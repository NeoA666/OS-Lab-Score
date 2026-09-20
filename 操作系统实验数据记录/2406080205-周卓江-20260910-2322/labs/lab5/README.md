# lab5：懒分配 + COW

改 xv6 内存分配：CP① sys_sbrk lazy（不立即分配）+ CP② page fault lazy 分支（访问时分配）。COW 作为支线。**CP①② 配套**——只改一个系统 crash。

## 怎么开始

1. **先过 lab0~4**
2. 读 `实验指导.md` 了解 lazy 原理 + page fault
3. 按 `AI-CHECKPOINT` 顺序做题：
   - **主线 CP①②**（必做，配套）：`sys_sbrk`（sysproc.c）改 lazy + `usertrap`（trap.c）加 lazy 分支
   - **支线 CP⑤**（可选）：COW + getpgcnt + oscomp + 平台
4. 用 Claude Code 辅助：进目录自动加载 `CLAUDE.md`，AI 先问后改
5. 验收：跑 `lazytest`，看到 "lab5 test passed"

## 文件说明

| 文件 | 用途 |
|------|------|
| `实验指导.md` | 任务说明 + lazy 原理 + 验收 |
| `CLAUDE.md` | AI 行为约束（修改题模式 + 配套要求） |
| `kernel/sysproc.c` | CP①（sys_sbrk 改 lazy） |
| `kernel/trap.c` | CP②（usertrap 加 lazy 分支） |
| `xv6-user/lazytest.c` | 验收程序 |
| `Makefile` | 构建 + 跑 + fs 入口 |

## 退出 qemu

`Ctrl+A` 然后按 `X`。

## 验收

- **主线**：`-> / $ lazytest` → "lab5 test passed"（CP①② 配套完成）
- **支线**：oscomp 测例在希冀平台拿分（COW + getpgcnt）

## ⚠️ 关键

CP①② **配套**——只改 CP①（sbrk lazy）不改 CP②（page fault lazy），sbrk 后访问 crash。两个一起改。
