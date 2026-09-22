# 抓取、清洗与 DIFF 工具：服务器目录结构说明

本文适用于本部署包中的学生数据抓取工具、实验过程清洗工具和代码差异报告工具，不包含 AI/人工贡献识别阶段。服务器部署根目录固定为 `/public/home/zhaoxia/桌面/NeoA`；本文中的部署根目录均指此路径，解压后的包内容直接放在该目录下。建议使用 Python 3.11+；DIFF 工具另需系统 `git` 命令可用。

## 部署根目录

解压部署包后，保持以下代码目录的相对层级。三个工具会根据此层级定位共享模块和默认数据目录；不要只单独移动某个脚本。

```text
/public/home/zhaoxia/桌面/NeoA/
├── 服务器部署目录结构说明-抓取清洗DIFF.md
├── 学生数据抓取工具/
│   ├── sync_xv6_submissions.py
│   ├── requirements.txt
│   └── README.md
└── 学生操作系统实验过程清洗工具/
    ├── output_layout.py
    ├── 实验过程清洗工具/
    │   ├── replay_term_qa.py
    │   ├── replay_engine.py
    │   ├── replay_parallel.py
    │   ├── timeline_alignment.py
    │   ├── timeline_reports.py
    │   ├── generate_readable_timeline.py
    │   ├── requirements.txt
    │   └── README.md
    └── 代码差异报告工具/
        ├── generate_lab_diff_reports.py
        └── README.md
```

包内还保留了三个工具各自的测试和补充说明文档；测试不是服务器运行时的必需文件。DIFF 工具只使用 Python 标准库和系统 Git，因此没有单独的 Python `requirements.txt`。

## 数据目录

默认情况下，原始数据、无答案基准和清洗结果都放在部署根目录，与两个工具目录同级：

```text
/public/home/zhaoxia/桌面/NeoA/
├── xv6-ai-labs-km-无答案/             # DIFF 的无答案参考源码，需部署者提供
│   ├── lab0/
│   ├── lab1/
│   ├── ...
│   └── lab8/
├── 操作系统实验数据记录/               # 抓取工具生成；也可预先放入原始提交
│   └── <学号>-<姓名>-<YYYYMMDD-HHMM>/
│       ├── .xv6-sync-source.json       # 抓取工具生成，DIFF 用它验证提交身份
│       ├── labs/
│       │   └── labN/
│       │       ├── kernel/
│       │       ├── xv6-user/
│       │       ├── linker/
│       │       └── Makefile             # 若该提交包含
│       ├── term/
│       │   ├── <录像ID>.out.gz          # 清洗必需：每位学生至少一条
│       │   └── <录像ID>.tim.gz          # 可选：对应 timing 文件
│       └── logs/
│           └── events.jsonl             # 可选：补充时间线采集日志佐证
└── 操作系统实验数据记录-已清洗/         # 清洗工具生成，必须可写
    ├── 按人分类/
    ├── 按Lab分类/
    ├── 汇总报告/
    ├── 运行日志/
    ├── .replay-cache/
    └── .lab-diff-cache/
```

`xv6-ai-labs-km-无答案/` 的 `lab0` 至 `lab8` 应分别放置对应基准源码。DIFF 会比较每个 Lab 下 `kernel/`、`xv6-user/`、`linker/` 中受支持的源码，以及根目录 Makefile；不会执行学生源码、Makefile 或脚本。

抓取工具从 `OSLAB_REMOTE_ROOT/YYYYMMDD/index.jsonl` 发现提交，并将归档解压到部署根的 `操作系统实验数据记录/`。`.xv6-sync-source.json` 由抓取工具写入；不要手工伪造。若原始数据由其他方式复制到服务器，DIFF 仍要求每个学生目录有有效的抓取来源标记。

清洗工具读取 `term/*.out.gz`、可选的同名 `*.tim.gz`，以及可选的 `logs/events.jsonl`。它会在 `操作系统实验数据记录-已清洗/按人分类/<学生目录>/` 写入 `.replay_term_qa.json` 归属清单。DIFF 依赖该清单确认清洗已完成且来源对应当前提交，因此应先成功完成清洗，再运行 DIFF；不要手动创建或编辑这些归属清单。

## 安装与运行

在服务器上进入指定部署根目录，创建虚拟环境并安装抓取、清洗所需依赖：

```bash
cd "/public/home/zhaoxia/桌面/NeoA"
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install -r "学生数据抓取工具/requirements.txt"
python3 -m pip install -r "学生操作系统实验过程清洗工具/实验过程清洗工具/requirements.txt"
git --version
```

DIFF 依赖 `git` 可从 `PATH` 调用。原始数据目录在首次抓取时创建；无答案基准目录需由部署者准备；清洗输出目录由清洗工具创建。运行账户需要读取原始数据和基准，并对部署根及清洗输出有相应写入权限。

抓取前，通过服务器密钥管理或服务环境配置提供连接变量，不要将密码写入源码、README、压缩包或命令历史：

```bash
export OSLAB_SSH_HOST="提交服务器地址"
export OSLAB_SSH_PORT="22"                 # 可选，默认 22
export OSLAB_SSH_USERNAME="提交服务器用户名"
export OSLAB_SSH_PASSWORD="提交服务器密码"
export OSLAB_REMOTE_ROOT="远端归档根目录"
```

按顺序运行：

```bash
python3 "学生数据抓取工具/sync_xv6_submissions.py"
python3 "学生操作系统实验过程清洗工具/实验过程清洗工具/replay_term_qa.py"
python3 "学生操作系统实验过程清洗工具/代码差异报告工具/generate_lab_diff_reports.py" --all-labs
```

若原始提交已通过其他方式放入 `操作系统实验数据记录/`，可以跳过抓取阶段。若数据根目录不采用默认位置，清洗工具支持位置参数和 `--output`；DIFF 工具支持 `--submissions-root`、`--cleaned-root` 和 `--reference-root`。抓取工具的输出位置固定为其部署根目录下的 `操作系统实验数据记录/`，因此部署时应按上面的相对目录摆放。

## 输出与保留

清洗和 DIFF 的正式报告写入 `操作系统实验数据记录-已清洗/`，按人视图和按 Lab 视图成对保存；缓存分别位于 `.replay-cache/` 与 `.lab-diff-cache/`。这些都是派生结果，可按项目的数据保留策略备份或重建。不要把原始学生数据、无答案基准、服务器密钥或本机虚拟环境加入部署源码包。
