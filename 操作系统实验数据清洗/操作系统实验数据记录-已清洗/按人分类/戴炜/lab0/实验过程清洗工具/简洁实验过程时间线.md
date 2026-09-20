# 简洁实验过程时间线

- 学号：2406080102
- 姓名：戴炜
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

### 录像时间：2026-09-09T10:47:24.877+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
claude
```

### 录像时间：2026-09-09T10:49:05.749+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
claude
```

### 录像时间：2026-09-09T10:57:21.658+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
claude
```

### 录像时间：2026-09-09T10:59:43.255+08:00（北京时间）

- 录像类型：用户问题

- 内容：

```text
你好，现在可以开始lab0的学习了
```

### 录像时间：2026-09-09T10:59:51.198+08:00（北京时间）

- 录像类型：Claude 回复

- 内容：

```text
你好！欢迎开始 lab0。

在动手之前，我想先确认一下你现在用的环境，这样我才知道接下来该带你往哪个方向走
。

lab0 的目标不是装一堆东西，而是让你把 xv6-k210 跑起来、看到 shell 提示符 -> /
$。所以第一步得先知道你手上是什么环境。

你现在用的是哪种？比如：

- 课程备好的实验镜像（.ova 已导入 VMware，或希冀云端、现场硬盘拷贝的镜像）
- 自己机器上全新装的系统

就告诉我这个就行，一次一个，我们从这里开始。
```

### 录像时间：2026-09-09T11:02:45.980+08:00（北京时间）

- 录像类型：用户问题

- 内容：

```text
我们首先从整体角度了解一下lab0,就是这文件目的是什么，需要我们做什么任务
```

### 录像时间：2026-09-09T11:03:03.633+08:00（北京时间）

- 录像类型：Claude 回复

- 内容：

```text
看完了，我用大白话给你捋一遍 lab0 是干什么的。

这个 lab 的目的

一句话：把 xv6-k210 这个操作系统在模拟器里跑起来，看到 shell 提示符 -> / $。

lab0 的特殊之处在于——不挖空、不改代码、不要求读懂 xv6。它就是个"搭环境 +
跑通"的章。你要做的不是写代码，而是理解"为什么我的电脑上要装这些东西、每一步在
干嘛"。

你需要做的事

整条链路其实就一句：把代码编译成 RISC-V 能跑的格式，再让一个模拟 RISC-V
机器的软件把它跑起来。

拆成几个任务：

     任务                 干什么                   关键命令/产物
 搭环境        拿到一台能用的 Ubuntu         实验镜像 / 自己装
 装交叉编译器  在 x86 电脑上编译出 RISC-V    riscv64-unknown-elf-gcc
               代码
 装模拟器      模拟一台 RISC-V 机器          qemu-system-riscv64
 构建内核      把 kernel/ 源码编译链接       make build →
                                             target/kernel
 做文件系统    把用户程序打包进磁盘镜像      make fs → fs.img
 启动          让 QEMU 把内核跑起来          make run
 验证          在 shell 里敲几个命令         ls、cat README

成功的标志（就三条）

1. make build 不报错，生成了 target/kernel
2. make fs 生成了 fs.img
3. make run 启动后，能看到 OpenSBI banner → 内核 banner → 最后出现 -> /
$，还能敲 ls、cat README 出结果

---
有个关键点提前说一句：如果你用的是课程预装好的"实验镜像"，任务 2 和
3（装工具链、装 QEMU）是可以跳过的，直接进 make build 就行。

这正好接回我上一条问你的问题——你现在用的到底是课程镜像，还是自己全新装的系统？
这决定了你要不要做安装那两步。
```

### 录像时间：2026-09-09T11:08:48.743+08:00（北京时间）

- 录像类型：用户问题

- 内容：

```text
我用的是学校提供的，应该是算课程镜像把
```

### 录像时间：2026-09-09T11:09:03.614+08:00（北京时间）

- 录像类型：Claude 回复

- 内容：

```text
好，既然是学校提供的镜像，那大概率环境里已经装好东西了，我们先别急着装任何东西
。

第一步很简单：花一分钟，确认这台机器上到底已经有什么。请你在自己的终端里跑这两
条命令，然后把输出贴给我：

qemu-system-riscv64 --version
riscv64-unknown-elf-gcc --version

- 第一条看 QEMU 模拟器在不在（要 ≥ 7.0）
- 第二条看 RISC-V 交叉编译器在不在

两条命令的输出能直接告诉我：你是"装好就能直接跑"的实验镜像，还是"只装了系统、
工具链要自己补"的基础镜像。先跑，贴结果给我。
```

### 录像时间：2026-09-09T11:12:42.452+08:00（北京时间）

- 录像类型：用户问题

- 内容：

```text
qemu-system-riscv64 --version
```

### 录像时间：2026-09-09T11:12:53.602+08:00（北京时间）

- 录像类型：Claude 回复

- 内容：

```text
这条是命令本身——我要看的是它跑完之后屏幕打印出来的那几行字。

你在终端里敲完这行、按回车之后，屏幕上会冒出一段类似这样的文字（版本号可能不同
）：

QEMU emulator version 8.2.x
Copyright (c) 2003-2023 Fabrice Bellard and the QEMU Project developers

请把你屏幕上实际显示的那几行复制粘贴给我。如果敲完之后没反应、或者出现 command
not found 之类的报错，也原样贴给我。
```

### 录像时间：2026-09-09T11:15:05.040+08:00（北京时间）

- 录像类型：用户问题

- 内容：

```text
第一个8.2.2
```

### 录像时间：2026-09-09T11:16:34.648+08:00（北京时间）

- 录像类型：Claude 回复

- 内容：

```text
很好，8.2.2 ≥ 7.0，QEMU 这一项已经就绪，不用装。

再看第二条，请把这条跑完的输出也贴给我：

riscv64-unknown-elf-gcc --version

- 如果打印出一段 riscv64-unknown-elf-gcc (GCC) 13.x.x ... 之类的版本信息 →
交叉编译器也装好了
- 如果提示 command not found → 说明这台机器是基础镜像，工具链要补

同样，把你屏幕上实际显示的那几行贴上来。
```

### 录像时间：2026-09-09T11:16:55.347+08:00（北京时间）

- 录像类型：用户问题

- 内容：

```text
第二个是13.2.0
```

### 录像时间：2026-09-09T11:17:18.220+08:00（北京时间）

- 录像类型：Claude 回复

- 内容：

```text
齐了，两项都达标：

- QEMU 8.2.2（≥ 7.0）✓
- 交叉编译器 GCC 13.2.0 ✓

所以你是实验镜像，任务 2、3（装工具链、装
QEMU）直接跳过，不用装任何东西。接下来直接进入正题——构建内核。

下一步只做一件事：确认你现在在 lab0 目录里，然后跑构建命令。

pwd        # 先看看当前路径，应该以 lab0 结尾
make build

make build 干的事就是：用交叉编译器把 kernel/ 里的源码编译、链接成一个 RISC-V
内核镜像 target/kernel。

跑完把输出贴给我——成功也好、报错也好，都原样贴。这一关过去，离看到 shell
就不远了。
```

### 录像时间：2026-09-09T11:17:51.828+08:00（北京时间）

- 录像类型：用户问题

- 内容：

```text
pwd
```

### 录像时间：2026-09-09T11:17:59.582+08:00（北京时间）

- 录像类型：Claude 回复

- 内容：

```text
pwd 也是一条命令，同样要看你敲完之后屏幕上显示出来的那一行路径。

具体这样：在终端里输入 pwd，按回车，屏幕上会出现一串以 /
开头的路径文字，类似：

/home/ailab-os/桌面/xv6-ai-labs-km/lab0

把这串路径发给我就行。我要确认的是：你现在这个终端是不是正停在 lab0
这个目录里。如果路径结尾不是 lab0，那下一步 make build 就会在错误的目录里跑。

（顺带说明一下：pwd 是 "print working directory"
的缩写，作用就是告诉你"我现在在哪个目录"。）
```

### 录像时间：2026-09-09T11:18:29.498+08:00（北京时间）

- 录像类型：用户问题

- 内容：

```text
是的，我们现在是在这个目录里面
```

### 录像时间：2026-09-09T11:18:32.134+08:00（北京时间）

- 录像类型：Claude 回复

- 内容：

```text
好，目录没问题。

那就跑构建命令：

make build

敲完回车，屏幕上会刷出一大堆编译信息。不用逐行看，你只要把最后几行（尤其是有没
有 Error 或者 make: *** 这种字样）贴给我就行。

如果整屏信息太长，就告诉我两件事：

1. 最后有没有出现 Error / make: *** ... 失败 这类字眼
2. 目录里有没有多出一个 target/ 文件夹（里面应该有个 kernel 文件）

先跑，结果贴我。
```

### 录像时间：2026-09-09T11:19:22.037+08:00（北京时间）

- 录像类型：用户问题

- 内容：

```text
这命令在哪里敲阿？
```

### 录像时间：2026-09-09T11:19:46.747+08:00（北京时间）

- 录像类型：Claude 回复

- 内容：

```text
好问题，这其实戳中了一个隐藏概念——"终端"是什么。

你现在跟我聊天，用的程序叫 Claude Code，而 Claude Code
本身就运行在终端里。终端就是那个"你输入命令、电脑去执行"的黑窗口。所以你不是没
有终端——你已经在终端里了，只是你现在正用它跟我对话。

那命令往哪敲？两个办法：

办法一（最省事，推荐）： 直接就在我们这个对话的输入框里，命令前面加一个
!，像这样输入再回车：

! make build

这个 ! 的含义是"让电脑执行后面这行命令"，执行完输出会直接显示在我们的对话里，
我立刻就能看到。

办法二： 另开一个终端窗口——图形桌面上按 Ctrl + Alt +
T，或右键桌面选"打开终端"，然后自己 cd 到 lab0 目录再敲 make build。

先用办法一试试，跑完结果直接出现在这里，我们接着看。
```

### 录像时间：2026-09-09T11:20:17.713+08:00（北京时间）

- 录像类型：用户问题

- 内容：

```text
！make build
```

### 录像时间：2026-09-09T11:20:25.375+08:00（北京时间）

- 录像类型：Claude 回复

- 内容：

```text
差一点点——你打的那个感叹号是中文全角的 ！，但 Claude Code 认的是英文半角的
!。这俩长得像，其实是两个不同的字符，电脑分得很清。

你现在的输入法应该还停在中文状态，所以打出来的是全角符号。

解决办法：把输入法切到英文（一般按一下 Shift
切换），或者打的时候确认感叹号是窄窄的、贴左边的 !，不是宽的 ！。

再试一次，用这个：

! make build

（对照一下：上面这个 ! 和 make 之间只有半个字符的宽度，你刚才的 ！ 更宽。）
```

### 录像时间：2026-09-09T11:29:48.252+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
make run

[终端输出]
qemu-system-riscv64: -device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0: Failed to get "write" lock
Is another process using the image [fs.img]?
make: *** [Makefile:152：run] 错误 1
```

### 录像时间：2026-09-09T11:30:31.116+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
make build

[终端输出]
make: 对“build”无需做任何事。
```

### 录像时间：2026-09-09T11:30:38.047+08:00（北京时间）

- 录像类型：Shell 命令

- 内容：

```text
make fs

[终端输出]
[sudo] ailab-os 的密码：
```

### 录像时间：2026-09-09T11:30:47.580+08:00（北京时间）

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
-> / $ ax
[exec] aaax not found
[exec] reach bad
[exec] /bin/aaax not found
[exec] reach bad
exec aaax failed
-> / $ QEMU: Terminated
```
