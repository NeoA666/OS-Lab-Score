# 操作系统实验

- [数据采集说明](学生操作系统实验数据爬取/使用说明.md)
- [已处理数据与报告](操作系统实验数据记录-已清洗/README.md)
- [历史验证记录](历史验证记录/README.md)

在本文件夹内运行处理工具：

```powershell
python replay_term_qa.py "学生操作系统实验数据爬取/操作系统实验数据记录" --output "操作系统实验数据记录-已清洗"
```

仅更新时间线时，添加 `--timeline-only`。整理目录本身没有重新生成学生实验报告。

工具测试：

```powershell
python -m unittest test_replay_term_qa test_timeline test_timeline_alignment test_timeline_reports
```

终端解析依赖统一放在上级 `公共依赖/pylib`，脚本会自动读取。数据采集工具有独立依赖说明，见其使用说明及 requirements.txt。
