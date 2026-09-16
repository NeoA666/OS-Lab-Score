
xv6-user/_mkdir:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/include/stat.h"
#include "xv6-user/user.h"

int
main(int argc, char *argv[])
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	addi	s0,sp,32
  int i;

  if(argc < 2){
   8:	4785                	li	a5,1
   a:	02a7d963          	bge	a5,a0,3c <main+0x3c>
   e:	e426                	sd	s1,8(sp)
  10:	e04a                	sd	s2,0(sp)
  12:	00858493          	addi	s1,a1,8
  16:	ffe5091b          	addiw	s2,a0,-2
  1a:	02091793          	slli	a5,s2,0x20
  1e:	01d7d913          	srli	s2,a5,0x1d
  22:	05c1                	addi	a1,a1,16
  24:	992e                	add	s2,s2,a1
    fprintf(2, "Usage: mkdir files...\n");
    exit(1);
  }

  for(i = 1; i < argc; i++){
    if(mkdir(argv[i]) < 0){
  26:	6088                	ld	a0,0(s1)
  28:	00000097          	auipc	ra,0x0
  2c:	354080e7          	jalr	852(ra) # 37c <mkdir>
  30:	02054663          	bltz	a0,5c <main+0x5c>
  for(i = 1; i < argc; i++){
  34:	04a1                	addi	s1,s1,8
  36:	ff2498e3          	bne	s1,s2,26 <main+0x26>
  3a:	a81d                	j	70 <main+0x70>
  3c:	e426                	sd	s1,8(sp)
  3e:	e04a                	sd	s2,0(sp)
    fprintf(2, "Usage: mkdir files...\n");
  40:	00001597          	auipc	a1,0x1
  44:	83858593          	addi	a1,a1,-1992 # 878 <malloc+0x104>
  48:	4509                	li	a0,2
  4a:	00000097          	auipc	ra,0x0
  4e:	644080e7          	jalr	1604(ra) # 68e <fprintf>
    exit(1);
  52:	4505                	li	a0,1
  54:	00000097          	auipc	ra,0x0
  58:	2d8080e7          	jalr	728(ra) # 32c <exit>
      fprintf(2, "mkdir: %s failed to create\n", argv[i]);
  5c:	6090                	ld	a2,0(s1)
  5e:	00001597          	auipc	a1,0x1
  62:	83258593          	addi	a1,a1,-1998 # 890 <malloc+0x11c>
  66:	4509                	li	a0,2
  68:	00000097          	auipc	ra,0x0
  6c:	626080e7          	jalr	1574(ra) # 68e <fprintf>
      break;
    }
  }

  exit(0);
  70:	4501                	li	a0,0
  72:	00000097          	auipc	ra,0x0
  76:	2ba080e7          	jalr	698(ra) # 32c <exit>

000000000000007a <strcpy>:
#include "kernel/include/fcntl.h"
#include "xv6-user/user.h"

char*
strcpy(char *s, const char *t)
{
  7a:	1141                	addi	sp,sp,-16
  7c:	e422                	sd	s0,8(sp)
  7e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  80:	87aa                	mv	a5,a0
  82:	0585                	addi	a1,a1,1
  84:	0785                	addi	a5,a5,1
  86:	fff5c703          	lbu	a4,-1(a1)
  8a:	fee78fa3          	sb	a4,-1(a5)
  8e:	fb75                	bnez	a4,82 <strcpy+0x8>
    ;
  return os;
}
  90:	6422                	ld	s0,8(sp)
  92:	0141                	addi	sp,sp,16
  94:	8082                	ret

0000000000000096 <strcat>:

char*
strcat(char *s, const char *t)
{
  96:	1141                	addi	sp,sp,-16
  98:	e422                	sd	s0,8(sp)
  9a:	0800                	addi	s0,sp,16
  char *os = s;
  while(*s)
  9c:	00054783          	lbu	a5,0(a0)
  a0:	c385                	beqz	a5,c0 <strcat+0x2a>
  a2:	87aa                	mv	a5,a0
    s++;
  a4:	0785                	addi	a5,a5,1
  while(*s)
  a6:	0007c703          	lbu	a4,0(a5)
  aa:	ff6d                	bnez	a4,a4 <strcat+0xe>
  while((*s++ = *t++))
  ac:	0585                	addi	a1,a1,1
  ae:	0785                	addi	a5,a5,1
  b0:	fff5c703          	lbu	a4,-1(a1)
  b4:	fee78fa3          	sb	a4,-1(a5)
  b8:	fb75                	bnez	a4,ac <strcat+0x16>
    ;
  return os;
}
  ba:	6422                	ld	s0,8(sp)
  bc:	0141                	addi	sp,sp,16
  be:	8082                	ret
  while(*s)
  c0:	87aa                	mv	a5,a0
  c2:	b7ed                	j	ac <strcat+0x16>

00000000000000c4 <strcmp>:


int
strcmp(const char *p, const char *q)
{
  c4:	1141                	addi	sp,sp,-16
  c6:	e422                	sd	s0,8(sp)
  c8:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  ca:	00054783          	lbu	a5,0(a0)
  ce:	cb91                	beqz	a5,e2 <strcmp+0x1e>
  d0:	0005c703          	lbu	a4,0(a1)
  d4:	00f71763          	bne	a4,a5,e2 <strcmp+0x1e>
    p++, q++;
  d8:	0505                	addi	a0,a0,1
  da:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  dc:	00054783          	lbu	a5,0(a0)
  e0:	fbe5                	bnez	a5,d0 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  e2:	0005c503          	lbu	a0,0(a1)
}
  e6:	40a7853b          	subw	a0,a5,a0
  ea:	6422                	ld	s0,8(sp)
  ec:	0141                	addi	sp,sp,16
  ee:	8082                	ret

00000000000000f0 <strlen>:

uint
strlen(const char *s)
{
  f0:	1141                	addi	sp,sp,-16
  f2:	e422                	sd	s0,8(sp)
  f4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  f6:	00054783          	lbu	a5,0(a0)
  fa:	cf91                	beqz	a5,116 <strlen+0x26>
  fc:	0505                	addi	a0,a0,1
  fe:	87aa                	mv	a5,a0
 100:	86be                	mv	a3,a5
 102:	0785                	addi	a5,a5,1
 104:	fff7c703          	lbu	a4,-1(a5)
 108:	ff65                	bnez	a4,100 <strlen+0x10>
 10a:	40a6853b          	subw	a0,a3,a0
 10e:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 110:	6422                	ld	s0,8(sp)
 112:	0141                	addi	sp,sp,16
 114:	8082                	ret
  for(n = 0; s[n]; n++)
 116:	4501                	li	a0,0
 118:	bfe5                	j	110 <strlen+0x20>

000000000000011a <memset>:

void*
memset(void *dst, int c, uint n)
{
 11a:	1141                	addi	sp,sp,-16
 11c:	e422                	sd	s0,8(sp)
 11e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 120:	ca19                	beqz	a2,136 <memset+0x1c>
 122:	87aa                	mv	a5,a0
 124:	1602                	slli	a2,a2,0x20
 126:	9201                	srli	a2,a2,0x20
 128:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 12c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 130:	0785                	addi	a5,a5,1
 132:	fee79de3          	bne	a5,a4,12c <memset+0x12>
  }
  return dst;
}
 136:	6422                	ld	s0,8(sp)
 138:	0141                	addi	sp,sp,16
 13a:	8082                	ret

000000000000013c <strchr>:

char*
strchr(const char *s, char c)
{
 13c:	1141                	addi	sp,sp,-16
 13e:	e422                	sd	s0,8(sp)
 140:	0800                	addi	s0,sp,16
  for(; *s; s++)
 142:	00054783          	lbu	a5,0(a0)
 146:	cb99                	beqz	a5,15c <strchr+0x20>
    if(*s == c)
 148:	00f58763          	beq	a1,a5,156 <strchr+0x1a>
  for(; *s; s++)
 14c:	0505                	addi	a0,a0,1
 14e:	00054783          	lbu	a5,0(a0)
 152:	fbfd                	bnez	a5,148 <strchr+0xc>
      return (char*)s;
  return 0;
 154:	4501                	li	a0,0
}
 156:	6422                	ld	s0,8(sp)
 158:	0141                	addi	sp,sp,16
 15a:	8082                	ret
  return 0;
 15c:	4501                	li	a0,0
 15e:	bfe5                	j	156 <strchr+0x1a>

0000000000000160 <gets>:

char*
gets(char *buf, int max)
{
 160:	711d                	addi	sp,sp,-96
 162:	ec86                	sd	ra,88(sp)
 164:	e8a2                	sd	s0,80(sp)
 166:	e4a6                	sd	s1,72(sp)
 168:	e0ca                	sd	s2,64(sp)
 16a:	fc4e                	sd	s3,56(sp)
 16c:	f852                	sd	s4,48(sp)
 16e:	f456                	sd	s5,40(sp)
 170:	f05a                	sd	s6,32(sp)
 172:	ec5e                	sd	s7,24(sp)
 174:	1080                	addi	s0,sp,96
 176:	8baa                	mv	s7,a0
 178:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 17a:	892a                	mv	s2,a0
 17c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 17e:	4aa9                	li	s5,10
 180:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 182:	89a6                	mv	s3,s1
 184:	2485                	addiw	s1,s1,1
 186:	0344d863          	bge	s1,s4,1b6 <gets+0x56>
    cc = read(0, &c, 1);
 18a:	4605                	li	a2,1
 18c:	faf40593          	addi	a1,s0,-81
 190:	4501                	li	a0,0
 192:	00000097          	auipc	ra,0x0
 196:	1b2080e7          	jalr	434(ra) # 344 <read>
    if(cc < 1)
 19a:	00a05e63          	blez	a0,1b6 <gets+0x56>
    buf[i++] = c;
 19e:	faf44783          	lbu	a5,-81(s0)
 1a2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1a6:	01578763          	beq	a5,s5,1b4 <gets+0x54>
 1aa:	0905                	addi	s2,s2,1
 1ac:	fd679be3          	bne	a5,s6,182 <gets+0x22>
    buf[i++] = c;
 1b0:	89a6                	mv	s3,s1
 1b2:	a011                	j	1b6 <gets+0x56>
 1b4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1b6:	99de                	add	s3,s3,s7
 1b8:	00098023          	sb	zero,0(s3)
  return buf;
}
 1bc:	855e                	mv	a0,s7
 1be:	60e6                	ld	ra,88(sp)
 1c0:	6446                	ld	s0,80(sp)
 1c2:	64a6                	ld	s1,72(sp)
 1c4:	6906                	ld	s2,64(sp)
 1c6:	79e2                	ld	s3,56(sp)
 1c8:	7a42                	ld	s4,48(sp)
 1ca:	7aa2                	ld	s5,40(sp)
 1cc:	7b02                	ld	s6,32(sp)
 1ce:	6be2                	ld	s7,24(sp)
 1d0:	6125                	addi	sp,sp,96
 1d2:	8082                	ret

00000000000001d4 <stat>:

int
stat(const char *n, struct stat *st)
{
 1d4:	1101                	addi	sp,sp,-32
 1d6:	ec06                	sd	ra,24(sp)
 1d8:	e822                	sd	s0,16(sp)
 1da:	e04a                	sd	s2,0(sp)
 1dc:	1000                	addi	s0,sp,32
 1de:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1e0:	4581                	li	a1,0
 1e2:	00000097          	auipc	ra,0x0
 1e6:	18a080e7          	jalr	394(ra) # 36c <open>
  if(fd < 0)
 1ea:	02054663          	bltz	a0,216 <stat+0x42>
 1ee:	e426                	sd	s1,8(sp)
 1f0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1f2:	85ca                	mv	a1,s2
 1f4:	00000097          	auipc	ra,0x0
 1f8:	180080e7          	jalr	384(ra) # 374 <fstat>
 1fc:	892a                	mv	s2,a0
  close(fd);
 1fe:	8526                	mv	a0,s1
 200:	00000097          	auipc	ra,0x0
 204:	154080e7          	jalr	340(ra) # 354 <close>
  return r;
 208:	64a2                	ld	s1,8(sp)
}
 20a:	854a                	mv	a0,s2
 20c:	60e2                	ld	ra,24(sp)
 20e:	6442                	ld	s0,16(sp)
 210:	6902                	ld	s2,0(sp)
 212:	6105                	addi	sp,sp,32
 214:	8082                	ret
    return -1;
 216:	597d                	li	s2,-1
 218:	bfcd                	j	20a <stat+0x36>

000000000000021a <atoi>:

int
atoi(const char *s)
{
 21a:	1141                	addi	sp,sp,-16
 21c:	e422                	sd	s0,8(sp)
 21e:	0800                	addi	s0,sp,16
  int n;
  int neg = 1;
  if (*s == '-') {
 220:	00054703          	lbu	a4,0(a0)
 224:	02d00793          	li	a5,45
  int neg = 1;
 228:	4585                	li	a1,1
  if (*s == '-') {
 22a:	04f70363          	beq	a4,a5,270 <atoi+0x56>
    s++;
    neg = -1;
  }
  n = 0;
  while('0' <= *s && *s <= '9')
 22e:	00054703          	lbu	a4,0(a0)
 232:	fd07079b          	addiw	a5,a4,-48
 236:	0ff7f793          	zext.b	a5,a5
 23a:	46a5                	li	a3,9
 23c:	02f6ed63          	bltu	a3,a5,276 <atoi+0x5c>
  n = 0;
 240:	4681                	li	a3,0
  while('0' <= *s && *s <= '9')
 242:	4625                	li	a2,9
    n = n*10 + *s++ - '0';
 244:	0505                	addi	a0,a0,1
 246:	0026979b          	slliw	a5,a3,0x2
 24a:	9fb5                	addw	a5,a5,a3
 24c:	0017979b          	slliw	a5,a5,0x1
 250:	9fb9                	addw	a5,a5,a4
 252:	fd07869b          	addiw	a3,a5,-48
  while('0' <= *s && *s <= '9')
 256:	00054703          	lbu	a4,0(a0)
 25a:	fd07079b          	addiw	a5,a4,-48
 25e:	0ff7f793          	zext.b	a5,a5
 262:	fef671e3          	bgeu	a2,a5,244 <atoi+0x2a>
  return n * neg;
}
 266:	02d5853b          	mulw	a0,a1,a3
 26a:	6422                	ld	s0,8(sp)
 26c:	0141                	addi	sp,sp,16
 26e:	8082                	ret
    s++;
 270:	0505                	addi	a0,a0,1
    neg = -1;
 272:	55fd                	li	a1,-1
 274:	bf6d                	j	22e <atoi+0x14>
  n = 0;
 276:	4681                	li	a3,0
 278:	b7fd                	j	266 <atoi+0x4c>

000000000000027a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 27a:	1141                	addi	sp,sp,-16
 27c:	e422                	sd	s0,8(sp)
 27e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 280:	02b57463          	bgeu	a0,a1,2a8 <memmove+0x2e>
    while(n-- > 0)
 284:	00c05f63          	blez	a2,2a2 <memmove+0x28>
 288:	1602                	slli	a2,a2,0x20
 28a:	9201                	srli	a2,a2,0x20
 28c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 290:	872a                	mv	a4,a0
      *dst++ = *src++;
 292:	0585                	addi	a1,a1,1
 294:	0705                	addi	a4,a4,1
 296:	fff5c683          	lbu	a3,-1(a1)
 29a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 29e:	fef71ae3          	bne	a4,a5,292 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2a2:	6422                	ld	s0,8(sp)
 2a4:	0141                	addi	sp,sp,16
 2a6:	8082                	ret
    dst += n;
 2a8:	00c50733          	add	a4,a0,a2
    src += n;
 2ac:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2ae:	fec05ae3          	blez	a2,2a2 <memmove+0x28>
 2b2:	fff6079b          	addiw	a5,a2,-1
 2b6:	1782                	slli	a5,a5,0x20
 2b8:	9381                	srli	a5,a5,0x20
 2ba:	fff7c793          	not	a5,a5
 2be:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2c0:	15fd                	addi	a1,a1,-1
 2c2:	177d                	addi	a4,a4,-1
 2c4:	0005c683          	lbu	a3,0(a1)
 2c8:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2cc:	fee79ae3          	bne	a5,a4,2c0 <memmove+0x46>
 2d0:	bfc9                	j	2a2 <memmove+0x28>

00000000000002d2 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2d2:	1141                	addi	sp,sp,-16
 2d4:	e422                	sd	s0,8(sp)
 2d6:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2d8:	ca05                	beqz	a2,308 <memcmp+0x36>
 2da:	fff6069b          	addiw	a3,a2,-1
 2de:	1682                	slli	a3,a3,0x20
 2e0:	9281                	srli	a3,a3,0x20
 2e2:	0685                	addi	a3,a3,1
 2e4:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2e6:	00054783          	lbu	a5,0(a0)
 2ea:	0005c703          	lbu	a4,0(a1)
 2ee:	00e79863          	bne	a5,a4,2fe <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2f2:	0505                	addi	a0,a0,1
    p2++;
 2f4:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2f6:	fed518e3          	bne	a0,a3,2e6 <memcmp+0x14>
  }
  return 0;
 2fa:	4501                	li	a0,0
 2fc:	a019                	j	302 <memcmp+0x30>
      return *p1 - *p2;
 2fe:	40e7853b          	subw	a0,a5,a4
}
 302:	6422                	ld	s0,8(sp)
 304:	0141                	addi	sp,sp,16
 306:	8082                	ret
  return 0;
 308:	4501                	li	a0,0
 30a:	bfe5                	j	302 <memcmp+0x30>

000000000000030c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 30c:	1141                	addi	sp,sp,-16
 30e:	e406                	sd	ra,8(sp)
 310:	e022                	sd	s0,0(sp)
 312:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 314:	00000097          	auipc	ra,0x0
 318:	f66080e7          	jalr	-154(ra) # 27a <memmove>
}
 31c:	60a2                	ld	ra,8(sp)
 31e:	6402                	ld	s0,0(sp)
 320:	0141                	addi	sp,sp,16
 322:	8082                	ret

0000000000000324 <fork>:
# generated by usys.pl - do not edit
#include "kernel/include/sysnum.h"
.global fork
fork:
 li a7, SYS_fork
 324:	4885                	li	a7,1
 ecall
 326:	00000073          	ecall
 ret
 32a:	8082                	ret

000000000000032c <exit>:
.global exit
exit:
 li a7, SYS_exit
 32c:	4889                	li	a7,2
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <wait>:
.global wait
wait:
 li a7, SYS_wait
 334:	488d                	li	a7,3
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 33c:	4891                	li	a7,4
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <read>:
.global read
read:
 li a7, SYS_read
 344:	4895                	li	a7,5
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <write>:
.global write
write:
 li a7, SYS_write
 34c:	48c1                	li	a7,16
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <close>:
.global close
close:
 li a7, SYS_close
 354:	48d5                	li	a7,21
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <kill>:
.global kill
kill:
 li a7, SYS_kill
 35c:	4899                	li	a7,6
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <exec>:
.global exec
exec:
 li a7, SYS_exec
 364:	489d                	li	a7,7
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <open>:
.global open
open:
 li a7, SYS_open
 36c:	48bd                	li	a7,15
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 374:	48a1                	li	a7,8
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 37c:	48d1                	li	a7,20
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 384:	48a5                	li	a7,9
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <dup>:
.global dup
dup:
 li a7, SYS_dup
 38c:	48a9                	li	a7,10
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 394:	48ad                	li	a7,11
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 39c:	48b1                	li	a7,12
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3a4:	48b5                	li	a7,13
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3ac:	48b9                	li	a7,14
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <test_proc>:
.global test_proc
test_proc:
 li a7, SYS_test_proc
 3b4:	48d9                	li	a7,22
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <dev>:
.global dev
dev:
 li a7, SYS_dev
 3bc:	48dd                	li	a7,23
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <readdir>:
.global readdir
readdir:
 li a7, SYS_readdir
 3c4:	48e1                	li	a7,24
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <getcwd>:
.global getcwd
getcwd:
 li a7, SYS_getcwd
 3cc:	48e5                	li	a7,25
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <remove>:
.global remove
remove:
 li a7, SYS_remove
 3d4:	48c5                	li	a7,17
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <trace>:
.global trace
trace:
 li a7, SYS_trace
 3dc:	48c9                	li	a7,18
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <sysinfo>:
.global sysinfo
sysinfo:
 li a7, SYS_sysinfo
 3e4:	48cd                	li	a7,19
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <rename>:
.global rename
rename:
 li a7, SYS_rename
 3ec:	48e9                	li	a7,26
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3f4:	1101                	addi	sp,sp,-32
 3f6:	ec06                	sd	ra,24(sp)
 3f8:	e822                	sd	s0,16(sp)
 3fa:	1000                	addi	s0,sp,32
 3fc:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 400:	4605                	li	a2,1
 402:	fef40593          	addi	a1,s0,-17
 406:	00000097          	auipc	ra,0x0
 40a:	f46080e7          	jalr	-186(ra) # 34c <write>
}
 40e:	60e2                	ld	ra,24(sp)
 410:	6442                	ld	s0,16(sp)
 412:	6105                	addi	sp,sp,32
 414:	8082                	ret

0000000000000416 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 416:	7139                	addi	sp,sp,-64
 418:	fc06                	sd	ra,56(sp)
 41a:	f822                	sd	s0,48(sp)
 41c:	f426                	sd	s1,40(sp)
 41e:	0080                	addi	s0,sp,64
 420:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 422:	c299                	beqz	a3,428 <printint+0x12>
 424:	0805cb63          	bltz	a1,4ba <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 428:	2581                	sext.w	a1,a1
  neg = 0;
 42a:	4881                	li	a7,0
 42c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 430:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 432:	2601                	sext.w	a2,a2
 434:	00000517          	auipc	a0,0x0
 438:	4dc50513          	addi	a0,a0,1244 # 910 <digits>
 43c:	883a                	mv	a6,a4
 43e:	2705                	addiw	a4,a4,1
 440:	02c5f7bb          	remuw	a5,a1,a2
 444:	1782                	slli	a5,a5,0x20
 446:	9381                	srli	a5,a5,0x20
 448:	97aa                	add	a5,a5,a0
 44a:	0007c783          	lbu	a5,0(a5)
 44e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 452:	0005879b          	sext.w	a5,a1
 456:	02c5d5bb          	divuw	a1,a1,a2
 45a:	0685                	addi	a3,a3,1
 45c:	fec7f0e3          	bgeu	a5,a2,43c <printint+0x26>
  if(neg)
 460:	00088c63          	beqz	a7,478 <printint+0x62>
    buf[i++] = '-';
 464:	fd070793          	addi	a5,a4,-48
 468:	00878733          	add	a4,a5,s0
 46c:	02d00793          	li	a5,45
 470:	fef70823          	sb	a5,-16(a4)
 474:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 478:	02e05c63          	blez	a4,4b0 <printint+0x9a>
 47c:	f04a                	sd	s2,32(sp)
 47e:	ec4e                	sd	s3,24(sp)
 480:	fc040793          	addi	a5,s0,-64
 484:	00e78933          	add	s2,a5,a4
 488:	fff78993          	addi	s3,a5,-1
 48c:	99ba                	add	s3,s3,a4
 48e:	377d                	addiw	a4,a4,-1
 490:	1702                	slli	a4,a4,0x20
 492:	9301                	srli	a4,a4,0x20
 494:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 498:	fff94583          	lbu	a1,-1(s2)
 49c:	8526                	mv	a0,s1
 49e:	00000097          	auipc	ra,0x0
 4a2:	f56080e7          	jalr	-170(ra) # 3f4 <putc>
  while(--i >= 0)
 4a6:	197d                	addi	s2,s2,-1
 4a8:	ff3918e3          	bne	s2,s3,498 <printint+0x82>
 4ac:	7902                	ld	s2,32(sp)
 4ae:	69e2                	ld	s3,24(sp)
}
 4b0:	70e2                	ld	ra,56(sp)
 4b2:	7442                	ld	s0,48(sp)
 4b4:	74a2                	ld	s1,40(sp)
 4b6:	6121                	addi	sp,sp,64
 4b8:	8082                	ret
    x = -xx;
 4ba:	40b005bb          	negw	a1,a1
    neg = 1;
 4be:	4885                	li	a7,1
    x = -xx;
 4c0:	b7b5                	j	42c <printint+0x16>

00000000000004c2 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4c2:	715d                	addi	sp,sp,-80
 4c4:	e486                	sd	ra,72(sp)
 4c6:	e0a2                	sd	s0,64(sp)
 4c8:	f84a                	sd	s2,48(sp)
 4ca:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4cc:	0005c903          	lbu	s2,0(a1)
 4d0:	1a090a63          	beqz	s2,684 <vprintf+0x1c2>
 4d4:	fc26                	sd	s1,56(sp)
 4d6:	f44e                	sd	s3,40(sp)
 4d8:	f052                	sd	s4,32(sp)
 4da:	ec56                	sd	s5,24(sp)
 4dc:	e85a                	sd	s6,16(sp)
 4de:	e45e                	sd	s7,8(sp)
 4e0:	8aaa                	mv	s5,a0
 4e2:	8bb2                	mv	s7,a2
 4e4:	00158493          	addi	s1,a1,1
  state = 0;
 4e8:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4ea:	02500a13          	li	s4,37
 4ee:	4b55                	li	s6,21
 4f0:	a839                	j	50e <vprintf+0x4c>
        putc(fd, c);
 4f2:	85ca                	mv	a1,s2
 4f4:	8556                	mv	a0,s5
 4f6:	00000097          	auipc	ra,0x0
 4fa:	efe080e7          	jalr	-258(ra) # 3f4 <putc>
 4fe:	a019                	j	504 <vprintf+0x42>
    } else if(state == '%'){
 500:	01498d63          	beq	s3,s4,51a <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 504:	0485                	addi	s1,s1,1
 506:	fff4c903          	lbu	s2,-1(s1)
 50a:	16090763          	beqz	s2,678 <vprintf+0x1b6>
    if(state == 0){
 50e:	fe0999e3          	bnez	s3,500 <vprintf+0x3e>
      if(c == '%'){
 512:	ff4910e3          	bne	s2,s4,4f2 <vprintf+0x30>
        state = '%';
 516:	89d2                	mv	s3,s4
 518:	b7f5                	j	504 <vprintf+0x42>
      if(c == 'd'){
 51a:	13490463          	beq	s2,s4,642 <vprintf+0x180>
 51e:	f9d9079b          	addiw	a5,s2,-99
 522:	0ff7f793          	zext.b	a5,a5
 526:	12fb6763          	bltu	s6,a5,654 <vprintf+0x192>
 52a:	f9d9079b          	addiw	a5,s2,-99
 52e:	0ff7f713          	zext.b	a4,a5
 532:	12eb6163          	bltu	s6,a4,654 <vprintf+0x192>
 536:	00271793          	slli	a5,a4,0x2
 53a:	00000717          	auipc	a4,0x0
 53e:	37e70713          	addi	a4,a4,894 # 8b8 <malloc+0x144>
 542:	97ba                	add	a5,a5,a4
 544:	439c                	lw	a5,0(a5)
 546:	97ba                	add	a5,a5,a4
 548:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 54a:	008b8913          	addi	s2,s7,8
 54e:	4685                	li	a3,1
 550:	4629                	li	a2,10
 552:	000ba583          	lw	a1,0(s7)
 556:	8556                	mv	a0,s5
 558:	00000097          	auipc	ra,0x0
 55c:	ebe080e7          	jalr	-322(ra) # 416 <printint>
 560:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 562:	4981                	li	s3,0
 564:	b745                	j	504 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 566:	008b8913          	addi	s2,s7,8
 56a:	4681                	li	a3,0
 56c:	4629                	li	a2,10
 56e:	000ba583          	lw	a1,0(s7)
 572:	8556                	mv	a0,s5
 574:	00000097          	auipc	ra,0x0
 578:	ea2080e7          	jalr	-350(ra) # 416 <printint>
 57c:	8bca                	mv	s7,s2
      state = 0;
 57e:	4981                	li	s3,0
 580:	b751                	j	504 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 582:	008b8913          	addi	s2,s7,8
 586:	4681                	li	a3,0
 588:	4641                	li	a2,16
 58a:	000ba583          	lw	a1,0(s7)
 58e:	8556                	mv	a0,s5
 590:	00000097          	auipc	ra,0x0
 594:	e86080e7          	jalr	-378(ra) # 416 <printint>
 598:	8bca                	mv	s7,s2
      state = 0;
 59a:	4981                	li	s3,0
 59c:	b7a5                	j	504 <vprintf+0x42>
 59e:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 5a0:	008b8c13          	addi	s8,s7,8
 5a4:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5a8:	03000593          	li	a1,48
 5ac:	8556                	mv	a0,s5
 5ae:	00000097          	auipc	ra,0x0
 5b2:	e46080e7          	jalr	-442(ra) # 3f4 <putc>
  putc(fd, 'x');
 5b6:	07800593          	li	a1,120
 5ba:	8556                	mv	a0,s5
 5bc:	00000097          	auipc	ra,0x0
 5c0:	e38080e7          	jalr	-456(ra) # 3f4 <putc>
 5c4:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5c6:	00000b97          	auipc	s7,0x0
 5ca:	34ab8b93          	addi	s7,s7,842 # 910 <digits>
 5ce:	03c9d793          	srli	a5,s3,0x3c
 5d2:	97de                	add	a5,a5,s7
 5d4:	0007c583          	lbu	a1,0(a5)
 5d8:	8556                	mv	a0,s5
 5da:	00000097          	auipc	ra,0x0
 5de:	e1a080e7          	jalr	-486(ra) # 3f4 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5e2:	0992                	slli	s3,s3,0x4
 5e4:	397d                	addiw	s2,s2,-1
 5e6:	fe0914e3          	bnez	s2,5ce <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 5ea:	8be2                	mv	s7,s8
      state = 0;
 5ec:	4981                	li	s3,0
 5ee:	6c02                	ld	s8,0(sp)
 5f0:	bf11                	j	504 <vprintf+0x42>
        s = va_arg(ap, char*);
 5f2:	008b8993          	addi	s3,s7,8
 5f6:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 5fa:	02090163          	beqz	s2,61c <vprintf+0x15a>
        while(*s != 0){
 5fe:	00094583          	lbu	a1,0(s2)
 602:	c9a5                	beqz	a1,672 <vprintf+0x1b0>
          putc(fd, *s);
 604:	8556                	mv	a0,s5
 606:	00000097          	auipc	ra,0x0
 60a:	dee080e7          	jalr	-530(ra) # 3f4 <putc>
          s++;
 60e:	0905                	addi	s2,s2,1
        while(*s != 0){
 610:	00094583          	lbu	a1,0(s2)
 614:	f9e5                	bnez	a1,604 <vprintf+0x142>
        s = va_arg(ap, char*);
 616:	8bce                	mv	s7,s3
      state = 0;
 618:	4981                	li	s3,0
 61a:	b5ed                	j	504 <vprintf+0x42>
          s = "(null)";
 61c:	00000917          	auipc	s2,0x0
 620:	29490913          	addi	s2,s2,660 # 8b0 <malloc+0x13c>
        while(*s != 0){
 624:	02800593          	li	a1,40
 628:	bff1                	j	604 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 62a:	008b8913          	addi	s2,s7,8
 62e:	000bc583          	lbu	a1,0(s7)
 632:	8556                	mv	a0,s5
 634:	00000097          	auipc	ra,0x0
 638:	dc0080e7          	jalr	-576(ra) # 3f4 <putc>
 63c:	8bca                	mv	s7,s2
      state = 0;
 63e:	4981                	li	s3,0
 640:	b5d1                	j	504 <vprintf+0x42>
        putc(fd, c);
 642:	02500593          	li	a1,37
 646:	8556                	mv	a0,s5
 648:	00000097          	auipc	ra,0x0
 64c:	dac080e7          	jalr	-596(ra) # 3f4 <putc>
      state = 0;
 650:	4981                	li	s3,0
 652:	bd4d                	j	504 <vprintf+0x42>
        putc(fd, '%');
 654:	02500593          	li	a1,37
 658:	8556                	mv	a0,s5
 65a:	00000097          	auipc	ra,0x0
 65e:	d9a080e7          	jalr	-614(ra) # 3f4 <putc>
        putc(fd, c);
 662:	85ca                	mv	a1,s2
 664:	8556                	mv	a0,s5
 666:	00000097          	auipc	ra,0x0
 66a:	d8e080e7          	jalr	-626(ra) # 3f4 <putc>
      state = 0;
 66e:	4981                	li	s3,0
 670:	bd51                	j	504 <vprintf+0x42>
        s = va_arg(ap, char*);
 672:	8bce                	mv	s7,s3
      state = 0;
 674:	4981                	li	s3,0
 676:	b579                	j	504 <vprintf+0x42>
 678:	74e2                	ld	s1,56(sp)
 67a:	79a2                	ld	s3,40(sp)
 67c:	7a02                	ld	s4,32(sp)
 67e:	6ae2                	ld	s5,24(sp)
 680:	6b42                	ld	s6,16(sp)
 682:	6ba2                	ld	s7,8(sp)
    }
  }
}
 684:	60a6                	ld	ra,72(sp)
 686:	6406                	ld	s0,64(sp)
 688:	7942                	ld	s2,48(sp)
 68a:	6161                	addi	sp,sp,80
 68c:	8082                	ret

000000000000068e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 68e:	715d                	addi	sp,sp,-80
 690:	ec06                	sd	ra,24(sp)
 692:	e822                	sd	s0,16(sp)
 694:	1000                	addi	s0,sp,32
 696:	e010                	sd	a2,0(s0)
 698:	e414                	sd	a3,8(s0)
 69a:	e818                	sd	a4,16(s0)
 69c:	ec1c                	sd	a5,24(s0)
 69e:	03043023          	sd	a6,32(s0)
 6a2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6a6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6aa:	8622                	mv	a2,s0
 6ac:	00000097          	auipc	ra,0x0
 6b0:	e16080e7          	jalr	-490(ra) # 4c2 <vprintf>
}
 6b4:	60e2                	ld	ra,24(sp)
 6b6:	6442                	ld	s0,16(sp)
 6b8:	6161                	addi	sp,sp,80
 6ba:	8082                	ret

00000000000006bc <printf>:

void
printf(const char *fmt, ...)
{
 6bc:	711d                	addi	sp,sp,-96
 6be:	ec06                	sd	ra,24(sp)
 6c0:	e822                	sd	s0,16(sp)
 6c2:	1000                	addi	s0,sp,32
 6c4:	e40c                	sd	a1,8(s0)
 6c6:	e810                	sd	a2,16(s0)
 6c8:	ec14                	sd	a3,24(s0)
 6ca:	f018                	sd	a4,32(s0)
 6cc:	f41c                	sd	a5,40(s0)
 6ce:	03043823          	sd	a6,48(s0)
 6d2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6d6:	00840613          	addi	a2,s0,8
 6da:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6de:	85aa                	mv	a1,a0
 6e0:	4505                	li	a0,1
 6e2:	00000097          	auipc	ra,0x0
 6e6:	de0080e7          	jalr	-544(ra) # 4c2 <vprintf>
}
 6ea:	60e2                	ld	ra,24(sp)
 6ec:	6442                	ld	s0,16(sp)
 6ee:	6125                	addi	sp,sp,96
 6f0:	8082                	ret

00000000000006f2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6f2:	1141                	addi	sp,sp,-16
 6f4:	e422                	sd	s0,8(sp)
 6f6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6f8:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6fc:	00000797          	auipc	a5,0x0
 700:	22c7b783          	ld	a5,556(a5) # 928 <freep>
 704:	a02d                	j	72e <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 706:	4618                	lw	a4,8(a2)
 708:	9f2d                	addw	a4,a4,a1
 70a:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 70e:	6398                	ld	a4,0(a5)
 710:	6310                	ld	a2,0(a4)
 712:	a83d                	j	750 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 714:	ff852703          	lw	a4,-8(a0)
 718:	9f31                	addw	a4,a4,a2
 71a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 71c:	ff053683          	ld	a3,-16(a0)
 720:	a091                	j	764 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 722:	6398                	ld	a4,0(a5)
 724:	00e7e463          	bltu	a5,a4,72c <free+0x3a>
 728:	00e6ea63          	bltu	a3,a4,73c <free+0x4a>
{
 72c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 72e:	fed7fae3          	bgeu	a5,a3,722 <free+0x30>
 732:	6398                	ld	a4,0(a5)
 734:	00e6e463          	bltu	a3,a4,73c <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 738:	fee7eae3          	bltu	a5,a4,72c <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 73c:	ff852583          	lw	a1,-8(a0)
 740:	6390                	ld	a2,0(a5)
 742:	02059813          	slli	a6,a1,0x20
 746:	01c85713          	srli	a4,a6,0x1c
 74a:	9736                	add	a4,a4,a3
 74c:	fae60de3          	beq	a2,a4,706 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 750:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 754:	4790                	lw	a2,8(a5)
 756:	02061593          	slli	a1,a2,0x20
 75a:	01c5d713          	srli	a4,a1,0x1c
 75e:	973e                	add	a4,a4,a5
 760:	fae68ae3          	beq	a3,a4,714 <free+0x22>
    p->s.ptr = bp->s.ptr;
 764:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 766:	00000717          	auipc	a4,0x0
 76a:	1cf73123          	sd	a5,450(a4) # 928 <freep>
}
 76e:	6422                	ld	s0,8(sp)
 770:	0141                	addi	sp,sp,16
 772:	8082                	ret

0000000000000774 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 774:	7139                	addi	sp,sp,-64
 776:	fc06                	sd	ra,56(sp)
 778:	f822                	sd	s0,48(sp)
 77a:	f426                	sd	s1,40(sp)
 77c:	ec4e                	sd	s3,24(sp)
 77e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 780:	02051493          	slli	s1,a0,0x20
 784:	9081                	srli	s1,s1,0x20
 786:	04bd                	addi	s1,s1,15
 788:	8091                	srli	s1,s1,0x4
 78a:	0014899b          	addiw	s3,s1,1
 78e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 790:	00000517          	auipc	a0,0x0
 794:	19853503          	ld	a0,408(a0) # 928 <freep>
 798:	c915                	beqz	a0,7cc <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 79a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 79c:	4798                	lw	a4,8(a5)
 79e:	08977e63          	bgeu	a4,s1,83a <malloc+0xc6>
 7a2:	f04a                	sd	s2,32(sp)
 7a4:	e852                	sd	s4,16(sp)
 7a6:	e456                	sd	s5,8(sp)
 7a8:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 7aa:	8a4e                	mv	s4,s3
 7ac:	0009871b          	sext.w	a4,s3
 7b0:	6685                	lui	a3,0x1
 7b2:	00d77363          	bgeu	a4,a3,7b8 <malloc+0x44>
 7b6:	6a05                	lui	s4,0x1
 7b8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7bc:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7c0:	00000917          	auipc	s2,0x0
 7c4:	16890913          	addi	s2,s2,360 # 928 <freep>
  if(p == (char*)-1)
 7c8:	5afd                	li	s5,-1
 7ca:	a091                	j	80e <malloc+0x9a>
 7cc:	f04a                	sd	s2,32(sp)
 7ce:	e852                	sd	s4,16(sp)
 7d0:	e456                	sd	s5,8(sp)
 7d2:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 7d4:	00000797          	auipc	a5,0x0
 7d8:	15c78793          	addi	a5,a5,348 # 930 <base>
 7dc:	00000717          	auipc	a4,0x0
 7e0:	14f73623          	sd	a5,332(a4) # 928 <freep>
 7e4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7e6:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7ea:	b7c1                	j	7aa <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 7ec:	6398                	ld	a4,0(a5)
 7ee:	e118                	sd	a4,0(a0)
 7f0:	a08d                	j	852 <malloc+0xde>
  hp->s.size = nu;
 7f2:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7f6:	0541                	addi	a0,a0,16
 7f8:	00000097          	auipc	ra,0x0
 7fc:	efa080e7          	jalr	-262(ra) # 6f2 <free>
  return freep;
 800:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 804:	c13d                	beqz	a0,86a <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 806:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 808:	4798                	lw	a4,8(a5)
 80a:	02977463          	bgeu	a4,s1,832 <malloc+0xbe>
    if(p == freep)
 80e:	00093703          	ld	a4,0(s2)
 812:	853e                	mv	a0,a5
 814:	fef719e3          	bne	a4,a5,806 <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 818:	8552                	mv	a0,s4
 81a:	00000097          	auipc	ra,0x0
 81e:	b82080e7          	jalr	-1150(ra) # 39c <sbrk>
  if(p == (char*)-1)
 822:	fd5518e3          	bne	a0,s5,7f2 <malloc+0x7e>
        return 0;
 826:	4501                	li	a0,0
 828:	7902                	ld	s2,32(sp)
 82a:	6a42                	ld	s4,16(sp)
 82c:	6aa2                	ld	s5,8(sp)
 82e:	6b02                	ld	s6,0(sp)
 830:	a03d                	j	85e <malloc+0xea>
 832:	7902                	ld	s2,32(sp)
 834:	6a42                	ld	s4,16(sp)
 836:	6aa2                	ld	s5,8(sp)
 838:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 83a:	fae489e3          	beq	s1,a4,7ec <malloc+0x78>
        p->s.size -= nunits;
 83e:	4137073b          	subw	a4,a4,s3
 842:	c798                	sw	a4,8(a5)
        p += p->s.size;
 844:	02071693          	slli	a3,a4,0x20
 848:	01c6d713          	srli	a4,a3,0x1c
 84c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 84e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 852:	00000717          	auipc	a4,0x0
 856:	0ca73b23          	sd	a0,214(a4) # 928 <freep>
      return (void*)(p + 1);
 85a:	01078513          	addi	a0,a5,16
  }
}
 85e:	70e2                	ld	ra,56(sp)
 860:	7442                	ld	s0,48(sp)
 862:	74a2                	ld	s1,40(sp)
 864:	69e2                	ld	s3,24(sp)
 866:	6121                	addi	sp,sp,64
 868:	8082                	ret
 86a:	7902                	ld	s2,32(sp)
 86c:	6a42                	ld	s4,16(sp)
 86e:	6aa2                	ld	s5,8(sp)
 870:	6b02                	ld	s6,0(sp)
 872:	b7f5                	j	85e <malloc+0xea>
