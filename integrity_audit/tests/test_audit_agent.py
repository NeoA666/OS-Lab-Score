from __future__ import annotations

import copy
import json
import tempfile
import unittest
from pathlib import Path
from typing import Any

from audit_agent.errors import DataAccessError, ValidationError
from audit_agent.loop import AuditAgentLoop
from audit_agent.models import AssistantResponse, ToolCall
from audit_agent.policy import PolicyDocument
from audit_agent.report import render_report, render_teacher_review_report
from audit_agent.repository import StudentAuditRepository
from audit_agent.tools import AuditTools
from audit_agent.validation import AssessmentValidator


class SequenceModel:
    """A deterministic model substitute used to test the host loop offline."""

    def __init__(self, responses: list[AssistantResponse]) -> None:
        self.responses = responses
        self.requests: list[dict[str, Any]] = []

    def complete(
        self, messages: list[dict[str, Any]], tools: list[dict[str, Any]]
    ) -> AssistantResponse:
        self.requests.append({"messages": copy.deepcopy(messages), "tools": copy.deepcopy(tools)})
        return self.responses.pop(0)


def response(*calls: ToolCall) -> AssistantResponse:
    return AssistantResponse(content=None, tool_calls=calls, raw_message={})


class AuditAgentTestCase(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name)
        self.data_root = self.root / "data"
        self.student_dir = self.data_root / "student-a"
        timeline_dir = self.student_dir / "实验过程时间线"
        timeline_dir.mkdir(parents=True)
        event = {
            "event_id": "evt-lab0-1",
            "lab": "lab0",
            "type": "shell_command_observed",
            "content": "make run",
            "output": ["qemu-system-riscv64: Could not open 'fs.img'"],
            "observed_at": "2026-09-03T17:31:50+08:00",
            "observation_semantics": "可观察显示时间，不是执行时间",
            "uncertainty": [],
            "source": {
                "out": "D:\\raw\\term.out.gz",
                "tim": "D:\\raw\\term.tim.gz",
                "observation": {"timing_line": 9, "decompressed_byte_range": [313, 314]},
            },
        }
        unrelated = {
            "event_id": "evt-lab1-1",
            "lab": "lab1",
            "type": "shell_command_observed",
            "content": "make build",
            "output": [],
        }
        (timeline_dir / "timeline_lab0.json").write_text(
            json.dumps(
                {
                    "schema_version": 1,
                    "student": {"student_id": "1001", "name": "Student A"},
                    "lab": "lab0",
                    "status": "complete",
                    "student_recordings": 1,
                    "summary": {"events": 1, "uncertain_events": 0, "errors": 0},
                    "errors": [],
                    "events": [event, unrelated],
                },
                ensure_ascii=False,
            ),
            encoding="utf-8",
        )
        (timeline_dir / "timeline_lab0.md").write_text("# 时间线\n\nmake run\n", encoding="utf-8")
        self.policy_path = self.root / "policy.md"
        self.policy_path.write_text(
            "\n".join(
                [
                    "# Policy",
                    "",
                    "## 3. AI 边界",
                    "",
                    "### 3.1 允许协助",
                    "",
                    "AI 对话本身不是违规。",
                    "",
                    "### 3.2 复核边界",
                    "",
                    "需要原始证据。",
                    "",
                    "## 4. 证据边界",
                    "",
                    "### 4.1 处理级别",
                    "",
                    "R1 和 R2 需要 E1。",
                ]
            ),
            encoding="utf-8",
        )
        self.repository = StudentAuditRepository(self.data_root, "1001", "lab0")
        self.policy = PolicyDocument(self.policy_path)

    def tearDown(self) -> None:
        self.temporary.cleanup()

    def valid_assessment(self) -> dict[str, Any]:
        return {
            "overall_disposition": "N0",
            "summary": "现有清洗材料只显示一次命令观察，不能推断学生行为。",
            "data_limitations": ["原始终端归档当前不可访问，事件仅为 E2。"],
            "findings": [
                {
                    "id": "N-001",
                    "disposition": "N0",
                    "rule_refs": ["3.1"],
                    "observations": ["记录观察到 make run 命令及其文件缺失输出。"],
                    "evidence": [
                        {
                            "event_id": "evt-lab0-1",
                            "quote": "make run",
                            "evidence_level": "E2",
                        }
                    ],
                    "limitations": ["显示时间不能证明谁键入或何时执行。"],
                    "alternative_explanations": ["学生可能在正常排查 fs.img 缺失问题。"],
                    "teacher_verification": ["如需教学复核，可请学生解释 make fs 与 make run 的关系。"],
                }
            ],
        }

    def test_repository_is_scoped_to_current_lab(self) -> None:
        matches = self.repository.search_events("make")
        self.assertEqual([item["event_id"] for item in matches["matches"]], ["evt-lab0-1"])
        with self.assertRaises(DataAccessError):
            self.repository.get_event("evt-lab1-1")

    def test_policy_parses_subsections(self) -> None:
        section = self.policy.get_section("3.1")
        self.assertIn("允许协助", section["heading"])
        self.assertIn("AI 对话", section["content"])

    def test_r1_requires_e1_evidence(self) -> None:
        assessment = self.valid_assessment()
        assessment["overall_disposition"] = "R1"
        assessment["findings"][0]["disposition"] = "R1"
        with self.assertRaises(ValidationError):
            AssessmentValidator(self.repository, self.policy).validate(assessment)

    def test_loop_validates_and_renders_draft(self) -> None:
        assessment = self.valid_assessment()
        model = SequenceModel(
            [
                response(
                    ToolCall("call-1", "get_data_inventory", {}),
                    ToolCall("call-2", "get_data_quality", {}),
                    ToolCall("call-3", "get_policy_section", {"section": "3.1"}),
                ),
                response(ToolCall("call-4", "get_event", {"event_id": "evt-lab0-1"})),
                response(ToolCall("call-5", "submit_assessment", {"assessment": assessment})),
            ]
        )
        tools = AuditTools(self.repository, self.policy)
        run = AuditAgentLoop(
            model=model,
            repository=self.repository,
            policy=self.policy,
            tools=tools,
            trace_dir=self.root / "traces",
        ).run()
        self.assertEqual(run.assessment["overall_disposition"], "N0")
        self.assertTrue(Path(run.trace_path or "").is_file())
        report = render_report(
            run.assessment,
            self.repository,
            self.policy,
            {"turns": run.turns, "tool_calls": run.tool_calls, "trace_path": run.trace_path},
        )
        self.assertIn("不是违规认定", report)
        self.assertIn("evt-lab0-1", report)

    def test_teacher_review_includes_only_r1_and_r2(self) -> None:
        validated = AssessmentValidator(self.repository, self.policy).validate(self.valid_assessment())
        review_finding = copy.deepcopy(validated["findings"][0])
        review_finding["id"] = "R-001"
        review_finding["disposition"] = "R1"
        review_finding["evidence"][0]["evidence_level"] = "E1"
        assessment = {
            **validated,
            "overall_disposition": "R1",
            "findings": [validated["findings"][0], review_finding],
        }
        report = render_teacher_review_report(
            assessment,
            self.repository,
            self.policy,
            {"turns": 3, "tool_calls": 5, "trace_path": "trace.jsonl"},
        )
        self.assertIn("R-001", report)
        self.assertNotIn("N-001", report)
        self.assertIn("E1 原始证据", report)
        self.assertIn("教师核实点", report)

    def test_loop_requests_revision_for_unread_rule_reference(self) -> None:
        assessment = self.valid_assessment()
        model = SequenceModel(
            [
                response(
                    ToolCall("call-1", "get_data_inventory", {}),
                    ToolCall("call-2", "get_data_quality", {}),
                    ToolCall("call-3", "get_policy_section", {"section": "3.2"}),
                ),
                response(ToolCall("call-4", "get_event", {"event_id": "evt-lab0-1"})),
                response(ToolCall("call-5", "submit_assessment", {"assessment": assessment})),
                response(ToolCall("call-6", "get_policy_section", {"section": "3.1"})),
                response(ToolCall("call-7", "submit_assessment", {"assessment": assessment})),
            ]
        )
        run = AuditAgentLoop(
            model=model,
            repository=self.repository,
            policy=self.policy,
            tools=AuditTools(self.repository, self.policy),
        ).run()
        self.assertEqual(run.assessment["overall_disposition"], "N0")
        self.assertIn("宿主校验拒绝", model.requests[3]["messages"][-1]["content"])

    def test_loop_allows_retry_after_malformed_submission_arguments(self) -> None:
        assessment = self.valid_assessment()
        model = SequenceModel(
            [
                response(
                    ToolCall("call-1", "get_data_inventory", {}),
                    ToolCall("call-2", "get_data_quality", {}),
                    ToolCall("call-3", "get_policy_section", {"section": "3.1"}),
                ),
                response(ToolCall("call-4", "get_event", {"event_id": "evt-lab0-1"})),
                response(
                    ToolCall(
                        "call-5",
                        "submit_assessment",
                        {"__audit_invalid_tool_arguments__": True},
                    )
                ),
                response(ToolCall("call-6", "submit_assessment", {"assessment": assessment})),
            ]
        )
        run = AuditAgentLoop(
            model=model,
            repository=self.repository,
            policy=self.policy,
            tools=AuditTools(self.repository, self.policy),
        ).run()
        self.assertEqual(run.assessment["overall_disposition"], "N0")
        self.assertIn("未被工具接受", model.requests[3]["messages"][-1]["content"])
