// 对外 API 用的目录项二进制格式（Linux getdents 约定布局）。
// 内核的 struct dirent（fat32.h）是内部数据模型，写给用户态 buf 时
// 要按本布局打包，再走 copyout 搬过去。
//
// 字段顺序固定，不能乱排：用户态 ls/getdents 解析器是按这个偏移读的。
struct linux_dirent {
  uint   d_ino;      // inode 号（FAT32 没有真 inode，可填占位）
  uint   d_off;      // 到下一条的偏移
  ushort d_reclen;   // 本条记录长度（含 d_name 与对齐）
  char   d_name[];   // 文件名（柔性数组），以 '\0' 结尾
};
