import json
import tempfile
import unittest
from pathlib import Path
from unittest import mock

import generate_lab_diff_reports as app


class LabDiffReportTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.reference = self.root / "reference"
        self.submissions = self.root / "submissions"
        self.cleaned = self.root / "cleaned"
        self.reference_lab = self.reference / "lab1"
        self.student_source = self.submissions / "2406080106-高龙徽-20260909-1215"
        self.student_lab = self.student_source / "labs" / "lab1"
        self.student_cleaned = self.cleaned / "高龙徽"
        self.write(self.reference_lab / "kernel" / "main.c", "int value = 1;\n")
        self.write(self.student_lab / "kernel" / "main.c", "int value = 2; // ```\n")
        self.write(self.reference_lab / "xv6-user" / "gone.c", "int gone;\n")
        self.write(self.student_lab / "kernel" / "new.c", "int added;\n")
        self.write(self.reference_lab / "Makefile", "all:\n\t@echo old\n")
        self.write(self.student_lab / "Makefile", "all:\n\t@echo new\n")
        self.write(self.reference_lab / "doc" / "guide.md", "reference\n")
        self.write(self.student_lab / "doc" / "guide.md", "student\n")
        self.write(self.reference_lab / "target" / "kernel.asm", "reference\n")
        self.write(self.student_lab / "target" / "kernel.asm", "student\n")
        self.write_bytes(self.reference_lab / "kernel" / "binary.c", b"reference\0")
        self.write_bytes(self.student_lab / "kernel" / "binary.c", b"student\0")
        self.student_cleaned.mkdir(parents=True)
        (self.student_cleaned / app.OWNER_FILE).write_text(
            json.dumps({"source": str(self.student_source)}), encoding="utf-8"
        )
        (self.student_cleaned / "现有报告.md").write_text("keep", encoding="utf-8")

    def tearDown(self):
        self.temp.cleanup()

    def write(self, path, content):
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")

    def write_bytes(self, path, content):
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(content)

    def args(self, *extra):
        return [
            "--lab", "lab1", "--reference-root", str(self.reference),
            "--submissions-root", str(self.submissions), "--cleaned-root", str(self.cleaned),
            *extra,
        ]

    def test_generates_source_only_reports_and_summary(self):
        self.assertEqual(app.main(self.args()), 0)
        report = self.student_cleaned / app.REPORT_FOLDER / "lab1.md"
        summary = self.cleaned / app.SUMMARY_FOLDER / "lab1.md"
        text = report.read_text(encoding="utf-8")
        summary_text = summary.read_text(encoding="utf-8")
        self.assertIn("2406080106", text)
        self.assertIn("kernel/main.c", text)
        self.assertIn("kernel/new.c", text)
        self.assertIn("xv6-user/gone.c", text)
        self.assertIn("kernel/binary.c", text)
        self.assertIn("````diff", text)
        self.assertIn("diff --git 基准/kernel/main.c 学生/kernel/main.c", text)
        self.assertNotIn("doc/guide.md", text)
        self.assertNotIn("target/kernel.asm", text)
        self.assertIn("查看报告", summary_text)
        self.assertEqual((self.student_cleaned / "现有报告.md").read_text(encoding="utf-8"), "keep")

    def test_ignores_whitespace_by_default_and_strict_mode_shows_it(self):
        self.write(self.reference_lab / "kernel" / "space.c", "int  value = 1;\n")
        self.write(self.student_lab / "kernel" / "space.c", "int value = 1;\n")
        self.assertEqual(app.main(self.args()), 0)
        normal = (self.student_cleaned / app.REPORT_FOLDER / "lab1.md").read_text(encoding="utf-8")
        self.assertNotIn("kernel/space.c", normal)
        self.assertEqual(app.main(self.args("--strict-whitespace")), 0)
        strict = (self.student_cleaned / app.REPORT_FOLDER / "lab1.md").read_text(encoding="utf-8")
        self.assertIn("kernel/space.c", strict)

    def test_dry_run_does_not_write_and_missing_cleaned_student_is_summarized(self):
        second = self.submissions / "2406080107-李四-20260909-1215" / "labs" / "lab1" / "kernel" / "main.c"
        self.write(second, "int second;\n")
        self.assertEqual(app.main(self.args("--dry-run")), 0)
        self.assertFalse((self.cleaned / app.SUMMARY_FOLDER).exists())
        self.assertEqual(app.main(self.args()), 0)
        summary = (self.cleaned / app.SUMMARY_FOLDER / "lab1.md").read_text(encoding="utf-8")
        self.assertIn("李四", summary)
        self.assertIn("未找到对应的已清洗学生目录", summary)

    def test_falls_back_to_a_unique_matching_cleaned_name_without_owner_file(self):
        fallback_source = self.submissions / "2406080107-李四-20260909-1215"
        self.write(fallback_source / "labs" / "lab1" / "kernel" / "main.c", "int fallback;\n")
        fallback_cleaned = self.cleaned / "李四"
        fallback_cleaned.mkdir()
        self.assertEqual(app.main(self.args("--student", "2406080107")), 0)
        self.assertTrue((fallback_cleaned / app.REPORT_FOLDER / "lab1.md").is_file())

    def test_does_not_fall_back_by_name_when_submissions_have_duplicate_names(self):
        duplicate = self.submissions / "2406080107-高龙徽-20260909-1215"
        self.write(duplicate / "labs" / "lab1" / "kernel" / "main.c", "int duplicate;\n")
        self.assertEqual(app.main(self.args("--student", "2406080107")), 0)
        summary = (self.cleaned / app.SUMMARY_FOLDER / "lab1.md").read_text(encoding="utf-8")
        self.assertIn("未找到对应的已清洗学生目录", summary)

    def test_handles_git_failure_as_a_per_file_error(self):
        with mock.patch.object(app, "git_diff", return_value=("error", "", 0, 0, "unreadable")):
            self.assertEqual(app.main(self.args()), 1)
        report = (self.student_cleaned / app.REPORT_FOLDER / "lab1.md").read_text(encoding="utf-8")
        self.assertIn("处理异常", report)
        self.assertIn("unreadable", report)


if __name__ == "__main__":
    unittest.main()
