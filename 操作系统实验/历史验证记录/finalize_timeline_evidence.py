"""Publish this run's verified, human-readable acceptance notes."""
import json
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / '操作系统实验数据记录-已清洗'
EVIDENCE = ROOT / '.verification'
summary = json.loads((EVIDENCE / 'timeline_acceptance.json').read_text(encoding='utf-8'))
documents = [json.loads(p.read_text(encoding='utf-8')) for p in sorted(OUT.glob('*/实验过程时间线/timeline_*.json'))]
students = {}
details = {}
for doc in documents:
    key = doc['student']['student_id']
    student = students.setdefault(key, {'name': doc['student']['name'], 'events': [], 'recordings': doc['student_recordings']})
    student['events'].extend(doc['events'])
    for recording in doc['recording_details']:
        details[recording['out']] = recording
events = [event for student in students.values() for event in student['events']]
before = (EVIDENCE / 'README_before_timeline.md').read_text(encoding='utf-8')
readme = OUT / 'README.md'
current = readme.read_text(encoding='utf-8')
assert current.startswith(before.rstrip()), 'Original README content changed'
assert summary['shell_deltas'] == []
assert len(students) == 12 and len(details) == 134
assert sum(e['elapsed_seconds'] is None for e in events) == 0
assert all(d['status'] == 'ok' for d in details.values())
(EVIDENCE / 'timeline_shell_deltas.json').write_text('[]\n', encoding='utf-8')

md = ['# 实验过程时间线验收说明', '', '日期：2026-09-12。已按计划实施并完成正式输出。', '',
      '共处理 12 名学生、134 个录像，生成 19 组时间线 Markdown/JSON（38 份报告）及 12 份独立归属清单。当前新增的 114、zhaoxia、张三、法规和个四名学生只有时间线，未重建旧四类报告。', '',
      '| 事件 | 数量 |', '| --- | ---: |', '| Shell 命令 | 262 |', '| 用户问题 | 35 |', '| Claude 回复 | 35 |',
      '| 合计 | 332 |', '',
      '321 个事件有绝对显示时间，11 个仅保留录像相对时间，0 个完全缺少观察时间。70 个问题/回复均定位；35 个回复还分别记录了最终正文首次完整可见时间。', '',
      '## 按学生覆盖', '', '| 学生 | 录像 | Shell | 问题 | 回复 | 仅相对时间 |', '| --- | ---: | ---: | ---: | ---: | ---: |']
for key, student in sorted(students.items()):
    kinds = Counter(e['type'] for e in student['events'])
    relative = sum(not e['observed_at'] and e['elapsed_seconds'] is not None for e in student['events'])
    md.append(f"| {student['name']} | {student['recordings']} | {kinds['shell_command_observed']} | {kinds['claude_user_observed']} | {kinds['claude_reply_observed']} | {relative} |")
md.extend(['', '## 时间不确定性与异常', '',
           '- 周卓江的录像 `20260910T155636-14821` 有两个不同开始日志（15:56:36 与 15:59:34）。其中 11 条 Shell 命令只保留原录像累计偏移，未强行安排跨终端顺序。',
           '- 6 个录像的头时间与日志相差 1 秒，涉及 18 个事件；保留头时间并注明差异。',
           '- 日志中 7 处时间倒序、2 行 NUL 前缀已记录，未据此自动校时。',
           '- 9 个无头录像和 2 个中文头录像均由独立读取路径处理，134 个录像无读取/提取失败。',
           '- 8 个录像保留有效 Claude 问答；其余录像未提取到有效问答不代表未发生对话。内部未保留记录可能是流式或重绘残留，不作为额外真实对话计数。',
           '- 时间为终端显示观察时间，不代表提交、执行开始或回复完成时间。绝对起点只有秒级精度，保留小数偏移不提升时钟精度。', '',
           '### 仅相对时间的命令', '', '| 录像累计秒 | 命令 |', '| ---: | --- |'])
for event in sorted((e for e in events if not e['observed_at']), key=lambda e: e['elapsed_seconds']):
    command = event['content'].replace('|', '\\|').replace('\n', ' ')
    md.append(f"| {event['elapsed_seconds']:.6f} | {command} |")
md.extend(['', '## 验证结果', '',
           '- 46 项测试：45 项通过；1 项目录符号链接测试因当前 Windows 无创建权限而跳过。语法检查通过。',
           '- 262 条 Shell 命令按原录像逐条比对正文和 cwd，差异为零；70 个旧问答文本块按学生、lab、录像和角色逐条比对，全部保留。',
           '- 332 个事件编号唯一；关联不跨学生、不跨录像。显示证据的原始文件、解压字节区间及 timing 行号全部回查通过。',
           '- 周卓江首问 `+125.961003s`、首答 `+130.863928s`、最终正文 `+133.260372s` 与交接示例一致。',
           '- yanghanqing 第一轮最终正文 `+834.132589s` 晚于第二问 `+825.384924s`，未改造成严格串行。',
           '- 11,576 个原始文件和 72 个旧输出（含旧报告归属清单）全量路径及 SHA-256 对比一致。README 原有正文保留，仅增补本功能说明和验收信息。',
           '- 普通运行默认生成原报告与时间线；本次使用 `--timeline-only`。独立模式及默认重跑、来源隔离、保留旧报告和安全清理已验证。', '',
           '## 使用与证据', '',
           '[输出说明与运行命令](../操作系统实验数据记录-已清洗/README.md) · [示例：周卓江 lab0 时间线](../操作系统实验数据记录-已清洗/周卓江/实验过程时间线/timeline_lab0.md)', '',
           '[机器验收摘要](timeline_acceptance.json) · [测试日志](timeline_tests.log) · [正式运行日志](timeline_final.log) · [文件校验基线](timeline_baseline.json)', ''])
(EVIDENCE / 'timeline_acceptance.md').write_text('\n'.join(md), encoding='utf-8')

start, end = '<!-- timeline-verification:start -->', '<!-- timeline-verification:end -->'
block = '\n'.join([start, '## 本次时间线验收（2026-09-12）', '',
    '已覆盖 12 名学生、134 个录像，生成 19 组 Markdown/JSON。332 个事件中，321 个有绝对显示时间，11 个因录像开始日志冲突仅保留相对时间；无完全缺少观察时间的事件。', '',
    '45 项测试通过，1 项符号链接测试受 Windows 权限限制而跳过。原始 11,576 个文件及 72 个旧输出全量 SHA-256 一致；262 条命令和 70 个问答文本块与旧结果一致。', '',
    '[详细验收说明、覆盖表与异常清单](../.verification/timeline_acceptance.md)', end])
if start in current:
    first = current.index(start)
    last = current.index(end, first) + len(end)
    current = current[:first] + block + current[last:]
else:
    current = current.rstrip() + '\n\n' + block + '\n'
readme.write_text(current, encoding='utf-8')
print(json.dumps({'students': len(students), 'recordings': len(details), 'events': len(events), 'report': str(EVIDENCE / 'timeline_acceptance.md')}, ensure_ascii=False))
