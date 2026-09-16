
xv6-user/_mv:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/include/fcntl.h"
#include "kernel/include/param.h"
#include "xv6-user/user.h"

int main(int argc, char *argv[])
{
   0:	d9010113          	addi	sp,sp,-624
   4:	26113423          	sd	ra,616(sp)
   8:	26813023          	sd	s0,608(sp)
   c:	1c80                	addi	s0,sp,624
    if (argc < 3) {
   e:	4789                	li	a5,2
  10:	02a7c263          	blt	a5,a0,34 <main+0x34>
  14:	24913c23          	sd	s1,600(sp)
        fprintf(2, "Usage: mv old_name new_name\n");
  18:	00001597          	auipc	a1,0x1
  1c:	99858593          	addi	a1,a1,-1640 # 9b0 <malloc+0x102>
  20:	4509                	li	a0,2
  22:	00000097          	auipc	ra,0x0
  26:	7a6080e7          	jalr	1958(ra) # 7c8 <fprintf>
        exit(1);
  2a:	4505                	li	a0,1
  2c:	00000097          	auipc	ra,0x0
  30:	43a080e7          	jalr	1082(ra) # 466 <exit>
  34:	24913c23          	sd	s1,600(sp)
  38:	84ae                	mv	s1,a1
    }

    char src[MAXPATH];
    char dst[MAXPATH];
    strcpy(src, argv[1]);
  3a:	658c                	ld	a1,8(a1)
  3c:	ed840513          	addi	a0,s0,-296
  40:	00000097          	auipc	ra,0x0
  44:	174080e7          	jalr	372(ra) # 1b4 <strcpy>
    strcpy(dst, argv[2]);
  48:	688c                	ld	a1,16(s1)
  4a:	dd040513          	addi	a0,s0,-560
  4e:	00000097          	auipc	ra,0x0
  52:	166080e7          	jalr	358(ra) # 1b4 <strcpy>
    int fd = open(dst, O_RDONLY);
  56:	4581                	li	a1,0
  58:	dd040513          	addi	a0,s0,-560
  5c:	00000097          	auipc	ra,0x0
  60:	44a080e7          	jalr	1098(ra) # 4a6 <open>
  64:	84aa                	mv	s1,a0
    if (fd >= 0) {
  66:	0e054a63          	bltz	a0,15a <main+0x15a>
        struct stat st;
        fstat(fd, &st);
  6a:	d9840593          	addi	a1,s0,-616
  6e:	00000097          	auipc	ra,0x0
  72:	440080e7          	jalr	1088(ra) # 4ae <fstat>
        close(fd);
  76:	8526                	mv	a0,s1
  78:	00000097          	auipc	ra,0x0
  7c:	416080e7          	jalr	1046(ra) # 48e <close>
        if (st.type == T_DIR) {
  80:	dc041703          	lh	a4,-576(s0)
  84:	4785                	li	a5,1
  86:	02f70263          	beq	a4,a5,aa <main+0xaa>
                    fprintf(2, "mv: fail! final dst path too long (exceed MAX=%d)!\n", MAXPATH);
                    exit(-1);
                }
            }
        } else {
            fprintf(2, "mv: fail! %s exists!\n", dst);
  8a:	dd040613          	addi	a2,s0,-560
  8e:	00001597          	auipc	a1,0x1
  92:	98258593          	addi	a1,a1,-1662 # a10 <malloc+0x162>
  96:	4509                	li	a0,2
  98:	00000097          	auipc	ra,0x0
  9c:	730080e7          	jalr	1840(ra) # 7c8 <fprintf>
            exit(-1);
  a0:	557d                	li	a0,-1
  a2:	00000097          	auipc	ra,0x0
  a6:	3c4080e7          	jalr	964(ra) # 466 <exit>
            for (ps = src + strlen(src) - 1; ps >= src; ps--) { // trim '/' in tail
  aa:	ed840493          	addi	s1,s0,-296
  ae:	8526                	mv	a0,s1
  b0:	00000097          	auipc	ra,0x0
  b4:	17a080e7          	jalr	378(ra) # 22a <strlen>
  b8:	02051793          	slli	a5,a0,0x20
  bc:	9381                	srli	a5,a5,0x20
  be:	17fd                	addi	a5,a5,-1
  c0:	97a6                	add	a5,a5,s1
  c2:	0297ed63          	bltu	a5,s1,fc <main+0xfc>
                if (*ps != '/') {
  c6:	02f00693          	li	a3,47
            for (ps = src + strlen(src) - 1; ps >= src; ps--) { // trim '/' in tail
  ca:	8626                	mv	a2,s1
                if (*ps != '/') {
  cc:	0007c703          	lbu	a4,0(a5)
  d0:	00d71663          	bne	a4,a3,dc <main+0xdc>
            for (ps = src + strlen(src) - 1; ps >= src; ps--) { // trim '/' in tail
  d4:	17fd                	addi	a5,a5,-1
  d6:	fec7fbe3          	bgeu	a5,a2,cc <main+0xcc>
  da:	a00d                	j	fc <main+0xfc>
                    *(ps + 1) = '\0';
  dc:	000780a3          	sb	zero,1(a5)
            for (; ps >= src && *ps != '/'; ps--);
  e0:	ed840713          	addi	a4,s0,-296
  e4:	02f00693          	li	a3,47
  e8:	863a                	mv	a2,a4
  ea:	00e7e963          	bltu	a5,a4,fc <main+0xfc>
  ee:	0007c703          	lbu	a4,0(a5)
  f2:	00d70563          	beq	a4,a3,fc <main+0xfc>
  f6:	17fd                	addi	a5,a5,-1
  f8:	fec7fbe3          	bgeu	a5,a2,ee <main+0xee>
            ps++;
  fc:	00178493          	addi	s1,a5,1
            pd = dst + strlen(dst);
 100:	dd040513          	addi	a0,s0,-560
 104:	00000097          	auipc	ra,0x0
 108:	126080e7          	jalr	294(ra) # 22a <strlen>
 10c:	1502                	slli	a0,a0,0x20
 10e:	9101                	srli	a0,a0,0x20
 110:	dd040793          	addi	a5,s0,-560
 114:	00a78733          	add	a4,a5,a0
            *pd++ = '/';
 118:	00170793          	addi	a5,a4,1
 11c:	02f00693          	li	a3,47
 120:	00d70023          	sb	a3,0(a4)
                if (pd >= dst + MAXPATH) {
 124:	ed440693          	addi	a3,s0,-300
            while (*ps) {
 128:	0004c703          	lbu	a4,0(s1)
 12c:	c71d                	beqz	a4,15a <main+0x15a>
                *pd++ = *ps++;
 12e:	0485                	addi	s1,s1,1
 130:	0785                	addi	a5,a5,1
 132:	fee78fa3          	sb	a4,-1(a5)
                if (pd >= dst + MAXPATH) {
 136:	fed7e9e3          	bltu	a5,a3,128 <main+0x128>
                    fprintf(2, "mv: fail! final dst path too long (exceed MAX=%d)!\n", MAXPATH);
 13a:	10400613          	li	a2,260
 13e:	00001597          	auipc	a1,0x1
 142:	89a58593          	addi	a1,a1,-1894 # 9d8 <malloc+0x12a>
 146:	4509                	li	a0,2
 148:	00000097          	auipc	ra,0x0
 14c:	680080e7          	jalr	1664(ra) # 7c8 <fprintf>
                    exit(-1);
 150:	557d                	li	a0,-1
 152:	00000097          	auipc	ra,0x0
 156:	314080e7          	jalr	788(ra) # 466 <exit>
        }
    }
    printf("moving [%s] to [%s]\n", src, dst);
 15a:	dd040613          	addi	a2,s0,-560
 15e:	ed840593          	addi	a1,s0,-296
 162:	00001517          	auipc	a0,0x1
 166:	8c650513          	addi	a0,a0,-1850 # a28 <malloc+0x17a>
 16a:	00000097          	auipc	ra,0x0
 16e:	68c080e7          	jalr	1676(ra) # 7f6 <printf>
    if (rename(src, dst) < 0) {
 172:	dd040593          	addi	a1,s0,-560
 176:	ed840513          	addi	a0,s0,-296
 17a:	00000097          	auipc	ra,0x0
 17e:	3ac080e7          	jalr	940(ra) # 526 <rename>
 182:	00054763          	bltz	a0,190 <main+0x190>
        fprintf(2, "mv: fail to rename %s to %s!\n", src, dst);
        exit(-1);
    }
    exit(0);
 186:	4501                	li	a0,0
 188:	00000097          	auipc	ra,0x0
 18c:	2de080e7          	jalr	734(ra) # 466 <exit>
        fprintf(2, "mv: fail to rename %s to %s!\n", src, dst);
 190:	dd040693          	addi	a3,s0,-560
 194:	ed840613          	addi	a2,s0,-296
 198:	00001597          	auipc	a1,0x1
 19c:	8a858593          	addi	a1,a1,-1880 # a40 <malloc+0x192>
 1a0:	4509                	li	a0,2
 1a2:	00000097          	auipc	ra,0x0
 1a6:	626080e7          	jalr	1574(ra) # 7c8 <fprintf>
        exit(-1);
 1aa:	557d                	li	a0,-1
 1ac:	00000097          	auipc	ra,0x0
 1b0:	2ba080e7          	jalr	698(ra) # 466 <exit>

00000000000001b4 <strcpy>:
#include "kernel/include/fcntl.h"
#include "xv6-user/user.h"

char*
strcpy(char *s, const char *t)
{
 1b4:	1141                	addi	sp,sp,-16
 1b6:	e422                	sd	s0,8(sp)
 1b8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1ba:	87aa                	mv	a5,a0
 1bc:	0585                	addi	a1,a1,1
 1be:	0785                	addi	a5,a5,1
 1c0:	fff5c703          	lbu	a4,-1(a1)
 1c4:	fee78fa3          	sb	a4,-1(a5)
 1c8:	fb75                	bnez	a4,1bc <strcpy+0x8>
    ;
  return os;
}
 1ca:	6422                	ld	s0,8(sp)
 1cc:	0141                	addi	sp,sp,16
 1ce:	8082                	ret

00000000000001d0 <strcat>:

char*
strcat(char *s, const char *t)
{
 1d0:	1141                	addi	sp,sp,-16
 1d2:	e422                	sd	s0,8(sp)
 1d4:	0800                	addi	s0,sp,16
  char *os = s;
  while(*s)
 1d6:	00054783          	lbu	a5,0(a0)
 1da:	c385                	beqz	a5,1fa <strcat+0x2a>
 1dc:	87aa                	mv	a5,a0
    s++;
 1de:	0785                	addi	a5,a5,1
  while(*s)
 1e0:	0007c703          	lbu	a4,0(a5)
 1e4:	ff6d                	bnez	a4,1de <strcat+0xe>
  while((*s++ = *t++))
 1e6:	0585                	addi	a1,a1,1
 1e8:	0785                	addi	a5,a5,1
 1ea:	fff5c703          	lbu	a4,-1(a1)
 1ee:	fee78fa3          	sb	a4,-1(a5)
 1f2:	fb75                	bnez	a4,1e6 <strcat+0x16>
    ;
  return os;
}
 1f4:	6422                	ld	s0,8(sp)
 1f6:	0141                	addi	sp,sp,16
 1f8:	8082                	ret
  while(*s)
 1fa:	87aa                	mv	a5,a0
 1fc:	b7ed                	j	1e6 <strcat+0x16>

00000000000001fe <strcmp>:


int
strcmp(const char *p, const char *q)
{
 1fe:	1141                	addi	sp,sp,-16
 200:	e422                	sd	s0,8(sp)
 202:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 204:	00054783          	lbu	a5,0(a0)
 208:	cb91                	beqz	a5,21c <strcmp+0x1e>
 20a:	0005c703          	lbu	a4,0(a1)
 20e:	00f71763          	bne	a4,a5,21c <strcmp+0x1e>
    p++, q++;
 212:	0505                	addi	a0,a0,1
 214:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 216:	00054783          	lbu	a5,0(a0)
 21a:	fbe5                	bnez	a5,20a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 21c:	0005c503          	lbu	a0,0(a1)
}
 220:	40a7853b          	subw	a0,a5,a0
 224:	6422                	ld	s0,8(sp)
 226:	0141                	addi	sp,sp,16
 228:	8082                	ret

000000000000022a <strlen>:

uint
strlen(const char *s)
{
 22a:	1141                	addi	sp,sp,-16
 22c:	e422                	sd	s0,8(sp)
 22e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 230:	00054783          	lbu	a5,0(a0)
 234:	cf91                	beqz	a5,250 <strlen+0x26>
 236:	0505                	addi	a0,a0,1
 238:	87aa                	mv	a5,a0
 23a:	86be                	mv	a3,a5
 23c:	0785                	addi	a5,a5,1
 23e:	fff7c703          	lbu	a4,-1(a5)
 242:	ff65                	bnez	a4,23a <strlen+0x10>
 244:	40a6853b          	subw	a0,a3,a0
 248:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 24a:	6422                	ld	s0,8(sp)
 24c:	0141                	addi	sp,sp,16
 24e:	8082                	ret
  for(n = 0; s[n]; n++)
 250:	4501                	li	a0,0
 252:	bfe5                	j	24a <strlen+0x20>

0000000000000254 <memset>:

void*
memset(void *dst, int c, uint n)
{
 254:	1141                	addi	sp,sp,-16
 256:	e422                	sd	s0,8(sp)
 258:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 25a:	ca19                	beqz	a2,270 <memset+0x1c>
 25c:	87aa                	mv	a5,a0
 25e:	1602                	slli	a2,a2,0x20
 260:	9201                	srli	a2,a2,0x20
 262:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 266:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 26a:	0785                	addi	a5,a5,1
 26c:	fee79de3          	bne	a5,a4,266 <memset+0x12>
  }
  return dst;
}
 270:	6422                	ld	s0,8(sp)
 272:	0141                	addi	sp,sp,16
 274:	8082                	ret

0000000000000276 <strchr>:

char*
strchr(const char *s, char c)
{
 276:	1141                	addi	sp,sp,-16
 278:	e422                	sd	s0,8(sp)
 27a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 27c:	00054783          	lbu	a5,0(a0)
 280:	cb99                	beqz	a5,296 <strchr+0x20>
    if(*s == c)
 282:	00f58763          	beq	a1,a5,290 <strchr+0x1a>
  for(; *s; s++)
 286:	0505                	addi	a0,a0,1
 288:	00054783          	lbu	a5,0(a0)
 28c:	fbfd                	bnez	a5,282 <strchr+0xc>
      return (char*)s;
  return 0;
 28e:	4501                	li	a0,0
}
 290:	6422                	ld	s0,8(sp)
 292:	0141                	addi	sp,sp,16
 294:	8082                	ret
  return 0;
 296:	4501                	li	a0,0
 298:	bfe5                	j	290 <strchr+0x1a>

000000000000029a <gets>:

char*
gets(char *buf, int max)
{
 29a:	711d                	addi	sp,sp,-96
 29c:	ec86                	sd	ra,88(sp)
 29e:	e8a2                	sd	s0,80(sp)
 2a0:	e4a6                	sd	s1,72(sp)
 2a2:	e0ca                	sd	s2,64(sp)
 2a4:	fc4e                	sd	s3,56(sp)
 2a6:	f852                	sd	s4,48(sp)
 2a8:	f456                	sd	s5,40(sp)
 2aa:	f05a                	sd	s6,32(sp)
 2ac:	ec5e                	sd	s7,24(sp)
 2ae:	1080                	addi	s0,sp,96
 2b0:	8baa                	mv	s7,a0
 2b2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2b4:	892a                	mv	s2,a0
 2b6:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2b8:	4aa9                	li	s5,10
 2ba:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2bc:	89a6                	mv	s3,s1
 2be:	2485                	addiw	s1,s1,1
 2c0:	0344d863          	bge	s1,s4,2f0 <gets+0x56>
    cc = read(0, &c, 1);
 2c4:	4605                	li	a2,1
 2c6:	faf40593          	addi	a1,s0,-81
 2ca:	4501                	li	a0,0
 2cc:	00000097          	auipc	ra,0x0
 2d0:	1b2080e7          	jalr	434(ra) # 47e <read>
    if(cc < 1)
 2d4:	00a05e63          	blez	a0,2f0 <gets+0x56>
    buf[i++] = c;
 2d8:	faf44783          	lbu	a5,-81(s0)
 2dc:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2e0:	01578763          	beq	a5,s5,2ee <gets+0x54>
 2e4:	0905                	addi	s2,s2,1
 2e6:	fd679be3          	bne	a5,s6,2bc <gets+0x22>
    buf[i++] = c;
 2ea:	89a6                	mv	s3,s1
 2ec:	a011                	j	2f0 <gets+0x56>
 2ee:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2f0:	99de                	add	s3,s3,s7
 2f2:	00098023          	sb	zero,0(s3)
  return buf;
}
 2f6:	855e                	mv	a0,s7
 2f8:	60e6                	ld	ra,88(sp)
 2fa:	6446                	ld	s0,80(sp)
 2fc:	64a6                	ld	s1,72(sp)
 2fe:	6906                	ld	s2,64(sp)
 300:	79e2                	ld	s3,56(sp)
 302:	7a42                	ld	s4,48(sp)
 304:	7aa2                	ld	s5,40(sp)
 306:	7b02                	ld	s6,32(sp)
 308:	6be2                	ld	s7,24(sp)
 30a:	6125                	addi	sp,sp,96
 30c:	8082                	ret

000000000000030e <stat>:

int
stat(const char *n, struct stat *st)
{
 30e:	1101                	addi	sp,sp,-32
 310:	ec06                	sd	ra,24(sp)
 312:	e822                	sd	s0,16(sp)
 314:	e04a                	sd	s2,0(sp)
 316:	1000                	addi	s0,sp,32
 318:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 31a:	4581                	li	a1,0
 31c:	00000097          	auipc	ra,0x0
 320:	18a080e7          	jalr	394(ra) # 4a6 <open>
  if(fd < 0)
 324:	02054663          	bltz	a0,350 <stat+0x42>
 328:	e426                	sd	s1,8(sp)
 32a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 32c:	85ca                	mv	a1,s2
 32e:	00000097          	auipc	ra,0x0
 332:	180080e7          	jalr	384(ra) # 4ae <fstat>
 336:	892a                	mv	s2,a0
  close(fd);
 338:	8526                	mv	a0,s1
 33a:	00000097          	auipc	ra,0x0
 33e:	154080e7          	jalr	340(ra) # 48e <close>
  return r;
 342:	64a2                	ld	s1,8(sp)
}
 344:	854a                	mv	a0,s2
 346:	60e2                	ld	ra,24(sp)
 348:	6442                	ld	s0,16(sp)
 34a:	6902                	ld	s2,0(sp)
 34c:	6105                	addi	sp,sp,32
 34e:	8082                	ret
    return -1;
 350:	597d                	li	s2,-1
 352:	bfcd                	j	344 <stat+0x36>

0000000000000354 <atoi>:

int
atoi(const char *s)
{
 354:	1141                	addi	sp,sp,-16
 356:	e422                	sd	s0,8(sp)
 358:	0800                	addi	s0,sp,16
  int n;
  int neg = 1;
  if (*s == '-') {
 35a:	00054703          	lbu	a4,0(a0)
 35e:	02d00793          	li	a5,45
  int neg = 1;
 362:	4585                	li	a1,1
  if (*s == '-') {
 364:	04f70363          	beq	a4,a5,3aa <atoi+0x56>
    s++;
    neg = -1;
  }
  n = 0;
  while('0' <= *s && *s <= '9')
 368:	00054703          	lbu	a4,0(a0)
 36c:	fd07079b          	addiw	a5,a4,-48
 370:	0ff7f793          	zext.b	a5,a5
 374:	46a5                	li	a3,9
 376:	02f6ed63          	bltu	a3,a5,3b0 <atoi+0x5c>
  n = 0;
 37a:	4681                	li	a3,0
  while('0' <= *s && *s <= '9')
 37c:	4625                	li	a2,9
    n = n*10 + *s++ - '0';
 37e:	0505                	addi	a0,a0,1
 380:	0026979b          	slliw	a5,a3,0x2
 384:	9fb5                	addw	a5,a5,a3
 386:	0017979b          	slliw	a5,a5,0x1
 38a:	9fb9                	addw	a5,a5,a4
 38c:	fd07869b          	addiw	a3,a5,-48
  while('0' <= *s && *s <= '9')
 390:	00054703          	lbu	a4,0(a0)
 394:	fd07079b          	addiw	a5,a4,-48
 398:	0ff7f793          	zext.b	a5,a5
 39c:	fef671e3          	bgeu	a2,a5,37e <atoi+0x2a>
  return n * neg;
}
 3a0:	02d5853b          	mulw	a0,a1,a3
 3a4:	6422                	ld	s0,8(sp)
 3a6:	0141                	addi	sp,sp,16
 3a8:	8082                	ret
    s++;
 3aa:	0505                	addi	a0,a0,1
    neg = -1;
 3ac:	55fd                	li	a1,-1
 3ae:	bf6d                	j	368 <atoi+0x14>
  n = 0;
 3b0:	4681                	li	a3,0
 3b2:	b7fd                	j	3a0 <atoi+0x4c>

00000000000003b4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3b4:	1141                	addi	sp,sp,-16
 3b6:	e422                	sd	s0,8(sp)
 3b8:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3ba:	02b57463          	bgeu	a0,a1,3e2 <memmove+0x2e>
    while(n-- > 0)
 3be:	00c05f63          	blez	a2,3dc <memmove+0x28>
 3c2:	1602                	slli	a2,a2,0x20
 3c4:	9201                	srli	a2,a2,0x20
 3c6:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3ca:	872a                	mv	a4,a0
      *dst++ = *src++;
 3cc:	0585                	addi	a1,a1,1
 3ce:	0705                	addi	a4,a4,1
 3d0:	fff5c683          	lbu	a3,-1(a1)
 3d4:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3d8:	fef71ae3          	bne	a4,a5,3cc <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3dc:	6422                	ld	s0,8(sp)
 3de:	0141                	addi	sp,sp,16
 3e0:	8082                	ret
    dst += n;
 3e2:	00c50733          	add	a4,a0,a2
    src += n;
 3e6:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3e8:	fec05ae3          	blez	a2,3dc <memmove+0x28>
 3ec:	fff6079b          	addiw	a5,a2,-1
 3f0:	1782                	slli	a5,a5,0x20
 3f2:	9381                	srli	a5,a5,0x20
 3f4:	fff7c793          	not	a5,a5
 3f8:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3fa:	15fd                	addi	a1,a1,-1
 3fc:	177d                	addi	a4,a4,-1
 3fe:	0005c683          	lbu	a3,0(a1)
 402:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 406:	fee79ae3          	bne	a5,a4,3fa <memmove+0x46>
 40a:	bfc9                	j	3dc <memmove+0x28>

000000000000040c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 40c:	1141                	addi	sp,sp,-16
 40e:	e422                	sd	s0,8(sp)
 410:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 412:	ca05                	beqz	a2,442 <memcmp+0x36>
 414:	fff6069b          	addiw	a3,a2,-1
 418:	1682                	slli	a3,a3,0x20
 41a:	9281                	srli	a3,a3,0x20
 41c:	0685                	addi	a3,a3,1
 41e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 420:	00054783          	lbu	a5,0(a0)
 424:	0005c703          	lbu	a4,0(a1)
 428:	00e79863          	bne	a5,a4,438 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 42c:	0505                	addi	a0,a0,1
    p2++;
 42e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 430:	fed518e3          	bne	a0,a3,420 <memcmp+0x14>
  }
  return 0;
 434:	4501                	li	a0,0
 436:	a019                	j	43c <memcmp+0x30>
      return *p1 - *p2;
 438:	40e7853b          	subw	a0,a5,a4
}
 43c:	6422                	ld	s0,8(sp)
 43e:	0141                	addi	sp,sp,16
 440:	8082                	ret
  return 0;
 442:	4501                	li	a0,0
 444:	bfe5                	j	43c <memcmp+0x30>

0000000000000446 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 446:	1141                	addi	sp,sp,-16
 448:	e406                	sd	ra,8(sp)
 44a:	e022                	sd	s0,0(sp)
 44c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 44e:	00000097          	auipc	ra,0x0
 452:	f66080e7          	jalr	-154(ra) # 3b4 <memmove>
}
 456:	60a2                	ld	ra,8(sp)
 458:	6402                	ld	s0,0(sp)
 45a:	0141                	addi	sp,sp,16
 45c:	8082                	ret

000000000000045e <fork>:
# generated by usys.pl - do not edit
#include "kernel/include/sysnum.h"
.global fork
fork:
 li a7, SYS_fork
 45e:	4885                	li	a7,1
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <exit>:
.global exit
exit:
 li a7, SYS_exit
 466:	4889                	li	a7,2
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <wait>:
.global wait
wait:
 li a7, SYS_wait
 46e:	488d                	li	a7,3
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 476:	4891                	li	a7,4
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <read>:
.global read
read:
 li a7, SYS_read
 47e:	4895                	li	a7,5
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <write>:
.global write
write:
 li a7, SYS_write
 486:	48c1                	li	a7,16
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <close>:
.global close
close:
 li a7, SYS_close
 48e:	48d5                	li	a7,21
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <kill>:
.global kill
kill:
 li a7, SYS_kill
 496:	4899                	li	a7,6
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <exec>:
.global exec
exec:
 li a7, SYS_exec
 49e:	489d                	li	a7,7
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <open>:
.global open
open:
 li a7, SYS_open
 4a6:	48bd                	li	a7,15
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4ae:	48a1                	li	a7,8
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4b6:	48d1                	li	a7,20
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4be:	48a5                	li	a7,9
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4c6:	48a9                	li	a7,10
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4ce:	48ad                	li	a7,11
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4d6:	48b1                	li	a7,12
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4de:	48b5                	li	a7,13
 ecall
 4e0:	00000073          	ecall
 ret
 4e4:	8082                	ret

00000000000004e6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4e6:	48b9                	li	a7,14
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <test_proc>:
.global test_proc
test_proc:
 li a7, SYS_test_proc
 4ee:	48d9                	li	a7,22
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <dev>:
.global dev
dev:
 li a7, SYS_dev
 4f6:	48dd                	li	a7,23
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <readdir>:
.global readdir
readdir:
 li a7, SYS_readdir
 4fe:	48e1                	li	a7,24
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <getcwd>:
.global getcwd
getcwd:
 li a7, SYS_getcwd
 506:	48e5                	li	a7,25
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <remove>:
.global remove
remove:
 li a7, SYS_remove
 50e:	48c5                	li	a7,17
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <trace>:
.global trace
trace:
 li a7, SYS_trace
 516:	48c9                	li	a7,18
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <sysinfo>:
.global sysinfo
sysinfo:
 li a7, SYS_sysinfo
 51e:	48cd                	li	a7,19
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <rename>:
.global rename
rename:
 li a7, SYS_rename
 526:	48e9                	li	a7,26
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 52e:	1101                	addi	sp,sp,-32
 530:	ec06                	sd	ra,24(sp)
 532:	e822                	sd	s0,16(sp)
 534:	1000                	addi	s0,sp,32
 536:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 53a:	4605                	li	a2,1
 53c:	fef40593          	addi	a1,s0,-17
 540:	00000097          	auipc	ra,0x0
 544:	f46080e7          	jalr	-186(ra) # 486 <write>
}
 548:	60e2                	ld	ra,24(sp)
 54a:	6442                	ld	s0,16(sp)
 54c:	6105                	addi	sp,sp,32
 54e:	8082                	ret

0000000000000550 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 550:	7139                	addi	sp,sp,-64
 552:	fc06                	sd	ra,56(sp)
 554:	f822                	sd	s0,48(sp)
 556:	f426                	sd	s1,40(sp)
 558:	0080                	addi	s0,sp,64
 55a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 55c:	c299                	beqz	a3,562 <printint+0x12>
 55e:	0805cb63          	bltz	a1,5f4 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 562:	2581                	sext.w	a1,a1
  neg = 0;
 564:	4881                	li	a7,0
 566:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 56a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 56c:	2601                	sext.w	a2,a2
 56e:	00000517          	auipc	a0,0x0
 572:	55250513          	addi	a0,a0,1362 # ac0 <digits>
 576:	883a                	mv	a6,a4
 578:	2705                	addiw	a4,a4,1
 57a:	02c5f7bb          	remuw	a5,a1,a2
 57e:	1782                	slli	a5,a5,0x20
 580:	9381                	srli	a5,a5,0x20
 582:	97aa                	add	a5,a5,a0
 584:	0007c783          	lbu	a5,0(a5)
 588:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 58c:	0005879b          	sext.w	a5,a1
 590:	02c5d5bb          	divuw	a1,a1,a2
 594:	0685                	addi	a3,a3,1
 596:	fec7f0e3          	bgeu	a5,a2,576 <printint+0x26>
  if(neg)
 59a:	00088c63          	beqz	a7,5b2 <printint+0x62>
    buf[i++] = '-';
 59e:	fd070793          	addi	a5,a4,-48
 5a2:	00878733          	add	a4,a5,s0
 5a6:	02d00793          	li	a5,45
 5aa:	fef70823          	sb	a5,-16(a4)
 5ae:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5b2:	02e05c63          	blez	a4,5ea <printint+0x9a>
 5b6:	f04a                	sd	s2,32(sp)
 5b8:	ec4e                	sd	s3,24(sp)
 5ba:	fc040793          	addi	a5,s0,-64
 5be:	00e78933          	add	s2,a5,a4
 5c2:	fff78993          	addi	s3,a5,-1
 5c6:	99ba                	add	s3,s3,a4
 5c8:	377d                	addiw	a4,a4,-1
 5ca:	1702                	slli	a4,a4,0x20
 5cc:	9301                	srli	a4,a4,0x20
 5ce:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5d2:	fff94583          	lbu	a1,-1(s2)
 5d6:	8526                	mv	a0,s1
 5d8:	00000097          	auipc	ra,0x0
 5dc:	f56080e7          	jalr	-170(ra) # 52e <putc>
  while(--i >= 0)
 5e0:	197d                	addi	s2,s2,-1
 5e2:	ff3918e3          	bne	s2,s3,5d2 <printint+0x82>
 5e6:	7902                	ld	s2,32(sp)
 5e8:	69e2                	ld	s3,24(sp)
}
 5ea:	70e2                	ld	ra,56(sp)
 5ec:	7442                	ld	s0,48(sp)
 5ee:	74a2                	ld	s1,40(sp)
 5f0:	6121                	addi	sp,sp,64
 5f2:	8082                	ret
    x = -xx;
 5f4:	40b005bb          	negw	a1,a1
    neg = 1;
 5f8:	4885                	li	a7,1
    x = -xx;
 5fa:	b7b5                	j	566 <printint+0x16>

00000000000005fc <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5fc:	715d                	addi	sp,sp,-80
 5fe:	e486                	sd	ra,72(sp)
 600:	e0a2                	sd	s0,64(sp)
 602:	f84a                	sd	s2,48(sp)
 604:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 606:	0005c903          	lbu	s2,0(a1)
 60a:	1a090a63          	beqz	s2,7be <vprintf+0x1c2>
 60e:	fc26                	sd	s1,56(sp)
 610:	f44e                	sd	s3,40(sp)
 612:	f052                	sd	s4,32(sp)
 614:	ec56                	sd	s5,24(sp)
 616:	e85a                	sd	s6,16(sp)
 618:	e45e                	sd	s7,8(sp)
 61a:	8aaa                	mv	s5,a0
 61c:	8bb2                	mv	s7,a2
 61e:	00158493          	addi	s1,a1,1
  state = 0;
 622:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 624:	02500a13          	li	s4,37
 628:	4b55                	li	s6,21
 62a:	a839                	j	648 <vprintf+0x4c>
        putc(fd, c);
 62c:	85ca                	mv	a1,s2
 62e:	8556                	mv	a0,s5
 630:	00000097          	auipc	ra,0x0
 634:	efe080e7          	jalr	-258(ra) # 52e <putc>
 638:	a019                	j	63e <vprintf+0x42>
    } else if(state == '%'){
 63a:	01498d63          	beq	s3,s4,654 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 63e:	0485                	addi	s1,s1,1
 640:	fff4c903          	lbu	s2,-1(s1)
 644:	16090763          	beqz	s2,7b2 <vprintf+0x1b6>
    if(state == 0){
 648:	fe0999e3          	bnez	s3,63a <vprintf+0x3e>
      if(c == '%'){
 64c:	ff4910e3          	bne	s2,s4,62c <vprintf+0x30>
        state = '%';
 650:	89d2                	mv	s3,s4
 652:	b7f5                	j	63e <vprintf+0x42>
      if(c == 'd'){
 654:	13490463          	beq	s2,s4,77c <vprintf+0x180>
 658:	f9d9079b          	addiw	a5,s2,-99
 65c:	0ff7f793          	zext.b	a5,a5
 660:	12fb6763          	bltu	s6,a5,78e <vprintf+0x192>
 664:	f9d9079b          	addiw	a5,s2,-99
 668:	0ff7f713          	zext.b	a4,a5
 66c:	12eb6163          	bltu	s6,a4,78e <vprintf+0x192>
 670:	00271793          	slli	a5,a4,0x2
 674:	00000717          	auipc	a4,0x0
 678:	3f470713          	addi	a4,a4,1012 # a68 <malloc+0x1ba>
 67c:	97ba                	add	a5,a5,a4
 67e:	439c                	lw	a5,0(a5)
 680:	97ba                	add	a5,a5,a4
 682:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 684:	008b8913          	addi	s2,s7,8
 688:	4685                	li	a3,1
 68a:	4629                	li	a2,10
 68c:	000ba583          	lw	a1,0(s7)
 690:	8556                	mv	a0,s5
 692:	00000097          	auipc	ra,0x0
 696:	ebe080e7          	jalr	-322(ra) # 550 <printint>
 69a:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 69c:	4981                	li	s3,0
 69e:	b745                	j	63e <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6a0:	008b8913          	addi	s2,s7,8
 6a4:	4681                	li	a3,0
 6a6:	4629                	li	a2,10
 6a8:	000ba583          	lw	a1,0(s7)
 6ac:	8556                	mv	a0,s5
 6ae:	00000097          	auipc	ra,0x0
 6b2:	ea2080e7          	jalr	-350(ra) # 550 <printint>
 6b6:	8bca                	mv	s7,s2
      state = 0;
 6b8:	4981                	li	s3,0
 6ba:	b751                	j	63e <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 6bc:	008b8913          	addi	s2,s7,8
 6c0:	4681                	li	a3,0
 6c2:	4641                	li	a2,16
 6c4:	000ba583          	lw	a1,0(s7)
 6c8:	8556                	mv	a0,s5
 6ca:	00000097          	auipc	ra,0x0
 6ce:	e86080e7          	jalr	-378(ra) # 550 <printint>
 6d2:	8bca                	mv	s7,s2
      state = 0;
 6d4:	4981                	li	s3,0
 6d6:	b7a5                	j	63e <vprintf+0x42>
 6d8:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 6da:	008b8c13          	addi	s8,s7,8
 6de:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6e2:	03000593          	li	a1,48
 6e6:	8556                	mv	a0,s5
 6e8:	00000097          	auipc	ra,0x0
 6ec:	e46080e7          	jalr	-442(ra) # 52e <putc>
  putc(fd, 'x');
 6f0:	07800593          	li	a1,120
 6f4:	8556                	mv	a0,s5
 6f6:	00000097          	auipc	ra,0x0
 6fa:	e38080e7          	jalr	-456(ra) # 52e <putc>
 6fe:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 700:	00000b97          	auipc	s7,0x0
 704:	3c0b8b93          	addi	s7,s7,960 # ac0 <digits>
 708:	03c9d793          	srli	a5,s3,0x3c
 70c:	97de                	add	a5,a5,s7
 70e:	0007c583          	lbu	a1,0(a5)
 712:	8556                	mv	a0,s5
 714:	00000097          	auipc	ra,0x0
 718:	e1a080e7          	jalr	-486(ra) # 52e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 71c:	0992                	slli	s3,s3,0x4
 71e:	397d                	addiw	s2,s2,-1
 720:	fe0914e3          	bnez	s2,708 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 724:	8be2                	mv	s7,s8
      state = 0;
 726:	4981                	li	s3,0
 728:	6c02                	ld	s8,0(sp)
 72a:	bf11                	j	63e <vprintf+0x42>
        s = va_arg(ap, char*);
 72c:	008b8993          	addi	s3,s7,8
 730:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 734:	02090163          	beqz	s2,756 <vprintf+0x15a>
        while(*s != 0){
 738:	00094583          	lbu	a1,0(s2)
 73c:	c9a5                	beqz	a1,7ac <vprintf+0x1b0>
          putc(fd, *s);
 73e:	8556                	mv	a0,s5
 740:	00000097          	auipc	ra,0x0
 744:	dee080e7          	jalr	-530(ra) # 52e <putc>
          s++;
 748:	0905                	addi	s2,s2,1
        while(*s != 0){
 74a:	00094583          	lbu	a1,0(s2)
 74e:	f9e5                	bnez	a1,73e <vprintf+0x142>
        s = va_arg(ap, char*);
 750:	8bce                	mv	s7,s3
      state = 0;
 752:	4981                	li	s3,0
 754:	b5ed                	j	63e <vprintf+0x42>
          s = "(null)";
 756:	00000917          	auipc	s2,0x0
 75a:	30a90913          	addi	s2,s2,778 # a60 <malloc+0x1b2>
        while(*s != 0){
 75e:	02800593          	li	a1,40
 762:	bff1                	j	73e <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 764:	008b8913          	addi	s2,s7,8
 768:	000bc583          	lbu	a1,0(s7)
 76c:	8556                	mv	a0,s5
 76e:	00000097          	auipc	ra,0x0
 772:	dc0080e7          	jalr	-576(ra) # 52e <putc>
 776:	8bca                	mv	s7,s2
      state = 0;
 778:	4981                	li	s3,0
 77a:	b5d1                	j	63e <vprintf+0x42>
        putc(fd, c);
 77c:	02500593          	li	a1,37
 780:	8556                	mv	a0,s5
 782:	00000097          	auipc	ra,0x0
 786:	dac080e7          	jalr	-596(ra) # 52e <putc>
      state = 0;
 78a:	4981                	li	s3,0
 78c:	bd4d                	j	63e <vprintf+0x42>
        putc(fd, '%');
 78e:	02500593          	li	a1,37
 792:	8556                	mv	a0,s5
 794:	00000097          	auipc	ra,0x0
 798:	d9a080e7          	jalr	-614(ra) # 52e <putc>
        putc(fd, c);
 79c:	85ca                	mv	a1,s2
 79e:	8556                	mv	a0,s5
 7a0:	00000097          	auipc	ra,0x0
 7a4:	d8e080e7          	jalr	-626(ra) # 52e <putc>
      state = 0;
 7a8:	4981                	li	s3,0
 7aa:	bd51                	j	63e <vprintf+0x42>
        s = va_arg(ap, char*);
 7ac:	8bce                	mv	s7,s3
      state = 0;
 7ae:	4981                	li	s3,0
 7b0:	b579                	j	63e <vprintf+0x42>
 7b2:	74e2                	ld	s1,56(sp)
 7b4:	79a2                	ld	s3,40(sp)
 7b6:	7a02                	ld	s4,32(sp)
 7b8:	6ae2                	ld	s5,24(sp)
 7ba:	6b42                	ld	s6,16(sp)
 7bc:	6ba2                	ld	s7,8(sp)
    }
  }
}
 7be:	60a6                	ld	ra,72(sp)
 7c0:	6406                	ld	s0,64(sp)
 7c2:	7942                	ld	s2,48(sp)
 7c4:	6161                	addi	sp,sp,80
 7c6:	8082                	ret

00000000000007c8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7c8:	715d                	addi	sp,sp,-80
 7ca:	ec06                	sd	ra,24(sp)
 7cc:	e822                	sd	s0,16(sp)
 7ce:	1000                	addi	s0,sp,32
 7d0:	e010                	sd	a2,0(s0)
 7d2:	e414                	sd	a3,8(s0)
 7d4:	e818                	sd	a4,16(s0)
 7d6:	ec1c                	sd	a5,24(s0)
 7d8:	03043023          	sd	a6,32(s0)
 7dc:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7e0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7e4:	8622                	mv	a2,s0
 7e6:	00000097          	auipc	ra,0x0
 7ea:	e16080e7          	jalr	-490(ra) # 5fc <vprintf>
}
 7ee:	60e2                	ld	ra,24(sp)
 7f0:	6442                	ld	s0,16(sp)
 7f2:	6161                	addi	sp,sp,80
 7f4:	8082                	ret

00000000000007f6 <printf>:

void
printf(const char *fmt, ...)
{
 7f6:	711d                	addi	sp,sp,-96
 7f8:	ec06                	sd	ra,24(sp)
 7fa:	e822                	sd	s0,16(sp)
 7fc:	1000                	addi	s0,sp,32
 7fe:	e40c                	sd	a1,8(s0)
 800:	e810                	sd	a2,16(s0)
 802:	ec14                	sd	a3,24(s0)
 804:	f018                	sd	a4,32(s0)
 806:	f41c                	sd	a5,40(s0)
 808:	03043823          	sd	a6,48(s0)
 80c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 810:	00840613          	addi	a2,s0,8
 814:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 818:	85aa                	mv	a1,a0
 81a:	4505                	li	a0,1
 81c:	00000097          	auipc	ra,0x0
 820:	de0080e7          	jalr	-544(ra) # 5fc <vprintf>
}
 824:	60e2                	ld	ra,24(sp)
 826:	6442                	ld	s0,16(sp)
 828:	6125                	addi	sp,sp,96
 82a:	8082                	ret

000000000000082c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 82c:	1141                	addi	sp,sp,-16
 82e:	e422                	sd	s0,8(sp)
 830:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 832:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 836:	00000797          	auipc	a5,0x0
 83a:	2a27b783          	ld	a5,674(a5) # ad8 <freep>
 83e:	a02d                	j	868 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 840:	4618                	lw	a4,8(a2)
 842:	9f2d                	addw	a4,a4,a1
 844:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 848:	6398                	ld	a4,0(a5)
 84a:	6310                	ld	a2,0(a4)
 84c:	a83d                	j	88a <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 84e:	ff852703          	lw	a4,-8(a0)
 852:	9f31                	addw	a4,a4,a2
 854:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 856:	ff053683          	ld	a3,-16(a0)
 85a:	a091                	j	89e <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 85c:	6398                	ld	a4,0(a5)
 85e:	00e7e463          	bltu	a5,a4,866 <free+0x3a>
 862:	00e6ea63          	bltu	a3,a4,876 <free+0x4a>
{
 866:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 868:	fed7fae3          	bgeu	a5,a3,85c <free+0x30>
 86c:	6398                	ld	a4,0(a5)
 86e:	00e6e463          	bltu	a3,a4,876 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 872:	fee7eae3          	bltu	a5,a4,866 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 876:	ff852583          	lw	a1,-8(a0)
 87a:	6390                	ld	a2,0(a5)
 87c:	02059813          	slli	a6,a1,0x20
 880:	01c85713          	srli	a4,a6,0x1c
 884:	9736                	add	a4,a4,a3
 886:	fae60de3          	beq	a2,a4,840 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 88a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 88e:	4790                	lw	a2,8(a5)
 890:	02061593          	slli	a1,a2,0x20
 894:	01c5d713          	srli	a4,a1,0x1c
 898:	973e                	add	a4,a4,a5
 89a:	fae68ae3          	beq	a3,a4,84e <free+0x22>
    p->s.ptr = bp->s.ptr;
 89e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8a0:	00000717          	auipc	a4,0x0
 8a4:	22f73c23          	sd	a5,568(a4) # ad8 <freep>
}
 8a8:	6422                	ld	s0,8(sp)
 8aa:	0141                	addi	sp,sp,16
 8ac:	8082                	ret

00000000000008ae <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8ae:	7139                	addi	sp,sp,-64
 8b0:	fc06                	sd	ra,56(sp)
 8b2:	f822                	sd	s0,48(sp)
 8b4:	f426                	sd	s1,40(sp)
 8b6:	ec4e                	sd	s3,24(sp)
 8b8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8ba:	02051493          	slli	s1,a0,0x20
 8be:	9081                	srli	s1,s1,0x20
 8c0:	04bd                	addi	s1,s1,15
 8c2:	8091                	srli	s1,s1,0x4
 8c4:	0014899b          	addiw	s3,s1,1
 8c8:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8ca:	00000517          	auipc	a0,0x0
 8ce:	20e53503          	ld	a0,526(a0) # ad8 <freep>
 8d2:	c915                	beqz	a0,906 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8d4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8d6:	4798                	lw	a4,8(a5)
 8d8:	08977e63          	bgeu	a4,s1,974 <malloc+0xc6>
 8dc:	f04a                	sd	s2,32(sp)
 8de:	e852                	sd	s4,16(sp)
 8e0:	e456                	sd	s5,8(sp)
 8e2:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8e4:	8a4e                	mv	s4,s3
 8e6:	0009871b          	sext.w	a4,s3
 8ea:	6685                	lui	a3,0x1
 8ec:	00d77363          	bgeu	a4,a3,8f2 <malloc+0x44>
 8f0:	6a05                	lui	s4,0x1
 8f2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8f6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8fa:	00000917          	auipc	s2,0x0
 8fe:	1de90913          	addi	s2,s2,478 # ad8 <freep>
  if(p == (char*)-1)
 902:	5afd                	li	s5,-1
 904:	a091                	j	948 <malloc+0x9a>
 906:	f04a                	sd	s2,32(sp)
 908:	e852                	sd	s4,16(sp)
 90a:	e456                	sd	s5,8(sp)
 90c:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 90e:	00000797          	auipc	a5,0x0
 912:	1d278793          	addi	a5,a5,466 # ae0 <base>
 916:	00000717          	auipc	a4,0x0
 91a:	1cf73123          	sd	a5,450(a4) # ad8 <freep>
 91e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 920:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 924:	b7c1                	j	8e4 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 926:	6398                	ld	a4,0(a5)
 928:	e118                	sd	a4,0(a0)
 92a:	a08d                	j	98c <malloc+0xde>
  hp->s.size = nu;
 92c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 930:	0541                	addi	a0,a0,16
 932:	00000097          	auipc	ra,0x0
 936:	efa080e7          	jalr	-262(ra) # 82c <free>
  return freep;
 93a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 93e:	c13d                	beqz	a0,9a4 <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 940:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 942:	4798                	lw	a4,8(a5)
 944:	02977463          	bgeu	a4,s1,96c <malloc+0xbe>
    if(p == freep)
 948:	00093703          	ld	a4,0(s2)
 94c:	853e                	mv	a0,a5
 94e:	fef719e3          	bne	a4,a5,940 <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 952:	8552                	mv	a0,s4
 954:	00000097          	auipc	ra,0x0
 958:	b82080e7          	jalr	-1150(ra) # 4d6 <sbrk>
  if(p == (char*)-1)
 95c:	fd5518e3          	bne	a0,s5,92c <malloc+0x7e>
        return 0;
 960:	4501                	li	a0,0
 962:	7902                	ld	s2,32(sp)
 964:	6a42                	ld	s4,16(sp)
 966:	6aa2                	ld	s5,8(sp)
 968:	6b02                	ld	s6,0(sp)
 96a:	a03d                	j	998 <malloc+0xea>
 96c:	7902                	ld	s2,32(sp)
 96e:	6a42                	ld	s4,16(sp)
 970:	6aa2                	ld	s5,8(sp)
 972:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 974:	fae489e3          	beq	s1,a4,926 <malloc+0x78>
        p->s.size -= nunits;
 978:	4137073b          	subw	a4,a4,s3
 97c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 97e:	02071693          	slli	a3,a4,0x20
 982:	01c6d713          	srli	a4,a3,0x1c
 986:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 988:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 98c:	00000717          	auipc	a4,0x0
 990:	14a73623          	sd	a0,332(a4) # ad8 <freep>
      return (void*)(p + 1);
 994:	01078513          	addi	a0,a5,16
  }
}
 998:	70e2                	ld	ra,56(sp)
 99a:	7442                	ld	s0,48(sp)
 99c:	74a2                	ld	s1,40(sp)
 99e:	69e2                	ld	s3,24(sp)
 9a0:	6121                	addi	sp,sp,64
 9a2:	8082                	ret
 9a4:	7902                	ld	s2,32(sp)
 9a6:	6a42                	ld	s4,16(sp)
 9a8:	6aa2                	ld	s5,8(sp)
 9aa:	6b02                	ld	s6,0(sp)
 9ac:	b7f5                	j	998 <malloc+0xea>
