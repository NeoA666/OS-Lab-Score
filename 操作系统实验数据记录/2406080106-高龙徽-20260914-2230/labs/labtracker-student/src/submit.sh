#!/usr/bin/env bash
# labtracker 提交入口（学生用）
#
# 顺序严格固定：先停止采集 → 冻结快照 → 打包 → 上传 → 只有上传核验成功才结束登记。
# 上传失败保留同一个包，再点一次《提交实验》就是重传同一份字节，不会重新打包。
set -u

LABT_HOME="$HOME/.labtracker"
LABT_BIN="$LABT_HOME/bin"
CONFIG="$LABT_HOME/config"
STATE_FILE="$LABT_HOME/state/current.state"

LABS_ROOT=$(sed -n 's/^LABS_ROOT=//p' "$CONFIG" 2>/dev/null | head -1)
UPLOAD_URL=$(sed -n 's/^UPLOAD_URL=//p' "$CONFIG" 2>/dev/null | head -1)
UPLOAD_TOKEN=$(sed -n 's/^UPLOAD_TOKEN=//p' "$CONFIG" 2>/dev/null | head -1)
DESKTOP=$(xdg-user-dir DESKTOP 2>/dev/null || echo "")
if [ ! -d "$DESKTOP" ]; then
    for c in "$HOME/桌面" "$HOME/Desktop"; do
        [ -d "$c" ] && DESKTOP=$c && break
    done
fi
[ -d "$DESKTOP" ] || DESKTOP="$HOME"

MAX_UPLOAD_BYTES=$((500 * 1024 * 1024))

GUI=0
command -v zenity >/dev/null 2>&1 \
    && { [ -n "${DISPLAY:-}" ] || [ -n "${WAYLAND_DISPLAY:-}" ]; } && GUI=1

say()  { if [ $GUI -eq 1 ]; then zenity --info --title="提交实验" --text="$1" 2>/dev/null; else echo "$1"; fi; }
die()  { if [ $GUI -eq 1 ]; then zenity --error --title="提交实验" --text="$1" 2>/dev/null; else echo "错误: $1" >&2; fi; exit 1; }
ask()  {
    [ "${LABT_ASSUME_YES:-0}" = "1" ] && return 0
    if [ $GUI -eq 1 ]; then
        zenity --question --title="提交实验" --text="$1" --ok-label="确认提交" --cancel-label="取消" 2>/dev/null
    else
        printf '%s [y/N] ' "$1"
        read -r a
        case $a in y|Y|yes) return 0;; *) return 1;; esac
    fi
}

st() { sed -n "s/^$1=//p" "$STATE_FILE" 2>/dev/null | head -1; }

STATE=$(st state); [ -n "$STATE" ] || STATE=idle
RUN_ID=$(st run_id); RUN_DIR=$(st run_dir)
SID=$(st sid); NAME=$(st name)

case $STATE in
    idle)     die "没有进行中的登记。请先点《登记实验》。" ;;
    finished) say "上一次登记已经结束（$(st finished_at)）。\n\n需要继续做实验的话，请先点《登记实验》。"; exit 0 ;;
esac
[ -n "$RUN_DIR" ] && [ -d "$RUN_DIR" ] || die "登记数据目录丢失，请把这条信息发给老师。"

# ---------- 1. 停止采集（建立冻结屏障）----------
if [ "$STATE" = "recording" ]; then
    ask "即将停止记录并提交本次实验。\n\n停止记录不会关闭你的终端，也不会打断正在运行的程序，但之后新执行的命令不再计入本次记录。\n\n确认提交？" \
        || { say "已取消，记录继续。"; exit 0; }
    "$LABT_BIN/session.py" freeze >/dev/null || die "停止记录失败，请重试或把提示发给老师。"
    STATE=freezing
fi

# ---------- 2. 通知各终端代理停写并确认落盘 ----------
PROXY_JSON=$("$LABT_BIN/session.py" stop-proxies --run-dir "$RUN_DIR" 2>/dev/null || echo '{}')
PROXY_NOTE=$(printf '%s' "$PROXY_JSON" | python3 -c '
import json,sys
try: d=json.load(sys.stdin)
except Exception: d={}
bad=[]
if d.get("failed"): bad.append("%d 个终端未确认停止写日志" % len(d["failed"]))
if d.get("growing"): bad.append("%d 个录像文件仍在增长" % len(d["growing"]))
print("；".join(bad))
' 2>/dev/null)

# ---------- 3. 冻结快照与打包（已有包则原样复用）----------
SUB_DIR="$RUN_DIR/submit"
mkdir -p "$SUB_DIR"
PKG=$(ls -1 "$SUB_DIR"/*-实验提交-*.tar.gz 2>/dev/null | head -1)

if [ -z "$PKG" ]; then
    STAGE="$SUB_DIR/staging"
    rm -rf "$STAGE"
    mkdir -p "$STAGE/logs" "$STAGE/term" "$STAGE/transcripts"

    # 3a. 本次登记的日志与录像（已经是冻结状态）
    for f in events.jsonl events.mirror.jsonl .chainstate identity run.conf; do
        [ -f "$RUN_DIR/$f" ] && cp -p "$RUN_DIR/$f" "$STAGE/logs/"
    done
    cp -a "$RUN_DIR"/capture "$STAGE/logs/" 2>/dev/null || true
    cp -a "$RUN_DIR"/term/. "$STAGE/term/" 2>/dev/null || true
    find "$STAGE/term" -name '*.out' -exec gzip -f {} \; 2>/dev/null
    find "$STAGE/term" -name '*.tim' -exec gzip -f {} \; 2>/dev/null

    # 3b. 实验代码：复制前后各记一次文件指纹，检测复制期间是否仍在改动
    LABS=$(st labs_root)
    [ -n "$LABS" ] || LABS="$LABS_ROOT"
    CODE_CHANGED=0
    if [ -n "$LABS" ] && [ -d "$LABS" ]; then
        mkdir -p "$STAGE/labs"
        __labt_fingerprint() {
            find "$LABS" -type f ! -path '*/.git/*' \
                -printf '%p\t%s\t%T@\n' 2>/dev/null | sort | sha256sum | cut -d' ' -f1
        }
        FP1=$(__labt_fingerprint)
        for lab in "$LABS"/lab*/; do
            [ -d "$lab" ] || continue
            labname=$(basename "$lab")
            tar -C "$LABS" \
                --exclude='*.o' --exclude='*.d' --exclude='fs.img' \
                --exclude='*.bin' --exclude='*.asm' --exclude='*.sym' \
                --exclude='kernel/kernel' --exclude='target' \
                -cf - "$labname" 2>/dev/null | tar -C "$STAGE/labs" -xf - 2>/dev/null
        done
        find "$STAGE/labs" \( -name '*.o' -o -name '*.d' -o -name 'fs.img' \
            -o -name '*.bin' -o -name '*.asm' -o -name '*.sym' \
            -o -path '*/kernel/kernel' \) -type f -delete 2>/dev/null
        FP2=$(__labt_fingerprint)
        [ "$FP1" = "$FP2" ] || CODE_CHANGED=1
    else
        echo "未找到实验代码目录：$LABS" > "$STAGE/无实验代码.txt"
    fi

    if [ $CODE_CHANGED -eq 1 ]; then
        # 采集已停止，但不打包一份前后不一致的代码
        "$LABT_BIN/session.py" pending --error "实验代码在打包期间发生变化" >/dev/null 2>&1
        die "检测到实验代码在打包过程中被修改。\n\n请先保存好文件、停止正在写文件的程序，再点一次《提交实验》。\n（记录已停止，不会再采集新的操作。）"
    fi

    # 3c. 文本转录
    for outgz in "$STAGE"/term/*.out.gz; do
        [ -e "$outgz" ] || continue
        base=$(basename "$outgz" .out.gz)
        timgz="$STAGE/term/$base.tim.gz"
        python3 "$LABT_BIN/transcript.py" "$outgz" "$timgz" \
            -o "$STAGE/transcripts/$base.txt" 2>/dev/null || true
    done

    # 3d. 过程摘要（只读本次登记的数据）
    python3 "$LABT_BIN/report.py" --data "$RUN_DIR" -o "$STAGE/摘要-过程报告.md" 2>/dev/null \
        || echo "摘要生成失败（不影响其余内容提交）" > "$STAGE/摘要-过程报告.md"

    # 3e. 清单与打包
    ( cd "$STAGE" && find . -type f ! -name MANIFEST.sha256 -print0 \
        | sort -z | xargs -0 sha256sum > MANIFEST.sha256 ) || die "生成校验清单失败。"

    SAFE_NAME=$(printf '%s' "$NAME" | tr -d '/' | tr -d '\n\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    [ -n "$SAFE_NAME" ] || SAFE_NAME="学生"
    STAMP=$(date +%Y%m%d-%H%M)
    PKG_NAME="${SID}-${SAFE_NAME}-实验提交-${STAMP}.tar.gz"
    PKG="$SUB_DIR/$PKG_NAME"
    tar czf "$PKG" -C "$STAGE" . || die "打包失败。"
    PKGSZ=$(stat -c%s "$PKG")
    if [ "$PKGSZ" -gt "$MAX_UPLOAD_BYTES" ]; then
        "$LABT_BIN/session.py" pending --error "提交包超过 500MB" >/dev/null 2>&1
        die "提交包超过 500MB（$(du -h "$PKG" | cut -f1)），无法上传。\n\n请把文件手动交给老师：$PKG"
    fi
    sha256sum "$PKG" | cut -d' ' -f1 > "$SUB_DIR/pkg.sha256"
    printf 'name=%s\nsize=%s\nbuilt_at=%s\n' "$PKG_NAME" "$PKGSZ" "$(date '+%F %T')" > "$SUB_DIR/pkg.meta"

    # 桌面上放一份方便手动上交（目录内不覆盖同名文件）
    OUTDIR="$DESKTOP/实验提交包"
    mkdir -p "$OUTDIR" 2>/dev/null && cp -f "$PKG" "$OUTDIR/$PKG_NAME" 2>/dev/null || true
fi

PKG_SHA=$(cat "$SUB_DIR/pkg.sha256" 2>/dev/null || sha256sum "$PKG" | cut -d' ' -f1)
PKGSZ=$(stat -c%s "$PKG" 2>/dev/null || echo 0)

# ---------- 4. 上传（严格核验；失败保留待提交，不结束登记）----------
UPLOAD_STATUS="未配置上传服务器"
UPLOAD_DETAIL="请把提交包手动交给老师。"
UPLOAD_OK=0

if [ -n "$UPLOAD_URL" ] && [ -n "$UPLOAD_TOKEN" ] && command -v curl >/dev/null 2>&1; then
    BODY=$(mktemp /tmp/labt-resp.XXXXXX)
    trap 'rm -f "$BODY"' EXIT
    HTTP=$(curl -sS -o "$BODY" -w '%{http_code}' --connect-timeout 10 -m 900 \
        -H "X-Upload-Token: $UPLOAD_TOKEN" \
        -F "file=@$PKG" -F "sha256=$PKG_SHA" \
        "$UPLOAD_URL/upload" 2>/dev/null)
    if [ "$HTTP" = "200" ] && "$LABT_BIN/session.py" verify-upload --expect-sha "$PKG_SHA" < "$BODY" 2>/dev/null; then
        UPLOAD_OK=1
        UPLOAD_STATUS="✅ 已上传到课程服务器"
        UPLOAD_DETAIL="服务器已收到 $(basename "$PKG")，sha256 核对一致。"
    else
        REASON=$(head -c 200 "$BODY" 2>/dev/null | tr -d '\n')
        UPLOAD_STATUS="⚠ 上传未成功"
        UPLOAD_DETAIL="HTTP=$HTTP $REASON"
    fi
else
    UPLOAD_DETAIL="未配置上传地址或令牌，请把提交包手动交给老师。"
fi

# ---------- 5. 结束登记或保留待提交 ----------
if [ $UPLOAD_OK -eq 1 ]; then
    "$LABT_BIN/session.py" finish >/dev/null || die "登记状态写入失败，请把这条信息发给老师。"
    FINAL_STATE="finished"
else
    "$LABT_BIN/session.py" pending --error "$UPLOAD_STATUS $UPLOAD_DETAIL" >/dev/null 2>&1
    FINAL_STATE="pending_upload"
fi

# ---------- 6. 结果 ----------
RESULT="## 提交结果

- 学号姓名：$SID $NAME
- 提交包：$(basename "$PKG")（$(du -h "$PKG" 2>/dev/null | cut -f1)）
- 位置：$SUB_DIR
- 上传：$UPLOAD_STATUS
  $UPLOAD_DETAIL
"
[ -n "${PROXY_NOTE:-}" ] && RESULT="$RESULT- 记录完整性提示：$PROXY_NOTE

"

if [ "$FINAL_STATE" = "finished" ]; then
    RESULT="$RESULT
记录已停止，本次登记已结束。下次做实验请重新点《登记实验》。
"
else
    RESULT="$RESULT
记录已停止，但**登记尚未结束**。
再点一次《提交实验》即可重传同一份包（不会重新打包，内容完全一致）。
"
fi

if [ $GUI -eq 1 ]; then
    printf '%s' "$RESULT" > /tmp/labt-result.$$.md
    zenity --text-info --title="提交实验" --width=680 --height=460 \
        --filename=/tmp/labt-result.$$.md 2>/dev/null
    rm -f /tmp/labt-result.$$.md
else
    echo
    printf '%s\n' "$RESULT"
fi
exit 0
