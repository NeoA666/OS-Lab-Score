#!/usr/bin/env bash
# labtracker 登录提醒（可选组件，只提醒，绝不自动登记、不自动采集）
set -u
LABT_HOME="$HOME/.labtracker"
STATE_FILE="$LABT_HOME/state/current.state"

[ -n "${DISPLAY:-}" ] || [ -n "${WAYLAND_DISPLAY:-}" ] || exit 0
command -v zenity >/dev/null 2>&1 || exit 0
[ -f "$STATE_FILE" ] || exit 0

st() { sed -n "s/^$1=//p" "$STATE_FILE" 2>/dev/null | head -1; }
state=$(st state)
[ "$state" = "idle" ] && exit 0

case $state in
    recording)
        zenity --info --title="实验记录" --text="上次登记的记录仍在进行中（$(st run_id)）。\n\n做完实验后请点《提交实验》。" 2>/dev/null ;;
    freezing|pending_upload)
        zenity --warning --title="实验记录" --text="上次登记的提交还没有完成。\n\n请点《提交实验》重传提交包。" 2>/dev/null ;;
esac
exit 0
