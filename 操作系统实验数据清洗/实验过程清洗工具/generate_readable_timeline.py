"""从既有时间线 JSON 生成仅供阅读的简洁 Markdown 时间线。"""

from __future__ import annotations

import argparse
from datetime import datetime, timedelta, timezone
import json
import os
from pathlib import Path
import re
import tempfile

from timeline_reports import (
    TIMELINE_MANIFEST,
    TIMELINE_DIRECTORY,
    timeline_paths,
    _ARTIFACT_RE,
    _timeline_artifacts_are_complete,
    write_text_pair,
    unlink_pair,
    TIMELINE_TOOL,
    has_link_component,
    is_link_like,
)


SOURCE_DIRECTORY = TIMELINE_DIRECTORY
OUTPUT_DIRECTORY = TIMELINE_DIRECTORY
OUTPUT_MANIFEST = ".readable_timeline_manifest.json"
TOOL_NAME = "generate_readable_timeline"
DEFAULT_CLEANED_ROOT = Path(__file__).resolve().parent.parent / "操作系统实验数据记录-已清洗"


def _atomic_write(path, text):
    write_text_pair(path, text)


def _event_type_label(kind):
    return {
        "shell_command_observed": "Shell 命令",
        "claude_user_observed": "用户问题",
        "claude_reply_observed": "Claude 回复",
    }.get(str(kind or ""), "未知")


def _event_time(event):
    value = event.get("observed_at")
    try:
        parsed = datetime.fromisoformat(str(value).replace("Z", "+00:00"))
        if parsed.tzinfo is not None:
            china = parsed.astimezone(timezone(timedelta(hours=8)))
            return china.isoformat(timespec="milliseconds") + "（北京时间）"
    except (TypeError, ValueError, OverflowError):
        pass
    elapsed = event.get("elapsed_seconds")
    try:
        return f"录像内 +{float(elapsed):.6f} 秒"
    except (TypeError, ValueError):
        return "未知"


def _append_fenced(lines, text):
    text = str(text or "")
    longest = max((len(match.group(0)) for match in re.finditer(r"`+", text)), default=0)
    fence = "`" * max(3, longest + 1)
    lines.extend([fence + "text", *text.splitlines(), fence])


def _content(event):
    content = str(event.get("content") or "")
    output = event.get("output_lines", event.get("output"))
    if isinstance(output, list):
        output = "\n".join(map(str, output))
    if output:
        content += ("\n\n" if content else "") + "[终端输出]\n" + str(output)
    return content


def render(document):
    student = document.get("student") if isinstance(document.get("student"), dict) else {}
    lab = document.get("lab") or "other"
    events = document.get("events") if isinstance(document.get("events"), list) else []
    lines = [
        "# 简洁实验过程时间线", "",
        f"- 学号：{student.get('student_id') or '未知'}",
        f"- 姓名：{student.get('name') or '未知'}",
        f"- 实验分类：{lab}",
        "",
        "## 过程",
        "",
    ]
    if not events:
        lines.extend(["暂无可展示内容。", ""])
        return "\n".join(lines)
    for event in events:
        if not isinstance(event, dict):
            continue
        lines.extend([
            f"### 录像时间：{_event_time(event)}",
            "",
            f"- 录像类型：{_event_type_label(event.get('type'))}",
            "",
            "- 内容：",
            "",
        ])
        _append_fenced(lines, _content(event))
        lines.append("")
    return "\n".join(lines)


def _read_manifest(path):
    if has_link_component(path):
        return None
    try:
        value = json.loads(Path(path).read_text(encoding="utf-8"))
    except (OSError, TypeError, ValueError):
        return None
    return value if isinstance(value, dict) else None


def _owned_artifact(target, name):
    if not isinstance(name, str) or not re.fullmatch(r"(?:lab[0-8]|其他)/实验过程清洗工具/简洁实验过程时间线\.md", name):
        return None
    candidate = Path(target) / name
    if has_link_component(candidate):
        return None
    return candidate if Path(target).resolve() in candidate.resolve().parents else None


def _source_timeline_files(source):
    source = Path(source)
    student = source.parent
    for lab in [*(f"lab{i}" for i in range(9)), "其他"]:
        if has_link_component(student / lab / "实验过程清洗工具"):
            raise ValueError(f"拒绝使用符号链接时间线目录：{student / lab}")
    producer_manifest = source / TIMELINE_MANIFEST
    if not producer_manifest.exists():
        return [p for p in sorted(student.glob("*/实验过程清洗工具/实验过程时间线.json")) if _ARTIFACT_RE.fullmatch(p.relative_to(student).as_posix()) and not has_link_component(p)], None
    manifest = _read_manifest(producer_manifest)
    if isinstance(manifest, dict) and manifest.get("tool") == TIMELINE_TOOL and manifest.get("status") == "cleared" and manifest.get("artifacts") == []:
        return [], None
    if not isinstance(manifest, dict) or manifest.get("tool") != TIMELINE_TOOL or manifest.get("status") not in {"complete", "partial"}:
        return [], f"时间线归属清单无效或尚未完成：{producer_manifest}"
    artifacts = manifest.get("artifacts")
    if not _timeline_artifacts_are_complete(student, artifacts):
        return [], f"时间线归属清单产物无效或缺失：{producer_manifest}"
    return [student / item for item in artifacts if item.endswith(".json")], None


def _clear_owned_output(target, manifest_path, existing, source_id):
    if not isinstance(existing, dict) or existing.get("tool") != TOOL_NAME or existing.get("source") != source_id:
        return
    for name in existing.get("artifacts", []):
        artifact = _owned_artifact(target, name)
        if artifact is not None:
            unlink_pair(artifact)
    _atomic_write(manifest_path, json.dumps({"tool": TOOL_NAME, "source": source_id, "artifacts": []}, ensure_ascii=False, indent=2) + "\n")


def write_student(student_directory):
    student = Path(student_directory)
    source = student / SOURCE_DIRECTORY
    if has_link_component(student) or has_link_component(source):
        raise ValueError(f"拒绝使用符号链接学生目录：{student}")
    manifest_path = source / OUTPUT_MANIFEST
    if has_link_component(manifest_path):
        raise ValueError(f"拒绝使用符号链接归属清单：{manifest_path}")
    existing = _read_manifest(manifest_path)
    source_id = str(source.resolve())
    if manifest_path.exists() and (not existing or existing.get("tool") != TOOL_NAME or existing.get("source") != source_id):
        raise ValueError(f"简洁时间线目录已有其他来源：{manifest_path}")
    files, error = _source_timeline_files(source)
    if error or not files:
        _clear_owned_output(student, manifest_path, existing, source_id)
        if error:
            raise ValueError(error)
        return []
    rendered = []
    for file in files:
        document = json.loads(file.read_text(encoding="utf-8"))
        if not isinstance(document, dict):
            raise ValueError(f"时间线 JSON 不是对象：{file}")
        target = file.with_name("简洁实验过程时间线.md")
        rendered.append((target, render(document)))
    for target, text in rendered:
        _atomic_write(target, text)
    wanted = {target.relative_to(student).as_posix() for target, _ in rendered}
    if existing:
        for name in existing.get("artifacts", []):
            if name not in wanted:
                artifact = _owned_artifact(student, name)
                if artifact is not None:
                    unlink_pair(artifact)
    _atomic_write(manifest_path, json.dumps({"tool": TOOL_NAME, "source": source_id, "artifacts": sorted(wanted)}, ensure_ascii=False, indent=2) + "\n")
    return [path for path, _ in rendered]


def main(argv=None):
    parser = argparse.ArgumentParser(
        description="从既有时间线 JSON 生成仅含录像时间、录像类型和内容的简洁 Markdown 时间线。"
    )
    parser.add_argument(
        "input_dir", nargs="?", default=str(DEFAULT_CLEANED_ROOT),
        help="包含学生目录的清洗结果根目录",
    )
    parser.add_argument(
        "--student", action="append", dest="students",
        help="仅处理指定的学生输出目录名；可重复指定",
    )
    args = parser.parse_args(argv)
    root_path = Path(args.input_dir)
    if has_link_component(root_path):
        parser.error(f"目录不得为符号链接或 junction：{root_path}")
    root = root_path.resolve()
    if (root / "按人分类").is_dir():
        root = root / "按人分类"
    if not root.is_dir():
        parser.error(f"目录不存在：{root}")

    processed = 0
    files = 0
    failures = []
    candidates = sorted(path for path in root.iterdir() if path.is_dir() and not is_link_like(path))
    if args.students:
        requested = set(args.students)
        candidates = [path for path in candidates if path.name in requested]
        missing = sorted(requested - {path.name for path in candidates})
        if missing:
            parser.error("未找到学生输出目录：" + "、".join(missing))
    for student in candidates:
        if is_link_like(student / SOURCE_DIRECTORY) or not (student / SOURCE_DIRECTORY).is_dir():
            continue
        try:
            output = write_student(student)
            if output:
                processed += 1
                files += len(output)
                print(f"{student.name}: {len(output)} 份简洁时间线")
        except Exception as exc:
            failures.append(f"{student.name}: {type(exc).__name__}: {exc}")
    print(f"完成：{processed} 名学生，{files} 份简洁时间线。")
    for failure in failures:
        print(f"失败：{failure}")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
