#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""批量生成 xv6 lab1--lab8 的学生源码差异 Markdown 报告。"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import shutil
import subprocess
import tempfile
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path
from urllib.parse import quote


SCRIPT_DIR = Path(__file__).resolve().parent
CLEANING_DIR = SCRIPT_DIR.parent
DEFAULT_REFERENCE_ROOT = CLEANING_DIR.parent / "xv6-ai-labs-km-无答案"
DEFAULT_SUBMISSIONS_ROOT = CLEANING_DIR / "操作系统实验数据记录"
DEFAULT_CLEANED_ROOT = CLEANING_DIR / "操作系统实验数据记录-已清洗"

LABS = tuple(f"lab{number}" for number in range(1, 9))
OWNER_FILE = ".replay_term_qa.json"
REPORT_FOLDER = "代码差异报告"
SUMMARY_FOLDER = "代码差异报告汇总"
SOURCE_FOLDERS = frozenset({"kernel", "xv6-user", "linker"})
SOURCE_SUFFIXES = frozenset({".c", ".h", ".s", ".ld", ".inc", ".sh", ".py", ".pl", ".mk"})
MAKEFILE_NAMES = frozenset({"makefile", "gnumakefile"})
STUDENT_NAME_RE = re.compile(
    r"^(?P<student_id>\d+)-(?P<name>.+?)(?:-实验提交)?-"
    r"(?P<date>\d{8})-(?P<time>\d{4})(?:-(?P<duplicate>\d+))?(?:\.tar\.gz)?$"
)


@dataclass
class Student:
    source: Path
    student_id: str
    name: str
    collected: str
    raw_time: str
    cleaned: Path | None = None
    selected: bool = True


@dataclass
class DiffEntry:
    path: str
    kind: str
    diff: str = ""
    additions: int = 0
    deletions: int = 0
    message: str = ""


@dataclass
class ReportResult:
    student: Student
    lab: str
    status: str
    message: str = ""
    report_path: Path | None = None
    scanned_files: int = 0
    unchanged_files: int = 0
    entries: list[DiffEntry] = field(default_factory=list)

    @property
    def additions(self) -> int:
        return sum(entry.additions for entry in self.entries)

    @property
    def deletions(self) -> int:
        return sum(entry.deletions for entry in self.entries)

    @property
    def changed_files(self) -> int:
        return sum(entry.kind in {"modified", "added", "deleted", "binary"}
                   for entry in self.entries)


def markdown_text(value: object) -> str:
    """转义报告元数据和 Markdown 表格单元格。"""
    text = str(value).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
    return re.sub(r"([\\`*_{}\[\]()#+!|~])", r"\\\1", text).replace("\n", "<br>").replace("\r", "")


def parse_student_name(name: str) -> Student | None:
    match = STUDENT_NAME_RE.fullmatch(name)
    if not match:
        return None
    info = match.groupdict()
    raw_time = f"{info['date']}-{info['time']}"
    try:
        collected = datetime.strptime(raw_time, "%Y%m%d-%H%M").strftime("%Y-%m-%d %H:%M")
    except ValueError:
        collected = f"{raw_time}（无法解析）"
    return Student(Path(), info["student_id"], info["name"], collected, raw_time)


def source_name_from_owner(value: object) -> str:
    """同时兼容 Windows 和 POSIX 形式的归属文件路径。"""
    return str(value).rstrip("/\\").replace("\\", "/").rsplit("/", 1)[-1]


def scan_students(submissions_root: Path, filters: list[str]) -> tuple[list[Student], list[str]]:
    students: list[Student] = []
    skipped: list[str] = []
    for directory in sorted(submissions_root.iterdir(), key=lambda path: path.name):
        if not directory.is_dir() or directory.is_symlink():
            continue
        parsed = parse_student_name(directory.name)
        if parsed is None:
            skipped.append(f"{directory.name}：目录名称不符合学生命名规则")
            continue
        parsed.source = directory.resolve()
        parsed.selected = not filters or parsed.student_id in filters or parsed.name in filters
        students.append(parsed)
    return students, skipped


def map_cleaned_students(students: list[Student], cleaned_root: Path) -> None:
    """依据现有清洗工具的归属文件，将原始提交精确对应到学生输出目录。"""
    by_source = {student.source.name: student for student in students}
    matches: dict[str, list[Path]] = {name: [] for name in by_source}
    if not cleaned_root.is_dir():
        return

    for directory in cleaned_root.iterdir():
        if not directory.is_dir() or directory.is_symlink():
            continue
        try:
            owner = json.loads((directory / OWNER_FILE).read_text(encoding="utf-8"))
        except (OSError, ValueError):
            continue
        if not isinstance(owner, dict) or "source" not in owner:
            continue
        source_name = source_name_from_owner(owner["source"])
        if source_name in matches:
            matches[source_name].append(directory)

    for source_name, locations in matches.items():
        if len(locations) == 1:
            by_source[source_name].cleaned = locations[0]

    # 早期清洗结果可能没有归属文件。仅接受“姓名完全相同且唯一”的目录名回退，
    # 避免将同名或多次采集的提交错误合并。
    for student in students:
        if student.cleaned is not None:
            continue
        if sum(other.name == student.name for other in students) != 1:
            continue
        candidates = [directory for directory in cleaned_root.iterdir()
                      if directory.is_dir() and not directory.is_symlink()
                      and directory.name == student.name]
        if len(candidates) == 1:
            student.cleaned = candidates[0]


def is_source_file(relative: Path) -> bool:
    if relative.name.casefold() in MAKEFILE_NAMES:
        return not relative.parts or relative.parts[0] in SOURCE_FOLDERS
    if len(relative.parts) == 1:
        return relative.name.casefold() in MAKEFILE_NAMES
    return relative.parts[0] in SOURCE_FOLDERS and relative.suffix.casefold() in SOURCE_SUFFIXES


def collect_source_files(lab_root: Path) -> dict[str, Path]:
    """返回允许比较的常规文件；不跟随符号链接，也不收集构建产物。"""
    files: dict[str, Path] = {}
    if not lab_root.is_dir() or lab_root.is_symlink():
        return files

    for root, directories, filenames in os.walk(lab_root, followlinks=False):
        current = Path(root)
        directories[:] = [name for name in directories if not (current / name).is_symlink()]
        for filename in filenames:
            candidate = current / filename
            if candidate.is_symlink() or not candidate.is_file():
                continue
            relative = candidate.relative_to(lab_root)
            if is_source_file(relative):
                files[relative.as_posix()] = candidate
    return files


def looks_binary(path: Path) -> bool:
    try:
        with path.open("rb") as stream:
            return b"\0" in stream.read(8192)
    except OSError:
        return False


def same_binary(left: Path | None, right: Path | None) -> bool:
    if left is None or right is None:
        return False
    try:
        if left.stat().st_size != right.stat().st_size:
            return False
        left_hash, right_hash = hashlib.sha256(), hashlib.sha256()
        for path, digest in ((left, left_hash), (right, right_hash)):
            with path.open("rb") as stream:
                for block in iter(lambda: stream.read(1024 * 1024), b""):
                    digest.update(block)
        return left_hash.digest() == right_hash.digest()
    except OSError:
        return False


def diff_line_counts(diff: str) -> tuple[int, int]:
    additions = deletions = 0
    for line in diff.splitlines():
        if line.startswith("+++") or line.startswith("---"):
            continue
        if line.startswith("+"):
            additions += 1
        elif line.startswith("-"):
            deletions += 1
    return additions, deletions


def normalize_diff_paths(diff: str, relative: str, left_exists: bool, right_exists: bool) -> str:
    """移除 --no-index 在绝对中文路径中产生的 Git 转义，仅改动补丁头。"""
    lines = diff.splitlines()
    for index, line in enumerate(lines):
        if line.startswith("@@"):
            break
        if line.startswith("diff --git "):
            lines[index] = f"diff --git 基准/{relative} 学生/{relative}"
        elif line.startswith("--- "):
            lines[index] = f"--- {'基准/' + relative if left_exists else '/dev/null'}"
        elif line.startswith("+++ "):
            lines[index] = f"+++ {'学生/' + relative if right_exists else '/dev/null'}"
    return "\n".join(lines)


def git_diff(relative: str, left: Path | None, right: Path | None,
             strict_whitespace: bool) -> tuple[str, str, int, int, str]:
    """返回状态、补丁、增删行数和错误信息；Git 返回 1 代表存在差异。"""
    old_path = str(left) if left is not None else os.devnull
    new_path = str(right) if right is not None else os.devnull
    command = ["git", "diff", "--no-index", "--no-ext-diff", "--unified=3",
               "--src-prefix=基准/", "--dst-prefix=学生/"]
    if not strict_whitespace:
        command.extend(["--ignore-space-change", "--ignore-space-at-eol"])
    command.extend(["--", old_path, new_path])
    try:
        completed = subprocess.run(command, capture_output=True, text=True, encoding="utf-8",
                                   errors="replace", check=False)
    except OSError as exc:
        return "error", "", 0, 0, str(exc)
    if completed.returncode == 0:
        return "unchanged", "", 0, 0, ""
    if completed.returncode == 1:
        patch = normalize_diff_paths(completed.stdout.rstrip(), relative, left is not None, right is not None)
        additions, deletions = diff_line_counts(patch)
        return "modified", patch, additions, deletions, ""
    error = completed.stderr.strip() or f"git diff 退出码 {completed.returncode}"
    return "error", "", 0, 0, error


def compare_lab(student: Student, lab: str, reference_root: Path,
                strict_whitespace: bool) -> ReportResult:
    reference_lab = reference_root / lab
    submission_lab = student.source / "labs" / lab
    if not reference_lab.is_dir():
        return ReportResult(student, lab, "失败", f"基准实验目录不存在：{reference_lab}")
    if not submission_lab.is_dir():
        return ReportResult(student, lab, "跳过", "未找到学生该实验的 labs/labN 目录")
    if student.cleaned is None:
        return ReportResult(student, lab, "跳过", "未找到对应的已清洗学生目录")

    reference_files = collect_source_files(reference_lab)
    submission_files = collect_source_files(submission_lab)
    paths = sorted(set(reference_files) | set(submission_files))
    result = ReportResult(student, lab, "成功", scanned_files=len(paths))
    for relative in paths:
        left, right = reference_files.get(relative), submission_files.get(relative)
        if (left and looks_binary(left)) or (right and looks_binary(right)):
            if same_binary(left, right):
                result.unchanged_files += 1
            else:
                kind = "added" if left is None else "deleted" if right is None else "binary"
                result.entries.append(DiffEntry(relative, kind, message="二进制文件不展示文本差异"))
            continue
        status, patch, additions, deletions, message = git_diff(relative, left, right, strict_whitespace)
        if status == "unchanged":
            result.unchanged_files += 1
        elif status == "error":
            result.entries.append(DiffEntry(relative, "error", message=message))
            result.status = "部分失败"
        else:
            kind = "added" if left is None else "deleted" if right is None else "modified"
            result.entries.append(DiffEntry(relative, kind, patch, additions, deletions))
    return result


def append_fenced_diff(lines: list[str], diff: str) -> None:
    longest = max((len(match.group(0)) for match in re.finditer(r"`+", diff)), default=0)
    fence = "`" * max(3, longest + 1)
    lines.extend([f"{fence}diff", diff, fence, ""])


def render_student_report(result: ReportResult, reference_root: Path,
                          strict_whitespace: bool) -> str:
    student = result.student
    lines = [f"# {result.lab} 源码差异报告", "",
             f"- 学号：{markdown_text(student.student_id)}",
             f"- 姓名：{markdown_text(student.name)}",
             f"- 数据采集时间：{markdown_text(student.collected)}",
             f"- 原始提交目录：`{student.source}`",
             f"- 基准目录：`{reference_root / result.lab}`",
             f"- 生成时间：{datetime.now().astimezone().strftime('%Y-%m-%d %H:%M:%S %z')}",
             "- 比较范围：kernel、xv6-user、linker 下的源码/脚本/构建配置，以及根目录 Makefile",
             f"- 空白符策略：{'精确比较' if strict_whitespace else '忽略空格、Tab 和行尾空白差异'}", "",
             "## 统计", "",
             "| 项目 | 数量 |", "| --- | ---: |",
             f"| 纳入比较的文件 | {result.scanned_files} |",
             f"| 一致文件 | {result.unchanged_files} |",
             f"| 有差异文件 | {result.changed_files} |",
             f"| 新增行 | {result.additions} |",
             f"| 删除行 | {result.deletions} |",
             f"| 处理异常文件 | {sum(entry.kind == 'error' for entry in result.entries)} |", ""]
    if not result.entries:
        lines.extend(["## 差异详情", "", "在所选源码范围内未发现差异。", ""])
        return "\n".join(lines)

    labels = {"modified": "修改", "added": "新增", "deleted": "删除",
              "binary": "二进制文件", "error": "处理异常"}
    lines.extend(["## 差异详情", ""])
    for entry in result.entries:
        lines.extend([f"### `{entry.path}`（{labels[entry.kind]}）", ""])
        if entry.diff:
            append_fenced_diff(lines, entry.diff)
        else:
            lines.extend([markdown_text(entry.message), ""])
    return "\n".join(lines)


def atomic_write(path: Path, text: str) -> None:
    if path.is_symlink():
        raise ValueError(f"拒绝覆盖符号链接：{path}")
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary: Path | None = None
    try:
        with tempfile.NamedTemporaryFile("w", encoding="utf-8", newline="\n", dir=path.parent,
                                         prefix=".lab-diff-", suffix=".tmp", delete=False) as stream:
            temporary = Path(stream.name)
            stream.write(text)
        os.replace(temporary, path)
    finally:
        if temporary is not None and temporary.exists():
            temporary.unlink()


def report_link(from_path: Path, to_path: Path) -> str:
    relative = os.path.relpath(to_path, from_path.parent).replace(os.sep, "/")
    return quote(relative, safe="/-_.")


def render_summary(lab: str, summary_path: Path, results: list[ReportResult], skipped: list[str],
                   strict_whitespace: bool) -> str:
    lines = [f"# {lab} 源码差异报告汇总", "",
             f"- 生成时间：{datetime.now().astimezone().strftime('%Y-%m-%d %H:%M:%S %z')}",
             "- 比较范围：kernel、xv6-user、linker 下的源码/脚本/构建配置，以及根目录 Makefile",
             f"- 空白符策略：{'精确比较' if strict_whitespace else '忽略空格、Tab 和行尾空白差异'}", "",
             "| 学号 | 姓名 | 状态 | 差异文件 | +行 | -行 | 报告/原因 |",
             "| --- | --- | --- | ---: | ---: | ---: | --- |"]
    for result in results:
        if result.report_path:
            link = report_link(summary_path, result.report_path)
            outcome = f"[查看报告]({link})"
        else:
            outcome = markdown_text(result.message)
        lines.append(
            f"| {markdown_text(result.student.student_id)} | {markdown_text(result.student.name)} | "
            f"{result.status} | {result.changed_files} | {result.additions} | {result.deletions} | {outcome} |"
        )
    if skipped:
        lines.extend(["", "## 未纳入处理的目录", ""])
        lines.extend(f"- {markdown_text(item)}" for item in skipped)
    lines.append("")
    return "\n".join(lines)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="批量生成 xv6 lab1--lab8 源码差异 Markdown 报告")
    selection = parser.add_mutually_exclusive_group(required=True)
    selection.add_argument("--lab", action="append", choices=LABS, help="指定实验；可重复使用")
    selection.add_argument("--all-labs", action="store_true", help="处理 lab1 至 lab8")
    parser.add_argument("--student", action="append", default=[], help="精确筛选学号或姓名；可重复使用")
    parser.add_argument("--reference-root", type=Path, default=DEFAULT_REFERENCE_ROOT)
    parser.add_argument("--submissions-root", type=Path, default=DEFAULT_SUBMISSIONS_ROOT)
    parser.add_argument("--cleaned-root", type=Path, default=DEFAULT_CLEANED_ROOT)
    parser.add_argument("--strict-whitespace", action="store_true", help="不忽略空白符差异")
    parser.add_argument("--dry-run", action="store_true", help="只显示处理计划，不写报告")
    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    reference_root = args.reference_root.resolve()
    submissions_root = args.submissions_root.resolve()
    cleaned_root = args.cleaned_root.resolve()
    if not shutil.which("git"):
        parser.error("未找到 git，无法生成差异")
    if not reference_root.is_dir():
        parser.error(f"基准根目录不存在：{reference_root}")
    if not submissions_root.is_dir():
        parser.error(f"学生提交根目录不存在：{submissions_root}")
    if not cleaned_root.is_dir():
        parser.error(f"已清洗根目录不存在：{cleaned_root}")

    labs = LABS if args.all_labs else tuple(dict.fromkeys(args.lab))
    students, skipped = scan_students(submissions_root, args.student)
    map_cleaned_students(students, cleaned_root)
    selected_students = [student for student in students if student.selected]
    all_results: list[ReportResult] = []
    for lab in labs:
        lab_results = [compare_lab(student, lab, reference_root, args.strict_whitespace)
                       for student in selected_students]
        all_results.extend(lab_results)
        if args.dry_run:
            print(f"[预演] {lab}：候选学生 {len(lab_results)} 人")
            for result in lab_results:
                print(f"  {result.student.student_id}-{result.student.name}：{result.status} {result.message}")
            continue
        for result in lab_results:
            if result.status not in {"成功", "部分失败"} or result.student.cleaned is None:
                continue
            report_path = result.student.cleaned / REPORT_FOLDER / f"{lab}.md"
            try:
                atomic_write(report_path, render_student_report(result, reference_root, args.strict_whitespace))
                result.report_path = report_path
            except OSError as exc:
                result.status = "失败"
                result.message = f"写入个人报告失败：{exc}"
        summary_path = cleaned_root / SUMMARY_FOLDER / f"{lab}.md"
        try:
            atomic_write(summary_path, render_summary(
                lab, summary_path, lab_results, skipped, args.strict_whitespace
            ))
        except OSError as exc:
            print(f"[失败] 无法写入汇总报告 {summary_path}：{exc}", file=os.sys.stderr)
            return 1
        print(f"[完成] {lab}：{summary_path}")

    return 1 if any(result.status in {"失败", "部分失败"} for result in all_results) else 0


if __name__ == "__main__":
    raise SystemExit(main())
