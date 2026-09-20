#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""增量同步 oslab 上每位学生的最新 xv6 实验提交。

依赖：paramiko（可用 python3 -m pip install -r requirements.txt 安装）
运行：python3 sync_xv6_submissions.py

脚本只下载并解压归档，不执行归档中的任何学生代码。
"""

from __future__ import annotations

import hashlib
import json
import os
import re
import shutil
import stat
import sys
import tarfile
import tempfile
import uuid
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path, PurePosixPath
from typing import Any


TOOL_ROOT = Path(__file__).resolve().parent
REPOSITORY_ROOT = TOOL_ROOT.parent
OUTPUT_ROOT = REPOSITORY_ROOT / "操作系统实验数据记录"
SOURCE_MARKER = ".xv6-sync-source.json"

MAX_ARCHIVE_MEMBERS = 100_000
MAX_EXTRACTED_BYTES = 512 * 1024 * 1024
MAX_MEMBER_BYTES = 256 * 1024 * 1024
CHUNK_SIZE = 1024 * 1024

ARCHIVE_RE = re.compile(
    r"^(?P<student_id>[^-]+)-(?P<name>.+)-实验提交-"
    r"(?P<stamp>\d{8}-\d{4})(?:-(?P<suffix>\d+))?\.tar\.gz$"
)
LOCAL_DIR_RE = re.compile(
    r"^(?P<student_id>[^-]+)-(?P<name>.+)-(?P<stamp>\d{8}-\d{4})$"
)


@dataclass(frozen=True)
class Submission:
    student_id: str
    name: str
    filename: str
    remote_path: str
    index_time: str
    index_datetime: datetime
    size: int
    sha256: str
    submission_stamp: str


class SyncError(RuntimeError):
    """单个学生同步失败。"""


def required_environment(name: str) -> str:
    value = os.environ.get(name, "").strip()
    if not value:
        raise SyncError(f"缺少环境变量 {name}")
    return value


def connection_settings() -> tuple[str, int, str, str, str]:
    host = required_environment("OSLAB_SSH_HOST")
    username = required_environment("OSLAB_SSH_USERNAME")
    password = required_environment("OSLAB_SSH_PASSWORD")
    remote_root = required_environment("OSLAB_REMOTE_ROOT")
    try:
        port = int(os.environ.get("OSLAB_SSH_PORT", "22"))
    except ValueError as exc:
        raise SyncError("环境变量 OSLAB_SSH_PORT 必须是有效端口号") from exc
    if not 1 <= port <= 65535:
        raise SyncError("环境变量 OSLAB_SSH_PORT 必须介于 1 和 65535")
    return host, port, username, password, remote_root.rstrip("/")


def parse_index_time(value: Any) -> tuple[str, datetime]:
    if not isinstance(value, str) or not value.strip():
        raise ValueError("index.jsonl 缺少有效 time")
    raw = value.strip()
    normalized = raw[:-1] + "+00:00" if raw.endswith("Z") else raw
    parsed = datetime.fromisoformat(normalized)
    if parsed.tzinfo is None:
        parsed = parsed.replace(tzinfo=timezone.utc)
    return raw, parsed.astimezone(timezone.utc)


def parse_archive_name(filename: str) -> tuple[str, str, str]:
    match = ARCHIVE_RE.fullmatch(filename)
    if not match:
        raise ValueError(f"无法从归档文件名解析学生信息：{filename}")
    student_id = match.group("student_id")
    name = match.group("name")
    stamp = match.group("stamp")
    validate_component(student_id, "学号")
    validate_component(name, "姓名")
    return student_id, name, stamp


def validate_component(value: str, label: str) -> None:
    if (
        not value
        or value in {".", ".."}
        or "/" in value
        or "\\" in value
        or "\x00" in value
        or value.endswith((".", " "))
        or re.search(r"[<>:\"|?*\x00-\x1f]", value)
    ):
        raise SyncError(f"{label}包含不安全字符：{value!r}")


def parse_index_row(row: dict[str, Any], date_dir: str, remote_root: str) -> Submission:
    filename = row.get("file")
    if not isinstance(filename, str) or Path(filename).name != filename:
        raise ValueError(f"归档文件名不是普通文件名：{filename!r}")
    student_id, name, stamp = parse_archive_name(filename)

    index_time, index_datetime = parse_index_time(row.get("time"))
    size = row.get("size")
    if type(size) is not int or size < 0:
        raise ValueError(f"归档大小无效：{filename}")
    sha256 = row.get("sha256")
    if not isinstance(sha256, str) or not re.fullmatch(r"[0-9a-fA-F]{64}", sha256):
        raise ValueError(f"归档 SHA-256 无效：{filename}")

    return Submission(
        student_id=student_id,
        name=name,
        filename=filename,
        remote_path=f"{remote_root}/{date_dir}/{filename}",
        index_time=index_time,
        index_datetime=index_datetime,
        size=size,
        sha256=sha256.lower(),
        submission_stamp=stamp,
    )


def read_remote_indexes(sftp: Any, remote_root: str) -> tuple[dict[str, Submission], list[str]]:
    """读取所有日期目录的 index.jsonl，并按学号选最新一条。"""
    candidates: dict[str, list[Submission]] = {}
    warnings: list[str] = []

    for entry in sorted(sftp.listdir_attr(remote_root), key=lambda item: item.filename):
        if not stat.S_ISDIR(entry.st_mode) or not re.fullmatch(r"\d{8}", entry.filename):
            continue
        index_path = f"{remote_root}/{entry.filename}/index.jsonl"
        try:
            with sftp.open(index_path, "r") as stream:
                text = stream.read().decode("utf-8")
        except FileNotFoundError:
            warnings.append(f"缺少索引：{index_path}")
            continue
        except Exception as exc:
            warnings.append(f"读取索引失败：{index_path}（{exc}）")
            continue

        for line_number, line in enumerate(text.splitlines(), 1):
            if not line.strip():
                continue
            try:
                row = json.loads(line)
                if not isinstance(row, dict):
                    raise ValueError("索引行不是 JSON 对象")
                submission = parse_index_row(row, entry.filename, remote_root)
            except (json.JSONDecodeError, ValueError, SyncError) as exc:
                warnings.append(f"忽略无效索引 {index_path}:{line_number}（{exc}）")
                continue
            candidates.setdefault(submission.student_id, []).append(submission)

    latest: dict[str, Submission] = {}
    for student_id, submissions in candidates.items():
        # 同一上传时间时按完整文件名排序，取排序靠后的归档。
        latest[student_id] = max(
            submissions, key=lambda item: (item.index_datetime, item.filename)
        )
    return latest, warnings


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        while True:
            chunk = stream.read(CHUNK_SIZE)
            if not chunk:
                break
            digest.update(chunk)
    return digest.hexdigest()


def source_marker(path: Path) -> dict[str, Any] | None:
    marker = path / SOURCE_MARKER
    try:
        data = json.loads(marker.read_text(encoding="utf-8"))
    except (FileNotFoundError, OSError, UnicodeDecodeError, json.JSONDecodeError):
        return None
    return data if isinstance(data, dict) else None


def local_student_dirs(student_id: str) -> list[Path]:
    if not OUTPUT_ROOT.exists():
        return []
    matches: list[Path] = []
    for child in OUTPUT_ROOT.iterdir():
        if not child.name.startswith(f"{student_id}-"):
            continue
        if child.is_symlink():
            raise SyncError(f"拒绝处理学生目录符号链接：{child}")
        if child.is_dir():
            matches.append(child)
    return matches


def target_dir_for(submission: Submission) -> Path:
    return OUTPUT_ROOT / f"{submission.student_id}-{submission.name}-{submission.submission_stamp}"


def is_current(local_dirs: list[Path], submission: Submission) -> bool:
    for directory in local_dirs:
        marker = source_marker(directory)
        if marker and marker.get("archive_sha256") == submission.sha256:
            return True
    # 兼容旧目录：目录名时间一致时视为已是同一提交；首次遇到并列归档会被重新同步，
    # 因为旧目录没有 source marker，无法确认它对应哪一个归档。
    return False


def safe_member_path(raw_name: str) -> PurePosixPath | None:
    if not isinstance(raw_name, str) or not raw_name:
        raise SyncError("归档成员路径为空")
    if "\\" in raw_name or raw_name.startswith("/") or re.match(r"^[A-Za-z]:", raw_name):
        raise SyncError(f"拒绝不安全归档路径：{raw_name!r}")

    parts = raw_name.split("/")
    while parts and parts[0] in {"", "."}:
        parts.pop(0)
    if not parts:
        return None
    if any(part in {"", ".", ".."} for part in parts):
        raise SyncError(f"拒绝不安全归档路径：{raw_name!r}")
    if any("\x00" in part or part.endswith((".", " ")) for part in parts):
        raise SyncError(f"拒绝跨平台不安全归档路径：{raw_name!r}")
    # 使用单个 POSIX 字符串构造，兼容 Python 3.11+，也避免极深成员路径
    # 在不同 pathlib 版本中出现多参数构造差异。
    return PurePosixPath("/".join(parts))


def safe_extract(archive_path: Path, destination: Path) -> None:
    destination.mkdir(parents=True, exist_ok=False)
    seen: dict[str, str] = {}
    members: list[tuple[tarfile.TarInfo, PurePosixPath]] = []
    total_size = 0

    try:
        with tarfile.open(archive_path, "r:gz") as archive:
            for index, member in enumerate(archive):
                if index >= MAX_ARCHIVE_MEMBERS:
                    raise SyncError("归档成员数量超过限制")
                relative = safe_member_path(member.name)
                if relative is None:
                    continue
                key = relative.as_posix().casefold()
                if key in seen:
                    raise SyncError(f"归档包含重复路径：{member.name}")
                if member.issym() or member.islnk() or not (member.isdir() or member.isfile()):
                    raise SyncError(f"拒绝链接或特殊归档成员：{member.name}")
                if member.isfile():
                    if member.size < 0 or member.size > MAX_MEMBER_BYTES:
                        raise SyncError(f"归档成员大小超限：{member.name}")
                    total_size += member.size
                    if total_size > MAX_EXTRACTED_BYTES:
                        raise SyncError("归档展开总大小超过限制")
                    kind = "file"
                else:
                    kind = "dir"
                seen[key] = kind
                members.append((member, relative))

            for _, relative in members:
                for parent in relative.parents:
                    if parent == PurePosixPath("."):
                        continue
                    if seen.get(parent.as_posix().casefold()) == "file":
                        raise SyncError(f"归档存在文件/目录路径冲突：{relative}")

            root = destination.resolve()
            for member, relative in members:
                output = destination.joinpath(*relative.parts)
                try:
                    output.resolve().relative_to(root)
                except ValueError as exc:
                    raise SyncError(f"归档路径逃逸目标目录：{member.name}") from exc
                if member.isdir():
                    output.mkdir(parents=True, exist_ok=True)
                    continue
                output.parent.mkdir(parents=True, exist_ok=True)
                source = archive.extractfile(member)
                if source is None:
                    raise SyncError(f"无法读取归档成员：{member.name}")
                with source, output.open("xb") as target:
                    shutil.copyfileobj(source, target, CHUNK_SIZE)
    except (tarfile.TarError, OSError) as exc:
        if isinstance(exc, SyncError):
            raise
        raise SyncError(f"解压失败：{exc}") from exc


def write_source_marker(destination: Path, submission: Submission) -> None:
    marker = {
        "version": 1,
        "student_id": submission.student_id,
        "name": submission.name,
        "archive_name": submission.filename,
        "remote_path": submission.remote_path,
        "submission_time": submission.index_time,
        "archive_size": submission.size,
        "archive_sha256": submission.sha256,
        "synced_at": datetime.now(timezone.utc).isoformat(),
    }
    marker_path = destination / SOURCE_MARKER
    marker_path.write_text(
        json.dumps(marker, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )


def commit_student(staging: Path, target: Path, old_dirs: list[Path]) -> None:
    backup: Path | None = None
    committed_path: Path | None = None
    try:
        backup = Path(tempfile.mkdtemp(prefix=".xv6-old-", dir=OUTPUT_ROOT.parent))
        for old_dir in old_dirs:
            backup_path = backup / old_dir.name
            old_dir.rename(backup_path)
        committed_path = target.parent / f".xv6-commit-{uuid.uuid4().hex}"
        staging.rename(committed_path)
        committed_path.rename(target)
        shutil.rmtree(backup)
    except Exception:
        if committed_path is not None and committed_path.exists():
            shutil.rmtree(committed_path, ignore_errors=True)
        if backup is not None and backup.exists():
            for backup_path in sorted(backup.iterdir(), key=lambda item: len(item.parts), reverse=True):
                original = OUTPUT_ROOT / backup_path.name
                if not original.exists():
                    backup_path.rename(original)
            shutil.rmtree(backup, ignore_errors=True)
        if staging.exists():
            shutil.rmtree(staging, ignore_errors=True)
        raise


def sync_one(sftp: Any, submission: Submission) -> str:
    OUTPUT_ROOT.mkdir(parents=True, exist_ok=True)
    old_dirs = local_student_dirs(submission.student_id)
    if is_current(old_dirs, submission):
        return "SKIPPED"

    status = "UPDATED" if old_dirs else "ADDED"
    temp_root = Path(tempfile.mkdtemp(prefix=".xv6-sync-", dir=OUTPUT_ROOT.parent))
    archive_path = temp_root / (submission.filename + ".part")
    staging = temp_root / "staging"
    try:
        sftp.get(submission.remote_path, str(archive_path))
        actual_size = archive_path.stat().st_size
        if actual_size != submission.size:
            raise SyncError(
                f"文件大小不一致：期望 {submission.size}，实际 {actual_size}"
            )
        actual_sha256 = sha256_file(archive_path)
        if actual_sha256 != submission.sha256:
            raise SyncError(
                f"SHA-256 不一致：期望 {submission.sha256}，实际 {actual_sha256}"
            )

        safe_extract(archive_path, staging)
        write_source_marker(staging, submission)
        commit_student(staging, target_dir_for(submission), old_dirs)
        return status
    finally:
        shutil.rmtree(temp_root, ignore_errors=True)


def connect() -> tuple[Any, Any, str]:
    try:
        import paramiko
    except ImportError as exc:
        raise SyncError(
            "缺少 paramiko，请执行 python3 -m pip install -r requirements.txt"
        ) from exc

    host, port, username, password, remote_root = connection_settings()

    client = paramiko.SSHClient()
    client.load_system_host_keys()
    client.set_missing_host_key_policy(paramiko.RejectPolicy())
    try:
        client.connect(
            hostname=host,
            port=port,
            username=username,
            password=password,
            look_for_keys=False,
            allow_agent=False,
            timeout=30,
            banner_timeout=30,
            auth_timeout=30,
        )
        return client, client.open_sftp(), remote_root
    except Exception:
        client.close()
        raise


def main() -> int:
    try:
        client, sftp, remote_root = connect()
    except Exception as exc:
        print(f"连接服务器失败：{exc}", file=sys.stderr)
        return 1

    results: list[tuple[str, str, str]] = []
    try:
        latest, warnings = read_remote_indexes(sftp, remote_root)
        for warning in warnings:
            print(f"警告：{warning}", file=sys.stderr)
        if not latest:
            raise SyncError("没有从远端 index.jsonl 发现有效提交")

        for student_id in sorted(latest):
            submission = latest[student_id]
            try:
                status = sync_one(sftp, submission)
                print(f"{status}: {submission.student_id}-{submission.name} ({submission.filename})")
                results.append((status, submission.student_id, ""))
            except Exception as exc:
                reason = str(exc)
                print(f"FAILED: {submission.student_id}-{submission.name}：{reason}", file=sys.stderr)
                results.append(("FAILED", submission.student_id, reason))
    finally:
        sftp.close()
        client.close()

    counts = {status: sum(1 for item in results if item[0] == status)
              for status in ("ADDED", "UPDATED", "SKIPPED", "FAILED")}
    print(
        "汇总："
        f"新增 {counts['ADDED']}，"
        f"更新 {counts['UPDATED']}，"
        f"跳过 {counts['SKIPPED']}，"
        f"失败 {counts['FAILED']}"
    )
    return 1 if counts["FAILED"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
