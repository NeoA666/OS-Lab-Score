import json
import shutil
import tempfile
from types import SimpleNamespace
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
        self.student_cleaned = self.cleaned / "按人分类" / "高龙徽"
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
        report = self.student_cleaned / "lab1" / app.REPORT_FOLDER / app.REPORT_NAME
        summary = self.cleaned / app.SUMMARY_FOLDER / "代码差异报告汇总-lab1.md"
        text = report.read_text(encoding="utf-8")
        summary_text = summary.read_text(encoding="utf-8")
        self.assertIn("2406080106", text)
        self.assertIn("kernel/main.c", text)
        self.assertIn("kernel/new.c", text)
        self.assertIn("xv6-user/gone.c", text)
        self.assertIn("### `Makefile`（修改）", text)
        self.assertIn("kernel/binary.c", text)
        self.assertIn("````diff", text)
        self.assertIn("diff --git 基准/kernel/main.c 学生/kernel/main.c", text)
        self.assertNotIn("doc/guide.md", text)
        self.assertNotIn("target/kernel.asm", text)
        self.assertIn("查看报告", summary_text)
        self.assertEqual(report.read_bytes(), app.mirror_path(report).read_bytes())
        self.assertTrue(list((self.cleaned / "运行日志").glob("代码差异报告工具-*.log")))
        self.assertEqual((self.student_cleaned / "现有报告.md").read_text(encoding="utf-8"), "keep")

    def test_unregistered_mirror_is_not_overwritten(self):
        report = self.student_cleaned / "lab1" / app.REPORT_FOLDER / app.REPORT_NAME
        mirrored = app.mirror_path(report)
        self.write(mirrored, "人工保留")
        self.assertEqual(app.main(self.args()), 1)
        self.assertEqual(mirrored.read_text(encoding="utf-8"), "人工保留")
        self.assertFalse(report.exists())

    def test_mirror_write_failure_is_reported(self):
        with mock.patch.object(app, "write_text_pair", side_effect=OSError("镜像写入失败")):
            self.assertEqual(app.main(self.args()), 1)
        summary = self.cleaned / app.SUMMARY_FOLDER / "代码差异报告汇总-lab1.md"
        self.assertIn("镜像写入失败", summary.read_text(encoding="utf-8"))

    def test_lab0_is_in_scope_and_compares_against_the_reference_lab0(self):
        # 回归：比较范围必须从 lab0 开始，且 lab0 与其它实验使用同一套
        # “学生 labs/labN 对比基准 labN”的对应规则。
        self.assertEqual(app.LABS, tuple(f"lab{number}" for number in range(0, 9)))
        self.assertIn(app.REPORT_NAME, app.REPORT_ARTIFACTS)
        self.write(self.reference / "lab0" / "kernel" / "main.c", "int base = 1;\n")
        self.write(self.student_source / "labs" / "lab0" / "kernel" / "main.c", "int base = 2;\n")
        self.assertEqual(app.main([
            "--lab", "lab0", "--reference-root", str(self.reference),
            "--submissions-root", str(self.submissions), "--cleaned-root", str(self.cleaned),
        ]), 0)
        report = self.student_cleaned / "lab0" / app.REPORT_FOLDER / app.REPORT_NAME
        self.assertTrue(report.is_file())
        text = report.read_text(encoding="utf-8")
        self.assertIn("# lab0 源码差异报告", text)
        self.assertIn(str(self.reference / "lab0"), text)
        self.assertIn("kernel/main.c", text)
        summary = (self.cleaned / app.SUMMARY_FOLDER / "代码差异报告汇总-lab0.md").read_text(encoding="utf-8")
        self.assertIn("# lab0 源码差异报告汇总", summary)
        self.assertIn("查看报告", summary)
        manifest = json.loads(
            (self.student_cleaned / "lab0" / app.REPORT_FOLDER / app.REPORT_MANIFEST).read_text(encoding="utf-8")
        )
        self.assertEqual(manifest["artifacts"], [app.REPORT_NAME])

    def test_ignores_whitespace_by_default_and_strict_mode_shows_it(self):
        self.write(self.reference_lab / "kernel" / "space.c", "int  value = 1;\n\n")
        self.write(self.student_lab / "kernel" / "space.c", "int value = 1;\n \t \n")
        self.assertEqual(app.main(self.args()), 0)
        normal = (self.student_cleaned / "lab1" / app.REPORT_FOLDER / app.REPORT_NAME).read_text(encoding="utf-8")
        self.assertNotIn("kernel/space.c", normal)
        self.assertIn("空白符策略：忽略空格、Tab、空白行和行尾空白差异", normal)
        self.assertEqual(app.main(self.args("--strict-whitespace")), 0)
        strict = (self.student_cleaned / "lab1" / app.REPORT_FOLDER / app.REPORT_NAME).read_text(encoding="utf-8")
        self.assertIn("kernel/space.c", strict)
        self.assertIn("空白符策略：精确比较", strict)

    def test_dry_run_does_not_write_and_missing_cleaned_student_is_summarized(self):
        second = self.submissions / "2406080107-李四-20260909-1215" / "labs" / "lab1" / "kernel" / "main.c"
        self.write(second, "int second;\n")
        self.assertEqual(app.main(self.args("--dry-run")), 0)
        self.assertFalse((self.cleaned / app.SUMMARY_FOLDER).exists())
        self.assertEqual(app.main(self.args()), 0)
        summary = (self.cleaned / app.SUMMARY_FOLDER / "代码差异报告汇总-lab1.md").read_text(encoding="utf-8")
        self.assertIn("李四", summary)
        self.assertIn("未找到对应的已清洗学生目录", summary)

    def test_falls_back_to_a_unique_matching_cleaned_name_without_owner_file(self):
        fallback_source = self.submissions / "2406080107-李四-20260909-1215"
        self.write(fallback_source / "labs" / "lab1" / "kernel" / "main.c", "int fallback;\n")
        fallback_cleaned = self.cleaned / "按人分类" / "李四"
        fallback_cleaned.mkdir()
        self.assertEqual(app.main(self.args("--student", "2406080107")), 0)
        self.assertTrue((fallback_cleaned / "lab1" / app.REPORT_FOLDER / app.REPORT_NAME).is_file())

    def test_does_not_fall_back_by_name_when_submissions_have_duplicate_names(self):
        duplicate = self.submissions / "2406080107-高龙徽-20260909-1215"
        self.write(duplicate / "labs" / "lab1" / "kernel" / "main.c", "int duplicate;\n")
        self.assertEqual(app.main(self.args("--student", "2406080107")), 0)
        summary = (self.cleaned / app.SUMMARY_FOLDER / "代码差异报告汇总-lab1.md").read_text(encoding="utf-8")
        self.assertIn("未找到对应的已清洗学生目录", summary)

    def test_handles_git_failure_as_a_per_file_error(self):
        self.assertEqual(app.main(self.args()), 0)
        report = self.student_cleaned / "lab1" / app.REPORT_FOLDER / app.REPORT_NAME
        manifest = self.student_cleaned / "lab1" / app.REPORT_FOLDER / app.REPORT_MANIFEST
        previous_report = report.read_text(encoding="utf-8")
        previous_manifest = manifest.read_text(encoding="utf-8")
        with mock.patch.object(app, "git_diff", return_value=("error", "", 0, 0, "unreadable")):
            self.assertEqual(app.main(self.args()), 1)
        self.assertEqual(report.read_text(encoding="utf-8"), previous_report)
        self.assertEqual(manifest.read_text(encoding="utf-8"), previous_manifest)
        summary = (self.cleaned / app.SUMMARY_FOLDER / "代码差异报告汇总-lab1.md").read_text(encoding="utf-8")
        self.assertIn("unreadable", summary)

    def test_empty_git_patch_is_a_per_file_error(self):
        completed = SimpleNamespace(returncode=1, stdout="", stderr="empty patch")
        with mock.patch.object(app.subprocess, "run", return_value=completed):
            status, patch, additions, deletions, message = app.git_diff(
                "kernel/main.c", None, None, strict_whitespace=True
            )
        self.assertEqual((status, patch, additions, deletions, message),
                         ("error", "", 0, 0, "empty patch"))

    def test_add_delete_diff_uses_git_empty_path_and_keeps_line_counts(self):
        added = self.student_lab / "kernel" / "新增 文件.c"
        deleted = self.reference_lab / "xv6-user" / "删除 文件.c"
        self.write(added, "++new;\n")
        self.write(deleted, "--old;\n")

        status, patch, additions, deletions, message = app.git_diff(
            "kernel/新增 文件.c", None, added, strict_whitespace=True
        )
        self.assertEqual((status, additions, deletions, message), ("modified", 1, 0, ""))
        self.assertIn("--- /dev/null", patch)
        self.assertIn("+++ 学生/kernel/新增 文件.c", patch)

        status, patch, additions, deletions, message = app.git_diff(
            "xv6-user/删除 文件.c", deleted, None, strict_whitespace=True
        )
        self.assertEqual((status, additions, deletions, message), ("modified", 0, 1, ""))
        self.assertIn("--- 基准/xv6-user/删除 文件.c", patch)
        self.assertIn("+++ /dev/null", patch)

    def test_scope_includes_root_makefiles_and_excludes_generated_and_vcs_files(self):
        self.write(self.reference_lab / "GNUmakefile", "all:\n\t@echo old\n")
        self.write(self.student_lab / "GNUmakefile", "all:\n\t@echo new\n")
        self.write(self.reference_lab / "kernel" / "manual.S", "old\n")
        self.write(self.student_lab / "kernel" / "manual.S", "new\n")
        self.write(self.reference_lab / "xv6-user" / "usys.S", "generated old\n")
        self.write(self.student_lab / "xv6-user" / "usys.S", "generated new\n")
        self.write(self.reference_lab / "kernel" / ".git" / "hooks" / "ignored.sh", "old\n")
        self.write(self.student_lab / "kernel" / ".git" / "hooks" / "ignored.sh", "new\n")
        self.write(self.reference_lab / "kernel" / ".hg" / "ignored.py", "old\n")
        self.write(self.student_lab / "kernel" / ".hg" / "ignored.py", "new\n")
        self.write(self.reference_lab / "kernel" / ".svn" / "ignored.mk", "old\n")
        self.write(self.student_lab / "kernel" / ".svn" / "ignored.mk", "new\n")

        self.assertEqual(app.main(self.args()), 0)
        text = (self.student_cleaned / "lab1" / app.REPORT_FOLDER / app.REPORT_NAME).read_text(encoding="utf-8")
        self.assertIn("### `Makefile`（修改）", text)
        self.assertIn("### `GNUmakefile`（修改）", text)
        self.assertIn("kernel/manual.S", text)
        self.assertNotIn("xv6-user/usys.S", text)
        self.assertNotIn("ignored.sh", text)
        self.assertNotIn("ignored.py", text)
        self.assertNotIn("ignored.mk", text)

    def test_owner_manifest_requires_the_full_submission_path(self):
        unrelated = self.root / "unrelated" / self.student_source.name
        self.student_cleaned.joinpath(app.OWNER_FILE).write_text(
            json.dumps({"source": str(unrelated)}), encoding="utf-8"
        )
        students, skipped = app.scan_students(self.submissions, [])
        self.assertEqual(skipped, [])
        app.map_cleaned_students(students, self.cleaned)
        self.assertTrue(all(student.cleaned is None for student in students))
        self.assertEqual(app.main(self.args()), 0)
        self.assertFalse((self.student_cleaned / "lab1" / app.REPORT_FOLDER / app.REPORT_NAME).exists())
        summary = (self.cleaned / app.SUMMARY_FOLDER / "代码差异报告汇总-lab1.md").read_text(encoding="utf-8")
        self.assertIn("未找到对应的已清洗学生目录", summary)

    def test_foreign_or_malformed_report_manifest_is_rejected_before_writing(self):
        report_dir = self.student_cleaned / "lab1" / app.REPORT_FOLDER
        report_dir.mkdir(parents=True)
        report = report_dir / app.REPORT_NAME
        report.write_text("keep", encoding="utf-8")
        manifest = report_dir / app.REPORT_MANIFEST
        for document in (
            json.dumps({"tool": "generate_lab_diff_reports", "source": "other", "artifacts": [app.REPORT_NAME]}),
            "{broken",
        ):
            manifest.write_text(document, encoding="utf-8")
            self.assertEqual(app.main(self.args()), 1)
            self.assertEqual(report.read_text(encoding="utf-8"), "keep")
            self.assertEqual(manifest.read_text(encoding="utf-8"), document)

    def test_link_like_report_manifest_is_rejected_before_writing(self):
        report_dir = self.student_cleaned / "lab1" / app.REPORT_FOLDER
        report_dir.mkdir(parents=True)
        report = report_dir / app.REPORT_NAME
        report.write_text("keep", encoding="utf-8")
        manifest = report_dir / app.REPORT_MANIFEST

        with mock.patch.object(
            app, "is_link_like", side_effect=lambda path: Path(path) == manifest
        ):
            self.assertEqual(app.main(self.args()), 1)
        self.assertEqual(report.read_text(encoding="utf-8"), "keep")

    def test_atomic_write_rejects_link_like_parent_before_creating_it(self):
        report_dir = self.student_cleaned / "dangling-junction"
        target = report_dir / app.REPORT_NAME

        with mock.patch.object(
            app, "is_link_like", side_effect=lambda path: Path(path) == report_dir
        ):
            with self.assertRaisesRegex(ValueError, "拒绝覆盖符号链接"):
                app.atomic_write(target, "new report")

        self.assertFalse(report_dir.exists())
        self.assertFalse(target.exists())

    def test_summary_write_value_error_returns_failure(self):
        summary = self.cleaned / app.SUMMARY_FOLDER / "代码差异报告汇总-lab1.md"
        original_write = app.atomic_write

        def reject_summary(path, text):
            if Path(path) == summary:
                raise ValueError("summary target rejected")
            return original_write(path, text)

        with mock.patch.object(app, "atomic_write", side_effect=reject_summary):
            self.assertEqual(app.main(self.args()), 1)

    def test_binary_scan_and_diff_count_cover_late_nul_and_code_prefixes(self):
        late_nul = self.root / "late-nul.c"
        self.write_bytes(late_nul, b"x" * 9000 + b"\0")
        self.assertTrue(app.looks_binary(late_nul))
        patch = "--- before\n+++ after\n++new;\n--old;\n"
        self.assertEqual(app.diff_line_counts(patch), (1, 1))

    def test_windows_reparse_point_is_link_like_without_path_is_junction(self):
        reparse_point = 0x400
        with mock.patch.object(Path, "is_symlink", return_value=False), \
             mock.patch.object(Path, "is_junction", return_value=False, create=True), \
             mock.patch.object(app.os, "lstat", return_value=SimpleNamespace(
                 st_file_attributes=reparse_point
             )), \
             mock.patch.object(app.stat, "FILE_ATTRIBUTE_REPARSE_POINT", reparse_point, create=True):
            self.assertTrue(app.is_link_like(self.root / "junction"))

    def test_selected_missing_lab_removes_only_its_owned_stale_report(self):
        self.assertEqual(app.main(self.args()), 0)
        report_dir = self.student_cleaned / "lab1" / app.REPORT_FOLDER
        report = report_dir / app.REPORT_NAME
        manifest = report_dir / app.REPORT_MANIFEST
        self.assertTrue(report.is_file())
        self.assertTrue(manifest.is_file())

        shutil.rmtree(self.student_lab)
        self.assertEqual(app.main(self.args()), 0)
        self.assertFalse(report.exists())
        self.assertFalse(app.mirror_path(report).exists())
        document = json.loads(manifest.read_text(encoding="utf-8"))
        self.assertEqual(document["artifacts"], [])
        summary = (self.cleaned / app.SUMMARY_FOLDER / "代码差异报告汇总-lab1.md").read_text(encoding="utf-8")
        self.assertIn("未找到学生该实验的 labs/labN 目录", summary)

    def test_unregistered_lab_report_is_not_claimed_or_removed(self):
        report_dir = self.student_cleaned / "lab1" / app.REPORT_FOLDER
        report_dir.mkdir(parents=True)
        preserved = report_dir / "lab2.md"
        preserved.write_text("keep lab2", encoding="utf-8")
        self.write(self.reference / "lab2" / "kernel" / "main.c", "int lab2;\n")

        self.assertEqual(app.main(self.args()), 0)
        manifest = report_dir / app.REPORT_MANIFEST
        self.assertEqual(
            json.loads(manifest.read_text(encoding="utf-8"))["artifacts"],
            [app.REPORT_NAME],
        )

        self.assertEqual(app.main([
            "--lab", "lab2", "--reference-root", str(self.reference),
            "--submissions-root", str(self.submissions), "--cleaned-root", str(self.cleaned),
        ]), 0)
        self.assertEqual(preserved.read_text(encoding="utf-8"), "keep lab2")
        self.assertEqual(
            json.loads(manifest.read_text(encoding="utf-8"))["artifacts"],
            [app.REPORT_NAME],
        )

    def test_unregistered_selected_lab_report_is_not_overwritten(self):
        report_dir = self.student_cleaned / "lab1" / app.REPORT_FOLDER
        report_dir.mkdir(parents=True)
        manual = report_dir / app.REPORT_NAME
        manual.write_text("keep lab1", encoding="utf-8")

        self.assertEqual(app.main(self.args()), 1)

        self.assertEqual(manual.read_text(encoding="utf-8"), "keep lab1")
        self.assertFalse((report_dir / app.REPORT_MANIFEST).exists())

    def test_missing_submission_with_owned_reports_fails_without_deleting_them(self):
        self.assertEqual(app.main(self.args()), 0)
        report_dir = self.student_cleaned / "lab1" / app.REPORT_FOLDER
        report = report_dir / app.REPORT_NAME
        manifest = report_dir / app.REPORT_MANIFEST
        previous_report = report.read_text(encoding="utf-8")
        previous_manifest = manifest.read_text(encoding="utf-8")

        shutil.rmtree(self.student_source)
        self.assertEqual(app.main(self.args()), 1)
        self.assertEqual(report.read_text(encoding="utf-8"), previous_report)
        self.assertEqual(manifest.read_text(encoding="utf-8"), previous_manifest)
        summary = (self.cleaned / app.SUMMARY_FOLDER / "代码差异报告汇总-lab1.md").read_text(encoding="utf-8")
        self.assertIn("原始提交目录不存在或无法匹配", summary)
        self.assertIn("2406080106", summary)

    def test_unmatched_student_filter_fails_without_writing_reports(self):
        self.assertEqual(app.main(self.args("--student", "not-a-student")), 1)
        self.assertFalse((self.student_cleaned / "lab1" / app.REPORT_FOLDER).exists())
        self.assertFalse((self.cleaned / app.SUMMARY_FOLDER).exists())


if __name__ == "__main__":
    unittest.main()
