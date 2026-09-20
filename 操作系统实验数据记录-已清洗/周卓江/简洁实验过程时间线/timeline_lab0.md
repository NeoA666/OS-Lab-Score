# 简洁实验过程时间线

- 学号：2406080205
- 姓名：周卓江
- 实验分类：lab0

## 过程

### 录像时间：2026-09-10T15:52:49.913+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
claude
```

### 录像时间：2026-09-10T15:54:06.929+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
claude
```

### 录像时间：2026-09-10T15:54:10.348+08:00（北京时间）

- 录像类型：用户问题

- 内容：

```text
nihao
```

### 录像时间：2026-09-10T15:54:11.678+08:00（北京时间）

- 录像类型：Claude 回复

- 内容：

```text
你好！

lab0 是搭环境那一章，目标是把 xv6-k210 在 qemu 上跑通，看到 shell 提示符。

在开始之前，我想先确认一件事：

你现在用的环境是哪种？ 是课程给的镜像（.ova 导入 VMware、希冀云端、或者硬盘拷贝过来的），还是你自己机器上全新装的系统？

这个决定了后面是「直接验证」还是「先装工具链」，差别挺大。
```

### 录像时间：2026-09-10T22:21:21.543+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
claude
```

### 录像时间：2026-09-10T22:23:17.961+08:00（北京时间）

- 录像类型：用户问题

- 内容：

```text
### Linux 命令行与包管理器

实验全程在 Linux 命令行下进行。对 Linux 还不熟悉的同学，建议先掌握下面这些常用命令：

- 目录与文件：`cd`、`ls`、`pwd`、`mkdir`、`rm`、`cp`、`mv`
- 权限与进程：`chmod`、`chown`、`ps`
- 重定向与管道：`>`、`<`、`|`
- 包管理（Ubuntu/Debian）：`apt update`、`apt install`、`apt search`
- 系统管理：`sudo`、`man`给我简要介绍一下这些命令
```

### 录像时间：2026-09-10T22:23:22.863+08:00（北京时间）

- 录像类型：Claude 回复

- 内容：

```text
这一串其实分五类，你在 lab0 里天天真正会用到的是第一类 + man，其余的先认个脸。

目录与文件
- pwd — print working directory，我现在在哪个目录
- ls — 列出当前目录有什么（ls -l 看详情，ls -a 连隐藏文件）
- cd — 切换目录（cd .. 回上一级，cd 单独敲回 home）
- mkdir — 建目录
- cp — 复制（cp -r 连目录一起复制）
- mv — 移动；同一目录内移动就是改名
- rm — 删除。⚠  Linux 命令行下没有回收站，删了就没了，rm -rf 尤其要想清楚再敲

权限与进程
- chmod — 改文件权限（谁能读/写/执行）
- chown — 改文件属主（通常要 sudo）
- ps — 看当前有哪些进程在跑

重定向与管道
- > — 把命令本该打印到屏幕的输出，写进文件（< 是反过来：从文件读输入）
- | — 把左边命令的输出，直接当成右边命令的输入

包管理（Ubuntu/Debian）
- apt update — 更新"可安装软件清单"（不是升级软件）
- apt search xxx — 按关键词找包
- apt install xxx — 装包

系统管理
- sudo — 以 root 身份执行这条命令
- man xxx — 看某个命令的手册（man ls、man qemu-system-riscv64）

对应到 lab0：你会用 cd 走到 ~/xv6-ai-labs，用 ls 确认 Makefile 在不在，用 man 去查工具用法。而你排错时最有用的是 > —— 它能让你把完整报错存成文件，而不是在终端里往回翻、只截给我看最后一行。

这里挖一层：命令的输出默认是"送到屏幕"这个目的地，> 和 | 只是把这个目的地换掉。所以 make build 2>&1 | tee build.log 这类写法才成立 —— 本质是给输出改道，不是新命令。

先消化这些。你想先从哪条深挖？
```

### 录像时间：2026-09-10T22:26:08.329+08:00（北京时间）

- 录像类型：用户问题

- 内容：

```text
宿主机上普通的 `gcc` 把 C 代码编译成 x86_64 可执行文件。本实验需要的是 `riscv64-unknown-elf-gcc`，这是一个交叉编译器：它在 x86_64 上运行，生成的代码却只能在 RISC-V 上执行。讲的更大白话一些
```

### 录像时间：2026-09-10T22:26:28.733+08:00（北京时间）

- 录像类型：Claude 回复

- 内容：

```text
一句话：编译器本身是一个程序，它也得先在某台机器上跑起来；"交叉"说的是——它跑在你的 x86 上，但吐出来的东西是给另一种 CPU 看的。

大白话版

打个比方。你是个中国人，要写一份给日本人看的说明书。

- 你自己写不出日文，得请个翻译。
- 这个翻译坐在你办公室里（在你的 x86_64 机器上运行）。
- 他交出来的稿子是日文的（产物是 RISC-V 的机器指令）。
- 这份日文稿子你自己看不懂、也用不了，只有日本人能读（只有 RISC-V 的 CPU 能执行）。

riscv64-unknown-elf-gcc 就是那个"中译日"的翻译。而普通的 gcc 是"中译中"——它只会说 x86 这一套，你逼它也写不出 RISC-V 的指令，它压根没学过那门语言。

所以关键不在"gcc 好不好用"，而在于：x86 的指令和 RISC-V 的指令是两套完全不同的语言。C 代码是"中文原稿"，两边都认；但要变成哪个 CPU 能跑的机器码，得看翻译是谁。

落到本实验

打开 lab0/Makefile 第 68～70 行：

TOOLPREFIX    := riscv64-unknown-elf-
# TOOLPREFIX  := riscv64-linux-gnu-
CC = $(TOOLPREFIX)gcc

看出名字是怎么来的了吗——它不是单独一个命令，而是前缀拼上 gcc。$(TOOLPREFIX)gcc 展开后正好就是 riscv64-unknown-elf-gcc。同理下面还有
$(TOOLPREFIX)ld、$(TOOLPREFIX)objcopy，一整套工具都靠这个前缀换语言。这也解释了为什么装工具链时是一整包一起装，而不是单装一个 gcc。

再挖一层

名字为什么这么长？因为它要同时说清两件事：

- 前半段 riscv64 —— 产物给谁看（目标机）
- 后半段 elf —— 产物是什么格式（一种可执行文件的标准封装格式）

而"跑在哪"这件事名字里根本没写，因为默认就是当前这台机器。一个编译器天然有两个身份：自己在哪跑（host）和产物在哪跑（target）。两者相同叫本地编译，不同就叫交叉编译。

顺下去就是一个自然的问题：产物是 RISC-V 的，可在你这台 x86 上根本没人能执行它——那待会儿是谁来"当那个日本人"？先记住这个悬念，想追就接着问。
```

### 录像时间：2026-09-10T22:35:46.877+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
make clean

[终端输出]
rm -f *.tex *.dvi *.idx *.aux *.log *.ind *.ilg \
*/*.o */*.d */*.asm */*.sym \
target/* \
xv6-user/initcode xv6-user/initcode.out \
kernel/kernel \
.gdbinit \
xv6-user/usys.S \
xv6-user/_init xv6-user/_sh xv6-user/_cat xv6-user/_echo xv6-user/_grep xv6-user/_ls xv6-user/_kill xv6-user/_mkdir xv6-user/_xargs xv6-user/_sleep xv6-user/_find xv6-user/_rm xv6-user/_wc xv6-user/_test xv6-user/_usertests xv6-user/_strace xv6-user/_mv
```

### 录像时间：2026-09-10T22:35:50.703+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
make run

[终端输出]
riscv64-unknown-elf-gcc    -c -o kernel/entry_qemu.o kernel/entry_qemu.S
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/printf.o kernel/printf.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/kalloc.o kernel/kalloc.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/intr.o kernel/intr.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/spinlock.o kernel/spinlock.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/string.o kernel/string.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/main.o kernel/main.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/vm.o kernel/vm.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/proc.o kernel/proc.c
riscv64-unknown-elf-gcc    -c -o kernel/swtch.o kernel/swtch.S
riscv64-unknown-elf-gcc    -c -o kernel/trampoline.o kernel/trampoline.S
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/trap.o kernel/trap.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/syscall.o kernel/syscall.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/sysproc.o kernel/sysproc.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/bio.o kernel/bio.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/sleeplock.o kernel/sleeplock.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/file.o kernel/file.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/pipe.o kernel/pipe.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/exec.o kernel/exec.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/sysfile.o kernel/sysfile.c
riscv64-unknown-elf-gcc    -c -o kernel/kernelvec.o kernel/kernelvec.S
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/timer.o kernel/timer.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/disk.o kernel/disk.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/fat32.o kernel/fat32.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/plic.o kernel/plic.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/console.o kernel/console.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/virtio_disk.o kernel/virtio_disk.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU -march=rv64g -nostdinc -I. -Ikernel -c xv6-user/initcode.S -o xv6-user/initcode.o
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e start -Ttext 0 -o xv6-user/initcode.out xv6-user/initcode.o
riscv64-unknown-elf-ld: warning: xv6-user/initcode.out has a LOAD segment with RWX permissions
riscv64-unknown-elf-objcopy -S -O binary xv6-user/initcode.out xv6-user/initcode
riscv64-unknown-elf-objdump -S xv6-user/initcode.o > xv6-user/initcode.asm
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/ulib.o xv6-user/ulib.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU -c -o xv6-user/usys.o xv6-user/usys.S
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/printf.o xv6-user/printf.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/umalloc.o xv6-user/umalloc.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/init.o xv6-user/init.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_init xv6-user/init.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_init has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_init > xv6-user/init.asm
riscv64-unknown-elf-objdump -t xv6-user/_init | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/init.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/sh.o xv6-user/sh.c
xv6-user/sh.c: In function 'runcmd':
xv6-user/sh.c:157:1: warning: infinite recursion detected [-Winfinite-recursion]
  157 | runcmd(struct cmd *cmd)
      | ^~~~~~
xv6-user/sh.c:205:5: note: recursive call
  205 |     runcmd(rcmd->cmd);
      |     ^~~~~~~~~~~~~~~~~
xv6-user/sh.c:225:7: note: recursive call
  225 |       runcmd(pcmd->left);
      |       ^~~~~~~~~~~~~~~~~~
xv6-user/sh.c:232:7: note: recursive call
  232 |       runcmd(pcmd->right);
      |       ^~~~~~~~~~~~~~~~~~~
xv6-user/sh.c:211:7: note: recursive call
  211 |       runcmd(lcmd->left);
      |       ^~~~~~~~~~~~~~~~~~
xv6-user/sh.c:213:5: note: recursive call
  213 |     runcmd(lcmd->right);
      |     ^~~~~~~~~~~~~~~~~~~
xv6-user/sh.c:243:7: note: recursive call
  243 |       runcmd(bcmd->cmd);
      |       ^~~~~~~~~~~~~~~~~
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_sh xv6-user/sh.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_sh has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_sh > xv6-user/sh.asm
riscv64-unknown-elf-objdump -t xv6-user/_sh | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/sh.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/cat.o xv6-user/cat.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_cat xv6-user/cat.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_cat has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_cat > xv6-user/cat.asm
riscv64-unknown-elf-objdump -t xv6-user/_cat | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/cat.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/echo.o xv6-user/echo.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_echo xv6-user/echo.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_echo has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_echo > xv6-user/echo.asm
riscv64-unknown-elf-objdump -t xv6-user/_echo | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/echo.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/grep.o xv6-user/grep.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_grep xv6-user/grep.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_grep has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_grep > xv6-user/grep.asm
riscv64-unknown-elf-objdump -t xv6-user/_grep | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/grep.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/ls.o xv6-user/ls.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_ls xv6-user/ls.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_ls has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_ls > xv6-user/ls.asm
riscv64-unknown-elf-objdump -t xv6-user/_ls | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/ls.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/kill.o xv6-user/kill.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_kill xv6-user/kill.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_kill has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_kill > xv6-user/kill.asm
riscv64-unknown-elf-objdump -t xv6-user/_kill | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/kill.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/mkdir.o xv6-user/mkdir.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_mkdir xv6-user/mkdir.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_mkdir has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_mkdir > xv6-user/mkdir.asm
riscv64-unknown-elf-objdump -t xv6-user/_mkdir | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/mkdir.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/xargs.o xv6-user/xargs.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_xargs xv6-user/xargs.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_xargs has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_xargs > xv6-user/xargs.asm
riscv64-unknown-elf-objdump -t xv6-user/_xargs | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/xargs.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/sleep.o xv6-user/sleep.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_sleep xv6-user/sleep.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_sleep has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_sleep > xv6-user/sleep.asm
riscv64-unknown-elf-objdump -t xv6-user/_sleep | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/sleep.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/find.o xv6-user/find.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_find xv6-user/find.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_find has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_find > xv6-user/find.asm
riscv64-unknown-elf-objdump -t xv6-user/_find | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/find.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/rm.o xv6-user/rm.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_rm xv6-user/rm.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_rm has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_rm > xv6-user/rm.asm
riscv64-unknown-elf-objdump -t xv6-user/_rm | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/rm.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/wc.o xv6-user/wc.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_wc xv6-user/wc.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_wc has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_wc > xv6-user/wc.asm
riscv64-unknown-elf-objdump -t xv6-user/_wc | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/wc.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/test.o xv6-user/test.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_test xv6-user/test.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_test has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_test > xv6-user/test.asm
riscv64-unknown-elf-objdump -t xv6-user/_test | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/test.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/usertests.o xv6-user/usertests.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_usertests xv6-user/usertests.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_usertests has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_usertests > xv6-user/usertests.asm
riscv64-unknown-elf-objdump -t xv6-user/_usertests | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/usertests.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/strace.o xv6-user/strace.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_strace xv6-user/strace.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_strace has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_strace > xv6-user/strace.asm
riscv64-unknown-elf-objdump -t xv6-user/_strace | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/strace.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/mv.o xv6-user/mv.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_mv xv6-user/mv.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_mv has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_mv > xv6-user/mv.asm
riscv64-unknown-elf-objdump -t xv6-user/_mv | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/mv.sym
qemu-system-riscv64: -drive file=fs.img,if=none,format=raw,id=x0: Could not open 'fs.img': No such file or directory
make: *** [Makefile:152：run] 错误 1
```

### 录像时间：2026-09-10T22:36:09.221+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
make fs

[终端输出]
making fs image...
输入了 512+0 块记录
输出了 512+0 块记录
268435456 字节 (268 MB, 256 MiB) 已复制，4.66192 s，57.6 MB/s
mkfs.fat 4.2 (2021-01-31)
[sudo] ailab-os 的密码：
```

### 录像时间：2026-09-10T22:36:25.256+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
make run

[终端输出]
OpenSBI v1.3
   ____                    _____ ____ _____
  / __ \                  / ____|  _ \_   _|
 | |  | |_ __   ___ _ __ | (___ | |_) || |
 | |  | | '_ \ / _ \ '_ \ \___ \|  _ < | |
 | |__| | |_) |  __/ | | |____) | |_) || |_
  \____/| .__/ \___|_| |_|_____/|___/_____|
        | |
        |_|

Platform Name             : riscv-virtio,qemu
Platform Features         : medeleg
Platform HART Count       : 2
Platform IPI Device       : aclint-mswi
Platform Timer Device     : aclint-mtimer @ 10000000Hz
Platform Console Device   : uart8250
Platform HSM Device       : ---
Platform PMU Device       : ---
Platform Reboot Device    : sifive_test
Platform Shutdown Device  : sifive_test
Platform Suspend Device   : ---
Platform CPPC Device      : ---
Firmware Base             : 0x80000000
Firmware Size             : 332 KB
Firmware RW Offset        : 0x40000
Firmware RW Size          : 76 KB
Firmware Heap Offset      : 0x4a000
Firmware Heap Size        : 36 KB (total), 2 KB (reserved), 9 KB (used), 24 KB (free)
Firmware Scratch Size     : 4096 B (total), 760 B (used), 3336 B (free)
Runtime SBI Version       : 1.0

Domain0 Name              : root
Domain0 Boot HART         : 0
Domain0 HARTs             : 0*,1*
Domain0 Region00          : 0x0000000002000000-0x000000000200ffff M: (I,R,W) S/U: ()
Domain0 Region01          : 0x0000000080040000-0x000000008005ffff M: (R,W) S/U: ()
Domain0 Region02          : 0x0000000080000000-0x000000008003ffff M: (R,X) S/U: ()
Domain0 Region03          : 0x0000000000000000-0xffffffffffffffff M: (R,W,X) S/U: (R,W,X)
Domain0 Next Address      : 0x0000000080200000
Domain0 Next Arg1         : 0x0000000087e00000
Domain0 Next Mode         : S-mode
Domain0 SysReset          : yes
Domain0 SysSuspend        : yes

Boot HART ID              : 0
Boot HART Domain          : root
Boot HART Priv Version    : v1.12
Boot HART Base ISA        : rv64imafdch
Boot HART ISA Extensions  : time,sstc
Boot HART PMP Count       : 16
Boot HART PMP Granularity : 4
Boot HART PMP Address Bits: 54
Boot HART MHPM Count      : 16
Boot HART MIDELEG         : 0x0000000000001666
Boot HART MEDELEG         : 0x0000000000f0b509
  (`-.            (`-.                            .-')       ('-.    _   .-')
 ( OO ).        _(OO  )_                        .(  OO)    _(  OO)  ( '.( OO )_
(_/.  \_)-. ,--(_/   ,. \  ,--.                (_)---\_)  (,------.  ,--.   ,--.) ,--. ,--.
 \  `.'  /  \   \   /(__/ /  .'       .-')     '  .-.  '   |  .---'  |   `.'   |  |  | |  |
  \     /\   \   \ /   / .  / -.    _(  OO)   ,|  | |  |   |  |      |         |  |  | | .-')
   \   \ |    \   '   /, | .-.  '  (,------. (_|  | |  |  (|  '--.   |  |'.'|  |  |  |_|( OO )
  .'    \_)    \     /__)' \  |  |  '------'   |  | |  |   |  .--'   |  |   |  |  |  | | `-' /
 /  .'.  \      \   /    \  `'  /              '  '-'  '-. |  `---.  |  |   |  | ('  '-'(_.-'
'--'   '--'      `-'      `----'                `-----'--' `------'  `--'   `--'   `-----'
hart 0 enter main()...
kernel_end: 0x0000000080226000, phystop: 0x0000000080600000
kinit
kvminit
kvminithart
timerinit
trapinithart
procinit
plicinit
plicinithart
virtio_disk_init
binit
fileinit
userinit
hart 0 init done
[fat32_init] enter!
[FAT32 init]byts_per_sec: 512
[FAT32 init]root_clus: 2
[FAT32 init]sec_per_clus: 1
[FAT32 init]fat_cnt: 2
[FAT32 init]fat_sz: 4033
[FAT32 init]first_data_sec: 8098
init: starting sh
-> / $ ls
bin                              DIR    0
README                           FILE   2059
cat                              FILE   22152
echo                             FILE   21088
find                             FILE   23288
grep                             FILE   24680
init                             FILE   21760
kill                             FILE   20976
ls                               FILE   23304
mkdir                            FILE   21072
mv                               FILE   22872
rm                               FILE   21064
sh                               FILE   43696
sleep                            FILE   21048
strace                           FILE   21424
test                             FILE   20920
usertests                        FILE   117496
wc                               FILE   22936
xargs                            FILE   22752
-> / $ ls/bin
[exec] ls/bin not found
[exec] reach bad
[exec] /bin/ls/bin not found
[exec] reach bad
exec ls/bin failed
-> / $ cat README
xv6 is a re-implementation of Dennis Ritchie's and Ken Thompson's Unix
Version 6 (v6).  xv6 loosely follows the structure and style of v6,
but is implemented for a modern RISC-V multiprocessor using ANSI C.
ACKNOWLEDGMENTS
xv6 is inspired by John Lions's Commentary on UNIX 6th Edition (Peer
to Peer Communications; ISBN: 1-57398-013-7; 1st edition (June 14,
2000)). See also https://pdos.csail.mit.edu/6.828/, which
provides pointers to on-line resources for v6.
The following people have made contributions: Russ Cox (context switching,
locking), Cliff Frey (MP), Xiao Yu (MP), Nickolai Zeldovich, and Austin
Clements.
We are also grateful for the bug reports and patches contributed by
Silas Boyd-Wickizer, Anton Burtsev, Dan Cross, Cody Cutler, Mike CAT,
Tej Chajed, Asami Doi, eyalz800, , Nelson Elhage, Saar Ettinger, Alice
Ferrazzi, Nathaniel Filardo, Peter Froehlich, Yakir Goaron,Shivam
Handa, Bryan Henry, jaichenhengjie, Jim Huang, Alexander Kapshuk,
Anders Kaseorg, kehao95, Wolfgang Keller, Jonathan Kimmitt, Eddie
Kohler, Austin Liew, Imbar Marinescu, Yandong Mao, Matan Shabtay,
Hitoshi Mitake, Carmi Merimovich, Mark Morrissey, mtasm, Joel Nider,
Greg Price, Ayan Shafqat, Eldar Sehayek, Yongming Shen, Fumiya
Shigemitsu, Takahiro, Cam Tenny, tyfkda, Rafael Ubal, Warren Toomey,
Stephen Tu, Pablo Ventura, Xi Wang, Keiichi Watanabe, Nicolas
Wolovick, wxdao, Grant Wu, Jindong Zhang, Icenowy Zheng, and Zou Chang
Wei.
The code in the files that constitute xv6 is
Copyright 2006-2020 Frans Kaashoek, Robert Morris, and Russ Cox.
ERROR REPORTS
Please send errors and suggestions to Frans Kaashoek and Robert Morris
(kaashoek,rtm@mit.edu). The main purpose of xv6 is as a teaching
operating system for MIT's 6.S081, so we are more interested in
simplifications and clarifications than new features.
BUILDING AND RUNNING XV6
You will need a RISC-V "newlib" tool chain from
https://github.com/riscv/riscv-gnu-toolchain, and qemu compiled for
riscv64-softmmu. Once they are installed, and in your shell
search path, you can run "make qemu".
-> / $
```

### 录像时间：2026-09-10T22:37:43.025+08:00（北京时间）

- 录像类型：用户问题

- 内容：

```text
| `-drive ... -device ...` | 把 `fs.img` 作为 virtio 块设备挂上 |这里的virto块设备是什么，是一种存储单元马
```

### 录像时间：2026-09-10T22:37:53.010+08:00（北京时间）

- 录像类型：Claude 回复

- 内容：

```text
一句话：几乎可以这么理解——对 xv6 内核来说，它就是一块能读能写的硬盘；但它在物理上并不存在，是 QEMU 用你磁盘上的一个普通文件演出来的。

把名字拆成两半

先说"块设备"。这个词的重心在"块"。

存储设备分两大类，区别在于怎么读写：

- 字符设备：一个字节一个字节地顺序流过去。典型的是串口、键盘——你只能"接下来收到什么就是什么"，不能跳到第 100 个字符去读。
- 块设备：把存储空间切成固定大小的块（磁盘上习惯叫扇区），每块有编号，你可以直接跳到第 100 块去读，不用先把前 99 块读完。硬盘、U 盘、SSD 都是块设备。

xv6 待会儿要跑文件系统，文件系统干的事就是"第 100 块存了哪个文件的哪段数据"——所以它需要的是能随机定位的块设备，不是串口那样的字节流。这就是这里为什么必须是块设备。

再说"virtio"。这是 virtual I/O 的缩写，意思是"虚拟的输入输出"。QEMU 和虚拟机里的内核事先约好一套简化的通话规则：内核说"帮我读第 100 块"，QEMU
就去办。因为它俩都知道对方是假的，不用装得像真硬盘那样一个寄存器一个寄存器地磨，速度就快得多。

落到本实验

lab0/Makefile 第 140～141 行：

QEMUOPTS += -drive file=fs.img,if=none,format=raw,id=x0
QEMUOPTS += -device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0

这两行看着重复，其实是分工：

- -drive 负责回答"背后是哪个文件"——答案是 fs.img，并且给它起个代号 x0（if=none 意思是先别急着接到任何总线上）。
- -device 负责回答"给虚拟机接一块什么样的硬盘"——接一块 virtio 块设备（virtio-blk），背后的数据源是 x0，插在 virtio-mmio-bus.0 这个位置上。

那句 -device 一执行，虚拟机里就凭空多出一块硬盘。内核启动后去探测，看到它长得跟真硬盘没区别，于是照常读写。

那 fs.img 又是谁？看第 228～231 行，make fs 干的事是：

dd if=/dev/zero of=fs.img bs=512k count=512   # 造一个 256MB 的全零大文件
mkfs.vfat -F 32 fs.img                        # 把它格式化成 FAT32

所以顺序是：先造一个 256MB 的空文件，格式化成文件系统，再让 QEMU 把它当成一块硬盘插到虚拟机上。你在 xv6 的 shell 里 echo hello > a.txt，数据最终就写进了宿主机这个 fs.img
文件里——这就是"虚拟"两个字的全部含义。

挖一层

顺着往下，内核那边也有一份配套代码：Makefile 第 55 行的 $K/virtio_disk.o。它是 xv6 里驱动这块假硬盘的代码——所谓驱动，就是"内核里负责跟某种设备说话的那部分代码"。你现在不用读懂它，只要知道：设备是
QEMU 假装的，但内核不觉得是假的，照样得老老实实写驱动去跟它打交道。

要接着看这块吗？还是先去把环境跑通？
```

### 录像时间：2026-09-10T22:39:42.694+08:00（北京时间）

- 录像类型：用户问题

- 内容：

```text
环境已经跑通，之后不要再提
```

### 录像时间：2026-09-10T22:39:53.094+08:00（北京时间）

- 录像类型：Claude 回复

- 内容：

```text
明白，记下了，之后不再提环境。

接着上面那个线头——你现在手上有一个选择：

- 继续挖 virtio 的虚拟设备这一层（QEMU 假装硬盘这件事，到底怎么"假装"的）；
- 或者往前推到 xv6 内核启动后是怎么发现这块盘的（设备探测）；
- 或者跳出这一行，你手上 实验指导.md 里还有别的地方看着不顺的，直接问那个。

你说哪个。
```

### 录像时间：2026-09-10T23:20:07.418+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
claude
```

### 录像时间：2026-09-10T23:21:27.078+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
claude
```

### 录像时间：2026-09-10T23:21:46.270+08:00（北京时间）

- 录像类型：用户问题

- 内容：

```text
你好，测试用，不用回复
```

### 录像时间：2026-09-10T23:21:47.773+08:00（北京时间）

- 录像类型：Claude 回复

- 内容：

```text
你好！收到，不回复。

（如果之后有 lab0 的问题，随时问。）
```

### 录像时间：2026-09-10T23:22:09.145+08:00（北京时间）

- 录像类型：用户问题

- 内容：

```text
请你介绍一下lab0实验的主要内容
```

### 录像时间：2026-09-10T23:22:15.559+08:00（北京时间）

- 录像类型：Claude 回复

- 内容：

```text
lab0 是整套实验的环境搭建章：不挖空、不改代码、不要求读懂 xv6。它只有一件事——把 xv6-k210 在 QEMU 里跑起来，直到你看见 shell 提示符 -> / $。

它为什么单独成一章

因为操作系统实验和普通编程实验有个根本区别：你写的代码不跑在你自己的电脑上。你的电脑是 x86_64，而 xv6-k210 要跑在 RISC-V 上。所以整条链路上有两套工具、两个角色：

- 宿主机（x86_64）：编辑器、make、qemu 在这一侧
- 目标机（RISC-V）：内核和用户程序在这一侧

中间靠 riscv64-unknown-elf-gcc（交叉编译器）和 qemu-system-riscv64（模拟器）连起来。lab0 就是让你亲手把这条链路接通的。

你要做的事，按顺序大致是五步

1. 有一个 Ubuntu Linux 环境（课程镜像 / 硬盘拷贝 / 希冀云端，三选一）
2. 确认交叉编译工具链在，且 Makefile 里的 TOOLPREFIX 和它对得上
3. 确认 QEMU 在，且版本 ≥ 7.0
4. make build 编译内核和用户程序 → make fs 打包出 FAT32 镜像 fs.img
5. make run 启动 QEMU，看到 OpenSBI banner → 内核 banner → -> / $

成功标志：在 shell 里敲 ls、cat README 有正常输出。走到这里，lab0 就算完成，后面 lab1 才动代码。

这里已经牵出好几个隐藏概念了——交叉编译、特权级、SBI、QEMU 的 virt 机器、FAT32 镜像为什么是必须的。你想先挖哪一个？
```
