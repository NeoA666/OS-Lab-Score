"""Shared paths and direct, paired output for the three cleaning tools."""
from __future__ import annotations

import os
import re
import stat
import tempfile
from pathlib import Path

PERSON_VIEW = "按人分类"
LAB_VIEW = "按Lab分类"
SUMMARY_DIRECTORY = "汇总报告"
LOG_DIRECTORY = "运行日志"
PROCESS_TOOL = "实验过程清洗工具"
DIFF_TOOL = "代码差异报告工具"
AI_TOOL = "AI人工贡献识别工具"
LAYOUT_VERSION = 2
README_TITLE = "# 操作系统实验数据清洗结果"
README_TEXT = """# 操作系统实验数据清洗结果

两种分类保存相同的完整实体文件，由三个工具直接生成。原始数据和 xv6 基准只读。

## 浏览结果

- [按 Lab 分类](按Lab分类/)：先选 lab0–lab8，再选学生。
- [按人分类](按人分类/)：先选学生，再选 Lab。
- 无法确认 Lab 的过程材料位于两种分类的“其他”目录。
- [汇总报告](汇总报告/)与[运行日志](运行日志/)统一保存在根目录下。

```text
按Lab分类/lab1/学生姓名/
按人分类/学生姓名/lab1/
├─ 实验过程清洗工具/
│  ├─ 终端对话记录.md
│  ├─ 完整终端转写记录.md
│  ├─ 终端命令统计.md
│  ├─ Claude对话记录.md
│  ├─ 实验过程时间线.md
│  ├─ 简洁实验过程时间线.md
│  └─ 实验过程时间线.json
├─ 代码差异报告工具/
│  └─ 代码差异报告.md
└─ AI人工贡献识别工具/
   ├─ assessment_lab1.json
   ├─ 完整贡献识别报告_lab1.md
   └─ 教师贡献复核报告_lab1.md
```

只有实际产生结果的学生、Lab 和工具才有相应文件；不能将缺少材料理解为没有操作。
隐藏清单用于来源归属、增量处理和文件校验。

## 历史 AI 结果

附有“历史结果说明.md”的 AI 产物来自离线迁移，未重新调用模型或验证结论。
正文、旧证据路径和哈希保持历史含义，不代表本次清洗后的输入，也不作为新版有效缓存。
迁移记录可在“汇总报告”中查看。
"""


def _component(value: str) -> str:
    value = str(value)
    if not value or value in {".", ".."} or any(c in value for c in '/\\:'):
        raise ValueError(f"无效目录名称：{value!r}")
    return value


def lab_directory(lab: str) -> str:
    return lab if re.fullmatch(r"lab[0-8]", str(lab)) else "其他"


def ensure_layout(root: Path) -> None:
    root = Path(root)
    for relative in [PERSON_VIEW, SUMMARY_DIRECTORY, LOG_DIRECTORY,
                     *(f"{LAB_VIEW}/lab{i}" for i in range(9)), f"{LAB_VIEW}/其他"]:
        target = root / relative
        _validate_target(target)
        target.mkdir(parents=True, exist_ok=True)
    readme = root / "README.md"
    _validate_target(readme)
    if not readme.exists() or readme.read_text(encoding="utf-8").startswith(
            (README_TITLE, "# 终端实验数据批处理说明")):
        write_text_pair(readme, README_TEXT)


def tool_paths(root: Path, student: str, lab: str, tool: str) -> tuple[Path, Path]:
    root = Path(root)
    student, tool = _component(student), _component(tool)
    lab = lab_directory(lab)
    return (root / PERSON_VIEW / student / lab / tool,
            root / LAB_VIEW / lab / student / tool)


def mirror_path(path: Path) -> Path | None:
    path = Path(path)
    parts = path.parts
    # Use the deepest view marker so unrelated ancestor names cannot interfere.
    for index in range(len(parts) - 3, -1, -1):
        if parts[index] not in {PERSON_VIEW, LAB_VIEW}:
            continue
        first, second = parts[index + 1:index + 3]
        lab = second if parts[index] == PERSON_VIEW else first
        if lab not in {*(f"lab{i}" for i in range(9)), "其他"}:
            continue
        root = Path(*parts[:index])
        other = LAB_VIEW if parts[index] == PERSON_VIEW else PERSON_VIEW
        return root.joinpath(other, second, first, *parts[index + 3:])
    return None


def paired_paths(path: Path) -> tuple[Path, ...]:
    path = Path(path)
    mirror = mirror_path(path)
    return (path, mirror) if mirror is not None else (path,)


def _validate_target(path: Path) -> None:
    for part in (path, *path.parents):
        reparse = (part.exists() and getattr(part.lstat(), "st_file_attributes", 0)
                   & getattr(stat, "FILE_ATTRIBUTE_REPARSE_POINT", 0))
        if part.is_symlink() or reparse or (hasattr(part, "is_junction") and part.is_junction()):
            raise ValueError(f"拒绝通过链接写入或删除：{part}")
    if path.exists() and not (path.is_file() or path.is_dir()):
        raise ValueError(f"不是常规文件或目录：{path}")


def write_bytes_pair(path: Path, content: bytes) -> None:
    """Stage both files before replacement; callers commit manifests afterwards."""
    targets = paired_paths(path)
    staged: list[tuple[Path, Path]] = []
    try:
        for target in targets:
            _validate_target(target)
            if target.is_dir():
                raise IsADirectoryError(target)
        for target in targets:
            target.parent.mkdir(parents=True, exist_ok=True)
            with tempfile.NamedTemporaryFile(dir=target.parent, prefix=".layout-",
                                             suffix=".tmp", delete=False) as stream:
                temporary = Path(stream.name)
                staged.append((temporary, target))
                stream.write(content)
        for temporary, target in staged:
            os.replace(temporary, target)
    finally:
        for temporary, _ in staged:
            temporary.unlink(missing_ok=True)


def write_text_pair(path: Path, text: str) -> None:
    write_bytes_pair(path, text.encode("utf-8"))


def unlink_pair(path: Path) -> None:
    targets = paired_paths(path)
    for target in targets:
        _validate_target(target)
        if target.is_dir():
            raise IsADirectoryError(target)
    for target in targets:
        target.unlink(missing_ok=True)


def pair_matches(path: Path) -> bool:
    targets = paired_paths(path)
    try:
        for target in targets:
            _validate_target(target)
        return all(target.is_file() for target in targets) and (
            len(targets) == 1 or targets[0].read_bytes() == targets[1].read_bytes())
    except (OSError, ValueError):
        return False
