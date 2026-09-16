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
    Claude Code 用户/回复问答；原 term_qa_report.md 和 JSON 输出保持不变。
"""
import os
import re
import sys
import json
import gzip
from collections import Counter

PYLIB = os.path.join(os.path.dirname(os.path.abspath(__file__)), "pylib")
if os.path.isdir(PYLIB):
    sys.path.insert(0, PYLIB)

from pyte import ByteStream                      # noqa: E402
from pyte.screens import Screen                  # noqa: E402
from wcwidth import wcwidth                      # noqa: E402

TERM_DIR = r"d:\workspace-vscode\实验过程记录-lab0\term"
OUT_DIR = os.path.dirname(os.path.abspath(__file__))

# Bash 提示符在原始流中的形态（user@host 用绿色，路径用蓝色，`$`/`#` 结束）。
# 例： ESC[01;32mailab-os@ailab-os-...ESC[00m:ESC[01;34m~/桌面/...ESC[00m$
SGR = rb"\x1b\[[0-9;]*m"
PROMPT_RAW = re.compile(
    SGR + rb"(?P<uh>ailab-os@ailab-os-VMware-Virtual-Platform)" + SGR + rb":"
    + SGR + rb"(?P<cwd>.*?)" + SGR + rb"(?P<mark>[$#]) "
)

PASTE_MARKERS = (b"\x1b[200~", b"\x1b[201~")   # 括号粘贴起止标记，无视觉含义
MAX_OUTPUT_LINES = 400                          # 每条命令输出在报告中最多保留的行数

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
        if out and len(out[-1]) == cols:
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


def read_term(out_path):
    with gzip.open(out_path, "rb") as f:
        raw = f.read()
    nl = raw.index(b"\n")
    header = raw[:nl].decode("utf-8", "replace")
    body = raw[nl + 1:]
    start = re.search(r"Script started on ([\d\-+:]+)", header)
    cols = int(re.search(r'COLUMNS="(\d+)"', header).group(1)) if re.search(r'COLUMNS="(\d+)"', header) else 198
    rows = int(re.search(r'LINES="(\d+)"', header).group(1)) if re.search(r'LINES="(\d+)"', header) else 59
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


def read_timing_entries(tim_path):
    """读取 script 的 timing 条目；失败时由调用方退化为一次性重放。"""
    if not (tim_path and os.path.exists(tim_path)):
        return []
    try:
        with gzip.open(tim_path, "rt", encoding="utf-8", errors="replace") as f:
            entries = []
            for line in f:
                parts = line.split()
                if len(parts) == 2:
                    delay, size = float(parts[0]), int(parts[1])
                    if size > 0:
                        entries.append((delay, size))
            return entries
    except Exception:
        return []


def iter_screen_diff_frames(out_path, tim_path, archive_clears=False):
    """按 .tim 分帧重放，并产出 pyte Screen 状态及相对上一帧的变化行。

    Claude QA 识别只消费这里的 Screen 结果，不消费未经终端语义解析的 transcript。
    """
    _, start, header_cols, rows, body = read_term(out_path)
    cols = infer_replay_columns(body, header_cols)
    entries = read_timing_entries(tim_path) or [(0.0, len(body))]

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


def build_time_map(tim_path, body_len):
    """根据 .tim 建立「累计字节数 -> 累计秒」的映射，返回按字节升序的两个数组。"""
    if not (tim_path and os.path.exists(tim_path)):
        return None
    try:
        with gzip.open(tim_path, "rb") as f:
            entries = []
            for ln in f.read().decode("utf-8", "replace").splitlines():
                parts = ln.split()
                if len(parts) == 2:
                    entries.append((float(parts[0]), int(parts[1])))
    except Exception:
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
    import bisect
    if not time_map:
        return None
    cum_b, cum_t = time_map
    i = bisect.bisect_left(cum_b, offset)
    if i >= len(cum_t):
        return cum_t[-1]
    return cum_t[i]


def extract_session(out_path, tim_path):
    rec_id = os.path.basename(out_path)[:-len(".out.gz")]
    header, start, cols, rows, body = read_term(out_path)

    # 去掉括号粘贴标记，避免其参与正文
    for mk in PASTE_MARKERS:
        body = body.replace(mk, b"")

    time_map = build_time_map(tim_path, len(body))

    matches = list(PROMPT_RAW.finditer(body))
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
        elapsed = time_at(time_map, m.start())
        commands.append({
            "rec": rec_id,
            "seq": None,  # 稍后补序号
            "cwd": cwd,
            "command": cmd,
            "output": out_lines,
            "elapsed": round(elapsed, 1) if elapsed is not None else None,
            "start": start,
        })

    for seq, c in enumerate(commands, 1):
        c["seq"] = seq
    return rec_id, start, commands


def is_claude_ui_terminator(line):
    """会终止消息正文的 TUI 状态行（其后通常是另一块界面）。"""
    stripped = line.replace("\u00a0", " ").strip()
    without_bullet = stripped.lstrip("● ")
    return (
        bool(CLAUDE_SPINNER_RE.search(stripped))
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
            if role == "claude" and is_claude_ui_noise(marker_text):
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


def extract_claude_session(out_path, tim_path):
    """通过逐帧 Screen diff 提取并去重一个 Claude Code 会话。"""
    rec_id = os.path.basename(out_path)[:-len(".out.gz")]
    records = []
    active = []
    next_id = 0

    for frame_no, _, screen_lines, changed_rows, _, _, _ in iter_screen_diff_frames(out_path, tim_path):
        if not changed_rows:
            continue
        observations = frame_qa_pairs(screen_lines)
        current = []
        used_ids = set()

        for observation in observations:
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
                })
            else:
                record = records[matched_id]
                record["claude"] = merge_streamed_answer(record["claude"], observation["claude"])
                record["last_seen"] = frame_no

            used_ids.add(matched_id)
            current.append({"id": matched_id})
        active = current

    pairs = [{"user": r["user"], "claude": r["claude"]} for r in records
             if r["user"] and r["claude"]]
    return rec_id, pairs


def replay_full_terminal(out_path, tim_path):
    """返回完整的 pyte 重放结果；不执行任何 Claude/命令过滤。"""
    rec_id = os.path.basename(out_path)[:-len(".out.gz")]
    final_lines = ()
    start = ""
    cols = rows = 0
    for _, _, screen_lines, _, start, cols, rows in iter_screen_diff_frames(
        out_path, tim_path, archive_clears=True
    ):
        final_lines = screen_lines

    # 去掉 Screen 固定高度带来的末尾填充行；内部空行和所有可见内容原样保留。
    final_lines = list(final_lines)
    while final_lines and not final_lines[-1]:
        final_lines.pop()
    return {
        "rec": rec_id,
        "start": start,
        "columns": cols,
        "rows": rows,
        "lines": final_lines,
    }


def append_fenced_text(md, lines):
    """以不会与终端内容冲突的 Markdown fence 写入原样文本。"""
    text = "\n".join(lines)
    longest = max((len(m.group(0)) for m in re.finditer(r"`+", text)), default=0)
    fence = "`" * max(3, longest + 1)
    md.append(fence + "text")
    md.extend(lines)
    md.append(fence)


def write_full_terminal_transcript(sessions):
    md = [
        "# Full Terminal Transcript",
        "",
        "由 `pyte` 按终端控制序列完整重放；未过滤 shell、Claude Code、普通输出或 TUI 内容。",
        "",
    ]
    for session in sessions:
        md.append(f"## Session {session['rec']}")
        md.append("")
        md.append(
            f"Start: `{session['start'] or '-'}` · "
            f"Screen: `{session['columns']}x{session['rows']}`"
        )
        md.append("")
        append_fenced_text(md, session["lines"])
        md.append("")

    path = os.path.join(OUT_DIR, "full_terminal_transcript.md")
    with open(path, "w", encoding="utf-8") as f:
        f.write("\n".join(md))
    return path


def write_command_statistics(counter):
    md = [
        "# Terminal Command Statistics",
        "",
        "| command | count |",
        "| --- | ---: |",
    ]
    for command, count in counter.most_common():
        safe = command.replace("\\", "\\\\").replace("|", "\\|")
        md.append(f"| {safe} | {count} |")
    md.append("")

    path = os.path.join(OUT_DIR, "command_statistics.md")
    with open(path, "w", encoding="utf-8") as f:
        f.write("\n".join(md))
    return path


def write_claude_qa_clean(sessions):
    md = ["# Claude Code QA (Clean)", ""]
    for session in sessions:
        if not session["pairs"]:
            continue
        md.append(f"## Session {session['rec']}")
        md.append("")
        for pair in session["pairs"]:
            md.append("### User")
            md.append("")
            md.append(pair["user"])
            md.append("")
            md.append("### Claude")
            md.append("")
            md.append(pair["claude"])
            md.append("")

    path = os.path.join(OUT_DIR, "claude_qa_clean.md")
    with open(path, "w", encoding="utf-8") as f:
        f.write("\n".join(md))
    return path


def main():
    out_files = sorted(p for p in os.listdir(TERM_DIR) if p.endswith(".out.gz"))

    all_qa = []
    counter = Counter()
    full_sessions = []
    claude_sessions = []
    for out_name in out_files:
        out_path = os.path.join(TERM_DIR, out_name)
        tim_path = out_path[:-len(".out.gz")] + ".tim.gz"

        # 新增报告各自独立；即使某一种提取失败，也不影响原 term_qa_report。
        try:
            full_sessions.append(replay_full_terminal(out_path, tim_path))
        except Exception as e:
            print(f"[完整转写跳过] {out_name}: {e}", file=sys.stderr)
        try:
            claude_rec_id, pairs = extract_claude_session(out_path, tim_path)
            claude_sessions.append({"rec": claude_rec_id, "pairs": pairs})
        except Exception as e:
            print(f"[Claude QA 跳过] {out_name}: {e}", file=sys.stderr)

        try:
            rec_id, start, commands = extract_session(out_path, tim_path)
        except Exception as e:
            print(f"[跳过] {out_name}: {e}", file=sys.stderr)
            continue
        for c in commands:
            counter[c["command"]] += 1
            all_qa.append(c)
        status = f"{len(commands)} 条命令" if commands else "无命令"
        print(f"[ok] {out_name} @ {start}: {status}")

    # 输出问答对 + 命令频次
    md = []
    md.append("# 终端会话问答对与命令频次报告")
    md.append("")
    md.append("使用 `pyte` 精确重放 `term/*.out.gz + *.tim.gz` 生成。"
              "**Q** 为提示符下输入的完整终端命令，**A** 为该命令的输出。")
    md.append("")
    md.append(f"- 分析录像文件数：{len(out_files)}")
    md.append(f"- 识别命令问答对总数：{len(all_qa)}")
    md.append(f"- 去重后不同命令数：{len(counter)}")
    md.append("")

    md.append("## 一、问答对集合")
    md.append("")
    for c in all_qa:
        elapsed = f"{c['elapsed']}s" if c["elapsed"] is not None else "-"
        md.append(f"### 问答 {c['seq']} · 录像 {c['rec']} · 开始 {c['start']} · +{elapsed} · 目录 `{c['cwd']}`")
        md.append("")
        md.append(f"**Q（命令）：** `{c['command']}`")
        md.append("")
        if c["output"]:
            shown = c["output"][:MAX_OUTPUT_LINES]
            truncated = len(c["output"]) > len(shown)
            md.append("**A（输出）：**")
            md.append("")
            md.append("```text")
            md.extend(shown)
            if truncated:
                md.append(f"... （其余 {len(c['output']) - len(shown)} 行已省略）")
            md.append("```")
        else:
            md.append("**A（输出）：** （无输出）")
        md.append("")

    md.append("## 二、终端命令频次（去重，按执行次数降序）")
    md.append("")
    md.append("| 次数 | 命令 |")
    md.append("| ---: | --- |")
    for cmd, cnt in counter.most_common():
        safe = cmd.replace("|", "\\|")
        md.append(f"| {cnt} | `{safe}` |")
    md.append("")

    report_path = os.path.join(OUT_DIR, "term_qa_report.md")
    with open(report_path, "w", encoding="utf-8") as f:
        f.write("\n".join(md))

    json_path = os.path.join(OUT_DIR, "term_qa_report.json")
    json_out = {
        "qa_pairs": [
            {
                "rec": c["rec"],
                "seq": c["seq"],
                "start": c["start"],
                "elapsed_seconds": c["elapsed"],
                "cwd": c["cwd"],
                "question": c["command"],
                "answer_lines": c["output"][:MAX_OUTPUT_LINES],
                "answer_truncated": len(c["output"]) > MAX_OUTPUT_LINES,
            }
            for c in all_qa
        ],
        "command_frequency": [
            {"command": cmd, "count": cnt} for cmd, cnt in counter.most_common()
        ],
    }
    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(json_out, f, ensure_ascii=False, indent=2)

    full_path = write_full_terminal_transcript(full_sessions)
    statistics_path = write_command_statistics(counter)
    claude_path = write_claude_qa_clean(claude_sessions)

    print(f"\n报告已生成：{report_path}")
    print(f"JSON 已生成：{json_path}")
    print(f"完整终端转写已生成：{full_path}")
    print(f"命令统计已生成：{statistics_path}")
    print(f"Claude QA 已生成：{claude_path}")
    print("\n命令频次：")
    for cmd, cnt in counter.most_common():
        print(f"  {cnt:3d}  {cmd}")


if __name__ == "__main__":
    main()
