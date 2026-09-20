# xv6 源码差异报告工具

批量比较学生提交的 `lab0` 至 `lab8` 源码与 `xv6-ai-labs-km-无答案` 基准，并生成便于评分审阅的 Markdown 差异报告。工具只读取基准和学生提交，不执行学生的 Makefile、脚本或代码。

## 功能与比较范围

- 支持 `lab0` 至 `lab8`：每个实验都把学生提交的 `labs/labN` 与基准根目录下对应的 `labN` 逐一比较，`lab0` 也遵循同一对应规则。
- 比较 `kernel/`、`xv6-user/`、`linker/` 下的 C、头文件、手写汇编、链接脚本、脚本和构建配置，以及实验根目录的 `Makefile`/`GNUmakefile`。
- 跳过文档、构建产物、`.git`/`.hg`/`.svn` 目录、系统元数据、符号链接和 Windows junction。xv6 各 lab 的 Makefile 通过 `usys.pl` 生成 `xv6-user/usys.S`，因此比较 `usys.pl` 而明确排除该生成汇编文件。
- 默认忽略空格、Tab、空白行和行尾空白造成的差异；`--strict-whitespace` 可改为精确比较。
- 通过 `git diff --no-index` 生成统一格式 diff，因此基准目录和学生目录不需要是 Git 仓库。
- 依据清洗结果中的 `.replay_term_qa.json` 的规范化完整原始路径关联对应的已清洗目录；仅在姓名唯一且目录名完全一致时才使用兼容旧数据的回退匹配。

个人报告包含文件与增删行统计，以及每个新增、删除或修改文件的完整 diff。跨学生汇总会标记成功、跳过和处理失败的原因。已有同名 `代码差异报告.md` 只有被同源 `.lab_diff_reports.json` 登记后才会被替换或清理；未登记的人工文件保持不变。

## 默认数据位置

从本目录运行时，默认使用以下目录：

```text
../../xv6-ai-labs-km-无答案/              基准实验根目录
../操作系统实验数据记录/                  原始学生提交根目录
../操作系统实验数据记录-已清洗/           清洗结果根目录
```

原始提交应位于 `<学生提交根目录>/<学号>-<姓名>-YYYYMMDD-HHMM>/labs/labN/`。请先运行上级 `实验过程清洗工具/`，使 `按人分类/<学生>/.replay_term_qa.json` 能够与原始提交建立对应关系。工具通过上级共享模块 `output_layout.py` 直接双写输出。

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

仅处理指定学生。学号或姓名必须精确匹配，`--student` 可重复使用；若既没有匹配的原始提交，也没有匹配的已登记旧报告，命令会失败且不写报告：

```bash
python -B generate_lab_diff_reports.py --lab lab1 --student 2406080102
python -B generate_lab_diff_reports.py --all-labs --student "戴炜" --student 2406080111
```

预演会生成处理结果供终端查看，但不会写入个人报告、汇总报告或报告清单：

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

正常比较完成的个人报告由工具直接同步写入两种分类（正文完全相同），无需后处理：

```text
操作系统实验数据记录-已清洗/按人分类/<学生>/labN/代码差异报告工具/代码差异报告.md
操作系统实验数据记录-已清洗/按Lab分类/labN/<学生>/代码差异报告工具/代码差异报告.md
```

每个 Lab 的工具目录内 `.lab_diff_reports.json` 仅登记本工具为该完整原始提交写入的 `代码差异报告.md`。当本次选中的实验目录从原始提交中消失时，工具只删除清单中对应的过期个人报告；未选中的 lab 报告会保留。使用 `--all-labs` 才会按当前全部实验输入清理所有 lab。单文件比较失败时保留旧报告，避免把未完成比较伪装成无差异。

每个实验的汇总统一写入“汇总报告/代码差异报告汇总”文件夹：

```text
操作系统实验数据记录-已清洗/汇总报告/代码差异报告汇总/代码差异报告汇总-labN.md
操作系统实验数据记录-已清洗/运行日志/代码差异报告工具-时间.log
```

如果学生没有 `labs/labN` 目录、未找到对应的已清洗目录或基准目录缺失，汇总报告会记录为跳过或失败。若整个原始提交目录消失但本工具清单仍登记个人报告，工具会保留旧报告、在选中 lab 的汇总中记录失败并返回非零退出码。二进制文件与单文件比较异常也会明确标记，其他学生和实验仍会继续处理。新增或删除文件通过 Git 兼容的 `/dev/null` 侧生成补丁；若 Git 返回差异状态却没有补丁，报告会标记该文件处理异常。

## 验证

在本目录运行测试：

```bash
python -B -m unittest -v test_generate_lab_diff_reports
```

项目背景和设计约定见 [背景信息.md](背景信息.md)。
