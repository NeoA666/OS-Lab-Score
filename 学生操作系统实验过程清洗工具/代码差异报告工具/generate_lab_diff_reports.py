#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""批量生成 xv6 lab0--lab8 的学生源码差异 Markdown 报告。"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import shutil
import stat
import subprocess
import sys
import tempfile
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path, PurePosixPath, PureWindowsPath
from urllib.parse import quote


SCRIPT_DIR = Path(__file__).resolve().parent
CLEANING_DIR = SCRIPT_DIR.parent
sys.path.insert(0, str(CLEANING_DIR))
from output_layout import (
    DIFF_TOOL,
    ensure_layout,
    mirror_path,
    pair_matches,
    unlink_pair,
    write_text_pair,
)

DEFAULT_REFERENCE_ROOT = CLEANING_DIR.parent / "xv6-ai-labs-km-无答案"
DEFAULT_SUBMISSIONS_ROOT = CLEANING_DIR.parent / "操作系统实验数据记录"
DEFAULT_CLEANED_ROOT = CLEANING_DIR.parent / "操作系统实验数据记录-已清洗"

LABS = tuple(f"lab{number}" for number in range(0, 9))
OWNER_FILE = ".replay_term_qa.json"
SOURCE_MARKER = ".xv6-sync-source.json"
REPORT_FOLDER = DIFF_TOOL
REPORT_NAME = "代码差异报告.md"
SUMMARY_FOLDER = Path("汇总报告") / "代码差异报告汇总"
REPORT_MANIFEST = ".lab_diff_reports.json"
REPORT_MANIFEST_VERSION = 1
CACHE_FOLDER = ".lab-diff-cache"
CACHE_OWNER = "generate_lab_diff_reports"
CACHE_SCHEMA_VERSION = 1
MISSING_LAB_FINGERPRINT = hashlib.sha256(b"lab-diff:missing-lab:v1").hexdigest()
# Keep these signatures explicit.  Changing the source selection, hashing or
# git invocation must invalidate analysis entries; changing report prose only
# needs a render pass.
ANALYZER_VERSION = "source-diff-analyzer-v2"
RENDER_VERSION = "source-diff-render-v2"
SOURCE_FOLDERS = frozenset({"kernel", "xv6-user", "linker"})
SOURCE_SUFFIXES = frozenset({".c", ".h", ".s", ".ld", ".inc", ".sh", ".py", ".pl", ".mk"})
MAKEFILE_NAMES = frozenset({"makefile", "gnumakefile"})
VCS_DIRECTORIES = frozenset({".git", ".hg", ".svn"})
# xv6 的每个 lab Makefile 都通过 `perl xv6-user/usys.pl > xv6-user/usys.S`
# 生成这个汇编文件；评分应比较其源生成器 usys.pl，而不是构建副产物。
GENERATED_SOURCE_PATHS = frozenset({"xv6-user/usys.s"})
REPORT_ARTIFACTS = frozenset({REPORT_NAME})
GIT_EMPTY_PATH = "/dev/null"
STUDENT_NAME_RE = re.compile(
    r"^(?P<student_id>[^-]+)-(?P<name>.+?)(?:-实验提交)?-"
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
    source_reference: str = ""
    archive_sha256: str = ""
    source_marker: dict | None = None


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
    cache_state: str = "REBUILT"
    source_fingerprint: str = ""
    reference_fingerprint: str = ""
    analyzer_signature: str = ""
    render_signature: str = ""
    missing_lab: bool = False

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


@dataclass
class SourceSnapshot:
    """A deterministic description of one allowed source tree."""

    files: dict[str, dict[str, object]] = field(default_factory=dict)
    fingerprint: str = ""
    error: str = ""


def _stable_json(value: object) -> str:
    """Serialize cache metadata deterministically across platforms."""
    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":"))


def _sha256_bytes(value: bytes) -> str:
    return hashlib.sha256(value).hexdigest()


def render_signature() -> str:
    return _sha256_bytes(_stable_json({
        "version": RENDER_VERSION,
        "report_name": REPORT_NAME,
        "report_folder": REPORT_FOLDER,
        "summary_folder": SUMMARY_FOLDER.as_posix(),
    }).encode("utf-8"))


def git_version() -> str:
    """Return the Git version used by analysis, without making it a dependency."""
    try:
        completed = subprocess.run(
            ["git", "--version"], capture_output=True, text=True,
            encoding="utf-8", errors="replace", check=False,
        )
    except OSError:
        return "unavailable"
    return completed.stdout.strip() or completed.stderr.strip() or "unknown"


def git_diff_options(strict_whitespace: bool) -> list[str]:
    """Return the exact static Git arguments used for one file comparison."""
    options = [
        "diff", "--no-index", "--no-ext-diff", "--unified=3",
        "--src-prefix=基准/", "--dst-prefix=学生/",
    ]
    if not strict_whitespace:
        options.extend([
            "--ignore-space-change",
            "--ignore-space-at-eol",
            "--ignore-blank-lines",
        ])
    return options


def analyzer_signature(strict_whitespace: bool, version: str | None = None) -> str:
    """Build the analysis signature that is part of every cache validation."""
    if version is None:
        version = git_version()
    return _sha256_bytes(_stable_json({
        "version": ANALYZER_VERSION,
        "git_version": version,
        "strict_whitespace": bool(strict_whitespace),
        "git_options": git_diff_options(strict_whitespace),
        "source_folders": sorted(SOURCE_FOLDERS),
        "source_suffixes": sorted(SOURCE_SUFFIXES),
        "makefile_names": sorted(MAKEFILE_NAMES),
        "generated_paths": sorted(GENERATED_SOURCE_PATHS),
    }).encode("utf-8"))


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


def source_identity_from(value: object, *bases: Path) -> str | None:
    """Resolve an owner source relative to declared roots before the CWD.

    Cleaning manifests intentionally store portable repository-relative paths.
    Resolving those paths against the process working directory made reports
    disappear when the tool was launched elsewhere, so callers pass the
    submission/repository roots explicitly.
    """
    if not isinstance(value, (str, os.PathLike)):
        return None
    raw = os.fspath(value).strip()
    if not raw:
        return None
    normalized = raw.replace("\\", os.sep).replace("/", os.sep)
    candidate = Path(normalized)
    if candidate.is_absolute():
        return source_identity(candidate)
    for base in bases:
        try:
            resolved = (Path(base) / candidate).resolve(strict=False)
        except OSError:
            continue
        if resolved.exists():
            return source_identity(resolved)
    # Preserve deterministic matching for a not-yet-created path.  The first
    # declared base is the contract for relative sources.
    if bases:
        return source_identity(Path(bases[0]) / candidate)
    return source_identity(candidate)


def _valid_archive_sha(value: object) -> bool:
    return isinstance(value, str) and bool(re.fullmatch(r"[0-9a-fA-F]{64}", value))


def read_source_marker(directory: Path) -> tuple[dict | None, str | None]:
    """Read and validate a sync marker, returning a diagnostic on failure."""
    marker_path = Path(directory) / SOURCE_MARKER
    if is_link_like(marker_path):
        return None, f"来源标记是符号链接：{SOURCE_MARKER}"
    try:
        marker = json.loads(marker_path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        return None, f"缺少来源标记：{SOURCE_MARKER}"
    except (OSError, UnicodeDecodeError, ValueError) as exc:
        return None, f"来源标记损坏：{exc}"
    if not isinstance(marker, dict):
        return None, "来源标记不是 JSON 对象"
    required = {
        "version", "student_id", "name", "archive_name", "remote_path",
        "submission_time", "archive_size", "archive_sha256",
    }
    missing = sorted(required - marker.keys())
    if missing:
        return None, f"来源标记缺少字段：{','.join(missing)}"
    if marker.get("version") != 1:
        return None, f"来源标记版本无效：{marker.get('version')!r}"
    if not isinstance(marker.get("student_id"), str) or not marker["student_id"]:
        return None, "来源标记学号无效"
    if not isinstance(marker.get("name"), str) or not marker["name"]:
        return None, "来源标记姓名无效"
    if not isinstance(marker.get("archive_name"), str) or not marker["archive_name"]:
        return None, "来源标记归档名无效"
    if not isinstance(marker.get("remote_path"), str) or not marker["remote_path"]:
        return None, "来源标记远程路径无效"
    if not isinstance(marker.get("submission_time"), str) or not marker["submission_time"]:
        return None, "来源标记提交时间无效"
    try:
        datetime.fromisoformat(marker["submission_time"].replace("Z", "+00:00"))
    except ValueError:
        return None, "来源标记提交时间格式无效"
    if type(marker.get("archive_size")) is not int or marker["archive_size"] < 0:
        return None, "来源标记归档大小无效"
    if not _valid_archive_sha(marker.get("archive_sha256")):
        return None, "来源标记归档 SHA-256 无效"
    return marker, None


def validate_student_marker(student: Student, marker: dict) -> str | None:
    """Check marker identity against the local directory name."""
    if marker.get("student_id") != student.student_id:
        return "来源标记学号与目录名不一致"
    if marker.get("name") != student.name:
        return "来源标记姓名与目录名不一致"
    archive_name = str(marker.get("archive_name", ""))
    # The archive name is an audit field.  It must identify the same student,
    # and its timestamp must agree with the local synchronized directory.
    archive_match = re.match(
        r"^(?P<student_id>[^-]+)-(?P<name>.+)-实验提交-(?P<stamp>\d{8}-\d{4})(?:-\d+)?\.tar\.gz$",
        archive_name,
    )
    if archive_match is None:
        return "来源标记归档名格式无效"
    if archive_match.group("student_id") != student.student_id:
        return "来源标记归档学号与目录名不一致"
    if archive_match.group("name") != student.name:
        return "来源标记归档姓名与目录名不一致"
    if archive_match.group("stamp") != student.raw_time:
        return "来源标记提交时间与目录名不一致"
    student.archive_sha256 = str(marker["archive_sha256"]).lower()
    student.source_marker = marker
    return None


def source_reference(source: Path, submissions_root: Path) -> str:
    """Return a portable submission label for manifests and reports."""
    try:
        root = Path(submissions_root).resolve()
        return (Path(root.name) / source.resolve().relative_to(root)).as_posix()
    except ValueError:
        return source.name


def display_path(path: Path, root: Path) -> str:
    """Render a path relative to a declared tool root when possible."""
    try:
        return Path(path).resolve().relative_to(Path(root).resolve()).as_posix()
    except ValueError:
        return Path(path).name


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


def assert_safe_path(path: Path, message: str = "拒绝通过链接访问路径") -> None:
    """Reject a path whose existing component is a symlink or reparse point."""
    target = Path(path)
    for component in (target, *target.parents):
        if is_link_like(component):
            raise ValueError(f"{message}：{target}")


def scan_students(
    submissions_root: Path,
    filters: list[str],
    require_marker: bool = True,
) -> tuple[list[Student], list[str]]:
    """Return one validated current submission per student.

    The synchronizer writes a source marker for every current directory.  A
    malformed or missing marker is diagnostic data, never a reason to guess
    from a directory name.  ``require_marker=False`` remains available for
    low-level callers that only need to exercise the filename parser.
    """
    students: list[Student] = []
    skipped: list[str] = []
    candidates_by_id: dict[str, list[Student]] = {}
    directory_names_by_id: dict[str, list[str]] = {}
    if not submissions_root.is_dir() or is_link_like(submissions_root):
        return students, [f"[source-scan] 提交根目录不可用：{submissions_root}"]
    try:
        directories = sorted(submissions_root.iterdir(), key=lambda path: path.name)
    except OSError as exc:
        return students, [f"[source-scan] 无法扫描提交根目录：{exc}"]
    for directory in directories:
        if is_link_like(directory):
            parsed_link = parse_student_name(directory.name)
            if parsed_link is not None:
                directory_names_by_id.setdefault(parsed_link.student_id, []).append(directory.name)
            skipped.append(f"[source-scan] {directory.name}：拒绝符号链接、junction 或其他不安全路径")
            continue
        if not directory.is_dir():
            continue
        parsed = parse_student_name(directory.name)
        if parsed is None:
            skipped.append(f"[source-scan] {directory.name}：目录名称不符合学生命名规则")
            continue
        directory_names_by_id.setdefault(parsed.student_id, []).append(directory.name)
        parsed.source = directory.resolve()
        parsed.source_reference = source_reference(parsed.source, submissions_root)
        marker, marker_error = read_source_marker(parsed.source)
        if marker_error is not None:
            if require_marker:
                skipped.append(f"[source-scan] {directory.name}：{marker_error}")
                continue
        elif marker is not None:
            identity_error = validate_student_marker(parsed, marker)
            if identity_error is not None:
                if require_marker:
                    skipped.append(f"[source-scan] {directory.name}：{identity_error}")
                    continue
            else:
                parsed.source_marker = marker
        parsed.selected = student_matches_filters(parsed, filters)
        candidates_by_id.setdefault(parsed.student_id, []).append(parsed)

    for student_id, names_for_id in sorted(directory_names_by_id.items()):
        if len(names_for_id) > 1:
            names = ", ".join(names_for_id)
            skipped.append(f"[source-scan] 学号 {student_id} 存在多个当前提交目录：{names}")
            continue
        candidates = candidates_by_id.get(student_id, [])
        if not candidates:
            continue
        students.append(candidates[0])
    return students, skipped


def map_cleaned_students(
    students: list[Student], cleaned_root: Path, submissions_root: Path | None = None
) -> list[str]:
    """依据现有清洗工具的归属文件，将原始提交精确对应到学生输出目录。"""
    diagnostics: list[str] = []
    cleaned_root = cleaned_root / "按人分类"
    try:
        assert_safe_path(cleaned_root, "已清洗按人视图包含链接或 junction")
    except ValueError as exc:
        return [f"[cleaned-scan] {exc}"]
    if submissions_root is None:
        submissions_root = students[0].source.parent if students else cleaned_root.parent.parent
    repository_root = Path(submissions_root).resolve().parent
    by_source = {
        key: student
        for student in students
        for key in (
            source_identity(student.source),
            student.source_reference,
            source_identity_from(student.source_reference, repository_root, submissions_root),
        )
        if key is not None
    }
    matches: dict[str, list[Path]] = {key: [] for key in by_source}
    if not cleaned_root.is_dir():
        diagnostics.extend(
            f"[cleaned-scan] {student.student_id}-{student.name}：未找到对应的已清洗学生目录"
            for student in students if student.selected
        )
        return diagnostics

    try:
        cleaned_directories = sorted(cleaned_root.iterdir(), key=lambda path: path.name)
    except OSError as exc:
        diagnostics.append(f"[cleaned-scan] 无法扫描已清洗按人视图：{exc}")
        return diagnostics
    for directory in cleaned_directories:
        if not directory.is_dir() or is_link_like(directory):
            continue
        owner_path = directory / OWNER_FILE
        try:
            assert_safe_path(owner_path, "终端清洗归属路径包含链接或 junction")
        except ValueError:
            continue
        try:
            owner = json.loads(owner_path.read_text(encoding="utf-8"))
        except (OSError, ValueError):
            continue
        if (
            not isinstance(owner, dict)
            or owner.get("tool") != "replay_term_qa"
            or owner.get("layout") != "dual-view-v2"
            or owner.get("status") != "complete"
            or owner.get("cache_format_version") != 2
            or not isinstance(owner.get("source"), str)
            or not owner["source"].strip()
            or not _valid_archive_sha(owner.get("input_fingerprint"))
            or not _valid_archive_sha(owner.get("processor_signature"))
            or not isinstance(owner.get("summary"), dict)
            or not isinstance(owner["summary"].get("errors"), list)
            or owner["summary"].get("errors")
        ):
            diagnostics.append(f"[cleaned-scan] {directory.name}：终端清洗归属文件未完成或格式无效")
            continue
        owner_keys = {
            source_identity(owner["source"]),
            source_identity_from(owner["source"], repository_root, submissions_root),
            str(owner["source"]).replace("\\", "/")
            if isinstance(owner["source"], str) else None,
        }
        for source_key in owner_keys & matches.keys():
            matches[source_key].append(directory)

    duplicate_messages: set[str] = set()
    ambiguous_students: set[str] = set()
    for source_key, locations in matches.items():
        unique_locations = sorted(set(locations), key=lambda path: str(path))
        if len(unique_locations) == 1:
            by_source[source_key].cleaned = unique_locations[0]
        elif len(unique_locations) > 1:
            student = by_source[source_key]
            ambiguous_students.add(student.student_id)
            duplicate_messages.add(
                f"[cleaned-scan] 学生 {student.student_id}-{student.name} 存在多个相同来源的已清洗目录："
                + ", ".join(str(path) for path in unique_locations)
            )
    diagnostics.extend(sorted(duplicate_messages))
    diagnostics.extend(
        f"[cleaned-scan] {student.student_id}-{student.name}：未找到唯一的已清洗学生目录"
        for student in students
        if student.selected and student.cleaned is None
        and student.student_id not in ambiguous_students
    )
    return diagnostics



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


def collect_source_files(lab_root: Path, raise_errors: bool = False) -> dict[str, Path]:
    """返回允许比较的常规文件；不跟随符号链接，也不收集构建产物。"""
    files: dict[str, Path] = {}
    try:
        assert_safe_path(lab_root, "源码路径包含链接或 junction")
    except ValueError:
        return files
    if not lab_root.is_dir() or is_link_like(lab_root):
        return files

    try:
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
    except OSError:
        if raise_errors:
            raise
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


def source_snapshot(lab_root: Path) -> SourceSnapshot:
    """Hash only the selected source files and return a stable tree digest."""
    lab_root = Path(lab_root)
    try:
        assert_safe_path(lab_root, "源码路径包含链接或 junction")
    except ValueError as exc:
        return SourceSnapshot(error=str(exc))
    if not lab_root.is_dir() or is_link_like(lab_root):
        return SourceSnapshot(error=f"源码目录不存在或不安全：{lab_root}")
    # A skipped link must not silently turn into a successful snapshot: the
    # caller needs a diagnostic and must avoid caching a partial tree.
    try:
        for root, directories, filenames in os.walk(lab_root, followlinks=False):
            current = Path(root)
            for name in (*directories, *filenames):
                candidate = current / name
                if is_link_like(candidate):
                    return SourceSnapshot(error=f"源码路径包含链接或 junction：{candidate}")
    except OSError as exc:
        return SourceSnapshot(error=f"扫描源码目录失败：{exc}")
    try:
        files = collect_source_files(lab_root, raise_errors=True)
    except OSError as exc:
        return SourceSnapshot(error=f"扫描源码目录失败：{exc}")
    descriptors: dict[str, dict[str, object]] = {}
    try:
        for relative in sorted(files):
            path = files[relative]
            before = path.stat()
            digest = hashlib.sha256()
            size = 0
            binary = False
            with path.open("rb") as stream:
                for block in iter(lambda: stream.read(1024 * 1024), b""):
                    size += len(block)
                    digest.update(block)
                    if b"\0" in block:
                        binary = True
            after = path.stat()
            if (
                before.st_size != after.st_size
                or before.st_mtime_ns != after.st_mtime_ns
                or getattr(before, "st_ino", 0) != getattr(after, "st_ino", 0)
            ):
                return SourceSnapshot(error=f"读取期间源码文件发生变化：{path}")
            descriptors[relative] = {
                "path": relative,
                "type": "binary" if binary else "text",
                "size": size,
                "sha256": digest.hexdigest(),
            }
    except OSError as exc:
        return SourceSnapshot(error=f"读取源码文件失败：{exc}")
    fingerprint = _sha256_bytes(_stable_json([
        descriptors[name] for name in sorted(descriptors)
    ]).encode("utf-8"))
    return SourceSnapshot(descriptors, fingerprint)


def snapshot_for_lab(root: Path, lab: str) -> SourceSnapshot:
    return source_snapshot(Path(root) / lab)


def missing_lab_snapshot() -> SourceSnapshot:
    """Stable, cacheable fingerprint for a confirmed absent student Lab."""
    return SourceSnapshot(files={}, fingerprint=MISSING_LAB_FINGERPRINT)


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
    command = ["git", *git_diff_options(strict_whitespace)]
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


def compare_lab(
    student: Student,
    lab: str,
    reference_root: Path,
    strict_whitespace: bool,
    student_snapshot: SourceSnapshot | None = None,
    reference_snapshot: SourceSnapshot | None = None,
    analyzer_sig: str = "",
) -> ReportResult:
    reference_lab = reference_root / lab
    submission_lab = student.source / "labs" / lab
    if not reference_lab.is_dir() or is_link_like(reference_lab):
        return ReportResult(
            student, lab, "失败", f"基准实验目录不存在：{reference_root.name}/{lab}",
            cache_state="FAILED", analyzer_signature=analyzer_sig,
        )
    if not submission_lab.is_dir() or is_link_like(submission_lab):
        return ReportResult(
            student, lab, "跳过", "未找到学生该实验的 labs/labN 目录",
            cache_state="SKIPPED", analyzer_signature=analyzer_sig,
        )
    if student.cleaned is None:
        return ReportResult(
            student, lab, "跳过", "未找到对应的已清洗学生目录",
            cache_state="SKIPPED", analyzer_signature=analyzer_sig,
        )

    reference_files = collect_source_files(reference_lab)
    submission_files = collect_source_files(submission_lab)
    paths = sorted(set(reference_files) | set(submission_files))
    result = ReportResult(
        student, lab, "成功", scanned_files=len(paths), analyzer_signature=analyzer_sig,
    )
    if student_snapshot is not None:
        result.source_fingerprint = student_snapshot.fingerprint
    if reference_snapshot is not None:
        result.reference_fingerprint = reference_snapshot.fingerprint
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
    if result.status == "部分失败":
        result.cache_state = "PARTIAL_FAILED"
    return result


def cache_directory(cleaned_root: Path) -> Path:
    return Path(cleaned_root) / CACHE_FOLDER


def cache_key(
    student: Student, lab: str, strict_whitespace: bool, analyzer_sig: str
) -> str:
    """Return a path-safe key independent of the submission directory name."""
    archive = student.archive_sha256 or _sha256_bytes(
        source_identity(student.source).encode("utf-8")
    )
    return _sha256_bytes(_stable_json({
        "student_id": student.student_id,
        "archive_sha256": archive,
        "lab": lab,
        "strict_whitespace": bool(strict_whitespace),
        "analyzer_signature": analyzer_sig,
    }).encode("utf-8"))


def cache_path(
    cleaned_root: Path, student: Student, lab: str,
    strict_whitespace: bool, analyzer_sig: str,
) -> Path:
    return cache_directory(cleaned_root) / "entries" / f"{cache_key(student, lab, strict_whitespace, analyzer_sig)}.json"


def serialize_diff_entry(entry: DiffEntry) -> dict[str, object]:
    return {
        "path": entry.path,
        "kind": entry.kind,
        "diff": entry.diff,
        "additions": entry.additions,
        "deletions": entry.deletions,
        "message": entry.message,
    }


def deserialize_diff_entry(value: object) -> DiffEntry | None:
    if not isinstance(value, dict):
        return None
    path, kind = value.get("path"), value.get("kind")
    if not isinstance(path, str) or not path or not safe_relative_path(path):
        return None
    if kind not in {"modified", "added", "deleted", "binary", "error"}:
        return None
    diff = value.get("diff", "")
    message = value.get("message", "")
    additions, deletions = value.get("additions", 0), value.get("deletions", 0)
    if not isinstance(diff, str) or not isinstance(message, str):
        return None
    if type(additions) is not int or additions < 0 or type(deletions) is not int or deletions < 0:
        return None
    return DiffEntry(path, kind, diff, additions, deletions, message)


def safe_relative_path(value: str) -> bool:
    """Validate a cache-stored path independently of the host OS."""
    if not isinstance(value, str) or not value or "\x00" in value:
        return False
    normalized = value.replace("\\", "/")
    posix = PurePosixPath(normalized)
    windows = PureWindowsPath(value)
    if posix.is_absolute() or windows.is_absolute() or windows.drive:
        return False
    return all(part not in {"", ".", ".."} for part in posix.parts)


def _snapshot_descriptors(snapshot: SourceSnapshot | None) -> dict[str, dict[str, object]]:
    return snapshot.files if snapshot is not None else {}


def cache_document(
    result: ReportResult,
    student_snapshot: SourceSnapshot,
    reference_snapshot: SourceSnapshot,
    strict_whitespace: bool,
    analyzer_sig: str,
    render_sig: str,
    report_text: str = "",
) -> dict[str, object]:
    """Create a cache record for a successful or confirmed-missing Lab."""
    if student_snapshot.error or reference_snapshot.error:
        raise ValueError("带有源码扫描错误的结果不可写入缓存")
    missing_lab = bool(
        result.missing_lab
        or (result.status == "跳过" and student_snapshot.fingerprint == MISSING_LAB_FINGERPRINT)
    )
    if missing_lab and student_snapshot.fingerprint != MISSING_LAB_FINGERPRINT:
        raise ValueError("缺失 Lab 缓存必须使用固定缺失指纹")
    if not missing_lab and student_snapshot.fingerprint == MISSING_LAB_FINGERPRINT:
        raise ValueError("非缺失 Lab 缓存不能使用缺失指纹")
    if result.status == "成功" and result.missing_lab:
        raise ValueError("成功结果不能标记为缺失 Lab")
    if result.status != "成功" and not (
        missing_lab and result.status == "跳过"
    ):
        raise ValueError("只有成功结果或已确认缺失的 Lab 可以写入缓存")
    mirror_sha256 = ""
    mirror_state = "unpublished"
    if result.report_path is not None:
        mirror = mirror_path(result.report_path)
        if mirror is None or not mirror.is_file() or is_link_like(mirror):
            raise ValueError("双视图镜像报告缺失或不安全")
        try:
            mirror_sha256 = _sha256_bytes(mirror.read_bytes())
            mirror_state = "matched" if mirror_sha256 == _sha256_bytes(report_text.encode("utf-8")) else "mismatch"
        except OSError as exc:
            raise ValueError(f"读取双视图镜像报告失败：{exc}") from exc
        if mirror_state != "matched":
            raise ValueError("双视图镜像报告内容不一致")
    return {
        "cache_owner": CACHE_OWNER,
        "schema_version": CACHE_SCHEMA_VERSION,
        "key": cache_key(result.student, result.lab, strict_whitespace, analyzer_sig),
        "student": {
            "student_id": result.student.student_id,
            "name": result.student.name,
            "archive_sha256": result.student.archive_sha256,
            "source": result.student.source_reference,
        },
        "lab": result.lab,
        "strict_whitespace": bool(strict_whitespace),
        "analyzer_signature": analyzer_sig,
        "comparison_rules_version": ANALYZER_VERSION,
        "git_version": git_version(),
        "git_args": git_diff_options(strict_whitespace),
        "render_signature": render_sig,
        "source_fingerprint": student_snapshot.fingerprint,
        "reference_fingerprint": reference_snapshot.fingerprint,
        "student_files": _snapshot_descriptors(student_snapshot),
        "reference_files": _snapshot_descriptors(reference_snapshot),
        "missing_lab": missing_lab,
        "status": result.status,
        "message": result.message,
        "scanned_files": result.scanned_files,
        "unchanged_files": result.unchanged_files,
        "entries": [serialize_diff_entry(entry) for entry in result.entries],
        "report_sha256": _sha256_bytes(report_text.encode("utf-8")) if report_text else "",
        "mirror_sha256": mirror_sha256,
        "mirror_state": mirror_state,
    }


def read_cache_document(path: Path) -> dict | None:
    try:
        assert_safe_path(path, "拒绝通过链接读取缓存")
    except ValueError:
        return None
    if is_link_like(path) or not path.is_file():
        return None
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeDecodeError, ValueError):
        return None
    if not isinstance(value, dict) or value.get("cache_owner") != CACHE_OWNER:
        return None
    if value.get("schema_version") != CACHE_SCHEMA_VERSION:
        return None
    return value


def result_from_cache(
    document: dict,
    student: Student,
    lab: str,
    student_snapshot: SourceSnapshot,
    reference_snapshot: SourceSnapshot,
    strict_whitespace: bool,
    analyzer_sig: str,
    render_sig: str,
) -> ReportResult | None:
    """Validate and reconstruct a result without touching Git."""
    expected = cache_key(student, lab, strict_whitespace, analyzer_sig)
    identity = document.get("student")
    missing_lab = document.get("missing_lab", False)
    if type(missing_lab) is not bool:
        return None
    status = document.get("status")
    status_is_valid = (
        status == "跳过"
        and missing_lab
        and student_snapshot.fingerprint == MISSING_LAB_FINGERPRINT
    ) or (
        status == "成功"
        and not missing_lab
        and student_snapshot.fingerprint != MISSING_LAB_FINGERPRINT
    )
    report_sha256 = document.get("report_sha256", "")
    mirror_sha256 = document.get("mirror_sha256", "")
    mirror_state = document.get("mirror_state", "unpublished")
    if (
        document.get("key") != expected
        or document.get("lab") != lab
        or document.get("strict_whitespace") is not bool(strict_whitespace)
        or document.get("analyzer_signature") != analyzer_sig
        or document.get("comparison_rules_version") != ANALYZER_VERSION
        or document.get("git_args") != git_diff_options(strict_whitespace)
        or not isinstance(document.get("git_version"), str)
        or not document.get("git_version")
        or not isinstance(document.get("render_signature"), str)
        or document.get("source_fingerprint") != student_snapshot.fingerprint
        or document.get("reference_fingerprint") != reference_snapshot.fingerprint
        or not isinstance(identity, dict)
        or identity.get("student_id") != student.student_id
        or identity.get("name") != student.name
        or identity.get("archive_sha256") != student.archive_sha256
        or not isinstance(identity.get("source"), str)
        or not status_is_valid
        or not isinstance(document.get("student_files"), dict)
        or not isinstance(document.get("reference_files"), dict)
        or document.get("student_files") != student_snapshot.files
        or document.get("reference_files") != reference_snapshot.files
        or not isinstance(document.get("message", ""), str)
        or (report_sha256 != "" and not _valid_archive_sha(report_sha256))
        or (mirror_sha256 != "" and not _valid_archive_sha(mirror_sha256))
        or mirror_state not in {"unpublished", "matched", "mismatch", "unreadable"}
    ):
        return None
    entries_raw = document.get("entries")
    if not isinstance(entries_raw, list):
        return None
    entries: list[DiffEntry] = []
    for raw in entries_raw:
        entry = deserialize_diff_entry(raw)
        if entry is None:
            return None
        entries.append(entry)
    entry_paths = [entry.path for entry in entries]
    if len(entry_paths) != len(set(entry_paths)) or entry_paths != sorted(entry_paths):
        return None
    source_paths = set(student_snapshot.files) | set(reference_snapshot.files)
    if not set(entry_paths).issubset(source_paths):
        return None
    for entry in entries:
        in_reference = entry.path in reference_snapshot.files
        in_student = entry.path in student_snapshot.files
        if not in_reference and in_student:
            allowed_kinds = {"added", "error"}
        elif in_reference and not in_student:
            allowed_kinds = {"deleted", "error"}
        elif in_reference and in_student:
            allowed_kinds = {"modified", "binary", "error"}
        else:
            return None
        if entry.kind not in allowed_kinds:
            return None
        if entry.kind in {"binary", "error"}:
            if entry.diff or entry.additions or entry.deletions:
                return None
        elif not entry.diff:
            return None
        else:
            additions, deletions = diff_line_counts(entry.diff)
            if (entry.additions, entry.deletions) != (additions, deletions):
                return None
    scanned = document.get("scanned_files")
    unchanged = document.get("unchanged_files")
    expected_scanned = len(source_paths)
    if (
        type(scanned) is not int
        or type(unchanged) is not int
        or scanned < 0
        or unchanged < 0
        or scanned != expected_scanned
        or unchanged + len(entries) != scanned
    ):
        return None
    if missing_lab and (scanned != 0 or unchanged != 0 or entries):
        return None
    source_changed = identity.get("source") != student.source_reference
    render_changed = status == "成功" and document.get("render_signature") != render_sig
    return ReportResult(
        student=student,
        lab=lab,
        status=status,
        message=document.get("message", "") if isinstance(document.get("message", ""), str) else "",
        scanned_files=scanned,
        unchanged_files=unchanged,
        entries=entries,
        cache_state=(
            "RECONCILED" if source_changed
            else "RENDERED" if render_changed
            else "CACHED"
        ),
        source_fingerprint=student_snapshot.fingerprint,
        reference_fingerprint=reference_snapshot.fingerprint,
        analyzer_signature=analyzer_sig,
        render_signature=render_sig,
        missing_lab=missing_lab,
    )


def write_cache_document(path: Path, document: dict) -> None:
    assert_safe_path(path, "拒绝通过链接写入缓存")
    atomic_write(path, json.dumps(document, ensure_ascii=False, sort_keys=True, indent=2) + "\n")


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
             f"- 原始提交目录：{markdown_text(student.source_reference)}",
             f"- 基准目录：{markdown_text(f'{reference_root.name}/{result.lab}')}",
             f"- 学生源码指纹：{result.source_fingerprint or '未知'}",
             f"- 基准源码指纹：{result.reference_fingerprint or '未知'}",
             f"- 分析器签名：{result.analyzer_signature or '未知'}",
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
    atomic_write_bytes(path, text.encode("utf-8"))


def atomic_write_bytes(path: Path, content: bytes) -> None:
    assert_safe_path(path, "拒绝覆盖符号链接")
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary: Path | None = None
    try:
        with tempfile.NamedTemporaryFile("wb", dir=path.parent,
                                         prefix=".lab-diff-", suffix=".tmp", delete=False) as stream:
            temporary = Path(stream.name)
            stream.write(content)
        os.replace(temporary, path)
    finally:
        if temporary is not None and temporary.exists():
            temporary.unlink()


def write_report_if_changed(path: Path, text: str) -> bool:
    """Publish both report views only when their bytes are not already right."""
    encoded = text.encode("utf-8")
    if pair_matches(path):
        try:
            if path.read_bytes() == encoded:
                return False
        except OSError:
            pass
    write_text_pair(path, text)
    return True


def report_pair_state(path: Path) -> dict[Path, bytes | None]:
    """Capture both report views so a later manifest failure can roll them back."""
    state: dict[Path, bytes | None] = {}
    targets = (Path(path), mirror_path(path))
    for target in targets:
        if target is None:
            continue
        assert_safe_path(target, "拒绝通过链接保存报告快照")
        if is_link_like(target):
            raise ValueError(f"报告路径是符号链接：{target}")
        if target.exists():
            if not target.is_file():
                raise ValueError(f"报告路径不是普通文件：{target}")
            state[target] = target.read_bytes()
        else:
            state[target] = None
    return state


def restore_report_pair(state: dict[Path, bytes | None]) -> None:
    """Restore a previously captured report pair after a failed manifest commit."""
    for target, content in state.items():
        assert_safe_path(target, "拒绝通过链接恢复报告")
        if content is None:
            if target.exists():
                if is_link_like(target) or not target.is_file():
                    raise ValueError(f"无法移除异常报告路径：{target}")
                target.unlink()
        else:
            atomic_write_bytes(target, content)


def student_report_directory(student: Student, lab: str) -> Path:
    """Return the owned report directory only when it remains inside the student output."""
    if student.cleaned is None:
        raise ValueError("学生没有已清洗输出目录")
    assert_safe_path(student.cleaned, "拒绝通过链接访问学生输出")
    cleaned = student.cleaned.resolve()
    report_dir = student.cleaned / lab / REPORT_FOLDER
    assert_safe_path(report_dir, "拒绝通过链接访问报告目录")
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


def _legacy_manifest_source_is_plausible(value: object, student: Student) -> bool:
    """Bound legacy basename matching to the declared submissions root."""
    if not isinstance(value, str) or not value.strip():
        return False
    normalized = value.strip().replace("\\", os.sep).replace("/", os.sep)
    candidate = Path(normalized)
    current_parent = student.source.resolve().parent
    if candidate.is_absolute():
        try:
            return candidate.resolve().parent == current_parent
        except OSError:
            return False
    parts = candidate.parts
    if len(parts) == 1:
        # Some early manifests stored only the submission directory basename.
        return True
    return parts[0].casefold() == current_parent.name.casefold()


def _manifest_source_matches_student(value: object, student: Student) -> bool:
    if not isinstance(value, str) or not value.strip():
        return False
    if value == student.source_reference:
        return True
    normalized = value.strip().replace("\\", os.sep).replace("/", os.sep)
    candidate = Path(normalized)
    current_identity = source_identity(student.source)
    if candidate.is_absolute():
        return source_identity(candidate) == current_identity
    return any(
        source_identity_from(value, base) == current_identity
        for base in (student.source.parent.parent, student.source.parent)
    )


def _report_manifest_owned_by(manifest: object, student: Student) -> bool:
    if (
        not isinstance(manifest, dict)
        or manifest.get("tool") != "generate_lab_diff_reports"
        or manifest.get("schema_version") != REPORT_MANIFEST_VERSION
    ):
        return False
    if _manifest_source_matches_student(manifest.get("source"), student):
        return True
    # A grabber reconciliation can rename the current directory while the
    # archive SHA remains the same.  New manifests carry the immutable
    # identity explicitly; older manifests are accepted only when their
    # parsed source still identifies the same student and submission stamp.
    if manifest.get("student_id") is not None:
        return (
            manifest.get("student_id") == student.student_id
            and manifest.get("name") == student.name
            and manifest.get("archive_sha256") == student.archive_sha256
        )
    parsed = parse_student_name(source_basename(manifest.get("source")))
    return bool(
        _legacy_manifest_source_is_plausible(manifest.get("source"), student)
        and parsed
        and parsed.student_id == student.student_id
        and parsed.name == student.name
        and parsed.raw_time == student.raw_time
    )


def _owned_report_artifact(report_dir: Path, name: object) -> Path | None:
    if not isinstance(name, str) or name not in REPORT_ARTIFACTS:
        return None
    target = report_dir / name
    if is_link_like(target):
        return None
    if target.exists() and not target.is_file():
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


def writable_student_report_directory(student: Student, lab: str) -> Path:
    """Reject a foreign or malformed manifest before any report is replaced."""
    report_dir = student_report_directory(student, lab)
    directories = [report_dir]
    mirrored = mirror_path(report_dir)
    if mirrored is not None:
        directories.append(mirrored)
    for directory in directories:
        manifest_path = directory / REPORT_MANIFEST
        if is_link_like(directory) or is_link_like(manifest_path):
            raise ValueError(f"报告目录或归属清单是符号链接：{manifest_path}")
        existing = _read_report_manifest(manifest_path)
        if manifest_path.exists() and not _report_manifest_owned_by(existing, student):
            raise ValueError(f"报告目录已有其他来源或无效归属清单：{manifest_path}")
        if manifest_path.exists() and _declared_report_artifacts(directory, existing) is None:
            raise ValueError(f"报告目录的归属清单产物无效：{manifest_path}")
    return report_dir


def writable_student_report_path(student: Student, lab: str) -> Path:
    """Return a report target without taking over an unregistered same-name file."""
    report_dir = writable_student_report_directory(student, lab)
    mirrored = mirror_path(report_dir)
    if mirrored is not None:
        mirror_target = mirrored / REPORT_NAME
        declared = _declared_report_artifacts(
            mirrored, _read_report_manifest(mirrored / REPORT_MANIFEST)
        )
        if is_link_like(mirror_target) or (
            mirror_target.exists()
            and (not mirror_target.is_file() or REPORT_NAME not in (declared or set()))
        ):
            raise ValueError(f"报告路径已有未登记内容：{mirror_target}")
    target = report_dir / REPORT_NAME
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
    lab = results[0].lab
    report_dir = writable_student_report_directory(student, lab)
    manifest_path = report_dir / REPORT_MANIFEST
    existing = _read_report_manifest(manifest_path)
    owned = _report_manifest_owned_by(existing, student)
    declared_artifacts = _declared_report_artifacts(report_dir, existing)
    if declared_artifacts is None:
        raise ValueError(f"报告目录的归属清单产物无效：{manifest_path}")
    artifacts = set(declared_artifacts)
    if not any(result.report_path is not None or result.missing_lab for result in results):
        return
    for result in sorted(
        results,
        key=lambda item: (item.student.student_id, item.student.name, item.student.source_reference),
    ):
        artifact = REPORT_NAME
        if result.lab not in selected_labs:
            continue
        if result.report_path is not None:
            artifacts.add(artifact)
        elif result.missing_lab:
            # A selected lab disappeared from the raw submission. Its old
            # report would otherwise remain visible as current scoring input.
            artifacts.discard(artifact)

    if not owned and not any(result.report_path is not None for result in results):
        return

    # The manifest and stale-report removals form one logical publication.
    # ``write_text_pair`` and ``unlink_pair`` are individually atomic, but a
    # successful manifest write followed by a failed stale-report removal
    # would otherwise leave the ownership record ahead of the files it names.
    previous_manifest_state = report_pair_state(manifest_path)
    stale_report_states: list[tuple[dict[Path, bytes | None], Path]] = []
    previous_artifacts = declared_artifacts
    for name in previous_artifacts - artifacts:
        if lab not in selected_labs:
            continue
        target = _owned_report_artifact(report_dir, name)
        if target is None:
            continue
        paired = (target, mirror_path(target))
        if any(candidate is not None and candidate.exists() for candidate in paired):
            stale_report_states.append((report_pair_state(target), target))

    try:
        write_text_pair(manifest_path, json.dumps({
            "tool": "generate_lab_diff_reports",
            "schema_version": REPORT_MANIFEST_VERSION,
            "student_id": student.student_id,
            "name": student.name,
            "archive_sha256": student.archive_sha256,
            "source": student.source_reference,
            "artifacts": sorted(artifacts),
        }, ensure_ascii=False, indent=2) + "\n")

        # Remove stale reports only after the new ownership record is safely
        # published.  If any removal fails, restore both the old manifest and
        # every report pair captured above before returning the original error.
        for _, target in stale_report_states:
            unlink_pair(target)
    except Exception:
        try:
            for state, target in reversed(stale_report_states):
                restore_report_pair(state)
            restore_report_pair(previous_manifest_state)
        except Exception:
            # Preserve the publication error; the caller still reports a
            # failed unit and the next run can surface any unrecoverable path.
            pass
        raise


def orphaned_report_results(
    cleaned_root: Path,
    labs: tuple[str, ...],
    filters: list[str],
    known_sources: set[str],
    submissions_root: Path | None = None,
    active_cleaned: set[str] | None = None,
) -> dict[str, list[ReportResult]]:
    """Surface registered reports whose original submission is no longer scannable.

    The old reports are intentionally retained because the raw input required to
    recreate them is gone. Returning failed results makes the stale state visible
    in each selected lab's summary and produces a non-zero batch exit status.
    """
    by_lab = {lab: [] for lab in labs}
    if not cleaned_root.is_dir() or is_link_like(cleaned_root):
        return by_lab

    people_root = cleaned_root / "按人分类"
    try:
        assert_safe_path(people_root, "已清洗按人视图包含链接或 junction")
    except ValueError:
        return by_lab
    if not people_root.is_dir() or is_link_like(people_root):
        return by_lab
    try:
        people_directories = sorted(people_root.iterdir(), key=lambda path: path.name)
    except OSError:
        return by_lab
    for directory in people_directories:
        if not directory.is_dir() or is_link_like(directory):
            continue
        if active_cleaned and source_identity(directory) in active_cleaned:
            # The terminal owner already maps this cleaned directory to a
            # current submission.  A legacy diff manifest may still mention
            # the previous directory name and will be reconciled in place.
            continue
        for lab in labs:
            report_dir = directory / lab / REPORT_FOLDER
            try:
                assert_safe_path(report_dir, "差异报告路径包含链接或 junction")
            except ValueError:
                continue
            manifest = _read_report_manifest(report_dir / REPORT_MANIFEST)
            if (
                not isinstance(manifest, dict)
                or manifest.get("tool") != "generate_lab_diff_reports"
                or manifest.get("schema_version") != REPORT_MANIFEST_VERSION
            ):
                continue
            source = manifest.get("source")
            source_keys = {
                source_identity(source),
                source_identity_from(
                    source,
                    *(tuple(filter(None, (
                        submissions_root.parent if submissions_root is not None else None,
                        submissions_root,
                    ))))
                ) if submissions_root is not None else None,
                str(source).replace("\\", "/") if isinstance(source, str) else None,
            }
            if source_keys & known_sources:
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
            report_path = report_dir / REPORT_NAME
            if (isinstance(artifacts, list) and REPORT_NAME in artifacts and report_path.is_file()
                    and not is_link_like(report_path)):
                by_lab[lab].append(ReportResult(
                    student, lab, "失败",
                    f"原始提交目录不存在或无法匹配；已保留旧个人报告：{report_path}",
                    cache_state="PARTIAL_FAILED",
                ))
    return by_lab


def report_link(from_path: Path, to_path: Path) -> str:
    relative = os.path.relpath(to_path, from_path.parent).replace(os.sep, "/")
    return quote(relative, safe="/-_.")


def render_summary(
    lab: str,
    summary_path: Path,
    results: list[ReportResult],
    skipped: list[str],
    strict_whitespace: bool,
    analyzer_sig: str = "",
) -> str:
    lines = [f"# {lab} 源码差异报告汇总", "",
             f"- 分析器签名：{analyzer_sig or (results[0].analyzer_signature if results else '未知')}",
             "- 比较范围：kernel、xv6-user、linker 下的源码/脚本/构建配置，以及根目录 Makefile",
             f"- 空白符策略：{'精确比较' if strict_whitespace else '忽略空格、Tab、空白行和行尾空白差异'}", "",
             "- 缓存状态：CACHED 表示完整命中；RENDERED 表示复用分析结果后重建正式报告；RECONCILED 表示归属来源变化后复用；REBUILT 表示重新执行源码比较；SKIPPED、PARTIAL_FAILED、FAILED 保留诊断。", "",
             "| 学号 | 姓名 | 状态 | 缓存状态 | 差异文件 | +行 | -行 | 报告/原因 |",
             "| --- | --- | --- | --- | ---: | ---: | ---: | --- |"]
    for result in sorted(
        results,
        key=lambda item: (item.student.student_id, item.student.name, item.student.source_reference),
    ):
        if result.report_path:
            link = report_link(summary_path, result.report_path)
            outcome = f"[查看报告（按人分类）]({link})"
            mirrored = mirror_path(result.report_path)
            if mirrored is not None:
                outcome += f" · [按Lab分类]({report_link(summary_path, mirrored)})"
            if result.message:
                outcome += "<br>" + markdown_text(result.message)
        else:
            outcome = markdown_text(result.message)
        # Formal summaries are reproducible: the run log keeps the concrete
        # action, while every successfully published reusable result is shown
        # as CACHED here so a cold and warm run produce identical bytes.
        summary_cache_state = (
            "CACHED"
            if (result.status == "成功" or result.missing_lab)
            and result.cache_state in {"CACHED", "RENDERED", "REBUILT", "RECONCILED"}
            else result.cache_state
        )
        lines.append(
            f"| {markdown_text(result.student.student_id)} | {markdown_text(result.student.name)} | "
            f"{result.status} | {summary_cache_state} | {result.changed_files} | {result.additions} | "
            f"{result.deletions} | {outcome} |"
        )
    if skipped:
        lines.extend(["", "## 未纳入处理的目录", ""])
        lines.extend(f"- {markdown_text(item)}" for item in skipped)
    lines.append("")
    return "\n".join(lines)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="批量生成 xv6 lab0--lab8 源码差异 Markdown 报告")
    selection = parser.add_mutually_exclusive_group(required=True)
    selection.add_argument("--lab", action="append", choices=LABS, help="指定实验；可重复使用")
    selection.add_argument("--all-labs", action="store_true", help="处理 lab0 至 lab8")
    parser.add_argument("--student", action="append", default=[], help="精确筛选学号或姓名；可重复使用")
    parser.add_argument("--reference-root", type=Path, default=DEFAULT_REFERENCE_ROOT)
    parser.add_argument("--submissions-root", type=Path, default=DEFAULT_SUBMISSIONS_ROOT)
    parser.add_argument("--cleaned-root", type=Path, default=DEFAULT_CLEANED_ROOT)
    parser.add_argument("--strict-whitespace", action="store_true", help="不忽略空白符差异")
    parser.add_argument("--dry-run", action="store_true", help="只显示处理计划，不写报告")
    parser.add_argument("--force", action="store_true", help="忽略选中学生和实验的源码差异缓存")
    return parser


def _placeholder_dry_result(
    student: Student,
    lab: str,
    state: str,
    message: str,
    source_snapshot_value: SourceSnapshot | None = None,
    reference_snapshot_value: SourceSnapshot | None = None,
    analyzer_sig: str = "",
    render_sig: str = "",
    missing_lab: bool = False,
) -> ReportResult:
    return ReportResult(
        student=student,
        lab=lab,
        status="预演",
        message=message,
        cache_state=state,
        source_fingerprint=(source_snapshot_value.fingerprint if source_snapshot_value else ""),
        reference_fingerprint=(reference_snapshot_value.fingerprint if reference_snapshot_value else ""),
        analyzer_signature=analyzer_sig,
        render_signature=render_sig,
        missing_lab=missing_lab,
    )


def prepare_lab_result(
    student: Student,
    lab: str,
    reference_root: Path,
    cleaned_root: Path,
    strict_whitespace: bool,
    analyzer_sig: str,
    render_sig: str,
    force: bool = False,
    dry_run: bool = False,
    reference_snapshot_value: SourceSnapshot | None = None,
) -> tuple[ReportResult, SourceSnapshot | None, SourceSnapshot | None, Path]:
    """Resolve one Lab through the cache, returning snapshots for persistence."""
    reference_lab = reference_root / lab
    submission_lab = student.source / "labs" / lab
    cache_file = cache_path(cleaned_root, student, lab, strict_whitespace, analyzer_sig)

    # Keep existing skip/failure semantics and avoid hashing absent trees.
    try:
        assert_safe_path(reference_lab, "基准源码路径包含链接或 junction")
        assert_safe_path(submission_lab, "学生源码路径包含链接或 junction")
    except ValueError as exc:
        result = ReportResult(
            student, lab, "部分失败", str(exc),
            cache_state="PARTIAL_FAILED", analyzer_signature=analyzer_sig,
            render_signature=render_sig,
        )
        return result, None, None, cache_file
    if not reference_lab.is_dir() or is_link_like(reference_lab):
        result = ReportResult(
            student, lab, "失败", f"基准实验目录不存在：{reference_root.name}/{lab}",
            cache_state="FAILED", analyzer_signature=analyzer_sig, render_signature=render_sig,
        )
        return result, None, None, cache_file

    reference_snapshot_value = reference_snapshot_value or source_snapshot(reference_lab)
    if reference_snapshot_value.error:
        result = ReportResult(
            student, lab, "部分失败", reference_snapshot_value.error,
            cache_state="PARTIAL_FAILED", analyzer_signature=analyzer_sig,
            render_signature=render_sig,
            reference_fingerprint=reference_snapshot_value.fingerprint,
        )
        return result, None, reference_snapshot_value, cache_file

    # A genuinely absent directory is a deterministic input state and can be
    # cached. Links, files, and unreadable paths remain uncached diagnostics.
    try:
        submission_exists = os.path.lexists(submission_lab)
    except OSError as exc:
        result = ReportResult(
            student, lab, "部分失败", f"检查学生实验目录失败：{exc}",
            cache_state="PARTIAL_FAILED", analyzer_signature=analyzer_sig,
            render_signature=render_sig,
        )
        return result, None, None, cache_file
    submission_link = is_link_like(submission_lab)
    if not submission_exists and not submission_link:
        student_snapshot_value = missing_lab_snapshot()
        if not force:
            cached = result_from_cache(
                read_cache_document(cache_file) or {}, student, lab,
                student_snapshot_value, reference_snapshot_value,
                strict_whitespace, analyzer_sig, render_sig,
            )
            if cached is not None:
                return cached, student_snapshot_value, reference_snapshot_value, cache_file
        if dry_run:
            return (
                _placeholder_dry_result(
                    student, lab, "REBUILT", "未找到学生该实验的 labs/labN 目录",
                    student_snapshot_value, reference_snapshot_value,
                    analyzer_sig, render_sig, missing_lab=True,
                ),
                student_snapshot_value,
                reference_snapshot_value,
                cache_file,
            )
        result = ReportResult(
            student, lab, "跳过", "未找到学生该实验的 labs/labN 目录",
            cache_state="REBUILT", analyzer_signature=analyzer_sig,
            render_signature=render_sig,
            source_fingerprint=student_snapshot_value.fingerprint,
            reference_fingerprint=reference_snapshot_value.fingerprint,
            missing_lab=True,
        )
        return result, student_snapshot_value, reference_snapshot_value, cache_file

    if not submission_lab.is_dir() or submission_link:
        result = ReportResult(
            student, lab, "部分失败", "学生该实验路径不是安全的 labs/labN 目录",
            cache_state="PARTIAL_FAILED", analyzer_signature=analyzer_sig,
            render_signature=render_sig,
        )
        return result, None, None, cache_file
    if student.cleaned is None:
        result = ReportResult(
            student, lab, "跳过", "未找到对应的已清洗学生目录",
            cache_state="SKIPPED", analyzer_signature=analyzer_sig, render_signature=render_sig,
        )
        return result, None, None, cache_file

    student_snapshot_value = source_snapshot(submission_lab)
    if reference_snapshot_value.error or student_snapshot_value.error:
        message = reference_snapshot_value.error or student_snapshot_value.error
        result = ReportResult(
            student, lab, "部分失败", message,
            cache_state="PARTIAL_FAILED", analyzer_signature=analyzer_sig,
            render_signature=render_sig,
            source_fingerprint=student_snapshot_value.fingerprint,
            reference_fingerprint=reference_snapshot_value.fingerprint,
        )
        return result, student_snapshot_value, reference_snapshot_value, cache_file

    if not force:
        cached = result_from_cache(
            read_cache_document(cache_file) or {}, student, lab,
            student_snapshot_value, reference_snapshot_value,
            strict_whitespace, analyzer_sig, render_sig,
        )
        if cached is not None:
            return cached, student_snapshot_value, reference_snapshot_value, cache_file
    if dry_run:
        return (
            _placeholder_dry_result(
                student, lab, "REBUILT", "缓存未命中，将重新比较",
                student_snapshot_value, reference_snapshot_value, analyzer_sig, render_sig,
            ),
            student_snapshot_value,
            reference_snapshot_value,
            cache_file,
        )

    result = compare_lab(
        student, lab, reference_root, strict_whitespace,
        student_snapshot_value, reference_snapshot_value, analyzer_sig,
    )
    # Do not publish or cache a result if either input tree changed while it
    # was being compared.  A later run can then take a fresh, trustworthy
    # snapshot instead of preserving a mixed-state diff.
    if result.status == "成功":
        final_student_snapshot = source_snapshot(submission_lab)
        final_reference_snapshot = source_snapshot(reference_lab)
        if (
            final_student_snapshot.error
            or final_reference_snapshot.error
            or final_student_snapshot.fingerprint != student_snapshot_value.fingerprint
            or final_reference_snapshot.fingerprint != reference_snapshot_value.fingerprint
        ):
            changed = "学生" if final_student_snapshot.fingerprint != student_snapshot_value.fingerprint else "基准"
            result = ReportResult(
                student, lab, "部分失败", f"比较期间{changed}源码发生变化，未发布或缓存结果",
                cache_state="PARTIAL_FAILED", analyzer_signature=analyzer_sig,
                render_signature=render_sig,
                source_fingerprint=final_student_snapshot.fingerprint,
                reference_fingerprint=final_reference_snapshot.fingerprint,
            )
            return result, final_student_snapshot, final_reference_snapshot, cache_file
    result.render_signature = render_sig
    result.cache_state = "REBUILT" if result.status == "成功" else result.cache_state
    return result, student_snapshot_value, reference_snapshot_value, cache_file


def cache_cleanup_candidates(
    cleaned_root: Path,
    selected_labs: frozenset[str],
    active_keys: set[str],
) -> list[Path]:
    """Return stale cache paths without mutating the filesystem."""
    root = cache_directory(cleaned_root)
    entries_root = root / "entries"
    try:
        assert_safe_path(root, "拒绝通过链接清理缓存")
        assert_safe_path(entries_root, "拒绝通过链接清理缓存")
    except ValueError:
        return []
    if not entries_root.is_dir() or is_link_like(entries_root):
        return []
    candidates: list[Path] = []
    for path in sorted(entries_root.glob("*.json")):
        if is_link_like(path):
            continue
        try:
            raw_document = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, UnicodeDecodeError, ValueError):
            continue
        if not isinstance(raw_document, dict) or raw_document.get("cache_owner") != CACHE_OWNER:
            continue
        if raw_document.get("lab") not in selected_labs:
            continue
        # Old schema entries are owned, but cannot be reused.  A complete scan
        # may remove them once it has established the current active keys.
        if raw_document.get("schema_version") != CACHE_SCHEMA_VERSION:
            candidates.append(path)
            continue
        if raw_document.get("key") in active_keys:
            continue
        candidates.append(path)
    return candidates


def cleanup_cache(
    cleaned_root: Path,
    selected_labs: frozenset[str],
    active_keys: set[str],
) -> list[str]:
    """Remove only stale entries owned by this tool after a complete scan."""
    removed: list[str] = []
    for path in cache_cleanup_candidates(cleaned_root, selected_labs, active_keys):
        try:
            path.unlink()
            removed.append(path.name)
        except OSError:
            continue
    return removed


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    for label, raw_root in (
        ("基准根目录", args.reference_root),
        ("提交根目录", args.submissions_root),
        ("已清洗根目录", args.cleaned_root),
    ):
        try:
            assert_safe_path(raw_root, f"{label}包含链接或 junction")
        except ValueError as exc:
            parser.error(str(exc))
    reference_root = args.reference_root.resolve()
    submissions_root = args.submissions_root.resolve()
    cleaned_root = args.cleaned_root.resolve()
    output_path_unsafe = any(
        is_link_like(cleaned_root / relative)
        for relative in ("按人分类", CACHE_FOLDER, Path(CACHE_FOLDER) / "entries")
    )
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
    analysis_sig = analyzer_signature(args.strict_whitespace)
    render_sig = render_signature()
    students, skipped = scan_students(submissions_root, args.student, require_marker=True)
    skipped.extend(map_cleaned_students(students, cleaned_root, submissions_root))
    selected_students = [student for student in students if student.selected]
    known_sources = {
        key
        for student in students
        for key in (
            source_identity(student.source),
            student.source_reference,
            source_identity_from(student.source_reference, submissions_root.parent, submissions_root),
        )
        if key is not None
    }
    active_cleaned = {
        source_identity(student.cleaned)
        for student in selected_students
        if student.cleaned is not None
    }
    orphaned_by_lab = orphaned_report_results(
        cleaned_root, labs, args.student, known_sources, submissions_root, active_cleaned
    )
    if args.student and not selected_students and not any(orphaned_by_lab.values()):
        print(f"[失败] 未找到匹配 --student 的原始提交或已登记报告：{', '.join(args.student)}",
              file=os.sys.stderr)
        return 1
    if not args.dry_run:
        ensure_layout(cleaned_root)
    all_results: list[ReportResult] = []
    active_cache_keys: set[str] = set()
    planned_cache_keys: set[str] = set()
    pending_cache: list[tuple[ReportResult, SourceSnapshot, SourceSnapshot, Path, str]] = []
    for lab in labs:
        reference_snapshot_value = source_snapshot(reference_root / lab)
        lab_results: list[ReportResult] = []
        prepared: list[tuple[ReportResult, SourceSnapshot | None, SourceSnapshot | None, Path]] = []
        for student in selected_students:
            prepared.append(prepare_lab_result(
                student, lab, reference_root, cleaned_root, args.strict_whitespace,
                analysis_sig, render_sig, force=args.force, dry_run=args.dry_run,
                reference_snapshot_value=(
                    reference_snapshot_value if not reference_snapshot_value.error else None
                ),
            ))
        if args.dry_run:
            for result, student_snapshot_value, reference_snapshot_for_result, _ in prepared:
                if (
                    student_snapshot_value is not None
                    and reference_snapshot_for_result is not None
                    and not student_snapshot_value.error
                    and not reference_snapshot_for_result.error
                    and result.status in {"成功", "跳过", "预演"}
                ):
                    planned_cache_keys.add(
                        cache_key(result.student, result.lab, args.strict_whitespace, analysis_sig)
                    )
        lab_results.extend(item[0] for item in prepared)
        lab_results.extend(orphaned_by_lab[lab])
        all_results.extend(lab_results)
        if args.dry_run:
            print(f"[预演] {lab}：候选学生 {len(lab_results)} 人")
            for result in lab_results:
                print(
                    f"  {result.student.student_id}-{result.student.name}："
                    f"{result.cache_state} {result.status} {result.message}"
                )
            continue
        publication_states: dict[int, tuple[dict[Path, bytes | None], dict[Path, bytes | None]]] = {}
        for result in lab_results:
            if result.status != "成功" or result.student.cleaned is None:
                continue
            try:
                report_path = writable_student_report_path(result.student, lab)
                # Keep both formal report views and both manifest views until
                # the ownership update has committed.  A manifest failure may
                # happen after it has removed a stale report, so the report
                # snapshot must be captured before publishing the new body.
                report_state = report_pair_state(report_path)
                manifest_state = report_pair_state(
                    report_path.parent / REPORT_MANIFEST
                )
                publication_states[id(result)] = (report_state, manifest_state)
                report_text = render_student_report(result, reference_root, args.strict_whitespace)
                # A cache hit still needs a render pass when a report/mirror is
                # missing, stale, or the student directory was reconciled.
                if result.cache_state == "CACHED":
                    try:
                        already_current = pair_matches(report_path) and report_path.read_text(
                            encoding="utf-8"
                        ) == report_text
                    except (OSError, UnicodeError):
                        already_current = False
                    if not already_current:
                        result.cache_state = "RENDERED"
                        report_text = render_student_report(
                            result, reference_root, args.strict_whitespace
                        )
                write_report_if_changed(report_path, report_text)
                if not pair_matches(report_path) or report_path.read_bytes() != report_text.encode("utf-8"):
                    raise ValueError("双视图个人报告发布后校验失败")
                result.report_path = report_path
                # Cache publication follows successful report publication.  A
                # failed report write therefore cannot strand a new cache entry.
                item = next(
                    item for item in prepared if item[0] is result
                )
                _, student_snapshot_value, reference_snapshot_for_result, cache_file = item
                if student_snapshot_value is not None and reference_snapshot_for_result is not None:
                    pending_cache.append((
                        result, student_snapshot_value, reference_snapshot_for_result,
                        cache_file, report_text,
                    ))
            except (OSError, ValueError) as exc:
                rollback_errors: list[str] = []
                publication_state = publication_states.pop(id(result), None)
                if publication_state is not None:
                    for state in publication_state:
                        try:
                            restore_report_pair(state)
                        except (OSError, ValueError) as rollback_exc:
                            rollback_errors.append(str(rollback_exc))
                result.status = "失败"
                result.cache_state = "FAILED"
                result.message = f"写入个人报告失败：{exc}"
                if rollback_errors:
                    result.message += "；回滚正式产物失败：" + "；".join(rollback_errors)

        # A confirmed-absent Lab has no report body, but its deterministic
        # state still belongs in the structured cache.  This also keeps the
        # entry alive during full-scan cache cleanup.
        for result, student_snapshot_value, reference_snapshot_for_result, cache_file in prepared:
            if (
                result.missing_lab
                and result.status == "跳过"
                and student_snapshot_value is not None
                and reference_snapshot_for_result is not None
            ):
                # Missing-Lab reconciliation can remove an old report while
                # updating the manifest, so it needs the same rollback state
                # even though no new report body is published.
                if id(result) not in publication_states and result.student.cleaned is not None:
                    try:
                        missing_report_path = writable_student_report_path(result.student, lab)
                        publication_states[id(result)] = (
                            report_pair_state(missing_report_path),
                            report_pair_state(missing_report_path.parent / REPORT_MANIFEST),
                        )
                    except (OSError, ValueError) as exc:
                        result.status = "部分失败"
                        result.cache_state = "PARTIAL_FAILED"
                        result.message = f"保存缺失 Lab 发布快照失败：{exc}"
                        continue
                pending_cache.append((
                    result, student_snapshot_value, reference_snapshot_for_result,
                    cache_file, "",
                ))
        for student in selected_students:
            student_results = [result for result in lab_results if result.student is student]
            if student.cleaned is None or not student_results:
                continue
            try:
                update_student_report_manifest(student, student_results, selected_labs)
                for result in student_results:
                    publication_states.pop(id(result), None)
            except (OSError, ValueError) as exc:
                rollback_errors: list[str] = []
                target = next(
                    (result for result in student_results if id(result) in publication_states),
                    student_results[0],
                )
                for result in student_results:
                    publication_state = publication_states.pop(id(result), None)
                    if publication_state is None:
                        continue
                    for state in publication_state:
                        try:
                            restore_report_pair(state)
                        except (OSError, ValueError) as rollback_exc:
                            rollback_errors.append(str(rollback_exc))
                target.status = "部分失败" if target.status in {"成功", "部分失败"} else "失败"
                target.cache_state = "PARTIAL_FAILED"
                target.message = f"更新个人报告清单失败：{exc}"
                if rollback_errors:
                    target.message += "；回滚正式产物失败：" + "；".join(rollback_errors)

        # Write structured analysis only after both report views and manifests
        # have been accepted.  Existing bytes remain untouched on an error.
        for result, student_snapshot_value, reference_snapshot_for_result, cache_file, report_text in list(pending_cache):
            if result.lab != lab or not (
                result.status == "成功" or (result.status == "跳过" and result.missing_lab)
            ):
                continue
            try:
                document = cache_document(
                    result, student_snapshot_value, reference_snapshot_for_result,
                    args.strict_whitespace, analysis_sig, render_sig, report_text,
                )
                if result.cache_state == "CACHED" and cache_file.is_file():
                    active_cache_keys.add(str(document["key"]))
                    continue
                write_cache_document(cache_file, document)
                active_cache_keys.add(str(document["key"]))
            except (OSError, ValueError) as exc:
                result.status = "部分失败"
                result.cache_state = "PARTIAL_FAILED"
                result.message = f"写入差异缓存失败：{exc}"
                active_cache_keys.add(cache_key(result.student, result.lab, args.strict_whitespace, analysis_sig))
        pending_cache = [item for item in pending_cache if item[0].lab != lab]
        summary_path = cleaned_root / SUMMARY_FOLDER / f"代码差异报告汇总-{lab}.md"
        try:
            assert_safe_path(summary_path, "拒绝通过链接访问汇总报告")
            summary_text = render_summary(
                lab, summary_path, lab_results, skipped, args.strict_whitespace, analysis_sig
            )
            if not pair_matches(summary_path) or summary_path.read_text(encoding="utf-8") != summary_text:
                atomic_write(summary_path, summary_text)
        except (OSError, UnicodeError, ValueError) as exc:
            print(f"[失败] 无法写入汇总报告 {display_path(summary_path, cleaned_root)}：{exc}", file=os.sys.stderr)
            return 1
        print(f"[完成] {lab}：{display_path(summary_path, cleaned_root)}")

    if args.dry_run:
        if args.student:
            print("[预演] 指定学生运行不会清理其他缓存")
        elif (
            output_path_unsafe
            or any(item.startswith(("[source-scan]", "[cleaned-scan]")) for item in skipped)
            or any(result.status in {"失败", "部分失败"} for result in all_results)
        ):
            print("[预演] 输入或清洗归属存在诊断，不会执行全局缓存清理")
        else:
            planned_cleanup = cache_cleanup_candidates(
                cleaned_root, selected_labs, planned_cache_keys
            )
            if planned_cleanup:
                print("[预演] 计划清理缓存：" + ", ".join(path.name for path in planned_cleanup))
            else:
                print("[预演] 没有计划清理的缓存")

    cleanup_allowed = (
        not args.dry_run
        and not args.student
        and not output_path_unsafe
        and not any(item.startswith(("[source-scan]", "[cleaned-scan]")) for item in skipped)
        and not any(result.status in {"失败", "部分失败"} for result in all_results)
    )
    if cleanup_allowed:
        cleanup_cache(cleaned_root, selected_labs, active_cache_keys)

    if not args.dry_run:
        log_path = cleaned_root / "运行日志" / (
            f"代码差异报告工具-{datetime.now().strftime('%Y%m%d-%H%M%S-%f')}.log"
        )
        assert_safe_path(log_path, "拒绝通过链接访问运行日志")
        atomic_write(log_path, "\n".join(
            f"{result.lab} {result.student.student_id}-{result.student.name} "
            f"{result.cache_state} {result.status} {result.message}"
            for result in all_results
        ) + "\n")

    return 1 if any(result.status in {"失败", "部分失败"} for result in all_results) else 0


if __name__ == "__main__":
    raise SystemExit(main())
