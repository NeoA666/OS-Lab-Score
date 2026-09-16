"""Evidence-preserving AI JSONL renderer; never executes submitted content."""
import html
import json
import re
from datetime import datetime, timezone
from urllib.parse import quote


def _label(value):
    return html.escape(str(value)).replace('\n', ' ').replace('\r', ' ').replace('`', '&#96;').replace('*', '&#42;').replace('[', '&#91;').replace(']', '&#93;').replace('|', '&#124;').replace('_', '&#95;')


def _text(value):
    return value if isinstance(value, str) else json.dumps(value, ensure_ascii=False, indent=2)


def _fence(value):
    value = _text(value)
    longest = max((len(m.group()) for m in re.finditer(r'`+', value)), default=0)
    fence = '`' * max(3, longest + 1)
    return f'{fence}text\n{value}\n{fence}'


def _source(path, line=None):
    suffix = f'，第 {line} 行' if line else ''
    return f'[{_label(path)}](原始提交/{quote(path, safe="/")}){suffix}'


def _sort_time(session):
    raw = session.get('created_at')
    try:
        dt = datetime.fromisoformat(str(raw).replace('Z', '+00:00'))
        if dt.tzinfo is None:
            return (1, dt.isoformat(), str(session.get('session_id', '')))
        return (0, dt.astimezone(timezone.utc).isoformat(), str(session.get('session_id', '')))
    except (ValueError, TypeError):
        return (2, '', str(session.get('session_id', '')))


def build_ai_report(files: dict[str, bytes], identity: dict) -> tuple[str, dict]:
    """Return independent conversation report plus sessions/messages/issues counts."""
    issues = []
    out = ['# AI 对话记录', '',
           f'学号：{_label(identity.get("student_id", "未知"))}；姓名：{_label(identity.get("name", "未知"))}',
           f'提交 ID：{_label(identity.get("submission_id", "未知"))}；来源压缩包：{_label(identity.get("archive", "未知"))}', '',
           '仅恢复会话内消息及内容块的原始顺序，不拼接终端时间线。创建和更新时间不是逐条消息时间。终端 ID：未提供关联。',
           '会话按实验分组；有时区的创建时间按绝对时间排序，无时区时间单独按原值排序，缺失或无效时间置后，不推定时区。', '']
    index = []
    if 'ai/sessions.json' in files:
        try:
            index = json.loads(files['ai/sessions.json'].decode('utf-8-sig'))
            if not isinstance(index, list):
                raise ValueError('会话索引应为数组')
        except (ValueError, UnicodeError) as exc:
            issues.append(f'ai/sessions.json 解析失败：{exc}')
            index = []
    else:
        issues.append('未提供 ai/sessions.json')
    sessions = []
    seen = set()
    for position, item in enumerate(index, 1):
        if not isinstance(item, dict) or not isinstance(item.get('session_id'), str):
            issues.append(f'会话索引第 {position} 项无有效 session_id')
            continue
        sid = item['session_id']
        if sid in seen:
            issues.append(f'会话索引重复 ID：{sid}；仅展示一次文件内容')
            continue
        seen.add(sid)
        sessions.append(dict(item, _path=f'ai/{sid}.jsonl'))
    for path in sorted(files):
        if path.startswith('ai/') and path.endswith('.jsonl') and path not in {s['_path'] for s in sessions}:
            sid = path[len('ai/'):-len('.jsonl')]
            sessions.append({'session_id': sid, '_path': path})
            issues.append(f'未被会话索引引用的文件：{path}')
    sessions.sort(key=lambda s: (str(s.get('lab_id', '未知实验')), _sort_time(s)))
    count = 0
    last_lab = None
    for session in sessions:
        lab = str(session.get('lab_id', '未知实验'))
        if lab != last_lab:
            out.extend([f'## 实验：{_label(lab)}', ''])
            last_lab = lab
        sid, path = session['session_id'], session['_path']
        out.extend([f'### 会话：{_label(sid)}', '',
                    f'实验 ID：{_label(lab)}；终端 ID：未提供关联',
                    f'创建时间（原始）：{_label(session.get("created_at", "未提供"))}',
                    f'最后更新时间（原始）：{_label(session.get("updated_at", "未提供"))}',
                    f'来源：{_source(path)}', ''])
        if path not in files:
            issues.append(f'会话文件缺失：{path}')
            out.extend(['会话文件缺失，无法恢复内容。', ''])
            continue
        records = []
        for lineno, raw in enumerate(files[path].splitlines(), 1):
            if not raw.strip():
                continue
            try:
                record = json.loads(raw.decode('utf-8-sig'))
                if not isinstance(record, dict):
                    raise ValueError('消息必须是对象')
                records.append((lineno, record, None))
            except (ValueError, UnicodeError) as exc:
                issues.append(f'{path}:{lineno} 消息解析失败：{exc}')
                records.append((lineno, None, raw.decode('utf-8', errors='backslashreplace')))
        calls = {}
        for lineno, record, _ in records:
            if record and isinstance(record.get('content'), list):
                for block in record['content']:
                    if isinstance(block, dict) and block.get('type') == 'tool_use' and isinstance(block.get('id'), str):
                        calls.setdefault(block['id'], []).append(lineno)
        valid_count = 0
        for number, (lineno, record, broken) in enumerate(records, 1):
            if record is None:
                out.extend([f'#### 记录 {number}：损坏消息', '', f'来源：{_source(path, lineno)}', '', _fence(broken), ''])
                continue
            valid_count += 1
            count += 1
            role = record.get('role', '未提供')
            content = record.get('content')
            if isinstance(content, list):
                blocks = content if content else [{'type': 'empty', 'text': '空消息：content 为 []'}]
            elif isinstance(content, str):
                blocks = [{'type': 'text', 'text': content}]
            else:
                blocks = [{'type': 'unknown', 'raw_content': content}]
            for blocknum, block in enumerate(blocks, 1):
                kind = block.get('type', 'unknown') if isinstance(block, dict) else 'unknown'
                label = {'tool_use': '工具调用（tool_use）', 'tool_result': '工具返回（tool_result）', 'thinking': '思考内容（thinking）', 'empty': '空消息'}.get(str(kind))
                if label is None:
                    label = ('用户文本' if role == 'user' else 'AI 文本' if role == 'assistant' else '其他角色文本') if kind == 'text' else '未知内容类型'
                out.extend([f'#### 消息 {number} · 块 {blocknum}：{label}', '',
                            f'会话 ID：{_label(sid)}；原始角色：{_label(role)}；内容类型：{_label(kind)}',
                            f'来源：{_source(path, lineno)}；逐条时间：未提供；终端 ID：未提供关联', ''])
                if kind == 'tool_result':
                    tool_id = block.get('tool_use_id', '未提供')
                    found = calls.get(tool_id, []) if isinstance(tool_id, str) else []
                    match = f'第 {found[0]} 行工具调用' if len(found) == 1 else '关联不唯一' if found else '未找到对应调用'
                    out.extend([f'关联调用 ID：{_label(tool_id)}；{match}', ''])
                    metadata = {key: value for key, value in block.items() if key != 'content'}
                    out.extend(['工具返回元数据（原始）：', '', _fence(metadata), '', '返回正文：', ''])
                    payload = block.get('content', None)
                    if 'content' not in block:
                        out.extend(['未提供 content 字段。', ''])
                elif kind == 'tool_use':
                    out.extend(['工具名称：', '', _fence(block.get('name', '未提供')), '',
                                '调用 ID：', '', _fence(block.get('id', '未提供')), '',
                                '调用参数（input）：', '', _fence(block.get('input', '未提供')), ''])
                    extras = {key: value for key, value in block.items() if key not in {'name', 'id', 'input'}}
                    out.extend(['其余原始字段：', '', _fence(extras), ''])
                    continue
                elif kind == 'text' and isinstance(block, dict) and set(block) <= {'type', 'text'}:
                    payload = block.get('text', '')
                    if payload == '':
                        out.extend(['空文本。', ''])
                else:
                    payload = block
                rendered = _fence(payload)
                if kind == 'tool_result' and len(_text(payload)) > 1500:
                    out.extend(['<details>', '<summary>展开完整工具返回</summary>', '', rendered, '', '</details>', ''])
                else:
                    out.extend([rendered, ''])
        if not records:
            out.extend(['会话文件为空：没有消息记录。', ''])
        if isinstance(session.get('messages'), int) and session['messages'] != valid_count:
            issues.append(f'{path} 消息数量不符：索引 {session["messages"]}，可解析消息 {valid_count}')
    if not sessions:
        out.extend(['未发现可展示的 AI 会话。', ''])
    if issues:
        out.extend(['## 数据异常与缺失', ''])
        out.extend(f'- {_label(issue)}' for issue in issues)
    return '\n'.join(out) + '\n', {'sessions': len(sessions), 'messages': count, 'issues': issues}
