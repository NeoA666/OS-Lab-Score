import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

import generate_readable_timeline as app


class ReadableTimelineTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(dir=Path(__file__).parent)
        self.root = Path(self.temporary.name)
        self.student = self.root / "学生"
        self.source = self.student / app.SOURCE_DIRECTORY
        self.source.mkdir(parents=True)
        document = {
            "student": {"student_id": "123", "name": "学生"},
            "lab": "lab0",
            "events": [{
                "event_id": "hidden-id",
                "recording_id": "hidden-recording",
                "terminal": {"header_tty": "/dev/pts/0"},
                "type": "shell_command_observed",
                "content": "echo hello",
                "output": ["hello"],
                "observed_at": "2026-09-10T14:00:00+00:00",
                "elapsed_seconds": 1.25,
            }],
        }
        self.timeline = self.student / "lab0" / "实验过程清洗工具" / "实验过程时间线.json"
        self.timeline.parent.mkdir(parents=True)
        self.timeline.write_text(json.dumps(document, ensure_ascii=False), encoding="utf-8")

    def tearDown(self):
        self.temporary.cleanup()

    def test_writes_simple_view_without_changing_source_json(self):
        source_hash = hashlib.sha256(self.timeline.read_bytes()).hexdigest()
        output = app.write_student(self.student)
        self.assertEqual([path.name for path in output], ["简洁实验过程时间线.md"])
        text = output[0].read_text(encoding="utf-8")
        self.assertIn("录像时间：2026-09-10T22:00:00.000+08:00（北京时间）", text)
        self.assertIn("录像类型：Shell 命令", text)
        self.assertIn("echo hello", text)
        self.assertIn("[终端输出]\nhello", text)
        self.assertNotIn("hidden-id", text)
        self.assertNotIn("hidden-recording", text)
        self.assertNotIn("/dev/pts/0", text)
        self.assertEqual(source_hash, hashlib.sha256(self.timeline.read_bytes()).hexdigest())

    def test_removes_only_owned_markdown_when_source_json_disappears(self):
        output = app.write_student(self.student)[0]
        manifest = self.source / app.OUTPUT_MANIFEST
        self.timeline.unlink()

        self.assertEqual(app.write_student(self.student), [])
        self.assertFalse(output.exists())
        document = json.loads(manifest.read_text(encoding="utf-8"))
        self.assertEqual(document["artifacts"], [])

    @unittest.skipUnless(os.name == "nt", "Windows junction fixture")
    def test_junction_output_is_rejected_without_writing_external_files(self):
        external = self.root / "external"
        external.mkdir()
        junction = self.student / "lab0" / "实验过程清洗工具"
        self.timeline.unlink()
        junction.rmdir()
        created = subprocess.run(
            ["cmd", "/d", "/c", "mklink", "/J", str(junction), str(external)],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            check=False,
        )
        if created.returncode:
            self.skipTest("当前 Windows 环境不允许创建 junction")
        try:
            with self.assertRaises(ValueError):
                app.write_student(self.student)
            self.assertEqual(list(external.iterdir()), [])
        finally:
            subprocess.run(["cmd", "/d", "/c", "rmdir", str(junction)],
                           stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)


if __name__ == "__main__":
    unittest.main()
