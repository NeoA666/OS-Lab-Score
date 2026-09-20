#!/usr/bin/env bash
# 学生入口：submit（首次运行会自动完成安装，无需手动配置）
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
LABT_HOME="$HOME/.labtracker"
PKG_VER=$(cat "$HERE/VERSION" 2>/dev/null || echo 0)
CUR_VER=$(cat "$LABT_HOME/VERSION" 2>/dev/null || echo '')
if [ ! -f "$LABT_HOME/bin/submit.sh" ] || [ "$PKG_VER" != "$CUR_VER" ]; then
    echo "正在准备实验记录程序（首次运行需要一点时间）..."
    bash "$HERE/install.sh" || { echo "安装未完成，请把上面的提示发给老师。" >&2; exit 1; }
fi
exec bash "$LABT_HOME/bin/submit.sh" "$@"
