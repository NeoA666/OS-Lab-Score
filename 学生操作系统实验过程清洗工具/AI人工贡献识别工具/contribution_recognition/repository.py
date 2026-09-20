"""Read-only, Lab-isolated access to contribution-recognition v2 inputs.

This module is deliberately the only layer that opens cleaned source material.
Snapshots carry manifests and diff positions only; callers request bounded,
redacted line ranges when a semantic model needs evidence.
"""

from __future__ import annotations

import hashlib
import re
from collections.abc import Iterable
from dataclasses import dataclass
from pathlib import Path

from .errors import DataAccessError, InvalidReferenceError
from .models import (
    SNAPSHOT_SCHEMA_VERSION,
    ContributionSnapshot,
    DiffHunk,
    MaterialExcerpt,
    SourceKind,
    SourceMaterial,
    StudentReference,
    TaskReference,
)
from .redaction import REDACTED, redact_sensitive_text


SIMPLE_TIMELINE_DIRECTORY = "简洁实验过程时间线"
TERMINAL_QA_DIRECTORY = "终端对话记录"
COMMAND_STATISTICS_DIRECTORY = "终端命令统计"
DIFF_DIRECTORY = "代码差异报告"

# A request is intentionally bounded so an agent cannot turn the controlled
# reader into a full-corpus export. Larger material is read in cited chunks.
MAX_MATERIAL_READ_LINES = 240

_LAB_RE = re.compile(r"^lab[0-8]$")
_FILE_HEADING_RE = re.compile(r"^###\s+`(?P<path>[^`]+)`(?:（(?P<kind>[^）]+)）)?")
_DIFF_FENCE_START_RE = re.compile(r"^```(?:diff|patch)\s*$", re.IGNORECASE)
_HUNK_RE = re.compile(
    r"^@@\s+-(?P<old_start>\d+)(?:,(?P<old_count>\d+))?\s+"
    r"\+(?P<new_start>\d+)(?:,(?P<new_count>\d+))?\s+@@"
)
_RAW_DIFF_PATH_RE = re.compile(r"^diff --git\s+(?P<old>\S+)\s+(?P<new>\S+)$")
_PRIVATE_KEY_BEGIN_RE = re.compile(r"-----BEGIN(?: [A-Z0-9]+)* PRIVATE KEY-----")
_PRIVATE_KEY_END_RE = re.compile(r"-----END(?: [A-Z0-9]+)* PRIVATE KEY-----")


@dataclass(frozen=True)
class _SourceSpec:
    kind: SourceKind
    directory: str
    filename_prefix: str
    filename_suffix: str

    def filename(self, lab: str) -> str:
        return f"{self.filename_prefix}{lab}{self.filename_suffix}"

    @property
    def filename_re(self) -> re.Pattern[str]:
        return re.compile(
            rf"^{re.escape(self.filename_prefix)}(?P<lab>lab[0-8]){re.escape(self.filename_suffix)}$"
        )


_SOURCE_SPECS: tuple[_SourceSpec, ...] = (
    _SourceSpec("timeline", SIMPLE_TIMELINE_DIRECTORY, "timeline_", ".md"),
    _SourceSpec("terminal_qa", TERMINAL_QA_DIRECTORY, "terminal_qa_report_", ".md"),
    _SourceSpec("command_statistics", COMMAND_STATISTICS_DIRECTORY, "command_statistics_", ".md"),
    _SourceSpec("diff_report", DIFF_DIRECTORY, "", ".md"),
)
_SOURCE_BY_KIND = {spec.kind: spec for spec in _SOURCE_SPECS}


def _source_id(lab: str, kind: SourceKind) -> str:
    return f"source:{lab}:{kind}"


def _sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    try:
        with path.open("rb") as stream:
            for chunk in iter(lambda: stream.read(1024 * 1024), b""):
                digest.update(chunk)
    except OSError as error:
        raise DataAccessError(f"无法读取清洗材料：{path}") from error
    return digest.hexdigest()


def _read_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError) as error:
        raise DataAccessError(f"无法读取清洗文本材料：{path}") from error


def _line_count(text: str) -> int:
    return len(text.splitlines())


def _is_link_like(path: Path) -> bool:
    """Reject symlinks and junctions rather than following them out of scope."""

    junction = getattr(path, "is_junction", None)
    try:
        return path.is_symlink() or bool(junction and junction())
    except OSError:
        return True


def _redact_preserving_line_numbers(text: str) -> str:
    """Redact values while retaining the physical line count for citations."""

    result: list[str] = []
    inside_private_key = False
    for raw_line in text.splitlines(keepends=True):
        content = raw_line.rstrip("\r\n")
        newline = raw_line[len(content):]
        if _PRIVATE_KEY_BEGIN_RE.search(content):
            inside_private_key = True
        if inside_private_key:
            result.append(f"{REDACTED}{newline}")
        else:
            result.append(f"{redact_sensitive_text(content)}{newline}")
        if _PRIVATE_KEY_END_RE.search(content):
            inside_private_key = False
    # ``splitlines`` deliberately returns no items for an empty source; that is
    # fine because empty sources are unavailable and cannot be read.
    return "".join(result)


class ContributionRepository:
    """Discover v2 source bundles and serve their bounded material excerpts.

    It only permits the four documented cleaned artifacts under the configured
    root. In particular, it never opens raw logs, recordings, old JSON
    timelines, Claude transcripts, student submissions, or output directories.
    """

    def __init__(self, cleaned_root: str | Path) -> None:
        self.cleaned_root = Path(cleaned_root).expanduser().resolve()
        if not self.cleaned_root.is_dir():
            raise DataAccessError(f"已清洗数据目录不存在：{self.cleaned_root}")

    @staticmethod
    def _validate_lab(lab: str) -> str:
        if not isinstance(lab, str) or not _LAB_RE.fullmatch(lab):
            raise InvalidReferenceError("实验标签必须为 lab0 至 lab8")
        return lab

    @staticmethod
    def _validate_student_selector(reference: str) -> str:
        if not isinstance(reference, str) or not reference.strip():
            raise InvalidReferenceError("学生标识不能为空")
        value = reference.strip()
        if value in {".", ".."} or "/" in value or "\\" in value or "\x00" in value:
            raise InvalidReferenceError("学生标识只能是学生目录名，不能包含路径分隔符")
        return value

    def _safe_child(self, parent: Path, *parts: str) -> Path:
        """Build a non-escaping child and reject links in every path component."""

        lexical = parent.joinpath(*parts)
        try:
            lexical.relative_to(parent)
        except ValueError as error:
            raise DataAccessError("材料路径越过了允许的学生目录") from error
        checked = parent
        for part in parts:
            checked = checked / part
            if _is_link_like(checked):
                raise DataAccessError("允许读取的清洗材料不能是链接")
        candidate = lexical.resolve(strict=False)
        try:
            candidate.relative_to(parent.resolve())
        except ValueError as error:
            raise DataAccessError("材料路径越过了允许的学生目录") from error
        return candidate

    def _student_dirs(self) -> list[Path]:
        result: list[Path] = []
        for candidate in sorted(self.cleaned_root.iterdir(), key=lambda path: path.name):
            if not candidate.is_dir() or _is_link_like(candidate):
                continue
            if any(
                (candidate / spec.directory).is_dir() and not _is_link_like(candidate / spec.directory)
                for spec in _SOURCE_SPECS
            ):
                result.append(candidate.resolve())
        return result

    def _all_students(self) -> list[StudentReference]:
        return [
            StudentReference(directory_name=directory.name, display_name=directory.name)
            for directory in self._student_dirs()
        ]

    def _resolve_student(
        self,
        reference: StudentReference | TaskReference | str,
    ) -> tuple[StudentReference, Path]:
        if isinstance(reference, TaskReference):
            reference = reference.student_reference
        selector = self._validate_student_selector(
            reference.directory_name if isinstance(reference, StudentReference) else reference
        )
        candidate = self._safe_child(self.cleaned_root, selector)
        if not candidate.is_dir() or _is_link_like(candidate):
            raise DataAccessError(f"未找到学生目录：{selector}")
        return StudentReference(candidate.name, display_name=candidate.name), candidate

    @staticmethod
    def _normalise_selectors(values: Iterable[str] | str | None) -> tuple[str, ...] | None:
        if values is None:
            return None
        if isinstance(values, str):
            return (values,)
        return tuple(values)

    def _source_path(self, student_dir: Path, lab: str, spec: _SourceSpec) -> Path:
        directory = self._safe_child(student_dir, spec.directory)
        return self._safe_child(directory, spec.filename(lab))

    @staticmethod
    def _relative_source_path(lab: str, spec: _SourceSpec) -> str:
        return (Path(spec.directory) / spec.filename(lab)).as_posix()

    def _discover_paths(self, student_dir: Path) -> dict[str, dict[SourceKind, Path]]:
        """Return the union of existing source files without reading their text."""

        result: dict[str, dict[SourceKind, Path]] = {}
        for spec in _SOURCE_SPECS:
            try:
                directory = self._safe_child(student_dir, spec.directory)
            except DataAccessError:
                continue
            if not directory.is_dir() or _is_link_like(directory):
                continue
            name_re = spec.filename_re
            for path in sorted(directory.iterdir(), key=lambda item: item.name):
                if _is_link_like(path) or not path.is_file():
                    continue
                matched = name_re.fullmatch(path.name)
                if not matched:
                    continue
                lab = matched.group("lab")
                # Lab0 deliberately has no code-diff input in v2.
                if lab == "lab0" and spec.kind == "diff_report":
                    continue
                result.setdefault(lab, {})[spec.kind] = path
        return result

    def discover_tasks(
        self,
        student_references: Iterable[str] | str | None = None,
        labs: Iterable[str] | str | None = None,
    ) -> list[TaskReference]:
        """Discover tasks from the union of all four v2 material families."""

        requested_students = self._normalise_selectors(student_references)
        requested_labs = self._normalise_selectors(labs)
        allowed_labs = (
            {self._validate_lab(lab) for lab in requested_labs}
            if requested_labs is not None
            else None
        )
        selected = (
            [(item, self._safe_child(self.cleaned_root, item.directory_name)) for item in self._all_students()]
            if requested_students is None
            else [self._resolve_student(item) for item in requested_students]
        )

        tasks: list[TaskReference] = []
        for student, student_dir in selected:
            paths_by_lab = self._discover_paths(student_dir)
            for lab, paths in sorted(paths_by_lab.items()):
                if allowed_labs is not None and lab not in allowed_labs:
                    continue
                def relative(kind: SourceKind) -> str | None:
                    path = paths.get(kind)
                    return path.relative_to(student_dir).as_posix() if path is not None else None

                tasks.append(
                    TaskReference(
                        student_reference=student,
                        lab=lab,
                        timeline_relative_path=relative("timeline"),
                        terminal_qa_relative_path=relative("terminal_qa"),
                        command_statistics_relative_path=relative("command_statistics"),
                        diff_relative_path=relative("diff_report"),
                    )
                )
        return sorted(tasks, key=lambda task: (task.directory_name, task.lab))

    def _material(self, student_dir: Path, lab: str, spec: _SourceSpec) -> SourceMaterial:
        source_id = _source_id(lab, spec.kind)
        required = not (lab == "lab0" and spec.kind == "diff_report")
        if not required:
            return SourceMaterial(
                source_id=source_id,
                kind=spec.kind,
                required=False,
                availability="not_applicable",
                reason="lab0 的贡献识别仅评估实验过程材料，不使用代码差异报告",
            )

        relative_path = self._relative_source_path(lab, spec)
        try:
            path = self._source_path(student_dir, lab, spec)
        except DataAccessError as error:
            return SourceMaterial(
                source_id=source_id,
                kind=spec.kind,
                required=required,
                availability="invalid",
                reason=str(error),
                relative_path=relative_path,
            )
        if _is_link_like(path):
            return SourceMaterial(
                source_id=source_id,
                kind=spec.kind,
                required=required,
                availability="invalid",
                reason="材料文件不能是链接",
                relative_path=relative_path,
            )
        if not path.is_file():
            return SourceMaterial(
                source_id=source_id,
                kind=spec.kind,
                required=required,
                availability="missing",
                reason="未找到该 Lab 的清洗材料；缺失不能解释为未操作或未使用 AI",
                relative_path=relative_path,
            )
        try:
            sha256 = _sha256_file(path)
            text = _read_text(path)
        except DataAccessError as error:
            return SourceMaterial(
                source_id=source_id,
                kind=spec.kind,
                required=required,
                availability="invalid",
                reason=str(error),
                relative_path=relative_path,
            )
        line_count = _line_count(text)
        if not text.strip():
            return SourceMaterial(
                source_id=source_id,
                kind=spec.kind,
                required=required,
                availability="invalid",
                reason="清洗材料为空，无法提供可复核证据",
                relative_path=relative_path,
                sha256=sha256,
                line_count=line_count,
            )
        return SourceMaterial(
            source_id=source_id,
            kind=spec.kind,
            required=required,
            availability="available",
            relative_path=relative_path,
            sha256=sha256,
            line_count=line_count,
        )

    @staticmethod
    def _parse_hunk_header(line: str) -> tuple[int | None, int | None, int | None, int | None]:
        matched = _HUNK_RE.match(line)
        if not matched:
            return None, None, None, None
        old_start = int(matched.group("old_start"))
        old_count = int(matched.group("old_count") or "1")
        new_start = int(matched.group("new_start"))
        new_count = int(matched.group("new_count") or "1")
        return old_start, old_count, new_start, new_count

    def _parse_diff_hunks(
        self,
        *,
        path: Path,
        lab: str,
        source_id: str,
    ) -> tuple[DiffHunk, ...]:
        """Parse only hunk positions and numeric ranges; never return diff text."""

        lines = _read_text(path).splitlines()
        hunks: list[DiffHunk] = []
        current_file_path: str | None = None
        change_kind: str | None = None
        in_diff_fence = False
        index = 0
        while index < len(lines):
            line = lines[index]
            heading = _FILE_HEADING_RE.match(line)
            if heading:
                current_file_path = heading.group("path")
                change_kind = heading.group("kind")
                index += 1
                continue
            raw_diff = _RAW_DIFF_PATH_RE.match(line)
            if raw_diff and current_file_path is None:
                candidate = raw_diff.group("new")
                current_file_path = candidate.removeprefix("b/")
            if _DIFF_FENCE_START_RE.match(line):
                in_diff_fence = True
                index += 1
                continue
            if in_diff_fence and line.startswith("```"):
                in_diff_fence = False
                index += 1
                continue
            if not in_diff_fence or not _HUNK_RE.match(line):
                index += 1
                continue

            start_index = index
            index += 1
            while index < len(lines):
                next_line = lines[index]
                if _HUNK_RE.match(next_line) or next_line.startswith("```"):
                    break
                index += 1
            old_start, old_count, new_start, new_count = self._parse_hunk_header(lines[start_index])
            hunks.append(
                DiffHunk(
                    hunk_id=f"hunk:{lab}:{len(hunks) + 1}",
                    source_id=source_id,
                    file_path=current_file_path,
                    change_kind=change_kind,
                    line_start=start_index + 1,
                    line_end=index,
                    old_line_start=old_start,
                    old_line_count=old_count,
                    new_line_start=new_start,
                    new_line_count=new_count,
                )
            )
        return tuple(hunks)

    def build_snapshot(
        self,
        student_reference: StudentReference | TaskReference | str,
        lab: str,
    ) -> ContributionSnapshot:
        """Build a content-free v2 manifest for exactly one student and Lab."""

        lab = self._validate_lab(lab)
        student, student_dir = self._resolve_student(student_reference)
        materials = tuple(self._material(student_dir, lab, spec) for spec in _SOURCE_SPECS)
        diff_material = next(item for item in materials if item.kind == "diff_report")
        diff_hunks: tuple[DiffHunk, ...] = ()
        if diff_material.available:
            try:
                diff_hunks = self._parse_diff_hunks(
                    path=self._source_path(student_dir, lab, _SOURCE_BY_KIND["diff_report"]),
                    lab=lab,
                    source_id=diff_material.source_id,
                )
            except DataAccessError:
                # The file was checked while building its manifest, but it can be
                # replaced between that read and parsing. The later excerpt read
                # also verifies its hash before exposing any text.
                diff_hunks = ()

        limitations = [
            "快照只包含四类已清洗材料的清单和代码差异范围；正文必须经受控读取接口获取。",
            "材料记录的是可观察过程，不能单独证明代码作者、键入方式、粘贴方式或学习程度。",
            "材料缺失或无效不能解释为学生未操作、未使用 AI 或不存在贡献。",
        ]
        unavailable = [item.source_id for item in materials if item.required and not item.available]
        if unavailable:
            limitations.append(f"必需材料不可用：{', '.join(unavailable)}。应输出资料不足而非贡献归属。")
        if lab != "lab0" and diff_material.available and not diff_hunks:
            limitations.append("代码差异报告未发现可定位的 unified diff hunk；代码范围无法细分。")

        return ContributionSnapshot(
            schema_version=SNAPSHOT_SCHEMA_VERSION,
            student=student,
            lab=lab,
            materials=materials,
            diff_hunks=diff_hunks,
            limitations=tuple(limitations),
        )

    def _validate_snapshot_material(
        self,
        snapshot: ContributionSnapshot,
        source_id: str,
    ) -> tuple[SourceMaterial, Path]:
        if snapshot.schema_version != SNAPSHOT_SCHEMA_VERSION:
            raise InvalidReferenceError("只能读取当前 v2 快照中的材料")
        lab = self._validate_lab(snapshot.lab)
        try:
            material = snapshot.material(source_id)
        except KeyError as error:
            raise InvalidReferenceError("source_id 不属于当前学生/Lab 快照") from error
        expected_source_id = _source_id(lab, material.kind)
        if material.source_id != expected_source_id:
            raise InvalidReferenceError("source_id 与当前 Lab 或材料类型不一致")
        if not material.available:
            raise DataAccessError(f"材料不可读取：{material.source_id}（{material.reason or material.availability}）")
        spec = _SOURCE_BY_KIND[material.kind]
        expected_relative_path = self._relative_source_path(lab, spec)
        if material.relative_path != expected_relative_path:
            raise InvalidReferenceError("快照材料路径不属于当前 Lab 的允许布局")
        _, student_dir = self._resolve_student(snapshot.student)
        path = self._source_path(student_dir, lab, spec)
        if not path.is_file() or _is_link_like(path):
            raise DataAccessError("快照建立后材料已丢失或变为不安全路径")
        if _sha256_file(path) != material.sha256:
            raise DataAccessError("快照建立后材料内容已变化；请重新构建快照")
        return material, path

    @staticmethod
    def _validate_line_range(start_line: int, end_line: int, line_count: int) -> None:
        if isinstance(start_line, bool) or isinstance(end_line, bool):
            raise InvalidReferenceError("材料行范围必须为整数")
        if not isinstance(start_line, int) or not isinstance(end_line, int):
            raise InvalidReferenceError("材料行范围必须为整数")
        if start_line < 1 or end_line < start_line:
            raise InvalidReferenceError("材料行范围无效")
        if end_line > line_count:
            raise InvalidReferenceError("材料行范围超出源文件")
        if end_line - start_line + 1 > MAX_MATERIAL_READ_LINES:
            raise InvalidReferenceError(
                f"单次材料读取最多 {MAX_MATERIAL_READ_LINES} 行；请分段请求"
            )

    def read_snapshot_material(
        self,
        snapshot: ContributionSnapshot,
        source_id: str,
        start_line: int,
        end_line: int,
    ) -> MaterialExcerpt:
        """Return one redacted, hash-verified, bounded source range from a snapshot."""

        material, path = self._validate_snapshot_material(snapshot, source_id)
        if material.line_count is None or material.relative_path is None or material.sha256 is None:
            raise DataAccessError("可用材料缺少读取所需的清单元数据")
        self._validate_line_range(start_line, end_line, material.line_count)
        lines = _read_text(path).splitlines(keepends=True)
        if len(lines) != material.line_count:
            raise DataAccessError("快照建立后材料行数已变化；请重新构建快照")
        excerpt = "".join(lines[start_line - 1:end_line])
        return MaterialExcerpt(
            source_id=material.source_id,
            kind=material.kind,
            relative_path=material.relative_path,
            sha256=material.sha256,
            line_start=start_line,
            line_end=end_line,
            text=_redact_preserving_line_numbers(excerpt),
        )

    def read_material(
        self,
        student_reference: StudentReference | TaskReference | str,
        lab: str,
        source_id: str,
        start_line: int,
        end_line: int,
    ) -> MaterialExcerpt:
        """Build a current manifest and read one bounded source range from it."""

        snapshot = self.build_snapshot(student_reference, lab)
        return self.read_snapshot_material(snapshot, source_id, start_line, end_line)
