from __future__ import annotations

import hashlib
import json
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable

from .errors import DataAccessError


ARTIFACT_LAYOUT: dict[str, tuple[str, str]] = {
    "timeline": ("实验过程时间线", "timeline_{lab}.md"),
    "readable_timeline": ("简洁实验过程时间线", "timeline_{lab}.md"),
    "command_statistics": ("终端命令统计", "command_statistics_{lab}.md"),
    "terminal_qa": ("终端对话记录", "terminal_qa_report_{lab}.md"),
    "claude_qa": ("claude对话", "claude_qa_clean_{lab}.md"),
    "full_terminal_transcript": ("完整终端转写记录", "full_terminal_transcript_{lab}.md"),
}

MAX_ARTIFACT_LINES_PER_CALL = 220
MAX_EVENT_PREVIEW = 900


@dataclass(frozen=True)
class StudentReference:
    directory_name: str
    student_id: str | None


def _read_json(path: Path) -> dict[str, Any]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError as error:
        raise DataAccessError(f"缺少数据文件：{path}") from error
    except json.JSONDecodeError as error:
        raise DataAccessError(f"JSON 无法解析：{path}") from error
    if not isinstance(value, dict):
        raise DataAccessError(f"JSON 根节点必须是对象：{path}")
    return value


def _short_text(value: Any, limit: int = MAX_EVENT_PREVIEW) -> str:
    text = str(value or "")
    return text if len(text) <= limit else f"{text[:limit]}..."


def _normalise_text(value: str) -> str:
    return re.sub(r"\s+", " ", value).strip()


class StudentAuditRepository:
    """Read-only access to exactly one student's cleaned, lab-scoped records."""

    def __init__(self, data_root: Path, student_reference: str, lab: str) -> None:
        self.data_root = data_root.resolve()
        self.lab = self._validate_lab(lab)
        self.student_dir = self._resolve_student(student_reference)
        self._timeline: dict[str, Any] | None = None
        self._events_by_id: dict[str, dict[str, Any]] | None = None
        self.reference = StudentReference(
            directory_name=self.student_dir.name,
            student_id=self._find_student_id(),
        )

    @staticmethod
    def _validate_lab(lab: str) -> str:
        if not re.fullmatch(r"lab[0-9]+", lab):
            raise DataAccessError("实验标签必须形如 lab0")
        return lab

    @classmethod
    def list_students(cls, data_root: Path) -> list[StudentReference]:
        root = data_root.resolve()
        if not root.is_dir():
            raise DataAccessError(f"清洗数据目录不存在：{root}")

        result: list[StudentReference] = []
        for directory in sorted(path for path in root.iterdir() if path.is_dir()):
            student_id = cls._read_student_id_from_directory(directory)
            result.append(StudentReference(directory.name, student_id))
        return result

    @staticmethod
    def _read_student_id_from_directory(directory: Path) -> str | None:
        timeline_dir = directory / "实验过程时间线"
        if not timeline_dir.is_dir():
            return None
        for path in sorted(timeline_dir.glob("timeline_*.json")):
            try:
                data = _read_json(path)
            except DataAccessError:
                continue
            student = data.get("student")
            if isinstance(student, dict) and isinstance(student.get("student_id"), str):
                return student["student_id"]
        return None

    def _resolve_student(self, student_reference: str) -> Path:
        if not self.data_root.is_dir():
            raise DataAccessError(f"清洗数据目录不存在：{self.data_root}")
        if not student_reference or "/" in student_reference or "\\" in student_reference:
            raise DataAccessError("学生标识必须是学生目录名或学号，不能包含路径分隔符")

        direct = self.data_root / student_reference
        if direct.is_dir():
            return direct.resolve()

        matches = [
            path
            for path in self.data_root.iterdir()
            if path.is_dir() and self._read_student_id_from_directory(path) == student_reference
        ]
        if len(matches) == 1:
            return matches[0].resolve()
        if not matches:
            raise DataAccessError(f"未找到学生：{student_reference}")
        raise DataAccessError(f"学生标识不唯一：{student_reference}")

    def _find_student_id(self) -> str | None:
        return self._read_student_id_from_directory(self.student_dir)

    @property
    def timeline_path(self) -> Path:
        return self.student_dir / "实验过程时间线" / f"timeline_{self.lab}.json"

    def has_lab_data(self) -> bool:
        return self.timeline_path.is_file()

    def timeline(self) -> dict[str, Any]:
        if self._timeline is None:
            if not self.has_lab_data():
                raise DataAccessError(
                    f"该学生没有 {self.lab} 的结构化时间线；缺失不能解释为未操作或未使用 AI"
                )
            self._timeline = _read_json(self.timeline_path)
        return self._timeline

    def _events(self) -> dict[str, dict[str, Any]]:
        if self._events_by_id is None:
            raw_events = self.timeline().get("events")
            if not isinstance(raw_events, list):
                raise DataAccessError("时间线缺少 events 数组")
            indexed: dict[str, dict[str, Any]] = {}
            for event in raw_events:
                if not isinstance(event, dict):
                    continue
                event_id = event.get("event_id")
                if isinstance(event_id, str) and event.get("lab") == self.lab:
                    indexed[event_id] = event
            self._events_by_id = indexed
        return self._events_by_id

    def _artifact_path(self, category: str) -> Path:
        try:
            directory, template = ARTIFACT_LAYOUT[category]
        except KeyError as error:
            valid = ", ".join(sorted(ARTIFACT_LAYOUT))
            raise DataAccessError(f"未知材料类别：{category}。可用类别：{valid}") from error
        path = (self.student_dir / directory / template.format(lab=self.lab)).resolve()
        try:
            path.relative_to(self.student_dir)
        except ValueError as error:
            raise DataAccessError("材料路径越过了当前学生目录") from error
        return path

    def inventory(self) -> dict[str, Any]:
        artifacts = []
        for category in ARTIFACT_LAYOUT:
            path = self._artifact_path(category)
            artifacts.append(
                {
                    "category": category,
                    "available": path.is_file(),
                    "relative_path": str(path.relative_to(self.student_dir)),
                }
            )
        return {
            "student_id": self.reference.student_id,
            "student_directory": self.reference.directory_name,
            "lab": self.lab,
            "timeline_json_available": self.has_lab_data(),
            "artifacts": artifacts,
            "read_only_scope": "仅当前学生目录和当前 lab 标签",
        }

    def data_quality(self) -> dict[str, Any]:
        if not self.has_lab_data():
            return {
                "lab": self.lab,
                "timeline_available": False,
                "limitation": "没有该 lab 的结构化时间线；不得从缺失推断学生行为。",
            }

        data = self.timeline()
        summary = data.get("summary") if isinstance(data.get("summary"), dict) else {}
        errors = data.get("errors") if isinstance(data.get("errors"), list) else []
        return {
            "lab": self.lab,
            "timeline_available": True,
            "status": data.get("status"),
            "student_recordings": data.get("student_recordings"),
            "summary": summary,
            "errors": errors,
            "time_semantics": "事件时间是可观察显示时间，不能单独推定键入、执行或模型生成的因果关系。",
            "evidence_default": "E2：当前清洗目录不含可验证的原始终端归档文件。",
        }

    def search_events(
        self,
        query: str,
        event_types: Iterable[str] | None = None,
        limit: int = 20,
    ) -> dict[str, Any]:
        if not isinstance(query, str) or not query.strip():
            raise DataAccessError("检索关键词不能为空")
        limit = max(1, min(int(limit), 50))
        desired_types = set(event_types or [])
        needle = query.casefold().strip()

        matches: list[dict[str, Any]] = []
        for event in self._events().values():
            if desired_types and event.get("type") not in desired_types:
                continue
            searchable = self.event_text(event).casefold()
            if needle not in searchable:
                continue
            matches.append(self._event_preview(event))
            if len(matches) >= limit:
                break
        return {"query": query, "matches": matches, "match_count": len(matches)}

    def _event_preview(self, event: dict[str, Any]) -> dict[str, Any]:
        return {
            "event_id": event.get("event_id"),
            "type": event.get("type"),
            "observed_at": event.get("observed_at"),
            "content": _short_text(event.get("content")),
            "output": [_short_text(item, 300) for item in event.get("output", [])[:4]]
            if isinstance(event.get("output"), list)
            else [],
            "uncertainty": event.get("uncertainty", []),
            "observation_semantics": event.get("observation_semantics"),
        }

    def get_event(self, event_id: str) -> dict[str, Any]:
        event = self._events().get(event_id)
        if event is None:
            raise DataAccessError(f"当前学生的 {self.lab} 中不存在事件：{event_id}")
        source = event.get("source") if isinstance(event.get("source"), dict) else {}
        return {
            "event": event,
            "evidence_level": "E2",
            "raw_source_accessible": False,
            "provenance": {
                "out": source.get("out"),
                "tim": source.get("tim"),
                "observation": source.get("observation"),
                "time_source": source.get("time_source"),
                "note": "原始路径仅作为定位信息出现在清洗材料中；当前 Agent 未获原始归档访问权。",
            },
        }

    def event_text(self, event: dict[str, Any]) -> str:
        parts: list[str] = []
        for key in ("content", "first_observed_excerpt"):
            value = event.get(key)
            if isinstance(value, str):
                parts.append(value)
        output = event.get("output")
        if isinstance(output, list):
            parts.extend(str(item) for item in output)
        return "\n".join(parts)

    def quote_matches_event(self, event_id: str, quote: str) -> bool:
        event = self._events().get(event_id)
        if event is None or not isinstance(quote, str) or not quote.strip():
            return False
        return _normalise_text(quote) in _normalise_text(self.event_text(event))

    def read_artifact(self, category: str, start_line: int, end_line: int) -> dict[str, Any]:
        path = self._artifact_path(category)
        if not path.is_file():
            raise DataAccessError(f"当前学生没有 {self.lab} 的 {category} 材料")
        start = max(1, int(start_line))
        end = max(start, min(int(end_line), start + MAX_ARTIFACT_LINES_PER_CALL - 1))
        lines = path.read_text(encoding="utf-8", errors="replace").splitlines()
        selected = [
            {"line": number, "text": line}
            for number, line in enumerate(lines[start - 1 : end], start=start)
        ]
        return {
            "category": category,
            "relative_path": str(path.relative_to(self.student_dir)),
            "line_start": start,
            "line_end": start + len(selected) - 1 if selected else start - 1,
            "total_lines": len(lines),
            "lines": selected,
            "evidence_level": "E2",
        }

    def search_artifacts(
        self,
        query: str,
        category: str | None = None,
        limit: int = 20,
    ) -> dict[str, Any]:
        if not isinstance(query, str) or not query.strip():
            raise DataAccessError("检索关键词不能为空")
        categories = [category] if category else list(ARTIFACT_LAYOUT)
        for item in categories:
            if item not in ARTIFACT_LAYOUT:
                raise DataAccessError(f"未知材料类别：{item}")
        needle = query.casefold().strip()
        remaining = max(1, min(int(limit), 50))
        matches: list[dict[str, Any]] = []
        for item in categories:
            path = self._artifact_path(item)
            if not path.is_file():
                continue
            for line_number, line in enumerate(
                path.read_text(encoding="utf-8", errors="replace").splitlines(), start=1
            ):
                if needle in line.casefold():
                    matches.append(
                        {
                            "category": item,
                            "relative_path": str(path.relative_to(self.student_dir)),
                            "line": line_number,
                            "text": _short_text(line, 500),
                            "evidence_level": "E2",
                        }
                    )
                    remaining -= 1
                    if remaining == 0:
                        return {"query": query, "matches": matches}
        return {"query": query, "matches": matches}

    def baseline_status(self, baseline_manifest: Path | None = None) -> dict[str, Any]:
        if baseline_manifest is None:
            return {
                "configured": False,
                "reason": "当前 Lab0 快照没有 Git 基线，且未提供已发布的哈希清单。",
            }
        path = baseline_manifest.resolve()
        if not path.is_file():
            return {"configured": False, "reason": f"基线清单不存在：{path}"}
        return {
            "configured": True,
            "relative_or_absolute_path": str(path),
            "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
            "note": "本版本只报告基线清单是否已配置；精确文件差异需要后续受控 diff 工具。",
        }

