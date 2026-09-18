# 教师贡献复核报告

- 学号：未知
- 学生目录：杨涵清
- 实验：lab0
- 分析状态：complete

## 自动结论

- 总体画像：人工贡献为主
- 画像置信度：强
- 自动摘要：The lab0 process timeline and terminal Q&A demonstrate the student independently performing command‑line operations to set up, run, debug, and clean the lab environment. No observable AI contribution is present.
- 证据 `source:lab0:timeline`：`简洁实验过程时间线/timeline_lab0.md`；SHA-256 `7b65d8b35aca2a4e768b1874734a3b3ca43eb38a90f6ca90dd38b3b79c4963b0`；第 16-200 行
  - 脱敏短摘录：make run  [终端输出] make: 警告：文件“target/kernel”的修改时间在未来 27355 秒后 qemu-system-riscv64: -drive file=fs.img,if=none,format=raw,id=x0: Could not open 'fs.img': No such file or directory make: *** [Makefile:152：run] 错误 1 ```  ### 录像时间：2026-09-03T17:32:38.616+08:00（北京时间）  - 录像类型：Shell 命令…
- 证据 `source:lab0:terminal_qa`：`终端对话记录/terminal_qa_report_lab0.md`；SHA-256 `57d7571f01ba508f51f49311841c1aad3f3e5c459014a4909c8c54054723e9b2`；第 28-200 行
  - 脱敏短摘录：**Q（命令）：**  ```text make run ```  **A（输出）：**  ```text make: 警告：文件“target/kernel”的修改时间在未来 27355 秒后 qemu-system-riscv64: -drive file=fs.img,if=none,format=raw,id=x0: Could not open 'fs.img': No such file or directory make: *** [Makefile:152：run] 错误 1 ```  ### 问答 2 · 录像 20260903T17…
- 替代解释：It remains possible that the student used AI tools for command suggestions or troubleshooting outside the recorded sessions, but the logs do not contain any explicit AI-generated content.
- 实验级局限：Only terminal interactions are recorded; any off‑screen AI usage cannot be detected.；The logs do not capture the student's decision‑making process, so indirect AI influence cannot be ruled out.；Repeated command attempts could reflect trial‑and‑error learning or AI‑guided hints; we cannot distinguish between them.

该结果由 NIM 主分析和独立 NIM 复核产生，且仅作为补充证据材料。它不认定真实作者、手打或复制粘贴行为，也不输出诚信结论或分数。

## 教师下一步

- 按需要回到 source_id、路径、哈希与行范围复核关键证据。

## 资料覆盖

- 资料覆盖：complete
- `source:lab0:timeline`（timeline）：available；`简洁实验过程时间线/timeline_lab0.md`；SHA-256 `7b65d8b35aca2a4e768b1874734a3b3ca43eb38a90f6ca90dd38b3b79c4963b0`；3878 行
- `source:lab0:terminal_qa`（terminal_qa）：available；`终端对话记录/terminal_qa_report_lab0.md`；SHA-256 `57d7571f01ba508f51f49311841c1aad3f3e5c459014a4909c8c54054723e9b2`；3680 行
- `source:lab0:command_statistics`（command_statistics）：available；`终端命令统计/command_statistics_lab0.md`；SHA-256 `c81ed1b2e1d908a3cdc50b1b35348877c94c737816bc5cee18d4fc323e3b2ff1`；33 行
- `source:lab0:diff_report`（diff_report）：not_applicable；`未提供路径`；SHA-256 `未提供哈希`；未知 行；原因：lab0 的贡献识别仅评估实验过程材料，不使用代码差异报告

## 关键贡献项

### 1. 人工贡献为主

- 单元 ID：`proc0`
- 类型：process_segment
- 置信度：强
- 可观察角色：人工：人工提问、人工执行命令、人工调试、人工验证
- 摘要：The student executed a sequence of shell commands to build and run the lab0 environment, encountered missing filesystem image errors, attempted to run make run, corrected typos, retried, observed QEMU boot output, tried debugging with make gdb (encountering lock issues), then made a filesystem with make fs and cleaned with make clean. All actions were visibly performed by the student with no indication of AI involvement in the logs.
- 替代解释：Although the logs show only student-typed commands, it is possible that the student used AI assistance (e.g., for command suggestions) outside the captured terminal sessions, but no direct evidence of such use appears in the provided materials.
- 过程范围：`source:lab0:timeline` 第 16-200 行
- 证据 `source:lab0:timeline`：`简洁实验过程时间线/timeline_lab0.md`；SHA-256 `7b65d8b35aca2a4e768b1874734a3b3ca43eb38a90f6ca90dd38b3b79c4963b0`；第 16-22 行
  - 脱敏短摘录：make run  [终端输出] make: 警告：文件“target/kernel”的修改时间在未来 27355 秒后 qemu-system-riscv64: -drive file=fs.img,if=none,format=raw,id=x0: Could not open 'fs.img': No such file or directory make: *** [Makefile:152：run] 错误 1 ```
- 证据 `source:lab0:timeline`：`简洁实验过程时间线/timeline_lab0.md`；SHA-256 `7b65d8b35aca2a4e768b1874734a3b3ca43eb38a90f6ca90dd38b3b79c4963b0`；第 30-35 行
  - 脱敏短摘录：```text make ru  [终端输出] make: *** 没有规则可制作目标“ru”。 停止。 ```
- 其余 10 条证据仅保留在 JSON assessment 中。

## 代码变化与复核

- 复核状态：NIM 主分析与独立 NIM 复核一致
- 复核总体决策：agree
- 复核摘要：The lab0 process timeline demonstrates the student independently performing command-line operations to set up, run, debug, and clean the environment. No observable AI contribution is present, supporting the human_dominant label.
- 已复核单元：proc0
- 存在分歧的单元：无

## 局限与追溯

- The analysis is limited to the provided timeline and terminal Q&A; other potential sources (e.g., editor logs, AI assistant transcripts) are not available.
- We cannot assess the correctness or completeness of the student's understanding, only the observable command sequence.
- 该结果是课程贡献归属线索，不认定真实作者、手打或粘贴方式、理解程度、诚信、违规或分数。
- Schema：`ai-human-contribution-assessment/v3`
- tool_version：3.1.1
- prompt_version：contribution-attribution-v3-nim-semantic-primary-v2
- validator_version：contribution-assessment-validator-v4
- completed_at：2026-09-18T11:47:05.359659+00:00
- 报告模板版本：6
