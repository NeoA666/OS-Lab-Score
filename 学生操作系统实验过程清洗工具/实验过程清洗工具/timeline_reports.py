"""Write the independent JSON and Markdown experiment timelines safely."""

from __future__ import annotations

import hashlib
import json
import os
import re
import stat
import sys
import tempfile
from datetime import datetime, timedelta, timezone
from pathlib import Path
from urllib.parse import quote

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from output_layout import PROCESS_TOOL, pair_matches, unlink_pair, write_text_pair

TIMELINE_DIRECTORY = ".实验过程清洗工具"
TIMELINE_MANIFEST = ".timeline_manifest.json"
TIMELINE_TOOL = "replay_term_qa.timeline"
TIMELINE_SCHEMA_VERSION = 2
TIMELINE_CACHE_FORMAT_VERSION = 2
LAB_KEYS = tuple(f"lab{i}" for i in range(9)) + ("other",)
README_BLOCK_START = "<!-- replay_term_qa:timeline:start -->"
README_BLOCK_END = "<!-- replay_term_qa:timeline:end -->"
_ARTIFACT_RE = re.compile(
    rf"^(?:lab[0-8]|其他)/{re.escape(PROCESS_TOOL)}/实验过程时间线\.(?:json|md)$"
)


def is_link_like(path):
    """Return whether a path is a symlink or Windows reparse-point link."""
    path = Path(path)
    junction = getattr(path, "is_junction", None)
    try:
        if path.is_symlink() or bool(junction and junction()):
            return True
        attributes = getattr(os.lstat(path), "st_file_attributes", 0)
        reparse_point = getattr(stat, "FILE_ATTRIBUTE_REPARSE_POINT", 0)
        return bool(reparse_point and attributes & reparse_point)
    except FileNotFoundError:
        return False
    except OSError:
        return True


def has_link_component(path):
    """Reject a target when it or any existing parent is link-like."""
    current = Path(path)
    while True:
        if is_link_like(current):
            return True
        parent = current.parent
        if parent == current:
            return False
        current = parent


def _atomic_write(path, text):
    write_text_pair(Path(path), text)


def timeline_paths(lab):
    directory = "其他" if lab == "other" else lab
    folder = Path(directory) / PROCESS_TOOL
    return folder / "实验过程时间线.json", folder / "实验过程时间线.md"


def _stream_sha256(path):
    digest = hashlib.sha256()
    with Path(path).open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def _read_manifest(student_output):
    path = Path(student_output) / TIMELINE_DIRECTORY / TIMELINE_MANIFEST
    if has_link_component(path):
        return None
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, ValueError, TypeError):
        return None
    return value if isinstance(value, dict) else None


def _manifest_matches_source(manifest, source, legacy_source=None):
    return bool(
        isinstance(manifest, dict)
        and manifest.get("tool") == TIMELINE_TOOL
        and manifest.get("source") in {str(source), str(legacy_source)}
    )


def _source_reference(info):
    return str(info.get("source_reference", info.get("source", "")))


def _recoverable_invalid_manifest_artifacts(output, source):
    """Return artifacts that prove ownership when only the manifest is corrupt."""
    output = Path(output)
    timeline_dir = output / TIMELINE_DIRECTORY
    if has_link_component(timeline_dir) or not timeline_dir.is_dir():
        return None
    artifacts = []
    json_labs = set()
    markdown_labs = set()
    # A hidden manifest without the paired, classified artifacts cannot prove ownership.
    for lab in LAB_KEYS:
        json_relative, md_relative = timeline_paths(lab)
        json_file = output / json_relative
        md_file = output / md_relative
        if not json_file.exists() and not md_file.exists():
            continue
        if (is_link_like(json_file) or is_link_like(md_file)
                or not json_file.is_file() or not md_file.is_file()):
            return None
        try:
            document = json.loads(json_file.read_text(encoding="utf-8"))
        except (OSError, TypeError, ValueError):
            return None
        student = document.get("student") if isinstance(document, dict) else None
        if (not isinstance(student, dict) or document.get("lab") != lab
                or student.get("source") != str(source)):
            return None
        json_labs.add(lab)
        markdown_labs.add(lab)
        artifacts.extend((json_relative.as_posix(), md_relative.as_posix()))
    return artifacts if json_labs and markdown_labs == json_labs else None


def timeline_owned_by(student_output, source, info=None):
    """Return whether the independent timeline manifest owns this directory."""
    output = Path(student_output)
    manifest_path = output / TIMELINE_DIRECTORY / TIMELINE_MANIFEST
    if has_link_component(manifest_path):
        return False
    manifest = _read_manifest(output)
    if _manifest_matches_source(manifest, source):
        return True
    if manifest is not None or not manifest_path.exists():
        return False
    return _recoverable_invalid_manifest_artifacts(output, source) is not None


def _timeline_artifact_is_valid(output, relative):
    if not isinstance(relative, str) or not _ARTIFACT_RE.fullmatch(relative):
        return False
    target = Path(output) / Path(relative)
    if has_link_component(target) or not target.is_file():
        return False
    try:
        resolved = target.resolve()
        output = Path(output).resolve()
    except OSError:
        return False
    return output in resolved.parents


def _timeline_artifacts_are_complete(output, artifacts):
    if not isinstance(artifacts, list) or not artifacts or not all(isinstance(item, str) for item in artifacts):
        return False
    if len(set(artifacts)) != len(artifacts) or not all(
        _timeline_artifact_is_valid(output, relative) for relative in artifacts
    ):
        return False
    grouped = {}
    for relative in artifacts:
        path = Path(relative)
        match = re.fullmatch(r"实验过程时间线\.(json|md)", path.name)
        if not match or len(path.parts) != 3 or path.parts[0] not in {*LAB_KEYS[:-1], "其他"} or path.parts[1] != PROCESS_TOOL:
            return False
        grouped.setdefault(path.parts[0], set()).add(match.group(1))
    return bool(grouped) and all(kinds == {"json", "md"} for kinds in grouped.values())


def _timeline_artifact_hashes_are_valid(output, artifacts, hashes):
    if not isinstance(hashes, dict) or set(hashes) != set(artifacts):
        return False
    for relative in artifacts:
        digest = hashes.get(relative)
        if not isinstance(digest, str) or not re.fullmatch(r"[0-9a-f]{64}", digest):
            return False
        try:
            target = Path(output) / relative
            if _stream_sha256(target) != digest or not pair_matches(target):
                return False
        except OSError:
            return False
    return True


_TIMELINE_STAT_KEYS = (
    "recordings",
    "events",
    "terminal_screen_events",
    "collection_log_events",
    "absolute_time_events",
    "relative_time_only_events",
    "missing_time_events",
    "collection_log_time_events",
    "uncertain_events",
    "recording_failures",
    "processing_failures",
    "errors",
)


def _timeline_summary_is_valid(summary):
    if not isinstance(summary, dict) or not isinstance(summary.get("statistics"), dict):
        return False
    statistics = summary["statistics"]
    return (
        all(
            isinstance(statistics.get(key), int) and not isinstance(statistics.get(key), bool)
            for key in _TIMELINE_STAT_KEYS
        )
        and isinstance(statistics.get("by_type"), dict)
        and all(
            isinstance(key, str) and isinstance(value, int) and not isinstance(value, bool)
            for key, value in statistics["by_type"].items()
        )
    )


def timeline_cache_hit(info, snapshot, processor_signature):
    """Restore a cached timeline summary only after validating every artifact."""
    output = Path(info["output"])
    if not snapshot.get("cacheable") or has_link_component(output) or not output.is_dir():
        return None
    manifest = _read_manifest(output)
    if not isinstance(manifest, dict) or manifest.get("tool") != TIMELINE_TOOL:
        return None
    if (
        manifest.get("source") != _source_reference(info)
        or manifest.get("status") != "complete"
        or manifest.get("schema_version") != TIMELINE_SCHEMA_VERSION
        or manifest.get("cache_format_version") != TIMELINE_CACHE_FORMAT_VERSION
        or manifest.get("input_fingerprint") != snapshot.get("fingerprint")
        or manifest.get("processor_signature") != processor_signature
    ):
        return None
    artifacts = manifest.get("artifacts")
    summary = manifest.get("summary")
    if (
        not _timeline_summary_is_valid(summary)
        or not _timeline_artifacts_are_complete(output, artifacts)
        or not _timeline_artifact_hashes_are_valid(output, artifacts, manifest.get("artifact_sha256"))
    ):
        return None
    return {
        "info": info,
        "statistics": dict(summary["statistics"]),
        "artifacts": list(artifacts),
        "errors": [],
        "fatal_errors": [],
        "cache_hit": True,
        "status": "incremental_skip",
    }


def mark_timeline_rebuild(info, allow_invalid_manifest_recovery=False):
    """Invalidate a prior success before construction can leave partial output."""
    output = Path(info["output"])
    manifest_path = output / TIMELINE_DIRECTORY / TIMELINE_MANIFEST
    if has_link_component(manifest_path):
        raise ValueError(f"拒绝覆盖符号链接时间线归属清单：{manifest_path}")
    previous = _read_manifest(output)
    source_reference = _source_reference(info)
    previous_owned = _manifest_matches_source(previous, source_reference, info.get("source"))
    if manifest_path.exists() and not previous_owned:
        if not allow_invalid_manifest_recovery or previous is not None:
            return
        artifacts = _recoverable_invalid_manifest_artifacts(output, source_reference)
        if artifacts is None:
            return
    else:
        artifacts = previous.get("artifacts") if isinstance(previous, dict) and isinstance(previous.get("artifacts"), list) else []
    manifest = {
        "tool": TIMELINE_TOOL,
        "source": source_reference,
        "schema_version": TIMELINE_SCHEMA_VERSION,
        "status": "building",
        "artifacts": sorted(
            relative for relative in artifacts
            if isinstance(relative, str) and _ARTIFACT_RE.fullmatch(relative)
        ),
    }
    _atomic_write(manifest_path, json.dumps(manifest, ensure_ascii=False, indent=2) + "\n")


def _remove_registered_artifacts(output, artifacts, keep=()):
    """Remove only valid timeline paths registered by the matching manifest."""
    output = Path(output).resolve()
    keep = set(keep)
    removed = []
    for relative in artifacts if isinstance(artifacts, list) else []:
        if (
            not isinstance(relative, str)
            or not _ARTIFACT_RE.fullmatch(relative)
            or relative in keep
            or not _timeline_artifact_is_valid(output, relative)
        ):
            continue
        target = output / Path(relative)
        unlink_pair(target)
        removed.append(relative)
    return removed


def remove_student_timeline(info):
    """Clear same-source registered artifacts while retaining a reusable owner marker."""
    output_path = Path(info["output"])
    if has_link_component(output_path):
        raise ValueError(f"拒绝使用符号链接学生输出目录：{output_path}")
    if not output_path.is_dir():
        return False
    output = output_path.resolve()
    manifest_path = output / TIMELINE_DIRECTORY / TIMELINE_MANIFEST
    if has_link_component(manifest_path):
        raise ValueError(f"拒绝删除符号链接时间线归属清单：{manifest_path}")
    manifest = _read_manifest(output)
    if not _manifest_matches_source(manifest, _source_reference(info), info.get("source")):
        return False
    _remove_registered_artifacts(output, manifest.get("artifacts", []))
    _atomic_write(manifest_path, json.dumps({
        "tool": TIMELINE_TOOL,
        "source": _source_reference(info),
        "schema_version": TIMELINE_SCHEMA_VERSION,
        "status": "cleared",
        "artifacts": [],
    }, ensure_ascii=False, indent=2) + "\n")
    return True


def _event_lab(event):
    lab = event.get("lab", "other") if isinstance(event, dict) else "other"
    return lab if lab in LAB_KEYS else "other"


def _is_collection_log_event(event):
    return bool(
        isinstance(event, dict)
        and (event.get("evidence_level") == "E2" or event.get("type") == "collection_log_evidence")
    )


def _iso_sort_value(value):
    if not value:
        return None
    try:
        parsed = datetime.fromisoformat(str(value).replace("Z", "+00:00"))
        if parsed.tzinfo is None:
            return None
        return parsed.astimezone(timezone.utc).timestamp()
    except (TypeError, ValueError, OverflowError):
        return None


def _event_sort_key(event):
    absolute = _iso_sort_value(event.get("logged_at") if _is_collection_log_event(event)
                               else event.get("observed_at"))
    elapsed = event.get("elapsed_seconds")
    try:
        elapsed_value = float(elapsed)
    except (TypeError, ValueError):
        elapsed_value = float("inf")
    return (
        absolute is None,
        absolute if absolute is not None else float("inf"),
        str(event.get("recording_id") or ""),
        elapsed_value,
        str(event.get("event_id") or ""),
    )


def _stats(events, errors):
    terminal_events = [event for event in events if not _is_collection_log_event(event)]
    collection_events = [event for event in events if _is_collection_log_event(event)]
    absolute = sum(_iso_sort_value(event.get("observed_at")) is not None for event in terminal_events)
    relative = sum(
        _iso_sort_value(event.get("observed_at")) is None and event.get("elapsed_seconds") is not None
        for event in terminal_events
    )
    missing = len(terminal_events) - absolute - relative
    collection_time = sum(
        _iso_sort_value(event.get("logged_at") or event.get("observed_at")) is not None
        for event in collection_events
    )
    uncertain = sum(bool(event.get("uncertainty")) for event in events)
    by_type = {}
    for event in events:
        kind = str(event.get("type") or "unknown")
        by_type[kind] = by_type.get(kind, 0) + 1
    return {
        "events": len(events),
        "terminal_screen_events": len(terminal_events),
        "collection_log_events": len(collection_events),
        "absolute_time_events": absolute,
        "relative_time_only_events": relative,
        "missing_time_events": missing,
        "collection_log_time_events": collection_time,
        "uncertain_events": uncertain,
        "errors": len(errors),
        "by_type": dict(sorted(by_type.items())),
    }


def _markdown_text(value):
    text = str(value).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
    return re.sub(r"([\\`*_{}\[\]()#+!|~])", r"\\\1", text).replace("\n", "<br>").replace("\r", "")


def _append_fenced(md, text):
    text = str(text or "")
    longest = max((len(match.group(0)) for match in re.finditer(r"`+", text)), default=0)
    fence = "`" * max(3, longest + 1)
    md.extend([fence + "text", *text.splitlines(), fence])


def _terminal_label(value):
    if isinstance(value, dict):
        parts = []
        for key, label in (("header_tty", "header TTY"), ("session_start_tty", "session TTY"),
                           ("tty", "TTY"), ("term", "TERM")):
            item = value.get(key)
            if isinstance(item, (list, tuple)):
                item = ", ".join(map(str, item))
            if item:
                parts.append(f"{label}: {item}")
        pids = value.get("shell_pid")
        if isinstance(pids, (list, tuple)):
            pids = ", ".join(map(str, pids))
        if pids is not None and pids != "":
            parts.append(f"PID: {pids}")
        return " / ".join(parts) or "未知"
    return str(value or "未知")


def _event_anchor(event_id):
    return "event-" + re.sub(r"[^A-Za-z0-9_-]+", "-", str(event_id or "unknown")).strip("-")


def _source_link(path, label, info):
    if not path:
        return "未知"
    return f"{_markdown_text(label)}（{_markdown_text(Path(str(path)).as_posix())}）"


def _event_type_label(kind):
    return {
        "shell_command_observed": "Shell 命令",
        "claude_user_observed": "用户问题",
        "claude_reply_observed": "Claude 回复",
        "collection_log_evidence": "采集日志佐证（E2）",
    }.get(kind, str(kind or "未知事件"))


def _beijing_time(value):
    if not value:
        return "未知"
    try:
        parsed = datetime.fromisoformat(str(value).replace("Z", "+00:00"))
        if parsed.tzinfo is None:
            return "未知（原始时间无时区，无法换算）"
        china = parsed.astimezone(timezone(timedelta(hours=8)))
        return china.isoformat(timespec="milliseconds") + "（北京时间）"
    except (TypeError, ValueError, OverflowError):
        return "未知（原始时间无法解析）"


def _elapsed_text(value):
    try:
        return f"+{float(value):.6f} 秒"
    except (TypeError, ValueError):
        return "未知"


def _render_collection_log_event(md, event, sequence):
    source = event.get("source") if isinstance(event.get("source"), dict) else {}
    association = event.get("association") if isinstance(event.get("association"), dict) else {}
    source_time = source.get("time") if isinstance(source.get("time"), dict) else {}
    confidence = association.get("confidence") or "unlinked"
    log_path = source.get("log") or "logs/events.jsonl"
    line = source.get("line")
    md.extend([
        f"<a id=\"{_event_anchor(event.get('event_id'))}\"></a>",
        f"### {sequence}. {_event_type_label(event.get('type'))}", "",
        f"- 事件编号：{_markdown_text(event.get('event_id', '未知'))}",
        f"- 采集日志类型：{_markdown_text(event.get('log_event_type') or 'unknown')}",
        f"- 采集日志时间：{_beijing_time(event.get('logged_at') or event.get('observed_at'))}",
        f"- 源行号：{_markdown_text(log_path)} 第 {_markdown_text(line if line is not None else '未知')} 行",
        f"- 关联置信度：{_markdown_text(confidence)}",
        f"- 关联录像：{_markdown_text(association.get('recording_id') or '无')}",
        f"- 时间语义：{_markdown_text(event.get('observation_semantics') or source_time.get('semantics') or '采集日志时间')}",
        "- 终端屏幕证据：无；本条仅为 E2 采集日志佐证。",
    ])
    if association.get("basis"):
        md.append(f"- 关联依据：{_markdown_text(association['basis'])}")
    if association.get("requested_recording_id"):
        md.append(f"- 日志 rec：{_markdown_text(association['requested_recording_id'])}")
    if event.get("cwd"):
        md.append(f"- 日志工作目录：{_markdown_text(event['cwd'])}")
    uncertainty = event.get("uncertainty") or []
    if uncertainty:
        md.append(f"- 不确定性：{_markdown_text('；'.join(map(str, uncertainty)))}")
    md.extend(["", "#### 原始日志记录", ""])
    _append_fenced(md, event.get("content", ""))
    md.append("")


def _render_terminal_event(md, info, event, sequence):
    observed = _beijing_time(event.get("observed_at"))
    md.extend([
        f"<a id=\"{_event_anchor(event.get('event_id'))}\"></a>",
        f"### {sequence}. {_event_type_label(event.get('type'))}（E1 终端屏幕证据）", "",
        f"- 事件编号：{_markdown_text(event.get('event_id', '未知'))}",
        f"- 显示时间：{observed}",
        f"- 录像相对时间：{_markdown_text(_elapsed_text(event.get('elapsed_seconds')))}",
        f"- 录像：{_markdown_text(event.get('recording_id', '未知'))}",
        f"- 终端：{_markdown_text(_terminal_label(event.get('terminal')))}",
        f"- 工作目录：{_markdown_text(event.get('cwd') or '未知')}",
        f"- 时间语义：{_markdown_text(event.get('observation_semantics') or '终端画面观察时间')}",
    ])
    if event.get("related_event_id"):
        md.append(f"- 关联事件：[{_markdown_text(event['related_event_id'])}]"
                  f"(#{_event_anchor(event['related_event_id'])})")
    uncertainty = event.get("uncertainty") or []
    if uncertainty:
        md.append(f"- 不确定性：{_markdown_text('；'.join(map(str, uncertainty)))}")
    source = event.get("source") or {}
    if source:
        md.append(f"- 原始文件：{_source_link(source.get('out'), '录像', info)} / "
                  f"{_source_link(source.get('tim'), '计时', info)}")
        observation = source.get("observation") or {}
        locators = []
        if observation.get("timing_line") is not None:
            locators.append(f"timing 第 {observation['timing_line']} 行")
        if observation.get("frame") is not None:
            locators.append(f"画面 {observation['frame']}")
        byte_range = observation.get("decompressed_byte_range") or observation.get("body_byte_range")
        if byte_range:
            locators.append(f"解压字节 [{byte_range[0]}, {byte_range[1]})")
        if locators:
            md.append(f"- 观察定位：{_markdown_text('；'.join(locators))}")
        shell_ranges = source.get("shell_decompressed_ranges") or {}
        if shell_ranges.get("output_start") is not None and shell_ranges.get("region_end") is not None:
            md.append(f"- Shell 输出字节：[{shell_ranges['output_start']}, {shell_ranges['region_end']})")
    if event.get("final_text_first_observed_at"):
        md.append(f"- 最终正文完整显示时间：{_beijing_time(event['final_text_first_observed_at'])}")
    if event.get("final_text_observation_semantics"):
        md.append(f"- 最终正文时间语义：{_markdown_text(event['final_text_observation_semantics'])}")
    md.extend(["", "#### 正文", ""])
    _append_fenced(md, event.get("content", ""))
    output_lines = event.get("output_lines", event.get("output"))
    if output_lines is not None:
        output_text = "\n".join(map(str, output_lines)) if isinstance(output_lines, list) else str(output_lines)
        md.extend(["", "#### 关联 Shell 输出", ""])
        _append_fenced(md, output_text)
        if event.get("output_truncated"):
            md.extend(["", "说明：输出已按原报告上限截断，可依据原始定位回查完整录像。"])
    if event.get("output_note"):
        md.extend(["", f"输出说明：{_markdown_text(event['output_note'])}"])
    md.append("")


def _render_markdown(info, lab, events, stats, errors):
    label = lab if lab != "other" else "其他（非 lab0–lab8 或目录未知）"
    md = [
        "# 实验过程时间线", "",
        f"- 学号：{_markdown_text(info.get('student_id', '未知'))}",
        f"- 姓名：{_markdown_text(info.get('name', '未知'))}",
        f"- 实验分类：{label}",
        f"- 事件总数：{stats['events']}",
        f"- E1 终端屏幕事件：{stats['terminal_screen_events']}",
        f"- E2 采集日志佐证：{stats['collection_log_events']}",
        f"- 有绝对终端显示时间（E1）：{stats['absolute_time_events']}",
        f"- 仅有录像相对时间（E1）：{stats['relative_time_only_events']}",
        f"- 终端时间缺失（E1）：{stats['missing_time_events']}",
        f"- 带可解析采集日志时间（E2）：{stats['collection_log_time_events']}",
        f"- 带不确定性说明：{stats['uncertain_events']}",
        "",
        "E1 是从终端录像重放得出的屏幕文本观察；其时间不等同于按键提交、命令开始执行、模型开始生成或回复完成时间。",
        "E2 是采集日志佐证，独立保留日志行号、日志时间与关联置信度；它不是终端屏幕证据，不能替代 E1。",
        "录像起始时钟只有秒级精度；显示到毫秒仅为保留 timing 相对偏移，不代表绝对时间具有毫秒精度。",
        "回复最终正文完整可见时间只是额外观察点，可能晚于下一轮问题，不能解释为模型完成时间。", "",
    ]
    terminal_events = [event for event in events if not _is_collection_log_event(event)]
    aligned = [event for event in terminal_events if _iso_sort_value(event.get("observed_at")) is not None]
    unaligned = [event for event in terminal_events if _iso_sort_value(event.get("observed_at")) is None]
    collection_events = [event for event in events if _is_collection_log_event(event)]
    sequence = 0
    for section, section_events, empty_text in (
        ("E1 终端屏幕证据：已对齐", aligned, "无。"),
        ("E1 终端屏幕证据：未对齐", unaligned, "无；所有 E1 事件均有可解析且带时区的绝对显示时间。"),
    ):
        md.extend([f"## {section}", ""])
        if not section_events:
            md.extend([empty_text, ""])
            continue
        for event in section_events:
            sequence += 1
            _render_terminal_event(md, info, event, sequence)
    md.extend(["## E2 采集日志佐证", ""])
    if not collection_events:
        md.extend(["无。", ""])
    else:
        for event in collection_events:
            sequence += 1
            _render_collection_log_event(md, event, sequence)
    md.extend(["## 异常", ""])
    if errors:
        md.extend(f"- {_markdown_text(error)}" for error in errors)
    else:
        md.append("无。")
    md.append("")
    return "\n".join(md)


def write_student_timeline(info, result, incremental=None):
    """Write all timeline artifacts, then clean only stale artifacts from the same source."""
    output_path = Path(info["output"])
    if has_link_component(output_path):
        raise ValueError(f"拒绝使用符号链接学生输出目录：{output_path}")
    output = output_path.resolve()
    timeline_dir = output / TIMELINE_DIRECTORY
    if has_link_component(timeline_dir):
        raise ValueError(f"拒绝使用符号链接时间线目录：{timeline_dir}")
    if output not in timeline_dir.resolve().parents:
        raise ValueError(f"时间线目标越出学生输出目录：{timeline_dir}")

    manifest_path = timeline_dir / TIMELINE_MANIFEST
    if has_link_component(manifest_path):
        raise ValueError(f"拒绝覆盖符号链接时间线归属清单：{manifest_path}")
    previous = _read_manifest(output)
    source_reference = _source_reference(info)
    previous_owned = _manifest_matches_source(previous, source_reference, info.get("source"))
    if manifest_path.exists() and (
        not previous
        or not previous_owned
    ):
        raise ValueError(f"时间线目录已有其他来源或无效归属清单：{manifest_path}")

    raw_events = result.get("events") or []
    total_recordings = int(result.get("recordings") or 0)
    if total_recordings <= 0:
        raise ValueError("未发现可处理的 term/*.out.gz 录像，不生成空时间线")
    errors = [str(error) for error in (result.get("errors") or [])]
    groups = {lab: [] for lab in LAB_KEYS}
    for raw_event in raw_events:
        if not isinstance(raw_event, dict):
            errors.append(f"忽略非对象事件：{raw_event!r}")
            continue
        event = dict(raw_event)
        lab = _event_lab(event)
        if event.get("lab") not in LAB_KEYS:
            event["lab"] = "other"
            event["uncertainty"] = list(event.get("uncertainty") or []) + ["实验分类无效，已归入 other"]
        groups[lab].append(event)
    declared_labs = result.get("labs")
    if not isinstance(declared_labs, (list, tuple, set)):
        declared_labs = ()
    active_labs = [
        lab for lab in LAB_KEYS
        if groups[lab] or lab in declared_labs
    ] or ["other"]

    wanted = []
    summaries = {}
    recording_details = result.get("recording_details") or []
    recording_failures = sum(
        isinstance(detail, dict) and detail.get("status") == "error"
        for detail in recording_details
    )
    fatal_errors = [str(error) for error in (result.get("fatal_errors") or [])]
    fatal_errors = list(dict.fromkeys(fatal_errors))
    for error in fatal_errors:
        if error not in errors:
            errors.append(error)
    processing_failures = recording_failures + len(fatal_errors)
    for lab in active_labs:
        events = sorted(groups[lab], key=_event_sort_key)
        stats = _stats(events, errors)
        stats["recording_failures"] = recording_failures
        stats["processing_failures"] = processing_failures
        summaries[lab] = stats
        document = {
            "schema_version": TIMELINE_SCHEMA_VERSION,
            "student": {
                "student_id": info.get("student_id", "未知"),
                "name": info.get("name", "未知"),
                "source": source_reference,
            },
            "lab": lab,
            "status": "partial" if processing_failures else "complete",
            "summary": stats,
            "statistics": stats,
            "student_recordings": total_recordings,
            "recording_details": recording_details,
            "events": events,
            "errors": errors,
        }
        json_relative, md_relative = timeline_paths(lab)
        _atomic_write(output / json_relative, json.dumps(document, ensure_ascii=False, indent=2) + "\n")
        _atomic_write(output / md_relative, _render_markdown(info, lab, events, stats, errors))
        wanted.extend((json_relative.as_posix(), md_relative.as_posix()))

    if previous_owned:
        _remove_registered_artifacts(output, previous.get("artifacts", []), wanted)

    manifest_artifacts = set(wanted)
    aggregate = _stats([event for lab in active_labs for event in groups[lab]], errors)
    aggregate["recordings"] = total_recordings
    aggregate["recording_failures"] = recording_failures
    aggregate["processing_failures"] = processing_failures
    manifest = {
        "tool": TIMELINE_TOOL,
        "source": source_reference,
        "schema_version": TIMELINE_SCHEMA_VERSION,
        "status": "partial" if processing_failures else "complete",
        "artifacts": sorted(manifest_artifacts),
    }
    if (
        not processing_failures
        and isinstance(incremental, dict)
        and isinstance(incremental.get("fingerprint"), str)
        and isinstance(incremental.get("processor_signature"), str)
    ):
        manifest.update({
            "cache_format_version": TIMELINE_CACHE_FORMAT_VERSION,
            "input_fingerprint": incremental["fingerprint"],
            "processor_signature": incremental["processor_signature"],
            "summary": {"statistics": aggregate},
            "artifact_sha256": {
                relative: _stream_sha256(output / relative)
                for relative in sorted(manifest_artifacts)
            },
        })
    _atomic_write(manifest_path, json.dumps(manifest, ensure_ascii=False, indent=2) + "\n")
    return {"labs": summaries, "statistics": aggregate, "artifacts": sorted(manifest_artifacts),
            "errors": errors, "fatal_errors": fatal_errors,
            "status": "partial" if processing_failures else "complete"}


def update_readme_timeline_block(readme_path, timeline_results):
    """Append or replace this feature's bounded README section without changing other text."""
    path = Path(readme_path)
    original = (path.read_text(encoding="utf-8") if path.is_file()
                else "# 终端实验数据批处理说明\n")
    start = original.find(README_BLOCK_START)
    end = original.find(README_BLOCK_END)
    if start >= 0 and end >= start:
        end += len(README_BLOCK_END)
    totals = {
        key: sum((item.get("statistics") or {}).get(key, 0) for item in timeline_results)
        for key in ("recordings", "events", "terminal_screen_events", "collection_log_events",
                    "absolute_time_events", "relative_time_only_events", "missing_time_events",
                    "collection_log_time_events", "uncertain_events", "recording_failures",
                    "processing_failures", "errors")
    }
    by_type = {}
    for item in timeline_results:
        for key, value in (item.get("statistics") or {}).get("by_type", {}).items():
            by_type[key] = by_type.get(key, 0) + value
    def stage_label(item):
        return {
            "complete": "已处理",
            "incremental_skip": "增量跳过",
            "partial": "部分失败",
            "failed": "失败",
        }.get(item.get("status"), "未运行")

    stage_counts = {label: sum(stage_label(item) == label for item in timeline_results)
                    for label in ("已处理", "增量跳过", "部分失败", "失败")}
    stage_rows = ["", "| 学生目录 | 时间线阶段 |", "| --- | --- |"]
    detail_rows = []
    for item in timeline_results:
        info = item.get("info") or {}
        source_name = info.get("source_name") or Path(str(info.get("source") or "未知")).name
        stage = stage_label(item)
        stage_rows.append(f"| {_markdown_text(source_name)} | {stage} |")
        item_errors = item.get("errors") or []
        if not isinstance(item_errors, (list, tuple)):
            item_errors = [item_errors]
        for error in dict.fromkeys(str(error) for error in item_errors):
            detail_rows.append(
                f"- {_markdown_text(source_name)}（{stage}）：{_markdown_text(error)}"
            )
    detail_block = (["", "### 时间线提示与失败详情", "", *detail_rows]
                    if detail_rows else [])
    block = [
        README_BLOCK_START,
        "## 实验过程时间线", "",
        "每名学生的时间线位于 `按人分类/<学生>/<lab>/实验过程清洗工具/`，并镜像到 `按Lab分类/<lab>/<学生>/实验过程清洗工具/`；每个 Lab 提供 JSON 规范数据和 Markdown 阅读版。E1 为 Shell 命令、Claude 用户问题与 Claude 回复等终端屏幕证据；E2 为采集日志佐证，二者分别保留来源与时间语义。", "",
        "E1 的时间是文本在终端画面中的可观察显示时间，不代表精确提交、执行开始、模型生成开始或回复完成时间。E2 的时间来自采集日志本身，附日志行号和 exact_rec、correlated 或 unlinked 关联置信度，绝不作为终端屏幕证据。", "",
        "录像起始时钟只有秒级精度；显示到毫秒仅用于保留 timing 相对偏移，不代表绝对时间具有毫秒精度。Claude 回复最终正文完整可见时间可能晚于下一轮问题，它不是回复完成时间。", "",
        "E1 JSON 中 `observed_at` 为带时区的显示时间，`elapsed_seconds` 为原录像累计偏移；`source.observation` 保留原 timing 行号、变化画面编号和解压字节区间（零基、左闭右开）。E2 使用 `logged_at`、`source.log`、`source.line` 和 `association`，不填充终端相对时间。无法确定的值保留为 null，原因见 `uncertainty`。", "",
        "`recording_details` 保留所有录像的读取、时钟和提取检查记录；`errors` 包含异常与不确定性提示，不等同于处理失败。没有提取到事件不代表没有发生操作或对话。内部未保留的 Claude 记录可能只是重绘残留，不能作为额外未完成对话计数。", "",
        "默认运行同时生成原有四类报告和时间线；`--timeline-only` 只刷新时间线并仅替换本说明块，保留 README 中原有报告统计与其他内容；`--no-timeline` 只生成原有报告。两项不能同时使用。输入、处理器代码和登记产物未变化时会增量跳过；`--force` 可强制重建所选时间线。", "",
        "本工作区仅更新时间线的命令（在脚本所在目录执行）：", "",
        "```powershell",
        'python3 replay_term_qa.py "../操作系统实验数据记录" -o "../操作系统实验数据记录-已清洗" --timeline-only',
        "```", "",
        f"- 本次时间线学生数：{len(timeline_results)}",
        f"- 时间线阶段已处理：{stage_counts['已处理']}",
        f"- 时间线阶段增量跳过：{stage_counts['增量跳过']}",
        f"- 时间线阶段失败或部分失败：{stage_counts['部分失败'] + stage_counts['失败']}",
        f"- 终端录像数：{totals['recordings']}",
        f"- 事件数：{totals['events']}",
        f"- E1 终端屏幕事件：{totals['terminal_screen_events']}",
        f"- E2 采集日志佐证：{totals['collection_log_events']}",
        f"- Shell 命令事件：{by_type.get('shell_command_observed', 0)}",
        f"- Claude 用户问题事件：{by_type.get('claude_user_observed', 0)}",
        f"- Claude 回复事件：{by_type.get('claude_reply_observed', 0)}",
        f"- 有绝对终端显示时间（E1）：{totals['absolute_time_events']}",
        f"- 仅有录像相对时间（E1）：{totals['relative_time_only_events']}",
        f"- 终端时间缺失（E1）：{totals['missing_time_events']}",
        f"- 带可解析采集日志时间（E2）：{totals['collection_log_time_events']}",
        f"- 带不确定性说明：{totals['uncertain_events']}",
        f"- 录像处理失败：{totals['recording_failures']}",
        f"- 处理失败总数：{totals['processing_failures']}",
        f"- 异常数：{totals['errors']}",
        *stage_rows,
        *detail_block,
        README_BLOCK_END,
    ]
    if start >= 0 and end >= start:
        combined = original[:start] + "\n".join(block) + original[end:]
    else:
        combined = original + ("\n" if original.endswith("\n") else "\n\n") + "\n".join(block) + "\n"
    _atomic_write(path, combined)
