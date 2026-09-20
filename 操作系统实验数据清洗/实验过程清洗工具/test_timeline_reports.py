import contextlib
import gzip
import io
import json
from pathlib import Path
import tempfile
from types import SimpleNamespace
import unittest
from unittest import mock

import generate_readable_timeline as readable
import replay_term_qa as app
import timeline_reports as reports


def sample_result(labs=("lab0", "lab1")):
    events = []
    for index, lab in enumerate(labs, 1):
        events.append({
            "event_id": f"event-{index}",
            "student": {"student_id": "123", "name": "学生"},
            "lab": lab,
            "cwd": f"~/{lab}",
            "recording_id": f"rec-{index}",
            "terminal": {"header_tty": "/dev/pts/0", "session_start_tty": ["/dev/pts/1"],
                         "shell_pid": ["42"]},
            "type": "shell_command_observed",
            "content": "echo hello",
            "output": ["hello"],
            "observed_at": "2026-09-10T14:00:00+00:00" if index == 1 else None,
            "elapsed_seconds": float(index),
            "observation_semantics": "命令文本完整可见",
            "related_event_id": None,
            "source": {"out": f"rec-{index}.out.gz", "tim": f"rec-{index}.tim.gz"},
            "uncertainty": [] if index == 1 else ["absolute_observation_unavailable"],
        })
    return {
        "events": events,
        "recordings": 3,
        "errors": ["clock warning"],
        "recording_details": [
            {"recording_id": "rec-1", "status": "ok"},
            {"recording_id": "rec-2", "status": "ok"},
            {"recording_id": "rec-without-event", "status": "ok"},
        ],
    }


class TimelineReportTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(dir=Path(__file__).parent)
        self.root = Path(self.temporary.name)
        self.source = self.root / "input" / "123-学生-20260910-1400"
        (self.source / "term").mkdir(parents=True)
        self.output = self.root / "output" / "学生"
        self.info = {"student_id": "123", "name": "学生", "source": str(self.source.resolve()),
                     "output": self.output}

    def tearDown(self):
        self.temporary.cleanup()

    def test_json_markdown_manifest_and_safe_stale_cleanup(self):
        summary = reports.write_student_timeline(self.info, sample_result())
        self.assertEqual(set(summary["labs"]), {"lab0", "lab1"})
        document = json.loads((self.output / "lab0" / "实验过程清洗工具" / "实验过程时间线.json").read_text(encoding="utf-8"))
        self.assertIn("summary", document)
        self.assertEqual(len(document["events"]), 1)
        self.assertEqual(len(document["recording_details"]), 3)
        markdown = (self.output / "lab0" / "实验过程清洗工具" / "实验过程时间线.md").read_text(encoding="utf-8")
        self.assertIn("2026-09-10T22:00:00.000+08:00（北京时间）", markdown)
        self.assertIn("关联 Shell 输出", markdown)
        self.assertIn("hello", markdown)
        self.assertIn("事件编号：", markdown)
        self.assertIn("header TTY: /dev/pts/0", markdown)
        notes = self.output / reports.TIMELINE_DIRECTORY / "notes.md"
        notes.write_text("keep", encoding="utf-8")
        reports.write_student_timeline(self.info, sample_result(("lab0",)))
        self.assertFalse((self.output / "lab1" / "实验过程清洗工具" / "实验过程时间线.json").exists())
        self.assertFalse((self.output / "lab1" / "实验过程清洗工具" / "实验过程时间线.md").exists())
        self.assertEqual(notes.read_text(encoding="utf-8"), "keep")

    def test_partial_rerun_removes_stale_labs_from_manifest_and_readable_view(self):
        reports.write_student_timeline(self.info, sample_result())
        timeline_dir = self.output / reports.TIMELINE_DIRECTORY
        stale_json = (self.output / "lab1" / "实验过程清洗工具" / "实验过程时间线.json").read_text(encoding="utf-8")
        partial = sample_result(("lab0",))
        partial["recording_details"].append({"recording_id": "broken", "status": "error"})

        summary = reports.write_student_timeline(self.info, partial)
        manifest = json.loads((timeline_dir / reports.TIMELINE_MANIFEST).read_text(encoding="utf-8"))
        self.assertEqual(summary["status"], "partial")
        self.assertNotIn("lab1/实验过程清洗工具/实验过程时间线.json", manifest["artifacts"])
        self.assertFalse((self.output / "lab1" / "实验过程清洗工具" / "实验过程时间线.json").exists())
        self.assertFalse((self.output / "lab1" / "实验过程清洗工具" / "实验过程时间线.md").exists())

        # A stale physical file must not bypass the producer's current manifest.
        (self.output / "lab1" / "实验过程清洗工具" / "实验过程时间线.json").write_text(stale_json, encoding="utf-8")
        written = readable.write_student(self.output)
        self.assertEqual([path.name for path in written], ["简洁实验过程时间线.md"])
        self.assertFalse((self.output / "lab1" / "实验过程清洗工具" / "简洁实验过程时间线.md").exists())

    def test_force_rebuild_recovers_same_source_corrupt_manifest_only_with_opt_in(self):
        reports.write_student_timeline(self.info, sample_result(("lab0",)))
        manifest_path = self.output / reports.TIMELINE_DIRECTORY / reports.TIMELINE_MANIFEST
        manifest_path.write_text("{corrupt", encoding="utf-8")

        self.assertTrue(reports.timeline_owned_by(self.output, self.info["source"]))
        reports.mark_timeline_rebuild(self.info)
        self.assertEqual(manifest_path.read_text(encoding="utf-8"), "{corrupt")

        reports.mark_timeline_rebuild(self.info, allow_invalid_manifest_recovery=True)
        building = json.loads(manifest_path.read_text(encoding="utf-8"))
        self.assertEqual(building["status"], "building")
        self.assertIn("lab0/实验过程清洗工具/实验过程时间线.json", building["artifacts"])
        summary = reports.write_student_timeline(self.info, sample_result(("lab0",)))
        self.assertEqual(summary["status"], "complete")
        self.assertEqual(
            json.loads(manifest_path.read_text(encoding="utf-8"))["status"], "complete"
        )

    def test_force_rebuild_does_not_claim_corrupt_foreign_artifacts(self):
        directory = self.output / reports.TIMELINE_DIRECTORY
        directory.mkdir(parents=True)
        (self.output / "lab0" / "实验过程清洗工具").mkdir(parents=True, exist_ok=True)
        (self.output / "lab0" / "实验过程清洗工具" / "实验过程时间线.json").write_text(json.dumps({
            "student": {"source": "another-source"}, "lab": "lab0",
        }), encoding="utf-8")
        manifest_path = directory / reports.TIMELINE_MANIFEST
        manifest_path.write_text("{corrupt", encoding="utf-8")

        self.assertFalse(reports.timeline_owned_by(self.output, self.info["source"]))
        reports.mark_timeline_rebuild(self.info, allow_invalid_manifest_recovery=True)
        self.assertEqual(manifest_path.read_text(encoding="utf-8"), "{corrupt")

    def test_remove_student_timeline_only_removes_same_source_registered_artifacts(self):
        reports.write_student_timeline(self.info, sample_result(("lab0",)))
        directory = self.output / reports.TIMELINE_DIRECTORY
        stale_json = (self.output / "lab0" / "实验过程清洗工具" / "实验过程时间线.json").read_text(encoding="utf-8")
        readable_output = readable.write_student(self.output)[0]
        notes = directory / "notes.md"
        notes.write_text("keep", encoding="utf-8")

        self.assertTrue(reports.remove_student_timeline(self.info))
        self.assertFalse((self.output / "lab0" / "实验过程清洗工具" / "实验过程时间线.json").exists())
        self.assertFalse((self.output / "lab0" / "实验过程清洗工具" / "实验过程时间线.md").exists())
        manifest = json.loads((directory / reports.TIMELINE_MANIFEST).read_text(encoding="utf-8"))
        self.assertEqual(manifest["status"], "cleared")
        self.assertEqual(manifest["artifacts"], [])
        self.assertEqual(notes.read_text(encoding="utf-8"), "keep")
        self.assertTrue(reports.timeline_owned_by(self.output, self.info["source"]))

        # A leftover file outside the cleared manifest cannot revive an old concise view.
        (self.output / "lab0" / "实验过程清洗工具" / "实验过程时间线.json").write_text(stale_json, encoding="utf-8")
        self.assertEqual(readable.write_student(self.output), [])
        self.assertFalse(readable_output.exists())

    def test_declared_lab_creates_prompt_only_lab_timeline(self):
        result = sample_result(())
        result["labs"] = ["lab0"]

        summary = reports.write_student_timeline(self.info, result)
        self.assertEqual(set(summary["labs"]), {"lab0"})
        self.assertTrue((self.output / "lab0" / "实验过程清洗工具" / "实验过程时间线.json").exists())
        self.assertFalse((self.output / "其他" / "实验过程清洗工具" / "实验过程时间线.json").exists())

    def test_foreign_manifest_is_rejected_before_writing(self):
        directory = self.output / reports.TIMELINE_DIRECTORY
        directory.mkdir(parents=True)
        (directory / reports.TIMELINE_MANIFEST).write_text(json.dumps({
            "tool": reports.TIMELINE_TOOL, "source": "another-source", "artifacts": []}), encoding="utf-8")
        with self.assertRaises(ValueError):
            reports.write_student_timeline(self.info, sample_result(("lab0",)))
        self.assertFalse((self.output / "lab0" / "实验过程清洗工具" / "实验过程时间线.json").exists())

    def test_windows_reparse_point_is_link_like_without_path_is_junction(self):
        reparse_point = 0x400
        with mock.patch.object(Path, "is_symlink", return_value=False), \
             mock.patch.object(Path, "is_junction", return_value=False, create=True), \
             mock.patch.object(reports.os, "lstat", return_value=SimpleNamespace(
                 st_file_attributes=reparse_point
             )), \
             mock.patch.object(reports.stat, "FILE_ATTRIBUTE_REPARSE_POINT", reparse_point, create=True):
            self.assertTrue(reports.is_link_like(self.root / "junction"))

    def test_readme_block_is_idempotent_and_preserves_existing_text(self):
        readme = self.root / "README.md"
        readme.write_text("# 终端实验数据批处理说明\n\n保留这段。\n", encoding="utf-8")
        item = {"statistics": {"events": 1, "absolute_time_events": 1,
                               "relative_time_only_events": 0, "missing_time_events": 0,
                               "uncertain_events": 0, "recording_failures": 0, "errors": 0}}
        reports.update_readme_timeline_block(readme, [item])
        first = readme.read_text(encoding="utf-8")
        reports.update_readme_timeline_block(readme, [item])
        second = readme.read_text(encoding="utf-8")
        self.assertEqual(first, second)
        self.assertIn("保留这段。", second)
        self.assertEqual(second.count(reports.README_BLOCK_START), 1)
        suffix = "\n\n## 后续人工说明\n\n  保留缩进与位置。\n"
        readme.write_text(second + suffix, encoding="utf-8")
        reports.update_readme_timeline_block(readme, [item])
        self.assertEqual(readme.read_text(encoding="utf-8"), second + suffix)

    def test_readme_block_includes_timeline_failure_details(self):
        readme = self.root / "README.md"
        item = {
            "info": {"source_name": "123-学生-20260910-1400"},
            "status": "failed",
            "statistics": {
                "events": 0, "absolute_time_events": 0, "relative_time_only_events": 0,
                "missing_time_events": 0, "uncertain_events": 0, "recording_failures": 1,
                "processing_failures": 1, "errors": 1,
            },
            "errors": ["损坏 timing 文件导致时间线失败"],
        }

        reports.update_readme_timeline_block(readme, [item])
        text = readme.read_text(encoding="utf-8")
        self.assertIn("### 时间线提示与失败详情", text)
        self.assertIn("123-学生-20260910-1400（失败）：损坏 timing 文件导致时间线失败", text)

    def test_timeline_only_creates_readme_and_reuses_timeline_owned_directory(self):
        output_root = self.root / "result"
        (self.source / "term" / "session.out.gz").write_bytes(gzip.compress(b"minimal recording"))
        aligned = {"events": [], "recordings": 1, "errors": [],
                   "recording_details": [{"recording_id": "empty", "status": "ok"}]}
        with mock.patch("timeline_alignment.build_student_timeline", return_value=aligned):
            with contextlib.redirect_stdout(io.StringIO()):
                self.assertEqual(app.main([str(self.source.parent), "-o", str(output_root), "--timeline-only"]), 0)
                self.assertEqual(app.main([str(self.source.parent), "-o", str(output_root), "--timeline-only"]), 0)
        self.assertTrue((output_root / "汇总报告" / "实验过程清洗汇总.md").read_text(encoding="utf-8").startswith(app.README_TITLE))
        student_dirs = [path for path in (output_root / "按人分类").iterdir() if path.is_dir()]
        self.assertEqual([path.name for path in student_dirs], ["学生"])
        self.assertFalse((student_dirs[0] / app.OWNER_FILE).exists())


if __name__ == "__main__":
    unittest.main()
