from __future__ import annotations

from pathlib import Path
from typing import Any, Callable

from .errors import DataAccessError, ToolError
from .policy import PolicyDocument
from .repository import ARTIFACT_LAYOUT, StudentAuditRepository
from .v3_adapter import ContributionAssessmentV3Adapter, StudentLabSnapshot


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


def _contribution_reference_schema() -> dict[str, Any]:
    """Schema for one bounded v3 source reference.

    The host reopens and matches every field against the v3 assessment; the
    schema only helps the model produce a repairable tool argument.
    """

    return {
        "type": "object",
        "properties": {
            "source_id": {"type": "string", "minLength": 1, "maxLength": 160},
            "relative_path": {"type": "string", "minLength": 1, "maxLength": 500},
            "sha256": {"type": "string", "pattern": "^[0-9a-fA-F]{64}$"},
            "line_start": {"type": "integer", "minimum": 1},
            "line_end": {"type": "integer", "minimum": 1},
            "excerpt": {"type": "string", "minLength": 1, "maxLength": 600},
        },
        "required": [
            "source_id",
            "relative_path",
            "sha256",
            "line_start",
            "line_end",
            "excerpt",
        ],
        "additionalProperties": False,
    }


def _contribution_evidence_schema() -> dict[str, Any]:
    """Schema for a v3 evidence wrapper or a direct source reference."""

    return {
        "type": "object",
        "properties": {
            "kind": {"type": "string", "enum": ["v3"]},
            "evidence_level": {"type": "string", "enum": ["E1", "E2"]},
            "unit_id": {"type": "string", "minLength": 1, "maxLength": 200},
            "evidence_ref": _contribution_reference_schema(),
            "evidence_refs": {
                "type": "array",
                "items": _contribution_reference_schema(),
                "minItems": 1,
                "maxItems": 8,
            },
            # Direct source references are accepted by the host as E2 only.
            "source_id": {"type": "string", "minLength": 1, "maxLength": 160},
            "relative_path": {"type": "string", "minLength": 1, "maxLength": 500},
            "sha256": {"type": "string", "pattern": "^[0-9a-fA-F]{64}$"},
            "line_start": {"type": "integer", "minimum": 1},
            "line_end": {"type": "integer", "minimum": 1},
            "excerpt": {"type": "string", "minLength": 1, "maxLength": 600},
        },
        "required": [],
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
        contribution_snapshot: StudentLabSnapshot | None = None,
    ) -> None:
        self.repository = repository
        self.policy = policy
        self.baseline_manifest = baseline_manifest
        if contribution_snapshot is None:
            try:
                contribution_snapshot = ContributionAssessmentV3Adapter(
                    repository.data_root
                ).load(repository.reference.directory_name, repository.lab)
            except (DataAccessError, OSError, ValueError):
                contribution_snapshot = None
        self.contribution_snapshot = contribution_snapshot
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
        # Only expose contribution tools when an assessment exists.  This
        # preserves the old event-only contract for legacy/offline fixtures;
        # production v3 tasks receive the complete bounded panel.
        if self.contribution_snapshot is not None and self.contribution_snapshot.assessment_available:
            self._handlers.update(
                {
                    "get_contribution_inventory": self._get_contribution_inventory,
                    "get_contribution_status": self._get_contribution_status,
                    "read_contribution_unit": self._read_contribution_unit,
                    "read_contribution_source_range": self._read_contribution_source_range,
                    "read_contribution_reference": self._read_contribution_reference,
                }
            )

    def definitions(self) -> list[dict[str, Any]]:
        categories = sorted(ARTIFACT_LAYOUT)
        definitions = [
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
                                                            "kind": {
                                                                "type": "string",
                                                                "enum": ["event", "v3"],
                                                                "description": "省略时按旧时间线事件处理；代码贡献证据使用 v3。",
                                                            },
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
                                                            "unit_id": {
                                                                "type": "string",
                                                                "minLength": 1,
                                                                "maxLength": 200,
                                                            },
                                                            "evidence_ref": _contribution_reference_schema(),
                                                            "evidence_refs": {
                                                                "type": "array",
                                                                "items": _contribution_reference_schema(),
                                                                "minItems": 1,
                                                                "maxItems": 8,
                                                            },
                                                            # A finding may cite a bounded source directly when it does not
                                                            # need to attribute the range to a contribution unit.
                                                            "source_id": {
                                                                "type": "string",
                                                                "minLength": 1,
                                                                "maxLength": 160,
                                                            },
                                                            "relative_path": {
                                                                "type": "string",
                                                                "minLength": 1,
                                                                "maxLength": 500,
                                                            },
                                                            "sha256": {
                                                                "type": "string",
                                                                "pattern": "^[0-9a-fA-F]{64}$",
                                                            },
                                                            "line_start": {
                                                                "type": "integer",
                                                                "minimum": 1,
                                                            },
                                                            "line_end": {
                                                                "type": "integer",
                                                                "minimum": 1,
                                                            },
                                                            "excerpt": {
                                                                "type": "string",
                                                                "minLength": 1,
                                                                "maxLength": 600,
                                                            },
                                                        },
                                                        # The host distinguishes the legacy event shape from the v3
                                                        # shape and returns a precise repair message when fields are
                                                        # missing.  Keeping both shapes in one tool avoids a second
                                                        # submission protocol for mixed findings.
                                                        "required": ["evidence_level"],
                                                        "additionalProperties": False,
                                                    },
                                                    "maxItems": 8,
                                                },
                                                # These top-level aliases are accepted by the host validator for
                                                # models that keep contribution citations separate from legacy
                                                # timeline evidence.  Each item may be a unit wrapper or a direct
                                                # source reference; the host reopens and verifies it.
                                                "evidence_refs": {
                                                    "type": "array",
                                                    "items": _contribution_evidence_schema(),
                                                    "minItems": 1,
                                                    "maxItems": 8,
                                                },
                                                "contribution_evidence": {
                                                    "type": "array",
                                                    "items": _contribution_evidence_schema(),
                                                    "minItems": 1,
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
        if self.contribution_snapshot is not None and self.contribution_snapshot.assessment_available:
            definitions.extend(
                [
                    {
                        "type": "function",
                        "function": {
                            "name": "get_contribution_inventory",
                            "description": "返回当前学生/Lab 的 v3 assessment 来源清单、覆盖和兼容状态，不返回完整 JSON。",
                            "parameters": _object_schema({}),
                        },
                    },
                    {
                        "type": "function",
                        "function": {
                            "name": "get_contribution_status",
                            "description": "返回当前 v3 贡献接入状态、复核状态和单元 ID，不返回整份 assessment。",
                            "parameters": _object_schema({}),
                        },
                    },
                    {
                        "type": "function",
                        "function": {
                            "name": "read_contribution_unit",
                            "description": "按 unit_id 读取一个已经通过宿主重验的贡献单元及其有限证据元数据。",
                            "parameters": _object_schema(
                                {"unit_id": {"type": "string", "minLength": 1, "maxLength": 200}},
                                ["unit_id"],
                            ),
                        },
                    },
                    {
                        "type": "function",
                        "function": {
                            "name": "read_contribution_source_range",
                            "description": "按精确 source_id 读取有限的 v3 来源行范围；不得跨学生、Lab 或 source。",
                            "parameters": _object_schema(
                                {
                                    "source_id": {"type": "string", "minLength": 1, "maxLength": 160},
                                    "start_line": {"type": "integer", "minimum": 1},
                                    "end_line": {"type": "integer", "minimum": 1},
                                },
                                ["source_id", "start_line", "end_line"],
                            ),
                        },
                    },
                    {
                        "type": "function",
                        "function": {
                            "name": "read_contribution_reference",
                            "description": "重新读取一个 v3 evidence_ref 的有限来源范围并返回哈希和脱敏行。",
                            "parameters": _object_schema(
                                {
                                    "source_id": {"type": "string", "minLength": 1, "maxLength": 160},
                                    "line_start": {"type": "integer", "minimum": 1},
                                    "line_end": {"type": "integer", "minimum": 1},
                                    "relative_path": {"type": "string", "minLength": 1, "maxLength": 500},
                                    "sha256": {"type": "string", "pattern": "^[0-9a-fA-F]{64}$"},
                                    "excerpt": {"type": "string", "minLength": 1, "maxLength": 600},
                                },
                                ["source_id", "line_start", "line_end"],
                            ),
                        },
                    },
                ]
            )
        return definitions

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

    def _require_contribution(self) -> StudentLabSnapshot:
        if self.contribution_snapshot is None:
            raise DataAccessError("当前任务没有可用的 v3 contribution assessment")
        return self.contribution_snapshot

    def _get_contribution_inventory(self, _: dict[str, Any]) -> dict[str, Any]:
        return self._require_contribution().inventory()

    def _get_contribution_status(self, _: dict[str, Any]) -> dict[str, Any]:
        return self._require_contribution().status()

    def _read_contribution_unit(self, arguments: dict[str, Any]) -> dict[str, Any]:
        return self._require_contribution().read_unit(arguments.get("unit_id", ""))

    def _read_contribution_source_range(self, arguments: dict[str, Any]) -> dict[str, Any]:
        return self._require_contribution().read_source_range(
            arguments.get("source_id", ""),
            arguments.get("start_line", 0),
            arguments.get("end_line", 0),
        )

    def _read_contribution_reference(self, arguments: dict[str, Any]) -> dict[str, Any]:
        snapshot = self._require_contribution()
        reference = {
            "source_id": arguments.get("source_id"),
            "line_start": arguments.get("line_start"),
            "line_end": arguments.get("line_end"),
        }
        for key in ("relative_path", "sha256", "excerpt"):
            if key in arguments:
                reference[key] = arguments[key]
        return snapshot.read_reference(reference)

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
