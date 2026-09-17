# 终端实验数据批处理说明

## 本次功能更新：按 Lab 分类

- 支持 lab0–lab8，并在每名学生目录下建立 `终端对话记录/`、`完整终端转写记录/`、`终端命令统计/`、`claude对话/` 四个子目录。
- 四类文件分别使用 `terminal_qa_report_labN.md`、`full_terminal_transcript_labN.md`、`command_statistics_labN.md`、`claude_qa_clean_labN.md`；`labN` 为实际识别到的实验目录。
- 不在 lab0–lab8 下、目录无法识别或录像读取失败的记录，归入对应的四份 `_other.md` 文件。只为实际出现的分类生成文件，不预建没有数据的 lab。
- 分类依据是 Shell 提示符中的工作目录，支持 lab 的子目录。正文、命令参数或 Claude 回复中提到其他 lab，不改变分类。
- 同一录像切换 lab 时按新提示符分段；`cd` 命令归入执行它时所在的目录，后续提示符显示目录变化后才切换分类，失败的 `cd` 不切换。
- Claude 问答按启动所在目录归类；返回同一 lab 后，同一录像的问答合并为一个 Session，Turn 连续编号。完整转写保留片段编号和原始字节区间，每个录像片段输出一次连续文本。
- 保留原有 Shell 提取、Claude Screen/diff 提取及 pyte 重放核心。各分类的命令数和轮次可以相加；跨分类录像及 Claude 会话在学生总计中按原录像去重。
- 全部分类报告写入成功后，按同来源归属清单移除过时的程序报告；保留其他文件，不修改原始实验数据。

### 验证记录与复查方法

2026-09-12 的分类版本验证已通过 Python 语法检查和 18 项测试，覆盖跨 lab 切换、返回同一 lab、子目录识别、失败的 cd、缺失计时文件、异常隔离及旧版报告迁移。

该次完整批处理处理了 12 名学生、134 个录像，得到 262 次 Shell 命令执行、8 个有效 Claude 会话、35 轮对话；133 个录像重放成功，1 个录像缺少有效头部。分类前后命令和问答无遗漏、无重复；11,576 个原始文件的路径、大小、修改时间和 SHA-256 校验一致。此处为该次验证记录，不代表之后每次运行的结果；最近一批结果见文末汇总。

从脚本所在目录复查：

```bash
python3 -m py_compile replay_term_qa.py
python3 -m unittest -v test_replay_term_qa
python3 replay_term_qa.py "../操作系统实验数据记录" --output "../操作系统实验数据记录-已清洗"
```

以上批处理命令显式指定工作区中的输出目录；省略 `--output` 时仍按输入目录同级的默认规则输出。

## 工具用途与数据来源

将 Linux `script` 采集的终端录像批量重放为可审阅的实验过程记录。只读取原始数据，不修改、移动或删除原始文件；不直接读取 transcripts 提取 Claude QA。

## 输入命名与结构

默认输入为当前目录的 `操作系统实验数据记录`，只扫描根目录的直接子目录。
学生目录为 `学号-姓名-YYYYMMDD-HHMM`；也接受 `学号-姓名-实验提交-YYYYMMDD-HHMM-序号`。
学号从左端匹配，日期、时间及可选重复编号从右端匹配，中间整体作为姓名（可包含连字符）。
解析函数也支持同结构的 `.tar.gz` 名称；本工具不自动解压归档文件。
学号、姓名和采集时间均来自学生目录名。非法日历日期或时分保留原值并标注“无法解析”。
输入目录本身包含 `term/` 时作为单学生目录；名称不规范时元数据为“未知”，仍处理录像。

```text
操作系统实验数据记录/
├── 2306010113-刘梓宸-20260911-2046/
│   ├── logs/
│   ├── term/
│   │   ├── xxx.out.gz
│   │   └── xxx.tim.gz
│   └── transcripts/
└── 2406080118-yanghanqing-20260911-0926/
    └── term/
```

## 输出结构和文件含义

默认输出为输入目录同级的 `输入目录名称-已清洗/`。单学生模式也在输出根目录下建立学生子目录。

```text
操作系统实验数据记录-已清洗/
├── README.md
└── 刘梓宸/
    ├── 终端对话记录/
    │   ├── terminal_qa_report_lab0.md
    │   └── terminal_qa_report_other.md
    ├── 完整终端转写记录/
    │   ├── full_terminal_transcript_lab0.md
    │   └── full_terminal_transcript_other.md
    ├── 终端命令统计/
    │   ├── command_statistics_lab0.md
    │   └── command_statistics_other.md
    └── claude对话/
        ├── claude_qa_clean_lab0.md
        ├── claude_qa_clean_lab1.md
        └── claude_qa_clean_other.md
```

仅为实际出现的 lab0–lab8 分类生成报告；非实验目录、无法识别目录及失败录像归入 `other`（其他）。
每个分类均生成四份报告，即使某类中没有 Shell 命令或有效 Claude 对话。空学生目录生成 other 四份空报告。
## Lab 分类原则

只根据 Shell 提示符的工作目录匹配完整路径段，例如 `~/lab0`、`/home/user/lab1/kernel`。`lab10`、`lab0-copy` 不属于 lab0–lab8；命令参数或对话正文提到 lab 不用于分类。
同一录像切换 lab 时，在下一条显示新工作目录的提示符处切分。`cd ../lab1` 命令属于执行它时所在的目录，之后的新提示符及命令归入 lab1；失败的 cd 不改变分类。
Claude 对话沿用启动时所在的 Shell 工作目录；Claude 内部文本中的其他路径不会改变归属。首个提示符之前的启动内容归入首个提示符目录；完全没有可识别提示符时归入 other。
跨 lab 录像的完整转写按片段保留，标明原始字节区间。每对录像数据完整重放后输出连续文本；跨 lab 时各片段独立重放并分别输出，不展开 Frame 或逐字符变化。
每个分类内，同一录像的有效 Claude 问答合并为一个 Session，Turn 连续编号。学生/根目录的录像数和 Claude 会话数按原录像去重，不能直接相加各 lab 会话数；命令数和轮次可相加。

| 文件 | 内容 |
| --- | --- |
| terminal_qa_report_labN.md / terminal_qa_report_other.md | Shell 完整命令、执行目录、输出、录像编号、开始及相对时间、命令频次；每条输出最多 400 行 |
| full_terminal_transcript_labN.md / full_terminal_transcript_other.md | 所有录像重放后的连续文本、滚屏和清屏历史、保留下来的 TUI 界面及重放错误 |
| command_statistics_labN.md / command_statistics_other.md | 仅 Shell 命令，按次数降序、命令文本升序排列 |
| claude_qa_clean_labN.md / claude_qa_clean_other.md | 有效 Claude Session、编号 Turn 及用户问题与最终回答，含会话和全局统计 |

`terminal_qa_report_labN.md` 按命令组织输出，可能截断长输出；`full_terminal_transcript_labN.md` 按录像和分类片段组织，完整重放后一次性输出文本，不执行 QA 清洗，也不添加 Frame 标题或逐行变化编号。
每份学生 Markdown 的标题后均提供学号、姓名、时间、来源和录像数量。

## Claude QA 与 Shell 统计原则

Claude QA 只消费 pyte Screen 逐帧 diff，以 `❯` 识别用户区、`●` 识别回复区。过滤 logo、边框、spinner、thinking、工具状态、权限菜单、登录/API 错误、状态栏、快捷键、VS Code 浮层和 resume footer；合并流式增长和重复重绘，不将未完成回复计入完整轮次。
一个终端录像对应一个 Claude Session；仅有启动界面或缺少完整问答的录像不计入有效会话。每个 Session 从 Turn 1 开始；总轮次等于各 Session 轮次之和。
Shell 统计保持原来的彩色提示符锚点识别方法，保留完整参数、选项、管道及重定向。Shell 中启动的 `claude` 会计入；Claude TUI 的 `❯` 输入不会计入。

## 重名、覆盖和异常

同名学生全部使用 `姓名-学号`；同一学生多次采集或其他名称冲突时再附加学号、采集标识及序号。分配目录前会检查已有结果的来源，不会把不同学生合并到同一输出目录。
隐藏文件 `.replay_term_qa.json` 记录输出归属。默认可原子替换本工具为相同来源生成的分类报告。无归属的既有目录默认另选名称；`--overwrite` 可允许覆盖此类目录中的分类报告，仍禁止覆盖已标记为其他来源的结果。分类报告全部写入成功后，仅清理同来源归属清单中已过时的旧版报告。原始数据和其他文件不变。每个文件单独原子替换，整个学生目录不是跨文件事务。
无效学生目录、缺少 term 的目录会跳过；单个录像或学生失败不会中断其余处理。缺少或不可读的 timing 文件时降级一次性重放，QA 可能不完整。重放失败记录在完整转写中，全部异常还列于本页。Shell 提取失败的录像单独计数，不计入“无 Shell 命令”会话。

## 安装和运行

需要 Python 3.9+，依赖 `pyte` 和 `wcwidth`。本工作区使用上级 `公共依赖/pylib/` 依赖目录。

```bash
python3 -m pip install pyte wcwidth
python3 replay_term_qa.py "../操作系统实验数据记录"
python3 replay_term_qa.py "../操作系统实验数据记录" --output "../操作系统实验数据记录-已清洗"
python3 replay_term_qa.py "../操作系统实验数据记录" --student 2306010113
python3 replay_term_qa.py "../操作系统实验数据记录" --student "刘梓宸" --overwrite
python3 replay_term_qa.py "../操作系统实验数据记录/2306010113-刘梓宸-20260911-2046"
python3 replay_term_qa.py --help
```

| 参数 | 说明 |
| --- | --- |
| input_dir | 可选；默认当前目录的操作系统实验数据记录 |
| --output / -o | 输出根目录，禁止与输入目录重叠 |
| --student | 精确匹配学号或姓名 |
| --overwrite | 允许覆盖无归属目录中已有的分类报告 |

存在学生/录像失败时退出码为 1；参数或根目录错误为 2；其余为 0。

## 已知限制

- script 未记录 resize ioctl 时，只能根据 TUI 边框推断宽度；多次 resize 可能影响重放。
- 保持现有提示符识别规则，目前针对 ailab-os 实验环境；其他用户名/主机名或非标准提示符可能无法识别。
- TUI 格式发生较大版本变化时可能需要更新过滤规则；终端录像无法提供可靠的结构化消息边界。
- 完整转写保留最终屏幕、滚屏及清屏历史；被原地重绘覆盖且未进入历史的瞬时字符（如 spinner 和流式中间状态）不单独导出。
- 时间优先保留 script 头部的原始时区；学生目录采集时间本身不包含时区。

## 本次运行汇总

- 输入目录：/Users/neoa/OS-Lab-Score/操作系统实验数据清洗/操作系统实验数据记录
- 处理学生数：7
- 成功学生数：6
- 跳过数量：0
- 失败或部分失败学生数：1
- 终端录像数：117
- 重放失败数：1
- Shell 命令执行总次数：209
- Claude 会话总数：8
- 对话轮次总数：35

| 学生目录 | 状态 | 录像 | 命令 | Claude 会话 | 轮次 | 输出 |
| --- | --- | ---: | ---: | ---: | ---: | --- |
| 2306010113-刘梓宸-20260911-2046 | 成功 | 1 | 0 | 0 | 0 | [lab0](%E5%88%98%E6%A2%93%E5%AE%B8/%E7%BB%88%E7%AB%AF%E5%AF%B9%E8%AF%9D%E8%AE%B0%E5%BD%95/terminal_qa_report_lab0.md) |
| 2406080102-戴炜-20260909-1131 | 成功 | 18 | 54 | 2 | 11 | [lab0](%E6%88%B4%E7%82%9C/%E7%BB%88%E7%AB%AF%E5%AF%B9%E8%AF%9D%E8%AE%B0%E5%BD%95/terminal_qa_report_lab0.md) / [lab1](%E6%88%B4%E7%82%9C/%E7%BB%88%E7%AB%AF%E5%AF%B9%E8%AF%9D%E8%AE%B0%E5%BD%95/terminal_qa_report_lab1.md) / [其他](%E6%88%B4%E7%82%9C/%E7%BB%88%E7%AB%AF%E5%AF%B9%E8%AF%9D%E8%AE%B0%E5%BD%95/terminal_qa_report_other.md) |
| 2406080104-方如轩-20260909-1237 | 部分失败 | 8 | 0 | 0 | 0 | [其他](%E6%96%B9%E5%A6%82%E8%BD%A9/%E7%BB%88%E7%AB%AF%E5%AF%B9%E8%AF%9D%E8%AE%B0%E5%BD%95/terminal_qa_report_other.md) |
| 2406080106-高龙徽-20260909-1215 | 成功 | 20 | 6 | 1 | 1 | [lab0](%E9%AB%98%E9%BE%99%E5%BE%BD/%E7%BB%88%E7%AB%AF%E5%AF%B9%E8%AF%9D%E8%AE%B0%E5%BD%95/terminal_qa_report_lab0.md) / [其他](%E9%AB%98%E9%BE%99%E5%BE%BD/%E7%BB%88%E7%AB%AF%E5%AF%B9%E8%AF%9D%E8%AE%B0%E5%BD%95/terminal_qa_report_other.md) |
| 2406080111-李兆卓-20260909-1215 | 成功 | 21 | 47 | 0 | 0 | [lab0](%E6%9D%8E%E5%85%86%E5%8D%93/%E7%BB%88%E7%AB%AF%E5%AF%B9%E8%AF%9D%E8%AE%B0%E5%BD%95/terminal_qa_report_lab0.md) / [lab1](%E6%9D%8E%E5%85%86%E5%8D%93/%E7%BB%88%E7%AB%AF%E5%AF%B9%E8%AF%9D%E8%AE%B0%E5%BD%95/terminal_qa_report_lab1.md) / [其他](%E6%9D%8E%E5%85%86%E5%8D%93/%E7%BB%88%E7%AB%AF%E5%AF%B9%E8%AF%9D%E8%AE%B0%E5%BD%95/terminal_qa_report_other.md) |
| 2406080118-杨涵清-20260911-0926 | 成功 | 24 | 65 | 1 | 15 | [lab0](%E6%9D%A8%E6%B6%B5%E6%B8%85/%E7%BB%88%E7%AB%AF%E5%AF%B9%E8%AF%9D%E8%AE%B0%E5%BD%95/terminal_qa_report_lab0.md) / [lab1](%E6%9D%A8%E6%B6%B5%E6%B8%85/%E7%BB%88%E7%AB%AF%E5%AF%B9%E8%AF%9D%E8%AE%B0%E5%BD%95/terminal_qa_report_lab1.md) / [其他](%E6%9D%A8%E6%B6%B5%E6%B8%85/%E7%BB%88%E7%AB%AF%E5%AF%B9%E8%AF%9D%E8%AE%B0%E5%BD%95/terminal_qa_report_other.md) |
| 2406080205-周卓江-20260910-2322 | 成功 | 25 | 37 | 4 | 8 | [lab0](%E5%91%A8%E5%8D%93%E6%B1%9F/%E7%BB%88%E7%AB%AF%E5%AF%B9%E8%AF%9D%E8%AE%B0%E5%BD%95/terminal_qa_report_lab0.md) / [其他](%E5%91%A8%E5%8D%93%E6%B1%9F/%E7%BB%88%E7%AB%AF%E5%AF%B9%E8%AF%9D%E8%AE%B0%E5%BD%95/terminal_qa_report_other.md) |

### 按实验分类汇总

| 分类 | 录像（分类内去重） | 命令 | Claude 会话（分类内去重） | 轮次 |
| --- | ---: | ---: | ---: | ---: |
| lab0 | 50 | 155 | 5 | 32 |
| lab1 | 3 | 15 | 0 | 0 |
| 其他 | 69 | 39 | 3 | 3 |

### 跳过与异常详情

- /Users/neoa/OS-Lab-Score/操作系统实验数据清洗/操作系统实验数据记录/2406080104-方如轩-20260909-1237/term/20260909T120838-19233.out.gz \[完整重放/目录分类\] ValueError: 录像为空或缺少 script 头部换行

<!-- replay_term_qa:timeline:start -->
## 实验过程时间线

每名学生的 `实验过程时间线/` 按 lab 提供对应的 JSON 规范数据和 Markdown 阅读版。Shell 命令、Claude 用户问题与 Claude 回复分别作为事件，并保留录像、终端、工作目录、相对时间、原始定位和不确定性说明。

时间线中的时间是文本在终端画面中的可观察显示时间，不代表精确提交、执行开始、模型生成开始或回复完成时间。同一 lab 内跨终端排序使用带时区的绝对时间；相同或接近的时间不证明严格先后。

录像起始时钟只有秒级精度；显示到毫秒仅用于保留 timing 相对偏移，不代表绝对时间具有毫秒精度。Claude 回复最终正文完整可见时间可能晚于下一轮问题，它不是回复完成时间。

JSON 中 `observed_at` 为带时区的显示时间，`elapsed_seconds` 为原录像累计偏移；`source.observation` 保留原 timing 行号、变化画面编号和解压字节区间（零基、左闭右开）。画面编号不等于 timing 行号，观察帧的位置也不代表正文全部字符都来自这一帧。`final_text_first_observed_at` 仅记录最终回复正文首次完整可见时间。无法确定的值保留为 null，原因见 `uncertainty`。

`recording_details` 保留所有录像的读取、时钟和提取检查记录；`errors` 包含异常与不确定性提示，不等同于处理失败。没有提取到事件不代表没有发生操作或对话。内部未保留的 Claude 记录可能只是重绘残留，不能作为额外未完成对话计数。

默认运行同时生成原有四类报告和时间线；`--timeline-only` 只刷新时间线并仅替换本说明块，保留 README 中原有报告统计与其他内容；`--no-timeline` 只生成原有报告。两项不能同时使用。

本工作区仅更新时间线的命令（在脚本所在目录执行）：

```powershell
python3 replay_term_qa.py "../操作系统实验数据记录" -o "../操作系统实验数据记录-已清洗" --timeline-only
```

- 本次时间线学生数：7
- 终端录像数：117
- 事件数：279
- Shell 命令事件：209
- Claude 用户问题事件：35
- Claude 回复事件：35
- 有绝对显示时间：268
- 仅有录像相对时间：11
- 时间缺失：0
- 带不确定性说明：29
- 录像处理失败：0
- 处理失败总数：0
- 异常数：15
<!-- replay_term_qa:timeline:end -->
