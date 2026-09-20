# 简洁实验过程时间线

- 学号：2406080111
- 姓名：李兆卓
- 实验分类：lab0

## 过程

### 录像时间：2026-09-03T17:31:50.856+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
make run

[终端输出]
make: 警告：文件“target/kernel”的修改时间在未来 27355 秒后
qemu-system-riscv64: -drive file=fs.img,if=none,format=raw,id=x0: Could not open 'fs.img': No such file or directory
make: *** [Makefile:152：run] 错误 1
```

### 录像时间：2026-09-03T17:32:38.616+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
make ru

[终端输出]
make: *** 没有规则可制作目标“ru”。 停止。
```

### 录像时间：2026-09-03T17:32:41.880+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
make run

[终端输出]
make: 警告：文件“target/kernel”的修改时间在未来 27304 秒后
making fs image...
输入了 512+0 块记录
输出了 512+0 块记录
268435456 字节 (268 MB, 256 MiB) 已复制，0.361707 s，742 MB/s
mkfs.fat 4.2 (2021-01-31)
[sudo] ailab-os 的密码：
对不起，请重试。
[sudo] ailab-os 的密码：

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
Domain0 Region01          : 0x0000000080040000-0x000000008005ffff M: (R,W) S/U:
()
Domain0 Region02          : 0x0000000080000000-0x000000008003ffff M: (R,X) S/U:
()
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
hart 0 init done
init: starting sh
-> / $ exit
exec exit failed
-> / $ halt
exec halt failed
-> / $
-> / $
-> / $
```

### 录像时间：2026-09-03T17:33:32.655+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
make gdb

[终端输出]
make: 警告：文件“target/kernel”的修改时间在未来 27253 秒后
*** QEMU 已在 :1234 等待 gdb，请在另⼀个终端运⾏: ***
 gdb-multiarch target/kernel -ex 'set arch riscv:rv64' -ex 'target remote localhost:1234'
qemu-system-riscv64: -device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0: Failed to get "write" lock
Is another process using the image [fs.img]?
make: *** [Makefile:159：gdb] 错误 1
```

### 录像时间：2026-09-03T17:34:05.935+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
make gdb

[终端输出]
make: 警告：文件“target/kernel”的修改时间在未来 27219 秒后
[sudo] ailab-os 的密码：
*** QEMU 已在 :1234 等待 gdb，请在另⼀个终端运⾏: ***
 gdb-multiarch target/kernel -ex 'set arch riscv:rv64' -ex 'target remote localhost:1234'
qemu-system-riscv64: -device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0: Failed to get "write" lock
Is another process using the image [fs.img]?
make: *** [Makefile:159：gdb] 错误 1
```

### 录像时间：2026-09-03T17:34:28.350+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
make fs
```

### 录像时间：2026-09-03T17:34:34.158+08:00（北京时间）

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
xv6-user/_init xv6-user/_sh xv6-user/_cat xv6-user/_echo xv6-user/_grep xv6-user/_ls xv6-user/_kill xv6-user/_mkdir xv6-user/_xargs xv6-user/_sleep xv6-user/_fi
nd xv6-user/_rm xv6-user/_wc xv6-user/_test xv6-user/_usertests xv6-user/_strace xv6-user/_mv
```

### 录像时间：2026-09-03T17:34:39.503+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
make gdb

[终端输出]
riscv64-unknown-elf-gcc    -c -o kernel/entry_qemu.o kernel/entry_qemu.S
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/printf.o kernel/printf.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/kalloc.o kernel/kalloc.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/intr.o kernel/intr.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/spinlock.o
kernel/spinlock.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/string.o kernel/string.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/main.o kernel/main.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/vm.o kernel/vm.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/proc.o kernel/proc.c
riscv64-unknown-elf-gcc    -c -o kernel/swtch.o kernel/swtch.S
riscv64-unknown-elf-gcc    -c -o kernel/trampoline.o kernel/trampoline.S
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/trap.o kernel/trap.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/syscall.o kernel/syscall.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/sysproc.o kernel/sysproc.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/bio.o kernel/bio.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/sleeplock.o kernel/sleeplock.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/file.o kernel/file.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/pipe.o kernel/pipe.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/exec.o kernel/exec.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/sysfile.o kernel/sysfile.c
riscv64-unknown-elf-gcc    -c -o kernel/kernelvec.o kernel/kernelvec.S
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/timer.o kernel/timer.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/disk.o kernel/disk.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/fat32.o kernel/fat32.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/plic.o kernel/plic.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/console.o kernel/console.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/virtio_disk.o kernel/virtio_disk.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU -march=rv64g -nostdinc -I. -Ikernel -c xv6-user/initcode.S -o xv6-user/initcode.o
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e start -Ttext 0 -o xv6-user/initcode.out xv6-user/initcode.o
riscv64-unknown-elf-ld: warning: xv6-user/initcode.out has a LOAD segment with RWX permissions
riscv64-unknown-elf-objcopy -S -O binary xv6-user/initcode.out xv6-user/initcoderiscv64-unknown-elf-objdump -S xv6-user/initcode.o > xv6-user/initcode.asm
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/ulib.o xv6-user/ulib.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU -c -o xv6-user/usys.o xv6-user/usys.S
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/printf.o
xv6-user/printf.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/umalloc.o xv6-user/umalloc.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/init.o xv6-user/init.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_init xv6-user/init.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_init has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_init > xv6-user/init.asm
riscv64-unknown-elf-objdump -t xv6-user/_init | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/init.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/sh.o xv6-user/sh.c
xv6-user/sh.c: In function 'runcmd':
xv6-user/sh.c:157:1: warning: infinite recursion detected [-Winfinite-recursion]  157 | runcmd(struct cmd *cmd)
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
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_sh xv6-user/sh.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umallo
c.o
riscv64-unknown-elf-ld: warning: xv6-user/_sh has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_sh > xv6-user/sh.asm
riscv64-unknown-elf-objdump -t xv6-user/_sh | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/sh.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/cat.o xv6-user/cat.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_cat xv6-user/cat.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umal
loc.o
riscv64-unknown-elf-ld: warning: xv6-user/_cat has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_cat > xv6-user/cat.asm
riscv64-unknown-elf-objdump -t xv6-user/_cat | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/cat.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/echo.o xv6-user/echo.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_echo xv6-user/echo.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_echo has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_echo > xv6-user/echo.asm
riscv64-unknown-elf-objdump -t xv6-user/_echo | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/echo.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/grep.o xv6-user/grep.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_grep xv6-user/grep.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_grep has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_grep > xv6-user/grep.asm
riscv64-unknown-elf-objdump -t xv6-user/_grep | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/grep.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/ls.o xv6-user/ls.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_ls xv6-user/ls.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umallo
c.o
riscv64-unknown-elf-ld: warning: xv6-user/_ls has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_ls > xv6-user/ls.asm
riscv64-unknown-elf-objdump -t xv6-user/_ls | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/ls.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/kill.o xv6-user/kill.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_kill xv6-user/kill.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_kill has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_kill > xv6-user/kill.asm
riscv64-unknown-elf-objdump -t xv6-user/_kill | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/kill.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/mkdir.o xv6-user/mkdir.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_mkdir xv6-user/mkdir.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/
umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_mkdir has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_mkdir > xv6-user/mkdir.asm
riscv64-unknown-elf-objdump -t xv6-user/_mkdir | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/mkdir.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/xargs.o xv6-user/xargs.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_xargs xv6-user/xargs.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/
umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_xargs has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_xargs > xv6-user/xargs.asm
riscv64-unknown-elf-objdump -t xv6-user/_xargs | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/xargs.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/sleep.o xv6-user/sleep.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_sleep xv6-user/sleep.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/
umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_sleep has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_sleep > xv6-user/sleep.asm
riscv64-unknown-elf-objdump -t xv6-user/_sleep | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/sleep.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/find.o xv6-user/find.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_find xv6-user/find.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_find has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_find > xv6-user/find.asm
riscv64-unknown-elf-objdump -t xv6-user/_find | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/find.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/rm.o xv6-user/rm.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_rm xv6-user/rm.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umallo
c.o
riscv64-unknown-elf-ld: warning: xv6-user/_rm has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_rm > xv6-user/rm.asm
riscv64-unknown-elf-objdump -t xv6-user/_rm | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/rm.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/wc.o xv6-user/wc.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_wc xv6-user/wc.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umallo
c.o
riscv64-unknown-elf-ld: warning: xv6-user/_wc has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_wc > xv6-user/wc.asm
riscv64-unknown-elf-objdump -t xv6-user/_wc | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/wc.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/test.o xv6-user/test.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_test xv6-user/test.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_test has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_test > xv6-user/test.asm
riscv64-unknown-elf-objdump -t xv6-user/_test | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/test.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/usertests.o xv6-user/usertests.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_usertests xv6-user/usertests.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o x
v6-user/umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_usertests has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_usertests > xv6-user/usertests.asm
riscv64-unknown-elf-objdump -t xv6-user/_usertests | sed '1,/SYMBOL TABLE/d; s/
.* / /; /^$/d' > xv6-user/usertests.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/strace.o
xv6-user/strace.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_strace xv6-user/strace.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-use
r/umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_strace has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_strace > xv6-user/strace.asm
riscv64-unknown-elf-objdump -t xv6-user/_strace | sed '1,/SYMBOL TABLE/d; s/ .*
/ /; /^$/d' > xv6-user/strace.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/mv.o xv6-user/mv.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_mv xv6-user/mv.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umallo
c.o
riscv64-unknown-elf-ld: warning: xv6-user/_mv has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_mv > xv6-user/mv.asm
riscv64-unknown-elf-objdump -t xv6-user/_mv | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/mv.sym
*** QEMU 已在 :1234 等待 gdb，请在另⼀个终端运⾏: ***
 gdb-multiarch target/kernel -ex 'set arch riscv:rv64' -ex 'target remote localhost:1234'
qemu-system-riscv64: -device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0: Failed to get "write" lock
Is another process using the image [fs.img]?
make: *** [Makefile:159：gdb] 错误 1
```

### 录像时间：2026-09-03T17:35:22.229+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
make gdb

[终端输出]
[sudo] ailab-os 的密码：
对不起，请重试。
[sudo] ailab-os 的密码：
*** QEMU 已在 :1234 等待 gdb，请在另⼀个终端运⾏: ***
 gdb-multiarch target/kernel -ex 'set arch riscv:rv64' -ex 'target remote localhost:1234'
qemu-system-riscv64: -device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0: Failed to get "write" lock
Is another process using the image [fs.img]?
make: *** [Makefile:159：gdb] 错误 1
```

### 录像时间：2026-09-03T17:35:39.157+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
make fs
```

### 录像时间：2026-09-03T17:35:48.613+08:00（北京时间）

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
xv6-user/_init xv6-user/_sh xv6-user/_cat xv6-user/_echo xv6-user/_grep xv6-user/_ls xv6-user/_kill xv6-user/_mkdir xv6-user/_xargs xv6-user/_sleep xv6-user/_fi
nd xv6-user/_rm xv6-user/_wc xv6-user/_test xv6-user/_usertests xv6-user/_strace xv6-user/_mv
```

### 录像时间：2026-09-03T17:35:55.813+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
make build

[终端输出]
riscv64-unknown-elf-gcc    -c -o kernel/entry_qemu.o kernel/entry_qemu.S
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/printf.o kernel/printf.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/kalloc.o kernel/kalloc.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/intr.o kernel/intr.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/spinlock.o
kernel/spinlock.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/string.o kernel/string.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/main.o kernel/main.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/vm.o kernel/vm.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/proc.o kernel/proc.c
riscv64-unknown-elf-gcc    -c -o kernel/swtch.o kernel/swtch.S
riscv64-unknown-elf-gcc    -c -o kernel/trampoline.o kernel/trampoline.S
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/trap.o kernel/trap.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/syscall.o kernel/syscall.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/sysproc.o kernel/sysproc.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/bio.o kernel/bio.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/sleeplock.o kernel/sleeplock.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/file.o kernel/file.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/pipe.o kernel/pipe.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/exec.o kernel/exec.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/sysfile.o kernel/sysfile.c
riscv64-unknown-elf-gcc    -c -o kernel/kernelvec.o kernel/kernelvec.S
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/timer.o kernel/timer.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/disk.o kernel/disk.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/fat32.o kernel/fat32.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/plic.o kernel/plic.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/console.o kernel/console.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/virtio_disk.o kernel/virtio_disk.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU -march=rv64g -nostdinc -I. -Ikernel -c xv6-user/initcode.S -o xv6-user/initcode.o
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e start -Ttext 0 -o xv6-user/initcode.out xv6-user/initcode.o
riscv64-unknown-elf-ld: warning: xv6-user/initcode.out has a LOAD segment with RWX permissions
riscv64-unknown-elf-objcopy -S -O binary xv6-user/initcode.out xv6-user/initcoderiscv64-unknown-elf-objdump -S xv6-user/initcode.o > xv6-user/initcode.asm
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/ulib.o xv6-user/ulib.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU -c -o xv6-user/usys.o xv6-user/usys.S
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/printf.o
xv6-user/printf.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/umalloc.o xv6-user/umalloc.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/init.o xv6-user/init.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_init xv6-user/init.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_init has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_init > xv6-user/init.asm
riscv64-unknown-elf-objdump -t xv6-user/_init | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/init.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/sh.o xv6-user/sh.c
xv6-user/sh.c: In function 'runcmd':
xv6-user/sh.c:157:1: warning: infinite recursion detected [-Winfinite-recursion]  157 | runcmd(struct cmd *cmd)
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
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_sh xv6-user/sh.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umallo
c.o
riscv64-unknown-elf-ld: warning: xv6-user/_sh has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_sh > xv6-user/sh.asm
riscv64-unknown-elf-objdump -t xv6-user/_sh | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/sh.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/cat.o xv6-user/cat.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_cat xv6-user/cat.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umal
loc.o
riscv64-unknown-elf-ld: warning: xv6-user/_cat has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_cat > xv6-user/cat.asm
riscv64-unknown-elf-objdump -t xv6-user/_cat | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/cat.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/echo.o xv6-user/echo.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_echo xv6-user/echo.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_echo has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_echo > xv6-user/echo.asm
riscv64-unknown-elf-objdump -t xv6-user/_echo | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/echo.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/grep.o xv6-user/grep.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_grep xv6-user/grep.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_grep has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_grep > xv6-user/grep.asm
riscv64-unknown-elf-objdump -t xv6-user/_grep | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/grep.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/ls.o xv6-user/ls.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_ls xv6-user/ls.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umallo
c.o
riscv64-unknown-elf-ld: warning: xv6-user/_ls has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_ls > xv6-user/ls.asm
riscv64-unknown-elf-objdump -t xv6-user/_ls | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/ls.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/kill.o xv6-user/kill.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_kill xv6-user/kill.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_kill has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_kill > xv6-user/kill.asm
riscv64-unknown-elf-objdump -t xv6-user/_kill | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/kill.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/mkdir.o xv6-user/mkdir.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_mkdir xv6-user/mkdir.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/
umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_mkdir has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_mkdir > xv6-user/mkdir.asm
riscv64-unknown-elf-objdump -t xv6-user/_mkdir | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/mkdir.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/xargs.o xv6-user/xargs.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_xargs xv6-user/xargs.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/
umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_xargs has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_xargs > xv6-user/xargs.asm
riscv64-unknown-elf-objdump -t xv6-user/_xargs | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/xargs.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/sleep.o xv6-user/sleep.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_sleep xv6-user/sleep.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/
umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_sleep has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_sleep > xv6-user/sleep.asm
riscv64-unknown-elf-objdump -t xv6-user/_sleep | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/sleep.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/find.o xv6-user/find.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_find xv6-user/find.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_find has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_find > xv6-user/find.asm
riscv64-unknown-elf-objdump -t xv6-user/_find | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/find.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/rm.o xv6-user/rm.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_rm xv6-user/rm.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umallo
c.o
riscv64-unknown-elf-ld: warning: xv6-user/_rm has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_rm > xv6-user/rm.asm
riscv64-unknown-elf-objdump -t xv6-user/_rm | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/rm.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/wc.o xv6-user/wc.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_wc xv6-user/wc.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umallo
c.o
riscv64-unknown-elf-ld: warning: xv6-user/_wc has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_wc > xv6-user/wc.asm
riscv64-unknown-elf-objdump -t xv6-user/_wc | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/wc.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/test.o xv6-user/test.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_test xv6-user/test.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_test has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_test > xv6-user/test.asm
riscv64-unknown-elf-objdump -t xv6-user/_test | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/test.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/usertests.o xv6-user/usertests.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_usertests xv6-user/usertests.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o x
v6-user/umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_usertests has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_usertests > xv6-user/usertests.asm
riscv64-unknown-elf-objdump -t xv6-user/_usertests | sed '1,/SYMBOL TABLE/d; s/
.* / /; /^$/d' > xv6-user/usertests.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/strace.o
xv6-user/strace.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_strace xv6-user/strace.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-use
r/umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_strace has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_strace > xv6-user/strace.asm
riscv64-unknown-elf-objdump -t xv6-user/_strace | sed '1,/SYMBOL TABLE/d; s/ .*
/ /; /^$/d' > xv6-user/strace.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/mv.o xv6-user/mv.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_mv xv6-user/mv.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umallo
c.o
riscv64-unknown-elf-ld: warning: xv6-user/_mv has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_mv > xv6-user/mv.asm
riscv64-unknown-elf-objdump -t xv6-user/_mv | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/mv.sym
```

### 录像时间：2026-09-03T17:36:01.300+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
make fa

[终端输出]
make: *** 没有规则可制作目标“fa”。 停止。
```

### 录像时间：2026-09-03T17:36:03.541+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
make fs
```

### 录像时间：2026-09-03T17:37:36.212+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
make gdb

[终端输出]
*** QEMU 已在 :1234 等待 gdb，请在另⼀个终端运⾏: ***
 gdb-multiarch target/kernel -ex 'set arch riscv:rv64' -ex 'target remote localhost:1234'
qemu-system-riscv64: -device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0: Failed to get "write" lock
Is another process using the image [fs.img]?
make: *** [Makefile:159：gdb] 错误 1
```

### 录像时间：2026-09-03T17:38:31.877+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
make clean

[终端输出]
rm -f *.tex *.dvi *.idx *.aux *.log *.ind *.ilg fs.img\
*/*.o */*.d */*.asm */*.sym \
target/* \
xv6-user/initcode xv6-user/initcode.out \
kernel/kernel \
.gdbinit \
xv6-user/usys.S \
xv6-user/_init xv6-user/_sh xv6-user/_cat xv6-user/_echo xv6-user/_grep xv6-user/_ls xv6-user/_kill xv6-user/_mkdir xv6-user/_xargs xv6-user/_sleep xv6-user/_fi
nd xv6-user/_rm xv6-user/_wc xv6-user/_test xv6-user/_usertests xv6-user/_strace xv6-user/_mv
```

### 录像时间：2026-09-03T17:38:41.765+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
make gdb

[终端输出]
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU -march=rv64g -nostdinc -I. -Ikernel -c xv6-user/initcode.S -o xv6-user/initcode.o
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e start -Ttext 0 -o xv6-user/initcode.out xv6-user/initcode.o
riscv64-unknown-elf-ld: warning: xv6-user/initcode.out has a LOAD segment with RWX permissions
riscv64-unknown-elf-objcopy -S -O binary xv6-user/initcode.out xv6-user/initcoderiscv64-unknown-elf-objdump -S xv6-user/initcode.o > xv6-user/initcode.asm
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU -c -o xv6-user/usys.o xv6-user/usys.S
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_init xv6-user/init.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_init has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_init > xv6-user/init.asm
riscv64-unknown-elf-objdump -t xv6-user/_init | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/init.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_sh xv6-user/sh.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umallo
c.o
riscv64-unknown-elf-ld: warning: xv6-user/_sh has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_sh > xv6-user/sh.asm
riscv64-unknown-elf-objdump -t xv6-user/_sh | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/sh.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_cat xv6-user/cat.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umal
loc.o
riscv64-unknown-elf-ld: warning: xv6-user/_cat has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_cat > xv6-user/cat.asm
riscv64-unknown-elf-objdump -t xv6-user/_cat | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/cat.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_echo xv6-user/echo.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_echo has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_echo > xv6-user/echo.asm
riscv64-unknown-elf-objdump -t xv6-user/_echo | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/echo.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_grep xv6-user/grep.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_grep has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_grep > xv6-user/grep.asm
riscv64-unknown-elf-objdump -t xv6-user/_grep | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/grep.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_ls xv6-user/ls.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umallo
c.o
riscv64-unknown-elf-ld: warning: xv6-user/_ls has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_ls > xv6-user/ls.asm
riscv64-unknown-elf-objdump -t xv6-user/_ls | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/ls.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_kill xv6-user/kill.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_kill has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_kill > xv6-user/kill.asm
riscv64-unknown-elf-objdump -t xv6-user/_kill | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/kill.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_mkdir xv6-user/mkdir.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/
umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_mkdir has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_mkdir > xv6-user/mkdir.asm
riscv64-unknown-elf-objdump -t xv6-user/_mkdir | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/mkdir.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_xargs xv6-user/xargs.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/
umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_xargs has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_xargs > xv6-user/xargs.asm
riscv64-unknown-elf-objdump -t xv6-user/_xargs | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/xargs.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_sleep xv6-user/sleep.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/
umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_sleep has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_sleep > xv6-user/sleep.asm
riscv64-unknown-elf-objdump -t xv6-user/_sleep | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/sleep.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_find xv6-user/find.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_find has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_find > xv6-user/find.asm
riscv64-unknown-elf-objdump -t xv6-user/_find | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/find.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_rm xv6-user/rm.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umallo
c.o
riscv64-unknown-elf-ld: warning: xv6-user/_rm has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_rm > xv6-user/rm.asm
riscv64-unknown-elf-objdump -t xv6-user/_rm | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/rm.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_wc xv6-user/wc.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umallo
c.o
riscv64-unknown-elf-ld: warning: xv6-user/_wc has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_wc > xv6-user/wc.asm
riscv64-unknown-elf-objdump -t xv6-user/_wc | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/wc.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_test xv6-user/test.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_test has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_test > xv6-user/test.asm
riscv64-unknown-elf-objdump -t xv6-user/_test | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/test.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_usertests xv6-user/usertests.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o x
v6-user/umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_usertests has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_usertests > xv6-user/usertests.asm
riscv64-unknown-elf-objdump -t xv6-user/_usertests | sed '1,/SYMBOL TABLE/d; s/
.* / /; /^$/d' > xv6-user/usertests.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_strace xv6-user/strace.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-use
r/umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_strace has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_strace > xv6-user/strace.asm
riscv64-unknown-elf-objdump -t xv6-user/_strace | sed '1,/SYMBOL TABLE/d; s/ .*
/ /; /^$/d' > xv6-user/strace.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_mv xv6-user/mv.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umallo
c.o
riscv64-unknown-elf-ld: warning: xv6-user/_mv has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_mv > xv6-user/mv.asm
riscv64-unknown-elf-objdump -t xv6-user/_mv | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/mv.sym
*** QEMU 已在 :1234 等待 gdb，请在另⼀个终端运⾏: ***
 gdb-multiarch target/kernel -ex 'set arch riscv:rv64' -ex 'target remote localhost:1234'
qemu-system-riscv64: -device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0: Failed to get "write" lock
Is another process using the image [fs.img]?
make: *** [Makefile:159：gdb] 错误 1
```

### 录像时间：2026-09-03T17:39:08.900+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
make clean

[终端输出]
rm -f *.tex *.dvi *.idx *.aux *.log *.ind *.ilg fs.img\
*/*.o */*.d */*.asm */*.sym \
target/* \
xv6-user/initcode xv6-user/initcode.out \
kernel/kernel \
.gdbinit \
xv6-user/usys.S \
xv6-user/_init xv6-user/_sh xv6-user/_cat xv6-user/_echo xv6-user/_grep xv6-user/_ls xv6-user/_kill xv6-user/_mkdir xv6-user/_xargs xv6-user/_sleep xv6-user/_fi
nd xv6-user/_rm xv6-user/_wc xv6-user/_test xv6-user/_usertests xv6-user/_strace xv6-user/_mv
```

### 录像时间：2026-09-03T17:42:29.637+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
make gdb

[终端输出]
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU -march=rv64g -nostdinc -I. -Ikernel -c xv6-user/initcode.S -o xv6-user/initcode.o
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e start -Ttext 0 -o xv6-user/initcode.out xv6-user/initcode.o
riscv64-unknown-elf-ld: warning: xv6-user/initcode.out has a LOAD segment with RWX permissions
riscv64-unknown-elf-objcopy -S -O binary xv6-user/initcode.out xv6-user/initcoderiscv64-unknown-elf-objdump -S xv6-user/initcode.o > xv6-user/initcode.asm
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU -c -o xv6-user/usys.o xv6-user/usys.S
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_init xv6-user/init.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_init has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_init > xv6-user/init.asm
riscv64-unknown-elf-objdump -t xv6-user/_init | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/init.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_sh xv6-user/sh.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umallo
c.o
riscv64-unknown-elf-ld: warning: xv6-user/_sh has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_sh > xv6-user/sh.asm
riscv64-unknown-elf-objdump -t xv6-user/_sh | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/sh.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_cat xv6-user/cat.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umal
loc.o
riscv64-unknown-elf-ld: warning: xv6-user/_cat has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_cat > xv6-user/cat.asm
riscv64-unknown-elf-objdump -t xv6-user/_cat | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/cat.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_echo xv6-user/echo.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_echo has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_echo > xv6-user/echo.asm
riscv64-unknown-elf-objdump -t xv6-user/_echo | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/echo.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_grep xv6-user/grep.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_grep has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_grep > xv6-user/grep.asm
riscv64-unknown-elf-objdump -t xv6-user/_grep | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/grep.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_ls xv6-user/ls.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umallo
c.o
riscv64-unknown-elf-ld: warning: xv6-user/_ls has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_ls > xv6-user/ls.asm
riscv64-unknown-elf-objdump -t xv6-user/_ls | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/ls.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_kill xv6-user/kill.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_kill has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_kill > xv6-user/kill.asm
riscv64-unknown-elf-objdump -t xv6-user/_kill | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/kill.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_mkdir xv6-user/mkdir.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/
umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_mkdir has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_mkdir > xv6-user/mkdir.asm
riscv64-unknown-elf-objdump -t xv6-user/_mkdir | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/mkdir.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_xargs xv6-user/xargs.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/
umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_xargs has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_xargs > xv6-user/xargs.asm
riscv64-unknown-elf-objdump -t xv6-user/_xargs | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/xargs.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_sleep xv6-user/sleep.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/
umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_sleep has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_sleep > xv6-user/sleep.asm
riscv64-unknown-elf-objdump -t xv6-user/_sleep | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/sleep.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_find xv6-user/find.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_find has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_find > xv6-user/find.asm
riscv64-unknown-elf-objdump -t xv6-user/_find | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/find.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_rm xv6-user/rm.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umallo
c.o
riscv64-unknown-elf-ld: warning: xv6-user/_rm has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_rm > xv6-user/rm.asm
riscv64-unknown-elf-objdump -t xv6-user/_rm | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/rm.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_wc xv6-user/wc.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umallo
c.o
riscv64-unknown-elf-ld: warning: xv6-user/_wc has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_wc > xv6-user/wc.asm
riscv64-unknown-elf-objdump -t xv6-user/_wc | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/wc.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_test xv6-user/test.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_test has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_test > xv6-user/test.asm
riscv64-unknown-elf-objdump -t xv6-user/_test | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/test.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_usertests xv6-user/usertests.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o x
v6-user/umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_usertests has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_usertests > xv6-user/usertests.asm
riscv64-unknown-elf-objdump -t xv6-user/_usertests | sed '1,/SYMBOL TABLE/d; s/
.* / /; /^$/d' > xv6-user/usertests.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_strace xv6-user/strace.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-use
r/umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_strace has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_strace > xv6-user/strace.asm
riscv64-unknown-elf-objdump -t xv6-user/_strace | sed '1,/SYMBOL TABLE/d; s/ .*
/ /; /^$/d' > xv6-user/strace.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_mv xv6-user/mv.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umallo
c.o
riscv64-unknown-elf-ld: warning: xv6-user/_mv has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_mv > xv6-user/mv.asm
riscv64-unknown-elf-objdump -t xv6-user/_mv | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/mv.sym
*** QEMU 已在 :1234 等待 gdb，请在另⼀个终端运⾏: ***
 gdb-multiarch target/kernel -ex 'set arch riscv:rv64' -ex 'target remote localhost:1234'
qemu-system-riscv64: -device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0: Failed to get "write" lock
Is another process using the image [fs.img]?
make: *** [Makefile:159：gdb] 错误 1
```

### 录像时间：2026-09-03T17:42:41.875+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
claude
```

### 录像时间：2026-09-03T17:46:43.828+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
make run

[终端输出]
qemu-system-riscv64: -device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0: Failed to get "write" lock
Is another process using the image [fs.img]?
make: *** [Makefile:152：run] 错误 1
```

### 录像时间：2026-09-03T17:47:04.310+08:00（北京时间）

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
Domain0 Region01          : 0x0000000080040000-0x000000008005ffff M: (R,W) S/U:
()
Domain0 Region02          : 0x0000000080000000-0x000000008003ffff M: (R,X) S/U:
()
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
panic: could not find virtio disk
backtrace:
0x0000000080200180
0x0000000080207464
0x0000000080205206
0x0000000080200ad6
```

### 录像时间：2026-09-03T17:51:17.534+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
make clean

[终端输出]
rm -f *.tex *.dvi *.idx *.aux *.log *.ind *.ilg fs.img\
*/*.o */*.d */*.asm */*.sym \
target/* \
xv6-user/initcode xv6-user/initcode.out \
kernel/kernel \
.gdbinit \
xv6-user/usys.S \
xv6-user/_init xv6-user/_sh xv6-user/_cat xv6-user/_echo xv6-user/_grep xv6-user/_ls xv6-user/_kill xv6-user/_mkdir xv6-user/_xargs xv6-user/_sleep xv6-user/_fi
nd xv6-user/_rm xv6-user/_wc xv6-user/_test xv6-user/_usertests xv6-user/_strace xv6-user/_mv
```

### 录像时间：2026-09-03T17:51:20.542+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
make run

[终端输出]
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU -march=rv64g -nostdinc -I. -Ikernel -c xv6-user/initcode.S -o xv6-user/initcode.o
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e start -Ttext 0 -o xv6-user/initcode.out xv6-user/initcode.o
riscv64-unknown-elf-ld: warning: xv6-user/initcode.out has a LOAD segment with RWX permissions
riscv64-unknown-elf-objcopy -S -O binary xv6-user/initcode.out xv6-user/initcoderiscv64-unknown-elf-objdump -S xv6-user/initcode.o > xv6-user/initcode.asm
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU -c -o xv6-user/usys.o xv6-user/usys.S
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_init xv6-user/init.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_init has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_init > xv6-user/init.asm
riscv64-unknown-elf-objdump -t xv6-user/_init | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/init.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_sh xv6-user/sh.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umallo
c.o
riscv64-unknown-elf-ld: warning: xv6-user/_sh has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_sh > xv6-user/sh.asm
riscv64-unknown-elf-objdump -t xv6-user/_sh | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/sh.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_cat xv6-user/cat.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umal
loc.o
riscv64-unknown-elf-ld: warning: xv6-user/_cat has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_cat > xv6-user/cat.asm
riscv64-unknown-elf-objdump -t xv6-user/_cat | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/cat.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_echo xv6-user/echo.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_echo has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_echo > xv6-user/echo.asm
riscv64-unknown-elf-objdump -t xv6-user/_echo | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/echo.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_grep xv6-user/grep.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_grep has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_grep > xv6-user/grep.asm
riscv64-unknown-elf-objdump -t xv6-user/_grep | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/grep.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_ls xv6-user/ls.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umallo
c.o
riscv64-unknown-elf-ld: warning: xv6-user/_ls has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_ls > xv6-user/ls.asm
riscv64-unknown-elf-objdump -t xv6-user/_ls | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/ls.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_kill xv6-user/kill.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_kill has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_kill > xv6-user/kill.asm
riscv64-unknown-elf-objdump -t xv6-user/_kill | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/kill.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_mkdir xv6-user/mkdir.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/
umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_mkdir has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_mkdir > xv6-user/mkdir.asm
riscv64-unknown-elf-objdump -t xv6-user/_mkdir | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/mkdir.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_xargs xv6-user/xargs.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/
umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_xargs has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_xargs > xv6-user/xargs.asm
riscv64-unknown-elf-objdump -t xv6-user/_xargs | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/xargs.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_sleep xv6-user/sleep.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/
umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_sleep has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_sleep > xv6-user/sleep.asm
riscv64-unknown-elf-objdump -t xv6-user/_sleep | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/sleep.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_find xv6-user/find.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_find has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_find > xv6-user/find.asm
riscv64-unknown-elf-objdump -t xv6-user/_find | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/find.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_rm xv6-user/rm.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umallo
c.o
riscv64-unknown-elf-ld: warning: xv6-user/_rm has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_rm > xv6-user/rm.asm
riscv64-unknown-elf-objdump -t xv6-user/_rm | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/rm.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_wc xv6-user/wc.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umallo
c.o
riscv64-unknown-elf-ld: warning: xv6-user/_wc has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_wc > xv6-user/wc.asm
riscv64-unknown-elf-objdump -t xv6-user/_wc | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/wc.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_test xv6-user/test.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_test has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_test > xv6-user/test.asm
riscv64-unknown-elf-objdump -t xv6-user/_test | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/test.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_usertests xv6-user/usertests.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o x
v6-user/umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_usertests has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_usertests > xv6-user/usertests.asm
riscv64-unknown-elf-objdump -t xv6-user/_usertests | sed '1,/SYMBOL TABLE/d; s/
.* / /; /^$/d' > xv6-user/usertests.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_strace xv6-user/strace.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-use
r/umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_strace has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_strace > xv6-user/strace.asm
riscv64-unknown-elf-objdump -t xv6-user/_strace | sed '1,/SYMBOL TABLE/d; s/ .*
/ /; /^$/d' > xv6-user/strace.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_mv xv6-user/mv.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umallo
c.o
riscv64-unknown-elf-ld: warning: xv6-user/_mv has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_mv > xv6-user/mv.asm
riscv64-unknown-elf-objdump -t xv6-user/_mv | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/mv.sym
[sudo] ailab-os 的密码：

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
Domain0 Region01          : 0x0000000080040000-0x000000008005ffff M: (R,W) S/U:
()
Domain0 Region02          : 0x0000000080000000-0x000000008003ffff M: (R,X) S/U:
()
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
panic: could not find virtio disk
backtrace:
0x0000000080200180
0x0000000080207464
0x0000000080205206
0x0000000080200ad6
```

### 录像时间：2026-09-03T17:51:45.278+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
make run

[终端输出]
[sudo] ailab-os 的密码：
qemu-system-riscv64: -device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0: Failed to get "write" lock
Is another process using the image [fs.img]?
make: *** [Makefile:152：run] 错误 1
```

### 录像时间：2026-09-03T17:53:07.886+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
make clean

[终端输出]
rm -f *.tex *.dvi *.idx *.aux *.log *.ind *.ilg fs.img\
*/*.o */*.d */*.asm */*.sym \
target/* \
xv6-user/initcode xv6-user/initcode.out \
kernel/kernel \
.gdbinit \
xv6-user/usys.S \
xv6-user/_init xv6-user/_sh xv6-user/_cat xv6-user/_echo xv6-user/_grep xv6-user/_ls xv6-user/_kill xv6-user/_mkdir xv6-user/_xargs xv6-user/_sleep xv6-user/_fi
nd xv6-user/_rm xv6-user/_wc xv6-user/_test xv6-user/_usertests xv6-user/_strace xv6-user/_mv
```

### 录像时间：2026-09-03T17:53:21.981+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
make build

[终端输出]
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU -march=rv64g -nostdinc -I. -Ikernel -c xv6-user/initcode.S -o xv6-user/initcode.o
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e start -Ttext 0 -o xv6-user/initcode.out xv6-user/initcode.o
riscv64-unknown-elf-ld: warning: xv6-user/initcode.out has a LOAD segment with RWX permissions
riscv64-unknown-elf-objcopy -S -O binary xv6-user/initcode.out xv6-user/initcoderiscv64-unknown-elf-objdump -S xv6-user/initcode.o > xv6-user/initcode.asm
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU -c -o xv6-user/usys.o xv6-user/usys.S
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_init xv6-user/init.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_init has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_init > xv6-user/init.asm
riscv64-unknown-elf-objdump -t xv6-user/_init | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/init.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_sh xv6-user/sh.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umallo
c.o
riscv64-unknown-elf-ld: warning: xv6-user/_sh has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_sh > xv6-user/sh.asm
riscv64-unknown-elf-objdump -t xv6-user/_sh | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/sh.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_cat xv6-user/cat.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umal
loc.o
riscv64-unknown-elf-ld: warning: xv6-user/_cat has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_cat > xv6-user/cat.asm
riscv64-unknown-elf-objdump -t xv6-user/_cat | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/cat.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_echo xv6-user/echo.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_echo has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_echo > xv6-user/echo.asm
riscv64-unknown-elf-objdump -t xv6-user/_echo | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/echo.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_grep xv6-user/grep.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_grep has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_grep > xv6-user/grep.asm
riscv64-unknown-elf-objdump -t xv6-user/_grep | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/grep.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_ls xv6-user/ls.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umallo
c.o
riscv64-unknown-elf-ld: warning: xv6-user/_ls has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_ls > xv6-user/ls.asm
riscv64-unknown-elf-objdump -t xv6-user/_ls | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/ls.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_kill xv6-user/kill.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_kill has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_kill > xv6-user/kill.asm
riscv64-unknown-elf-objdump -t xv6-user/_kill | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/kill.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_mkdir xv6-user/mkdir.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/
umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_mkdir has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_mkdir > xv6-user/mkdir.asm
riscv64-unknown-elf-objdump -t xv6-user/_mkdir | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/mkdir.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_xargs xv6-user/xargs.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/
umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_xargs has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_xargs > xv6-user/xargs.asm
riscv64-unknown-elf-objdump -t xv6-user/_xargs | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/xargs.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_sleep xv6-user/sleep.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/
umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_sleep has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_sleep > xv6-user/sleep.asm
riscv64-unknown-elf-objdump -t xv6-user/_sleep | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/sleep.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_find xv6-user/find.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_find has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_find > xv6-user/find.asm
riscv64-unknown-elf-objdump -t xv6-user/_find | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/find.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_rm xv6-user/rm.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umallo
c.o
riscv64-unknown-elf-ld: warning: xv6-user/_rm has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_rm > xv6-user/rm.asm
riscv64-unknown-elf-objdump -t xv6-user/_rm | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/rm.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_wc xv6-user/wc.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umallo
c.o
riscv64-unknown-elf-ld: warning: xv6-user/_wc has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_wc > xv6-user/wc.asm
riscv64-unknown-elf-objdump -t xv6-user/_wc | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/wc.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_test xv6-user/test.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_test has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_test > xv6-user/test.asm
riscv64-unknown-elf-objdump -t xv6-user/_test | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/test.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_usertests xv6-user/usertests.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o x
v6-user/umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_usertests has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_usertests > xv6-user/usertests.asm
riscv64-unknown-elf-objdump -t xv6-user/_usertests | sed '1,/SYMBOL TABLE/d; s/
.* / /; /^$/d' > xv6-user/usertests.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_strace xv6-user/strace.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-use
r/umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_strace has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_strace > xv6-user/strace.asm
riscv64-unknown-elf-objdump -t xv6-user/_strace | sed '1,/SYMBOL TABLE/d; s/ .*
/ /; /^$/d' > xv6-user/strace.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_mv xv6-user/mv.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umallo
c.o
riscv64-unknown-elf-ld: warning: xv6-user/_mv has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_mv > xv6-user/mv.asm
riscv64-unknown-elf-objdump -t xv6-user/_mv | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/mv.sym
```

### 录像时间：2026-09-03T17:53:24.737+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
make fs
```

### 录像时间：2026-09-03T17:53:36.318+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
make run

[终端输出]
qemu-system-riscv64: -device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0: Failed to get "write" lock
Is another process using the image [fs.img]?
make: *** [Makefile:152：run] 错误 1
```

### 录像时间：2026-09-03T17:54:04.029+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
make fs

[终端输出]
making fs image...
输入了 512+0 块记录
输出了 512+0 块记录
268435456 字节 (268 MB, 256 MiB) 已复制，0.112941 s，2.4 GB/s
mkfs.fat 4.2 (2021-01-31)
```

### 录像时间：2026-09-03T17:54:10.145+08:00（北京时间）

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
Domain0 Region01          : 0x0000000080040000-0x000000008005ffff M: (R,W) S/U:
()
Domain0 Region02          : 0x0000000080000000-0x000000008003ffff M: (R,X) S/U:
()
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
-> / $
-> / $
```

### 录像时间：2026-09-03T17:54:26.285+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
make gdb

[终端输出]
*** QEMU 已在 :1234 等待 gdb，请在另⼀个终端运⾏: ***
 gdb-multiarch target/kernel -ex 'set arch riscv:rv64' -ex 'target remote localhost:1234'
qemu-system-riscv64: -device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0: Failed to get "write" lock
Is another process using the image [fs.img]?
make: *** [Makefile:159：gdb] 错误 1
```

### 录像时间：2026-09-03T17:54:46.925+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
make clean

[终端输出]
rm -f *.tex *.dvi *.idx *.aux *.log *.ind *.ilg fs.img\
*/*.o */*.d */*.asm */*.sym \
target/* \
xv6-user/initcode xv6-user/initcode.out \
kernel/kernel \
.gdbinit \
xv6-user/usys.S \
xv6-user/_init xv6-user/_sh xv6-user/_cat xv6-user/_echo xv6-user/_grep xv6-user/_ls xv6-user/_kill xv6-user/_mkdir xv6-user/_xargs xv6-user/_sleep xv6-user/_fi
nd xv6-user/_rm xv6-user/_wc xv6-user/_test xv6-user/_usertests xv6-user/_strace xv6-user/_mv
```

### 录像时间：2026-09-03T17:55:31.613+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
make fs

[终端输出]
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU -c -o xv6-user/usys.o xv6-user/usys.S
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_init xv6-user/init.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_init has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_init > xv6-user/init.asm
riscv64-unknown-elf-objdump -t xv6-user/_init | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/init.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_sh xv6-user/sh.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umallo
c.o
riscv64-unknown-elf-ld: warning: xv6-user/_sh has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_sh > xv6-user/sh.asm
riscv64-unknown-elf-objdump -t xv6-user/_sh | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/sh.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_cat xv6-user/cat.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umal
loc.o
riscv64-unknown-elf-ld: warning: xv6-user/_cat has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_cat > xv6-user/cat.asm
riscv64-unknown-elf-objdump -t xv6-user/_cat | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/cat.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_echo xv6-user/echo.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_echo has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_echo > xv6-user/echo.asm
riscv64-unknown-elf-objdump -t xv6-user/_echo | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/echo.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_grep xv6-user/grep.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_grep has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_grep > xv6-user/grep.asm
riscv64-unknown-elf-objdump -t xv6-user/_grep | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/grep.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_ls xv6-user/ls.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umallo
c.o
riscv64-unknown-elf-ld: warning: xv6-user/_ls has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_ls > xv6-user/ls.asm
riscv64-unknown-elf-objdump -t xv6-user/_ls | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/ls.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_kill xv6-user/kill.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_kill has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_kill > xv6-user/kill.asm
riscv64-unknown-elf-objdump -t xv6-user/_kill | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/kill.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_mkdir xv6-user/mkdir.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/
umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_mkdir has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_mkdir > xv6-user/mkdir.asm
riscv64-unknown-elf-objdump -t xv6-user/_mkdir | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/mkdir.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_xargs xv6-user/xargs.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/
umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_xargs has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_xargs > xv6-user/xargs.asm
riscv64-unknown-elf-objdump -t xv6-user/_xargs | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/xargs.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_sleep xv6-user/sleep.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/
umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_sleep has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_sleep > xv6-user/sleep.asm
riscv64-unknown-elf-objdump -t xv6-user/_sleep | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/sleep.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_find xv6-user/find.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_find has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_find > xv6-user/find.asm
riscv64-unknown-elf-objdump -t xv6-user/_find | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/find.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_rm xv6-user/rm.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umallo
c.o
riscv64-unknown-elf-ld: warning: xv6-user/_rm has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_rm > xv6-user/rm.asm
riscv64-unknown-elf-objdump -t xv6-user/_rm | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/rm.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_wc xv6-user/wc.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umallo
c.o
riscv64-unknown-elf-ld: warning: xv6-user/_wc has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_wc > xv6-user/wc.asm
riscv64-unknown-elf-objdump -t xv6-user/_wc | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/wc.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_test xv6-user/test.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_test has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_test > xv6-user/test.asm
riscv64-unknown-elf-objdump -t xv6-user/_test | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/test.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_usertests xv6-user/usertests.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o x
v6-user/umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_usertests has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_usertests > xv6-user/usertests.asm
riscv64-unknown-elf-objdump -t xv6-user/_usertests | sed '1,/SYMBOL TABLE/d; s/
.* / /; /^$/d' > xv6-user/usertests.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_strace xv6-user/strace.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-use
r/umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_strace has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_strace > xv6-user/strace.asm
riscv64-unknown-elf-objdump -t xv6-user/_strace | sed '1,/SYMBOL TABLE/d; s/ .*
/ /; /^$/d' > xv6-user/strace.sym
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_mv xv6-user/mv.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umallo
c.o
riscv64-unknown-elf-ld: warning: xv6-user/_mv has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_mv > xv6-user/mv.asm
riscv64-unknown-elf-objdump -t xv6-user/_mv | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/mv.sym
[sudo] ailab-os 的密码：
对不起，请重试。
[sudo] ailab-os 的密码：
对不起，请重试。
[sudo] ailab-os 的密码：
```

### 录像时间：2026-09-03T17:55:57.709+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
make clean

[终端输出]
rm -f fs.img
rm -f *.tex *.dvi *.idx *.aux *.log *.ind *.ilg \
*/*.o */*.d */*.asm */*.sym \
target/* \
xv6-user/initcode xv6-user/initcode.out \
kernel/kernel \
.gdbinit \
xv6-user/usys.S \
xv6-user/_init xv6-user/_sh xv6-user/_cat xv6-user/_echo xv6-user/_grep xv6-user/_ls xv6-user/_kill xv6-user/_mkdir xv6-user/_xargs xv6-user/_sleep xv6-user/_fi
nd xv6-user/_rm xv6-user/_wc xv6-user/_test xv6-user/_usertests xv6-user/_strace xv6-user/_mv
```

### 录像时间：2026-09-03T17:56:02.125+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
make clean

[终端输出]
                                                                           fs
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/ulib.o xv6-user/ulib.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU -c -o xv6-user/usys.o xv6-user/usys.S
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/printf.o
xv6-user/printf.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/umalloc.o xv6-user/umalloc.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/init.o xv6-user/init.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_init xv6-user/init.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_init has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_init > xv6-user/init.asm
riscv64-unknown-elf-objdump -t xv6-user/_init | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/init.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/sh.o xv6-user/sh.c
xv6-user/sh.c: In function 'runcmd':
xv6-user/sh.c:157:1: warning: infinite recursion detected [-Winfinite-recursion]  157 | runcmd(struct cmd *cmd)
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
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_sh xv6-user/sh.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umallo
c.o
riscv64-unknown-elf-ld: warning: xv6-user/_sh has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_sh > xv6-user/sh.asm
riscv64-unknown-elf-objdump -t xv6-user/_sh | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/sh.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/cat.o xv6-user/cat.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_cat xv6-user/cat.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umal
loc.o
riscv64-unknown-elf-ld: warning: xv6-user/_cat has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_cat > xv6-user/cat.asm
riscv64-unknown-elf-objdump -t xv6-user/_cat | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/cat.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/echo.o xv6-user/echo.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_echo xv6-user/echo.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_echo has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_echo > xv6-user/echo.asm
riscv64-unknown-elf-objdump -t xv6-user/_echo | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/echo.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/grep.o xv6-user/grep.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_grep xv6-user/grep.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_grep has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_grep > xv6-user/grep.asm
riscv64-unknown-elf-objdump -t xv6-user/_grep | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/grep.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/ls.o xv6-user/ls.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_ls xv6-user/ls.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umallo
c.o
riscv64-unknown-elf-ld: warning: xv6-user/_ls has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_ls > xv6-user/ls.asm
riscv64-unknown-elf-objdump -t xv6-user/_ls | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/ls.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/kill.o xv6-user/kill.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_kill xv6-user/kill.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_kill has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_kill > xv6-user/kill.asm
riscv64-unknown-elf-objdump -t xv6-user/_kill | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/kill.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/mkdir.o xv6-user/mkdir.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_mkdir xv6-user/mkdir.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/
umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_mkdir has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_mkdir > xv6-user/mkdir.asm
riscv64-unknown-elf-objdump -t xv6-user/_mkdir | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/mkdir.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/xargs.o xv6-user/xargs.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_xargs xv6-user/xargs.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/
umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_xargs has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_xargs > xv6-user/xargs.asm
riscv64-unknown-elf-objdump -t xv6-user/_xargs | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/xargs.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/sleep.o xv6-user/sleep.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_sleep xv6-user/sleep.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/
umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_sleep has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_sleep > xv6-user/sleep.asm
riscv64-unknown-elf-objdump -t xv6-user/_sleep | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/sleep.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/find.o xv6-user/find.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_find xv6-user/find.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_find has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_find > xv6-user/find.asm
riscv64-unknown-elf-objdump -t xv6-user/_find | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/find.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/rm.o xv6-user/rm.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_rm xv6-user/rm.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umallo
c.o
riscv64-unknown-elf-ld: warning: xv6-user/_rm has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_rm > xv6-user/rm.asm
riscv64-unknown-elf-objdump -t xv6-user/_rm | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/rm.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/wc.o xv6-user/wc.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_wc xv6-user/wc.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umallo
c.o
riscv64-unknown-elf-ld: warning: xv6-user/_wc has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_wc > xv6-user/wc.asm
riscv64-unknown-elf-objdump -t xv6-user/_wc | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/wc.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/test.o xv6-user/test.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_test xv6-user/test.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/um
alloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_test has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_test > xv6-user/test.asm
riscv64-unknown-elf-objdump -t xv6-user/_test | sed '1,/SYMBOL TABLE/d; s/ .* /
/; /^$/d' > xv6-user/test.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/usertests.o xv6-user/usertests.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_usertests xv6-user/usertests.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o x
v6-user/umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_usertests has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_usertests > xv6-user/usertests.asm
riscv64-unknown-elf-objdump -t xv6-user/_usertests | sed '1,/SYMBOL TABLE/d; s/
.* / /; /^$/d' > xv6-user/usertests.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/strace.o
xv6-user/strace.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_strace xv6-user/strace.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-use
r/umalloc.o
riscv64-unknown-elf-ld: warning: xv6-user/_strace has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_strace > xv6-user/strace.asm
riscv64-unknown-elf-objdump -t xv6-user/_strace | sed '1,/SYMBOL TABLE/d; s/ .*
/ /; /^$/d' > xv6-user/strace.sym
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o xv6-user/mv.o xv6-user/mv.c
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o xv6-user/_mv xv6-user/mv.o xv6-user/ulib.o xv6-user/usys.o xv6-user/printf.o xv6-user/umallo
c.o
riscv64-unknown-elf-ld: warning: xv6-user/_mv has a LOAD segment with RWX permissions
riscv64-unknown-elf-objdump -S xv6-user/_mv > xv6-user/mv.asm
riscv64-unknown-elf-objdump -t xv6-user/_mv | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > xv6-user/mv.sym
making fs image...
输入了 512+0 块记录
输出了 512+0 块记录
268435456 字节 (268 MB, 256 MiB) 已复制，0.134451 s，2.0 GB/s
mkfs.fat 4.2 (2021-01-31)
```

### 录像时间：2026-09-03T17:56:14.381+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
make gdb

[终端输出]
riscv64-unknown-elf-gcc    -c -o kernel/entry_qemu.o kernel/entry_qemu.S
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/printf.o kernel/printf.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/kalloc.o kernel/kalloc.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/intr.o kernel/intr.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/spinlock.o
kernel/spinlock.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/string.o kernel/string.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/main.o kernel/main.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/vm.o kernel/vm.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/proc.o kernel/proc.c
riscv64-unknown-elf-gcc    -c -o kernel/swtch.o kernel/swtch.S
riscv64-unknown-elf-gcc    -c -o kernel/trampoline.o kernel/trampoline.S
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/trap.o kernel/trap.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/syscall.o kernel/syscall.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/sysproc.o kernel/sysproc.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/bio.o kernel/bio.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/sleeplock.o kernel/sleeplock.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/file.o kernel/file.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/pipe.o kernel/pipe.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/exec.o kernel/exec.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/sysfile.o kernel/sysfile.c
riscv64-unknown-elf-gcc    -c -o kernel/kernelvec.o kernel/kernelvec.S
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/timer.o kernel/timer.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/disk.o kernel/disk.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/fat32.o kernel/fat32.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/plic.o kernel/plic.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/console.o kernel/console.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU   -c -o kernel/virtio_disk.o kernel/virtio_disk.c
riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O -fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib
 -mno-relax -I. -fno-stack-protector -DDEBUG  -D QEMU -march=rv64g -nostdinc -I. -Ikernel -c xv6-user/initcode.S -o xv6-user/initcode.o
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e start -Ttext 0 -o xv6-user/initcode.out xv6-user/initcode.o
riscv64-unknown-elf-ld: warning: xv6-user/initcode.out has a LOAD segment with RWX permissions
riscv64-unknown-elf-objcopy -S -O binary xv6-user/initcode.out xv6-user/initcoderiscv64-unknown-elf-objdump -S xv6-user/initcode.o > xv6-user/initcode.asm
*** QEMU 已在 :1234 等待 gdb，请在另⼀个终端运⾏: ***
 gdb-multiarch target/kernel -ex 'set arch riscv:rv64' -ex 'target remote localhost:1234'

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
Domain0 Region01          : 0x0000000080040000-0x000000008005ffff M: (R,W) S/U:
()
Domain0 Region02          : 0x0000000080000000-0x000000008003ffff M: (R,X) S/U:
()
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
-> / $
-> / $
```

### 录像时间：2026-09-03T17:56:57.986+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
gdb-multiarch target/kernel -ex 'set arch riscv:rv64' -ex 'target remote localhost:1234'

[终端输出]
GNU gdb (Ubuntu 15.1-1ubuntu1~24.04.1) 15.1
Copyright (C) 2024 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
Type "show copying" and "show warranty" for details.
This GDB was configured as "x86_64-linux-gnu".
Type "show configuration" for configuration details.
For bug reporting instructions, please see:
<https://www.gnu.org/software/gdb/bugs/>.
Find the GDB manual and other documentation resources online at:
    <http://www.gnu.org/software/gdb/documentation/>.

For help, type "help".
Type "apropos word" to search for commands related to "word"...
Reading symbols from target/kernel...
The target architecture is set to "riscv:rv64".
Remote debugging using localhost:1234
0x0000000000001000 in ?? ()
(gdb) l
19      #ifndef QEMU
20      #include "include/sdcard.h"
21      #include "include/fpioa.h"
22      #include "include/dmac.h"
23      #endif
24
25      static inline void inithartid(unsigned long hartid) {
26        asm volatile("mv tp, %0" : : "r" (hartid & 0x1));
27      }
28
(gdb) exit
A debugging session is active.
        Inferior 1 [process 1] will be detached.
Quit anyway? (y or n) y
Detaching from program: /home/ailab-os/桌面/xv6-ai-labs-km/lab0/target/kernel, process 1
Ending remote debugging.
[Inferior 1 (process 1) detached]
```

### 录像时间：2026-09-04T01:07:45.728+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
make run

[终端输出]
qemu-system-riscv64: -drive file=fs.img,if=none,format=raw,id=x0: Could not open 'fs.img': No such file or directory
make: *** [Makefile:152：run] 错误 1
```

### 录像时间：2026-09-09T11:11:34.921+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
claude
```

### 录像时间：2026-09-09T11:29:19.678+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
claude
```

### 录像时间：2026-09-09T11:33:53.944+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
claude
```
