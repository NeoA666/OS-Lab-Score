# 教师贡献复核报告

- 学号：未知
- 学生目录：杨涵清
- 实验：lab1
- 分析状态：complete

## 自动结论

- 总体画像：无法判断贡献归属
- 画像置信度：弱
- 自动摘要：独立复核对一个或多个贡献归属存在分歧，当前实验级结论为无法判断。
- 证据 `source:lab1:diff_report`：`代码差异报告\lab1.md`；SHA-256 `2913d065f15085ae7e531a290177adde62a9c5a3e15713572da42280928fbf97`；第 32-130 行
  - 脱敏短摘录：@@ -151,6 +151,12 @@ ifeq ($(platform), k210)  else  	@$(QEMU) $(QEMUOPTS)  endif +# 调试⽤：启动带 gdbstub 的 QEMU（端⼝ 1234），停在起点等 gdb 接管 +# 另开⼀个终端跑：gdb-multiarch target/kernel -ex 'set arch riscv:rv64' -ex 'target remote localhost:1234' +gdb: build +	@echo "*** QEMU 已在 :1234 等待 gdb，请在另…
- 证据 `source:lab1:timeline`：`简洁实验过程时间线\timeline_lab1.md`；SHA-256 `0a41f38067c250585c9b6e9b55a506624ec565c53580b62eb58641f4f2ec6621`；第 16-50 行
  - 脱敏短摘录：make build  [终端输出] riscv64-unknown-elf-gcc    -c -o kernel/entry_qemu.o kernel/entry_qemu.S riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib  -mno-relax -I. -fno-stack…
- 替代解释：亦有可能学生在 AI 的建议或自动补全辅助下完成了部分修改，但材料中没有明确的 AI 生成痕迹（如典型的 AI 注释或代码风格），故不能将其判定为 AI 主导。
- 实验级局限：缺少直接的文件编辑记录（如编辑器命令、视频或详细日志）。；仅凭终端构建输出和最终 diff 无法区分人工输入与 AI 辅助输入的细节。；独立 NIM 复核存在分歧，实验级结论已降级为无法判断。

该结果由 NIM 主分析和独立 NIM 复核产生，且仅作为补充证据材料。它不认定真实作者、手打或复制粘贴行为，也不输出诚信结论或分数。

## 教师下一步

- 优先检查复核分歧单元的源文件哈希、行范围和脱敏短摘录。
- 对无法判断的单元，仅将其作为补充材料和教学沟通线索，不作作者或诚信推断。

## 资料覆盖

- 资料覆盖：complete
- `source:lab1:timeline`（timeline）：available；`简洁实验过程时间线\timeline_lab1.md`；SHA-256 `0a41f38067c250585c9b6e9b55a506624ec565c53580b62eb58641f4f2ec6621`；1291 行
- `source:lab1:terminal_qa`（terminal_qa）：available；`终端对话记录\terminal_qa_report_lab1.md`；SHA-256 `ae9b4ca1a7be52bf641b4c4dfa8196980346f5e0f073ef5d6fa1e13f1c98ffa0`；1447 行
- `source:lab1:command_statistics`（command_statistics）：available；`终端命令统计\command_statistics_lab1.md`；SHA-256 `1ccb0797722afd484a778fcd0189098d7ebfb5958e9a97c164b0dd26b765cbca`；28 行
- `source:lab1:diff_report`（diff_report）：available；`代码差异报告\lab1.md`；SHA-256 `2913d065f15085ae7e531a290177adde62a9c5a3e15713572da42280928fbf97`；130 行

## 关键贡献项

### 1. 无法判断贡献归属

- 单元 ID：`hunk:lab1:1`
- 类型：code_hunk
- 置信度：弱
- 可观察角色：人工：人工执行命令、人工验证
- 摘要：学生在 Makefile 中新增了 gdb 调试目标，包含中文注释说明使用方法。
- 替代解释：该目标可能由 AI 生成并随后由学生简单确认，但材料中未见直接 AI 生成痕迹。
- 代码 hunk：`hunk:lab1:1`
- 证据 `source:lab1:diff_report`：`代码差异报告\lab1.md`；SHA-256 `2913d065f15085ae7e531a290177adde62a9c5a3e15713572da42280928fbf97`；第 32-44 行
  - 脱敏短摘录：@@ -151,6 +151,12 @@ ifeq ($(platform), k210)  else  	@$(QEMU) $(QEMUOPTS)  endif +# 调试⽤：启动带 gdbstub 的 QEMU（端⼝ 1234），停在起点等 gdb 接管 +# 另开⼀个终端跑：gdb-multiarch target/kernel -ex 'set arch riscv:rv64' -ex 'target remote localhost:1234' +gdb: build +	@echo "*** QEMU 已在 :1234 等待 gdb，请在另…
- 证据 `source:lab1:timeline`：`简洁实验过程时间线\timeline_lab1.md`；SHA-256 `0a41f38067c250585c9b6e9b55a506624ec565c53580b62eb58641f4f2ec6621`；第 16-50 行
  - 脱敏短摘录：make build  [终端输出] riscv64-unknown-elf-gcc    -c -o kernel/entry_qemu.o kernel/entry_qemu.S riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib  -mno-relax -I. -fno-stack…

### 2. 无法判断贡献归属

- 单元 ID：`hunk:lab1:2`
- 类型：code_hunk
- 置信度：弱
- 可观察角色：人工：人工执行命令、人工验证
- 摘要：在 Makefile 的 clean 目标中添加了 fs.img 到删除列表。
- 替代解释：此改动亦可能来自 AI 建议，但未见 AI 生成证据。
- 代码 hunk：`hunk:lab1:2`
- 证据 `source:lab1:diff_report`：`代码差异报告\lab1.md`；SHA-256 `2913d065f15085ae7e531a290177adde62a9c5a3e15713572da42280928fbf97`；第 45-53 行
  - 脱敏短摘录：@@ -242,7 +248,7 @@ sdcard: userprogs  	@sudo cp README $(dst)/README    clean:  -	rm -f *.tex *.dvi *.idx *.aux *.log *.ind *.ilg \ +	rm -f *.tex *.dvi *.idx *.aux *.log *.ind *.ilg fs.img\  	*/*.o */*.d */*.asm */*.sym \  	$T/* \  	$U/initcode $U/initcode.out \
- 证据 `source:lab1:timeline`：`简洁实验过程时间线\timeline_lab1.md`；SHA-256 `0a41f38067c250585c9b6e9b55a506624ec565c53580b62eb58641f4f2ec6621`；第 16-50 行
  - 脱敏短摘录：make build  [终端输出] riscv64-unknown-elf-gcc    -c -o kernel/entry_qemu.o kernel/entry_qemu.S riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib  -mno-relax -I. -fno-stack…

### 3. 无法判断贡献归属

- 单元 ID：`hunk:lab1:3`
- 类型：code_hunk
- 置信度：弱
- 可观察角色：人工：人工执行命令、人工验证
- 摘要：将 SYS_halt 从占位符 0 改为实际系统调用号 27。
- 替代解释：该数值可能由 AI 推荐，但学生亦可能自行查表后修改。
- 代码 hunk：`hunk:lab1:3`
- 证据 `source:lab1:diff_report`：`代码差异报告\lab1.md`；SHA-256 `2913d065f15085ae7e531a290177adde62a9c5a3e15713572da42280928fbf97`；第 63-70 行
  - 脱敏短摘录：@@ -56,6 +56,5 @@  //   - 你选的号和已有 syscall 冲突了吗？  //   - syscalls[] 用这个号做下标会越界吗？  // ─────────────────────────────────────────────────────────── -#define SYS_halt   0   // ← 占位。学生：思考后改成未占用号 - +#define SYS_halt   27  #endif
- 证据 `source:lab1:timeline`：`简洁实验过程时间线\timeline_lab1.md`；SHA-256 `0a41f38067c250585c9b6e9b55a506624ec565c53580b62eb58641f4f2ec6621`；第 16-50 行
  - 脱敏短摘录：make build  [终端输出] riscv64-unknown-elf-gcc    -c -o kernel/entry_qemu.o kernel/entry_qemu.S riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib  -mno-relax -I. -fno-stack…

### 4. 无法判断贡献归属

- 单元 ID：`hunk:lab1:4`
- 类型：code_hunk
- 置信度：弱
- 可观察角色：人工：人工执行命令、人工验证
- 摘要：在 syscall.c 的 syscalls[] 分发表中增加 [SYS_halt] 条目。
- 替代解释：此行插入可能由 AI 自动补全，但学生亦可手动添加。
- 代码 hunk：`hunk:lab1:4`
- 证据 `source:lab1:diff_report`：`代码差异报告\lab1.md`；SHA-256 `2913d065f15085ae7e531a290177adde62a9c5a3e15713572da42280928fbf97`；第 80-88 行
  - 脱敏短摘录：@@ -145,6 +146,8 @@ static uint64 (*syscalls[])(void) = {    [SYS_trace]       sys_trace,    [SYS_sysinfo]     sys_sysinfo,    [SYS_rename]      sys_rename, +  [SYS_halt]        sys_halt, +    // ═══════════════════════════════════════════════════════════════    // 【AI-CHECKPOIN…
- 证据 `source:lab1:timeline`：`简洁实验过程时间线\timeline_lab1.md`；SHA-256 `0a41f38067c250585c9b6e9b55a506624ec565c53580b62eb58641f4f2ec6621`；第 16-50 行
  - 脱敏短摘录：make build  [终端输出] riscv64-unknown-elf-gcc    -c -o kernel/entry_qemu.o kernel/entry_qemu.S riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib  -mno-relax -I. -fno-stack…

### 5. 无法判断贡献归属

- 单元 ID：`hunk:lab1:5`
- 类型：code_hunk
- 置信度：弱
- 可观察角色：人工：人工执行命令、人工验证
- 摘要：在 syscall.c 的 sysnames[] 中增加 "halt" 字符串。
- 替代解释：同上，可能为 AI 建议或学生手动添加。
- 代码 hunk：`hunk:lab1:5`
- 证据 `source:lab1:diff_report`：`代码差异报告\lab1.md`；SHA-256 `2913d065f15085ae7e531a290177adde62a9c5a3e15713572da42280928fbf97`；第 89-97 行
  - 脱敏短摘录：@@ -199,6 +202,8 @@ static char *sysnames[] = {    [SYS_trace]       "trace",    [SYS_sysinfo]     "sysinfo",    [SYS_rename]      "rename", +  [SYS_halt]        "halt", +  };    void
- 证据 `source:lab1:timeline`：`简洁实验过程时间线\timeline_lab1.md`；SHA-256 `0a41f38067c250585c9b6e9b55a506624ec565c53580b62eb58641f4f2ec6621`；第 16-50 行
  - 脱敏短摘录：make build  [终端输出] riscv64-unknown-elf-gcc    -c -o kernel/entry_qemu.o kernel/entry_qemu.S riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib  -mno-relax -I. -fno-stack…

### 6. 无法判断贡献归属

- 单元 ID：`hunk:lab1:6`
- 类型：code_hunk
- 置信度：弱
- 可观察角色：人工：人工执行命令、人工验证
- 摘要：将 sys_halt 的实现从占位返回 -1 替换为实际的 sbi_shutdown() 并返回 0。
- 替代解释：此实现可能参考了教材或 AI 示例，但学生亦可自行编写。
- 代码 hunk：`hunk:lab1:6`
- 证据 `source:lab1:diff_report`：`代码差异报告\lab1.md`；SHA-256 `2913d065f15085ae7e531a290177adde62a9c5a3e15713572da42280928fbf97`；第 107-115 行
  - 脱敏短摘录：@@ -185,6 +185,6 @@ sys_trace(void)  uint64  sys_halt(void)  { -  // todo（CP④）：通过 SBI 提供的关机封装结束系统 -  return -1;  // 占位——学生实现后替换为实际关机逻辑 +sbi_shutdown(); +  return 0;    }
- 证据 `source:lab1:timeline`：`简洁实验过程时间线\timeline_lab1.md`；SHA-256 `0a41f38067c250585c9b6e9b55a506624ec565c53580b62eb58641f4f2ec6621`；第 16-50 行
  - 脱敏短摘录：make build  [终端输出] riscv64-unknown-elf-gcc    -c -o kernel/entry_qemu.o kernel/entry_qemu.S riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib  -mno-relax -I. -fno-stack…

其余 1 个贡献单元见完整报告和 JSON assessment。
## 代码变化与复核

- 复核状态：独立 NIM 复核存在分歧，相关单元已降级为无法判断
- 复核总体决策：disagree
- 复核摘要：所提供材料仅包含代码差异和编译输出，未见任何直接的人类编辑痕迹（如编辑器命令、修改日志或视频记录），因此无法将初判的人类主导行为证实。
- 已复核单元：hunk:lab1:1, hunk:lab1:2, hunk:lab1:3, hunk:lab1:4, hunk:lab1:5, hunk:lab1:6, hunk:lab1:7
- 存在分歧的单元：hunk:lab1:1, hunk:lab1:2, hunk:lab1:3, hunk:lab1:4, hunk:lab1:5, hunk:lab1:6, hunk:lab1:7

## 局限与追溯

- 所提供材料仅包括时间线（主要为构建命令）、终端问答（未展示）、命令统计和 diff 报告，缺少实际编辑过程的记录。
- 无法从现有材料中确定学生是否使用了 AI 生成代码、自动补全或粘贴操作。
- 该结果是课程贡献归属线索，不认定真实作者、手打或粘贴方式、理解程度、诚信、违规或分数。
- 独立 NIM 复核存在分歧；相关单元和实验级结论已降级为无法判断。
- Schema：`ai-human-contribution-assessment/v3`
- tool_version：3.1.1
- prompt_version：contribution-attribution-v3-nim-semantic-primary-v2
- validator_version：contribution-assessment-validator-v4
- completed_at：2026-09-19T05:09:02.708768+00:00
- 报告模板版本：6
