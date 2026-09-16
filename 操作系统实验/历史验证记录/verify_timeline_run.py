"""Current-run file preservation and timeline acceptance evidence."""
import hashlib
import json
import sys
from pathlib import Path
from collections import Counter

ROOT = Path(__file__).resolve().parent.parent
RAW = ROOT / '学生操作系统实验数据爬取' / '操作系统实验数据记录'
OUT = ROOT / '操作系统实验数据记录-已清洗'
BASE = ROOT / '.verification' / 'timeline_baseline.json'

def digest(path):
    h = hashlib.sha256()
    with path.open('rb') as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b''):
            h.update(chunk)
    return h.hexdigest()

def snapshot():
    raw = {p.relative_to(RAW).as_posix(): digest(p) for p in RAW.rglob('*') if p.is_file()}
    old = {p.relative_to(OUT).as_posix(): digest(p) for p in OUT.rglob('*')
           if p.is_file() and p.name != 'README.md' and '实验过程时间线' not in p.parts}
    return {'raw': raw, 'old_outputs': old}

if __name__ == '__main__':
    if sys.argv[1] == 'baseline':
        data = snapshot()
        BASE.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding='utf-8')
        print(json.dumps({k: len(v) for k, v in data.items()}))
    elif sys.argv[1] == 'verify':
        before = json.loads(BASE.read_text(encoding='utf-8'))
        after = snapshot()
        changes = {k: sorted(p for p in set(before[k]) | set(after[k])
                             if before[k].get(p) != after[k].get(p)) for k in before}
        print(json.dumps(changes, ensure_ascii=False))
        assert not any(changes.values()), 'Original data or legacy output changed'
