"""独立的终端显示事件定位；原始文件和四类历史报告均不写入。

字节位置均为解压流内零基、左闭右开范围。帧证据是重放输入块的位置，
并不宣称该块包含当前屏幕正文的全部原始字符。
"""
from bisect import bisect_right
from datetime import datetime, timedelta, timezone
import gzip
import hashlib
import json
import math
from pathlib import Path
import re
import shlex

import replay_term_qa as app


def parse_datetime(value):
    try:
        parsed = datetime.fromisoformat(str(value).replace("Z", "+00:00"))
        return parsed if parsed.tzinfo is not None else None
    except (TypeError, ValueError):
        return None


def read_recording(out_path, tim_path):
    """识别真正的 script 头，并保留 timing 的原始行号和字节边界。"""
    raw = gzip.open(out_path, "rb").read()
    first = raw.split(b"\n", 1)[0].decode("utf-8", "replace")
    has_header = raw.split(b"\n", 1)[0].startswith(app.SCRIPT_HEADER_PREFIXES)
    header_bytes = raw.index(b"\n") + 1 if has_header and b"\n" in raw else 0
    if has_header and not header_bytes:
        raise ValueError("script 头缺少换行，无法定位正文")
    header = first if has_header else ""
    body = raw[header_bytes:]
    date_match = re.search(r"\d{4}-\d\d-\d\d[ T]\d\d:\d\d:\d\d(?:\.\d+)?(?:Z|[+-]\d\d:\d\d)", header)
    start = parse_datetime(date_match.group(0)) if date_match else None
    attr = lambda key: (re.search(key + r'="([^"]*)"', header).group(1)
                        if re.search(key + r'="([^"]*)"', header) else None)
    issues, entries = [], []
    offset, elapsed = 0, 0.0
    if not Path(tim_path).is_file():
        issues.append("timing_missing")
    else:
        try:
            with gzip.open(tim_path, "rt", encoding="utf-8", errors="strict") as handle:
                for line_no, line in enumerate(handle, 1):
                    fields = line.split()
                    if len(fields) != 2:
                        raise ValueError(f"timing 第 {line_no} 行不是两个字段")
                    delay, size = float(fields[0]), int(fields[1])
                    if not math.isfinite(delay) or delay < 0 or size < 0:
                        raise ValueError(f"timing 第 {line_no} 行有负值或非有限值")
                    elapsed += delay
                    if not math.isfinite(elapsed):
                        raise ValueError("timing 累计时间溢出")
                    entries.append({"line": line_no, "begin": offset, "end": offset + size,
                                    "elapsed": elapsed, "delay": delay})
                    offset += size
        except (OSError, EOFError, UnicodeError, ValueError, OverflowError) as exc:
            issues.append("timing_invalid: " + str(exc))
            entries = []
            offset = 0
    if not entries and not issues:
        issues.append("timing_empty")
    administrative_tail = app.has_administrative_script_tail(body, offset) if entries else False
    if entries and offset > len(body):
        issues.append("timing_exceeds_body")
    elif entries and offset < len(body) and not administrative_tail:
        issues.append("timing_uncovered_tail")
    if entries and not app.timing_entries_cover_body(
        [(entry["delay"], entry["end"] - entry["begin"]) for entry in entries], body
    ):
        # Keep the recording available for a single replay, but do not assign
        # any event a time from an incomplete timing file.
        entries = []
        offset = 0
    def dimension(name, default):
        value = attr(name)
        return int(value) if value and re.fullmatch(r"\d+", value) and int(value) > 0 else default
    return {"out": str(Path(out_path).resolve()), "tim": str(Path(tim_path).resolve()),
            "header": header, "header_bytes": header_bytes, "body": body,
            "header_start": start, "start_text": date_match.group(0) if date_match else "",
            "cols": dimension("COLUMNS", 198), "rows": dimension("LINES", 59),
            "header_tty": attr("TTY"), "format": "header" if has_header else "headerless",
            "entries": entries, "ends": [entry["end"] for entry in entries],
            "timed_bytes": offset, "administrative_tail": administrative_tail,
            "issues": issues}


def load_collection_log(source):
    """Read every valid collection-log record and keep session starts for clocks.

    ``events.jsonl`` is collection metadata, never a terminal screen capture.
    The returned records preserve their source line so callers can expose them
    as E2 evidence without confusing them with replay-derived E1 events.
    """
    path = Path(source) / "logs" / "events.jsonl"
    records, sessions, issues = [], {}, []
    if app.has_link_component(path):
        return records, sessions, ["session_log_linked"]
    if not path.is_file():
        return records, sessions, ["session_log_missing"]
    previous = None
    try:
        handle = path.open("r", encoding="utf-8", errors="replace")
    except OSError as exc:
        return records, sessions, ["session_log_unreadable: " + str(exc)]
    with handle:
        for line_no, raw_line in enumerate(handle, 1):
            nul_prefix = len(raw_line) - len(raw_line.lstrip("\0"))
            line = raw_line[nul_prefix:]
            if nul_prefix:
                issues.append(f"日志第 {line_no} 行有 NUL 前缀，已恢复尾部 JSON")
            try:
                event = json.loads(
                    line,
                    parse_constant=lambda value: (_ for _ in ()).throw(
                        ValueError(f"非标准 JSON 常量：{value}")
                    ),
                )
                if not isinstance(event, dict):
                    raise ValueError("日志项不是对象")
            except (ValueError, TypeError):
                suffix = "（NUL 前缀恢复后仍不可解析）" if nul_prefix else ""
                issues.append(f"日志第 {line_no} 行不可解析{suffix}")
                continue
            event = dict(event, source_file="logs/events.jsonl", source_line=line_no,
                         nul_prefix_recovered=bool(nul_prefix))
            records.append(event)
            timestamp = parse_datetime(event.get("ts"))
            if timestamp and previous and timestamp < previous:
                issues.append(f"日志第 {line_no} 行时间倒退；未据此校正录像时钟")
            if timestamp:
                previous = timestamp
            if event.get("type") == "session_start" and event.get("rec"):
                sessions.setdefault(str(event["rec"]), []).append(event)
    return records, sessions, issues


def load_session_logs(source):
    """Compatibility wrapper for callers that only need clock support."""
    _, sessions, issues = load_collection_log(source)
    return sessions, issues


def choose_clock(recording, starts):
    """仅 rec 精确关联。保留候选时间，冲突时不伪造统一基准。"""
    warnings = []
    header = recording["header_start"]
    candidates = []
    for item in starts:
        timestamp = parse_datetime(item.get("ts"))
        if timestamp:
            epoch = item.get("epoch")
            if isinstance(epoch, (int, float)) and (not math.isfinite(epoch) or abs(timestamp.timestamp() - epoch) > 1):
                warnings.append("session_start_ts_epoch_conflict")
            candidates.append(timestamp)
    distinct = set(candidates)
    logged = next(iter(distinct)) if len(distinct) == 1 else None
    if len(distinct) > 1:
        warnings.append("conflicting_session_start_records")
    source, start, usable = None, None, True
    if header:
        start, source = header, "script_header_plus_timing"
        if logged and header != logged:
            difference = abs((header - logged).total_seconds())
            warnings.append("header_session_start_difference_seconds=" + str(difference))
            if difference > 1:
                usable = False
        if len(distinct) > 1:
            usable = False
    elif logged and "session_start_ts_epoch_conflict" not in warnings:
        start, source = logged, "session_start_rec_match_plus_timing"
    else:
        warnings.append("absolute_start_unavailable")
        usable = False
    if not usable:
        warnings.append("global_order_uncertain")
    return {"start": start, "usable": usable, "source": source, "uncertainty": warnings,
            "session_start_evidence": starts,
            "terminal": {"header_tty": recording["header_tty"],
                         "session_start_tty": sorted({str(x["tty"]) for x in starts if x.get("tty")}),
                         "shell_pid": sorted({str(x["shell_pid"]) for x in starts if x.get("shell_pid")})}}


def evidence_at_byte(recording, position):
    index = bisect_right(recording["ends"], position)
    entries = recording["entries"]
    if index >= len(entries) or position < 0 or position >= len(recording["body"]):
        return {"elapsed_seconds": None, "timing_line": None,
                "body_byte_range": [max(0, position), max(0, position) + 1],
                "uncertainty": ["byte_not_covered_by_valid_timing"]}
    entry = entries[index]
    if entry["end"] > len(recording["body"]):
        return {"elapsed_seconds": None, "timing_line": entry["line"],
                "body_byte_range": [entry["begin"], len(recording["body"])],
                "uncertainty": ["timing_block_exceeds_available_body"]}
    return {"elapsed_seconds": entry["elapsed"], "timing_line": entry["line"],
            "body_byte_range": [entry["begin"], min(entry["end"], len(recording["body"]))],
            "uncertainty": []}


def iso_at(clock, elapsed):
    if elapsed is None or not clock["usable"] or clock["start"] is None:
        return None
    try:
        return (clock["start"] + timedelta(seconds=elapsed)).isoformat()
    except (OverflowError, ValueError):
        return None


def _source_log_time(event):
    """Resolve an E2 record's own timestamp without deriving terminal time."""
    issues = []
    timestamp = parse_datetime(event.get("ts"))
    epoch = event.get("epoch")
    epoch_time = None
    if isinstance(epoch, (int, float)) and not isinstance(epoch, bool) and math.isfinite(epoch):
        try:
            epoch_time = datetime.fromtimestamp(epoch, timezone.utc)
        except (OverflowError, OSError, ValueError):
            issues.append("collection_log_epoch_unusable")
    elif epoch is not None:
        issues.append("collection_log_epoch_unusable")
    if timestamp is not None and epoch_time is not None:
        try:
            if abs((timestamp - epoch_time).total_seconds()) > 1:
                issues.append("collection_log_ts_epoch_conflict")
        except OverflowError:
            issues.append("collection_log_ts_epoch_conflict")
    if timestamp is not None:
        source = "ts"
    elif epoch_time is not None:
        timestamp, source = epoch_time, "epoch"
    else:
        source = "unavailable"
        issues.append("collection_log_time_unavailable")
    semantics = {
        "ts": "采集日志 ts 字段记录的时间；不是终端屏幕文本的可观察显示时间。",
        "epoch": "采集日志 epoch 字段换算的时间；不是终端屏幕文本的可观察显示时间。",
        "unavailable": "采集日志未提供可解析时间；不是终端屏幕证据。",
    }[source]
    return timestamp, {
        "ts": event.get("ts"), "epoch": epoch,
        "resolved_at": timestamp.isoformat() if timestamp else None,
        "resolution": source, "semantics": semantics,
    }, issues


def _terminal_values(context):
    terminal = context.get("terminal") or {}
    ttys = set()
    pids = set()
    for value in (terminal.get("header_tty"), terminal.get("tty")):
        if value not in (None, ""):
            ttys.add(str(value))
    for value in terminal.get("session_start_tty", ()):  # exact rec clock records
        if value not in (None, ""):
            ttys.add(str(value))
    for value in terminal.get("shell_pid", ()):
        if value not in (None, ""):
            pids.add(str(value))
    return ttys, pids


def _recording_time_range(context):
    """Return an independently checkable absolute start/end pair, if available."""
    clock = context.get("clock") or {}
    start = clock.get("start")
    if not clock.get("usable") or not isinstance(start, datetime) or start.tzinfo is None:
        return None
    duration = context.get("duration_seconds")
    try:
        duration = float(duration)
    except (TypeError, ValueError):
        return None
    if not math.isfinite(duration) or duration < 0:
        return None
    try:
        return start, start + timedelta(seconds=duration)
    except (OverflowError, ValueError):
        return None


def _correlate_log_record(event, contexts, timestamp):
    """Associate only an exact rec or one TTY/PID plus a timed recording span."""
    requested = event.get("rec")
    exact = [context for context in contexts
             if requested not in (None, "") and str(context.get("recording_id")) == str(requested)]
    if len(exact) == 1:
        return exact[0], "exact_rec", "日志 rec 与录像 ID 完全一致"

    if timestamp is None:
        return None, "unlinked", "日志缺少可解析时间，无法执行 TTY/PID 时段关联"
    tty = event.get("tty")
    pid = event.get("shell_pid")
    has_tty = tty not in (None, "")
    has_pid = pid not in (None, "")
    if not has_tty and not has_pid:
        return None, "unlinked", "日志缺少 rec 和 TTY/PID，无法关联录像"
    candidates = []
    for context in contexts:
        bounds = _recording_time_range(context)
        if bounds is None or not (bounds[0] <= timestamp <= bounds[1]):
            continue
        ttys, pids = _terminal_values(context)
        if has_tty and str(tty) not in ttys:
            continue
        if has_pid and str(pid) not in pids:
            continue
        candidates.append(context)
    if len(candidates) == 1:
        return candidates[0], "correlated", "唯一 TTY/PID 与有效录像时段匹配"
    if candidates:
        return None, "unlinked", "TTY/PID 与有效录像时段匹配到多个录像"
    return None, "unlinked", "未找到唯一 TTY/PID 与有效录像时段匹配"


def _log_payload(event):
    """Return the original JSON object, excluding parser-only annotations."""
    return {
        key: value for key, value in event.items()
        if key not in {"source_file", "source_line", "nul_prefix_recovered"}
    }


def build_collection_log_events(info, records, contexts, prefix=None):
    """Build visible E2 collection-log evidence without fabricating screen observations."""
    if prefix is None:
        prefix = hashlib.sha256(str(Path(info.get("source", "")).resolve()).encode("utf-8")).hexdigest()[:12]
    events = []
    for record in records:
        if not isinstance(record, dict) or record.get("type") == "hb":
            continue
        line_no = record.get("source_line")
        try:
            line_no = int(line_no)
        except (TypeError, ValueError):
            line_no = 0
        timestamp, source_time, time_issues = _source_log_time(record)
        context, confidence, basis = _correlate_log_record(record, contexts, timestamp)
        cwd = record.get("cwd") if isinstance(record.get("cwd"), str) else None
        payload = _log_payload(record)
        raw_type = record.get("type")
        log_type = str(raw_type) if raw_type not in (None, "") else "unknown"
        association = {
            "confidence": confidence,
            "recording_id": context.get("recording_id") if context else None,
            "requested_recording_id": str(record["rec"]) if record.get("rec") not in (None, "") else None,
            "basis": basis,
        }
        issues = list(time_issues)
        if confidence == "unlinked":
            issues.append("collection_log_recording_unlinked")
        if record.get("nul_prefix_recovered"):
            issues.append("collection_log_nul_prefix_recovered")
        events.append({
            "event_id": f"{prefix}:log:{line_no:09d}",
            "student": {"student_id": info.get("student_id"), "name": info.get("name")},
            "lab": app.lab_from_cwd(cwd) if cwd else "other",
            "cwd": cwd,
            "recording_id": context.get("recording_id") if context else None,
            "terminal": None,
            "type": "collection_log_evidence",
            "evidence_level": "E2",
            "log_event_type": log_type,
            "content": json.dumps(payload, ensure_ascii=False, sort_keys=True, separators=(",", ":")),
            "observed_at": timestamp.isoformat() if timestamp else None,
            "logged_at": timestamp.isoformat() if timestamp else None,
            "elapsed_seconds": None,
            "observation_semantics": source_time["semantics"],
            "related_event_id": None,
            "association": association,
            "source": {
                "log": record.get("source_file", "logs/events.jsonl"),
                "line": line_no or None,
                "nul_prefix_recovered": bool(record.get("nul_prefix_recovered")),
                "time": source_time,
                "event": payload,
            },
            "uncertainty": list(dict.fromkeys(issues)),
            "ordering_note": "按采集日志时间与源行号稳定展示；该顺序不是终端屏幕显示顺序。",
        })
    return events


def iter_region_frames(recording, region, frames):
    """与旧 Screen/diff 逐条喂入相同字节；额外记录原录像定位信息。"""
    body = recording["body"][region["begin"]:region["end"]]
    columns = app.infer_replay_columns(body, recording["cols"])
    screen = app.ScrollScreen(columns, recording["rows"])
    stream = app.ByteStream(screen)
    previous = ()
    frame_no = 0
    segments = []
    for entry in recording["entries"]:
        begin, end = max(region["begin"], entry["begin"]), min(region["end"], entry["end"])
        if end > begin:
            segments.append((begin, end, entry["elapsed"] if entry["end"] <= len(recording["body"]) else None, entry["line"]))
    consumed = segments[-1][1] if segments else region["begin"]
    if consumed < region["end"]:
        segments.append((consumed, region["end"], None, None))
    for begin, end, elapsed, line in segments:
        stream.feed(recording["body"][begin:end])
        current = tuple(screen.scrollback) + tuple(
            app.render_line(screen.buffer[y], screen.columns) for y in range(screen.lines))
        changed = tuple(i for i in range(max(len(previous), len(current)))
                        if (previous[i] if i < len(previous) else None)
                        != (current[i] if i < len(current) else None))
        if not changed:
            continue
        blocks = app.parse_claude_blocks(current)
        users, pair_slots, pending = [], [], None
        for role, text in blocks:
            if role == "user":
                pending = len(users)
                users.append(app.normalized_message(text))
            elif pending is not None:
                pair_slots.append(pending)
                pending = None
        frames.append({"frame": frame_no, "elapsed_seconds": elapsed, "timing_line": line,
                       "body_byte_range": [begin, end], "users": users, "pair_slots": pair_slots,
                       "changed_rows": list(changed),
                       "uncertainty": [] if elapsed is not None else ["frame_not_covered_by_valid_timing"]})
        yield frame_no, elapsed or 0.0, current, changed, recording["start_text"], columns, recording["rows"]
        previous = current
        frame_no += 1


def _public_evidence(recording, observation):
    if observation is None:
        return None
    result = {key: observation[key] for key in ("frame", "elapsed_seconds", "timing_line", "body_byte_range", "changed_rows") if key in observation}
    if "body_byte_range" in result:
        result["decompressed_byte_range"] = [v + recording["header_bytes"] for v in result["body_byte_range"]]
    return result


def _event(info, rec_id, recording, clock, identity, kind, content, cwd, observation, related=None):
    elapsed = observation.get("elapsed_seconds") if observation else None
    issues = list(clock["uncertainty"]) + list(recording["issues"])
    issues.extend(observation.get("uncertainty", []) if observation else ["message_observation_unlocated"])
    absolute = iso_at(clock, elapsed)
    if elapsed is not None and absolute is None:
        issues.append("absolute_observation_unavailable")
    return {"event_id": identity, "student": {"student_id": info.get("student_id"), "name": info.get("name")},
            "lab": app.lab_from_cwd(cwd), "cwd": cwd, "recording_id": rec_id,
            "terminal": clock["terminal"], "type": kind, "content": content,
            "observed_at": absolute, "elapsed_seconds": elapsed,
            "observation_semantics": {"shell_command_observed": "命令回显末端所在输出块的观察时间；不是提交或执行时间",
                                       "claude_user_observed": "最终保留问题文本首次完整显示；不是回车提交时间",
                                       "claude_reply_observed": "关联回复正文首次显示；不是后台开始生成或完成时间"}[kind],
            "related_event_id": related,
            "source": {"out": recording["out"], "tim": recording["tim"], "time_source": clock["source"],
                       "header_bytes": recording["header_bytes"],
                       "observation": _public_evidence(recording, observation),
                       "session_start": [{"file": x["source_file"], "line": x["source_line"], "ts": x.get("ts"), "epoch": x.get("epoch")} for x in clock["session_start_evidence"]]},
            "absolute_time_resolution_seconds": 1,
            "uncertainty": list(dict.fromkeys(issues)),
            "ordering_note": "按可用观察时间稳定展示；近同时与跨终端事件不保证严格先后"}


def locate_question(pair, observations, frames, first_answer, lower_frame=0):
    """按首个已关联问答在画面内的同文本出现序号前溯；不跨上一轮边界。"""
    key = app.normalized_message(pair["user"])
    first = observations[0]
    frame = frames[first["frame"]]
    slots = frame["pair_slots"]
    slot = slots[first["observation_index"]] if first["observation_index"] < len(slots) else None
    if slot is None:
        return None, ["user_occurrence_identity_unavailable"]
    ordinal = frame["users"][:slot + 1].count(key)
    # 画面历史只要连续保留该出现序号，就能向前回查真正显示帧。
    # 清屏或历史删除使出现序号变化时停止，以免跨到同文本的旧轮次。
    found = frame
    for candidate in reversed(frames[lower_frame:first["frame"]]):
        count = candidate["users"].count(key)
        if count >= ordinal:
            found = candidate
        elif count == 0:
            break
        else:
            break
    return found, []


def is_claude_launch(command):
    """仅判断执行位置的程序名，正文或 echo 参数中的 claude 不算启动。"""
    try:
        lexer = shlex.shlex(command, posix=True, punctuation_chars=";&|()")
        lexer.whitespace_split = True
        tokens = list(lexer)
    except ValueError:
        return False
    at_command, wrapper, skip_value = True, None, False
    value_options = {
        "env": {"-u", "--unset", "-C", "--chdir"},
        "sudo": {"-u", "--user", "-g", "--group", "-h", "--host", "-p", "--prompt", "-C", "--close-from", "-T", "--command-timeout", "-R", "--chroot", "-D", "--chdir"},
        "exec": {"-a"},
    }
    for token in tokens:
        if token in (";", "&&", "||", "|", "&", "(", ")"):
            at_command, wrapper, skip_value = True, None, False
            continue
        if not at_command:
            continue
        if skip_value:
            skip_value = False
            continue
        if wrapper and token in value_options.get(wrapper, set()):
            skip_value = True
            continue
        if wrapper and token.startswith("-"):
            if (token in ("--help", "--version")
                    or wrapper == "command" and token in ("-v", "-V")
                    or wrapper == "env" and token in ("-S", "--split-string")):
                at_command = False
            continue
        if re.match(r"^[A-Za-z_][A-Za-z_0-9]*=", token):
            continue
        if token in ("env", "command", "exec", "sudo", "nohup"):
            wrapper = token
            continue
        if token.rsplit("/", 1)[-1] == "claude":
            return True
        at_command = False
    return False


def build_student_timeline(info):
    source = Path(info["source"])
    term = source / "term"
    if not term.is_dir() or app.is_link_like(term):
        return {"events": [], "recordings": 0, "errors": ["缺少 term/ 录像目录"], "recording_details": [], "processing_failed": True}
    log_records, sessions, log_issues = load_collection_log(source)
    events, errors, details = [], list(log_issues), []
    contexts = []
    observed_labs = set()
    files = app.term_recordings(term)
    prefix = hashlib.sha256(str(source.resolve()).encode("utf-8")).hexdigest()[:12]
    for out in files:
        rec_id = out.name[:-len(".out.gz")]
        tim = out.with_name(rec_id + ".tim.gz")
        detail = {"recording_id": rec_id, "out": (Path("term") / out.name).as_posix(), "status": "ok", "events": 0,
                  "claude_retained_pairs": 0, "claude_record_count": 0,
                  "claude_unretained_record_count": 0, "claude_incomplete_record_count": 0,
                  "claude_extraction_status": "no_recognizable_role_markers"}
        details.append(detail)
        before = len(events)
        try:
            recording = read_recording(out, tim)
            recording["out"] = (Path("term") / out.name).as_posix()
            recording["tim"] = (Path("term") / tim.name).as_posix()
            regions = app.split_lab_regions(recording["body"])
            observed_labs.update(
                region["lab"] for region in regions
                if region.get("lab") in app.LAB_KEYS
            )
            clock = choose_clock(recording, sessions.get(rec_id, []))
            contexts.append({
                "recording_id": rec_id,
                "clock": clock,
                "terminal": clock["terminal"],
                "duration_seconds": recording["entries"][-1]["elapsed"] if recording["entries"] else None,
            })
            detail.update(format=recording["format"], header_bytes=recording["header_bytes"],
                          body_bytes=len(recording["body"]), timing_bytes=recording["timed_bytes"],
                          administrative_tail=recording["administrative_tail"],
                          header_start=recording["header_start"].isoformat() if recording["header_start"] else None,
                          chosen_start=clock["start"].isoformat() if clock["start"] else None,
                          time_source=clock["source"], global_clock_usable=clock["usable"],
                          terminal=clock["terminal"], issues=recording["issues"] + clock["uncertainty"])
            evidence = []
            _, _, commands = app.extract_session(str(out), str(tim), source_data=(recording["header"], recording["start_text"], recording["cols"], recording["rows"], recording["body"]), evidence=evidence)
            launches = []
            for seq, (command, location) in enumerate(zip(commands, evidence), 1):
                identity = f"{prefix}:{rec_id}:shell:{seq}"
                observation = evidence_at_byte(recording, location["echo_end"] - 1)
                event = _event(info, rec_id, recording, clock, identity, "shell_command_observed", command["command"], command["cwd"], observation)
                event["source"]["shell_ranges"] = dict(location)
                event["source"]["shell_decompressed_ranges"] = {key: value + recording["header_bytes"] for key, value in location.items()}
                is_launch = is_claude_launch(command["command"])
                event["output"] = None if is_launch else command["output"][:app.MAX_OUTPUT_LINES]
                event["output_note"] = "Claude 启动输出含 TUI，正文单独展开；完整输出可按原始字节范围回查" if is_launch else "关联原提取器的命令输出；未推定执行结束或输出时间"
                event["output_truncated"] = not is_launch and len(command["output"]) > app.MAX_OUTPUT_LINES
                if is_launch:
                    launches.append((location["echo_end"], event))
                events.append(event)
            # 没有角色标记的流无法包含现有识别器可识别的问答，无需逐帧重放。
            if "❯".encode() in recording["body"] and "●".encode() in recording["body"]:
                detail["claude_extraction_status"] = "screen_replayed_no_retained_pairs"
                for region_no, region in enumerate(regions, 1):
                    frames, trace = [], {}
                    _, pairs = app.extract_claude_session(str(out), str(tim), frame_source=iter_region_frames(recording, region, frames), evidence=trace)
                    detail["claude_retained_pairs"] += len(pairs)
                    detail["claude_record_count"] += trace.get("record_count", 0)
                    detail["claude_unretained_record_count"] += trace.get("unretained_record_count", 0)
                    detail["claude_incomplete_record_count"] += trace.get("incomplete_record_count", 0)
                    if pairs:
                        detail["claude_extraction_status"] = "retained_pairs"
                    observations = trace.get("observations", [])
                    previous_first = 0
                    for pair_no, (pair, record_ids) in enumerate(zip(pairs, trace.get("pair_record_ids", [])), 1):
                        related = [x for x in observations if x["record_id"] in record_ids]
                        if not related:
                            raise ValueError("保留问答缺少记录身份观察")
                        first_reply = frames[related[0]["frame"]]
                        question, question_issues = locate_question(pair, related, frames, first_reply, previous_first)
                        previous_first = related[0]["frame"]
                        end_key = app.normalized_message(pair["claude"])
                        final = next((frames[x["frame"]] for x in related if app.normalized_message(x["claude"]) == end_key), None)
                        launch = next((event for position, event in reversed(launches)
                                       if region["begin"] <= position <= first_reply["body_byte_range"][1]
                                       and first_reply["body_byte_range"][0] < event["source"]["shell_ranges"]["output_end"]), None)
                        cwd = launch["cwd"] if launch else region["cwd"]
                        base = f"{prefix}:{rec_id}:region:{region_no}:qa:{pair_no}"
                        user = _event(info, rec_id, recording, clock, base + ":user", "claude_user_observed", pair["user"], cwd, question, launch["event_id"] if launch else None)
                        reply = _event(info, rec_id, recording, clock, base + ":reply", "claude_reply_observed", pair["claude"], cwd, first_reply, user["event_id"])
                        user["uncertainty"].extend(question_issues)
                        for event in (user, reply):
                            event["qa_pair_id"] = base
                            event["claude_launch_event_id"] = launch["event_id"] if launch else None
                            event["source"].update(region_number=region_no, region_body_byte_range=[region["begin"], region["end"]], message_record_ids=record_ids)
                            if not launch:
                                event["uncertainty"].append("claude_launch_command_unlocated")
                        reply["first_observed_excerpt"] = related[0]["claude"]
                        reply["final_text_first_observed_at"] = iso_at(clock, final["elapsed_seconds"]) if final else None
                        reply["final_text_first_elapsed_seconds"] = final["elapsed_seconds"] if final else None
                        reply["final_text_observation_semantics"] = "最终保留正文首次完整匹配的观察时间；不是后台完成事件，可能晚于下一轮问题"
                        reply["source"]["final_text_observation"] = _public_evidence(recording, final)
                        if final is None:
                            reply["uncertainty"].append("final_text_full_observation_unlocated")
                        events.extend((user, reply))
            detail["events"] = len(events) - before
            for issue in detail["issues"]:
                errors.append(rec_id + ": " + issue)
        except Exception as exc:
            detail.update(status="error", error=f"{type(exc).__name__}: {exc}", events=len(events) - before)
            errors.append(rec_id + ": " + detail["error"])
    events.extend(build_collection_log_events(info, log_records, contexts, prefix))
    events.sort(key=lambda e: (e["observed_at"] is None,
                              parse_datetime(e["observed_at"]).timestamp() if e["observed_at"] else 0,
                              str(e.get("recording_id") or ""),
                              e["elapsed_seconds"] if e["elapsed_seconds"] is not None else float("inf"),
                              e["event_id"]))
    return {"events": events, "recordings": len(files), "errors": errors,
            "recording_details": details, "labs": sorted(observed_labs)}


def _cached_header_start(header):
    if not isinstance(header, dict):
        return None
    for value in (header.get("start"), header.get("start_text"), header.get("started_at")):
        parsed = parse_datetime(value)
        if parsed is not None:
            return parsed
        match = re.search(r"\d{4}-\d\d-\d\d[ T]\d\d:\d\d:\d\d(?:\.\d+)?(?:Z|[+-]\d\d:\d\d)", str(value or ""))
        if match:
            parsed = parse_datetime(match.group(0))
            if parsed is not None:
                return parsed
    return None


def _cached_timing_index(value):
    entries = []
    if not isinstance(value, (list, tuple)):
        return entries
    for raw in value:
        if not isinstance(raw, dict):
            return []
        try:
            line = int(raw.get("line"))
            begin = int(raw.get("begin"))
            end = int(raw.get("end"))
            elapsed = float(raw.get("elapsed"))
        except (TypeError, ValueError):
            return []
        if line < 1 or begin < 0 or end < begin or not math.isfinite(elapsed) or elapsed < 0:
            return []
        entries.append({"line": line, "begin": begin, "end": end, "elapsed": elapsed})
    if any(later["begin"] < earlier["end"] or later["elapsed"] < earlier["elapsed"]
           for earlier, later in zip(entries, entries[1:])):
        return []
    return entries


def _cache_observation(value, timing_entries, timing_valid):
    """Normalize cache evidence while refusing times from an invalid timing index."""
    raw = value if isinstance(value, dict) else {}
    observation = dict(raw)
    elapsed = raw.get("elapsed_seconds", raw.get("elapsed"))
    try:
        elapsed = float(elapsed)
        if not math.isfinite(elapsed) or elapsed < 0:
            elapsed = None
    except (TypeError, ValueError):
        elapsed = None
    if not timing_valid:
        elapsed = None
    if elapsed is not None and observation.get("timing_line") is None:
        entry = next((item for item in timing_entries if item["elapsed"] >= elapsed), None)
        if entry:
            observation["timing_line"] = entry["line"]
            observation.setdefault("body_byte_range", [entry["begin"], entry["end"]])
    observation["elapsed_seconds"] = elapsed
    uncertainty = list(observation.get("uncertainty") or [])
    if elapsed is None:
        uncertainty.append("frame_not_covered_by_valid_timing")
    observation["uncertainty"] = list(dict.fromkeys(map(str, uncertainty)))
    return observation


def _cached_terminal_event(info, rec_id, source_relative, tim_relative, clock, issues,
                           identity, kind, content, cwd, observation, related=None):
    elapsed = observation.get("elapsed_seconds") if isinstance(observation, dict) else None
    uncertainty = list(clock.get("uncertainty") or []) + list(issues or [])
    uncertainty.extend(observation.get("uncertainty", []) if isinstance(observation, dict)
                      else ["message_observation_unlocated"])
    absolute = iso_at(clock, elapsed)
    if elapsed is not None and absolute is None:
        uncertainty.append("absolute_observation_unavailable")
    semantics = {
        "shell_command_observed": "命令回显末端所在输出块的观察时间；不是提交或执行时间",
        "claude_user_observed": "最终保留问题文本首次完整显示；不是回车提交时间",
        "claude_reply_observed": "关联回复正文首次显示；不是后台开始生成或完成时间",
    }.get(kind, "终端画面观察时间")
    return {
        "event_id": identity,
        "student": {"student_id": info.get("student_id"), "name": info.get("name")},
        "lab": app.lab_from_cwd(cwd) if isinstance(cwd, str) else "other",
        "cwd": cwd,
        "recording_id": rec_id,
        "terminal": clock.get("terminal") or {},
        "type": kind,
        "evidence_level": "E1",
        "content": content,
        "observed_at": absolute,
        "elapsed_seconds": elapsed,
        "observation_semantics": semantics,
        "related_event_id": related,
        "source": {
            "out": source_relative,
            "tim": tim_relative,
            "time_source": clock.get("source"),
            "observation": {
                key: observation[key] for key in ("frame", "elapsed_seconds", "timing_line",
                                                    "body_byte_range", "decompressed_byte_range",
                                                    "changed_rows")
                if isinstance(observation, dict) and key in observation
            },
            "session_start": [
                {"file": item.get("source_file"), "line": item.get("source_line"),
                 "ts": item.get("ts"), "epoch": item.get("epoch")}
                for item in clock.get("session_start_evidence", [])
            ],
        },
        "absolute_time_resolution_seconds": 1,
        "uncertainty": list(dict.fromkeys(map(str, uncertainty))),
        "ordering_note": "按可用观察时间稳定展示；近同时与跨终端事件不保证严格先后",
    }


def _cached_pair_observations(pair, timing_entries, timing_valid):
    evidence = pair.get("evidence") if isinstance(pair.get("evidence"), dict) else {}
    if isinstance(pair.get("evidence"), (list, tuple)):
        frames = list(pair["evidence"])
        evidence = {
            "user": frames[0] if frames else None,
            "reply": frames[1] if len(frames) > 1 else (frames[0] if frames else None),
            "final": frames[-1] if frames else None,
        }
    user = evidence.get("user", evidence.get("question", pair.get("user_evidence")))
    reply = evidence.get("reply", evidence.get("first_reply", pair.get("reply_evidence")))
    final = evidence.get("final", evidence.get("final_text", pair.get("final_evidence")))
    return (
        _cache_observation(user, timing_entries, timing_valid),
        _cache_observation(reply, timing_entries, timing_valid),
        _cache_observation(final, timing_entries, timing_valid) if final is not None else None,
    )


def build_student_timeline_from_recordings(info, recordings):
    """Build E1/E2 timelines from recording-cache results without replaying gzip input.

    The public input is the recording result schema produced by ``replay_engine``:
    ``header``, ``timing_index``, ``lab_regions``, ``commands``, and optional
    ``claude_pairs``.  Invalid cache records become per-recording diagnostics;
    collection-log E2 entries are still emitted from the current source log.
    """
    source = Path(info["source"])
    log_records, sessions, log_issues = load_collection_log(source)
    if isinstance(recordings, dict):
        recordings = list(recordings.values())
    recordings = list(recordings or [])
    normalized = [dict(item) for item in recordings if isinstance(item, dict)]
    normalized.sort(key=lambda item: (str(item.get("source_relative") or ""),
                                      str(item.get("recording_id") or "")))
    prefix = hashlib.sha256(str(source.resolve()).encode("utf-8")).hexdigest()[:12]
    events, errors, details, contexts, observed_labs = [], list(log_issues), [], [], set()
    for item in normalized:
        canonical_id = str(item.get("recording_id") or "")
        rec_id = str(item.get("recording_name") or Path(canonical_id).name or
                     Path(str(item.get("out_relative") or item.get("source_relative") or "unknown")).name)
        if rec_id.endswith(".out.gz"):
            rec_id = rec_id[:-len(".out.gz")]
        source_relative = str(
            item.get("out_relative") or item.get("source_relative") or
            (Path("term") / (rec_id + ".out.gz")).as_posix()
        ).replace("\\", "/")
        tim_relative = str(item.get("tim_relative") or "").replace("\\", "/")
        if not tim_relative and source_relative.endswith(".out.gz"):
            tim_relative = source_relative[:-len(".out.gz")] + ".tim.gz"
        status = str(item.get("status") or "ok")
        header = item.get("header") if isinstance(item.get("header"), dict) else {}
        timing_valid = bool(item.get("timing_valid"))
        timing_entries = _cached_timing_index(item.get("timing_index")) if timing_valid else []
        issues = [str(issue) for issue in (item.get("issues") or [])]
        if timing_valid and not timing_entries:
            timing_valid = False
            issues.append("cached_timing_index_invalid")
        cache_recording = {
            "header_start": _cached_header_start(header),
            "header_tty": header.get("tty", header.get("header_tty")),
        }
        clock = choose_clock(cache_recording, sessions.get(rec_id, []))
        regions = item.get("lab_regions") if isinstance(item.get("lab_regions"), (list, tuple)) else []
        for region in regions:
            if isinstance(region, dict) and region.get("lab") in app.LAB_KEYS:
                observed_labs.add(region["lab"])
        detail = {
            "recording_id": rec_id,
            "out": source_relative,
            "status": "error" if status == "error" else "ok",
            "issues": issues + list(clock.get("uncertainty") or []),
            "time_source": clock.get("source"),
            "global_clock_usable": bool(clock.get("usable")),
            "terminal": clock.get("terminal"),
        }
        details.append(detail)
        if status == "error":
            detail["error"] = str(item.get("error") or "录像缓存分析失败")
            errors.append(rec_id + ": " + detail["error"])
            continue
        contexts.append({
            "recording_id": rec_id,
            "clock": clock,
            "terminal": clock["terminal"],
            "duration_seconds": timing_entries[-1]["elapsed"] if timing_entries else None,
        })
        before = len(events)
        for seq, command in enumerate(item.get("commands") or [], 1):
            if not isinstance(command, dict):
                continue
            cwd = command.get("cwd") if isinstance(command.get("cwd"), str) else None
            observation = _cache_observation(command.get("evidence", command), timing_entries, timing_valid)
            event = _cached_terminal_event(
                info, rec_id, source_relative, tim_relative, clock, issues,
                f"{prefix}:{rec_id}:shell:{seq}", "shell_command_observed",
                str(command.get("command") or ""), cwd, observation,
            )
            anchors = command.get("anchors") if isinstance(command.get("anchors"), dict) else {}
            if anchors:
                event["source"]["shell_ranges"] = dict(anchors)
            event["output"] = command.get("output")
            events.append(event)
        for pair_no, pair in enumerate(item.get("claude_pairs") or [], 1):
            if not isinstance(pair, dict):
                continue
            user_observation, reply_observation, final_observation = _cached_pair_observations(
                pair, timing_entries, timing_valid
            )
            lab = pair.get("lab") if pair.get("lab") in app.LAB_KEYS else "other"
            cwd = pair.get("cwd") if isinstance(pair.get("cwd"), str) else None
            base = f"{prefix}:{rec_id}:qa:{pair_no}"
            user = _cached_terminal_event(
                info, rec_id, source_relative, tim_relative, clock, issues,
                base + ":user", "claude_user_observed", str(pair.get("user") or ""), cwd, user_observation,
            )
            reply = _cached_terminal_event(
                info, rec_id, source_relative, tim_relative, clock, issues,
                base + ":reply", "claude_reply_observed", str(pair.get("claude") or ""), cwd,
                reply_observation, user["event_id"],
            )
            user["lab"] = reply["lab"] = lab
            user["qa_pair_id"] = reply["qa_pair_id"] = base
            evidence = pair.get("evidence") if isinstance(pair.get("evidence"), dict) else {}
            question_issues = evidence.get("question_uncertainty")
            if isinstance(question_issues, (list, tuple)):
                user["uncertainty"] = list(dict.fromkeys(
                    list(user["uncertainty"]) + [str(issue) for issue in question_issues]
                ))
            for event in (user, reply):
                event["source"].update({
                    "region_number": pair.get("region_number"),
                    "region_body_byte_range": pair.get("region_body_byte_range"),
                    "message_record_ids": pair.get("record_ids"),
                })
            if final_observation is not None:
                reply["final_text_first_elapsed_seconds"] = final_observation["elapsed_seconds"]
                reply["final_text_first_observed_at"] = iso_at(clock, final_observation["elapsed_seconds"])
                reply["source"]["final_text_observation"] = final_observation
                reply["final_text_observation_semantics"] = "最终保留正文首次完整匹配的观察时间；不是后台完成事件"
            events.extend((user, reply))
        detail["events"] = len(events) - before
    events.extend(build_collection_log_events(info, log_records, contexts, prefix))
    events.sort(key=lambda event: (
        event.get("observed_at") is None,
        parse_datetime(event.get("logged_at") or event.get("observed_at")).timestamp()
        if event.get("logged_at") or event.get("observed_at") else 0,
        str(event.get("recording_id") or ""),
        event.get("elapsed_seconds") if event.get("elapsed_seconds") is not None else float("inf"),
        str(event.get("event_id") or ""),
    ))
    return {
        "events": events,
        "recordings": len(normalized),
        "errors": errors,
        "recording_details": details,
        "labs": sorted(observed_labs),
    }
