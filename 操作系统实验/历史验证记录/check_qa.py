import json, sys
from pathlib import Path
sys.path.insert(0,str(Path.cwd()))
import replay_term_qa as app
baseline=json.loads(Path('.verification/baseline.json').read_text(encoding='utf-8'))
current={}
for name, old in baseline.items():
    if old['qa']:
        p=Path(name)
        pairs=app.extract_claude_session(str(p), str(p.with_name(p.name.replace('.out.gz','.tim.gz'))))[1]
        current[name]=pairs
        print(p.name, len(old['qa']), '->',len(pairs),flush=True)
        Path('.verification/qa_current.json').write_text(json.dumps(current, ensure_ascii=False,indent=2),encoding='utf-8')
