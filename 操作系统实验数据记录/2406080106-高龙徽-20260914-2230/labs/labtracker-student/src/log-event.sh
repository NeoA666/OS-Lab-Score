#!/usr/bin/env bash
# labtracker 事件写入器（登记门控版）
# 用法: log-event.sh <类型> [字段=值 ...]
#
# 与 state/lock 共用同一把 flock；锁内重新核对 run_id 与 state=recording，
# 因此提交把状态改为 freezing 之后，任何采集事件都不可能再落盘。
# 事件写入当前登记目录 data/runs/<run_id>/events.jsonl，身份取登记快照。
# 任何故障都静默退出，绝不阻断学生终端。

LABT_HOME="$HOME/.labtracker"
STATE_DIR="$LABT_HOME/state"
STATE_FILE="$STATE_DIR/current.state"
LOCK="$STATE_DIR/lock"

[ -f "$STATE_FILE" ] || exit 0
[ "$#" -ge 1 ] || exit 0

TYPE=$1; shift

# 快速预检：绝大多数命令在未登记时走到这里就返回，不必抢锁
grep -q '^state=recording$' "$STATE_FILE" 2>/dev/null || exit 0

RUN_WANT="${LABT_RUN:-}"

exec 9>>"$LOCK" 2>/dev/null || exit 0
flock -x -w 2 9 || exit 0

CUR_STATE=$(sed -n 's/^state=//p' "$STATE_FILE" 2>/dev/null | head -1)
CUR_RUN=$(sed -n 's/^run_id=//p' "$STATE_FILE" 2>/dev/null | head -1)
CUR_DIR=$(sed -n 's/^run_dir=//p' "$STATE_FILE" 2>/dev/null | head -1)
LABT_SID=$(sed -n 's/^sid=//p' "$STATE_FILE" 2>/dev/null | head -1)
LABT_NAME=$(sed -n 's/^name=//p' "$STATE_FILE" 2>/dev/null | head -1)

[ "$CUR_STATE" = "recording" ] || exit 0
[ -n "$CUR_DIR" ] && [ -d "$CUR_DIR" ] || exit 0
[ -n "$RUN_WANT" ] && [ "$RUN_WANT" != "$CUR_RUN" ] && exit 0

# ---------- JSON 字符串转义 ----------
labt_esc() {
    local s=$1
    s=${s//\\/\\\\}
    s=${s//\"/\\\"}
    s=${s//$'\n'/\\n}
    s=${s//$'\r'/}
    s=${s//$'\t'/\\t}
    printf '%s' "$s" | tr -d '\001-\037\177'
}

TS=$(date +%Y-%m-%dT%H:%M:%S%:z)
EPOCH=$(date +%s)

payload="{\"ts\":\"$TS\",\"epoch\":$EPOCH,\"run\":\"$(labt_esc "$CUR_RUN")\",\"type\":\"$(labt_esc "$TYPE")\""
[ -n "$LABT_SID" ] && payload="$payload,\"sid\":\"$(labt_esc "$LABT_SID")\""
[ -n "$LABT_NAME" ] && payload="$payload,\"name\":\"$(labt_esc "$LABT_NAME")\""
for kv in "$@"; do
    k=${kv%%=*}; v=${kv#*=}
    [ "$k" = "$kv" ] && continue
    case $v in
        __num__*) v=${v#__num__}; payload="$payload,\"$k\":$(labt_esc "$v")" ;;
        *)        payload="$payload,\"$k\":\"$(labt_esc "$v")\"" ;;
    esac
done

EVENTS="$CUR_DIR/events.jsonl"
MIRROR="$CUR_DIR/events.mirror.jsonl"
CHAIN="$CUR_DIR/.chainstate"

PREV="0000000000000000000000000000000000000000000000000000000000000000"
[ -s "$CHAIN" ] && PREV=$(head -1 "$CHAIN")
payload="$payload,\"prev\":\"$PREV\""
H=$(printf '%s\n%s' "$PREV" "$payload" | sha256sum | cut -d' ' -f1)

printf '%s,"h":"%s"}\n' "$payload" "$H" >> "$EVENTS" 2>/dev/null || exit 0
printf '%s}\n' "$payload" >> "$MIRROR" 2>/dev/null
printf '%s' "$H" > "$CHAIN" 2>/dev/null
exit 0
