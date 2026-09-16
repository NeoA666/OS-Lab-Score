# lab3：内存分配管理——brk / mmap / munmap

新增 3 个内存管理 syscall：`brk`（heap 顶语义）/ `mmap`（匿名映射简化版）/ `munmap`（解除映射）。链路预填，学生聚焦 `sysproc.c` 实现（复用 growproc）。

## 怎么开始

1. **先过 lab0~2**（环境 + syscall 链路 + 进程管理）
2. 读 `实验指导.md` 了解进程地址空间和任务
3. 按 `AI-CHECKPOINT` 顺序做题：
   - **主线 CP①~③**（必做）：`sys_brk` → `sys_mmap` → `sys_munmap`（都在 `kernel/sysproc.c`）
   - **支线 CP⑤**（可选）：mmap 文件映射（完整 VMA 版）+ oscomp 适配 + 平台提交
4. 用 Claude Code 辅助：进目录自动加载 `CLAUDE.md`，AI 先问后写
5. 验收：在 shell 跑 `mmaptest`，看到 "lab3 test passed"

## 文件说明

| 文件 | 用途 |
|------|------|
| `实验指导.md` | 任务说明 + 知识点 + 验收（学生主读） |
| `CLAUDE.md` | AI 行为约束（主线 5 硬规则 + CP⑤ 支线） |
| `kernel/sysproc.c` | CP①②③ 挖空（sys_brk / sys_mmap / sys_munmap） |
| `kernel/include/sysnum.h` | 3 个新 syscall 号（预填） |
| `kernel/syscall.c` | dispatch（预填） |
| `xv6-user/usys.pl` + `user.h` | stub + 原型（预填） |
| `xv6-user/mmaptest.c` | 验收程序（跑 `mmaptest`） |
| `Makefile` | 构建 + 跑 + fs 入口 |

## 退出 qemu

`Ctrl+A` 然后按 `X`。

## 验收

- **主线**：`-> / $ mmaptest` → "lab3 test passed"
- **支线**：oscomp 测例在希冀平台拿分（CP⑤ 完整 mmap + VMA）
