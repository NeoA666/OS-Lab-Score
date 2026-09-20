#!/usr/bin/env bash
# labtracker 终端接入钩子（由 ~/.bashrc 末尾标记块 source）
#
# 规则：
#   - 未登记：什么都不做，不采集、不装命令钩子。
#   - 登记中且本终端还没有代理：套一层 recorder.py（输出+timing+命令日志）。
#   - 已在代理内（嵌套 bash、重新 source）：只装命令钩子，不重复套录。
#   - 登记前就打开的终端：不补录，提示学生新开终端。
#   - 上一轮已停止记录的终端：代理仍在转发但已停写，不再重新接入。
#
# 铁律：本文件任何一步失败都必须退回普通 shell，绝不阻断学生。

[ -n "$BASH_VERSION" ] || return 0 2>/dev/null || exit 0

LABT_HOME="$HOME/.labtracker"
LABT_BIN="$LABT_HOME/bin"
STATE_FILE="$LABT_HOME/state/current.state"

[ -f "$LABT_BIN/session.py" ] || return 0 2>/dev/null || exit 0

# ---------------------------------------------------------------- 命令级日志
__labt_last_hist=""
__labt_log_cmd() {
    local rc=$?
    local line num cmd
    line=$(HISTTIMEFORMAT= builtin history 1 2>/dev/null) || return $rc
    num=$(printf '%s' "$line" | awk '{print $1}')
    cmd=$(printf '%s' "$line" | sed 's/^ *[0-9]\{1,\} *\*\{0,1\}//')
    [ -n "$cmd" ] || return $rc
    # 空回车不会新增历史号，避免重复记录同一条命令
    [ -n "$num" ] && [ "$num" = "$__labt_last_hist" ] && return $rc
    __labt_last_hist=$num
    case "$cmd" in
        __labt_*|labt_*|history*) return $rc ;;
    esac
    "$LABT_BIN/log-event.sh" cmd \
        "cwd=$(pwd)" \
        "rc=__num__$rc" \
        "cmd=$cmd" </dev/null >/dev/null 2>&1
    return $rc
}

__labt_install_cmd_hook() {
    # 兼容 PROMPT_COMMAND 的字符串/数组两种形式，且重复 source 不重复安装
    case "$(declare -p PROMPT_COMMAND 2>/dev/null)" in
        "declare -a"*) ;;
        *) PROMPT_COMMAND="" ;;
    esac
    local joined
    joined=$(declare -p PROMPT_COMMAND 2>/dev/null)
    case "$joined" in
        *__labt_log_cmd*) return 0 ;;
    esac
    HISTCONTROL=
    PROMPT_COMMAND="__labt_log_cmd${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
    return 0
}

__labt_main() {
    # 只处理交互式 Bash
    case $- in *i*) ;; *) return 0 ;; esac
    [ -n "$PS1" ] || return 0

    local tty
    tty=$(tty 2>/dev/null) || return 0
    case $tty in /dev/*) ;; *) return 0 ;; esac

    [ -f "$STATE_FILE" ] || return 0
    local state run run_dir
    state=$(sed -n 's/^state=//p' "$STATE_FILE" 2>/dev/null | head -1)
    run=$(sed -n 's/^run_id=//p' "$STATE_FILE" 2>/dev/null | head -1)
    run_dir=$(sed -n 's/^run_dir=//p' "$STATE_FILE" 2>/dev/null | head -1)

    local m proxy_pid=""
    m=$(printf '%s' "$tty" | sed 's#^/##; s#/#_#g')
    if [ -n "$run_dir" ] && [ -f "$run_dir/capture/proxies/by-tty/$m" ]; then
        proxy_pid=$(head -1 "$run_dir/capture/proxies/by-tty/$m" 2>/dev/null)
    fi

    # 已在本轮代理的 PTY 内（嵌套 bash / exec bash / 重新 source）
    # 会话级 session_start/end 由 recorder.py 统一记录，这里只装命令钩子
    if [ -n "$proxy_pid" ] && kill -0 "$proxy_pid" 2>/dev/null; then
        __labt_install_cmd_hook
        return 0
    fi
    # 代理刚启动、by-tty 尚未落盘时的兜底（环境变量由代理注入）
    if [ -n "$LABT_PROXY_PID" ] && [ "$LABT_PROXY_TTY" = "$tty" ] \
       && kill -0 "$LABT_PROXY_PID" 2>/dev/null; then
        __labt_install_cmd_hook
        return 0
    fi

    # 未登记：不采集
    [ "$state" = "recording" ] && [ -n "$run" ] && [ -n "$run_dir" ] || return 0

    # 登记前就已打开的终端不补录（同一会话内的 exec bash 也算旧终端）
    if [ -f "$run_dir/capture/pretty/$m" ]; then
        local _ptty _psess _pboot sess curboot
        IFS='|' read -r _ptty _psess _pboot < "$run_dir/capture/pretty/$m"
        sess=$(awk '{for(i=1;i<=NF;i++) if($i ~ /\)$/){print $(i+4); exit}}' /proc/$$/stat 2>/dev/null)
        curboot=$(cat /proc/sys/kernel/random/boot_id 2>/dev/null)
        if [ -n "$sess" ] && [ "$_psess" = "$sess" ] && [ "$_pboot" = "$curboot" ]; then
            printf '\n[实验记录] 本终端在登记前就已打开，不会补录。请新开一个终端做实验。\n\n' >&2
            return 0
        fi
    fi

    local base
    base=$(date +%Y%m%dT%H%M%S)-$$
    # execfail：万一 python3 缺失或代理启动失败，退回普通 shell，而不是把学生终端关掉
    shopt -s execfail
    exec python3 "$LABT_BIN/recorder.py" --run "$run" --base "$base" --shell bash
    shopt -u execfail
    printf '\n[实验记录] 未能启动记录程序，本终端不会被记录。请把这条信息发给老师。\n\n' >&2
    return 0
}

__labt_main
