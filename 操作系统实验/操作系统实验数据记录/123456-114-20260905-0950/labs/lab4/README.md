# lab4：调度算法——RR / priority

修改 xv6 调度策略：添加 `set_timeslice` / `set_priority` syscall + `struct proc` 字段，实现 priority 调度（改 `pick_next_proc`）。机制（swtch/锁）不动，只动策略。

## 怎么开始

1. **先过 lab0~3**
2. 读 `实验指导.md` 了解 scheduler 和机制/策略分离
3. 按 `AI-CHECKPOINT` 顺序做题：
   - **主线 CP①~③**（必做）：`sys_set_timeslice` → `sys_set_priority` → `pick_next_proc`（priority 调度）
   - **支线 CP⑤**（可选）：MLFQ + oscomp 适配 + 平台提交
4. 用 Claude Code 辅助：进目录自动加载 `CLAUDE.md`
5. 验收：跑 `schedtest`，观察 priority 1 先完成

## 文件说明

| 文件 | 用途 |
|------|------|
| `实验指导.md` | 任务说明 + 知识点 + 验收 |
| `CLAUDE.md` | AI 行为约束 |
| `kernel/sysproc.c` | CP①②（sys_set_timeslice / sys_set_priority） |
| `kernel/proc.c` | CP③（pick_next_proc 调度策略） |
| `kernel/include/proc.h` | struct proc 加 timeslice/priority 字段 |
| `kernel/include/sysnum.h` / `syscall.c` / `xv6-user/usys.pl` / `user.h` | 链路（预填） |
| `xv6-user/schedtest.c` | 验收程序 |
| `Makefile` | 构建 + 跑 + fs 入口 |

## 退出 qemu

`Ctrl+A` 然后按 `X`。

## 验收

- **主线**：`-> / $ schedtest` → priority 1 先完成
- **支线**：oscomp 测例在希冀平台拿分
