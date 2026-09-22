"""Recording-level terminal replay analysis.

The report writer and timeline writer consume the JSON-compatible result from
``analyze_recording``.  Keeping this module importable at top level is
intentional: it is executed in Windows ``spawn`` worker processes.
"""
from __future__ import annotations

from bisect import bisect_right
import hashlib
import inspect
from pathlib import Path
import re
from typing import Any, Iterable, Mapping

import pyte
import wcwidth as wcwidth_module

import replay_term_qa as app


ANALYZER_VERSION = "recording-engine-v2"

# The cache must follow the terminal-analysis rules in replay_term_qa without
# treating report prose, CLI wiring, or unrelated output formatting as a replay
# change.  Keep this list close to analyze_recording when adding a new app-side
# helper to the recording analysis path.
_APP_ANALYSIS_SYMBOLS = (
    "SCRIPT_HEADER_PREFIXES", "SCRIPT_DONE_PREFIXES", "PROMPT_RAW", "PLAIN_PROMPT_RAW",
    "CLAUDE_MARKER_RE", "BOX_DRAWING_RE", "CLAUDE_SPINNER_RE",
    "CLAUDE_ANIMATED_STATUS_RE", "CLAUDE_PROCESS_RE", "CLAUDE_STATUS_FRAGMENTS",
    "CLAUDE_FOOTER_PREFIXES", "CLAUDE_OVERLAY_PREFIXES", "LAB_KEYS",
    "ScrollScreen", "TranscriptScreen", "shell_prompt_matches", "render_line",
    "render_region", "join_wrapped", "clean_command", "normalize_command",
    "read_term_data", "infer_replay_columns", "read_timing_entries",
    "time_map_from_entries", "time_at", "replay_full_terminal_data", "lab_from_cwd",
    "split_lab_regions",
    "normalized_message", "parse_claude_blocks", "is_claude_ui_terminator",
    "is_claude_ui_noise", "clean_claude_message", "claude_frame_ready",
    "answers_are_related", "merge_streamed_answer", "extract_session",
    "extract_claude_session",
)


def _analysis_symbol_bytes(name: str) -> bytes:
    """Return stable source/value bytes for one app-side analysis dependency."""
    value = getattr(app, name)
    if hasattr(value, "pattern") and hasattr(value, "flags"):
        return repr((value.pattern, value.flags)).encode("utf-8", "backslashreplace")
    if isinstance(value, (str, bytes, int, float, tuple, frozenset)):
        return repr(value).encode("utf-8", "backslashreplace")
    try:
        return inspect.getsource(value).encode("utf-8")
    except (OSError, TypeError):
        return repr(value).encode("utf-8", "backslashreplace")


def analyzer_signature() -> str:
    """Return a content signature for replay rules used by cached results."""
    digest = hashlib.sha256(ANALYZER_VERSION.encode("ascii"))
    for name, module in (("pyte", pyte), ("wcwidth", wcwidth_module)):
        digest.update(name.encode("ascii"))
        digest.update(str(getattr(module, "__version__", "unknown")).encode("utf-8"))
    for source in (Path(__file__),):
        try:
            digest.update(source.name.encode("utf-8"))
            digest.update(source.read_bytes())
        except OSError:
            digest.update(str(source).encode("utf-8", "replace"))
    for name in _APP_ANALYSIS_SYMBOLS:
        digest.update(name.encode("utf-8"))
        digest.update(b"\0")
        digest.update(_analysis_symbol_bytes(name))
        digest.update(b"\0")
    return f"{ANALYZER_VERSION}:{digest.hexdigest()}"


def _recording_name(task: Mapping[str, Any]) -> str:
    value = str(task.get("recording_name") or task.get("recording_id") or "")
    if value:
        return value.rsplit("/", 1)[-1].rsplit("\\", 1)[-1]
    return Path(str(task["out_path"])).name.removesuffix(".out.gz")


def _timing_index(entries: Iterable[tuple[float, int]]) -> list[dict[str, Any]]:
    offset = 0
    elapsed = 0.0
    result = []
    for line, (delay, size) in enumerate(entries, 1):
        elapsed += delay
        result.append({
            "line": line,
            "begin": offset,
            "end": offset + size,
            "elapsed": elapsed,
        })
        offset += size
    return result


def _header_value(header: str, name: str) -> str | None:
    match = re.search(re.escape(name) + r'="([^"]*)"', header)
    return match.group(1) if match else None


def _frame_slots(lines: tuple[str, ...]) -> tuple[list[str], list[int]]:
    """Record enough parsed frame metadata to locate a retained QA pair later."""
    users: list[str] = []
    pair_slots: list[int] = []
    pending: int | None = None
    for role, text in app.parse_claude_blocks(lines):
        if role == "user":
            pending = len(users)
            users.append(app.normalized_message(text))
        elif pending is not None:
            pair_slots.append(pending)
            pending = None
    return users, pair_slots


def _frame_source(
    body: bytes,
    entries: list[tuple[float, int]],
    columns: int,
    rows: int,
    start: str,
    *,
    keep_metadata: list[dict[str, Any]],
):
    """Yield exact screen changes while retaining only derived frame metadata.

    A valid timing file supplies natural replay chunks.  Without one, there is
    no defensible temporal subdivision, so the full body is rendered once and
    receives no timing value.
    """
    screen = app.ScrollScreen(columns, rows)
    stream = app.ByteStream(screen)
    # A newly-created DiffScreen marks every row dirty.  It is not evidence.
    screen.dirty.clear()
    previous: tuple[str, ...] = ()
    offset = 0
    elapsed = 0.0
    frame_no = 0
    segments: list[tuple[int, int, float | None, int | None]] = []
    if entries:
        for line, (delay, size) in enumerate(entries, 1):
            elapsed += delay
            end = min(offset + size, len(body))
            if end > offset:
                segments.append((offset, end, elapsed, line))
            offset = end
            if offset >= len(body):
                break
        if offset < len(body):
            segments.append((offset, len(body), None, None))
    elif body:
        segments.append((0, len(body), None, None))

    for begin, end, frame_elapsed, timing_line in segments:
        stream.feed(body[begin:end])
        dirty = bool(screen.dirty)
        screen.dirty.clear()
        if not dirty:
            continue
        current = tuple(screen.scrollback) + tuple(
            app.render_line(screen.buffer[y], screen.columns)
            for y in range(screen.lines)
        )
        changed = tuple(
            index for index in range(max(len(previous), len(current)))
            if (previous[index] if index < len(previous) else None)
            != (current[index] if index < len(current) else None)
        )
        if not changed:
            continue
        users, pair_slots = _frame_slots(current)
        keep_metadata.append({
            "frame": frame_no,
            "elapsed_seconds": frame_elapsed,
            "timing_line": timing_line,
            "body_byte_range": [begin, end],
            "changed_rows": list(changed),
            "users": users,
            "pair_slots": pair_slots,
            "uncertainty": [] if frame_elapsed is not None else [
                "frame_not_covered_by_valid_timing"
            ],
        })
        yield frame_no, frame_elapsed or 0.0, current, changed, start, columns, rows
        previous = current
        frame_no += 1


def _frame_evidence(frame: Mapping[str, Any] | None, header_bytes: int) -> dict[str, Any] | None:
    if not frame:
        return None
    result = {
        key: frame[key]
        for key in ("frame", "elapsed_seconds", "timing_line", "body_byte_range", "changed_rows")
        if key in frame
    }
    byte_range = result.get("body_byte_range")
    if isinstance(byte_range, list) and len(byte_range) == 2:
        result["decompressed_byte_range"] = [
            int(byte_range[0]) + header_bytes,
            int(byte_range[1]) + header_bytes,
        ]
    if frame.get("uncertainty"):
        result["uncertainty"] = list(frame["uncertainty"])
    return result


def _region_for_offset(regions: list[dict[str, Any]], offset: int) -> tuple[int, dict[str, Any]]:
    for number, region in enumerate(regions, 1):
        if int(region["begin"]) <= offset < int(region["end"]):
            return number, region
    return len(regions), regions[-1]


def _locate_question(
    pair: Mapping[str, Any],
    observations: list[Mapping[str, Any]],
    frames: list[Mapping[str, Any]],
    first_reply: Mapping[str, Any],
    lower_frame: int,
) -> tuple[Mapping[str, Any] | None, list[str]]:
    if not observations:
        return None, ["user_occurrence_identity_unavailable"]
    first = observations[0]
    frame_number = int(first["frame"])
    if frame_number >= len(frames):
        return None, ["user_occurrence_identity_unavailable"]
    slots = frames[frame_number].get("pair_slots") or []
    observation_index = int(first.get("observation_index") or 0)
    if observation_index >= len(slots):
        return None, ["user_occurrence_identity_unavailable"]
    key = app.normalized_message(str(pair["user"]))
    slot = int(slots[observation_index])
    users = frames[frame_number].get("users") or []
    ordinal = list(users[:slot + 1]).count(key)
    found: Mapping[str, Any] = frames[frame_number]
    for candidate in reversed(frames[lower_frame:frame_number]):
        count = list(candidate.get("users") or []).count(key)
        if count >= ordinal:
            found = candidate
        else:
            break
    return found, []


def _extract_claude_pairs(
    out_path: str,
    tim_path: str,
    body: bytes,
    start: str,
    columns: int,
    rows: int,
    header_bytes: int,
    entries: list[tuple[float, int]],
    regions: list[dict[str, Any]],
) -> tuple[list[dict[str, Any]], int, dict[str, Any]]:
    """Extract all candidate QA pairs from one screen scan of the recording."""
    frames: list[dict[str, Any]] = []
    trace: dict[str, Any] = {}
    source = _frame_source(
        body, entries, columns, rows, start, keep_metadata=frames,
    )
    _, pairs = app.extract_claude_session(
        out_path, tim_path, frame_source=source, evidence=trace,
    )
    answers: list[dict[str, Any]] = []
    previous_first = 0
    records_by_id: dict[int, list[dict[str, Any]]] = {}
    for observation in trace.get("observations", []):
        records_by_id.setdefault(int(observation["record_id"]), []).append(observation)
    for pair_number, (pair, record_ids) in enumerate(
        zip(pairs, trace.get("pair_record_ids", [])), 1
    ):
        observations = [
            observation
            for record_id in record_ids
            for observation in records_by_id.get(int(record_id), [])
        ]
        observations.sort(key=lambda item: (int(item["frame"]), int(item["observation_index"])))
        if not observations:
            continue
        first_frame = frames[int(observations[0]["frame"])]
        question_frame, question_issues = _locate_question(
            pair, observations, frames, first_frame, previous_first,
        )
        previous_first = int(observations[0]["frame"])
        final_key = app.normalized_message(pair["claude"])
        final_frame = next(
            (frames[int(item["frame"])] for item in observations
             if app.normalized_message(item["claude"]) == final_key),
            None,
        )
        region_number, region = _region_for_offset(
            regions, int(first_frame["body_byte_range"][0]),
        )
        answers.append({
            "pair_number": pair_number,
            "user": pair["user"],
            "claude": pair["claude"],
            "lab": region["lab"],
            "cwd": region["cwd"],
            "region_number": region_number,
            "region_body_byte_range": [region["begin"], region["end"]],
            "record_ids": list(record_ids),
            "evidence": {
                "question": _frame_evidence(question_frame, header_bytes),
                "reply": _frame_evidence(first_frame, header_bytes),
                "final": _frame_evidence(final_frame, header_bytes),
                "question_uncertainty": question_issues,
            },
        })
    metadata = {
        "frame_count": len(frames),
        "record_count": int(trace.get("record_count") or 0),
        "retained_record_count": int(trace.get("retained_record_count") or 0),
        "unretained_record_count": int(trace.get("unretained_record_count") or 0),
        "incomplete_record_count": int(trace.get("incomplete_record_count") or 0),
    }
    return answers, len(frames), metadata


def _command_evidence(
    index: list[dict[str, Any]],
    offset: int,
    header_bytes: int,
) -> dict[str, Any]:
    ends = [int(item["end"]) for item in index]
    position = max(0, offset)
    slot = bisect_right(ends, position)
    if slot >= len(index):
        return {
            "elapsed_seconds": None,
            "timing_line": None,
            "body_byte_range": [position, position + 1],
            "decompressed_byte_range": [position + header_bytes, position + header_bytes + 1],
            "uncertainty": ["byte_not_covered_by_valid_timing"],
        }
    item = index[slot]
    return {
        "elapsed_seconds": item["elapsed"],
        "timing_line": item["line"],
        "body_byte_range": [item["begin"], item["end"]],
        "decompressed_byte_range": [item["begin"] + header_bytes, item["end"] + header_bytes],
        "uncertainty": [],
    }


def analyze_recording(task: dict[str, Any]) -> dict[str, Any]:
    """Analyze one recording pair and return a cacheable, JSON-safe result."""
    out_path = str(task["out_path"])
    tim_path = str(task.get("tim_path") or "")
    rec = _recording_name(task)
    header, start, header_cols, rows, body, header_bytes = app.read_term_data(out_path)
    regions = app.split_lab_regions(body)
    timing_issue = task.get("timing_issue")
    entries = [] if timing_issue else app.read_timing_entries(tim_path, body)
    timing_index = _timing_index(entries)
    issues: list[str] = []
    if not entries:
        if timing_issue:
            issues.append(str(timing_issue))
        elif not tim_path or not Path(tim_path).is_file():
            issues.append("timing_missing")
        else:
            issues.append("timing_invalid_or_uncovered")
    time_map = app.time_map_from_entries(entries)

    transcript = app.replay_full_terminal_data(header, start, header_cols, rows, body, rec)
    command_anchors: list[dict[str, Any]] = []
    commands: list[dict[str, Any]] = []
    command_error: str | None = None
    try:
        _, _, commands = app.extract_session(
            out_path,
            tim_path,
            source_data=(header, start, header_cols, rows, body),
            evidence=command_anchors,
            time_map=time_map,
        )
        for command, anchors in zip(commands, command_anchors):
            command["anchors"] = dict(anchors)
            command["evidence"] = _command_evidence(
                timing_index, int(anchors.get("echo_end", 0)) - 1, header_bytes,
            )
    except Exception as exc:
        command_error = f"{type(exc).__name__}: {exc}"
        issues.append("command_parse_error")

    marker_candidate = b"\xe2\x9d\xaf" in body and b"\xe2\x97\x8f" in body
    exact_requested = bool(task.get("need_exact")) or str(task.get("replay_mode") or "hybrid") == "exact"
    exact_required = marker_candidate or exact_requested or not entries or command_error is not None
    claude_pairs: list[dict[str, Any]] = []
    exact_frame_count = 0
    claude_metadata: dict[str, Any] = {}
    if exact_required:
        columns = app.infer_replay_columns(body, header_cols)
        claude_pairs, exact_frame_count, claude_metadata = _extract_claude_pairs(
            out_path, tim_path, body, start, columns, rows, header_bytes, entries, regions,
        )

    return {
        "status": "partial" if command_error else "ok",
        "recording_id": str(task.get("recording_id") or rec),
        "recording_name": rec,
        "source_relative": str(task.get("source_relative") or "").replace("\\", "/"),
        "out_relative": str(task.get("out_relative") or "").replace("\\", "/"),
        "tim_relative": str(task.get("tim_relative") or "").replace("\\", "/"),
        "timing_state": str(task.get("timing_state") or ""),
        "header": {
            "text": header,
            "start_text": start,
            "header_bytes": header_bytes,
            "tty": _header_value(header, "TTY"),
            "format": "header" if header_bytes else "headerless",
        },
        "body_bytes": len(body),
        "columns": transcript["columns"],
        "rows": transcript["rows"],
        "lab_regions": regions,
        "timing_valid": bool(entries),
        "timing_index": timing_index,
        "issues": issues,
        "transcript": transcript,
        "commands": commands,
        "command_error": command_error,
        "claude_pairs": claude_pairs,
        "claude_candidate": marker_candidate,
        "claude_metadata": claude_metadata,
        "capabilities": {
            "terminal_transcript": True,
            "exact_frames": exact_required,
            "temporal_frames": bool(entries) and exact_required,
        },
        "exact_frame_count": exact_frame_count,
    }


__all__ = ["ANALYZER_VERSION", "analyzer_signature", "analyze_recording"]
