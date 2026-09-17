# xv6 源码差异报告工具

批量比较学生提交的 `lab1` 至 `lab8` 源码与 `xv6-ai-labs-km-无答案` 基准，并将 Markdown 报告写入对应的已清洗学生目录。

在本目录执行：

```bash
python3 generate_lab_diff_reports.py --all-labs
```

常用命令：

```bash
# 只处理 lab3
python3 generate_lab_diff_reports.py --lab lab3

# 只处理指定学生
python3 generate_lab_diff_reports.py --all-labs --student 2406080106

# 预演，不写入报告
python3 generate_lab_diff_reports.py --all-labs --dry-run

# 连空白符差异也显示
python3 generate_lab_diff_reports.py --lab lab1 --strict-whitespace
```

个人报告位置为 `操作系统实验数据记录-已清洗/<学生>/代码差异报告/labN.md`，汇总位置为 `操作系统实验数据记录-已清洗/代码差异报告汇总/labN.md`。
