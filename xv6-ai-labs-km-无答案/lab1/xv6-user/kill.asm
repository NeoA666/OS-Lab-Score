
xv6-user/_kill:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/include/stat.h"
#include "xv6-user/user.h"

int
main(int argc, char **argv)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	addi	s0,sp,32
  int i;

  if(argc < 2){
   8:	4785                	li	a5,1
   a:	02a7df63          	bge	a5,a0,48 <main+0x48>
   e:	e426                	sd	s1,8(sp)
  10:	e04a                	sd	s2,0(sp)
  12:	00858493          	addi	s1,a1,8
  16:	ffe5091b          	addiw	s2,a0,-2
  1a:	02091793          	slli	a5,s2,0x20
  1e:	01d7d913          	srli	s2,a5,0x1d
  22:	05c1                	addi	a1,a1,16
  24:	992e                	add	s2,s2,a1
    fprintf(2, "usage: kill pid...\n");
    exit(1);
  }
  for(i=1; i<argc; i++)
    kill(atoi(argv[i]));
  26:	6088                	ld	a0,0(s1)
  28:	00000097          	auipc	ra,0x0
  2c:	1e0080e7          	jalr	480(ra) # 208 <atoi>
  30:	00000097          	auipc	ra,0x0
  34:	31a080e7          	jalr	794(ra) # 34a <kill>
  for(i=1; i<argc; i++)
  38:	04a1                	addi	s1,s1,8
  3a:	ff2496e3          	bne	s1,s2,26 <main+0x26>
  exit(0);
  3e:	4501                	li	a0,0
  40:	00000097          	auipc	ra,0x0
  44:	2da080e7          	jalr	730(ra) # 31a <exit>
  48:	e426                	sd	s1,8(sp)
  4a:	e04a                	sd	s2,0(sp)
    fprintf(2, "usage: kill pid...\n");
  4c:	00001597          	auipc	a1,0x1
  50:	81c58593          	addi	a1,a1,-2020 # 868 <malloc+0x106>
  54:	4509                	li	a0,2
  56:	00000097          	auipc	ra,0x0
  5a:	626080e7          	jalr	1574(ra) # 67c <fprintf>
    exit(1);
  5e:	4505                	li	a0,1
  60:	00000097          	auipc	ra,0x0
  64:	2ba080e7          	jalr	698(ra) # 31a <exit>

0000000000000068 <strcpy>:
#include "kernel/include/fcntl.h"
#include "xv6-user/user.h"

char*
strcpy(char *s, const char *t)
{
  68:	1141                	addi	sp,sp,-16
  6a:	e422                	sd	s0,8(sp)
  6c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  6e:	87aa                	mv	a5,a0
  70:	0585                	addi	a1,a1,1
  72:	0785                	addi	a5,a5,1
  74:	fff5c703          	lbu	a4,-1(a1)
  78:	fee78fa3          	sb	a4,-1(a5)
  7c:	fb75                	bnez	a4,70 <strcpy+0x8>
    ;
  return os;
}
  7e:	6422                	ld	s0,8(sp)
  80:	0141                	addi	sp,sp,16
  82:	8082                	ret

0000000000000084 <strcat>:

char*
strcat(char *s, const char *t)
{
  84:	1141                	addi	sp,sp,-16
  86:	e422                	sd	s0,8(sp)
  88:	0800                	addi	s0,sp,16
  char *os = s;
  while(*s)
  8a:	00054783          	lbu	a5,0(a0)
  8e:	c385                	beqz	a5,ae <strcat+0x2a>
  90:	87aa                	mv	a5,a0
    s++;
  92:	0785                	addi	a5,a5,1
  while(*s)
  94:	0007c703          	lbu	a4,0(a5)
  98:	ff6d                	bnez	a4,92 <strcat+0xe>
  while((*s++ = *t++))
  9a:	0585                	addi	a1,a1,1
  9c:	0785                	addi	a5,a5,1
  9e:	fff5c703          	lbu	a4,-1(a1)
  a2:	fee78fa3          	sb	a4,-1(a5)
  a6:	fb75                	bnez	a4,9a <strcat+0x16>
    ;
  return os;
}
  a8:	6422                	ld	s0,8(sp)
  aa:	0141                	addi	sp,sp,16
  ac:	8082                	ret
  while(*s)
  ae:	87aa                	mv	a5,a0
  b0:	b7ed                	j	9a <strcat+0x16>

00000000000000b2 <strcmp>:


int
strcmp(const char *p, const char *q)
{
  b2:	1141                	addi	sp,sp,-16
  b4:	e422                	sd	s0,8(sp)
  b6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  b8:	00054783          	lbu	a5,0(a0)
  bc:	cb91                	beqz	a5,d0 <strcmp+0x1e>
  be:	0005c703          	lbu	a4,0(a1)
  c2:	00f71763          	bne	a4,a5,d0 <strcmp+0x1e>
    p++, q++;
  c6:	0505                	addi	a0,a0,1
  c8:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  ca:	00054783          	lbu	a5,0(a0)
  ce:	fbe5                	bnez	a5,be <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  d0:	0005c503          	lbu	a0,0(a1)
}
  d4:	40a7853b          	subw	a0,a5,a0
  d8:	6422                	ld	s0,8(sp)
  da:	0141                	addi	sp,sp,16
  dc:	8082                	ret

00000000000000de <strlen>:

uint
strlen(const char *s)
{
  de:	1141                	addi	sp,sp,-16
  e0:	e422                	sd	s0,8(sp)
  e2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  e4:	00054783          	lbu	a5,0(a0)
  e8:	cf91                	beqz	a5,104 <strlen+0x26>
  ea:	0505                	addi	a0,a0,1
  ec:	87aa                	mv	a5,a0
  ee:	86be                	mv	a3,a5
  f0:	0785                	addi	a5,a5,1
  f2:	fff7c703          	lbu	a4,-1(a5)
  f6:	ff65                	bnez	a4,ee <strlen+0x10>
  f8:	40a6853b          	subw	a0,a3,a0
  fc:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  fe:	6422                	ld	s0,8(sp)
 100:	0141                	addi	sp,sp,16
 102:	8082                	ret
  for(n = 0; s[n]; n++)
 104:	4501                	li	a0,0
 106:	bfe5                	j	fe <strlen+0x20>

0000000000000108 <memset>:

void*
memset(void *dst, int c, uint n)
{
 108:	1141                	addi	sp,sp,-16
 10a:	e422                	sd	s0,8(sp)
 10c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 10e:	ca19                	beqz	a2,124 <memset+0x1c>
 110:	87aa                	mv	a5,a0
 112:	1602                	slli	a2,a2,0x20
 114:	9201                	srli	a2,a2,0x20
 116:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 11a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 11e:	0785                	addi	a5,a5,1
 120:	fee79de3          	bne	a5,a4,11a <memset+0x12>
  }
  return dst;
}
 124:	6422                	ld	s0,8(sp)
 126:	0141                	addi	sp,sp,16
 128:	8082                	ret

000000000000012a <strchr>:

char*
strchr(const char *s, char c)
{
 12a:	1141                	addi	sp,sp,-16
 12c:	e422                	sd	s0,8(sp)
 12e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 130:	00054783          	lbu	a5,0(a0)
 134:	cb99                	beqz	a5,14a <strchr+0x20>
    if(*s == c)
 136:	00f58763          	beq	a1,a5,144 <strchr+0x1a>
  for(; *s; s++)
 13a:	0505                	addi	a0,a0,1
 13c:	00054783          	lbu	a5,0(a0)
 140:	fbfd                	bnez	a5,136 <strchr+0xc>
      return (char*)s;
  return 0;
 142:	4501                	li	a0,0
}
 144:	6422                	ld	s0,8(sp)
 146:	0141                	addi	sp,sp,16
 148:	8082                	ret
  return 0;
 14a:	4501                	li	a0,0
 14c:	bfe5                	j	144 <strchr+0x1a>

000000000000014e <gets>:

char*
gets(char *buf, int max)
{
 14e:	711d                	addi	sp,sp,-96
 150:	ec86                	sd	ra,88(sp)
 152:	e8a2                	sd	s0,80(sp)
 154:	e4a6                	sd	s1,72(sp)
 156:	e0ca                	sd	s2,64(sp)
 158:	fc4e                	sd	s3,56(sp)
 15a:	f852                	sd	s4,48(sp)
 15c:	f456                	sd	s5,40(sp)
 15e:	f05a                	sd	s6,32(sp)
 160:	ec5e                	sd	s7,24(sp)
 162:	1080                	addi	s0,sp,96
 164:	8baa                	mv	s7,a0
 166:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 168:	892a                	mv	s2,a0
 16a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 16c:	4aa9                	li	s5,10
 16e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 170:	89a6                	mv	s3,s1
 172:	2485                	addiw	s1,s1,1
 174:	0344d863          	bge	s1,s4,1a4 <gets+0x56>
    cc = read(0, &c, 1);
 178:	4605                	li	a2,1
 17a:	faf40593          	addi	a1,s0,-81
 17e:	4501                	li	a0,0
 180:	00000097          	auipc	ra,0x0
 184:	1b2080e7          	jalr	434(ra) # 332 <read>
    if(cc < 1)
 188:	00a05e63          	blez	a0,1a4 <gets+0x56>
    buf[i++] = c;
 18c:	faf44783          	lbu	a5,-81(s0)
 190:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 194:	01578763          	beq	a5,s5,1a2 <gets+0x54>
 198:	0905                	addi	s2,s2,1
 19a:	fd679be3          	bne	a5,s6,170 <gets+0x22>
    buf[i++] = c;
 19e:	89a6                	mv	s3,s1
 1a0:	a011                	j	1a4 <gets+0x56>
 1a2:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1a4:	99de                	add	s3,s3,s7
 1a6:	00098023          	sb	zero,0(s3)
  return buf;
}
 1aa:	855e                	mv	a0,s7
 1ac:	60e6                	ld	ra,88(sp)
 1ae:	6446                	ld	s0,80(sp)
 1b0:	64a6                	ld	s1,72(sp)
 1b2:	6906                	ld	s2,64(sp)
 1b4:	79e2                	ld	s3,56(sp)
 1b6:	7a42                	ld	s4,48(sp)
 1b8:	7aa2                	ld	s5,40(sp)
 1ba:	7b02                	ld	s6,32(sp)
 1bc:	6be2                	ld	s7,24(sp)
 1be:	6125                	addi	sp,sp,96
 1c0:	8082                	ret

00000000000001c2 <stat>:

int
stat(const char *n, struct stat *st)
{
 1c2:	1101                	addi	sp,sp,-32
 1c4:	ec06                	sd	ra,24(sp)
 1c6:	e822                	sd	s0,16(sp)
 1c8:	e04a                	sd	s2,0(sp)
 1ca:	1000                	addi	s0,sp,32
 1cc:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1ce:	4581                	li	a1,0
 1d0:	00000097          	auipc	ra,0x0
 1d4:	18a080e7          	jalr	394(ra) # 35a <open>
  if(fd < 0)
 1d8:	02054663          	bltz	a0,204 <stat+0x42>
 1dc:	e426                	sd	s1,8(sp)
 1de:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1e0:	85ca                	mv	a1,s2
 1e2:	00000097          	auipc	ra,0x0
 1e6:	180080e7          	jalr	384(ra) # 362 <fstat>
 1ea:	892a                	mv	s2,a0
  close(fd);
 1ec:	8526                	mv	a0,s1
 1ee:	00000097          	auipc	ra,0x0
 1f2:	154080e7          	jalr	340(ra) # 342 <close>
  return r;
 1f6:	64a2                	ld	s1,8(sp)
}
 1f8:	854a                	mv	a0,s2
 1fa:	60e2                	ld	ra,24(sp)
 1fc:	6442                	ld	s0,16(sp)
 1fe:	6902                	ld	s2,0(sp)
 200:	6105                	addi	sp,sp,32
 202:	8082                	ret
    return -1;
 204:	597d                	li	s2,-1
 206:	bfcd                	j	1f8 <stat+0x36>

0000000000000208 <atoi>:

int
atoi(const char *s)
{
 208:	1141                	addi	sp,sp,-16
 20a:	e422                	sd	s0,8(sp)
 20c:	0800                	addi	s0,sp,16
  int n;
  int neg = 1;
  if (*s == '-') {
 20e:	00054703          	lbu	a4,0(a0)
 212:	02d00793          	li	a5,45
  int neg = 1;
 216:	4585                	li	a1,1
  if (*s == '-') {
 218:	04f70363          	beq	a4,a5,25e <atoi+0x56>
    s++;
    neg = -1;
  }
  n = 0;
  while('0' <= *s && *s <= '9')
 21c:	00054703          	lbu	a4,0(a0)
 220:	fd07079b          	addiw	a5,a4,-48
 224:	0ff7f793          	zext.b	a5,a5
 228:	46a5                	li	a3,9
 22a:	02f6ed63          	bltu	a3,a5,264 <atoi+0x5c>
  n = 0;
 22e:	4681                	li	a3,0
  while('0' <= *s && *s <= '9')
 230:	4625                	li	a2,9
    n = n*10 + *s++ - '0';
 232:	0505                	addi	a0,a0,1
 234:	0026979b          	slliw	a5,a3,0x2
 238:	9fb5                	addw	a5,a5,a3
 23a:	0017979b          	slliw	a5,a5,0x1
 23e:	9fb9                	addw	a5,a5,a4
 240:	fd07869b          	addiw	a3,a5,-48
  while('0' <= *s && *s <= '9')
 244:	00054703          	lbu	a4,0(a0)
 248:	fd07079b          	addiw	a5,a4,-48
 24c:	0ff7f793          	zext.b	a5,a5
 250:	fef671e3          	bgeu	a2,a5,232 <atoi+0x2a>
  return n * neg;
}
 254:	02d5853b          	mulw	a0,a1,a3
 258:	6422                	ld	s0,8(sp)
 25a:	0141                	addi	sp,sp,16
 25c:	8082                	ret
    s++;
 25e:	0505                	addi	a0,a0,1
    neg = -1;
 260:	55fd                	li	a1,-1
 262:	bf6d                	j	21c <atoi+0x14>
  n = 0;
 264:	4681                	li	a3,0
 266:	b7fd                	j	254 <atoi+0x4c>

0000000000000268 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 268:	1141                	addi	sp,sp,-16
 26a:	e422                	sd	s0,8(sp)
 26c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 26e:	02b57463          	bgeu	a0,a1,296 <memmove+0x2e>
    while(n-- > 0)
 272:	00c05f63          	blez	a2,290 <memmove+0x28>
 276:	1602                	slli	a2,a2,0x20
 278:	9201                	srli	a2,a2,0x20
 27a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 27e:	872a                	mv	a4,a0
      *dst++ = *src++;
 280:	0585                	addi	a1,a1,1
 282:	0705                	addi	a4,a4,1
 284:	fff5c683          	lbu	a3,-1(a1)
 288:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 28c:	fef71ae3          	bne	a4,a5,280 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 290:	6422                	ld	s0,8(sp)
 292:	0141                	addi	sp,sp,16
 294:	8082                	ret
    dst += n;
 296:	00c50733          	add	a4,a0,a2
    src += n;
 29a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 29c:	fec05ae3          	blez	a2,290 <memmove+0x28>
 2a0:	fff6079b          	addiw	a5,a2,-1
 2a4:	1782                	slli	a5,a5,0x20
 2a6:	9381                	srli	a5,a5,0x20
 2a8:	fff7c793          	not	a5,a5
 2ac:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2ae:	15fd                	addi	a1,a1,-1
 2b0:	177d                	addi	a4,a4,-1
 2b2:	0005c683          	lbu	a3,0(a1)
 2b6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2ba:	fee79ae3          	bne	a5,a4,2ae <memmove+0x46>
 2be:	bfc9                	j	290 <memmove+0x28>

00000000000002c0 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2c0:	1141                	addi	sp,sp,-16
 2c2:	e422                	sd	s0,8(sp)
 2c4:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2c6:	ca05                	beqz	a2,2f6 <memcmp+0x36>
 2c8:	fff6069b          	addiw	a3,a2,-1
 2cc:	1682                	slli	a3,a3,0x20
 2ce:	9281                	srli	a3,a3,0x20
 2d0:	0685                	addi	a3,a3,1
 2d2:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2d4:	00054783          	lbu	a5,0(a0)
 2d8:	0005c703          	lbu	a4,0(a1)
 2dc:	00e79863          	bne	a5,a4,2ec <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2e0:	0505                	addi	a0,a0,1
    p2++;
 2e2:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2e4:	fed518e3          	bne	a0,a3,2d4 <memcmp+0x14>
  }
  return 0;
 2e8:	4501                	li	a0,0
 2ea:	a019                	j	2f0 <memcmp+0x30>
      return *p1 - *p2;
 2ec:	40e7853b          	subw	a0,a5,a4
}
 2f0:	6422                	ld	s0,8(sp)
 2f2:	0141                	addi	sp,sp,16
 2f4:	8082                	ret
  return 0;
 2f6:	4501                	li	a0,0
 2f8:	bfe5                	j	2f0 <memcmp+0x30>

00000000000002fa <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2fa:	1141                	addi	sp,sp,-16
 2fc:	e406                	sd	ra,8(sp)
 2fe:	e022                	sd	s0,0(sp)
 300:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 302:	00000097          	auipc	ra,0x0
 306:	f66080e7          	jalr	-154(ra) # 268 <memmove>
}
 30a:	60a2                	ld	ra,8(sp)
 30c:	6402                	ld	s0,0(sp)
 30e:	0141                	addi	sp,sp,16
 310:	8082                	ret

0000000000000312 <fork>:
# generated by usys.pl - do not edit
#include "kernel/include/sysnum.h"
.global fork
fork:
 li a7, SYS_fork
 312:	4885                	li	a7,1
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <exit>:
.global exit
exit:
 li a7, SYS_exit
 31a:	4889                	li	a7,2
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <wait>:
.global wait
wait:
 li a7, SYS_wait
 322:	488d                	li	a7,3
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 32a:	4891                	li	a7,4
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <read>:
.global read
read:
 li a7, SYS_read
 332:	4895                	li	a7,5
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <write>:
.global write
write:
 li a7, SYS_write
 33a:	48c1                	li	a7,16
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <close>:
.global close
close:
 li a7, SYS_close
 342:	48d5                	li	a7,21
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <kill>:
.global kill
kill:
 li a7, SYS_kill
 34a:	4899                	li	a7,6
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <exec>:
.global exec
exec:
 li a7, SYS_exec
 352:	489d                	li	a7,7
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <open>:
.global open
open:
 li a7, SYS_open
 35a:	48bd                	li	a7,15
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 362:	48a1                	li	a7,8
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 36a:	48d1                	li	a7,20
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 372:	48a5                	li	a7,9
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <dup>:
.global dup
dup:
 li a7, SYS_dup
 37a:	48a9                	li	a7,10
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 382:	48ad                	li	a7,11
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 38a:	48b1                	li	a7,12
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 392:	48b5                	li	a7,13
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 39a:	48b9                	li	a7,14
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <test_proc>:
.global test_proc
test_proc:
 li a7, SYS_test_proc
 3a2:	48d9                	li	a7,22
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <dev>:
.global dev
dev:
 li a7, SYS_dev
 3aa:	48dd                	li	a7,23
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <readdir>:
.global readdir
readdir:
 li a7, SYS_readdir
 3b2:	48e1                	li	a7,24
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <getcwd>:
.global getcwd
getcwd:
 li a7, SYS_getcwd
 3ba:	48e5                	li	a7,25
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <remove>:
.global remove
remove:
 li a7, SYS_remove
 3c2:	48c5                	li	a7,17
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <trace>:
.global trace
trace:
 li a7, SYS_trace
 3ca:	48c9                	li	a7,18
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <sysinfo>:
.global sysinfo
sysinfo:
 li a7, SYS_sysinfo
 3d2:	48cd                	li	a7,19
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <rename>:
.global rename
rename:
 li a7, SYS_rename
 3da:	48e9                	li	a7,26
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3e2:	1101                	addi	sp,sp,-32
 3e4:	ec06                	sd	ra,24(sp)
 3e6:	e822                	sd	s0,16(sp)
 3e8:	1000                	addi	s0,sp,32
 3ea:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3ee:	4605                	li	a2,1
 3f0:	fef40593          	addi	a1,s0,-17
 3f4:	00000097          	auipc	ra,0x0
 3f8:	f46080e7          	jalr	-186(ra) # 33a <write>
}
 3fc:	60e2                	ld	ra,24(sp)
 3fe:	6442                	ld	s0,16(sp)
 400:	6105                	addi	sp,sp,32
 402:	8082                	ret

0000000000000404 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 404:	7139                	addi	sp,sp,-64
 406:	fc06                	sd	ra,56(sp)
 408:	f822                	sd	s0,48(sp)
 40a:	f426                	sd	s1,40(sp)
 40c:	0080                	addi	s0,sp,64
 40e:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 410:	c299                	beqz	a3,416 <printint+0x12>
 412:	0805cb63          	bltz	a1,4a8 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 416:	2581                	sext.w	a1,a1
  neg = 0;
 418:	4881                	li	a7,0
 41a:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 41e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 420:	2601                	sext.w	a2,a2
 422:	00000517          	auipc	a0,0x0
 426:	4be50513          	addi	a0,a0,1214 # 8e0 <digits>
 42a:	883a                	mv	a6,a4
 42c:	2705                	addiw	a4,a4,1
 42e:	02c5f7bb          	remuw	a5,a1,a2
 432:	1782                	slli	a5,a5,0x20
 434:	9381                	srli	a5,a5,0x20
 436:	97aa                	add	a5,a5,a0
 438:	0007c783          	lbu	a5,0(a5)
 43c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 440:	0005879b          	sext.w	a5,a1
 444:	02c5d5bb          	divuw	a1,a1,a2
 448:	0685                	addi	a3,a3,1
 44a:	fec7f0e3          	bgeu	a5,a2,42a <printint+0x26>
  if(neg)
 44e:	00088c63          	beqz	a7,466 <printint+0x62>
    buf[i++] = '-';
 452:	fd070793          	addi	a5,a4,-48
 456:	00878733          	add	a4,a5,s0
 45a:	02d00793          	li	a5,45
 45e:	fef70823          	sb	a5,-16(a4)
 462:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 466:	02e05c63          	blez	a4,49e <printint+0x9a>
 46a:	f04a                	sd	s2,32(sp)
 46c:	ec4e                	sd	s3,24(sp)
 46e:	fc040793          	addi	a5,s0,-64
 472:	00e78933          	add	s2,a5,a4
 476:	fff78993          	addi	s3,a5,-1
 47a:	99ba                	add	s3,s3,a4
 47c:	377d                	addiw	a4,a4,-1
 47e:	1702                	slli	a4,a4,0x20
 480:	9301                	srli	a4,a4,0x20
 482:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 486:	fff94583          	lbu	a1,-1(s2)
 48a:	8526                	mv	a0,s1
 48c:	00000097          	auipc	ra,0x0
 490:	f56080e7          	jalr	-170(ra) # 3e2 <putc>
  while(--i >= 0)
 494:	197d                	addi	s2,s2,-1
 496:	ff3918e3          	bne	s2,s3,486 <printint+0x82>
 49a:	7902                	ld	s2,32(sp)
 49c:	69e2                	ld	s3,24(sp)
}
 49e:	70e2                	ld	ra,56(sp)
 4a0:	7442                	ld	s0,48(sp)
 4a2:	74a2                	ld	s1,40(sp)
 4a4:	6121                	addi	sp,sp,64
 4a6:	8082                	ret
    x = -xx;
 4a8:	40b005bb          	negw	a1,a1
    neg = 1;
 4ac:	4885                	li	a7,1
    x = -xx;
 4ae:	b7b5                	j	41a <printint+0x16>

00000000000004b0 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4b0:	715d                	addi	sp,sp,-80
 4b2:	e486                	sd	ra,72(sp)
 4b4:	e0a2                	sd	s0,64(sp)
 4b6:	f84a                	sd	s2,48(sp)
 4b8:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4ba:	0005c903          	lbu	s2,0(a1)
 4be:	1a090a63          	beqz	s2,672 <vprintf+0x1c2>
 4c2:	fc26                	sd	s1,56(sp)
 4c4:	f44e                	sd	s3,40(sp)
 4c6:	f052                	sd	s4,32(sp)
 4c8:	ec56                	sd	s5,24(sp)
 4ca:	e85a                	sd	s6,16(sp)
 4cc:	e45e                	sd	s7,8(sp)
 4ce:	8aaa                	mv	s5,a0
 4d0:	8bb2                	mv	s7,a2
 4d2:	00158493          	addi	s1,a1,1
  state = 0;
 4d6:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4d8:	02500a13          	li	s4,37
 4dc:	4b55                	li	s6,21
 4de:	a839                	j	4fc <vprintf+0x4c>
        putc(fd, c);
 4e0:	85ca                	mv	a1,s2
 4e2:	8556                	mv	a0,s5
 4e4:	00000097          	auipc	ra,0x0
 4e8:	efe080e7          	jalr	-258(ra) # 3e2 <putc>
 4ec:	a019                	j	4f2 <vprintf+0x42>
    } else if(state == '%'){
 4ee:	01498d63          	beq	s3,s4,508 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 4f2:	0485                	addi	s1,s1,1
 4f4:	fff4c903          	lbu	s2,-1(s1)
 4f8:	16090763          	beqz	s2,666 <vprintf+0x1b6>
    if(state == 0){
 4fc:	fe0999e3          	bnez	s3,4ee <vprintf+0x3e>
      if(c == '%'){
 500:	ff4910e3          	bne	s2,s4,4e0 <vprintf+0x30>
        state = '%';
 504:	89d2                	mv	s3,s4
 506:	b7f5                	j	4f2 <vprintf+0x42>
      if(c == 'd'){
 508:	13490463          	beq	s2,s4,630 <vprintf+0x180>
 50c:	f9d9079b          	addiw	a5,s2,-99
 510:	0ff7f793          	zext.b	a5,a5
 514:	12fb6763          	bltu	s6,a5,642 <vprintf+0x192>
 518:	f9d9079b          	addiw	a5,s2,-99
 51c:	0ff7f713          	zext.b	a4,a5
 520:	12eb6163          	bltu	s6,a4,642 <vprintf+0x192>
 524:	00271793          	slli	a5,a4,0x2
 528:	00000717          	auipc	a4,0x0
 52c:	36070713          	addi	a4,a4,864 # 888 <malloc+0x126>
 530:	97ba                	add	a5,a5,a4
 532:	439c                	lw	a5,0(a5)
 534:	97ba                	add	a5,a5,a4
 536:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 538:	008b8913          	addi	s2,s7,8
 53c:	4685                	li	a3,1
 53e:	4629                	li	a2,10
 540:	000ba583          	lw	a1,0(s7)
 544:	8556                	mv	a0,s5
 546:	00000097          	auipc	ra,0x0
 54a:	ebe080e7          	jalr	-322(ra) # 404 <printint>
 54e:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 550:	4981                	li	s3,0
 552:	b745                	j	4f2 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 554:	008b8913          	addi	s2,s7,8
 558:	4681                	li	a3,0
 55a:	4629                	li	a2,10
 55c:	000ba583          	lw	a1,0(s7)
 560:	8556                	mv	a0,s5
 562:	00000097          	auipc	ra,0x0
 566:	ea2080e7          	jalr	-350(ra) # 404 <printint>
 56a:	8bca                	mv	s7,s2
      state = 0;
 56c:	4981                	li	s3,0
 56e:	b751                	j	4f2 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 570:	008b8913          	addi	s2,s7,8
 574:	4681                	li	a3,0
 576:	4641                	li	a2,16
 578:	000ba583          	lw	a1,0(s7)
 57c:	8556                	mv	a0,s5
 57e:	00000097          	auipc	ra,0x0
 582:	e86080e7          	jalr	-378(ra) # 404 <printint>
 586:	8bca                	mv	s7,s2
      state = 0;
 588:	4981                	li	s3,0
 58a:	b7a5                	j	4f2 <vprintf+0x42>
 58c:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 58e:	008b8c13          	addi	s8,s7,8
 592:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 596:	03000593          	li	a1,48
 59a:	8556                	mv	a0,s5
 59c:	00000097          	auipc	ra,0x0
 5a0:	e46080e7          	jalr	-442(ra) # 3e2 <putc>
  putc(fd, 'x');
 5a4:	07800593          	li	a1,120
 5a8:	8556                	mv	a0,s5
 5aa:	00000097          	auipc	ra,0x0
 5ae:	e38080e7          	jalr	-456(ra) # 3e2 <putc>
 5b2:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5b4:	00000b97          	auipc	s7,0x0
 5b8:	32cb8b93          	addi	s7,s7,812 # 8e0 <digits>
 5bc:	03c9d793          	srli	a5,s3,0x3c
 5c0:	97de                	add	a5,a5,s7
 5c2:	0007c583          	lbu	a1,0(a5)
 5c6:	8556                	mv	a0,s5
 5c8:	00000097          	auipc	ra,0x0
 5cc:	e1a080e7          	jalr	-486(ra) # 3e2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5d0:	0992                	slli	s3,s3,0x4
 5d2:	397d                	addiw	s2,s2,-1
 5d4:	fe0914e3          	bnez	s2,5bc <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 5d8:	8be2                	mv	s7,s8
      state = 0;
 5da:	4981                	li	s3,0
 5dc:	6c02                	ld	s8,0(sp)
 5de:	bf11                	j	4f2 <vprintf+0x42>
        s = va_arg(ap, char*);
 5e0:	008b8993          	addi	s3,s7,8
 5e4:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 5e8:	02090163          	beqz	s2,60a <vprintf+0x15a>
        while(*s != 0){
 5ec:	00094583          	lbu	a1,0(s2)
 5f0:	c9a5                	beqz	a1,660 <vprintf+0x1b0>
          putc(fd, *s);
 5f2:	8556                	mv	a0,s5
 5f4:	00000097          	auipc	ra,0x0
 5f8:	dee080e7          	jalr	-530(ra) # 3e2 <putc>
          s++;
 5fc:	0905                	addi	s2,s2,1
        while(*s != 0){
 5fe:	00094583          	lbu	a1,0(s2)
 602:	f9e5                	bnez	a1,5f2 <vprintf+0x142>
        s = va_arg(ap, char*);
 604:	8bce                	mv	s7,s3
      state = 0;
 606:	4981                	li	s3,0
 608:	b5ed                	j	4f2 <vprintf+0x42>
          s = "(null)";
 60a:	00000917          	auipc	s2,0x0
 60e:	27690913          	addi	s2,s2,630 # 880 <malloc+0x11e>
        while(*s != 0){
 612:	02800593          	li	a1,40
 616:	bff1                	j	5f2 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 618:	008b8913          	addi	s2,s7,8
 61c:	000bc583          	lbu	a1,0(s7)
 620:	8556                	mv	a0,s5
 622:	00000097          	auipc	ra,0x0
 626:	dc0080e7          	jalr	-576(ra) # 3e2 <putc>
 62a:	8bca                	mv	s7,s2
      state = 0;
 62c:	4981                	li	s3,0
 62e:	b5d1                	j	4f2 <vprintf+0x42>
        putc(fd, c);
 630:	02500593          	li	a1,37
 634:	8556                	mv	a0,s5
 636:	00000097          	auipc	ra,0x0
 63a:	dac080e7          	jalr	-596(ra) # 3e2 <putc>
      state = 0;
 63e:	4981                	li	s3,0
 640:	bd4d                	j	4f2 <vprintf+0x42>
        putc(fd, '%');
 642:	02500593          	li	a1,37
 646:	8556                	mv	a0,s5
 648:	00000097          	auipc	ra,0x0
 64c:	d9a080e7          	jalr	-614(ra) # 3e2 <putc>
        putc(fd, c);
 650:	85ca                	mv	a1,s2
 652:	8556                	mv	a0,s5
 654:	00000097          	auipc	ra,0x0
 658:	d8e080e7          	jalr	-626(ra) # 3e2 <putc>
      state = 0;
 65c:	4981                	li	s3,0
 65e:	bd51                	j	4f2 <vprintf+0x42>
        s = va_arg(ap, char*);
 660:	8bce                	mv	s7,s3
      state = 0;
 662:	4981                	li	s3,0
 664:	b579                	j	4f2 <vprintf+0x42>
 666:	74e2                	ld	s1,56(sp)
 668:	79a2                	ld	s3,40(sp)
 66a:	7a02                	ld	s4,32(sp)
 66c:	6ae2                	ld	s5,24(sp)
 66e:	6b42                	ld	s6,16(sp)
 670:	6ba2                	ld	s7,8(sp)
    }
  }
}
 672:	60a6                	ld	ra,72(sp)
 674:	6406                	ld	s0,64(sp)
 676:	7942                	ld	s2,48(sp)
 678:	6161                	addi	sp,sp,80
 67a:	8082                	ret

000000000000067c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 67c:	715d                	addi	sp,sp,-80
 67e:	ec06                	sd	ra,24(sp)
 680:	e822                	sd	s0,16(sp)
 682:	1000                	addi	s0,sp,32
 684:	e010                	sd	a2,0(s0)
 686:	e414                	sd	a3,8(s0)
 688:	e818                	sd	a4,16(s0)
 68a:	ec1c                	sd	a5,24(s0)
 68c:	03043023          	sd	a6,32(s0)
 690:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 694:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 698:	8622                	mv	a2,s0
 69a:	00000097          	auipc	ra,0x0
 69e:	e16080e7          	jalr	-490(ra) # 4b0 <vprintf>
}
 6a2:	60e2                	ld	ra,24(sp)
 6a4:	6442                	ld	s0,16(sp)
 6a6:	6161                	addi	sp,sp,80
 6a8:	8082                	ret

00000000000006aa <printf>:

void
printf(const char *fmt, ...)
{
 6aa:	711d                	addi	sp,sp,-96
 6ac:	ec06                	sd	ra,24(sp)
 6ae:	e822                	sd	s0,16(sp)
 6b0:	1000                	addi	s0,sp,32
 6b2:	e40c                	sd	a1,8(s0)
 6b4:	e810                	sd	a2,16(s0)
 6b6:	ec14                	sd	a3,24(s0)
 6b8:	f018                	sd	a4,32(s0)
 6ba:	f41c                	sd	a5,40(s0)
 6bc:	03043823          	sd	a6,48(s0)
 6c0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6c4:	00840613          	addi	a2,s0,8
 6c8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6cc:	85aa                	mv	a1,a0
 6ce:	4505                	li	a0,1
 6d0:	00000097          	auipc	ra,0x0
 6d4:	de0080e7          	jalr	-544(ra) # 4b0 <vprintf>
}
 6d8:	60e2                	ld	ra,24(sp)
 6da:	6442                	ld	s0,16(sp)
 6dc:	6125                	addi	sp,sp,96
 6de:	8082                	ret

00000000000006e0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6e0:	1141                	addi	sp,sp,-16
 6e2:	e422                	sd	s0,8(sp)
 6e4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6e6:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6ea:	00000797          	auipc	a5,0x0
 6ee:	20e7b783          	ld	a5,526(a5) # 8f8 <freep>
 6f2:	a02d                	j	71c <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6f4:	4618                	lw	a4,8(a2)
 6f6:	9f2d                	addw	a4,a4,a1
 6f8:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6fc:	6398                	ld	a4,0(a5)
 6fe:	6310                	ld	a2,0(a4)
 700:	a83d                	j	73e <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 702:	ff852703          	lw	a4,-8(a0)
 706:	9f31                	addw	a4,a4,a2
 708:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 70a:	ff053683          	ld	a3,-16(a0)
 70e:	a091                	j	752 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 710:	6398                	ld	a4,0(a5)
 712:	00e7e463          	bltu	a5,a4,71a <free+0x3a>
 716:	00e6ea63          	bltu	a3,a4,72a <free+0x4a>
{
 71a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 71c:	fed7fae3          	bgeu	a5,a3,710 <free+0x30>
 720:	6398                	ld	a4,0(a5)
 722:	00e6e463          	bltu	a3,a4,72a <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 726:	fee7eae3          	bltu	a5,a4,71a <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 72a:	ff852583          	lw	a1,-8(a0)
 72e:	6390                	ld	a2,0(a5)
 730:	02059813          	slli	a6,a1,0x20
 734:	01c85713          	srli	a4,a6,0x1c
 738:	9736                	add	a4,a4,a3
 73a:	fae60de3          	beq	a2,a4,6f4 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 73e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 742:	4790                	lw	a2,8(a5)
 744:	02061593          	slli	a1,a2,0x20
 748:	01c5d713          	srli	a4,a1,0x1c
 74c:	973e                	add	a4,a4,a5
 74e:	fae68ae3          	beq	a3,a4,702 <free+0x22>
    p->s.ptr = bp->s.ptr;
 752:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 754:	00000717          	auipc	a4,0x0
 758:	1af73223          	sd	a5,420(a4) # 8f8 <freep>
}
 75c:	6422                	ld	s0,8(sp)
 75e:	0141                	addi	sp,sp,16
 760:	8082                	ret

0000000000000762 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 762:	7139                	addi	sp,sp,-64
 764:	fc06                	sd	ra,56(sp)
 766:	f822                	sd	s0,48(sp)
 768:	f426                	sd	s1,40(sp)
 76a:	ec4e                	sd	s3,24(sp)
 76c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 76e:	02051493          	slli	s1,a0,0x20
 772:	9081                	srli	s1,s1,0x20
 774:	04bd                	addi	s1,s1,15
 776:	8091                	srli	s1,s1,0x4
 778:	0014899b          	addiw	s3,s1,1
 77c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 77e:	00000517          	auipc	a0,0x0
 782:	17a53503          	ld	a0,378(a0) # 8f8 <freep>
 786:	c915                	beqz	a0,7ba <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 788:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 78a:	4798                	lw	a4,8(a5)
 78c:	08977e63          	bgeu	a4,s1,828 <malloc+0xc6>
 790:	f04a                	sd	s2,32(sp)
 792:	e852                	sd	s4,16(sp)
 794:	e456                	sd	s5,8(sp)
 796:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 798:	8a4e                	mv	s4,s3
 79a:	0009871b          	sext.w	a4,s3
 79e:	6685                	lui	a3,0x1
 7a0:	00d77363          	bgeu	a4,a3,7a6 <malloc+0x44>
 7a4:	6a05                	lui	s4,0x1
 7a6:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7aa:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7ae:	00000917          	auipc	s2,0x0
 7b2:	14a90913          	addi	s2,s2,330 # 8f8 <freep>
  if(p == (char*)-1)
 7b6:	5afd                	li	s5,-1
 7b8:	a091                	j	7fc <malloc+0x9a>
 7ba:	f04a                	sd	s2,32(sp)
 7bc:	e852                	sd	s4,16(sp)
 7be:	e456                	sd	s5,8(sp)
 7c0:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 7c2:	00000797          	auipc	a5,0x0
 7c6:	13e78793          	addi	a5,a5,318 # 900 <base>
 7ca:	00000717          	auipc	a4,0x0
 7ce:	12f73723          	sd	a5,302(a4) # 8f8 <freep>
 7d2:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7d4:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7d8:	b7c1                	j	798 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 7da:	6398                	ld	a4,0(a5)
 7dc:	e118                	sd	a4,0(a0)
 7de:	a08d                	j	840 <malloc+0xde>
  hp->s.size = nu;
 7e0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7e4:	0541                	addi	a0,a0,16
 7e6:	00000097          	auipc	ra,0x0
 7ea:	efa080e7          	jalr	-262(ra) # 6e0 <free>
  return freep;
 7ee:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7f2:	c13d                	beqz	a0,858 <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7f4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7f6:	4798                	lw	a4,8(a5)
 7f8:	02977463          	bgeu	a4,s1,820 <malloc+0xbe>
    if(p == freep)
 7fc:	00093703          	ld	a4,0(s2)
 800:	853e                	mv	a0,a5
 802:	fef719e3          	bne	a4,a5,7f4 <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 806:	8552                	mv	a0,s4
 808:	00000097          	auipc	ra,0x0
 80c:	b82080e7          	jalr	-1150(ra) # 38a <sbrk>
  if(p == (char*)-1)
 810:	fd5518e3          	bne	a0,s5,7e0 <malloc+0x7e>
        return 0;
 814:	4501                	li	a0,0
 816:	7902                	ld	s2,32(sp)
 818:	6a42                	ld	s4,16(sp)
 81a:	6aa2                	ld	s5,8(sp)
 81c:	6b02                	ld	s6,0(sp)
 81e:	a03d                	j	84c <malloc+0xea>
 820:	7902                	ld	s2,32(sp)
 822:	6a42                	ld	s4,16(sp)
 824:	6aa2                	ld	s5,8(sp)
 826:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 828:	fae489e3          	beq	s1,a4,7da <malloc+0x78>
        p->s.size -= nunits;
 82c:	4137073b          	subw	a4,a4,s3
 830:	c798                	sw	a4,8(a5)
        p += p->s.size;
 832:	02071693          	slli	a3,a4,0x20
 836:	01c6d713          	srli	a4,a3,0x1c
 83a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 83c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 840:	00000717          	auipc	a4,0x0
 844:	0aa73c23          	sd	a0,184(a4) # 8f8 <freep>
      return (void*)(p + 1);
 848:	01078513          	addi	a0,a5,16
  }
}
 84c:	70e2                	ld	ra,56(sp)
 84e:	7442                	ld	s0,48(sp)
 850:	74a2                	ld	s1,40(sp)
 852:	69e2                	ld	s3,24(sp)
 854:	6121                	addi	sp,sp,64
 856:	8082                	ret
 858:	7902                	ld	s2,32(sp)
 85a:	6a42                	ld	s4,16(sp)
 85c:	6aa2                	ld	s5,8(sp)
 85e:	6b02                	ld	s6,0(sp)
 860:	b7f5                	j	84c <malloc+0xea>
