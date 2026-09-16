import sys, json
from pathlib import Path
sys.path.insert(0, str(Path('pylib').resolve()))
sys.path.insert(0, str(Path('.verification').resolve()))
import replay_term_qa_original as old
result = {}
for p in sorted(Path('操作系统实验数据记录').glob('*/term/*.out.gz')):
    t = p.with_name(p.name.replace('.out.gz', '.tim.gz'))
    try:
        result[str(p)] = {'commands': old.extract_session(str(p),str(t))[2], 'qa': old.extract_claude_session(str(p),str(t))[1]}
    except Exception as exc:
        result[str(p)] = {'commands': [], 'qa': [], 'error': str(exc)}
Path('.verification/baseline.json').write_text(json.dumps(result, ensure_ascii=False, indent=2), encoding='utf-8')
print('Baseline',len(result),sum(len(v['qa']) for v in result.values()))
