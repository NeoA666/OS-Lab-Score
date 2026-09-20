# AI/人工贡献识别工具

依据已清洗的时间线、终端对话、命令统计和代码差异，调用 NVIDIA NIM 生成带来源范围与哈希的贡献证据。输出是供后续复核使用的材料，不是作者身份、违规、处分或分数结论。

## 前提

需要 Python 3.9+ 和服务器环境变量 `NVIDIA_API_KEY`。可选变量包括 `NVIDIA_API_BASE_URL`、`NVIDIA_MODEL`、`NVIDIA_MAX_TOKENS`、`NVIDIA_CONNECT_TIMEOUT_SECONDS` 和 `NVIDIA_READ_TIMEOUT_SECONDS`。

## 运行

```bash
python3 identify_contributions.py inspect --student 2406080118 --lab lab0
python3 identify_contributions.py analyze --student 2406080118 --lab lab1 --dry-run
python3 identify_contributions.py analyze --student 2406080118 --lab lab1
python3 identify_contributions.py batch --lab lab1 --jobs 1
```

默认读取仓库根的 `操作系统实验数据记录-已清洗/`；使用 `--cleaned-root` 可覆盖。`lab1` 至 `lab8` 缺少任一规定材料时写为 `insufficient_data`，不会推测 AI 或人工贡献。

每个学生的输出写入 `AI人工贡献识别/`，包含 `assessment/assessment_labN.json`、完整贡献识别报告和教师贡献复核报告；汇总与运行日志写入已清洗根。API 密钥、原始模型响应和模型思维内容不会写入这些文件。
