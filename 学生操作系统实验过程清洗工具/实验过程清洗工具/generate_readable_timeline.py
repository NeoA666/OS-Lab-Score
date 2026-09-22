"""从既有时间线 JSON 生成仅供阅读的简洁 Markdown 时间线。"""

from __future__ import annotations

import argparse
from datetime import datetime, timedelta, timezone
import json
from pathlib import Path
import re
import sys

from timeline_reports import (
    LAB_KEYS,
    TIMELINE_DIRECTORY,
    TIMELINE_MANIFEST,
    TIMELINE_TOOL,
    has_link_component,
    is_link_like,
    timeline_paths,
)

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from output_layout import PERSON_VIEW, PROCESS_TOOL, unlink_pair, write_text_pair


SOURCE_DIRECTORY = "实验过程时间线"
OUTPUT_DIRECTORY = "简洁实验过程时间线"
OUTPUT_MANIFEST = ".readable_timeline_manifest.json"
TOOL_NAME = "generate_readable_timeline"
JSON_NAME = re.compile(r"^timeline_(lab[0-8]|other)\.json$")
MARKDOWN_NAME = re.compile(r"^timeline_(lab[0-8]|other)\.md$")
CURRENT_OUTPUT_NAME = "简洁实验过程时间线.md"
CURRENT_ARTIFACT = re.compile(
    rf"^(?:lab[0-8]|其他)/{re.escape(PROCESS_TOOL)}/{re.escape(CURRENT_OUTPUT_NAME)}$"
)
DEFAULT_CLEANED_ROOT = Path(__file__).resolve().parents[2] / "操作系统实验数据记录-已清洗"


def _atomic_write(path, text):
    write_text_pair(Path(path), text)


def _event_type_label(kind):
    return {
        "shell_command_observed": "Shell 命令",
        "claude_user_observed": "用户问题",
        "claude_reply_observed": "Claude 回复",
        "collection_log_evidence": "采集日志佐证（E2）",
    }.get(str(kind or ""), "未知")


def _is_collection_log_event(event):
    return bool(
        isinstance(event, dict)
        and (event.get("evidence_level") == "E2" or event.get("type") == "collection_log_evidence")
    )


def _event_time(event):
    value = event.get("logged_at") if _is_collection_log_event(event) else event.get("observed_at")
    if value is None:
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


def _collection_log_lines(event):
    source = event.get("source") if isinstance(event.get("source"), dict) else {}
    association = event.get("association") if isinstance(event.get("association"), dict) else {}
    source_time = source.get("time") if isinstance(source.get("time"), dict) else {}
    line = source.get("line")
    return [
        f"- 证据类型：{_event_type_label(event.get('type'))}",
        f"- 采集日志类型：{event.get('log_event_type') or 'unknown'}",
        f"- 源行号：{source.get('log') or 'logs/events.jsonl'} 第 {line if line is not None else '未知'} 行",
        f"- 关联置信度：{association.get('confidence') or 'unlinked'}",
        f"- 关联录像：{association.get('recording_id') or '无'}",
        f"- 时间语义：{event.get('observation_semantics') or source_time.get('semantics') or '采集日志时间'}",
        "- 终端屏幕证据：无；本条仅为 E2 采集日志佐证。",
    ]


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
        collection_log = _is_collection_log_event(event)
        lines.extend([
            f"### {'采集日志时间' if collection_log else '录像时间'}：{_event_time(event)}",
            "",
        ])
        if collection_log:
            lines.extend(_collection_log_lines(event))
        else:
            lines.append(f"- 录像类型：{_event_type_label(event.get('type'))}")
        lines.extend(["", "- 内容：", ""])
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


def _safe_child(root, relative):
    candidate = Path(root) / Path(relative)
    if has_link_component(candidate):
        return None
    try:
        if Path(root).resolve() not in candidate.resolve().parents:
            return None
    except OSError:
        return None
    return candidate


def _current_source_id(manifest):
    source = manifest.get("source") if isinstance(manifest, dict) else None
    if not isinstance(source, str) or not source:
        return None
    return f"{TIMELINE_DIRECTORY}/{TIMELINE_MANIFEST}:{source}"


def _current_output_relative(lab):
    json_relative, _ = timeline_paths(lab)
    return json_relative.parent / CURRENT_OUTPUT_NAME


def _current_source_timeline_files(student_directory):
    """Read the current dual-view producer manifest without trusting paths in it."""
    student = Path(student_directory)
    manifest_path = student / TIMELINE_DIRECTORY / TIMELINE_MANIFEST
    if not manifest_path.exists():
        return None, None, None
    if has_link_component(manifest_path):
        return [], None, f"时间线归属清单是符号链接：{manifest_path}"
    manifest = _read_manifest(manifest_path)
    source_id = _current_source_id(manifest)
    if not (
        isinstance(manifest, dict)
        and manifest.get("tool") == TIMELINE_TOOL
        and source_id is not None
        and isinstance(manifest.get("artifacts"), list)
    ):
        return [], None, f"时间线归属清单无效：{manifest_path}"
    artifacts = manifest["artifacts"]
    if not all(isinstance(item, str) for item in artifacts):
        return [], source_id, f"时间线归属清单含无效或重复产物：{manifest_path}"
    if len(set(artifacts)) != len(artifacts):
        return [], source_id, f"时间线归属清单含无效或重复产物：{manifest_path}"
    if manifest.get("status") == "cleared" and artifacts == []:
        return [], source_id, None
    if manifest.get("status") not in {"complete", "partial"}:
        return [], source_id, f"时间线归属清单尚未完成：{manifest_path}"

    expected = {}
    for lab in LAB_KEYS:
        json_relative, markdown_relative = timeline_paths(lab)
        expected[json_relative.as_posix()] = (lab, "json", json_relative)
        expected[markdown_relative.as_posix()] = (lab, "markdown", markdown_relative)
    registered = set(artifacts)
    if not registered or not registered <= set(expected):
        return [], source_id, f"时间线归属清单含未知或越界产物：{manifest_path}"

    source_files = []
    for lab in LAB_KEYS:
        json_relative, markdown_relative = timeline_paths(lab)
        expected_pair = {json_relative.as_posix(), markdown_relative.as_posix()}
        present = expected_pair & registered
        if present and present != expected_pair:
            return [], source_id, f"时间线归属清单缺少 {lab} 的 JSON/Markdown 成对产物：{manifest_path}"
        if not present:
            continue
        source_file = _safe_child(student, json_relative)
        if source_file is None or not source_file.is_file():
            return [], source_id, f"时间线归属清单登记的 JSON 不可用：{student / json_relative}"
        source_markdown = _safe_child(student, markdown_relative)
        if source_markdown is None or not source_markdown.is_file():
            return [], source_id, f"时间线归属清单登记的 Markdown 不可用：{student / markdown_relative}"
        source_files.append((source_file, _current_output_relative(lab)))
    return source_files, source_id, None


def _legacy_source_timeline_files(source):
    """Return legacy flat artifacts while retaining its historical manifest rules."""
    source = Path(source)
    producer_manifest = source / TIMELINE_MANIFEST
    if not producer_manifest.exists():
        source_files = [
            path for path in sorted(source.glob("timeline_*.json"))
            if JSON_NAME.fullmatch(path.name) and not is_link_like(path)
        ]
        return [(path, path.with_suffix(".md").name) for path in source_files], None
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
    if not all(isinstance(relative, str) for relative in artifacts) or len(set(artifacts)) != len(artifacts):
        return [], f"时间线归属清单含无效或重复产物：{producer_manifest}"
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
        source_files.append((source_file, source_file.with_suffix(".md").name))
    return source_files, None


def _discover_source(student_directory):
    """Resolve current dual-view input first, then a legacy flat directory."""
    current_files, current_id, current_error = _current_source_timeline_files(student_directory)
    if current_files is not None:
        return current_files, current_id, "current", current_error
    source = Path(student_directory) / SOURCE_DIRECTORY
    if source.exists() and is_link_like(source):
        return [], SOURCE_DIRECTORY, "legacy", f"时间线目录是符号链接：{source}"
    legacy_files, legacy_error = _legacy_source_timeline_files(source)
    return legacy_files, SOURCE_DIRECTORY, "legacy", legacy_error


def _readable_manifest_path(student_directory, layout):
    student = Path(student_directory)
    if layout == "current":
        return student / TIMELINE_DIRECTORY / OUTPUT_MANIFEST
    return student / OUTPUT_DIRECTORY / OUTPUT_MANIFEST


def _manifest_layout(manifest):
    if not isinstance(manifest, dict):
        return None
    layout = manifest.get("layout")
    if layout in {"current", "legacy"}:
        return layout
    if manifest.get("source") == SOURCE_DIRECTORY:
        return "legacy"
    return None


def _manifest_matches(manifest, source_id, layout):
    return bool(
        isinstance(manifest, dict)
        and manifest.get("tool") == TOOL_NAME
        and manifest.get("source") == source_id
        and _manifest_layout(manifest) == layout
    )


def _owned_artifact(student_directory, name, layout):
    if not isinstance(name, str):
        return None
    student = Path(student_directory)
    if layout == "current":
        if not CURRENT_ARTIFACT.fullmatch(name):
            return None
        return _safe_child(student, name)
    if layout == "legacy" and MARKDOWN_NAME.fullmatch(name):
        return _safe_child(student / OUTPUT_DIRECTORY, name)
    return None


def _clear_owned_output(student_directory, manifest_path, existing, source_id, layout):
    if not _manifest_matches(existing, source_id, layout):
        return
    for name in existing.get("artifacts", []):
        artifact = _owned_artifact(student_directory, name, layout)
        if artifact is not None and artifact.is_file():
            unlink_pair(artifact)
    _atomic_write(manifest_path, json.dumps({
        "tool": TOOL_NAME,
        "source": source_id,
        "layout": layout,
        "artifacts": [],
    }, ensure_ascii=False, indent=2) + "\n")


def _target_file(student_directory, relative, layout):
    student = Path(student_directory)
    if layout == "current":
        return _safe_child(student, relative)
    return _safe_child(student / OUTPUT_DIRECTORY, relative)


def write_student(student_directory):
    student = Path(student_directory)
    if has_link_component(student):
        raise ValueError(f"拒绝使用符号链接学生目录：{student}")
    student = student.resolve()
    source_files, source_id, layout, source_error = _discover_source(student)
    if source_id is None:
        return []
    manifest_path = _readable_manifest_path(student, layout)
    if has_link_component(manifest_path):
        raise ValueError(f"拒绝覆盖符号链接简洁时间线清单：{manifest_path}")
    existing = _read_manifest(manifest_path)
    if source_error:
        _clear_owned_output(student, manifest_path, existing, source_id, layout)
        raise ValueError(source_error)
    if not source_files:
        _clear_owned_output(student, manifest_path, existing, source_id, layout)
        return []
    if manifest_path.exists() and not _manifest_matches(existing, source_id, layout):
        raise ValueError(f"简洁时间线目录已有其他来源：{manifest_path.parent}")

    rendered = []
    for source_file, target_relative in source_files:
        try:
            document = json.loads(source_file.read_text(encoding="utf-8"))
        except (OSError, TypeError, ValueError) as exc:
            raise ValueError(f"无法读取 {source_file}: {exc}") from exc
        if not isinstance(document, dict):
            raise ValueError(f"时间线 JSON 不是对象：{source_file}")
        target_file = _target_file(student, target_relative, layout)
        if target_file is None:
            raise ValueError(f"简洁时间线目标越出学生目录：{target_relative}")
        rendered.append((target_file, Path(target_relative).as_posix(), render(document)))

    for target_file, _, text in rendered:
        _atomic_write(target_file, text)
    wanted = {relative for _, relative, _ in rendered}
    if existing:
        for name in existing.get("artifacts", []):
            if name in wanted:
                continue
            artifact = _owned_artifact(student, name, layout)
            if artifact is not None and artifact.is_file():
                unlink_pair(artifact)
    _atomic_write(manifest_path, json.dumps({
        "tool": TOOL_NAME,
        "source": source_id,
        "layout": layout,
        "artifacts": sorted(wanted),
    }, ensure_ascii=False, indent=2) + "\n")
    return [path for path, _, _ in rendered]


def _student_candidates(root):
    """Prefer the canonical person view while still accepting legacy roots."""
    root = Path(root)
    person_root = root if root.name == PERSON_VIEW else root / PERSON_VIEW
    if person_root.is_dir():
        if has_link_component(person_root):
            raise ValueError(f"按人分类目录不得为符号链接或 junction：{person_root}")
        return sorted(
            path for path in person_root.iterdir()
            if path.is_dir() and not is_link_like(path)
        )
    if (root / TIMELINE_DIRECTORY).exists() or (root / SOURCE_DIRECTORY).exists():
        return [root]
    return sorted(path for path in root.iterdir() if path.is_dir() and not is_link_like(path))


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
    try:
        candidates = _student_candidates(root)
    except ValueError as exc:
        parser.error(str(exc))
    if args.students:
        requested = set(args.students)
        candidates = [path for path in candidates if path.name in requested]
        missing = sorted(requested - {path.name for path in candidates})
        if missing:
            parser.error("未找到学生输出目录：" + "、".join(missing))
    for student in candidates:
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
