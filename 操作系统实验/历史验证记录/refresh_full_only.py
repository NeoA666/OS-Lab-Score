"""仅刷新现有完整转写文件，不写入另外三类报告、归属清单或批处理汇总。"""
import hashlib,json,sys,contextlib,io
from pathlib import Path
sys.path.insert(0,str(Path.cwd()))
import replay_term_qa as app
root=Path('操作系统实验数据记录-已清洗').resolve()
protected={p:hashlib.sha256(p.read_bytes()).hexdigest() for p in root.rglob('*') if p.is_file() and not p.name.startswith('full_terminal_transcript_')}
input_root=Path('学生操作系统实验数据爬取/操作系统实验数据记录')
originals={p:(p.stat().st_size,p.stat().st_mtime_ns,hashlib.sha256(p.read_bytes()).hexdigest()) for p in input_root.rglob('*') if p.is_file()}
expected={p.resolve() for p in root.rglob('full_terminal_transcript_*.md')}
written=set()
write=app.atomic_write

def write_full_only(path,text):
    path=Path(path).resolve()
    if not path.name.startswith('full_terminal_transcript_'):
        return
    assert path in expected,path
    assert '### Frame ' not in text
    write(path,text)
    written.add(path)

app.atomic_write=write_full_only
# 本次只重放完整终端；不重新提取和写入 Claude QA，不改变正常 CLI 流程。
app.extract_claude_session=lambda out,tim:(Path(out).name[:-len('.out.gz')],[])
app.finish_student_reports=lambda info,paths:None
recordings=failures=students=0
for owner_path in sorted(root.glob('*/.replay_term_qa.json')):
    owner=json.loads(owner_path.read_text(encoding='utf-8'))
    source=Path(owner['source'])
    info=app.parse_student_name(source.name)
    info.update(source=str(source),output=owner_path.parent)
    print('Refreshing full transcript:',info['name'],flush=True)
    with contextlib.redirect_stdout(io.StringIO()):
        result=app.process_student(info)
    recordings+=result.get('recordings',0)
    failures+=result.get('replay_failed',0)
    students+=1
assert written==expected,(written,expected)
for p,digest in protected.items():
    assert hashlib.sha256(p.read_bytes()).hexdigest()==digest,p
for p,state in originals.items():
    assert (p.stat().st_size,p.stat().st_mtime_ns,hashlib.sha256(p.read_bytes()).hexdigest())==state,p
assert set(originals)=={p for p in input_root.rglob('*') if p.is_file()}
summary={'students':students,'recordings':recordings,'failed_recordings':failures,'full_reports':len(written),
         'unchanged_other_files':len(protected),'unchanged_source_files':len(originals)}
Path('.verification/continuous_full_summary.json').write_text(json.dumps(summary,indent=2),encoding='utf-8')
print('PASS',json.dumps(summary),flush=True)
