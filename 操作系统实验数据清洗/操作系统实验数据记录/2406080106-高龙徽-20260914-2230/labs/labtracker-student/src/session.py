#!/usr/bin/env python3
"""labtracker 登记生命周期与采集门禁

状态机：idle -> recording -> freezing -> pending_upload -> finished

设计要点：
- 唯一权威状态存在 state/current.state（行式 key=value，原子替换），bash 与 Python 都能读。
- 所有采集写入（终端输出/timing、命令事件、心跳）都必须持有 state/lock 这一把
  flock，并在锁内重新核对 run_id 与 state=recording。提交在同一把锁内把状态改为
  freezing，因此屏障之后不可能再有新的采集数据落盘。
- 每次登记有独立目录 data/runs/<run_id>/，身份在 begin 时快照，不随全局 id.conf 变化。
"""
import argparse
import contextlib
import datetime
import fcntl
import json
import os
import re
import socket
import sys
import time

HOME = os.path.expanduser('~')
LABT_HOME = os.path.join(HOME, '.labtracker')
STATE_DIR = os.path.join(LABT_HOME, 'state')
STATE_FILE = os.path.join(STATE_DIR, 'current.state')
LOCK_FILE = os.path.join(STATE_DIR, 'lock')
RUNS_DIR = os.path.join(LABT_HOME, 'data', 'runs')

STATE_KEYS = ('run_id', 'state', 'sid', 'name', 'course', 'labs_root', 'run_dir',
              'boot_id', 'started_at', 'capture_stopped_at', 'finished_at', 'error')

SID_RE = re.compile(r'^[0-9]{6,15}$')


# ---------------------------------------------------------------- 基础工具

def boot_id():
    try:
        with open('/proc/sys/kernel/random/boot_id') as f:
            return f.read().strip()
    except OSError:
        return ''


def now_iso():
    return datetime.datetime.now().strftime('%Y-%m-%dT%H:%M:%S%z')


def new_run_id():
    return datetime.datetime.now().strftime('%Y%m%dT%H%M%S') + '-' + \
        format(int.from_bytes(os.urandom(2), 'big'), '04d')


def read_state():
    st = {k: '' for k in STATE_KEYS}
    st['state'] = 'idle'
    try:
        with open(STATE_FILE, encoding='utf-8') as f:
            for line in f:
                line = line.rstrip('\n')
                if '=' in line:
                    k, v = line.split('=', 1)
                    if k in STATE_KEYS:
                        st[k] = v
    except OSError:
        pass
    return st


def _write_state_locked(st):
    os.makedirs(STATE_DIR, exist_ok=True)
    tmp = STATE_FILE + '.tmp.%d' % os.getpid()
    with open(tmp, 'w', encoding='utf-8') as f:
        for k in STATE_KEYS:
            f.write('%s=%s\n' % (k, st.get(k, '')))
    os.chmod(tmp, 0o600)
    os.replace(tmp, STATE_FILE)


@contextlib.contextmanager
def locked(timeout=10.0):
    """取得生命周期/采集写入锁。锁内只做状态读写，禁止网络与交互。"""
    os.makedirs(STATE_DIR, exist_ok=True)
    fd = os.open(LOCK_FILE, os.O_CREAT | os.O_RDWR, 0o600)
    deadline = time.monotonic() + timeout
    try:
        while True:
            try:
                fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
                break
            except OSError:
                if time.monotonic() > deadline:
                    raise TimeoutError('等待采集锁超时')
                time.sleep(0.02)
        yield
    finally:
        try:
            fcntl.flock(fd, fcntl.LOCK_UN)
        except OSError:
            pass
        os.close(fd)


class Gate:
    """采集写入闸门：每次写入前在锁内重新核对登记与状态。"""

    def __init__(self, run_id):
        self.run_id = run_id
        os.makedirs(STATE_DIR, exist_ok=True)
        self.fd = os.open(LOCK_FILE, os.O_CREAT | os.O_RDWR, 0o600)

    def write(self, fn, timeout=2.0):
        """持锁执行 fn()；若登记已冻结/不匹配/超时则返回 False 且不执行。"""
        deadline = time.monotonic() + timeout
        while True:
            try:
                fcntl.flock(self.fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
                break
            except OSError:
                if time.monotonic() > deadline:
                    return False
                time.sleep(0.01)
        try:
            st = read_state()
            if st.get('state') != 'recording' or st.get('run_id') != self.run_id:
                return False
            fn()
            return True
        finally:
            try:
                fcntl.flock(self.fd, fcntl.LOCK_UN)
            except OSError:
                pass

    def close(self):
        try:
            os.close(self.fd)
        except OSError:
            pass


# ---------------------------------------------------------------- 基线收集

def _proc_field(pid, idx):
    """读取 /proc/<pid>/stat 中 comm 之后的第 idx 个字段（idx 从 0 计）。"""
    try:
        with open('/proc/%d/stat' % pid, encoding='utf-8', errors='replace') as f:
            raw = f.read()
    except OSError:
        return None
    cut = raw.rfind(')')
    if cut < 0:
        return None
    parts = raw[cut + 2:].split()
    if idx >= len(parts):
        return None
    return parts[idx]


def _proc_starttime(pid):
    # stat 第 22 项 = comm 之后第 19 项
    return _proc_field(pid, 19)


def _proc_session(pid):
    # stat 第 6 项 = comm 之后第 3 项
    return _proc_field(pid, 3)


def _proc_tty(pid):
    try:
        tgt = os.readlink('/proc/%d/fd/0' % pid)
    except OSError:
        return ''
    return tgt if tgt.startswith('/dev/pts/') else ''


def _mangle(tty):
    return tty.strip('/').replace('/', '_') or 'none'


def collect_baseline(run_dir):
    """登记开始时已存在的交互 Bash 终端：本轮不补录。

    记录 (tty, 会话ID)。同 TTY 上后来 exec bash 仍属同一会话，依旧排除；
    TTY 设备号被新终端复用时会话ID不同，可以正常接入。
    """
    pretty = os.path.join(run_dir, 'capture', 'pretty')
    os.makedirs(pretty, exist_ok=True)
    bid = boot_id()
    seen = set()
    try:
        pids = [int(p) for p in os.listdir('/proc') if p.isdigit()]
    except OSError:
        return 0
    for pid in pids:
        try:
            if os.stat('/proc/%d' % pid).st_uid != os.getuid():
                continue
        except OSError:
            continue
        try:
            with open('/proc/%d/comm' % pid, encoding='utf-8', errors='replace') as f:
                comm = f.read().strip()
        except OSError:
            continue
        if comm != 'bash':
            continue
        tty = _proc_tty(pid)
        if not tty:
            continue
        sess = _proc_session(pid) or ''
        key = (tty, sess)
        if key in seen:
            continue
        seen.add(key)
        with open(os.path.join(pretty, _mangle(tty)), 'w', encoding='utf-8') as f:
            f.write('%s|%s|%s\n' % (tty, sess, bid))
    return len(seen)


def tty_is_pretty(run_dir, tty, session):
    """该终端是否是登记前就存在的旧终端。"""
    path = os.path.join(run_dir, 'capture', 'pretty', _mangle(tty))
    try:
        with open(path, encoding='utf-8') as f:
            rec_tty, rec_sess, rec_boot = f.read().strip().split('|')
    except (OSError, ValueError):
        return False
    if rec_boot != boot_id():
        return False          # 重启后旧终端已不存在
    return rec_tty == tty and rec_sess == session


# ---------------------------------------------------------------- 登记操作

def _run_paths(run_dir):
    return {
        'term': os.path.join(run_dir, 'term'),
        'proxies': os.path.join(run_dir, 'capture', 'proxies'),
        'submit': os.path.join(run_dir, 'submit'),
    }


def cmd_begin(args):
    if not SID_RE.match(args.sid or ''):
        print('学号须为 6~15 位数字', file=sys.stderr)
        return 2
    name = (args.name or '').strip()
    if not (2 <= len(name) <= 30):
        print('姓名须为 2~30 个字', file=sys.stderr)
        return 2
    labs = os.path.abspath(os.path.expanduser(args.labs or ''))
    if not os.path.isdir(labs):
        print('实验目录不存在: %s' % labs, file=sys.stderr)
        return 2

    with locked():
        st = read_state()
        if st.get('state') == 'recording':
            print('已有进行中的登记：%s（%s）' % (st.get('run_id'), st.get('started_at')),
                  file=sys.stderr)
            return 3
        if st.get('state') in ('freezing', 'pending_upload'):
            print('上一次登记尚未完成提交，请先运行《提交实验》完成上传。', file=sys.stderr)
            return 4

        run_id = new_run_id()
        run_dir = os.path.join(RUNS_DIR, run_id)
        paths = _run_paths(run_dir)
        for d in (run_dir, paths['term'], paths['proxies'], paths['submit']):
            os.makedirs(d, exist_ok=True)
        with open(os.path.join(run_dir, 'identity'), 'w', encoding='utf-8') as f:
            f.write('sid=%s\nname=%s\nbound_at=%s\n' % (args.sid, name, now_iso()))
        with open(os.path.join(run_dir, 'run.conf'), 'w', encoding='utf-8') as f:
            f.write('labs_root=%s\ncourse=%s\n' % (labs, args.course or ''))
        collect_baseline(run_dir)

        st.update({
            'run_id': run_id, 'state': 'recording', 'sid': args.sid, 'name': name,
            'course': args.course or '', 'labs_root': labs, 'run_dir': run_dir,
            'boot_id': boot_id(), 'started_at': now_iso(),
            'capture_stopped_at': '', 'finished_at': '', 'error': '',
        })
        _write_state_locked(st)
    print(run_id)
    return 0


def cmd_freeze(args):
    with locked():
        st = read_state()
        if st.get('state') == 'recording':
            st['state'] = 'freezing'
            st['capture_stopped_at'] = now_iso()
            _write_state_locked(st)
            run_dir = st.get('run_dir') or ''
            if run_dir and os.path.isdir(run_dir):
                try:
                    with open(os.path.join(run_dir, 'stopped_at'), 'w',
                              encoding='utf-8') as f:
                        f.write('at=%s\n' % st['capture_stopped_at'])
                except OSError:
                    pass
            print('frozen')
        elif st.get('state') in ('freezing', 'pending_upload'):
            print('already')
        elif st.get('state') == 'finished':
            print('finished')
        else:
            print('no-active-run', file=sys.stderr)
            return 3
    return 0


def cmd_pending(args):
    with locked():
        st = read_state()
        if st.get('state') not in ('freezing', 'pending_upload'):
            print('当前状态不是待提交：%s' % st.get('state'), file=sys.stderr)
            return 3
        st['state'] = 'pending_upload'
        st['error'] = (args.error or '')[:500]
        _write_state_locked(st)
    return 0


def cmd_finish(args):
    with locked():
        st = read_state()
        if st.get('state') not in ('freezing', 'pending_upload'):
            print('当前状态无法结束登记：%s' % st.get('state'), file=sys.stderr)
            return 3
        st['state'] = 'finished'
        st['finished_at'] = now_iso()
        st['error'] = ''
        _write_state_locked(st)
    return 0


def cmd_abort(args):
    """放弃当前登记（只改状态，保留已采集数据以便排查）。"""
    with locked():
        st = read_state()
        if st.get('state') == 'idle':
            return 0
        st['state'] = 'finished'
        st['finished_at'] = now_iso()
        st['error'] = 'aborted'
        _write_state_locked(st)
    return 0


def _proc_alive(pid, starttime):
    """PID 存活且启动时间一致（防止 PID 复用误判）。"""
    if not pid or not os.path.exists('/proc/%d' % pid):
        return False
    if starttime:
        return _proc_starttime(pid) == str(starttime)
    return True


def cmd_stop_proxies(args):
    """通知本次登记的所有终端代理停止写日志；代理继续转发，学生终端不受影响。

    屏障已经由 freeze 建立，这里只做落盘确认，失败也要如实报告。
    """
    proxies = os.path.join(args.run_dir, 'capture', 'proxies')
    out = {'total': 0, 'acked': 0, 'failed': [], 'growing': [], 'dead': []}
    entries = []
    if os.path.isdir(proxies):
        for fn in sorted(os.listdir(proxies)):
            if not fn.endswith('.json'):
                continue
            try:
                with open(os.path.join(proxies, fn), encoding='utf-8') as f:
                    rec = json.load(f)
            except (OSError, ValueError):
                continue
            entries.append(rec)
    out['total'] = len(entries)

    for rec in entries:
        pid = rec.get('pid')
        base = rec.get('base') or ''
        if not _proc_alive(pid, rec.get('starttime')):
            out['dead'].append({'pid': pid, 'base': base})
            continue
        acked = False
        sock = rec.get('sock') or ''
        if sock and os.path.exists(sock):
            try:
                c = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
                c.settimeout(5.0)
                c.connect(sock)
                c.sendall(json.dumps({'cmd': 'stop_log'}).encode() + b'\n')
                data = c.recv(4096)
                c.close()
                reply = json.loads(data.decode('utf-8', 'replace').strip() or '{}')
                acked = bool(reply.get('ok'))
            except (OSError, ValueError):
                acked = False
        if acked:
            out['acked'] += 1
        else:
            out['failed'].append({'pid': pid, 'base': base})

    # 落盘确认：输出文件在短时间内不应再增长
    time.sleep(0.3)
    for rec in entries:
        base = rec.get('base') or ''
        for ext in ('.out', '.tim'):
            p = os.path.join(args.run_dir, 'term', base + ext)
            try:
                s1 = os.path.getsize(p)
                time.sleep(0.4)
                s2 = os.path.getsize(p)
                if s2 != s1:
                    out['growing'].append({'base': base, 'ext': ext})
                    break
            except OSError:
                pass
    print(json.dumps(out, ensure_ascii=False))
    return 0


def cmd_verify_upload(args):
    """严格校验上传响应：HTTP 2xx 由调用方给出，这里校验 JSON ok 与 sha256。"""
    body = sys.stdin.read()
    try:
        resp = json.loads(body)
    except ValueError:
        print('响应不是合法 JSON', file=sys.stderr)
        return 1
    if resp.get('ok') is not True:
        print('响应 ok 不是 true', file=sys.stderr)
        return 1
    sha = resp.get('sha256')
    if not isinstance(sha, str) or not re.match(r'^[0-9a-f]{64}$', sha):
        print('响应缺少合法的 sha256', file=sys.stderr)
        return 1
    if args.expect_sha and sha != args.expect_sha:
        print('服务器 sha256 与本地不一致', file=sys.stderr)
        return 1
    return 0


def cmd_status(args):
    st = read_state()
    if args.json:
        print(json.dumps(st, ensure_ascii=False))
        return 0
    zh = {'idle': '未登记', 'recording': '记录中', 'freezing': '正在停止记录',
          'pending_upload': '待提交', 'finished': '已结束'}
    print('状态：%s' % zh.get(st['state'], st['state']))
    if st.get('run_id'):
        print('登记号：%s' % st['run_id'])
        print('学生：%s（%s）' % (st.get('name'), st.get('sid')))
        print('实验目录：%s' % st.get('labs_root'))
        print('开始时间：%s' % st.get('started_at'))
    if st.get('error'):
        print('说明：%s' % st['error'])
    return 0


def cmd_run_dir(args):
    st = read_state()
    if not st.get('run_dir'):
        return 1
    print(st['run_dir'])
    return 0


def cmd_check_pretty(args):
    st = read_state()
    if st.get('run_id') != args.run or not st.get('run_dir'):
        return 1
    return 0 if tty_is_pretty(st['run_dir'], args.tty, args.session) else 1


def cmd_gate(args):
    """给 shell 用的一次性门禁查询：state==recording 且 run 匹配则返回 0。"""
    st = read_state()
    ok = st.get('state') == 'recording' and (not args.run or st.get('run_id') == args.run)
    return 0 if ok else 1


def main(argv=None):
    ap = argparse.ArgumentParser(prog='session.py')
    sub = ap.add_subparsers(dest='cmd', required=True)

    p = sub.add_parser('begin')
    p.add_argument('--sid', required=True)
    p.add_argument('--name', required=True)
    p.add_argument('--labs', required=True)
    p.add_argument('--course', default='')
    p.set_defaults(func=cmd_begin)

    sub.add_parser('freeze').set_defaults(func=cmd_freeze)
    p = sub.add_parser('pending')
    p.add_argument('--error', default='')
    p.set_defaults(func=cmd_pending)
    sub.add_parser('finish').set_defaults(func=cmd_finish)
    sub.add_parser('abort').set_defaults(func=cmd_abort)

    p = sub.add_parser('status')
    p.add_argument('--json', action='store_true')
    p.set_defaults(func=cmd_status)

    sub.add_parser('run-dir').set_defaults(func=cmd_run_dir)

    p = sub.add_parser('check-pretty')
    p.add_argument('--run', required=True)
    p.add_argument('--tty', required=True)
    p.add_argument('--session', required=True)
    p.set_defaults(func=cmd_check_pretty)

    p = sub.add_parser('gate')
    p.add_argument('--run', default='')
    p.set_defaults(func=cmd_gate)

    p = sub.add_parser('stop-proxies')
    p.add_argument('--run-dir', required=True)
    p.set_defaults(func=cmd_stop_proxies)

    p = sub.add_parser('verify-upload')
    p.add_argument('--expect-sha', default='')
    p.set_defaults(func=cmd_verify_upload)

    args = ap.parse_args(argv)
    return args.func(args)


if __name__ == '__main__':
    sys.exit(main())
