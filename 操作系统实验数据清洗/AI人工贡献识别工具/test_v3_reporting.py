from __future__ import annotations

import json
import os
import tempfile
import unittest
from copy import deepcopy
from pathlib import Path

from contribution_recognition.report import V3_SCHEMA_VERSION, render_full_report, render_teacher_report
from contribution_recognition.storage import ContributionStorage, validate_v3_assessment


def _source(
    source_id: str,
    kind: str,
    path: str,
    sha: str,
    *,
    required: bool = True,
    availability: str = "available",
    line_count: int | None = 30,
    reason: str | None = None,
) -> dict[str, object]:
    return {
        "source_id": source_id,
        "kind": kind,
        "required": required,
        "availability": availability,
        "relative_path": path,
        "sha256": sha,
        "line_count": line_count,
        "reason": reason,
    }


def _evidence(source_id: str = "source:lab1:timeline") -> dict[str, object]:
    return {
        "source_id": source_id,
        "relative_path": "简洁实验过程时间线/timeline_lab1.md",
        "sha256": "a" * 64,
        "line_start": 3,
        "line_end": 5,
        "excerpt": "学生询问原理；NVIDIA_API_KEY=[REDACTED]。",
    }


def _assessment() -> dict[str, object]:
    evidence = _evidence()
    return {
        "schema_version": V3_SCHEMA_VERSION,
        "analysis_status": "complete",
        "student": {
            "directory_name": "2406080001-测试学生",
            "student_id": "2406080001",
            "display_name": "测试学生",
        },
        "lab": "lab1",
        "coverage": {"status": "complete", "missing_or_limited": []},
        "source_manifest": [
            _source("source:lab1:timeline", "timeline", "简洁实验过程时间线/timeline_lab1.md", "a" * 64),
            _source("source:lab1:terminal_qa", "terminal_qa", "终端对话记录/terminal_qa_report_lab1.md", "b" * 64),
            _source("source:lab1:command_statistics", "command_statistics", "终端命令统计/command_statistics_lab1.md", "c" * 64),
            _source("source:lab1:diff_report", "diff_report", "代码差异报告/lab1.md", "d" * 64),
        ],
        "diff_hunks": [
            {
                "hunk_id": "hunk:lab1:1",
                "file_path": "kernel/foo.c",
                "source_id": "source:lab1:diff_report",
                "line_start": 10,
                "line_end": 20,
            }
        ],
        "contribution_units": [
            {
                "unit_id": "unit-1",
                "unit_type": "code_hunk",
                "label": "mixed",
                "behavior_roles": {
                    "ai": ["ai_guidance"],
                    "human": ["human_implementation", "human_verification"],
                },
                "confidence": "moderate",
                "scope": {"hunk_id": "hunk:lab1:1"},
                "evidence_refs": [evidence],
                "summary": "学生根据解释修改并验证了该范围。",
                "alternative_explanation": "过程记录不能证明真实作者身份。",
                "limitations": ["无法从记录判断输入方式。"],
            }
        ],
        "lab_conclusion": {
            "label": "mixed",
            "confidence": "moderate",
            "summary": "当前 Lab 存在可复核的 AI 指导与人工实现过程。",
            "evidence_refs": [evidence],
        },
        "review": {
            "status": "agreed",
            "overall_decision": "agree",
            "unit_reviews": [
                {
                    "unit_id": "unit-1",
                    "decision": "agree",
                    "reason": "证据范围一致。",
                    "evidence_refs": [evidence],
                }
            ],
            "reviewed_unit_ids": ["unit-1"],
            "disagreement_unit_ids": [],
        },
        "limitations": ["结论仅覆盖已清洗的当前 Lab 材料。"],
        "run_metadata": {
            "tool_version": "3.0.0-test",
            "prompt_version": "v3-test",
            "validator_version": "validator-test",
            "completed_at": "2026-09-18T00:00:00+00:00",
            "reasoning_content": "must never persist",
            "raw_response": "must never persist",
        },
    }


class V3ReportingTests(unittest.TestCase):
    def test_renderers_use_short_redacted_evidence_only(self) -> None:
        assessment = _assessment()
        full = render_full_report(assessment)
        teacher = render_teacher_report(assessment)

        for report in (full, teacher):
            self.assertIn("SHA-256", report)
            self.assertIn("第 3-5 行", report)
            self.assertIn("[REDACTED]", report)
            self.assertNotIn("[REDACTED]", report)
            self.assertNotIn("must never persist", report)
            self.assertNotIn("reasoning_content", report)
        self.assertIn("完整贡献识别报告", full)
        self.assertIn("教师贡献复核报告", teacher)
        self.assertIn("NIM 主分析与独立 NIM 复核一致", teacher)

    def test_storage_commits_assessment_and_both_reports_with_v3_manifest(self) -> None:
        assessment = _assessment()
        with tempfile.TemporaryDirectory() as temporary_directory:
            storage = ContributionStorage(Path(temporary_directory))
            assessment_path, full_path, teacher_path = storage.write_assessment_and_reports(
                "2406080001-测试学生",
                "lab1",
                assessment,
                render_full_report(assessment),
                render_teacher_report(assessment),
                "sha256:input",
                "sha256:render",
            )

            self.assertTrue(assessment_path.is_file())
            self.assertTrue(full_path.is_file())
            self.assertTrue(teacher_path.is_file())
            self.assertEqual(assessment_path.parent.name, "assessment")
            self.assertEqual(full_path.parent.name, "完整贡献识别报告")
            self.assertEqual(teacher_path.parent.name, "教师贡献复核报告")
            written = json.loads(assessment_path.read_text(encoding="utf-8"))
            self.assertEqual(written["schema_version"], V3_SCHEMA_VERSION)
            self.assertNotIn("reasoning_content", json.dumps(written, ensure_ascii=False))
            self.assertNotIn("[REDACTED]", json.dumps(written, ensure_ascii=False))
            self.assertTrue(storage.cache_hit("2406080001-测试学生", "lab1", "sha256:input"))
            self.assertTrue(storage.reports_are_current("2406080001-测试学生", "lab1", "sha256:render"))
            manifest = storage.load_manifest("2406080001-测试学生")
            self.assertEqual(manifest["schema_version"], "ai-human-contribution-manifest/v3")
            self.assertIn("full_report_sha256", manifest["labs"]["lab1"])
            self.assertIn("teacher_report_sha256", manifest["labs"]["lab1"])
            self.assertEqual(list(assessment_path.parent.glob(".contribution-*.tmp")), [])

            storage.write_reports_only(
                "2406080001-测试学生",
                "lab1",
                written,
                render_full_report(written),
                render_teacher_report(written),
                "sha256:rerender",
            )
            self.assertFalse(storage.reports_are_current("2406080001-测试学生", "lab1", "sha256:render"))
            self.assertTrue(storage.reports_are_current("2406080001-测试学生", "lab1", "sha256:rerender"))

    def test_flat_v3_artifacts_migrate_into_categorized_directories(self) -> None:
        assessment = _assessment()
        student = "2406080001-测试学生"
        with tempfile.TemporaryDirectory() as temporary_directory:
            storage = ContributionStorage(Path(temporary_directory))
            assessment_path, full_path, teacher_path = storage.write_assessment_and_reports(
                student,
                "lab1",
                assessment,
                render_full_report(assessment),
                render_teacher_report(assessment),
                "sha256:input",
                "sha256:render",
            )
            root = storage.analysis_directory(student)
            legacy_assessment = root / "assessment_lab1.json"
            legacy_full = root / "完整贡献识别报告_lab1.md"
            legacy_teacher = root / "教师贡献复核报告_lab1.md"
            os.replace(assessment_path, legacy_assessment)
            os.replace(full_path, legacy_full)
            os.replace(teacher_path, legacy_teacher)

            self.assertTrue(storage.cache_hit(student, "lab1", "sha256:input"))
            self.assertTrue(assessment_path.is_file())
            self.assertTrue(full_path.is_file())
            self.assertTrue(teacher_path.is_file())
            self.assertFalse(legacy_assessment.exists())
            self.assertFalse(legacy_full.exists())
            self.assertFalse(legacy_teacher.exists())

    def test_insufficient_data_and_old_schema_are_strictly_handled(self) -> None:
        assessment = _assessment()
        assessment["analysis_status"] = "insufficient_data"
        assessment["contribution_units"] = []
        assessment["lab_conclusion"] = {
            "label": "indeterminate",
            "confidence": "weak",
            "summary": "规定材料不足。",
            "evidence_refs": [],
        }
        assessment["review"] = {
            "status": "not_run",
            "overall_decision": None,
            "unit_reviews": [],
            "reviewed_unit_ids": [],
            "disagreement_unit_ids": [],
        }
        validate_v3_assessment(assessment)
        self.assertIn("无可复核的贡献单元", render_teacher_report(assessment))

        old = deepcopy(assessment)
        old["schema_version"] = "ai-human-contribution-assessment/v2"
        with self.assertRaisesRegex(ValueError, "仅可写入"):
            validate_v3_assessment(old)
        with self.assertRaisesRegex(ValueError, "只支持"):
            render_full_report(old)

    def test_weak_and_disagreed_units_cannot_be_persisted_as_positive_attribution(self) -> None:
        weak = _assessment()
        weak["contribution_units"][0]["confidence"] = "weak"  # type: ignore[index]
        with self.assertRaisesRegex(ValueError, "弱证据"):
            validate_v3_assessment(weak)

        disagreed = _assessment()
        disagreed["review"] = {
            "status": "disagreed",
            "overall_decision": "disagree",
            "unit_reviews": [
                {
                    "unit_id": "unit-1",
                    "decision": "disagree",
                    "reason": "复核认为结论不足。",
                    "evidence_refs": [_evidence()],
                }
            ],
            "reviewed_unit_ids": ["unit-1"],
            "disagreement_unit_ids": ["unit-1"],
        }
        with self.assertRaisesRegex(ValueError, "分歧单元"):
            validate_v3_assessment(disagreed)

    def test_process_segment_uses_the_canonical_direct_line_scope(self) -> None:
        assessment = _assessment()
        unit = assessment["contribution_units"][0]  # type: ignore[index]
        unit["unit_type"] = "process_segment"
        unit["scope"] = {"source_id": "source:lab1:timeline", "line_start": 3, "line_end": 5}
        validate_v3_assessment(assessment)
        self.assertIn("过程范围：`source:lab1:timeline` 第 3-5 行", render_full_report(assessment))

    def test_overview_reads_canonical_lab_conclusion_and_review(self) -> None:
        with tempfile.TemporaryDirectory() as temporary_directory:
            storage = ContributionStorage(Path(temporary_directory))
            markdown_path, csv_path = storage.write_overview(
                [
                    {
                        "student_directory": "student",
                        "lab": "lab1",
                        "analysis_status": "complete",
                        "execution_status": "cached",
                        "lab_conclusion": {"label": "mixed", "confidence": "moderate"},
                        "review": {"status": "agreed"},
                        "coverage": {"status": "complete"},
                        "message": "ok",
                    }
                ]
            )
            markdown = markdown_path.read_text(encoding="utf-8")
            csv_text = csv_path.read_text(encoding="utf-8")
            self.assertIn("总体贡献画像", markdown)
            self.assertIn("mixed", markdown)
            self.assertIn("agreed", csv_text)


if __name__ == "__main__":
    unittest.main()
