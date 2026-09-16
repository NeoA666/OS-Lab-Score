"""时间线对齐的合成回归测试。

测试只在临时目录建立 script 录像，不读取或改写真实学生数据；旧版测试保持不变。
"""
import gzip
import hashlib
import io
import contextlib
import json
from pathlib import Path
import tempfile
import unittest

import timeline_alignment as timeline
import replay_term_qa as app


PROMPT0 = (
    "\x1b[01;32mailab-os@ailab-os-VMware-Virtual-Platform\x1b[00m:"
    "\x1b[01;34m~/lab0\x1b[00m$ "
)
PROMPT1 = (
    "\x1b[01;32mailab-os@ailab-os-VMware-Virtual-Platform\x1b[00m:"
    "\x1b[01;34m~/lab1\x1b[00m$ "
)


def write_recording(term, name="session", chunks=(), timing=None, header=None):
    """建立最小 gzip script 录像，并返回 out/tim 路径。"""
    term.mkdir(parents=True, exist_ok=True)
    parts = [x.encode("utf-8") for x in chunks]
    if header is None:
        header = 'Script started on 2026-09-10 22:21:12+08:00 [COLUMNS="80" LINES="24"]\n'
    out = term / (name + ".out.gz")
    out.write_bytes(gzip.compress(header.encode("utf-8") + b"".join(parts)))
    tim = term / (name + ".tim.gz")
    if timing is not None:
        if timing is True:
            timing = [(0.1, len(x)) for x in parts]
        tim.write_bytes(gzip.compress("".join(f"{d} {n}\n" for d, n in timing).encode()))
    return out, tim


class TimelineFixtureTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.student = self.root / "123-测试-20260910-2221"
        self.output = self.root / "output" / "测试"
        self.output.mkdir(parents=True)

    def tearDown(self):
        self.tmp.cleanup()

    def info(self):
        return {
            "source": str(self.student),
            "output": self.output,
            "student_id": "123",
            "name": "测试",
            "collected": "2026-09-10 22:21",
        }

    def build(self, chunks, name="session", timing=True, header=None):
        write_recording(self.student / "term", name, chunks, timing, header)
        result = timeline.build_student_timeline(self.info())
        self.assertIsInstance(result, dict)
        for key in ("events", "recordings", "errors", "recording_details"):
            self.assertIn(key, result)
        self.assertIsInstance(result["events"], list)
        self.assertIsInstance(result["recordings"], (int, list, dict))
        self.assertIsInstance(result["errors"], list)
        self.assertIsInstance(result["recording_details"], (list, dict))
        return result

    def test_contract_and_independent_user_reply_times(self):
        chunks = [
            PROMPT0 + "claude\r\n",
            "❯ 第一问题\r\n",
            "● 第一回答\r\n",
            "❯ 第二问题\r\n",
            "● 第二回答\r\n",
            "─" * 60 + "\r\n❯ \r\n? for shortcuts\r\n",
        ]
        result = self.build(chunks, timing=[(i + 1, len(x.encode("utf-8"))) for i, x in enumerate(chunks)])
        events = result["events"]
        self.assertGreaterEqual(len(events), 4)
        for event in events:
            self.assertTrue(event.get("event_id") or event.get("id"))
            self.assertTrue(event.get("event_type") or event.get("type"))
            self.assertTrue(event.get("recording_id") or event.get("recording"))
            self.assertTrue(
                event.get("display_time") is not None
                or event.get("display_start") is not None
                or event.get("relative_offset") is not None
                or event.get("elapsed_seconds") is not None
            )
        user = [e for e in events if e.get("type") == "claude_user_observed"]
        reply = [e for e in events if e.get("type") == "claude_reply_observed"]
        self.assertEqual(len(user), 2)
        self.assertEqual(len(reply), 2)
        self.assertEqual([e["elapsed_seconds"] for e in user + reply], [3.0, 10.0, 6.0, 15.0])
        self.assertEqual([e["related_event_id"] for e in reply], [user[0]["event_id"], user[1]["event_id"]])

    def test_cross_lab_and_original_order_are_retained(self):
        result = self.build([
            PROMPT0 + "pwd\r\n/home/x/lab0\r\n",
            PROMPT0 + "cd ../lab1\r\n",
            PROMPT1 + "echo lab1\r\n",
            "lab1\r\n",
        ], name="cross", timing=True)
        labs = {(e.get("lab") or e.get("lab_name")) for e in result["events"]}
        if labs:
            self.assertIn("lab0", labs)
            self.assertIn("lab1", labs)
        commands = [e for e in result["events"] if e.get("type") == "shell_command_observed"]
        self.assertEqual(len(commands), 3)
        self.assertEqual([e["content"] for e in commands], ["pwd", "cd ../lab1", "echo lab1"])
        self.assertEqual([round(e["elapsed_seconds"], 1) for e in commands], [0.1, 0.2, 0.3])

    def test_missing_timing_is_reported_without_losing_recording(self):
        result = self.build([PROMPT0 + "echo no-tim\r\n", "ok\r\n"], timing=None, name="missing")
        self.assertTrue(result["errors"] or any(d.get("timing_missing") for d in result["recording_details"] if isinstance(d, dict)))
        self.assertGreaterEqual(len(result["events"]), 1)

    def test_paste_streaming_duplicates_are_not_duplicate_events(self):
        result = self.build([
            PROMPT0 + "claude\r\n",
            "❯ \x1b[200~粘贴的问题\x1b[201~\r\n",
            "● 答案的前半",
            "\r\x1b[2K● 答案的前半+后半。\r\n",
            "❯ \r\n",
        ], name="paste", timing=True)
        user = [e for e in result["events"] if e.get("type") == "claude_user_observed"]
        reply = [e for e in result["events"] if e.get("type") == "claude_reply_observed"]
        self.assertEqual(len(user), 1)
        self.assertEqual(len(reply), 1)
        self.assertEqual(user[0]["content"], "粘贴的问题")
        self.assertEqual(reply[0]["content"], "答案的前半+后半。")

    def test_chinese_header_and_conflicting_timing_are_safe(self):
        result = self.build(
            [PROMPT0 + "echo 中文\r\n中文\r\n"],
            name="zh",
            header="脚本开始于 2026-09-10 22:21:12+08:00\n",
            timing=[(0.1, 1)],
        )
        detail = result["recording_details"][0]
        self.assertIn("timing_uncovered_tail", detail["issues"])
        command = next(e for e in result["events"] if e["type"] == "shell_command_observed")
        self.assertIsNone(command["elapsed_seconds"])

    def test_headerless_recording_preserves_first_bytes(self):
        result = self.build(
            [PROMPT0 + "echo first\r\n", "first output\r\n"],
            name="headerless", header="", timing=True,
        )
        detail = result["recording_details"][0]
        self.assertEqual(detail["format"], "headerless")
        self.assertEqual(detail["header_bytes"], 0)
        self.assertTrue(any("first" in json.dumps(e, ensure_ascii=False) for e in result["events"]))

    def test_header_and_duplicate_session_start_are_reported(self):
        logs = self.student / "logs"
        logs.mkdir(parents=True, exist_ok=True)
        records = [
            {"type": "session_start", "rec": "headerlog", "ts": "2026-09-10T22:21:13+08:00", "tty": "pts/1"},
            {"type": "session_start", "rec": "headerlog", "ts": "2026-09-10T22:21:14+08:00", "tty": "pts/2"},
        ]
        (logs / "events.jsonl").write_text("\n".join(json.dumps(x) for x in records) + "\n", encoding="utf-8")
        result = self.build([PROMPT0 + "echo log\r\n"], name="headerlog", timing=True)
        issues = json.dumps(result, ensure_ascii=False)
        self.assertTrue("conflicting_session_start_records" in issues or "header_session_start_difference" in issues)

    def test_same_timestamp_recordings_have_stable_distinct_order(self):
        write_recording(self.student / "term", "a", [PROMPT0 + "echo a\r\n"], True)
        write_recording(self.student / "term", "b", [PROMPT0 + "echo b\r\n"], True)
        result = timeline.build_student_timeline(self.info())
        commands = [e for e in result["events"] if e.get("type") == "shell_command_observed"]
        self.assertEqual([(e["recording_id"], e["content"]) for e in commands], [("a", "echo a"), ("b", "echo b")])
        self.assertNotEqual(commands[0]["event_id"], commands[1]["event_id"])


class TimelineCliTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.input = self.root / "学生数据"
        self.student = self.input / "123-测试-20260910-2221"
        write_recording(self.student / "term", chunks=[
            PROMPT0 + "echo cli\r\n", "cli output\r\n",
        ], timing=True)
        self.output = self.root / "结果"

    def tearDown(self):
        self.tmp.cleanup()

    def run_app(self, *args):
        with contextlib.redirect_stdout(io.StringIO()):
            return app.main([str(self.input), "-o", str(self.output), *args])

    @staticmethod
    def hashes(root):
        return {
            str(p.relative_to(root)): hashlib.sha256(p.read_bytes()).hexdigest()
            for p in root.rglob("*") if p.is_file()
        }

    def test_timeline_only_does_not_rebuild_existing_reports(self):
        self.assertEqual(self.run_app(), 0)
        student_out = self.output / "测试"
        old = {k: v for k, v in self.hashes(student_out).items()
               if "实验过程时间线" not in k and k != ".timeline_manifest.json"}
        timeline_files = sorted(str(p.relative_to(student_out)) for p in student_out.rglob("*")
                                if p.is_file() and "实验过程时间线" in str(p))
        self.assertTrue(timeline_files)
        self.assertEqual(self.run_app("--timeline-only"), 0)
        now = self.hashes(student_out)
        self.assertEqual(old, {k: v for k, v in now.items()
                               if "实验过程时间线" not in k and k != ".timeline_manifest.json"})
        self.assertEqual(timeline_files, sorted(str(p.relative_to(student_out)) for p in student_out.rglob("*")
                                                if p.is_file() and "实验过程时间线" in str(p)))

    def test_no_timeline_preserves_timeline_and_rerun_is_idempotent(self):
        self.assertEqual(self.run_app(), 0)
        student_out = self.output / "测试"
        before = self.hashes(student_out)
        self.assertEqual(self.run_app("--no-timeline"), 0)
        after_no = self.hashes(student_out)
        self.assertEqual(before, after_no)
        self.assertEqual(self.run_app(), 0)
        self.assertEqual(after_no, self.hashes(student_out))
        manifests = list(student_out.rglob(".timeline_manifest.json"))
        self.assertEqual(len(manifests), 1)
        manifest = json.loads(manifests[0].read_text(encoding="utf-8"))
        self.assertEqual(manifest["source"], str(self.student.resolve()))

    def test_different_source_gets_distinct_timeline_owner(self):
        self.assertEqual(self.run_app("--timeline-only"), 0)
        student_out = self.output / "测试"
        timeline_dir = student_out / "实验过程时间线"
        other = self.input / "456-测试-20260910-2222"
        write_recording(other / "term", chunks=[PROMPT0 + "echo other\r\n"], timing=True)
        self.assertEqual(self.run_app("--timeline-only", "--student", "456"), 0)
        self.assertTrue(timeline_dir.is_dir())
        manifests = list(self.output.rglob(".timeline_manifest.json"))
        self.assertEqual(len(manifests), 2)
        self.assertEqual({json.loads(p.read_text(encoding="utf-8"))["source"] for p in manifests},
                         {str(self.student.resolve()), str(other.resolve())})

    def test_missing_term_is_nonzero(self):
        missing = self.input / "789-缺失-20260910-2223"
        missing.mkdir(parents=True)
        with contextlib.redirect_stdout(io.StringIO()):
            code = app.main([str(self.input), "-o", str(self.output), "--timeline-only", "--student", "789"])
        self.assertNotEqual(code, 0)

    def test_symlink_term_is_rejected_when_supported(self):
        real_term = self.root / "real-term"
        write_recording(real_term, chunks=[PROMPT0 + "echo link\r\n"], timing=True)
        symlink_student = self.input / "888-链接-20260910-2224"
        symlink_student.mkdir(parents=True)
        try:
            (symlink_student / "term").symlink_to(real_term, target_is_directory=True)
        except (OSError, NotImplementedError):
            self.skipTest("当前 Windows 环境不允许创建目录符号链接")
        with contextlib.redirect_stdout(io.StringIO()):
            code = app.main([str(self.input), "-o", str(self.output), "--timeline-only", "--student", "888"])
        self.assertNotEqual(code, 0)


if __name__ == "__main__":
    unittest.main()
