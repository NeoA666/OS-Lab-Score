
xv6-user/_cat:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <cat>:

char buf[512];

void
cat(int fd)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
   e:	89aa                	mv	s3,a0
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0) {
  10:	00001917          	auipc	s2,0x1
  14:	9d890913          	addi	s2,s2,-1576 # 9e8 <buf>
  18:	20000613          	li	a2,512
  1c:	85ca                	mv	a1,s2
  1e:	854e                	mv	a0,s3
  20:	00000097          	auipc	ra,0x0
  24:	3cc080e7          	jalr	972(ra) # 3ec <read>
  28:	84aa                	mv	s1,a0
  2a:	02a05963          	blez	a0,5c <cat+0x5c>
    if (write(1, buf, n) != n) {
  2e:	8626                	mv	a2,s1
  30:	85ca                	mv	a1,s2
  32:	4505                	li	a0,1
  34:	00000097          	auipc	ra,0x0
  38:	3c0080e7          	jalr	960(ra) # 3f4 <write>
  3c:	fc950ee3          	beq	a0,s1,18 <cat+0x18>
      fprintf(2, "cat: write error\n");
  40:	00001597          	auipc	a1,0x1
  44:	8e058593          	addi	a1,a1,-1824 # 920 <malloc+0x104>
  48:	4509                	li	a0,2
  4a:	00000097          	auipc	ra,0x0
  4e:	6ec080e7          	jalr	1772(ra) # 736 <fprintf>
      exit(1);
  52:	4505                	li	a0,1
  54:	00000097          	auipc	ra,0x0
  58:	380080e7          	jalr	896(ra) # 3d4 <exit>
    }
  }
  if(n < 0){
  5c:	00054963          	bltz	a0,6e <cat+0x6e>
    fprintf(2, "cat: read error\n");
    exit(1);
  }
}
  60:	70a2                	ld	ra,40(sp)
  62:	7402                	ld	s0,32(sp)
  64:	64e2                	ld	s1,24(sp)
  66:	6942                	ld	s2,16(sp)
  68:	69a2                	ld	s3,8(sp)
  6a:	6145                	addi	sp,sp,48
  6c:	8082                	ret
    fprintf(2, "cat: read error\n");
  6e:	00001597          	auipc	a1,0x1
  72:	8ca58593          	addi	a1,a1,-1846 # 938 <malloc+0x11c>
  76:	4509                	li	a0,2
  78:	00000097          	auipc	ra,0x0
  7c:	6be080e7          	jalr	1726(ra) # 736 <fprintf>
    exit(1);
  80:	4505                	li	a0,1
  82:	00000097          	auipc	ra,0x0
  86:	352080e7          	jalr	850(ra) # 3d4 <exit>

000000000000008a <main>:

int
main(int argc, char *argv[])
{
  8a:	7179                	addi	sp,sp,-48
  8c:	f406                	sd	ra,40(sp)
  8e:	f022                	sd	s0,32(sp)
  90:	1800                	addi	s0,sp,48
  int fd, i;

  if(argc <= 1){
  92:	4785                	li	a5,1
  94:	04a7da63          	bge	a5,a0,e8 <main+0x5e>
  98:	ec26                	sd	s1,24(sp)
  9a:	e84a                	sd	s2,16(sp)
  9c:	e44e                	sd	s3,8(sp)
  9e:	00858913          	addi	s2,a1,8
  a2:	ffe5099b          	addiw	s3,a0,-2
  a6:	02099793          	slli	a5,s3,0x20
  aa:	01d7d993          	srli	s3,a5,0x1d
  ae:	05c1                	addi	a1,a1,16
  b0:	99ae                	add	s3,s3,a1
    cat(0);
    exit(0);
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
  b2:	4581                	li	a1,0
  b4:	00093503          	ld	a0,0(s2)
  b8:	00000097          	auipc	ra,0x0
  bc:	35c080e7          	jalr	860(ra) # 414 <open>
  c0:	84aa                	mv	s1,a0
  c2:	04054063          	bltz	a0,102 <main+0x78>
      fprintf(2, "cat: cannot open %s\n", argv[i]);
      exit(1);
    }
    cat(fd);
  c6:	00000097          	auipc	ra,0x0
  ca:	f3a080e7          	jalr	-198(ra) # 0 <cat>
    close(fd);
  ce:	8526                	mv	a0,s1
  d0:	00000097          	auipc	ra,0x0
  d4:	32c080e7          	jalr	812(ra) # 3fc <close>
  for(i = 1; i < argc; i++){
  d8:	0921                	addi	s2,s2,8
  da:	fd391ce3          	bne	s2,s3,b2 <main+0x28>
  }
  exit(0);
  de:	4501                	li	a0,0
  e0:	00000097          	auipc	ra,0x0
  e4:	2f4080e7          	jalr	756(ra) # 3d4 <exit>
  e8:	ec26                	sd	s1,24(sp)
  ea:	e84a                	sd	s2,16(sp)
  ec:	e44e                	sd	s3,8(sp)
    cat(0);
  ee:	4501                	li	a0,0
  f0:	00000097          	auipc	ra,0x0
  f4:	f10080e7          	jalr	-240(ra) # 0 <cat>
    exit(0);
  f8:	4501                	li	a0,0
  fa:	00000097          	auipc	ra,0x0
  fe:	2da080e7          	jalr	730(ra) # 3d4 <exit>
      fprintf(2, "cat: cannot open %s\n", argv[i]);
 102:	00093603          	ld	a2,0(s2)
 106:	00001597          	auipc	a1,0x1
 10a:	84a58593          	addi	a1,a1,-1974 # 950 <malloc+0x134>
 10e:	4509                	li	a0,2
 110:	00000097          	auipc	ra,0x0
 114:	626080e7          	jalr	1574(ra) # 736 <fprintf>
      exit(1);
 118:	4505                	li	a0,1
 11a:	00000097          	auipc	ra,0x0
 11e:	2ba080e7          	jalr	698(ra) # 3d4 <exit>

0000000000000122 <strcpy>:
#include "kernel/include/fcntl.h"
#include "xv6-user/user.h"

char*
strcpy(char *s, const char *t)
{
 122:	1141                	addi	sp,sp,-16
 124:	e422                	sd	s0,8(sp)
 126:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 128:	87aa                	mv	a5,a0
 12a:	0585                	addi	a1,a1,1
 12c:	0785                	addi	a5,a5,1
 12e:	fff5c703          	lbu	a4,-1(a1)
 132:	fee78fa3          	sb	a4,-1(a5)
 136:	fb75                	bnez	a4,12a <strcpy+0x8>
    ;
  return os;
}
 138:	6422                	ld	s0,8(sp)
 13a:	0141                	addi	sp,sp,16
 13c:	8082                	ret

000000000000013e <strcat>:

char*
strcat(char *s, const char *t)
{
 13e:	1141                	addi	sp,sp,-16
 140:	e422                	sd	s0,8(sp)
 142:	0800                	addi	s0,sp,16
  char *os = s;
  while(*s)
 144:	00054783          	lbu	a5,0(a0)
 148:	c385                	beqz	a5,168 <strcat+0x2a>
 14a:	87aa                	mv	a5,a0
    s++;
 14c:	0785                	addi	a5,a5,1
  while(*s)
 14e:	0007c703          	lbu	a4,0(a5)
 152:	ff6d                	bnez	a4,14c <strcat+0xe>
  while((*s++ = *t++))
 154:	0585                	addi	a1,a1,1
 156:	0785                	addi	a5,a5,1
 158:	fff5c703          	lbu	a4,-1(a1)
 15c:	fee78fa3          	sb	a4,-1(a5)
 160:	fb75                	bnez	a4,154 <strcat+0x16>
    ;
  return os;
}
 162:	6422                	ld	s0,8(sp)
 164:	0141                	addi	sp,sp,16
 166:	8082                	ret
  while(*s)
 168:	87aa                	mv	a5,a0
 16a:	b7ed                	j	154 <strcat+0x16>

000000000000016c <strcmp>:


int
strcmp(const char *p, const char *q)
{
 16c:	1141                	addi	sp,sp,-16
 16e:	e422                	sd	s0,8(sp)
 170:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 172:	00054783          	lbu	a5,0(a0)
 176:	cb91                	beqz	a5,18a <strcmp+0x1e>
 178:	0005c703          	lbu	a4,0(a1)
 17c:	00f71763          	bne	a4,a5,18a <strcmp+0x1e>
    p++, q++;
 180:	0505                	addi	a0,a0,1
 182:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 184:	00054783          	lbu	a5,0(a0)
 188:	fbe5                	bnez	a5,178 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 18a:	0005c503          	lbu	a0,0(a1)
}
 18e:	40a7853b          	subw	a0,a5,a0
 192:	6422                	ld	s0,8(sp)
 194:	0141                	addi	sp,sp,16
 196:	8082                	ret

0000000000000198 <strlen>:

uint
strlen(const char *s)
{
 198:	1141                	addi	sp,sp,-16
 19a:	e422                	sd	s0,8(sp)
 19c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 19e:	00054783          	lbu	a5,0(a0)
 1a2:	cf91                	beqz	a5,1be <strlen+0x26>
 1a4:	0505                	addi	a0,a0,1
 1a6:	87aa                	mv	a5,a0
 1a8:	86be                	mv	a3,a5
 1aa:	0785                	addi	a5,a5,1
 1ac:	fff7c703          	lbu	a4,-1(a5)
 1b0:	ff65                	bnez	a4,1a8 <strlen+0x10>
 1b2:	40a6853b          	subw	a0,a3,a0
 1b6:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 1b8:	6422                	ld	s0,8(sp)
 1ba:	0141                	addi	sp,sp,16
 1bc:	8082                	ret
  for(n = 0; s[n]; n++)
 1be:	4501                	li	a0,0
 1c0:	bfe5                	j	1b8 <strlen+0x20>

00000000000001c2 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1c2:	1141                	addi	sp,sp,-16
 1c4:	e422                	sd	s0,8(sp)
 1c6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1c8:	ca19                	beqz	a2,1de <memset+0x1c>
 1ca:	87aa                	mv	a5,a0
 1cc:	1602                	slli	a2,a2,0x20
 1ce:	9201                	srli	a2,a2,0x20
 1d0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1d4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1d8:	0785                	addi	a5,a5,1
 1da:	fee79de3          	bne	a5,a4,1d4 <memset+0x12>
  }
  return dst;
}
 1de:	6422                	ld	s0,8(sp)
 1e0:	0141                	addi	sp,sp,16
 1e2:	8082                	ret

00000000000001e4 <strchr>:

char*
strchr(const char *s, char c)
{
 1e4:	1141                	addi	sp,sp,-16
 1e6:	e422                	sd	s0,8(sp)
 1e8:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1ea:	00054783          	lbu	a5,0(a0)
 1ee:	cb99                	beqz	a5,204 <strchr+0x20>
    if(*s == c)
 1f0:	00f58763          	beq	a1,a5,1fe <strchr+0x1a>
  for(; *s; s++)
 1f4:	0505                	addi	a0,a0,1
 1f6:	00054783          	lbu	a5,0(a0)
 1fa:	fbfd                	bnez	a5,1f0 <strchr+0xc>
      return (char*)s;
  return 0;
 1fc:	4501                	li	a0,0
}
 1fe:	6422                	ld	s0,8(sp)
 200:	0141                	addi	sp,sp,16
 202:	8082                	ret
  return 0;
 204:	4501                	li	a0,0
 206:	bfe5                	j	1fe <strchr+0x1a>

0000000000000208 <gets>:

char*
gets(char *buf, int max)
{
 208:	711d                	addi	sp,sp,-96
 20a:	ec86                	sd	ra,88(sp)
 20c:	e8a2                	sd	s0,80(sp)
 20e:	e4a6                	sd	s1,72(sp)
 210:	e0ca                	sd	s2,64(sp)
 212:	fc4e                	sd	s3,56(sp)
 214:	f852                	sd	s4,48(sp)
 216:	f456                	sd	s5,40(sp)
 218:	f05a                	sd	s6,32(sp)
 21a:	ec5e                	sd	s7,24(sp)
 21c:	1080                	addi	s0,sp,96
 21e:	8baa                	mv	s7,a0
 220:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 222:	892a                	mv	s2,a0
 224:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 226:	4aa9                	li	s5,10
 228:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 22a:	89a6                	mv	s3,s1
 22c:	2485                	addiw	s1,s1,1
 22e:	0344d863          	bge	s1,s4,25e <gets+0x56>
    cc = read(0, &c, 1);
 232:	4605                	li	a2,1
 234:	faf40593          	addi	a1,s0,-81
 238:	4501                	li	a0,0
 23a:	00000097          	auipc	ra,0x0
 23e:	1b2080e7          	jalr	434(ra) # 3ec <read>
    if(cc < 1)
 242:	00a05e63          	blez	a0,25e <gets+0x56>
    buf[i++] = c;
 246:	faf44783          	lbu	a5,-81(s0)
 24a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 24e:	01578763          	beq	a5,s5,25c <gets+0x54>
 252:	0905                	addi	s2,s2,1
 254:	fd679be3          	bne	a5,s6,22a <gets+0x22>
    buf[i++] = c;
 258:	89a6                	mv	s3,s1
 25a:	a011                	j	25e <gets+0x56>
 25c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 25e:	99de                	add	s3,s3,s7
 260:	00098023          	sb	zero,0(s3)
  return buf;
}
 264:	855e                	mv	a0,s7
 266:	60e6                	ld	ra,88(sp)
 268:	6446                	ld	s0,80(sp)
 26a:	64a6                	ld	s1,72(sp)
 26c:	6906                	ld	s2,64(sp)
 26e:	79e2                	ld	s3,56(sp)
 270:	7a42                	ld	s4,48(sp)
 272:	7aa2                	ld	s5,40(sp)
 274:	7b02                	ld	s6,32(sp)
 276:	6be2                	ld	s7,24(sp)
 278:	6125                	addi	sp,sp,96
 27a:	8082                	ret

000000000000027c <stat>:

int
stat(const char *n, struct stat *st)
{
 27c:	1101                	addi	sp,sp,-32
 27e:	ec06                	sd	ra,24(sp)
 280:	e822                	sd	s0,16(sp)
 282:	e04a                	sd	s2,0(sp)
 284:	1000                	addi	s0,sp,32
 286:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 288:	4581                	li	a1,0
 28a:	00000097          	auipc	ra,0x0
 28e:	18a080e7          	jalr	394(ra) # 414 <open>
  if(fd < 0)
 292:	02054663          	bltz	a0,2be <stat+0x42>
 296:	e426                	sd	s1,8(sp)
 298:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 29a:	85ca                	mv	a1,s2
 29c:	00000097          	auipc	ra,0x0
 2a0:	180080e7          	jalr	384(ra) # 41c <fstat>
 2a4:	892a                	mv	s2,a0
  close(fd);
 2a6:	8526                	mv	a0,s1
 2a8:	00000097          	auipc	ra,0x0
 2ac:	154080e7          	jalr	340(ra) # 3fc <close>
  return r;
 2b0:	64a2                	ld	s1,8(sp)
}
 2b2:	854a                	mv	a0,s2
 2b4:	60e2                	ld	ra,24(sp)
 2b6:	6442                	ld	s0,16(sp)
 2b8:	6902                	ld	s2,0(sp)
 2ba:	6105                	addi	sp,sp,32
 2bc:	8082                	ret
    return -1;
 2be:	597d                	li	s2,-1
 2c0:	bfcd                	j	2b2 <stat+0x36>

00000000000002c2 <atoi>:

int
atoi(const char *s)
{
 2c2:	1141                	addi	sp,sp,-16
 2c4:	e422                	sd	s0,8(sp)
 2c6:	0800                	addi	s0,sp,16
  int n;
  int neg = 1;
  if (*s == '-') {
 2c8:	00054703          	lbu	a4,0(a0)
 2cc:	02d00793          	li	a5,45
  int neg = 1;
 2d0:	4585                	li	a1,1
  if (*s == '-') {
 2d2:	04f70363          	beq	a4,a5,318 <atoi+0x56>
    s++;
    neg = -1;
  }
  n = 0;
  while('0' <= *s && *s <= '9')
 2d6:	00054703          	lbu	a4,0(a0)
 2da:	fd07079b          	addiw	a5,a4,-48
 2de:	0ff7f793          	zext.b	a5,a5
 2e2:	46a5                	li	a3,9
 2e4:	02f6ed63          	bltu	a3,a5,31e <atoi+0x5c>
  n = 0;
 2e8:	4681                	li	a3,0
  while('0' <= *s && *s <= '9')
 2ea:	4625                	li	a2,9
    n = n*10 + *s++ - '0';
 2ec:	0505                	addi	a0,a0,1
 2ee:	0026979b          	slliw	a5,a3,0x2
 2f2:	9fb5                	addw	a5,a5,a3
 2f4:	0017979b          	slliw	a5,a5,0x1
 2f8:	9fb9                	addw	a5,a5,a4
 2fa:	fd07869b          	addiw	a3,a5,-48
  while('0' <= *s && *s <= '9')
 2fe:	00054703          	lbu	a4,0(a0)
 302:	fd07079b          	addiw	a5,a4,-48
 306:	0ff7f793          	zext.b	a5,a5
 30a:	fef671e3          	bgeu	a2,a5,2ec <atoi+0x2a>
  return n * neg;
}
 30e:	02d5853b          	mulw	a0,a1,a3
 312:	6422                	ld	s0,8(sp)
 314:	0141                	addi	sp,sp,16
 316:	8082                	ret
    s++;
 318:	0505                	addi	a0,a0,1
    neg = -1;
 31a:	55fd                	li	a1,-1
 31c:	bf6d                	j	2d6 <atoi+0x14>
  n = 0;
 31e:	4681                	li	a3,0
 320:	b7fd                	j	30e <atoi+0x4c>

0000000000000322 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 322:	1141                	addi	sp,sp,-16
 324:	e422                	sd	s0,8(sp)
 326:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 328:	02b57463          	bgeu	a0,a1,350 <memmove+0x2e>
    while(n-- > 0)
 32c:	00c05f63          	blez	a2,34a <memmove+0x28>
 330:	1602                	slli	a2,a2,0x20
 332:	9201                	srli	a2,a2,0x20
 334:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 338:	872a                	mv	a4,a0
      *dst++ = *src++;
 33a:	0585                	addi	a1,a1,1
 33c:	0705                	addi	a4,a4,1
 33e:	fff5c683          	lbu	a3,-1(a1)
 342:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 346:	fef71ae3          	bne	a4,a5,33a <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 34a:	6422                	ld	s0,8(sp)
 34c:	0141                	addi	sp,sp,16
 34e:	8082                	ret
    dst += n;
 350:	00c50733          	add	a4,a0,a2
    src += n;
 354:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 356:	fec05ae3          	blez	a2,34a <memmove+0x28>
 35a:	fff6079b          	addiw	a5,a2,-1
 35e:	1782                	slli	a5,a5,0x20
 360:	9381                	srli	a5,a5,0x20
 362:	fff7c793          	not	a5,a5
 366:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 368:	15fd                	addi	a1,a1,-1
 36a:	177d                	addi	a4,a4,-1
 36c:	0005c683          	lbu	a3,0(a1)
 370:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 374:	fee79ae3          	bne	a5,a4,368 <memmove+0x46>
 378:	bfc9                	j	34a <memmove+0x28>

000000000000037a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 37a:	1141                	addi	sp,sp,-16
 37c:	e422                	sd	s0,8(sp)
 37e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 380:	ca05                	beqz	a2,3b0 <memcmp+0x36>
 382:	fff6069b          	addiw	a3,a2,-1
 386:	1682                	slli	a3,a3,0x20
 388:	9281                	srli	a3,a3,0x20
 38a:	0685                	addi	a3,a3,1
 38c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 38e:	00054783          	lbu	a5,0(a0)
 392:	0005c703          	lbu	a4,0(a1)
 396:	00e79863          	bne	a5,a4,3a6 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 39a:	0505                	addi	a0,a0,1
    p2++;
 39c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 39e:	fed518e3          	bne	a0,a3,38e <memcmp+0x14>
  }
  return 0;
 3a2:	4501                	li	a0,0
 3a4:	a019                	j	3aa <memcmp+0x30>
      return *p1 - *p2;
 3a6:	40e7853b          	subw	a0,a5,a4
}
 3aa:	6422                	ld	s0,8(sp)
 3ac:	0141                	addi	sp,sp,16
 3ae:	8082                	ret
  return 0;
 3b0:	4501                	li	a0,0
 3b2:	bfe5                	j	3aa <memcmp+0x30>

00000000000003b4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3b4:	1141                	addi	sp,sp,-16
 3b6:	e406                	sd	ra,8(sp)
 3b8:	e022                	sd	s0,0(sp)
 3ba:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3bc:	00000097          	auipc	ra,0x0
 3c0:	f66080e7          	jalr	-154(ra) # 322 <memmove>
}
 3c4:	60a2                	ld	ra,8(sp)
 3c6:	6402                	ld	s0,0(sp)
 3c8:	0141                	addi	sp,sp,16
 3ca:	8082                	ret

00000000000003cc <fork>:
# generated by usys.pl - do not edit
#include "kernel/include/sysnum.h"
.global fork
fork:
 li a7, SYS_fork
 3cc:	4885                	li	a7,1
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3d4:	4889                	li	a7,2
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <wait>:
.global wait
wait:
 li a7, SYS_wait
 3dc:	488d                	li	a7,3
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3e4:	4891                	li	a7,4
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <read>:
.global read
read:
 li a7, SYS_read
 3ec:	4895                	li	a7,5
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <write>:
.global write
write:
 li a7, SYS_write
 3f4:	48c1                	li	a7,16
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <close>:
.global close
close:
 li a7, SYS_close
 3fc:	48d5                	li	a7,21
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <kill>:
.global kill
kill:
 li a7, SYS_kill
 404:	4899                	li	a7,6
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <exec>:
.global exec
exec:
 li a7, SYS_exec
 40c:	489d                	li	a7,7
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <open>:
.global open
open:
 li a7, SYS_open
 414:	48bd                	li	a7,15
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 41c:	48a1                	li	a7,8
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 424:	48d1                	li	a7,20
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 42c:	48a5                	li	a7,9
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <dup>:
.global dup
dup:
 li a7, SYS_dup
 434:	48a9                	li	a7,10
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 43c:	48ad                	li	a7,11
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 444:	48b1                	li	a7,12
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 44c:	48b5                	li	a7,13
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 454:	48b9                	li	a7,14
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <test_proc>:
.global test_proc
test_proc:
 li a7, SYS_test_proc
 45c:	48d9                	li	a7,22
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <dev>:
.global dev
dev:
 li a7, SYS_dev
 464:	48dd                	li	a7,23
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <readdir>:
.global readdir
readdir:
 li a7, SYS_readdir
 46c:	48e1                	li	a7,24
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <getcwd>:
.global getcwd
getcwd:
 li a7, SYS_getcwd
 474:	48e5                	li	a7,25
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <remove>:
.global remove
remove:
 li a7, SYS_remove
 47c:	48c5                	li	a7,17
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <trace>:
.global trace
trace:
 li a7, SYS_trace
 484:	48c9                	li	a7,18
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <sysinfo>:
.global sysinfo
sysinfo:
 li a7, SYS_sysinfo
 48c:	48cd                	li	a7,19
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <rename>:
.global rename
rename:
 li a7, SYS_rename
 494:	48e9                	li	a7,26
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 49c:	1101                	addi	sp,sp,-32
 49e:	ec06                	sd	ra,24(sp)
 4a0:	e822                	sd	s0,16(sp)
 4a2:	1000                	addi	s0,sp,32
 4a4:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4a8:	4605                	li	a2,1
 4aa:	fef40593          	addi	a1,s0,-17
 4ae:	00000097          	auipc	ra,0x0
 4b2:	f46080e7          	jalr	-186(ra) # 3f4 <write>
}
 4b6:	60e2                	ld	ra,24(sp)
 4b8:	6442                	ld	s0,16(sp)
 4ba:	6105                	addi	sp,sp,32
 4bc:	8082                	ret

00000000000004be <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4be:	7139                	addi	sp,sp,-64
 4c0:	fc06                	sd	ra,56(sp)
 4c2:	f822                	sd	s0,48(sp)
 4c4:	f426                	sd	s1,40(sp)
 4c6:	0080                	addi	s0,sp,64
 4c8:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4ca:	c299                	beqz	a3,4d0 <printint+0x12>
 4cc:	0805cb63          	bltz	a1,562 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4d0:	2581                	sext.w	a1,a1
  neg = 0;
 4d2:	4881                	li	a7,0
 4d4:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4d8:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4da:	2601                	sext.w	a2,a2
 4dc:	00000517          	auipc	a0,0x0
 4e0:	4ec50513          	addi	a0,a0,1260 # 9c8 <digits>
 4e4:	883a                	mv	a6,a4
 4e6:	2705                	addiw	a4,a4,1
 4e8:	02c5f7bb          	remuw	a5,a1,a2
 4ec:	1782                	slli	a5,a5,0x20
 4ee:	9381                	srli	a5,a5,0x20
 4f0:	97aa                	add	a5,a5,a0
 4f2:	0007c783          	lbu	a5,0(a5)
 4f6:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4fa:	0005879b          	sext.w	a5,a1
 4fe:	02c5d5bb          	divuw	a1,a1,a2
 502:	0685                	addi	a3,a3,1
 504:	fec7f0e3          	bgeu	a5,a2,4e4 <printint+0x26>
  if(neg)
 508:	00088c63          	beqz	a7,520 <printint+0x62>
    buf[i++] = '-';
 50c:	fd070793          	addi	a5,a4,-48
 510:	00878733          	add	a4,a5,s0
 514:	02d00793          	li	a5,45
 518:	fef70823          	sb	a5,-16(a4)
 51c:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 520:	02e05c63          	blez	a4,558 <printint+0x9a>
 524:	f04a                	sd	s2,32(sp)
 526:	ec4e                	sd	s3,24(sp)
 528:	fc040793          	addi	a5,s0,-64
 52c:	00e78933          	add	s2,a5,a4
 530:	fff78993          	addi	s3,a5,-1
 534:	99ba                	add	s3,s3,a4
 536:	377d                	addiw	a4,a4,-1
 538:	1702                	slli	a4,a4,0x20
 53a:	9301                	srli	a4,a4,0x20
 53c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 540:	fff94583          	lbu	a1,-1(s2)
 544:	8526                	mv	a0,s1
 546:	00000097          	auipc	ra,0x0
 54a:	f56080e7          	jalr	-170(ra) # 49c <putc>
  while(--i >= 0)
 54e:	197d                	addi	s2,s2,-1
 550:	ff3918e3          	bne	s2,s3,540 <printint+0x82>
 554:	7902                	ld	s2,32(sp)
 556:	69e2                	ld	s3,24(sp)
}
 558:	70e2                	ld	ra,56(sp)
 55a:	7442                	ld	s0,48(sp)
 55c:	74a2                	ld	s1,40(sp)
 55e:	6121                	addi	sp,sp,64
 560:	8082                	ret
    x = -xx;
 562:	40b005bb          	negw	a1,a1
    neg = 1;
 566:	4885                	li	a7,1
    x = -xx;
 568:	b7b5                	j	4d4 <printint+0x16>

000000000000056a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 56a:	715d                	addi	sp,sp,-80
 56c:	e486                	sd	ra,72(sp)
 56e:	e0a2                	sd	s0,64(sp)
 570:	f84a                	sd	s2,48(sp)
 572:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 574:	0005c903          	lbu	s2,0(a1)
 578:	1a090a63          	beqz	s2,72c <vprintf+0x1c2>
 57c:	fc26                	sd	s1,56(sp)
 57e:	f44e                	sd	s3,40(sp)
 580:	f052                	sd	s4,32(sp)
 582:	ec56                	sd	s5,24(sp)
 584:	e85a                	sd	s6,16(sp)
 586:	e45e                	sd	s7,8(sp)
 588:	8aaa                	mv	s5,a0
 58a:	8bb2                	mv	s7,a2
 58c:	00158493          	addi	s1,a1,1
  state = 0;
 590:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 592:	02500a13          	li	s4,37
 596:	4b55                	li	s6,21
 598:	a839                	j	5b6 <vprintf+0x4c>
        putc(fd, c);
 59a:	85ca                	mv	a1,s2
 59c:	8556                	mv	a0,s5
 59e:	00000097          	auipc	ra,0x0
 5a2:	efe080e7          	jalr	-258(ra) # 49c <putc>
 5a6:	a019                	j	5ac <vprintf+0x42>
    } else if(state == '%'){
 5a8:	01498d63          	beq	s3,s4,5c2 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 5ac:	0485                	addi	s1,s1,1
 5ae:	fff4c903          	lbu	s2,-1(s1)
 5b2:	16090763          	beqz	s2,720 <vprintf+0x1b6>
    if(state == 0){
 5b6:	fe0999e3          	bnez	s3,5a8 <vprintf+0x3e>
      if(c == '%'){
 5ba:	ff4910e3          	bne	s2,s4,59a <vprintf+0x30>
        state = '%';
 5be:	89d2                	mv	s3,s4
 5c0:	b7f5                	j	5ac <vprintf+0x42>
      if(c == 'd'){
 5c2:	13490463          	beq	s2,s4,6ea <vprintf+0x180>
 5c6:	f9d9079b          	addiw	a5,s2,-99
 5ca:	0ff7f793          	zext.b	a5,a5
 5ce:	12fb6763          	bltu	s6,a5,6fc <vprintf+0x192>
 5d2:	f9d9079b          	addiw	a5,s2,-99
 5d6:	0ff7f713          	zext.b	a4,a5
 5da:	12eb6163          	bltu	s6,a4,6fc <vprintf+0x192>
 5de:	00271793          	slli	a5,a4,0x2
 5e2:	00000717          	auipc	a4,0x0
 5e6:	38e70713          	addi	a4,a4,910 # 970 <malloc+0x154>
 5ea:	97ba                	add	a5,a5,a4
 5ec:	439c                	lw	a5,0(a5)
 5ee:	97ba                	add	a5,a5,a4
 5f0:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 5f2:	008b8913          	addi	s2,s7,8
 5f6:	4685                	li	a3,1
 5f8:	4629                	li	a2,10
 5fa:	000ba583          	lw	a1,0(s7)
 5fe:	8556                	mv	a0,s5
 600:	00000097          	auipc	ra,0x0
 604:	ebe080e7          	jalr	-322(ra) # 4be <printint>
 608:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 60a:	4981                	li	s3,0
 60c:	b745                	j	5ac <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 60e:	008b8913          	addi	s2,s7,8
 612:	4681                	li	a3,0
 614:	4629                	li	a2,10
 616:	000ba583          	lw	a1,0(s7)
 61a:	8556                	mv	a0,s5
 61c:	00000097          	auipc	ra,0x0
 620:	ea2080e7          	jalr	-350(ra) # 4be <printint>
 624:	8bca                	mv	s7,s2
      state = 0;
 626:	4981                	li	s3,0
 628:	b751                	j	5ac <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 62a:	008b8913          	addi	s2,s7,8
 62e:	4681                	li	a3,0
 630:	4641                	li	a2,16
 632:	000ba583          	lw	a1,0(s7)
 636:	8556                	mv	a0,s5
 638:	00000097          	auipc	ra,0x0
 63c:	e86080e7          	jalr	-378(ra) # 4be <printint>
 640:	8bca                	mv	s7,s2
      state = 0;
 642:	4981                	li	s3,0
 644:	b7a5                	j	5ac <vprintf+0x42>
 646:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 648:	008b8c13          	addi	s8,s7,8
 64c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 650:	03000593          	li	a1,48
 654:	8556                	mv	a0,s5
 656:	00000097          	auipc	ra,0x0
 65a:	e46080e7          	jalr	-442(ra) # 49c <putc>
  putc(fd, 'x');
 65e:	07800593          	li	a1,120
 662:	8556                	mv	a0,s5
 664:	00000097          	auipc	ra,0x0
 668:	e38080e7          	jalr	-456(ra) # 49c <putc>
 66c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 66e:	00000b97          	auipc	s7,0x0
 672:	35ab8b93          	addi	s7,s7,858 # 9c8 <digits>
 676:	03c9d793          	srli	a5,s3,0x3c
 67a:	97de                	add	a5,a5,s7
 67c:	0007c583          	lbu	a1,0(a5)
 680:	8556                	mv	a0,s5
 682:	00000097          	auipc	ra,0x0
 686:	e1a080e7          	jalr	-486(ra) # 49c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 68a:	0992                	slli	s3,s3,0x4
 68c:	397d                	addiw	s2,s2,-1
 68e:	fe0914e3          	bnez	s2,676 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 692:	8be2                	mv	s7,s8
      state = 0;
 694:	4981                	li	s3,0
 696:	6c02                	ld	s8,0(sp)
 698:	bf11                	j	5ac <vprintf+0x42>
        s = va_arg(ap, char*);
 69a:	008b8993          	addi	s3,s7,8
 69e:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 6a2:	02090163          	beqz	s2,6c4 <vprintf+0x15a>
        while(*s != 0){
 6a6:	00094583          	lbu	a1,0(s2)
 6aa:	c9a5                	beqz	a1,71a <vprintf+0x1b0>
          putc(fd, *s);
 6ac:	8556                	mv	a0,s5
 6ae:	00000097          	auipc	ra,0x0
 6b2:	dee080e7          	jalr	-530(ra) # 49c <putc>
          s++;
 6b6:	0905                	addi	s2,s2,1
        while(*s != 0){
 6b8:	00094583          	lbu	a1,0(s2)
 6bc:	f9e5                	bnez	a1,6ac <vprintf+0x142>
        s = va_arg(ap, char*);
 6be:	8bce                	mv	s7,s3
      state = 0;
 6c0:	4981                	li	s3,0
 6c2:	b5ed                	j	5ac <vprintf+0x42>
          s = "(null)";
 6c4:	00000917          	auipc	s2,0x0
 6c8:	2a490913          	addi	s2,s2,676 # 968 <malloc+0x14c>
        while(*s != 0){
 6cc:	02800593          	li	a1,40
 6d0:	bff1                	j	6ac <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 6d2:	008b8913          	addi	s2,s7,8
 6d6:	000bc583          	lbu	a1,0(s7)
 6da:	8556                	mv	a0,s5
 6dc:	00000097          	auipc	ra,0x0
 6e0:	dc0080e7          	jalr	-576(ra) # 49c <putc>
 6e4:	8bca                	mv	s7,s2
      state = 0;
 6e6:	4981                	li	s3,0
 6e8:	b5d1                	j	5ac <vprintf+0x42>
        putc(fd, c);
 6ea:	02500593          	li	a1,37
 6ee:	8556                	mv	a0,s5
 6f0:	00000097          	auipc	ra,0x0
 6f4:	dac080e7          	jalr	-596(ra) # 49c <putc>
      state = 0;
 6f8:	4981                	li	s3,0
 6fa:	bd4d                	j	5ac <vprintf+0x42>
        putc(fd, '%');
 6fc:	02500593          	li	a1,37
 700:	8556                	mv	a0,s5
 702:	00000097          	auipc	ra,0x0
 706:	d9a080e7          	jalr	-614(ra) # 49c <putc>
        putc(fd, c);
 70a:	85ca                	mv	a1,s2
 70c:	8556                	mv	a0,s5
 70e:	00000097          	auipc	ra,0x0
 712:	d8e080e7          	jalr	-626(ra) # 49c <putc>
      state = 0;
 716:	4981                	li	s3,0
 718:	bd51                	j	5ac <vprintf+0x42>
        s = va_arg(ap, char*);
 71a:	8bce                	mv	s7,s3
      state = 0;
 71c:	4981                	li	s3,0
 71e:	b579                	j	5ac <vprintf+0x42>
 720:	74e2                	ld	s1,56(sp)
 722:	79a2                	ld	s3,40(sp)
 724:	7a02                	ld	s4,32(sp)
 726:	6ae2                	ld	s5,24(sp)
 728:	6b42                	ld	s6,16(sp)
 72a:	6ba2                	ld	s7,8(sp)
    }
  }
}
 72c:	60a6                	ld	ra,72(sp)
 72e:	6406                	ld	s0,64(sp)
 730:	7942                	ld	s2,48(sp)
 732:	6161                	addi	sp,sp,80
 734:	8082                	ret

0000000000000736 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 736:	715d                	addi	sp,sp,-80
 738:	ec06                	sd	ra,24(sp)
 73a:	e822                	sd	s0,16(sp)
 73c:	1000                	addi	s0,sp,32
 73e:	e010                	sd	a2,0(s0)
 740:	e414                	sd	a3,8(s0)
 742:	e818                	sd	a4,16(s0)
 744:	ec1c                	sd	a5,24(s0)
 746:	03043023          	sd	a6,32(s0)
 74a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 74e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 752:	8622                	mv	a2,s0
 754:	00000097          	auipc	ra,0x0
 758:	e16080e7          	jalr	-490(ra) # 56a <vprintf>
}
 75c:	60e2                	ld	ra,24(sp)
 75e:	6442                	ld	s0,16(sp)
 760:	6161                	addi	sp,sp,80
 762:	8082                	ret

0000000000000764 <printf>:

void
printf(const char *fmt, ...)
{
 764:	711d                	addi	sp,sp,-96
 766:	ec06                	sd	ra,24(sp)
 768:	e822                	sd	s0,16(sp)
 76a:	1000                	addi	s0,sp,32
 76c:	e40c                	sd	a1,8(s0)
 76e:	e810                	sd	a2,16(s0)
 770:	ec14                	sd	a3,24(s0)
 772:	f018                	sd	a4,32(s0)
 774:	f41c                	sd	a5,40(s0)
 776:	03043823          	sd	a6,48(s0)
 77a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 77e:	00840613          	addi	a2,s0,8
 782:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 786:	85aa                	mv	a1,a0
 788:	4505                	li	a0,1
 78a:	00000097          	auipc	ra,0x0
 78e:	de0080e7          	jalr	-544(ra) # 56a <vprintf>
}
 792:	60e2                	ld	ra,24(sp)
 794:	6442                	ld	s0,16(sp)
 796:	6125                	addi	sp,sp,96
 798:	8082                	ret

000000000000079a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 79a:	1141                	addi	sp,sp,-16
 79c:	e422                	sd	s0,8(sp)
 79e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7a0:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7a4:	00000797          	auipc	a5,0x0
 7a8:	23c7b783          	ld	a5,572(a5) # 9e0 <freep>
 7ac:	a02d                	j	7d6 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7ae:	4618                	lw	a4,8(a2)
 7b0:	9f2d                	addw	a4,a4,a1
 7b2:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7b6:	6398                	ld	a4,0(a5)
 7b8:	6310                	ld	a2,0(a4)
 7ba:	a83d                	j	7f8 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7bc:	ff852703          	lw	a4,-8(a0)
 7c0:	9f31                	addw	a4,a4,a2
 7c2:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7c4:	ff053683          	ld	a3,-16(a0)
 7c8:	a091                	j	80c <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ca:	6398                	ld	a4,0(a5)
 7cc:	00e7e463          	bltu	a5,a4,7d4 <free+0x3a>
 7d0:	00e6ea63          	bltu	a3,a4,7e4 <free+0x4a>
{
 7d4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7d6:	fed7fae3          	bgeu	a5,a3,7ca <free+0x30>
 7da:	6398                	ld	a4,0(a5)
 7dc:	00e6e463          	bltu	a3,a4,7e4 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7e0:	fee7eae3          	bltu	a5,a4,7d4 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7e4:	ff852583          	lw	a1,-8(a0)
 7e8:	6390                	ld	a2,0(a5)
 7ea:	02059813          	slli	a6,a1,0x20
 7ee:	01c85713          	srli	a4,a6,0x1c
 7f2:	9736                	add	a4,a4,a3
 7f4:	fae60de3          	beq	a2,a4,7ae <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7f8:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7fc:	4790                	lw	a2,8(a5)
 7fe:	02061593          	slli	a1,a2,0x20
 802:	01c5d713          	srli	a4,a1,0x1c
 806:	973e                	add	a4,a4,a5
 808:	fae68ae3          	beq	a3,a4,7bc <free+0x22>
    p->s.ptr = bp->s.ptr;
 80c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 80e:	00000717          	auipc	a4,0x0
 812:	1cf73923          	sd	a5,466(a4) # 9e0 <freep>
}
 816:	6422                	ld	s0,8(sp)
 818:	0141                	addi	sp,sp,16
 81a:	8082                	ret

000000000000081c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 81c:	7139                	addi	sp,sp,-64
 81e:	fc06                	sd	ra,56(sp)
 820:	f822                	sd	s0,48(sp)
 822:	f426                	sd	s1,40(sp)
 824:	ec4e                	sd	s3,24(sp)
 826:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 828:	02051493          	slli	s1,a0,0x20
 82c:	9081                	srli	s1,s1,0x20
 82e:	04bd                	addi	s1,s1,15
 830:	8091                	srli	s1,s1,0x4
 832:	0014899b          	addiw	s3,s1,1
 836:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 838:	00000517          	auipc	a0,0x0
 83c:	1a853503          	ld	a0,424(a0) # 9e0 <freep>
 840:	c915                	beqz	a0,874 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 842:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 844:	4798                	lw	a4,8(a5)
 846:	08977e63          	bgeu	a4,s1,8e2 <malloc+0xc6>
 84a:	f04a                	sd	s2,32(sp)
 84c:	e852                	sd	s4,16(sp)
 84e:	e456                	sd	s5,8(sp)
 850:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 852:	8a4e                	mv	s4,s3
 854:	0009871b          	sext.w	a4,s3
 858:	6685                	lui	a3,0x1
 85a:	00d77363          	bgeu	a4,a3,860 <malloc+0x44>
 85e:	6a05                	lui	s4,0x1
 860:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 864:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 868:	00000917          	auipc	s2,0x0
 86c:	17890913          	addi	s2,s2,376 # 9e0 <freep>
  if(p == (char*)-1)
 870:	5afd                	li	s5,-1
 872:	a091                	j	8b6 <malloc+0x9a>
 874:	f04a                	sd	s2,32(sp)
 876:	e852                	sd	s4,16(sp)
 878:	e456                	sd	s5,8(sp)
 87a:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 87c:	00000797          	auipc	a5,0x0
 880:	36c78793          	addi	a5,a5,876 # be8 <base>
 884:	00000717          	auipc	a4,0x0
 888:	14f73e23          	sd	a5,348(a4) # 9e0 <freep>
 88c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 88e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 892:	b7c1                	j	852 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 894:	6398                	ld	a4,0(a5)
 896:	e118                	sd	a4,0(a0)
 898:	a08d                	j	8fa <malloc+0xde>
  hp->s.size = nu;
 89a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 89e:	0541                	addi	a0,a0,16
 8a0:	00000097          	auipc	ra,0x0
 8a4:	efa080e7          	jalr	-262(ra) # 79a <free>
  return freep;
 8a8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8ac:	c13d                	beqz	a0,912 <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ae:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8b0:	4798                	lw	a4,8(a5)
 8b2:	02977463          	bgeu	a4,s1,8da <malloc+0xbe>
    if(p == freep)
 8b6:	00093703          	ld	a4,0(s2)
 8ba:	853e                	mv	a0,a5
 8bc:	fef719e3          	bne	a4,a5,8ae <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 8c0:	8552                	mv	a0,s4
 8c2:	00000097          	auipc	ra,0x0
 8c6:	b82080e7          	jalr	-1150(ra) # 444 <sbrk>
  if(p == (char*)-1)
 8ca:	fd5518e3          	bne	a0,s5,89a <malloc+0x7e>
        return 0;
 8ce:	4501                	li	a0,0
 8d0:	7902                	ld	s2,32(sp)
 8d2:	6a42                	ld	s4,16(sp)
 8d4:	6aa2                	ld	s5,8(sp)
 8d6:	6b02                	ld	s6,0(sp)
 8d8:	a03d                	j	906 <malloc+0xea>
 8da:	7902                	ld	s2,32(sp)
 8dc:	6a42                	ld	s4,16(sp)
 8de:	6aa2                	ld	s5,8(sp)
 8e0:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8e2:	fae489e3          	beq	s1,a4,894 <malloc+0x78>
        p->s.size -= nunits;
 8e6:	4137073b          	subw	a4,a4,s3
 8ea:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8ec:	02071693          	slli	a3,a4,0x20
 8f0:	01c6d713          	srli	a4,a3,0x1c
 8f4:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8f6:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8fa:	00000717          	auipc	a4,0x0
 8fe:	0ea73323          	sd	a0,230(a4) # 9e0 <freep>
      return (void*)(p + 1);
 902:	01078513          	addi	a0,a5,16
  }
}
 906:	70e2                	ld	ra,56(sp)
 908:	7442                	ld	s0,48(sp)
 90a:	74a2                	ld	s1,40(sp)
 90c:	69e2                	ld	s3,24(sp)
 90e:	6121                	addi	sp,sp,64
 910:	8082                	ret
 912:	7902                	ld	s2,32(sp)
 914:	6a42                	ld	s4,16(sp)
 916:	6aa2                	ld	s5,8(sp)
 918:	6b02                	ld	s6,0(sp)
 91a:	b7f5                	j	906 <malloc+0xea>
