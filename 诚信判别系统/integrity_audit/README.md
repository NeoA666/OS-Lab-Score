# 学生 / Lab 诚信审核 Agent

本目录提供一个受控的诚信审核 Agent Loop。每次任务只读取一个学生目录中的一个 `labN`，再生成稳定位置的完整报告和教师复核报告。报告是复核材料，不是违规认定、处分或评分决定。

系统会把清洗后的实验过程、代码 diff 和 AI/人工贡献评估作为输入。模型只能通过只读工具访问当前学生和当前 Lab 的材料；宿主程序负责校验规则引用、事件引用、v3 证据范围、哈希、证据等级和最终诚信标签。

## 目录与输入

默认清洗数据根目录为：

```text
/Users/neoa/OS-Lab-Score/操作系统实验数据清洗/操作系统实验数据记录-已清洗/
```

每个学生目录可以包含以下按 Lab 分开的材料：

```text
<学生目录>/
├── 实验过程时间线/timeline_lab0.json|.md
├── 简洁实验过程时间线/timeline_lab0.md
├── 终端命令统计/command_statistics_lab0.md
├── 终端对话记录/terminal_qa_report_lab0.md
├── claude对话/claude_qa_clean_lab0.md
├── 完整终端转写记录/full_terminal_transcript_lab0.md
├── 代码差异报告/lab0.md
└── AI人工贡献识别/assessment/assessment_lab0.json
```

`assessment_labN.json` 遵循 `ai-human-contribution-assessment/v3`。其中的 source path、SHA-256、行号、excerpt、diff hunk 和独立复核状态由宿主重新读取和验证；无效单元会被隔离，不能作为风险升级依据。代码 diff 会通过同一 v3 证据链进入 Agent Loop，不再被当作普通自由文本。

清洗时间线和 Markdown 视图通常来自同一原始归档，默认是 `E2`。只有带有受控原始文件、哈希和精确范围的材料才可能成为 `E1`。缺少文件只能说明覆盖不足，不能据此推断学生没有操作、使用了 AI 或存在风险。

## 诚信标签

宿主程序在模型草稿通过校验后生成一个稳定标签：

| 标签 | 含义 |
| --- | --- |
| `完全诚信` | 当前材料未形成诚信复核线索 |
| `基本诚信` | 有教学提醒或资料边界，但未形成高风险结论 |
| `存在疑点` | 经规则启用、复核同意且引用有效的贡献材料形成教师核实线索 |
| `高风险待核实` | 同时满足独立 `E1`、规则引用和 `R1/R2` 门槛，仍须教师正式核实 |
| `资料不足/无法判定` | 当前材料或 v3 评估不完整，不能作出诚信判断 |

`R1`、`R2` 是复核路径，不是违规结论。贡献层通常是 `E2`，不能单独产生高风险标签。

## NVIDIA NIM 配置

客户端使用 NVIDIA NIM 的 OpenAI 兼容接口。真实密钥只通过进程环境或密钥管理器注入，不能写入源码、文档、报告、日志或 Git：

```bash
export NVIDIA_API_KEY='由密钥管理器注入的 nvapi 密钥'
export NVIDIA_API_BASE_URL='https://integrate.api.nvidia.com/v1'
export NVIDIA_MODEL='nvidia/nemotron-3-super-120b-a12b'
export NVIDIA_MAX_TOKENS='32768'
export NVIDIA_CONNECT_TIMEOUT_SECONDS='15'
export NVIDIA_READ_TIMEOUT_SECONDS='300'
export NVIDIA_TEMPERATURE='1.0'
export NVIDIA_TOP_P='0.95'
```

请求会发送 `chat_template_kwargs.enable_thinking=true` 和 `force_nonempty_content=true`，并使用 `max_tokens=32768` 保留较高的思考空间。思维内容只保留在当前请求的内存上下文中，不写入 trace、assessment 或报告；运行日志会过滤 reasoning、原始响应和疑似密钥文本。客户端支持 SSE 工具调用分片、连接/读取超时和对限流及临时服务错误的退避重试。

参数依据：[NVIDIA Nemotron 3 Super 官方模型说明](https://build.nvidia.com/nvidia/nemotron-3-super-120b-a12b.md)。官方示例同样使用 `temperature=1.0`、`top_p=0.95`，并说明可通过 `enable_thinking` 控制 reasoning。

## 单任务运行

```bash
cd /Users/neoa/OS-Lab-Score/诚信判别系统/integrity_audit
python3 -m audit_agent students
python3 -m audit_agent inspect --student <学号或学生目录名> --lab lab0
python3 -m audit_agent audit --student <学号或学生目录名> --lab lab0 --dry-run
python3 -m audit_agent audit --student <学号或学生目录名> --lab lab0
```

`inspect` 和 `--dry-run` 不调用模型。正式运行最多使用 20 轮，可通过 `--max-turns 2..30` 调整。可选的 `--baseline-manifest` 用于提供已发布基线哈希清单；当前版本只验证和展示清单身份，不把基线差异直接当成风险结论。

## 批处理与恢复

处理所有学生的 Lab0：

```bash
python3 -m audit_agent batch --lab lab0
```

只处理指定学生或多个 Lab：

```bash
python3 -m audit_agent batch \
  --student <学生目录名或学号> \
  --student <另一名学生> \
  --lab lab0 --lab lab1
```

也可以用 `--all-labs` 从每名学生已有的时间线和 v3 文件发现 `labN`（与 `--lab` 互斥）：

```bash
python3 -m audit_agent batch --all-labs --resume
```

批处理对每个学生/Lab 独立记录状态；单个任务失败不会阻断其他任务。`--resume` 会复用输入指纹未变化的已完成任务，并把上次失败的任务标为待重试；`--resume --retry-failed` 才会重新运行失败任务；`--force` 忽略缓存并重新调用模型；`--dry-run` 只输出任务清单，不写报告和批次汇总。

稳定输出结构如下，重复运行会原子替换同一份当前报告：

```text
诚信审核报告草稿/<学生目录>/<labN>/完整诚信审核报告.md
教师复核报告草稿/<学生目录>/<labN>/教师诚信复核报告.md
诚信审核运行日志/<学生目录>/<labN>/assessment.json
诚信审核运行日志/<学生目录>/<labN>/audit_manifest.json
诚信审核运行日志/<学生目录>/<labN>/runs/<时间戳>.jsonl
诚信审核运行日志/batches/<批次名>/summary.json
```

完整报告首屏展示诚信标签、覆盖状态、贡献单元、来源范围和教师动作；教师报告优先展示处理路径、待核实条目、替代解释和可执行核实点。报告只呈现有界 excerpt、路径、哈希和行号，不展开完整原始文件。

## 从已有日志重渲染

模板调整后可从含有 `validated_assessment` 的 JSONL 日志重建两份报告：

```bash
python3 -m audit_agent render-trace \
  --student <学号或学生目录名> --lab lab0 \
  --trace /路径/诚信审核运行日志/<学生目录>/lab0/runs/<文件>.jsonl
```

命令会重新检查学生、Lab、规则 SHA-256、事件证据和 v3 范围，并重新计算宿主诚信标签；日志中的模型标签不能绕过这些校验。

## 验证

```bash
python3 -m compileall -q audit_agent
python3 -m unittest discover -s tests -v
```

测试使用离线假客户端，不会向 NVIDIA 发起请求。报告和运行日志可能包含学生数据，应按课程授权、访问控制和留存制度保存。
