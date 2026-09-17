"""End-to-end checks for student-level incremental processing."""
import contextlib
import gzip
import hashlib
import io
import json
import os
from pathlib import Path
import shutil
import tempfile
import unittest
from unittest import mock

import replay_term_qa as app
import timeline_alignment
import timeline_reports


PROMPT = "\x1b[01;32mailab-os@ailab-os-VMware-Virtual-Platform\x1b[00m:\x1b[01;34m~/lab0\x1b[00m$ "


def write_recording(student, name="session", timing=True):
    term = student / "term"
    term.mkdir(parents=True, exist_ok=True)
    chunks = [PROMPT + "echo incremental\r\n", "incremental\r\n"]
    encoded = [chunk.encode("utf-8") for chunk in chunks]
    header = b'Script started on 2026-09-10 22:21:12+08:00 [COLUMNS="80" LINES="24"]\n'
    out = term / f"{name}.out.gz"
    out.write_bytes(gzip.compress(header + b"".join(encoded)))
    tim = term / f"{name}.tim.gz"
    if timing:
        tim.write_bytes(gzip.compress("".join(
            f"0.1 {len(chunk)}\n" for chunk in encoded
        ).encode("ascii")))
    return out, tim


class IncrementalProcessingTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(dir=Path(__file__).parent)
        self.root = Path(self.temporary.name)
        self.input = self.root / "输入"
        self.output = self.root / "输出"
        self.student = self.input / "123-测试-20260910-2221"
        write_recording(self.student)

    def tearDown(self):
        self.temporary.cleanup()

    def run_app(self, *args):
        with contextlib.redirect_stdout(io.StringIO()):
            return app.main([str(self.input), "-o", str(self.output), *args])

    def invoke_with_counts(self, *args):
        with mock.patch.object(app, "process_student", wraps=app.process_student) as reports:
            with mock.patch.object(
                timeline_alignment, "build_student_timeline", wraps=timeline_alignment.build_student_timeline
            ) as timelines:
                code = self.run_app(*args)
        return code, reports, timelines

    def student_output(self, name="测试"):
        return self.output / name

    @staticmethod
    def hashes(root):
        return {
            path.relative_to(root).as_posix(): hashlib.sha256(path.read_bytes()).hexdigest()
            for path in root.rglob("*") if path.is_file()
        }

    @staticmethod
    def report_hashes(root):
        return {
            path.relative_to(root).as_posix(): hashlib.sha256(path.read_bytes()).hexdigest()
            for path in root.rglob("*.md")
            if timeline_reports.TIMELINE_DIRECTORY not in path.parts
        }

    def test_second_run_skips_both_stages_and_restores_summary(self):
        code, reports, timelines = self.invoke_with_counts()
        self.assertEqual(code, 0)
        self.assertEqual(reports.call_count, 1)
        self.assertEqual(timelines.call_count, 1)
        student_out = self.student_output()
        report_manifest = json.loads((student_out / app.OWNER_FILE).read_text(encoding="utf-8"))
        timeline_manifest = json.loads((student_out / timeline_reports.TIMELINE_DIRECTORY /
                                        timeline_reports.TIMELINE_MANIFEST).read_text(encoding="utf-8"))
        for manifest, cache_version in ((report_manifest, app.INCREMENTAL_CACHE_FORMAT_VERSION),
                                        (timeline_manifest, timeline_reports.TIMELINE_CACHE_FORMAT_VERSION)):
            self.assertEqual(manifest["status"], "complete")
            self.assertEqual(manifest["cache_format_version"], cache_version)
            self.assertTrue(manifest["input_fingerprint"])
            self.assertTrue(manifest["processor_signature"])
            self.assertIn("summary", manifest)
        before = self.hashes(student_out)
        code, reports, timelines = self.invoke_with_counts()
        self.assertEqual(code, 0)
        self.assertEqual(reports.call_count, 0)
        self.assertEqual(timelines.call_count, 0)
        self.assertEqual(before, self.hashes(student_out))
        readme = (self.output / "README.md").read_text(encoding="utf-8")
        self.assertIn("报告阶段增量跳过：1", readme)
        self.assertIn("时间线阶段增量跳过：1", readme)
        self.assertIn("终端录像数：1", readme)

    def test_cached_report_warning_remains_in_root_readme(self):
        (self.student / "term" / "session.tim.gz").unlink()
        self.assertEqual(self.run_app(), 0)
        warning = "计时文件缺失、为空、损坏或未覆盖完整录像"
        self.assertIn(warning, (self.output / "README.md").read_text(encoding="utf-8"))

        code, reports, timelines = self.invoke_with_counts()
        self.assertEqual(code, 0)
        self.assertEqual((reports.call_count, timelines.call_count), (0, 0))
        self.assertIn(warning, (self.output / "README.md").read_text(encoding="utf-8"))

    def test_timeline_only_failure_reason_is_rendered_to_root_readme(self):
        with mock.patch.object(app, "write_student_timeline", side_effect=ValueError("timeline write failed")):
            self.assertEqual(self.run_app("--timeline-only"), 1)
        readme = (self.output / "README.md").read_text(encoding="utf-8")
        self.assertIn("时间线异常详情", readme)
        self.assertIn("timeline write failed", readme)

    def test_missing_recording_clears_owned_timeline_and_reports_cleanup_failure(self):
        self.assertEqual(self.run_app(), 0)
        student_out = self.student_output()
        (self.student / "term" / "session.out.gz").unlink()
        (self.student / "term" / "session.tim.gz").unlink()

        self.assertEqual(self.run_app("--timeline-only"), 1)
        timeline_dir = student_out / timeline_reports.TIMELINE_DIRECTORY
        manifest = json.loads((timeline_dir / timeline_reports.TIMELINE_MANIFEST).read_text(encoding="utf-8"))
        self.assertEqual(manifest["status"], "cleared")
        self.assertFalse(list(timeline_dir.glob("timeline_*.json")))
        self.assertFalse(list(timeline_dir.glob("timeline_*.md")))

        with mock.patch.object(app, "remove_student_timeline", side_effect=OSError("cleanup failed")):
            self.assertEqual(self.run_app("--timeline-only"), 1)
        self.assertIn("cleanup failed", (self.output / "README.md").read_text(encoding="utf-8"))

    def test_missing_recording_clears_owned_reports_without_timeline(self):
        self.assertEqual(self.run_app(), 0)
        student_out = self.student_output()
        reports = [student_out / path for path in app.lab_report_paths("lab0")]
        self.assertTrue(all(path.is_file() for path in reports))
        manual = student_out / "manual-note.md"
        manual.write_text("keep", encoding="utf-8")
        timeline = student_out / timeline_reports.TIMELINE_DIRECTORY / "timeline_lab0.json"
        timeline_before = timeline.read_bytes()
        (self.student / "term" / "session.out.gz").unlink()
        (self.student / "term" / "session.tim.gz").unlink()

        self.assertEqual(self.run_app("--no-timeline"), 1)

        self.assertTrue(all(not path.exists() for path in reports))
        self.assertEqual(manual.read_text(encoding="utf-8"), "keep")
        self.assertEqual(timeline.read_bytes(), timeline_before)
        manifest = json.loads((student_out / app.OWNER_FILE).read_text(encoding="utf-8"))
        self.assertEqual(manifest["source"], str(self.student.resolve()))
        self.assertEqual(manifest["status"], "cleared")
        self.assertEqual(manifest["reports"], [])

    def test_missing_recording_does_not_partially_clear_invalid_report_manifest(self):
        self.assertEqual(self.run_app(), 0)
        student_out = self.student_output()
        reports = [student_out / path for path in app.lab_report_paths("lab0")]
        owner_path = student_out / app.OWNER_FILE
        manifest = json.loads(owner_path.read_text(encoding="utf-8"))
        manifest["reports"] = [
            app.lab_report_paths("lab0")[0].as_posix(),
            "../outside.md",
        ]
        owner_path.write_text(json.dumps(manifest), encoding="utf-8")
        (self.student / "term" / "session.out.gz").unlink()
        (self.student / "term" / "session.tim.gz").unlink()

        self.assertEqual(self.run_app("--no-timeline"), 1)

        self.assertTrue(all(path.is_file() for path in reports))
        self.assertEqual(
            json.loads(owner_path.read_text(encoding="utf-8"))["reports"], manifest["reports"]
        )
        self.assertIn("报告清理", (self.output / "README.md").read_text(encoding="utf-8"))

    def test_timeline_owned_output_does_not_take_over_unregistered_reports(self):
        self.assertEqual(self.run_app("--timeline-only"), 0)
        timeline_output = self.student_output()
        manual = timeline_output / app.lab_report_paths("lab0")[0]
        manual.parent.mkdir(parents=True)
        manual.write_text("keep", encoding="utf-8")

        self.assertEqual(self.run_app("--no-timeline"), 0)

        self.assertEqual(manual.read_text(encoding="utf-8"), "keep")
        report_outputs = [
            directory for directory in self.output.iterdir()
            if directory.is_dir() and (directory / app.OWNER_FILE).is_file()
        ]
        self.assertEqual(len(report_outputs), 1)
        self.assertNotEqual(report_outputs[0], timeline_output)
        self.assertTrue((report_outputs[0] / app.lab_report_paths("lab0")[0]).is_file())

    def test_overwrite_takes_over_timeline_owned_output_with_fixed_report(self):
        self.assertEqual(self.run_app("--timeline-only"), 0)
        timeline_output = self.student_output()
        manual = timeline_output / app.lab_report_paths("lab0")[0]
        manual.parent.mkdir(parents=True)
        manual.write_text("replace", encoding="utf-8")

        self.assertEqual(self.run_app("--no-timeline", "--overwrite"), 0)

        self.assertNotEqual(manual.read_text(encoding="utf-8"), "replace")
        manifest = json.loads((timeline_output / app.OWNER_FILE).read_text(encoding="utf-8"))
        self.assertEqual(manifest["source"], str(self.student.resolve()))

    def test_foreign_report_owner_is_not_reused_through_timeline_owner(self):
        self.assertEqual(self.run_app("--timeline-only"), 0)
        timeline_output = self.student_output()
        owner_path = timeline_output / app.OWNER_FILE
        foreign_manifest = json.dumps({
            "tool": "replay_term_qa",
            "source": str((self.root / "other-source").resolve()),
            "reports": [],
        }, ensure_ascii=False)
        owner_path.write_text(foreign_manifest, encoding="utf-8")
        manual = timeline_output / app.lab_report_paths("lab0")[0]
        manual.parent.mkdir(parents=True)
        manual.write_text("foreign report", encoding="utf-8")

        self.assertEqual(self.run_app(), 0)
        self.assertEqual(self.run_app("--overwrite"), 0)

        self.assertEqual(owner_path.read_text(encoding="utf-8"), foreign_manifest)
        self.assertEqual(manual.read_text(encoding="utf-8"), "foreign report")
        replacement = self.output / "测试-123-20260910-2221"
        self.assertTrue((replacement / app.OWNER_FILE).is_file())
        self.assertTrue((replacement / app.lab_report_paths("lab0")[0]).is_file())

    def test_force_passes_invalid_manifest_recovery_flag(self):
        with mock.patch.object(app, "mark_timeline_rebuild", wraps=app.mark_timeline_rebuild) as rebuild:
            self.assertEqual(self.run_app("--force", "--timeline-only"), 0)
        self.assertTrue(rebuild.call_args.kwargs["allow_invalid_manifest_recovery"])

    def test_content_scope_and_stage_isolation(self):
        other = self.input / "456-另一位-20260910-2222"
        write_recording(other)
        self.assertEqual(self.run_app(), 0)
        student_out = self.student_output()
        before_reports = self.report_hashes(student_out)

        log = self.student / "logs" / "events.jsonl"
        log.parent.mkdir(parents=True)
        log.write_text('{"type": "session_start", "rec": "session", "ts": "2026-09-10T22:21:13+08:00"}\n',
                       encoding="utf-8")
        code, reports, timelines = self.invoke_with_counts()
        self.assertEqual(code, 0)
        self.assertEqual(reports.call_count, 0)
        self.assertEqual(timelines.call_count, 1)
        self.assertEqual(before_reports, self.report_hashes(student_out))

        (self.student / "labs").mkdir()
        (self.student / "labs" / "note.txt").write_text("ignore", encoding="utf-8")
        (self.student / "transcripts").mkdir()
        (self.student / "transcripts" / "note.txt").write_text("ignore", encoding="utf-8")
        (self.student / "unrelated.txt").write_text("ignore", encoding="utf-8")
        code, reports, timelines = self.invoke_with_counts()
        self.assertEqual(code, 0)
        self.assertEqual(reports.call_count, 0)
        self.assertEqual(timelines.call_count, 0)

        session_out = self.student / "term" / "session.out.gz"
        session_out.write_bytes(gzip.compress(gzip.decompress(session_out.read_bytes()), mtime=0))
        code, reports, timelines = self.invoke_with_counts()
        self.assertEqual(code, 0)
        self.assertEqual(reports.call_count, 1)
        self.assertEqual(timelines.call_count, 1)

        extra_out, extra_tim = write_recording(self.student, "extra")
        code, reports, timelines = self.invoke_with_counts()
        self.assertEqual(code, 0)
        self.assertEqual(reports.call_count, 1)
        self.assertEqual(timelines.call_count, 1)

        timing = gzip.decompress(extra_tim.read_bytes()).decode("ascii")
        extra_tim.write_bytes(gzip.compress(timing.replace("0.1", "0.2", 1).encode("ascii")))
        code, reports, timelines = self.invoke_with_counts()
        self.assertEqual(code, 0)
        self.assertEqual(reports.call_count, 1)
        self.assertEqual(timelines.call_count, 1)

        extra_out.unlink()
        extra_tim.unlink()
        code, reports, timelines = self.invoke_with_counts()
        self.assertEqual(code, 0)
        self.assertEqual(reports.call_count, 1)
        self.assertEqual(timelines.call_count, 1)

        _, tim = write_recording(self.student, "second")
        original_timing = tim.read_bytes()
        code, reports, timelines = self.invoke_with_counts()
        self.assertEqual(code, 0)
        self.assertEqual(reports.call_count, 1)
        self.assertEqual(timelines.call_count, 1)
        tim.unlink()
        code, reports, timelines = self.invoke_with_counts()
        self.assertEqual(code, 0)
        self.assertEqual(reports.call_count, 1)
        self.assertEqual(timelines.call_count, 1)
        tim.write_bytes(original_timing)
        code, reports, timelines = self.invoke_with_counts()
        self.assertEqual(code, 0)
        self.assertEqual(reports.call_count, 1)
        self.assertEqual(timelines.call_count, 1)

    def test_cache_invalidation_for_artifacts_manifests_signatures_and_force(self):
        self.assertEqual(self.run_app(), 0)
        student_out = self.student_output()
        report = student_out / app.lab_report_paths("lab0")[0]
        report.unlink()
        code, reports, timelines = self.invoke_with_counts()
        self.assertEqual(code, 0)
        self.assertEqual((reports.call_count, timelines.call_count), (1, 0))

        timeline_file = student_out / timeline_reports.TIMELINE_DIRECTORY / "timeline_lab0.md"
        timeline_file.unlink()
        code, reports, timelines = self.invoke_with_counts()
        self.assertEqual(code, 0)
        self.assertEqual((reports.call_count, timelines.call_count), (0, 1))

        owner_path = student_out / app.OWNER_FILE
        owner_path.write_text("{broken", encoding="utf-8")
        code, reports, timelines = self.invoke_with_counts()
        self.assertEqual(code, 0)
        self.assertEqual((reports.call_count, timelines.call_count), (1, 0))

        owner = json.loads(owner_path.read_text(encoding="utf-8"))
        owner.pop("cache_format_version")
        owner_path.write_text(json.dumps(owner), encoding="utf-8")
        code, reports, timelines = self.invoke_with_counts()
        self.assertEqual(code, 0)
        self.assertEqual((reports.call_count, timelines.call_count), (1, 0))

        owner = json.loads(owner_path.read_text(encoding="utf-8"))
        owner["reports"] = ["../outside.md"]
        owner_path.write_text(json.dumps(owner), encoding="utf-8")
        code, reports, timelines = self.invoke_with_counts()
        self.assertEqual(code, 0)
        self.assertEqual((reports.call_count, timelines.call_count), (1, 0))

        timeline_owner_path = student_out / timeline_reports.TIMELINE_DIRECTORY / timeline_reports.TIMELINE_MANIFEST
        timeline_owner = json.loads(timeline_owner_path.read_text(encoding="utf-8"))
        timeline_owner["artifacts"] = ["实验过程时间线/timeline_lab0.json"]
        timeline_owner_path.write_text(json.dumps(timeline_owner), encoding="utf-8")
        code, reports, timelines = self.invoke_with_counts()
        self.assertEqual(code, 0)
        self.assertEqual((reports.call_count, timelines.call_count), (0, 1))

        with mock.patch.object(app, "timeline_processor_signature", return_value="changed-timeline-signature"):
            code, reports, timelines = self.invoke_with_counts()
            self.assertEqual(code, 0)
            self.assertEqual((reports.call_count, timelines.call_count), (0, 1))
            with mock.patch.object(app, "report_processor_signature", return_value="changed-signature"):
                code, reports, timelines = self.invoke_with_counts()
            self.assertEqual(code, 0)
            self.assertEqual((reports.call_count, timelines.call_count), (1, 0))

        code, reports, timelines = self.invoke_with_counts("--force", "--no-timeline")
        self.assertEqual(code, 0)
        self.assertEqual((reports.call_count, timelines.call_count), (1, 0))
        code, reports, timelines = self.invoke_with_counts("--force", "--timeline-only")
        self.assertEqual(code, 0)
        self.assertEqual((reports.call_count, timelines.call_count), (0, 1))

    def test_different_source_path_gets_a_distinct_output_and_then_hits_cache(self):
        self.assertEqual(self.run_app(), 0)
        previous_output = self.student_output()
        previous_report_owner = json.loads((previous_output / app.OWNER_FILE).read_text(encoding="utf-8"))
        previous_timeline_owner = json.loads((previous_output / timeline_reports.TIMELINE_DIRECTORY /
                                              timeline_reports.TIMELINE_MANIFEST).read_text(encoding="utf-8"))
        renamed = self.input / "123-测试-20260910-2222"
        self.student.rename(renamed)
        self.student = renamed
        code, reports, timelines = self.invoke_with_counts()
        self.assertEqual(code, 0)
        self.assertEqual((reports.call_count, timelines.call_count), (1, 1))
        student_out = self.output / "测试-123-20260910-2222"
        self.assertTrue(student_out.is_dir())
        report_owner = json.loads((student_out / app.OWNER_FILE).read_text(encoding="utf-8"))
        timeline_owner = json.loads((student_out / timeline_reports.TIMELINE_DIRECTORY /
                                     timeline_reports.TIMELINE_MANIFEST).read_text(encoding="utf-8"))
        self.assertEqual(report_owner["source"], str(renamed.resolve()))
        self.assertEqual(timeline_owner["source"], str(renamed.resolve()))
        self.assertEqual(json.loads((previous_output / app.OWNER_FILE).read_text(encoding="utf-8")),
                         previous_report_owner)
        self.assertEqual(json.loads((previous_output / timeline_reports.TIMELINE_DIRECTORY /
                                     timeline_reports.TIMELINE_MANIFEST).read_text(encoding="utf-8")),
                         previous_timeline_owner)
        code, reports, timelines = self.invoke_with_counts()
        self.assertEqual(code, 0)
        self.assertEqual((reports.call_count, timelines.call_count), (0, 0))

    def test_interrupted_rebuild_reuses_the_same_owned_output(self):
        self.assertEqual(self.run_app(), 0)
        student_out = self.student_output()
        with mock.patch.object(app, "process_student", side_effect=OSError("simulated interruption")):
            self.assertEqual(self.run_app("--no-timeline", "--force"), 1)
        owner = json.loads((student_out / app.OWNER_FILE).read_text(encoding="utf-8"))
        self.assertEqual(owner["source"], str(self.student.resolve()))
        self.assertEqual(owner["status"], "building")

        self.assertEqual(self.run_app("--no-timeline"), 0)
        self.assertEqual(
            sorted(path.name for path in self.output.iterdir() if path.is_dir()),
            ["测试"],
        )
        owner = json.loads((student_out / app.OWNER_FILE).read_text(encoding="utf-8"))
        self.assertEqual(owner["status"], "complete")

    def test_cache_hashes_detect_tampered_artifacts(self):
        self.assertEqual(self.run_app(), 0)
        student_out = self.student_output()
        report = student_out / app.lab_report_paths("lab0")[0]
        report.write_text(report.read_text(encoding="utf-8") + "tampered\n", encoding="utf-8")
        code, reports, timelines = self.invoke_with_counts()
        self.assertEqual(code, 0)
        self.assertEqual((reports.call_count, timelines.call_count), (1, 0))

        timeline = student_out / timeline_reports.TIMELINE_DIRECTORY / "timeline_lab0.md"
        timeline.write_text(timeline.read_text(encoding="utf-8") + "tampered\n", encoding="utf-8")
        code, reports, timelines = self.invoke_with_counts()
        self.assertEqual(code, 0)
        self.assertEqual((reports.call_count, timelines.call_count), (0, 1))

    def test_partial_stages_are_not_cached_as_successes(self):
        self.assertEqual(self.run_app(), 0)
        (self.student / "term" / "broken.out.gz").write_bytes(b"not gzip")
        code, reports, timelines = self.invoke_with_counts()
        self.assertNotEqual(code, 0)
        self.assertEqual((reports.call_count, timelines.call_count), (1, 1))
        student_out = self.student_output()
        report_owner = json.loads((student_out / app.OWNER_FILE).read_text(encoding="utf-8"))
        timeline_owner = json.loads((student_out / timeline_reports.TIMELINE_DIRECTORY /
                                     timeline_reports.TIMELINE_MANIFEST).read_text(encoding="utf-8"))
        self.assertNotEqual(report_owner["status"], "complete")
        self.assertNotEqual(timeline_owner["status"], "complete")
        self.assertNotIn("input_fingerprint", report_owner)
        self.assertNotIn("input_fingerprint", timeline_owner)
        code, reports, timelines = self.invoke_with_counts()
        self.assertNotEqual(code, 0)
        self.assertEqual((reports.call_count, timelines.call_count), (1, 1))

    def test_modes_filters_and_content_fingerprint_ignore_mtime(self):
        other = self.input / "456-另一位-20260910-2222"
        write_recording(other)
        self.assertEqual(self.run_app(), 0)
        out = self.student / "term" / "session.out.gz"
        original_stat = out.stat()
        os.utime(out, (original_stat.st_atime + 5, original_stat.st_mtime + 5))
        code, reports, timelines = self.invoke_with_counts()
        self.assertEqual(code, 0)
        self.assertEqual((reports.call_count, timelines.call_count), (0, 0))

        code, reports, timelines = self.invoke_with_counts("--force", "--timeline-only")
        self.assertEqual(code, 0)
        self.assertEqual((reports.call_count, timelines.call_count), (0, 2))
        code, reports, timelines = self.invoke_with_counts("--force", "--no-timeline")
        self.assertEqual(code, 0)
        self.assertEqual((reports.call_count, timelines.call_count), (2, 0))
        code, reports, timelines = self.invoke_with_counts(
            "--force", "--no-timeline", "--student", "123"
        )
        self.assertEqual(code, 0)
        self.assertEqual((reports.call_count, timelines.call_count), (1, 0))
        self.assertEqual(reports.call_args.args[0]["student_id"], "123")

    def test_missing_source_output_is_preserved_and_reported(self):
        self.assertEqual(self.run_app(), 0)
        student_out = self.student_output()
        before = self.hashes(student_out)
        shutil.rmtree(self.student)
        self.assertEqual(self.run_app(), 0)
        self.assertEqual(before, self.hashes(student_out))
        readme = (self.output / "README.md").read_text(encoding="utf-8")
        self.assertIn("原始提交已不存在，输出已保留", readme)


if __name__ == "__main__":
    unittest.main()
