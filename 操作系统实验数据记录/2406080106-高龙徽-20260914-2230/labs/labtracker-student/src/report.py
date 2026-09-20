#!/usr/bin/env python3
"""labtracker 过程摘要生成器（按登记生成）

用法: report.py [--data 登记目录] [-o 摘要.md] [--json]
读该登记的 events.jsonl(+镜像)、心跳、录像目录，产出《摘要-过程报告.md》。
数据严格限定在本次登记目录内，不读取全局历史日志。
"""
import argparse
import datetime
import glob
import gzip
import hashlib
import json
import os
import re

HOME = os.path.expanduser('~')
LABT_HOME = os.path.join(HOME, '.labtracker')

IDLE_ACTIVE_MS = 120000
CMD_GAP_CAP_S = 900
GENESIS = '0' * 64


def default_data_dir():
    """未显式指定时取当前登记目录；没有登记则回退到旧版全局目录（只读）。"""
    state = os.path.join(LABT_HOME, 'state', 'current.state')
    try:
        with open(state, encoding='utf-8') as f:
            for line in f:
                if line.startswith('run_dir='):
                    d = line.strip().split('=', 1)[1]
                    if d and os.path.isdir(d):
                        return d
    except OSError:
        pass
    return os.path.join(LABT_HOME, 'data')


def load_events(data_dir):
    """返回 (events, raws, bad)。raws 与行号一一对应，坏行不影响其它行对齐。"""
    events, raws, bad = [], [], 0
    path = os.path.join(data_dir, 'events.jsonl')
    if not os.path.exists(path):
        return events, raws, bad
    with open(path, encoding='utf-8', errors='replace') as f:
        for line in f:
            line = line.rstrip('\n')
            if not line.strip():
                continue
            raws.append(line)
            try:
                events.append(json.loads(line))
            except json.JSONDecodeError:
                events.append(None)
                bad += 1
    return events, raws, bad


def chain_verify(events, raws):
    """按 log-event.sh 的构造方式重算哈希链。

    以原始行为准逐行校验：坏行只让该行断链，不会让后续行整体错位。
    """
    broken = []
    prev = GENESIS
    for i, (ev, raw) in enumerate(zip(events, raws), 1):
        if ev is None:
            broken.append(i)
            continue
        h = ev.get('h')
        pv = ev.get('prev')
        if h is None or pv is None or pv != prev:
            broken.append(i)
            if h is None:
                continue
        cut = raw.rfind(',"h":"')
        if cut <= 0:
            broken.append(i)
            continue
        payload = raw[:cut]
        calc = hashlib.sha256((prev + '\n' + payload).encode('utf-8')).hexdigest()
        if calc != h:
            broken.append(i)
        prev = h
    return broken, len(raws)


def mirror_count(data_dir):
    p = os.path.join(data_dir, 'events.mirror.jsonl')
    if not os.path.exists(p):
        return -1
    return sum(1 for _ in open(p, encoding='utf-8', errors='replace'))


def timing_duration(data_dir, rec_base):
    for cand in (os.path.join(data_dir, 'term', rec_base + '.tim'),
                 os.path.join(data_dir, 'term', rec_base + '.tim.gz')):
        if os.path.exists(cand):
            op = gzip.open if cand.endswith('.gz') else open
            try:
                with op(cand, 'rt', errors='replace') as f:
                    return sum(float(l.split()[0]) for l in f if l.split())
            except (OSError, ValueError):
                return None
    return None


def fmt_dur(sec):
    sec = int(sec)
    h, m, s = sec // 3600, sec % 3600 // 60, sec % 60
    if h:
        return f'{h}小时{m:02d}分'
    if m:
        return f'{m}分{s:02d}秒'
    return f'{s}秒'


def read_kv(path, key):
    try:
        with open(path, encoding='utf-8') as f:
            for line in f:
                if line.startswith(key + '='):
                    return line.strip().split('=', 1)[1]
    except OSError:
        pass
    return ''


def labs_root(data_dir):
    root = read_kv(os.path.join(data_dir, 'run.conf'), 'labs_root')
    return root or read_kv(os.path.join(LABT_HOME, 'config'), 'LABS_ROOT')


def lab_of(cwd, root):
    if root and cwd.startswith(root):
        rest = cwd[len(root):].lstrip('/')
        m = re.match(r'(lab\d+)', rest)
        if m:
            return m.group(1)
        return '其他目录'
    return None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--data', default='')
    ap.add_argument('-o', '--output')
    ap.add_argument('--json', action='store_true')
    args = ap.parse_args()

    data_dir = args.data or default_data_dir()
    events_all, raws, bad = load_events(data_dir)
    events = [e for e in events_all if e is not None]
    root = labs_root(data_dir)

    sid = read_kv(os.path.join(data_dir, 'identity'), 'sid')
    name = read_kv(os.path.join(data_dir, 'identity'), 'name')
    run_id = os.path.basename(os.path.normpath(data_dir))
    stopped = read_kv(os.path.join(data_dir, 'stopped_at'), 'at')

    # ---- 活跃时长（心跳）----
    hbs = [e for e in events if e.get('type') == 'hb']
    active_sec = 0.0
    day_active = {}
    for a, b in zip(hbs, hbs[1:]):
        d = b['epoch'] - a['epoch']
        if d <= 0 or d > 300:
            d = 60
        idle = b.get('idle_ms', -1)
        changed = b.get('changed', 0)
        # idle_ms = -1 表示空闲时间不可知，不能当作"活跃"
        idle_active = isinstance(idle, (int, float)) and 0 <= idle < IDLE_ACTIVE_MS
        if idle_active or changed:
            active_sec += d
            day = datetime.datetime.fromtimestamp(b['epoch']).strftime('%Y-%m-%d')
            day_active[day] = day_active.get(day, 0) + d

    # ---- 命令统计 ----
    cmds = [e for e in events if e.get('type') == 'cmd']
    lab_sec = {}
    last_t = {}
    for c in cmds:
        lab = lab_of(c.get('cwd', ''), root)
        if not lab:
            continue
        t = c['epoch']
        if lab in last_t and t - last_t[lab] <= CMD_GAP_CAP_S:
            lab_sec[lab] = lab_sec.get(lab, 0) + (t - last_t[lab])
        last_t[lab] = t

    def cmd_is(ev, head):
        c = ev.get('cmd', '').strip()
        return c == head or c.startswith(head + ' ')

    make_ok = sum(1 for c in cmds if cmd_is(c, 'make') and c.get('rc') == 0)
    make_fail = sum(1 for c in cmds if cmd_is(c, 'make') and c.get('rc') not in (0, None))
    qemu_n = sum(1 for c in cmds if 'qemu' in c.get('cmd', ''))
    claude_n = sum(1 for c in cmds if cmd_is(c, 'claude'))

    sessions = [e for e in events if e.get('type') == 'session_start']
    terms = {}
    for s in sessions:
        t = s.get('term', '?')
        terms[t] = terms.get(t, 0) + 1

    # ---- 录像清单 ----
    recs = []
    for p in sorted(glob.glob(os.path.join(data_dir, 'term', '*.out')) +
                    glob.glob(os.path.join(data_dir, 'term', '*.out.gz'))):
        base = os.path.basename(p)
        base = base[:-3] if base.endswith('.gz') else base
        rb = base[:-4]
        recs.append((rb, os.path.getsize(p), timing_duration(data_dir, rb)))

    # ---- 完整性 ----
    broken, total = chain_verify(events_all, raws)
    mir = mirror_count(data_dir)
    issues = []
    if bad:
        issues.append(f'events.jsonl 有 {bad} 行无法解析')
    if broken:
        issues.append(f'哈希链在第 {broken[:5]}{"..." if len(broken) > 5 else ""} 行断裂'
                      f'（共{len(broken)}处）——疑似被修改或删除')
    if mir >= 0 and mir != total:
        issues.append(f'镜像({mir}行)与主日志({total}行)行数不一致——疑似删除记录')
    rec_event_count = sum(1 for s in sessions if s.get('rec') and s.get('rec') != 'none')
    if recs and rec_event_count != len(recs):
        issues.append(f'会话事件{rec_event_count}条 vs 录像{len(recs)}个 不对应——疑似录像被删')
    if not issues:
        issues.append('未发现异常')

    period = (events[0]['ts'], events[-1]['ts']) if events else ('无', '无')

    L = []
    L.append('# 实验过程摘要报告\n')
    L.append(f'- 学生：**{name}**（学号 {sid}）')
    L.append(f'- 登记号：{run_id}')
    L.append(f'- 统计区间：{period[0]} ~ {period[1]}')
    if stopped:
        L.append(f'- 采集停止时间：{stopped}')
    L.append(f'- 活跃实操时长：**{fmt_dur(active_sec)}**（键鼠活跃或实验目录有改动的时间）')
    L.append(f'- 活跃天数：{len(day_active)} 天\n')
    L.append('## 每日活跃时长')
    if day_active:
        for d in sorted(day_active):
            L.append(f'- {d}：{fmt_dur(day_active[d])}')
    else:
        L.append('- （无心跳记录）')
    L.append('\n## 各实验投入（按命令时间间隔估算）')
    if lab_sec:
        for lab in sorted(lab_sec):
            L.append(f'- {lab}：{fmt_dur(lab_sec[lab])}')
    else:
        L.append('- （未记录到实验目录内命令）')
    L.append('\n## 操作统计')
    L.append(f'- 终端会话数：{len(sessions)}（{", ".join(f"{k}×{v}" for k, v in sorted(terms.items())) or "无"}）')
    L.append(f'- 命令条数：{len(cmds)}')
    L.append(f'- make 编译：成功 {make_ok} 次，失败 {make_fail} 次')
    L.append(f'- QEMU 运行：{qemu_n} 次；Claude Code 启动：{claude_n} 次\n')
    L.append('## 终端录像清单')
    if recs:
        tot = sum(d or 0 for _, _, d in recs)
        L.append(f'共 {len(recs)} 段，总时长约 {fmt_dur(tot)}')
        for rb, size, dur in recs:
            ds = fmt_dur(dur) if dur is not None else '?'
            L.append(f'- {rb}：{ds}，{size}B')
    else:
        L.append('（无录像文件）')
    L.append('\n## 日志完整性校验')
    for i in issues:
        L.append(f'- {i}')
    md = '\n'.join(L) + '\n'

    if args.output:
        with open(args.output, 'w', encoding='utf-8') as f:
            f.write(md)
    else:
        print(md)

    if args.json:
        print(json.dumps({
            'sid': sid, 'name': name, 'run': run_id,
            'active_sec': int(active_sec), 'days': len(day_active), 'cmds': len(cmds),
            'make_ok': make_ok, 'make_fail': make_fail,
            'qemu': qemu_n, 'claude': claude_n,
            'sessions': len(sessions), 'recordings': len(recs),
            'chain_broken': len(broken), 'issues': issues,
        }, ensure_ascii=False))


if __name__ == '__main__':
    main()
