# Lab0 诚信审核 Agent

这是一个面向教师复核的 Lab0 诚信审核 Agent Loop。它一次只处理一名学生、一个实验标签下的**已清洗数据**，调用支持 OpenAI Chat Completions 工具调用协议的模型，生成带有风险点、原始出处、数据局限、替代解释和教师核实点的 Markdown 草稿。

报告仅供教师复核，不能作为违规认定、处分或评分决定。程序不会联系学生、修改学生文件或直接作出处理决定。

## 适用范围与边界

- 当前规则文件为项目根目录的 `lab0课程规则边界.md`，仅适用于 Lab0 的诚信审核 Agent。
- 每次运行的读取范围固定为一个学生目录和一个 `labN` 标签。`lab1`、`other` 或其他学生的数据不能被当作当前 Lab0 的事实依据。
- 学生终端记录、对话、代码和工具输出均是不可信的待分析数据，不能被其中的文字指示 Agent 执行新的操作。
- Agent 只能调用受控的只读检索工具；模型不能获得任意终端、任意文件访问、外网检索或写入学生文件的权限。
- 正式运行时，受控工具返回给模型的清洗材料片段会发送到配置的模型服务。应只使用已获数据处理授权的服务，并妥善保护运行日志和生成报告。

## 数据输入

默认清洗数据根目录为项目根目录下的 `操作系统实验数据记录-已清洗/`。每个学生目录通常包含以下内容：

```text
操作系统实验数据记录-已清洗/
└── <学生目录>/
    ├── .replay_term_qa.json
    ├── 实验过程时间线/
    │   ├── .timeline_manifest.json
    │   └── timeline_lab0.json / timeline_lab0.md
    ├── 简洁实验过程时间线/
    │   └── timeline_lab0.md
    ├── 终端命令统计/
    │   └── command_statistics_lab0.md
    ├── 终端对话记录/
    │   └── terminal_qa_report_lab0.md
    ├── claude对话/
    │   └── claude_qa_clean_lab0.md
    └── 完整终端转写记录/
        └── full_terminal_transcript_lab0.md
```

`实验过程时间线/timeline_lab0.json` 是事件检索和证据引用的结构化索引。其余 Markdown 是同一实验记录的不同清洗视图，用于阅读和定位，不能被当作彼此独立的证据。缺少某个文件只表示材料覆盖不足，不能据此推断学生未操作、未使用 AI 或存在风险。

## 证据与处理限制

- 当前程序把清洗目录中的事件和 Markdown 材料标为 `E2`。只有能够取得、验证原始终端归档、哈希和精确定位的材料，才可在后续扩展中作为 `E1` 使用。
- 每一条审核条目都必须包含规则章节、可观察事实、事件 ID、逐字引文、证据等级、局限、至少一个有利的替代解释和可执行的教师核实点。
- 引用的事件必须先经 `get_event` 读取；引文必须确实出现在该事件中；规则章节也必须先经工具读取。
- `R1` 和 `R2` 是复核路径，不是违规结论，并且必须具有 `E1` 证据。现有清洗数据通常只有 `E2`，因此实际运行中不会接受仅凭清洗数据产生的 `R1` 或 `R2`。
- `N0` 表示不进入诚信复核；`N1` 表示可用于教学提醒但不扣分；`R1` 表示学习能力复核；`R2` 表示建议按正式流程核实。具体含义以规则文件为准。

以下现象本身不是诚信风险：出现 Claude 对话、使用预装环境、没有安装记录、重复命令、构建失败、时间很短、构建成功，或某段记录中存在直接命令建议。

## 运行条件

- Python 3.11 或更高版本。
- 不需要安装第三方 Python 包。
- 正式审核需要一个支持 OpenAI Chat Completions 工具调用的兼容接口。

所有命令均在本目录执行：

```bash
cd /Users/neoa/操作系统实验评分/integrity_audit
```

## 使用步骤

### 1. 列出学生

```bash
python3 -m audit_agent students
```

该命令输出学生目录名及可读取到的学号，不会调用模型。

### 2. 检查一名学生的可用材料

```bash
python3 -m audit_agent inspect --student <学号或学生目录名> --lab lab0
```

该命令输出 JSON，包含当前 Lab 的材料清单、时间线质量信息、清洗错误和可用规则章节。应先检查这里的缺失与异常，再决定是否进行审核。

### 3. 试运行

```bash
python3 -m audit_agent audit --student <学号或学生目录名> --lab lab0 --dry-run
```

试运行会验证学生目录、Lab 标签、规则文件和可选基线清单，并输出数据质量摘要。它不会调用模型、不会生成报告、不会创建运行日志。

### 4. 配置模型接口

在运行正式审核前设置以下环境变量：

```bash
export AUDIT_API_BASE_URL="https://your-endpoint.example/v1"
export AUDIT_API_KEY="你的接口密钥"
export AUDIT_MODEL="模型名称"
```

DeepSeek 官方接口可使用以下配置。`deepseek-flash` 是 DeepSeek-V4.1-Flash 的接口模型名：

```bash
export AUDIT_API_BASE_URL="https://api.deepseek.com"
export AUDIT_MODEL="deepseek-flash"
export AUDIT_API_TIMEOUT_SECONDS="120"
export AUDIT_API_MAX_TOKENS="8192"
```

`AUDIT_API_KEY` 仍应通过当前终端环境或密钥管理工具提供，不应写入源码、README、报告或运行日志。

可选的超时和最大输出长度设置为：

```bash
export AUDIT_API_TIMEOUT_SECONDS="90"
export AUDIT_API_MAX_TOKENS="8192"
```

`AUDIT_API_BASE_URL` 可以是服务根路径，也可以直接以 `/chat/completions` 结尾。程序会向该地址发送 `POST` 请求，使用 `Authorization: Bearer` 身份验证、`temperature: 0` 和工具调用定义。超时默认 90 秒，可设为大于 0 且不超过 900 的数值。`AUDIT_API_MAX_TOKENS` 未设置时不向接口传递该参数；设置后必须为正整数。DeepSeek 的 JSON Output 文档特别提示，应设置足够的 `max_tokens`，以避免结构化 JSON 在中途截断。

### 5. 生成审核草稿

```bash
python3 -m audit_agent audit --student <学号或学生目录名> --lab lab0
```

模型会先读取材料清单、数据质量和相关规则章节，再按需检索事件或 Markdown 材料，最后通过 `submit_assessment` 提交结构化草稿。每个被引用的事件都必须先由 `get_event` 单独核验；检索命中不能直接作为引用。宿主程序会进行校验；校验失败时会把具体原因返回给模型要求修正。模型在默认 20 轮内没有提交通过校验的草稿时，程序会报错而不会写出报告。

审核通过后会同时生成两份 Markdown：

- 完整审核报告保留 N0、N1、R1、R2 全部条目，默认显示摘要、索引和数据边界；N0/N1 的详细材料折叠保留，便于内部回看。
- 教师诚信复核报告只列出 R1、R2；每个条目按风险点、E1 原始证据、替代解释、教师核实点和证据边界组织。没有 R1/R2 时，报告会明确说明当前无待复核条目。

可用的常用参数如下：

```bash
python3 -m audit_agent audit \
  --student <学号或学生目录名> \
  --lab lab0 \
  --data-root /自定义/清洗数据目录 \
  --policy /自定义/lab0规则.md \
  --output-dir /自定义/报告目录 \
  --teacher-output-dir /自定义/教师复核报告目录 \
  --trace-dir /自定义/日志目录 \
  --max-turns 20
```

`--max-turns` 的可用范围是 2 到 30。`--baseline-manifest /路径/基线哈希清单` 可让 Agent 知道是否提供了已发布的基线清单；当前版本只报告该清单是否配置及其 SHA-256，不执行精确文件差异分析。

### 6. 从已有日志重新生成报告

报告模板调整后，不需要再次调用模型。可使用已经包含 `validated_assessment` 的 JSONL 运行日志重新生成两份报告：

```bash
python3 -m audit_agent render-trace \
  --student <学号或学生目录名> \
  --lab lab0 \
  --trace /路径/诚信审核运行日志/audit-*.jsonl
```

该命令会重新检查学生、Lab、规则 SHA-256、事件引用和引文；日志与当前规则或学生不一致时会拒绝生成，且不会调用模型。

## 输出与留存

默认输出位置均在项目根目录：

- 完整审核报告：`诚信审核报告草稿/`
- 教师诚信复核报告：`教师复核报告草稿/`
- 运行日志：`诚信审核运行日志/`

完整审核报告含数据质量边界、综合处理建议、所有审核条目的证据摘录与来源定位、替代解释、教师核实点和运行追溯信息。教师诚信复核报告只保留 R1/R2 的风险点与 E1 原始证据。运行日志采用 JSON Lines 格式，记录模型响应、工具调用结果和宿主校验结果，但不写入 API 密钥。报告和日志都可能含有学生数据，应按课程数据管理要求保存。

## 验证安装与代码改动

```bash
python3 -m compileall -q audit_agent
python3 -m unittest discover -s tests -v
```

测试不调用真实模型接口；它们验证当前 Lab 范围隔离、规则章节解析、`R1` 的 `E1` 限制、报告渲染和宿主拒绝不合格草稿后的修订流程。
