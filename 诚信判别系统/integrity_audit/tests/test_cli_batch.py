from __future__ import annotations

import json
import tempfile
import unittest
from contextlib import redirect_stdout
from io import StringIO
from pathlib import Path
from unittest import mock

from audit_agent import cli
from audit_agent.models import AssistantResponse, ToolCall
from audit_agent.repository import StudentAuditRepository
from audit_agent.report import write_report, write_teacher_review_report


class FakeNimClient:
    """Offline two-turn model used to exercise the real batch orchestration."""

    def __init__(self, *_args, **_kwargs) -> None:
        self.calls = 0

    def complete(self, messages, tools):  # noqa: ANN001 - protocol test double
        self.calls += 1
        if self.calls % 2:
            return AssistantResponse(
                content=None,
                tool_calls=(
                    ToolCall(f"inventory-{self.calls}", "get_data_inventory", {}),
                    ToolCall(f"quality-{self.calls}", "get_data_quality", {}),
                    ToolCall(f"policy-{self.calls}", "get_policy_section", {"section": "1"}),
                ),
                raw_message={},
            )
        return AssistantResponse(
            content=None,
            tool_calls=(
                ToolCall(
                    f"submit-{self.calls}",
                    "submit_assessment",
                    {
                        "assessment": {
                            "overall_disposition": "N0",
                            "summary": "没有足够材料支持风险判断。",
                            "data_limitations": ["本测试只提供空时间线。"],
                            "findings": [],
                        }
                    },
                ),
            ),
            raw_message={},
        )


class CountingFakeNimClient(FakeNimClient):
    instances = 0

    def __init__(self, *_args, **_kwargs) -> None:
        super().__init__(*_args, **_kwargs)
        type(self).instances += 1


class FailingNimClient:
    instances = 0

    def __init__(self, *_args, **_kwargs) -> None:
        type(self).instances += 1

    def complete(self, *_args, **_kwargs):  # noqa: ANN001 - protocol test double
        raise RuntimeError("测试网络失败")


class CliBatchTestCase(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name)
        self.data_root = self.root / "data"
        self.student = self.data_root / "student-a"
        timeline = self.student / "实验过程时间线"
        timeline.mkdir(parents=True)
        (timeline / "timeline_lab0.json").write_text(
            json.dumps(
                {
                    "schema_version": 1,
                    "student": {"student_id": "1001", "name": "Student A"},
                    "lab": "lab0",
                    "status": "complete",
                    "summary": {"events": 0, "errors": 0},
                    "errors": [],
                    "events": [],
                },
                ensure_ascii=False,
            ),
            encoding="utf-8",
        )
        self.policy = self.root / "policy.md"
        self.policy.write_text("# Policy\n\n## 1. 基本边界\n\n仅用于测试。\n", encoding="utf-8")

    def tearDown(self) -> None:
        self.temporary.cleanup()

    def test_report_writers_use_stable_student_lab_paths_and_replace(self) -> None:
        repository = StudentAuditRepository(self.data_root, "1001", "lab0")
        full_root = self.root / "full"
        teacher_root = self.root / "teacher"

        first = write_report(full_root, repository, "first")
        second = write_report(full_root, repository, "second")
        teacher = write_teacher_review_report(teacher_root, repository, "teacher")

        self.assertEqual(first, second)
        self.assertEqual(
            first,
            full_root / "student-a" / "lab0" / "完整诚信审核报告.md",
        )
        self.assertEqual(
            teacher,
            teacher_root / "student-a" / "lab0" / "教师诚信复核报告.md",
        )
        self.assertEqual(first.read_text(encoding="utf-8"), "second")
        self.assertEqual(list((full_root / "student-a" / "lab0").iterdir()), [first])

    def test_batch_writes_task_artifacts_and_summary(self) -> None:
        full_root = self.root / "full"
        teacher_root = self.root / "teacher"
        trace_root = self.root / "logs"
        output = StringIO()
        arguments = [
            "batch",
            "--data-root",
            str(self.data_root),
            "--policy",
            str(self.policy),
            "--student",
            "1001",
            "--lab",
            "lab0",
            "--output-dir",
            str(full_root),
            "--teacher-output-dir",
            str(teacher_root),
            "--trace-dir",
            str(trace_root),
            "--batch-id",
            "batch-test",
        ]
        with mock.patch.object(cli, "OpenAICompatibleChatClient", FakeNimClient):
            with mock.patch.object(cli.OpenAICompatibleConfig, "from_environment", return_value=object()):
                with redirect_stdout(output):
                    exit_code = cli.main(arguments)

        self.assertEqual(exit_code, 0)
        response = json.loads(output.getvalue())
        self.assertEqual(response["summary"], str(trace_root / "batches" / "batch-test" / "summary.json"))
        summary = json.loads(Path(response["summary"]).read_text(encoding="utf-8"))
        self.assertEqual(summary["counts"], {"completed": 1})
        row = summary["results"][0]
        self.assertEqual(
            Path(row["report"]),
            full_root / "student-a" / "lab0" / "完整诚信审核报告.md",
        )
        self.assertEqual(
            Path(row["teacher_review_report"]),
            teacher_root / "student-a" / "lab0" / "教师诚信复核报告.md",
        )
        task_logs = trace_root / "student-a" / "lab0"
        self.assertTrue((task_logs / "assessment.json").is_file())
        self.assertTrue((task_logs / "audit_manifest.json").is_file())
        self.assertEqual(len(list((task_logs / "runs").glob("*.jsonl"))), 1)

    def test_defaults_point_to_cleaning_pipeline_root(self) -> None:
        defaults = cli._defaults()
        self.assertEqual(defaults["data_root"].name, "操作系统实验数据记录-已清洗")
        self.assertEqual(defaults["data_root"].parent.name, "操作系统实验数据清洗")

    def test_student_listing_skips_pipeline_aggregate_directories(self) -> None:
        (self.data_root / "代码差异报告汇总").mkdir()
        (self.data_root / "AI人工贡献识别运行日志").mkdir()
        (self.data_root / ".cache").mkdir()
        students = StudentAuditRepository.list_students(self.data_root)
        self.assertEqual([item.directory_name for item in students], ["student-a"])

    def test_batch_dry_run_reports_bounded_contribution_inventory(self) -> None:
        output = StringIO()
        arguments = [
            "batch",
            "--data-root",
            str(self.data_root),
            "--policy",
            str(self.policy),
            "--student",
            "1001",
            "--lab",
            "lab0",
            "--dry-run",
        ]
        with redirect_stdout(output):
            self.assertEqual(cli.main(arguments), 0)
        row = json.loads(output.getvalue())["batch"]["results"][0]
        self.assertEqual(row["status"], "dry-run")
        self.assertFalse(row["contribution"]["assessment_available"])
        self.assertEqual(row["contribution"]["unit_count"], 0)

    def test_missing_batch_task_writes_insufficient_reports_without_model(self) -> None:
        empty_student = self.data_root / "student-empty"
        empty_student.mkdir()
        full_root = self.root / "full"
        teacher_root = self.root / "teacher"
        trace_root = self.root / "logs"
        arguments = [
            "batch",
            "--data-root",
            str(self.data_root),
            "--policy",
            str(self.policy),
            "--student",
            "student-empty",
            "--lab",
            "lab0",
            "--output-dir",
            str(full_root),
            "--teacher-output-dir",
            str(teacher_root),
            "--trace-dir",
            str(trace_root),
            "--batch-id",
            "missing-test",
        ]
        output = StringIO()
        with mock.patch.object(cli, "OpenAICompatibleChatClient", side_effect=AssertionError("不应调用模型")):
            with redirect_stdout(output):
                self.assertEqual(cli.main(arguments), 0)
        row = json.loads(output.getvalue())["batch"]["results"][0]
        self.assertEqual(row["status"], "missing")
        self.assertEqual(row["overall_label"], "资料不足/无法判定")
        report = Path(row["report"])
        teacher_report = Path(row["teacher_review_report"])
        self.assertTrue(report.is_file())
        self.assertTrue(teacher_report.is_file())
        self.assertIn("资料不足/无法判定", report.read_text(encoding="utf-8"))
        manifest = json.loads((trace_root / "student-empty" / "lab0" / "audit_manifest.json").read_text(encoding="utf-8"))
        self.assertEqual(manifest["status"], "missing")

        second_output = StringIO()
        with redirect_stdout(second_output):
            self.assertEqual(cli.main(arguments), 0)
        cached = json.loads(second_output.getvalue())["batch"]["results"][0]
        self.assertEqual(cached["status"], "cached")
        cached_manifest = json.loads((trace_root / "student-empty" / "lab0" / "audit_manifest.json").read_text(encoding="utf-8"))
        self.assertEqual(cached_manifest["status"], "missing")

    def test_completed_batch_task_is_cached_without_model_call(self) -> None:
        full_root = self.root / "full"
        teacher_root = self.root / "teacher"
        trace_root = self.root / "logs"
        common = [
            "batch",
            "--data-root",
            str(self.data_root),
            "--policy",
            str(self.policy),
            "--student",
            "1001",
            "--lab",
            "lab0",
            "--output-dir",
            str(full_root),
            "--teacher-output-dir",
            str(teacher_root),
            "--trace-dir",
            str(trace_root),
            "--batch-id",
            "cache-test",
        ]
        CountingFakeNimClient.instances = 0
        with mock.patch.object(cli, "OpenAICompatibleChatClient", CountingFakeNimClient):
            with mock.patch.object(cli.OpenAICompatibleConfig, "from_environment", return_value=object()):
                first_output = StringIO()
                with redirect_stdout(first_output):
                    self.assertEqual(cli.main(common), 0)
                second_output = StringIO()
                with redirect_stdout(second_output):
                    self.assertEqual(cli.main(common), 0)

        first = json.loads(first_output.getvalue())["batch"]["results"][0]
        second = json.loads(second_output.getvalue())["batch"]["results"][0]
        self.assertEqual(first["status"], "completed")
        self.assertEqual(second["status"], "cached")
        self.assertEqual(CountingFakeNimClient.instances, 1)
        self.assertEqual(first["input_fingerprint"], second["input_fingerprint"])

    def test_resume_defers_failure_and_retry_failed_runs_it_again(self) -> None:
        trace_root = self.root / "logs"
        common = [
            "batch",
            "--data-root",
            str(self.data_root),
            "--policy",
            str(self.policy),
            "--student",
            "1001",
            "--lab",
            "lab0",
            "--trace-dir",
            str(trace_root),
            "--batch-id",
            "failure-test",
        ]
        FailingNimClient.instances = 0
        with mock.patch.object(cli, "OpenAICompatibleChatClient", FailingNimClient):
            with mock.patch.object(cli.OpenAICompatibleConfig, "from_environment", return_value=object()):
                first_output = StringIO()
                with redirect_stdout(first_output):
                    self.assertEqual(cli.main(common), 1)

        first = json.loads(first_output.getvalue())["batch"]["results"][0]
        self.assertEqual(first["status"], "failed")
        self.assertTrue((trace_root / "student-a" / "lab0" / "audit_manifest.json").is_file())

        deferred_output = StringIO()
        with redirect_stdout(deferred_output):
            self.assertEqual(cli.main(common + ["--resume"]), 0)
        deferred = json.loads(deferred_output.getvalue())["batch"]["results"][0]
        self.assertEqual(deferred["status"], "deferred")
        self.assertEqual(FailingNimClient.instances, 1)

        retry_output = StringIO()
        with mock.patch.object(cli, "OpenAICompatibleChatClient", FakeNimClient):
            with mock.patch.object(cli.OpenAICompatibleConfig, "from_environment", return_value=object()):
                with redirect_stdout(retry_output):
                    self.assertEqual(cli.main(common + ["--resume", "--retry-failed"]), 0)
        retry = json.loads(retry_output.getvalue())["batch"]["results"][0]
        self.assertEqual(retry["status"], "completed")


if __name__ == "__main__":
    unittest.main()
