"""核对真实批处理产物、原脚本命令结果与原始文件 SHA-256。"""
import ast
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import sys
sys.path.insert(0, str(Path.cwd()))
import replay_term_qa as app

root = Path('操作系统实验数据记录')
out = root.with_name(root.name + '-已清洗')
baseline = json.loads(Path('.verification/baseline.json').read_text(encoding='utf-8'))
old_ast = ast.parse(Path('.verification/replay_term_qa_original.py').read_text(encoding='utf-8'))
new_ast = ast.parse(Path('replay_term_qa.py').read_text(encoding='utf-8'))
for name in ['extract_session', 'clean_command', 'normalize_command', 'render_region', 'join_wrapped']:
    original = next(n for n in old_ast.body if isinstance(n, ast.FunctionDef) and n.name == name)
    current = next(n for n in new_ast.body if isinstance(n, ast.FunctionDef) and n.name == name)
    assert ast.dump(original) == ast.dump(current), name
print('PASS: Shell extraction core unchanged')

students, skipped = app.scan_students(root.resolve())
app.allocate_outputs(students, out.resolve())
assert len(students) == 12 and not skipped
assert {'2306010113','2406080118','2406080205'} <= {s['student_id'] for s in students}
sums = Counter()
noise = re.compile(r'[\u2500-\u257f]|▐▛|▝▜|[✻✢✶✽]|Resume this session with:|esc to interrupt|\? for shortcuts|^Thinking for|^Bash\(', re.M)
for student in students:
    directory = student['output']
    docs = {name: (directory / name).read_text(encoding='utf-8') for name in app.REPORT_NAMES}
    assert not (directory / 'term_qa_report.md').exists()
    for name, text in docs.items():
        for key in ['student_id', 'name']:
            assert app.markdown_text(student[key]) in text, (directory, name, key)
        assert student['collected'] in text, (directory, name)
    expected = Counter(c['command'] for p, data in baseline.items()
                       if Path(p).parent.parent.name == student['source_name'] for c in data['commands'])
    table=[]
    app.add_statistics_table(table, expected)
    assert '\n'.join(table).strip() in docs['command_statistics.md'], directory
    assert not any(command.startswith('❯') for command in expected)
    sums['claude_launches'] += sum(n for command,n in expected.items() if command == 'claude' or command.startswith('claude '))
    qa=docs['claude_qa_clean.md']
    count=lambda label: int(re.search(r'^- '+label+r'：(\d+)$',qa,re.M).group(1))
    turns=re.findall(r'^### Turn (\d+)$',qa,re.M)
    per_session=[int(n) for n in re.findall(r'^- 对话轮次：(\d+)$',qa,re.M)]
    assert count('对话轮次总数') == sum(per_session) == len(turns)
    assert count('有效用户问题数') == count('有效 Claude 回复数') == len(turns)
    assert count('Claude 会话总数') == len(per_session)
    for session in re.split(r'^## Session \d+：',qa,flags=re.M)[1:]:
        numbers=[int(n) for n in re.findall(r'^### Turn (\d+)$',session,re.M)]
        assert numbers == list(range(1,len(numbers)+1))
    assert not noise.search(qa), (directory, noise.search(qa).group(0) if noise.search(qa) else '')
    qa_pairs = [(x.split('\n\n#### Claude\n\n',1)) for x in re.split(r'^#### User\n\n',qa,flags=re.M)[1:]]
    sums['students']+=1
    sums['recordings']+=len(list((Path(student['source'])/'term').glob('*.out.gz')))
    sums['commands']+=sum(expected.values())
    sums['claude_sessions']+=len(per_session)
    sums['turns']+=len(turns)
    sums['replay_failed']+=int(re.search(r'^- 重放失败数量：(\d+)$',docs['full_terminal_transcript.md'],re.M).group(1))
assert sums['claude_launches']>0
all_full='\n'.join(p.read_text(encoding='utf-8') for p in out.glob('*/full_terminal_transcript.md'))
for marker in ['Resume this session with:', '▐▛', '─', '✻', '? for shortcuts', 'Thinking']:
    assert marker in all_full, marker
assert '20260909T120838-19233.out.gz' in all_full
print('PASS: all reports, metadata, Shell baseline, QA totals/filtering, complete TUI and failure isolation')

manifest=json.loads(Path('.verification/input_manifest_before.json').read_text(encoding='utf-8-sig'))
assert {str(p.resolve()) for p in root.rglob('*') if p.is_file()} == {v['Path'] for v in manifest}
for item in manifest:
    p=Path(item['Path'])
    assert p.stat().st_size == item['Length']
    assert hashlib.sha256(p.read_bytes()).hexdigest().upper() == item['Hash'], p
    # Windows 文件时间 ticks 精度由 PowerShell 原值在单独清单核对。
print('PASS: all',len(manifest),'original files have identical paths, sizes and SHA-256')
print(json.dumps(dict(sums),ensure_ascii=False,indent=2))
Path('.verification/acceptance_summary.json').write_text(json.dumps(dict(sums),ensure_ascii=False,indent=2),encoding='utf-8')
