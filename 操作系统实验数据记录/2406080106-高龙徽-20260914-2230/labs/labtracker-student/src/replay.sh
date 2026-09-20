#!/usr/bin/env bash
# labtracker 录像回放助手
# 用法:
#   labt-replay <录像> [--speed 倍速] [--cast [输出.cast]]
#   <录像> 可以是 .out / .out.gz / 基名（如 20260903T094416-10900）
#   缺省在本次登记的录像目录里找，也可以直接给完整路径。
set -u
LABT_HOME="$HOME/.labtracker"
STATE_FILE="$LABT_HOME/state/current.state"
BIN_DIR="$(dirname "$(readlink -f "$0")")"

usage() { sed -n '2,6p' "$0"; exit 1; }
[ $# -ge 1 ] || usage

REC=$1; shift
SPEED=1
CAST=""
while [ $# -gt 0 ]; do
    case $1 in
        --speed) SPEED=${2:-1}; shift 2 ;;
        --cast)  if [ $# -ge 2 ] && [ "${2:0:2}" != "--" ]; then CAST=$2; shift 2; else CAST=""; shift; fi ;;
        *) usage ;;
    esac
done

search_dirs() {
    local d
    d=$(sed -n 's/^run_dir=//p' "$STATE_FILE" 2>/dev/null | head -1)
    [ -n "$d" ] && printf '%s\n' "$d/term"
    ls -1dt "$LABT_HOME"/data/runs/*/term 2>/dev/null
    printf '%s\n' "$LABT_HOME/data/term"
}

resolve() {
    local base=$1 d p
    for p in "$base" "$base.out"; do
        [ -f "$p" ] && { printf '%s' "$p"; return 0; }
    done
    [ -f "$base.out.gz" ] && { printf '%s' "$base.out.gz"; return 0; }
    while IFS= read -r d; do
        for p in "$d/$base" "$d/$base.out" "$d/$base.out.gz"; do
            [ -f "$p" ] && { printf '%s' "$p"; return 0; }
        done
    done < <(search_dirs)
    return 1
}

OUTFILE=$(resolve "$REC") || { echo "找不到录像: $REC" >&2; exit 1; }
OUTFILE=$(readlink -f "$OUTFILE")
DIR=$(dirname "$OUTFILE")
STEM=$(basename "$OUTFILE"); STEM=${STEM%.gz}; STEM=${STEM%.out}

TMP=$(mktemp -d /tmp/labt-replay.XXXXXX)
trap 'rm -rf "$TMP"' EXIT
if [ -f "$DIR/$STEM.out.gz" ]; then gunzip -c "$DIR/$STEM.out.gz" > "$TMP/$STEM.out"
else cp "$DIR/$STEM.out" "$TMP/$STEM.out"; fi
TIM=""
for t in "$DIR/$STEM.tim" "$DIR/$STEM.tim.gz"; do
    if [ -f "$t" ]; then
        case $t in
            *.gz) gunzip -c "$t" > "$TMP/$STEM.tim" ;;
            *) cp "$t" "$TMP/$STEM.tim" ;;
        esac
        TIM="$TMP/$STEM.tim"
        break
    fi
done

if [ -n "$CAST" ] || [ "${1:-}" = "--cast" ]; then
    OUT_CAST=${CAST:-"$STEM.cast"}
    python3 "$BIN_DIR/castify.py" "$TMP/$STEM.out" "$TIM" -o "$OUT_CAST"
    echo "已生成 $OUT_CAST"
    echo '提示: 安装 asciinema 后可用 "asciinema play 文件.cast" 回放。'
    exit 0
fi

echo "回放 $STEM （Ctrl+C 退出；倍速 $SPEED）"
if [ -n "$TIM" ] && command -v scriptreplay >/dev/null 2>&1; then
    scriptreplay --log-timing "$TIM" --log-out "$TMP/$STEM.out" --divisor "$SPEED"
else
    cat "$TMP/$STEM.out"
fi
