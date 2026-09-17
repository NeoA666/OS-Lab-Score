
xv6-user/_wc:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <wc>:

char buf[512];

void
wc(int fd, char *name)
{
   0:	7119                	addi	sp,sp,-128
   2:	fc86                	sd	ra,120(sp)
   4:	f8a2                	sd	s0,112(sp)
   6:	f4a6                	sd	s1,104(sp)
   8:	f0ca                	sd	s2,96(sp)
   a:	ecce                	sd	s3,88(sp)
   c:	e8d2                	sd	s4,80(sp)
   e:	e4d6                	sd	s5,72(sp)
  10:	e0da                	sd	s6,64(sp)
  12:	fc5e                	sd	s7,56(sp)
  14:	f862                	sd	s8,48(sp)
  16:	f466                	sd	s9,40(sp)
  18:	f06a                	sd	s10,32(sp)
  1a:	ec6e                	sd	s11,24(sp)
  1c:	0100                	addi	s0,sp,128
  1e:	f8a43423          	sd	a0,-120(s0)
  22:	f8b43023          	sd	a1,-128(s0)
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
  inword = 0;
  26:	4901                	li	s2,0
  l = w = c = 0;
  28:	4d01                	li	s10,0
  2a:	4c81                	li	s9,0
  2c:	4c01                	li	s8,0
  while((n = read(fd, buf, sizeof(buf))) > 0){
  2e:	00001d97          	auipc	s11,0x1
  32:	a52d8d93          	addi	s11,s11,-1454 # a80 <buf>
    for(i=0; i<n; i++){
      c++;
      if(buf[i] == '\n')
  36:	4aa9                	li	s5,10
        l++;
      if(strchr(" \r\t\n\v", buf[i]))
  38:	00001a17          	auipc	s4,0x1
  3c:	968a0a13          	addi	s4,s4,-1688 # 9a0 <malloc+0x104>
        inword = 0;
  40:	4b81                	li	s7,0
  while((n = read(fd, buf, sizeof(buf))) > 0){
  42:	a805                	j	72 <wc+0x72>
      if(strchr(" \r\t\n\v", buf[i]))
  44:	8552                	mv	a0,s4
  46:	00000097          	auipc	ra,0x0
  4a:	21e080e7          	jalr	542(ra) # 264 <strchr>
  4e:	c919                	beqz	a0,64 <wc+0x64>
        inword = 0;
  50:	895e                	mv	s2,s7
    for(i=0; i<n; i++){
  52:	0485                	addi	s1,s1,1
  54:	01348d63          	beq	s1,s3,6e <wc+0x6e>
      if(buf[i] == '\n')
  58:	0004c583          	lbu	a1,0(s1)
  5c:	ff5594e3          	bne	a1,s5,44 <wc+0x44>
        l++;
  60:	2c05                	addiw	s8,s8,1
  62:	b7cd                	j	44 <wc+0x44>
      else if(!inword){
  64:	fe0917e3          	bnez	s2,52 <wc+0x52>
        w++;
  68:	2c85                	addiw	s9,s9,1
        inword = 1;
  6a:	4905                	li	s2,1
  6c:	b7dd                	j	52 <wc+0x52>
  6e:	01ab0d3b          	addw	s10,s6,s10
  while((n = read(fd, buf, sizeof(buf))) > 0){
  72:	20000613          	li	a2,512
  76:	85ee                	mv	a1,s11
  78:	f8843503          	ld	a0,-120(s0)
  7c:	00000097          	auipc	ra,0x0
  80:	3f0080e7          	jalr	1008(ra) # 46c <read>
  84:	8b2a                	mv	s6,a0
  86:	00a05963          	blez	a0,98 <wc+0x98>
    for(i=0; i<n; i++){
  8a:	00001497          	auipc	s1,0x1
  8e:	9f648493          	addi	s1,s1,-1546 # a80 <buf>
  92:	009509b3          	add	s3,a0,s1
  96:	b7c9                	j	58 <wc+0x58>
      }
    }
  }
  if(n < 0){
  98:	02054e63          	bltz	a0,d4 <wc+0xd4>
    printf("wc: read error\n");
    exit(1);
  }
  printf("%d\t%d\t%d\t%s\n", l, w, c, name);
  9c:	f8043703          	ld	a4,-128(s0)
  a0:	86ea                	mv	a3,s10
  a2:	8666                	mv	a2,s9
  a4:	85e2                	mv	a1,s8
  a6:	00001517          	auipc	a0,0x1
  aa:	91a50513          	addi	a0,a0,-1766 # 9c0 <malloc+0x124>
  ae:	00000097          	auipc	ra,0x0
  b2:	736080e7          	jalr	1846(ra) # 7e4 <printf>
}
  b6:	70e6                	ld	ra,120(sp)
  b8:	7446                	ld	s0,112(sp)
  ba:	74a6                	ld	s1,104(sp)
  bc:	7906                	ld	s2,96(sp)
  be:	69e6                	ld	s3,88(sp)
  c0:	6a46                	ld	s4,80(sp)
  c2:	6aa6                	ld	s5,72(sp)
  c4:	6b06                	ld	s6,64(sp)
  c6:	7be2                	ld	s7,56(sp)
  c8:	7c42                	ld	s8,48(sp)
  ca:	7ca2                	ld	s9,40(sp)
  cc:	7d02                	ld	s10,32(sp)
  ce:	6de2                	ld	s11,24(sp)
  d0:	6109                	addi	sp,sp,128
  d2:	8082                	ret
    printf("wc: read error\n");
  d4:	00001517          	auipc	a0,0x1
  d8:	8dc50513          	addi	a0,a0,-1828 # 9b0 <malloc+0x114>
  dc:	00000097          	auipc	ra,0x0
  e0:	708080e7          	jalr	1800(ra) # 7e4 <printf>
    exit(1);
  e4:	4505                	li	a0,1
  e6:	00000097          	auipc	ra,0x0
  ea:	36e080e7          	jalr	878(ra) # 454 <exit>

00000000000000ee <main>:

int
main(int argc, char *argv[])
{
  ee:	7179                	addi	sp,sp,-48
  f0:	f406                	sd	ra,40(sp)
  f2:	f022                	sd	s0,32(sp)
  f4:	1800                	addi	s0,sp,48
  int fd, i;

  if(argc <= 1){
  f6:	4785                	li	a5,1
  f8:	06a7d563          	bge	a5,a0,162 <main+0x74>
  fc:	ec26                	sd	s1,24(sp)
  fe:	e84a                	sd	s2,16(sp)
 100:	e44e                	sd	s3,8(sp)
 102:	89aa                	mv	s3,a0
 104:	84ae                	mv	s1,a1
    wc(0, "");
    exit(0);
  }

  printf("LINE\tWORD\tBYTE\tFILE\n");
 106:	00001517          	auipc	a0,0x1
 10a:	8ca50513          	addi	a0,a0,-1846 # 9d0 <malloc+0x134>
 10e:	00000097          	auipc	ra,0x0
 112:	6d6080e7          	jalr	1750(ra) # 7e4 <printf>
  for(i = 1; i < argc; i++){
 116:	00848913          	addi	s2,s1,8
 11a:	39f9                	addiw	s3,s3,-2
 11c:	02099793          	slli	a5,s3,0x20
 120:	01d7d993          	srli	s3,a5,0x1d
 124:	04c1                	addi	s1,s1,16
 126:	99a6                	add	s3,s3,s1
    if((fd = open(argv[i], 0)) < 0){
 128:	4581                	li	a1,0
 12a:	00093503          	ld	a0,0(s2)
 12e:	00000097          	auipc	ra,0x0
 132:	366080e7          	jalr	870(ra) # 494 <open>
 136:	84aa                	mv	s1,a0
 138:	04054663          	bltz	a0,184 <main+0x96>
      printf("wc: cannot open %s\n", argv[i]);
      exit(1);
    }
    wc(fd, argv[i]);
 13c:	00093583          	ld	a1,0(s2)
 140:	00000097          	auipc	ra,0x0
 144:	ec0080e7          	jalr	-320(ra) # 0 <wc>
    close(fd);
 148:	8526                	mv	a0,s1
 14a:	00000097          	auipc	ra,0x0
 14e:	332080e7          	jalr	818(ra) # 47c <close>
  for(i = 1; i < argc; i++){
 152:	0921                	addi	s2,s2,8
 154:	fd391ae3          	bne	s2,s3,128 <main+0x3a>
  }
  exit(0);
 158:	4501                	li	a0,0
 15a:	00000097          	auipc	ra,0x0
 15e:	2fa080e7          	jalr	762(ra) # 454 <exit>
 162:	ec26                	sd	s1,24(sp)
 164:	e84a                	sd	s2,16(sp)
 166:	e44e                	sd	s3,8(sp)
    wc(0, "");
 168:	00001597          	auipc	a1,0x1
 16c:	84058593          	addi	a1,a1,-1984 # 9a8 <malloc+0x10c>
 170:	4501                	li	a0,0
 172:	00000097          	auipc	ra,0x0
 176:	e8e080e7          	jalr	-370(ra) # 0 <wc>
    exit(0);
 17a:	4501                	li	a0,0
 17c:	00000097          	auipc	ra,0x0
 180:	2d8080e7          	jalr	728(ra) # 454 <exit>
      printf("wc: cannot open %s\n", argv[i]);
 184:	00093583          	ld	a1,0(s2)
 188:	00001517          	auipc	a0,0x1
 18c:	86050513          	addi	a0,a0,-1952 # 9e8 <malloc+0x14c>
 190:	00000097          	auipc	ra,0x0
 194:	654080e7          	jalr	1620(ra) # 7e4 <printf>
      exit(1);
 198:	4505                	li	a0,1
 19a:	00000097          	auipc	ra,0x0
 19e:	2ba080e7          	jalr	698(ra) # 454 <exit>

00000000000001a2 <strcpy>:
#include "kernel/include/fcntl.h"
#include "xv6-user/user.h"

char*
strcpy(char *s, const char *t)
{
 1a2:	1141                	addi	sp,sp,-16
 1a4:	e422                	sd	s0,8(sp)
 1a6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1a8:	87aa                	mv	a5,a0
 1aa:	0585                	addi	a1,a1,1
 1ac:	0785                	addi	a5,a5,1
 1ae:	fff5c703          	lbu	a4,-1(a1)
 1b2:	fee78fa3          	sb	a4,-1(a5)
 1b6:	fb75                	bnez	a4,1aa <strcpy+0x8>
    ;
  return os;
}
 1b8:	6422                	ld	s0,8(sp)
 1ba:	0141                	addi	sp,sp,16
 1bc:	8082                	ret

00000000000001be <strcat>:

char*
strcat(char *s, const char *t)
{
 1be:	1141                	addi	sp,sp,-16
 1c0:	e422                	sd	s0,8(sp)
 1c2:	0800                	addi	s0,sp,16
  char *os = s;
  while(*s)
 1c4:	00054783          	lbu	a5,0(a0)
 1c8:	c385                	beqz	a5,1e8 <strcat+0x2a>
 1ca:	87aa                	mv	a5,a0
    s++;
 1cc:	0785                	addi	a5,a5,1
  while(*s)
 1ce:	0007c703          	lbu	a4,0(a5)
 1d2:	ff6d                	bnez	a4,1cc <strcat+0xe>
  while((*s++ = *t++))
 1d4:	0585                	addi	a1,a1,1
 1d6:	0785                	addi	a5,a5,1
 1d8:	fff5c703          	lbu	a4,-1(a1)
 1dc:	fee78fa3          	sb	a4,-1(a5)
 1e0:	fb75                	bnez	a4,1d4 <strcat+0x16>
    ;
  return os;
}
 1e2:	6422                	ld	s0,8(sp)
 1e4:	0141                	addi	sp,sp,16
 1e6:	8082                	ret
  while(*s)
 1e8:	87aa                	mv	a5,a0
 1ea:	b7ed                	j	1d4 <strcat+0x16>

00000000000001ec <strcmp>:


int
strcmp(const char *p, const char *q)
{
 1ec:	1141                	addi	sp,sp,-16
 1ee:	e422                	sd	s0,8(sp)
 1f0:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1f2:	00054783          	lbu	a5,0(a0)
 1f6:	cb91                	beqz	a5,20a <strcmp+0x1e>
 1f8:	0005c703          	lbu	a4,0(a1)
 1fc:	00f71763          	bne	a4,a5,20a <strcmp+0x1e>
    p++, q++;
 200:	0505                	addi	a0,a0,1
 202:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 204:	00054783          	lbu	a5,0(a0)
 208:	fbe5                	bnez	a5,1f8 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 20a:	0005c503          	lbu	a0,0(a1)
}
 20e:	40a7853b          	subw	a0,a5,a0
 212:	6422                	ld	s0,8(sp)
 214:	0141                	addi	sp,sp,16
 216:	8082                	ret

0000000000000218 <strlen>:

uint
strlen(const char *s)
{
 218:	1141                	addi	sp,sp,-16
 21a:	e422                	sd	s0,8(sp)
 21c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 21e:	00054783          	lbu	a5,0(a0)
 222:	cf91                	beqz	a5,23e <strlen+0x26>
 224:	0505                	addi	a0,a0,1
 226:	87aa                	mv	a5,a0
 228:	86be                	mv	a3,a5
 22a:	0785                	addi	a5,a5,1
 22c:	fff7c703          	lbu	a4,-1(a5)
 230:	ff65                	bnez	a4,228 <strlen+0x10>
 232:	40a6853b          	subw	a0,a3,a0
 236:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 238:	6422                	ld	s0,8(sp)
 23a:	0141                	addi	sp,sp,16
 23c:	8082                	ret
  for(n = 0; s[n]; n++)
 23e:	4501                	li	a0,0
 240:	bfe5                	j	238 <strlen+0x20>

0000000000000242 <memset>:

void*
memset(void *dst, int c, uint n)
{
 242:	1141                	addi	sp,sp,-16
 244:	e422                	sd	s0,8(sp)
 246:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 248:	ca19                	beqz	a2,25e <memset+0x1c>
 24a:	87aa                	mv	a5,a0
 24c:	1602                	slli	a2,a2,0x20
 24e:	9201                	srli	a2,a2,0x20
 250:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 254:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 258:	0785                	addi	a5,a5,1
 25a:	fee79de3          	bne	a5,a4,254 <memset+0x12>
  }
  return dst;
}
 25e:	6422                	ld	s0,8(sp)
 260:	0141                	addi	sp,sp,16
 262:	8082                	ret

0000000000000264 <strchr>:

char*
strchr(const char *s, char c)
{
 264:	1141                	addi	sp,sp,-16
 266:	e422                	sd	s0,8(sp)
 268:	0800                	addi	s0,sp,16
  for(; *s; s++)
 26a:	00054783          	lbu	a5,0(a0)
 26e:	cb99                	beqz	a5,284 <strchr+0x20>
    if(*s == c)
 270:	00f58763          	beq	a1,a5,27e <strchr+0x1a>
  for(; *s; s++)
 274:	0505                	addi	a0,a0,1
 276:	00054783          	lbu	a5,0(a0)
 27a:	fbfd                	bnez	a5,270 <strchr+0xc>
      return (char*)s;
  return 0;
 27c:	4501                	li	a0,0
}
 27e:	6422                	ld	s0,8(sp)
 280:	0141                	addi	sp,sp,16
 282:	8082                	ret
  return 0;
 284:	4501                	li	a0,0
 286:	bfe5                	j	27e <strchr+0x1a>

0000000000000288 <gets>:

char*
gets(char *buf, int max)
{
 288:	711d                	addi	sp,sp,-96
 28a:	ec86                	sd	ra,88(sp)
 28c:	e8a2                	sd	s0,80(sp)
 28e:	e4a6                	sd	s1,72(sp)
 290:	e0ca                	sd	s2,64(sp)
 292:	fc4e                	sd	s3,56(sp)
 294:	f852                	sd	s4,48(sp)
 296:	f456                	sd	s5,40(sp)
 298:	f05a                	sd	s6,32(sp)
 29a:	ec5e                	sd	s7,24(sp)
 29c:	1080                	addi	s0,sp,96
 29e:	8baa                	mv	s7,a0
 2a0:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2a2:	892a                	mv	s2,a0
 2a4:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2a6:	4aa9                	li	s5,10
 2a8:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2aa:	89a6                	mv	s3,s1
 2ac:	2485                	addiw	s1,s1,1
 2ae:	0344d863          	bge	s1,s4,2de <gets+0x56>
    cc = read(0, &c, 1);
 2b2:	4605                	li	a2,1
 2b4:	faf40593          	addi	a1,s0,-81
 2b8:	4501                	li	a0,0
 2ba:	00000097          	auipc	ra,0x0
 2be:	1b2080e7          	jalr	434(ra) # 46c <read>
    if(cc < 1)
 2c2:	00a05e63          	blez	a0,2de <gets+0x56>
    buf[i++] = c;
 2c6:	faf44783          	lbu	a5,-81(s0)
 2ca:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2ce:	01578763          	beq	a5,s5,2dc <gets+0x54>
 2d2:	0905                	addi	s2,s2,1
 2d4:	fd679be3          	bne	a5,s6,2aa <gets+0x22>
    buf[i++] = c;
 2d8:	89a6                	mv	s3,s1
 2da:	a011                	j	2de <gets+0x56>
 2dc:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2de:	99de                	add	s3,s3,s7
 2e0:	00098023          	sb	zero,0(s3)
  return buf;
}
 2e4:	855e                	mv	a0,s7
 2e6:	60e6                	ld	ra,88(sp)
 2e8:	6446                	ld	s0,80(sp)
 2ea:	64a6                	ld	s1,72(sp)
 2ec:	6906                	ld	s2,64(sp)
 2ee:	79e2                	ld	s3,56(sp)
 2f0:	7a42                	ld	s4,48(sp)
 2f2:	7aa2                	ld	s5,40(sp)
 2f4:	7b02                	ld	s6,32(sp)
 2f6:	6be2                	ld	s7,24(sp)
 2f8:	6125                	addi	sp,sp,96
 2fa:	8082                	ret

00000000000002fc <stat>:

int
stat(const char *n, struct stat *st)
{
 2fc:	1101                	addi	sp,sp,-32
 2fe:	ec06                	sd	ra,24(sp)
 300:	e822                	sd	s0,16(sp)
 302:	e04a                	sd	s2,0(sp)
 304:	1000                	addi	s0,sp,32
 306:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 308:	4581                	li	a1,0
 30a:	00000097          	auipc	ra,0x0
 30e:	18a080e7          	jalr	394(ra) # 494 <open>
  if(fd < 0)
 312:	02054663          	bltz	a0,33e <stat+0x42>
 316:	e426                	sd	s1,8(sp)
 318:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 31a:	85ca                	mv	a1,s2
 31c:	00000097          	auipc	ra,0x0
 320:	180080e7          	jalr	384(ra) # 49c <fstat>
 324:	892a                	mv	s2,a0
  close(fd);
 326:	8526                	mv	a0,s1
 328:	00000097          	auipc	ra,0x0
 32c:	154080e7          	jalr	340(ra) # 47c <close>
  return r;
 330:	64a2                	ld	s1,8(sp)
}
 332:	854a                	mv	a0,s2
 334:	60e2                	ld	ra,24(sp)
 336:	6442                	ld	s0,16(sp)
 338:	6902                	ld	s2,0(sp)
 33a:	6105                	addi	sp,sp,32
 33c:	8082                	ret
    return -1;
 33e:	597d                	li	s2,-1
 340:	bfcd                	j	332 <stat+0x36>

0000000000000342 <atoi>:

int
atoi(const char *s)
{
 342:	1141                	addi	sp,sp,-16
 344:	e422                	sd	s0,8(sp)
 346:	0800                	addi	s0,sp,16
  int n;
  int neg = 1;
  if (*s == '-') {
 348:	00054703          	lbu	a4,0(a0)
 34c:	02d00793          	li	a5,45
  int neg = 1;
 350:	4585                	li	a1,1
  if (*s == '-') {
 352:	04f70363          	beq	a4,a5,398 <atoi+0x56>
    s++;
    neg = -1;
  }
  n = 0;
  while('0' <= *s && *s <= '9')
 356:	00054703          	lbu	a4,0(a0)
 35a:	fd07079b          	addiw	a5,a4,-48
 35e:	0ff7f793          	zext.b	a5,a5
 362:	46a5                	li	a3,9
 364:	02f6ed63          	bltu	a3,a5,39e <atoi+0x5c>
  n = 0;
 368:	4681                	li	a3,0
  while('0' <= *s && *s <= '9')
 36a:	4625                	li	a2,9
    n = n*10 + *s++ - '0';
 36c:	0505                	addi	a0,a0,1
 36e:	0026979b          	slliw	a5,a3,0x2
 372:	9fb5                	addw	a5,a5,a3
 374:	0017979b          	slliw	a5,a5,0x1
 378:	9fb9                	addw	a5,a5,a4
 37a:	fd07869b          	addiw	a3,a5,-48
  while('0' <= *s && *s <= '9')
 37e:	00054703          	lbu	a4,0(a0)
 382:	fd07079b          	addiw	a5,a4,-48
 386:	0ff7f793          	zext.b	a5,a5
 38a:	fef671e3          	bgeu	a2,a5,36c <atoi+0x2a>
  return n * neg;
}
 38e:	02d5853b          	mulw	a0,a1,a3
 392:	6422                	ld	s0,8(sp)
 394:	0141                	addi	sp,sp,16
 396:	8082                	ret
    s++;
 398:	0505                	addi	a0,a0,1
    neg = -1;
 39a:	55fd                	li	a1,-1
 39c:	bf6d                	j	356 <atoi+0x14>
  n = 0;
 39e:	4681                	li	a3,0
 3a0:	b7fd                	j	38e <atoi+0x4c>

00000000000003a2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3a2:	1141                	addi	sp,sp,-16
 3a4:	e422                	sd	s0,8(sp)
 3a6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3a8:	02b57463          	bgeu	a0,a1,3d0 <memmove+0x2e>
    while(n-- > 0)
 3ac:	00c05f63          	blez	a2,3ca <memmove+0x28>
 3b0:	1602                	slli	a2,a2,0x20
 3b2:	9201                	srli	a2,a2,0x20
 3b4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3b8:	872a                	mv	a4,a0
      *dst++ = *src++;
 3ba:	0585                	addi	a1,a1,1
 3bc:	0705                	addi	a4,a4,1
 3be:	fff5c683          	lbu	a3,-1(a1)
 3c2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3c6:	fef71ae3          	bne	a4,a5,3ba <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3ca:	6422                	ld	s0,8(sp)
 3cc:	0141                	addi	sp,sp,16
 3ce:	8082                	ret
    dst += n;
 3d0:	00c50733          	add	a4,a0,a2
    src += n;
 3d4:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3d6:	fec05ae3          	blez	a2,3ca <memmove+0x28>
 3da:	fff6079b          	addiw	a5,a2,-1
 3de:	1782                	slli	a5,a5,0x20
 3e0:	9381                	srli	a5,a5,0x20
 3e2:	fff7c793          	not	a5,a5
 3e6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3e8:	15fd                	addi	a1,a1,-1
 3ea:	177d                	addi	a4,a4,-1
 3ec:	0005c683          	lbu	a3,0(a1)
 3f0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3f4:	fee79ae3          	bne	a5,a4,3e8 <memmove+0x46>
 3f8:	bfc9                	j	3ca <memmove+0x28>

00000000000003fa <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3fa:	1141                	addi	sp,sp,-16
 3fc:	e422                	sd	s0,8(sp)
 3fe:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 400:	ca05                	beqz	a2,430 <memcmp+0x36>
 402:	fff6069b          	addiw	a3,a2,-1
 406:	1682                	slli	a3,a3,0x20
 408:	9281                	srli	a3,a3,0x20
 40a:	0685                	addi	a3,a3,1
 40c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 40e:	00054783          	lbu	a5,0(a0)
 412:	0005c703          	lbu	a4,0(a1)
 416:	00e79863          	bne	a5,a4,426 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 41a:	0505                	addi	a0,a0,1
    p2++;
 41c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 41e:	fed518e3          	bne	a0,a3,40e <memcmp+0x14>
  }
  return 0;
 422:	4501                	li	a0,0
 424:	a019                	j	42a <memcmp+0x30>
      return *p1 - *p2;
 426:	40e7853b          	subw	a0,a5,a4
}
 42a:	6422                	ld	s0,8(sp)
 42c:	0141                	addi	sp,sp,16
 42e:	8082                	ret
  return 0;
 430:	4501                	li	a0,0
 432:	bfe5                	j	42a <memcmp+0x30>

0000000000000434 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 434:	1141                	addi	sp,sp,-16
 436:	e406                	sd	ra,8(sp)
 438:	e022                	sd	s0,0(sp)
 43a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 43c:	00000097          	auipc	ra,0x0
 440:	f66080e7          	jalr	-154(ra) # 3a2 <memmove>
}
 444:	60a2                	ld	ra,8(sp)
 446:	6402                	ld	s0,0(sp)
 448:	0141                	addi	sp,sp,16
 44a:	8082                	ret

000000000000044c <fork>:
# generated by usys.pl - do not edit
#include "kernel/include/sysnum.h"
.global fork
fork:
 li a7, SYS_fork
 44c:	4885                	li	a7,1
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <exit>:
.global exit
exit:
 li a7, SYS_exit
 454:	4889                	li	a7,2
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <wait>:
.global wait
wait:
 li a7, SYS_wait
 45c:	488d                	li	a7,3
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 464:	4891                	li	a7,4
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <read>:
.global read
read:
 li a7, SYS_read
 46c:	4895                	li	a7,5
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <write>:
.global write
write:
 li a7, SYS_write
 474:	48c1                	li	a7,16
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <close>:
.global close
close:
 li a7, SYS_close
 47c:	48d5                	li	a7,21
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <kill>:
.global kill
kill:
 li a7, SYS_kill
 484:	4899                	li	a7,6
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <exec>:
.global exec
exec:
 li a7, SYS_exec
 48c:	489d                	li	a7,7
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <open>:
.global open
open:
 li a7, SYS_open
 494:	48bd                	li	a7,15
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 49c:	48a1                	li	a7,8
 ecall
 49e:	00000073          	ecall
 ret
 4a2:	8082                	ret

00000000000004a4 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4a4:	48d1                	li	a7,20
 ecall
 4a6:	00000073          	ecall
 ret
 4aa:	8082                	ret

00000000000004ac <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4ac:	48a5                	li	a7,9
 ecall
 4ae:	00000073          	ecall
 ret
 4b2:	8082                	ret

00000000000004b4 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4b4:	48a9                	li	a7,10
 ecall
 4b6:	00000073          	ecall
 ret
 4ba:	8082                	ret

00000000000004bc <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4bc:	48ad                	li	a7,11
 ecall
 4be:	00000073          	ecall
 ret
 4c2:	8082                	ret

00000000000004c4 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4c4:	48b1                	li	a7,12
 ecall
 4c6:	00000073          	ecall
 ret
 4ca:	8082                	ret

00000000000004cc <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4cc:	48b5                	li	a7,13
 ecall
 4ce:	00000073          	ecall
 ret
 4d2:	8082                	ret

00000000000004d4 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4d4:	48b9                	li	a7,14
 ecall
 4d6:	00000073          	ecall
 ret
 4da:	8082                	ret

00000000000004dc <test_proc>:
.global test_proc
test_proc:
 li a7, SYS_test_proc
 4dc:	48d9                	li	a7,22
 ecall
 4de:	00000073          	ecall
 ret
 4e2:	8082                	ret

00000000000004e4 <dev>:
.global dev
dev:
 li a7, SYS_dev
 4e4:	48dd                	li	a7,23
 ecall
 4e6:	00000073          	ecall
 ret
 4ea:	8082                	ret

00000000000004ec <readdir>:
.global readdir
readdir:
 li a7, SYS_readdir
 4ec:	48e1                	li	a7,24
 ecall
 4ee:	00000073          	ecall
 ret
 4f2:	8082                	ret

00000000000004f4 <getcwd>:
.global getcwd
getcwd:
 li a7, SYS_getcwd
 4f4:	48e5                	li	a7,25
 ecall
 4f6:	00000073          	ecall
 ret
 4fa:	8082                	ret

00000000000004fc <remove>:
.global remove
remove:
 li a7, SYS_remove
 4fc:	48c5                	li	a7,17
 ecall
 4fe:	00000073          	ecall
 ret
 502:	8082                	ret

0000000000000504 <trace>:
.global trace
trace:
 li a7, SYS_trace
 504:	48c9                	li	a7,18
 ecall
 506:	00000073          	ecall
 ret
 50a:	8082                	ret

000000000000050c <sysinfo>:
.global sysinfo
sysinfo:
 li a7, SYS_sysinfo
 50c:	48cd                	li	a7,19
 ecall
 50e:	00000073          	ecall
 ret
 512:	8082                	ret

0000000000000514 <rename>:
.global rename
rename:
 li a7, SYS_rename
 514:	48e9                	li	a7,26
 ecall
 516:	00000073          	ecall
 ret
 51a:	8082                	ret

000000000000051c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 51c:	1101                	addi	sp,sp,-32
 51e:	ec06                	sd	ra,24(sp)
 520:	e822                	sd	s0,16(sp)
 522:	1000                	addi	s0,sp,32
 524:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 528:	4605                	li	a2,1
 52a:	fef40593          	addi	a1,s0,-17
 52e:	00000097          	auipc	ra,0x0
 532:	f46080e7          	jalr	-186(ra) # 474 <write>
}
 536:	60e2                	ld	ra,24(sp)
 538:	6442                	ld	s0,16(sp)
 53a:	6105                	addi	sp,sp,32
 53c:	8082                	ret

000000000000053e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 53e:	7139                	addi	sp,sp,-64
 540:	fc06                	sd	ra,56(sp)
 542:	f822                	sd	s0,48(sp)
 544:	f426                	sd	s1,40(sp)
 546:	0080                	addi	s0,sp,64
 548:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 54a:	c299                	beqz	a3,550 <printint+0x12>
 54c:	0805cb63          	bltz	a1,5e2 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 550:	2581                	sext.w	a1,a1
  neg = 0;
 552:	4881                	li	a7,0
 554:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 558:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 55a:	2601                	sext.w	a2,a2
 55c:	00000517          	auipc	a0,0x0
 560:	50450513          	addi	a0,a0,1284 # a60 <digits>
 564:	883a                	mv	a6,a4
 566:	2705                	addiw	a4,a4,1
 568:	02c5f7bb          	remuw	a5,a1,a2
 56c:	1782                	slli	a5,a5,0x20
 56e:	9381                	srli	a5,a5,0x20
 570:	97aa                	add	a5,a5,a0
 572:	0007c783          	lbu	a5,0(a5)
 576:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 57a:	0005879b          	sext.w	a5,a1
 57e:	02c5d5bb          	divuw	a1,a1,a2
 582:	0685                	addi	a3,a3,1
 584:	fec7f0e3          	bgeu	a5,a2,564 <printint+0x26>
  if(neg)
 588:	00088c63          	beqz	a7,5a0 <printint+0x62>
    buf[i++] = '-';
 58c:	fd070793          	addi	a5,a4,-48
 590:	00878733          	add	a4,a5,s0
 594:	02d00793          	li	a5,45
 598:	fef70823          	sb	a5,-16(a4)
 59c:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5a0:	02e05c63          	blez	a4,5d8 <printint+0x9a>
 5a4:	f04a                	sd	s2,32(sp)
 5a6:	ec4e                	sd	s3,24(sp)
 5a8:	fc040793          	addi	a5,s0,-64
 5ac:	00e78933          	add	s2,a5,a4
 5b0:	fff78993          	addi	s3,a5,-1
 5b4:	99ba                	add	s3,s3,a4
 5b6:	377d                	addiw	a4,a4,-1
 5b8:	1702                	slli	a4,a4,0x20
 5ba:	9301                	srli	a4,a4,0x20
 5bc:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5c0:	fff94583          	lbu	a1,-1(s2)
 5c4:	8526                	mv	a0,s1
 5c6:	00000097          	auipc	ra,0x0
 5ca:	f56080e7          	jalr	-170(ra) # 51c <putc>
  while(--i >= 0)
 5ce:	197d                	addi	s2,s2,-1
 5d0:	ff3918e3          	bne	s2,s3,5c0 <printint+0x82>
 5d4:	7902                	ld	s2,32(sp)
 5d6:	69e2                	ld	s3,24(sp)
}
 5d8:	70e2                	ld	ra,56(sp)
 5da:	7442                	ld	s0,48(sp)
 5dc:	74a2                	ld	s1,40(sp)
 5de:	6121                	addi	sp,sp,64
 5e0:	8082                	ret
    x = -xx;
 5e2:	40b005bb          	negw	a1,a1
    neg = 1;
 5e6:	4885                	li	a7,1
    x = -xx;
 5e8:	b7b5                	j	554 <printint+0x16>

00000000000005ea <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5ea:	715d                	addi	sp,sp,-80
 5ec:	e486                	sd	ra,72(sp)
 5ee:	e0a2                	sd	s0,64(sp)
 5f0:	f84a                	sd	s2,48(sp)
 5f2:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5f4:	0005c903          	lbu	s2,0(a1)
 5f8:	1a090a63          	beqz	s2,7ac <vprintf+0x1c2>
 5fc:	fc26                	sd	s1,56(sp)
 5fe:	f44e                	sd	s3,40(sp)
 600:	f052                	sd	s4,32(sp)
 602:	ec56                	sd	s5,24(sp)
 604:	e85a                	sd	s6,16(sp)
 606:	e45e                	sd	s7,8(sp)
 608:	8aaa                	mv	s5,a0
 60a:	8bb2                	mv	s7,a2
 60c:	00158493          	addi	s1,a1,1
  state = 0;
 610:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 612:	02500a13          	li	s4,37
 616:	4b55                	li	s6,21
 618:	a839                	j	636 <vprintf+0x4c>
        putc(fd, c);
 61a:	85ca                	mv	a1,s2
 61c:	8556                	mv	a0,s5
 61e:	00000097          	auipc	ra,0x0
 622:	efe080e7          	jalr	-258(ra) # 51c <putc>
 626:	a019                	j	62c <vprintf+0x42>
    } else if(state == '%'){
 628:	01498d63          	beq	s3,s4,642 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 62c:	0485                	addi	s1,s1,1
 62e:	fff4c903          	lbu	s2,-1(s1)
 632:	16090763          	beqz	s2,7a0 <vprintf+0x1b6>
    if(state == 0){
 636:	fe0999e3          	bnez	s3,628 <vprintf+0x3e>
      if(c == '%'){
 63a:	ff4910e3          	bne	s2,s4,61a <vprintf+0x30>
        state = '%';
 63e:	89d2                	mv	s3,s4
 640:	b7f5                	j	62c <vprintf+0x42>
      if(c == 'd'){
 642:	13490463          	beq	s2,s4,76a <vprintf+0x180>
 646:	f9d9079b          	addiw	a5,s2,-99
 64a:	0ff7f793          	zext.b	a5,a5
 64e:	12fb6763          	bltu	s6,a5,77c <vprintf+0x192>
 652:	f9d9079b          	addiw	a5,s2,-99
 656:	0ff7f713          	zext.b	a4,a5
 65a:	12eb6163          	bltu	s6,a4,77c <vprintf+0x192>
 65e:	00271793          	slli	a5,a4,0x2
 662:	00000717          	auipc	a4,0x0
 666:	3a670713          	addi	a4,a4,934 # a08 <malloc+0x16c>
 66a:	97ba                	add	a5,a5,a4
 66c:	439c                	lw	a5,0(a5)
 66e:	97ba                	add	a5,a5,a4
 670:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 672:	008b8913          	addi	s2,s7,8
 676:	4685                	li	a3,1
 678:	4629                	li	a2,10
 67a:	000ba583          	lw	a1,0(s7)
 67e:	8556                	mv	a0,s5
 680:	00000097          	auipc	ra,0x0
 684:	ebe080e7          	jalr	-322(ra) # 53e <printint>
 688:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 68a:	4981                	li	s3,0
 68c:	b745                	j	62c <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 68e:	008b8913          	addi	s2,s7,8
 692:	4681                	li	a3,0
 694:	4629                	li	a2,10
 696:	000ba583          	lw	a1,0(s7)
 69a:	8556                	mv	a0,s5
 69c:	00000097          	auipc	ra,0x0
 6a0:	ea2080e7          	jalr	-350(ra) # 53e <printint>
 6a4:	8bca                	mv	s7,s2
      state = 0;
 6a6:	4981                	li	s3,0
 6a8:	b751                	j	62c <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 6aa:	008b8913          	addi	s2,s7,8
 6ae:	4681                	li	a3,0
 6b0:	4641                	li	a2,16
 6b2:	000ba583          	lw	a1,0(s7)
 6b6:	8556                	mv	a0,s5
 6b8:	00000097          	auipc	ra,0x0
 6bc:	e86080e7          	jalr	-378(ra) # 53e <printint>
 6c0:	8bca                	mv	s7,s2
      state = 0;
 6c2:	4981                	li	s3,0
 6c4:	b7a5                	j	62c <vprintf+0x42>
 6c6:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 6c8:	008b8c13          	addi	s8,s7,8
 6cc:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6d0:	03000593          	li	a1,48
 6d4:	8556                	mv	a0,s5
 6d6:	00000097          	auipc	ra,0x0
 6da:	e46080e7          	jalr	-442(ra) # 51c <putc>
  putc(fd, 'x');
 6de:	07800593          	li	a1,120
 6e2:	8556                	mv	a0,s5
 6e4:	00000097          	auipc	ra,0x0
 6e8:	e38080e7          	jalr	-456(ra) # 51c <putc>
 6ec:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6ee:	00000b97          	auipc	s7,0x0
 6f2:	372b8b93          	addi	s7,s7,882 # a60 <digits>
 6f6:	03c9d793          	srli	a5,s3,0x3c
 6fa:	97de                	add	a5,a5,s7
 6fc:	0007c583          	lbu	a1,0(a5)
 700:	8556                	mv	a0,s5
 702:	00000097          	auipc	ra,0x0
 706:	e1a080e7          	jalr	-486(ra) # 51c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 70a:	0992                	slli	s3,s3,0x4
 70c:	397d                	addiw	s2,s2,-1
 70e:	fe0914e3          	bnez	s2,6f6 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 712:	8be2                	mv	s7,s8
      state = 0;
 714:	4981                	li	s3,0
 716:	6c02                	ld	s8,0(sp)
 718:	bf11                	j	62c <vprintf+0x42>
        s = va_arg(ap, char*);
 71a:	008b8993          	addi	s3,s7,8
 71e:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 722:	02090163          	beqz	s2,744 <vprintf+0x15a>
        while(*s != 0){
 726:	00094583          	lbu	a1,0(s2)
 72a:	c9a5                	beqz	a1,79a <vprintf+0x1b0>
          putc(fd, *s);
 72c:	8556                	mv	a0,s5
 72e:	00000097          	auipc	ra,0x0
 732:	dee080e7          	jalr	-530(ra) # 51c <putc>
          s++;
 736:	0905                	addi	s2,s2,1
        while(*s != 0){
 738:	00094583          	lbu	a1,0(s2)
 73c:	f9e5                	bnez	a1,72c <vprintf+0x142>
        s = va_arg(ap, char*);
 73e:	8bce                	mv	s7,s3
      state = 0;
 740:	4981                	li	s3,0
 742:	b5ed                	j	62c <vprintf+0x42>
          s = "(null)";
 744:	00000917          	auipc	s2,0x0
 748:	2bc90913          	addi	s2,s2,700 # a00 <malloc+0x164>
        while(*s != 0){
 74c:	02800593          	li	a1,40
 750:	bff1                	j	72c <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 752:	008b8913          	addi	s2,s7,8
 756:	000bc583          	lbu	a1,0(s7)
 75a:	8556                	mv	a0,s5
 75c:	00000097          	auipc	ra,0x0
 760:	dc0080e7          	jalr	-576(ra) # 51c <putc>
 764:	8bca                	mv	s7,s2
      state = 0;
 766:	4981                	li	s3,0
 768:	b5d1                	j	62c <vprintf+0x42>
        putc(fd, c);
 76a:	02500593          	li	a1,37
 76e:	8556                	mv	a0,s5
 770:	00000097          	auipc	ra,0x0
 774:	dac080e7          	jalr	-596(ra) # 51c <putc>
      state = 0;
 778:	4981                	li	s3,0
 77a:	bd4d                	j	62c <vprintf+0x42>
        putc(fd, '%');
 77c:	02500593          	li	a1,37
 780:	8556                	mv	a0,s5
 782:	00000097          	auipc	ra,0x0
 786:	d9a080e7          	jalr	-614(ra) # 51c <putc>
        putc(fd, c);
 78a:	85ca                	mv	a1,s2
 78c:	8556                	mv	a0,s5
 78e:	00000097          	auipc	ra,0x0
 792:	d8e080e7          	jalr	-626(ra) # 51c <putc>
      state = 0;
 796:	4981                	li	s3,0
 798:	bd51                	j	62c <vprintf+0x42>
        s = va_arg(ap, char*);
 79a:	8bce                	mv	s7,s3
      state = 0;
 79c:	4981                	li	s3,0
 79e:	b579                	j	62c <vprintf+0x42>
 7a0:	74e2                	ld	s1,56(sp)
 7a2:	79a2                	ld	s3,40(sp)
 7a4:	7a02                	ld	s4,32(sp)
 7a6:	6ae2                	ld	s5,24(sp)
 7a8:	6b42                	ld	s6,16(sp)
 7aa:	6ba2                	ld	s7,8(sp)
    }
  }
}
 7ac:	60a6                	ld	ra,72(sp)
 7ae:	6406                	ld	s0,64(sp)
 7b0:	7942                	ld	s2,48(sp)
 7b2:	6161                	addi	sp,sp,80
 7b4:	8082                	ret

00000000000007b6 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7b6:	715d                	addi	sp,sp,-80
 7b8:	ec06                	sd	ra,24(sp)
 7ba:	e822                	sd	s0,16(sp)
 7bc:	1000                	addi	s0,sp,32
 7be:	e010                	sd	a2,0(s0)
 7c0:	e414                	sd	a3,8(s0)
 7c2:	e818                	sd	a4,16(s0)
 7c4:	ec1c                	sd	a5,24(s0)
 7c6:	03043023          	sd	a6,32(s0)
 7ca:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7ce:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7d2:	8622                	mv	a2,s0
 7d4:	00000097          	auipc	ra,0x0
 7d8:	e16080e7          	jalr	-490(ra) # 5ea <vprintf>
}
 7dc:	60e2                	ld	ra,24(sp)
 7de:	6442                	ld	s0,16(sp)
 7e0:	6161                	addi	sp,sp,80
 7e2:	8082                	ret

00000000000007e4 <printf>:

void
printf(const char *fmt, ...)
{
 7e4:	711d                	addi	sp,sp,-96
 7e6:	ec06                	sd	ra,24(sp)
 7e8:	e822                	sd	s0,16(sp)
 7ea:	1000                	addi	s0,sp,32
 7ec:	e40c                	sd	a1,8(s0)
 7ee:	e810                	sd	a2,16(s0)
 7f0:	ec14                	sd	a3,24(s0)
 7f2:	f018                	sd	a4,32(s0)
 7f4:	f41c                	sd	a5,40(s0)
 7f6:	03043823          	sd	a6,48(s0)
 7fa:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7fe:	00840613          	addi	a2,s0,8
 802:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 806:	85aa                	mv	a1,a0
 808:	4505                	li	a0,1
 80a:	00000097          	auipc	ra,0x0
 80e:	de0080e7          	jalr	-544(ra) # 5ea <vprintf>
}
 812:	60e2                	ld	ra,24(sp)
 814:	6442                	ld	s0,16(sp)
 816:	6125                	addi	sp,sp,96
 818:	8082                	ret

000000000000081a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 81a:	1141                	addi	sp,sp,-16
 81c:	e422                	sd	s0,8(sp)
 81e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 820:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 824:	00000797          	auipc	a5,0x0
 828:	2547b783          	ld	a5,596(a5) # a78 <freep>
 82c:	a02d                	j	856 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 82e:	4618                	lw	a4,8(a2)
 830:	9f2d                	addw	a4,a4,a1
 832:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 836:	6398                	ld	a4,0(a5)
 838:	6310                	ld	a2,0(a4)
 83a:	a83d                	j	878 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 83c:	ff852703          	lw	a4,-8(a0)
 840:	9f31                	addw	a4,a4,a2
 842:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 844:	ff053683          	ld	a3,-16(a0)
 848:	a091                	j	88c <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 84a:	6398                	ld	a4,0(a5)
 84c:	00e7e463          	bltu	a5,a4,854 <free+0x3a>
 850:	00e6ea63          	bltu	a3,a4,864 <free+0x4a>
{
 854:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 856:	fed7fae3          	bgeu	a5,a3,84a <free+0x30>
 85a:	6398                	ld	a4,0(a5)
 85c:	00e6e463          	bltu	a3,a4,864 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 860:	fee7eae3          	bltu	a5,a4,854 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 864:	ff852583          	lw	a1,-8(a0)
 868:	6390                	ld	a2,0(a5)
 86a:	02059813          	slli	a6,a1,0x20
 86e:	01c85713          	srli	a4,a6,0x1c
 872:	9736                	add	a4,a4,a3
 874:	fae60de3          	beq	a2,a4,82e <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 878:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 87c:	4790                	lw	a2,8(a5)
 87e:	02061593          	slli	a1,a2,0x20
 882:	01c5d713          	srli	a4,a1,0x1c
 886:	973e                	add	a4,a4,a5
 888:	fae68ae3          	beq	a3,a4,83c <free+0x22>
    p->s.ptr = bp->s.ptr;
 88c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 88e:	00000717          	auipc	a4,0x0
 892:	1ef73523          	sd	a5,490(a4) # a78 <freep>
}
 896:	6422                	ld	s0,8(sp)
 898:	0141                	addi	sp,sp,16
 89a:	8082                	ret

000000000000089c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 89c:	7139                	addi	sp,sp,-64
 89e:	fc06                	sd	ra,56(sp)
 8a0:	f822                	sd	s0,48(sp)
 8a2:	f426                	sd	s1,40(sp)
 8a4:	ec4e                	sd	s3,24(sp)
 8a6:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8a8:	02051493          	slli	s1,a0,0x20
 8ac:	9081                	srli	s1,s1,0x20
 8ae:	04bd                	addi	s1,s1,15
 8b0:	8091                	srli	s1,s1,0x4
 8b2:	0014899b          	addiw	s3,s1,1
 8b6:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8b8:	00000517          	auipc	a0,0x0
 8bc:	1c053503          	ld	a0,448(a0) # a78 <freep>
 8c0:	c915                	beqz	a0,8f4 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8c2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8c4:	4798                	lw	a4,8(a5)
 8c6:	08977e63          	bgeu	a4,s1,962 <malloc+0xc6>
 8ca:	f04a                	sd	s2,32(sp)
 8cc:	e852                	sd	s4,16(sp)
 8ce:	e456                	sd	s5,8(sp)
 8d0:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8d2:	8a4e                	mv	s4,s3
 8d4:	0009871b          	sext.w	a4,s3
 8d8:	6685                	lui	a3,0x1
 8da:	00d77363          	bgeu	a4,a3,8e0 <malloc+0x44>
 8de:	6a05                	lui	s4,0x1
 8e0:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8e4:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8e8:	00000917          	auipc	s2,0x0
 8ec:	19090913          	addi	s2,s2,400 # a78 <freep>
  if(p == (char*)-1)
 8f0:	5afd                	li	s5,-1
 8f2:	a091                	j	936 <malloc+0x9a>
 8f4:	f04a                	sd	s2,32(sp)
 8f6:	e852                	sd	s4,16(sp)
 8f8:	e456                	sd	s5,8(sp)
 8fa:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8fc:	00000797          	auipc	a5,0x0
 900:	38478793          	addi	a5,a5,900 # c80 <base>
 904:	00000717          	auipc	a4,0x0
 908:	16f73a23          	sd	a5,372(a4) # a78 <freep>
 90c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 90e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 912:	b7c1                	j	8d2 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 914:	6398                	ld	a4,0(a5)
 916:	e118                	sd	a4,0(a0)
 918:	a08d                	j	97a <malloc+0xde>
  hp->s.size = nu;
 91a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 91e:	0541                	addi	a0,a0,16
 920:	00000097          	auipc	ra,0x0
 924:	efa080e7          	jalr	-262(ra) # 81a <free>
  return freep;
 928:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 92c:	c13d                	beqz	a0,992 <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 92e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 930:	4798                	lw	a4,8(a5)
 932:	02977463          	bgeu	a4,s1,95a <malloc+0xbe>
    if(p == freep)
 936:	00093703          	ld	a4,0(s2)
 93a:	853e                	mv	a0,a5
 93c:	fef719e3          	bne	a4,a5,92e <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 940:	8552                	mv	a0,s4
 942:	00000097          	auipc	ra,0x0
 946:	b82080e7          	jalr	-1150(ra) # 4c4 <sbrk>
  if(p == (char*)-1)
 94a:	fd5518e3          	bne	a0,s5,91a <malloc+0x7e>
        return 0;
 94e:	4501                	li	a0,0
 950:	7902                	ld	s2,32(sp)
 952:	6a42                	ld	s4,16(sp)
 954:	6aa2                	ld	s5,8(sp)
 956:	6b02                	ld	s6,0(sp)
 958:	a03d                	j	986 <malloc+0xea>
 95a:	7902                	ld	s2,32(sp)
 95c:	6a42                	ld	s4,16(sp)
 95e:	6aa2                	ld	s5,8(sp)
 960:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 962:	fae489e3          	beq	s1,a4,914 <malloc+0x78>
        p->s.size -= nunits;
 966:	4137073b          	subw	a4,a4,s3
 96a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 96c:	02071693          	slli	a3,a4,0x20
 970:	01c6d713          	srli	a4,a3,0x1c
 974:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 976:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 97a:	00000717          	auipc	a4,0x0
 97e:	0ea73f23          	sd	a0,254(a4) # a78 <freep>
      return (void*)(p + 1);
 982:	01078513          	addi	a0,a5,16
  }
}
 986:	70e2                	ld	ra,56(sp)
 988:	7442                	ld	s0,48(sp)
 98a:	74a2                	ld	s1,40(sp)
 98c:	69e2                	ld	s3,24(sp)
 98e:	6121                	addi	sp,sp,64
 990:	8082                	ret
 992:	7902                	ld	s2,32(sp)
 994:	6a42                	ld	s4,16(sp)
 996:	6aa2                	ld	s5,8(sp)
 998:	6b02                	ld	s6,0(sp)
 99a:	b7f5                	j	986 <malloc+0xea>
