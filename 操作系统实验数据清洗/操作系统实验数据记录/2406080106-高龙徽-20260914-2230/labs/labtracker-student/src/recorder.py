#!/usr/bin/env python3
"""labtracker 可停写 PTY 代理

作用：给一个交互 Bash 套一层伪终端，把输出写成 <base>.out / <base>.tim
（与 util-linux script 兼容，可被现有转录与回放工具读取），同时：

- 只记录终端显示流，不保存原始键盘输入；
- 每个输出块与其 timing 项在同一把采集锁内配对写入；
- 收到 STOP_LOG 后只关闭日志，继续透明转发，学生终端和正在运行的命令不受影响；
- 采集门禁失效（登记已冻结）时自动停写，不需要外部信号。

用法（由 hook.sh 调用，不直接给学生用）：
    recorder.py --run <run_id> --base <base> [--shell bash]
"""
import argparse
import errno
import fcntl
import json
import os
import selectors
import signal
import socket
import subprocess
import sys
import termios
import time
import traceback
import tty

BIN_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, BIN_DIR)
import session  # noqa: E402

SOCK_DIR = os.path.join(session.LABT_HOME, 'state', 'sock')
CHUNK = 65536


def log(msg):
    sys.stderr.write('[labtracker] %s\n' % msg)
    sys.stderr.flush()


def detect_term():
    if os.environ.get('TERM_PROGRAM'):
        return os.environ['TERM_PROGRAM']
    if os.environ.get('TMUX'):
        return 'tmux'
    return os.environ.get('TERM', '') or 'unknown'


def emit_event(run_id, etype, **fields):
    """会话事件仍走 log-event.sh，保证与命令事件同一条哈希链、同一套门禁。"""
    script = os.path.join(BIN_DIR, 'log-event.sh')
    if not os.path.exists(script):
        return
    env = dict(os.environ)
    env['LABT_RUN'] = run_id
    argv = [script, etype] + ['%s=%s' % (k, v) for k, v in fields.items()]
    try:
        subprocess.run(argv, env=env, stdin=subprocess.DEVNULL,
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                       timeout=5)
    except (OSError, subprocess.SubprocessError):
        pass


def copy_winsize(src_fd, dst_fd):
    try:
        data = fcntl.ioctl(src_fd, termios.TIOCGWINSZ, b'\0' * 8)
        fcntl.ioctl(dst_fd, termios.TIOCSWINSZ, data)
    except OSError:
        pass


class Logger:
    """输出与 timing 配对写入；门禁失效即永久停写。"""

    def __init__(self, gate, base, term_dir):
        self.gate = gate
        self.logging = True
        self.errors = []
        self.out_bytes = 0
        self.tim_bytes = 0
        self.t0 = time.monotonic()
        self.out = None
        self.tim = None
        try:
            os.makedirs(term_dir, exist_ok=True)
            self.out = open(os.path.join(term_dir, base + '.out'), 'wb', buffering=0)
            self.tim = open(os.path.join(term_dir, base + '.tim'), 'wb', buffering=0)
        except OSError as e:
            self.logging = False
            self.errors.append('open:%s' % e)
            self._close()

    def feed(self, data):
        if not self.logging or not data:
            return
        line = ('%.6f %d\n' % (time.monotonic() - self.t0, len(data))).encode('ascii')

        def do():
            self.out.write(data)
            self.tim.write(line)
            self.out_bytes += len(data)
            self.tim_bytes += len(line)

        try:
            if not self.gate.write(do):
                self.logging = False
                self.errors.append('gate-closed')
                self._close()
        except OSError as e:
            self.logging = False
            self.errors.append('write:%s' % e)
            self._close()

    def stop(self):
        if self.logging:
            self.logging = False
        self._close()

    def _close(self):
        for f in (self.out, self.tim):
            try:
                if f is not None:
                    f.close()
            except OSError:
                pass
        self.out = self.tim = None


def fallback(shell):
    """把终端交还给学生：记录程序自身出问题时，绝不能让学生开不了终端。"""
    try:
        os.execvp(shell, [shell])
    except OSError:
        os._exit(127)


def main():
    ap = argparse.ArgumentParser(prog='recorder.py')
    ap.add_argument('--run', required=True)
    ap.add_argument('--base', required=True)
    ap.add_argument('--shell', default='bash')
    args = ap.parse_args()
    try:
        return _main(args)
    except SystemExit:
        raise
    except BaseException:
        # fork 之前出任何问题：把终端还给学生的 shell，绝不能让记录程序挡住终端
        traceback.print_exc()
        fallback(args.shell)
        raise


def _main(args):
    st = session.read_state()
    run_dir = st.get('run_dir') or ''
    recording = st.get('state') == 'recording' and st.get('run_id') == args.run

    if not recording or not run_dir:
        # 登记已冻结或不存在：不记录，但仍要把终端交还给学生
        os.execvp(args.shell, [args.shell])
        return 1

    term_dir = os.path.join(run_dir, 'term')
    proxies = os.path.join(run_dir, 'capture', 'proxies')
    by_tty = os.path.join(proxies, 'by-tty')
    os.makedirs(by_tty, exist_ok=True)
    os.makedirs(SOCK_DIR, exist_ok=True, mode=0o700)

    pid = os.getpid()
    sock_path = os.path.join(SOCK_DIR, '%d.sock' % pid)
    try:
        os.unlink(sock_path)
    except OSError:
        pass
    srv = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    srv.bind(sock_path)
    os.chmod(sock_path, 0o600)
    srv.listen(4)
    srv.setblocking(False)

    master, slave = pty_open()
    slave_name = os.ttyname(slave)
    base = args.base

    def write_proxy(stopped):
        rec = {
            'pid': pid, 'tty': slave_name, 'session': session._proc_session(pid) or '',
            'base': base, 'run_id': args.run, 'sock': sock_path,
            'starttime': session._proc_starttime(pid) or '',
            'stopped': stopped, 'updated_at': session.now_iso(),
        }
        tmp = os.path.join(proxies, '%d.json.tmp' % pid)
        with open(tmp, 'w', encoding='utf-8') as f:
            json.dump(rec, f, ensure_ascii=False)
        os.replace(tmp, os.path.join(proxies, '%d.json' % pid))
        with open(os.path.join(by_tty, session._mangle(slave_name)), 'w') as f:
            f.write('%d\n' % pid)

    # 先登记代理身份，再启动子 shell：保证子 Bash 读 .bashrc 时一定能看到自己已在代理内
    gate = session.Gate(args.run)
    logger = Logger(gate, base, term_dir)
    write_proxy(False)
    emit_event(args.run, 'session_start', tty=slave_name, term=detect_term(),
               rec=base, proxy_pid=pid)

    child = os.fork()
    if child == 0:
        try:
            os.close(master)
            os.setsid()
            fcntl.ioctl(slave, termios.TIOCSCTTY, 0)
            copy_winsize(0, slave)
            os.dup2(slave, 0)
            os.dup2(slave, 1)
            os.dup2(slave, 2)
            if slave > 2:
                os.close(slave)
            os.environ['LABT_WRAPPED'] = '1'
            os.environ['LABT_PROXY_PID'] = str(pid)
            os.environ['LABT_PROXY_TTY'] = slave_name
            os.environ['LABT_RUN'] = args.run
            os.environ['LABT_REC_BASE'] = base
            os.execvp(args.shell, [args.shell])
        except BaseException:
            os._exit(127)

    os.close(slave)
    os.set_blocking(master, False)

    saved_term = None
    if os.isatty(0):
        try:
            saved_term = termios.tcgetattr(0)
            tty.setraw(0)
        except termios.error:
            saved_term = None

    wake_r, wake_w = os.pipe()
    os.set_blocking(wake_r, False)
    os.set_blocking(wake_w, False)
    signal.set_wakeup_fd(wake_w)
    signal.signal(signal.SIGWINCH, lambda *_: None)

    sel = selectors.DefaultSelector()
    sel.register(0, selectors.EVENT_READ, 'stdin')
    sel.register(master, selectors.EVENT_READ, 'master')
    sel.register(srv.fileno(), selectors.EVENT_READ, 'sock')
    sel.register(wake_r, selectors.EVENT_READ, 'winch')

    status = 0
    try:
        running = True
        while running:
            for key, _ in sel.select(timeout=1.0):
                if key.data == 'winch':
                    try:
                        os.read(wake_r, 4096)
                    except OSError:
                        pass
                    copy_winsize(0, master)
                elif key.data == 'stdin':
                    try:
                        data = os.read(0, CHUNK)
                    except OSError:
                        data = b''
                    if not data:
                        running = False
                        break
                    try:
                        os.write(master, data)
                    except OSError as e:
                        if e.errno not in (errno.EIO, errno.EBADF, errno.EAGAIN):
                            running = False
                            break
                elif key.data == 'master':
                    try:
                        data = os.read(master, CHUNK)
                    except OSError as e:
                        if e.errno in (errno.EIO, errno.EBADF):
                            running = False
                            break
                        if e.errno == errno.EAGAIN:
                            continue
                        running = False
                        break
                    if not data:
                        running = False
                        break
                    try:
                        os.write(1, data)
                    except OSError:
                        pass
                    logger.feed(data)
                elif key.data == 'sock':
                    handle_control(srv, logger, write_proxy, base)
    finally:
        logger.stop()
        emit_event(args.run, 'session_end', rec=base, proxy_pid=pid,
                   out_bytes=logger.out_bytes, tim_bytes=logger.tim_bytes,
                   errors=','.join(logger.errors) or 'none')
        try:
            _, status_raw = os.waitpid(child, 0)
            if os.WIFEXITED(status_raw):
                status = os.WEXITSTATUS(status_raw)
            elif os.WIFSIGNALED(status_raw):
                status = 128 + os.WTERMSIG(status_raw)
        except OSError:
            pass
        for f in (wake_r, wake_w):
            try:
                os.close(f)
            except OSError:
                pass
        if saved_term is not None:
            try:
                termios.tcsetattr(0, termios.TCSADRAIN, saved_term)
            except termios.error:
                pass
        for p in (sock_path, os.path.join(proxies, '%d.json' % pid),
                  os.path.join(by_tty, session._mangle(slave_name))):
            try:
                os.unlink(p)
            except OSError:
                pass
        try:
            srv.close()
        except OSError:
            pass
        gate.close()
    return status


def pty_open():
    master, slave = os.openpty()
    return master, slave


def handle_control(srv, logger, write_proxy, base):
    """处理提交侧的 STOP_LOG；只关闭日志，不动终端。"""
    try:
        conn, _ = srv.accept()
    except OSError:
        return
    conn.settimeout(3.0)
    try:
        buf = b''
        while b'\n' not in buf and len(buf) < 4096:
            chunk = conn.recv(4096)
            if not chunk:
                break
            buf += chunk
        try:
            req = json.loads(buf.decode('utf-8', 'replace').strip() or '{}')
        except ValueError:
            req = {}
        cmd = req.get('cmd')
        if cmd == 'stop_log':
            logger.stop()
            write_proxy(True)
            resp = {'ok': True, 'base': base, 'pid': os.getpid(),
                    'out': logger.out_bytes, 'tim': logger.tim_bytes,
                    'errors': logger.errors}
            conn.sendall((json.dumps(resp, ensure_ascii=False) + '\n').encode())
        elif cmd == 'ping':
            conn.sendall((json.dumps({'ok': True, 'logging': logger.logging}) + '\n').encode())
        else:
            conn.sendall(b'{"ok":false,"err":"unknown"}\n')
    except OSError:
        pass
    finally:
        try:
            conn.close()
        except OSError:
            pass


if __name__ == '__main__':
    sys.exit(main())
