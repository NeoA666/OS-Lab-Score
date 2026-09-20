# lab6：页面替换算法（FIFO / LRU）

主线添加 `set_max_page_in_mem` / `get_swap_count` syscall（CP①②）+ 讨论 FIFO/LRU 原理（CP③）。完整 swap 子系统放支线 CP⑤（大工程选做）。

## 怎么开始

1. **先过 lab0~5**
2. 读 `实验指导.md` 了解页面替换原理
3. 按 `AI-CHECKPOINT` 顺序做题：
   - **主线 CP①~③**（必做）：`sys_set_max_page_in_mem` → `sys_get_swap_count`（sysproc.c）+ CP③ 原理讨论
   - **支线 CP⑤**（可选）：完整 swap 子系统 + oscomp + 平台
4. 用 Claude Code 辅助：进目录自动加载 `CLAUDE.md`
5. 验收：跑 `vmtest`，看到 "lab6 test passed"

## 文件说明

| 文件 | 用途 |
|------|------|
| `实验指导.md` | 任务说明 + 页面替换原理 |
| `CLAUDE.md` | AI 行为约束 |
| `kernel/sysproc.c` | CP①②③（set_max_page_in_mem / get_swap_count / FIFO-LRU 原理） |
| `kernel/include/proc.h` | struct proc 加 max_pages/swap_count 字段 |
| `kernel/include/sysnum.h` / `syscall.c` / `xv6-user/usys.pl` / `user.h` | 链路（预填） |
| `xv6-user/vmtest.c` | 验收程序 |
| `Makefile` | 构建 + 跑 + fs 入口 |

## 退出 qemu

`Ctrl+A` 然后按 `X`。

## 验收

- **主线**：`-> / $ vmtest` → "lab6 test passed"（CP①②）+ CP③ 原理答对
- **支线**：oscomp 测例在希冀平台拿分（完整 swap + FIFO/LRU）
