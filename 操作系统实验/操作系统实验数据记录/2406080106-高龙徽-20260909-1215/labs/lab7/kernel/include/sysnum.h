#ifndef __SYSNUM_H
#define __SYSNUM_H

// System call numbers
#define SYS_fork         1
#define SYS_exit         2
#define SYS_wait         3
#define SYS_pipe         4
#define SYS_read         5
#define SYS_kill         6
#define SYS_exec         7
#define SYS_fstat        8
#define SYS_chdir        9
#define SYS_dup         10
#define SYS_getpid      11
#define SYS_sbrk        12
#define SYS_sleep       13
#define SYS_uptime      14
#define SYS_open        15
#define SYS_write       16
#define SYS_remove      17
#define SYS_trace       18
#define SYS_sysinfo     19
#define SYS_mkdir       20
#define SYS_close       21
#define SYS_test_proc   22
#define SYS_dev         23
#define SYS_readdir     24
#define SYS_getcwd      25
#define SYS_rename      26

// lab7 新增 syscall 号（主线 CP①~③，链路已预填，实现挖空在 kernel/sysproc.c 或 sysfile.c）
#define SYS_dup2        27   // CP① 复制到指定 fd
#define SYS_getdents    28   // CP② 读目录项
#define SYS_unlink      29   // CP③ 删除文件

#endif
#define SYS_halt 30
