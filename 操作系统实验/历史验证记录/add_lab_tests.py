from pathlib import Path
p=Path('test_replay_term_qa.py')
s=p.read_text(encoding='utf-8')
pos=s.index('    def test_table_and_sort(')
s=s[:pos]+'''    def test_lab_path_segments(self):
        for number in range(9):
            self.assertEqual(app.lab_from_cwd(f'/home/a/lab{number}/kernel'), f'lab{number}')
        for path in ('/lab10', '/lab0-copy', '/mylab1', '~/lab0/../other', '/tmp'):
            self.assertEqual(app.lab_from_cwd(path), 'other')
        self.assertEqual(app.lab_from_cwd(r'C:\\course\\lab8\\kernel'), 'lab8')
        self.assertEqual(app.lab_from_cwd('/lab0/../lab2'), 'lab2')
    def test_multiple_labs_in_one_recording(self):
        root, output = self.root / 'input', self.root / 'output'
        term = root / '123-学生-20260911-2046' / 'term'
        prompt = lambda cwd: PROMPT.replace('~/lab0', cwd)
        chunks = [prompt('~') + 'cd lab0\\r\\n',
                  prompt('~/lab0') + 'claude\\r\\n',
                  '❯ 比较 lab1 和 lab8，但我仍在 lab0\\r\\n● ZERO_ANSWER_ONE\\r\\n❯ \\r\\n',
                  'Resume this session with:\\r\\nclaude --resume zero\\r\\n',
                  prompt('~/lab0') + 'cd ../lab1\\r\\n',
                  prompt('~/lab1/kernel') + 'claude\\r\\n',
                  '❯ LAB_ONE_QUESTION\\r\\n● ONE_ANSWER\\r\\n❯ \\r\\n',
                  prompt('~/lab1/kernel') + 'cd ../../lab0\\r\\n',
                  prompt('~/lab0') + 'claude\\r\\n',
                  '❯ LAB_ZERO_SECOND\\r\\n● ZERO_ANSWER_TWO\\r\\n❯ \\r\\n',
                  prompt('~/lab0') + 'cd /tmp\\r\\n', prompt('/tmp') + 'echo OUTSIDE\\r\\nOUTSIDE\\r\\n']
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
        stats = (info['output'] / app.lab_report_paths('lab0')[2]).read_text(encoding='utf-8')
        self.assertIn('| claude | 2 |', stats)
        self.assertIn('| cd ../lab1 | 1 |', stats)
    def test_regions_preserve_bytes_and_absolute_timing(self):
        body = (PROMPT + 'cd ../lab1\\r\\n' + PROMPT.replace('lab0','lab1') + 'ls\\r\\n').encode()
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
        body=(prompt+'cd lab0\\r\\nNo such directory\\r\\n'+prompt+'claude\\r\\n❯ lab8\\r\\n● lab0\\r\\n').encode()
        self.assertEqual([r['lab'] for r in app.split_lab_regions(body)], ['other'])
        self.assertEqual(app.split_lab_regions('❯ lab0\\n● lab1\\n'.encode())[0]['lab'], 'other')
        self.assertEqual(app.split_lab_regions(b'user@host:~/lab2$ ls\\r\\n')[0]['lab'], 'lab2')
    def test_split_without_timing_and_old_layout_migration(self):
        root, output = self.root / 'input', self.root / 'output'
        student = root / '123-学生-20260911-2046'
        chunks=[PROMPT+'echo ZERO\\r\\nZERO\\r\\n',
                PROMPT.replace('lab0','lab8')+'echo EIGHT\\r\\nEIGHT\\r\\n']
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
''' +s[pos:]
p.write_text(s,encoding='utf-8')
