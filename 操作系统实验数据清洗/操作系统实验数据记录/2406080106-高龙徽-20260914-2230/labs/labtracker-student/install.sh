#!/usr/bin/env bash
# labtracker 安装器（学生版，无需 root，全部装在当前用户目录）
#
# 用法:
#   ./install.sh                     安装/升级（已有数据保留）
#   ./install.sh --labs <路径>        指定实验代码根目录
#   ./install.sh --autostart         同时安装"登录后提醒登记"（默认不装）
#   ./install.sh --no-deps           跳过系统依赖检查
#
# 安装内容:
#   ~/.labtracker/                     程序、状态与本次登记数据
#   ~/.bashrc 末尾标记块                终端接入钩子（未登记时完全不采集）
#   ~/.local/bin/labt-register|labt-submit
#   桌面《登记实验》《提交实验》两个入口
#   可选：~/.config/autostart/ 登录提醒
set -u

SRC="$(cd "$(dirname "$0")" && pwd)"
LABT_HOME="$HOME/.labtracker"
LABS_OPT=""
UPLOAD_URL_OPT=""
UPLOAD_TOKEN_OPT=""
COURSE_OPT=""
AUTOSTART=0
CHECK_DEPS=1

while [ $# -gt 0 ]; do
    case $1 in
        --labs)        LABS_OPT=${2:-}; shift 2 ;;
        --upload-url)  UPLOAD_URL_OPT=${2:-}; shift 2 ;;
        --upload-token) UPLOAD_TOKEN_OPT=${2:-}; shift 2 ;;
        --course)      COURSE_OPT=${2:-}; shift 2 ;;
        --autostart)   AUTOSTART=1; shift ;;
        --no-deps)     CHECK_DEPS=0; shift ;;
        -h|--help)     sed -n '2,15p' "$0"; exit 0 ;;
        *) echo "未知参数: $1" >&2; exit 1 ;;
    esac
done

# ---------- 课程配置（包内 course.conf 由老师提供，按数据解析，不 source）----------
COURSE_CONF="$SRC/course.conf"
conf_get() { [ -f "$COURSE_CONF" ] && sed -n "s/^$1=//p" "$COURSE_CONF" 2>/dev/null | head -1; }

# ---------- 系统依赖 ----------
REQUIRED="bash python3 curl tar gzip flock sha256sum find sed grep awk"
MISSING=""
for c in $REQUIRED; do
    command -v "$c" >/dev/null 2>&1 || MISSING="$MISSING $c"
done
if [ -n "$MISSING" ] && [ $CHECK_DEPS -eq 1 ]; then
    PKGS="util-linux coreutils findutils sed grep gawk curl python3 tar gzip"
    echo "缺少命令:$MISSING"
    echo "需要安装的系统包：$PKGS"
    if command -v apt-get >/dev/null 2>&1; then
        printf '现在安装吗？需要管理员密码 [y/N] '
        read -r a
        case $a in
            y|Y)
                if sudo apt-get install -y $PKGS; then
                    echo "依赖安装完成。"
                else
                    echo "!! 依赖安装失败，请手动安装后重试：sudo apt-get install -y $PKGS" >&2
                    exit 1
                fi ;;
            *) echo "!! 已跳过。缺少依赖时记录或提交可能失败。" ;;
        esac
    else
        echo "!! 请用你的发行版包管理器安装上述命令后重试。" >&2
        exit 1
    fi
fi

# 可选工具提示（不影响核心功能）
command -v zenity >/dev/null 2>&1 || echo "提示：未安装 zenity，将使用终端问答方式（sudo apt-get install -y zenity 可启用图形界面）"

# ---------- 实验目录 ----------
LABS_ROOT="$LABS_OPT"
[ -n "$LABS_ROOT" ] || LABS_ROOT=$(conf_get LABS_ROOT)
if [ -z "$LABS_ROOT" ]; then
    for c in "$HOME/桌面/xv6-ai-labs-km" "$HOME/xv6-ai-labs-km" "$HOME/Desktop/xv6-ai-labs-km"; do
        [ -d "$c" ] && LABS_ROOT="$c" && break
    done
fi

echo "== labtracker 学生版安装 =="
echo "   实验目录: ${LABS_ROOT:-（未指定，登记时可选择）}"

# ---------- 旧版全时录制检测 ----------
if pgrep -f 'labtracker/data/term' >/dev/null 2>&1; then
    echo
    echo "!! 检测到旧版记录程序仍在某些终端里运行。"
    echo "   旧版无法安全热切换，请：先做完当前实验 → 关闭那些终端（或注销重新登录）"
    echo "   → 再重新运行《登记实验》。本安装不会强制结束你的终端。"
    echo
fi

# ---------- 程序文件 ----------
mkdir -p "$LABT_HOME/bin" "$LABT_HOME/state/sock" "$LABT_HOME/data/runs"
cp "$SRC"/src/*.sh "$SRC"/src/*.py "$LABT_HOME/bin/" || { echo "!! 复制程序失败" >&2; exit 1; }
chmod +x "$LABT_HOME/bin/"*
printf '%s\n' "$(cat "$SRC/VERSION" 2>/dev/null || echo 0)" > "$LABT_HOME/VERSION"
echo "   [1/6] 程序文件 → $LABT_HOME/bin"

# ---------- 配置 ----------
CONFIG="$LABT_HOME/config"
if [ ! -f "$CONFIG" ]; then
    : > "$CONFIG"
fi
ensure_kv() {  # ensure_kv KEY VALUE
    local k=$1 v=$2
    [ -n "$v" ] || return 0
    if grep -q "^$k=.\+" "$CONFIG" 2>/dev/null; then
        return 0
    fi
    sed -i "/^$k=/d" "$CONFIG" 2>/dev/null
    printf '%s=%s\n' "$k" "$v" >> "$CONFIG"
}
ensure_kv LABS_ROOT "${LABS_ROOT:-$(conf_get LABS_ROOT)}"
ensure_kv UPLOAD_URL "${UPLOAD_URL_OPT:-$(conf_get UPLOAD_URL)}"
ensure_kv UPLOAD_TOKEN "${UPLOAD_TOKEN_OPT:-$(conf_get UPLOAD_TOKEN)}"
ensure_kv COURSE_NAME "${COURSE_OPT:-$(conf_get COURSE_NAME)}"
chmod 600 "$CONFIG" 2>/dev/null
echo "   [2/6] 配置 → $CONFIG"

# ---------- .bashrc 钩子（幂等）----------
BASHRC="$HOME/.bashrc"
touch "$BASHRC"
if ! grep -q ">>> labtracker >>>" "$BASHRC" 2>/dev/null; then
    cat >> "$BASHRC" <<'EOF'

# >>> labtracker >>>（实验过程记录：只有登记后新开的终端才会被记录）
if [ -n "$PS1" ] && [ -f "$HOME/.labtracker/bin/hook.sh" ]; then
    . "$HOME/.labtracker/bin/hook.sh"
fi
# <<< labtracker <<<
EOF
    echo "   [3/6] .bashrc 已加装钩子（新开的终端生效）"
else
    echo "   [3/6] .bashrc 钩子已存在，跳过"
fi

# ---------- 命令行与桌面入口 ----------
BIN_LINK="$HOME/.local/bin"
mkdir -p "$BIN_LINK"
ln -sf "$LABT_HOME/bin/register.sh" "$BIN_LINK/labt-register"
ln -sf "$LABT_HOME/bin/submit.sh"   "$BIN_LINK/labt-submit"
ln -sf "$LABT_HOME/bin/submit.sh"   "$BIN_LINK/submit"
ln -sf "$LABT_HOME/bin/replay.sh"   "$BIN_LINK/labt-replay"

DESKTOP_DIR=$(xdg-user-dir DESKTOP 2>/dev/null || echo "")
if [ ! -d "$DESKTOP_DIR" ]; then
    for c in "$HOME/桌面" "$HOME/Desktop"; do
        [ -d "$c" ] && DESKTOP_DIR=$c && break
    done
fi
[ -d "$DESKTOP_DIR" ] || DESKTOP_DIR="$HOME"
write_desktop() {  # write_desktop 文件名 名称 说明 目标
    cat > "$DESKTOP_DIR/$1" <<EOF
[Desktop Entry]
Type=Application
Name=$2
Comment=$3
Exec=$4
Icon=utilities-terminal
Terminal=false
EOF
    chmod +x "$DESKTOP_DIR/$1"
    gio set "$DESKTOP_DIR/$1" metadata::trusted true 2>/dev/null || true
}
write_desktop "登记实验.desktop" "登记实验" "填写身份并开始记录实验过程" "$LABT_HOME/bin/register.sh"
write_desktop "提交实验.desktop" "提交实验" "停止记录、打包并上传本次实验" "$LABT_HOME/bin/submit.sh"
echo "   [4/6] 命令 labt-register / labt-submit，桌面《登记实验》《提交实验》"

# ---------- 登录提醒（可选，默认不装）----------
AUTOSTART_FILE="$HOME/.config/autostart/labtracker-reminder.desktop"
rm -f "$HOME/.config/autostart/labtracker-identity.desktop" 2>/dev/null
if [ $AUTOSTART -eq 1 ]; then
    mkdir -p "$HOME/.config/autostart"
    cat > "$AUTOSTART_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=实验记录提醒
Exec=$LABT_HOME/bin/remind.sh
X-GNOME-Autostart-enabled=true
NoDisplay=true
EOF
    echo "   [5/6] 已安装登录提醒（只提醒，不会自动开始记录）"
else
    rm -f "$AUTOSTART_FILE" 2>/dev/null
    echo "   [5/6] 未安装登录自启动（需要时: $0 --autostart）"
fi

# ---------- 心跳服务（登记时才启动，不随登录启动）----------
UNIT_DIR="$HOME/.config/systemd/user"
mkdir -p "$UNIT_DIR"
cp "$SRC/assets/labtracker.service" "$UNIT_DIR/labtracker.service"
if command -v systemctl >/dev/null 2>&1; then
    systemctl --user daemon-reload 2>/dev/null || true
    systemctl --user disable labtracker.service 2>/dev/null || true
    echo "   [6/6] 心跳服务已就位（登记时自动启动，不会开机常驻）"
else
    echo "   [6/6] 无 systemd，心跳由登记时后台启动"
fi

echo
echo "安装完成。接下来："
echo "  1. 双击桌面《登记实验》（或终端运行 labt-register）"
echo "  2. 登记完成后【新开一个终端】做实验（登记前就开着的终端不会补录）"
echo "  3. 做完后双击桌面《提交实验》"
echo "  4. 想卸载：bash $SRC/uninstall.sh"
