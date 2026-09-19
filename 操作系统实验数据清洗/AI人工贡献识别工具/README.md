# AI/人工贡献识别工具 v3

这是操作系统实验数据清洗的一个独立阶段。它按“学生目录 + `labN`”读取已清洗材料，调用 NVIDIA NIM 做语义识别和独立复核，输出可供后续诚信判别系统或评分机制参考的贡献证据。它不修改诚信判别系统，不输出诚信等级、违规结论、处分建议或分数。

## 工作方式

脚本不通过文本匹配、代码风格、提交速度或命令频率判定“谁写了代码”。脚本只负责：发现当前 Lab 的材料、建立来源 ID 与行号索引、计算 SHA-256、向 NIM 提供受控只读片段、校验结构化结果、脱敏、增量缓存和原子写入。

NIM 完成两轮彼此独立的语义工作：

1. 主分析按来源 ID 和行范围读取当前 Lab 的材料，形成贡献单元和证据引用。
2. 独立复核重新检查必要材料；若不同意某个单元，该单元降级为 `indeterminate`。

生产分析和独立复核都由 NVIDIA NIM 执行，凭据只从运行环境的 `NVIDIA_API_KEY` 读取。工具绝不把 API 密钥、原始 NIM 响应或模型思维内容写入 JSON、Markdown、清单或运行日志。

## 输入材料

每次分析只能使用当前学生、当前 Lab 的下列已清洗 Markdown 材料：

```text
操作系统实验数据记录-已清洗/<学生>/
  简洁实验过程时间线/timeline_labN.md
  终端对话记录/terminal_qa_report_labN.md
  终端命令统计/command_statistics_labN.md
  代码差异报告/labN.md
```

`lab0` 不要求代码差异报告，只使用前三份材料并生成 `process_segment` 过程贡献单元。`lab1` 至 `lab8` 必须具备四份材料；缺少任一规定过程材料时，任务写为 `insufficient_data`，列出缺口，不请求 NIM 归属，也不把缺失解释为未使用 AI 或人工完成。

完整终端转写、`claude_qa_clean_labN.md`、原始录像及其他 Lab 的材料不会进入本工具的模型上下文。

## v3 输出

每个任务的稳定输出位置如下：

```text
操作系统实验数据记录-已清洗/<学生>/AI人工贡献识别/
  assessment/
    assessment_labN.json
  完整贡献识别报告/
    完整贡献识别报告_labN.md
  教师贡献复核报告/
    教师贡献复核报告_labN.md
  .contribution_manifest.json

操作系统实验数据记录-已清洗/AI人工贡献识别汇总/
  总览.md
  总览.csv

操作系统实验数据记录-已清洗/AI人工贡献识别运行日志/
```

`assessment_labN.json` 是唯一机器接口，`schema_version` 为 `ai-human-contribution-assessment/v3`。它包含：

- `source_manifest` 与 `diff_hunks`：四类材料的来源 ID、路径、哈希、行数、可用状态，以及 diff hunk 的定位。
- `coverage`：当前 Lab 的资料覆盖与缺口；资料缺失只降低可见性，不形成 AI 或人工归因。
- `contribution_units`：每个 `code_hunk` 或 `process_segment` 的 `ai_dominant`、`human_dominant`、`mixed` 或 `indeterminate` 结论，固定的 `{ai, human}` 角色对象、置信度、单一 hunk 或行范围、短摘录证据、替代解释和局限。
- `lab_conclusion`、`review`、`limitations`、`run_metadata`：Lab 级摘要、NIM 独立复核的单元记录/派生索引和追溯信息。

报告只显示脱敏短摘录、来源路径、哈希与行范围，不包含完整输入材料或 NIM 的私有输出。完整字段与下游消费规则见 [诚信判别系统对接文档.md](诚信判别系统对接文档.md)。

## 贡献标签的边界

`ai_dominant`、`human_dominant`、`mixed` 和 `indeterminate` 是当前清洗材料上的语义贡献判断，不是作者身份、手打、粘贴、理解程度或是否违规的事实认定。

例如，AI 给出代码、学生阅读解释后自己修改并验证时，NIM 可以根据可复核过程将相应代码或过程单元判为 `human_dominant`，同时在 `behavior_roles` 中保留 `ai_code_generation` 等可观察辅助角色。只有材料与行号引用足以支撑时才会形成这种结论；无法区分时必须输出 `indeterminate`。

## 命令

在本目录运行：

```bash
# 查看某个任务的材料发现与可用性；不调用 NIM
python3 identify_contributions.py inspect --student 2406080118 --lab lab0

# 只预览，不调用 NIM 或写入产物
python3 identify_contributions.py analyze --student 2406080118 --lab lab0 --dry-run

# 检查 NIM 原生受控读取能力与网络配置
python3 identify_contributions.py doctor

# 运行一个任务
python3 identify_contributions.py analyze --student 2406080118 --lab lab1

# 批量运行；默认顺序执行
python3 identify_contributions.py batch --lab lab1 --jobs 1
```

运行实际 NIM 分析前，由环境注入凭据：

```bash
export NVIDIA_API_KEY='由运行环境注入'
```

`--force` 忽略该任务的分析缓存。输入材料、提示词、模型的非敏感配置、受控读取协议、校验器或 schema 变化时会重新分析；只有报告模板变化时只重渲染两份 Markdown。`--resume`、`--retry-failed`、`--dry-run` 与 `--jobs 1` 可用于批处理恢复和预演。

模型偶尔返回无法解析、根节点不是对象、提交动作错误或缺少提交对象的 JSON 信封时，工具会先执行既有的单次局部协议修复；该修复仍失败时，会以全新会话完整重跑主分析和独立复核一次。因此单个任务最多执行两次完整尝试。证据范围、内容校验、资料不足和配置错误不会触发该任务级重跑。两次都失败后会写入可重试的结构化失败记录；后续批处理仍需显式使用 `--retry-failed` 或 `--force` 才会再次调用 NIM。

## 与诚信判别系统的关系

后续诚信判别系统只能把 v3 assessment 当作补充过程和代码来源材料。它必须自行检查学生/Lab 边界、源文件哈希、行范围和本系统的证据等级，再根据 Lab 规则决定是否采取教学或诚信动作。不得只凭贡献标签、总体画像、代码 diff 或 Markdown 报告产生诚信等级或违规结论。
