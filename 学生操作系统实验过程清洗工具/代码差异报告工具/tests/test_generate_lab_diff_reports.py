import json
import os
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
        self.write_json(self.student_source / app.SOURCE_MARKER, {
            "version": 1,
            "student_id": "2406080106",
            "name": "高龙徽",
            "archive_name": "2406080106-高龙徽-实验提交-20260909-1215.tar.gz",
            "remote_path": "/remote/20260909/2406080106-高龙徽-实验提交-20260909-1215.tar.gz",
            "submission_time": "2026-09-09T04:15:00Z",
            "archive_size": 123,
            "archive_sha256": "a" * 64,
        })
        self.student_cleaned.mkdir(parents=True)
        self.write_json(self.student_cleaned / app.OWNER_FILE, self.terminal_owner())
        (self.student_cleaned / "现有报告.md").write_text("keep", encoding="utf-8")

    def tearDown(self):
        self.temp.cleanup()

    def write(self, path, content):
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")

    def write_bytes(self, path, content):
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(content)

    def write_json(self, path, value):
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(value, ensure_ascii=False), encoding="utf-8")

    def add_submission_marker(self, source, student_id, name, stamp, sha="d"):
        self.write_json(Path(source) / app.SOURCE_MARKER, {
            "version": 1,
            "student_id": student_id,
            "name": name,
            "archive_name": f"{student_id}-{name}-实验提交-{stamp}.tar.gz",
            "remote_path": f"/remote/{stamp[:8]}/{student_id}-{name}.tar.gz",
            "submission_time": "2026-09-09T04:15:00Z",
            "archive_size": 123,
            "archive_sha256": (sha * 64)[:64],
        })

    def terminal_owner(self, source=None):
        return {
            "tool": "replay_term_qa",
            "source": source or f"{self.submissions.name}/{self.student_source.name}",
            "layout": "dual-view-v2",
            "status": "complete",
            "reports": [],
            "cache_format_version": 2,
            "input_fingerprint": "b" * 64,
            "processor_signature": "c" * 64,
            "summary": {
                "recordings": 1, "commands": 1, "claude_sessions": 0,
                "turns": 0, "replay_failed": 0,
                "labs": {"lab1": {
                    "recordings": 1, "commands": 1,
                    "claude_sessions": 0, "turns": 0, "replay_failed": 0,
                }},
                "errors": [],
            },
            "artifact_sha256": {},
        }

    def report_path(self, lab="lab1"):
        return self.student_cleaned / lab / app.REPORT_FOLDER / app.REPORT_NAME

    def report_manifest_path(self, lab="lab1"):
        return self.report_path(lab).parent / app.REPORT_MANIFEST

    def summary_path(self, lab="lab1"):
        return self.cleaned / app.SUMMARY_FOLDER / f"代码差异报告汇总-{lab}.md"

    def args(self, *extra):
        return [
            "--lab", "lab1", "--reference-root", str(self.reference),
            "--submissions-root", str(self.submissions), "--cleaned-root", str(self.cleaned),
            *extra,
        ]

    def args_labs(self, *labs, extra=()):
        values = []
        for lab in labs:
            values.extend(("--lab", lab))
        return [
            *values, "--reference-root", str(self.reference),
            "--submissions-root", str(self.submissions),
            "--cleaned-root", str(self.cleaned), *extra,
        ]

    def test_generates_source_only_reports_and_summary(self):
        self.assertEqual(app.main(self.args()), 0)
        report = self.report_path()
        mirror = self.cleaned / "按Lab分类" / "lab1" / "高龙徽" / app.REPORT_FOLDER / app.REPORT_NAME
        summary = self.summary_path()
        text = report.read_text(encoding="utf-8")
        summary_text = summary.read_text(encoding="utf-8")
        self.assertEqual(report.read_bytes(), mirror.read_bytes())
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
        self.assertEqual((self.student_cleaned / "现有报告.md").read_text(encoding="utf-8"), "keep")

    def test_ignores_whitespace_by_default_and_strict_mode_shows_it(self):
        self.write(self.reference_lab / "kernel" / "space.c", "int  value = 1;\n\n")
        self.write(self.student_lab / "kernel" / "space.c", "int value = 1;\n \t \n")
        self.assertEqual(app.main(self.args()), 0)
        normal = self.report_path().read_text(encoding="utf-8")
        self.assertNotIn("kernel/space.c", normal)
        self.assertIn("空白符策略：忽略空格、Tab、空白行和行尾空白差异", normal)
        self.assertEqual(app.main(self.args("--strict-whitespace")), 0)
        strict = self.report_path().read_text(encoding="utf-8")
        self.assertIn("kernel/space.c", strict)
        self.assertIn("空白符策略：精确比较", strict)

    def test_second_run_hits_cache_without_git_and_keeps_formal_bytes(self):
        self.assertEqual(app.main(self.args()), 0)
        tracked = (
            self.report_path(),
            self.cleaned / "按Lab分类" / "lab1" / "高龙徽" / app.REPORT_FOLDER / app.REPORT_NAME,
            self.report_manifest_path(),
            self.summary_path(),
        )
        before = {path: path.read_bytes() for path in tracked}

        with mock.patch.object(app, "git_diff", side_effect=AssertionError("cache miss")):
            self.assertEqual(app.main(self.args()), 0)

        self.assertEqual({path: path.read_bytes() for path in tracked}, before)

    def test_corrupt_cache_statistics_are_not_reused(self):
        self.assertEqual(app.main(self.args()), 0)
        cache_entries = list((self.cleaned / app.CACHE_FOLDER / "entries").glob("*.json"))
        self.assertEqual(len(cache_entries), 1)
        cache_path = cache_entries[0]
        document = json.loads(cache_path.read_text(encoding="utf-8"))
        document["entries"] = []
        document["scanned_files"] = 99
        cache_path.write_text(json.dumps(document), encoding="utf-8")

        with mock.patch.object(app, "git_diff", wraps=app.git_diff) as diff:
            self.assertEqual(app.main(self.args()), 0)
        self.assertGreater(diff.call_count, 0)

    def test_partial_cleanup_keeps_unselected_old_schema_entries(self):
        entries_root = self.cleaned / app.CACHE_FOLDER / "entries"
        entries_root.mkdir(parents=True)
        selected = entries_root / "selected.json"
        unselected = entries_root / "unselected.json"
        selected.write_text(json.dumps({
            "cache_owner": app.CACHE_OWNER,
            "schema_version": app.CACHE_SCHEMA_VERSION - 1,
            "lab": "lab1",
        }), encoding="utf-8")
        unselected.write_text(json.dumps({
            "cache_owner": app.CACHE_OWNER,
            "schema_version": app.CACHE_SCHEMA_VERSION - 1,
            "lab": "lab2",
        }), encoding="utf-8")

        removed = app.cleanup_cache(self.cleaned, frozenset({"lab1"}), set())
        self.assertEqual(removed, ["selected.json"])
        self.assertFalse(selected.exists())
        self.assertTrue(unselected.exists())

    def test_render_change_reuses_structured_cache_without_git(self):
        self.assertEqual(app.main(self.args()), 0)
        original_render = app.render_student_report

        def changed_render(result, reference_root, strict_whitespace):
            return original_render(result, reference_root, strict_whitespace).replace(
                f"# {result.lab} 源码差异报告",
                f"# {result.lab} 源码差异报告（模板更新）",
                1,
            )

        with mock.patch.object(app, "RENDER_VERSION", "source-diff-render-v3"), \
             mock.patch.object(app, "render_student_report", side_effect=changed_render), \
             mock.patch.object(app, "git_diff", side_effect=AssertionError("render-only change ran git")):
            self.assertEqual(app.main(self.args()), 0)

        self.assertIn("模板更新", self.report_path().read_text(encoding="utf-8"))

    def test_reference_lab_change_invalidates_only_that_lab_cache(self):
        self.write(self.reference / "lab2" / "kernel" / "main.c", "int lab2 = 1;\n")
        self.write(self.student_source / "labs" / "lab2" / "kernel" / "main.c", "int lab2 = 2;\n")
        labs_args = self.args_labs("lab1", "lab2")
        self.assertEqual(app.main(labs_args), 0)
        cache_entries = list((self.cleaned / app.CACHE_FOLDER / "entries").glob("*.json"))
        self.assertEqual(len(cache_entries), 2)

        self.write(self.reference / "lab2" / "kernel" / "main.c", "int lab2 = 9;\n")
        with mock.patch.object(app, "git_diff", wraps=app.git_diff) as diff:
            self.assertEqual(app.main(labs_args), 0)
        # lab1 remains a complete cache hit; lab2 has one selected source file.
        self.assertEqual(diff.call_count, 1)

    def test_dry_run_does_not_write_and_missing_cleaned_student_is_summarized(self):
        second_source = self.submissions / "2406080107-李四-20260909-1215"
        second = second_source / "labs" / "lab1" / "kernel" / "main.c"
        self.write(second, "int second;\n")
        self.add_submission_marker(second_source, "2406080107", "李四", "20260909-1215")
        self.assertEqual(app.main(self.args("--dry-run")), 0)
        self.assertFalse((self.cleaned / app.SUMMARY_FOLDER).exists())
        self.assertFalse((self.cleaned / app.CACHE_FOLDER).exists())
        self.assertFalse(self.report_path().exists())
        self.assertEqual(app.main(self.args()), 0)
        summary = self.summary_path().read_text(encoding="utf-8")
        self.assertIn("李四", summary)
        self.assertIn("未找到对应的已清洗学生目录", summary)

    def test_does_not_fall_back_to_a_cleaned_name_without_terminal_owner(self):
        fallback_source = self.submissions / "2406080107-李四-20260909-1215"
        self.write(fallback_source / "labs" / "lab1" / "kernel" / "main.c", "int fallback;\n")
        self.add_submission_marker(fallback_source, "2406080107", "李四", "20260909-1215")
        fallback_cleaned = self.cleaned / "按人分类" / "李四"
        fallback_cleaned.mkdir(parents=True)
        self.assertEqual(app.main(self.args("--student", "2406080107")), 0)
        self.assertFalse((fallback_cleaned / "lab1" / app.REPORT_FOLDER / app.REPORT_NAME).exists())

    def test_does_not_fall_back_by_name_when_submissions_have_duplicate_names(self):
        duplicate = self.submissions / "2406080107-高龙徽-20260909-1215"
        self.write(duplicate / "labs" / "lab1" / "kernel" / "main.c", "int duplicate;\n")
        self.add_submission_marker(duplicate, "2406080107", "高龙徽", "20260909-1215")
        self.assertEqual(app.main(self.args("--student", "2406080107")), 0)
        summary = self.summary_path().read_text(encoding="utf-8")
        self.assertIn("未找到对应的已清洗学生目录", summary)

    def test_handles_git_failure_as_a_per_file_error(self):
        self.assertEqual(app.main(self.args()), 0)
        report = self.report_path()
        manifest = self.report_manifest_path()
        previous_report = report.read_text(encoding="utf-8")
        previous_manifest = manifest.read_text(encoding="utf-8")
        with mock.patch.object(app, "git_diff", return_value=("error", "", 0, 0, "unreadable")):
            self.assertEqual(app.main(self.args("--force")), 1)
        self.assertEqual(report.read_text(encoding="utf-8"), previous_report)
        self.assertEqual(manifest.read_text(encoding="utf-8"), previous_manifest)
        summary = self.summary_path().read_text(encoding="utf-8")
        self.assertIn("unreadable", summary)

    def test_manifest_failure_rolls_back_report_and_recovers_next_run(self):
        self.assertEqual(app.main(self.args()), 0)
        report = self.report_path()
        mirror = self.cleaned / "按Lab分类" / "lab1" / "高龙徽" / app.REPORT_FOLDER / app.REPORT_NAME
        manifest = self.report_manifest_path()
        mirror_manifest = mirror.parent / app.REPORT_MANIFEST
        before = {
            path: path.read_bytes()
            for path in (report, mirror, manifest, mirror_manifest)
        }

        # Force a new report body, then fail only when the ownership manifest
        # is published. The transaction must restore every formal artifact.
        self.write(self.student_lab / "kernel" / "main.c", "int value = 9;\n")
        original_write_text_pair = app.write_text_pair

        def fail_manifest(path, text):
            if Path(path).name == app.REPORT_MANIFEST:
                raise OSError("injected manifest failure")
            return original_write_text_pair(path, text)

        with mock.patch.object(app, "write_text_pair", side_effect=fail_manifest):
            self.assertEqual(app.main(self.args("--force")), 1)

        for path, content in before.items():
            self.assertEqual(path.read_bytes(), content)

        # The failed publication must not strand an unregistered new report;
        # a subsequent normal run can publish the same changed input.
        self.assertEqual(app.main(self.args()), 0)
        self.assertIn("int value = 9", report.read_text(encoding="utf-8"))

    def test_manifest_failure_restores_existing_report_pair_and_manifest(self):
        self.assertEqual(app.main(self.args()), 0)
        report = self.report_path()
        mirror = self.cleaned / "按Lab分类" / "lab1" / "高龙徽" / app.REPORT_FOLDER / app.REPORT_NAME
        manifest = self.report_manifest_path()
        mirror_manifest = mirror.parent / app.REPORT_MANIFEST
        cache_files = sorted((self.cleaned / app.CACHE_FOLDER / "entries").glob("*.json"))
        previous = {
            report: report.read_bytes(),
            mirror: mirror.read_bytes(),
            manifest: manifest.read_bytes(),
            mirror_manifest: mirror_manifest.read_bytes(),
            **{path: path.read_bytes() for path in cache_files},
        }

        self.write(self.student_lab / "kernel" / "main.c", "int value = 99;\n")
        with mock.patch.object(
            app, "update_student_report_manifest", side_effect=OSError("manifest blocked")
        ):
            self.assertEqual(app.main(self.args("--force")), 1)

        self.assertEqual({path: path.read_bytes() for path in previous}, previous)
        self.assertIn("manifest blocked", self.summary_path().read_text(encoding="utf-8"))

    def test_manifest_failure_removes_first_publish_and_next_run_recovers(self):
        with mock.patch.object(
            app, "update_student_report_manifest", side_effect=OSError("manifest blocked")
        ):
            self.assertEqual(app.main(self.args()), 1)

        report = self.report_path()
        mirror = self.cleaned / "按Lab分类" / "lab1" / "高龙徽" / app.REPORT_FOLDER / app.REPORT_NAME
        self.assertFalse(report.exists())
        self.assertFalse(mirror.exists())
        self.assertFalse(self.report_manifest_path().exists())
        self.assertFalse((mirror.parent / app.REPORT_MANIFEST).exists())

        self.assertEqual(app.main(self.args()), 0)
        self.assertTrue(report.is_file())
        self.assertTrue(mirror.is_file())
        self.assertTrue(self.report_manifest_path().is_file())

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
        text = self.report_path().read_text(encoding="utf-8")
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
        self.assertFalse(self.report_path().exists())
        summary = self.summary_path().read_text(encoding="utf-8")
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
        target = report_dir / "lab1.md"

        with mock.patch.object(
            app, "is_link_like", side_effect=lambda path: Path(path) == report_dir
        ):
            with self.assertRaisesRegex(ValueError, "拒绝覆盖符号链接"):
                app.atomic_write(target, "new report")

        self.assertFalse(report_dir.exists())
        self.assertFalse(target.exists())

    def test_summary_write_value_error_returns_failure(self):
        summary = self.summary_path()
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
        document = json.loads(manifest.read_text(encoding="utf-8"))
        self.assertEqual(document["artifacts"], [])
        summary = self.summary_path().read_text(encoding="utf-8")
        self.assertIn("未找到学生该实验的 labs/labN 目录", summary)

    def test_missing_lab_is_cached_and_reused_without_git(self):
        self.assertEqual(app.main(self.args()), 0)
        shutil.rmtree(self.student_lab)

        self.assertEqual(app.main(self.args()), 0)
        cache_entries = list((self.cleaned / app.CACHE_FOLDER / "entries").glob("*.json"))
        self.assertEqual(len(cache_entries), 1)
        cache_path = cache_entries[0]
        missing_document = json.loads(cache_path.read_text(encoding="utf-8"))
        self.assertEqual(missing_document["status"], "跳过")
        self.assertTrue(missing_document["missing_lab"])
        self.assertEqual(
            missing_document["source_fingerprint"], app.MISSING_LAB_FINGERPRINT
        )
        before = cache_path.read_bytes()
        summary_before = self.summary_path().read_bytes()

        with mock.patch.object(app, "git_diff", side_effect=AssertionError("missing cache miss")):
            self.assertEqual(app.main(self.args()), 0)

        self.assertEqual(cache_path.read_bytes(), before)
        self.assertEqual(self.summary_path().read_bytes(), summary_before)
        summary = self.summary_path().read_text(encoding="utf-8")
        self.assertIn("| 2406080106 | 高龙徽 | 跳过 | CACHED |", summary)

    def test_strict_git_options_do_not_advertise_ignored_whitespace(self):
        self.assertNotIn("--ignore-space-change", app.git_diff_options(True))
        self.assertNotIn("--ignore-space-at-eol", app.git_diff_options(True))
        self.assertNotIn("--ignore-blank-lines", app.git_diff_options(True))
        self.assertIn("--ignore-space-change", app.git_diff_options(False))

    def test_unregistered_lab_report_is_not_claimed_or_removed(self):
        report_dir = self.student_cleaned / "lab1" / app.REPORT_FOLDER
        report_dir.mkdir(parents=True)
        preserved = report_dir / "manual.md"
        preserved.write_text("keep lab2", encoding="utf-8")
        self.write(self.reference / "lab2" / "kernel" / "main.c", "int lab2;\n")

        self.assertEqual(app.main(self.args()), 0)
        manifest = report_dir / app.REPORT_MANIFEST
        self.assertEqual(
            json.loads(manifest.read_text(encoding="utf-8"))["artifacts"],
            [app.REPORT_NAME],
        )
        self.assertEqual(preserved.read_text(encoding="utf-8"), "keep lab2")

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
        summary = self.summary_path().read_text(encoding="utf-8")
        self.assertIn("原始提交目录不存在或无法匹配", summary)
        self.assertIn("2406080106", summary)

    def test_unmatched_student_filter_fails_without_writing_reports(self):
        self.assertEqual(app.main(self.args("--student", "not-a-student")), 1)
        self.assertFalse((self.student_cleaned / "lab1" / app.REPORT_FOLDER).exists())
        self.assertFalse((self.cleaned / app.SUMMARY_FOLDER).exists())


class CurrentSubmissionContractTests(unittest.TestCase):
    """Regression coverage for the synchronizer/terminal-cleaner boundary.

    These tests deliberately use the complete upstream marker shapes.  The
    diff tool must never infer a current submission from a directory name when
    the synchronizer marker is absent, malformed, or ambiguous.
    """

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.reference = self.root / "reference"
        self.submissions = self.root / "submissions"
        self.cleaned = self.root / "cleaned"
        self.student_name = "2406080106-高龙徽-20260909-1215"
        self.student_source = self.submissions / self.student_name
        self.write(self.reference / "lab1" / "kernel" / "main.c", "int value = 1;\n")
        self.write(self.student_source / "labs" / "lab1" / "kernel" / "main.c", "int value = 2;\n")
        self.marker = {
            "version": 1,
            "student_id": "2406080106",
            "name": "高龙徽",
            "archive_name": "2406080106-高龙徽-实验提交-20260909-1215.tar.gz",
            "remote_path": "/remote/20260909/2406080106-高龙徽-实验提交-20260909-1215.tar.gz",
            "submission_time": "2026-09-09T04:15:00Z",
            "archive_size": 123,
            "archive_sha256": "a" * 64,
        }
        self.write_json(self.student_source / app.SOURCE_MARKER, self.marker)
        self.cleaned_student = self.cleaned / "按人分类" / "高龙徽"
        self.cleaned_student.mkdir(parents=True)
        self.owner = {
            "tool": "replay_term_qa",
            "source": f"{self.submissions.name}/{self.student_name}",
            "layout": "dual-view-v2",
            "status": "complete",
            "reports": [],
            "cache_format_version": 2,
            "input_fingerprint": "b" * 64,
            "processor_signature": "c" * 64,
            "summary": {
                "recordings": 1,
                "commands": 1,
                "claude_sessions": 0,
                "turns": 0,
                "replay_failed": 0,
                "labs": {"lab1": {
                    "recordings": 1,
                    "commands": 1,
                    "claude_sessions": 0,
                    "turns": 0,
                    "replay_failed": 0,
                }},
                "errors": [],
            },
            "artifact_sha256": {},
        }
        self.write_json(self.cleaned_student / app.OWNER_FILE, self.owner)

    def tearDown(self):
        self.temp.cleanup()

    @staticmethod
    def write(path, content):
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")

    @staticmethod
    def write_json(path, value):
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(value, ensure_ascii=False), encoding="utf-8")

    def test_scan_requires_valid_sync_marker_and_rejects_duplicate_ids(self):
        # A second valid current directory for the same ID is ambiguous even
        # when its name and marker are otherwise internally consistent.
        duplicate_name = "2406080106-另一份-20260910-1200"
        duplicate = self.submissions / duplicate_name
        duplicate_marker = dict(self.marker)
        duplicate_marker.update({
            "name": "另一份",
            "archive_name": "2406080106-另一份-实验提交-20260910-1200.tar.gz",
        })
        self.write_json(duplicate / app.SOURCE_MARKER, duplicate_marker)

        missing = self.submissions / "2406080111-缺标记-20260909-1215"
        missing.mkdir(parents=True)
        invalid = self.submissions / "2406080112-坏标记-20260909-1215"
        self.write_json(invalid / app.SOURCE_MARKER, {"version": 1})

        students, skipped = app.scan_students(self.submissions, [])

        self.assertEqual(students, [])
        diagnostics = "\n".join(skipped)
        self.assertIn("学号 2406080106 存在多个当前提交目录", diagnostics)
        self.assertIn("2406080111-缺标记", diagnostics)
        self.assertIn("2406080112-坏标记", diagnostics)

    def test_relative_terminal_owner_maps_from_non_repository_cwd(self):
        students, skipped = app.scan_students(self.submissions, [])
        self.assertEqual(skipped, [])
        self.assertEqual(len(students), 1)

        previous = Path.cwd()
        foreign_cwd = self.root / "launched-from-elsewhere"
        foreign_cwd.mkdir()
        try:
            os.chdir(foreign_cwd)
            app.map_cleaned_students(students, self.cleaned, self.submissions)
        finally:
            os.chdir(previous)

        self.assertEqual(students[0].cleaned, self.cleaned_student)

    def test_structured_cache_hit_is_invalidated_by_archive_or_source_fingerprint(self):
        students, skipped = app.scan_students(self.submissions, [])
        self.assertEqual((len(students), skipped), (1, []))
        student = students[0]
        student.cleaned = self.cleaned_student
        student_snapshot = app.snapshot_for_lab(student.source / "labs", "lab1")
        reference_snapshot = app.snapshot_for_lab(self.reference, "lab1")
        analyzer = app.analyzer_signature(False, version="git-test")
        result = app.compare_lab(
            student,
            "lab1",
            self.reference,
            False,
            student_snapshot=student_snapshot,
            reference_snapshot=reference_snapshot,
            analyzer_sig=analyzer,
        )
        self.assertEqual(result.status, "成功")
        document = app.cache_document(
            result,
            student_snapshot,
            reference_snapshot,
            False,
            analyzer,
            app.render_signature(),
            app.render_student_report(result, self.reference, False),
        )

        with mock.patch.object(app, "git_diff", side_effect=AssertionError("cache called git")):
            hit = app.result_from_cache(
                document,
                student,
                "lab1",
                student_snapshot,
                reference_snapshot,
                False,
                analyzer,
                app.render_signature(),
            )
        self.assertIsNotNone(hit)
        self.assertEqual(hit.cache_state, "CACHED")

        student.archive_sha256 = "d" * 64
        self.assertIsNone(app.result_from_cache(
            document, student, "lab1", student_snapshot, reference_snapshot,
            False, analyzer, app.render_signature(),
        ))
        student.archive_sha256 = self.marker["archive_sha256"]
        self.write(
            student.source / "labs" / "lab1" / "kernel" / "main.c",
            "int value = 3;\n",
        )
        changed_snapshot = app.snapshot_for_lab(student.source, "lab1")
        self.assertNotEqual(changed_snapshot.fingerprint, student_snapshot.fingerprint)
        self.assertIsNone(app.result_from_cache(
            document, student, "lab1", changed_snapshot, reference_snapshot,
            False, analyzer, app.render_signature(),
        ))


if __name__ == "__main__":
    unittest.main()
