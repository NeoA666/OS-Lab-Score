from pathlib import Path
p=Path('replay_term_qa.py')
s=p.read_text(encoding='utf-8')
s=s.replace('    Claude Code 用户/回复问答；原 term_qa_report.md 和 JSON 输出保持不变。','    Claude Code 用户/回复问答；支持多学生批处理及单学生目录。')
s=s.replace('import json\n', 'import json\nimport argparse\nimport tempfile\nimport hashlib\nfrom pathlib import Path\nfrom datetime import datetime\nfrom urllib.parse import quote\n')
s=s.replace('TERM_DIR = r"d:\\workspace-vscode\\实验过程记录-lab0\\term"\nOUT_DIR = os.path.dirname(os.path.abspath(__file__))\n','')
s=s.replace('start = re.search(r"Script started on ([\\d\\-+:]+)", header)', 'start = re.search(r"Script started on (.+?)(?: \\[|$)", header)')
a=s.index('def replay_full_terminal(')
b=s.index('\n\ndef append_fenced_text',a)
s=s[:a]+'''def replay_full_terminal(out_path, tim_path):
    """保留 pyte 清屏历史和逐帧变化行，包含后来被重绘覆盖的 TUI 内容。"""
    _, start, header_cols, rows, body = read_term(out_path)
    cols = infer_replay_columns(body, header_cols)
    frames = []
    for frame, elapsed, lines, changed, _, _, _ in iter_screen_diff_frames(
        out_path, tim_path, archive_clears=True
    ):
        # 变化行带行号，空白重绘也记录；不应用任何 Claude 清洗规则。
        frames.append((frame, elapsed, [(i + 1, lines[i] if i < len(lines) else "")
                                       for i in changed]))
    return {"rec": Path(out_path).name[:-len(".out.gz")], "start": start,
            "columns": cols, "rows": rows, "frames": frames}
''' +s[b:]
s=s[:s.index('def write_full_terminal_transcript(')]
p.write_text(s,encoding='utf-8')
