# 操作系统实验数据清洗

本目录保存学生操作系统实验的原始采集数据、派生的审阅报告，以及三套独立工具：实验过程清洗、xv6 源码差异报告和 AI/人工贡献识别。原始数据与 xv6 基准均只读；工具只在已清洗目录中写入派生报告。

## 目录说明

| 目录 | 内容 | 是否由工具写入 |
| --- | --- | --- |
| `操作系统实验数据记录/` | 按“学号-姓名-时间”保存的原始学生采集数据和源码提交 | 否 |
| `操作系统实验数据记录-已清洗/` | 每位学生的终端、时间线和代码差异报告 | 是 |
| `实验过程清洗工具/` | 终端录像重放、命令与 Claude 问答提取、时间线生成及其测试 | 否 |
| `代码差异报告工具/` | xv6 `lab1` 至 `lab8` 源码差异 Markdown 生成器及其测试 | 否 |
| `AI人工贡献识别工具/` | 基于已清洗时间线和 diff 的 AI/人工贡献提取 | 否 |
| `文档/` | 数据背景和处理规则说明 | 否 |
| `历史验证记录/` | 已归档的旧脚本、日志、验证数据和验收材料，不作为当前入口 | 否 |

## 实验过程清洗

工具会读取原始 `term/` 录像，生成终端对话、完整转写、命令统计、Claude 问答和实验过程时间线。进入工具目录执行：

```bash
cd 实验过程清洗工具
python3 replay_term_qa.py ../操作系统实验数据记录 \
  --output ../操作系统实验数据记录-已清洗
```

默认按“学生目录 + 处理阶段”增量处理：所有输入仍会扫描，但输入内容、处理器代码和登记产物都未变化的阶段会跳过重放并保留统计。使用 `--force` 可强制重建当前选中的学生和阶段：

```bash
python3 replay_term_qa.py ../操作系统实验数据记录 \
  --output ../操作系统实验数据记录-已清洗 --student 2306010113 --force
```

每名学生必须提供至少一个常规 `term/*.out.gz` 录像。缺失、为空、符号链接或 Windows junction 的 `term/` 会按学生级失败处理，命令返回 `1`，不会生成空学生报告或时间线；无匹配的 `--student` 返回参数错误 `2`。

只更新时间线：

```bash
python3 replay_term_qa.py ../操作系统实验数据记录 \
  --output ../操作系统实验数据记录-已清洗 --timeline-only
```

运行该工具的测试：

```bash
python3 -m unittest -v \
  test_replay_term_qa test_timeline test_timeline_alignment \
  test_timeline_reports test_generate_readable_timeline \
  test_incremental_processing
```

## xv6 源码差异报告

差异工具将学生 `labs/labN` 的源码和构建配置与工作区根目录的 `xv6-ai-labs-km-无答案/labN` 比较。默认忽略纯空白差异，并只比较 `kernel/`、`xv6-user/`、`linker/` 和 Makefile，不纳入文档、教师参考资料或构建产物。

```bash
cd 代码差异报告工具
python3 generate_lab_diff_reports.py --all-labs
```

常用变体：

```bash
# 指定一个实验或学生
python3 generate_lab_diff_reports.py --lab lab3
python3 generate_lab_diff_reports.py --all-labs --student 2406080106

# 预演，或显示空白符差异
python3 generate_lab_diff_reports.py --all-labs --dry-run
python3 generate_lab_diff_reports.py --lab lab1 --strict-whitespace
```

个人报告写入 `操作系统实验数据记录-已清洗/<学生>/代码差异报告/labN.md`；跨学生汇总写入 `操作系统实验数据记录-已清洗/代码差异报告汇总/labN.md`。详细参数见 [代码差异工具说明](代码差异报告工具/README.md)。

## AI/人工贡献识别

贡献识别是时间线、终端报告、命令统计和代码 diff 之后的独立清洗阶段。它将当前“学生目录 + Lab”的四类已清洗材料交给 NVIDIA NIM 做语义主分析和独立复核；脚本只负责来源索引、哈希、受控读取、校验、脱敏与缓存。`lab0` 只分析过程材料，`lab1` 至 `lab8` 缺少任一规定材料时写为 `insufficient_data`，不会猜测 AI 或人工贡献。

结果是 `ai-human-contribution-assessment/v3` 的补充证据 JSON 和两份 Markdown 报告，不是诚信等级、违规结论或分数。`ai_dominant`、`human_dominant`、`mixed` 和 `indeterminate` 只描述当前材料的语义贡献画像，不能断言真实作者、手打、粘贴或理解程度。

```bash
cd AI人工贡献识别工具
python3 identify_contributions.py analyze --student 2406080118 --lab lab1 --dry-run
```

实际 NIM 分析与独立复核都要求由运行环境提供 `NVIDIA_API_KEY`。输出写入每位学生的 `AI人工贡献识别/` 目录，详细命令、v3 契约与诚信系统消费限制见 [AI/人工贡献识别工具说明](AI人工贡献识别工具/README.md)。

## 参考资料

- [已清洗数据与报告说明](操作系统实验数据记录-已清洗/README.md)
- [实验过程数据背景总结](文档/实验过程数据背景总结.md)
- [2026-09-17 工具修复与复跑报告](文档/2026-09-17-工具修复与复跑报告.md)
- [历史验证记录](历史验证记录/README.md)
