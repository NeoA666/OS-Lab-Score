
xv6-user/_echo:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/include/stat.h"
#include "xv6-user/user.h"

int
main(int argc, char *argv[])
{
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	e852                	sd	s4,16(sp)
   e:	e456                	sd	s5,8(sp)
  10:	0080                	addi	s0,sp,64
  int i;

  for(i = 1; i < argc; i++){
  12:	4785                	li	a5,1
  14:	06a7d863          	bge	a5,a0,84 <main+0x84>
  18:	00858493          	addi	s1,a1,8
  1c:	3579                	addiw	a0,a0,-2
  1e:	02051793          	slli	a5,a0,0x20
  22:	01d7d513          	srli	a0,a5,0x1d
  26:	00a48a33          	add	s4,s1,a0
  2a:	05c1                	addi	a1,a1,16
  2c:	00a589b3          	add	s3,a1,a0
    write(1, argv[i], strlen(argv[i]));
    if(i + 1 < argc){
      write(1, " ", 1);
  30:	00001a97          	auipc	s5,0x1
  34:	858a8a93          	addi	s5,s5,-1960 # 888 <malloc+0x100>
  38:	a819                	j	4e <main+0x4e>
  3a:	4605                	li	a2,1
  3c:	85d6                	mv	a1,s5
  3e:	4505                	li	a0,1
  40:	00000097          	auipc	ra,0x0
  44:	320080e7          	jalr	800(ra) # 360 <write>
  for(i = 1; i < argc; i++){
  48:	04a1                	addi	s1,s1,8
  4a:	03348d63          	beq	s1,s3,84 <main+0x84>
    write(1, argv[i], strlen(argv[i]));
  4e:	0004b903          	ld	s2,0(s1)
  52:	854a                	mv	a0,s2
  54:	00000097          	auipc	ra,0x0
  58:	0b0080e7          	jalr	176(ra) # 104 <strlen>
  5c:	0005061b          	sext.w	a2,a0
  60:	85ca                	mv	a1,s2
  62:	4505                	li	a0,1
  64:	00000097          	auipc	ra,0x0
  68:	2fc080e7          	jalr	764(ra) # 360 <write>
    if(i + 1 < argc){
  6c:	fd4497e3          	bne	s1,s4,3a <main+0x3a>
    } else {
      write(1, "\n", 1);
  70:	4605                	li	a2,1
  72:	00001597          	auipc	a1,0x1
  76:	81e58593          	addi	a1,a1,-2018 # 890 <malloc+0x108>
  7a:	4505                	li	a0,1
  7c:	00000097          	auipc	ra,0x0
  80:	2e4080e7          	jalr	740(ra) # 360 <write>
    }
  }
  exit(0);
  84:	4501                	li	a0,0
  86:	00000097          	auipc	ra,0x0
  8a:	2ba080e7          	jalr	698(ra) # 340 <exit>

000000000000008e <strcpy>:
#include "kernel/include/fcntl.h"
#include "xv6-user/user.h"

char*
strcpy(char *s, const char *t)
{
  8e:	1141                	addi	sp,sp,-16
  90:	e422                	sd	s0,8(sp)
  92:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  94:	87aa                	mv	a5,a0
  96:	0585                	addi	a1,a1,1
  98:	0785                	addi	a5,a5,1
  9a:	fff5c703          	lbu	a4,-1(a1)
  9e:	fee78fa3          	sb	a4,-1(a5)
  a2:	fb75                	bnez	a4,96 <strcpy+0x8>
    ;
  return os;
}
  a4:	6422                	ld	s0,8(sp)
  a6:	0141                	addi	sp,sp,16
  a8:	8082                	ret

00000000000000aa <strcat>:

char*
strcat(char *s, const char *t)
{
  aa:	1141                	addi	sp,sp,-16
  ac:	e422                	sd	s0,8(sp)
  ae:	0800                	addi	s0,sp,16
  char *os = s;
  while(*s)
  b0:	00054783          	lbu	a5,0(a0)
  b4:	c385                	beqz	a5,d4 <strcat+0x2a>
  b6:	87aa                	mv	a5,a0
    s++;
  b8:	0785                	addi	a5,a5,1
  while(*s)
  ba:	0007c703          	lbu	a4,0(a5)
  be:	ff6d                	bnez	a4,b8 <strcat+0xe>
  while((*s++ = *t++))
  c0:	0585                	addi	a1,a1,1
  c2:	0785                	addi	a5,a5,1
  c4:	fff5c703          	lbu	a4,-1(a1)
  c8:	fee78fa3          	sb	a4,-1(a5)
  cc:	fb75                	bnez	a4,c0 <strcat+0x16>
    ;
  return os;
}
  ce:	6422                	ld	s0,8(sp)
  d0:	0141                	addi	sp,sp,16
  d2:	8082                	ret
  while(*s)
  d4:	87aa                	mv	a5,a0
  d6:	b7ed                	j	c0 <strcat+0x16>

00000000000000d8 <strcmp>:


int
strcmp(const char *p, const char *q)
{
  d8:	1141                	addi	sp,sp,-16
  da:	e422                	sd	s0,8(sp)
  dc:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  de:	00054783          	lbu	a5,0(a0)
  e2:	cb91                	beqz	a5,f6 <strcmp+0x1e>
  e4:	0005c703          	lbu	a4,0(a1)
  e8:	00f71763          	bne	a4,a5,f6 <strcmp+0x1e>
    p++, q++;
  ec:	0505                	addi	a0,a0,1
  ee:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  f0:	00054783          	lbu	a5,0(a0)
  f4:	fbe5                	bnez	a5,e4 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  f6:	0005c503          	lbu	a0,0(a1)
}
  fa:	40a7853b          	subw	a0,a5,a0
  fe:	6422                	ld	s0,8(sp)
 100:	0141                	addi	sp,sp,16
 102:	8082                	ret

0000000000000104 <strlen>:

uint
strlen(const char *s)
{
 104:	1141                	addi	sp,sp,-16
 106:	e422                	sd	s0,8(sp)
 108:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 10a:	00054783          	lbu	a5,0(a0)
 10e:	cf91                	beqz	a5,12a <strlen+0x26>
 110:	0505                	addi	a0,a0,1
 112:	87aa                	mv	a5,a0
 114:	86be                	mv	a3,a5
 116:	0785                	addi	a5,a5,1
 118:	fff7c703          	lbu	a4,-1(a5)
 11c:	ff65                	bnez	a4,114 <strlen+0x10>
 11e:	40a6853b          	subw	a0,a3,a0
 122:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 124:	6422                	ld	s0,8(sp)
 126:	0141                	addi	sp,sp,16
 128:	8082                	ret
  for(n = 0; s[n]; n++)
 12a:	4501                	li	a0,0
 12c:	bfe5                	j	124 <strlen+0x20>

000000000000012e <memset>:

void*
memset(void *dst, int c, uint n)
{
 12e:	1141                	addi	sp,sp,-16
 130:	e422                	sd	s0,8(sp)
 132:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 134:	ca19                	beqz	a2,14a <memset+0x1c>
 136:	87aa                	mv	a5,a0
 138:	1602                	slli	a2,a2,0x20
 13a:	9201                	srli	a2,a2,0x20
 13c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 140:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 144:	0785                	addi	a5,a5,1
 146:	fee79de3          	bne	a5,a4,140 <memset+0x12>
  }
  return dst;
}
 14a:	6422                	ld	s0,8(sp)
 14c:	0141                	addi	sp,sp,16
 14e:	8082                	ret

0000000000000150 <strchr>:

char*
strchr(const char *s, char c)
{
 150:	1141                	addi	sp,sp,-16
 152:	e422                	sd	s0,8(sp)
 154:	0800                	addi	s0,sp,16
  for(; *s; s++)
 156:	00054783          	lbu	a5,0(a0)
 15a:	cb99                	beqz	a5,170 <strchr+0x20>
    if(*s == c)
 15c:	00f58763          	beq	a1,a5,16a <strchr+0x1a>
  for(; *s; s++)
 160:	0505                	addi	a0,a0,1
 162:	00054783          	lbu	a5,0(a0)
 166:	fbfd                	bnez	a5,15c <strchr+0xc>
      return (char*)s;
  return 0;
 168:	4501                	li	a0,0
}
 16a:	6422                	ld	s0,8(sp)
 16c:	0141                	addi	sp,sp,16
 16e:	8082                	ret
  return 0;
 170:	4501                	li	a0,0
 172:	bfe5                	j	16a <strchr+0x1a>

0000000000000174 <gets>:

char*
gets(char *buf, int max)
{
 174:	711d                	addi	sp,sp,-96
 176:	ec86                	sd	ra,88(sp)
 178:	e8a2                	sd	s0,80(sp)
 17a:	e4a6                	sd	s1,72(sp)
 17c:	e0ca                	sd	s2,64(sp)
 17e:	fc4e                	sd	s3,56(sp)
 180:	f852                	sd	s4,48(sp)
 182:	f456                	sd	s5,40(sp)
 184:	f05a                	sd	s6,32(sp)
 186:	ec5e                	sd	s7,24(sp)
 188:	1080                	addi	s0,sp,96
 18a:	8baa                	mv	s7,a0
 18c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 18e:	892a                	mv	s2,a0
 190:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 192:	4aa9                	li	s5,10
 194:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 196:	89a6                	mv	s3,s1
 198:	2485                	addiw	s1,s1,1
 19a:	0344d863          	bge	s1,s4,1ca <gets+0x56>
    cc = read(0, &c, 1);
 19e:	4605                	li	a2,1
 1a0:	faf40593          	addi	a1,s0,-81
 1a4:	4501                	li	a0,0
 1a6:	00000097          	auipc	ra,0x0
 1aa:	1b2080e7          	jalr	434(ra) # 358 <read>
    if(cc < 1)
 1ae:	00a05e63          	blez	a0,1ca <gets+0x56>
    buf[i++] = c;
 1b2:	faf44783          	lbu	a5,-81(s0)
 1b6:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1ba:	01578763          	beq	a5,s5,1c8 <gets+0x54>
 1be:	0905                	addi	s2,s2,1
 1c0:	fd679be3          	bne	a5,s6,196 <gets+0x22>
    buf[i++] = c;
 1c4:	89a6                	mv	s3,s1
 1c6:	a011                	j	1ca <gets+0x56>
 1c8:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1ca:	99de                	add	s3,s3,s7
 1cc:	00098023          	sb	zero,0(s3)
  return buf;
}
 1d0:	855e                	mv	a0,s7
 1d2:	60e6                	ld	ra,88(sp)
 1d4:	6446                	ld	s0,80(sp)
 1d6:	64a6                	ld	s1,72(sp)
 1d8:	6906                	ld	s2,64(sp)
 1da:	79e2                	ld	s3,56(sp)
 1dc:	7a42                	ld	s4,48(sp)
 1de:	7aa2                	ld	s5,40(sp)
 1e0:	7b02                	ld	s6,32(sp)
 1e2:	6be2                	ld	s7,24(sp)
 1e4:	6125                	addi	sp,sp,96
 1e6:	8082                	ret

00000000000001e8 <stat>:

int
stat(const char *n, struct stat *st)
{
 1e8:	1101                	addi	sp,sp,-32
 1ea:	ec06                	sd	ra,24(sp)
 1ec:	e822                	sd	s0,16(sp)
 1ee:	e04a                	sd	s2,0(sp)
 1f0:	1000                	addi	s0,sp,32
 1f2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1f4:	4581                	li	a1,0
 1f6:	00000097          	auipc	ra,0x0
 1fa:	18a080e7          	jalr	394(ra) # 380 <open>
  if(fd < 0)
 1fe:	02054663          	bltz	a0,22a <stat+0x42>
 202:	e426                	sd	s1,8(sp)
 204:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 206:	85ca                	mv	a1,s2
 208:	00000097          	auipc	ra,0x0
 20c:	180080e7          	jalr	384(ra) # 388 <fstat>
 210:	892a                	mv	s2,a0
  close(fd);
 212:	8526                	mv	a0,s1
 214:	00000097          	auipc	ra,0x0
 218:	154080e7          	jalr	340(ra) # 368 <close>
  return r;
 21c:	64a2                	ld	s1,8(sp)
}
 21e:	854a                	mv	a0,s2
 220:	60e2                	ld	ra,24(sp)
 222:	6442                	ld	s0,16(sp)
 224:	6902                	ld	s2,0(sp)
 226:	6105                	addi	sp,sp,32
 228:	8082                	ret
    return -1;
 22a:	597d                	li	s2,-1
 22c:	bfcd                	j	21e <stat+0x36>

000000000000022e <atoi>:

int
atoi(const char *s)
{
 22e:	1141                	addi	sp,sp,-16
 230:	e422                	sd	s0,8(sp)
 232:	0800                	addi	s0,sp,16
  int n;
  int neg = 1;
  if (*s == '-') {
 234:	00054703          	lbu	a4,0(a0)
 238:	02d00793          	li	a5,45
  int neg = 1;
 23c:	4585                	li	a1,1
  if (*s == '-') {
 23e:	04f70363          	beq	a4,a5,284 <atoi+0x56>
    s++;
    neg = -1;
  }
  n = 0;
  while('0' <= *s && *s <= '9')
 242:	00054703          	lbu	a4,0(a0)
 246:	fd07079b          	addiw	a5,a4,-48
 24a:	0ff7f793          	zext.b	a5,a5
 24e:	46a5                	li	a3,9
 250:	02f6ed63          	bltu	a3,a5,28a <atoi+0x5c>
  n = 0;
 254:	4681                	li	a3,0
  while('0' <= *s && *s <= '9')
 256:	4625                	li	a2,9
    n = n*10 + *s++ - '0';
 258:	0505                	addi	a0,a0,1
 25a:	0026979b          	slliw	a5,a3,0x2
 25e:	9fb5                	addw	a5,a5,a3
 260:	0017979b          	slliw	a5,a5,0x1
 264:	9fb9                	addw	a5,a5,a4
 266:	fd07869b          	addiw	a3,a5,-48
  while('0' <= *s && *s <= '9')
 26a:	00054703          	lbu	a4,0(a0)
 26e:	fd07079b          	addiw	a5,a4,-48
 272:	0ff7f793          	zext.b	a5,a5
 276:	fef671e3          	bgeu	a2,a5,258 <atoi+0x2a>
  return n * neg;
}
 27a:	02d5853b          	mulw	a0,a1,a3
 27e:	6422                	ld	s0,8(sp)
 280:	0141                	addi	sp,sp,16
 282:	8082                	ret
    s++;
 284:	0505                	addi	a0,a0,1
    neg = -1;
 286:	55fd                	li	a1,-1
 288:	bf6d                	j	242 <atoi+0x14>
  n = 0;
 28a:	4681                	li	a3,0
 28c:	b7fd                	j	27a <atoi+0x4c>

000000000000028e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 28e:	1141                	addi	sp,sp,-16
 290:	e422                	sd	s0,8(sp)
 292:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 294:	02b57463          	bgeu	a0,a1,2bc <memmove+0x2e>
    while(n-- > 0)
 298:	00c05f63          	blez	a2,2b6 <memmove+0x28>
 29c:	1602                	slli	a2,a2,0x20
 29e:	9201                	srli	a2,a2,0x20
 2a0:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2a4:	872a                	mv	a4,a0
      *dst++ = *src++;
 2a6:	0585                	addi	a1,a1,1
 2a8:	0705                	addi	a4,a4,1
 2aa:	fff5c683          	lbu	a3,-1(a1)
 2ae:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2b2:	fef71ae3          	bne	a4,a5,2a6 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2b6:	6422                	ld	s0,8(sp)
 2b8:	0141                	addi	sp,sp,16
 2ba:	8082                	ret
    dst += n;
 2bc:	00c50733          	add	a4,a0,a2
    src += n;
 2c0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2c2:	fec05ae3          	blez	a2,2b6 <memmove+0x28>
 2c6:	fff6079b          	addiw	a5,a2,-1
 2ca:	1782                	slli	a5,a5,0x20
 2cc:	9381                	srli	a5,a5,0x20
 2ce:	fff7c793          	not	a5,a5
 2d2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2d4:	15fd                	addi	a1,a1,-1
 2d6:	177d                	addi	a4,a4,-1
 2d8:	0005c683          	lbu	a3,0(a1)
 2dc:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2e0:	fee79ae3          	bne	a5,a4,2d4 <memmove+0x46>
 2e4:	bfc9                	j	2b6 <memmove+0x28>

00000000000002e6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2e6:	1141                	addi	sp,sp,-16
 2e8:	e422                	sd	s0,8(sp)
 2ea:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2ec:	ca05                	beqz	a2,31c <memcmp+0x36>
 2ee:	fff6069b          	addiw	a3,a2,-1
 2f2:	1682                	slli	a3,a3,0x20
 2f4:	9281                	srli	a3,a3,0x20
 2f6:	0685                	addi	a3,a3,1
 2f8:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2fa:	00054783          	lbu	a5,0(a0)
 2fe:	0005c703          	lbu	a4,0(a1)
 302:	00e79863          	bne	a5,a4,312 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 306:	0505                	addi	a0,a0,1
    p2++;
 308:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 30a:	fed518e3          	bne	a0,a3,2fa <memcmp+0x14>
  }
  return 0;
 30e:	4501                	li	a0,0
 310:	a019                	j	316 <memcmp+0x30>
      return *p1 - *p2;
 312:	40e7853b          	subw	a0,a5,a4
}
 316:	6422                	ld	s0,8(sp)
 318:	0141                	addi	sp,sp,16
 31a:	8082                	ret
  return 0;
 31c:	4501                	li	a0,0
 31e:	bfe5                	j	316 <memcmp+0x30>

0000000000000320 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 320:	1141                	addi	sp,sp,-16
 322:	e406                	sd	ra,8(sp)
 324:	e022                	sd	s0,0(sp)
 326:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 328:	00000097          	auipc	ra,0x0
 32c:	f66080e7          	jalr	-154(ra) # 28e <memmove>
}
 330:	60a2                	ld	ra,8(sp)
 332:	6402                	ld	s0,0(sp)
 334:	0141                	addi	sp,sp,16
 336:	8082                	ret

0000000000000338 <fork>:
# generated by usys.pl - do not edit
#include "kernel/include/sysnum.h"
.global fork
fork:
 li a7, SYS_fork
 338:	4885                	li	a7,1
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <exit>:
.global exit
exit:
 li a7, SYS_exit
 340:	4889                	li	a7,2
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <wait>:
.global wait
wait:
 li a7, SYS_wait
 348:	488d                	li	a7,3
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 350:	4891                	li	a7,4
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <read>:
.global read
read:
 li a7, SYS_read
 358:	4895                	li	a7,5
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <write>:
.global write
write:
 li a7, SYS_write
 360:	48c1                	li	a7,16
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <close>:
.global close
close:
 li a7, SYS_close
 368:	48d5                	li	a7,21
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <kill>:
.global kill
kill:
 li a7, SYS_kill
 370:	4899                	li	a7,6
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <exec>:
.global exec
exec:
 li a7, SYS_exec
 378:	489d                	li	a7,7
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <open>:
.global open
open:
 li a7, SYS_open
 380:	48bd                	li	a7,15
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 388:	48a1                	li	a7,8
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 390:	48d1                	li	a7,20
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 398:	48a5                	li	a7,9
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3a0:	48a9                	li	a7,10
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3a8:	48ad                	li	a7,11
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3b0:	48b1                	li	a7,12
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3b8:	48b5                	li	a7,13
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3c0:	48b9                	li	a7,14
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <test_proc>:
.global test_proc
test_proc:
 li a7, SYS_test_proc
 3c8:	48d9                	li	a7,22
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <dev>:
.global dev
dev:
 li a7, SYS_dev
 3d0:	48dd                	li	a7,23
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <readdir>:
.global readdir
readdir:
 li a7, SYS_readdir
 3d8:	48e1                	li	a7,24
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <getcwd>:
.global getcwd
getcwd:
 li a7, SYS_getcwd
 3e0:	48e5                	li	a7,25
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <remove>:
.global remove
remove:
 li a7, SYS_remove
 3e8:	48c5                	li	a7,17
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <trace>:
.global trace
trace:
 li a7, SYS_trace
 3f0:	48c9                	li	a7,18
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <sysinfo>:
.global sysinfo
sysinfo:
 li a7, SYS_sysinfo
 3f8:	48cd                	li	a7,19
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <rename>:
.global rename
rename:
 li a7, SYS_rename
 400:	48e9                	li	a7,26
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 408:	1101                	addi	sp,sp,-32
 40a:	ec06                	sd	ra,24(sp)
 40c:	e822                	sd	s0,16(sp)
 40e:	1000                	addi	s0,sp,32
 410:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 414:	4605                	li	a2,1
 416:	fef40593          	addi	a1,s0,-17
 41a:	00000097          	auipc	ra,0x0
 41e:	f46080e7          	jalr	-186(ra) # 360 <write>
}
 422:	60e2                	ld	ra,24(sp)
 424:	6442                	ld	s0,16(sp)
 426:	6105                	addi	sp,sp,32
 428:	8082                	ret

000000000000042a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 42a:	7139                	addi	sp,sp,-64
 42c:	fc06                	sd	ra,56(sp)
 42e:	f822                	sd	s0,48(sp)
 430:	f426                	sd	s1,40(sp)
 432:	0080                	addi	s0,sp,64
 434:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 436:	c299                	beqz	a3,43c <printint+0x12>
 438:	0805cb63          	bltz	a1,4ce <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 43c:	2581                	sext.w	a1,a1
  neg = 0;
 43e:	4881                	li	a7,0
 440:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 444:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 446:	2601                	sext.w	a2,a2
 448:	00000517          	auipc	a0,0x0
 44c:	4b050513          	addi	a0,a0,1200 # 8f8 <digits>
 450:	883a                	mv	a6,a4
 452:	2705                	addiw	a4,a4,1
 454:	02c5f7bb          	remuw	a5,a1,a2
 458:	1782                	slli	a5,a5,0x20
 45a:	9381                	srli	a5,a5,0x20
 45c:	97aa                	add	a5,a5,a0
 45e:	0007c783          	lbu	a5,0(a5)
 462:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 466:	0005879b          	sext.w	a5,a1
 46a:	02c5d5bb          	divuw	a1,a1,a2
 46e:	0685                	addi	a3,a3,1
 470:	fec7f0e3          	bgeu	a5,a2,450 <printint+0x26>
  if(neg)
 474:	00088c63          	beqz	a7,48c <printint+0x62>
    buf[i++] = '-';
 478:	fd070793          	addi	a5,a4,-48
 47c:	00878733          	add	a4,a5,s0
 480:	02d00793          	li	a5,45
 484:	fef70823          	sb	a5,-16(a4)
 488:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 48c:	02e05c63          	blez	a4,4c4 <printint+0x9a>
 490:	f04a                	sd	s2,32(sp)
 492:	ec4e                	sd	s3,24(sp)
 494:	fc040793          	addi	a5,s0,-64
 498:	00e78933          	add	s2,a5,a4
 49c:	fff78993          	addi	s3,a5,-1
 4a0:	99ba                	add	s3,s3,a4
 4a2:	377d                	addiw	a4,a4,-1
 4a4:	1702                	slli	a4,a4,0x20
 4a6:	9301                	srli	a4,a4,0x20
 4a8:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4ac:	fff94583          	lbu	a1,-1(s2)
 4b0:	8526                	mv	a0,s1
 4b2:	00000097          	auipc	ra,0x0
 4b6:	f56080e7          	jalr	-170(ra) # 408 <putc>
  while(--i >= 0)
 4ba:	197d                	addi	s2,s2,-1
 4bc:	ff3918e3          	bne	s2,s3,4ac <printint+0x82>
 4c0:	7902                	ld	s2,32(sp)
 4c2:	69e2                	ld	s3,24(sp)
}
 4c4:	70e2                	ld	ra,56(sp)
 4c6:	7442                	ld	s0,48(sp)
 4c8:	74a2                	ld	s1,40(sp)
 4ca:	6121                	addi	sp,sp,64
 4cc:	8082                	ret
    x = -xx;
 4ce:	40b005bb          	negw	a1,a1
    neg = 1;
 4d2:	4885                	li	a7,1
    x = -xx;
 4d4:	b7b5                	j	440 <printint+0x16>

00000000000004d6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4d6:	715d                	addi	sp,sp,-80
 4d8:	e486                	sd	ra,72(sp)
 4da:	e0a2                	sd	s0,64(sp)
 4dc:	f84a                	sd	s2,48(sp)
 4de:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4e0:	0005c903          	lbu	s2,0(a1)
 4e4:	1a090a63          	beqz	s2,698 <vprintf+0x1c2>
 4e8:	fc26                	sd	s1,56(sp)
 4ea:	f44e                	sd	s3,40(sp)
 4ec:	f052                	sd	s4,32(sp)
 4ee:	ec56                	sd	s5,24(sp)
 4f0:	e85a                	sd	s6,16(sp)
 4f2:	e45e                	sd	s7,8(sp)
 4f4:	8aaa                	mv	s5,a0
 4f6:	8bb2                	mv	s7,a2
 4f8:	00158493          	addi	s1,a1,1
  state = 0;
 4fc:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4fe:	02500a13          	li	s4,37
 502:	4b55                	li	s6,21
 504:	a839                	j	522 <vprintf+0x4c>
        putc(fd, c);
 506:	85ca                	mv	a1,s2
 508:	8556                	mv	a0,s5
 50a:	00000097          	auipc	ra,0x0
 50e:	efe080e7          	jalr	-258(ra) # 408 <putc>
 512:	a019                	j	518 <vprintf+0x42>
    } else if(state == '%'){
 514:	01498d63          	beq	s3,s4,52e <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 518:	0485                	addi	s1,s1,1
 51a:	fff4c903          	lbu	s2,-1(s1)
 51e:	16090763          	beqz	s2,68c <vprintf+0x1b6>
    if(state == 0){
 522:	fe0999e3          	bnez	s3,514 <vprintf+0x3e>
      if(c == '%'){
 526:	ff4910e3          	bne	s2,s4,506 <vprintf+0x30>
        state = '%';
 52a:	89d2                	mv	s3,s4
 52c:	b7f5                	j	518 <vprintf+0x42>
      if(c == 'd'){
 52e:	13490463          	beq	s2,s4,656 <vprintf+0x180>
 532:	f9d9079b          	addiw	a5,s2,-99
 536:	0ff7f793          	zext.b	a5,a5
 53a:	12fb6763          	bltu	s6,a5,668 <vprintf+0x192>
 53e:	f9d9079b          	addiw	a5,s2,-99
 542:	0ff7f713          	zext.b	a4,a5
 546:	12eb6163          	bltu	s6,a4,668 <vprintf+0x192>
 54a:	00271793          	slli	a5,a4,0x2
 54e:	00000717          	auipc	a4,0x0
 552:	35270713          	addi	a4,a4,850 # 8a0 <malloc+0x118>
 556:	97ba                	add	a5,a5,a4
 558:	439c                	lw	a5,0(a5)
 55a:	97ba                	add	a5,a5,a4
 55c:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 55e:	008b8913          	addi	s2,s7,8
 562:	4685                	li	a3,1
 564:	4629                	li	a2,10
 566:	000ba583          	lw	a1,0(s7)
 56a:	8556                	mv	a0,s5
 56c:	00000097          	auipc	ra,0x0
 570:	ebe080e7          	jalr	-322(ra) # 42a <printint>
 574:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 576:	4981                	li	s3,0
 578:	b745                	j	518 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 57a:	008b8913          	addi	s2,s7,8
 57e:	4681                	li	a3,0
 580:	4629                	li	a2,10
 582:	000ba583          	lw	a1,0(s7)
 586:	8556                	mv	a0,s5
 588:	00000097          	auipc	ra,0x0
 58c:	ea2080e7          	jalr	-350(ra) # 42a <printint>
 590:	8bca                	mv	s7,s2
      state = 0;
 592:	4981                	li	s3,0
 594:	b751                	j	518 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 596:	008b8913          	addi	s2,s7,8
 59a:	4681                	li	a3,0
 59c:	4641                	li	a2,16
 59e:	000ba583          	lw	a1,0(s7)
 5a2:	8556                	mv	a0,s5
 5a4:	00000097          	auipc	ra,0x0
 5a8:	e86080e7          	jalr	-378(ra) # 42a <printint>
 5ac:	8bca                	mv	s7,s2
      state = 0;
 5ae:	4981                	li	s3,0
 5b0:	b7a5                	j	518 <vprintf+0x42>
 5b2:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 5b4:	008b8c13          	addi	s8,s7,8
 5b8:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5bc:	03000593          	li	a1,48
 5c0:	8556                	mv	a0,s5
 5c2:	00000097          	auipc	ra,0x0
 5c6:	e46080e7          	jalr	-442(ra) # 408 <putc>
  putc(fd, 'x');
 5ca:	07800593          	li	a1,120
 5ce:	8556                	mv	a0,s5
 5d0:	00000097          	auipc	ra,0x0
 5d4:	e38080e7          	jalr	-456(ra) # 408 <putc>
 5d8:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5da:	00000b97          	auipc	s7,0x0
 5de:	31eb8b93          	addi	s7,s7,798 # 8f8 <digits>
 5e2:	03c9d793          	srli	a5,s3,0x3c
 5e6:	97de                	add	a5,a5,s7
 5e8:	0007c583          	lbu	a1,0(a5)
 5ec:	8556                	mv	a0,s5
 5ee:	00000097          	auipc	ra,0x0
 5f2:	e1a080e7          	jalr	-486(ra) # 408 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5f6:	0992                	slli	s3,s3,0x4
 5f8:	397d                	addiw	s2,s2,-1
 5fa:	fe0914e3          	bnez	s2,5e2 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 5fe:	8be2                	mv	s7,s8
      state = 0;
 600:	4981                	li	s3,0
 602:	6c02                	ld	s8,0(sp)
 604:	bf11                	j	518 <vprintf+0x42>
        s = va_arg(ap, char*);
 606:	008b8993          	addi	s3,s7,8
 60a:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 60e:	02090163          	beqz	s2,630 <vprintf+0x15a>
        while(*s != 0){
 612:	00094583          	lbu	a1,0(s2)
 616:	c9a5                	beqz	a1,686 <vprintf+0x1b0>
          putc(fd, *s);
 618:	8556                	mv	a0,s5
 61a:	00000097          	auipc	ra,0x0
 61e:	dee080e7          	jalr	-530(ra) # 408 <putc>
          s++;
 622:	0905                	addi	s2,s2,1
        while(*s != 0){
 624:	00094583          	lbu	a1,0(s2)
 628:	f9e5                	bnez	a1,618 <vprintf+0x142>
        s = va_arg(ap, char*);
 62a:	8bce                	mv	s7,s3
      state = 0;
 62c:	4981                	li	s3,0
 62e:	b5ed                	j	518 <vprintf+0x42>
          s = "(null)";
 630:	00000917          	auipc	s2,0x0
 634:	26890913          	addi	s2,s2,616 # 898 <malloc+0x110>
        while(*s != 0){
 638:	02800593          	li	a1,40
 63c:	bff1                	j	618 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 63e:	008b8913          	addi	s2,s7,8
 642:	000bc583          	lbu	a1,0(s7)
 646:	8556                	mv	a0,s5
 648:	00000097          	auipc	ra,0x0
 64c:	dc0080e7          	jalr	-576(ra) # 408 <putc>
 650:	8bca                	mv	s7,s2
      state = 0;
 652:	4981                	li	s3,0
 654:	b5d1                	j	518 <vprintf+0x42>
        putc(fd, c);
 656:	02500593          	li	a1,37
 65a:	8556                	mv	a0,s5
 65c:	00000097          	auipc	ra,0x0
 660:	dac080e7          	jalr	-596(ra) # 408 <putc>
      state = 0;
 664:	4981                	li	s3,0
 666:	bd4d                	j	518 <vprintf+0x42>
        putc(fd, '%');
 668:	02500593          	li	a1,37
 66c:	8556                	mv	a0,s5
 66e:	00000097          	auipc	ra,0x0
 672:	d9a080e7          	jalr	-614(ra) # 408 <putc>
        putc(fd, c);
 676:	85ca                	mv	a1,s2
 678:	8556                	mv	a0,s5
 67a:	00000097          	auipc	ra,0x0
 67e:	d8e080e7          	jalr	-626(ra) # 408 <putc>
      state = 0;
 682:	4981                	li	s3,0
 684:	bd51                	j	518 <vprintf+0x42>
        s = va_arg(ap, char*);
 686:	8bce                	mv	s7,s3
      state = 0;
 688:	4981                	li	s3,0
 68a:	b579                	j	518 <vprintf+0x42>
 68c:	74e2                	ld	s1,56(sp)
 68e:	79a2                	ld	s3,40(sp)
 690:	7a02                	ld	s4,32(sp)
 692:	6ae2                	ld	s5,24(sp)
 694:	6b42                	ld	s6,16(sp)
 696:	6ba2                	ld	s7,8(sp)
    }
  }
}
 698:	60a6                	ld	ra,72(sp)
 69a:	6406                	ld	s0,64(sp)
 69c:	7942                	ld	s2,48(sp)
 69e:	6161                	addi	sp,sp,80
 6a0:	8082                	ret

00000000000006a2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6a2:	715d                	addi	sp,sp,-80
 6a4:	ec06                	sd	ra,24(sp)
 6a6:	e822                	sd	s0,16(sp)
 6a8:	1000                	addi	s0,sp,32
 6aa:	e010                	sd	a2,0(s0)
 6ac:	e414                	sd	a3,8(s0)
 6ae:	e818                	sd	a4,16(s0)
 6b0:	ec1c                	sd	a5,24(s0)
 6b2:	03043023          	sd	a6,32(s0)
 6b6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6ba:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6be:	8622                	mv	a2,s0
 6c0:	00000097          	auipc	ra,0x0
 6c4:	e16080e7          	jalr	-490(ra) # 4d6 <vprintf>
}
 6c8:	60e2                	ld	ra,24(sp)
 6ca:	6442                	ld	s0,16(sp)
 6cc:	6161                	addi	sp,sp,80
 6ce:	8082                	ret

00000000000006d0 <printf>:

void
printf(const char *fmt, ...)
{
 6d0:	711d                	addi	sp,sp,-96
 6d2:	ec06                	sd	ra,24(sp)
 6d4:	e822                	sd	s0,16(sp)
 6d6:	1000                	addi	s0,sp,32
 6d8:	e40c                	sd	a1,8(s0)
 6da:	e810                	sd	a2,16(s0)
 6dc:	ec14                	sd	a3,24(s0)
 6de:	f018                	sd	a4,32(s0)
 6e0:	f41c                	sd	a5,40(s0)
 6e2:	03043823          	sd	a6,48(s0)
 6e6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6ea:	00840613          	addi	a2,s0,8
 6ee:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6f2:	85aa                	mv	a1,a0
 6f4:	4505                	li	a0,1
 6f6:	00000097          	auipc	ra,0x0
 6fa:	de0080e7          	jalr	-544(ra) # 4d6 <vprintf>
}
 6fe:	60e2                	ld	ra,24(sp)
 700:	6442                	ld	s0,16(sp)
 702:	6125                	addi	sp,sp,96
 704:	8082                	ret

0000000000000706 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 706:	1141                	addi	sp,sp,-16
 708:	e422                	sd	s0,8(sp)
 70a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 70c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 710:	00000797          	auipc	a5,0x0
 714:	2007b783          	ld	a5,512(a5) # 910 <freep>
 718:	a02d                	j	742 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 71a:	4618                	lw	a4,8(a2)
 71c:	9f2d                	addw	a4,a4,a1
 71e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 722:	6398                	ld	a4,0(a5)
 724:	6310                	ld	a2,0(a4)
 726:	a83d                	j	764 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 728:	ff852703          	lw	a4,-8(a0)
 72c:	9f31                	addw	a4,a4,a2
 72e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 730:	ff053683          	ld	a3,-16(a0)
 734:	a091                	j	778 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 736:	6398                	ld	a4,0(a5)
 738:	00e7e463          	bltu	a5,a4,740 <free+0x3a>
 73c:	00e6ea63          	bltu	a3,a4,750 <free+0x4a>
{
 740:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 742:	fed7fae3          	bgeu	a5,a3,736 <free+0x30>
 746:	6398                	ld	a4,0(a5)
 748:	00e6e463          	bltu	a3,a4,750 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 74c:	fee7eae3          	bltu	a5,a4,740 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 750:	ff852583          	lw	a1,-8(a0)
 754:	6390                	ld	a2,0(a5)
 756:	02059813          	slli	a6,a1,0x20
 75a:	01c85713          	srli	a4,a6,0x1c
 75e:	9736                	add	a4,a4,a3
 760:	fae60de3          	beq	a2,a4,71a <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 764:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 768:	4790                	lw	a2,8(a5)
 76a:	02061593          	slli	a1,a2,0x20
 76e:	01c5d713          	srli	a4,a1,0x1c
 772:	973e                	add	a4,a4,a5
 774:	fae68ae3          	beq	a3,a4,728 <free+0x22>
    p->s.ptr = bp->s.ptr;
 778:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 77a:	00000717          	auipc	a4,0x0
 77e:	18f73b23          	sd	a5,406(a4) # 910 <freep>
}
 782:	6422                	ld	s0,8(sp)
 784:	0141                	addi	sp,sp,16
 786:	8082                	ret

0000000000000788 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 788:	7139                	addi	sp,sp,-64
 78a:	fc06                	sd	ra,56(sp)
 78c:	f822                	sd	s0,48(sp)
 78e:	f426                	sd	s1,40(sp)
 790:	ec4e                	sd	s3,24(sp)
 792:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 794:	02051493          	slli	s1,a0,0x20
 798:	9081                	srli	s1,s1,0x20
 79a:	04bd                	addi	s1,s1,15
 79c:	8091                	srli	s1,s1,0x4
 79e:	0014899b          	addiw	s3,s1,1
 7a2:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7a4:	00000517          	auipc	a0,0x0
 7a8:	16c53503          	ld	a0,364(a0) # 910 <freep>
 7ac:	c915                	beqz	a0,7e0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7ae:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7b0:	4798                	lw	a4,8(a5)
 7b2:	08977e63          	bgeu	a4,s1,84e <malloc+0xc6>
 7b6:	f04a                	sd	s2,32(sp)
 7b8:	e852                	sd	s4,16(sp)
 7ba:	e456                	sd	s5,8(sp)
 7bc:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 7be:	8a4e                	mv	s4,s3
 7c0:	0009871b          	sext.w	a4,s3
 7c4:	6685                	lui	a3,0x1
 7c6:	00d77363          	bgeu	a4,a3,7cc <malloc+0x44>
 7ca:	6a05                	lui	s4,0x1
 7cc:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7d0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7d4:	00000917          	auipc	s2,0x0
 7d8:	13c90913          	addi	s2,s2,316 # 910 <freep>
  if(p == (char*)-1)
 7dc:	5afd                	li	s5,-1
 7de:	a091                	j	822 <malloc+0x9a>
 7e0:	f04a                	sd	s2,32(sp)
 7e2:	e852                	sd	s4,16(sp)
 7e4:	e456                	sd	s5,8(sp)
 7e6:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 7e8:	00000797          	auipc	a5,0x0
 7ec:	13078793          	addi	a5,a5,304 # 918 <base>
 7f0:	00000717          	auipc	a4,0x0
 7f4:	12f73023          	sd	a5,288(a4) # 910 <freep>
 7f8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7fa:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7fe:	b7c1                	j	7be <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 800:	6398                	ld	a4,0(a5)
 802:	e118                	sd	a4,0(a0)
 804:	a08d                	j	866 <malloc+0xde>
  hp->s.size = nu;
 806:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 80a:	0541                	addi	a0,a0,16
 80c:	00000097          	auipc	ra,0x0
 810:	efa080e7          	jalr	-262(ra) # 706 <free>
  return freep;
 814:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 818:	c13d                	beqz	a0,87e <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 81a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 81c:	4798                	lw	a4,8(a5)
 81e:	02977463          	bgeu	a4,s1,846 <malloc+0xbe>
    if(p == freep)
 822:	00093703          	ld	a4,0(s2)
 826:	853e                	mv	a0,a5
 828:	fef719e3          	bne	a4,a5,81a <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 82c:	8552                	mv	a0,s4
 82e:	00000097          	auipc	ra,0x0
 832:	b82080e7          	jalr	-1150(ra) # 3b0 <sbrk>
  if(p == (char*)-1)
 836:	fd5518e3          	bne	a0,s5,806 <malloc+0x7e>
        return 0;
 83a:	4501                	li	a0,0
 83c:	7902                	ld	s2,32(sp)
 83e:	6a42                	ld	s4,16(sp)
 840:	6aa2                	ld	s5,8(sp)
 842:	6b02                	ld	s6,0(sp)
 844:	a03d                	j	872 <malloc+0xea>
 846:	7902                	ld	s2,32(sp)
 848:	6a42                	ld	s4,16(sp)
 84a:	6aa2                	ld	s5,8(sp)
 84c:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 84e:	fae489e3          	beq	s1,a4,800 <malloc+0x78>
        p->s.size -= nunits;
 852:	4137073b          	subw	a4,a4,s3
 856:	c798                	sw	a4,8(a5)
        p += p->s.size;
 858:	02071693          	slli	a3,a4,0x20
 85c:	01c6d713          	srli	a4,a3,0x1c
 860:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 862:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 866:	00000717          	auipc	a4,0x0
 86a:	0aa73523          	sd	a0,170(a4) # 910 <freep>
      return (void*)(p + 1);
 86e:	01078513          	addi	a0,a5,16
  }
}
 872:	70e2                	ld	ra,56(sp)
 874:	7442                	ld	s0,48(sp)
 876:	74a2                	ld	s1,40(sp)
 878:	69e2                	ld	s3,24(sp)
 87a:	6121                	addi	sp,sp,64
 87c:	8082                	ret
 87e:	7902                	ld	s2,32(sp)
 880:	6a42                	ld	s4,16(sp)
 882:	6aa2                	ld	s5,8(sp)
 884:	6b02                	ld	s6,0(sp)
 886:	b7f5                	j	872 <malloc+0xea>
