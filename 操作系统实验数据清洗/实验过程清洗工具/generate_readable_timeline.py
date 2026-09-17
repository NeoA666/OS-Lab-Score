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
    TIMELINE_TOOL,
    has_link_component,
    is_link_like,
)


SOURCE_DIRECTORY = "实验过程时间线"
OUTPUT_DIRECTORY = "简洁实验过程时间线"
OUTPUT_MANIFEST = ".readable_timeline_manifest.json"
TOOL_NAME = "generate_readable_timeline"
JSON_NAME = re.compile(r"^timeline_(lab[0-8]|other)\.json$")
MARKDOWN_NAME = re.compile(r"^timeline_(lab[0-8]|other)\.md$")
DEFAULT_CLEANED_ROOT = Path(__file__).resolve().parent.parent / "操作系统实验数据记录-已清洗"


def _atomic_write(path, text):
    path = Path(path)
    if has_link_component(path):
        raise ValueError(f"拒绝覆盖符号链接：{path}")
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(
            mode="w", encoding="utf-8", newline="\n", dir=path.parent,
            prefix=".readable-timeline-", suffix=".tmp", delete=False,
        ) as stream:
            temporary = Path(stream.name)
            stream.write(text)
        os.replace(temporary, path)
    finally:
        if temporary and temporary.exists():
            temporary.unlink()


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
    if not isinstance(name, str) or not MARKDOWN_NAME.fullmatch(name):
        return None
    candidate = Path(target) / name
    if has_link_component(candidate):
        return None
    try:
        if Path(target).resolve() not in candidate.resolve().parents:
            return None
    except OSError:
        return None
    return candidate


def _source_timeline_files(source):
    """Return current JSON artifacts, preferring the producer's manifest contract."""
    source = Path(source)
    producer_manifest = source / TIMELINE_MANIFEST
    if not producer_manifest.exists():
        return ([
            path for path in sorted(source.glob("timeline_*.json"))
            if JSON_NAME.fullmatch(path.name) and not is_link_like(path)
        ], None)
    manifest = _read_manifest(producer_manifest)
    if (
        isinstance(manifest, dict)
        and manifest.get("tool") == TIMELINE_TOOL
        and manifest.get("status") == "cleared"
        and manifest.get("artifacts") == []
    ):
        return [], None
    if not (
        isinstance(manifest, dict)
        and manifest.get("tool") == TIMELINE_TOOL
        and manifest.get("status") in {"complete", "partial"}
        and isinstance(manifest.get("artifacts"), list)
    ):
        return [], f"时间线归属清单无效或尚未完成：{producer_manifest}"
    artifacts = manifest["artifacts"]
    if not all(isinstance(relative, str) for relative in artifacts):
        return [], f"时间线归属清单含无效产物：{producer_manifest}"
    if len(set(artifacts)) != len(artifacts):
        return [], f"时间线归属清单含重复产物：{producer_manifest}"
    json_labs = set()
    markdown_labs = set()
    for relative in artifacts:
        path = Path(relative)
        if path.parent.as_posix() != SOURCE_DIRECTORY:
            return [], f"时间线归属清单含越界产物：{producer_manifest}"
        json_match = JSON_NAME.fullmatch(path.name)
        markdown_match = MARKDOWN_NAME.fullmatch(path.name)
        if json_match:
            json_labs.add(json_match.group(1))
        elif markdown_match:
            markdown_labs.add(markdown_match.group(1))
        else:
            return [], f"时间线归属清单含未知产物：{producer_manifest}"
    if not json_labs or json_labs != markdown_labs:
        return [], f"时间线归属清单缺少成对 JSON/Markdown 产物：{producer_manifest}"
    source_files = []
    for lab in sorted(json_labs):
        source_file = source / f"timeline_{lab}.json"
        if has_link_component(source_file) or not source_file.is_file():
            return [], f"时间线归属清单登记的 JSON 不可用：{source_file}"
        source_files.append(source_file)
    return source_files, None


def _clear_owned_output(target, manifest_path, existing, source_id):
    if not (
        isinstance(existing, dict)
        and existing.get("tool") == TOOL_NAME
        and existing.get("source") == source_id
    ):
        return
    for name in existing.get("artifacts", []):
        artifact = _owned_artifact(target, name)
        if artifact is not None and artifact.is_file():
            artifact.unlink()
    _atomic_write(manifest_path, json.dumps({
        "tool": TOOL_NAME,
        "source": source_id,
        "artifacts": [],
    }, ensure_ascii=False, indent=2) + "\n")


def write_student(student_directory):
    student_directory = Path(student_directory)
    if has_link_component(student_directory):
        raise ValueError(f"拒绝使用符号链接学生目录：{student_directory}")
    source = student_directory / SOURCE_DIRECTORY
    target = student_directory / OUTPUT_DIRECTORY
    if has_link_component(target):
        raise ValueError(f"拒绝使用符号链接输出目录：{target}")
    if student_directory.resolve() not in target.resolve().parents:
        raise ValueError(f"输出目录越出学生目录：{target}")

    manifest_path = target / OUTPUT_MANIFEST
    existing = _read_manifest(manifest_path)
    source_id = str(source.resolve())
    source_files, source_error = _source_timeline_files(source)
    if source_error:
        _clear_owned_output(target, manifest_path, existing, source_id)
        raise ValueError(source_error)
    if not source_files:
        _clear_owned_output(target, manifest_path, existing, source_id)
        return []

    if manifest_path.exists() and (
        not existing
        or existing.get("tool") != TOOL_NAME
        or existing.get("source") != source_id
    ):
        raise ValueError(f"简洁时间线目录已有其他来源：{target}")

    rendered = []
    for source_file in source_files:
        try:
            document = json.loads(source_file.read_text(encoding="utf-8"))
        except (OSError, TypeError, ValueError) as exc:
            raise ValueError(f"无法读取 {source_file}: {exc}") from exc
        if not isinstance(document, dict):
            raise ValueError(f"时间线 JSON 不是对象：{source_file}")
        target_file = target / source_file.with_suffix(".md").name
        rendered.append((target_file, render(document)))

    for target_file, text in rendered:
        _atomic_write(target_file, text)
    wanted = {path.name for path, _ in rendered}
    if existing:
        for name in existing.get("artifacts", []):
            if name in wanted:
                continue
            artifact = _owned_artifact(target, name)
            if artifact is not None and artifact.is_file():
                artifact.unlink()
    _atomic_write(manifest_path, json.dumps({
        "tool": TOOL_NAME,
        "source": source_id,
        "artifacts": sorted(wanted),
    }, ensure_ascii=False, indent=2) + "\n")
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
