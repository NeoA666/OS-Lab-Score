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
    def test_full_exports_final_text_and_preserves_history(self):
        out, tim = recording(self.root / 'term', chunks=[
            '▐▛███▜▌ Claude Code\r\n─界面─\r\n', '✻ Computing…',
            '\r\x1b[2K完成\r\n', 'Resume this session with:\r\nclaude --resume abc\r\n'])
        full = app.replay_full_terminal(out, tim)
        text = '\n'.join(full['lines'])
        self.assertNotIn('frames', full)
        self.assertNotIn('✻ Computing…', text)
        self.assertIn('完成', text)
        for marker in ['▐▛███▜▌', '─界面─', 'Resume this session with:']:
            self.assertIn(marker, text)
    def test_full_collapses_character_frames_and_keeps_clear_history(self):
        out, tim = recording(self.root / 'term', chunks=[
            '清屏之前的内容\r\n', '\x1b[2J\x1b[H', *list('hello'), '\r\n'])
        full = app.replay_full_terminal(out, tim)
        self.assertIn('清屏之前的内容', full['lines'])
        self.assertIn('hello', full['lines'])
        self.assertEqual(full['lines'].count('hello'), 1)
        for partial in ('h', 'he', 'hel', 'hell'):
            self.assertNotIn(partial, full['lines'])
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
            for filename in app.lab_report_paths("lab0"):
                text = (output / name / filename).read_text(encoding='utf-8')
                self.assertIn('- 学号：', text)
                self.assertIn('- 姓名：张伟', text)
                self.assertIn('- 数据采集时间：', text)
            self.assertFalse((output / name / 'term_qa_report.md').exists())
        full = (output / '张伟-123' / app.lab_report_paths('other')[1]).read_text(encoding='utf-8')
        self.assertIn('broken.out.gz', full)
        self.assertIn('- 重放失败数量：1', full)
        qa = (output / '张伟-456' / app.lab_report_paths('lab0')[3]).read_text(encoding='utf-8')
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
        self.assertIn('- 学号：未知', (output / '未知' / app.lab_report_paths('lab0')[0]).read_text(encoding='utf-8'))
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
        self.assertTrue((output / 'B' / app.lab_report_paths('lab0')[3]).is_file())
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
    def test_lab_path_segments(self):
        for number in range(9):
            self.assertEqual(app.lab_from_cwd(f'/home/a/lab{number}/kernel'), f'lab{number}')
        for path in ('/lab10', '/lab0-copy', '/mylab1', '~/lab0/../other', '/tmp'):
            self.assertEqual(app.lab_from_cwd(path), 'other')
        self.assertEqual(app.lab_from_cwd(r'C:\course\lab8\kernel'), 'lab8')
        self.assertEqual(app.lab_from_cwd('/lab0/../lab2'), 'lab2')
    def test_multiple_labs_in_one_recording(self):
        root, output = self.root / 'input', self.root / 'output'
        term = root / '123-学生-20260911-2046' / 'term'
        prompt = lambda cwd: PROMPT.replace('~/lab0', cwd)
        chunks = [prompt('~') + 'cd lab0\r\n',
                  prompt('~/lab0') + 'claude\r\n',
                  '❯ 比较 lab1 和 lab8，但我仍在 lab0\r\n● ZERO_ANSWER_ONE\r\n❯ \r\n',
                  'Resume this session with:\r\nclaude --resume zero\r\n',
                  prompt('~/lab0') + 'cd ../lab1\r\n',
                  prompt('~/lab1/kernel') + 'claude\r\n',
                  '❯ LAB_ONE_QUESTION\r\n● ONE_ANSWER\r\n❯ \r\n',
                  prompt('~/lab1/kernel') + 'cd ../../lab0\r\n',
                  prompt('~/lab0') + 'claude\r\n',
                  '❯ LAB_ZERO_SECOND\r\n● ZERO_ANSWER_TWO\r\n❯ \r\n',
                  prompt('~/lab0') + 'cd /tmp\r\n', prompt('/tmp') + 'echo OUTSIDE\r\nOUTSIDE\r\n']
        recording(term, chunks=chunks)
        with contextlib.redirect_stdout(io.StringIO()):
            info = app.parse_student_name(term.parent.name)
            info.update(source=str(term.parent.resolve()), output=output / '学生')
            result = app.process_student(info)
        self.assertEqual(result['status'], '成功')
        self.assertEqual(result['recordings'], 1)
        self.assertEqual(result['commands'], 8)
        self.assertEqual(result['claude_sessions'], 1)
        self.assertEqual(result['turns'], 3)
        self.assertEqual(set(result['labs']), {'lab0', 'lab1', 'other'})
        self.assertEqual(result['labs']['lab0']['turns'], 2)
        for lab in result['labs']:
            for path in app.lab_report_paths(lab):
                self.assertTrue((info['output'] / path).is_file())
        zero = (info['output'] / app.lab_report_paths('lab0')[3]).read_text(encoding='utf-8')
        one = (info['output'] / app.lab_report_paths('lab1')[3]).read_text(encoding='utf-8')
        self.assertIn('ZERO_ANSWER_ONE', zero)
        self.assertIn('ZERO_ANSWER_TWO', zero)
        self.assertNotIn('ONE_ANSWER', zero)
        self.assertIn('### Turn 2', zero)
        self.assertIn('ONE_ANSWER', one)
        self.assertNotIn('ZERO_ANSWER', one)
        zero_full = (info['output'] / app.lab_report_paths('lab0')[1]).read_text(encoding='utf-8')
        self.assertIn('ZERO_ANSWER_ONE', zero_full)
        self.assertIn('ZERO_ANSWER_TWO', zero_full)
        self.assertNotIn('ONE_ANSWER', zero_full)
        self.assertNotIn('OUTSIDE', zero_full)
        self.assertNotIn('### Frame', zero_full)
        self.assertNotIn('1: ', zero_full)
        stats = (info['output'] / app.lab_report_paths('lab0')[2]).read_text(encoding='utf-8')
        self.assertIn('| claude | 2 |', stats)
        self.assertIn('| cd ../lab1 | 1 |', stats)
    def test_regions_preserve_bytes_and_absolute_timing(self):
        body = (PROMPT + 'cd ../lab1\r\n' + PROMPT.replace('lab0','lab1') + 'ls\r\n').encode()
        regions = app.split_lab_regions(body)
        self.assertEqual([r['lab'] for r in regions], ['lab0','lab1'])
        self.assertEqual(b''.join(body[r['begin']:r['end']] for r in regions), body)
        # 同一 timing 帧包含两个 lab，两个片段都保留该帧的原始时间。
        for r in regions:
            entries = app.region_timing([(2.5,len(body))],r['begin'],r['end'])
            self.assertEqual(sum(size for _,size in entries),r['end']-r['begin'])
            self.assertEqual(sum(delay for delay,_ in entries),2.5)
        self.assertEqual(app.region_timing([], 4, 10), [(0.0,6)])
    def test_other_and_failed_cd_are_not_guessed(self):
        prompt = PROMPT.replace('~/lab0','~')
        body=(prompt+'cd lab0\r\nNo such directory\r\n'+prompt+'claude\r\n❯ lab8\r\n● lab0\r\n').encode()
        self.assertEqual([r['lab'] for r in app.split_lab_regions(body)], ['other'])
        self.assertEqual(app.split_lab_regions('❯ lab0\n● lab1\n'.encode())[0]['lab'], 'other')
        self.assertEqual(app.split_lab_regions(b'user@host:~/lab2$ ls\r\n')[0]['lab'], 'lab2')
    def test_split_without_timing_and_old_layout_migration(self):
        root, output = self.root / 'input', self.root / 'output'
        student = root / '123-学生-20260911-2046'
        chunks=[PROMPT+'echo ZERO\r\nZERO\r\n',
                PROMPT.replace('lab0','lab8')+'echo EIGHT\r\nEIGHT\r\n']
        recording(student/'term',chunks=chunks,timing=False)
        target=output/'学生'
        target.mkdir(parents=True)
        for name in app.REPORT_NAMES:
            (target/name).write_text('old generated report',encoding='utf-8')
        (target/'notes.md').write_text('keep me',encoding='utf-8')
        (target/app.OWNER_FILE).write_text(json.dumps({'tool':'replay_term_qa',
            'source':str(student.resolve()),'reports':list(app.REPORT_NAMES)}),encoding='utf-8')
        self.assertEqual(self.run_app(root, output),0)
        self.assertTrue(all(not (target/name).exists() for name in app.REPORT_NAMES))
        self.assertEqual((target/'notes.md').read_text(encoding='utf-8'),'keep me')
        for lab in ('lab0','lab8'):
            self.assertTrue(all((target/name).is_file() for name in app.lab_report_paths(lab)))
        eight=(target/app.lab_report_paths('lab8')[1]).read_text(encoding='utf-8')
        self.assertIn('EIGHT',eight)
        self.assertNotIn('ZERO',eight)
    def test_table_and_sort(self):
        md = []
        app.add_statistics_table(md, app.Counter({'z': 2, 'a': 2, r'grep x | cat C:\path': 1}))
        self.assertLess(md.index('| a | 2 |'), md.index('| z | 2 |'))
        self.assertIn(r'\|', '\n'.join(md))
        self.assertIn(r'\\path', '\n'.join(md))


if __name__ == '__main__':
    unittest.main()
