# Claude Code QA (Clean)

- 学号：2406080124
- 姓名：周珈冰
- 数据采集时间：2026-09-20 14:56
- 原始时间标识：20260920-1456
- 原始数据目录：2406080124-周珈冰-20260920-1456
- 终端录像数量：51

- 实验分类：其他（非 lab0–lab8 或目录未知）

- Claude 会话总数：9
- 对话轮次总数：38
- 有效用户问题数：38
- 有效 Claude 回复数：38

## Session 1：20260909T120305-13333

- 对话轮次：2
- 开始时间：2026-09-09 12:03:05+08:00

### Turn 1

#### User

hi

#### Claude

Hi! How can I help you today?

### Turn 2

#### User

你好

#### Claude

你好！有什么我可以帮你的吗？

## Session 2：20260914T111609-19048

- 对话轮次：1
- 开始时间：2026-09-14 11:16:09+08:00

### Turn 1

#### User

现在我需要关于lab0的试验报告，但是我并不知道该怎么提交，是否能在虚拟机上提交
呢

#### Claude

我先了解一下你的环境，看看有没有 lab0 相关的文件和提交说明。

## Session 3：20260915T152544-3853

- 对话轮次：1
- 开始时间：2026-09-15 15:25:44+08:00

### Turn 1

#### User

我的实验提交了没

#### Claude

提交了 ✅

你（周佳冰，学号 2406080124）的实验最后一次成功提交是 2026-09-14
11:10，记录如下：

- 提交包：2406080124-zhoujiabing-实验提交-20260914-1110.tar.gz（大小 1,816,693
字节）
- 上传结果：ok: true —— 服务器已成功接收，sha256 校验一致

也就是说你的提交已经在服务器上了。

不过提醒一下今天（09-15）的情况：从记录看，你今天 15:02
开机登录后，只有心跳记录、没有任何代码改动（changed:0），也没有新的
submit/upload 事件。所以：

- 如果你今天没改代码，那 9-14 那次就是最新提交，没问题；
- 如果你今天改了代码但没重新提交，那最新改动还没上传，需要再跑一次提交。

需要我帮你重新提交一次吗？

## Session 4：20260916T100821-3950

- 对话轮次：2
- 开始时间：2026-09-16 10:08:21+08:00

### Turn 1

#### User

我能把自己电脑上的文件传到虚拟机里吗

#### Claude

可以，方法取决于你的虚拟机软件和网络环境。给你几种最常见的：

1. 拖拽 / 复制粘贴（最快，适合零散文件）

- VirtualBox：设备 → 共享剪贴板 / 拖放
设为「双向」，然后直接从宿主机把文件拖进虚拟机窗口。
- VMware：虚拟机设置里开启「拖放」，直接拖进去。
- 需要先安装 Guest Additions / VMware Tools 才能用。

2. 共享文件夹（适合大量/经常传文件）

- VirtualBox：设备 → 共享文件夹 →
添加宿主机的目录，在虚拟机里挂载到某个路径（如 /mnt/share）。
- VMware：虚拟机设置 → 选项 → 共享文件夹，同理。

3. scp / rsync（通用，适合有 SSH 的情况）

如果你的虚拟机能通过 SSH 访问，在宿主机上执行：
# 单个文件
scp /本地/路径/文件.txt 用户名@虚拟机IP:/目标/路径/

# 整个目录
scp -r /本地/目录 用户名@虚拟机IP:/目标/路径/
反过来从虚拟机取文件也同理（把参数顺序对调）。

4. 用 HTTP 临时传文件

在宿主机文件所在目录起一个临时服务器，虚拟机里用浏览器/curl 下载：
# 宿主机上
python3 -m http.server 8000
# 虚拟机里
curl -O http://宿主机IP:8000/文件名

5. 纯文本小文件：直接粘贴

内容不大的话，直接在宿主机复制文本，粘贴进虚拟机的编辑器即可（需开启共享剪贴板
）。

---
你用的是哪款虚拟机软件？（VirtualBox / VMware / 云主机 /
其他）告诉我，以及虚拟机能不能 SSH 连上，我给你最省事的那条命令。

### Turn 2

#### User

VM

#### Claude

VMware 的话，最省事的是共享文件夹，一次配置以后随便传。

方法一：共享文件夹（推荐）

1. 虚拟机设置里添加共享目录（先关机或关机状态设置，部分版本支持热添加）
- VMware 菜单：虚拟机(Virtual Machine) → 设置(Settings) → 选项(Options) →
共享文件夹(Shared Folders)
- 选「总是启用(Always enabled)」，点「添加(Add)」
- 选择宿主机上要共享的目录，起个名字（比如 share）

2. 虚拟机里查看共享内容
- Windows 虚拟机：网络位置里会显示 \\vmware-host\Shared
Folders\share，或映射成 Z: 盘
- Linux 虚拟机：挂载到 /mnt/hgfs：
sudo mkdir -p /mnt/hgfs
sudo vmhgfs-fuse .host:/ /mnt/hgfs -o allow_other
如果提示找不到 vmhgfs-fuse，先装 VMware Tools / open-vm-tools：
sudo apt install open-vm-tools open-vm-tools-desktop   # Debian/Ubuntu

方法二：拖拽（零配置，适合偶尔传几个文件）

- 确认装了 VMware Tools
- 虚拟机设置里勾选「拖放(Drag and Drop)」为「双向(Bidirectional)」
在宿主机上执行（需要知道虚拟机的 IP）：
scp /本地/文件.txt 用户名@虚拟机IP:/目标/路径/

---
两个问题帮我确认一下，就能给你精确命令：

1. 虚拟机里装的是 Windows 还是 Linux？（看你现在 /home/ailab-os 这个环境，虚拟机很可能是
Linux）
2. 你的 VMware 是哪个产品——Workstation / Player / Fusion（Mac）？

如果虚拟机就是 Linux，最推荐 open-vm-tools +
共享文件夹，配置一次永久好用。要的话我把完整命令按步骤给你。

## Session 5：20260916T102744-3101

- 对话轮次：3
- 开始时间：2026-09-16 10:27:44+08:00

### Turn 1

#### User

我已经打开了虚拟机共享文件夹，怎么在虚拟机上查看我的宿主计算机文件夹

#### Claude

我先看一下这台虚拟机用的是什么虚拟化平台（VMware / VirtualBox /
Hyper-V），这样能给你准确的挂载命令。

### Turn 2

#### User

以上成功了，但是我想要每次开机不需要再重新配置共享文件夹，且我现在在主目录中
找不到mnt文件夹

#### Claude

先说 mnt 找不到的原因，再给开机自动挂载的配置。

### Turn 3

#### User

刚刚我cd到了hgfs文件夹，怎么在终端中回到一开始的文件夹

#### Claude

两个命令，看你要回哪儿：

cd -      # 回到上一次所在的目录（就是你 cd 过来之前的那个）
cd        # 直接回家目录 /home/ailab-os

cd - 靠的是 shell 的环境变量
OLDPWD，它同时还会把要去的路径打印出来，所以你执行后会看到类似：

/home/ailab-os

这样你就知道回到哪了。它还能来回切换——在 /mnt/hgfs 敲 cd - 回家目录，再敲一次
cd - 又回到 /mnt/hgfs。

几个相关的：

    命令                 作用
 cd -        上次的目录（来回跳很方便）
 cd 或 cd ~  家目录 /home/ailab-os
 cd ..       上一级目录
 cd /        文件系统根目录
 pwd         看当前在哪（迷路了就敲这个）

顺带一提：因为 /mnt/hgfs 是挂载点，cd .. 会到
/mnt，不是回到你来时的目录——这种情况就得用 cd -。

## Session 6：20260916T104443-2705

- 对话轮次：3
- 开始时间：2026-09-16 10:44:43+08:00

### Turn 1

#### User

我重新启动后可以看到主机共享文件夹，但是无法打开

#### Claude

我先看看当前环境的情况，判断是哪种虚拟机共享方案。

Listed 1 directory (ctrl+o to expand)

### Turn 2

#### User

还是打不开阿

#### Claude

先看看现在实际是什么状态 —— 上一轮的命令到底跑没跑、跑成什么样。

### Turn 3

#### User

cp: 在 '/tmp/fstab.new/etc/fstab' 后缺少要操作的目标文件
请尝试执行 "cp --help" 来获取更多信息。
bash: 行 1: echo--- 挂载参数 ---: 未找到命令
vmhgfs-fuse /mnt/hgfs fuse.vmhgfs-fuse rw,relatime,user_id=0,group_id=0 0 0
--- 目录内容 ---
总计 17
dr-xr-xr-x 1 root root 4192  9月 16 10:52 .
drwxr-xr-x 3 root root 4096  9月 16 10:33 ..
drwxrwxrwx 1 root root 8192  9月 16 10:26 智能24-操作系统-虚拟机

#### Claude

看出来了——你的输入在丢空格：

- cp /tmp/fstab.new /etc/fstab 变成了 cp /tmp/fstab.new/etc/fstab
- echo "--- 挂载参数 ---" 变成了 echo--- 挂载参数 ---（但下面那个 echo "---
目录内容 ---" 却正常）

所以 /etc/fstab 依然没被改（挂载参数还是 user_id=0,group_id=0），而 ls
之所以能列出 智能24-操作系统-虚拟机，是因为它在 sudo bash 里以 root
身份跑的——root 一直都能访问，这跟你的诊断无关。

长命令在你的终端里会被吞字符，所以我不再让你粘贴长命令了。我把整个修复写成一个
脚本，你只需要执行一条几乎没有空格的命令：

## Session 7：20260916T112944-5479

- 对话轮次：1
- 开始时间：2026-09-16 11:29:44+08:00

### Turn 1

#### User

123

#### Claude

I'm here — that looks like a test message. What would you like to work on?

I can see your working directory is /home/ailab-os (not a git repo). Let me
know what you need, and if it's a code task, point me at the relevant files or
projects.

## Session 8：20260920T124631-3840

- 对话轮次：14
- 开始时间：2026-09-20 12:46:31+08:00

### Turn 1

#### User

源码先被make指令编译成QEMU能读懂的RISC-V编码，再由QEMU这个虚拟电脑中的CPU把相
应的指令执行，我的理解对吗？

#### Claude

你的理解大方向对，但有几处关键细节需要修正。让我先看一下你的工作目录，好结合具
体项目说。

### Turn 2

#### User

xv6 的 `exec()`是什么

#### Claude

我看一下你这个仓库里的实际实现。

### Turn 3

#### User

`make run` 背后执行了搭建镜像、把源代码搬进QEMU，对吗

#### Claude

让我把这个 Makefile 的依赖链完整走一遍，别凭印象说。

### Turn 4

#### User

QEMU 参数是QEMU本身识别的吗

#### Claude

好问题——答案是"是的，但有个重要的例外"。让我实际验证一下。

### Turn 5

#### User

内核第一条指令在哪个文件

#### Claude

工具链是 riscv64-unknown-elf-（Makefile 里那行被注释掉了，实际配的是
riscv64-linux-gnu-——这是个坑，稍后说）。我先用现成的工具链验证一下第一条指令：

### Turn 6

#### User

M-mode 的 CSR、PMP、mepc和mret是什么

#### Claude

这份代码里的 RustSBI 源码正好是完整的 M 模式教材。先做两个验证：

### Turn 7

#### User

但这个操作系统又没有用到K210真板子，为什么会有RustSBI

#### Claude

好问题——这正是"虚拟平台也需要固件"的经典疑问。让我用证据回答。

### Turn 8

#### User

为什么需要两个hart

#### Claude

反直觉的地方在于：不是 xv6 需要两个核，是 K210 有两个核。

根本原因：这个移植的目标平台是双核的

K210（Kendryte K210）是一颗双核 RV64GC 芯片——两个 64 位 RISC-V 核，各带
FPU，共用 8MB SRAM。这不是可选项，是硬件规格。

所以 -smp 2 的作用是让 QEMU
模拟出目标硬件的规格，而不是因为操作系统需要两个核才能跑。QEMU 上这两个 hart
是 K210 那两颗核的替身。

证据就在参数里：

// kernel/include/param.h:5
#define NCPU          2  // maximum number of CPUs

NCPU 是编译期硬编码的 2，不是从 QEMU 那里问来的。内核不探测有几个核，它假设有
2 个——因为这个移植只打算跑在 K210 和"模拟 K210 的 QEMU"上。

更能说明问题的是这行（kernel/main.c:25）：

static inline void inithartid(unsigned long hartid) {
  asm volatile("mv tp, %0" : : "r" (hartid & 0x1));
}

hartid & 0x1 —— 把 hart id 直接截断到 0 或 1。这是明摆着假设"最多两个核"。

单核其实也能跑

代码里没有"必须双核才能工作"的逻辑。看 main.c 的分工：

if (hartid == 0) {
    // 全部初始化：console、内存、页表、trap、进程、磁盘……
    for(int i = 1; i < NCPU; i++) {
      unsigned long mask = 1 << i;
      sbi_send_ipi(&mask);        // 唤醒其它核
    }
    __sync_synchronize();
    started = 1;                   // ← 举起发令枪
}
else {
    while (started == 0) ;         // ← 其它核原地等
    __sync_synchronize();
    kvminithart();                 // 只做 per-hart 的初始化
    trapinithart();
    plicinithart();
}
scheduler();                       // 所有核都进调度器

hart 0 是"主核"，干所有脏活；hart 1
是"从核"，等主核完事后只补几项自己的配置就进调度循环。
这是对称多处理（SMP）的标准启动模式。如果只有 1 个 hart，for
循环不执行，started = 1 照设，一切正常——只是少一个干活的。

（实际上 -smp 1 会有点小问题：sbi_send_ipi 会给不存在的 hart 1 发中断，不过
RustSBI 会忽略掉，不影响。）

那两个核到底买到了什么

从操作系统教学的角度，多核的意义不只是"快"：

       问题                单核                    多核
 自旋锁             只在关中断时有意义  真需要，两个核真的会同时抢
 原子操作           基本用不上          __sync_*、LR/SC 指令必需
 内存序 / 内存屏障  没有意义            必需
 缓存一致性         不存在              真实存在
 TLB shootdown      不存在              改页表要通知其它核
 push_off/pop_off   简单                要同时管中断和锁

单核操作系统上，这些全是"假问题"。
加上第二个核，它们立刻变成必须正确处理的真问题。这才是 -smp 2 的教学价值。

那个 __sync_synchronize()（main.c:65,72）就是活生生的例子：

started = 1;   // 如果没有屏障……

hart 0 在 started = 1 之前往
cpus[]、proc[]、页表里写了一堆东西。如果没有内存屏障，hart 1 完全可能看到
started == 1 却看不到那些初始化结果（因为写操作重排序 /
存储缓冲区还没刷出去）。hart 1 一进 scheduler() 就访问半成品的 proc
数组，直接崩。

单核上你永远遇不到这个问题。

per-hart 的寄存器：哪些是每核独立的

这是多核编程的核心认知。这些每个核各有一套：

     寄存器           作用                    在哪设置
 satp             页表基址      kvminithart()（main.c:78,79
                                调了两次！）
 stvec            陷阱向量      trapinithart()
 sscratch         trapframe     同上
                  指针
 tp               存 hart id    inithartid()
 PLIC S-mode      中断开关      plicinithart()
 使能位

注意 main.c:78-81：hart 1 要单独跑一遍 kvminithart() 和 trapinithart()。为什么
hart 0 初始化时不能顺手帮它设了？因为 csrw satp, ... 只改当前核的寄存器。页表
内容是共享的（在内存里），但"用哪张页表"这件事是每个核各自记的。

tp 存 hart id 的用处在这里（proc.c:84-88）：

int cpuid() {
  int id = r_tp();      // 我是哪个核？
  return id;
}

内核任何地方都能问"我现在跑在哪个核上"，靠的就是 tp。而 struct cpu cpus[NCPU]
（proc.c:18）就是每个核的状态集合——当前进程、调度器上下文、关中断嵌套深度。

回到第一个问题：*2 是这么来的

现在可以完整解释你早先看到的那段 entry_qemu.S 了：

asm
add  t0, a0, 1        # t0 = hartid + 1
slli t0, t0, 14       # t0 = (hartid+1) × 16384    ← 4 页 × 4096
la   sp, boot_stack
add  sp, sp, t0

asm
boot_stack:
    .space 4096 * 4 * 2     # ← 这个 ×2，就是 ×NCPU

 hart       sp 初值           栈区间
 0     boot_stack + 16KB  [+0, +16KB)
 1     boot_stack + 32KB  [+16KB, +32KB)

32KB 正好装下 2 份 16KB 栈。 每个 hart
必须有独立的栈——否则两个核同时压栈会互相覆盖，这是最隐蔽也最致命的竞态。

这形成一个三方耦合，改一处必须改三处：

Makefile:  -smp 2
param.h:   #define NCPU 2
entry.S:   .space 4096 * 4 * 2

如果只把 -smp 改成 4 而不动其它两个：hart 2 的 sp 会是 boot_stack +
48KB，超出数组末尾 16KB，直接踩进 .bss 里别的变量；同时 inithartid 的 & 0x1
会把 hart 2 当成 hart 0，两个核共用一个
cpuid()。整个系统会以一种极难调试的方式崩溃。

这跟你前面看到的 -m 8M ↔ PHYSTOP 是同一类东西：Makefile
和源码之间靠人维护的隐式契约，没有任何工具帮你检查。

一句话总结

-smp 2 的存在理由是保真：K210 是双核的，所以 QEMU 也必须开两个核，这样在 QEMU
上调试出的锁行为、调度行为、竞态结论才能迁移到真板子上。如果 QEMU 单核跑、真板
子双核跑，那你等于在两个不同的系统上调试——这正是嵌入式移植最怕的事。

### Turn 9

#### User

trapframe->sp = PGSIZE这条指令是什么意思，通俗的讲一下

#### Claude

这行在 kernel/proc.c:299，是 userinit() 里给第一个用户进程准备初始状态：

p->trapframe->epc = 0x0;      // 用户程序从哪开始跑
p->trapframe->sp  = PGSIZE;   // 用户栈顶在哪 = 4096

先记住一个前提：栈是"倒着长"的

想象一个立式冰柜，开口在顶上。你往里放东西的时候，是从顶部往下放，放一个，手就
往下挪一格。

- "手现在的位置"就是 sp（stack pointer，栈指针）
- 冰柜里空着的时候，"下一个该放东西的位置"就是最顶上那一格
- 而"最顶上"的地址 = 冰柜底部地址 + 冰柜高度

现在看 initcode 的地址空间。uvminit() 给它分配了整整一页（vm.c:274）：

mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
//                  ↑ 从虚拟地址 0 开始，映射 4096 字节

所以它的"冰柜"就是虚拟地址 0x0000 到 0x1000 这一页：

0x0000    ← 冰柜底部
          initcode 代码       epc = 0，程序从这开始执行
          "/init" 字符串
          argv 数组
              ↓↓↓         ← 栈从上面往下长，往代码方向长
0x1000    ← 冰柜顶部 = 4096 = PGSIZE
                                 sp 初值就指向这里

所以 sp = PGSIZE 的意思就是"栈是空的，从这一页的最顶上开始往下用"。 4096
恰好是这一页的末尾（0x1000），也是整个进程地址空间的边界。

压栈的时候 sp 会减小（比如 sp -= 16），用到
0x0FF0、0x0FE0……越来越小，朝着代码那个方向逼近。initcode
只有几十字节，离碰撞还远得很。

为什么必须手工设置这个值

因为内核接下来要做一件"骗人"的事。

正常情况下，用户程序调用 ecall 陷入内核，内核处理完执行 sret 返回。sret 会从
trapframe 里恢复所有寄存器——包括 sp。一切自洽。

但 initcode 是第一个用户进程，它从来没陷入过内核，没有"被保存的状态"！所以内核
得凭空捏造一份：trapframe 就是化妆盒，内核把用户态"应该长什么样"摆好——epc = 0
表示从代码开头跑，sp = 4096 表示栈从页面顶端开始——然后一条 sret，CPU
就"假装"从用户态返回了，initcode 开始运行。

一句话：这是内核在把木偶摆好姿势，准备让它活过来。

对比一下 exec 里的写法

你在早先看 exec() 时见过类似的，但那里是变量：

// kernel/exec.c:159
p->trapframe->sp = sp;    // ← 是变量 sp，不是常量 PGSIZE

区别在于：

                 userinit()                     exec()
 目标程序   initcode，只有一页     任意 ELF，可能几 MB
 栈放哪     和代码挤在同一页里     单独分配两页（exec.c:112）
 sp 怎么定  写死 PGSIZE（就一页）  算出来 sp = sz（跟着程序大小走）

exec 加载的程序可能很大，栈得单独放在所有代码段之上的高地址，所以必须先算出
sz（程序占多大），再定 sp。而 initcode
小得可怜，一页装下代码和栈绰绰有余，直接写常量 4096 就行。

一个容易混淆的点

这个系统里有好几种栈，初值算法都不一样，别搞混：

          栈                 设置位置                  初值
 内核启动栈（每个      entry_qemu.S:6-7      boot_stack +
 hart）                                      (hartid+1)×16KB
 进程的内核栈          proc.c:165            p->kstack + PGSIZE
 用户栈                proc.c:299 /          PGSIZE / 算出来的 sz
                       exec.c:159

注意后面两个都是 "某段内存的起始地址 + PGSIZE" ——
一模一样的套路：p->context.sp = p->kstack +
PGSIZE（proc.c:165）表示"内核栈也是从这一页的顶端开始往下用"。

"栈顶 = 一段内存的末尾" 这个规律，你在这个系统里到处都能看到。

---
通俗总结：trapframe->sp = PGSIZE 就是告诉 CPU
——"这个新进程的栈，从它那页内存的最顶上（地址 4096）开始，往下长"。

### Turn 10

#### User

阶段三提到，allocproc() 把 p->context.ra 设为了 forkret，因此 swtch 结尾的
ret 指令会跳转到 forkret。我并没有在阶段三找到相应的代码，通俗的讲解什么是for
kret，他的作用是什么

#### Claude

先把代码位置给你——它不在阶段三的讲义里，但确实在仓库里，而且很可能是被注释掉的
printf 骗了：

// kernel/proc.c:613-635
// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
  // printf("run in forkret\n");     ← 第 618 行，被注释了
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);

  if (first) {
    // printf("[forkret]first scheduling\n");   ← 628 行，也被注释了
    first = 0;
    fat32_init();
    myproc()->cwd = ename("/");
  }

  usertrapret();
}

阶段三的讲义大概只贴了 allocproc() 里那两句注释，没贴函数本体。

为什么非要有个 forkret 不可

根源在 swtch 的最后一行（kernel/swtch.S:40）：

asm
swtch:
    sd ra, 0(a0)      # 保存调度器的 ra
    ...
    ld ra, 0(a1)      # ra = 新进程的 context.ra
    ...
    ret               # ← 就是 "jr ra"，跳到 ra 指向的地址

ret 只会做一件事：跳到一个函数的开头。 仅此而已。

那为什么不把 p->context.ra 直接设成用户程序的入口地址，一步到位跳到用户代码？

因为办不到。此刻 CPU 还在内核里，拿着一堆还没收拾的东西：跑在内核页表上、stvec
指向内核陷阱处理程序、sstatus 里记着"来自 S
模式"。直接跳进用户代码，等于用内核的身份去执行用户的指令——权限全乱套了。

回到用户态需要一整套准备工作：切页表、设 sepc、把 sstatus.SPP 清成 User、设
stvec、最后 sret。这套活儿已经有个函数在干了，叫
usertrapret()（kernel/trap.c:104）。

但 usertrapret() 是个 C 函数 —— 它需要被"调用"，需要合法的栈、需要 ra
里有返回地址。而 ret 只会"跳"。

▎ 所以 forkret 就是一个专门用来"接住这个 ret"的函数。

打个比方：swtch 的 ret 像一条传送带，只能把人放到某个房间的门口。你要去的地方
在楼上，得走一段楼梯（usertrapret 里那一串设置）才能进门（sret）。forkret
就是那个门口。

换个角度说：forkret 是给新进程伪造的"第一帧"。 老进程让出 CPU 时冻结在 swtch
里，下次回来从原地继续。新进程没有"原地",只能伪造一个——伪造的手段就是往
context 里塞好地址，让 swtch 以为自己在恢复一个旧进程，实际上一头撞进了
forkret。

它具体干的三件事

① release(&myproc()->lock) —— 接棒

回头看调度器（kernel/proc.c:546-557）：

acquire(&p->lock);
if(p->state == RUNNABLE) {
    p->state = RUNNING;
    c->proc = p;
    swtch(&c->context, &p->context);   // ← 锁还攥在手里就切走了

调度器是攥着 p->lock 切换过去的。为什么？因为进程的状态刚从 RUNNABLE 改成
RUNNING，这个过渡期必须锁住，否则别的 CPU 核可能半路把它抢走。

紧接着调度器留了句话（proc.c:550-551）：

// It is the process's job to release its lock and then reacquire it
// before jumping back to us.

"释放这把锁是进程自己的事。" 而进程第一次获得执行权的地方，正是 forkret
的第一行。

这是个很漂亮的接力：交棒的人手还没松，接棒的人在对面松开。

（之后这个进程再让出 CPU 时走的是另一条对称的路 —— yield() 里
acquire(&p->lock) 后 sched()，proc.c:604-611。）

② fat32_init() —— 一生只做一次的初始化

这是 forkret
存在的第二个理由，也是最容易被忽略的。看原注释（proc.c:625-627）：

// File system initialization must be run in the context of a
// regular process (e.g. because it calls sleep), and thus cannot
// be run from main().

翻译过来：fat32_init() 干活时会 sleep()（比如等磁盘 IO 完成），而 sleep()
需要一个有效的当前进程 —— 它得把进程挂到某个等待队列上去。

可是在 main() 里根本就没有"当前进程"这回事！myproc()
返回的是垃圾数据。所以文件系统初始化不能放在 main() 里做。

那放哪？推迟到"系统里第一次有进程真正跑起来"的那一刻 —— 那正好就是 forkret。

static int first 保证这段代码整个系统生命周期只执行一次。注意它是个 static
局部变量 —— 哪怕 forkret 被调用 100
次（每个进程第一次被调度时都会经过它），fat32_init() 也只在最开始那次跑一遍。

myproc()->cwd = ename("/") 同理：每个进程都需要一个"当前工作目录"，第一个进程
顺手创建根目录并把它设成自己的 cwd。

③ usertrapret() —— 真正下到用户态

kernel/trap.c:104 起，干的是：

w_stvec(TRAMPOLINE + (uservec - trampoline));   // 下次从用户态陷入走这条路
p->trapframe->kernel_satp   = r_satp();         // 填下次陷入时要用的内核信息
p->trapframe->kernel_sp     = p->kstack + PGSIZE;
p->trapframe->kernel_trap   = (uint64)usertrap;

x = r_sstatus();
x &= ~SSTATUS_SPP;      // 上次特权级 = User
x |= SSTATUS_SPIE;      // 用户态开中断
w_sstatus(x);

w_sepc(p->trapframe->epc);   // 用户程序从哪条指令开始（initcode 是 0）
...
sret                          // 正式落到用户态

注意 p->trapframe->epc 和 p->trapframe->sp —— 就是你上一个问题里
proc.c:298-299 设置的那两个值。上一环的伏笔在这里收网：epc = 0 让 initcode
从代码开头跑，sp = PGSIZE 让它从栈顶开始。

完整时序

调度器线程                                新进程（第一次被调度）
acquire(&p->lock)
p->state = RUNNING
c->proc = p
swtch(&c->context, &p->context)
    sd ra/sp/s0-s11 → c->context     （冻住调度器）
    ld ra/sp/s0-s11 ← p->context     （解冻"新进程"）
         ra = forkret           ← allocproc 埋的（proc.c:164）
         sp = kstack + PGSIZE   ← allocproc 埋的（proc.c:165）
   ret → forkret()
                                            release(&p->lock)     ①
                                            if(first) fat32_init() ②
                                            usertrapret()          ③
                                                 ↓
                                             设 stvec / sepc / sstatus
                                             切到用户页表
                                             sret → initcode 跑起来

   （很久以后，这个进程 yield 了）
   swtch 返回 ← sched() 里的 swtch
   继续往下走

两个补充

只有"第一次"才走 forkret。 这个进程以后每次被调度，它的 context 已经被 swtch
更新成"冻结在自己让出 CPU 的那一点"了，回来直接从 swtch 后面接着跑，不会再经过
forkret。forkret 只服务于"从零开始的进程"。

名字的由来：forkret = "fork return"，即"从 fork
返回的路径"。因为这套机制最早就是给 fork() 出来的子进程用的 ——
子进程的诞生发生在内核里，它没法"从 fork 函数返回"，只能伪造一条返回路径。后来
系统里第一个进程（initcode）借用了同一条路。

一句话总结：forkret 是内核给"第一次上场的进程"准备的起跑器。swtch 的 ret
只能把人送到一个函数门口，forkret
就是那个门口——它松开调度器递来的锁、顺手做一次全局初始化（这事在 main()
里没法做，因为没有"当前进程"），最后调用 usertrapret() 把进程真正送进用户态。

### Turn 11

#### User

sys前缀是什么意思，syscall、sysnum又是什么意思

#### Claude

sys 是 system 的缩写。但你的困惑很可能来自——同一个词在这套代码里出现在三个不同
的层次，指的是三件不同的事。

先拆词

   词        全称                          是什么
 syscall  system call  ① 概念：系统调用 ② 文件 kernel/syscall.c ③
                       里面的分发函数 syscall()
 sysnum   system call  文件名 kernel/include/sysnum.h，一张编号表
           numbers
 sys_     system call  内核里"某个系统调用的实现函数"
 前缀

核心：同一个功能，在三个层次上有三个名字

拿 fork 举例：

      层次         名字       长什么样                在哪
 用户程序看到的  fork      int             xv6-user/user.h:9
                           fork(void);
 用户态的桩代码  fork      3 条汇编指令    xv6-user/usys.S（自动生成）
 内核里的真身    sys_fork  几十行 C 代码   kernel/sysproc.c
 两者之间的号码  SYS_fork  数字 1          kernel/include/sysnum.h:5

关键认知：用户态的 fork() 和内核的 sys_fork() 是两个完全不同的函数。

用户态的 fork() 什么活都不干，它只是给内核打个招呼。真正的创建进程的活儿全在
sys_fork() 里。既然是完全不同的两个东西，就不能重名——所以内核版本加 sys_
前缀。

完整链路

用户程序                          内核
fork()
    调用 usys.S 里的桩
  ↓
fork:
  li   a7, SYS_fork   ← 号码 1
  ecall               ← 陷入内核
  ret
   ecall → usertrap()
                                      认出这是用户态的系统调用
                                     ↓
                                   syscall()          ← 分发器
                                      num = trapframe->a7  取到 1
                                      syscalls[1]()
                                     ↓
                                   sys_fork()         ← 真正干活
                                      返回值写入 trapframe->a0
                                     ↓
  ← 回到用户态，返回值在 a0

usys.pl 就是用来生成那些桩代码的（xv6-user/usys.pl:9-16）：

sub entry {
    my $name = shift;
    print ".global $name\n";
    print "${name}:\n";
    print " li a7, SYS_${name}\n";   # 把号码放进 a7
    print " ecall\n";                 # 陷入内核
    print " ret\n";
}
...
entry("fork");

生成的汇编长这样：

asm
.global fork
fork:
 li a7, SYS_fork      # SYS_fork = 1
 ecall
 ret

用户态的 fork() 总共就三条指令。
它自己不会创建进程，只是"报个号"然后跳进内核。

syscall() 是个跳转表

kernel/syscall.c:179：

void
syscall(void)
{
  int num;
  struct proc *p = myproc();

  num = p->trapframe->a7;                    // ← 从 a7 取号码
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    p->trapframe->a0 = syscalls[num]();      // ← 查表调用，返回值放 a0
    if ((p->tmask & (1 << num)) != 0) {      // trace 功能
      printf("pid %d: %s -> %d\n", p->pid, sysnames[num], p->trapframe->a0);
    }
  } else {
    printf("pid %d %s: unknown sys call %d\n", p->pid, p->name, num);
    p->trapframe->a0 = -1;
  }
}

它自己一个系统调用也不实现，只做三件事：取号码、查表、调用。

那张表在 syscall.c:120：

static uint64 (*syscalls[])(void) = {
  [SYS_fork]        sys_fork,      // [1]  → sys_fork
  [SYS_exit]        sys_exit,      // [2]  → sys_exit
  [SYS_wait]        sys_wait,      // [3]  → sys_wait
  ...
};

这叫指定初始化器（designated initializer）——[SYS_fork]
明确指定这个函数指针放在数组的第 1 号位置。所以 syscalls[1] 就是 sys_fork。

这个设计的好处：加一个新系统调用，只要在表里加一行，syscall()
本身一个字都不用改。

注意那个防御检查 && syscalls[num]：如果表里某个位置忘了填，它就是
NULL，这里会挡住，打印 "unknown sys call" 而不是跑飞。

a7 寄存器就是"点菜号码"

整个机制的本质是：用户和内核约定一个整数来代表要什么服务。

- 用户态：li a7, SYS_fork → ecall
- 内核态：读 trapframe->a7，知道用户要 fork

编号表就是 kernel/include/sysnum.h：

// System call numbers
#define SYS_fork         1
#define SYS_exit         2
#define SYS_wait         3
...
#define SYS_rename      26

为什么用数字，不用函数名？

- 用函数地址：用户和内核在不同地址空间，用户手里的地址在内核里毫无意义，而且等
于把内核布局暴露给用户——不安全
- 用字符串名字：ecall 之后内核还得比较字符串，慢，而且字符串要占用户栈空间
- 用整数：塞进一个寄存器，O(1) 查表，完美

SYS_ / sys_ / 无前缀——一套巧妙的命名设计

C 是大小写敏感的，所以这三个是不同的标识符：

fork        // 用户接口（函数名）
SYS_fork    // 编号 1（宏）
sys_fork    // 内核实现（函数名）

同一个词，三种写法，看一眼就知道在说哪一层。 这是 xv6
里贯穿全局的约定，你读代码时靠它就能立刻判断某个东西在哪个空间。

代价：五处必须同步

这个设计不是没有成本的。加一个新的系统调用，要动五个地方：

            文件                         加什么
 kernel/include/sysnum.h      #define SYS_xxx 27
 kernel/syscall.c syscalls[]  [SYS_xxx] sys_xxx,
 kernel/syscall.c sysnames[]  [SYS_xxx] "xxx",
 kernel/syscall.c 顶部        extern uint64 sys_xxx(void);
 xv6-user/usys.pl             entry("xxx");
 xv6-user/user.h              int xxx(...);

没有任何工具帮你检查这六处是否一致。 漏了 syscalls[] 那一行，运行时就会打印
"unknown sys call"；漏了 usys.pl，用户程序链接时报 undefined reference。

顺带提一句 sysnames[]（syscall.c:149）—— 它存在的唯一目的是给 trace
功能用的。你看到的 kernel/syscall.c:188-190 那段打印，就是用户程序
strace（对应 SYS_trace 18）的实现基础：打开 trace
后，每次系统调用都会被打印出来，形如 pid 3: fork -> 5。

一句话总结

- sys = system，表示"这是内核提供的东西"
- syscall = 系统调用：用户态通过 ecall
请求内核服务的机制；也指那个查表分发的函数
- sysnum = 系统调用的编号表，是用户态和内核之间"用哪个数字代表哪个服务"的契约
- sys_ 前缀 = 内核里"某个系统调用的真身"，加前缀是为了不和用户接口重名

用户态的 fork() 只是"报号"，内核的 sys_fork() 才是"干活"。中间的号码，就是
SYS_fork。

### Turn 12

#### User

$ make build
make: *** 没有规则可制作目标“build”。 停止。
ailab-os@ailab-os-VMware-Virtual-Platform:~$ make fs
make: *** 没有规则可制作目标“fs”。 停止。
ailab-os@ailab-os-VMware-Virtual-Platform:~$ make run
make: *** 没有规则可制作目标“run”。 停止。
ailab-os@ailab-os-VMware-Virtual-Platform:~$ ^C
ailab-os@ailab-os-VMware-Virtual-Platform:~$

#### Claude

问题很简单：你在家目录 ~ 里跑 make，但 Makefile 不在这儿。

Makefile 在桌面的子目录里：

### Turn 13

#### User

ilab-os@ailab-os-VMware-Virtual-Platform:~/桌面/xv6-k210-原版参考$ -> / $
halt
bash: /: 是一个目录

#### Claude

让我看一下 xv6 的 shell 是什么样的提示符，以及有没有 halt：

### Turn 14

#### User

怎么进入QEMU

#### Claude

make run 就是进入 QEMU 的方式——没有单独的"进入"步骤。-nographic
参数把虚拟机的串口直接接到你的终端上，所以按下回车那一刻，你就在里面了。

我实际跑一次给你看（喂几条命令进去，然后自动退出）：

## Session 9：20260920T141353-13401

- 对话轮次：11
- 开始时间：2026-09-20 14:13:53+08:00

### Turn 1

#### User

我现在想在shell中执行halt，但是不打印 "should not reach
here"，打印未找到halt目录，是怎么回事？怎么解决

#### Claude

我先看看你的工作目录里有什么，定位这个 halt 相关的代码。

### Turn 2

#### User

[railab-os@ailab-os-VMware-Virtual-Platform:~/桌面/xv6-k210-原版参考$
   -> / $ halt-> / $ halt
   … +8 lines (ctrl+o to expand)

#### Claude

先说结论：你看到的不是 xv6 里的打印，是构建阶段就断了——make build 在链接
xv6-user/_halt 时报：

xv6-user/halt.o: in function `main':
.../halt.c:10:(.text+0x8): undefined reference to `halt'
make: *** [Makefile:173：xv6-user/_halt] 错误 1

意思是 halt.c:10 那句 halt() 找不到函数体，_halt
这个可执行文件压根没生成。没生成，fs.img 里就没有它，xv6 shell 里自然也没有
halt 可跑——所以你还看不到 "should not reach
here"，那不是关机失败，是程序还没被造出来。

把这三层分清楚（这是现在最要紧的一层）：

halt.c（源码）  →  _halt（构建产物）  →  fs.img（装进镜像，xv6 里才能跑）

顺带排掉一个坑：bash 的提示符是 $，xv6 的提示符是 -> / $。在 bash 下敲 halt
是关你的宿主机虚拟机（会提示需要认证），跟实验无关；实验要敲的地方是 -> / $
后面。

链路第一关先过：看 kernel/include/sysnum.h 里现有的编号分布，SYS_halt
应该选什么号？为什么？

### Turn 3

#### User

我填了30,因为1-26都被占用了

#### Claude

1~26 确实排满了（sysnum.h:5-30），所以号不能落在里面——这个判断是对的。

不过文件里还没落地：kernel/include/sysnum.h:59 现在还是占位的 0，你先把 30
写进去存盘，再 grep SYS_halt kernel/include/sysnum.h
自查一眼。（号是当数组下标用的，27、28、29 空着没好处，顺延的 27 也行；30
不冲突，能用。）

接着看链路的第二段。xv6-user/usys.pl 第 9-16 行有个 entry
子程序，它每被调用一次会生成几条汇编指令？每条分别干了什么？

### Turn 4

#### User

5条，命名，然后把名字付给系统li a7,然后系统调用，最后返回

#### Claude

对。那 5 行里其实是 2 行声明/标签 + 3 条指令：.global+标号、li a7,
SYS_xxx（把号塞进 a7）、ecall（陷入内核）、ret（回到用户态）。所以这个桩函数自
己什么活都不干，只负责"把号放进 a7，然后陷入"。

现在把这一环接上：xv6-user/usys.pl 末尾已经有 entry("fork"); …
entry("rename"); 一串，照同样的格式给 halt 补一行。存盘后跑 make build——之前
halt.c:10 那个 undefined reference 应该就消失了。

（先提一句：编出 _halt 还不等于 xv6
里能跑，镜像那边还有一步，等这一步过了再说。）

把 make build 的结果贴给我。

### Turn 5

#### User

riscv64-unknown-elf-gcc -Wall -Werror -Wno-error=infinite-recursion -O
-fno-omit-frame-pointer -ggdb -g -MD -mcmodel=medany -ffreestanding
-fno-common -nostdlib -mno-relax -I. -fno-stack-protector -D QEMU -c -o
xv6-user/usys.o xv6-user/usys.S
xv6-user/usys.S: Assembler messages:
xv6-user/usys.S:135: Error: illegal operands `li a7,SYS_hait'
make: *** [Makefile:181：xv6-user/usys.o] 错误 1

#### Claude

报错咬住的正是这一处：usys.pl:44 你加的那行，生成出来的桩叫 hait，于是
usys.S:135 变成 li a7, SYS_hait——而 sysnum.h:59 里定义的宏是
SYS_halt。两个名字差了一个字母。

这里有个值得记住的点：usys.pl 自己不检查名字，它只是 print
文本，名字拼错了它照样输出。真正较真的是汇编器——usys.S:7 那句 #include
"kernel/include/sysnum.h" 把宏引了进来，SYS_xxx
必须在那里能找到同名定义，找不到就是"illegal
operands"。这正是桩名和宏名要一字不差的原因。

把 usys.pl:44 的名字跟 sysnum.h:59 逐字母对一遍改掉（放第 44
行还是文件末尾都行，位置不影响；末尾第 68 行那句注释掉的 TODO 可以顺手删掉）。

改完再 make build。

### Turn 6

#### User

-> / $ halt
pid 3 halt: unknown sys call 30

usertrap(): unexpected scause 0x000000000000000f pid=3 halt
            sepc=0x0000000000000020 stval=0xffffffffffffffff
-> / $

#### Claude

两条现象分开看：

unknown sys call 30 —— 内核的 syscall() 从 a7 读到号
30，在分发表里没找到对应处理函数，于是走了 else 分支，把 -1 塞回 a0
当作返回值。这就是链路第三段还没接通：号有了、桩有了，内核这张表里还缺 30
这一项。这一步的报错正好就是 CP③ 要解决的问题。

后面那个 trap —— 这里有个容易误会的点，值得记住：user.h:36 把 halt() 声明成了
__attribute__((noreturn))，等于告诉编译器"这个函数不会返回"。编译器信了，就把
main 里 halt() 之后的代码整段删掉了——printf("should not reach here") 和结尾的
ret 在二进制里根本不存在。objdump -d xv6-user/_halt 一看便知：main 到 0xc 的
jalr 就没了，0x10 紧接着是 strcpy。

所以 syscall 一返回，CPU 顺着往下执行，直接掉进 strcpy
的指令里，用一堆积存器垃圾去写内存（sb a4,-1(a5)，a5 正好被加成 0），写了地址
0xffffffffffffffff —— scause 0xf 是 store page fault，sepc=0x20 就是那条
sb。内核遇到这种意外陷入就把进程杀了。

顺带纠正一个判断标准：这个构建里 "should not reach here"
永远不会打印（被编译器删了），所以"没打印"不能当成功证据。真正的成功信号是
QEMU 直接退出。

回到 CP③：内核拿到 a7 里的号 30 之后，靠什么找到该调哪个函数？去
kernel/syscall.c 看那张表和用它的地方。

### Turn 7

#### User

是通过SYS_rename

#### Claude

SYS_rename 是什么？它是 sysnum.h
里的一个宏，展开就是一个数字（26）。内核运行时手里握着的只有 a7
里那个数字，它不会去看名字——[SYS_rename] sys_rename
这种写法，作用是在源码层面把"号 26"和"函数
sys_rename"摆到一起，编译完剩下的就是一张表。

所以问题没变：内核手里只有一个数字 30，它是凭这个数字怎么找到该调的函数？

看 kernel/syscall.c:210-212 这三行：num 从哪儿来的？拿到之后被拿去做了什么？

### Turn 8

#### User

num从trapframe寄存器里找到a7,然后比较num是不是在0～26已占编号之间，是的话就去
执行对应编号的函数，把返回值存在a0中。不是的话就报错

#### Claude

对，关键就在这：号是当数组下标用的——syscalls[num]() 一步就从号跳到函数指针。

两处小修正，顺便把 CP① 串起来：
- 上界不是"已占编号
26"，而是这张表的长度（NELEM(syscalls)）；表多长，号就能到多大。
- 第一个条件是 num > 0——这正是号 0 被排除的原因（你 CP① 没选
0，现在能说清为什么了）。

现在把它接上：kernel/syscall.c:172 那行 TODO
就是留给你的位置，照上面那些行的写法补一项。左边用宏 [SYS_halt]，别硬编码成
[30]——号以后再改，硬编码这里就跟着错。（顺手 grep -n sys_halt kernel/syscall.c
核对一下 extern 声明在不在，本 lab 已经预填了。）

存盘后 make run 就行（这次改的是内核，不用重打 fs.img）。预期：unknown sys
call 30 消失；后面那个 trap 还会出现——那是 CP④ 的活，先别慌。

### Turn 9

#### User

make run
qemu-system-riscv64: -device
virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0: Failed to get "write" lock
Is another process using the image [fs.img]?
make: *** [Makefile:152：run] 错误 1

#### Claude

fs.img 是 QEMU 的虚拟磁盘。QEMU 打开它时会加一把写锁（防止两个 QEMU
同时写同一个镜像，把文件系统写坏）。报这个错，说明锁已经被别人拿走了——通常是两
种情况之一：

1. 还有一个 QEMU 活着（上次 make run
没正常退出，或者直接关了终端窗口，进程变孤儿还在跑）
ps aux | grep [q]emu-system-riscv64
lsof fs.img            # 没装 lsof 就用 fuser -v fs.img
找到 PID 就 kill <PID>。

2. 镜像还挂在 /mnt 上（make fs 里 mount 之后 umount
没跑到，中断时会留下这种状态）
grep fs.img /proc/mounts      # 有输出就是还挂着
sudo umount /mnt

两样都清掉再 make run。

顺带一个要养成的习惯：QEMU 里正常退出的方式是先按 Ctrl-A，再按 X（不是
Ctrl-C，也不是直接关窗口）。直接关窗口会留下上面第 1
种情况——孤儿进程占着锁，下次就起不来了。

### Turn 10

#### User

-> / $ halt

usertrap(): unexpected scause 0x000000000000000f pid=3 halt
            sepc=0x0000000000000020 stval=0xffffffffffffffff

#### Claude

对上了：unknown sys call 30 那行没了——说明号、桩、分发表三段都通了，halt()
这次真的进了内核。

但后面两行 trap 跟上次一模一样，原因也还是那个：sys_halt()
现在只是个占位，return -1 让 halt() 立刻返回，而 main
后面本来就没代码（noreturn 把 printf 删了），于是又一路掉进
strcpy。现象没变，是因为内核里还没有人真的去关机。

最后一段（CP④）：去 kernel/include/sbi.h
翻一下，里面有没有跟"关机"相关的封装函数？叫什么名字？

### Turn 11

#### User

sbi_shutdown()

#### Claude

对。

动手：kernel/sysproc.c:186 的 sys_halt() 里，把占位的 return -1; 换成对
sbi_shutdown(); 的调用，末尾那个 return 0; 保留——它执行不到，只是为了让 C
函数形式上有个返回值。（sbi.h 已经在 sysproc.c:13 引入过了，不用再加
include。）

存盘后 make run，进 xv6 敲 halt。这次的预期是：QEMU 直接退出，回到宿主机的
bash 提示符——既不打印 "should not reach here"，也不再有那个 trap。
