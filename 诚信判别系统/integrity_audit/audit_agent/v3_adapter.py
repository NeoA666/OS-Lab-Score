"""Strict consumer for AI/human contribution-recognition v3 assessments.

This module is the integrity system boundary for contribution data.  It reads
only the fixed assessment JSON, rechecks source paths, hashes, line ranges and
excerpts, and exposes bounded read operations.  It never parses the upstream
Markdown reports or invokes the contribution-recognition tool.
"""

from __future__ import annotations

import hashlib
import json
import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Iterator, Mapping, Sequence

from .evidence import EvidenceRef, can_upgrade_to_e1, effective_evidence_level
from .errors import DataAccessError


V3_SCHEMA_VERSION = "ai-human-contribution-assessment/v3"
SUPPORTED_LABS = frozenset("lab" + str(i) for i in range(9))
ANALYSIS_STATUSES = frozenset({"complete", "insufficient_data", "failed"})
COVERAGE_STATUSES = frozenset({"complete", "insufficient", "insufficient_data", "partial", "failed"})
SOURCE_AVAILABILITIES = frozenset({"available", "missing", "invalid", "not_applicable"})
SOURCE_KINDS = frozenset({"timeline", "terminal_qa", "command_statistics", "diff_report"})
UNIT_TYPES = frozenset({"code_hunk", "process_segment"})
UNIT_LABELS = frozenset({"ai_dominant", "human_dominant", "mixed", "indeterminate"})
CONFIDENCE_VALUES = frozenset({"strong", "moderate", "weak"})
REVIEW_STATUSES = frozenset({"agreed", "disagreed", "not_run"})
REVIEW_DECISIONS = frozenset({"agree", "disagree"})
MAX_SOURCE_LINES_PER_CALL = 220
MAX_EXCERPT_CHARS = 600
DEFAULT_DATA_ROOT = (
    Path(__file__).resolve().parents[3]
    / "操作系统实验数据清洗"
    / "操作系统实验数据记录-已清洗"
)

SOURCE_LAYOUT: dict[str, tuple[str, str]] = {
    "timeline": ("简洁实验过程时间线", "timeline_{lab}.md"),
    "terminal_qa": ("终端对话记录", "terminal_qa_report_{lab}.md"),
    "command_statistics": ("终端命令统计", "command_statistics_{lab}.md"),
    "diff_report": ("代码差异报告", "{lab}.md"),
}

_LAB_RE = re.compile(r"^lab[0-8]$")
_SHA256_RE = re.compile(r"^[0-9a-fA-F]{64}$")
_PRIVATE_KEYS = frozenset({
    "reasoning_content", "reasoning", "chain_of_thought", "thoughts",
    "raw_response", "raw_model_response", "raw_nim_response",
    "model_response", "request_payload", "response_payload",
    "request_messages", "messages", "system_prompt", "prompt",
})
_PRIVATE_KEY_RE = re.compile(
    r"(?:reasoning|thought|chain.?of.?thought|raw.?response|model.?response|"
    r"request.?payload|response.?payload|system.?prompt)",
    re.IGNORECASE,
)
_SECRET_RE = re.compile(
    r"(?i)(?:nvapi-[A-Za-z0-9_-]+|bearer\s+[A-Za-z0-9._~+/=-]+|"
    r"(?:api[_ -]?key|token|password)\s*[:=]\s*[^\s,;]+)"
)
_REDACTION_MARKERS = ("[REDACTED]", "[已脱敏]", "<REDACTED>", "<已脱敏>", "***", "…", "...")


class V3ContractError(DataAccessError, ValueError):
    """The assessment cannot be consumed under the v3 contract."""


def _allowed(value: Any, values: frozenset[str]) -> bool:
    return isinstance(value, str) and value in values


def _safe_copy(value: Any) -> Any:
    if isinstance(value, dict):
        return {
            str(key): _safe_copy(item)
            for key, item in value.items()
            if (
                str(key).casefold() not in _PRIVATE_KEYS
                and not _PRIVATE_KEY_RE.search(str(key))
            )
        }
    if isinstance(value, list):
        return [_safe_copy(item) for item in value]
    if isinstance(value, tuple):
        return tuple(_safe_copy(item) for item in value)
    if isinstance(value, str):
        redacted = _redact_text(value)
        return redacted if len(redacted) <= 4000 else redacted[:3999] + "…"
    return value


def _redact_text(value: str) -> str:
    return _SECRET_RE.sub("[REDACTED]", value)


def _file_sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def _read_lines(path: Path) -> list[str]:
    return path.read_text(encoding="utf-8", errors="replace").splitlines()


def _normalise(value: str) -> str:
    return re.sub(r"\s+", " ", value).strip()


def _path_is_safe(relative_path: str) -> bool:
    candidate = Path(relative_path)
    return bool(
        relative_path
        and not candidate.is_absolute()
        and "\\" not in relative_path
        and ".." not in candidate.parts
    )


def _source_id_matches_lab(source_id: str, lab: str) -> bool:
    # The stable v3 identity is source:<lab>:<kind>.  An unqualified or
    # two-part short name is never inferred from a path.
    pieces = source_id.split(":") if isinstance(source_id, str) else []
    if len(pieces) == 3 and pieces[0] == "source":
        return pieces[1] == lab and pieces[2] in SOURCE_KINDS
    return False


def _excerpt_matches(excerpt: str, selected_lines: Sequence[str]) -> bool:
    if not isinstance(excerpt, str) or not excerpt.strip():
        return False
    source_norm = _normalise("\n".join(selected_lines))
    excerpt_norm = _normalise(excerpt)
    if excerpt_norm and excerpt_norm in source_norm:
        return True
    residual = excerpt
    for marker in _REDACTION_MARKERS:
        residual = residual.replace(marker, " ")
    residual = _SECRET_RE.sub(" ", residual)
    tokens = re.findall(r"[A-Za-z0-9_./:-]{2,}|[\u3400-\u9fff]{2,}", residual)
    if not tokens:
        return any(marker in excerpt for marker in _REDACTION_MARKERS)
    haystack = source_norm.casefold()
    matched = sum(1 for token in tokens if _normalise(token).casefold() in haystack)
    return matched >= max(1, (len(tokens) + 1) // 2)


@dataclass(frozen=True)
class SourceRecord:
    source_id: str
    kind: str
    required: bool
    availability: str
    relative_path: str | None
    sha256: str | None
    line_count: int | None
    reason: str | None = None
    actual_path: Path | None = field(default=None, repr=False, compare=False)
    issues: tuple[str, ...] = ()

    @property
    def available(self) -> bool:
        return self.availability == "available"

    @property
    def valid(self) -> bool:
        return self.available and not self.issues and self.actual_path is not None

    @property
    def evidence_level(self) -> str:
        # Cleaned Markdown is E2.  E1 needs independent raw provenance.
        return "E2"

    @property
    def path(self) -> str | None:
        return self.relative_path

    def to_dict(self) -> dict[str, Any]:
        return {
            "source_id": self.source_id,
            "kind": self.kind,
            "required": self.required,
            "availability": self.availability,
            "relative_path": self.relative_path,
            "sha256": self.sha256,
            "line_count": self.line_count,
            "reason": self.reason,
            "valid": self.valid,
            "issues": list(self.issues),
        }


@dataclass(frozen=True)
class ValidatedContributionUnit(Mapping[str, Any]):
    unit_id: str
    raw: Mapping[str, Any]
    evidence_refs: tuple[EvidenceRef, ...]
    valid: bool
    issues: tuple[str, ...] = ()

    @property
    def label(self) -> str:
        return str(self.raw.get("label") or "indeterminate")

    @property
    def confidence(self) -> str:
        return str(self.raw.get("confidence") or "weak")

    @property
    def unit_type(self) -> str:
        return str(self.raw.get("unit_type") or "unknown")

    @property
    def risk_signal(self) -> bool:
        return self.valid and self.label in {"ai_dominant", "mixed"} and self.confidence != "weak"

    def to_dict(self) -> dict[str, Any]:
        result = _safe_copy(dict(self.raw))
        result["evidence_refs"] = [item.to_dict() for item in self.evidence_refs]
        result["valid"] = self.valid
        if self.issues:
            result["validation_issues"] = list(self.issues)
        return result

    # Mapping compatibility lets host contracts consume a unit without
    # depending on this adapter's dataclass implementation.
    def __getitem__(self, key: str) -> Any:
        return self.to_dict()[key]

    def __iter__(self) -> Iterator[str]:
        return iter(self.to_dict())

    def __len__(self) -> int:
        return len(self.to_dict())


@dataclass(frozen=True)
class StudentLabSnapshot:
    data_root: Path
    student_directory: str
    student_id: str | None
    lab: str
    student_dir: Path
    assessment_path: Path
    assessment: Mapping[str, Any] | None
    assessment_status: str
    compatibility: str
    coverage: Mapping[str, Any]
    source_manifest: tuple[SourceRecord, ...]
    diff_hunks: Mapping[str, Mapping[str, Any]]
    contribution_units: tuple[ValidatedContributionUnit, ...]
    lab_conclusion: Mapping[str, Any] | None
    lab_conclusion_valid: bool
    review: Mapping[str, Any]
    review_valid: bool
    issues: tuple[str, ...] = ()

    @property
    def sources(self) -> tuple[SourceRecord, ...]:
        return self.source_manifest

    @property
    def source_by_id(self) -> dict[str, SourceRecord]:
        return {item.source_id: item for item in self.source_manifest}

    @property
    def assessment_available(self) -> bool:
        return self.assessment is not None

    @property
    def analysis_status(self) -> str:
        return self.assessment_status

    @property
    def source_manifest_by_id(self) -> dict[str, SourceRecord]:
        return self.source_by_id

    @property
    def compatible(self) -> bool:
        return self.compatibility == "compatible"

    @property
    def semantic_consumable(self) -> bool:
        required_sources_valid = all(
            (not source.required) or source.valid
            for source in self.source_manifest
        )
        return bool(
            self.compatible
            and self.assessment_status == "complete"
            and self.lab_conclusion_valid
            and required_sources_valid
            and not self.issues
        )

    @property
    def contribution_layer_usable(self) -> bool:
        return bool(
            self.semantic_consumable
            and self.lab_conclusion_valid
            and self.coverage.get("status") == "complete"
        )

    @property
    def coverage_complete(self) -> bool:
        return self.coverage.get("status") == "complete"

    @property
    def contribution_refs_valid(self) -> bool:
        """Whether the Lab-level contribution references survived revalidation."""

        return bool(self.compatible and self.lab_conclusion_valid and not self.issues)

    @property
    def review_status(self) -> str:
        return str(self.review.get("status") or "not_run")

    @property
    def review_agreed(self) -> bool:
        return bool(
            self.review_valid
            and self.review_status == "agreed"
            and self.review.get("overall_decision") == "agree"
        )

    @property
    def risk_upgrade_allowed(self) -> bool:
        return bool(self.contribution_layer_usable and self.review_agreed)

    @property
    def valid_units(self) -> tuple[ValidatedContributionUnit, ...]:
        return tuple(item for item in self.contribution_units if item.valid)

    @property
    def valid_contribution_units(self) -> tuple[ValidatedContributionUnit, ...]:
        return self.valid_units

    @property
    def invalid_units(self) -> tuple[ValidatedContributionUnit, ...]:
        return tuple(item for item in self.contribution_units if not item.valid)

    @property
    def disagreement_unit_ids(self) -> frozenset[str]:
        values = self.review.get("disagreement_unit_ids")
        return frozenset(item for item in values if isinstance(item, str)) if isinstance(values, list) else frozenset()

    def unit(self, unit_id: str) -> ValidatedContributionUnit:
        for item in self.contribution_units:
            if item.unit_id == unit_id:
                return item
        raise DataAccessError("当前 assessment 不存在 contribution unit：" + unit_id)

    def inventory(self) -> dict[str, Any]:
        return {
            "student_directory": self.student_directory,
            "student_id": self.student_id,
            "lab": self.lab,
            "assessment_path": str(self.assessment_path.relative_to(self.student_dir)),
            "assessment_available": self.assessment_available,
            "schema_compatible": self.compatible,
            "analysis_status": self.assessment_status,
            "coverage": _safe_copy(dict(self.coverage)),
            "coverage_complete": self.coverage_complete,
            "review_status": self.review_status,
            "review_overall_decision": self.review.get("overall_decision"),
            "contribution_layer_usable": self.contribution_layer_usable,
            "risk_upgrade_allowed": self.risk_upgrade_allowed,
            "source_manifest": [item.to_dict() for item in self.source_manifest],
            "diff_hunks": [
                {
                    key: _safe_copy(hunk[key])
                    for key in (
                        "hunk_id",
                        "file_path",
                        "source_id",
                        "line_start",
                        "line_end",
                        "change_kind",
                        "old_line_start",
                        "old_line_count",
                        "new_line_start",
                        "new_line_count",
                    )
                    if key in hunk
                }
                for hunk in self.diff_hunks.values()
            ],
            "unit_count": len(self.contribution_units),
            "valid_unit_ids": [item.unit_id for item in self.valid_units],
            "invalid_unit_ids": [item.unit_id for item in self.invalid_units],
            "issues": list(self.issues),
            "read_only_scope": "仅当前学生目录、当前 lab 和 assessment source_manifest",
        }

    def status(self) -> dict[str, Any]:
        result = self.inventory()
        result["limitations"] = _safe_copy(
            list(self.assessment.get("limitations", []))
            if isinstance(self.assessment, Mapping) and isinstance(self.assessment.get("limitations"), list)
            else []
        )
        return result

    @property
    def assessment_fingerprint(self) -> str | None:
        value = self.assessment.get("input_fingerprint") if isinstance(self.assessment, Mapping) else None
        return value if isinstance(value, str) else None

    @property
    def source_fingerprint(self) -> str:
        payload = json.dumps(
            [item.to_dict() for item in self.source_manifest],
            ensure_ascii=False,
            sort_keys=True,
            separators=(",", ":"),
        ).encode("utf-8")
        return "sha256:" + hashlib.sha256(payload).hexdigest()

    def read_source_range(
        self,
        source_id: str,
        start_line: int,
        end_line: int,
        *,
        max_lines: int = MAX_SOURCE_LINES_PER_CALL,
    ) -> dict[str, Any]:
        source = self.source_by_id.get(source_id)
        if source is None:
            raise DataAccessError("source_id 不属于当前学生/Lab assessment：" + str(source_id))
        if not source.valid or source.actual_path is None:
            detail = "; ".join(source.issues) or source.availability
            raise DataAccessError("来源不可读取：" + source_id + "（" + detail + "）")
        if (
            isinstance(start_line, bool)
            or isinstance(end_line, bool)
            or not isinstance(start_line, int)
            or not isinstance(end_line, int)
            or start_line < 1
            or end_line < start_line
        ):
            raise DataAccessError("行范围无效")
        cap = max(1, min(int(max_lines), MAX_SOURCE_LINES_PER_CALL))
        end_line = min(end_line, start_line + cap - 1)
        current_hash = _file_sha256(source.actual_path)
        if current_hash.casefold() != str(source.sha256).casefold():
            raise DataAccessError("来源哈希已变化，拒绝读取：" + source_id)
        lines = _read_lines(source.actual_path)
        if end_line > len(lines):
            raise DataAccessError("行范围越出来源文件：" + source_id)
        selected = lines[start_line - 1:end_line]
        return {
            "source_id": source.source_id,
            "kind": source.kind,
            "relative_path": source.relative_path,
            "sha256": source.sha256,
            "line_start": start_line,
            "line_end": end_line,
            "total_lines": len(lines),
            "lines": [
                {"line": start_line + offset, "text": _redact_text(line)}
                for offset, line in enumerate(selected)
            ],
            "evidence_level": "E2",
        }

    def read_source(self, source_id: str, start_line: int, end_line: int) -> dict[str, Any]:
        return self.read_source_range(source_id, start_line, end_line)

    def read_v3_source_range(
        self, source_id: str, start_line: int, end_line: int
    ) -> dict[str, Any]:
        return self.read_source_range(source_id, start_line, end_line)

    def read_unit(self, unit_id: str) -> dict[str, Any]:
        unit = self.unit(unit_id)
        result = unit.to_dict()
        scope = result.get("scope")
        if isinstance(scope, Mapping) and isinstance(scope.get("hunk_id"), str):
            hunk = self.diff_hunks.get(scope["hunk_id"])
            if isinstance(hunk, Mapping):
                result["diff_hunk"] = _safe_copy(dict(hunk))
        return result

    def read_contribution_unit(self, unit_id: str) -> dict[str, Any]:
        return self.read_unit(unit_id)

    def read_v3_unit(self, unit_id: str) -> dict[str, Any]:
        return self.read_unit(unit_id)

    def read_reference(self, reference: EvidenceRef | Mapping[str, Any]) -> dict[str, Any]:
        if isinstance(reference, EvidenceRef):
            if reference.kind != "v3":
                raise DataAccessError("事件证据不通过 v3 source-range 接口读取")
            if not reference.valid:
                raise DataAccessError(reference.invalid_reason or "证据引用无效")
            source_id, start, end = reference.source_id, reference.line_start, reference.line_end
            source = self.source_by_id.get(source_id or "")
            if source is None:
                raise DataAccessError("source_id 不属于当前 assessment")
            if reference.relative_path != source.relative_path or reference.sha256 != source.sha256:
                raise DataAccessError("EvidenceRef 路径或哈希与 source_manifest 不一致")
            result = self.read_source_range(source_id or "", start or 0, end or 0)
            if reference.excerpt and not _excerpt_matches(
                reference.excerpt,
                [item["text"] for item in result["lines"]],
            ):
                raise DataAccessError("EvidenceRef excerpt 不在声明范围内")
            return result
        else:
            source_id = reference.get("source_id")
            start, end = reference.get("line_start"), reference.get("line_end")
            full_fields = {
                "source_id",
                "relative_path",
                "sha256",
                "line_start",
                "line_end",
                "excerpt",
            }
            if full_fields.issubset(reference):
                source = self.source_by_id.get(source_id if isinstance(source_id, str) else "")
                if source is None or not source.valid or source.actual_path is None:
                    raise DataAccessError("v3 引用来源不可用")
                if reference.get("relative_path") != source.relative_path:
                    raise DataAccessError("v3 引用路径与 source_manifest 不一致")
                if reference.get("sha256") != source.sha256:
                    raise DataAccessError("v3 引用哈希与 source_manifest 不一致")
                if (
                    isinstance(start, bool)
                    or isinstance(end, bool)
                    or not isinstance(start, int)
                    or not isinstance(end, int)
                    or start < 1
                    or end < start
                    or (source.line_count is not None and end > source.line_count)
                ):
                    raise DataAccessError("v3 引用行范围无效")
                source_result = self.read_source_range(source_id, start, end)
                excerpt = reference.get("excerpt")
                if not isinstance(excerpt, str) or not _excerpt_matches(
                    excerpt,
                    [item["text"] for item in source_result["lines"]],
                ):
                    raise DataAccessError("v3 引用摘录不在声明范围内")
                return source_result
        if not isinstance(source_id, str) or not isinstance(start, int) or not isinstance(end, int):
            raise DataAccessError("v3 引用必须包含 source_id、line_start、line_end")
        return self.read_source_range(source_id, start, end)

    def contribution_signals(self) -> list[dict[str, Any]]:
        result: list[dict[str, Any]] = []
        for unit in self.contribution_units:
            eligible = bool(
                self.risk_upgrade_allowed
                and unit.risk_signal
                and unit.unit_id not in self.disagreement_unit_ids
            )
            result.append({
                "unit_id": unit.unit_id,
                "unit_type": unit.unit_type,
                "label": unit.label,
                "confidence": unit.confidence,
                "valid": unit.valid,
                "risk_signal": eligible,
                "evidence_refs": [ref.to_dict() for ref in unit.evidence_refs],
                "issues": list(unit.issues),
            })
        return result


class ContributionAssessmentV3Adapter:
    """Load and revalidate one fixed-path v3 assessment."""

    def __init__(self, data_root: Path | None = None, *, max_source_lines: int = MAX_SOURCE_LINES_PER_CALL) -> None:
        if data_root is not None and hasattr(data_root, "data_root"):
            data_root = getattr(data_root, "data_root")
        self.data_root = Path(data_root or DEFAULT_DATA_ROOT).expanduser().resolve()
        self.max_source_lines = max(1, min(int(max_source_lines), MAX_SOURCE_LINES_PER_CALL))

    @staticmethod
    def validate_lab(lab: str) -> str:
        if not isinstance(lab, str) or not _LAB_RE.fullmatch(lab):
            raise DataAccessError("实验标签必须是 lab0 至 lab8")
        return lab

    def assessment_path(self, student_reference: str | Path, lab: str) -> Path:
        lab = self.validate_lab(lab)
        student_dir = self._resolve_student(student_reference)
        path = (student_dir / "AI人工贡献识别" / "assessment" / ("assessment_" + lab + ".json")).resolve()
        self._ensure_inside(path, student_dir)
        return path

    def load(
        self,
        student_reference: str | Path,
        lab: str,
        *,
        strict: bool = False,
    ) -> StudentLabSnapshot:
        lab = self.validate_lab(lab)
        student_dir = self._resolve_student(student_reference)
        student_id = self._student_id(student_dir)
        path = (
            student_dir / "AI人工贡献识别" / "assessment" / ("assessment_" + lab + ".json")
        ).resolve()
        self._ensure_inside(path, student_dir)
        if not path.is_file():
            snapshot = self._empty_snapshot(
                student_dir=student_dir,
                student_id=student_id,
                lab=lab,
                path=path,
                status="missing",
                compatibility="missing",
                issues=("assessment 文件不存在：" + str(path.relative_to(student_dir)),),
            )
            if strict:
                raise V3ContractError(snapshot.issues[0])
            return snapshot
        try:
            raw = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, UnicodeError, json.JSONDecodeError) as error:
            snapshot = self._empty_snapshot(
                student_dir=student_dir,
                student_id=student_id,
                lab=lab,
                path=path,
                status="invalid",
                compatibility="incompatible",
                issues=("assessment JSON 无法读取或解析：" + error.__class__.__name__,),
            )
            if strict:
                raise V3ContractError(snapshot.issues[0]) from error
            return snapshot
        if not isinstance(raw, dict):
            snapshot = self._empty_snapshot(
                student_dir=student_dir,
                student_id=student_id,
                lab=lab,
                path=path,
                status="invalid",
                compatibility="incompatible",
                issues=("assessment JSON 根节点必须是对象",),
            )
            if strict:
                raise V3ContractError(snapshot.issues[0])
            return snapshot

        schema = raw.get("schema_version")
        if schema != V3_SCHEMA_VERSION:
            legacy = isinstance(schema, str) and "/v2" in schema
            compatibility = "legacy/incompatible" if legacy else "incompatible"
            snapshot = self._empty_snapshot(
                student_dir=student_dir,
                student_id=student_id,
                lab=lab,
                path=path,
                status="legacy/incompatible" if legacy else "incompatible",
                compatibility=compatibility,
                assessment=_safe_copy(raw),
                issues=("不支持的 schema_version：" + repr(schema) + "；只消费 " + V3_SCHEMA_VERSION,),
            )
            if strict:
                raise V3ContractError(snapshot.issues[0])
            return snapshot

        snapshot = self._validate_v3(
            raw=raw,
            student_dir=student_dir,
            student_id=student_id,
            lab=lab,
            path=path,
        )
        if strict and (not snapshot.compatible or not snapshot.semantic_consumable):
            raise V3ContractError("；".join(snapshot.issues) or "v3 assessment 不能安全消费")
        return snapshot

    def inspect(self, student_reference: str | Path, lab: str, *, strict: bool = False) -> StudentLabSnapshot:
        return self.load(student_reference, lab, strict=strict)

    def read(self, student_reference: str | Path, lab: str, *, strict: bool = False) -> StudentLabSnapshot:
        return self.load(student_reference, lab, strict=strict)

    def status(self, student_reference: str | Path, lab: str) -> dict[str, Any]:
        return self.load(student_reference, lab).status()

    def inventory(self, student_reference: str | Path, lab: str) -> dict[str, Any]:
        return self.load(student_reference, lab).inventory()

    def read_unit(self, student_reference: str | Path, lab: str, unit_id: str) -> dict[str, Any]:
        return self.load(student_reference, lab).read_unit(unit_id)

    def read_v3_unit(self, student_reference: str | Path, lab: str, unit_id: str) -> dict[str, Any]:
        return self.read_unit(student_reference, lab, unit_id)

    def read_source_range(
        self,
        student_reference: str | Path,
        lab: str,
        source_id: str,
        start_line: int,
        end_line: int,
    ) -> dict[str, Any]:
        return self.load(student_reference, lab).read_source_range(
            source_id, start_line, end_line, max_lines=self.max_source_lines
        )

    def read_v3_source_range(
        self,
        student_reference: str | Path,
        lab: str,
        source_id: str,
        start_line: int,
        end_line: int,
    ) -> dict[str, Any]:
        return self.read_source_range(student_reference, lab, source_id, start_line, end_line)

    def require(self, student_reference: str | Path, lab: str) -> StudentLabSnapshot:
        return self.load(student_reference, lab, strict=True)

    def load_for_directory(self, student_directory: Path, lab: str, *, strict: bool = False) -> StudentLabSnapshot:
        student_directory = Path(student_directory).resolve()
        self._ensure_inside(student_directory, self.data_root)
        return self.load(student_directory.name, lab, strict=strict)

    def event_evidence(
        self,
        event_id: str,
        quote: str,
        *,
        evidence_level: str = "E2",
        provenance: Mapping[str, Any] | None = None,
        independent_archive: bool = False,
        archive_sha256: str | None = None,
        collection_chain: bool = False,
        precise_location: bool = False,
    ) -> EvidenceRef:
        level = (
            "E1"
            if evidence_level == "E1"
            and can_upgrade_to_e1(
                independent_archive=independent_archive,
                archive_sha256=archive_sha256,
                collection_chain=collection_chain,
                precise_location=precise_location,
            )
            else "E2"
        )
        return EvidenceRef.from_event(event_id, quote, evidence_level=level, provenance=provenance)

    def _resolve_student(self, student_reference: str | Path) -> Path:
        if not self.data_root.is_dir():
            raise DataAccessError("清洗数据目录不存在：" + str(self.data_root))
        if isinstance(student_reference, Path):
            candidate = student_reference.expanduser().resolve()
            self._ensure_inside(candidate, self.data_root)
            if not candidate.is_dir():
                raise DataAccessError("学生目录不存在：" + str(candidate))
            return candidate
        if not isinstance(student_reference, str) or not student_reference.strip():
            raise DataAccessError("学生标识不能为空")
        if "/" in student_reference or "\\" in student_reference:
            raise DataAccessError("学生标识不能包含路径分隔符")
        direct = (self.data_root / student_reference).resolve()
        if direct.is_dir():
            self._ensure_inside(direct, self.data_root)
            return direct
        matches = [
            item.resolve()
            for item in sorted(self.data_root.iterdir())
            if item.is_dir() and self._student_id(item) == student_reference
        ]
        if len(matches) == 1:
            return matches[0]
        if not matches:
            raise DataAccessError("未找到学生：" + student_reference)
        raise DataAccessError("学生标识不唯一：" + student_reference)

    @staticmethod
    def _ensure_inside(path: Path, root: Path) -> None:
        try:
            path.relative_to(root)
        except ValueError as error:
            raise DataAccessError("路径越过允许的学生目录范围") from error

    @staticmethod
    def _student_id(student_dir: Path) -> str | None:
        timeline_dir = student_dir / "实验过程时间线"
        if not timeline_dir.is_dir():
            return None
        for path in sorted(timeline_dir.glob("timeline_*.json")):
            try:
                value = json.loads(path.read_text(encoding="utf-8"))
            except (OSError, UnicodeError, json.JSONDecodeError):
                continue
            if isinstance(value, dict) and isinstance(value.get("student"), dict):
                student_id = value["student"].get("student_id")
                if isinstance(student_id, str) and student_id:
                    return student_id
        return None

    def _empty_snapshot(
        self,
        *,
        student_dir: Path,
        student_id: str | None,
        lab: str,
        path: Path,
        status: str,
        compatibility: str,
        assessment: Mapping[str, Any] | None = None,
        issues: tuple[str, ...] = (),
    ) -> StudentLabSnapshot:
        return StudentLabSnapshot(
            data_root=self.data_root,
            student_directory=student_dir.name,
            student_id=student_id,
            lab=lab,
            student_dir=student_dir,
            assessment_path=path,
            assessment=assessment,
            assessment_status=status,
            compatibility=compatibility,
            coverage={},
            source_manifest=(),
            diff_hunks={},
            contribution_units=(),
            lab_conclusion=None,
            lab_conclusion_valid=False,
            review={
                "status": "not_run",
                "overall_decision": None,
                "unit_reviews": [],
                "reviewed_unit_ids": [],
                "disagreement_unit_ids": [],
            },
            review_valid=False,
            issues=issues,
        )

    def _validate_v3(
        self,
        *,
        raw: dict[str, Any],
        student_dir: Path,
        student_id: str | None,
        lab: str,
        path: Path,
    ) -> StudentLabSnapshot:
        # Keep the original JSON for excerpt verification; sanitize only the
        # snapshot exposed to callers after all integrity checks complete.
        safe_raw = _safe_copy(raw)
        issues: list[str] = []
        required_top_level = (
            "analysis_status",
            "student",
            "lab",
            "coverage",
            "source_manifest",
            "diff_hunks",
            "contribution_units",
            "lab_conclusion",
            "review",
            "limitations",
            "run_metadata",
        )
        for field_name in required_top_level:
            if field_name not in raw:
                issues.append("assessment 缺少字段：" + field_name)
        student = raw.get("student")
        if not isinstance(student, dict):
            issues.append("student 必须是对象")
            student = {}
        else:
            for field_name in ("directory_name", "student_id", "display_name"):
                if field_name not in student:
                    issues.append("student 缺少字段：" + field_name)
            directory_name = student.get("directory_name")
            if not isinstance(directory_name, str) or not directory_name.strip():
                issues.append("student.directory_name 必须是非空字符串")
            elif directory_name != student_dir.name:
                issues.append("student.directory_name 与当前学生目录不匹配")
            for field_name in ("student_id", "display_name"):
                value = student.get(field_name)
                if value is not None and (
                    not isinstance(value, str) or not value.strip()
                ):
                    issues.append(
                        "student." + field_name + " 必须是字符串或 null"
                    )
            if (
                isinstance(student_id, str)
                and student_id
                and isinstance(student.get("student_id"), str)
                and student.get("student_id") != student_id
            ):
                issues.append("student.student_id 与当前时间线学生标识不一致")
        if raw.get("lab") != lab:
            issues.append("assessment.lab 与当前 Lab 不匹配")
        status = raw.get("analysis_status")
        if not _allowed(status, ANALYSIS_STATUSES):
            issues.append("analysis_status 无效")
            status = "invalid"
        coverage = raw.get("coverage")
        if not isinstance(coverage, dict):
            issues.append("coverage 必须是对象")
            coverage = {}
        elif not _allowed(coverage.get("status"), COVERAGE_STATUSES):
            issues.append("coverage.status 无效")
        elif not isinstance(coverage.get("missing_or_limited"), list):
            issues.append("coverage.missing_or_limited 必须是数组")

        limitations = raw.get("limitations")
        if not isinstance(limitations, list):
            issues.append("limitations 必须是数组")
        elif any(not isinstance(item, str) or not item.strip() for item in limitations):
            issues.append("limitations 必须是非空字符串数组")
        run_metadata = raw.get("run_metadata")
        if not isinstance(run_metadata, dict):
            issues.append("run_metadata 必须是对象")

        source_manifest, source_issues = self._parse_sources(
            raw.get("source_manifest"), student_dir, lab
        )
        issues.extend(source_issues)
        source_by_id = {item.source_id: item for item in source_manifest}
        hunk_by_id, hunk_issues = self._parse_hunks(
            raw.get("diff_hunks"), source_by_id, lab
        )
        issues.extend(hunk_issues)

        units_raw = raw.get("contribution_units")
        if not isinstance(units_raw, list):
            issues.append("contribution_units 必须是数组")
            units_raw = []
        units: list[ValidatedContributionUnit] = []
        unit_ids: set[str] = set()
        for index, value in enumerate(units_raw):
            unit, unit_issues = self._parse_unit(
                value, index, source_by_id, hunk_by_id, lab=lab
            )
            if unit.unit_id in unit_ids:
                unit_issues = [*unit_issues, "unit_id 重复"]
            unit_ids.add(unit.unit_id)
            units.append(
                ValidatedContributionUnit(
                    unit_id=unit.unit_id,
                    raw=unit.raw,
                    evidence_refs=unit.evidence_refs,
                    valid=unit.valid and not unit_issues,
                    issues=tuple(unit_issues),
                )
            )

        conclusion, conclusion_valid, conclusion_issues = self._parse_conclusion(
            raw.get("lab_conclusion"), source_by_id
        )
        issues.extend(conclusion_issues)
        review, review_valid, review_issues = self._parse_review(
            raw.get("review"),
            source_by_id,
            unit_ids,
            reviewable_unit_ids={item.unit_id for item in units if item.valid},
        )
        issues.extend(review_issues)
        if review.get("status") == "disagreed":
            disagreement_ids = {
                item for item in review.get("disagreement_unit_ids", [])
                if isinstance(item, str)
            }
            if disagreement_ids:
                downgraded: list[ValidatedContributionUnit] = []
                for unit in units:
                    if unit.unit_id not in disagreement_ids:
                        downgraded.append(unit)
                        continue
                    changed = _safe_copy(dict(unit.raw))
                    changed.setdefault("original_label", changed.get("label"))
                    changed.setdefault("original_confidence", changed.get("confidence"))
                    changed["label"] = "indeterminate"
                    changed["confidence"] = "weak"
                    downgraded.append(
                        ValidatedContributionUnit(
                            unit_id=unit.unit_id,
                            raw=changed,
                            evidence_refs=unit.evidence_refs,
                            valid=unit.valid,
                            issues=unit.issues,
                        )
                    )
                units = downgraded

        for kind in self._expected_kinds(lab):
            matching = [item for item in source_manifest if item.kind == kind]
            if not matching:
                issues.append("缺少 source_manifest 材料类型：" + kind)
            else:
                expected_required = not (lab == "lab0" and kind == "diff_report")
                if matching[0].required != expected_required:
                    issues.append("source_manifest.required 与 Lab 契约不一致：" + kind)
                if matching[0].required and not matching[0].available and status == "complete":
                    issues.append("规定材料不可用：" + kind)
        if lab == "lab0":
            diff_sources = [item for item in source_manifest if item.kind == "diff_report"]
            if diff_sources and diff_sources[0].availability != "not_applicable":
                issues.append("lab0 的 diff_report 必须是 not_applicable")
            if hunk_by_id:
                issues.append("lab0 不应包含 diff_hunks")

        if status in {"insufficient_data", "failed"}:
            if units:
                issues.append(status + " assessment 不得包含 contribution_units")
            if not isinstance(conclusion, Mapping) or conclusion.get("label") != "indeterminate":
                issues.append(status + " assessment 的 lab_conclusion 必须是 indeterminate")

        structural_markers = (
            "assessment 缺少字段",
            "student 必须是对象",
            "student 缺少字段",
            "student.",
            "assessment.lab",
            "analysis_status",
            "coverage",
            "source_manifest",
            "diff_hunks",
            "缺少 source_manifest",
            "lab0",
            "insufficient_data assessment",
            "failed assessment",
            "limitations",
            "run_metadata",
        )
        compatibility = (
            "incompatible"
            if any(issue.startswith(marker) for issue in issues for marker in structural_markers)
            else "compatible"
        )
        # A manifest path/hash/range problem makes the source contract unsafe.
        if any(
            any(token in issue for token in ("路径", "哈希", "source_id", "relative_path", "sha256", "越出"))
            for issue in issues
        ):
            compatibility = "incompatible"

        return StudentLabSnapshot(
            data_root=self.data_root,
            student_directory=student_dir.name,
            student_id=(
                student.get("student_id")
                if isinstance(student.get("student_id"), str)
                else student_id
            ),
            lab=lab,
            student_dir=student_dir,
            assessment_path=path,
            assessment=safe_raw,
            assessment_status=status,
            compatibility=compatibility,
            coverage=_safe_copy(coverage),
            source_manifest=tuple(source_manifest),
            diff_hunks={key: _safe_copy(value) for key, value in hunk_by_id.items()},
            contribution_units=tuple(units),
            lab_conclusion=conclusion,
            lab_conclusion_valid=conclusion_valid,
            review=review,
            review_valid=review_valid,
            issues=tuple(issues),
        )

    @staticmethod
    def _expected_kinds(lab: str) -> tuple[str, ...]:
        # Lab0 still carries all four manifest slots; diff_report is explicitly
        # not_applicable. Labs 1-8 require all four as available inputs.
        return ("timeline", "terminal_qa", "command_statistics", "diff_report")

    def _parse_sources(
        self,
        value: Any,
        student_dir: Path,
        lab: str,
    ) -> tuple[list[SourceRecord], list[str]]:
        if not isinstance(value, list):
            return [], ["source_manifest 必须是数组"]
        issues: list[str] = []
        records: list[SourceRecord] = []
        ids: set[str] = set()
        kinds: set[str] = set()
        for index, item in enumerate(value):
            if not isinstance(item, dict):
                issues.append("source_manifest[" + str(index) + "] 必须是对象")
                continue
            source_id = item.get("source_id")
            kind = item.get("kind")
            required = item.get("required")
            availability = item.get("availability")
            rel = item.get("relative_path")
            sha = item.get("sha256")
            line_count = item.get("line_count")
            reason = _redact_text(item["reason"]) if isinstance(item.get("reason"), str) else None
            local: list[str] = []
            if not isinstance(source_id, str) or not source_id:
                source_id = "<invalid-source-" + str(index) + ">"
                local.append("source_id 无效")
            elif not _source_id_matches_lab(source_id, lab):
                local.append("source_id 未使用完整的当前 Lab 标识")
            if source_id in ids:
                local.append("source_id 重复")
            ids.add(source_id)
            if not _allowed(kind, SOURCE_KINDS):
                local.append("kind 无效")
                kind = str(kind or "unknown")
            elif kind in kinds:
                local.append("kind 重复")
            kinds.add(kind)
            if not isinstance(required, bool):
                local.append("required 必须是布尔值")
                required = bool(required)
            if not _allowed(availability, SOURCE_AVAILABILITIES):
                local.append("availability 无效")
                availability = "invalid"
            if availability == "available":
                if not isinstance(rel, str) or not _path_is_safe(rel):
                    local.append("available source 的 relative_path 无效或越界")
                if not isinstance(sha, str) or not _SHA256_RE.fullmatch(sha):
                    local.append("available source 的 sha256 无效")
                if (
                    isinstance(line_count, bool)
                    or not isinstance(line_count, int)
                    or line_count < 0
                ):
                    local.append("available source 的 line_count 无效")
            elif availability == "not_applicable":
                if required:
                    local.append("required source 不能标记为 not_applicable")
                if rel is not None or sha is not None or line_count is not None:
                    local.append("not_applicable source 的路径、哈希和行数必须为 null")
            elif availability in {"missing", "invalid"} and rel is not None:
                if not isinstance(rel, str) or not _path_is_safe(rel):
                    local.append("不可用 source 的 relative_path 无效")

            actual_path: Path | None = None
            expected_dir, expected_name = SOURCE_LAYOUT.get(kind, ("", ""))
            expected_rel = (
                expected_dir + "/" + expected_name.format(lab=lab)
                if expected_dir
                else None
            )
            if availability == "available" and isinstance(rel, str) and _path_is_safe(rel):
                actual_path = (student_dir / rel).resolve()
                try:
                    self._ensure_inside(actual_path, student_dir)
                except DataAccessError:
                    local.append("来源路径越过学生目录")
                    actual_path = None
                if expected_rel and rel != expected_rel:
                    local.append("来源路径与 kind/Lab 不匹配")
                if actual_path is None or not actual_path.is_file():
                    local.append("来源文件不存在")
                else:
                    try:
                        actual_hash = _file_sha256(actual_path)
                        actual_lines = len(_read_lines(actual_path))
                    except OSError:
                        local.append("来源文件无法读取")
                    else:
                        if isinstance(sha, str) and actual_hash.casefold() != sha.casefold():
                            local.append("来源文件 SHA-256 不一致")
                        if isinstance(line_count, int) and actual_lines != line_count:
                            local.append("来源文件行数不一致")
            records.append(
                SourceRecord(
                    source_id=source_id,
                    kind=kind,
                    required=required,
                    availability=availability,
                    relative_path=rel if isinstance(rel, str) else None,
                    sha256=sha if isinstance(sha, str) else None,
                    line_count=line_count if isinstance(line_count, int) else None,
                    reason=reason,
                    actual_path=actual_path,
                    issues=tuple(local),
                )
            )
            for error in local:
                if any(
                    token in error
                    for token in (
                        "source_id",
                        "kind",
                        "路径",
                        "SHA-256",
                        "行数",
                        "越过",
                        "relative_path",
                        "not_applicable",
                    )
                ):
                    issues.append(
                        "source_manifest[" + str(index) + "]：" + error
                    )
        unknown = kinds - set(self._expected_kinds(lab))
        if unknown:
            issues.append("source_manifest 含未知材料类型：" + ", ".join(sorted(unknown)))
        return records, issues

    @staticmethod
    def _parse_hunks(
        value: Any,
        sources: Mapping[str, SourceRecord],
        lab: str,
    ) -> tuple[dict[str, Mapping[str, Any]], list[str]]:
        if not isinstance(value, list):
            return {}, ["diff_hunks 必须是数组"]
        issues: list[str] = []
        result: dict[str, Mapping[str, Any]] = {}
        for index, item in enumerate(value):
            if not isinstance(item, dict):
                issues.append("diff_hunks[" + str(index) + "] 必须是对象")
                continue
            hunk_id = item.get("hunk_id")
            file_path = item.get("file_path")
            source_id = item.get("source_id")
            start, end = item.get("line_start"), item.get("line_end")
            if not isinstance(hunk_id, str) or not hunk_id:
                issues.append("diff_hunks[" + str(index) + "].hunk_id 无效")
                continue
            if hunk_id in result:
                issues.append("diff_hunks[" + str(index) + "] hunk_id 重复")
            if not isinstance(file_path, str) or not file_path.strip() or not _path_is_safe(file_path):
                issues.append("diff_hunks[" + str(index) + "].file_path 无效或越界")
            if not isinstance(source_id, str) or not source_id:
                issues.append("diff_hunks[" + str(index) + "].source_id 无效")
            source = sources.get(source_id) if isinstance(source_id, str) else None
            if source is None or source.kind != "diff_report" or not source.valid:
                issues.append("diff_hunks[" + str(index) + "].source_id 不是当前 Lab diff_report")
            if (
                isinstance(start, bool)
                or isinstance(end, bool)
                or not isinstance(start, int)
                or not isinstance(end, int)
                or start < 1
                or end < start
            ):
                issues.append("diff_hunks[" + str(index) + "] 行范围无效")
            elif (
                source is not None
                and isinstance(source.line_count, int)
                and end > source.line_count
            ):
                issues.append("diff_hunks[" + str(index) + "] 行范围越出来源")
            result[hunk_id] = _safe_copy(item)
        if lab == "lab0" and result:
            issues.append("lab0 不应包含 diff_hunks")
        return result, issues

    def _parse_unit(
        self,
        value: Any,
        index: int,
        sources: Mapping[str, SourceRecord],
        hunks: Mapping[str, Mapping[str, Any]],
        *,
        lab: str,
    ) -> tuple[ValidatedContributionUnit, list[str]]:
        if not isinstance(value, dict):
            issue = "unit 必须是对象"
            return (
                ValidatedContributionUnit(
                    unit_id="<invalid-unit-" + str(index) + ">",
                    raw={},
                    evidence_refs=(),
                    valid=False,
                    issues=(issue,),
                ),
                [issue],
            )
        original = value
        raw = _safe_copy(value)
        raw_id = raw.get("unit_id")
        unit_id = raw_id if isinstance(raw_id, str) and raw_id else "<invalid-unit-" + str(index) + ">"
        issues: list[str] = []
        if unit_id.startswith("<invalid-unit-"):
            issues.append("unit_id 无效")
        unit_type = raw.get("unit_type")
        if not _allowed(unit_type, UNIT_TYPES):
            issues.append("unit_type 无效")
        elif lab == "lab0" and unit_type != "process_segment":
            # Lab0 is process-only.  Keep this as a unit-local failure so a
            # malformed contribution unit cannot invalidate unrelated units
            # or the legacy integrity evidence for the same Lab.
            issues.append("lab0 只能包含 process_segment 贡献单元")
        label = raw.get("label")
        if not _allowed(label, UNIT_LABELS):
            issues.append("label 无效")
        confidence = raw.get("confidence")
        if not _allowed(confidence, CONFIDENCE_VALUES):
            issues.append("confidence 无效")
        if confidence == "weak" and label != "indeterminate":
            issues.append("弱证据必须使用 indeterminate")

        behavior_roles = raw.get("behavior_roles")
        if not isinstance(behavior_roles, dict):
            issues.append("behavior_roles 必须是对象")
        else:
            for owner in ("ai", "human"):
                roles = behavior_roles.get(owner)
                if not isinstance(roles, list) or any(
                    not isinstance(role, str) or not role.strip() for role in roles
                ):
                    issues.append(f"behavior_roles.{owner} 必须是字符串数组")
        summary = raw.get("summary")
        if not isinstance(summary, str) or not summary.strip():
            issues.append("summary 必须是非空字符串")
        alternative_explanation = raw.get("alternative_explanation")
        if not isinstance(alternative_explanation, str) or not alternative_explanation.strip():
            issues.append("alternative_explanation 必须是非空字符串")
        unit_limitations = raw.get("limitations")
        if not isinstance(unit_limitations, list) or any(
            not isinstance(item, str) or not item.strip() for item in unit_limitations
        ):
            issues.append("limitations 必须是字符串数组")
        scope = raw.get("scope")
        if not isinstance(scope, dict):
            issues.append("scope 必须是对象")
        elif unit_type == "code_hunk":
            if scope.get("hunk_id") not in hunks:
                issues.append("scope.hunk_id 无效")
        elif unit_type == "process_segment":
            source_id = scope.get("source_id")
            start, end = scope.get("line_start"), scope.get("line_end")
            source = sources.get(source_id) if isinstance(source_id, str) else None
            if source is None or not source.valid:
                issues.append("process_segment source_id 不可用")
            if (
                isinstance(start, bool)
                or isinstance(end, bool)
                or not isinstance(start, int)
                or not isinstance(end, int)
                or start < 1
                or end < start
            ):
                issues.append("process_segment 行范围无效")
            elif (
                source is not None
                and isinstance(source.line_count, int)
                and end > source.line_count
            ):
                issues.append("process_segment 行范围越出来源")

        refs_raw = original.get("evidence_refs")
        if not isinstance(refs_raw, list):
            issues.append("evidence_refs 必须是数组")
            refs_raw = []
        refs: list[EvidenceRef] = []
        for ref_index, ref_value in enumerate(refs_raw):
            evidence, reason = self._validate_reference(ref_value, sources)
            refs.append(evidence)
            if reason:
                issues.append(
                    "evidence_refs[" + str(ref_index) + "]：" + reason
                )
        unit = ValidatedContributionUnit(
            unit_id=unit_id,
            raw=raw,
            evidence_refs=tuple(refs),
            valid=not issues,
            issues=tuple(issues),
        )
        return unit, issues

    def _parse_conclusion(
        self,
        value: Any,
        sources: Mapping[str, SourceRecord],
    ) -> tuple[Mapping[str, Any] | None, bool, list[str]]:
        if not isinstance(value, dict):
            return None, False, ["lab_conclusion 必须是对象"]
        original = value
        raw = _safe_copy(value)
        issues: list[str] = []
        if not _allowed(raw.get("label"), UNIT_LABELS):
            issues.append("lab_conclusion.label 无效")
        if not _allowed(raw.get("confidence"), CONFIDENCE_VALUES):
            issues.append("lab_conclusion.confidence 无效")
        if raw.get("confidence") == "weak" and raw.get("label") != "indeterminate":
            issues.append("lab_conclusion 弱证据必须使用 indeterminate")
        summary = raw.get("summary")
        if not isinstance(summary, str) or not summary.strip():
            issues.append("lab_conclusion.summary 必须是非空字符串")
        if "alternative_explanation" in raw and (
            not isinstance(raw.get("alternative_explanation"), str)
            or not str(raw.get("alternative_explanation")).strip()
        ):
            issues.append("lab_conclusion.alternative_explanation 必须是非空字符串")
        if "limitations" in raw:
            conclusion_limitations = raw.get("limitations")
            if not isinstance(conclusion_limitations, list) or any(
                not isinstance(item, str) or not item.strip()
                for item in conclusion_limitations
            ):
                issues.append("lab_conclusion.limitations 必须是字符串数组")
        refs_raw = original.get("evidence_refs")
        if not isinstance(refs_raw, list):
            issues.append("lab_conclusion.evidence_refs 必须是数组")
            refs_raw = []
        refs: list[EvidenceRef] = []
        for index, ref_value in enumerate(refs_raw):
            evidence, reason = self._validate_reference(ref_value, sources)
            refs.append(evidence)
            if reason:
                issues.append(
                    "lab_conclusion.evidence_refs[" + str(index) + "]：" + reason
                )
        raw["evidence_refs"] = [item.to_dict() for item in refs]
        return raw, not issues, issues

    def _parse_review(
        self,
        value: Any,
        sources: Mapping[str, SourceRecord],
        unit_ids: set[str],
        *,
        reviewable_unit_ids: set[str] | None = None,
    ) -> tuple[dict[str, Any], bool, list[str]]:
        if not isinstance(value, dict):
            return (
                {
                    "status": "not_run",
                    "overall_decision": None,
                    "unit_reviews": [],
                    "reviewed_unit_ids": [],
                    "disagreement_unit_ids": [],
                },
                False,
                ["review 必须是对象"],
            )
        raw = _safe_copy(value)
        issues: list[str] = []
        status = raw.get("status")
        if not _allowed(status, REVIEW_STATUSES):
            issues.append("review.status 无效")
            status = "not_run"
        overall = raw.get("overall_decision")
        if overall is not None and not _allowed(overall, REVIEW_DECISIONS):
            issues.append("review.overall_decision 必须是 agree、disagree 或 null")
        if status == "not_run" and overall is not None:
            issues.append("review.not_run 时 overall_decision 必须为 null")
        expected = "agree" if status == "agreed" else "disagree"
        if status in {"agreed", "disagreed"} and overall != expected:
            issues.append("review.status 与 overall_decision 不一致")

        reviews = raw.get("unit_reviews")
        if not isinstance(reviews, list):
            issues.append("review.unit_reviews 必须是数组")
            reviews = []
        reviewed_ids: list[str] = []
        disagreement_ids: list[str] = []
        reviewed_seen: set[str] = set()
        clean_reviews: list[dict[str, Any]] = []
        for index, item in enumerate(reviews):
            if not isinstance(item, dict):
                issues.append("review.unit_reviews[" + str(index) + "] 必须是对象")
                continue
            original_item = item
            clean = _safe_copy(item)
            unit_id = clean.get("unit_id")
            decision = clean.get("decision")
            if not isinstance(unit_id, str) or unit_id not in unit_ids:
                issues.append("review.unit_reviews[" + str(index) + "].unit_id 无效")
            elif unit_id in reviewed_seen:
                issues.append("review.unit_reviews[" + str(index) + "].unit_id 重复")
            else:
                reviewed_seen.add(unit_id)
            if not _allowed(decision, REVIEW_DECISIONS):
                issues.append("review.unit_reviews[" + str(index) + "].decision 无效")
            reason = original_item.get("reason")
            if not isinstance(reason, str) or not reason.strip():
                issues.append(
                    "review.unit_reviews[" + str(index) + "].reason 必须是非空字符串"
                )
            refs_raw = original_item.get("evidence_refs")
            if not isinstance(refs_raw, list):
                issues.append(
                    "review.unit_reviews[" + str(index) + "].evidence_refs 必须是数组"
                )
                refs_raw = []
            refs: list[EvidenceRef] = []
            for ref_index, ref_value in enumerate(refs_raw):
                evidence, reason = self._validate_reference(ref_value, sources)
                refs.append(evidence)
                if reason:
                    issues.append(
                        "review.unit_reviews["
                        + str(index)
                        + "].evidence_refs["
                        + str(ref_index)
                        + "]："
                        + reason
                    )
            clean["evidence_refs"] = [item.to_dict() for item in refs]
            if isinstance(unit_id, str):
                reviewed_ids.append(unit_id)
                if decision == "disagree":
                    disagreement_ids.append(unit_id)
            clean_reviews.append(clean)
        provided_reviewed = raw.get("reviewed_unit_ids")
        provided_disagreement = raw.get("disagreement_unit_ids")
        if not isinstance(provided_reviewed, list):
            issues.append("review.reviewed_unit_ids 必须是数组")
            provided_reviewed = []
        if not isinstance(provided_disagreement, list):
            issues.append("review.disagreement_unit_ids 必须是数组")
            provided_disagreement = []
        if any(not isinstance(item, str) for item in provided_reviewed):
            issues.append("review.reviewed_unit_ids 必须是字符串数组")
        if any(not isinstance(item, str) for item in provided_disagreement):
            issues.append("review.disagreement_unit_ids 必须是字符串数组")
        if len(provided_reviewed) != len({item for item in provided_reviewed if isinstance(item, str)}):
            issues.append("review.reviewed_unit_ids 不得重复")
        if len(provided_disagreement) != len({item for item in provided_disagreement if isinstance(item, str)}):
            issues.append("review.disagreement_unit_ids 不得重复")
        reviewed_values = {item for item in provided_reviewed if isinstance(item, str)}
        disagreement_values = {item for item in provided_disagreement if isinstance(item, str)}
        if reviewed_values != set(reviewed_ids):
            issues.append("review.reviewed_unit_ids 必须由 unit_reviews 推导")
        if disagreement_values != set(disagreement_ids):
            issues.append("review.disagreement_unit_ids 必须由 disagree 单元推导")
        if status == "not_run" and clean_reviews:
            issues.append("review.not_run 不得包含 unit_reviews")
        expected_review_ids = unit_ids if reviewable_unit_ids is None else reviewable_unit_ids
        # A malformed contribution unit is deliberately isolated.  Its review
        # record may remain in the upstream artifact, but it must not make the
        # otherwise valid units fail the review-coverage gate.
        reviewed_for_gate = reviewed_values.intersection(expected_review_ids)
        disagreement_for_gate = disagreement_values.intersection(expected_review_ids)
        if status in {"agreed", "disagreed"} and reviewed_for_gate != expected_review_ids:
            issues.append("review.unit_reviews 必须覆盖每个 contribution_unit")
        if status == "agreed" and disagreement_for_gate:
            issues.append("review.status=agreed 不得包含 disagree 单元")
        raw["status"] = status
        raw["overall_decision"] = overall
        raw["unit_reviews"] = clean_reviews
        raw["reviewed_unit_ids"] = list(provided_reviewed)
        raw["disagreement_unit_ids"] = list(provided_disagreement)
        return raw, not issues, issues

    def _validate_reference(
        self,
        value: Any,
        sources: Mapping[str, SourceRecord],
    ) -> tuple[EvidenceRef, str | None]:
        if not isinstance(value, dict):
            reason = "引用必须是对象"
            return EvidenceRef.invalid(kind="v3", reason=reason), reason
        required = (
            "source_id",
            "relative_path",
            "sha256",
            "line_start",
            "line_end",
            "excerpt",
        )
        missing = [key for key in required if key not in value]
        source_id = value.get("source_id") if isinstance(value.get("source_id"), str) else None
        if missing:
            reason = "缺少字段：" + ", ".join(missing)
            return EvidenceRef.invalid(kind="v3", reason=reason, source_id=source_id), reason
        if "start_line" in value or "end_line" in value:
            reason = "必须使用 line_start/line_end，不能使用旧范围字段"
            return EvidenceRef.invalid(kind="v3", reason=reason, source_id=source_id), reason
        source = sources.get(source_id or "")
        if source is None:
            reason = "source_id 不在当前 source_manifest"
            return EvidenceRef.invalid(kind="v3", reason=reason, source_id=source_id), reason
        if not source.valid:
            reason = "引用来源未通过路径、哈希或可用性校验"
            return EvidenceRef.invalid(
                kind="v3",
                reason=reason,
                source_id=source.source_id,
                relative_path=value.get("relative_path"),
                sha256=value.get("sha256"),
                line_start=value.get("line_start"),
                line_end=value.get("line_end"),
                excerpt=value.get("excerpt"),
            ), reason
        if value.get("relative_path") != source.relative_path:
            reason = "relative_path 与 source_manifest 不一致"
            return EvidenceRef.invalid(kind="v3", reason=reason, source_id=source.source_id), reason
        if value.get("sha256") != source.sha256:
            reason = "sha256 与 source_manifest 不一致"
            return EvidenceRef.invalid(kind="v3", reason=reason, source_id=source.source_id), reason
        start, end = value.get("line_start"), value.get("line_end")
        if (
            isinstance(start, bool)
            or isinstance(end, bool)
            or not isinstance(start, int)
            or not isinstance(end, int)
            or start < 1
            or end < start
        ):
            reason = "行范围无效"
            return EvidenceRef.invalid(kind="v3", reason=reason, source_id=source.source_id), reason
        if source.line_count is not None and end > source.line_count:
            reason = "行范围越出 source_manifest.line_count"
            return EvidenceRef.invalid(kind="v3", reason=reason, source_id=source.source_id), reason
        excerpt = value.get("excerpt")
        if not isinstance(excerpt, str) or not excerpt.strip() or len(excerpt) > MAX_EXCERPT_CHARS:
            reason = "excerpt 必须是非空且不超过 600 字符的字符串"
            return EvidenceRef.invalid(kind="v3", reason=reason, source_id=source.source_id), reason
        try:
            lines = _read_lines(source.actual_path) if source.actual_path is not None else []
        except OSError:
            reason = "来源文件无法读取"
            return EvidenceRef.invalid(kind="v3", reason=reason, source_id=source.source_id), reason
        if not _excerpt_matches(excerpt, lines[start - 1:end]):
            reason = "excerpt 不在所声明的行范围内"
            return EvidenceRef.invalid(
                kind="v3",
                reason=reason,
                source_id=source.source_id,
                relative_path=source.relative_path,
                sha256=source.sha256,
                line_start=start,
                line_end=end,
                excerpt=excerpt,
            ), reason
        level = effective_evidence_level(value)
        return EvidenceRef.from_v3(value, evidence_level=level), None


__all__ = [
    "ANALYSIS_STATUSES",
    "CONFIDENCE_VALUES",
    "ContributionAssessmentV3Adapter",
    "DEFAULT_DATA_ROOT",
    "SUPPORTED_LABS",
    "SOURCE_KINDS",
    "SourceRecord",
    "StudentLabSnapshot",
    "UNIT_LABELS",
    "ValidatedContributionUnit",
    "V3ContractError",
    "V3_SCHEMA_VERSION",
    "EvidenceRef",
]
