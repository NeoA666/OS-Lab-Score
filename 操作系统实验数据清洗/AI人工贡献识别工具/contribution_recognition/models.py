"""Serializable, content-free input contracts for contribution recognition v2.

The repository owns source text. A snapshot intentionally contains only a
manifest and mechanically parsed scope metadata so callers cannot accidentally
send every cleaned record to a model. Text crosses this boundary only through
``ContributionRepository.read_material``.
"""

from __future__ import annotations

import hashlib
import json
from dataclasses import asdict, dataclass, field, is_dataclass
from typing import Any, Literal


SNAPSHOT_SCHEMA_VERSION = 2

CoverageState = Literal["available", "missing", "not_applicable", "invalid"]
SourceKind = Literal["timeline", "terminal_qa", "command_statistics", "diff_report"]


def _primitive(value: Any) -> Any:
    """Convert frozen dataclasses and tuples into JSON-safe primitives."""

    if is_dataclass(value):
        return _primitive(asdict(value))
    if isinstance(value, dict):
        return {str(key): _primitive(item) for key, item in value.items()}
    if isinstance(value, (list, tuple)):
        return [_primitive(item) for item in value]
    return value


def stable_sha256(value: Any) -> str:
    """Return a deterministic digest of JSON-safe data without absolute paths."""

    encoded = json.dumps(
        _primitive(value),
        ensure_ascii=False,
        sort_keys=True,
        separators=(",", ":"),
    ).encode("utf-8")
    return hashlib.sha256(encoded).hexdigest()


@dataclass(frozen=True)
class StudentReference:
    """A stable logical identity for one cleaned student directory."""

    directory_name: str
    student_id: str | None = None
    display_name: str | None = None

    def to_dict(self) -> dict[str, Any]:
        return _primitive(self)


@dataclass(frozen=True)
class TaskReference:
    """One discoverable student/Lab task from the union of v2 source files."""

    student_reference: StudentReference
    lab: str
    timeline_relative_path: str | None = None
    terminal_qa_relative_path: str | None = None
    command_statistics_relative_path: str | None = None
    diff_relative_path: str | None = None

    @property
    def directory_name(self) -> str:
        return self.student_reference.directory_name

    @property
    def student_id(self) -> str | None:
        return self.student_reference.student_id

    def to_dict(self) -> dict[str, Any]:
        return _primitive(self)


@dataclass(frozen=True)
class SourceMaterial:
    """One allowed cleaned source, represented without its body text."""

    source_id: str
    kind: SourceKind
    required: bool
    availability: CoverageState
    reason: str | None = None
    relative_path: str | None = None
    sha256: str | None = None
    line_count: int | None = None

    def __post_init__(self) -> None:
        if self.availability == "available":
            if not self.relative_path or not self.sha256 or self.line_count is None:
                raise ValueError("可用材料必须包含路径、哈希和行数")
            if self.line_count < 0:
                raise ValueError("材料行数不能为负数")
        elif self.availability == "not_applicable" and self.required:
            raise ValueError("必需材料不能标记为不适用")

    @property
    def available(self) -> bool:
        return self.availability == "available"

    @property
    def state(self) -> CoverageState:
        """Compatibility-friendly spelling for callers that present coverage."""

        return self.availability

    def to_dict(self) -> dict[str, Any]:
        return _primitive(self)


@dataclass(frozen=True)
class DiffHunk:
    """Mechanically parsed diff scope metadata; it deliberately excludes code text."""

    hunk_id: str
    source_id: str
    file_path: str | None
    change_kind: str | None
    line_start: int
    line_end: int
    old_line_start: int | None = None
    old_line_count: int | None = None
    new_line_start: int | None = None
    new_line_count: int | None = None

    def __post_init__(self) -> None:
        if self.line_start < 1 or self.line_end < self.line_start:
            raise ValueError("diff hunk 行范围无效")

    def to_dict(self) -> dict[str, Any]:
        return _primitive(self)


@dataclass(frozen=True)
class MaterialExcerpt:
    """A bounded, redacted source range returned by the repository read API."""

    source_id: str
    kind: SourceKind
    relative_path: str
    sha256: str
    line_start: int
    line_end: int
    text: str

    def __post_init__(self) -> None:
        if self.line_start < 1 or self.line_end < self.line_start:
            raise ValueError("材料摘录行范围无效")

    def to_dict(self) -> dict[str, Any]:
        """Serialize only after the caller explicitly requested this excerpt."""

        return _primitive(self)


@dataclass(frozen=True)
class ContributionSnapshot:
    """A Lab-scoped manifest for semantic attribution, with no source bodies."""

    schema_version: int
    student: StudentReference
    lab: str
    materials: tuple[SourceMaterial, ...]
    diff_hunks: tuple[DiffHunk, ...]
    limitations: tuple[str, ...] = ()
    _material_ids: frozenset[str] = field(init=False, repr=False, compare=False)

    def __post_init__(self) -> None:
        if self.schema_version != SNAPSHOT_SCHEMA_VERSION:
            raise ValueError("ContributionSnapshot 必须使用当前 v2 schema")
        material_ids = [item.source_id for item in self.materials]
        if len(material_ids) != len(set(material_ids)):
            raise ValueError("source_id 必须在单个快照内唯一")
        materials_by_id = {item.source_id: item for item in self.materials}
        valid_ids = frozenset(materials_by_id)
        if any(item.source_id not in materials_by_id for item in self.diff_hunks):
            raise ValueError("diff hunk 必须引用同一快照中的材料")
        if any(materials_by_id[item.source_id].kind != "diff_report" for item in self.diff_hunks):
            raise ValueError("diff hunk 只能引用代码差异报告材料")
        object.__setattr__(self, "_material_ids", valid_ids)

    @property
    def source_manifest(self) -> tuple[SourceMaterial, ...]:
        return self.materials

    @property
    def analysis_ready(self) -> bool:
        return all(material.available for material in self.materials if material.required)

    @property
    def missing_required_sources(self) -> tuple[SourceMaterial, ...]:
        return tuple(material for material in self.materials if material.required and not material.available)

    def material(self, source_id: str) -> SourceMaterial:
        for item in self.materials:
            if item.source_id == source_id:
                return item
        raise KeyError(source_id)

    def assessment_fingerprint_payload(self) -> dict[str, Any]:
        """Stable analysis identity; it has no source body text or absolute path."""

        return {
            "snapshot_schema_version": self.schema_version,
            "student": self.student.to_dict(),
            "lab": self.lab,
            "source_manifest": [item.to_dict() for item in self.materials],
            "diff_hunks": [item.to_dict() for item in self.diff_hunks],
        }

    @property
    def assessment_fingerprint(self) -> str:
        return stable_sha256(self.assessment_fingerprint_payload())

    def to_dict(self) -> dict[str, Any]:
        """Return a model-safe manifest. Use the repository to read source text."""

        return {
            "schema_version": self.schema_version,
            "student": self.student.to_dict(),
            "lab": self.lab,
            "source_manifest": [item.to_dict() for item in self.materials],
            "diff_hunks": [item.to_dict() for item in self.diff_hunks],
            "analysis_ready": self.analysis_ready,
            "missing_required_source_ids": [item.source_id for item in self.missing_required_sources],
            "limitations": list(self.limitations),
            "assessment_fingerprint": self.assessment_fingerprint,
            "assessment_fingerprint_payload": self.assessment_fingerprint_payload(),
        }
