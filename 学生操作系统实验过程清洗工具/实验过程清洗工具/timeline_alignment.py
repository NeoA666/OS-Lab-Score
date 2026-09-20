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


def load_session_logs(source):
    path = Path(source) / "logs" / "events.jsonl"
    sessions, issues = {}, []
    if app.has_link_component(path):
        return sessions, ["session_log_linked"]
    if not path.is_file():
        return sessions, ["session_log_missing"]
    previous = None
    try:
        handle = path.open("r", encoding="utf-8", errors="replace")
    except OSError as exc:
        return sessions, ["session_log_unreadable: " + str(exc)]
    with handle:
        for line_no, line in enumerate(handle, 1):
            if line.startswith("\0"):
                issues.append(f"日志第 {line_no} 行有 NUL 前缀，保留尾部 JSON")
                line = line.lstrip("\0")
            try:
                event = json.loads(line)
                if not isinstance(event, dict):
                    raise ValueError("日志项不是对象")
            except (ValueError, TypeError):
                issues.append(f"日志第 {line_no} 行不可解析")
                continue
            timestamp = parse_datetime(event.get("ts"))
            if timestamp and previous and timestamp < previous:
                issues.append(f"日志第 {line_no} 行时间倒退；未据此校正录像时钟")
            if timestamp:
                previous = timestamp
            if event.get("type") == "session_start" and event.get("rec"):
                event = dict(event, source_file="logs/events.jsonl", source_line=line_no)
                sessions.setdefault(str(event["rec"]), []).append(event)
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
    sessions, log_issues = load_session_logs(source)
    events, errors, details = [], list(log_issues), []
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
    events.sort(key=lambda e: (e["observed_at"] is None,
                              parse_datetime(e["observed_at"]).timestamp() if e["observed_at"] else 0,
                              e["recording_id"], e["elapsed_seconds"] if e["elapsed_seconds"] is not None else float("inf"),
                              e["event_id"]))
    return {"events": events, "recordings": len(files), "errors": errors,
            "recording_details": details, "labs": sorted(observed_labs)}
