"""Atomic storage for AI/human contribution-recognition v3 artifacts."""

from __future__ import annotations

import csv
import hashlib
import json
import os
import re
import tempfile
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterable, Mapping

from . import TOOL_VERSION
from .redaction import redact_sensitive_text, redact_sensitive_value
from output_layout import AI_TOOL, PERSON_VIEW, tool_paths, paired_paths, pair_matches, write_bytes_pair, unlink_pair


V3_SCHEMA_VERSION = "ai-human-contribution-assessment/v3"
MANIFEST_SCHEMA_VERSION = "ai-human-contribution-manifest/v3"
MANIFEST_NAME = ".contribution_manifest.json"
SUMMARY_DIRECTORY = "汇总报告"
LOG_DIRECTORY = "运行日志"
REPORT_TEMPLATE_VERSION = "6"

_ANALYSIS_STATUSES = frozenset({"complete", "insufficient_data", "failed"})
_UNIT_TYPES = frozenset({"code_hunk", "process_segment"})
_UNIT_LABELS = frozenset({"ai_dominant", "human_dominant", "mixed", "indeterminate"})
_CONFIDENCE = frozenset({"strong", "moderate", "weak"})
_REVIEW_STATUSES = frozenset({"agreed", "disagreed", "not_run"})
_REVIEW_DECISIONS = frozenset({"agree", "disagree"})
_SOURCE_KINDS = frozenset({"timeline", "terminal_qa", "command_statistics", "diff_report"})
_MAX_EVIDENCE_EXCERPT_CHARACTERS = 600
_OUTPUT_TEXT_LIMITS = {
    "excerpt": 600,
    "summary": 800,
    "alternative_explanation": 800,
    "statement": 800,
    "reason": 800,
    "message": 800,
}
_DISALLOWED_OUTPUT_KEYS = frozenset(
    {
        "reasoning_content",
        "reasoning",
        "chain_of_thought",
        "thoughts",
        "raw_response",
        "raw_model_response",
        "raw_nim_response",
        "model_response",
        "response_content",
        "request_payload",
        "response_payload",
        "request_messages",
        "messages",
        "system_prompt",
        "prompt",
    }
)


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()


def stable_sha256(value: Any) -> str:
    encoded = json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode("utf-8")
    return hashlib.sha256(encoded).hexdigest()


def file_sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def _write_temporary_text(path: Path, text: str) -> Path:
    path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(
        mode="w",
        encoding="utf-8",
        newline="\n",
        dir=path.parent,
        prefix=".contribution-",
        suffix=".tmp",
        delete=False,
    ) as stream:
        temporary = Path(stream.name)
        stream.write(text)
    return temporary


def atomic_write_bundle(values: Mapping[Path, str]) -> None:
    """Commit a group of files via same-directory replaces.

    A filesystem cannot atomically replace three independent paths as one
    transaction.  The per-student manifest is written only after this bundle
    completes, so an interrupted bundle has no valid cache commit marker.
    """

    temporary_files: list[tuple[Path, Path]] = []
    try:
        for path, text in values.items():
            for target in paired_paths(path):
                # Use the shared target checks, including junction protection.
                from output_layout import _validate_target
                _validate_target(target)
                temporary_files.append((_write_temporary_text(target, text), target))
        for temporary, path in temporary_files:
            os.replace(temporary, path)
    finally:
        for temporary, _ in temporary_files:
            if temporary.exists():
                temporary.unlink()


def atomic_write_text(path: Path, text: str) -> None:
    atomic_write_bundle({path: text})


def atomic_write_json(path: Path, value: Any) -> None:
    atomic_write_text(path, json.dumps(value, ensure_ascii=False, indent=2, sort_keys=True) + "\n")


def _strip_disallowed_output_fields(value: Any) -> Any:
    """Drop model-private payload fields before artifacts leave process memory."""

    if isinstance(value, dict):
        result: dict[Any, Any] = {}
        for key, item in value.items():
            if str(key).casefold() in _DISALLOWED_OUTPUT_KEYS:
                continue
            cleaned = _strip_disallowed_output_fields(item)
            limit = _OUTPUT_TEXT_LIMITS.get(str(key))
            if limit is not None and isinstance(cleaned, str) and len(cleaned) > limit:
                cleaned = cleaned[: max(0, limit - 1)].rstrip() + "…"
            result[key] = cleaned
        return result
    if isinstance(value, list):
        return [_strip_disallowed_output_fields(item) for item in value]
    if isinstance(value, tuple):
        return tuple(_strip_disallowed_output_fields(item) for item in value)
    return value


def sanitize_assessment_for_output(assessment: dict[str, Any]) -> dict[str, Any]:
    """Return a deep-safe copy suitable for JSON, Markdown, and manifests."""

    sanitized = _strip_disallowed_output_fields(assessment)
    redacted = redact_sensitive_value(sanitized)
    if not isinstance(redacted, dict):  # Defensive type narrowing for callers.
        raise ValueError("assessment 文件根节点必须是对象")
    return redacted


def _require_object(parent: dict[str, Any], key: str) -> dict[str, Any]:
    value = parent.get(key)
    if not isinstance(value, dict):
        raise ValueError(f"v3 assessment 缺少对象字段 {key}")
    return value


def _require_list(parent: dict[str, Any], key: str) -> list[Any]:
    value = parent.get(key)
    if not isinstance(value, list):
        raise ValueError(f"v3 assessment 缺少数组字段 {key}")
    return value


def _validate_evidence_refs(value: list[Any], context: str) -> None:
    for index, ref in enumerate(value):
        if not isinstance(ref, dict):
            raise ValueError(f"{context}[{index}] 必须是对象")
        required = ("source_id", "relative_path", "sha256", "line_start", "line_end", "excerpt")
        missing = [key for key in required if key not in ref]
        if missing:
            raise ValueError(f"{context}[{index}] 缺少字段 {', '.join(missing)}")
        start, end = ref.get("line_start"), ref.get("line_end")
        if not isinstance(start, int) or not isinstance(end, int) or start < 1 or end < start:
            raise ValueError(f"{context}[{index}] 行范围无效")
        excerpt = ref.get("excerpt")
        if not isinstance(excerpt, str) or len(excerpt) > _MAX_EVIDENCE_EXCERPT_CHARACTERS:
            raise ValueError(f"{context}[{index}] 摘录必须是至多 {_MAX_EVIDENCE_EXCERPT_CHARACTERS} 字符的字符串")


def validate_v3_assessment(assessment: dict[str, Any]) -> None:
    """Validate the stable output shape without making semantic judgments."""

    if assessment.get("schema_version") != V3_SCHEMA_VERSION:
        raise ValueError(
            f"仅可写入 {V3_SCHEMA_VERSION}；收到 {assessment.get('schema_version')!r}"
        )
    status = assessment.get("analysis_status")
    if status not in _ANALYSIS_STATUSES:
        raise ValueError("analysis_status 无效")
    student = _require_object(assessment, "student")
    if not isinstance(student.get("directory_name"), str) or not student["directory_name"].strip():
        raise ValueError("student.directory_name 必须是非空字符串")
    lab = assessment.get("lab")
    if not isinstance(lab, str) or not re.fullmatch(r"lab[0-8]", lab):
        raise ValueError("lab 必须是非空字符串")

    source_manifest = _require_list(assessment, "source_manifest")
    coverage = _require_object(assessment, "coverage")
    if not isinstance(coverage.get("status"), str):
        raise ValueError("coverage.status 必须是字符串")
    diff_hunks = _require_list(assessment, "diff_hunks")
    for index, material in enumerate(source_manifest):
        if not isinstance(material, dict):
            raise ValueError(f"source_manifest[{index}] 必须是对象")
        missing = [
            key
            for key in ("source_id", "kind", "required", "availability", "relative_path", "sha256", "line_count")
            if key not in material
        ]
        if missing:
            raise ValueError(f"source_manifest[{index}] 缺少字段 {', '.join(missing)}")
        kind = material.get("kind")
        if kind not in _SOURCE_KINDS:
            raise ValueError(f"source_manifest[{index}].kind 无效")
        expected_source_id = f"source:{lab}:{kind}"
        if material.get("source_id") != expected_source_id:
            raise ValueError(
                f"source_manifest[{index}].source_id 必须精确为 {expected_source_id}"
            )
        availability = material.get("availability")
        if availability not in {"available", "missing", "invalid", "not_applicable"}:
            raise ValueError(f"source_manifest[{index}].availability 无效")
        if not isinstance(material.get("required"), bool):
            raise ValueError(f"source_manifest[{index}].required 必须是布尔值")
        if availability == "available":
            if not isinstance(material.get("relative_path"), str) or not material["relative_path"]:
                raise ValueError(f"source_manifest[{index}] 可用材料必须有 relative_path")
            if not isinstance(material.get("sha256"), str) or not re.fullmatch(r"[0-9a-fA-F]{64}", material["sha256"]):
                raise ValueError(f"source_manifest[{index}] 可用材料 sha256 无效")
            if not isinstance(material.get("line_count"), int) or material["line_count"] < 0:
                raise ValueError(f"source_manifest[{index}] 可用材料 line_count 无效")
        elif material.get("required") and availability == "not_applicable":
            raise ValueError(f"source_manifest[{index}] 必需材料不能标记为 not_applicable")
    source_by_id = {
        str(material["source_id"]): material
        for material in source_manifest
        if isinstance(material, dict) and isinstance(material.get("source_id"), str) and material["source_id"]
    }
    if len(source_by_id) != len(source_manifest):
        raise ValueError("source_manifest.source_id 必须非空且在单个 assessment 内唯一")
    if len(source_manifest) != 4:
        raise ValueError("source_manifest 必须包含 timeline、terminal_qa、command_statistics、diff_report 四项")
    source_by_kind = {item.get("kind"): item for item in source_manifest}
    if set(source_by_kind) != set(_SOURCE_KINDS):
        raise ValueError("source_manifest 缺少规定材料类型")
    if lab == "lab0":
        diff = source_by_kind["diff_report"]
        if diff.get("availability") != "not_applicable" or diff.get("required") is not False:
            raise ValueError("lab0 的 diff_report 必须是非必需的 not_applicable")
    else:
        for kind, item in source_by_kind.items():
            if item.get("required") is not True:
                raise ValueError(f"{lab} 的 {kind} 必须是必需材料")
    for index, hunk in enumerate(diff_hunks):
        if not isinstance(hunk, dict):
            raise ValueError(f"diff_hunks[{index}] 必须是对象")
        missing = [
            key for key in ("hunk_id", "file_path", "source_id", "line_start", "line_end") if key not in hunk
        ]
        if missing:
            raise ValueError(f"diff_hunks[{index}] 缺少字段 {', '.join(missing)}")
        if hunk.get("source_id") not in source_by_id:
            raise ValueError(f"diff_hunks[{index}].source_id 不在 source_manifest 中")
    hunk_by_id = {
        str(hunk["hunk_id"]): hunk
        for hunk in diff_hunks
        if isinstance(hunk, dict) and isinstance(hunk.get("hunk_id"), str) and hunk["hunk_id"]
    }
    if len(hunk_by_id) != len(diff_hunks):
        raise ValueError("diff_hunks.hunk_id 必须非空且在单个 assessment 内唯一")

    units = _require_list(assessment, "contribution_units")
    for index, unit in enumerate(units):
        if not isinstance(unit, dict):
            raise ValueError(f"contribution_units[{index}] 必须是对象")
        required = (
            "unit_id", "unit_type", "label", "behavior_roles", "confidence", "scope",
            "evidence_refs", "summary", "alternative_explanation", "limitations",
        )
        missing = [key for key in required if key not in unit]
        if missing:
            raise ValueError(f"contribution_units[{index}] 缺少字段 {', '.join(missing)}")
        if unit.get("unit_type") not in _UNIT_TYPES:
            raise ValueError(f"contribution_units[{index}].unit_type 无效")
        if unit.get("label") not in _UNIT_LABELS:
            raise ValueError(f"contribution_units[{index}].label 无效")
        if unit.get("confidence") not in _CONFIDENCE:
            raise ValueError(f"contribution_units[{index}].confidence 无效")
        if unit.get("confidence") == "weak" and unit.get("label") != "indeterminate":
            raise ValueError(f"contribution_units[{index}] 弱证据必须使用 indeterminate")
        behavior_roles = unit.get("behavior_roles")
        if not isinstance(behavior_roles, dict):
            raise ValueError(f"contribution_units[{index}].behavior_roles 必须是对象")
        for role_owner in ("ai", "human"):
            roles = behavior_roles.get(role_owner)
            if not isinstance(roles, list) or not all(isinstance(role, str) and role for role in roles):
                raise ValueError(f"contribution_units[{index}].behavior_roles.{role_owner} 必须是字符串数组")
        if not isinstance(unit.get("scope"), dict):
            raise ValueError(f"contribution_units[{index}].scope 必须是对象")
        scope = unit["scope"]
        if unit.get("unit_type") == "code_hunk":
            hunk_id = scope.get("hunk_id")
            if not isinstance(hunk_id, str) or hunk_id not in hunk_by_id:
                raise ValueError(f"contribution_units[{index}].scope.hunk_id 无效")
        else:
            source_id = scope.get("source_id")
            start, end = scope.get("line_start"), scope.get("line_end")
            if source_id not in source_by_id or not isinstance(start, int) or not isinstance(end, int) or start < 1 or end < start:
                raise ValueError(f"contribution_units[{index}] 过程范围无效")
            line_count = source_by_id[source_id].get("line_count")
            if isinstance(line_count, int) and end > line_count:
                raise ValueError(f"contribution_units[{index}] 过程范围越出源文件")
        if not isinstance(unit.get("limitations"), list):
            raise ValueError(f"contribution_units[{index}].limitations 必须是数组")
        refs = unit.get("evidence_refs")
        if not isinstance(refs, list):
            raise ValueError(f"contribution_units[{index}].evidence_refs 必须是数组")
        _validate_evidence_refs(refs, f"contribution_units[{index}].evidence_refs")
        for ref in refs:
            source = source_by_id.get(str(ref["source_id"]))
            if source is None:
                raise ValueError(f"contribution_units[{index}] 证据引用了未知 source_id")
            if source.get("availability") != "available":
                raise ValueError(f"contribution_units[{index}] 不能引用不可用 source_id")
            if ref["relative_path"] != source.get("relative_path") or ref["sha256"] != source.get("sha256"):
                raise ValueError(f"contribution_units[{index}] 证据路径或哈希与 source_manifest 不一致")
            if ref["line_end"] > source.get("line_count", 0):
                raise ValueError(f"contribution_units[{index}] 证据行范围越出源文件")

    conclusion = _require_object(assessment, "lab_conclusion")
    required_conclusion = ("label", "confidence", "summary", "evidence_refs")
    missing_conclusion = [key for key in required_conclusion if key not in conclusion]
    if missing_conclusion:
        raise ValueError(f"lab_conclusion 缺少字段 {', '.join(missing_conclusion)}")
    if conclusion.get("label") not in _UNIT_LABELS:
        raise ValueError("lab_conclusion.label 无效")
    if conclusion.get("confidence") not in _CONFIDENCE:
        raise ValueError("lab_conclusion.confidence 无效")
    if not isinstance(conclusion.get("evidence_refs"), list):
        raise ValueError("lab_conclusion.evidence_refs 必须是数组")
    _validate_evidence_refs(conclusion["evidence_refs"], "lab_conclusion.evidence_refs")
    for ref in conclusion["evidence_refs"]:
        source = source_by_id.get(str(ref["source_id"]))
        if source is None or source.get("availability") != "available" or ref["relative_path"] != source.get("relative_path") or ref["sha256"] != source.get("sha256"):
            raise ValueError("lab_conclusion 证据路径、哈希或 source_id 无效")
        if ref["line_end"] > source.get("line_count", 0):
            raise ValueError("lab_conclusion 证据行范围越出源文件")

    review = _require_object(assessment, "review")
    if review.get("status") not in _REVIEW_STATUSES:
        raise ValueError("review.status 无效")
    for key in ("unit_reviews", "reviewed_unit_ids", "disagreement_unit_ids"):
        if not isinstance(review.get(key), list):
            raise ValueError(f"review.{key} 必须是数组")
    overall_decision = review.get("overall_decision")
    if review.get("status") == "not_run":
        if overall_decision is not None:
            raise ValueError("review.status=not_run 时 overall_decision 必须为 null")
    elif overall_decision not in _REVIEW_DECISIONS:
        raise ValueError("review.overall_decision 必须为 agree 或 disagree")
    units_by_id = {
        str(unit.get("unit_id")): unit
        for unit in units
        if isinstance(unit, dict) and isinstance(unit.get("unit_id"), str) and unit["unit_id"]
    }
    if len(units_by_id) != len(units):
        raise ValueError("contribution_units.unit_id 必须非空且在单个 assessment 内唯一")
    for unit_id in [*review["reviewed_unit_ids"], *review["disagreement_unit_ids"]]:
        if unit_id not in units_by_id:
            raise ValueError("review 引用了不存在的 contribution_unit")
    reviewed_from_records: list[str] = []
    for index, unit_review in enumerate(review["unit_reviews"]):
        if not isinstance(unit_review, dict):
            raise ValueError(f"review.unit_reviews[{index}] 必须是对象")
        required = ("unit_id", "decision", "reason", "evidence_refs")
        missing = [key for key in required if key not in unit_review]
        if missing:
            raise ValueError(f"review.unit_reviews[{index}] 缺少字段 {', '.join(missing)}")
        unit_id = unit_review.get("unit_id")
        if not isinstance(unit_id, str) or unit_id not in units_by_id:
            raise ValueError(f"review.unit_reviews[{index}].unit_id 无效")
        if unit_review.get("decision") not in _REVIEW_DECISIONS:
            raise ValueError(f"review.unit_reviews[{index}].decision 必须为 agree 或 disagree")
        if not isinstance(unit_review.get("reason"), str):
            raise ValueError(f"review.unit_reviews[{index}].reason 必须是字符串")
        refs = unit_review.get("evidence_refs")
        if not isinstance(refs, list):
            raise ValueError(f"review.unit_reviews[{index}].evidence_refs 必须是数组")
        _validate_evidence_refs(refs, f"review.unit_reviews[{index}].evidence_refs")
        for ref in refs:
            source = source_by_id.get(str(ref["source_id"]))
            if source is None or source.get("availability") != "available" or ref["relative_path"] != source.get("relative_path") or ref["sha256"] != source.get("sha256"):
                raise ValueError(f"review.unit_reviews[{index}] 证据路径、哈希或 source_id 无效")
            if ref["line_end"] > source.get("line_count", 0):
                raise ValueError(f"review.unit_reviews[{index}] 证据行范围越出源文件")
        reviewed_from_records.append(unit_id)
    if set(reviewed_from_records) != set(review["reviewed_unit_ids"]):
        raise ValueError("review.reviewed_unit_ids 必须由 unit_reviews 推导")
    if review.get("status") == "disagreed":
        if overall_decision != "disagree":
            raise ValueError("review.status=disagreed 时 overall_decision 必须为 disagree")
        for unit_id in review["disagreement_unit_ids"]:
            if units_by_id[unit_id].get("label") != "indeterminate":
                raise ValueError("独立复核分歧单元必须降级为 indeterminate")
    elif review.get("status") == "agreed" and overall_decision != "agree":
        raise ValueError("review.status=agreed 时 overall_decision 必须为 agree")
    if not isinstance(assessment.get("limitations"), list):
        raise ValueError("limitations 必须是数组")
    _require_object(assessment, "run_metadata")
    if status in {"insufficient_data", "failed"}:
        if units or conclusion.get("label") != "indeterminate":
            raise ValueError(f"{status} 必须使用空 contribution_units 和 indeterminate Lab 结论")


def _new_manifest() -> dict[str, Any]:
    return {
        "schema_version": MANIFEST_SCHEMA_VERSION,
        "tool": "ai-human-contribution-recognition",
        "tool_version": TOOL_VERSION,
        "report_template_version": REPORT_TEMPLATE_VERSION,
        "labs": {},
    }


class ContributionStorage:
    """Owns only contribution-recognition outputs under a cleaned data root."""

    def __init__(self, cleaned_root: Path) -> None:
        self.cleaned_root = cleaned_root.resolve()

    def student_directory(self, student_directory: str) -> Path:
        tool_paths(self.cleaned_root, student_directory, "lab0", AI_TOOL)
        candidate = (self.cleaned_root / PERSON_VIEW / student_directory).resolve()
        try:
            candidate.relative_to(self.cleaned_root)
        except ValueError as error:
            raise ValueError("学生目录越过了已清洗根目录") from error
        return candidate

    def assessment_path(self, student_directory: str, lab: str) -> Path:
        return tool_paths(self.cleaned_root, student_directory, lab, AI_TOOL)[0] / f"assessment_{lab}.json"

    def full_report_path(self, student_directory: str, lab: str) -> Path:
        return tool_paths(self.cleaned_root, student_directory, lab, AI_TOOL)[0] / f"完整贡献识别报告_{lab}.md"

    def teacher_report_path(self, student_directory: str, lab: str) -> Path:
        return tool_paths(self.cleaned_root, student_directory, lab, AI_TOOL)[0] / f"教师贡献复核报告_{lab}.md"

    def report_path(self, student_directory: str, lab: str) -> Path:
        """Compatibility alias for the teacher-facing report path."""

        return self.teacher_report_path(student_directory, lab)

    def manifest_path(self, student_directory: str) -> Path:
        self.student_directory(student_directory)
        return self.cleaned_root / LOG_DIRECTORY / AI_TOOL / student_directory / MANIFEST_NAME

    def load_manifest(self, student_directory: str) -> dict[str, Any]:
        path = self.manifest_path(student_directory)
        if not path.is_file():
            return _new_manifest()
        try:
            value = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError):
            return _new_manifest()
        if not isinstance(value, dict) or not isinstance(value.get("labs"), dict):
            return _new_manifest()
        if value.get("schema_version") != MANIFEST_SCHEMA_VERSION:
            # A v1/v2 manifest must not cause stale artifacts to be cache hits.
            return _new_manifest()
        return value

    def cache_entry(self, student_directory: str, lab: str) -> dict[str, Any] | None:
        entry = self.load_manifest(student_directory).get("labs", {}).get(lab)
        if isinstance(entry, dict):
            # A valid canonical artifact can repair a missing/stale mirror locally.
            for path, key in ((self.assessment_path(student_directory, lab), "assessment_sha256"),
                              (self.full_report_path(student_directory, lab), "full_report_sha256"),
                              (self.teacher_report_path(student_directory, lab), "teacher_report_sha256")):
                if not pair_matches(path):
                    for candidate in paired_paths(path):
                        if candidate.is_file() and entry.get(key) == file_sha256(candidate):
                            write_bytes_pair(path, candidate.read_bytes())
                            break
            return entry
        return None

    def cache_hit(self, student_directory: str, lab: str, assessment_fingerprint: str) -> bool:
        entry = self.cache_entry(student_directory, lab)
        assessment_path = self.assessment_path(student_directory, lab)
        if not entry or not assessment_path.is_file():
            return False
        if entry.get("assessment_schema_version") != V3_SCHEMA_VERSION:
            return False
        if entry.get("analysis_status") not in {"complete", "insufficient_data"}:
            return False
        if entry.get("assessment_fingerprint") != assessment_fingerprint:
            return False
        try:
            return entry.get("assessment_sha256") == file_sha256(assessment_path)
        except OSError:
            return False

    def reports_are_current(self, student_directory: str, lab: str, render_fingerprint: str) -> bool:
        entry = self.cache_entry(student_directory, lab)
        paths = (self.full_report_path(student_directory, lab), self.teacher_report_path(student_directory, lab))
        if not entry or entry.get("render_fingerprint") != render_fingerprint or not all(path.is_file() for path in paths):
            return False
        try:
            return (
                entry.get("full_report_sha256") == file_sha256(paths[0])
                and entry.get("teacher_report_sha256") == file_sha256(paths[1])
            )
        except OSError:
            return False

    def report_is_current(self, student_directory: str, lab: str, render_fingerprint: str) -> bool:
        """Compatibility name; v3 requires both Markdown renderings to match."""

        return self.reports_are_current(student_directory, lab, render_fingerprint)

    def _write_manifest_entry(
        self,
        student_directory: str,
        lab: str,
        assessment: dict[str, Any],
        assessment_fingerprint: str,
        render_fingerprint: str,
    ) -> None:
        assessment_path = self.assessment_path(student_directory, lab)
        full_path = self.full_report_path(student_directory, lab)
        teacher_path = self.teacher_report_path(student_directory, lab)
        manifest = self.load_manifest(student_directory)
        labs = manifest.setdefault("labs", {})
        labs[lab] = {
            "analysis_status": assessment.get("analysis_status"),
            "assessment_schema_version": assessment.get("schema_version"),
            "assessment_fingerprint": assessment_fingerprint,
            "render_fingerprint": render_fingerprint,
            "assessment_sha256": file_sha256(assessment_path),
            "full_report_sha256": file_sha256(full_path),
            "teacher_report_sha256": file_sha256(teacher_path),
            "updated_at": utc_now(),
        }
        manifest.update(
            {
                "schema_version": MANIFEST_SCHEMA_VERSION,
                "tool": "ai-human-contribution-recognition",
                "tool_version": TOOL_VERSION,
                "report_template_version": REPORT_TEMPLATE_VERSION,
                "updated_at": utc_now(),
            }
        )
        atomic_write_json(self.manifest_path(student_directory), redact_sensitive_value(manifest))

    def write_assessment_and_reports(
        self,
        student_directory: str,
        lab: str,
        assessment: dict[str, Any],
        full_report: str,
        teacher_report: str,
        assessment_fingerprint: str,
        render_fingerprint: str,
    ) -> tuple[Path, Path, Path]:
        """Commit a checked v3 assessment and both report renderings."""

        safe_assessment = sanitize_assessment_for_output(assessment)
        validate_v3_assessment(safe_assessment)
        assessment_path = self.assessment_path(student_directory, lab)
        full_path = self.full_report_path(student_directory, lab)
        teacher_path = self.teacher_report_path(student_directory, lab)
        atomic_write_bundle(
            {
                assessment_path: json.dumps(safe_assessment, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
                full_path: redact_sensitive_text(full_report),
                teacher_path: redact_sensitive_text(teacher_report),
            }
        )
        self._write_manifest_entry(
            student_directory, lab, safe_assessment, assessment_fingerprint, render_fingerprint
        )
        unlink_pair(assessment_path.parent / "历史结果说明.md")
        return assessment_path, full_path, teacher_path

    def write_reports_only(
        self,
        student_directory: str,
        lab: str,
        assessment: dict[str, Any],
        full_report: str,
        teacher_report: str,
        render_fingerprint: str,
    ) -> tuple[Path, Path]:
        """Re-render both reports without changing a validated assessment."""

        safe_assessment = sanitize_assessment_for_output(assessment)
        validate_v3_assessment(safe_assessment)
        entry = self.cache_entry(student_directory, lab)
        assessment_path = self.assessment_path(student_directory, lab)
        if not entry or entry.get("assessment_sha256") != file_sha256(assessment_path):
            raise ValueError("不能为不存在或已损坏的 assessment 仅重渲染报告")
        full_path = self.full_report_path(student_directory, lab)
        teacher_path = self.teacher_report_path(student_directory, lab)
        atomic_write_bundle(
            {full_path: redact_sensitive_text(full_report), teacher_path: redact_sensitive_text(teacher_report)}
        )
        self._write_manifest_entry(
            student_directory,
            lab,
            safe_assessment,
            str(entry.get("assessment_fingerprint") or ""),
            render_fingerprint,
        )
        return full_path, teacher_path

    # These names keep the previous CLI call sites source-compatible, but reject
    # v1/v2 assessments rather than silently translating their semantics.
    def write_assessment_and_report(
        self,
        student_directory: str,
        lab: str,
        assessment: dict[str, Any],
        report: str,
        assessment_fingerprint: str,
        render_fingerprint: str,
    ) -> tuple[Path, Path]:
        from .report import render_full_report

        assessment_path, _, teacher_path = self.write_assessment_and_reports(
            student_directory,
            lab,
            assessment,
            render_full_report(assessment),
            report,
            assessment_fingerprint,
            render_fingerprint,
        )
        return assessment_path, teacher_path

    def write_report_only(
        self,
        student_directory: str,
        lab: str,
        report: str,
        render_fingerprint: str,
    ) -> Path:
        """Re-render v3 reports and return the teacher-facing report path."""

        path = self.assessment_path(student_directory, lab)
        try:
            assessment = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as error:
            raise ValueError("无法读取 assessment 以重渲染完整报告") from error
        if not isinstance(assessment, dict):
            raise ValueError("assessment 文件根节点不是对象")
        from .report import render_full_report

        self.write_reports_only(
            student_directory,
            lab,
            assessment,
            render_full_report(assessment),
            report,
            render_fingerprint,
        )
        return self.teacher_report_path(student_directory, lab)

    def write_run_log(self, student_directory: str, lab: str, records: Iterable[dict[str, Any]]) -> Path:
        stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S.%fZ")
        path = self.cleaned_root / LOG_DIRECTORY / AI_TOOL / student_directory / lab / "runs" / f"{stamp}.jsonl"
        lines = [
            json.dumps(redact_sensitive_value(_strip_disallowed_output_fields(record)), ensure_ascii=False, sort_keys=True)
            for record in records
        ]
        atomic_write_text(path, "\n".join(lines) + ("\n" if lines else ""))
        return path

    def write_batch_summary(self, batch_id: str, summary: dict[str, Any]) -> Path:
        path = self.cleaned_root / LOG_DIRECTORY / AI_TOOL / "batches" / batch_id / "summary.json"
        atomic_write_json(path, redact_sensitive_value(_strip_disallowed_output_fields(summary)))
        return path

    @staticmethod
    def _csv_value(value: Any) -> str:
        text = redact_sensitive_text(str(value or ""))
        # Spreadsheet formula prefixes must not become active when a teacher opens CSV.
        return "'" + text if text[:1] in {"=", "+", "-", "@"} else text

    def write_overview(self, rows: list[dict[str, Any]]) -> tuple[Path, Path]:
        directory = self.cleaned_root / SUMMARY_DIRECTORY
        markdown_path = directory / "AI人工贡献识别_总览.md"
        csv_path = directory / "AI人工贡献识别_总览.csv"
        headers = ["学生目录", "Lab", "分析状态", "执行状态", "总体贡献画像", "置信度", "复核状态", "资料覆盖", "说明"]
        markdown = ["# AI/人工贡献识别总览", "", "| " + " | ".join(headers) + " |", "| --- | --- | --- | --- | --- | --- | --- | --- | --- |"]
        csv_rows = [headers]
        for row in rows:
            conclusion = row.get("lab_conclusion")
            conclusion_dict = conclusion if isinstance(conclusion, dict) else {}
            review = row.get("review")
            review_dict = review if isinstance(review, dict) else {}
            coverage = row.get("coverage")
            if isinstance(coverage, dict):
                coverage_value = coverage.get("status", "")
            else:
                coverage_value = coverage
            values = [
                self._csv_value(row.get("student_directory", "")),
                self._csv_value(row.get("lab", "")),
                self._csv_value(row.get("analysis_status", row.get("status", ""))),
                self._csv_value(row.get("execution_status", row.get("status", ""))),
                self._csv_value(conclusion_dict.get("label", conclusion if not conclusion_dict else "")),
                self._csv_value(conclusion_dict.get("confidence", row.get("confidence", ""))),
                self._csv_value(review_dict.get("status", row.get("review_status", ""))),
                self._csv_value(coverage_value),
                self._csv_value(row.get("message", "")),
            ]
            markdown.append("| " + " | ".join(value.replace("|", "\\|").replace("\n", "<br>") for value in values) + " |")
            csv_rows.append(values)
        csv_text_lines: list[str] = []
        # Use a temporary CSV file for stdlib-compliant escaping, then bundle both outputs.
        directory.mkdir(parents=True, exist_ok=True)
        with tempfile.NamedTemporaryFile(mode="w+", encoding="utf-8", newline="", delete=True) as stream:
            writer = csv.writer(stream)
            writer.writerows(csv_rows)
            stream.seek(0)
            csv_text_lines.append(stream.read())
        atomic_write_bundle(
            {
                markdown_path: "\n".join(markdown) + "\n",
                csv_path: "".join(csv_text_lines),
            }
        )
        return markdown_path, csv_path
