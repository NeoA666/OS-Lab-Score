from __future__ import annotations

from pathlib import Path
from typing import Any, Callable

from .errors import DataAccessError, ToolError
from .policy import PolicyDocument
from .repository import ARTIFACT_LAYOUT, StudentAuditRepository


def _object_schema(
    properties: dict[str, Any],
    required: list[str] | None = None,
) -> dict[str, Any]:
    return {
        "type": "object",
        "properties": properties,
        "required": required or [],
        "additionalProperties": False,
    }


class AuditTools:
    """The entire tool surface exposed to the language model.

    Every handler is read-only except submit_assessment, which stores an
    untrusted in-memory payload for host-side validation. Report writing never
    happens through a model-visible tool.
    """

    def __init__(
        self,
        repository: StudentAuditRepository,
        policy: PolicyDocument,
        baseline_manifest: Path | None = None,
    ) -> None:
        self.repository = repository
        self.policy = policy
        self.baseline_manifest = baseline_manifest
        self.submission: dict[str, Any] | None = None
        self._handlers: dict[str, Callable[[dict[str, Any]], dict[str, Any]]] = {
            "get_data_inventory": self._get_data_inventory,
            "get_data_quality": self._get_data_quality,
            "search_events": self._search_events,
            "get_event": self._get_event,
            "read_lab_artifact": self._read_lab_artifact,
            "search_lab_artifacts": self._search_lab_artifacts,
            "get_policy_section": self._get_policy_section,
            "get_baseline_status": self._get_baseline_status,
            "submit_assessment": self._submit_assessment,
        }

    def definitions(self) -> list[dict[str, Any]]:
        categories = sorted(ARTIFACT_LAYOUT)
        return [
            {
                "type": "function",
                "function": {
                    "name": "get_data_inventory",
                    "description": "返回当前学生、当前实验标签可用的清洗材料清单。",
                    "parameters": _object_schema({}),
                },
            },
            {
                "type": "function",
                "function": {
                    "name": "get_data_quality",
                    "description": "返回时间线覆盖、提取错误和时间解释限制。必须在形成判断前调用。",
                    "parameters": _object_schema({}),
                },
            },
            {
                "type": "function",
                "function": {
                    "name": "search_events",
                    "description": "在当前学生、当前 lab 的结构化事件中检索文本。结果只用于定位，需再用 get_event 获取出处。",
                    "parameters": _object_schema(
                        {
                            "query": {"type": "string", "minLength": 1, "maxLength": 300},
                            "event_types": {
                                "type": "array",
                                "items": {"type": "string", "maxLength": 100},
                                "maxItems": 8,
                            },
                            "limit": {"type": "integer", "minimum": 1, "maximum": 50},
                        },
                        ["query"],
                    ),
                },
            },
            {
                "type": "function",
                "function": {
                    "name": "get_event",
                    "description": "返回单一事件、其可引用内容和来源定位。当前清洗目录的事件默认是 E2。",
                    "parameters": _object_schema(
                        {"event_id": {"type": "string", "minLength": 1, "maxLength": 300}},
                        ["event_id"],
                    ),
                },
            },
            {
                "type": "function",
                "function": {
                    "name": "read_lab_artifact",
                    "description": "读取当前 lab 的一种清洗 Markdown 材料的有限行范围。不得用它代替原始证据。",
                    "parameters": _object_schema(
                        {
                            "category": {"type": "string", "enum": categories},
                            "start_line": {"type": "integer", "minimum": 1},
                            "end_line": {"type": "integer", "minimum": 1},
                        },
                        ["category", "start_line", "end_line"],
                    ),
                },
            },
            {
                "type": "function",
                "function": {
                    "name": "search_lab_artifacts",
                    "description": "在当前 lab 的清洗 Markdown 材料中定位关键词。结果为 E2 定位线索。",
                    "parameters": _object_schema(
                        {
                            "query": {"type": "string", "minLength": 1, "maxLength": 300},
                            "category": {"type": "string", "enum": categories},
                            "limit": {"type": "integer", "minimum": 1, "maximum": 50},
                        },
                        ["query"],
                    ),
                },
            },
            {
                "type": "function",
                "function": {
                    "name": "get_policy_section",
                    "description": "读取诚信审核 Agent 规则的单一编号章节和版本哈希。",
                    "parameters": _object_schema(
                        {"section": {"type": "string", "minLength": 1, "maxLength": 20}},
                        ["section"],
                    ),
                },
            },
            {
                "type": "function",
                "function": {
                    "name": "get_baseline_status",
                    "description": "检查是否配置了已发布 Lab0 基线哈希清单。",
                    "parameters": _object_schema({}),
                },
            },
            {
                "type": "function",
                "function": {
                    "name": "submit_assessment",
                    "description": "提交结构化审核草稿供宿主校验。必须在完成证据检索后调用；提交不等于写入报告。",
                    "parameters": _object_schema(
                        {
                            "assessment": {
                                "type": "object",
                                "properties": {
                                    "overall_disposition": {
                                        "type": "string",
                                        "enum": ["N0", "N1", "R1", "R2"],
                                    },
                                    "summary": {"type": "string", "minLength": 1, "maxLength": 2000},
                                    "data_limitations": {
                                        "type": "array",
                                        "items": {"type": "string", "maxLength": 1000},
                                        "maxItems": 20,
                                    },
                                    "findings": {
                                        "type": "array",
                                        "maxItems": 12,
                                        "items": {
                                            "type": "object",
                                            "properties": {
                                                "id": {"type": "string", "minLength": 1, "maxLength": 50},
                                                "disposition": {
                                                    "type": "string",
                                                    "enum": ["N0", "N1", "R1", "R2"],
                                                },
                                                "rule_refs": {
                                                    "type": "array",
                                                    "items": {"type": "string", "maxLength": 50},
                                                    "maxItems": 6,
                                                },
                                                "observations": {
                                                    "type": "array",
                                                    "items": {"type": "string", "maxLength": 1500},
                                                    "maxItems": 8,
                                                },
                                                "evidence": {
                                                    "type": "array",
                                                    "items": {
                                                        "type": "object",
                                                        "properties": {
                                                            "event_id": {
                                                                "type": "string",
                                                                "minLength": 1,
                                                                "maxLength": 300,
                                                            },
                                                            "quote": {
                                                                "type": "string",
                                                                "minLength": 1,
                                                                "maxLength": 1500,
                                                            },
                                                            "evidence_level": {
                                                                "type": "string",
                                                                "enum": ["E1", "E2"],
                                                            },
                                                        },
                                                        "required": [
                                                            "event_id",
                                                            "quote",
                                                            "evidence_level",
                                                        ],
                                                        "additionalProperties": False,
                                                    },
                                                    "maxItems": 8,
                                                },
                                                "limitations": {
                                                    "type": "array",
                                                    "items": {"type": "string", "maxLength": 1000},
                                                    "maxItems": 8,
                                                },
                                                "alternative_explanations": {
                                                    "type": "array",
                                                    "items": {"type": "string", "maxLength": 1000},
                                                    "maxItems": 8,
                                                },
                                                "teacher_verification": {
                                                    "type": "array",
                                                    "items": {"type": "string", "maxLength": 1000},
                                                    "maxItems": 8,
                                                },
                                            },
                                            "required": [
                                                "id",
                                                "disposition",
                                                "rule_refs",
                                                "observations",
                                                "evidence",
                                                "limitations",
                                                "alternative_explanations",
                                                "teacher_verification",
                                            ],
                                            "additionalProperties": False,
                                        },
                                    },
                                },
                                "required": [
                                    "overall_disposition",
                                    "summary",
                                    "data_limitations",
                                    "findings",
                                ],
                                "additionalProperties": False,
                            }
                        },
                        ["assessment"],
                    ),
                },
            },
        ]

    def execute(self, name: str, arguments: dict[str, Any]) -> dict[str, Any]:
        handler = self._handlers.get(name)
        if handler is None:
            return {"ok": False, "error": f"未公开的工具：{name}"}
        if not isinstance(arguments, dict):
            return {"ok": False, "error": "工具参数必须是 JSON 对象"}
        if arguments.get("__audit_invalid_tool_arguments__") is True:
            return {
                "ok": False,
                "error": "模型返回的工具参数不是合法 JSON 对象；请使用工具定义中的 JSON Schema 重新调用该工具。",
            }
        try:
            return {"ok": True, "result": handler(arguments)}
        except (DataAccessError, ToolError, TypeError, ValueError) as error:
            return {"ok": False, "error": str(error)}

    def _get_data_inventory(self, _: dict[str, Any]) -> dict[str, Any]:
        return self.repository.inventory()

    def _get_data_quality(self, _: dict[str, Any]) -> dict[str, Any]:
        return self.repository.data_quality()

    def _search_events(self, arguments: dict[str, Any]) -> dict[str, Any]:
        event_types = arguments.get("event_types")
        if event_types is not None and not isinstance(event_types, list):
            raise ToolError("event_types 必须是数组")
        return self.repository.search_events(
            query=arguments.get("query", ""),
            event_types=event_types,
            limit=arguments.get("limit", 20),
        )

    def _get_event(self, arguments: dict[str, Any]) -> dict[str, Any]:
        return self.repository.get_event(arguments.get("event_id", ""))

    def _read_lab_artifact(self, arguments: dict[str, Any]) -> dict[str, Any]:
        return self.repository.read_artifact(
            category=arguments.get("category", ""),
            start_line=arguments.get("start_line", 0),
            end_line=arguments.get("end_line", 0),
        )

    def _search_lab_artifacts(self, arguments: dict[str, Any]) -> dict[str, Any]:
        category = arguments.get("category")
        if category is not None and not isinstance(category, str):
            raise ToolError("category 必须是字符串")
        return self.repository.search_artifacts(
            query=arguments.get("query", ""),
            category=category,
            limit=arguments.get("limit", 20),
        )

    def _get_policy_section(self, arguments: dict[str, Any]) -> dict[str, Any]:
        return self.policy.get_section(arguments.get("section", ""))

    def _get_baseline_status(self, _: dict[str, Any]) -> dict[str, Any]:
        return self.repository.baseline_status(self.baseline_manifest)

    def _submit_assessment(self, arguments: dict[str, Any]) -> dict[str, Any]:
        if self.submission is not None:
            raise ToolError("本次运行已经提交过 assessment")
        assessment = arguments.get("assessment")
        if not isinstance(assessment, dict):
            raise ToolError("assessment 必须是对象")
        self.submission = assessment
        return {
            "accepted_for_host_validation": True,
            "note": "该提交尚未生成报告；宿主将校验证据、规则、实验范围和处理级别。",
        }

    def discard_submission(self) -> None:
        """Allow a revision only after the host rejects an untrusted draft."""

        self.submission = None
