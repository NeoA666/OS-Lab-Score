"""Shared, paired output layout for the cleaning pipeline."""
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
README_TITLE = "# 操作系统实验数据清洗结果"


def lab_directory(lab: str) -> str:
    return lab if re.fullmatch(r"lab[0-8]", str(lab)) else "其他"


def _component(value: str) -> str:
    value = str(value)
    if not value or value in {".", ".."} or any(char in value for char in "/\\:"):
        raise ValueError(f"无效目录名称：{value!r}")
    return value


def _validate_target(path: Path) -> None:
    for part in (path, *path.parents):
        attributes = getattr(part.lstat(), "st_file_attributes", 0) if part.exists() else 0
        reparse = attributes & getattr(stat, "FILE_ATTRIBUTE_REPARSE_POINT", 0)
        if part.is_symlink() or reparse or (hasattr(part, "is_junction") and part.is_junction()):
            raise ValueError(f"拒绝通过链接写入或删除：{part}")


def ensure_layout(root: Path) -> None:
    root = Path(root)
    for relative in (
        PERSON_VIEW, SUMMARY_DIRECTORY, LOG_DIRECTORY,
        *(f"{LAB_VIEW}/lab{number}" for number in range(9)), f"{LAB_VIEW}/其他",
    ):
        target = root / relative
        _validate_target(target)
        target.mkdir(parents=True, exist_ok=True)
    readme = root / "README.md"
    if not readme.exists():
        readme.write_text(
            f"{README_TITLE}\n\n结果按[人](按人分类/)和[Lab](按Lab分类/)两种方式浏览。\n",
            encoding="utf-8",
        )


def tool_paths(root: Path, student: str, lab: str, tool: str) -> tuple[Path, Path]:
    root = Path(root)
    student, tool = _component(student), _component(tool)
    lab = lab_directory(lab)
    return (
        root / PERSON_VIEW / student / lab / tool,
        root / LAB_VIEW / lab / student / tool,
    )


def mirror_path(path: Path) -> Path | None:
    path = Path(path)
    parts = path.parts
    for index in range(len(parts) - 3, -1, -1):
        view = parts[index]
        if view not in {PERSON_VIEW, LAB_VIEW}:
            continue
        first, second = parts[index + 1:index + 3]
        lab = second if view == PERSON_VIEW else first
        if lab not in {*(f"lab{number}" for number in range(9)), "其他"}:
            continue
        root = Path(*parts[:index])
        if view == PERSON_VIEW:
            return root / LAB_VIEW / second / first / Path(*parts[index + 3:])
        return root / PERSON_VIEW / second / first / Path(*parts[index + 3:])
    return None


def paired_paths(path: Path) -> tuple[Path, ...]:
    mirror = mirror_path(path)
    return (Path(path), mirror) if mirror is not None else (Path(path),)


def write_bytes_pair(path: Path, content: bytes) -> None:
    staged: list[tuple[Path, Path]] = []
    replaced: list[Path] = []
    previous: dict[Path, bytes | None] = {}
    try:
        for target in paired_paths(path):
            _validate_target(target)
            target.parent.mkdir(parents=True, exist_ok=True)
            if target.exists():
                if not target.is_file():
                    raise ValueError(f"目标不是普通文件：{target}")
                previous[target] = target.read_bytes()
            else:
                previous[target] = None
            with tempfile.NamedTemporaryFile(dir=target.parent, prefix=".layout-", suffix=".tmp", delete=False) as stream:
                temporary = Path(stream.name)
                stream.write(content)
            staged.append((temporary, target))
        for temporary, target in staged:
            os.replace(temporary, target)
            replaced.append(target)
    except Exception:
        # Restore every target already replaced in this publication.  The
        # rollback uses same-directory temporary files, so a failed mirror
        # update cannot leave the two classification views divergent.
        for target in reversed(replaced):
            old = previous.get(target)
            rollback: Path | None = None
            try:
                if old is None:
                    target.unlink(missing_ok=True)
                else:
                    with tempfile.NamedTemporaryFile(
                        dir=target.parent, prefix=".layout-rollback-", suffix=".tmp", delete=False
                    ) as stream:
                        rollback = Path(stream.name)
                        stream.write(old)
                    os.replace(rollback, target)
                    rollback = None
            except Exception:
                # Preserve the original publication error; callers still get
                # a non-zero result and can surface the target path.
                pass
            finally:
                if rollback is not None:
                    rollback.unlink(missing_ok=True)
        raise
    finally:
        for temporary, _ in staged:
            temporary.unlink(missing_ok=True)


def write_text_pair(path: Path, text: str) -> None:
    write_bytes_pair(path, text.encode("utf-8"))


def unlink_pair(path: Path) -> None:
    targets = paired_paths(path)
    previous: dict[Path, bytes | None] = {}
    removed: list[Path] = []
    try:
        for target in targets:
            _validate_target(target)
            if target.exists():
                if not target.is_file():
                    raise ValueError(f"目标不是普通文件：{target}")
                previous[target] = target.read_bytes()
            else:
                previous[target] = None
        for target in targets:
            if target.exists():
                target.unlink()
                removed.append(target)
    except Exception:
        for target in reversed(removed):
            old = previous.get(target)
            rollback: Path | None = None
            try:
                if old is not None:
                    with tempfile.NamedTemporaryFile(
                        dir=target.parent, prefix=".layout-unlink-rollback-", suffix=".tmp", delete=False
                    ) as stream:
                        rollback = Path(stream.name)
                        stream.write(old)
                    os.replace(rollback, target)
                    rollback = None
            except Exception:
                pass
            finally:
                if rollback is not None:
                    rollback.unlink(missing_ok=True)
        raise


def pair_matches(path: Path) -> bool:
    targets = paired_paths(path)
    try:
        return all(target.is_file() for target in targets) and (len(targets) == 1 or targets[0].read_bytes() == targets[1].read_bytes())
    except OSError:
        return False
