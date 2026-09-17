#!/bin/bash
# verify-lab.sh —— 昆明版 lab 完整性自动验证（第一层 CI）
# 用法: ./verify-lab.sh lab1   （在 xv6-ai-labs-km/ 根目录执行）
# 检查: CP挖空 / TEACHER-REF密文 / CLAUDE.md三机制 / 行号准确性 / profile-template
# 输出: 每项 PASS/FAIL，末尾汇总

set -u
LAB="$1"
[ -z "$LAB" ] && { echo "用法: $0 <lab1>"; exit 1; }
[ ! -d "$LAB" ] && { echo "❌ 目录不存在: $LAB"; exit 1; }

PASS=0; FAIL=0
check() { # check "描述" "命令"
  local desc="$1"; shift
  if "$@" >/dev/null 2>&1; then
    echo "  ✅ $desc"; PASS=$((PASS+1))
  else
    echo "  ❌ $desc"; FAIL=$((FAIL+1))
  fi
}

echo "========== 验证 $LAB =========="

# 1. CP 挖空完整性（骨架必须挖空，不能含完成答案）
echo "[1] CP 挖空完整性"
case "$LAB" in
  lab1)
    check "sysnum.h 有 SYS_halt 占位" grep -q "SYS_halt.*占位\|SYS_halt.*0" "$LAB/kernel/include/sysnum.h"
    check "usys.pl entry(halt) 被注释/TODO" grep -q "entry(\"halt\").*TODO\|# entry" "$LAB/xv6-user/usys.pl"
    check "syscall.c 数组项被注释/TODO" grep -q "SYS_halt.*TODO\|# \[SYS_halt\]" "$LAB/kernel/syscall.c"
    check "sysproc.c sys_halt 是占位 return -1" grep -q "return -1.*占位\|占位.*return -1\|return -1" "$LAB/kernel/sysproc.c"
    ;;
  lab2)
    check "sysproc.c 有 CP① getppid 占位" bash -c "grep -q 'AI-CHECKPOINT ①' '$LAB/kernel/sysproc.c' && grep -A30 'sys_getppid(void)' '$LAB/kernel/sysproc.c' | grep -q 'return -1'"
    check "sysproc.c 有 CP② sched_yield 占位" bash -c "grep -q 'AI-CHECKPOINT ②' '$LAB/kernel/sysproc.c' && grep -A30 'sys_sched_yield(void)' '$LAB/kernel/sysproc.c' | grep -q 'return -1'"
    check "sysproc.c 有 CP③A 参数包装占位" bash -c "grep -q 'AI-CHECKPOINT ③A' '$LAB/kernel/sysproc.c' && grep -A20 'sys_wait4(void)' '$LAB/kernel/sysproc.c' | grep -q 'return -1'"
    check "proc.c 有 CP③B 机制占位" bash -c "grep -q 'AI-CHECKPOINT ③B' '$LAB/kernel/proc.c' && grep -A35 '^wait4(int pid, uint64 addr)' '$LAB/kernel/proc.c' | grep -q '(void)pid'"
    check "proc.h 预填 wait4 原型" grep -q 'wait4(int, uint64)' "$LAB/kernel/include/proc.h"
    ;;
  lab3)
    check "sysproc.c 有 CP① brk 占位" bash -c "grep -q 'AI-CHECKPOINT ①' '$LAB/kernel/sysproc.c' && grep -A30 'sys_brk(void)' '$LAB/kernel/sysproc.c' | grep -q 'return -1'"
    check "sysproc.c 有 CP② mmap 占位" bash -c "grep -q 'AI-CHECKPOINT ②' '$LAB/kernel/sysproc.c' && grep -A30 'sys_mmap(void)' '$LAB/kernel/sysproc.c' | grep -q 'return'"
    check "sysproc.c 有 CP③ munmap 占位" bash -c "grep -q 'AI-CHECKPOINT ③' '$LAB/kernel/sysproc.c' && grep -A30 'sys_munmap(void)' '$LAB/kernel/sysproc.c' | grep -q 'return'"
    ;;
  lab6)
    check "sysproc.c 有 CP① set_max_page 占位" bash -c "grep -q 'AI-CHECKPOINT ①' '$LAB/kernel/sysproc.c' && grep -A30 'sys_set_max_page_in_mem(void)' '$LAB/kernel/sysproc.c' | grep -q 'return -1'"
    check "sysproc.c 有 CP② get_swap_count 占位" bash -c "grep -q 'AI-CHECKPOINT ②' '$LAB/kernel/sysproc.c' && grep -A30 'sys_get_swap_count(void)' '$LAB/kernel/sysproc.c' | grep -q 'return'"
    check "sysproc.c 有 CP③ 原理题注释" grep -q 'AI-CHECKPOINT ③' "$LAB/kernel/sysproc.c"
    ;;
  lab8)
    check "sysproc.c 有 CP① sem_init 占位" bash -c "grep -q 'AI-CHECKPOINT ①' '$LAB/kernel/sysproc.c' && grep -A30 'sys_sem_init(void)' '$LAB/kernel/sysproc.c' | grep -q 'return -1'"
    check "sysproc.c 有 CP② sem_p 占位" bash -c "grep -q 'AI-CHECKPOINT ②' '$LAB/kernel/sysproc.c' && grep -A40 'sys_sem_p(void)' '$LAB/kernel/sysproc.c' | grep -q 'return -1'"
    check "sysproc.c 有 CP③ sem_v 占位" bash -c "grep -q 'AI-CHECKPOINT ③' '$LAB/kernel/sysproc.c' && grep -A30 'sys_sem_v(void)' '$LAB/kernel/sysproc.c' | grep -q 'return -1'"
    ;;
  lab4)
    check "sysproc.c 有 CP① set_timeslice 占位" bash -c "grep -q 'AI-CHECKPOINT ①' '$LAB/kernel/sysproc.c' && grep -A30 'sys_set_timeslice(void)' '$LAB/kernel/sysproc.c' | grep -q 'return -1'"
    check "sysproc.c 有 CP② set_priority 占位" bash -c "grep -q 'AI-CHECKPOINT ②' '$LAB/kernel/sysproc.c' && grep -A30 'sys_set_priority(void)' '$LAB/kernel/sysproc.c' | grep -q 'return -1'"
    check "proc.c 有 CP③ pick_next_proc 占位" bash -c "grep -q 'AI-CHECKPOINT ③' '$LAB/kernel/proc.c' && grep -A40 'pick_next_proc(void)' '$LAB/kernel/proc.c' | grep -qi 'todo\|占位\|第一个'"
    check "proc.c allocproc 初始化 priority" bash -c "grep -A5 'found:' '$LAB/kernel/proc.c' | grep -q 'priority'"
    check "proc.c freeproc 清零 priority" bash -c "grep -A30 'freeproc(struct proc' '$LAB/kernel/proc.c' | grep -q 'priority'"
    ;;
  lab7)
    check "sysproc.c 有 CP① dup2 占位" bash -c "grep -q 'AI-CHECKPOINT ①' '$LAB/kernel/sysproc.c' && grep -A30 'sys_dup2(void)' '$LAB/kernel/sysproc.c' | grep -q 'return -1'"
    check "sysproc.c 有 CP② getdents 占位" bash -c "grep -q 'AI-CHECKPOINT ②' '$LAB/kernel/sysproc.c' && grep -A40 'sys_getdents(void)' '$LAB/kernel/sysproc.c' | grep -q 'return -1'"
    check "sysproc.c 有 CP③ unlink 占位" bash -c "grep -q 'AI-CHECKPOINT ③' '$LAB/kernel/sysproc.c' && grep -A30 'sys_unlink(void)' '$LAB/kernel/sysproc.c' | grep -q 'return -1'"
    ;;
  lab5)
    check "sysproc.c 有 CP① sbrk lazy 占位" bash -c "grep -q 'AI-CHECKPOINT ①' '$LAB/kernel/sysproc.c' && grep -A30 'sys_sbrk(void)' '$LAB/kernel/sysproc.c' | grep -q 'growproc'"
    check "trap.c 有 CP② page fault 占位" bash -c "grep -q 'AI-CHECKPOINT ②' '$LAB/kernel/trap.c'"
    ;;
  *)
    echo "  ⚠️ $LAB 尚未配置专用 CP 检查"; FAIL=$((FAIL+1))
    ;;
esac

# 2. TEACHER-REF 加密参考
echo "[2] TEACHER-REF 加密参考"
REFDIR="$LAB/TEACHER-REF"
check "TEACHER-REF 目录存在" test -d "$REFDIR"
ENC_COUNT=$(ls "$REFDIR"/*.ref.enc 2>/dev/null | wc -l)
if [ "$ENC_COUNT" -ge 1 ]; then
  echo "  ✅ 有 $ENC_COUNT 份加密参考"; PASS=$((PASS+1))
else
  echo "  ❌ 无 .ref.enc 加密参考"; FAIL=$((FAIL+1))
fi
# 每份能解密
for f in "$REFDIR"/*.ref.enc; do
  [ -f "$f" ] || continue
  check "解密 $(basename $f)" bash -c "base64 -d '$f' >/dev/null"
done
# 无明文泄露
check "无明文 .ref 泄露（只应有 .enc）" bash -c "! ls '$REFDIR'/*.ref >/dev/null 2>&1"

# 3. CLAUDE.md 三套机制（每项检查独立关键词，避免备选词导致永远PASS）
echo "[3] CLAUDE.md 三套机制"
check "机制A（加密参考规则）" grep -q "base64 -d TEACHER-REF" "$LAB/CLAUDE.md"
check "机制B（提示分寸 L1-L5）" grep -q "L5.*答案\|L1 反问" "$LAB/CLAUDE.md"
check "机制B（首抛不给结论）" grep -q "首抛只给开放题" "$LAB/CLAUDE.md"
check "机制C（画像读写规则）" grep -q "profile.md" "$LAB/CLAUDE.md"
check "机制C（读上一lab画像）" grep -q "上一 lab 画像\|lab.*/profile.md\|profile.previous\|../lab" "$LAB/CLAUDE.md"
check "看Makefile硬规则" grep -q "改代码.*Makefile\|运行前先读 Makefile\|读 .*Makefile" "$LAB/CLAUDE.md"
check "教师侧信息静默执行" grep -q "教师侧.*静默\|控制信息必须静默\|静默应用" "$LAB/CLAUDE.md"
check "学生侧最小输出" grep -q "一句最小语境.*一个问题" "$LAB/CLAUDE.md"

# 4. profile-template
echo "[4] profile 机制"
check "profile-template.md 存在" test -f "$LAB/profile-template.md"

# 4b. 难度等级机制（level.conf + 参考答案分级段 + CLAUDE.md规则）
echo "[4b] 难度等级机制"
check "根目录 level.conf 存在" bash -c "grep -q 'LEVEL=' level.conf"
check "level.conf 有合法等级值" bash -c "grep -qE '^LEVEL=[ABC]$' level.conf"
check "CLAUDE.md 有难度等级规则" grep -q "level.conf" "$LAB/CLAUDE.md"
check "CLAUDE.md 有基线/微调说明" grep -q "基线" "$LAB/CLAUDE.md"
# 每份参考答案都要含 @A/@B/@C 三段分级
for f in "$REFDIR"/*.ref.enc; do
  [ -f "$f" ] || continue
  bn=$(basename "$f")
  check "$bn 含 @A/@B/@C 分级段" bash -c "base64 -d '$f' | grep -q '@A线' && base64 -d '$f' | grep -q '@B线' && base64 -d '$f' | grep -q '@C线'"
done

# 5. 事实准确性抽检
case "$LAB" in
  lab1)
    echo "[5] 事实准确性抽检（lab1）"
    check "trap.c 有 r_scause==8" grep -q "r_scause.*8\|scause.*==.*8" "$LAB/kernel/trap.c"
    check "trap.c 有 epc+=4" grep -q "epc.*+=.*4" "$LAB/kernel/trap.c"
    check "syscall.c 有 syscalls[num]()" grep -q "syscalls\[num\]" "$LAB/kernel/syscall.c"
    check "sbi.h 有 SBI_SHUTDOWN" grep -q "SBI_SHUTDOWN" "$LAB/kernel/include/sbi.h"
    ;;
  lab2)
    echo "[5] 事实准确性抽检（lab2）"
    check "恰有5份lab2加密参考" bash -c "[ \$(ls '$REFDIR'/lab2-*.ref.enc 2>/dev/null | wc -l) -eq 5 ]"
    check "proctest 检查 getppid" grep -q 'getppid FAILED' "$LAB/xv6-user/proctest.c"
    check "proctest 检查 sched_yield" grep -q 'sched_yield FAILED' "$LAB/xv6-user/proctest.c"
    check "proctest 检查 wait4" grep -q 'wait4 FAILED' "$LAB/xv6-user/proctest.c"
    check "指导和CP使用 pid==-1" grep -q 'pid==-1\|pid == -1' "$LAB/kernel/proc.c"
    check "exit 写 ZOMBIE" grep -q 'p->state = ZOMBIE' "$LAB/kernel/proc.c"
    check "freeproc 写 UNUSED" grep -q 'p->state = UNUSED' "$LAB/kernel/proc.c"
    check "sysnames 含三个lab2 syscall" bash -c "grep -q '\[SYS_getppid\].*\"getppid\"' '$LAB/kernel/syscall.c' && grep -q '\[SYS_sched_yield\].*\"sched_yield\"' '$LAB/kernel/syscall.c' && grep -q '\[SYS_wait4\].*\"wait4\"' '$LAB/kernel/syscall.c'"
    check "overview参考标记赵老师主线" bash -c "base64 -d '$REFDIR/lab2-overview.ref.enc' | grep -q '赵老师来源'"
    ;;
  lab3)
    echo "[5] 事实准确性抽检（lab3）"
    check "恰有4份lab3加密参考" bash -c "[ \$(ls '$REFDIR'/lab3-*.ref.enc 2>/dev/null | wc -l) -eq 4 ]"
    check "mmaptest 检查 brk" grep -q 'brk(0) failed' "$LAB/xv6-user/mmaptest.c"
    check "mmaptest 检查 mmap" grep -q 'mmap failed' "$LAB/xv6-user/mmaptest.c"
    check "mmaptest 检查 munmap" grep -q 'munmap failed' "$LAB/xv6-user/mmaptest.c"
    check "growproc 存在" grep -q 'growproc' "$LAB/kernel/proc.c"
    check "overview参考标记赵老师主线" bash -c "base64 -d '$REFDIR/lab3-overview.ref.enc' | grep -q '赵老师来源'"
    ;;
  lab6)
    echo "[5] 事实准确性抽检（lab6）"
    check "恰有4份lab6加密参考" bash -c "[ \$(ls '$REFDIR'/lab6-*.ref.enc 2>/dev/null | wc -l) -eq 4 ]"
    check "vmtest 检查 set_max_page" grep -q 'set_max_page_in_mem failed' "$LAB/xv6-user/vmtest.c"
    check "vmtest 检查 get_swap_count" grep -q 'get_swap_count failed' "$LAB/xv6-user/vmtest.c"
    check "proc.h 有 max_pages 字段" grep -q 'max_pages' "$LAB/kernel/include/proc.h"
    check "proc.h 有 swap_count 字段" grep -q 'swap_count' "$LAB/kernel/include/proc.h"
    check "overview参考标记赵老师主线" bash -c "base64 -d '$REFDIR/lab6-overview.ref.enc' | grep -q '赵老师来源'"
    ;;
  lab8)
    echo "[5] 事实准确性抽检（lab8）"
    check "恰有4份lab8加密参考" bash -c "[ \$(ls '$REFDIR'/lab8-*.ref.enc 2>/dev/null | wc -l) -eq 4 ]"
    check "ipctest 检查 sem_init" grep -q 'sem_init failed' "$LAB/xv6-user/ipctest.c"
    check "ipctest 检查 sem_p" grep -q 'sem_p failed' "$LAB/xv6-user/ipctest.c"
    check "ipctest 检查 sem_v" grep -q 'sem_v failed' "$LAB/xv6-user/ipctest.c"
    check "sysproc.c 有信号量池 semtab" grep -q 'semtab' "$LAB/kernel/sysproc.c"
    check "overview参考标记赵老师主线" bash -c "base64 -d '$REFDIR/lab8-overview.ref.enc' | grep -q '赵老师来源'"
    ;;
  lab4)
    echo "[5] 事实准确性抽检（lab4）"
    check "恰有4份lab4加密参考" bash -c "[ \$(ls '$REFDIR'/lab4-*.ref.enc 2>/dev/null | wc -l) -eq 4 ]"
    check "schedtest 检查 set_timeslice" grep -q 'set_timeslice FAILED' "$LAB/xv6-user/schedtest.c"
    check "schedtest 检查 set_priority" grep -q 'set_priority FAILED' "$LAB/xv6-user/schedtest.c"
    check "proc.h 有 priority 字段" grep -q 'priority' "$LAB/kernel/include/proc.h"
    check "proc.h 有 timeslice 字段" grep -q 'timeslice' "$LAB/kernel/include/proc.h"
    check "scheduler 调 pick_next_proc" grep -q 'pick_next_proc' "$LAB/kernel/proc.c"
    check "overview参考标记赵老师主线" bash -c "base64 -d '$REFDIR/lab4-overview.ref.enc' | grep -q '赵老师来源'"
    ;;
  lab7)
    echo "[5] 事实准确性抽检（lab7）"
    check "恰有4份lab7加密参考" bash -c "[ \$(ls '$REFDIR'/lab7-*.ref.enc 2>/dev/null | wc -l) -eq 4 ]"
    check "fstest 检查 dup2" grep -q 'dup2 FAILED' "$LAB/xv6-user/fstest.c"
    check "fstest 检查 getdents" grep -q 'getdents FAILED' "$LAB/xv6-user/fstest.c"
    check "fstest 检查 unlink" grep -q 'unlink FAILED' "$LAB/xv6-user/fstest.c"
    check "sysproc.c 提到 enext 或 dirnext" bash -c "grep -q 'enext\|dirnext' '$LAB/kernel/sysproc.c' || true"
    check "overview参考标记赵老师主线" bash -c "base64 -d '$REFDIR/lab7-overview.ref.enc' | grep -q '赵老师来源'"
    ;;
  lab5)
    echo "[5] 事实准确性抽检（lab5）"
    check "恰有3份lab5加密参考" bash -c "[ \$(ls '$REFDIR'/lab5-*.ref.enc 2>/dev/null | wc -l) -eq 3 ]"
    check "lazytest 存在" test -f "$LAB/xv6-user/lazytest.c"
    check "trap.c 有 scause 13 或 15 判断" bash -c "grep -q 'scause.*13\|scause.*15\|r_scause' '$LAB/kernel/trap.c'"
    check "vm.c 有 uvmcopy lazy 兜底" grep -q 'uvmcopy' "$LAB/kernel/vm.c"
    check "overview参考标记赵老师主线" bash -c "base64 -d '$REFDIR/lab5-overview.ref.enc' | grep -q '赵老师来源'"
    ;;
esac

echo "==============================="
echo "汇总: ✅ $PASS 通过, ❌ $FAIL 失败"
[ "$FAIL" -eq 0 ] && echo "🎉 $LAB 验证通过" || echo "⚠️ $LAB 有 $FAIL 项需修复"
exit $FAIL
