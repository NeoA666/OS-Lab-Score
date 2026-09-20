# xv6 源码差异报告工具

将学生 `labs/lab1` 至 `labs/lab8` 与仓库根的 `xv6-ai-labs-km-无答案/` 对照，生成可供评分审阅的统一 Markdown 差异报告。工具使用 `git diff --no-index`，不会执行学生 Makefile、脚本或代码。

## 前提

需要 Python 3.9+ 和可从 `PATH` 调用的 Git。默认目录均由脚本位置定位：

```text
../../xv6-ai-labs-km-无答案/
../../操作系统实验数据记录/
../../操作系统实验数据记录-已清洗/
```

## 运行

```bash
python3 generate_lab_diff_reports.py --all-labs
python3 generate_lab_diff_reports.py --lab lab3 --student 2406080102
python3 generate_lab_diff_reports.py --all-labs --dry-run
```

`--reference-root`、`--submissions-root`、`--cleaned-root` 可覆盖默认位置。默认忽略空白符差异；`--strict-whitespace` 启用精确比较。

个人报告写入 `<已清洗根>/<学生>/代码差异报告/labN.md`，汇总写入 `<已清洗根>/代码差异报告汇总/labN.md`。报告清单只允许工具替换自己登记的文件，人工文件不会被清理。
