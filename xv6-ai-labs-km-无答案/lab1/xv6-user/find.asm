
xv6-user/_find:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <find>:
#include "xv6-user/user.h"

static char path[512];

void find(char *filename)
{
   0:	7119                	addi	sp,sp,-128
   2:	fc86                	sd	ra,120(sp)
   4:	f8a2                	sd	s0,112(sp)
   6:	ecce                	sd	s3,88(sp)
   8:	0100                	addi	s0,sp,128
   a:	89aa                	mv	s3,a0
    int fd;
    struct stat st;
    if ((fd = open(path, O_RDONLY)) < 0) {
   c:	4581                	li	a1,0
   e:	00001517          	auipc	a0,0x1
  12:	af250513          	addi	a0,a0,-1294 # b00 <path>
  16:	00000097          	auipc	ra,0x0
  1a:	4da080e7          	jalr	1242(ra) # 4f0 <open>
  1e:	02054c63          	bltz	a0,56 <find+0x56>
  22:	f4a6                	sd	s1,104(sp)
  24:	84aa                	mv	s1,a0
        fprintf(2, "find: cannot open %s\n", path);
        return;
    }
    if (fstat(fd, &st) < 0) {
  26:	f8840593          	addi	a1,s0,-120
  2a:	00000097          	auipc	ra,0x0
  2e:	4ce080e7          	jalr	1230(ra) # 4f8 <fstat>
  32:	04054063          	bltz	a0,72 <find+0x72>
        fprintf(2, "find: cannot stat %s\n", path);
        close(fd);
        return;
    }
    if (st.type != T_DIR) {
  36:	fb041703          	lh	a4,-80(s0)
  3a:	4785                	li	a5,1
  3c:	04f70f63          	beq	a4,a5,9a <find+0x9a>
        close(fd);
  40:	8526                	mv	a0,s1
  42:	00000097          	auipc	ra,0x0
  46:	496080e7          	jalr	1174(ra) # 4d8 <close>
        return;
  4a:	74a6                	ld	s1,104(sp)
        }
        find(filename);
    }
    close(fd);
    return;
}
  4c:	70e6                	ld	ra,120(sp)
  4e:	7446                	ld	s0,112(sp)
  50:	69e6                	ld	s3,88(sp)
  52:	6109                	addi	sp,sp,128
  54:	8082                	ret
        fprintf(2, "find: cannot open %s\n", path);
  56:	00001617          	auipc	a2,0x1
  5a:	aaa60613          	addi	a2,a2,-1366 # b00 <path>
  5e:	00001597          	auipc	a1,0x1
  62:	99a58593          	addi	a1,a1,-1638 # 9f8 <malloc+0x100>
  66:	4509                	li	a0,2
  68:	00000097          	auipc	ra,0x0
  6c:	7aa080e7          	jalr	1962(ra) # 812 <fprintf>
        return;
  70:	bff1                	j	4c <find+0x4c>
        fprintf(2, "find: cannot stat %s\n", path);
  72:	00001617          	auipc	a2,0x1
  76:	a8e60613          	addi	a2,a2,-1394 # b00 <path>
  7a:	00001597          	auipc	a1,0x1
  7e:	99e58593          	addi	a1,a1,-1634 # a18 <malloc+0x120>
  82:	4509                	li	a0,2
  84:	00000097          	auipc	ra,0x0
  88:	78e080e7          	jalr	1934(ra) # 812 <fprintf>
        close(fd);
  8c:	8526                	mv	a0,s1
  8e:	00000097          	auipc	ra,0x0
  92:	44a080e7          	jalr	1098(ra) # 4d8 <close>
        return;
  96:	74a6                	ld	s1,104(sp)
  98:	bf55                	j	4c <find+0x4c>
    if (strlen(path) + 255 + 2 > sizeof(path)) {
  9a:	00001517          	auipc	a0,0x1
  9e:	a6650513          	addi	a0,a0,-1434 # b00 <path>
  a2:	00000097          	auipc	ra,0x0
  a6:	1d2080e7          	jalr	466(ra) # 274 <strlen>
  aa:	1015051b          	addiw	a0,a0,257
  ae:	20000793          	li	a5,512
  b2:	0aa7e363          	bltu	a5,a0,158 <find+0x158>
  b6:	f0ca                	sd	s2,96(sp)
  b8:	e8d2                	sd	s4,80(sp)
  ba:	e4d6                	sd	s5,72(sp)
    char *p = path + strlen(path) - 1;
  bc:	00001917          	auipc	s2,0x1
  c0:	a4490913          	addi	s2,s2,-1468 # b00 <path>
  c4:	854a                	mv	a0,s2
  c6:	00000097          	auipc	ra,0x0
  ca:	1ae080e7          	jalr	430(ra) # 274 <strlen>
  ce:	1502                	slli	a0,a0,0x20
  d0:	9101                	srli	a0,a0,0x20
  d2:	fff50793          	addi	a5,a0,-1
  d6:	993e                	add	s2,s2,a5
    if (*p != '/') {
  d8:	00094703          	lbu	a4,0(s2)
  dc:	02f00793          	li	a5,47
  e0:	00f70963          	beq	a4,a5,f2 <find+0xf2>
        *++p = '/';
  e4:	00f900a3          	sb	a5,1(s2)
  e8:	00001917          	auipc	s2,0x1
  ec:	a1890913          	addi	s2,s2,-1512 # b00 <path>
  f0:	992a                	add	s2,s2,a0
    p++;
  f2:	0905                	addi	s2,s2,1
        if (strcmp(p, ".") == 0 || strcmp(p, "..") == 0) {
  f4:	00001a17          	auipc	s4,0x1
  f8:	954a0a13          	addi	s4,s4,-1708 # a48 <malloc+0x150>
  fc:	00001a97          	auipc	s5,0x1
 100:	954a8a93          	addi	s5,s5,-1708 # a50 <malloc+0x158>
    while (readdir(fd, &st)) {
 104:	f8840593          	addi	a1,s0,-120
 108:	8526                	mv	a0,s1
 10a:	00000097          	auipc	ra,0x0
 10e:	43e080e7          	jalr	1086(ra) # 548 <readdir>
 112:	c149                	beqz	a0,194 <find+0x194>
        strcpy(p, st.name);
 114:	f8840593          	addi	a1,s0,-120
 118:	854a                	mv	a0,s2
 11a:	00000097          	auipc	ra,0x0
 11e:	0e4080e7          	jalr	228(ra) # 1fe <strcpy>
        if (strcmp(p, ".") == 0 || strcmp(p, "..") == 0) {
 122:	85d2                	mv	a1,s4
 124:	854a                	mv	a0,s2
 126:	00000097          	auipc	ra,0x0
 12a:	122080e7          	jalr	290(ra) # 248 <strcmp>
 12e:	d979                	beqz	a0,104 <find+0x104>
 130:	85d6                	mv	a1,s5
 132:	854a                	mv	a0,s2
 134:	00000097          	auipc	ra,0x0
 138:	114080e7          	jalr	276(ra) # 248 <strcmp>
 13c:	d561                	beqz	a0,104 <find+0x104>
        if (strcmp(p, filename) == 0) {
 13e:	85ce                	mv	a1,s3
 140:	854a                	mv	a0,s2
 142:	00000097          	auipc	ra,0x0
 146:	106080e7          	jalr	262(ra) # 248 <strcmp>
 14a:	c51d                	beqz	a0,178 <find+0x178>
        find(filename);
 14c:	854e                	mv	a0,s3
 14e:	00000097          	auipc	ra,0x0
 152:	eb2080e7          	jalr	-334(ra) # 0 <find>
 156:	b77d                	j	104 <find+0x104>
        fprintf(2, "find: path too long\n");
 158:	00001597          	auipc	a1,0x1
 15c:	8d858593          	addi	a1,a1,-1832 # a30 <malloc+0x138>
 160:	4509                	li	a0,2
 162:	00000097          	auipc	ra,0x0
 166:	6b0080e7          	jalr	1712(ra) # 812 <fprintf>
        close(fd);
 16a:	8526                	mv	a0,s1
 16c:	00000097          	auipc	ra,0x0
 170:	36c080e7          	jalr	876(ra) # 4d8 <close>
        return;
 174:	74a6                	ld	s1,104(sp)
 176:	bdd9                	j	4c <find+0x4c>
            fprintf(1, "%s\n", path);
 178:	00001617          	auipc	a2,0x1
 17c:	98860613          	addi	a2,a2,-1656 # b00 <path>
 180:	00001597          	auipc	a1,0x1
 184:	8d858593          	addi	a1,a1,-1832 # a58 <malloc+0x160>
 188:	4505                	li	a0,1
 18a:	00000097          	auipc	ra,0x0
 18e:	688080e7          	jalr	1672(ra) # 812 <fprintf>
 192:	bf6d                	j	14c <find+0x14c>
    close(fd);
 194:	8526                	mv	a0,s1
 196:	00000097          	auipc	ra,0x0
 19a:	342080e7          	jalr	834(ra) # 4d8 <close>
 19e:	74a6                	ld	s1,104(sp)
 1a0:	7906                	ld	s2,96(sp)
 1a2:	6a46                	ld	s4,80(sp)
 1a4:	6aa6                	ld	s5,72(sp)
    return;
 1a6:	b55d                	j	4c <find+0x4c>

00000000000001a8 <main>:


int main(int argc, char *argv[])
{
 1a8:	1101                	addi	sp,sp,-32
 1aa:	ec06                	sd	ra,24(sp)
 1ac:	e822                	sd	s0,16(sp)
 1ae:	1000                	addi	s0,sp,32
    if (argc < 3) {
 1b0:	4789                	li	a5,2
 1b2:	02a7c163          	blt	a5,a0,1d4 <main+0x2c>
 1b6:	e426                	sd	s1,8(sp)
        fprintf(2, "Usage: find DIR FILENAME\n");
 1b8:	00001597          	auipc	a1,0x1
 1bc:	8a858593          	addi	a1,a1,-1880 # a60 <malloc+0x168>
 1c0:	4509                	li	a0,2
 1c2:	00000097          	auipc	ra,0x0
 1c6:	650080e7          	jalr	1616(ra) # 812 <fprintf>
        exit(0);
 1ca:	4501                	li	a0,0
 1cc:	00000097          	auipc	ra,0x0
 1d0:	2e4080e7          	jalr	740(ra) # 4b0 <exit>
 1d4:	e426                	sd	s1,8(sp)
 1d6:	84ae                	mv	s1,a1
    } else {
        strcpy(path, argv[1]);
 1d8:	658c                	ld	a1,8(a1)
 1da:	00001517          	auipc	a0,0x1
 1de:	92650513          	addi	a0,a0,-1754 # b00 <path>
 1e2:	00000097          	auipc	ra,0x0
 1e6:	01c080e7          	jalr	28(ra) # 1fe <strcpy>
        find(argv[2]);
 1ea:	6888                	ld	a0,16(s1)
 1ec:	00000097          	auipc	ra,0x0
 1f0:	e14080e7          	jalr	-492(ra) # 0 <find>
    }
    exit(0);
 1f4:	4501                	li	a0,0
 1f6:	00000097          	auipc	ra,0x0
 1fa:	2ba080e7          	jalr	698(ra) # 4b0 <exit>

00000000000001fe <strcpy>:
#include "kernel/include/fcntl.h"
#include "xv6-user/user.h"

char*
strcpy(char *s, const char *t)
{
 1fe:	1141                	addi	sp,sp,-16
 200:	e422                	sd	s0,8(sp)
 202:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 204:	87aa                	mv	a5,a0
 206:	0585                	addi	a1,a1,1
 208:	0785                	addi	a5,a5,1
 20a:	fff5c703          	lbu	a4,-1(a1)
 20e:	fee78fa3          	sb	a4,-1(a5)
 212:	fb75                	bnez	a4,206 <strcpy+0x8>
    ;
  return os;
}
 214:	6422                	ld	s0,8(sp)
 216:	0141                	addi	sp,sp,16
 218:	8082                	ret

000000000000021a <strcat>:

char*
strcat(char *s, const char *t)
{
 21a:	1141                	addi	sp,sp,-16
 21c:	e422                	sd	s0,8(sp)
 21e:	0800                	addi	s0,sp,16
  char *os = s;
  while(*s)
 220:	00054783          	lbu	a5,0(a0)
 224:	c385                	beqz	a5,244 <strcat+0x2a>
 226:	87aa                	mv	a5,a0
    s++;
 228:	0785                	addi	a5,a5,1
  while(*s)
 22a:	0007c703          	lbu	a4,0(a5)
 22e:	ff6d                	bnez	a4,228 <strcat+0xe>
  while((*s++ = *t++))
 230:	0585                	addi	a1,a1,1
 232:	0785                	addi	a5,a5,1
 234:	fff5c703          	lbu	a4,-1(a1)
 238:	fee78fa3          	sb	a4,-1(a5)
 23c:	fb75                	bnez	a4,230 <strcat+0x16>
    ;
  return os;
}
 23e:	6422                	ld	s0,8(sp)
 240:	0141                	addi	sp,sp,16
 242:	8082                	ret
  while(*s)
 244:	87aa                	mv	a5,a0
 246:	b7ed                	j	230 <strcat+0x16>

0000000000000248 <strcmp>:


int
strcmp(const char *p, const char *q)
{
 248:	1141                	addi	sp,sp,-16
 24a:	e422                	sd	s0,8(sp)
 24c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 24e:	00054783          	lbu	a5,0(a0)
 252:	cb91                	beqz	a5,266 <strcmp+0x1e>
 254:	0005c703          	lbu	a4,0(a1)
 258:	00f71763          	bne	a4,a5,266 <strcmp+0x1e>
    p++, q++;
 25c:	0505                	addi	a0,a0,1
 25e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 260:	00054783          	lbu	a5,0(a0)
 264:	fbe5                	bnez	a5,254 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 266:	0005c503          	lbu	a0,0(a1)
}
 26a:	40a7853b          	subw	a0,a5,a0
 26e:	6422                	ld	s0,8(sp)
 270:	0141                	addi	sp,sp,16
 272:	8082                	ret

0000000000000274 <strlen>:

uint
strlen(const char *s)
{
 274:	1141                	addi	sp,sp,-16
 276:	e422                	sd	s0,8(sp)
 278:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 27a:	00054783          	lbu	a5,0(a0)
 27e:	cf91                	beqz	a5,29a <strlen+0x26>
 280:	0505                	addi	a0,a0,1
 282:	87aa                	mv	a5,a0
 284:	86be                	mv	a3,a5
 286:	0785                	addi	a5,a5,1
 288:	fff7c703          	lbu	a4,-1(a5)
 28c:	ff65                	bnez	a4,284 <strlen+0x10>
 28e:	40a6853b          	subw	a0,a3,a0
 292:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 294:	6422                	ld	s0,8(sp)
 296:	0141                	addi	sp,sp,16
 298:	8082                	ret
  for(n = 0; s[n]; n++)
 29a:	4501                	li	a0,0
 29c:	bfe5                	j	294 <strlen+0x20>

000000000000029e <memset>:

void*
memset(void *dst, int c, uint n)
{
 29e:	1141                	addi	sp,sp,-16
 2a0:	e422                	sd	s0,8(sp)
 2a2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2a4:	ca19                	beqz	a2,2ba <memset+0x1c>
 2a6:	87aa                	mv	a5,a0
 2a8:	1602                	slli	a2,a2,0x20
 2aa:	9201                	srli	a2,a2,0x20
 2ac:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2b0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 2b4:	0785                	addi	a5,a5,1
 2b6:	fee79de3          	bne	a5,a4,2b0 <memset+0x12>
  }
  return dst;
}
 2ba:	6422                	ld	s0,8(sp)
 2bc:	0141                	addi	sp,sp,16
 2be:	8082                	ret

00000000000002c0 <strchr>:

char*
strchr(const char *s, char c)
{
 2c0:	1141                	addi	sp,sp,-16
 2c2:	e422                	sd	s0,8(sp)
 2c4:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2c6:	00054783          	lbu	a5,0(a0)
 2ca:	cb99                	beqz	a5,2e0 <strchr+0x20>
    if(*s == c)
 2cc:	00f58763          	beq	a1,a5,2da <strchr+0x1a>
  for(; *s; s++)
 2d0:	0505                	addi	a0,a0,1
 2d2:	00054783          	lbu	a5,0(a0)
 2d6:	fbfd                	bnez	a5,2cc <strchr+0xc>
      return (char*)s;
  return 0;
 2d8:	4501                	li	a0,0
}
 2da:	6422                	ld	s0,8(sp)
 2dc:	0141                	addi	sp,sp,16
 2de:	8082                	ret
  return 0;
 2e0:	4501                	li	a0,0
 2e2:	bfe5                	j	2da <strchr+0x1a>

00000000000002e4 <gets>:

char*
gets(char *buf, int max)
{
 2e4:	711d                	addi	sp,sp,-96
 2e6:	ec86                	sd	ra,88(sp)
 2e8:	e8a2                	sd	s0,80(sp)
 2ea:	e4a6                	sd	s1,72(sp)
 2ec:	e0ca                	sd	s2,64(sp)
 2ee:	fc4e                	sd	s3,56(sp)
 2f0:	f852                	sd	s4,48(sp)
 2f2:	f456                	sd	s5,40(sp)
 2f4:	f05a                	sd	s6,32(sp)
 2f6:	ec5e                	sd	s7,24(sp)
 2f8:	1080                	addi	s0,sp,96
 2fa:	8baa                	mv	s7,a0
 2fc:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2fe:	892a                	mv	s2,a0
 300:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 302:	4aa9                	li	s5,10
 304:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 306:	89a6                	mv	s3,s1
 308:	2485                	addiw	s1,s1,1
 30a:	0344d863          	bge	s1,s4,33a <gets+0x56>
    cc = read(0, &c, 1);
 30e:	4605                	li	a2,1
 310:	faf40593          	addi	a1,s0,-81
 314:	4501                	li	a0,0
 316:	00000097          	auipc	ra,0x0
 31a:	1b2080e7          	jalr	434(ra) # 4c8 <read>
    if(cc < 1)
 31e:	00a05e63          	blez	a0,33a <gets+0x56>
    buf[i++] = c;
 322:	faf44783          	lbu	a5,-81(s0)
 326:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 32a:	01578763          	beq	a5,s5,338 <gets+0x54>
 32e:	0905                	addi	s2,s2,1
 330:	fd679be3          	bne	a5,s6,306 <gets+0x22>
    buf[i++] = c;
 334:	89a6                	mv	s3,s1
 336:	a011                	j	33a <gets+0x56>
 338:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 33a:	99de                	add	s3,s3,s7
 33c:	00098023          	sb	zero,0(s3)
  return buf;
}
 340:	855e                	mv	a0,s7
 342:	60e6                	ld	ra,88(sp)
 344:	6446                	ld	s0,80(sp)
 346:	64a6                	ld	s1,72(sp)
 348:	6906                	ld	s2,64(sp)
 34a:	79e2                	ld	s3,56(sp)
 34c:	7a42                	ld	s4,48(sp)
 34e:	7aa2                	ld	s5,40(sp)
 350:	7b02                	ld	s6,32(sp)
 352:	6be2                	ld	s7,24(sp)
 354:	6125                	addi	sp,sp,96
 356:	8082                	ret

0000000000000358 <stat>:

int
stat(const char *n, struct stat *st)
{
 358:	1101                	addi	sp,sp,-32
 35a:	ec06                	sd	ra,24(sp)
 35c:	e822                	sd	s0,16(sp)
 35e:	e04a                	sd	s2,0(sp)
 360:	1000                	addi	s0,sp,32
 362:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 364:	4581                	li	a1,0
 366:	00000097          	auipc	ra,0x0
 36a:	18a080e7          	jalr	394(ra) # 4f0 <open>
  if(fd < 0)
 36e:	02054663          	bltz	a0,39a <stat+0x42>
 372:	e426                	sd	s1,8(sp)
 374:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 376:	85ca                	mv	a1,s2
 378:	00000097          	auipc	ra,0x0
 37c:	180080e7          	jalr	384(ra) # 4f8 <fstat>
 380:	892a                	mv	s2,a0
  close(fd);
 382:	8526                	mv	a0,s1
 384:	00000097          	auipc	ra,0x0
 388:	154080e7          	jalr	340(ra) # 4d8 <close>
  return r;
 38c:	64a2                	ld	s1,8(sp)
}
 38e:	854a                	mv	a0,s2
 390:	60e2                	ld	ra,24(sp)
 392:	6442                	ld	s0,16(sp)
 394:	6902                	ld	s2,0(sp)
 396:	6105                	addi	sp,sp,32
 398:	8082                	ret
    return -1;
 39a:	597d                	li	s2,-1
 39c:	bfcd                	j	38e <stat+0x36>

000000000000039e <atoi>:

int
atoi(const char *s)
{
 39e:	1141                	addi	sp,sp,-16
 3a0:	e422                	sd	s0,8(sp)
 3a2:	0800                	addi	s0,sp,16
  int n;
  int neg = 1;
  if (*s == '-') {
 3a4:	00054703          	lbu	a4,0(a0)
 3a8:	02d00793          	li	a5,45
  int neg = 1;
 3ac:	4585                	li	a1,1
  if (*s == '-') {
 3ae:	04f70363          	beq	a4,a5,3f4 <atoi+0x56>
    s++;
    neg = -1;
  }
  n = 0;
  while('0' <= *s && *s <= '9')
 3b2:	00054703          	lbu	a4,0(a0)
 3b6:	fd07079b          	addiw	a5,a4,-48
 3ba:	0ff7f793          	zext.b	a5,a5
 3be:	46a5                	li	a3,9
 3c0:	02f6ed63          	bltu	a3,a5,3fa <atoi+0x5c>
  n = 0;
 3c4:	4681                	li	a3,0
  while('0' <= *s && *s <= '9')
 3c6:	4625                	li	a2,9
    n = n*10 + *s++ - '0';
 3c8:	0505                	addi	a0,a0,1
 3ca:	0026979b          	slliw	a5,a3,0x2
 3ce:	9fb5                	addw	a5,a5,a3
 3d0:	0017979b          	slliw	a5,a5,0x1
 3d4:	9fb9                	addw	a5,a5,a4
 3d6:	fd07869b          	addiw	a3,a5,-48
  while('0' <= *s && *s <= '9')
 3da:	00054703          	lbu	a4,0(a0)
 3de:	fd07079b          	addiw	a5,a4,-48
 3e2:	0ff7f793          	zext.b	a5,a5
 3e6:	fef671e3          	bgeu	a2,a5,3c8 <atoi+0x2a>
  return n * neg;
}
 3ea:	02d5853b          	mulw	a0,a1,a3
 3ee:	6422                	ld	s0,8(sp)
 3f0:	0141                	addi	sp,sp,16
 3f2:	8082                	ret
    s++;
 3f4:	0505                	addi	a0,a0,1
    neg = -1;
 3f6:	55fd                	li	a1,-1
 3f8:	bf6d                	j	3b2 <atoi+0x14>
  n = 0;
 3fa:	4681                	li	a3,0
 3fc:	b7fd                	j	3ea <atoi+0x4c>

00000000000003fe <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3fe:	1141                	addi	sp,sp,-16
 400:	e422                	sd	s0,8(sp)
 402:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 404:	02b57463          	bgeu	a0,a1,42c <memmove+0x2e>
    while(n-- > 0)
 408:	00c05f63          	blez	a2,426 <memmove+0x28>
 40c:	1602                	slli	a2,a2,0x20
 40e:	9201                	srli	a2,a2,0x20
 410:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 414:	872a                	mv	a4,a0
      *dst++ = *src++;
 416:	0585                	addi	a1,a1,1
 418:	0705                	addi	a4,a4,1
 41a:	fff5c683          	lbu	a3,-1(a1)
 41e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 422:	fef71ae3          	bne	a4,a5,416 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 426:	6422                	ld	s0,8(sp)
 428:	0141                	addi	sp,sp,16
 42a:	8082                	ret
    dst += n;
 42c:	00c50733          	add	a4,a0,a2
    src += n;
 430:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 432:	fec05ae3          	blez	a2,426 <memmove+0x28>
 436:	fff6079b          	addiw	a5,a2,-1
 43a:	1782                	slli	a5,a5,0x20
 43c:	9381                	srli	a5,a5,0x20
 43e:	fff7c793          	not	a5,a5
 442:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 444:	15fd                	addi	a1,a1,-1
 446:	177d                	addi	a4,a4,-1
 448:	0005c683          	lbu	a3,0(a1)
 44c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 450:	fee79ae3          	bne	a5,a4,444 <memmove+0x46>
 454:	bfc9                	j	426 <memmove+0x28>

0000000000000456 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 456:	1141                	addi	sp,sp,-16
 458:	e422                	sd	s0,8(sp)
 45a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 45c:	ca05                	beqz	a2,48c <memcmp+0x36>
 45e:	fff6069b          	addiw	a3,a2,-1
 462:	1682                	slli	a3,a3,0x20
 464:	9281                	srli	a3,a3,0x20
 466:	0685                	addi	a3,a3,1
 468:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 46a:	00054783          	lbu	a5,0(a0)
 46e:	0005c703          	lbu	a4,0(a1)
 472:	00e79863          	bne	a5,a4,482 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 476:	0505                	addi	a0,a0,1
    p2++;
 478:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 47a:	fed518e3          	bne	a0,a3,46a <memcmp+0x14>
  }
  return 0;
 47e:	4501                	li	a0,0
 480:	a019                	j	486 <memcmp+0x30>
      return *p1 - *p2;
 482:	40e7853b          	subw	a0,a5,a4
}
 486:	6422                	ld	s0,8(sp)
 488:	0141                	addi	sp,sp,16
 48a:	8082                	ret
  return 0;
 48c:	4501                	li	a0,0
 48e:	bfe5                	j	486 <memcmp+0x30>

0000000000000490 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 490:	1141                	addi	sp,sp,-16
 492:	e406                	sd	ra,8(sp)
 494:	e022                	sd	s0,0(sp)
 496:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 498:	00000097          	auipc	ra,0x0
 49c:	f66080e7          	jalr	-154(ra) # 3fe <memmove>
}
 4a0:	60a2                	ld	ra,8(sp)
 4a2:	6402                	ld	s0,0(sp)
 4a4:	0141                	addi	sp,sp,16
 4a6:	8082                	ret

00000000000004a8 <fork>:
# generated by usys.pl - do not edit
#include "kernel/include/sysnum.h"
.global fork
fork:
 li a7, SYS_fork
 4a8:	4885                	li	a7,1
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <exit>:
.global exit
exit:
 li a7, SYS_exit
 4b0:	4889                	li	a7,2
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <wait>:
.global wait
wait:
 li a7, SYS_wait
 4b8:	488d                	li	a7,3
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4c0:	4891                	li	a7,4
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <read>:
.global read
read:
 li a7, SYS_read
 4c8:	4895                	li	a7,5
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <write>:
.global write
write:
 li a7, SYS_write
 4d0:	48c1                	li	a7,16
 ecall
 4d2:	00000073          	ecall
 ret
 4d6:	8082                	ret

00000000000004d8 <close>:
.global close
close:
 li a7, SYS_close
 4d8:	48d5                	li	a7,21
 ecall
 4da:	00000073          	ecall
 ret
 4de:	8082                	ret

00000000000004e0 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4e0:	4899                	li	a7,6
 ecall
 4e2:	00000073          	ecall
 ret
 4e6:	8082                	ret

00000000000004e8 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4e8:	489d                	li	a7,7
 ecall
 4ea:	00000073          	ecall
 ret
 4ee:	8082                	ret

00000000000004f0 <open>:
.global open
open:
 li a7, SYS_open
 4f0:	48bd                	li	a7,15
 ecall
 4f2:	00000073          	ecall
 ret
 4f6:	8082                	ret

00000000000004f8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4f8:	48a1                	li	a7,8
 ecall
 4fa:	00000073          	ecall
 ret
 4fe:	8082                	ret

0000000000000500 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 500:	48d1                	li	a7,20
 ecall
 502:	00000073          	ecall
 ret
 506:	8082                	ret

0000000000000508 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 508:	48a5                	li	a7,9
 ecall
 50a:	00000073          	ecall
 ret
 50e:	8082                	ret

0000000000000510 <dup>:
.global dup
dup:
 li a7, SYS_dup
 510:	48a9                	li	a7,10
 ecall
 512:	00000073          	ecall
 ret
 516:	8082                	ret

0000000000000518 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 518:	48ad                	li	a7,11
 ecall
 51a:	00000073          	ecall
 ret
 51e:	8082                	ret

0000000000000520 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 520:	48b1                	li	a7,12
 ecall
 522:	00000073          	ecall
 ret
 526:	8082                	ret

0000000000000528 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 528:	48b5                	li	a7,13
 ecall
 52a:	00000073          	ecall
 ret
 52e:	8082                	ret

0000000000000530 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 530:	48b9                	li	a7,14
 ecall
 532:	00000073          	ecall
 ret
 536:	8082                	ret

0000000000000538 <test_proc>:
.global test_proc
test_proc:
 li a7, SYS_test_proc
 538:	48d9                	li	a7,22
 ecall
 53a:	00000073          	ecall
 ret
 53e:	8082                	ret

0000000000000540 <dev>:
.global dev
dev:
 li a7, SYS_dev
 540:	48dd                	li	a7,23
 ecall
 542:	00000073          	ecall
 ret
 546:	8082                	ret

0000000000000548 <readdir>:
.global readdir
readdir:
 li a7, SYS_readdir
 548:	48e1                	li	a7,24
 ecall
 54a:	00000073          	ecall
 ret
 54e:	8082                	ret

0000000000000550 <getcwd>:
.global getcwd
getcwd:
 li a7, SYS_getcwd
 550:	48e5                	li	a7,25
 ecall
 552:	00000073          	ecall
 ret
 556:	8082                	ret

0000000000000558 <remove>:
.global remove
remove:
 li a7, SYS_remove
 558:	48c5                	li	a7,17
 ecall
 55a:	00000073          	ecall
 ret
 55e:	8082                	ret

0000000000000560 <trace>:
.global trace
trace:
 li a7, SYS_trace
 560:	48c9                	li	a7,18
 ecall
 562:	00000073          	ecall
 ret
 566:	8082                	ret

0000000000000568 <sysinfo>:
.global sysinfo
sysinfo:
 li a7, SYS_sysinfo
 568:	48cd                	li	a7,19
 ecall
 56a:	00000073          	ecall
 ret
 56e:	8082                	ret

0000000000000570 <rename>:
.global rename
rename:
 li a7, SYS_rename
 570:	48e9                	li	a7,26
 ecall
 572:	00000073          	ecall
 ret
 576:	8082                	ret

0000000000000578 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 578:	1101                	addi	sp,sp,-32
 57a:	ec06                	sd	ra,24(sp)
 57c:	e822                	sd	s0,16(sp)
 57e:	1000                	addi	s0,sp,32
 580:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 584:	4605                	li	a2,1
 586:	fef40593          	addi	a1,s0,-17
 58a:	00000097          	auipc	ra,0x0
 58e:	f46080e7          	jalr	-186(ra) # 4d0 <write>
}
 592:	60e2                	ld	ra,24(sp)
 594:	6442                	ld	s0,16(sp)
 596:	6105                	addi	sp,sp,32
 598:	8082                	ret

000000000000059a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 59a:	7139                	addi	sp,sp,-64
 59c:	fc06                	sd	ra,56(sp)
 59e:	f822                	sd	s0,48(sp)
 5a0:	f426                	sd	s1,40(sp)
 5a2:	0080                	addi	s0,sp,64
 5a4:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 5a6:	c299                	beqz	a3,5ac <printint+0x12>
 5a8:	0805cb63          	bltz	a1,63e <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 5ac:	2581                	sext.w	a1,a1
  neg = 0;
 5ae:	4881                	li	a7,0
 5b0:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 5b4:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5b6:	2601                	sext.w	a2,a2
 5b8:	00000517          	auipc	a0,0x0
 5bc:	52850513          	addi	a0,a0,1320 # ae0 <digits>
 5c0:	883a                	mv	a6,a4
 5c2:	2705                	addiw	a4,a4,1
 5c4:	02c5f7bb          	remuw	a5,a1,a2
 5c8:	1782                	slli	a5,a5,0x20
 5ca:	9381                	srli	a5,a5,0x20
 5cc:	97aa                	add	a5,a5,a0
 5ce:	0007c783          	lbu	a5,0(a5)
 5d2:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5d6:	0005879b          	sext.w	a5,a1
 5da:	02c5d5bb          	divuw	a1,a1,a2
 5de:	0685                	addi	a3,a3,1
 5e0:	fec7f0e3          	bgeu	a5,a2,5c0 <printint+0x26>
  if(neg)
 5e4:	00088c63          	beqz	a7,5fc <printint+0x62>
    buf[i++] = '-';
 5e8:	fd070793          	addi	a5,a4,-48
 5ec:	00878733          	add	a4,a5,s0
 5f0:	02d00793          	li	a5,45
 5f4:	fef70823          	sb	a5,-16(a4)
 5f8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5fc:	02e05c63          	blez	a4,634 <printint+0x9a>
 600:	f04a                	sd	s2,32(sp)
 602:	ec4e                	sd	s3,24(sp)
 604:	fc040793          	addi	a5,s0,-64
 608:	00e78933          	add	s2,a5,a4
 60c:	fff78993          	addi	s3,a5,-1
 610:	99ba                	add	s3,s3,a4
 612:	377d                	addiw	a4,a4,-1
 614:	1702                	slli	a4,a4,0x20
 616:	9301                	srli	a4,a4,0x20
 618:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 61c:	fff94583          	lbu	a1,-1(s2)
 620:	8526                	mv	a0,s1
 622:	00000097          	auipc	ra,0x0
 626:	f56080e7          	jalr	-170(ra) # 578 <putc>
  while(--i >= 0)
 62a:	197d                	addi	s2,s2,-1
 62c:	ff3918e3          	bne	s2,s3,61c <printint+0x82>
 630:	7902                	ld	s2,32(sp)
 632:	69e2                	ld	s3,24(sp)
}
 634:	70e2                	ld	ra,56(sp)
 636:	7442                	ld	s0,48(sp)
 638:	74a2                	ld	s1,40(sp)
 63a:	6121                	addi	sp,sp,64
 63c:	8082                	ret
    x = -xx;
 63e:	40b005bb          	negw	a1,a1
    neg = 1;
 642:	4885                	li	a7,1
    x = -xx;
 644:	b7b5                	j	5b0 <printint+0x16>

0000000000000646 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 646:	715d                	addi	sp,sp,-80
 648:	e486                	sd	ra,72(sp)
 64a:	e0a2                	sd	s0,64(sp)
 64c:	f84a                	sd	s2,48(sp)
 64e:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 650:	0005c903          	lbu	s2,0(a1)
 654:	1a090a63          	beqz	s2,808 <vprintf+0x1c2>
 658:	fc26                	sd	s1,56(sp)
 65a:	f44e                	sd	s3,40(sp)
 65c:	f052                	sd	s4,32(sp)
 65e:	ec56                	sd	s5,24(sp)
 660:	e85a                	sd	s6,16(sp)
 662:	e45e                	sd	s7,8(sp)
 664:	8aaa                	mv	s5,a0
 666:	8bb2                	mv	s7,a2
 668:	00158493          	addi	s1,a1,1
  state = 0;
 66c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 66e:	02500a13          	li	s4,37
 672:	4b55                	li	s6,21
 674:	a839                	j	692 <vprintf+0x4c>
        putc(fd, c);
 676:	85ca                	mv	a1,s2
 678:	8556                	mv	a0,s5
 67a:	00000097          	auipc	ra,0x0
 67e:	efe080e7          	jalr	-258(ra) # 578 <putc>
 682:	a019                	j	688 <vprintf+0x42>
    } else if(state == '%'){
 684:	01498d63          	beq	s3,s4,69e <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 688:	0485                	addi	s1,s1,1
 68a:	fff4c903          	lbu	s2,-1(s1)
 68e:	16090763          	beqz	s2,7fc <vprintf+0x1b6>
    if(state == 0){
 692:	fe0999e3          	bnez	s3,684 <vprintf+0x3e>
      if(c == '%'){
 696:	ff4910e3          	bne	s2,s4,676 <vprintf+0x30>
        state = '%';
 69a:	89d2                	mv	s3,s4
 69c:	b7f5                	j	688 <vprintf+0x42>
      if(c == 'd'){
 69e:	13490463          	beq	s2,s4,7c6 <vprintf+0x180>
 6a2:	f9d9079b          	addiw	a5,s2,-99
 6a6:	0ff7f793          	zext.b	a5,a5
 6aa:	12fb6763          	bltu	s6,a5,7d8 <vprintf+0x192>
 6ae:	f9d9079b          	addiw	a5,s2,-99
 6b2:	0ff7f713          	zext.b	a4,a5
 6b6:	12eb6163          	bltu	s6,a4,7d8 <vprintf+0x192>
 6ba:	00271793          	slli	a5,a4,0x2
 6be:	00000717          	auipc	a4,0x0
 6c2:	3ca70713          	addi	a4,a4,970 # a88 <malloc+0x190>
 6c6:	97ba                	add	a5,a5,a4
 6c8:	439c                	lw	a5,0(a5)
 6ca:	97ba                	add	a5,a5,a4
 6cc:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 6ce:	008b8913          	addi	s2,s7,8
 6d2:	4685                	li	a3,1
 6d4:	4629                	li	a2,10
 6d6:	000ba583          	lw	a1,0(s7)
 6da:	8556                	mv	a0,s5
 6dc:	00000097          	auipc	ra,0x0
 6e0:	ebe080e7          	jalr	-322(ra) # 59a <printint>
 6e4:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 6e6:	4981                	li	s3,0
 6e8:	b745                	j	688 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ea:	008b8913          	addi	s2,s7,8
 6ee:	4681                	li	a3,0
 6f0:	4629                	li	a2,10
 6f2:	000ba583          	lw	a1,0(s7)
 6f6:	8556                	mv	a0,s5
 6f8:	00000097          	auipc	ra,0x0
 6fc:	ea2080e7          	jalr	-350(ra) # 59a <printint>
 700:	8bca                	mv	s7,s2
      state = 0;
 702:	4981                	li	s3,0
 704:	b751                	j	688 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 706:	008b8913          	addi	s2,s7,8
 70a:	4681                	li	a3,0
 70c:	4641                	li	a2,16
 70e:	000ba583          	lw	a1,0(s7)
 712:	8556                	mv	a0,s5
 714:	00000097          	auipc	ra,0x0
 718:	e86080e7          	jalr	-378(ra) # 59a <printint>
 71c:	8bca                	mv	s7,s2
      state = 0;
 71e:	4981                	li	s3,0
 720:	b7a5                	j	688 <vprintf+0x42>
 722:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 724:	008b8c13          	addi	s8,s7,8
 728:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 72c:	03000593          	li	a1,48
 730:	8556                	mv	a0,s5
 732:	00000097          	auipc	ra,0x0
 736:	e46080e7          	jalr	-442(ra) # 578 <putc>
  putc(fd, 'x');
 73a:	07800593          	li	a1,120
 73e:	8556                	mv	a0,s5
 740:	00000097          	auipc	ra,0x0
 744:	e38080e7          	jalr	-456(ra) # 578 <putc>
 748:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 74a:	00000b97          	auipc	s7,0x0
 74e:	396b8b93          	addi	s7,s7,918 # ae0 <digits>
 752:	03c9d793          	srli	a5,s3,0x3c
 756:	97de                	add	a5,a5,s7
 758:	0007c583          	lbu	a1,0(a5)
 75c:	8556                	mv	a0,s5
 75e:	00000097          	auipc	ra,0x0
 762:	e1a080e7          	jalr	-486(ra) # 578 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 766:	0992                	slli	s3,s3,0x4
 768:	397d                	addiw	s2,s2,-1
 76a:	fe0914e3          	bnez	s2,752 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 76e:	8be2                	mv	s7,s8
      state = 0;
 770:	4981                	li	s3,0
 772:	6c02                	ld	s8,0(sp)
 774:	bf11                	j	688 <vprintf+0x42>
        s = va_arg(ap, char*);
 776:	008b8993          	addi	s3,s7,8
 77a:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 77e:	02090163          	beqz	s2,7a0 <vprintf+0x15a>
        while(*s != 0){
 782:	00094583          	lbu	a1,0(s2)
 786:	c9a5                	beqz	a1,7f6 <vprintf+0x1b0>
          putc(fd, *s);
 788:	8556                	mv	a0,s5
 78a:	00000097          	auipc	ra,0x0
 78e:	dee080e7          	jalr	-530(ra) # 578 <putc>
          s++;
 792:	0905                	addi	s2,s2,1
        while(*s != 0){
 794:	00094583          	lbu	a1,0(s2)
 798:	f9e5                	bnez	a1,788 <vprintf+0x142>
        s = va_arg(ap, char*);
 79a:	8bce                	mv	s7,s3
      state = 0;
 79c:	4981                	li	s3,0
 79e:	b5ed                	j	688 <vprintf+0x42>
          s = "(null)";
 7a0:	00000917          	auipc	s2,0x0
 7a4:	2e090913          	addi	s2,s2,736 # a80 <malloc+0x188>
        while(*s != 0){
 7a8:	02800593          	li	a1,40
 7ac:	bff1                	j	788 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 7ae:	008b8913          	addi	s2,s7,8
 7b2:	000bc583          	lbu	a1,0(s7)
 7b6:	8556                	mv	a0,s5
 7b8:	00000097          	auipc	ra,0x0
 7bc:	dc0080e7          	jalr	-576(ra) # 578 <putc>
 7c0:	8bca                	mv	s7,s2
      state = 0;
 7c2:	4981                	li	s3,0
 7c4:	b5d1                	j	688 <vprintf+0x42>
        putc(fd, c);
 7c6:	02500593          	li	a1,37
 7ca:	8556                	mv	a0,s5
 7cc:	00000097          	auipc	ra,0x0
 7d0:	dac080e7          	jalr	-596(ra) # 578 <putc>
      state = 0;
 7d4:	4981                	li	s3,0
 7d6:	bd4d                	j	688 <vprintf+0x42>
        putc(fd, '%');
 7d8:	02500593          	li	a1,37
 7dc:	8556                	mv	a0,s5
 7de:	00000097          	auipc	ra,0x0
 7e2:	d9a080e7          	jalr	-614(ra) # 578 <putc>
        putc(fd, c);
 7e6:	85ca                	mv	a1,s2
 7e8:	8556                	mv	a0,s5
 7ea:	00000097          	auipc	ra,0x0
 7ee:	d8e080e7          	jalr	-626(ra) # 578 <putc>
      state = 0;
 7f2:	4981                	li	s3,0
 7f4:	bd51                	j	688 <vprintf+0x42>
        s = va_arg(ap, char*);
 7f6:	8bce                	mv	s7,s3
      state = 0;
 7f8:	4981                	li	s3,0
 7fa:	b579                	j	688 <vprintf+0x42>
 7fc:	74e2                	ld	s1,56(sp)
 7fe:	79a2                	ld	s3,40(sp)
 800:	7a02                	ld	s4,32(sp)
 802:	6ae2                	ld	s5,24(sp)
 804:	6b42                	ld	s6,16(sp)
 806:	6ba2                	ld	s7,8(sp)
    }
  }
}
 808:	60a6                	ld	ra,72(sp)
 80a:	6406                	ld	s0,64(sp)
 80c:	7942                	ld	s2,48(sp)
 80e:	6161                	addi	sp,sp,80
 810:	8082                	ret

0000000000000812 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 812:	715d                	addi	sp,sp,-80
 814:	ec06                	sd	ra,24(sp)
 816:	e822                	sd	s0,16(sp)
 818:	1000                	addi	s0,sp,32
 81a:	e010                	sd	a2,0(s0)
 81c:	e414                	sd	a3,8(s0)
 81e:	e818                	sd	a4,16(s0)
 820:	ec1c                	sd	a5,24(s0)
 822:	03043023          	sd	a6,32(s0)
 826:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 82a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 82e:	8622                	mv	a2,s0
 830:	00000097          	auipc	ra,0x0
 834:	e16080e7          	jalr	-490(ra) # 646 <vprintf>
}
 838:	60e2                	ld	ra,24(sp)
 83a:	6442                	ld	s0,16(sp)
 83c:	6161                	addi	sp,sp,80
 83e:	8082                	ret

0000000000000840 <printf>:

void
printf(const char *fmt, ...)
{
 840:	711d                	addi	sp,sp,-96
 842:	ec06                	sd	ra,24(sp)
 844:	e822                	sd	s0,16(sp)
 846:	1000                	addi	s0,sp,32
 848:	e40c                	sd	a1,8(s0)
 84a:	e810                	sd	a2,16(s0)
 84c:	ec14                	sd	a3,24(s0)
 84e:	f018                	sd	a4,32(s0)
 850:	f41c                	sd	a5,40(s0)
 852:	03043823          	sd	a6,48(s0)
 856:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 85a:	00840613          	addi	a2,s0,8
 85e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 862:	85aa                	mv	a1,a0
 864:	4505                	li	a0,1
 866:	00000097          	auipc	ra,0x0
 86a:	de0080e7          	jalr	-544(ra) # 646 <vprintf>
}
 86e:	60e2                	ld	ra,24(sp)
 870:	6442                	ld	s0,16(sp)
 872:	6125                	addi	sp,sp,96
 874:	8082                	ret

0000000000000876 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 876:	1141                	addi	sp,sp,-16
 878:	e422                	sd	s0,8(sp)
 87a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 87c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 880:	00000797          	auipc	a5,0x0
 884:	2787b783          	ld	a5,632(a5) # af8 <freep>
 888:	a02d                	j	8b2 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 88a:	4618                	lw	a4,8(a2)
 88c:	9f2d                	addw	a4,a4,a1
 88e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 892:	6398                	ld	a4,0(a5)
 894:	6310                	ld	a2,0(a4)
 896:	a83d                	j	8d4 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 898:	ff852703          	lw	a4,-8(a0)
 89c:	9f31                	addw	a4,a4,a2
 89e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8a0:	ff053683          	ld	a3,-16(a0)
 8a4:	a091                	j	8e8 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8a6:	6398                	ld	a4,0(a5)
 8a8:	00e7e463          	bltu	a5,a4,8b0 <free+0x3a>
 8ac:	00e6ea63          	bltu	a3,a4,8c0 <free+0x4a>
{
 8b0:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8b2:	fed7fae3          	bgeu	a5,a3,8a6 <free+0x30>
 8b6:	6398                	ld	a4,0(a5)
 8b8:	00e6e463          	bltu	a3,a4,8c0 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8bc:	fee7eae3          	bltu	a5,a4,8b0 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 8c0:	ff852583          	lw	a1,-8(a0)
 8c4:	6390                	ld	a2,0(a5)
 8c6:	02059813          	slli	a6,a1,0x20
 8ca:	01c85713          	srli	a4,a6,0x1c
 8ce:	9736                	add	a4,a4,a3
 8d0:	fae60de3          	beq	a2,a4,88a <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8d4:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8d8:	4790                	lw	a2,8(a5)
 8da:	02061593          	slli	a1,a2,0x20
 8de:	01c5d713          	srli	a4,a1,0x1c
 8e2:	973e                	add	a4,a4,a5
 8e4:	fae68ae3          	beq	a3,a4,898 <free+0x22>
    p->s.ptr = bp->s.ptr;
 8e8:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8ea:	00000717          	auipc	a4,0x0
 8ee:	20f73723          	sd	a5,526(a4) # af8 <freep>
}
 8f2:	6422                	ld	s0,8(sp)
 8f4:	0141                	addi	sp,sp,16
 8f6:	8082                	ret

00000000000008f8 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8f8:	7139                	addi	sp,sp,-64
 8fa:	fc06                	sd	ra,56(sp)
 8fc:	f822                	sd	s0,48(sp)
 8fe:	f426                	sd	s1,40(sp)
 900:	ec4e                	sd	s3,24(sp)
 902:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 904:	02051493          	slli	s1,a0,0x20
 908:	9081                	srli	s1,s1,0x20
 90a:	04bd                	addi	s1,s1,15
 90c:	8091                	srli	s1,s1,0x4
 90e:	0014899b          	addiw	s3,s1,1
 912:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 914:	00000517          	auipc	a0,0x0
 918:	1e453503          	ld	a0,484(a0) # af8 <freep>
 91c:	c915                	beqz	a0,950 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 91e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 920:	4798                	lw	a4,8(a5)
 922:	08977e63          	bgeu	a4,s1,9be <malloc+0xc6>
 926:	f04a                	sd	s2,32(sp)
 928:	e852                	sd	s4,16(sp)
 92a:	e456                	sd	s5,8(sp)
 92c:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 92e:	8a4e                	mv	s4,s3
 930:	0009871b          	sext.w	a4,s3
 934:	6685                	lui	a3,0x1
 936:	00d77363          	bgeu	a4,a3,93c <malloc+0x44>
 93a:	6a05                	lui	s4,0x1
 93c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 940:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 944:	00000917          	auipc	s2,0x0
 948:	1b490913          	addi	s2,s2,436 # af8 <freep>
  if(p == (char*)-1)
 94c:	5afd                	li	s5,-1
 94e:	a091                	j	992 <malloc+0x9a>
 950:	f04a                	sd	s2,32(sp)
 952:	e852                	sd	s4,16(sp)
 954:	e456                	sd	s5,8(sp)
 956:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 958:	00000797          	auipc	a5,0x0
 95c:	3a878793          	addi	a5,a5,936 # d00 <base>
 960:	00000717          	auipc	a4,0x0
 964:	18f73c23          	sd	a5,408(a4) # af8 <freep>
 968:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 96a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 96e:	b7c1                	j	92e <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 970:	6398                	ld	a4,0(a5)
 972:	e118                	sd	a4,0(a0)
 974:	a08d                	j	9d6 <malloc+0xde>
  hp->s.size = nu;
 976:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 97a:	0541                	addi	a0,a0,16
 97c:	00000097          	auipc	ra,0x0
 980:	efa080e7          	jalr	-262(ra) # 876 <free>
  return freep;
 984:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 988:	c13d                	beqz	a0,9ee <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 98a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 98c:	4798                	lw	a4,8(a5)
 98e:	02977463          	bgeu	a4,s1,9b6 <malloc+0xbe>
    if(p == freep)
 992:	00093703          	ld	a4,0(s2)
 996:	853e                	mv	a0,a5
 998:	fef719e3          	bne	a4,a5,98a <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 99c:	8552                	mv	a0,s4
 99e:	00000097          	auipc	ra,0x0
 9a2:	b82080e7          	jalr	-1150(ra) # 520 <sbrk>
  if(p == (char*)-1)
 9a6:	fd5518e3          	bne	a0,s5,976 <malloc+0x7e>
        return 0;
 9aa:	4501                	li	a0,0
 9ac:	7902                	ld	s2,32(sp)
 9ae:	6a42                	ld	s4,16(sp)
 9b0:	6aa2                	ld	s5,8(sp)
 9b2:	6b02                	ld	s6,0(sp)
 9b4:	a03d                	j	9e2 <malloc+0xea>
 9b6:	7902                	ld	s2,32(sp)
 9b8:	6a42                	ld	s4,16(sp)
 9ba:	6aa2                	ld	s5,8(sp)
 9bc:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 9be:	fae489e3          	beq	s1,a4,970 <malloc+0x78>
        p->s.size -= nunits;
 9c2:	4137073b          	subw	a4,a4,s3
 9c6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9c8:	02071693          	slli	a3,a4,0x20
 9cc:	01c6d713          	srli	a4,a3,0x1c
 9d0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9d2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9d6:	00000717          	auipc	a4,0x0
 9da:	12a73123          	sd	a0,290(a4) # af8 <freep>
      return (void*)(p + 1);
 9de:	01078513          	addi	a0,a5,16
  }
}
 9e2:	70e2                	ld	ra,56(sp)
 9e4:	7442                	ld	s0,48(sp)
 9e6:	74a2                	ld	s1,40(sp)
 9e8:	69e2                	ld	s3,24(sp)
 9ea:	6121                	addi	sp,sp,64
 9ec:	8082                	ret
 9ee:	7902                	ld	s2,32(sp)
 9f0:	6a42                	ld	s4,16(sp)
 9f2:	6aa2                	ld	s5,8(sp)
 9f4:	6b02                	ld	s6,0(sp)
 9f6:	b7f5                	j	9e2 <malloc+0xea>
