import importlib.util
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / 'pylib'))
spec = importlib.util.spec_from_file_location('legacy', ROOT / '.verification/replay_term_qa_before_timeline.py')
app = importlib.util.module_from_spec(spec)
spec.loader.exec_module(app)
raw = ROOT / '学生操作系统实验数据爬取/操作系统实验数据记录'
results = {}
for out in sorted(raw.glob('*/term/*.out.gz')):
    try:
        commands = app.extract_session(out, out.with_name(out.name.replace('.out.gz', '.tim.gz')))[2]
        results[out.relative_to(raw).as_posix()] = {'commands': [
            {'command': c['command'], 'cwd': c['cwd']} for c in commands]}
    except Exception as exc:
        results[out.relative_to(raw).as_posix()] = {'commands': [], 'error': str(exc)}
(ROOT / '.verification/timeline_legacy_commands.json').write_text(
    json.dumps(results, ensure_ascii=False, indent=2), encoding='utf-8')
print(json.dumps({'recordings': len(results), 'commands': sum(len(v['commands']) for v in results.values()),
                  'failed': sum('error' in v for v in results.values())}))
