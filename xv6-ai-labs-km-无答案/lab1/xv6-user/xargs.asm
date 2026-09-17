
xv6-user/_xargs:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <readline>:
/**
 * len:    include the 0 in the end.
 * return: the number of bytes that read successfully (0 in the end is not included)
 */
int readline(int fd, char *buf, int len)
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
  12:	89aa                	mv	s3,a0
  14:	892e                	mv	s2,a1
    char *p = buf;
  16:	84ae                	mv	s1,a1
    while (read(fd, p, 1) != 0 && p < buf + len) {
  18:	00c58a33          	add	s4,a1,a2
        if (*p == '\n') {
  1c:	4aa9                	li	s5,10
    while (read(fd, p, 1) != 0 && p < buf + len) {
  1e:	a011                	j	22 <readline+0x22>
                continue;
            }
            *p = '\0';
            break;
        }
        p++;
  20:	0485                	addi	s1,s1,1
    while (read(fd, p, 1) != 0 && p < buf + len) {
  22:	4605                	li	a2,1
  24:	85a6                	mv	a1,s1
  26:	854e                	mv	a0,s3
  28:	00000097          	auipc	ra,0x0
  2c:	45c080e7          	jalr	1116(ra) # 484 <read>
  30:	c905                	beqz	a0,60 <readline+0x60>
  32:	0344f763          	bgeu	s1,s4,60 <readline+0x60>
        if (*p == '\n') {
  36:	0004c783          	lbu	a5,0(s1)
  3a:	ff5793e3          	bne	a5,s5,20 <readline+0x20>
            if (p == buf) {     // ignore empty line
  3e:	01248f63          	beq	s1,s2,5c <readline+0x5c>
            *p = '\0';
  42:	00048023          	sb	zero,0(s1)
    }
    if (p == buf) {
        return 0;
    }
    return p - buf;
  46:	4124853b          	subw	a0,s1,s2
}
  4a:	70e2                	ld	ra,56(sp)
  4c:	7442                	ld	s0,48(sp)
  4e:	74a2                	ld	s1,40(sp)
  50:	7902                	ld	s2,32(sp)
  52:	69e2                	ld	s3,24(sp)
  54:	6a42                	ld	s4,16(sp)
  56:	6aa2                	ld	s5,8(sp)
  58:	6121                	addi	sp,sp,64
  5a:	8082                	ret
  5c:	84ca                	mv	s1,s2
  5e:	b7d1                	j	22 <readline+0x22>
        return 0;
  60:	4501                	li	a0,0
    if (p == buf) {
  62:	ff2484e3          	beq	s1,s2,4a <readline+0x4a>
  66:	b7c5                	j	46 <readline+0x46>

0000000000000068 <main>:

int main(int argc, char *argv[])
{
  68:	7161                	addi	sp,sp,-432
  6a:	f706                	sd	ra,424(sp)
  6c:	f322                	sd	s0,416(sp)
  6e:	1b00                	addi	s0,sp,432
    if (argc < 2) {
  70:	4785                	li	a5,1
  72:	0aa7d263          	bge	a5,a0,116 <main+0xae>
  76:	ef26                	sd	s1,408(sp)
  78:	eb4a                	sd	s2,400(sp)
  7a:	e74e                	sd	s3,392(sp)
  7c:	84aa                	mv	s1,a0
  7e:	892e                	mv	s2,a1
  80:	00858713          	addi	a4,a1,8
  84:	ed040793          	addi	a5,s0,-304
  88:	0005059b          	sext.w	a1,a0
  8c:	ffe5061b          	addiw	a2,a0,-2
  90:	02061693          	slli	a3,a2,0x20
  94:	01d6d613          	srli	a2,a3,0x1d
  98:	ed840693          	addi	a3,s0,-296
  9c:	9636                	add	a2,a2,a3
    }
    char *argvs[MAXARG];
    char buf[128];
    int i;
    for (i = 1; i < argc; i++) {
        argvs[i - 1] = argv[i];         // argvs[0] = COMMAND
  9e:	6314                	ld	a3,0(a4)
  a0:	e394                	sd	a3,0(a5)
    for (i = 1; i < argc; i++) {
  a2:	0721                	addi	a4,a4,8
  a4:	07a1                	addi	a5,a5,8
  a6:	fec79ce3          	bne	a5,a2,9e <main+0x36>
  aa:	fff5899b          	addiw	s3,a1,-1
    }
    i--;
    if (readline(0, buf, 128) == 0) {   // if there is no input
  ae:	08000613          	li	a2,128
  b2:	e5040593          	addi	a1,s0,-432
  b6:	4501                	li	a0,0
  b8:	00000097          	auipc	ra,0x0
  bc:	f48080e7          	jalr	-184(ra) # 0 <readline>
  c0:	cd25                	beqz	a0,138 <main+0xd0>
            printf("xargs: exec %s fail\n", argv[1]);
            exit(0);
        }
        wait(0);
    } else {
        argvs[i] = buf;
  c2:	00399593          	slli	a1,s3,0x3
  c6:	fd058793          	addi	a5,a1,-48
  ca:	008785b3          	add	a1,a5,s0
  ce:	e5040793          	addi	a5,s0,-432
  d2:	f0f5b023          	sd	a5,-256(a1)
        argvs[i + 1] = 0;
  d6:	048e                	slli	s1,s1,0x3
  d8:	fd048793          	addi	a5,s1,-48
  dc:	008784b3          	add	s1,a5,s0
  e0:	f004b023          	sd	zero,-256(s1)
        do {
            if (fork() == 0) {
  e4:	00000097          	auipc	ra,0x0
  e8:	380080e7          	jalr	896(ra) # 464 <fork>
  ec:	c145                	beqz	a0,18c <main+0x124>
                exec(argv[1], argvs);
                printf("xargs: exec %s fail\n", argv[1]);
                exit(0);
            }
            wait(0);
  ee:	4501                	li	a0,0
  f0:	00000097          	auipc	ra,0x0
  f4:	384080e7          	jalr	900(ra) # 474 <wait>
        } while (readline(0, buf, 128) != 0);
  f8:	08000613          	li	a2,128
  fc:	e5040593          	addi	a1,s0,-432
 100:	4501                	li	a0,0
 102:	00000097          	auipc	ra,0x0
 106:	efe080e7          	jalr	-258(ra) # 0 <readline>
 10a:	fd69                	bnez	a0,e4 <main+0x7c>
    }
    exit(0);
 10c:	4501                	li	a0,0
 10e:	00000097          	auipc	ra,0x0
 112:	35e080e7          	jalr	862(ra) # 46c <exit>
 116:	ef26                	sd	s1,408(sp)
 118:	eb4a                	sd	s2,400(sp)
 11a:	e74e                	sd	s3,392(sp)
        fprintf(2, "Usage: xargs COMMAND [INITIAL-ARGS]...\n");
 11c:	00001597          	auipc	a1,0x1
 120:	89c58593          	addi	a1,a1,-1892 # 9b8 <malloc+0x104>
 124:	4509                	li	a0,2
 126:	00000097          	auipc	ra,0x0
 12a:	6a8080e7          	jalr	1704(ra) # 7ce <fprintf>
        exit(-1);
 12e:	557d                	li	a0,-1
 130:	00000097          	auipc	ra,0x0
 134:	33c080e7          	jalr	828(ra) # 46c <exit>
        argvs[i] = 0;
 138:	00399593          	slli	a1,s3,0x3
 13c:	fd058793          	addi	a5,a1,-48
 140:	008785b3          	add	a1,a5,s0
 144:	f005b023          	sd	zero,-256(a1)
        if (fork() == 0) {
 148:	00000097          	auipc	ra,0x0
 14c:	31c080e7          	jalr	796(ra) # 464 <fork>
 150:	e905                	bnez	a0,180 <main+0x118>
            exec(argv[1], argvs);
 152:	ed040593          	addi	a1,s0,-304
 156:	00893503          	ld	a0,8(s2)
 15a:	00000097          	auipc	ra,0x0
 15e:	34a080e7          	jalr	842(ra) # 4a4 <exec>
            printf("xargs: exec %s fail\n", argv[1]);
 162:	00893583          	ld	a1,8(s2)
 166:	00001517          	auipc	a0,0x1
 16a:	87a50513          	addi	a0,a0,-1926 # 9e0 <malloc+0x12c>
 16e:	00000097          	auipc	ra,0x0
 172:	68e080e7          	jalr	1678(ra) # 7fc <printf>
            exit(0);
 176:	4501                	li	a0,0
 178:	00000097          	auipc	ra,0x0
 17c:	2f4080e7          	jalr	756(ra) # 46c <exit>
        wait(0);
 180:	4501                	li	a0,0
 182:	00000097          	auipc	ra,0x0
 186:	2f2080e7          	jalr	754(ra) # 474 <wait>
 18a:	b749                	j	10c <main+0xa4>
                exec(argv[1], argvs);
 18c:	ed040593          	addi	a1,s0,-304
 190:	00893503          	ld	a0,8(s2)
 194:	00000097          	auipc	ra,0x0
 198:	310080e7          	jalr	784(ra) # 4a4 <exec>
                printf("xargs: exec %s fail\n", argv[1]);
 19c:	00893583          	ld	a1,8(s2)
 1a0:	00001517          	auipc	a0,0x1
 1a4:	84050513          	addi	a0,a0,-1984 # 9e0 <malloc+0x12c>
 1a8:	00000097          	auipc	ra,0x0
 1ac:	654080e7          	jalr	1620(ra) # 7fc <printf>
                exit(0);
 1b0:	4501                	li	a0,0
 1b2:	00000097          	auipc	ra,0x0
 1b6:	2ba080e7          	jalr	698(ra) # 46c <exit>

00000000000001ba <strcpy>:
#include "kernel/include/fcntl.h"
#include "xv6-user/user.h"

char*
strcpy(char *s, const char *t)
{
 1ba:	1141                	addi	sp,sp,-16
 1bc:	e422                	sd	s0,8(sp)
 1be:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1c0:	87aa                	mv	a5,a0
 1c2:	0585                	addi	a1,a1,1
 1c4:	0785                	addi	a5,a5,1
 1c6:	fff5c703          	lbu	a4,-1(a1)
 1ca:	fee78fa3          	sb	a4,-1(a5)
 1ce:	fb75                	bnez	a4,1c2 <strcpy+0x8>
    ;
  return os;
}
 1d0:	6422                	ld	s0,8(sp)
 1d2:	0141                	addi	sp,sp,16
 1d4:	8082                	ret

00000000000001d6 <strcat>:

char*
strcat(char *s, const char *t)
{
 1d6:	1141                	addi	sp,sp,-16
 1d8:	e422                	sd	s0,8(sp)
 1da:	0800                	addi	s0,sp,16
  char *os = s;
  while(*s)
 1dc:	00054783          	lbu	a5,0(a0)
 1e0:	c385                	beqz	a5,200 <strcat+0x2a>
 1e2:	87aa                	mv	a5,a0
    s++;
 1e4:	0785                	addi	a5,a5,1
  while(*s)
 1e6:	0007c703          	lbu	a4,0(a5)
 1ea:	ff6d                	bnez	a4,1e4 <strcat+0xe>
  while((*s++ = *t++))
 1ec:	0585                	addi	a1,a1,1
 1ee:	0785                	addi	a5,a5,1
 1f0:	fff5c703          	lbu	a4,-1(a1)
 1f4:	fee78fa3          	sb	a4,-1(a5)
 1f8:	fb75                	bnez	a4,1ec <strcat+0x16>
    ;
  return os;
}
 1fa:	6422                	ld	s0,8(sp)
 1fc:	0141                	addi	sp,sp,16
 1fe:	8082                	ret
  while(*s)
 200:	87aa                	mv	a5,a0
 202:	b7ed                	j	1ec <strcat+0x16>

0000000000000204 <strcmp>:


int
strcmp(const char *p, const char *q)
{
 204:	1141                	addi	sp,sp,-16
 206:	e422                	sd	s0,8(sp)
 208:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 20a:	00054783          	lbu	a5,0(a0)
 20e:	cb91                	beqz	a5,222 <strcmp+0x1e>
 210:	0005c703          	lbu	a4,0(a1)
 214:	00f71763          	bne	a4,a5,222 <strcmp+0x1e>
    p++, q++;
 218:	0505                	addi	a0,a0,1
 21a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 21c:	00054783          	lbu	a5,0(a0)
 220:	fbe5                	bnez	a5,210 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 222:	0005c503          	lbu	a0,0(a1)
}
 226:	40a7853b          	subw	a0,a5,a0
 22a:	6422                	ld	s0,8(sp)
 22c:	0141                	addi	sp,sp,16
 22e:	8082                	ret

0000000000000230 <strlen>:

uint
strlen(const char *s)
{
 230:	1141                	addi	sp,sp,-16
 232:	e422                	sd	s0,8(sp)
 234:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 236:	00054783          	lbu	a5,0(a0)
 23a:	cf91                	beqz	a5,256 <strlen+0x26>
 23c:	0505                	addi	a0,a0,1
 23e:	87aa                	mv	a5,a0
 240:	86be                	mv	a3,a5
 242:	0785                	addi	a5,a5,1
 244:	fff7c703          	lbu	a4,-1(a5)
 248:	ff65                	bnez	a4,240 <strlen+0x10>
 24a:	40a6853b          	subw	a0,a3,a0
 24e:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 250:	6422                	ld	s0,8(sp)
 252:	0141                	addi	sp,sp,16
 254:	8082                	ret
  for(n = 0; s[n]; n++)
 256:	4501                	li	a0,0
 258:	bfe5                	j	250 <strlen+0x20>

000000000000025a <memset>:

void*
memset(void *dst, int c, uint n)
{
 25a:	1141                	addi	sp,sp,-16
 25c:	e422                	sd	s0,8(sp)
 25e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 260:	ca19                	beqz	a2,276 <memset+0x1c>
 262:	87aa                	mv	a5,a0
 264:	1602                	slli	a2,a2,0x20
 266:	9201                	srli	a2,a2,0x20
 268:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 26c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 270:	0785                	addi	a5,a5,1
 272:	fee79de3          	bne	a5,a4,26c <memset+0x12>
  }
  return dst;
}
 276:	6422                	ld	s0,8(sp)
 278:	0141                	addi	sp,sp,16
 27a:	8082                	ret

000000000000027c <strchr>:

char*
strchr(const char *s, char c)
{
 27c:	1141                	addi	sp,sp,-16
 27e:	e422                	sd	s0,8(sp)
 280:	0800                	addi	s0,sp,16
  for(; *s; s++)
 282:	00054783          	lbu	a5,0(a0)
 286:	cb99                	beqz	a5,29c <strchr+0x20>
    if(*s == c)
 288:	00f58763          	beq	a1,a5,296 <strchr+0x1a>
  for(; *s; s++)
 28c:	0505                	addi	a0,a0,1
 28e:	00054783          	lbu	a5,0(a0)
 292:	fbfd                	bnez	a5,288 <strchr+0xc>
      return (char*)s;
  return 0;
 294:	4501                	li	a0,0
}
 296:	6422                	ld	s0,8(sp)
 298:	0141                	addi	sp,sp,16
 29a:	8082                	ret
  return 0;
 29c:	4501                	li	a0,0
 29e:	bfe5                	j	296 <strchr+0x1a>

00000000000002a0 <gets>:

char*
gets(char *buf, int max)
{
 2a0:	711d                	addi	sp,sp,-96
 2a2:	ec86                	sd	ra,88(sp)
 2a4:	e8a2                	sd	s0,80(sp)
 2a6:	e4a6                	sd	s1,72(sp)
 2a8:	e0ca                	sd	s2,64(sp)
 2aa:	fc4e                	sd	s3,56(sp)
 2ac:	f852                	sd	s4,48(sp)
 2ae:	f456                	sd	s5,40(sp)
 2b0:	f05a                	sd	s6,32(sp)
 2b2:	ec5e                	sd	s7,24(sp)
 2b4:	1080                	addi	s0,sp,96
 2b6:	8baa                	mv	s7,a0
 2b8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2ba:	892a                	mv	s2,a0
 2bc:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2be:	4aa9                	li	s5,10
 2c0:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2c2:	89a6                	mv	s3,s1
 2c4:	2485                	addiw	s1,s1,1
 2c6:	0344d863          	bge	s1,s4,2f6 <gets+0x56>
    cc = read(0, &c, 1);
 2ca:	4605                	li	a2,1
 2cc:	faf40593          	addi	a1,s0,-81
 2d0:	4501                	li	a0,0
 2d2:	00000097          	auipc	ra,0x0
 2d6:	1b2080e7          	jalr	434(ra) # 484 <read>
    if(cc < 1)
 2da:	00a05e63          	blez	a0,2f6 <gets+0x56>
    buf[i++] = c;
 2de:	faf44783          	lbu	a5,-81(s0)
 2e2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2e6:	01578763          	beq	a5,s5,2f4 <gets+0x54>
 2ea:	0905                	addi	s2,s2,1
 2ec:	fd679be3          	bne	a5,s6,2c2 <gets+0x22>
    buf[i++] = c;
 2f0:	89a6                	mv	s3,s1
 2f2:	a011                	j	2f6 <gets+0x56>
 2f4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2f6:	99de                	add	s3,s3,s7
 2f8:	00098023          	sb	zero,0(s3)
  return buf;
}
 2fc:	855e                	mv	a0,s7
 2fe:	60e6                	ld	ra,88(sp)
 300:	6446                	ld	s0,80(sp)
 302:	64a6                	ld	s1,72(sp)
 304:	6906                	ld	s2,64(sp)
 306:	79e2                	ld	s3,56(sp)
 308:	7a42                	ld	s4,48(sp)
 30a:	7aa2                	ld	s5,40(sp)
 30c:	7b02                	ld	s6,32(sp)
 30e:	6be2                	ld	s7,24(sp)
 310:	6125                	addi	sp,sp,96
 312:	8082                	ret

0000000000000314 <stat>:

int
stat(const char *n, struct stat *st)
{
 314:	1101                	addi	sp,sp,-32
 316:	ec06                	sd	ra,24(sp)
 318:	e822                	sd	s0,16(sp)
 31a:	e04a                	sd	s2,0(sp)
 31c:	1000                	addi	s0,sp,32
 31e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 320:	4581                	li	a1,0
 322:	00000097          	auipc	ra,0x0
 326:	18a080e7          	jalr	394(ra) # 4ac <open>
  if(fd < 0)
 32a:	02054663          	bltz	a0,356 <stat+0x42>
 32e:	e426                	sd	s1,8(sp)
 330:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 332:	85ca                	mv	a1,s2
 334:	00000097          	auipc	ra,0x0
 338:	180080e7          	jalr	384(ra) # 4b4 <fstat>
 33c:	892a                	mv	s2,a0
  close(fd);
 33e:	8526                	mv	a0,s1
 340:	00000097          	auipc	ra,0x0
 344:	154080e7          	jalr	340(ra) # 494 <close>
  return r;
 348:	64a2                	ld	s1,8(sp)
}
 34a:	854a                	mv	a0,s2
 34c:	60e2                	ld	ra,24(sp)
 34e:	6442                	ld	s0,16(sp)
 350:	6902                	ld	s2,0(sp)
 352:	6105                	addi	sp,sp,32
 354:	8082                	ret
    return -1;
 356:	597d                	li	s2,-1
 358:	bfcd                	j	34a <stat+0x36>

000000000000035a <atoi>:

int
atoi(const char *s)
{
 35a:	1141                	addi	sp,sp,-16
 35c:	e422                	sd	s0,8(sp)
 35e:	0800                	addi	s0,sp,16
  int n;
  int neg = 1;
  if (*s == '-') {
 360:	00054703          	lbu	a4,0(a0)
 364:	02d00793          	li	a5,45
  int neg = 1;
 368:	4585                	li	a1,1
  if (*s == '-') {
 36a:	04f70363          	beq	a4,a5,3b0 <atoi+0x56>
    s++;
    neg = -1;
  }
  n = 0;
  while('0' <= *s && *s <= '9')
 36e:	00054703          	lbu	a4,0(a0)
 372:	fd07079b          	addiw	a5,a4,-48
 376:	0ff7f793          	zext.b	a5,a5
 37a:	46a5                	li	a3,9
 37c:	02f6ed63          	bltu	a3,a5,3b6 <atoi+0x5c>
  n = 0;
 380:	4681                	li	a3,0
  while('0' <= *s && *s <= '9')
 382:	4625                	li	a2,9
    n = n*10 + *s++ - '0';
 384:	0505                	addi	a0,a0,1
 386:	0026979b          	slliw	a5,a3,0x2
 38a:	9fb5                	addw	a5,a5,a3
 38c:	0017979b          	slliw	a5,a5,0x1
 390:	9fb9                	addw	a5,a5,a4
 392:	fd07869b          	addiw	a3,a5,-48
  while('0' <= *s && *s <= '9')
 396:	00054703          	lbu	a4,0(a0)
 39a:	fd07079b          	addiw	a5,a4,-48
 39e:	0ff7f793          	zext.b	a5,a5
 3a2:	fef671e3          	bgeu	a2,a5,384 <atoi+0x2a>
  return n * neg;
}
 3a6:	02d5853b          	mulw	a0,a1,a3
 3aa:	6422                	ld	s0,8(sp)
 3ac:	0141                	addi	sp,sp,16
 3ae:	8082                	ret
    s++;
 3b0:	0505                	addi	a0,a0,1
    neg = -1;
 3b2:	55fd                	li	a1,-1
 3b4:	bf6d                	j	36e <atoi+0x14>
  n = 0;
 3b6:	4681                	li	a3,0
 3b8:	b7fd                	j	3a6 <atoi+0x4c>

00000000000003ba <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3ba:	1141                	addi	sp,sp,-16
 3bc:	e422                	sd	s0,8(sp)
 3be:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3c0:	02b57463          	bgeu	a0,a1,3e8 <memmove+0x2e>
    while(n-- > 0)
 3c4:	00c05f63          	blez	a2,3e2 <memmove+0x28>
 3c8:	1602                	slli	a2,a2,0x20
 3ca:	9201                	srli	a2,a2,0x20
 3cc:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3d0:	872a                	mv	a4,a0
      *dst++ = *src++;
 3d2:	0585                	addi	a1,a1,1
 3d4:	0705                	addi	a4,a4,1
 3d6:	fff5c683          	lbu	a3,-1(a1)
 3da:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3de:	fef71ae3          	bne	a4,a5,3d2 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3e2:	6422                	ld	s0,8(sp)
 3e4:	0141                	addi	sp,sp,16
 3e6:	8082                	ret
    dst += n;
 3e8:	00c50733          	add	a4,a0,a2
    src += n;
 3ec:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3ee:	fec05ae3          	blez	a2,3e2 <memmove+0x28>
 3f2:	fff6079b          	addiw	a5,a2,-1
 3f6:	1782                	slli	a5,a5,0x20
 3f8:	9381                	srli	a5,a5,0x20
 3fa:	fff7c793          	not	a5,a5
 3fe:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 400:	15fd                	addi	a1,a1,-1
 402:	177d                	addi	a4,a4,-1
 404:	0005c683          	lbu	a3,0(a1)
 408:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 40c:	fee79ae3          	bne	a5,a4,400 <memmove+0x46>
 410:	bfc9                	j	3e2 <memmove+0x28>

0000000000000412 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 412:	1141                	addi	sp,sp,-16
 414:	e422                	sd	s0,8(sp)
 416:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 418:	ca05                	beqz	a2,448 <memcmp+0x36>
 41a:	fff6069b          	addiw	a3,a2,-1
 41e:	1682                	slli	a3,a3,0x20
 420:	9281                	srli	a3,a3,0x20
 422:	0685                	addi	a3,a3,1
 424:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 426:	00054783          	lbu	a5,0(a0)
 42a:	0005c703          	lbu	a4,0(a1)
 42e:	00e79863          	bne	a5,a4,43e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 432:	0505                	addi	a0,a0,1
    p2++;
 434:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 436:	fed518e3          	bne	a0,a3,426 <memcmp+0x14>
  }
  return 0;
 43a:	4501                	li	a0,0
 43c:	a019                	j	442 <memcmp+0x30>
      return *p1 - *p2;
 43e:	40e7853b          	subw	a0,a5,a4
}
 442:	6422                	ld	s0,8(sp)
 444:	0141                	addi	sp,sp,16
 446:	8082                	ret
  return 0;
 448:	4501                	li	a0,0
 44a:	bfe5                	j	442 <memcmp+0x30>

000000000000044c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 44c:	1141                	addi	sp,sp,-16
 44e:	e406                	sd	ra,8(sp)
 450:	e022                	sd	s0,0(sp)
 452:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 454:	00000097          	auipc	ra,0x0
 458:	f66080e7          	jalr	-154(ra) # 3ba <memmove>
}
 45c:	60a2                	ld	ra,8(sp)
 45e:	6402                	ld	s0,0(sp)
 460:	0141                	addi	sp,sp,16
 462:	8082                	ret

0000000000000464 <fork>:
# generated by usys.pl - do not edit
#include "kernel/include/sysnum.h"
.global fork
fork:
 li a7, SYS_fork
 464:	4885                	li	a7,1
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <exit>:
.global exit
exit:
 li a7, SYS_exit
 46c:	4889                	li	a7,2
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <wait>:
.global wait
wait:
 li a7, SYS_wait
 474:	488d                	li	a7,3
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 47c:	4891                	li	a7,4
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <read>:
.global read
read:
 li a7, SYS_read
 484:	4895                	li	a7,5
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <write>:
.global write
write:
 li a7, SYS_write
 48c:	48c1                	li	a7,16
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <close>:
.global close
close:
 li a7, SYS_close
 494:	48d5                	li	a7,21
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <kill>:
.global kill
kill:
 li a7, SYS_kill
 49c:	4899                	li	a7,6
 ecall
 49e:	00000073          	ecall
 ret
 4a2:	8082                	ret

00000000000004a4 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4a4:	489d                	li	a7,7
 ecall
 4a6:	00000073          	ecall
 ret
 4aa:	8082                	ret

00000000000004ac <open>:
.global open
open:
 li a7, SYS_open
 4ac:	48bd                	li	a7,15
 ecall
 4ae:	00000073          	ecall
 ret
 4b2:	8082                	ret

00000000000004b4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4b4:	48a1                	li	a7,8
 ecall
 4b6:	00000073          	ecall
 ret
 4ba:	8082                	ret

00000000000004bc <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4bc:	48d1                	li	a7,20
 ecall
 4be:	00000073          	ecall
 ret
 4c2:	8082                	ret

00000000000004c4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4c4:	48a5                	li	a7,9
 ecall
 4c6:	00000073          	ecall
 ret
 4ca:	8082                	ret

00000000000004cc <dup>:
.global dup
dup:
 li a7, SYS_dup
 4cc:	48a9                	li	a7,10
 ecall
 4ce:	00000073          	ecall
 ret
 4d2:	8082                	ret

00000000000004d4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4d4:	48ad                	li	a7,11
 ecall
 4d6:	00000073          	ecall
 ret
 4da:	8082                	ret

00000000000004dc <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4dc:	48b1                	li	a7,12
 ecall
 4de:	00000073          	ecall
 ret
 4e2:	8082                	ret

00000000000004e4 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4e4:	48b5                	li	a7,13
 ecall
 4e6:	00000073          	ecall
 ret
 4ea:	8082                	ret

00000000000004ec <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4ec:	48b9                	li	a7,14
 ecall
 4ee:	00000073          	ecall
 ret
 4f2:	8082                	ret

00000000000004f4 <test_proc>:
.global test_proc
test_proc:
 li a7, SYS_test_proc
 4f4:	48d9                	li	a7,22
 ecall
 4f6:	00000073          	ecall
 ret
 4fa:	8082                	ret

00000000000004fc <dev>:
.global dev
dev:
 li a7, SYS_dev
 4fc:	48dd                	li	a7,23
 ecall
 4fe:	00000073          	ecall
 ret
 502:	8082                	ret

0000000000000504 <readdir>:
.global readdir
readdir:
 li a7, SYS_readdir
 504:	48e1                	li	a7,24
 ecall
 506:	00000073          	ecall
 ret
 50a:	8082                	ret

000000000000050c <getcwd>:
.global getcwd
getcwd:
 li a7, SYS_getcwd
 50c:	48e5                	li	a7,25
 ecall
 50e:	00000073          	ecall
 ret
 512:	8082                	ret

0000000000000514 <remove>:
.global remove
remove:
 li a7, SYS_remove
 514:	48c5                	li	a7,17
 ecall
 516:	00000073          	ecall
 ret
 51a:	8082                	ret

000000000000051c <trace>:
.global trace
trace:
 li a7, SYS_trace
 51c:	48c9                	li	a7,18
 ecall
 51e:	00000073          	ecall
 ret
 522:	8082                	ret

0000000000000524 <sysinfo>:
.global sysinfo
sysinfo:
 li a7, SYS_sysinfo
 524:	48cd                	li	a7,19
 ecall
 526:	00000073          	ecall
 ret
 52a:	8082                	ret

000000000000052c <rename>:
.global rename
rename:
 li a7, SYS_rename
 52c:	48e9                	li	a7,26
 ecall
 52e:	00000073          	ecall
 ret
 532:	8082                	ret

0000000000000534 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 534:	1101                	addi	sp,sp,-32
 536:	ec06                	sd	ra,24(sp)
 538:	e822                	sd	s0,16(sp)
 53a:	1000                	addi	s0,sp,32
 53c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 540:	4605                	li	a2,1
 542:	fef40593          	addi	a1,s0,-17
 546:	00000097          	auipc	ra,0x0
 54a:	f46080e7          	jalr	-186(ra) # 48c <write>
}
 54e:	60e2                	ld	ra,24(sp)
 550:	6442                	ld	s0,16(sp)
 552:	6105                	addi	sp,sp,32
 554:	8082                	ret

0000000000000556 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 556:	7139                	addi	sp,sp,-64
 558:	fc06                	sd	ra,56(sp)
 55a:	f822                	sd	s0,48(sp)
 55c:	f426                	sd	s1,40(sp)
 55e:	0080                	addi	s0,sp,64
 560:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 562:	c299                	beqz	a3,568 <printint+0x12>
 564:	0805cb63          	bltz	a1,5fa <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 568:	2581                	sext.w	a1,a1
  neg = 0;
 56a:	4881                	li	a7,0
 56c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 570:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 572:	2601                	sext.w	a2,a2
 574:	00000517          	auipc	a0,0x0
 578:	4e450513          	addi	a0,a0,1252 # a58 <digits>
 57c:	883a                	mv	a6,a4
 57e:	2705                	addiw	a4,a4,1
 580:	02c5f7bb          	remuw	a5,a1,a2
 584:	1782                	slli	a5,a5,0x20
 586:	9381                	srli	a5,a5,0x20
 588:	97aa                	add	a5,a5,a0
 58a:	0007c783          	lbu	a5,0(a5)
 58e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 592:	0005879b          	sext.w	a5,a1
 596:	02c5d5bb          	divuw	a1,a1,a2
 59a:	0685                	addi	a3,a3,1
 59c:	fec7f0e3          	bgeu	a5,a2,57c <printint+0x26>
  if(neg)
 5a0:	00088c63          	beqz	a7,5b8 <printint+0x62>
    buf[i++] = '-';
 5a4:	fd070793          	addi	a5,a4,-48
 5a8:	00878733          	add	a4,a5,s0
 5ac:	02d00793          	li	a5,45
 5b0:	fef70823          	sb	a5,-16(a4)
 5b4:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5b8:	02e05c63          	blez	a4,5f0 <printint+0x9a>
 5bc:	f04a                	sd	s2,32(sp)
 5be:	ec4e                	sd	s3,24(sp)
 5c0:	fc040793          	addi	a5,s0,-64
 5c4:	00e78933          	add	s2,a5,a4
 5c8:	fff78993          	addi	s3,a5,-1
 5cc:	99ba                	add	s3,s3,a4
 5ce:	377d                	addiw	a4,a4,-1
 5d0:	1702                	slli	a4,a4,0x20
 5d2:	9301                	srli	a4,a4,0x20
 5d4:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5d8:	fff94583          	lbu	a1,-1(s2)
 5dc:	8526                	mv	a0,s1
 5de:	00000097          	auipc	ra,0x0
 5e2:	f56080e7          	jalr	-170(ra) # 534 <putc>
  while(--i >= 0)
 5e6:	197d                	addi	s2,s2,-1
 5e8:	ff3918e3          	bne	s2,s3,5d8 <printint+0x82>
 5ec:	7902                	ld	s2,32(sp)
 5ee:	69e2                	ld	s3,24(sp)
}
 5f0:	70e2                	ld	ra,56(sp)
 5f2:	7442                	ld	s0,48(sp)
 5f4:	74a2                	ld	s1,40(sp)
 5f6:	6121                	addi	sp,sp,64
 5f8:	8082                	ret
    x = -xx;
 5fa:	40b005bb          	negw	a1,a1
    neg = 1;
 5fe:	4885                	li	a7,1
    x = -xx;
 600:	b7b5                	j	56c <printint+0x16>

0000000000000602 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 602:	715d                	addi	sp,sp,-80
 604:	e486                	sd	ra,72(sp)
 606:	e0a2                	sd	s0,64(sp)
 608:	f84a                	sd	s2,48(sp)
 60a:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 60c:	0005c903          	lbu	s2,0(a1)
 610:	1a090a63          	beqz	s2,7c4 <vprintf+0x1c2>
 614:	fc26                	sd	s1,56(sp)
 616:	f44e                	sd	s3,40(sp)
 618:	f052                	sd	s4,32(sp)
 61a:	ec56                	sd	s5,24(sp)
 61c:	e85a                	sd	s6,16(sp)
 61e:	e45e                	sd	s7,8(sp)
 620:	8aaa                	mv	s5,a0
 622:	8bb2                	mv	s7,a2
 624:	00158493          	addi	s1,a1,1
  state = 0;
 628:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 62a:	02500a13          	li	s4,37
 62e:	4b55                	li	s6,21
 630:	a839                	j	64e <vprintf+0x4c>
        putc(fd, c);
 632:	85ca                	mv	a1,s2
 634:	8556                	mv	a0,s5
 636:	00000097          	auipc	ra,0x0
 63a:	efe080e7          	jalr	-258(ra) # 534 <putc>
 63e:	a019                	j	644 <vprintf+0x42>
    } else if(state == '%'){
 640:	01498d63          	beq	s3,s4,65a <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 644:	0485                	addi	s1,s1,1
 646:	fff4c903          	lbu	s2,-1(s1)
 64a:	16090763          	beqz	s2,7b8 <vprintf+0x1b6>
    if(state == 0){
 64e:	fe0999e3          	bnez	s3,640 <vprintf+0x3e>
      if(c == '%'){
 652:	ff4910e3          	bne	s2,s4,632 <vprintf+0x30>
        state = '%';
 656:	89d2                	mv	s3,s4
 658:	b7f5                	j	644 <vprintf+0x42>
      if(c == 'd'){
 65a:	13490463          	beq	s2,s4,782 <vprintf+0x180>
 65e:	f9d9079b          	addiw	a5,s2,-99
 662:	0ff7f793          	zext.b	a5,a5
 666:	12fb6763          	bltu	s6,a5,794 <vprintf+0x192>
 66a:	f9d9079b          	addiw	a5,s2,-99
 66e:	0ff7f713          	zext.b	a4,a5
 672:	12eb6163          	bltu	s6,a4,794 <vprintf+0x192>
 676:	00271793          	slli	a5,a4,0x2
 67a:	00000717          	auipc	a4,0x0
 67e:	38670713          	addi	a4,a4,902 # a00 <malloc+0x14c>
 682:	97ba                	add	a5,a5,a4
 684:	439c                	lw	a5,0(a5)
 686:	97ba                	add	a5,a5,a4
 688:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 68a:	008b8913          	addi	s2,s7,8
 68e:	4685                	li	a3,1
 690:	4629                	li	a2,10
 692:	000ba583          	lw	a1,0(s7)
 696:	8556                	mv	a0,s5
 698:	00000097          	auipc	ra,0x0
 69c:	ebe080e7          	jalr	-322(ra) # 556 <printint>
 6a0:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 6a2:	4981                	li	s3,0
 6a4:	b745                	j	644 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6a6:	008b8913          	addi	s2,s7,8
 6aa:	4681                	li	a3,0
 6ac:	4629                	li	a2,10
 6ae:	000ba583          	lw	a1,0(s7)
 6b2:	8556                	mv	a0,s5
 6b4:	00000097          	auipc	ra,0x0
 6b8:	ea2080e7          	jalr	-350(ra) # 556 <printint>
 6bc:	8bca                	mv	s7,s2
      state = 0;
 6be:	4981                	li	s3,0
 6c0:	b751                	j	644 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 6c2:	008b8913          	addi	s2,s7,8
 6c6:	4681                	li	a3,0
 6c8:	4641                	li	a2,16
 6ca:	000ba583          	lw	a1,0(s7)
 6ce:	8556                	mv	a0,s5
 6d0:	00000097          	auipc	ra,0x0
 6d4:	e86080e7          	jalr	-378(ra) # 556 <printint>
 6d8:	8bca                	mv	s7,s2
      state = 0;
 6da:	4981                	li	s3,0
 6dc:	b7a5                	j	644 <vprintf+0x42>
 6de:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 6e0:	008b8c13          	addi	s8,s7,8
 6e4:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6e8:	03000593          	li	a1,48
 6ec:	8556                	mv	a0,s5
 6ee:	00000097          	auipc	ra,0x0
 6f2:	e46080e7          	jalr	-442(ra) # 534 <putc>
  putc(fd, 'x');
 6f6:	07800593          	li	a1,120
 6fa:	8556                	mv	a0,s5
 6fc:	00000097          	auipc	ra,0x0
 700:	e38080e7          	jalr	-456(ra) # 534 <putc>
 704:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 706:	00000b97          	auipc	s7,0x0
 70a:	352b8b93          	addi	s7,s7,850 # a58 <digits>
 70e:	03c9d793          	srli	a5,s3,0x3c
 712:	97de                	add	a5,a5,s7
 714:	0007c583          	lbu	a1,0(a5)
 718:	8556                	mv	a0,s5
 71a:	00000097          	auipc	ra,0x0
 71e:	e1a080e7          	jalr	-486(ra) # 534 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 722:	0992                	slli	s3,s3,0x4
 724:	397d                	addiw	s2,s2,-1
 726:	fe0914e3          	bnez	s2,70e <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 72a:	8be2                	mv	s7,s8
      state = 0;
 72c:	4981                	li	s3,0
 72e:	6c02                	ld	s8,0(sp)
 730:	bf11                	j	644 <vprintf+0x42>
        s = va_arg(ap, char*);
 732:	008b8993          	addi	s3,s7,8
 736:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 73a:	02090163          	beqz	s2,75c <vprintf+0x15a>
        while(*s != 0){
 73e:	00094583          	lbu	a1,0(s2)
 742:	c9a5                	beqz	a1,7b2 <vprintf+0x1b0>
          putc(fd, *s);
 744:	8556                	mv	a0,s5
 746:	00000097          	auipc	ra,0x0
 74a:	dee080e7          	jalr	-530(ra) # 534 <putc>
          s++;
 74e:	0905                	addi	s2,s2,1
        while(*s != 0){
 750:	00094583          	lbu	a1,0(s2)
 754:	f9e5                	bnez	a1,744 <vprintf+0x142>
        s = va_arg(ap, char*);
 756:	8bce                	mv	s7,s3
      state = 0;
 758:	4981                	li	s3,0
 75a:	b5ed                	j	644 <vprintf+0x42>
          s = "(null)";
 75c:	00000917          	auipc	s2,0x0
 760:	29c90913          	addi	s2,s2,668 # 9f8 <malloc+0x144>
        while(*s != 0){
 764:	02800593          	li	a1,40
 768:	bff1                	j	744 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 76a:	008b8913          	addi	s2,s7,8
 76e:	000bc583          	lbu	a1,0(s7)
 772:	8556                	mv	a0,s5
 774:	00000097          	auipc	ra,0x0
 778:	dc0080e7          	jalr	-576(ra) # 534 <putc>
 77c:	8bca                	mv	s7,s2
      state = 0;
 77e:	4981                	li	s3,0
 780:	b5d1                	j	644 <vprintf+0x42>
        putc(fd, c);
 782:	02500593          	li	a1,37
 786:	8556                	mv	a0,s5
 788:	00000097          	auipc	ra,0x0
 78c:	dac080e7          	jalr	-596(ra) # 534 <putc>
      state = 0;
 790:	4981                	li	s3,0
 792:	bd4d                	j	644 <vprintf+0x42>
        putc(fd, '%');
 794:	02500593          	li	a1,37
 798:	8556                	mv	a0,s5
 79a:	00000097          	auipc	ra,0x0
 79e:	d9a080e7          	jalr	-614(ra) # 534 <putc>
        putc(fd, c);
 7a2:	85ca                	mv	a1,s2
 7a4:	8556                	mv	a0,s5
 7a6:	00000097          	auipc	ra,0x0
 7aa:	d8e080e7          	jalr	-626(ra) # 534 <putc>
      state = 0;
 7ae:	4981                	li	s3,0
 7b0:	bd51                	j	644 <vprintf+0x42>
        s = va_arg(ap, char*);
 7b2:	8bce                	mv	s7,s3
      state = 0;
 7b4:	4981                	li	s3,0
 7b6:	b579                	j	644 <vprintf+0x42>
 7b8:	74e2                	ld	s1,56(sp)
 7ba:	79a2                	ld	s3,40(sp)
 7bc:	7a02                	ld	s4,32(sp)
 7be:	6ae2                	ld	s5,24(sp)
 7c0:	6b42                	ld	s6,16(sp)
 7c2:	6ba2                	ld	s7,8(sp)
    }
  }
}
 7c4:	60a6                	ld	ra,72(sp)
 7c6:	6406                	ld	s0,64(sp)
 7c8:	7942                	ld	s2,48(sp)
 7ca:	6161                	addi	sp,sp,80
 7cc:	8082                	ret

00000000000007ce <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7ce:	715d                	addi	sp,sp,-80
 7d0:	ec06                	sd	ra,24(sp)
 7d2:	e822                	sd	s0,16(sp)
 7d4:	1000                	addi	s0,sp,32
 7d6:	e010                	sd	a2,0(s0)
 7d8:	e414                	sd	a3,8(s0)
 7da:	e818                	sd	a4,16(s0)
 7dc:	ec1c                	sd	a5,24(s0)
 7de:	03043023          	sd	a6,32(s0)
 7e2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7e6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7ea:	8622                	mv	a2,s0
 7ec:	00000097          	auipc	ra,0x0
 7f0:	e16080e7          	jalr	-490(ra) # 602 <vprintf>
}
 7f4:	60e2                	ld	ra,24(sp)
 7f6:	6442                	ld	s0,16(sp)
 7f8:	6161                	addi	sp,sp,80
 7fa:	8082                	ret

00000000000007fc <printf>:

void
printf(const char *fmt, ...)
{
 7fc:	711d                	addi	sp,sp,-96
 7fe:	ec06                	sd	ra,24(sp)
 800:	e822                	sd	s0,16(sp)
 802:	1000                	addi	s0,sp,32
 804:	e40c                	sd	a1,8(s0)
 806:	e810                	sd	a2,16(s0)
 808:	ec14                	sd	a3,24(s0)
 80a:	f018                	sd	a4,32(s0)
 80c:	f41c                	sd	a5,40(s0)
 80e:	03043823          	sd	a6,48(s0)
 812:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 816:	00840613          	addi	a2,s0,8
 81a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 81e:	85aa                	mv	a1,a0
 820:	4505                	li	a0,1
 822:	00000097          	auipc	ra,0x0
 826:	de0080e7          	jalr	-544(ra) # 602 <vprintf>
}
 82a:	60e2                	ld	ra,24(sp)
 82c:	6442                	ld	s0,16(sp)
 82e:	6125                	addi	sp,sp,96
 830:	8082                	ret

0000000000000832 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 832:	1141                	addi	sp,sp,-16
 834:	e422                	sd	s0,8(sp)
 836:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 838:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 83c:	00000797          	auipc	a5,0x0
 840:	2347b783          	ld	a5,564(a5) # a70 <freep>
 844:	a02d                	j	86e <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 846:	4618                	lw	a4,8(a2)
 848:	9f2d                	addw	a4,a4,a1
 84a:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 84e:	6398                	ld	a4,0(a5)
 850:	6310                	ld	a2,0(a4)
 852:	a83d                	j	890 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 854:	ff852703          	lw	a4,-8(a0)
 858:	9f31                	addw	a4,a4,a2
 85a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 85c:	ff053683          	ld	a3,-16(a0)
 860:	a091                	j	8a4 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 862:	6398                	ld	a4,0(a5)
 864:	00e7e463          	bltu	a5,a4,86c <free+0x3a>
 868:	00e6ea63          	bltu	a3,a4,87c <free+0x4a>
{
 86c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 86e:	fed7fae3          	bgeu	a5,a3,862 <free+0x30>
 872:	6398                	ld	a4,0(a5)
 874:	00e6e463          	bltu	a3,a4,87c <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 878:	fee7eae3          	bltu	a5,a4,86c <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 87c:	ff852583          	lw	a1,-8(a0)
 880:	6390                	ld	a2,0(a5)
 882:	02059813          	slli	a6,a1,0x20
 886:	01c85713          	srli	a4,a6,0x1c
 88a:	9736                	add	a4,a4,a3
 88c:	fae60de3          	beq	a2,a4,846 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 890:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 894:	4790                	lw	a2,8(a5)
 896:	02061593          	slli	a1,a2,0x20
 89a:	01c5d713          	srli	a4,a1,0x1c
 89e:	973e                	add	a4,a4,a5
 8a0:	fae68ae3          	beq	a3,a4,854 <free+0x22>
    p->s.ptr = bp->s.ptr;
 8a4:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8a6:	00000717          	auipc	a4,0x0
 8aa:	1cf73523          	sd	a5,458(a4) # a70 <freep>
}
 8ae:	6422                	ld	s0,8(sp)
 8b0:	0141                	addi	sp,sp,16
 8b2:	8082                	ret

00000000000008b4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8b4:	7139                	addi	sp,sp,-64
 8b6:	fc06                	sd	ra,56(sp)
 8b8:	f822                	sd	s0,48(sp)
 8ba:	f426                	sd	s1,40(sp)
 8bc:	ec4e                	sd	s3,24(sp)
 8be:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8c0:	02051493          	slli	s1,a0,0x20
 8c4:	9081                	srli	s1,s1,0x20
 8c6:	04bd                	addi	s1,s1,15
 8c8:	8091                	srli	s1,s1,0x4
 8ca:	0014899b          	addiw	s3,s1,1
 8ce:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8d0:	00000517          	auipc	a0,0x0
 8d4:	1a053503          	ld	a0,416(a0) # a70 <freep>
 8d8:	c915                	beqz	a0,90c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8da:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8dc:	4798                	lw	a4,8(a5)
 8de:	08977e63          	bgeu	a4,s1,97a <malloc+0xc6>
 8e2:	f04a                	sd	s2,32(sp)
 8e4:	e852                	sd	s4,16(sp)
 8e6:	e456                	sd	s5,8(sp)
 8e8:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8ea:	8a4e                	mv	s4,s3
 8ec:	0009871b          	sext.w	a4,s3
 8f0:	6685                	lui	a3,0x1
 8f2:	00d77363          	bgeu	a4,a3,8f8 <malloc+0x44>
 8f6:	6a05                	lui	s4,0x1
 8f8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8fc:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 900:	00000917          	auipc	s2,0x0
 904:	17090913          	addi	s2,s2,368 # a70 <freep>
  if(p == (char*)-1)
 908:	5afd                	li	s5,-1
 90a:	a091                	j	94e <malloc+0x9a>
 90c:	f04a                	sd	s2,32(sp)
 90e:	e852                	sd	s4,16(sp)
 910:	e456                	sd	s5,8(sp)
 912:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 914:	00000797          	auipc	a5,0x0
 918:	16478793          	addi	a5,a5,356 # a78 <base>
 91c:	00000717          	auipc	a4,0x0
 920:	14f73a23          	sd	a5,340(a4) # a70 <freep>
 924:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 926:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 92a:	b7c1                	j	8ea <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 92c:	6398                	ld	a4,0(a5)
 92e:	e118                	sd	a4,0(a0)
 930:	a08d                	j	992 <malloc+0xde>
  hp->s.size = nu;
 932:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 936:	0541                	addi	a0,a0,16
 938:	00000097          	auipc	ra,0x0
 93c:	efa080e7          	jalr	-262(ra) # 832 <free>
  return freep;
 940:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 944:	c13d                	beqz	a0,9aa <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 946:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 948:	4798                	lw	a4,8(a5)
 94a:	02977463          	bgeu	a4,s1,972 <malloc+0xbe>
    if(p == freep)
 94e:	00093703          	ld	a4,0(s2)
 952:	853e                	mv	a0,a5
 954:	fef719e3          	bne	a4,a5,946 <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 958:	8552                	mv	a0,s4
 95a:	00000097          	auipc	ra,0x0
 95e:	b82080e7          	jalr	-1150(ra) # 4dc <sbrk>
  if(p == (char*)-1)
 962:	fd5518e3          	bne	a0,s5,932 <malloc+0x7e>
        return 0;
 966:	4501                	li	a0,0
 968:	7902                	ld	s2,32(sp)
 96a:	6a42                	ld	s4,16(sp)
 96c:	6aa2                	ld	s5,8(sp)
 96e:	6b02                	ld	s6,0(sp)
 970:	a03d                	j	99e <malloc+0xea>
 972:	7902                	ld	s2,32(sp)
 974:	6a42                	ld	s4,16(sp)
 976:	6aa2                	ld	s5,8(sp)
 978:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 97a:	fae489e3          	beq	s1,a4,92c <malloc+0x78>
        p->s.size -= nunits;
 97e:	4137073b          	subw	a4,a4,s3
 982:	c798                	sw	a4,8(a5)
        p += p->s.size;
 984:	02071693          	slli	a3,a4,0x20
 988:	01c6d713          	srli	a4,a3,0x1c
 98c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 98e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 992:	00000717          	auipc	a4,0x0
 996:	0ca73f23          	sd	a0,222(a4) # a70 <freep>
      return (void*)(p + 1);
 99a:	01078513          	addi	a0,a5,16
  }
}
 99e:	70e2                	ld	ra,56(sp)
 9a0:	7442                	ld	s0,48(sp)
 9a2:	74a2                	ld	s1,40(sp)
 9a4:	69e2                	ld	s3,24(sp)
 9a6:	6121                	addi	sp,sp,64
 9a8:	8082                	ret
 9aa:	7902                	ld	s2,32(sp)
 9ac:	6a42                	ld	s4,16(sp)
 9ae:	6aa2                	ld	s5,8(sp)
 9b0:	6b02                	ld	s6,0(sp)
 9b2:	b7f5                	j	99e <malloc+0xea>
