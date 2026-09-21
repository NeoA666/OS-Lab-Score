#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
使用 pyte 精确重放 term/*.out.gz + *.tim.gz，生成终端命令问答及三种独立 Markdown 输出。

方法说明：
  * term 文件是 Linux `script` 录像：.out.gz 是原始 pty 输出流（含 ANSI 控制序列），
    .tim.gz 是 `延迟 字节数` 计时文件。
  * 命令检测采用「提示符锚点」法在**原始字节流**上定位每条命令（不受 clear/全屏
    TUI 清屏、以及窄终端自动换行的影响，能拿到含全部参数/选项的完整命令）。
  * 命令与其输出的正文，分别用 pyte 的 Screen 做忠实渲染（解析 SGR 颜色、退格、
    \b 删除、全角字符、自动换行等），得到干净的文本。
  * 额外输出完整终端转写、shell 命令统计，以及基于逐帧 Screen diff 的干净
    Claude Code 用户/回复问答；支持多学生批处理及单学生目录。
"""
import os
import re
import sys
import json
import argparse
import tempfile
import hashlib
import math
import io
from contextlib import redirect_stderr, redirect_stdout
from bisect import bisect_right
from pathlib import Path
from datetime import datetime
from urllib.parse import quote
import gzip
from collections import Counter

TOOL_DIR = Path(__file__).resolve().parent
CLEANING_DIR = TOOL_DIR.parent
REPOSITORY_ROOT = CLEANING_DIR.parent
sys.path.insert(0, str(CLEANING_DIR))
from output_layout import (  # noqa: E402
    PROCESS_TOOL,
    ensure_layout,
    pair_matches,
    unlink_pair,
    write_text_pair,
)
PYLIB = str(REPOSITORY_ROOT / "公共依赖" / "pylib")
if os.path.isdir(PYLIB):
    sys.path.insert(0, PYLIB)

from pyte import ByteStream                      # noqa: E402
from pyte.screens import Screen                  # noqa: E402
from wcwidth import wcwidth                      # noqa: E402
from timeline_reports import (                  # noqa: E402
    README_BLOCK_END,
    README_BLOCK_START,
    TIMELINE_DIRECTORY,
    TIMELINE_MANIFEST,
    TIMELINE_TOOL,
    mark_timeline_rebuild,
    remove_student_timeline,
    timeline_cache_hit,
    timeline_owned_by,
    update_readme_timeline_block,
    write_student_timeline,
    has_link_component,
    is_link_like,
)


# Bash 提示符在原始流中的形态（user@host 用绿色，路径用蓝色，`$`/`#` 结束）。
# 也接受行首未着色的普通 Bash 提示符，避免把提示符配色当成数据契约。
SGR = rb"\x1b\[[0-9;]*m"
ZERO_WIDTH_ANSI = (
    rb"(?:\x1b\][^\x07\x1b]*(?:\x07|\x1b\\)"
    rb"|\x1b\[[0-?]*[ -/]*[@-~])"
)
LOGICAL_LINE_PREFIX = rb"(?:^|(?<=[\r\n]))(?:" + ZERO_WIDTH_ANSI + rb")*?"
PROMPT_RAW = re.compile(
    LOGICAL_LINE_PREFIX + SGR + rb"(?P<uh>[^\s@\x1b]+@[^\s:\x1b]+)" + SGR + rb":"
    + SGR + rb"(?P<cwd>.*?)" + SGR + rb"(?P<mark>[$#]) "
)
PLAIN_PROMPT_RAW = re.compile(
    LOGICAL_LINE_PREFIX + rb"[^\s@\x1b]+@[^\s:\x1b]+:(?P<cwd>[^\r\n\x1b]*?)(?P<mark>[$#]) "
)
SCRIPT_HEADER_PREFIXES = (
    b"Script started on ",
    "脚本启动于 ".encode("utf-8"),
    "脚本开始于 ".encode("utf-8"),
)
SCRIPT_DONE_PREFIXES = (
    b"Script done on ",
    "脚本完成于 ".encode("utf-8"),
    "脚本结束于 ".encode("utf-8"),
)

MAX_OUTPUT_LINES = 400                          # 每条命令输出在报告中最多保留的行数

# 增量状态只保存在各学生既有的归属清单中。版本变化会让旧清单安全地失效。
INCREMENTAL_CACHE_FORMAT_VERSION = 2
_HASH_CHUNK_SIZE = 1024 * 1024
MAX_CACHED_DIAGNOSTICS = 100
MAX_CACHED_DIAGNOSTIC_LENGTH = 2000


def shell_prompt_matches(body):
    """Return every supported shell prompt in byte order.

    A recording can change its prompt style mid-session, for example after a
    shell profile reload. Both patterns use the same named groups and accept
    OSC/CSI controls before the visible prompt on a logical line.
    """
    return sorted(
        [*PROMPT_RAW.finditer(body), *PLAIN_PROMPT_RAW.finditer(body)],
        key=lambda match: match.start(),
    )


# Claude Code 会在终端内反复重绘。以下规则只用于 claude_qa_clean.md；
# full_terminal_transcript.md 不使用这些过滤规则。
BOX_DRAWING_RE = re.compile(r"[\u2500-\u257f]")
CLAUDE_MARKER_RE = re.compile(r"^(?P<role>[❯●])(?:[ \u00a0]*(?P<text>.*))$")
CLAUDE_SPINNER_RE = re.compile(
    r"(?:Computing(?:\.{3}|…)?|Thinking\s+for\s+\d+(?:\.\d+)?s|"
    r"(?:Crunched|Sautéed|Sauteed|Baked|Brewed|"
    r"Cooked|Worked)\s+for\s+\d+(?:\.\d+)?s|Thought\s+for\s+\d+(?:\.\d+)?s)",
    re.IGNORECASE,
)
CLAUDE_ANIMATED_STATUS_RE = re.compile(
    r"^[✻✢✶✽·*]\s*[^\n]*(?:…|\.\.\.)(?:\s|$)", re.IGNORECASE
)
CLAUDE_PROCESS_RE = re.compile(
    r"^(?:Thinking(?:\s|[.…:]|$)|[✻✢✶✽]\s+.+|"
    r"(?:Bash|Read|Write|Edit|MultiEdit|Glob|Grep|Search|Task|Agent|TodoWrite|"
    r"WebFetch|WebSearch|ToolSearch|Skill|NotebookEdit)\s*\(|"
    r"(?:Running|Searching|Reading|Writing|Editing)\s|"
    r"Do you want to proceed\?|Allow (?:Claude|once|always)|"
    r"(?:[❯>]\s*)?\d+\.\s+(?:Yes|No|Allow|Deny)|"
    r"Esc to cancel|Enter to confirm|Permission required|"
    r"Please run /login|API Error:|Invalid API key|Not logged in|"
    r"✽|✻|✢|✶)", re.IGNORECASE
)
CLAUDE_STATUS_FRAGMENTS = (
    "manual mode on",
    "? for shortcuts",
    "← for agents",
    "esc to interrupt",
    "/effort",
)
CLAUDE_FOOTER_PREFIXES = (
    "Resume this session with:",
    "claude --resume ",
    "Press Ctrl-C again to exit",
)
CLAUDE_OVERLAY_PREFIXES = (
    "Welcome to Claude Code for VS Code",
    "installed extension ",
    "Claude has context of ",
    "Review Claude Code's changes ",
    "Cmd+Esc for Quick Launch",
    "Ctrl+Alt+K to reference ",
    "Press Enter to continue",
)


def render_line(line, columns):
    """把 pyte 的一行（dict: x->Char）渲染为 unicode 字符串，处理全角字符 stub。"""
    out = []
    is_wide = False
    for x in range(columns):
        if is_wide:
            is_wide = False
            continue
        ch = line[x].data
        out.append(ch)
        if wcwidth(ch) == 2:
            is_wide = True
    return "".join(out).rstrip()


class ScrollScreen(Screen):
    """带滚动历史捕获的 Screen（用基础 Screen 实现，不受 clear 清屏影响光标屏幕）。"""

    def __init__(self, cols, rows):
        super().__init__(cols, rows)
        self.scrollback = []

    def index(self):
        top, bottom = self.margins or (0, self.lines - 1)
        if self.cursor.y == bottom:
            self.scrollback.append(render_line(self.buffer[top], self.columns))
        super().index()

    def reverse_index(self):
        top, bottom = self.margins or (0, self.lines - 1)
        if self.cursor.y == top:
            self.scrollback.append(render_line(self.buffer[bottom], self.columns))
        super().reverse_index()


class TranscriptScreen(ScrollScreen):
    """在滚屏历史之外保存全屏清除前的画面，避免 TUI 退出时丢失内容。"""

    def __init__(self, cols, rows):
        self.archived = []
        super().__init__(cols, rows)

    def _archive_visible_screen(self):
        lines = list(self.scrollback)
        lines.extend(render_line(self.buffer[y], self.columns) for y in range(self.lines))
        while lines and not lines[-1]:
            lines.pop()
        if lines:
            self.archived.extend(lines)
            self.archived.append("")
        self.scrollback.clear()

    def erase_in_display(self, how=0, *args, **kwargs):
        # CSI 2 J / CSI 3 J 会令普通 Screen 永久丢掉清屏前的 TUI。
        if how in (2, 3):
            self._archive_visible_screen()
        super().erase_in_display(how, *args, **kwargs)

    def transcript_lines(self):
        """返回当前时刻所有已归档、已滚出和仍在屏幕上的渲染行。"""
        lines = list(self.archived)
        lines.extend(self.scrollback)
        lines.extend(render_line(self.buffer[y], self.columns) for y in range(self.lines))
        return lines


def render_region(region_bytes, cols, rows):
    """把一个原始字节片段喂给 pyte，返回渲染后的干净文本行列表。"""
    screen = ScrollScreen(cols, rows)
    ByteStream(screen).feed(region_bytes)
    lines = list(screen.scrollback)
    for y in range(rows):
        t = render_line(screen.buffer[y], cols)
        if t:
            lines.append(t)
    return lines


def join_wrapped(lines, cols):
    """合并被终端自动换行拆开的行：上一行恰好填满整列宽则视为续行。"""
    out = []
    for ln in lines:
        width = sum(max(wcwidth(char), 0) for char in out[-1]) if out else 0
        if out and width == cols:
            out[-1] += ln
        else:
            out.append(ln)
    return out


def clean_command(echo_bytes, cols, rows):
    """渲染命令回显，返回完整的命令字符串（已解析退格/ANSI，合并自动换行）。"""
    lines = render_region(echo_bytes, cols, rows)
    lines = [ln for ln in lines if ln.strip()] or [""]
    lines = join_wrapped(lines, cols)
    return " ".join(ln.strip() for ln in lines).strip()


def normalize_command(cmd):
    """去掉回显中的括号粘贴标记残迹（脱字符形态 ^[[200~/^[[201~ 与末尾粘连的 ~）。"""
    cmd = re.sub(r"\^\[\[20[01]~", "", cmd)
    cmd = cmd.strip()
    # 仅当末尾 '~' 直接粘连命令（粘贴结束残迹），而非 "cd ~" 这类合法写法时去掉
    if cmd.endswith("~") and not cmd.endswith(" ~"):
        cmd = cmd[:-1].rstrip()
    return cmd


def _header_dimension(header, name, default):
    match = re.search(rf'{re.escape(name)}="(\d+)"', header)
    if not match:
        return default
    value = int(match.group(1))
    return value if value > 0 else default


def has_administrative_script_tail(body, offset):
    """Return whether bytes after timing coverage are script's own footer."""
    tail = body[offset:]
    return bool(tail.strip()) and tail.lstrip().startswith(SCRIPT_DONE_PREFIXES)


def timing_entries_cover_body(entries, body):
    """Timing is usable only when it covers the recording except script's own footer."""
    if not entries:
        return False
    covered = sum(size for _, size in entries)
    return covered <= len(body) and (
        covered == len(body) or has_administrative_script_tail(body, covered)
    )


def read_term(out_path):
    with gzip.open(out_path, "rb") as f:
        raw = f.read()
    first, newline, remainder = raw.partition(b"\n")
    has_header = first.startswith(SCRIPT_HEADER_PREFIXES)
    if has_header and not newline:
        raise ValueError("script 头缺少换行，无法定位正文")
    header = first.decode("utf-8", "replace") if has_header else ""
    body = remainder if has_header else raw
    start = re.search(r"(?:Script started on|脚本启动于|脚本开始于)\s+(.+?)(?: \[|$)", header)
    cols = _header_dimension(header, "COLUMNS", 198)
    rows = _header_dimension(header, "LINES", 59)
    return header, (start.group(1) if start else ""), cols, rows, body


def infer_replay_columns(body, header_cols):
    """修正 script 头部可能过期的列数，仅把 TUI 整行边框用作终端几何信息。

    `script` 不会把运行期间的 TIOCSWINSZ 变化写进 .out；Claude Code 绘制的
    连续横线恰好覆盖实际终端宽度。这里只读取边框长度，不从原始文本抽取 QA。
    """
    if b"Claude Code" not in body:
        return header_cols

    widths = []
    for char in ("─", "═"):
        encoded = re.escape(char.encode("utf-8"))
        pattern = re.compile(rb"(?:" + encoded + rb"){40,400}")
        widths.extend(len(m.group(0)) // len(char.encode("utf-8")) for m in pattern.finditer(body))
    return max(widths) if widths else header_cols


def read_timing_entries(tim_path, body=None):
    """读取 script 的 timing 条目；失败时由调用方退化为一次性重放。"""
    if not (tim_path and os.path.exists(tim_path)):
        return []
    try:
        with gzip.open(tim_path, "rt", encoding="utf-8", errors="strict") as f:
            entries = []
            elapsed = 0.0
            for line in f:
                parts = line.split()
                if len(parts) != 2:
                    return []
                delay, size = float(parts[0]), int(parts[1])
                if not math.isfinite(delay) or delay < 0 or size < 0:
                    return []
                elapsed += delay
                if not math.isfinite(elapsed):
                    return []
                entries.append((delay, size))
        if body is not None and not timing_entries_cover_body(entries, body):
            return []
        return entries
    except (OSError, EOFError, UnicodeError, ValueError, OverflowError):
        return []


def iter_screen_diff_frames(out_path, tim_path, archive_clears=False):
    """按 .tim 分帧重放，并产出 pyte Screen 状态及相对上一帧的变化行。

    Claude QA 识别只消费这里的 Screen 结果，不消费未经终端语义解析的 transcript。
    """
    _, start, header_cols, rows, body = read_term(out_path)
    cols = infer_replay_columns(body, header_cols)
    entries = read_timing_entries(tim_path, body) or [(0.0, len(body))]

    # 干净 QA 只看 Screen/scrollback 的变化；完整转写额外归档清屏前画面。
    screen = TranscriptScreen(cols, rows) if archive_clears else ScrollScreen(cols, rows)
    stream = ByteStream(screen)
    previous = ()
    offset = 0
    elapsed = 0.0
    frame_no = 0

    for delay, size in entries:
        elapsed += delay
        end = min(offset + size, len(body))
        if end > offset:
            stream.feed(body[offset:end])
        offset = end

        if archive_clears:
            current = tuple(screen.transcript_lines())
        else:
            current = tuple(screen.scrollback) + tuple(
                render_line(screen.buffer[y], screen.columns) for y in range(screen.lines)
            )
        max_len = max(len(previous), len(current))
        changed_rows = tuple(
            i for i in range(max_len)
            if (previous[i] if i < len(previous) else None)
            != (current[i] if i < len(current) else None)
        )
        if changed_rows:
            yield frame_no, elapsed, current, changed_rows, start, cols, rows
            previous = current
            frame_no += 1
        if offset >= len(body):
            break

    # timing 文件损坏或截短时仍重放剩余字节。
    if offset < len(body):
        stream.feed(body[offset:])
        if archive_clears:
            current = tuple(screen.transcript_lines())
        else:
            current = tuple(screen.scrollback) + tuple(
                render_line(screen.buffer[y], screen.columns) for y in range(screen.lines)
            )
        max_len = max(len(previous), len(current))
        changed_rows = tuple(
            i for i in range(max_len)
            if (previous[i] if i < len(previous) else None)
            != (current[i] if i < len(current) else None)
        )
        if changed_rows:
            yield frame_no, elapsed, current, changed_rows, start, cols, rows


def build_time_map(tim_path, body):
    """根据 .tim 建立「累计字节数 -> 累计秒」的映射，返回按字节升序的两个数组。"""
    entries = read_timing_entries(tim_path, body)
    if not entries:
        return None
    cum_b, cum_t = [], []
    b = t = 0.0
    for delay, n in entries:
        t += delay
        b += n
        cum_b.append(int(b))
        cum_t.append(t)
    return cum_b, cum_t


def time_at(time_map, offset):
    if not time_map:
        return None
    cum_b, cum_t = time_map
    # A byte at the end of one timing block belongs to the next block.
    i = bisect_right(cum_b, offset)
    if i >= len(cum_t):
        return cum_t[-1]
    return cum_t[i]


def extract_session(out_path, tim_path, *, source_data=None, evidence=None):
    rec_id = os.path.basename(out_path)[:-len(".out.gz")]
    header, start, cols, rows, body = source_data if source_data is not None else read_term(out_path)
    raw_body = body

    marker_ranges = [(match.start(), match.end())
                     for match in re.finditer(rb"\x1b\[20[01]~", raw_body)]

    # 保存的只是被删标记的断点。普通录像不再为每个字节建立 Python int 映射表。
    clean_marker_starts, removed_totals = [], []
    removed = 0
    for begin, end in marker_ranges:
        clean_marker_starts.append(begin - removed)
        removed += end - begin
        removed_totals.append(removed)
    if marker_ranges:
        body = re.sub(rb"\x1b\[20[01]~", b"", raw_body)

    time_map = build_time_map(tim_path, raw_body)

    def raw_offset(offset):
        index = bisect_right(clean_marker_starts, offset)
        return offset + (removed_totals[index - 1] if index else 0)

    def raw_end_offset(offset):
        # A content range ending immediately before a paste marker excludes it.
        return raw_offset(offset - 1) + 1 if offset else raw_offset(0)

    matches = shell_prompt_matches(body)
    commands = []
    for i, m in enumerate(matches):
        region_end = matches[i + 1].start() if i + 1 < len(matches) else len(body)
        region = body[m.end():region_end]

        # 命令回显到第一个 \r / \n 为止；其后为命令输出
        cr = region.find(b"\r")
        lf = region.find(b"\n")
        cut = len(region)
        for pos in (cr, lf):
            if pos != -1:
                cut = min(cut, pos)
        echo = region[:cut]
        output = region[cut:]

        cmd = clean_command(echo, cols, rows)
        cmd = normalize_command(cmd)
        if not cmd:
            continue
        # 过滤纯 Ctrl-C 中断等噪声
        if set(cmd) <= {"^", "C", "c", "\x03"}:
            continue

        out_lines = render_region(output, cols, rows)
        # 去除首尾空行
        while out_lines and not out_lines[0].strip():
            out_lines.pop(0)
        while out_lines and not out_lines[-1].strip():
            out_lines.pop()
        out_lines = join_wrapped(out_lines, cols)

        cwd = m.group("cwd").decode("utf-8", "replace")
        elapsed = time_at(time_map, raw_offset(m.start()))
        commands.append({
            "rec": rec_id,
            "seq": None,  # 稍后补序号
            "cwd": cwd,
            "command": cmd,
            "output": out_lines,
            "elapsed": round(elapsed, 1) if elapsed is not None else None,
            "start": start,
        })
        if evidence is not None:
            evidence.append({
                "prompt_begin": raw_offset(m.start()),
                "echo_begin": raw_offset(m.end()),
                "echo_end": raw_end_offset(m.end() + cut) if cut else raw_offset(m.end()),
                "output_begin": raw_offset(m.end() + cut),
                "output_end": raw_offset(region_end),
            })

    for seq, c in enumerate(commands, 1):
        c["seq"] = seq
    return rec_id, start, commands


def is_claude_ui_terminator(line):
    """会终止消息正文的 TUI 状态行（其后通常是另一块界面）。"""
    stripped = line.replace("\u00a0", " ").strip()
    without_bullet = stripped.lstrip("● ")
    return (
        bool(CLAUDE_PROCESS_RE.search(without_bullet))
        or bool(CLAUDE_SPINNER_RE.search(stripped))
        or bool(CLAUDE_ANIMATED_STATUS_RE.search(stripped))
        or any(fragment in stripped for fragment in CLAUDE_STATUS_FRAGMENTS)
        or any(stripped.startswith(prefix) for prefix in CLAUDE_FOOTER_PREFIXES)
        or any(without_bullet.startswith(prefix) for prefix in CLAUDE_OVERLAY_PREFIXES)
        or stripped.startswith(("⎿", "※ recap:", "Accessing workspace:"))
    )


def is_claude_ui_noise(line):
    """判断 Claude TUI 的装饰、状态、spinner 和会话 footer。"""
    stripped = line.replace("\u00a0", " ").strip()
    if not stripped:
        return False
    if not BOX_DRAWING_RE.sub("", stripped).strip():
        return True
    if is_claude_ui_terminator(stripped):
        return True

    # 三行 Claude 标志及欢迎框标题不属于问答正文。
    logo_chars = set("▐▛█▜▌▝▘ ")
    if set(stripped) <= logo_chars:
        return True
    if any(token in stripped for token in ("▐▛███▜▌", "▝▜█████▛▘", "▘▘ ▝▝")):
        return True
    return False


def clean_claude_message(lines):
    """清理一个已由 pyte Screen 识别出的 Claude/User 消息块。"""
    cleaned = []
    for line in lines:
        line = line.replace("\u00a0", " ").rstrip()
        if is_claude_ui_terminator(line):
            break
        if is_claude_ui_noise(line):
            continue

        # 删除边框字符而保留同一行中的真实文字。
        line = BOX_DRAWING_RE.sub("", line).rstrip()
        if line.startswith("  "):
            line = line[2:]
        elif line.startswith(" "):
            line = line[1:]

        # 屏幕重绘偶尔会把同一行连续写入 scrollback；只折叠相邻副本。
        if line and cleaned:
            previous_index = next((i for i in range(len(cleaned) - 1, -1, -1) if cleaned[i]), None)
            if previous_index is not None and line == cleaned[previous_index]:
                while cleaned and not cleaned[-1]:
                    cleaned.pop()
                continue
        if not line and cleaned and not cleaned[-1]:
            continue
        cleaned.append(line)

    while cleaned and not cleaned[0]:
        cleaned.pop(0)
    while cleaned and not cleaned[-1]:
        cleaned.pop()
    return "\n".join(cleaned).strip()


def parse_claude_blocks(screen_lines):
    """在一帧 Screen 历史中识别 ❯ 用户块和 ● Claude 块。"""
    blocks = []
    role = None
    content = []

    def flush():
        nonlocal role, content
        if role:
            text = clean_claude_message(content)
            if text:
                blocks.append((role, text))
        role = None
        content = []

    for raw_line in screen_lines:
        line = raw_line.replace("\u00a0", " ")
        marker = CLAUDE_MARKER_RE.match(line)
        if marker:
            flush()
            role = "user" if marker.group("role") == "❯" else "claude"
            marker_text = marker.group("text")
            # 展开的 thinking/tool 状态有时也以“● Thinking ...”开头；
            # 它不是最终回复，整块忽略，不能只删标题后误收内部推理正文。
            if is_claude_ui_noise(marker_text):
                role = None
                content = []
            else:
                content = [marker_text]
            continue

        # Claude 退出后出现 shell prompt，不能把它并进最后一个回答。
        if role and re.match(r"^[^\s@]+@[^:]+:.*[$#] ?", line):
            flush()
            continue
        if role:
            content.append(line)

    flush()
    return blocks


def frame_qa_pairs(screen_lines):
    """把同一 Screen 状态中相邻的 User/Claude 块配成已提交的问答。"""
    pairs = []
    pending_user = None
    for role, text in parse_claude_blocks(screen_lines):
        if role == "user":
            pending_user = text
        elif pending_user:
            pairs.append({"user": pending_user, "claude": text})
            pending_user = None
    return pairs


def normalized_message(text):
    """仅用于跨 frame 对齐，不改变最终输出文本。"""
    return re.sub(r"\s+", " ", text).strip()


def answers_are_related(old, new):
    """判断两个回答是否是流式输出过程中同一消息的不同完整度。"""
    a, b = normalized_message(old), normalized_message(new)
    if not a or not b:
        return True
    if a in b or b in a:
        return True
    # Markdown 流式帧中的粗体/代码标记会在最终 TUI 布局中消失。
    compact = lambda text: re.sub(r"[\s`*]", "", text)
    ac, bc = compact(a), compact(b)
    if ac in bc or bc in ac or (len(ac) >= 40 and len(bc) >= 40 and ac[:40] == bc[:40]):
        return True
    old_lines = [normalized_message(x) for x in old.splitlines() if x.strip()]
    new_lines = [normalized_message(x) for x in new.splitlines() if x.strip()]
    limit = min(len(old_lines), len(new_lines), 8)
    return any(old_lines[-n:] == new_lines[:n] for n in range(1, limit + 1))


def merge_streamed_answer(old, new):
    """合并回答的增长帧、滚屏后缀帧，并避免重绘造成整块重复。"""
    if not old:
        return new
    if not new or old == new:
        return old
    if old in new:
        return new
    if new in old:
        return old

    old_lines = old.splitlines()
    new_lines = new.splitlines()
    limit = min(len(old_lines), len(new_lines))
    for n in range(limit, 0, -1):
        if old_lines[-n:] == new_lines[:n]:
            return "\n".join(old_lines + new_lines[n:]).strip()

    # Screen 全历史通常是单调增长；若只改写了最后一个流式行，保留更完整帧。
    return new if len(new) >= len(old) else old


def claude_frame_ready(screen_lines):
    """只在输入区恢复待命且没有执行中状态时，将最后一轮视为完成。"""
    # 历史中可含旧 spinner；只检查最后一个回复标记以后的界面。
    last_answer = max((i for i, line in enumerate(screen_lines)
                       if line.startswith("●") and not is_claude_ui_noise(line.lstrip("● "))), default=-1)
    if last_answer < 0:
        return False
    tail = screen_lines[last_answer + 1:]
    busy = any("esc to interrupt" in line.lower()
               or CLAUDE_ANIMATED_STATUS_RE.search(line.strip()) for line in tail)
    ready = any((line.startswith("❯") and not is_claude_ui_noise(line[1:].strip())) or line.strip().startswith("Resume this session with:")
                or re.match(r"^[^\s@]+@[^:]+:.*[$#] ?", line) for line in tail)
    return ready and not busy


def extract_claude_session(out_path, tim_path, *, frame_source=None, evidence=None):
    """通过逐帧 Screen diff 提取并去重一个 Claude Code 会话。"""
    rec_id = os.path.basename(out_path)[:-len(".out.gz")]
    records = []
    active = []
    next_id = 0

    frame_source = frame_source if frame_source is not None else iter_screen_diff_frames(out_path, tim_path)
    for frame_no, _, screen_lines, changed_rows, _, _, _ in frame_source:
        if not changed_rows:
            continue
        observations = frame_qa_pairs(screen_lines)
        current = []
        used_ids = set()

        for observation_index, observation in enumerate(observations):
            completed = observation_index < len(observations) - 1 or claude_frame_ready(screen_lines)
            user_key = normalized_message(observation["user"])
            matched_id = None

            # 先与上一 Screen 状态对齐；这样相同问题在后续真正重复时仍可成为新问答。
            for old in active:
                record = records[old["id"]]
                if (old["id"] not in used_ids
                        and normalized_message(record["user"]) == user_key
                        and answers_are_related(record["claude"], observation["claude"])):
                    matched_id = old["id"]
                    break

            # 短暂清屏/重画会让块消失一两帧，允许最近记录重新接续。
            if matched_id is None:
                for record_id in range(len(records) - 1, -1, -1):
                    record = records[record_id]
                    if (record_id not in used_ids and frame_no - record["last_seen"] <= 3
                            and normalized_message(record["user"]) == user_key
                            and answers_are_related(record["claude"], observation["claude"])):
                        matched_id = record_id
                        break

            if matched_id is None:
                matched_id = next_id
                next_id += 1
                records.append({
                    "user": observation["user"],
                    "claude": observation["claude"],
                    "last_seen": frame_no,
                    "completed": completed,
                })
            else:
                record = records[matched_id]
                record["claude"] = (observation["claude"] if completed
                                    else merge_streamed_answer(record["claude"], observation["claude"]))
                record["last_seen"] = frame_no
                record["completed"] = completed

            used_ids.add(matched_id)
            current.append({"id": matched_id})
            if evidence is not None:
                evidence.setdefault("observations", []).append({
                    "record_id": matched_id, "frame": frame_no,
                    "observation_index": observation_index,
                    "user": observation["user"], "claude": observation["claude"],
                })
        active = current

    retained = [(i, r) for i, r in enumerate(records)
                if r["user"] and r["claude"] and r["completed"]]
    pairs = [{"user": r["user"], "claude": r["claude"]} for _, r in retained]
    # 同一问题相邻的流式重排副本合并；隔着其他问题的真实重复提问仍保留。
    deduplicated = []
    retained_ids = []
    for (record_id, _), pair in zip(retained, pairs):
        if (deduplicated and normalized_message(pair["user"]) == normalized_message(deduplicated[-1]["user"])
                and answers_are_related(deduplicated[-1]["claude"], pair["claude"])):
            deduplicated[-1] = pair
            retained_ids[-1].append(record_id)
        else:
            deduplicated.append(pair)
            retained_ids.append([record_id])
    if evidence is not None:
        evidence["pair_record_ids"] = retained_ids
        evidence["record_count"] = len(records)
        evidence["retained_record_count"] = len(retained)
        evidence["unretained_record_count"] = len(records) - len(retained)
        evidence["incomplete_record_count"] = sum(not r["completed"] for r in records)
    return rec_id, deduplicated


def replay_full_terminal(out_path, tim_path):
    """每对录像完整重放后导出连续文本，保留滚屏及清屏历史，不导出逐帧变化。"""
    _, start, header_cols, rows, body = read_term(out_path)
    cols = infer_replay_columns(body, header_cols)
    final_lines = ()
    for _, _, screen_lines, _, _, _, _ in iter_screen_diff_frames(
        out_path, tim_path, archive_clears=True
    ):
        final_lines = screen_lines
    lines = list(final_lines)
    # 仅去除固定屏幕高度造成的末尾填充空行，不使用 Claude QA 清洗规则。
    while lines and not lines[-1]:
        lines.pop()
    return {"rec": Path(out_path).name[:-len(".out.gz")], "start": start,
            "columns": cols, "rows": rows, "lines": lines}


def append_fenced_text(md, lines):
    """以不会与终端内容冲突的 Markdown fence 写入原样文本。"""
    text = "\n".join(lines)
    longest = max((len(m.group(0)) for m in re.finditer(r"`+", text)), default=0)
    fence = "`" * max(3, longest + 1)
    md.append(fence + "text")
    md.extend(lines)
    md.append(fence)


# 从两端定位学号及时间；姓名中的连字符整体保留。
STUDENT_NAME_RE = re.compile(
    r"^(?P<student_id>\d+)-(?P<name>.+?)(?:-实验提交)?-"
    r"(?P<date>\d{8})-(?P<time>\d{4})(?:-(?P<duplicate>\d+))?(?:\.tar\.gz)?$"
)
REPORT_NAMES = ("terminal_qa_report.md", "full_terminal_transcript.md",
                "command_statistics.md", "claude_qa_clean.md")
OWNER_FILE = ".replay_term_qa.json"
README_TITLE = "# 终端实验数据批处理说明"
TIMELINE_DIAGNOSTICS_START = "<!-- replay_term_qa:timeline-diagnostics:start -->"
TIMELINE_DIAGNOSTICS_END = "<!-- replay_term_qa:timeline-diagnostics:end -->"

# README 的版本说明与验证记录；历史验证和每次动态汇总分开。
README_UPDATE_NOTES = [
    "## 本次功能更新：按人和按 Lab 双分类输出",
    "",
    "- 同一份结果同时写入 `按人分类/学生/lab/实验过程清洗工具/` 和 `按Lab分类/lab/学生/实验过程清洗工具/`；两侧文件内容一致。",
    "- 每个实际出现的 lab 叶子包含终端对话、完整转写、命令统计、Claude 对话以及 JSON/Markdown 时间线；无法确认的记录归入 `其他/`。",
    "- 汇总报告和本次运行日志分别保存在根目录的 `汇总报告/` 与 `运行日志/`。",
    "- 分类依据是 Shell 提示符中的工作目录，支持 lab 的子目录。正文、命令参数或 Claude 回复中提到其他 lab，不改变分类。",
    "- 同一录像切换 lab 时按新提示符分段；`cd` 命令归入执行它时所在的目录，后续提示符显示目录变化后才切换分类，失败的 `cd` 不切换。",
    "- Claude 问答按启动所在目录归类；返回同一 lab 后，同一录像的问答合并为一个 Session，Turn 连续编号。完整转写保留片段编号和原始字节区间，每个录像片段输出一次连续文本。",
    "- 保留原有 Shell 提取、Claude Screen/diff 提取及 pyte 重放核心。各分类的命令数和轮次可以相加；跨分类录像及 Claude 会话在学生总计中按原录像去重。",
    "- 全部分类报告写入成功后，按同来源归属清单移除过时的程序报告；保留其他文件，不修改原始实验数据。",
    "",
    "### 验证记录与复查方法",
    "",
    "2026-09-12 的分类版本验证已通过 Python 语法检查和 18 项测试，覆盖跨 lab 切换、返回同一 lab、子目录识别、失败的 cd、缺失计时文件、异常隔离及旧版报告迁移。",
    "",
    "该次完整批处理处理了 12 名学生、134 个录像，得到 262 次 Shell 命令执行、8 个有效 Claude 会话、35 轮对话；133 个录像重放成功，1 个录像缺少有效头部。分类前后命令和问答无遗漏、无重复；11,576 个原始文件的路径、大小、修改时间和 SHA-256 校验一致。此处为该次验证记录，不代表之后每次运行的结果；最近一批结果见文末汇总。",
    "",
    "从脚本所在目录复查：",
    "",
    "```bash",
    "python3 -m py_compile replay_term_qa.py",
    "python3 -m unittest -v test_replay_term_qa",
    "python3 replay_term_qa.py \"../操作系统实验数据记录\" --output \"../操作系统实验数据记录-已清洗\"",
    "```",
    "",
    "以上批处理命令显式指定工作区中的输出目录；省略 `--output` 时仍按输入目录同级的默认规则输出。",
    ""
]


def parse_student_name(name):
    """解析普通目录名或带“实验提交”和重复编号的归档名，不解压归档。"""
    match = STUDENT_NAME_RE.fullmatch(name)
    if not match:
        return None
    info = match.groupdict()
    raw_time = f"{info['date']}-{info['time']}"
    try:
        collected = datetime.strptime(raw_time, "%Y%m%d-%H%M").strftime("%Y-%m-%d %H:%M")
    except ValueError:
        collected = f"{raw_time}（无法解析）"
    return {"student_id": info["student_id"], "name": info["name"],
            "collected": collected, "raw_time": raw_time, "source_name": name}


def markdown_text(value):
    """转义 Markdown 元数据和表格，避免管道、反斜杠等改变排版。"""
    text = str(value).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
    return re.sub(r"([\\`*_{}\[\]()#+!|~])", r"\\\1", text).replace("\n", "<br>").replace("\r", "")


def student_header(title, info, count):
    """四份学生报告统一使用同一份元数据，避免跨学生状态泄漏。"""
    return [f"# {title}", "", f"- 学号：{markdown_text(info['student_id'])}",
            f"- 姓名：{markdown_text(info['name'])}",
            f"- 数据采集时间：{info['collected']}", f"- 原始时间标识：{info['raw_time']}",
            f"- 原始数据目录：{markdown_text(info['source_name'])}",
            f"- 终端录像数量：{count}", ""]


def atomic_write(path, text):
    """Atomically replace a file and its classification-view counterpart."""
    write_text_pair(Path(path), text)


def _stream_sha256(path):
    """Return a SHA-256 digest without loading a recording into memory."""
    digest = hashlib.sha256()
    with Path(path).open("rb") as stream:
        for block in iter(lambda: stream.read(_HASH_CHUNK_SIZE), b""):
            digest.update(block)
    return digest.hexdigest()


def _snapshot_file(path, relative):
    """Describe one input file for an incremental fingerprint.

    Missing timing or event-log files are valid input states. Symlinks and
    unreadable entries remain visible in the snapshot but never become cacheable.
    """
    path = Path(path)
    record = {"path": str(relative).replace("\\", "/")}
    if has_link_component(path):
        record["state"] = "symlink"
        return record, False
    if not path.exists():
        record["state"] = "missing"
        return record, True
    if not path.is_file():
        record["state"] = "not_regular"
        return record, False
    try:
        record.update({"state": "file", "sha256": _stream_sha256(path)})
    except OSError:
        record["state"] = "unreadable"
        return record, False
    return record, True


def snapshot_student_inputs(source, include_timeline_log=False):
    """Build the deterministic, stage-specific input snapshot for one student.

    The report stage observes only term/*.out.gz plus each matching .tim.gz.
    The timeline stage adds logs/events.jsonl. Paths are sorted and every
    regular file contributes its original-byte SHA-256; no input is decompressed
    or replayed while taking the snapshot.
    """
    source = Path(source)
    entries = []
    cacheable = True
    term = source / "term"
    if is_link_like(term):
        entries.append({"path": "term", "state": "symlink"})
        cacheable = False
    elif not term.is_dir():
        entries.append({"path": "term", "state": "missing_or_not_directory"})
        cacheable = False
    else:
        recordings = sorted(term.glob("*.out.gz"), key=lambda item: item.name)
        for out in recordings:
            out_entry, out_cacheable = _snapshot_file(out, out.relative_to(source).as_posix())
            entries.append(out_entry)
            cacheable = cacheable and out_cacheable
            tim = out.with_name(out.name[:-len(".out.gz")] + ".tim.gz")
            tim_entry, tim_cacheable = _snapshot_file(tim, tim.relative_to(source).as_posix())
            entries.append(tim_entry)
            cacheable = cacheable and tim_cacheable
    if include_timeline_log:
        event_entry, event_cacheable = _snapshot_file(
            source / "logs" / "events.jsonl", "logs/events.jsonl"
        )
        entries.append(event_entry)
        cacheable = cacheable and event_cacheable
    entries.sort(key=lambda item: item["path"])
    payload = {
        "cache_format_version": INCREMENTAL_CACHE_FORMAT_VERSION,
        "stage": "timeline" if include_timeline_log else "reports",
        "entries": entries,
    }
    encoded = json.dumps(payload, ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode("utf-8")
    return {
        "fingerprint": hashlib.sha256(encoded).hexdigest(),
        "cacheable": cacheable,
        "entries": entries,
    }


def term_recordings(term):
    """Return regular recording files without following symbolic links."""
    term = Path(term)
    if not term.is_dir() or is_link_like(term):
        return []
    return sorted(
        (path for path in term.glob("*.out.gz") if path.is_file() and not is_link_like(path)),
        key=lambda path: path.name,
    )


def _processor_signature(stage, paths):
    """Fingerprint the code that semantically owns one output stage."""
    digest = hashlib.sha256()
    digest.update(f"replay_term_qa:{stage}:cache-v{INCREMENTAL_CACHE_FORMAT_VERSION}\\0".encode("utf-8"))
    for path in paths:
        path = Path(path)
        digest.update(path.name.encode("utf-8"))
        digest.update(b"\\0")
        digest.update(_stream_sha256(path).encode("ascii"))
        digest.update(b"\\0")
    return digest.hexdigest()


def report_processor_signature():
    return _processor_signature(
        "reports", (Path(__file__).resolve(), CLEANING_DIR / "output_layout.py")
    )


def timeline_processor_signature():
    return _processor_signature(
        "timeline",
        (Path(__file__).resolve(), TOOL_DIR / "timeline_alignment.py",
         TOOL_DIR / "timeline_reports.py", CLEANING_DIR / "output_layout.py"),
    )


def safe_component(name):
    """生成 Windows/Linux 都可使用的目录名；消毒后加摘要防止碰撞。"""
    safe = re.sub(r'[<>:"/\\|?*\x00-\x1f]', "_", name).rstrip(" .")
    if not safe or safe in (".", ".."):
        safe = "未知"
    if re.match(r"^(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])(?:\.|$)", safe, re.I):
        safe = "_" + safe
    if len(safe) > 100:
        safe = safe[:100]
    if safe != name:
        safe += "-" + hashlib.sha256(name.encode("utf-8")).hexdigest()[:8]
    return safe


def scan_students(input_dir, student_filter=None):
    """只扫描直接子目录；含 term 的输入目录始终允许作为旧版单学生输入。"""
    single = (input_dir / "term").is_dir()
    candidates = [input_dir] if single else sorted(input_dir.iterdir(), key=lambda p: p.name)
    students, skipped = [], []
    for directory in candidates:
        if not directory.is_dir():
            continue
        if is_link_like(directory):
            skipped.append((directory.name, "跳过符号链接目录"))
            continue
        info = parse_student_name(directory.name)
        if info is None and single:
            info = {"student_id": "未知", "name": "未知", "collected": "未知",
                    "raw_time": "未知", "source_name": directory.name}
        if info is None:
            skipped.append((directory.name, "目录名称不符合学生命名规则"))
            continue
        info["source"] = str(directory.resolve())
        info["source_reference"] = (
            Path(input_dir.name) / directory.relative_to(input_dir)
        ).as_posix()
        if student_filter and student_filter not in (info["student_id"], info["name"]):
            skipped.append((directory.name, "不匹配 --student 筛选条件"))
            # 保留到分配目录阶段，保证筛选前后同名学生的输出位置一致。
            info["selected"] = False
        else:
            info["selected"] = True
        students.append(info)
    return students, skipped


def allocate_outputs(students, output_dir, overwrite=False):
    """先对全部学生分配名字；重复采集、同名、已有其他学生结果均不得混用。"""
    counts = Counter(safe_component(s["name"]).casefold() for s in students)
    used = set()
    existing = {p.name.casefold(): p for p in output_dir.iterdir()} if output_dir.exists() else {}
    for info in students:
        base = safe_component(info["name"])
        if counts[base.casefold()] > 1:
            base = safe_component(f"{info['name']}-{info['student_id']}")
        candidate = base
        sequence = 0
        while True:
            key = candidate.casefold()
            target = existing.get(key, output_dir / candidate)
            available = key not in used and not has_link_component(target)
            if target.exists():
                owner_path = target / OWNER_FILE
                owner = _read_json_object(owner_path)
                owner_exists = owner_path.exists() or is_link_like(owner_path)
                report_owned = _report_manifest_matches_student(owner, info)
                timeline_owned = not is_link_like(owner_path) and timeline_owned_by(
                    target, info.get("source_reference", info["source"])
                )
                # A timeline-only directory can be reused before reports have
                # an owner. A malformed owner can recover only from a valid
                # same-source timeline; a parseable foreign owner remains an
                # absolute boundary.
                timeline_reusable = timeline_owned and (
                    (not owner_exists and (overwrite or not has_fixed_report_artifacts(target)))
                    or (owner_exists and owner is None)
                )
                available = available and target.is_dir() and (
                    report_owned or timeline_reusable or (not owner_exists and overwrite)
                )
            if available:
                break
            sequence += 1
            suffix = safe_component(f"{info['student_id']}-{info['raw_time']}")
            candidate = f"{base}-{suffix}" + (f"-{sequence}" if sequence > 1 else "")
        used.add(key)
        info["output"] = target


def add_statistics_table(md, counter):
    md.extend(["| command | count |", "| --- | ---: |"])
    for command, count in sorted(counter.items(), key=lambda item: (-item[1], item[0])):
        md.append(f"| {markdown_text(command)} | {count} |")
    md.append("")


REPORT_FOLDERS = ("终端对话记录", "完整终端转写记录", "终端命令统计", "claude对话")
LAB_KEYS = tuple(f"lab{i}" for i in range(9)) + ("other",)
# 仅用于工作目录分类，不改变原有 Shell 命令提取规则。
def lab_from_cwd(cwd):
    """仅按完整目录段识别 lab0–lab8，支持其子目录；lab10、lab0-copy 不匹配。"""
    parts = cwd.strip().replace("\\", "/").split("/")
    # 规范化 ..，避免 /lab0/../other 被错误分类为 lab0。
    normalized = []
    for part in parts:
        if part == "..":
            if normalized:
                normalized.pop()
        elif part not in ("", "."):
            normalized.append(part)
    return next((part for part in reversed(normalized) if part in LAB_KEYS[:-1]), "other")


def lab_report_paths(lab):
    """Place the four reports in the lab/tool leaf of both output views."""
    if lab not in LAB_KEYS:
        raise ValueError(f"未知实验分类：{lab}")
    directory = "其他" if lab == "other" else lab
    return tuple(
        Path(directory) / PROCESS_TOOL / name
        for name in ("终端对话记录.md", "完整终端转写记录.md",
                     "终端命令统计.md", "Claude对话记录.md")
    )


def fixed_report_artifact_paths():
    """Return every fixed report name the report stage may own or replace."""
    return tuple(Path(name) for name in REPORT_NAMES) + tuple(
        path for lab in LAB_KEYS for path in lab_report_paths(lab)
    )


def has_fixed_report_artifacts(directory):
    """Return whether an otherwise unowned output contains a fixed report path."""
    directory = Path(directory)
    for relative in fixed_report_artifact_paths():
        target = directory / relative
        if target.exists() or has_link_component(target):
            return True
    return False


def split_lab_regions(body):
    """在真实提示符处切分工作目录变化；不根据用户输入、cd 文本或回复内容猜测。"""
    prompts = shell_prompt_matches(body)
    if not prompts:
        return [{"lab": "other", "begin": 0, "end": len(body), "cwd": "未知"}]
    first_cwd = prompts[0].group("cwd").decode("utf-8", "replace")
    regions = [{"lab": lab_from_cwd(first_cwd), "begin": 0, "cwd": first_cwd}]
    for prompt in prompts[1:]:
        cwd = prompt.group("cwd").decode("utf-8", "replace")
        lab = lab_from_cwd(cwd)
        if lab != regions[-1]["lab"]:
            regions[-1]["end"] = prompt.start()
            regions.append({"lab": lab, "begin": prompt.start(), "cwd": cwd})
    regions[-1]["end"] = len(body)
    return regions


def region_timing(entries, begin, end):
    """裁剪 timing 字节区间；首帧保留原录像累计时间，跨分类边界的一帧拆开。"""
    offset = 0
    elapsed = 0.0
    last_emitted = 0.0
    clipped = []
    for delay, size in entries:
        elapsed += delay
        next_offset = offset + size
        overlap = min(end, next_offset) - max(begin, offset)
        if overlap > 0:
            clipped.append((elapsed - last_emitted, overlap))
            last_emitted = elapsed
        offset = next_offset
        if offset >= end:
            break
    # 缺失/截短计时信息时仍保留全部剩余字节，与旧版降级逻辑一致。
    if offset < end:
        size = end - max(begin, offset)
        if size > 0:
            clipped.append((max(0.0, elapsed - last_emitted), size))
    return clipped


def new_lab_bucket():
    return {"files": set(), "commands": [], "full": [], "claude": {},
            "errors": [], "shell_success": set()}


def _read_json_object(path):
    path = Path(path)
    if is_link_like(path):
        return None
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, ValueError, TypeError):
        return None
    return value if isinstance(value, dict) else None


def _report_manifest_matches_student(manifest, info):
    source_reference = info.get("source_reference", info.get("source"))
    return bool(
        isinstance(manifest, dict)
        and manifest.get("tool") == "replay_term_qa"
        and manifest.get("source") in {source_reference, info.get("source")}
    )


def _bounded_diagnostics(errors):
    """Keep cache and README diagnostics useful without making manifests unbounded."""
    if not isinstance(errors, (list, tuple)):
        return []
    result, seen = [], set()
    for error in errors:
        if not isinstance(error, str):
            continue
        text = error[:MAX_CACHED_DIAGNOSTIC_LENGTH]
        if text in seen:
            continue
        seen.add(text)
        result.append(text)
        if len(result) >= MAX_CACHED_DIAGNOSTICS:
            break
    return result


def _report_summary(result):
    keys = ("recordings", "commands", "claude_sessions", "turns", "replay_failed")
    labs = {}
    for lab, values in (result.get("labs") or {}).items():
        if lab not in LAB_KEYS or not isinstance(values, dict):
            continue
        labs[lab] = {key: int(values.get(key, 0)) for key in keys}
    return {key: int(result.get(key, 0)) for key in keys} | {
        "labs": labs,
        "errors": _bounded_diagnostics(result.get("errors")),
    }


def _report_summary_is_valid(summary):
    keys = ("recordings", "commands", "claude_sessions", "turns", "replay_failed")
    if not isinstance(summary, dict) or not isinstance(summary.get("labs"), dict):
        return False
    errors = summary.get("errors")
    if (
        not isinstance(errors, list)
        or len(errors) > MAX_CACHED_DIAGNOSTICS
        or not all(isinstance(error, str) and len(error) <= MAX_CACHED_DIAGNOSTIC_LENGTH
                   for error in errors)
    ):
        return False
    if not summary["labs"]:
        return False
    for key in keys:
        if not isinstance(summary.get(key), int) or isinstance(summary.get(key), bool):
            return False
    for lab, values in summary["labs"].items():
        if lab not in LAB_KEYS or not isinstance(values, dict):
            return False
        for key in keys:
            if not isinstance(values.get(key), int) or isinstance(values.get(key), bool):
                return False
    return True


def _report_paths_from_summary(summary):
    if not _report_summary_is_valid(summary):
        return None
    return sorted(
        path.as_posix()
        for lab in summary["labs"]
        for path in lab_report_paths(lab)
    )


def _report_artifact_is_valid(output, relative):
    allowed = {path.as_posix() for lab in LAB_KEYS for path in lab_report_paths(lab)}
    if relative not in allowed:
        return False
    target = Path(output) / Path(relative)
    if has_link_component(target) or not target.is_file():
        return False
    try:
        resolved = target.resolve()
        output = Path(output).resolve()
    except OSError:
        return False
    return output in resolved.parents


def _report_artifact_hashes_are_valid(output, reports, hashes):
    if not isinstance(hashes, dict) or set(hashes) != set(reports):
        return False
    for relative in reports:
        digest = hashes.get(relative)
        if not isinstance(digest, str) or not re.fullmatch(r"[0-9a-f]{64}", digest):
            return False
        try:
            target = Path(output) / relative
            if _stream_sha256(target) != digest or not pair_matches(target):
                return False
        except OSError:
            return False
    return True


def report_cache_hit(info, snapshot, processor_signature):
    """Return a restored report result only when every cache invariant holds."""
    output = Path(info["output"])
    owner_path = output / OWNER_FILE
    if not snapshot.get("cacheable") or has_link_component(output) or not output.is_dir():
        return None
    manifest = _read_json_object(owner_path)
    if (
        not isinstance(manifest, dict)
        or manifest.get("tool") != "replay_term_qa"
        or not _report_manifest_matches_student(manifest, info)
    ):
        return None
    if (
        manifest.get("status") != "complete"
        or manifest.get("cache_format_version") != INCREMENTAL_CACHE_FORMAT_VERSION
        or manifest.get("input_fingerprint") != snapshot.get("fingerprint")
        or manifest.get("processor_signature") != processor_signature
    ):
        return None
    summary = manifest.get("summary")
    expected = _report_paths_from_summary(summary)
    reports = manifest.get("reports")
    if (
        not isinstance(reports, list)
        or not all(isinstance(relative, str) for relative in reports)
        or sorted(reports) != expected
        or len(set(reports)) != len(reports)
    ):
        return None
    if not all(isinstance(relative, str) and _report_artifact_is_valid(output, relative)
               for relative in reports):
        return None
    if not _report_artifact_hashes_are_valid(output, reports, manifest.get("artifact_sha256")):
        return None
    return {
        "status": "增量跳过",
        "info": info,
        "cache_hit": True,
        **summary,
    }


def mark_report_rebuild(info):
    """Invalidate a prior successful report cache before any rebuild work starts."""
    output = Path(info["output"])
    owner_path = output / OWNER_FILE
    if has_link_component(owner_path):
        raise ValueError(f"拒绝覆盖符号链接归属清单：{owner_path}")
    previous = _read_json_object(owner_path)
    if owner_path.exists() and not _report_manifest_matches_student(previous, info):
        return
    allowed = set(REPORT_NAMES) | {path.as_posix() for lab in LAB_KEYS for path in lab_report_paths(lab)}
    reports = previous.get("reports") if isinstance(previous, dict) and isinstance(previous.get("reports"), list) else []
    manifest = {
        "tool": "replay_term_qa",
        "source": info.get("source_reference", info["source"]),
        "layout": previous.get("layout", "by-lab-v1") if isinstance(previous, dict) else "by-lab-v1",
        "status": "building",
        "reports": sorted(relative for relative in reports if relative in allowed),
    }
    atomic_write(owner_path, json.dumps(manifest, ensure_ascii=False, indent=2) + "\n")


def remove_student_reports(info):
    """Clear same-source registered reports when the source has no recordings."""
    output_path = Path(info["output"])
    if has_link_component(output_path):
        raise ValueError(f"拒绝使用符号链接学生输出目录：{output_path}")
    if not output_path.is_dir():
        return False
    output = output_path.resolve()
    owner_path = output / OWNER_FILE
    if has_link_component(owner_path):
        raise ValueError(f"拒绝删除符号链接归属清单：{owner_path}")
    manifest = _read_json_object(owner_path)
    if not _report_manifest_matches_student(manifest, info):
        return False

    allowed = set(REPORT_NAMES) | {
        path.as_posix() for lab in LAB_KEYS for path in lab_report_paths(lab)
    }
    reports = manifest.get("reports")
    if (
        not isinstance(reports, list)
        or not all(isinstance(relative, str) for relative in reports)
        or len(reports) != len(set(reports))
        or not all(relative in allowed for relative in reports)
    ):
        raise ValueError(f"归属清单中的报告路径无效：{owner_path}")

    targets = []
    for relative in reports:
        target = output / Path(relative)
        if has_link_component(target):
            raise ValueError(f"拒绝删除符号链接报告：{target}")
        resolved = target.resolve()
        if output not in resolved.parents:
            raise ValueError(f"报告目标越出学生输出目录：{target}")
        if target.exists() and not target.is_file():
            raise ValueError(f"拒绝删除非普通文件报告：{target}")
        targets.append(target)

    for target in targets:
        unlink_pair(target)
    atomic_write(owner_path, json.dumps({
        "tool": "replay_term_qa",
        "source": info.get("source_reference", info["source"]),
        "layout": "dual-view-v2",
        "status": "cleared",
        "reports": [],
    }, ensure_ascii=False, indent=2) + "\n")
    return True


def validate_student_report_targets(info, paths, *, overwrite=False):
    """Reject unowned fixed report files before any student report is replaced."""
    directory_path = Path(info["output"])
    if has_link_component(directory_path):
        raise ValueError(f"拒绝使用符号链接学生输出目录：{directory_path}")
    directory = directory_path.resolve()
    owner_path = directory / OWNER_FILE
    if has_link_component(owner_path):
        raise ValueError(f"拒绝覆盖符号链接归属清单：{owner_path}")
    manifest = _read_json_object(owner_path)
    report_owned = _report_manifest_matches_student(manifest, info)
    recovering_timeline_owned_output = (
        owner_path.exists()
        and manifest is None
        and timeline_owned_by(directory, info.get("source_reference", info["source"]))
    )
    if owner_path.exists() and not report_owned and not recovering_timeline_owned_output:
        raise ValueError(f"报告归属清单无效或属于其他来源：{owner_path}")
    for relative in paths:
        target = directory / relative
        if has_link_component(target):
            raise ValueError(f"拒绝覆盖符号链接报告：{target}")
        resolved = target.resolve()
        if directory not in resolved.parents:
            raise ValueError(f"报告目标越出学生输出目录：{target}")
        if target.exists() and not target.is_file():
            raise ValueError(f"报告目标不是普通文件：{target}")
        if target.exists() and not report_owned and not overwrite and not recovering_timeline_owned_output:
            raise ValueError(
                f"报告路径已有未登记内容，请使用 --overwrite 或选择其他输出目录：{target}"
            )


def finish_student_reports(info, paths, *, stage_status, incremental=None, summary=None):
    """登记新版报告清单；仅移除同来源清单中已过时的程序报告，不碰原始数据。"""
    directory_path = Path(info["output"])
    if has_link_component(directory_path):
        raise ValueError(f"拒绝使用符号链接学生输出目录：{directory_path}")
    directory = directory_path.resolve()
    owner_path = directory / OWNER_FILE
    previous = _read_json_object(owner_path) or {}
    allowed = set(REPORT_NAMES) | {p.as_posix() for lab in LAB_KEYS for p in lab_report_paths(lab)}
    wanted = {p.as_posix() for p in paths}
    if _report_manifest_matches_student(previous, info):
        for relative in previous.get("reports", []):
            if relative in allowed and relative not in wanted:
                target = directory / relative
                resolved = target.resolve()
                if directory in resolved.parents and not has_link_component(target) and target.is_file():
                    unlink_pair(target)
    manifest = {"tool": "replay_term_qa", "source": info.get("source_reference", info["source"]), "layout": "dual-view-v2",
                "status": stage_status, "reports": sorted(wanted)}
    if (
        stage_status == "complete"
        and isinstance(incremental, dict)
        and isinstance(incremental.get("fingerprint"), str)
        and isinstance(incremental.get("processor_signature"), str)
        and _report_summary_is_valid(summary)
    ):
        manifest.update({
            "cache_format_version": INCREMENTAL_CACHE_FORMAT_VERSION,
            "input_fingerprint": incremental["fingerprint"],
            "processor_signature": incremental["processor_signature"],
            "summary": summary,
            "artifact_sha256": {
                relative: _stream_sha256(directory / relative)
                for relative in sorted(wanted)
            },
        })
    atomic_write(owner_path, json.dumps(manifest, ensure_ascii=False, indent=2) + "\n")


def write_student_reports(info, files, commands, full_sessions, claude_sessions, errors,
                          shell_success, lab="other"):
    """集中生成四份报告，所有计数均由本学生实际提取结果计算。"""
    counter = Counter(c["command"] for c in commands)
    shell_sessions = len({c["rec"] for c in commands})
    claude_sessions = [s for s in claude_sessions if s["pairs"]]
    turns = sum(len(s["pairs"]) for s in claude_sessions)
    header = lambda title: student_header(title, info, len(files)) + [
        f"- 实验分类：{lab if lab != 'other' else '其他（非 lab0–lab8 或目录未知）'}", ""]
    totals = [f"- Shell 命令执行总次数：{len(commands)}", f"- 不同 Shell 命令数量：{len(counter)}"]
    report = header("终端会话问答对与命令频次报告") + totals + [
        f"- 包含 Shell 命令的终端会话数：{shell_sessions}",
        f"- 无 Shell 命令的终端会话数：{shell_success - shell_sessions}",
        f"- Shell 提取失败会话数：{len(files) - shell_success}", "",
        "Q 为 shell 提示符下输入的完整命令，A 为命令输出。每条命令输出最多保留 400 行。", "",
        "## 一、问答对集合", ""]
    for c in commands:
        elapsed = f"{c['elapsed']}s" if c["elapsed"] is not None else "未知"
        report.extend([f"### 问答 {c['seq']} · 录像 {c['rec']}", "",
                       f"- 开始时间：{c['start'] or '未知'}", f"- 相对时间：{elapsed}",
                       f"- 命令执行目录：{markdown_text(c['cwd'])}", "", "**Q（命令）：**", ""])
        append_fenced_text(report, [c["command"]])
        report.extend(["", "**A（输出）：**", ""])
        shown = c["output"][:MAX_OUTPUT_LINES]
        append_fenced_text(report, shown or ["（无输出）"])
        if len(c["output"]) > len(shown):
            report.append(f"（其余 {len(c['output']) - len(shown)} 行已省略，详见完整转写。）")
        report.append("")
    report.extend(["## 二、终端命令频次", ""])
    add_statistics_table(report, counter)
    if errors:
        report.extend(["## 三、处理异常", ""] + [f"- {markdown_text(e)}" for e in errors] + [""])

    full = header("Full Terminal Transcript") + [f"- 终端录像总数：{len(files)}",
        f"- 成功重放数量：{len({s['rec'] for s in full_sessions if 'error' not in s} - {s['rec'] for s in full_sessions if 'error' in s})}",
        f"- 重放失败数量：{len({s['rec'] for s in full_sessions if 'error' in s})}", "",
        "每对 .out.gz + .tim.gz 经 pyte 完整重放后输出连续文本，保留滚屏及清屏历史，不执行 Claude 清洗。",
        "跨 lab 的录像仍按原有分类分段，每个片段输出一次完整重放结果，不展开逐帧变化或逐字符中间状态。", ""]
    for s in full_sessions:
        suffix = f" · 片段 {s['region']}" if 'region' in s else ""
        full.extend([f"## Session {s['rec']}{suffix}", ""])
        if 'begin' in s:
            full.extend([f"- 原录像字节区间：[ {s['begin']}, {s['end']} )",
                         f"- 分类依据目录：{markdown_text(s['cwd'])}", ""])
        if "error" in s:
            full.extend([f"- 失败文件：{markdown_text(s['file'])}",
                         f"- 错误原因：{markdown_text(s['error'])}", ""])
            continue
        full.extend([f"- 开始时间：{s['start'] or '未知'}",
                     f"- 终端尺寸：{s['columns']} × {s['rows']}", ""])
        append_fenced_text(full, s["lines"])
        full.append("")
    stats = header("Terminal Command Statistics") + totals + [""]
    add_statistics_table(stats, counter)
    qa = header("Claude Code QA (Clean)") + [f"- Claude 会话总数：{len(claude_sessions)}",
        f"- 对话轮次总数：{turns}", f"- 有效用户问题数：{turns}", f"- 有效 Claude 回复数：{turns}", ""]
    for number, s in enumerate(claude_sessions, 1):
        qa.extend([f"## Session {number}：{s['rec']}", "", f"- 对话轮次：{len(s['pairs'])}",
                   f"- 开始时间：{s['start'] or '未知'}", ""])
        for turn, pair in enumerate(s["pairs"], 1):
            qa.extend([f"### Turn {turn}", "", "#### User", "", pair["user"], "",
                       "#### Claude", "", pair["claude"], ""])
    for name, content in zip(lab_report_paths(lab), (report, full, stats, qa)):
        target = info["output"] / name
        if info["output"].resolve() not in target.resolve().parents:
            raise ValueError(f"报告目标越出学生输出目录：{target}")
        atomic_write(target, "\n".join(content))
    return {"recordings": len(files), "commands": len(commands), "claude_sessions": len(claude_sessions),
            "turns": turns, "replay_failed": len({s['rec'] for s in full_sessions if "error" in s})}


def process_student(info, incremental=None, overwrite=False):
    """按提示符工作目录分段重放；Claude 保持启动目录归属，直到返回新的 Shell 提示符。"""
    if incremental is None:
        incremental = info.get("_report_incremental")
    term = Path(info["source"]) / "term"
    if not term.is_dir() or is_link_like(term):
        return {"status": "失败", "info": info, "errors": [f"{term}：缺少 term/ 或为符号链接"]}
    files = term_recordings(term)
    if not files:
        return {
            "status": "失败",
            "info": info,
            "errors": [f"{term}：未发现可处理的 *.out.gz 录像，不生成空报告"],
            "recordings": 0,
            "commands": 0,
            "claude_sessions": 0,
            "turns": 0,
            "replay_failed": 0,
            "labs": {},
        }
    buckets, errors, failed_recordings = {}, [], set()
    claude_recordings = set()
    stage_failed = False

    def bucket(lab):
        return buckets.setdefault(lab, new_lab_bucket())

    for number, out in enumerate(files, 1):
        tim = out.with_name(out.name[:-len(".out.gz")] + ".tim.gz")
        rec = out.name[:-len(".out.gz")]
        print(f"  [录像 {number}/{len(files)}] {out.name}", flush=True)
        try:
            header, start, columns, rows, body = read_term(out)
            regions = split_lab_regions(body)
        except Exception as exc:
            message = f"{out} [完整重放/目录分类] {type(exc).__name__}: {exc}"
            errors.append(message)
            failed_recordings.add(rec)
            stage_failed = True
            group = bucket("other")
            group["files"].add(out)
            group["errors"].append(message)
            group["full"].append({"rec": rec, "file": str(out), "error": str(exc)})
            print(f"  [失败] {message}", flush=True)
            continue
        entries = read_timing_entries(tim, body)
        if not entries:
            warning = f"{tim}：计时文件缺失、为空、损坏或未覆盖完整录像，使用一次性重放且不记录相对时间"
            errors.append(warning)
            print(f"  [警告] {warning}", flush=True)
        for region in regions:
            group = bucket(region["lab"])
            group["files"].add(out)
            if not entries and warning not in group["errors"]:
                group["errors"].append(warning)
        # 命令仍在完整原录像上提取一次，按每条命令的原始 cwd 分流。
        try:
            _, _, extracted = extract_session(str(out), str(tim))
            for command in extracted:
                group = bucket(lab_from_cwd(command["cwd"]))
                group["files"].add(out)
                group["commands"].append(command)
            for group in buckets.values():
                if out in group["files"]:
                    group["shell_success"].add(rec)
        except Exception as exc:
            message = f"{out} [Shell 提取] {type(exc).__name__}: {exc}"
            errors.append(message)
            stage_failed = True
            for region in regions:
                bucket(region["lab"])["errors"].append(message)
            print(f"  [失败] {message}", flush=True)

        # 使用临时 gzip 片段复用原 pyte Screen/diff 提取器；从不改写学生文件。
        with tempfile.TemporaryDirectory(prefix="replay-labs-") as temporary:
            for index, region in enumerate(regions, 1):
                group = bucket(region["lab"])
                try:
                    if len(regions) == 1:
                        segment_out, segment_tim = out, tim
                    else:
                        segment_out = Path(temporary) / out.name
                        segment_tim = Path(temporary) / tim.name
                        segment = body[region["begin"]:region["end"]]
                        segment_header = header.encode("utf-8") + b"\n" if header else b""
                        segment_out.write_bytes(gzip.compress(segment_header + segment))
                        clipped = region_timing(entries, region["begin"], region["end"])
                        segment_tim.write_bytes(gzip.compress("".join(
                            f"{delay:.9f} {size}\n" for delay, size in clipped).encode("ascii")))
                except Exception as exc:
                    message = f"{out} [{region['lab']} 片段 {index} 准备] {type(exc).__name__}: {exc}"
                    errors.append(message)
                    group["errors"].append(message)
                    group["full"].append({"rec": rec, "file": str(out), "error": str(exc)})
                    failed_recordings.add(rec)
                    stage_failed = True
                    continue
                for stage in ("完整重放", "Claude QA 提取"):
                    try:
                        if stage == "完整重放":
                            session = replay_full_terminal(segment_out, segment_tim)
                            session.update(region=index, begin=region["begin"], end=region["end"], cwd=region["cwd"])
                            group["full"].append(session)
                        else:
                            _, pairs = extract_claude_session(str(segment_out), str(segment_tim))
                            session = group["claude"].setdefault(rec, {"rec": rec, "start": start, "pairs": []})
                            session["pairs"].extend(pairs)
                            if pairs:
                                claude_recordings.add(rec)
                    except Exception as exc:
                        message = f"{out} [{region['lab']} 片段 {index} {stage}] {type(exc).__name__}: {exc}"
                        errors.append(message)
                        group["errors"].append(message)
                        stage_failed = True
                        print(f"  [失败] {message}", flush=True)
                        if stage == "完整重放":
                            failed_recordings.add(rec)
                            group["full"].append({"rec": rec, "file": str(out), "error": str(exc)})
    if not buckets:
        bucket("other")
    paths = [path for lab in LAB_KEYS if lab in buckets for path in lab_report_paths(lab)]
    validate_student_report_targets(info, paths, overwrite=overwrite)
    per_lab = {}
    for lab in LAB_KEYS:
        if lab not in buckets:
            continue
        group = buckets[lab]
        per_lab[lab] = write_student_reports(
            info, group["files"], group["commands"], group["full"], list(group["claude"].values()),
            group["errors"], len(group["shell_success"]), lab)
        print(f"  [分类 {lab}] {per_lab[lab]['recordings']} 个录像，"
              f"{per_lab[lab]['commands']} 条命令，{per_lab[lab]['turns']} 轮 QA", flush=True)
    result = {"status": "部分失败" if stage_failed else "成功", "info": info, "errors": errors,
              "recordings": len(files), "commands": sum(r["commands"] for r in per_lab.values()),
              "claude_sessions": len(claude_recordings), "turns": sum(r["turns"] for r in per_lab.values()),
              "replay_failed": len(failed_recordings), "labs": per_lab}
    finish_student_reports(
        info,
        paths,
        stage_status="partial" if stage_failed else "complete",
        incremental=incremental,
        summary=_report_summary(result),
    )
    return result


def _report_stage_label(result):
    return {
        "成功": "已处理",
        "增量跳过": "增量跳过",
        "部分失败": "部分失败",
        "失败": "失败",
        "跳过": "跳过",
    }.get(result.get("status"), "未运行")


def _timeline_stage_label(result):
    status = result.get("status")
    return {
        "complete": "已处理",
        "incremental_skip": "增量跳过",
        "partial": "部分失败",
        "failed": "失败",
    }.get(status, result.get("stage_status", "未运行"))


def _missing_source_outputs(output_dir, assigned_outputs):
    """Find tool-owned student outputs whose original source is now absent.

    This is intentionally limited to a default full batch. The caller supplies
    all currently assigned output directories, including unselected entries.
    """
    output_dir = Path(output_dir)
    assigned = {Path(path).resolve() for path in assigned_outputs}
    missing = []
    for directory in sorted(output_dir.iterdir(), key=lambda path: path.name):
        if has_link_component(directory) or not directory.is_dir() or directory.resolve() in assigned:
            continue
        report_owner = _read_json_object(directory / OWNER_FILE)
        timeline_owner = _read_json_object(
            directory / TIMELINE_DIRECTORY / TIMELINE_MANIFEST
        )
        sources = []
        if isinstance(report_owner, dict) and report_owner.get("tool") == "replay_term_qa":
            sources.append(("报告", report_owner.get("source")))
        if isinstance(timeline_owner, dict) and timeline_owner.get("tool") == TIMELINE_TOOL:
            sources.append(("时间线", timeline_owner.get("source")))
        valid_sources = [(stage, source) for stage, source in sources if isinstance(source, str)]
        if not valid_sources or any(Path(source).exists() for _, source in valid_sources):
            continue
        source = valid_sources[0][1]
        source_name = source.rstrip("/\\").replace("\\", "/").rsplit("/", 1)[-1] or directory.name
        parsed = parse_student_name(source_name) or {
            "student_id": "未知", "name": directory.name, "collected": "未知",
            "raw_time": "未知", "source_name": source_name,
        }
        parsed.update({"source": source, "output": directory})
        stages = {stage for stage, _ in valid_sources}
        missing.append({
            "status": "原始提交已不存在，输出已保留",
            "info": parsed,
            "errors": [],
            "report_stage": "原始提交已不存在，输出已保留" if "报告" in stages else "未管理",
            "timeline_stage": "原始提交已不存在，输出已保留" if "时间线" in stages else "未管理",
        })
    return missing


def _overview_rows(results, timeline_results, missing_sources):
    rows = {}
    for result in results:
        info = result["info"]
        key = str(Path(info["output"]).resolve())
        rows[key] = {"info": info, "report": result, "timeline": None}
    for result in timeline_results:
        info = result["info"]
        key = str(Path(info["output"]).resolve())
        rows.setdefault(key, {"info": info, "report": None, "timeline": None})["timeline"] = result
    ordered = list(rows.values())
    for result in missing_sources:
        ordered.append({"info": result["info"], "report": None, "timeline": None, "missing": result})
    return ordered


def existing_timeline_readme_block(readme_path):
    """Return complete prior timeline blocks so reports-only runs preserve them."""
    path = Path(readme_path)
    if not path.is_file():
        return None
    try:
        text = path.read_text(encoding="utf-8")
    except OSError:
        return None
    start = text.find(README_BLOCK_START)
    end = text.find(README_BLOCK_END, start)
    if start < 0 or end < start:
        return None
    blocks = [text[start:end + len(README_BLOCK_END)]]
    diagnostic_start = text.find(TIMELINE_DIAGNOSTICS_START)
    diagnostic_end = text.find(TIMELINE_DIAGNOSTICS_END, diagnostic_start)
    if diagnostic_start >= 0 and diagnostic_end >= diagnostic_start:
        blocks.append(text[diagnostic_start:diagnostic_end + len(TIMELINE_DIAGNOSTICS_END)])
    return "\n\n".join(blocks)


def _timeline_result_diagnostics(result):
    """Restore timeline warnings from validated JSON artifacts on a cache hit."""
    direct = _bounded_diagnostics(result.get("errors"))
    if direct or not result.get("cache_hit"):
        return direct
    info = result.get("info") or {}
    output = info.get("output")
    if not output:
        return []
    recovered = []
    for relative in result.get("artifacts") or []:
        path = Path(relative)
        if (
            len(path.parts) != 3
            or path.parts[0] not in {*LAB_KEYS[:-1], "其他"}
            or path.parts[1] != PROCESS_TOOL
            or path.name != "实验过程时间线.json"
        ):
            continue
        target = Path(output) / path
        if has_link_component(target) or not target.is_file():
            continue
        try:
            document = json.loads(target.read_text(encoding="utf-8"))
        except (OSError, TypeError, ValueError):
            continue
        if isinstance(document, dict):
            recovered.extend(document.get("errors") or [])
    return _bounded_diagnostics(recovered)


def update_timeline_diagnostics_block(readme_path, timeline_results):
    """Keep per-student timeline diagnostics visible for normal and cached runs."""
    path = Path(readme_path)
    original = path.read_text(encoding="utf-8") if path.is_file() else README_TITLE + "\n"
    diagnostics = []
    for result in timeline_results:
        info = result.get("info") or {}
        source_name = info.get("source_name") or Path(str(info.get("source") or "未知")).name
        diagnostics.extend(
            f"{source_name} [时间线] {error}"
            for error in _timeline_result_diagnostics(result)
        )
    diagnostics = _bounded_diagnostics(diagnostics)
    block = [TIMELINE_DIAGNOSTICS_START, "### 时间线异常详情", ""]
    if diagnostics:
        block.extend(f"- {markdown_text(error)}" for error in diagnostics)
    else:
        block.append("无。")
    block.extend(["", TIMELINE_DIAGNOSTICS_END])
    start = original.find(TIMELINE_DIAGNOSTICS_START)
    end = original.find(TIMELINE_DIAGNOSTICS_END, start)
    if start >= 0 and end >= start:
        end += len(TIMELINE_DIAGNOSTICS_END)
        text = original[:start] + "\n".join(block) + original[end:]
    else:
        text = original + ("\n" if original.endswith("\n") else "\n\n") + "\n".join(block) + "\n"
    atomic_write(path, text)


def write_readme(output_dir, input_dir, results, skipped, timeline_results=(), missing_sources=(),
                 preserved_timeline_block=None):
    """生成中文使用说明和本次运行的可核对汇总（筛选运行只汇总本次）。"""
    timeline_results = list(timeline_results)
    missing_sources = list(missing_sources)
    overview_rows = _overview_rows(results, timeline_results, missing_sources)
    md = [README_TITLE, "", *README_UPDATE_NOTES, "## 工具用途与数据来源", "",
          "将 Linux `script` 采集的终端录像批量重放为可审阅的实验过程记录。"
          "只读取原始数据，不修改、移动或删除原始文件；不直接读取 transcripts 提取 Claude QA。", "",
          "## 输入命名与结构", "",
          "默认输入为本脚本上级目录下的 `操作系统实验数据记录`，只扫描根目录的直接子目录。",
          "学生目录为 `学号-姓名-YYYYMMDD-HHMM`；也接受 `学号-姓名-实验提交-YYYYMMDD-HHMM-序号`。",
          "学号从左端匹配，日期、时间及可选重复编号从右端匹配，中间整体作为姓名（可包含连字符）。",
          "解析函数也支持同结构的 `.tar.gz` 名称；本工具不自动解压归档文件。",
          "学号、姓名和采集时间均来自学生目录名。非法日历日期或时分保留原值并标注“无法解析”。",
          "输入目录本身包含 `term/` 时作为单学生目录；名称不规范时元数据为“未知”，仍处理录像。", "",
          "```text", "操作系统实验数据记录/", "├── 2306010113-刘梓宸-20260911-2046/",
          "│   ├── logs/", "│   ├── term/", "│   │   ├── xxx.out.gz", "│   │   └── xxx.tim.gz",
          "│   └── transcripts/", "└── 2406080118-yanghanqing-20260911-0926/", "    └── term/", "```", "",
          "## 输出结构和文件含义", "",
          "默认输出为输入目录同级的 `输入目录名称-已清洗/`。单学生模式也在输出根目录下建立学生子目录。", "",
          "```text", "操作系统实验数据记录-已清洗/", "├── 按人分类/刘梓宸/lab0/实验过程清洗工具/",
          "│   ├── 终端对话记录.md", "│   ├── 完整终端转写记录.md", "│   ├── 终端命令统计.md",
          "│   ├── Claude对话记录.md", "│   ├── 实验过程时间线.json", "│   └── 实验过程时间线.md",
          "├── 按Lab分类/lab0/刘梓宸/实验过程清洗工具/", "├── 汇总报告/实验过程清洗汇总.md",
          "├── 运行日志/实验过程清洗工具.log", "└── README.md", "```", "",
          "仅为实际出现的 lab0–lab8 分类生成报告；非实验目录、无法识别目录及失败录像归入 `other`（其他）。",
          "每个分类均生成四份报告及两份时间线文件，即使某类中没有 Shell 命令或有效 Claude 对话。没有 `*.out.gz` 录像的 term 目录会记录为失败且不生成空报告。",
          "## Lab 分类原则", "",
          "只根据 Shell 提示符的工作目录匹配完整路径段，例如 `~/lab0`、`/home/user/lab1/kernel`。"
          "`lab10`、`lab0-copy` 不属于 lab0–lab8；命令参数或对话正文提到 lab 不用于分类。",
          "同一录像切换 lab 时，在下一条显示新工作目录的提示符处切分。"
          "`cd ../lab1` 命令属于执行它时所在的目录，之后的新提示符及命令归入 lab1；失败的 cd 不改变分类。",
          "Claude 对话沿用启动时所在的 Shell 工作目录；Claude 内部文本中的其他路径不会改变归属。"
          "首个提示符之前的启动内容归入首个提示符目录；完全没有可识别提示符时归入 other。",
          "跨 lab 录像的完整转写按片段保留，标明原始字节区间。每对录像数据完整重放后输出连续文本；跨 lab 时各片段独立重放并分别输出，不展开 Frame 或逐字符变化。",
          "每个分类内，同一录像的有效 Claude 问答合并为一个 Session，Turn 连续编号。"
          "学生/根目录的录像数和 Claude 会话数按原录像去重，不能直接相加各 lab 会话数；命令数和轮次可相加。", "",
          "| 文件 | 内容 |", "| --- | --- |",
          "| 终端对话记录.md | Shell 完整命令、执行目录、输出、录像编号、开始及相对时间、命令频次；每条输出最多 400 行 |",
          "| 完整终端转写记录.md | 所有录像重放后的连续文本、滚屏和清屏历史、保留下来的 TUI 界面及重放错误 |",
          "| 终端命令统计.md | 仅 Shell 命令，按次数降序、命令文本升序排列 |",
          "| Claude对话记录.md | 有效 Claude Session、编号 Turn 及用户问题与最终回答，含会话和全局统计 |",
          "| 实验过程时间线.json / 实验过程时间线.md | 按时间排序的结构化事件及阅读版时间线 |", "",
          "`终端对话记录.md` 按命令组织输出，可能截断长输出；`完整终端转写记录.md` 按录像和分类片段组织，"
          "完整重放后一次性输出文本，不执行 QA 清洗，也不添加 Frame 标题或逐行变化编号。",
          "每份学生 Markdown 的标题后均提供学号、姓名、时间、来源和录像数量。", "",
          "## Claude QA 与 Shell 统计原则", "",
          "Claude QA 只消费 pyte Screen 逐帧 diff，以 `❯` 识别用户区、`●` 识别回复区。"
          "过滤 logo、边框、spinner、thinking、工具状态、权限菜单、登录/API 错误、状态栏、快捷键、VS Code 浮层和 resume footer；"
          "合并流式增长和重复重绘，不将未完成回复计入完整轮次。",
          "一个终端录像对应一个 Claude Session；仅有启动界面或缺少完整问答的录像不计入有效会话。"
          "每个 Session 从 Turn 1 开始；总轮次等于各 Session 轮次之和。",
          "Shell 统计识别彩色及行首普通 `user@host:cwd$`/`#` 提示符，保留完整参数、选项、管道及重定向。"
          "Shell 中启动的 `claude` 会计入；Claude TUI 的 `❯` 输入不会计入。", "",
          "## 重名、覆盖和异常", "",
          "同名学生全部使用 `姓名-学号`；同一学生多次采集或其他名称冲突时再附加学号、采集标识及序号。"
          "分配目录前会检查已有结果的来源，不会把不同学生合并到同一输出目录。",
          "隐藏文件 `.replay_term_qa.json` 记录输出归属和报告阶段增量状态。默认可原子替换本工具为相同来源生成的分类报告。"
          "无归属的既有目录默认另选名称；`--overwrite` 可允许覆盖此类目录中的分类报告，仍禁止覆盖已标记为其他来源的结果。"
          "分类报告全部写入成功后，仅清理同来源归属清单中已过时的旧版报告。原始数据和其他文件不变。每个文件单独原子替换，整个学生目录不是跨文件事务。",
          "默认运行会为每位学生分别检查报告和时间线输入指纹；输入、处理器代码、登记产物及其哈希都未变化时显示“增量跳过”，并从清单恢复本次总览统计。`--force` 可忽略该判断并重建当前选中的阶段。",
          "无效学生目录会跳过；缺少、为空或为符号链接/junction 的 term 目录属于该学生的失败，不生成空报告或时间线，且不会中断其余处理。"
          "缺少、不可读、含非法值或未覆盖完整录像的 timing 文件会降级一次性重放，不记录相对时间。重放失败记录在完整转写中，全部异常还列于本页。"
          "Shell 提取失败的录像单独计数，不计入“无 Shell 命令”会话。", "",
          "## 安装和运行", "",
          "需要 Python 3.9+，依赖 `pyte` 和 `wcwidth`。本工作区使用上级 `公共依赖/pylib/` 依赖目录。", "",
          "```bash", "python3 -m pip install pyte wcwidth", 'python3 replay_term_qa.py "../操作系统实验数据记录"',
          'python3 replay_term_qa.py "../操作系统实验数据记录" --output "../操作系统实验数据记录-已清洗"',
          'python3 replay_term_qa.py "../操作系统实验数据记录" --student 2306010113',
          'python3 replay_term_qa.py "../操作系统实验数据记录" --student "刘梓宸" --overwrite',
          'python3 replay_term_qa.py "../操作系统实验数据记录" --student 2306010113 --force',
          'python3 replay_term_qa.py "../操作系统实验数据记录/2306010113-刘梓宸-20260911-2046"',
          "python3 replay_term_qa.py --help", "```", "",
          "| 参数 | 说明 |", "| --- | --- |", "| input_dir | 可选；默认本脚本上级目录的操作系统实验数据记录 |",
          "| --output / -o | 输出根目录，禁止与输入目录重叠 |", "| --student | 精确匹配学号或姓名；无匹配时参数错误 |",
          "| --overwrite | 允许覆盖无归属目录中已有的分类报告 |", "| --force | 忽略当前所选学生和阶段的增量命中，强制完整重建 |",
          "| --timeline-only | 只刷新时间线，并替换根 README 的时间线说明块 |", "| --no-timeline | 只重建四类报告，保留既有时间线产物和说明块 |", "",
          "存在学生/录像失败时退出码为 1；参数或根目录错误为 2；其余为 0。", "",
          "## 已知限制", "",
          "- script 未记录 resize ioctl 时，只能根据 TUI 边框推断宽度；多次 resize 可能影响重放。",
          "- 提示符识别支持标准彩色或行首普通 `user@host:cwd$`/`#` 形式；自定义 PS1、PowerShell 或没有目录信息的提示符可能无法识别。",
          "- TUI 格式发生较大版本变化时可能需要更新过滤规则；终端录像无法提供可靠的结构化消息边界。",
          "- 完整转写保留最终屏幕、滚屏及清屏历史；被原地重绘覆盖且未进入历史的瞬时字符（如 spinner 和流式中间状态）不单独导出。",
          "- 时间优先保留 script 头部的原始时区；学生目录采集时间本身不包含时区。", "",
          "## 本次运行汇总", "", f"- 输入目录：{markdown_text(input_dir)}",
          f"- 报告阶段学生数：{len(results)}",
          f"- 报告阶段已处理：{sum(r['status'] == '成功' for r in results)}",
          f"- 报告阶段增量跳过：{sum(r['status'] == '增量跳过' for r in results)}",
          f"- 报告阶段跳过：{sum(r['status'] == '跳过' for r in results)}",
          f"- 报告阶段失败或部分失败：{sum(r['status'] in ('失败', '部分失败') for r in results)}",
          f"- 时间线阶段学生数：{len(timeline_results)}",
          f"- 时间线阶段已处理：{sum(_timeline_stage_label(r) == '已处理' for r in timeline_results)}",
          f"- 时间线阶段增量跳过：{sum(_timeline_stage_label(r) == '增量跳过' for r in timeline_results)}",
          f"- 时间线阶段失败或部分失败：{sum(_timeline_stage_label(r) in ('失败', '部分失败') for r in timeline_results)}",
          f"- 跳过数量：{len(skipped) + sum(r['status'] == '跳过' for r in results)}"]
    for key, label in (("recordings", "终端录像数"), ("replay_failed", "重放失败数"),
                       ("commands", "Shell 命令执行总次数"), ("claude_sessions", "Claude 会话总数"),
                       ("turns", "对话轮次总数")):
        md.append(f"- {label}：{sum(r.get(key, 0) for r in results)}")
    md.extend(["", "| 学生目录 | 报告阶段 | 时间线阶段 | 录像 | 命令 | Claude 会话 | 轮次 | 输出 |",
               "| --- | --- | --- | ---: | ---: | ---: | ---: | --- |"])
    for row in overview_rows:
        info = row["info"]
        missing = row.get("missing")
        report = row.get("report")
        timeline = row.get("timeline")
        links = []
        for lab in (report or {}).get("labs", {}):
            relative = Path(info["output"].name) / lab_report_paths(lab)[0]
            links.append(f"[{lab if lab != 'other' else '其他'}]({quote(relative.as_posix())})")
        output = " / ".join(links) or "—"
        report_stage = missing["report_stage"] if missing else (
            _report_stage_label(report) if report else "未运行"
        )
        timeline_stage = missing["timeline_stage"] if missing else (
            _timeline_stage_label(timeline) if timeline else "未运行"
        )
        md.append(
            f"| {markdown_text(info.get('source_name', Path(info['source']).name))} | {report_stage} | "
            f"{timeline_stage} | {(report or {}).get('recordings', 0)} | "
            f"{(report or {}).get('commands', 0)} | {(report or {}).get('claude_sessions', 0)} | "
            f"{(report or {}).get('turns', 0)} | {output} |"
        )
    md.extend(["", "### 按实验分类汇总", "",
               "| 分类 | 录像（分类内去重） | 命令 | Claude 会话（分类内去重） | 轮次 |",
               "| --- | ---: | ---: | ---: | ---: |"])
    for lab in LAB_KEYS:
        grouped = [r["labs"][lab] for r in results if lab in r.get("labs", {})]
        if grouped:
            counts = [sum(g[key] for g in grouped) for key in ("recordings", "commands", "claude_sessions", "turns")]
            md.append(f"| {lab if lab != 'other' else '其他'} | " + " | ".join(map(str, counts)) + " |")
    md.extend(["", "### 跳过与异常详情", ""])
    md.extend(f"- {markdown_text(path)}：{markdown_text(reason)}" for path, reason in skipped)
    for r in results:
        md.extend(f"- {markdown_text(e)}" for e in r["errors"])
    if missing_sources:
        md.extend(
            f"- {markdown_text(item['info']['source_name'])}：原始提交已不存在，输出已保留"
            for item in missing_sources
        )
    if not skipped and not any(r["errors"] for r in results) and not missing_sources:
        md.append("无。")
    text = "\n".join(md) + "\n"
    if preserved_timeline_block:
        text = text.rstrip("\n") + "\n\n" + preserved_timeline_block.rstrip("\n") + "\n"
    atomic_write(output_dir / "汇总报告" / "实验过程清洗汇总.md", text)


def _main(argv=None, log_state=None):
    """批处理入口；原报告和独立时间线均按学生隔离失败。"""
    parser = argparse.ArgumentParser(description="批量重放学生 Linux script 录像，生成原有报告和实验过程时间线")
    parser.add_argument("input_dir", nargs="?", default=str(REPOSITORY_ROOT / "操作系统实验数据记录"), help="输入根目录或单学生目录")
    parser.add_argument("--output", "-o", help="输出根目录，默认输入目录同级的 输入目录名-已清洗")
    parser.add_argument("--overwrite", action="store_true", help="允许覆盖无归属输出目录中的固定程序产物，不删除其他文件")
    parser.add_argument("--student", help="只处理精确匹配的学号或姓名；无匹配时参数错误")
    parser.add_argument("--force", action="store_true", help="忽略增量命中，强制重建当前选中的阶段")
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--timeline-only", action="store_true",
                      help="只生成实验过程时间线并更新根 README 的时间线说明块，不重建原有四类报告")
    mode.add_argument("--no-timeline", action="store_true",
                      help="只生成原有四类报告，不生成实验过程时间线")
    args = parser.parse_args(argv)
    run_reports = not args.timeline_only
    run_timeline = not args.no_timeline
    report_signature = report_processor_signature() if run_reports else None
    timeline_signature = timeline_processor_signature() if run_timeline else None
    input_path = Path(args.input_dir)
    if has_link_component(input_path):
        parser.error(f"输入目录不得为符号链接或 junction：{input_path}")
    input_dir = input_path.resolve()
    output_path = Path(args.output) if args.output else input_dir.with_name(input_dir.name + "-已清洗")
    if has_link_component(output_path):
        parser.error(f"输出目录不得为符号链接或 junction：{output_path}")
    output_dir = output_path.resolve()
    if not input_dir.is_dir():
        parser.error(f"输入目录不存在：{input_dir}")
    if input_dir == output_dir or input_dir in output_dir.parents or output_dir in input_dir.parents:
        parser.error(f"输入和输出目录不得重叠：{input_dir} / {output_dir}")
    try:
        students, skipped = scan_students(input_dir, args.student)
    except (OSError, ValueError) as exc:
        parser.error(str(exc))
    selected = [s for s in students if s["selected"]]
    if args.student and not selected:
        parser.error(f"未找到匹配 --student 的学生：{args.student}")
    try:
        output_dir.mkdir(parents=True, exist_ok=True)
        readme = output_dir / "汇总报告" / "实验过程清洗汇总.md"
        if readme.exists() and not args.overwrite and not readme.read_text(encoding="utf-8").startswith(README_TITLE):
            parser.error(f"输出目录已有其他 README.md，请选择其他 --output 或显式使用 --overwrite：{readme}")
        ensure_layout(output_dir)
        if log_state is not None:
            log_state["path"] = output_dir / "运行日志" / "实验过程清洗工具.log"
        allocate_outputs(students, output_dir / "按人分类", args.overwrite)
    except (OSError, ValueError) as exc:
        parser.error(str(exc))
    preserved_timeline_block = existing_timeline_readme_block(readme) if args.no_timeline else None
    results = []
    timeline_results = []
    timeline_failed = False
    for i, info in enumerate(selected, 1):
        print(f"[学生 {i}/{len(selected)}] {info['name']}（{info['student_id']}）", flush=True)
        has_recordings = bool(term_recordings(Path(info["source"]) / "term"))
        if run_reports:
            report_snapshot = snapshot_student_inputs(info["source"])
            report_incremental = {
                "fingerprint": report_snapshot["fingerprint"],
                "processor_signature": report_signature,
            }
            result = None if args.force or not has_recordings else report_cache_hit(
                info, report_snapshot, report_signature
            )
            if result is not None:
                print("  [报告] 增量跳过（输入及产物未变）", flush=True)
            else:
                info["_report_incremental"] = report_incremental
                try:
                    if has_recordings:
                        mark_report_rebuild(info)
                    result = process_student(info, overwrite=True) if args.overwrite else process_student(info)
                except Exception as exc:
                    result = {"status": "失败", "info": info,
                              "errors": [f"{info.get('source_reference', info['source'])}：{type(exc).__name__}: {exc}"]}
                finally:
                    info.pop("_report_incremental", None)
                if not has_recordings:
                    try:
                        remove_student_reports(info)
                    except Exception as exc:
                        result.setdefault("errors", []).append(
                            f"{info.get('source_reference', info['source'])} [报告清理] {type(exc).__name__}: {exc}"
                        )
            results.append(result)
            if not result.get("cache_hit"):
                print(f"  [{result['status']}] {result.get('recordings', 0)} 个录像，"
                      f"{result.get('commands', 0)} 条 Shell 命令，{result.get('claude_sessions', 0)} 个 Claude 会话，"
                      f"{result.get('turns', 0)} 组 QA\n  输出：{info['output']}", flush=True)
            if result["status"] in ("失败", "跳过"):
                for error in result["errors"]:
                    print(f"  [{result['status']}] {error}", flush=True)
        if run_timeline:
            if not has_recordings:
                timeline_failed = True
                message = f"{info.get('source_reference', info['source'])} [时间线处理] 未发现可处理的 term/*.out.gz 录像"
                timeline_errors = [message]
                try:
                    remove_student_timeline(info)
                except Exception as exc:
                    timeline_errors.append(
                        f"{info.get('source_reference', info['source'])} [时间线清理] {type(exc).__name__}: {exc}"
                    )
                timeline_result = {"info": info, "status": "failed", "statistics": {
                    "events": 0, "absolute_time_events": 0, "relative_time_only_events": 0,
                    "missing_time_events": 0, "uncertain_events": 0, "recording_failures": 0,
                    "processing_failures": 1, "errors": len(timeline_errors),
                }, "errors": timeline_errors}
                print(f"  [时间线失败] {message}", file=sys.stderr, flush=True)
            else:
                timeline_snapshot = snapshot_student_inputs(info["source"], include_timeline_log=True)
                timeline_incremental = {
                    "fingerprint": timeline_snapshot["fingerprint"],
                    "processor_signature": timeline_signature,
                }
                timeline_result = None if args.force else timeline_cache_hit(
                    info, timeline_snapshot, timeline_signature
                )
                if timeline_result is not None:
                    print("  [时间线] 增量跳过（输入及产物未变）", flush=True)
                else:
                    try:
                        mark_timeline_rebuild(info, allow_invalid_manifest_recovery=args.force)
                        from timeline_alignment import build_student_timeline
                        aligned = build_student_timeline(info)
                        timeline_result = write_student_timeline(
                            info, aligned, incremental=timeline_incremental
                        )
                        timeline_result["info"] = info
                    except Exception as exc:
                        timeline_failed = True
                        message = f"{info.get('source_reference', info['source'])} [时间线处理] {type(exc).__name__}: {exc}"
                        timeline_result = {"info": info, "status": "failed", "statistics": {
                            "events": 0, "absolute_time_events": 0, "relative_time_only_events": 0,
                            "missing_time_events": 0, "uncertain_events": 0, "recording_failures": 0,
                            "processing_failures": 1, "errors": 1,
                        }, "errors": [message]}
                        print(f"  [时间线失败] {message}", file=sys.stderr, flush=True)
            timeline_results.append(timeline_result)
            stats = timeline_result["statistics"]
            recording_failures = stats.get("recording_failures", 0)
            processing_failures = stats.get("processing_failures", recording_failures)
            if processing_failures:
                timeline_failed = True
            if not timeline_result.get("cache_hit") and timeline_result.get("status") != "failed":
                timeline_label = "时间线部分失败" if processing_failures else "时间线成功"
                print(f"  [{timeline_label}] {stats['events']} 个事件，"
                      f"{stats['absolute_time_events']} 个有绝对时间，"
                      f"{stats['relative_time_only_events']} 个仅有相对时间，"
                      f"{stats['missing_time_events']} 个时间缺失，"
                      f"{recording_failures} 个录像处理失败，"
                      f"{stats['errors']} 个异常或不确定性提示", flush=True)
                for error in timeline_result["errors"]:
                    print(f"  [时间线提示] {error}", flush=True)
    for path, reason in skipped:
        print(f"[跳过] {path}：{reason}", flush=True)
    default_full_batch = (
        not args.student
        and not args.timeline_only
        and not args.no_timeline
        and not (input_dir / "term").is_dir()
    )
    missing_sources = (
        _missing_source_outputs(output_dir / "按人分类", [info["output"] for info in students])
        if default_full_batch else []
    )
    if run_reports:
        try:
            write_readme(
                output_dir, input_dir, results, skipped, timeline_results, missing_sources,
                preserved_timeline_block=preserved_timeline_block,
            )
            if run_timeline:
                update_readme_timeline_block(readme, timeline_results)
                update_timeline_diagnostics_block(readme, timeline_results)
        except (OSError, ValueError) as exc:
            print(f"[失败] {readme}：{exc}", file=sys.stderr)
            return 1
    elif run_timeline:
        try:
            update_readme_timeline_block(readme, timeline_results)
            update_timeline_diagnostics_block(readme, timeline_results)
        except (OSError, ValueError) as exc:
            print(f"[失败] {readme}：{exc}", file=sys.stderr)
            return 1
    if run_reports:
        print(f"报告汇总：{len(results)} 个学生，{sum(r.get('recordings', 0) for r in results)} 个录像，"
              f"{sum(r.get('commands', 0) for r in results)} 条命令，"
              f"{sum(r.get('claude_sessions', 0) for r in results)} 个 Claude 会话，"
              f"{sum(r.get('turns', 0) for r in results)} 轮对话。", flush=True)
    if run_timeline:
        print(f"时间线汇总：{len(timeline_results)} 个学生，"
              f"{sum(r.get('statistics', {}).get('events', 0) for r in timeline_results)} 个事件。", flush=True)
    report_failed = any(r["status"] in ("失败", "部分失败") for r in results)
    return int(report_failed or timeline_failed)


class _RunTee:
    def __init__(self, stream, capture):
        self.stream = stream
        self.capture = capture

    def write(self, text):
        self.capture.write(text)
        return self.stream.write(text)

    def flush(self):
        self.stream.flush()


def main(argv=None):
    """Run the batch while preserving its console output in the root run log."""
    capture, state = io.StringIO(), {}
    try:
        with redirect_stdout(_RunTee(sys.stdout, capture)), redirect_stderr(_RunTee(sys.stderr, capture)):
            return _main(argv, state)
    finally:
        if "path" in state:
            atomic_write(state["path"], capture.getvalue())


if __name__ == "__main__":
    sys.exit(main())
