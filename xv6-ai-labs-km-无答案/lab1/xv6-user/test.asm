
xv6-user/_test:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/include/stat.h"
#include "kernel/include/sysinfo.h"
#include "xv6-user/user.h"

int main()
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	addi	s0,sp,32
    struct sysinfo info;
    if (sysinfo(&info) < 0) {
   8:	fe040513          	addi	a0,s0,-32
   c:	00000097          	auipc	ra,0x0
  10:	3bc080e7          	jalr	956(ra) # 3c8 <sysinfo>
  14:	02054c63          	bltz	a0,4c <main+0x4c>
        printf("sysinfo fail!\n");
    } else {
        printf("memory left: %d KB\n", info.freemem >> 10);
  18:	fe043583          	ld	a1,-32(s0)
  1c:	81a9                	srli	a1,a1,0xa
  1e:	00001517          	auipc	a0,0x1
  22:	85250513          	addi	a0,a0,-1966 # 870 <malloc+0x118>
  26:	00000097          	auipc	ra,0x0
  2a:	67a080e7          	jalr	1658(ra) # 6a0 <printf>
        printf("process amount: %d\n", info.nproc);
  2e:	fe843583          	ld	a1,-24(s0)
  32:	00001517          	auipc	a0,0x1
  36:	85650513          	addi	a0,a0,-1962 # 888 <malloc+0x130>
  3a:	00000097          	auipc	ra,0x0
  3e:	666080e7          	jalr	1638(ra) # 6a0 <printf>
    }
    exit(0);
  42:	4501                	li	a0,0
  44:	00000097          	auipc	ra,0x0
  48:	2cc080e7          	jalr	716(ra) # 310 <exit>
        printf("sysinfo fail!\n");
  4c:	00001517          	auipc	a0,0x1
  50:	80c50513          	addi	a0,a0,-2036 # 858 <malloc+0x100>
  54:	00000097          	auipc	ra,0x0
  58:	64c080e7          	jalr	1612(ra) # 6a0 <printf>
  5c:	b7dd                	j	42 <main+0x42>

000000000000005e <strcpy>:
#include "kernel/include/fcntl.h"
#include "xv6-user/user.h"

char*
strcpy(char *s, const char *t)
{
  5e:	1141                	addi	sp,sp,-16
  60:	e422                	sd	s0,8(sp)
  62:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  64:	87aa                	mv	a5,a0
  66:	0585                	addi	a1,a1,1
  68:	0785                	addi	a5,a5,1
  6a:	fff5c703          	lbu	a4,-1(a1)
  6e:	fee78fa3          	sb	a4,-1(a5)
  72:	fb75                	bnez	a4,66 <strcpy+0x8>
    ;
  return os;
}
  74:	6422                	ld	s0,8(sp)
  76:	0141                	addi	sp,sp,16
  78:	8082                	ret

000000000000007a <strcat>:

char*
strcat(char *s, const char *t)
{
  7a:	1141                	addi	sp,sp,-16
  7c:	e422                	sd	s0,8(sp)
  7e:	0800                	addi	s0,sp,16
  char *os = s;
  while(*s)
  80:	00054783          	lbu	a5,0(a0)
  84:	c385                	beqz	a5,a4 <strcat+0x2a>
  86:	87aa                	mv	a5,a0
    s++;
  88:	0785                	addi	a5,a5,1
  while(*s)
  8a:	0007c703          	lbu	a4,0(a5)
  8e:	ff6d                	bnez	a4,88 <strcat+0xe>
  while((*s++ = *t++))
  90:	0585                	addi	a1,a1,1
  92:	0785                	addi	a5,a5,1
  94:	fff5c703          	lbu	a4,-1(a1)
  98:	fee78fa3          	sb	a4,-1(a5)
  9c:	fb75                	bnez	a4,90 <strcat+0x16>
    ;
  return os;
}
  9e:	6422                	ld	s0,8(sp)
  a0:	0141                	addi	sp,sp,16
  a2:	8082                	ret
  while(*s)
  a4:	87aa                	mv	a5,a0
  a6:	b7ed                	j	90 <strcat+0x16>

00000000000000a8 <strcmp>:


int
strcmp(const char *p, const char *q)
{
  a8:	1141                	addi	sp,sp,-16
  aa:	e422                	sd	s0,8(sp)
  ac:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  ae:	00054783          	lbu	a5,0(a0)
  b2:	cb91                	beqz	a5,c6 <strcmp+0x1e>
  b4:	0005c703          	lbu	a4,0(a1)
  b8:	00f71763          	bne	a4,a5,c6 <strcmp+0x1e>
    p++, q++;
  bc:	0505                	addi	a0,a0,1
  be:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  c0:	00054783          	lbu	a5,0(a0)
  c4:	fbe5                	bnez	a5,b4 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  c6:	0005c503          	lbu	a0,0(a1)
}
  ca:	40a7853b          	subw	a0,a5,a0
  ce:	6422                	ld	s0,8(sp)
  d0:	0141                	addi	sp,sp,16
  d2:	8082                	ret

00000000000000d4 <strlen>:

uint
strlen(const char *s)
{
  d4:	1141                	addi	sp,sp,-16
  d6:	e422                	sd	s0,8(sp)
  d8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  da:	00054783          	lbu	a5,0(a0)
  de:	cf91                	beqz	a5,fa <strlen+0x26>
  e0:	0505                	addi	a0,a0,1
  e2:	87aa                	mv	a5,a0
  e4:	86be                	mv	a3,a5
  e6:	0785                	addi	a5,a5,1
  e8:	fff7c703          	lbu	a4,-1(a5)
  ec:	ff65                	bnez	a4,e4 <strlen+0x10>
  ee:	40a6853b          	subw	a0,a3,a0
  f2:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  f4:	6422                	ld	s0,8(sp)
  f6:	0141                	addi	sp,sp,16
  f8:	8082                	ret
  for(n = 0; s[n]; n++)
  fa:	4501                	li	a0,0
  fc:	bfe5                	j	f4 <strlen+0x20>

00000000000000fe <memset>:

void*
memset(void *dst, int c, uint n)
{
  fe:	1141                	addi	sp,sp,-16
 100:	e422                	sd	s0,8(sp)
 102:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 104:	ca19                	beqz	a2,11a <memset+0x1c>
 106:	87aa                	mv	a5,a0
 108:	1602                	slli	a2,a2,0x20
 10a:	9201                	srli	a2,a2,0x20
 10c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 110:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 114:	0785                	addi	a5,a5,1
 116:	fee79de3          	bne	a5,a4,110 <memset+0x12>
  }
  return dst;
}
 11a:	6422                	ld	s0,8(sp)
 11c:	0141                	addi	sp,sp,16
 11e:	8082                	ret

0000000000000120 <strchr>:

char*
strchr(const char *s, char c)
{
 120:	1141                	addi	sp,sp,-16
 122:	e422                	sd	s0,8(sp)
 124:	0800                	addi	s0,sp,16
  for(; *s; s++)
 126:	00054783          	lbu	a5,0(a0)
 12a:	cb99                	beqz	a5,140 <strchr+0x20>
    if(*s == c)
 12c:	00f58763          	beq	a1,a5,13a <strchr+0x1a>
  for(; *s; s++)
 130:	0505                	addi	a0,a0,1
 132:	00054783          	lbu	a5,0(a0)
 136:	fbfd                	bnez	a5,12c <strchr+0xc>
      return (char*)s;
  return 0;
 138:	4501                	li	a0,0
}
 13a:	6422                	ld	s0,8(sp)
 13c:	0141                	addi	sp,sp,16
 13e:	8082                	ret
  return 0;
 140:	4501                	li	a0,0
 142:	bfe5                	j	13a <strchr+0x1a>

0000000000000144 <gets>:

char*
gets(char *buf, int max)
{
 144:	711d                	addi	sp,sp,-96
 146:	ec86                	sd	ra,88(sp)
 148:	e8a2                	sd	s0,80(sp)
 14a:	e4a6                	sd	s1,72(sp)
 14c:	e0ca                	sd	s2,64(sp)
 14e:	fc4e                	sd	s3,56(sp)
 150:	f852                	sd	s4,48(sp)
 152:	f456                	sd	s5,40(sp)
 154:	f05a                	sd	s6,32(sp)
 156:	ec5e                	sd	s7,24(sp)
 158:	1080                	addi	s0,sp,96
 15a:	8baa                	mv	s7,a0
 15c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 15e:	892a                	mv	s2,a0
 160:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 162:	4aa9                	li	s5,10
 164:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 166:	89a6                	mv	s3,s1
 168:	2485                	addiw	s1,s1,1
 16a:	0344d863          	bge	s1,s4,19a <gets+0x56>
    cc = read(0, &c, 1);
 16e:	4605                	li	a2,1
 170:	faf40593          	addi	a1,s0,-81
 174:	4501                	li	a0,0
 176:	00000097          	auipc	ra,0x0
 17a:	1b2080e7          	jalr	434(ra) # 328 <read>
    if(cc < 1)
 17e:	00a05e63          	blez	a0,19a <gets+0x56>
    buf[i++] = c;
 182:	faf44783          	lbu	a5,-81(s0)
 186:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 18a:	01578763          	beq	a5,s5,198 <gets+0x54>
 18e:	0905                	addi	s2,s2,1
 190:	fd679be3          	bne	a5,s6,166 <gets+0x22>
    buf[i++] = c;
 194:	89a6                	mv	s3,s1
 196:	a011                	j	19a <gets+0x56>
 198:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 19a:	99de                	add	s3,s3,s7
 19c:	00098023          	sb	zero,0(s3)
  return buf;
}
 1a0:	855e                	mv	a0,s7
 1a2:	60e6                	ld	ra,88(sp)
 1a4:	6446                	ld	s0,80(sp)
 1a6:	64a6                	ld	s1,72(sp)
 1a8:	6906                	ld	s2,64(sp)
 1aa:	79e2                	ld	s3,56(sp)
 1ac:	7a42                	ld	s4,48(sp)
 1ae:	7aa2                	ld	s5,40(sp)
 1b0:	7b02                	ld	s6,32(sp)
 1b2:	6be2                	ld	s7,24(sp)
 1b4:	6125                	addi	sp,sp,96
 1b6:	8082                	ret

00000000000001b8 <stat>:

int
stat(const char *n, struct stat *st)
{
 1b8:	1101                	addi	sp,sp,-32
 1ba:	ec06                	sd	ra,24(sp)
 1bc:	e822                	sd	s0,16(sp)
 1be:	e04a                	sd	s2,0(sp)
 1c0:	1000                	addi	s0,sp,32
 1c2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1c4:	4581                	li	a1,0
 1c6:	00000097          	auipc	ra,0x0
 1ca:	18a080e7          	jalr	394(ra) # 350 <open>
  if(fd < 0)
 1ce:	02054663          	bltz	a0,1fa <stat+0x42>
 1d2:	e426                	sd	s1,8(sp)
 1d4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1d6:	85ca                	mv	a1,s2
 1d8:	00000097          	auipc	ra,0x0
 1dc:	180080e7          	jalr	384(ra) # 358 <fstat>
 1e0:	892a                	mv	s2,a0
  close(fd);
 1e2:	8526                	mv	a0,s1
 1e4:	00000097          	auipc	ra,0x0
 1e8:	154080e7          	jalr	340(ra) # 338 <close>
  return r;
 1ec:	64a2                	ld	s1,8(sp)
}
 1ee:	854a                	mv	a0,s2
 1f0:	60e2                	ld	ra,24(sp)
 1f2:	6442                	ld	s0,16(sp)
 1f4:	6902                	ld	s2,0(sp)
 1f6:	6105                	addi	sp,sp,32
 1f8:	8082                	ret
    return -1;
 1fa:	597d                	li	s2,-1
 1fc:	bfcd                	j	1ee <stat+0x36>

00000000000001fe <atoi>:

int
atoi(const char *s)
{
 1fe:	1141                	addi	sp,sp,-16
 200:	e422                	sd	s0,8(sp)
 202:	0800                	addi	s0,sp,16
  int n;
  int neg = 1;
  if (*s == '-') {
 204:	00054703          	lbu	a4,0(a0)
 208:	02d00793          	li	a5,45
  int neg = 1;
 20c:	4585                	li	a1,1
  if (*s == '-') {
 20e:	04f70363          	beq	a4,a5,254 <atoi+0x56>
    s++;
    neg = -1;
  }
  n = 0;
  while('0' <= *s && *s <= '9')
 212:	00054703          	lbu	a4,0(a0)
 216:	fd07079b          	addiw	a5,a4,-48
 21a:	0ff7f793          	zext.b	a5,a5
 21e:	46a5                	li	a3,9
 220:	02f6ed63          	bltu	a3,a5,25a <atoi+0x5c>
  n = 0;
 224:	4681                	li	a3,0
  while('0' <= *s && *s <= '9')
 226:	4625                	li	a2,9
    n = n*10 + *s++ - '0';
 228:	0505                	addi	a0,a0,1
 22a:	0026979b          	slliw	a5,a3,0x2
 22e:	9fb5                	addw	a5,a5,a3
 230:	0017979b          	slliw	a5,a5,0x1
 234:	9fb9                	addw	a5,a5,a4
 236:	fd07869b          	addiw	a3,a5,-48
  while('0' <= *s && *s <= '9')
 23a:	00054703          	lbu	a4,0(a0)
 23e:	fd07079b          	addiw	a5,a4,-48
 242:	0ff7f793          	zext.b	a5,a5
 246:	fef671e3          	bgeu	a2,a5,228 <atoi+0x2a>
  return n * neg;
}
 24a:	02d5853b          	mulw	a0,a1,a3
 24e:	6422                	ld	s0,8(sp)
 250:	0141                	addi	sp,sp,16
 252:	8082                	ret
    s++;
 254:	0505                	addi	a0,a0,1
    neg = -1;
 256:	55fd                	li	a1,-1
 258:	bf6d                	j	212 <atoi+0x14>
  n = 0;
 25a:	4681                	li	a3,0
 25c:	b7fd                	j	24a <atoi+0x4c>

000000000000025e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 25e:	1141                	addi	sp,sp,-16
 260:	e422                	sd	s0,8(sp)
 262:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 264:	02b57463          	bgeu	a0,a1,28c <memmove+0x2e>
    while(n-- > 0)
 268:	00c05f63          	blez	a2,286 <memmove+0x28>
 26c:	1602                	slli	a2,a2,0x20
 26e:	9201                	srli	a2,a2,0x20
 270:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 274:	872a                	mv	a4,a0
      *dst++ = *src++;
 276:	0585                	addi	a1,a1,1
 278:	0705                	addi	a4,a4,1
 27a:	fff5c683          	lbu	a3,-1(a1)
 27e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 282:	fef71ae3          	bne	a4,a5,276 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 286:	6422                	ld	s0,8(sp)
 288:	0141                	addi	sp,sp,16
 28a:	8082                	ret
    dst += n;
 28c:	00c50733          	add	a4,a0,a2
    src += n;
 290:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 292:	fec05ae3          	blez	a2,286 <memmove+0x28>
 296:	fff6079b          	addiw	a5,a2,-1
 29a:	1782                	slli	a5,a5,0x20
 29c:	9381                	srli	a5,a5,0x20
 29e:	fff7c793          	not	a5,a5
 2a2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2a4:	15fd                	addi	a1,a1,-1
 2a6:	177d                	addi	a4,a4,-1
 2a8:	0005c683          	lbu	a3,0(a1)
 2ac:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2b0:	fee79ae3          	bne	a5,a4,2a4 <memmove+0x46>
 2b4:	bfc9                	j	286 <memmove+0x28>

00000000000002b6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2b6:	1141                	addi	sp,sp,-16
 2b8:	e422                	sd	s0,8(sp)
 2ba:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2bc:	ca05                	beqz	a2,2ec <memcmp+0x36>
 2be:	fff6069b          	addiw	a3,a2,-1
 2c2:	1682                	slli	a3,a3,0x20
 2c4:	9281                	srli	a3,a3,0x20
 2c6:	0685                	addi	a3,a3,1
 2c8:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2ca:	00054783          	lbu	a5,0(a0)
 2ce:	0005c703          	lbu	a4,0(a1)
 2d2:	00e79863          	bne	a5,a4,2e2 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2d6:	0505                	addi	a0,a0,1
    p2++;
 2d8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2da:	fed518e3          	bne	a0,a3,2ca <memcmp+0x14>
  }
  return 0;
 2de:	4501                	li	a0,0
 2e0:	a019                	j	2e6 <memcmp+0x30>
      return *p1 - *p2;
 2e2:	40e7853b          	subw	a0,a5,a4
}
 2e6:	6422                	ld	s0,8(sp)
 2e8:	0141                	addi	sp,sp,16
 2ea:	8082                	ret
  return 0;
 2ec:	4501                	li	a0,0
 2ee:	bfe5                	j	2e6 <memcmp+0x30>

00000000000002f0 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2f0:	1141                	addi	sp,sp,-16
 2f2:	e406                	sd	ra,8(sp)
 2f4:	e022                	sd	s0,0(sp)
 2f6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2f8:	00000097          	auipc	ra,0x0
 2fc:	f66080e7          	jalr	-154(ra) # 25e <memmove>
}
 300:	60a2                	ld	ra,8(sp)
 302:	6402                	ld	s0,0(sp)
 304:	0141                	addi	sp,sp,16
 306:	8082                	ret

0000000000000308 <fork>:
# generated by usys.pl - do not edit
#include "kernel/include/sysnum.h"
.global fork
fork:
 li a7, SYS_fork
 308:	4885                	li	a7,1
 ecall
 30a:	00000073          	ecall
 ret
 30e:	8082                	ret

0000000000000310 <exit>:
.global exit
exit:
 li a7, SYS_exit
 310:	4889                	li	a7,2
 ecall
 312:	00000073          	ecall
 ret
 316:	8082                	ret

0000000000000318 <wait>:
.global wait
wait:
 li a7, SYS_wait
 318:	488d                	li	a7,3
 ecall
 31a:	00000073          	ecall
 ret
 31e:	8082                	ret

0000000000000320 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 320:	4891                	li	a7,4
 ecall
 322:	00000073          	ecall
 ret
 326:	8082                	ret

0000000000000328 <read>:
.global read
read:
 li a7, SYS_read
 328:	4895                	li	a7,5
 ecall
 32a:	00000073          	ecall
 ret
 32e:	8082                	ret

0000000000000330 <write>:
.global write
write:
 li a7, SYS_write
 330:	48c1                	li	a7,16
 ecall
 332:	00000073          	ecall
 ret
 336:	8082                	ret

0000000000000338 <close>:
.global close
close:
 li a7, SYS_close
 338:	48d5                	li	a7,21
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <kill>:
.global kill
kill:
 li a7, SYS_kill
 340:	4899                	li	a7,6
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <exec>:
.global exec
exec:
 li a7, SYS_exec
 348:	489d                	li	a7,7
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <open>:
.global open
open:
 li a7, SYS_open
 350:	48bd                	li	a7,15
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 358:	48a1                	li	a7,8
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 360:	48d1                	li	a7,20
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 368:	48a5                	li	a7,9
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <dup>:
.global dup
dup:
 li a7, SYS_dup
 370:	48a9                	li	a7,10
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 378:	48ad                	li	a7,11
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 380:	48b1                	li	a7,12
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 388:	48b5                	li	a7,13
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 390:	48b9                	li	a7,14
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <test_proc>:
.global test_proc
test_proc:
 li a7, SYS_test_proc
 398:	48d9                	li	a7,22
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <dev>:
.global dev
dev:
 li a7, SYS_dev
 3a0:	48dd                	li	a7,23
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <readdir>:
.global readdir
readdir:
 li a7, SYS_readdir
 3a8:	48e1                	li	a7,24
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <getcwd>:
.global getcwd
getcwd:
 li a7, SYS_getcwd
 3b0:	48e5                	li	a7,25
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <remove>:
.global remove
remove:
 li a7, SYS_remove
 3b8:	48c5                	li	a7,17
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <trace>:
.global trace
trace:
 li a7, SYS_trace
 3c0:	48c9                	li	a7,18
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <sysinfo>:
.global sysinfo
sysinfo:
 li a7, SYS_sysinfo
 3c8:	48cd                	li	a7,19
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <rename>:
.global rename
rename:
 li a7, SYS_rename
 3d0:	48e9                	li	a7,26
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3d8:	1101                	addi	sp,sp,-32
 3da:	ec06                	sd	ra,24(sp)
 3dc:	e822                	sd	s0,16(sp)
 3de:	1000                	addi	s0,sp,32
 3e0:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3e4:	4605                	li	a2,1
 3e6:	fef40593          	addi	a1,s0,-17
 3ea:	00000097          	auipc	ra,0x0
 3ee:	f46080e7          	jalr	-186(ra) # 330 <write>
}
 3f2:	60e2                	ld	ra,24(sp)
 3f4:	6442                	ld	s0,16(sp)
 3f6:	6105                	addi	sp,sp,32
 3f8:	8082                	ret

00000000000003fa <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3fa:	7139                	addi	sp,sp,-64
 3fc:	fc06                	sd	ra,56(sp)
 3fe:	f822                	sd	s0,48(sp)
 400:	f426                	sd	s1,40(sp)
 402:	0080                	addi	s0,sp,64
 404:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 406:	c299                	beqz	a3,40c <printint+0x12>
 408:	0805cb63          	bltz	a1,49e <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 40c:	2581                	sext.w	a1,a1
  neg = 0;
 40e:	4881                	li	a7,0
 410:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 414:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 416:	2601                	sext.w	a2,a2
 418:	00000517          	auipc	a0,0x0
 41c:	4e850513          	addi	a0,a0,1256 # 900 <digits>
 420:	883a                	mv	a6,a4
 422:	2705                	addiw	a4,a4,1
 424:	02c5f7bb          	remuw	a5,a1,a2
 428:	1782                	slli	a5,a5,0x20
 42a:	9381                	srli	a5,a5,0x20
 42c:	97aa                	add	a5,a5,a0
 42e:	0007c783          	lbu	a5,0(a5)
 432:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 436:	0005879b          	sext.w	a5,a1
 43a:	02c5d5bb          	divuw	a1,a1,a2
 43e:	0685                	addi	a3,a3,1
 440:	fec7f0e3          	bgeu	a5,a2,420 <printint+0x26>
  if(neg)
 444:	00088c63          	beqz	a7,45c <printint+0x62>
    buf[i++] = '-';
 448:	fd070793          	addi	a5,a4,-48
 44c:	00878733          	add	a4,a5,s0
 450:	02d00793          	li	a5,45
 454:	fef70823          	sb	a5,-16(a4)
 458:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 45c:	02e05c63          	blez	a4,494 <printint+0x9a>
 460:	f04a                	sd	s2,32(sp)
 462:	ec4e                	sd	s3,24(sp)
 464:	fc040793          	addi	a5,s0,-64
 468:	00e78933          	add	s2,a5,a4
 46c:	fff78993          	addi	s3,a5,-1
 470:	99ba                	add	s3,s3,a4
 472:	377d                	addiw	a4,a4,-1
 474:	1702                	slli	a4,a4,0x20
 476:	9301                	srli	a4,a4,0x20
 478:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 47c:	fff94583          	lbu	a1,-1(s2)
 480:	8526                	mv	a0,s1
 482:	00000097          	auipc	ra,0x0
 486:	f56080e7          	jalr	-170(ra) # 3d8 <putc>
  while(--i >= 0)
 48a:	197d                	addi	s2,s2,-1
 48c:	ff3918e3          	bne	s2,s3,47c <printint+0x82>
 490:	7902                	ld	s2,32(sp)
 492:	69e2                	ld	s3,24(sp)
}
 494:	70e2                	ld	ra,56(sp)
 496:	7442                	ld	s0,48(sp)
 498:	74a2                	ld	s1,40(sp)
 49a:	6121                	addi	sp,sp,64
 49c:	8082                	ret
    x = -xx;
 49e:	40b005bb          	negw	a1,a1
    neg = 1;
 4a2:	4885                	li	a7,1
    x = -xx;
 4a4:	b7b5                	j	410 <printint+0x16>

00000000000004a6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4a6:	715d                	addi	sp,sp,-80
 4a8:	e486                	sd	ra,72(sp)
 4aa:	e0a2                	sd	s0,64(sp)
 4ac:	f84a                	sd	s2,48(sp)
 4ae:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4b0:	0005c903          	lbu	s2,0(a1)
 4b4:	1a090a63          	beqz	s2,668 <vprintf+0x1c2>
 4b8:	fc26                	sd	s1,56(sp)
 4ba:	f44e                	sd	s3,40(sp)
 4bc:	f052                	sd	s4,32(sp)
 4be:	ec56                	sd	s5,24(sp)
 4c0:	e85a                	sd	s6,16(sp)
 4c2:	e45e                	sd	s7,8(sp)
 4c4:	8aaa                	mv	s5,a0
 4c6:	8bb2                	mv	s7,a2
 4c8:	00158493          	addi	s1,a1,1
  state = 0;
 4cc:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4ce:	02500a13          	li	s4,37
 4d2:	4b55                	li	s6,21
 4d4:	a839                	j	4f2 <vprintf+0x4c>
        putc(fd, c);
 4d6:	85ca                	mv	a1,s2
 4d8:	8556                	mv	a0,s5
 4da:	00000097          	auipc	ra,0x0
 4de:	efe080e7          	jalr	-258(ra) # 3d8 <putc>
 4e2:	a019                	j	4e8 <vprintf+0x42>
    } else if(state == '%'){
 4e4:	01498d63          	beq	s3,s4,4fe <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 4e8:	0485                	addi	s1,s1,1
 4ea:	fff4c903          	lbu	s2,-1(s1)
 4ee:	16090763          	beqz	s2,65c <vprintf+0x1b6>
    if(state == 0){
 4f2:	fe0999e3          	bnez	s3,4e4 <vprintf+0x3e>
      if(c == '%'){
 4f6:	ff4910e3          	bne	s2,s4,4d6 <vprintf+0x30>
        state = '%';
 4fa:	89d2                	mv	s3,s4
 4fc:	b7f5                	j	4e8 <vprintf+0x42>
      if(c == 'd'){
 4fe:	13490463          	beq	s2,s4,626 <vprintf+0x180>
 502:	f9d9079b          	addiw	a5,s2,-99
 506:	0ff7f793          	zext.b	a5,a5
 50a:	12fb6763          	bltu	s6,a5,638 <vprintf+0x192>
 50e:	f9d9079b          	addiw	a5,s2,-99
 512:	0ff7f713          	zext.b	a4,a5
 516:	12eb6163          	bltu	s6,a4,638 <vprintf+0x192>
 51a:	00271793          	slli	a5,a4,0x2
 51e:	00000717          	auipc	a4,0x0
 522:	38a70713          	addi	a4,a4,906 # 8a8 <malloc+0x150>
 526:	97ba                	add	a5,a5,a4
 528:	439c                	lw	a5,0(a5)
 52a:	97ba                	add	a5,a5,a4
 52c:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 52e:	008b8913          	addi	s2,s7,8
 532:	4685                	li	a3,1
 534:	4629                	li	a2,10
 536:	000ba583          	lw	a1,0(s7)
 53a:	8556                	mv	a0,s5
 53c:	00000097          	auipc	ra,0x0
 540:	ebe080e7          	jalr	-322(ra) # 3fa <printint>
 544:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 546:	4981                	li	s3,0
 548:	b745                	j	4e8 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 54a:	008b8913          	addi	s2,s7,8
 54e:	4681                	li	a3,0
 550:	4629                	li	a2,10
 552:	000ba583          	lw	a1,0(s7)
 556:	8556                	mv	a0,s5
 558:	00000097          	auipc	ra,0x0
 55c:	ea2080e7          	jalr	-350(ra) # 3fa <printint>
 560:	8bca                	mv	s7,s2
      state = 0;
 562:	4981                	li	s3,0
 564:	b751                	j	4e8 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 566:	008b8913          	addi	s2,s7,8
 56a:	4681                	li	a3,0
 56c:	4641                	li	a2,16
 56e:	000ba583          	lw	a1,0(s7)
 572:	8556                	mv	a0,s5
 574:	00000097          	auipc	ra,0x0
 578:	e86080e7          	jalr	-378(ra) # 3fa <printint>
 57c:	8bca                	mv	s7,s2
      state = 0;
 57e:	4981                	li	s3,0
 580:	b7a5                	j	4e8 <vprintf+0x42>
 582:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 584:	008b8c13          	addi	s8,s7,8
 588:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 58c:	03000593          	li	a1,48
 590:	8556                	mv	a0,s5
 592:	00000097          	auipc	ra,0x0
 596:	e46080e7          	jalr	-442(ra) # 3d8 <putc>
  putc(fd, 'x');
 59a:	07800593          	li	a1,120
 59e:	8556                	mv	a0,s5
 5a0:	00000097          	auipc	ra,0x0
 5a4:	e38080e7          	jalr	-456(ra) # 3d8 <putc>
 5a8:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5aa:	00000b97          	auipc	s7,0x0
 5ae:	356b8b93          	addi	s7,s7,854 # 900 <digits>
 5b2:	03c9d793          	srli	a5,s3,0x3c
 5b6:	97de                	add	a5,a5,s7
 5b8:	0007c583          	lbu	a1,0(a5)
 5bc:	8556                	mv	a0,s5
 5be:	00000097          	auipc	ra,0x0
 5c2:	e1a080e7          	jalr	-486(ra) # 3d8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5c6:	0992                	slli	s3,s3,0x4
 5c8:	397d                	addiw	s2,s2,-1
 5ca:	fe0914e3          	bnez	s2,5b2 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 5ce:	8be2                	mv	s7,s8
      state = 0;
 5d0:	4981                	li	s3,0
 5d2:	6c02                	ld	s8,0(sp)
 5d4:	bf11                	j	4e8 <vprintf+0x42>
        s = va_arg(ap, char*);
 5d6:	008b8993          	addi	s3,s7,8
 5da:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 5de:	02090163          	beqz	s2,600 <vprintf+0x15a>
        while(*s != 0){
 5e2:	00094583          	lbu	a1,0(s2)
 5e6:	c9a5                	beqz	a1,656 <vprintf+0x1b0>
          putc(fd, *s);
 5e8:	8556                	mv	a0,s5
 5ea:	00000097          	auipc	ra,0x0
 5ee:	dee080e7          	jalr	-530(ra) # 3d8 <putc>
          s++;
 5f2:	0905                	addi	s2,s2,1
        while(*s != 0){
 5f4:	00094583          	lbu	a1,0(s2)
 5f8:	f9e5                	bnez	a1,5e8 <vprintf+0x142>
        s = va_arg(ap, char*);
 5fa:	8bce                	mv	s7,s3
      state = 0;
 5fc:	4981                	li	s3,0
 5fe:	b5ed                	j	4e8 <vprintf+0x42>
          s = "(null)";
 600:	00000917          	auipc	s2,0x0
 604:	2a090913          	addi	s2,s2,672 # 8a0 <malloc+0x148>
        while(*s != 0){
 608:	02800593          	li	a1,40
 60c:	bff1                	j	5e8 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 60e:	008b8913          	addi	s2,s7,8
 612:	000bc583          	lbu	a1,0(s7)
 616:	8556                	mv	a0,s5
 618:	00000097          	auipc	ra,0x0
 61c:	dc0080e7          	jalr	-576(ra) # 3d8 <putc>
 620:	8bca                	mv	s7,s2
      state = 0;
 622:	4981                	li	s3,0
 624:	b5d1                	j	4e8 <vprintf+0x42>
        putc(fd, c);
 626:	02500593          	li	a1,37
 62a:	8556                	mv	a0,s5
 62c:	00000097          	auipc	ra,0x0
 630:	dac080e7          	jalr	-596(ra) # 3d8 <putc>
      state = 0;
 634:	4981                	li	s3,0
 636:	bd4d                	j	4e8 <vprintf+0x42>
        putc(fd, '%');
 638:	02500593          	li	a1,37
 63c:	8556                	mv	a0,s5
 63e:	00000097          	auipc	ra,0x0
 642:	d9a080e7          	jalr	-614(ra) # 3d8 <putc>
        putc(fd, c);
 646:	85ca                	mv	a1,s2
 648:	8556                	mv	a0,s5
 64a:	00000097          	auipc	ra,0x0
 64e:	d8e080e7          	jalr	-626(ra) # 3d8 <putc>
      state = 0;
 652:	4981                	li	s3,0
 654:	bd51                	j	4e8 <vprintf+0x42>
        s = va_arg(ap, char*);
 656:	8bce                	mv	s7,s3
      state = 0;
 658:	4981                	li	s3,0
 65a:	b579                	j	4e8 <vprintf+0x42>
 65c:	74e2                	ld	s1,56(sp)
 65e:	79a2                	ld	s3,40(sp)
 660:	7a02                	ld	s4,32(sp)
 662:	6ae2                	ld	s5,24(sp)
 664:	6b42                	ld	s6,16(sp)
 666:	6ba2                	ld	s7,8(sp)
    }
  }
}
 668:	60a6                	ld	ra,72(sp)
 66a:	6406                	ld	s0,64(sp)
 66c:	7942                	ld	s2,48(sp)
 66e:	6161                	addi	sp,sp,80
 670:	8082                	ret

0000000000000672 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 672:	715d                	addi	sp,sp,-80
 674:	ec06                	sd	ra,24(sp)
 676:	e822                	sd	s0,16(sp)
 678:	1000                	addi	s0,sp,32
 67a:	e010                	sd	a2,0(s0)
 67c:	e414                	sd	a3,8(s0)
 67e:	e818                	sd	a4,16(s0)
 680:	ec1c                	sd	a5,24(s0)
 682:	03043023          	sd	a6,32(s0)
 686:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 68a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 68e:	8622                	mv	a2,s0
 690:	00000097          	auipc	ra,0x0
 694:	e16080e7          	jalr	-490(ra) # 4a6 <vprintf>
}
 698:	60e2                	ld	ra,24(sp)
 69a:	6442                	ld	s0,16(sp)
 69c:	6161                	addi	sp,sp,80
 69e:	8082                	ret

00000000000006a0 <printf>:

void
printf(const char *fmt, ...)
{
 6a0:	711d                	addi	sp,sp,-96
 6a2:	ec06                	sd	ra,24(sp)
 6a4:	e822                	sd	s0,16(sp)
 6a6:	1000                	addi	s0,sp,32
 6a8:	e40c                	sd	a1,8(s0)
 6aa:	e810                	sd	a2,16(s0)
 6ac:	ec14                	sd	a3,24(s0)
 6ae:	f018                	sd	a4,32(s0)
 6b0:	f41c                	sd	a5,40(s0)
 6b2:	03043823          	sd	a6,48(s0)
 6b6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6ba:	00840613          	addi	a2,s0,8
 6be:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6c2:	85aa                	mv	a1,a0
 6c4:	4505                	li	a0,1
 6c6:	00000097          	auipc	ra,0x0
 6ca:	de0080e7          	jalr	-544(ra) # 4a6 <vprintf>
}
 6ce:	60e2                	ld	ra,24(sp)
 6d0:	6442                	ld	s0,16(sp)
 6d2:	6125                	addi	sp,sp,96
 6d4:	8082                	ret

00000000000006d6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6d6:	1141                	addi	sp,sp,-16
 6d8:	e422                	sd	s0,8(sp)
 6da:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6dc:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6e0:	00000797          	auipc	a5,0x0
 6e4:	2387b783          	ld	a5,568(a5) # 918 <freep>
 6e8:	a02d                	j	712 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6ea:	4618                	lw	a4,8(a2)
 6ec:	9f2d                	addw	a4,a4,a1
 6ee:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6f2:	6398                	ld	a4,0(a5)
 6f4:	6310                	ld	a2,0(a4)
 6f6:	a83d                	j	734 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6f8:	ff852703          	lw	a4,-8(a0)
 6fc:	9f31                	addw	a4,a4,a2
 6fe:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 700:	ff053683          	ld	a3,-16(a0)
 704:	a091                	j	748 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 706:	6398                	ld	a4,0(a5)
 708:	00e7e463          	bltu	a5,a4,710 <free+0x3a>
 70c:	00e6ea63          	bltu	a3,a4,720 <free+0x4a>
{
 710:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 712:	fed7fae3          	bgeu	a5,a3,706 <free+0x30>
 716:	6398                	ld	a4,0(a5)
 718:	00e6e463          	bltu	a3,a4,720 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 71c:	fee7eae3          	bltu	a5,a4,710 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 720:	ff852583          	lw	a1,-8(a0)
 724:	6390                	ld	a2,0(a5)
 726:	02059813          	slli	a6,a1,0x20
 72a:	01c85713          	srli	a4,a6,0x1c
 72e:	9736                	add	a4,a4,a3
 730:	fae60de3          	beq	a2,a4,6ea <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 734:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 738:	4790                	lw	a2,8(a5)
 73a:	02061593          	slli	a1,a2,0x20
 73e:	01c5d713          	srli	a4,a1,0x1c
 742:	973e                	add	a4,a4,a5
 744:	fae68ae3          	beq	a3,a4,6f8 <free+0x22>
    p->s.ptr = bp->s.ptr;
 748:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 74a:	00000717          	auipc	a4,0x0
 74e:	1cf73723          	sd	a5,462(a4) # 918 <freep>
}
 752:	6422                	ld	s0,8(sp)
 754:	0141                	addi	sp,sp,16
 756:	8082                	ret

0000000000000758 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 758:	7139                	addi	sp,sp,-64
 75a:	fc06                	sd	ra,56(sp)
 75c:	f822                	sd	s0,48(sp)
 75e:	f426                	sd	s1,40(sp)
 760:	ec4e                	sd	s3,24(sp)
 762:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 764:	02051493          	slli	s1,a0,0x20
 768:	9081                	srli	s1,s1,0x20
 76a:	04bd                	addi	s1,s1,15
 76c:	8091                	srli	s1,s1,0x4
 76e:	0014899b          	addiw	s3,s1,1
 772:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 774:	00000517          	auipc	a0,0x0
 778:	1a453503          	ld	a0,420(a0) # 918 <freep>
 77c:	c915                	beqz	a0,7b0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 77e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 780:	4798                	lw	a4,8(a5)
 782:	08977e63          	bgeu	a4,s1,81e <malloc+0xc6>
 786:	f04a                	sd	s2,32(sp)
 788:	e852                	sd	s4,16(sp)
 78a:	e456                	sd	s5,8(sp)
 78c:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 78e:	8a4e                	mv	s4,s3
 790:	0009871b          	sext.w	a4,s3
 794:	6685                	lui	a3,0x1
 796:	00d77363          	bgeu	a4,a3,79c <malloc+0x44>
 79a:	6a05                	lui	s4,0x1
 79c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7a0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7a4:	00000917          	auipc	s2,0x0
 7a8:	17490913          	addi	s2,s2,372 # 918 <freep>
  if(p == (char*)-1)
 7ac:	5afd                	li	s5,-1
 7ae:	a091                	j	7f2 <malloc+0x9a>
 7b0:	f04a                	sd	s2,32(sp)
 7b2:	e852                	sd	s4,16(sp)
 7b4:	e456                	sd	s5,8(sp)
 7b6:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 7b8:	00000797          	auipc	a5,0x0
 7bc:	16878793          	addi	a5,a5,360 # 920 <base>
 7c0:	00000717          	auipc	a4,0x0
 7c4:	14f73c23          	sd	a5,344(a4) # 918 <freep>
 7c8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7ca:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7ce:	b7c1                	j	78e <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 7d0:	6398                	ld	a4,0(a5)
 7d2:	e118                	sd	a4,0(a0)
 7d4:	a08d                	j	836 <malloc+0xde>
  hp->s.size = nu;
 7d6:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7da:	0541                	addi	a0,a0,16
 7dc:	00000097          	auipc	ra,0x0
 7e0:	efa080e7          	jalr	-262(ra) # 6d6 <free>
  return freep;
 7e4:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7e8:	c13d                	beqz	a0,84e <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7ea:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7ec:	4798                	lw	a4,8(a5)
 7ee:	02977463          	bgeu	a4,s1,816 <malloc+0xbe>
    if(p == freep)
 7f2:	00093703          	ld	a4,0(s2)
 7f6:	853e                	mv	a0,a5
 7f8:	fef719e3          	bne	a4,a5,7ea <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 7fc:	8552                	mv	a0,s4
 7fe:	00000097          	auipc	ra,0x0
 802:	b82080e7          	jalr	-1150(ra) # 380 <sbrk>
  if(p == (char*)-1)
 806:	fd5518e3          	bne	a0,s5,7d6 <malloc+0x7e>
        return 0;
 80a:	4501                	li	a0,0
 80c:	7902                	ld	s2,32(sp)
 80e:	6a42                	ld	s4,16(sp)
 810:	6aa2                	ld	s5,8(sp)
 812:	6b02                	ld	s6,0(sp)
 814:	a03d                	j	842 <malloc+0xea>
 816:	7902                	ld	s2,32(sp)
 818:	6a42                	ld	s4,16(sp)
 81a:	6aa2                	ld	s5,8(sp)
 81c:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 81e:	fae489e3          	beq	s1,a4,7d0 <malloc+0x78>
        p->s.size -= nunits;
 822:	4137073b          	subw	a4,a4,s3
 826:	c798                	sw	a4,8(a5)
        p += p->s.size;
 828:	02071693          	slli	a3,a4,0x20
 82c:	01c6d713          	srli	a4,a3,0x1c
 830:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 832:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 836:	00000717          	auipc	a4,0x0
 83a:	0ea73123          	sd	a0,226(a4) # 918 <freep>
      return (void*)(p + 1);
 83e:	01078513          	addi	a0,a5,16
  }
}
 842:	70e2                	ld	ra,56(sp)
 844:	7442                	ld	s0,48(sp)
 846:	74a2                	ld	s1,40(sp)
 848:	69e2                	ld	s3,24(sp)
 84a:	6121                	addi	sp,sp,64
 84c:	8082                	ret
 84e:	7902                	ld	s2,32(sp)
 850:	6a42                	ld	s4,16(sp)
 852:	6aa2                	ld	s5,8(sp)
 854:	6b02                	ld	s6,0(sp)
 856:	b7f5                	j	842 <malloc+0xea>
