from __future__ import annotations

import hashlib
import json
import tempfile
import unittest
from pathlib import Path

from audit_agent.policy import PolicyDocument
from audit_agent.report import render_report
from audit_agent.repository import StudentAuditRepository
from audit_agent.v3_adapter import ContributionAssessmentV3Adapter
from audit_agent.validation import AssessmentValidator
from audit_agent.loop import AuditAgentLoop
from audit_agent.models import AssistantResponse, ToolCall
from audit_agent.tools import AuditTools
from audit_agent.integrity_assessment import derive_overall_label, make_integrity_assessment


class V3EvidenceValidationTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.data = self.root / "data"
        self.student = self.data / "student-a"
        timeline_dir = self.student / "实验过程时间线"
        timeline_dir.mkdir(parents=True)
        (timeline_dir / "timeline_lab1.json").write_text(
            json.dumps(
                {
                    "schema_version": 1,
                    "student": {"student_id": "1001", "name": "A"},
                    "lab": "lab1",
                    "status": "complete",
                    "summary": {"events": 0, "errors": 0},
                    "errors": [],
                    "events": [],
                },
                ensure_ascii=False,
            ),
            encoding="utf-8",
        )
        source_text = {
            "timeline": "学生阅读提示\n学生运行测试\n",
            "terminal_qa": "问答记录\n",
            "command_statistics": "make test\n",
            "diff_report": "@@ kernel/foo.c @@\n+return 0;\n",
        }
        source_paths = {
            "timeline": "简洁实验过程时间线/timeline_lab1.md",
            "terminal_qa": "终端对话记录/terminal_qa_report_lab1.md",
            "command_statistics": "终端命令统计/command_statistics_lab1.md",
            "diff_report": "代码差异报告/lab1.md",
        }
        self.sources: list[dict[str, object]] = []
        for kind, relative in source_paths.items():
            path = self.student / relative
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(source_text[kind], encoding="utf-8")
            self.sources.append(
                {
                    "source_id": f"source:lab1:{kind}",
                    "kind": kind,
                    "required": True,
                    "availability": "available",
                    "relative_path": relative,
                    "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
                    "line_count": len(source_text[kind].splitlines()),
                    "reason": None,
                }
            )
        self.policy_path = self.root / "lab1-policy.md"
        self.policy_path.write_text("# Rules\n\n## 1 边界\n\n仅用于测试。\n", encoding="utf-8")
        self.policy = PolicyDocument(self.policy_path)
        assessment_dir = self.student / "AI人工贡献识别" / "assessment"
        assessment_dir.mkdir(parents=True)
        self.assessment_path = assessment_dir / "assessment_lab1.json"

    def tearDown(self) -> None:
        self.temp.cleanup()

    def _reference(self) -> dict[str, object]:
        source = next(item for item in self.sources if item["kind"] == "timeline")
        return {
            "source_id": source["source_id"],
            "relative_path": source["relative_path"],
            "sha256": source["sha256"],
            "line_start": 1,
            "line_end": 1,
            "excerpt": "学生阅读提示",
        }

    def _write_v3(self) -> None:
        ref = self._reference()
        value = {
            "schema_version": "ai-human-contribution-assessment/v3",
            "analysis_status": "complete",
            "student": {"directory_name": "student-a", "student_id": "1001", "display_name": "A"},
            "lab": "lab1",
            "coverage": {"status": "complete", "missing_or_limited": []},
            "source_manifest": self.sources,
            "diff_hunks": [
                {
                    "hunk_id": "hunk:lab1:1",
                    "file_path": "kernel/foo.c",
                    "source_id": "source:lab1:diff_report",
                    "line_start": 1,
                    "line_end": 2,
                }
            ],
            "contribution_units": [
                {
                    "unit_id": "unit-code",
                    "unit_type": "code_hunk",
                    "label": "mixed",
                    "behavior_roles": {"ai": ["ai_guidance"], "human": ["human_verification"]},
                    "confidence": "moderate",
                    "scope": {"hunk_id": "hunk:lab1:1"},
                    "evidence_refs": [ref],
                    "summary": "测试贡献单元",
                    "alternative_explanation": "材料有限",
                    "limitations": [],
                }
            ],
            "lab_conclusion": {
                "label": "mixed",
                "confidence": "moderate",
                "summary": "测试结论",
                "alternative_explanation": "材料有限",
                "limitations": [],
                "evidence_refs": [ref],
            },
            "review": {
                "status": "agreed",
                "overall_decision": "agree",
                "unit_reviews": [
                    {"unit_id": "unit-code", "decision": "agree", "reason": "范围一致", "evidence_refs": []}
                ],
                "reviewed_unit_ids": ["unit-code"],
                "disagreement_unit_ids": [],
            },
            "limitations": [],
            "run_metadata": {},
        }
        self.assessment_path.write_text(json.dumps(value, ensure_ascii=False), encoding="utf-8")

    def _validator(self) -> AssessmentValidator:
        self._write_v3()
        repository = StudentAuditRepository(self.data, "1001", "lab1")
        snapshot = ContributionAssessmentV3Adapter(self.data).load("student-a", "lab1", strict=True)
        return AssessmentValidator(repository, self.policy, contribution_snapshot=snapshot)

    def _raw(self, evidence: dict[str, object]) -> dict[str, object]:
        return {
            "overall_disposition": "N0",
            "summary": "当前只用于测试。",
            "data_limitations": ["测试材料有限。"],
            "findings": [
                {
                    "id": "F-001",
                    "disposition": "N0",
                    "rule_refs": ["1"],
                    "observations": ["观察到补充贡献材料。"],
                    "evidence": [evidence],
                    "limitations": ["不能据此推断真实作者。"],
                    "alternative_explanations": ["存在其他合理解释。"],
                    "teacher_verification": ["必要时询问学生。"],
                }
            ],
        }

    def test_valid_v3_evidence_is_revalidated_and_normalized(self) -> None:
        reference = self._reference()
        result = self._validator().validate(
            self._raw(
                {
                    "kind": "v3",
                    "unit_id": "unit-code",
                    "evidence_level": "E2",
                    "evidence_refs": [reference],
                }
            )
        )
        evidence = result["findings"][0]["evidence"][0]
        self.assertEqual(evidence["kind"], "v3")
        self.assertEqual(evidence["unit_id"], "unit-code")
        self.assertEqual(evidence["evidence_refs"][0]["source_id"], "source:lab1:timeline")

    def test_malformed_contribution_evidence_is_rejected_even_with_legacy_evidence(self) -> None:
        reference = self._reference()
        with self.assertRaises(Exception):
            raw = self._raw(
                {
                    "kind": "v3",
                    "unit_id": "unit-code",
                    "evidence_level": "E2",
                    "evidence_refs": [reference],
                }
            )
            raw["findings"][0]["contribution_evidence"] = "not-an-array"
            self._validator().validate(raw)

    def test_v3_hash_and_e1_claim_are_rejected(self) -> None:
        reference = self._reference()
        forged = {**reference, "sha256": "0" * 64}
        with self.assertRaises(Exception):
            self._validator().validate(
                self._raw(
                    {
                        "kind": "v3",
                        "unit_id": "unit-code",
                        "evidence_level": "E2",
                        "evidence_refs": [forged],
                    }
                )
            )
        with self.assertRaises(Exception):
            self._validator().validate(
                self._raw(
                    {
                        "kind": "v3",
                        "unit_id": "unit-code",
                        "evidence_level": "E1",
                        "evidence_refs": [reference],
                    }
                )
            )

    def test_report_renders_nested_integrity_assessment_without_secrets(self) -> None:
        reference = self._reference()
        assessment = self._validator().validate(
            self._raw(
                {
                    "kind": "v3",
                    "unit_id": "unit-code",
                    "evidence_level": "E2",
                    "evidence_refs": [reference],
                }
            )
        )
        assessment["integrity_assessment"] = {
            "overall_label": "存在疑点",
            "overall_disposition": "teacher_review",
            "coverage": {"status": "complete", "missing_or_limited": []},
            "contribution_access": {"analysis_status": "complete", "review_status": "agreed", "valid_unit_count": 1},
            "contribution_units": [
                {
                    "unit_id": "unit-code",
                    "label": "mixed",
                    "confidence": "moderate",
                    "summary": "代码与过程的补充线索",
                    "evidence_refs": [reference],
                }
            ],
            "teacher_actions": ["请教师核对学生解释。"],
            "limitations": ["贡献标签不等于作者认定。"],
        }
        repository = StudentAuditRepository(self.data, "1001", "lab1")
        report = render_report(assessment, repository, self.policy, {})
        self.assertIn("存在疑点", report)
        self.assertIn("教师动作", report)
        self.assertIn("source:lab1:timeline", report)
        self.assertIn("学生阅读提示", report)
        self.assertNotIn("nvapi-", report)
        self.assertNotIn("reasoning_content", report)

    def test_host_assessment_preserves_bounded_v3_unit_summary(self) -> None:
        self._write_v3()
        repository = StudentAuditRepository(self.data, "1001", "lab1")
        snapshot = ContributionAssessmentV3Adapter(self.data).load("student-a", "lab1", strict=True)
        host = make_integrity_assessment(
            student_directory="student-a",
            student_id="1001",
            lab="lab1",
            snapshot=snapshot,
        )
        units = host.to_dict()["contribution_access"]["units"]
        self.assertEqual(units[0]["summary"], "测试贡献单元")

        assessment = {
            "student_id": "1001",
            "lab": "lab1",
            "overall_disposition": "N0",
            "summary": "当前只用于测试。",
            "data_limitations": ["测试材料有限。"],
            "findings": [],
            "integrity_assessment": host.to_dict(),
        }
        report = render_report(assessment, repository, self.policy, {})
        self.assertIn("测试贡献单元", report)

    def test_disagreed_review_blocks_high_risk_gate(self) -> None:
        """A review disagreement must suppress every risk upgrade."""

        self._write_v3()
        value = json.loads(self.assessment_path.read_text(encoding="utf-8"))
        value["review"]["status"] = "disagreed"
        value["review"]["overall_decision"] = "disagree"
        value["review"]["unit_reviews"][0]["decision"] = "disagree"
        value["review"]["disagreement_unit_ids"] = ["unit-code"]
        self.assessment_path.write_text(json.dumps(value, ensure_ascii=False), encoding="utf-8")
        snapshot = ContributionAssessmentV3Adapter(self.data).load("student-a", "lab1", strict=True)

        label, _, limits = derive_overall_label(
            snapshot=snapshot,
            candidate_findings=[{"disposition": "R1"}],
            independent_e1=True,
            r1_r2_passed=True,
        )
        self.assertNotEqual(label, "高风险待核实")
        self.assertTrue(any("不提升诚信风险" in item for item in limits))

    def test_local_contribution_failure_keeps_independent_e1_reviewable(self) -> None:
        """A broken v3 contribution citation must not hide legacy E1 evidence."""

        self._write_v3()
        value = json.loads(self.assessment_path.read_text(encoding="utf-8"))
        # Keep the source manifest and review intact while invalidating only the
        # Lab-level contribution conclusion reference.
        value["lab_conclusion"]["evidence_refs"][0]["excerpt"] = "篡改后的摘录"
        self.assessment_path.write_text(json.dumps(value, ensure_ascii=False), encoding="utf-8")
        snapshot = ContributionAssessmentV3Adapter(self.data).load("student-a", "lab1")

        self.assertFalse(snapshot.lab_conclusion_valid)
        label, _, limits = derive_overall_label(
            snapshot=snapshot,
            candidate_findings=[{"disposition": "R1"}],
            independent_e1=True,
            r1_r2_passed=True,
        )
        self.assertEqual(label, "高风险待核实")
        self.assertTrue(any("贡献层" in item for item in limits))

    def test_invalid_unit_reference_does_not_block_independent_e1(self) -> None:
        """One invalid contribution unit is isolated from the host evidence path."""

        self._write_v3()
        value = json.loads(self.assessment_path.read_text(encoding="utf-8"))
        value["contribution_units"][0]["evidence_refs"][0]["excerpt"] = "篡改后的摘录"
        self.assessment_path.write_text(json.dumps(value, ensure_ascii=False), encoding="utf-8")
        snapshot = ContributionAssessmentV3Adapter(self.data).load("student-a", "lab1")

        self.assertFalse(snapshot.contribution_units[0].valid)
        self.assertTrue(snapshot.semantic_consumable)
        label, _, _ = derive_overall_label(
            snapshot=snapshot,
            candidate_findings=[{"disposition": "R1"}],
            independent_e1=True,
            r1_r2_passed=True,
        )
        self.assertEqual(label, "高风险待核实")

    def test_contribution_routing_requires_a_routable_unit(self) -> None:
        """A positive Lab conclusion cannot substitute for unit-level evidence."""

        self._write_v3()
        snapshot = ContributionAssessmentV3Adapter(self.data).load("student-a", "lab1", strict=True)
        registry = {"lab1": {"contribution_routing_enabled": True}}
        label, _, _ = derive_overall_label(snapshot=snapshot, rule_registry=registry)
        self.assertEqual(label, "存在疑点")

        value = json.loads(self.assessment_path.read_text(encoding="utf-8"))
        value["contribution_units"][0]["label"] = "human_dominant"
        self.assessment_path.write_text(json.dumps(value, ensure_ascii=False), encoding="utf-8")
        human_only = ContributionAssessmentV3Adapter(self.data).load("student-a", "lab1", strict=True)
        label, _, _ = derive_overall_label(snapshot=human_only, rule_registry=registry)
        self.assertNotEqual(label, "存在疑点")

    def test_incompatible_snapshot_cannot_raise_risk(self) -> None:
        snapshot = {
            "analysis_status": "complete",
            "compatibility": "incompatible",
            "semantic_consumable": False,
            "coverage": {"status": "complete"},
            "review": {"status": "agreed", "overall_decision": "agree"},
            "lab": "lab0",
            "lab_conclusion": {"label": "mixed", "confidence": "moderate"},
            "contribution_units": [{"label": "mixed", "confidence": "moderate", "valid": True}],
            "lab_conclusion_valid": True,
            "contribution_refs_valid": True,
        }
        label, _, limits = derive_overall_label(
            snapshot=snapshot,
            candidate_findings=[{"disposition": "R2"}],
            independent_e1=True,
            r1_r2_passed=True,
        )
        self.assertEqual(label, "资料不足/无法判定")
        self.assertTrue(limits)

    def test_upstream_limitations_produce_basic_integrity_and_are_persisted(self) -> None:
        self._write_v3()
        value = json.loads(self.assessment_path.read_text(encoding="utf-8"))
        value["limitations"] = ["当前过程材料只覆盖有限时间段。"]
        self.assessment_path.write_text(json.dumps(value, ensure_ascii=False), encoding="utf-8")
        snapshot = ContributionAssessmentV3Adapter(self.data).load("student-a", "lab1", strict=True)

        host = make_integrity_assessment(
            student_directory="student-a",
            student_id="1001",
            lab="lab1",
            snapshot=snapshot,
        )
        self.assertEqual(host.overall_label, "基本诚信")
        self.assertIn("当前过程材料只覆盖有限时间段。", host.limitations)

    def test_loop_accepts_v3_evidence_after_bounded_reads(self) -> None:
        self._write_v3()
        repository = StudentAuditRepository(self.data, "1001", "lab1")
        tools = AuditTools(repository, self.policy)
        reference = self._reference()
        candidate = self._raw(
            {
                "kind": "v3",
                "unit_id": "unit-code",
                "evidence_level": "E2",
                "evidence_refs": [reference],
            }
        )

        class Model:
            def __init__(self) -> None:
                self.responses = [
                    AssistantResponse(
                        content=None,
                        tool_calls=(
                            ToolCall("i", "get_data_inventory", {}),
                            ToolCall("q", "get_data_quality", {}),
                            ToolCall("ci", "get_contribution_inventory", {}),
                            ToolCall("cs", "get_contribution_status", {}),
                            ToolCall("p", "get_policy_section", {"section": "1"}),
                        ),
                        raw_message={},
                    ),
                    AssistantResponse(
                        content=None,
                        tool_calls=(
                            ToolCall("u", "read_contribution_unit", {"unit_id": "unit-code"}),
                            ToolCall(
                                "r",
                                "read_contribution_reference",
                                {
                                    "source_id": reference["source_id"],
                                    "line_start": 1,
                                    "line_end": 1,
                                },
                            ),
                        ),
                        raw_message={},
                    ),
                    AssistantResponse(
                        content=None,
                        tool_calls=(ToolCall("s", "submit_assessment", {"assessment": candidate}),),
                        raw_message={},
                    ),
                ]

            def complete(self, messages, tools):  # noqa: ANN001 - test protocol double
                return self.responses.pop(0)

        run = AuditAgentLoop(Model(), repository, self.policy, tools, max_turns=6).run()
        self.assertEqual(run.assessment["findings"][0]["evidence"][0]["kind"], "v3")

    def test_tool_schema_and_validator_cover_top_level_v3_evidence(self) -> None:
        self._write_v3()
        repository = StudentAuditRepository(self.data, "1001", "lab1")
        tools = AuditTools(repository, self.policy)
        submit = next(
            item
            for item in tools.definitions()
            if item.get("function", {}).get("name") == "submit_assessment"
        )
        finding_schema = submit["function"]["parameters"]["properties"]["assessment"]["properties"][
            "findings"
        ]["items"]
        finding_properties = finding_schema["properties"]
        self.assertIn("evidence_refs", finding_properties)
        self.assertIn("contribution_evidence", finding_properties)
        evidence_properties = finding_properties["evidence"]["items"]["properties"]
        for field in ("evidence_ref", "source_id", "relative_path", "sha256", "line_start", "line_end", "excerpt"):
            self.assertIn(field, evidence_properties)

        reference = self._reference()
        raw = self._raw(reference)
        finding = raw["findings"][0]
        finding.pop("evidence")
        finding["evidence_refs"] = [reference]
        validated = AssessmentValidator(
            repository,
            self.policy,
            contribution_snapshot=ContributionAssessmentV3Adapter(self.data).load(
                "student-a", "lab1", strict=True
            ),
        ).validate(raw)
        self.assertEqual(validated["findings"][0]["evidence"][0]["kind"], "v3")

        singular = self._raw(
            {
                "kind": "v3",
                "unit_id": "unit-code",
                "evidence_level": "E2",
                "evidence_ref": reference,
            }
        )
        singular_validated = AssessmentValidator(
            repository,
            self.policy,
            contribution_snapshot=ContributionAssessmentV3Adapter(self.data).load(
                "student-a", "lab1", strict=True
            ),
        ).validate(singular)
        self.assertEqual(
            singular_validated["findings"][0]["evidence"][0]["evidence_refs"][0]["source_id"],
            "source:lab1:timeline",
        )

        read = tools.execute(
            "read_contribution_reference",
            {
                "source_id": reference["source_id"],
                "line_start": reference["line_start"],
                "line_end": reference["line_end"],
                "relative_path": reference["relative_path"],
                "sha256": reference["sha256"],
                "excerpt": reference["excerpt"],
            },
        )
        self.assertTrue(read["ok"])
        forged = dict(reference)
        forged["excerpt"] = "not in source"
        self.assertFalse(
            tools.execute("read_contribution_reference", forged)["ok"]
        )


if __name__ == "__main__":
    unittest.main()
