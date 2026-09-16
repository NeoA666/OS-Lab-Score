"""Render final Markdown from the already validated canonical JSON, without replay."""
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))
import timeline_reports as reports

output = ROOT / '操作系统实验数据记录-已清洗'
count = 0
for path in sorted(output.glob('*/实验过程时间线/timeline_*.json')):
    document = json.loads(path.read_text(encoding='utf-8'))
    info = dict(document['student'], output=path.parent.parent)
    reports._atomic_write(path.with_suffix('.md'), reports._render_markdown(
        info, document['lab'], document['events'], document['statistics'], document['errors']))
    count += 1
print(count)
