#!/usr/bin/env bash
# labtracker 心跳守护
# 只在登记进行中写心跳（活跃度统计用）；登记结束或长时间空闲后自行退出，
# 不做常驻进程。磁盘整理只处理已经结束的登记的录像文件。
LABT_HOME="$HOME/.labtracker"
LABT_BIN="$LABT_HOME/bin"
STATE_FILE="$LABT_HOME/state/current.state"

IDLE_ACTIVE_MAX_MS=120000
HOUSEKEEP_INTERVAL=600
TERM_GZ_AFTER_MIN=720
HB_SEC=${LABT_HB_SEC:-60}
IDLE_EXIT_TICKS=${LABT_IDLE_EXIT_TICKS:-10}   # 连续多少个心跳周期未登记就退出

[ -f "$STATE_FILE" ] || exit 1

st() { sed -n "s/^$1=//p" "$STATE_FILE" 2>/dev/null | head -1; }

idle_ms() {
    gdbus call --session \
        --dest org.gnome.Mutter.IdleMonitor \
        --object-path /org/gnome/Mutter/IdleMonitor/Core \
        --method org.gnome.Mutter.IdleMonitor.GetIdletime 2>/dev/null \
        | grep -o '[0-9]\+' | head -1
}

labs_changed_count() {
    local root=$1 run_dir=$2 stamp n=0
    stamp="$run_dir/.labstamp"
    [ -n "$root" ] && [ -d "$root" ] || { printf '0'; return; }
    [ -e "$stamp" ] || touch "$stamp"
    n=$(find "$root" -type f -newer "$stamp" 2>/dev/null | head -50 | wc -l)
    touch "$stamp" 2>/dev/null
    printf '%s' "$n"
}

housekeep() {
    local cur_run=$1 d
    for d in "$LABT_HOME"/data/runs/*/; do
        [ -d "$d" ] || continue
        # 只压缩已结束登记的录像，绝不碰正在写入的文件
        [ "$(basename "$d")" = "$cur_run" ] && continue
        find "$d/term" -name '*.out' -mmin +"$TERM_GZ_AFTER_MIN" -exec gzip -f {} \; 2>/dev/null
        find "$d/term" -name '*.tim' -mmin +"$TERM_GZ_AFTER_MIN" -exec gzip -f {} \; 2>/dev/null
    done
    # 清理孤儿代理 socket
    find "$LABT_HOME/state/sock" -name '*.sock' -mmin +1440 -delete 2>/dev/null
    return 0
}

_counter=0
_idle_ticks=0
while :; do
    state=$(st state)
    run_dir=$(st run_dir)
    if [ "$state" = "recording" ] && [ -n "$run_dir" ] && [ -d "$run_dir" ]; then
        _idle_ticks=0
        root=$(sed -n 's/^labs_root=//p' "$run_dir/run.conf" 2>/dev/null | head -1)
        [ -n "$root" ] || root=$(sed -n 's/^LABS_ROOT=//p' "$LABT_HOME/config" 2>/dev/null | head -1)
        _idle=$(idle_ms)
        _changed=$(labs_changed_count "$root" "$run_dir")
        "$LABT_BIN/log-event.sh" hb \
            "idle_ms=__num__${_idle:--1}" \
            "changed=__num__$_changed" </dev/null >/dev/null 2>&1
    else
        _idle_ticks=$((_idle_ticks + 1))
        [ "$_idle_ticks" -ge "$IDLE_EXIT_TICKS" ] && exit 0
    fi

    _counter=$((_counter + HB_SEC))
    if [ "$_counter" -ge "$HOUSEKEEP_INTERVAL" ]; then
        _counter=0
        housekeep "$(st run_id)"
    fi
    sleep "$HB_SEC"
done
