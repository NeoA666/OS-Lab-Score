#include "kernel/include/types.h"
#include "user.h"

// lab6 验收程序：测 CP① set_max_page_in_mem + CP② get_swap_count。
// 骨架状态（占位 return -1/0）：本测试 set 失败。
// 学生完成 CP①② 后：set 成功，get 返回字段值（骨架 0，CP⑤ 完整 swap 后 >0）。
int
main(void)
{
  int r = set_max_page_in_mem(4);
  if(r < 0) {
    printf("set_max_page_in_mem failed (CP① not done?)\n");
    exit(1);
  }
  printf("set max pages = 4 (CP① OK)\n");

  int swaps = get_swap_count();
  if(swaps < 0) {
    printf("get_swap_count failed (CP② not done?)\n");
    exit(1);
  }
  printf("swap count = %d (骨架 0；CP⑤ 实现真 swap 后 >0)\n", swaps);

  printf("lab6 test passed\n");
  exit(0);
}
