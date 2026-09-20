#!/usr/bin/env python3
"""labtracker 录像 → 可读纯文本转录

用法: transcript.py <rec.out[.gz]> [<rec.tim[.gz]>] [-o 输出.txt]

原理：timing 文件(classic 格式，每行"延迟 字节数")把显示流切成块并给出时间；
剥掉 ANSI 转义序列，处理 \\r 覆盖行（进度条类输出取最后一次覆盖），
在时间间隔明显处打 [分:秒] 时间戳，方便老师快速定位。
"""
import argparse
import gzip
import os
import re
import sys

ANSI_RE = re.compile(
    rb'\x1b\[[0-9;?]*[ -/]*[@-~]'          # CSI 序列（颜色/光标）
    rb'|\x1b\][^\x07\x1b]*(?:\x07|\x1b\\)'  # OSC 序列（窗口标题等）
    rb'|\x1b[()][0-9A-B]'                   # 字符集切换
    rb'|\x1b[\x40-\x5f]'                    # 其余两字节转义（0x40~0x5F 终止符）
)

# carry 检测只认"必须完整才算完"的多字符序列（CSI/OSC），
# 否则 \x1b]0;标题 这类跨块序列会被两字节分支误判为已完整
STRICT_SEQ_RE = re.compile(
    rb'\x1b\[[0-9;?]*[ -/]*[@-~]'
    rb'|\x1b\][^\x07\x1b]*(?:\x07|\x1b\\)'
)

# script 自带的头尾说明行
SCRIPT_HDR = re.compile(r'^Script (started|done) on ')


def read_bytes(path):
    op = gzip.open if path.endswith('.gz') else open
    with op(path, 'rb') as f:
        return f.read()


def read_timing(path):
    """返回 [(累计时间秒, 字节数), ...]；文件缺失/损坏时返回 None"""
    if not path or not os.path.exists(path):
        return None
    entries = []
    try:
        op = gzip.open if path.endswith('.gz') else open
        with op(path, 'rb') as f:
            t = 0.0
            for line in f:
                parts = line.split()
                if len(parts) < 2:
                    continue
                try:
                    t += float(parts[0])
                    entries.append((t, int(parts[1])))
                except ValueError:
                    continue
    except OSError:
        return None
    return entries or None


def split_chunks(data, timing):
    """按 timing 把字节流切块；没有 timing 就整段一块"""
    if not timing:
        return [(0.0, data)]
    chunks, pos, t = [], 0, 0.0
    for t, n in timing:
        chunks.append((t, data[pos:pos + n]))
        pos += n
    if pos < len(data):
        chunks.append((t, data[pos:]))
    return chunks


def carry_len(chunk):
    """块尾若有被截断的转义序列（如跨块的窗口标题 OSC），返回需留到下块的字节数"""
    i = chunk.rfind(b'\x1b')
    if i == -1:
        return 0
    tail = chunk[i:]
    if STRICT_SEQ_RE.search(tail):
        return 0        # 从最后一个 ESC 起已是完整多字符序列
    if len(tail) > 512:
        return 0        # 异常长，按普通噪声处理
    return len(tail)


def clean_text(b):
    """ANSI 剥离 + \\r 覆盖处理 → 干净文本行列表"""
    text = ANSI_RE.sub(b'', b).replace(b'\x00', b'').replace(b'\x08', b'')
    text = text.decode('utf-8', 'replace')
    lines = []
    for raw in text.split('\n'):
        segs = raw.split('\r')
        # 终端里 \r 表示回到行首覆盖：保留最后一段非空内容
        line = ''
        for s in segs:
            if s.strip():
                line = s
        lines.append(line)
    return lines


def fmt_dur(sec):
    m, s = divmod(int(sec), 60)
    if m >= 60:
        return f"{m // 60}小时{m % 60}分{s:02d}秒"
    return f"{m}分{s:02d}秒"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('out', help='.out 或 .out.gz 显示流文件')
    ap.add_argument('tim', nargs='?', help='.tim 或 .tim.gz 时间戳文件')
    ap.add_argument('-o', '--output', help='输出文件，缺省打印到stdout')
    args = ap.parse_args()

    data = read_bytes(args.out)
    tim_path = args.tim
    if tim_path is None:
        base = args.out[:-3] if args.out.endswith('.gz') else args.out
        for cand in (base[:-4] + '.tim.gz', base[:-4] + '.tim'):
            if os.path.exists(cand):
                tim_path = cand
                break
    timing = read_timing(tim_path)

    chunks = split_chunks(data, timing)
    duration = chunks[-1][0] if chunks else 0.0

    result = []
    result.append('==== labtracker 终端转录 ====')
    result.append(f'录像: {os.path.basename(args.out)}   时长: {fmt_dur(duration)}   原始大小: {len(data)}B')
    result.append('=' * 50)

    last_mark_t = 0.0
    emitted_any = False
    buf = []
    carry = b''
    t_last = 0.0
    for t, chunk in chunks:
        chunk = carry + chunk
        carry = b''
        n = carry_len(chunk)
        if n:
            carry = chunk[-n:]
            chunk = chunk[:-n]
        t_last = t
        for line in clean_text(chunk):
            if SCRIPT_HDR.match(line.strip()):
                continue
            if not line.strip():
                buf.append('')
                continue
            if t - last_mark_t >= 3.0 and emitted_any:
                buf.append(f'-- [{fmt_dur(t)}] --')
                last_mark_t = t
            elif not emitted_any:
                buf.append(f'-- [开始] --')
                last_mark_t = t
                emitted_any = True
            buf.append(line)
    if carry:
        for line in clean_text(carry):
            if line.strip() and not SCRIPT_HDR.match(line.strip()):
                buf.append(line)

    # 压掉连续空行
    out_lines, blank = [], 0
    for l in buf:
        if l.strip():
            blank = 0
            out_lines.append(l)
        else:
            blank += 1
            if blank <= 1:
                out_lines.append(l)

    result.extend(out_lines)
    text = '\n'.join(result) + '\n'

    if args.output:
        with open(args.output, 'w', encoding='utf-8') as f:
            f.write(text)
    else:
        sys.stdout.write(text)


if __name__ == '__main__':
    main()
