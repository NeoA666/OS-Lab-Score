# lab1 源码差异报告

- 学号：2406080118
- 姓名：杨涵清
- 数据采集时间：2026-09-17 17:29
- 原始提交目录：`D:\OS-Lab-Score\操作系统实验数据清洗\操作系统实验数据记录\2406080118-杨涵清-20260917-1729`
- 基准目录：`D:\OS-Lab-Score\xv6-ai-labs-km-无答案\lab1`
- 生成时间：2026-09-19 01:37:12 +0800
- 比较范围：kernel、xv6-user、linker 下的源码/脚本/构建配置，以及根目录 Makefile
- 空白符策略：忽略空格、Tab、空白行和行尾空白差异

## 统计

| 项目 | 数量 |
| --- | ---: |
| 纳入比较的文件 | 107 |
| 一致文件 | 102 |
| 有差异文件 | 5 |
| 新增行 | 15 |
| 删除行 | 5 |
| 处理异常文件 | 0 |

## 差异详情

### `Makefile`（修改）

```diff
diff --git 基准/Makefile 学生/Makefile
index f727dde..2aaf8f5 100644
--- 基准/Makefile
+++ 学生/Makefile
@@ -151,6 +151,12 @@ ifeq ($(platform), k210)
 else
 	@$(QEMU) $(QEMUOPTS)
 endif
+# 调试⽤：启动带 gdbstub 的 QEMU（端⼝ 1234），停在起点等 gdb 接管
+# 另开⼀个终端跑：gdb-multiarch target/kernel -ex 'set arch riscv:rv64' -ex 'target remote localhost:1234'
+gdb: build
+	@echo "*** QEMU 已在 :1234 等待 gdb，请在另⼀个终端运⾏: ***"
+	@echo " gdb-multiarch target/kernel -ex 'set arch riscv:rv64' -ex 'target remote localhost:1234'"
+	@$(QEMU) $(QEMUOPTS) -S -s
 
 $U/initcode: $U/initcode.S
 	$(CC) $(CFLAGS) -march=rv64g -nostdinc -I. -Ikernel -c $U/initcode.S -o $U/initcode.o
@@ -242,7 +248,7 @@ sdcard: userprogs
 	@sudo cp README $(dst)/README
 
 clean: 
-	rm -f *.tex *.dvi *.idx *.aux *.log *.ind *.ilg \
+	rm -f *.tex *.dvi *.idx *.aux *.log *.ind *.ilg fs.img\
 	*/*.o */*.d */*.asm */*.sym \
 	$T/* \
 	$U/initcode $U/initcode.out \
```

### `kernel/include/sysnum.h`（修改）

```diff
diff --git 基准/kernel/include/sysnum.h 学生/kernel/include/sysnum.h
index fe4492e..2e7ef0b 100644
--- 基准/kernel/include/sysnum.h
+++ 学生/kernel/include/sysnum.h
@@ -56,6 +56,5 @@
 //   - 你选的号和已有 syscall 冲突了吗？
 //   - syscalls[] 用这个号做下标会越界吗？
 // ───────────────────────────────────────────────────────────
-#define SYS_halt   0   // ← 占位。学生：思考后改成未占用号
-
+#define SYS_halt   27
 #endif
```

### `kernel/syscall.c`（修改）

```diff
diff --git 基准/kernel/syscall.c 学生/kernel/syscall.c
index 0219b80..71a393b 100644
--- 基准/kernel/syscall.c
+++ 学生/kernel/syscall.c
@@ -145,6 +146,8 @@ static uint64 (*syscalls[])(void) = {
   [SYS_trace]       sys_trace,
   [SYS_sysinfo]     sys_sysinfo,
   [SYS_rename]      sys_rename,
+  [SYS_halt]        sys_halt,
+
   // ═══════════════════════════════════════════════════════════════
   // 【AI-CHECKPOINT ③】syscall.c syscalls[] dispatch（主线·教学）
   // ────────────────────────────────────────────────────────────────
@@ -199,6 +202,8 @@ static char *sysnames[] = {
   [SYS_trace]       "trace",
   [SYS_sysinfo]     "sysinfo",
   [SYS_rename]      "rename",
+  [SYS_halt]        "halt",
+
 };
 
 void
```

### `kernel/sysproc.c`（修改）

```diff
diff --git 基准/kernel/sysproc.c 学生/kernel/sysproc.c
index 809b911..0396327 100644
--- 基准/kernel/sysproc.c
+++ 学生/kernel/sysproc.c
@@ -185,6 +185,6 @@ sys_trace(void)
 uint64
 sys_halt(void)
 {
-  // todo（CP④）：通过 SBI 提供的关机封装结束系统
-  return -1;  // 占位——学生实现后替换为实际关机逻辑
+sbi_shutdown();
+  return 0;  
 }
```

### `xv6-user/usys.pl`（修改）

```diff
diff --git 基准/xv6-user/usys.pl 学生/xv6-user/usys.pl
index 2e7f4bc..3c77c44 100644
--- 基准/xv6-user/usys.pl
+++ 学生/xv6-user/usys.pl
@@ -65,3 +65,4 @@ entry("rename");
 #   - ecall 后的路径能和 syscall.c 的分发表连起来吗？
 # ───────────────────────────────────────────────────────────
 # entry("halt");  // TODO: 学生自行添加此行（CP②）
+entry("halt");
```
