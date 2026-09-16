import json
import unittest
from pathlib import Path
from ai_experience_terminal import build_terminal_report, literal


def cast(events, **header):
    meta = {'version': 2, 'width': 80, 'height': 24, 'timestamp': 0, 'lab_id': 'lab'}
    meta.update(header)
    return '\n'.join(json.dumps(v) for v in [meta] + events).encode()


class TerminalReportTests(unittest.TestCase):
    def test_repeat_and_stale_logs(self):
        events = [[0, 'o', '\x1b[?2004h[root@host lab]# '],
                  [1, 'o', 'echo yes'], [2, 'o', '\r\n\x1b[?2004l\r'],
                  [3, 'o', 'yes\r\n\x1b[?2004h[root@host lab]# '],
                  [4, 'o', '\r\n\x1b[?2004l\r'],
                  [5, 'o', '\x1b[?2004h[root@host lab]# '],
                  [6, 'o', 'echo yes'], [7, 'o', '\r\n\x1b[?2004l\r'],
                  [8, 'o', 'yes\r\n']]
        logs = [{'session': 'one', 'cmd': 'echo yes', 'rc': 0, 'ts': '2026-09-01T00:00:00'} for _ in range(3)]
        report, stats = build_terminal_report({'casts/one.cast': cast(events), 'workspace/.labtracker/commands.jsonl': '\n'.join(map(json.dumps, logs)).encode()}, {})
        self.assertEqual(stats['commands'], 2)
        self.assertIn('未匹配命令日志', report)
        self.assertIn('2026-09-01T00:00:00', report)
        self.assertIn('返回码：0', report)

    def test_sample_three_commands(self):
        root = Path(__file__).parent / '示例数据'
        if not root.exists():
            self.skipTest('Sample unavailable')
        report, stats = build_terminal_report({p.relative_to(root).as_posix(): p.read_bytes() for p in root.rglob('*') if p.is_file()}, {})
        self.assertEqual(stats['commands'], 3)
        self.assertEqual(stats['recordings'], 3)
        self.assertIn('SyntaxError', report)
        self.assertEqual(stats['issues'], [])

    def test_corrupt_and_unknown_and_missing_time(self):
        raw = cast([[0, 'o', 'initial\r\n'], [1, 'r', '40x30'], [2, 'x', '<script>test</script>'], [3, 'o', 'tail']], timestamp=None)
        raw += b'\nnot json\n[4,"o",42]\n[5,"r","bad"]'
        report, stats = build_terminal_report({'casts/t.cast': raw}, {})
        self.assertGreaterEqual(len(stats['issues']), 3)
        self.assertIn('绝对时间未知', report)
        self.assertIn('initial', report)
        self.assertIn('tail', report)
        self.assertIn('40x30', report)
        self.assertIn('原始事件 x', report)

    def test_backspace_and_ansi(self):
        report, stats = build_terminal_report({'casts/t.cast': cast([[0, 'o', '\x1b[?2004h[root@host lab]# '], [1, 'o', 'echx\bo hi'], [2, 'o', '\r\n\x1b[?2004l\r'], [3, 'o', '\x1b[31mhi\x1b[0m\r\n']])}, {})
        self.assertEqual(stats['commands'], 1)
        self.assertIn('echo hi', report)
        self.assertNotIn('\x1b', report)

    def test_same_chunk_submission(self):
        report, stats = build_terminal_report({'casts/t.cast': cast([[0, 'o', '\x1b[?2004h[root@host lab]# echo hello\r\n\x1b[?2004l\rhello\r\n']])}, {})
        self.assertEqual(stats['commands'], 1)
        self.assertIn('echo hello', report)
        self.assertIn('hello', report.split('### 按录像顺序的画面记录')[0])

    def test_bad_header_other_file_continues(self):
        report, stats = build_terminal_report({'casts/bad.cast': b'bad\n[0,"o","x"]', 'casts/ok.cast': cast([[0, 'o', 'ok']])}, {})
        self.assertEqual(stats['recordings'], 1)
        self.assertIn('ok', report)
        self.assertTrue(stats['issues'])

    def test_fence_is_safe(self):
        self.assertTrue(literal('```\n<script>\n```').startswith('````text'))

    def test_plain_shell_output_not_command(self):
        report, stats = build_terminal_report({'casts/t.cast': cast([[0, 'o', '[root@host lab]# echo hi'], [1, 'o', '\r\n'], [2, 'o', 'hi\r\nsecond line\r\n']])}, {})
        self.assertEqual(stats['commands'], 1)


if __name__ == '__main__':
    unittest.main()
