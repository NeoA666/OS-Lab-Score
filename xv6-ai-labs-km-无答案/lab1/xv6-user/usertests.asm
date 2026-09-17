
xv6-user/_usertests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <copyinstr1>:
}

// what if you pass ridiculous string pointers to system calls?
void
copyinstr1(char *s)
{
       0:	1141                	addi	sp,sp,-16
       2:	e406                	sd	ra,8(sp)
       4:	e022                	sd	s0,0(sp)
       6:	0800                	addi	s0,sp,16
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };

  for(int ai = 0; ai < 2; ai++){
    uint64 addr = addrs[ai];

    int fd = open((char *)addr, O_CREATE|O_WRONLY);
       8:	20100593          	li	a1,513
       c:	4505                	li	a0,1
       e:	057e                	slli	a0,a0,0x1f
      10:	00005097          	auipc	ra,0x5
      14:	94e080e7          	jalr	-1714(ra) # 495e <open>
    if(fd >= 0){
      18:	02055063          	bgez	a0,38 <copyinstr1+0x38>
    int fd = open((char *)addr, O_CREATE|O_WRONLY);
      1c:	20100593          	li	a1,513
      20:	557d                	li	a0,-1
      22:	00005097          	auipc	ra,0x5
      26:	93c080e7          	jalr	-1732(ra) # 495e <open>
    if(fd >= 0){
      2a:	55fd                	li	a1,-1
      2c:	00055863          	bgez	a0,3c <copyinstr1+0x3c>
      printf("open(%p) returned %d, not -1\n", addr, fd);
      exit(1);
    }
  }
}
      30:	60a2                	ld	ra,8(sp)
      32:	6402                	ld	s0,0(sp)
      34:	0141                	addi	sp,sp,16
      36:	8082                	ret
    uint64 addr = addrs[ai];
      38:	4585                	li	a1,1
      3a:	05fe                	slli	a1,a1,0x1f
      printf("open(%p) returned %d, not -1\n", addr, fd);
      3c:	862a                	mv	a2,a0
      3e:	00005517          	auipc	a0,0x5
      42:	e2a50513          	addi	a0,a0,-470 # 4e68 <malloc+0x102>
      46:	00005097          	auipc	ra,0x5
      4a:	c68080e7          	jalr	-920(ra) # 4cae <printf>
      exit(1);
      4e:	4505                	li	a0,1
      50:	00005097          	auipc	ra,0x5
      54:	8ce080e7          	jalr	-1842(ra) # 491e <exit>

0000000000000058 <validatetest>:
  } 
}

void
validatetest(char *s)
{
      58:	7139                	addi	sp,sp,-64
      5a:	fc06                	sd	ra,56(sp)
      5c:	f822                	sd	s0,48(sp)
      5e:	f426                	sd	s1,40(sp)
      60:	f04a                	sd	s2,32(sp)
      62:	ec4e                	sd	s3,24(sp)
      64:	e852                	sd	s4,16(sp)
      66:	e456                	sd	s5,8(sp)
      68:	0080                	addi	s0,sp,64
      6a:	8aaa                	mv	s5,a0
  int hi;
  uint64 p;

  hi = 1100*1024;
  for(p = 0; p <= (uint)hi; p += PGSIZE){
      6c:	4481                	li	s1,0
    // try to crash the kernel by passing in a bad string pointer
    if(open((char*)p, O_RDONLY) != -1){
      6e:	597d                	li	s2,-1
  for(p = 0; p <= (uint)hi; p += PGSIZE){
      70:	6a05                	lui	s4,0x1
      72:	001149b7          	lui	s3,0x114
    if(open((char*)p, O_RDONLY) != -1){
      76:	4581                	li	a1,0
      78:	8526                	mv	a0,s1
      7a:	00005097          	auipc	ra,0x5
      7e:	8e4080e7          	jalr	-1820(ra) # 495e <open>
      82:	01251e63          	bne	a0,s2,9e <validatetest+0x46>
  for(p = 0; p <= (uint)hi; p += PGSIZE){
      86:	94d2                	add	s1,s1,s4
      88:	ff3497e3          	bne	s1,s3,76 <validatetest+0x1e>
      printf("%s: link should not succeed\n", s);
      printf("bad string:[%s]\n", (char*)p);
      exit(1);
    }
  }
}
      8c:	70e2                	ld	ra,56(sp)
      8e:	7442                	ld	s0,48(sp)
      90:	74a2                	ld	s1,40(sp)
      92:	7902                	ld	s2,32(sp)
      94:	69e2                	ld	s3,24(sp)
      96:	6a42                	ld	s4,16(sp)
      98:	6aa2                	ld	s5,8(sp)
      9a:	6121                	addi	sp,sp,64
      9c:	8082                	ret
      printf("%s: link should not succeed\n", s);
      9e:	85d6                	mv	a1,s5
      a0:	00005517          	auipc	a0,0x5
      a4:	de850513          	addi	a0,a0,-536 # 4e88 <malloc+0x122>
      a8:	00005097          	auipc	ra,0x5
      ac:	c06080e7          	jalr	-1018(ra) # 4cae <printf>
      printf("bad string:[%s]\n", (char*)p);
      b0:	85a6                	mv	a1,s1
      b2:	00005517          	auipc	a0,0x5
      b6:	df650513          	addi	a0,a0,-522 # 4ea8 <malloc+0x142>
      ba:	00005097          	auipc	ra,0x5
      be:	bf4080e7          	jalr	-1036(ra) # 4cae <printf>
      exit(1);
      c2:	4505                	li	a0,1
      c4:	00005097          	auipc	ra,0x5
      c8:	85a080e7          	jalr	-1958(ra) # 491e <exit>

00000000000000cc <bsstest>:
void
bsstest(char *s)
{
  int i;

  for(i = 0; i < sizeof(uninit); i++){
      cc:	00008797          	auipc	a5,0x8
      d0:	0b478793          	addi	a5,a5,180 # 8180 <uninit>
      d4:	0000a697          	auipc	a3,0xa
      d8:	7bc68693          	addi	a3,a3,1980 # a890 <buf>
    if(uninit[i] != '\0'){
      dc:	0007c703          	lbu	a4,0(a5)
      e0:	e709                	bnez	a4,ea <bsstest+0x1e>
  for(i = 0; i < sizeof(uninit); i++){
      e2:	0785                	addi	a5,a5,1
      e4:	fed79ce3          	bne	a5,a3,dc <bsstest+0x10>
      e8:	8082                	ret
{
      ea:	1141                	addi	sp,sp,-16
      ec:	e406                	sd	ra,8(sp)
      ee:	e022                	sd	s0,0(sp)
      f0:	0800                	addi	s0,sp,16
      printf("%s: bss test failed\n", s);
      f2:	85aa                	mv	a1,a0
      f4:	00005517          	auipc	a0,0x5
      f8:	dcc50513          	addi	a0,a0,-564 # 4ec0 <malloc+0x15a>
      fc:	00005097          	auipc	ra,0x5
     100:	bb2080e7          	jalr	-1102(ra) # 4cae <printf>
      exit(1);
     104:	4505                	li	a0,1
     106:	00005097          	auipc	ra,0x5
     10a:	818080e7          	jalr	-2024(ra) # 491e <exit>

000000000000010e <opentest>:
{
     10e:	1101                	addi	sp,sp,-32
     110:	ec06                	sd	ra,24(sp)
     112:	e822                	sd	s0,16(sp)
     114:	e426                	sd	s1,8(sp)
     116:	1000                	addi	s0,sp,32
     118:	84aa                	mv	s1,a0
  fd = open("echo", 0);
     11a:	4581                	li	a1,0
     11c:	00005517          	auipc	a0,0x5
     120:	dbc50513          	addi	a0,a0,-580 # 4ed8 <malloc+0x172>
     124:	00005097          	auipc	ra,0x5
     128:	83a080e7          	jalr	-1990(ra) # 495e <open>
  if(fd < 0){
     12c:	02054663          	bltz	a0,158 <opentest+0x4a>
  close(fd);
     130:	00005097          	auipc	ra,0x5
     134:	816080e7          	jalr	-2026(ra) # 4946 <close>
  fd = open("doesnotexist", 0);
     138:	4581                	li	a1,0
     13a:	00005517          	auipc	a0,0x5
     13e:	dbe50513          	addi	a0,a0,-578 # 4ef8 <malloc+0x192>
     142:	00005097          	auipc	ra,0x5
     146:	81c080e7          	jalr	-2020(ra) # 495e <open>
  if(fd >= 0){
     14a:	02055563          	bgez	a0,174 <opentest+0x66>
}
     14e:	60e2                	ld	ra,24(sp)
     150:	6442                	ld	s0,16(sp)
     152:	64a2                	ld	s1,8(sp)
     154:	6105                	addi	sp,sp,32
     156:	8082                	ret
    printf("%s: open echo failed!\n", s);
     158:	85a6                	mv	a1,s1
     15a:	00005517          	auipc	a0,0x5
     15e:	d8650513          	addi	a0,a0,-634 # 4ee0 <malloc+0x17a>
     162:	00005097          	auipc	ra,0x5
     166:	b4c080e7          	jalr	-1204(ra) # 4cae <printf>
    exit(1);
     16a:	4505                	li	a0,1
     16c:	00004097          	auipc	ra,0x4
     170:	7b2080e7          	jalr	1970(ra) # 491e <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     174:	85a6                	mv	a1,s1
     176:	00005517          	auipc	a0,0x5
     17a:	d9250513          	addi	a0,a0,-622 # 4f08 <malloc+0x1a2>
     17e:	00005097          	auipc	ra,0x5
     182:	b30080e7          	jalr	-1232(ra) # 4cae <printf>
    exit(1);
     186:	4505                	li	a0,1
     188:	00004097          	auipc	ra,0x4
     18c:	796080e7          	jalr	1942(ra) # 491e <exit>

0000000000000190 <truncate2>:
{
     190:	7179                	addi	sp,sp,-48
     192:	f406                	sd	ra,40(sp)
     194:	f022                	sd	s0,32(sp)
     196:	ec26                	sd	s1,24(sp)
     198:	e84a                	sd	s2,16(sp)
     19a:	e44e                	sd	s3,8(sp)
     19c:	1800                	addi	s0,sp,48
     19e:	89aa                	mv	s3,a0
  remove("truncfile");
     1a0:	00005517          	auipc	a0,0x5
     1a4:	d9050513          	addi	a0,a0,-624 # 4f30 <malloc+0x1ca>
     1a8:	00005097          	auipc	ra,0x5
     1ac:	81e080e7          	jalr	-2018(ra) # 49c6 <remove>
  int fd1 = open("truncfile", O_CREATE|O_TRUNC|O_WRONLY);
     1b0:	60100593          	li	a1,1537
     1b4:	00005517          	auipc	a0,0x5
     1b8:	d7c50513          	addi	a0,a0,-644 # 4f30 <malloc+0x1ca>
     1bc:	00004097          	auipc	ra,0x4
     1c0:	7a2080e7          	jalr	1954(ra) # 495e <open>
     1c4:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     1c6:	4611                	li	a2,4
     1c8:	00005597          	auipc	a1,0x5
     1cc:	d7858593          	addi	a1,a1,-648 # 4f40 <malloc+0x1da>
     1d0:	00004097          	auipc	ra,0x4
     1d4:	76e080e7          	jalr	1902(ra) # 493e <write>
  int fd2 = open("truncfile", O_TRUNC|O_WRONLY);
     1d8:	40100593          	li	a1,1025
     1dc:	00005517          	auipc	a0,0x5
     1e0:	d5450513          	addi	a0,a0,-684 # 4f30 <malloc+0x1ca>
     1e4:	00004097          	auipc	ra,0x4
     1e8:	77a080e7          	jalr	1914(ra) # 495e <open>
     1ec:	892a                	mv	s2,a0
  int n = write(fd1, "x", 1);
     1ee:	4605                	li	a2,1
     1f0:	00005597          	auipc	a1,0x5
     1f4:	d5858593          	addi	a1,a1,-680 # 4f48 <malloc+0x1e2>
     1f8:	8526                	mv	a0,s1
     1fa:	00004097          	auipc	ra,0x4
     1fe:	744080e7          	jalr	1860(ra) # 493e <write>
  if(n != -1){
     202:	57fd                	li	a5,-1
     204:	02f51b63          	bne	a0,a5,23a <truncate2+0xaa>
  remove("truncfile");
     208:	00005517          	auipc	a0,0x5
     20c:	d2850513          	addi	a0,a0,-728 # 4f30 <malloc+0x1ca>
     210:	00004097          	auipc	ra,0x4
     214:	7b6080e7          	jalr	1974(ra) # 49c6 <remove>
  close(fd1);
     218:	8526                	mv	a0,s1
     21a:	00004097          	auipc	ra,0x4
     21e:	72c080e7          	jalr	1836(ra) # 4946 <close>
  close(fd2);
     222:	854a                	mv	a0,s2
     224:	00004097          	auipc	ra,0x4
     228:	722080e7          	jalr	1826(ra) # 4946 <close>
}
     22c:	70a2                	ld	ra,40(sp)
     22e:	7402                	ld	s0,32(sp)
     230:	64e2                	ld	s1,24(sp)
     232:	6942                	ld	s2,16(sp)
     234:	69a2                	ld	s3,8(sp)
     236:	6145                	addi	sp,sp,48
     238:	8082                	ret
    printf("%s: write returned %d, expected -1\n", s, n);
     23a:	862a                	mv	a2,a0
     23c:	85ce                	mv	a1,s3
     23e:	00005517          	auipc	a0,0x5
     242:	d1250513          	addi	a0,a0,-750 # 4f50 <malloc+0x1ea>
     246:	00005097          	auipc	ra,0x5
     24a:	a68080e7          	jalr	-1432(ra) # 4cae <printf>
    exit(1);
     24e:	4505                	li	a0,1
     250:	00004097          	auipc	ra,0x4
     254:	6ce080e7          	jalr	1742(ra) # 491e <exit>

0000000000000258 <createtest>:
{
     258:	7179                	addi	sp,sp,-48
     25a:	f406                	sd	ra,40(sp)
     25c:	f022                	sd	s0,32(sp)
     25e:	ec26                	sd	s1,24(sp)
     260:	e84a                	sd	s2,16(sp)
     262:	e44e                	sd	s3,8(sp)
     264:	1800                	addi	s0,sp,48
  name[0] = 'a';
     266:	00007797          	auipc	a5,0x7
     26a:	e0278793          	addi	a5,a5,-510 # 7068 <name>
     26e:	06100713          	li	a4,97
     272:	00e78023          	sb	a4,0(a5)
  name[2] = '\0';
     276:	00078123          	sb	zero,2(a5)
     27a:	03000493          	li	s1,48
    name[1] = '0' + i;
     27e:	893e                	mv	s2,a5
  for(i = 0; i < N; i++){
     280:	06400993          	li	s3,100
    name[1] = '0' + i;
     284:	009900a3          	sb	s1,1(s2)
    fd = open(name, O_CREATE|O_RDWR);
     288:	20200593          	li	a1,514
     28c:	854a                	mv	a0,s2
     28e:	00004097          	auipc	ra,0x4
     292:	6d0080e7          	jalr	1744(ra) # 495e <open>
    close(fd);
     296:	00004097          	auipc	ra,0x4
     29a:	6b0080e7          	jalr	1712(ra) # 4946 <close>
  for(i = 0; i < N; i++){
     29e:	2485                	addiw	s1,s1,1
     2a0:	0ff4f493          	zext.b	s1,s1
     2a4:	ff3490e3          	bne	s1,s3,284 <createtest+0x2c>
  name[0] = 'a';
     2a8:	00007797          	auipc	a5,0x7
     2ac:	dc078793          	addi	a5,a5,-576 # 7068 <name>
     2b0:	06100713          	li	a4,97
     2b4:	00e78023          	sb	a4,0(a5)
  name[2] = '\0';
     2b8:	00078123          	sb	zero,2(a5)
     2bc:	03000493          	li	s1,48
    name[1] = '0' + i;
     2c0:	893e                	mv	s2,a5
  for(i = 0; i < N; i++){
     2c2:	06400993          	li	s3,100
    name[1] = '0' + i;
     2c6:	009900a3          	sb	s1,1(s2)
    remove(name);
     2ca:	854a                	mv	a0,s2
     2cc:	00004097          	auipc	ra,0x4
     2d0:	6fa080e7          	jalr	1786(ra) # 49c6 <remove>
  for(i = 0; i < N; i++){
     2d4:	2485                	addiw	s1,s1,1
     2d6:	0ff4f493          	zext.b	s1,s1
     2da:	ff3496e3          	bne	s1,s3,2c6 <createtest+0x6e>
}
     2de:	70a2                	ld	ra,40(sp)
     2e0:	7402                	ld	s0,32(sp)
     2e2:	64e2                	ld	s1,24(sp)
     2e4:	6942                	ld	s2,16(sp)
     2e6:	69a2                	ld	s3,8(sp)
     2e8:	6145                	addi	sp,sp,48
     2ea:	8082                	ret

00000000000002ec <bigwrite>:
{
     2ec:	715d                	addi	sp,sp,-80
     2ee:	e486                	sd	ra,72(sp)
     2f0:	e0a2                	sd	s0,64(sp)
     2f2:	fc26                	sd	s1,56(sp)
     2f4:	f84a                	sd	s2,48(sp)
     2f6:	f44e                	sd	s3,40(sp)
     2f8:	f052                	sd	s4,32(sp)
     2fa:	ec56                	sd	s5,24(sp)
     2fc:	e85a                	sd	s6,16(sp)
     2fe:	e45e                	sd	s7,8(sp)
     300:	0880                	addi	s0,sp,80
     302:	8baa                	mv	s7,a0
  remove("bigwrite");
     304:	00005517          	auipc	a0,0x5
     308:	c7450513          	addi	a0,a0,-908 # 4f78 <malloc+0x212>
     30c:	00004097          	auipc	ra,0x4
     310:	6ba080e7          	jalr	1722(ra) # 49c6 <remove>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     314:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
     318:	00005a97          	auipc	s5,0x5
     31c:	c60a8a93          	addi	s5,s5,-928 # 4f78 <malloc+0x212>
      int cc = write(fd, buf, sz);
     320:	0000aa17          	auipc	s4,0xa
     324:	570a0a13          	addi	s4,s4,1392 # a890 <buf>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     328:	6b09                	lui	s6,0x2
     32a:	807b0b13          	addi	s6,s6,-2041 # 1807 <forkfork+0x3f>
    fd = open("bigwrite", O_CREATE | O_RDWR);
     32e:	20200593          	li	a1,514
     332:	8556                	mv	a0,s5
     334:	00004097          	auipc	ra,0x4
     338:	62a080e7          	jalr	1578(ra) # 495e <open>
     33c:	892a                	mv	s2,a0
    if(fd < 0){
     33e:	04054d63          	bltz	a0,398 <bigwrite+0xac>
      int cc = write(fd, buf, sz);
     342:	8626                	mv	a2,s1
     344:	85d2                	mv	a1,s4
     346:	00004097          	auipc	ra,0x4
     34a:	5f8080e7          	jalr	1528(ra) # 493e <write>
     34e:	89aa                	mv	s3,a0
      if(cc != sz){
     350:	06a49263          	bne	s1,a0,3b4 <bigwrite+0xc8>
      int cc = write(fd, buf, sz);
     354:	8626                	mv	a2,s1
     356:	85d2                	mv	a1,s4
     358:	854a                	mv	a0,s2
     35a:	00004097          	auipc	ra,0x4
     35e:	5e4080e7          	jalr	1508(ra) # 493e <write>
      if(cc != sz){
     362:	04951a63          	bne	a0,s1,3b6 <bigwrite+0xca>
    close(fd);
     366:	854a                	mv	a0,s2
     368:	00004097          	auipc	ra,0x4
     36c:	5de080e7          	jalr	1502(ra) # 4946 <close>
    remove("bigwrite");
     370:	8556                	mv	a0,s5
     372:	00004097          	auipc	ra,0x4
     376:	654080e7          	jalr	1620(ra) # 49c6 <remove>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     37a:	1d74849b          	addiw	s1,s1,471
     37e:	fb6498e3          	bne	s1,s6,32e <bigwrite+0x42>
}
     382:	60a6                	ld	ra,72(sp)
     384:	6406                	ld	s0,64(sp)
     386:	74e2                	ld	s1,56(sp)
     388:	7942                	ld	s2,48(sp)
     38a:	79a2                	ld	s3,40(sp)
     38c:	7a02                	ld	s4,32(sp)
     38e:	6ae2                	ld	s5,24(sp)
     390:	6b42                	ld	s6,16(sp)
     392:	6ba2                	ld	s7,8(sp)
     394:	6161                	addi	sp,sp,80
     396:	8082                	ret
      printf("%s: cannot create bigwrite\n", s);
     398:	85de                	mv	a1,s7
     39a:	00005517          	auipc	a0,0x5
     39e:	bee50513          	addi	a0,a0,-1042 # 4f88 <malloc+0x222>
     3a2:	00005097          	auipc	ra,0x5
     3a6:	90c080e7          	jalr	-1780(ra) # 4cae <printf>
      exit(1);
     3aa:	4505                	li	a0,1
     3ac:	00004097          	auipc	ra,0x4
     3b0:	572080e7          	jalr	1394(ra) # 491e <exit>
      if(cc != sz){
     3b4:	89a6                	mv	s3,s1
        printf("%s: write(%d) ret %d\n", s, sz, cc);
     3b6:	86aa                	mv	a3,a0
     3b8:	864e                	mv	a2,s3
     3ba:	85de                	mv	a1,s7
     3bc:	00005517          	auipc	a0,0x5
     3c0:	bec50513          	addi	a0,a0,-1044 # 4fa8 <malloc+0x242>
     3c4:	00005097          	auipc	ra,0x5
     3c8:	8ea080e7          	jalr	-1814(ra) # 4cae <printf>
        exit(1);
     3cc:	4505                	li	a0,1
     3ce:	00004097          	auipc	ra,0x4
     3d2:	550080e7          	jalr	1360(ra) # 491e <exit>

00000000000003d6 <badwrite>:
// file is deleted? if the kernel has this bug, it will panic: balloc:
// out of blocks. assumed_free may need to be raised to be more than
// the number of free blocks. this test takes a long time.
void
badwrite(char *s)
{
     3d6:	7179                	addi	sp,sp,-48
     3d8:	f406                	sd	ra,40(sp)
     3da:	f022                	sd	s0,32(sp)
     3dc:	ec26                	sd	s1,24(sp)
     3de:	e84a                	sd	s2,16(sp)
     3e0:	e44e                	sd	s3,8(sp)
     3e2:	e052                	sd	s4,0(sp)
     3e4:	1800                	addi	s0,sp,48
  int assumed_free = 600;
  
  remove("junk");
     3e6:	00005517          	auipc	a0,0x5
     3ea:	bda50513          	addi	a0,a0,-1062 # 4fc0 <malloc+0x25a>
     3ee:	00004097          	auipc	ra,0x4
     3f2:	5d8080e7          	jalr	1496(ra) # 49c6 <remove>
     3f6:	25800913          	li	s2,600
  for(int i = 0; i < assumed_free; i++){
    int fd = open("junk", O_CREATE|O_WRONLY);
     3fa:	00005997          	auipc	s3,0x5
     3fe:	bc698993          	addi	s3,s3,-1082 # 4fc0 <malloc+0x25a>
    if(fd < 0){
      printf("open junk failed\n");
      exit(1);
    }
    write(fd, (char*)0xffffffffffL, 1);
     402:	5a7d                	li	s4,-1
     404:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE|O_WRONLY);
     408:	20100593          	li	a1,513
     40c:	854e                	mv	a0,s3
     40e:	00004097          	auipc	ra,0x4
     412:	550080e7          	jalr	1360(ra) # 495e <open>
     416:	84aa                	mv	s1,a0
    if(fd < 0){
     418:	06054b63          	bltz	a0,48e <badwrite+0xb8>
    write(fd, (char*)0xffffffffffL, 1);
     41c:	4605                	li	a2,1
     41e:	85d2                	mv	a1,s4
     420:	00004097          	auipc	ra,0x4
     424:	51e080e7          	jalr	1310(ra) # 493e <write>
    close(fd);
     428:	8526                	mv	a0,s1
     42a:	00004097          	auipc	ra,0x4
     42e:	51c080e7          	jalr	1308(ra) # 4946 <close>
    remove("junk");
     432:	854e                	mv	a0,s3
     434:	00004097          	auipc	ra,0x4
     438:	592080e7          	jalr	1426(ra) # 49c6 <remove>
  for(int i = 0; i < assumed_free; i++){
     43c:	397d                	addiw	s2,s2,-1
     43e:	fc0915e3          	bnez	s2,408 <badwrite+0x32>
  }

  int fd = open("junk", O_CREATE|O_WRONLY);
     442:	20100593          	li	a1,513
     446:	00005517          	auipc	a0,0x5
     44a:	b7a50513          	addi	a0,a0,-1158 # 4fc0 <malloc+0x25a>
     44e:	00004097          	auipc	ra,0x4
     452:	510080e7          	jalr	1296(ra) # 495e <open>
     456:	84aa                	mv	s1,a0
  if(fd < 0){
     458:	04054863          	bltz	a0,4a8 <badwrite+0xd2>
    printf("open junk failed\n");
    exit(1);
  }
  if(write(fd, "x", 1) != 1){
     45c:	4605                	li	a2,1
     45e:	00005597          	auipc	a1,0x5
     462:	aea58593          	addi	a1,a1,-1302 # 4f48 <malloc+0x1e2>
     466:	00004097          	auipc	ra,0x4
     46a:	4d8080e7          	jalr	1240(ra) # 493e <write>
     46e:	4785                	li	a5,1
     470:	04f50963          	beq	a0,a5,4c2 <badwrite+0xec>
    printf("write failed\n");
     474:	00005517          	auipc	a0,0x5
     478:	b6c50513          	addi	a0,a0,-1172 # 4fe0 <malloc+0x27a>
     47c:	00005097          	auipc	ra,0x5
     480:	832080e7          	jalr	-1998(ra) # 4cae <printf>
    exit(1);
     484:	4505                	li	a0,1
     486:	00004097          	auipc	ra,0x4
     48a:	498080e7          	jalr	1176(ra) # 491e <exit>
      printf("open junk failed\n");
     48e:	00005517          	auipc	a0,0x5
     492:	b3a50513          	addi	a0,a0,-1222 # 4fc8 <malloc+0x262>
     496:	00005097          	auipc	ra,0x5
     49a:	818080e7          	jalr	-2024(ra) # 4cae <printf>
      exit(1);
     49e:	4505                	li	a0,1
     4a0:	00004097          	auipc	ra,0x4
     4a4:	47e080e7          	jalr	1150(ra) # 491e <exit>
    printf("open junk failed\n");
     4a8:	00005517          	auipc	a0,0x5
     4ac:	b2050513          	addi	a0,a0,-1248 # 4fc8 <malloc+0x262>
     4b0:	00004097          	auipc	ra,0x4
     4b4:	7fe080e7          	jalr	2046(ra) # 4cae <printf>
    exit(1);
     4b8:	4505                	li	a0,1
     4ba:	00004097          	auipc	ra,0x4
     4be:	464080e7          	jalr	1124(ra) # 491e <exit>
  }
  close(fd);
     4c2:	8526                	mv	a0,s1
     4c4:	00004097          	auipc	ra,0x4
     4c8:	482080e7          	jalr	1154(ra) # 4946 <close>
  remove("junk");
     4cc:	00005517          	auipc	a0,0x5
     4d0:	af450513          	addi	a0,a0,-1292 # 4fc0 <malloc+0x25a>
     4d4:	00004097          	auipc	ra,0x4
     4d8:	4f2080e7          	jalr	1266(ra) # 49c6 <remove>

  exit(0);
     4dc:	4501                	li	a0,0
     4de:	00004097          	auipc	ra,0x4
     4e2:	440080e7          	jalr	1088(ra) # 491e <exit>

00000000000004e6 <copyin>:
{
     4e6:	715d                	addi	sp,sp,-80
     4e8:	e486                	sd	ra,72(sp)
     4ea:	e0a2                	sd	s0,64(sp)
     4ec:	fc26                	sd	s1,56(sp)
     4ee:	f84a                	sd	s2,48(sp)
     4f0:	f44e                	sd	s3,40(sp)
     4f2:	f052                	sd	s4,32(sp)
     4f4:	0880                	addi	s0,sp,80
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     4f6:	4785                	li	a5,1
     4f8:	07fe                	slli	a5,a5,0x1f
     4fa:	fcf43023          	sd	a5,-64(s0)
     4fe:	57fd                	li	a5,-1
     500:	fcf43423          	sd	a5,-56(s0)
  for(int ai = 0; ai < 2; ai++){
     504:	fc040913          	addi	s2,s0,-64
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     508:	00005a17          	auipc	s4,0x5
     50c:	ae8a0a13          	addi	s4,s4,-1304 # 4ff0 <malloc+0x28a>
    uint64 addr = addrs[ai];
     510:	00093983          	ld	s3,0(s2)
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     514:	20100593          	li	a1,513
     518:	8552                	mv	a0,s4
     51a:	00004097          	auipc	ra,0x4
     51e:	444080e7          	jalr	1092(ra) # 495e <open>
     522:	84aa                	mv	s1,a0
    if(fd < 0){
     524:	08054863          	bltz	a0,5b4 <copyin+0xce>
    int n = write(fd, (void*)addr, 8192);
     528:	6609                	lui	a2,0x2
     52a:	85ce                	mv	a1,s3
     52c:	00004097          	auipc	ra,0x4
     530:	412080e7          	jalr	1042(ra) # 493e <write>
    if(n >= 0){
     534:	08055d63          	bgez	a0,5ce <copyin+0xe8>
    close(fd);
     538:	8526                	mv	a0,s1
     53a:	00004097          	auipc	ra,0x4
     53e:	40c080e7          	jalr	1036(ra) # 4946 <close>
    remove("copyin1");
     542:	8552                	mv	a0,s4
     544:	00004097          	auipc	ra,0x4
     548:	482080e7          	jalr	1154(ra) # 49c6 <remove>
    n = write(1, (char*)addr, 8192);
     54c:	6609                	lui	a2,0x2
     54e:	85ce                	mv	a1,s3
     550:	4505                	li	a0,1
     552:	00004097          	auipc	ra,0x4
     556:	3ec080e7          	jalr	1004(ra) # 493e <write>
    if(n > 0){
     55a:	08a04963          	bgtz	a0,5ec <copyin+0x106>
    if(pipe(fds) < 0){
     55e:	fb840513          	addi	a0,s0,-72
     562:	00004097          	auipc	ra,0x4
     566:	3cc080e7          	jalr	972(ra) # 492e <pipe>
     56a:	0a054063          	bltz	a0,60a <copyin+0x124>
    n = write(fds[1], (char*)addr, 8192);
     56e:	6609                	lui	a2,0x2
     570:	85ce                	mv	a1,s3
     572:	fbc42503          	lw	a0,-68(s0)
     576:	00004097          	auipc	ra,0x4
     57a:	3c8080e7          	jalr	968(ra) # 493e <write>
    if(n > 0){
     57e:	0aa04363          	bgtz	a0,624 <copyin+0x13e>
    close(fds[0]);
     582:	fb842503          	lw	a0,-72(s0)
     586:	00004097          	auipc	ra,0x4
     58a:	3c0080e7          	jalr	960(ra) # 4946 <close>
    close(fds[1]);
     58e:	fbc42503          	lw	a0,-68(s0)
     592:	00004097          	auipc	ra,0x4
     596:	3b4080e7          	jalr	948(ra) # 4946 <close>
  for(int ai = 0; ai < 2; ai++){
     59a:	0921                	addi	s2,s2,8
     59c:	fd040793          	addi	a5,s0,-48
     5a0:	f6f918e3          	bne	s2,a5,510 <copyin+0x2a>
}
     5a4:	60a6                	ld	ra,72(sp)
     5a6:	6406                	ld	s0,64(sp)
     5a8:	74e2                	ld	s1,56(sp)
     5aa:	7942                	ld	s2,48(sp)
     5ac:	79a2                	ld	s3,40(sp)
     5ae:	7a02                	ld	s4,32(sp)
     5b0:	6161                	addi	sp,sp,80
     5b2:	8082                	ret
      printf("open(copyin1) failed\n");
     5b4:	00005517          	auipc	a0,0x5
     5b8:	a4450513          	addi	a0,a0,-1468 # 4ff8 <malloc+0x292>
     5bc:	00004097          	auipc	ra,0x4
     5c0:	6f2080e7          	jalr	1778(ra) # 4cae <printf>
      exit(1);
     5c4:	4505                	li	a0,1
     5c6:	00004097          	auipc	ra,0x4
     5ca:	358080e7          	jalr	856(ra) # 491e <exit>
      printf("write(fd, %p, 8192) returned %d, not -1\n", addr, n);
     5ce:	862a                	mv	a2,a0
     5d0:	85ce                	mv	a1,s3
     5d2:	00005517          	auipc	a0,0x5
     5d6:	a3e50513          	addi	a0,a0,-1474 # 5010 <malloc+0x2aa>
     5da:	00004097          	auipc	ra,0x4
     5de:	6d4080e7          	jalr	1748(ra) # 4cae <printf>
      exit(1);
     5e2:	4505                	li	a0,1
     5e4:	00004097          	auipc	ra,0x4
     5e8:	33a080e7          	jalr	826(ra) # 491e <exit>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     5ec:	862a                	mv	a2,a0
     5ee:	85ce                	mv	a1,s3
     5f0:	00005517          	auipc	a0,0x5
     5f4:	a5050513          	addi	a0,a0,-1456 # 5040 <malloc+0x2da>
     5f8:	00004097          	auipc	ra,0x4
     5fc:	6b6080e7          	jalr	1718(ra) # 4cae <printf>
      exit(1);
     600:	4505                	li	a0,1
     602:	00004097          	auipc	ra,0x4
     606:	31c080e7          	jalr	796(ra) # 491e <exit>
      printf("pipe() failed\n");
     60a:	00005517          	auipc	a0,0x5
     60e:	a6650513          	addi	a0,a0,-1434 # 5070 <malloc+0x30a>
     612:	00004097          	auipc	ra,0x4
     616:	69c080e7          	jalr	1692(ra) # 4cae <printf>
      exit(1);
     61a:	4505                	li	a0,1
     61c:	00004097          	auipc	ra,0x4
     620:	302080e7          	jalr	770(ra) # 491e <exit>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     624:	862a                	mv	a2,a0
     626:	85ce                	mv	a1,s3
     628:	00005517          	auipc	a0,0x5
     62c:	a5850513          	addi	a0,a0,-1448 # 5080 <malloc+0x31a>
     630:	00004097          	auipc	ra,0x4
     634:	67e080e7          	jalr	1662(ra) # 4cae <printf>
      exit(1);
     638:	4505                	li	a0,1
     63a:	00004097          	auipc	ra,0x4
     63e:	2e4080e7          	jalr	740(ra) # 491e <exit>

0000000000000642 <copyout>:
{
     642:	711d                	addi	sp,sp,-96
     644:	ec86                	sd	ra,88(sp)
     646:	e8a2                	sd	s0,80(sp)
     648:	e4a6                	sd	s1,72(sp)
     64a:	e0ca                	sd	s2,64(sp)
     64c:	fc4e                	sd	s3,56(sp)
     64e:	f852                	sd	s4,48(sp)
     650:	f456                	sd	s5,40(sp)
     652:	1080                	addi	s0,sp,96
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     654:	4785                	li	a5,1
     656:	07fe                	slli	a5,a5,0x1f
     658:	faf43823          	sd	a5,-80(s0)
     65c:	57fd                	li	a5,-1
     65e:	faf43c23          	sd	a5,-72(s0)
  for(int ai = 0; ai < 2; ai++){
     662:	fb040913          	addi	s2,s0,-80
    int fd = open("README", 0);
     666:	00005a17          	auipc	s4,0x5
     66a:	a4aa0a13          	addi	s4,s4,-1462 # 50b0 <malloc+0x34a>
    n = write(fds[1], "x", 1);
     66e:	00005a97          	auipc	s5,0x5
     672:	8daa8a93          	addi	s5,s5,-1830 # 4f48 <malloc+0x1e2>
    uint64 addr = addrs[ai];
     676:	00093983          	ld	s3,0(s2)
    int fd = open("README", 0);
     67a:	4581                	li	a1,0
     67c:	8552                	mv	a0,s4
     67e:	00004097          	auipc	ra,0x4
     682:	2e0080e7          	jalr	736(ra) # 495e <open>
     686:	84aa                	mv	s1,a0
    if(fd < 0){
     688:	08054663          	bltz	a0,714 <copyout+0xd2>
    int n = read(fd, (void*)addr, 8192);
     68c:	6609                	lui	a2,0x2
     68e:	85ce                	mv	a1,s3
     690:	00004097          	auipc	ra,0x4
     694:	2a6080e7          	jalr	678(ra) # 4936 <read>
    if(n > 0){
     698:	08a04b63          	bgtz	a0,72e <copyout+0xec>
    close(fd);
     69c:	8526                	mv	a0,s1
     69e:	00004097          	auipc	ra,0x4
     6a2:	2a8080e7          	jalr	680(ra) # 4946 <close>
    if(pipe(fds) < 0){
     6a6:	fa840513          	addi	a0,s0,-88
     6aa:	00004097          	auipc	ra,0x4
     6ae:	284080e7          	jalr	644(ra) # 492e <pipe>
     6b2:	08054d63          	bltz	a0,74c <copyout+0x10a>
    n = write(fds[1], "x", 1);
     6b6:	4605                	li	a2,1
     6b8:	85d6                	mv	a1,s5
     6ba:	fac42503          	lw	a0,-84(s0)
     6be:	00004097          	auipc	ra,0x4
     6c2:	280080e7          	jalr	640(ra) # 493e <write>
    if(n != 1){
     6c6:	4785                	li	a5,1
     6c8:	08f51f63          	bne	a0,a5,766 <copyout+0x124>
    n = read(fds[0], (void*)addr, 8192);
     6cc:	6609                	lui	a2,0x2
     6ce:	85ce                	mv	a1,s3
     6d0:	fa842503          	lw	a0,-88(s0)
     6d4:	00004097          	auipc	ra,0x4
     6d8:	262080e7          	jalr	610(ra) # 4936 <read>
    if(n > 0){
     6dc:	0aa04263          	bgtz	a0,780 <copyout+0x13e>
    close(fds[0]);
     6e0:	fa842503          	lw	a0,-88(s0)
     6e4:	00004097          	auipc	ra,0x4
     6e8:	262080e7          	jalr	610(ra) # 4946 <close>
    close(fds[1]);
     6ec:	fac42503          	lw	a0,-84(s0)
     6f0:	00004097          	auipc	ra,0x4
     6f4:	256080e7          	jalr	598(ra) # 4946 <close>
  for(int ai = 0; ai < 2; ai++){
     6f8:	0921                	addi	s2,s2,8
     6fa:	fc040793          	addi	a5,s0,-64
     6fe:	f6f91ce3          	bne	s2,a5,676 <copyout+0x34>
}
     702:	60e6                	ld	ra,88(sp)
     704:	6446                	ld	s0,80(sp)
     706:	64a6                	ld	s1,72(sp)
     708:	6906                	ld	s2,64(sp)
     70a:	79e2                	ld	s3,56(sp)
     70c:	7a42                	ld	s4,48(sp)
     70e:	7aa2                	ld	s5,40(sp)
     710:	6125                	addi	sp,sp,96
     712:	8082                	ret
      printf("open(README) failed\n");
     714:	00005517          	auipc	a0,0x5
     718:	9a450513          	addi	a0,a0,-1628 # 50b8 <malloc+0x352>
     71c:	00004097          	auipc	ra,0x4
     720:	592080e7          	jalr	1426(ra) # 4cae <printf>
      exit(1);
     724:	4505                	li	a0,1
     726:	00004097          	auipc	ra,0x4
     72a:	1f8080e7          	jalr	504(ra) # 491e <exit>
      printf("read(fd, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     72e:	862a                	mv	a2,a0
     730:	85ce                	mv	a1,s3
     732:	00005517          	auipc	a0,0x5
     736:	99e50513          	addi	a0,a0,-1634 # 50d0 <malloc+0x36a>
     73a:	00004097          	auipc	ra,0x4
     73e:	574080e7          	jalr	1396(ra) # 4cae <printf>
      exit(1);
     742:	4505                	li	a0,1
     744:	00004097          	auipc	ra,0x4
     748:	1da080e7          	jalr	474(ra) # 491e <exit>
      printf("pipe() failed\n");
     74c:	00005517          	auipc	a0,0x5
     750:	92450513          	addi	a0,a0,-1756 # 5070 <malloc+0x30a>
     754:	00004097          	auipc	ra,0x4
     758:	55a080e7          	jalr	1370(ra) # 4cae <printf>
      exit(1);
     75c:	4505                	li	a0,1
     75e:	00004097          	auipc	ra,0x4
     762:	1c0080e7          	jalr	448(ra) # 491e <exit>
      printf("pipe write failed\n");
     766:	00005517          	auipc	a0,0x5
     76a:	99a50513          	addi	a0,a0,-1638 # 5100 <malloc+0x39a>
     76e:	00004097          	auipc	ra,0x4
     772:	540080e7          	jalr	1344(ra) # 4cae <printf>
      exit(1);
     776:	4505                	li	a0,1
     778:	00004097          	auipc	ra,0x4
     77c:	1a6080e7          	jalr	422(ra) # 491e <exit>
      printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     780:	862a                	mv	a2,a0
     782:	85ce                	mv	a1,s3
     784:	00005517          	auipc	a0,0x5
     788:	99450513          	addi	a0,a0,-1644 # 5118 <malloc+0x3b2>
     78c:	00004097          	auipc	ra,0x4
     790:	522080e7          	jalr	1314(ra) # 4cae <printf>
      exit(1);
     794:	4505                	li	a0,1
     796:	00004097          	auipc	ra,0x4
     79a:	188080e7          	jalr	392(ra) # 491e <exit>

000000000000079e <truncate1>:
{
     79e:	711d                	addi	sp,sp,-96
     7a0:	ec86                	sd	ra,88(sp)
     7a2:	e8a2                	sd	s0,80(sp)
     7a4:	e4a6                	sd	s1,72(sp)
     7a6:	e0ca                	sd	s2,64(sp)
     7a8:	fc4e                	sd	s3,56(sp)
     7aa:	f852                	sd	s4,48(sp)
     7ac:	f456                	sd	s5,40(sp)
     7ae:	1080                	addi	s0,sp,96
     7b0:	8aaa                	mv	s5,a0
  remove("truncfile");
     7b2:	00004517          	auipc	a0,0x4
     7b6:	77e50513          	addi	a0,a0,1918 # 4f30 <malloc+0x1ca>
     7ba:	00004097          	auipc	ra,0x4
     7be:	20c080e7          	jalr	524(ra) # 49c6 <remove>
  int fd1 = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     7c2:	60100593          	li	a1,1537
     7c6:	00004517          	auipc	a0,0x4
     7ca:	76a50513          	addi	a0,a0,1898 # 4f30 <malloc+0x1ca>
     7ce:	00004097          	auipc	ra,0x4
     7d2:	190080e7          	jalr	400(ra) # 495e <open>
     7d6:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     7d8:	4611                	li	a2,4
     7da:	00004597          	auipc	a1,0x4
     7de:	76658593          	addi	a1,a1,1894 # 4f40 <malloc+0x1da>
     7e2:	00004097          	auipc	ra,0x4
     7e6:	15c080e7          	jalr	348(ra) # 493e <write>
  close(fd1);
     7ea:	8526                	mv	a0,s1
     7ec:	00004097          	auipc	ra,0x4
     7f0:	15a080e7          	jalr	346(ra) # 4946 <close>
  int fd2 = open("truncfile", O_RDONLY);
     7f4:	4581                	li	a1,0
     7f6:	00004517          	auipc	a0,0x4
     7fa:	73a50513          	addi	a0,a0,1850 # 4f30 <malloc+0x1ca>
     7fe:	00004097          	auipc	ra,0x4
     802:	160080e7          	jalr	352(ra) # 495e <open>
     806:	84aa                	mv	s1,a0
  int n = read(fd2, buf, sizeof(buf));
     808:	02000613          	li	a2,32
     80c:	fa040593          	addi	a1,s0,-96
     810:	00004097          	auipc	ra,0x4
     814:	126080e7          	jalr	294(ra) # 4936 <read>
  if(n != 4){
     818:	4791                	li	a5,4
     81a:	0cf51e63          	bne	a0,a5,8f6 <truncate1+0x158>
  fd1 = open("truncfile", O_WRONLY|O_TRUNC);
     81e:	40100593          	li	a1,1025
     822:	00004517          	auipc	a0,0x4
     826:	70e50513          	addi	a0,a0,1806 # 4f30 <malloc+0x1ca>
     82a:	00004097          	auipc	ra,0x4
     82e:	134080e7          	jalr	308(ra) # 495e <open>
     832:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
     834:	4581                	li	a1,0
     836:	00004517          	auipc	a0,0x4
     83a:	6fa50513          	addi	a0,a0,1786 # 4f30 <malloc+0x1ca>
     83e:	00004097          	auipc	ra,0x4
     842:	120080e7          	jalr	288(ra) # 495e <open>
     846:	892a                	mv	s2,a0
  n = read(fd3, buf, sizeof(buf));
     848:	02000613          	li	a2,32
     84c:	fa040593          	addi	a1,s0,-96
     850:	00004097          	auipc	ra,0x4
     854:	0e6080e7          	jalr	230(ra) # 4936 <read>
     858:	8a2a                	mv	s4,a0
  if(n != 0){
     85a:	ed4d                	bnez	a0,914 <truncate1+0x176>
  n = read(fd2, buf, sizeof(buf));
     85c:	02000613          	li	a2,32
     860:	fa040593          	addi	a1,s0,-96
     864:	8526                	mv	a0,s1
     866:	00004097          	auipc	ra,0x4
     86a:	0d0080e7          	jalr	208(ra) # 4936 <read>
     86e:	8a2a                	mv	s4,a0
  if(n != 0){
     870:	e971                	bnez	a0,944 <truncate1+0x1a6>
  write(fd1, "abcdef", 6);
     872:	4619                	li	a2,6
     874:	00005597          	auipc	a1,0x5
     878:	93458593          	addi	a1,a1,-1740 # 51a8 <malloc+0x442>
     87c:	854e                	mv	a0,s3
     87e:	00004097          	auipc	ra,0x4
     882:	0c0080e7          	jalr	192(ra) # 493e <write>
  n = read(fd3, buf, sizeof(buf));
     886:	02000613          	li	a2,32
     88a:	fa040593          	addi	a1,s0,-96
     88e:	854a                	mv	a0,s2
     890:	00004097          	auipc	ra,0x4
     894:	0a6080e7          	jalr	166(ra) # 4936 <read>
  if(n != 6){
     898:	4799                	li	a5,6
     89a:	0cf51d63          	bne	a0,a5,974 <truncate1+0x1d6>
  n = read(fd2, buf, sizeof(buf));
     89e:	02000613          	li	a2,32
     8a2:	fa040593          	addi	a1,s0,-96
     8a6:	8526                	mv	a0,s1
     8a8:	00004097          	auipc	ra,0x4
     8ac:	08e080e7          	jalr	142(ra) # 4936 <read>
  if(n != 2){
     8b0:	4789                	li	a5,2
     8b2:	0ef51063          	bne	a0,a5,992 <truncate1+0x1f4>
  remove("truncfile");
     8b6:	00004517          	auipc	a0,0x4
     8ba:	67a50513          	addi	a0,a0,1658 # 4f30 <malloc+0x1ca>
     8be:	00004097          	auipc	ra,0x4
     8c2:	108080e7          	jalr	264(ra) # 49c6 <remove>
  close(fd1);
     8c6:	854e                	mv	a0,s3
     8c8:	00004097          	auipc	ra,0x4
     8cc:	07e080e7          	jalr	126(ra) # 4946 <close>
  close(fd2);
     8d0:	8526                	mv	a0,s1
     8d2:	00004097          	auipc	ra,0x4
     8d6:	074080e7          	jalr	116(ra) # 4946 <close>
  close(fd3);
     8da:	854a                	mv	a0,s2
     8dc:	00004097          	auipc	ra,0x4
     8e0:	06a080e7          	jalr	106(ra) # 4946 <close>
}
     8e4:	60e6                	ld	ra,88(sp)
     8e6:	6446                	ld	s0,80(sp)
     8e8:	64a6                	ld	s1,72(sp)
     8ea:	6906                	ld	s2,64(sp)
     8ec:	79e2                	ld	s3,56(sp)
     8ee:	7a42                	ld	s4,48(sp)
     8f0:	7aa2                	ld	s5,40(sp)
     8f2:	6125                	addi	sp,sp,96
     8f4:	8082                	ret
    printf("%s: read %d bytes, wanted 4\n", s, n);
     8f6:	862a                	mv	a2,a0
     8f8:	85d6                	mv	a1,s5
     8fa:	00005517          	auipc	a0,0x5
     8fe:	84e50513          	addi	a0,a0,-1970 # 5148 <malloc+0x3e2>
     902:	00004097          	auipc	ra,0x4
     906:	3ac080e7          	jalr	940(ra) # 4cae <printf>
    exit(1);
     90a:	4505                	li	a0,1
     90c:	00004097          	auipc	ra,0x4
     910:	012080e7          	jalr	18(ra) # 491e <exit>
    printf("aaa fd3=%d\n", fd3);
     914:	85ca                	mv	a1,s2
     916:	00005517          	auipc	a0,0x5
     91a:	85250513          	addi	a0,a0,-1966 # 5168 <malloc+0x402>
     91e:	00004097          	auipc	ra,0x4
     922:	390080e7          	jalr	912(ra) # 4cae <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     926:	8652                	mv	a2,s4
     928:	85d6                	mv	a1,s5
     92a:	00005517          	auipc	a0,0x5
     92e:	84e50513          	addi	a0,a0,-1970 # 5178 <malloc+0x412>
     932:	00004097          	auipc	ra,0x4
     936:	37c080e7          	jalr	892(ra) # 4cae <printf>
    exit(1);
     93a:	4505                	li	a0,1
     93c:	00004097          	auipc	ra,0x4
     940:	fe2080e7          	jalr	-30(ra) # 491e <exit>
    printf("bbb fd2=%d\n", fd2);
     944:	85a6                	mv	a1,s1
     946:	00005517          	auipc	a0,0x5
     94a:	85250513          	addi	a0,a0,-1966 # 5198 <malloc+0x432>
     94e:	00004097          	auipc	ra,0x4
     952:	360080e7          	jalr	864(ra) # 4cae <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     956:	8652                	mv	a2,s4
     958:	85d6                	mv	a1,s5
     95a:	00005517          	auipc	a0,0x5
     95e:	81e50513          	addi	a0,a0,-2018 # 5178 <malloc+0x412>
     962:	00004097          	auipc	ra,0x4
     966:	34c080e7          	jalr	844(ra) # 4cae <printf>
    exit(1);
     96a:	4505                	li	a0,1
     96c:	00004097          	auipc	ra,0x4
     970:	fb2080e7          	jalr	-78(ra) # 491e <exit>
    printf("%s: read %d bytes, wanted 6\n", s, n);
     974:	862a                	mv	a2,a0
     976:	85d6                	mv	a1,s5
     978:	00005517          	auipc	a0,0x5
     97c:	83850513          	addi	a0,a0,-1992 # 51b0 <malloc+0x44a>
     980:	00004097          	auipc	ra,0x4
     984:	32e080e7          	jalr	814(ra) # 4cae <printf>
    exit(1);
     988:	4505                	li	a0,1
     98a:	00004097          	auipc	ra,0x4
     98e:	f94080e7          	jalr	-108(ra) # 491e <exit>
    printf("%s: read %d bytes, wanted 2\n", s, n);
     992:	862a                	mv	a2,a0
     994:	85d6                	mv	a1,s5
     996:	00005517          	auipc	a0,0x5
     99a:	83a50513          	addi	a0,a0,-1990 # 51d0 <malloc+0x46a>
     99e:	00004097          	auipc	ra,0x4
     9a2:	310080e7          	jalr	784(ra) # 4cae <printf>
    exit(1);
     9a6:	4505                	li	a0,1
     9a8:	00004097          	auipc	ra,0x4
     9ac:	f76080e7          	jalr	-138(ra) # 491e <exit>

00000000000009b0 <writetest>:
{
     9b0:	7139                	addi	sp,sp,-64
     9b2:	fc06                	sd	ra,56(sp)
     9b4:	f822                	sd	s0,48(sp)
     9b6:	f426                	sd	s1,40(sp)
     9b8:	f04a                	sd	s2,32(sp)
     9ba:	ec4e                	sd	s3,24(sp)
     9bc:	e852                	sd	s4,16(sp)
     9be:	e456                	sd	s5,8(sp)
     9c0:	e05a                	sd	s6,0(sp)
     9c2:	0080                	addi	s0,sp,64
     9c4:	8b2a                	mv	s6,a0
  fd = open("small", O_CREATE|O_RDWR);
     9c6:	20200593          	li	a1,514
     9ca:	00005517          	auipc	a0,0x5
     9ce:	82650513          	addi	a0,a0,-2010 # 51f0 <malloc+0x48a>
     9d2:	00004097          	auipc	ra,0x4
     9d6:	f8c080e7          	jalr	-116(ra) # 495e <open>
  if(fd < 0){
     9da:	0a054d63          	bltz	a0,a94 <writetest+0xe4>
     9de:	892a                	mv	s2,a0
     9e0:	4481                	li	s1,0
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     9e2:	00005997          	auipc	s3,0x5
     9e6:	83698993          	addi	s3,s3,-1994 # 5218 <malloc+0x4b2>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     9ea:	00005a97          	auipc	s5,0x5
     9ee:	866a8a93          	addi	s5,s5,-1946 # 5250 <malloc+0x4ea>
  for(i = 0; i < N; i++){
     9f2:	06400a13          	li	s4,100
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     9f6:	4629                	li	a2,10
     9f8:	85ce                	mv	a1,s3
     9fa:	854a                	mv	a0,s2
     9fc:	00004097          	auipc	ra,0x4
     a00:	f42080e7          	jalr	-190(ra) # 493e <write>
     a04:	47a9                	li	a5,10
     a06:	0af51563          	bne	a0,a5,ab0 <writetest+0x100>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     a0a:	4629                	li	a2,10
     a0c:	85d6                	mv	a1,s5
     a0e:	854a                	mv	a0,s2
     a10:	00004097          	auipc	ra,0x4
     a14:	f2e080e7          	jalr	-210(ra) # 493e <write>
     a18:	47a9                	li	a5,10
     a1a:	0af51963          	bne	a0,a5,acc <writetest+0x11c>
  for(i = 0; i < N; i++){
     a1e:	2485                	addiw	s1,s1,1
     a20:	fd449be3          	bne	s1,s4,9f6 <writetest+0x46>
  close(fd);
     a24:	854a                	mv	a0,s2
     a26:	00004097          	auipc	ra,0x4
     a2a:	f20080e7          	jalr	-224(ra) # 4946 <close>
  fd = open("small", O_RDONLY);
     a2e:	4581                	li	a1,0
     a30:	00004517          	auipc	a0,0x4
     a34:	7c050513          	addi	a0,a0,1984 # 51f0 <malloc+0x48a>
     a38:	00004097          	auipc	ra,0x4
     a3c:	f26080e7          	jalr	-218(ra) # 495e <open>
     a40:	84aa                	mv	s1,a0
  if(fd < 0){
     a42:	0a054363          	bltz	a0,ae8 <writetest+0x138>
  i = read(fd, buf, N*SZ*2);
     a46:	7d000613          	li	a2,2000
     a4a:	0000a597          	auipc	a1,0xa
     a4e:	e4658593          	addi	a1,a1,-442 # a890 <buf>
     a52:	00004097          	auipc	ra,0x4
     a56:	ee4080e7          	jalr	-284(ra) # 4936 <read>
  if(i != N*SZ*2){
     a5a:	7d000793          	li	a5,2000
     a5e:	0af51363          	bne	a0,a5,b04 <writetest+0x154>
  close(fd);
     a62:	8526                	mv	a0,s1
     a64:	00004097          	auipc	ra,0x4
     a68:	ee2080e7          	jalr	-286(ra) # 4946 <close>
  if(remove("small") < 0){
     a6c:	00004517          	auipc	a0,0x4
     a70:	78450513          	addi	a0,a0,1924 # 51f0 <malloc+0x48a>
     a74:	00004097          	auipc	ra,0x4
     a78:	f52080e7          	jalr	-174(ra) # 49c6 <remove>
     a7c:	0a054263          	bltz	a0,b20 <writetest+0x170>
}
     a80:	70e2                	ld	ra,56(sp)
     a82:	7442                	ld	s0,48(sp)
     a84:	74a2                	ld	s1,40(sp)
     a86:	7902                	ld	s2,32(sp)
     a88:	69e2                	ld	s3,24(sp)
     a8a:	6a42                	ld	s4,16(sp)
     a8c:	6aa2                	ld	s5,8(sp)
     a8e:	6b02                	ld	s6,0(sp)
     a90:	6121                	addi	sp,sp,64
     a92:	8082                	ret
    printf("%s: error: creat small failed!\n", s);
     a94:	85da                	mv	a1,s6
     a96:	00004517          	auipc	a0,0x4
     a9a:	76250513          	addi	a0,a0,1890 # 51f8 <malloc+0x492>
     a9e:	00004097          	auipc	ra,0x4
     aa2:	210080e7          	jalr	528(ra) # 4cae <printf>
    exit(1);
     aa6:	4505                	li	a0,1
     aa8:	00004097          	auipc	ra,0x4
     aac:	e76080e7          	jalr	-394(ra) # 491e <exit>
      printf("%s: error: write aa %d new file failed\n", i);
     ab0:	85a6                	mv	a1,s1
     ab2:	00004517          	auipc	a0,0x4
     ab6:	77650513          	addi	a0,a0,1910 # 5228 <malloc+0x4c2>
     aba:	00004097          	auipc	ra,0x4
     abe:	1f4080e7          	jalr	500(ra) # 4cae <printf>
      exit(1);
     ac2:	4505                	li	a0,1
     ac4:	00004097          	auipc	ra,0x4
     ac8:	e5a080e7          	jalr	-422(ra) # 491e <exit>
      printf("%s: error: write bb %d new file failed\n", i);
     acc:	85a6                	mv	a1,s1
     ace:	00004517          	auipc	a0,0x4
     ad2:	79250513          	addi	a0,a0,1938 # 5260 <malloc+0x4fa>
     ad6:	00004097          	auipc	ra,0x4
     ada:	1d8080e7          	jalr	472(ra) # 4cae <printf>
      exit(1);
     ade:	4505                	li	a0,1
     ae0:	00004097          	auipc	ra,0x4
     ae4:	e3e080e7          	jalr	-450(ra) # 491e <exit>
    printf("%s: error: open small failed!\n", s);
     ae8:	85da                	mv	a1,s6
     aea:	00004517          	auipc	a0,0x4
     aee:	79e50513          	addi	a0,a0,1950 # 5288 <malloc+0x522>
     af2:	00004097          	auipc	ra,0x4
     af6:	1bc080e7          	jalr	444(ra) # 4cae <printf>
    exit(1);
     afa:	4505                	li	a0,1
     afc:	00004097          	auipc	ra,0x4
     b00:	e22080e7          	jalr	-478(ra) # 491e <exit>
    printf("%s: read failed\n", s);
     b04:	85da                	mv	a1,s6
     b06:	00004517          	auipc	a0,0x4
     b0a:	7a250513          	addi	a0,a0,1954 # 52a8 <malloc+0x542>
     b0e:	00004097          	auipc	ra,0x4
     b12:	1a0080e7          	jalr	416(ra) # 4cae <printf>
    exit(1);
     b16:	4505                	li	a0,1
     b18:	00004097          	auipc	ra,0x4
     b1c:	e06080e7          	jalr	-506(ra) # 491e <exit>
    printf("%s: remove small failed\n", s);
     b20:	85da                	mv	a1,s6
     b22:	00004517          	auipc	a0,0x4
     b26:	79e50513          	addi	a0,a0,1950 # 52c0 <malloc+0x55a>
     b2a:	00004097          	auipc	ra,0x4
     b2e:	184080e7          	jalr	388(ra) # 4cae <printf>
    exit(1);
     b32:	4505                	li	a0,1
     b34:	00004097          	auipc	ra,0x4
     b38:	dea080e7          	jalr	-534(ra) # 491e <exit>

0000000000000b3c <writebig>:
{
     b3c:	7179                	addi	sp,sp,-48
     b3e:	f406                	sd	ra,40(sp)
     b40:	f022                	sd	s0,32(sp)
     b42:	ec26                	sd	s1,24(sp)
     b44:	e84a                	sd	s2,16(sp)
     b46:	e44e                	sd	s3,8(sp)
     b48:	e052                	sd	s4,0(sp)
     b4a:	1800                	addi	s0,sp,48
     b4c:	8a2a                	mv	s4,a0
  fd = open("big", O_CREATE|O_RDWR);
     b4e:	20200593          	li	a1,514
     b52:	00004517          	auipc	a0,0x4
     b56:	78e50513          	addi	a0,a0,1934 # 52e0 <malloc+0x57a>
     b5a:	00004097          	auipc	ra,0x4
     b5e:	e04080e7          	jalr	-508(ra) # 495e <open>
     b62:	89aa                	mv	s3,a0
  for(i = 0; i < MAXFILE; i++){
     b64:	4481                	li	s1,0
    ((int*)buf)[0] = i;
     b66:	0000a917          	auipc	s2,0xa
     b6a:	d2a90913          	addi	s2,s2,-726 # a890 <buf>
  if(fd < 0){
     b6e:	06054e63          	bltz	a0,bea <writebig+0xae>
    ((int*)buf)[0] = i;
     b72:	00992023          	sw	s1,0(s2)
    if(write(fd, buf, BSIZE) != BSIZE){
     b76:	20000613          	li	a2,512
     b7a:	85ca                	mv	a1,s2
     b7c:	854e                	mv	a0,s3
     b7e:	00004097          	auipc	ra,0x4
     b82:	dc0080e7          	jalr	-576(ra) # 493e <write>
     b86:	20000793          	li	a5,512
     b8a:	06f51e63          	bne	a0,a5,c06 <writebig+0xca>
  for(i = 0; i < MAXFILE; i++){
     b8e:	2485                	addiw	s1,s1,1
     b90:	20000793          	li	a5,512
     b94:	fcf49fe3          	bne	s1,a5,b72 <writebig+0x36>
  close(fd);
     b98:	854e                	mv	a0,s3
     b9a:	00004097          	auipc	ra,0x4
     b9e:	dac080e7          	jalr	-596(ra) # 4946 <close>
  fd = open("big", O_RDONLY);
     ba2:	4581                	li	a1,0
     ba4:	00004517          	auipc	a0,0x4
     ba8:	73c50513          	addi	a0,a0,1852 # 52e0 <malloc+0x57a>
     bac:	00004097          	auipc	ra,0x4
     bb0:	db2080e7          	jalr	-590(ra) # 495e <open>
     bb4:	89aa                	mv	s3,a0
  n = 0;
     bb6:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
     bb8:	0000a917          	auipc	s2,0xa
     bbc:	cd890913          	addi	s2,s2,-808 # a890 <buf>
  if(fd < 0){
     bc0:	06054163          	bltz	a0,c22 <writebig+0xe6>
    i = read(fd, buf, BSIZE);
     bc4:	20000613          	li	a2,512
     bc8:	85ca                	mv	a1,s2
     bca:	854e                	mv	a0,s3
     bcc:	00004097          	auipc	ra,0x4
     bd0:	d6a080e7          	jalr	-662(ra) # 4936 <read>
    if(i == 0){
     bd4:	c52d                	beqz	a0,c3e <writebig+0x102>
    } else if(i != BSIZE){
     bd6:	20000793          	li	a5,512
     bda:	0af51c63          	bne	a0,a5,c92 <writebig+0x156>
    if(((int*)buf)[0] != n){
     bde:	00092603          	lw	a2,0(s2)
     be2:	0c961663          	bne	a2,s1,cae <writebig+0x172>
    n++;
     be6:	2485                	addiw	s1,s1,1
    i = read(fd, buf, BSIZE);
     be8:	bff1                	j	bc4 <writebig+0x88>
    printf("%s: error: creat big failed!\n", s);
     bea:	85d2                	mv	a1,s4
     bec:	00004517          	auipc	a0,0x4
     bf0:	6fc50513          	addi	a0,a0,1788 # 52e8 <malloc+0x582>
     bf4:	00004097          	auipc	ra,0x4
     bf8:	0ba080e7          	jalr	186(ra) # 4cae <printf>
    exit(1);
     bfc:	4505                	li	a0,1
     bfe:	00004097          	auipc	ra,0x4
     c02:	d20080e7          	jalr	-736(ra) # 491e <exit>
      printf("%s: error: write big file failed\n", i);
     c06:	85a6                	mv	a1,s1
     c08:	00004517          	auipc	a0,0x4
     c0c:	70050513          	addi	a0,a0,1792 # 5308 <malloc+0x5a2>
     c10:	00004097          	auipc	ra,0x4
     c14:	09e080e7          	jalr	158(ra) # 4cae <printf>
      exit(1);
     c18:	4505                	li	a0,1
     c1a:	00004097          	auipc	ra,0x4
     c1e:	d04080e7          	jalr	-764(ra) # 491e <exit>
    printf("%s: error: open big failed!\n", s);
     c22:	85d2                	mv	a1,s4
     c24:	00004517          	auipc	a0,0x4
     c28:	70c50513          	addi	a0,a0,1804 # 5330 <malloc+0x5ca>
     c2c:	00004097          	auipc	ra,0x4
     c30:	082080e7          	jalr	130(ra) # 4cae <printf>
    exit(1);
     c34:	4505                	li	a0,1
     c36:	00004097          	auipc	ra,0x4
     c3a:	ce8080e7          	jalr	-792(ra) # 491e <exit>
      if(n == MAXFILE - 1){
     c3e:	1ff00793          	li	a5,511
     c42:	02f48963          	beq	s1,a5,c74 <writebig+0x138>
  close(fd);
     c46:	854e                	mv	a0,s3
     c48:	00004097          	auipc	ra,0x4
     c4c:	cfe080e7          	jalr	-770(ra) # 4946 <close>
  if(remove("big") < 0){
     c50:	00004517          	auipc	a0,0x4
     c54:	69050513          	addi	a0,a0,1680 # 52e0 <malloc+0x57a>
     c58:	00004097          	auipc	ra,0x4
     c5c:	d6e080e7          	jalr	-658(ra) # 49c6 <remove>
     c60:	06054563          	bltz	a0,cca <writebig+0x18e>
}
     c64:	70a2                	ld	ra,40(sp)
     c66:	7402                	ld	s0,32(sp)
     c68:	64e2                	ld	s1,24(sp)
     c6a:	6942                	ld	s2,16(sp)
     c6c:	69a2                	ld	s3,8(sp)
     c6e:	6a02                	ld	s4,0(sp)
     c70:	6145                	addi	sp,sp,48
     c72:	8082                	ret
        printf("%s: read only %d blocks from big", n);
     c74:	1ff00593          	li	a1,511
     c78:	00004517          	auipc	a0,0x4
     c7c:	6d850513          	addi	a0,a0,1752 # 5350 <malloc+0x5ea>
     c80:	00004097          	auipc	ra,0x4
     c84:	02e080e7          	jalr	46(ra) # 4cae <printf>
        exit(1);
     c88:	4505                	li	a0,1
     c8a:	00004097          	auipc	ra,0x4
     c8e:	c94080e7          	jalr	-876(ra) # 491e <exit>
      printf("%s: read failed %d\n", i);
     c92:	85aa                	mv	a1,a0
     c94:	00004517          	auipc	a0,0x4
     c98:	6e450513          	addi	a0,a0,1764 # 5378 <malloc+0x612>
     c9c:	00004097          	auipc	ra,0x4
     ca0:	012080e7          	jalr	18(ra) # 4cae <printf>
      exit(1);
     ca4:	4505                	li	a0,1
     ca6:	00004097          	auipc	ra,0x4
     caa:	c78080e7          	jalr	-904(ra) # 491e <exit>
      printf("%s: read content of block %d is %d\n",
     cae:	85a6                	mv	a1,s1
     cb0:	00004517          	auipc	a0,0x4
     cb4:	6e050513          	addi	a0,a0,1760 # 5390 <malloc+0x62a>
     cb8:	00004097          	auipc	ra,0x4
     cbc:	ff6080e7          	jalr	-10(ra) # 4cae <printf>
      exit(1);
     cc0:	4505                	li	a0,1
     cc2:	00004097          	auipc	ra,0x4
     cc6:	c5c080e7          	jalr	-932(ra) # 491e <exit>
    printf("%s: remove big failed\n", s);
     cca:	85d2                	mv	a1,s4
     ccc:	00004517          	auipc	a0,0x4
     cd0:	6ec50513          	addi	a0,a0,1772 # 53b8 <malloc+0x652>
     cd4:	00004097          	auipc	ra,0x4
     cd8:	fda080e7          	jalr	-38(ra) # 4cae <printf>
    exit(1);
     cdc:	4505                	li	a0,1
     cde:	00004097          	auipc	ra,0x4
     ce2:	c40080e7          	jalr	-960(ra) # 491e <exit>

0000000000000ce6 <removeread>:
{
     ce6:	7179                	addi	sp,sp,-48
     ce8:	f406                	sd	ra,40(sp)
     cea:	f022                	sd	s0,32(sp)
     cec:	ec26                	sd	s1,24(sp)
     cee:	e84a                	sd	s2,16(sp)
     cf0:	e44e                	sd	s3,8(sp)
     cf2:	1800                	addi	s0,sp,48
     cf4:	89aa                	mv	s3,a0
  fd = open("removeread", O_CREATE | O_RDWR);
     cf6:	20200593          	li	a1,514
     cfa:	00004517          	auipc	a0,0x4
     cfe:	6d650513          	addi	a0,a0,1750 # 53d0 <malloc+0x66a>
     d02:	00004097          	auipc	ra,0x4
     d06:	c5c080e7          	jalr	-932(ra) # 495e <open>
  if(fd < 0){
     d0a:	0e054763          	bltz	a0,df8 <removeread+0x112>
     d0e:	84aa                	mv	s1,a0
  write(fd, "hello", SZ);
     d10:	4615                	li	a2,5
     d12:	00004597          	auipc	a1,0x4
     d16:	6ee58593          	addi	a1,a1,1774 # 5400 <malloc+0x69a>
     d1a:	00004097          	auipc	ra,0x4
     d1e:	c24080e7          	jalr	-988(ra) # 493e <write>
  close(fd);
     d22:	8526                	mv	a0,s1
     d24:	00004097          	auipc	ra,0x4
     d28:	c22080e7          	jalr	-990(ra) # 4946 <close>
  fd = open("removeread", O_RDWR);
     d2c:	4589                	li	a1,2
     d2e:	00004517          	auipc	a0,0x4
     d32:	6a250513          	addi	a0,a0,1698 # 53d0 <malloc+0x66a>
     d36:	00004097          	auipc	ra,0x4
     d3a:	c28080e7          	jalr	-984(ra) # 495e <open>
     d3e:	84aa                	mv	s1,a0
  if(fd < 0){
     d40:	0c054a63          	bltz	a0,e14 <removeread+0x12e>
  if(remove("removeread") != 0){
     d44:	00004517          	auipc	a0,0x4
     d48:	68c50513          	addi	a0,a0,1676 # 53d0 <malloc+0x66a>
     d4c:	00004097          	auipc	ra,0x4
     d50:	c7a080e7          	jalr	-902(ra) # 49c6 <remove>
     d54:	ed71                	bnez	a0,e30 <removeread+0x14a>
  fd1 = open("removeread", O_CREATE | O_RDWR);
     d56:	20200593          	li	a1,514
     d5a:	00004517          	auipc	a0,0x4
     d5e:	67650513          	addi	a0,a0,1654 # 53d0 <malloc+0x66a>
     d62:	00004097          	auipc	ra,0x4
     d66:	bfc080e7          	jalr	-1028(ra) # 495e <open>
     d6a:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
     d6c:	460d                	li	a2,3
     d6e:	00004597          	auipc	a1,0x4
     d72:	6da58593          	addi	a1,a1,1754 # 5448 <malloc+0x6e2>
     d76:	00004097          	auipc	ra,0x4
     d7a:	bc8080e7          	jalr	-1080(ra) # 493e <write>
  close(fd1);
     d7e:	854a                	mv	a0,s2
     d80:	00004097          	auipc	ra,0x4
     d84:	bc6080e7          	jalr	-1082(ra) # 4946 <close>
  if(read(fd, buf, sizeof(buf)) != SZ){
     d88:	6609                	lui	a2,0x2
     d8a:	80060613          	addi	a2,a2,-2048 # 1800 <forkfork+0x38>
     d8e:	0000a597          	auipc	a1,0xa
     d92:	b0258593          	addi	a1,a1,-1278 # a890 <buf>
     d96:	8526                	mv	a0,s1
     d98:	00004097          	auipc	ra,0x4
     d9c:	b9e080e7          	jalr	-1122(ra) # 4936 <read>
     da0:	4795                	li	a5,5
     da2:	0af51563          	bne	a0,a5,e4c <removeread+0x166>
  if(buf[0] != 'h'){
     da6:	0000a717          	auipc	a4,0xa
     daa:	aea74703          	lbu	a4,-1302(a4) # a890 <buf>
     dae:	06800793          	li	a5,104
     db2:	0af71b63          	bne	a4,a5,e68 <removeread+0x182>
  if(write(fd, buf, 10) != 10){
     db6:	4629                	li	a2,10
     db8:	0000a597          	auipc	a1,0xa
     dbc:	ad858593          	addi	a1,a1,-1320 # a890 <buf>
     dc0:	8526                	mv	a0,s1
     dc2:	00004097          	auipc	ra,0x4
     dc6:	b7c080e7          	jalr	-1156(ra) # 493e <write>
     dca:	47a9                	li	a5,10
     dcc:	0af51c63          	bne	a0,a5,e84 <removeread+0x19e>
  close(fd);
     dd0:	8526                	mv	a0,s1
     dd2:	00004097          	auipc	ra,0x4
     dd6:	b74080e7          	jalr	-1164(ra) # 4946 <close>
  remove("removeread");
     dda:	00004517          	auipc	a0,0x4
     dde:	5f650513          	addi	a0,a0,1526 # 53d0 <malloc+0x66a>
     de2:	00004097          	auipc	ra,0x4
     de6:	be4080e7          	jalr	-1052(ra) # 49c6 <remove>
}
     dea:	70a2                	ld	ra,40(sp)
     dec:	7402                	ld	s0,32(sp)
     dee:	64e2                	ld	s1,24(sp)
     df0:	6942                	ld	s2,16(sp)
     df2:	69a2                	ld	s3,8(sp)
     df4:	6145                	addi	sp,sp,48
     df6:	8082                	ret
    printf("%s: create removeread failed\n", s);
     df8:	85ce                	mv	a1,s3
     dfa:	00004517          	auipc	a0,0x4
     dfe:	5e650513          	addi	a0,a0,1510 # 53e0 <malloc+0x67a>
     e02:	00004097          	auipc	ra,0x4
     e06:	eac080e7          	jalr	-340(ra) # 4cae <printf>
    exit(1);
     e0a:	4505                	li	a0,1
     e0c:	00004097          	auipc	ra,0x4
     e10:	b12080e7          	jalr	-1262(ra) # 491e <exit>
    printf("%s: open removeread failed\n", s);
     e14:	85ce                	mv	a1,s3
     e16:	00004517          	auipc	a0,0x4
     e1a:	5f250513          	addi	a0,a0,1522 # 5408 <malloc+0x6a2>
     e1e:	00004097          	auipc	ra,0x4
     e22:	e90080e7          	jalr	-368(ra) # 4cae <printf>
    exit(1);
     e26:	4505                	li	a0,1
     e28:	00004097          	auipc	ra,0x4
     e2c:	af6080e7          	jalr	-1290(ra) # 491e <exit>
    printf("%s: remove removeread failed\n", s);
     e30:	85ce                	mv	a1,s3
     e32:	00004517          	auipc	a0,0x4
     e36:	5f650513          	addi	a0,a0,1526 # 5428 <malloc+0x6c2>
     e3a:	00004097          	auipc	ra,0x4
     e3e:	e74080e7          	jalr	-396(ra) # 4cae <printf>
    exit(1);
     e42:	4505                	li	a0,1
     e44:	00004097          	auipc	ra,0x4
     e48:	ada080e7          	jalr	-1318(ra) # 491e <exit>
    printf("%s: removeread read failed", s);
     e4c:	85ce                	mv	a1,s3
     e4e:	00004517          	auipc	a0,0x4
     e52:	60250513          	addi	a0,a0,1538 # 5450 <malloc+0x6ea>
     e56:	00004097          	auipc	ra,0x4
     e5a:	e58080e7          	jalr	-424(ra) # 4cae <printf>
    exit(1);
     e5e:	4505                	li	a0,1
     e60:	00004097          	auipc	ra,0x4
     e64:	abe080e7          	jalr	-1346(ra) # 491e <exit>
    printf("%s: removeread wrong data\n", s);
     e68:	85ce                	mv	a1,s3
     e6a:	00004517          	auipc	a0,0x4
     e6e:	60650513          	addi	a0,a0,1542 # 5470 <malloc+0x70a>
     e72:	00004097          	auipc	ra,0x4
     e76:	e3c080e7          	jalr	-452(ra) # 4cae <printf>
    exit(1);
     e7a:	4505                	li	a0,1
     e7c:	00004097          	auipc	ra,0x4
     e80:	aa2080e7          	jalr	-1374(ra) # 491e <exit>
    printf("%s: removeread write failed\n", s);
     e84:	85ce                	mv	a1,s3
     e86:	00004517          	auipc	a0,0x4
     e8a:	60a50513          	addi	a0,a0,1546 # 5490 <malloc+0x72a>
     e8e:	00004097          	auipc	ra,0x4
     e92:	e20080e7          	jalr	-480(ra) # 4cae <printf>
    exit(1);
     e96:	4505                	li	a0,1
     e98:	00004097          	auipc	ra,0x4
     e9c:	a86080e7          	jalr	-1402(ra) # 491e <exit>

0000000000000ea0 <pgbug>:
{
     ea0:	7179                	addi	sp,sp,-48
     ea2:	f406                	sd	ra,40(sp)
     ea4:	f022                	sd	s0,32(sp)
     ea6:	ec26                	sd	s1,24(sp)
     ea8:	1800                	addi	s0,sp,48
  argv[0] = 0;
     eaa:	fc043c23          	sd	zero,-40(s0)
  exec((char*)0xeaeb0b5b00002f5e, argv);
     eae:	eaeb14b7          	lui	s1,0xeaeb1
     eb2:	b5b48493          	addi	s1,s1,-1189 # ffffffffeaeb0b5b <__BSS_END__+0xffffffffeaea4abb>
     eb6:	04d2                	slli	s1,s1,0x14
     eb8:	048d                	addi	s1,s1,3
     eba:	04b2                	slli	s1,s1,0xc
     ebc:	f5e48493          	addi	s1,s1,-162
     ec0:	fd840593          	addi	a1,s0,-40
     ec4:	8526                	mv	a0,s1
     ec6:	00004097          	auipc	ra,0x4
     eca:	a90080e7          	jalr	-1392(ra) # 4956 <exec>
  pipe((int*)0xeaeb0b5b00002f5e);
     ece:	8526                	mv	a0,s1
     ed0:	00004097          	auipc	ra,0x4
     ed4:	a5e080e7          	jalr	-1442(ra) # 492e <pipe>
  exit(0);
     ed8:	4501                	li	a0,0
     eda:	00004097          	auipc	ra,0x4
     ede:	a44080e7          	jalr	-1468(ra) # 491e <exit>

0000000000000ee2 <badarg>:

// regression test. test whether exec() leaks memory if one of the
// arguments is invalid. the test passes if the kernel doesn't panic.
void
badarg(char *s)
{
     ee2:	7139                	addi	sp,sp,-64
     ee4:	fc06                	sd	ra,56(sp)
     ee6:	f822                	sd	s0,48(sp)
     ee8:	f426                	sd	s1,40(sp)
     eea:	f04a                	sd	s2,32(sp)
     eec:	ec4e                	sd	s3,24(sp)
     eee:	0080                	addi	s0,sp,64
     ef0:	64b1                	lui	s1,0xc
     ef2:	35048493          	addi	s1,s1,848 # c350 <__BSS_END__+0x2b0>
  for(int i = 0; i < 50000; i++){
    char *argv[2];
    argv[0] = (char*)0xffffffff;
     ef6:	597d                	li	s2,-1
     ef8:	02095913          	srli	s2,s2,0x20
    argv[1] = 0;
    exec("echo", argv);
     efc:	00004997          	auipc	s3,0x4
     f00:	fdc98993          	addi	s3,s3,-36 # 4ed8 <malloc+0x172>
    argv[0] = (char*)0xffffffff;
     f04:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
     f08:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
     f0c:	fc040593          	addi	a1,s0,-64
     f10:	854e                	mv	a0,s3
     f12:	00004097          	auipc	ra,0x4
     f16:	a44080e7          	jalr	-1468(ra) # 4956 <exec>
  for(int i = 0; i < 50000; i++){
     f1a:	34fd                	addiw	s1,s1,-1
     f1c:	f4e5                	bnez	s1,f04 <badarg+0x22>
  }
  
  exit(0);
     f1e:	4501                	li	a0,0
     f20:	00004097          	auipc	ra,0x4
     f24:	9fe080e7          	jalr	-1538(ra) # 491e <exit>

0000000000000f28 <copyinstr2>:
{
     f28:	714d                	addi	sp,sp,-336
     f2a:	e686                	sd	ra,328(sp)
     f2c:	e2a2                	sd	s0,320(sp)
     f2e:	0a80                	addi	s0,sp,336
  for(int i = 0; i < MAXPATH; i++)
     f30:	ee840793          	addi	a5,s0,-280
     f34:	fec40693          	addi	a3,s0,-20
    b[i] = 'x';
     f38:	07800713          	li	a4,120
     f3c:	00e78023          	sb	a4,0(a5)
  for(int i = 0; i < MAXPATH; i++)
     f40:	0785                	addi	a5,a5,1
     f42:	fed79de3          	bne	a5,a3,f3c <copyinstr2+0x14>
  b[MAXPATH] = '\0';
     f46:	fe040623          	sb	zero,-20(s0)
  int ret = remove(b);
     f4a:	ee840513          	addi	a0,s0,-280
     f4e:	00004097          	auipc	ra,0x4
     f52:	a78080e7          	jalr	-1416(ra) # 49c6 <remove>
  if(ret != -1){
     f56:	57fd                	li	a5,-1
     f58:	0cf51663          	bne	a0,a5,1024 <copyinstr2+0xfc>
  int fd = open(b, O_CREATE | O_WRONLY);
     f5c:	20100593          	li	a1,513
     f60:	ee840513          	addi	a0,s0,-280
     f64:	00004097          	auipc	ra,0x4
     f68:	9fa080e7          	jalr	-1542(ra) # 495e <open>
  if(fd != -1){
     f6c:	57fd                	li	a5,-1
     f6e:	0cf51b63          	bne	a0,a5,1044 <copyinstr2+0x11c>
  char *args[] = { "xx", 0 };
     f72:	00005797          	auipc	a5,0x5
     f76:	15678793          	addi	a5,a5,342 # 60c8 <malloc+0x1362>
     f7a:	ecf43c23          	sd	a5,-296(s0)
     f7e:	ee043023          	sd	zero,-288(s0)
  ret = exec(b, args);
     f82:	ed840593          	addi	a1,s0,-296
     f86:	ee840513          	addi	a0,s0,-280
     f8a:	00004097          	auipc	ra,0x4
     f8e:	9cc080e7          	jalr	-1588(ra) # 4956 <exec>
  if(ret != -1){
     f92:	57fd                	li	a5,-1
     f94:	0cf51863          	bne	a0,a5,1064 <copyinstr2+0x13c>
  int pid = fork();
     f98:	00004097          	auipc	ra,0x4
     f9c:	97e080e7          	jalr	-1666(ra) # 4916 <fork>
  if(pid < 0){
     fa0:	0e054263          	bltz	a0,1084 <copyinstr2+0x15c>
  if(pid == 0){
     fa4:	10051363          	bnez	a0,10aa <copyinstr2+0x182>
     fa8:	00006797          	auipc	a5,0x6
     fac:	1d078793          	addi	a5,a5,464 # 7178 <big.0>
     fb0:	00007697          	auipc	a3,0x7
     fb4:	1c868693          	addi	a3,a3,456 # 8178 <__global_pointer$+0x918>
      big[i] = 'x';
     fb8:	07800713          	li	a4,120
     fbc:	00e78023          	sb	a4,0(a5)
    for(int i = 0; i < PGSIZE; i++)
     fc0:	0785                	addi	a5,a5,1
     fc2:	fed79de3          	bne	a5,a3,fbc <copyinstr2+0x94>
    big[PGSIZE] = '\0';
     fc6:	00007797          	auipc	a5,0x7
     fca:	1a078923          	sb	zero,434(a5) # 8178 <__global_pointer$+0x918>
    char *args2[] = { big, big, big, 0 };
     fce:	00006797          	auipc	a5,0x6
     fd2:	cc278793          	addi	a5,a5,-830 # 6c90 <malloc+0x1f2a>
     fd6:	6390                	ld	a2,0(a5)
     fd8:	6794                	ld	a3,8(a5)
     fda:	6b98                	ld	a4,16(a5)
     fdc:	6f9c                	ld	a5,24(a5)
     fde:	eac43823          	sd	a2,-336(s0)
     fe2:	ead43c23          	sd	a3,-328(s0)
     fe6:	ece43023          	sd	a4,-320(s0)
     fea:	ecf43423          	sd	a5,-312(s0)
    ret = exec("echo", args2);
     fee:	eb040593          	addi	a1,s0,-336
     ff2:	00004517          	auipc	a0,0x4
     ff6:	ee650513          	addi	a0,a0,-282 # 4ed8 <malloc+0x172>
     ffa:	00004097          	auipc	ra,0x4
     ffe:	95c080e7          	jalr	-1700(ra) # 4956 <exec>
    if(ret != -1){
    1002:	57fd                	li	a5,-1
    1004:	08f50d63          	beq	a0,a5,109e <copyinstr2+0x176>
      printf("exec(echo, BIG) returned %d, not -1\n", fd);
    1008:	55fd                	li	a1,-1
    100a:	00004517          	auipc	a0,0x4
    100e:	50650513          	addi	a0,a0,1286 # 5510 <malloc+0x7aa>
    1012:	00004097          	auipc	ra,0x4
    1016:	c9c080e7          	jalr	-868(ra) # 4cae <printf>
      exit(1);
    101a:	4505                	li	a0,1
    101c:	00004097          	auipc	ra,0x4
    1020:	902080e7          	jalr	-1790(ra) # 491e <exit>
    printf("remove(%s) returned %d, not -1\n", b, ret);
    1024:	862a                	mv	a2,a0
    1026:	ee840593          	addi	a1,s0,-280
    102a:	00004517          	auipc	a0,0x4
    102e:	48650513          	addi	a0,a0,1158 # 54b0 <malloc+0x74a>
    1032:	00004097          	auipc	ra,0x4
    1036:	c7c080e7          	jalr	-900(ra) # 4cae <printf>
    exit(1);
    103a:	4505                	li	a0,1
    103c:	00004097          	auipc	ra,0x4
    1040:	8e2080e7          	jalr	-1822(ra) # 491e <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    1044:	862a                	mv	a2,a0
    1046:	ee840593          	addi	a1,s0,-280
    104a:	00004517          	auipc	a0,0x4
    104e:	48650513          	addi	a0,a0,1158 # 54d0 <malloc+0x76a>
    1052:	00004097          	auipc	ra,0x4
    1056:	c5c080e7          	jalr	-932(ra) # 4cae <printf>
    exit(1);
    105a:	4505                	li	a0,1
    105c:	00004097          	auipc	ra,0x4
    1060:	8c2080e7          	jalr	-1854(ra) # 491e <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    1064:	567d                	li	a2,-1
    1066:	ee840593          	addi	a1,s0,-280
    106a:	00004517          	auipc	a0,0x4
    106e:	48650513          	addi	a0,a0,1158 # 54f0 <malloc+0x78a>
    1072:	00004097          	auipc	ra,0x4
    1076:	c3c080e7          	jalr	-964(ra) # 4cae <printf>
    exit(1);
    107a:	4505                	li	a0,1
    107c:	00004097          	auipc	ra,0x4
    1080:	8a2080e7          	jalr	-1886(ra) # 491e <exit>
    printf("fork failed\n");
    1084:	00005517          	auipc	a0,0x5
    1088:	86450513          	addi	a0,a0,-1948 # 58e8 <malloc+0xb82>
    108c:	00004097          	auipc	ra,0x4
    1090:	c22080e7          	jalr	-990(ra) # 4cae <printf>
    exit(1);
    1094:	4505                	li	a0,1
    1096:	00004097          	auipc	ra,0x4
    109a:	888080e7          	jalr	-1912(ra) # 491e <exit>
    exit(747); // OK
    109e:	2eb00513          	li	a0,747
    10a2:	00004097          	auipc	ra,0x4
    10a6:	87c080e7          	jalr	-1924(ra) # 491e <exit>
  int st = 0;
    10aa:	ec042a23          	sw	zero,-300(s0)
  wait(&st);
    10ae:	ed440513          	addi	a0,s0,-300
    10b2:	00004097          	auipc	ra,0x4
    10b6:	874080e7          	jalr	-1932(ra) # 4926 <wait>
  if(st != 747){
    10ba:	ed442703          	lw	a4,-300(s0)
    10be:	2eb00793          	li	a5,747
    10c2:	00f71663          	bne	a4,a5,10ce <copyinstr2+0x1a6>
}
    10c6:	60b6                	ld	ra,328(sp)
    10c8:	6416                	ld	s0,320(sp)
    10ca:	6171                	addi	sp,sp,336
    10cc:	8082                	ret
    printf("exec(echo, BIG) succeeded, should have failed\n");
    10ce:	00004517          	auipc	a0,0x4
    10d2:	46a50513          	addi	a0,a0,1130 # 5538 <malloc+0x7d2>
    10d6:	00004097          	auipc	ra,0x4
    10da:	bd8080e7          	jalr	-1064(ra) # 4cae <printf>
    exit(1);
    10de:	4505                	li	a0,1
    10e0:	00004097          	auipc	ra,0x4
    10e4:	83e080e7          	jalr	-1986(ra) # 491e <exit>

00000000000010e8 <truncate3>:
{
    10e8:	7159                	addi	sp,sp,-112
    10ea:	f486                	sd	ra,104(sp)
    10ec:	f0a2                	sd	s0,96(sp)
    10ee:	e8ca                	sd	s2,80(sp)
    10f0:	1880                	addi	s0,sp,112
    10f2:	892a                	mv	s2,a0
  close(open("truncfile", O_CREATE|O_TRUNC|O_WRONLY));
    10f4:	60100593          	li	a1,1537
    10f8:	00004517          	auipc	a0,0x4
    10fc:	e3850513          	addi	a0,a0,-456 # 4f30 <malloc+0x1ca>
    1100:	00004097          	auipc	ra,0x4
    1104:	85e080e7          	jalr	-1954(ra) # 495e <open>
    1108:	00004097          	auipc	ra,0x4
    110c:	83e080e7          	jalr	-1986(ra) # 4946 <close>
  pid = fork();
    1110:	00004097          	auipc	ra,0x4
    1114:	806080e7          	jalr	-2042(ra) # 4916 <fork>
  if(pid < 0){
    1118:	08054463          	bltz	a0,11a0 <truncate3+0xb8>
  if(pid == 0){
    111c:	e16d                	bnez	a0,11fe <truncate3+0x116>
    111e:	eca6                	sd	s1,88(sp)
    1120:	e4ce                	sd	s3,72(sp)
    1122:	e0d2                	sd	s4,64(sp)
    1124:	fc56                	sd	s5,56(sp)
    1126:	06400993          	li	s3,100
      int fd = open("truncfile", O_WRONLY);
    112a:	00004a17          	auipc	s4,0x4
    112e:	e06a0a13          	addi	s4,s4,-506 # 4f30 <malloc+0x1ca>
      int n = write(fd, "1234567890", 10);
    1132:	00004a97          	auipc	s5,0x4
    1136:	466a8a93          	addi	s5,s5,1126 # 5598 <malloc+0x832>
      int fd = open("truncfile", O_WRONLY);
    113a:	4585                	li	a1,1
    113c:	8552                	mv	a0,s4
    113e:	00004097          	auipc	ra,0x4
    1142:	820080e7          	jalr	-2016(ra) # 495e <open>
    1146:	84aa                	mv	s1,a0
      if(fd < 0){
    1148:	06054e63          	bltz	a0,11c4 <truncate3+0xdc>
      int n = write(fd, "1234567890", 10);
    114c:	4629                	li	a2,10
    114e:	85d6                	mv	a1,s5
    1150:	00003097          	auipc	ra,0x3
    1154:	7ee080e7          	jalr	2030(ra) # 493e <write>
      if(n != 10){
    1158:	47a9                	li	a5,10
    115a:	08f51363          	bne	a0,a5,11e0 <truncate3+0xf8>
      close(fd);
    115e:	8526                	mv	a0,s1
    1160:	00003097          	auipc	ra,0x3
    1164:	7e6080e7          	jalr	2022(ra) # 4946 <close>
      fd = open("truncfile", O_RDONLY);
    1168:	4581                	li	a1,0
    116a:	8552                	mv	a0,s4
    116c:	00003097          	auipc	ra,0x3
    1170:	7f2080e7          	jalr	2034(ra) # 495e <open>
    1174:	84aa                	mv	s1,a0
      read(fd, buf, sizeof(buf));
    1176:	02000613          	li	a2,32
    117a:	f9840593          	addi	a1,s0,-104
    117e:	00003097          	auipc	ra,0x3
    1182:	7b8080e7          	jalr	1976(ra) # 4936 <read>
      close(fd);
    1186:	8526                	mv	a0,s1
    1188:	00003097          	auipc	ra,0x3
    118c:	7be080e7          	jalr	1982(ra) # 4946 <close>
    for(int i = 0; i < 100; i++){
    1190:	39fd                	addiw	s3,s3,-1
    1192:	fa0994e3          	bnez	s3,113a <truncate3+0x52>
    exit(0);
    1196:	4501                	li	a0,0
    1198:	00003097          	auipc	ra,0x3
    119c:	786080e7          	jalr	1926(ra) # 491e <exit>
    11a0:	eca6                	sd	s1,88(sp)
    11a2:	e4ce                	sd	s3,72(sp)
    11a4:	e0d2                	sd	s4,64(sp)
    11a6:	fc56                	sd	s5,56(sp)
    printf("%s: fork failed\n", s);
    11a8:	85ca                	mv	a1,s2
    11aa:	00004517          	auipc	a0,0x4
    11ae:	3be50513          	addi	a0,a0,958 # 5568 <malloc+0x802>
    11b2:	00004097          	auipc	ra,0x4
    11b6:	afc080e7          	jalr	-1284(ra) # 4cae <printf>
    exit(1);
    11ba:	4505                	li	a0,1
    11bc:	00003097          	auipc	ra,0x3
    11c0:	762080e7          	jalr	1890(ra) # 491e <exit>
        printf("%s: open failed\n", s);
    11c4:	85ca                	mv	a1,s2
    11c6:	00004517          	auipc	a0,0x4
    11ca:	3ba50513          	addi	a0,a0,954 # 5580 <malloc+0x81a>
    11ce:	00004097          	auipc	ra,0x4
    11d2:	ae0080e7          	jalr	-1312(ra) # 4cae <printf>
        exit(1);
    11d6:	4505                	li	a0,1
    11d8:	00003097          	auipc	ra,0x3
    11dc:	746080e7          	jalr	1862(ra) # 491e <exit>
        printf("%s: write got %d, expected 10\n", s, n);
    11e0:	862a                	mv	a2,a0
    11e2:	85ca                	mv	a1,s2
    11e4:	00004517          	auipc	a0,0x4
    11e8:	3c450513          	addi	a0,a0,964 # 55a8 <malloc+0x842>
    11ec:	00004097          	auipc	ra,0x4
    11f0:	ac2080e7          	jalr	-1342(ra) # 4cae <printf>
        exit(1);
    11f4:	4505                	li	a0,1
    11f6:	00003097          	auipc	ra,0x3
    11fa:	728080e7          	jalr	1832(ra) # 491e <exit>
    11fe:	eca6                	sd	s1,88(sp)
    1200:	e4ce                	sd	s3,72(sp)
    1202:	e0d2                	sd	s4,64(sp)
    1204:	fc56                	sd	s5,56(sp)
    1206:	09600993          	li	s3,150
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    120a:	00004a17          	auipc	s4,0x4
    120e:	d26a0a13          	addi	s4,s4,-730 # 4f30 <malloc+0x1ca>
    int n = write(fd, "xxx", 3);
    1212:	00004a97          	auipc	s5,0x4
    1216:	3b6a8a93          	addi	s5,s5,950 # 55c8 <malloc+0x862>
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    121a:	60100593          	li	a1,1537
    121e:	8552                	mv	a0,s4
    1220:	00003097          	auipc	ra,0x3
    1224:	73e080e7          	jalr	1854(ra) # 495e <open>
    1228:	84aa                	mv	s1,a0
    if(fd < 0){
    122a:	04054763          	bltz	a0,1278 <truncate3+0x190>
    int n = write(fd, "xxx", 3);
    122e:	460d                	li	a2,3
    1230:	85d6                	mv	a1,s5
    1232:	00003097          	auipc	ra,0x3
    1236:	70c080e7          	jalr	1804(ra) # 493e <write>
    if(n != 3){
    123a:	478d                	li	a5,3
    123c:	04f51c63          	bne	a0,a5,1294 <truncate3+0x1ac>
    close(fd);
    1240:	8526                	mv	a0,s1
    1242:	00003097          	auipc	ra,0x3
    1246:	704080e7          	jalr	1796(ra) # 4946 <close>
  for(int i = 0; i < 150; i++){
    124a:	39fd                	addiw	s3,s3,-1
    124c:	fc0997e3          	bnez	s3,121a <truncate3+0x132>
  wait(&xstatus);
    1250:	fbc40513          	addi	a0,s0,-68
    1254:	00003097          	auipc	ra,0x3
    1258:	6d2080e7          	jalr	1746(ra) # 4926 <wait>
  remove("truncfile");
    125c:	00004517          	auipc	a0,0x4
    1260:	cd450513          	addi	a0,a0,-812 # 4f30 <malloc+0x1ca>
    1264:	00003097          	auipc	ra,0x3
    1268:	762080e7          	jalr	1890(ra) # 49c6 <remove>
  exit(xstatus);
    126c:	fbc42503          	lw	a0,-68(s0)
    1270:	00003097          	auipc	ra,0x3
    1274:	6ae080e7          	jalr	1710(ra) # 491e <exit>
      printf("%s: open failed\n", s);
    1278:	85ca                	mv	a1,s2
    127a:	00004517          	auipc	a0,0x4
    127e:	30650513          	addi	a0,a0,774 # 5580 <malloc+0x81a>
    1282:	00004097          	auipc	ra,0x4
    1286:	a2c080e7          	jalr	-1492(ra) # 4cae <printf>
      exit(1);
    128a:	4505                	li	a0,1
    128c:	00003097          	auipc	ra,0x3
    1290:	692080e7          	jalr	1682(ra) # 491e <exit>
      printf("%s: write got %d, expected 3\n", s, n);
    1294:	862a                	mv	a2,a0
    1296:	85ca                	mv	a1,s2
    1298:	00004517          	auipc	a0,0x4
    129c:	33850513          	addi	a0,a0,824 # 55d0 <malloc+0x86a>
    12a0:	00004097          	auipc	ra,0x4
    12a4:	a0e080e7          	jalr	-1522(ra) # 4cae <printf>
      exit(1);
    12a8:	4505                	li	a0,1
    12aa:	00003097          	auipc	ra,0x3
    12ae:	674080e7          	jalr	1652(ra) # 491e <exit>

00000000000012b2 <exectest>:
{
    12b2:	715d                	addi	sp,sp,-80
    12b4:	e486                	sd	ra,72(sp)
    12b6:	e0a2                	sd	s0,64(sp)
    12b8:	f84a                	sd	s2,48(sp)
    12ba:	0880                	addi	s0,sp,80
    12bc:	892a                	mv	s2,a0
  char *echoargv[] = { "echo", "OK", 0 };
    12be:	00004797          	auipc	a5,0x4
    12c2:	c1a78793          	addi	a5,a5,-998 # 4ed8 <malloc+0x172>
    12c6:	fcf43023          	sd	a5,-64(s0)
    12ca:	00004797          	auipc	a5,0x4
    12ce:	32678793          	addi	a5,a5,806 # 55f0 <malloc+0x88a>
    12d2:	fcf43423          	sd	a5,-56(s0)
    12d6:	fc043823          	sd	zero,-48(s0)
  remove("echo-ok");
    12da:	00004517          	auipc	a0,0x4
    12de:	31e50513          	addi	a0,a0,798 # 55f8 <malloc+0x892>
    12e2:	00003097          	auipc	ra,0x3
    12e6:	6e4080e7          	jalr	1764(ra) # 49c6 <remove>
  pid = fork();
    12ea:	00003097          	auipc	ra,0x3
    12ee:	62c080e7          	jalr	1580(ra) # 4916 <fork>
  if(pid < 0) {
    12f2:	04054763          	bltz	a0,1340 <exectest+0x8e>
    12f6:	fc26                	sd	s1,56(sp)
    12f8:	84aa                	mv	s1,a0
  if(pid == 0) {
    12fa:	ed41                	bnez	a0,1392 <exectest+0xe0>
    close(1);
    12fc:	4505                	li	a0,1
    12fe:	00003097          	auipc	ra,0x3
    1302:	648080e7          	jalr	1608(ra) # 4946 <close>
    fd = open("echo-ok", O_CREATE|O_WRONLY);
    1306:	20100593          	li	a1,513
    130a:	00004517          	auipc	a0,0x4
    130e:	2ee50513          	addi	a0,a0,750 # 55f8 <malloc+0x892>
    1312:	00003097          	auipc	ra,0x3
    1316:	64c080e7          	jalr	1612(ra) # 495e <open>
    if(fd < 0) {
    131a:	04054263          	bltz	a0,135e <exectest+0xac>
    if(fd != 1) {
    131e:	4785                	li	a5,1
    1320:	04f50d63          	beq	a0,a5,137a <exectest+0xc8>
      printf("%s: wrong fd\n", s);
    1324:	85ca                	mv	a1,s2
    1326:	00004517          	auipc	a0,0x4
    132a:	2f250513          	addi	a0,a0,754 # 5618 <malloc+0x8b2>
    132e:	00004097          	auipc	ra,0x4
    1332:	980080e7          	jalr	-1664(ra) # 4cae <printf>
      exit(1);
    1336:	4505                	li	a0,1
    1338:	00003097          	auipc	ra,0x3
    133c:	5e6080e7          	jalr	1510(ra) # 491e <exit>
    1340:	fc26                	sd	s1,56(sp)
     printf("%s: fork failed\n", s);
    1342:	85ca                	mv	a1,s2
    1344:	00004517          	auipc	a0,0x4
    1348:	22450513          	addi	a0,a0,548 # 5568 <malloc+0x802>
    134c:	00004097          	auipc	ra,0x4
    1350:	962080e7          	jalr	-1694(ra) # 4cae <printf>
     exit(1);
    1354:	4505                	li	a0,1
    1356:	00003097          	auipc	ra,0x3
    135a:	5c8080e7          	jalr	1480(ra) # 491e <exit>
      printf("%s: create failed\n", s);
    135e:	85ca                	mv	a1,s2
    1360:	00004517          	auipc	a0,0x4
    1364:	2a050513          	addi	a0,a0,672 # 5600 <malloc+0x89a>
    1368:	00004097          	auipc	ra,0x4
    136c:	946080e7          	jalr	-1722(ra) # 4cae <printf>
      exit(1);
    1370:	4505                	li	a0,1
    1372:	00003097          	auipc	ra,0x3
    1376:	5ac080e7          	jalr	1452(ra) # 491e <exit>
    if(exec("echo", echoargv) < 0){
    137a:	fc040593          	addi	a1,s0,-64
    137e:	00004517          	auipc	a0,0x4
    1382:	b5a50513          	addi	a0,a0,-1190 # 4ed8 <malloc+0x172>
    1386:	00003097          	auipc	ra,0x3
    138a:	5d0080e7          	jalr	1488(ra) # 4956 <exec>
    138e:	02054163          	bltz	a0,13b0 <exectest+0xfe>
  if (wait(&xstatus) != pid) {
    1392:	fdc40513          	addi	a0,s0,-36
    1396:	00003097          	auipc	ra,0x3
    139a:	590080e7          	jalr	1424(ra) # 4926 <wait>
    139e:	02951763          	bne	a0,s1,13cc <exectest+0x11a>
  if(xstatus != 0)
    13a2:	fdc42503          	lw	a0,-36(s0)
    13a6:	cd0d                	beqz	a0,13e0 <exectest+0x12e>
    exit(xstatus);
    13a8:	00003097          	auipc	ra,0x3
    13ac:	576080e7          	jalr	1398(ra) # 491e <exit>
      printf("%s: exec echo failed\n", s);
    13b0:	85ca                	mv	a1,s2
    13b2:	00004517          	auipc	a0,0x4
    13b6:	27650513          	addi	a0,a0,630 # 5628 <malloc+0x8c2>
    13ba:	00004097          	auipc	ra,0x4
    13be:	8f4080e7          	jalr	-1804(ra) # 4cae <printf>
      exit(1);
    13c2:	4505                	li	a0,1
    13c4:	00003097          	auipc	ra,0x3
    13c8:	55a080e7          	jalr	1370(ra) # 491e <exit>
    printf("%s: wait failed!\n", s);
    13cc:	85ca                	mv	a1,s2
    13ce:	00004517          	auipc	a0,0x4
    13d2:	27250513          	addi	a0,a0,626 # 5640 <malloc+0x8da>
    13d6:	00004097          	auipc	ra,0x4
    13da:	8d8080e7          	jalr	-1832(ra) # 4cae <printf>
    13de:	b7d1                	j	13a2 <exectest+0xf0>
  fd = open("echo-ok", O_RDONLY);
    13e0:	4581                	li	a1,0
    13e2:	00004517          	auipc	a0,0x4
    13e6:	21650513          	addi	a0,a0,534 # 55f8 <malloc+0x892>
    13ea:	00003097          	auipc	ra,0x3
    13ee:	574080e7          	jalr	1396(ra) # 495e <open>
  if(fd < 0) {
    13f2:	02054a63          	bltz	a0,1426 <exectest+0x174>
  if (read(fd, buf, 2) != 2) {
    13f6:	4609                	li	a2,2
    13f8:	fb840593          	addi	a1,s0,-72
    13fc:	00003097          	auipc	ra,0x3
    1400:	53a080e7          	jalr	1338(ra) # 4936 <read>
    1404:	4789                	li	a5,2
    1406:	02f50e63          	beq	a0,a5,1442 <exectest+0x190>
    printf("%s: read failed\n", s);
    140a:	85ca                	mv	a1,s2
    140c:	00004517          	auipc	a0,0x4
    1410:	e9c50513          	addi	a0,a0,-356 # 52a8 <malloc+0x542>
    1414:	00004097          	auipc	ra,0x4
    1418:	89a080e7          	jalr	-1894(ra) # 4cae <printf>
    exit(1);
    141c:	4505                	li	a0,1
    141e:	00003097          	auipc	ra,0x3
    1422:	500080e7          	jalr	1280(ra) # 491e <exit>
    printf("%s: open failed\n", s);
    1426:	85ca                	mv	a1,s2
    1428:	00004517          	auipc	a0,0x4
    142c:	15850513          	addi	a0,a0,344 # 5580 <malloc+0x81a>
    1430:	00004097          	auipc	ra,0x4
    1434:	87e080e7          	jalr	-1922(ra) # 4cae <printf>
    exit(1);
    1438:	4505                	li	a0,1
    143a:	00003097          	auipc	ra,0x3
    143e:	4e4080e7          	jalr	1252(ra) # 491e <exit>
  remove("echo-ok");
    1442:	00004517          	auipc	a0,0x4
    1446:	1b650513          	addi	a0,a0,438 # 55f8 <malloc+0x892>
    144a:	00003097          	auipc	ra,0x3
    144e:	57c080e7          	jalr	1404(ra) # 49c6 <remove>
  if(buf[0] == 'O' && buf[1] == 'K')
    1452:	fb844703          	lbu	a4,-72(s0)
    1456:	04f00793          	li	a5,79
    145a:	00f71863          	bne	a4,a5,146a <exectest+0x1b8>
    145e:	fb944703          	lbu	a4,-71(s0)
    1462:	04b00793          	li	a5,75
    1466:	02f70063          	beq	a4,a5,1486 <exectest+0x1d4>
    printf("%s: wrong output\n", s);
    146a:	85ca                	mv	a1,s2
    146c:	00004517          	auipc	a0,0x4
    1470:	1ec50513          	addi	a0,a0,492 # 5658 <malloc+0x8f2>
    1474:	00004097          	auipc	ra,0x4
    1478:	83a080e7          	jalr	-1990(ra) # 4cae <printf>
    exit(1);
    147c:	4505                	li	a0,1
    147e:	00003097          	auipc	ra,0x3
    1482:	4a0080e7          	jalr	1184(ra) # 491e <exit>
    exit(0);
    1486:	4501                	li	a0,0
    1488:	00003097          	auipc	ra,0x3
    148c:	496080e7          	jalr	1174(ra) # 491e <exit>

0000000000001490 <pipe1>:
{
    1490:	711d                	addi	sp,sp,-96
    1492:	ec86                	sd	ra,88(sp)
    1494:	e8a2                	sd	s0,80(sp)
    1496:	fc4e                	sd	s3,56(sp)
    1498:	1080                	addi	s0,sp,96
    149a:	89aa                	mv	s3,a0
  if(pipe(fds) != 0){
    149c:	fa840513          	addi	a0,s0,-88
    14a0:	00003097          	auipc	ra,0x3
    14a4:	48e080e7          	jalr	1166(ra) # 492e <pipe>
    14a8:	e149                	bnez	a0,152a <pipe1+0x9a>
    14aa:	e4a6                	sd	s1,72(sp)
    14ac:	f852                	sd	s4,48(sp)
    14ae:	84aa                	mv	s1,a0
  pid = fork();
    14b0:	00003097          	auipc	ra,0x3
    14b4:	466080e7          	jalr	1126(ra) # 4916 <fork>
    14b8:	8a2a                	mv	s4,a0
  if(pid == 0){
    14ba:	cd41                	beqz	a0,1552 <pipe1+0xc2>
  } else if(pid > 0){
    14bc:	18a05d63          	blez	a0,1656 <pipe1+0x1c6>
    14c0:	e0ca                	sd	s2,64(sp)
    14c2:	f456                	sd	s5,40(sp)
    close(fds[1]);
    14c4:	fac42503          	lw	a0,-84(s0)
    14c8:	00003097          	auipc	ra,0x3
    14cc:	47e080e7          	jalr	1150(ra) # 4946 <close>
    total = 0;
    14d0:	8a26                	mv	s4,s1
    cc = 1;
    14d2:	4905                	li	s2,1
    while((n = read(fds[0], buf, cc)) > 0){
    14d4:	00009a97          	auipc	s5,0x9
    14d8:	3bca8a93          	addi	s5,s5,956 # a890 <buf>
    14dc:	864a                	mv	a2,s2
    14de:	85d6                	mv	a1,s5
    14e0:	fa842503          	lw	a0,-88(s0)
    14e4:	00003097          	auipc	ra,0x3
    14e8:	452080e7          	jalr	1106(ra) # 4936 <read>
    14ec:	10a05c63          	blez	a0,1604 <pipe1+0x174>
      for(i = 0; i < n; i++){
    14f0:	00009717          	auipc	a4,0x9
    14f4:	3a070713          	addi	a4,a4,928 # a890 <buf>
    14f8:	00a4863b          	addw	a2,s1,a0
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    14fc:	00074683          	lbu	a3,0(a4)
    1500:	0ff4f793          	zext.b	a5,s1
    1504:	2485                	addiw	s1,s1,1
    1506:	0cf69d63          	bne	a3,a5,15e0 <pipe1+0x150>
      for(i = 0; i < n; i++){
    150a:	0705                	addi	a4,a4,1
    150c:	fec498e3          	bne	s1,a2,14fc <pipe1+0x6c>
      total += n;
    1510:	00aa0a3b          	addw	s4,s4,a0
      cc = cc * 2;
    1514:	0019179b          	slliw	a5,s2,0x1
    1518:	0007891b          	sext.w	s2,a5
      if(cc > sizeof(buf))
    151c:	6709                	lui	a4,0x2
    151e:	80070713          	addi	a4,a4,-2048 # 1800 <forkfork+0x38>
    1522:	fb277de3          	bgeu	a4,s2,14dc <pipe1+0x4c>
        cc = sizeof(buf);
    1526:	893a                	mv	s2,a4
    1528:	bf55                	j	14dc <pipe1+0x4c>
    152a:	e4a6                	sd	s1,72(sp)
    152c:	e0ca                	sd	s2,64(sp)
    152e:	f852                	sd	s4,48(sp)
    1530:	f456                	sd	s5,40(sp)
    1532:	f05a                	sd	s6,32(sp)
    1534:	ec5e                	sd	s7,24(sp)
    printf("%s: pipe() failed\n", s);
    1536:	85ce                	mv	a1,s3
    1538:	00004517          	auipc	a0,0x4
    153c:	13850513          	addi	a0,a0,312 # 5670 <malloc+0x90a>
    1540:	00003097          	auipc	ra,0x3
    1544:	76e080e7          	jalr	1902(ra) # 4cae <printf>
    exit(1);
    1548:	4505                	li	a0,1
    154a:	00003097          	auipc	ra,0x3
    154e:	3d4080e7          	jalr	980(ra) # 491e <exit>
    1552:	e0ca                	sd	s2,64(sp)
    1554:	f456                	sd	s5,40(sp)
    1556:	f05a                	sd	s6,32(sp)
    1558:	ec5e                	sd	s7,24(sp)
    close(fds[0]);
    155a:	fa842503          	lw	a0,-88(s0)
    155e:	00003097          	auipc	ra,0x3
    1562:	3e8080e7          	jalr	1000(ra) # 4946 <close>
    for(n = 0; n < N; n++){
    1566:	00009b17          	auipc	s6,0x9
    156a:	32ab0b13          	addi	s6,s6,810 # a890 <buf>
    156e:	416004bb          	negw	s1,s6
    1572:	0ff4f493          	zext.b	s1,s1
    1576:	409b0913          	addi	s2,s6,1033
      if(write(fds[1], buf, SZ) != SZ){
    157a:	8bda                	mv	s7,s6
    for(n = 0; n < N; n++){
    157c:	6a85                	lui	s5,0x1
    157e:	42da8a93          	addi	s5,s5,1069 # 142d <exectest+0x17b>
{
    1582:	87da                	mv	a5,s6
        buf[i] = seq++;
    1584:	0097873b          	addw	a4,a5,s1
    1588:	00e78023          	sb	a4,0(a5)
      for(i = 0; i < SZ; i++)
    158c:	0785                	addi	a5,a5,1
    158e:	ff279be3          	bne	a5,s2,1584 <pipe1+0xf4>
    1592:	409a0a1b          	addiw	s4,s4,1033
      if(write(fds[1], buf, SZ) != SZ){
    1596:	40900613          	li	a2,1033
    159a:	85de                	mv	a1,s7
    159c:	fac42503          	lw	a0,-84(s0)
    15a0:	00003097          	auipc	ra,0x3
    15a4:	39e080e7          	jalr	926(ra) # 493e <write>
    15a8:	40900793          	li	a5,1033
    15ac:	00f51c63          	bne	a0,a5,15c4 <pipe1+0x134>
    for(n = 0; n < N; n++){
    15b0:	24a5                	addiw	s1,s1,9
    15b2:	0ff4f493          	zext.b	s1,s1
    15b6:	fd5a16e3          	bne	s4,s5,1582 <pipe1+0xf2>
    exit(0);
    15ba:	4501                	li	a0,0
    15bc:	00003097          	auipc	ra,0x3
    15c0:	362080e7          	jalr	866(ra) # 491e <exit>
        printf("%s: pipe1 oops 1\n", s);
    15c4:	85ce                	mv	a1,s3
    15c6:	00004517          	auipc	a0,0x4
    15ca:	0c250513          	addi	a0,a0,194 # 5688 <malloc+0x922>
    15ce:	00003097          	auipc	ra,0x3
    15d2:	6e0080e7          	jalr	1760(ra) # 4cae <printf>
        exit(1);
    15d6:	4505                	li	a0,1
    15d8:	00003097          	auipc	ra,0x3
    15dc:	346080e7          	jalr	838(ra) # 491e <exit>
          printf("%s: pipe1 oops 2\n", s);
    15e0:	85ce                	mv	a1,s3
    15e2:	00004517          	auipc	a0,0x4
    15e6:	0be50513          	addi	a0,a0,190 # 56a0 <malloc+0x93a>
    15ea:	00003097          	auipc	ra,0x3
    15ee:	6c4080e7          	jalr	1732(ra) # 4cae <printf>
          return;
    15f2:	64a6                	ld	s1,72(sp)
    15f4:	6906                	ld	s2,64(sp)
    15f6:	7a42                	ld	s4,48(sp)
    15f8:	7aa2                	ld	s5,40(sp)
}
    15fa:	60e6                	ld	ra,88(sp)
    15fc:	6446                	ld	s0,80(sp)
    15fe:	79e2                	ld	s3,56(sp)
    1600:	6125                	addi	sp,sp,96
    1602:	8082                	ret
    if(total != N * SZ){
    1604:	6785                	lui	a5,0x1
    1606:	42d78793          	addi	a5,a5,1069 # 142d <exectest+0x17b>
    160a:	02fa0263          	beq	s4,a5,162e <pipe1+0x19e>
    160e:	f05a                	sd	s6,32(sp)
    1610:	ec5e                	sd	s7,24(sp)
      printf("%s: pipe1 oops 3 total %d\n", total);
    1612:	85d2                	mv	a1,s4
    1614:	00004517          	auipc	a0,0x4
    1618:	0a450513          	addi	a0,a0,164 # 56b8 <malloc+0x952>
    161c:	00003097          	auipc	ra,0x3
    1620:	692080e7          	jalr	1682(ra) # 4cae <printf>
      exit(1);
    1624:	4505                	li	a0,1
    1626:	00003097          	auipc	ra,0x3
    162a:	2f8080e7          	jalr	760(ra) # 491e <exit>
    162e:	f05a                	sd	s6,32(sp)
    1630:	ec5e                	sd	s7,24(sp)
    close(fds[0]);
    1632:	fa842503          	lw	a0,-88(s0)
    1636:	00003097          	auipc	ra,0x3
    163a:	310080e7          	jalr	784(ra) # 4946 <close>
    wait(&xstatus);
    163e:	fa440513          	addi	a0,s0,-92
    1642:	00003097          	auipc	ra,0x3
    1646:	2e4080e7          	jalr	740(ra) # 4926 <wait>
    exit(xstatus);
    164a:	fa442503          	lw	a0,-92(s0)
    164e:	00003097          	auipc	ra,0x3
    1652:	2d0080e7          	jalr	720(ra) # 491e <exit>
    1656:	e0ca                	sd	s2,64(sp)
    1658:	f456                	sd	s5,40(sp)
    165a:	f05a                	sd	s6,32(sp)
    165c:	ec5e                	sd	s7,24(sp)
    printf("%s: fork() failed\n", s);
    165e:	85ce                	mv	a1,s3
    1660:	00004517          	auipc	a0,0x4
    1664:	07850513          	addi	a0,a0,120 # 56d8 <malloc+0x972>
    1668:	00003097          	auipc	ra,0x3
    166c:	646080e7          	jalr	1606(ra) # 4cae <printf>
    exit(1);
    1670:	4505                	li	a0,1
    1672:	00003097          	auipc	ra,0x3
    1676:	2ac080e7          	jalr	684(ra) # 491e <exit>

000000000000167a <exitwait>:
{
    167a:	7139                	addi	sp,sp,-64
    167c:	fc06                	sd	ra,56(sp)
    167e:	f822                	sd	s0,48(sp)
    1680:	f426                	sd	s1,40(sp)
    1682:	f04a                	sd	s2,32(sp)
    1684:	ec4e                	sd	s3,24(sp)
    1686:	e852                	sd	s4,16(sp)
    1688:	0080                	addi	s0,sp,64
    168a:	8a2a                	mv	s4,a0
  for(i = 0; i < 100; i++){
    168c:	4901                	li	s2,0
    168e:	06400993          	li	s3,100
    pid = fork();
    1692:	00003097          	auipc	ra,0x3
    1696:	284080e7          	jalr	644(ra) # 4916 <fork>
    169a:	84aa                	mv	s1,a0
    if(pid < 0){
    169c:	02054a63          	bltz	a0,16d0 <exitwait+0x56>
    if(pid){
    16a0:	c151                	beqz	a0,1724 <exitwait+0xaa>
      if(wait(&xstate) != pid){
    16a2:	fcc40513          	addi	a0,s0,-52
    16a6:	00003097          	auipc	ra,0x3
    16aa:	280080e7          	jalr	640(ra) # 4926 <wait>
    16ae:	02951f63          	bne	a0,s1,16ec <exitwait+0x72>
      if(i != xstate) {
    16b2:	fcc42783          	lw	a5,-52(s0)
    16b6:	05279963          	bne	a5,s2,1708 <exitwait+0x8e>
  for(i = 0; i < 100; i++){
    16ba:	2905                	addiw	s2,s2,1
    16bc:	fd391be3          	bne	s2,s3,1692 <exitwait+0x18>
}
    16c0:	70e2                	ld	ra,56(sp)
    16c2:	7442                	ld	s0,48(sp)
    16c4:	74a2                	ld	s1,40(sp)
    16c6:	7902                	ld	s2,32(sp)
    16c8:	69e2                	ld	s3,24(sp)
    16ca:	6a42                	ld	s4,16(sp)
    16cc:	6121                	addi	sp,sp,64
    16ce:	8082                	ret
      printf("%s: fork failed\n", s);
    16d0:	85d2                	mv	a1,s4
    16d2:	00004517          	auipc	a0,0x4
    16d6:	e9650513          	addi	a0,a0,-362 # 5568 <malloc+0x802>
    16da:	00003097          	auipc	ra,0x3
    16de:	5d4080e7          	jalr	1492(ra) # 4cae <printf>
      exit(1);
    16e2:	4505                	li	a0,1
    16e4:	00003097          	auipc	ra,0x3
    16e8:	23a080e7          	jalr	570(ra) # 491e <exit>
        printf("%s: wait wrong pid\n", s);
    16ec:	85d2                	mv	a1,s4
    16ee:	00004517          	auipc	a0,0x4
    16f2:	00250513          	addi	a0,a0,2 # 56f0 <malloc+0x98a>
    16f6:	00003097          	auipc	ra,0x3
    16fa:	5b8080e7          	jalr	1464(ra) # 4cae <printf>
        exit(1);
    16fe:	4505                	li	a0,1
    1700:	00003097          	auipc	ra,0x3
    1704:	21e080e7          	jalr	542(ra) # 491e <exit>
        printf("%s: wait wrong exit status\n", s);
    1708:	85d2                	mv	a1,s4
    170a:	00004517          	auipc	a0,0x4
    170e:	ffe50513          	addi	a0,a0,-2 # 5708 <malloc+0x9a2>
    1712:	00003097          	auipc	ra,0x3
    1716:	59c080e7          	jalr	1436(ra) # 4cae <printf>
        exit(1);
    171a:	4505                	li	a0,1
    171c:	00003097          	auipc	ra,0x3
    1720:	202080e7          	jalr	514(ra) # 491e <exit>
      exit(i);
    1724:	854a                	mv	a0,s2
    1726:	00003097          	auipc	ra,0x3
    172a:	1f8080e7          	jalr	504(ra) # 491e <exit>

000000000000172e <twochildren>:
{
    172e:	1101                	addi	sp,sp,-32
    1730:	ec06                	sd	ra,24(sp)
    1732:	e822                	sd	s0,16(sp)
    1734:	e426                	sd	s1,8(sp)
    1736:	e04a                	sd	s2,0(sp)
    1738:	1000                	addi	s0,sp,32
    173a:	892a                	mv	s2,a0
    173c:	3e800493          	li	s1,1000
    int pid1 = fork();
    1740:	00003097          	auipc	ra,0x3
    1744:	1d6080e7          	jalr	470(ra) # 4916 <fork>
    if(pid1 < 0){
    1748:	02054c63          	bltz	a0,1780 <twochildren+0x52>
    if(pid1 == 0){
    174c:	c921                	beqz	a0,179c <twochildren+0x6e>
      int pid2 = fork();
    174e:	00003097          	auipc	ra,0x3
    1752:	1c8080e7          	jalr	456(ra) # 4916 <fork>
      if(pid2 < 0){
    1756:	04054763          	bltz	a0,17a4 <twochildren+0x76>
      if(pid2 == 0){
    175a:	c13d                	beqz	a0,17c0 <twochildren+0x92>
        wait(0);
    175c:	4501                	li	a0,0
    175e:	00003097          	auipc	ra,0x3
    1762:	1c8080e7          	jalr	456(ra) # 4926 <wait>
        wait(0);
    1766:	4501                	li	a0,0
    1768:	00003097          	auipc	ra,0x3
    176c:	1be080e7          	jalr	446(ra) # 4926 <wait>
  for(int i = 0; i < 1000; i++){
    1770:	34fd                	addiw	s1,s1,-1
    1772:	f4f9                	bnez	s1,1740 <twochildren+0x12>
}
    1774:	60e2                	ld	ra,24(sp)
    1776:	6442                	ld	s0,16(sp)
    1778:	64a2                	ld	s1,8(sp)
    177a:	6902                	ld	s2,0(sp)
    177c:	6105                	addi	sp,sp,32
    177e:	8082                	ret
      printf("%s: fork failed\n", s);
    1780:	85ca                	mv	a1,s2
    1782:	00004517          	auipc	a0,0x4
    1786:	de650513          	addi	a0,a0,-538 # 5568 <malloc+0x802>
    178a:	00003097          	auipc	ra,0x3
    178e:	524080e7          	jalr	1316(ra) # 4cae <printf>
      exit(1);
    1792:	4505                	li	a0,1
    1794:	00003097          	auipc	ra,0x3
    1798:	18a080e7          	jalr	394(ra) # 491e <exit>
      exit(0);
    179c:	00003097          	auipc	ra,0x3
    17a0:	182080e7          	jalr	386(ra) # 491e <exit>
        printf("%s: fork failed\n", s);
    17a4:	85ca                	mv	a1,s2
    17a6:	00004517          	auipc	a0,0x4
    17aa:	dc250513          	addi	a0,a0,-574 # 5568 <malloc+0x802>
    17ae:	00003097          	auipc	ra,0x3
    17b2:	500080e7          	jalr	1280(ra) # 4cae <printf>
        exit(1);
    17b6:	4505                	li	a0,1
    17b8:	00003097          	auipc	ra,0x3
    17bc:	166080e7          	jalr	358(ra) # 491e <exit>
        exit(0);
    17c0:	00003097          	auipc	ra,0x3
    17c4:	15e080e7          	jalr	350(ra) # 491e <exit>

00000000000017c8 <forkfork>:
{
    17c8:	7179                	addi	sp,sp,-48
    17ca:	f406                	sd	ra,40(sp)
    17cc:	f022                	sd	s0,32(sp)
    17ce:	ec26                	sd	s1,24(sp)
    17d0:	1800                	addi	s0,sp,48
    17d2:	84aa                	mv	s1,a0
    int pid = fork();
    17d4:	00003097          	auipc	ra,0x3
    17d8:	142080e7          	jalr	322(ra) # 4916 <fork>
    if(pid < 0){
    17dc:	04054163          	bltz	a0,181e <forkfork+0x56>
    if(pid == 0){
    17e0:	cd29                	beqz	a0,183a <forkfork+0x72>
    int pid = fork();
    17e2:	00003097          	auipc	ra,0x3
    17e6:	134080e7          	jalr	308(ra) # 4916 <fork>
    if(pid < 0){
    17ea:	02054a63          	bltz	a0,181e <forkfork+0x56>
    if(pid == 0){
    17ee:	c531                	beqz	a0,183a <forkfork+0x72>
    wait(&xstatus);
    17f0:	fdc40513          	addi	a0,s0,-36
    17f4:	00003097          	auipc	ra,0x3
    17f8:	132080e7          	jalr	306(ra) # 4926 <wait>
    if(xstatus != 0) {
    17fc:	fdc42783          	lw	a5,-36(s0)
    1800:	ebbd                	bnez	a5,1876 <forkfork+0xae>
    wait(&xstatus);
    1802:	fdc40513          	addi	a0,s0,-36
    1806:	00003097          	auipc	ra,0x3
    180a:	120080e7          	jalr	288(ra) # 4926 <wait>
    if(xstatus != 0) {
    180e:	fdc42783          	lw	a5,-36(s0)
    1812:	e3b5                	bnez	a5,1876 <forkfork+0xae>
}
    1814:	70a2                	ld	ra,40(sp)
    1816:	7402                	ld	s0,32(sp)
    1818:	64e2                	ld	s1,24(sp)
    181a:	6145                	addi	sp,sp,48
    181c:	8082                	ret
      printf("%s: fork failed", s);
    181e:	85a6                	mv	a1,s1
    1820:	00004517          	auipc	a0,0x4
    1824:	f0850513          	addi	a0,a0,-248 # 5728 <malloc+0x9c2>
    1828:	00003097          	auipc	ra,0x3
    182c:	486080e7          	jalr	1158(ra) # 4cae <printf>
      exit(1);
    1830:	4505                	li	a0,1
    1832:	00003097          	auipc	ra,0x3
    1836:	0ec080e7          	jalr	236(ra) # 491e <exit>
{
    183a:	0c800493          	li	s1,200
        int pid1 = fork();
    183e:	00003097          	auipc	ra,0x3
    1842:	0d8080e7          	jalr	216(ra) # 4916 <fork>
        if(pid1 < 0){
    1846:	00054f63          	bltz	a0,1864 <forkfork+0x9c>
        if(pid1 == 0){
    184a:	c115                	beqz	a0,186e <forkfork+0xa6>
        wait(0);
    184c:	4501                	li	a0,0
    184e:	00003097          	auipc	ra,0x3
    1852:	0d8080e7          	jalr	216(ra) # 4926 <wait>
      for(int j = 0; j < 200; j++){
    1856:	34fd                	addiw	s1,s1,-1
    1858:	f0fd                	bnez	s1,183e <forkfork+0x76>
      exit(0);
    185a:	4501                	li	a0,0
    185c:	00003097          	auipc	ra,0x3
    1860:	0c2080e7          	jalr	194(ra) # 491e <exit>
          exit(1);
    1864:	4505                	li	a0,1
    1866:	00003097          	auipc	ra,0x3
    186a:	0b8080e7          	jalr	184(ra) # 491e <exit>
          exit(0);
    186e:	00003097          	auipc	ra,0x3
    1872:	0b0080e7          	jalr	176(ra) # 491e <exit>
      printf("%s: fork in child failed", s);
    1876:	85a6                	mv	a1,s1
    1878:	00004517          	auipc	a0,0x4
    187c:	ec050513          	addi	a0,a0,-320 # 5738 <malloc+0x9d2>
    1880:	00003097          	auipc	ra,0x3
    1884:	42e080e7          	jalr	1070(ra) # 4cae <printf>
      exit(1);
    1888:	4505                	li	a0,1
    188a:	00003097          	auipc	ra,0x3
    188e:	094080e7          	jalr	148(ra) # 491e <exit>

0000000000001892 <reparent2>:
{
    1892:	1101                	addi	sp,sp,-32
    1894:	ec06                	sd	ra,24(sp)
    1896:	e822                	sd	s0,16(sp)
    1898:	e426                	sd	s1,8(sp)
    189a:	1000                	addi	s0,sp,32
    189c:	32000493          	li	s1,800
    int pid1 = fork();
    18a0:	00003097          	auipc	ra,0x3
    18a4:	076080e7          	jalr	118(ra) # 4916 <fork>
    if(pid1 < 0){
    18a8:	00054f63          	bltz	a0,18c6 <reparent2+0x34>
    if(pid1 == 0){
    18ac:	c915                	beqz	a0,18e0 <reparent2+0x4e>
    wait(0);
    18ae:	4501                	li	a0,0
    18b0:	00003097          	auipc	ra,0x3
    18b4:	076080e7          	jalr	118(ra) # 4926 <wait>
  for(int i = 0; i < 800; i++){
    18b8:	34fd                	addiw	s1,s1,-1
    18ba:	f0fd                	bnez	s1,18a0 <reparent2+0xe>
  exit(0);
    18bc:	4501                	li	a0,0
    18be:	00003097          	auipc	ra,0x3
    18c2:	060080e7          	jalr	96(ra) # 491e <exit>
      printf("fork failed\n");
    18c6:	00004517          	auipc	a0,0x4
    18ca:	02250513          	addi	a0,a0,34 # 58e8 <malloc+0xb82>
    18ce:	00003097          	auipc	ra,0x3
    18d2:	3e0080e7          	jalr	992(ra) # 4cae <printf>
      exit(1);
    18d6:	4505                	li	a0,1
    18d8:	00003097          	auipc	ra,0x3
    18dc:	046080e7          	jalr	70(ra) # 491e <exit>
      fork();
    18e0:	00003097          	auipc	ra,0x3
    18e4:	036080e7          	jalr	54(ra) # 4916 <fork>
      fork();
    18e8:	00003097          	auipc	ra,0x3
    18ec:	02e080e7          	jalr	46(ra) # 4916 <fork>
      exit(0);
    18f0:	4501                	li	a0,0
    18f2:	00003097          	auipc	ra,0x3
    18f6:	02c080e7          	jalr	44(ra) # 491e <exit>

00000000000018fa <forktest>:
{
    18fa:	7179                	addi	sp,sp,-48
    18fc:	f406                	sd	ra,40(sp)
    18fe:	f022                	sd	s0,32(sp)
    1900:	ec26                	sd	s1,24(sp)
    1902:	e84a                	sd	s2,16(sp)
    1904:	e44e                	sd	s3,8(sp)
    1906:	1800                	addi	s0,sp,48
    1908:	89aa                	mv	s3,a0
  for(n=0; n<N; n++){
    190a:	4481                	li	s1,0
    190c:	3e800913          	li	s2,1000
    pid = fork();
    1910:	00003097          	auipc	ra,0x3
    1914:	006080e7          	jalr	6(ra) # 4916 <fork>
    if(pid < 0)
    1918:	08054263          	bltz	a0,199c <forktest+0xa2>
    if(pid == 0)
    191c:	c115                	beqz	a0,1940 <forktest+0x46>
  for(n=0; n<N; n++){
    191e:	2485                	addiw	s1,s1,1
    1920:	ff2498e3          	bne	s1,s2,1910 <forktest+0x16>
    printf("%s: fork claimed to work 1000 times!\n", s);
    1924:	85ce                	mv	a1,s3
    1926:	00004517          	auipc	a0,0x4
    192a:	e7a50513          	addi	a0,a0,-390 # 57a0 <malloc+0xa3a>
    192e:	00003097          	auipc	ra,0x3
    1932:	380080e7          	jalr	896(ra) # 4cae <printf>
    exit(1);
    1936:	4505                	li	a0,1
    1938:	00003097          	auipc	ra,0x3
    193c:	fe6080e7          	jalr	-26(ra) # 491e <exit>
      exit(0);
    1940:	00003097          	auipc	ra,0x3
    1944:	fde080e7          	jalr	-34(ra) # 491e <exit>
    printf("%s: no fork at all!\n", s);
    1948:	85ce                	mv	a1,s3
    194a:	00004517          	auipc	a0,0x4
    194e:	e0e50513          	addi	a0,a0,-498 # 5758 <malloc+0x9f2>
    1952:	00003097          	auipc	ra,0x3
    1956:	35c080e7          	jalr	860(ra) # 4cae <printf>
    exit(1);
    195a:	4505                	li	a0,1
    195c:	00003097          	auipc	ra,0x3
    1960:	fc2080e7          	jalr	-62(ra) # 491e <exit>
      printf("%s: wait stopped early\n", s);
    1964:	85ce                	mv	a1,s3
    1966:	00004517          	auipc	a0,0x4
    196a:	e0a50513          	addi	a0,a0,-502 # 5770 <malloc+0xa0a>
    196e:	00003097          	auipc	ra,0x3
    1972:	340080e7          	jalr	832(ra) # 4cae <printf>
      exit(1);
    1976:	4505                	li	a0,1
    1978:	00003097          	auipc	ra,0x3
    197c:	fa6080e7          	jalr	-90(ra) # 491e <exit>
    printf("%s: wait got too many\n", s);
    1980:	85ce                	mv	a1,s3
    1982:	00004517          	auipc	a0,0x4
    1986:	e0650513          	addi	a0,a0,-506 # 5788 <malloc+0xa22>
    198a:	00003097          	auipc	ra,0x3
    198e:	324080e7          	jalr	804(ra) # 4cae <printf>
    exit(1);
    1992:	4505                	li	a0,1
    1994:	00003097          	auipc	ra,0x3
    1998:	f8a080e7          	jalr	-118(ra) # 491e <exit>
  if (n == 0) {
    199c:	d4d5                	beqz	s1,1948 <forktest+0x4e>
  for(; n > 0; n--){
    199e:	00905b63          	blez	s1,19b4 <forktest+0xba>
    if(wait(0) < 0){
    19a2:	4501                	li	a0,0
    19a4:	00003097          	auipc	ra,0x3
    19a8:	f82080e7          	jalr	-126(ra) # 4926 <wait>
    19ac:	fa054ce3          	bltz	a0,1964 <forktest+0x6a>
  for(; n > 0; n--){
    19b0:	34fd                	addiw	s1,s1,-1
    19b2:	f8e5                	bnez	s1,19a2 <forktest+0xa8>
  if(wait(0) != -1){
    19b4:	4501                	li	a0,0
    19b6:	00003097          	auipc	ra,0x3
    19ba:	f70080e7          	jalr	-144(ra) # 4926 <wait>
    19be:	57fd                	li	a5,-1
    19c0:	fcf510e3          	bne	a0,a5,1980 <forktest+0x86>
}
    19c4:	70a2                	ld	ra,40(sp)
    19c6:	7402                	ld	s0,32(sp)
    19c8:	64e2                	ld	s1,24(sp)
    19ca:	6942                	ld	s2,16(sp)
    19cc:	69a2                	ld	s3,8(sp)
    19ce:	6145                	addi	sp,sp,48
    19d0:	8082                	ret

00000000000019d2 <kernmem>:
{
    19d2:	715d                	addi	sp,sp,-80
    19d4:	e486                	sd	ra,72(sp)
    19d6:	e0a2                	sd	s0,64(sp)
    19d8:	fc26                	sd	s1,56(sp)
    19da:	f84a                	sd	s2,48(sp)
    19dc:	f44e                	sd	s3,40(sp)
    19de:	f052                	sd	s4,32(sp)
    19e0:	ec56                	sd	s5,24(sp)
    19e2:	0880                	addi	s0,sp,80
    19e4:	8aaa                	mv	s5,a0
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    19e6:	40100493          	li	s1,1025
    19ea:	04d6                	slli	s1,s1,0x15
    if(xstatus != -1)  // did kernel kill child?
    19ec:	5a7d                	li	s4,-1
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    19ee:	69b1                	lui	s3,0xc
    19f0:	35098993          	addi	s3,s3,848 # c350 <__BSS_END__+0x2b0>
    19f4:	1007d937          	lui	s2,0x1007d
    19f8:	090e                	slli	s2,s2,0x3
    19fa:	48090913          	addi	s2,s2,1152 # 1007d480 <__BSS_END__+0x100713e0>
    pid = fork();
    19fe:	00003097          	auipc	ra,0x3
    1a02:	f18080e7          	jalr	-232(ra) # 4916 <fork>
    if(pid < 0){
    1a06:	02054963          	bltz	a0,1a38 <kernmem+0x66>
    if(pid == 0){
    1a0a:	c529                	beqz	a0,1a54 <kernmem+0x82>
    wait(&xstatus);
    1a0c:	fbc40513          	addi	a0,s0,-68
    1a10:	00003097          	auipc	ra,0x3
    1a14:	f16080e7          	jalr	-234(ra) # 4926 <wait>
    if(xstatus != -1)  // did kernel kill child?
    1a18:	fbc42783          	lw	a5,-68(s0)
    1a1c:	05479c63          	bne	a5,s4,1a74 <kernmem+0xa2>
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    1a20:	94ce                	add	s1,s1,s3
    1a22:	fd249ee3          	bne	s1,s2,19fe <kernmem+0x2c>
}
    1a26:	60a6                	ld	ra,72(sp)
    1a28:	6406                	ld	s0,64(sp)
    1a2a:	74e2                	ld	s1,56(sp)
    1a2c:	7942                	ld	s2,48(sp)
    1a2e:	79a2                	ld	s3,40(sp)
    1a30:	7a02                	ld	s4,32(sp)
    1a32:	6ae2                	ld	s5,24(sp)
    1a34:	6161                	addi	sp,sp,80
    1a36:	8082                	ret
      printf("%s: fork failed\n", s);
    1a38:	85d6                	mv	a1,s5
    1a3a:	00004517          	auipc	a0,0x4
    1a3e:	b2e50513          	addi	a0,a0,-1234 # 5568 <malloc+0x802>
    1a42:	00003097          	auipc	ra,0x3
    1a46:	26c080e7          	jalr	620(ra) # 4cae <printf>
      exit(1);
    1a4a:	4505                	li	a0,1
    1a4c:	00003097          	auipc	ra,0x3
    1a50:	ed2080e7          	jalr	-302(ra) # 491e <exit>
      printf("%s: oops could read %x = %x\n", a, *a);
    1a54:	0004c603          	lbu	a2,0(s1)
    1a58:	85a6                	mv	a1,s1
    1a5a:	00004517          	auipc	a0,0x4
    1a5e:	d6e50513          	addi	a0,a0,-658 # 57c8 <malloc+0xa62>
    1a62:	00003097          	auipc	ra,0x3
    1a66:	24c080e7          	jalr	588(ra) # 4cae <printf>
      exit(1);
    1a6a:	4505                	li	a0,1
    1a6c:	00003097          	auipc	ra,0x3
    1a70:	eb2080e7          	jalr	-334(ra) # 491e <exit>
      exit(1);
    1a74:	4505                	li	a0,1
    1a76:	00003097          	auipc	ra,0x3
    1a7a:	ea8080e7          	jalr	-344(ra) # 491e <exit>

0000000000001a7e <bigargtest>:
{
    1a7e:	7179                	addi	sp,sp,-48
    1a80:	f406                	sd	ra,40(sp)
    1a82:	f022                	sd	s0,32(sp)
    1a84:	ec26                	sd	s1,24(sp)
    1a86:	1800                	addi	s0,sp,48
    1a88:	84aa                	mv	s1,a0
  remove("bigarg-ok");
    1a8a:	00004517          	auipc	a0,0x4
    1a8e:	d5e50513          	addi	a0,a0,-674 # 57e8 <malloc+0xa82>
    1a92:	00003097          	auipc	ra,0x3
    1a96:	f34080e7          	jalr	-204(ra) # 49c6 <remove>
  pid = fork();
    1a9a:	00003097          	auipc	ra,0x3
    1a9e:	e7c080e7          	jalr	-388(ra) # 4916 <fork>
  if(pid == 0){
    1aa2:	c921                	beqz	a0,1af2 <bigargtest+0x74>
  } else if(pid < 0){
    1aa4:	0a054863          	bltz	a0,1b54 <bigargtest+0xd6>
  wait(&xstatus);
    1aa8:	fdc40513          	addi	a0,s0,-36
    1aac:	00003097          	auipc	ra,0x3
    1ab0:	e7a080e7          	jalr	-390(ra) # 4926 <wait>
  if(xstatus != 0)
    1ab4:	fdc42503          	lw	a0,-36(s0)
    1ab8:	ed45                	bnez	a0,1b70 <bigargtest+0xf2>
  fd = open("bigarg-ok", 0);
    1aba:	4581                	li	a1,0
    1abc:	00004517          	auipc	a0,0x4
    1ac0:	d2c50513          	addi	a0,a0,-724 # 57e8 <malloc+0xa82>
    1ac4:	00003097          	auipc	ra,0x3
    1ac8:	e9a080e7          	jalr	-358(ra) # 495e <open>
  if(fd < 0){
    1acc:	0a054663          	bltz	a0,1b78 <bigargtest+0xfa>
  close(fd);
    1ad0:	00003097          	auipc	ra,0x3
    1ad4:	e76080e7          	jalr	-394(ra) # 4946 <close>
  remove("bigarg-ok");
    1ad8:	00004517          	auipc	a0,0x4
    1adc:	d1050513          	addi	a0,a0,-752 # 57e8 <malloc+0xa82>
    1ae0:	00003097          	auipc	ra,0x3
    1ae4:	ee6080e7          	jalr	-282(ra) # 49c6 <remove>
}
    1ae8:	70a2                	ld	ra,40(sp)
    1aea:	7402                	ld	s0,32(sp)
    1aec:	64e2                	ld	s1,24(sp)
    1aee:	6145                	addi	sp,sp,48
    1af0:	8082                	ret
    1af2:	00005797          	auipc	a5,0x5
    1af6:	58678793          	addi	a5,a5,1414 # 7078 <args.1>
    1afa:	00005697          	auipc	a3,0x5
    1afe:	67668693          	addi	a3,a3,1654 # 7170 <args.1+0xf8>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    1b02:	00004717          	auipc	a4,0x4
    1b06:	cf670713          	addi	a4,a4,-778 # 57f8 <malloc+0xa92>
    1b0a:	e398                	sd	a4,0(a5)
    for(i = 0; i < MAXARG-1; i++)
    1b0c:	07a1                	addi	a5,a5,8
    1b0e:	fed79ee3          	bne	a5,a3,1b0a <bigargtest+0x8c>
    args[MAXARG-1] = 0;
    1b12:	00005597          	auipc	a1,0x5
    1b16:	56658593          	addi	a1,a1,1382 # 7078 <args.1>
    1b1a:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
    1b1e:	00003517          	auipc	a0,0x3
    1b22:	3ba50513          	addi	a0,a0,954 # 4ed8 <malloc+0x172>
    1b26:	00003097          	auipc	ra,0x3
    1b2a:	e30080e7          	jalr	-464(ra) # 4956 <exec>
    fd = open("bigarg-ok", O_CREATE);
    1b2e:	20000593          	li	a1,512
    1b32:	00004517          	auipc	a0,0x4
    1b36:	cb650513          	addi	a0,a0,-842 # 57e8 <malloc+0xa82>
    1b3a:	00003097          	auipc	ra,0x3
    1b3e:	e24080e7          	jalr	-476(ra) # 495e <open>
    close(fd);
    1b42:	00003097          	auipc	ra,0x3
    1b46:	e04080e7          	jalr	-508(ra) # 4946 <close>
    exit(0);
    1b4a:	4501                	li	a0,0
    1b4c:	00003097          	auipc	ra,0x3
    1b50:	dd2080e7          	jalr	-558(ra) # 491e <exit>
    printf("%s: bigargtest: fork failed\n", s);
    1b54:	85a6                	mv	a1,s1
    1b56:	00004517          	auipc	a0,0x4
    1b5a:	d8250513          	addi	a0,a0,-638 # 58d8 <malloc+0xb72>
    1b5e:	00003097          	auipc	ra,0x3
    1b62:	150080e7          	jalr	336(ra) # 4cae <printf>
    exit(1);
    1b66:	4505                	li	a0,1
    1b68:	00003097          	auipc	ra,0x3
    1b6c:	db6080e7          	jalr	-586(ra) # 491e <exit>
    exit(xstatus);
    1b70:	00003097          	auipc	ra,0x3
    1b74:	dae080e7          	jalr	-594(ra) # 491e <exit>
    printf("%s: bigarg test failed!\n", s);
    1b78:	85a6                	mv	a1,s1
    1b7a:	00004517          	auipc	a0,0x4
    1b7e:	d7e50513          	addi	a0,a0,-642 # 58f8 <malloc+0xb92>
    1b82:	00003097          	auipc	ra,0x3
    1b86:	12c080e7          	jalr	300(ra) # 4cae <printf>
    exit(1);
    1b8a:	4505                	li	a0,1
    1b8c:	00003097          	auipc	ra,0x3
    1b90:	d92080e7          	jalr	-622(ra) # 491e <exit>

0000000000001b94 <stacktest>:
{
    1b94:	7179                	addi	sp,sp,-48
    1b96:	f406                	sd	ra,40(sp)
    1b98:	f022                	sd	s0,32(sp)
    1b9a:	ec26                	sd	s1,24(sp)
    1b9c:	1800                	addi	s0,sp,48
    1b9e:	84aa                	mv	s1,a0
  pid = fork();
    1ba0:	00003097          	auipc	ra,0x3
    1ba4:	d76080e7          	jalr	-650(ra) # 4916 <fork>
  if(pid == 0) {
    1ba8:	c115                	beqz	a0,1bcc <stacktest+0x38>
  } else if(pid < 0){
    1baa:	04054363          	bltz	a0,1bf0 <stacktest+0x5c>
  wait(&xstatus);
    1bae:	fdc40513          	addi	a0,s0,-36
    1bb2:	00003097          	auipc	ra,0x3
    1bb6:	d74080e7          	jalr	-652(ra) # 4926 <wait>
  if(xstatus == -1)  // kernel killed child?
    1bba:	fdc42503          	lw	a0,-36(s0)
    1bbe:	57fd                	li	a5,-1
    1bc0:	04f50663          	beq	a0,a5,1c0c <stacktest+0x78>
    exit(xstatus);
    1bc4:	00003097          	auipc	ra,0x3
    1bc8:	d5a080e7          	jalr	-678(ra) # 491e <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp" : "=r" (x) );
    1bcc:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %p\n", *sp);
    1bce:	77fd                	lui	a5,0xfffff
    1bd0:	97ba                	add	a5,a5,a4
    1bd2:	0007c583          	lbu	a1,0(a5) # fffffffffffff000 <__BSS_END__+0xffffffffffff2f60>
    1bd6:	00004517          	auipc	a0,0x4
    1bda:	d4250513          	addi	a0,a0,-702 # 5918 <malloc+0xbb2>
    1bde:	00003097          	auipc	ra,0x3
    1be2:	0d0080e7          	jalr	208(ra) # 4cae <printf>
    exit(1);
    1be6:	4505                	li	a0,1
    1be8:	00003097          	auipc	ra,0x3
    1bec:	d36080e7          	jalr	-714(ra) # 491e <exit>
    printf("%s: fork failed\n", s);
    1bf0:	85a6                	mv	a1,s1
    1bf2:	00004517          	auipc	a0,0x4
    1bf6:	97650513          	addi	a0,a0,-1674 # 5568 <malloc+0x802>
    1bfa:	00003097          	auipc	ra,0x3
    1bfe:	0b4080e7          	jalr	180(ra) # 4cae <printf>
    exit(1);
    1c02:	4505                	li	a0,1
    1c04:	00003097          	auipc	ra,0x3
    1c08:	d1a080e7          	jalr	-742(ra) # 491e <exit>
    exit(0);
    1c0c:	4501                	li	a0,0
    1c0e:	00003097          	auipc	ra,0x3
    1c12:	d10080e7          	jalr	-752(ra) # 491e <exit>

0000000000001c16 <copyinstr3>:
{
    1c16:	7179                	addi	sp,sp,-48
    1c18:	f406                	sd	ra,40(sp)
    1c1a:	f022                	sd	s0,32(sp)
    1c1c:	ec26                	sd	s1,24(sp)
    1c1e:	1800                	addi	s0,sp,48
  sbrk(8192);
    1c20:	6509                	lui	a0,0x2
    1c22:	00003097          	auipc	ra,0x3
    1c26:	d6c080e7          	jalr	-660(ra) # 498e <sbrk>
  uint64 top = (uint64) sbrk(0);
    1c2a:	4501                	li	a0,0
    1c2c:	00003097          	auipc	ra,0x3
    1c30:	d62080e7          	jalr	-670(ra) # 498e <sbrk>
  if((top % PGSIZE) != 0){
    1c34:	03451793          	slli	a5,a0,0x34
    1c38:	eba5                	bnez	a5,1ca8 <copyinstr3+0x92>
  top = (uint64) sbrk(0);
    1c3a:	4501                	li	a0,0
    1c3c:	00003097          	auipc	ra,0x3
    1c40:	d52080e7          	jalr	-686(ra) # 498e <sbrk>
  if(top % PGSIZE){
    1c44:	03451793          	slli	a5,a0,0x34
    1c48:	ebb5                	bnez	a5,1cbc <copyinstr3+0xa6>
  char *b = (char *) (top - 1);
    1c4a:	fff50493          	addi	s1,a0,-1 # 1fff <sbrkmuch+0x133>
  *b = 'x';
    1c4e:	07800793          	li	a5,120
    1c52:	fef50fa3          	sb	a5,-1(a0)
  int ret = remove(b);
    1c56:	8526                	mv	a0,s1
    1c58:	00003097          	auipc	ra,0x3
    1c5c:	d6e080e7          	jalr	-658(ra) # 49c6 <remove>
  if(ret != -1){
    1c60:	57fd                	li	a5,-1
    1c62:	06f51a63          	bne	a0,a5,1cd6 <copyinstr3+0xc0>
  int fd = open(b, O_CREATE | O_WRONLY);
    1c66:	20100593          	li	a1,513
    1c6a:	8526                	mv	a0,s1
    1c6c:	00003097          	auipc	ra,0x3
    1c70:	cf2080e7          	jalr	-782(ra) # 495e <open>
  if(fd != -1){
    1c74:	57fd                	li	a5,-1
    1c76:	06f51f63          	bne	a0,a5,1cf4 <copyinstr3+0xde>
  char *args[] = { "xx", 0 };
    1c7a:	00004797          	auipc	a5,0x4
    1c7e:	44e78793          	addi	a5,a5,1102 # 60c8 <malloc+0x1362>
    1c82:	fcf43823          	sd	a5,-48(s0)
    1c86:	fc043c23          	sd	zero,-40(s0)
  ret = exec(b, args);
    1c8a:	fd040593          	addi	a1,s0,-48
    1c8e:	8526                	mv	a0,s1
    1c90:	00003097          	auipc	ra,0x3
    1c94:	cc6080e7          	jalr	-826(ra) # 4956 <exec>
  if(ret != -1){
    1c98:	57fd                	li	a5,-1
    1c9a:	06f51c63          	bne	a0,a5,1d12 <copyinstr3+0xfc>
}
    1c9e:	70a2                	ld	ra,40(sp)
    1ca0:	7402                	ld	s0,32(sp)
    1ca2:	64e2                	ld	s1,24(sp)
    1ca4:	6145                	addi	sp,sp,48
    1ca6:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    1ca8:	0347d513          	srli	a0,a5,0x34
    1cac:	6785                	lui	a5,0x1
    1cae:	40a7853b          	subw	a0,a5,a0
    1cb2:	00003097          	auipc	ra,0x3
    1cb6:	cdc080e7          	jalr	-804(ra) # 498e <sbrk>
    1cba:	b741                	j	1c3a <copyinstr3+0x24>
    printf("oops\n");
    1cbc:	00004517          	auipc	a0,0x4
    1cc0:	c8450513          	addi	a0,a0,-892 # 5940 <malloc+0xbda>
    1cc4:	00003097          	auipc	ra,0x3
    1cc8:	fea080e7          	jalr	-22(ra) # 4cae <printf>
    exit(1);
    1ccc:	4505                	li	a0,1
    1cce:	00003097          	auipc	ra,0x3
    1cd2:	c50080e7          	jalr	-944(ra) # 491e <exit>
    printf("remove(%s) returned %d, not -1\n", b, ret);
    1cd6:	862a                	mv	a2,a0
    1cd8:	85a6                	mv	a1,s1
    1cda:	00003517          	auipc	a0,0x3
    1cde:	7d650513          	addi	a0,a0,2006 # 54b0 <malloc+0x74a>
    1ce2:	00003097          	auipc	ra,0x3
    1ce6:	fcc080e7          	jalr	-52(ra) # 4cae <printf>
    exit(1);
    1cea:	4505                	li	a0,1
    1cec:	00003097          	auipc	ra,0x3
    1cf0:	c32080e7          	jalr	-974(ra) # 491e <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    1cf4:	862a                	mv	a2,a0
    1cf6:	85a6                	mv	a1,s1
    1cf8:	00003517          	auipc	a0,0x3
    1cfc:	7d850513          	addi	a0,a0,2008 # 54d0 <malloc+0x76a>
    1d00:	00003097          	auipc	ra,0x3
    1d04:	fae080e7          	jalr	-82(ra) # 4cae <printf>
    exit(1);
    1d08:	4505                	li	a0,1
    1d0a:	00003097          	auipc	ra,0x3
    1d0e:	c14080e7          	jalr	-1004(ra) # 491e <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    1d12:	567d                	li	a2,-1
    1d14:	85a6                	mv	a1,s1
    1d16:	00003517          	auipc	a0,0x3
    1d1a:	7da50513          	addi	a0,a0,2010 # 54f0 <malloc+0x78a>
    1d1e:	00003097          	auipc	ra,0x3
    1d22:	f90080e7          	jalr	-112(ra) # 4cae <printf>
    exit(1);
    1d26:	4505                	li	a0,1
    1d28:	00003097          	auipc	ra,0x3
    1d2c:	bf6080e7          	jalr	-1034(ra) # 491e <exit>

0000000000001d30 <sbrkbasic>:
{
    1d30:	7139                	addi	sp,sp,-64
    1d32:	fc06                	sd	ra,56(sp)
    1d34:	f822                	sd	s0,48(sp)
    1d36:	ec4e                	sd	s3,24(sp)
    1d38:	0080                	addi	s0,sp,64
    1d3a:	89aa                	mv	s3,a0
  pid = fork();
    1d3c:	00003097          	auipc	ra,0x3
    1d40:	bda080e7          	jalr	-1062(ra) # 4916 <fork>
  if(pid < 0){
    1d44:	02054f63          	bltz	a0,1d82 <sbrkbasic+0x52>
  if(pid == 0){
    1d48:	e52d                	bnez	a0,1db2 <sbrkbasic+0x82>
    a = sbrk(TOOMUCH);
    1d4a:	40000537          	lui	a0,0x40000
    1d4e:	00003097          	auipc	ra,0x3
    1d52:	c40080e7          	jalr	-960(ra) # 498e <sbrk>
    if(a == (char*)0xffffffffffffffffL){
    1d56:	57fd                	li	a5,-1
    1d58:	04f50563          	beq	a0,a5,1da2 <sbrkbasic+0x72>
    1d5c:	f426                	sd	s1,40(sp)
    1d5e:	f04a                	sd	s2,32(sp)
    1d60:	e852                	sd	s4,16(sp)
    for(b = a; b < a+TOOMUCH; b += 4096){
    1d62:	400007b7          	lui	a5,0x40000
    1d66:	97aa                	add	a5,a5,a0
      *b = 99;
    1d68:	06300693          	li	a3,99
    for(b = a; b < a+TOOMUCH; b += 4096){
    1d6c:	6705                	lui	a4,0x1
      *b = 99;
    1d6e:	00d50023          	sb	a3,0(a0) # 40000000 <__BSS_END__+0x3fff3f60>
    for(b = a; b < a+TOOMUCH; b += 4096){
    1d72:	953a                	add	a0,a0,a4
    1d74:	fef51de3          	bne	a0,a5,1d6e <sbrkbasic+0x3e>
    exit(1);
    1d78:	4505                	li	a0,1
    1d7a:	00003097          	auipc	ra,0x3
    1d7e:	ba4080e7          	jalr	-1116(ra) # 491e <exit>
    1d82:	f426                	sd	s1,40(sp)
    1d84:	f04a                	sd	s2,32(sp)
    1d86:	e852                	sd	s4,16(sp)
    printf("fork failed in sbrkbasic\n");
    1d88:	00004517          	auipc	a0,0x4
    1d8c:	bc050513          	addi	a0,a0,-1088 # 5948 <malloc+0xbe2>
    1d90:	00003097          	auipc	ra,0x3
    1d94:	f1e080e7          	jalr	-226(ra) # 4cae <printf>
    exit(1);
    1d98:	4505                	li	a0,1
    1d9a:	00003097          	auipc	ra,0x3
    1d9e:	b84080e7          	jalr	-1148(ra) # 491e <exit>
    1da2:	f426                	sd	s1,40(sp)
    1da4:	f04a                	sd	s2,32(sp)
    1da6:	e852                	sd	s4,16(sp)
      exit(0);
    1da8:	4501                	li	a0,0
    1daa:	00003097          	auipc	ra,0x3
    1dae:	b74080e7          	jalr	-1164(ra) # 491e <exit>
  wait(&xstatus);
    1db2:	fcc40513          	addi	a0,s0,-52
    1db6:	00003097          	auipc	ra,0x3
    1dba:	b70080e7          	jalr	-1168(ra) # 4926 <wait>
  if(xstatus == 1){
    1dbe:	fcc42703          	lw	a4,-52(s0)
    1dc2:	4785                	li	a5,1
    1dc4:	02f70063          	beq	a4,a5,1de4 <sbrkbasic+0xb4>
    1dc8:	f426                	sd	s1,40(sp)
    1dca:	f04a                	sd	s2,32(sp)
    1dcc:	e852                	sd	s4,16(sp)
  a = sbrk(0);
    1dce:	4501                	li	a0,0
    1dd0:	00003097          	auipc	ra,0x3
    1dd4:	bbe080e7          	jalr	-1090(ra) # 498e <sbrk>
    1dd8:	84aa                	mv	s1,a0
  for(i = 0; i < 5000; i++){
    1dda:	4901                	li	s2,0
    1ddc:	6a05                	lui	s4,0x1
    1dde:	388a0a13          	addi	s4,s4,904 # 1388 <exectest+0xd6>
    1de2:	a01d                	j	1e08 <sbrkbasic+0xd8>
    1de4:	f426                	sd	s1,40(sp)
    1de6:	f04a                	sd	s2,32(sp)
    1de8:	e852                	sd	s4,16(sp)
    printf("%s: too much memory allocated!\n", s);
    1dea:	85ce                	mv	a1,s3
    1dec:	00004517          	auipc	a0,0x4
    1df0:	b7c50513          	addi	a0,a0,-1156 # 5968 <malloc+0xc02>
    1df4:	00003097          	auipc	ra,0x3
    1df8:	eba080e7          	jalr	-326(ra) # 4cae <printf>
    exit(1);
    1dfc:	4505                	li	a0,1
    1dfe:	00003097          	auipc	ra,0x3
    1e02:	b20080e7          	jalr	-1248(ra) # 491e <exit>
    1e06:	84be                	mv	s1,a5
    b = sbrk(1);
    1e08:	4505                	li	a0,1
    1e0a:	00003097          	auipc	ra,0x3
    1e0e:	b84080e7          	jalr	-1148(ra) # 498e <sbrk>
    if(b != a){
    1e12:	04951c63          	bne	a0,s1,1e6a <sbrkbasic+0x13a>
    *b = 1;
    1e16:	4785                	li	a5,1
    1e18:	00f48023          	sb	a5,0(s1)
    a = b + 1;
    1e1c:	00148793          	addi	a5,s1,1
  for(i = 0; i < 5000; i++){
    1e20:	2905                	addiw	s2,s2,1
    1e22:	ff4912e3          	bne	s2,s4,1e06 <sbrkbasic+0xd6>
  pid = fork();
    1e26:	00003097          	auipc	ra,0x3
    1e2a:	af0080e7          	jalr	-1296(ra) # 4916 <fork>
    1e2e:	892a                	mv	s2,a0
  if(pid < 0){
    1e30:	04054d63          	bltz	a0,1e8a <sbrkbasic+0x15a>
  c = sbrk(1);
    1e34:	4505                	li	a0,1
    1e36:	00003097          	auipc	ra,0x3
    1e3a:	b58080e7          	jalr	-1192(ra) # 498e <sbrk>
  c = sbrk(1);
    1e3e:	4505                	li	a0,1
    1e40:	00003097          	auipc	ra,0x3
    1e44:	b4e080e7          	jalr	-1202(ra) # 498e <sbrk>
  if(c != a + 1){
    1e48:	0489                	addi	s1,s1,2
    1e4a:	04a48e63          	beq	s1,a0,1ea6 <sbrkbasic+0x176>
    printf("%s: sbrk test failed post-fork\n", s);
    1e4e:	85ce                	mv	a1,s3
    1e50:	00004517          	auipc	a0,0x4
    1e54:	b7850513          	addi	a0,a0,-1160 # 59c8 <malloc+0xc62>
    1e58:	00003097          	auipc	ra,0x3
    1e5c:	e56080e7          	jalr	-426(ra) # 4cae <printf>
    exit(1);
    1e60:	4505                	li	a0,1
    1e62:	00003097          	auipc	ra,0x3
    1e66:	abc080e7          	jalr	-1348(ra) # 491e <exit>
      printf("%s: sbrk test failed %d %x %x\n", i, a, b);
    1e6a:	86aa                	mv	a3,a0
    1e6c:	8626                	mv	a2,s1
    1e6e:	85ca                	mv	a1,s2
    1e70:	00004517          	auipc	a0,0x4
    1e74:	b1850513          	addi	a0,a0,-1256 # 5988 <malloc+0xc22>
    1e78:	00003097          	auipc	ra,0x3
    1e7c:	e36080e7          	jalr	-458(ra) # 4cae <printf>
      exit(1);
    1e80:	4505                	li	a0,1
    1e82:	00003097          	auipc	ra,0x3
    1e86:	a9c080e7          	jalr	-1380(ra) # 491e <exit>
    printf("%s: sbrk test fork failed\n", s);
    1e8a:	85ce                	mv	a1,s3
    1e8c:	00004517          	auipc	a0,0x4
    1e90:	b1c50513          	addi	a0,a0,-1252 # 59a8 <malloc+0xc42>
    1e94:	00003097          	auipc	ra,0x3
    1e98:	e1a080e7          	jalr	-486(ra) # 4cae <printf>
    exit(1);
    1e9c:	4505                	li	a0,1
    1e9e:	00003097          	auipc	ra,0x3
    1ea2:	a80080e7          	jalr	-1408(ra) # 491e <exit>
  if(pid == 0)
    1ea6:	00091763          	bnez	s2,1eb4 <sbrkbasic+0x184>
    exit(0);
    1eaa:	4501                	li	a0,0
    1eac:	00003097          	auipc	ra,0x3
    1eb0:	a72080e7          	jalr	-1422(ra) # 491e <exit>
  wait(&xstatus);
    1eb4:	fcc40513          	addi	a0,s0,-52
    1eb8:	00003097          	auipc	ra,0x3
    1ebc:	a6e080e7          	jalr	-1426(ra) # 4926 <wait>
  exit(xstatus);
    1ec0:	fcc42503          	lw	a0,-52(s0)
    1ec4:	00003097          	auipc	ra,0x3
    1ec8:	a5a080e7          	jalr	-1446(ra) # 491e <exit>

0000000000001ecc <sbrkmuch>:
{
    1ecc:	7179                	addi	sp,sp,-48
    1ece:	f406                	sd	ra,40(sp)
    1ed0:	f022                	sd	s0,32(sp)
    1ed2:	ec26                	sd	s1,24(sp)
    1ed4:	e84a                	sd	s2,16(sp)
    1ed6:	e44e                	sd	s3,8(sp)
    1ed8:	e052                	sd	s4,0(sp)
    1eda:	1800                	addi	s0,sp,48
    1edc:	89aa                	mv	s3,a0
  oldbrk = sbrk(0);
    1ede:	4501                	li	a0,0
    1ee0:	00003097          	auipc	ra,0x3
    1ee4:	aae080e7          	jalr	-1362(ra) # 498e <sbrk>
    1ee8:	892a                	mv	s2,a0
  a = sbrk(0);
    1eea:	4501                	li	a0,0
    1eec:	00003097          	auipc	ra,0x3
    1ef0:	aa2080e7          	jalr	-1374(ra) # 498e <sbrk>
    1ef4:	84aa                	mv	s1,a0
  p = sbrk(amt);
    1ef6:	00300537          	lui	a0,0x300
    1efa:	9d05                	subw	a0,a0,s1
    1efc:	00003097          	auipc	ra,0x3
    1f00:	a92080e7          	jalr	-1390(ra) # 498e <sbrk>
  if (p != a) {
    1f04:	0ca49863          	bne	s1,a0,1fd4 <sbrkmuch+0x108>
  char *eee = sbrk(0);
    1f08:	4501                	li	a0,0
    1f0a:	00003097          	auipc	ra,0x3
    1f0e:	a84080e7          	jalr	-1404(ra) # 498e <sbrk>
    1f12:	87aa                	mv	a5,a0
  for(char *pp = a; pp < eee; pp += 4096)
    1f14:	00a4f963          	bgeu	s1,a0,1f26 <sbrkmuch+0x5a>
    *pp = 1;
    1f18:	4685                	li	a3,1
  for(char *pp = a; pp < eee; pp += 4096)
    1f1a:	6705                	lui	a4,0x1
    *pp = 1;
    1f1c:	00d48023          	sb	a3,0(s1)
  for(char *pp = a; pp < eee; pp += 4096)
    1f20:	94ba                	add	s1,s1,a4
    1f22:	fef4ede3          	bltu	s1,a5,1f1c <sbrkmuch+0x50>
  *lastaddr = 99;
    1f26:	003007b7          	lui	a5,0x300
    1f2a:	06300713          	li	a4,99
    1f2e:	fee78fa3          	sb	a4,-1(a5) # 2fffff <__BSS_END__+0x2f3f5f>
  a = sbrk(0);
    1f32:	4501                	li	a0,0
    1f34:	00003097          	auipc	ra,0x3
    1f38:	a5a080e7          	jalr	-1446(ra) # 498e <sbrk>
    1f3c:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    1f3e:	757d                	lui	a0,0xfffff
    1f40:	00003097          	auipc	ra,0x3
    1f44:	a4e080e7          	jalr	-1458(ra) # 498e <sbrk>
  if(c == (char*)0xffffffffffffffffL){
    1f48:	57fd                	li	a5,-1
    1f4a:	0af50363          	beq	a0,a5,1ff0 <sbrkmuch+0x124>
  c = sbrk(0);
    1f4e:	4501                	li	a0,0
    1f50:	00003097          	auipc	ra,0x3
    1f54:	a3e080e7          	jalr	-1474(ra) # 498e <sbrk>
  if(c != a - PGSIZE){
    1f58:	77fd                	lui	a5,0xfffff
    1f5a:	97a6                	add	a5,a5,s1
    1f5c:	0af51863          	bne	a0,a5,200c <sbrkmuch+0x140>
  a = sbrk(0);
    1f60:	4501                	li	a0,0
    1f62:	00003097          	auipc	ra,0x3
    1f66:	a2c080e7          	jalr	-1492(ra) # 498e <sbrk>
    1f6a:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    1f6c:	6505                	lui	a0,0x1
    1f6e:	00003097          	auipc	ra,0x3
    1f72:	a20080e7          	jalr	-1504(ra) # 498e <sbrk>
    1f76:	8a2a                	mv	s4,a0
  if(c != a || sbrk(0) != a + PGSIZE){
    1f78:	0aa49963          	bne	s1,a0,202a <sbrkmuch+0x15e>
    1f7c:	4501                	li	a0,0
    1f7e:	00003097          	auipc	ra,0x3
    1f82:	a10080e7          	jalr	-1520(ra) # 498e <sbrk>
    1f86:	6785                	lui	a5,0x1
    1f88:	97a6                	add	a5,a5,s1
    1f8a:	0af51063          	bne	a0,a5,202a <sbrkmuch+0x15e>
  if(*lastaddr == 99){
    1f8e:	003007b7          	lui	a5,0x300
    1f92:	fff7c703          	lbu	a4,-1(a5) # 2fffff <__BSS_END__+0x2f3f5f>
    1f96:	06300793          	li	a5,99
    1f9a:	0af70763          	beq	a4,a5,2048 <sbrkmuch+0x17c>
  a = sbrk(0);
    1f9e:	4501                	li	a0,0
    1fa0:	00003097          	auipc	ra,0x3
    1fa4:	9ee080e7          	jalr	-1554(ra) # 498e <sbrk>
    1fa8:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    1faa:	4501                	li	a0,0
    1fac:	00003097          	auipc	ra,0x3
    1fb0:	9e2080e7          	jalr	-1566(ra) # 498e <sbrk>
    1fb4:	40a9053b          	subw	a0,s2,a0
    1fb8:	00003097          	auipc	ra,0x3
    1fbc:	9d6080e7          	jalr	-1578(ra) # 498e <sbrk>
  if(c != a){
    1fc0:	0aa49263          	bne	s1,a0,2064 <sbrkmuch+0x198>
}
    1fc4:	70a2                	ld	ra,40(sp)
    1fc6:	7402                	ld	s0,32(sp)
    1fc8:	64e2                	ld	s1,24(sp)
    1fca:	6942                	ld	s2,16(sp)
    1fcc:	69a2                	ld	s3,8(sp)
    1fce:	6a02                	ld	s4,0(sp)
    1fd0:	6145                	addi	sp,sp,48
    1fd2:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
    1fd4:	85ce                	mv	a1,s3
    1fd6:	00004517          	auipc	a0,0x4
    1fda:	a1250513          	addi	a0,a0,-1518 # 59e8 <malloc+0xc82>
    1fde:	00003097          	auipc	ra,0x3
    1fe2:	cd0080e7          	jalr	-816(ra) # 4cae <printf>
    exit(1);
    1fe6:	4505                	li	a0,1
    1fe8:	00003097          	auipc	ra,0x3
    1fec:	936080e7          	jalr	-1738(ra) # 491e <exit>
    printf("%s: sbrk could not deallocate\n", s);
    1ff0:	85ce                	mv	a1,s3
    1ff2:	00004517          	auipc	a0,0x4
    1ff6:	a3e50513          	addi	a0,a0,-1474 # 5a30 <malloc+0xcca>
    1ffa:	00003097          	auipc	ra,0x3
    1ffe:	cb4080e7          	jalr	-844(ra) # 4cae <printf>
    exit(1);
    2002:	4505                	li	a0,1
    2004:	00003097          	auipc	ra,0x3
    2008:	91a080e7          	jalr	-1766(ra) # 491e <exit>
    printf("%s: sbrk deallocation produced wrong address, a %x c %x\n", a, c);
    200c:	862a                	mv	a2,a0
    200e:	85a6                	mv	a1,s1
    2010:	00004517          	auipc	a0,0x4
    2014:	a4050513          	addi	a0,a0,-1472 # 5a50 <malloc+0xcea>
    2018:	00003097          	auipc	ra,0x3
    201c:	c96080e7          	jalr	-874(ra) # 4cae <printf>
    exit(1);
    2020:	4505                	li	a0,1
    2022:	00003097          	auipc	ra,0x3
    2026:	8fc080e7          	jalr	-1796(ra) # 491e <exit>
    printf("%s: sbrk re-allocation failed, a %x c %x\n", a, c);
    202a:	8652                	mv	a2,s4
    202c:	85a6                	mv	a1,s1
    202e:	00004517          	auipc	a0,0x4
    2032:	a6250513          	addi	a0,a0,-1438 # 5a90 <malloc+0xd2a>
    2036:	00003097          	auipc	ra,0x3
    203a:	c78080e7          	jalr	-904(ra) # 4cae <printf>
    exit(1);
    203e:	4505                	li	a0,1
    2040:	00003097          	auipc	ra,0x3
    2044:	8de080e7          	jalr	-1826(ra) # 491e <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    2048:	85ce                	mv	a1,s3
    204a:	00004517          	auipc	a0,0x4
    204e:	a7650513          	addi	a0,a0,-1418 # 5ac0 <malloc+0xd5a>
    2052:	00003097          	auipc	ra,0x3
    2056:	c5c080e7          	jalr	-932(ra) # 4cae <printf>
    exit(1);
    205a:	4505                	li	a0,1
    205c:	00003097          	auipc	ra,0x3
    2060:	8c2080e7          	jalr	-1854(ra) # 491e <exit>
    printf("%s: sbrk downsize failed, a %x c %x\n", a, c);
    2064:	862a                	mv	a2,a0
    2066:	85a6                	mv	a1,s1
    2068:	00004517          	auipc	a0,0x4
    206c:	a9050513          	addi	a0,a0,-1392 # 5af8 <malloc+0xd92>
    2070:	00003097          	auipc	ra,0x3
    2074:	c3e080e7          	jalr	-962(ra) # 4cae <printf>
    exit(1);
    2078:	4505                	li	a0,1
    207a:	00003097          	auipc	ra,0x3
    207e:	8a4080e7          	jalr	-1884(ra) # 491e <exit>

0000000000002082 <sbrkarg>:
{
    2082:	7179                	addi	sp,sp,-48
    2084:	f406                	sd	ra,40(sp)
    2086:	f022                	sd	s0,32(sp)
    2088:	ec26                	sd	s1,24(sp)
    208a:	e84a                	sd	s2,16(sp)
    208c:	e44e                	sd	s3,8(sp)
    208e:	1800                	addi	s0,sp,48
    2090:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    2092:	6505                	lui	a0,0x1
    2094:	00003097          	auipc	ra,0x3
    2098:	8fa080e7          	jalr	-1798(ra) # 498e <sbrk>
    209c:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE|O_WRONLY);
    209e:	20100593          	li	a1,513
    20a2:	00004517          	auipc	a0,0x4
    20a6:	a7e50513          	addi	a0,a0,-1410 # 5b20 <malloc+0xdba>
    20aa:	00003097          	auipc	ra,0x3
    20ae:	8b4080e7          	jalr	-1868(ra) # 495e <open>
    20b2:	84aa                	mv	s1,a0
  remove("sbrk");
    20b4:	00004517          	auipc	a0,0x4
    20b8:	a6c50513          	addi	a0,a0,-1428 # 5b20 <malloc+0xdba>
    20bc:	00003097          	auipc	ra,0x3
    20c0:	90a080e7          	jalr	-1782(ra) # 49c6 <remove>
  if(fd < 0)  {
    20c4:	0404c163          	bltz	s1,2106 <sbrkarg+0x84>
  if ((n = write(fd, a, PGSIZE)) < 0) {
    20c8:	6605                	lui	a2,0x1
    20ca:	85ca                	mv	a1,s2
    20cc:	8526                	mv	a0,s1
    20ce:	00003097          	auipc	ra,0x3
    20d2:	870080e7          	jalr	-1936(ra) # 493e <write>
    20d6:	04054663          	bltz	a0,2122 <sbrkarg+0xa0>
  close(fd);
    20da:	8526                	mv	a0,s1
    20dc:	00003097          	auipc	ra,0x3
    20e0:	86a080e7          	jalr	-1942(ra) # 4946 <close>
  a = sbrk(PGSIZE);
    20e4:	6505                	lui	a0,0x1
    20e6:	00003097          	auipc	ra,0x3
    20ea:	8a8080e7          	jalr	-1880(ra) # 498e <sbrk>
  if(pipe((int *) a) != 0){
    20ee:	00003097          	auipc	ra,0x3
    20f2:	840080e7          	jalr	-1984(ra) # 492e <pipe>
    20f6:	e521                	bnez	a0,213e <sbrkarg+0xbc>
}
    20f8:	70a2                	ld	ra,40(sp)
    20fa:	7402                	ld	s0,32(sp)
    20fc:	64e2                	ld	s1,24(sp)
    20fe:	6942                	ld	s2,16(sp)
    2100:	69a2                	ld	s3,8(sp)
    2102:	6145                	addi	sp,sp,48
    2104:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    2106:	85ce                	mv	a1,s3
    2108:	00004517          	auipc	a0,0x4
    210c:	a2050513          	addi	a0,a0,-1504 # 5b28 <malloc+0xdc2>
    2110:	00003097          	auipc	ra,0x3
    2114:	b9e080e7          	jalr	-1122(ra) # 4cae <printf>
    exit(1);
    2118:	4505                	li	a0,1
    211a:	00003097          	auipc	ra,0x3
    211e:	804080e7          	jalr	-2044(ra) # 491e <exit>
    printf("%s: write sbrk failed\n", s);
    2122:	85ce                	mv	a1,s3
    2124:	00004517          	auipc	a0,0x4
    2128:	a1c50513          	addi	a0,a0,-1508 # 5b40 <malloc+0xdda>
    212c:	00003097          	auipc	ra,0x3
    2130:	b82080e7          	jalr	-1150(ra) # 4cae <printf>
    exit(1);
    2134:	4505                	li	a0,1
    2136:	00002097          	auipc	ra,0x2
    213a:	7e8080e7          	jalr	2024(ra) # 491e <exit>
    printf("%s: pipe() failed\n", s);
    213e:	85ce                	mv	a1,s3
    2140:	00003517          	auipc	a0,0x3
    2144:	53050513          	addi	a0,a0,1328 # 5670 <malloc+0x90a>
    2148:	00003097          	auipc	ra,0x3
    214c:	b66080e7          	jalr	-1178(ra) # 4cae <printf>
    exit(1);
    2150:	4505                	li	a0,1
    2152:	00002097          	auipc	ra,0x2
    2156:	7cc080e7          	jalr	1996(ra) # 491e <exit>

000000000000215a <argptest>:
{
    215a:	1101                	addi	sp,sp,-32
    215c:	ec06                	sd	ra,24(sp)
    215e:	e822                	sd	s0,16(sp)
    2160:	e426                	sd	s1,8(sp)
    2162:	e04a                	sd	s2,0(sp)
    2164:	1000                	addi	s0,sp,32
    2166:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
    2168:	4581                	li	a1,0
    216a:	00004517          	auipc	a0,0x4
    216e:	9ee50513          	addi	a0,a0,-1554 # 5b58 <malloc+0xdf2>
    2172:	00002097          	auipc	ra,0x2
    2176:	7ec080e7          	jalr	2028(ra) # 495e <open>
  if (fd < 0) {
    217a:	02054b63          	bltz	a0,21b0 <argptest+0x56>
    217e:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    2180:	4501                	li	a0,0
    2182:	00003097          	auipc	ra,0x3
    2186:	80c080e7          	jalr	-2036(ra) # 498e <sbrk>
    218a:	567d                	li	a2,-1
    218c:	fff50593          	addi	a1,a0,-1
    2190:	8526                	mv	a0,s1
    2192:	00002097          	auipc	ra,0x2
    2196:	7a4080e7          	jalr	1956(ra) # 4936 <read>
  close(fd);
    219a:	8526                	mv	a0,s1
    219c:	00002097          	auipc	ra,0x2
    21a0:	7aa080e7          	jalr	1962(ra) # 4946 <close>
}
    21a4:	60e2                	ld	ra,24(sp)
    21a6:	6442                	ld	s0,16(sp)
    21a8:	64a2                	ld	s1,8(sp)
    21aa:	6902                	ld	s2,0(sp)
    21ac:	6105                	addi	sp,sp,32
    21ae:	8082                	ret
    printf("%s: open failed\n", s);
    21b0:	85ca                	mv	a1,s2
    21b2:	00003517          	auipc	a0,0x3
    21b6:	3ce50513          	addi	a0,a0,974 # 5580 <malloc+0x81a>
    21ba:	00003097          	auipc	ra,0x3
    21be:	af4080e7          	jalr	-1292(ra) # 4cae <printf>
    exit(1);
    21c2:	4505                	li	a0,1
    21c4:	00002097          	auipc	ra,0x2
    21c8:	75a080e7          	jalr	1882(ra) # 491e <exit>

00000000000021cc <sbrkbugs>:
{
    21cc:	1141                	addi	sp,sp,-16
    21ce:	e406                	sd	ra,8(sp)
    21d0:	e022                	sd	s0,0(sp)
    21d2:	0800                	addi	s0,sp,16
  int pid = fork();
    21d4:	00002097          	auipc	ra,0x2
    21d8:	742080e7          	jalr	1858(ra) # 4916 <fork>
  if(pid < 0){
    21dc:	02054263          	bltz	a0,2200 <sbrkbugs+0x34>
  if(pid == 0){
    21e0:	ed0d                	bnez	a0,221a <sbrkbugs+0x4e>
    int sz = (uint64) sbrk(0);
    21e2:	00002097          	auipc	ra,0x2
    21e6:	7ac080e7          	jalr	1964(ra) # 498e <sbrk>
    sbrk(-sz);
    21ea:	40a0053b          	negw	a0,a0
    21ee:	00002097          	auipc	ra,0x2
    21f2:	7a0080e7          	jalr	1952(ra) # 498e <sbrk>
    exit(0);
    21f6:	4501                	li	a0,0
    21f8:	00002097          	auipc	ra,0x2
    21fc:	726080e7          	jalr	1830(ra) # 491e <exit>
    printf("fork failed\n");
    2200:	00003517          	auipc	a0,0x3
    2204:	6e850513          	addi	a0,a0,1768 # 58e8 <malloc+0xb82>
    2208:	00003097          	auipc	ra,0x3
    220c:	aa6080e7          	jalr	-1370(ra) # 4cae <printf>
    exit(1);
    2210:	4505                	li	a0,1
    2212:	00002097          	auipc	ra,0x2
    2216:	70c080e7          	jalr	1804(ra) # 491e <exit>
  wait(0);
    221a:	4501                	li	a0,0
    221c:	00002097          	auipc	ra,0x2
    2220:	70a080e7          	jalr	1802(ra) # 4926 <wait>
  pid = fork();
    2224:	00002097          	auipc	ra,0x2
    2228:	6f2080e7          	jalr	1778(ra) # 4916 <fork>
  if(pid < 0){
    222c:	02054563          	bltz	a0,2256 <sbrkbugs+0x8a>
  if(pid == 0){
    2230:	e121                	bnez	a0,2270 <sbrkbugs+0xa4>
    int sz = (uint64) sbrk(0);
    2232:	00002097          	auipc	ra,0x2
    2236:	75c080e7          	jalr	1884(ra) # 498e <sbrk>
    sbrk(-(sz - 3500));
    223a:	6785                	lui	a5,0x1
    223c:	dac7879b          	addiw	a5,a5,-596 # dac <removeread+0xc6>
    2240:	40a7853b          	subw	a0,a5,a0
    2244:	00002097          	auipc	ra,0x2
    2248:	74a080e7          	jalr	1866(ra) # 498e <sbrk>
    exit(0);
    224c:	4501                	li	a0,0
    224e:	00002097          	auipc	ra,0x2
    2252:	6d0080e7          	jalr	1744(ra) # 491e <exit>
    printf("fork failed\n");
    2256:	00003517          	auipc	a0,0x3
    225a:	69250513          	addi	a0,a0,1682 # 58e8 <malloc+0xb82>
    225e:	00003097          	auipc	ra,0x3
    2262:	a50080e7          	jalr	-1456(ra) # 4cae <printf>
    exit(1);
    2266:	4505                	li	a0,1
    2268:	00002097          	auipc	ra,0x2
    226c:	6b6080e7          	jalr	1718(ra) # 491e <exit>
  wait(0);
    2270:	4501                	li	a0,0
    2272:	00002097          	auipc	ra,0x2
    2276:	6b4080e7          	jalr	1716(ra) # 4926 <wait>
  pid = fork();
    227a:	00002097          	auipc	ra,0x2
    227e:	69c080e7          	jalr	1692(ra) # 4916 <fork>
  if(pid < 0){
    2282:	02054a63          	bltz	a0,22b6 <sbrkbugs+0xea>
  if(pid == 0){
    2286:	e529                	bnez	a0,22d0 <sbrkbugs+0x104>
    sbrk((10*4096 + 2048) - (uint64)sbrk(0));
    2288:	00002097          	auipc	ra,0x2
    228c:	706080e7          	jalr	1798(ra) # 498e <sbrk>
    2290:	67ad                	lui	a5,0xb
    2292:	8007879b          	addiw	a5,a5,-2048 # a800 <uninit+0x2680>
    2296:	40a7853b          	subw	a0,a5,a0
    229a:	00002097          	auipc	ra,0x2
    229e:	6f4080e7          	jalr	1780(ra) # 498e <sbrk>
    sbrk(-10);
    22a2:	5559                	li	a0,-10
    22a4:	00002097          	auipc	ra,0x2
    22a8:	6ea080e7          	jalr	1770(ra) # 498e <sbrk>
    exit(0);
    22ac:	4501                	li	a0,0
    22ae:	00002097          	auipc	ra,0x2
    22b2:	670080e7          	jalr	1648(ra) # 491e <exit>
    printf("fork failed\n");
    22b6:	00003517          	auipc	a0,0x3
    22ba:	63250513          	addi	a0,a0,1586 # 58e8 <malloc+0xb82>
    22be:	00003097          	auipc	ra,0x3
    22c2:	9f0080e7          	jalr	-1552(ra) # 4cae <printf>
    exit(1);
    22c6:	4505                	li	a0,1
    22c8:	00002097          	auipc	ra,0x2
    22cc:	656080e7          	jalr	1622(ra) # 491e <exit>
  wait(0);
    22d0:	4501                	li	a0,0
    22d2:	00002097          	auipc	ra,0x2
    22d6:	654080e7          	jalr	1620(ra) # 4926 <wait>
  exit(0);
    22da:	4501                	li	a0,0
    22dc:	00002097          	auipc	ra,0x2
    22e0:	642080e7          	jalr	1602(ra) # 491e <exit>

00000000000022e4 <execout>:
// test the exec() code that cleans up if it runs out
// of memory. it's really a test that such a condition
// doesn't cause a panic.
void
execout(char *s)
{
    22e4:	715d                	addi	sp,sp,-80
    22e6:	e486                	sd	ra,72(sp)
    22e8:	e0a2                	sd	s0,64(sp)
    22ea:	fc26                	sd	s1,56(sp)
    22ec:	f84a                	sd	s2,48(sp)
    22ee:	f44e                	sd	s3,40(sp)
    22f0:	f052                	sd	s4,32(sp)
    22f2:	0880                	addi	s0,sp,80
  for(int avail = 0; avail < 15; avail++){
    22f4:	4901                	li	s2,0
    22f6:	49bd                	li	s3,15
    int pid = fork();
    22f8:	00002097          	auipc	ra,0x2
    22fc:	61e080e7          	jalr	1566(ra) # 4916 <fork>
    2300:	84aa                	mv	s1,a0
    if(pid < 0){
    2302:	02054063          	bltz	a0,2322 <execout+0x3e>
      printf("fork failed\n");
      exit(1);
    } else if(pid == 0){
    2306:	c91d                	beqz	a0,233c <execout+0x58>
      close(1);
      char *args[] = { "echo", "x", 0 };
      exec("echo", args);
      exit(0);
    } else {
      wait((int*)0);
    2308:	4501                	li	a0,0
    230a:	00002097          	auipc	ra,0x2
    230e:	61c080e7          	jalr	1564(ra) # 4926 <wait>
  for(int avail = 0; avail < 15; avail++){
    2312:	2905                	addiw	s2,s2,1
    2314:	ff3912e3          	bne	s2,s3,22f8 <execout+0x14>
    }
  }

  exit(0);
    2318:	4501                	li	a0,0
    231a:	00002097          	auipc	ra,0x2
    231e:	604080e7          	jalr	1540(ra) # 491e <exit>
      printf("fork failed\n");
    2322:	00003517          	auipc	a0,0x3
    2326:	5c650513          	addi	a0,a0,1478 # 58e8 <malloc+0xb82>
    232a:	00003097          	auipc	ra,0x3
    232e:	984080e7          	jalr	-1660(ra) # 4cae <printf>
      exit(1);
    2332:	4505                	li	a0,1
    2334:	00002097          	auipc	ra,0x2
    2338:	5ea080e7          	jalr	1514(ra) # 491e <exit>
        if(a == 0xffffffffffffffffLL)
    233c:	59fd                	li	s3,-1
        *(char*)(a + 4096 - 1) = 1;
    233e:	4a05                	li	s4,1
        uint64 a = (uint64) sbrk(4096);
    2340:	6505                	lui	a0,0x1
    2342:	00002097          	auipc	ra,0x2
    2346:	64c080e7          	jalr	1612(ra) # 498e <sbrk>
        if(a == 0xffffffffffffffffLL)
    234a:	01350763          	beq	a0,s3,2358 <execout+0x74>
        *(char*)(a + 4096 - 1) = 1;
    234e:	6785                	lui	a5,0x1
    2350:	97aa                	add	a5,a5,a0
    2352:	ff478fa3          	sb	s4,-1(a5) # fff <copyinstr2+0xd7>
      while(1){
    2356:	b7ed                	j	2340 <execout+0x5c>
      for(int i = 0; i < avail; i++)
    2358:	01205a63          	blez	s2,236c <execout+0x88>
        sbrk(-4096);
    235c:	757d                	lui	a0,0xfffff
    235e:	00002097          	auipc	ra,0x2
    2362:	630080e7          	jalr	1584(ra) # 498e <sbrk>
      for(int i = 0; i < avail; i++)
    2366:	2485                	addiw	s1,s1,1
    2368:	ff249ae3          	bne	s1,s2,235c <execout+0x78>
      close(1);
    236c:	4505                	li	a0,1
    236e:	00002097          	auipc	ra,0x2
    2372:	5d8080e7          	jalr	1496(ra) # 4946 <close>
      char *args[] = { "echo", "x", 0 };
    2376:	00003517          	auipc	a0,0x3
    237a:	b6250513          	addi	a0,a0,-1182 # 4ed8 <malloc+0x172>
    237e:	faa43c23          	sd	a0,-72(s0)
    2382:	00003797          	auipc	a5,0x3
    2386:	bc678793          	addi	a5,a5,-1082 # 4f48 <malloc+0x1e2>
    238a:	fcf43023          	sd	a5,-64(s0)
    238e:	fc043423          	sd	zero,-56(s0)
      exec("echo", args);
    2392:	fb840593          	addi	a1,s0,-72
    2396:	00002097          	auipc	ra,0x2
    239a:	5c0080e7          	jalr	1472(ra) # 4956 <exec>
      exit(0);
    239e:	4501                	li	a0,0
    23a0:	00002097          	auipc	ra,0x2
    23a4:	57e080e7          	jalr	1406(ra) # 491e <exit>

00000000000023a8 <iputtest>:
{
    23a8:	1101                	addi	sp,sp,-32
    23aa:	ec06                	sd	ra,24(sp)
    23ac:	e822                	sd	s0,16(sp)
    23ae:	e426                	sd	s1,8(sp)
    23b0:	1000                	addi	s0,sp,32
    23b2:	84aa                	mv	s1,a0
  if(mkdir("iputdir") < 0){
    23b4:	00003517          	auipc	a0,0x3
    23b8:	7ac50513          	addi	a0,a0,1964 # 5b60 <malloc+0xdfa>
    23bc:	00002097          	auipc	ra,0x2
    23c0:	5b2080e7          	jalr	1458(ra) # 496e <mkdir>
    23c4:	04054563          	bltz	a0,240e <iputtest+0x66>
  if(chdir("iputdir") < 0){
    23c8:	00003517          	auipc	a0,0x3
    23cc:	79850513          	addi	a0,a0,1944 # 5b60 <malloc+0xdfa>
    23d0:	00002097          	auipc	ra,0x2
    23d4:	5a6080e7          	jalr	1446(ra) # 4976 <chdir>
    23d8:	04054963          	bltz	a0,242a <iputtest+0x82>
  if(remove("../iputdir") < 0){
    23dc:	00003517          	auipc	a0,0x3
    23e0:	7c450513          	addi	a0,a0,1988 # 5ba0 <malloc+0xe3a>
    23e4:	00002097          	auipc	ra,0x2
    23e8:	5e2080e7          	jalr	1506(ra) # 49c6 <remove>
    23ec:	04054d63          	bltz	a0,2446 <iputtest+0x9e>
  if(chdir("/") < 0){
    23f0:	00003517          	auipc	a0,0x3
    23f4:	7e050513          	addi	a0,a0,2016 # 5bd0 <malloc+0xe6a>
    23f8:	00002097          	auipc	ra,0x2
    23fc:	57e080e7          	jalr	1406(ra) # 4976 <chdir>
    2400:	06054163          	bltz	a0,2462 <iputtest+0xba>
}
    2404:	60e2                	ld	ra,24(sp)
    2406:	6442                	ld	s0,16(sp)
    2408:	64a2                	ld	s1,8(sp)
    240a:	6105                	addi	sp,sp,32
    240c:	8082                	ret
    printf("%s: mkdir failed\n", s);
    240e:	85a6                	mv	a1,s1
    2410:	00003517          	auipc	a0,0x3
    2414:	75850513          	addi	a0,a0,1880 # 5b68 <malloc+0xe02>
    2418:	00003097          	auipc	ra,0x3
    241c:	896080e7          	jalr	-1898(ra) # 4cae <printf>
    exit(1);
    2420:	4505                	li	a0,1
    2422:	00002097          	auipc	ra,0x2
    2426:	4fc080e7          	jalr	1276(ra) # 491e <exit>
    printf("%s: chdir iputdir failed\n", s);
    242a:	85a6                	mv	a1,s1
    242c:	00003517          	auipc	a0,0x3
    2430:	75450513          	addi	a0,a0,1876 # 5b80 <malloc+0xe1a>
    2434:	00003097          	auipc	ra,0x3
    2438:	87a080e7          	jalr	-1926(ra) # 4cae <printf>
    exit(1);
    243c:	4505                	li	a0,1
    243e:	00002097          	auipc	ra,0x2
    2442:	4e0080e7          	jalr	1248(ra) # 491e <exit>
    printf("%s: remove ../iputdir failed\n", s);
    2446:	85a6                	mv	a1,s1
    2448:	00003517          	auipc	a0,0x3
    244c:	76850513          	addi	a0,a0,1896 # 5bb0 <malloc+0xe4a>
    2450:	00003097          	auipc	ra,0x3
    2454:	85e080e7          	jalr	-1954(ra) # 4cae <printf>
    exit(1);
    2458:	4505                	li	a0,1
    245a:	00002097          	auipc	ra,0x2
    245e:	4c4080e7          	jalr	1220(ra) # 491e <exit>
    printf("%s: chdir / failed\n", s);
    2462:	85a6                	mv	a1,s1
    2464:	00003517          	auipc	a0,0x3
    2468:	77450513          	addi	a0,a0,1908 # 5bd8 <malloc+0xe72>
    246c:	00003097          	auipc	ra,0x3
    2470:	842080e7          	jalr	-1982(ra) # 4cae <printf>
    exit(1);
    2474:	4505                	li	a0,1
    2476:	00002097          	auipc	ra,0x2
    247a:	4a8080e7          	jalr	1192(ra) # 491e <exit>

000000000000247e <exitiputtest>:
{
    247e:	7179                	addi	sp,sp,-48
    2480:	f406                	sd	ra,40(sp)
    2482:	f022                	sd	s0,32(sp)
    2484:	ec26                	sd	s1,24(sp)
    2486:	1800                	addi	s0,sp,48
    2488:	84aa                	mv	s1,a0
  pid = fork();
    248a:	00002097          	auipc	ra,0x2
    248e:	48c080e7          	jalr	1164(ra) # 4916 <fork>
  if(pid < 0){
    2492:	04054663          	bltz	a0,24de <exitiputtest+0x60>
  if(pid == 0){
    2496:	ed45                	bnez	a0,254e <exitiputtest+0xd0>
    if(mkdir("iputdir") < 0){
    2498:	00003517          	auipc	a0,0x3
    249c:	6c850513          	addi	a0,a0,1736 # 5b60 <malloc+0xdfa>
    24a0:	00002097          	auipc	ra,0x2
    24a4:	4ce080e7          	jalr	1230(ra) # 496e <mkdir>
    24a8:	04054963          	bltz	a0,24fa <exitiputtest+0x7c>
    if(chdir("iputdir") < 0){
    24ac:	00003517          	auipc	a0,0x3
    24b0:	6b450513          	addi	a0,a0,1716 # 5b60 <malloc+0xdfa>
    24b4:	00002097          	auipc	ra,0x2
    24b8:	4c2080e7          	jalr	1218(ra) # 4976 <chdir>
    24bc:	04054d63          	bltz	a0,2516 <exitiputtest+0x98>
    if(remove("../iputdir") < 0){
    24c0:	00003517          	auipc	a0,0x3
    24c4:	6e050513          	addi	a0,a0,1760 # 5ba0 <malloc+0xe3a>
    24c8:	00002097          	auipc	ra,0x2
    24cc:	4fe080e7          	jalr	1278(ra) # 49c6 <remove>
    24d0:	06054163          	bltz	a0,2532 <exitiputtest+0xb4>
    exit(0);
    24d4:	4501                	li	a0,0
    24d6:	00002097          	auipc	ra,0x2
    24da:	448080e7          	jalr	1096(ra) # 491e <exit>
    printf("%s: fork failed\n", s);
    24de:	85a6                	mv	a1,s1
    24e0:	00003517          	auipc	a0,0x3
    24e4:	08850513          	addi	a0,a0,136 # 5568 <malloc+0x802>
    24e8:	00002097          	auipc	ra,0x2
    24ec:	7c6080e7          	jalr	1990(ra) # 4cae <printf>
    exit(1);
    24f0:	4505                	li	a0,1
    24f2:	00002097          	auipc	ra,0x2
    24f6:	42c080e7          	jalr	1068(ra) # 491e <exit>
      printf("%s: mkdir failed\n", s);
    24fa:	85a6                	mv	a1,s1
    24fc:	00003517          	auipc	a0,0x3
    2500:	66c50513          	addi	a0,a0,1644 # 5b68 <malloc+0xe02>
    2504:	00002097          	auipc	ra,0x2
    2508:	7aa080e7          	jalr	1962(ra) # 4cae <printf>
      exit(1);
    250c:	4505                	li	a0,1
    250e:	00002097          	auipc	ra,0x2
    2512:	410080e7          	jalr	1040(ra) # 491e <exit>
      printf("%s: child chdir failed\n", s);
    2516:	85a6                	mv	a1,s1
    2518:	00003517          	auipc	a0,0x3
    251c:	6d850513          	addi	a0,a0,1752 # 5bf0 <malloc+0xe8a>
    2520:	00002097          	auipc	ra,0x2
    2524:	78e080e7          	jalr	1934(ra) # 4cae <printf>
      exit(1);
    2528:	4505                	li	a0,1
    252a:	00002097          	auipc	ra,0x2
    252e:	3f4080e7          	jalr	1012(ra) # 491e <exit>
      printf("%s: remove ../iputdir failed\n", s);
    2532:	85a6                	mv	a1,s1
    2534:	00003517          	auipc	a0,0x3
    2538:	67c50513          	addi	a0,a0,1660 # 5bb0 <malloc+0xe4a>
    253c:	00002097          	auipc	ra,0x2
    2540:	772080e7          	jalr	1906(ra) # 4cae <printf>
      exit(1);
    2544:	4505                	li	a0,1
    2546:	00002097          	auipc	ra,0x2
    254a:	3d8080e7          	jalr	984(ra) # 491e <exit>
  wait(&xstatus);
    254e:	fdc40513          	addi	a0,s0,-36
    2552:	00002097          	auipc	ra,0x2
    2556:	3d4080e7          	jalr	980(ra) # 4926 <wait>
  exit(xstatus);
    255a:	fdc42503          	lw	a0,-36(s0)
    255e:	00002097          	auipc	ra,0x2
    2562:	3c0080e7          	jalr	960(ra) # 491e <exit>

0000000000002566 <subdir>:
{
    2566:	1101                	addi	sp,sp,-32
    2568:	ec06                	sd	ra,24(sp)
    256a:	e822                	sd	s0,16(sp)
    256c:	e426                	sd	s1,8(sp)
    256e:	e04a                	sd	s2,0(sp)
    2570:	1000                	addi	s0,sp,32
    2572:	892a                	mv	s2,a0
  remove("ff");
    2574:	00003517          	auipc	a0,0x3
    2578:	69450513          	addi	a0,a0,1684 # 5c08 <malloc+0xea2>
    257c:	00002097          	auipc	ra,0x2
    2580:	44a080e7          	jalr	1098(ra) # 49c6 <remove>
  if(mkdir("dd") != 0){
    2584:	00003517          	auipc	a0,0x3
    2588:	68c50513          	addi	a0,a0,1676 # 5c10 <malloc+0xeaa>
    258c:	00002097          	auipc	ra,0x2
    2590:	3e2080e7          	jalr	994(ra) # 496e <mkdir>
    2594:	24051363          	bnez	a0,27da <subdir+0x274>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    2598:	20200593          	li	a1,514
    259c:	00003517          	auipc	a0,0x3
    25a0:	69450513          	addi	a0,a0,1684 # 5c30 <malloc+0xeca>
    25a4:	00002097          	auipc	ra,0x2
    25a8:	3ba080e7          	jalr	954(ra) # 495e <open>
    25ac:	84aa                	mv	s1,a0
  if(fd < 0){
    25ae:	24054463          	bltz	a0,27f6 <subdir+0x290>
  write(fd, "ff", 2);
    25b2:	4609                	li	a2,2
    25b4:	00003597          	auipc	a1,0x3
    25b8:	65458593          	addi	a1,a1,1620 # 5c08 <malloc+0xea2>
    25bc:	00002097          	auipc	ra,0x2
    25c0:	382080e7          	jalr	898(ra) # 493e <write>
  close(fd);
    25c4:	8526                	mv	a0,s1
    25c6:	00002097          	auipc	ra,0x2
    25ca:	380080e7          	jalr	896(ra) # 4946 <close>
  if(remove("dd") >= 0){
    25ce:	00003517          	auipc	a0,0x3
    25d2:	64250513          	addi	a0,a0,1602 # 5c10 <malloc+0xeaa>
    25d6:	00002097          	auipc	ra,0x2
    25da:	3f0080e7          	jalr	1008(ra) # 49c6 <remove>
    25de:	22055a63          	bgez	a0,2812 <subdir+0x2ac>
  if(mkdir("/dd/dd") != 0){
    25e2:	00003517          	auipc	a0,0x3
    25e6:	6a650513          	addi	a0,a0,1702 # 5c88 <malloc+0xf22>
    25ea:	00002097          	auipc	ra,0x2
    25ee:	384080e7          	jalr	900(ra) # 496e <mkdir>
    25f2:	22051e63          	bnez	a0,282e <subdir+0x2c8>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    25f6:	20200593          	li	a1,514
    25fa:	00003517          	auipc	a0,0x3
    25fe:	6b650513          	addi	a0,a0,1718 # 5cb0 <malloc+0xf4a>
    2602:	00002097          	auipc	ra,0x2
    2606:	35c080e7          	jalr	860(ra) # 495e <open>
    260a:	84aa                	mv	s1,a0
  if(fd < 0){
    260c:	22054f63          	bltz	a0,284a <subdir+0x2e4>
  write(fd, "FF", 2);
    2610:	4609                	li	a2,2
    2612:	00003597          	auipc	a1,0x3
    2616:	6ce58593          	addi	a1,a1,1742 # 5ce0 <malloc+0xf7a>
    261a:	00002097          	auipc	ra,0x2
    261e:	324080e7          	jalr	804(ra) # 493e <write>
  close(fd);
    2622:	8526                	mv	a0,s1
    2624:	00002097          	auipc	ra,0x2
    2628:	322080e7          	jalr	802(ra) # 4946 <close>
  fd = open("dd/dd/../ff", 0);
    262c:	4581                	li	a1,0
    262e:	00003517          	auipc	a0,0x3
    2632:	6ba50513          	addi	a0,a0,1722 # 5ce8 <malloc+0xf82>
    2636:	00002097          	auipc	ra,0x2
    263a:	328080e7          	jalr	808(ra) # 495e <open>
    263e:	84aa                	mv	s1,a0
  if(fd < 0){
    2640:	22054363          	bltz	a0,2866 <subdir+0x300>
  cc = read(fd, buf, sizeof(buf));
    2644:	6609                	lui	a2,0x2
    2646:	80060613          	addi	a2,a2,-2048 # 1800 <forkfork+0x38>
    264a:	00008597          	auipc	a1,0x8
    264e:	24658593          	addi	a1,a1,582 # a890 <buf>
    2652:	00002097          	auipc	ra,0x2
    2656:	2e4080e7          	jalr	740(ra) # 4936 <read>
  if(cc != 2 || buf[0] != 'f'){
    265a:	4789                	li	a5,2
    265c:	22f51363          	bne	a0,a5,2882 <subdir+0x31c>
    2660:	00008717          	auipc	a4,0x8
    2664:	23074703          	lbu	a4,560(a4) # a890 <buf>
    2668:	06600793          	li	a5,102
    266c:	20f71b63          	bne	a4,a5,2882 <subdir+0x31c>
  close(fd);
    2670:	8526                	mv	a0,s1
    2672:	00002097          	auipc	ra,0x2
    2676:	2d4080e7          	jalr	724(ra) # 4946 <close>
  if(remove("dd/dd/ff") != 0){
    267a:	00003517          	auipc	a0,0x3
    267e:	63650513          	addi	a0,a0,1590 # 5cb0 <malloc+0xf4a>
    2682:	00002097          	auipc	ra,0x2
    2686:	344080e7          	jalr	836(ra) # 49c6 <remove>
    268a:	20051a63          	bnez	a0,289e <subdir+0x338>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    268e:	4581                	li	a1,0
    2690:	00003517          	auipc	a0,0x3
    2694:	62050513          	addi	a0,a0,1568 # 5cb0 <malloc+0xf4a>
    2698:	00002097          	auipc	ra,0x2
    269c:	2c6080e7          	jalr	710(ra) # 495e <open>
    26a0:	20055d63          	bgez	a0,28ba <subdir+0x354>
  if(chdir("dd") != 0){
    26a4:	00003517          	auipc	a0,0x3
    26a8:	56c50513          	addi	a0,a0,1388 # 5c10 <malloc+0xeaa>
    26ac:	00002097          	auipc	ra,0x2
    26b0:	2ca080e7          	jalr	714(ra) # 4976 <chdir>
    26b4:	22051163          	bnez	a0,28d6 <subdir+0x370>
  if(chdir("dd/../../dd") != 0){
    26b8:	00003517          	auipc	a0,0x3
    26bc:	6e050513          	addi	a0,a0,1760 # 5d98 <malloc+0x1032>
    26c0:	00002097          	auipc	ra,0x2
    26c4:	2b6080e7          	jalr	694(ra) # 4976 <chdir>
    26c8:	22051563          	bnez	a0,28f2 <subdir+0x38c>
  if(chdir("dd/../../../dd") != 0){
    26cc:	00003517          	auipc	a0,0x3
    26d0:	6fc50513          	addi	a0,a0,1788 # 5dc8 <malloc+0x1062>
    26d4:	00002097          	auipc	ra,0x2
    26d8:	2a2080e7          	jalr	674(ra) # 4976 <chdir>
    26dc:	22051963          	bnez	a0,290e <subdir+0x3a8>
  if(chdir("./..") != 0){
    26e0:	00003517          	auipc	a0,0x3
    26e4:	71850513          	addi	a0,a0,1816 # 5df8 <malloc+0x1092>
    26e8:	00002097          	auipc	ra,0x2
    26ec:	28e080e7          	jalr	654(ra) # 4976 <chdir>
    26f0:	22051d63          	bnez	a0,292a <subdir+0x3c4>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    26f4:	4581                	li	a1,0
    26f6:	00003517          	auipc	a0,0x3
    26fa:	5ba50513          	addi	a0,a0,1466 # 5cb0 <malloc+0xf4a>
    26fe:	00002097          	auipc	ra,0x2
    2702:	260080e7          	jalr	608(ra) # 495e <open>
    2706:	24055063          	bgez	a0,2946 <subdir+0x3e0>
  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    270a:	20200593          	li	a1,514
    270e:	00003517          	auipc	a0,0x3
    2712:	73a50513          	addi	a0,a0,1850 # 5e48 <malloc+0x10e2>
    2716:	00002097          	auipc	ra,0x2
    271a:	248080e7          	jalr	584(ra) # 495e <open>
    271e:	24055263          	bgez	a0,2962 <subdir+0x3fc>
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    2722:	20200593          	li	a1,514
    2726:	00003517          	auipc	a0,0x3
    272a:	75250513          	addi	a0,a0,1874 # 5e78 <malloc+0x1112>
    272e:	00002097          	auipc	ra,0x2
    2732:	230080e7          	jalr	560(ra) # 495e <open>
    2736:	24055463          	bgez	a0,297e <subdir+0x418>
  if(open("dd", O_CREATE) >= 0){
    273a:	20000593          	li	a1,512
    273e:	00003517          	auipc	a0,0x3
    2742:	4d250513          	addi	a0,a0,1234 # 5c10 <malloc+0xeaa>
    2746:	00002097          	auipc	ra,0x2
    274a:	218080e7          	jalr	536(ra) # 495e <open>
    274e:	24055663          	bgez	a0,299a <subdir+0x434>
  if(open("dd", O_RDWR) >= 0){
    2752:	4589                	li	a1,2
    2754:	00003517          	auipc	a0,0x3
    2758:	4bc50513          	addi	a0,a0,1212 # 5c10 <malloc+0xeaa>
    275c:	00002097          	auipc	ra,0x2
    2760:	202080e7          	jalr	514(ra) # 495e <open>
    2764:	24055963          	bgez	a0,29b6 <subdir+0x450>
  if(open("dd", O_WRONLY) >= 0){
    2768:	4585                	li	a1,1
    276a:	00003517          	auipc	a0,0x3
    276e:	4a650513          	addi	a0,a0,1190 # 5c10 <malloc+0xeaa>
    2772:	00002097          	auipc	ra,0x2
    2776:	1ec080e7          	jalr	492(ra) # 495e <open>
    277a:	24055c63          	bgez	a0,29d2 <subdir+0x46c>
  if(remove("dd/ff") != 0){
    277e:	00003517          	auipc	a0,0x3
    2782:	4b250513          	addi	a0,a0,1202 # 5c30 <malloc+0xeca>
    2786:	00002097          	auipc	ra,0x2
    278a:	240080e7          	jalr	576(ra) # 49c6 <remove>
    278e:	26051063          	bnez	a0,29ee <subdir+0x488>
  if(remove("dd") == 0){
    2792:	00003517          	auipc	a0,0x3
    2796:	47e50513          	addi	a0,a0,1150 # 5c10 <malloc+0xeaa>
    279a:	00002097          	auipc	ra,0x2
    279e:	22c080e7          	jalr	556(ra) # 49c6 <remove>
    27a2:	26050463          	beqz	a0,2a0a <subdir+0x4a4>
  if(remove("dd/dd") < 0){
    27a6:	00003517          	auipc	a0,0x3
    27aa:	7aa50513          	addi	a0,a0,1962 # 5f50 <malloc+0x11ea>
    27ae:	00002097          	auipc	ra,0x2
    27b2:	218080e7          	jalr	536(ra) # 49c6 <remove>
    27b6:	26054863          	bltz	a0,2a26 <subdir+0x4c0>
  if(remove("dd") < 0){
    27ba:	00003517          	auipc	a0,0x3
    27be:	45650513          	addi	a0,a0,1110 # 5c10 <malloc+0xeaa>
    27c2:	00002097          	auipc	ra,0x2
    27c6:	204080e7          	jalr	516(ra) # 49c6 <remove>
    27ca:	26054c63          	bltz	a0,2a42 <subdir+0x4dc>
}
    27ce:	60e2                	ld	ra,24(sp)
    27d0:	6442                	ld	s0,16(sp)
    27d2:	64a2                	ld	s1,8(sp)
    27d4:	6902                	ld	s2,0(sp)
    27d6:	6105                	addi	sp,sp,32
    27d8:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    27da:	85ca                	mv	a1,s2
    27dc:	00003517          	auipc	a0,0x3
    27e0:	43c50513          	addi	a0,a0,1084 # 5c18 <malloc+0xeb2>
    27e4:	00002097          	auipc	ra,0x2
    27e8:	4ca080e7          	jalr	1226(ra) # 4cae <printf>
    exit(1);
    27ec:	4505                	li	a0,1
    27ee:	00002097          	auipc	ra,0x2
    27f2:	130080e7          	jalr	304(ra) # 491e <exit>
    printf("%s: create dd/ff failed\n", s);
    27f6:	85ca                	mv	a1,s2
    27f8:	00003517          	auipc	a0,0x3
    27fc:	44050513          	addi	a0,a0,1088 # 5c38 <malloc+0xed2>
    2800:	00002097          	auipc	ra,0x2
    2804:	4ae080e7          	jalr	1198(ra) # 4cae <printf>
    exit(1);
    2808:	4505                	li	a0,1
    280a:	00002097          	auipc	ra,0x2
    280e:	114080e7          	jalr	276(ra) # 491e <exit>
    printf("%s: remove dd (non-empty dir) succeeded!\n", s);
    2812:	85ca                	mv	a1,s2
    2814:	00003517          	auipc	a0,0x3
    2818:	44450513          	addi	a0,a0,1092 # 5c58 <malloc+0xef2>
    281c:	00002097          	auipc	ra,0x2
    2820:	492080e7          	jalr	1170(ra) # 4cae <printf>
    exit(1);
    2824:	4505                	li	a0,1
    2826:	00002097          	auipc	ra,0x2
    282a:	0f8080e7          	jalr	248(ra) # 491e <exit>
    printf("subdir mkdir dd/dd failed\n", s);
    282e:	85ca                	mv	a1,s2
    2830:	00003517          	auipc	a0,0x3
    2834:	46050513          	addi	a0,a0,1120 # 5c90 <malloc+0xf2a>
    2838:	00002097          	auipc	ra,0x2
    283c:	476080e7          	jalr	1142(ra) # 4cae <printf>
    exit(1);
    2840:	4505                	li	a0,1
    2842:	00002097          	auipc	ra,0x2
    2846:	0dc080e7          	jalr	220(ra) # 491e <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    284a:	85ca                	mv	a1,s2
    284c:	00003517          	auipc	a0,0x3
    2850:	47450513          	addi	a0,a0,1140 # 5cc0 <malloc+0xf5a>
    2854:	00002097          	auipc	ra,0x2
    2858:	45a080e7          	jalr	1114(ra) # 4cae <printf>
    exit(1);
    285c:	4505                	li	a0,1
    285e:	00002097          	auipc	ra,0x2
    2862:	0c0080e7          	jalr	192(ra) # 491e <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    2866:	85ca                	mv	a1,s2
    2868:	00003517          	auipc	a0,0x3
    286c:	49050513          	addi	a0,a0,1168 # 5cf8 <malloc+0xf92>
    2870:	00002097          	auipc	ra,0x2
    2874:	43e080e7          	jalr	1086(ra) # 4cae <printf>
    exit(1);
    2878:	4505                	li	a0,1
    287a:	00002097          	auipc	ra,0x2
    287e:	0a4080e7          	jalr	164(ra) # 491e <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    2882:	85ca                	mv	a1,s2
    2884:	00003517          	auipc	a0,0x3
    2888:	49450513          	addi	a0,a0,1172 # 5d18 <malloc+0xfb2>
    288c:	00002097          	auipc	ra,0x2
    2890:	422080e7          	jalr	1058(ra) # 4cae <printf>
    exit(1);
    2894:	4505                	li	a0,1
    2896:	00002097          	auipc	ra,0x2
    289a:	088080e7          	jalr	136(ra) # 491e <exit>
    printf("%s: remove dd/dd/ff failed\n", s);
    289e:	85ca                	mv	a1,s2
    28a0:	00003517          	auipc	a0,0x3
    28a4:	49850513          	addi	a0,a0,1176 # 5d38 <malloc+0xfd2>
    28a8:	00002097          	auipc	ra,0x2
    28ac:	406080e7          	jalr	1030(ra) # 4cae <printf>
    exit(1);
    28b0:	4505                	li	a0,1
    28b2:	00002097          	auipc	ra,0x2
    28b6:	06c080e7          	jalr	108(ra) # 491e <exit>
    printf("%s: open (removeed) dd/dd/ff succeeded\n", s);
    28ba:	85ca                	mv	a1,s2
    28bc:	00003517          	auipc	a0,0x3
    28c0:	49c50513          	addi	a0,a0,1180 # 5d58 <malloc+0xff2>
    28c4:	00002097          	auipc	ra,0x2
    28c8:	3ea080e7          	jalr	1002(ra) # 4cae <printf>
    exit(1);
    28cc:	4505                	li	a0,1
    28ce:	00002097          	auipc	ra,0x2
    28d2:	050080e7          	jalr	80(ra) # 491e <exit>
    printf("%s: chdir dd failed\n", s);
    28d6:	85ca                	mv	a1,s2
    28d8:	00003517          	auipc	a0,0x3
    28dc:	4a850513          	addi	a0,a0,1192 # 5d80 <malloc+0x101a>
    28e0:	00002097          	auipc	ra,0x2
    28e4:	3ce080e7          	jalr	974(ra) # 4cae <printf>
    exit(1);
    28e8:	4505                	li	a0,1
    28ea:	00002097          	auipc	ra,0x2
    28ee:	034080e7          	jalr	52(ra) # 491e <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    28f2:	85ca                	mv	a1,s2
    28f4:	00003517          	auipc	a0,0x3
    28f8:	4b450513          	addi	a0,a0,1204 # 5da8 <malloc+0x1042>
    28fc:	00002097          	auipc	ra,0x2
    2900:	3b2080e7          	jalr	946(ra) # 4cae <printf>
    exit(1);
    2904:	4505                	li	a0,1
    2906:	00002097          	auipc	ra,0x2
    290a:	018080e7          	jalr	24(ra) # 491e <exit>
    printf("chdir dd/../../dd failed\n", s);
    290e:	85ca                	mv	a1,s2
    2910:	00003517          	auipc	a0,0x3
    2914:	4c850513          	addi	a0,a0,1224 # 5dd8 <malloc+0x1072>
    2918:	00002097          	auipc	ra,0x2
    291c:	396080e7          	jalr	918(ra) # 4cae <printf>
    exit(1);
    2920:	4505                	li	a0,1
    2922:	00002097          	auipc	ra,0x2
    2926:	ffc080e7          	jalr	-4(ra) # 491e <exit>
    printf("%s: chdir ./.. failed\n", s);
    292a:	85ca                	mv	a1,s2
    292c:	00003517          	auipc	a0,0x3
    2930:	4d450513          	addi	a0,a0,1236 # 5e00 <malloc+0x109a>
    2934:	00002097          	auipc	ra,0x2
    2938:	37a080e7          	jalr	890(ra) # 4cae <printf>
    exit(1);
    293c:	4505                	li	a0,1
    293e:	00002097          	auipc	ra,0x2
    2942:	fe0080e7          	jalr	-32(ra) # 491e <exit>
    printf("%s: open (removeed) dd/dd/ff succeeded!\n", s);
    2946:	85ca                	mv	a1,s2
    2948:	00003517          	auipc	a0,0x3
    294c:	4d050513          	addi	a0,a0,1232 # 5e18 <malloc+0x10b2>
    2950:	00002097          	auipc	ra,0x2
    2954:	35e080e7          	jalr	862(ra) # 4cae <printf>
    exit(1);
    2958:	4505                	li	a0,1
    295a:	00002097          	auipc	ra,0x2
    295e:	fc4080e7          	jalr	-60(ra) # 491e <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    2962:	85ca                	mv	a1,s2
    2964:	00003517          	auipc	a0,0x3
    2968:	4f450513          	addi	a0,a0,1268 # 5e58 <malloc+0x10f2>
    296c:	00002097          	auipc	ra,0x2
    2970:	342080e7          	jalr	834(ra) # 4cae <printf>
    exit(1);
    2974:	4505                	li	a0,1
    2976:	00002097          	auipc	ra,0x2
    297a:	fa8080e7          	jalr	-88(ra) # 491e <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    297e:	85ca                	mv	a1,s2
    2980:	00003517          	auipc	a0,0x3
    2984:	50850513          	addi	a0,a0,1288 # 5e88 <malloc+0x1122>
    2988:	00002097          	auipc	ra,0x2
    298c:	326080e7          	jalr	806(ra) # 4cae <printf>
    exit(1);
    2990:	4505                	li	a0,1
    2992:	00002097          	auipc	ra,0x2
    2996:	f8c080e7          	jalr	-116(ra) # 491e <exit>
    printf("%s: create dd succeeded!\n", s);
    299a:	85ca                	mv	a1,s2
    299c:	00003517          	auipc	a0,0x3
    29a0:	50c50513          	addi	a0,a0,1292 # 5ea8 <malloc+0x1142>
    29a4:	00002097          	auipc	ra,0x2
    29a8:	30a080e7          	jalr	778(ra) # 4cae <printf>
    exit(1);
    29ac:	4505                	li	a0,1
    29ae:	00002097          	auipc	ra,0x2
    29b2:	f70080e7          	jalr	-144(ra) # 491e <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    29b6:	85ca                	mv	a1,s2
    29b8:	00003517          	auipc	a0,0x3
    29bc:	51050513          	addi	a0,a0,1296 # 5ec8 <malloc+0x1162>
    29c0:	00002097          	auipc	ra,0x2
    29c4:	2ee080e7          	jalr	750(ra) # 4cae <printf>
    exit(1);
    29c8:	4505                	li	a0,1
    29ca:	00002097          	auipc	ra,0x2
    29ce:	f54080e7          	jalr	-172(ra) # 491e <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    29d2:	85ca                	mv	a1,s2
    29d4:	00003517          	auipc	a0,0x3
    29d8:	51450513          	addi	a0,a0,1300 # 5ee8 <malloc+0x1182>
    29dc:	00002097          	auipc	ra,0x2
    29e0:	2d2080e7          	jalr	722(ra) # 4cae <printf>
    exit(1);
    29e4:	4505                	li	a0,1
    29e6:	00002097          	auipc	ra,0x2
    29ea:	f38080e7          	jalr	-200(ra) # 491e <exit>
    printf("%s: remove dd/ff failed\n", s);
    29ee:	85ca                	mv	a1,s2
    29f0:	00003517          	auipc	a0,0x3
    29f4:	51850513          	addi	a0,a0,1304 # 5f08 <malloc+0x11a2>
    29f8:	00002097          	auipc	ra,0x2
    29fc:	2b6080e7          	jalr	694(ra) # 4cae <printf>
    exit(1);
    2a00:	4505                	li	a0,1
    2a02:	00002097          	auipc	ra,0x2
    2a06:	f1c080e7          	jalr	-228(ra) # 491e <exit>
    printf("%s: remove non-empty dd succeeded!\n", s);
    2a0a:	85ca                	mv	a1,s2
    2a0c:	00003517          	auipc	a0,0x3
    2a10:	51c50513          	addi	a0,a0,1308 # 5f28 <malloc+0x11c2>
    2a14:	00002097          	auipc	ra,0x2
    2a18:	29a080e7          	jalr	666(ra) # 4cae <printf>
    exit(1);
    2a1c:	4505                	li	a0,1
    2a1e:	00002097          	auipc	ra,0x2
    2a22:	f00080e7          	jalr	-256(ra) # 491e <exit>
    printf("%s: remove dd/dd failed\n", s);
    2a26:	85ca                	mv	a1,s2
    2a28:	00003517          	auipc	a0,0x3
    2a2c:	53050513          	addi	a0,a0,1328 # 5f58 <malloc+0x11f2>
    2a30:	00002097          	auipc	ra,0x2
    2a34:	27e080e7          	jalr	638(ra) # 4cae <printf>
    exit(1);
    2a38:	4505                	li	a0,1
    2a3a:	00002097          	auipc	ra,0x2
    2a3e:	ee4080e7          	jalr	-284(ra) # 491e <exit>
    printf("%s: remove dd failed\n", s);
    2a42:	85ca                	mv	a1,s2
    2a44:	00003517          	auipc	a0,0x3
    2a48:	53450513          	addi	a0,a0,1332 # 5f78 <malloc+0x1212>
    2a4c:	00002097          	auipc	ra,0x2
    2a50:	262080e7          	jalr	610(ra) # 4cae <printf>
    exit(1);
    2a54:	4505                	li	a0,1
    2a56:	00002097          	auipc	ra,0x2
    2a5a:	ec8080e7          	jalr	-312(ra) # 491e <exit>

0000000000002a5e <rmdot>:
{
    2a5e:	1101                	addi	sp,sp,-32
    2a60:	ec06                	sd	ra,24(sp)
    2a62:	e822                	sd	s0,16(sp)
    2a64:	e426                	sd	s1,8(sp)
    2a66:	1000                	addi	s0,sp,32
    2a68:	84aa                	mv	s1,a0
  if(mkdir("dots") != 0){
    2a6a:	00003517          	auipc	a0,0x3
    2a6e:	52650513          	addi	a0,a0,1318 # 5f90 <malloc+0x122a>
    2a72:	00002097          	auipc	ra,0x2
    2a76:	efc080e7          	jalr	-260(ra) # 496e <mkdir>
    2a7a:	e549                	bnez	a0,2b04 <rmdot+0xa6>
  if(chdir("dots") != 0){
    2a7c:	00003517          	auipc	a0,0x3
    2a80:	51450513          	addi	a0,a0,1300 # 5f90 <malloc+0x122a>
    2a84:	00002097          	auipc	ra,0x2
    2a88:	ef2080e7          	jalr	-270(ra) # 4976 <chdir>
    2a8c:	e951                	bnez	a0,2b20 <rmdot+0xc2>
  if(remove(".") == 0){
    2a8e:	00003517          	auipc	a0,0x3
    2a92:	53a50513          	addi	a0,a0,1338 # 5fc8 <malloc+0x1262>
    2a96:	00002097          	auipc	ra,0x2
    2a9a:	f30080e7          	jalr	-208(ra) # 49c6 <remove>
    2a9e:	cd59                	beqz	a0,2b3c <rmdot+0xde>
  if(remove("..") == 0){
    2aa0:	00003517          	auipc	a0,0x3
    2aa4:	54850513          	addi	a0,a0,1352 # 5fe8 <malloc+0x1282>
    2aa8:	00002097          	auipc	ra,0x2
    2aac:	f1e080e7          	jalr	-226(ra) # 49c6 <remove>
    2ab0:	c545                	beqz	a0,2b58 <rmdot+0xfa>
  if(chdir("/") != 0){
    2ab2:	00003517          	auipc	a0,0x3
    2ab6:	11e50513          	addi	a0,a0,286 # 5bd0 <malloc+0xe6a>
    2aba:	00002097          	auipc	ra,0x2
    2abe:	ebc080e7          	jalr	-324(ra) # 4976 <chdir>
    2ac2:	e94d                	bnez	a0,2b74 <rmdot+0x116>
  if(remove("dots/.") == 0){
    2ac4:	00003517          	auipc	a0,0x3
    2ac8:	54450513          	addi	a0,a0,1348 # 6008 <malloc+0x12a2>
    2acc:	00002097          	auipc	ra,0x2
    2ad0:	efa080e7          	jalr	-262(ra) # 49c6 <remove>
    2ad4:	cd55                	beqz	a0,2b90 <rmdot+0x132>
  if(remove("dots/..") == 0){
    2ad6:	00003517          	auipc	a0,0x3
    2ada:	55a50513          	addi	a0,a0,1370 # 6030 <malloc+0x12ca>
    2ade:	00002097          	auipc	ra,0x2
    2ae2:	ee8080e7          	jalr	-280(ra) # 49c6 <remove>
    2ae6:	c179                	beqz	a0,2bac <rmdot+0x14e>
  if(remove("dots") != 0){
    2ae8:	00003517          	auipc	a0,0x3
    2aec:	4a850513          	addi	a0,a0,1192 # 5f90 <malloc+0x122a>
    2af0:	00002097          	auipc	ra,0x2
    2af4:	ed6080e7          	jalr	-298(ra) # 49c6 <remove>
    2af8:	e961                	bnez	a0,2bc8 <rmdot+0x16a>
}
    2afa:	60e2                	ld	ra,24(sp)
    2afc:	6442                	ld	s0,16(sp)
    2afe:	64a2                	ld	s1,8(sp)
    2b00:	6105                	addi	sp,sp,32
    2b02:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
    2b04:	85a6                	mv	a1,s1
    2b06:	00003517          	auipc	a0,0x3
    2b0a:	49250513          	addi	a0,a0,1170 # 5f98 <malloc+0x1232>
    2b0e:	00002097          	auipc	ra,0x2
    2b12:	1a0080e7          	jalr	416(ra) # 4cae <printf>
    exit(1);
    2b16:	4505                	li	a0,1
    2b18:	00002097          	auipc	ra,0x2
    2b1c:	e06080e7          	jalr	-506(ra) # 491e <exit>
    printf("%s: chdir dots failed\n", s);
    2b20:	85a6                	mv	a1,s1
    2b22:	00003517          	auipc	a0,0x3
    2b26:	48e50513          	addi	a0,a0,1166 # 5fb0 <malloc+0x124a>
    2b2a:	00002097          	auipc	ra,0x2
    2b2e:	184080e7          	jalr	388(ra) # 4cae <printf>
    exit(1);
    2b32:	4505                	li	a0,1
    2b34:	00002097          	auipc	ra,0x2
    2b38:	dea080e7          	jalr	-534(ra) # 491e <exit>
    printf("%s: rm . worked!\n", s);
    2b3c:	85a6                	mv	a1,s1
    2b3e:	00003517          	auipc	a0,0x3
    2b42:	49250513          	addi	a0,a0,1170 # 5fd0 <malloc+0x126a>
    2b46:	00002097          	auipc	ra,0x2
    2b4a:	168080e7          	jalr	360(ra) # 4cae <printf>
    exit(1);
    2b4e:	4505                	li	a0,1
    2b50:	00002097          	auipc	ra,0x2
    2b54:	dce080e7          	jalr	-562(ra) # 491e <exit>
    printf("%s: rm .. worked!\n", s);
    2b58:	85a6                	mv	a1,s1
    2b5a:	00003517          	auipc	a0,0x3
    2b5e:	49650513          	addi	a0,a0,1174 # 5ff0 <malloc+0x128a>
    2b62:	00002097          	auipc	ra,0x2
    2b66:	14c080e7          	jalr	332(ra) # 4cae <printf>
    exit(1);
    2b6a:	4505                	li	a0,1
    2b6c:	00002097          	auipc	ra,0x2
    2b70:	db2080e7          	jalr	-590(ra) # 491e <exit>
    printf("%s: chdir / failed\n", s);
    2b74:	85a6                	mv	a1,s1
    2b76:	00003517          	auipc	a0,0x3
    2b7a:	06250513          	addi	a0,a0,98 # 5bd8 <malloc+0xe72>
    2b7e:	00002097          	auipc	ra,0x2
    2b82:	130080e7          	jalr	304(ra) # 4cae <printf>
    exit(1);
    2b86:	4505                	li	a0,1
    2b88:	00002097          	auipc	ra,0x2
    2b8c:	d96080e7          	jalr	-618(ra) # 491e <exit>
    printf("%s: remove dots/. worked!\n", s);
    2b90:	85a6                	mv	a1,s1
    2b92:	00003517          	auipc	a0,0x3
    2b96:	47e50513          	addi	a0,a0,1150 # 6010 <malloc+0x12aa>
    2b9a:	00002097          	auipc	ra,0x2
    2b9e:	114080e7          	jalr	276(ra) # 4cae <printf>
    exit(1);
    2ba2:	4505                	li	a0,1
    2ba4:	00002097          	auipc	ra,0x2
    2ba8:	d7a080e7          	jalr	-646(ra) # 491e <exit>
    printf("%s: remove dots/.. worked!\n", s);
    2bac:	85a6                	mv	a1,s1
    2bae:	00003517          	auipc	a0,0x3
    2bb2:	48a50513          	addi	a0,a0,1162 # 6038 <malloc+0x12d2>
    2bb6:	00002097          	auipc	ra,0x2
    2bba:	0f8080e7          	jalr	248(ra) # 4cae <printf>
    exit(1);
    2bbe:	4505                	li	a0,1
    2bc0:	00002097          	auipc	ra,0x2
    2bc4:	d5e080e7          	jalr	-674(ra) # 491e <exit>
    printf("%s: remove dots failed!\n", s);
    2bc8:	85a6                	mv	a1,s1
    2bca:	00003517          	auipc	a0,0x3
    2bce:	48e50513          	addi	a0,a0,1166 # 6058 <malloc+0x12f2>
    2bd2:	00002097          	auipc	ra,0x2
    2bd6:	0dc080e7          	jalr	220(ra) # 4cae <printf>
    exit(1);
    2bda:	4505                	li	a0,1
    2bdc:	00002097          	auipc	ra,0x2
    2be0:	d42080e7          	jalr	-702(ra) # 491e <exit>

0000000000002be4 <dirfile>:
{
    2be4:	1101                	addi	sp,sp,-32
    2be6:	ec06                	sd	ra,24(sp)
    2be8:	e822                	sd	s0,16(sp)
    2bea:	e426                	sd	s1,8(sp)
    2bec:	e04a                	sd	s2,0(sp)
    2bee:	1000                	addi	s0,sp,32
    2bf0:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
    2bf2:	20000593          	li	a1,512
    2bf6:	00003517          	auipc	a0,0x3
    2bfa:	48250513          	addi	a0,a0,1154 # 6078 <malloc+0x1312>
    2bfe:	00002097          	auipc	ra,0x2
    2c02:	d60080e7          	jalr	-672(ra) # 495e <open>
  if(fd < 0){
    2c06:	0c054d63          	bltz	a0,2ce0 <dirfile+0xfc>
  close(fd);
    2c0a:	00002097          	auipc	ra,0x2
    2c0e:	d3c080e7          	jalr	-708(ra) # 4946 <close>
  if(chdir("dirfile") == 0){
    2c12:	00003517          	auipc	a0,0x3
    2c16:	46650513          	addi	a0,a0,1126 # 6078 <malloc+0x1312>
    2c1a:	00002097          	auipc	ra,0x2
    2c1e:	d5c080e7          	jalr	-676(ra) # 4976 <chdir>
    2c22:	cd69                	beqz	a0,2cfc <dirfile+0x118>
  fd = open("dirfile/xx", 0);
    2c24:	4581                	li	a1,0
    2c26:	00003517          	auipc	a0,0x3
    2c2a:	49a50513          	addi	a0,a0,1178 # 60c0 <malloc+0x135a>
    2c2e:	00002097          	auipc	ra,0x2
    2c32:	d30080e7          	jalr	-720(ra) # 495e <open>
  if(fd >= 0){
    2c36:	0e055163          	bgez	a0,2d18 <dirfile+0x134>
  fd = open("dirfile/xx", O_CREATE);
    2c3a:	20000593          	li	a1,512
    2c3e:	00003517          	auipc	a0,0x3
    2c42:	48250513          	addi	a0,a0,1154 # 60c0 <malloc+0x135a>
    2c46:	00002097          	auipc	ra,0x2
    2c4a:	d18080e7          	jalr	-744(ra) # 495e <open>
  if(fd >= 0){
    2c4e:	0e055363          	bgez	a0,2d34 <dirfile+0x150>
  if(mkdir("dirfile/xx") == 0){
    2c52:	00003517          	auipc	a0,0x3
    2c56:	46e50513          	addi	a0,a0,1134 # 60c0 <malloc+0x135a>
    2c5a:	00002097          	auipc	ra,0x2
    2c5e:	d14080e7          	jalr	-748(ra) # 496e <mkdir>
    2c62:	c57d                	beqz	a0,2d50 <dirfile+0x16c>
  if(remove("dirfile/xx") == 0){
    2c64:	00003517          	auipc	a0,0x3
    2c68:	45c50513          	addi	a0,a0,1116 # 60c0 <malloc+0x135a>
    2c6c:	00002097          	auipc	ra,0x2
    2c70:	d5a080e7          	jalr	-678(ra) # 49c6 <remove>
    2c74:	cd65                	beqz	a0,2d6c <dirfile+0x188>
  if(remove("dirfile") != 0){
    2c76:	00003517          	auipc	a0,0x3
    2c7a:	40250513          	addi	a0,a0,1026 # 6078 <malloc+0x1312>
    2c7e:	00002097          	auipc	ra,0x2
    2c82:	d48080e7          	jalr	-696(ra) # 49c6 <remove>
    2c86:	10051163          	bnez	a0,2d88 <dirfile+0x1a4>
  fd = open(".", O_RDWR);
    2c8a:	4589                	li	a1,2
    2c8c:	00003517          	auipc	a0,0x3
    2c90:	33c50513          	addi	a0,a0,828 # 5fc8 <malloc+0x1262>
    2c94:	00002097          	auipc	ra,0x2
    2c98:	cca080e7          	jalr	-822(ra) # 495e <open>
  if(fd >= 0){
    2c9c:	10055463          	bgez	a0,2da4 <dirfile+0x1c0>
  fd = open(".", 0);
    2ca0:	4581                	li	a1,0
    2ca2:	00003517          	auipc	a0,0x3
    2ca6:	32650513          	addi	a0,a0,806 # 5fc8 <malloc+0x1262>
    2caa:	00002097          	auipc	ra,0x2
    2cae:	cb4080e7          	jalr	-844(ra) # 495e <open>
    2cb2:	84aa                	mv	s1,a0
  if(write(fd, "x", 1) > 0){
    2cb4:	4605                	li	a2,1
    2cb6:	00002597          	auipc	a1,0x2
    2cba:	29258593          	addi	a1,a1,658 # 4f48 <malloc+0x1e2>
    2cbe:	00002097          	auipc	ra,0x2
    2cc2:	c80080e7          	jalr	-896(ra) # 493e <write>
    2cc6:	0ea04d63          	bgtz	a0,2dc0 <dirfile+0x1dc>
  close(fd);
    2cca:	8526                	mv	a0,s1
    2ccc:	00002097          	auipc	ra,0x2
    2cd0:	c7a080e7          	jalr	-902(ra) # 4946 <close>
}
    2cd4:	60e2                	ld	ra,24(sp)
    2cd6:	6442                	ld	s0,16(sp)
    2cd8:	64a2                	ld	s1,8(sp)
    2cda:	6902                	ld	s2,0(sp)
    2cdc:	6105                	addi	sp,sp,32
    2cde:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    2ce0:	85ca                	mv	a1,s2
    2ce2:	00003517          	auipc	a0,0x3
    2ce6:	39e50513          	addi	a0,a0,926 # 6080 <malloc+0x131a>
    2cea:	00002097          	auipc	ra,0x2
    2cee:	fc4080e7          	jalr	-60(ra) # 4cae <printf>
    exit(1);
    2cf2:	4505                	li	a0,1
    2cf4:	00002097          	auipc	ra,0x2
    2cf8:	c2a080e7          	jalr	-982(ra) # 491e <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    2cfc:	85ca                	mv	a1,s2
    2cfe:	00003517          	auipc	a0,0x3
    2d02:	3a250513          	addi	a0,a0,930 # 60a0 <malloc+0x133a>
    2d06:	00002097          	auipc	ra,0x2
    2d0a:	fa8080e7          	jalr	-88(ra) # 4cae <printf>
    exit(1);
    2d0e:	4505                	li	a0,1
    2d10:	00002097          	auipc	ra,0x2
    2d14:	c0e080e7          	jalr	-1010(ra) # 491e <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    2d18:	85ca                	mv	a1,s2
    2d1a:	00003517          	auipc	a0,0x3
    2d1e:	3b650513          	addi	a0,a0,950 # 60d0 <malloc+0x136a>
    2d22:	00002097          	auipc	ra,0x2
    2d26:	f8c080e7          	jalr	-116(ra) # 4cae <printf>
    exit(1);
    2d2a:	4505                	li	a0,1
    2d2c:	00002097          	auipc	ra,0x2
    2d30:	bf2080e7          	jalr	-1038(ra) # 491e <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    2d34:	85ca                	mv	a1,s2
    2d36:	00003517          	auipc	a0,0x3
    2d3a:	39a50513          	addi	a0,a0,922 # 60d0 <malloc+0x136a>
    2d3e:	00002097          	auipc	ra,0x2
    2d42:	f70080e7          	jalr	-144(ra) # 4cae <printf>
    exit(1);
    2d46:	4505                	li	a0,1
    2d48:	00002097          	auipc	ra,0x2
    2d4c:	bd6080e7          	jalr	-1066(ra) # 491e <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    2d50:	85ca                	mv	a1,s2
    2d52:	00003517          	auipc	a0,0x3
    2d56:	3a650513          	addi	a0,a0,934 # 60f8 <malloc+0x1392>
    2d5a:	00002097          	auipc	ra,0x2
    2d5e:	f54080e7          	jalr	-172(ra) # 4cae <printf>
    exit(1);
    2d62:	4505                	li	a0,1
    2d64:	00002097          	auipc	ra,0x2
    2d68:	bba080e7          	jalr	-1094(ra) # 491e <exit>
    printf("%s: remove dirfile/xx succeeded!\n", s);
    2d6c:	85ca                	mv	a1,s2
    2d6e:	00003517          	auipc	a0,0x3
    2d72:	3b250513          	addi	a0,a0,946 # 6120 <malloc+0x13ba>
    2d76:	00002097          	auipc	ra,0x2
    2d7a:	f38080e7          	jalr	-200(ra) # 4cae <printf>
    exit(1);
    2d7e:	4505                	li	a0,1
    2d80:	00002097          	auipc	ra,0x2
    2d84:	b9e080e7          	jalr	-1122(ra) # 491e <exit>
    printf("%s: remove dirfile failed!\n", s);
    2d88:	85ca                	mv	a1,s2
    2d8a:	00003517          	auipc	a0,0x3
    2d8e:	3be50513          	addi	a0,a0,958 # 6148 <malloc+0x13e2>
    2d92:	00002097          	auipc	ra,0x2
    2d96:	f1c080e7          	jalr	-228(ra) # 4cae <printf>
    exit(1);
    2d9a:	4505                	li	a0,1
    2d9c:	00002097          	auipc	ra,0x2
    2da0:	b82080e7          	jalr	-1150(ra) # 491e <exit>
    printf("%s: open . for writing succeeded!\n", s);
    2da4:	85ca                	mv	a1,s2
    2da6:	00003517          	auipc	a0,0x3
    2daa:	3c250513          	addi	a0,a0,962 # 6168 <malloc+0x1402>
    2dae:	00002097          	auipc	ra,0x2
    2db2:	f00080e7          	jalr	-256(ra) # 4cae <printf>
    exit(1);
    2db6:	4505                	li	a0,1
    2db8:	00002097          	auipc	ra,0x2
    2dbc:	b66080e7          	jalr	-1178(ra) # 491e <exit>
    printf("%s: write . succeeded!\n", s);
    2dc0:	85ca                	mv	a1,s2
    2dc2:	00003517          	auipc	a0,0x3
    2dc6:	3ce50513          	addi	a0,a0,974 # 6190 <malloc+0x142a>
    2dca:	00002097          	auipc	ra,0x2
    2dce:	ee4080e7          	jalr	-284(ra) # 4cae <printf>
    exit(1);
    2dd2:	4505                	li	a0,1
    2dd4:	00002097          	auipc	ra,0x2
    2dd8:	b4a080e7          	jalr	-1206(ra) # 491e <exit>

0000000000002ddc <iref>:
{
    2ddc:	7139                	addi	sp,sp,-64
    2dde:	fc06                	sd	ra,56(sp)
    2de0:	f822                	sd	s0,48(sp)
    2de2:	f426                	sd	s1,40(sp)
    2de4:	f04a                	sd	s2,32(sp)
    2de6:	ec4e                	sd	s3,24(sp)
    2de8:	e852                	sd	s4,16(sp)
    2dea:	e456                	sd	s5,8(sp)
    2dec:	0080                	addi	s0,sp,64
    2dee:	8aaa                	mv	s5,a0
    2df0:	02e00493          	li	s1,46
    if(mkdir("irefd") != 0){
    2df4:	00003917          	auipc	s2,0x3
    2df8:	3b490913          	addi	s2,s2,948 # 61a8 <malloc+0x1442>
    mkdir("");
    2dfc:	00003a17          	auipc	s4,0x3
    2e00:	044a0a13          	addi	s4,s4,68 # 5e40 <malloc+0x10da>
    fd = open("xx", O_CREATE);
    2e04:	00003997          	auipc	s3,0x3
    2e08:	2c498993          	addi	s3,s3,708 # 60c8 <malloc+0x1362>
    2e0c:	a889                	j	2e5e <iref+0x82>
      printf("%s: mkdir irefd failed\n", s);
    2e0e:	85d6                	mv	a1,s5
    2e10:	00003517          	auipc	a0,0x3
    2e14:	3a050513          	addi	a0,a0,928 # 61b0 <malloc+0x144a>
    2e18:	00002097          	auipc	ra,0x2
    2e1c:	e96080e7          	jalr	-362(ra) # 4cae <printf>
      exit(1);
    2e20:	4505                	li	a0,1
    2e22:	00002097          	auipc	ra,0x2
    2e26:	afc080e7          	jalr	-1284(ra) # 491e <exit>
      printf("%s: chdir irefd failed\n", s);
    2e2a:	85d6                	mv	a1,s5
    2e2c:	00003517          	auipc	a0,0x3
    2e30:	39c50513          	addi	a0,a0,924 # 61c8 <malloc+0x1462>
    2e34:	00002097          	auipc	ra,0x2
    2e38:	e7a080e7          	jalr	-390(ra) # 4cae <printf>
      exit(1);
    2e3c:	4505                	li	a0,1
    2e3e:	00002097          	auipc	ra,0x2
    2e42:	ae0080e7          	jalr	-1312(ra) # 491e <exit>
      close(fd);
    2e46:	00002097          	auipc	ra,0x2
    2e4a:	b00080e7          	jalr	-1280(ra) # 4946 <close>
    2e4e:	a091                	j	2e92 <iref+0xb6>
    remove("xx");
    2e50:	854e                	mv	a0,s3
    2e52:	00002097          	auipc	ra,0x2
    2e56:	b74080e7          	jalr	-1164(ra) # 49c6 <remove>
  for(i = 0; i < NINODE - 4; i++){
    2e5a:	34fd                	addiw	s1,s1,-1
    2e5c:	c8a9                	beqz	s1,2eae <iref+0xd2>
    if(mkdir("irefd") != 0){
    2e5e:	854a                	mv	a0,s2
    2e60:	00002097          	auipc	ra,0x2
    2e64:	b0e080e7          	jalr	-1266(ra) # 496e <mkdir>
    2e68:	f15d                	bnez	a0,2e0e <iref+0x32>
    if(chdir("irefd") != 0){
    2e6a:	854a                	mv	a0,s2
    2e6c:	00002097          	auipc	ra,0x2
    2e70:	b0a080e7          	jalr	-1270(ra) # 4976 <chdir>
    2e74:	f95d                	bnez	a0,2e2a <iref+0x4e>
    mkdir("");
    2e76:	8552                	mv	a0,s4
    2e78:	00002097          	auipc	ra,0x2
    2e7c:	af6080e7          	jalr	-1290(ra) # 496e <mkdir>
    fd = open("", O_CREATE);
    2e80:	20000593          	li	a1,512
    2e84:	8552                	mv	a0,s4
    2e86:	00002097          	auipc	ra,0x2
    2e8a:	ad8080e7          	jalr	-1320(ra) # 495e <open>
    if(fd >= 0)
    2e8e:	fa055ce3          	bgez	a0,2e46 <iref+0x6a>
    fd = open("xx", O_CREATE);
    2e92:	20000593          	li	a1,512
    2e96:	854e                	mv	a0,s3
    2e98:	00002097          	auipc	ra,0x2
    2e9c:	ac6080e7          	jalr	-1338(ra) # 495e <open>
    if(fd >= 0)
    2ea0:	fa0548e3          	bltz	a0,2e50 <iref+0x74>
      close(fd);
    2ea4:	00002097          	auipc	ra,0x2
    2ea8:	aa2080e7          	jalr	-1374(ra) # 4946 <close>
    2eac:	b755                	j	2e50 <iref+0x74>
    2eae:	03300493          	li	s1,51
    chdir("..");
    2eb2:	00003997          	auipc	s3,0x3
    2eb6:	13698993          	addi	s3,s3,310 # 5fe8 <malloc+0x1282>
    remove("irefd");
    2eba:	00003917          	auipc	s2,0x3
    2ebe:	2ee90913          	addi	s2,s2,750 # 61a8 <malloc+0x1442>
    chdir("..");
    2ec2:	854e                	mv	a0,s3
    2ec4:	00002097          	auipc	ra,0x2
    2ec8:	ab2080e7          	jalr	-1358(ra) # 4976 <chdir>
    remove("irefd");
    2ecc:	854a                	mv	a0,s2
    2ece:	00002097          	auipc	ra,0x2
    2ed2:	af8080e7          	jalr	-1288(ra) # 49c6 <remove>
  for(i = 0; i < NINODE + 1; i++){
    2ed6:	34fd                	addiw	s1,s1,-1
    2ed8:	f4ed                	bnez	s1,2ec2 <iref+0xe6>
  chdir("/");
    2eda:	00003517          	auipc	a0,0x3
    2ede:	cf650513          	addi	a0,a0,-778 # 5bd0 <malloc+0xe6a>
    2ee2:	00002097          	auipc	ra,0x2
    2ee6:	a94080e7          	jalr	-1388(ra) # 4976 <chdir>
}
    2eea:	70e2                	ld	ra,56(sp)
    2eec:	7442                	ld	s0,48(sp)
    2eee:	74a2                	ld	s1,40(sp)
    2ef0:	7902                	ld	s2,32(sp)
    2ef2:	69e2                	ld	s3,24(sp)
    2ef4:	6a42                	ld	s4,16(sp)
    2ef6:	6aa2                	ld	s5,8(sp)
    2ef8:	6121                	addi	sp,sp,64
    2efa:	8082                	ret

0000000000002efc <openiputtest>:
{
    2efc:	7179                	addi	sp,sp,-48
    2efe:	f406                	sd	ra,40(sp)
    2f00:	f022                	sd	s0,32(sp)
    2f02:	ec26                	sd	s1,24(sp)
    2f04:	1800                	addi	s0,sp,48
    2f06:	84aa                	mv	s1,a0
  if(mkdir("oidir") < 0){
    2f08:	00003517          	auipc	a0,0x3
    2f0c:	2d850513          	addi	a0,a0,728 # 61e0 <malloc+0x147a>
    2f10:	00002097          	auipc	ra,0x2
    2f14:	a5e080e7          	jalr	-1442(ra) # 496e <mkdir>
    2f18:	04054263          	bltz	a0,2f5c <openiputtest+0x60>
  pid = fork();
    2f1c:	00002097          	auipc	ra,0x2
    2f20:	9fa080e7          	jalr	-1542(ra) # 4916 <fork>
  if(pid < 0){
    2f24:	04054a63          	bltz	a0,2f78 <openiputtest+0x7c>
  if(pid == 0){
    2f28:	e93d                	bnez	a0,2f9e <openiputtest+0xa2>
    int fd = open("oidir", O_RDWR);
    2f2a:	4589                	li	a1,2
    2f2c:	00003517          	auipc	a0,0x3
    2f30:	2b450513          	addi	a0,a0,692 # 61e0 <malloc+0x147a>
    2f34:	00002097          	auipc	ra,0x2
    2f38:	a2a080e7          	jalr	-1494(ra) # 495e <open>
    if(fd >= 0){
    2f3c:	04054c63          	bltz	a0,2f94 <openiputtest+0x98>
      printf("%s: open directory for write succeeded\n", s);
    2f40:	85a6                	mv	a1,s1
    2f42:	00003517          	auipc	a0,0x3
    2f46:	2be50513          	addi	a0,a0,702 # 6200 <malloc+0x149a>
    2f4a:	00002097          	auipc	ra,0x2
    2f4e:	d64080e7          	jalr	-668(ra) # 4cae <printf>
      exit(1);
    2f52:	4505                	li	a0,1
    2f54:	00002097          	auipc	ra,0x2
    2f58:	9ca080e7          	jalr	-1590(ra) # 491e <exit>
    printf("%s: mkdir oidir failed\n", s);
    2f5c:	85a6                	mv	a1,s1
    2f5e:	00003517          	auipc	a0,0x3
    2f62:	28a50513          	addi	a0,a0,650 # 61e8 <malloc+0x1482>
    2f66:	00002097          	auipc	ra,0x2
    2f6a:	d48080e7          	jalr	-696(ra) # 4cae <printf>
    exit(1);
    2f6e:	4505                	li	a0,1
    2f70:	00002097          	auipc	ra,0x2
    2f74:	9ae080e7          	jalr	-1618(ra) # 491e <exit>
    printf("%s: fork failed\n", s);
    2f78:	85a6                	mv	a1,s1
    2f7a:	00002517          	auipc	a0,0x2
    2f7e:	5ee50513          	addi	a0,a0,1518 # 5568 <malloc+0x802>
    2f82:	00002097          	auipc	ra,0x2
    2f86:	d2c080e7          	jalr	-724(ra) # 4cae <printf>
    exit(1);
    2f8a:	4505                	li	a0,1
    2f8c:	00002097          	auipc	ra,0x2
    2f90:	992080e7          	jalr	-1646(ra) # 491e <exit>
    exit(0);
    2f94:	4501                	li	a0,0
    2f96:	00002097          	auipc	ra,0x2
    2f9a:	988080e7          	jalr	-1656(ra) # 491e <exit>
  sleep(1);
    2f9e:	4505                	li	a0,1
    2fa0:	00002097          	auipc	ra,0x2
    2fa4:	9f6080e7          	jalr	-1546(ra) # 4996 <sleep>
  if(remove("oidir") != 0){
    2fa8:	00003517          	auipc	a0,0x3
    2fac:	23850513          	addi	a0,a0,568 # 61e0 <malloc+0x147a>
    2fb0:	00002097          	auipc	ra,0x2
    2fb4:	a16080e7          	jalr	-1514(ra) # 49c6 <remove>
    2fb8:	cd19                	beqz	a0,2fd6 <openiputtest+0xda>
    printf("%s: remove failed\n", s);
    2fba:	85a6                	mv	a1,s1
    2fbc:	00003517          	auipc	a0,0x3
    2fc0:	26c50513          	addi	a0,a0,620 # 6228 <malloc+0x14c2>
    2fc4:	00002097          	auipc	ra,0x2
    2fc8:	cea080e7          	jalr	-790(ra) # 4cae <printf>
    exit(1);
    2fcc:	4505                	li	a0,1
    2fce:	00002097          	auipc	ra,0x2
    2fd2:	950080e7          	jalr	-1712(ra) # 491e <exit>
  wait(&xstatus);
    2fd6:	fdc40513          	addi	a0,s0,-36
    2fda:	00002097          	auipc	ra,0x2
    2fde:	94c080e7          	jalr	-1716(ra) # 4926 <wait>
  exit(xstatus);
    2fe2:	fdc42503          	lw	a0,-36(s0)
    2fe6:	00002097          	auipc	ra,0x2
    2fea:	938080e7          	jalr	-1736(ra) # 491e <exit>

0000000000002fee <forkforkfork>:
{
    2fee:	1101                	addi	sp,sp,-32
    2ff0:	ec06                	sd	ra,24(sp)
    2ff2:	e822                	sd	s0,16(sp)
    2ff4:	e426                	sd	s1,8(sp)
    2ff6:	1000                	addi	s0,sp,32
    2ff8:	84aa                	mv	s1,a0
  remove("stopforking");
    2ffa:	00003517          	auipc	a0,0x3
    2ffe:	24650513          	addi	a0,a0,582 # 6240 <malloc+0x14da>
    3002:	00002097          	auipc	ra,0x2
    3006:	9c4080e7          	jalr	-1596(ra) # 49c6 <remove>
  int pid = fork();
    300a:	00002097          	auipc	ra,0x2
    300e:	90c080e7          	jalr	-1780(ra) # 4916 <fork>
  if(pid < 0){
    3012:	04054d63          	bltz	a0,306c <forkforkfork+0x7e>
  if(pid == 0){
    3016:	c92d                	beqz	a0,3088 <forkforkfork+0x9a>
  sleep(20); // two seconds
    3018:	4551                	li	a0,20
    301a:	00002097          	auipc	ra,0x2
    301e:	97c080e7          	jalr	-1668(ra) # 4996 <sleep>
  close(open("stopforking", O_CREATE|O_RDWR));
    3022:	20200593          	li	a1,514
    3026:	00003517          	auipc	a0,0x3
    302a:	21a50513          	addi	a0,a0,538 # 6240 <malloc+0x14da>
    302e:	00002097          	auipc	ra,0x2
    3032:	930080e7          	jalr	-1744(ra) # 495e <open>
    3036:	00002097          	auipc	ra,0x2
    303a:	910080e7          	jalr	-1776(ra) # 4946 <close>
  wait(0);
    303e:	4501                	li	a0,0
    3040:	00002097          	auipc	ra,0x2
    3044:	8e6080e7          	jalr	-1818(ra) # 4926 <wait>
  sleep(10); // one second
    3048:	4529                	li	a0,10
    304a:	00002097          	auipc	ra,0x2
    304e:	94c080e7          	jalr	-1716(ra) # 4996 <sleep>
  remove("stopforking");
    3052:	00003517          	auipc	a0,0x3
    3056:	1ee50513          	addi	a0,a0,494 # 6240 <malloc+0x14da>
    305a:	00002097          	auipc	ra,0x2
    305e:	96c080e7          	jalr	-1684(ra) # 49c6 <remove>
}
    3062:	60e2                	ld	ra,24(sp)
    3064:	6442                	ld	s0,16(sp)
    3066:	64a2                	ld	s1,8(sp)
    3068:	6105                	addi	sp,sp,32
    306a:	8082                	ret
    printf("%s: fork failed", s);
    306c:	85a6                	mv	a1,s1
    306e:	00002517          	auipc	a0,0x2
    3072:	6ba50513          	addi	a0,a0,1722 # 5728 <malloc+0x9c2>
    3076:	00002097          	auipc	ra,0x2
    307a:	c38080e7          	jalr	-968(ra) # 4cae <printf>
    exit(1);
    307e:	4505                	li	a0,1
    3080:	00002097          	auipc	ra,0x2
    3084:	89e080e7          	jalr	-1890(ra) # 491e <exit>
      int fd = open("stopforking", 0);
    3088:	00003497          	auipc	s1,0x3
    308c:	1b848493          	addi	s1,s1,440 # 6240 <malloc+0x14da>
    3090:	4581                	li	a1,0
    3092:	8526                	mv	a0,s1
    3094:	00002097          	auipc	ra,0x2
    3098:	8ca080e7          	jalr	-1846(ra) # 495e <open>
      if(fd >= 0){
    309c:	02055763          	bgez	a0,30ca <forkforkfork+0xdc>
      if(fork() < 0){
    30a0:	00002097          	auipc	ra,0x2
    30a4:	876080e7          	jalr	-1930(ra) # 4916 <fork>
    30a8:	fe0554e3          	bgez	a0,3090 <forkforkfork+0xa2>
        close(open("stopforking", O_CREATE|O_RDWR));
    30ac:	20200593          	li	a1,514
    30b0:	00003517          	auipc	a0,0x3
    30b4:	19050513          	addi	a0,a0,400 # 6240 <malloc+0x14da>
    30b8:	00002097          	auipc	ra,0x2
    30bc:	8a6080e7          	jalr	-1882(ra) # 495e <open>
    30c0:	00002097          	auipc	ra,0x2
    30c4:	886080e7          	jalr	-1914(ra) # 4946 <close>
    30c8:	b7e1                	j	3090 <forkforkfork+0xa2>
        exit(0);
    30ca:	4501                	li	a0,0
    30cc:	00002097          	auipc	ra,0x2
    30d0:	852080e7          	jalr	-1966(ra) # 491e <exit>

00000000000030d4 <preempt>:
{
    30d4:	7139                	addi	sp,sp,-64
    30d6:	fc06                	sd	ra,56(sp)
    30d8:	f822                	sd	s0,48(sp)
    30da:	f426                	sd	s1,40(sp)
    30dc:	f04a                	sd	s2,32(sp)
    30de:	ec4e                	sd	s3,24(sp)
    30e0:	e852                	sd	s4,16(sp)
    30e2:	0080                	addi	s0,sp,64
    30e4:	892a                	mv	s2,a0
  pid1 = fork();
    30e6:	00002097          	auipc	ra,0x2
    30ea:	830080e7          	jalr	-2000(ra) # 4916 <fork>
  if(pid1 < 0) {
    30ee:	00054563          	bltz	a0,30f8 <preempt+0x24>
    30f2:	84aa                	mv	s1,a0
  if(pid1 == 0)
    30f4:	ed19                	bnez	a0,3112 <preempt+0x3e>
    for(;;)
    30f6:	a001                	j	30f6 <preempt+0x22>
    printf("%s: fork failed");
    30f8:	00002517          	auipc	a0,0x2
    30fc:	63050513          	addi	a0,a0,1584 # 5728 <malloc+0x9c2>
    3100:	00002097          	auipc	ra,0x2
    3104:	bae080e7          	jalr	-1106(ra) # 4cae <printf>
    exit(1);
    3108:	4505                	li	a0,1
    310a:	00002097          	auipc	ra,0x2
    310e:	814080e7          	jalr	-2028(ra) # 491e <exit>
  pid2 = fork();
    3112:	00002097          	auipc	ra,0x2
    3116:	804080e7          	jalr	-2044(ra) # 4916 <fork>
    311a:	89aa                	mv	s3,a0
  if(pid2 < 0) {
    311c:	00054463          	bltz	a0,3124 <preempt+0x50>
  if(pid2 == 0)
    3120:	e105                	bnez	a0,3140 <preempt+0x6c>
    for(;;)
    3122:	a001                	j	3122 <preempt+0x4e>
    printf("%s: fork failed\n", s);
    3124:	85ca                	mv	a1,s2
    3126:	00002517          	auipc	a0,0x2
    312a:	44250513          	addi	a0,a0,1090 # 5568 <malloc+0x802>
    312e:	00002097          	auipc	ra,0x2
    3132:	b80080e7          	jalr	-1152(ra) # 4cae <printf>
    exit(1);
    3136:	4505                	li	a0,1
    3138:	00001097          	auipc	ra,0x1
    313c:	7e6080e7          	jalr	2022(ra) # 491e <exit>
  pipe(pfds);
    3140:	fc840513          	addi	a0,s0,-56
    3144:	00001097          	auipc	ra,0x1
    3148:	7ea080e7          	jalr	2026(ra) # 492e <pipe>
  pid3 = fork();
    314c:	00001097          	auipc	ra,0x1
    3150:	7ca080e7          	jalr	1994(ra) # 4916 <fork>
    3154:	8a2a                	mv	s4,a0
  if(pid3 < 0) {
    3156:	02054e63          	bltz	a0,3192 <preempt+0xbe>
  if(pid3 == 0){
    315a:	e13d                	bnez	a0,31c0 <preempt+0xec>
    close(pfds[0]);
    315c:	fc842503          	lw	a0,-56(s0)
    3160:	00001097          	auipc	ra,0x1
    3164:	7e6080e7          	jalr	2022(ra) # 4946 <close>
    if(write(pfds[1], "x", 1) != 1)
    3168:	4605                	li	a2,1
    316a:	00002597          	auipc	a1,0x2
    316e:	dde58593          	addi	a1,a1,-546 # 4f48 <malloc+0x1e2>
    3172:	fcc42503          	lw	a0,-52(s0)
    3176:	00001097          	auipc	ra,0x1
    317a:	7c8080e7          	jalr	1992(ra) # 493e <write>
    317e:	4785                	li	a5,1
    3180:	02f51763          	bne	a0,a5,31ae <preempt+0xda>
    close(pfds[1]);
    3184:	fcc42503          	lw	a0,-52(s0)
    3188:	00001097          	auipc	ra,0x1
    318c:	7be080e7          	jalr	1982(ra) # 4946 <close>
    for(;;)
    3190:	a001                	j	3190 <preempt+0xbc>
     printf("%s: fork failed\n", s);
    3192:	85ca                	mv	a1,s2
    3194:	00002517          	auipc	a0,0x2
    3198:	3d450513          	addi	a0,a0,980 # 5568 <malloc+0x802>
    319c:	00002097          	auipc	ra,0x2
    31a0:	b12080e7          	jalr	-1262(ra) # 4cae <printf>
     exit(1);
    31a4:	4505                	li	a0,1
    31a6:	00001097          	auipc	ra,0x1
    31aa:	778080e7          	jalr	1912(ra) # 491e <exit>
      printf("%s: preempt write error");
    31ae:	00003517          	auipc	a0,0x3
    31b2:	0a250513          	addi	a0,a0,162 # 6250 <malloc+0x14ea>
    31b6:	00002097          	auipc	ra,0x2
    31ba:	af8080e7          	jalr	-1288(ra) # 4cae <printf>
    31be:	b7d9                	j	3184 <preempt+0xb0>
  close(pfds[1]);
    31c0:	fcc42503          	lw	a0,-52(s0)
    31c4:	00001097          	auipc	ra,0x1
    31c8:	782080e7          	jalr	1922(ra) # 4946 <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
    31cc:	6609                	lui	a2,0x2
    31ce:	80060613          	addi	a2,a2,-2048 # 1800 <forkfork+0x38>
    31d2:	00007597          	auipc	a1,0x7
    31d6:	6be58593          	addi	a1,a1,1726 # a890 <buf>
    31da:	fc842503          	lw	a0,-56(s0)
    31de:	00001097          	auipc	ra,0x1
    31e2:	758080e7          	jalr	1880(ra) # 4936 <read>
    31e6:	4785                	li	a5,1
    31e8:	02f50263          	beq	a0,a5,320c <preempt+0x138>
    printf("%s: preempt read error");
    31ec:	00003517          	auipc	a0,0x3
    31f0:	07c50513          	addi	a0,a0,124 # 6268 <malloc+0x1502>
    31f4:	00002097          	auipc	ra,0x2
    31f8:	aba080e7          	jalr	-1350(ra) # 4cae <printf>
}
    31fc:	70e2                	ld	ra,56(sp)
    31fe:	7442                	ld	s0,48(sp)
    3200:	74a2                	ld	s1,40(sp)
    3202:	7902                	ld	s2,32(sp)
    3204:	69e2                	ld	s3,24(sp)
    3206:	6a42                	ld	s4,16(sp)
    3208:	6121                	addi	sp,sp,64
    320a:	8082                	ret
  close(pfds[0]);
    320c:	fc842503          	lw	a0,-56(s0)
    3210:	00001097          	auipc	ra,0x1
    3214:	736080e7          	jalr	1846(ra) # 4946 <close>
  printf("kill... ");
    3218:	00003517          	auipc	a0,0x3
    321c:	06850513          	addi	a0,a0,104 # 6280 <malloc+0x151a>
    3220:	00002097          	auipc	ra,0x2
    3224:	a8e080e7          	jalr	-1394(ra) # 4cae <printf>
  kill(pid1);
    3228:	8526                	mv	a0,s1
    322a:	00001097          	auipc	ra,0x1
    322e:	724080e7          	jalr	1828(ra) # 494e <kill>
  kill(pid2);
    3232:	854e                	mv	a0,s3
    3234:	00001097          	auipc	ra,0x1
    3238:	71a080e7          	jalr	1818(ra) # 494e <kill>
  kill(pid3);
    323c:	8552                	mv	a0,s4
    323e:	00001097          	auipc	ra,0x1
    3242:	710080e7          	jalr	1808(ra) # 494e <kill>
  printf("wait... ");
    3246:	00003517          	auipc	a0,0x3
    324a:	04a50513          	addi	a0,a0,74 # 6290 <malloc+0x152a>
    324e:	00002097          	auipc	ra,0x2
    3252:	a60080e7          	jalr	-1440(ra) # 4cae <printf>
  wait(0);
    3256:	4501                	li	a0,0
    3258:	00001097          	auipc	ra,0x1
    325c:	6ce080e7          	jalr	1742(ra) # 4926 <wait>
  wait(0);
    3260:	4501                	li	a0,0
    3262:	00001097          	auipc	ra,0x1
    3266:	6c4080e7          	jalr	1732(ra) # 4926 <wait>
  wait(0);
    326a:	4501                	li	a0,0
    326c:	00001097          	auipc	ra,0x1
    3270:	6ba080e7          	jalr	1722(ra) # 4926 <wait>
    3274:	b761                	j	31fc <preempt+0x128>

0000000000003276 <sbrkfail>:
{
    3276:	7119                	addi	sp,sp,-128
    3278:	fc86                	sd	ra,120(sp)
    327a:	f8a2                	sd	s0,112(sp)
    327c:	f4a6                	sd	s1,104(sp)
    327e:	f0ca                	sd	s2,96(sp)
    3280:	ecce                	sd	s3,88(sp)
    3282:	e8d2                	sd	s4,80(sp)
    3284:	e4d6                	sd	s5,72(sp)
    3286:	0100                	addi	s0,sp,128
    3288:	8aaa                	mv	s5,a0
  if(pipe(fds) != 0){
    328a:	fb040513          	addi	a0,s0,-80
    328e:	00001097          	auipc	ra,0x1
    3292:	6a0080e7          	jalr	1696(ra) # 492e <pipe>
    3296:	e901                	bnez	a0,32a6 <sbrkfail+0x30>
    3298:	f8040493          	addi	s1,s0,-128
    329c:	fa840993          	addi	s3,s0,-88
    32a0:	8926                	mv	s2,s1
    if(pids[i] != -1)
    32a2:	5a7d                	li	s4,-1
    32a4:	a085                	j	3304 <sbrkfail+0x8e>
    printf("%s: pipe() failed\n", s);
    32a6:	85d6                	mv	a1,s5
    32a8:	00002517          	auipc	a0,0x2
    32ac:	3c850513          	addi	a0,a0,968 # 5670 <malloc+0x90a>
    32b0:	00002097          	auipc	ra,0x2
    32b4:	9fe080e7          	jalr	-1538(ra) # 4cae <printf>
    exit(1);
    32b8:	4505                	li	a0,1
    32ba:	00001097          	auipc	ra,0x1
    32be:	664080e7          	jalr	1636(ra) # 491e <exit>
      sbrk(BIG - (uint64)sbrk(0));
    32c2:	00001097          	auipc	ra,0x1
    32c6:	6cc080e7          	jalr	1740(ra) # 498e <sbrk>
    32ca:	064007b7          	lui	a5,0x6400
    32ce:	40a7853b          	subw	a0,a5,a0
    32d2:	00001097          	auipc	ra,0x1
    32d6:	6bc080e7          	jalr	1724(ra) # 498e <sbrk>
      write(fds[1], "x", 1);
    32da:	4605                	li	a2,1
    32dc:	00002597          	auipc	a1,0x2
    32e0:	c6c58593          	addi	a1,a1,-916 # 4f48 <malloc+0x1e2>
    32e4:	fb442503          	lw	a0,-76(s0)
    32e8:	00001097          	auipc	ra,0x1
    32ec:	656080e7          	jalr	1622(ra) # 493e <write>
      for(;;) sleep(1000);
    32f0:	3e800513          	li	a0,1000
    32f4:	00001097          	auipc	ra,0x1
    32f8:	6a2080e7          	jalr	1698(ra) # 4996 <sleep>
    32fc:	bfd5                	j	32f0 <sbrkfail+0x7a>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    32fe:	0911                	addi	s2,s2,4
    3300:	03390563          	beq	s2,s3,332a <sbrkfail+0xb4>
    if((pids[i] = fork()) == 0){
    3304:	00001097          	auipc	ra,0x1
    3308:	612080e7          	jalr	1554(ra) # 4916 <fork>
    330c:	00a92023          	sw	a0,0(s2)
    3310:	d94d                	beqz	a0,32c2 <sbrkfail+0x4c>
    if(pids[i] != -1)
    3312:	ff4506e3          	beq	a0,s4,32fe <sbrkfail+0x88>
      read(fds[0], &scratch, 1);
    3316:	4605                	li	a2,1
    3318:	faf40593          	addi	a1,s0,-81
    331c:	fb042503          	lw	a0,-80(s0)
    3320:	00001097          	auipc	ra,0x1
    3324:	616080e7          	jalr	1558(ra) # 4936 <read>
    3328:	bfd9                	j	32fe <sbrkfail+0x88>
  c = sbrk(PGSIZE);
    332a:	6505                	lui	a0,0x1
    332c:	00001097          	auipc	ra,0x1
    3330:	662080e7          	jalr	1634(ra) # 498e <sbrk>
    3334:	8a2a                	mv	s4,a0
    if(pids[i] == -1)
    3336:	597d                	li	s2,-1
    3338:	a021                	j	3340 <sbrkfail+0xca>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    333a:	0491                	addi	s1,s1,4
    333c:	01348f63          	beq	s1,s3,335a <sbrkfail+0xe4>
    if(pids[i] == -1)
    3340:	4088                	lw	a0,0(s1)
    3342:	ff250ce3          	beq	a0,s2,333a <sbrkfail+0xc4>
    kill(pids[i]);
    3346:	00001097          	auipc	ra,0x1
    334a:	608080e7          	jalr	1544(ra) # 494e <kill>
    wait(0);
    334e:	4501                	li	a0,0
    3350:	00001097          	auipc	ra,0x1
    3354:	5d6080e7          	jalr	1494(ra) # 4926 <wait>
    3358:	b7cd                	j	333a <sbrkfail+0xc4>
  if(c == (char*)0xffffffffffffffffL){
    335a:	57fd                	li	a5,-1
    335c:	04fa0163          	beq	s4,a5,339e <sbrkfail+0x128>
  pid = fork();
    3360:	00001097          	auipc	ra,0x1
    3364:	5b6080e7          	jalr	1462(ra) # 4916 <fork>
    3368:	84aa                	mv	s1,a0
  if(pid < 0){
    336a:	04054863          	bltz	a0,33ba <sbrkfail+0x144>
  if(pid == 0){
    336e:	c525                	beqz	a0,33d6 <sbrkfail+0x160>
  wait(&xstatus);
    3370:	fbc40513          	addi	a0,s0,-68
    3374:	00001097          	auipc	ra,0x1
    3378:	5b2080e7          	jalr	1458(ra) # 4926 <wait>
  if(xstatus != -1 && xstatus != 2)
    337c:	fbc42783          	lw	a5,-68(s0)
    3380:	577d                	li	a4,-1
    3382:	00e78563          	beq	a5,a4,338c <sbrkfail+0x116>
    3386:	4709                	li	a4,2
    3388:	08e79c63          	bne	a5,a4,3420 <sbrkfail+0x1aa>
}
    338c:	70e6                	ld	ra,120(sp)
    338e:	7446                	ld	s0,112(sp)
    3390:	74a6                	ld	s1,104(sp)
    3392:	7906                	ld	s2,96(sp)
    3394:	69e6                	ld	s3,88(sp)
    3396:	6a46                	ld	s4,80(sp)
    3398:	6aa6                	ld	s5,72(sp)
    339a:	6109                	addi	sp,sp,128
    339c:	8082                	ret
    printf("%s: failed sbrk leaked memory\n", s);
    339e:	85d6                	mv	a1,s5
    33a0:	00003517          	auipc	a0,0x3
    33a4:	f0050513          	addi	a0,a0,-256 # 62a0 <malloc+0x153a>
    33a8:	00002097          	auipc	ra,0x2
    33ac:	906080e7          	jalr	-1786(ra) # 4cae <printf>
    exit(1);
    33b0:	4505                	li	a0,1
    33b2:	00001097          	auipc	ra,0x1
    33b6:	56c080e7          	jalr	1388(ra) # 491e <exit>
    printf("%s: fork failed\n", s);
    33ba:	85d6                	mv	a1,s5
    33bc:	00002517          	auipc	a0,0x2
    33c0:	1ac50513          	addi	a0,a0,428 # 5568 <malloc+0x802>
    33c4:	00002097          	auipc	ra,0x2
    33c8:	8ea080e7          	jalr	-1814(ra) # 4cae <printf>
    exit(1);
    33cc:	4505                	li	a0,1
    33ce:	00001097          	auipc	ra,0x1
    33d2:	550080e7          	jalr	1360(ra) # 491e <exit>
    a = sbrk(0);
    33d6:	4501                	li	a0,0
    33d8:	00001097          	auipc	ra,0x1
    33dc:	5b6080e7          	jalr	1462(ra) # 498e <sbrk>
    33e0:	892a                	mv	s2,a0
    sbrk(10*BIG);
    33e2:	3e800537          	lui	a0,0x3e800
    33e6:	00001097          	auipc	ra,0x1
    33ea:	5a8080e7          	jalr	1448(ra) # 498e <sbrk>
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    33ee:	87ca                	mv	a5,s2
    33f0:	3e800737          	lui	a4,0x3e800
    33f4:	993a                	add	s2,s2,a4
    33f6:	6705                	lui	a4,0x1
      n += *(a+i);
    33f8:	0007c683          	lbu	a3,0(a5) # 6400000 <__BSS_END__+0x63f3f60>
    33fc:	9cb5                	addw	s1,s1,a3
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    33fe:	97ba                	add	a5,a5,a4
    3400:	fef91ce3          	bne	s2,a5,33f8 <sbrkfail+0x182>
    printf("%s: allocate a lot of memory succeeded %d\n", n);
    3404:	85a6                	mv	a1,s1
    3406:	00003517          	auipc	a0,0x3
    340a:	eba50513          	addi	a0,a0,-326 # 62c0 <malloc+0x155a>
    340e:	00002097          	auipc	ra,0x2
    3412:	8a0080e7          	jalr	-1888(ra) # 4cae <printf>
    exit(1);
    3416:	4505                	li	a0,1
    3418:	00001097          	auipc	ra,0x1
    341c:	506080e7          	jalr	1286(ra) # 491e <exit>
    exit(1);
    3420:	4505                	li	a0,1
    3422:	00001097          	auipc	ra,0x1
    3426:	4fc080e7          	jalr	1276(ra) # 491e <exit>

000000000000342a <reparent>:
{
    342a:	7179                	addi	sp,sp,-48
    342c:	f406                	sd	ra,40(sp)
    342e:	f022                	sd	s0,32(sp)
    3430:	ec26                	sd	s1,24(sp)
    3432:	e84a                	sd	s2,16(sp)
    3434:	e44e                	sd	s3,8(sp)
    3436:	e052                	sd	s4,0(sp)
    3438:	1800                	addi	s0,sp,48
    343a:	89aa                	mv	s3,a0
  int master_pid = getpid();
    343c:	00001097          	auipc	ra,0x1
    3440:	54a080e7          	jalr	1354(ra) # 4986 <getpid>
    3444:	8a2a                	mv	s4,a0
    3446:	0c800913          	li	s2,200
    int pid = fork();
    344a:	00001097          	auipc	ra,0x1
    344e:	4cc080e7          	jalr	1228(ra) # 4916 <fork>
    3452:	84aa                	mv	s1,a0
    if(pid < 0){
    3454:	02054263          	bltz	a0,3478 <reparent+0x4e>
    if(pid){
    3458:	cd21                	beqz	a0,34b0 <reparent+0x86>
      if(wait(0) != pid){
    345a:	4501                	li	a0,0
    345c:	00001097          	auipc	ra,0x1
    3460:	4ca080e7          	jalr	1226(ra) # 4926 <wait>
    3464:	02951863          	bne	a0,s1,3494 <reparent+0x6a>
  for(int i = 0; i < 200; i++){
    3468:	397d                	addiw	s2,s2,-1
    346a:	fe0910e3          	bnez	s2,344a <reparent+0x20>
  exit(0);
    346e:	4501                	li	a0,0
    3470:	00001097          	auipc	ra,0x1
    3474:	4ae080e7          	jalr	1198(ra) # 491e <exit>
      printf("%s: fork failed\n", s);
    3478:	85ce                	mv	a1,s3
    347a:	00002517          	auipc	a0,0x2
    347e:	0ee50513          	addi	a0,a0,238 # 5568 <malloc+0x802>
    3482:	00002097          	auipc	ra,0x2
    3486:	82c080e7          	jalr	-2004(ra) # 4cae <printf>
      exit(1);
    348a:	4505                	li	a0,1
    348c:	00001097          	auipc	ra,0x1
    3490:	492080e7          	jalr	1170(ra) # 491e <exit>
        printf("%s: wait wrong pid\n", s);
    3494:	85ce                	mv	a1,s3
    3496:	00002517          	auipc	a0,0x2
    349a:	25a50513          	addi	a0,a0,602 # 56f0 <malloc+0x98a>
    349e:	00002097          	auipc	ra,0x2
    34a2:	810080e7          	jalr	-2032(ra) # 4cae <printf>
        exit(1);
    34a6:	4505                	li	a0,1
    34a8:	00001097          	auipc	ra,0x1
    34ac:	476080e7          	jalr	1142(ra) # 491e <exit>
      int pid2 = fork();
    34b0:	00001097          	auipc	ra,0x1
    34b4:	466080e7          	jalr	1126(ra) # 4916 <fork>
      if(pid2 < 0){
    34b8:	00054763          	bltz	a0,34c6 <reparent+0x9c>
      exit(0);
    34bc:	4501                	li	a0,0
    34be:	00001097          	auipc	ra,0x1
    34c2:	460080e7          	jalr	1120(ra) # 491e <exit>
        kill(master_pid);
    34c6:	8552                	mv	a0,s4
    34c8:	00001097          	auipc	ra,0x1
    34cc:	486080e7          	jalr	1158(ra) # 494e <kill>
        exit(1);
    34d0:	4505                	li	a0,1
    34d2:	00001097          	auipc	ra,0x1
    34d6:	44c080e7          	jalr	1100(ra) # 491e <exit>

00000000000034da <mem>:
{
    34da:	7139                	addi	sp,sp,-64
    34dc:	fc06                	sd	ra,56(sp)
    34de:	f822                	sd	s0,48(sp)
    34e0:	f426                	sd	s1,40(sp)
    34e2:	f04a                	sd	s2,32(sp)
    34e4:	ec4e                	sd	s3,24(sp)
    34e6:	0080                	addi	s0,sp,64
    34e8:	89aa                	mv	s3,a0
  if((pid = fork()) == 0){
    34ea:	00001097          	auipc	ra,0x1
    34ee:	42c080e7          	jalr	1068(ra) # 4916 <fork>
    m1 = 0;
    34f2:	4481                	li	s1,0
    while((m2 = malloc(10001)) != 0){
    34f4:	6909                	lui	s2,0x2
    34f6:	71190913          	addi	s2,s2,1809 # 2711 <subdir+0x1ab>
  if((pid = fork()) == 0){
    34fa:	c115                	beqz	a0,351e <mem+0x44>
    wait(&xstatus);
    34fc:	fcc40513          	addi	a0,s0,-52
    3500:	00001097          	auipc	ra,0x1
    3504:	426080e7          	jalr	1062(ra) # 4926 <wait>
    if(xstatus == -1){
    3508:	fcc42503          	lw	a0,-52(s0)
    350c:	57fd                	li	a5,-1
    350e:	06f50363          	beq	a0,a5,3574 <mem+0x9a>
    exit(xstatus);
    3512:	00001097          	auipc	ra,0x1
    3516:	40c080e7          	jalr	1036(ra) # 491e <exit>
      *(char**)m2 = m1;
    351a:	e104                	sd	s1,0(a0)
      m1 = m2;
    351c:	84aa                	mv	s1,a0
    while((m2 = malloc(10001)) != 0){
    351e:	854a                	mv	a0,s2
    3520:	00002097          	auipc	ra,0x2
    3524:	846080e7          	jalr	-1978(ra) # 4d66 <malloc>
    3528:	f96d                	bnez	a0,351a <mem+0x40>
    while(m1){
    352a:	c881                	beqz	s1,353a <mem+0x60>
      m2 = *(char**)m1;
    352c:	8526                	mv	a0,s1
    352e:	6084                	ld	s1,0(s1)
      free(m1);
    3530:	00001097          	auipc	ra,0x1
    3534:	7b4080e7          	jalr	1972(ra) # 4ce4 <free>
    while(m1){
    3538:	f8f5                	bnez	s1,352c <mem+0x52>
    m1 = malloc(1024*20);
    353a:	6515                	lui	a0,0x5
    353c:	00002097          	auipc	ra,0x2
    3540:	82a080e7          	jalr	-2006(ra) # 4d66 <malloc>
    if(m1 == 0){
    3544:	c911                	beqz	a0,3558 <mem+0x7e>
    free(m1);
    3546:	00001097          	auipc	ra,0x1
    354a:	79e080e7          	jalr	1950(ra) # 4ce4 <free>
    exit(0);
    354e:	4501                	li	a0,0
    3550:	00001097          	auipc	ra,0x1
    3554:	3ce080e7          	jalr	974(ra) # 491e <exit>
      printf("couldn't allocate mem?!!\n", s);
    3558:	85ce                	mv	a1,s3
    355a:	00003517          	auipc	a0,0x3
    355e:	d9650513          	addi	a0,a0,-618 # 62f0 <malloc+0x158a>
    3562:	00001097          	auipc	ra,0x1
    3566:	74c080e7          	jalr	1868(ra) # 4cae <printf>
      exit(1);
    356a:	4505                	li	a0,1
    356c:	00001097          	auipc	ra,0x1
    3570:	3b2080e7          	jalr	946(ra) # 491e <exit>
      exit(0);
    3574:	4501                	li	a0,0
    3576:	00001097          	auipc	ra,0x1
    357a:	3a8080e7          	jalr	936(ra) # 491e <exit>

000000000000357e <sharedfd>:
{
    357e:	7159                	addi	sp,sp,-112
    3580:	f486                	sd	ra,104(sp)
    3582:	f0a2                	sd	s0,96(sp)
    3584:	e0d2                	sd	s4,64(sp)
    3586:	1880                	addi	s0,sp,112
    3588:	8a2a                	mv	s4,a0
  remove("sharedfd");
    358a:	00003517          	auipc	a0,0x3
    358e:	d8650513          	addi	a0,a0,-634 # 6310 <malloc+0x15aa>
    3592:	00001097          	auipc	ra,0x1
    3596:	434080e7          	jalr	1076(ra) # 49c6 <remove>
  fd = open("sharedfd", O_CREATE|O_RDWR);
    359a:	20200593          	li	a1,514
    359e:	00003517          	auipc	a0,0x3
    35a2:	d7250513          	addi	a0,a0,-654 # 6310 <malloc+0x15aa>
    35a6:	00001097          	auipc	ra,0x1
    35aa:	3b8080e7          	jalr	952(ra) # 495e <open>
  if(fd < 0){
    35ae:	06054063          	bltz	a0,360e <sharedfd+0x90>
    35b2:	eca6                	sd	s1,88(sp)
    35b4:	e8ca                	sd	s2,80(sp)
    35b6:	e4ce                	sd	s3,72(sp)
    35b8:	fc56                	sd	s5,56(sp)
    35ba:	f85a                	sd	s6,48(sp)
    35bc:	f45e                	sd	s7,40(sp)
    35be:	892a                	mv	s2,a0
  pid = fork();
    35c0:	00001097          	auipc	ra,0x1
    35c4:	356080e7          	jalr	854(ra) # 4916 <fork>
    35c8:	89aa                	mv	s3,a0
  memset(buf, pid==0?'c':'p', sizeof(buf));
    35ca:	07000593          	li	a1,112
    35ce:	e119                	bnez	a0,35d4 <sharedfd+0x56>
    35d0:	06300593          	li	a1,99
    35d4:	4629                	li	a2,10
    35d6:	fa040513          	addi	a0,s0,-96
    35da:	00001097          	auipc	ra,0x1
    35de:	132080e7          	jalr	306(ra) # 470c <memset>
    35e2:	3e800493          	li	s1,1000
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    35e6:	4629                	li	a2,10
    35e8:	fa040593          	addi	a1,s0,-96
    35ec:	854a                	mv	a0,s2
    35ee:	00001097          	auipc	ra,0x1
    35f2:	350080e7          	jalr	848(ra) # 493e <write>
    35f6:	47a9                	li	a5,10
    35f8:	02f51f63          	bne	a0,a5,3636 <sharedfd+0xb8>
  for(i = 0; i < N; i++){
    35fc:	34fd                	addiw	s1,s1,-1
    35fe:	f4e5                	bnez	s1,35e6 <sharedfd+0x68>
  if(pid == 0) {
    3600:	04099963          	bnez	s3,3652 <sharedfd+0xd4>
    exit(0);
    3604:	4501                	li	a0,0
    3606:	00001097          	auipc	ra,0x1
    360a:	318080e7          	jalr	792(ra) # 491e <exit>
    360e:	eca6                	sd	s1,88(sp)
    3610:	e8ca                	sd	s2,80(sp)
    3612:	e4ce                	sd	s3,72(sp)
    3614:	fc56                	sd	s5,56(sp)
    3616:	f85a                	sd	s6,48(sp)
    3618:	f45e                	sd	s7,40(sp)
    printf("%s: cannot open sharedfd for writing", s);
    361a:	85d2                	mv	a1,s4
    361c:	00003517          	auipc	a0,0x3
    3620:	d0450513          	addi	a0,a0,-764 # 6320 <malloc+0x15ba>
    3624:	00001097          	auipc	ra,0x1
    3628:	68a080e7          	jalr	1674(ra) # 4cae <printf>
    exit(1);
    362c:	4505                	li	a0,1
    362e:	00001097          	auipc	ra,0x1
    3632:	2f0080e7          	jalr	752(ra) # 491e <exit>
      printf("%s: write sharedfd failed\n", s);
    3636:	85d2                	mv	a1,s4
    3638:	00003517          	auipc	a0,0x3
    363c:	d1050513          	addi	a0,a0,-752 # 6348 <malloc+0x15e2>
    3640:	00001097          	auipc	ra,0x1
    3644:	66e080e7          	jalr	1646(ra) # 4cae <printf>
      exit(1);
    3648:	4505                	li	a0,1
    364a:	00001097          	auipc	ra,0x1
    364e:	2d4080e7          	jalr	724(ra) # 491e <exit>
    wait(&xstatus);
    3652:	f9c40513          	addi	a0,s0,-100
    3656:	00001097          	auipc	ra,0x1
    365a:	2d0080e7          	jalr	720(ra) # 4926 <wait>
    if(xstatus != 0)
    365e:	f9c42983          	lw	s3,-100(s0)
    3662:	00098763          	beqz	s3,3670 <sharedfd+0xf2>
      exit(xstatus);
    3666:	854e                	mv	a0,s3
    3668:	00001097          	auipc	ra,0x1
    366c:	2b6080e7          	jalr	694(ra) # 491e <exit>
  close(fd);
    3670:	854a                	mv	a0,s2
    3672:	00001097          	auipc	ra,0x1
    3676:	2d4080e7          	jalr	724(ra) # 4946 <close>
  fd = open("sharedfd", 0);
    367a:	4581                	li	a1,0
    367c:	00003517          	auipc	a0,0x3
    3680:	c9450513          	addi	a0,a0,-876 # 6310 <malloc+0x15aa>
    3684:	00001097          	auipc	ra,0x1
    3688:	2da080e7          	jalr	730(ra) # 495e <open>
    368c:	8baa                	mv	s7,a0
  nc = np = 0;
    368e:	8ace                	mv	s5,s3
  if(fd < 0){
    3690:	02054563          	bltz	a0,36ba <sharedfd+0x13c>
    3694:	faa40913          	addi	s2,s0,-86
      if(buf[i] == 'c')
    3698:	06300493          	li	s1,99
      if(buf[i] == 'p')
    369c:	07000b13          	li	s6,112
  while((n = read(fd, buf, sizeof(buf))) > 0){
    36a0:	4629                	li	a2,10
    36a2:	fa040593          	addi	a1,s0,-96
    36a6:	855e                	mv	a0,s7
    36a8:	00001097          	auipc	ra,0x1
    36ac:	28e080e7          	jalr	654(ra) # 4936 <read>
    36b0:	02a05f63          	blez	a0,36ee <sharedfd+0x170>
    36b4:	fa040793          	addi	a5,s0,-96
    36b8:	a01d                	j	36de <sharedfd+0x160>
    printf("%s: cannot open sharedfd for reading\n", s);
    36ba:	85d2                	mv	a1,s4
    36bc:	00003517          	auipc	a0,0x3
    36c0:	cac50513          	addi	a0,a0,-852 # 6368 <malloc+0x1602>
    36c4:	00001097          	auipc	ra,0x1
    36c8:	5ea080e7          	jalr	1514(ra) # 4cae <printf>
    exit(1);
    36cc:	4505                	li	a0,1
    36ce:	00001097          	auipc	ra,0x1
    36d2:	250080e7          	jalr	592(ra) # 491e <exit>
        nc++;
    36d6:	2985                	addiw	s3,s3,1
    for(i = 0; i < sizeof(buf); i++){
    36d8:	0785                	addi	a5,a5,1
    36da:	fd2783e3          	beq	a5,s2,36a0 <sharedfd+0x122>
      if(buf[i] == 'c')
    36de:	0007c703          	lbu	a4,0(a5)
    36e2:	fe970ae3          	beq	a4,s1,36d6 <sharedfd+0x158>
      if(buf[i] == 'p')
    36e6:	ff6719e3          	bne	a4,s6,36d8 <sharedfd+0x15a>
        np++;
    36ea:	2a85                	addiw	s5,s5,1
    36ec:	b7f5                	j	36d8 <sharedfd+0x15a>
  close(fd);
    36ee:	855e                	mv	a0,s7
    36f0:	00001097          	auipc	ra,0x1
    36f4:	256080e7          	jalr	598(ra) # 4946 <close>
  remove("sharedfd");
    36f8:	00003517          	auipc	a0,0x3
    36fc:	c1850513          	addi	a0,a0,-1000 # 6310 <malloc+0x15aa>
    3700:	00001097          	auipc	ra,0x1
    3704:	2c6080e7          	jalr	710(ra) # 49c6 <remove>
  if(nc == N*SZ && np == N*SZ){
    3708:	6789                	lui	a5,0x2
    370a:	71078793          	addi	a5,a5,1808 # 2710 <subdir+0x1aa>
    370e:	00f99763          	bne	s3,a5,371c <sharedfd+0x19e>
    3712:	6789                	lui	a5,0x2
    3714:	71078793          	addi	a5,a5,1808 # 2710 <subdir+0x1aa>
    3718:	02fa8063          	beq	s5,a5,3738 <sharedfd+0x1ba>
    printf("%s: nc/np test fails\n", s);
    371c:	85d2                	mv	a1,s4
    371e:	00003517          	auipc	a0,0x3
    3722:	c7250513          	addi	a0,a0,-910 # 6390 <malloc+0x162a>
    3726:	00001097          	auipc	ra,0x1
    372a:	588080e7          	jalr	1416(ra) # 4cae <printf>
    exit(1);
    372e:	4505                	li	a0,1
    3730:	00001097          	auipc	ra,0x1
    3734:	1ee080e7          	jalr	494(ra) # 491e <exit>
    exit(0);
    3738:	4501                	li	a0,0
    373a:	00001097          	auipc	ra,0x1
    373e:	1e4080e7          	jalr	484(ra) # 491e <exit>

0000000000003742 <fourfiles>:
{
    3742:	7171                	addi	sp,sp,-176
    3744:	f506                	sd	ra,168(sp)
    3746:	f122                	sd	s0,160(sp)
    3748:	ed26                	sd	s1,152(sp)
    374a:	e94a                	sd	s2,144(sp)
    374c:	e54e                	sd	s3,136(sp)
    374e:	e152                	sd	s4,128(sp)
    3750:	fcd6                	sd	s5,120(sp)
    3752:	f8da                	sd	s6,112(sp)
    3754:	f4de                	sd	s7,104(sp)
    3756:	f0e2                	sd	s8,96(sp)
    3758:	ece6                	sd	s9,88(sp)
    375a:	e8ea                	sd	s10,80(sp)
    375c:	e4ee                	sd	s11,72(sp)
    375e:	1900                	addi	s0,sp,176
    3760:	f4a43c23          	sd	a0,-168(s0)
  char *names[] = { "f0", "f1", "f2", "f3" };
    3764:	00003797          	auipc	a5,0x3
    3768:	c4478793          	addi	a5,a5,-956 # 63a8 <malloc+0x1642>
    376c:	f6f43823          	sd	a5,-144(s0)
    3770:	00003797          	auipc	a5,0x3
    3774:	c4078793          	addi	a5,a5,-960 # 63b0 <malloc+0x164a>
    3778:	f6f43c23          	sd	a5,-136(s0)
    377c:	00003797          	auipc	a5,0x3
    3780:	c3c78793          	addi	a5,a5,-964 # 63b8 <malloc+0x1652>
    3784:	f8f43023          	sd	a5,-128(s0)
    3788:	00003797          	auipc	a5,0x3
    378c:	c3878793          	addi	a5,a5,-968 # 63c0 <malloc+0x165a>
    3790:	f8f43423          	sd	a5,-120(s0)
  for(pi = 0; pi < NCHILD; pi++){
    3794:	f7040c13          	addi	s8,s0,-144
  char *names[] = { "f0", "f1", "f2", "f3" };
    3798:	8962                	mv	s2,s8
  for(pi = 0; pi < NCHILD; pi++){
    379a:	4481                	li	s1,0
    379c:	4a11                	li	s4,4
    fname = names[pi];
    379e:	00093983          	ld	s3,0(s2)
    remove(fname);
    37a2:	854e                	mv	a0,s3
    37a4:	00001097          	auipc	ra,0x1
    37a8:	222080e7          	jalr	546(ra) # 49c6 <remove>
    pid = fork();
    37ac:	00001097          	auipc	ra,0x1
    37b0:	16a080e7          	jalr	362(ra) # 4916 <fork>
    if(pid < 0){
    37b4:	04054363          	bltz	a0,37fa <fourfiles+0xb8>
    if(pid == 0){
    37b8:	c125                	beqz	a0,3818 <fourfiles+0xd6>
  for(pi = 0; pi < NCHILD; pi++){
    37ba:	2485                	addiw	s1,s1,1
    37bc:	0921                	addi	s2,s2,8
    37be:	ff4490e3          	bne	s1,s4,379e <fourfiles+0x5c>
    37c2:	4491                	li	s1,4
    wait(&xstatus);
    37c4:	f6c40513          	addi	a0,s0,-148
    37c8:	00001097          	auipc	ra,0x1
    37cc:	15e080e7          	jalr	350(ra) # 4926 <wait>
    if(xstatus != 0)
    37d0:	f6c42b03          	lw	s6,-148(s0)
    37d4:	0c0b1d63          	bnez	s6,38ae <fourfiles+0x16c>
  for(pi = 0; pi < NCHILD; pi++){
    37d8:	34fd                	addiw	s1,s1,-1
    37da:	f4ed                	bnez	s1,37c4 <fourfiles+0x82>
    37dc:	03000b93          	li	s7,48
    while((n = read(fd, buf, sizeof(buf))) > 0){
    37e0:	6a09                	lui	s4,0x2
    37e2:	800a0a13          	addi	s4,s4,-2048 # 1800 <forkfork+0x38>
    37e6:	00007a97          	auipc	s5,0x7
    37ea:	0aaa8a93          	addi	s5,s5,170 # a890 <buf>
    if(total != N*SZ){
    37ee:	6d85                	lui	s11,0x1
    37f0:	770d8d93          	addi	s11,s11,1904 # 1770 <twochildren+0x42>
  for(i = 0; i < NCHILD; i++){
    37f4:	03400d13          	li	s10,52
    37f8:	aa05                	j	3928 <fourfiles+0x1e6>
      printf("fork failed\n", s);
    37fa:	f5843583          	ld	a1,-168(s0)
    37fe:	00002517          	auipc	a0,0x2
    3802:	0ea50513          	addi	a0,a0,234 # 58e8 <malloc+0xb82>
    3806:	00001097          	auipc	ra,0x1
    380a:	4a8080e7          	jalr	1192(ra) # 4cae <printf>
      exit(1);
    380e:	4505                	li	a0,1
    3810:	00001097          	auipc	ra,0x1
    3814:	10e080e7          	jalr	270(ra) # 491e <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    3818:	20200593          	li	a1,514
    381c:	854e                	mv	a0,s3
    381e:	00001097          	auipc	ra,0x1
    3822:	140080e7          	jalr	320(ra) # 495e <open>
    3826:	892a                	mv	s2,a0
      if(fd < 0){
    3828:	04054763          	bltz	a0,3876 <fourfiles+0x134>
      memset(buf, '0'+pi, SZ);
    382c:	1f400613          	li	a2,500
    3830:	0304859b          	addiw	a1,s1,48
    3834:	00007517          	auipc	a0,0x7
    3838:	05c50513          	addi	a0,a0,92 # a890 <buf>
    383c:	00001097          	auipc	ra,0x1
    3840:	ed0080e7          	jalr	-304(ra) # 470c <memset>
    3844:	44b1                	li	s1,12
        if((n = write(fd, buf, SZ)) != SZ){
    3846:	00007997          	auipc	s3,0x7
    384a:	04a98993          	addi	s3,s3,74 # a890 <buf>
    384e:	1f400613          	li	a2,500
    3852:	85ce                	mv	a1,s3
    3854:	854a                	mv	a0,s2
    3856:	00001097          	auipc	ra,0x1
    385a:	0e8080e7          	jalr	232(ra) # 493e <write>
    385e:	85aa                	mv	a1,a0
    3860:	1f400793          	li	a5,500
    3864:	02f51863          	bne	a0,a5,3894 <fourfiles+0x152>
      for(i = 0; i < N; i++){
    3868:	34fd                	addiw	s1,s1,-1
    386a:	f0f5                	bnez	s1,384e <fourfiles+0x10c>
      exit(0);
    386c:	4501                	li	a0,0
    386e:	00001097          	auipc	ra,0x1
    3872:	0b0080e7          	jalr	176(ra) # 491e <exit>
        printf("create failed\n", s);
    3876:	f5843583          	ld	a1,-168(s0)
    387a:	00003517          	auipc	a0,0x3
    387e:	b4e50513          	addi	a0,a0,-1202 # 63c8 <malloc+0x1662>
    3882:	00001097          	auipc	ra,0x1
    3886:	42c080e7          	jalr	1068(ra) # 4cae <printf>
        exit(1);
    388a:	4505                	li	a0,1
    388c:	00001097          	auipc	ra,0x1
    3890:	092080e7          	jalr	146(ra) # 491e <exit>
          printf("write failed %d\n", n);
    3894:	00003517          	auipc	a0,0x3
    3898:	b4450513          	addi	a0,a0,-1212 # 63d8 <malloc+0x1672>
    389c:	00001097          	auipc	ra,0x1
    38a0:	412080e7          	jalr	1042(ra) # 4cae <printf>
          exit(1);
    38a4:	4505                	li	a0,1
    38a6:	00001097          	auipc	ra,0x1
    38aa:	078080e7          	jalr	120(ra) # 491e <exit>
      exit(xstatus);
    38ae:	855a                	mv	a0,s6
    38b0:	00001097          	auipc	ra,0x1
    38b4:	06e080e7          	jalr	110(ra) # 491e <exit>
          printf("wrong char\n", s);
    38b8:	f5843583          	ld	a1,-168(s0)
    38bc:	00003517          	auipc	a0,0x3
    38c0:	b3450513          	addi	a0,a0,-1228 # 63f0 <malloc+0x168a>
    38c4:	00001097          	auipc	ra,0x1
    38c8:	3ea080e7          	jalr	1002(ra) # 4cae <printf>
          exit(1);
    38cc:	4505                	li	a0,1
    38ce:	00001097          	auipc	ra,0x1
    38d2:	050080e7          	jalr	80(ra) # 491e <exit>
      total += n;
    38d6:	00a9093b          	addw	s2,s2,a0
    while((n = read(fd, buf, sizeof(buf))) > 0){
    38da:	8652                	mv	a2,s4
    38dc:	85d6                	mv	a1,s5
    38de:	854e                	mv	a0,s3
    38e0:	00001097          	auipc	ra,0x1
    38e4:	056080e7          	jalr	86(ra) # 4936 <read>
    38e8:	02a05063          	blez	a0,3908 <fourfiles+0x1c6>
    38ec:	00007797          	auipc	a5,0x7
    38f0:	fa478793          	addi	a5,a5,-92 # a890 <buf>
    38f4:	00f506b3          	add	a3,a0,a5
        if(buf[j] != '0'+i){
    38f8:	0007c703          	lbu	a4,0(a5)
    38fc:	fa971ee3          	bne	a4,s1,38b8 <fourfiles+0x176>
      for(j = 0; j < n; j++){
    3900:	0785                	addi	a5,a5,1
    3902:	fed79be3          	bne	a5,a3,38f8 <fourfiles+0x1b6>
    3906:	bfc1                	j	38d6 <fourfiles+0x194>
    close(fd);
    3908:	854e                	mv	a0,s3
    390a:	00001097          	auipc	ra,0x1
    390e:	03c080e7          	jalr	60(ra) # 4946 <close>
    if(total != N*SZ){
    3912:	03b91863          	bne	s2,s11,3942 <fourfiles+0x200>
    remove(fname);
    3916:	8566                	mv	a0,s9
    3918:	00001097          	auipc	ra,0x1
    391c:	0ae080e7          	jalr	174(ra) # 49c6 <remove>
  for(i = 0; i < NCHILD; i++){
    3920:	0c21                	addi	s8,s8,8
    3922:	2b85                	addiw	s7,s7,1
    3924:	03ab8d63          	beq	s7,s10,395e <fourfiles+0x21c>
    fname = names[i];
    3928:	000c3c83          	ld	s9,0(s8)
    fd = open(fname, 0);
    392c:	4581                	li	a1,0
    392e:	8566                	mv	a0,s9
    3930:	00001097          	auipc	ra,0x1
    3934:	02e080e7          	jalr	46(ra) # 495e <open>
    3938:	89aa                	mv	s3,a0
    total = 0;
    393a:	895a                	mv	s2,s6
        if(buf[j] != '0'+i){
    393c:	000b849b          	sext.w	s1,s7
    while((n = read(fd, buf, sizeof(buf))) > 0){
    3940:	bf69                	j	38da <fourfiles+0x198>
      printf("wrong length %d\n", total);
    3942:	85ca                	mv	a1,s2
    3944:	00003517          	auipc	a0,0x3
    3948:	abc50513          	addi	a0,a0,-1348 # 6400 <malloc+0x169a>
    394c:	00001097          	auipc	ra,0x1
    3950:	362080e7          	jalr	866(ra) # 4cae <printf>
      exit(1);
    3954:	4505                	li	a0,1
    3956:	00001097          	auipc	ra,0x1
    395a:	fc8080e7          	jalr	-56(ra) # 491e <exit>
}
    395e:	70aa                	ld	ra,168(sp)
    3960:	740a                	ld	s0,160(sp)
    3962:	64ea                	ld	s1,152(sp)
    3964:	694a                	ld	s2,144(sp)
    3966:	69aa                	ld	s3,136(sp)
    3968:	6a0a                	ld	s4,128(sp)
    396a:	7ae6                	ld	s5,120(sp)
    396c:	7b46                	ld	s6,112(sp)
    396e:	7ba6                	ld	s7,104(sp)
    3970:	7c06                	ld	s8,96(sp)
    3972:	6ce6                	ld	s9,88(sp)
    3974:	6d46                	ld	s10,80(sp)
    3976:	6da6                	ld	s11,72(sp)
    3978:	614d                	addi	sp,sp,176
    397a:	8082                	ret

000000000000397c <bigfile>:
{
    397c:	7139                	addi	sp,sp,-64
    397e:	fc06                	sd	ra,56(sp)
    3980:	f822                	sd	s0,48(sp)
    3982:	f426                	sd	s1,40(sp)
    3984:	f04a                	sd	s2,32(sp)
    3986:	ec4e                	sd	s3,24(sp)
    3988:	e852                	sd	s4,16(sp)
    398a:	e456                	sd	s5,8(sp)
    398c:	0080                	addi	s0,sp,64
    398e:	8aaa                	mv	s5,a0
  remove("bigfile.dat");
    3990:	00003517          	auipc	a0,0x3
    3994:	a8850513          	addi	a0,a0,-1400 # 6418 <malloc+0x16b2>
    3998:	00001097          	auipc	ra,0x1
    399c:	02e080e7          	jalr	46(ra) # 49c6 <remove>
  fd = open("bigfile.dat", O_CREATE | O_RDWR);
    39a0:	20200593          	li	a1,514
    39a4:	00003517          	auipc	a0,0x3
    39a8:	a7450513          	addi	a0,a0,-1420 # 6418 <malloc+0x16b2>
    39ac:	00001097          	auipc	ra,0x1
    39b0:	fb2080e7          	jalr	-78(ra) # 495e <open>
    39b4:	89aa                	mv	s3,a0
  for(i = 0; i < N; i++){
    39b6:	4481                	li	s1,0
    memset(buf, i, SZ);
    39b8:	00007917          	auipc	s2,0x7
    39bc:	ed890913          	addi	s2,s2,-296 # a890 <buf>
  for(i = 0; i < N; i++){
    39c0:	4a51                	li	s4,20
  if(fd < 0){
    39c2:	0a054063          	bltz	a0,3a62 <bigfile+0xe6>
    memset(buf, i, SZ);
    39c6:	25800613          	li	a2,600
    39ca:	85a6                	mv	a1,s1
    39cc:	854a                	mv	a0,s2
    39ce:	00001097          	auipc	ra,0x1
    39d2:	d3e080e7          	jalr	-706(ra) # 470c <memset>
    if(write(fd, buf, SZ) != SZ){
    39d6:	25800613          	li	a2,600
    39da:	85ca                	mv	a1,s2
    39dc:	854e                	mv	a0,s3
    39de:	00001097          	auipc	ra,0x1
    39e2:	f60080e7          	jalr	-160(ra) # 493e <write>
    39e6:	25800793          	li	a5,600
    39ea:	08f51a63          	bne	a0,a5,3a7e <bigfile+0x102>
  for(i = 0; i < N; i++){
    39ee:	2485                	addiw	s1,s1,1
    39f0:	fd449be3          	bne	s1,s4,39c6 <bigfile+0x4a>
  close(fd);
    39f4:	854e                	mv	a0,s3
    39f6:	00001097          	auipc	ra,0x1
    39fa:	f50080e7          	jalr	-176(ra) # 4946 <close>
  fd = open("bigfile.dat", 0);
    39fe:	4581                	li	a1,0
    3a00:	00003517          	auipc	a0,0x3
    3a04:	a1850513          	addi	a0,a0,-1512 # 6418 <malloc+0x16b2>
    3a08:	00001097          	auipc	ra,0x1
    3a0c:	f56080e7          	jalr	-170(ra) # 495e <open>
    3a10:	8a2a                	mv	s4,a0
  total = 0;
    3a12:	4981                	li	s3,0
  for(i = 0; ; i++){
    3a14:	4481                	li	s1,0
    cc = read(fd, buf, SZ/2);
    3a16:	00007917          	auipc	s2,0x7
    3a1a:	e7a90913          	addi	s2,s2,-390 # a890 <buf>
  if(fd < 0){
    3a1e:	06054e63          	bltz	a0,3a9a <bigfile+0x11e>
    cc = read(fd, buf, SZ/2);
    3a22:	12c00613          	li	a2,300
    3a26:	85ca                	mv	a1,s2
    3a28:	8552                	mv	a0,s4
    3a2a:	00001097          	auipc	ra,0x1
    3a2e:	f0c080e7          	jalr	-244(ra) # 4936 <read>
    if(cc < 0){
    3a32:	08054263          	bltz	a0,3ab6 <bigfile+0x13a>
    if(cc == 0)
    3a36:	c971                	beqz	a0,3b0a <bigfile+0x18e>
    if(cc != SZ/2){
    3a38:	12c00793          	li	a5,300
    3a3c:	08f51b63          	bne	a0,a5,3ad2 <bigfile+0x156>
    if(buf[0] != i/2 || buf[SZ/2-1] != i/2){
    3a40:	01f4d79b          	srliw	a5,s1,0x1f
    3a44:	9fa5                	addw	a5,a5,s1
    3a46:	4017d79b          	sraiw	a5,a5,0x1
    3a4a:	00094703          	lbu	a4,0(s2)
    3a4e:	0af71063          	bne	a4,a5,3aee <bigfile+0x172>
    3a52:	12b94703          	lbu	a4,299(s2)
    3a56:	08f71c63          	bne	a4,a5,3aee <bigfile+0x172>
    total += cc;
    3a5a:	12c9899b          	addiw	s3,s3,300
  for(i = 0; ; i++){
    3a5e:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ/2);
    3a60:	b7c9                	j	3a22 <bigfile+0xa6>
    printf("%s: cannot create bigfile", s);
    3a62:	85d6                	mv	a1,s5
    3a64:	00003517          	auipc	a0,0x3
    3a68:	9c450513          	addi	a0,a0,-1596 # 6428 <malloc+0x16c2>
    3a6c:	00001097          	auipc	ra,0x1
    3a70:	242080e7          	jalr	578(ra) # 4cae <printf>
    exit(1);
    3a74:	4505                	li	a0,1
    3a76:	00001097          	auipc	ra,0x1
    3a7a:	ea8080e7          	jalr	-344(ra) # 491e <exit>
      printf("%s: write bigfile failed\n", s);
    3a7e:	85d6                	mv	a1,s5
    3a80:	00003517          	auipc	a0,0x3
    3a84:	9c850513          	addi	a0,a0,-1592 # 6448 <malloc+0x16e2>
    3a88:	00001097          	auipc	ra,0x1
    3a8c:	226080e7          	jalr	550(ra) # 4cae <printf>
      exit(1);
    3a90:	4505                	li	a0,1
    3a92:	00001097          	auipc	ra,0x1
    3a96:	e8c080e7          	jalr	-372(ra) # 491e <exit>
    printf("%s: cannot open bigfile\n", s);
    3a9a:	85d6                	mv	a1,s5
    3a9c:	00003517          	auipc	a0,0x3
    3aa0:	9cc50513          	addi	a0,a0,-1588 # 6468 <malloc+0x1702>
    3aa4:	00001097          	auipc	ra,0x1
    3aa8:	20a080e7          	jalr	522(ra) # 4cae <printf>
    exit(1);
    3aac:	4505                	li	a0,1
    3aae:	00001097          	auipc	ra,0x1
    3ab2:	e70080e7          	jalr	-400(ra) # 491e <exit>
      printf("%s: read bigfile failed\n", s);
    3ab6:	85d6                	mv	a1,s5
    3ab8:	00003517          	auipc	a0,0x3
    3abc:	9d050513          	addi	a0,a0,-1584 # 6488 <malloc+0x1722>
    3ac0:	00001097          	auipc	ra,0x1
    3ac4:	1ee080e7          	jalr	494(ra) # 4cae <printf>
      exit(1);
    3ac8:	4505                	li	a0,1
    3aca:	00001097          	auipc	ra,0x1
    3ace:	e54080e7          	jalr	-428(ra) # 491e <exit>
      printf("%s: short read bigfile\n", s);
    3ad2:	85d6                	mv	a1,s5
    3ad4:	00003517          	auipc	a0,0x3
    3ad8:	9d450513          	addi	a0,a0,-1580 # 64a8 <malloc+0x1742>
    3adc:	00001097          	auipc	ra,0x1
    3ae0:	1d2080e7          	jalr	466(ra) # 4cae <printf>
      exit(1);
    3ae4:	4505                	li	a0,1
    3ae6:	00001097          	auipc	ra,0x1
    3aea:	e38080e7          	jalr	-456(ra) # 491e <exit>
      printf("%s: read bigfile wrong data\n", s);
    3aee:	85d6                	mv	a1,s5
    3af0:	00003517          	auipc	a0,0x3
    3af4:	9d050513          	addi	a0,a0,-1584 # 64c0 <malloc+0x175a>
    3af8:	00001097          	auipc	ra,0x1
    3afc:	1b6080e7          	jalr	438(ra) # 4cae <printf>
      exit(1);
    3b00:	4505                	li	a0,1
    3b02:	00001097          	auipc	ra,0x1
    3b06:	e1c080e7          	jalr	-484(ra) # 491e <exit>
  close(fd);
    3b0a:	8552                	mv	a0,s4
    3b0c:	00001097          	auipc	ra,0x1
    3b10:	e3a080e7          	jalr	-454(ra) # 4946 <close>
  if(total != N*SZ){
    3b14:	678d                	lui	a5,0x3
    3b16:	ee078793          	addi	a5,a5,-288 # 2ee0 <iref+0x104>
    3b1a:	02f99363          	bne	s3,a5,3b40 <bigfile+0x1c4>
  remove("bigfile.dat");
    3b1e:	00003517          	auipc	a0,0x3
    3b22:	8fa50513          	addi	a0,a0,-1798 # 6418 <malloc+0x16b2>
    3b26:	00001097          	auipc	ra,0x1
    3b2a:	ea0080e7          	jalr	-352(ra) # 49c6 <remove>
}
    3b2e:	70e2                	ld	ra,56(sp)
    3b30:	7442                	ld	s0,48(sp)
    3b32:	74a2                	ld	s1,40(sp)
    3b34:	7902                	ld	s2,32(sp)
    3b36:	69e2                	ld	s3,24(sp)
    3b38:	6a42                	ld	s4,16(sp)
    3b3a:	6aa2                	ld	s5,8(sp)
    3b3c:	6121                	addi	sp,sp,64
    3b3e:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    3b40:	85d6                	mv	a1,s5
    3b42:	00003517          	auipc	a0,0x3
    3b46:	99e50513          	addi	a0,a0,-1634 # 64e0 <malloc+0x177a>
    3b4a:	00001097          	auipc	ra,0x1
    3b4e:	164080e7          	jalr	356(ra) # 4cae <printf>
    exit(1);
    3b52:	4505                	li	a0,1
    3b54:	00001097          	auipc	ra,0x1
    3b58:	dca080e7          	jalr	-566(ra) # 491e <exit>

0000000000003b5c <createdelete>:
{
    3b5c:	7175                	addi	sp,sp,-144
    3b5e:	e506                	sd	ra,136(sp)
    3b60:	e122                	sd	s0,128(sp)
    3b62:	fca6                	sd	s1,120(sp)
    3b64:	f8ca                	sd	s2,112(sp)
    3b66:	f4ce                	sd	s3,104(sp)
    3b68:	f0d2                	sd	s4,96(sp)
    3b6a:	ecd6                	sd	s5,88(sp)
    3b6c:	e8da                	sd	s6,80(sp)
    3b6e:	e4de                	sd	s7,72(sp)
    3b70:	e0e2                	sd	s8,64(sp)
    3b72:	0900                	addi	s0,sp,144
    3b74:	8c2a                	mv	s8,a0
  char illegal[] = { '\"', '*', '/', ':', '<', '>', '?', '\\', '|', 0 };
    3b76:	00003797          	auipc	a5,0x3
    3b7a:	9f278793          	addi	a5,a5,-1550 # 6568 <malloc+0x1802>
    3b7e:	6398                	ld	a4,0(a5)
    3b80:	f8e43023          	sd	a4,-128(s0)
    3b84:	0087d783          	lhu	a5,8(a5)
    3b88:	f8f41423          	sh	a5,-120(s0)
  for(pi = 0; pi < NCHILD; pi++){
    3b8c:	4901                	li	s2,0
    3b8e:	4991                	li	s3,4
    pid = fork();
    3b90:	00001097          	auipc	ra,0x1
    3b94:	d86080e7          	jalr	-634(ra) # 4916 <fork>
    3b98:	84aa                	mv	s1,a0
    if(pid < 0){
    3b9a:	02054e63          	bltz	a0,3bd6 <createdelete+0x7a>
    if(pid == 0){
    3b9e:	c931                	beqz	a0,3bf2 <createdelete+0x96>
  for(pi = 0; pi < NCHILD; pi++){
    3ba0:	2905                	addiw	s2,s2,1
    3ba2:	ff3917e3          	bne	s2,s3,3b90 <createdelete+0x34>
    3ba6:	4491                	li	s1,4
    wait(&xstatus);
    3ba8:	f7c40513          	addi	a0,s0,-132
    3bac:	00001097          	auipc	ra,0x1
    3bb0:	d7a080e7          	jalr	-646(ra) # 4926 <wait>
    if(xstatus != 0)
    3bb4:	f7c42983          	lw	s3,-132(s0)
    3bb8:	10099663          	bnez	s3,3cc4 <createdelete+0x168>
  for(pi = 0; pi < NCHILD; pi++){
    3bbc:	34fd                	addiw	s1,s1,-1
    3bbe:	f4ed                	bnez	s1,3ba8 <createdelete+0x4c>
  name[0] = name[1] = name[2] = 0;
    3bc0:	f8040923          	sb	zero,-110(s0)
    3bc4:	03000913          	li	s2,48
    3bc8:	07000a93          	li	s5,112
    for(pi = 0; pi < NCHILD; pi++){
    3bcc:	07400a13          	li	s4,116
      if((i == 0 || i >= N/2) && fd < 0){
    3bd0:	4b25                	li	s6,9
      } else if((i >= 1 && i < N/2) && fd >= 0){
    3bd2:	4ba1                	li	s7,8
    3bd4:	aa79                	j	3d72 <createdelete+0x216>
      printf("fork failed\n", s);
    3bd6:	85e2                	mv	a1,s8
    3bd8:	00002517          	auipc	a0,0x2
    3bdc:	d1050513          	addi	a0,a0,-752 # 58e8 <malloc+0xb82>
    3be0:	00001097          	auipc	ra,0x1
    3be4:	0ce080e7          	jalr	206(ra) # 4cae <printf>
      exit(1);
    3be8:	4505                	li	a0,1
    3bea:	00001097          	auipc	ra,0x1
    3bee:	d34080e7          	jalr	-716(ra) # 491e <exit>
      name[0] = 'p' + pi;
    3bf2:	0709091b          	addiw	s2,s2,112
    3bf6:	f9240823          	sb	s2,-112(s0)
      name[2] = '\0';
    3bfa:	f8040923          	sb	zero,-110(s0)
      for(i = 0; i < N; i++){
    3bfe:	4951                	li	s2,20
    3c00:	a099                	j	3c46 <createdelete+0xea>
          fd = open(name, O_CREATE | O_RDWR);
    3c02:	20200593          	li	a1,514
    3c06:	f9040513          	addi	a0,s0,-112
    3c0a:	00001097          	auipc	ra,0x1
    3c0e:	d54080e7          	jalr	-684(ra) # 495e <open>
          if(fd < 0){
    3c12:	00054763          	bltz	a0,3c20 <createdelete+0xc4>
          close(fd);
    3c16:	00001097          	auipc	ra,0x1
    3c1a:	d30080e7          	jalr	-720(ra) # 4946 <close>
    3c1e:	a089                	j	3c60 <createdelete+0x104>
            printf("%s: create %s failed\n", s, name);
    3c20:	f9040613          	addi	a2,s0,-112
    3c24:	85e2                	mv	a1,s8
    3c26:	00003517          	auipc	a0,0x3
    3c2a:	8da50513          	addi	a0,a0,-1830 # 6500 <malloc+0x179a>
    3c2e:	00001097          	auipc	ra,0x1
    3c32:	080080e7          	jalr	128(ra) # 4cae <printf>
            exit(1);
    3c36:	4505                	li	a0,1
    3c38:	00001097          	auipc	ra,0x1
    3c3c:	ce6080e7          	jalr	-794(ra) # 491e <exit>
      for(i = 0; i < N; i++){
    3c40:	2485                	addiw	s1,s1,1
    3c42:	07248c63          	beq	s1,s2,3cba <createdelete+0x15e>
        name[1] = '0' + i;
    3c46:	0304859b          	addiw	a1,s1,48
    3c4a:	0ff5f593          	zext.b	a1,a1
    3c4e:	f8b408a3          	sb	a1,-111(s0)
        if (strchr(illegal, name[1]) == 0) {
    3c52:	f8040513          	addi	a0,s0,-128
    3c56:	00001097          	auipc	ra,0x1
    3c5a:	ad8080e7          	jalr	-1320(ra) # 472e <strchr>
    3c5e:	d155                	beqz	a0,3c02 <createdelete+0xa6>
        if(i > 0 && (i % 2 ) == 0){
    3c60:	14905a63          	blez	s1,3db4 <createdelete+0x258>
    3c64:	0014f793          	andi	a5,s1,1
    3c68:	ffe1                	bnez	a5,3c40 <createdelete+0xe4>
          name[1] = '0' + (i / 2);
    3c6a:	01f4d59b          	srliw	a1,s1,0x1f
    3c6e:	9da5                	addw	a1,a1,s1
    3c70:	4015d59b          	sraiw	a1,a1,0x1
    3c74:	0305859b          	addiw	a1,a1,48
    3c78:	0ff5f593          	zext.b	a1,a1
    3c7c:	f8b408a3          	sb	a1,-111(s0)
          if (strchr(illegal, name[1]) == 0) {
    3c80:	f8040513          	addi	a0,s0,-128
    3c84:	00001097          	auipc	ra,0x1
    3c88:	aaa080e7          	jalr	-1366(ra) # 472e <strchr>
    3c8c:	f955                	bnez	a0,3c40 <createdelete+0xe4>
            if(remove(name) < 0){
    3c8e:	f9040513          	addi	a0,s0,-112
    3c92:	00001097          	auipc	ra,0x1
    3c96:	d34080e7          	jalr	-716(ra) # 49c6 <remove>
    3c9a:	fa0553e3          	bgez	a0,3c40 <createdelete+0xe4>
              printf("%s: remove failed\n", s);
    3c9e:	85e2                	mv	a1,s8
    3ca0:	00002517          	auipc	a0,0x2
    3ca4:	58850513          	addi	a0,a0,1416 # 6228 <malloc+0x14c2>
    3ca8:	00001097          	auipc	ra,0x1
    3cac:	006080e7          	jalr	6(ra) # 4cae <printf>
              exit(1);
    3cb0:	4505                	li	a0,1
    3cb2:	00001097          	auipc	ra,0x1
    3cb6:	c6c080e7          	jalr	-916(ra) # 491e <exit>
      exit(0);
    3cba:	4501                	li	a0,0
    3cbc:	00001097          	auipc	ra,0x1
    3cc0:	c62080e7          	jalr	-926(ra) # 491e <exit>
      exit(1);
    3cc4:	4505                	li	a0,1
    3cc6:	00001097          	auipc	ra,0x1
    3cca:	c58080e7          	jalr	-936(ra) # 491e <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
    3cce:	f9040613          	addi	a2,s0,-112
    3cd2:	85e2                	mv	a1,s8
    3cd4:	00003517          	auipc	a0,0x3
    3cd8:	84450513          	addi	a0,a0,-1980 # 6518 <malloc+0x17b2>
    3cdc:	00001097          	auipc	ra,0x1
    3ce0:	fd2080e7          	jalr	-46(ra) # 4cae <printf>
        exit(1);
    3ce4:	4505                	li	a0,1
    3ce6:	00001097          	auipc	ra,0x1
    3cea:	c38080e7          	jalr	-968(ra) # 491e <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    3cee:	fff9879b          	addiw	a5,s3,-1
    3cf2:	04fbf763          	bgeu	s7,a5,3d40 <createdelete+0x1e4>
      if(fd >= 0)
    3cf6:	04055063          	bgez	a0,3d36 <createdelete+0x1da>
    for(pi = 0; pi < NCHILD; pi++){
    3cfa:	2485                	addiw	s1,s1,1
    3cfc:	0ff4f493          	zext.b	s1,s1
    3d00:	07448263          	beq	s1,s4,3d64 <createdelete+0x208>
      name[0] = 'p' + pi;
    3d04:	f8940823          	sb	s1,-112(s0)
      name[1] = '0' + i;
    3d08:	f92408a3          	sb	s2,-111(s0)
      if (strchr(illegal, name[1]) != 0) { continue; }
    3d0c:	85ca                	mv	a1,s2
    3d0e:	f8040513          	addi	a0,s0,-128
    3d12:	00001097          	auipc	ra,0x1
    3d16:	a1c080e7          	jalr	-1508(ra) # 472e <strchr>
    3d1a:	f165                	bnez	a0,3cfa <createdelete+0x19e>
      fd = open(name, 0);
    3d1c:	4581                	li	a1,0
    3d1e:	f9040513          	addi	a0,s0,-112
    3d22:	00001097          	auipc	ra,0x1
    3d26:	c3c080e7          	jalr	-964(ra) # 495e <open>
      if((i == 0 || i >= N/2) && fd < 0){
    3d2a:	00098463          	beqz	s3,3d32 <createdelete+0x1d6>
    3d2e:	fd3b50e3          	bge	s6,s3,3cee <createdelete+0x192>
    3d32:	f8054ee3          	bltz	a0,3cce <createdelete+0x172>
        close(fd);
    3d36:	00001097          	auipc	ra,0x1
    3d3a:	c10080e7          	jalr	-1008(ra) # 4946 <close>
    3d3e:	bf75                	j	3cfa <createdelete+0x19e>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    3d40:	fa054de3          	bltz	a0,3cfa <createdelete+0x19e>
        printf("%s: oops createdelete %s did exist\n", s, name);
    3d44:	f9040613          	addi	a2,s0,-112
    3d48:	85e2                	mv	a1,s8
    3d4a:	00002517          	auipc	a0,0x2
    3d4e:	7f650513          	addi	a0,a0,2038 # 6540 <malloc+0x17da>
    3d52:	00001097          	auipc	ra,0x1
    3d56:	f5c080e7          	jalr	-164(ra) # 4cae <printf>
        exit(1);
    3d5a:	4505                	li	a0,1
    3d5c:	00001097          	auipc	ra,0x1
    3d60:	bc2080e7          	jalr	-1086(ra) # 491e <exit>
  for(i = 0; i < N; i++){
    3d64:	2985                	addiw	s3,s3,1
    3d66:	2905                	addiw	s2,s2,1
    3d68:	0ff97913          	zext.b	s2,s2
    3d6c:	47d1                	li	a5,20
    3d6e:	02f98a63          	beq	s3,a5,3da2 <createdelete+0x246>
    for(pi = 0; pi < NCHILD; pi++){
    3d72:	84d6                	mv	s1,s5
    3d74:	bf41                	j	3d04 <createdelete+0x1a8>
  for(i = 0; i < N; i++){
    3d76:	2905                	addiw	s2,s2,1
    3d78:	0ff97913          	zext.b	s2,s2
    3d7c:	03490e63          	beq	s2,s4,3db8 <createdelete+0x25c>
  name[0] = name[1] = name[2] = 0;
    3d80:	84d6                	mv	s1,s5
      name[0] = 'p' + pi;
    3d82:	f8940823          	sb	s1,-112(s0)
      name[1] = '0' + i;
    3d86:	f92408a3          	sb	s2,-111(s0)
      remove(name);
    3d8a:	f9040513          	addi	a0,s0,-112
    3d8e:	00001097          	auipc	ra,0x1
    3d92:	c38080e7          	jalr	-968(ra) # 49c6 <remove>
    for(pi = 0; pi < NCHILD; pi++){
    3d96:	2485                	addiw	s1,s1,1
    3d98:	0ff4f493          	zext.b	s1,s1
    3d9c:	ff3493e3          	bne	s1,s3,3d82 <createdelete+0x226>
    3da0:	bfd9                	j	3d76 <createdelete+0x21a>
    3da2:	03000913          	li	s2,48
  name[0] = name[1] = name[2] = 0;
    3da6:	07000a93          	li	s5,112
    for(pi = 0; pi < NCHILD; pi++){
    3daa:	07400993          	li	s3,116
  for(i = 0; i < N; i++){
    3dae:	04400a13          	li	s4,68
    3db2:	b7f9                	j	3d80 <createdelete+0x224>
      for(i = 0; i < N; i++){
    3db4:	2485                	addiw	s1,s1,1
    3db6:	bd41                	j	3c46 <createdelete+0xea>
}
    3db8:	60aa                	ld	ra,136(sp)
    3dba:	640a                	ld	s0,128(sp)
    3dbc:	74e6                	ld	s1,120(sp)
    3dbe:	7946                	ld	s2,112(sp)
    3dc0:	79a6                	ld	s3,104(sp)
    3dc2:	7a06                	ld	s4,96(sp)
    3dc4:	6ae6                	ld	s5,88(sp)
    3dc6:	6b46                	ld	s6,80(sp)
    3dc8:	6ba6                	ld	s7,72(sp)
    3dca:	6c06                	ld	s8,64(sp)
    3dcc:	6149                	addi	sp,sp,144
    3dce:	8082                	ret

0000000000003dd0 <dirtest>:
{
    3dd0:	1101                	addi	sp,sp,-32
    3dd2:	ec06                	sd	ra,24(sp)
    3dd4:	e822                	sd	s0,16(sp)
    3dd6:	e426                	sd	s1,8(sp)
    3dd8:	1000                	addi	s0,sp,32
    3dda:	84aa                	mv	s1,a0
  printf("mkdir test\n");
    3ddc:	00002517          	auipc	a0,0x2
    3de0:	79c50513          	addi	a0,a0,1948 # 6578 <malloc+0x1812>
    3de4:	00001097          	auipc	ra,0x1
    3de8:	eca080e7          	jalr	-310(ra) # 4cae <printf>
  if(mkdir("dir0") < 0){
    3dec:	00002517          	auipc	a0,0x2
    3df0:	79c50513          	addi	a0,a0,1948 # 6588 <malloc+0x1822>
    3df4:	00001097          	auipc	ra,0x1
    3df8:	b7a080e7          	jalr	-1158(ra) # 496e <mkdir>
    3dfc:	04054d63          	bltz	a0,3e56 <dirtest+0x86>
  if(chdir("dir0") < 0){
    3e00:	00002517          	auipc	a0,0x2
    3e04:	78850513          	addi	a0,a0,1928 # 6588 <malloc+0x1822>
    3e08:	00001097          	auipc	ra,0x1
    3e0c:	b6e080e7          	jalr	-1170(ra) # 4976 <chdir>
    3e10:	06054163          	bltz	a0,3e72 <dirtest+0xa2>
  if(chdir("..") < 0){
    3e14:	00002517          	auipc	a0,0x2
    3e18:	1d450513          	addi	a0,a0,468 # 5fe8 <malloc+0x1282>
    3e1c:	00001097          	auipc	ra,0x1
    3e20:	b5a080e7          	jalr	-1190(ra) # 4976 <chdir>
    3e24:	06054563          	bltz	a0,3e8e <dirtest+0xbe>
  if(remove("dir0") < 0){
    3e28:	00002517          	auipc	a0,0x2
    3e2c:	76050513          	addi	a0,a0,1888 # 6588 <malloc+0x1822>
    3e30:	00001097          	auipc	ra,0x1
    3e34:	b96080e7          	jalr	-1130(ra) # 49c6 <remove>
    3e38:	06054963          	bltz	a0,3eaa <dirtest+0xda>
  printf("%s: mkdir test ok\n");
    3e3c:	00002517          	auipc	a0,0x2
    3e40:	79c50513          	addi	a0,a0,1948 # 65d8 <malloc+0x1872>
    3e44:	00001097          	auipc	ra,0x1
    3e48:	e6a080e7          	jalr	-406(ra) # 4cae <printf>
}
    3e4c:	60e2                	ld	ra,24(sp)
    3e4e:	6442                	ld	s0,16(sp)
    3e50:	64a2                	ld	s1,8(sp)
    3e52:	6105                	addi	sp,sp,32
    3e54:	8082                	ret
    printf("%s: mkdir failed\n", s);
    3e56:	85a6                	mv	a1,s1
    3e58:	00002517          	auipc	a0,0x2
    3e5c:	d1050513          	addi	a0,a0,-752 # 5b68 <malloc+0xe02>
    3e60:	00001097          	auipc	ra,0x1
    3e64:	e4e080e7          	jalr	-434(ra) # 4cae <printf>
    exit(1);
    3e68:	4505                	li	a0,1
    3e6a:	00001097          	auipc	ra,0x1
    3e6e:	ab4080e7          	jalr	-1356(ra) # 491e <exit>
    printf("%s: chdir dir0 failed\n", s);
    3e72:	85a6                	mv	a1,s1
    3e74:	00002517          	auipc	a0,0x2
    3e78:	71c50513          	addi	a0,a0,1820 # 6590 <malloc+0x182a>
    3e7c:	00001097          	auipc	ra,0x1
    3e80:	e32080e7          	jalr	-462(ra) # 4cae <printf>
    exit(1);
    3e84:	4505                	li	a0,1
    3e86:	00001097          	auipc	ra,0x1
    3e8a:	a98080e7          	jalr	-1384(ra) # 491e <exit>
    printf("%s: chdir .. failed\n", s);
    3e8e:	85a6                	mv	a1,s1
    3e90:	00002517          	auipc	a0,0x2
    3e94:	71850513          	addi	a0,a0,1816 # 65a8 <malloc+0x1842>
    3e98:	00001097          	auipc	ra,0x1
    3e9c:	e16080e7          	jalr	-490(ra) # 4cae <printf>
    exit(1);
    3ea0:	4505                	li	a0,1
    3ea2:	00001097          	auipc	ra,0x1
    3ea6:	a7c080e7          	jalr	-1412(ra) # 491e <exit>
    printf("%s: remove dir0 failed\n", s);
    3eaa:	85a6                	mv	a1,s1
    3eac:	00002517          	auipc	a0,0x2
    3eb0:	71450513          	addi	a0,a0,1812 # 65c0 <malloc+0x185a>
    3eb4:	00001097          	auipc	ra,0x1
    3eb8:	dfa080e7          	jalr	-518(ra) # 4cae <printf>
    exit(1);
    3ebc:	4505                	li	a0,1
    3ebe:	00001097          	auipc	ra,0x1
    3ec2:	a60080e7          	jalr	-1440(ra) # 491e <exit>

0000000000003ec6 <fourteen>:
{
    3ec6:	1101                	addi	sp,sp,-32
    3ec8:	ec06                	sd	ra,24(sp)
    3eca:	e822                	sd	s0,16(sp)
    3ecc:	e426                	sd	s1,8(sp)
    3ece:	1000                	addi	s0,sp,32
    3ed0:	84aa                	mv	s1,a0
  if(mkdir("12345678901234") != 0){
    3ed2:	00003517          	auipc	a0,0x3
    3ed6:	8ee50513          	addi	a0,a0,-1810 # 67c0 <malloc+0x1a5a>
    3eda:	00001097          	auipc	ra,0x1
    3ede:	a94080e7          	jalr	-1388(ra) # 496e <mkdir>
    3ee2:	e165                	bnez	a0,3fc2 <fourteen+0xfc>
  if(mkdir("12345678901234/123456789012345") != 0){
    3ee4:	00002517          	auipc	a0,0x2
    3ee8:	73450513          	addi	a0,a0,1844 # 6618 <malloc+0x18b2>
    3eec:	00001097          	auipc	ra,0x1
    3ef0:	a82080e7          	jalr	-1406(ra) # 496e <mkdir>
    3ef4:	e56d                	bnez	a0,3fde <fourteen+0x118>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    3ef6:	20000593          	li	a1,512
    3efa:	00002517          	auipc	a0,0x2
    3efe:	77650513          	addi	a0,a0,1910 # 6670 <malloc+0x190a>
    3f02:	00001097          	auipc	ra,0x1
    3f06:	a5c080e7          	jalr	-1444(ra) # 495e <open>
  if(fd < 0){
    3f0a:	0e054863          	bltz	a0,3ffa <fourteen+0x134>
  close(fd);
    3f0e:	00001097          	auipc	ra,0x1
    3f12:	a38080e7          	jalr	-1480(ra) # 4946 <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    3f16:	4581                	li	a1,0
    3f18:	00002517          	auipc	a0,0x2
    3f1c:	7d050513          	addi	a0,a0,2000 # 66e8 <malloc+0x1982>
    3f20:	00001097          	auipc	ra,0x1
    3f24:	a3e080e7          	jalr	-1474(ra) # 495e <open>
  if(fd < 0){
    3f28:	0e054763          	bltz	a0,4016 <fourteen+0x150>
  close(fd);
    3f2c:	00001097          	auipc	ra,0x1
    3f30:	a1a080e7          	jalr	-1510(ra) # 4946 <close>
  if(mkdir("12345678901234/12345678901234") == 0){
    3f34:	00003517          	auipc	a0,0x3
    3f38:	82450513          	addi	a0,a0,-2012 # 6758 <malloc+0x19f2>
    3f3c:	00001097          	auipc	ra,0x1
    3f40:	a32080e7          	jalr	-1486(ra) # 496e <mkdir>
    3f44:	c57d                	beqz	a0,4032 <fourteen+0x16c>
  if(mkdir("123456789012345/12345678901234") == 0){
    3f46:	00003517          	auipc	a0,0x3
    3f4a:	86a50513          	addi	a0,a0,-1942 # 67b0 <malloc+0x1a4a>
    3f4e:	00001097          	auipc	ra,0x1
    3f52:	a20080e7          	jalr	-1504(ra) # 496e <mkdir>
    3f56:	cd65                	beqz	a0,404e <fourteen+0x188>
  remove("123456789012345/12345678901234");
    3f58:	00003517          	auipc	a0,0x3
    3f5c:	85850513          	addi	a0,a0,-1960 # 67b0 <malloc+0x1a4a>
    3f60:	00001097          	auipc	ra,0x1
    3f64:	a66080e7          	jalr	-1434(ra) # 49c6 <remove>
  remove("12345678901234/12345678901234");
    3f68:	00002517          	auipc	a0,0x2
    3f6c:	7f050513          	addi	a0,a0,2032 # 6758 <malloc+0x19f2>
    3f70:	00001097          	auipc	ra,0x1
    3f74:	a56080e7          	jalr	-1450(ra) # 49c6 <remove>
  remove("12345678901234/12345678901234/12345678901234");
    3f78:	00002517          	auipc	a0,0x2
    3f7c:	77050513          	addi	a0,a0,1904 # 66e8 <malloc+0x1982>
    3f80:	00001097          	auipc	ra,0x1
    3f84:	a46080e7          	jalr	-1466(ra) # 49c6 <remove>
  remove("123456789012345/123456789012345/123456789012345");
    3f88:	00002517          	auipc	a0,0x2
    3f8c:	6e850513          	addi	a0,a0,1768 # 6670 <malloc+0x190a>
    3f90:	00001097          	auipc	ra,0x1
    3f94:	a36080e7          	jalr	-1482(ra) # 49c6 <remove>
  remove("12345678901234/123456789012345");
    3f98:	00002517          	auipc	a0,0x2
    3f9c:	68050513          	addi	a0,a0,1664 # 6618 <malloc+0x18b2>
    3fa0:	00001097          	auipc	ra,0x1
    3fa4:	a26080e7          	jalr	-1498(ra) # 49c6 <remove>
  remove("12345678901234");
    3fa8:	00003517          	auipc	a0,0x3
    3fac:	81850513          	addi	a0,a0,-2024 # 67c0 <malloc+0x1a5a>
    3fb0:	00001097          	auipc	ra,0x1
    3fb4:	a16080e7          	jalr	-1514(ra) # 49c6 <remove>
}
    3fb8:	60e2                	ld	ra,24(sp)
    3fba:	6442                	ld	s0,16(sp)
    3fbc:	64a2                	ld	s1,8(sp)
    3fbe:	6105                	addi	sp,sp,32
    3fc0:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
    3fc2:	85a6                	mv	a1,s1
    3fc4:	00002517          	auipc	a0,0x2
    3fc8:	62c50513          	addi	a0,a0,1580 # 65f0 <malloc+0x188a>
    3fcc:	00001097          	auipc	ra,0x1
    3fd0:	ce2080e7          	jalr	-798(ra) # 4cae <printf>
    exit(1);
    3fd4:	4505                	li	a0,1
    3fd6:	00001097          	auipc	ra,0x1
    3fda:	948080e7          	jalr	-1720(ra) # 491e <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
    3fde:	85a6                	mv	a1,s1
    3fe0:	00002517          	auipc	a0,0x2
    3fe4:	65850513          	addi	a0,a0,1624 # 6638 <malloc+0x18d2>
    3fe8:	00001097          	auipc	ra,0x1
    3fec:	cc6080e7          	jalr	-826(ra) # 4cae <printf>
    exit(1);
    3ff0:	4505                	li	a0,1
    3ff2:	00001097          	auipc	ra,0x1
    3ff6:	92c080e7          	jalr	-1748(ra) # 491e <exit>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
    3ffa:	85a6                	mv	a1,s1
    3ffc:	00002517          	auipc	a0,0x2
    4000:	6a450513          	addi	a0,a0,1700 # 66a0 <malloc+0x193a>
    4004:	00001097          	auipc	ra,0x1
    4008:	caa080e7          	jalr	-854(ra) # 4cae <printf>
    exit(1);
    400c:	4505                	li	a0,1
    400e:	00001097          	auipc	ra,0x1
    4012:	910080e7          	jalr	-1776(ra) # 491e <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
    4016:	85a6                	mv	a1,s1
    4018:	00002517          	auipc	a0,0x2
    401c:	70050513          	addi	a0,a0,1792 # 6718 <malloc+0x19b2>
    4020:	00001097          	auipc	ra,0x1
    4024:	c8e080e7          	jalr	-882(ra) # 4cae <printf>
    exit(1);
    4028:	4505                	li	a0,1
    402a:	00001097          	auipc	ra,0x1
    402e:	8f4080e7          	jalr	-1804(ra) # 491e <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
    4032:	85a6                	mv	a1,s1
    4034:	00002517          	auipc	a0,0x2
    4038:	74450513          	addi	a0,a0,1860 # 6778 <malloc+0x1a12>
    403c:	00001097          	auipc	ra,0x1
    4040:	c72080e7          	jalr	-910(ra) # 4cae <printf>
    exit(1);
    4044:	4505                	li	a0,1
    4046:	00001097          	auipc	ra,0x1
    404a:	8d8080e7          	jalr	-1832(ra) # 491e <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
    404e:	85a6                	mv	a1,s1
    4050:	00002517          	auipc	a0,0x2
    4054:	78050513          	addi	a0,a0,1920 # 67d0 <malloc+0x1a6a>
    4058:	00001097          	auipc	ra,0x1
    405c:	c56080e7          	jalr	-938(ra) # 4cae <printf>
    exit(1);
    4060:	4505                	li	a0,1
    4062:	00001097          	auipc	ra,0x1
    4066:	8bc080e7          	jalr	-1860(ra) # 491e <exit>

000000000000406a <fsfull>:
{
    406a:	7135                	addi	sp,sp,-160
    406c:	ed06                	sd	ra,152(sp)
    406e:	e922                	sd	s0,144(sp)
    4070:	e526                	sd	s1,136(sp)
    4072:	e14a                	sd	s2,128(sp)
    4074:	fcce                	sd	s3,120(sp)
    4076:	f8d2                	sd	s4,112(sp)
    4078:	f4d6                	sd	s5,104(sp)
    407a:	f0da                	sd	s6,96(sp)
    407c:	ecde                	sd	s7,88(sp)
    407e:	e8e2                	sd	s8,80(sp)
    4080:	e4e6                	sd	s9,72(sp)
    4082:	e0ea                	sd	s10,64(sp)
    4084:	1100                	addi	s0,sp,160
  printf("fsfull test\n");
    4086:	00002517          	auipc	a0,0x2
    408a:	78250513          	addi	a0,a0,1922 # 6808 <malloc+0x1aa2>
    408e:	00001097          	auipc	ra,0x1
    4092:	c20080e7          	jalr	-992(ra) # 4cae <printf>
  for(nfiles = 0; ; nfiles++){
    4096:	4481                	li	s1,0
    name[0] = 'f';
    4098:	06600d13          	li	s10,102
    name[1] = '0' + nfiles / 1000;
    409c:	3e800c13          	li	s8,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    40a0:	06400b93          	li	s7,100
    name[3] = '0' + (nfiles % 100) / 10;
    40a4:	4b29                	li	s6,10
    printf("%s: writing %s\n", name);
    40a6:	00002c97          	auipc	s9,0x2
    40aa:	772c8c93          	addi	s9,s9,1906 # 6818 <malloc+0x1ab2>
    name[0] = 'f';
    40ae:	f7a40023          	sb	s10,-160(s0)
    name[1] = '0' + nfiles / 1000;
    40b2:	0384c7bb          	divw	a5,s1,s8
    40b6:	0307879b          	addiw	a5,a5,48
    40ba:	f6f400a3          	sb	a5,-159(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    40be:	0384e7bb          	remw	a5,s1,s8
    40c2:	0377c7bb          	divw	a5,a5,s7
    40c6:	0307879b          	addiw	a5,a5,48
    40ca:	f6f40123          	sb	a5,-158(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    40ce:	0374e7bb          	remw	a5,s1,s7
    40d2:	0367c7bb          	divw	a5,a5,s6
    40d6:	0307879b          	addiw	a5,a5,48
    40da:	f6f401a3          	sb	a5,-157(s0)
    name[4] = '0' + (nfiles % 10);
    40de:	0364e7bb          	remw	a5,s1,s6
    40e2:	0307879b          	addiw	a5,a5,48
    40e6:	f6f40223          	sb	a5,-156(s0)
    name[5] = '\0';
    40ea:	f60402a3          	sb	zero,-155(s0)
    printf("%s: writing %s\n", name);
    40ee:	f6040593          	addi	a1,s0,-160
    40f2:	8566                	mv	a0,s9
    40f4:	00001097          	auipc	ra,0x1
    40f8:	bba080e7          	jalr	-1094(ra) # 4cae <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    40fc:	20200593          	li	a1,514
    4100:	f6040513          	addi	a0,s0,-160
    4104:	00001097          	auipc	ra,0x1
    4108:	85a080e7          	jalr	-1958(ra) # 495e <open>
    410c:	892a                	mv	s2,a0
    if(fd < 0){
    410e:	0a055563          	bgez	a0,41b8 <fsfull+0x14e>
      printf("%s: open %s failed\n", name);
    4112:	f6040593          	addi	a1,s0,-160
    4116:	00002517          	auipc	a0,0x2
    411a:	71250513          	addi	a0,a0,1810 # 6828 <malloc+0x1ac2>
    411e:	00001097          	auipc	ra,0x1
    4122:	b90080e7          	jalr	-1136(ra) # 4cae <printf>
  while(nfiles >= 0){
    4126:	0604c363          	bltz	s1,418c <fsfull+0x122>
    name[0] = 'f';
    412a:	06600b13          	li	s6,102
    name[1] = '0' + nfiles / 1000;
    412e:	3e800a13          	li	s4,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4132:	06400993          	li	s3,100
    name[3] = '0' + (nfiles % 100) / 10;
    4136:	4929                	li	s2,10
  while(nfiles >= 0){
    4138:	5afd                	li	s5,-1
    name[0] = 'f';
    413a:	f7640023          	sb	s6,-160(s0)
    name[1] = '0' + nfiles / 1000;
    413e:	0344c7bb          	divw	a5,s1,s4
    4142:	0307879b          	addiw	a5,a5,48
    4146:	f6f400a3          	sb	a5,-159(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    414a:	0344e7bb          	remw	a5,s1,s4
    414e:	0337c7bb          	divw	a5,a5,s3
    4152:	0307879b          	addiw	a5,a5,48
    4156:	f6f40123          	sb	a5,-158(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    415a:	0334e7bb          	remw	a5,s1,s3
    415e:	0327c7bb          	divw	a5,a5,s2
    4162:	0307879b          	addiw	a5,a5,48
    4166:	f6f401a3          	sb	a5,-157(s0)
    name[4] = '0' + (nfiles % 10);
    416a:	0324e7bb          	remw	a5,s1,s2
    416e:	0307879b          	addiw	a5,a5,48
    4172:	f6f40223          	sb	a5,-156(s0)
    name[5] = '\0';
    4176:	f60402a3          	sb	zero,-155(s0)
    remove(name);
    417a:	f6040513          	addi	a0,s0,-160
    417e:	00001097          	auipc	ra,0x1
    4182:	848080e7          	jalr	-1976(ra) # 49c6 <remove>
    nfiles--;
    4186:	34fd                	addiw	s1,s1,-1
  while(nfiles >= 0){
    4188:	fb5499e3          	bne	s1,s5,413a <fsfull+0xd0>
  printf("fsfull test finished\n");
    418c:	00002517          	auipc	a0,0x2
    4190:	6cc50513          	addi	a0,a0,1740 # 6858 <malloc+0x1af2>
    4194:	00001097          	auipc	ra,0x1
    4198:	b1a080e7          	jalr	-1254(ra) # 4cae <printf>
}
    419c:	60ea                	ld	ra,152(sp)
    419e:	644a                	ld	s0,144(sp)
    41a0:	64aa                	ld	s1,136(sp)
    41a2:	690a                	ld	s2,128(sp)
    41a4:	79e6                	ld	s3,120(sp)
    41a6:	7a46                	ld	s4,112(sp)
    41a8:	7aa6                	ld	s5,104(sp)
    41aa:	7b06                	ld	s6,96(sp)
    41ac:	6be6                	ld	s7,88(sp)
    41ae:	6c46                	ld	s8,80(sp)
    41b0:	6ca6                	ld	s9,72(sp)
    41b2:	6d06                	ld	s10,64(sp)
    41b4:	610d                	addi	sp,sp,160
    41b6:	8082                	ret
    int total = 0;
    41b8:	4981                	li	s3,0
      int cc = write(fd, buf, BSIZE);
    41ba:	00006a97          	auipc	s5,0x6
    41be:	6d6a8a93          	addi	s5,s5,1750 # a890 <buf>
      if(cc < BSIZE)
    41c2:	1ff00a13          	li	s4,511
      int cc = write(fd, buf, BSIZE);
    41c6:	20000613          	li	a2,512
    41ca:	85d6                	mv	a1,s5
    41cc:	854a                	mv	a0,s2
    41ce:	00000097          	auipc	ra,0x0
    41d2:	770080e7          	jalr	1904(ra) # 493e <write>
      if(cc < BSIZE)
    41d6:	00aa5563          	bge	s4,a0,41e0 <fsfull+0x176>
      total += cc;
    41da:	00a989bb          	addw	s3,s3,a0
    while(1){
    41de:	b7e5                	j	41c6 <fsfull+0x15c>
    printf("%s: wrote %d bytes\n", total);
    41e0:	85ce                	mv	a1,s3
    41e2:	00002517          	auipc	a0,0x2
    41e6:	65e50513          	addi	a0,a0,1630 # 6840 <malloc+0x1ada>
    41ea:	00001097          	auipc	ra,0x1
    41ee:	ac4080e7          	jalr	-1340(ra) # 4cae <printf>
    close(fd);
    41f2:	854a                	mv	a0,s2
    41f4:	00000097          	auipc	ra,0x0
    41f8:	752080e7          	jalr	1874(ra) # 4946 <close>
    if(total == 0)
    41fc:	f20985e3          	beqz	s3,4126 <fsfull+0xbc>
  for(nfiles = 0; ; nfiles++){
    4200:	2485                	addiw	s1,s1,1
    4202:	b575                	j	40ae <fsfull+0x44>

0000000000004204 <rand>:
{
    4204:	1141                	addi	sp,sp,-16
    4206:	e422                	sd	s0,8(sp)
    4208:	0800                	addi	s0,sp,16
  randstate = randstate * 1664525 + 1013904223;
    420a:	00003717          	auipc	a4,0x3
    420e:	e5670713          	addi	a4,a4,-426 # 7060 <randstate>
    4212:	6308                	ld	a0,0(a4)
    4214:	001967b7          	lui	a5,0x196
    4218:	60d78793          	addi	a5,a5,1549 # 19660d <__BSS_END__+0x18a56d>
    421c:	02f50533          	mul	a0,a0,a5
    4220:	3c6ef7b7          	lui	a5,0x3c6ef
    4224:	35f78793          	addi	a5,a5,863 # 3c6ef35f <__BSS_END__+0x3c6e32bf>
    4228:	953e                	add	a0,a0,a5
    422a:	e308                	sd	a0,0(a4)
}
    422c:	2501                	sext.w	a0,a0
    422e:	6422                	ld	s0,8(sp)
    4230:	0141                	addi	sp,sp,16
    4232:	8082                	ret

0000000000004234 <countfree>:
// because out of memory with lazy allocation results in the process
// taking a fault and being killed, fork and report back.
//
int
countfree()
{
    4234:	7139                	addi	sp,sp,-64
    4236:	fc06                	sd	ra,56(sp)
    4238:	f822                	sd	s0,48(sp)
    423a:	0080                	addi	s0,sp,64
  int fds[2];

  if(pipe(fds) < 0){
    423c:	fc840513          	addi	a0,s0,-56
    4240:	00000097          	auipc	ra,0x0
    4244:	6ee080e7          	jalr	1774(ra) # 492e <pipe>
    4248:	06054a63          	bltz	a0,42bc <countfree+0x88>
    printf("pipe() failed in countfree()\n");
    exit(1);
  }
  
  int pid = fork();
    424c:	00000097          	auipc	ra,0x0
    4250:	6ca080e7          	jalr	1738(ra) # 4916 <fork>

  if(pid < 0){
    4254:	08054463          	bltz	a0,42dc <countfree+0xa8>
    printf("fork failed in countfree()\n");
    exit(1);
  }

  if(pid == 0){
    4258:	e55d                	bnez	a0,4306 <countfree+0xd2>
    425a:	f426                	sd	s1,40(sp)
    425c:	f04a                	sd	s2,32(sp)
    425e:	ec4e                	sd	s3,24(sp)
    close(fds[0]);
    4260:	fc842503          	lw	a0,-56(s0)
    4264:	00000097          	auipc	ra,0x0
    4268:	6e2080e7          	jalr	1762(ra) # 4946 <close>
    
    while(1){
      uint64 a = (uint64) sbrk(4096);
      if(a == 0xffffffffffffffff){
    426c:	597d                	li	s2,-1
        break;
      }

      // modify the memory to make sure it's really allocated.
      *(char *)(a + 4096 - 1) = 1;
    426e:	4485                	li	s1,1

      // report back one more page.
      if(write(fds[1], "x", 1) != 1){
    4270:	00001997          	auipc	s3,0x1
    4274:	cd898993          	addi	s3,s3,-808 # 4f48 <malloc+0x1e2>
      uint64 a = (uint64) sbrk(4096);
    4278:	6505                	lui	a0,0x1
    427a:	00000097          	auipc	ra,0x0
    427e:	714080e7          	jalr	1812(ra) # 498e <sbrk>
      if(a == 0xffffffffffffffff){
    4282:	07250d63          	beq	a0,s2,42fc <countfree+0xc8>
      *(char *)(a + 4096 - 1) = 1;
    4286:	6785                	lui	a5,0x1
    4288:	97aa                	add	a5,a5,a0
    428a:	fe978fa3          	sb	s1,-1(a5) # fff <copyinstr2+0xd7>
      if(write(fds[1], "x", 1) != 1){
    428e:	8626                	mv	a2,s1
    4290:	85ce                	mv	a1,s3
    4292:	fcc42503          	lw	a0,-52(s0)
    4296:	00000097          	auipc	ra,0x0
    429a:	6a8080e7          	jalr	1704(ra) # 493e <write>
    429e:	fc950de3          	beq	a0,s1,4278 <countfree+0x44>
        printf("write() failed in countfree()\n");
    42a2:	00002517          	auipc	a0,0x2
    42a6:	60e50513          	addi	a0,a0,1550 # 68b0 <malloc+0x1b4a>
    42aa:	00001097          	auipc	ra,0x1
    42ae:	a04080e7          	jalr	-1532(ra) # 4cae <printf>
        exit(1);
    42b2:	4505                	li	a0,1
    42b4:	00000097          	auipc	ra,0x0
    42b8:	66a080e7          	jalr	1642(ra) # 491e <exit>
    42bc:	f426                	sd	s1,40(sp)
    42be:	f04a                	sd	s2,32(sp)
    42c0:	ec4e                	sd	s3,24(sp)
    printf("pipe() failed in countfree()\n");
    42c2:	00002517          	auipc	a0,0x2
    42c6:	5ae50513          	addi	a0,a0,1454 # 6870 <malloc+0x1b0a>
    42ca:	00001097          	auipc	ra,0x1
    42ce:	9e4080e7          	jalr	-1564(ra) # 4cae <printf>
    exit(1);
    42d2:	4505                	li	a0,1
    42d4:	00000097          	auipc	ra,0x0
    42d8:	64a080e7          	jalr	1610(ra) # 491e <exit>
    42dc:	f426                	sd	s1,40(sp)
    42de:	f04a                	sd	s2,32(sp)
    42e0:	ec4e                	sd	s3,24(sp)
    printf("fork failed in countfree()\n");
    42e2:	00002517          	auipc	a0,0x2
    42e6:	5ae50513          	addi	a0,a0,1454 # 6890 <malloc+0x1b2a>
    42ea:	00001097          	auipc	ra,0x1
    42ee:	9c4080e7          	jalr	-1596(ra) # 4cae <printf>
    exit(1);
    42f2:	4505                	li	a0,1
    42f4:	00000097          	auipc	ra,0x0
    42f8:	62a080e7          	jalr	1578(ra) # 491e <exit>
      }
    }

    exit(0);
    42fc:	4501                	li	a0,0
    42fe:	00000097          	auipc	ra,0x0
    4302:	620080e7          	jalr	1568(ra) # 491e <exit>
    4306:	f426                	sd	s1,40(sp)
  }

  close(fds[1]);
    4308:	fcc42503          	lw	a0,-52(s0)
    430c:	00000097          	auipc	ra,0x0
    4310:	63a080e7          	jalr	1594(ra) # 4946 <close>

  int n = 0;
    4314:	4481                	li	s1,0
  while(1){
    char c;
    int cc = read(fds[0], &c, 1);
    4316:	4605                	li	a2,1
    4318:	fc740593          	addi	a1,s0,-57
    431c:	fc842503          	lw	a0,-56(s0)
    4320:	00000097          	auipc	ra,0x0
    4324:	616080e7          	jalr	1558(ra) # 4936 <read>
    if(cc < 0){
    4328:	00054563          	bltz	a0,4332 <countfree+0xfe>
      printf("read() failed in countfree()\n");
      exit(1);
    }
    if(cc == 0)
    432c:	c115                	beqz	a0,4350 <countfree+0x11c>
      break;
    n += 1;
    432e:	2485                	addiw	s1,s1,1
  while(1){
    4330:	b7dd                	j	4316 <countfree+0xe2>
    4332:	f04a                	sd	s2,32(sp)
    4334:	ec4e                	sd	s3,24(sp)
      printf("read() failed in countfree()\n");
    4336:	00002517          	auipc	a0,0x2
    433a:	59a50513          	addi	a0,a0,1434 # 68d0 <malloc+0x1b6a>
    433e:	00001097          	auipc	ra,0x1
    4342:	970080e7          	jalr	-1680(ra) # 4cae <printf>
      exit(1);
    4346:	4505                	li	a0,1
    4348:	00000097          	auipc	ra,0x0
    434c:	5d6080e7          	jalr	1494(ra) # 491e <exit>
  }

  close(fds[0]);
    4350:	fc842503          	lw	a0,-56(s0)
    4354:	00000097          	auipc	ra,0x0
    4358:	5f2080e7          	jalr	1522(ra) # 4946 <close>
  wait((int*)0);
    435c:	4501                	li	a0,0
    435e:	00000097          	auipc	ra,0x0
    4362:	5c8080e7          	jalr	1480(ra) # 4926 <wait>
  
  return n;
}
    4366:	8526                	mv	a0,s1
    4368:	74a2                	ld	s1,40(sp)
    436a:	70e2                	ld	ra,56(sp)
    436c:	7442                	ld	s0,48(sp)
    436e:	6121                	addi	sp,sp,64
    4370:	8082                	ret

0000000000004372 <run>:

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
    4372:	7179                	addi	sp,sp,-48
    4374:	f406                	sd	ra,40(sp)
    4376:	f022                	sd	s0,32(sp)
    4378:	ec26                	sd	s1,24(sp)
    437a:	e84a                	sd	s2,16(sp)
    437c:	1800                	addi	s0,sp,48
    437e:	84aa                	mv	s1,a0
    4380:	892e                	mv	s2,a1
  int pid;
  int xstatus;

  printf("test %s: ", s);
    4382:	00002517          	auipc	a0,0x2
    4386:	56e50513          	addi	a0,a0,1390 # 68f0 <malloc+0x1b8a>
    438a:	00001097          	auipc	ra,0x1
    438e:	924080e7          	jalr	-1756(ra) # 4cae <printf>
  if((pid = fork()) < 0) {
    4392:	00000097          	auipc	ra,0x0
    4396:	584080e7          	jalr	1412(ra) # 4916 <fork>
    439a:	02054e63          	bltz	a0,43d6 <run+0x64>
    printf("runtest: fork error\n");
    exit(1);
  }
  if(pid == 0) {
    439e:	c929                	beqz	a0,43f0 <run+0x7e>
    f(s);
    exit(0);
  } else {
    wait(&xstatus);
    43a0:	fdc40513          	addi	a0,s0,-36
    43a4:	00000097          	auipc	ra,0x0
    43a8:	582080e7          	jalr	1410(ra) # 4926 <wait>
    if(xstatus != 0) 
    43ac:	fdc42783          	lw	a5,-36(s0)
    43b0:	c7b9                	beqz	a5,43fe <run+0x8c>
      printf("FAILED\n");
    43b2:	00002517          	auipc	a0,0x2
    43b6:	56650513          	addi	a0,a0,1382 # 6918 <malloc+0x1bb2>
    43ba:	00001097          	auipc	ra,0x1
    43be:	8f4080e7          	jalr	-1804(ra) # 4cae <printf>
    else
      printf("OK\n");
    return xstatus == 0;
    43c2:	fdc42503          	lw	a0,-36(s0)
  }
}
    43c6:	00153513          	seqz	a0,a0
    43ca:	70a2                	ld	ra,40(sp)
    43cc:	7402                	ld	s0,32(sp)
    43ce:	64e2                	ld	s1,24(sp)
    43d0:	6942                	ld	s2,16(sp)
    43d2:	6145                	addi	sp,sp,48
    43d4:	8082                	ret
    printf("runtest: fork error\n");
    43d6:	00002517          	auipc	a0,0x2
    43da:	52a50513          	addi	a0,a0,1322 # 6900 <malloc+0x1b9a>
    43de:	00001097          	auipc	ra,0x1
    43e2:	8d0080e7          	jalr	-1840(ra) # 4cae <printf>
    exit(1);
    43e6:	4505                	li	a0,1
    43e8:	00000097          	auipc	ra,0x0
    43ec:	536080e7          	jalr	1334(ra) # 491e <exit>
    f(s);
    43f0:	854a                	mv	a0,s2
    43f2:	9482                	jalr	s1
    exit(0);
    43f4:	4501                	li	a0,0
    43f6:	00000097          	auipc	ra,0x0
    43fa:	528080e7          	jalr	1320(ra) # 491e <exit>
      printf("OK\n");
    43fe:	00002517          	auipc	a0,0x2
    4402:	52250513          	addi	a0,a0,1314 # 6920 <malloc+0x1bba>
    4406:	00001097          	auipc	ra,0x1
    440a:	8a8080e7          	jalr	-1880(ra) # 4cae <printf>
    440e:	bf55                	j	43c2 <run+0x50>

0000000000004410 <main>:

int
main(int argc, char *argv[])
{
    4410:	c8010113          	addi	sp,sp,-896
    4414:	36113c23          	sd	ra,888(sp)
    4418:	36813823          	sd	s0,880(sp)
    441c:	35313c23          	sd	s3,856(sp)
    4420:	0700                	addi	s0,sp,896
    4422:	89aa                	mv	s3,a0
  int continuous = 0;
  char *justone = 0;

  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    4424:	4789                	li	a5,2
    4426:	0af50263          	beq	a0,a5,44ca <main+0xba>
    continuous = 1;
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    continuous = 2;
  } else if(argc == 2 && argv[1][0] != '-'){
    justone = argv[1];
  } else if(argc > 1){
    442a:	4785                	li	a5,1
    442c:	14a7c263          	blt	a5,a0,4570 <main+0x160>
  char *justone = 0;
    4430:	4981                	li	s3,0
    4432:	36913423          	sd	s1,872(sp)
    4436:	37213023          	sd	s2,864(sp)
    443a:	35413823          	sd	s4,848(sp)
    443e:	35513423          	sd	s5,840(sp)
    4442:	35613023          	sd	s6,832(sp)
  }
  
  struct test {
    void (*f)(char *);
    char *s;
  } tests[] = {
    4446:	00003797          	auipc	a5,0x3
    444a:	86a78793          	addi	a5,a5,-1942 # 6cb0 <malloc+0x1f4a>
    444e:	c8040713          	addi	a4,s0,-896
    4452:	00003817          	auipc	a6,0x3
    4456:	b9e80813          	addi	a6,a6,-1122 # 6ff0 <malloc+0x228a>
    445a:	6388                	ld	a0,0(a5)
    445c:	678c                	ld	a1,8(a5)
    445e:	6b90                	ld	a2,16(a5)
    4460:	6f94                	ld	a3,24(a5)
    4462:	e308                	sd	a0,0(a4)
    4464:	e70c                	sd	a1,8(a4)
    4466:	eb10                	sd	a2,16(a4)
    4468:	ef14                	sd	a3,24(a4)
    446a:	02078793          	addi	a5,a5,32
    446e:	02070713          	addi	a4,a4,32
    4472:	ff0794e3          	bne	a5,a6,445a <main+0x4a>
          exit(1);
      }
    }
  }

  printf("usertests starting\n");
    4476:	00002517          	auipc	a0,0x2
    447a:	56a50513          	addi	a0,a0,1386 # 69e0 <malloc+0x1c7a>
    447e:	00001097          	auipc	ra,0x1
    4482:	830080e7          	jalr	-2000(ra) # 4cae <printf>
  int free0 = countfree();
    4486:	00000097          	auipc	ra,0x0
    448a:	dae080e7          	jalr	-594(ra) # 4234 <countfree>
    448e:	8aaa                	mv	s5,a0
  int free1 = 0;
  int fail = 0;
  for (struct test *t = tests; t->s != 0; t++) {
    4490:	c8843903          	ld	s2,-888(s0)
    4494:	c8040493          	addi	s1,s0,-896
  int fail = 0;
    4498:	4a01                	li	s4,0
    if((justone == 0) || strcmp(t->s, justone) == 0) {
      if(!run(t->f, t->s))
        fail = 1;
    449a:	4b05                	li	s6,1
  for (struct test *t = tests; t->s != 0; t++) {
    449c:	12091963          	bnez	s2,45ce <main+0x1be>
  }

  if(fail){
    printf("SOME TESTS FAILED\n");
    exit(1);
  } else if((free1 = countfree()) < free0){
    44a0:	00000097          	auipc	ra,0x0
    44a4:	d94080e7          	jalr	-620(ra) # 4234 <countfree>
    44a8:	85aa                	mv	a1,a0
    44aa:	17555363          	bge	a0,s5,4610 <main+0x200>
    printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    44ae:	8656                	mv	a2,s5
    44b0:	00002517          	auipc	a0,0x2
    44b4:	4e850513          	addi	a0,a0,1256 # 6998 <malloc+0x1c32>
    44b8:	00000097          	auipc	ra,0x0
    44bc:	7f6080e7          	jalr	2038(ra) # 4cae <printf>
    exit(1);
    44c0:	4505                	li	a0,1
    44c2:	00000097          	auipc	ra,0x0
    44c6:	45c080e7          	jalr	1116(ra) # 491e <exit>
    44ca:	36913423          	sd	s1,872(sp)
    44ce:	37213023          	sd	s2,864(sp)
    44d2:	35413823          	sd	s4,848(sp)
    44d6:	35513423          	sd	s5,840(sp)
    44da:	35613023          	sd	s6,832(sp)
    44de:	84ae                	mv	s1,a1
  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    44e0:	00002597          	auipc	a1,0x2
    44e4:	44858593          	addi	a1,a1,1096 # 6928 <malloc+0x1bc2>
    44e8:	6488                	ld	a0,8(s1)
    44ea:	00000097          	auipc	ra,0x0
    44ee:	1cc080e7          	jalr	460(ra) # 46b6 <strcmp>
    44f2:	ed21                	bnez	a0,454a <main+0x13a>
    continuous = 1;
    44f4:	4985                	li	s3,1
  } tests[] = {
    44f6:	00002797          	auipc	a5,0x2
    44fa:	7ba78793          	addi	a5,a5,1978 # 6cb0 <malloc+0x1f4a>
    44fe:	c8040713          	addi	a4,s0,-896
    4502:	00003817          	auipc	a6,0x3
    4506:	aee80813          	addi	a6,a6,-1298 # 6ff0 <malloc+0x228a>
    450a:	6388                	ld	a0,0(a5)
    450c:	678c                	ld	a1,8(a5)
    450e:	6b90                	ld	a2,16(a5)
    4510:	6f94                	ld	a3,24(a5)
    4512:	e308                	sd	a0,0(a4)
    4514:	e70c                	sd	a1,8(a4)
    4516:	eb10                	sd	a2,16(a4)
    4518:	ef14                	sd	a3,24(a4)
    451a:	02078793          	addi	a5,a5,32
    451e:	02070713          	addi	a4,a4,32
    4522:	ff0794e3          	bne	a5,a6,450a <main+0xfa>
    printf("continuous usertests starting\n");
    4526:	00002517          	auipc	a0,0x2
    452a:	4d250513          	addi	a0,a0,1234 # 69f8 <malloc+0x1c92>
    452e:	00000097          	auipc	ra,0x0
    4532:	780080e7          	jalr	1920(ra) # 4cae <printf>
        printf("SOME TESTS FAILED\n");
    4536:	00002a97          	auipc	s5,0x2
    453a:	44aa8a93          	addi	s5,s5,1098 # 6980 <malloc+0x1c1a>
        if(continuous != 2)
    453e:	4a09                	li	s4,2
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    4540:	00002b17          	auipc	s6,0x2
    4544:	420b0b13          	addi	s6,s6,1056 # 6960 <malloc+0x1bfa>
    4548:	a8f5                	j	4644 <main+0x234>
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    454a:	00002597          	auipc	a1,0x2
    454e:	3e658593          	addi	a1,a1,998 # 6930 <malloc+0x1bca>
    4552:	6488                	ld	a0,8(s1)
    4554:	00000097          	auipc	ra,0x0
    4558:	162080e7          	jalr	354(ra) # 46b6 <strcmp>
    455c:	dd49                	beqz	a0,44f6 <main+0xe6>
  } else if(argc == 2 && argv[1][0] != '-'){
    455e:	0084b983          	ld	s3,8(s1)
    4562:	0009c703          	lbu	a4,0(s3)
    4566:	02d00793          	li	a5,45
    456a:	ecf71ee3          	bne	a4,a5,4446 <main+0x36>
    456e:	a819                	j	4584 <main+0x174>
    4570:	36913423          	sd	s1,872(sp)
    4574:	37213023          	sd	s2,864(sp)
    4578:	35413823          	sd	s4,848(sp)
    457c:	35513423          	sd	s5,840(sp)
    4580:	35613023          	sd	s6,832(sp)
    printf("Usage: usertests [-c] [testname]\n");
    4584:	00002517          	auipc	a0,0x2
    4588:	3b450513          	addi	a0,a0,948 # 6938 <malloc+0x1bd2>
    458c:	00000097          	auipc	ra,0x0
    4590:	722080e7          	jalr	1826(ra) # 4cae <printf>
    exit(1);
    4594:	4505                	li	a0,1
    4596:	00000097          	auipc	ra,0x0
    459a:	388080e7          	jalr	904(ra) # 491e <exit>
          exit(1);
    459e:	4505                	li	a0,1
    45a0:	00000097          	auipc	ra,0x0
    45a4:	37e080e7          	jalr	894(ra) # 491e <exit>
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    45a8:	40a905bb          	subw	a1,s2,a0
    45ac:	855a                	mv	a0,s6
    45ae:	00000097          	auipc	ra,0x0
    45b2:	700080e7          	jalr	1792(ra) # 4cae <printf>
        if(continuous != 2)
    45b6:	09498763          	beq	s3,s4,4644 <main+0x234>
          exit(1);
    45ba:	4505                	li	a0,1
    45bc:	00000097          	auipc	ra,0x0
    45c0:	362080e7          	jalr	866(ra) # 491e <exit>
  for (struct test *t = tests; t->s != 0; t++) {
    45c4:	04c1                	addi	s1,s1,16
    45c6:	0084b903          	ld	s2,8(s1)
    45ca:	02090463          	beqz	s2,45f2 <main+0x1e2>
    if((justone == 0) || strcmp(t->s, justone) == 0) {
    45ce:	00098963          	beqz	s3,45e0 <main+0x1d0>
    45d2:	85ce                	mv	a1,s3
    45d4:	854a                	mv	a0,s2
    45d6:	00000097          	auipc	ra,0x0
    45da:	0e0080e7          	jalr	224(ra) # 46b6 <strcmp>
    45de:	f17d                	bnez	a0,45c4 <main+0x1b4>
      if(!run(t->f, t->s))
    45e0:	85ca                	mv	a1,s2
    45e2:	6088                	ld	a0,0(s1)
    45e4:	00000097          	auipc	ra,0x0
    45e8:	d8e080e7          	jalr	-626(ra) # 4372 <run>
    45ec:	fd61                	bnez	a0,45c4 <main+0x1b4>
        fail = 1;
    45ee:	8a5a                	mv	s4,s6
    45f0:	bfd1                	j	45c4 <main+0x1b4>
  if(fail){
    45f2:	ea0a07e3          	beqz	s4,44a0 <main+0x90>
    printf("SOME TESTS FAILED\n");
    45f6:	00002517          	auipc	a0,0x2
    45fa:	38a50513          	addi	a0,a0,906 # 6980 <malloc+0x1c1a>
    45fe:	00000097          	auipc	ra,0x0
    4602:	6b0080e7          	jalr	1712(ra) # 4cae <printf>
    exit(1);
    4606:	4505                	li	a0,1
    4608:	00000097          	auipc	ra,0x0
    460c:	316080e7          	jalr	790(ra) # 491e <exit>
  } else {
    printf("ALL TESTS PASSED\n");
    4610:	00002517          	auipc	a0,0x2
    4614:	3b850513          	addi	a0,a0,952 # 69c8 <malloc+0x1c62>
    4618:	00000097          	auipc	ra,0x0
    461c:	696080e7          	jalr	1686(ra) # 4cae <printf>
    exit(0);
    4620:	4501                	li	a0,0
    4622:	00000097          	auipc	ra,0x0
    4626:	2fc080e7          	jalr	764(ra) # 491e <exit>
        printf("SOME TESTS FAILED\n");
    462a:	8556                	mv	a0,s5
    462c:	00000097          	auipc	ra,0x0
    4630:	682080e7          	jalr	1666(ra) # 4cae <printf>
        if(continuous != 2)
    4634:	f74995e3          	bne	s3,s4,459e <main+0x18e>
      int free1 = countfree();
    4638:	00000097          	auipc	ra,0x0
    463c:	bfc080e7          	jalr	-1028(ra) # 4234 <countfree>
      if(free1 < free0){
    4640:	f72544e3          	blt	a0,s2,45a8 <main+0x198>
      int free0 = countfree();
    4644:	00000097          	auipc	ra,0x0
    4648:	bf0080e7          	jalr	-1040(ra) # 4234 <countfree>
    464c:	892a                	mv	s2,a0
      for (struct test *t = tests; t->s != 0; t++) {
    464e:	c8843583          	ld	a1,-888(s0)
    4652:	d1fd                	beqz	a1,4638 <main+0x228>
    4654:	c8040493          	addi	s1,s0,-896
        if(!run(t->f, t->s)){
    4658:	6088                	ld	a0,0(s1)
    465a:	00000097          	auipc	ra,0x0
    465e:	d18080e7          	jalr	-744(ra) # 4372 <run>
    4662:	d561                	beqz	a0,462a <main+0x21a>
      for (struct test *t = tests; t->s != 0; t++) {
    4664:	04c1                	addi	s1,s1,16
    4666:	648c                	ld	a1,8(s1)
    4668:	f9e5                	bnez	a1,4658 <main+0x248>
    466a:	b7f9                	j	4638 <main+0x228>

000000000000466c <strcpy>:
#include "kernel/include/fcntl.h"
#include "xv6-user/user.h"

char*
strcpy(char *s, const char *t)
{
    466c:	1141                	addi	sp,sp,-16
    466e:	e422                	sd	s0,8(sp)
    4670:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    4672:	87aa                	mv	a5,a0
    4674:	0585                	addi	a1,a1,1
    4676:	0785                	addi	a5,a5,1
    4678:	fff5c703          	lbu	a4,-1(a1)
    467c:	fee78fa3          	sb	a4,-1(a5)
    4680:	fb75                	bnez	a4,4674 <strcpy+0x8>
    ;
  return os;
}
    4682:	6422                	ld	s0,8(sp)
    4684:	0141                	addi	sp,sp,16
    4686:	8082                	ret

0000000000004688 <strcat>:

char*
strcat(char *s, const char *t)
{
    4688:	1141                	addi	sp,sp,-16
    468a:	e422                	sd	s0,8(sp)
    468c:	0800                	addi	s0,sp,16
  char *os = s;
  while(*s)
    468e:	00054783          	lbu	a5,0(a0)
    4692:	c385                	beqz	a5,46b2 <strcat+0x2a>
    4694:	87aa                	mv	a5,a0
    s++;
    4696:	0785                	addi	a5,a5,1
  while(*s)
    4698:	0007c703          	lbu	a4,0(a5)
    469c:	ff6d                	bnez	a4,4696 <strcat+0xe>
  while((*s++ = *t++))
    469e:	0585                	addi	a1,a1,1
    46a0:	0785                	addi	a5,a5,1
    46a2:	fff5c703          	lbu	a4,-1(a1)
    46a6:	fee78fa3          	sb	a4,-1(a5)
    46aa:	fb75                	bnez	a4,469e <strcat+0x16>
    ;
  return os;
}
    46ac:	6422                	ld	s0,8(sp)
    46ae:	0141                	addi	sp,sp,16
    46b0:	8082                	ret
  while(*s)
    46b2:	87aa                	mv	a5,a0
    46b4:	b7ed                	j	469e <strcat+0x16>

00000000000046b6 <strcmp>:


int
strcmp(const char *p, const char *q)
{
    46b6:	1141                	addi	sp,sp,-16
    46b8:	e422                	sd	s0,8(sp)
    46ba:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    46bc:	00054783          	lbu	a5,0(a0)
    46c0:	cb91                	beqz	a5,46d4 <strcmp+0x1e>
    46c2:	0005c703          	lbu	a4,0(a1)
    46c6:	00f71763          	bne	a4,a5,46d4 <strcmp+0x1e>
    p++, q++;
    46ca:	0505                	addi	a0,a0,1
    46cc:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    46ce:	00054783          	lbu	a5,0(a0)
    46d2:	fbe5                	bnez	a5,46c2 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    46d4:	0005c503          	lbu	a0,0(a1)
}
    46d8:	40a7853b          	subw	a0,a5,a0
    46dc:	6422                	ld	s0,8(sp)
    46de:	0141                	addi	sp,sp,16
    46e0:	8082                	ret

00000000000046e2 <strlen>:

uint
strlen(const char *s)
{
    46e2:	1141                	addi	sp,sp,-16
    46e4:	e422                	sd	s0,8(sp)
    46e6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    46e8:	00054783          	lbu	a5,0(a0)
    46ec:	cf91                	beqz	a5,4708 <strlen+0x26>
    46ee:	0505                	addi	a0,a0,1
    46f0:	87aa                	mv	a5,a0
    46f2:	86be                	mv	a3,a5
    46f4:	0785                	addi	a5,a5,1
    46f6:	fff7c703          	lbu	a4,-1(a5)
    46fa:	ff65                	bnez	a4,46f2 <strlen+0x10>
    46fc:	40a6853b          	subw	a0,a3,a0
    4700:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    4702:	6422                	ld	s0,8(sp)
    4704:	0141                	addi	sp,sp,16
    4706:	8082                	ret
  for(n = 0; s[n]; n++)
    4708:	4501                	li	a0,0
    470a:	bfe5                	j	4702 <strlen+0x20>

000000000000470c <memset>:

void*
memset(void *dst, int c, uint n)
{
    470c:	1141                	addi	sp,sp,-16
    470e:	e422                	sd	s0,8(sp)
    4710:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    4712:	ca19                	beqz	a2,4728 <memset+0x1c>
    4714:	87aa                	mv	a5,a0
    4716:	1602                	slli	a2,a2,0x20
    4718:	9201                	srli	a2,a2,0x20
    471a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    471e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    4722:	0785                	addi	a5,a5,1
    4724:	fee79de3          	bne	a5,a4,471e <memset+0x12>
  }
  return dst;
}
    4728:	6422                	ld	s0,8(sp)
    472a:	0141                	addi	sp,sp,16
    472c:	8082                	ret

000000000000472e <strchr>:

char*
strchr(const char *s, char c)
{
    472e:	1141                	addi	sp,sp,-16
    4730:	e422                	sd	s0,8(sp)
    4732:	0800                	addi	s0,sp,16
  for(; *s; s++)
    4734:	00054783          	lbu	a5,0(a0)
    4738:	cb99                	beqz	a5,474e <strchr+0x20>
    if(*s == c)
    473a:	00f58763          	beq	a1,a5,4748 <strchr+0x1a>
  for(; *s; s++)
    473e:	0505                	addi	a0,a0,1
    4740:	00054783          	lbu	a5,0(a0)
    4744:	fbfd                	bnez	a5,473a <strchr+0xc>
      return (char*)s;
  return 0;
    4746:	4501                	li	a0,0
}
    4748:	6422                	ld	s0,8(sp)
    474a:	0141                	addi	sp,sp,16
    474c:	8082                	ret
  return 0;
    474e:	4501                	li	a0,0
    4750:	bfe5                	j	4748 <strchr+0x1a>

0000000000004752 <gets>:

char*
gets(char *buf, int max)
{
    4752:	711d                	addi	sp,sp,-96
    4754:	ec86                	sd	ra,88(sp)
    4756:	e8a2                	sd	s0,80(sp)
    4758:	e4a6                	sd	s1,72(sp)
    475a:	e0ca                	sd	s2,64(sp)
    475c:	fc4e                	sd	s3,56(sp)
    475e:	f852                	sd	s4,48(sp)
    4760:	f456                	sd	s5,40(sp)
    4762:	f05a                	sd	s6,32(sp)
    4764:	ec5e                	sd	s7,24(sp)
    4766:	1080                	addi	s0,sp,96
    4768:	8baa                	mv	s7,a0
    476a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    476c:	892a                	mv	s2,a0
    476e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    4770:	4aa9                	li	s5,10
    4772:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    4774:	89a6                	mv	s3,s1
    4776:	2485                	addiw	s1,s1,1
    4778:	0344d863          	bge	s1,s4,47a8 <gets+0x56>
    cc = read(0, &c, 1);
    477c:	4605                	li	a2,1
    477e:	faf40593          	addi	a1,s0,-81
    4782:	4501                	li	a0,0
    4784:	00000097          	auipc	ra,0x0
    4788:	1b2080e7          	jalr	434(ra) # 4936 <read>
    if(cc < 1)
    478c:	00a05e63          	blez	a0,47a8 <gets+0x56>
    buf[i++] = c;
    4790:	faf44783          	lbu	a5,-81(s0)
    4794:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    4798:	01578763          	beq	a5,s5,47a6 <gets+0x54>
    479c:	0905                	addi	s2,s2,1
    479e:	fd679be3          	bne	a5,s6,4774 <gets+0x22>
    buf[i++] = c;
    47a2:	89a6                	mv	s3,s1
    47a4:	a011                	j	47a8 <gets+0x56>
    47a6:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    47a8:	99de                	add	s3,s3,s7
    47aa:	00098023          	sb	zero,0(s3)
  return buf;
}
    47ae:	855e                	mv	a0,s7
    47b0:	60e6                	ld	ra,88(sp)
    47b2:	6446                	ld	s0,80(sp)
    47b4:	64a6                	ld	s1,72(sp)
    47b6:	6906                	ld	s2,64(sp)
    47b8:	79e2                	ld	s3,56(sp)
    47ba:	7a42                	ld	s4,48(sp)
    47bc:	7aa2                	ld	s5,40(sp)
    47be:	7b02                	ld	s6,32(sp)
    47c0:	6be2                	ld	s7,24(sp)
    47c2:	6125                	addi	sp,sp,96
    47c4:	8082                	ret

00000000000047c6 <stat>:

int
stat(const char *n, struct stat *st)
{
    47c6:	1101                	addi	sp,sp,-32
    47c8:	ec06                	sd	ra,24(sp)
    47ca:	e822                	sd	s0,16(sp)
    47cc:	e04a                	sd	s2,0(sp)
    47ce:	1000                	addi	s0,sp,32
    47d0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    47d2:	4581                	li	a1,0
    47d4:	00000097          	auipc	ra,0x0
    47d8:	18a080e7          	jalr	394(ra) # 495e <open>
  if(fd < 0)
    47dc:	02054663          	bltz	a0,4808 <stat+0x42>
    47e0:	e426                	sd	s1,8(sp)
    47e2:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    47e4:	85ca                	mv	a1,s2
    47e6:	00000097          	auipc	ra,0x0
    47ea:	180080e7          	jalr	384(ra) # 4966 <fstat>
    47ee:	892a                	mv	s2,a0
  close(fd);
    47f0:	8526                	mv	a0,s1
    47f2:	00000097          	auipc	ra,0x0
    47f6:	154080e7          	jalr	340(ra) # 4946 <close>
  return r;
    47fa:	64a2                	ld	s1,8(sp)
}
    47fc:	854a                	mv	a0,s2
    47fe:	60e2                	ld	ra,24(sp)
    4800:	6442                	ld	s0,16(sp)
    4802:	6902                	ld	s2,0(sp)
    4804:	6105                	addi	sp,sp,32
    4806:	8082                	ret
    return -1;
    4808:	597d                	li	s2,-1
    480a:	bfcd                	j	47fc <stat+0x36>

000000000000480c <atoi>:

int
atoi(const char *s)
{
    480c:	1141                	addi	sp,sp,-16
    480e:	e422                	sd	s0,8(sp)
    4810:	0800                	addi	s0,sp,16
  int n;
  int neg = 1;
  if (*s == '-') {
    4812:	00054703          	lbu	a4,0(a0)
    4816:	02d00793          	li	a5,45
  int neg = 1;
    481a:	4585                	li	a1,1
  if (*s == '-') {
    481c:	04f70363          	beq	a4,a5,4862 <atoi+0x56>
    s++;
    neg = -1;
  }
  n = 0;
  while('0' <= *s && *s <= '9')
    4820:	00054703          	lbu	a4,0(a0)
    4824:	fd07079b          	addiw	a5,a4,-48
    4828:	0ff7f793          	zext.b	a5,a5
    482c:	46a5                	li	a3,9
    482e:	02f6ed63          	bltu	a3,a5,4868 <atoi+0x5c>
  n = 0;
    4832:	4681                	li	a3,0
  while('0' <= *s && *s <= '9')
    4834:	4625                	li	a2,9
    n = n*10 + *s++ - '0';
    4836:	0505                	addi	a0,a0,1
    4838:	0026979b          	slliw	a5,a3,0x2
    483c:	9fb5                	addw	a5,a5,a3
    483e:	0017979b          	slliw	a5,a5,0x1
    4842:	9fb9                	addw	a5,a5,a4
    4844:	fd07869b          	addiw	a3,a5,-48
  while('0' <= *s && *s <= '9')
    4848:	00054703          	lbu	a4,0(a0)
    484c:	fd07079b          	addiw	a5,a4,-48
    4850:	0ff7f793          	zext.b	a5,a5
    4854:	fef671e3          	bgeu	a2,a5,4836 <atoi+0x2a>
  return n * neg;
}
    4858:	02d5853b          	mulw	a0,a1,a3
    485c:	6422                	ld	s0,8(sp)
    485e:	0141                	addi	sp,sp,16
    4860:	8082                	ret
    s++;
    4862:	0505                	addi	a0,a0,1
    neg = -1;
    4864:	55fd                	li	a1,-1
    4866:	bf6d                	j	4820 <atoi+0x14>
  n = 0;
    4868:	4681                	li	a3,0
    486a:	b7fd                	j	4858 <atoi+0x4c>

000000000000486c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    486c:	1141                	addi	sp,sp,-16
    486e:	e422                	sd	s0,8(sp)
    4870:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    4872:	02b57463          	bgeu	a0,a1,489a <memmove+0x2e>
    while(n-- > 0)
    4876:	00c05f63          	blez	a2,4894 <memmove+0x28>
    487a:	1602                	slli	a2,a2,0x20
    487c:	9201                	srli	a2,a2,0x20
    487e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
    4882:	872a                	mv	a4,a0
      *dst++ = *src++;
    4884:	0585                	addi	a1,a1,1
    4886:	0705                	addi	a4,a4,1
    4888:	fff5c683          	lbu	a3,-1(a1)
    488c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    4890:	fef71ae3          	bne	a4,a5,4884 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    4894:	6422                	ld	s0,8(sp)
    4896:	0141                	addi	sp,sp,16
    4898:	8082                	ret
    dst += n;
    489a:	00c50733          	add	a4,a0,a2
    src += n;
    489e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    48a0:	fec05ae3          	blez	a2,4894 <memmove+0x28>
    48a4:	fff6079b          	addiw	a5,a2,-1
    48a8:	1782                	slli	a5,a5,0x20
    48aa:	9381                	srli	a5,a5,0x20
    48ac:	fff7c793          	not	a5,a5
    48b0:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    48b2:	15fd                	addi	a1,a1,-1
    48b4:	177d                	addi	a4,a4,-1
    48b6:	0005c683          	lbu	a3,0(a1)
    48ba:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    48be:	fee79ae3          	bne	a5,a4,48b2 <memmove+0x46>
    48c2:	bfc9                	j	4894 <memmove+0x28>

00000000000048c4 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    48c4:	1141                	addi	sp,sp,-16
    48c6:	e422                	sd	s0,8(sp)
    48c8:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    48ca:	ca05                	beqz	a2,48fa <memcmp+0x36>
    48cc:	fff6069b          	addiw	a3,a2,-1
    48d0:	1682                	slli	a3,a3,0x20
    48d2:	9281                	srli	a3,a3,0x20
    48d4:	0685                	addi	a3,a3,1
    48d6:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    48d8:	00054783          	lbu	a5,0(a0)
    48dc:	0005c703          	lbu	a4,0(a1)
    48e0:	00e79863          	bne	a5,a4,48f0 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
    48e4:	0505                	addi	a0,a0,1
    p2++;
    48e6:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    48e8:	fed518e3          	bne	a0,a3,48d8 <memcmp+0x14>
  }
  return 0;
    48ec:	4501                	li	a0,0
    48ee:	a019                	j	48f4 <memcmp+0x30>
      return *p1 - *p2;
    48f0:	40e7853b          	subw	a0,a5,a4
}
    48f4:	6422                	ld	s0,8(sp)
    48f6:	0141                	addi	sp,sp,16
    48f8:	8082                	ret
  return 0;
    48fa:	4501                	li	a0,0
    48fc:	bfe5                	j	48f4 <memcmp+0x30>

00000000000048fe <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    48fe:	1141                	addi	sp,sp,-16
    4900:	e406                	sd	ra,8(sp)
    4902:	e022                	sd	s0,0(sp)
    4904:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    4906:	00000097          	auipc	ra,0x0
    490a:	f66080e7          	jalr	-154(ra) # 486c <memmove>
}
    490e:	60a2                	ld	ra,8(sp)
    4910:	6402                	ld	s0,0(sp)
    4912:	0141                	addi	sp,sp,16
    4914:	8082                	ret

0000000000004916 <fork>:
# generated by usys.pl - do not edit
#include "kernel/include/sysnum.h"
.global fork
fork:
 li a7, SYS_fork
    4916:	4885                	li	a7,1
 ecall
    4918:	00000073          	ecall
 ret
    491c:	8082                	ret

000000000000491e <exit>:
.global exit
exit:
 li a7, SYS_exit
    491e:	4889                	li	a7,2
 ecall
    4920:	00000073          	ecall
 ret
    4924:	8082                	ret

0000000000004926 <wait>:
.global wait
wait:
 li a7, SYS_wait
    4926:	488d                	li	a7,3
 ecall
    4928:	00000073          	ecall
 ret
    492c:	8082                	ret

000000000000492e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    492e:	4891                	li	a7,4
 ecall
    4930:	00000073          	ecall
 ret
    4934:	8082                	ret

0000000000004936 <read>:
.global read
read:
 li a7, SYS_read
    4936:	4895                	li	a7,5
 ecall
    4938:	00000073          	ecall
 ret
    493c:	8082                	ret

000000000000493e <write>:
.global write
write:
 li a7, SYS_write
    493e:	48c1                	li	a7,16
 ecall
    4940:	00000073          	ecall
 ret
    4944:	8082                	ret

0000000000004946 <close>:
.global close
close:
 li a7, SYS_close
    4946:	48d5                	li	a7,21
 ecall
    4948:	00000073          	ecall
 ret
    494c:	8082                	ret

000000000000494e <kill>:
.global kill
kill:
 li a7, SYS_kill
    494e:	4899                	li	a7,6
 ecall
    4950:	00000073          	ecall
 ret
    4954:	8082                	ret

0000000000004956 <exec>:
.global exec
exec:
 li a7, SYS_exec
    4956:	489d                	li	a7,7
 ecall
    4958:	00000073          	ecall
 ret
    495c:	8082                	ret

000000000000495e <open>:
.global open
open:
 li a7, SYS_open
    495e:	48bd                	li	a7,15
 ecall
    4960:	00000073          	ecall
 ret
    4964:	8082                	ret

0000000000004966 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    4966:	48a1                	li	a7,8
 ecall
    4968:	00000073          	ecall
 ret
    496c:	8082                	ret

000000000000496e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    496e:	48d1                	li	a7,20
 ecall
    4970:	00000073          	ecall
 ret
    4974:	8082                	ret

0000000000004976 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    4976:	48a5                	li	a7,9
 ecall
    4978:	00000073          	ecall
 ret
    497c:	8082                	ret

000000000000497e <dup>:
.global dup
dup:
 li a7, SYS_dup
    497e:	48a9                	li	a7,10
 ecall
    4980:	00000073          	ecall
 ret
    4984:	8082                	ret

0000000000004986 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    4986:	48ad                	li	a7,11
 ecall
    4988:	00000073          	ecall
 ret
    498c:	8082                	ret

000000000000498e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    498e:	48b1                	li	a7,12
 ecall
    4990:	00000073          	ecall
 ret
    4994:	8082                	ret

0000000000004996 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    4996:	48b5                	li	a7,13
 ecall
    4998:	00000073          	ecall
 ret
    499c:	8082                	ret

000000000000499e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    499e:	48b9                	li	a7,14
 ecall
    49a0:	00000073          	ecall
 ret
    49a4:	8082                	ret

00000000000049a6 <test_proc>:
.global test_proc
test_proc:
 li a7, SYS_test_proc
    49a6:	48d9                	li	a7,22
 ecall
    49a8:	00000073          	ecall
 ret
    49ac:	8082                	ret

00000000000049ae <dev>:
.global dev
dev:
 li a7, SYS_dev
    49ae:	48dd                	li	a7,23
 ecall
    49b0:	00000073          	ecall
 ret
    49b4:	8082                	ret

00000000000049b6 <readdir>:
.global readdir
readdir:
 li a7, SYS_readdir
    49b6:	48e1                	li	a7,24
 ecall
    49b8:	00000073          	ecall
 ret
    49bc:	8082                	ret

00000000000049be <getcwd>:
.global getcwd
getcwd:
 li a7, SYS_getcwd
    49be:	48e5                	li	a7,25
 ecall
    49c0:	00000073          	ecall
 ret
    49c4:	8082                	ret

00000000000049c6 <remove>:
.global remove
remove:
 li a7, SYS_remove
    49c6:	48c5                	li	a7,17
 ecall
    49c8:	00000073          	ecall
 ret
    49cc:	8082                	ret

00000000000049ce <trace>:
.global trace
trace:
 li a7, SYS_trace
    49ce:	48c9                	li	a7,18
 ecall
    49d0:	00000073          	ecall
 ret
    49d4:	8082                	ret

00000000000049d6 <sysinfo>:
.global sysinfo
sysinfo:
 li a7, SYS_sysinfo
    49d6:	48cd                	li	a7,19
 ecall
    49d8:	00000073          	ecall
 ret
    49dc:	8082                	ret

00000000000049de <rename>:
.global rename
rename:
 li a7, SYS_rename
    49de:	48e9                	li	a7,26
 ecall
    49e0:	00000073          	ecall
 ret
    49e4:	8082                	ret

00000000000049e6 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    49e6:	1101                	addi	sp,sp,-32
    49e8:	ec06                	sd	ra,24(sp)
    49ea:	e822                	sd	s0,16(sp)
    49ec:	1000                	addi	s0,sp,32
    49ee:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    49f2:	4605                	li	a2,1
    49f4:	fef40593          	addi	a1,s0,-17
    49f8:	00000097          	auipc	ra,0x0
    49fc:	f46080e7          	jalr	-186(ra) # 493e <write>
}
    4a00:	60e2                	ld	ra,24(sp)
    4a02:	6442                	ld	s0,16(sp)
    4a04:	6105                	addi	sp,sp,32
    4a06:	8082                	ret

0000000000004a08 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    4a08:	7139                	addi	sp,sp,-64
    4a0a:	fc06                	sd	ra,56(sp)
    4a0c:	f822                	sd	s0,48(sp)
    4a0e:	f426                	sd	s1,40(sp)
    4a10:	0080                	addi	s0,sp,64
    4a12:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    4a14:	c299                	beqz	a3,4a1a <printint+0x12>
    4a16:	0805cb63          	bltz	a1,4aac <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    4a1a:	2581                	sext.w	a1,a1
  neg = 0;
    4a1c:	4881                	li	a7,0
    4a1e:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    4a22:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    4a24:	2601                	sext.w	a2,a2
    4a26:	00002517          	auipc	a0,0x2
    4a2a:	62250513          	addi	a0,a0,1570 # 7048 <digits>
    4a2e:	883a                	mv	a6,a4
    4a30:	2705                	addiw	a4,a4,1
    4a32:	02c5f7bb          	remuw	a5,a1,a2
    4a36:	1782                	slli	a5,a5,0x20
    4a38:	9381                	srli	a5,a5,0x20
    4a3a:	97aa                	add	a5,a5,a0
    4a3c:	0007c783          	lbu	a5,0(a5)
    4a40:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    4a44:	0005879b          	sext.w	a5,a1
    4a48:	02c5d5bb          	divuw	a1,a1,a2
    4a4c:	0685                	addi	a3,a3,1
    4a4e:	fec7f0e3          	bgeu	a5,a2,4a2e <printint+0x26>
  if(neg)
    4a52:	00088c63          	beqz	a7,4a6a <printint+0x62>
    buf[i++] = '-';
    4a56:	fd070793          	addi	a5,a4,-48
    4a5a:	00878733          	add	a4,a5,s0
    4a5e:	02d00793          	li	a5,45
    4a62:	fef70823          	sb	a5,-16(a4)
    4a66:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    4a6a:	02e05c63          	blez	a4,4aa2 <printint+0x9a>
    4a6e:	f04a                	sd	s2,32(sp)
    4a70:	ec4e                	sd	s3,24(sp)
    4a72:	fc040793          	addi	a5,s0,-64
    4a76:	00e78933          	add	s2,a5,a4
    4a7a:	fff78993          	addi	s3,a5,-1
    4a7e:	99ba                	add	s3,s3,a4
    4a80:	377d                	addiw	a4,a4,-1
    4a82:	1702                	slli	a4,a4,0x20
    4a84:	9301                	srli	a4,a4,0x20
    4a86:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    4a8a:	fff94583          	lbu	a1,-1(s2)
    4a8e:	8526                	mv	a0,s1
    4a90:	00000097          	auipc	ra,0x0
    4a94:	f56080e7          	jalr	-170(ra) # 49e6 <putc>
  while(--i >= 0)
    4a98:	197d                	addi	s2,s2,-1
    4a9a:	ff3918e3          	bne	s2,s3,4a8a <printint+0x82>
    4a9e:	7902                	ld	s2,32(sp)
    4aa0:	69e2                	ld	s3,24(sp)
}
    4aa2:	70e2                	ld	ra,56(sp)
    4aa4:	7442                	ld	s0,48(sp)
    4aa6:	74a2                	ld	s1,40(sp)
    4aa8:	6121                	addi	sp,sp,64
    4aaa:	8082                	ret
    x = -xx;
    4aac:	40b005bb          	negw	a1,a1
    neg = 1;
    4ab0:	4885                	li	a7,1
    x = -xx;
    4ab2:	b7b5                	j	4a1e <printint+0x16>

0000000000004ab4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    4ab4:	715d                	addi	sp,sp,-80
    4ab6:	e486                	sd	ra,72(sp)
    4ab8:	e0a2                	sd	s0,64(sp)
    4aba:	f84a                	sd	s2,48(sp)
    4abc:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    4abe:	0005c903          	lbu	s2,0(a1)
    4ac2:	1a090a63          	beqz	s2,4c76 <vprintf+0x1c2>
    4ac6:	fc26                	sd	s1,56(sp)
    4ac8:	f44e                	sd	s3,40(sp)
    4aca:	f052                	sd	s4,32(sp)
    4acc:	ec56                	sd	s5,24(sp)
    4ace:	e85a                	sd	s6,16(sp)
    4ad0:	e45e                	sd	s7,8(sp)
    4ad2:	8aaa                	mv	s5,a0
    4ad4:	8bb2                	mv	s7,a2
    4ad6:	00158493          	addi	s1,a1,1
  state = 0;
    4ada:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    4adc:	02500a13          	li	s4,37
    4ae0:	4b55                	li	s6,21
    4ae2:	a839                	j	4b00 <vprintf+0x4c>
        putc(fd, c);
    4ae4:	85ca                	mv	a1,s2
    4ae6:	8556                	mv	a0,s5
    4ae8:	00000097          	auipc	ra,0x0
    4aec:	efe080e7          	jalr	-258(ra) # 49e6 <putc>
    4af0:	a019                	j	4af6 <vprintf+0x42>
    } else if(state == '%'){
    4af2:	01498d63          	beq	s3,s4,4b0c <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
    4af6:	0485                	addi	s1,s1,1
    4af8:	fff4c903          	lbu	s2,-1(s1)
    4afc:	16090763          	beqz	s2,4c6a <vprintf+0x1b6>
    if(state == 0){
    4b00:	fe0999e3          	bnez	s3,4af2 <vprintf+0x3e>
      if(c == '%'){
    4b04:	ff4910e3          	bne	s2,s4,4ae4 <vprintf+0x30>
        state = '%';
    4b08:	89d2                	mv	s3,s4
    4b0a:	b7f5                	j	4af6 <vprintf+0x42>
      if(c == 'd'){
    4b0c:	13490463          	beq	s2,s4,4c34 <vprintf+0x180>
    4b10:	f9d9079b          	addiw	a5,s2,-99
    4b14:	0ff7f793          	zext.b	a5,a5
    4b18:	12fb6763          	bltu	s6,a5,4c46 <vprintf+0x192>
    4b1c:	f9d9079b          	addiw	a5,s2,-99
    4b20:	0ff7f713          	zext.b	a4,a5
    4b24:	12eb6163          	bltu	s6,a4,4c46 <vprintf+0x192>
    4b28:	00271793          	slli	a5,a4,0x2
    4b2c:	00002717          	auipc	a4,0x2
    4b30:	4c470713          	addi	a4,a4,1220 # 6ff0 <malloc+0x228a>
    4b34:	97ba                	add	a5,a5,a4
    4b36:	439c                	lw	a5,0(a5)
    4b38:	97ba                	add	a5,a5,a4
    4b3a:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
    4b3c:	008b8913          	addi	s2,s7,8
    4b40:	4685                	li	a3,1
    4b42:	4629                	li	a2,10
    4b44:	000ba583          	lw	a1,0(s7)
    4b48:	8556                	mv	a0,s5
    4b4a:	00000097          	auipc	ra,0x0
    4b4e:	ebe080e7          	jalr	-322(ra) # 4a08 <printint>
    4b52:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
    4b54:	4981                	li	s3,0
    4b56:	b745                	j	4af6 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
    4b58:	008b8913          	addi	s2,s7,8
    4b5c:	4681                	li	a3,0
    4b5e:	4629                	li	a2,10
    4b60:	000ba583          	lw	a1,0(s7)
    4b64:	8556                	mv	a0,s5
    4b66:	00000097          	auipc	ra,0x0
    4b6a:	ea2080e7          	jalr	-350(ra) # 4a08 <printint>
    4b6e:	8bca                	mv	s7,s2
      state = 0;
    4b70:	4981                	li	s3,0
    4b72:	b751                	j	4af6 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
    4b74:	008b8913          	addi	s2,s7,8
    4b78:	4681                	li	a3,0
    4b7a:	4641                	li	a2,16
    4b7c:	000ba583          	lw	a1,0(s7)
    4b80:	8556                	mv	a0,s5
    4b82:	00000097          	auipc	ra,0x0
    4b86:	e86080e7          	jalr	-378(ra) # 4a08 <printint>
    4b8a:	8bca                	mv	s7,s2
      state = 0;
    4b8c:	4981                	li	s3,0
    4b8e:	b7a5                	j	4af6 <vprintf+0x42>
    4b90:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
    4b92:	008b8c13          	addi	s8,s7,8
    4b96:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
    4b9a:	03000593          	li	a1,48
    4b9e:	8556                	mv	a0,s5
    4ba0:	00000097          	auipc	ra,0x0
    4ba4:	e46080e7          	jalr	-442(ra) # 49e6 <putc>
  putc(fd, 'x');
    4ba8:	07800593          	li	a1,120
    4bac:	8556                	mv	a0,s5
    4bae:	00000097          	auipc	ra,0x0
    4bb2:	e38080e7          	jalr	-456(ra) # 49e6 <putc>
    4bb6:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    4bb8:	00002b97          	auipc	s7,0x2
    4bbc:	490b8b93          	addi	s7,s7,1168 # 7048 <digits>
    4bc0:	03c9d793          	srli	a5,s3,0x3c
    4bc4:	97de                	add	a5,a5,s7
    4bc6:	0007c583          	lbu	a1,0(a5)
    4bca:	8556                	mv	a0,s5
    4bcc:	00000097          	auipc	ra,0x0
    4bd0:	e1a080e7          	jalr	-486(ra) # 49e6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    4bd4:	0992                	slli	s3,s3,0x4
    4bd6:	397d                	addiw	s2,s2,-1
    4bd8:	fe0914e3          	bnez	s2,4bc0 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
    4bdc:	8be2                	mv	s7,s8
      state = 0;
    4bde:	4981                	li	s3,0
    4be0:	6c02                	ld	s8,0(sp)
    4be2:	bf11                	j	4af6 <vprintf+0x42>
        s = va_arg(ap, char*);
    4be4:	008b8993          	addi	s3,s7,8
    4be8:	000bb903          	ld	s2,0(s7)
        if(s == 0)
    4bec:	02090163          	beqz	s2,4c0e <vprintf+0x15a>
        while(*s != 0){
    4bf0:	00094583          	lbu	a1,0(s2)
    4bf4:	c9a5                	beqz	a1,4c64 <vprintf+0x1b0>
          putc(fd, *s);
    4bf6:	8556                	mv	a0,s5
    4bf8:	00000097          	auipc	ra,0x0
    4bfc:	dee080e7          	jalr	-530(ra) # 49e6 <putc>
          s++;
    4c00:	0905                	addi	s2,s2,1
        while(*s != 0){
    4c02:	00094583          	lbu	a1,0(s2)
    4c06:	f9e5                	bnez	a1,4bf6 <vprintf+0x142>
        s = va_arg(ap, char*);
    4c08:	8bce                	mv	s7,s3
      state = 0;
    4c0a:	4981                	li	s3,0
    4c0c:	b5ed                	j	4af6 <vprintf+0x42>
          s = "(null)";
    4c0e:	00002917          	auipc	s2,0x2
    4c12:	07a90913          	addi	s2,s2,122 # 6c88 <malloc+0x1f22>
        while(*s != 0){
    4c16:	02800593          	li	a1,40
    4c1a:	bff1                	j	4bf6 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
    4c1c:	008b8913          	addi	s2,s7,8
    4c20:	000bc583          	lbu	a1,0(s7)
    4c24:	8556                	mv	a0,s5
    4c26:	00000097          	auipc	ra,0x0
    4c2a:	dc0080e7          	jalr	-576(ra) # 49e6 <putc>
    4c2e:	8bca                	mv	s7,s2
      state = 0;
    4c30:	4981                	li	s3,0
    4c32:	b5d1                	j	4af6 <vprintf+0x42>
        putc(fd, c);
    4c34:	02500593          	li	a1,37
    4c38:	8556                	mv	a0,s5
    4c3a:	00000097          	auipc	ra,0x0
    4c3e:	dac080e7          	jalr	-596(ra) # 49e6 <putc>
      state = 0;
    4c42:	4981                	li	s3,0
    4c44:	bd4d                	j	4af6 <vprintf+0x42>
        putc(fd, '%');
    4c46:	02500593          	li	a1,37
    4c4a:	8556                	mv	a0,s5
    4c4c:	00000097          	auipc	ra,0x0
    4c50:	d9a080e7          	jalr	-614(ra) # 49e6 <putc>
        putc(fd, c);
    4c54:	85ca                	mv	a1,s2
    4c56:	8556                	mv	a0,s5
    4c58:	00000097          	auipc	ra,0x0
    4c5c:	d8e080e7          	jalr	-626(ra) # 49e6 <putc>
      state = 0;
    4c60:	4981                	li	s3,0
    4c62:	bd51                	j	4af6 <vprintf+0x42>
        s = va_arg(ap, char*);
    4c64:	8bce                	mv	s7,s3
      state = 0;
    4c66:	4981                	li	s3,0
    4c68:	b579                	j	4af6 <vprintf+0x42>
    4c6a:	74e2                	ld	s1,56(sp)
    4c6c:	79a2                	ld	s3,40(sp)
    4c6e:	7a02                	ld	s4,32(sp)
    4c70:	6ae2                	ld	s5,24(sp)
    4c72:	6b42                	ld	s6,16(sp)
    4c74:	6ba2                	ld	s7,8(sp)
    }
  }
}
    4c76:	60a6                	ld	ra,72(sp)
    4c78:	6406                	ld	s0,64(sp)
    4c7a:	7942                	ld	s2,48(sp)
    4c7c:	6161                	addi	sp,sp,80
    4c7e:	8082                	ret

0000000000004c80 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    4c80:	715d                	addi	sp,sp,-80
    4c82:	ec06                	sd	ra,24(sp)
    4c84:	e822                	sd	s0,16(sp)
    4c86:	1000                	addi	s0,sp,32
    4c88:	e010                	sd	a2,0(s0)
    4c8a:	e414                	sd	a3,8(s0)
    4c8c:	e818                	sd	a4,16(s0)
    4c8e:	ec1c                	sd	a5,24(s0)
    4c90:	03043023          	sd	a6,32(s0)
    4c94:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    4c98:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    4c9c:	8622                	mv	a2,s0
    4c9e:	00000097          	auipc	ra,0x0
    4ca2:	e16080e7          	jalr	-490(ra) # 4ab4 <vprintf>
}
    4ca6:	60e2                	ld	ra,24(sp)
    4ca8:	6442                	ld	s0,16(sp)
    4caa:	6161                	addi	sp,sp,80
    4cac:	8082                	ret

0000000000004cae <printf>:

void
printf(const char *fmt, ...)
{
    4cae:	711d                	addi	sp,sp,-96
    4cb0:	ec06                	sd	ra,24(sp)
    4cb2:	e822                	sd	s0,16(sp)
    4cb4:	1000                	addi	s0,sp,32
    4cb6:	e40c                	sd	a1,8(s0)
    4cb8:	e810                	sd	a2,16(s0)
    4cba:	ec14                	sd	a3,24(s0)
    4cbc:	f018                	sd	a4,32(s0)
    4cbe:	f41c                	sd	a5,40(s0)
    4cc0:	03043823          	sd	a6,48(s0)
    4cc4:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    4cc8:	00840613          	addi	a2,s0,8
    4ccc:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    4cd0:	85aa                	mv	a1,a0
    4cd2:	4505                	li	a0,1
    4cd4:	00000097          	auipc	ra,0x0
    4cd8:	de0080e7          	jalr	-544(ra) # 4ab4 <vprintf>
}
    4cdc:	60e2                	ld	ra,24(sp)
    4cde:	6442                	ld	s0,16(sp)
    4ce0:	6125                	addi	sp,sp,96
    4ce2:	8082                	ret

0000000000004ce4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    4ce4:	1141                	addi	sp,sp,-16
    4ce6:	e422                	sd	s0,8(sp)
    4ce8:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    4cea:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    4cee:	00002797          	auipc	a5,0x2
    4cf2:	3827b783          	ld	a5,898(a5) # 7070 <freep>
    4cf6:	a02d                	j	4d20 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    4cf8:	4618                	lw	a4,8(a2)
    4cfa:	9f2d                	addw	a4,a4,a1
    4cfc:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    4d00:	6398                	ld	a4,0(a5)
    4d02:	6310                	ld	a2,0(a4)
    4d04:	a83d                	j	4d42 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    4d06:	ff852703          	lw	a4,-8(a0)
    4d0a:	9f31                	addw	a4,a4,a2
    4d0c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    4d0e:	ff053683          	ld	a3,-16(a0)
    4d12:	a091                	j	4d56 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    4d14:	6398                	ld	a4,0(a5)
    4d16:	00e7e463          	bltu	a5,a4,4d1e <free+0x3a>
    4d1a:	00e6ea63          	bltu	a3,a4,4d2e <free+0x4a>
{
    4d1e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    4d20:	fed7fae3          	bgeu	a5,a3,4d14 <free+0x30>
    4d24:	6398                	ld	a4,0(a5)
    4d26:	00e6e463          	bltu	a3,a4,4d2e <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    4d2a:	fee7eae3          	bltu	a5,a4,4d1e <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
    4d2e:	ff852583          	lw	a1,-8(a0)
    4d32:	6390                	ld	a2,0(a5)
    4d34:	02059813          	slli	a6,a1,0x20
    4d38:	01c85713          	srli	a4,a6,0x1c
    4d3c:	9736                	add	a4,a4,a3
    4d3e:	fae60de3          	beq	a2,a4,4cf8 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
    4d42:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    4d46:	4790                	lw	a2,8(a5)
    4d48:	02061593          	slli	a1,a2,0x20
    4d4c:	01c5d713          	srli	a4,a1,0x1c
    4d50:	973e                	add	a4,a4,a5
    4d52:	fae68ae3          	beq	a3,a4,4d06 <free+0x22>
    p->s.ptr = bp->s.ptr;
    4d56:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    4d58:	00002717          	auipc	a4,0x2
    4d5c:	30f73c23          	sd	a5,792(a4) # 7070 <freep>
}
    4d60:	6422                	ld	s0,8(sp)
    4d62:	0141                	addi	sp,sp,16
    4d64:	8082                	ret

0000000000004d66 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    4d66:	7139                	addi	sp,sp,-64
    4d68:	fc06                	sd	ra,56(sp)
    4d6a:	f822                	sd	s0,48(sp)
    4d6c:	f426                	sd	s1,40(sp)
    4d6e:	ec4e                	sd	s3,24(sp)
    4d70:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    4d72:	02051493          	slli	s1,a0,0x20
    4d76:	9081                	srli	s1,s1,0x20
    4d78:	04bd                	addi	s1,s1,15
    4d7a:	8091                	srli	s1,s1,0x4
    4d7c:	0014899b          	addiw	s3,s1,1
    4d80:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    4d82:	00002517          	auipc	a0,0x2
    4d86:	2ee53503          	ld	a0,750(a0) # 7070 <freep>
    4d8a:	c915                	beqz	a0,4dbe <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    4d8c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    4d8e:	4798                	lw	a4,8(a5)
    4d90:	08977e63          	bgeu	a4,s1,4e2c <malloc+0xc6>
    4d94:	f04a                	sd	s2,32(sp)
    4d96:	e852                	sd	s4,16(sp)
    4d98:	e456                	sd	s5,8(sp)
    4d9a:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
    4d9c:	8a4e                	mv	s4,s3
    4d9e:	0009871b          	sext.w	a4,s3
    4da2:	6685                	lui	a3,0x1
    4da4:	00d77363          	bgeu	a4,a3,4daa <malloc+0x44>
    4da8:	6a05                	lui	s4,0x1
    4daa:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    4dae:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    4db2:	00002917          	auipc	s2,0x2
    4db6:	2be90913          	addi	s2,s2,702 # 7070 <freep>
  if(p == (char*)-1)
    4dba:	5afd                	li	s5,-1
    4dbc:	a091                	j	4e00 <malloc+0x9a>
    4dbe:	f04a                	sd	s2,32(sp)
    4dc0:	e852                	sd	s4,16(sp)
    4dc2:	e456                	sd	s5,8(sp)
    4dc4:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
    4dc6:	00007797          	auipc	a5,0x7
    4dca:	2ca78793          	addi	a5,a5,714 # c090 <base>
    4dce:	00002717          	auipc	a4,0x2
    4dd2:	2af73123          	sd	a5,674(a4) # 7070 <freep>
    4dd6:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    4dd8:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    4ddc:	b7c1                	j	4d9c <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
    4dde:	6398                	ld	a4,0(a5)
    4de0:	e118                	sd	a4,0(a0)
    4de2:	a08d                	j	4e44 <malloc+0xde>
  hp->s.size = nu;
    4de4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    4de8:	0541                	addi	a0,a0,16
    4dea:	00000097          	auipc	ra,0x0
    4dee:	efa080e7          	jalr	-262(ra) # 4ce4 <free>
  return freep;
    4df2:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    4df6:	c13d                	beqz	a0,4e5c <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    4df8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    4dfa:	4798                	lw	a4,8(a5)
    4dfc:	02977463          	bgeu	a4,s1,4e24 <malloc+0xbe>
    if(p == freep)
    4e00:	00093703          	ld	a4,0(s2)
    4e04:	853e                	mv	a0,a5
    4e06:	fef719e3          	bne	a4,a5,4df8 <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
    4e0a:	8552                	mv	a0,s4
    4e0c:	00000097          	auipc	ra,0x0
    4e10:	b82080e7          	jalr	-1150(ra) # 498e <sbrk>
  if(p == (char*)-1)
    4e14:	fd5518e3          	bne	a0,s5,4de4 <malloc+0x7e>
        return 0;
    4e18:	4501                	li	a0,0
    4e1a:	7902                	ld	s2,32(sp)
    4e1c:	6a42                	ld	s4,16(sp)
    4e1e:	6aa2                	ld	s5,8(sp)
    4e20:	6b02                	ld	s6,0(sp)
    4e22:	a03d                	j	4e50 <malloc+0xea>
    4e24:	7902                	ld	s2,32(sp)
    4e26:	6a42                	ld	s4,16(sp)
    4e28:	6aa2                	ld	s5,8(sp)
    4e2a:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
    4e2c:	fae489e3          	beq	s1,a4,4dde <malloc+0x78>
        p->s.size -= nunits;
    4e30:	4137073b          	subw	a4,a4,s3
    4e34:	c798                	sw	a4,8(a5)
        p += p->s.size;
    4e36:	02071693          	slli	a3,a4,0x20
    4e3a:	01c6d713          	srli	a4,a3,0x1c
    4e3e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    4e40:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    4e44:	00002717          	auipc	a4,0x2
    4e48:	22a73623          	sd	a0,556(a4) # 7070 <freep>
      return (void*)(p + 1);
    4e4c:	01078513          	addi	a0,a5,16
  }
}
    4e50:	70e2                	ld	ra,56(sp)
    4e52:	7442                	ld	s0,48(sp)
    4e54:	74a2                	ld	s1,40(sp)
    4e56:	69e2                	ld	s3,24(sp)
    4e58:	6121                	addi	sp,sp,64
    4e5a:	8082                	ret
    4e5c:	7902                	ld	s2,32(sp)
    4e5e:	6a42                	ld	s4,16(sp)
    4e60:	6aa2                	ld	s5,8(sp)
    4e62:	6b02                	ld	s6,0(sp)
    4e64:	b7f5                	j	4e50 <malloc+0xea>
