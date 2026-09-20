# lab8：IPC + 信号量（sem_init / sem_p / sem_v）

新增 3 个信号量 syscall（基于 xv6 sleep/wakeup）。完整测例（生产者-消费者/哲学家）放支线 CP⑤。

## 怎么开始

1. **先过 lab0~7**
2. 读 `实验指导.md` 了解 sleep/wakeup + 信号量原语
3. 按 `AI-CHECKPOINT` 顺序做题：
   - **主线 CP①~③**（必做）：`sys_sem_init` → `sys_sem_p` → `sys_sem_v`（都在 `kernel/sysproc.c`）
   - **支线 CP⑤**（可选）：生产者-消费者/哲学家测例 + oscomp + 平台
4. 用 Claude Code 辅助：进目录自动加载 `CLAUDE.md`
5. 验收：跑 `ipctest`，子进程应阻塞到父 sem_v 后才继续

## 文件说明

| 文件 | 用途 |
|------|------|
| `实验指导.md` | 任务说明 + 信号量原理 + sleep/wakeup |
| `CLAUDE.md` | AI 行为约束 |
| `kernel/sysproc.c` | CP①②③（sem_init/p/v）+ 全局 semtab 信号量池 |
| `kernel/include/sysnum.h` / `syscall.c` / `xv6-user/usys.pl` / `user.h` | 链路（预填） |
| `xv6-user/ipctest.c` | 验收程序（父子同步） |
| `Makefile` | 构建 + 跑 + fs 入口 |

## 退出 qemu

`Ctrl+A` 然后按 `X`。

## 验收

- **主线**：`-> / $ ipctest` → 子阻塞→父 V→子继续→"lab8 test passed"
- **支线**：oscomp 测例在希冀平台拿分
