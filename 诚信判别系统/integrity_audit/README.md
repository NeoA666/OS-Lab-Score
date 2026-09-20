# 学生 / Lab 诚信审核 Agent

针对单个学生、单个 `labN` 的受控诚信审核循环。它只读取经过清洗的材料，受宿主规则、证据哈希、行范围和数据边界校验，生成完整审核报告与教师复核报告。

## 安装

需要 Python 3.11+。本项目目前只使用标准库，可直接运行或安装为命令：

```bash
python3 -m pip install -e .
```

生产审核需要由服务器注入 `NVIDIA_API_KEY`。可选配置为 `NVIDIA_API_BASE_URL`、`NVIDIA_MODEL`、`NVIDIA_MAX_TOKENS`、`NVIDIA_CONNECT_TIMEOUT_SECONDS`、`NVIDIA_READ_TIMEOUT_SECONDS`、`NVIDIA_TEMPERATURE` 与 `NVIDIA_TOP_P`。

## 运行

```bash
python3 -m audit_agent students
python3 -m audit_agent inspect --student 2406080118 --lab lab0
python3 -m audit_agent audit --student 2406080118 --lab lab0 --dry-run
python3 -m audit_agent batch --lab lab0 --resume
```

默认数据根为仓库根的 `操作系统实验数据记录-已清洗/`。可使用 `--data-root`、`--policy`、`--output-dir`、`--teacher-output-dir` 与 `--trace-dir` 覆盖。

```text
诚信审核报告草稿/<学生>/<labN>/完整诚信审核报告.md
教师复核报告草稿/<学生>/<labN>/教师诚信复核报告.md
诚信审核运行日志/<学生>/<labN>/assessment.json
```

所有高风险标签仍需教师核实。材料缺失只会降低可见性，不会被解释为学生未操作、使用 AI 或存在违规。
