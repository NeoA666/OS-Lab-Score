#!/usr/bin/env bash
# labtracker 卸载器
# 用法: ./uninstall.sh           停用并保留已登记数据
#       ./uninstall.sh --purge   连同全部登记数据一起删除
set -u
LABT_HOME="$HOME/.labtracker"
PURGE=0
[ "${1:-}" = "--purge" ] && PURGE=1

systemctl --user disable --now labtracker.service 2>/dev/null || true
rm -f "$HOME/.config/systemd/user/labtracker.service"
systemctl --user daemon-reload 2>/dev/null || true
rm -f "$HOME/.config/autostart/labtracker-reminder.desktop" \
      "$HOME/.config/autostart/labtracker-identity.desktop"
rm -f "$HOME/.local/bin/submit" "$HOME/.local/bin/labt-replay" \
      "$HOME/.local/bin/labt-register" "$HOME/.local/bin/labt-submit"

DESKTOP_DIR=$(xdg-user-dir DESKTOP 2>/dev/null || echo "$HOME/桌面")
rm -f "$DESKTOP_DIR/登记实验.desktop" "$DESKTOP_DIR/提交实验.desktop"

# 去掉 .bashrc 标记块（含首尾标记行）
if [ -f "$HOME/.bashrc" ]; then
    python3 - "$HOME/.bashrc" <<'EOF'
import sys
p = sys.argv[1]
s = open(p, encoding='utf-8').read()
a = s.find('# >>> labtracker >>>')
b = s.find('# <<< labtracker <<<')
if a != -1 and b != -1:
    open(p, 'w', encoding='utf-8').write(s[:a] + s[b + len('# <<< labtracker <<<'):].lstrip('\n'))
    print(".bashrc 钩子已移除")
EOF
fi

if [ $PURGE -eq 1 ]; then
    rm -rf "$LABT_HOME"
    echo "已删除全部程序与登记数据。"
else
    echo "已停用。登记数据保留在 $LABT_HOME/data/runs（彻底删除: $0 --purge）"
fi
