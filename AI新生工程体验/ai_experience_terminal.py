"""Read-only asciicast rendering. Student code is never imported or executed."""
import difflib
import html
import json
import math
import re
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path
from urllib.parse import quote

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / '公共依赖' / 'pylib'))
import pyte


class EvidenceScreen(pyte.Screen):
    def __init__(self, columns, lines):
        self.history = []
        super().__init__(columns, lines)

    def index(self):
        top, bottom = self.margins or (0, self.lines - 1)
        if self.cursor.y == bottom:
            self.history.append(self.display[top])
        super().index()

    def erase_in_display(self, how=0, *args, **kwargs):
        if how in (2, 3):
            self.history.extend(self.display)
        super().erase_in_display(how, *args, **kwargs)

    def snapshot(self):
        result = self.history + self.display
        while result and not result[-1].strip():
            result.pop()
        return result


def literal(value):
    value = str(value)
    fence = '`' * max(3, 1 + max((len(m.group()) for m in re.finditer(r'`+', value)), default=0))
    return fence + 'text\n' + value + '\n' + fence


def safe(value):
    return html.escape(str(value)).replace('\n', ' ').replace('|', '&#124;').replace('`', '&#96;')


def source(path, first=None, last=None):
    suffix = f'，行 {first}' if first else ''
    if last and last != first:
        suffix += f'–{last}'
    return f'[{safe(path)}]({quote("原始提交/" + path, safe="/")}){suffix}'


def display_time(timestamp, offset):
    try:
        if isinstance(timestamp, bool) or not isinstance(timestamp, (int, float)):
            raise ValueError()
        dt = datetime.fromtimestamp(timestamp + offset, timezone(timedelta(hours=8)))
        return dt.isoformat(timespec='milliseconds') + '（北京时间）'
    except (ValueError, TypeError, OverflowError, OSError):
        return '绝对时间未知'


def candidate_command(screen):
    # Join visual wraps. Restrict to recognizable shell prompts, never infer from logs alone.
    lines = screen.snapshot()
    text = ''.join(line.rstrip() for line in lines)
    matches = list(re.finditer(r'(?:\[[^\[\]]+@[^\[\]]+\][#$] ?|[\w.-]+@[\w.-]+:[^\n]*?[$#] )', text))
    if not matches:
        return ''
    command = text[matches[-1].end():].strip()
    return command if '\x00' not in command else ''


def read_json_lines(path, raw, issues):
    try:
        lines = raw.decode('utf-8-sig').splitlines()
    except UnicodeDecodeError as exc:
        issues.append(f'{path}: UTF-8 解码错误 {exc}；替换无效字节继续展示')
        lines = raw.decode('utf-8-sig', errors='replace').splitlines()
    for number, line in enumerate(lines, 1):
        if not line.strip():
            continue
        try:
            yield number, json.loads(line)
        except (ValueError, TypeError) as exc:
            issues.append(f'{path} 行 {number}: JSON 损坏 {exc}')


def build_terminal_report(files, identity):
    issues = []
    stats = {'recordings': 0, 'commands': 0, 'issues': issues}
    out = ['# 终端时间线', '', f'学号：{safe(identity.get("student_id", "未知"))}；姓名：{safe(identity.get("name", "未知"))}', '',
           f'提交 ID：{safe(identity.get("submission_id", "未知"))}；来源压缩包：{safe(identity.get("archive", "未知"))}', '',
           '本报告仅重放已记录的终端，不执行学生代码。显示时间不是按键或进程开始、结束的精确时间。各终端独立展示，不与 AI 对话拼接。', '',
           '命令识别依据可见 shell 提示符及提交回显，属于可观察执行候选，无法识别的输出仍保留。命令日志仅按终端 ID 关联；无时区日志不擅自换算时区。', '']
    logs = []
    for path, raw in sorted(files.items()):
        if path.endswith('/commands.jsonl') or path == 'commands.jsonl':
            for line, value in read_json_lines(path, raw, issues):
                if isinstance(value, dict):
                    logs.append({'path': path, 'line': line, 'value': value, 'used': False})
                else:
                    issues.append(f'{path} 行 {line}: 命令日志不是对象')
    recordings = []
    for path, raw in sorted(files.items()):
        if not path.endswith('.cast'):
            continue
        records = list(read_json_lines(path, raw, issues))
        if not records or records[0][0] != 1 or not isinstance(records[0][1], dict):
            issues.append(f'{path}: 缺少有效录像头；原始记录保留')
            out += [f'## 损坏录像：{safe(path)}', '', source(path), '']
            continue
        header = records[0][1]
        recordings.append((str(header.get('lab_id', '未知实验')), path, header, records[1:]))
    for lab, path, header, events in sorted(recordings, key=lambda x: (x[0], x[1])):
        stats['recordings'] += 1
        terminal = Path(path).stem
        session_logs = [entry for entry in logs if entry['value'].get('session') == terminal]
        cwd = list(dict.fromkeys(str(e['value']['cwd']) for e in session_logs if e['value'].get('cwd')))
        out += [f'## 实验：{safe(lab)} / 终端：{safe(terminal)}', '',
                f'工作目录（日志记录）：{safe("；".join(cwd) or "未知")}；录像起始原始时间戳：{safe(header.get("timestamp", "缺失"))}', '', source(path, 1), '']
        if header.get('version') != 2:
            issues.append(f'{path}: 录像版本不是 2，按兼容事件结构尝试读取')
        try:
            width, height = int(header.get('width', 80)), int(header.get('height', 24))
            if not 1 <= width <= 1000 or not 1 <= height <= 1000:
                raise ValueError()
        except (ValueError, TypeError):
            width, height = 80, 24
            issues.append(f'{path}: 终端尺寸异常，使用 80×24 展示')
        screen = EvidenceScreen(width, height)
        stream = pyte.Stream(screen)
        previous = []
        frames = []
        commands = []
        last_offset = -1
        plain_submitted = False
        marker_recording = any(isinstance(e, list) and len(e) == 3 and isinstance(e[2], str) and '\x1b[?2004' in e[2] for _, e in events)
        for line, event in events:
            if not (isinstance(event, list) and len(event) == 3 and isinstance(event[0], (int, float))
                    and not isinstance(event[0], bool) and math.isfinite(event[0]) and event[0] >= 0
                    and isinstance(event[1], str) and isinstance(event[2], str)):
                issues.append(f'{path} 行 {line}: 非法录像事件')
                continue
            offset, kind, data = event
            if offset < last_offset:
                issues.append(f'{path} 行 {line}: 时间偏移倒退，保留文件顺序')
            last_offset = offset
            stamp = f'{display_time(header.get("timestamp"), offset)}；偏移 +{offset:.6f}s；{source(path, line)}'
            if kind == 'r':
                try:
                    w, h = map(int, data.split('x'))
                    if not 1 <= w <= 1000 or not 1 <= h <= 1000:
                        raise ValueError()
                    screen.resize(lines=h, columns=w)
                    frames.append((stamp, '尺寸变化', data, line))
                except (ValueError, TypeError):
                    issues.append(f'{path} 行 {line}: 非法尺寸 {data!r}')
                continue
            if kind != 'o':
                frames.append((stamp, f'原始事件 {kind}', data, line))
                continue
            # Bash disables bracketed paste on submission. Capture screen BEFORE its newline.
            # Plain shells without that marker are handled at individual newlines.
            pieces = re.split('(\x1b\\[\\?2004l|\\n)', data)
            marker_in_event = '\x1b[?2004l' in data
            before_event = candidate_command(screen)
            marker_candidate = before_event
            if re.search(r'\][#$] ', data):
                plain_submitted = False
            for piece in pieces:
                if piece == '\n' and marker_in_event:
                    marker_candidate = candidate_command(screen)
                if piece == '\x1b[?2004l' or (piece == '\n' and not marker_recording and not plain_submitted):
                    command = marker_candidate if marker_in_event else candidate_command(screen)
                    if command:
                        commands.append({'command': command, 'line': line, 'offset': offset, 'stamp': stamp})
                        plain_submitted = True
                stream.feed(piece)
            current = screen.snapshot()
            changed = []
            for tag, a, b, c, d in difflib.SequenceMatcher(a=previous, b=current, autojunk=False).get_opcodes():
                if tag in ('insert', 'replace'):
                    changed.extend(current[c:d])
                elif tag == 'delete':
                    changed.append('[画面删除/清除 ' + str(b - a) + ' 行]')
            if changed:
                frames.append((stamp, '画面更新（包含输入回显或输出）', '\n'.join(changed), line))
            previous = current
        stats['commands'] += len(commands)
        out += [f'可观察非空命令提交：{len(commands)} 次。逐帧画面更新在下方保留，重复绘制不代表重复执行。', '']
        for index, cmd in enumerate(commands, 1):
            end = max(cmd['line'], commands[index]['line'] - 1) if index < len(commands) else (events[-1][0] if events else cmd['line'])
            out += [f'### 操作 {index}', '', f'终端 ID：{safe(terminal)}；实验 ID：{safe(lab)}；工作目录（会话日志）：{safe("；".join(cwd) or "未知")}', '', cmd['stamp'], '', f'输出证据区间：{source(path, cmd["line"], end)}（包含后续提示符及下一次输入回显，以逐帧记录为准）', '',
                    '命令回显：', '', literal(cmd['command']), '']
            matched = next((e for e in session_logs if not e['used'] and str(e['value'].get('cmd', '')).strip() == cmd['command']), None)
            if matched:
                matched['used'] = True
                value = matched['value']
                out += [f'候选关联日志：{source(matched["path"], matched["line"])}；返回码：{safe(value.get("rc", "缺失"))}；日志原始时间：{safe(value.get("ts", "缺失"))}', '',
                        '关联依据：终端 ID 精确一致、命令文字一致、日志顺序；时间及时区未确证，返回码归属仍可能有歧义。', '']
            else:
                out += ['未匹配命令日志，返回码未知。', '']
            block_output = [body for _, label, body, frame_line in frames if cmd['line'] <= frame_line <= end and label.startswith('画面')]
            out += ['提交及后续画面输出（可能含命令、提示符及下一次输入回显）：', '', literal('\n'.join(block_output) or '未记录后续输出'), '']
        out += ['### 按录像顺序的画面记录', '', '以下保留初始化、输入回显、输出、重绘与尺寸变化；画面更新是相对上一输出帧的变化，不应当作新的命令次数。', '']
        for stamp, label, body, _ in frames:
            out += [f'**{label}**', '', stamp, '', literal(body), '']
        if not frames:
            out += ['无可展示事件。', '']
    if not recordings:
        out += ['未发现可解析的终端录像。', '']
    unmatched = [entry for entry in logs if not entry['used']]
    if unmatched:
        out += ['## 未匹配命令日志', '', '可能包括初始化空命令、上一命令的重复记录或缺少录像证据的操作；这些条目不计为执行次数。原始时间无时区时保持原样。', '']
        for entry in unmatched:
            out += [source(entry['path'], entry['line']), '', literal(json.dumps(entry['value'], ensure_ascii=False, indent=2)), '']
    if issues:
        out += ['## 解析异常', ''] + ['- ' + safe(issue) for issue in issues] + ['']
    return '\n'.join(out), stats
