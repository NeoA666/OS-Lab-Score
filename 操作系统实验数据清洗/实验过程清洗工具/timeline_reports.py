"""Write the independent JSON and Markdown experiment timelines safely."""

from __future__ import annotations

import json
import os
import re
import tempfile
from datetime import datetime, timedelta, timezone
from pathlib import Path
from urllib.parse import quote


TIMELINE_DIRECTORY = "实验过程时间线"
TIMELINE_MANIFEST = ".timeline_manifest.json"
TIMELINE_TOOL = "replay_term_qa.timeline"
TIMELINE_SCHEMA_VERSION = 1
LAB_KEYS = tuple(f"lab{i}" for i in range(9)) + ("other",)
README_BLOCK_START = "<!-- replay_term_qa:timeline:start -->"
README_BLOCK_END = "<!-- replay_term_qa:timeline:end -->"
_ARTIFACT_RE = re.compile(
    rf"^{re.escape(TIMELINE_DIRECTORY)}/timeline_(?:lab[0-8]|other)\.(?:json|md)$"
)


def _atomic_write(path, text):
    path = Path(path)
    if path.is_symlink():
        raise ValueError(f"拒绝覆盖符号链接：{path}")
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(
            mode="w", encoding="utf-8", newline="\n", dir=path.parent,
            prefix=".timeline-", suffix=".tmp", delete=False,
        ) as stream:
            temporary = Path(stream.name)
            stream.write(text)
        os.replace(temporary, path)
    finally:
        if temporary and temporary.exists():
            temporary.unlink()


def _read_manifest(student_output):
    path = Path(student_output) / TIMELINE_DIRECTORY / TIMELINE_MANIFEST
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, ValueError, TypeError):
        return None
    return value if isinstance(value, dict) else None


def timeline_owned_by(student_output, source):
    """Return whether the independent timeline manifest owns this directory."""
    manifest = _read_manifest(student_output)
    return bool(
        manifest
        and manifest.get("tool") == TIMELINE_TOOL
        and manifest.get("source") == str(source)
    )


def _renamed_source_owner(manifest, info, output):
    """允许同一学号的提交目录改名后复用其现有时间线目录。"""
    if not isinstance(manifest, dict) or manifest.get("tool") != TIMELINE_TOOL:
        return False
    source = manifest.get("source")
    if not isinstance(source, str):
        return False
    source_name = source.rstrip("/\\").replace("\\", "/").rsplit("/", 1)[-1]
    match = re.match(r"^(\d+)-", source_name)
    return bool(
        match
        and match.group(1) == str(info.get("student_id", ""))
        and output.name == str(info.get("name", ""))
    )


def _event_lab(event):
    lab = event.get("lab", "other") if isinstance(event, dict) else "other"
    return lab if lab in LAB_KEYS else "other"


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
    absolute = _iso_sort_value(event.get("observed_at"))
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
    absolute = sum(_iso_sort_value(event.get("observed_at")) is not None for event in events)
    relative = sum(
        _iso_sort_value(event.get("observed_at")) is None and event.get("elapsed_seconds") is not None
        for event in events
    )
    missing = len(events) - absolute - relative
    uncertain = sum(bool(event.get("uncertainty")) for event in events)
    by_type = {}
    for event in events:
        kind = str(event.get("type") or "unknown")
        by_type[kind] = by_type.get(kind, 0) + 1
    return {
        "events": len(events),
        "absolute_time_events": absolute,
        "relative_time_only_events": relative,
        "missing_time_events": missing,
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
    try:
        base = Path(info["output"]) / TIMELINE_DIRECTORY
        relative = Path(os.path.relpath(Path(path), base)).as_posix()
        return f"[{label}]({quote(relative)})"
    except (OSError, ValueError, TypeError):
        return _markdown_text(path)


def _event_type_label(kind):
    return {
        "shell_command_observed": "Shell 命令",
        "claude_user_observed": "用户问题",
        "claude_reply_observed": "Claude 回复",
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


def _render_markdown(info, lab, events, stats, errors):
    label = lab if lab != "other" else "其他（非 lab0–lab8 或目录未知）"
    md = [
        "# 实验过程时间线", "",
        f"- 学号：{_markdown_text(info.get('student_id', '未知'))}",
        f"- 姓名：{_markdown_text(info.get('name', '未知'))}",
        f"- 实验分类：{label}",
        f"- 事件总数：{stats['events']}",
        f"- 有绝对显示时间：{stats['absolute_time_events']}",
        f"- 仅有录像相对时间：{stats['relative_time_only_events']}",
        f"- 时间缺失：{stats['missing_time_events']}",
        f"- 带不确定性说明：{stats['uncertain_events']}",
        "",
        "时间表示终端画面中相应文本的可观察显示时间，不等同于按键提交、命令开始执行、模型开始生成或回复完成时间。",
        "同一 lab 内跨终端按带时区的绝对时间合并并稳定排列；相同或接近的显示时间不证明严格先后或因果关系。",
        "录像起始时钟只有秒级精度；显示到毫秒仅为保留 timing 相对偏移，不代表绝对时间具有毫秒精度。",
        "仅展示现有识别规则保留的事件；未提取到事件不代表没有发生操作或对话。每份 JSON 保留该学生全部录像的检查记录。",
        "回复最终正文完整可见时间只是额外观察点，可能晚于下一轮问题，不能解释为模型完成时间。", "",
    ]
    aligned = [event for event in events if _iso_sort_value(event.get("observed_at")) is not None]
    unaligned = [event for event in events if _iso_sort_value(event.get("observed_at")) is None]
    sequence = 0
    for section, section_events, empty_text in (
        ("已对齐事件", aligned, "无。"),
        ("未对齐事件", unaligned, "无；所有事件均有可解析且带时区的绝对显示时间。"),
    ):
        md.extend([f"## {section}", ""])
        if not section_events:
            md.extend([empty_text, ""])
            continue
        for event in section_events:
            sequence += 1
            observed = _beijing_time(event.get("observed_at"))
            elapsed = event.get("elapsed_seconds")
            elapsed_text = "未知" if elapsed is None else f"+{elapsed:.6f} 秒"
            md.extend([
                f"<a id=\"{_event_anchor(event.get('event_id'))}\"></a>",
                f"### {sequence}. {_event_type_label(event.get('type'))}", "",
                f"- 事件编号：{_markdown_text(event.get('event_id', '未知'))}",
                f"- 显示时间：{observed}",
                f"- 录像相对时间：{_markdown_text(elapsed_text)}",
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
    md.extend(["## 异常", ""])
    if errors:
        md.extend(f"- {_markdown_text(error)}" for error in errors)
    else:
        md.append("无。")
    md.append("")
    return "\n".join(md)


def write_student_timeline(info, result):
    """Write all timeline artifacts, then clean only stale artifacts from the same source."""
    output = Path(info["output"]).resolve()
    timeline_dir = output / TIMELINE_DIRECTORY
    if timeline_dir.is_symlink():
        raise ValueError(f"拒绝使用符号链接时间线目录：{timeline_dir}")
    if output not in timeline_dir.resolve().parents:
        raise ValueError(f"时间线目标越出学生输出目录：{timeline_dir}")

    manifest_path = timeline_dir / TIMELINE_MANIFEST
    if manifest_path.is_symlink():
        raise ValueError(f"拒绝覆盖符号链接时间线归属清单：{manifest_path}")
    previous = _read_manifest(output)
    previous_owned = (
        isinstance(previous, dict)
        and previous.get("tool") == TIMELINE_TOOL
        and (previous.get("source") == info.get("source") or _renamed_source_owner(previous, info, output))
    )
    if manifest_path.exists() and (
        not previous
        or not previous_owned
    ):
        raise ValueError(f"时间线目录已有其他来源或无效归属清单：{manifest_path}")

    raw_events = result.get("events") or []
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
    active_labs = [lab for lab in LAB_KEYS if groups[lab]] or ["other"]

    wanted = []
    summaries = {}
    recording_details = result.get("recording_details") or []
    total_recordings = int(result.get("recordings") or 0)
    recording_failures = sum(
        isinstance(detail, dict) and detail.get("status") == "error"
        for detail in recording_details
    )
    fatal_errors = [str(error) for error in (result.get("fatal_errors") or [])]
    if total_recordings == 0:
        fatal_errors.append("未发现可处理的 term/*.out.gz 录像")
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
                "source": info.get("source"),
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
        json_relative = Path(TIMELINE_DIRECTORY) / f"timeline_{lab}.json"
        md_relative = Path(TIMELINE_DIRECTORY) / f"timeline_{lab}.md"
        _atomic_write(output / json_relative, json.dumps(document, ensure_ascii=False, indent=2) + "\n")
        _atomic_write(output / md_relative, _render_markdown(info, lab, events, stats, errors))
        wanted.extend((json_relative.as_posix(), md_relative.as_posix()))

    if not processing_failures and previous_owned:
        for relative in previous.get("artifacts", []):
            if not isinstance(relative, str) or not _ARTIFACT_RE.fullmatch(relative) or relative in wanted:
                continue
            target = output / Path(relative)
            resolved = target.resolve()
            if output in resolved.parents and not target.is_symlink() and target.is_file():
                target.unlink()

    manifest_artifacts = set(wanted)
    if processing_failures and previous:
        manifest_artifacts.update(
            relative for relative in previous.get("artifacts", [])
            if isinstance(relative, str) and _ARTIFACT_RE.fullmatch(relative)
        )
    manifest = {
        "tool": TIMELINE_TOOL,
        "source": info.get("source"),
        "schema_version": TIMELINE_SCHEMA_VERSION,
        "status": "partial" if processing_failures else "complete",
        "artifacts": sorted(manifest_artifacts),
    }
    _atomic_write(manifest_path, json.dumps(manifest, ensure_ascii=False, indent=2) + "\n")
    aggregate = _stats([event for lab in active_labs for event in groups[lab]], errors)
    aggregate["recordings"] = total_recordings
    aggregate["recording_failures"] = recording_failures
    aggregate["processing_failures"] = processing_failures
    return {"labs": summaries, "statistics": aggregate, "artifacts": sorted(manifest_artifacts),
            "errors": errors, "fatal_errors": fatal_errors}


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
        for key in ("recordings", "events", "absolute_time_events", "relative_time_only_events", "missing_time_events",
                    "uncertain_events", "recording_failures", "processing_failures", "errors")
    }
    by_type = {}
    for item in timeline_results:
        for key, value in (item.get("statistics") or {}).get("by_type", {}).items():
            by_type[key] = by_type.get(key, 0) + value
    block = [
        README_BLOCK_START,
        "## 实验过程时间线", "",
        "每名学生的 `实验过程时间线/` 按 lab 提供对应的 JSON 规范数据和 Markdown 阅读版。Shell 命令、Claude 用户问题与 Claude 回复分别作为事件，并保留录像、终端、工作目录、相对时间、原始定位和不确定性说明。", "",
        "时间线中的时间是文本在终端画面中的可观察显示时间，不代表精确提交、执行开始、模型生成开始或回复完成时间。同一 lab 内跨终端排序使用带时区的绝对时间；相同或接近的时间不证明严格先后。", "",
        "录像起始时钟只有秒级精度；显示到毫秒仅用于保留 timing 相对偏移，不代表绝对时间具有毫秒精度。Claude 回复最终正文完整可见时间可能晚于下一轮问题，它不是回复完成时间。", "",
        "JSON 中 `observed_at` 为带时区的显示时间，`elapsed_seconds` 为原录像累计偏移；`source.observation` 保留原 timing 行号、变化画面编号和解压字节区间（零基、左闭右开）。画面编号不等于 timing 行号，观察帧的位置也不代表正文全部字符都来自这一帧。`final_text_first_observed_at` 仅记录最终回复正文首次完整可见时间。无法确定的值保留为 null，原因见 `uncertainty`。", "",
        "`recording_details` 保留所有录像的读取、时钟和提取检查记录；`errors` 包含异常与不确定性提示，不等同于处理失败。没有提取到事件不代表没有发生操作或对话。内部未保留的 Claude 记录可能只是重绘残留，不能作为额外未完成对话计数。", "",
        "默认运行同时生成原有四类报告和时间线；`--timeline-only` 只刷新时间线并仅替换本说明块，保留 README 中原有报告统计与其他内容；`--no-timeline` 只生成原有报告。两项不能同时使用。", "",
        "本工作区仅更新时间线的命令（在脚本所在目录执行）：", "",
        "```powershell",
        'python3 replay_term_qa.py "../操作系统实验数据记录" -o "../操作系统实验数据记录-已清洗" --timeline-only',
        "```", "",
        f"- 本次时间线学生数：{len(timeline_results)}",
        f"- 终端录像数：{totals['recordings']}",
        f"- 事件数：{totals['events']}",
        f"- Shell 命令事件：{by_type.get('shell_command_observed', 0)}",
        f"- Claude 用户问题事件：{by_type.get('claude_user_observed', 0)}",
        f"- Claude 回复事件：{by_type.get('claude_reply_observed', 0)}",
        f"- 有绝对显示时间：{totals['absolute_time_events']}",
        f"- 仅有录像相对时间：{totals['relative_time_only_events']}",
        f"- 时间缺失：{totals['missing_time_events']}",
        f"- 带不确定性说明：{totals['uncertain_events']}",
        f"- 录像处理失败：{totals['recording_failures']}",
        f"- 处理失败总数：{totals['processing_failures']}",
        f"- 异常数：{totals['errors']}",
        README_BLOCK_END,
    ]
    if start >= 0 and end >= start:
        combined = original[:start] + "\n".join(block) + original[end:]
    else:
        combined = original + ("\n" if original.endswith("\n") else "\n\n") + "\n".join(block) + "\n"
    _atomic_write(path, combined)
