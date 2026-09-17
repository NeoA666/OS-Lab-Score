
xv6-user/_ls:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <fmtname>:
#include "kernel/include/stat.h"
#include "xv6-user/user.h"

char*
fmtname(char *name)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	1800                	addi	s0,sp,48
   c:	892a                	mv	s2,a0
  static char buf[STAT_MAX_NAME+1];
  int len = strlen(name);
   e:	00000097          	auipc	ra,0x0
  12:	250080e7          	jalr	592(ra) # 25e <strlen>
  16:	0005049b          	sext.w	s1,a0

  // Return blank-padded name.
  if(len >= STAT_MAX_NAME)
  1a:	47fd                	li	a5,31
  1c:	0097d963          	bge	a5,s1,2e <fmtname+0x2e>
    return name;
  memmove(buf, name, len);
  memset(buf + len, ' ', STAT_MAX_NAME - len);
  buf[STAT_MAX_NAME] = '\0';
  return buf;
}
  20:	854a                	mv	a0,s2
  22:	70a2                	ld	ra,40(sp)
  24:	7402                	ld	s0,32(sp)
  26:	64e2                	ld	s1,24(sp)
  28:	6942                	ld	s2,16(sp)
  2a:	6145                	addi	sp,sp,48
  2c:	8082                	ret
  2e:	e44e                	sd	s3,8(sp)
  memmove(buf, name, len);
  30:	00001997          	auipc	s3,0x1
  34:	aa898993          	addi	s3,s3,-1368 # ad8 <buf.0>
  38:	8626                	mv	a2,s1
  3a:	85ca                	mv	a1,s2
  3c:	854e                	mv	a0,s3
  3e:	00000097          	auipc	ra,0x0
  42:	3aa080e7          	jalr	938(ra) # 3e8 <memmove>
  memset(buf + len, ' ', STAT_MAX_NAME - len);
  46:	02000613          	li	a2,32
  4a:	9e05                	subw	a2,a2,s1
  4c:	02000593          	li	a1,32
  50:	00998533          	add	a0,s3,s1
  54:	00000097          	auipc	ra,0x0
  58:	234080e7          	jalr	564(ra) # 288 <memset>
  buf[STAT_MAX_NAME] = '\0';
  5c:	02098023          	sb	zero,32(s3)
  return buf;
  60:	894e                	mv	s2,s3
  62:	69a2                	ld	s3,8(sp)
  64:	bf75                	j	20 <fmtname+0x20>

0000000000000066 <ls>:

void
ls(char *path)
{
  66:	7119                	addi	sp,sp,-128
  68:	fc86                	sd	ra,120(sp)
  6a:	f8a2                	sd	s0,112(sp)
  6c:	f0ca                	sd	s2,96(sp)
  6e:	0100                	addi	s0,sp,128
  70:	892a                	mv	s2,a0
  int fd;
  struct stat st;
  char *types[] = {
  72:	f8043023          	sd	zero,-128(s0)
  76:	00001797          	auipc	a5,0x1
  7a:	97278793          	addi	a5,a5,-1678 # 9e8 <malloc+0x106>
  7e:	f8f43423          	sd	a5,-120(s0)
  82:	00001797          	auipc	a5,0x1
  86:	97678793          	addi	a5,a5,-1674 # 9f8 <malloc+0x116>
  8a:	f8f43823          	sd	a5,-112(s0)
    [T_DIR]   "DIR ",
    [T_FILE]  "FILE",
  };

  if((fd = open(path, 0)) < 0){
  8e:	4581                	li	a1,0
  90:	00000097          	auipc	ra,0x0
  94:	44a080e7          	jalr	1098(ra) # 4da <open>
  98:	02054863          	bltz	a0,c8 <ls+0x62>
  9c:	f4a6                	sd	s1,104(sp)
  9e:	84aa                	mv	s1,a0
    fprintf(2, "ls: cannot open %s\n", path);
    return;
  }

  if(fstat(fd, &st) < 0){
  a0:	f9840593          	addi	a1,s0,-104
  a4:	00000097          	auipc	ra,0x0
  a8:	43e080e7          	jalr	1086(ra) # 4e2 <fstat>
  ac:	02054963          	bltz	a0,de <ls+0x78>
    fprintf(2, "ls: cannot stat %s\n", path);
    close(fd);
    return;
  }

  if (st.type == T_DIR){
  b0:	fc041703          	lh	a4,-64(s0)
  b4:	4785                	li	a5,1
  b6:	0af71063          	bne	a4,a5,156 <ls+0xf0>
  ba:	ecce                	sd	s3,88(sp)
    while(readdir(fd, &st) == 1){
  bc:	4905                	li	s2,1
      printf("%s %s\t%d\n", fmtname(st.name), types[st.type], st.size);
  be:	00001997          	auipc	s3,0x1
  c2:	97298993          	addi	s3,s3,-1678 # a30 <malloc+0x14e>
  c6:	a09d                	j	12c <ls+0xc6>
    fprintf(2, "ls: cannot open %s\n", path);
  c8:	864a                	mv	a2,s2
  ca:	00001597          	auipc	a1,0x1
  ce:	93658593          	addi	a1,a1,-1738 # a00 <malloc+0x11e>
  d2:	4509                	li	a0,2
  d4:	00000097          	auipc	ra,0x0
  d8:	728080e7          	jalr	1832(ra) # 7fc <fprintf>
    return;
  dc:	a885                	j	14c <ls+0xe6>
    fprintf(2, "ls: cannot stat %s\n", path);
  de:	864a                	mv	a2,s2
  e0:	00001597          	auipc	a1,0x1
  e4:	93858593          	addi	a1,a1,-1736 # a18 <malloc+0x136>
  e8:	4509                	li	a0,2
  ea:	00000097          	auipc	ra,0x0
  ee:	712080e7          	jalr	1810(ra) # 7fc <fprintf>
    close(fd);
  f2:	8526                	mv	a0,s1
  f4:	00000097          	auipc	ra,0x0
  f8:	3ce080e7          	jalr	974(ra) # 4c2 <close>
    return;
  fc:	74a6                	ld	s1,104(sp)
  fe:	a0b9                	j	14c <ls+0xe6>
      printf("%s %s\t%d\n", fmtname(st.name), types[st.type], st.size);
 100:	f9840513          	addi	a0,s0,-104
 104:	00000097          	auipc	ra,0x0
 108:	efc080e7          	jalr	-260(ra) # 0 <fmtname>
 10c:	85aa                	mv	a1,a0
 10e:	fc041783          	lh	a5,-64(s0)
 112:	078e                	slli	a5,a5,0x3
 114:	fd078793          	addi	a5,a5,-48
 118:	97a2                	add	a5,a5,s0
 11a:	fc843683          	ld	a3,-56(s0)
 11e:	fb07b603          	ld	a2,-80(a5)
 122:	854e                	mv	a0,s3
 124:	00000097          	auipc	ra,0x0
 128:	706080e7          	jalr	1798(ra) # 82a <printf>
    while(readdir(fd, &st) == 1){
 12c:	f9840593          	addi	a1,s0,-104
 130:	8526                	mv	a0,s1
 132:	00000097          	auipc	ra,0x0
 136:	400080e7          	jalr	1024(ra) # 532 <readdir>
 13a:	fd2503e3          	beq	a0,s2,100 <ls+0x9a>
 13e:	69e6                	ld	s3,88(sp)
    }
  } else {
    printf("%s %s\t%l\n", fmtname(st.name), types[st.type], st.size);
  }
  close(fd);
 140:	8526                	mv	a0,s1
 142:	00000097          	auipc	ra,0x0
 146:	380080e7          	jalr	896(ra) # 4c2 <close>
 14a:	74a6                	ld	s1,104(sp)
}
 14c:	70e6                	ld	ra,120(sp)
 14e:	7446                	ld	s0,112(sp)
 150:	7906                	ld	s2,96(sp)
 152:	6109                	addi	sp,sp,128
 154:	8082                	ret
    printf("%s %s\t%l\n", fmtname(st.name), types[st.type], st.size);
 156:	f9840513          	addi	a0,s0,-104
 15a:	00000097          	auipc	ra,0x0
 15e:	ea6080e7          	jalr	-346(ra) # 0 <fmtname>
 162:	85aa                	mv	a1,a0
 164:	fc041783          	lh	a5,-64(s0)
 168:	078e                	slli	a5,a5,0x3
 16a:	fd078793          	addi	a5,a5,-48
 16e:	97a2                	add	a5,a5,s0
 170:	fc843683          	ld	a3,-56(s0)
 174:	fb07b603          	ld	a2,-80(a5)
 178:	00001517          	auipc	a0,0x1
 17c:	8c850513          	addi	a0,a0,-1848 # a40 <malloc+0x15e>
 180:	00000097          	auipc	ra,0x0
 184:	6aa080e7          	jalr	1706(ra) # 82a <printf>
 188:	bf65                	j	140 <ls+0xda>

000000000000018a <main>:

int
main(int argc, char *argv[])
{
 18a:	1101                	addi	sp,sp,-32
 18c:	ec06                	sd	ra,24(sp)
 18e:	e822                	sd	s0,16(sp)
 190:	1000                	addi	s0,sp,32
  int i;

  if(argc < 2){
 192:	4785                	li	a5,1
 194:	02a7db63          	bge	a5,a0,1ca <main+0x40>
 198:	e426                	sd	s1,8(sp)
 19a:	e04a                	sd	s2,0(sp)
 19c:	00858493          	addi	s1,a1,8
 1a0:	ffe5091b          	addiw	s2,a0,-2
 1a4:	02091793          	slli	a5,s2,0x20
 1a8:	01d7d913          	srli	s2,a5,0x1d
 1ac:	05c1                	addi	a1,a1,16
 1ae:	992e                	add	s2,s2,a1
    ls(".");
    exit(0);
  }
  for(i=1; i<argc; i++)
    ls(argv[i]);
 1b0:	6088                	ld	a0,0(s1)
 1b2:	00000097          	auipc	ra,0x0
 1b6:	eb4080e7          	jalr	-332(ra) # 66 <ls>
  for(i=1; i<argc; i++)
 1ba:	04a1                	addi	s1,s1,8
 1bc:	ff249ae3          	bne	s1,s2,1b0 <main+0x26>
  exit(0);
 1c0:	4501                	li	a0,0
 1c2:	00000097          	auipc	ra,0x0
 1c6:	2d8080e7          	jalr	728(ra) # 49a <exit>
 1ca:	e426                	sd	s1,8(sp)
 1cc:	e04a                	sd	s2,0(sp)
    ls(".");
 1ce:	00001517          	auipc	a0,0x1
 1d2:	88250513          	addi	a0,a0,-1918 # a50 <malloc+0x16e>
 1d6:	00000097          	auipc	ra,0x0
 1da:	e90080e7          	jalr	-368(ra) # 66 <ls>
    exit(0);
 1de:	4501                	li	a0,0
 1e0:	00000097          	auipc	ra,0x0
 1e4:	2ba080e7          	jalr	698(ra) # 49a <exit>

00000000000001e8 <strcpy>:
#include "kernel/include/fcntl.h"
#include "xv6-user/user.h"

char*
strcpy(char *s, const char *t)
{
 1e8:	1141                	addi	sp,sp,-16
 1ea:	e422                	sd	s0,8(sp)
 1ec:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1ee:	87aa                	mv	a5,a0
 1f0:	0585                	addi	a1,a1,1
 1f2:	0785                	addi	a5,a5,1
 1f4:	fff5c703          	lbu	a4,-1(a1)
 1f8:	fee78fa3          	sb	a4,-1(a5)
 1fc:	fb75                	bnez	a4,1f0 <strcpy+0x8>
    ;
  return os;
}
 1fe:	6422                	ld	s0,8(sp)
 200:	0141                	addi	sp,sp,16
 202:	8082                	ret

0000000000000204 <strcat>:

char*
strcat(char *s, const char *t)
{
 204:	1141                	addi	sp,sp,-16
 206:	e422                	sd	s0,8(sp)
 208:	0800                	addi	s0,sp,16
  char *os = s;
  while(*s)
 20a:	00054783          	lbu	a5,0(a0)
 20e:	c385                	beqz	a5,22e <strcat+0x2a>
 210:	87aa                	mv	a5,a0
    s++;
 212:	0785                	addi	a5,a5,1
  while(*s)
 214:	0007c703          	lbu	a4,0(a5)
 218:	ff6d                	bnez	a4,212 <strcat+0xe>
  while((*s++ = *t++))
 21a:	0585                	addi	a1,a1,1
 21c:	0785                	addi	a5,a5,1
 21e:	fff5c703          	lbu	a4,-1(a1)
 222:	fee78fa3          	sb	a4,-1(a5)
 226:	fb75                	bnez	a4,21a <strcat+0x16>
    ;
  return os;
}
 228:	6422                	ld	s0,8(sp)
 22a:	0141                	addi	sp,sp,16
 22c:	8082                	ret
  while(*s)
 22e:	87aa                	mv	a5,a0
 230:	b7ed                	j	21a <strcat+0x16>

0000000000000232 <strcmp>:


int
strcmp(const char *p, const char *q)
{
 232:	1141                	addi	sp,sp,-16
 234:	e422                	sd	s0,8(sp)
 236:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 238:	00054783          	lbu	a5,0(a0)
 23c:	cb91                	beqz	a5,250 <strcmp+0x1e>
 23e:	0005c703          	lbu	a4,0(a1)
 242:	00f71763          	bne	a4,a5,250 <strcmp+0x1e>
    p++, q++;
 246:	0505                	addi	a0,a0,1
 248:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 24a:	00054783          	lbu	a5,0(a0)
 24e:	fbe5                	bnez	a5,23e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 250:	0005c503          	lbu	a0,0(a1)
}
 254:	40a7853b          	subw	a0,a5,a0
 258:	6422                	ld	s0,8(sp)
 25a:	0141                	addi	sp,sp,16
 25c:	8082                	ret

000000000000025e <strlen>:

uint
strlen(const char *s)
{
 25e:	1141                	addi	sp,sp,-16
 260:	e422                	sd	s0,8(sp)
 262:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 264:	00054783          	lbu	a5,0(a0)
 268:	cf91                	beqz	a5,284 <strlen+0x26>
 26a:	0505                	addi	a0,a0,1
 26c:	87aa                	mv	a5,a0
 26e:	86be                	mv	a3,a5
 270:	0785                	addi	a5,a5,1
 272:	fff7c703          	lbu	a4,-1(a5)
 276:	ff65                	bnez	a4,26e <strlen+0x10>
 278:	40a6853b          	subw	a0,a3,a0
 27c:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 27e:	6422                	ld	s0,8(sp)
 280:	0141                	addi	sp,sp,16
 282:	8082                	ret
  for(n = 0; s[n]; n++)
 284:	4501                	li	a0,0
 286:	bfe5                	j	27e <strlen+0x20>

0000000000000288 <memset>:

void*
memset(void *dst, int c, uint n)
{
 288:	1141                	addi	sp,sp,-16
 28a:	e422                	sd	s0,8(sp)
 28c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 28e:	ca19                	beqz	a2,2a4 <memset+0x1c>
 290:	87aa                	mv	a5,a0
 292:	1602                	slli	a2,a2,0x20
 294:	9201                	srli	a2,a2,0x20
 296:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 29a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 29e:	0785                	addi	a5,a5,1
 2a0:	fee79de3          	bne	a5,a4,29a <memset+0x12>
  }
  return dst;
}
 2a4:	6422                	ld	s0,8(sp)
 2a6:	0141                	addi	sp,sp,16
 2a8:	8082                	ret

00000000000002aa <strchr>:

char*
strchr(const char *s, char c)
{
 2aa:	1141                	addi	sp,sp,-16
 2ac:	e422                	sd	s0,8(sp)
 2ae:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2b0:	00054783          	lbu	a5,0(a0)
 2b4:	cb99                	beqz	a5,2ca <strchr+0x20>
    if(*s == c)
 2b6:	00f58763          	beq	a1,a5,2c4 <strchr+0x1a>
  for(; *s; s++)
 2ba:	0505                	addi	a0,a0,1
 2bc:	00054783          	lbu	a5,0(a0)
 2c0:	fbfd                	bnez	a5,2b6 <strchr+0xc>
      return (char*)s;
  return 0;
 2c2:	4501                	li	a0,0
}
 2c4:	6422                	ld	s0,8(sp)
 2c6:	0141                	addi	sp,sp,16
 2c8:	8082                	ret
  return 0;
 2ca:	4501                	li	a0,0
 2cc:	bfe5                	j	2c4 <strchr+0x1a>

00000000000002ce <gets>:

char*
gets(char *buf, int max)
{
 2ce:	711d                	addi	sp,sp,-96
 2d0:	ec86                	sd	ra,88(sp)
 2d2:	e8a2                	sd	s0,80(sp)
 2d4:	e4a6                	sd	s1,72(sp)
 2d6:	e0ca                	sd	s2,64(sp)
 2d8:	fc4e                	sd	s3,56(sp)
 2da:	f852                	sd	s4,48(sp)
 2dc:	f456                	sd	s5,40(sp)
 2de:	f05a                	sd	s6,32(sp)
 2e0:	ec5e                	sd	s7,24(sp)
 2e2:	1080                	addi	s0,sp,96
 2e4:	8baa                	mv	s7,a0
 2e6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2e8:	892a                	mv	s2,a0
 2ea:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2ec:	4aa9                	li	s5,10
 2ee:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2f0:	89a6                	mv	s3,s1
 2f2:	2485                	addiw	s1,s1,1
 2f4:	0344d863          	bge	s1,s4,324 <gets+0x56>
    cc = read(0, &c, 1);
 2f8:	4605                	li	a2,1
 2fa:	faf40593          	addi	a1,s0,-81
 2fe:	4501                	li	a0,0
 300:	00000097          	auipc	ra,0x0
 304:	1b2080e7          	jalr	434(ra) # 4b2 <read>
    if(cc < 1)
 308:	00a05e63          	blez	a0,324 <gets+0x56>
    buf[i++] = c;
 30c:	faf44783          	lbu	a5,-81(s0)
 310:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 314:	01578763          	beq	a5,s5,322 <gets+0x54>
 318:	0905                	addi	s2,s2,1
 31a:	fd679be3          	bne	a5,s6,2f0 <gets+0x22>
    buf[i++] = c;
 31e:	89a6                	mv	s3,s1
 320:	a011                	j	324 <gets+0x56>
 322:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 324:	99de                	add	s3,s3,s7
 326:	00098023          	sb	zero,0(s3)
  return buf;
}
 32a:	855e                	mv	a0,s7
 32c:	60e6                	ld	ra,88(sp)
 32e:	6446                	ld	s0,80(sp)
 330:	64a6                	ld	s1,72(sp)
 332:	6906                	ld	s2,64(sp)
 334:	79e2                	ld	s3,56(sp)
 336:	7a42                	ld	s4,48(sp)
 338:	7aa2                	ld	s5,40(sp)
 33a:	7b02                	ld	s6,32(sp)
 33c:	6be2                	ld	s7,24(sp)
 33e:	6125                	addi	sp,sp,96
 340:	8082                	ret

0000000000000342 <stat>:

int
stat(const char *n, struct stat *st)
{
 342:	1101                	addi	sp,sp,-32
 344:	ec06                	sd	ra,24(sp)
 346:	e822                	sd	s0,16(sp)
 348:	e04a                	sd	s2,0(sp)
 34a:	1000                	addi	s0,sp,32
 34c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 34e:	4581                	li	a1,0
 350:	00000097          	auipc	ra,0x0
 354:	18a080e7          	jalr	394(ra) # 4da <open>
  if(fd < 0)
 358:	02054663          	bltz	a0,384 <stat+0x42>
 35c:	e426                	sd	s1,8(sp)
 35e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 360:	85ca                	mv	a1,s2
 362:	00000097          	auipc	ra,0x0
 366:	180080e7          	jalr	384(ra) # 4e2 <fstat>
 36a:	892a                	mv	s2,a0
  close(fd);
 36c:	8526                	mv	a0,s1
 36e:	00000097          	auipc	ra,0x0
 372:	154080e7          	jalr	340(ra) # 4c2 <close>
  return r;
 376:	64a2                	ld	s1,8(sp)
}
 378:	854a                	mv	a0,s2
 37a:	60e2                	ld	ra,24(sp)
 37c:	6442                	ld	s0,16(sp)
 37e:	6902                	ld	s2,0(sp)
 380:	6105                	addi	sp,sp,32
 382:	8082                	ret
    return -1;
 384:	597d                	li	s2,-1
 386:	bfcd                	j	378 <stat+0x36>

0000000000000388 <atoi>:

int
atoi(const char *s)
{
 388:	1141                	addi	sp,sp,-16
 38a:	e422                	sd	s0,8(sp)
 38c:	0800                	addi	s0,sp,16
  int n;
  int neg = 1;
  if (*s == '-') {
 38e:	00054703          	lbu	a4,0(a0)
 392:	02d00793          	li	a5,45
  int neg = 1;
 396:	4585                	li	a1,1
  if (*s == '-') {
 398:	04f70363          	beq	a4,a5,3de <atoi+0x56>
    s++;
    neg = -1;
  }
  n = 0;
  while('0' <= *s && *s <= '9')
 39c:	00054703          	lbu	a4,0(a0)
 3a0:	fd07079b          	addiw	a5,a4,-48
 3a4:	0ff7f793          	zext.b	a5,a5
 3a8:	46a5                	li	a3,9
 3aa:	02f6ed63          	bltu	a3,a5,3e4 <atoi+0x5c>
  n = 0;
 3ae:	4681                	li	a3,0
  while('0' <= *s && *s <= '9')
 3b0:	4625                	li	a2,9
    n = n*10 + *s++ - '0';
 3b2:	0505                	addi	a0,a0,1
 3b4:	0026979b          	slliw	a5,a3,0x2
 3b8:	9fb5                	addw	a5,a5,a3
 3ba:	0017979b          	slliw	a5,a5,0x1
 3be:	9fb9                	addw	a5,a5,a4
 3c0:	fd07869b          	addiw	a3,a5,-48
  while('0' <= *s && *s <= '9')
 3c4:	00054703          	lbu	a4,0(a0)
 3c8:	fd07079b          	addiw	a5,a4,-48
 3cc:	0ff7f793          	zext.b	a5,a5
 3d0:	fef671e3          	bgeu	a2,a5,3b2 <atoi+0x2a>
  return n * neg;
}
 3d4:	02d5853b          	mulw	a0,a1,a3
 3d8:	6422                	ld	s0,8(sp)
 3da:	0141                	addi	sp,sp,16
 3dc:	8082                	ret
    s++;
 3de:	0505                	addi	a0,a0,1
    neg = -1;
 3e0:	55fd                	li	a1,-1
 3e2:	bf6d                	j	39c <atoi+0x14>
  n = 0;
 3e4:	4681                	li	a3,0
 3e6:	b7fd                	j	3d4 <atoi+0x4c>

00000000000003e8 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3e8:	1141                	addi	sp,sp,-16
 3ea:	e422                	sd	s0,8(sp)
 3ec:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3ee:	02b57463          	bgeu	a0,a1,416 <memmove+0x2e>
    while(n-- > 0)
 3f2:	00c05f63          	blez	a2,410 <memmove+0x28>
 3f6:	1602                	slli	a2,a2,0x20
 3f8:	9201                	srli	a2,a2,0x20
 3fa:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3fe:	872a                	mv	a4,a0
      *dst++ = *src++;
 400:	0585                	addi	a1,a1,1
 402:	0705                	addi	a4,a4,1
 404:	fff5c683          	lbu	a3,-1(a1)
 408:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 40c:	fef71ae3          	bne	a4,a5,400 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 410:	6422                	ld	s0,8(sp)
 412:	0141                	addi	sp,sp,16
 414:	8082                	ret
    dst += n;
 416:	00c50733          	add	a4,a0,a2
    src += n;
 41a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 41c:	fec05ae3          	blez	a2,410 <memmove+0x28>
 420:	fff6079b          	addiw	a5,a2,-1
 424:	1782                	slli	a5,a5,0x20
 426:	9381                	srli	a5,a5,0x20
 428:	fff7c793          	not	a5,a5
 42c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 42e:	15fd                	addi	a1,a1,-1
 430:	177d                	addi	a4,a4,-1
 432:	0005c683          	lbu	a3,0(a1)
 436:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 43a:	fee79ae3          	bne	a5,a4,42e <memmove+0x46>
 43e:	bfc9                	j	410 <memmove+0x28>

0000000000000440 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 440:	1141                	addi	sp,sp,-16
 442:	e422                	sd	s0,8(sp)
 444:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 446:	ca05                	beqz	a2,476 <memcmp+0x36>
 448:	fff6069b          	addiw	a3,a2,-1
 44c:	1682                	slli	a3,a3,0x20
 44e:	9281                	srli	a3,a3,0x20
 450:	0685                	addi	a3,a3,1
 452:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 454:	00054783          	lbu	a5,0(a0)
 458:	0005c703          	lbu	a4,0(a1)
 45c:	00e79863          	bne	a5,a4,46c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 460:	0505                	addi	a0,a0,1
    p2++;
 462:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 464:	fed518e3          	bne	a0,a3,454 <memcmp+0x14>
  }
  return 0;
 468:	4501                	li	a0,0
 46a:	a019                	j	470 <memcmp+0x30>
      return *p1 - *p2;
 46c:	40e7853b          	subw	a0,a5,a4
}
 470:	6422                	ld	s0,8(sp)
 472:	0141                	addi	sp,sp,16
 474:	8082                	ret
  return 0;
 476:	4501                	li	a0,0
 478:	bfe5                	j	470 <memcmp+0x30>

000000000000047a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 47a:	1141                	addi	sp,sp,-16
 47c:	e406                	sd	ra,8(sp)
 47e:	e022                	sd	s0,0(sp)
 480:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 482:	00000097          	auipc	ra,0x0
 486:	f66080e7          	jalr	-154(ra) # 3e8 <memmove>
}
 48a:	60a2                	ld	ra,8(sp)
 48c:	6402                	ld	s0,0(sp)
 48e:	0141                	addi	sp,sp,16
 490:	8082                	ret

0000000000000492 <fork>:
# generated by usys.pl - do not edit
#include "kernel/include/sysnum.h"
.global fork
fork:
 li a7, SYS_fork
 492:	4885                	li	a7,1
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <exit>:
.global exit
exit:
 li a7, SYS_exit
 49a:	4889                	li	a7,2
 ecall
 49c:	00000073          	ecall
 ret
 4a0:	8082                	ret

00000000000004a2 <wait>:
.global wait
wait:
 li a7, SYS_wait
 4a2:	488d                	li	a7,3
 ecall
 4a4:	00000073          	ecall
 ret
 4a8:	8082                	ret

00000000000004aa <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4aa:	4891                	li	a7,4
 ecall
 4ac:	00000073          	ecall
 ret
 4b0:	8082                	ret

00000000000004b2 <read>:
.global read
read:
 li a7, SYS_read
 4b2:	4895                	li	a7,5
 ecall
 4b4:	00000073          	ecall
 ret
 4b8:	8082                	ret

00000000000004ba <write>:
.global write
write:
 li a7, SYS_write
 4ba:	48c1                	li	a7,16
 ecall
 4bc:	00000073          	ecall
 ret
 4c0:	8082                	ret

00000000000004c2 <close>:
.global close
close:
 li a7, SYS_close
 4c2:	48d5                	li	a7,21
 ecall
 4c4:	00000073          	ecall
 ret
 4c8:	8082                	ret

00000000000004ca <kill>:
.global kill
kill:
 li a7, SYS_kill
 4ca:	4899                	li	a7,6
 ecall
 4cc:	00000073          	ecall
 ret
 4d0:	8082                	ret

00000000000004d2 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4d2:	489d                	li	a7,7
 ecall
 4d4:	00000073          	ecall
 ret
 4d8:	8082                	ret

00000000000004da <open>:
.global open
open:
 li a7, SYS_open
 4da:	48bd                	li	a7,15
 ecall
 4dc:	00000073          	ecall
 ret
 4e0:	8082                	ret

00000000000004e2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4e2:	48a1                	li	a7,8
 ecall
 4e4:	00000073          	ecall
 ret
 4e8:	8082                	ret

00000000000004ea <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4ea:	48d1                	li	a7,20
 ecall
 4ec:	00000073          	ecall
 ret
 4f0:	8082                	ret

00000000000004f2 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4f2:	48a5                	li	a7,9
 ecall
 4f4:	00000073          	ecall
 ret
 4f8:	8082                	ret

00000000000004fa <dup>:
.global dup
dup:
 li a7, SYS_dup
 4fa:	48a9                	li	a7,10
 ecall
 4fc:	00000073          	ecall
 ret
 500:	8082                	ret

0000000000000502 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 502:	48ad                	li	a7,11
 ecall
 504:	00000073          	ecall
 ret
 508:	8082                	ret

000000000000050a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 50a:	48b1                	li	a7,12
 ecall
 50c:	00000073          	ecall
 ret
 510:	8082                	ret

0000000000000512 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 512:	48b5                	li	a7,13
 ecall
 514:	00000073          	ecall
 ret
 518:	8082                	ret

000000000000051a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 51a:	48b9                	li	a7,14
 ecall
 51c:	00000073          	ecall
 ret
 520:	8082                	ret

0000000000000522 <test_proc>:
.global test_proc
test_proc:
 li a7, SYS_test_proc
 522:	48d9                	li	a7,22
 ecall
 524:	00000073          	ecall
 ret
 528:	8082                	ret

000000000000052a <dev>:
.global dev
dev:
 li a7, SYS_dev
 52a:	48dd                	li	a7,23
 ecall
 52c:	00000073          	ecall
 ret
 530:	8082                	ret

0000000000000532 <readdir>:
.global readdir
readdir:
 li a7, SYS_readdir
 532:	48e1                	li	a7,24
 ecall
 534:	00000073          	ecall
 ret
 538:	8082                	ret

000000000000053a <getcwd>:
.global getcwd
getcwd:
 li a7, SYS_getcwd
 53a:	48e5                	li	a7,25
 ecall
 53c:	00000073          	ecall
 ret
 540:	8082                	ret

0000000000000542 <remove>:
.global remove
remove:
 li a7, SYS_remove
 542:	48c5                	li	a7,17
 ecall
 544:	00000073          	ecall
 ret
 548:	8082                	ret

000000000000054a <trace>:
.global trace
trace:
 li a7, SYS_trace
 54a:	48c9                	li	a7,18
 ecall
 54c:	00000073          	ecall
 ret
 550:	8082                	ret

0000000000000552 <sysinfo>:
.global sysinfo
sysinfo:
 li a7, SYS_sysinfo
 552:	48cd                	li	a7,19
 ecall
 554:	00000073          	ecall
 ret
 558:	8082                	ret

000000000000055a <rename>:
.global rename
rename:
 li a7, SYS_rename
 55a:	48e9                	li	a7,26
 ecall
 55c:	00000073          	ecall
 ret
 560:	8082                	ret

0000000000000562 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 562:	1101                	addi	sp,sp,-32
 564:	ec06                	sd	ra,24(sp)
 566:	e822                	sd	s0,16(sp)
 568:	1000                	addi	s0,sp,32
 56a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 56e:	4605                	li	a2,1
 570:	fef40593          	addi	a1,s0,-17
 574:	00000097          	auipc	ra,0x0
 578:	f46080e7          	jalr	-186(ra) # 4ba <write>
}
 57c:	60e2                	ld	ra,24(sp)
 57e:	6442                	ld	s0,16(sp)
 580:	6105                	addi	sp,sp,32
 582:	8082                	ret

0000000000000584 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 584:	7139                	addi	sp,sp,-64
 586:	fc06                	sd	ra,56(sp)
 588:	f822                	sd	s0,48(sp)
 58a:	f426                	sd	s1,40(sp)
 58c:	0080                	addi	s0,sp,64
 58e:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 590:	c299                	beqz	a3,596 <printint+0x12>
 592:	0805cb63          	bltz	a1,628 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 596:	2581                	sext.w	a1,a1
  neg = 0;
 598:	4881                	li	a7,0
 59a:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 59e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5a0:	2601                	sext.w	a2,a2
 5a2:	00000517          	auipc	a0,0x0
 5a6:	51650513          	addi	a0,a0,1302 # ab8 <digits>
 5aa:	883a                	mv	a6,a4
 5ac:	2705                	addiw	a4,a4,1
 5ae:	02c5f7bb          	remuw	a5,a1,a2
 5b2:	1782                	slli	a5,a5,0x20
 5b4:	9381                	srli	a5,a5,0x20
 5b6:	97aa                	add	a5,a5,a0
 5b8:	0007c783          	lbu	a5,0(a5)
 5bc:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5c0:	0005879b          	sext.w	a5,a1
 5c4:	02c5d5bb          	divuw	a1,a1,a2
 5c8:	0685                	addi	a3,a3,1
 5ca:	fec7f0e3          	bgeu	a5,a2,5aa <printint+0x26>
  if(neg)
 5ce:	00088c63          	beqz	a7,5e6 <printint+0x62>
    buf[i++] = '-';
 5d2:	fd070793          	addi	a5,a4,-48
 5d6:	00878733          	add	a4,a5,s0
 5da:	02d00793          	li	a5,45
 5de:	fef70823          	sb	a5,-16(a4)
 5e2:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5e6:	02e05c63          	blez	a4,61e <printint+0x9a>
 5ea:	f04a                	sd	s2,32(sp)
 5ec:	ec4e                	sd	s3,24(sp)
 5ee:	fc040793          	addi	a5,s0,-64
 5f2:	00e78933          	add	s2,a5,a4
 5f6:	fff78993          	addi	s3,a5,-1
 5fa:	99ba                	add	s3,s3,a4
 5fc:	377d                	addiw	a4,a4,-1
 5fe:	1702                	slli	a4,a4,0x20
 600:	9301                	srli	a4,a4,0x20
 602:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 606:	fff94583          	lbu	a1,-1(s2)
 60a:	8526                	mv	a0,s1
 60c:	00000097          	auipc	ra,0x0
 610:	f56080e7          	jalr	-170(ra) # 562 <putc>
  while(--i >= 0)
 614:	197d                	addi	s2,s2,-1
 616:	ff3918e3          	bne	s2,s3,606 <printint+0x82>
 61a:	7902                	ld	s2,32(sp)
 61c:	69e2                	ld	s3,24(sp)
}
 61e:	70e2                	ld	ra,56(sp)
 620:	7442                	ld	s0,48(sp)
 622:	74a2                	ld	s1,40(sp)
 624:	6121                	addi	sp,sp,64
 626:	8082                	ret
    x = -xx;
 628:	40b005bb          	negw	a1,a1
    neg = 1;
 62c:	4885                	li	a7,1
    x = -xx;
 62e:	b7b5                	j	59a <printint+0x16>

0000000000000630 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 630:	715d                	addi	sp,sp,-80
 632:	e486                	sd	ra,72(sp)
 634:	e0a2                	sd	s0,64(sp)
 636:	f84a                	sd	s2,48(sp)
 638:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 63a:	0005c903          	lbu	s2,0(a1)
 63e:	1a090a63          	beqz	s2,7f2 <vprintf+0x1c2>
 642:	fc26                	sd	s1,56(sp)
 644:	f44e                	sd	s3,40(sp)
 646:	f052                	sd	s4,32(sp)
 648:	ec56                	sd	s5,24(sp)
 64a:	e85a                	sd	s6,16(sp)
 64c:	e45e                	sd	s7,8(sp)
 64e:	8aaa                	mv	s5,a0
 650:	8bb2                	mv	s7,a2
 652:	00158493          	addi	s1,a1,1
  state = 0;
 656:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 658:	02500a13          	li	s4,37
 65c:	4b55                	li	s6,21
 65e:	a839                	j	67c <vprintf+0x4c>
        putc(fd, c);
 660:	85ca                	mv	a1,s2
 662:	8556                	mv	a0,s5
 664:	00000097          	auipc	ra,0x0
 668:	efe080e7          	jalr	-258(ra) # 562 <putc>
 66c:	a019                	j	672 <vprintf+0x42>
    } else if(state == '%'){
 66e:	01498d63          	beq	s3,s4,688 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 672:	0485                	addi	s1,s1,1
 674:	fff4c903          	lbu	s2,-1(s1)
 678:	16090763          	beqz	s2,7e6 <vprintf+0x1b6>
    if(state == 0){
 67c:	fe0999e3          	bnez	s3,66e <vprintf+0x3e>
      if(c == '%'){
 680:	ff4910e3          	bne	s2,s4,660 <vprintf+0x30>
        state = '%';
 684:	89d2                	mv	s3,s4
 686:	b7f5                	j	672 <vprintf+0x42>
      if(c == 'd'){
 688:	13490463          	beq	s2,s4,7b0 <vprintf+0x180>
 68c:	f9d9079b          	addiw	a5,s2,-99
 690:	0ff7f793          	zext.b	a5,a5
 694:	12fb6763          	bltu	s6,a5,7c2 <vprintf+0x192>
 698:	f9d9079b          	addiw	a5,s2,-99
 69c:	0ff7f713          	zext.b	a4,a5
 6a0:	12eb6163          	bltu	s6,a4,7c2 <vprintf+0x192>
 6a4:	00271793          	slli	a5,a4,0x2
 6a8:	00000717          	auipc	a4,0x0
 6ac:	3b870713          	addi	a4,a4,952 # a60 <malloc+0x17e>
 6b0:	97ba                	add	a5,a5,a4
 6b2:	439c                	lw	a5,0(a5)
 6b4:	97ba                	add	a5,a5,a4
 6b6:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 6b8:	008b8913          	addi	s2,s7,8
 6bc:	4685                	li	a3,1
 6be:	4629                	li	a2,10
 6c0:	000ba583          	lw	a1,0(s7)
 6c4:	8556                	mv	a0,s5
 6c6:	00000097          	auipc	ra,0x0
 6ca:	ebe080e7          	jalr	-322(ra) # 584 <printint>
 6ce:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 6d0:	4981                	li	s3,0
 6d2:	b745                	j	672 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6d4:	008b8913          	addi	s2,s7,8
 6d8:	4681                	li	a3,0
 6da:	4629                	li	a2,10
 6dc:	000ba583          	lw	a1,0(s7)
 6e0:	8556                	mv	a0,s5
 6e2:	00000097          	auipc	ra,0x0
 6e6:	ea2080e7          	jalr	-350(ra) # 584 <printint>
 6ea:	8bca                	mv	s7,s2
      state = 0;
 6ec:	4981                	li	s3,0
 6ee:	b751                	j	672 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 6f0:	008b8913          	addi	s2,s7,8
 6f4:	4681                	li	a3,0
 6f6:	4641                	li	a2,16
 6f8:	000ba583          	lw	a1,0(s7)
 6fc:	8556                	mv	a0,s5
 6fe:	00000097          	auipc	ra,0x0
 702:	e86080e7          	jalr	-378(ra) # 584 <printint>
 706:	8bca                	mv	s7,s2
      state = 0;
 708:	4981                	li	s3,0
 70a:	b7a5                	j	672 <vprintf+0x42>
 70c:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 70e:	008b8c13          	addi	s8,s7,8
 712:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 716:	03000593          	li	a1,48
 71a:	8556                	mv	a0,s5
 71c:	00000097          	auipc	ra,0x0
 720:	e46080e7          	jalr	-442(ra) # 562 <putc>
  putc(fd, 'x');
 724:	07800593          	li	a1,120
 728:	8556                	mv	a0,s5
 72a:	00000097          	auipc	ra,0x0
 72e:	e38080e7          	jalr	-456(ra) # 562 <putc>
 732:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 734:	00000b97          	auipc	s7,0x0
 738:	384b8b93          	addi	s7,s7,900 # ab8 <digits>
 73c:	03c9d793          	srli	a5,s3,0x3c
 740:	97de                	add	a5,a5,s7
 742:	0007c583          	lbu	a1,0(a5)
 746:	8556                	mv	a0,s5
 748:	00000097          	auipc	ra,0x0
 74c:	e1a080e7          	jalr	-486(ra) # 562 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 750:	0992                	slli	s3,s3,0x4
 752:	397d                	addiw	s2,s2,-1
 754:	fe0914e3          	bnez	s2,73c <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 758:	8be2                	mv	s7,s8
      state = 0;
 75a:	4981                	li	s3,0
 75c:	6c02                	ld	s8,0(sp)
 75e:	bf11                	j	672 <vprintf+0x42>
        s = va_arg(ap, char*);
 760:	008b8993          	addi	s3,s7,8
 764:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 768:	02090163          	beqz	s2,78a <vprintf+0x15a>
        while(*s != 0){
 76c:	00094583          	lbu	a1,0(s2)
 770:	c9a5                	beqz	a1,7e0 <vprintf+0x1b0>
          putc(fd, *s);
 772:	8556                	mv	a0,s5
 774:	00000097          	auipc	ra,0x0
 778:	dee080e7          	jalr	-530(ra) # 562 <putc>
          s++;
 77c:	0905                	addi	s2,s2,1
        while(*s != 0){
 77e:	00094583          	lbu	a1,0(s2)
 782:	f9e5                	bnez	a1,772 <vprintf+0x142>
        s = va_arg(ap, char*);
 784:	8bce                	mv	s7,s3
      state = 0;
 786:	4981                	li	s3,0
 788:	b5ed                	j	672 <vprintf+0x42>
          s = "(null)";
 78a:	00000917          	auipc	s2,0x0
 78e:	2ce90913          	addi	s2,s2,718 # a58 <malloc+0x176>
        while(*s != 0){
 792:	02800593          	li	a1,40
 796:	bff1                	j	772 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 798:	008b8913          	addi	s2,s7,8
 79c:	000bc583          	lbu	a1,0(s7)
 7a0:	8556                	mv	a0,s5
 7a2:	00000097          	auipc	ra,0x0
 7a6:	dc0080e7          	jalr	-576(ra) # 562 <putc>
 7aa:	8bca                	mv	s7,s2
      state = 0;
 7ac:	4981                	li	s3,0
 7ae:	b5d1                	j	672 <vprintf+0x42>
        putc(fd, c);
 7b0:	02500593          	li	a1,37
 7b4:	8556                	mv	a0,s5
 7b6:	00000097          	auipc	ra,0x0
 7ba:	dac080e7          	jalr	-596(ra) # 562 <putc>
      state = 0;
 7be:	4981                	li	s3,0
 7c0:	bd4d                	j	672 <vprintf+0x42>
        putc(fd, '%');
 7c2:	02500593          	li	a1,37
 7c6:	8556                	mv	a0,s5
 7c8:	00000097          	auipc	ra,0x0
 7cc:	d9a080e7          	jalr	-614(ra) # 562 <putc>
        putc(fd, c);
 7d0:	85ca                	mv	a1,s2
 7d2:	8556                	mv	a0,s5
 7d4:	00000097          	auipc	ra,0x0
 7d8:	d8e080e7          	jalr	-626(ra) # 562 <putc>
      state = 0;
 7dc:	4981                	li	s3,0
 7de:	bd51                	j	672 <vprintf+0x42>
        s = va_arg(ap, char*);
 7e0:	8bce                	mv	s7,s3
      state = 0;
 7e2:	4981                	li	s3,0
 7e4:	b579                	j	672 <vprintf+0x42>
 7e6:	74e2                	ld	s1,56(sp)
 7e8:	79a2                	ld	s3,40(sp)
 7ea:	7a02                	ld	s4,32(sp)
 7ec:	6ae2                	ld	s5,24(sp)
 7ee:	6b42                	ld	s6,16(sp)
 7f0:	6ba2                	ld	s7,8(sp)
    }
  }
}
 7f2:	60a6                	ld	ra,72(sp)
 7f4:	6406                	ld	s0,64(sp)
 7f6:	7942                	ld	s2,48(sp)
 7f8:	6161                	addi	sp,sp,80
 7fa:	8082                	ret

00000000000007fc <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7fc:	715d                	addi	sp,sp,-80
 7fe:	ec06                	sd	ra,24(sp)
 800:	e822                	sd	s0,16(sp)
 802:	1000                	addi	s0,sp,32
 804:	e010                	sd	a2,0(s0)
 806:	e414                	sd	a3,8(s0)
 808:	e818                	sd	a4,16(s0)
 80a:	ec1c                	sd	a5,24(s0)
 80c:	03043023          	sd	a6,32(s0)
 810:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 814:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 818:	8622                	mv	a2,s0
 81a:	00000097          	auipc	ra,0x0
 81e:	e16080e7          	jalr	-490(ra) # 630 <vprintf>
}
 822:	60e2                	ld	ra,24(sp)
 824:	6442                	ld	s0,16(sp)
 826:	6161                	addi	sp,sp,80
 828:	8082                	ret

000000000000082a <printf>:

void
printf(const char *fmt, ...)
{
 82a:	711d                	addi	sp,sp,-96
 82c:	ec06                	sd	ra,24(sp)
 82e:	e822                	sd	s0,16(sp)
 830:	1000                	addi	s0,sp,32
 832:	e40c                	sd	a1,8(s0)
 834:	e810                	sd	a2,16(s0)
 836:	ec14                	sd	a3,24(s0)
 838:	f018                	sd	a4,32(s0)
 83a:	f41c                	sd	a5,40(s0)
 83c:	03043823          	sd	a6,48(s0)
 840:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 844:	00840613          	addi	a2,s0,8
 848:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 84c:	85aa                	mv	a1,a0
 84e:	4505                	li	a0,1
 850:	00000097          	auipc	ra,0x0
 854:	de0080e7          	jalr	-544(ra) # 630 <vprintf>
}
 858:	60e2                	ld	ra,24(sp)
 85a:	6442                	ld	s0,16(sp)
 85c:	6125                	addi	sp,sp,96
 85e:	8082                	ret

0000000000000860 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 860:	1141                	addi	sp,sp,-16
 862:	e422                	sd	s0,8(sp)
 864:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 866:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 86a:	00000797          	auipc	a5,0x0
 86e:	2667b783          	ld	a5,614(a5) # ad0 <freep>
 872:	a02d                	j	89c <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 874:	4618                	lw	a4,8(a2)
 876:	9f2d                	addw	a4,a4,a1
 878:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 87c:	6398                	ld	a4,0(a5)
 87e:	6310                	ld	a2,0(a4)
 880:	a83d                	j	8be <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 882:	ff852703          	lw	a4,-8(a0)
 886:	9f31                	addw	a4,a4,a2
 888:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 88a:	ff053683          	ld	a3,-16(a0)
 88e:	a091                	j	8d2 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 890:	6398                	ld	a4,0(a5)
 892:	00e7e463          	bltu	a5,a4,89a <free+0x3a>
 896:	00e6ea63          	bltu	a3,a4,8aa <free+0x4a>
{
 89a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 89c:	fed7fae3          	bgeu	a5,a3,890 <free+0x30>
 8a0:	6398                	ld	a4,0(a5)
 8a2:	00e6e463          	bltu	a3,a4,8aa <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8a6:	fee7eae3          	bltu	a5,a4,89a <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 8aa:	ff852583          	lw	a1,-8(a0)
 8ae:	6390                	ld	a2,0(a5)
 8b0:	02059813          	slli	a6,a1,0x20
 8b4:	01c85713          	srli	a4,a6,0x1c
 8b8:	9736                	add	a4,a4,a3
 8ba:	fae60de3          	beq	a2,a4,874 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8be:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8c2:	4790                	lw	a2,8(a5)
 8c4:	02061593          	slli	a1,a2,0x20
 8c8:	01c5d713          	srli	a4,a1,0x1c
 8cc:	973e                	add	a4,a4,a5
 8ce:	fae68ae3          	beq	a3,a4,882 <free+0x22>
    p->s.ptr = bp->s.ptr;
 8d2:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8d4:	00000717          	auipc	a4,0x0
 8d8:	1ef73e23          	sd	a5,508(a4) # ad0 <freep>
}
 8dc:	6422                	ld	s0,8(sp)
 8de:	0141                	addi	sp,sp,16
 8e0:	8082                	ret

00000000000008e2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8e2:	7139                	addi	sp,sp,-64
 8e4:	fc06                	sd	ra,56(sp)
 8e6:	f822                	sd	s0,48(sp)
 8e8:	f426                	sd	s1,40(sp)
 8ea:	ec4e                	sd	s3,24(sp)
 8ec:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8ee:	02051493          	slli	s1,a0,0x20
 8f2:	9081                	srli	s1,s1,0x20
 8f4:	04bd                	addi	s1,s1,15
 8f6:	8091                	srli	s1,s1,0x4
 8f8:	0014899b          	addiw	s3,s1,1
 8fc:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8fe:	00000517          	auipc	a0,0x0
 902:	1d253503          	ld	a0,466(a0) # ad0 <freep>
 906:	c915                	beqz	a0,93a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 908:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 90a:	4798                	lw	a4,8(a5)
 90c:	08977e63          	bgeu	a4,s1,9a8 <malloc+0xc6>
 910:	f04a                	sd	s2,32(sp)
 912:	e852                	sd	s4,16(sp)
 914:	e456                	sd	s5,8(sp)
 916:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 918:	8a4e                	mv	s4,s3
 91a:	0009871b          	sext.w	a4,s3
 91e:	6685                	lui	a3,0x1
 920:	00d77363          	bgeu	a4,a3,926 <malloc+0x44>
 924:	6a05                	lui	s4,0x1
 926:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 92a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 92e:	00000917          	auipc	s2,0x0
 932:	1a290913          	addi	s2,s2,418 # ad0 <freep>
  if(p == (char*)-1)
 936:	5afd                	li	s5,-1
 938:	a091                	j	97c <malloc+0x9a>
 93a:	f04a                	sd	s2,32(sp)
 93c:	e852                	sd	s4,16(sp)
 93e:	e456                	sd	s5,8(sp)
 940:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 942:	00000797          	auipc	a5,0x0
 946:	1be78793          	addi	a5,a5,446 # b00 <base>
 94a:	00000717          	auipc	a4,0x0
 94e:	18f73323          	sd	a5,390(a4) # ad0 <freep>
 952:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 954:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 958:	b7c1                	j	918 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 95a:	6398                	ld	a4,0(a5)
 95c:	e118                	sd	a4,0(a0)
 95e:	a08d                	j	9c0 <malloc+0xde>
  hp->s.size = nu;
 960:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 964:	0541                	addi	a0,a0,16
 966:	00000097          	auipc	ra,0x0
 96a:	efa080e7          	jalr	-262(ra) # 860 <free>
  return freep;
 96e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 972:	c13d                	beqz	a0,9d8 <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 974:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 976:	4798                	lw	a4,8(a5)
 978:	02977463          	bgeu	a4,s1,9a0 <malloc+0xbe>
    if(p == freep)
 97c:	00093703          	ld	a4,0(s2)
 980:	853e                	mv	a0,a5
 982:	fef719e3          	bne	a4,a5,974 <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 986:	8552                	mv	a0,s4
 988:	00000097          	auipc	ra,0x0
 98c:	b82080e7          	jalr	-1150(ra) # 50a <sbrk>
  if(p == (char*)-1)
 990:	fd5518e3          	bne	a0,s5,960 <malloc+0x7e>
        return 0;
 994:	4501                	li	a0,0
 996:	7902                	ld	s2,32(sp)
 998:	6a42                	ld	s4,16(sp)
 99a:	6aa2                	ld	s5,8(sp)
 99c:	6b02                	ld	s6,0(sp)
 99e:	a03d                	j	9cc <malloc+0xea>
 9a0:	7902                	ld	s2,32(sp)
 9a2:	6a42                	ld	s4,16(sp)
 9a4:	6aa2                	ld	s5,8(sp)
 9a6:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 9a8:	fae489e3          	beq	s1,a4,95a <malloc+0x78>
        p->s.size -= nunits;
 9ac:	4137073b          	subw	a4,a4,s3
 9b0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9b2:	02071693          	slli	a3,a4,0x20
 9b6:	01c6d713          	srli	a4,a3,0x1c
 9ba:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9bc:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9c0:	00000717          	auipc	a4,0x0
 9c4:	10a73823          	sd	a0,272(a4) # ad0 <freep>
      return (void*)(p + 1);
 9c8:	01078513          	addi	a0,a5,16
  }
}
 9cc:	70e2                	ld	ra,56(sp)
 9ce:	7442                	ld	s0,48(sp)
 9d0:	74a2                	ld	s1,40(sp)
 9d2:	69e2                	ld	s3,24(sp)
 9d4:	6121                	addi	sp,sp,64
 9d6:	8082                	ret
 9d8:	7902                	ld	s2,32(sp)
 9da:	6a42                	ld	s4,16(sp)
 9dc:	6aa2                	ld	s5,8(sp)
 9de:	6b02                	ld	s6,0(sp)
 9e0:	b7f5                	j	9cc <malloc+0xea>
