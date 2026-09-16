
xv6-user/_grep:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <matchstar>:
  return 0;
}

// matchstar: search for c*re at beginning of text
int matchstar(int c, char *re, char *text)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	e052                	sd	s4,0(sp)
   e:	1800                	addi	s0,sp,48
  10:	892a                	mv	s2,a0
  12:	89ae                	mv	s3,a1
  14:	84b2                	mv	s1,a2
  do{  // a * matches zero or more instances
    if(matchhere(re, text))
      return 1;
  }while(*text!='\0' && (*text++==c || c=='.'));
  16:	02e00a13          	li	s4,46
    if(matchhere(re, text))
  1a:	85a6                	mv	a1,s1
  1c:	854e                	mv	a0,s3
  1e:	00000097          	auipc	ra,0x0
  22:	030080e7          	jalr	48(ra) # 4e <matchhere>
  26:	e919                	bnez	a0,3c <matchstar+0x3c>
  }while(*text!='\0' && (*text++==c || c=='.'));
  28:	0004c783          	lbu	a5,0(s1)
  2c:	cb89                	beqz	a5,3e <matchstar+0x3e>
  2e:	0485                	addi	s1,s1,1
  30:	2781                	sext.w	a5,a5
  32:	ff2784e3          	beq	a5,s2,1a <matchstar+0x1a>
  36:	ff4902e3          	beq	s2,s4,1a <matchstar+0x1a>
  3a:	a011                	j	3e <matchstar+0x3e>
      return 1;
  3c:	4505                	li	a0,1
  return 0;
}
  3e:	70a2                	ld	ra,40(sp)
  40:	7402                	ld	s0,32(sp)
  42:	64e2                	ld	s1,24(sp)
  44:	6942                	ld	s2,16(sp)
  46:	69a2                	ld	s3,8(sp)
  48:	6a02                	ld	s4,0(sp)
  4a:	6145                	addi	sp,sp,48
  4c:	8082                	ret

000000000000004e <matchhere>:
  if(re[0] == '\0')
  4e:	00054703          	lbu	a4,0(a0)
  52:	cb3d                	beqz	a4,c8 <matchhere+0x7a>
{
  54:	1141                	addi	sp,sp,-16
  56:	e406                	sd	ra,8(sp)
  58:	e022                	sd	s0,0(sp)
  5a:	0800                	addi	s0,sp,16
  5c:	87aa                	mv	a5,a0
  if(re[1] == '*')
  5e:	00154683          	lbu	a3,1(a0)
  62:	02a00613          	li	a2,42
  66:	02c68563          	beq	a3,a2,90 <matchhere+0x42>
  if(re[0] == '$' && re[1] == '\0')
  6a:	02400613          	li	a2,36
  6e:	02c70a63          	beq	a4,a2,a2 <matchhere+0x54>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  72:	0005c683          	lbu	a3,0(a1)
  return 0;
  76:	4501                	li	a0,0
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  78:	ca81                	beqz	a3,88 <matchhere+0x3a>
  7a:	02e00613          	li	a2,46
  7e:	02c70d63          	beq	a4,a2,b8 <matchhere+0x6a>
  return 0;
  82:	4501                	li	a0,0
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  84:	02d70a63          	beq	a4,a3,b8 <matchhere+0x6a>
}
  88:	60a2                	ld	ra,8(sp)
  8a:	6402                	ld	s0,0(sp)
  8c:	0141                	addi	sp,sp,16
  8e:	8082                	ret
    return matchstar(re[0], re+2, text);
  90:	862e                	mv	a2,a1
  92:	00250593          	addi	a1,a0,2
  96:	853a                	mv	a0,a4
  98:	00000097          	auipc	ra,0x0
  9c:	f68080e7          	jalr	-152(ra) # 0 <matchstar>
  a0:	b7e5                	j	88 <matchhere+0x3a>
  if(re[0] == '$' && re[1] == '\0')
  a2:	c691                	beqz	a3,ae <matchhere+0x60>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  a4:	0005c683          	lbu	a3,0(a1)
  a8:	fee9                	bnez	a3,82 <matchhere+0x34>
  return 0;
  aa:	4501                	li	a0,0
  ac:	bff1                	j	88 <matchhere+0x3a>
    return *text == '\0';
  ae:	0005c503          	lbu	a0,0(a1)
  b2:	00153513          	seqz	a0,a0
  b6:	bfc9                	j	88 <matchhere+0x3a>
    return matchhere(re+1, text+1);
  b8:	0585                	addi	a1,a1,1
  ba:	00178513          	addi	a0,a5,1
  be:	00000097          	auipc	ra,0x0
  c2:	f90080e7          	jalr	-112(ra) # 4e <matchhere>
  c6:	b7c9                	j	88 <matchhere+0x3a>
    return 1;
  c8:	4505                	li	a0,1
}
  ca:	8082                	ret

00000000000000cc <match>:
{
  cc:	1101                	addi	sp,sp,-32
  ce:	ec06                	sd	ra,24(sp)
  d0:	e822                	sd	s0,16(sp)
  d2:	e426                	sd	s1,8(sp)
  d4:	e04a                	sd	s2,0(sp)
  d6:	1000                	addi	s0,sp,32
  d8:	892a                	mv	s2,a0
  da:	84ae                	mv	s1,a1
  if(re[0] == '^')
  dc:	00054703          	lbu	a4,0(a0)
  e0:	05e00793          	li	a5,94
  e4:	00f70e63          	beq	a4,a5,100 <match+0x34>
    if(matchhere(re, text))
  e8:	85a6                	mv	a1,s1
  ea:	854a                	mv	a0,s2
  ec:	00000097          	auipc	ra,0x0
  f0:	f62080e7          	jalr	-158(ra) # 4e <matchhere>
  f4:	ed01                	bnez	a0,10c <match+0x40>
  }while(*text++ != '\0');
  f6:	0485                	addi	s1,s1,1
  f8:	fff4c783          	lbu	a5,-1(s1)
  fc:	f7f5                	bnez	a5,e8 <match+0x1c>
  fe:	a801                	j	10e <match+0x42>
    return matchhere(re+1, text);
 100:	0505                	addi	a0,a0,1
 102:	00000097          	auipc	ra,0x0
 106:	f4c080e7          	jalr	-180(ra) # 4e <matchhere>
 10a:	a011                	j	10e <match+0x42>
      return 1;
 10c:	4505                	li	a0,1
}
 10e:	60e2                	ld	ra,24(sp)
 110:	6442                	ld	s0,16(sp)
 112:	64a2                	ld	s1,8(sp)
 114:	6902                	ld	s2,0(sp)
 116:	6105                	addi	sp,sp,32
 118:	8082                	ret

000000000000011a <grep>:
{
 11a:	715d                	addi	sp,sp,-80
 11c:	e486                	sd	ra,72(sp)
 11e:	e0a2                	sd	s0,64(sp)
 120:	fc26                	sd	s1,56(sp)
 122:	f84a                	sd	s2,48(sp)
 124:	f44e                	sd	s3,40(sp)
 126:	f052                	sd	s4,32(sp)
 128:	ec56                	sd	s5,24(sp)
 12a:	e85a                	sd	s6,16(sp)
 12c:	e45e                	sd	s7,8(sp)
 12e:	e062                	sd	s8,0(sp)
 130:	0880                	addi	s0,sp,80
 132:	89aa                	mv	s3,a0
 134:	8b2e                	mv	s6,a1
  m = 0;
 136:	4a01                	li	s4,0
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 138:	3ff00b93          	li	s7,1023
 13c:	00001a97          	auipc	s5,0x1
 140:	a24a8a93          	addi	s5,s5,-1500 # b60 <buf>
 144:	a0a1                	j	18c <grep+0x72>
      p = q+1;
 146:	00148913          	addi	s2,s1,1
    while((q = strchr(p, '\n')) != 0){
 14a:	45a9                	li	a1,10
 14c:	854a                	mv	a0,s2
 14e:	00000097          	auipc	ra,0x0
 152:	21e080e7          	jalr	542(ra) # 36c <strchr>
 156:	84aa                	mv	s1,a0
 158:	c905                	beqz	a0,188 <grep+0x6e>
      *q = 0;
 15a:	00048023          	sb	zero,0(s1)
      if(match(pattern, p)){
 15e:	85ca                	mv	a1,s2
 160:	854e                	mv	a0,s3
 162:	00000097          	auipc	ra,0x0
 166:	f6a080e7          	jalr	-150(ra) # cc <match>
 16a:	dd71                	beqz	a0,146 <grep+0x2c>
        *q = '\n';
 16c:	47a9                	li	a5,10
 16e:	00f48023          	sb	a5,0(s1)
        write(1, p, q+1 - p);
 172:	00148613          	addi	a2,s1,1
 176:	4126063b          	subw	a2,a2,s2
 17a:	85ca                	mv	a1,s2
 17c:	4505                	li	a0,1
 17e:	00000097          	auipc	ra,0x0
 182:	3fe080e7          	jalr	1022(ra) # 57c <write>
 186:	b7c1                	j	146 <grep+0x2c>
    if(m > 0){
 188:	03404763          	bgtz	s4,1b6 <grep+0x9c>
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 18c:	414b863b          	subw	a2,s7,s4
 190:	014a85b3          	add	a1,s5,s4
 194:	855a                	mv	a0,s6
 196:	00000097          	auipc	ra,0x0
 19a:	3de080e7          	jalr	990(ra) # 574 <read>
 19e:	02a05b63          	blez	a0,1d4 <grep+0xba>
    m += n;
 1a2:	00aa0c3b          	addw	s8,s4,a0
 1a6:	000c0a1b          	sext.w	s4,s8
    buf[m] = '\0';
 1aa:	014a87b3          	add	a5,s5,s4
 1ae:	00078023          	sb	zero,0(a5)
    p = buf;
 1b2:	8956                	mv	s2,s5
    while((q = strchr(p, '\n')) != 0){
 1b4:	bf59                	j	14a <grep+0x30>
      m -= p - buf;
 1b6:	00001517          	auipc	a0,0x1
 1ba:	9aa50513          	addi	a0,a0,-1622 # b60 <buf>
 1be:	40a90a33          	sub	s4,s2,a0
 1c2:	414c0a3b          	subw	s4,s8,s4
      memmove(buf, p, m);
 1c6:	8652                	mv	a2,s4
 1c8:	85ca                	mv	a1,s2
 1ca:	00000097          	auipc	ra,0x0
 1ce:	2e0080e7          	jalr	736(ra) # 4aa <memmove>
 1d2:	bf6d                	j	18c <grep+0x72>
}
 1d4:	60a6                	ld	ra,72(sp)
 1d6:	6406                	ld	s0,64(sp)
 1d8:	74e2                	ld	s1,56(sp)
 1da:	7942                	ld	s2,48(sp)
 1dc:	79a2                	ld	s3,40(sp)
 1de:	7a02                	ld	s4,32(sp)
 1e0:	6ae2                	ld	s5,24(sp)
 1e2:	6b42                	ld	s6,16(sp)
 1e4:	6ba2                	ld	s7,8(sp)
 1e6:	6c02                	ld	s8,0(sp)
 1e8:	6161                	addi	sp,sp,80
 1ea:	8082                	ret

00000000000001ec <main>:
{
 1ec:	7179                	addi	sp,sp,-48
 1ee:	f406                	sd	ra,40(sp)
 1f0:	f022                	sd	s0,32(sp)
 1f2:	ec26                	sd	s1,24(sp)
 1f4:	e84a                	sd	s2,16(sp)
 1f6:	e44e                	sd	s3,8(sp)
 1f8:	e052                	sd	s4,0(sp)
 1fa:	1800                	addi	s0,sp,48
  if(argc <= 1){
 1fc:	4785                	li	a5,1
 1fe:	04a7de63          	bge	a5,a0,25a <main+0x6e>
  pattern = argv[1];
 202:	0085ba03          	ld	s4,8(a1)
  if(argc <= 2){
 206:	4789                	li	a5,2
 208:	06a7d763          	bge	a5,a0,276 <main+0x8a>
 20c:	01058913          	addi	s2,a1,16
 210:	ffd5099b          	addiw	s3,a0,-3
 214:	02099793          	slli	a5,s3,0x20
 218:	01d7d993          	srli	s3,a5,0x1d
 21c:	05e1                	addi	a1,a1,24
 21e:	99ae                	add	s3,s3,a1
    if((fd = open(argv[i], 0)) < 0){
 220:	4581                	li	a1,0
 222:	00093503          	ld	a0,0(s2)
 226:	00000097          	auipc	ra,0x0
 22a:	376080e7          	jalr	886(ra) # 59c <open>
 22e:	84aa                	mv	s1,a0
 230:	04054e63          	bltz	a0,28c <main+0xa0>
    grep(pattern, fd);
 234:	85aa                	mv	a1,a0
 236:	8552                	mv	a0,s4
 238:	00000097          	auipc	ra,0x0
 23c:	ee2080e7          	jalr	-286(ra) # 11a <grep>
    close(fd);
 240:	8526                	mv	a0,s1
 242:	00000097          	auipc	ra,0x0
 246:	342080e7          	jalr	834(ra) # 584 <close>
  for(i = 2; i < argc; i++){
 24a:	0921                	addi	s2,s2,8
 24c:	fd391ae3          	bne	s2,s3,220 <main+0x34>
  exit(0);
 250:	4501                	li	a0,0
 252:	00000097          	auipc	ra,0x0
 256:	30a080e7          	jalr	778(ra) # 55c <exit>
    fprintf(2, "usage: grep pattern [file ...]\n");
 25a:	00001597          	auipc	a1,0x1
 25e:	84e58593          	addi	a1,a1,-1970 # aa8 <malloc+0x104>
 262:	4509                	li	a0,2
 264:	00000097          	auipc	ra,0x0
 268:	65a080e7          	jalr	1626(ra) # 8be <fprintf>
    exit(1);
 26c:	4505                	li	a0,1
 26e:	00000097          	auipc	ra,0x0
 272:	2ee080e7          	jalr	750(ra) # 55c <exit>
    grep(pattern, 0);
 276:	4581                	li	a1,0
 278:	8552                	mv	a0,s4
 27a:	00000097          	auipc	ra,0x0
 27e:	ea0080e7          	jalr	-352(ra) # 11a <grep>
    exit(0);
 282:	4501                	li	a0,0
 284:	00000097          	auipc	ra,0x0
 288:	2d8080e7          	jalr	728(ra) # 55c <exit>
      printf("grep: cannot open %s\n", argv[i]);
 28c:	00093583          	ld	a1,0(s2)
 290:	00001517          	auipc	a0,0x1
 294:	83850513          	addi	a0,a0,-1992 # ac8 <malloc+0x124>
 298:	00000097          	auipc	ra,0x0
 29c:	654080e7          	jalr	1620(ra) # 8ec <printf>
      exit(1);
 2a0:	4505                	li	a0,1
 2a2:	00000097          	auipc	ra,0x0
 2a6:	2ba080e7          	jalr	698(ra) # 55c <exit>

00000000000002aa <strcpy>:
#include "kernel/include/fcntl.h"
#include "xv6-user/user.h"

char*
strcpy(char *s, const char *t)
{
 2aa:	1141                	addi	sp,sp,-16
 2ac:	e422                	sd	s0,8(sp)
 2ae:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 2b0:	87aa                	mv	a5,a0
 2b2:	0585                	addi	a1,a1,1
 2b4:	0785                	addi	a5,a5,1
 2b6:	fff5c703          	lbu	a4,-1(a1)
 2ba:	fee78fa3          	sb	a4,-1(a5)
 2be:	fb75                	bnez	a4,2b2 <strcpy+0x8>
    ;
  return os;
}
 2c0:	6422                	ld	s0,8(sp)
 2c2:	0141                	addi	sp,sp,16
 2c4:	8082                	ret

00000000000002c6 <strcat>:

char*
strcat(char *s, const char *t)
{
 2c6:	1141                	addi	sp,sp,-16
 2c8:	e422                	sd	s0,8(sp)
 2ca:	0800                	addi	s0,sp,16
  char *os = s;
  while(*s)
 2cc:	00054783          	lbu	a5,0(a0)
 2d0:	c385                	beqz	a5,2f0 <strcat+0x2a>
 2d2:	87aa                	mv	a5,a0
    s++;
 2d4:	0785                	addi	a5,a5,1
  while(*s)
 2d6:	0007c703          	lbu	a4,0(a5)
 2da:	ff6d                	bnez	a4,2d4 <strcat+0xe>
  while((*s++ = *t++))
 2dc:	0585                	addi	a1,a1,1
 2de:	0785                	addi	a5,a5,1
 2e0:	fff5c703          	lbu	a4,-1(a1)
 2e4:	fee78fa3          	sb	a4,-1(a5)
 2e8:	fb75                	bnez	a4,2dc <strcat+0x16>
    ;
  return os;
}
 2ea:	6422                	ld	s0,8(sp)
 2ec:	0141                	addi	sp,sp,16
 2ee:	8082                	ret
  while(*s)
 2f0:	87aa                	mv	a5,a0
 2f2:	b7ed                	j	2dc <strcat+0x16>

00000000000002f4 <strcmp>:


int
strcmp(const char *p, const char *q)
{
 2f4:	1141                	addi	sp,sp,-16
 2f6:	e422                	sd	s0,8(sp)
 2f8:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 2fa:	00054783          	lbu	a5,0(a0)
 2fe:	cb91                	beqz	a5,312 <strcmp+0x1e>
 300:	0005c703          	lbu	a4,0(a1)
 304:	00f71763          	bne	a4,a5,312 <strcmp+0x1e>
    p++, q++;
 308:	0505                	addi	a0,a0,1
 30a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 30c:	00054783          	lbu	a5,0(a0)
 310:	fbe5                	bnez	a5,300 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 312:	0005c503          	lbu	a0,0(a1)
}
 316:	40a7853b          	subw	a0,a5,a0
 31a:	6422                	ld	s0,8(sp)
 31c:	0141                	addi	sp,sp,16
 31e:	8082                	ret

0000000000000320 <strlen>:

uint
strlen(const char *s)
{
 320:	1141                	addi	sp,sp,-16
 322:	e422                	sd	s0,8(sp)
 324:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 326:	00054783          	lbu	a5,0(a0)
 32a:	cf91                	beqz	a5,346 <strlen+0x26>
 32c:	0505                	addi	a0,a0,1
 32e:	87aa                	mv	a5,a0
 330:	86be                	mv	a3,a5
 332:	0785                	addi	a5,a5,1
 334:	fff7c703          	lbu	a4,-1(a5)
 338:	ff65                	bnez	a4,330 <strlen+0x10>
 33a:	40a6853b          	subw	a0,a3,a0
 33e:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 340:	6422                	ld	s0,8(sp)
 342:	0141                	addi	sp,sp,16
 344:	8082                	ret
  for(n = 0; s[n]; n++)
 346:	4501                	li	a0,0
 348:	bfe5                	j	340 <strlen+0x20>

000000000000034a <memset>:

void*
memset(void *dst, int c, uint n)
{
 34a:	1141                	addi	sp,sp,-16
 34c:	e422                	sd	s0,8(sp)
 34e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 350:	ca19                	beqz	a2,366 <memset+0x1c>
 352:	87aa                	mv	a5,a0
 354:	1602                	slli	a2,a2,0x20
 356:	9201                	srli	a2,a2,0x20
 358:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 35c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 360:	0785                	addi	a5,a5,1
 362:	fee79de3          	bne	a5,a4,35c <memset+0x12>
  }
  return dst;
}
 366:	6422                	ld	s0,8(sp)
 368:	0141                	addi	sp,sp,16
 36a:	8082                	ret

000000000000036c <strchr>:

char*
strchr(const char *s, char c)
{
 36c:	1141                	addi	sp,sp,-16
 36e:	e422                	sd	s0,8(sp)
 370:	0800                	addi	s0,sp,16
  for(; *s; s++)
 372:	00054783          	lbu	a5,0(a0)
 376:	cb99                	beqz	a5,38c <strchr+0x20>
    if(*s == c)
 378:	00f58763          	beq	a1,a5,386 <strchr+0x1a>
  for(; *s; s++)
 37c:	0505                	addi	a0,a0,1
 37e:	00054783          	lbu	a5,0(a0)
 382:	fbfd                	bnez	a5,378 <strchr+0xc>
      return (char*)s;
  return 0;
 384:	4501                	li	a0,0
}
 386:	6422                	ld	s0,8(sp)
 388:	0141                	addi	sp,sp,16
 38a:	8082                	ret
  return 0;
 38c:	4501                	li	a0,0
 38e:	bfe5                	j	386 <strchr+0x1a>

0000000000000390 <gets>:

char*
gets(char *buf, int max)
{
 390:	711d                	addi	sp,sp,-96
 392:	ec86                	sd	ra,88(sp)
 394:	e8a2                	sd	s0,80(sp)
 396:	e4a6                	sd	s1,72(sp)
 398:	e0ca                	sd	s2,64(sp)
 39a:	fc4e                	sd	s3,56(sp)
 39c:	f852                	sd	s4,48(sp)
 39e:	f456                	sd	s5,40(sp)
 3a0:	f05a                	sd	s6,32(sp)
 3a2:	ec5e                	sd	s7,24(sp)
 3a4:	1080                	addi	s0,sp,96
 3a6:	8baa                	mv	s7,a0
 3a8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3aa:	892a                	mv	s2,a0
 3ac:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 3ae:	4aa9                	li	s5,10
 3b0:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 3b2:	89a6                	mv	s3,s1
 3b4:	2485                	addiw	s1,s1,1
 3b6:	0344d863          	bge	s1,s4,3e6 <gets+0x56>
    cc = read(0, &c, 1);
 3ba:	4605                	li	a2,1
 3bc:	faf40593          	addi	a1,s0,-81
 3c0:	4501                	li	a0,0
 3c2:	00000097          	auipc	ra,0x0
 3c6:	1b2080e7          	jalr	434(ra) # 574 <read>
    if(cc < 1)
 3ca:	00a05e63          	blez	a0,3e6 <gets+0x56>
    buf[i++] = c;
 3ce:	faf44783          	lbu	a5,-81(s0)
 3d2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 3d6:	01578763          	beq	a5,s5,3e4 <gets+0x54>
 3da:	0905                	addi	s2,s2,1
 3dc:	fd679be3          	bne	a5,s6,3b2 <gets+0x22>
    buf[i++] = c;
 3e0:	89a6                	mv	s3,s1
 3e2:	a011                	j	3e6 <gets+0x56>
 3e4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 3e6:	99de                	add	s3,s3,s7
 3e8:	00098023          	sb	zero,0(s3)
  return buf;
}
 3ec:	855e                	mv	a0,s7
 3ee:	60e6                	ld	ra,88(sp)
 3f0:	6446                	ld	s0,80(sp)
 3f2:	64a6                	ld	s1,72(sp)
 3f4:	6906                	ld	s2,64(sp)
 3f6:	79e2                	ld	s3,56(sp)
 3f8:	7a42                	ld	s4,48(sp)
 3fa:	7aa2                	ld	s5,40(sp)
 3fc:	7b02                	ld	s6,32(sp)
 3fe:	6be2                	ld	s7,24(sp)
 400:	6125                	addi	sp,sp,96
 402:	8082                	ret

0000000000000404 <stat>:

int
stat(const char *n, struct stat *st)
{
 404:	1101                	addi	sp,sp,-32
 406:	ec06                	sd	ra,24(sp)
 408:	e822                	sd	s0,16(sp)
 40a:	e04a                	sd	s2,0(sp)
 40c:	1000                	addi	s0,sp,32
 40e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 410:	4581                	li	a1,0
 412:	00000097          	auipc	ra,0x0
 416:	18a080e7          	jalr	394(ra) # 59c <open>
  if(fd < 0)
 41a:	02054663          	bltz	a0,446 <stat+0x42>
 41e:	e426                	sd	s1,8(sp)
 420:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 422:	85ca                	mv	a1,s2
 424:	00000097          	auipc	ra,0x0
 428:	180080e7          	jalr	384(ra) # 5a4 <fstat>
 42c:	892a                	mv	s2,a0
  close(fd);
 42e:	8526                	mv	a0,s1
 430:	00000097          	auipc	ra,0x0
 434:	154080e7          	jalr	340(ra) # 584 <close>
  return r;
 438:	64a2                	ld	s1,8(sp)
}
 43a:	854a                	mv	a0,s2
 43c:	60e2                	ld	ra,24(sp)
 43e:	6442                	ld	s0,16(sp)
 440:	6902                	ld	s2,0(sp)
 442:	6105                	addi	sp,sp,32
 444:	8082                	ret
    return -1;
 446:	597d                	li	s2,-1
 448:	bfcd                	j	43a <stat+0x36>

000000000000044a <atoi>:

int
atoi(const char *s)
{
 44a:	1141                	addi	sp,sp,-16
 44c:	e422                	sd	s0,8(sp)
 44e:	0800                	addi	s0,sp,16
  int n;
  int neg = 1;
  if (*s == '-') {
 450:	00054703          	lbu	a4,0(a0)
 454:	02d00793          	li	a5,45
  int neg = 1;
 458:	4585                	li	a1,1
  if (*s == '-') {
 45a:	04f70363          	beq	a4,a5,4a0 <atoi+0x56>
    s++;
    neg = -1;
  }
  n = 0;
  while('0' <= *s && *s <= '9')
 45e:	00054703          	lbu	a4,0(a0)
 462:	fd07079b          	addiw	a5,a4,-48
 466:	0ff7f793          	zext.b	a5,a5
 46a:	46a5                	li	a3,9
 46c:	02f6ed63          	bltu	a3,a5,4a6 <atoi+0x5c>
  n = 0;
 470:	4681                	li	a3,0
  while('0' <= *s && *s <= '9')
 472:	4625                	li	a2,9
    n = n*10 + *s++ - '0';
 474:	0505                	addi	a0,a0,1
 476:	0026979b          	slliw	a5,a3,0x2
 47a:	9fb5                	addw	a5,a5,a3
 47c:	0017979b          	slliw	a5,a5,0x1
 480:	9fb9                	addw	a5,a5,a4
 482:	fd07869b          	addiw	a3,a5,-48
  while('0' <= *s && *s <= '9')
 486:	00054703          	lbu	a4,0(a0)
 48a:	fd07079b          	addiw	a5,a4,-48
 48e:	0ff7f793          	zext.b	a5,a5
 492:	fef671e3          	bgeu	a2,a5,474 <atoi+0x2a>
  return n * neg;
}
 496:	02d5853b          	mulw	a0,a1,a3
 49a:	6422                	ld	s0,8(sp)
 49c:	0141                	addi	sp,sp,16
 49e:	8082                	ret
    s++;
 4a0:	0505                	addi	a0,a0,1
    neg = -1;
 4a2:	55fd                	li	a1,-1
 4a4:	bf6d                	j	45e <atoi+0x14>
  n = 0;
 4a6:	4681                	li	a3,0
 4a8:	b7fd                	j	496 <atoi+0x4c>

00000000000004aa <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 4aa:	1141                	addi	sp,sp,-16
 4ac:	e422                	sd	s0,8(sp)
 4ae:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 4b0:	02b57463          	bgeu	a0,a1,4d8 <memmove+0x2e>
    while(n-- > 0)
 4b4:	00c05f63          	blez	a2,4d2 <memmove+0x28>
 4b8:	1602                	slli	a2,a2,0x20
 4ba:	9201                	srli	a2,a2,0x20
 4bc:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 4c0:	872a                	mv	a4,a0
      *dst++ = *src++;
 4c2:	0585                	addi	a1,a1,1
 4c4:	0705                	addi	a4,a4,1
 4c6:	fff5c683          	lbu	a3,-1(a1)
 4ca:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 4ce:	fef71ae3          	bne	a4,a5,4c2 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 4d2:	6422                	ld	s0,8(sp)
 4d4:	0141                	addi	sp,sp,16
 4d6:	8082                	ret
    dst += n;
 4d8:	00c50733          	add	a4,a0,a2
    src += n;
 4dc:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 4de:	fec05ae3          	blez	a2,4d2 <memmove+0x28>
 4e2:	fff6079b          	addiw	a5,a2,-1
 4e6:	1782                	slli	a5,a5,0x20
 4e8:	9381                	srli	a5,a5,0x20
 4ea:	fff7c793          	not	a5,a5
 4ee:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 4f0:	15fd                	addi	a1,a1,-1
 4f2:	177d                	addi	a4,a4,-1
 4f4:	0005c683          	lbu	a3,0(a1)
 4f8:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 4fc:	fee79ae3          	bne	a5,a4,4f0 <memmove+0x46>
 500:	bfc9                	j	4d2 <memmove+0x28>

0000000000000502 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 502:	1141                	addi	sp,sp,-16
 504:	e422                	sd	s0,8(sp)
 506:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 508:	ca05                	beqz	a2,538 <memcmp+0x36>
 50a:	fff6069b          	addiw	a3,a2,-1
 50e:	1682                	slli	a3,a3,0x20
 510:	9281                	srli	a3,a3,0x20
 512:	0685                	addi	a3,a3,1
 514:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 516:	00054783          	lbu	a5,0(a0)
 51a:	0005c703          	lbu	a4,0(a1)
 51e:	00e79863          	bne	a5,a4,52e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 522:	0505                	addi	a0,a0,1
    p2++;
 524:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 526:	fed518e3          	bne	a0,a3,516 <memcmp+0x14>
  }
  return 0;
 52a:	4501                	li	a0,0
 52c:	a019                	j	532 <memcmp+0x30>
      return *p1 - *p2;
 52e:	40e7853b          	subw	a0,a5,a4
}
 532:	6422                	ld	s0,8(sp)
 534:	0141                	addi	sp,sp,16
 536:	8082                	ret
  return 0;
 538:	4501                	li	a0,0
 53a:	bfe5                	j	532 <memcmp+0x30>

000000000000053c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 53c:	1141                	addi	sp,sp,-16
 53e:	e406                	sd	ra,8(sp)
 540:	e022                	sd	s0,0(sp)
 542:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 544:	00000097          	auipc	ra,0x0
 548:	f66080e7          	jalr	-154(ra) # 4aa <memmove>
}
 54c:	60a2                	ld	ra,8(sp)
 54e:	6402                	ld	s0,0(sp)
 550:	0141                	addi	sp,sp,16
 552:	8082                	ret

0000000000000554 <fork>:
# generated by usys.pl - do not edit
#include "kernel/include/sysnum.h"
.global fork
fork:
 li a7, SYS_fork
 554:	4885                	li	a7,1
 ecall
 556:	00000073          	ecall
 ret
 55a:	8082                	ret

000000000000055c <exit>:
.global exit
exit:
 li a7, SYS_exit
 55c:	4889                	li	a7,2
 ecall
 55e:	00000073          	ecall
 ret
 562:	8082                	ret

0000000000000564 <wait>:
.global wait
wait:
 li a7, SYS_wait
 564:	488d                	li	a7,3
 ecall
 566:	00000073          	ecall
 ret
 56a:	8082                	ret

000000000000056c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 56c:	4891                	li	a7,4
 ecall
 56e:	00000073          	ecall
 ret
 572:	8082                	ret

0000000000000574 <read>:
.global read
read:
 li a7, SYS_read
 574:	4895                	li	a7,5
 ecall
 576:	00000073          	ecall
 ret
 57a:	8082                	ret

000000000000057c <write>:
.global write
write:
 li a7, SYS_write
 57c:	48c1                	li	a7,16
 ecall
 57e:	00000073          	ecall
 ret
 582:	8082                	ret

0000000000000584 <close>:
.global close
close:
 li a7, SYS_close
 584:	48d5                	li	a7,21
 ecall
 586:	00000073          	ecall
 ret
 58a:	8082                	ret

000000000000058c <kill>:
.global kill
kill:
 li a7, SYS_kill
 58c:	4899                	li	a7,6
 ecall
 58e:	00000073          	ecall
 ret
 592:	8082                	ret

0000000000000594 <exec>:
.global exec
exec:
 li a7, SYS_exec
 594:	489d                	li	a7,7
 ecall
 596:	00000073          	ecall
 ret
 59a:	8082                	ret

000000000000059c <open>:
.global open
open:
 li a7, SYS_open
 59c:	48bd                	li	a7,15
 ecall
 59e:	00000073          	ecall
 ret
 5a2:	8082                	ret

00000000000005a4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 5a4:	48a1                	li	a7,8
 ecall
 5a6:	00000073          	ecall
 ret
 5aa:	8082                	ret

00000000000005ac <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 5ac:	48d1                	li	a7,20
 ecall
 5ae:	00000073          	ecall
 ret
 5b2:	8082                	ret

00000000000005b4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 5b4:	48a5                	li	a7,9
 ecall
 5b6:	00000073          	ecall
 ret
 5ba:	8082                	ret

00000000000005bc <dup>:
.global dup
dup:
 li a7, SYS_dup
 5bc:	48a9                	li	a7,10
 ecall
 5be:	00000073          	ecall
 ret
 5c2:	8082                	ret

00000000000005c4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 5c4:	48ad                	li	a7,11
 ecall
 5c6:	00000073          	ecall
 ret
 5ca:	8082                	ret

00000000000005cc <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 5cc:	48b1                	li	a7,12
 ecall
 5ce:	00000073          	ecall
 ret
 5d2:	8082                	ret

00000000000005d4 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 5d4:	48b5                	li	a7,13
 ecall
 5d6:	00000073          	ecall
 ret
 5da:	8082                	ret

00000000000005dc <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 5dc:	48b9                	li	a7,14
 ecall
 5de:	00000073          	ecall
 ret
 5e2:	8082                	ret

00000000000005e4 <test_proc>:
.global test_proc
test_proc:
 li a7, SYS_test_proc
 5e4:	48d9                	li	a7,22
 ecall
 5e6:	00000073          	ecall
 ret
 5ea:	8082                	ret

00000000000005ec <dev>:
.global dev
dev:
 li a7, SYS_dev
 5ec:	48dd                	li	a7,23
 ecall
 5ee:	00000073          	ecall
 ret
 5f2:	8082                	ret

00000000000005f4 <readdir>:
.global readdir
readdir:
 li a7, SYS_readdir
 5f4:	48e1                	li	a7,24
 ecall
 5f6:	00000073          	ecall
 ret
 5fa:	8082                	ret

00000000000005fc <getcwd>:
.global getcwd
getcwd:
 li a7, SYS_getcwd
 5fc:	48e5                	li	a7,25
 ecall
 5fe:	00000073          	ecall
 ret
 602:	8082                	ret

0000000000000604 <remove>:
.global remove
remove:
 li a7, SYS_remove
 604:	48c5                	li	a7,17
 ecall
 606:	00000073          	ecall
 ret
 60a:	8082                	ret

000000000000060c <trace>:
.global trace
trace:
 li a7, SYS_trace
 60c:	48c9                	li	a7,18
 ecall
 60e:	00000073          	ecall
 ret
 612:	8082                	ret

0000000000000614 <sysinfo>:
.global sysinfo
sysinfo:
 li a7, SYS_sysinfo
 614:	48cd                	li	a7,19
 ecall
 616:	00000073          	ecall
 ret
 61a:	8082                	ret

000000000000061c <rename>:
.global rename
rename:
 li a7, SYS_rename
 61c:	48e9                	li	a7,26
 ecall
 61e:	00000073          	ecall
 ret
 622:	8082                	ret

0000000000000624 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 624:	1101                	addi	sp,sp,-32
 626:	ec06                	sd	ra,24(sp)
 628:	e822                	sd	s0,16(sp)
 62a:	1000                	addi	s0,sp,32
 62c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 630:	4605                	li	a2,1
 632:	fef40593          	addi	a1,s0,-17
 636:	00000097          	auipc	ra,0x0
 63a:	f46080e7          	jalr	-186(ra) # 57c <write>
}
 63e:	60e2                	ld	ra,24(sp)
 640:	6442                	ld	s0,16(sp)
 642:	6105                	addi	sp,sp,32
 644:	8082                	ret

0000000000000646 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 646:	7139                	addi	sp,sp,-64
 648:	fc06                	sd	ra,56(sp)
 64a:	f822                	sd	s0,48(sp)
 64c:	f426                	sd	s1,40(sp)
 64e:	0080                	addi	s0,sp,64
 650:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 652:	c299                	beqz	a3,658 <printint+0x12>
 654:	0805cb63          	bltz	a1,6ea <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 658:	2581                	sext.w	a1,a1
  neg = 0;
 65a:	4881                	li	a7,0
 65c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 660:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 662:	2601                	sext.w	a2,a2
 664:	00000517          	auipc	a0,0x0
 668:	4dc50513          	addi	a0,a0,1244 # b40 <digits>
 66c:	883a                	mv	a6,a4
 66e:	2705                	addiw	a4,a4,1
 670:	02c5f7bb          	remuw	a5,a1,a2
 674:	1782                	slli	a5,a5,0x20
 676:	9381                	srli	a5,a5,0x20
 678:	97aa                	add	a5,a5,a0
 67a:	0007c783          	lbu	a5,0(a5)
 67e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 682:	0005879b          	sext.w	a5,a1
 686:	02c5d5bb          	divuw	a1,a1,a2
 68a:	0685                	addi	a3,a3,1
 68c:	fec7f0e3          	bgeu	a5,a2,66c <printint+0x26>
  if(neg)
 690:	00088c63          	beqz	a7,6a8 <printint+0x62>
    buf[i++] = '-';
 694:	fd070793          	addi	a5,a4,-48
 698:	00878733          	add	a4,a5,s0
 69c:	02d00793          	li	a5,45
 6a0:	fef70823          	sb	a5,-16(a4)
 6a4:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 6a8:	02e05c63          	blez	a4,6e0 <printint+0x9a>
 6ac:	f04a                	sd	s2,32(sp)
 6ae:	ec4e                	sd	s3,24(sp)
 6b0:	fc040793          	addi	a5,s0,-64
 6b4:	00e78933          	add	s2,a5,a4
 6b8:	fff78993          	addi	s3,a5,-1
 6bc:	99ba                	add	s3,s3,a4
 6be:	377d                	addiw	a4,a4,-1
 6c0:	1702                	slli	a4,a4,0x20
 6c2:	9301                	srli	a4,a4,0x20
 6c4:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 6c8:	fff94583          	lbu	a1,-1(s2)
 6cc:	8526                	mv	a0,s1
 6ce:	00000097          	auipc	ra,0x0
 6d2:	f56080e7          	jalr	-170(ra) # 624 <putc>
  while(--i >= 0)
 6d6:	197d                	addi	s2,s2,-1
 6d8:	ff3918e3          	bne	s2,s3,6c8 <printint+0x82>
 6dc:	7902                	ld	s2,32(sp)
 6de:	69e2                	ld	s3,24(sp)
}
 6e0:	70e2                	ld	ra,56(sp)
 6e2:	7442                	ld	s0,48(sp)
 6e4:	74a2                	ld	s1,40(sp)
 6e6:	6121                	addi	sp,sp,64
 6e8:	8082                	ret
    x = -xx;
 6ea:	40b005bb          	negw	a1,a1
    neg = 1;
 6ee:	4885                	li	a7,1
    x = -xx;
 6f0:	b7b5                	j	65c <printint+0x16>

00000000000006f2 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 6f2:	715d                	addi	sp,sp,-80
 6f4:	e486                	sd	ra,72(sp)
 6f6:	e0a2                	sd	s0,64(sp)
 6f8:	f84a                	sd	s2,48(sp)
 6fa:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 6fc:	0005c903          	lbu	s2,0(a1)
 700:	1a090a63          	beqz	s2,8b4 <vprintf+0x1c2>
 704:	fc26                	sd	s1,56(sp)
 706:	f44e                	sd	s3,40(sp)
 708:	f052                	sd	s4,32(sp)
 70a:	ec56                	sd	s5,24(sp)
 70c:	e85a                	sd	s6,16(sp)
 70e:	e45e                	sd	s7,8(sp)
 710:	8aaa                	mv	s5,a0
 712:	8bb2                	mv	s7,a2
 714:	00158493          	addi	s1,a1,1
  state = 0;
 718:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 71a:	02500a13          	li	s4,37
 71e:	4b55                	li	s6,21
 720:	a839                	j	73e <vprintf+0x4c>
        putc(fd, c);
 722:	85ca                	mv	a1,s2
 724:	8556                	mv	a0,s5
 726:	00000097          	auipc	ra,0x0
 72a:	efe080e7          	jalr	-258(ra) # 624 <putc>
 72e:	a019                	j	734 <vprintf+0x42>
    } else if(state == '%'){
 730:	01498d63          	beq	s3,s4,74a <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 734:	0485                	addi	s1,s1,1
 736:	fff4c903          	lbu	s2,-1(s1)
 73a:	16090763          	beqz	s2,8a8 <vprintf+0x1b6>
    if(state == 0){
 73e:	fe0999e3          	bnez	s3,730 <vprintf+0x3e>
      if(c == '%'){
 742:	ff4910e3          	bne	s2,s4,722 <vprintf+0x30>
        state = '%';
 746:	89d2                	mv	s3,s4
 748:	b7f5                	j	734 <vprintf+0x42>
      if(c == 'd'){
 74a:	13490463          	beq	s2,s4,872 <vprintf+0x180>
 74e:	f9d9079b          	addiw	a5,s2,-99
 752:	0ff7f793          	zext.b	a5,a5
 756:	12fb6763          	bltu	s6,a5,884 <vprintf+0x192>
 75a:	f9d9079b          	addiw	a5,s2,-99
 75e:	0ff7f713          	zext.b	a4,a5
 762:	12eb6163          	bltu	s6,a4,884 <vprintf+0x192>
 766:	00271793          	slli	a5,a4,0x2
 76a:	00000717          	auipc	a4,0x0
 76e:	37e70713          	addi	a4,a4,894 # ae8 <malloc+0x144>
 772:	97ba                	add	a5,a5,a4
 774:	439c                	lw	a5,0(a5)
 776:	97ba                	add	a5,a5,a4
 778:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 77a:	008b8913          	addi	s2,s7,8
 77e:	4685                	li	a3,1
 780:	4629                	li	a2,10
 782:	000ba583          	lw	a1,0(s7)
 786:	8556                	mv	a0,s5
 788:	00000097          	auipc	ra,0x0
 78c:	ebe080e7          	jalr	-322(ra) # 646 <printint>
 790:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 792:	4981                	li	s3,0
 794:	b745                	j	734 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 796:	008b8913          	addi	s2,s7,8
 79a:	4681                	li	a3,0
 79c:	4629                	li	a2,10
 79e:	000ba583          	lw	a1,0(s7)
 7a2:	8556                	mv	a0,s5
 7a4:	00000097          	auipc	ra,0x0
 7a8:	ea2080e7          	jalr	-350(ra) # 646 <printint>
 7ac:	8bca                	mv	s7,s2
      state = 0;
 7ae:	4981                	li	s3,0
 7b0:	b751                	j	734 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 7b2:	008b8913          	addi	s2,s7,8
 7b6:	4681                	li	a3,0
 7b8:	4641                	li	a2,16
 7ba:	000ba583          	lw	a1,0(s7)
 7be:	8556                	mv	a0,s5
 7c0:	00000097          	auipc	ra,0x0
 7c4:	e86080e7          	jalr	-378(ra) # 646 <printint>
 7c8:	8bca                	mv	s7,s2
      state = 0;
 7ca:	4981                	li	s3,0
 7cc:	b7a5                	j	734 <vprintf+0x42>
 7ce:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 7d0:	008b8c13          	addi	s8,s7,8
 7d4:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 7d8:	03000593          	li	a1,48
 7dc:	8556                	mv	a0,s5
 7de:	00000097          	auipc	ra,0x0
 7e2:	e46080e7          	jalr	-442(ra) # 624 <putc>
  putc(fd, 'x');
 7e6:	07800593          	li	a1,120
 7ea:	8556                	mv	a0,s5
 7ec:	00000097          	auipc	ra,0x0
 7f0:	e38080e7          	jalr	-456(ra) # 624 <putc>
 7f4:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7f6:	00000b97          	auipc	s7,0x0
 7fa:	34ab8b93          	addi	s7,s7,842 # b40 <digits>
 7fe:	03c9d793          	srli	a5,s3,0x3c
 802:	97de                	add	a5,a5,s7
 804:	0007c583          	lbu	a1,0(a5)
 808:	8556                	mv	a0,s5
 80a:	00000097          	auipc	ra,0x0
 80e:	e1a080e7          	jalr	-486(ra) # 624 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 812:	0992                	slli	s3,s3,0x4
 814:	397d                	addiw	s2,s2,-1
 816:	fe0914e3          	bnez	s2,7fe <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 81a:	8be2                	mv	s7,s8
      state = 0;
 81c:	4981                	li	s3,0
 81e:	6c02                	ld	s8,0(sp)
 820:	bf11                	j	734 <vprintf+0x42>
        s = va_arg(ap, char*);
 822:	008b8993          	addi	s3,s7,8
 826:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 82a:	02090163          	beqz	s2,84c <vprintf+0x15a>
        while(*s != 0){
 82e:	00094583          	lbu	a1,0(s2)
 832:	c9a5                	beqz	a1,8a2 <vprintf+0x1b0>
          putc(fd, *s);
 834:	8556                	mv	a0,s5
 836:	00000097          	auipc	ra,0x0
 83a:	dee080e7          	jalr	-530(ra) # 624 <putc>
          s++;
 83e:	0905                	addi	s2,s2,1
        while(*s != 0){
 840:	00094583          	lbu	a1,0(s2)
 844:	f9e5                	bnez	a1,834 <vprintf+0x142>
        s = va_arg(ap, char*);
 846:	8bce                	mv	s7,s3
      state = 0;
 848:	4981                	li	s3,0
 84a:	b5ed                	j	734 <vprintf+0x42>
          s = "(null)";
 84c:	00000917          	auipc	s2,0x0
 850:	29490913          	addi	s2,s2,660 # ae0 <malloc+0x13c>
        while(*s != 0){
 854:	02800593          	li	a1,40
 858:	bff1                	j	834 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 85a:	008b8913          	addi	s2,s7,8
 85e:	000bc583          	lbu	a1,0(s7)
 862:	8556                	mv	a0,s5
 864:	00000097          	auipc	ra,0x0
 868:	dc0080e7          	jalr	-576(ra) # 624 <putc>
 86c:	8bca                	mv	s7,s2
      state = 0;
 86e:	4981                	li	s3,0
 870:	b5d1                	j	734 <vprintf+0x42>
        putc(fd, c);
 872:	02500593          	li	a1,37
 876:	8556                	mv	a0,s5
 878:	00000097          	auipc	ra,0x0
 87c:	dac080e7          	jalr	-596(ra) # 624 <putc>
      state = 0;
 880:	4981                	li	s3,0
 882:	bd4d                	j	734 <vprintf+0x42>
        putc(fd, '%');
 884:	02500593          	li	a1,37
 888:	8556                	mv	a0,s5
 88a:	00000097          	auipc	ra,0x0
 88e:	d9a080e7          	jalr	-614(ra) # 624 <putc>
        putc(fd, c);
 892:	85ca                	mv	a1,s2
 894:	8556                	mv	a0,s5
 896:	00000097          	auipc	ra,0x0
 89a:	d8e080e7          	jalr	-626(ra) # 624 <putc>
      state = 0;
 89e:	4981                	li	s3,0
 8a0:	bd51                	j	734 <vprintf+0x42>
        s = va_arg(ap, char*);
 8a2:	8bce                	mv	s7,s3
      state = 0;
 8a4:	4981                	li	s3,0
 8a6:	b579                	j	734 <vprintf+0x42>
 8a8:	74e2                	ld	s1,56(sp)
 8aa:	79a2                	ld	s3,40(sp)
 8ac:	7a02                	ld	s4,32(sp)
 8ae:	6ae2                	ld	s5,24(sp)
 8b0:	6b42                	ld	s6,16(sp)
 8b2:	6ba2                	ld	s7,8(sp)
    }
  }
}
 8b4:	60a6                	ld	ra,72(sp)
 8b6:	6406                	ld	s0,64(sp)
 8b8:	7942                	ld	s2,48(sp)
 8ba:	6161                	addi	sp,sp,80
 8bc:	8082                	ret

00000000000008be <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8be:	715d                	addi	sp,sp,-80
 8c0:	ec06                	sd	ra,24(sp)
 8c2:	e822                	sd	s0,16(sp)
 8c4:	1000                	addi	s0,sp,32
 8c6:	e010                	sd	a2,0(s0)
 8c8:	e414                	sd	a3,8(s0)
 8ca:	e818                	sd	a4,16(s0)
 8cc:	ec1c                	sd	a5,24(s0)
 8ce:	03043023          	sd	a6,32(s0)
 8d2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8d6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8da:	8622                	mv	a2,s0
 8dc:	00000097          	auipc	ra,0x0
 8e0:	e16080e7          	jalr	-490(ra) # 6f2 <vprintf>
}
 8e4:	60e2                	ld	ra,24(sp)
 8e6:	6442                	ld	s0,16(sp)
 8e8:	6161                	addi	sp,sp,80
 8ea:	8082                	ret

00000000000008ec <printf>:

void
printf(const char *fmt, ...)
{
 8ec:	711d                	addi	sp,sp,-96
 8ee:	ec06                	sd	ra,24(sp)
 8f0:	e822                	sd	s0,16(sp)
 8f2:	1000                	addi	s0,sp,32
 8f4:	e40c                	sd	a1,8(s0)
 8f6:	e810                	sd	a2,16(s0)
 8f8:	ec14                	sd	a3,24(s0)
 8fa:	f018                	sd	a4,32(s0)
 8fc:	f41c                	sd	a5,40(s0)
 8fe:	03043823          	sd	a6,48(s0)
 902:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 906:	00840613          	addi	a2,s0,8
 90a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 90e:	85aa                	mv	a1,a0
 910:	4505                	li	a0,1
 912:	00000097          	auipc	ra,0x0
 916:	de0080e7          	jalr	-544(ra) # 6f2 <vprintf>
}
 91a:	60e2                	ld	ra,24(sp)
 91c:	6442                	ld	s0,16(sp)
 91e:	6125                	addi	sp,sp,96
 920:	8082                	ret

0000000000000922 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 922:	1141                	addi	sp,sp,-16
 924:	e422                	sd	s0,8(sp)
 926:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 928:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 92c:	00000797          	auipc	a5,0x0
 930:	22c7b783          	ld	a5,556(a5) # b58 <freep>
 934:	a02d                	j	95e <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 936:	4618                	lw	a4,8(a2)
 938:	9f2d                	addw	a4,a4,a1
 93a:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 93e:	6398                	ld	a4,0(a5)
 940:	6310                	ld	a2,0(a4)
 942:	a83d                	j	980 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 944:	ff852703          	lw	a4,-8(a0)
 948:	9f31                	addw	a4,a4,a2
 94a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 94c:	ff053683          	ld	a3,-16(a0)
 950:	a091                	j	994 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 952:	6398                	ld	a4,0(a5)
 954:	00e7e463          	bltu	a5,a4,95c <free+0x3a>
 958:	00e6ea63          	bltu	a3,a4,96c <free+0x4a>
{
 95c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 95e:	fed7fae3          	bgeu	a5,a3,952 <free+0x30>
 962:	6398                	ld	a4,0(a5)
 964:	00e6e463          	bltu	a3,a4,96c <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 968:	fee7eae3          	bltu	a5,a4,95c <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 96c:	ff852583          	lw	a1,-8(a0)
 970:	6390                	ld	a2,0(a5)
 972:	02059813          	slli	a6,a1,0x20
 976:	01c85713          	srli	a4,a6,0x1c
 97a:	9736                	add	a4,a4,a3
 97c:	fae60de3          	beq	a2,a4,936 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 980:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 984:	4790                	lw	a2,8(a5)
 986:	02061593          	slli	a1,a2,0x20
 98a:	01c5d713          	srli	a4,a1,0x1c
 98e:	973e                	add	a4,a4,a5
 990:	fae68ae3          	beq	a3,a4,944 <free+0x22>
    p->s.ptr = bp->s.ptr;
 994:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 996:	00000717          	auipc	a4,0x0
 99a:	1cf73123          	sd	a5,450(a4) # b58 <freep>
}
 99e:	6422                	ld	s0,8(sp)
 9a0:	0141                	addi	sp,sp,16
 9a2:	8082                	ret

00000000000009a4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9a4:	7139                	addi	sp,sp,-64
 9a6:	fc06                	sd	ra,56(sp)
 9a8:	f822                	sd	s0,48(sp)
 9aa:	f426                	sd	s1,40(sp)
 9ac:	ec4e                	sd	s3,24(sp)
 9ae:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9b0:	02051493          	slli	s1,a0,0x20
 9b4:	9081                	srli	s1,s1,0x20
 9b6:	04bd                	addi	s1,s1,15
 9b8:	8091                	srli	s1,s1,0x4
 9ba:	0014899b          	addiw	s3,s1,1
 9be:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 9c0:	00000517          	auipc	a0,0x0
 9c4:	19853503          	ld	a0,408(a0) # b58 <freep>
 9c8:	c915                	beqz	a0,9fc <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9ca:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9cc:	4798                	lw	a4,8(a5)
 9ce:	08977e63          	bgeu	a4,s1,a6a <malloc+0xc6>
 9d2:	f04a                	sd	s2,32(sp)
 9d4:	e852                	sd	s4,16(sp)
 9d6:	e456                	sd	s5,8(sp)
 9d8:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 9da:	8a4e                	mv	s4,s3
 9dc:	0009871b          	sext.w	a4,s3
 9e0:	6685                	lui	a3,0x1
 9e2:	00d77363          	bgeu	a4,a3,9e8 <malloc+0x44>
 9e6:	6a05                	lui	s4,0x1
 9e8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9ec:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 9f0:	00000917          	auipc	s2,0x0
 9f4:	16890913          	addi	s2,s2,360 # b58 <freep>
  if(p == (char*)-1)
 9f8:	5afd                	li	s5,-1
 9fa:	a091                	j	a3e <malloc+0x9a>
 9fc:	f04a                	sd	s2,32(sp)
 9fe:	e852                	sd	s4,16(sp)
 a00:	e456                	sd	s5,8(sp)
 a02:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 a04:	00000797          	auipc	a5,0x0
 a08:	55c78793          	addi	a5,a5,1372 # f60 <base>
 a0c:	00000717          	auipc	a4,0x0
 a10:	14f73623          	sd	a5,332(a4) # b58 <freep>
 a14:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a16:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a1a:	b7c1                	j	9da <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 a1c:	6398                	ld	a4,0(a5)
 a1e:	e118                	sd	a4,0(a0)
 a20:	a08d                	j	a82 <malloc+0xde>
  hp->s.size = nu;
 a22:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a26:	0541                	addi	a0,a0,16
 a28:	00000097          	auipc	ra,0x0
 a2c:	efa080e7          	jalr	-262(ra) # 922 <free>
  return freep;
 a30:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a34:	c13d                	beqz	a0,a9a <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a36:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a38:	4798                	lw	a4,8(a5)
 a3a:	02977463          	bgeu	a4,s1,a62 <malloc+0xbe>
    if(p == freep)
 a3e:	00093703          	ld	a4,0(s2)
 a42:	853e                	mv	a0,a5
 a44:	fef719e3          	bne	a4,a5,a36 <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 a48:	8552                	mv	a0,s4
 a4a:	00000097          	auipc	ra,0x0
 a4e:	b82080e7          	jalr	-1150(ra) # 5cc <sbrk>
  if(p == (char*)-1)
 a52:	fd5518e3          	bne	a0,s5,a22 <malloc+0x7e>
        return 0;
 a56:	4501                	li	a0,0
 a58:	7902                	ld	s2,32(sp)
 a5a:	6a42                	ld	s4,16(sp)
 a5c:	6aa2                	ld	s5,8(sp)
 a5e:	6b02                	ld	s6,0(sp)
 a60:	a03d                	j	a8e <malloc+0xea>
 a62:	7902                	ld	s2,32(sp)
 a64:	6a42                	ld	s4,16(sp)
 a66:	6aa2                	ld	s5,8(sp)
 a68:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 a6a:	fae489e3          	beq	s1,a4,a1c <malloc+0x78>
        p->s.size -= nunits;
 a6e:	4137073b          	subw	a4,a4,s3
 a72:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a74:	02071693          	slli	a3,a4,0x20
 a78:	01c6d713          	srli	a4,a3,0x1c
 a7c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a7e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a82:	00000717          	auipc	a4,0x0
 a86:	0ca73b23          	sd	a0,214(a4) # b58 <freep>
      return (void*)(p + 1);
 a8a:	01078513          	addi	a0,a5,16
  }
}
 a8e:	70e2                	ld	ra,56(sp)
 a90:	7442                	ld	s0,48(sp)
 a92:	74a2                	ld	s1,40(sp)
 a94:	69e2                	ld	s3,24(sp)
 a96:	6121                	addi	sp,sp,64
 a98:	8082                	ret
 a9a:	7902                	ld	s2,32(sp)
 a9c:	6a42                	ld	s4,16(sp)
 a9e:	6aa2                	ld	s5,8(sp)
 aa0:	6b02                	ld	s6,0(sp)
 aa2:	b7f5                	j	a8e <malloc+0xea>
