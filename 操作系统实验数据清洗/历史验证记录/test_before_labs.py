"""批处理边界和终端语义回归测试；临时夹具不会修改学生原始数据。"""
import contextlib
import gzip
import io
import json
from pathlib import Path
import tempfile
import unittest
from unittest import mock
import replay_term_qa as app

PROMPT = '\x1b[01;32mailab-os@ailab-os-VMware-Virtual-Platform\x1b[00m:\x1b[01;34m~/lab0\x1b[00m$ '


def recording(term, name='session', chunks=None, timing=True):
    term.mkdir(parents=True, exist_ok=True)
    chunks = chunks or [PROMPT + 'claude\r\n', '▐▛███▜▌ Claude Code\r\n',
                       '❯ 分析 Makefile\r\n', '● 最终回答\r\n', '─' * 60 + '\r\n❯ \r\n? for shortcuts\r\n']
    parts = [part.encode('utf-8') for part in chunks]
    header = b'Script started on 2026-09-10 22:21:12+08:00 [COLUMNS="80" LINES="24"]\n'
    out = term / (name + '.out.gz')
    out.write_bytes(gzip.compress(header + b''.join(parts)))
    tim = term / (name + '.tim.gz')
    if timing:
        tim.write_bytes(gzip.compress(''.join(f'0.1 {len(part)}\n' for part in parts).encode()))
    return out, tim


class BatchTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(dir=Path(__file__).parent)
        self.root = Path(self.temp.name)
    def tearDown(self):
        self.temp.cleanup()
    def run_app(self, root, output, *args):
        with contextlib.redirect_stdout(io.StringIO()):
            return app.main([str(root), '-o', str(output), *args])
    def test_metadata(self):
        for name in ('123-Anne-Marie-20260911-2046', '123-Anne-Marie-实验提交-20260911-2046-2.tar.gz'):
            info = app.parse_student_name(name)
            self.assertEqual(info['name'], 'Anne-Marie')
            self.assertEqual(info['collected'], '2026-09-11 20:46')
        info = app.parse_student_name('123-名字-20261399-2561-2')
        self.assertEqual(info['raw_time'], '20261399-2561')
        self.assertIn('无法解析', info['collected'])
        self.assertIsNone(app.parse_student_name('unrelated'))
    def test_shell_and_screen_qa(self):
        out, tim = recording(self.root / 'term')
        commands = app.extract_session(str(out), str(tim))[2]
        self.assertEqual([c['command'] for c in commands], ['claude'])
        pairs = app.extract_claude_session(str(out), str(tim))[1]
        self.assertEqual(pairs, [{'user': '分析 Makefile', 'claude': '最终回答'}])
        self.assertEqual(app.read_term(out)[1], '2026-09-10 22:21:12+08:00')
    def test_unfinished_and_tool_permission(self):
        chunks = ['❯ 用户问题\r\n', '● Bash(ls)\r\n  ⎿ file\r\n',
                  'Do you want to proceed?\r\n❯ 1. Yes\r\n  2. No\r\n',
                  '● Thinking for 2s\r\n  内部思考\r\n',
                  '● 尚未完成\r\n✻ Computing…\r\n❯ \r\nesc to interrupt\r\n']
        out, tim = recording(self.root / 'term', chunks=chunks)
        self.assertEqual(app.extract_claude_session(str(out), str(tim))[1], [])
        blocks = app.parse_claude_blocks('❯ 问题\n● Bash(ls)\n  工具内容\n● Thinking for 2s\n  思考内容\n● 完成\n❯ \n'.splitlines())
        self.assertEqual(blocks, [('user', '问题'), ('claude', '完成')])
    def test_full_preserves_overwritten_tui(self):
        out, tim = recording(self.root / 'term', chunks=[
            '▐▛███▜▌ Claude Code\r\n─界面─\r\n', '✻ Computing…',
            '\r\x1b[2K完成\r\n', 'Resume this session with:\r\nclaude --resume abc\r\n'])
        full = app.replay_full_terminal(out, tim)
        text = '\n'.join(line for _, _, lines in full['frames'] for _, line in lines)
        for marker in ['▐▛███▜▌', '─界面─', '✻ Computing…', 'Resume this session with:']:
            self.assertIn(marker, text)
    def test_batch_isolation_errors_and_atomic_rerun(self):
        root, output = self.root / 'input', self.root / 'output'
        a = root / '123-张伟-20260911-2046'
        b = root / '456-张伟-20261311-2046'
        recording(a / 'term', timing=False)
        recording(b / 'term')
        (a / 'term' / 'broken.out.gz').write_bytes(b'not gzip')
        (root / '789-跳过-20260911-2046').mkdir()
        (root / 'unexpected').mkdir()
        snapshots = {p: p.read_bytes() for p in root.rglob('*') if p.is_file()}
        self.assertEqual(self.run_app(root, output), 1)
        self.assertTrue((output / 'README.md').exists())
        for name in ('张伟-123', '张伟-456'):
            for filename in app.REPORT_NAMES:
                text = (output / name / filename).read_text(encoding='utf-8')
                self.assertIn('- 学号：', text)
                self.assertIn('- 姓名：张伟', text)
                self.assertIn('- 数据采集时间：', text)
            self.assertFalse((output / name / 'term_qa_report.md').exists())
        full = (output / '张伟-123' / 'full_terminal_transcript.md').read_text(encoding='utf-8')
        self.assertIn('broken.out.gz', full)
        self.assertIn('- 成功重放数量：1', full)
        qa = (output / '张伟-456' / 'claude_qa_clean.md').read_text(encoding='utf-8')
        self.assertIn('### Turn 1', qa)
        self.assertIn('## Session 1：', qa)
        self.assertIn('- 对话轮次总数：1', qa)
        before = {p: p.read_bytes() for p in output.rglob('*.md')}
        self.assertEqual(self.run_app(root, output), 1)
        self.assertEqual(before, {p: p.read_bytes() for p in output.rglob('*.md')})
        self.assertEqual(snapshots, {p: p.read_bytes() for p in root.rglob('*') if p.is_file()})
        self.assertEqual(self.run_app(root, output, '--student', '456'), 0)
        self.assertFalse((output / '张伟').exists())
    def test_single_unknown_and_existing_collision(self):
        root, output = self.root / 'legacy', self.root / 'output'
        recording(root / 'term')
        self.assertEqual(self.run_app(root, output), 0)
        self.assertIn('- 学号：未知', (output / '未知' / app.REPORT_NAMES[0]).read_text(encoding='utf-8'))
        another = self.root / 'other'
        recording(another / 'term')
        self.assertEqual(self.run_app(another, output, '--overwrite'), 0)
        owners = [json.loads(p.read_text(encoding='utf-8'))['source'] for p in output.glob('*/.replay_term_qa.json')]
        self.assertEqual(len(set(owners)), 2)
    def test_duplicate_capture_and_portable_names(self):
        root, output = self.root / 'input', self.root / 'output'
        for name in ('123-Anne-Marie-20260911-2046', '123-Anne-Marie-20260911-2046-1', '456-anne-marie-20260911-2046'):
            recording(root / name / 'term')
        self.assertEqual(self.run_app(root, output), 0)
        dirs = [p.name.casefold() for p in output.iterdir() if p.is_dir()]
        self.assertEqual(len(set(dirs)), 3)
        self.assertNotEqual(app.safe_component('a:b'), app.safe_component('a?b'))
    def test_student_failure_continues(self):
        root, output = self.root / 'input', self.root / 'output'
        for name in ('123-A-20260911-2046', '456-B-20260911-2046'):
            recording(root / name / 'term')
        original = app.process_student
        def process(info):
            if info['student_id'] == '123':
                raise OSError('模拟学生级读取失败')
            return original(info)
        with mock.patch.object(app, 'process_student', side_effect=process):
            self.assertEqual(self.run_app(root, output), 1)
        self.assertTrue((output / 'B' / 'claude_qa_clean.md').is_file())
        readme = (output / 'README.md').read_text(encoding='utf-8')
        self.assertIn('模拟学生级读取失败', readme)
        self.assertIn('123-A-20260911-2046', readme)
    def test_atomic_failure_preserves_previous_file(self):
        target = self.root / 'report.md'
        target.write_text('old report', encoding='utf-8')
        with mock.patch.object(app.os, 'replace', side_effect=OSError('模拟替换失败')):
            with self.assertRaises(OSError):
                app.atomic_write(target, 'new report')
        self.assertEqual(target.read_text(encoding='utf-8'), 'old report')
        self.assertEqual(list(self.root.glob('.replay-*.tmp')), [])
    def test_streaming_redraw_and_multiple_turns(self):
        chunks = ['❯ 第一个问题\r\n● **这是一段正在逐字输出的回答',
                  '\r\x1b[2K● 这是一段正在逐字输出的回答，现已完整。\r\n❯ \r\n',
                  '❯ 第二个问题\r\n● Thinking for 1m 2s\r\n  不应导出\r\n',
                  '● Bash(ls)\r\n  ⎿ file\r\n',
                  '● 第二个最终回答。\r\n❯ \r\n']
        out, tim = recording(self.root / 'term', chunks=chunks)
        pairs = app.extract_claude_session(str(out), str(tim))[1]
        self.assertEqual(len(pairs), 2)
        self.assertEqual(pairs[0]['claude'], '这是一段正在逐字输出的回答，现已完整。')
        self.assertEqual(pairs[1]['claude'], '第二个最终回答。')
    def test_login_error_not_final_answer(self):
        out, tim = recording(self.root / 'term', chunks=[
            '❯ 你好\r\n● Please run /login · API Error: 401\r\n❯ \r\n'])
        self.assertEqual(app.extract_claude_session(str(out), str(tim))[1], [])
    def test_markdown_bullets_are_message_content(self):
        self.assertEqual(app.clean_claude_message(['回答', '* 保留条目', '· 普通项目']),
                         '回答\n* 保留条目\n· 普通项目')
    def test_table_and_sort(self):
        md = []
        app.add_statistics_table(md, app.Counter({'z': 2, 'a': 2, r'grep x | cat C:\path': 1}))
        self.assertLess(md.index('| a | 2 |'), md.index('| z | 2 |'))
        self.assertIn(r'\|', '\n'.join(md))
        self.assertIn(r'\\path', '\n'.join(md))


if __name__ == '__main__':
    unittest.main()
