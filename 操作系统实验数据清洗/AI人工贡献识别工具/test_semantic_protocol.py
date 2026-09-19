from __future__ import annotations

import json
import unittest
from copy import deepcopy
from typing import Any
from unittest.mock import patch

from contribution_recognition.analysis import (
    AssessmentValidationError,
    AssessmentValidator,
    ContributionAnalyzer,
    ReviewValidator,
    TransientProtocolError,
    _apply_review,
    _controlled_exchange,
    _initial_primary_payload,
    _parse_json_object,
    _primary_system_prompt,
    _submission_from_response,
    _validate_read_requests,
)
from contribution_recognition.models import (
    ContributionSnapshot,
    MaterialExcerpt,
    SourceMaterial,
    StudentReference,
)
from contribution_recognition.protocol import NimConfig, NimResponse


def _source(
    source_id: str,
    kind: str,
    path: str | None,
    sha: str | None,
    lines: int | None,
    *,
    required: bool = True,
    availability: str = "available",
) -> SourceMaterial:
    return SourceMaterial(
        source_id=source_id,
        kind=kind,  # type: ignore[arg-type]
        required=required,
        availability=availability,  # type: ignore[arg-type]
        relative_path=path,
        sha256=sha,
        line_count=lines,
        reason=None if availability == "available" else "not applicable",
    )


def _snapshot() -> ContributionSnapshot:
    return ContributionSnapshot(
        schema_version=2,
        student=StudentReference("student-a", "2406080001", "Student A"),
        lab="lab0",
        materials=(
            _source(
                "source:lab0:timeline",
                "timeline",
                "简洁实验过程时间线/timeline_lab0.md",
                "a" * 64,
                4,
            ),
            _source(
                "source:lab0:terminal_qa",
                "terminal_qa",
                "终端对话记录/terminal_qa_report_lab0.md",
                "b" * 64,
                3,
            ),
            _source(
                "source:lab0:command_statistics",
                "command_statistics",
                "终端命令统计/command_statistics_lab0.md",
                "c" * 64,
                3,
            ),
            _source(
                "source:lab0:diff_report",
                "diff_report",
                None,
                None,
                None,
                required=False,
                availability="not_applicable",
            ),
        ),
        diff_hunks=(),
    )


def _excerpt() -> MaterialExcerpt:
    return MaterialExcerpt(
        source_id="source:lab0:timeline",
        kind="timeline",
        relative_path="简洁实验过程时间线/timeline_lab0.md",
        sha256="a" * 64,
        line_start=1,
        line_end=4,
        text="学生询问内核机制。\nAI 给出代码示例。\n学生调试命令。\n学生验证输出。\n",
    )


def _assessment_payload(*, label: str = "human_dominant", confidence: str = "moderate") -> dict[str, Any]:
    reference = {
        "source_id": "source:lab0:timeline",
        "start_line": 1,
        "end_line": 4,
    }
    return {
        "contribution_units": [
            {
                "unit_id": "unit-1",
                "unit_type": "process_segment",
                "scope": {
                    "source_id": "source:lab0:timeline",
                    "start_line": 1,
                    "end_line": 4,
                },
                "label": label,
                "behavior_roles": {
                    "ai": ["ai_explanation", "ai_code_generation"],
                    "human": ["human_prompting", "human_debugging", "human_verification"],
                },
                "confidence": confidence,
                "evidence_refs": [reference],
                "summary": "材料记录了 AI 解释和学生后续调试、验证。",
                "alternative_explanation": "记录不能证明真实作者或输入方式。",
                "limitations": ["只覆盖当前已清洗过程材料。"],
            }
        ],
        "lab_conclusion": {
            "label": label,
            "confidence": confidence,
            "evidence_refs": [reference],
            "summary": "当前过程片段以人工调试和验证为主。",
            "alternative_explanation": "材料不能排除未记录的辅助方式。",
            "limitations": ["当前结论仅覆盖指定片段。"],
        },
        "limitations": ["仅分析当前 Lab 的已清洗材料。"],
        "teacher_actions": ["需要时按行范围复核。"],
    }


def _review_payload(decision: str = "agree") -> dict[str, Any]:
    return {
        "unit_reviews": [
            {
                "unit_id": "unit-1",
                "decision": decision,
                "reason": "读取的过程片段支持该复核决定。",
                "evidence_refs": [
                    {
                        "source_id": "source:lab0:timeline",
                        "start_line": 1,
                        "end_line": 4,
                    }
                ],
            }
        ],
        "overall_decision": decision,
        "summary": "独立复核已完成。",
    }


class _ScriptedClient:
    def __init__(self, payloads: list[dict[str, Any]]) -> None:
        self.payloads = list(payloads)
        self.calls: list[list[dict[str, Any]]] = []

    def complete(self, messages: list[dict[str, Any]]) -> NimResponse:
        self.calls.append([dict(message) for message in messages])
        if not self.payloads:
            raise AssertionError("unexpected NIM completion")
        content = json.dumps(self.payloads.pop(0), ensure_ascii=False)
        return NimResponse(
            content=content,
            model="test-nim",
            usage={"total_tokens": 1},
            request_id=f"request-{len(self.calls)}",
            attempts=1,
            elapsed_seconds=0.0,
        )


def _reader(
    snapshot: ContributionSnapshot,
    source_id: str,
    start_line: int,
    end_line: int,
) -> MaterialExcerpt:
    if snapshot.lab != "lab0" or source_id != "source:lab0:timeline":
        raise AssertionError("reader received a cross-Lab request")
    if (start_line, end_line) != (1, 4):
        raise AssertionError("reader received an unexpected range")
    return MaterialExcerpt(
        source_id=source_id,
        kind="timeline",
        relative_path="简洁实验过程时间线/timeline_lab0.md",
        sha256="a" * 64,
        line_start=start_line,
        line_end=end_line,
        text="api_key=nvapi-12345678\nAI reply\nstudent debug\nstudent verify\n",
    )


class SemanticProtocolTests(unittest.TestCase):
    def test_json_parser_extracts_an_action_object_from_visible_prose(self) -> None:
        payload = _parse_json_object(
            'I will request a bounded fragment. {"action":"read_material",'
            '"requests":[{"source_id":"source:lab0:timeline","start_line":1,"end_line":2}]}'
        )
        self.assertEqual(payload["action"], "read_material")
        self.assertEqual(payload["requests"][0]["end_line"], 2)

    def test_read_requests_clip_to_the_controlled_source_range(self) -> None:
        requests = _validate_read_requests(
            [
                {
                    "source_id": "source:lab0:timeline",
                    "start_line": 1,
                    "end_line": 99,
                }
            ],
            _snapshot(),
            already_requested=0,
            already_lines=0,
        )
        self.assertEqual(requests, [("source:lab0:timeline", 1, 4)])

    def test_read_limit_forces_a_source_free_submission_turn(self) -> None:
        scripted = _ScriptedClient(
            [
                {
                    "action": "read_material",
                    "requests": [
                        {
                            "source_id": "source:lab0:timeline",
                            "start_line": 1,
                            "end_line": 4,
                        }
                    ],
                },
                {"action": "submit_assessment", "assessment": _assessment_payload()},
            ]
        )
        with patch("contribution_recognition.analysis.MAX_READ_ROUNDS", 1):
            exchange = _controlled_exchange(
                client=scripted,
                snapshot=_snapshot(),
                material_reader=_reader,
                system_prompt=_primary_system_prompt(),
                initial_payload=_initial_primary_payload(_snapshot()),
                submit_action="submit_assessment",
                submit_field="assessment",
            )
        self.assertEqual(exchange.payload["lab_conclusion"]["label"], "human_dominant")
        second_call = json.dumps(scripted.calls[1], ensure_ascii=False)
        self.assertIn("read_budget_exhausted", second_call)

    def test_read_limit_repairs_a_wrong_final_action_once(self) -> None:
        scripted = _ScriptedClient(
            [
                {
                    "action": "read_material",
                    "requests": [
                        {
                            "source_id": "source:lab0:timeline",
                            "start_line": 1,
                            "end_line": 4,
                        }
                    ],
                },
                {"action": "submit_review", "review": _review_payload()},
                {"action": "submit_assessment", "assessment": _assessment_payload()},
            ]
        )
        with patch("contribution_recognition.analysis.MAX_READ_ROUNDS", 1):
            exchange = _controlled_exchange(
                client=scripted,
                snapshot=_snapshot(),
                material_reader=_reader,
                system_prompt=_primary_system_prompt(),
                initial_payload=_initial_primary_payload(_snapshot()),
                submit_action="submit_assessment",
                submit_field="assessment",
            )
        self.assertTrue(exchange.repaired_protocol)
        self.assertEqual(len(scripted.calls), 3)
        repair_call = json.dumps(scripted.calls[2], ensure_ascii=False)
        self.assertIn("protocol_repair", repair_call)

    def test_final_submission_repair_remains_available_after_read_repair(self) -> None:
        scripted = _ScriptedClient(
            [
                {"action": "unexpected"},
                {
                    "action": "read_material",
                    "requests": [
                        {
                            "source_id": "source:lab0:timeline",
                            "start_line": 1,
                            "end_line": 4,
                        }
                    ],
                },
                {"action": "submit_review", "review": _review_payload()},
                {"action": "submit_assessment", "assessment": _assessment_payload()},
            ]
        )
        with patch("contribution_recognition.analysis.MAX_READ_ROUNDS", 2):
            exchange = _controlled_exchange(
                client=scripted,
                snapshot=_snapshot(),
                material_reader=_reader,
                system_prompt=_primary_system_prompt(),
                initial_payload=_initial_primary_payload(_snapshot()),
                submit_action="submit_assessment",
                submit_field="assessment",
            )
        self.assertTrue(exchange.repaired_protocol)
        self.assertEqual(len(scripted.calls), 4)
        final_repair_call = json.dumps(scripted.calls[3], ensure_ascii=False)
        self.assertIn("禁止继续读取材料", final_repair_call)

    def test_adjacent_controlled_fragments_support_a_contiguous_citation(self) -> None:
        full = _excerpt()
        lines = full.text.splitlines(keepends=True)
        first = MaterialExcerpt(
            source_id=full.source_id,
            kind=full.kind,
            relative_path=full.relative_path,
            sha256=full.sha256,
            line_start=1,
            line_end=2,
            text="".join(lines[:2]),
        )
        second = MaterialExcerpt(
            source_id=full.source_id,
            kind=full.kind,
            relative_path=full.relative_path,
            sha256=full.sha256,
            line_start=3,
            line_end=4,
            text="".join(lines[2:]),
        )
        assessment = AssessmentValidator(_snapshot(), "sha256:input", [first, second]).validate(
            _assessment_payload(), {}
        )
        excerpt = assessment["contribution_units"][0]["evidence_refs"][0]["excerpt"]
        self.assertIn("学生询问内核机制", excerpt)
        self.assertIn("学生验证输出", excerpt)

    def test_process_scope_can_use_key_evidence_within_a_read_segment(self) -> None:
        payload = _assessment_payload()
        payload["contribution_units"][0]["evidence_refs"] = [
            {
                "source_id": "source:lab0:timeline",
                "start_line": 2,
                "end_line": 3,
            }
        ]
        assessment = AssessmentValidator(_snapshot(), "sha256:input", [_excerpt()]).validate(
            payload, {}
        )
        self.assertEqual(assessment["contribution_units"][0]["scope"]["line_end"], 4)
        self.assertEqual(assessment["contribution_units"][0]["evidence_refs"][0]["line_start"], 2)

    def test_validator_retains_model_human_dominant_and_ai_generation_role(self) -> None:
        validator = AssessmentValidator(_snapshot(), "sha256:input", [_excerpt()])
        assessment = validator.validate(_assessment_payload(), {})
        unit = assessment["contribution_units"][0]
        self.assertEqual(unit["label"], "human_dominant")
        self.assertIn("ai_code_generation", unit["behavior_roles"]["ai"])
        self.assertIn("human_debugging", unit["behavior_roles"]["human"])
        self.assertEqual(unit["evidence_refs"][0]["sha256"], "a" * 64)
        self.assertNotIn("author", json.dumps(assessment, ensure_ascii=False).casefold())

    def test_weak_evidence_cannot_emit_positive_label(self) -> None:
        validator = AssessmentValidator(_snapshot(), "sha256:input", [_excerpt()])
        with self.assertRaisesRegex(AssessmentValidationError, "弱证据"):
            validator.validate(_assessment_payload(confidence="weak"), {})

    def test_reviewer_disagreement_mechanically_downgrades_unit_and_lab(self) -> None:
        validator = AssessmentValidator(_snapshot(), "sha256:input", [_excerpt()])
        assessment = validator.validate(_assessment_payload(label="ai_dominant"), {})
        review = ReviewValidator(_snapshot(), assessment, [_excerpt()]).validate(
            _review_payload("disagree")
        )
        final = _apply_review(assessment, review)
        self.assertEqual(final["contribution_units"][0]["label"], "indeterminate")
        self.assertEqual(final["contribution_units"][0]["confidence"], "weak")
        self.assertEqual(final["lab_conclusion"]["label"], "indeterminate")
        self.assertEqual(final["review"]["status"], "disagreed")
        self.assertEqual(final["review"]["disagreement_unit_ids"], ["unit-1"])

    def test_two_nim_phases_only_receive_source_text_after_controlled_read(self) -> None:
        primary = _assessment_payload()
        scripted = _ScriptedClient(
            [
                {
                    "action": "read_material",
                    "requests": [
                        {
                            "source_id": "source:lab0:timeline",
                            "start_line": 1,
                            "end_line": 4,
                        }
                    ],
                },
                {"action": "submit_assessment", "assessment": primary},
                {
                    "action": "read_material",
                    "requests": [
                        {
                            "source_id": "source:lab0:timeline",
                            "start_line": 1,
                            "end_line": 4,
                        }
                    ],
                },
                {"action": "submit_review", "review": _review_payload()},
            ]
        )
        config = NimConfig(api_key="test-key")
        run = ContributionAnalyzer(scripted, config).analyze(
            _snapshot(),
            "sha256:input",
            material_reader=_reader,
        )
        self.assertEqual(run.assessment["analysis_status"], "complete")
        self.assertEqual(run.assessment["review"]["status"], "agreed")
        self.assertEqual(run.primary_read_count, 1)
        self.assertEqual(run.reviewer_read_count, 1)
        first_call = json.dumps(scripted.calls[0], ensure_ascii=False)
        self.assertNotIn("student debug", first_call)
        all_calls = json.dumps(scripted.calls, ensure_ascii=False)
        self.assertNotIn("nvapi-12345678", all_calls)
        self.assertIn("[REDACTED]", all_calls)

    def test_invalid_unread_citation_does_not_create_a_semantic_fallback(self) -> None:
        payload = _assessment_payload()
        payload["contribution_units"][0]["evidence_refs"][0]["end_line"] = 5
        scripted = _ScriptedClient(
            [
                {
                    "action": "read_material",
                    "requests": [
                        {
                            "source_id": "source:lab0:timeline",
                            "start_line": 1,
                            "end_line": 4,
                        }
                    ],
                },
                {"action": "submit_assessment", "assessment": payload},
                {"action": "submit_assessment", "assessment": payload},
            ]
        )
        with self.assertRaises(AssessmentValidationError):
            ContributionAnalyzer(scripted, NimConfig(api_key="test-key")).analyze(
                _snapshot(),
                "sha256:input",
                material_reader=_reader,
            )


class TransientProtocolClassificationTests(unittest.TestCase):
    """T01: only submission-envelope failures are transient."""

    def test_transient_error_is_an_assessment_validation_error(self) -> None:
        # The existing one-shot local repair catches AssessmentValidationError,
        # so the transient subtype must remain a subclass.
        self.assertTrue(issubclass(TransientProtocolError, AssessmentValidationError))

    def test_unparseable_content_is_transient(self) -> None:
        with self.assertRaises(TransientProtocolError):
            _parse_json_object("this is not JSON at all")

    def test_non_object_root_is_transient(self) -> None:
        with self.assertRaises(TransientProtocolError):
            _parse_json_object("[1, 2, 3]")

    def test_wrong_action_is_transient(self) -> None:
        with self.assertRaises(TransientProtocolError):
            _submission_from_response(
                {"action": "submit_review"},
                "submit_assessment",
                "assessment",
            )
        with self.assertRaises(TransientProtocolError):
            _submission_from_response({}, "submit_assessment", "assessment")

    def test_missing_submission_object_is_transient(self) -> None:
        for raw in (
            {"action": "submit_assessment"},
            {"action": "submit_assessment", "assessment": "not-an-object"},
            {"action": "submit_assessment", "assessment": None},
        ):
            with self.subTest(raw=raw):
                with self.assertRaises(TransientProtocolError):
                    _submission_from_response(raw, "submit_assessment", "assessment")

    def test_citation_out_of_range_is_not_transient(self) -> None:
        payload = _assessment_payload()
        payload["contribution_units"][0]["evidence_refs"][0]["end_line"] = 99
        with self.assertRaises(AssessmentValidationError) as context:
            AssessmentValidator(_snapshot(), "sha256:input", [_excerpt()]).validate(payload, {})
        self.assertNotIsInstance(context.exception, TransientProtocolError)

    def test_semantic_field_error_is_not_transient(self) -> None:
        with self.assertRaises(AssessmentValidationError) as context:
            AssessmentValidator(_snapshot(), "sha256:input", [_excerpt()]).validate(
                _assessment_payload(confidence="weak"), {}
            )
        self.assertNotIsInstance(context.exception, TransientProtocolError)

    def test_controlled_read_error_is_not_transient(self) -> None:
        from contribution_recognition.analysis import ControlledReadError

        self.assertTrue(issubclass(ControlledReadError, AssessmentValidationError))
        self.assertFalse(issubclass(ControlledReadError, TransientProtocolError))


if __name__ == "__main__":
    unittest.main()
