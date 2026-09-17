# 实验过程清洗工具

将学生 Linux `script` 终端录像重放为可审阅的实验过程数据。工具读取原始录像，提取 Shell 命令、终端转写和 Claude Code 问答，并按 `lab0` 至 `lab8` 分类生成 Markdown 报告与实验过程时间线。

## 功能

- 重放 `term/*.out.gz` 和对应的 `*.tim.gz`，处理 ANSI 控制序列、退格、清屏和自动换行；识别 English/中文 script 头和无头录像。
- 生成四类按实验分类的报告：终端对话记录、完整终端转写记录、终端命令统计和 Claude 对话。
- 根据彩色或行首普通 `user@host:cwd$`/`#` 提示符中的工作目录识别实验分类；无法识别目录、非 `lab0` 至 `lab8` 的记录和读取失败的录像归入 `other`。
- 生成包含 JSON 和 Markdown 的实验过程时间线；可再生成面向阅读的简洁时间线。
- 为每个学生记录归属与增量状态。输入、处理器和已登记产物均未变化时，默认跳过不需要重建的阶段；`--force` 可强制重建。
- 原始录像不被修改，也不会执行学生提交的命令或代码。

## 输入约定

批处理输入根目录通常为上级的 `操作系统实验数据记录/`。省略 `input_dir` 时，默认使用脚本上级目录下的该目录。每个学生目录名称应符合以下形式：

```text
<学号>-<姓名>-YYYYMMDD-HHMM/
├── term/
│   ├── <录像>.out.gz
│   └── <录像>.tim.gz
└── logs/
    └── events.jsonl
```

- `term/` 中至少一个常规 `*.out.gz` 是必需的终端录像数据；缺失、为空、符号链接或 Windows junction 都会以学生级失败退出，不创建空报告或空时间线。
- 同名 `*.tim.gz` 为可选计时文件。缺失、不可读、格式错误、负值、非有限值或未覆盖完整录像时会降级为一次性重放，并把报告和时间线的相对时间标为未知。
- `logs/events.jsonl` 是时间线阶段的可选补充输入。
- 学生目录可使用 `-实验提交` 后缀或重复编号；不符合命名规则的目录会记录为跳过项。

## 输出结构

默认输出在输入目录同级，目录名为 `<输入目录名>-已清洗/`。以 `操作系统实验数据记录-已清洗/` 为例：

```text
操作系统实验数据记录-已清洗/
├── README.md
└── <学生>/
    ├── 终端对话记录/terminal_qa_report_labN.md
    ├── 完整终端转写记录/full_terminal_transcript_labN.md
    ├── 终端命令统计/command_statistics_labN.md
    ├── claude对话/claude_qa_clean_labN.md
    ├── 实验过程时间线/timeline_labN.json
    ├── 实验过程时间线/timeline_labN.md
    ├── 简洁实验过程时间线/timeline_labN.md
    └── .replay_term_qa.json
```

只会为实际出现的实验分类创建文件。无法分类的数据使用对应的 `_other` 文件名。`简洁实验过程时间线/` 由下文的辅助命令单独生成。

## 环境准备

需要 Python 3.9+、`pyte` 和 `wcwidth`。本仓库会优先使用 `公共依赖/pylib/` 中的依赖；独立使用时可安装：

```bash
python -m pip install pyte wcwidth
```

在本目录执行以下命令。Windows 可使用 `python`，其他环境可按本机配置使用 `python3`。

## 常用命令

完整批处理并显式指定输出目录：

```bash
python -B replay_term_qa.py "../操作系统实验数据记录" --output "../操作系统实验数据记录-已清洗"
```

仅处理一名学生，学号或姓名必须精确匹配：

```bash
python -B replay_term_qa.py "../操作系统实验数据记录" --student 2406080102
python -B replay_term_qa.py "../操作系统实验数据记录" --student "戴炜"
```

强制重建当前选中学生的报告和时间线：

```bash
python -B replay_term_qa.py "../操作系统实验数据记录" --output "../操作系统实验数据记录-已清洗" --force
```

只刷新实验过程时间线，或只重建四类终端报告：

```bash
python -B replay_term_qa.py "../操作系统实验数据记录" --output "../操作系统实验数据记录-已清洗" --timeline-only
python -B replay_term_qa.py "../操作系统实验数据记录" --output "../操作系统实验数据记录-已清洗" --no-timeline
```

`--overwrite` 仅允许覆盖没有本工具归属信息的输出目录中的固定程序产物；它不会删除其他文件，也不会覆盖已归属给其他原始提交的结果。输入、输出和产物路径中的符号链接或 Windows junction 会被拒绝。

`--timeline-only` 只刷新时间线并替换根 `README.md` 中的时间线说明块，不重建四类终端报告。`--no-timeline` 只重建四类报告，保留已有时间线产物和该说明块。

## 简洁时间线

`generate_readable_timeline.py` 从已有的 `实验过程时间线/timeline_*.json` 提取时间、类型和内容，生成更适合人工阅读的 Markdown。先完成主清洗命令，再执行：

```bash
python -B generate_readable_timeline.py "../操作系统实验数据记录-已清洗"
python -B generate_readable_timeline.py "../操作系统实验数据记录-已清洗" --student "戴炜"
```

`--student` 在此处匹配已清洗输出目录名，可重复指定。

简洁时间线清单仅登记该工具写入的 `timeline_*.md`。对应 JSON 在后续运行中消失时，工具会删除清单中同名的旧 Markdown，不会触碰其他文件。

## 增量、异常与安全性

主工具会针对每名学生分别计算输入指纹，并校验登记产物的 SHA-256。修改或新增录像、修改处理器、删除或篡改产物都会重建对应阶段；仅修改 `logs/events.jsonl` 时只会重建时间线。缺少、为空或为链接的 `term/`、损坏录像或单个时间线处理错误都会记录为该学生失败，不会中断其他学生，根目录 `README.md` 会列出失败原因且不创建空学生产物。存在学生或录像失败时命令退出码为 `1`；无匹配的 `--student` 为参数错误并返回 `2`。

输出文件通过临时文件原子替换，工具会拒绝向符号链接或 Windows junction 写入。清理过时产物时仅处理归属清单中登记的本工具文件，原始数据及其他文件保持不变。

## 验证

在本目录运行完整测试集：

```bash
python -B -m unittest -v test_replay_term_qa test_timeline test_timeline_alignment test_timeline_reports test_generate_readable_timeline test_incremental_processing
```
