# Claude Code QA (Clean)

- 学号：2406080113
- 姓名：裴政杨
- 数据采集时间：2026-09-16 10:40
- 原始时间标识：20260916-1040
- 原始数据目录：2406080113-裴政杨-20260916-1040
- 终端录像数量：14

- 实验分类：lab0

- Claude 会话总数：2
- 对话轮次总数：18
- 有效用户问题数：18
- 有效 Claude 回复数：18

## Session 1：20260914T214704-7661

- 对话轮次：9
- 开始时间：2026-09-14 21:47:04+08:00

### Turn 1

#### User

什么是特权级

#### Claude

特权级是 CPU 硬件给自己划的“权限档位”，它决定当前正在执行的这段代码能不能执行
某些指令、能不能碰某些寄存器。x86 上叫 ring0/ring3，RISC-V 上叫 M/S/U。

为什么必须有它

想象一下：如果用户程序能随手关掉中断、直接改页表、直接写磁盘控制器的寄存器，那
操作系统就只是个摆设——它拦不住任何人。所以硬件要划一条用户程序跨不过去的线。不
是靠“大家说好不这么干”，是靠硬件真的不让。

在本实验里的位置

实验指导.md 第 66–80 行讲了三档：

- M-mode（Machine）：最高权限。QEMU 上电后先跑的就是它 —— OpenSBI 固件。
- S-mode（Supervisor）：内核的地盘，xv6-k210 跑在这里。
- U-mode（User）：用户程序的地盘，你之后在 shell 里敲的 ls、echo 就跑在这。

顺序是：上电 → M-mode 的 OpenSBI 做硬件初始化 → 跳进 S-mode 启动 xv6
内核。所以 make run 时先刷出来的那段 OpenSBI ASCII banner，是 M-mode
的代码打的，内核 banner 在它后面。

再挖一层：这条线是怎么“硬”起来的

RISC-V 靠两样东西实现它：一组只能在 M/S 模式访问的 CSR（控制状态寄存器，比如
mstatus、mepc），以及几条特权指令（比如 mret）。U-mode
里执行这些指令不会“没效果”，而是直接触发一个异常，把控制权交回内核。

这就是为什么“从内核跳进用户程序”和“从用户程序回到内核”不能是普通的 jump ——
特权级的切换本身要经过硬件的门。

一个小问题留给你：shell 里的 ls 要读磁盘、要往屏幕打印，这些事 U-mode
自己干不了，那它是怎么完成的？

### Turn 2

#### User

你问的这个问题我不会，你帮我回答一下

#### Claude

这个问题你答不上来很正常——它其实是三个问题叠在一起：能不能自己干？不能的话还剩
什么招？这个招叫什么？拆开看就不难了。

第一步：U-mode 能不能自己干？不能。

“往屏幕打印”这件事，本质是往 UART 芯片的寄存器里写数据。UART
不是什么抽象的东西，它就是一串内存地址 —— 在 kernel/include/memlayout.h:40
里就写着：

#define UART 0x10000000L

内核写这个地址，字符就从屏幕出来了。但 U-mode 的代码够不到这个地址——不是“约定
不能碰”，是硬件在每次访存时都会检查当前特权级，不该碰的直接触发异常。磁盘 IO
同理。

所以 ls 想打印，它手里根本没有能用的工具。

第二步：那它还剩什么招？

只剩一招：主动举手。用户程序不能越界，但它可以让 CPU
停下来，把控制权交给内核，同时递上一句话：“我想打印这几个字符，麻烦你替我办。”

第三步：这个“举手”叫什么？

RISC-V 里这条指令叫 ecall（environment call）。它做的事就是：把当前特权级从 U
抬到 S，跳到内核预先登记好的一个入口。内核在那儿一看——“哦，2
号请求是打印”——就替它写 UART，然后送它回去。

这套“举手 → 掉进内核 → 内核代办 → 返回”的机制，就是系统调用。

---
一个比喻能帮你记住：ecall 就像去银行柜台。你在玻璃外面（U-mode）碰不到钱箱，但
你可以填单子、按铃（ecall），柜员（S-mode
内核）在里面替你办。特权级就是那层玻璃——它不靠自觉，靠硬件。

至于内核收到 ecall 之后具体怎么分流、怎么保存现场再恢复，那是 trap
处理的内容，属于后面 lab 的范围，lab0 不用碰。你现在只要能把“用户程序干不了 →
举手 → 内核代办”这条因果说顺，就够了。

### Turn 3

#### User

RISC-V和我的ubantu是同等的操作系统吗？

#### Claude

不是同一类东西，谈不上“同等”——它俩根本不在一个层面上。

一句话：Ubuntu 和 xv6 才是同级的（都是操作系统）；RISC-V 的同级是
x86-64（都是指令集）。

RISC-V 不是软件，是指令集架构（ISA）。它规定的是一台 CPU
能听懂哪些指令、有哪些寄存器、有什么特权级。它是硬件和软件之间约定的“语言”。

把它竖着摞起来看最清楚：

    层      你机器上        本实验里
 应用程序  浏览器、ls  shell 里的命令
 操作系统  Ubuntu      xv6-k210
 指令集    x86-64      RISC-V
 硬件      你的 CPU    QEMU 假装出来的 CPU

同一行里的才是同类。所以你的问题应该这样问才对：“xv6-k210 和 Ubuntu
是同等的操作系统吗？”——是，都是操作系统。而“RISC-V 和 x86-64
是同等的指令集吗？”——也是。

一个反证能帮你钉住这个区分：Ubuntu 是有 riscv64 版本的，理论上可以装在一台真
RISC-V 电脑上。但如果 Ubuntu 真的是“RISC-V
的同级”，这种说法就不成立了。反过来，“把 xv6 换成 RISC-V”这句话根本说不通。

那 QEMU 在这里干什么？

你的电脑是 x86-64，听不懂 RISC-V 指令。QEMU 的作用就是假装自己是一台 RISC-V
机器——它一条条接收 RISC-V 指令，在你 x86-64 的真实 CPU 上模拟执行。xv6
跑在里面，完全以为自己在真硬件上。

这就是为什么 make run 里必须有 QEMU：它补上了“你的机器不是 RISC-V”这个缺口。

---
给你一个小验证：在你自己的终端敲

uname -m

看看你的 Ubuntu 报出的是什么。那个字符串就是你这台机器的指令集。

### Turn 4

#### User

GCC 13是什么东西

#### Claude

GCC 是编译器——把 C
源代码翻译成机器能执行的机器码的那个程序。“13”是它的版本号。

在你这台 Ubuntu 24.04 上，sudo apt install gcc-riscv64-unknown-elf
装出来的那个交叉编译器，版本就是 GCC 13。你跑 riscv64-unknown-elf-gcc
--version，第一行末尾的 13.x.x 就是它。

它在本实验里的位置

Makefile:68-70 这三行：

TOOLPREFIX    := riscv64-unknown-elf-
CC = $(TOOLPREFIX)gcc

CC 就是 Makefile 里代表编译器的变量。所以每次 make
build，真正在翻译你内核代码的就是这个 GCC 13。

为什么版本号在这里值得一提

因为编译器不是死的工具，它也在演进。新版本会加入新的检查。GCC 13 遇到
xv6-user/sh.c 里的 runcmd() 就会报一句
-Winfinite-recursion（怀疑是无限递归）。

麻烦在于 Makefile:79 里有这个：

CFLAGS = -Wall -Werror ...

-Werror 的意思是“把警告当成错误”。所以一个新版本编译器多出来的警告，会让本该编
过的旧代码直接编译失败。

仓库已经处理了——同一行后面跟着
-Wno-error=infinite-recursion，专门给这一条警告开个口子。所以你在 make build
里看到这条警告是正常的，它不会中断构建。

---
顺带提一句你可能会撞上的混淆：gcc --version（不带前缀）报的也是
GCC，但那是给你 x86-64 的 Ubuntu 编译普通程序的，跟 xv6
一点关系都没有。本实验只认带 riscv64-unknown-elf- 前缀的那个。

### Turn 5

#### User

现在我想问一下一个能够正常运行的电脑系统都要包含什么

#### Claude

一句话：一台电脑能跑起来，靠的是一条四棒接力——每一棒只做一件事，把下一棒扶起来
，然后让位。

 棒   是什                  干活的内容                  本实验里是谁
 次    么
 1    硬件  CPU 取指执行、内存、外设                    QEMU 假装出来
                                                        的那台机器
 2    固件  上电后第一段代码：把硬件初始化到能用，然后  OpenSBI（M-mo
            找到内核跳过去                              de）
 3    内核  操作系统本体                                xv6-k210（S-m
                                                        ode）
 4    用户  人和程序干活的地方                          init → sh →
      态                                                -> / $

第 1 棒：真硬件就是 CPU、内存、一堆外设芯片。它自己什么都不会，只会听指令。

第 2 棒：CPU 一上电，PC 指向一个固定地址，那里躺着固件。固件的活儿很具体——把内
存控制器、中断控制器这些"开机前必须先摆好"的东西配置好，然后跳到内核入口。你的
make run 里，-bios default 让 QEMU 加载的就是它。

第 3 棒是重点，因为"操作系统"这个词真正指的是它。内核不管业务，它只提供四种基
础能力：

- 管进程 —— 谁在跑、什么时候换人 → proc.c、swtch.S
- 管内存 —— 谁能用哪些内存、怎么隔离 → kalloc.c、vm.c
- 管文件 —— 数据怎么存、怎么按名字找 → fat32.c、file.c
- 管设备 —— 屏幕、磁盘、时钟怎么用 → uart.c、disk.c、plic.c

这四件事就是"操作系统"的全部底子。你在 shell
里敲的每一条命令，往下追都会落到这四组文件之一。

第 4 棒：内核把 init 跑起来，init 再 fork 一个
sh。真正坐在屏幕上等你打字的，是这个 sh。

---
有个很妙的点：这份清单你不用背，make run 会把它打印出来。
屏幕上依次出现的三段东西，正好就是第 2、3、4 棒在自报家门：

OpenSBI v1.0          ← 第2棒：固件说"我干完了"
xv6-k210 ...          ← 第3棒：内核说"我起来了"
-> / $                ← 第4棒：shell 说"轮到你输入了"

所以 -> / $
出现这件事，信息量比它看起来大得多——它意味着从通电到用户态，四棒一棒没掉。

等你跑 make run
的时候留意一下这三段的先后顺序。有任何一棒看懂了想往下挖，再问我。

### Turn 6

#### User

那这个编译器和指令集呢？

#### Claude

好问题——你这是在把新东西往刚才那张图上放。但它俩放不上去，因为它们不在那条接力
链上。

刚才那四棒，全都是运行的时候在场的东西：通电了，它们一棒接一棒地活着。而编译器
和指令集属于另外两个维度：

- 编译器是建造阶段的东西。make build 的时候它干活，make run
的时候它早就退场了。链上跑的不是编译器，是它留下的产物（target/kernel）。
- 指令集根本不是一个"东西"，是一份契约。它是硬件和软件之间的约定：硬件说"我听
得懂这些指令"，软件说"那我只用这些写"。它没有位置，因为它贯穿整条链。

画成图大概是这样：

【建造期】在你的 x86-64 Ubuntu 上
    C 源码 [gcc 翻译]> RISC-V 机器码 > target/kernel
                                                  ▼
【运行期】接力链
    硬件 > 固件 > 内核 > 用户态
    （链上每一节，都是用 RISC-V 指令写的）
                    ↑
              QEMU 站在链外托着第一棒
              ——它自己是 x86-64 程序

所以三者是三件事：编译器是造链的工人，指令集是链子每一节都遵守的规格，四棒接力
是链子怎么动起来。

---
再挖一层：编译器其实不是必须的。

指令集那份契约，你可以让编译器替你履行，也可以自己直接写。xv6
里就有一批文件是手写的汇编：

- kernel/entry_qemu.S —— 内核第一条指令，给每个 hart 设栈
- kernel/swtch.S —— 进程上下文切换
- kernel/trampoline.S —— 用户态陷入内核时换页表

这些地方 GCC 帮不上忙——因为它们要操作的东西（设栈指针、切页表、ecall
的具体寄存器约定）是 C 语言描述不出来的。所以只能人手写。

这就是为什么 kernel/ 目录里 .c 和 .S 混着放：能用 C 说清楚的部分交给
gcc，说不清楚的部分手写汇编。 它们最后都被编译成同一种东西——RISC-V 指令。

---
到这里你手里其实已经有三个可以分开看的东西了：建造期的工具链、贯穿全程的指令集
契约、运行期的四棒接力。哪个方向想再往下走，你说。

### Turn 7

#### User

make build为什么我只用这一句话系统就知道我要装一个什么样子的内核呢？难道内核
只有一种吗？

#### Claude

make build 什么都不知道。它没有智能，也不会猜——它只是读了一个文件：Makefile。
所有答案都写在那里。

make 这个程序的工作方式很朴素：你去 Makefile 里找有没有一条叫 build
的规则，找到了就照做。Makefile:108 那行就是：

build: $T/kernel userprogs

意思是"要完成 build，先得把 target/kernel 和用户程序搞出来"。至于
target/kernel
怎么来、用什么编译器、编哪些文件——继续往下照抄，一直抄到没有依赖为止。

所以真正回答"要装一个什么样的内核"的，是 Makefile，不是 make。

---
至于"内核只有一种吗"——不是。光这个仓库里就有两种。

看 Makefile 最开头：

#platform     := k210
platform      := qemu
mode := debug
#mode := release

注意那两行被 # 注释掉的。它们就是证据：有人写过 k210 和 release
这两种配置，然后手动关掉了。你现在跑的 make build，用的是 qemu + debug。

这个 platform 不是装饰，它真的在分叉。比如 Makefile:9-13：

ifeq ($(platform), k210)
OBJS += $K/entry_k210.o
else
OBJS += $K/entry_qemu.o
endif

把 platform 改成 k210，编出来的会是另一个内核：

           platform := qemu（你现在）      platform := k210
 内核入口  entry_qemu.o                entry_k210.o
 磁盘驱动  virtio_disk.o               sdcard.o + spi.o + dmac.o
 链接脚本  linker/qemu.ld              linker/k210.ld
 固件      OpenSBI                     sbi-k210

同一份源代码，一行改动，产出的是两个不同的内核。

---
再挖一层：这些分叉发生在"编译之前"。

ifeq 不是给编译器看的注释，是 make
真的会执行的条件判断。它在决定"要编译哪些文件"的时候就做完了选择。

意味着：k210 分支里的 sdcard.c、fpioa.c，在你现在这套配置下根本不会被送去编译—
—不是编了再丢掉，是压根没编。这也解释了为什么 实验指导.md 里说这些文件"QEMU
模式下不参与"。

---
顺带说一句，往大了看：Linux 内核有几千个这样的开关（make menuconfig
那个满屏的配置界面），同一份源码能编出无数种内核——从手机上的到超算上的。所以"
内核"从来不是一种东西，是一族。Makefile 开头那几行，就是这一族里挑一个的旋钮。

### Turn 8

#### User

fs.img这是什么

#### Claude

fs.img 是一块虚拟硬盘。

它本身就是一个普通文件，躺在你的 lab0 目录里：

-rw-rw-r-- 1 ailab-os ailab-os 268435456  9月 14 22:08 fs.img

268435456 字节 = 256 MB。但里面的内容不是一个 256MB
的大垃圾堆——里面装着一个完整的、格式化好的文件系统，里面躺着 init、sh、README
这些文件。

为什么必须有它

xv6 跑到最后要 exec("/init")、要读 /sh——这些文件总得存在某个地方。可 QEMU
造出来的那台虚拟机器是空的，没有你的硬盘。所以得给它配一块。

它是怎么做出来的——Makefile 的 fs 目标：

dd if=/dev/zero of=fs.img bs=512k count=512   # 造一个 256MB 的全零文件
mkfs.vfat -F 32 fs.img                        # 把它格式化成 FAT32
sudo mount fs.img /mnt                        # 挂载！
sudo cp README /mnt/README                    # 往里拷文件
for file in $(ls $U/_*); do sudo cp ... ; done  # 把编译好的用户程序拷进去
sudo umount /mnt                              # 卸载

从"一块空白"到"一个能用的文件系统"，六步。

xv6 怎么用它——Makefile:140-141，启动 QEMU 时把它当磁盘插上去：

QEMUOPTS += -drive file=fs.img,if=none,format=raw,id=x0
QEMUOPTS += -device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0

fs.img 就是 QEMU 里那台虚拟机的硬盘。xv6 里的 disk.c、virtio_disk.c
读的就是它。

---
挖一层：注意那个 mount。

fs.img 能被你的 Ubuntu 直接 mount 到 /mnt——这说明它不是 xv6 的私有格式，是标准
FAT32。任何 Linux 都能读。

你可以自己验证一下，在终端敲：

mkdir -p /tmp/x && sudo mount -o loop fs.img /tmp/x && ls /tmp/x

（看完 sudo umount /tmp/x 卸掉。）你会看到 /init、/sh 就摆在那儿——和 xv6 里 ls
看到的是同一批文件。

---
顺带把前面几课串一下：fs.img 里那些 _sh、_init，是用 RISC-V 交叉编译器在你
x86-64 的 Ubuntu 上编出来的 RISC-V 程序，由一个 x86-64 的 cp 拷进一个 FAT32
镜像，最后被 QEMU 里的 RISC-V 版 xv6 读出来执行。

fs.img 就是这两个世界之间的交接棒。

### Turn 9

#### User

SBI是什么

#### Claude

SBI 是 M-mode 给 S-mode 开的一个服务窗口。全称 Supervisor Binary
Interface——"Supervisor 二进制接口"。

为什么需要这个窗口

接上前面特权级那一课：内核跑在 S-mode，可有些事 S-mode
没权限干——配置定时器、让某个 hart 停下来、关机、直接往控制台吐字符。这些是
M-mode 的地盘。

内核想在 S-mode 里把机器关掉，它做不到。它只能去敲那扇窗口。

本实验的真实位置

kernel/include/sbi.h。别看它名字带 SBI，这个文件其实是窗口的客户端——内核这边用
来"敲门"的封装。里面每个函数最后都落到同一个宏：

#define SBI_CALL(which, arg0, arg1, arg2, arg3) ({        \
      register uintptr_t a7 asm ("a7") = (uintptr_t)(which); \
      asm volatile ("ecall"                             \
                    : "+r" (a0) ...);                    \
      a0;                                                \
})

那个 ecall，和你前面学的用户程序举手用的是同一条指令。

再看 sbi.h:12-20 那几行：

#define SBI_SET_TIMER        0
#define SBI_CONSOLE_PUTCHAR  1
#define SBI_CONSOLE_GETCHAR  2
...
#define SBI_SHUTDOWN         8

这些编号就是窗口的"业务号码"，写在 a7 里递给 M-mode。跟系统调用号是一个套路。

所以 kernel/console.c 里 printf 想往屏幕写字，最后走的是 sbi_console_putchar()
→ ecall → M-mode 的 OpenSBI 替它写。

---
挖一层：这是一部楼梯，每层台阶一模一样。

U-mode  ecall>  S-mode     用户程序请求内核   = 系统调用
S-mode  ecall>  M-mode     内核请求固件       = SBI 调用

同一条指令，同一个套路：把请求编号和参数放进约定好的寄存器，ecall，对面接住，
办完返回。只是每一层抬高了一档特权级。

这就是为什么它叫 "Interface"——和 "ABI"（Application Binary
Interface）一个构词法。它是一份约定，不是一个程序。约定这一头是内核的
sbi.h，那一头由谁实现都行。

谁实现了它？ QEMU 自带的 OpenSBI。Makefile:137 那行 -bios default 就是让 QEMU
把它加载进去。你 make run 时最先看到的那段 OpenSBI
banner，就是这扇窗口的营业公告。

---
一句话收口：SBI 就是内核的"系统调用"，只不过调用对象是固件而不是内核。

## Session 2：20260914T230037-5159

- 对话轮次：9
- 开始时间：2026-09-14 23:00:37+08:00

### Turn 1

#### User

什么是特权级

#### Claude

特权级是 CPU 硬件给自己划的“权限档位”，它决定当前正在执行的这段代码能不能执行
某些指令、能不能碰某些寄存器。x86 上叫 ring0/ring3，RISC-V 上叫 M/S/U。

为什么必须有它

想象一下：如果用户程序能随手关掉中断、直接改页表、直接写磁盘控制器的寄存器，那
操作系统就只是个摆设——它拦不住任何人。所以硬件要划一条用户程序跨不过去的线。不
是靠“大家说好不这么干”，是靠硬件真的不让。

在本实验里的位置

实验指导.md 第 66–80 行讲了三档：

- M-mode（Machine）：最高权限。QEMU 上电后先跑的就是它 —— OpenSBI 固件。
- S-mode（Supervisor）：内核的地盘，xv6-k210 跑在这里。
- U-mode（User）：用户程序的地盘，你之后在 shell 里敲的 ls、echo 就跑在这。

顺序是：上电 → M-mode 的 OpenSBI 做硬件初始化 → 跳进 S-mode 启动 xv6
内核。所以 make run 时先刷出来的那段 OpenSBI ASCII banner，是 M-mode
的代码打的，内核 banner 在它后面。

再挖一层：这条线是怎么“硬”起来的

RISC-V 靠两样东西实现它：一组只能在 M/S 模式访问的 CSR（控制状态寄存器，比如
mstatus、mepc），以及几条特权指令（比如 mret）。U-mode
里执行这些指令不会“没效果”，而是直接触发一个异常，把控制权交回内核。

这就是为什么“从内核跳进用户程序”和“从用户程序回到内核”不能是普通的 jump ——
特权级的切换本身要经过硬件的门。

一个小问题留给你：shell 里的 ls 要读磁盘、要往屏幕打印，这些事 U-mode
自己干不了，那它是怎么完成的？

### Turn 2

#### User

你问的这个问题我不会，你帮我回答一下

#### Claude

这个问题你答不上来很正常——它其实是三个问题叠在一起：能不能自己干？不能的话还剩
什么招？这个招叫什么？拆开看就不难了。

第一步：U-mode 能不能自己干？不能。

“往屏幕打印”这件事，本质是往 UART 芯片的寄存器里写数据。UART
不是什么抽象的东西，它就是一串内存地址 —— 在 kernel/include/memlayout.h:40
里就写着：

#define UART 0x10000000L

内核写这个地址，字符就从屏幕出来了。但 U-mode 的代码够不到这个地址——不是“约定
不能碰”，是硬件在每次访存时都会检查当前特权级，不该碰的直接触发异常。磁盘 IO
同理。

所以 ls 想打印，它手里根本没有能用的工具。

第二步：那它还剩什么招？

只剩一招：主动举手。用户程序不能越界，但它可以让 CPU
停下来，把控制权交给内核，同时递上一句话：“我想打印这几个字符，麻烦你替我办。”

第三步：这个“举手”叫什么？

RISC-V 里这条指令叫 ecall（environment call）。它做的事就是：把当前特权级从 U
抬到 S，跳到内核预先登记好的一个入口。内核在那儿一看——“哦，2
号请求是打印”——就替它写 UART，然后送它回去。

这套“举手 → 掉进内核 → 内核代办 → 返回”的机制，就是系统调用。

---
一个比喻能帮你记住：ecall 就像去银行柜台。你在玻璃外面（U-mode）碰不到钱箱，但
你可以填单子、按铃（ecall），柜员（S-mode
内核）在里面替你办。特权级就是那层玻璃——它不靠自觉，靠硬件。

至于内核收到 ecall 之后具体怎么分流、怎么保存现场再恢复，那是 trap
处理的内容，属于后面 lab 的范围，lab0 不用碰。你现在只要能把“用户程序干不了 →
举手 → 内核代办”这条因果说顺，就够了。

### Turn 3

#### User

RISC-V和我的ubantu是同等的操作系统吗？

#### Claude

不是同一类东西，谈不上“同等”——它俩根本不在一个层面上。

一句话：Ubuntu 和 xv6 才是同级的（都是操作系统）；RISC-V 的同级是
x86-64（都是指令集）。

RISC-V 不是软件，是指令集架构（ISA）。它规定的是一台 CPU
能听懂哪些指令、有哪些寄存器、有什么特权级。它是硬件和软件之间约定的“语言”。

把它竖着摞起来看最清楚：

    层      你机器上        本实验里
 应用程序  浏览器、ls  shell 里的命令
 操作系统  Ubuntu      xv6-k210
 指令集    x86-64      RISC-V
 硬件      你的 CPU    QEMU 假装出来的 CPU

同一行里的才是同类。所以你的问题应该这样问才对：“xv6-k210 和 Ubuntu
是同等的操作系统吗？”——是，都是操作系统。而“RISC-V 和 x86-64
是同等的指令集吗？”——也是。

一个反证能帮你钉住这个区分：Ubuntu 是有 riscv64 版本的，理论上可以装在一台真
RISC-V 电脑上。但如果 Ubuntu 真的是“RISC-V
的同级”，这种说法就不成立了。反过来，“把 xv6 换成 RISC-V”这句话根本说不通。

那 QEMU 在这里干什么？

你的电脑是 x86-64，听不懂 RISC-V 指令。QEMU 的作用就是假装自己是一台 RISC-V
机器——它一条条接收 RISC-V 指令，在你 x86-64 的真实 CPU 上模拟执行。xv6
跑在里面，完全以为自己在真硬件上。

这就是为什么 make run 里必须有 QEMU：它补上了“你的机器不是 RISC-V”这个缺口。

---
给你一个小验证：在你自己的终端敲

uname -m

看看你的 Ubuntu 报出的是什么。那个字符串就是你这台机器的指令集。

### Turn 4

#### User

GCC 13是什么东西

#### Claude

GCC 是编译器——把 C
源代码翻译成机器能执行的机器码的那个程序。“13”是它的版本号。

在你这台 Ubuntu 24.04 上，sudo apt install gcc-riscv64-unknown-elf
装出来的那个交叉编译器，版本就是 GCC 13。你跑 riscv64-unknown-elf-gcc
--version，第一行末尾的 13.x.x 就是它。

它在本实验里的位置

Makefile:68-70 这三行：

TOOLPREFIX    := riscv64-unknown-elf-
CC = $(TOOLPREFIX)gcc

CC 就是 Makefile 里代表编译器的变量。所以每次 make
build，真正在翻译你内核代码的就是这个 GCC 13。

为什么版本号在这里值得一提

因为编译器不是死的工具，它也在演进。新版本会加入新的检查。GCC 13 遇到
xv6-user/sh.c 里的 runcmd() 就会报一句
-Winfinite-recursion（怀疑是无限递归）。

麻烦在于 Makefile:79 里有这个：

CFLAGS = -Wall -Werror ...

-Werror 的意思是“把警告当成错误”。所以一个新版本编译器多出来的警告，会让本该编
过的旧代码直接编译失败。

仓库已经处理了——同一行后面跟着
-Wno-error=infinite-recursion，专门给这一条警告开个口子。所以你在 make build
里看到这条警告是正常的，它不会中断构建。

---
顺带提一句你可能会撞上的混淆：gcc --version（不带前缀）报的也是
GCC，但那是给你 x86-64 的 Ubuntu 编译普通程序的，跟 xv6
一点关系都没有。本实验只认带 riscv64-unknown-elf- 前缀的那个。

### Turn 5

#### User

现在我想问一下一个能够正常运行的电脑系统都要包含什么

#### Claude

一句话：一台电脑能跑起来，靠的是一条四棒接力——每一棒只做一件事，把下一棒扶起来
，然后让位。

 棒   是什                  干活的内容                  本实验里是谁
 次    么
 1    硬件  CPU 取指执行、内存、外设                    QEMU 假装出来
                                                        的那台机器
 2    固件  上电后第一段代码：把硬件初始化到能用，然后  OpenSBI（M-mo
            找到内核跳过去                              de）
 3    内核  操作系统本体                                xv6-k210（S-m
                                                        ode）
 4    用户  人和程序干活的地方                          init → sh →
      态                                                -> / $

第 1 棒：真硬件就是 CPU、内存、一堆外设芯片。它自己什么都不会，只会听指令。

第 2 棒：CPU 一上电，PC 指向一个固定地址，那里躺着固件。固件的活儿很具体——把内
存控制器、中断控制器这些"开机前必须先摆好"的东西配置好，然后跳到内核入口。你的
make run 里，-bios default 让 QEMU 加载的就是它。

第 3 棒是重点，因为"操作系统"这个词真正指的是它。内核不管业务，它只提供四种基
础能力：

- 管进程 —— 谁在跑、什么时候换人 → proc.c、swtch.S
- 管内存 —— 谁能用哪些内存、怎么隔离 → kalloc.c、vm.c
- 管文件 —— 数据怎么存、怎么按名字找 → fat32.c、file.c
- 管设备 —— 屏幕、磁盘、时钟怎么用 → uart.c、disk.c、plic.c

这四件事就是"操作系统"的全部底子。你在 shell
里敲的每一条命令，往下追都会落到这四组文件之一。

第 4 棒：内核把 init 跑起来，init 再 fork 一个
sh。真正坐在屏幕上等你打字的，是这个 sh。

---
有个很妙的点：这份清单你不用背，make run 会把它打印出来。
屏幕上依次出现的三段东西，正好就是第 2、3、4 棒在自报家门：

OpenSBI v1.0          ← 第2棒：固件说"我干完了"
xv6-k210 ...          ← 第3棒：内核说"我起来了"
-> / $                ← 第4棒：shell 说"轮到你输入了"

所以 -> / $
出现这件事，信息量比它看起来大得多——它意味着从通电到用户态，四棒一棒没掉。

等你跑 make run
的时候留意一下这三段的先后顺序。有任何一棒看懂了想往下挖，再问我。

### Turn 6

#### User

那这个编译器和指令集呢？

#### Claude

好问题——你这是在把新东西往刚才那张图上放。但它俩放不上去，因为它们不在那条接力
链上。

刚才那四棒，全都是运行的时候在场的东西：通电了，它们一棒接一棒地活着。而编译器
和指令集属于另外两个维度：

- 编译器是建造阶段的东西。make build 的时候它干活，make run
的时候它早就退场了。链上跑的不是编译器，是它留下的产物（target/kernel）。
- 指令集根本不是一个"东西"，是一份契约。它是硬件和软件之间的约定：硬件说"我听
得懂这些指令"，软件说"那我只用这些写"。它没有位置，因为它贯穿整条链。

画成图大概是这样：

【建造期】在你的 x86-64 Ubuntu 上
    C 源码 [gcc 翻译]> RISC-V 机器码 > target/kernel
                                                  ▼
【运行期】接力链
    硬件 > 固件 > 内核 > 用户态
    （链上每一节，都是用 RISC-V 指令写的）
                    ↑
              QEMU 站在链外托着第一棒
              ——它自己是 x86-64 程序

所以三者是三件事：编译器是造链的工人，指令集是链子每一节都遵守的规格，四棒接力
是链子怎么动起来。

---
再挖一层：编译器其实不是必须的。

指令集那份契约，你可以让编译器替你履行，也可以自己直接写。xv6
里就有一批文件是手写的汇编：

- kernel/entry_qemu.S —— 内核第一条指令，给每个 hart 设栈
- kernel/swtch.S —— 进程上下文切换
- kernel/trampoline.S —— 用户态陷入内核时换页表

这些地方 GCC 帮不上忙——因为它们要操作的东西（设栈指针、切页表、ecall
的具体寄存器约定）是 C 语言描述不出来的。所以只能人手写。

这就是为什么 kernel/ 目录里 .c 和 .S 混着放：能用 C 说清楚的部分交给
gcc，说不清楚的部分手写汇编。 它们最后都被编译成同一种东西——RISC-V 指令。

---
到这里你手里其实已经有三个可以分开看的东西了：建造期的工具链、贯穿全程的指令集
契约、运行期的四棒接力。哪个方向想再往下走，你说。

### Turn 7

#### User

make build为什么我只用这一句话系统就知道我要装一个什么样子的内核呢？难道内核
只有一种吗？

#### Claude

make build 什么都不知道。它没有智能，也不会猜——它只是读了一个文件：Makefile。
所有答案都写在那里。

make 这个程序的工作方式很朴素：你去 Makefile 里找有没有一条叫 build
的规则，找到了就照做。Makefile:108 那行就是：

build: $T/kernel userprogs

意思是"要完成 build，先得把 target/kernel 和用户程序搞出来"。至于
target/kernel
怎么来、用什么编译器、编哪些文件——继续往下照抄，一直抄到没有依赖为止。

所以真正回答"要装一个什么样的内核"的，是 Makefile，不是 make。

---
至于"内核只有一种吗"——不是。光这个仓库里就有两种。

看 Makefile 最开头：

#platform     := k210
platform      := qemu
mode := debug
#mode := release

注意那两行被 # 注释掉的。它们就是证据：有人写过 k210 和 release
这两种配置，然后手动关掉了。你现在跑的 make build，用的是 qemu + debug。

这个 platform 不是装饰，它真的在分叉。比如 Makefile:9-13：

ifeq ($(platform), k210)
OBJS += $K/entry_k210.o
else
OBJS += $K/entry_qemu.o
endif

把 platform 改成 k210，编出来的会是另一个内核：

           platform := qemu（你现在）      platform := k210
 内核入口  entry_qemu.o                entry_k210.o
 磁盘驱动  virtio_disk.o               sdcard.o + spi.o + dmac.o
 链接脚本  linker/qemu.ld              linker/k210.ld
 固件      OpenSBI                     sbi-k210

同一份源代码，一行改动，产出的是两个不同的内核。

---
再挖一层：这些分叉发生在"编译之前"。

ifeq 不是给编译器看的注释，是 make
真的会执行的条件判断。它在决定"要编译哪些文件"的时候就做完了选择。

意味着：k210 分支里的 sdcard.c、fpioa.c，在你现在这套配置下根本不会被送去编译—
—不是编了再丢掉，是压根没编。这也解释了为什么 实验指导.md 里说这些文件"QEMU
模式下不参与"。

---
顺带说一句，往大了看：Linux 内核有几千个这样的开关（make menuconfig
那个满屏的配置界面），同一份源码能编出无数种内核——从手机上的到超算上的。所以"
内核"从来不是一种东西，是一族。Makefile 开头那几行，就是这一族里挑一个的旋钮。

### Turn 8

#### User

fs.img这是什么

#### Claude

fs.img 是一块虚拟硬盘。

它本身就是一个普通文件，躺在你的 lab0 目录里：

-rw-rw-r-- 1 ailab-os ailab-os 268435456  9月 14 22:08 fs.img

268435456 字节 = 256 MB。但里面的内容不是一个 256MB
的大垃圾堆——里面装着一个完整的、格式化好的文件系统，里面躺着 init、sh、README
这些文件。

为什么必须有它

xv6 跑到最后要 exec("/init")、要读 /sh——这些文件总得存在某个地方。可 QEMU
造出来的那台虚拟机器是空的，没有你的硬盘。所以得给它配一块。

它是怎么做出来的——Makefile 的 fs 目标：

dd if=/dev/zero of=fs.img bs=512k count=512   # 造一个 256MB 的全零文件
mkfs.vfat -F 32 fs.img                        # 把它格式化成 FAT32
sudo mount fs.img /mnt                        # 挂载！
sudo cp README /mnt/README                    # 往里拷文件
for file in $(ls $U/_*); do sudo cp ... ; done  # 把编译好的用户程序拷进去
sudo umount /mnt                              # 卸载

从"一块空白"到"一个能用的文件系统"，六步。

xv6 怎么用它——Makefile:140-141，启动 QEMU 时把它当磁盘插上去：

QEMUOPTS += -drive file=fs.img,if=none,format=raw,id=x0
QEMUOPTS += -device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0

fs.img 就是 QEMU 里那台虚拟机的硬盘。xv6 里的 disk.c、virtio_disk.c
读的就是它。

---
挖一层：注意那个 mount。

fs.img 能被你的 Ubuntu 直接 mount 到 /mnt——这说明它不是 xv6 的私有格式，是标准
FAT32。任何 Linux 都能读。

你可以自己验证一下，在终端敲：

mkdir -p /tmp/x && sudo mount -o loop fs.img /tmp/x && ls /tmp/x

（看完 sudo umount /tmp/x 卸掉。）你会看到 /init、/sh 就摆在那儿——和 xv6 里 ls
看到的是同一批文件。

---
顺带把前面几课串一下：fs.img 里那些 _sh、_init，是用 RISC-V 交叉编译器在你
x86-64 的 Ubuntu 上编出来的 RISC-V 程序，由一个 x86-64 的 cp 拷进一个 FAT32
镜像，最后被 QEMU 里的 RISC-V 版 xv6 读出来执行。

fs.img 就是这两个世界之间的交接棒。

### Turn 9

#### User

SBI是什么

#### Claude

SBI 是 M-mode 给 S-mode 开的一个服务窗口。全称 Supervisor Binary
Interface——"Supervisor 二进制接口"。

为什么需要这个窗口

接上前面特权级那一课：内核跑在 S-mode，可有些事 S-mode
没权限干——配置定时器、让某个 hart 停下来、关机、直接往控制台吐字符。这些是
M-mode 的地盘。

内核想在 S-mode 里把机器关掉，它做不到。它只能去敲那扇窗口。

本实验的真实位置

kernel/include/sbi.h。别看它名字带 SBI，这个文件其实是窗口的客户端——内核这边用
来"敲门"的封装。里面每个函数最后都落到同一个宏：

#define SBI_CALL(which, arg0, arg1, arg2, arg3) ({        \
      register uintptr_t a7 asm ("a7") = (uintptr_t)(which); \
      asm volatile ("ecall"                             \
                    : "+r" (a0) ...);                    \
      a0;                                                \
})

那个 ecall，和你前面学的用户程序举手用的是同一条指令。

再看 sbi.h:12-20 那几行：

#define SBI_SET_TIMER        0
#define SBI_CONSOLE_PUTCHAR  1
#define SBI_CONSOLE_GETCHAR  2
...
#define SBI_SHUTDOWN         8

这些编号就是窗口的"业务号码"，写在 a7 里递给 M-mode。跟系统调用号是一个套路。

所以 kernel/console.c 里 printf 想往屏幕写字，最后走的是 sbi_console_putchar()
→ ecall → M-mode 的 OpenSBI 替它写。

---
挖一层：这是一部楼梯，每层台阶一模一样。

U-mode  ecall>  S-mode     用户程序请求内核   = 系统调用
S-mode  ecall>  M-mode     内核请求固件       = SBI 调用

同一条指令，同一个套路：把请求编号和参数放进约定好的寄存器，ecall，对面接住，
办完返回。只是每一层抬高了一档特权级。

这就是为什么它叫 "Interface"——和 "ABI"（Application Binary
Interface）一个构词法。它是一份约定，不是一个程序。约定这一头是内核的
sbi.h，那一头由谁实现都行。

谁实现了它？ QEMU 自带的 OpenSBI。Makefile:137 那行 -bios default 就是让 QEMU
把它加载进去。你 make run 时最先看到的那段 OpenSBI
banner，就是这扇窗口的营业公告。

---
一句话收口：SBI 就是内核的"系统调用"，只不过调用对象是固件而不是内核。
