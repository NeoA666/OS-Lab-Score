#!/usr/bin/env bash
# labtracker 登记入口（学生用）
# 流程：确认身份 → 确认实验目录 → 创建登记 → 开始记录 → 提示新开终端
# 有图形界面走 zenity，无图形界面走终端问答。
set -u

LABT_HOME="$HOME/.labtracker"
LABT_BIN="$LABT_HOME/bin"
CONFIG="$LABT_HOME/config"
IDCONF="$LABT_HOME/data/id.conf"
STATE_FILE="$LABT_HOME/state/current.state"

SID_OPT=""; NAME_OPT=""; LABS_OPT=""
while [ $# -gt 0 ]; do
    case $1 in
        --sid)  SID_OPT=${2:-}; shift 2 ;;
        --name) NAME_OPT=${2:-}; shift 2 ;;
        --labs) LABS_OPT=${2:-}; shift 2 ;;
        *) shift ;;
    esac
done

GUI=0
command -v zenity >/dev/null 2>&1 \
    && { [ -n "${DISPLAY:-}" ] || [ -n "${WAYLAND_DISPLAY:-}" ]; } && GUI=1
# 参数齐全时走非交互（老师批量部署或自动化测试用）
[ -n "$SID_OPT" ] && [ -n "$NAME_OPT" ] && [ -n "$LABS_OPT" ] && GUI=0

say() { if [ $GUI -eq 1 ]; then zenity --info --title="登记实验" --text="$1" 2>/dev/null; else echo "$1"; fi; }
err() { if [ $GUI -eq 1 ]; then zenity --error --title="登记实验" --text="$1" 2>/dev/null; else echo "错误: $1" >&2; fi; }

valid_sid()  { printf '%s' "$1" | grep -Eq '^[0-9]{6,15}$'; }
valid_name() { [ ${#1} -ge 2 ] && [ ${#1} -le 30 ]; }

st() { sed -n "s/^$1=//p" "$STATE_FILE" 2>/dev/null | head -1; }

[ -x "$LABT_BIN/session.py" ] || [ -f "$LABT_BIN/session.py" ] || { err "程序未安装完整，请重新解压运行《登记实验》。"; exit 1; }

LABS_DEFAULT=$(sed -n 's/^LABS_ROOT=//p' "$CONFIG" 2>/dev/null | head -1)
case "$LABS_DEFAULT" in "~/"*) LABS_DEFAULT="$HOME/${LABS_DEFAULT#\~/}" ;; esac
COURSE=$(sed -n 's/^COURSE_NAME=//p' "$CONFIG" 2>/dev/null | head -1)

STATE=$(st state); [ -n "$STATE" ] || STATE=idle
case $STATE in
    recording)
        say "已经在记录中。\n\n登记号：$(st run_id)\n开始时间：$(st started_at)\n\n请新开一个终端做实验；做完后点《提交实验》。"
        exit 0 ;;
    freezing|pending_upload)
        say "上一次登记还没有提交成功。\n\n请先点《提交实验》完成上传，再开始新的登记。"
        exit 0 ;;
esac

# ---------- 身份 ----------
SID=$(sed -n 's/^sid=//p' "$IDCONF" 2>/dev/null | head -1)
NAME=$(sed -n 's/^name=//p' "$IDCONF" 2>/dev/null | head -1)
if [ -n "$SID_OPT" ] && [ -n "$NAME_OPT" ]; then
    SID=$SID_OPT; NAME=$NAME_OPT
    if ! valid_sid "$SID" || ! valid_name "$NAME"; then
        err "学号须为6~15位数字，姓名2~30个字。"; exit 2
    fi
fi
while [ -z "$SID_OPT" ] || [ -z "$NAME_OPT" ]; do
    if [ $GUI -eq 1 ]; then
        out=$(zenity --forms --title="登记实验 · 身份" \
            --text="本课程会记录你在终端里的实验过程（命令与输出），用于平时成绩评定。\n请填写学号和真实姓名：" \
            --add-entry="学号(纯数字)" --add-entry="姓名" 2>/dev/null) || { exit 0; }
        IFS='|' read -r SID NAME <<< "$out"
    else
        echo "本课程会记录你在终端里的实验过程（命令与输出），用于平时成绩评定。"
        read -rp "学号[$SID]: " _s || exit 0
        [ -n "$_s" ] && SID=$_s
        read -rp "姓名[$NAME]: " _n || exit 0
        [ -n "$_n" ] && NAME=$_n
    fi
    SID=$(printf '%s' "$SID" | tr -d '[:space:]')
    NAME=$(printf '%s' "$NAME" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    valid_sid "$SID" && valid_name "$NAME" && break
    if [ $GUI -eq 1 ]; then
        zenity --error --title="格式有误" --text="学号须为6~15位数字，姓名2~30个字。" 2>/dev/null
    else
        echo "学号须为6~15位数字，姓名2~30个字，请重新输入。"
    fi
done

# ---------- 实验目录 ----------
LABS="$LABS_DEFAULT"
if [ -n "$LABS_OPT" ]; then
    [ -d "$LABS_OPT" ] || { err "目录不存在：$LABS_OPT"; exit 2; }
    LABS=$LABS_OPT
    GUI=0          # 已显式指定目录，不再交互确认
else
while :; do
    if [ -n "$LABS" ] && [ -d "$LABS" ]; then
        if [ $GUI -eq 1 ]; then
            zenity --question --title="登记实验 · 实验目录" \
                --text="实验代码目录：\n<b>$LABS</b>\n\n是否正确？" \
                --ok-label="正确，开始登记" --cancel-label="换一个目录" 2>/dev/null && break
        else
            read -rp "实验目录[$LABS]: " _d || exit 0
            [ -z "$_d" ] && break
            LABS=$_d
            continue
        fi
    fi
    if [ $GUI -eq 1 ]; then
        LABS=$(zenity --file-selection --directory --title="选择实验代码目录" 2>/dev/null) || exit 0
    else
        read -rp "请输入实验代码目录: " LABS || exit 0
    fi
    [ -n "$LABS" ] && [ -d "$LABS" ] && break
    err "目录不存在：$LABS"
    LABS=""
done
fi

# ---------- 创建登记 ----------
RUN=$("$LABT_BIN/session.py" begin --sid "$SID" --name "$NAME" --labs "$LABS" --course "$COURSE") || {
    err "登记失败，请把上面的提示发给老师。"
    exit 1
}

printf 'sid=%s\nname=%s\nbound_at=%s\n' "$SID" "$NAME" "$(date '+%F %T')" > "$IDCONF" 2>/dev/null

# 心跳守护（仅在记录期间工作，长时间空闲会自行退出）
if command -v systemctl >/dev/null 2>&1; then
    systemctl --user start labtracker.service 2>/dev/null \
        || nohup "$LABT_BIN/daemon.sh" </dev/null >/dev/null 2>&1 &
else
    nohup "$LABT_BIN/daemon.sh" </dev/null >/dev/null 2>&1 &
fi

# 图形方式下顺手打开一个实验终端；打不开就让学生自己开
if [ $GUI -eq 1 ]; then
    opened=0
    for t in gnome-terminal konsole xfce4-terminal x-terminal-emulator; do
        if command -v "$t" >/dev/null 2>&1; then
            "$t" >/dev/null 2>&1 &
            opened=1
            break
        fi
    done
    if [ $opened -eq 0 ] && command -v xterm >/dev/null 2>&1; then
        xterm -e bash >/dev/null 2>&1 &
    fi
fi

say "登记完成，已开始记录。\n\n学号：$SID\n姓名：$NAME\n登记号：$RUN\n\n接下来请：\n1. 新开一个终端（登记前就开着的终端不会补录）\n2. 在该终端里做实验\n3. 做完后点《提交实验》\n\n记录内容：终端里的命令与输出。不记录屏幕画面，也不记录 sudo 密码。"
exit 0
