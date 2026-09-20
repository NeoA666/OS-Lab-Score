#include "kernel/include/types.h"
#include "user.h"

// lab8 验收程序：测 CP①②③ 信号量 sem_init/p/v 同步父子进程。
// 骨架状态（占位 return -1）：信号量不工作，子进程不阻塞直接跑。
// 学生完成 CP①②③ 后：子进程 sem_p 阻塞，等父进程 sem_v 后才继续。
int
main(void)
{
  if(sem_init(0, 0) < 0) {       // 信号量 0 初值 0（同步用）
    printf("sem_init failed (CP① not done?)\n");
    exit(1);
  }

  int pid = fork();
  if(pid < 0) { printf("fork failed\n"); exit(1); }
  if(pid == 0) {
    printf("child: about to sem_p (should block until parent sem_v)\n");
    if(sem_p(0) < 0) {
      printf("sem_p failed (CP② not done?)\n");
      exit(1);
    }
    printf("child: got sem, exiting\n");
    exit(0);
  }

  // 父：先让子跑一会儿（子应该阻塞在 sem_p），然后 sem_v 唤醒
  sleep(3);
  printf("parent: calling sem_v to wake child\n");
  if(sem_v(0) < 0) {
    printf("sem_v failed (CP③ not done?)\n");
    exit(1);
  }
  wait(0);
  printf("lab8 test passed\n");
  exit(0);
}
