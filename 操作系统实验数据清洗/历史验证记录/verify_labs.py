"""核对真实数据分类结果：命令/QA 不丢失、不重复，分类隔离，原始文件不变。"""
import json, hashlib, re, sys
from collections import Counter, defaultdict
from pathlib import Path
sys.path.insert(0,str(Path.cwd()))
import replay_term_qa as app
root=Path('学生操作系统实验数据爬取/操作系统实验数据记录')
out=root.with_name(root.name+'-已清洗')
old_out=Path('操作系统实验数据记录-已清洗')
old_commands=json.loads(Path('.verification/baseline.json').read_text(encoding='utf-8'))
noise=re.compile(r'[\u2500-\u257f]|▐▛|▝▜|[✻✢✶✽]|Resume this session with:|esc to interrupt|\? for shortcuts|^Thinking for|^Bash\(',re.M)

def pairs(text):
    return [block.strip() for block in re.findall(r'^### Turn \d+\n\n#### User\n\n(.*?)(?=^### Turn \d+\n|^## Session |\Z)',text,re.M|re.S)]

students,_=app.scan_students(root.resolve())
app.allocate_outputs(students,out.resolve())
totals=Counter(); lab_totals=defaultdict(Counter)
for student in students:
    directory=student['output']
    owner=json.loads((directory/app.OWNER_FILE).read_text(encoding='utf-8'))
    assert owner['layout']=='by-lab-v1'
    assert all(not (directory/name).exists() for name in app.REPORT_NAMES)
    assert {p.relative_to(directory).as_posix() for p in directory.rglob('*.md')}==set(owner['reports'])
    counts=defaultdict(Counter)
    for path,data in old_commands.items():
        if Path(path).parent.parent.name==student['source_name']:
            for command in data['commands']:
                counts[app.lab_from_cwd(command['cwd'])][command['command']]+=1
    student_pairs=[]; sessions=set()
    for lab in app.LAB_KEYS:
        paths=app.lab_report_paths(lab)
        if not (directory/paths[0]).exists():
            assert not counts[lab]
            continue
        docs=[(directory/path).read_text(encoding='utf-8') for path in paths]
        for text in docs:
            assert f'- 学号：{student["student_id"]}' in text
            assert f'- 姓名：{app.markdown_text(student["name"])}' in text
            assert f'- 数据采集时间：{student["collected"]}' in text
            assert '- 实验分类：' in text
        expected=[]; app.add_statistics_table(expected,counts[lab])
        assert '\n'.join(expected).strip() in docs[2],(directory,lab)
        qa=docs[3]
        turns=[int(x) for x in re.findall(r'^- 对话轮次：(\d+)$',qa,re.M)]
        n=int(re.search(r'^- 对话轮次总数：(\d+)$',qa,re.M).group(1))
        assert n==sum(turns)==len(re.findall(r'^### Turn \d+$',qa,re.M))
        assert not noise.search(qa),(directory,lab)
        for segment in re.split(r'^## Session \d+：',qa,flags=re.M)[1:]:
            nums=[int(x) for x in re.findall(r'^### Turn (\d+)$',segment,re.M)]
            assert nums==list(range(1,len(nums)+1))
        sessions.update(re.findall(r'^## Session \d+：(.+)$',qa,re.M))
        student_pairs.extend(pairs(qa))
        lab_totals[lab]['commands']+=sum(counts[lab].values())
        lab_totals[lab]['turns']+=n
        lab_totals[lab]['recordings']+=int(re.search(r'^- 终端录像数量：(\d+)$',qa,re.M).group(1))
        lab_totals[lab]['claude_sessions']+=len(turns)
    old_path=old_out/directory.name/'claude_qa_clean.md'
    if old_path.exists():
        old_qa=old_path.read_text(encoding='utf-8')
    else:
        assert not any(data['qa'] for path,data in old_commands.items() if Path(path).parent.parent.name==student['source_name'])
        old_qa='' 
    assert Counter(student_pairs)==Counter(pairs(old_qa)),(directory,'QA changed')
    totals['students']+=1
    totals['recordings']+=len(list((Path(student['source'])/'term').glob('*.out.gz')))
    totals['commands']+=sum(sum(counter.values()) for counter in counts.values())
    totals['claude_sessions']+=len(sessions)
    totals['turns']+=len(student_pairs)

# 所有录像片段必须无缝覆盖原 body，每段只能归入一个分类。
for path in root.glob('*/term/*.out.gz'):
    try: body=app.read_term(path)[4]
    except ValueError: continue
    regions=app.split_lab_regions(body)
    assert regions[0]['begin']==0 and regions[-1]['end']==len(body)
    assert all(a['end']==b['begin'] for a,b in zip(regions,regions[1:]))
    assert b''.join(body[r['begin']:r['end']] for r in regions)==body

manifest=json.loads(Path('.verification/labs_input_before.json').read_text(encoding='utf-8'))
assert {str(p.resolve()) for p in root.rglob('*') if p.is_file()}==set(manifest)
for name,expected in manifest.items():
    p=Path(name)
    assert [p.stat().st_size,p.stat().st_mtime_ns,hashlib.sha256(p.read_bytes()).hexdigest()]==expected,name
print('PASS: classified structure, all 4 reports, metadata, Shell counts and lab attribution')
print('PASS: complete QA content equals prior output, no duplicate/missing turns, TUI filters')
print('PASS: region byte ranges cover each recording exactly once')
print('PASS: original',len(manifest),'files identical (paths/sizes/mtime/SHA-256)')
result={'totals':dict(totals),'labs':{lab:dict(count) for lab,count in lab_totals.items()}}
print(json.dumps(result,ensure_ascii=False,indent=2))
Path('.verification/labs_acceptance_summary.json').write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf-8')
