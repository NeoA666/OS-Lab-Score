#include "kernel/include/types.h"
#include "user.h"

// lab7 验收程序：测 CP① dup2 + CP② getdents + CP③ unlink。
int
main(void)
{
  int failed = 0;

  // CP① dup2：复制 STDOUT(1) 到 fd 5
  int newfd = dup2(1, 5);
  if(newfd != 5) {
    printf("dup2 FAILED (got %d, expect 5)\n", newfd);
    failed = 1;
  } else {
    printf("dup2 OK\n");
  }

  // CP② getdents：打开根目录读目录项
  int dirfd = open("/", 0);
  if(dirfd < 0) {
    printf("getdents FAILED: cannot open /\n");
    failed = 1;
  } else {
    char buf[512];
    int n = getdents(dirfd, buf, sizeof(buf));
    if(n <= 0) {
      printf("getdents FAILED (got %d, expect >0)\n", n);
      failed = 1;
    } else {
      printf("getdents OK (read %d bytes of entries)\n", n);
    }
    close(dirfd);
  }

  // CP③ unlink：创建文件再删除，再 open 确认已删
  int fd = open("testfile_l7", 0x202);  // O_CREATE(0x200) | O_RDWR(0x002)
  if(fd >= 0) {
    write(fd, "x", 1);
    close(fd);
  }
  if(unlink("testfile_l7") < 0) {
    printf("unlink FAILED\n");
    failed = 1;
  } else {
    int check = open("testfile_l7", 0);
    if(check >= 0) {
      printf("unlink FAILED: file still exists after unlink\n");
      close(check);
      failed = 1;
    } else {
      printf("unlink OK\n");
    }
  }

  if(!failed) {
    write(5, "lab7 test passed\n", 17);
  } else {
    printf("lab7 test FAILED\n");
    exit(1);
  }
  exit(0);
}
