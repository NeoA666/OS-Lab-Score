"""保存学生原始提交并生成独立证据报告；绝不执行学生代码。"""
from __future__ import annotations

import argparse
import hashlib
import json
import math
import re
import tarfile
from pathlib import Path, PurePosixPath
from urllib.parse import quote

ROOT = Path(__file__).resolve().parent
DEFAULT_INPUT = ROOT / "原始数据"
DEFAULT_OUTPUT = ROOT / "已处理数据"
OWNER = "ai-experience-batch-v1"
MAX_TOTAL_BYTES = 512 * 1024 * 1024
MAX_MEMBERS = 100000


def cell(value):
    text = str(value).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("|", "&#124;").replace("\r", " ").replace("\n", " ")
    for char in "`*[]_":
        text = text.replace(char, f"&#{ord(char)};")
    return text


def digest(data):
    return hashlib.sha256(data).hexdigest()


def safe_name(name):
    """Reject paths unsafe on both POSIX and Windows; never use tar extraction."""
    if not isinstance(name, str) or not name or "\\" in name or name.startswith("/"):
        raise ValueError(f"不安全路径：{name!r}")
    parts = name.rstrip("/").split("/")
    for part in parts:
        if (part in ("", ".", "..") or part.endswith((".", " "))
                or re.search(r'[<>:"|?*\x00-\x1f]', part)
                or part.split(".")[0].upper() in {"CON", "PRN", "AUX", "NUL", *[f"COM{i}" for i in range(1, 10)], *[f"LPT{i}" for i in range(1, 10)]}):
            raise ValueError(f"不安全路径：{name!r}")
    return "/".join(parts)


def read_archive(path):
    files, dirs, seen, total = {}, [], {}, 0
    with tarfile.open(path, "r:gz") as archive:
        for index, member in enumerate(archive):
            if index >= MAX_MEMBERS:
                raise ValueError("压缩包成员数量超过限制")
            name = safe_name(member.name)
            key = name.casefold()
            if key in seen:
                raise ValueError(f"重复目标路径：{name}")
            if not (member.isfile() or member.isdir()):
                raise ValueError(f"拒绝链接或特殊成员：{name}")
            seen[key] = "dir" if member.isdir() else "file"
            if member.isdir():
                dirs.append(name)
                continue
            total += member.size
            if total > MAX_TOTAL_BYTES:
                raise ValueError("压缩包展开大小超过 512 MiB")
            with archive.extractfile(member) as stream:
                data = stream.read()
            if len(data) != member.size:
                raise ValueError(f"成员内容不完整：{name}")
            files[name] = data
    for name in seen:
        for parent in PurePosixPath(name).parents:
            if str(parent) != "." and seen.get(str(parent)) == "file":
                raise ValueError(f"文件与目录路径冲突：{name}")
    return files, dirs


def validate(files, student_id):
    checks = []
    def check(item, expected, actual, source, level="失败"):
        checks.append({"status": "通过" if expected == actual else level, "item": item,
                       "expected": expected, "actual": actual, "source": source})
    def parse(name, kind):
        try:
            obj = json.loads(files[name].decode("utf-8-sig"))
            if not isinstance(obj, kind):
                raise ValueError("顶层类型错误")
            check("JSON 可解析", True, True, name)
            return obj
        except (KeyError, UnicodeError, ValueError) as exc:
            check("JSON 可解析", True, str(exc), name)
            return None
    manifest = parse("manifest.json", dict)
    blocked = False
    if manifest is not None:
        owner = manifest.get("owner_username")
        check("学生账号一致", student_id, owner, "manifest.json")
        blocked = owner is not None and str(owner) != student_id
        listed = set()
        for category in ("added", "changed", "deleted"):
            names = manifest.get(category + "_files")
            if not isinstance(names, list):
                check(category + "_files 类型", "list", type(names).__name__, "manifest.json")
                continue
            check(category + "_count", len(names), manifest.get(category + "_count"), "manifest.json")
            for raw in names:
                try:
                    name = "workspace/" + safe_name(raw)
                    check("声明文件存在" if category != "deleted" else "删除文件不在快照中",
                          category != "deleted", name in files, name)
                    if category != "deleted":
                        listed.add(name)
                except ValueError as exc:
                    check("声明路径安全", True, str(exc), "manifest.json")
        for name in sorted(n for n in files if n.startswith("workspace/") and n not in listed):
            check("workspace 文件已声明", True, False, name, "警告")
        casts = manifest.get("cast_files")
        if isinstance(casts, list):
            listed_casts = set()
            for entry in casts:
                if not isinstance(entry, dict):
                    check("录像清单条目", "object", entry, "manifest.json")
                    continue
                try:
                    name = "casts/" + safe_name(entry.get("name"))
                except ValueError as exc:
                    check("录像路径安全", True, str(exc), "manifest.json")
                    continue
                listed_casts.add(name)
                check("录像存在", True, name in files, name)
                if name in files:
                    check("录像字节数", entry.get("bytes"), len(files[name]), name)
            check("录像清单与实际文件一致", sorted(listed_casts), sorted(n for n in files if n.startswith("casts/") and n.endswith(".cast")), "manifest.json / casts")
        else:
            check("cast_files 类型", "list", type(casts).__name__, "manifest.json")
    sessions = parse("ai/sessions.json", list)
    for name, data in sorted(files.items()):
        if not (name.startswith("casts/") and name.endswith(".cast")):
            continue
        try:
            lines = data.decode("utf-8-sig").splitlines()
            header = json.loads(lines[0])
            if not isinstance(header, dict) or header.get("version") != 2:
                raise ValueError("需要 asciinema v2 对象头部")
            check("录像头部可解析", True, True, name + ":1")
            owner = header.get("owner")
            if owner is not None:
                check("录像学生账号一致", student_id, str(owner), name + ":1")
                if str(owner) != student_id:
                    blocked = True
            previous_time = -1
            for line_no, line in enumerate(lines[1:], 2):
                try:
                    event = json.loads(line)
                    if (not isinstance(event, list) or len(event) != 3
                            or type(event[0]) not in (int, float) or not math.isfinite(event[0])
                            or event[0] < 0 or not isinstance(event[1], str) or not isinstance(event[2], str)):
                        raise ValueError("非法录像事件结构")
                    if event[0] < previous_time:
                        check("录像偏移非递减", True, False, f"{name}:{line_no}", "警告")
                    previous_time = event[0]
                except (ValueError, TypeError) as exc:
                    check("录像事件可解析", True, str(exc), f"{name}:{line_no}")
        except (UnicodeError, ValueError, IndexError) as exc:
            check("录像头部可解析", True, str(exc), name)
    message_counts = {}
    for name, data in sorted(files.items()):
        if not name.endswith(".jsonl"):
            continue
        count = 0
        try:
            lines = data.decode("utf-8-sig").splitlines()
        except UnicodeError as exc:
            check("JSONL 编码", "UTF-8", str(exc), name)
            continue
        for line_no, line in enumerate(lines, 1):
            if not line.strip():
                continue
            try:
                row = json.loads(line)
                if not isinstance(row, dict):
                    raise ValueError("记录不是对象")
                count += 1
            except ValueError as exc:
                check("JSONL 记录可解析", True, str(exc), f"{name}:{line_no}")
        check("JSONL 有效记录数", count, count, name)
        if name.startswith("ai/"):
            message_counts[name] = count
    if sessions is not None:
        declared = []
        for s in sessions:
            if not isinstance(s, dict):
                check("会话索引条目", "object", s, "ai/sessions.json")
                continue
            try:
                sid = safe_name(s.get("session_id"))
                if "/" in sid:
                    raise ValueError("会话 ID 含路径分隔符")
            except ValueError as exc:
                check("会话 ID", "有效标识", str(exc), "ai/sessions.json")
                continue
            name = f"ai/{sid}.jsonl"
            declared.append(name)
            check("会话文件存在", True, name in files, name)
            check("会话消息数量", s.get("messages"), message_counts.get(name), name)
        check("会话 ID 无重复", len(set(declared)), len(declared), "ai/sessions.json")
        check("会话索引与实际文件一致", sorted(set(declared)), sorted(message_counts), "ai/sessions.json / ai")
        if manifest is not None:
            check("AI 会话总数", manifest.get("ai_sessions"), len(sessions), "manifest.json / ai/sessions.json")
    if manifest is not None:
        check("AI 消息总数", manifest.get("ai_messages"), sum(message_counts.values()), "manifest.json / ai/*.jsonl")
    return manifest or {}, checks, blocked


def base_header(title, identity):
    return [f"# {title}", "", f"- 学号：{cell(identity['student_id'])}", f"- 姓名：{cell(identity['name'])}",
            f"- 提交 ID：{cell(identity.get('submission_id') or '未知')}", f"- 来源压缩包：{cell(identity['archive'])}", ""]


def ensure_plain(path):
    if path.is_symlink() or (hasattr(path, "is_junction") and path.is_junction()):
        raise ValueError(f"拒绝输出链接目录或文件：{path}")


def write_text(path, text):
    ensure_plain(path)
    path.write_text(text, encoding="utf-8")


def status_of(checks):
    return "失败" if any(c["status"] == "失败" for c in checks) else "警告" if any(c["status"] == "警告" for c in checks) else "通过"


def load_marker(path):
    value = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(value, dict) or value.get("owner") != OWNER:
        raise ValueError("处理记录归属或格式无效")
    row = value.get("summary")
    if (not isinstance(row, dict) or row.get("student") != path.parent.name
            or not all(isinstance(row.get(k), str) for k in ("status", "action"))
            or not all(type(row.get(k)) is int and row[k] >= 0 for k in ("py_files", "sessions", "messages", "recordings"))
            or not isinstance(row.get("issues"), list) or not all(isinstance(x, str) for x in row["issues"])):
        raise ValueError("处理记录汇总字段无效")
    return value


def process_student(archive, output, regenerate=False):
    stem = archive.name[:-7]
    safe_name(stem)
    sid, name = stem.split("-", 1)
    if not sid.isdigit() or not name:
        raise ValueError("文件名应为 学生学号-学生姓名.tar.gz")
    dest = output / stem
    ensure_plain(dest)
    marker = dest / "处理记录.json"
    if dest.exists():
        if not regenerate:
            if marker.is_file() and not marker.is_symlink():
                try:
                    previous = load_marker(marker)
                    return {**previous["summary"], "action": "跳过已有输出"}
                except (OSError, ValueError):
                    pass
            return {"student": stem, "status": "未处理", "action": "跳过已有输出", "issues": ["已有输出目录，未覆盖"], "py_files": 0, "sessions": 0, "messages": 0, "recordings": 0}
        if not marker.is_file() or marker.is_symlink():
            raise ValueError("重新生成仅允许覆盖本工具创建的目录")
        previous = load_marker(marker)
        if previous.get("owner") != OWNER or previous.get("archive_sha256") != digest(archive.read_bytes()):
            raise ValueError("输出归属或压缩包内容已变化，请使用新输出目录")
    dest.mkdir(parents=True, exist_ok=True)
    identity = dict(student_id=sid, name=name, archive=archive.name, submission_id="未知")
    files, dirs, checks, blocked = {}, [], [], False
    try:
        files, dirs = read_archive(archive)
        manifest, checks, blocked = validate(files, sid)
        identity["submission_id"] = manifest.get("submission_id", "未知")
    except (OSError, ValueError, tarfile.TarError, EOFError) as exc:
        blocked = True
        checks.append(dict(status="失败", item="压缩包读取与路径安全", expected="安全且可读", actual=str(exc), source=archive.name))
    hashes = []
    if not blocked:
        raw = dest / "原始提交"
        ensure_plain(raw)
        raw.mkdir(exist_ok=True)
        for folder in sorted(dirs, key=lambda n: len(PurePosixPath(n).parts)):
            target = raw / folder
            for p in [target, *target.parents]:
                if p == dest:
                    break
                ensure_plain(p)
            target.mkdir(parents=True, exist_ok=True)
        for rel, data in sorted(files.items()):
            target = raw / rel
            for p in [target, *target.parents]:
                if p == dest:
                    break
                ensure_plain(p)
            target.parent.mkdir(parents=True, exist_ok=True)
            if target.exists() and target.read_bytes() != data:
                raise ValueError(f"原始提交副本已改变，拒绝覆盖：{rel}")
            if not target.exists():
                target.write_bytes(data)
            actual = digest(target.read_bytes())
            if actual != digest(data):
                raise OSError(f"提取校验失败：{rel}")
            hashes.append({"path": rel, "bytes": len(data), "sha256": actual})
        write_text(dest / "SHA256清单.json", json.dumps({"note": "提取一致性记录，不是源头真实性证明", "files": hashes}, ensure_ascii=False, indent=2) + "\n")
        checks.append(dict(status="通过", item="提取前后 SHA-256 一致", expected=len(files), actual=len(hashes), source="SHA256清单.json"))
    stats = {}
    from ai_experience_ai import build_ai_report
    from ai_experience_terminal import build_terminal_report
    for filename, builder in (("AI对话记录.md", build_ai_report), ("终端时间线.md", build_terminal_report)):
        if blocked:
            text = "\n".join(base_header(filename[:-3], identity) + ["该学生处理已停止，原因见 [完整性校验](完整性校验.md)。"])
            details = {}
        else:
            try:
                text, details = builder(files, identity)
                for issue in details.get("issues", []):
                    checks.append(dict(status="警告", item="过程恢复", expected="记录完整且可定位", actual=issue, source=filename))
            except Exception as exc:
                details = {}
                text = "\n".join(base_header(filename[:-3], identity) + ["处理失败：" + cell(str(exc))])
                checks.append(dict(status="失败", item="报告生成", expected="成功", actual=str(exc), source=filename))
        stats.update({k: v for k, v in details.items() if k != "issues"})
        write_text(dest / filename, text)
    py_files = sorted(n for n in files if n.startswith("workspace/") and n.lower().endswith(".py"))
    other = sorted(n for n in files if n.startswith("workspace/") and not n.startswith("workspace/.labtracker/") and n not in py_files)
    md = base_header("完整性校验", identity) + [f"- 校验状态：**{status_of(checks)}**", f"- 处理状态：{'已停止' if blocked else '已处理可用内容'}", "",
        "本报告校验提交清单与包内数据的一致性。manifest 未提供原始文件哈希，无法证明源头内容未被修改。增量提交不含完整官方模板，通过校验不代表实验环境完整。", "",
        "学生文件原样保存，未执行、导入、修复或测试。重新运行结果不在本批处理中产生。", "", "## 校验明细", "",
        "| 状态 | 检查项 | 预期 | 实际 | 来源 |", "|---|---|---|---|---|"]
    md += ["| " + " | ".join(cell(c[k]) for k in ("status", "item", "expected", "actual", "source")) + " |" for c in checks]
    md += ["", "## 原始作业", ""]
    if not py_files:
        md.append("未发现 `.py` 文件；这不等于未提交作业。")
    for rel in py_files + other:
        label = "Python 文件" if rel in py_files else "其他提交文件（异常扩展名可能是代码，未改名或执行）"
        md.append(f"- {label}：" + (cell(rel) if blocked else f"[{cell(rel)}]({quote('原始提交/' + rel, safe='/')})"))
    if not blocked:
        md += ["", "[SHA-256 清单](SHA256清单.json)：记录本次提取前后的一致性，可用于后续追踪。"]
    write_text(dest / "完整性校验.md", "\n".join(md) + "\n")
    summary = dict(student=stem, status=status_of(checks), action="停止" if blocked else "已处理", py_files=len(py_files),
                   sessions=stats.get("sessions", 0), messages=stats.get("messages", 0), recordings=stats.get("recordings", 0),
                   issues=[f"{c['item']}：{c['actual']}" for c in checks if c["status"] != "通过"])
    write_text(marker, json.dumps({"owner": OWNER, "archive_sha256": digest(archive.read_bytes()), "summary": summary}, ensure_ascii=False, indent=2) + "\n")
    return summary


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", nargs="?", type=Path, default=DEFAULT_INPUT)
    parser.add_argument("--output", "-o", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--student", help="按学号精确筛选")
    parser.add_argument("--regenerate", action="store_true", help="覆盖本工具已有报告；原始提交须保持一致")
    args = parser.parse_args(argv)
    src, out = args.input.resolve(), args.output.resolve()
    if not src.is_dir():
        parser.error("输入目录不存在")
    if src == out or src in out.parents or out in src.parents:
        parser.error("输入输出目录不得重叠")
    for p in [args.output.absolute(), *args.output.absolute().parents]:
        ensure_plain(p)
    out.mkdir(parents=True, exist_ok=True)
    results = []
    for archive in sorted(src.glob("*.tar.gz")):
        if args.student and archive.name.split("-", 1)[0] != args.student:
            continue
        try:
            result = process_student(archive, out, args.regenerate)
        except Exception as exc:
            result = dict(student=archive.name[:-7], status="处理失败", action="未覆盖", issues=[str(exc)], py_files=0, sessions=0, messages=0, recordings=0)
        results.append(result)
        print(f"{result['student']}：{result['status']} / {result['action']}")
    # Include earlier processed students when a filtered run refreshes the batch index.
    selected = {r['student'] for r in results}
    for marker in sorted(out.glob("*/处理记录.json")):
        if marker.parent.name in selected or marker.is_symlink() or marker.parent.is_symlink():
            continue
        try:
            previous = load_marker(marker)
            results.append({**previous["summary"], "action": "已有结果"})
        except (OSError, ValueError) as exc:
            results.append(dict(student=marker.parent.name, status="未处理", action="历史记录无效", issues=[str(exc)], py_files=0, sessions=0, messages=0, recordings=0))
    md = ["# 批处理汇总", "", "<!-- ai-experience-batch-v1 -->", "", "保留原始提交，分别恢复 AI 对话顺序与终端时间线；未运行学生代码，不生成测试结果，不进行评分。", "",
          "消息数按可解析的 JSONL 消息记录统计，不等于学生提问次数。详情及证据定位见各学生报告。", "",
          "| 学生 | 校验状态 | 本次处理 | .py 文件 | AI 会话 | AI 消息 | 终端录像 | 报告 | 异常说明 |", "|---|---|---|---:|---:|---:|---:|---|---|"]
    for r in sorted(results, key=lambda x: x["student"]):
        folder = quote(r["student"], safe="")
        links = " / ".join(f"[{label}]({folder}/{quote(file)})" for label, file in (("校验", "完整性校验.md"), ("AI", "AI对话记录.md"), ("终端", "终端时间线.md")) if (out / r["student"] / file).is_file())
        md.append("| " + " | ".join([*[cell(r[k]) for k in ("student", "status", "action", "py_files", "sessions", "messages", "recordings")], links, cell("；".join(r["issues"]) or "无")]) + " |")
    summary_path = out / "批处理汇总.md"
    if summary_path.exists() and "<!-- ai-experience-batch-v1 -->" not in summary_path.read_text(encoding="utf-8"):
        raise ValueError("汇总报告不是本工具产物，拒绝覆盖")
    write_text(summary_path, "\n".join(md) + "\n")
    return 1 if any(r["status"] in ("失败", "处理失败") for r in results) else 0


if __name__ == "__main__":
    raise SystemExit(main())
