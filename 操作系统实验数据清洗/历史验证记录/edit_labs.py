from pathlib import Path
p=Path('replay_term_qa.py')
s=p.read_text(encoding='utf-8')
pos=s.index('def write_student_reports(')
new='''REPORT_FOLDERS = ("终端对话记录", "完整终端转写记录", "终端命令统计", "claude对话")
LAB_KEYS = tuple(f"lab{i}" for i in range(9)) + ("other",)
# 仅用于工作目录分类，不改变原有 Shell 命令提取规则。
LAB_PROMPT_RAW = re.compile(
    SGR + rb"(?P<uh>[^\\s@\\x1b]+@[^\\s:\\x1b]+)" + SGR + rb":"
    + SGR + rb"(?P<cwd>.*?)" + SGR + rb"[$#] "
)
PLAIN_LAB_PROMPT_RAW = re.compile(
    rb"(?:^|(?<=[\\r\\n]))[^\\s@\\x1b]+@[^\\s:\\x1b]+:(?P<cwd>[^\\r\\n\\x1b]*?)[$#] "
)


def lab_from_cwd(cwd):
    """仅按完整目录段识别 lab0–lab8，支持其子目录；lab10、lab0-copy 不匹配。"""
    parts = cwd.strip().replace("\\\\", "/").split("/")
    # 规范化 ..，避免 /lab0/../other 被错误分类为 lab0。
    normalized = []
    for part in parts:
        if part == "..":
            if normalized:
                normalized.pop()
        elif part not in ("", "."):
            normalized.append(part)
    return next((part for part in reversed(normalized) if part in LAB_KEYS[:-1]), "other")


def lab_report_paths(lab):
    """四种报告放在四个中文子目录中，以 lab 或 other 为文件后缀。"""
    if lab not in LAB_KEYS:
        raise ValueError(f"未知实验分类：{lab}")
    return tuple(Path(folder) / f"{Path(name).stem}_{lab}.md"
                 for folder, name in zip(REPORT_FOLDERS, REPORT_NAMES))


def split_lab_regions(body):
    """在真实提示符处切分工作目录变化；不根据用户输入、cd 文本或回复内容猜测。"""
    prompts = list(LAB_PROMPT_RAW.finditer(body))
    if not prompts:
        # 无彩色提示符的录像才使用行首普通提示符，避免 Claude 粘贴文本误触发。
        prompts = list(PLAIN_LAB_PROMPT_RAW.finditer(body))
    if not prompts:
        return [{"lab": "other", "begin": 0, "end": len(body), "cwd": "未知"}]
    first_cwd = prompts[0].group("cwd").decode("utf-8", "replace")
    regions = [{"lab": lab_from_cwd(first_cwd), "begin": 0, "cwd": first_cwd}]
    for prompt in prompts[1:]:
        cwd = prompt.group("cwd").decode("utf-8", "replace")
        lab = lab_from_cwd(cwd)
        if lab != regions[-1]["lab"]:
            regions[-1]["end"] = prompt.start()
            regions.append({"lab": lab, "begin": prompt.start(), "cwd": cwd})
    regions[-1]["end"] = len(body)
    return regions


def region_timing(entries, begin, end):
    """裁剪 timing 字节区间；首帧保留原录像累计时间，跨分类边界的一帧拆开。"""
    offset = 0
    elapsed = 0.0
    last_emitted = 0.0
    clipped = []
    for delay, size in entries:
        elapsed += delay
        next_offset = offset + size
        overlap = min(end, next_offset) - max(begin, offset)
        if overlap > 0:
            clipped.append((elapsed - last_emitted, overlap))
            last_emitted = elapsed
        offset = next_offset
        if offset >= end:
            break
    # 缺失/截短计时信息时仍保留全部剩余字节，与旧版降级逻辑一致。
    if offset < end:
        size = end - max(begin, offset)
        if size > 0:
            clipped.append((max(0.0, elapsed - last_emitted), size))
    return clipped


def new_lab_bucket():
    return {"files": set(), "commands": [], "full": [], "claude": {},
            "errors": [], "shell_success": set()}


def finish_student_reports(info, paths):
    """登记新版报告清单；仅移除同来源清单中已过时的程序报告，不碰原始数据。"""
    directory = info["output"].resolve()
    owner_path = directory / OWNER_FILE
    try:
        previous = json.loads(owner_path.read_text(encoding="utf-8"))
    except (OSError, ValueError):
        previous = {}
    allowed = set(REPORT_NAMES) | {p.as_posix() for lab in LAB_KEYS for p in lab_report_paths(lab)}
    wanted = {p.as_posix() for p in paths}
    if (isinstance(previous, dict) and previous.get("tool") == "replay_term_qa"
            and previous.get("source") == info["source"]):
        for relative in previous.get("reports", []):
            if relative in allowed and relative not in wanted:
                target = directory / relative
                resolved = target.resolve()
                if directory in resolved.parents and not target.is_symlink() and target.is_file():
                    target.unlink()
    atomic_write(owner_path, json.dumps(
        {"tool": "replay_term_qa", "source": info["source"], "layout": "by-lab-v1",
         "reports": sorted(wanted)}, ensure_ascii=False, indent=2))


'''
s=s[:pos]+new+s[pos:]
s=s.replace('                          shell_success):','                          shell_success, lab="other"):')
s=s.replace('    header = lambda title: student_header(title, info, len(files))','    header = lambda title: student_header(title, info, len(files)) + [\n        f"- 实验分类：{lab if lab != \'other\' else \'其他（非 lab0–lab8 或目录未知）\'}", ""]')
s=s.replace("f\"- 成功重放数量：{sum('error' not in s for s in full_sessions)}\",", "f\"- 成功重放数量：{len({s['rec'] for s in full_sessions if 'error' not in s} - {s['rec'] for s in full_sessions if 'error' in s})}\",")
s=s.replace("f\"- 重放失败数量：{sum('error' in s for s in full_sessions)}\",", "f\"- 重放失败数量：{len({s['rec'] for s in full_sessions if 'error' in s})}\",")
s=s.replace('        full.extend([f"## Session {s[\'rec\']}", ""])', '''        suffix = f" · 片段 {s['region']}" if 'region' in s else ""
        full.extend([f"## Session {s['rec']}{suffix}", ""])
        if 'begin' in s:
            full.extend([f"- 原录像字节区间：[ {s['begin']}, {s['end']} )",
                         f"- 分类依据目录：{markdown_text(s['cwd'])}", ""])''')
a=s.index('    # 首次写入前登记归属；')
b=s.index('\n\ndef process_student',a)
s=s[:a]+'''    for name, content in zip(lab_report_paths(lab), (report, full, stats, qa)):
        target = info["output"] / name
        if info["output"].resolve() not in target.resolve().parents:
            raise ValueError(f"报告目标越出学生输出目录：{target}")
        atomic_write(target, "\\n".join(content))
    return {"recordings": len(files), "commands": len(commands), "claude_sessions": len(claude_sessions),
            "turns": turns, "replay_failed": len({s['rec'] for s in full_sessions if "error" in s})}
''' +s[b:]
a=s.index('def process_student(')
b=s.index('\n\ndef write_readme',a)
s=s[:a]+'''def process_student(info):
    """按提示符工作目录分段重放；Claude 保持启动目录归属，直到返回新的 Shell 提示符。"""
    term = Path(info["source"]) / "term"
    if not term.is_dir() or term.is_symlink():
        return {"status": "跳过", "info": info, "errors": [f"{term}：缺少 term/ 或为符号链接"]}
    files = sorted((p for p in term.glob("*.out.gz") if p.is_file()), key=lambda p: p.name)
    buckets, errors, failed_recordings = {}, [], set()
    claude_recordings = set()
    stage_failed = False

    def bucket(lab):
        return buckets.setdefault(lab, new_lab_bucket())

    for number, out in enumerate(files, 1):
        tim = out.with_name(out.name[:-len(".out.gz")] + ".tim.gz")
        rec = out.name[:-len(".out.gz")]
        print(f"  [录像 {number}/{len(files)}] {out.name}", flush=True)
        entries = read_timing_entries(tim)
        if not entries:
            warning = f"{tim}：计时文件缺失、为空或不可读，使用一次性重放降级"
            errors.append(warning)
            print(f"  [警告] {warning}", flush=True)
        try:
            header, start, columns, rows, body = read_term(out)
            regions = split_lab_regions(body)
        except Exception as exc:
            message = f"{out} [完整重放/目录分类] {type(exc).__name__}: {exc}"
            errors.append(message)
            failed_recordings.add(rec)
            stage_failed = True
            group = bucket("other")
            group["files"].add(out)
            group["errors"].append(message)
            group["full"].append({"rec": rec, "file": str(out), "error": str(exc)})
            print(f"  [失败] {message}", flush=True)
            continue
        for region in regions:
            group = bucket(region["lab"])
            group["files"].add(out)
            if not entries and warning not in group["errors"]:
                group["errors"].append(warning)
        # 命令仍在完整原录像上提取一次，按每条命令的原始 cwd 分流。
        try:
            _, _, extracted = extract_session(str(out), str(tim))
            for command in extracted:
                group = bucket(lab_from_cwd(command["cwd"]))
                group["files"].add(out)
                group["commands"].append(command)
            for group in buckets.values():
                if out in group["files"]:
                    group["shell_success"].add(rec)
        except Exception as exc:
            message = f"{out} [Shell 提取] {type(exc).__name__}: {exc}"
            errors.append(message)
            stage_failed = True
            for region in regions:
                bucket(region["lab"])["errors"].append(message)
            print(f"  [失败] {message}", flush=True)

        # 使用临时 gzip 片段复用原 pyte Screen/diff 提取器；从不改写学生文件。
        with tempfile.TemporaryDirectory(prefix="replay-labs-") as temporary:
            for index, region in enumerate(regions, 1):
                group = bucket(region["lab"])
                try:
                    if len(regions) == 1:
                        segment_out, segment_tim = out, tim
                    else:
                        segment_out = Path(temporary) / out.name
                        segment_tim = Path(temporary) / tim.name
                        segment = body[region["begin"]:region["end"]]
                        segment_out.write_bytes(gzip.compress(header.encode("utf-8") + b"\\n" + segment))
                        clipped = region_timing(entries, region["begin"], region["end"])
                        segment_tim.write_bytes(gzip.compress("".join(
                            f"{delay:.9f} {size}\\n" for delay, size in clipped).encode("ascii")))
                except Exception as exc:
                    message = f"{out} [{region['lab']} 片段 {index} 准备] {type(exc).__name__}: {exc}"
                    errors.append(message)
                    group["errors"].append(message)
                    group["full"].append({"rec": rec, "file": str(out), "error": str(exc)})
                    failed_recordings.add(rec)
                    stage_failed = True
                    continue
                for stage in ("完整重放", "Claude QA 提取"):
                    try:
                        if stage == "完整重放":
                            session = replay_full_terminal(segment_out, segment_tim)
                            session.update(region=index, begin=region["begin"], end=region["end"], cwd=region["cwd"])
                            group["full"].append(session)
                        else:
                            _, pairs = extract_claude_session(str(segment_out), str(segment_tim))
                            session = group["claude"].setdefault(rec, {"rec": rec, "start": start, "pairs": []})
                            session["pairs"].extend(pairs)
                            if pairs:
                                claude_recordings.add(rec)
                    except Exception as exc:
                        message = f"{out} [{region['lab']} 片段 {index} {stage}] {type(exc).__name__}: {exc}"
                        errors.append(message)
                        group["errors"].append(message)
                        stage_failed = True
                        print(f"  [失败] {message}", flush=True)
                        if stage == "完整重放":
                            failed_recordings.add(rec)
                            group["full"].append({"rec": rec, "file": str(out), "error": str(exc)})
    if not buckets:
        bucket("other")
    per_lab, paths = {}, []
    for lab in LAB_KEYS:
        if lab not in buckets:
            continue
        group = buckets[lab]
        per_lab[lab] = write_student_reports(
            info, group["files"], group["commands"], group["full"], list(group["claude"].values()),
            group["errors"], len(group["shell_success"]), lab)
        paths.extend(lab_report_paths(lab))
        print(f"  [分类 {lab}] {per_lab[lab]['recordings']} 个录像，"
              f"{per_lab[lab]['commands']} 条命令，{per_lab[lab]['turns']} 轮 QA", flush=True)
    finish_student_reports(info, paths)
    return {"status": "部分失败" if stage_failed else "成功", "info": info, "errors": errors,
            "recordings": len(files), "commands": sum(r["commands"] for r in per_lab.values()),
            "claude_sessions": len(claude_recordings), "turns": sum(r["turns"] for r in per_lab.values()),
            "replay_failed": len(failed_recordings), "labs": per_lab}
''' +s[b:]
p.write_text(s,encoding='utf-8')
