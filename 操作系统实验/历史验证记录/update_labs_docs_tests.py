from pathlib import Path
p=Path('replay_term_qa.py')
s=p.read_text(encoding='utf-8')
s=s.replace('          *[f"    {\'└──\' if i == 3 else \'├──\'} {name}" for i, name in enumerate(REPORT_NAMES)], "```", "",', '''          "    ├── 终端对话记录/", "    │   ├── terminal_qa_report_lab0.md", "    │   └── terminal_qa_report_other.md",
          "    ├── 完整终端转写记录/", "    │   ├── full_terminal_transcript_lab0.md", "    │   └── full_terminal_transcript_other.md",
          "    ├── 终端命令统计/", "    │   ├── command_statistics_lab0.md", "    │   └── command_statistics_other.md",
          "    └── claude对话/", "        ├── claude_qa_clean_lab0.md", "        ├── claude_qa_clean_lab1.md",
          "        └── claude_qa_clean_other.md", "```", "",
          "仅为实际出现的 lab0–lab8 分类生成报告；非实验目录、无法识别目录及失败录像归入 `other`（其他）。",
          "每个分类均生成四份报告，即使某类中没有 Shell 命令或有效 Claude 对话。空学生目录生成 other 四份空报告。",
          "## Lab 分类原则", "",
          "只根据 Shell 提示符的工作目录匹配完整路径段，例如 `~/lab0`、`/home/user/lab1/kernel`。"
          "`lab10`、`lab0-copy` 不属于 lab0–lab8；命令参数或对话正文提到 lab 不用于分类。",
          "同一录像切换 lab 时，在下一条显示新工作目录的提示符处切分。"
          "`cd ../lab1` 命令属于执行它时所在的目录，之后的新提示符及命令归入 lab1；失败的 cd 不改变分类。",
          "Claude 对话沿用启动时所在的 Shell 工作目录；Claude 内部文本中的其他路径不会改变归属。"
          "首个提示符之前的启动内容归入首个提示符目录；完全没有可识别提示符时归入 other。",
          "跨 lab 录像的完整转写按片段保留，标明原始字节区间和累计时间。各片段独立重放以免混入其他 lab 的屏幕历史。",
          "每个分类内，同一录像的有效 Claude 问答合并为一个 Session，Turn 连续编号。"
          "学生/根目录的录像数和 Claude 会话数按原录像去重，不能直接相加各 lab 会话数；命令数和轮次可相加。", "",''')
for stem in ('terminal_qa_report','full_terminal_transcript','command_statistics','claude_qa_clean'):
    s=s.replace(f'| {stem}.md |', f'| {stem}_labN.md / {stem}_other.md |')
s=s.replace('`terminal_qa_report.md` 按命令组织输出', '`terminal_qa_report_labN.md` 按命令组织输出')
s=s.replace('`full_terminal_transcript.md` 按录像和帧组织', '`full_terminal_transcript_labN.md` 按录像和帧组织')
s=s.replace('相同来源生成的四份报告', '相同来源生成的分类报告')
s=s.replace('此类目录中的四个固定文件', '此类目录中的分类报告')
s=s.replace('无归属目录中已有的固定报告', '无归属目录中已有的分类报告')
s=s.replace('"不清理旧文件或原始数据。每个文件单独原子替换，整个学生目录不是跨文件事务。",', '"分类报告全部写入成功后，仅清理同来源归属清单中已过时的旧版报告。原始数据和其他文件不变。每个文件单独原子替换，整个学生目录不是跨文件事务。",')
s=s.replace('        link = quote(info["output"].name) + "/terminal_qa_report.md"\n        output = f"[查看报告]({link})" if "recordings" in r else "—"', '''        links = []
        for lab in r.get("labs", {}):
            relative = Path(info["output"].name) / lab_report_paths(lab)[0]
            links.append(f"[{lab if lab != 'other' else '其他'}]({quote(relative.as_posix())})")
        output = " / ".join(links) or "—"''')
s=s.replace('    md.extend(["", "### 跳过与异常详情", ""])', '''    md.extend(["", "### 按实验分类汇总", "",
               "| 分类 | 录像（分类内去重） | 命令 | Claude 会话（分类内去重） | 轮次 |",
               "| --- | ---: | ---: | ---: | ---: |"])
    for lab in LAB_KEYS:
        grouped = [r["labs"][lab] for r in results if lab in r.get("labs", {})]
        if grouped:
            counts = [sum(g[key] for g in grouped) for key in ("recordings", "commands", "claude_sessions", "turns")]
            md.append(f"| {lab if lab != 'other' else '其他'} | " + " | ".join(map(str, counts)) + " |")
    md.extend(["", "### 跳过与异常详情", ""])''')
p.write_text(s,encoding='utf-8')
p=Path('test_replay_term_qa.py')
s=p.read_text(encoding='utf-8')
s=s.replace('for filename in app.REPORT_NAMES:', 'for filename in app.lab_report_paths("lab0"):')
s=s.replace("output / name / filename", "output / name / filename")
s=s.replace("output / '张伟-123' / 'full_terminal_transcript.md'", "output / '张伟-123' / app.lab_report_paths('other')[1]")
s=s.replace("self.assertIn('- 成功重放数量：1', full)","self.assertIn('- 重放失败数量：1', full)")
s=s.replace("output / '张伟-456' / 'claude_qa_clean.md'", "output / '张伟-456' / app.lab_report_paths('lab0')[3]")
s=s.replace("output / '未知' / app.REPORT_NAMES[0]", "output / '未知' / app.lab_report_paths('lab0')[0]")
s=s.replace("output / 'B' / 'claude_qa_clean.md'", "output / 'B' / app.lab_report_paths('lab0')[3]")
p.write_text(s,encoding='utf-8')
