#!/usr/bin/env python3
"""labtracker 录像 → asciinema v2 (.cast) 格式

用法: castify.py <rec.out[.gz]> [<rec.tim[.gz]>] [-o 输出.cast]

.cast 是 JSONL：首行是头部，之后每行 [偏移秒, "o", 显示内容]。
生成后可用 `asciinema play xx.cast` 回放，或上传/内嵌网页播放器。
时间戳来自文件名里的录像时间（如 20260903T094416-1234）。
"""
import argparse
import datetime
import gzip
import json
import os
import re
import sys

FNAME_TS = re.compile(r'(\d{8})T(\d{6})')


def read_bytes(path):
    op = gzip.open if path.endswith('.gz') else open
    with op(path, 'rb') as f:
        return f.read()


def read_timing(path):
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


def ts_from_name(name):
    m = FNAME_TS.search(os.path.basename(name))
    if not m:
        return int(os.path.getmtime(name))
    d, t = m.group(1), m.group(2)
    try:
        dt = datetime.datetime.strptime(d + t, '%Y%m%d%H%M%S')
        return int(dt.timestamp())
    except ValueError:
        return int(os.path.getmtime(name))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('out')
    ap.add_argument('tim', nargs='?')
    ap.add_argument('-o', '--output')
    args = ap.parse_args()

    data = read_bytes(args.out)
    tim_path = args.tim
    if tim_path is None:
        base = args.out[:-3] if args.out.endswith('.gz') else args.out
        for cand in (base[:-4] + '.tim.gz', base[:-4] + '.tim'):
            if os.path.exists(cand):
                tim_path = cand
                break

    header = {
        "version": 2,
        "width": 100,
        "height": 30,
        "timestamp": ts_from_name(args.out),
        "env": {"TERM": "xterm-256color", "SHELL": "/bin/bash"},
    }

    events = []
    timing = read_timing(tim_path)
    if timing:
        pos = 0
        for t, n in timing:
            chunk = data[pos:pos + n]
            pos += n
            events.append([round(t, 6), "o", chunk.decode('utf-8', 'replace')])
        if pos < len(data):
            events.append([round(timing[-1][0], 6), "o", data[pos:].decode('utf-8', 'replace')])
    else:
        events.append([0.0, "o", data.decode('utf-8', 'replace')])

    if args.output:
        with open(args.output, 'w', encoding='utf-8') as f:
            f.write(json.dumps(header) + '\n')
            for e in events:
                f.write(json.dumps(e) + '\n')
        print(f"已生成 {args.output}（{len(events)} 段，可 `asciinema play` 回放）")
    else:
        sys.stdout.write(json.dumps(header) + '\n')
        for e in events:
            sys.stdout.write(json.dumps(e) + '\n')


if __name__ == '__main__':
    main()
