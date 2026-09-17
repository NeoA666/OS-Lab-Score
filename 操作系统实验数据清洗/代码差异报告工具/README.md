# xv6 源码差异报告工具

批量比较学生提交的 `lab1` 至 `lab8` 源码与 `xv6-ai-labs-km-无答案` 基准，并生成便于评分审阅的 Markdown 差异报告。工具只读取基准和学生提交，不执行学生的 Makefile、脚本或代码。

## 功能与比较范围

- 支持 `lab1` 至 `lab8`；`lab0` 不在比较范围内。
- 比较 `kernel/`、`xv6-user/`、`linker/` 下的 C、头文件、汇编、链接脚本、脚本和构建配置，以及实验根目录的 `Makefile`/`GNUmakefile`。
- 跳过文档、构建产物、版本控制目录、系统元数据和符号链接。
- 默认忽略空格、Tab 和行尾空白造成的差异；`--strict-whitespace` 可改为精确比较。
- 通过 `git diff --no-index` 生成统一格式 diff，因此基准目录和学生目录不需要是 Git 仓库。
- 依据清洗结果中的 `.replay_term_qa.json` 将学生原始提交精确关联到对应的已清洗目录；仅在姓名唯一且目录名完全一致时才使用兼容旧数据的回退匹配。

个人报告包含文件与增删行统计，以及每个新增、删除或修改文件的完整 diff。跨学生汇总会标记成功、跳过和处理失败的原因。

## 默认数据位置

从本目录运行时，默认使用以下目录：

```text
../../xv6-ai-labs-km-无答案/              基准实验根目录
../操作系统实验数据记录/                  原始学生提交根目录
../操作系统实验数据记录-已清洗/           清洗结果根目录
```

原始提交应位于 `<学生提交根目录>/<学号>-<姓名>-YYYYMMDD-HHMM>/labs/labN/`。请先运行上级 `实验过程清洗工具/`，使清洗目录能够与原始提交建立对应关系。

## 环境准备

需要 Python 3.9+ 和可在 `PATH` 中调用的 Git。脚本使用 Python 标准库与 `git diff --no-index`，不需要安装第三方 Python 包。

下面的命令均在本目录执行。Windows 可使用 `python`，其他环境可按本机配置使用 `python3`。

## 常用命令

生成全部实验的报告：

```bash
python -B generate_lab_diff_reports.py --all-labs
```

只生成一个实验，或重复 `--lab` 选择多个实验：

```bash
python -B generate_lab_diff_reports.py --lab lab1
python -B generate_lab_diff_reports.py --lab lab1 --lab lab3
```

仅处理指定学生。学号或姓名必须精确匹配，`--student` 可重复使用：

```bash
python -B generate_lab_diff_reports.py --lab lab1 --student 2406080102
python -B generate_lab_diff_reports.py --all-labs --student "戴炜" --student 2406080111
```

预演会生成处理结果供终端查看，但不会写入个人报告或汇总报告：

```bash
python -B generate_lab_diff_reports.py --all-labs --dry-run
```

显示空白符差异：

```bash
python -B generate_lab_diff_reports.py --lab lab1 --strict-whitespace
```

使用非默认目录：

```bash
python -B generate_lab_diff_reports.py --lab lab1 --reference-root "../../xv6-ai-labs-km-无答案" --submissions-root "../操作系统实验数据记录" --cleaned-root "../操作系统实验数据记录-已清洗"
```

## 输出

正常比较完成的个人报告写入：

```text
操作系统实验数据记录-已清洗/<学生>/代码差异报告/labN.md
```

每个实验都会在清洗根目录写入一份汇总：

```text
操作系统实验数据记录-已清洗/代码差异报告汇总/labN.md
```

如果学生没有 `labs/labN` 目录、未找到对应的已清洗目录或基准目录缺失，汇总报告会记录为跳过或失败。二进制文件与单文件比较异常也会明确标记，其他学生和实验仍会继续处理。

## 验证

在本目录运行测试：

```bash
python -B -m unittest -v test_generate_lab_diff_reports
```

项目背景和设计约定见 [背景信息.md](背景信息.md)。
