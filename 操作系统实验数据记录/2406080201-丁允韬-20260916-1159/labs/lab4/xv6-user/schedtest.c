#include "kernel/include/types.h"
#include "user.h"

// lab4 验收程序：测 CP① set_timeslice + CP② set_priority + CP③ priority 调度。
// CP① 检查：set_timeslice 返回 0。
// CP②③ 检查：fork 3 个子进程分别设 priority 1/2/3，priority 1 应最先 done。
int
main(void)
{
  // CP① set_timeslice 验证
  if(set_timeslice(10) < 0) {
    printf("set_timeslice FAILED (CP① not done?)\n");
    exit(1);
  }
  printf("set_timeslice OK\n");

  for(int i = 0; i < 3; i++) {
    int pid = fork();
    if(pid < 0) {
      printf("fork failed\n");
      exit(1);
    }
    if(pid == 0) {
      // 子进程 i 设 priority i+1（0号子设1最高，2号子设3最低）
      if(set_priority(i + 1) < 0) {
        printf("set_priority FAILED (CP② not done?)\n");
        exit(99);
      }
      // 干足够久的活，触发多次时钟中断 + 调度
      volatile long long x = 0;
      for(long long j = 0; j < 5000000LL; j++) x += j;
      printf("process priority %d done\n", i + 1);
      exit(i + 1);
    }
  }
  // 父进程等所有子进程
  int status;
  while(wait(&status) > 0) {
    // 等所有子进程退出
  }
  printf("lab4 test done\n");
  printf("观察上方：priority 1 应该最先 done，priority 3 最后\n");
  exit(0);
}
