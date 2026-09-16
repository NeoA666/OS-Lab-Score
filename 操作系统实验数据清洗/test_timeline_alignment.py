"""新增显示事件旁路的时间、身份和原始位置边界测试。"""
import gzip
import json
from pathlib import Path
import tempfile
import unittest

import replay_term_qa as app
import timeline_alignment as timeline


PROMPT = '\x1b[01;32mailab-os@ailab-os-VMware-Virtual-Platform\x1b[00m:\x1b[01;34m~/lab0\x1b[00m$ '


class AlignmentTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        (self.root / "term").mkdir()

    def tearDown(self):
        self.temp.cleanup()

    def recording(self, chunks, header=None, delays=None, sizes=None):
        chunks = [part.encode() if isinstance(part, str) else part for part in chunks]
        if header is None:
            header = 'Script started on 2026-09-10 22:21:12+08:00 [COLUMNS="80" LINES="24"]\n'
        out, tim = self.root / "term/r.out.gz", self.root / "term/r.tim.gz"
        out.write_bytes(gzip.compress(header.encode() + b"".join(chunks)))
        delays = delays or [1] * len(chunks)
        sizes = sizes or [len(part) for part in chunks]
        tim.write_bytes(gzip.compress("".join(f"{d} {s}\n" for d, s in zip(delays, sizes)).encode()))
        return out, tim

    def build(self):
        return timeline.build_student_timeline({"source": str(self.root), "student_id": "123", "name": "测试"})

    def test_byte_boundary_and_paste_mapping(self):
        out, tim = self.recording([PROMPT, '\x1b[200~pwd\x1b[201~', '\r\n/home\r\n'])
        rec = timeline.read_recording(out, tim)
        evidence = []
        commands = app.extract_session(out, tim, evidence=evidence)[2]
        self.assertEqual(commands[0]["command"], "pwd")
        self.assertEqual(rec["body"][evidence[0]["echo_end"] - 3:evidence[0]["echo_end"]], b"pwd")
        self.assertEqual(timeline.evidence_at_byte(rec, len(PROMPT.encode()))["elapsed_seconds"], 2)
        self.assertEqual(self.build()["events"][0]["elapsed_seconds"], 2)

    def test_headerless_does_not_drop_first_command(self):
        self.recording([PROMPT + 'pwd\r\n'], header="")
        result = self.build()
        self.assertEqual(result["recording_details"][0]["format"], "headerless")
        self.assertEqual(result["events"][0]["content"], "pwd")
        self.assertIsNone(result["events"][0]["observed_at"])
        self.assertEqual(result["events"][0]["elapsed_seconds"], 1)

    def test_chinese_header_and_invalid_dimensions(self):
        self.recording([PROMPT + 'pwd\r\n'], header='脚本启动于 2026-09-05 09:49:18+00:00 [COLUMNS="-1" LINES="-1"]\n')
        event = self.build()["events"][0]
        self.assertEqual(event["content"], "pwd")
        self.assertEqual(event["observed_at"], "2026-09-05T09:49:19+00:00")

    def test_user_reply_and_final_display_are_independent(self):
        self.recording([PROMPT + 'claude\r\n', '❯ 问题\r\n', '● 答', '案\r\n❯ \r\n? for shortcuts\r\n'])
        events = self.build()["events"]
        user = next(e for e in events if e["type"] == "claude_user_observed")
        answer = next(e for e in events if e["type"] == "claude_reply_observed")
        self.assertEqual(user["elapsed_seconds"], 2)
        self.assertEqual(answer["elapsed_seconds"], 3)
        self.assertEqual(answer["final_text_first_elapsed_seconds"], 4)
        self.assertEqual(answer["content"], "答案")
        self.assertEqual(answer["related_event_id"], user["event_id"])
        self.assertEqual(answer["source"]["observation"]["timing_line"], 3)

    def test_echo_claude_is_not_launch(self):
        for command in ('echo claude', "printf 'claude'", 'cat file | grep claude',
                        'env -u claude bash', 'command -v claude', 'sudo -u claude bash'):
            self.assertFalse(timeline.is_claude_launch(command))
        for command in ('claude', 'FOO=bar claude', 'cd lab0 && claude', 'env FOO=bar /bin/claude',
                        'sudo claude', 'sudo -u root claude', 'env -u FOO claude'):
            self.assertTrue(timeline.is_claude_launch(command))
        self.recording([PROMPT + 'echo claude\r\nclaude\r\n'])
        self.assertEqual(self.build()["events"][0]["output"][0], "claude")

    def test_unfinished_reply_is_recorded_as_unretained(self):
        self.recording([PROMPT + 'claude\r\n', '❯ 问题\r\n● 尚在生成\r\n'])
        result = self.build()
        self.assertEqual(len(result["events"]), 1)
        self.assertEqual(result["recording_details"][0]["claude_incomplete_record_count"], 1)
        self.assertEqual(result["recording_details"][0]["claude_unretained_record_count"], 1)

    def test_invalid_or_excess_timing_cannot_supply_event_time(self):
        self.recording([PROMPT + 'pwd\r\n'], delays=[-1])
        event = self.build()["events"][0]
        self.assertIsNone(event["elapsed_seconds"])
        self.recording([PROMPT + 'pwd\r\n'], sizes=[99999])
        event = self.build()["events"][0]
        self.assertIsNone(event["elapsed_seconds"])
        self.assertIn("timing_block_exceeds_available_body", event["uncertainty"])

    def test_conflicting_session_starts_preserve_relative_time(self):
        self.recording([PROMPT + 'pwd\r\n'])
        (self.root / "logs").mkdir()
        starts = [{"type": "session_start", "rec": "r", "ts": ts, "tty": "/dev/pts/2"}
                  for ts in ("2026-09-10T22:21:12+08:00", "2026-09-10T22:22:12+08:00")]
        (self.root / "logs/events.jsonl").write_text("\n".join(json.dumps(x) for x in starts), encoding="utf-8")
        event = self.build()["events"][0]
        self.assertIsNone(event["observed_at"])
        self.assertEqual(event["elapsed_seconds"], 1)
        self.assertIn("conflicting_session_start_records", event["uncertainty"])

    def test_repeated_question_gets_distinct_identity(self):
        self.recording([PROMPT + 'claude\r\n', '❯ 同问\r\n● 甲\r\n❯ \r\n',
                        '❯ 别问\r\n● 乙\r\n❯ \r\n', '❯ 同问\r\n● 丙\r\n❯ \r\n'])
        users = [e for e in self.build()["events"] if e["type"] == "claude_user_observed"]
        self.assertEqual([e["content"] for e in users], ["同问", "别问", "同问"])
        self.assertEqual([e["elapsed_seconds"] for e in users], [2, 3, 4])
        self.assertEqual(len({e["event_id"] for e in users}), 3)

    def test_missing_term_is_reported(self):
        result = timeline.build_student_timeline({"source": str(self.root / 'absent')})
        self.assertTrue(result["errors"])


if __name__ == "__main__":
    unittest.main()
