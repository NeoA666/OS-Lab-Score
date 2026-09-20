#include "kernel/include/types.h"
#include "user.h"

// lab5 验收程序：测 CP① sys_sbrk lazy + CP② page fault lazy 分支。
// 骨架状态（原版 sbrk 立即分配）：本测试也通过，但不体现 lazy。
// 学生完成 CP①② 后：sbrk 不立即分配，访问触发 page fault → CP② lazy 分配。
// 两状态下本测试都 passed，但机制不同——区分要看 getpgcnt（CP⑤ 支线）。
int
main(void)
{
  char *mem = sbrk(4096);
  if((long)mem < 0) {
    printf("sbrk failed\n");
    exit(1);
  }
  printf("sbrk returned 0x%lx\n", (uint64)mem);

  // 写访问：CP①② 完成后这里触发 page fault → lazy 分配
  mem[0] = 'X';
  mem[4095] = 'Y';
  if(mem[0] == 'X' && mem[4095] == 'Y') {
    printf("lazy alloc read/write OK\n");
    printf("lab5 test passed\n");
  } else {
    printf("lab5 test FAILED\n");
    exit(1);
  }
  exit(0);
}
