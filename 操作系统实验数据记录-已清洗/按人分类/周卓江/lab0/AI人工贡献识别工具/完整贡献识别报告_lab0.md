# 完整贡献识别报告

- 学号：未知
- 学生目录：周卓江
- 实验：lab0
- 分析状态：insufficient_data

## 使用边界

当前结果仅记录规定清洗材料不足；未形成 NIM 贡献归因，资料缺失不能解释为未使用 AI。它只可作为后续教学、诚信判别或评分机制的补充输入；下游必须自行复核源文件、哈希与行范围，并应用自身规则。

## 输入材料清单

- 资料覆盖：insufficient
- 限制：source:lab0:timeline: 未找到该 Lab 的清洗材料；缺失不能解释为未操作或未使用 AI
- `source:lab0:timeline`（timeline）：missing；`lab0/实验过程清洗工具/简洁实验过程时间线.md`；SHA-256 `未提供哈希`；未知 行；原因：未找到该 Lab 的清洗材料；缺失不能解释为未操作或未使用 AI
- `source:lab0:terminal_qa`（terminal_qa）：available；`lab0/实验过程清洗工具/终端对话记录.md`；SHA-256 `d4f9823175ea9ecc5e7d4a6bad8a826bebd76a38ca18fb0e3d4f4614ac469c39`；774 行
- `source:lab0:command_statistics`（command_statistics）：available；`lab0/实验过程清洗工具/终端命令统计.md`；SHA-256 `a36291031f40dde7d9b523b3b0b570c8d7be2c279242d7163c04bab33a50af1a`；20 行
- `source:lab0:diff_report`（diff_report）：not_applicable；`未提供路径`；SHA-256 `未提供哈希`；未知 行；原因：lab0 的贡献识别仅评估实验过程材料，不使用代码差异报告

## 总体贡献画像

- 总体画像：无法判断贡献归属
- 画像置信度：弱
- 自动摘要：当前 Lab 缺少必需的已清洗过程或代码材料，未进行 AI/人工贡献归属。
- 证据引用：无
- 替代解释：资料缺失不表示未使用 AI、未进行人工操作或没有代码变化。
- 实验级局限：缺少必需的已清洗材料：source:lab0:timeline（missing：未找到该 Lab 的清洗材料；缺失不能解释为未操作或未使用 AI）

## 独立复核

- 复核状态：未执行独立 NIM 复核
- 复核总体决策：未提供
- 复核摘要：资料不足，未调用主分析或独立复核模型。
- 已复核单元：无
- 存在分歧的单元：无
- 未提供单元级独立复核记录。

## 贡献单元

无可复核的贡献单元。
## 全局局限

- 缺少必需的已清洗材料：source:lab0:timeline（missing：未找到该 Lab 的清洗材料；缺失不能解释为未操作或未使用 AI）
- 资料缺失只能限制结论，不能用于推断 AI 使用、人工贡献、诚信、违规或分数。

## 运行追溯

- Schema：`ai-human-contribution-assessment/v3`
- tool_version：3.2.0
- prompt_version：contribution-attribution-v3-nim-semantic-primary-v2
- validator_version：contribution-assessment-validator-v4
- completed_at：2026-09-21T02:19:04.274400+00:00
- 报告模板版本：6
