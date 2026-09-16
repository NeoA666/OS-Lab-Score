#include "kernel/include/types.h"
#include "user.h"

// lab3 验收程序：测 CP① brk + CP② mmap + CP③ munmap。
// 学生完成 CP①②③ 后应输出 "lab3 test passed"。
int
main(void)
{
  // CP① brk(0) 返回当前 heap
  uint64 heap = brk(0);
  if ((long)heap < 0) {
    printf("brk(0) failed\n");
    exit(1);
  }
  printf("brk(0) = 0x%lx\n", heap);

  // CP② mmap 匿名映射 4096 字节
  uint64 mapped = mmap((void*)0, 4096, 0, 0, -1, 0);
  if ((long)mapped < 0) {
    printf("mmap failed\n");
    exit(1);
  }
  printf("mmap returned 0x%lx\n", mapped);

  // 读写映射区验证可写可读
  char *p = (char*)mapped;
  p[0] = 'X';
  p[4095] = 'Y';
  if (p[0] != 'X' || p[4095] != 'Y') {
    printf("mmap read/write FAILED\n");
    exit(1);
  }
  printf("mmap read/write OK\n");

  // CP③ munmap 解除
  int r = munmap((void*)mapped, 4096);
  if (r < 0) {
    printf("munmap failed\n");
    exit(1);
  }

  printf("lab3 test passed\n");
  exit(0);
}
