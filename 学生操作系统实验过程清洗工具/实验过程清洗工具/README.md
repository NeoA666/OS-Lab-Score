# 实验过程清洗工具

重放学生 `term/*.out.gz` 与可选的 `*.tim.gz` 终端录像，提取 Shell 命令、终端对话、完整转写、Claude 对话和按 lab 分类的实验过程时间线。工具只读取录像和日志，不执行学生命令。

## 安装

需要 Python 3.9+。在本目录执行：

```bash
python3 -m pip install -r requirements.txt
```

## 运行

默认读取仓库根的 `操作系统实验数据记录/`，并写入同级 `操作系统实验数据记录-已清洗/`：

```bash
python3 replay_term_qa.py
python3 replay_term_qa.py --student 2406080102
python3 replay_term_qa.py --timeline-only
python3 generate_readable_timeline.py
```

可用位置参数指定其他输入根，`--output` 指定输出根，`--force` 忽略增量缓存重建选中的学生。每个学生至少需要一个常规 `term/*.out.gz`；缺少录像、损坏计时文件、符号链接或不安全目录会被独立报告，不会生成伪造的空结果。
