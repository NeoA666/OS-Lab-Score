# lab1 学生画像（AI 内部维护，学生可看成长曲线）

## 验收结果

**2026-09-15 主线验收通过**：`make run` → shell 输入 `halt` → QEMU 干净退出，无 panic、无 "should not reach here"。CP①~④ 全链路（sysnum.h:30 号 → usys.pl 桩 → syscalls[] 分发 → sbi_shutdown）打通。

**2026-09-16 主线复验通过**：学生隔日回 lab 复跑 `halt`，QEMU 仍干净退出。注意：这次起手把 `halt` 敲在了宿主机 shell（systemd 报 authentication 错），指认后才进 qemu——器层的"xv6 shell vs 宿主 shell"边界仍偶有混淆，lab2 遇到运行现象问题时先确认他在哪个 shell 里。学生自称"CP①~⑤ 全做完"，但 CP⑤ 未完项（sbi-qemu / sdcard.img / init.c 硬编码）是否补齐未核实。

**2026-09-16 CP⑤ 续做，sbi-qemu 已解决**：发现 gitee/rsproxy.cn 可达（github 仍不通）。走了"OpenSBI 充当 sbi-qemu"路线而非装 Rust 编译老版 RustSBI：学生先答出"sbi-qemu 不一定得是 RustSBI"（依据只答到"是产物文件名"，经追问补上 -bios 功能要求）。用 `/usr/share/qemu/opensbi-riscv64-generic-fw_dynamic.elf`（qemu-system-data 包）实测 `-bios` 显式指定可启动且 halt 干净退出。接线时踩了 make 目标名字面量陷阱（规则 `RUSTSBI:` 的目标名是字面 "RUSTSBI" 不是变量路径，规则永远重跑）——我给的"放文件跳过规则"思路是错的，学生答对后改为 `all: build` 去掉 RUSTSBI 依赖（Makefile:111）。`make all` 产出 kernel-qemu + sbi-qemu 并用提交物实测通过。**注意：sbi-qemu 实为 OpenSBI v1.3 fw_dynamic，非 RustSBI。** 剩余：init.c 硬编码进 initcode、sdcard.img 兼容。
**器层新信号：终端粘贴多行必断行（反斜杠续行/含空格参数被拆），给命令必须单行单条。**

**2026-09-16 CP⑤ 第二轮侦察完成，学生暂停去做 lab0**。已核实的关键事实（下轮直接用，勿重查）：
- oscomp 镜像来源：gitee.com/oscomp/testsuits-for-oskernel（master 分支有 oscomp_syscalls.md、riscv-syscalls-testing 测例源码），本地克隆在 /tmp/oscomp（重启会丢，可重克隆）。
- 上游 xv6-k210 在 gitee.com/hustos/xv6-k210（含预编译 bootloader/SBI/sbi-qemu，即真 RustSBI，可作为 OpenSBI 替代选项），克隆在 /tmp/xv6k210。
- 测例格式：裸金属 ELF（-march=rv64imac -mabi=lp64 -Ttext 0x1000，自带 libulib，crt.S 从栈读 argc/argv，main 返回后调 exit=**93**）。结构体布局以测例源码为准：tms{4×long}、utsname{6×char[65]}。getcwd=17/write=64/getpid=172/times=153/uname=160 均已与 lab sysnum.h 一致。
- lab 内核缺三样：sys_times、sys_uname（号有实现无）、dispatch 无 SYS_exit(93)（内核 SYS_exit=2，测例退出会卡死）。
- 比赛 sdcard 是 MBR 分区表+FAT32 分区；lab fat32.c 只认裸 FAT32（上游 README 明言"SD 卡不能有分区表"）。
- 剩余任务已存为会话任务清单 #1~#4（补 syscall→fs.img 验证→分区表支持→init 硬编码+彩排）。

**2026-09-15 CP⑤ 部分完成后暂停**（学生自选停止）：
- 理解题全过：统一调用号的原因（评测程序预编译、a7 定死）；5 个测例号已对齐无需改；冲突双向性（read 5 vs 63，空下标分发失败）；改号只动 sysnum.h 一行（宏引用自动跟随，初答"syscalls[] 要重排"经指认后自纠）。
- 平台对接：自己提出 `make all` target 方案（build 依赖 + cp 改名 + RUSTSBI 依赖），已落码 Makefile:110，`kernel-qemu` 可产出。
- **未完**：`sbi-qemu` 拿不到——lab 仓库无 `bootloader/` 目录、机器无 Rust 工具链、网络受限。恢复路径：从上游 HUSTOS/xv6-k210 取现成 sbi-qemu（或装 cargo 源码编）；sdcard.img 与 init.c 硬编码进 initcode 两项也未做。

## 五维达成度（lab1 完成）

| 层 | 状态 | 依据 |
|----|------|------|
| 器 | 立住 | 环境跑通（lab0 过）；"改 kernel 侧代码 → make build 重编内核，改 xv6-user → 重打 fs.img"的构建层次未专门考查，lab2 需回查 |
| 技 | 立住 | CP①~④ 链路四处（编号/桩/分发/实现）全部答对并落码；CP① 曾撞号但经提示能自纠 |
| 术 | 半通 | CP② 两次答出完整路径（uservec→usertrap→syscall→sys_halt），是背出的还是理解的待 lab2 验证；scause/epc 未考查 |
| 法 | 未触 | 未主动问"为什么这样设计"；未抛可扩展性题（A 线不要求） |
| 道 | 半通 | CP④ Q1"安全隔离"+"SBI 在 M 态，硬件不放行"——特权级委托方向答对，表述简短 |

## 卡点记录

- **CP① Q1**：初答 26（撞号），未先看文件；指到 `sysnum.h:30` 后改答 30，通过。
- **CP① Q2**："简单开销小"不完整；追问 ecall 时刻寄存器后答出，通过。
- **CP④ Q3**：把 `SBI_SHUTDOWN` 编号误当函数，重复两次同一答案；指到 sbi.h 的 inline 函数区后找到 `sbi_shutdown()`，通过。**这是本 lab 最明显的卡点：区分"编号/宏"和"函数"花了 3 轮。**

## 推荐快慢线

**A 线**（与班级基线一致）。理由：答题前不主动查文件，抽象提示接不住，需要落到具体行号/区域；但一旦给了锚点，理解速度不慢，三问内基本能过。后续 lab 保持：先给区域锚点、卡住再给行号、每次一小步。

## 给下个 lab AI 的提示

- 给提示时永远附带文件+行号或函数区，纯方向性反问基本无效。
- 注意训练"先打开文件核实再作答"的习惯——CP① 和 CP④ 都是没看文件就猜。
- 概念上重点盯：编号 vs 函数名的区别（CP④ Q3 卡过）、系统调用返回路径（sret）。
- lab2 若涉及构建层次（改用户程序要重打 fs.img），主动考查器层是否真立住。
