from pathlib import Path
p=Path('replay_term_qa.py')
s=p.read_text(encoding='utf-8')
s=s.replace('CLAUDE_STATUS_FRAGMENTS = (', '''CLAUDE_PROCESS_RE = re.compile(
    r"^(?:Thinking(?:\\s|[.…:]|$)|[✻✢✶✽·*]\\s+.+|"
    r"(?:Bash|Read|Write|Edit|MultiEdit|Glob|Grep|Search|Task|Agent|TodoWrite|"
    r"WebFetch|WebSearch|ToolSearch|Skill|NotebookEdit)\\s*\\(|"
    r"(?:Running|Searching|Reading|Writing|Editing)\\s|"
    r"Do you want to proceed\\?|Allow (?:Claude|once|always)|"
    r"(?:[❯>]\\s*)?\\d+\\.\\s+(?:Yes|No|Allow|Deny)|"
    r"Esc to cancel|Enter to confirm|Permission required|"
    r"✽|✻|✢|✶)", re.IGNORECASE
)
CLAUDE_STATUS_FRAGMENTS = (''')
s=s.replace('bool(CLAUDE_SPINNER_RE.search(stripped))', 'bool(CLAUDE_PROCESS_RE.search(without_bullet))\n        or bool(CLAUDE_SPINNER_RE.search(stripped))')
# 权限菜单也可能以 ❯ 开头，禁止进入用户问题。
s=s.replace('if role == "claude" and is_claude_ui_noise(marker_text):', 'if is_claude_ui_noise(marker_text):')
# 补充完成判定仍只依赖 pyte 的屏幕，不使用原始 transcript。
pos=s.index('def extract_claude_session(')
s=s[:pos]+'''def claude_frame_ready(screen_lines):
    """只在输入区恢复待命且没有执行中状态时，将最后一轮视为完成。"""
    # 历史中可含旧 spinner；只检查最后一个回复标记以后的界面。
    last_answer = max((i for i, line in enumerate(screen_lines)
                       if line.startswith("●") and not is_claude_ui_noise(line.lstrip("● "))), default=-1)
    if last_answer < 0:
        return False
    tail = screen_lines[last_answer + 1:]
    busy = any("esc to interrupt" in line.lower()
               or CLAUDE_ANIMATED_STATUS_RE.search(line.strip()) for line in tail)
    ready = any(line.strip() == "❯" or line.strip().startswith("Resume this session with:")
                or re.match(r"^[^\\s@]+@[^:]+:.*[$#] ?", line) for line in tail)
    return ready and not busy


''' +s[pos:]
s=s.replace('for observation in observations:', 'for observation_index, observation in enumerate(observations):\n            completed = observation_index < len(observations) - 1 or claude_frame_ready(screen_lines)')
s=s.replace('"last_seen": frame_no,', '"last_seen": frame_no,\n                    "completed": completed,')
s=s.replace('record["last_seen"] = frame_no', 'record["last_seen"] = frame_no\n                record["completed"] = completed')
s=s.replace('if r["user"] and r["claude"]]', 'if r["user"] and r["claude"] and r["completed"]]')
p.write_text(s,encoding='utf-8')
