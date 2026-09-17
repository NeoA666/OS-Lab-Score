# 操作系统实验数据清洗

本目录保存学生操作系统实验的原始采集数据、派生的审阅报告，以及两套独立工具：实验过程清洗和 xv6 源码差异报告。原始数据与 xv6 基准均只读；工具只在已清洗目录中写入派生报告。

## 目录说明

| 目录 | 内容 | 是否由工具写入 |
| --- | --- | --- |
| `操作系统实验数据记录/` | 按“学号-姓名-时间”保存的原始学生采集数据和源码提交 | 否 |
| `操作系统实验数据记录-已清洗/` | 每位学生的终端、时间线和代码差异报告 | 是 |
| `实验过程清洗工具/` | 终端录像重放、命令与 Claude 问答提取、时间线生成及其测试 | 否 |
| `代码差异报告工具/` | xv6 `lab1` 至 `lab8` 源码差异 Markdown 生成器及其测试 | 否 |
| `文档/` | 数据背景和处理规则说明 | 否 |
| `历史验证记录/` | 已归档的旧脚本、日志、验证数据和验收材料，不作为当前入口 | 否 |

## 实验过程清洗

工具会读取原始 `term/` 录像，生成终端对话、完整转写、命令统计、Claude 问答和实验过程时间线。进入工具目录执行：

```bash
cd 实验过程清洗工具
python3 replay_term_qa.py ../操作系统实验数据记录 \
  --output ../操作系统实验数据记录-已清洗
```

只更新时间线：

```bash
python3 replay_term_qa.py ../操作系统实验数据记录 \
  --output ../操作系统实验数据记录-已清洗 --timeline-only
```

运行该工具的测试：

```bash
python3 -m unittest -v \
  test_replay_term_qa test_timeline test_timeline_alignment \
  test_timeline_reports test_generate_readable_timeline
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

## 参考资料

- [已清洗数据与报告说明](操作系统实验数据记录-已清洗/README.md)
- [实验过程数据背景总结](文档/实验过程数据背景总结.md)
- [历史验证记录](历史验证记录/README.md)
