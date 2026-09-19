# lab2 源码差异报告

- 学号：2406080106
- 姓名：高龙徽
- 数据采集时间：2026-09-09 12:15
- 原始提交目录：`D:\OS-Lab-Score\操作系统实验数据清洗\操作系统实验数据记录\2406080106-高龙徽-20260909-1215`
- 基准目录：`D:\OS-Lab-Score\xv6-ai-labs-km-无答案\lab2`
- 生成时间：2026-09-19 01:37:30 +0800
- 比较范围：kernel、xv6-user、linker 下的源码/脚本/构建配置，以及根目录 Makefile
- 空白符策略：忽略空格、Tab、空白行和行尾空白差异

## 统计

| 项目 | 数量 |
| --- | ---: |
| 纳入比较的文件 | 108 |
| 一致文件 | 107 |
| 有差异文件 | 1 |
| 新增行 | 6 |
| 删除行 | 0 |
| 处理异常文件 | 0 |

## 差异详情

### `Makefile`（修改）

```diff
diff --git 基准/Makefile 学生/Makefile
index 1e650f7..0ba861f 100644
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
```
