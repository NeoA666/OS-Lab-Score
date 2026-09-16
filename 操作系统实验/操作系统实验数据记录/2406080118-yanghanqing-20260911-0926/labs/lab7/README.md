# lab7：文件系统——dup2 / getdents / unlink

添加 3 个文件相关 syscall：`dup2`（复制 fd）/ `getdents`（读目录）/ `unlink`（删文件）。链路预填，学生聚焦 `sysproc.c` 实现，复用现有 filedup/enext/eremove。不挖 fat32 核心。

## 怎么开始

1. **先过 lab0~6**
2. 读 `实验指导.md` 了解 xv6-k210 文件系统（dirent/file/ofile）
3. 按 `AI-CHECKPOINT` 顺序做题：
   - **主线 CP①~③**（必做）：`sys_dup2` → `sys_getdents` → `sys_unlink`（都在 `kernel/sysproc.c`）
   - **支线 CP⑤**（可选）：oscomp 14 测例全量适配 + 平台提交
4. 用 Claude Code 辅助：进目录自动加载 `CLAUDE.md`
5. 验收：跑 `fstest`（CP① dup2）+ 手动测 getdents/unlink

## 文件说明

| 文件 | 用途 |
|------|------|
| `实验指导.md` | 任务说明 + FS 结构 + 验收 |
| `CLAUDE.md` | AI 行为约束 |
| `kernel/sysproc.c` | CP①②③（sys_dup2 / sys_getdents / sys_unlink） |
| `kernel/include/sysnum.h` / `syscall.c` / `xv6-user/usys.pl` / `user.h` | 链路（预填） |
| `xv6-user/fstest.c` | 验收程序（dup2） |
| `Makefile` | 构建 + 跑 + fs 入口 |

## 退出 qemu

`Ctrl+A` 然后按 `X`。

## 验收

- **主线**：`-> / $ fstest` → "lab7 dup2 test passed"；getdents/unlink 手动测
- **支线**：oscomp 14 测例在希冀平台拿分
