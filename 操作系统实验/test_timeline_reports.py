import contextlib
import io
import json
from pathlib import Path
import tempfile
import unittest
from unittest import mock

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
        document = json.loads((self.output / reports.TIMELINE_DIRECTORY / "timeline_lab0.json").read_text(encoding="utf-8"))
        self.assertIn("summary", document)
        self.assertEqual(len(document["events"]), 1)
        self.assertEqual(len(document["recording_details"]), 3)
        markdown = (self.output / reports.TIMELINE_DIRECTORY / "timeline_lab0.md").read_text(encoding="utf-8")
        self.assertIn("2026-09-10T22:00:00.000+08:00（北京时间）", markdown)
        self.assertIn("关联 Shell 输出", markdown)
        self.assertIn("hello", markdown)
        self.assertIn("事件编号：", markdown)
        self.assertIn("header TTY: /dev/pts/0", markdown)
        notes = self.output / reports.TIMELINE_DIRECTORY / "notes.md"
        notes.write_text("keep", encoding="utf-8")
        reports.write_student_timeline(self.info, sample_result(("lab0",)))
        self.assertFalse((self.output / reports.TIMELINE_DIRECTORY / "timeline_lab1.json").exists())
        self.assertFalse((self.output / reports.TIMELINE_DIRECTORY / "timeline_lab1.md").exists())
        self.assertEqual(notes.read_text(encoding="utf-8"), "keep")

    def test_foreign_manifest_is_rejected_before_writing(self):
        directory = self.output / reports.TIMELINE_DIRECTORY
        directory.mkdir(parents=True)
        (directory / reports.TIMELINE_MANIFEST).write_text(json.dumps({
            "tool": reports.TIMELINE_TOOL, "source": "another-source", "artifacts": []}), encoding="utf-8")
        with self.assertRaises(ValueError):
            reports.write_student_timeline(self.info, sample_result(("lab0",)))
        self.assertFalse((directory / "timeline_lab0.json").exists())

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

    def test_timeline_only_creates_readme_and_reuses_timeline_owned_directory(self):
        output_root = self.root / "result"
        aligned = {"events": [], "recordings": 1, "errors": [],
                   "recording_details": [{"recording_id": "empty", "status": "ok"}]}
        with mock.patch("timeline_alignment.build_student_timeline", return_value=aligned):
            with contextlib.redirect_stdout(io.StringIO()):
                self.assertEqual(app.main([str(self.source.parent), "-o", str(output_root), "--timeline-only"]), 0)
                self.assertEqual(app.main([str(self.source.parent), "-o", str(output_root), "--timeline-only"]), 0)
        self.assertTrue((output_root / "README.md").read_text(encoding="utf-8").startswith(app.README_TITLE))
        student_dirs = [path for path in output_root.iterdir() if path.is_dir()]
        self.assertEqual([path.name for path in student_dirs], ["学生"])
        self.assertFalse((student_dirs[0] / app.OWNER_FILE).exists())


if __name__ == "__main__":
    unittest.main()
