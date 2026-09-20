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
import stat
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
REPORT_MANIFEST = ".lab_diff_reports.json"
REPORT_MANIFEST_VERSION = 1
SOURCE_FOLDERS = frozenset({"kernel", "xv6-user", "linker"})
SOURCE_SUFFIXES = frozenset({".c", ".h", ".s", ".ld", ".inc", ".sh", ".py", ".pl", ".mk"})
MAKEFILE_NAMES = frozenset({"makefile", "gnumakefile"})
VCS_DIRECTORIES = frozenset({".git", ".hg", ".svn"})
# xv6 的每个 lab Makefile 都通过 `perl xv6-user/usys.pl > xv6-user/usys.S`
# 生成这个汇编文件；评分应比较其源生成器 usys.pl，而不是构建副产物。
GENERATED_SOURCE_PATHS = frozenset({"xv6-user/usys.s"})
REPORT_ARTIFACTS = frozenset(f"{lab}.md" for lab in LABS)
GIT_EMPTY_PATH = "/dev/null"
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


def source_identity(value: object) -> str | None:
    """Return a normalized full-path identity for an owner manifest source."""
    if not isinstance(value, (str, os.PathLike)):
        return None
    text = os.fspath(value).strip()
    if not text:
        return None
    try:
        # Normalize both separator forms before resolving so manifests written on
        # Windows and POSIX use the same representation on their native host.
        path = Path(text.replace("\\", os.sep).replace("/", os.sep)).resolve(strict=False)
    except OSError:
        path = Path(text.replace("\\", os.sep).replace("/", os.sep))
    return os.path.normcase(os.path.normpath(str(path)))


def student_matches_filters(student: Student, filters: list[str]) -> bool:
    return not filters or student.student_id in filters or student.name in filters


def source_basename(value: object) -> str:
    """Return a path basename while accepting owner manifests from either OS."""
    if not isinstance(value, str):
        return ""
    return value.rstrip("/\\").replace("\\", "/").rsplit("/", 1)[-1]


def is_link_like(path: Path) -> bool:
    """Treat Windows junctions as links as well as ordinary symbolic links."""
    path = Path(path)
    junction = getattr(path, "is_junction", None)
    try:
        if path.is_symlink() or bool(junction and junction()):
            return True
        # Path.is_junction() was added after Python 3.9. On older supported
        # Windows versions, the reparse-point attribute covers junctions too.
        attributes = getattr(os.lstat(path), "st_file_attributes", 0)
        reparse_point = getattr(stat, "FILE_ATTRIBUTE_REPARSE_POINT", 0)
        return bool(reparse_point and attributes & reparse_point)
    except FileNotFoundError:
        return False
    except OSError:
        return True


def scan_students(submissions_root: Path, filters: list[str]) -> tuple[list[Student], list[str]]:
    students: list[Student] = []
    skipped: list[str] = []
    for directory in sorted(submissions_root.iterdir(), key=lambda path: path.name):
        if not directory.is_dir() or is_link_like(directory):
            continue
        parsed = parse_student_name(directory.name)
        if parsed is None:
            skipped.append(f"{directory.name}：目录名称不符合学生命名规则")
            continue
        parsed.source = directory.resolve()
        parsed.selected = student_matches_filters(parsed, filters)
        students.append(parsed)
    return students, skipped


def map_cleaned_students(students: list[Student], cleaned_root: Path) -> None:
    """依据现有清洗工具的归属文件，将原始提交精确对应到学生输出目录。"""
    by_source = {source_identity(student.source): student for student in students}
    matches: dict[str, list[Path]] = {key: [] for key in by_source if key is not None}
    if not cleaned_root.is_dir():
        return

    for directory in cleaned_root.iterdir():
        if not directory.is_dir() or is_link_like(directory):
            continue
        try:
            owner = json.loads((directory / OWNER_FILE).read_text(encoding="utf-8"))
        except (OSError, ValueError):
            continue
        if not isinstance(owner, dict) or "source" not in owner:
            continue
        source_key = source_identity(owner["source"])
        if source_key in matches:
            matches[source_key].append(directory)

    for source_key, locations in matches.items():
        if len(locations) == 1:
            by_source[source_key].cleaned = locations[0]

    # 早期清洗结果可能没有归属文件。仅接受“姓名完全相同且唯一”且确实没有
    # 归属文件的目录名回退；有效但不匹配的归属信息绝不能被姓名覆盖。
    for student in students:
        if student.cleaned is not None:
            continue
        if sum(other.name == student.name for other in students) != 1:
            continue
        candidates = [directory for directory in cleaned_root.iterdir()
                      if directory.is_dir() and not is_link_like(directory)
                      and directory.name == student.name
                      and not is_link_like(directory / OWNER_FILE)
                      and not (directory / OWNER_FILE).exists()]
        if len(candidates) == 1:
            student.cleaned = candidates[0]


def is_source_file(relative: Path) -> bool:
    relative_key = relative.as_posix().casefold()
    if relative_key in GENERATED_SOURCE_PATHS:
        return False
    if len(relative.parts) == 1:
        return relative.name.casefold() in MAKEFILE_NAMES
    if relative.name.casefold() in MAKEFILE_NAMES:
        return relative.parts[0].casefold() in SOURCE_FOLDERS
    return (relative.parts[0].casefold() in SOURCE_FOLDERS
            and relative.suffix.casefold() in SOURCE_SUFFIXES)


def collect_source_files(lab_root: Path) -> dict[str, Path]:
    """返回允许比较的常规文件；不跟随符号链接，也不收集构建产物。"""
    files: dict[str, Path] = {}
    if not lab_root.is_dir() or is_link_like(lab_root):
        return files

    for root, directories, filenames in os.walk(lab_root, followlinks=False):
        current = Path(root)
        directories[:] = sorted(
            name for name in directories
            if name.casefold() not in VCS_DIRECTORIES and not is_link_like(current / name)
        )
        for filename in filenames:
            candidate = current / filename
            if is_link_like(candidate) or not candidate.is_file():
                continue
            relative = candidate.relative_to(lab_root)
            if is_source_file(relative):
                files[relative.as_posix()] = candidate
    return files


def looks_binary(path: Path) -> bool:
    try:
        with path.open("rb") as stream:
            for block in iter(lambda: stream.read(1024 * 1024), b""):
                if b"\0" in block:
                    return True
            return False
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
        if line.startswith("+++ ") or line.startswith("--- "):
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
    old_path = str(left) if left is not None else GIT_EMPTY_PATH
    new_path = str(right) if right is not None else GIT_EMPTY_PATH
    command = ["git", "diff", "--no-index", "--no-ext-diff", "--unified=3",
               "--src-prefix=基准/", "--dst-prefix=学生/"]
    if not strict_whitespace:
        command.extend([
            "--ignore-space-change",
            "--ignore-space-at-eol",
            "--ignore-blank-lines",
        ])
    command.extend(["--", old_path, new_path])
    try:
        completed = subprocess.run(command, capture_output=True, text=True, encoding="utf-8",
                                   errors="replace", check=False)
    except OSError as exc:
        return "error", "", 0, 0, str(exc)
    if completed.returncode == 0:
        return "unchanged", "", 0, 0, ""
    if completed.returncode == 1:
        raw_patch = completed.stdout.rstrip()
        if not raw_patch:
            error = completed.stderr.strip() or "git diff 返回差异状态但没有生成补丁"
            return "error", "", 0, 0, error
        patch = normalize_diff_paths(raw_patch, relative, left is not None, right is not None)
        additions, deletions = diff_line_counts(patch)
        return "modified", patch, additions, deletions, ""
    error = completed.stderr.strip() or f"git diff 退出码 {completed.returncode}"
    return "error", "", 0, 0, error


def compare_lab(student: Student, lab: str, reference_root: Path,
                strict_whitespace: bool) -> ReportResult:
    reference_lab = reference_root / lab
    submission_lab = student.source / "labs" / lab
    if not reference_lab.is_dir() or is_link_like(reference_lab):
        return ReportResult(student, lab, "失败", f"基准实验目录不存在：{reference_lab}")
    if not submission_lab.is_dir() or is_link_like(submission_lab):
        return ReportResult(student, lab, "跳过", "未找到学生该实验的 labs/labN 目录")
    if student.cleaned is None:
        return ReportResult(student, lab, "跳过", "未找到对应的已清洗学生目录")

    reference_files = collect_source_files(reference_lab)
    submission_files = collect_source_files(submission_lab)
    paths = sorted(set(reference_files) | set(submission_files))
    result = ReportResult(student, lab, "成功", scanned_files=len(paths))
    errors: list[str] = []
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
            errors.append(f"{relative}: {message}")
        else:
            kind = "added" if left is None else "deleted" if right is None else "modified"
            result.entries.append(DiffEntry(relative, kind, patch, additions, deletions))
    result.message = "；".join(errors)
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
             f"- 空白符策略：{'精确比较' if strict_whitespace else '忽略空格、Tab、空白行和行尾空白差异'}", "",
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
    if is_link_like(path) or is_link_like(path.parent):
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


def student_report_directory(student: Student) -> Path:
    """Return the owned report directory only when it remains inside the student output."""
    if student.cleaned is None:
        raise ValueError("学生没有已清洗输出目录")
    cleaned = student.cleaned.resolve()
    report_dir = student.cleaned / REPORT_FOLDER
    if is_link_like(report_dir):
        raise ValueError(f"拒绝使用符号链接报告目录：{report_dir}")
    if cleaned not in report_dir.resolve().parents:
        raise ValueError(f"报告目录越出学生输出目录：{report_dir}")
    return report_dir


def _read_report_manifest(path: Path) -> dict | None:
    if is_link_like(path):
        return None
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, TypeError, ValueError):
        return None
    return value if isinstance(value, dict) else None


def _report_manifest_owned_by(manifest: object, student: Student) -> bool:
    return (
        isinstance(manifest, dict)
        and manifest.get("tool") == "generate_lab_diff_reports"
        and source_identity(manifest.get("source")) == source_identity(student.source)
    )


def _owned_report_artifact(report_dir: Path, name: object) -> Path | None:
    if not isinstance(name, str) or name not in REPORT_ARTIFACTS:
        return None
    target = report_dir / name
    if is_link_like(target):
        return None
    try:
        if report_dir.resolve() not in target.resolve().parents:
            return None
    except OSError:
        return None
    return target


def _declared_report_artifacts(report_dir: Path, manifest: object) -> set[str] | None:
    """Return a valid same-source manifest's registered report names only."""
    if manifest is None:
        return set()
    if not isinstance(manifest, dict):
        return None
    artifacts = manifest.get("artifacts")
    if (
        not isinstance(artifacts, list)
        or not all(isinstance(name, str) for name in artifacts)
        or len(artifacts) != len(set(artifacts))
    ):
        return None
    declared = set()
    for name in artifacts:
        if _owned_report_artifact(report_dir, name) is None:
            return None
        declared.add(name)
    return declared


def writable_student_report_directory(student: Student) -> Path:
    """Reject a foreign or malformed manifest before any report is replaced."""
    report_dir = student_report_directory(student)
    manifest_path = report_dir / REPORT_MANIFEST
    if is_link_like(manifest_path):
        raise ValueError(f"报告目录的归属清单是符号链接：{manifest_path}")
    existing = _read_report_manifest(manifest_path)
    if manifest_path.exists() and not _report_manifest_owned_by(existing, student):
        raise ValueError(f"报告目录已有其他来源或无效归属清单：{manifest_path}")
    if manifest_path.exists() and _declared_report_artifacts(report_dir, existing) is None:
        raise ValueError(f"报告目录的归属清单产物无效：{manifest_path}")
    return report_dir


def writable_student_report_path(student: Student, lab: str) -> Path:
    """Return a report target without taking over an unregistered same-name file."""
    report_dir = writable_student_report_directory(student)
    target = report_dir / f"{lab}.md"
    if is_link_like(target):
        raise ValueError(f"报告路径是符号链接：{target}")
    manifest = _read_report_manifest(report_dir / REPORT_MANIFEST)
    declared = _declared_report_artifacts(report_dir, manifest)
    if target.exists():
        if not _report_manifest_owned_by(manifest, student) or target.name not in (declared or set()):
            raise ValueError(f"报告路径已有未登记内容：{target}")
        if not target.is_file():
            raise ValueError(f"报告路径不是普通文件：{target}")
    return target


def update_student_report_manifest(student: Student, results: list[ReportResult],
                                   selected_labs: frozenset[str]) -> None:
    """Register current reports and remove stale reports only for selected labs."""
    report_dir = writable_student_report_directory(student)
    manifest_path = report_dir / REPORT_MANIFEST
    existing = _read_report_manifest(manifest_path)
    owned = _report_manifest_owned_by(existing, student)
    declared_artifacts = _declared_report_artifacts(report_dir, existing)
    if declared_artifacts is None:
        raise ValueError(f"报告目录的归属清单产物无效：{manifest_path}")
    artifacts = set(declared_artifacts)
    if not any(result.report_path is not None or result.status == "跳过" for result in results):
        return
    for result in results:
        artifact = f"{result.lab}.md"
        if result.lab not in selected_labs:
            continue
        if result.report_path is not None:
            artifacts.add(artifact)
        elif result.status == "跳过":
            # A selected lab disappeared from the raw submission. Its old
            # report would otherwise remain visible as current scoring input.
            artifacts.discard(artifact)

    if not owned and not any(result.report_path is not None for result in results):
        return

    previous_artifacts = declared_artifacts
    for name in previous_artifacts - artifacts:
        if Path(name).stem not in selected_labs:
            continue
        target = _owned_report_artifact(report_dir, name)
        if target is not None and target.is_file():
            target.unlink()

    atomic_write(manifest_path, json.dumps({
        "tool": "generate_lab_diff_reports",
        "schema_version": REPORT_MANIFEST_VERSION,
        "source": str(student.source),
        "artifacts": sorted(artifacts),
    }, ensure_ascii=False, indent=2) + "\n")


def orphaned_report_results(cleaned_root: Path, labs: tuple[str, ...], filters: list[str],
                            known_sources: set[str]) -> dict[str, list[ReportResult]]:
    """Surface registered reports whose original submission is no longer scannable.

    The old reports are intentionally retained because the raw input required to
    recreate them is gone. Returning failed results makes the stale state visible
    in each selected lab's summary and produces a non-zero batch exit status.
    """
    by_lab = {lab: [] for lab in labs}
    if not cleaned_root.is_dir() or is_link_like(cleaned_root):
        return by_lab

    for directory in sorted(cleaned_root.iterdir(), key=lambda path: path.name):
        if not directory.is_dir() or is_link_like(directory):
            continue
        report_dir = directory / REPORT_FOLDER
        if not report_dir.is_dir() or is_link_like(report_dir):
            continue
        manifest_path = report_dir / REPORT_MANIFEST
        manifest = _read_report_manifest(manifest_path)
        if not isinstance(manifest, dict) or manifest.get("tool") != "generate_lab_diff_reports":
            continue
        source = manifest.get("source")
        source_key = source_identity(source)
        if source_key is None or source_key in known_sources:
            continue
        parsed = parse_student_name(source_basename(source))
        if parsed is None:
            student = Student(Path(str(source)), "未知", directory.name, "未知", "未知", directory)
        else:
            student = parsed
            student.source = Path(str(source))
            student.cleaned = directory
        if not student_matches_filters(student, filters):
            continue
        artifacts = manifest.get("artifacts")
        if not isinstance(artifacts, list):
            continue
        for lab in labs:
            artifact = f"{lab}.md"
            report_path = report_dir / artifact
            if (artifact in artifacts and report_path.is_file()
                    and not is_link_like(report_path)):
                by_lab[lab].append(ReportResult(
                    student, lab, "失败",
                    f"原始提交目录不存在或无法匹配；已保留旧个人报告：{report_path}"
                ))
    return by_lab


def report_link(from_path: Path, to_path: Path) -> str:
    relative = os.path.relpath(to_path, from_path.parent).replace(os.sep, "/")
    return quote(relative, safe="/-_.")


def render_summary(lab: str, summary_path: Path, results: list[ReportResult], skipped: list[str],
                   strict_whitespace: bool) -> str:
    lines = [f"# {lab} 源码差异报告汇总", "",
             f"- 生成时间：{datetime.now().astimezone().strftime('%Y-%m-%d %H:%M:%S %z')}",
             "- 比较范围：kernel、xv6-user、linker 下的源码/脚本/构建配置，以及根目录 Makefile",
             f"- 空白符策略：{'精确比较' if strict_whitespace else '忽略空格、Tab、空白行和行尾空白差异'}", "",
             "| 学号 | 姓名 | 状态 | 差异文件 | +行 | -行 | 报告/原因 |",
             "| --- | --- | --- | ---: | ---: | ---: | --- |"]
    for result in results:
        if result.report_path:
            link = report_link(summary_path, result.report_path)
            outcome = f"[查看报告]({link})"
            if result.message:
                outcome += "<br>" + markdown_text(result.message)
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
    selected_labs = frozenset(labs)
    students, skipped = scan_students(submissions_root, args.student)
    map_cleaned_students(students, cleaned_root)
    selected_students = [student for student in students if student.selected]
    known_sources = {key for student in students if (key := source_identity(student.source)) is not None}
    orphaned_by_lab = orphaned_report_results(cleaned_root, labs, args.student, known_sources)
    if args.student and not selected_students and not any(orphaned_by_lab.values()):
        print(f"[失败] 未找到匹配 --student 的原始提交或已登记报告：{', '.join(args.student)}",
              file=os.sys.stderr)
        return 1
    all_results: list[ReportResult] = []
    for lab in labs:
        lab_results = [compare_lab(student, lab, reference_root, args.strict_whitespace)
                       for student in selected_students]
        lab_results.extend(orphaned_by_lab[lab])
        all_results.extend(lab_results)
        if args.dry_run:
            print(f"[预演] {lab}：候选学生 {len(lab_results)} 人")
            for result in lab_results:
                print(f"  {result.student.student_id}-{result.student.name}：{result.status} {result.message}")
            continue
        for result in lab_results:
            if result.status != "成功" or result.student.cleaned is None:
                continue
            try:
                report_path = writable_student_report_path(result.student, lab)
                atomic_write(report_path, render_student_report(result, reference_root, args.strict_whitespace))
                result.report_path = report_path
            except (OSError, ValueError) as exc:
                result.status = "失败"
                result.message = f"写入个人报告失败：{exc}"
        for student in selected_students:
            student_results = [result for result in lab_results if result.student is student]
            if student.cleaned is None or not student_results:
                continue
            try:
                update_student_report_manifest(student, student_results, selected_labs)
            except (OSError, ValueError) as exc:
                target = student_results[0]
                target.status = "部分失败" if target.status in {"成功", "部分失败"} else "失败"
                target.message = f"更新个人报告清单失败：{exc}"
        summary_path = cleaned_root / SUMMARY_FOLDER / f"{lab}.md"
        try:
            atomic_write(summary_path, render_summary(
                lab, summary_path, lab_results, skipped, args.strict_whitespace
            ))
        except (OSError, ValueError) as exc:
            print(f"[失败] 无法写入汇总报告 {summary_path}：{exc}", file=os.sys.stderr)
            return 1
        print(f"[完成] {lab}：{summary_path}")

    return 1 if any(result.status in {"失败", "部分失败"} for result in all_results) else 0


if __name__ == "__main__":
    raise SystemExit(main())
