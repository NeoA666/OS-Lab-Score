# Claude Code QA (Clean)

- 学号：2406080114
- 姓名：王世佳
- 数据采集时间：2026-09-17 17:52
- 原始时间标识：20260917-1752
- 原始数据目录：2406080114-王世佳-20260917-1752
- 终端录像数量：2

- 实验分类：lab1

- Claude 会话总数：1
- 对话轮次总数：43
- 有效用户问题数：43
- 有效 Claude 回复数：43

## Session 1：20260917T163003-5987

- 对话轮次：43
- 开始时间：未知

### Turn 1

#### User

make build

#### Claude

make build 跑到最后一步失败了。报错在链接用户程序时：

riscv64-unknown-elf-ld ... -o xv6-user/_halt ...
xv6-user/halt.o: in function `main':
xv6-user/halt.c:10:(.text+0x8): undefined reference to `halt'
make: *** [Makefile:167：xv6-user/_halt] 错误 1

人话版：xv6-user/halt.c:10 这一行调用了 halt()，链接器要把所有 .o 拼成可执行文件时，去找"halt 这个函数到底在哪"，找不到，于是停下。

先不动代码，问你一个问题：

用户程序想请内核替它办一件事（比如关机），它靠什么把"我要办哪一件事"这个信息告诉内核？

（提示不用急着看代码，先想：用户程序和内核是两段完全独立的机器码，它们之间能传的只有寄存器里的值。）

### Turn 2

#### User

通过用户程序的参数

#### Claude

方向对了一半：确实是靠"给内核捎一个值"过去，而不是靠函数名——两条独立的机器码之间传不了名字。

但这里还差一步：内核收到这个值之后，总得拿它去干点什么，才能知道该执行哪件事。

追问：内核手里有一堆"能办的事"，它拿到你传的这个值，最可能拿它去干什么？（想想它怎么从这个值，找到对应的那一件事）

### Turn 3

#### User

通过调用函数

#### Claude

"调用函数"没说错——内核最后确实要调一个函数。缺的是中间那一步：它凭什么知道该调哪一个？

给你一个具体方向：内核不是靠"一层层判断"挑出该调谁的，而是靠"查"。

去看 kernel/syscall.c:121，那里有一个数组。看看它长什么样、每一项装的是什么。

然后回答我：内核是凭你传的那个值，怎么一步步找到"该调的那个函数"的？

### Turn 4

#### User

通过对应sysnames数组的值找到对应的操作

#### Claude

你翻到的是 sysnames[]——那是另一个数组，和 121 行那个是并排放着的两个。长得像，装的东西不一样。

这两个数组的存在本身很说明问题：内核为什么要分开放两个？

回去对着看：sysnames[] 每一格装的是什么？syscalls[] 每一格装的是什么？内核在分发的时候，是从哪一边"取"出东西来用的？

### Turn 5

#### User

在syscalls中取出东西

#### Claude

对了，分发用的是 syscalls[]。

再往前一步：内核是从 syscalls[] 里"取"东西——那么它凭什么取？你传给内核的那个值，在这个数组面前扮演的是什么角色？

### Turn 6

#### User

查找数组位置

#### Claude

对——你传的那个值，就是"从数组里数第几格"，也就是下标。

把你的思路串一遍：用户程序传一个值 → 内核拿它当 syscalls[] 的下标 → 取出那一格里装的东西 → 调用它。这就是 ecall 之后内核走的路径。

现在可以动 sysnum.h 了，但先回答我：

SYS_halt 该填什么号？为什么？

### Turn 7

#### User

什么意思

#### Claude

是我刚才问得太绕了，换个具体的说法。

打开 kernel/include/sysnum.h，最下面一行是这样的：

#define SYS_halt   0   // ← 占位。学生：思考后改成未占用号

往上看，SYS_fork 1、SYS_exit 2、……、SYS_rename 26——每一个系统调用在这里都有一行：一个名字 + 一个编号。

SYS_halt 是你这次要新增的那个，它后面的 0 只是个占位符，不是答案。你要做的事情就是：把那个 0 换成一个你选的数字。

选几呢？不用猜。你先凭第一反应说一个数出来，我们把它代进 syscall() 里走一遍，看能不能通。

### Turn 8

#### User

27

#### Claude

Update(kernel/include/sysnum.h)

### Turn 9

#### User

make build

#### Claude

报错和刚才一模一样。

这说明改号只解决了一件事——"用哪个号"，没解决另一件事——halt 这个函数的代码到底在哪。

注意 xv6-user/user.h:36 里已经有这么一行：

void halt(void) __attribute__((noreturn));

这是声明：只是跟编译器打个招呼"有这么个函数"。它没有函数体，链接器要的是定义（真正的机器码）。

那么问题来了：halt 的函数体该由谁提供？里面要写什么，才能真的让内核去关机？

### Turn 10

#### User

函数体由我提供，里面应该是可以由内核调用的，识别用户的操作，进行关机

#### Claude

"函数体得有人提供"——这半句对。

但"由内核调用"这句反了。先把调用方向捋直：

xv6-user/halt.c:10 那一行 halt()，是用户程序在请求内核办事，还是内核在指挥用户程序？谁先动？

### Turn 11

#### User

用户

#### Claude

对，用户先动。

接着这个问：用户程序在用户态跑着，它没有权限直接去碰硬件做关机。所以 halt 的函数体里，得放一个什么样的动作，才能把控制权交出去、让内核接手？

### Turn 12

#### User

转交权限

#### Claude

方向对了——就是要把控制权"交出去"。

在 RISC-V 上，这个动作有一条专门的指令，而且本 lab 的代码里到处都在用它。

去看 xv6-user/usys.pl 开头的那个 entry() 子程序：它给每一个 syscall 生成的桩函数，里面放了哪几条指令？其中哪一条是真正"交控制权"的那个动作？

### Turn 13

#### User

ecall

#### Claude

对，ecall——environment call，环"境"调用，专门用来"从用户态掉进内核态"。

但 ecall 本身只说了"我要陷入内核"这一件事。它没说你要办哪件事。内核拿到这个陷入，怎么知道你是想关机、还是想读文件？

看 entry() 里 ecall 的上一句——桩函数在陷入之前还干了一件事。它在干什么？

### Turn 14

#### User

读取相关指令

#### Claude

换个更具体的问法。看 xv6-user/usys.pl:13：

print " li a7, SYS_${name}\n";

ecall 上面紧挨着的就是这一句。桩函数在陷入内核之前，先把什么东西放进了哪个地方？

（提示：这个东西你前面已经见过两次了。）

### Turn 15

#### User

把对应的SYSname放入以上操作

#### Claude

"放什么"答对了——就是那个 syscall 号（SYS_halt 展开后就是 27）。

还差"放进哪儿"。li a7, SYS_${name} 里面的 a7——它是个什么东西？是内存里的某个变量吗？还是别的？

### Turn 16

#### User

我不知道

#### Claude

没关系，这个补上就通了。

a7 是 CPU 内部的一个寄存器的名字，不是内存里的变量，也不是 C 里的数组元素。

可以把寄存器想成 CPU 里的一小排"格子"——CPU 干活时伸手就能摸到，比去内存拿快得多。RISC-V 里有 32 个这样的通用寄存器，a7 是其中一个的固定名字。li a7,
27 这句话的意思就是：把 27 装进 a7 这个格子里。

为什么号要走寄存器？因为用户态和内核态是两段隔离的代码，它们之间没办法直接"递内存里的东西"，只能靠这几个格子递这种很小的值。而 ecall
这个"交控制权"的动作，不会清空这些格子——所以陷入内核之后，内核还能从同一个格子里把号读回来。

事实上内核那边就是这么读的：kernel/syscall.c:210 就一行。

你现在去看一眼那一行：内核是从哪里把号拿回来的？

### Turn 17

#### User

sysname

#### Claude

不是——sysnames 是你前面认错的那个数组，别绕回去。

这次请你真的把 kernel/syscall.c:210 这一行读出来，就一行。等号右边是什么？

### Turn 18

#### User

syscalls[num]();

#### Claude

那是 212 行——syscalls[num]()，正是我们前面说的"拿号当下标、取出函数、调用它"。地方找对了，只是行号差了两行。

210 行在它上面两行处，只有一句赋值：等号左边是 num。

这一行等号右边是什么？

### Turn 19

#### User

p->trapframe->a7;

#### Claude

对，p->trapframe->a7——内核就是从这个格子里把号读回来的。

那么 CP② 第一个问题的答案，你已经自己攒齐了：

1. usys.pl:13 生成的桩函数，把号装进 a7
2. usys.pl:14 的 ecall 交出控制权
3. kernel/syscall.c:210 内核从 a7 把号读回来
4. kernel/syscall.c:212 拿这个号当下标取出函数并调用

一句话：桩函数的职责就是"把号装进约定的寄存器 + ecall"，它自己什么都不干。

下一个问题：ecall 执行的那一瞬间，CPU 跳到了内核的哪里？xv6 里有一个函数专门负责接住从用户态掉下来的陷阱——去 kernel/trap.c 里找找，它叫什么？

### Turn 20

#### User

usertrap

#### Claude

对，usertrap()——kernel/trap.c:51。

它在内核里，专门接住所有从用户态掉下来的陷阱。但"陷阱"不止一种：用户调 syscall 是一种，用户访问了非法地址也是一种。usertrap()
得先分清是哪一种，再决定怎么处理。

它判断完之后，会调用哪一个函数，才把控制权交到真正干活的地方？——这个函数你前面已经看过两眼了。

### Turn 21

#### User

usertrapret

#### Claude

usertrapret 里的 ret 是 return——那是办完事、回用户态的那一步，在最后。

我问的是它前面那一步：usertrap() 判断出"这是用户在要 syscall"之后，真正去"办这件事"的那个调用。

你前面在 kernel/syscall.c 里看过它两眼，那个函数叫什么名字？

### Turn 22

#### User

sysname

#### Claude

不是 sysname。这个名字确实容易混——kernel/syscall.c 里并排放着三个名字很像的东西：

    名字                          是什么
 syscalls[]  数组，每格装一个函数指针（"能办的事"）
 sysnames[]  数组，每格装一个字符串（名字，只用来打印 trace）
 syscall()   函数，就是那个分发员

我要的是第三个。

看 kernel/trap.c:78，那里只有一行——它调用了哪个函数？

### Turn 23

#### User

syscall

#### Claude

对了。

CP② 这条链现在全了：

用户态 halt()  →  li a7, 27  →  ecall
      ↓
usertrap()      kernel/trap.c:51   接住陷阱，分清是哪一类
      ↓
syscall()       kernel/trap.c:78   分发
      ↓
syscalls[27]()  kernel/syscall.c:212
      ↓
usertrapret()   kernel/trap.c:104  回用户态

现在可以动笔了。xv6-user/usys.pl 最后一行还挂着个 TODO：

# entry("halt");  // TODO: 学生自行添加此行（CP②）

把它改成真正的一行 entry("halt");（跟上面那串写法一致），然后重新 make build，看这次过不过。

### Turn 24

#### User

make build

#### Claude

报错其实是能读懂的，我们一句句读：

Unrecognized character \xEF; marked by <-- HERE after ry("halt")<-- HERE near column 14 at xv6-user/usys.pl line 44

- xv6-user/usys.pl line 44 —— 出错的位置
- after ry("halt") —— 就在 entry("halt") 后面那一个字符上
- \xEF —— Perl 说："这是个非 ASCII 字符，我不认识"

原因：你第 44 行末尾敲的那个"分号"，是中文输入法打出来的全角分号 ；。它看着像分号，其实是 3 个字节（EF BC 9B）；而 Perl 要的是英文半角 ;，1
个字节（3B）。长得像，压根不是同一个字符。

这是写代码最常踩的坑之一：中文标点和英文标点不能互换。以后看到 Unrecognized character、stray \357、expected ';' 这类报错，先回头看标点。

把第 44 行末尾那个全角分号换成英文半角 ;，再 make build。

顺带说一句，你的改动位置本身是对的——加在 entry("rename"); 后面，和上面那串写法一致，这点没问题。

### Turn 25

#### User

make build

#### Claude

Update(profile.md)

### Turn 26

#### User

内核无法完成关机这一步骤

#### Claude

对，但"无法完成"太笼统了。内核不会默默什么都不做——syscall() 里那个 if 不满足的时候，后面跟着一个 else 分支，里面写了具体的动作。

去看 kernel/syscall.c:211 那个 if 和它后面的 else：号不合法时，内核会具体做什么？

### Turn 27

#### User

unknown sys call

#### Claude

对——会打印 unknown sys call 27，把 a0 设成 -1，然后 halt() 返回。控制权回到 halt.c，接着执行下一行 printf("should not reach here")。

但这里有个反常的地方，值得你停一下：

27 明明是个没被占用的合法号，为什么内核还说它 "unknown"？

去数一数 syscalls[] 数组现在一共有几个格子。你传进去的 27，在格子的范围之内吗？

### Turn 28

#### User

26

#### Claude

接近了——准确说是最大下标 26，所以数组一共 27 格：0 号那一格空着，1~26 各装一个函数，下标只能取 0~26。

那么问题来了：syscalls[27] —— 取得出来吗？

如果取不出来，那要让 27 号真的生效，光在 sysnum.h 里定个号够不够？你还得往数组里补什么？

### Turn 29

#### User

在数组中添加SYS-halt

#### Claude

对，方向对了。

数组里每一格其实是两个东西拼起来的。拿已有的项看：

[SYS_rename]      sys_rename,

- [ ] 里的，是下标
- 后面跟的那个，是值

那你要是给 halt 加一格，[ ] 里写什么？后面写什么？

### Turn 30

#### User

SYS_halt   sys_halt

#### Claude

对了：[SYS_halt] 是下标（号），sys_halt 是值（内核里真正干活的那个函数）。

现在动笔。kernel/syscall.c 里挂着一行 TODO：

// [SYS_halt]        sys_halt,  // TODO: 学生自行添加此行（CP③）

把它变成真的一行（和上面 [SYS_rename] sys_rename, 写法一致）。

改完先别急着编译——先猜一次：这次 make build 会过，还是不过？如果不过，是哪个阶段报的错？为什么？

### Turn 31

#### User

make build

#### Claude

你加的那一行在 kernel/syscall.c:148，位置和写法都对：

[SYS_rename]      sys_rename,
[SYS_halt]        sys_halt,

make build exit=0，过了。

为什么这次能过？因为链接器要找的 sys_halt 这个函数已经存在——kernel/sysproc.c:186 里有一个，只不过函数体现在是占位的：

uint64
sys_halt(void)
{
  // todo（CP④）：通过 SBI 提供的关机封装结束系统
  return -1;  // 占位——学生实现后替换为实际关机逻辑
}

所以链路现在是通的，只是最后一环空着：

halt() → ecall → usertrap() → syscall() → syscalls[27] → sys_halt() → return -1

走到 sys_halt() 就原路返回了，什么也没关。

这就剩最后一个问题：用户程序为什么不能直接去关机，非得绕这一道 syscall？

### Turn 32

#### User

用户程序的指令是虚拟的

#### Claude

不是"虚拟"的问题——用户程序的指令本身是真的，它算出来的地址也是真的。它缺的不是真实度，是权限。

反过来想一个更根本的问题：

如果一个用户程序想关机就能自己关机、想读磁盘就能自己读磁盘、想改另一个进程的内存就能直接改——那还要"内核"这个东西干什么？

### Turn 33

#### User

为了保护其他用户程序

#### Claude

对——保护。而保护不能靠"大家自觉"，得靠硬件的特权级强制：用户程序跑在最低那一级，像"关机"这种动作，CPU 直接拒绝执行。

但这里有个更绕的点，值得你想一下：

那内核自己呢？内核就能直接关机吗？

去看 kernel/include/sbi.h，里面有一个现成的关机封装函数。内核调它的时候，实际上是在求谁帮忙？

### Turn 34

#### User

那个是关机封装函数

#### Claude

对，kernel/include/sbi.h 里那个就是关机的封装——你找对地方了。

现在最后一笔，kernel/include/sbi.h 里那个函数的名字你是能看到的。打开 kernel/sysproc.c:186 的 sys_halt()：

uint64
sys_halt(void)
{
  // todo（CP④）：通过 SBI 提供的关机封装结束系统
  return -1;  // 占位——学生实现后替换为实际关机逻辑
}

把这一行占位换成"调用那个关机封装函数"。

去 sbi.h 里把函数名抄准，写进 sys_halt() 里，然后告诉我你调的是哪个函数。

### Turn 35

#### User

我问的是哪个是关机封装函数

#### Claude

是我理解偏了，抱歉。

这个我不直接说，教你自己找——这个技能后面每个 lab 都用得上。

kernel/include/sbi.h 很短，直接打开扫一遍就行。如果一眼看不出哪个是关机的，用最笨也最有用的办法：

在文件里搜关键词 shutdown。

它会命中两处。看看这两处分别是什么东西——一个是宏定义（#define 开头），一个是函数。

我要的是那个函数。把它的名字念给我。

### Turn 36

#### User

SBI_CALL_0(SBI_SHUTDOWN);

#### Claude

那是函数里面的那一行。我问的是函数的名字——名字写在花括号 { 的上面一行。

你搜到的那一处（kernel/include/sbi.h:58），往上看一行，那一行长什么样？

### Turn 37

#### User

static inline void sbi_shutdown(void)

#### Claude

对——函数名是 sbi_shutdown。

static inline 是修饰（意思是"这个函数就放在头文件里，调用时就地展开"），void 是它的返回值类型（什么都不返回）。调用时只写函数名加括号就行，跟调
printf 一样。

现在动笔：kernel/sysproc.c:186 的 sys_halt() 里，把那行占位的 return -1; 换成对它的调用。

写完 make build。

（先留个心眼：这个调用执行完之后会发生什么，等你写完了我们再聊。）

### Turn 38

#### User

make build

#### Claude

Auto mode lets Claude handle permission prompts automatically — Claude checks each tool call for risky actions and prompt injection before
executing. Actions Claude identifies as safe are executed, while actions Claude identifies as risky are blocked and Claude may try a
different approach. Ideal for long-running tasks. Sessions are slightly more expensive. Claude can make mistakes that allow harmful
commands to run, it's recommended to only use in isolated environments. Shift+Tab to change mode.

### Turn 39

#### User

mo

#### Claude

没看懂这两个字，是不是手滑了？

你可以直接回答那个问题：sbi_shutdown() 执行完之后，控制流还会回到下一行吗？

### Turn 40

#### User

no

#### Claude

对——关机请求一执行，机器就停了，控制流回不来。

但编译器不知道这件事。它看到的只是一个普普通通的 void 函数调用，按 C 的语法规矩：非 void 的函数，末尾必须有一句 return，不管它实际走不走得到。这是
C 的规矩，不是逻辑的规矩——所以那句 return 是写给编译器看的，不是写给机器看的。

现在把这个函数补完整，两处：

1. sbi_shutdown() 后面补上 ;
2. 函数末尾的 } 之前，补一句 return，交回一个值

写完 make build。

### Turn 41

#### User

make build

#### Claude

Update(profile.md)

### Turn 42

#### User

mak… +11 lines (ctrl+o to expand)

#### Claude

磁盘满了——这是真正的原因。

/dev/sda2   20G   19G   70M  100% /

只剩 70M。而 make fs 要造一个 256MB 的 fs.img，写不下，所以 dd 报 No space left on device；mkfs.fat
又接着在一个残缺文件上跑了一遍，报错就滚成一串。

（第二行 sudo: A terminal is required to authenticate 是另一件事——make fs 里的 sudo mount 需要你输密码，我这边没有终端，这一步必须你来跑。）

我已经把那个残缺的 fs.img（72M）删了——它是在这次失败里刚新建的，删掉才能腾地方。

腾空间的目标，我扫了一圈：

           目录            大小       是什么              删掉的后果
 ~/.npm/_cacache           617M  npm 的下载缓存     下次装包重新下载，安全
 ~/.config/Code            240M  VS Code 配置+数据  ⚠  含你的设置，别删
 /var/cache                158M  系统包缓存         要 sudo
 ~/.cache/vscode-cpptools  44M   VS Code 插件缓存   会重建，安全
 ~/.cache/tracker3         39M   文件索引缓存       会重建，安全

建议先清 npm 缓存——617M，放一个 256M 的 fs.img 还富余一倍：

rm -rf ~/.npm/_cacache

要我帮你执行吗？（这一步动的是你个人的缓存目录，所以先问你一声。）

### Turn 43

#### User

yes

#### Claude

清完了：

/dev/sda2   20G   18G  686M   97% /

686M 空闲，放 256M 的 fs.img 富余一倍多。

现在轮到你了——make fs 里的 sudo mount 要密码，得在你自己的终端里跑：

make fs

（也可以在对话里直接敲 ! make fs，让它在这个会话里执行。）

成功的话会因为 sudo umount 收尾，没有报错就是成功。跑完告诉我结果，然后再进下一步 make run。
