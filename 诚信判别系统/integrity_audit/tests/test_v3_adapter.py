from __future__ import annotations

import hashlib
import json
import tempfile
import unittest
from pathlib import Path
from typing import Any

from audit_agent.evidence import EvidenceRef, can_upgrade_to_e1
from audit_agent.policy import PolicyDocument
from audit_agent.repository import StudentAuditRepository
from audit_agent.validation import AssessmentValidator
from audit_agent.errors import ValidationError
from audit_agent.v3_adapter import (
    ContributionAssessmentV3Adapter,
    V3ContractError,
)


class V3AdapterTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.student = self.root / "student-a"
        (self.student / "AI人工贡献识别" / "assessment").mkdir(parents=True)
        self.files = {
            "timeline": ("简洁实验过程时间线/timeline_lab0.md", "学生询问原理\n学生验证输出\n"),
            "terminal_qa": ("终端对话记录/terminal_qa_report_lab0.md", "终端问答\n"),
            "command_statistics": ("终端命令统计/command_statistics_lab0.md", "make test\n"),
        }
        self.sources: list[dict[str, Any]] = []
        for kind, (relative, text) in self.files.items():
            path = self.student / relative
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(text, encoding="utf-8")
            self.sources.append(
                {
                    "source_id": "source:lab0:" + kind,
                    "kind": kind,
                    "required": True,
                    "availability": "available",
                    "relative_path": relative,
                    "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
                    "line_count": len(text.splitlines()),
                    "reason": None,
                }
            )
        self.sources.append(
            {
                "source_id": "source:lab0:diff_report",
                "kind": "diff_report",
                "required": False,
                "availability": "not_applicable",
                "relative_path": None,
                "sha256": None,
                "line_count": None,
                "reason": "lab0 process-only",
            }
        )

    def tearDown(self) -> None:
        self.temp.cleanup()

    def _ref(self, *, excerpt: str = "学生询问原理", source_id: str = "source:lab0:timeline") -> dict[str, Any]:
        source = next(item for item in self.sources if item["source_id"] == source_id)
        return {
            "source_id": source_id,
            "relative_path": source["relative_path"],
            "sha256": source["sha256"],
            "line_start": 1,
            "line_end": 1,
            "excerpt": excerpt,
        }

    def _assessment(self) -> dict[str, Any]:
        ref = self._ref()
        return {
            "schema_version": "ai-human-contribution-assessment/v3",
            "analysis_status": "complete",
            "student": {"directory_name": "student-a", "student_id": "1001", "display_name": "A"},
            "lab": "lab0",
            "coverage": {"status": "complete", "missing_or_limited": []},
            "source_manifest": self.sources,
            "diff_hunks": [],
            "contribution_units": [
                {
                    "unit_id": "unit-good",
                    "unit_type": "process_segment",
                    "label": "mixed",
                    "behavior_roles": {"ai": ["ai_guidance"], "human": ["human_verification"]},
                    "confidence": "moderate",
                    "scope": {
                        "source_id": "source:lab0:timeline",
                        "line_start": 1,
                        "line_end": 1,
                    },
                    "evidence_refs": [ref],
                    "summary": "过程片段",
                    "alternative_explanation": "记录有限",
                    "limitations": [],
                }
            ],
            "lab_conclusion": {
                "label": "mixed",
                "confidence": "moderate",
                "summary": "有限过程证据",
                "evidence_refs": [ref],
            },
            "review": {
                "status": "agreed",
                "overall_decision": "agree",
                "unit_reviews": [
                    {
                        "unit_id": "unit-good",
                        "decision": "agree",
                        "reason": "范围一致",
                        "evidence_refs": [ref],
                    }
                ],
                "reviewed_unit_ids": ["unit-good"],
                "disagreement_unit_ids": [],
            },
            "limitations": [],
            "run_metadata": {},
        }

    def _write(self, value: dict[str, Any]) -> None:
        path = self.student / "AI人工贡献识别" / "assessment" / "assessment_lab0.json"
        path.write_text(json.dumps(value, ensure_ascii=False), encoding="utf-8")

    def _host_validation_payload(self, snapshot: Any) -> dict[str, Any]:
        unit = snapshot.contribution_units[0]
        reference = unit.evidence_refs[0].to_dict()
        return {
            "overall_disposition": "N0",
            "summary": "仅作宿主校验测试。",
            "data_limitations": ["测试数据有限。"],
            "findings": [
                {
                    "id": "N-V3",
                    "disposition": "N0",
                    "rule_refs": ["3.1"],
                    "observations": ["引用一个已重验的 v3 贡献单元。"],
                    "evidence": [
                        {
                            "kind": "v3",
                            "unit_id": unit.unit_id,
                            "evidence_level": reference["evidence_level"],
                            "evidence_refs": [reference],
                        }
                    ],
                    "limitations": ["不得据此推断作者身份。"],
                    "alternative_explanations": ["记录可能不完整。"],
                    "teacher_verification": ["按行范围复核。"],
                }
            ],
        }

    def _host_validator(self, snapshot: Any) -> AssessmentValidator:
        policy_path = self.root / "policy.md"
        policy_path.write_text(
            "# 规则\n\n## 3.1 允许协助\n\n教学辅助不等于违规。\n",
            encoding="utf-8",
        )
        repository = StudentAuditRepository(self.root, "student-a", "lab0")
        return AssessmentValidator(repository, PolicyDocument(policy_path), snapshot)

    def test_complete_lab0_is_consumable_and_diff_is_not_applicable(self) -> None:
        self._write(self._assessment())
        snapshot = ContributionAssessmentV3Adapter(self.root).load("student-a", "lab0")
        self.assertTrue(snapshot.semantic_consumable)
        self.assertTrue(snapshot.risk_upgrade_allowed)
        self.assertEqual(snapshot.source_by_id["source:lab0:diff_report"].availability, "not_applicable")
        self.assertEqual(snapshot.read_source_range("source:lab0:timeline", 1, 1)["lines"][0]["line"], 1)

    def test_v2_is_explicitly_incompatible(self) -> None:
        value = self._assessment()
        value["schema_version"] = "ai-human-contribution-assessment/v2"
        self._write(value)
        snapshot = ContributionAssessmentV3Adapter(self.root).load("student-a", "lab0")
        self.assertEqual(snapshot.compatibility, "legacy/incompatible")
        self.assertFalse(snapshot.semantic_consumable)
        with self.assertRaises(V3ContractError):
            ContributionAssessmentV3Adapter(self.root).require("student-a", "lab0")

    def test_host_validator_rejects_cross_lab_hash_range_and_excerpt_tampering(self) -> None:
        self._write(self._assessment())
        snapshot = ContributionAssessmentV3Adapter(self.root).load("student-a", "lab0")
        validator = self._host_validator(snapshot)
        payload = self._host_validation_payload(snapshot)
        self.assertEqual(validator.validate(payload)["findings"][0]["evidence"][0]["kind"], "v3")

        for mutation in (
            lambda item: item.update({"source_id": "source:lab1:timeline"}),
            lambda item: item.update({"sha256": "0" * 64}),
            lambda item: item.update({"line_start": 0}),
            lambda item: item.update({"excerpt": "unrelated forged text"}),
        ):
            changed = json.loads(json.dumps(payload, ensure_ascii=False))
            mutation(changed["findings"][0]["evidence"][0]["evidence_refs"][0])
            with self.assertRaises(ValidationError):
                validator.validate(changed)

    def test_host_validator_allows_not_run_display_but_blocks_disagreed_unit(self) -> None:
        value = self._assessment()
        value["review"] = {
            "status": "not_run",
            "overall_decision": None,
            "unit_reviews": [],
            "reviewed_unit_ids": [],
            "disagreement_unit_ids": [],
        }
        self._write(value)
        snapshot = ContributionAssessmentV3Adapter(self.root).load("student-a", "lab0")
        self.assertTrue(self._host_validator(snapshot).validate(self._host_validation_payload(snapshot)))

        value = self._assessment()
        value["review"] = {
            "status": "disagreed",
            "overall_decision": "disagree",
            "unit_reviews": [
                {
                    "unit_id": "unit-good",
                    "decision": "disagree",
                    "reason": "独立复核不同意。",
                    "evidence_refs": [self._ref()],
                }
            ],
            "reviewed_unit_ids": ["unit-good"],
            "disagreement_unit_ids": ["unit-good"],
        }
        self._write(value)
        disagreed = ContributionAssessmentV3Adapter(self.root).load("student-a", "lab0")
        with self.assertRaises(ValidationError):
            self._host_validator(disagreed).validate(self._host_validation_payload(disagreed))

    def test_bad_reference_isolated_to_its_unit(self) -> None:
        value = self._assessment()
        value["contribution_units"].append(
            {
                "unit_id": "unit-bad",
                "unit_type": "process_segment",
                "label": "ai_dominant",
                "behavior_roles": {"ai": ["generation"], "human": []},
                "confidence": "strong",
                "scope": {"source_id": "source:lab0:timeline", "line_start": 1, "line_end": 1},
                "evidence_refs": [{**self._ref(), "excerpt": "forged unrelated text"}],
                "summary": "bad",
                "alternative_explanation": "bad",
                "limitations": [],
            }
        )
        self._write(value)
        snapshot = ContributionAssessmentV3Adapter(self.root).load("student-a", "lab0")
        self.assertIn("unit-good", [item.unit_id for item in snapshot.valid_units])
        self.assertIn("unit-bad", [item.unit_id for item in snapshot.invalid_units])
        self.assertTrue(snapshot.contribution_layer_usable)

    def test_hash_mismatch_and_cross_source_are_rejected(self) -> None:
        value = self._assessment()
        value["contribution_units"][0]["evidence_refs"][0]["sha256"] = "0" * 64
        self._write(value)
        snapshot = ContributionAssessmentV3Adapter(self.root).load("student-a", "lab0")
        self.assertFalse(snapshot.contribution_units[0].valid)
        self.assertFalse(snapshot.contribution_signals()[0]["risk_signal"])
        self.assertFalse(snapshot.semantic_consumable)

    def test_disagreed_review_downgrades_the_disputed_unit(self) -> None:
        value = self._assessment()
        value["review"]["status"] = "disagreed"
        value["review"]["overall_decision"] = "disagree"
        value["review"]["unit_reviews"][0]["decision"] = "disagree"
        value["review"]["disagreement_unit_ids"] = ["unit-good"]
        self._write(value)
        snapshot = ContributionAssessmentV3Adapter(self.root).load("student-a", "lab0")
        self.assertEqual(snapshot.contribution_units[0].label, "indeterminate")
        self.assertEqual(snapshot.contribution_units[0].confidence, "weak")
        self.assertFalse(snapshot.risk_upgrade_allowed)

    def test_event_reference_and_e1_gate(self) -> None:
        event = EvidenceRef.from_event("evt-1", "make test")
        self.assertEqual(event.evidence_level, "E2")
        self.assertEqual(
            EvidenceRef.from_event("evt-1", "make test", evidence_level="E1").evidence_level,
            "E2",
        )
        self.assertFalse(can_upgrade_to_e1(
            independent_archive=False,
            archive_sha256=None,
            collection_chain=False,
            precise_location=False,
        ))
        adapter = ContributionAssessmentV3Adapter(self.root)
        self.assertEqual(
            adapter.event_evidence("evt-1", "make test", evidence_level="E1").evidence_level,
            "E2",
        )

    def test_snapshot_never_exposes_private_reasoning_or_key_fields(self) -> None:
        value = self._assessment()
        value["run_metadata"]["reasoning_content"] = "secret chain"
        value["limitations"] = ["nvapi-test-secret-token"]
        self._write(value)
        snapshot = ContributionAssessmentV3Adapter(self.root).load("student-a", "lab0")
        encoded = json.dumps(snapshot.status(), ensure_ascii=False)
        self.assertNotIn("secret chain", encoded)
        self.assertNotIn("nvapi-test-secret-token", encoded)

    def test_forged_secret_only_excerpt_is_not_accepted_after_redaction(self) -> None:
        value = self._assessment()
        value["contribution_units"][0]["evidence_refs"][0]["excerpt"] = "nvapi-forged-secret"
        value["lab_conclusion"]["evidence_refs"][0]["excerpt"] = "nvapi-forged-secret"
        value["review"]["unit_reviews"][0]["evidence_refs"][0]["excerpt"] = "nvapi-forged-secret"
        self._write(value)
        snapshot = ContributionAssessmentV3Adapter(self.root).load("student-a", "lab0")
        self.assertFalse(snapshot.contribution_units[0].valid)
        self.assertFalse(snapshot.lab_conclusion_valid)

    def test_cross_lab_source_id_is_rejected_without_path_guessing(self) -> None:
        value = self._assessment()
        value["contribution_units"][0]["evidence_refs"][0]["source_id"] = "source:lab1:timeline"
        self._write(value)
        snapshot = ContributionAssessmentV3Adapter(self.root).load("student-a", "lab0")
        self.assertFalse(snapshot.contribution_units[0].valid)

    def test_lab1_missing_required_materials_is_not_a_negative_fact(self) -> None:
        value = self._assessment()
        value["lab"] = "lab1"
        value["analysis_status"] = "insufficient_data"
        value["student"]["directory_name"] = "student-a"
        value["source_manifest"] = [
            {
                "source_id": "source:lab1:" + kind,
                "kind": kind,
                "required": True,
                "availability": "missing",
                "relative_path": None,
                "sha256": None,
                "line_count": None,
                "reason": "材料缺失",
            }
            for kind in ("timeline", "terminal_qa", "command_statistics", "diff_report")
        ]
        value["contribution_units"] = []
        value["lab_conclusion"] = {
            "label": "indeterminate",
            "confidence": "weak",
            "summary": "资料不足",
            "evidence_refs": [],
        }
        value["review"] = {
            "status": "not_run",
            "overall_decision": None,
            "unit_reviews": [],
            "reviewed_unit_ids": [],
            "disagreement_unit_ids": [],
        }
        path = self.student / "AI人工贡献识别" / "assessment" / "assessment_lab1.json"
        path.write_text(json.dumps(value, ensure_ascii=False), encoding="utf-8")
        snapshot = ContributionAssessmentV3Adapter(self.root).load("student-a", "lab1")
        self.assertFalse(snapshot.semantic_consumable)
        self.assertEqual(snapshot.analysis_status, "insufficient_data")


if __name__ == "__main__":
    unittest.main()
