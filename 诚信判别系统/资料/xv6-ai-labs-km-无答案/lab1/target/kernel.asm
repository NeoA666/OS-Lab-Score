
target/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <_entry>:
    80200000:	00150293          	addi	t0,a0,1
    80200004:	02ba                	slli	t0,t0,0xe
    80200006:	0000b117          	auipc	sp,0xb
    8020000a:	ffa10113          	addi	sp,sp,-6 # 8020b000 <boot_stack>
    8020000e:	9116                	add	sp,sp,t0
    80200010:	1f7000ef          	jal	80200a06 <main>

0000000080200014 <loop>:
    80200014:	a001                	j	80200014 <loop>

0000000080200016 <printint>:
    }
}

static void
printint(int xx, int base, int sign)
{
    80200016:	7179                	addi	sp,sp,-48
    80200018:	f406                	sd	ra,40(sp)
    8020001a:	f022                	sd	s0,32(sp)
    8020001c:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    8020001e:	c219                	beqz	a2,80200024 <printint+0xe>
    80200020:	08054963          	bltz	a0,802000b2 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    80200024:	2501                	sext.w	a0,a0
    80200026:	4881                	li	a7,0
    80200028:	fd040693          	addi	a3,s0,-48

  i = 0;
    8020002c:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    8020002e:	2581                	sext.w	a1,a1
    80200030:	0000a617          	auipc	a2,0xa
    80200034:	d2060613          	addi	a2,a2,-736 # 80209d50 <digits>
    80200038:	883a                	mv	a6,a4
    8020003a:	2705                	addiw	a4,a4,1
    8020003c:	02b577bb          	remuw	a5,a0,a1
    80200040:	1782                	slli	a5,a5,0x20
    80200042:	9381                	srli	a5,a5,0x20
    80200044:	97b2                	add	a5,a5,a2
    80200046:	0007c783          	lbu	a5,0(a5)
    8020004a:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    8020004e:	0005079b          	sext.w	a5,a0
    80200052:	02b5553b          	divuw	a0,a0,a1
    80200056:	0685                	addi	a3,a3,1
    80200058:	feb7f0e3          	bgeu	a5,a1,80200038 <printint+0x22>

  if(sign)
    8020005c:	00088c63          	beqz	a7,80200074 <printint+0x5e>
    buf[i++] = '-';
    80200060:	fe070793          	addi	a5,a4,-32
    80200064:	00878733          	add	a4,a5,s0
    80200068:	02d00793          	li	a5,45
    8020006c:	fef70823          	sb	a5,-16(a4)
    80200070:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80200074:	02e05b63          	blez	a4,802000aa <printint+0x94>
    80200078:	ec26                	sd	s1,24(sp)
    8020007a:	e84a                	sd	s2,16(sp)
    8020007c:	fd040793          	addi	a5,s0,-48
    80200080:	00e784b3          	add	s1,a5,a4
    80200084:	fff78913          	addi	s2,a5,-1
    80200088:	993a                	add	s2,s2,a4
    8020008a:	377d                	addiw	a4,a4,-1
    8020008c:	1702                	slli	a4,a4,0x20
    8020008e:	9301                	srli	a4,a4,0x20
    80200090:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80200094:	fff4c503          	lbu	a0,-1(s1)
    80200098:	00007097          	auipc	ra,0x7
    8020009c:	e1e080e7          	jalr	-482(ra) # 80206eb6 <consputc>
  while(--i >= 0)
    802000a0:	14fd                	addi	s1,s1,-1
    802000a2:	ff2499e3          	bne	s1,s2,80200094 <printint+0x7e>
    802000a6:	64e2                	ld	s1,24(sp)
    802000a8:	6942                	ld	s2,16(sp)
}
    802000aa:	70a2                	ld	ra,40(sp)
    802000ac:	7402                	ld	s0,32(sp)
    802000ae:	6145                	addi	sp,sp,48
    802000b0:	8082                	ret
    x = -xx;
    802000b2:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    802000b6:	4885                	li	a7,1
    x = -xx;
    802000b8:	bf85                	j	80200028 <printint+0x12>

00000000802000ba <printstring>:
void printstring(const char* s) {
    802000ba:	1101                	addi	sp,sp,-32
    802000bc:	ec06                	sd	ra,24(sp)
    802000be:	e822                	sd	s0,16(sp)
    802000c0:	e426                	sd	s1,8(sp)
    802000c2:	1000                	addi	s0,sp,32
    802000c4:	84aa                	mv	s1,a0
    while (*s)
    802000c6:	00054503          	lbu	a0,0(a0)
    802000ca:	c909                	beqz	a0,802000dc <printstring+0x22>
        consputc(*s++);
    802000cc:	0485                	addi	s1,s1,1
    802000ce:	00007097          	auipc	ra,0x7
    802000d2:	de8080e7          	jalr	-536(ra) # 80206eb6 <consputc>
    while (*s)
    802000d6:	0004c503          	lbu	a0,0(s1)
    802000da:	f96d                	bnez	a0,802000cc <printstring+0x12>
}
    802000dc:	60e2                	ld	ra,24(sp)
    802000de:	6442                	ld	s0,16(sp)
    802000e0:	64a2                	ld	s1,8(sp)
    802000e2:	6105                	addi	sp,sp,32
    802000e4:	8082                	ret

00000000802000e6 <backtrace>:
  for(;;)
    ;
}

void backtrace()
{
    802000e6:	7179                	addi	sp,sp,-48
    802000e8:	f406                	sd	ra,40(sp)
    802000ea:	f022                	sd	s0,32(sp)
    802000ec:	ec26                	sd	s1,24(sp)
    802000ee:	e84a                	sd	s2,16(sp)
    802000f0:	1800                	addi	s0,sp,48

static inline uint64
r_fp()
{
  uint64 x;
  asm volatile("mv %0, s0" : "=r" (x) );
    802000f2:	8922                	mv	s2,s0
  uint64 *fp = (uint64 *)r_fp();
    802000f4:	84ca                	mv	s1,s2
  uint64 *bottom = (uint64 *)PGROUNDUP((uint64)fp);
    802000f6:	6785                	lui	a5,0x1
    802000f8:	17fd                	addi	a5,a5,-1 # fff <_entry-0x801ff001>
    802000fa:	993e                	add	s2,s2,a5
    802000fc:	77fd                	lui	a5,0xfffff
    802000fe:	00f97933          	and	s2,s2,a5
  printf("backtrace:\n");
    80200102:	00009517          	auipc	a0,0x9
    80200106:	efe50513          	addi	a0,a0,-258 # 80209000 <etext>
    8020010a:	00000097          	auipc	ra,0x0
    8020010e:	086080e7          	jalr	134(ra) # 80200190 <printf>
  while (fp < bottom) {
    80200112:	0324f463          	bgeu	s1,s2,8020013a <backtrace+0x54>
    80200116:	e44e                	sd	s3,8(sp)
    uint64 ra = *(fp - 1);
    printf("%p\n", ra - 4);
    80200118:	00009997          	auipc	s3,0x9
    8020011c:	ef898993          	addi	s3,s3,-264 # 80209010 <etext+0x10>
    80200120:	ff84b583          	ld	a1,-8(s1)
    80200124:	15f1                	addi	a1,a1,-4
    80200126:	854e                	mv	a0,s3
    80200128:	00000097          	auipc	ra,0x0
    8020012c:	068080e7          	jalr	104(ra) # 80200190 <printf>
    fp = (uint64 *)*(fp - 2);
    80200130:	ff04b483          	ld	s1,-16(s1)
  while (fp < bottom) {
    80200134:	ff24e6e3          	bltu	s1,s2,80200120 <backtrace+0x3a>
    80200138:	69a2                	ld	s3,8(sp)
  }
}
    8020013a:	70a2                	ld	ra,40(sp)
    8020013c:	7402                	ld	s0,32(sp)
    8020013e:	64e2                	ld	s1,24(sp)
    80200140:	6942                	ld	s2,16(sp)
    80200142:	6145                	addi	sp,sp,48
    80200144:	8082                	ret

0000000080200146 <panic>:
{
    80200146:	1101                	addi	sp,sp,-32
    80200148:	ec06                	sd	ra,24(sp)
    8020014a:	e822                	sd	s0,16(sp)
    8020014c:	e426                	sd	s1,8(sp)
    8020014e:	1000                	addi	s0,sp,32
    80200150:	84aa                	mv	s1,a0
  printf("panic: ");
    80200152:	00009517          	auipc	a0,0x9
    80200156:	ec650513          	addi	a0,a0,-314 # 80209018 <etext+0x18>
    8020015a:	00000097          	auipc	ra,0x0
    8020015e:	036080e7          	jalr	54(ra) # 80200190 <printf>
  printf(s);
    80200162:	8526                	mv	a0,s1
    80200164:	00000097          	auipc	ra,0x0
    80200168:	02c080e7          	jalr	44(ra) # 80200190 <printf>
  printf("\n");
    8020016c:	00009517          	auipc	a0,0x9
    80200170:	eb450513          	addi	a0,a0,-332 # 80209020 <etext+0x20>
    80200174:	00000097          	auipc	ra,0x0
    80200178:	01c080e7          	jalr	28(ra) # 80200190 <printf>
  backtrace();
    8020017c:	00000097          	auipc	ra,0x0
    80200180:	f6a080e7          	jalr	-150(ra) # 802000e6 <backtrace>
  panicked = 1; // freeze uart output from other CPUs
    80200184:	4785                	li	a5,1
    80200186:	00013717          	auipc	a4,0x13
    8020018a:	e8f72d23          	sw	a5,-358(a4) # 80213020 <panicked>
  for(;;)
    8020018e:	a001                	j	8020018e <panic+0x48>

0000000080200190 <printf>:
{
    80200190:	7131                	addi	sp,sp,-192
    80200192:	fc86                	sd	ra,120(sp)
    80200194:	f8a2                	sd	s0,112(sp)
    80200196:	e8d2                	sd	s4,80(sp)
    80200198:	f06a                	sd	s10,32(sp)
    8020019a:	0100                	addi	s0,sp,128
    8020019c:	8a2a                	mv	s4,a0
    8020019e:	e40c                	sd	a1,8(s0)
    802001a0:	e810                	sd	a2,16(s0)
    802001a2:	ec14                	sd	a3,24(s0)
    802001a4:	f018                	sd	a4,32(s0)
    802001a6:	f41c                	sd	a5,40(s0)
    802001a8:	03043823          	sd	a6,48(s0)
    802001ac:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    802001b0:	00013d17          	auipc	s10,0x13
    802001b4:	e68d2d03          	lw	s10,-408(s10) # 80213018 <pr+0x18>
  if(locking)
    802001b8:	040d1463          	bnez	s10,80200200 <printf+0x70>
  if (fmt == 0)
    802001bc:	040a0b63          	beqz	s4,80200212 <printf+0x82>
  va_start(ap, fmt);
    802001c0:	00840793          	addi	a5,s0,8
    802001c4:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    802001c8:	000a4503          	lbu	a0,0(s4)
    802001cc:	18050b63          	beqz	a0,80200362 <printf+0x1d2>
    802001d0:	f4a6                	sd	s1,104(sp)
    802001d2:	f0ca                	sd	s2,96(sp)
    802001d4:	ecce                	sd	s3,88(sp)
    802001d6:	e4d6                	sd	s5,72(sp)
    802001d8:	e0da                	sd	s6,64(sp)
    802001da:	fc5e                	sd	s7,56(sp)
    802001dc:	f862                	sd	s8,48(sp)
    802001de:	f466                	sd	s9,40(sp)
    802001e0:	ec6e                	sd	s11,24(sp)
    802001e2:	4981                	li	s3,0
    if(c != '%'){
    802001e4:	02500b13          	li	s6,37
    switch(c){
    802001e8:	07000b93          	li	s7,112
  consputc('x');
    802001ec:	4cc1                	li	s9,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    802001ee:	0000aa97          	auipc	s5,0xa
    802001f2:	b62a8a93          	addi	s5,s5,-1182 # 80209d50 <digits>
    switch(c){
    802001f6:	07300c13          	li	s8,115
    802001fa:	06400d93          	li	s11,100
    802001fe:	a0b1                	j	8020024a <printf+0xba>
    acquire(&pr.lock);
    80200200:	00013517          	auipc	a0,0x13
    80200204:	e0050513          	addi	a0,a0,-512 # 80213000 <pr>
    80200208:	00000097          	auipc	ra,0x0
    8020020c:	4e8080e7          	jalr	1256(ra) # 802006f0 <acquire>
    80200210:	b775                	j	802001bc <printf+0x2c>
    80200212:	f4a6                	sd	s1,104(sp)
    80200214:	f0ca                	sd	s2,96(sp)
    80200216:	ecce                	sd	s3,88(sp)
    80200218:	e4d6                	sd	s5,72(sp)
    8020021a:	e0da                	sd	s6,64(sp)
    8020021c:	fc5e                	sd	s7,56(sp)
    8020021e:	f862                	sd	s8,48(sp)
    80200220:	f466                	sd	s9,40(sp)
    80200222:	ec6e                	sd	s11,24(sp)
    panic("null fmt");
    80200224:	00009517          	auipc	a0,0x9
    80200228:	e0c50513          	addi	a0,a0,-500 # 80209030 <etext+0x30>
    8020022c:	00000097          	auipc	ra,0x0
    80200230:	f1a080e7          	jalr	-230(ra) # 80200146 <panic>
      consputc(c);
    80200234:	00007097          	auipc	ra,0x7
    80200238:	c82080e7          	jalr	-894(ra) # 80206eb6 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8020023c:	2985                	addiw	s3,s3,1
    8020023e:	013a07b3          	add	a5,s4,s3
    80200242:	0007c503          	lbu	a0,0(a5) # fffffffffffff000 <ebss_clear+0xffffffff7fdda000>
    80200246:	10050563          	beqz	a0,80200350 <printf+0x1c0>
    if(c != '%'){
    8020024a:	ff6515e3          	bne	a0,s6,80200234 <printf+0xa4>
    c = fmt[++i] & 0xff;
    8020024e:	2985                	addiw	s3,s3,1
    80200250:	013a07b3          	add	a5,s4,s3
    80200254:	0007c783          	lbu	a5,0(a5)
    80200258:	0007849b          	sext.w	s1,a5
    if(c == 0)
    8020025c:	10078b63          	beqz	a5,80200372 <printf+0x1e2>
    switch(c){
    80200260:	05778a63          	beq	a5,s7,802002b4 <printf+0x124>
    80200264:	02fbf663          	bgeu	s7,a5,80200290 <printf+0x100>
    80200268:	09878863          	beq	a5,s8,802002f8 <printf+0x168>
    8020026c:	07800713          	li	a4,120
    80200270:	0ce79563          	bne	a5,a4,8020033a <printf+0x1aa>
      printint(va_arg(ap, int), 16, 1);
    80200274:	f8843783          	ld	a5,-120(s0)
    80200278:	00878713          	addi	a4,a5,8
    8020027c:	f8e43423          	sd	a4,-120(s0)
    80200280:	4605                	li	a2,1
    80200282:	85e6                	mv	a1,s9
    80200284:	4388                	lw	a0,0(a5)
    80200286:	00000097          	auipc	ra,0x0
    8020028a:	d90080e7          	jalr	-624(ra) # 80200016 <printint>
      break;
    8020028e:	b77d                	j	8020023c <printf+0xac>
    switch(c){
    80200290:	09678f63          	beq	a5,s6,8020032e <printf+0x19e>
    80200294:	0bb79363          	bne	a5,s11,8020033a <printf+0x1aa>
      printint(va_arg(ap, int), 10, 1);
    80200298:	f8843783          	ld	a5,-120(s0)
    8020029c:	00878713          	addi	a4,a5,8
    802002a0:	f8e43423          	sd	a4,-120(s0)
    802002a4:	4605                	li	a2,1
    802002a6:	45a9                	li	a1,10
    802002a8:	4388                	lw	a0,0(a5)
    802002aa:	00000097          	auipc	ra,0x0
    802002ae:	d6c080e7          	jalr	-660(ra) # 80200016 <printint>
      break;
    802002b2:	b769                	j	8020023c <printf+0xac>
      printptr(va_arg(ap, uint64));
    802002b4:	f8843783          	ld	a5,-120(s0)
    802002b8:	00878713          	addi	a4,a5,8
    802002bc:	f8e43423          	sd	a4,-120(s0)
    802002c0:	0007b903          	ld	s2,0(a5)
  consputc('0');
    802002c4:	03000513          	li	a0,48
    802002c8:	00007097          	auipc	ra,0x7
    802002cc:	bee080e7          	jalr	-1042(ra) # 80206eb6 <consputc>
  consputc('x');
    802002d0:	07800513          	li	a0,120
    802002d4:	00007097          	auipc	ra,0x7
    802002d8:	be2080e7          	jalr	-1054(ra) # 80206eb6 <consputc>
    802002dc:	84e6                	mv	s1,s9
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    802002de:	03c95793          	srli	a5,s2,0x3c
    802002e2:	97d6                	add	a5,a5,s5
    802002e4:	0007c503          	lbu	a0,0(a5)
    802002e8:	00007097          	auipc	ra,0x7
    802002ec:	bce080e7          	jalr	-1074(ra) # 80206eb6 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    802002f0:	0912                	slli	s2,s2,0x4
    802002f2:	34fd                	addiw	s1,s1,-1
    802002f4:	f4ed                	bnez	s1,802002de <printf+0x14e>
    802002f6:	b799                	j	8020023c <printf+0xac>
      if((s = va_arg(ap, char*)) == 0)
    802002f8:	f8843783          	ld	a5,-120(s0)
    802002fc:	00878713          	addi	a4,a5,8
    80200300:	f8e43423          	sd	a4,-120(s0)
    80200304:	6384                	ld	s1,0(a5)
    80200306:	cc89                	beqz	s1,80200320 <printf+0x190>
      for(; *s; s++)
    80200308:	0004c503          	lbu	a0,0(s1)
    8020030c:	d905                	beqz	a0,8020023c <printf+0xac>
        consputc(*s);
    8020030e:	00007097          	auipc	ra,0x7
    80200312:	ba8080e7          	jalr	-1112(ra) # 80206eb6 <consputc>
      for(; *s; s++)
    80200316:	0485                	addi	s1,s1,1
    80200318:	0004c503          	lbu	a0,0(s1)
    8020031c:	f96d                	bnez	a0,8020030e <printf+0x17e>
    8020031e:	bf39                	j	8020023c <printf+0xac>
        s = "(null)";
    80200320:	00009497          	auipc	s1,0x9
    80200324:	d0848493          	addi	s1,s1,-760 # 80209028 <etext+0x28>
      for(; *s; s++)
    80200328:	02800513          	li	a0,40
    8020032c:	b7cd                	j	8020030e <printf+0x17e>
      consputc('%');
    8020032e:	855a                	mv	a0,s6
    80200330:	00007097          	auipc	ra,0x7
    80200334:	b86080e7          	jalr	-1146(ra) # 80206eb6 <consputc>
      break;
    80200338:	b711                	j	8020023c <printf+0xac>
      consputc('%');
    8020033a:	855a                	mv	a0,s6
    8020033c:	00007097          	auipc	ra,0x7
    80200340:	b7a080e7          	jalr	-1158(ra) # 80206eb6 <consputc>
      consputc(c);
    80200344:	8526                	mv	a0,s1
    80200346:	00007097          	auipc	ra,0x7
    8020034a:	b70080e7          	jalr	-1168(ra) # 80206eb6 <consputc>
      break;
    8020034e:	b5fd                	j	8020023c <printf+0xac>
    80200350:	74a6                	ld	s1,104(sp)
    80200352:	7906                	ld	s2,96(sp)
    80200354:	69e6                	ld	s3,88(sp)
    80200356:	6aa6                	ld	s5,72(sp)
    80200358:	6b06                	ld	s6,64(sp)
    8020035a:	7be2                	ld	s7,56(sp)
    8020035c:	7c42                	ld	s8,48(sp)
    8020035e:	7ca2                	ld	s9,40(sp)
    80200360:	6de2                	ld	s11,24(sp)
  if(locking)
    80200362:	020d1263          	bnez	s10,80200386 <printf+0x1f6>
}
    80200366:	70e6                	ld	ra,120(sp)
    80200368:	7446                	ld	s0,112(sp)
    8020036a:	6a46                	ld	s4,80(sp)
    8020036c:	7d02                	ld	s10,32(sp)
    8020036e:	6129                	addi	sp,sp,192
    80200370:	8082                	ret
    80200372:	74a6                	ld	s1,104(sp)
    80200374:	7906                	ld	s2,96(sp)
    80200376:	69e6                	ld	s3,88(sp)
    80200378:	6aa6                	ld	s5,72(sp)
    8020037a:	6b06                	ld	s6,64(sp)
    8020037c:	7be2                	ld	s7,56(sp)
    8020037e:	7c42                	ld	s8,48(sp)
    80200380:	7ca2                	ld	s9,40(sp)
    80200382:	6de2                	ld	s11,24(sp)
    80200384:	bff9                	j	80200362 <printf+0x1d2>
    release(&pr.lock);
    80200386:	00013517          	auipc	a0,0x13
    8020038a:	c7a50513          	addi	a0,a0,-902 # 80213000 <pr>
    8020038e:	00000097          	auipc	ra,0x0
    80200392:	3b6080e7          	jalr	950(ra) # 80200744 <release>
}
    80200396:	bfc1                	j	80200366 <printf+0x1d6>

0000000080200398 <printfinit>:

void
printfinit(void)
{
    80200398:	1101                	addi	sp,sp,-32
    8020039a:	ec06                	sd	ra,24(sp)
    8020039c:	e822                	sd	s0,16(sp)
    8020039e:	e426                	sd	s1,8(sp)
    802003a0:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    802003a2:	00013497          	auipc	s1,0x13
    802003a6:	c5e48493          	addi	s1,s1,-930 # 80213000 <pr>
    802003aa:	00009597          	auipc	a1,0x9
    802003ae:	c9658593          	addi	a1,a1,-874 # 80209040 <etext+0x40>
    802003b2:	8526                	mv	a0,s1
    802003b4:	00000097          	auipc	ra,0x0
    802003b8:	2f8080e7          	jalr	760(ra) # 802006ac <initlock>
  pr.locking = 1;   // changed, used to be 1
    802003bc:	4785                	li	a5,1
    802003be:	cc9c                	sw	a5,24(s1)
}
    802003c0:	60e2                	ld	ra,24(sp)
    802003c2:	6442                	ld	s0,16(sp)
    802003c4:	64a2                	ld	s1,8(sp)
    802003c6:	6105                	addi	sp,sp,32
    802003c8:	8082                	ret

00000000802003ca <print_logo>:

#ifdef QEMU
void print_logo() {
    802003ca:	1141                	addi	sp,sp,-16
    802003cc:	e406                	sd	ra,8(sp)
    802003ce:	e022                	sd	s0,0(sp)
    802003d0:	0800                	addi	s0,sp,16
    printf("  (`-.            (`-.                            .-')       ('-.    _   .-')\n");
    802003d2:	00009517          	auipc	a0,0x9
    802003d6:	c7650513          	addi	a0,a0,-906 # 80209048 <etext+0x48>
    802003da:	00000097          	auipc	ra,0x0
    802003de:	db6080e7          	jalr	-586(ra) # 80200190 <printf>
    printf(" ( OO ).        _(OO  )_                        .(  OO)    _(  OO)  ( '.( OO )_ \n");
    802003e2:	00009517          	auipc	a0,0x9
    802003e6:	cb650513          	addi	a0,a0,-842 # 80209098 <etext+0x98>
    802003ea:	00000097          	auipc	ra,0x0
    802003ee:	da6080e7          	jalr	-602(ra) # 80200190 <printf>
    printf("(_/.  \\_)-. ,--(_/   ,. \\  ,--.                (_)---\\_)  (,------.  ,--.   ,--.) ,--. ,--.  \n");
    802003f2:	00009517          	auipc	a0,0x9
    802003f6:	cfe50513          	addi	a0,a0,-770 # 802090f0 <etext+0xf0>
    802003fa:	00000097          	auipc	ra,0x0
    802003fe:	d96080e7          	jalr	-618(ra) # 80200190 <printf>
    printf(" \\  `.'  /  \\   \\   /(__/ /  .'       .-')     '  .-.  '   |  .---'  |   `.'   |  |  | |  |   \n");
    80200402:	00009517          	auipc	a0,0x9
    80200406:	d4e50513          	addi	a0,a0,-690 # 80209150 <etext+0x150>
    8020040a:	00000097          	auipc	ra,0x0
    8020040e:	d86080e7          	jalr	-634(ra) # 80200190 <printf>
    printf("  \\     /\\   \\   \\ /   / .  / -.    _(  OO)   ,|  | |  |   |  |      |         |  |  | | .-')\n");
    80200412:	00009517          	auipc	a0,0x9
    80200416:	d9e50513          	addi	a0,a0,-610 # 802091b0 <etext+0x1b0>
    8020041a:	00000097          	auipc	ra,0x0
    8020041e:	d76080e7          	jalr	-650(ra) # 80200190 <printf>
    printf("   \\   \\ |    \\   '   /, | .-.  '  (,------. (_|  | |  |  (|  '--.   |  |'.'|  |  |  |_|( OO )\n");
    80200422:	00009517          	auipc	a0,0x9
    80200426:	dee50513          	addi	a0,a0,-530 # 80209210 <etext+0x210>
    8020042a:	00000097          	auipc	ra,0x0
    8020042e:	d66080e7          	jalr	-666(ra) # 80200190 <printf>
    printf("  .'    \\_)    \\     /__)' \\  |  |  '------'   |  | |  |   |  .--'   |  |   |  |  |  | | `-' /\n");
    80200432:	00009517          	auipc	a0,0x9
    80200436:	e3e50513          	addi	a0,a0,-450 # 80209270 <etext+0x270>
    8020043a:	00000097          	auipc	ra,0x0
    8020043e:	d56080e7          	jalr	-682(ra) # 80200190 <printf>
    printf(" /  .'.  \\      \\   /    \\  `'  /              '  '-'  '-. |  `---.  |  |   |  | ('  '-'(_.-'\n");
    80200442:	00009517          	auipc	a0,0x9
    80200446:	e8e50513          	addi	a0,a0,-370 # 802092d0 <etext+0x2d0>
    8020044a:	00000097          	auipc	ra,0x0
    8020044e:	d46080e7          	jalr	-698(ra) # 80200190 <printf>
    printf("'--'   '--'      `-'      `----'                `-----'--' `------'  `--'   `--'   `-----'\n");
    80200452:	00009517          	auipc	a0,0x9
    80200456:	ede50513          	addi	a0,a0,-290 # 80209330 <etext+0x330>
    8020045a:	00000097          	auipc	ra,0x0
    8020045e:	d36080e7          	jalr	-714(ra) # 80200190 <printf>
}
    80200462:	60a2                	ld	ra,8(sp)
    80200464:	6402                	ld	s0,0(sp)
    80200466:	0141                	addi	sp,sp,16
    80200468:	8082                	ret

000000008020046a <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    8020046a:	1101                	addi	sp,sp,-32
    8020046c:	ec06                	sd	ra,24(sp)
    8020046e:	e822                	sd	s0,16(sp)
    80200470:	e426                	sd	s1,8(sp)
    80200472:	e04a                	sd	s2,0(sp)
    80200474:	1000                	addi	s0,sp,32
  struct run *r;
  
  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < kernel_end || (uint64)pa >= PHYSTOP)
    80200476:	03451793          	slli	a5,a0,0x34
    8020047a:	e3ad                	bnez	a5,802004dc <kfree+0x72>
    8020047c:	84aa                	mv	s1,a0
    8020047e:	00025797          	auipc	a5,0x25
    80200482:	b8278793          	addi	a5,a5,-1150 # 80225000 <ebss_clear>
    80200486:	04f56b63          	bltu	a0,a5,802004dc <kfree+0x72>
    8020048a:	40300793          	li	a5,1027
    8020048e:	07d6                	slli	a5,a5,0x15
    80200490:	04f57663          	bgeu	a0,a5,802004dc <kfree+0x72>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80200494:	6605                	lui	a2,0x1
    80200496:	4585                	li	a1,1
    80200498:	00000097          	auipc	ra,0x0
    8020049c:	2f4080e7          	jalr	756(ra) # 8020078c <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    802004a0:	00013917          	auipc	s2,0x13
    802004a4:	b8890913          	addi	s2,s2,-1144 # 80213028 <kmem>
    802004a8:	854a                	mv	a0,s2
    802004aa:	00000097          	auipc	ra,0x0
    802004ae:	246080e7          	jalr	582(ra) # 802006f0 <acquire>
  r->next = kmem.freelist;
    802004b2:	01893783          	ld	a5,24(s2)
    802004b6:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    802004b8:	00993c23          	sd	s1,24(s2)
  kmem.npage++;
    802004bc:	02093783          	ld	a5,32(s2)
    802004c0:	0785                	addi	a5,a5,1
    802004c2:	02f93023          	sd	a5,32(s2)
  release(&kmem.lock);
    802004c6:	854a                	mv	a0,s2
    802004c8:	00000097          	auipc	ra,0x0
    802004cc:	27c080e7          	jalr	636(ra) # 80200744 <release>
}
    802004d0:	60e2                	ld	ra,24(sp)
    802004d2:	6442                	ld	s0,16(sp)
    802004d4:	64a2                	ld	s1,8(sp)
    802004d6:	6902                	ld	s2,0(sp)
    802004d8:	6105                	addi	sp,sp,32
    802004da:	8082                	ret
    panic("kfree");
    802004dc:	00009517          	auipc	a0,0x9
    802004e0:	eb450513          	addi	a0,a0,-332 # 80209390 <etext+0x390>
    802004e4:	00000097          	auipc	ra,0x0
    802004e8:	c62080e7          	jalr	-926(ra) # 80200146 <panic>

00000000802004ec <freerange>:
{
    802004ec:	7179                	addi	sp,sp,-48
    802004ee:	f406                	sd	ra,40(sp)
    802004f0:	f022                	sd	s0,32(sp)
    802004f2:	ec26                	sd	s1,24(sp)
    802004f4:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    802004f6:	6785                	lui	a5,0x1
    802004f8:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x801ff001>
    802004fc:	00e504b3          	add	s1,a0,a4
    80200500:	777d                	lui	a4,0xfffff
    80200502:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80200504:	94be                	add	s1,s1,a5
    80200506:	0295e463          	bltu	a1,s1,8020052e <freerange+0x42>
    8020050a:	e84a                	sd	s2,16(sp)
    8020050c:	e44e                	sd	s3,8(sp)
    8020050e:	e052                	sd	s4,0(sp)
    80200510:	892e                	mv	s2,a1
    kfree(p);
    80200512:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80200514:	6985                	lui	s3,0x1
    kfree(p);
    80200516:	01448533          	add	a0,s1,s4
    8020051a:	00000097          	auipc	ra,0x0
    8020051e:	f50080e7          	jalr	-176(ra) # 8020046a <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80200522:	94ce                	add	s1,s1,s3
    80200524:	fe9979e3          	bgeu	s2,s1,80200516 <freerange+0x2a>
    80200528:	6942                	ld	s2,16(sp)
    8020052a:	69a2                	ld	s3,8(sp)
    8020052c:	6a02                	ld	s4,0(sp)
}
    8020052e:	70a2                	ld	ra,40(sp)
    80200530:	7402                	ld	s0,32(sp)
    80200532:	64e2                	ld	s1,24(sp)
    80200534:	6145                	addi	sp,sp,48
    80200536:	8082                	ret

0000000080200538 <kinit>:
{
    80200538:	1101                	addi	sp,sp,-32
    8020053a:	ec06                	sd	ra,24(sp)
    8020053c:	e822                	sd	s0,16(sp)
    8020053e:	e426                	sd	s1,8(sp)
    80200540:	1000                	addi	s0,sp,32
  initlock(&kmem.lock, "kmem");
    80200542:	00013497          	auipc	s1,0x13
    80200546:	ae648493          	addi	s1,s1,-1306 # 80213028 <kmem>
    8020054a:	00009597          	auipc	a1,0x9
    8020054e:	e4e58593          	addi	a1,a1,-434 # 80209398 <etext+0x398>
    80200552:	8526                	mv	a0,s1
    80200554:	00000097          	auipc	ra,0x0
    80200558:	158080e7          	jalr	344(ra) # 802006ac <initlock>
  kmem.freelist = 0;
    8020055c:	0004bc23          	sd	zero,24(s1)
  kmem.npage = 0;
    80200560:	0204b023          	sd	zero,32(s1)
  freerange(kernel_end, (void*)PHYSTOP);
    80200564:	40300593          	li	a1,1027
    80200568:	05d6                	slli	a1,a1,0x15
    8020056a:	00025517          	auipc	a0,0x25
    8020056e:	a9650513          	addi	a0,a0,-1386 # 80225000 <ebss_clear>
    80200572:	00000097          	auipc	ra,0x0
    80200576:	f7a080e7          	jalr	-134(ra) # 802004ec <freerange>
}
    8020057a:	60e2                	ld	ra,24(sp)
    8020057c:	6442                	ld	s0,16(sp)
    8020057e:	64a2                	ld	s1,8(sp)
    80200580:	6105                	addi	sp,sp,32
    80200582:	8082                	ret

0000000080200584 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80200584:	1101                	addi	sp,sp,-32
    80200586:	ec06                	sd	ra,24(sp)
    80200588:	e822                	sd	s0,16(sp)
    8020058a:	e426                	sd	s1,8(sp)
    8020058c:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    8020058e:	00013497          	auipc	s1,0x13
    80200592:	a9a48493          	addi	s1,s1,-1382 # 80213028 <kmem>
    80200596:	8526                	mv	a0,s1
    80200598:	00000097          	auipc	ra,0x0
    8020059c:	158080e7          	jalr	344(ra) # 802006f0 <acquire>
  r = kmem.freelist;
    802005a0:	6c84                	ld	s1,24(s1)
  if(r) {
    802005a2:	c89d                	beqz	s1,802005d8 <kalloc+0x54>
    kmem.freelist = r->next;
    802005a4:	609c                	ld	a5,0(s1)
    802005a6:	00013517          	auipc	a0,0x13
    802005aa:	a8250513          	addi	a0,a0,-1406 # 80213028 <kmem>
    802005ae:	ed1c                	sd	a5,24(a0)
    kmem.npage--;
    802005b0:	711c                	ld	a5,32(a0)
    802005b2:	17fd                	addi	a5,a5,-1
    802005b4:	f11c                	sd	a5,32(a0)
  }
  release(&kmem.lock);
    802005b6:	00000097          	auipc	ra,0x0
    802005ba:	18e080e7          	jalr	398(ra) # 80200744 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    802005be:	6605                	lui	a2,0x1
    802005c0:	4595                	li	a1,5
    802005c2:	8526                	mv	a0,s1
    802005c4:	00000097          	auipc	ra,0x0
    802005c8:	1c8080e7          	jalr	456(ra) # 8020078c <memset>
  return (void*)r;
}
    802005cc:	8526                	mv	a0,s1
    802005ce:	60e2                	ld	ra,24(sp)
    802005d0:	6442                	ld	s0,16(sp)
    802005d2:	64a2                	ld	s1,8(sp)
    802005d4:	6105                	addi	sp,sp,32
    802005d6:	8082                	ret
  release(&kmem.lock);
    802005d8:	00013517          	auipc	a0,0x13
    802005dc:	a5050513          	addi	a0,a0,-1456 # 80213028 <kmem>
    802005e0:	00000097          	auipc	ra,0x0
    802005e4:	164080e7          	jalr	356(ra) # 80200744 <release>
  if(r)
    802005e8:	b7d5                	j	802005cc <kalloc+0x48>

00000000802005ea <freemem_amount>:

uint64
freemem_amount(void)
{
    802005ea:	1141                	addi	sp,sp,-16
    802005ec:	e422                	sd	s0,8(sp)
    802005ee:	0800                	addi	s0,sp,16
  return kmem.npage << PGSHIFT;
}
    802005f0:	00013517          	auipc	a0,0x13
    802005f4:	a5853503          	ld	a0,-1448(a0) # 80213048 <kmem+0x20>
    802005f8:	0532                	slli	a0,a0,0xc
    802005fa:	6422                	ld	s0,8(sp)
    802005fc:	0141                	addi	sp,sp,16
    802005fe:	8082                	ret

0000000080200600 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80200600:	1101                	addi	sp,sp,-32
    80200602:	ec06                	sd	ra,24(sp)
    80200604:	e822                	sd	s0,16(sp)
    80200606:	e426                	sd	s1,8(sp)
    80200608:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8020060a:	100024f3          	csrr	s1,sstatus
    8020060e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80200612:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80200614:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  //printf("\e[32mpush_off()\e[0m: cpuid(): %d\n", cpuid());
  if(mycpu()->noff == 0)
    80200618:	00001097          	auipc	ra,0x1
    8020061c:	49a080e7          	jalr	1178(ra) # 80201ab2 <mycpu>
    80200620:	5d3c                	lw	a5,120(a0)
    80200622:	cf89                	beqz	a5,8020063c <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80200624:	00001097          	auipc	ra,0x1
    80200628:	48e080e7          	jalr	1166(ra) # 80201ab2 <mycpu>
    8020062c:	5d3c                	lw	a5,120(a0)
    8020062e:	2785                	addiw	a5,a5,1
    80200630:	dd3c                	sw	a5,120(a0)
}
    80200632:	60e2                	ld	ra,24(sp)
    80200634:	6442                	ld	s0,16(sp)
    80200636:	64a2                	ld	s1,8(sp)
    80200638:	6105                	addi	sp,sp,32
    8020063a:	8082                	ret
    mycpu()->intena = old;
    8020063c:	00001097          	auipc	ra,0x1
    80200640:	476080e7          	jalr	1142(ra) # 80201ab2 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80200644:	8085                	srli	s1,s1,0x1
    80200646:	8885                	andi	s1,s1,1
    80200648:	dd64                	sw	s1,124(a0)
    8020064a:	bfe9                	j	80200624 <push_off+0x24>

000000008020064c <pop_off>:

void
pop_off(void)
{
    8020064c:	1141                	addi	sp,sp,-16
    8020064e:	e406                	sd	ra,8(sp)
    80200650:	e022                	sd	s0,0(sp)
    80200652:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80200654:	00001097          	auipc	ra,0x1
    80200658:	45e080e7          	jalr	1118(ra) # 80201ab2 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8020065c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80200660:	8b89                	andi	a5,a5,2

  //printf("\e[31mpop_off()\e[0m: cpuid(): %d\n", cpuid());
  if(intr_get())
    80200662:	e78d                	bnez	a5,8020068c <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1) {
    80200664:	5d3c                	lw	a5,120(a0)
    80200666:	02f05b63          	blez	a5,8020069c <pop_off+0x50>
    //printf("c->noff = %d\n", c->noff);
    panic("pop_off");
  }
  //printf("c->noff: %d\n", c->noff);
  //printf("c: %x\n", c);
  c->noff -= 1;
    8020066a:	37fd                	addiw	a5,a5,-1
    8020066c:	0007871b          	sext.w	a4,a5
    80200670:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80200672:	eb09                	bnez	a4,80200684 <pop_off+0x38>
    80200674:	5d7c                	lw	a5,124(a0)
    80200676:	c799                	beqz	a5,80200684 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80200678:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8020067c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80200680:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80200684:	60a2                	ld	ra,8(sp)
    80200686:	6402                	ld	s0,0(sp)
    80200688:	0141                	addi	sp,sp,16
    8020068a:	8082                	ret
    panic("pop_off - interruptible");
    8020068c:	00009517          	auipc	a0,0x9
    80200690:	d1450513          	addi	a0,a0,-748 # 802093a0 <etext+0x3a0>
    80200694:	00000097          	auipc	ra,0x0
    80200698:	ab2080e7          	jalr	-1358(ra) # 80200146 <panic>
    panic("pop_off");
    8020069c:	00009517          	auipc	a0,0x9
    802006a0:	d1c50513          	addi	a0,a0,-740 # 802093b8 <etext+0x3b8>
    802006a4:	00000097          	auipc	ra,0x0
    802006a8:	aa2080e7          	jalr	-1374(ra) # 80200146 <panic>

00000000802006ac <initlock>:
#include "include/intr.h"
#include "include/printf.h"

void
initlock(struct spinlock *lk, char *name)
{
    802006ac:	1141                	addi	sp,sp,-16
    802006ae:	e422                	sd	s0,8(sp)
    802006b0:	0800                	addi	s0,sp,16
  lk->name = name;
    802006b2:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    802006b4:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    802006b8:	00053823          	sd	zero,16(a0)
}
    802006bc:	6422                	ld	s0,8(sp)
    802006be:	0141                	addi	sp,sp,16
    802006c0:	8082                	ret

00000000802006c2 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    802006c2:	411c                	lw	a5,0(a0)
    802006c4:	e399                	bnez	a5,802006ca <holding+0x8>
    802006c6:	4501                	li	a0,0
  return r;
}
    802006c8:	8082                	ret
{
    802006ca:	1101                	addi	sp,sp,-32
    802006cc:	ec06                	sd	ra,24(sp)
    802006ce:	e822                	sd	s0,16(sp)
    802006d0:	e426                	sd	s1,8(sp)
    802006d2:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    802006d4:	6904                	ld	s1,16(a0)
    802006d6:	00001097          	auipc	ra,0x1
    802006da:	3dc080e7          	jalr	988(ra) # 80201ab2 <mycpu>
    802006de:	40a48533          	sub	a0,s1,a0
    802006e2:	00153513          	seqz	a0,a0
}
    802006e6:	60e2                	ld	ra,24(sp)
    802006e8:	6442                	ld	s0,16(sp)
    802006ea:	64a2                	ld	s1,8(sp)
    802006ec:	6105                	addi	sp,sp,32
    802006ee:	8082                	ret

00000000802006f0 <acquire>:
{
    802006f0:	1101                	addi	sp,sp,-32
    802006f2:	ec06                	sd	ra,24(sp)
    802006f4:	e822                	sd	s0,16(sp)
    802006f6:	e426                	sd	s1,8(sp)
    802006f8:	1000                	addi	s0,sp,32
    802006fa:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    802006fc:	00000097          	auipc	ra,0x0
    80200700:	f04080e7          	jalr	-252(ra) # 80200600 <push_off>
  if(holding(lk))
    80200704:	8526                	mv	a0,s1
    80200706:	00000097          	auipc	ra,0x0
    8020070a:	fbc080e7          	jalr	-68(ra) # 802006c2 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    8020070e:	4705                	li	a4,1
  if(holding(lk))
    80200710:	e115                	bnez	a0,80200734 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80200712:	87ba                	mv	a5,a4
    80200714:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80200718:	2781                	sext.w	a5,a5
    8020071a:	ffe5                	bnez	a5,80200712 <acquire+0x22>
  __sync_synchronize();
    8020071c:	0ff0000f          	fence
  lk->cpu = mycpu();
    80200720:	00001097          	auipc	ra,0x1
    80200724:	392080e7          	jalr	914(ra) # 80201ab2 <mycpu>
    80200728:	e888                	sd	a0,16(s1)
}
    8020072a:	60e2                	ld	ra,24(sp)
    8020072c:	6442                	ld	s0,16(sp)
    8020072e:	64a2                	ld	s1,8(sp)
    80200730:	6105                	addi	sp,sp,32
    80200732:	8082                	ret
    panic("acquire");
    80200734:	00009517          	auipc	a0,0x9
    80200738:	c8c50513          	addi	a0,a0,-884 # 802093c0 <etext+0x3c0>
    8020073c:	00000097          	auipc	ra,0x0
    80200740:	a0a080e7          	jalr	-1526(ra) # 80200146 <panic>

0000000080200744 <release>:
{
    80200744:	1101                	addi	sp,sp,-32
    80200746:	ec06                	sd	ra,24(sp)
    80200748:	e822                	sd	s0,16(sp)
    8020074a:	e426                	sd	s1,8(sp)
    8020074c:	1000                	addi	s0,sp,32
    8020074e:	84aa                	mv	s1,a0
  if(!holding(lk))
    80200750:	00000097          	auipc	ra,0x0
    80200754:	f72080e7          	jalr	-142(ra) # 802006c2 <holding>
    80200758:	c115                	beqz	a0,8020077c <release+0x38>
  lk->cpu = 0;
    8020075a:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    8020075e:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80200762:	0f50000f          	fence	iorw,ow
    80200766:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    8020076a:	00000097          	auipc	ra,0x0
    8020076e:	ee2080e7          	jalr	-286(ra) # 8020064c <pop_off>
}
    80200772:	60e2                	ld	ra,24(sp)
    80200774:	6442                	ld	s0,16(sp)
    80200776:	64a2                	ld	s1,8(sp)
    80200778:	6105                	addi	sp,sp,32
    8020077a:	8082                	ret
    panic("release");
    8020077c:	00009517          	auipc	a0,0x9
    80200780:	c4c50513          	addi	a0,a0,-948 # 802093c8 <etext+0x3c8>
    80200784:	00000097          	auipc	ra,0x0
    80200788:	9c2080e7          	jalr	-1598(ra) # 80200146 <panic>

000000008020078c <memset>:
#include "include/types.h"

void*
memset(void *dst, int c, uint n)
{
    8020078c:	1141                	addi	sp,sp,-16
    8020078e:	e422                	sd	s0,8(sp)
    80200790:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80200792:	ca19                	beqz	a2,802007a8 <memset+0x1c>
    80200794:	87aa                	mv	a5,a0
    80200796:	1602                	slli	a2,a2,0x20
    80200798:	9201                	srli	a2,a2,0x20
    8020079a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    8020079e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    802007a2:	0785                	addi	a5,a5,1
    802007a4:	fee79de3          	bne	a5,a4,8020079e <memset+0x12>
  }
  return dst;
}
    802007a8:	6422                	ld	s0,8(sp)
    802007aa:	0141                	addi	sp,sp,16
    802007ac:	8082                	ret

00000000802007ae <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    802007ae:	1141                	addi	sp,sp,-16
    802007b0:	e422                	sd	s0,8(sp)
    802007b2:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    802007b4:	ca05                	beqz	a2,802007e4 <memcmp+0x36>
    802007b6:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x801ff001>
    802007ba:	1682                	slli	a3,a3,0x20
    802007bc:	9281                	srli	a3,a3,0x20
    802007be:	0685                	addi	a3,a3,1
    802007c0:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    802007c2:	00054783          	lbu	a5,0(a0)
    802007c6:	0005c703          	lbu	a4,0(a1)
    802007ca:	00e79863          	bne	a5,a4,802007da <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    802007ce:	0505                	addi	a0,a0,1
    802007d0:	0585                	addi	a1,a1,1
  while(n-- > 0){
    802007d2:	fed518e3          	bne	a0,a3,802007c2 <memcmp+0x14>
  }

  return 0;
    802007d6:	4501                	li	a0,0
    802007d8:	a019                	j	802007de <memcmp+0x30>
      return *s1 - *s2;
    802007da:	40e7853b          	subw	a0,a5,a4
}
    802007de:	6422                	ld	s0,8(sp)
    802007e0:	0141                	addi	sp,sp,16
    802007e2:	8082                	ret
  return 0;
    802007e4:	4501                	li	a0,0
    802007e6:	bfe5                	j	802007de <memcmp+0x30>

00000000802007e8 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    802007e8:	1141                	addi	sp,sp,-16
    802007ea:	e422                	sd	s0,8(sp)
    802007ec:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    802007ee:	02a5e563          	bltu	a1,a0,80200818 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    802007f2:	fff6069b          	addiw	a3,a2,-1
    802007f6:	ce11                	beqz	a2,80200812 <memmove+0x2a>
    802007f8:	1682                	slli	a3,a3,0x20
    802007fa:	9281                	srli	a3,a3,0x20
    802007fc:	0685                	addi	a3,a3,1
    802007fe:	96ae                	add	a3,a3,a1
    80200800:	87aa                	mv	a5,a0
      *d++ = *s++;
    80200802:	0585                	addi	a1,a1,1
    80200804:	0785                	addi	a5,a5,1
    80200806:	fff5c703          	lbu	a4,-1(a1)
    8020080a:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    8020080e:	feb69ae3          	bne	a3,a1,80200802 <memmove+0x1a>

  return dst;
}
    80200812:	6422                	ld	s0,8(sp)
    80200814:	0141                	addi	sp,sp,16
    80200816:	8082                	ret
  if(s < d && s + n > d){
    80200818:	02061713          	slli	a4,a2,0x20
    8020081c:	9301                	srli	a4,a4,0x20
    8020081e:	00e587b3          	add	a5,a1,a4
    80200822:	fcf578e3          	bgeu	a0,a5,802007f2 <memmove+0xa>
    d += n;
    80200826:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80200828:	fff6069b          	addiw	a3,a2,-1
    8020082c:	d27d                	beqz	a2,80200812 <memmove+0x2a>
    8020082e:	02069613          	slli	a2,a3,0x20
    80200832:	9201                	srli	a2,a2,0x20
    80200834:	fff64613          	not	a2,a2
    80200838:	963e                	add	a2,a2,a5
      *--d = *--s;
    8020083a:	17fd                	addi	a5,a5,-1
    8020083c:	177d                	addi	a4,a4,-1 # ffffffffffffefff <ebss_clear+0xffffffff7fdd9fff>
    8020083e:	0007c683          	lbu	a3,0(a5)
    80200842:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80200846:	fec79ae3          	bne	a5,a2,8020083a <memmove+0x52>
    8020084a:	b7e1                	j	80200812 <memmove+0x2a>

000000008020084c <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    8020084c:	1141                	addi	sp,sp,-16
    8020084e:	e406                	sd	ra,8(sp)
    80200850:	e022                	sd	s0,0(sp)
    80200852:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80200854:	00000097          	auipc	ra,0x0
    80200858:	f94080e7          	jalr	-108(ra) # 802007e8 <memmove>
}
    8020085c:	60a2                	ld	ra,8(sp)
    8020085e:	6402                	ld	s0,0(sp)
    80200860:	0141                	addi	sp,sp,16
    80200862:	8082                	ret

0000000080200864 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80200864:	1141                	addi	sp,sp,-16
    80200866:	e422                	sd	s0,8(sp)
    80200868:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    8020086a:	ce11                	beqz	a2,80200886 <strncmp+0x22>
    8020086c:	00054783          	lbu	a5,0(a0)
    80200870:	cf89                	beqz	a5,8020088a <strncmp+0x26>
    80200872:	0005c703          	lbu	a4,0(a1)
    80200876:	00f71a63          	bne	a4,a5,8020088a <strncmp+0x26>
    n--, p++, q++;
    8020087a:	367d                	addiw	a2,a2,-1
    8020087c:	0505                	addi	a0,a0,1
    8020087e:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80200880:	f675                	bnez	a2,8020086c <strncmp+0x8>
  if(n == 0)
    return 0;
    80200882:	4501                	li	a0,0
    80200884:	a801                	j	80200894 <strncmp+0x30>
    80200886:	4501                	li	a0,0
    80200888:	a031                	j	80200894 <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    8020088a:	00054503          	lbu	a0,0(a0)
    8020088e:	0005c783          	lbu	a5,0(a1)
    80200892:	9d1d                	subw	a0,a0,a5
}
    80200894:	6422                	ld	s0,8(sp)
    80200896:	0141                	addi	sp,sp,16
    80200898:	8082                	ret

000000008020089a <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    8020089a:	1141                	addi	sp,sp,-16
    8020089c:	e422                	sd	s0,8(sp)
    8020089e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    802008a0:	87aa                	mv	a5,a0
    802008a2:	86b2                	mv	a3,a2
    802008a4:	367d                	addiw	a2,a2,-1
    802008a6:	02d05563          	blez	a3,802008d0 <strncpy+0x36>
    802008aa:	0785                	addi	a5,a5,1
    802008ac:	0005c703          	lbu	a4,0(a1)
    802008b0:	fee78fa3          	sb	a4,-1(a5)
    802008b4:	0585                	addi	a1,a1,1
    802008b6:	f775                	bnez	a4,802008a2 <strncpy+0x8>
    ;
  while(n-- > 0)
    802008b8:	873e                	mv	a4,a5
    802008ba:	9fb5                	addw	a5,a5,a3
    802008bc:	37fd                	addiw	a5,a5,-1
    802008be:	00c05963          	blez	a2,802008d0 <strncpy+0x36>
    *s++ = 0;
    802008c2:	0705                	addi	a4,a4,1
    802008c4:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    802008c8:	40e786bb          	subw	a3,a5,a4
    802008cc:	fed04be3          	bgtz	a3,802008c2 <strncpy+0x28>
  return os;
}
    802008d0:	6422                	ld	s0,8(sp)
    802008d2:	0141                	addi	sp,sp,16
    802008d4:	8082                	ret

00000000802008d6 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    802008d6:	1141                	addi	sp,sp,-16
    802008d8:	e422                	sd	s0,8(sp)
    802008da:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    802008dc:	02c05363          	blez	a2,80200902 <safestrcpy+0x2c>
    802008e0:	fff6069b          	addiw	a3,a2,-1
    802008e4:	1682                	slli	a3,a3,0x20
    802008e6:	9281                	srli	a3,a3,0x20
    802008e8:	96ae                	add	a3,a3,a1
    802008ea:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    802008ec:	00d58963          	beq	a1,a3,802008fe <safestrcpy+0x28>
    802008f0:	0585                	addi	a1,a1,1
    802008f2:	0785                	addi	a5,a5,1
    802008f4:	fff5c703          	lbu	a4,-1(a1)
    802008f8:	fee78fa3          	sb	a4,-1(a5)
    802008fc:	fb65                	bnez	a4,802008ec <safestrcpy+0x16>
    ;
  *s = 0;
    802008fe:	00078023          	sb	zero,0(a5)
  return os;
}
    80200902:	6422                	ld	s0,8(sp)
    80200904:	0141                	addi	sp,sp,16
    80200906:	8082                	ret

0000000080200908 <strlen>:

int
strlen(const char *s)
{
    80200908:	1141                	addi	sp,sp,-16
    8020090a:	e422                	sd	s0,8(sp)
    8020090c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    8020090e:	00054783          	lbu	a5,0(a0)
    80200912:	cf91                	beqz	a5,8020092e <strlen+0x26>
    80200914:	0505                	addi	a0,a0,1
    80200916:	87aa                	mv	a5,a0
    80200918:	86be                	mv	a3,a5
    8020091a:	0785                	addi	a5,a5,1
    8020091c:	fff7c703          	lbu	a4,-1(a5)
    80200920:	ff65                	bnez	a4,80200918 <strlen+0x10>
    80200922:	40a6853b          	subw	a0,a3,a0
    80200926:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80200928:	6422                	ld	s0,8(sp)
    8020092a:	0141                	addi	sp,sp,16
    8020092c:	8082                	ret
  for(n = 0; s[n]; n++)
    8020092e:	4501                	li	a0,0
    80200930:	bfe5                	j	80200928 <strlen+0x20>

0000000080200932 <wnstr>:

// convert uchar string into wide char string 
void wnstr(wchar *dst, char const *src, int len) {
    80200932:	1141                	addi	sp,sp,-16
    80200934:	e422                	sd	s0,8(sp)
    80200936:	0800                	addi	s0,sp,16
  while (len -- && *src) {
    80200938:	c20d                	beqz	a2,8020095a <wnstr+0x28>
    8020093a:	02061793          	slli	a5,a2,0x20
    8020093e:	01f7d613          	srli	a2,a5,0x1f
    80200942:	00c50733          	add	a4,a0,a2
    80200946:	0005c783          	lbu	a5,0(a1)
    8020094a:	cb81                	beqz	a5,8020095a <wnstr+0x28>
    *(uchar*)dst = *src++;
    8020094c:	0585                	addi	a1,a1,1
    8020094e:	00f50023          	sb	a5,0(a0)
    dst ++;
    80200952:	0509                	addi	a0,a0,2
  while (len -- && *src) {
    80200954:	fee519e3          	bne	a0,a4,80200946 <wnstr+0x14>
    80200958:	853a                	mv	a0,a4
  }

  *dst = 0;
    8020095a:	00051023          	sh	zero,0(a0)
}
    8020095e:	6422                	ld	s0,8(sp)
    80200960:	0141                	addi	sp,sp,16
    80200962:	8082                	ret

0000000080200964 <snstr>:

// convert wide char string into uchar string 
void snstr(char *dst, wchar const *src, int len) {
    80200964:	1141                	addi	sp,sp,-16
    80200966:	e422                	sd	s0,8(sp)
    80200968:	0800                	addi	s0,sp,16
  while (len -- && *src) {
    8020096a:	fff6071b          	addiw	a4,a2,-1
    8020096e:	02061693          	slli	a3,a2,0x20
    80200972:	9281                	srli	a3,a3,0x20
    80200974:	96aa                	add	a3,a3,a0
    80200976:	c61d                	beqz	a2,802009a4 <snstr+0x40>
    80200978:	0005d783          	lhu	a5,0(a1)
    8020097c:	cb89                	beqz	a5,8020098e <snstr+0x2a>
    *dst++ = (uchar)(*src & 0xff);
    8020097e:	0505                	addi	a0,a0,1
    80200980:	fef50fa3          	sb	a5,-1(a0)
    src ++;
    80200984:	0589                	addi	a1,a1,2
  while (len -- && *src) {
    80200986:	377d                	addiw	a4,a4,-1
    80200988:	fed518e3          	bne	a0,a3,80200978 <snstr+0x14>
    8020098c:	8536                	mv	a0,a3
  }
  while(len-- > 0)
    8020098e:	02071793          	slli	a5,a4,0x20
    80200992:	9381                	srli	a5,a5,0x20
    80200994:	97aa                	add	a5,a5,a0
    80200996:	00e05763          	blez	a4,802009a4 <snstr+0x40>
    *dst++ = 0;
    8020099a:	0505                	addi	a0,a0,1
    8020099c:	fe050fa3          	sb	zero,-1(a0)
  while(len-- > 0)
    802009a0:	fef51de3          	bne	a0,a5,8020099a <snstr+0x36>
}
    802009a4:	6422                	ld	s0,8(sp)
    802009a6:	0141                	addi	sp,sp,16
    802009a8:	8082                	ret

00000000802009aa <wcsncmp>:

int wcsncmp(wchar const *s1, wchar const *s2, int len) {
    802009aa:	1141                	addi	sp,sp,-16
    802009ac:	e422                	sd	s0,8(sp)
    802009ae:	0800                	addi	s0,sp,16
    802009b0:	872a                	mv	a4,a0
  int ret = 0;

  while (len-- && *s1) {
    802009b2:	02061793          	slli	a5,a2,0x20
    802009b6:	01f7d613          	srli	a2,a5,0x1f
    802009ba:	962e                	add	a2,a2,a1
    802009bc:	00c58f63          	beq	a1,a2,802009da <wcsncmp+0x30>
    802009c0:	00075783          	lhu	a5,0(a4)
    802009c4:	cb89                	beqz	a5,802009d6 <wcsncmp+0x2c>
    ret = (int)(*s1++ - *s2++);
    802009c6:	0709                	addi	a4,a4,2
    802009c8:	0589                	addi	a1,a1,2
    802009ca:	ffe5d683          	lhu	a3,-2(a1)
    802009ce:	40d7853b          	subw	a0,a5,a3
    if (ret) break;
    802009d2:	d56d                	beqz	a0,802009bc <wcsncmp+0x12>
    802009d4:	a021                	j	802009dc <wcsncmp+0x32>
    802009d6:	4501                	li	a0,0
    802009d8:	a011                	j	802009dc <wcsncmp+0x32>
    802009da:	4501                	li	a0,0
  }

  return ret;
}
    802009dc:	6422                	ld	s0,8(sp)
    802009de:	0141                	addi	sp,sp,16
    802009e0:	8082                	ret

00000000802009e2 <strchr>:

char*
strchr(const char *s, char c)
{
    802009e2:	1141                	addi	sp,sp,-16
    802009e4:	e422                	sd	s0,8(sp)
    802009e6:	0800                	addi	s0,sp,16
  for(; *s; s++)
    802009e8:	00054783          	lbu	a5,0(a0)
    802009ec:	cb99                	beqz	a5,80200a02 <strchr+0x20>
    if(*s == c)
    802009ee:	00f58763          	beq	a1,a5,802009fc <strchr+0x1a>
  for(; *s; s++)
    802009f2:	0505                	addi	a0,a0,1
    802009f4:	00054783          	lbu	a5,0(a0)
    802009f8:	fbfd                	bnez	a5,802009ee <strchr+0xc>
      return (char*)s;
  return 0;
    802009fa:	4501                	li	a0,0
    802009fc:	6422                	ld	s0,8(sp)
    802009fe:	0141                	addi	sp,sp,16
    80200a00:	8082                	ret
  return 0;
    80200a02:	4501                	li	a0,0
    80200a04:	bfe5                	j	802009fc <strchr+0x1a>

0000000080200a06 <main>:

volatile static int started = 0;

void
main(unsigned long hartid, unsigned long dtb_pa)
{
    80200a06:	7179                	addi	sp,sp,-48
    80200a08:	f406                	sd	ra,40(sp)
    80200a0a:	f022                	sd	s0,32(sp)
    80200a0c:	ec26                	sd	s1,24(sp)
    80200a0e:	1800                	addi	s0,sp,48
    80200a10:	84aa                	mv	s1,a0
  asm volatile("mv tp, %0" : : "r" (hartid & 0x1));
    80200a12:	00157793          	andi	a5,a0,1
    80200a16:	823e                	mv	tp,a5
  inithartid(hartid);

  if (__sync_bool_compare_and_swap(&started, 0, -1)) {
    80200a18:	00012717          	auipc	a4,0x12
    80200a1c:	63870713          	addi	a4,a4,1592 # 80213050 <started>
    80200a20:	56fd                	li	a3,-1
    80200a22:	0f50000f          	fence	iorw,ow
    80200a26:	140727af          	lr.w.aq	a5,(a4)
    80200a2a:	e781                	bnez	a5,80200a32 <main+0x2c>
    80200a2c:	1cd7262f          	sc.w.aq	a2,a3,(a4)
    80200a30:	fa7d                	bnez	a2,80200a26 <main+0x20>
    80200a32:	2781                	sext.w	a5,a5
    __sync_synchronize();
    started = 1;
  }
  else
  {
    while (started != 1)
    80200a34:	86ba                	mv	a3,a4
    80200a36:	4705                	li	a4,1
  if (__sync_bool_compare_and_swap(&started, 0, -1)) {
    80200a38:	ebf1                	bnez	a5,80200b0c <main+0x106>
    consoleinit();
    80200a3a:	00006097          	auipc	ra,0x6
    80200a3e:	654080e7          	jalr	1620(ra) # 8020708e <consoleinit>
    printfinit();   // init a lock for printf 
    80200a42:	00000097          	auipc	ra,0x0
    80200a46:	956080e7          	jalr	-1706(ra) # 80200398 <printfinit>
    print_logo();
    80200a4a:	00000097          	auipc	ra,0x0
    80200a4e:	980080e7          	jalr	-1664(ra) # 802003ca <print_logo>
    kinit();         // physical page allocator
    80200a52:	00000097          	auipc	ra,0x0
    80200a56:	ae6080e7          	jalr	-1306(ra) # 80200538 <kinit>
    kvminit();       // create kernel page table
    80200a5a:	00000097          	auipc	ra,0x0
    80200a5e:	334080e7          	jalr	820(ra) # 80200d8e <kvminit>
    kvminithart();   // turn on paging
    80200a62:	00000097          	auipc	ra,0x0
    80200a66:	0e2080e7          	jalr	226(ra) # 80200b44 <kvminithart>
    timerinit();     // init a lock for timer
    80200a6a:	00004097          	auipc	ra,0x4
    80200a6e:	614080e7          	jalr	1556(ra) # 8020507e <timerinit>
    trapinithart();  // install kernel trap vector, including interrupt handler
    80200a72:	00002097          	auipc	ra,0x2
    80200a76:	cde080e7          	jalr	-802(ra) # 80202750 <trapinithart>
    procinit();
    80200a7a:	00001097          	auipc	ra,0x1
    80200a7e:	fb2080e7          	jalr	-78(ra) # 80201a2c <procinit>
    plicinit();
    80200a82:	00006097          	auipc	ra,0x6
    80200a86:	1ce080e7          	jalr	462(ra) # 80206c50 <plicinit>
    plicinithart();
    80200a8a:	00006097          	auipc	ra,0x6
    80200a8e:	1e4080e7          	jalr	484(ra) # 80206c6e <plicinithart>
    disk_init();
    80200a92:	00004097          	auipc	ra,0x4
    80200a96:	688080e7          	jalr	1672(ra) # 8020511a <disk_init>
    binit();         // buffer cache
    80200a9a:	00003097          	auipc	ra,0x3
    80200a9e:	8da080e7          	jalr	-1830(ra) # 80203374 <binit>
    fileinit();      // file table
    80200aa2:	00003097          	auipc	ra,0x3
    80200aa6:	cdc080e7          	jalr	-804(ra) # 8020377e <fileinit>
    userinit();      // first user process
    80200aaa:	00001097          	auipc	ra,0x1
    80200aae:	332080e7          	jalr	818(ra) # 80201ddc <userinit>
    printf("hart %d init done\n", hartid);
    80200ab2:	85a6                	mv	a1,s1
    80200ab4:	00009517          	auipc	a0,0x9
    80200ab8:	91c50513          	addi	a0,a0,-1764 # 802093d0 <etext+0x3d0>
    80200abc:	fffff097          	auipc	ra,0xfffff
    80200ac0:	6d4080e7          	jalr	1748(ra) # 80200190 <printf>
      if(i == hartid)
    80200ac4:	cc91                	beqz	s1,80200ae0 <main+0xda>
      unsigned long mask = 1 << i;
    80200ac6:	4785                	li	a5,1
    80200ac8:	fcf43c23          	sd	a5,-40(s0)
	SBI_CALL_0(SBI_CLEAR_IPI);
}

static inline void sbi_send_ipi(const unsigned long *hart_mask)
{
	SBI_CALL_1(SBI_SEND_IPI, hart_mask);
    80200acc:	fd840513          	addi	a0,s0,-40
    80200ad0:	4581                	li	a1,0
    80200ad2:	4601                	li	a2,0
    80200ad4:	4681                	li	a3,0
    80200ad6:	4891                	li	a7,4
    80200ad8:	00000073          	ecall
      if(i == hartid)
    80200adc:	00f48d63          	beq	s1,a5,80200af6 <main+0xf0>
      unsigned long mask = 1 << i;
    80200ae0:	4789                	li	a5,2
    80200ae2:	fcf43c23          	sd	a5,-40(s0)
    80200ae6:	fd840513          	addi	a0,s0,-40
    80200aea:	4581                	li	a1,0
    80200aec:	4601                	li	a2,0
    80200aee:	4681                	li	a3,0
    80200af0:	4891                	li	a7,4
    80200af2:	00000073          	ecall
    __sync_synchronize();
    80200af6:	0ff0000f          	fence
    started = 1;
    80200afa:	4785                	li	a5,1
    80200afc:	00012717          	auipc	a4,0x12
    80200b00:	54f72a23          	sw	a5,1364(a4) # 80213050 <started>
    kvminithart();
    trapinithart();
    plicinithart();  // ask PLIC for device interrupts
    printf("hart %d init done\n", hartid);
  }
  scheduler();
    80200b04:	00001097          	auipc	ra,0x1
    80200b08:	548080e7          	jalr	1352(ra) # 8020204c <scheduler>
    while (started != 1)
    80200b0c:	429c                	lw	a5,0(a3)
    80200b0e:	2781                	sext.w	a5,a5
    80200b10:	fee79ee3          	bne	a5,a4,80200b0c <main+0x106>
    __sync_synchronize();
    80200b14:	0ff0000f          	fence
    kvminithart();
    80200b18:	00000097          	auipc	ra,0x0
    80200b1c:	02c080e7          	jalr	44(ra) # 80200b44 <kvminithart>
    trapinithart();
    80200b20:	00002097          	auipc	ra,0x2
    80200b24:	c30080e7          	jalr	-976(ra) # 80202750 <trapinithart>
    plicinithart();  // ask PLIC for device interrupts
    80200b28:	00006097          	auipc	ra,0x6
    80200b2c:	146080e7          	jalr	326(ra) # 80206c6e <plicinithart>
    printf("hart %d init done\n", hartid);
    80200b30:	85a6                	mv	a1,s1
    80200b32:	00009517          	auipc	a0,0x9
    80200b36:	89e50513          	addi	a0,a0,-1890 # 802093d0 <etext+0x3d0>
    80200b3a:	fffff097          	auipc	ra,0xfffff
    80200b3e:	656080e7          	jalr	1622(ra) # 80200190 <printf>
    80200b42:	b7c9                	j	80200b04 <main+0xfe>

0000000080200b44 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80200b44:	1141                	addi	sp,sp,-16
    80200b46:	e422                	sd	s0,8(sp)
    80200b48:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80200b4a:	00012797          	auipc	a5,0x12
    80200b4e:	50e7b783          	ld	a5,1294(a5) # 80213058 <kernel_pagetable>
    80200b52:	83b1                	srli	a5,a5,0xc
    80200b54:	577d                	li	a4,-1
    80200b56:	177e                	slli	a4,a4,0x3f
    80200b58:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80200b5a:	18079073          	csrw	satp,a5
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  // asm volatile("sfence.vma zero, zero");
  asm volatile("sfence.vma");
    80200b5e:	12000073          	sfence.vma
  // reg_info();
  sfence_vma();
  #ifdef DEBUG
  printf("kvminithart\n");
  #endif
}
    80200b62:	6422                	ld	s0,8(sp)
    80200b64:	0141                	addi	sp,sp,16
    80200b66:	8082                	ret

0000000080200b68 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80200b68:	7139                	addi	sp,sp,-64
    80200b6a:	fc06                	sd	ra,56(sp)
    80200b6c:	f822                	sd	s0,48(sp)
    80200b6e:	f426                	sd	s1,40(sp)
    80200b70:	f04a                	sd	s2,32(sp)
    80200b72:	ec4e                	sd	s3,24(sp)
    80200b74:	e852                	sd	s4,16(sp)
    80200b76:	e456                	sd	s5,8(sp)
    80200b78:	e05a                	sd	s6,0(sp)
    80200b7a:	0080                	addi	s0,sp,64
    80200b7c:	84aa                	mv	s1,a0
    80200b7e:	89ae                	mv	s3,a1
    80200b80:	8ab2                	mv	s5,a2
  
  if(va >= MAXVA)
    80200b82:	57fd                	li	a5,-1
    80200b84:	83e9                	srli	a5,a5,0x1a
    80200b86:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80200b88:	4b31                	li	s6,12
  if(va >= MAXVA)
    80200b8a:	04b7f263          	bgeu	a5,a1,80200bce <walk+0x66>
    panic("walk");
    80200b8e:	00009517          	auipc	a0,0x9
    80200b92:	85a50513          	addi	a0,a0,-1958 # 802093e8 <etext+0x3e8>
    80200b96:	fffff097          	auipc	ra,0xfffff
    80200b9a:	5b0080e7          	jalr	1456(ra) # 80200146 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == NULL)
    80200b9e:	060a8663          	beqz	s5,80200c0a <walk+0xa2>
    80200ba2:	00000097          	auipc	ra,0x0
    80200ba6:	9e2080e7          	jalr	-1566(ra) # 80200584 <kalloc>
    80200baa:	84aa                	mv	s1,a0
    80200bac:	c529                	beqz	a0,80200bf6 <walk+0x8e>
        return NULL;
      memset(pagetable, 0, PGSIZE);
    80200bae:	6605                	lui	a2,0x1
    80200bb0:	4581                	li	a1,0
    80200bb2:	00000097          	auipc	ra,0x0
    80200bb6:	bda080e7          	jalr	-1062(ra) # 8020078c <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80200bba:	00c4d793          	srli	a5,s1,0xc
    80200bbe:	07aa                	slli	a5,a5,0xa
    80200bc0:	0017e793          	ori	a5,a5,1
    80200bc4:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80200bc8:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <ebss_clear+0xffffffff7fdd9ff7>
    80200bca:	036a0063          	beq	s4,s6,80200bea <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80200bce:	0149d933          	srl	s2,s3,s4
    80200bd2:	1ff97913          	andi	s2,s2,511
    80200bd6:	090e                	slli	s2,s2,0x3
    80200bd8:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80200bda:	00093483          	ld	s1,0(s2)
    80200bde:	0014f793          	andi	a5,s1,1
    80200be2:	dfd5                	beqz	a5,80200b9e <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80200be4:	80a9                	srli	s1,s1,0xa
    80200be6:	04b2                	slli	s1,s1,0xc
    80200be8:	b7c5                	j	80200bc8 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80200bea:	00c9d513          	srli	a0,s3,0xc
    80200bee:	1ff57513          	andi	a0,a0,511
    80200bf2:	050e                	slli	a0,a0,0x3
    80200bf4:	9526                	add	a0,a0,s1
}
    80200bf6:	70e2                	ld	ra,56(sp)
    80200bf8:	7442                	ld	s0,48(sp)
    80200bfa:	74a2                	ld	s1,40(sp)
    80200bfc:	7902                	ld	s2,32(sp)
    80200bfe:	69e2                	ld	s3,24(sp)
    80200c00:	6a42                	ld	s4,16(sp)
    80200c02:	6aa2                	ld	s5,8(sp)
    80200c04:	6b02                	ld	s6,0(sp)
    80200c06:	6121                	addi	sp,sp,64
    80200c08:	8082                	ret
        return NULL;
    80200c0a:	4501                	li	a0,0
    80200c0c:	b7ed                	j	80200bf6 <walk+0x8e>

0000000080200c0e <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80200c0e:	57fd                	li	a5,-1
    80200c10:	83e9                	srli	a5,a5,0x1a
    80200c12:	00b7f463          	bgeu	a5,a1,80200c1a <walkaddr+0xc>
    return NULL;
    80200c16:	4501                	li	a0,0
    return NULL;
  if((*pte & PTE_U) == 0)
    return NULL;
  pa = PTE2PA(*pte);
  return pa;
}
    80200c18:	8082                	ret
{
    80200c1a:	1141                	addi	sp,sp,-16
    80200c1c:	e406                	sd	ra,8(sp)
    80200c1e:	e022                	sd	s0,0(sp)
    80200c20:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80200c22:	4601                	li	a2,0
    80200c24:	00000097          	auipc	ra,0x0
    80200c28:	f44080e7          	jalr	-188(ra) # 80200b68 <walk>
  if(pte == 0)
    80200c2c:	c105                	beqz	a0,80200c4c <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80200c2e:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80200c30:	0117f693          	andi	a3,a5,17
    80200c34:	4745                	li	a4,17
    return NULL;
    80200c36:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80200c38:	00e68663          	beq	a3,a4,80200c44 <walkaddr+0x36>
}
    80200c3c:	60a2                	ld	ra,8(sp)
    80200c3e:	6402                	ld	s0,0(sp)
    80200c40:	0141                	addi	sp,sp,16
    80200c42:	8082                	ret
  pa = PTE2PA(*pte);
    80200c44:	83a9                	srli	a5,a5,0xa
    80200c46:	00c79513          	slli	a0,a5,0xc
  return pa;
    80200c4a:	bfcd                	j	80200c3c <walkaddr+0x2e>
    return NULL;
    80200c4c:	4501                	li	a0,0
    80200c4e:	b7fd                	j	80200c3c <walkaddr+0x2e>

0000000080200c50 <kwalkaddr>:
  return kwalkaddr(kernel_pagetable, va);
}

uint64
kwalkaddr(pagetable_t kpt, uint64 va)
{
    80200c50:	1101                	addi	sp,sp,-32
    80200c52:	ec06                	sd	ra,24(sp)
    80200c54:	e822                	sd	s0,16(sp)
    80200c56:	e426                	sd	s1,8(sp)
    80200c58:	1000                	addi	s0,sp,32
  uint64 off = va % PGSIZE;
    80200c5a:	03459793          	slli	a5,a1,0x34
    80200c5e:	0347d493          	srli	s1,a5,0x34
  pte_t *pte;
  uint64 pa;
  
  pte = walk(kpt, va, 0);
    80200c62:	4601                	li	a2,0
    80200c64:	00000097          	auipc	ra,0x0
    80200c68:	f04080e7          	jalr	-252(ra) # 80200b68 <walk>
  if(pte == 0)
    80200c6c:	cd09                	beqz	a0,80200c86 <kwalkaddr+0x36>
    panic("kvmpa");
  if((*pte & PTE_V) == 0)
    80200c6e:	6108                	ld	a0,0(a0)
    80200c70:	00157793          	andi	a5,a0,1
    80200c74:	c38d                	beqz	a5,80200c96 <kwalkaddr+0x46>
    panic("kvmpa");
  pa = PTE2PA(*pte);
    80200c76:	8129                	srli	a0,a0,0xa
    80200c78:	0532                	slli	a0,a0,0xc
  return pa+off;
}
    80200c7a:	9526                	add	a0,a0,s1
    80200c7c:	60e2                	ld	ra,24(sp)
    80200c7e:	6442                	ld	s0,16(sp)
    80200c80:	64a2                	ld	s1,8(sp)
    80200c82:	6105                	addi	sp,sp,32
    80200c84:	8082                	ret
    panic("kvmpa");
    80200c86:	00008517          	auipc	a0,0x8
    80200c8a:	76a50513          	addi	a0,a0,1898 # 802093f0 <etext+0x3f0>
    80200c8e:	fffff097          	auipc	ra,0xfffff
    80200c92:	4b8080e7          	jalr	1208(ra) # 80200146 <panic>
    panic("kvmpa");
    80200c96:	00008517          	auipc	a0,0x8
    80200c9a:	75a50513          	addi	a0,a0,1882 # 802093f0 <etext+0x3f0>
    80200c9e:	fffff097          	auipc	ra,0xfffff
    80200ca2:	4a8080e7          	jalr	1192(ra) # 80200146 <panic>

0000000080200ca6 <kvmpa>:
{
    80200ca6:	1141                	addi	sp,sp,-16
    80200ca8:	e406                	sd	ra,8(sp)
    80200caa:	e022                	sd	s0,0(sp)
    80200cac:	0800                	addi	s0,sp,16
    80200cae:	85aa                	mv	a1,a0
  return kwalkaddr(kernel_pagetable, va);
    80200cb0:	00012517          	auipc	a0,0x12
    80200cb4:	3a853503          	ld	a0,936(a0) # 80213058 <kernel_pagetable>
    80200cb8:	00000097          	auipc	ra,0x0
    80200cbc:	f98080e7          	jalr	-104(ra) # 80200c50 <kwalkaddr>
}
    80200cc0:	60a2                	ld	ra,8(sp)
    80200cc2:	6402                	ld	s0,0(sp)
    80200cc4:	0141                	addi	sp,sp,16
    80200cc6:	8082                	ret

0000000080200cc8 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80200cc8:	715d                	addi	sp,sp,-80
    80200cca:	e486                	sd	ra,72(sp)
    80200ccc:	e0a2                	sd	s0,64(sp)
    80200cce:	fc26                	sd	s1,56(sp)
    80200cd0:	f84a                	sd	s2,48(sp)
    80200cd2:	f44e                	sd	s3,40(sp)
    80200cd4:	f052                	sd	s4,32(sp)
    80200cd6:	ec56                	sd	s5,24(sp)
    80200cd8:	e85a                	sd	s6,16(sp)
    80200cda:	e45e                	sd	s7,8(sp)
    80200cdc:	0880                	addi	s0,sp,80
    80200cde:	8aaa                	mv	s5,a0
    80200ce0:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    80200ce2:	777d                	lui	a4,0xfffff
    80200ce4:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80200ce8:	fff60993          	addi	s3,a2,-1 # fff <_entry-0x801ff001>
    80200cec:	99ae                	add	s3,s3,a1
    80200cee:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    80200cf2:	893e                	mv	s2,a5
    80200cf4:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80200cf8:	6b85                	lui	s7,0x1
    80200cfa:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == NULL)
    80200cfe:	4605                	li	a2,1
    80200d00:	85ca                	mv	a1,s2
    80200d02:	8556                	mv	a0,s5
    80200d04:	00000097          	auipc	ra,0x0
    80200d08:	e64080e7          	jalr	-412(ra) # 80200b68 <walk>
    80200d0c:	c51d                	beqz	a0,80200d3a <mappages+0x72>
    if(*pte & PTE_V)
    80200d0e:	611c                	ld	a5,0(a0)
    80200d10:	8b85                	andi	a5,a5,1
    80200d12:	ef81                	bnez	a5,80200d2a <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80200d14:	80b1                	srli	s1,s1,0xc
    80200d16:	04aa                	slli	s1,s1,0xa
    80200d18:	0164e4b3          	or	s1,s1,s6
    80200d1c:	0014e493          	ori	s1,s1,1
    80200d20:	e104                	sd	s1,0(a0)
    if(a == last)
    80200d22:	03390863          	beq	s2,s3,80200d52 <mappages+0x8a>
    a += PGSIZE;
    80200d26:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == NULL)
    80200d28:	bfc9                	j	80200cfa <mappages+0x32>
      panic("remap");
    80200d2a:	00008517          	auipc	a0,0x8
    80200d2e:	6ce50513          	addi	a0,a0,1742 # 802093f8 <etext+0x3f8>
    80200d32:	fffff097          	auipc	ra,0xfffff
    80200d36:	414080e7          	jalr	1044(ra) # 80200146 <panic>
      return -1;
    80200d3a:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80200d3c:	60a6                	ld	ra,72(sp)
    80200d3e:	6406                	ld	s0,64(sp)
    80200d40:	74e2                	ld	s1,56(sp)
    80200d42:	7942                	ld	s2,48(sp)
    80200d44:	79a2                	ld	s3,40(sp)
    80200d46:	7a02                	ld	s4,32(sp)
    80200d48:	6ae2                	ld	s5,24(sp)
    80200d4a:	6b42                	ld	s6,16(sp)
    80200d4c:	6ba2                	ld	s7,8(sp)
    80200d4e:	6161                	addi	sp,sp,80
    80200d50:	8082                	ret
  return 0;
    80200d52:	4501                	li	a0,0
    80200d54:	b7e5                	j	80200d3c <mappages+0x74>

0000000080200d56 <kvmmap>:
{
    80200d56:	1141                	addi	sp,sp,-16
    80200d58:	e406                	sd	ra,8(sp)
    80200d5a:	e022                	sd	s0,0(sp)
    80200d5c:	0800                	addi	s0,sp,16
    80200d5e:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    80200d60:	86ae                	mv	a3,a1
    80200d62:	85aa                	mv	a1,a0
    80200d64:	00012517          	auipc	a0,0x12
    80200d68:	2f453503          	ld	a0,756(a0) # 80213058 <kernel_pagetable>
    80200d6c:	00000097          	auipc	ra,0x0
    80200d70:	f5c080e7          	jalr	-164(ra) # 80200cc8 <mappages>
    80200d74:	e509                	bnez	a0,80200d7e <kvmmap+0x28>
}
    80200d76:	60a2                	ld	ra,8(sp)
    80200d78:	6402                	ld	s0,0(sp)
    80200d7a:	0141                	addi	sp,sp,16
    80200d7c:	8082                	ret
    panic("kvmmap");
    80200d7e:	00008517          	auipc	a0,0x8
    80200d82:	68250513          	addi	a0,a0,1666 # 80209400 <etext+0x400>
    80200d86:	fffff097          	auipc	ra,0xfffff
    80200d8a:	3c0080e7          	jalr	960(ra) # 80200146 <panic>

0000000080200d8e <kvminit>:
{
    80200d8e:	1101                	addi	sp,sp,-32
    80200d90:	ec06                	sd	ra,24(sp)
    80200d92:	e822                	sd	s0,16(sp)
    80200d94:	e426                	sd	s1,8(sp)
    80200d96:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    80200d98:	fffff097          	auipc	ra,0xfffff
    80200d9c:	7ec080e7          	jalr	2028(ra) # 80200584 <kalloc>
    80200da0:	00012717          	auipc	a4,0x12
    80200da4:	2aa73c23          	sd	a0,696(a4) # 80213058 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    80200da8:	6605                	lui	a2,0x1
    80200daa:	4581                	li	a1,0
    80200dac:	00000097          	auipc	ra,0x0
    80200db0:	9e0080e7          	jalr	-1568(ra) # 8020078c <memset>
  kvmmap(UART_V, UART, PGSIZE, PTE_R | PTE_W);
    80200db4:	4699                	li	a3,6
    80200db6:	6605                	lui	a2,0x1
    80200db8:	100005b7          	lui	a1,0x10000
    80200dbc:	3f100513          	li	a0,1009
    80200dc0:	0572                	slli	a0,a0,0x1c
    80200dc2:	00000097          	auipc	ra,0x0
    80200dc6:	f94080e7          	jalr	-108(ra) # 80200d56 <kvmmap>
  kvmmap(VIRTIO0_V, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80200dca:	4699                	li	a3,6
    80200dcc:	6605                	lui	a2,0x1
    80200dce:	100015b7          	lui	a1,0x10001
    80200dd2:	03f10537          	lui	a0,0x3f10
    80200dd6:	0505                	addi	a0,a0,1 # 3f10001 <_entry-0x7c2effff>
    80200dd8:	0532                	slli	a0,a0,0xc
    80200dda:	00000097          	auipc	ra,0x0
    80200dde:	f7c080e7          	jalr	-132(ra) # 80200d56 <kvmmap>
  kvmmap(CLINT_V, CLINT, 0x10000, PTE_R | PTE_W);
    80200de2:	4699                	li	a3,6
    80200de4:	6641                	lui	a2,0x10
    80200de6:	020005b7          	lui	a1,0x2000
    80200dea:	01f81537          	lui	a0,0x1f81
    80200dee:	0536                	slli	a0,a0,0xd
    80200df0:	00000097          	auipc	ra,0x0
    80200df4:	f66080e7          	jalr	-154(ra) # 80200d56 <kvmmap>
  kvmmap(PLIC_V, PLIC, 0x4000, PTE_R | PTE_W);
    80200df8:	4699                	li	a3,6
    80200dfa:	6611                	lui	a2,0x4
    80200dfc:	0c0005b7          	lui	a1,0xc000
    80200e00:	00fc3537          	lui	a0,0xfc3
    80200e04:	053a                	slli	a0,a0,0xe
    80200e06:	00000097          	auipc	ra,0x0
    80200e0a:	f50080e7          	jalr	-176(ra) # 80200d56 <kvmmap>
  kvmmap(PLIC_V + 0x200000, PLIC + 0x200000, 0x4000, PTE_R | PTE_W);
    80200e0e:	4699                	li	a3,6
    80200e10:	6611                	lui	a2,0x4
    80200e12:	0c2005b7          	lui	a1,0xc200
    80200e16:	1f861537          	lui	a0,0x1f861
    80200e1a:	0526                	slli	a0,a0,0x9
    80200e1c:	00000097          	auipc	ra,0x0
    80200e20:	f3a080e7          	jalr	-198(ra) # 80200d56 <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext - KERNBASE, PTE_R | PTE_X);
    80200e24:	00008497          	auipc	s1,0x8
    80200e28:	1dc48493          	addi	s1,s1,476 # 80209000 <etext>
    80200e2c:	bff00613          	li	a2,-1025
    80200e30:	0656                	slli	a2,a2,0x15
    80200e32:	46a9                	li	a3,10
    80200e34:	9626                	add	a2,a2,s1
    80200e36:	40100593          	li	a1,1025
    80200e3a:	05d6                	slli	a1,a1,0x15
    80200e3c:	852e                	mv	a0,a1
    80200e3e:	00000097          	auipc	ra,0x0
    80200e42:	f18080e7          	jalr	-232(ra) # 80200d56 <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP - (uint64)etext, PTE_R | PTE_W);
    80200e46:	40300613          	li	a2,1027
    80200e4a:	0656                	slli	a2,a2,0x15
    80200e4c:	4699                	li	a3,6
    80200e4e:	8e05                	sub	a2,a2,s1
    80200e50:	85a6                	mv	a1,s1
    80200e52:	8526                	mv	a0,s1
    80200e54:	00000097          	auipc	ra,0x0
    80200e58:	f02080e7          	jalr	-254(ra) # 80200d56 <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80200e5c:	46a9                	li	a3,10
    80200e5e:	6605                	lui	a2,0x1
    80200e60:	00007597          	auipc	a1,0x7
    80200e64:	1a058593          	addi	a1,a1,416 # 80208000 <_trampoline>
    80200e68:	04000537          	lui	a0,0x4000
    80200e6c:	157d                	addi	a0,a0,-1 # 3ffffff <_entry-0x7c200001>
    80200e6e:	0532                	slli	a0,a0,0xc
    80200e70:	00000097          	auipc	ra,0x0
    80200e74:	ee6080e7          	jalr	-282(ra) # 80200d56 <kvmmap>
}
    80200e78:	60e2                	ld	ra,24(sp)
    80200e7a:	6442                	ld	s0,16(sp)
    80200e7c:	64a2                	ld	s1,8(sp)
    80200e7e:	6105                	addi	sp,sp,32
    80200e80:	8082                	ret

0000000080200e82 <vmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
vmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80200e82:	715d                	addi	sp,sp,-80
    80200e84:	e486                	sd	ra,72(sp)
    80200e86:	e0a2                	sd	s0,64(sp)
    80200e88:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80200e8a:	03459793          	slli	a5,a1,0x34
    80200e8e:	e39d                	bnez	a5,80200eb4 <vmunmap+0x32>
    80200e90:	f84a                	sd	s2,48(sp)
    80200e92:	f44e                	sd	s3,40(sp)
    80200e94:	f052                	sd	s4,32(sp)
    80200e96:	ec56                	sd	s5,24(sp)
    80200e98:	e85a                	sd	s6,16(sp)
    80200e9a:	e45e                	sd	s7,8(sp)
    80200e9c:	8a2a                	mv	s4,a0
    80200e9e:	892e                	mv	s2,a1
    80200ea0:	8ab6                	mv	s5,a3
    panic("vmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80200ea2:	0632                	slli	a2,a2,0xc
    80200ea4:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("vmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("vmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80200ea8:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80200eaa:	6b05                	lui	s6,0x1
    80200eac:	0935fb63          	bgeu	a1,s3,80200f42 <vmunmap+0xc0>
    80200eb0:	fc26                	sd	s1,56(sp)
    80200eb2:	a8a9                	j	80200f0c <vmunmap+0x8a>
    80200eb4:	fc26                	sd	s1,56(sp)
    80200eb6:	f84a                	sd	s2,48(sp)
    80200eb8:	f44e                	sd	s3,40(sp)
    80200eba:	f052                	sd	s4,32(sp)
    80200ebc:	ec56                	sd	s5,24(sp)
    80200ebe:	e85a                	sd	s6,16(sp)
    80200ec0:	e45e                	sd	s7,8(sp)
    panic("vmunmap: not aligned");
    80200ec2:	00008517          	auipc	a0,0x8
    80200ec6:	54650513          	addi	a0,a0,1350 # 80209408 <etext+0x408>
    80200eca:	fffff097          	auipc	ra,0xfffff
    80200ece:	27c080e7          	jalr	636(ra) # 80200146 <panic>
      panic("vmunmap: walk");
    80200ed2:	00008517          	auipc	a0,0x8
    80200ed6:	54e50513          	addi	a0,a0,1358 # 80209420 <etext+0x420>
    80200eda:	fffff097          	auipc	ra,0xfffff
    80200ede:	26c080e7          	jalr	620(ra) # 80200146 <panic>
      panic("vmunmap: not mapped");
    80200ee2:	00008517          	auipc	a0,0x8
    80200ee6:	54e50513          	addi	a0,a0,1358 # 80209430 <etext+0x430>
    80200eea:	fffff097          	auipc	ra,0xfffff
    80200eee:	25c080e7          	jalr	604(ra) # 80200146 <panic>
      panic("vmunmap: not a leaf");
    80200ef2:	00008517          	auipc	a0,0x8
    80200ef6:	55650513          	addi	a0,a0,1366 # 80209448 <etext+0x448>
    80200efa:	fffff097          	auipc	ra,0xfffff
    80200efe:	24c080e7          	jalr	588(ra) # 80200146 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    80200f02:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80200f06:	995a                	add	s2,s2,s6
    80200f08:	03397c63          	bgeu	s2,s3,80200f40 <vmunmap+0xbe>
    if((pte = walk(pagetable, a, 0)) == 0)
    80200f0c:	4601                	li	a2,0
    80200f0e:	85ca                	mv	a1,s2
    80200f10:	8552                	mv	a0,s4
    80200f12:	00000097          	auipc	ra,0x0
    80200f16:	c56080e7          	jalr	-938(ra) # 80200b68 <walk>
    80200f1a:	84aa                	mv	s1,a0
    80200f1c:	d95d                	beqz	a0,80200ed2 <vmunmap+0x50>
    if((*pte & PTE_V) == 0)
    80200f1e:	6108                	ld	a0,0(a0)
    80200f20:	00157793          	andi	a5,a0,1
    80200f24:	dfdd                	beqz	a5,80200ee2 <vmunmap+0x60>
    if(PTE_FLAGS(*pte) == PTE_V)
    80200f26:	3ff57793          	andi	a5,a0,1023
    80200f2a:	fd7784e3          	beq	a5,s7,80200ef2 <vmunmap+0x70>
    if(do_free){
    80200f2e:	fc0a8ae3          	beqz	s5,80200f02 <vmunmap+0x80>
      uint64 pa = PTE2PA(*pte);
    80200f32:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80200f34:	0532                	slli	a0,a0,0xc
    80200f36:	fffff097          	auipc	ra,0xfffff
    80200f3a:	534080e7          	jalr	1332(ra) # 8020046a <kfree>
    80200f3e:	b7d1                	j	80200f02 <vmunmap+0x80>
    80200f40:	74e2                	ld	s1,56(sp)
    80200f42:	7942                	ld	s2,48(sp)
    80200f44:	79a2                	ld	s3,40(sp)
    80200f46:	7a02                	ld	s4,32(sp)
    80200f48:	6ae2                	ld	s5,24(sp)
    80200f4a:	6b42                	ld	s6,16(sp)
    80200f4c:	6ba2                	ld	s7,8(sp)
  }
}
    80200f4e:	60a6                	ld	ra,72(sp)
    80200f50:	6406                	ld	s0,64(sp)
    80200f52:	6161                	addi	sp,sp,80
    80200f54:	8082                	ret

0000000080200f56 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80200f56:	1101                	addi	sp,sp,-32
    80200f58:	ec06                	sd	ra,24(sp)
    80200f5a:	e822                	sd	s0,16(sp)
    80200f5c:	e426                	sd	s1,8(sp)
    80200f5e:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80200f60:	fffff097          	auipc	ra,0xfffff
    80200f64:	624080e7          	jalr	1572(ra) # 80200584 <kalloc>
    80200f68:	84aa                	mv	s1,a0
  if(pagetable == NULL)
    80200f6a:	c519                	beqz	a0,80200f78 <uvmcreate+0x22>
    return NULL;
  memset(pagetable, 0, PGSIZE);
    80200f6c:	6605                	lui	a2,0x1
    80200f6e:	4581                	li	a1,0
    80200f70:	00000097          	auipc	ra,0x0
    80200f74:	81c080e7          	jalr	-2020(ra) # 8020078c <memset>
  return pagetable;
}
    80200f78:	8526                	mv	a0,s1
    80200f7a:	60e2                	ld	ra,24(sp)
    80200f7c:	6442                	ld	s0,16(sp)
    80200f7e:	64a2                	ld	s1,8(sp)
    80200f80:	6105                	addi	sp,sp,32
    80200f82:	8082                	ret

0000000080200f84 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, pagetable_t kpagetable, uchar *src, uint sz)
{
    80200f84:	7139                	addi	sp,sp,-64
    80200f86:	fc06                	sd	ra,56(sp)
    80200f88:	f822                	sd	s0,48(sp)
    80200f8a:	f426                	sd	s1,40(sp)
    80200f8c:	f04a                	sd	s2,32(sp)
    80200f8e:	ec4e                	sd	s3,24(sp)
    80200f90:	e852                	sd	s4,16(sp)
    80200f92:	e456                	sd	s5,8(sp)
    80200f94:	0080                	addi	s0,sp,64
  char *mem;

  if(sz >= PGSIZE)
    80200f96:	6785                	lui	a5,0x1
    80200f98:	06f6f363          	bgeu	a3,a5,80200ffe <uvminit+0x7a>
    80200f9c:	8aaa                	mv	s5,a0
    80200f9e:	8a2e                	mv	s4,a1
    80200fa0:	89b2                	mv	s3,a2
    80200fa2:	8936                	mv	s2,a3
    panic("inituvm: more than a page");
  mem = kalloc();
    80200fa4:	fffff097          	auipc	ra,0xfffff
    80200fa8:	5e0080e7          	jalr	1504(ra) # 80200584 <kalloc>
    80200fac:	84aa                	mv	s1,a0
  // printf("[uvminit]kalloc: %p\n", mem);
  memset(mem, 0, PGSIZE);
    80200fae:	6605                	lui	a2,0x1
    80200fb0:	4581                	li	a1,0
    80200fb2:	fffff097          	auipc	ra,0xfffff
    80200fb6:	7da080e7          	jalr	2010(ra) # 8020078c <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80200fba:	4779                	li	a4,30
    80200fbc:	86a6                	mv	a3,s1
    80200fbe:	6605                	lui	a2,0x1
    80200fc0:	4581                	li	a1,0
    80200fc2:	8556                	mv	a0,s5
    80200fc4:	00000097          	auipc	ra,0x0
    80200fc8:	d04080e7          	jalr	-764(ra) # 80200cc8 <mappages>
  mappages(kpagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X);
    80200fcc:	4739                	li	a4,14
    80200fce:	86a6                	mv	a3,s1
    80200fd0:	6605                	lui	a2,0x1
    80200fd2:	4581                	li	a1,0
    80200fd4:	8552                	mv	a0,s4
    80200fd6:	00000097          	auipc	ra,0x0
    80200fda:	cf2080e7          	jalr	-782(ra) # 80200cc8 <mappages>
  memmove(mem, src, sz);
    80200fde:	864a                	mv	a2,s2
    80200fe0:	85ce                	mv	a1,s3
    80200fe2:	8526                	mv	a0,s1
    80200fe4:	00000097          	auipc	ra,0x0
    80200fe8:	804080e7          	jalr	-2044(ra) # 802007e8 <memmove>
  // for (int i = 0; i < sz; i ++) {
  //   printf("[uvminit]mem: %p, %x\n", mem + i, mem[i]);
  // }
}
    80200fec:	70e2                	ld	ra,56(sp)
    80200fee:	7442                	ld	s0,48(sp)
    80200ff0:	74a2                	ld	s1,40(sp)
    80200ff2:	7902                	ld	s2,32(sp)
    80200ff4:	69e2                	ld	s3,24(sp)
    80200ff6:	6a42                	ld	s4,16(sp)
    80200ff8:	6aa2                	ld	s5,8(sp)
    80200ffa:	6121                	addi	sp,sp,64
    80200ffc:	8082                	ret
    panic("inituvm: more than a page");
    80200ffe:	00008517          	auipc	a0,0x8
    80201002:	46250513          	addi	a0,a0,1122 # 80209460 <etext+0x460>
    80201006:	fffff097          	auipc	ra,0xfffff
    8020100a:	140080e7          	jalr	320(ra) # 80200146 <panic>

000000008020100e <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, pagetable_t kpagetable, uint64 oldsz, uint64 newsz)
{
    8020100e:	7179                	addi	sp,sp,-48
    80201010:	f406                	sd	ra,40(sp)
    80201012:	f022                	sd	s0,32(sp)
    80201014:	e84a                	sd	s2,16(sp)
    80201016:	1800                	addi	s0,sp,48
  if(newsz >= oldsz)
    return oldsz;
    80201018:	8932                	mv	s2,a2
  if(newsz >= oldsz)
    8020101a:	02c6f463          	bgeu	a3,a2,80201042 <uvmdealloc+0x34>
    8020101e:	e44e                	sd	s3,8(sp)
    80201020:	e052                	sd	s4,0(sp)
    80201022:	89aa                	mv	s3,a0
    80201024:	852e                	mv	a0,a1
    80201026:	8936                	mv	s2,a3

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80201028:	6785                	lui	a5,0x1
    8020102a:	17fd                	addi	a5,a5,-1 # fff <_entry-0x801ff001>
    8020102c:	00f68a33          	add	s4,a3,a5
    80201030:	777d                	lui	a4,0xfffff
    80201032:	00ea7a33          	and	s4,s4,a4
    80201036:	963e                	add	a2,a2,a5
    80201038:	8e79                	and	a2,a2,a4
    8020103a:	00ca6a63          	bltu	s4,a2,8020104e <uvmdealloc+0x40>
    8020103e:	69a2                	ld	s3,8(sp)
    80201040:	6a02                	ld	s4,0(sp)
    vmunmap(kpagetable, PGROUNDUP(newsz), npages, 0);
    vmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80201042:	854a                	mv	a0,s2
    80201044:	70a2                	ld	ra,40(sp)
    80201046:	7402                	ld	s0,32(sp)
    80201048:	6942                	ld	s2,16(sp)
    8020104a:	6145                	addi	sp,sp,48
    8020104c:	8082                	ret
    8020104e:	ec26                	sd	s1,24(sp)
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80201050:	414604b3          	sub	s1,a2,s4
    80201054:	80b1                	srli	s1,s1,0xc
    vmunmap(kpagetable, PGROUNDUP(newsz), npages, 0);
    80201056:	2481                	sext.w	s1,s1
    80201058:	4681                	li	a3,0
    8020105a:	8626                	mv	a2,s1
    8020105c:	85d2                	mv	a1,s4
    8020105e:	00000097          	auipc	ra,0x0
    80201062:	e24080e7          	jalr	-476(ra) # 80200e82 <vmunmap>
    vmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80201066:	4685                	li	a3,1
    80201068:	8626                	mv	a2,s1
    8020106a:	85d2                	mv	a1,s4
    8020106c:	854e                	mv	a0,s3
    8020106e:	00000097          	auipc	ra,0x0
    80201072:	e14080e7          	jalr	-492(ra) # 80200e82 <vmunmap>
    80201076:	64e2                	ld	s1,24(sp)
    80201078:	69a2                	ld	s3,8(sp)
    8020107a:	6a02                	ld	s4,0(sp)
    8020107c:	b7d9                	j	80201042 <uvmdealloc+0x34>

000000008020107e <uvmalloc>:
  if(newsz < oldsz)
    8020107e:	0ec6ed63          	bltu	a3,a2,80201178 <uvmalloc+0xfa>
{
    80201082:	7139                	addi	sp,sp,-64
    80201084:	fc06                	sd	ra,56(sp)
    80201086:	f822                	sd	s0,48(sp)
    80201088:	ec4e                	sd	s3,24(sp)
    8020108a:	e852                	sd	s4,16(sp)
    8020108c:	e456                	sd	s5,8(sp)
    8020108e:	e05a                	sd	s6,0(sp)
    80201090:	0080                	addi	s0,sp,64
    80201092:	8a2a                	mv	s4,a0
    80201094:	8aae                	mv	s5,a1
    80201096:	8b36                	mv	s6,a3
  oldsz = PGROUNDUP(oldsz);
    80201098:	6785                	lui	a5,0x1
    8020109a:	17fd                	addi	a5,a5,-1 # fff <_entry-0x801ff001>
    8020109c:	963e                	add	a2,a2,a5
    8020109e:	77fd                	lui	a5,0xfffff
    802010a0:	00f679b3          	and	s3,a2,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    802010a4:	0cd9fc63          	bgeu	s3,a3,8020117c <uvmalloc+0xfe>
    802010a8:	f426                	sd	s1,40(sp)
    802010aa:	f04a                	sd	s2,32(sp)
    802010ac:	894e                	mv	s2,s3
    mem = kalloc();
    802010ae:	fffff097          	auipc	ra,0xfffff
    802010b2:	4d6080e7          	jalr	1238(ra) # 80200584 <kalloc>
    802010b6:	84aa                	mv	s1,a0
    if(mem == NULL){
    802010b8:	c139                	beqz	a0,802010fe <uvmalloc+0x80>
    memset(mem, 0, PGSIZE);
    802010ba:	6605                	lui	a2,0x1
    802010bc:	4581                	li	a1,0
    802010be:	fffff097          	auipc	ra,0xfffff
    802010c2:	6ce080e7          	jalr	1742(ra) # 8020078c <memset>
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0) {
    802010c6:	4779                	li	a4,30
    802010c8:	86a6                	mv	a3,s1
    802010ca:	6605                	lui	a2,0x1
    802010cc:	85ca                	mv	a1,s2
    802010ce:	8552                	mv	a0,s4
    802010d0:	00000097          	auipc	ra,0x0
    802010d4:	bf8080e7          	jalr	-1032(ra) # 80200cc8 <mappages>
    802010d8:	e531                	bnez	a0,80201124 <uvmalloc+0xa6>
    if (mappages(kpagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R) != 0){
    802010da:	4739                	li	a4,14
    802010dc:	86a6                	mv	a3,s1
    802010de:	6605                	lui	a2,0x1
    802010e0:	85ca                	mv	a1,s2
    802010e2:	8556                	mv	a0,s5
    802010e4:	00000097          	auipc	ra,0x0
    802010e8:	be4080e7          	jalr	-1052(ra) # 80200cc8 <mappages>
    802010ec:	ed29                	bnez	a0,80201146 <uvmalloc+0xc8>
  for(a = oldsz; a < newsz; a += PGSIZE){
    802010ee:	6785                	lui	a5,0x1
    802010f0:	993e                	add	s2,s2,a5
    802010f2:	fb696ee3          	bltu	s2,s6,802010ae <uvmalloc+0x30>
  return newsz;
    802010f6:	855a                	mv	a0,s6
    802010f8:	74a2                	ld	s1,40(sp)
    802010fa:	7902                	ld	s2,32(sp)
    802010fc:	a821                	j	80201114 <uvmalloc+0x96>
      uvmdealloc(pagetable, kpagetable, a, oldsz);
    802010fe:	86ce                	mv	a3,s3
    80201100:	864a                	mv	a2,s2
    80201102:	85d6                	mv	a1,s5
    80201104:	8552                	mv	a0,s4
    80201106:	00000097          	auipc	ra,0x0
    8020110a:	f08080e7          	jalr	-248(ra) # 8020100e <uvmdealloc>
      return 0;
    8020110e:	4501                	li	a0,0
    80201110:	74a2                	ld	s1,40(sp)
    80201112:	7902                	ld	s2,32(sp)
}
    80201114:	70e2                	ld	ra,56(sp)
    80201116:	7442                	ld	s0,48(sp)
    80201118:	69e2                	ld	s3,24(sp)
    8020111a:	6a42                	ld	s4,16(sp)
    8020111c:	6aa2                	ld	s5,8(sp)
    8020111e:	6b02                	ld	s6,0(sp)
    80201120:	6121                	addi	sp,sp,64
    80201122:	8082                	ret
      kfree(mem);
    80201124:	8526                	mv	a0,s1
    80201126:	fffff097          	auipc	ra,0xfffff
    8020112a:	344080e7          	jalr	836(ra) # 8020046a <kfree>
      uvmdealloc(pagetable, kpagetable, a, oldsz);
    8020112e:	86ce                	mv	a3,s3
    80201130:	864a                	mv	a2,s2
    80201132:	85d6                	mv	a1,s5
    80201134:	8552                	mv	a0,s4
    80201136:	00000097          	auipc	ra,0x0
    8020113a:	ed8080e7          	jalr	-296(ra) # 8020100e <uvmdealloc>
      return 0;
    8020113e:	4501                	li	a0,0
    80201140:	74a2                	ld	s1,40(sp)
    80201142:	7902                	ld	s2,32(sp)
    80201144:	bfc1                	j	80201114 <uvmalloc+0x96>
      int npages = (a - oldsz) / PGSIZE;
    80201146:	41390633          	sub	a2,s2,s3
    8020114a:	8231                	srli	a2,a2,0xc
    8020114c:	0006049b          	sext.w	s1,a2
      vmunmap(pagetable, oldsz, npages + 1, 1);   // plus the page allocated above.
    80201150:	4685                	li	a3,1
    80201152:	2605                	addiw	a2,a2,1 # 1001 <_entry-0x801fefff>
    80201154:	85ce                	mv	a1,s3
    80201156:	8552                	mv	a0,s4
    80201158:	00000097          	auipc	ra,0x0
    8020115c:	d2a080e7          	jalr	-726(ra) # 80200e82 <vmunmap>
      vmunmap(kpagetable, oldsz, npages, 0);
    80201160:	4681                	li	a3,0
    80201162:	8626                	mv	a2,s1
    80201164:	85ce                	mv	a1,s3
    80201166:	8556                	mv	a0,s5
    80201168:	00000097          	auipc	ra,0x0
    8020116c:	d1a080e7          	jalr	-742(ra) # 80200e82 <vmunmap>
      return 0;
    80201170:	4501                	li	a0,0
    80201172:	74a2                	ld	s1,40(sp)
    80201174:	7902                	ld	s2,32(sp)
    80201176:	bf79                	j	80201114 <uvmalloc+0x96>
    return oldsz;
    80201178:	8532                	mv	a0,a2
}
    8020117a:	8082                	ret
  return newsz;
    8020117c:	8536                	mv	a0,a3
    8020117e:	bf59                	j	80201114 <uvmalloc+0x96>

0000000080201180 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80201180:	7179                	addi	sp,sp,-48
    80201182:	f406                	sd	ra,40(sp)
    80201184:	f022                	sd	s0,32(sp)
    80201186:	ec26                	sd	s1,24(sp)
    80201188:	e84a                	sd	s2,16(sp)
    8020118a:	e44e                	sd	s3,8(sp)
    8020118c:	e052                	sd	s4,0(sp)
    8020118e:	1800                	addi	s0,sp,48
    80201190:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80201192:	84aa                	mv	s1,a0
    80201194:	6905                	lui	s2,0x1
    80201196:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80201198:	4985                	li	s3,1
    8020119a:	a829                	j	802011b4 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8020119c:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    8020119e:	00c79513          	slli	a0,a5,0xc
    802011a2:	00000097          	auipc	ra,0x0
    802011a6:	fde080e7          	jalr	-34(ra) # 80201180 <freewalk>
      pagetable[i] = 0;
    802011aa:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    802011ae:	04a1                	addi	s1,s1,8
    802011b0:	03248163          	beq	s1,s2,802011d2 <freewalk+0x52>
    pte_t pte = pagetable[i];
    802011b4:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    802011b6:	00f7f713          	andi	a4,a5,15
    802011ba:	ff3701e3          	beq	a4,s3,8020119c <freewalk+0x1c>
    } else if(pte & PTE_V){
    802011be:	8b85                	andi	a5,a5,1
    802011c0:	d7fd                	beqz	a5,802011ae <freewalk+0x2e>
      panic("freewalk: leaf");
    802011c2:	00008517          	auipc	a0,0x8
    802011c6:	2be50513          	addi	a0,a0,702 # 80209480 <etext+0x480>
    802011ca:	fffff097          	auipc	ra,0xfffff
    802011ce:	f7c080e7          	jalr	-132(ra) # 80200146 <panic>
    }
  }
  kfree((void*)pagetable);
    802011d2:	8552                	mv	a0,s4
    802011d4:	fffff097          	auipc	ra,0xfffff
    802011d8:	296080e7          	jalr	662(ra) # 8020046a <kfree>
}
    802011dc:	70a2                	ld	ra,40(sp)
    802011de:	7402                	ld	s0,32(sp)
    802011e0:	64e2                	ld	s1,24(sp)
    802011e2:	6942                	ld	s2,16(sp)
    802011e4:	69a2                	ld	s3,8(sp)
    802011e6:	6a02                	ld	s4,0(sp)
    802011e8:	6145                	addi	sp,sp,48
    802011ea:	8082                	ret

00000000802011ec <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    802011ec:	1101                	addi	sp,sp,-32
    802011ee:	ec06                	sd	ra,24(sp)
    802011f0:	e822                	sd	s0,16(sp)
    802011f2:	e426                	sd	s1,8(sp)
    802011f4:	1000                	addi	s0,sp,32
    802011f6:	84aa                	mv	s1,a0
  if(sz > 0)
    802011f8:	e999                	bnez	a1,8020120e <uvmfree+0x22>
    vmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    802011fa:	8526                	mv	a0,s1
    802011fc:	00000097          	auipc	ra,0x0
    80201200:	f84080e7          	jalr	-124(ra) # 80201180 <freewalk>
}
    80201204:	60e2                	ld	ra,24(sp)
    80201206:	6442                	ld	s0,16(sp)
    80201208:	64a2                	ld	s1,8(sp)
    8020120a:	6105                	addi	sp,sp,32
    8020120c:	8082                	ret
    vmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8020120e:	6785                	lui	a5,0x1
    80201210:	17fd                	addi	a5,a5,-1 # fff <_entry-0x801ff001>
    80201212:	95be                	add	a1,a1,a5
    80201214:	4685                	li	a3,1
    80201216:	00c5d613          	srli	a2,a1,0xc
    8020121a:	4581                	li	a1,0
    8020121c:	00000097          	auipc	ra,0x0
    80201220:	c66080e7          	jalr	-922(ra) # 80200e82 <vmunmap>
    80201224:	bfd9                	j	802011fa <uvmfree+0xe>

0000000080201226 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i = 0, ki = 0;
  uint flags;
  char *mem;

  while (i < sz){
    80201226:	10068863          	beqz	a3,80201336 <uvmcopy+0x110>
{
    8020122a:	711d                	addi	sp,sp,-96
    8020122c:	ec86                	sd	ra,88(sp)
    8020122e:	e8a2                	sd	s0,80(sp)
    80201230:	e4a6                	sd	s1,72(sp)
    80201232:	e0ca                	sd	s2,64(sp)
    80201234:	fc4e                	sd	s3,56(sp)
    80201236:	f852                	sd	s4,48(sp)
    80201238:	f456                	sd	s5,40(sp)
    8020123a:	f05a                	sd	s6,32(sp)
    8020123c:	ec5e                	sd	s7,24(sp)
    8020123e:	e862                	sd	s8,16(sp)
    80201240:	e466                	sd	s9,8(sp)
    80201242:	1080                	addi	s0,sp,96
    80201244:	8baa                	mv	s7,a0
    80201246:	8a2e                	mv	s4,a1
    80201248:	8b32                	mv	s6,a2
    8020124a:	8ab6                	mv	s5,a3
  uint64 pa, i = 0, ki = 0;
    8020124c:	4981                	li	s3,0
    8020124e:	a011                	j	80201252 <uvmcopy+0x2c>
    80201250:	89a6                	mv	s3,s1
    if((pte = walk(old, i, 0)) == NULL)
    80201252:	4601                	li	a2,0
    80201254:	85ce                	mv	a1,s3
    80201256:	855e                	mv	a0,s7
    80201258:	00000097          	auipc	ra,0x0
    8020125c:	910080e7          	jalr	-1776(ra) # 80200b68 <walk>
    80201260:	c13d                	beqz	a0,802012c6 <uvmcopy+0xa0>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80201262:	6118                	ld	a4,0(a0)
    80201264:	00177793          	andi	a5,a4,1
    80201268:	c7bd                	beqz	a5,802012d6 <uvmcopy+0xb0>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8020126a:	00a75593          	srli	a1,a4,0xa
    8020126e:	00c59c93          	slli	s9,a1,0xc
    flags = PTE_FLAGS(*pte);
    80201272:	00070c1b          	sext.w	s8,a4
    80201276:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == NULL)
    8020127a:	fffff097          	auipc	ra,0xfffff
    8020127e:	30a080e7          	jalr	778(ra) # 80200584 <kalloc>
    80201282:	892a                	mv	s2,a0
    80201284:	c925                	beqz	a0,802012f4 <uvmcopy+0xce>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80201286:	6605                	lui	a2,0x1
    80201288:	85e6                	mv	a1,s9
    8020128a:	fffff097          	auipc	ra,0xfffff
    8020128e:	55e080e7          	jalr	1374(ra) # 802007e8 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0) {
    80201292:	8726                	mv	a4,s1
    80201294:	86ca                	mv	a3,s2
    80201296:	6605                	lui	a2,0x1
    80201298:	85ce                	mv	a1,s3
    8020129a:	8552                	mv	a0,s4
    8020129c:	00000097          	auipc	ra,0x0
    802012a0:	a2c080e7          	jalr	-1492(ra) # 80200cc8 <mappages>
    802012a4:	e129                	bnez	a0,802012e6 <uvmcopy+0xc0>
      kfree(mem);
      goto err;
    }
    i += PGSIZE;
    802012a6:	6485                	lui	s1,0x1
    802012a8:	94ce                	add	s1,s1,s3
    if(mappages(knew, ki, PGSIZE, (uint64)mem, flags & ~PTE_U) != 0){
    802012aa:	3efc7713          	andi	a4,s8,1007
    802012ae:	86ca                	mv	a3,s2
    802012b0:	6605                	lui	a2,0x1
    802012b2:	85ce                	mv	a1,s3
    802012b4:	855a                	mv	a0,s6
    802012b6:	00000097          	auipc	ra,0x0
    802012ba:	a12080e7          	jalr	-1518(ra) # 80200cc8 <mappages>
    802012be:	ed05                	bnez	a0,802012f6 <uvmcopy+0xd0>
  while (i < sz){
    802012c0:	f954e8e3          	bltu	s1,s5,80201250 <uvmcopy+0x2a>
    802012c4:	a8a1                	j	8020131c <uvmcopy+0xf6>
      panic("uvmcopy: pte should exist");
    802012c6:	00008517          	auipc	a0,0x8
    802012ca:	1ca50513          	addi	a0,a0,458 # 80209490 <etext+0x490>
    802012ce:	fffff097          	auipc	ra,0xfffff
    802012d2:	e78080e7          	jalr	-392(ra) # 80200146 <panic>
      panic("uvmcopy: page not present");
    802012d6:	00008517          	auipc	a0,0x8
    802012da:	1da50513          	addi	a0,a0,474 # 802094b0 <etext+0x4b0>
    802012de:	fffff097          	auipc	ra,0xfffff
    802012e2:	e68080e7          	jalr	-408(ra) # 80200146 <panic>
      kfree(mem);
    802012e6:	854a                	mv	a0,s2
    802012e8:	fffff097          	auipc	ra,0xfffff
    802012ec:	182080e7          	jalr	386(ra) # 8020046a <kfree>
      goto err;
    802012f0:	84ce                	mv	s1,s3
    802012f2:	a011                	j	802012f6 <uvmcopy+0xd0>
    802012f4:	84ce                	mv	s1,s3
    ki += PGSIZE;
  }
  return 0;

 err:
  vmunmap(knew, 0, ki / PGSIZE, 0);
    802012f6:	4681                	li	a3,0
    802012f8:	00c9d613          	srli	a2,s3,0xc
    802012fc:	4581                	li	a1,0
    802012fe:	855a                	mv	a0,s6
    80201300:	00000097          	auipc	ra,0x0
    80201304:	b82080e7          	jalr	-1150(ra) # 80200e82 <vmunmap>
  vmunmap(new, 0, i / PGSIZE, 1);
    80201308:	4685                	li	a3,1
    8020130a:	00c4d613          	srli	a2,s1,0xc
    8020130e:	4581                	li	a1,0
    80201310:	8552                	mv	a0,s4
    80201312:	00000097          	auipc	ra,0x0
    80201316:	b70080e7          	jalr	-1168(ra) # 80200e82 <vmunmap>
  return -1;
    8020131a:	557d                	li	a0,-1
}
    8020131c:	60e6                	ld	ra,88(sp)
    8020131e:	6446                	ld	s0,80(sp)
    80201320:	64a6                	ld	s1,72(sp)
    80201322:	6906                	ld	s2,64(sp)
    80201324:	79e2                	ld	s3,56(sp)
    80201326:	7a42                	ld	s4,48(sp)
    80201328:	7aa2                	ld	s5,40(sp)
    8020132a:	7b02                	ld	s6,32(sp)
    8020132c:	6be2                	ld	s7,24(sp)
    8020132e:	6c42                	ld	s8,16(sp)
    80201330:	6ca2                	ld	s9,8(sp)
    80201332:	6125                	addi	sp,sp,96
    80201334:	8082                	ret
  return 0;
    80201336:	4501                	li	a0,0
}
    80201338:	8082                	ret

000000008020133a <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8020133a:	1141                	addi	sp,sp,-16
    8020133c:	e406                	sd	ra,8(sp)
    8020133e:	e022                	sd	s0,0(sp)
    80201340:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80201342:	4601                	li	a2,0
    80201344:	00000097          	auipc	ra,0x0
    80201348:	824080e7          	jalr	-2012(ra) # 80200b68 <walk>
  if(pte == NULL)
    8020134c:	c901                	beqz	a0,8020135c <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8020134e:	611c                	ld	a5,0(a0)
    80201350:	9bbd                	andi	a5,a5,-17
    80201352:	e11c                	sd	a5,0(a0)
}
    80201354:	60a2                	ld	ra,8(sp)
    80201356:	6402                	ld	s0,0(sp)
    80201358:	0141                	addi	sp,sp,16
    8020135a:	8082                	ret
    panic("uvmclear");
    8020135c:	00008517          	auipc	a0,0x8
    80201360:	17450513          	addi	a0,a0,372 # 802094d0 <etext+0x4d0>
    80201364:	fffff097          	auipc	ra,0xfffff
    80201368:	de2080e7          	jalr	-542(ra) # 80200146 <panic>

000000008020136c <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8020136c:	c6bd                	beqz	a3,802013da <copyout+0x6e>
{
    8020136e:	715d                	addi	sp,sp,-80
    80201370:	e486                	sd	ra,72(sp)
    80201372:	e0a2                	sd	s0,64(sp)
    80201374:	fc26                	sd	s1,56(sp)
    80201376:	f84a                	sd	s2,48(sp)
    80201378:	f44e                	sd	s3,40(sp)
    8020137a:	f052                	sd	s4,32(sp)
    8020137c:	ec56                	sd	s5,24(sp)
    8020137e:	e85a                	sd	s6,16(sp)
    80201380:	e45e                	sd	s7,8(sp)
    80201382:	e062                	sd	s8,0(sp)
    80201384:	0880                	addi	s0,sp,80
    80201386:	8b2a                	mv	s6,a0
    80201388:	8c2e                	mv	s8,a1
    8020138a:	8a32                	mv	s4,a2
    8020138c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8020138e:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == NULL)
      return -1;
    n = PGSIZE - (dstva - va0);
    80201390:	6a85                	lui	s5,0x1
    80201392:	a015                	j	802013b6 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80201394:	9562                	add	a0,a0,s8
    80201396:	0004861b          	sext.w	a2,s1
    8020139a:	85d2                	mv	a1,s4
    8020139c:	41250533          	sub	a0,a0,s2
    802013a0:	fffff097          	auipc	ra,0xfffff
    802013a4:	448080e7          	jalr	1096(ra) # 802007e8 <memmove>

    len -= n;
    802013a8:	409989b3          	sub	s3,s3,s1
    src += n;
    802013ac:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    802013ae:	01590c33          	add	s8,s2,s5
  while(len > 0){
    802013b2:	02098263          	beqz	s3,802013d6 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    802013b6:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    802013ba:	85ca                	mv	a1,s2
    802013bc:	855a                	mv	a0,s6
    802013be:	00000097          	auipc	ra,0x0
    802013c2:	850080e7          	jalr	-1968(ra) # 80200c0e <walkaddr>
    if(pa0 == NULL)
    802013c6:	cd01                	beqz	a0,802013de <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    802013c8:	418904b3          	sub	s1,s2,s8
    802013cc:	94d6                	add	s1,s1,s5
    if(n > len)
    802013ce:	fc99f3e3          	bgeu	s3,s1,80201394 <copyout+0x28>
    802013d2:	84ce                	mv	s1,s3
    802013d4:	b7c1                	j	80201394 <copyout+0x28>
  }
  return 0;
    802013d6:	4501                	li	a0,0
    802013d8:	a021                	j	802013e0 <copyout+0x74>
    802013da:	4501                	li	a0,0
}
    802013dc:	8082                	ret
      return -1;
    802013de:	557d                	li	a0,-1
}
    802013e0:	60a6                	ld	ra,72(sp)
    802013e2:	6406                	ld	s0,64(sp)
    802013e4:	74e2                	ld	s1,56(sp)
    802013e6:	7942                	ld	s2,48(sp)
    802013e8:	79a2                	ld	s3,40(sp)
    802013ea:	7a02                	ld	s4,32(sp)
    802013ec:	6ae2                	ld	s5,24(sp)
    802013ee:	6b42                	ld	s6,16(sp)
    802013f0:	6ba2                	ld	s7,8(sp)
    802013f2:	6c02                	ld	s8,0(sp)
    802013f4:	6161                	addi	sp,sp,80
    802013f6:	8082                	ret

00000000802013f8 <copyout2>:

int
copyout2(uint64 dstva, char *src, uint64 len)
{
    802013f8:	7179                	addi	sp,sp,-48
    802013fa:	f406                	sd	ra,40(sp)
    802013fc:	f022                	sd	s0,32(sp)
    802013fe:	ec26                	sd	s1,24(sp)
    80201400:	e84a                	sd	s2,16(sp)
    80201402:	e44e                	sd	s3,8(sp)
    80201404:	1800                	addi	s0,sp,48
    80201406:	84aa                	mv	s1,a0
    80201408:	89ae                	mv	s3,a1
    8020140a:	8932                	mv	s2,a2
  uint64 sz = myproc()->sz;
    8020140c:	00000097          	auipc	ra,0x0
    80201410:	6c2080e7          	jalr	1730(ra) # 80201ace <myproc>
    80201414:	653c                	ld	a5,72(a0)
  if (dstva + len > sz || dstva >= sz) {
    80201416:	01248733          	add	a4,s1,s2
    8020141a:	02e7e463          	bltu	a5,a4,80201442 <copyout2+0x4a>
    8020141e:	02f4f463          	bgeu	s1,a5,80201446 <copyout2+0x4e>
    return -1;
  }
  memmove((void *)dstva, src, len);
    80201422:	0009061b          	sext.w	a2,s2
    80201426:	85ce                	mv	a1,s3
    80201428:	8526                	mv	a0,s1
    8020142a:	fffff097          	auipc	ra,0xfffff
    8020142e:	3be080e7          	jalr	958(ra) # 802007e8 <memmove>
  return 0;
    80201432:	4501                	li	a0,0
}
    80201434:	70a2                	ld	ra,40(sp)
    80201436:	7402                	ld	s0,32(sp)
    80201438:	64e2                	ld	s1,24(sp)
    8020143a:	6942                	ld	s2,16(sp)
    8020143c:	69a2                	ld	s3,8(sp)
    8020143e:	6145                	addi	sp,sp,48
    80201440:	8082                	ret
    return -1;
    80201442:	557d                	li	a0,-1
    80201444:	bfc5                	j	80201434 <copyout2+0x3c>
    80201446:	557d                	li	a0,-1
    80201448:	b7f5                	j	80201434 <copyout2+0x3c>

000000008020144a <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8020144a:	caa5                	beqz	a3,802014ba <copyin+0x70>
{
    8020144c:	715d                	addi	sp,sp,-80
    8020144e:	e486                	sd	ra,72(sp)
    80201450:	e0a2                	sd	s0,64(sp)
    80201452:	fc26                	sd	s1,56(sp)
    80201454:	f84a                	sd	s2,48(sp)
    80201456:	f44e                	sd	s3,40(sp)
    80201458:	f052                	sd	s4,32(sp)
    8020145a:	ec56                	sd	s5,24(sp)
    8020145c:	e85a                	sd	s6,16(sp)
    8020145e:	e45e                	sd	s7,8(sp)
    80201460:	e062                	sd	s8,0(sp)
    80201462:	0880                	addi	s0,sp,80
    80201464:	8b2a                	mv	s6,a0
    80201466:	8a2e                	mv	s4,a1
    80201468:	8c32                	mv	s8,a2
    8020146a:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8020146c:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == NULL)
      return -1;
    n = PGSIZE - (srcva - va0);
    8020146e:	6a85                	lui	s5,0x1
    80201470:	a01d                	j	80201496 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80201472:	018505b3          	add	a1,a0,s8
    80201476:	0004861b          	sext.w	a2,s1
    8020147a:	412585b3          	sub	a1,a1,s2
    8020147e:	8552                	mv	a0,s4
    80201480:	fffff097          	auipc	ra,0xfffff
    80201484:	368080e7          	jalr	872(ra) # 802007e8 <memmove>

    len -= n;
    80201488:	409989b3          	sub	s3,s3,s1
    dst += n;
    8020148c:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8020148e:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80201492:	02098263          	beqz	s3,802014b6 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80201496:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8020149a:	85ca                	mv	a1,s2
    8020149c:	855a                	mv	a0,s6
    8020149e:	fffff097          	auipc	ra,0xfffff
    802014a2:	770080e7          	jalr	1904(ra) # 80200c0e <walkaddr>
    if(pa0 == NULL)
    802014a6:	cd01                	beqz	a0,802014be <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    802014a8:	418904b3          	sub	s1,s2,s8
    802014ac:	94d6                	add	s1,s1,s5
    if(n > len)
    802014ae:	fc99f2e3          	bgeu	s3,s1,80201472 <copyin+0x28>
    802014b2:	84ce                	mv	s1,s3
    802014b4:	bf7d                	j	80201472 <copyin+0x28>
  }
  return 0;
    802014b6:	4501                	li	a0,0
    802014b8:	a021                	j	802014c0 <copyin+0x76>
    802014ba:	4501                	li	a0,0
}
    802014bc:	8082                	ret
      return -1;
    802014be:	557d                	li	a0,-1
}
    802014c0:	60a6                	ld	ra,72(sp)
    802014c2:	6406                	ld	s0,64(sp)
    802014c4:	74e2                	ld	s1,56(sp)
    802014c6:	7942                	ld	s2,48(sp)
    802014c8:	79a2                	ld	s3,40(sp)
    802014ca:	7a02                	ld	s4,32(sp)
    802014cc:	6ae2                	ld	s5,24(sp)
    802014ce:	6b42                	ld	s6,16(sp)
    802014d0:	6ba2                	ld	s7,8(sp)
    802014d2:	6c02                	ld	s8,0(sp)
    802014d4:	6161                	addi	sp,sp,80
    802014d6:	8082                	ret

00000000802014d8 <copyin2>:

int
copyin2(char *dst, uint64 srcva, uint64 len)
{
    802014d8:	7179                	addi	sp,sp,-48
    802014da:	f406                	sd	ra,40(sp)
    802014dc:	f022                	sd	s0,32(sp)
    802014de:	ec26                	sd	s1,24(sp)
    802014e0:	e84a                	sd	s2,16(sp)
    802014e2:	e44e                	sd	s3,8(sp)
    802014e4:	1800                	addi	s0,sp,48
    802014e6:	89aa                	mv	s3,a0
    802014e8:	84ae                	mv	s1,a1
    802014ea:	8932                	mv	s2,a2
  uint64 sz = myproc()->sz;
    802014ec:	00000097          	auipc	ra,0x0
    802014f0:	5e2080e7          	jalr	1506(ra) # 80201ace <myproc>
    802014f4:	653c                	ld	a5,72(a0)
  if (srcva + len > sz || srcva >= sz) {
    802014f6:	01248733          	add	a4,s1,s2
    802014fa:	02e7e463          	bltu	a5,a4,80201522 <copyin2+0x4a>
    802014fe:	02f4f463          	bgeu	s1,a5,80201526 <copyin2+0x4e>
    return -1;
  }
  memmove(dst, (void *)srcva, len);
    80201502:	0009061b          	sext.w	a2,s2
    80201506:	85a6                	mv	a1,s1
    80201508:	854e                	mv	a0,s3
    8020150a:	fffff097          	auipc	ra,0xfffff
    8020150e:	2de080e7          	jalr	734(ra) # 802007e8 <memmove>
  return 0;
    80201512:	4501                	li	a0,0
}
    80201514:	70a2                	ld	ra,40(sp)
    80201516:	7402                	ld	s0,32(sp)
    80201518:	64e2                	ld	s1,24(sp)
    8020151a:	6942                	ld	s2,16(sp)
    8020151c:	69a2                	ld	s3,8(sp)
    8020151e:	6145                	addi	sp,sp,48
    80201520:	8082                	ret
    return -1;
    80201522:	557d                	li	a0,-1
    80201524:	bfc5                	j	80201514 <copyin2+0x3c>
    80201526:	557d                	li	a0,-1
    80201528:	b7f5                	j	80201514 <copyin2+0x3c>

000000008020152a <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8020152a:	cacd                	beqz	a3,802015dc <copyinstr+0xb2>
{
    8020152c:	715d                	addi	sp,sp,-80
    8020152e:	e486                	sd	ra,72(sp)
    80201530:	e0a2                	sd	s0,64(sp)
    80201532:	fc26                	sd	s1,56(sp)
    80201534:	f84a                	sd	s2,48(sp)
    80201536:	f44e                	sd	s3,40(sp)
    80201538:	f052                	sd	s4,32(sp)
    8020153a:	ec56                	sd	s5,24(sp)
    8020153c:	e85a                	sd	s6,16(sp)
    8020153e:	e45e                	sd	s7,8(sp)
    80201540:	0880                	addi	s0,sp,80
    80201542:	8a2a                	mv	s4,a0
    80201544:	8b2e                	mv	s6,a1
    80201546:	8bb2                	mv	s7,a2
    80201548:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    8020154a:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == NULL)
      return -1;
    n = PGSIZE - (srcva - va0);
    8020154c:	6985                	lui	s3,0x1
    8020154e:	a825                	j	80201586 <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80201550:	00078023          	sb	zero,0(a5)
    80201554:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80201556:	37fd                	addiw	a5,a5,-1
    80201558:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8020155c:	60a6                	ld	ra,72(sp)
    8020155e:	6406                	ld	s0,64(sp)
    80201560:	74e2                	ld	s1,56(sp)
    80201562:	7942                	ld	s2,48(sp)
    80201564:	79a2                	ld	s3,40(sp)
    80201566:	7a02                	ld	s4,32(sp)
    80201568:	6ae2                	ld	s5,24(sp)
    8020156a:	6b42                	ld	s6,16(sp)
    8020156c:	6ba2                	ld	s7,8(sp)
    8020156e:	6161                	addi	sp,sp,80
    80201570:	8082                	ret
    80201572:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x801ff001>
    80201576:	9742                	add	a4,a4,a6
      --max;
    80201578:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    8020157c:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    80201580:	04e58663          	beq	a1,a4,802015cc <copyinstr+0xa2>
{
    80201584:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    80201586:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8020158a:	85a6                	mv	a1,s1
    8020158c:	8552                	mv	a0,s4
    8020158e:	fffff097          	auipc	ra,0xfffff
    80201592:	680080e7          	jalr	1664(ra) # 80200c0e <walkaddr>
    if(pa0 == NULL)
    80201596:	cd0d                	beqz	a0,802015d0 <copyinstr+0xa6>
    n = PGSIZE - (srcva - va0);
    80201598:	417486b3          	sub	a3,s1,s7
    8020159c:	96ce                	add	a3,a3,s3
    if(n > max)
    8020159e:	00d97363          	bgeu	s2,a3,802015a4 <copyinstr+0x7a>
    802015a2:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    802015a4:	955e                	add	a0,a0,s7
    802015a6:	8d05                	sub	a0,a0,s1
    while(n > 0){
    802015a8:	c695                	beqz	a3,802015d4 <copyinstr+0xaa>
    802015aa:	87da                	mv	a5,s6
    802015ac:	885a                	mv	a6,s6
      if(*p == '\0'){
    802015ae:	41650633          	sub	a2,a0,s6
    while(n > 0){
    802015b2:	96da                	add	a3,a3,s6
    802015b4:	85be                	mv	a1,a5
      if(*p == '\0'){
    802015b6:	00f60733          	add	a4,a2,a5
    802015ba:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <ebss_clear+0xffffffff7fdda000>
    802015be:	db49                	beqz	a4,80201550 <copyinstr+0x26>
        *dst = *p;
    802015c0:	00e78023          	sb	a4,0(a5)
      dst++;
    802015c4:	0785                	addi	a5,a5,1
    while(n > 0){
    802015c6:	fed797e3          	bne	a5,a3,802015b4 <copyinstr+0x8a>
    802015ca:	b765                	j	80201572 <copyinstr+0x48>
    802015cc:	4781                	li	a5,0
    802015ce:	b761                	j	80201556 <copyinstr+0x2c>
      return -1;
    802015d0:	557d                	li	a0,-1
    802015d2:	b769                	j	8020155c <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    802015d4:	6b85                	lui	s7,0x1
    802015d6:	9ba6                	add	s7,s7,s1
    802015d8:	87da                	mv	a5,s6
    802015da:	b76d                	j	80201584 <copyinstr+0x5a>
  int got_null = 0;
    802015dc:	4781                	li	a5,0
  if(got_null){
    802015de:	37fd                	addiw	a5,a5,-1
    802015e0:	0007851b          	sext.w	a0,a5
}
    802015e4:	8082                	ret

00000000802015e6 <copyinstr2>:

int
copyinstr2(char *dst, uint64 srcva, uint64 max)
{
    802015e6:	7179                	addi	sp,sp,-48
    802015e8:	f406                	sd	ra,40(sp)
    802015ea:	f022                	sd	s0,32(sp)
    802015ec:	ec26                	sd	s1,24(sp)
    802015ee:	e84a                	sd	s2,16(sp)
    802015f0:	e44e                	sd	s3,8(sp)
    802015f2:	1800                	addi	s0,sp,48
    802015f4:	89aa                	mv	s3,a0
    802015f6:	84ae                	mv	s1,a1
    802015f8:	8932                	mv	s2,a2
  int got_null = 0;
  uint64 sz = myproc()->sz;
    802015fa:	00000097          	auipc	ra,0x0
    802015fe:	4d4080e7          	jalr	1236(ra) # 80201ace <myproc>
    80201602:	6534                	ld	a3,72(a0)
  while(srcva < sz && max > 0){
    80201604:	04d4f363          	bgeu	s1,a3,8020164a <copyinstr2+0x64>
    80201608:	04090363          	beqz	s2,8020164e <copyinstr2+0x68>
    8020160c:	01298633          	add	a2,s3,s2
    80201610:	8e85                	sub	a3,a3,s1
    80201612:	96ce                	add	a3,a3,s3
    80201614:	87ce                	mv	a5,s3
    char *p = (char *)srcva;
    80201616:	413485b3          	sub	a1,s1,s3
    if(*p == '\0'){
    8020161a:	00b78733          	add	a4,a5,a1
    8020161e:	00074703          	lbu	a4,0(a4)
    80201622:	cb11                	beqz	a4,80201636 <copyinstr2+0x50>
      *dst = '\0';
      got_null = 1;
      break;
    } else {
      *dst = *p;
    80201624:	00e78023          	sb	a4,0(a5)
    }
    --max;
    srcva++;
    dst++;
    80201628:	0785                	addi	a5,a5,1
  while(srcva < sz && max > 0){
    8020162a:	02d78463          	beq	a5,a3,80201652 <copyinstr2+0x6c>
    8020162e:	fec796e3          	bne	a5,a2,8020161a <copyinstr2+0x34>
  }
  if(got_null){
    return 0;
  } else {
    return -1;
    80201632:	557d                	li	a0,-1
    80201634:	a021                	j	8020163c <copyinstr2+0x56>
      *dst = '\0';
    80201636:	00078023          	sb	zero,0(a5)
    return 0;
    8020163a:	4501                	li	a0,0
  }
}
    8020163c:	70a2                	ld	ra,40(sp)
    8020163e:	7402                	ld	s0,32(sp)
    80201640:	64e2                	ld	s1,24(sp)
    80201642:	6942                	ld	s2,16(sp)
    80201644:	69a2                	ld	s3,8(sp)
    80201646:	6145                	addi	sp,sp,48
    80201648:	8082                	ret
    return -1;
    8020164a:	557d                	li	a0,-1
    8020164c:	bfc5                	j	8020163c <copyinstr2+0x56>
    8020164e:	557d                	li	a0,-1
    80201650:	b7f5                	j	8020163c <copyinstr2+0x56>
    80201652:	557d                	li	a0,-1
    80201654:	b7e5                	j	8020163c <copyinstr2+0x56>

0000000080201656 <kfreewalk>:
}

// only free page table, not physical pages
void
kfreewalk(pagetable_t kpt)
{
    80201656:	7179                	addi	sp,sp,-48
    80201658:	f406                	sd	ra,40(sp)
    8020165a:	f022                	sd	s0,32(sp)
    8020165c:	ec26                	sd	s1,24(sp)
    8020165e:	e84a                	sd	s2,16(sp)
    80201660:	e44e                	sd	s3,8(sp)
    80201662:	e052                	sd	s4,0(sp)
    80201664:	1800                	addi	s0,sp,48
    80201666:	8a2a                	mv	s4,a0
  for (int i = 0; i < 512; i++) {
    80201668:	84aa                	mv	s1,a0
    8020166a:	6905                	lui	s2,0x1
    8020166c:	992a                	add	s2,s2,a0
    pte_t pte = kpt[i];
    if ((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0) {
    8020166e:	4985                	li	s3,1
    80201670:	a829                	j	8020168a <kfreewalk+0x34>
      kfreewalk((pagetable_t) PTE2PA(pte));
    80201672:	83a9                	srli	a5,a5,0xa
    80201674:	00c79513          	slli	a0,a5,0xc
    80201678:	00000097          	auipc	ra,0x0
    8020167c:	fde080e7          	jalr	-34(ra) # 80201656 <kfreewalk>
      kpt[i] = 0;
    80201680:	0004b023          	sd	zero,0(s1) # 1000 <_entry-0x801ff000>
  for (int i = 0; i < 512; i++) {
    80201684:	04a1                	addi	s1,s1,8
    80201686:	01248963          	beq	s1,s2,80201698 <kfreewalk+0x42>
    pte_t pte = kpt[i];
    8020168a:	609c                	ld	a5,0(s1)
    if ((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0) {
    8020168c:	00f7f713          	andi	a4,a5,15
    80201690:	ff3701e3          	beq	a4,s3,80201672 <kfreewalk+0x1c>
    } else if (pte & PTE_V) {
    80201694:	8b85                	andi	a5,a5,1
    80201696:	d7fd                	beqz	a5,80201684 <kfreewalk+0x2e>
      break;
    }
  }
  kfree((void *) kpt);
    80201698:	8552                	mv	a0,s4
    8020169a:	fffff097          	auipc	ra,0xfffff
    8020169e:	dd0080e7          	jalr	-560(ra) # 8020046a <kfree>
}
    802016a2:	70a2                	ld	ra,40(sp)
    802016a4:	7402                	ld	s0,32(sp)
    802016a6:	64e2                	ld	s1,24(sp)
    802016a8:	6942                	ld	s2,16(sp)
    802016aa:	69a2                	ld	s3,8(sp)
    802016ac:	6a02                	ld	s4,0(sp)
    802016ae:	6145                	addi	sp,sp,48
    802016b0:	8082                	ret

00000000802016b2 <kvmfreeusr>:

void
kvmfreeusr(pagetable_t kpt)
{
    802016b2:	1101                	addi	sp,sp,-32
    802016b4:	ec06                	sd	ra,24(sp)
    802016b6:	e822                	sd	s0,16(sp)
    802016b8:	e426                	sd	s1,8(sp)
    802016ba:	1000                	addi	s0,sp,32
    802016bc:	84aa                	mv	s1,a0
  pte_t pte;
  for (int i = 0; i < PX(2, MAXUVA); i++) {
    pte = kpt[i];
    802016be:	6108                	ld	a0,0(a0)
    if ((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0) {
    802016c0:	00f57713          	andi	a4,a0,15
    802016c4:	4785                	li	a5,1
    802016c6:	00f70d63          	beq	a4,a5,802016e0 <kvmfreeusr+0x2e>
    pte = kpt[i];
    802016ca:	6488                	ld	a0,8(s1)
    if ((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0) {
    802016cc:	00f57713          	andi	a4,a0,15
    802016d0:	4785                	li	a5,1
    802016d2:	02f70063          	beq	a4,a5,802016f2 <kvmfreeusr+0x40>
      kfreewalk((pagetable_t) PTE2PA(pte));
      kpt[i] = 0;
    }
  }
}
    802016d6:	60e2                	ld	ra,24(sp)
    802016d8:	6442                	ld	s0,16(sp)
    802016da:	64a2                	ld	s1,8(sp)
    802016dc:	6105                	addi	sp,sp,32
    802016de:	8082                	ret
      kfreewalk((pagetable_t) PTE2PA(pte));
    802016e0:	8129                	srli	a0,a0,0xa
    802016e2:	0532                	slli	a0,a0,0xc
    802016e4:	00000097          	auipc	ra,0x0
    802016e8:	f72080e7          	jalr	-142(ra) # 80201656 <kfreewalk>
      kpt[i] = 0;
    802016ec:	0004b023          	sd	zero,0(s1)
    802016f0:	bfe9                	j	802016ca <kvmfreeusr+0x18>
      kfreewalk((pagetable_t) PTE2PA(pte));
    802016f2:	8129                	srli	a0,a0,0xa
    802016f4:	0532                	slli	a0,a0,0xc
    802016f6:	00000097          	auipc	ra,0x0
    802016fa:	f60080e7          	jalr	-160(ra) # 80201656 <kfreewalk>
      kpt[i] = 0;
    802016fe:	0004b423          	sd	zero,8(s1)
}
    80201702:	bfd1                	j	802016d6 <kvmfreeusr+0x24>

0000000080201704 <kvmfree>:

void
kvmfree(pagetable_t kpt, int stack_free)
{
    80201704:	1101                	addi	sp,sp,-32
    80201706:	ec06                	sd	ra,24(sp)
    80201708:	e822                	sd	s0,16(sp)
    8020170a:	e426                	sd	s1,8(sp)
    8020170c:	1000                	addi	s0,sp,32
    8020170e:	84aa                	mv	s1,a0
  if (stack_free) {
    80201710:	e185                	bnez	a1,80201730 <kvmfree+0x2c>
    pte_t pte = kpt[PX(2, VKSTACK)];
    if ((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0) {
      kfreewalk((pagetable_t) PTE2PA(pte));
    }
  }
  kvmfreeusr(kpt);
    80201712:	8526                	mv	a0,s1
    80201714:	00000097          	auipc	ra,0x0
    80201718:	f9e080e7          	jalr	-98(ra) # 802016b2 <kvmfreeusr>
  kfree(kpt);
    8020171c:	8526                	mv	a0,s1
    8020171e:	fffff097          	auipc	ra,0xfffff
    80201722:	d4c080e7          	jalr	-692(ra) # 8020046a <kfree>
}
    80201726:	60e2                	ld	ra,24(sp)
    80201728:	6442                	ld	s0,16(sp)
    8020172a:	64a2                	ld	s1,8(sp)
    8020172c:	6105                	addi	sp,sp,32
    8020172e:	8082                	ret
    vmunmap(kpt, VKSTACK, 1, 1);
    80201730:	4685                	li	a3,1
    80201732:	4605                	li	a2,1
    80201734:	0fb00593          	li	a1,251
    80201738:	05fa                	slli	a1,a1,0x1e
    8020173a:	fffff097          	auipc	ra,0xfffff
    8020173e:	748080e7          	jalr	1864(ra) # 80200e82 <vmunmap>
    pte_t pte = kpt[PX(2, VKSTACK)];
    80201742:	7d84b503          	ld	a0,2008(s1)
    if ((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0) {
    80201746:	00f57713          	andi	a4,a0,15
    8020174a:	4785                	li	a5,1
    8020174c:	fcf713e3          	bne	a4,a5,80201712 <kvmfree+0xe>
      kfreewalk((pagetable_t) PTE2PA(pte));
    80201750:	8129                	srli	a0,a0,0xa
    80201752:	0532                	slli	a0,a0,0xc
    80201754:	00000097          	auipc	ra,0x0
    80201758:	f02080e7          	jalr	-254(ra) # 80201656 <kfreewalk>
    8020175c:	bf5d                	j	80201712 <kvmfree+0xe>

000000008020175e <proc_kpagetable>:
{
    8020175e:	1101                	addi	sp,sp,-32
    80201760:	ec06                	sd	ra,24(sp)
    80201762:	e822                	sd	s0,16(sp)
    80201764:	e426                	sd	s1,8(sp)
    80201766:	1000                	addi	s0,sp,32
  pagetable_t kpt = (pagetable_t) kalloc();
    80201768:	fffff097          	auipc	ra,0xfffff
    8020176c:	e1c080e7          	jalr	-484(ra) # 80200584 <kalloc>
    80201770:	84aa                	mv	s1,a0
  if (kpt == NULL)
    80201772:	c91d                	beqz	a0,802017a8 <proc_kpagetable+0x4a>
  memmove(kpt, kernel_pagetable, PGSIZE);
    80201774:	6605                	lui	a2,0x1
    80201776:	00012597          	auipc	a1,0x12
    8020177a:	8e25b583          	ld	a1,-1822(a1) # 80213058 <kernel_pagetable>
    8020177e:	fffff097          	auipc	ra,0xfffff
    80201782:	06a080e7          	jalr	106(ra) # 802007e8 <memmove>
  char *pstack = kalloc();
    80201786:	fffff097          	auipc	ra,0xfffff
    8020178a:	dfe080e7          	jalr	-514(ra) # 80200584 <kalloc>
    8020178e:	86aa                	mv	a3,a0
  if(pstack == NULL)
    80201790:	c115                	beqz	a0,802017b4 <proc_kpagetable+0x56>
  if (mappages(kpt, VKSTACK, PGSIZE, (uint64)pstack, PTE_R | PTE_W) != 0)
    80201792:	4719                	li	a4,6
    80201794:	6605                	lui	a2,0x1
    80201796:	0fb00593          	li	a1,251
    8020179a:	05fa                	slli	a1,a1,0x1e
    8020179c:	8526                	mv	a0,s1
    8020179e:	fffff097          	auipc	ra,0xfffff
    802017a2:	52a080e7          	jalr	1322(ra) # 80200cc8 <mappages>
    802017a6:	e519                	bnez	a0,802017b4 <proc_kpagetable+0x56>
}
    802017a8:	8526                	mv	a0,s1
    802017aa:	60e2                	ld	ra,24(sp)
    802017ac:	6442                	ld	s0,16(sp)
    802017ae:	64a2                	ld	s1,8(sp)
    802017b0:	6105                	addi	sp,sp,32
    802017b2:	8082                	ret
  kvmfree(kpt, 1);
    802017b4:	4585                	li	a1,1
    802017b6:	8526                	mv	a0,s1
    802017b8:	00000097          	auipc	ra,0x0
    802017bc:	f4c080e7          	jalr	-180(ra) # 80201704 <kvmfree>
  return NULL;
    802017c0:	4481                	li	s1,0
    802017c2:	b7dd                	j	802017a8 <proc_kpagetable+0x4a>

00000000802017c4 <vmprint>:

void vmprint(pagetable_t pagetable)
{
    802017c4:	7119                	addi	sp,sp,-128
    802017c6:	fc86                	sd	ra,120(sp)
    802017c8:	f8a2                	sd	s0,112(sp)
    802017ca:	f4a6                	sd	s1,104(sp)
    802017cc:	f0ca                	sd	s2,96(sp)
    802017ce:	ecce                	sd	s3,88(sp)
    802017d0:	e8d2                	sd	s4,80(sp)
    802017d2:	e4d6                	sd	s5,72(sp)
    802017d4:	e0da                	sd	s6,64(sp)
    802017d6:	fc5e                	sd	s7,56(sp)
    802017d8:	f862                	sd	s8,48(sp)
    802017da:	f466                	sd	s9,40(sp)
    802017dc:	f06a                	sd	s10,32(sp)
    802017de:	ec6e                	sd	s11,24(sp)
    802017e0:	0100                	addi	s0,sp,128
    802017e2:	8baa                	mv	s7,a0
    802017e4:	f8a43423          	sd	a0,-120(s0)
  const int capacity = 512;
  printf("page table %p\n", pagetable);
    802017e8:	85aa                	mv	a1,a0
    802017ea:	00008517          	auipc	a0,0x8
    802017ee:	cf650513          	addi	a0,a0,-778 # 802094e0 <etext+0x4e0>
    802017f2:	fffff097          	auipc	ra,0xfffff
    802017f6:	99e080e7          	jalr	-1634(ra) # 80200190 <printf>
  for (pte_t *pte = (pte_t *) pagetable; pte < pagetable + capacity; pte++) {
    802017fa:	6d85                	lui	s11,0x1
    802017fc:	9dde                	add	s11,s11,s7
    802017fe:	6c85                	lui	s9,0x1

      for (pte_t *pte2 = (pte_t *) pt2; pte2 < pt2 + capacity; pte2++) {
        if (*pte2 & PTE_V)
        {
          pagetable_t pt3 = (pagetable_t) PTE2PA(*pte2);
          printf(".. ..%d: pte %p pa %p\n", pte2 - pt2, *pte2, pt3);
    80201800:	00008d17          	auipc	s10,0x8
    80201804:	d08d0d13          	addi	s10,s10,-760 # 80209508 <etext+0x508>

          for (pte_t *pte3 = (pte_t *) pt3; pte3 < pt3 + capacity; pte3++)
            if (*pte3 & PTE_V)
              printf(".. .. ..%d: pte %p pa %p\n", pte3 - pt3, *pte3, PTE2PA(*pte3));
    80201808:	00008a17          	auipc	s4,0x8
    8020180c:	d18a0a13          	addi	s4,s4,-744 # 80209520 <etext+0x520>
    80201810:	a885                	j	80201880 <vmprint+0xbc>
          for (pte_t *pte3 = (pte_t *) pt3; pte3 < pt3 + capacity; pte3++)
    80201812:	04a1                	addi	s1,s1,8
    80201814:	197d                	addi	s2,s2,-1 # fff <_entry-0x801ff001>
    80201816:	02090263          	beqz	s2,8020183a <vmprint+0x76>
            if (*pte3 & PTE_V)
    8020181a:	6090                	ld	a2,0(s1)
    8020181c:	00167793          	andi	a5,a2,1
    80201820:	dbed                	beqz	a5,80201812 <vmprint+0x4e>
              printf(".. .. ..%d: pte %p pa %p\n", pte3 - pt3, *pte3, PTE2PA(*pte3));
    80201822:	00a65693          	srli	a3,a2,0xa
    80201826:	413485b3          	sub	a1,s1,s3
    8020182a:	06b2                	slli	a3,a3,0xc
    8020182c:	858d                	srai	a1,a1,0x3
    8020182e:	8552                	mv	a0,s4
    80201830:	fffff097          	auipc	ra,0xfffff
    80201834:	960080e7          	jalr	-1696(ra) # 80200190 <printf>
    80201838:	bfe9                	j	80201812 <vmprint+0x4e>
      for (pte_t *pte2 = (pte_t *) pt2; pte2 < pt2 + capacity; pte2++) {
    8020183a:	0aa1                	addi	s5,s5,8 # fffffffffffff008 <ebss_clear+0xffffffff7fdda008>
    8020183c:	1b7d                	addi	s6,s6,-1 # fff <_entry-0x801ff001>
    8020183e:	020b0e63          	beqz	s6,8020187a <vmprint+0xb6>
        if (*pte2 & PTE_V)
    80201842:	000ab603          	ld	a2,0(s5)
    80201846:	00167793          	andi	a5,a2,1
    8020184a:	dbe5                	beqz	a5,8020183a <vmprint+0x76>
          pagetable_t pt3 = (pagetable_t) PTE2PA(*pte2);
    8020184c:	00a65993          	srli	s3,a2,0xa
    80201850:	09b2                	slli	s3,s3,0xc
          printf(".. ..%d: pte %p pa %p\n", pte2 - pt2, *pte2, pt3);
    80201852:	418a85b3          	sub	a1,s5,s8
    80201856:	86ce                	mv	a3,s3
    80201858:	858d                	srai	a1,a1,0x3
    8020185a:	856a                	mv	a0,s10
    8020185c:	fffff097          	auipc	ra,0xfffff
    80201860:	934080e7          	jalr	-1740(ra) # 80200190 <printf>
          for (pte_t *pte3 = (pte_t *) pt3; pte3 < pt3 + capacity; pte3++)
    80201864:	01998733          	add	a4,s3,s9
    80201868:	00898793          	addi	a5,s3,8 # 1008 <_entry-0x801feff8>
    8020186c:	20000913          	li	s2,512
    80201870:	00f77363          	bgeu	a4,a5,80201876 <vmprint+0xb2>
    80201874:	4905                	li	s2,1
    80201876:	84ce                	mv	s1,s3
    80201878:	b74d                	j	8020181a <vmprint+0x56>
  for (pte_t *pte = (pte_t *) pagetable; pte < pagetable + capacity; pte++) {
    8020187a:	0ba1                	addi	s7,s7,8 # 1008 <_entry-0x801feff8>
    8020187c:	05bb8463          	beq	s7,s11,802018c4 <vmprint+0x100>
    if (*pte & PTE_V)
    80201880:	000bb603          	ld	a2,0(s7)
    80201884:	00167793          	andi	a5,a2,1
    80201888:	dbed                	beqz	a5,8020187a <vmprint+0xb6>
      pagetable_t pt2 = (pagetable_t) PTE2PA(*pte); 
    8020188a:	00a65c13          	srli	s8,a2,0xa
    8020188e:	0c32                	slli	s8,s8,0xc
      printf("..%d: pte %p pa %p\n", pte - pagetable, *pte, pt2);
    80201890:	f8843783          	ld	a5,-120(s0)
    80201894:	40fb87b3          	sub	a5,s7,a5
    80201898:	86e2                	mv	a3,s8
    8020189a:	4037d593          	srai	a1,a5,0x3
    8020189e:	00008517          	auipc	a0,0x8
    802018a2:	c5250513          	addi	a0,a0,-942 # 802094f0 <etext+0x4f0>
    802018a6:	fffff097          	auipc	ra,0xfffff
    802018aa:	8ea080e7          	jalr	-1814(ra) # 80200190 <printf>
      for (pte_t *pte2 = (pte_t *) pt2; pte2 < pt2 + capacity; pte2++) {
    802018ae:	008c0713          	addi	a4,s8,8
    802018b2:	019c07b3          	add	a5,s8,s9
    802018b6:	20000b13          	li	s6,512
    802018ba:	00e7f363          	bgeu	a5,a4,802018c0 <vmprint+0xfc>
    802018be:	4b05                	li	s6,1
    802018c0:	8ae2                	mv	s5,s8
    802018c2:	b741                	j	80201842 <vmprint+0x7e>
        }
      }
    }
  }
  return;
    802018c4:	70e6                	ld	ra,120(sp)
    802018c6:	7446                	ld	s0,112(sp)
    802018c8:	74a6                	ld	s1,104(sp)
    802018ca:	7906                	ld	s2,96(sp)
    802018cc:	69e6                	ld	s3,88(sp)
    802018ce:	6a46                	ld	s4,80(sp)
    802018d0:	6aa6                	ld	s5,72(sp)
    802018d2:	6b06                	ld	s6,64(sp)
    802018d4:	7be2                	ld	s7,56(sp)
    802018d6:	7c42                	ld	s8,48(sp)
    802018d8:	7ca2                	ld	s9,40(sp)
    802018da:	7d02                	ld	s10,32(sp)
    802018dc:	6de2                	ld	s11,24(sp)
    802018de:	6109                	addi	sp,sp,128
    802018e0:	8082                	ret

00000000802018e2 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    802018e2:	1101                	addi	sp,sp,-32
    802018e4:	ec06                	sd	ra,24(sp)
    802018e6:	e822                	sd	s0,16(sp)
    802018e8:	e426                	sd	s1,8(sp)
    802018ea:	1000                	addi	s0,sp,32
    802018ec:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    802018ee:	fffff097          	auipc	ra,0xfffff
    802018f2:	dd4080e7          	jalr	-556(ra) # 802006c2 <holding>
    802018f6:	c909                	beqz	a0,80201908 <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    802018f8:	749c                	ld	a5,40(s1)
    802018fa:	00978f63          	beq	a5,s1,80201918 <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    802018fe:	60e2                	ld	ra,24(sp)
    80201900:	6442                	ld	s0,16(sp)
    80201902:	64a2                	ld	s1,8(sp)
    80201904:	6105                	addi	sp,sp,32
    80201906:	8082                	ret
    panic("wakeup1");
    80201908:	00008517          	auipc	a0,0x8
    8020190c:	c3850513          	addi	a0,a0,-968 # 80209540 <etext+0x540>
    80201910:	fffff097          	auipc	ra,0xfffff
    80201914:	836080e7          	jalr	-1994(ra) # 80200146 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    80201918:	4c98                	lw	a4,24(s1)
    8020191a:	4785                	li	a5,1
    8020191c:	fef711e3          	bne	a4,a5,802018fe <wakeup1+0x1c>
    p->state = RUNNABLE;
    80201920:	4789                	li	a5,2
    80201922:	cc9c                	sw	a5,24(s1)
}
    80201924:	bfe9                	j	802018fe <wakeup1+0x1c>

0000000080201926 <reg_info>:
void reg_info(void) {
    80201926:	1141                	addi	sp,sp,-16
    80201928:	e406                	sd	ra,8(sp)
    8020192a:	e022                	sd	s0,0(sp)
    8020192c:	0800                	addi	s0,sp,16
  printf("register info: {\n");
    8020192e:	00008517          	auipc	a0,0x8
    80201932:	c1a50513          	addi	a0,a0,-998 # 80209548 <etext+0x548>
    80201936:	fffff097          	auipc	ra,0xfffff
    8020193a:	85a080e7          	jalr	-1958(ra) # 80200190 <printf>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8020193e:	100025f3          	csrr	a1,sstatus
  printf("sstatus: %p\n", r_sstatus());
    80201942:	00008517          	auipc	a0,0x8
    80201946:	c1e50513          	addi	a0,a0,-994 # 80209560 <etext+0x560>
    8020194a:	fffff097          	auipc	ra,0xfffff
    8020194e:	846080e7          	jalr	-1978(ra) # 80200190 <printf>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80201952:	144025f3          	csrr	a1,sip
  printf("sip: %p\n", r_sip());
    80201956:	00008517          	auipc	a0,0x8
    8020195a:	c1a50513          	addi	a0,a0,-998 # 80209570 <etext+0x570>
    8020195e:	fffff097          	auipc	ra,0xfffff
    80201962:	832080e7          	jalr	-1998(ra) # 80200190 <printf>
  asm volatile("csrr %0, sie" : "=r" (x) );
    80201966:	104025f3          	csrr	a1,sie
  printf("sie: %p\n", r_sie());
    8020196a:	00008517          	auipc	a0,0x8
    8020196e:	c1650513          	addi	a0,a0,-1002 # 80209580 <etext+0x580>
    80201972:	fffff097          	auipc	ra,0xfffff
    80201976:	81e080e7          	jalr	-2018(ra) # 80200190 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8020197a:	141025f3          	csrr	a1,sepc
  printf("sepc: %p\n", r_sepc());
    8020197e:	00008517          	auipc	a0,0x8
    80201982:	c1250513          	addi	a0,a0,-1006 # 80209590 <etext+0x590>
    80201986:	fffff097          	auipc	ra,0xfffff
    8020198a:	80a080e7          	jalr	-2038(ra) # 80200190 <printf>
  asm volatile("csrr %0, stvec" : "=r" (x) );
    8020198e:	105025f3          	csrr	a1,stvec
  printf("stvec: %p\n", r_stvec());
    80201992:	00008517          	auipc	a0,0x8
    80201996:	c0e50513          	addi	a0,a0,-1010 # 802095a0 <etext+0x5a0>
    8020199a:	ffffe097          	auipc	ra,0xffffe
    8020199e:	7f6080e7          	jalr	2038(ra) # 80200190 <printf>
  asm volatile("csrr %0, satp" : "=r" (x) );
    802019a2:	180025f3          	csrr	a1,satp
  printf("satp: %p\n", r_satp());
    802019a6:	00008517          	auipc	a0,0x8
    802019aa:	c0a50513          	addi	a0,a0,-1014 # 802095b0 <etext+0x5b0>
    802019ae:	ffffe097          	auipc	ra,0xffffe
    802019b2:	7e2080e7          	jalr	2018(ra) # 80200190 <printf>
  asm volatile("csrr %0, scause" : "=r" (x) );
    802019b6:	142025f3          	csrr	a1,scause
  printf("scause: %p\n", r_scause());
    802019ba:	00008517          	auipc	a0,0x8
    802019be:	c0650513          	addi	a0,a0,-1018 # 802095c0 <etext+0x5c0>
    802019c2:	ffffe097          	auipc	ra,0xffffe
    802019c6:	7ce080e7          	jalr	1998(ra) # 80200190 <printf>
  asm volatile("csrr %0, stval" : "=r" (x) );
    802019ca:	143025f3          	csrr	a1,stval
  printf("stval: %p\n", r_stval());
    802019ce:	00008517          	auipc	a0,0x8
    802019d2:	c0250513          	addi	a0,a0,-1022 # 802095d0 <etext+0x5d0>
    802019d6:	ffffe097          	auipc	ra,0xffffe
    802019da:	7ba080e7          	jalr	1978(ra) # 80200190 <printf>
  asm volatile("mv %0, sp" : "=r" (x) );
    802019de:	858a                	mv	a1,sp
  printf("sp: %p\n", r_sp());
    802019e0:	00008517          	auipc	a0,0x8
    802019e4:	c0050513          	addi	a0,a0,-1024 # 802095e0 <etext+0x5e0>
    802019e8:	ffffe097          	auipc	ra,0xffffe
    802019ec:	7a8080e7          	jalr	1960(ra) # 80200190 <printf>
  asm volatile("mv %0, tp" : "=r" (x) );
    802019f0:	8592                	mv	a1,tp
  printf("tp: %p\n", r_tp());
    802019f2:	00008517          	auipc	a0,0x8
    802019f6:	bf650513          	addi	a0,a0,-1034 # 802095e8 <etext+0x5e8>
    802019fa:	ffffe097          	auipc	ra,0xffffe
    802019fe:	796080e7          	jalr	1942(ra) # 80200190 <printf>
  asm volatile("mv %0, ra" : "=r" (x) );
    80201a02:	8586                	mv	a1,ra
  printf("ra: %p\n", r_ra());
    80201a04:	00008517          	auipc	a0,0x8
    80201a08:	bec50513          	addi	a0,a0,-1044 # 802095f0 <etext+0x5f0>
    80201a0c:	ffffe097          	auipc	ra,0xffffe
    80201a10:	784080e7          	jalr	1924(ra) # 80200190 <printf>
  printf("}\n");
    80201a14:	00008517          	auipc	a0,0x8
    80201a18:	be450513          	addi	a0,a0,-1052 # 802095f8 <etext+0x5f8>
    80201a1c:	ffffe097          	auipc	ra,0xffffe
    80201a20:	774080e7          	jalr	1908(ra) # 80200190 <printf>
}
    80201a24:	60a2                	ld	ra,8(sp)
    80201a26:	6402                	ld	s0,0(sp)
    80201a28:	0141                	addi	sp,sp,16
    80201a2a:	8082                	ret

0000000080201a2c <procinit>:
{
    80201a2c:	7179                	addi	sp,sp,-48
    80201a2e:	f406                	sd	ra,40(sp)
    80201a30:	f022                	sd	s0,32(sp)
    80201a32:	ec26                	sd	s1,24(sp)
    80201a34:	e84a                	sd	s2,16(sp)
    80201a36:	e44e                	sd	s3,8(sp)
    80201a38:	1800                	addi	s0,sp,48
  initlock(&pid_lock, "nextpid");
    80201a3a:	00008597          	auipc	a1,0x8
    80201a3e:	bc658593          	addi	a1,a1,-1082 # 80209600 <etext+0x600>
    80201a42:	00011517          	auipc	a0,0x11
    80201a46:	61e50513          	addi	a0,a0,1566 # 80213060 <pid_lock>
    80201a4a:	fffff097          	auipc	ra,0xfffff
    80201a4e:	c62080e7          	jalr	-926(ra) # 802006ac <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80201a52:	00011497          	auipc	s1,0x11
    80201a56:	72648493          	addi	s1,s1,1830 # 80213178 <proc>
      initlock(&p->lock, "proc");
    80201a5a:	00008997          	auipc	s3,0x8
    80201a5e:	bae98993          	addi	s3,s3,-1106 # 80209608 <etext+0x608>
  for(p = proc; p < &proc[NPROC]; p++) {
    80201a62:	00016917          	auipc	s2,0x16
    80201a66:	08690913          	addi	s2,s2,134 # 80217ae8 <initproc>
      initlock(&p->lock, "proc");
    80201a6a:	85ce                	mv	a1,s3
    80201a6c:	8526                	mv	a0,s1
    80201a6e:	fffff097          	auipc	ra,0xfffff
    80201a72:	c3e080e7          	jalr	-962(ra) # 802006ac <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80201a76:	17848493          	addi	s1,s1,376
    80201a7a:	ff2498e3          	bne	s1,s2,80201a6a <procinit+0x3e>
  memset(cpus, 0, sizeof(cpus));
    80201a7e:	10000613          	li	a2,256
    80201a82:	4581                	li	a1,0
    80201a84:	00011517          	auipc	a0,0x11
    80201a88:	5f450513          	addi	a0,a0,1524 # 80213078 <cpus>
    80201a8c:	fffff097          	auipc	ra,0xfffff
    80201a90:	d00080e7          	jalr	-768(ra) # 8020078c <memset>
}
    80201a94:	70a2                	ld	ra,40(sp)
    80201a96:	7402                	ld	s0,32(sp)
    80201a98:	64e2                	ld	s1,24(sp)
    80201a9a:	6942                	ld	s2,16(sp)
    80201a9c:	69a2                	ld	s3,8(sp)
    80201a9e:	6145                	addi	sp,sp,48
    80201aa0:	8082                	ret

0000000080201aa2 <cpuid>:
{
    80201aa2:	1141                	addi	sp,sp,-16
    80201aa4:	e422                	sd	s0,8(sp)
    80201aa6:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80201aa8:	8512                	mv	a0,tp
}
    80201aaa:	2501                	sext.w	a0,a0
    80201aac:	6422                	ld	s0,8(sp)
    80201aae:	0141                	addi	sp,sp,16
    80201ab0:	8082                	ret

0000000080201ab2 <mycpu>:
mycpu(void) {
    80201ab2:	1141                	addi	sp,sp,-16
    80201ab4:	e422                	sd	s0,8(sp)
    80201ab6:	0800                	addi	s0,sp,16
    80201ab8:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80201aba:	2781                	sext.w	a5,a5
    80201abc:	079e                	slli	a5,a5,0x7
}
    80201abe:	00011517          	auipc	a0,0x11
    80201ac2:	5ba50513          	addi	a0,a0,1466 # 80213078 <cpus>
    80201ac6:	953e                	add	a0,a0,a5
    80201ac8:	6422                	ld	s0,8(sp)
    80201aca:	0141                	addi	sp,sp,16
    80201acc:	8082                	ret

0000000080201ace <myproc>:
myproc(void) {
    80201ace:	1101                	addi	sp,sp,-32
    80201ad0:	ec06                	sd	ra,24(sp)
    80201ad2:	e822                	sd	s0,16(sp)
    80201ad4:	e426                	sd	s1,8(sp)
    80201ad6:	1000                	addi	s0,sp,32
  push_off();
    80201ad8:	fffff097          	auipc	ra,0xfffff
    80201adc:	b28080e7          	jalr	-1240(ra) # 80200600 <push_off>
    80201ae0:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80201ae2:	2781                	sext.w	a5,a5
    80201ae4:	079e                	slli	a5,a5,0x7
    80201ae6:	00011717          	auipc	a4,0x11
    80201aea:	57a70713          	addi	a4,a4,1402 # 80213060 <pid_lock>
    80201aee:	97ba                	add	a5,a5,a4
    80201af0:	6f84                	ld	s1,24(a5)
  pop_off();
    80201af2:	fffff097          	auipc	ra,0xfffff
    80201af6:	b5a080e7          	jalr	-1190(ra) # 8020064c <pop_off>
}
    80201afa:	8526                	mv	a0,s1
    80201afc:	60e2                	ld	ra,24(sp)
    80201afe:	6442                	ld	s0,16(sp)
    80201b00:	64a2                	ld	s1,8(sp)
    80201b02:	6105                	addi	sp,sp,32
    80201b04:	8082                	ret

0000000080201b06 <forkret>:
{
    80201b06:	1101                	addi	sp,sp,-32
    80201b08:	ec06                	sd	ra,24(sp)
    80201b0a:	e822                	sd	s0,16(sp)
    80201b0c:	1000                	addi	s0,sp,32
  release(&myproc()->lock);
    80201b0e:	00000097          	auipc	ra,0x0
    80201b12:	fc0080e7          	jalr	-64(ra) # 80201ace <myproc>
    80201b16:	fffff097          	auipc	ra,0xfffff
    80201b1a:	c2e080e7          	jalr	-978(ra) # 80200744 <release>
  if (first) {
    80201b1e:	00008797          	auipc	a5,0x8
    80201b22:	52a7a783          	lw	a5,1322(a5) # 8020a048 <first.1>
    80201b26:	eb89                	bnez	a5,80201b38 <forkret+0x32>
  usertrapret();
    80201b28:	00001097          	auipc	ra,0x1
    80201b2c:	c64080e7          	jalr	-924(ra) # 8020278c <usertrapret>
}
    80201b30:	60e2                	ld	ra,24(sp)
    80201b32:	6442                	ld	s0,16(sp)
    80201b34:	6105                	addi	sp,sp,32
    80201b36:	8082                	ret
    80201b38:	e426                	sd	s1,8(sp)
    first = 0;
    80201b3a:	00008797          	auipc	a5,0x8
    80201b3e:	5007a723          	sw	zero,1294(a5) # 8020a048 <first.1>
    fat32_init();
    80201b42:	00004097          	auipc	ra,0x4
    80201b46:	da8080e7          	jalr	-600(ra) # 802058ea <fat32_init>
    myproc()->cwd = ename("/");
    80201b4a:	00000097          	auipc	ra,0x0
    80201b4e:	f84080e7          	jalr	-124(ra) # 80201ace <myproc>
    80201b52:	84aa                	mv	s1,a0
    80201b54:	00008517          	auipc	a0,0x8
    80201b58:	abc50513          	addi	a0,a0,-1348 # 80209610 <etext+0x610>
    80201b5c:	00005097          	auipc	ra,0x5
    80201b60:	0ba080e7          	jalr	186(ra) # 80206c16 <ename>
    80201b64:	14a4bc23          	sd	a0,344(s1)
    80201b68:	64a2                	ld	s1,8(sp)
    80201b6a:	bf7d                	j	80201b28 <forkret+0x22>

0000000080201b6c <allocpid>:
allocpid() {
    80201b6c:	1101                	addi	sp,sp,-32
    80201b6e:	ec06                	sd	ra,24(sp)
    80201b70:	e822                	sd	s0,16(sp)
    80201b72:	e426                	sd	s1,8(sp)
    80201b74:	e04a                	sd	s2,0(sp)
    80201b76:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80201b78:	00011917          	auipc	s2,0x11
    80201b7c:	4e890913          	addi	s2,s2,1256 # 80213060 <pid_lock>
    80201b80:	854a                	mv	a0,s2
    80201b82:	fffff097          	auipc	ra,0xfffff
    80201b86:	b6e080e7          	jalr	-1170(ra) # 802006f0 <acquire>
  pid = nextpid;
    80201b8a:	00008797          	auipc	a5,0x8
    80201b8e:	4c278793          	addi	a5,a5,1218 # 8020a04c <nextpid>
    80201b92:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80201b94:	0014871b          	addiw	a4,s1,1
    80201b98:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80201b9a:	854a                	mv	a0,s2
    80201b9c:	fffff097          	auipc	ra,0xfffff
    80201ba0:	ba8080e7          	jalr	-1112(ra) # 80200744 <release>
}
    80201ba4:	8526                	mv	a0,s1
    80201ba6:	60e2                	ld	ra,24(sp)
    80201ba8:	6442                	ld	s0,16(sp)
    80201baa:	64a2                	ld	s1,8(sp)
    80201bac:	6902                	ld	s2,0(sp)
    80201bae:	6105                	addi	sp,sp,32
    80201bb0:	8082                	ret

0000000080201bb2 <proc_pagetable>:
{
    80201bb2:	1101                	addi	sp,sp,-32
    80201bb4:	ec06                	sd	ra,24(sp)
    80201bb6:	e822                	sd	s0,16(sp)
    80201bb8:	e426                	sd	s1,8(sp)
    80201bba:	e04a                	sd	s2,0(sp)
    80201bbc:	1000                	addi	s0,sp,32
    80201bbe:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80201bc0:	fffff097          	auipc	ra,0xfffff
    80201bc4:	396080e7          	jalr	918(ra) # 80200f56 <uvmcreate>
    80201bc8:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80201bca:	c121                	beqz	a0,80201c0a <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80201bcc:	4729                	li	a4,10
    80201bce:	00006697          	auipc	a3,0x6
    80201bd2:	43268693          	addi	a3,a3,1074 # 80208000 <_trampoline>
    80201bd6:	6605                	lui	a2,0x1
    80201bd8:	040005b7          	lui	a1,0x4000
    80201bdc:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c200001>
    80201bde:	05b2                	slli	a1,a1,0xc
    80201be0:	fffff097          	auipc	ra,0xfffff
    80201be4:	0e8080e7          	jalr	232(ra) # 80200cc8 <mappages>
    80201be8:	02054863          	bltz	a0,80201c18 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80201bec:	4719                	li	a4,6
    80201bee:	06093683          	ld	a3,96(s2)
    80201bf2:	6605                	lui	a2,0x1
    80201bf4:	020005b7          	lui	a1,0x2000
    80201bf8:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e200001>
    80201bfa:	05b6                	slli	a1,a1,0xd
    80201bfc:	8526                	mv	a0,s1
    80201bfe:	fffff097          	auipc	ra,0xfffff
    80201c02:	0ca080e7          	jalr	202(ra) # 80200cc8 <mappages>
    80201c06:	02054163          	bltz	a0,80201c28 <proc_pagetable+0x76>
}
    80201c0a:	8526                	mv	a0,s1
    80201c0c:	60e2                	ld	ra,24(sp)
    80201c0e:	6442                	ld	s0,16(sp)
    80201c10:	64a2                	ld	s1,8(sp)
    80201c12:	6902                	ld	s2,0(sp)
    80201c14:	6105                	addi	sp,sp,32
    80201c16:	8082                	ret
    uvmfree(pagetable, 0);
    80201c18:	4581                	li	a1,0
    80201c1a:	8526                	mv	a0,s1
    80201c1c:	fffff097          	auipc	ra,0xfffff
    80201c20:	5d0080e7          	jalr	1488(ra) # 802011ec <uvmfree>
    return NULL;
    80201c24:	4481                	li	s1,0
    80201c26:	b7d5                	j	80201c0a <proc_pagetable+0x58>
    vmunmap(pagetable, TRAMPOLINE, 1, 0);
    80201c28:	4681                	li	a3,0
    80201c2a:	4605                	li	a2,1
    80201c2c:	040005b7          	lui	a1,0x4000
    80201c30:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c200001>
    80201c32:	05b2                	slli	a1,a1,0xc
    80201c34:	8526                	mv	a0,s1
    80201c36:	fffff097          	auipc	ra,0xfffff
    80201c3a:	24c080e7          	jalr	588(ra) # 80200e82 <vmunmap>
    uvmfree(pagetable, 0);
    80201c3e:	4581                	li	a1,0
    80201c40:	8526                	mv	a0,s1
    80201c42:	fffff097          	auipc	ra,0xfffff
    80201c46:	5aa080e7          	jalr	1450(ra) # 802011ec <uvmfree>
    return NULL;
    80201c4a:	4481                	li	s1,0
    80201c4c:	bf7d                	j	80201c0a <proc_pagetable+0x58>

0000000080201c4e <proc_freepagetable>:
{
    80201c4e:	1101                	addi	sp,sp,-32
    80201c50:	ec06                	sd	ra,24(sp)
    80201c52:	e822                	sd	s0,16(sp)
    80201c54:	e426                	sd	s1,8(sp)
    80201c56:	e04a                	sd	s2,0(sp)
    80201c58:	1000                	addi	s0,sp,32
    80201c5a:	84aa                	mv	s1,a0
    80201c5c:	892e                	mv	s2,a1
  vmunmap(pagetable, TRAMPOLINE, 1, 0);
    80201c5e:	4681                	li	a3,0
    80201c60:	4605                	li	a2,1
    80201c62:	040005b7          	lui	a1,0x4000
    80201c66:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c200001>
    80201c68:	05b2                	slli	a1,a1,0xc
    80201c6a:	fffff097          	auipc	ra,0xfffff
    80201c6e:	218080e7          	jalr	536(ra) # 80200e82 <vmunmap>
  vmunmap(pagetable, TRAPFRAME, 1, 0);
    80201c72:	4681                	li	a3,0
    80201c74:	4605                	li	a2,1
    80201c76:	020005b7          	lui	a1,0x2000
    80201c7a:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e200001>
    80201c7c:	05b6                	slli	a1,a1,0xd
    80201c7e:	8526                	mv	a0,s1
    80201c80:	fffff097          	auipc	ra,0xfffff
    80201c84:	202080e7          	jalr	514(ra) # 80200e82 <vmunmap>
  uvmfree(pagetable, sz);
    80201c88:	85ca                	mv	a1,s2
    80201c8a:	8526                	mv	a0,s1
    80201c8c:	fffff097          	auipc	ra,0xfffff
    80201c90:	560080e7          	jalr	1376(ra) # 802011ec <uvmfree>
}
    80201c94:	60e2                	ld	ra,24(sp)
    80201c96:	6442                	ld	s0,16(sp)
    80201c98:	64a2                	ld	s1,8(sp)
    80201c9a:	6902                	ld	s2,0(sp)
    80201c9c:	6105                	addi	sp,sp,32
    80201c9e:	8082                	ret

0000000080201ca0 <freeproc>:
{
    80201ca0:	1101                	addi	sp,sp,-32
    80201ca2:	ec06                	sd	ra,24(sp)
    80201ca4:	e822                	sd	s0,16(sp)
    80201ca6:	e426                	sd	s1,8(sp)
    80201ca8:	1000                	addi	s0,sp,32
    80201caa:	84aa                	mv	s1,a0
  if(p->trapframe)
    80201cac:	7128                	ld	a0,96(a0)
    80201cae:	c509                	beqz	a0,80201cb8 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80201cb0:	ffffe097          	auipc	ra,0xffffe
    80201cb4:	7ba080e7          	jalr	1978(ra) # 8020046a <kfree>
  p->trapframe = 0;
    80201cb8:	0604b023          	sd	zero,96(s1)
  if (p->kpagetable) {
    80201cbc:	6ca8                	ld	a0,88(s1)
    80201cbe:	c511                	beqz	a0,80201cca <freeproc+0x2a>
    kvmfree(p->kpagetable, 1);
    80201cc0:	4585                	li	a1,1
    80201cc2:	00000097          	auipc	ra,0x0
    80201cc6:	a42080e7          	jalr	-1470(ra) # 80201704 <kvmfree>
  p->kpagetable = 0;
    80201cca:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80201cce:	68a8                	ld	a0,80(s1)
    80201cd0:	c511                	beqz	a0,80201cdc <freeproc+0x3c>
    proc_freepagetable(p->pagetable, p->sz);
    80201cd2:	64ac                	ld	a1,72(s1)
    80201cd4:	00000097          	auipc	ra,0x0
    80201cd8:	f7a080e7          	jalr	-134(ra) # 80201c4e <proc_freepagetable>
  p->pagetable = 0;
    80201cdc:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80201ce0:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80201ce4:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80201ce8:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80201cec:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80201cf0:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80201cf4:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80201cf8:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80201cfc:	0004ac23          	sw	zero,24(s1)
}
    80201d00:	60e2                	ld	ra,24(sp)
    80201d02:	6442                	ld	s0,16(sp)
    80201d04:	64a2                	ld	s1,8(sp)
    80201d06:	6105                	addi	sp,sp,32
    80201d08:	8082                	ret

0000000080201d0a <allocproc>:
{
    80201d0a:	1101                	addi	sp,sp,-32
    80201d0c:	ec06                	sd	ra,24(sp)
    80201d0e:	e822                	sd	s0,16(sp)
    80201d10:	e426                	sd	s1,8(sp)
    80201d12:	e04a                	sd	s2,0(sp)
    80201d14:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80201d16:	00011497          	auipc	s1,0x11
    80201d1a:	46248493          	addi	s1,s1,1122 # 80213178 <proc>
    80201d1e:	00016917          	auipc	s2,0x16
    80201d22:	dca90913          	addi	s2,s2,-566 # 80217ae8 <initproc>
    acquire(&p->lock);
    80201d26:	8526                	mv	a0,s1
    80201d28:	fffff097          	auipc	ra,0xfffff
    80201d2c:	9c8080e7          	jalr	-1592(ra) # 802006f0 <acquire>
    if(p->state == UNUSED) {
    80201d30:	4c9c                	lw	a5,24(s1)
    80201d32:	cf81                	beqz	a5,80201d4a <allocproc+0x40>
      release(&p->lock);
    80201d34:	8526                	mv	a0,s1
    80201d36:	fffff097          	auipc	ra,0xfffff
    80201d3a:	a0e080e7          	jalr	-1522(ra) # 80200744 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80201d3e:	17848493          	addi	s1,s1,376
    80201d42:	ff2492e3          	bne	s1,s2,80201d26 <allocproc+0x1c>
  return NULL;
    80201d46:	4481                	li	s1,0
    80201d48:	a085                	j	80201da8 <allocproc+0x9e>
  p->pid = allocpid();
    80201d4a:	00000097          	auipc	ra,0x0
    80201d4e:	e22080e7          	jalr	-478(ra) # 80201b6c <allocpid>
    80201d52:	dc88                	sw	a0,56(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == NULL){
    80201d54:	fffff097          	auipc	ra,0xfffff
    80201d58:	830080e7          	jalr	-2000(ra) # 80200584 <kalloc>
    80201d5c:	892a                	mv	s2,a0
    80201d5e:	f0a8                	sd	a0,96(s1)
    80201d60:	c939                	beqz	a0,80201db6 <allocproc+0xac>
  if ((p->pagetable = proc_pagetable(p)) == NULL ||
    80201d62:	8526                	mv	a0,s1
    80201d64:	00000097          	auipc	ra,0x0
    80201d68:	e4e080e7          	jalr	-434(ra) # 80201bb2 <proc_pagetable>
    80201d6c:	e8a8                	sd	a0,80(s1)
    80201d6e:	c939                	beqz	a0,80201dc4 <allocproc+0xba>
      (p->kpagetable = proc_kpagetable()) == NULL) {
    80201d70:	00000097          	auipc	ra,0x0
    80201d74:	9ee080e7          	jalr	-1554(ra) # 8020175e <proc_kpagetable>
    80201d78:	eca8                	sd	a0,88(s1)
  if ((p->pagetable = proc_pagetable(p)) == NULL ||
    80201d7a:	c529                	beqz	a0,80201dc4 <allocproc+0xba>
  p->kstack = VKSTACK;
    80201d7c:	0fb00793          	li	a5,251
    80201d80:	07fa                	slli	a5,a5,0x1e
    80201d82:	e0bc                	sd	a5,64(s1)
  memset(&p->context, 0, sizeof(p->context));
    80201d84:	07000613          	li	a2,112
    80201d88:	4581                	li	a1,0
    80201d8a:	06848513          	addi	a0,s1,104
    80201d8e:	fffff097          	auipc	ra,0xfffff
    80201d92:	9fe080e7          	jalr	-1538(ra) # 8020078c <memset>
  p->context.ra = (uint64)forkret;
    80201d96:	00000797          	auipc	a5,0x0
    80201d9a:	d7078793          	addi	a5,a5,-656 # 80201b06 <forkret>
    80201d9e:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80201da0:	60bc                	ld	a5,64(s1)
    80201da2:	6705                	lui	a4,0x1
    80201da4:	97ba                	add	a5,a5,a4
    80201da6:	f8bc                	sd	a5,112(s1)
}
    80201da8:	8526                	mv	a0,s1
    80201daa:	60e2                	ld	ra,24(sp)
    80201dac:	6442                	ld	s0,16(sp)
    80201dae:	64a2                	ld	s1,8(sp)
    80201db0:	6902                	ld	s2,0(sp)
    80201db2:	6105                	addi	sp,sp,32
    80201db4:	8082                	ret
    release(&p->lock);
    80201db6:	8526                	mv	a0,s1
    80201db8:	fffff097          	auipc	ra,0xfffff
    80201dbc:	98c080e7          	jalr	-1652(ra) # 80200744 <release>
    return NULL;
    80201dc0:	84ca                	mv	s1,s2
    80201dc2:	b7dd                	j	80201da8 <allocproc+0x9e>
    freeproc(p);
    80201dc4:	8526                	mv	a0,s1
    80201dc6:	00000097          	auipc	ra,0x0
    80201dca:	eda080e7          	jalr	-294(ra) # 80201ca0 <freeproc>
    release(&p->lock);
    80201dce:	8526                	mv	a0,s1
    80201dd0:	fffff097          	auipc	ra,0xfffff
    80201dd4:	974080e7          	jalr	-1676(ra) # 80200744 <release>
    return NULL;
    80201dd8:	4481                	li	s1,0
    80201dda:	b7f9                	j	80201da8 <allocproc+0x9e>

0000000080201ddc <userinit>:
{
    80201ddc:	1101                	addi	sp,sp,-32
    80201dde:	ec06                	sd	ra,24(sp)
    80201de0:	e822                	sd	s0,16(sp)
    80201de2:	e426                	sd	s1,8(sp)
    80201de4:	1000                	addi	s0,sp,32
  p = allocproc();
    80201de6:	00000097          	auipc	ra,0x0
    80201dea:	f24080e7          	jalr	-220(ra) # 80201d0a <allocproc>
    80201dee:	84aa                	mv	s1,a0
  initproc = p;
    80201df0:	00016797          	auipc	a5,0x16
    80201df4:	cea7bc23          	sd	a0,-776(a5) # 80217ae8 <initproc>
  uvminit(p->pagetable , p->kpagetable, initcode, sizeof(initcode));
    80201df8:	03400693          	li	a3,52
    80201dfc:	00008617          	auipc	a2,0x8
    80201e00:	20460613          	addi	a2,a2,516 # 8020a000 <initcode>
    80201e04:	6d2c                	ld	a1,88(a0)
    80201e06:	6928                	ld	a0,80(a0)
    80201e08:	fffff097          	auipc	ra,0xfffff
    80201e0c:	17c080e7          	jalr	380(ra) # 80200f84 <uvminit>
  p->sz = PGSIZE;
    80201e10:	6785                	lui	a5,0x1
    80201e12:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0x0;      // user program counter
    80201e14:	70b8                	ld	a4,96(s1)
    80201e16:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x801fefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80201e1a:	70b8                	ld	a4,96(s1)
    80201e1c:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80201e1e:	4641                	li	a2,16
    80201e20:	00007597          	auipc	a1,0x7
    80201e24:	7f858593          	addi	a1,a1,2040 # 80209618 <etext+0x618>
    80201e28:	16048513          	addi	a0,s1,352
    80201e2c:	fffff097          	auipc	ra,0xfffff
    80201e30:	aaa080e7          	jalr	-1366(ra) # 802008d6 <safestrcpy>
  p->state = RUNNABLE;
    80201e34:	4789                	li	a5,2
    80201e36:	cc9c                	sw	a5,24(s1)
  p->tmask = 0;
    80201e38:	1604a823          	sw	zero,368(s1)
  release(&p->lock);
    80201e3c:	8526                	mv	a0,s1
    80201e3e:	fffff097          	auipc	ra,0xfffff
    80201e42:	906080e7          	jalr	-1786(ra) # 80200744 <release>
}
    80201e46:	60e2                	ld	ra,24(sp)
    80201e48:	6442                	ld	s0,16(sp)
    80201e4a:	64a2                	ld	s1,8(sp)
    80201e4c:	6105                	addi	sp,sp,32
    80201e4e:	8082                	ret

0000000080201e50 <growproc>:
{
    80201e50:	1101                	addi	sp,sp,-32
    80201e52:	ec06                	sd	ra,24(sp)
    80201e54:	e822                	sd	s0,16(sp)
    80201e56:	e426                	sd	s1,8(sp)
    80201e58:	e04a                	sd	s2,0(sp)
    80201e5a:	1000                	addi	s0,sp,32
    80201e5c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80201e5e:	00000097          	auipc	ra,0x0
    80201e62:	c70080e7          	jalr	-912(ra) # 80201ace <myproc>
    80201e66:	892a                	mv	s2,a0
  sz = p->sz;
    80201e68:	6530                	ld	a2,72(a0)
    80201e6a:	0006079b          	sext.w	a5,a2
  if(n > 0){
    80201e6e:	00904f63          	bgtz	s1,80201e8c <growproc+0x3c>
  } else if(n < 0){
    80201e72:	0204ce63          	bltz	s1,80201eae <growproc+0x5e>
  p->sz = sz;
    80201e76:	1782                	slli	a5,a5,0x20
    80201e78:	9381                	srli	a5,a5,0x20
    80201e7a:	04f93423          	sd	a5,72(s2)
  return 0;
    80201e7e:	4501                	li	a0,0
}
    80201e80:	60e2                	ld	ra,24(sp)
    80201e82:	6442                	ld	s0,16(sp)
    80201e84:	64a2                	ld	s1,8(sp)
    80201e86:	6902                	ld	s2,0(sp)
    80201e88:	6105                	addi	sp,sp,32
    80201e8a:	8082                	ret
    if((sz = uvmalloc(p->pagetable, p->kpagetable, sz, sz + n)) == 0) {
    80201e8c:	00f486bb          	addw	a3,s1,a5
    80201e90:	1682                	slli	a3,a3,0x20
    80201e92:	9281                	srli	a3,a3,0x20
    80201e94:	1602                	slli	a2,a2,0x20
    80201e96:	9201                	srli	a2,a2,0x20
    80201e98:	6d2c                	ld	a1,88(a0)
    80201e9a:	6928                	ld	a0,80(a0)
    80201e9c:	fffff097          	auipc	ra,0xfffff
    80201ea0:	1e2080e7          	jalr	482(ra) # 8020107e <uvmalloc>
    80201ea4:	0005079b          	sext.w	a5,a0
    80201ea8:	f7f9                	bnez	a5,80201e76 <growproc+0x26>
      return -1;
    80201eaa:	557d                	li	a0,-1
    80201eac:	bfd1                	j	80201e80 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, p->kpagetable, sz, sz + n);
    80201eae:	00f486bb          	addw	a3,s1,a5
    80201eb2:	1682                	slli	a3,a3,0x20
    80201eb4:	9281                	srli	a3,a3,0x20
    80201eb6:	1602                	slli	a2,a2,0x20
    80201eb8:	9201                	srli	a2,a2,0x20
    80201eba:	6d2c                	ld	a1,88(a0)
    80201ebc:	6928                	ld	a0,80(a0)
    80201ebe:	fffff097          	auipc	ra,0xfffff
    80201ec2:	150080e7          	jalr	336(ra) # 8020100e <uvmdealloc>
    80201ec6:	0005079b          	sext.w	a5,a0
    80201eca:	b775                	j	80201e76 <growproc+0x26>

0000000080201ecc <fork>:
{
    80201ecc:	7139                	addi	sp,sp,-64
    80201ece:	fc06                	sd	ra,56(sp)
    80201ed0:	f822                	sd	s0,48(sp)
    80201ed2:	f426                	sd	s1,40(sp)
    80201ed4:	e456                	sd	s5,8(sp)
    80201ed6:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80201ed8:	00000097          	auipc	ra,0x0
    80201edc:	bf6080e7          	jalr	-1034(ra) # 80201ace <myproc>
    80201ee0:	8aaa                	mv	s5,a0
  if((np = allocproc()) == NULL){
    80201ee2:	00000097          	auipc	ra,0x0
    80201ee6:	e28080e7          	jalr	-472(ra) # 80201d0a <allocproc>
    80201eea:	cd65                	beqz	a0,80201fe2 <fork+0x116>
    80201eec:	e852                	sd	s4,16(sp)
    80201eee:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, np->kpagetable, p->sz) < 0){
    80201ef0:	048ab683          	ld	a3,72(s5)
    80201ef4:	6d30                	ld	a2,88(a0)
    80201ef6:	692c                	ld	a1,80(a0)
    80201ef8:	050ab503          	ld	a0,80(s5)
    80201efc:	fffff097          	auipc	ra,0xfffff
    80201f00:	32a080e7          	jalr	810(ra) # 80201226 <uvmcopy>
    80201f04:	06054063          	bltz	a0,80201f64 <fork+0x98>
    80201f08:	f04a                	sd	s2,32(sp)
    80201f0a:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80201f0c:	048ab783          	ld	a5,72(s5)
    80201f10:	04fa3423          	sd	a5,72(s4)
  np->parent = p;
    80201f14:	035a3023          	sd	s5,32(s4)
  np->tmask = p->tmask;
    80201f18:	170aa783          	lw	a5,368(s5)
    80201f1c:	16fa2823          	sw	a5,368(s4)
  *(np->trapframe) = *(p->trapframe);
    80201f20:	060ab683          	ld	a3,96(s5)
    80201f24:	87b6                	mv	a5,a3
    80201f26:	060a3703          	ld	a4,96(s4)
    80201f2a:	12068693          	addi	a3,a3,288
    80201f2e:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x801ff000>
    80201f32:	6788                	ld	a0,8(a5)
    80201f34:	6b8c                	ld	a1,16(a5)
    80201f36:	6f90                	ld	a2,24(a5)
    80201f38:	01073023          	sd	a6,0(a4)
    80201f3c:	e708                	sd	a0,8(a4)
    80201f3e:	eb0c                	sd	a1,16(a4)
    80201f40:	ef10                	sd	a2,24(a4)
    80201f42:	02078793          	addi	a5,a5,32
    80201f46:	02070713          	addi	a4,a4,32
    80201f4a:	fed792e3          	bne	a5,a3,80201f2e <fork+0x62>
  np->trapframe->a0 = 0;
    80201f4e:	060a3783          	ld	a5,96(s4)
    80201f52:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80201f56:	0d8a8493          	addi	s1,s5,216
    80201f5a:	0d8a0913          	addi	s2,s4,216
    80201f5e:	158a8993          	addi	s3,s5,344
    80201f62:	a015                	j	80201f86 <fork+0xba>
    freeproc(np);
    80201f64:	8552                	mv	a0,s4
    80201f66:	00000097          	auipc	ra,0x0
    80201f6a:	d3a080e7          	jalr	-710(ra) # 80201ca0 <freeproc>
    release(&np->lock);
    80201f6e:	8552                	mv	a0,s4
    80201f70:	ffffe097          	auipc	ra,0xffffe
    80201f74:	7d4080e7          	jalr	2004(ra) # 80200744 <release>
    return -1;
    80201f78:	54fd                	li	s1,-1
    80201f7a:	6a42                	ld	s4,16(sp)
    80201f7c:	a8a1                	j	80201fd4 <fork+0x108>
  for(i = 0; i < NOFILE; i++)
    80201f7e:	04a1                	addi	s1,s1,8
    80201f80:	0921                	addi	s2,s2,8
    80201f82:	01348b63          	beq	s1,s3,80201f98 <fork+0xcc>
    if(p->ofile[i])
    80201f86:	6088                	ld	a0,0(s1)
    80201f88:	d97d                	beqz	a0,80201f7e <fork+0xb2>
      np->ofile[i] = filedup(p->ofile[i]);
    80201f8a:	00002097          	auipc	ra,0x2
    80201f8e:	8b6080e7          	jalr	-1866(ra) # 80203840 <filedup>
    80201f92:	00a93023          	sd	a0,0(s2)
    80201f96:	b7e5                	j	80201f7e <fork+0xb2>
  np->cwd = edup(p->cwd);
    80201f98:	158ab503          	ld	a0,344(s5)
    80201f9c:	00004097          	auipc	ra,0x4
    80201fa0:	1d6080e7          	jalr	470(ra) # 80206172 <edup>
    80201fa4:	14aa3c23          	sd	a0,344(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80201fa8:	4641                	li	a2,16
    80201faa:	160a8593          	addi	a1,s5,352
    80201fae:	160a0513          	addi	a0,s4,352
    80201fb2:	fffff097          	auipc	ra,0xfffff
    80201fb6:	924080e7          	jalr	-1756(ra) # 802008d6 <safestrcpy>
  pid = np->pid;
    80201fba:	038a2483          	lw	s1,56(s4)
  np->state = RUNNABLE;
    80201fbe:	4789                	li	a5,2
    80201fc0:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80201fc4:	8552                	mv	a0,s4
    80201fc6:	ffffe097          	auipc	ra,0xffffe
    80201fca:	77e080e7          	jalr	1918(ra) # 80200744 <release>
  return pid;
    80201fce:	7902                	ld	s2,32(sp)
    80201fd0:	69e2                	ld	s3,24(sp)
    80201fd2:	6a42                	ld	s4,16(sp)
}
    80201fd4:	8526                	mv	a0,s1
    80201fd6:	70e2                	ld	ra,56(sp)
    80201fd8:	7442                	ld	s0,48(sp)
    80201fda:	74a2                	ld	s1,40(sp)
    80201fdc:	6aa2                	ld	s5,8(sp)
    80201fde:	6121                	addi	sp,sp,64
    80201fe0:	8082                	ret
    return -1;
    80201fe2:	54fd                	li	s1,-1
    80201fe4:	bfc5                	j	80201fd4 <fork+0x108>

0000000080201fe6 <reparent>:
{
    80201fe6:	7179                	addi	sp,sp,-48
    80201fe8:	f406                	sd	ra,40(sp)
    80201fea:	f022                	sd	s0,32(sp)
    80201fec:	ec26                	sd	s1,24(sp)
    80201fee:	e84a                	sd	s2,16(sp)
    80201ff0:	e44e                	sd	s3,8(sp)
    80201ff2:	e052                	sd	s4,0(sp)
    80201ff4:	1800                	addi	s0,sp,48
    80201ff6:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80201ff8:	00011497          	auipc	s1,0x11
    80201ffc:	18048493          	addi	s1,s1,384 # 80213178 <proc>
      pp->parent = initproc;
    80202000:	00016a17          	auipc	s4,0x16
    80202004:	ae8a0a13          	addi	s4,s4,-1304 # 80217ae8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80202008:	00016997          	auipc	s3,0x16
    8020200c:	ae098993          	addi	s3,s3,-1312 # 80217ae8 <initproc>
    80202010:	a029                	j	8020201a <reparent+0x34>
    80202012:	17848493          	addi	s1,s1,376
    80202016:	03348363          	beq	s1,s3,8020203c <reparent+0x56>
    if(pp->parent == p){
    8020201a:	709c                	ld	a5,32(s1)
    8020201c:	ff279be3          	bne	a5,s2,80202012 <reparent+0x2c>
      acquire(&pp->lock);
    80202020:	8526                	mv	a0,s1
    80202022:	ffffe097          	auipc	ra,0xffffe
    80202026:	6ce080e7          	jalr	1742(ra) # 802006f0 <acquire>
      pp->parent = initproc;
    8020202a:	000a3783          	ld	a5,0(s4)
    8020202e:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    80202030:	8526                	mv	a0,s1
    80202032:	ffffe097          	auipc	ra,0xffffe
    80202036:	712080e7          	jalr	1810(ra) # 80200744 <release>
    8020203a:	bfe1                	j	80202012 <reparent+0x2c>
}
    8020203c:	70a2                	ld	ra,40(sp)
    8020203e:	7402                	ld	s0,32(sp)
    80202040:	64e2                	ld	s1,24(sp)
    80202042:	6942                	ld	s2,16(sp)
    80202044:	69a2                	ld	s3,8(sp)
    80202046:	6a02                	ld	s4,0(sp)
    80202048:	6145                	addi	sp,sp,48
    8020204a:	8082                	ret

000000008020204c <scheduler>:
{
    8020204c:	715d                	addi	sp,sp,-80
    8020204e:	e486                	sd	ra,72(sp)
    80202050:	e0a2                	sd	s0,64(sp)
    80202052:	fc26                	sd	s1,56(sp)
    80202054:	f84a                	sd	s2,48(sp)
    80202056:	f44e                	sd	s3,40(sp)
    80202058:	f052                	sd	s4,32(sp)
    8020205a:	ec56                	sd	s5,24(sp)
    8020205c:	e85a                	sd	s6,16(sp)
    8020205e:	e45e                	sd	s7,8(sp)
    80202060:	e062                	sd	s8,0(sp)
    80202062:	0880                	addi	s0,sp,80
    80202064:	8792                	mv	a5,tp
  int id = r_tp();
    80202066:	2781                	sext.w	a5,a5
  c->proc = 0;
    80202068:	00779b13          	slli	s6,a5,0x7
    8020206c:	00011717          	auipc	a4,0x11
    80202070:	ff470713          	addi	a4,a4,-12 # 80213060 <pid_lock>
    80202074:	975a                	add	a4,a4,s6
    80202076:	00073c23          	sd	zero,24(a4)
        swtch(&c->context, &p->context);
    8020207a:	00011717          	auipc	a4,0x11
    8020207e:	00670713          	addi	a4,a4,6 # 80213080 <cpus+0x8>
    80202082:	9b3a                	add	s6,s6,a4
        c->proc = p;
    80202084:	079e                	slli	a5,a5,0x7
    80202086:	00011a97          	auipc	s5,0x11
    8020208a:	fdaa8a93          	addi	s5,s5,-38 # 80213060 <pid_lock>
    8020208e:	9abe                	add	s5,s5,a5
        w_satp(MAKE_SATP(p->kpagetable));
    80202090:	5a7d                	li	s4,-1
    80202092:	1a7e                	slli	s4,s4,0x3f
        w_satp(MAKE_SATP(kernel_pagetable));
    80202094:	00011b97          	auipc	s7,0x11
    80202098:	fc4b8b93          	addi	s7,s7,-60 # 80213058 <kernel_pagetable>
    8020209c:	a8a5                	j	80202114 <scheduler+0xc8>
      release(&p->lock);
    8020209e:	8526                	mv	a0,s1
    802020a0:	ffffe097          	auipc	ra,0xffffe
    802020a4:	6a4080e7          	jalr	1700(ra) # 80200744 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    802020a8:	17848493          	addi	s1,s1,376
    802020ac:	05248a63          	beq	s1,s2,80202100 <scheduler+0xb4>
      acquire(&p->lock);
    802020b0:	8526                	mv	a0,s1
    802020b2:	ffffe097          	auipc	ra,0xffffe
    802020b6:	63e080e7          	jalr	1598(ra) # 802006f0 <acquire>
      if(p->state == RUNNABLE) {
    802020ba:	4c9c                	lw	a5,24(s1)
    802020bc:	ff3791e3          	bne	a5,s3,8020209e <scheduler+0x52>
        p->state = RUNNING;
    802020c0:	478d                	li	a5,3
    802020c2:	cc9c                	sw	a5,24(s1)
        c->proc = p;
    802020c4:	009abc23          	sd	s1,24(s5)
        w_satp(MAKE_SATP(p->kpagetable));
    802020c8:	6cbc                	ld	a5,88(s1)
    802020ca:	83b1                	srli	a5,a5,0xc
    802020cc:	0147e7b3          	or	a5,a5,s4
  asm volatile("csrw satp, %0" : : "r" (x));
    802020d0:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma");
    802020d4:	12000073          	sfence.vma
        swtch(&c->context, &p->context);
    802020d8:	06848593          	addi	a1,s1,104
    802020dc:	855a                	mv	a0,s6
    802020de:	00000097          	auipc	ra,0x0
    802020e2:	608080e7          	jalr	1544(ra) # 802026e6 <swtch>
        w_satp(MAKE_SATP(kernel_pagetable));
    802020e6:	000bb783          	ld	a5,0(s7)
    802020ea:	83b1                	srli	a5,a5,0xc
    802020ec:	0147e7b3          	or	a5,a5,s4
  asm volatile("csrw satp, %0" : : "r" (x));
    802020f0:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma");
    802020f4:	12000073          	sfence.vma
        c->proc = 0;
    802020f8:	000abc23          	sd	zero,24(s5)
        found = 1;
    802020fc:	4c05                	li	s8,1
    802020fe:	b745                	j	8020209e <scheduler+0x52>
    if(found == 0) {
    80202100:	000c1a63          	bnez	s8,80202114 <scheduler+0xc8>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80202104:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80202108:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8020210c:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80202110:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80202114:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80202118:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8020211c:	10079073          	csrw	sstatus,a5
    int found = 0;
    80202120:	4c01                	li	s8,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80202122:	00011497          	auipc	s1,0x11
    80202126:	05648493          	addi	s1,s1,86 # 80213178 <proc>
      if(p->state == RUNNABLE) {
    8020212a:	4989                	li	s3,2
    for(p = proc; p < &proc[NPROC]; p++) {
    8020212c:	00016917          	auipc	s2,0x16
    80202130:	9bc90913          	addi	s2,s2,-1604 # 80217ae8 <initproc>
    80202134:	bfb5                	j	802020b0 <scheduler+0x64>

0000000080202136 <sched>:
{
    80202136:	7179                	addi	sp,sp,-48
    80202138:	f406                	sd	ra,40(sp)
    8020213a:	f022                	sd	s0,32(sp)
    8020213c:	ec26                	sd	s1,24(sp)
    8020213e:	e84a                	sd	s2,16(sp)
    80202140:	e44e                	sd	s3,8(sp)
    80202142:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80202144:	00000097          	auipc	ra,0x0
    80202148:	98a080e7          	jalr	-1654(ra) # 80201ace <myproc>
    8020214c:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8020214e:	ffffe097          	auipc	ra,0xffffe
    80202152:	574080e7          	jalr	1396(ra) # 802006c2 <holding>
    80202156:	c93d                	beqz	a0,802021cc <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80202158:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8020215a:	2781                	sext.w	a5,a5
    8020215c:	079e                	slli	a5,a5,0x7
    8020215e:	00011717          	auipc	a4,0x11
    80202162:	f0270713          	addi	a4,a4,-254 # 80213060 <pid_lock>
    80202166:	97ba                	add	a5,a5,a4
    80202168:	0907a703          	lw	a4,144(a5)
    8020216c:	4785                	li	a5,1
    8020216e:	06f71763          	bne	a4,a5,802021dc <sched+0xa6>
  if(p->state == RUNNING)
    80202172:	4c98                	lw	a4,24(s1)
    80202174:	478d                	li	a5,3
    80202176:	06f70b63          	beq	a4,a5,802021ec <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8020217a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8020217e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80202180:	efb5                	bnez	a5,802021fc <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80202182:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80202184:	00011917          	auipc	s2,0x11
    80202188:	edc90913          	addi	s2,s2,-292 # 80213060 <pid_lock>
    8020218c:	2781                	sext.w	a5,a5
    8020218e:	079e                	slli	a5,a5,0x7
    80202190:	97ca                	add	a5,a5,s2
    80202192:	0947a983          	lw	s3,148(a5)
    80202196:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80202198:	2781                	sext.w	a5,a5
    8020219a:	079e                	slli	a5,a5,0x7
    8020219c:	00011597          	auipc	a1,0x11
    802021a0:	ee458593          	addi	a1,a1,-284 # 80213080 <cpus+0x8>
    802021a4:	95be                	add	a1,a1,a5
    802021a6:	06848513          	addi	a0,s1,104
    802021aa:	00000097          	auipc	ra,0x0
    802021ae:	53c080e7          	jalr	1340(ra) # 802026e6 <swtch>
    802021b2:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    802021b4:	2781                	sext.w	a5,a5
    802021b6:	079e                	slli	a5,a5,0x7
    802021b8:	993e                	add	s2,s2,a5
    802021ba:	09392a23          	sw	s3,148(s2)
}
    802021be:	70a2                	ld	ra,40(sp)
    802021c0:	7402                	ld	s0,32(sp)
    802021c2:	64e2                	ld	s1,24(sp)
    802021c4:	6942                	ld	s2,16(sp)
    802021c6:	69a2                	ld	s3,8(sp)
    802021c8:	6145                	addi	sp,sp,48
    802021ca:	8082                	ret
    panic("sched p->lock");
    802021cc:	00007517          	auipc	a0,0x7
    802021d0:	45c50513          	addi	a0,a0,1116 # 80209628 <etext+0x628>
    802021d4:	ffffe097          	auipc	ra,0xffffe
    802021d8:	f72080e7          	jalr	-142(ra) # 80200146 <panic>
    panic("sched locks");
    802021dc:	00007517          	auipc	a0,0x7
    802021e0:	45c50513          	addi	a0,a0,1116 # 80209638 <etext+0x638>
    802021e4:	ffffe097          	auipc	ra,0xffffe
    802021e8:	f62080e7          	jalr	-158(ra) # 80200146 <panic>
    panic("sched running");
    802021ec:	00007517          	auipc	a0,0x7
    802021f0:	45c50513          	addi	a0,a0,1116 # 80209648 <etext+0x648>
    802021f4:	ffffe097          	auipc	ra,0xffffe
    802021f8:	f52080e7          	jalr	-174(ra) # 80200146 <panic>
    panic("sched interruptible");
    802021fc:	00007517          	auipc	a0,0x7
    80202200:	45c50513          	addi	a0,a0,1116 # 80209658 <etext+0x658>
    80202204:	ffffe097          	auipc	ra,0xffffe
    80202208:	f42080e7          	jalr	-190(ra) # 80200146 <panic>

000000008020220c <exit>:
{
    8020220c:	7179                	addi	sp,sp,-48
    8020220e:	f406                	sd	ra,40(sp)
    80202210:	f022                	sd	s0,32(sp)
    80202212:	ec26                	sd	s1,24(sp)
    80202214:	e84a                	sd	s2,16(sp)
    80202216:	e44e                	sd	s3,8(sp)
    80202218:	e052                	sd	s4,0(sp)
    8020221a:	1800                	addi	s0,sp,48
    8020221c:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8020221e:	00000097          	auipc	ra,0x0
    80202222:	8b0080e7          	jalr	-1872(ra) # 80201ace <myproc>
    80202226:	89aa                	mv	s3,a0
  if(p == initproc)
    80202228:	00016797          	auipc	a5,0x16
    8020222c:	8c07b783          	ld	a5,-1856(a5) # 80217ae8 <initproc>
    80202230:	0d850493          	addi	s1,a0,216
    80202234:	15850913          	addi	s2,a0,344
    80202238:	02a79363          	bne	a5,a0,8020225e <exit+0x52>
    panic("init exiting");
    8020223c:	00007517          	auipc	a0,0x7
    80202240:	43450513          	addi	a0,a0,1076 # 80209670 <etext+0x670>
    80202244:	ffffe097          	auipc	ra,0xffffe
    80202248:	f02080e7          	jalr	-254(ra) # 80200146 <panic>
      fileclose(f);
    8020224c:	00001097          	auipc	ra,0x1
    80202250:	646080e7          	jalr	1606(ra) # 80203892 <fileclose>
      p->ofile[fd] = 0;
    80202254:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80202258:	04a1                	addi	s1,s1,8
    8020225a:	01248563          	beq	s1,s2,80202264 <exit+0x58>
    if(p->ofile[fd]){
    8020225e:	6088                	ld	a0,0(s1)
    80202260:	f575                	bnez	a0,8020224c <exit+0x40>
    80202262:	bfdd                	j	80202258 <exit+0x4c>
  eput(p->cwd);
    80202264:	1589b503          	ld	a0,344(s3)
    80202268:	00004097          	auipc	ra,0x4
    8020226c:	1e2080e7          	jalr	482(ra) # 8020644a <eput>
  p->cwd = 0;
    80202270:	1409bc23          	sd	zero,344(s3)
  acquire(&initproc->lock);
    80202274:	00016497          	auipc	s1,0x16
    80202278:	87448493          	addi	s1,s1,-1932 # 80217ae8 <initproc>
    8020227c:	6088                	ld	a0,0(s1)
    8020227e:	ffffe097          	auipc	ra,0xffffe
    80202282:	472080e7          	jalr	1138(ra) # 802006f0 <acquire>
  wakeup1(initproc);
    80202286:	6088                	ld	a0,0(s1)
    80202288:	fffff097          	auipc	ra,0xfffff
    8020228c:	65a080e7          	jalr	1626(ra) # 802018e2 <wakeup1>
  release(&initproc->lock);
    80202290:	6088                	ld	a0,0(s1)
    80202292:	ffffe097          	auipc	ra,0xffffe
    80202296:	4b2080e7          	jalr	1202(ra) # 80200744 <release>
  acquire(&p->lock);
    8020229a:	854e                	mv	a0,s3
    8020229c:	ffffe097          	auipc	ra,0xffffe
    802022a0:	454080e7          	jalr	1108(ra) # 802006f0 <acquire>
  struct proc *original_parent = p->parent;
    802022a4:	0209b483          	ld	s1,32(s3)
  release(&p->lock);
    802022a8:	854e                	mv	a0,s3
    802022aa:	ffffe097          	auipc	ra,0xffffe
    802022ae:	49a080e7          	jalr	1178(ra) # 80200744 <release>
  acquire(&original_parent->lock);
    802022b2:	8526                	mv	a0,s1
    802022b4:	ffffe097          	auipc	ra,0xffffe
    802022b8:	43c080e7          	jalr	1084(ra) # 802006f0 <acquire>
  acquire(&p->lock);
    802022bc:	854e                	mv	a0,s3
    802022be:	ffffe097          	auipc	ra,0xffffe
    802022c2:	432080e7          	jalr	1074(ra) # 802006f0 <acquire>
  reparent(p);
    802022c6:	854e                	mv	a0,s3
    802022c8:	00000097          	auipc	ra,0x0
    802022cc:	d1e080e7          	jalr	-738(ra) # 80201fe6 <reparent>
  wakeup1(original_parent);
    802022d0:	8526                	mv	a0,s1
    802022d2:	fffff097          	auipc	ra,0xfffff
    802022d6:	610080e7          	jalr	1552(ra) # 802018e2 <wakeup1>
  p->xstate = status;
    802022da:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    802022de:	4791                	li	a5,4
    802022e0:	00f9ac23          	sw	a5,24(s3)
  release(&original_parent->lock);
    802022e4:	8526                	mv	a0,s1
    802022e6:	ffffe097          	auipc	ra,0xffffe
    802022ea:	45e080e7          	jalr	1118(ra) # 80200744 <release>
  sched();
    802022ee:	00000097          	auipc	ra,0x0
    802022f2:	e48080e7          	jalr	-440(ra) # 80202136 <sched>
  panic("zombie exit");
    802022f6:	00007517          	auipc	a0,0x7
    802022fa:	38a50513          	addi	a0,a0,906 # 80209680 <etext+0x680>
    802022fe:	ffffe097          	auipc	ra,0xffffe
    80202302:	e48080e7          	jalr	-440(ra) # 80200146 <panic>

0000000080202306 <yield>:
{
    80202306:	1101                	addi	sp,sp,-32
    80202308:	ec06                	sd	ra,24(sp)
    8020230a:	e822                	sd	s0,16(sp)
    8020230c:	e426                	sd	s1,8(sp)
    8020230e:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80202310:	fffff097          	auipc	ra,0xfffff
    80202314:	7be080e7          	jalr	1982(ra) # 80201ace <myproc>
    80202318:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8020231a:	ffffe097          	auipc	ra,0xffffe
    8020231e:	3d6080e7          	jalr	982(ra) # 802006f0 <acquire>
  p->state = RUNNABLE;
    80202322:	4789                	li	a5,2
    80202324:	cc9c                	sw	a5,24(s1)
  sched();
    80202326:	00000097          	auipc	ra,0x0
    8020232a:	e10080e7          	jalr	-496(ra) # 80202136 <sched>
  release(&p->lock);
    8020232e:	8526                	mv	a0,s1
    80202330:	ffffe097          	auipc	ra,0xffffe
    80202334:	414080e7          	jalr	1044(ra) # 80200744 <release>
}
    80202338:	60e2                	ld	ra,24(sp)
    8020233a:	6442                	ld	s0,16(sp)
    8020233c:	64a2                	ld	s1,8(sp)
    8020233e:	6105                	addi	sp,sp,32
    80202340:	8082                	ret

0000000080202342 <sleep>:
{
    80202342:	7179                	addi	sp,sp,-48
    80202344:	f406                	sd	ra,40(sp)
    80202346:	f022                	sd	s0,32(sp)
    80202348:	ec26                	sd	s1,24(sp)
    8020234a:	e84a                	sd	s2,16(sp)
    8020234c:	e44e                	sd	s3,8(sp)
    8020234e:	1800                	addi	s0,sp,48
    80202350:	89aa                	mv	s3,a0
    80202352:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80202354:	fffff097          	auipc	ra,0xfffff
    80202358:	77a080e7          	jalr	1914(ra) # 80201ace <myproc>
    8020235c:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    8020235e:	05250663          	beq	a0,s2,802023aa <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    80202362:	ffffe097          	auipc	ra,0xffffe
    80202366:	38e080e7          	jalr	910(ra) # 802006f0 <acquire>
    release(lk);
    8020236a:	854a                	mv	a0,s2
    8020236c:	ffffe097          	auipc	ra,0xffffe
    80202370:	3d8080e7          	jalr	984(ra) # 80200744 <release>
  p->chan = chan;
    80202374:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    80202378:	4785                	li	a5,1
    8020237a:	cc9c                	sw	a5,24(s1)
  sched();
    8020237c:	00000097          	auipc	ra,0x0
    80202380:	dba080e7          	jalr	-582(ra) # 80202136 <sched>
  p->chan = 0;
    80202384:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    80202388:	8526                	mv	a0,s1
    8020238a:	ffffe097          	auipc	ra,0xffffe
    8020238e:	3ba080e7          	jalr	954(ra) # 80200744 <release>
    acquire(lk);
    80202392:	854a                	mv	a0,s2
    80202394:	ffffe097          	auipc	ra,0xffffe
    80202398:	35c080e7          	jalr	860(ra) # 802006f0 <acquire>
}
    8020239c:	70a2                	ld	ra,40(sp)
    8020239e:	7402                	ld	s0,32(sp)
    802023a0:	64e2                	ld	s1,24(sp)
    802023a2:	6942                	ld	s2,16(sp)
    802023a4:	69a2                	ld	s3,8(sp)
    802023a6:	6145                	addi	sp,sp,48
    802023a8:	8082                	ret
  p->chan = chan;
    802023aa:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    802023ae:	4785                	li	a5,1
    802023b0:	cd1c                	sw	a5,24(a0)
  sched();
    802023b2:	00000097          	auipc	ra,0x0
    802023b6:	d84080e7          	jalr	-636(ra) # 80202136 <sched>
  p->chan = 0;
    802023ba:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    802023be:	bff9                	j	8020239c <sleep+0x5a>

00000000802023c0 <wait>:
{
    802023c0:	715d                	addi	sp,sp,-80
    802023c2:	e486                	sd	ra,72(sp)
    802023c4:	e0a2                	sd	s0,64(sp)
    802023c6:	fc26                	sd	s1,56(sp)
    802023c8:	f84a                	sd	s2,48(sp)
    802023ca:	f44e                	sd	s3,40(sp)
    802023cc:	f052                	sd	s4,32(sp)
    802023ce:	ec56                	sd	s5,24(sp)
    802023d0:	e85a                	sd	s6,16(sp)
    802023d2:	e45e                	sd	s7,8(sp)
    802023d4:	0880                	addi	s0,sp,80
    802023d6:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    802023d8:	fffff097          	auipc	ra,0xfffff
    802023dc:	6f6080e7          	jalr	1782(ra) # 80201ace <myproc>
    802023e0:	892a                	mv	s2,a0
  acquire(&p->lock);
    802023e2:	ffffe097          	auipc	ra,0xffffe
    802023e6:	30e080e7          	jalr	782(ra) # 802006f0 <acquire>
    havekids = 0;
    802023ea:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    802023ec:	4a11                	li	s4,4
        havekids = 1;
    802023ee:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    802023f0:	00015997          	auipc	s3,0x15
    802023f4:	6f898993          	addi	s3,s3,1784 # 80217ae8 <initproc>
    802023f8:	a075                	j	802024a4 <wait+0xe4>
          pid = np->pid;
    802023fa:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout2(addr, (char *)&np->xstate, sizeof(np->xstate)) < 0) {
    802023fe:	000b0c63          	beqz	s6,80202416 <wait+0x56>
    80202402:	4611                	li	a2,4
    80202404:	03448593          	addi	a1,s1,52
    80202408:	855a                	mv	a0,s6
    8020240a:	fffff097          	auipc	ra,0xfffff
    8020240e:	fee080e7          	jalr	-18(ra) # 802013f8 <copyout2>
    80202412:	02054d63          	bltz	a0,8020244c <wait+0x8c>
          freeproc(np);
    80202416:	8526                	mv	a0,s1
    80202418:	00000097          	auipc	ra,0x0
    8020241c:	888080e7          	jalr	-1912(ra) # 80201ca0 <freeproc>
          release(&np->lock);
    80202420:	8526                	mv	a0,s1
    80202422:	ffffe097          	auipc	ra,0xffffe
    80202426:	322080e7          	jalr	802(ra) # 80200744 <release>
          release(&p->lock);
    8020242a:	854a                	mv	a0,s2
    8020242c:	ffffe097          	auipc	ra,0xffffe
    80202430:	318080e7          	jalr	792(ra) # 80200744 <release>
}
    80202434:	854e                	mv	a0,s3
    80202436:	60a6                	ld	ra,72(sp)
    80202438:	6406                	ld	s0,64(sp)
    8020243a:	74e2                	ld	s1,56(sp)
    8020243c:	7942                	ld	s2,48(sp)
    8020243e:	79a2                	ld	s3,40(sp)
    80202440:	7a02                	ld	s4,32(sp)
    80202442:	6ae2                	ld	s5,24(sp)
    80202444:	6b42                	ld	s6,16(sp)
    80202446:	6ba2                	ld	s7,8(sp)
    80202448:	6161                	addi	sp,sp,80
    8020244a:	8082                	ret
            release(&np->lock);
    8020244c:	8526                	mv	a0,s1
    8020244e:	ffffe097          	auipc	ra,0xffffe
    80202452:	2f6080e7          	jalr	758(ra) # 80200744 <release>
            release(&p->lock);
    80202456:	854a                	mv	a0,s2
    80202458:	ffffe097          	auipc	ra,0xffffe
    8020245c:	2ec080e7          	jalr	748(ra) # 80200744 <release>
            return -1;
    80202460:	59fd                	li	s3,-1
    80202462:	bfc9                	j	80202434 <wait+0x74>
    for(np = proc; np < &proc[NPROC]; np++){
    80202464:	17848493          	addi	s1,s1,376
    80202468:	03348463          	beq	s1,s3,80202490 <wait+0xd0>
      if(np->parent == p){
    8020246c:	709c                	ld	a5,32(s1)
    8020246e:	ff279be3          	bne	a5,s2,80202464 <wait+0xa4>
        acquire(&np->lock);
    80202472:	8526                	mv	a0,s1
    80202474:	ffffe097          	auipc	ra,0xffffe
    80202478:	27c080e7          	jalr	636(ra) # 802006f0 <acquire>
        if(np->state == ZOMBIE){
    8020247c:	4c9c                	lw	a5,24(s1)
    8020247e:	f7478ee3          	beq	a5,s4,802023fa <wait+0x3a>
        release(&np->lock);
    80202482:	8526                	mv	a0,s1
    80202484:	ffffe097          	auipc	ra,0xffffe
    80202488:	2c0080e7          	jalr	704(ra) # 80200744 <release>
        havekids = 1;
    8020248c:	8756                	mv	a4,s5
    8020248e:	bfd9                	j	80202464 <wait+0xa4>
    if(!havekids || p->killed){
    80202490:	c305                	beqz	a4,802024b0 <wait+0xf0>
    80202492:	03092783          	lw	a5,48(s2)
    80202496:	ef89                	bnez	a5,802024b0 <wait+0xf0>
    sleep(p, &p->lock);  //DOC: wait-sleep
    80202498:	85ca                	mv	a1,s2
    8020249a:	854a                	mv	a0,s2
    8020249c:	00000097          	auipc	ra,0x0
    802024a0:	ea6080e7          	jalr	-346(ra) # 80202342 <sleep>
    havekids = 0;
    802024a4:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    802024a6:	00011497          	auipc	s1,0x11
    802024aa:	cd248493          	addi	s1,s1,-814 # 80213178 <proc>
    802024ae:	bf7d                	j	8020246c <wait+0xac>
      release(&p->lock);
    802024b0:	854a                	mv	a0,s2
    802024b2:	ffffe097          	auipc	ra,0xffffe
    802024b6:	292080e7          	jalr	658(ra) # 80200744 <release>
      return -1;
    802024ba:	59fd                	li	s3,-1
    802024bc:	bfa5                	j	80202434 <wait+0x74>

00000000802024be <wakeup>:
{
    802024be:	7139                	addi	sp,sp,-64
    802024c0:	fc06                	sd	ra,56(sp)
    802024c2:	f822                	sd	s0,48(sp)
    802024c4:	f426                	sd	s1,40(sp)
    802024c6:	f04a                	sd	s2,32(sp)
    802024c8:	ec4e                	sd	s3,24(sp)
    802024ca:	e852                	sd	s4,16(sp)
    802024cc:	e456                	sd	s5,8(sp)
    802024ce:	0080                	addi	s0,sp,64
    802024d0:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    802024d2:	00011497          	auipc	s1,0x11
    802024d6:	ca648493          	addi	s1,s1,-858 # 80213178 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    802024da:	4985                	li	s3,1
      p->state = RUNNABLE;
    802024dc:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    802024de:	00015917          	auipc	s2,0x15
    802024e2:	60a90913          	addi	s2,s2,1546 # 80217ae8 <initproc>
    802024e6:	a811                	j	802024fa <wakeup+0x3c>
    release(&p->lock);
    802024e8:	8526                	mv	a0,s1
    802024ea:	ffffe097          	auipc	ra,0xffffe
    802024ee:	25a080e7          	jalr	602(ra) # 80200744 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    802024f2:	17848493          	addi	s1,s1,376
    802024f6:	03248063          	beq	s1,s2,80202516 <wakeup+0x58>
    acquire(&p->lock);
    802024fa:	8526                	mv	a0,s1
    802024fc:	ffffe097          	auipc	ra,0xffffe
    80202500:	1f4080e7          	jalr	500(ra) # 802006f0 <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    80202504:	4c9c                	lw	a5,24(s1)
    80202506:	ff3791e3          	bne	a5,s3,802024e8 <wakeup+0x2a>
    8020250a:	749c                	ld	a5,40(s1)
    8020250c:	fd479ee3          	bne	a5,s4,802024e8 <wakeup+0x2a>
      p->state = RUNNABLE;
    80202510:	0154ac23          	sw	s5,24(s1)
    80202514:	bfd1                	j	802024e8 <wakeup+0x2a>
}
    80202516:	70e2                	ld	ra,56(sp)
    80202518:	7442                	ld	s0,48(sp)
    8020251a:	74a2                	ld	s1,40(sp)
    8020251c:	7902                	ld	s2,32(sp)
    8020251e:	69e2                	ld	s3,24(sp)
    80202520:	6a42                	ld	s4,16(sp)
    80202522:	6aa2                	ld	s5,8(sp)
    80202524:	6121                	addi	sp,sp,64
    80202526:	8082                	ret

0000000080202528 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80202528:	7179                	addi	sp,sp,-48
    8020252a:	f406                	sd	ra,40(sp)
    8020252c:	f022                	sd	s0,32(sp)
    8020252e:	ec26                	sd	s1,24(sp)
    80202530:	e84a                	sd	s2,16(sp)
    80202532:	e44e                	sd	s3,8(sp)
    80202534:	1800                	addi	s0,sp,48
    80202536:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80202538:	00011497          	auipc	s1,0x11
    8020253c:	c4048493          	addi	s1,s1,-960 # 80213178 <proc>
    80202540:	00015997          	auipc	s3,0x15
    80202544:	5a898993          	addi	s3,s3,1448 # 80217ae8 <initproc>
    acquire(&p->lock);
    80202548:	8526                	mv	a0,s1
    8020254a:	ffffe097          	auipc	ra,0xffffe
    8020254e:	1a6080e7          	jalr	422(ra) # 802006f0 <acquire>
    if(p->pid == pid){
    80202552:	5c9c                	lw	a5,56(s1)
    80202554:	01278d63          	beq	a5,s2,8020256e <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80202558:	8526                	mv	a0,s1
    8020255a:	ffffe097          	auipc	ra,0xffffe
    8020255e:	1ea080e7          	jalr	490(ra) # 80200744 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80202562:	17848493          	addi	s1,s1,376
    80202566:	ff3491e3          	bne	s1,s3,80202548 <kill+0x20>
  }
  return -1;
    8020256a:	557d                	li	a0,-1
    8020256c:	a821                	j	80202584 <kill+0x5c>
      p->killed = 1;
    8020256e:	4785                	li	a5,1
    80202570:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    80202572:	4c98                	lw	a4,24(s1)
    80202574:	00f70f63          	beq	a4,a5,80202592 <kill+0x6a>
      release(&p->lock);
    80202578:	8526                	mv	a0,s1
    8020257a:	ffffe097          	auipc	ra,0xffffe
    8020257e:	1ca080e7          	jalr	458(ra) # 80200744 <release>
      return 0;
    80202582:	4501                	li	a0,0
}
    80202584:	70a2                	ld	ra,40(sp)
    80202586:	7402                	ld	s0,32(sp)
    80202588:	64e2                	ld	s1,24(sp)
    8020258a:	6942                	ld	s2,16(sp)
    8020258c:	69a2                	ld	s3,8(sp)
    8020258e:	6145                	addi	sp,sp,48
    80202590:	8082                	ret
        p->state = RUNNABLE;
    80202592:	4789                	li	a5,2
    80202594:	cc9c                	sw	a5,24(s1)
    80202596:	b7cd                	j	80202578 <kill+0x50>

0000000080202598 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80202598:	1101                	addi	sp,sp,-32
    8020259a:	ec06                	sd	ra,24(sp)
    8020259c:	e822                	sd	s0,16(sp)
    8020259e:	e426                	sd	s1,8(sp)
    802025a0:	1000                	addi	s0,sp,32
    802025a2:	84aa                	mv	s1,a0
    802025a4:	852e                	mv	a0,a1
    802025a6:	85b2                	mv	a1,a2
    802025a8:	8636                	mv	a2,a3
  // struct proc *p = myproc();
  if(user_dst){
    802025aa:	c891                	beqz	s1,802025be <either_copyout+0x26>
    // return copyout(p->pagetable, dst, src, len);
    return copyout2(dst, src, len);
    802025ac:	fffff097          	auipc	ra,0xfffff
    802025b0:	e4c080e7          	jalr	-436(ra) # 802013f8 <copyout2>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    802025b4:	60e2                	ld	ra,24(sp)
    802025b6:	6442                	ld	s0,16(sp)
    802025b8:	64a2                	ld	s1,8(sp)
    802025ba:	6105                	addi	sp,sp,32
    802025bc:	8082                	ret
    memmove((char *)dst, src, len);
    802025be:	0006861b          	sext.w	a2,a3
    802025c2:	ffffe097          	auipc	ra,0xffffe
    802025c6:	226080e7          	jalr	550(ra) # 802007e8 <memmove>
    return 0;
    802025ca:	8526                	mv	a0,s1
    802025cc:	b7e5                	j	802025b4 <either_copyout+0x1c>

00000000802025ce <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    802025ce:	1101                	addi	sp,sp,-32
    802025d0:	ec06                	sd	ra,24(sp)
    802025d2:	e822                	sd	s0,16(sp)
    802025d4:	e426                	sd	s1,8(sp)
    802025d6:	1000                	addi	s0,sp,32
    802025d8:	84ae                	mv	s1,a1
    802025da:	85b2                	mv	a1,a2
    802025dc:	8636                	mv	a2,a3
  // struct proc *p = myproc();
  if(user_src){
    802025de:	c891                	beqz	s1,802025f2 <either_copyin+0x24>
    // return copyin(p->pagetable, dst, src, len);
    return copyin2(dst, src, len);
    802025e0:	fffff097          	auipc	ra,0xfffff
    802025e4:	ef8080e7          	jalr	-264(ra) # 802014d8 <copyin2>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    802025e8:	60e2                	ld	ra,24(sp)
    802025ea:	6442                	ld	s0,16(sp)
    802025ec:	64a2                	ld	s1,8(sp)
    802025ee:	6105                	addi	sp,sp,32
    802025f0:	8082                	ret
    memmove(dst, (char*)src, len);
    802025f2:	0006861b          	sext.w	a2,a3
    802025f6:	ffffe097          	auipc	ra,0xffffe
    802025fa:	1f2080e7          	jalr	498(ra) # 802007e8 <memmove>
    return 0;
    802025fe:	8526                	mv	a0,s1
    80202600:	b7e5                	j	802025e8 <either_copyin+0x1a>

0000000080202602 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80202602:	715d                	addi	sp,sp,-80
    80202604:	e486                	sd	ra,72(sp)
    80202606:	e0a2                	sd	s0,64(sp)
    80202608:	fc26                	sd	s1,56(sp)
    8020260a:	f84a                	sd	s2,48(sp)
    8020260c:	f44e                	sd	s3,40(sp)
    8020260e:	f052                	sd	s4,32(sp)
    80202610:	ec56                	sd	s5,24(sp)
    80202612:	e85a                	sd	s6,16(sp)
    80202614:	e45e                	sd	s7,8(sp)
    80202616:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\nPID\tSTATE\tNAME\tMEM\n");
    80202618:	00007517          	auipc	a0,0x7
    8020261c:	08050513          	addi	a0,a0,128 # 80209698 <etext+0x698>
    80202620:	ffffe097          	auipc	ra,0xffffe
    80202624:	b70080e7          	jalr	-1168(ra) # 80200190 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80202628:	00011497          	auipc	s1,0x11
    8020262c:	cb048493          	addi	s1,s1,-848 # 802132d8 <proc+0x160>
    80202630:	00015917          	auipc	s2,0x15
    80202634:	61890913          	addi	s2,s2,1560 # 80217c48 <bcache+0x158>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80202638:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    8020263a:	00007997          	auipc	s3,0x7
    8020263e:	05698993          	addi	s3,s3,86 # 80209690 <etext+0x690>
    printf("%d\t%s\t%s\t%d", p->pid, state, p->name, p->sz);
    80202642:	00007a97          	auipc	s5,0x7
    80202646:	06ea8a93          	addi	s5,s5,110 # 802096b0 <etext+0x6b0>
    printf("\n");
    8020264a:	00007a17          	auipc	s4,0x7
    8020264e:	9d6a0a13          	addi	s4,s4,-1578 # 80209020 <etext+0x20>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80202652:	00007b97          	auipc	s7,0x7
    80202656:	716b8b93          	addi	s7,s7,1814 # 80209d68 <states.0>
    8020265a:	a01d                	j	80202680 <procdump+0x7e>
    printf("%d\t%s\t%s\t%d", p->pid, state, p->name, p->sz);
    8020265c:	ee86b703          	ld	a4,-280(a3)
    80202660:	ed86a583          	lw	a1,-296(a3)
    80202664:	8556                	mv	a0,s5
    80202666:	ffffe097          	auipc	ra,0xffffe
    8020266a:	b2a080e7          	jalr	-1238(ra) # 80200190 <printf>
    printf("\n");
    8020266e:	8552                	mv	a0,s4
    80202670:	ffffe097          	auipc	ra,0xffffe
    80202674:	b20080e7          	jalr	-1248(ra) # 80200190 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80202678:	17848493          	addi	s1,s1,376
    8020267c:	03248263          	beq	s1,s2,802026a0 <procdump+0x9e>
    if(p->state == UNUSED)
    80202680:	86a6                	mv	a3,s1
    80202682:	eb84a783          	lw	a5,-328(s1)
    80202686:	dbed                	beqz	a5,80202678 <procdump+0x76>
      state = "???";
    80202688:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8020268a:	fcfb69e3          	bltu	s6,a5,8020265c <procdump+0x5a>
    8020268e:	02079713          	slli	a4,a5,0x20
    80202692:	01d75793          	srli	a5,a4,0x1d
    80202696:	97de                	add	a5,a5,s7
    80202698:	6390                	ld	a2,0(a5)
    8020269a:	f269                	bnez	a2,8020265c <procdump+0x5a>
      state = "???";
    8020269c:	864e                	mv	a2,s3
    8020269e:	bf7d                	j	8020265c <procdump+0x5a>
  }
}
    802026a0:	60a6                	ld	ra,72(sp)
    802026a2:	6406                	ld	s0,64(sp)
    802026a4:	74e2                	ld	s1,56(sp)
    802026a6:	7942                	ld	s2,48(sp)
    802026a8:	79a2                	ld	s3,40(sp)
    802026aa:	7a02                	ld	s4,32(sp)
    802026ac:	6ae2                	ld	s5,24(sp)
    802026ae:	6b42                	ld	s6,16(sp)
    802026b0:	6ba2                	ld	s7,8(sp)
    802026b2:	6161                	addi	sp,sp,80
    802026b4:	8082                	ret

00000000802026b6 <procnum>:

uint64
procnum(void)
{
    802026b6:	1141                	addi	sp,sp,-16
    802026b8:	e422                	sd	s0,8(sp)
    802026ba:	0800                	addi	s0,sp,16
  int num = 0;
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    802026bc:	00011797          	auipc	a5,0x11
    802026c0:	abc78793          	addi	a5,a5,-1348 # 80213178 <proc>
  int num = 0;
    802026c4:	4501                	li	a0,0
  for (p = proc; p < &proc[NPROC]; p++) {
    802026c6:	00015697          	auipc	a3,0x15
    802026ca:	42268693          	addi	a3,a3,1058 # 80217ae8 <initproc>
    802026ce:	a029                	j	802026d8 <procnum+0x22>
    802026d0:	17878793          	addi	a5,a5,376
    802026d4:	00d78663          	beq	a5,a3,802026e0 <procnum+0x2a>
    if (p->state != UNUSED) {
    802026d8:	4f98                	lw	a4,24(a5)
    802026da:	db7d                	beqz	a4,802026d0 <procnum+0x1a>
      num++;
    802026dc:	2505                	addiw	a0,a0,1
    802026de:	bfcd                	j	802026d0 <procnum+0x1a>
    }
  }

  return num;
}
    802026e0:	6422                	ld	s0,8(sp)
    802026e2:	0141                	addi	sp,sp,16
    802026e4:	8082                	ret

00000000802026e6 <swtch>:
    802026e6:	00153023          	sd	ra,0(a0)
    802026ea:	00253423          	sd	sp,8(a0)
    802026ee:	e900                	sd	s0,16(a0)
    802026f0:	ed04                	sd	s1,24(a0)
    802026f2:	03253023          	sd	s2,32(a0)
    802026f6:	03353423          	sd	s3,40(a0)
    802026fa:	03453823          	sd	s4,48(a0)
    802026fe:	03553c23          	sd	s5,56(a0)
    80202702:	05653023          	sd	s6,64(a0)
    80202706:	05753423          	sd	s7,72(a0)
    8020270a:	05853823          	sd	s8,80(a0)
    8020270e:	05953c23          	sd	s9,88(a0)
    80202712:	07a53023          	sd	s10,96(a0)
    80202716:	07b53423          	sd	s11,104(a0)
    8020271a:	0005b083          	ld	ra,0(a1)
    8020271e:	0085b103          	ld	sp,8(a1)
    80202722:	6980                	ld	s0,16(a1)
    80202724:	6d84                	ld	s1,24(a1)
    80202726:	0205b903          	ld	s2,32(a1)
    8020272a:	0285b983          	ld	s3,40(a1)
    8020272e:	0305ba03          	ld	s4,48(a1)
    80202732:	0385ba83          	ld	s5,56(a1)
    80202736:	0405bb03          	ld	s6,64(a1)
    8020273a:	0485bb83          	ld	s7,72(a1)
    8020273e:	0505bc03          	ld	s8,80(a1)
    80202742:	0585bc83          	ld	s9,88(a1)
    80202746:	0605bd03          	ld	s10,96(a1)
    8020274a:	0685bd83          	ld	s11,104(a1)
    8020274e:	8082                	ret

0000000080202750 <trapinithart>:
// }

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80202750:	1141                	addi	sp,sp,-16
    80202752:	e406                	sd	ra,8(sp)
    80202754:	e022                	sd	s0,0(sp)
    80202756:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80202758:	00003797          	auipc	a5,0x3
    8020275c:	89878793          	addi	a5,a5,-1896 # 80204ff0 <kernelvec>
    80202760:	10579073          	csrw	stvec,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80202764:	100027f3          	csrr	a5,sstatus
  w_stvec((uint64)kernelvec);
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80202768:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8020276c:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    80202770:	104027f3          	csrr	a5,sie
  // enable supervisor-mode timer interrupts.
  w_sie(r_sie() | SIE_SEIE | SIE_SSIE | SIE_STIE);
    80202774:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80202778:	10479073          	csrw	sie,a5
  set_next_timeout();
    8020277c:	00003097          	auipc	ra,0x3
    80202780:	92a080e7          	jalr	-1750(ra) # 802050a6 <set_next_timeout>
  #ifdef DEBUG
  printf("trapinithart\n");
  #endif
}
    80202784:	60a2                	ld	ra,8(sp)
    80202786:	6402                	ld	s0,0(sp)
    80202788:	0141                	addi	sp,sp,16
    8020278a:	8082                	ret

000000008020278c <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8020278c:	1141                	addi	sp,sp,-16
    8020278e:	e406                	sd	ra,8(sp)
    80202790:	e022                	sd	s0,0(sp)
    80202792:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80202794:	fffff097          	auipc	ra,0xfffff
    80202798:	33a080e7          	jalr	826(ra) # 80201ace <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8020279c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    802027a0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    802027a2:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    802027a6:	00006697          	auipc	a3,0x6
    802027aa:	85a68693          	addi	a3,a3,-1958 # 80208000 <_trampoline>
    802027ae:	00006717          	auipc	a4,0x6
    802027b2:	85270713          	addi	a4,a4,-1966 # 80208000 <_trampoline>
    802027b6:	8f15                	sub	a4,a4,a3
    802027b8:	040007b7          	lui	a5,0x4000
    802027bc:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c200001>
    802027be:	07b2                	slli	a5,a5,0xc
    802027c0:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    802027c2:	10571073          	csrw	stvec,a4

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    802027c6:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    802027c8:	18002673          	csrr	a2,satp
    802027cc:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    802027ce:	7130                	ld	a2,96(a0)
    802027d0:	6138                	ld	a4,64(a0)
    802027d2:	6585                	lui	a1,0x1
    802027d4:	972e                	add	a4,a4,a1
    802027d6:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    802027d8:	7138                	ld	a4,96(a0)
    802027da:	00000617          	auipc	a2,0x0
    802027de:	13260613          	addi	a2,a2,306 # 8020290c <usertrap>
    802027e2:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    802027e4:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    802027e6:	8612                	mv	a2,tp
    802027e8:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    802027ea:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    802027ee:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    802027f2:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    802027f6:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    802027fa:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    802027fc:	6f18                	ld	a4,24(a4)
    802027fe:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  // printf("[usertrapret]p->pagetable: %p\n", p->pagetable);
  uint64 satp = MAKE_SATP(p->pagetable);
    80202802:	692c                	ld	a1,80(a0)
    80202804:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80202806:	00006717          	auipc	a4,0x6
    8020280a:	88a70713          	addi	a4,a4,-1910 # 80208090 <userret>
    8020280e:	8f15                	sub	a4,a4,a3
    80202810:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80202812:	577d                	li	a4,-1
    80202814:	177e                	slli	a4,a4,0x3f
    80202816:	8dd9                	or	a1,a1,a4
    80202818:	02000537          	lui	a0,0x2000
    8020281c:	157d                	addi	a0,a0,-1 # 1ffffff <_entry-0x7e200001>
    8020281e:	0536                	slli	a0,a0,0xd
    80202820:	9782                	jalr	a5
}
    80202822:	60a2                	ld	ra,8(sp)
    80202824:	6402                	ld	s0,0(sp)
    80202826:	0141                	addi	sp,sp,16
    80202828:	8082                	ret

000000008020282a <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    8020282a:	142027f3          	csrr	a5,scause
			consoleintr(c);
		#endif
		timer_tick();
		return 2;
	}
	else { return 0;}
    8020282e:	4501                	li	a0,0
	if ((0x8000000000000000L & scause) && 9 == (scause & 0xff)) 
    80202830:	0c07dd63          	bgez	a5,8020290a <devintr+0xe0>
int devintr(void) {
    80202834:	1101                	addi	sp,sp,-32
    80202836:	ec06                	sd	ra,24(sp)
    80202838:	e822                	sd	s0,16(sp)
    8020283a:	1000                	addi	s0,sp,32
	if ((0x8000000000000000L & scause) && 9 == (scause & 0xff)) 
    8020283c:	0ff7f713          	zext.b	a4,a5
    80202840:	46a5                	li	a3,9
    80202842:	00d70c63          	beq	a4,a3,8020285a <devintr+0x30>
	else if (0x8000000000000005L == scause) {
    80202846:	577d                	li	a4,-1
    80202848:	177e                	slli	a4,a4,0x3f
    8020284a:	0715                	addi	a4,a4,5
	else { return 0;}
    8020284c:	4501                	li	a0,0
	else if (0x8000000000000005L == scause) {
    8020284e:	06e78d63          	beq	a5,a4,802028c8 <devintr+0x9e>
}
    80202852:	60e2                	ld	ra,24(sp)
    80202854:	6442                	ld	s0,16(sp)
    80202856:	6105                	addi	sp,sp,32
    80202858:	8082                	ret
    8020285a:	e426                	sd	s1,8(sp)
		int irq = plic_claim();
    8020285c:	00004097          	auipc	ra,0x4
    80202860:	454080e7          	jalr	1108(ra) # 80206cb0 <plic_claim>
    80202864:	84aa                	mv	s1,a0
		if (UART_IRQ == irq) {
    80202866:	47a9                	li	a5,10
    80202868:	00f50963          	beq	a0,a5,8020287a <devintr+0x50>
		else if (DISK_IRQ == irq) {
    8020286c:	4785                	li	a5,1
    8020286e:	02f50e63          	beq	a0,a5,802028aa <devintr+0x80>
		return 1;
    80202872:	4505                	li	a0,1
		else if (irq) {
    80202874:	e0a1                	bnez	s1,802028b4 <devintr+0x8a>
    80202876:	64a2                	ld	s1,8(sp)
    80202878:	bfe9                	j	80202852 <devintr+0x28>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
    8020287a:	4501                	li	a0,0
    8020287c:	4581                	li	a1,0
    8020287e:	4601                	li	a2,0
    80202880:	4681                	li	a3,0
    80202882:	4889                	li	a7,2
    80202884:	00000073          	ecall
    80202888:	2501                	sext.w	a0,a0
			if (-1 != c) {
    8020288a:	57fd                	li	a5,-1
    8020288c:	00f51a63          	bne	a0,a5,802028a0 <devintr+0x76>
		if (irq) { plic_complete(irq);}
    80202890:	8526                	mv	a0,s1
    80202892:	00004097          	auipc	ra,0x4
    80202896:	448080e7          	jalr	1096(ra) # 80206cda <plic_complete>
		return 1;
    8020289a:	4505                	li	a0,1
    8020289c:	64a2                	ld	s1,8(sp)
    8020289e:	bf55                	j	80202852 <devintr+0x28>
				consoleintr(c);
    802028a0:	00004097          	auipc	ra,0x4
    802028a4:	654080e7          	jalr	1620(ra) # 80206ef4 <consoleintr>
    802028a8:	b7e5                	j	80202890 <devintr+0x66>
			disk_intr();
    802028aa:	00003097          	auipc	ra,0x3
    802028ae:	8bc080e7          	jalr	-1860(ra) # 80205166 <disk_intr>
		if (irq) { plic_complete(irq);}
    802028b2:	bff9                	j	80202890 <devintr+0x66>
			printf("unexpected interrupt irq = %d\n", irq);
    802028b4:	85a6                	mv	a1,s1
    802028b6:	00007517          	auipc	a0,0x7
    802028ba:	e3250513          	addi	a0,a0,-462 # 802096e8 <etext+0x6e8>
    802028be:	ffffe097          	auipc	ra,0xffffe
    802028c2:	8d2080e7          	jalr	-1838(ra) # 80200190 <printf>
		if (irq) { plic_complete(irq);}
    802028c6:	b7e9                	j	80202890 <devintr+0x66>
    802028c8:	4581                	li	a1,0
    802028ca:	4601                	li	a2,0
    802028cc:	4681                	li	a3,0
    802028ce:	4889                	li	a7,2
    802028d0:	00000073          	ecall
    802028d4:	2501                	sext.w	a0,a0
		while ((c = sbi_console_getchar()) != -1)
    802028d6:	57fd                	li	a5,-1
    802028d8:	02f50363          	beq	a0,a5,802028fe <devintr+0xd4>
    802028dc:	e426                	sd	s1,8(sp)
    802028de:	54fd                	li	s1,-1
			consoleintr(c);
    802028e0:	00004097          	auipc	ra,0x4
    802028e4:	614080e7          	jalr	1556(ra) # 80206ef4 <consoleintr>
    802028e8:	4501                	li	a0,0
    802028ea:	4581                	li	a1,0
    802028ec:	4601                	li	a2,0
    802028ee:	4681                	li	a3,0
    802028f0:	4889                	li	a7,2
    802028f2:	00000073          	ecall
    802028f6:	2501                	sext.w	a0,a0
		while ((c = sbi_console_getchar()) != -1)
    802028f8:	fe9514e3          	bne	a0,s1,802028e0 <devintr+0xb6>
    802028fc:	64a2                	ld	s1,8(sp)
		timer_tick();
    802028fe:	00002097          	auipc	ra,0x2
    80202902:	7ce080e7          	jalr	1998(ra) # 802050cc <timer_tick>
		return 2;
    80202906:	4509                	li	a0,2
    80202908:	b7a9                	j	80202852 <devintr+0x28>
}
    8020290a:	8082                	ret

000000008020290c <usertrap>:
{
    8020290c:	1101                	addi	sp,sp,-32
    8020290e:	ec06                	sd	ra,24(sp)
    80202910:	e822                	sd	s0,16(sp)
    80202912:	e426                	sd	s1,8(sp)
    80202914:	e04a                	sd	s2,0(sp)
    80202916:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80202918:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8020291c:	1007f793          	andi	a5,a5,256
    80202920:	e3ad                	bnez	a5,80202982 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80202922:	00002797          	auipc	a5,0x2
    80202926:	6ce78793          	addi	a5,a5,1742 # 80204ff0 <kernelvec>
    8020292a:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8020292e:	fffff097          	auipc	ra,0xfffff
    80202932:	1a0080e7          	jalr	416(ra) # 80201ace <myproc>
    80202936:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80202938:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8020293a:	14102773          	csrr	a4,sepc
    8020293e:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80202940:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80202944:	47a1                	li	a5,8
    80202946:	04f71c63          	bne	a4,a5,8020299e <usertrap+0x92>
    if(p->killed)
    8020294a:	591c                	lw	a5,48(a0)
    8020294c:	e3b9                	bnez	a5,80202992 <usertrap+0x86>
    p->trapframe->epc += 4;
    8020294e:	70b8                	ld	a4,96(s1)
    80202950:	6f1c                	ld	a5,24(a4)
    80202952:	0791                	addi	a5,a5,4
    80202954:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80202956:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8020295a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8020295e:	10079073          	csrw	sstatus,a5
    syscall();
    80202962:	00000097          	auipc	ra,0x0
    80202966:	5d4080e7          	jalr	1492(ra) # 80202f36 <syscall>
  if(p->killed)
    8020296a:	589c                	lw	a5,48(s1)
    8020296c:	ebd1                	bnez	a5,80202a00 <usertrap+0xf4>
  usertrapret();
    8020296e:	00000097          	auipc	ra,0x0
    80202972:	e1e080e7          	jalr	-482(ra) # 8020278c <usertrapret>
}
    80202976:	60e2                	ld	ra,24(sp)
    80202978:	6442                	ld	s0,16(sp)
    8020297a:	64a2                	ld	s1,8(sp)
    8020297c:	6902                	ld	s2,0(sp)
    8020297e:	6105                	addi	sp,sp,32
    80202980:	8082                	ret
    panic("usertrap: not from user mode");
    80202982:	00007517          	auipc	a0,0x7
    80202986:	d8650513          	addi	a0,a0,-634 # 80209708 <etext+0x708>
    8020298a:	ffffd097          	auipc	ra,0xffffd
    8020298e:	7bc080e7          	jalr	1980(ra) # 80200146 <panic>
      exit(-1);
    80202992:	557d                	li	a0,-1
    80202994:	00000097          	auipc	ra,0x0
    80202998:	878080e7          	jalr	-1928(ra) # 8020220c <exit>
    8020299c:	bf4d                	j	8020294e <usertrap+0x42>
  else if((which_dev = devintr()) != 0){
    8020299e:	00000097          	auipc	ra,0x0
    802029a2:	e8c080e7          	jalr	-372(ra) # 8020282a <devintr>
    802029a6:	892a                	mv	s2,a0
    802029a8:	c501                	beqz	a0,802029b0 <usertrap+0xa4>
  if(p->killed)
    802029aa:	589c                	lw	a5,48(s1)
    802029ac:	c3b1                	beqz	a5,802029f0 <usertrap+0xe4>
    802029ae:	a825                	j	802029e6 <usertrap+0xda>
  asm volatile("csrr %0, scause" : "=r" (x) );
    802029b0:	142025f3          	csrr	a1,scause
    printf("\nusertrap(): unexpected scause %p pid=%d %s\n", r_scause(), p->pid, p->name);
    802029b4:	16048693          	addi	a3,s1,352
    802029b8:	5c90                	lw	a2,56(s1)
    802029ba:	00007517          	auipc	a0,0x7
    802029be:	d6e50513          	addi	a0,a0,-658 # 80209728 <etext+0x728>
    802029c2:	ffffd097          	auipc	ra,0xffffd
    802029c6:	7ce080e7          	jalr	1998(ra) # 80200190 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    802029ca:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    802029ce:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    802029d2:	00007517          	auipc	a0,0x7
    802029d6:	d8650513          	addi	a0,a0,-634 # 80209758 <etext+0x758>
    802029da:	ffffd097          	auipc	ra,0xffffd
    802029de:	7b6080e7          	jalr	1974(ra) # 80200190 <printf>
    p->killed = 1;
    802029e2:	4785                	li	a5,1
    802029e4:	d89c                	sw	a5,48(s1)
    exit(-1);
    802029e6:	557d                	li	a0,-1
    802029e8:	00000097          	auipc	ra,0x0
    802029ec:	824080e7          	jalr	-2012(ra) # 8020220c <exit>
  if(which_dev == 2)
    802029f0:	4789                	li	a5,2
    802029f2:	f6f91ee3          	bne	s2,a5,8020296e <usertrap+0x62>
    yield();
    802029f6:	00000097          	auipc	ra,0x0
    802029fa:	910080e7          	jalr	-1776(ra) # 80202306 <yield>
    802029fe:	bf85                	j	8020296e <usertrap+0x62>
  int which_dev = 0;
    80202a00:	4901                	li	s2,0
    80202a02:	b7d5                	j	802029e6 <usertrap+0xda>

0000000080202a04 <kerneltrap>:
kerneltrap() {
    80202a04:	7179                	addi	sp,sp,-48
    80202a06:	f406                	sd	ra,40(sp)
    80202a08:	f022                	sd	s0,32(sp)
    80202a0a:	ec26                	sd	s1,24(sp)
    80202a0c:	e84a                	sd	s2,16(sp)
    80202a0e:	e44e                	sd	s3,8(sp)
    80202a10:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80202a12:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80202a16:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80202a1a:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80202a1e:	1004f793          	andi	a5,s1,256
    80202a22:	cb85                	beqz	a5,80202a52 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80202a24:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80202a28:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80202a2a:	ef85                	bnez	a5,80202a62 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80202a2c:	00000097          	auipc	ra,0x0
    80202a30:	dfe080e7          	jalr	-514(ra) # 8020282a <devintr>
    80202a34:	cd1d                	beqz	a0,80202a72 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING) {
    80202a36:	4789                	li	a5,2
    80202a38:	08f50b63          	beq	a0,a5,80202ace <kerneltrap+0xca>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80202a3c:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80202a40:	10049073          	csrw	sstatus,s1
}
    80202a44:	70a2                	ld	ra,40(sp)
    80202a46:	7402                	ld	s0,32(sp)
    80202a48:	64e2                	ld	s1,24(sp)
    80202a4a:	6942                	ld	s2,16(sp)
    80202a4c:	69a2                	ld	s3,8(sp)
    80202a4e:	6145                	addi	sp,sp,48
    80202a50:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80202a52:	00007517          	auipc	a0,0x7
    80202a56:	d2650513          	addi	a0,a0,-730 # 80209778 <etext+0x778>
    80202a5a:	ffffd097          	auipc	ra,0xffffd
    80202a5e:	6ec080e7          	jalr	1772(ra) # 80200146 <panic>
    panic("kerneltrap: interrupts enabled");
    80202a62:	00007517          	auipc	a0,0x7
    80202a66:	d3e50513          	addi	a0,a0,-706 # 802097a0 <etext+0x7a0>
    80202a6a:	ffffd097          	auipc	ra,0xffffd
    80202a6e:	6dc080e7          	jalr	1756(ra) # 80200146 <panic>
    printf("\nscause %p\n", scause);
    80202a72:	85ce                	mv	a1,s3
    80202a74:	00007517          	auipc	a0,0x7
    80202a78:	d4c50513          	addi	a0,a0,-692 # 802097c0 <etext+0x7c0>
    80202a7c:	ffffd097          	auipc	ra,0xffffd
    80202a80:	714080e7          	jalr	1812(ra) # 80200190 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80202a84:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80202a88:	14302673          	csrr	a2,stval
  asm volatile("mv %0, tp" : "=r" (x) );
    80202a8c:	8692                	mv	a3,tp
    printf("sepc=%p stval=%p hart=%d\n", r_sepc(), r_stval(), r_tp());
    80202a8e:	00007517          	auipc	a0,0x7
    80202a92:	d4250513          	addi	a0,a0,-702 # 802097d0 <etext+0x7d0>
    80202a96:	ffffd097          	auipc	ra,0xffffd
    80202a9a:	6fa080e7          	jalr	1786(ra) # 80200190 <printf>
    struct proc *p = myproc();
    80202a9e:	fffff097          	auipc	ra,0xfffff
    80202aa2:	030080e7          	jalr	48(ra) # 80201ace <myproc>
    if (p != 0) {
    80202aa6:	cd01                	beqz	a0,80202abe <kerneltrap+0xba>
      printf("pid: %d, name: %s\n", p->pid, p->name);
    80202aa8:	16050613          	addi	a2,a0,352
    80202aac:	5d0c                	lw	a1,56(a0)
    80202aae:	00007517          	auipc	a0,0x7
    80202ab2:	d4250513          	addi	a0,a0,-702 # 802097f0 <etext+0x7f0>
    80202ab6:	ffffd097          	auipc	ra,0xffffd
    80202aba:	6da080e7          	jalr	1754(ra) # 80200190 <printf>
    panic("kerneltrap");
    80202abe:	00007517          	auipc	a0,0x7
    80202ac2:	d4a50513          	addi	a0,a0,-694 # 80209808 <etext+0x808>
    80202ac6:	ffffd097          	auipc	ra,0xffffd
    80202aca:	680080e7          	jalr	1664(ra) # 80200146 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING) {
    80202ace:	fffff097          	auipc	ra,0xfffff
    80202ad2:	000080e7          	jalr	ra # 80201ace <myproc>
    80202ad6:	d13d                	beqz	a0,80202a3c <kerneltrap+0x38>
    80202ad8:	fffff097          	auipc	ra,0xfffff
    80202adc:	ff6080e7          	jalr	-10(ra) # 80201ace <myproc>
    80202ae0:	4d18                	lw	a4,24(a0)
    80202ae2:	478d                	li	a5,3
    80202ae4:	f4f71ce3          	bne	a4,a5,80202a3c <kerneltrap+0x38>
    yield();
    80202ae8:	00000097          	auipc	ra,0x0
    80202aec:	81e080e7          	jalr	-2018(ra) # 80202306 <yield>
    80202af0:	b7b1                	j	80202a3c <kerneltrap+0x38>

0000000080202af2 <trapframedump>:

void trapframedump(struct trapframe *tf)
{
    80202af2:	1101                	addi	sp,sp,-32
    80202af4:	ec06                	sd	ra,24(sp)
    80202af6:	e822                	sd	s0,16(sp)
    80202af8:	e426                	sd	s1,8(sp)
    80202afa:	1000                	addi	s0,sp,32
    80202afc:	84aa                	mv	s1,a0
  printf("a0: %p\t", tf->a0);
    80202afe:	792c                	ld	a1,112(a0)
    80202b00:	00007517          	auipc	a0,0x7
    80202b04:	d1850513          	addi	a0,a0,-744 # 80209818 <etext+0x818>
    80202b08:	ffffd097          	auipc	ra,0xffffd
    80202b0c:	688080e7          	jalr	1672(ra) # 80200190 <printf>
  printf("a1: %p\t", tf->a1);
    80202b10:	7cac                	ld	a1,120(s1)
    80202b12:	00007517          	auipc	a0,0x7
    80202b16:	d0e50513          	addi	a0,a0,-754 # 80209820 <etext+0x820>
    80202b1a:	ffffd097          	auipc	ra,0xffffd
    80202b1e:	676080e7          	jalr	1654(ra) # 80200190 <printf>
  printf("a2: %p\t", tf->a2);
    80202b22:	60cc                	ld	a1,128(s1)
    80202b24:	00007517          	auipc	a0,0x7
    80202b28:	d0450513          	addi	a0,a0,-764 # 80209828 <etext+0x828>
    80202b2c:	ffffd097          	auipc	ra,0xffffd
    80202b30:	664080e7          	jalr	1636(ra) # 80200190 <printf>
  printf("a3: %p\n", tf->a3);
    80202b34:	64cc                	ld	a1,136(s1)
    80202b36:	00007517          	auipc	a0,0x7
    80202b3a:	cfa50513          	addi	a0,a0,-774 # 80209830 <etext+0x830>
    80202b3e:	ffffd097          	auipc	ra,0xffffd
    80202b42:	652080e7          	jalr	1618(ra) # 80200190 <printf>
  printf("a4: %p\t", tf->a4);
    80202b46:	68cc                	ld	a1,144(s1)
    80202b48:	00007517          	auipc	a0,0x7
    80202b4c:	cf050513          	addi	a0,a0,-784 # 80209838 <etext+0x838>
    80202b50:	ffffd097          	auipc	ra,0xffffd
    80202b54:	640080e7          	jalr	1600(ra) # 80200190 <printf>
  printf("a5: %p\t", tf->a5);
    80202b58:	6ccc                	ld	a1,152(s1)
    80202b5a:	00007517          	auipc	a0,0x7
    80202b5e:	ce650513          	addi	a0,a0,-794 # 80209840 <etext+0x840>
    80202b62:	ffffd097          	auipc	ra,0xffffd
    80202b66:	62e080e7          	jalr	1582(ra) # 80200190 <printf>
  printf("a6: %p\t", tf->a6);
    80202b6a:	70cc                	ld	a1,160(s1)
    80202b6c:	00007517          	auipc	a0,0x7
    80202b70:	cdc50513          	addi	a0,a0,-804 # 80209848 <etext+0x848>
    80202b74:	ffffd097          	auipc	ra,0xffffd
    80202b78:	61c080e7          	jalr	1564(ra) # 80200190 <printf>
  printf("a7: %p\n", tf->a7);
    80202b7c:	74cc                	ld	a1,168(s1)
    80202b7e:	00007517          	auipc	a0,0x7
    80202b82:	cd250513          	addi	a0,a0,-814 # 80209850 <etext+0x850>
    80202b86:	ffffd097          	auipc	ra,0xffffd
    80202b8a:	60a080e7          	jalr	1546(ra) # 80200190 <printf>
  printf("t0: %p\t", tf->t0);
    80202b8e:	64ac                	ld	a1,72(s1)
    80202b90:	00007517          	auipc	a0,0x7
    80202b94:	cc850513          	addi	a0,a0,-824 # 80209858 <etext+0x858>
    80202b98:	ffffd097          	auipc	ra,0xffffd
    80202b9c:	5f8080e7          	jalr	1528(ra) # 80200190 <printf>
  printf("t1: %p\t", tf->t1);
    80202ba0:	68ac                	ld	a1,80(s1)
    80202ba2:	00007517          	auipc	a0,0x7
    80202ba6:	cbe50513          	addi	a0,a0,-834 # 80209860 <etext+0x860>
    80202baa:	ffffd097          	auipc	ra,0xffffd
    80202bae:	5e6080e7          	jalr	1510(ra) # 80200190 <printf>
  printf("t2: %p\t", tf->t2);
    80202bb2:	6cac                	ld	a1,88(s1)
    80202bb4:	00007517          	auipc	a0,0x7
    80202bb8:	cb450513          	addi	a0,a0,-844 # 80209868 <etext+0x868>
    80202bbc:	ffffd097          	auipc	ra,0xffffd
    80202bc0:	5d4080e7          	jalr	1492(ra) # 80200190 <printf>
  printf("t3: %p\n", tf->t3);
    80202bc4:	1004b583          	ld	a1,256(s1)
    80202bc8:	00007517          	auipc	a0,0x7
    80202bcc:	ca850513          	addi	a0,a0,-856 # 80209870 <etext+0x870>
    80202bd0:	ffffd097          	auipc	ra,0xffffd
    80202bd4:	5c0080e7          	jalr	1472(ra) # 80200190 <printf>
  printf("t4: %p\t", tf->t4);
    80202bd8:	1084b583          	ld	a1,264(s1)
    80202bdc:	00007517          	auipc	a0,0x7
    80202be0:	c9c50513          	addi	a0,a0,-868 # 80209878 <etext+0x878>
    80202be4:	ffffd097          	auipc	ra,0xffffd
    80202be8:	5ac080e7          	jalr	1452(ra) # 80200190 <printf>
  printf("t5: %p\t", tf->t5);
    80202bec:	1104b583          	ld	a1,272(s1)
    80202bf0:	00007517          	auipc	a0,0x7
    80202bf4:	c9050513          	addi	a0,a0,-880 # 80209880 <etext+0x880>
    80202bf8:	ffffd097          	auipc	ra,0xffffd
    80202bfc:	598080e7          	jalr	1432(ra) # 80200190 <printf>
  printf("t6: %p\t", tf->t6);
    80202c00:	1184b583          	ld	a1,280(s1)
    80202c04:	00007517          	auipc	a0,0x7
    80202c08:	c8450513          	addi	a0,a0,-892 # 80209888 <etext+0x888>
    80202c0c:	ffffd097          	auipc	ra,0xffffd
    80202c10:	584080e7          	jalr	1412(ra) # 80200190 <printf>
  printf("s0: %p\n", tf->s0);
    80202c14:	70ac                	ld	a1,96(s1)
    80202c16:	00007517          	auipc	a0,0x7
    80202c1a:	c7a50513          	addi	a0,a0,-902 # 80209890 <etext+0x890>
    80202c1e:	ffffd097          	auipc	ra,0xffffd
    80202c22:	572080e7          	jalr	1394(ra) # 80200190 <printf>
  printf("s1: %p\t", tf->s1);
    80202c26:	74ac                	ld	a1,104(s1)
    80202c28:	00007517          	auipc	a0,0x7
    80202c2c:	c7050513          	addi	a0,a0,-912 # 80209898 <etext+0x898>
    80202c30:	ffffd097          	auipc	ra,0xffffd
    80202c34:	560080e7          	jalr	1376(ra) # 80200190 <printf>
  printf("s2: %p\t", tf->s2);
    80202c38:	78cc                	ld	a1,176(s1)
    80202c3a:	00007517          	auipc	a0,0x7
    80202c3e:	c6650513          	addi	a0,a0,-922 # 802098a0 <etext+0x8a0>
    80202c42:	ffffd097          	auipc	ra,0xffffd
    80202c46:	54e080e7          	jalr	1358(ra) # 80200190 <printf>
  printf("s3: %p\t", tf->s3);
    80202c4a:	7ccc                	ld	a1,184(s1)
    80202c4c:	00007517          	auipc	a0,0x7
    80202c50:	c5c50513          	addi	a0,a0,-932 # 802098a8 <etext+0x8a8>
    80202c54:	ffffd097          	auipc	ra,0xffffd
    80202c58:	53c080e7          	jalr	1340(ra) # 80200190 <printf>
  printf("s4: %p\n", tf->s4);
    80202c5c:	60ec                	ld	a1,192(s1)
    80202c5e:	00007517          	auipc	a0,0x7
    80202c62:	c5250513          	addi	a0,a0,-942 # 802098b0 <etext+0x8b0>
    80202c66:	ffffd097          	auipc	ra,0xffffd
    80202c6a:	52a080e7          	jalr	1322(ra) # 80200190 <printf>
  printf("s5: %p\t", tf->s5);
    80202c6e:	64ec                	ld	a1,200(s1)
    80202c70:	00007517          	auipc	a0,0x7
    80202c74:	c4850513          	addi	a0,a0,-952 # 802098b8 <etext+0x8b8>
    80202c78:	ffffd097          	auipc	ra,0xffffd
    80202c7c:	518080e7          	jalr	1304(ra) # 80200190 <printf>
  printf("s6: %p\t", tf->s6);
    80202c80:	68ec                	ld	a1,208(s1)
    80202c82:	00007517          	auipc	a0,0x7
    80202c86:	c3e50513          	addi	a0,a0,-962 # 802098c0 <etext+0x8c0>
    80202c8a:	ffffd097          	auipc	ra,0xffffd
    80202c8e:	506080e7          	jalr	1286(ra) # 80200190 <printf>
  printf("s7: %p\t", tf->s7);
    80202c92:	6cec                	ld	a1,216(s1)
    80202c94:	00007517          	auipc	a0,0x7
    80202c98:	c3450513          	addi	a0,a0,-972 # 802098c8 <etext+0x8c8>
    80202c9c:	ffffd097          	auipc	ra,0xffffd
    80202ca0:	4f4080e7          	jalr	1268(ra) # 80200190 <printf>
  printf("s8: %p\n", tf->s8);
    80202ca4:	70ec                	ld	a1,224(s1)
    80202ca6:	00007517          	auipc	a0,0x7
    80202caa:	c2a50513          	addi	a0,a0,-982 # 802098d0 <etext+0x8d0>
    80202cae:	ffffd097          	auipc	ra,0xffffd
    80202cb2:	4e2080e7          	jalr	1250(ra) # 80200190 <printf>
  printf("s9: %p\t", tf->s9);
    80202cb6:	74ec                	ld	a1,232(s1)
    80202cb8:	00007517          	auipc	a0,0x7
    80202cbc:	c2050513          	addi	a0,a0,-992 # 802098d8 <etext+0x8d8>
    80202cc0:	ffffd097          	auipc	ra,0xffffd
    80202cc4:	4d0080e7          	jalr	1232(ra) # 80200190 <printf>
  printf("s10: %p\t", tf->s10);
    80202cc8:	78ec                	ld	a1,240(s1)
    80202cca:	00007517          	auipc	a0,0x7
    80202cce:	c1650513          	addi	a0,a0,-1002 # 802098e0 <etext+0x8e0>
    80202cd2:	ffffd097          	auipc	ra,0xffffd
    80202cd6:	4be080e7          	jalr	1214(ra) # 80200190 <printf>
  printf("s11: %p\t", tf->s11);
    80202cda:	7cec                	ld	a1,248(s1)
    80202cdc:	00007517          	auipc	a0,0x7
    80202ce0:	c1450513          	addi	a0,a0,-1004 # 802098f0 <etext+0x8f0>
    80202ce4:	ffffd097          	auipc	ra,0xffffd
    80202ce8:	4ac080e7          	jalr	1196(ra) # 80200190 <printf>
  printf("ra: %p\n", tf->ra);
    80202cec:	748c                	ld	a1,40(s1)
    80202cee:	00007517          	auipc	a0,0x7
    80202cf2:	90250513          	addi	a0,a0,-1790 # 802095f0 <etext+0x5f0>
    80202cf6:	ffffd097          	auipc	ra,0xffffd
    80202cfa:	49a080e7          	jalr	1178(ra) # 80200190 <printf>
  printf("sp: %p\t", tf->sp);
    80202cfe:	788c                	ld	a1,48(s1)
    80202d00:	00007517          	auipc	a0,0x7
    80202d04:	c0050513          	addi	a0,a0,-1024 # 80209900 <etext+0x900>
    80202d08:	ffffd097          	auipc	ra,0xffffd
    80202d0c:	488080e7          	jalr	1160(ra) # 80200190 <printf>
  printf("gp: %p\t", tf->gp);
    80202d10:	7c8c                	ld	a1,56(s1)
    80202d12:	00007517          	auipc	a0,0x7
    80202d16:	bf650513          	addi	a0,a0,-1034 # 80209908 <etext+0x908>
    80202d1a:	ffffd097          	auipc	ra,0xffffd
    80202d1e:	476080e7          	jalr	1142(ra) # 80200190 <printf>
  printf("tp: %p\t", tf->tp);
    80202d22:	60ac                	ld	a1,64(s1)
    80202d24:	00007517          	auipc	a0,0x7
    80202d28:	bec50513          	addi	a0,a0,-1044 # 80209910 <etext+0x910>
    80202d2c:	ffffd097          	auipc	ra,0xffffd
    80202d30:	464080e7          	jalr	1124(ra) # 80200190 <printf>
  printf("epc: %p\n", tf->epc);
    80202d34:	6c8c                	ld	a1,24(s1)
    80202d36:	00007517          	auipc	a0,0x7
    80202d3a:	be250513          	addi	a0,a0,-1054 # 80209918 <etext+0x918>
    80202d3e:	ffffd097          	auipc	ra,0xffffd
    80202d42:	452080e7          	jalr	1106(ra) # 80200190 <printf>
}
    80202d46:	60e2                	ld	ra,24(sp)
    80202d48:	6442                	ld	s0,16(sp)
    80202d4a:	64a2                	ld	s1,8(sp)
    80202d4c:	6105                	addi	sp,sp,32
    80202d4e:	8082                	ret

0000000080202d50 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80202d50:	1101                	addi	sp,sp,-32
    80202d52:	ec06                	sd	ra,24(sp)
    80202d54:	e822                	sd	s0,16(sp)
    80202d56:	e426                	sd	s1,8(sp)
    80202d58:	1000                	addi	s0,sp,32
    80202d5a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80202d5c:	fffff097          	auipc	ra,0xfffff
    80202d60:	d72080e7          	jalr	-654(ra) # 80201ace <myproc>
  switch (n) {
    80202d64:	4795                	li	a5,5
    80202d66:	0497e163          	bltu	a5,s1,80202da8 <argraw+0x58>
    80202d6a:	048a                	slli	s1,s1,0x2
    80202d6c:	00007717          	auipc	a4,0x7
    80202d70:	02470713          	addi	a4,a4,36 # 80209d90 <states.0+0x28>
    80202d74:	94ba                	add	s1,s1,a4
    80202d76:	409c                	lw	a5,0(s1)
    80202d78:	97ba                	add	a5,a5,a4
    80202d7a:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80202d7c:	713c                	ld	a5,96(a0)
    80202d7e:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80202d80:	60e2                	ld	ra,24(sp)
    80202d82:	6442                	ld	s0,16(sp)
    80202d84:	64a2                	ld	s1,8(sp)
    80202d86:	6105                	addi	sp,sp,32
    80202d88:	8082                	ret
    return p->trapframe->a1;
    80202d8a:	713c                	ld	a5,96(a0)
    80202d8c:	7fa8                	ld	a0,120(a5)
    80202d8e:	bfcd                	j	80202d80 <argraw+0x30>
    return p->trapframe->a2;
    80202d90:	713c                	ld	a5,96(a0)
    80202d92:	63c8                	ld	a0,128(a5)
    80202d94:	b7f5                	j	80202d80 <argraw+0x30>
    return p->trapframe->a3;
    80202d96:	713c                	ld	a5,96(a0)
    80202d98:	67c8                	ld	a0,136(a5)
    80202d9a:	b7dd                	j	80202d80 <argraw+0x30>
    return p->trapframe->a4;
    80202d9c:	713c                	ld	a5,96(a0)
    80202d9e:	6bc8                	ld	a0,144(a5)
    80202da0:	b7c5                	j	80202d80 <argraw+0x30>
    return p->trapframe->a5;
    80202da2:	713c                	ld	a5,96(a0)
    80202da4:	6fc8                	ld	a0,152(a5)
    80202da6:	bfe9                	j	80202d80 <argraw+0x30>
  panic("argraw");
    80202da8:	00007517          	auipc	a0,0x7
    80202dac:	b8050513          	addi	a0,a0,-1152 # 80209928 <etext+0x928>
    80202db0:	ffffd097          	auipc	ra,0xffffd
    80202db4:	396080e7          	jalr	918(ra) # 80200146 <panic>

0000000080202db8 <sys_sysinfo>:
    return 0;
}

uint64
sys_sysinfo(void)
{
    80202db8:	7179                	addi	sp,sp,-48
    80202dba:	f406                	sd	ra,40(sp)
    80202dbc:	f022                	sd	s0,32(sp)
    80202dbe:	ec26                	sd	s1,24(sp)
    80202dc0:	1800                	addi	s0,sp,48
  *ip = argraw(n);
    80202dc2:	4501                	li	a0,0
    80202dc4:	00000097          	auipc	ra,0x0
    80202dc8:	f8c080e7          	jalr	-116(ra) # 80202d50 <argraw>
    80202dcc:	84aa                	mv	s1,a0
  if (argaddr(0, &addr) < 0) {
    return -1;
  }

  struct sysinfo info;
  info.freemem = freemem_amount();
    80202dce:	ffffe097          	auipc	ra,0xffffe
    80202dd2:	81c080e7          	jalr	-2020(ra) # 802005ea <freemem_amount>
    80202dd6:	fca43823          	sd	a0,-48(s0)
  info.nproc = procnum();
    80202dda:	00000097          	auipc	ra,0x0
    80202dde:	8dc080e7          	jalr	-1828(ra) # 802026b6 <procnum>
    80202de2:	fca43c23          	sd	a0,-40(s0)

  // if (copyout(p->pagetable, addr, (char *)&info, sizeof(info)) < 0) {
  if (copyout2(addr, (char *)&info, sizeof(info)) < 0) {
    80202de6:	4641                	li	a2,16
    80202de8:	fd040593          	addi	a1,s0,-48
    80202dec:	8526                	mv	a0,s1
    80202dee:	ffffe097          	auipc	ra,0xffffe
    80202df2:	60a080e7          	jalr	1546(ra) # 802013f8 <copyout2>
    return -1;
  }

  return 0;
    80202df6:	957d                	srai	a0,a0,0x3f
    80202df8:	70a2                	ld	ra,40(sp)
    80202dfa:	7402                	ld	s0,32(sp)
    80202dfc:	64e2                	ld	s1,24(sp)
    80202dfe:	6145                	addi	sp,sp,48
    80202e00:	8082                	ret

0000000080202e02 <fetchaddr>:
{
    80202e02:	1101                	addi	sp,sp,-32
    80202e04:	ec06                	sd	ra,24(sp)
    80202e06:	e822                	sd	s0,16(sp)
    80202e08:	e426                	sd	s1,8(sp)
    80202e0a:	e04a                	sd	s2,0(sp)
    80202e0c:	1000                	addi	s0,sp,32
    80202e0e:	84aa                	mv	s1,a0
    80202e10:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80202e12:	fffff097          	auipc	ra,0xfffff
    80202e16:	cbc080e7          	jalr	-836(ra) # 80201ace <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80202e1a:	653c                	ld	a5,72(a0)
    80202e1c:	02f4f763          	bgeu	s1,a5,80202e4a <fetchaddr+0x48>
    80202e20:	00848713          	addi	a4,s1,8
    80202e24:	02e7e563          	bltu	a5,a4,80202e4e <fetchaddr+0x4c>
  if(copyin2((char *)ip, addr, sizeof(*ip)) != 0)
    80202e28:	4621                	li	a2,8
    80202e2a:	85a6                	mv	a1,s1
    80202e2c:	854a                	mv	a0,s2
    80202e2e:	ffffe097          	auipc	ra,0xffffe
    80202e32:	6aa080e7          	jalr	1706(ra) # 802014d8 <copyin2>
    80202e36:	00a03533          	snez	a0,a0
    80202e3a:	40a00533          	neg	a0,a0
}
    80202e3e:	60e2                	ld	ra,24(sp)
    80202e40:	6442                	ld	s0,16(sp)
    80202e42:	64a2                	ld	s1,8(sp)
    80202e44:	6902                	ld	s2,0(sp)
    80202e46:	6105                	addi	sp,sp,32
    80202e48:	8082                	ret
    return -1;
    80202e4a:	557d                	li	a0,-1
    80202e4c:	bfcd                	j	80202e3e <fetchaddr+0x3c>
    80202e4e:	557d                	li	a0,-1
    80202e50:	b7fd                	j	80202e3e <fetchaddr+0x3c>

0000000080202e52 <fetchstr>:
{
    80202e52:	1101                	addi	sp,sp,-32
    80202e54:	ec06                	sd	ra,24(sp)
    80202e56:	e822                	sd	s0,16(sp)
    80202e58:	e426                	sd	s1,8(sp)
    80202e5a:	1000                	addi	s0,sp,32
    80202e5c:	84ae                	mv	s1,a1
  int err = copyinstr2(buf, addr, max);
    80202e5e:	85aa                	mv	a1,a0
    80202e60:	8526                	mv	a0,s1
    80202e62:	ffffe097          	auipc	ra,0xffffe
    80202e66:	784080e7          	jalr	1924(ra) # 802015e6 <copyinstr2>
  if(err < 0)
    80202e6a:	00054763          	bltz	a0,80202e78 <fetchstr+0x26>
  return strlen(buf);
    80202e6e:	8526                	mv	a0,s1
    80202e70:	ffffe097          	auipc	ra,0xffffe
    80202e74:	a98080e7          	jalr	-1384(ra) # 80200908 <strlen>
}
    80202e78:	60e2                	ld	ra,24(sp)
    80202e7a:	6442                	ld	s0,16(sp)
    80202e7c:	64a2                	ld	s1,8(sp)
    80202e7e:	6105                	addi	sp,sp,32
    80202e80:	8082                	ret

0000000080202e82 <argint>:
{
    80202e82:	1101                	addi	sp,sp,-32
    80202e84:	ec06                	sd	ra,24(sp)
    80202e86:	e822                	sd	s0,16(sp)
    80202e88:	e426                	sd	s1,8(sp)
    80202e8a:	1000                	addi	s0,sp,32
    80202e8c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80202e8e:	00000097          	auipc	ra,0x0
    80202e92:	ec2080e7          	jalr	-318(ra) # 80202d50 <argraw>
    80202e96:	c088                	sw	a0,0(s1)
}
    80202e98:	4501                	li	a0,0
    80202e9a:	60e2                	ld	ra,24(sp)
    80202e9c:	6442                	ld	s0,16(sp)
    80202e9e:	64a2                	ld	s1,8(sp)
    80202ea0:	6105                	addi	sp,sp,32
    80202ea2:	8082                	ret

0000000080202ea4 <sys_test_proc>:
sys_test_proc(void) {
    80202ea4:	1101                	addi	sp,sp,-32
    80202ea6:	ec06                	sd	ra,24(sp)
    80202ea8:	e822                	sd	s0,16(sp)
    80202eaa:	1000                	addi	s0,sp,32
    argint(0, &n);
    80202eac:	fec40593          	addi	a1,s0,-20
    80202eb0:	4501                	li	a0,0
    80202eb2:	00000097          	auipc	ra,0x0
    80202eb6:	fd0080e7          	jalr	-48(ra) # 80202e82 <argint>
    printf("hello world from proc %d, hart %d, arg %d\n", myproc()->pid, r_tp(), n);
    80202eba:	fffff097          	auipc	ra,0xfffff
    80202ebe:	c14080e7          	jalr	-1004(ra) # 80201ace <myproc>
    80202ec2:	8612                	mv	a2,tp
    80202ec4:	fec42683          	lw	a3,-20(s0)
    80202ec8:	5d0c                	lw	a1,56(a0)
    80202eca:	00007517          	auipc	a0,0x7
    80202ece:	a6650513          	addi	a0,a0,-1434 # 80209930 <etext+0x930>
    80202ed2:	ffffd097          	auipc	ra,0xffffd
    80202ed6:	2be080e7          	jalr	702(ra) # 80200190 <printf>
}
    80202eda:	4501                	li	a0,0
    80202edc:	60e2                	ld	ra,24(sp)
    80202ede:	6442                	ld	s0,16(sp)
    80202ee0:	6105                	addi	sp,sp,32
    80202ee2:	8082                	ret

0000000080202ee4 <argaddr>:
{
    80202ee4:	1101                	addi	sp,sp,-32
    80202ee6:	ec06                	sd	ra,24(sp)
    80202ee8:	e822                	sd	s0,16(sp)
    80202eea:	e426                	sd	s1,8(sp)
    80202eec:	1000                	addi	s0,sp,32
    80202eee:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80202ef0:	00000097          	auipc	ra,0x0
    80202ef4:	e60080e7          	jalr	-416(ra) # 80202d50 <argraw>
    80202ef8:	e088                	sd	a0,0(s1)
}
    80202efa:	4501                	li	a0,0
    80202efc:	60e2                	ld	ra,24(sp)
    80202efe:	6442                	ld	s0,16(sp)
    80202f00:	64a2                	ld	s1,8(sp)
    80202f02:	6105                	addi	sp,sp,32
    80202f04:	8082                	ret

0000000080202f06 <argstr>:
{
    80202f06:	1101                	addi	sp,sp,-32
    80202f08:	ec06                	sd	ra,24(sp)
    80202f0a:	e822                	sd	s0,16(sp)
    80202f0c:	e426                	sd	s1,8(sp)
    80202f0e:	e04a                	sd	s2,0(sp)
    80202f10:	1000                	addi	s0,sp,32
    80202f12:	84ae                	mv	s1,a1
    80202f14:	8932                	mv	s2,a2
  *ip = argraw(n);
    80202f16:	00000097          	auipc	ra,0x0
    80202f1a:	e3a080e7          	jalr	-454(ra) # 80202d50 <argraw>
  return fetchstr(addr, buf, max);
    80202f1e:	864a                	mv	a2,s2
    80202f20:	85a6                	mv	a1,s1
    80202f22:	00000097          	auipc	ra,0x0
    80202f26:	f30080e7          	jalr	-208(ra) # 80202e52 <fetchstr>
}
    80202f2a:	60e2                	ld	ra,24(sp)
    80202f2c:	6442                	ld	s0,16(sp)
    80202f2e:	64a2                	ld	s1,8(sp)
    80202f30:	6902                	ld	s2,0(sp)
    80202f32:	6105                	addi	sp,sp,32
    80202f34:	8082                	ret

0000000080202f36 <syscall>:
{
    80202f36:	7179                	addi	sp,sp,-48
    80202f38:	f406                	sd	ra,40(sp)
    80202f3a:	f022                	sd	s0,32(sp)
    80202f3c:	ec26                	sd	s1,24(sp)
    80202f3e:	e84a                	sd	s2,16(sp)
    80202f40:	e44e                	sd	s3,8(sp)
    80202f42:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80202f44:	fffff097          	auipc	ra,0xfffff
    80202f48:	b8a080e7          	jalr	-1142(ra) # 80201ace <myproc>
    80202f4c:	84aa                	mv	s1,a0
  num = p->trapframe->a7;
    80202f4e:	06053903          	ld	s2,96(a0)
    80202f52:	0a893783          	ld	a5,168(s2)
    80202f56:	0007899b          	sext.w	s3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80202f5a:	37fd                	addiw	a5,a5,-1
    80202f5c:	4765                	li	a4,25
    80202f5e:	04f76763          	bltu	a4,a5,80202fac <syscall+0x76>
    80202f62:	00399713          	slli	a4,s3,0x3
    80202f66:	00007797          	auipc	a5,0x7
    80202f6a:	e4278793          	addi	a5,a5,-446 # 80209da8 <syscalls>
    80202f6e:	97ba                	add	a5,a5,a4
    80202f70:	639c                	ld	a5,0(a5)
    80202f72:	cf8d                	beqz	a5,80202fac <syscall+0x76>
    p->trapframe->a0 = syscalls[num]();
    80202f74:	9782                	jalr	a5
    80202f76:	06a93823          	sd	a0,112(s2)
    if ((p->tmask & (1 << num)) != 0) {
    80202f7a:	1704a783          	lw	a5,368(s1)
    80202f7e:	4137d7bb          	sraw	a5,a5,s3
    80202f82:	8b85                	andi	a5,a5,1
    80202f84:	c3b9                	beqz	a5,80202fca <syscall+0x94>
      printf("pid %d: %s -> %d\n", p->pid, sysnames[num], p->trapframe->a0);
    80202f86:	70b8                	ld	a4,96(s1)
    80202f88:	098e                	slli	s3,s3,0x3
    80202f8a:	00007797          	auipc	a5,0x7
    80202f8e:	e1e78793          	addi	a5,a5,-482 # 80209da8 <syscalls>
    80202f92:	97ce                	add	a5,a5,s3
    80202f94:	7b34                	ld	a3,112(a4)
    80202f96:	6ff0                	ld	a2,216(a5)
    80202f98:	5c8c                	lw	a1,56(s1)
    80202f9a:	00007517          	auipc	a0,0x7
    80202f9e:	9c650513          	addi	a0,a0,-1594 # 80209960 <etext+0x960>
    80202fa2:	ffffd097          	auipc	ra,0xffffd
    80202fa6:	1ee080e7          	jalr	494(ra) # 80200190 <printf>
    80202faa:	a005                	j	80202fca <syscall+0x94>
    printf("pid %d %s: unknown sys call %d\n",
    80202fac:	86ce                	mv	a3,s3
    80202fae:	16048613          	addi	a2,s1,352
    80202fb2:	5c8c                	lw	a1,56(s1)
    80202fb4:	00007517          	auipc	a0,0x7
    80202fb8:	9c450513          	addi	a0,a0,-1596 # 80209978 <etext+0x978>
    80202fbc:	ffffd097          	auipc	ra,0xffffd
    80202fc0:	1d4080e7          	jalr	468(ra) # 80200190 <printf>
    p->trapframe->a0 = -1;
    80202fc4:	70bc                	ld	a5,96(s1)
    80202fc6:	577d                	li	a4,-1
    80202fc8:	fbb8                	sd	a4,112(a5)
}
    80202fca:	70a2                	ld	ra,40(sp)
    80202fcc:	7402                	ld	s0,32(sp)
    80202fce:	64e2                	ld	s1,24(sp)
    80202fd0:	6942                	ld	s2,16(sp)
    80202fd2:	69a2                	ld	s3,8(sp)
    80202fd4:	6145                	addi	sp,sp,48
    80202fd6:	8082                	ret

0000000080202fd8 <sys_exec>:

extern int exec(char *path, char **argv);

uint64
sys_exec(void)
{
    80202fd8:	db010113          	addi	sp,sp,-592
    80202fdc:	24113423          	sd	ra,584(sp)
    80202fe0:	24813023          	sd	s0,576(sp)
    80202fe4:	23213823          	sd	s2,560(sp)
    80202fe8:	0c80                	addi	s0,sp,592
  char path[FAT32_MAX_PATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, FAT32_MAX_PATH) < 0 || argaddr(1, &uargv) < 0){
    80202fea:	10400613          	li	a2,260
    80202fee:	ec840593          	addi	a1,s0,-312
    80202ff2:	4501                	li	a0,0
    80202ff4:	00000097          	auipc	ra,0x0
    80202ff8:	f12080e7          	jalr	-238(ra) # 80202f06 <argstr>
    return -1;
    80202ffc:	597d                	li	s2,-1
  if(argstr(0, path, FAT32_MAX_PATH) < 0 || argaddr(1, &uargv) < 0){
    80202ffe:	10054963          	bltz	a0,80203110 <sys_exec+0x138>
    80203002:	dc040593          	addi	a1,s0,-576
    80203006:	4505                	li	a0,1
    80203008:	00000097          	auipc	ra,0x0
    8020300c:	edc080e7          	jalr	-292(ra) # 80202ee4 <argaddr>
    80203010:	10054063          	bltz	a0,80203110 <sys_exec+0x138>
    80203014:	22913c23          	sd	s1,568(sp)
    80203018:	23313423          	sd	s3,552(sp)
    8020301c:	23413023          	sd	s4,544(sp)
  }
  memset(argv, 0, sizeof(argv));
    80203020:	10000613          	li	a2,256
    80203024:	4581                	li	a1,0
    80203026:	dc840513          	addi	a0,s0,-568
    8020302a:	ffffd097          	auipc	ra,0xffffd
    8020302e:	762080e7          	jalr	1890(ra) # 8020078c <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80203032:	dc840493          	addi	s1,s0,-568
  memset(argv, 0, sizeof(argv));
    80203036:	89a6                	mv	s3,s1
    80203038:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    8020303a:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8020303e:	00391513          	slli	a0,s2,0x3
    80203042:	db840593          	addi	a1,s0,-584
    80203046:	dc043783          	ld	a5,-576(s0)
    8020304a:	953e                	add	a0,a0,a5
    8020304c:	00000097          	auipc	ra,0x0
    80203050:	db6080e7          	jalr	-586(ra) # 80202e02 <fetchaddr>
    80203054:	02054a63          	bltz	a0,80203088 <sys_exec+0xb0>
      goto bad;
    }
    if(uarg == 0){
    80203058:	db843783          	ld	a5,-584(s0)
    8020305c:	cba9                	beqz	a5,802030ae <sys_exec+0xd6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8020305e:	ffffd097          	auipc	ra,0xffffd
    80203062:	526080e7          	jalr	1318(ra) # 80200584 <kalloc>
    80203066:	85aa                	mv	a1,a0
    80203068:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    8020306c:	cd11                	beqz	a0,80203088 <sys_exec+0xb0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8020306e:	6605                	lui	a2,0x1
    80203070:	db843503          	ld	a0,-584(s0)
    80203074:	00000097          	auipc	ra,0x0
    80203078:	dde080e7          	jalr	-546(ra) # 80202e52 <fetchstr>
    8020307c:	00054663          	bltz	a0,80203088 <sys_exec+0xb0>
    if(i >= NELEM(argv)){
    80203080:	0905                	addi	s2,s2,1
    80203082:	09a1                	addi	s3,s3,8
    80203084:	fb491de3          	bne	s2,s4,8020303e <sys_exec+0x66>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80203088:	ec840913          	addi	s2,s0,-312
    8020308c:	6088                	ld	a0,0(s1)
    8020308e:	c935                	beqz	a0,80203102 <sys_exec+0x12a>
    kfree(argv[i]);
    80203090:	ffffd097          	auipc	ra,0xffffd
    80203094:	3da080e7          	jalr	986(ra) # 8020046a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80203098:	04a1                	addi	s1,s1,8
    8020309a:	ff2499e3          	bne	s1,s2,8020308c <sys_exec+0xb4>
  return -1;
    8020309e:	597d                	li	s2,-1
    802030a0:	23813483          	ld	s1,568(sp)
    802030a4:	22813983          	ld	s3,552(sp)
    802030a8:	22013a03          	ld	s4,544(sp)
    802030ac:	a095                	j	80203110 <sys_exec+0x138>
      argv[i] = 0;
    802030ae:	0009079b          	sext.w	a5,s2
    802030b2:	078e                	slli	a5,a5,0x3
    802030b4:	fd078793          	addi	a5,a5,-48
    802030b8:	97a2                	add	a5,a5,s0
    802030ba:	de07bc23          	sd	zero,-520(a5)
  int ret = exec(path, argv);
    802030be:	dc840593          	addi	a1,s0,-568
    802030c2:	ec840513          	addi	a0,s0,-312
    802030c6:	00001097          	auipc	ra,0x1
    802030ca:	ed4080e7          	jalr	-300(ra) # 80203f9a <exec>
    802030ce:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    802030d0:	ec840993          	addi	s3,s0,-312
    802030d4:	6088                	ld	a0,0(s1)
    802030d6:	cd19                	beqz	a0,802030f4 <sys_exec+0x11c>
    kfree(argv[i]);
    802030d8:	ffffd097          	auipc	ra,0xffffd
    802030dc:	392080e7          	jalr	914(ra) # 8020046a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    802030e0:	04a1                	addi	s1,s1,8
    802030e2:	ff3499e3          	bne	s1,s3,802030d4 <sys_exec+0xfc>
    802030e6:	23813483          	ld	s1,568(sp)
    802030ea:	22813983          	ld	s3,552(sp)
    802030ee:	22013a03          	ld	s4,544(sp)
    802030f2:	a839                	j	80203110 <sys_exec+0x138>
  return ret;
    802030f4:	23813483          	ld	s1,568(sp)
    802030f8:	22813983          	ld	s3,552(sp)
    802030fc:	22013a03          	ld	s4,544(sp)
    80203100:	a801                	j	80203110 <sys_exec+0x138>
  return -1;
    80203102:	597d                	li	s2,-1
    80203104:	23813483          	ld	s1,568(sp)
    80203108:	22813983          	ld	s3,552(sp)
    8020310c:	22013a03          	ld	s4,544(sp)
}
    80203110:	854a                	mv	a0,s2
    80203112:	24813083          	ld	ra,584(sp)
    80203116:	24013403          	ld	s0,576(sp)
    8020311a:	23013903          	ld	s2,560(sp)
    8020311e:	25010113          	addi	sp,sp,592
    80203122:	8082                	ret

0000000080203124 <sys_exit>:

uint64
sys_exit(void)
{
    80203124:	1101                	addi	sp,sp,-32
    80203126:	ec06                	sd	ra,24(sp)
    80203128:	e822                	sd	s0,16(sp)
    8020312a:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    8020312c:	fec40593          	addi	a1,s0,-20
    80203130:	4501                	li	a0,0
    80203132:	00000097          	auipc	ra,0x0
    80203136:	d50080e7          	jalr	-688(ra) # 80202e82 <argint>
    return -1;
    8020313a:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    8020313c:	00054963          	bltz	a0,8020314e <sys_exit+0x2a>
  exit(n);
    80203140:	fec42503          	lw	a0,-20(s0)
    80203144:	fffff097          	auipc	ra,0xfffff
    80203148:	0c8080e7          	jalr	200(ra) # 8020220c <exit>
  return 0;  // not reached
    8020314c:	4781                	li	a5,0
}
    8020314e:	853e                	mv	a0,a5
    80203150:	60e2                	ld	ra,24(sp)
    80203152:	6442                	ld	s0,16(sp)
    80203154:	6105                	addi	sp,sp,32
    80203156:	8082                	ret

0000000080203158 <sys_getpid>:

uint64
sys_getpid(void)
{
    80203158:	1141                	addi	sp,sp,-16
    8020315a:	e406                	sd	ra,8(sp)
    8020315c:	e022                	sd	s0,0(sp)
    8020315e:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80203160:	fffff097          	auipc	ra,0xfffff
    80203164:	96e080e7          	jalr	-1682(ra) # 80201ace <myproc>
}
    80203168:	5d08                	lw	a0,56(a0)
    8020316a:	60a2                	ld	ra,8(sp)
    8020316c:	6402                	ld	s0,0(sp)
    8020316e:	0141                	addi	sp,sp,16
    80203170:	8082                	ret

0000000080203172 <sys_fork>:

uint64
sys_fork(void)
{
    80203172:	1141                	addi	sp,sp,-16
    80203174:	e406                	sd	ra,8(sp)
    80203176:	e022                	sd	s0,0(sp)
    80203178:	0800                	addi	s0,sp,16
  return fork();
    8020317a:	fffff097          	auipc	ra,0xfffff
    8020317e:	d52080e7          	jalr	-686(ra) # 80201ecc <fork>
}
    80203182:	60a2                	ld	ra,8(sp)
    80203184:	6402                	ld	s0,0(sp)
    80203186:	0141                	addi	sp,sp,16
    80203188:	8082                	ret

000000008020318a <sys_wait>:

uint64
sys_wait(void)
{
    8020318a:	1101                	addi	sp,sp,-32
    8020318c:	ec06                	sd	ra,24(sp)
    8020318e:	e822                	sd	s0,16(sp)
    80203190:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80203192:	fe840593          	addi	a1,s0,-24
    80203196:	4501                	li	a0,0
    80203198:	00000097          	auipc	ra,0x0
    8020319c:	d4c080e7          	jalr	-692(ra) # 80202ee4 <argaddr>
    802031a0:	87aa                	mv	a5,a0
    return -1;
    802031a2:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    802031a4:	0007c863          	bltz	a5,802031b4 <sys_wait+0x2a>
  return wait(p);
    802031a8:	fe843503          	ld	a0,-24(s0)
    802031ac:	fffff097          	auipc	ra,0xfffff
    802031b0:	214080e7          	jalr	532(ra) # 802023c0 <wait>
}
    802031b4:	60e2                	ld	ra,24(sp)
    802031b6:	6442                	ld	s0,16(sp)
    802031b8:	6105                	addi	sp,sp,32
    802031ba:	8082                	ret

00000000802031bc <sys_sbrk>:

uint64
sys_sbrk(void)
{
    802031bc:	7179                	addi	sp,sp,-48
    802031be:	f406                	sd	ra,40(sp)
    802031c0:	f022                	sd	s0,32(sp)
    802031c2:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    802031c4:	fdc40593          	addi	a1,s0,-36
    802031c8:	4501                	li	a0,0
    802031ca:	00000097          	auipc	ra,0x0
    802031ce:	cb8080e7          	jalr	-840(ra) # 80202e82 <argint>
    802031d2:	87aa                	mv	a5,a0
    return -1;
    802031d4:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    802031d6:	0207c263          	bltz	a5,802031fa <sys_sbrk+0x3e>
    802031da:	ec26                	sd	s1,24(sp)
  addr = myproc()->sz;
    802031dc:	fffff097          	auipc	ra,0xfffff
    802031e0:	8f2080e7          	jalr	-1806(ra) # 80201ace <myproc>
    802031e4:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    802031e6:	fdc42503          	lw	a0,-36(s0)
    802031ea:	fffff097          	auipc	ra,0xfffff
    802031ee:	c66080e7          	jalr	-922(ra) # 80201e50 <growproc>
    802031f2:	00054863          	bltz	a0,80203202 <sys_sbrk+0x46>
    return -1;
  return addr;
    802031f6:	8526                	mv	a0,s1
    802031f8:	64e2                	ld	s1,24(sp)
}
    802031fa:	70a2                	ld	ra,40(sp)
    802031fc:	7402                	ld	s0,32(sp)
    802031fe:	6145                	addi	sp,sp,48
    80203200:	8082                	ret
    return -1;
    80203202:	557d                	li	a0,-1
    80203204:	64e2                	ld	s1,24(sp)
    80203206:	bfd5                	j	802031fa <sys_sbrk+0x3e>

0000000080203208 <sys_sleep>:

uint64
sys_sleep(void)
{
    80203208:	7139                	addi	sp,sp,-64
    8020320a:	fc06                	sd	ra,56(sp)
    8020320c:	f822                	sd	s0,48(sp)
    8020320e:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80203210:	fcc40593          	addi	a1,s0,-52
    80203214:	4501                	li	a0,0
    80203216:	00000097          	auipc	ra,0x0
    8020321a:	c6c080e7          	jalr	-916(ra) # 80202e82 <argint>
    return -1;
    8020321e:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80203220:	06054b63          	bltz	a0,80203296 <sys_sleep+0x8e>
    80203224:	f04a                	sd	s2,32(sp)
  acquire(&tickslock);
    80203226:	0001a517          	auipc	a0,0x1a
    8020322a:	1e250513          	addi	a0,a0,482 # 8021d408 <tickslock>
    8020322e:	ffffd097          	auipc	ra,0xffffd
    80203232:	4c2080e7          	jalr	1218(ra) # 802006f0 <acquire>
  ticks0 = ticks;
    80203236:	0001a917          	auipc	s2,0x1a
    8020323a:	1ea92903          	lw	s2,490(s2) # 8021d420 <ticks>
  while(ticks - ticks0 < n){
    8020323e:	fcc42783          	lw	a5,-52(s0)
    80203242:	c3a1                	beqz	a5,80203282 <sys_sleep+0x7a>
    80203244:	f426                	sd	s1,40(sp)
    80203246:	ec4e                	sd	s3,24(sp)
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80203248:	0001a997          	auipc	s3,0x1a
    8020324c:	1c098993          	addi	s3,s3,448 # 8021d408 <tickslock>
    80203250:	0001a497          	auipc	s1,0x1a
    80203254:	1d048493          	addi	s1,s1,464 # 8021d420 <ticks>
    if(myproc()->killed){
    80203258:	fffff097          	auipc	ra,0xfffff
    8020325c:	876080e7          	jalr	-1930(ra) # 80201ace <myproc>
    80203260:	591c                	lw	a5,48(a0)
    80203262:	ef9d                	bnez	a5,802032a0 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80203264:	85ce                	mv	a1,s3
    80203266:	8526                	mv	a0,s1
    80203268:	fffff097          	auipc	ra,0xfffff
    8020326c:	0da080e7          	jalr	218(ra) # 80202342 <sleep>
  while(ticks - ticks0 < n){
    80203270:	409c                	lw	a5,0(s1)
    80203272:	412787bb          	subw	a5,a5,s2
    80203276:	fcc42703          	lw	a4,-52(s0)
    8020327a:	fce7efe3          	bltu	a5,a4,80203258 <sys_sleep+0x50>
    8020327e:	74a2                	ld	s1,40(sp)
    80203280:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80203282:	0001a517          	auipc	a0,0x1a
    80203286:	18650513          	addi	a0,a0,390 # 8021d408 <tickslock>
    8020328a:	ffffd097          	auipc	ra,0xffffd
    8020328e:	4ba080e7          	jalr	1210(ra) # 80200744 <release>
  return 0;
    80203292:	4781                	li	a5,0
    80203294:	7902                	ld	s2,32(sp)
}
    80203296:	853e                	mv	a0,a5
    80203298:	70e2                	ld	ra,56(sp)
    8020329a:	7442                	ld	s0,48(sp)
    8020329c:	6121                	addi	sp,sp,64
    8020329e:	8082                	ret
      release(&tickslock);
    802032a0:	0001a517          	auipc	a0,0x1a
    802032a4:	16850513          	addi	a0,a0,360 # 8021d408 <tickslock>
    802032a8:	ffffd097          	auipc	ra,0xffffd
    802032ac:	49c080e7          	jalr	1180(ra) # 80200744 <release>
      return -1;
    802032b0:	57fd                	li	a5,-1
    802032b2:	74a2                	ld	s1,40(sp)
    802032b4:	7902                	ld	s2,32(sp)
    802032b6:	69e2                	ld	s3,24(sp)
    802032b8:	bff9                	j	80203296 <sys_sleep+0x8e>

00000000802032ba <sys_kill>:

uint64
sys_kill(void)
{
    802032ba:	1101                	addi	sp,sp,-32
    802032bc:	ec06                	sd	ra,24(sp)
    802032be:	e822                	sd	s0,16(sp)
    802032c0:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    802032c2:	fec40593          	addi	a1,s0,-20
    802032c6:	4501                	li	a0,0
    802032c8:	00000097          	auipc	ra,0x0
    802032cc:	bba080e7          	jalr	-1094(ra) # 80202e82 <argint>
    802032d0:	87aa                	mv	a5,a0
    return -1;
    802032d2:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    802032d4:	0007c863          	bltz	a5,802032e4 <sys_kill+0x2a>
  return kill(pid);
    802032d8:	fec42503          	lw	a0,-20(s0)
    802032dc:	fffff097          	auipc	ra,0xfffff
    802032e0:	24c080e7          	jalr	588(ra) # 80202528 <kill>
}
    802032e4:	60e2                	ld	ra,24(sp)
    802032e6:	6442                	ld	s0,16(sp)
    802032e8:	6105                	addi	sp,sp,32
    802032ea:	8082                	ret

00000000802032ec <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    802032ec:	1101                	addi	sp,sp,-32
    802032ee:	ec06                	sd	ra,24(sp)
    802032f0:	e822                	sd	s0,16(sp)
    802032f2:	e426                	sd	s1,8(sp)
    802032f4:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    802032f6:	0001a517          	auipc	a0,0x1a
    802032fa:	11250513          	addi	a0,a0,274 # 8021d408 <tickslock>
    802032fe:	ffffd097          	auipc	ra,0xffffd
    80203302:	3f2080e7          	jalr	1010(ra) # 802006f0 <acquire>
  xticks = ticks;
    80203306:	0001a497          	auipc	s1,0x1a
    8020330a:	11a4a483          	lw	s1,282(s1) # 8021d420 <ticks>
  release(&tickslock);
    8020330e:	0001a517          	auipc	a0,0x1a
    80203312:	0fa50513          	addi	a0,a0,250 # 8021d408 <tickslock>
    80203316:	ffffd097          	auipc	ra,0xffffd
    8020331a:	42e080e7          	jalr	1070(ra) # 80200744 <release>
  return xticks;
}
    8020331e:	02049513          	slli	a0,s1,0x20
    80203322:	9101                	srli	a0,a0,0x20
    80203324:	60e2                	ld	ra,24(sp)
    80203326:	6442                	ld	s0,16(sp)
    80203328:	64a2                	ld	s1,8(sp)
    8020332a:	6105                	addi	sp,sp,32
    8020332c:	8082                	ret

000000008020332e <sys_trace>:

uint64
sys_trace(void)
{
    8020332e:	1101                	addi	sp,sp,-32
    80203330:	ec06                	sd	ra,24(sp)
    80203332:	e822                	sd	s0,16(sp)
    80203334:	1000                	addi	s0,sp,32
  int mask;
  if(argint(0, &mask) < 0) {
    80203336:	fec40593          	addi	a1,s0,-20
    8020333a:	4501                	li	a0,0
    8020333c:	00000097          	auipc	ra,0x0
    80203340:	b46080e7          	jalr	-1210(ra) # 80202e82 <argint>
    return -1;
    80203344:	57fd                	li	a5,-1
  if(argint(0, &mask) < 0) {
    80203346:	00054b63          	bltz	a0,8020335c <sys_trace+0x2e>
  }
  myproc()->tmask = mask;
    8020334a:	ffffe097          	auipc	ra,0xffffe
    8020334e:	784080e7          	jalr	1924(ra) # 80201ace <myproc>
    80203352:	fec42783          	lw	a5,-20(s0)
    80203356:	16f52823          	sw	a5,368(a0)
  return 0;
    8020335a:	4781                	li	a5,0
}
    8020335c:	853e                	mv	a0,a5
    8020335e:	60e2                	ld	ra,24(sp)
    80203360:	6442                	ld	s0,16(sp)
    80203362:	6105                	addi	sp,sp,32
    80203364:	8082                	ret

0000000080203366 <sys_halt>:
//   - 你调用的是内核中可用的 SBI 封装吗？
//   - 如果关机调用正常执行，后续 return 是否只是为了满足 C 函数形式？
// ───────────────────────────────────────────────────────────
uint64
sys_halt(void)
{
    80203366:	1141                	addi	sp,sp,-16
    80203368:	e422                	sd	s0,8(sp)
    8020336a:	0800                	addi	s0,sp,16
  // todo（CP④）：通过 SBI 提供的关机封装结束系统
  return -1;  // 占位——学生实现后替换为实际关机逻辑
    8020336c:	557d                	li	a0,-1
    8020336e:	6422                	ld	s0,8(sp)
    80203370:	0141                	addi	sp,sp,16
    80203372:	8082                	ret

0000000080203374 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80203374:	7139                	addi	sp,sp,-64
    80203376:	fc06                	sd	ra,56(sp)
    80203378:	f822                	sd	s0,48(sp)
    8020337a:	f426                	sd	s1,40(sp)
    8020337c:	f04a                	sd	s2,32(sp)
    8020337e:	ec4e                	sd	s3,24(sp)
    80203380:	e852                	sd	s4,16(sp)
    80203382:	e456                	sd	s5,8(sp)
    80203384:	0080                	addi	s0,sp,64
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80203386:	00006597          	auipc	a1,0x6
    8020338a:	6ea58593          	addi	a1,a1,1770 # 80209a70 <etext+0xa70>
    8020338e:	00014517          	auipc	a0,0x14
    80203392:	76250513          	addi	a0,a0,1890 # 80217af0 <bcache>
    80203396:	ffffd097          	auipc	ra,0xffffd
    8020339a:	316080e7          	jalr	790(ra) # 802006ac <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8020339e:	00018797          	auipc	a5,0x18
    802033a2:	75278793          	addi	a5,a5,1874 # 8021baf0 <bcache+0x4000>
    802033a6:	00019717          	auipc	a4,0x19
    802033aa:	db270713          	addi	a4,a4,-590 # 8021c158 <bcache+0x4668>
    802033ae:	6ae7b823          	sd	a4,1712(a5)
  bcache.head.next = &bcache.head;
    802033b2:	6ae7bc23          	sd	a4,1720(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    802033b6:	00014497          	auipc	s1,0x14
    802033ba:	75248493          	addi	s1,s1,1874 # 80217b08 <bcache+0x18>
    b->refcnt = 0;
    b->sectorno = ~0;
    802033be:	5a7d                	li	s4,-1
    b->dev = ~0;
    b->next = bcache.head.next;
    802033c0:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    802033c2:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    802033c4:	00006a97          	auipc	s5,0x6
    802033c8:	6b4a8a93          	addi	s5,s5,1716 # 80209a78 <etext+0xa78>
    b->refcnt = 0;
    802033cc:	0404a023          	sw	zero,64(s1)
    b->sectorno = ~0;
    802033d0:	0144a623          	sw	s4,12(s1)
    b->dev = ~0;
    802033d4:	0144a423          	sw	s4,8(s1)
    b->next = bcache.head.next;
    802033d8:	6b893783          	ld	a5,1720(s2)
    802033dc:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    802033de:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    802033e2:	85d6                	mv	a1,s5
    802033e4:	01048513          	addi	a0,s1,16
    802033e8:	00000097          	auipc	ra,0x0
    802033ec:	26c080e7          	jalr	620(ra) # 80203654 <initsleeplock>
    bcache.head.next->prev = b;
    802033f0:	6b893783          	ld	a5,1720(s2)
    802033f4:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    802033f6:	6a993c23          	sd	s1,1720(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    802033fa:	25848493          	addi	s1,s1,600
    802033fe:	fd3497e3          	bne	s1,s3,802033cc <binit+0x58>
  }
  #ifdef DEBUG
  printf("binit\n");
  #endif
}
    80203402:	70e2                	ld	ra,56(sp)
    80203404:	7442                	ld	s0,48(sp)
    80203406:	74a2                	ld	s1,40(sp)
    80203408:	7902                	ld	s2,32(sp)
    8020340a:	69e2                	ld	s3,24(sp)
    8020340c:	6a42                	ld	s4,16(sp)
    8020340e:	6aa2                	ld	s5,8(sp)
    80203410:	6121                	addi	sp,sp,64
    80203412:	8082                	ret

0000000080203414 <bread>:
  panic("bget: no buffers");
}

// Return a locked buf with the contents of the indicated block.
struct buf* 
bread(uint dev, uint sectorno) {
    80203414:	7179                	addi	sp,sp,-48
    80203416:	f406                	sd	ra,40(sp)
    80203418:	f022                	sd	s0,32(sp)
    8020341a:	ec26                	sd	s1,24(sp)
    8020341c:	e84a                	sd	s2,16(sp)
    8020341e:	e44e                	sd	s3,8(sp)
    80203420:	1800                	addi	s0,sp,48
    80203422:	892a                	mv	s2,a0
    80203424:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80203426:	00014517          	auipc	a0,0x14
    8020342a:	6ca50513          	addi	a0,a0,1738 # 80217af0 <bcache>
    8020342e:	ffffd097          	auipc	ra,0xffffd
    80203432:	2c2080e7          	jalr	706(ra) # 802006f0 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80203436:	00019497          	auipc	s1,0x19
    8020343a:	d724b483          	ld	s1,-654(s1) # 8021c1a8 <bcache+0x46b8>
    8020343e:	00019797          	auipc	a5,0x19
    80203442:	d1a78793          	addi	a5,a5,-742 # 8021c158 <bcache+0x4668>
    80203446:	02f48f63          	beq	s1,a5,80203484 <bread+0x70>
    8020344a:	873e                	mv	a4,a5
    8020344c:	a021                	j	80203454 <bread+0x40>
    8020344e:	68a4                	ld	s1,80(s1)
    80203450:	02e48a63          	beq	s1,a4,80203484 <bread+0x70>
    if(b->dev == dev && b->sectorno == sectorno){
    80203454:	449c                	lw	a5,8(s1)
    80203456:	ff279ce3          	bne	a5,s2,8020344e <bread+0x3a>
    8020345a:	44dc                	lw	a5,12(s1)
    8020345c:	ff3799e3          	bne	a5,s3,8020344e <bread+0x3a>
      b->refcnt++;
    80203460:	40bc                	lw	a5,64(s1)
    80203462:	2785                	addiw	a5,a5,1
    80203464:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80203466:	00014517          	auipc	a0,0x14
    8020346a:	68a50513          	addi	a0,a0,1674 # 80217af0 <bcache>
    8020346e:	ffffd097          	auipc	ra,0xffffd
    80203472:	2d6080e7          	jalr	726(ra) # 80200744 <release>
      acquiresleep(&b->lock);
    80203476:	01048513          	addi	a0,s1,16
    8020347a:	00000097          	auipc	ra,0x0
    8020347e:	214080e7          	jalr	532(ra) # 8020368e <acquiresleep>
      return b;
    80203482:	a8b9                	j	802034e0 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80203484:	00019497          	auipc	s1,0x19
    80203488:	d1c4b483          	ld	s1,-740(s1) # 8021c1a0 <bcache+0x46b0>
    8020348c:	00019797          	auipc	a5,0x19
    80203490:	ccc78793          	addi	a5,a5,-820 # 8021c158 <bcache+0x4668>
    80203494:	00f48863          	beq	s1,a5,802034a4 <bread+0x90>
    80203498:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8020349a:	40bc                	lw	a5,64(s1)
    8020349c:	cf81                	beqz	a5,802034b4 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8020349e:	64a4                	ld	s1,72(s1)
    802034a0:	fee49de3          	bne	s1,a4,8020349a <bread+0x86>
  panic("bget: no buffers");
    802034a4:	00006517          	auipc	a0,0x6
    802034a8:	5dc50513          	addi	a0,a0,1500 # 80209a80 <etext+0xa80>
    802034ac:	ffffd097          	auipc	ra,0xffffd
    802034b0:	c9a080e7          	jalr	-870(ra) # 80200146 <panic>
      b->dev = dev;
    802034b4:	0124a423          	sw	s2,8(s1)
      b->sectorno = sectorno;
    802034b8:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    802034bc:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    802034c0:	4785                	li	a5,1
    802034c2:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    802034c4:	00014517          	auipc	a0,0x14
    802034c8:	62c50513          	addi	a0,a0,1580 # 80217af0 <bcache>
    802034cc:	ffffd097          	auipc	ra,0xffffd
    802034d0:	278080e7          	jalr	632(ra) # 80200744 <release>
      acquiresleep(&b->lock);
    802034d4:	01048513          	addi	a0,s1,16
    802034d8:	00000097          	auipc	ra,0x0
    802034dc:	1b6080e7          	jalr	438(ra) # 8020368e <acquiresleep>
  struct buf *b;

  b = bget(dev, sectorno);
  if (!b->valid) {
    802034e0:	409c                	lw	a5,0(s1)
    802034e2:	cb89                	beqz	a5,802034f4 <bread+0xe0>
    disk_read(b);
    b->valid = 1;
  }

  return b;
}
    802034e4:	8526                	mv	a0,s1
    802034e6:	70a2                	ld	ra,40(sp)
    802034e8:	7402                	ld	s0,32(sp)
    802034ea:	64e2                	ld	s1,24(sp)
    802034ec:	6942                	ld	s2,16(sp)
    802034ee:	69a2                	ld	s3,8(sp)
    802034f0:	6145                	addi	sp,sp,48
    802034f2:	8082                	ret
    disk_read(b);
    802034f4:	8526                	mv	a0,s1
    802034f6:	00002097          	auipc	ra,0x2
    802034fa:	c3c080e7          	jalr	-964(ra) # 80205132 <disk_read>
    b->valid = 1;
    802034fe:	4785                	li	a5,1
    80203500:	c09c                	sw	a5,0(s1)
  return b;
    80203502:	b7cd                	j	802034e4 <bread+0xd0>

0000000080203504 <bwrite>:

// Write b's contents to disk.  Must be locked.
void 
bwrite(struct buf *b) {
    80203504:	1101                	addi	sp,sp,-32
    80203506:	ec06                	sd	ra,24(sp)
    80203508:	e822                	sd	s0,16(sp)
    8020350a:	e426                	sd	s1,8(sp)
    8020350c:	1000                	addi	s0,sp,32
    8020350e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80203510:	0541                	addi	a0,a0,16
    80203512:	00000097          	auipc	ra,0x0
    80203516:	216080e7          	jalr	534(ra) # 80203728 <holdingsleep>
    8020351a:	c919                	beqz	a0,80203530 <bwrite+0x2c>
    panic("bwrite");
  disk_write(b);
    8020351c:	8526                	mv	a0,s1
    8020351e:	00002097          	auipc	ra,0x2
    80203522:	c2e080e7          	jalr	-978(ra) # 8020514c <disk_write>
}
    80203526:	60e2                	ld	ra,24(sp)
    80203528:	6442                	ld	s0,16(sp)
    8020352a:	64a2                	ld	s1,8(sp)
    8020352c:	6105                	addi	sp,sp,32
    8020352e:	8082                	ret
    panic("bwrite");
    80203530:	00006517          	auipc	a0,0x6
    80203534:	56850513          	addi	a0,a0,1384 # 80209a98 <etext+0xa98>
    80203538:	ffffd097          	auipc	ra,0xffffd
    8020353c:	c0e080e7          	jalr	-1010(ra) # 80200146 <panic>

0000000080203540 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80203540:	1101                	addi	sp,sp,-32
    80203542:	ec06                	sd	ra,24(sp)
    80203544:	e822                	sd	s0,16(sp)
    80203546:	e426                	sd	s1,8(sp)
    80203548:	e04a                	sd	s2,0(sp)
    8020354a:	1000                	addi	s0,sp,32
    8020354c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8020354e:	01050913          	addi	s2,a0,16
    80203552:	854a                	mv	a0,s2
    80203554:	00000097          	auipc	ra,0x0
    80203558:	1d4080e7          	jalr	468(ra) # 80203728 <holdingsleep>
    8020355c:	c925                	beqz	a0,802035cc <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    8020355e:	854a                	mv	a0,s2
    80203560:	00000097          	auipc	ra,0x0
    80203564:	184080e7          	jalr	388(ra) # 802036e4 <releasesleep>

  acquire(&bcache.lock);
    80203568:	00014517          	auipc	a0,0x14
    8020356c:	58850513          	addi	a0,a0,1416 # 80217af0 <bcache>
    80203570:	ffffd097          	auipc	ra,0xffffd
    80203574:	180080e7          	jalr	384(ra) # 802006f0 <acquire>
  b->refcnt--;
    80203578:	40bc                	lw	a5,64(s1)
    8020357a:	37fd                	addiw	a5,a5,-1
    8020357c:	0007871b          	sext.w	a4,a5
    80203580:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80203582:	e71d                	bnez	a4,802035b0 <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80203584:	68b8                	ld	a4,80(s1)
    80203586:	64bc                	ld	a5,72(s1)
    80203588:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    8020358a:	68b8                	ld	a4,80(s1)
    8020358c:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8020358e:	00018797          	auipc	a5,0x18
    80203592:	56278793          	addi	a5,a5,1378 # 8021baf0 <bcache+0x4000>
    80203596:	6b87b703          	ld	a4,1720(a5)
    8020359a:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8020359c:	00019717          	auipc	a4,0x19
    802035a0:	bbc70713          	addi	a4,a4,-1092 # 8021c158 <bcache+0x4668>
    802035a4:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    802035a6:	6b87b703          	ld	a4,1720(a5)
    802035aa:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    802035ac:	6a97bc23          	sd	s1,1720(a5)
  }
  
  release(&bcache.lock);
    802035b0:	00014517          	auipc	a0,0x14
    802035b4:	54050513          	addi	a0,a0,1344 # 80217af0 <bcache>
    802035b8:	ffffd097          	auipc	ra,0xffffd
    802035bc:	18c080e7          	jalr	396(ra) # 80200744 <release>
}
    802035c0:	60e2                	ld	ra,24(sp)
    802035c2:	6442                	ld	s0,16(sp)
    802035c4:	64a2                	ld	s1,8(sp)
    802035c6:	6902                	ld	s2,0(sp)
    802035c8:	6105                	addi	sp,sp,32
    802035ca:	8082                	ret
    panic("brelse");
    802035cc:	00006517          	auipc	a0,0x6
    802035d0:	4d450513          	addi	a0,a0,1236 # 80209aa0 <etext+0xaa0>
    802035d4:	ffffd097          	auipc	ra,0xffffd
    802035d8:	b72080e7          	jalr	-1166(ra) # 80200146 <panic>

00000000802035dc <bpin>:

void
bpin(struct buf *b) {
    802035dc:	1101                	addi	sp,sp,-32
    802035de:	ec06                	sd	ra,24(sp)
    802035e0:	e822                	sd	s0,16(sp)
    802035e2:	e426                	sd	s1,8(sp)
    802035e4:	1000                	addi	s0,sp,32
    802035e6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    802035e8:	00014517          	auipc	a0,0x14
    802035ec:	50850513          	addi	a0,a0,1288 # 80217af0 <bcache>
    802035f0:	ffffd097          	auipc	ra,0xffffd
    802035f4:	100080e7          	jalr	256(ra) # 802006f0 <acquire>
  b->refcnt++;
    802035f8:	40bc                	lw	a5,64(s1)
    802035fa:	2785                	addiw	a5,a5,1
    802035fc:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    802035fe:	00014517          	auipc	a0,0x14
    80203602:	4f250513          	addi	a0,a0,1266 # 80217af0 <bcache>
    80203606:	ffffd097          	auipc	ra,0xffffd
    8020360a:	13e080e7          	jalr	318(ra) # 80200744 <release>
}
    8020360e:	60e2                	ld	ra,24(sp)
    80203610:	6442                	ld	s0,16(sp)
    80203612:	64a2                	ld	s1,8(sp)
    80203614:	6105                	addi	sp,sp,32
    80203616:	8082                	ret

0000000080203618 <bunpin>:

void
bunpin(struct buf *b) {
    80203618:	1101                	addi	sp,sp,-32
    8020361a:	ec06                	sd	ra,24(sp)
    8020361c:	e822                	sd	s0,16(sp)
    8020361e:	e426                	sd	s1,8(sp)
    80203620:	1000                	addi	s0,sp,32
    80203622:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80203624:	00014517          	auipc	a0,0x14
    80203628:	4cc50513          	addi	a0,a0,1228 # 80217af0 <bcache>
    8020362c:	ffffd097          	auipc	ra,0xffffd
    80203630:	0c4080e7          	jalr	196(ra) # 802006f0 <acquire>
  b->refcnt--;
    80203634:	40bc                	lw	a5,64(s1)
    80203636:	37fd                	addiw	a5,a5,-1
    80203638:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8020363a:	00014517          	auipc	a0,0x14
    8020363e:	4b650513          	addi	a0,a0,1206 # 80217af0 <bcache>
    80203642:	ffffd097          	auipc	ra,0xffffd
    80203646:	102080e7          	jalr	258(ra) # 80200744 <release>
}
    8020364a:	60e2                	ld	ra,24(sp)
    8020364c:	6442                	ld	s0,16(sp)
    8020364e:	64a2                	ld	s1,8(sp)
    80203650:	6105                	addi	sp,sp,32
    80203652:	8082                	ret

0000000080203654 <initsleeplock>:
#include "include/proc.h"
#include "include/sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80203654:	1101                	addi	sp,sp,-32
    80203656:	ec06                	sd	ra,24(sp)
    80203658:	e822                	sd	s0,16(sp)
    8020365a:	e426                	sd	s1,8(sp)
    8020365c:	e04a                	sd	s2,0(sp)
    8020365e:	1000                	addi	s0,sp,32
    80203660:	84aa                	mv	s1,a0
    80203662:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80203664:	00006597          	auipc	a1,0x6
    80203668:	44458593          	addi	a1,a1,1092 # 80209aa8 <etext+0xaa8>
    8020366c:	0521                	addi	a0,a0,8
    8020366e:	ffffd097          	auipc	ra,0xffffd
    80203672:	03e080e7          	jalr	62(ra) # 802006ac <initlock>
  lk->name = name;
    80203676:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8020367a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8020367e:	0204a423          	sw	zero,40(s1)
}
    80203682:	60e2                	ld	ra,24(sp)
    80203684:	6442                	ld	s0,16(sp)
    80203686:	64a2                	ld	s1,8(sp)
    80203688:	6902                	ld	s2,0(sp)
    8020368a:	6105                	addi	sp,sp,32
    8020368c:	8082                	ret

000000008020368e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8020368e:	1101                	addi	sp,sp,-32
    80203690:	ec06                	sd	ra,24(sp)
    80203692:	e822                	sd	s0,16(sp)
    80203694:	e426                	sd	s1,8(sp)
    80203696:	e04a                	sd	s2,0(sp)
    80203698:	1000                	addi	s0,sp,32
    8020369a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8020369c:	00850913          	addi	s2,a0,8
    802036a0:	854a                	mv	a0,s2
    802036a2:	ffffd097          	auipc	ra,0xffffd
    802036a6:	04e080e7          	jalr	78(ra) # 802006f0 <acquire>
  while (lk->locked) {
    802036aa:	409c                	lw	a5,0(s1)
    802036ac:	cb89                	beqz	a5,802036be <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    802036ae:	85ca                	mv	a1,s2
    802036b0:	8526                	mv	a0,s1
    802036b2:	fffff097          	auipc	ra,0xfffff
    802036b6:	c90080e7          	jalr	-880(ra) # 80202342 <sleep>
  while (lk->locked) {
    802036ba:	409c                	lw	a5,0(s1)
    802036bc:	fbed                	bnez	a5,802036ae <acquiresleep+0x20>
  }
  lk->locked = 1;
    802036be:	4785                	li	a5,1
    802036c0:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    802036c2:	ffffe097          	auipc	ra,0xffffe
    802036c6:	40c080e7          	jalr	1036(ra) # 80201ace <myproc>
    802036ca:	5d1c                	lw	a5,56(a0)
    802036cc:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    802036ce:	854a                	mv	a0,s2
    802036d0:	ffffd097          	auipc	ra,0xffffd
    802036d4:	074080e7          	jalr	116(ra) # 80200744 <release>
}
    802036d8:	60e2                	ld	ra,24(sp)
    802036da:	6442                	ld	s0,16(sp)
    802036dc:	64a2                	ld	s1,8(sp)
    802036de:	6902                	ld	s2,0(sp)
    802036e0:	6105                	addi	sp,sp,32
    802036e2:	8082                	ret

00000000802036e4 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    802036e4:	1101                	addi	sp,sp,-32
    802036e6:	ec06                	sd	ra,24(sp)
    802036e8:	e822                	sd	s0,16(sp)
    802036ea:	e426                	sd	s1,8(sp)
    802036ec:	e04a                	sd	s2,0(sp)
    802036ee:	1000                	addi	s0,sp,32
    802036f0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    802036f2:	00850913          	addi	s2,a0,8
    802036f6:	854a                	mv	a0,s2
    802036f8:	ffffd097          	auipc	ra,0xffffd
    802036fc:	ff8080e7          	jalr	-8(ra) # 802006f0 <acquire>
  lk->locked = 0;
    80203700:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80203704:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80203708:	8526                	mv	a0,s1
    8020370a:	fffff097          	auipc	ra,0xfffff
    8020370e:	db4080e7          	jalr	-588(ra) # 802024be <wakeup>
  release(&lk->lk);
    80203712:	854a                	mv	a0,s2
    80203714:	ffffd097          	auipc	ra,0xffffd
    80203718:	030080e7          	jalr	48(ra) # 80200744 <release>
}
    8020371c:	60e2                	ld	ra,24(sp)
    8020371e:	6442                	ld	s0,16(sp)
    80203720:	64a2                	ld	s1,8(sp)
    80203722:	6902                	ld	s2,0(sp)
    80203724:	6105                	addi	sp,sp,32
    80203726:	8082                	ret

0000000080203728 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80203728:	7179                	addi	sp,sp,-48
    8020372a:	f406                	sd	ra,40(sp)
    8020372c:	f022                	sd	s0,32(sp)
    8020372e:	ec26                	sd	s1,24(sp)
    80203730:	e84a                	sd	s2,16(sp)
    80203732:	1800                	addi	s0,sp,48
    80203734:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80203736:	00850913          	addi	s2,a0,8
    8020373a:	854a                	mv	a0,s2
    8020373c:	ffffd097          	auipc	ra,0xffffd
    80203740:	fb4080e7          	jalr	-76(ra) # 802006f0 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80203744:	409c                	lw	a5,0(s1)
    80203746:	ef91                	bnez	a5,80203762 <holdingsleep+0x3a>
    80203748:	4481                	li	s1,0
  release(&lk->lk);
    8020374a:	854a                	mv	a0,s2
    8020374c:	ffffd097          	auipc	ra,0xffffd
    80203750:	ff8080e7          	jalr	-8(ra) # 80200744 <release>
  return r;
}
    80203754:	8526                	mv	a0,s1
    80203756:	70a2                	ld	ra,40(sp)
    80203758:	7402                	ld	s0,32(sp)
    8020375a:	64e2                	ld	s1,24(sp)
    8020375c:	6942                	ld	s2,16(sp)
    8020375e:	6145                	addi	sp,sp,48
    80203760:	8082                	ret
    80203762:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80203764:	0284a983          	lw	s3,40(s1)
    80203768:	ffffe097          	auipc	ra,0xffffe
    8020376c:	366080e7          	jalr	870(ra) # 80201ace <myproc>
    80203770:	5d04                	lw	s1,56(a0)
    80203772:	413484b3          	sub	s1,s1,s3
    80203776:	0014b493          	seqz	s1,s1
    8020377a:	69a2                	ld	s3,8(sp)
    8020377c:	b7f9                	j	8020374a <holdingsleep+0x22>

000000008020377e <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8020377e:	1101                	addi	sp,sp,-32
    80203780:	ec06                	sd	ra,24(sp)
    80203782:	e822                	sd	s0,16(sp)
    80203784:	e426                	sd	s1,8(sp)
    80203786:	e04a                	sd	s2,0(sp)
    80203788:	1000                	addi	s0,sp,32
  initlock(&ftable.lock, "ftable");
    8020378a:	00006597          	auipc	a1,0x6
    8020378e:	32e58593          	addi	a1,a1,814 # 80209ab8 <etext+0xab8>
    80203792:	00019517          	auipc	a0,0x19
    80203796:	cbe50513          	addi	a0,a0,-834 # 8021c450 <ftable>
    8020379a:	ffffd097          	auipc	ra,0xffffd
    8020379e:	f12080e7          	jalr	-238(ra) # 802006ac <initlock>
  struct file *f;
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    802037a2:	00019497          	auipc	s1,0x19
    802037a6:	cc648493          	addi	s1,s1,-826 # 8021c468 <ftable+0x18>
    802037aa:	0001a917          	auipc	s2,0x1a
    802037ae:	c5e90913          	addi	s2,s2,-930 # 8021d408 <tickslock>
    memset(f, 0, sizeof(struct file));
    802037b2:	02800613          	li	a2,40
    802037b6:	4581                	li	a1,0
    802037b8:	8526                	mv	a0,s1
    802037ba:	ffffd097          	auipc	ra,0xffffd
    802037be:	fd2080e7          	jalr	-46(ra) # 8020078c <memset>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    802037c2:	02848493          	addi	s1,s1,40
    802037c6:	ff2496e3          	bne	s1,s2,802037b2 <fileinit+0x34>
  }
  #ifdef DEBUG
  printf("fileinit\n");
  #endif
}
    802037ca:	60e2                	ld	ra,24(sp)
    802037cc:	6442                	ld	s0,16(sp)
    802037ce:	64a2                	ld	s1,8(sp)
    802037d0:	6902                	ld	s2,0(sp)
    802037d2:	6105                	addi	sp,sp,32
    802037d4:	8082                	ret

00000000802037d6 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    802037d6:	1101                	addi	sp,sp,-32
    802037d8:	ec06                	sd	ra,24(sp)
    802037da:	e822                	sd	s0,16(sp)
    802037dc:	e426                	sd	s1,8(sp)
    802037de:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    802037e0:	00019517          	auipc	a0,0x19
    802037e4:	c7050513          	addi	a0,a0,-912 # 8021c450 <ftable>
    802037e8:	ffffd097          	auipc	ra,0xffffd
    802037ec:	f08080e7          	jalr	-248(ra) # 802006f0 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    802037f0:	00019497          	auipc	s1,0x19
    802037f4:	c7848493          	addi	s1,s1,-904 # 8021c468 <ftable+0x18>
    802037f8:	0001a717          	auipc	a4,0x1a
    802037fc:	c1070713          	addi	a4,a4,-1008 # 8021d408 <tickslock>
    if(f->ref == 0){
    80203800:	40dc                	lw	a5,4(s1)
    80203802:	cf99                	beqz	a5,80203820 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80203804:	02848493          	addi	s1,s1,40
    80203808:	fee49ce3          	bne	s1,a4,80203800 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8020380c:	00019517          	auipc	a0,0x19
    80203810:	c4450513          	addi	a0,a0,-956 # 8021c450 <ftable>
    80203814:	ffffd097          	auipc	ra,0xffffd
    80203818:	f30080e7          	jalr	-208(ra) # 80200744 <release>
  return NULL;
    8020381c:	4481                	li	s1,0
    8020381e:	a819                	j	80203834 <filealloc+0x5e>
      f->ref = 1;
    80203820:	4785                	li	a5,1
    80203822:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80203824:	00019517          	auipc	a0,0x19
    80203828:	c2c50513          	addi	a0,a0,-980 # 8021c450 <ftable>
    8020382c:	ffffd097          	auipc	ra,0xffffd
    80203830:	f18080e7          	jalr	-232(ra) # 80200744 <release>
}
    80203834:	8526                	mv	a0,s1
    80203836:	60e2                	ld	ra,24(sp)
    80203838:	6442                	ld	s0,16(sp)
    8020383a:	64a2                	ld	s1,8(sp)
    8020383c:	6105                	addi	sp,sp,32
    8020383e:	8082                	ret

0000000080203840 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80203840:	1101                	addi	sp,sp,-32
    80203842:	ec06                	sd	ra,24(sp)
    80203844:	e822                	sd	s0,16(sp)
    80203846:	e426                	sd	s1,8(sp)
    80203848:	1000                	addi	s0,sp,32
    8020384a:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8020384c:	00019517          	auipc	a0,0x19
    80203850:	c0450513          	addi	a0,a0,-1020 # 8021c450 <ftable>
    80203854:	ffffd097          	auipc	ra,0xffffd
    80203858:	e9c080e7          	jalr	-356(ra) # 802006f0 <acquire>
  if(f->ref < 1)
    8020385c:	40dc                	lw	a5,4(s1)
    8020385e:	02f05263          	blez	a5,80203882 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80203862:	2785                	addiw	a5,a5,1
    80203864:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80203866:	00019517          	auipc	a0,0x19
    8020386a:	bea50513          	addi	a0,a0,-1046 # 8021c450 <ftable>
    8020386e:	ffffd097          	auipc	ra,0xffffd
    80203872:	ed6080e7          	jalr	-298(ra) # 80200744 <release>
  return f;
}
    80203876:	8526                	mv	a0,s1
    80203878:	60e2                	ld	ra,24(sp)
    8020387a:	6442                	ld	s0,16(sp)
    8020387c:	64a2                	ld	s1,8(sp)
    8020387e:	6105                	addi	sp,sp,32
    80203880:	8082                	ret
    panic("filedup");
    80203882:	00006517          	auipc	a0,0x6
    80203886:	23e50513          	addi	a0,a0,574 # 80209ac0 <etext+0xac0>
    8020388a:	ffffd097          	auipc	ra,0xffffd
    8020388e:	8bc080e7          	jalr	-1860(ra) # 80200146 <panic>

0000000080203892 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80203892:	7139                	addi	sp,sp,-64
    80203894:	fc06                	sd	ra,56(sp)
    80203896:	f822                	sd	s0,48(sp)
    80203898:	f426                	sd	s1,40(sp)
    8020389a:	0080                	addi	s0,sp,64
    8020389c:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8020389e:	00019517          	auipc	a0,0x19
    802038a2:	bb250513          	addi	a0,a0,-1102 # 8021c450 <ftable>
    802038a6:	ffffd097          	auipc	ra,0xffffd
    802038aa:	e4a080e7          	jalr	-438(ra) # 802006f0 <acquire>
  if(f->ref < 1)
    802038ae:	40dc                	lw	a5,4(s1)
    802038b0:	04f05b63          	blez	a5,80203906 <fileclose+0x74>
    panic("fileclose");
  if(--f->ref > 0){
    802038b4:	37fd                	addiw	a5,a5,-1
    802038b6:	0007871b          	sext.w	a4,a5
    802038ba:	c0dc                	sw	a5,4(s1)
    802038bc:	06e04163          	bgtz	a4,8020391e <fileclose+0x8c>
    802038c0:	f04a                	sd	s2,32(sp)
    802038c2:	ec4e                	sd	s3,24(sp)
    802038c4:	e852                	sd	s4,16(sp)
    802038c6:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    802038c8:	0004a903          	lw	s2,0(s1)
    802038cc:	0094ca03          	lbu	s4,9(s1)
    802038d0:	0104b983          	ld	s3,16(s1)
    802038d4:	0184ba83          	ld	s5,24(s1)
  f->ref = 0;
    802038d8:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    802038dc:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    802038e0:	00019517          	auipc	a0,0x19
    802038e4:	b7050513          	addi	a0,a0,-1168 # 8021c450 <ftable>
    802038e8:	ffffd097          	auipc	ra,0xffffd
    802038ec:	e5c080e7          	jalr	-420(ra) # 80200744 <release>

  if(ff.type == FD_PIPE){
    802038f0:	4785                	li	a5,1
    802038f2:	04f90363          	beq	s2,a5,80203938 <fileclose+0xa6>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_ENTRY){
    802038f6:	4789                	li	a5,2
    802038f8:	04f90b63          	beq	s2,a5,8020394e <fileclose+0xbc>
    802038fc:	7902                	ld	s2,32(sp)
    802038fe:	69e2                	ld	s3,24(sp)
    80203900:	6a42                	ld	s4,16(sp)
    80203902:	6aa2                	ld	s5,8(sp)
    80203904:	a02d                	j	8020392e <fileclose+0x9c>
    80203906:	f04a                	sd	s2,32(sp)
    80203908:	ec4e                	sd	s3,24(sp)
    8020390a:	e852                	sd	s4,16(sp)
    8020390c:	e456                	sd	s5,8(sp)
    panic("fileclose");
    8020390e:	00006517          	auipc	a0,0x6
    80203912:	1ba50513          	addi	a0,a0,442 # 80209ac8 <etext+0xac8>
    80203916:	ffffd097          	auipc	ra,0xffffd
    8020391a:	830080e7          	jalr	-2000(ra) # 80200146 <panic>
    release(&ftable.lock);
    8020391e:	00019517          	auipc	a0,0x19
    80203922:	b3250513          	addi	a0,a0,-1230 # 8021c450 <ftable>
    80203926:	ffffd097          	auipc	ra,0xffffd
    8020392a:	e1e080e7          	jalr	-482(ra) # 80200744 <release>
    eput(ff.ep);
  } else if (ff.type == FD_DEVICE) {

  }
}
    8020392e:	70e2                	ld	ra,56(sp)
    80203930:	7442                	ld	s0,48(sp)
    80203932:	74a2                	ld	s1,40(sp)
    80203934:	6121                	addi	sp,sp,64
    80203936:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80203938:	85d2                	mv	a1,s4
    8020393a:	854e                	mv	a0,s3
    8020393c:	00000097          	auipc	ra,0x0
    80203940:	418080e7          	jalr	1048(ra) # 80203d54 <pipeclose>
    80203944:	7902                	ld	s2,32(sp)
    80203946:	69e2                	ld	s3,24(sp)
    80203948:	6a42                	ld	s4,16(sp)
    8020394a:	6aa2                	ld	s5,8(sp)
    8020394c:	b7cd                	j	8020392e <fileclose+0x9c>
    eput(ff.ep);
    8020394e:	8556                	mv	a0,s5
    80203950:	00003097          	auipc	ra,0x3
    80203954:	afa080e7          	jalr	-1286(ra) # 8020644a <eput>
    80203958:	7902                	ld	s2,32(sp)
    8020395a:	69e2                	ld	s3,24(sp)
    8020395c:	6a42                	ld	s4,16(sp)
    8020395e:	6aa2                	ld	s5,8(sp)
    80203960:	b7f9                	j	8020392e <fileclose+0x9c>

0000000080203962 <filestat>:
filestat(struct file *f, uint64 addr)
{
  // struct proc *p = myproc();
  struct stat st;
  
  if(f->type == FD_ENTRY){
    80203962:	4118                	lw	a4,0(a0)
    80203964:	4789                	li	a5,2
    80203966:	04f71c63          	bne	a4,a5,802039be <filestat+0x5c>
{
    8020396a:	711d                	addi	sp,sp,-96
    8020396c:	ec86                	sd	ra,88(sp)
    8020396e:	e8a2                	sd	s0,80(sp)
    80203970:	e4a6                	sd	s1,72(sp)
    80203972:	e0ca                	sd	s2,64(sp)
    80203974:	1080                	addi	s0,sp,96
    80203976:	84aa                	mv	s1,a0
    80203978:	892e                	mv	s2,a1
    elock(f->ep);
    8020397a:	6d08                	ld	a0,24(a0)
    8020397c:	00003097          	auipc	ra,0x3
    80203980:	a4a080e7          	jalr	-1462(ra) # 802063c6 <elock>
    estat(f->ep, &st);
    80203984:	fa840593          	addi	a1,s0,-88
    80203988:	6c88                	ld	a0,24(s1)
    8020398a:	00003097          	auipc	ra,0x3
    8020398e:	bfc080e7          	jalr	-1028(ra) # 80206586 <estat>
    eunlock(f->ep);
    80203992:	6c88                	ld	a0,24(s1)
    80203994:	00003097          	auipc	ra,0x3
    80203998:	a68080e7          	jalr	-1432(ra) # 802063fc <eunlock>
    // if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    if(copyout2(addr, (char *)&st, sizeof(st)) < 0)
    8020399c:	03800613          	li	a2,56
    802039a0:	fa840593          	addi	a1,s0,-88
    802039a4:	854a                	mv	a0,s2
    802039a6:	ffffe097          	auipc	ra,0xffffe
    802039aa:	a52080e7          	jalr	-1454(ra) # 802013f8 <copyout2>
    802039ae:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    802039b2:	60e6                	ld	ra,88(sp)
    802039b4:	6446                	ld	s0,80(sp)
    802039b6:	64a6                	ld	s1,72(sp)
    802039b8:	6906                	ld	s2,64(sp)
    802039ba:	6125                	addi	sp,sp,96
    802039bc:	8082                	ret
  return -1;
    802039be:	557d                	li	a0,-1
}
    802039c0:	8082                	ret

00000000802039c2 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    802039c2:	7179                	addi	sp,sp,-48
    802039c4:	f406                	sd	ra,40(sp)
    802039c6:	f022                	sd	s0,32(sp)
    802039c8:	e84a                	sd	s2,16(sp)
    802039ca:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    802039cc:	00854783          	lbu	a5,8(a0)
    802039d0:	cbc5                	beqz	a5,80203a80 <fileread+0xbe>
    802039d2:	ec26                	sd	s1,24(sp)
    802039d4:	e44e                	sd	s3,8(sp)
    802039d6:	84aa                	mv	s1,a0
    802039d8:	892e                	mv	s2,a1
    802039da:	89b2                	mv	s3,a2
    return -1;

  switch (f->type) {
    802039dc:	411c                	lw	a5,0(a0)
    802039de:	4709                	li	a4,2
    802039e0:	04e78c63          	beq	a5,a4,80203a38 <fileread+0x76>
    802039e4:	470d                	li	a4,3
    802039e6:	02e78363          	beq	a5,a4,80203a0c <fileread+0x4a>
    802039ea:	4705                	li	a4,1
    802039ec:	08e79263          	bne	a5,a4,80203a70 <fileread+0xae>
    case FD_PIPE:
        r = piperead(f->pipe, addr, n);
    802039f0:	6908                	ld	a0,16(a0)
    802039f2:	00000097          	auipc	ra,0x0
    802039f6:	4c8080e7          	jalr	1224(ra) # 80203eba <piperead>
    802039fa:	892a                	mv	s2,a0
        break;
    802039fc:	64e2                	ld	s1,24(sp)
    802039fe:	69a2                	ld	s3,8(sp)
    default:
      panic("fileread");
  }

  return r;
}
    80203a00:	854a                	mv	a0,s2
    80203a02:	70a2                	ld	ra,40(sp)
    80203a04:	7402                	ld	s0,32(sp)
    80203a06:	6942                	ld	s2,16(sp)
    80203a08:	6145                	addi	sp,sp,48
    80203a0a:	8082                	ret
        if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80203a0c:	02451783          	lh	a5,36(a0)
    80203a10:	03079693          	slli	a3,a5,0x30
    80203a14:	92c1                	srli	a3,a3,0x30
    80203a16:	4725                	li	a4,9
    80203a18:	06d76663          	bltu	a4,a3,80203a84 <fileread+0xc2>
    80203a1c:	0792                	slli	a5,a5,0x4
    80203a1e:	00019717          	auipc	a4,0x19
    80203a22:	99270713          	addi	a4,a4,-1646 # 8021c3b0 <devsw>
    80203a26:	97ba                	add	a5,a5,a4
    80203a28:	639c                	ld	a5,0(a5)
    80203a2a:	c3ad                	beqz	a5,80203a8c <fileread+0xca>
        r = devsw[f->major].read(1, addr, n);
    80203a2c:	4505                	li	a0,1
    80203a2e:	9782                	jalr	a5
    80203a30:	892a                	mv	s2,a0
        break;
    80203a32:	64e2                	ld	s1,24(sp)
    80203a34:	69a2                	ld	s3,8(sp)
    80203a36:	b7e9                	j	80203a00 <fileread+0x3e>
        elock(f->ep);
    80203a38:	6d08                	ld	a0,24(a0)
    80203a3a:	00003097          	auipc	ra,0x3
    80203a3e:	98c080e7          	jalr	-1652(ra) # 802063c6 <elock>
          if((r = eread(f->ep, 1, addr, f->off, n)) > 0)
    80203a42:	874e                	mv	a4,s3
    80203a44:	5094                	lw	a3,32(s1)
    80203a46:	864a                	mv	a2,s2
    80203a48:	4585                	li	a1,1
    80203a4a:	6c88                	ld	a0,24(s1)
    80203a4c:	00002097          	auipc	ra,0x2
    80203a50:	064080e7          	jalr	100(ra) # 80205ab0 <eread>
    80203a54:	892a                	mv	s2,a0
    80203a56:	00a05563          	blez	a0,80203a60 <fileread+0x9e>
            f->off += r;
    80203a5a:	509c                	lw	a5,32(s1)
    80203a5c:	9fa9                	addw	a5,a5,a0
    80203a5e:	d09c                	sw	a5,32(s1)
        eunlock(f->ep);
    80203a60:	6c88                	ld	a0,24(s1)
    80203a62:	00003097          	auipc	ra,0x3
    80203a66:	99a080e7          	jalr	-1638(ra) # 802063fc <eunlock>
        break;
    80203a6a:	64e2                	ld	s1,24(sp)
    80203a6c:	69a2                	ld	s3,8(sp)
    80203a6e:	bf49                	j	80203a00 <fileread+0x3e>
      panic("fileread");
    80203a70:	00006517          	auipc	a0,0x6
    80203a74:	06850513          	addi	a0,a0,104 # 80209ad8 <etext+0xad8>
    80203a78:	ffffc097          	auipc	ra,0xffffc
    80203a7c:	6ce080e7          	jalr	1742(ra) # 80200146 <panic>
    return -1;
    80203a80:	597d                	li	s2,-1
    80203a82:	bfbd                	j	80203a00 <fileread+0x3e>
          return -1;
    80203a84:	597d                	li	s2,-1
    80203a86:	64e2                	ld	s1,24(sp)
    80203a88:	69a2                	ld	s3,8(sp)
    80203a8a:	bf9d                	j	80203a00 <fileread+0x3e>
    80203a8c:	597d                	li	s2,-1
    80203a8e:	64e2                	ld	s1,24(sp)
    80203a90:	69a2                	ld	s3,8(sp)
    80203a92:	b7bd                	j	80203a00 <fileread+0x3e>

0000000080203a94 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80203a94:	7179                	addi	sp,sp,-48
    80203a96:	f406                	sd	ra,40(sp)
    80203a98:	f022                	sd	s0,32(sp)
    80203a9a:	e44e                	sd	s3,8(sp)
    80203a9c:	1800                	addi	s0,sp,48
  int ret = 0;

  if(f->writable == 0)
    80203a9e:	00954783          	lbu	a5,9(a0)
    80203aa2:	cfe9                	beqz	a5,80203b7c <filewrite+0xe8>
    80203aa4:	ec26                	sd	s1,24(sp)
    80203aa6:	e84a                	sd	s2,16(sp)
    80203aa8:	84aa                	mv	s1,a0
    80203aaa:	89ae                	mv	s3,a1
    80203aac:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80203aae:	411c                	lw	a5,0(a0)
    80203ab0:	4705                	li	a4,1
    80203ab2:	06e78763          	beq	a5,a4,80203b20 <filewrite+0x8c>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80203ab6:	470d                	li	a4,3
    80203ab8:	06e78d63          	beq	a5,a4,80203b32 <filewrite+0x9e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_ENTRY){
    80203abc:	4709                	li	a4,2
    80203abe:	0ae79663          	bne	a5,a4,80203b6a <filewrite+0xd6>
    struct proc *p = myproc();
    80203ac2:	ffffe097          	auipc	ra,0xffffe
    80203ac6:	00c080e7          	jalr	12(ra) # 80201ace <myproc>
    if(n < 0 || addr >= p->sz || (uint64)n > p->sz - addr)
    80203aca:	0c094363          	bltz	s2,80203b90 <filewrite+0xfc>
    80203ace:	653c                	ld	a5,72(a0)
    80203ad0:	0cf9f463          	bgeu	s3,a5,80203b98 <filewrite+0x104>
    80203ad4:	413787b3          	sub	a5,a5,s3
    80203ad8:	0d27e463          	bltu	a5,s2,80203ba0 <filewrite+0x10c>
    80203adc:	e052                	sd	s4,0(sp)
      return -1;
    elock(f->ep);
    80203ade:	6c88                	ld	a0,24(s1)
    80203ae0:	00003097          	auipc	ra,0x3
    80203ae4:	8e6080e7          	jalr	-1818(ra) # 802063c6 <elock>
    if (ewrite(f->ep, 1, addr, f->off, n) == n) {
    80203ae8:	00090a1b          	sext.w	s4,s2
    80203aec:	8752                	mv	a4,s4
    80203aee:	5094                	lw	a3,32(s1)
    80203af0:	864e                	mv	a2,s3
    80203af2:	4585                	li	a1,1
    80203af4:	6c88                	ld	a0,24(s1)
    80203af6:	00002097          	auipc	ra,0x2
    80203afa:	0c8080e7          	jalr	200(ra) # 80205bbe <ewrite>
      ret = n;
      f->off += n;
    } else {
      ret = -1;
    80203afe:	59fd                	li	s3,-1
    if (ewrite(f->ep, 1, addr, f->off, n) == n) {
    80203b00:	05250f63          	beq	a0,s2,80203b5e <filewrite+0xca>
    }
    eunlock(f->ep);
    80203b04:	6c88                	ld	a0,24(s1)
    80203b06:	00003097          	auipc	ra,0x3
    80203b0a:	8f6080e7          	jalr	-1802(ra) # 802063fc <eunlock>
    80203b0e:	64e2                	ld	s1,24(sp)
    80203b10:	6942                	ld	s2,16(sp)
    80203b12:	6a02                	ld	s4,0(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80203b14:	854e                	mv	a0,s3
    80203b16:	70a2                	ld	ra,40(sp)
    80203b18:	7402                	ld	s0,32(sp)
    80203b1a:	69a2                	ld	s3,8(sp)
    80203b1c:	6145                	addi	sp,sp,48
    80203b1e:	8082                	ret
    ret = pipewrite(f->pipe, addr, n);
    80203b20:	6908                	ld	a0,16(a0)
    80203b22:	00000097          	auipc	ra,0x0
    80203b26:	2a2080e7          	jalr	674(ra) # 80203dc4 <pipewrite>
    80203b2a:	89aa                	mv	s3,a0
    80203b2c:	64e2                	ld	s1,24(sp)
    80203b2e:	6942                	ld	s2,16(sp)
    80203b30:	b7d5                	j	80203b14 <filewrite+0x80>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80203b32:	02451783          	lh	a5,36(a0)
    80203b36:	03079693          	slli	a3,a5,0x30
    80203b3a:	92c1                	srli	a3,a3,0x30
    80203b3c:	4725                	li	a4,9
    80203b3e:	04d76163          	bltu	a4,a3,80203b80 <filewrite+0xec>
    80203b42:	0792                	slli	a5,a5,0x4
    80203b44:	00019717          	auipc	a4,0x19
    80203b48:	86c70713          	addi	a4,a4,-1940 # 8021c3b0 <devsw>
    80203b4c:	97ba                	add	a5,a5,a4
    80203b4e:	679c                	ld	a5,8(a5)
    80203b50:	cf85                	beqz	a5,80203b88 <filewrite+0xf4>
    ret = devsw[f->major].write(1, addr, n);
    80203b52:	4505                	li	a0,1
    80203b54:	9782                	jalr	a5
    80203b56:	89aa                	mv	s3,a0
    80203b58:	64e2                	ld	s1,24(sp)
    80203b5a:	6942                	ld	s2,16(sp)
    80203b5c:	bf65                	j	80203b14 <filewrite+0x80>
      f->off += n;
    80203b5e:	509c                	lw	a5,32(s1)
    80203b60:	014787bb          	addw	a5,a5,s4
    80203b64:	d09c                	sw	a5,32(s1)
      ret = n;
    80203b66:	89ca                	mv	s3,s2
    80203b68:	bf71                	j	80203b04 <filewrite+0x70>
    80203b6a:	e052                	sd	s4,0(sp)
    panic("filewrite");
    80203b6c:	00006517          	auipc	a0,0x6
    80203b70:	f7c50513          	addi	a0,a0,-132 # 80209ae8 <etext+0xae8>
    80203b74:	ffffc097          	auipc	ra,0xffffc
    80203b78:	5d2080e7          	jalr	1490(ra) # 80200146 <panic>
    return -1;
    80203b7c:	59fd                	li	s3,-1
    80203b7e:	bf59                	j	80203b14 <filewrite+0x80>
      return -1;
    80203b80:	59fd                	li	s3,-1
    80203b82:	64e2                	ld	s1,24(sp)
    80203b84:	6942                	ld	s2,16(sp)
    80203b86:	b779                	j	80203b14 <filewrite+0x80>
    80203b88:	59fd                	li	s3,-1
    80203b8a:	64e2                	ld	s1,24(sp)
    80203b8c:	6942                	ld	s2,16(sp)
    80203b8e:	b759                	j	80203b14 <filewrite+0x80>
      return -1;
    80203b90:	59fd                	li	s3,-1
    80203b92:	64e2                	ld	s1,24(sp)
    80203b94:	6942                	ld	s2,16(sp)
    80203b96:	bfbd                	j	80203b14 <filewrite+0x80>
    80203b98:	59fd                	li	s3,-1
    80203b9a:	64e2                	ld	s1,24(sp)
    80203b9c:	6942                	ld	s2,16(sp)
    80203b9e:	bf9d                	j	80203b14 <filewrite+0x80>
    80203ba0:	59fd                	li	s3,-1
    80203ba2:	64e2                	ld	s1,24(sp)
    80203ba4:	6942                	ld	s2,16(sp)
    80203ba6:	b7bd                	j	80203b14 <filewrite+0x80>

0000000080203ba8 <dirnext>:
int
dirnext(struct file *f, uint64 addr)
{
  // struct proc *p = myproc();

  if(f->readable == 0 || !(f->ep->attribute & ATTR_DIRECTORY))
    80203ba8:	00854783          	lbu	a5,8(a0)
    80203bac:	c3e1                	beqz	a5,80203c6c <dirnext+0xc4>
{
    80203bae:	7105                	addi	sp,sp,-480
    80203bb0:	ef86                	sd	ra,472(sp)
    80203bb2:	eba2                	sd	s0,464(sp)
    80203bb4:	e7a6                	sd	s1,456(sp)
    80203bb6:	ff4e                	sd	s3,440(sp)
    80203bb8:	1380                	addi	s0,sp,480
    80203bba:	84aa                	mv	s1,a0
    80203bbc:	89ae                	mv	s3,a1
  if(f->readable == 0 || !(f->ep->attribute & ATTR_DIRECTORY))
    80203bbe:	6d1c                	ld	a5,24(a0)
    80203bc0:	1007c783          	lbu	a5,256(a5)
    80203bc4:	8bc1                	andi	a5,a5,16
    return -1;
    80203bc6:	557d                	li	a0,-1
  if(f->readable == 0 || !(f->ep->attribute & ATTR_DIRECTORY))
    80203bc8:	e799                	bnez	a5,80203bd6 <dirnext+0x2e>
  // if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
  if(copyout2(addr, (char *)&st, sizeof(st)) < 0)
    return -1;

  return 1;
    80203bca:	60fe                	ld	ra,472(sp)
    80203bcc:	645e                	ld	s0,464(sp)
    80203bce:	64be                	ld	s1,456(sp)
    80203bd0:	79fa                	ld	s3,440(sp)
    80203bd2:	613d                	addi	sp,sp,480
    80203bd4:	8082                	ret
    80203bd6:	e3ca                	sd	s2,448(sp)
  memset(&de, 0, sizeof(de));
    80203bd8:	16800613          	li	a2,360
    80203bdc:	4581                	li	a1,0
    80203bde:	e6840513          	addi	a0,s0,-408
    80203be2:	ffffd097          	auipc	ra,0xffffd
    80203be6:	baa080e7          	jalr	-1110(ra) # 8020078c <memset>
  int count = 0;
    80203bea:	e2042623          	sw	zero,-468(s0)
  elock(f->ep);
    80203bee:	6c88                	ld	a0,24(s1)
    80203bf0:	00002097          	auipc	ra,0x2
    80203bf4:	7d6080e7          	jalr	2006(ra) # 802063c6 <elock>
  while ((ret = enext(f->ep, &de, f->off, &count)) == 0) {  // skip empty entry
    80203bf8:	a801                	j	80203c08 <dirnext+0x60>
    f->off += count * 32;
    80203bfa:	e2c42783          	lw	a5,-468(s0)
    80203bfe:	0057979b          	slliw	a5,a5,0x5
    80203c02:	5098                	lw	a4,32(s1)
    80203c04:	9fb9                	addw	a5,a5,a4
    80203c06:	d09c                	sw	a5,32(s1)
  while ((ret = enext(f->ep, &de, f->off, &count)) == 0) {  // skip empty entry
    80203c08:	e2c40693          	addi	a3,s0,-468
    80203c0c:	5090                	lw	a2,32(s1)
    80203c0e:	e6840593          	addi	a1,s0,-408
    80203c12:	6c88                	ld	a0,24(s1)
    80203c14:	00003097          	auipc	ra,0x3
    80203c18:	9ba080e7          	jalr	-1606(ra) # 802065ce <enext>
    80203c1c:	892a                	mv	s2,a0
    80203c1e:	dd71                	beqz	a0,80203bfa <dirnext+0x52>
  eunlock(f->ep);
    80203c20:	6c88                	ld	a0,24(s1)
    80203c22:	00002097          	auipc	ra,0x2
    80203c26:	7da080e7          	jalr	2010(ra) # 802063fc <eunlock>
  if (ret == -1)
    80203c2a:	57fd                	li	a5,-1
    return 0;
    80203c2c:	4501                	li	a0,0
  if (ret == -1)
    80203c2e:	04f90163          	beq	s2,a5,80203c70 <dirnext+0xc8>
  f->off += count * 32;
    80203c32:	e2c42783          	lw	a5,-468(s0)
    80203c36:	0057979b          	slliw	a5,a5,0x5
    80203c3a:	5098                	lw	a4,32(s1)
    80203c3c:	9fb9                	addw	a5,a5,a4
    80203c3e:	d09c                	sw	a5,32(s1)
  estat(&de, &st);
    80203c40:	e3040593          	addi	a1,s0,-464
    80203c44:	e6840513          	addi	a0,s0,-408
    80203c48:	00003097          	auipc	ra,0x3
    80203c4c:	93e080e7          	jalr	-1730(ra) # 80206586 <estat>
  if(copyout2(addr, (char *)&st, sizeof(st)) < 0)
    80203c50:	03800613          	li	a2,56
    80203c54:	e3040593          	addi	a1,s0,-464
    80203c58:	854e                	mv	a0,s3
    80203c5a:	ffffd097          	auipc	ra,0xffffd
    80203c5e:	79e080e7          	jalr	1950(ra) # 802013f8 <copyout2>
  return 1;
    80203c62:	957d                	srai	a0,a0,0x3f
    80203c64:	00156513          	ori	a0,a0,1
    80203c68:	691e                	ld	s2,448(sp)
    80203c6a:	b785                	j	80203bca <dirnext+0x22>
    return -1;
    80203c6c:	557d                	li	a0,-1
    80203c6e:	8082                	ret
    80203c70:	691e                	ld	s2,448(sp)
    80203c72:	bfa1                	j	80203bca <dirnext+0x22>

0000000080203c74 <pipealloc>:
#include "include/kalloc.h"
#include "include/vm.h"

int
pipealloc(struct file **f0, struct file **f1)
{
    80203c74:	7179                	addi	sp,sp,-48
    80203c76:	f406                	sd	ra,40(sp)
    80203c78:	f022                	sd	s0,32(sp)
    80203c7a:	ec26                	sd	s1,24(sp)
    80203c7c:	e052                	sd	s4,0(sp)
    80203c7e:	1800                	addi	s0,sp,48
    80203c80:	84aa                	mv	s1,a0
    80203c82:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80203c84:	0005b023          	sd	zero,0(a1)
    80203c88:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == NULL || (*f1 = filealloc()) == NULL)
    80203c8c:	00000097          	auipc	ra,0x0
    80203c90:	b4a080e7          	jalr	-1206(ra) # 802037d6 <filealloc>
    80203c94:	e088                	sd	a0,0(s1)
    80203c96:	cd49                	beqz	a0,80203d30 <pipealloc+0xbc>
    80203c98:	00000097          	auipc	ra,0x0
    80203c9c:	b3e080e7          	jalr	-1218(ra) # 802037d6 <filealloc>
    80203ca0:	00aa3023          	sd	a0,0(s4)
    80203ca4:	c141                	beqz	a0,80203d24 <pipealloc+0xb0>
    80203ca6:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == NULL)
    80203ca8:	ffffd097          	auipc	ra,0xffffd
    80203cac:	8dc080e7          	jalr	-1828(ra) # 80200584 <kalloc>
    80203cb0:	892a                	mv	s2,a0
    80203cb2:	c13d                	beqz	a0,80203d18 <pipealloc+0xa4>
    80203cb4:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80203cb6:	4985                	li	s3,1
    80203cb8:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80203cbc:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80203cc0:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80203cc4:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80203cc8:	00006597          	auipc	a1,0x6
    80203ccc:	ce858593          	addi	a1,a1,-792 # 802099b0 <etext+0x9b0>
    80203cd0:	ffffd097          	auipc	ra,0xffffd
    80203cd4:	9dc080e7          	jalr	-1572(ra) # 802006ac <initlock>
  (*f0)->type = FD_PIPE;
    80203cd8:	609c                	ld	a5,0(s1)
    80203cda:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80203cde:	609c                	ld	a5,0(s1)
    80203ce0:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80203ce4:	609c                	ld	a5,0(s1)
    80203ce6:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80203cea:	609c                	ld	a5,0(s1)
    80203cec:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80203cf0:	000a3783          	ld	a5,0(s4)
    80203cf4:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80203cf8:	000a3783          	ld	a5,0(s4)
    80203cfc:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80203d00:	000a3783          	ld	a5,0(s4)
    80203d04:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80203d08:	000a3783          	ld	a5,0(s4)
    80203d0c:	0127b823          	sd	s2,16(a5)
  return 0;
    80203d10:	4501                	li	a0,0
    80203d12:	6942                	ld	s2,16(sp)
    80203d14:	69a2                	ld	s3,8(sp)
    80203d16:	a03d                	j	80203d44 <pipealloc+0xd0>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80203d18:	6088                	ld	a0,0(s1)
    80203d1a:	c119                	beqz	a0,80203d20 <pipealloc+0xac>
    80203d1c:	6942                	ld	s2,16(sp)
    80203d1e:	a029                	j	80203d28 <pipealloc+0xb4>
    80203d20:	6942                	ld	s2,16(sp)
    80203d22:	a039                	j	80203d30 <pipealloc+0xbc>
    80203d24:	6088                	ld	a0,0(s1)
    80203d26:	c50d                	beqz	a0,80203d50 <pipealloc+0xdc>
    fileclose(*f0);
    80203d28:	00000097          	auipc	ra,0x0
    80203d2c:	b6a080e7          	jalr	-1174(ra) # 80203892 <fileclose>
  if(*f1)
    80203d30:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80203d34:	557d                	li	a0,-1
  if(*f1)
    80203d36:	c799                	beqz	a5,80203d44 <pipealloc+0xd0>
    fileclose(*f1);
    80203d38:	853e                	mv	a0,a5
    80203d3a:	00000097          	auipc	ra,0x0
    80203d3e:	b58080e7          	jalr	-1192(ra) # 80203892 <fileclose>
  return -1;
    80203d42:	557d                	li	a0,-1
}
    80203d44:	70a2                	ld	ra,40(sp)
    80203d46:	7402                	ld	s0,32(sp)
    80203d48:	64e2                	ld	s1,24(sp)
    80203d4a:	6a02                	ld	s4,0(sp)
    80203d4c:	6145                	addi	sp,sp,48
    80203d4e:	8082                	ret
  return -1;
    80203d50:	557d                	li	a0,-1
    80203d52:	bfcd                	j	80203d44 <pipealloc+0xd0>

0000000080203d54 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80203d54:	1101                	addi	sp,sp,-32
    80203d56:	ec06                	sd	ra,24(sp)
    80203d58:	e822                	sd	s0,16(sp)
    80203d5a:	e426                	sd	s1,8(sp)
    80203d5c:	e04a                	sd	s2,0(sp)
    80203d5e:	1000                	addi	s0,sp,32
    80203d60:	84aa                	mv	s1,a0
    80203d62:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80203d64:	ffffd097          	auipc	ra,0xffffd
    80203d68:	98c080e7          	jalr	-1652(ra) # 802006f0 <acquire>
  if(writable){
    80203d6c:	02090d63          	beqz	s2,80203da6 <pipeclose+0x52>
    pi->writeopen = 0;
    80203d70:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80203d74:	21848513          	addi	a0,s1,536
    80203d78:	ffffe097          	auipc	ra,0xffffe
    80203d7c:	746080e7          	jalr	1862(ra) # 802024be <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80203d80:	2204b783          	ld	a5,544(s1)
    80203d84:	eb95                	bnez	a5,80203db8 <pipeclose+0x64>
    release(&pi->lock);
    80203d86:	8526                	mv	a0,s1
    80203d88:	ffffd097          	auipc	ra,0xffffd
    80203d8c:	9bc080e7          	jalr	-1604(ra) # 80200744 <release>
    kfree((char*)pi);
    80203d90:	8526                	mv	a0,s1
    80203d92:	ffffc097          	auipc	ra,0xffffc
    80203d96:	6d8080e7          	jalr	1752(ra) # 8020046a <kfree>
  } else
    release(&pi->lock);
}
    80203d9a:	60e2                	ld	ra,24(sp)
    80203d9c:	6442                	ld	s0,16(sp)
    80203d9e:	64a2                	ld	s1,8(sp)
    80203da0:	6902                	ld	s2,0(sp)
    80203da2:	6105                	addi	sp,sp,32
    80203da4:	8082                	ret
    pi->readopen = 0;
    80203da6:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80203daa:	21c48513          	addi	a0,s1,540
    80203dae:	ffffe097          	auipc	ra,0xffffe
    80203db2:	710080e7          	jalr	1808(ra) # 802024be <wakeup>
    80203db6:	b7e9                	j	80203d80 <pipeclose+0x2c>
    release(&pi->lock);
    80203db8:	8526                	mv	a0,s1
    80203dba:	ffffd097          	auipc	ra,0xffffd
    80203dbe:	98a080e7          	jalr	-1654(ra) # 80200744 <release>
}
    80203dc2:	bfe1                	j	80203d9a <pipeclose+0x46>

0000000080203dc4 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80203dc4:	711d                	addi	sp,sp,-96
    80203dc6:	ec86                	sd	ra,88(sp)
    80203dc8:	e8a2                	sd	s0,80(sp)
    80203dca:	e4a6                	sd	s1,72(sp)
    80203dcc:	e0ca                	sd	s2,64(sp)
    80203dce:	fc4e                	sd	s3,56(sp)
    80203dd0:	f852                	sd	s4,48(sp)
    80203dd2:	f456                	sd	s5,40(sp)
    80203dd4:	f05a                	sd	s6,32(sp)
    80203dd6:	ec5e                	sd	s7,24(sp)
    80203dd8:	1080                	addi	s0,sp,96
    80203dda:	84aa                	mv	s1,a0
    80203ddc:	8b2e                	mv	s6,a1
    80203dde:	8ab2                	mv	s5,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80203de0:	ffffe097          	auipc	ra,0xffffe
    80203de4:	cee080e7          	jalr	-786(ra) # 80201ace <myproc>
    80203de8:	892a                	mv	s2,a0

  acquire(&pi->lock);
    80203dea:	8526                	mv	a0,s1
    80203dec:	ffffd097          	auipc	ra,0xffffd
    80203df0:	904080e7          	jalr	-1788(ra) # 802006f0 <acquire>
  for(i = 0; i < n; i++){
    80203df4:	4b81                	li	s7,0
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || pr->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80203df6:	21848a13          	addi	s4,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80203dfa:	21c48993          	addi	s3,s1,540
  for(i = 0; i < n; i++){
    80203dfe:	09505063          	blez	s5,80203e7e <pipewrite+0xba>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80203e02:	2184a783          	lw	a5,536(s1)
    80203e06:	21c4a703          	lw	a4,540(s1)
    80203e0a:	2007879b          	addiw	a5,a5,512
    80203e0e:	02f71b63          	bne	a4,a5,80203e44 <pipewrite+0x80>
      if(pi->readopen == 0 || pr->killed){
    80203e12:	2204a783          	lw	a5,544(s1)
    80203e16:	c3c1                	beqz	a5,80203e96 <pipewrite+0xd2>
    80203e18:	03092783          	lw	a5,48(s2)
    80203e1c:	efad                	bnez	a5,80203e96 <pipewrite+0xd2>
      wakeup(&pi->nread);
    80203e1e:	8552                	mv	a0,s4
    80203e20:	ffffe097          	auipc	ra,0xffffe
    80203e24:	69e080e7          	jalr	1694(ra) # 802024be <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80203e28:	85a6                	mv	a1,s1
    80203e2a:	854e                	mv	a0,s3
    80203e2c:	ffffe097          	auipc	ra,0xffffe
    80203e30:	516080e7          	jalr	1302(ra) # 80202342 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80203e34:	2184a783          	lw	a5,536(s1)
    80203e38:	21c4a703          	lw	a4,540(s1)
    80203e3c:	2007879b          	addiw	a5,a5,512
    80203e40:	fcf709e3          	beq	a4,a5,80203e12 <pipewrite+0x4e>
    }
    // if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    if(copyin2(&ch, addr + i, 1) == -1)
    80203e44:	4605                	li	a2,1
    80203e46:	85da                	mv	a1,s6
    80203e48:	faf40513          	addi	a0,s0,-81
    80203e4c:	ffffd097          	auipc	ra,0xffffd
    80203e50:	68c080e7          	jalr	1676(ra) # 802014d8 <copyin2>
    80203e54:	57fd                	li	a5,-1
    80203e56:	02f50463          	beq	a0,a5,80203e7e <pipewrite+0xba>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80203e5a:	21c4a783          	lw	a5,540(s1)
    80203e5e:	0017871b          	addiw	a4,a5,1
    80203e62:	20e4ae23          	sw	a4,540(s1)
    80203e66:	1ff7f793          	andi	a5,a5,511
    80203e6a:	97a6                	add	a5,a5,s1
    80203e6c:	faf44703          	lbu	a4,-81(s0)
    80203e70:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    80203e74:	2b85                	addiw	s7,s7,1
    80203e76:	0b05                	addi	s6,s6,1
    80203e78:	f97a95e3          	bne	s5,s7,80203e02 <pipewrite+0x3e>
    80203e7c:	8bd6                	mv	s7,s5
  }
  wakeup(&pi->nread);
    80203e7e:	21848513          	addi	a0,s1,536
    80203e82:	ffffe097          	auipc	ra,0xffffe
    80203e86:	63c080e7          	jalr	1596(ra) # 802024be <wakeup>
  release(&pi->lock);
    80203e8a:	8526                	mv	a0,s1
    80203e8c:	ffffd097          	auipc	ra,0xffffd
    80203e90:	8b8080e7          	jalr	-1864(ra) # 80200744 <release>
  return i;
    80203e94:	a039                	j	80203ea2 <pipewrite+0xde>
        release(&pi->lock);
    80203e96:	8526                	mv	a0,s1
    80203e98:	ffffd097          	auipc	ra,0xffffd
    80203e9c:	8ac080e7          	jalr	-1876(ra) # 80200744 <release>
        return -1;
    80203ea0:	5bfd                	li	s7,-1
}
    80203ea2:	855e                	mv	a0,s7
    80203ea4:	60e6                	ld	ra,88(sp)
    80203ea6:	6446                	ld	s0,80(sp)
    80203ea8:	64a6                	ld	s1,72(sp)
    80203eaa:	6906                	ld	s2,64(sp)
    80203eac:	79e2                	ld	s3,56(sp)
    80203eae:	7a42                	ld	s4,48(sp)
    80203eb0:	7aa2                	ld	s5,40(sp)
    80203eb2:	7b02                	ld	s6,32(sp)
    80203eb4:	6be2                	ld	s7,24(sp)
    80203eb6:	6125                	addi	sp,sp,96
    80203eb8:	8082                	ret

0000000080203eba <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80203eba:	715d                	addi	sp,sp,-80
    80203ebc:	e486                	sd	ra,72(sp)
    80203ebe:	e0a2                	sd	s0,64(sp)
    80203ec0:	fc26                	sd	s1,56(sp)
    80203ec2:	f84a                	sd	s2,48(sp)
    80203ec4:	f44e                	sd	s3,40(sp)
    80203ec6:	f052                	sd	s4,32(sp)
    80203ec8:	ec56                	sd	s5,24(sp)
    80203eca:	0880                	addi	s0,sp,80
    80203ecc:	84aa                	mv	s1,a0
    80203ece:	892e                	mv	s2,a1
    80203ed0:	8a32                	mv	s4,a2
  int i;
  struct proc *pr = myproc();
    80203ed2:	ffffe097          	auipc	ra,0xffffe
    80203ed6:	bfc080e7          	jalr	-1028(ra) # 80201ace <myproc>
    80203eda:	89aa                	mv	s3,a0
  char ch;

  acquire(&pi->lock);
    80203edc:	8526                	mv	a0,s1
    80203ede:	ffffd097          	auipc	ra,0xffffd
    80203ee2:	812080e7          	jalr	-2030(ra) # 802006f0 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80203ee6:	2184a703          	lw	a4,536(s1)
    80203eea:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80203eee:	21848a93          	addi	s5,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80203ef2:	02f71463          	bne	a4,a5,80203f1a <piperead+0x60>
    80203ef6:	2244a783          	lw	a5,548(s1)
    80203efa:	c385                	beqz	a5,80203f1a <piperead+0x60>
    if(pr->killed){
    80203efc:	0309a783          	lw	a5,48(s3)
    80203f00:	e7d1                	bnez	a5,80203f8c <piperead+0xd2>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80203f02:	85a6                	mv	a1,s1
    80203f04:	8556                	mv	a0,s5
    80203f06:	ffffe097          	auipc	ra,0xffffe
    80203f0a:	43c080e7          	jalr	1084(ra) # 80202342 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80203f0e:	2184a703          	lw	a4,536(s1)
    80203f12:	21c4a783          	lw	a5,540(s1)
    80203f16:	fef700e3          	beq	a4,a5,80203ef6 <piperead+0x3c>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80203f1a:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    // if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    if(copyout2(addr + i, &ch, 1) == -1)
    80203f1c:	5afd                	li	s5,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80203f1e:	05405263          	blez	s4,80203f62 <piperead+0xa8>
    if(pi->nread == pi->nwrite)
    80203f22:	2184a783          	lw	a5,536(s1)
    80203f26:	21c4a703          	lw	a4,540(s1)
    80203f2a:	02f70c63          	beq	a4,a5,80203f62 <piperead+0xa8>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80203f2e:	0017871b          	addiw	a4,a5,1
    80203f32:	20e4ac23          	sw	a4,536(s1)
    80203f36:	1ff7f793          	andi	a5,a5,511
    80203f3a:	97a6                	add	a5,a5,s1
    80203f3c:	0187c783          	lbu	a5,24(a5)
    80203f40:	faf40fa3          	sb	a5,-65(s0)
    if(copyout2(addr + i, &ch, 1) == -1)
    80203f44:	4605                	li	a2,1
    80203f46:	fbf40593          	addi	a1,s0,-65
    80203f4a:	854a                	mv	a0,s2
    80203f4c:	ffffd097          	auipc	ra,0xffffd
    80203f50:	4ac080e7          	jalr	1196(ra) # 802013f8 <copyout2>
    80203f54:	01550763          	beq	a0,s5,80203f62 <piperead+0xa8>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80203f58:	2985                	addiw	s3,s3,1
    80203f5a:	0905                	addi	s2,s2,1
    80203f5c:	fd3a13e3          	bne	s4,s3,80203f22 <piperead+0x68>
    80203f60:	89d2                	mv	s3,s4
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80203f62:	21c48513          	addi	a0,s1,540
    80203f66:	ffffe097          	auipc	ra,0xffffe
    80203f6a:	558080e7          	jalr	1368(ra) # 802024be <wakeup>
  release(&pi->lock);
    80203f6e:	8526                	mv	a0,s1
    80203f70:	ffffc097          	auipc	ra,0xffffc
    80203f74:	7d4080e7          	jalr	2004(ra) # 80200744 <release>
  return i;
}
    80203f78:	854e                	mv	a0,s3
    80203f7a:	60a6                	ld	ra,72(sp)
    80203f7c:	6406                	ld	s0,64(sp)
    80203f7e:	74e2                	ld	s1,56(sp)
    80203f80:	7942                	ld	s2,48(sp)
    80203f82:	79a2                	ld	s3,40(sp)
    80203f84:	7a02                	ld	s4,32(sp)
    80203f86:	6ae2                	ld	s5,24(sp)
    80203f88:	6161                	addi	sp,sp,80
    80203f8a:	8082                	ret
      release(&pi->lock);
    80203f8c:	8526                	mv	a0,s1
    80203f8e:	ffffc097          	auipc	ra,0xffffc
    80203f92:	7b6080e7          	jalr	1974(ra) # 80200744 <release>
      return -1;
    80203f96:	59fd                	li	s3,-1
    80203f98:	b7c5                	j	80203f78 <piperead+0xbe>

0000000080203f9a <exec>:
  return 0;
}


int exec(char *path, char **argv)
{
    80203f9a:	de010113          	addi	sp,sp,-544
    80203f9e:	20113c23          	sd	ra,536(sp)
    80203fa2:	20813823          	sd	s0,528(sp)
    80203fa6:	20913423          	sd	s1,520(sp)
    80203faa:	21213023          	sd	s2,512(sp)
    80203fae:	1400                	addi	s0,sp,544
    80203fb0:	892a                	mv	s2,a0
    80203fb2:	dea43823          	sd	a0,-528(s0)
    80203fb6:	deb43c23          	sd	a1,-520(s0)
  struct elfhdr elf;
  struct dirent *ep;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  pagetable_t kpagetable = 0, oldkpagetable;
  struct proc *p = myproc();
    80203fba:	ffffe097          	auipc	ra,0xffffe
    80203fbe:	b14080e7          	jalr	-1260(ra) # 80201ace <myproc>
    80203fc2:	84aa                	mv	s1,a0

  // Make a copy of p->kpt without old user space, 
  // but with the same kstack we are using now, which can't be changed
  if ((kpagetable = (pagetable_t)kalloc()) == NULL) {
    80203fc4:	ffffc097          	auipc	ra,0xffffc
    80203fc8:	5c0080e7          	jalr	1472(ra) # 80200584 <kalloc>
    80203fcc:	3c050a63          	beqz	a0,802043a0 <exec+0x406>
    80203fd0:	ffce                	sd	s3,504(sp)
    80203fd2:	f3da                	sd	s6,480(sp)
    80203fd4:	8b2a                	mv	s6,a0
    return -1;
  }
  memmove(kpagetable, p->kpagetable, PGSIZE);
    80203fd6:	6605                	lui	a2,0x1
    80203fd8:	6cac                	ld	a1,88(s1)
    80203fda:	ffffd097          	auipc	ra,0xffffd
    80203fde:	80e080e7          	jalr	-2034(ra) # 802007e8 <memmove>
  for (int i = 0; i < PX(2, MAXUVA); i++) {
    kpagetable[i] = 0;
    80203fe2:	000b3023          	sd	zero,0(s6)
    80203fe6:	000b3423          	sd	zero,8(s6)
  }

  if((ep = ename(path)) == NULL) {
    80203fea:	854a                	mv	a0,s2
    80203fec:	00003097          	auipc	ra,0x3
    80203ff0:	c2a080e7          	jalr	-982(ra) # 80206c16 <ename>
    80203ff4:	89aa                	mv	s3,a0
    80203ff6:	3a050c63          	beqz	a0,802043ae <exec+0x414>
    #ifdef DEBUG
    printf("[exec] %s not found\n", path);
    #endif
    goto bad;
  }
  elock(ep);
    80203ffa:	00002097          	auipc	ra,0x2
    80203ffe:	3cc080e7          	jalr	972(ra) # 802063c6 <elock>

  // Check ELF header
  if(eread(ep, 0, (uint64) &elf, 0, sizeof(elf)) != sizeof(elf))
    80204002:	04000713          	li	a4,64
    80204006:	4681                	li	a3,0
    80204008:	e4840613          	addi	a2,s0,-440
    8020400c:	4581                	li	a1,0
    8020400e:	854e                	mv	a0,s3
    80204010:	00002097          	auipc	ra,0x2
    80204014:	aa0080e7          	jalr	-1376(ra) # 80205ab0 <eread>
    80204018:	04000793          	li	a5,64
    8020401c:	00f51a63          	bne	a0,a5,80204030 <exec+0x96>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80204020:	e4842703          	lw	a4,-440(s0)
    80204024:	464c47b7          	lui	a5,0x464c4
    80204028:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39d3ba81>
    8020402c:	00f70963          	beq	a4,a5,8020403e <exec+0xa4>
  printf("[exec] reach bad\n");
  #endif
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(kpagetable)
    kvmfree(kpagetable, 0);
    80204030:	4581                	li	a1,0
    80204032:	855a                	mv	a0,s6
    80204034:	ffffd097          	auipc	ra,0xffffd
    80204038:	6d0080e7          	jalr	1744(ra) # 80201704 <kvmfree>
  if(ep){
    8020403c:	ae29                	j	80204356 <exec+0x3bc>
    8020403e:	efde                	sd	s7,472(sp)
  if((pagetable = proc_pagetable(p)) == NULL)
    80204040:	8526                	mv	a0,s1
    80204042:	ffffe097          	auipc	ra,0xffffe
    80204046:	b70080e7          	jalr	-1168(ra) # 80201bb2 <proc_pagetable>
    8020404a:	8baa                	mv	s7,a0
    8020404c:	34050f63          	beqz	a0,802043aa <exec+0x410>
    80204050:	fbd2                	sd	s4,496(sp)
    80204052:	f7d6                	sd	s5,488(sp)
    80204054:	ebe2                	sd	s8,464(sp)
    80204056:	e7e6                	sd	s9,456(sp)
    80204058:	e3ea                	sd	s10,448(sp)
    8020405a:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8020405c:	e6842783          	lw	a5,-408(s0)
    80204060:	e8045703          	lhu	a4,-384(s0)
    80204064:	10070263          	beqz	a4,80204168 <exec+0x1ce>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80204068:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8020406a:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    8020406c:	6d05                	lui	s10,0x1
    8020406e:	fffd0713          	addi	a4,s10,-1 # fff <_entry-0x801ff001>
    80204072:	dee43423          	sd	a4,-536(s0)
    if(sz - i < PGSIZE)
    80204076:	6a85                	lui	s5,0x1
    80204078:	a885                	j	802040e8 <exec+0x14e>
      panic("loadseg: address should exist");
    8020407a:	00006517          	auipc	a0,0x6
    8020407e:	a7e50513          	addi	a0,a0,-1410 # 80209af8 <etext+0xaf8>
    80204082:	ffffc097          	auipc	ra,0xffffc
    80204086:	0c4080e7          	jalr	196(ra) # 80200146 <panic>
    if(sz - i < PGSIZE)
    8020408a:	2481                	sext.w	s1,s1
    if(eread(ep, 0, (uint64)pa, offset+i, n) != n)
    8020408c:	8726                	mv	a4,s1
    8020408e:	012c86bb          	addw	a3,s9,s2
    80204092:	4581                	li	a1,0
    80204094:	854e                	mv	a0,s3
    80204096:	00002097          	auipc	ra,0x2
    8020409a:	a1a080e7          	jalr	-1510(ra) # 80205ab0 <eread>
    8020409e:	2501                	sext.w	a0,a0
    802040a0:	28a49463          	bne	s1,a0,80204328 <exec+0x38e>
  for(i = 0; i < sz; i += PGSIZE){
    802040a4:	012a893b          	addw	s2,s5,s2
    802040a8:	03497563          	bgeu	s2,s4,802040d2 <exec+0x138>
    pa = walkaddr(pagetable, va + i);
    802040ac:	02091593          	slli	a1,s2,0x20
    802040b0:	9181                	srli	a1,a1,0x20
    802040b2:	95e2                	add	a1,a1,s8
    802040b4:	855e                	mv	a0,s7
    802040b6:	ffffd097          	auipc	ra,0xffffd
    802040ba:	b58080e7          	jalr	-1192(ra) # 80200c0e <walkaddr>
    802040be:	862a                	mv	a2,a0
    if(pa == NULL)
    802040c0:	dd4d                	beqz	a0,8020407a <exec+0xe0>
    if(sz - i < PGSIZE)
    802040c2:	412a04bb          	subw	s1,s4,s2
    802040c6:	0004879b          	sext.w	a5,s1
    802040ca:	fcfd70e3          	bgeu	s10,a5,8020408a <exec+0xf0>
    802040ce:	84d6                	mv	s1,s5
    802040d0:	bf6d                	j	8020408a <exec+0xf0>
    sz = sz1;
    802040d2:	e0043483          	ld	s1,-512(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    802040d6:	2d85                	addiw	s11,s11,1 # 1001 <_entry-0x801fefff>
    802040d8:	e0843783          	ld	a5,-504(s0)
    802040dc:	0387879b          	addiw	a5,a5,56
    802040e0:	e8045703          	lhu	a4,-384(s0)
    802040e4:	08edd363          	bge	s11,a4,8020416a <exec+0x1d0>
    if(eread(ep, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    802040e8:	2781                	sext.w	a5,a5
    802040ea:	e0f43423          	sd	a5,-504(s0)
    802040ee:	03800713          	li	a4,56
    802040f2:	86be                	mv	a3,a5
    802040f4:	e1040613          	addi	a2,s0,-496
    802040f8:	4581                	li	a1,0
    802040fa:	854e                	mv	a0,s3
    802040fc:	00002097          	auipc	ra,0x2
    80204100:	9b4080e7          	jalr	-1612(ra) # 80205ab0 <eread>
    80204104:	03800793          	li	a5,56
    80204108:	20f51e63          	bne	a0,a5,80204324 <exec+0x38a>
    if(ph.type != ELF_PROG_LOAD)
    8020410c:	e1042783          	lw	a5,-496(s0)
    80204110:	4705                	li	a4,1
    80204112:	fce792e3          	bne	a5,a4,802040d6 <exec+0x13c>
    if(ph.memsz < ph.filesz)
    80204116:	e3843683          	ld	a3,-456(s0)
    8020411a:	e3043783          	ld	a5,-464(s0)
    8020411e:	26f6e463          	bltu	a3,a5,80204386 <exec+0x3ec>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80204122:	e2043783          	ld	a5,-480(s0)
    80204126:	96be                	add	a3,a3,a5
    80204128:	26f6e263          	bltu	a3,a5,8020438c <exec+0x3f2>
    if((sz1 = uvmalloc(pagetable, kpagetable, sz, ph.vaddr + ph.memsz)) == 0)
    8020412c:	8626                	mv	a2,s1
    8020412e:	85da                	mv	a1,s6
    80204130:	855e                	mv	a0,s7
    80204132:	ffffd097          	auipc	ra,0xffffd
    80204136:	f4c080e7          	jalr	-180(ra) # 8020107e <uvmalloc>
    8020413a:	e0a43023          	sd	a0,-512(s0)
    8020413e:	24050a63          	beqz	a0,80204392 <exec+0x3f8>
    if(ph.vaddr % PGSIZE != 0)
    80204142:	e2043c03          	ld	s8,-480(s0)
    80204146:	de843783          	ld	a5,-536(s0)
    8020414a:	00fc77b3          	and	a5,s8,a5
    8020414e:	1c079d63          	bnez	a5,80204328 <exec+0x38e>
    if(loadseg(pagetable, ph.vaddr, ep, ph.off, ph.filesz) < 0)
    80204152:	e1842c83          	lw	s9,-488(s0)
    80204156:	e3042a03          	lw	s4,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8020415a:	000a0463          	beqz	s4,80204162 <exec+0x1c8>
    8020415e:	4901                	li	s2,0
    80204160:	b7b1                	j	802040ac <exec+0x112>
    sz = sz1;
    80204162:	e0043483          	ld	s1,-512(s0)
    80204166:	bf85                	j	802040d6 <exec+0x13c>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80204168:	4481                	li	s1,0
  eunlock(ep);
    8020416a:	854e                	mv	a0,s3
    8020416c:	00002097          	auipc	ra,0x2
    80204170:	290080e7          	jalr	656(ra) # 802063fc <eunlock>
  eput(ep);
    80204174:	854e                	mv	a0,s3
    80204176:	00002097          	auipc	ra,0x2
    8020417a:	2d4080e7          	jalr	724(ra) # 8020644a <eput>
  p = myproc();
    8020417e:	ffffe097          	auipc	ra,0xffffe
    80204182:	950080e7          	jalr	-1712(ra) # 80201ace <myproc>
    80204186:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80204188:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    8020418c:	6985                	lui	s3,0x1
    8020418e:	19fd                	addi	s3,s3,-1 # fff <_entry-0x801ff001>
    80204190:	99a6                	add	s3,s3,s1
    80204192:	77fd                	lui	a5,0xfffff
    80204194:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, kpagetable, sz, sz + 2*PGSIZE)) == 0)
    80204198:	6689                	lui	a3,0x2
    8020419a:	96ce                	add	a3,a3,s3
    8020419c:	864e                	mv	a2,s3
    8020419e:	85da                	mv	a1,s6
    802041a0:	855e                	mv	a0,s7
    802041a2:	ffffd097          	auipc	ra,0xffffd
    802041a6:	edc080e7          	jalr	-292(ra) # 8020107e <uvmalloc>
    802041aa:	892a                	mv	s2,a0
    802041ac:	e0a43023          	sd	a0,-512(s0)
    802041b0:	e509                	bnez	a0,802041ba <exec+0x220>
  if(pagetable)
    802041b2:	e1343023          	sd	s3,-512(s0)
    802041b6:	4981                	li	s3,0
    802041b8:	aa85                	j	80204328 <exec+0x38e>
  uvmclear(pagetable, sz-2*PGSIZE);
    802041ba:	75f9                	lui	a1,0xffffe
    802041bc:	95aa                	add	a1,a1,a0
    802041be:	855e                	mv	a0,s7
    802041c0:	ffffd097          	auipc	ra,0xffffd
    802041c4:	17a080e7          	jalr	378(ra) # 8020133a <uvmclear>
  stackbase = sp - PGSIZE;
    802041c8:	7c7d                	lui	s8,0xfffff
    802041ca:	9c4a                	add	s8,s8,s2
  for(argc = 0; argv[argc]; argc++) {
    802041cc:	df843783          	ld	a5,-520(s0)
    802041d0:	6388                	ld	a0,0(a5)
    802041d2:	c52d                	beqz	a0,8020423c <exec+0x2a2>
    802041d4:	e8840993          	addi	s3,s0,-376
    802041d8:	f8840c93          	addi	s9,s0,-120
    802041dc:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    802041de:	ffffc097          	auipc	ra,0xffffc
    802041e2:	72a080e7          	jalr	1834(ra) # 80200908 <strlen>
    802041e6:	0015079b          	addiw	a5,a0,1
    802041ea:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    802041ee:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    802041f2:	1b896363          	bltu	s2,s8,80204398 <exec+0x3fe>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    802041f6:	df843d83          	ld	s11,-520(s0)
    802041fa:	000dba03          	ld	s4,0(s11)
    802041fe:	8552                	mv	a0,s4
    80204200:	ffffc097          	auipc	ra,0xffffc
    80204204:	708080e7          	jalr	1800(ra) # 80200908 <strlen>
    80204208:	0015069b          	addiw	a3,a0,1
    8020420c:	8652                	mv	a2,s4
    8020420e:	85ca                	mv	a1,s2
    80204210:	855e                	mv	a0,s7
    80204212:	ffffd097          	auipc	ra,0xffffd
    80204216:	15a080e7          	jalr	346(ra) # 8020136c <copyout>
    8020421a:	18054163          	bltz	a0,8020439c <exec+0x402>
    ustack[argc] = sp;
    8020421e:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80204222:	0485                	addi	s1,s1,1
    80204224:	008d8793          	addi	a5,s11,8
    80204228:	def43c23          	sd	a5,-520(s0)
    8020422c:	008db503          	ld	a0,8(s11)
    80204230:	c909                	beqz	a0,80204242 <exec+0x2a8>
    if(argc >= MAXARG)
    80204232:	09a1                	addi	s3,s3,8
    80204234:	fb9995e3          	bne	s3,s9,802041de <exec+0x244>
  ep = 0;
    80204238:	4981                	li	s3,0
    8020423a:	a0fd                	j	80204328 <exec+0x38e>
  sp = sz;
    8020423c:	e0043903          	ld	s2,-512(s0)
  for(argc = 0; argv[argc]; argc++) {
    80204240:	4481                	li	s1,0
  ustack[argc] = 0;
    80204242:	00349793          	slli	a5,s1,0x3
    80204246:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <ebss_clear+0xffffffff7fdd9f90>
    8020424a:	97a2                	add	a5,a5,s0
    8020424c:	ee07bc23          	sd	zero,-264(a5)
  sp -= (argc+1) * sizeof(uint64);
    80204250:	00148693          	addi	a3,s1,1
    80204254:	068e                	slli	a3,a3,0x3
    80204256:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8020425a:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    8020425e:	e0043983          	ld	s3,-512(s0)
  if(sp < stackbase)
    80204262:	f58968e3          	bltu	s2,s8,802041b2 <exec+0x218>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80204266:	e8840613          	addi	a2,s0,-376
    8020426a:	85ca                	mv	a1,s2
    8020426c:	855e                	mv	a0,s7
    8020426e:	ffffd097          	auipc	ra,0xffffd
    80204272:	0fe080e7          	jalr	254(ra) # 8020136c <copyout>
    80204276:	12054763          	bltz	a0,802043a4 <exec+0x40a>
  p->trapframe->a1 = sp;
    8020427a:	060ab783          	ld	a5,96(s5) # 1060 <_entry-0x801fefa0>
    8020427e:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80204282:	df043783          	ld	a5,-528(s0)
    80204286:	0007c703          	lbu	a4,0(a5)
    8020428a:	cf11                	beqz	a4,802042a6 <exec+0x30c>
    8020428c:	0785                	addi	a5,a5,1
    if(*s == '/')
    8020428e:	02f00693          	li	a3,47
    80204292:	a039                	j	802042a0 <exec+0x306>
      last = s+1;
    80204294:	def43823          	sd	a5,-528(s0)
  for(last=s=path; *s; s++)
    80204298:	0785                	addi	a5,a5,1
    8020429a:	fff7c703          	lbu	a4,-1(a5)
    8020429e:	c701                	beqz	a4,802042a6 <exec+0x30c>
    if(*s == '/')
    802042a0:	fed71ce3          	bne	a4,a3,80204298 <exec+0x2fe>
    802042a4:	bfc5                	j	80204294 <exec+0x2fa>
  safestrcpy(p->name, last, sizeof(p->name));
    802042a6:	4641                	li	a2,16
    802042a8:	df043583          	ld	a1,-528(s0)
    802042ac:	160a8513          	addi	a0,s5,352
    802042b0:	ffffc097          	auipc	ra,0xffffc
    802042b4:	626080e7          	jalr	1574(ra) # 802008d6 <safestrcpy>
  oldpagetable = p->pagetable;
    802042b8:	050ab503          	ld	a0,80(s5)
  oldkpagetable = p->kpagetable;
    802042bc:	058ab983          	ld	s3,88(s5)
  p->pagetable = pagetable;
    802042c0:	057ab823          	sd	s7,80(s5)
  p->kpagetable = kpagetable;
    802042c4:	056abc23          	sd	s6,88(s5)
  p->sz = sz;
    802042c8:	e0043783          	ld	a5,-512(s0)
    802042cc:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    802042d0:	060ab783          	ld	a5,96(s5)
    802042d4:	e6043703          	ld	a4,-416(s0)
    802042d8:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    802042da:	060ab783          	ld	a5,96(s5)
    802042de:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    802042e2:	85ea                	mv	a1,s10
    802042e4:	ffffe097          	auipc	ra,0xffffe
    802042e8:	96a080e7          	jalr	-1686(ra) # 80201c4e <proc_freepagetable>
  w_satp(MAKE_SATP(p->kpagetable));
    802042ec:	058ab783          	ld	a5,88(s5)
    802042f0:	83b1                	srli	a5,a5,0xc
    802042f2:	577d                	li	a4,-1
    802042f4:	177e                	slli	a4,a4,0x3f
    802042f6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    802042f8:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma");
    802042fc:	12000073          	sfence.vma
  kvmfree(oldkpagetable, 0);
    80204300:	4581                	li	a1,0
    80204302:	854e                	mv	a0,s3
    80204304:	ffffd097          	auipc	ra,0xffffd
    80204308:	400080e7          	jalr	1024(ra) # 80201704 <kvmfree>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8020430c:	0004851b          	sext.w	a0,s1
    80204310:	79fe                	ld	s3,504(sp)
    80204312:	7a5e                	ld	s4,496(sp)
    80204314:	7abe                	ld	s5,488(sp)
    80204316:	7b1e                	ld	s6,480(sp)
    80204318:	6bfe                	ld	s7,472(sp)
    8020431a:	6c5e                	ld	s8,464(sp)
    8020431c:	6cbe                	ld	s9,456(sp)
    8020431e:	6d1e                	ld	s10,448(sp)
    80204320:	7dfa                	ld	s11,440(sp)
    80204322:	a0b9                	j	80204370 <exec+0x3d6>
    80204324:	e0943023          	sd	s1,-512(s0)
    proc_freepagetable(pagetable, sz);
    80204328:	e0043583          	ld	a1,-512(s0)
    8020432c:	855e                	mv	a0,s7
    8020432e:	ffffe097          	auipc	ra,0xffffe
    80204332:	920080e7          	jalr	-1760(ra) # 80201c4e <proc_freepagetable>
    kvmfree(kpagetable, 0);
    80204336:	4581                	li	a1,0
    80204338:	855a                	mv	a0,s6
    8020433a:	ffffd097          	auipc	ra,0xffffd
    8020433e:	3ca080e7          	jalr	970(ra) # 80201704 <kvmfree>
    eunlock(ep);
    eput(ep);
  }
  return -1;
    80204342:	557d                	li	a0,-1
  if(ep){
    80204344:	06098f63          	beqz	s3,802043c2 <exec+0x428>
    80204348:	7a5e                	ld	s4,496(sp)
    8020434a:	7abe                	ld	s5,488(sp)
    8020434c:	6bfe                	ld	s7,472(sp)
    8020434e:	6c5e                	ld	s8,464(sp)
    80204350:	6cbe                	ld	s9,456(sp)
    80204352:	6d1e                	ld	s10,448(sp)
    80204354:	7dfa                	ld	s11,440(sp)
    eunlock(ep);
    80204356:	854e                	mv	a0,s3
    80204358:	00002097          	auipc	ra,0x2
    8020435c:	0a4080e7          	jalr	164(ra) # 802063fc <eunlock>
    eput(ep);
    80204360:	854e                	mv	a0,s3
    80204362:	00002097          	auipc	ra,0x2
    80204366:	0e8080e7          	jalr	232(ra) # 8020644a <eput>
  return -1;
    8020436a:	557d                	li	a0,-1
    8020436c:	79fe                	ld	s3,504(sp)
    8020436e:	7b1e                	ld	s6,480(sp)
}
    80204370:	21813083          	ld	ra,536(sp)
    80204374:	21013403          	ld	s0,528(sp)
    80204378:	20813483          	ld	s1,520(sp)
    8020437c:	20013903          	ld	s2,512(sp)
    80204380:	22010113          	addi	sp,sp,544
    80204384:	8082                	ret
    80204386:	e0943023          	sd	s1,-512(s0)
    8020438a:	bf79                	j	80204328 <exec+0x38e>
    8020438c:	e0943023          	sd	s1,-512(s0)
    80204390:	bf61                	j	80204328 <exec+0x38e>
    80204392:	e0943023          	sd	s1,-512(s0)
    80204396:	bf49                	j	80204328 <exec+0x38e>
  ep = 0;
    80204398:	4981                	li	s3,0
    8020439a:	b779                	j	80204328 <exec+0x38e>
    8020439c:	4981                	li	s3,0
  if(pagetable)
    8020439e:	b769                	j	80204328 <exec+0x38e>
    return -1;
    802043a0:	557d                	li	a0,-1
    802043a2:	b7f9                	j	80204370 <exec+0x3d6>
  sz = sz1;
    802043a4:	e0043983          	ld	s3,-512(s0)
    802043a8:	b529                	j	802041b2 <exec+0x218>
    802043aa:	6bfe                	ld	s7,472(sp)
    802043ac:	b151                	j	80204030 <exec+0x96>
    kvmfree(kpagetable, 0);
    802043ae:	4581                	li	a1,0
    802043b0:	855a                	mv	a0,s6
    802043b2:	ffffd097          	auipc	ra,0xffffd
    802043b6:	352080e7          	jalr	850(ra) # 80201704 <kvmfree>
  return -1;
    802043ba:	557d                	li	a0,-1
    802043bc:	79fe                	ld	s3,504(sp)
    802043be:	7b1e                	ld	s6,480(sp)
    802043c0:	bf45                	j	80204370 <exec+0x3d6>
    802043c2:	79fe                	ld	s3,504(sp)
    802043c4:	7a5e                	ld	s4,496(sp)
    802043c6:	7abe                	ld	s5,488(sp)
    802043c8:	7b1e                	ld	s6,480(sp)
    802043ca:	6bfe                	ld	s7,472(sp)
    802043cc:	6c5e                	ld	s8,464(sp)
    802043ce:	6cbe                	ld	s9,456(sp)
    802043d0:	6d1e                	ld	s10,448(sp)
    802043d2:	7dfa                	ld	s11,440(sp)
    802043d4:	bf71                	j	80204370 <exec+0x3d6>

00000000802043d6 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    802043d6:	7179                	addi	sp,sp,-48
    802043d8:	f406                	sd	ra,40(sp)
    802043da:	f022                	sd	s0,32(sp)
    802043dc:	ec26                	sd	s1,24(sp)
    802043de:	e84a                	sd	s2,16(sp)
    802043e0:	1800                	addi	s0,sp,48
    802043e2:	892e                	mv	s2,a1
    802043e4:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    802043e6:	fdc40593          	addi	a1,s0,-36
    802043ea:	fffff097          	auipc	ra,0xfffff
    802043ee:	a98080e7          	jalr	-1384(ra) # 80202e82 <argint>
    802043f2:	04054063          	bltz	a0,80204432 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == NULL)
    802043f6:	fdc42703          	lw	a4,-36(s0)
    802043fa:	47bd                	li	a5,15
    802043fc:	02e7ed63          	bltu	a5,a4,80204436 <argfd+0x60>
    80204400:	ffffd097          	auipc	ra,0xffffd
    80204404:	6ce080e7          	jalr	1742(ra) # 80201ace <myproc>
    80204408:	fdc42703          	lw	a4,-36(s0)
    8020440c:	01a70793          	addi	a5,a4,26
    80204410:	078e                	slli	a5,a5,0x3
    80204412:	953e                	add	a0,a0,a5
    80204414:	651c                	ld	a5,8(a0)
    80204416:	c395                	beqz	a5,8020443a <argfd+0x64>
    return -1;
  if(pfd)
    80204418:	00090463          	beqz	s2,80204420 <argfd+0x4a>
    *pfd = fd;
    8020441c:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80204420:	4501                	li	a0,0
  if(pf)
    80204422:	c091                	beqz	s1,80204426 <argfd+0x50>
    *pf = f;
    80204424:	e09c                	sd	a5,0(s1)
}
    80204426:	70a2                	ld	ra,40(sp)
    80204428:	7402                	ld	s0,32(sp)
    8020442a:	64e2                	ld	s1,24(sp)
    8020442c:	6942                	ld	s2,16(sp)
    8020442e:	6145                	addi	sp,sp,48
    80204430:	8082                	ret
    return -1;
    80204432:	557d                	li	a0,-1
    80204434:	bfcd                	j	80204426 <argfd+0x50>
    return -1;
    80204436:	557d                	li	a0,-1
    80204438:	b7fd                	j	80204426 <argfd+0x50>
    8020443a:	557d                	li	a0,-1
    8020443c:	b7ed                	j	80204426 <argfd+0x50>

000000008020443e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8020443e:	1101                	addi	sp,sp,-32
    80204440:	ec06                	sd	ra,24(sp)
    80204442:	e822                	sd	s0,16(sp)
    80204444:	e426                	sd	s1,8(sp)
    80204446:	1000                	addi	s0,sp,32
    80204448:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8020444a:	ffffd097          	auipc	ra,0xffffd
    8020444e:	684080e7          	jalr	1668(ra) # 80201ace <myproc>
    80204452:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80204454:	0d850793          	addi	a5,a0,216
    80204458:	4501                	li	a0,0
    8020445a:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8020445c:	6398                	ld	a4,0(a5)
    8020445e:	cb19                	beqz	a4,80204474 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80204460:	2505                	addiw	a0,a0,1
    80204462:	07a1                	addi	a5,a5,8
    80204464:	fed51ce3          	bne	a0,a3,8020445c <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80204468:	557d                	li	a0,-1
}
    8020446a:	60e2                	ld	ra,24(sp)
    8020446c:	6442                	ld	s0,16(sp)
    8020446e:	64a2                	ld	s1,8(sp)
    80204470:	6105                	addi	sp,sp,32
    80204472:	8082                	ret
      p->ofile[fd] = f;
    80204474:	01a50793          	addi	a5,a0,26
    80204478:	078e                	slli	a5,a5,0x3
    8020447a:	963e                	add	a2,a2,a5
    8020447c:	e604                	sd	s1,8(a2)
      return fd;
    8020447e:	b7f5                	j	8020446a <fdalloc+0x2c>

0000000080204480 <create>:
  return filestat(f, st);
}

static struct dirent*
create(char *path, short type, int mode)
{
    80204480:	7169                	addi	sp,sp,-304
    80204482:	f606                	sd	ra,296(sp)
    80204484:	f222                	sd	s0,288(sp)
    80204486:	ee26                	sd	s1,280(sp)
    80204488:	ea4a                	sd	s2,272(sp)
    8020448a:	e64e                	sd	s3,264(sp)
    8020448c:	1a00                	addi	s0,sp,304
    8020448e:	89ae                	mv	s3,a1
  struct dirent *ep, *dp;
  char name[FAT32_MAX_FILENAME + 1];

  if((dp = enameparent(path, name)) == NULL)
    80204490:	ed040593          	addi	a1,s0,-304
    80204494:	00002097          	auipc	ra,0x2
    80204498:	7a0080e7          	jalr	1952(ra) # 80206c34 <enameparent>
    8020449c:	84aa                	mv	s1,a0
    8020449e:	c545                	beqz	a0,80204546 <create+0xc6>
    mode = ATTR_READ_ONLY;
  } else {
    mode = 0;  
  }

  elock(dp);
    802044a0:	00002097          	auipc	ra,0x2
    802044a4:	f26080e7          	jalr	-218(ra) # 802063c6 <elock>
  if (type == T_DIR) {
    802044a8:	fff98613          	addi	a2,s3,-1
    802044ac:	00163613          	seqz	a2,a2
  if ((ep = ealloc(dp, name, mode)) == NULL) {
    802044b0:	0612                	slli	a2,a2,0x4
    802044b2:	ed040593          	addi	a1,s0,-304
    802044b6:	8526                	mv	a0,s1
    802044b8:	00002097          	auipc	ra,0x2
    802044bc:	46a080e7          	jalr	1130(ra) # 80206922 <ealloc>
    802044c0:	892a                	mv	s2,a0
    802044c2:	c131                	beqz	a0,80204506 <create+0x86>
    eunlock(dp);
    eput(dp);
    return NULL;
  }
  
  if ((type == T_DIR && !(ep->attribute & ATTR_DIRECTORY)) ||
    802044c4:	4785                	li	a5,1
    802044c6:	04f98b63          	beq	s3,a5,8020451c <create+0x9c>
    802044ca:	4789                	li	a5,2
    802044cc:	00f99663          	bne	s3,a5,802044d8 <create+0x58>
      (type == T_FILE && (ep->attribute & ATTR_DIRECTORY))) {
    802044d0:	10054783          	lbu	a5,256(a0)
    802044d4:	8bc1                	andi	a5,a5,16
    802044d6:	e7b9                	bnez	a5,80204524 <create+0xa4>
    eput(ep);
    eput(dp);
    return NULL;
  }

  eunlock(dp);
    802044d8:	8526                	mv	a0,s1
    802044da:	00002097          	auipc	ra,0x2
    802044de:	f22080e7          	jalr	-222(ra) # 802063fc <eunlock>
  eput(dp);
    802044e2:	8526                	mv	a0,s1
    802044e4:	00002097          	auipc	ra,0x2
    802044e8:	f66080e7          	jalr	-154(ra) # 8020644a <eput>

  elock(ep);
    802044ec:	854a                	mv	a0,s2
    802044ee:	00002097          	auipc	ra,0x2
    802044f2:	ed8080e7          	jalr	-296(ra) # 802063c6 <elock>
  return ep;
}
    802044f6:	854a                	mv	a0,s2
    802044f8:	70b2                	ld	ra,296(sp)
    802044fa:	7412                	ld	s0,288(sp)
    802044fc:	64f2                	ld	s1,280(sp)
    802044fe:	6952                	ld	s2,272(sp)
    80204500:	69b2                	ld	s3,264(sp)
    80204502:	6155                	addi	sp,sp,304
    80204504:	8082                	ret
    eunlock(dp);
    80204506:	8526                	mv	a0,s1
    80204508:	00002097          	auipc	ra,0x2
    8020450c:	ef4080e7          	jalr	-268(ra) # 802063fc <eunlock>
    eput(dp);
    80204510:	8526                	mv	a0,s1
    80204512:	00002097          	auipc	ra,0x2
    80204516:	f38080e7          	jalr	-200(ra) # 8020644a <eput>
    return NULL;
    8020451a:	bff1                	j	802044f6 <create+0x76>
  if ((type == T_DIR && !(ep->attribute & ATTR_DIRECTORY)) ||
    8020451c:	10054783          	lbu	a5,256(a0)
    80204520:	8bc1                	andi	a5,a5,16
    80204522:	fbdd                	bnez	a5,802044d8 <create+0x58>
    eunlock(dp);
    80204524:	8526                	mv	a0,s1
    80204526:	00002097          	auipc	ra,0x2
    8020452a:	ed6080e7          	jalr	-298(ra) # 802063fc <eunlock>
    eput(ep);
    8020452e:	854a                	mv	a0,s2
    80204530:	00002097          	auipc	ra,0x2
    80204534:	f1a080e7          	jalr	-230(ra) # 8020644a <eput>
    eput(dp);
    80204538:	8526                	mv	a0,s1
    8020453a:	00002097          	auipc	ra,0x2
    8020453e:	f10080e7          	jalr	-240(ra) # 8020644a <eput>
    return NULL;
    80204542:	4901                	li	s2,0
    80204544:	bf4d                	j	802044f6 <create+0x76>
    return NULL;
    80204546:	892a                	mv	s2,a0
    80204548:	b77d                	j	802044f6 <create+0x76>

000000008020454a <sys_dup>:
{
    8020454a:	7179                	addi	sp,sp,-48
    8020454c:	f406                	sd	ra,40(sp)
    8020454e:	f022                	sd	s0,32(sp)
    80204550:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80204552:	fd840613          	addi	a2,s0,-40
    80204556:	4581                	li	a1,0
    80204558:	4501                	li	a0,0
    8020455a:	00000097          	auipc	ra,0x0
    8020455e:	e7c080e7          	jalr	-388(ra) # 802043d6 <argfd>
    return -1;
    80204562:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80204564:	02054763          	bltz	a0,80204592 <sys_dup+0x48>
    80204568:	ec26                	sd	s1,24(sp)
    8020456a:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    8020456c:	fd843903          	ld	s2,-40(s0)
    80204570:	854a                	mv	a0,s2
    80204572:	00000097          	auipc	ra,0x0
    80204576:	ecc080e7          	jalr	-308(ra) # 8020443e <fdalloc>
    8020457a:	84aa                	mv	s1,a0
    return -1;
    8020457c:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8020457e:	00054f63          	bltz	a0,8020459c <sys_dup+0x52>
  filedup(f);
    80204582:	854a                	mv	a0,s2
    80204584:	fffff097          	auipc	ra,0xfffff
    80204588:	2bc080e7          	jalr	700(ra) # 80203840 <filedup>
  return fd;
    8020458c:	87a6                	mv	a5,s1
    8020458e:	64e2                	ld	s1,24(sp)
    80204590:	6942                	ld	s2,16(sp)
}
    80204592:	853e                	mv	a0,a5
    80204594:	70a2                	ld	ra,40(sp)
    80204596:	7402                	ld	s0,32(sp)
    80204598:	6145                	addi	sp,sp,48
    8020459a:	8082                	ret
    8020459c:	64e2                	ld	s1,24(sp)
    8020459e:	6942                	ld	s2,16(sp)
    802045a0:	bfcd                	j	80204592 <sys_dup+0x48>

00000000802045a2 <sys_read>:
{
    802045a2:	7179                	addi	sp,sp,-48
    802045a4:	f406                	sd	ra,40(sp)
    802045a6:	f022                	sd	s0,32(sp)
    802045a8:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    802045aa:	fe840613          	addi	a2,s0,-24
    802045ae:	4581                	li	a1,0
    802045b0:	4501                	li	a0,0
    802045b2:	00000097          	auipc	ra,0x0
    802045b6:	e24080e7          	jalr	-476(ra) # 802043d6 <argfd>
    return -1;
    802045ba:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    802045bc:	04054163          	bltz	a0,802045fe <sys_read+0x5c>
    802045c0:	fe440593          	addi	a1,s0,-28
    802045c4:	4509                	li	a0,2
    802045c6:	fffff097          	auipc	ra,0xfffff
    802045ca:	8bc080e7          	jalr	-1860(ra) # 80202e82 <argint>
    return -1;
    802045ce:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    802045d0:	02054763          	bltz	a0,802045fe <sys_read+0x5c>
    802045d4:	fd840593          	addi	a1,s0,-40
    802045d8:	4505                	li	a0,1
    802045da:	fffff097          	auipc	ra,0xfffff
    802045de:	90a080e7          	jalr	-1782(ra) # 80202ee4 <argaddr>
    return -1;
    802045e2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    802045e4:	00054d63          	bltz	a0,802045fe <sys_read+0x5c>
  return fileread(f, p, n);
    802045e8:	fe442603          	lw	a2,-28(s0)
    802045ec:	fd843583          	ld	a1,-40(s0)
    802045f0:	fe843503          	ld	a0,-24(s0)
    802045f4:	fffff097          	auipc	ra,0xfffff
    802045f8:	3ce080e7          	jalr	974(ra) # 802039c2 <fileread>
    802045fc:	87aa                	mv	a5,a0
}
    802045fe:	853e                	mv	a0,a5
    80204600:	70a2                	ld	ra,40(sp)
    80204602:	7402                	ld	s0,32(sp)
    80204604:	6145                	addi	sp,sp,48
    80204606:	8082                	ret

0000000080204608 <sys_write>:
{
    80204608:	7179                	addi	sp,sp,-48
    8020460a:	f406                	sd	ra,40(sp)
    8020460c:	f022                	sd	s0,32(sp)
    8020460e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80204610:	fe840613          	addi	a2,s0,-24
    80204614:	4581                	li	a1,0
    80204616:	4501                	li	a0,0
    80204618:	00000097          	auipc	ra,0x0
    8020461c:	dbe080e7          	jalr	-578(ra) # 802043d6 <argfd>
    return -1;
    80204620:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80204622:	04054163          	bltz	a0,80204664 <sys_write+0x5c>
    80204626:	fe440593          	addi	a1,s0,-28
    8020462a:	4509                	li	a0,2
    8020462c:	fffff097          	auipc	ra,0xfffff
    80204630:	856080e7          	jalr	-1962(ra) # 80202e82 <argint>
    return -1;
    80204634:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80204636:	02054763          	bltz	a0,80204664 <sys_write+0x5c>
    8020463a:	fd840593          	addi	a1,s0,-40
    8020463e:	4505                	li	a0,1
    80204640:	fffff097          	auipc	ra,0xfffff
    80204644:	8a4080e7          	jalr	-1884(ra) # 80202ee4 <argaddr>
    return -1;
    80204648:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8020464a:	00054d63          	bltz	a0,80204664 <sys_write+0x5c>
  return filewrite(f, p, n);
    8020464e:	fe442603          	lw	a2,-28(s0)
    80204652:	fd843583          	ld	a1,-40(s0)
    80204656:	fe843503          	ld	a0,-24(s0)
    8020465a:	fffff097          	auipc	ra,0xfffff
    8020465e:	43a080e7          	jalr	1082(ra) # 80203a94 <filewrite>
    80204662:	87aa                	mv	a5,a0
}
    80204664:	853e                	mv	a0,a5
    80204666:	70a2                	ld	ra,40(sp)
    80204668:	7402                	ld	s0,32(sp)
    8020466a:	6145                	addi	sp,sp,48
    8020466c:	8082                	ret

000000008020466e <sys_close>:
{
    8020466e:	1101                	addi	sp,sp,-32
    80204670:	ec06                	sd	ra,24(sp)
    80204672:	e822                	sd	s0,16(sp)
    80204674:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80204676:	fe040613          	addi	a2,s0,-32
    8020467a:	fec40593          	addi	a1,s0,-20
    8020467e:	4501                	li	a0,0
    80204680:	00000097          	auipc	ra,0x0
    80204684:	d56080e7          	jalr	-682(ra) # 802043d6 <argfd>
    return -1;
    80204688:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8020468a:	02054463          	bltz	a0,802046b2 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8020468e:	ffffd097          	auipc	ra,0xffffd
    80204692:	440080e7          	jalr	1088(ra) # 80201ace <myproc>
    80204696:	fec42783          	lw	a5,-20(s0)
    8020469a:	07e9                	addi	a5,a5,26
    8020469c:	078e                	slli	a5,a5,0x3
    8020469e:	953e                	add	a0,a0,a5
    802046a0:	00053423          	sd	zero,8(a0)
  fileclose(f);
    802046a4:	fe043503          	ld	a0,-32(s0)
    802046a8:	fffff097          	auipc	ra,0xfffff
    802046ac:	1ea080e7          	jalr	490(ra) # 80203892 <fileclose>
  return 0;
    802046b0:	4781                	li	a5,0
}
    802046b2:	853e                	mv	a0,a5
    802046b4:	60e2                	ld	ra,24(sp)
    802046b6:	6442                	ld	s0,16(sp)
    802046b8:	6105                	addi	sp,sp,32
    802046ba:	8082                	ret

00000000802046bc <sys_fstat>:
{
    802046bc:	1101                	addi	sp,sp,-32
    802046be:	ec06                	sd	ra,24(sp)
    802046c0:	e822                	sd	s0,16(sp)
    802046c2:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    802046c4:	fe840613          	addi	a2,s0,-24
    802046c8:	4581                	li	a1,0
    802046ca:	4501                	li	a0,0
    802046cc:	00000097          	auipc	ra,0x0
    802046d0:	d0a080e7          	jalr	-758(ra) # 802043d6 <argfd>
    return -1;
    802046d4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    802046d6:	02054563          	bltz	a0,80204700 <sys_fstat+0x44>
    802046da:	fe040593          	addi	a1,s0,-32
    802046de:	4505                	li	a0,1
    802046e0:	fffff097          	auipc	ra,0xfffff
    802046e4:	804080e7          	jalr	-2044(ra) # 80202ee4 <argaddr>
    return -1;
    802046e8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    802046ea:	00054b63          	bltz	a0,80204700 <sys_fstat+0x44>
  return filestat(f, st);
    802046ee:	fe043583          	ld	a1,-32(s0)
    802046f2:	fe843503          	ld	a0,-24(s0)
    802046f6:	fffff097          	auipc	ra,0xfffff
    802046fa:	26c080e7          	jalr	620(ra) # 80203962 <filestat>
    802046fe:	87aa                	mv	a5,a0
}
    80204700:	853e                	mv	a0,a5
    80204702:	60e2                	ld	ra,24(sp)
    80204704:	6442                	ld	s0,16(sp)
    80204706:	6105                	addi	sp,sp,32
    80204708:	8082                	ret

000000008020470a <sys_open>:

uint64
sys_open(void)
{
    8020470a:	7129                	addi	sp,sp,-320
    8020470c:	fe06                	sd	ra,312(sp)
    8020470e:	fa22                	sd	s0,304(sp)
    80204710:	0280                	addi	s0,sp,320
  char path[FAT32_MAX_PATH];
  int fd, omode;
  struct file *f;
  struct dirent *ep;

  if(argstr(0, path, FAT32_MAX_PATH) < 0 || argint(1, &omode) < 0)
    80204712:	10400613          	li	a2,260
    80204716:	ec840593          	addi	a1,s0,-312
    8020471a:	4501                	li	a0,0
    8020471c:	ffffe097          	auipc	ra,0xffffe
    80204720:	7ea080e7          	jalr	2026(ra) # 80202f06 <argstr>
    80204724:	87aa                	mv	a5,a0
    return -1;
    80204726:	557d                	li	a0,-1
  if(argstr(0, path, FAT32_MAX_PATH) < 0 || argint(1, &omode) < 0)
    80204728:	0a07c463          	bltz	a5,802047d0 <sys_open+0xc6>
    8020472c:	ec440593          	addi	a1,s0,-316
    80204730:	4505                	li	a0,1
    80204732:	ffffe097          	auipc	ra,0xffffe
    80204736:	750080e7          	jalr	1872(ra) # 80202e82 <argint>
    8020473a:	10054963          	bltz	a0,8020484c <sys_open+0x142>
    8020473e:	f24a                	sd	s2,288(sp)

  if(omode & O_CREATE){
    80204740:	ec442603          	lw	a2,-316(s0)
    80204744:	20067793          	andi	a5,a2,512
    80204748:	cbc1                	beqz	a5,802047d8 <sys_open+0xce>
    ep = create(path, T_FILE, omode);
    8020474a:	4589                	li	a1,2
    8020474c:	ec840513          	addi	a0,s0,-312
    80204750:	00000097          	auipc	ra,0x0
    80204754:	d30080e7          	jalr	-720(ra) # 80204480 <create>
    80204758:	892a                	mv	s2,a0
    if(ep == NULL){
    8020475a:	c97d                	beqz	a0,80204850 <sys_open+0x146>
    8020475c:	ee4e                	sd	s3,280(sp)
      eput(ep);
      return -1;
    }
  }

  if((f = filealloc()) == NULL || (fd = fdalloc(f)) < 0){
    8020475e:	fffff097          	auipc	ra,0xfffff
    80204762:	078080e7          	jalr	120(ra) # 802037d6 <filealloc>
    80204766:	89aa                	mv	s3,a0
    80204768:	cd55                	beqz	a0,80204824 <sys_open+0x11a>
    8020476a:	f626                	sd	s1,296(sp)
    8020476c:	00000097          	auipc	ra,0x0
    80204770:	cd2080e7          	jalr	-814(ra) # 8020443e <fdalloc>
    80204774:	84aa                	mv	s1,a0
    80204776:	0a054163          	bltz	a0,80204818 <sys_open+0x10e>
    eunlock(ep);
    eput(ep);
    return -1;
  }

  if(!(ep->attribute & ATTR_DIRECTORY) && (omode & O_TRUNC)){
    8020477a:	10094783          	lbu	a5,256(s2)
    8020477e:	8bc1                	andi	a5,a5,16
    80204780:	e791                	bnez	a5,8020478c <sys_open+0x82>
    80204782:	ec442783          	lw	a5,-316(s0)
    80204786:	4007f793          	andi	a5,a5,1024
    8020478a:	ebdd                	bnez	a5,80204840 <sys_open+0x136>
    etrunc(ep);
  }

  f->type = FD_ENTRY;
    8020478c:	4789                	li	a5,2
    8020478e:	00f9a023          	sw	a5,0(s3)
  f->off = (omode & O_APPEND) ? ep->file_size : 0;
    80204792:	ec442783          	lw	a5,-316(s0)
    80204796:	0047f693          	andi	a3,a5,4
    8020479a:	4701                	li	a4,0
    8020479c:	c299                	beqz	a3,802047a2 <sys_open+0x98>
    8020479e:	10892703          	lw	a4,264(s2)
    802047a2:	02e9a023          	sw	a4,32(s3)
  f->ep = ep;
    802047a6:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    802047aa:	0017c713          	xori	a4,a5,1
    802047ae:	8b05                	andi	a4,a4,1
    802047b0:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    802047b4:	8b8d                	andi	a5,a5,3
    802047b6:	00f037b3          	snez	a5,a5
    802047ba:	00f984a3          	sb	a5,9(s3)

  eunlock(ep);
    802047be:	854a                	mv	a0,s2
    802047c0:	00002097          	auipc	ra,0x2
    802047c4:	c3c080e7          	jalr	-964(ra) # 802063fc <eunlock>

  return fd;
    802047c8:	8526                	mv	a0,s1
    802047ca:	74b2                	ld	s1,296(sp)
    802047cc:	7912                	ld	s2,288(sp)
    802047ce:	69f2                	ld	s3,280(sp)
}
    802047d0:	70f2                	ld	ra,312(sp)
    802047d2:	7452                	ld	s0,304(sp)
    802047d4:	6131                	addi	sp,sp,320
    802047d6:	8082                	ret
    if((ep = ename(path)) == NULL){
    802047d8:	ec840513          	addi	a0,s0,-312
    802047dc:	00002097          	auipc	ra,0x2
    802047e0:	43a080e7          	jalr	1082(ra) # 80206c16 <ename>
    802047e4:	892a                	mv	s2,a0
    802047e6:	c925                	beqz	a0,80204856 <sys_open+0x14c>
    elock(ep);
    802047e8:	00002097          	auipc	ra,0x2
    802047ec:	bde080e7          	jalr	-1058(ra) # 802063c6 <elock>
    if((ep->attribute & ATTR_DIRECTORY) && omode != O_RDONLY){
    802047f0:	10094783          	lbu	a5,256(s2)
    802047f4:	8bc1                	andi	a5,a5,16
    802047f6:	d3bd                	beqz	a5,8020475c <sys_open+0x52>
    802047f8:	ec442783          	lw	a5,-316(s0)
    802047fc:	d3a5                	beqz	a5,8020475c <sys_open+0x52>
      eunlock(ep);
    802047fe:	854a                	mv	a0,s2
    80204800:	00002097          	auipc	ra,0x2
    80204804:	bfc080e7          	jalr	-1028(ra) # 802063fc <eunlock>
      eput(ep);
    80204808:	854a                	mv	a0,s2
    8020480a:	00002097          	auipc	ra,0x2
    8020480e:	c40080e7          	jalr	-960(ra) # 8020644a <eput>
      return -1;
    80204812:	557d                	li	a0,-1
    80204814:	7912                	ld	s2,288(sp)
    80204816:	bf6d                	j	802047d0 <sys_open+0xc6>
      fileclose(f);
    80204818:	854e                	mv	a0,s3
    8020481a:	fffff097          	auipc	ra,0xfffff
    8020481e:	078080e7          	jalr	120(ra) # 80203892 <fileclose>
    80204822:	74b2                	ld	s1,296(sp)
    eunlock(ep);
    80204824:	854a                	mv	a0,s2
    80204826:	00002097          	auipc	ra,0x2
    8020482a:	bd6080e7          	jalr	-1066(ra) # 802063fc <eunlock>
    eput(ep);
    8020482e:	854a                	mv	a0,s2
    80204830:	00002097          	auipc	ra,0x2
    80204834:	c1a080e7          	jalr	-998(ra) # 8020644a <eput>
    return -1;
    80204838:	557d                	li	a0,-1
    8020483a:	7912                	ld	s2,288(sp)
    8020483c:	69f2                	ld	s3,280(sp)
    8020483e:	bf49                	j	802047d0 <sys_open+0xc6>
    etrunc(ep);
    80204840:	854a                	mv	a0,s2
    80204842:	00002097          	auipc	ra,0x2
    80204846:	b1a080e7          	jalr	-1254(ra) # 8020635c <etrunc>
    8020484a:	b789                	j	8020478c <sys_open+0x82>
    return -1;
    8020484c:	557d                	li	a0,-1
    8020484e:	b749                	j	802047d0 <sys_open+0xc6>
      return -1;
    80204850:	557d                	li	a0,-1
    80204852:	7912                	ld	s2,288(sp)
    80204854:	bfb5                	j	802047d0 <sys_open+0xc6>
      return -1;
    80204856:	557d                	li	a0,-1
    80204858:	7912                	ld	s2,288(sp)
    8020485a:	bf9d                	j	802047d0 <sys_open+0xc6>

000000008020485c <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8020485c:	7169                	addi	sp,sp,-304
    8020485e:	f606                	sd	ra,296(sp)
    80204860:	f222                	sd	s0,288(sp)
    80204862:	1a00                	addi	s0,sp,304
  char path[FAT32_MAX_PATH];
  struct dirent *ep;

  if(argstr(0, path, FAT32_MAX_PATH) < 0 || (ep = create(path, T_DIR, 0)) == 0){
    80204864:	10400613          	li	a2,260
    80204868:	ed840593          	addi	a1,s0,-296
    8020486c:	4501                	li	a0,0
    8020486e:	ffffe097          	auipc	ra,0xffffe
    80204872:	698080e7          	jalr	1688(ra) # 80202f06 <argstr>
    return -1;
    80204876:	57fd                	li	a5,-1
  if(argstr(0, path, FAT32_MAX_PATH) < 0 || (ep = create(path, T_DIR, 0)) == 0){
    80204878:	02054863          	bltz	a0,802048a8 <sys_mkdir+0x4c>
    8020487c:	ee26                	sd	s1,280(sp)
    8020487e:	4601                	li	a2,0
    80204880:	4585                	li	a1,1
    80204882:	ed840513          	addi	a0,s0,-296
    80204886:	00000097          	auipc	ra,0x0
    8020488a:	bfa080e7          	jalr	-1030(ra) # 80204480 <create>
    8020488e:	84aa                	mv	s1,a0
    80204890:	c10d                	beqz	a0,802048b2 <sys_mkdir+0x56>
  }
  eunlock(ep);
    80204892:	00002097          	auipc	ra,0x2
    80204896:	b6a080e7          	jalr	-1174(ra) # 802063fc <eunlock>
  eput(ep);
    8020489a:	8526                	mv	a0,s1
    8020489c:	00002097          	auipc	ra,0x2
    802048a0:	bae080e7          	jalr	-1106(ra) # 8020644a <eput>
  return 0;
    802048a4:	4781                	li	a5,0
    802048a6:	64f2                	ld	s1,280(sp)
}
    802048a8:	853e                	mv	a0,a5
    802048aa:	70b2                	ld	ra,296(sp)
    802048ac:	7412                	ld	s0,288(sp)
    802048ae:	6155                	addi	sp,sp,304
    802048b0:	8082                	ret
    return -1;
    802048b2:	57fd                	li	a5,-1
    802048b4:	64f2                	ld	s1,280(sp)
    802048b6:	bfcd                	j	802048a8 <sys_mkdir+0x4c>

00000000802048b8 <sys_chdir>:

uint64
sys_chdir(void)
{
    802048b8:	7169                	addi	sp,sp,-304
    802048ba:	f606                	sd	ra,296(sp)
    802048bc:	f222                	sd	s0,288(sp)
    802048be:	ea4a                	sd	s2,272(sp)
    802048c0:	1a00                	addi	s0,sp,304
  char path[FAT32_MAX_PATH];
  struct dirent *ep;
  struct proc *p = myproc();
    802048c2:	ffffd097          	auipc	ra,0xffffd
    802048c6:	20c080e7          	jalr	524(ra) # 80201ace <myproc>
    802048ca:	892a                	mv	s2,a0
  
  if(argstr(0, path, FAT32_MAX_PATH) < 0 || (ep = ename(path)) == NULL){
    802048cc:	10400613          	li	a2,260
    802048d0:	ed840593          	addi	a1,s0,-296
    802048d4:	4501                	li	a0,0
    802048d6:	ffffe097          	auipc	ra,0xffffe
    802048da:	630080e7          	jalr	1584(ra) # 80202f06 <argstr>
    return -1;
    802048de:	57fd                	li	a5,-1
  if(argstr(0, path, FAT32_MAX_PATH) < 0 || (ep = ename(path)) == NULL){
    802048e0:	04054263          	bltz	a0,80204924 <sys_chdir+0x6c>
    802048e4:	ee26                	sd	s1,280(sp)
    802048e6:	ed840513          	addi	a0,s0,-296
    802048ea:	00002097          	auipc	ra,0x2
    802048ee:	32c080e7          	jalr	812(ra) # 80206c16 <ename>
    802048f2:	84aa                	mv	s1,a0
    802048f4:	c939                	beqz	a0,8020494a <sys_chdir+0x92>
  }
  elock(ep);
    802048f6:	00002097          	auipc	ra,0x2
    802048fa:	ad0080e7          	jalr	-1328(ra) # 802063c6 <elock>
  if(!(ep->attribute & ATTR_DIRECTORY)){
    802048fe:	1004c783          	lbu	a5,256(s1)
    80204902:	8bc1                	andi	a5,a5,16
    80204904:	c795                	beqz	a5,80204930 <sys_chdir+0x78>
    eunlock(ep);
    eput(ep);
    return -1;
  }
  eunlock(ep);
    80204906:	8526                	mv	a0,s1
    80204908:	00002097          	auipc	ra,0x2
    8020490c:	af4080e7          	jalr	-1292(ra) # 802063fc <eunlock>
  eput(p->cwd);
    80204910:	15893503          	ld	a0,344(s2)
    80204914:	00002097          	auipc	ra,0x2
    80204918:	b36080e7          	jalr	-1226(ra) # 8020644a <eput>
  p->cwd = ep;
    8020491c:	14993c23          	sd	s1,344(s2)
  return 0;
    80204920:	4781                	li	a5,0
    80204922:	64f2                	ld	s1,280(sp)
}
    80204924:	853e                	mv	a0,a5
    80204926:	70b2                	ld	ra,296(sp)
    80204928:	7412                	ld	s0,288(sp)
    8020492a:	6952                	ld	s2,272(sp)
    8020492c:	6155                	addi	sp,sp,304
    8020492e:	8082                	ret
    eunlock(ep);
    80204930:	8526                	mv	a0,s1
    80204932:	00002097          	auipc	ra,0x2
    80204936:	aca080e7          	jalr	-1334(ra) # 802063fc <eunlock>
    eput(ep);
    8020493a:	8526                	mv	a0,s1
    8020493c:	00002097          	auipc	ra,0x2
    80204940:	b0e080e7          	jalr	-1266(ra) # 8020644a <eput>
    return -1;
    80204944:	57fd                	li	a5,-1
    80204946:	64f2                	ld	s1,280(sp)
    80204948:	bff1                	j	80204924 <sys_chdir+0x6c>
    return -1;
    8020494a:	57fd                	li	a5,-1
    8020494c:	64f2                	ld	s1,280(sp)
    8020494e:	bfd9                	j	80204924 <sys_chdir+0x6c>

0000000080204950 <sys_pipe>:

uint64
sys_pipe(void)
{
    80204950:	7139                	addi	sp,sp,-64
    80204952:	fc06                	sd	ra,56(sp)
    80204954:	f822                	sd	s0,48(sp)
    80204956:	f426                	sd	s1,40(sp)
    80204958:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8020495a:	ffffd097          	auipc	ra,0xffffd
    8020495e:	174080e7          	jalr	372(ra) # 80201ace <myproc>
    80204962:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80204964:	fd840593          	addi	a1,s0,-40
    80204968:	4501                	li	a0,0
    8020496a:	ffffe097          	auipc	ra,0xffffe
    8020496e:	57a080e7          	jalr	1402(ra) # 80202ee4 <argaddr>
    return -1;
    80204972:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80204974:	0c054e63          	bltz	a0,80204a50 <sys_pipe+0x100>
  if(pipealloc(&rf, &wf) < 0)
    80204978:	fc840593          	addi	a1,s0,-56
    8020497c:	fd040513          	addi	a0,s0,-48
    80204980:	fffff097          	auipc	ra,0xfffff
    80204984:	2f4080e7          	jalr	756(ra) # 80203c74 <pipealloc>
    return -1;
    80204988:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8020498a:	0c054363          	bltz	a0,80204a50 <sys_pipe+0x100>
  fd0 = -1;
    8020498e:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80204992:	fd043503          	ld	a0,-48(s0)
    80204996:	00000097          	auipc	ra,0x0
    8020499a:	aa8080e7          	jalr	-1368(ra) # 8020443e <fdalloc>
    8020499e:	fca42223          	sw	a0,-60(s0)
    802049a2:	08054a63          	bltz	a0,80204a36 <sys_pipe+0xe6>
    802049a6:	fc843503          	ld	a0,-56(s0)
    802049aa:	00000097          	auipc	ra,0x0
    802049ae:	a94080e7          	jalr	-1388(ra) # 8020443e <fdalloc>
    802049b2:	fca42023          	sw	a0,-64(s0)
    802049b6:	06054763          	bltz	a0,80204a24 <sys_pipe+0xd4>
    fileclose(wf);
    return -1;
  }
  // if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
  //    copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
  if(copyout2(fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    802049ba:	4611                	li	a2,4
    802049bc:	fc440593          	addi	a1,s0,-60
    802049c0:	fd843503          	ld	a0,-40(s0)
    802049c4:	ffffd097          	auipc	ra,0xffffd
    802049c8:	a34080e7          	jalr	-1484(ra) # 802013f8 <copyout2>
    802049cc:	00054f63          	bltz	a0,802049ea <sys_pipe+0x9a>
     copyout2(fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    802049d0:	4611                	li	a2,4
    802049d2:	fc040593          	addi	a1,s0,-64
    802049d6:	fd843503          	ld	a0,-40(s0)
    802049da:	0511                	addi	a0,a0,4
    802049dc:	ffffd097          	auipc	ra,0xffffd
    802049e0:	a1c080e7          	jalr	-1508(ra) # 802013f8 <copyout2>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    802049e4:	4781                	li	a5,0
  if(copyout2(fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    802049e6:	06055563          	bgez	a0,80204a50 <sys_pipe+0x100>
    p->ofile[fd0] = 0;
    802049ea:	fc442783          	lw	a5,-60(s0)
    802049ee:	07e9                	addi	a5,a5,26
    802049f0:	078e                	slli	a5,a5,0x3
    802049f2:	97a6                	add	a5,a5,s1
    802049f4:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    802049f8:	fc042783          	lw	a5,-64(s0)
    802049fc:	07e9                	addi	a5,a5,26
    802049fe:	078e                	slli	a5,a5,0x3
    80204a00:	00f48533          	add	a0,s1,a5
    80204a04:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80204a08:	fd043503          	ld	a0,-48(s0)
    80204a0c:	fffff097          	auipc	ra,0xfffff
    80204a10:	e86080e7          	jalr	-378(ra) # 80203892 <fileclose>
    fileclose(wf);
    80204a14:	fc843503          	ld	a0,-56(s0)
    80204a18:	fffff097          	auipc	ra,0xfffff
    80204a1c:	e7a080e7          	jalr	-390(ra) # 80203892 <fileclose>
    return -1;
    80204a20:	57fd                	li	a5,-1
    80204a22:	a03d                	j	80204a50 <sys_pipe+0x100>
    if(fd0 >= 0)
    80204a24:	fc442783          	lw	a5,-60(s0)
    80204a28:	0007c763          	bltz	a5,80204a36 <sys_pipe+0xe6>
      p->ofile[fd0] = 0;
    80204a2c:	07e9                	addi	a5,a5,26
    80204a2e:	078e                	slli	a5,a5,0x3
    80204a30:	97a6                	add	a5,a5,s1
    80204a32:	0007b423          	sd	zero,8(a5)
    fileclose(rf);
    80204a36:	fd043503          	ld	a0,-48(s0)
    80204a3a:	fffff097          	auipc	ra,0xfffff
    80204a3e:	e58080e7          	jalr	-424(ra) # 80203892 <fileclose>
    fileclose(wf);
    80204a42:	fc843503          	ld	a0,-56(s0)
    80204a46:	fffff097          	auipc	ra,0xfffff
    80204a4a:	e4c080e7          	jalr	-436(ra) # 80203892 <fileclose>
    return -1;
    80204a4e:	57fd                	li	a5,-1
}
    80204a50:	853e                	mv	a0,a5
    80204a52:	70e2                	ld	ra,56(sp)
    80204a54:	7442                	ld	s0,48(sp)
    80204a56:	74a2                	ld	s1,40(sp)
    80204a58:	6121                	addi	sp,sp,64
    80204a5a:	8082                	ret

0000000080204a5c <sys_dev>:

// To open console device.
uint64
sys_dev(void)
{
    80204a5c:	7179                	addi	sp,sp,-48
    80204a5e:	f406                	sd	ra,40(sp)
    80204a60:	f022                	sd	s0,32(sp)
    80204a62:	1800                	addi	s0,sp,48
  int fd, omode;
  int major, minor;
  struct file *f;

  if(argint(0, &omode) < 0 || argint(1, &major) < 0 || argint(2, &minor) < 0){
    80204a64:	fdc40593          	addi	a1,s0,-36
    80204a68:	4501                	li	a0,0
    80204a6a:	ffffe097          	auipc	ra,0xffffe
    80204a6e:	418080e7          	jalr	1048(ra) # 80202e82 <argint>
    80204a72:	0a054563          	bltz	a0,80204b1c <sys_dev+0xc0>
    80204a76:	fd840593          	addi	a1,s0,-40
    80204a7a:	4505                	li	a0,1
    80204a7c:	ffffe097          	auipc	ra,0xffffe
    80204a80:	406080e7          	jalr	1030(ra) # 80202e82 <argint>
    80204a84:	0a054163          	bltz	a0,80204b26 <sys_dev+0xca>
    80204a88:	fd440593          	addi	a1,s0,-44
    80204a8c:	4509                	li	a0,2
    80204a8e:	ffffe097          	auipc	ra,0xffffe
    80204a92:	3f4080e7          	jalr	1012(ra) # 80202e82 <argint>
    80204a96:	08054a63          	bltz	a0,80204b2a <sys_dev+0xce>
    return -1;
  }

  if(omode & O_CREATE){
    80204a9a:	fdc42783          	lw	a5,-36(s0)
    80204a9e:	2007f793          	andi	a5,a5,512
    80204aa2:	efa1                	bnez	a5,80204afa <sys_dev+0x9e>
    panic("dev file on FAT");
  }

  if(major < 0 || major >= NDEV)
    80204aa4:	fd842703          	lw	a4,-40(s0)
    80204aa8:	47a5                	li	a5,9
    return -1;
    80204aaa:	557d                	li	a0,-1
  if(major < 0 || major >= NDEV)
    80204aac:	06e7e963          	bltu	a5,a4,80204b1e <sys_dev+0xc2>
    80204ab0:	ec26                	sd	s1,24(sp)

  if((f = filealloc()) == NULL || (fd = fdalloc(f)) < 0){
    80204ab2:	fffff097          	auipc	ra,0xfffff
    80204ab6:	d24080e7          	jalr	-732(ra) # 802037d6 <filealloc>
    80204aba:	84aa                	mv	s1,a0
    80204abc:	c92d                	beqz	a0,80204b2e <sys_dev+0xd2>
    80204abe:	00000097          	auipc	ra,0x0
    80204ac2:	980080e7          	jalr	-1664(ra) # 8020443e <fdalloc>
    80204ac6:	04054363          	bltz	a0,80204b0c <sys_dev+0xb0>
    if(f)
      fileclose(f);
    return -1;
  }

  f->type = FD_DEVICE;
    80204aca:	478d                	li	a5,3
    80204acc:	c09c                	sw	a5,0(s1)
  f->off = 0;
    80204ace:	0204a023          	sw	zero,32(s1)
  f->ep = 0;
    80204ad2:	0004bc23          	sd	zero,24(s1)
  f->major = major;
    80204ad6:	fd842783          	lw	a5,-40(s0)
    80204ada:	02f49223          	sh	a5,36(s1)
  f->readable = !(omode & O_WRONLY);
    80204ade:	fdc42783          	lw	a5,-36(s0)
    80204ae2:	0017c713          	xori	a4,a5,1
    80204ae6:	8b05                	andi	a4,a4,1
    80204ae8:	00e48423          	sb	a4,8(s1)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80204aec:	8b8d                	andi	a5,a5,3
    80204aee:	00f037b3          	snez	a5,a5
    80204af2:	00f484a3          	sb	a5,9(s1)

  return fd;
    80204af6:	64e2                	ld	s1,24(sp)
    80204af8:	a01d                	j	80204b1e <sys_dev+0xc2>
    80204afa:	ec26                	sd	s1,24(sp)
    panic("dev file on FAT");
    80204afc:	00005517          	auipc	a0,0x5
    80204b00:	01c50513          	addi	a0,a0,28 # 80209b18 <etext+0xb18>
    80204b04:	ffffb097          	auipc	ra,0xffffb
    80204b08:	642080e7          	jalr	1602(ra) # 80200146 <panic>
      fileclose(f);
    80204b0c:	8526                	mv	a0,s1
    80204b0e:	fffff097          	auipc	ra,0xfffff
    80204b12:	d84080e7          	jalr	-636(ra) # 80203892 <fileclose>
    return -1;
    80204b16:	557d                	li	a0,-1
    80204b18:	64e2                	ld	s1,24(sp)
    80204b1a:	a011                	j	80204b1e <sys_dev+0xc2>
    return -1;
    80204b1c:	557d                	li	a0,-1
}
    80204b1e:	70a2                	ld	ra,40(sp)
    80204b20:	7402                	ld	s0,32(sp)
    80204b22:	6145                	addi	sp,sp,48
    80204b24:	8082                	ret
    return -1;
    80204b26:	557d                	li	a0,-1
    80204b28:	bfdd                	j	80204b1e <sys_dev+0xc2>
    80204b2a:	557d                	li	a0,-1
    80204b2c:	bfcd                	j	80204b1e <sys_dev+0xc2>
    return -1;
    80204b2e:	557d                	li	a0,-1
    80204b30:	64e2                	ld	s1,24(sp)
    80204b32:	b7f5                	j	80204b1e <sys_dev+0xc2>

0000000080204b34 <sys_readdir>:

// To support ls command
uint64
sys_readdir(void)
{
    80204b34:	1101                	addi	sp,sp,-32
    80204b36:	ec06                	sd	ra,24(sp)
    80204b38:	e822                	sd	s0,16(sp)
    80204b3a:	1000                	addi	s0,sp,32
  struct file *f;
  uint64 p;

  if(argfd(0, 0, &f) < 0 || argaddr(1, &p) < 0)
    80204b3c:	fe840613          	addi	a2,s0,-24
    80204b40:	4581                	li	a1,0
    80204b42:	4501                	li	a0,0
    80204b44:	00000097          	auipc	ra,0x0
    80204b48:	892080e7          	jalr	-1902(ra) # 802043d6 <argfd>
    return -1;
    80204b4c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &p) < 0)
    80204b4e:	02054563          	bltz	a0,80204b78 <sys_readdir+0x44>
    80204b52:	fe040593          	addi	a1,s0,-32
    80204b56:	4505                	li	a0,1
    80204b58:	ffffe097          	auipc	ra,0xffffe
    80204b5c:	38c080e7          	jalr	908(ra) # 80202ee4 <argaddr>
    return -1;
    80204b60:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &p) < 0)
    80204b62:	00054b63          	bltz	a0,80204b78 <sys_readdir+0x44>
  return dirnext(f, p);
    80204b66:	fe043583          	ld	a1,-32(s0)
    80204b6a:	fe843503          	ld	a0,-24(s0)
    80204b6e:	fffff097          	auipc	ra,0xfffff
    80204b72:	03a080e7          	jalr	58(ra) # 80203ba8 <dirnext>
    80204b76:	87aa                	mv	a5,a0
}
    80204b78:	853e                	mv	a0,a5
    80204b7a:	60e2                	ld	ra,24(sp)
    80204b7c:	6442                	ld	s0,16(sp)
    80204b7e:	6105                	addi	sp,sp,32
    80204b80:	8082                	ret

0000000080204b82 <sys_getcwd>:

// get absolute cwd string
uint64
sys_getcwd(void)
{
    80204b82:	714d                	addi	sp,sp,-336
    80204b84:	e686                	sd	ra,328(sp)
    80204b86:	e2a2                	sd	s0,320(sp)
    80204b88:	0a80                	addi	s0,sp,336
  uint64 addr;
  if (argaddr(0, &addr) < 0)
    80204b8a:	fb840593          	addi	a1,s0,-72
    80204b8e:	4501                	li	a0,0
    80204b90:	ffffe097          	auipc	ra,0xffffe
    80204b94:	354080e7          	jalr	852(ra) # 80202ee4 <argaddr>
    80204b98:	87aa                	mv	a5,a0
    return -1;
    80204b9a:	557d                	li	a0,-1
  if (argaddr(0, &addr) < 0)
    80204b9c:	0807c663          	bltz	a5,80204c28 <sys_getcwd+0xa6>
    80204ba0:	fe26                	sd	s1,312(sp)
    80204ba2:	f64e                	sd	s3,296(sp)

  struct dirent *de = myproc()->cwd;
    80204ba4:	ffffd097          	auipc	ra,0xffffd
    80204ba8:	f2a080e7          	jalr	-214(ra) # 80201ace <myproc>
    80204bac:	15853483          	ld	s1,344(a0)
  char path[FAT32_MAX_PATH];
  char *s;
  int len;

  if (de->parent == NULL) {
    80204bb0:	1204b783          	ld	a5,288(s1)
    80204bb4:	cfb5                	beqz	a5,80204c30 <sys_getcwd+0xae>
    80204bb6:	fa4a                	sd	s2,304(sp)
    80204bb8:	f252                	sd	s4,288(sp)
    80204bba:	ee56                	sd	s5,280(sp)
    s = "/";
  } else {
    s = path + FAT32_MAX_PATH - 1;
    *s = '\0';
    80204bbc:	fa0409a3          	sb	zero,-77(s0)
    s = path + FAT32_MAX_PATH - 1;
    80204bc0:	fb340993          	addi	s3,s0,-77
    while (de->parent) {
      len = strlen(de->filename);
      s -= len;
      if (s <= path)          // can't reach root "/"
    80204bc4:	eb040a13          	addi	s4,s0,-336
        return -1;
      strncpy(s, de->filename, len);
      *--s = '/';
    80204bc8:	02f00a93          	li	s5,47
      len = strlen(de->filename);
    80204bcc:	8526                	mv	a0,s1
    80204bce:	ffffc097          	auipc	ra,0xffffc
    80204bd2:	d3a080e7          	jalr	-710(ra) # 80200908 <strlen>
    80204bd6:	862a                	mv	a2,a0
      s -= len;
    80204bd8:	40a98933          	sub	s2,s3,a0
      if (s <= path)          // can't reach root "/"
    80204bdc:	052a7f63          	bgeu	s4,s2,80204c3a <sys_getcwd+0xb8>
      strncpy(s, de->filename, len);
    80204be0:	85a6                	mv	a1,s1
    80204be2:	854a                	mv	a0,s2
    80204be4:	ffffc097          	auipc	ra,0xffffc
    80204be8:	cb6080e7          	jalr	-842(ra) # 8020089a <strncpy>
      *--s = '/';
    80204bec:	fff90993          	addi	s3,s2,-1
    80204bf0:	ff590fa3          	sb	s5,-1(s2)
      de = de->parent;
    80204bf4:	1204b483          	ld	s1,288(s1)
    while (de->parent) {
    80204bf8:	1204b783          	ld	a5,288(s1)
    80204bfc:	fbe1                	bnez	a5,80204bcc <sys_getcwd+0x4a>
    80204bfe:	7952                	ld	s2,304(sp)
    80204c00:	7a12                	ld	s4,288(sp)
    80204c02:	6af2                	ld	s5,280(sp)
    }
  }

  // if (copyout(myproc()->pagetable, addr, s, strlen(s) + 1) < 0)
  if (copyout2(addr, s, strlen(s) + 1) < 0)
    80204c04:	fb843483          	ld	s1,-72(s0)
    80204c08:	854e                	mv	a0,s3
    80204c0a:	ffffc097          	auipc	ra,0xffffc
    80204c0e:	cfe080e7          	jalr	-770(ra) # 80200908 <strlen>
    80204c12:	0015061b          	addiw	a2,a0,1
    80204c16:	85ce                	mv	a1,s3
    80204c18:	8526                	mv	a0,s1
    80204c1a:	ffffc097          	auipc	ra,0xffffc
    80204c1e:	7de080e7          	jalr	2014(ra) # 802013f8 <copyout2>
    80204c22:	957d                	srai	a0,a0,0x3f
    80204c24:	74f2                	ld	s1,312(sp)
    80204c26:	79b2                	ld	s3,296(sp)
    return -1;
  
  return 0;

}
    80204c28:	60b6                	ld	ra,328(sp)
    80204c2a:	6416                	ld	s0,320(sp)
    80204c2c:	6171                	addi	sp,sp,336
    80204c2e:	8082                	ret
    s = "/";
    80204c30:	00005997          	auipc	s3,0x5
    80204c34:	9e098993          	addi	s3,s3,-1568 # 80209610 <etext+0x610>
    80204c38:	b7f1                	j	80204c04 <sys_getcwd+0x82>
        return -1;
    80204c3a:	557d                	li	a0,-1
    80204c3c:	74f2                	ld	s1,312(sp)
    80204c3e:	7952                	ld	s2,304(sp)
    80204c40:	79b2                	ld	s3,296(sp)
    80204c42:	7a12                	ld	s4,288(sp)
    80204c44:	6af2                	ld	s5,280(sp)
    80204c46:	b7cd                	j	80204c28 <sys_getcwd+0xa6>

0000000080204c48 <sys_remove>:
  return ret == -1;
}

uint64
sys_remove(void)
{
    80204c48:	d6010113          	addi	sp,sp,-672
    80204c4c:	28113c23          	sd	ra,664(sp)
    80204c50:	28813823          	sd	s0,656(sp)
    80204c54:	1500                	addi	s0,sp,672
  char path[FAT32_MAX_PATH];
  struct dirent *ep;
  int len;
  if((len = argstr(0, path, FAT32_MAX_PATH)) <= 0)
    80204c56:	10400613          	li	a2,260
    80204c5a:	ed840593          	addi	a1,s0,-296
    80204c5e:	4501                	li	a0,0
    80204c60:	ffffe097          	auipc	ra,0xffffe
    80204c64:	2a6080e7          	jalr	678(ra) # 80202f06 <argstr>
    80204c68:	10a05863          	blez	a0,80204d78 <sys_remove+0x130>
    return -1;

  char *s = path + len - 1;
    80204c6c:	ed840713          	addi	a4,s0,-296
    80204c70:	157d                	addi	a0,a0,-1
    80204c72:	00a707b3          	add	a5,a4,a0
  while (s >= path && *s == '/') {
    80204c76:	02f00693          	li	a3,47
    80204c7a:	863a                	mv	a2,a4
    80204c7c:	0ae7e063          	bltu	a5,a4,80204d1c <sys_remove+0xd4>
    80204c80:	0007c703          	lbu	a4,0(a5)
    80204c84:	08d71f63          	bne	a4,a3,80204d22 <sys_remove+0xda>
    s--;
    80204c88:	17fd                	addi	a5,a5,-1
  while (s >= path && *s == '/') {
    80204c8a:	fec7fbe3          	bgeu	a5,a2,80204c80 <sys_remove+0x38>
    80204c8e:	28913423          	sd	s1,648(sp)
  }
  if (s >= path && *s == '.' && (s == path || *--s == '/')) {
    return -1;
  }
  
  if((ep = ename(path)) == NULL){
    80204c92:	ed840513          	addi	a0,s0,-296
    80204c96:	00002097          	auipc	ra,0x2
    80204c9a:	f80080e7          	jalr	-128(ra) # 80206c16 <ename>
    80204c9e:	84aa                	mv	s1,a0
    80204ca0:	c175                	beqz	a0,80204d84 <sys_remove+0x13c>
    return -1;
  }
  elock(ep);
    80204ca2:	00001097          	auipc	ra,0x1
    80204ca6:	724080e7          	jalr	1828(ra) # 802063c6 <elock>
  if((ep->attribute & ATTR_DIRECTORY) && !isdirempty(ep)){
    80204caa:	1004c783          	lbu	a5,256(s1)
    80204cae:	8bc1                	andi	a5,a5,16
    80204cb0:	c38d                	beqz	a5,80204cd2 <sys_remove+0x8a>
  ep.valid = 0;
    80204cb2:	e8041323          	sh	zero,-378(s0)
  ret = enext(dp, &ep, 2 * 32, &count);   // skip the "." and ".."
    80204cb6:	d6c40693          	addi	a3,s0,-660
    80204cba:	04000613          	li	a2,64
    80204cbe:	d7040593          	addi	a1,s0,-656
    80204cc2:	8526                	mv	a0,s1
    80204cc4:	00002097          	auipc	ra,0x2
    80204cc8:	90a080e7          	jalr	-1782(ra) # 802065ce <enext>
  if((ep->attribute & ATTR_DIRECTORY) && !isdirempty(ep)){
    80204ccc:	57fd                	li	a5,-1
    80204cce:	08f51763          	bne	a0,a5,80204d5c <sys_remove+0x114>
      eunlock(ep);
      eput(ep);
      return -1;
  }
  elock(ep->parent);      // Will this lead to deadlock?
    80204cd2:	1204b503          	ld	a0,288(s1)
    80204cd6:	00001097          	auipc	ra,0x1
    80204cda:	6f0080e7          	jalr	1776(ra) # 802063c6 <elock>
  eremove(ep);
    80204cde:	8526                	mv	a0,s1
    80204ce0:	00001097          	auipc	ra,0x1
    80204ce4:	5b8080e7          	jalr	1464(ra) # 80206298 <eremove>
  eunlock(ep->parent);
    80204ce8:	1204b503          	ld	a0,288(s1)
    80204cec:	00001097          	auipc	ra,0x1
    80204cf0:	710080e7          	jalr	1808(ra) # 802063fc <eunlock>
  eunlock(ep);
    80204cf4:	8526                	mv	a0,s1
    80204cf6:	00001097          	auipc	ra,0x1
    80204cfa:	706080e7          	jalr	1798(ra) # 802063fc <eunlock>
  eput(ep);
    80204cfe:	8526                	mv	a0,s1
    80204d00:	00001097          	auipc	ra,0x1
    80204d04:	74a080e7          	jalr	1866(ra) # 8020644a <eput>

  return 0;
    80204d08:	4501                	li	a0,0
    80204d0a:	28813483          	ld	s1,648(sp)
}
    80204d0e:	29813083          	ld	ra,664(sp)
    80204d12:	29013403          	ld	s0,656(sp)
    80204d16:	2a010113          	addi	sp,sp,672
    80204d1a:	8082                	ret
    80204d1c:	28913423          	sd	s1,648(sp)
    80204d20:	bf8d                	j	80204c92 <sys_remove+0x4a>
  if (s >= path && *s == '.' && (s == path || *--s == '/')) {
    80204d22:	ed840713          	addi	a4,s0,-296
    80204d26:	02e7e863          	bltu	a5,a4,80204d56 <sys_remove+0x10e>
    80204d2a:	0007c683          	lbu	a3,0(a5)
    80204d2e:	02e00713          	li	a4,46
    80204d32:	00e68563          	beq	a3,a4,80204d3c <sys_remove+0xf4>
    80204d36:	28913423          	sd	s1,648(sp)
    80204d3a:	bfa1                	j	80204c92 <sys_remove+0x4a>
    80204d3c:	ed840713          	addi	a4,s0,-296
    80204d40:	02e78e63          	beq	a5,a4,80204d7c <sys_remove+0x134>
    80204d44:	fff7c703          	lbu	a4,-1(a5)
    80204d48:	02f00793          	li	a5,47
    80204d4c:	02f70a63          	beq	a4,a5,80204d80 <sys_remove+0x138>
    80204d50:	28913423          	sd	s1,648(sp)
    80204d54:	bf3d                	j	80204c92 <sys_remove+0x4a>
    80204d56:	28913423          	sd	s1,648(sp)
    80204d5a:	bf25                	j	80204c92 <sys_remove+0x4a>
      eunlock(ep);
    80204d5c:	8526                	mv	a0,s1
    80204d5e:	00001097          	auipc	ra,0x1
    80204d62:	69e080e7          	jalr	1694(ra) # 802063fc <eunlock>
      eput(ep);
    80204d66:	8526                	mv	a0,s1
    80204d68:	00001097          	auipc	ra,0x1
    80204d6c:	6e2080e7          	jalr	1762(ra) # 8020644a <eput>
      return -1;
    80204d70:	557d                	li	a0,-1
    80204d72:	28813483          	ld	s1,648(sp)
    80204d76:	bf61                	j	80204d0e <sys_remove+0xc6>
    return -1;
    80204d78:	557d                	li	a0,-1
    80204d7a:	bf51                	j	80204d0e <sys_remove+0xc6>
    return -1;
    80204d7c:	557d                	li	a0,-1
    80204d7e:	bf41                	j	80204d0e <sys_remove+0xc6>
    80204d80:	557d                	li	a0,-1
    80204d82:	b771                	j	80204d0e <sys_remove+0xc6>
    return -1;
    80204d84:	557d                	li	a0,-1
    80204d86:	28813483          	ld	s1,648(sp)
    80204d8a:	b751                	j	80204d0e <sys_remove+0xc6>

0000000080204d8c <sys_rename>:

// Must hold too many locks at a time! It's possible to raise a deadlock.
// Because this op takes some steps, we can't promise
uint64
sys_rename(void)
{
    80204d8c:	c4010113          	addi	sp,sp,-960
    80204d90:	3a113c23          	sd	ra,952(sp)
    80204d94:	3a813823          	sd	s0,944(sp)
    80204d98:	0780                	addi	s0,sp,960
  char old[FAT32_MAX_PATH], new[FAT32_MAX_PATH];
  if (argstr(0, old, FAT32_MAX_PATH) < 0 || argstr(1, new, FAT32_MAX_PATH) < 0) {
    80204d9a:	10400613          	li	a2,260
    80204d9e:	ec840593          	addi	a1,s0,-312
    80204da2:	4501                	li	a0,0
    80204da4:	ffffe097          	auipc	ra,0xffffe
    80204da8:	162080e7          	jalr	354(ra) # 80202f06 <argstr>
      return -1;
    80204dac:	57fd                	li	a5,-1
  if (argstr(0, old, FAT32_MAX_PATH) < 0 || argstr(1, new, FAT32_MAX_PATH) < 0) {
    80204dae:	10054163          	bltz	a0,80204eb0 <sys_rename+0x124>
    80204db2:	10400613          	li	a2,260
    80204db6:	dc040593          	addi	a1,s0,-576
    80204dba:	4505                	li	a0,1
    80204dbc:	ffffe097          	auipc	ra,0xffffe
    80204dc0:	14a080e7          	jalr	330(ra) # 80202f06 <argstr>
      return -1;
    80204dc4:	57fd                	li	a5,-1
  if (argstr(0, old, FAT32_MAX_PATH) < 0 || argstr(1, new, FAT32_MAX_PATH) < 0) {
    80204dc6:	0e054563          	bltz	a0,80204eb0 <sys_rename+0x124>
    80204dca:	3a913423          	sd	s1,936(sp)
    80204dce:	3b213023          	sd	s2,928(sp)
  }

  struct dirent *src = NULL, *dst = NULL, *pdst = NULL;
  int srclock = 0;
  char *name;
  if ((src = ename(old)) == NULL || (pdst = enameparent(new, old)) == NULL
    80204dd2:	ec840513          	addi	a0,s0,-312
    80204dd6:	00002097          	auipc	ra,0x2
    80204dda:	e40080e7          	jalr	-448(ra) # 80206c16 <ename>
    80204dde:	84aa                	mv	s1,a0
    80204de0:	1e050f63          	beqz	a0,80204fde <sys_rename+0x252>
    80204de4:	ec840593          	addi	a1,s0,-312
    80204de8:	dc040513          	addi	a0,s0,-576
    80204dec:	00002097          	auipc	ra,0x2
    80204df0:	e48080e7          	jalr	-440(ra) # 80206c34 <enameparent>
    80204df4:	892a                	mv	s2,a0
    80204df6:	c949                	beqz	a0,80204e88 <sys_rename+0xfc>
    80204df8:	39313c23          	sd	s3,920(sp)
      || (name = formatname(old)) == NULL) {
    80204dfc:	ec840513          	addi	a0,s0,-312
    80204e00:	00001097          	auipc	ra,0x1
    80204e04:	ef2080e7          	jalr	-270(ra) # 80205cf2 <formatname>
    80204e08:	89aa                	mv	s3,a0
    80204e0a:	1c050463          	beqz	a0,80204fd2 <sys_rename+0x246>
    goto fail;          // src doesn't exist || dst parent doesn't exist || illegal new name
  }
  for (struct dirent *ep = pdst; ep != NULL; ep = ep->parent) {
    if (ep == src) {    // In what universe can we move a directory into its child?
    80204e0e:	1d248563          	beq	s1,s2,80204fd8 <sys_rename+0x24c>
  for (struct dirent *ep = pdst; ep != NULL; ep = ep->parent) {
    80204e12:	87ca                	mv	a5,s2
    80204e14:	1207b783          	ld	a5,288(a5)
    80204e18:	c791                	beqz	a5,80204e24 <sys_rename+0x98>
    if (ep == src) {    // In what universe can we move a directory into its child?
    80204e1a:	fef49de3          	bne	s1,a5,80204e14 <sys_rename+0x88>
    80204e1e:	39813983          	ld	s3,920(sp)
    80204e22:	a09d                	j	80204e88 <sys_rename+0xfc>
    80204e24:	39413823          	sd	s4,912(sp)
      goto fail;
    }
  }

  uint off;
  elock(src);     // must hold child's lock before acquiring parent's, because we do so in other similar cases
    80204e28:	8526                	mv	a0,s1
    80204e2a:	00001097          	auipc	ra,0x1
    80204e2e:	59c080e7          	jalr	1436(ra) # 802063c6 <elock>
  srclock = 1;
  elock(pdst);
    80204e32:	854a                	mv	a0,s2
    80204e34:	00001097          	auipc	ra,0x1
    80204e38:	592080e7          	jalr	1426(ra) # 802063c6 <elock>
  dst = dirlookup(pdst, name, &off);
    80204e3c:	dbc40613          	addi	a2,s0,-580
    80204e40:	85ce                	mv	a1,s3
    80204e42:	854a                	mv	a0,s2
    80204e44:	00002097          	auipc	ra,0x2
    80204e48:	982080e7          	jalr	-1662(ra) # 802067c6 <dirlookup>
    80204e4c:	8a2a                	mv	s4,a0
  if (dst != NULL) {
    80204e4e:	cd4d                	beqz	a0,80204f08 <sys_rename+0x17c>
    eunlock(pdst);
    80204e50:	854a                	mv	a0,s2
    80204e52:	00001097          	auipc	ra,0x1
    80204e56:	5aa080e7          	jalr	1450(ra) # 802063fc <eunlock>
    if (src == dst) {
    80204e5a:	01448963          	beq	s1,s4,80204e6c <sys_rename+0xe0>
      goto fail;
    } else if (src->attribute & dst->attribute & ATTR_DIRECTORY) {
    80204e5e:	1004c783          	lbu	a5,256(s1)
    80204e62:	100a4703          	lbu	a4,256(s4)
    80204e66:	8ff9                	and	a5,a5,a4
    80204e68:	8bc1                	andi	a5,a5,16
    80204e6a:	ebb9                	bnez	a5,80204ec0 <sys_rename+0x134>

  return 0;

fail:
  if (srclock)
    eunlock(src);
    80204e6c:	8526                	mv	a0,s1
    80204e6e:	00001097          	auipc	ra,0x1
    80204e72:	58e080e7          	jalr	1422(ra) # 802063fc <eunlock>
  if (dst)
    eput(dst);
    80204e76:	8552                	mv	a0,s4
    80204e78:	00001097          	auipc	ra,0x1
    80204e7c:	5d2080e7          	jalr	1490(ra) # 8020644a <eput>
    80204e80:	39813983          	ld	s3,920(sp)
    80204e84:	39013a03          	ld	s4,912(sp)
  if (pdst)
    80204e88:	00090763          	beqz	s2,80204e96 <sys_rename+0x10a>
    eput(pdst);
    80204e8c:	854a                	mv	a0,s2
    80204e8e:	00001097          	auipc	ra,0x1
    80204e92:	5bc080e7          	jalr	1468(ra) # 8020644a <eput>
  if (src)
    eput(src);
  return -1;
    80204e96:	57fd                	li	a5,-1
  if (src)
    80204e98:	14048563          	beqz	s1,80204fe2 <sys_rename+0x256>
    eput(src);
    80204e9c:	8526                	mv	a0,s1
    80204e9e:	00001097          	auipc	ra,0x1
    80204ea2:	5ac080e7          	jalr	1452(ra) # 8020644a <eput>
  return -1;
    80204ea6:	57fd                	li	a5,-1
    80204ea8:	3a813483          	ld	s1,936(sp)
    80204eac:	3a013903          	ld	s2,928(sp)
}
    80204eb0:	853e                	mv	a0,a5
    80204eb2:	3b813083          	ld	ra,952(sp)
    80204eb6:	3b013403          	ld	s0,944(sp)
    80204eba:	3c010113          	addi	sp,sp,960
    80204ebe:	8082                	ret
      elock(dst);
    80204ec0:	8552                	mv	a0,s4
    80204ec2:	00001097          	auipc	ra,0x1
    80204ec6:	504080e7          	jalr	1284(ra) # 802063c6 <elock>
  ep.valid = 0;
    80204eca:	d6041323          	sh	zero,-666(s0)
  ret = enext(dp, &ep, 2 * 32, &count);   // skip the "." and ".."
    80204ece:	c4c40693          	addi	a3,s0,-948
    80204ed2:	04000613          	li	a2,64
    80204ed6:	c5040593          	addi	a1,s0,-944
    80204eda:	8552                	mv	a0,s4
    80204edc:	00001097          	auipc	ra,0x1
    80204ee0:	6f2080e7          	jalr	1778(ra) # 802065ce <enext>
      if (!isdirempty(dst)) {    // it's ok to overwrite an empty dir
    80204ee4:	57fd                	li	a5,-1
    80204ee6:	0ef51063          	bne	a0,a5,80204fc6 <sys_rename+0x23a>
      elock(pdst);
    80204eea:	854a                	mv	a0,s2
    80204eec:	00001097          	auipc	ra,0x1
    80204ef0:	4da080e7          	jalr	1242(ra) # 802063c6 <elock>
    eremove(dst);
    80204ef4:	8552                	mv	a0,s4
    80204ef6:	00001097          	auipc	ra,0x1
    80204efa:	3a2080e7          	jalr	930(ra) # 80206298 <eremove>
    eunlock(dst);
    80204efe:	8552                	mv	a0,s4
    80204f00:	00001097          	auipc	ra,0x1
    80204f04:	4fc080e7          	jalr	1276(ra) # 802063fc <eunlock>
  memmove(src->filename, name, FAT32_MAX_FILENAME);
    80204f08:	0ff00613          	li	a2,255
    80204f0c:	85ce                	mv	a1,s3
    80204f0e:	8526                	mv	a0,s1
    80204f10:	ffffc097          	auipc	ra,0xffffc
    80204f14:	8d8080e7          	jalr	-1832(ra) # 802007e8 <memmove>
  emake(pdst, src, off);
    80204f18:	dbc42603          	lw	a2,-580(s0)
    80204f1c:	85a6                	mv	a1,s1
    80204f1e:	854a                	mv	a0,s2
    80204f20:	00001097          	auipc	ra,0x1
    80204f24:	e92080e7          	jalr	-366(ra) # 80205db2 <emake>
  if (src->parent != pdst) {
    80204f28:	1204b783          	ld	a5,288(s1)
    80204f2c:	01278d63          	beq	a5,s2,80204f46 <sys_rename+0x1ba>
    eunlock(pdst);
    80204f30:	854a                	mv	a0,s2
    80204f32:	00001097          	auipc	ra,0x1
    80204f36:	4ca080e7          	jalr	1226(ra) # 802063fc <eunlock>
    elock(src->parent);
    80204f3a:	1204b503          	ld	a0,288(s1)
    80204f3e:	00001097          	auipc	ra,0x1
    80204f42:	488080e7          	jalr	1160(ra) # 802063c6 <elock>
  eremove(src);
    80204f46:	8526                	mv	a0,s1
    80204f48:	00001097          	auipc	ra,0x1
    80204f4c:	350080e7          	jalr	848(ra) # 80206298 <eremove>
  eunlock(src->parent);
    80204f50:	1204b503          	ld	a0,288(s1)
    80204f54:	00001097          	auipc	ra,0x1
    80204f58:	4a8080e7          	jalr	1192(ra) # 802063fc <eunlock>
  struct dirent *psrc = src->parent;  // src must not be root, or it won't pass the for-loop test
    80204f5c:	1204b983          	ld	s3,288(s1)
  src->parent = edup(pdst);
    80204f60:	854a                	mv	a0,s2
    80204f62:	00001097          	auipc	ra,0x1
    80204f66:	210080e7          	jalr	528(ra) # 80206172 <edup>
    80204f6a:	12a4b023          	sd	a0,288(s1)
  src->off = off;
    80204f6e:	dbc42783          	lw	a5,-580(s0)
    80204f72:	10f4ae23          	sw	a5,284(s1)
  src->valid = 1;
    80204f76:	4785                	li	a5,1
    80204f78:	10f49b23          	sh	a5,278(s1)
  eunlock(src);
    80204f7c:	8526                	mv	a0,s1
    80204f7e:	00001097          	auipc	ra,0x1
    80204f82:	47e080e7          	jalr	1150(ra) # 802063fc <eunlock>
  eput(psrc);
    80204f86:	854e                	mv	a0,s3
    80204f88:	00001097          	auipc	ra,0x1
    80204f8c:	4c2080e7          	jalr	1218(ra) # 8020644a <eput>
  if (dst) {
    80204f90:	000a0763          	beqz	s4,80204f9e <sys_rename+0x212>
    eput(dst);
    80204f94:	8552                	mv	a0,s4
    80204f96:	00001097          	auipc	ra,0x1
    80204f9a:	4b4080e7          	jalr	1204(ra) # 8020644a <eput>
  eput(pdst);
    80204f9e:	854a                	mv	a0,s2
    80204fa0:	00001097          	auipc	ra,0x1
    80204fa4:	4aa080e7          	jalr	1194(ra) # 8020644a <eput>
  eput(src);
    80204fa8:	8526                	mv	a0,s1
    80204faa:	00001097          	auipc	ra,0x1
    80204fae:	4a0080e7          	jalr	1184(ra) # 8020644a <eput>
  return 0;
    80204fb2:	4781                	li	a5,0
    80204fb4:	3a813483          	ld	s1,936(sp)
    80204fb8:	3a013903          	ld	s2,928(sp)
    80204fbc:	39813983          	ld	s3,920(sp)
    80204fc0:	39013a03          	ld	s4,912(sp)
    80204fc4:	b5f5                	j	80204eb0 <sys_rename+0x124>
        eunlock(dst);
    80204fc6:	8552                	mv	a0,s4
    80204fc8:	00001097          	auipc	ra,0x1
    80204fcc:	434080e7          	jalr	1076(ra) # 802063fc <eunlock>
        goto fail;
    80204fd0:	bd71                	j	80204e6c <sys_rename+0xe0>
    80204fd2:	39813983          	ld	s3,920(sp)
    80204fd6:	bd4d                	j	80204e88 <sys_rename+0xfc>
    80204fd8:	39813983          	ld	s3,920(sp)
    80204fdc:	b575                	j	80204e88 <sys_rename+0xfc>
  struct dirent *src = NULL, *dst = NULL, *pdst = NULL;
    80204fde:	892a                	mv	s2,a0
  if (dst)
    80204fe0:	b565                	j	80204e88 <sys_rename+0xfc>
    80204fe2:	3a813483          	ld	s1,936(sp)
    80204fe6:	3a013903          	ld	s2,928(sp)
    80204fea:	b5d9                	j	80204eb0 <sys_rename+0x124>
    80204fec:	0000                	unimp
	...

0000000080204ff0 <kernelvec>:
    80204ff0:	7111                	addi	sp,sp,-256
    80204ff2:	e006                	sd	ra,0(sp)
    80204ff4:	e40a                	sd	sp,8(sp)
    80204ff6:	e80e                	sd	gp,16(sp)
    80204ff8:	ec12                	sd	tp,24(sp)
    80204ffa:	f016                	sd	t0,32(sp)
    80204ffc:	f41a                	sd	t1,40(sp)
    80204ffe:	f81e                	sd	t2,48(sp)
    80205000:	fc22                	sd	s0,56(sp)
    80205002:	e0a6                	sd	s1,64(sp)
    80205004:	e4aa                	sd	a0,72(sp)
    80205006:	e8ae                	sd	a1,80(sp)
    80205008:	ecb2                	sd	a2,88(sp)
    8020500a:	f0b6                	sd	a3,96(sp)
    8020500c:	f4ba                	sd	a4,104(sp)
    8020500e:	f8be                	sd	a5,112(sp)
    80205010:	fcc2                	sd	a6,120(sp)
    80205012:	e146                	sd	a7,128(sp)
    80205014:	e54a                	sd	s2,136(sp)
    80205016:	e94e                	sd	s3,144(sp)
    80205018:	ed52                	sd	s4,152(sp)
    8020501a:	f156                	sd	s5,160(sp)
    8020501c:	f55a                	sd	s6,168(sp)
    8020501e:	f95e                	sd	s7,176(sp)
    80205020:	fd62                	sd	s8,184(sp)
    80205022:	e1e6                	sd	s9,192(sp)
    80205024:	e5ea                	sd	s10,200(sp)
    80205026:	e9ee                	sd	s11,208(sp)
    80205028:	edf2                	sd	t3,216(sp)
    8020502a:	f1f6                	sd	t4,224(sp)
    8020502c:	f5fa                	sd	t5,232(sp)
    8020502e:	f9fe                	sd	t6,240(sp)
    80205030:	9d5fd0ef          	jal	80202a04 <kerneltrap>
    80205034:	6082                	ld	ra,0(sp)
    80205036:	6122                	ld	sp,8(sp)
    80205038:	61c2                	ld	gp,16(sp)
    8020503a:	7282                	ld	t0,32(sp)
    8020503c:	7322                	ld	t1,40(sp)
    8020503e:	73c2                	ld	t2,48(sp)
    80205040:	7462                	ld	s0,56(sp)
    80205042:	6486                	ld	s1,64(sp)
    80205044:	6526                	ld	a0,72(sp)
    80205046:	65c6                	ld	a1,80(sp)
    80205048:	6666                	ld	a2,88(sp)
    8020504a:	7686                	ld	a3,96(sp)
    8020504c:	7726                	ld	a4,104(sp)
    8020504e:	77c6                	ld	a5,112(sp)
    80205050:	7866                	ld	a6,120(sp)
    80205052:	688a                	ld	a7,128(sp)
    80205054:	692a                	ld	s2,136(sp)
    80205056:	69ca                	ld	s3,144(sp)
    80205058:	6a6a                	ld	s4,152(sp)
    8020505a:	7a8a                	ld	s5,160(sp)
    8020505c:	7b2a                	ld	s6,168(sp)
    8020505e:	7bca                	ld	s7,176(sp)
    80205060:	7c6a                	ld	s8,184(sp)
    80205062:	6c8e                	ld	s9,192(sp)
    80205064:	6d2e                	ld	s10,200(sp)
    80205066:	6dce                	ld	s11,208(sp)
    80205068:	6e6e                	ld	t3,216(sp)
    8020506a:	7e8e                	ld	t4,224(sp)
    8020506c:	7f2e                	ld	t5,232(sp)
    8020506e:	7fce                	ld	t6,240(sp)
    80205070:	6111                	addi	sp,sp,256
    80205072:	10200073          	sret
	...

000000008020507e <timerinit>:
#include "include/proc.h"

struct spinlock tickslock;
uint ticks;

void timerinit() {
    8020507e:	1141                	addi	sp,sp,-16
    80205080:	e406                	sd	ra,8(sp)
    80205082:	e022                	sd	s0,0(sp)
    80205084:	0800                	addi	s0,sp,16
    initlock(&tickslock, "time");
    80205086:	00005597          	auipc	a1,0x5
    8020508a:	aa258593          	addi	a1,a1,-1374 # 80209b28 <etext+0xb28>
    8020508e:	00018517          	auipc	a0,0x18
    80205092:	37a50513          	addi	a0,a0,890 # 8021d408 <tickslock>
    80205096:	ffffb097          	auipc	ra,0xffffb
    8020509a:	616080e7          	jalr	1558(ra) # 802006ac <initlock>
    #ifdef DEBUG
    printf("timerinit\n");
    #endif
}
    8020509e:	60a2                	ld	ra,8(sp)
    802050a0:	6402                	ld	s0,0(sp)
    802050a2:	0141                	addi	sp,sp,16
    802050a4:	8082                	ret

00000000802050a6 <set_next_timeout>:

void
set_next_timeout() {
    802050a6:	1141                	addi	sp,sp,-16
    802050a8:	e422                	sd	s0,8(sp)
    802050aa:	0800                	addi	s0,sp,16
  asm volatile("rdtime %0" : "=r" (x) );
    802050ac:	c0102573          	rdtime	a0
    // if comment the `printf` line below
    // the timer will not work.

    // this bug seems to disappear automatically
    // printf("");
    sbi_set_timer(r_time() + INTERVAL);
    802050b0:	001dc7b7          	lui	a5,0x1dc
    802050b4:	13078793          	addi	a5,a5,304 # 1dc130 <_entry-0x80023ed0>
    802050b8:	953e                	add	a0,a0,a5
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
    802050ba:	4581                	li	a1,0
    802050bc:	4601                	li	a2,0
    802050be:	4681                	li	a3,0
    802050c0:	4881                	li	a7,0
    802050c2:	00000073          	ecall
}
    802050c6:	6422                	ld	s0,8(sp)
    802050c8:	0141                	addi	sp,sp,16
    802050ca:	8082                	ret

00000000802050cc <timer_tick>:

void timer_tick() {
    802050cc:	1101                	addi	sp,sp,-32
    802050ce:	ec06                	sd	ra,24(sp)
    802050d0:	e822                	sd	s0,16(sp)
    802050d2:	e426                	sd	s1,8(sp)
    802050d4:	1000                	addi	s0,sp,32
    acquire(&tickslock);
    802050d6:	00018497          	auipc	s1,0x18
    802050da:	33248493          	addi	s1,s1,818 # 8021d408 <tickslock>
    802050de:	8526                	mv	a0,s1
    802050e0:	ffffb097          	auipc	ra,0xffffb
    802050e4:	610080e7          	jalr	1552(ra) # 802006f0 <acquire>
    ticks++;
    802050e8:	00018517          	auipc	a0,0x18
    802050ec:	33850513          	addi	a0,a0,824 # 8021d420 <ticks>
    802050f0:	411c                	lw	a5,0(a0)
    802050f2:	2785                	addiw	a5,a5,1
    802050f4:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    802050f6:	ffffd097          	auipc	ra,0xffffd
    802050fa:	3c8080e7          	jalr	968(ra) # 802024be <wakeup>
    release(&tickslock);
    802050fe:	8526                	mv	a0,s1
    80205100:	ffffb097          	auipc	ra,0xffffb
    80205104:	644080e7          	jalr	1604(ra) # 80200744 <release>
    set_next_timeout();
    80205108:	00000097          	auipc	ra,0x0
    8020510c:	f9e080e7          	jalr	-98(ra) # 802050a6 <set_next_timeout>
}
    80205110:	60e2                	ld	ra,24(sp)
    80205112:	6442                	ld	s0,16(sp)
    80205114:	64a2                	ld	s1,8(sp)
    80205116:	6105                	addi	sp,sp,32
    80205118:	8082                	ret

000000008020511a <disk_init>:
#else
#include "include/virtio.h"
#endif 

void disk_init(void)
{
    8020511a:	1141                	addi	sp,sp,-16
    8020511c:	e406                	sd	ra,8(sp)
    8020511e:	e022                	sd	s0,0(sp)
    80205120:	0800                	addi	s0,sp,16
    #ifdef QEMU
    virtio_disk_init();
    80205122:	00002097          	auipc	ra,0x2
    80205126:	042080e7          	jalr	66(ra) # 80207164 <virtio_disk_init>
	#else 
	sdcard_init();
    #endif
}
    8020512a:	60a2                	ld	ra,8(sp)
    8020512c:	6402                	ld	s0,0(sp)
    8020512e:	0141                	addi	sp,sp,16
    80205130:	8082                	ret

0000000080205132 <disk_read>:

void disk_read(struct buf *b)
{
    80205132:	1141                	addi	sp,sp,-16
    80205134:	e406                	sd	ra,8(sp)
    80205136:	e022                	sd	s0,0(sp)
    80205138:	0800                	addi	s0,sp,16
    #ifdef QEMU
	virtio_disk_rw(b, 0);
    8020513a:	4581                	li	a1,0
    8020513c:	00002097          	auipc	ra,0x2
    80205140:	1b6080e7          	jalr	438(ra) # 802072f2 <virtio_disk_rw>
    #else 
	sdcard_read_sector(b->data, b->sectorno);
	#endif
}
    80205144:	60a2                	ld	ra,8(sp)
    80205146:	6402                	ld	s0,0(sp)
    80205148:	0141                	addi	sp,sp,16
    8020514a:	8082                	ret

000000008020514c <disk_write>:

void disk_write(struct buf *b)
{
    8020514c:	1141                	addi	sp,sp,-16
    8020514e:	e406                	sd	ra,8(sp)
    80205150:	e022                	sd	s0,0(sp)
    80205152:	0800                	addi	s0,sp,16
    #ifdef QEMU
	virtio_disk_rw(b, 1);
    80205154:	4585                	li	a1,1
    80205156:	00002097          	auipc	ra,0x2
    8020515a:	19c080e7          	jalr	412(ra) # 802072f2 <virtio_disk_rw>
    #else 
	sdcard_write_sector(b->data, b->sectorno);
	#endif
}
    8020515e:	60a2                	ld	ra,8(sp)
    80205160:	6402                	ld	s0,0(sp)
    80205162:	0141                	addi	sp,sp,16
    80205164:	8082                	ret

0000000080205166 <disk_intr>:

void disk_intr(void)
{
    80205166:	1141                	addi	sp,sp,-16
    80205168:	e406                	sd	ra,8(sp)
    8020516a:	e022                	sd	s0,0(sp)
    8020516c:	0800                	addi	s0,sp,16
    #ifdef QEMU
    virtio_disk_intr();
    8020516e:	00002097          	auipc	ra,0x2
    80205172:	412080e7          	jalr	1042(ra) # 80207580 <virtio_disk_intr>
    #else 
    dmac_intr(DMAC_CHANNEL0);
    #endif
}
    80205176:	60a2                	ld	ra,8(sp)
    80205178:	6402                	ld	s0,0(sp)
    8020517a:	0141                	addi	sp,sp,16
    8020517c:	8082                	ret

000000008020517e <filename_equal>:
    return tot;
}

static int
filename_equal(const char *a, const char *b)
{
    8020517e:	1141                	addi	sp,sp,-16
    80205180:	e422                	sd	s0,8(sp)
    80205182:	0800                	addi	s0,sp,16
    for (int i = 0; i <= FAT32_MAX_FILENAME; i++) {
    80205184:	862a                	mv	a2,a0
    80205186:	10050513          	addi	a0,a0,256
        uchar ca = a[i];
        uchar cb = b[i];
        if (ca >= 'a' && ca <= 'z') ca -= 'a' - 'A';
    8020518a:	4865                	li	a6,25
    8020518c:	a801                	j	8020519c <filename_equal+0x1e>
        if (cb >= 'a' && cb <= 'z') cb -= 'a' - 'A';
        if (ca != cb) return 0;
    8020518e:	04f71363          	bne	a4,a5,802051d4 <filename_equal+0x56>
        if (ca == 0) return 1;
    80205192:	c3b9                	beqz	a5,802051d8 <filename_equal+0x5a>
    for (int i = 0; i <= FAT32_MAX_FILENAME; i++) {
    80205194:	0605                	addi	a2,a2,1 # 1001 <_entry-0x801fefff>
    80205196:	0585                	addi	a1,a1,1
    80205198:	02a60c63          	beq	a2,a0,802051d0 <filename_equal+0x52>
        uchar ca = a[i];
    8020519c:	00064703          	lbu	a4,0(a2)
        uchar cb = b[i];
    802051a0:	0005c783          	lbu	a5,0(a1)
        if (ca >= 'a' && ca <= 'z') ca -= 'a' - 'A';
    802051a4:	f9f7069b          	addiw	a3,a4,-97
    802051a8:	0ff6f693          	zext.b	a3,a3
    802051ac:	00d86563          	bltu	a6,a3,802051b6 <filename_equal+0x38>
    802051b0:	3701                	addiw	a4,a4,-32
    802051b2:	0ff77713          	zext.b	a4,a4
        if (cb >= 'a' && cb <= 'z') cb -= 'a' - 'A';
    802051b6:	f9f7869b          	addiw	a3,a5,-97
    802051ba:	0ff6f693          	zext.b	a3,a3
    802051be:	fcd868e3          	bltu	a6,a3,8020518e <filename_equal+0x10>
    802051c2:	3781                	addiw	a5,a5,-32
        if (ca != cb) return 0;
    802051c4:	0ff7f793          	zext.b	a5,a5
    802051c8:	fcf706e3          	beq	a4,a5,80205194 <filename_equal+0x16>
    802051cc:	4501                	li	a0,0
    802051ce:	a031                	j	802051da <filename_equal+0x5c>
    }
    return 1;
    802051d0:	4505                	li	a0,1
    802051d2:	a021                	j	802051da <filename_equal+0x5c>
        if (ca != cb) return 0;
    802051d4:	4501                	li	a0,0
    802051d6:	a011                	j	802051da <filename_equal+0x5c>
        if (ca == 0) return 1;
    802051d8:	4505                	li	a0,1
}
    802051da:	6422                	ld	s0,8(sp)
    802051dc:	0141                	addi	sp,sp,16
    802051de:	8082                	ret

00000000802051e0 <read_fat>:
{
    802051e0:	1101                	addi	sp,sp,-32
    802051e2:	ec06                	sd	ra,24(sp)
    802051e4:	e822                	sd	s0,16(sp)
    802051e6:	e426                	sd	s1,8(sp)
    802051e8:	1000                	addi	s0,sp,32
    if (cluster >= FAT32_EOC) {
    802051ea:	100007b7          	lui	a5,0x10000
    802051ee:	17dd                	addi	a5,a5,-9 # ffffff7 <_entry-0x70200009>
        return cluster;
    802051f0:	84aa                	mv	s1,a0
    if (cluster >= FAT32_EOC) {
    802051f2:	00a7ea63          	bltu	a5,a0,80205206 <read_fat+0x26>
    if (cluster > fat.data_clus_cnt + 1) {     // because cluster number starts at 2, not 0
    802051f6:	00018797          	auipc	a5,0x18
    802051fa:	23a7a783          	lw	a5,570(a5) # 8021d430 <fat+0x8>
    802051fe:	2785                	addiw	a5,a5,1
        return 0;
    80205200:	4481                	li	s1,0
    if (cluster > fat.data_clus_cnt + 1) {     // because cluster number starts at 2, not 0
    80205202:	00a7f863          	bgeu	a5,a0,80205212 <read_fat+0x32>
}
    80205206:	8526                	mv	a0,s1
    80205208:	60e2                	ld	ra,24(sp)
    8020520a:	6442                	ld	s0,16(sp)
    8020520c:	64a2                	ld	s1,8(sp)
    8020520e:	6105                	addi	sp,sp,32
    80205210:	8082                	ret
    80205212:	e04a                	sd	s2,0(sp)
    return fat.bpb.rsvd_sec_cnt + (cluster << 2) / fat.bpb.byts_per_sec + fat.bpb.fat_sz * (fat_num - 1);
    80205214:	0025149b          	slliw	s1,a0,0x2
    80205218:	00018917          	auipc	s2,0x18
    8020521c:	21090913          	addi	s2,s2,528 # 8021d428 <fat>
    80205220:	01095783          	lhu	a5,16(s2)
    80205224:	02f4d7bb          	divuw	a5,s1,a5
    80205228:	01495583          	lhu	a1,20(s2)
    struct buf *b = bread(0, fat_sec);
    8020522c:	9dbd                	addw	a1,a1,a5
    8020522e:	4501                	li	a0,0
    80205230:	ffffe097          	auipc	ra,0xffffe
    80205234:	1e4080e7          	jalr	484(ra) # 80203414 <bread>
    return (cluster << 2) % fat.bpb.byts_per_sec;
    80205238:	01095783          	lhu	a5,16(s2)
    8020523c:	02f4f4bb          	remuw	s1,s1,a5
    uint32 next_clus = *(uint32 *)(b->data + fat_offset_of_clus(cluster));
    80205240:	1482                	slli	s1,s1,0x20
    80205242:	9081                	srli	s1,s1,0x20
    80205244:	009507b3          	add	a5,a0,s1
    80205248:	4fa4                	lw	s1,88(a5)
    brelse(b);
    8020524a:	ffffe097          	auipc	ra,0xffffe
    8020524e:	2f6080e7          	jalr	758(ra) # 80203540 <brelse>
    return next_clus;
    80205252:	6902                	ld	s2,0(sp)
    80205254:	bf4d                	j	80205206 <read_fat+0x26>

0000000080205256 <alloc_clus>:
{
    80205256:	711d                	addi	sp,sp,-96
    80205258:	ec86                	sd	ra,88(sp)
    8020525a:	e8a2                	sd	s0,80(sp)
    8020525c:	e4a6                	sd	s1,72(sp)
    8020525e:	e0ca                	sd	s2,64(sp)
    80205260:	fc4e                	sd	s3,56(sp)
    80205262:	f852                	sd	s4,48(sp)
    80205264:	f456                	sd	s5,40(sp)
    80205266:	f05a                	sd	s6,32(sp)
    80205268:	ec5e                	sd	s7,24(sp)
    8020526a:	e862                	sd	s8,16(sp)
    8020526c:	e466                	sd	s9,8(sp)
    8020526e:	1080                	addi	s0,sp,96
    uint32 sec = fat.bpb.rsvd_sec_cnt;
    80205270:	00018797          	auipc	a5,0x18
    80205274:	1b878793          	addi	a5,a5,440 # 8021d428 <fat>
    80205278:	0147db83          	lhu	s7,20(a5)
    uint32 const ent_per_sec = fat.bpb.byts_per_sec / sizeof(uint32);
    8020527c:	0107d903          	lhu	s2,16(a5)
    for (uint32 i = 0; i < fat.bpb.fat_sz; i++, sec++) {
    80205280:	539c                	lw	a5,32(a5)
    80205282:	10078263          	beqz	a5,80205386 <alloc_clus+0x130>
    80205286:	0029591b          	srliw	s2,s2,0x2
    8020528a:	0009099b          	sext.w	s3,s2
    8020528e:	4b01                	li	s6,0
        b = bread(dev, sec);
    80205290:	00050a9b          	sext.w	s5,a0
        for (uint32 j = 0; j < ent_per_sec; j++) {
    80205294:	4c01                	li	s8,0
    for (uint32 i = 0; i < fat.bpb.fat_sz; i++, sec++) {
    80205296:	00018c97          	auipc	s9,0x18
    8020529a:	192c8c93          	addi	s9,s9,402 # 8021d428 <fat>
    8020529e:	a0c9                	j	80205360 <alloc_clus+0x10a>
                ((uint32 *)(b->data))[j] = FAT32_EOC + 7;
    802052a0:	10000737          	lui	a4,0x10000
    802052a4:	177d                	addi	a4,a4,-1 # fffffff <_entry-0x70200001>
    802052a6:	c398                	sw	a4,0(a5)
                bwrite(b);
    802052a8:	8552                	mv	a0,s4
    802052aa:	ffffe097          	auipc	ra,0xffffe
    802052ae:	25a080e7          	jalr	602(ra) # 80203504 <bwrite>
                brelse(b);
    802052b2:	8552                	mv	a0,s4
    802052b4:	ffffe097          	auipc	ra,0xffffe
    802052b8:	28c080e7          	jalr	652(ra) # 80203540 <brelse>
                uint32 clus = i * ent_per_sec + j;
    802052bc:	0369093b          	mulw	s2,s2,s6
    802052c0:	0099093b          	addw	s2,s2,s1
    802052c4:	00090a9b          	sext.w	s5,s2
    return ((cluster - 2) * fat.bpb.sec_per_clus) + fat.first_data_sec;
    802052c8:	00018717          	auipc	a4,0x18
    802052cc:	16070713          	addi	a4,a4,352 # 8021d428 <fat>
    802052d0:	01274783          	lbu	a5,18(a4)
    802052d4:	ffe9099b          	addiw	s3,s2,-2
    802052d8:	02f989bb          	mulw	s3,s3,a5
    802052dc:	4318                	lw	a4,0(a4)
    802052de:	00e989bb          	addw	s3,s3,a4
    for (int i = 0; i < fat.bpb.sec_per_clus; i++) {
    802052e2:	c7b1                	beqz	a5,8020532e <alloc_clus+0xd8>
    802052e4:	4901                	li	s2,0
    802052e6:	00018a17          	auipc	s4,0x18
    802052ea:	142a0a13          	addi	s4,s4,322 # 8021d428 <fat>
        b = bread(0, sec++);
    802052ee:	013905bb          	addw	a1,s2,s3
    802052f2:	4501                	li	a0,0
    802052f4:	ffffe097          	auipc	ra,0xffffe
    802052f8:	120080e7          	jalr	288(ra) # 80203414 <bread>
    802052fc:	84aa                	mv	s1,a0
        memset(b->data, 0, BSIZE);
    802052fe:	20000613          	li	a2,512
    80205302:	4581                	li	a1,0
    80205304:	05850513          	addi	a0,a0,88
    80205308:	ffffb097          	auipc	ra,0xffffb
    8020530c:	484080e7          	jalr	1156(ra) # 8020078c <memset>
        bwrite(b);
    80205310:	8526                	mv	a0,s1
    80205312:	ffffe097          	auipc	ra,0xffffe
    80205316:	1f2080e7          	jalr	498(ra) # 80203504 <bwrite>
        brelse(b);
    8020531a:	8526                	mv	a0,s1
    8020531c:	ffffe097          	auipc	ra,0xffffe
    80205320:	224080e7          	jalr	548(ra) # 80203540 <brelse>
    for (int i = 0; i < fat.bpb.sec_per_clus; i++) {
    80205324:	2905                	addiw	s2,s2,1
    80205326:	012a4783          	lbu	a5,18(s4)
    8020532a:	fcf942e3          	blt	s2,a5,802052ee <alloc_clus+0x98>
}
    8020532e:	8556                	mv	a0,s5
    80205330:	60e6                	ld	ra,88(sp)
    80205332:	6446                	ld	s0,80(sp)
    80205334:	64a6                	ld	s1,72(sp)
    80205336:	6906                	ld	s2,64(sp)
    80205338:	79e2                	ld	s3,56(sp)
    8020533a:	7a42                	ld	s4,48(sp)
    8020533c:	7aa2                	ld	s5,40(sp)
    8020533e:	7b02                	ld	s6,32(sp)
    80205340:	6be2                	ld	s7,24(sp)
    80205342:	6c42                	ld	s8,16(sp)
    80205344:	6ca2                	ld	s9,8(sp)
    80205346:	6125                	addi	sp,sp,96
    80205348:	8082                	ret
        brelse(b);
    8020534a:	8552                	mv	a0,s4
    8020534c:	ffffe097          	auipc	ra,0xffffe
    80205350:	1f4080e7          	jalr	500(ra) # 80203540 <brelse>
    for (uint32 i = 0; i < fat.bpb.fat_sz; i++, sec++) {
    80205354:	2b05                	addiw	s6,s6,1
    80205356:	2b85                	addiw	s7,s7,1
    80205358:	020ca783          	lw	a5,32(s9)
    8020535c:	02fb7563          	bgeu	s6,a5,80205386 <alloc_clus+0x130>
        b = bread(dev, sec);
    80205360:	85de                	mv	a1,s7
    80205362:	8556                	mv	a0,s5
    80205364:	ffffe097          	auipc	ra,0xffffe
    80205368:	0b0080e7          	jalr	176(ra) # 80203414 <bread>
    8020536c:	8a2a                	mv	s4,a0
        for (uint32 j = 0; j < ent_per_sec; j++) {
    8020536e:	fc098ee3          	beqz	s3,8020534a <alloc_clus+0xf4>
    80205372:	05850793          	addi	a5,a0,88
    80205376:	84e2                	mv	s1,s8
            if (((uint32 *)(b->data))[j] == 0) {
    80205378:	4398                	lw	a4,0(a5)
    8020537a:	d31d                	beqz	a4,802052a0 <alloc_clus+0x4a>
        for (uint32 j = 0; j < ent_per_sec; j++) {
    8020537c:	2485                	addiw	s1,s1,1
    8020537e:	0791                	addi	a5,a5,4
    80205380:	fe999ce3          	bne	s3,s1,80205378 <alloc_clus+0x122>
    80205384:	b7d9                	j	8020534a <alloc_clus+0xf4>
    panic("no clusters");
    80205386:	00004517          	auipc	a0,0x4
    8020538a:	7aa50513          	addi	a0,a0,1962 # 80209b30 <etext+0xb30>
    8020538e:	ffffb097          	auipc	ra,0xffffb
    80205392:	db8080e7          	jalr	-584(ra) # 80200146 <panic>

0000000080205396 <write_fat>:
    if (cluster > fat.data_clus_cnt + 1) {
    80205396:	00018797          	auipc	a5,0x18
    8020539a:	09a7a783          	lw	a5,154(a5) # 8021d430 <fat+0x8>
    8020539e:	2785                	addiw	a5,a5,1
    802053a0:	06a7e963          	bltu	a5,a0,80205412 <write_fat+0x7c>
{
    802053a4:	7179                	addi	sp,sp,-48
    802053a6:	f406                	sd	ra,40(sp)
    802053a8:	f022                	sd	s0,32(sp)
    802053aa:	ec26                	sd	s1,24(sp)
    802053ac:	e84a                	sd	s2,16(sp)
    802053ae:	e44e                	sd	s3,8(sp)
    802053b0:	e052                	sd	s4,0(sp)
    802053b2:	1800                	addi	s0,sp,48
    802053b4:	89ae                	mv	s3,a1
    return fat.bpb.rsvd_sec_cnt + (cluster << 2) / fat.bpb.byts_per_sec + fat.bpb.fat_sz * (fat_num - 1);
    802053b6:	0025149b          	slliw	s1,a0,0x2
    802053ba:	00018a17          	auipc	s4,0x18
    802053be:	06ea0a13          	addi	s4,s4,110 # 8021d428 <fat>
    802053c2:	010a5783          	lhu	a5,16(s4)
    802053c6:	02f4d7bb          	divuw	a5,s1,a5
    802053ca:	014a5583          	lhu	a1,20(s4)
    struct buf *b = bread(0, fat_sec);
    802053ce:	9dbd                	addw	a1,a1,a5
    802053d0:	4501                	li	a0,0
    802053d2:	ffffe097          	auipc	ra,0xffffe
    802053d6:	042080e7          	jalr	66(ra) # 80203414 <bread>
    802053da:	892a                	mv	s2,a0
    return (cluster << 2) % fat.bpb.byts_per_sec;
    802053dc:	010a5783          	lhu	a5,16(s4)
    802053e0:	02f4f4bb          	remuw	s1,s1,a5
    *(uint32 *)(b->data + off) = content;
    802053e4:	1482                	slli	s1,s1,0x20
    802053e6:	9081                	srli	s1,s1,0x20
    802053e8:	94aa                	add	s1,s1,a0
    802053ea:	0534ac23          	sw	s3,88(s1)
    bwrite(b);
    802053ee:	ffffe097          	auipc	ra,0xffffe
    802053f2:	116080e7          	jalr	278(ra) # 80203504 <bwrite>
    brelse(b);
    802053f6:	854a                	mv	a0,s2
    802053f8:	ffffe097          	auipc	ra,0xffffe
    802053fc:	148080e7          	jalr	328(ra) # 80203540 <brelse>
    return 0;
    80205400:	4501                	li	a0,0
}
    80205402:	70a2                	ld	ra,40(sp)
    80205404:	7402                	ld	s0,32(sp)
    80205406:	64e2                	ld	s1,24(sp)
    80205408:	6942                	ld	s2,16(sp)
    8020540a:	69a2                	ld	s3,8(sp)
    8020540c:	6a02                	ld	s4,0(sp)
    8020540e:	6145                	addi	sp,sp,48
    80205410:	8082                	ret
        return -1;
    80205412:	557d                	li	a0,-1
}
    80205414:	8082                	ret

0000000080205416 <reloc_clus>:
{
    80205416:	715d                	addi	sp,sp,-80
    80205418:	e486                	sd	ra,72(sp)
    8020541a:	e0a2                	sd	s0,64(sp)
    8020541c:	fc26                	sd	s1,56(sp)
    8020541e:	f84a                	sd	s2,48(sp)
    80205420:	f44e                	sd	s3,40(sp)
    80205422:	f052                	sd	s4,32(sp)
    80205424:	e45e                	sd	s7,8(sp)
    80205426:	0880                	addi	s0,sp,80
    80205428:	84aa                	mv	s1,a0
    8020542a:	8a2e                	mv	s4,a1
    int clus_num = off / fat.byts_per_clus;
    8020542c:	00018b97          	auipc	s7,0x18
    80205430:	008bab83          	lw	s7,8(s7) # 8021d434 <fat+0xc>
    80205434:	0375d9bb          	divuw	s3,a1,s7
    while (clus_num > entry->clus_cnt) {
    80205438:	11052703          	lw	a4,272(a0)
    8020543c:	07377b63          	bgeu	a4,s3,802054b2 <reloc_clus+0x9c>
    80205440:	ec56                	sd	s5,24(sp)
    80205442:	e85a                	sd	s6,16(sp)
    80205444:	8b32                	mv	s6,a2
        if (clus >= FAT32_EOC) {
    80205446:	10000ab7          	lui	s5,0x10000
    8020544a:	1add                	addi	s5,s5,-9 # ffffff7 <_entry-0x70200009>
    8020544c:	a81d                	j	80205482 <reloc_clus+0x6c>
                clus = alloc_clus(entry->dev);
    8020544e:	1144c503          	lbu	a0,276(s1)
    80205452:	00000097          	auipc	ra,0x0
    80205456:	e04080e7          	jalr	-508(ra) # 80205256 <alloc_clus>
    8020545a:	0005091b          	sext.w	s2,a0
                write_fat(entry->cur_clus, clus);
    8020545e:	85ca                	mv	a1,s2
    80205460:	10c4a503          	lw	a0,268(s1)
    80205464:	00000097          	auipc	ra,0x0
    80205468:	f32080e7          	jalr	-206(ra) # 80205396 <write_fat>
        entry->cur_clus = clus;
    8020546c:	1124a623          	sw	s2,268(s1)
        entry->clus_cnt++;
    80205470:	1104a783          	lw	a5,272(s1)
    80205474:	2785                	addiw	a5,a5,1
    80205476:	0007871b          	sext.w	a4,a5
    8020547a:	10f4a823          	sw	a5,272(s1)
    while (clus_num > entry->clus_cnt) {
    8020547e:	03377863          	bgeu	a4,s3,802054ae <reloc_clus+0x98>
        int clus = read_fat(entry->cur_clus);
    80205482:	10c4a503          	lw	a0,268(s1)
    80205486:	00000097          	auipc	ra,0x0
    8020548a:	d5a080e7          	jalr	-678(ra) # 802051e0 <read_fat>
    8020548e:	0005091b          	sext.w	s2,a0
        if (clus >= FAT32_EOC) {
    80205492:	fd2adde3          	bge	s5,s2,8020546c <reloc_clus+0x56>
            if (alloc) {
    80205496:	fa0b1ce3          	bnez	s6,8020544e <reloc_clus+0x38>
                entry->cur_clus = entry->first_clus;
    8020549a:	1044a783          	lw	a5,260(s1)
    8020549e:	10f4a623          	sw	a5,268(s1)
                entry->clus_cnt = 0;
    802054a2:	1004a823          	sw	zero,272(s1)
                return -1;
    802054a6:	557d                	li	a0,-1
    802054a8:	6ae2                	ld	s5,24(sp)
    802054aa:	6b42                	ld	s6,16(sp)
    802054ac:	a891                	j	80205500 <reloc_clus+0xea>
    802054ae:	6ae2                	ld	s5,24(sp)
    802054b0:	6b42                	ld	s6,16(sp)
    if (clus_num < entry->clus_cnt) {
    802054b2:	04e9f163          	bgeu	s3,a4,802054f4 <reloc_clus+0xde>
        entry->cur_clus = entry->first_clus;
    802054b6:	1044a783          	lw	a5,260(s1)
    802054ba:	10f4a623          	sw	a5,268(s1)
        entry->clus_cnt = 0;
    802054be:	1004a823          	sw	zero,272(s1)
        while (entry->clus_cnt < clus_num) {
    802054c2:	037a6963          	bltu	s4,s7,802054f4 <reloc_clus+0xde>
            if (entry->cur_clus >= FAT32_EOC) {
    802054c6:	10000937          	lui	s2,0x10000
    802054ca:	195d                	addi	s2,s2,-9 # ffffff7 <_entry-0x70200009>
            entry->cur_clus = read_fat(entry->cur_clus);
    802054cc:	10c4a503          	lw	a0,268(s1)
    802054d0:	00000097          	auipc	ra,0x0
    802054d4:	d10080e7          	jalr	-752(ra) # 802051e0 <read_fat>
    802054d8:	2501                	sext.w	a0,a0
    802054da:	10a4a623          	sw	a0,268(s1)
            if (entry->cur_clus >= FAT32_EOC) {
    802054de:	02a96a63          	bltu	s2,a0,80205512 <reloc_clus+0xfc>
            entry->clus_cnt++;
    802054e2:	1104a783          	lw	a5,272(s1)
    802054e6:	2785                	addiw	a5,a5,1
    802054e8:	0007871b          	sext.w	a4,a5
    802054ec:	10f4a823          	sw	a5,272(s1)
        while (entry->clus_cnt < clus_num) {
    802054f0:	fd376ee3          	bltu	a4,s3,802054cc <reloc_clus+0xb6>
    return off % fat.byts_per_clus;
    802054f4:	00018797          	auipc	a5,0x18
    802054f8:	f407a783          	lw	a5,-192(a5) # 8021d434 <fat+0xc>
    802054fc:	02fa753b          	remuw	a0,s4,a5
}
    80205500:	60a6                	ld	ra,72(sp)
    80205502:	6406                	ld	s0,64(sp)
    80205504:	74e2                	ld	s1,56(sp)
    80205506:	7942                	ld	s2,48(sp)
    80205508:	79a2                	ld	s3,40(sp)
    8020550a:	7a02                	ld	s4,32(sp)
    8020550c:	6ba2                	ld	s7,8(sp)
    8020550e:	6161                	addi	sp,sp,80
    80205510:	8082                	ret
    80205512:	ec56                	sd	s5,24(sp)
    80205514:	e85a                	sd	s6,16(sp)
                panic("reloc_clus");
    80205516:	00004517          	auipc	a0,0x4
    8020551a:	62a50513          	addi	a0,a0,1578 # 80209b40 <etext+0xb40>
    8020551e:	ffffb097          	auipc	ra,0xffffb
    80205522:	c28080e7          	jalr	-984(ra) # 80200146 <panic>

0000000080205526 <rw_clus>:
{
    80205526:	7119                	addi	sp,sp,-128
    80205528:	fc86                	sd	ra,120(sp)
    8020552a:	f8a2                	sd	s0,112(sp)
    8020552c:	e0da                	sd	s6,64(sp)
    8020552e:	f862                	sd	s8,48(sp)
    80205530:	0100                	addi	s0,sp,128
    80205532:	f8c43423          	sd	a2,-120(s0)
    80205536:	8b36                	mv	s6,a3
    80205538:	8c3e                	mv	s8,a5
    if (off + n > fat.byts_per_clus)
    8020553a:	00f706bb          	addw	a3,a4,a5
    8020553e:	00018797          	auipc	a5,0x18
    80205542:	ef67a783          	lw	a5,-266(a5) # 8021d434 <fat+0xc>
    80205546:	04d7ea63          	bltu	a5,a3,8020559a <rw_clus+0x74>
    8020554a:	ecce                	sd	s3,88(sp)
    8020554c:	e8d2                	sd	s4,80(sp)
    8020554e:	e4d6                	sd	s5,72(sp)
    80205550:	f466                	sd	s9,40(sp)
    80205552:	8cae                	mv	s9,a1
    uint sec = first_sec_of_clus(cluster) + off / fat.bpb.byts_per_sec;
    80205554:	00018797          	auipc	a5,0x18
    80205558:	ed478793          	addi	a5,a5,-300 # 8021d428 <fat>
    8020555c:	0107d683          	lhu	a3,16(a5)
    return ((cluster - 2) * fat.bpb.sec_per_clus) + fat.first_data_sec;
    80205560:	ffe5099b          	addiw	s3,a0,-2
    80205564:	0127c603          	lbu	a2,18(a5)
    80205568:	02c989bb          	mulw	s3,s3,a2
    8020556c:	439c                	lw	a5,0(a5)
    8020556e:	00f989bb          	addw	s3,s3,a5
    uint sec = first_sec_of_clus(cluster) + off / fat.bpb.byts_per_sec;
    80205572:	02d757bb          	divuw	a5,a4,a3
    80205576:	00f989bb          	addw	s3,s3,a5
    off = off % fat.bpb.byts_per_sec;
    8020557a:	02d7773b          	remuw	a4,a4,a3
    8020557e:	00070a9b          	sext.w	s5,a4
    for (tot = 0; tot < n; tot += m, off += m, data += m, sec++) {
    80205582:	100c0763          	beqz	s8,80205690 <rw_clus+0x16a>
    80205586:	f4a6                	sd	s1,104(sp)
    80205588:	f0ca                	sd	s2,96(sp)
    8020558a:	fc5e                	sd	s7,56(sp)
    8020558c:	f06a                	sd	s10,32(sp)
    8020558e:	ec6e                	sd	s11,24(sp)
    80205590:	4a01                	li	s4,0
        m = BSIZE - off % BSIZE;
    80205592:	20000d93          	li	s11,512
        if (bad == -1) {
    80205596:	5d7d                	li	s10,-1
    80205598:	a89d                	j	8020560e <rw_clus+0xe8>
    8020559a:	f4a6                	sd	s1,104(sp)
    8020559c:	f0ca                	sd	s2,96(sp)
    8020559e:	ecce                	sd	s3,88(sp)
    802055a0:	e8d2                	sd	s4,80(sp)
    802055a2:	e4d6                	sd	s5,72(sp)
    802055a4:	fc5e                	sd	s7,56(sp)
    802055a6:	f466                	sd	s9,40(sp)
    802055a8:	f06a                	sd	s10,32(sp)
    802055aa:	ec6e                	sd	s11,24(sp)
        panic("offset out of range");
    802055ac:	00004517          	auipc	a0,0x4
    802055b0:	5a450513          	addi	a0,a0,1444 # 80209b50 <etext+0xb50>
    802055b4:	ffffb097          	auipc	ra,0xffffb
    802055b8:	b92080e7          	jalr	-1134(ra) # 80200146 <panic>
                bwrite(bp);
    802055bc:	854a                	mv	a0,s2
    802055be:	ffffe097          	auipc	ra,0xffffe
    802055c2:	f46080e7          	jalr	-186(ra) # 80203504 <bwrite>
        brelse(bp);
    802055c6:	854a                	mv	a0,s2
    802055c8:	ffffe097          	auipc	ra,0xffffe
    802055cc:	f78080e7          	jalr	-136(ra) # 80203540 <brelse>
        if (bad == -1) {
    802055d0:	a02d                	j	802055fa <rw_clus+0xd4>
            bad = either_copyout(user, data, bp->data + (off % BSIZE), m);
    802055d2:	05890613          	addi	a2,s2,88
    802055d6:	1682                	slli	a3,a3,0x20
    802055d8:	9281                	srli	a3,a3,0x20
    802055da:	963a                	add	a2,a2,a4
    802055dc:	85da                	mv	a1,s6
    802055de:	f8843503          	ld	a0,-120(s0)
    802055e2:	ffffd097          	auipc	ra,0xffffd
    802055e6:	fb6080e7          	jalr	-74(ra) # 80202598 <either_copyout>
    802055ea:	8baa                	mv	s7,a0
        brelse(bp);
    802055ec:	854a                	mv	a0,s2
    802055ee:	ffffe097          	auipc	ra,0xffffe
    802055f2:	f52080e7          	jalr	-174(ra) # 80203540 <brelse>
        if (bad == -1) {
    802055f6:	09ab8f63          	beq	s7,s10,80205694 <rw_clus+0x16e>
    for (tot = 0; tot < n; tot += m, off += m, data += m, sec++) {
    802055fa:	01448a3b          	addw	s4,s1,s4
    802055fe:	01548abb          	addw	s5,s1,s5
    80205602:	1482                	slli	s1,s1,0x20
    80205604:	9081                	srli	s1,s1,0x20
    80205606:	9b26                	add	s6,s6,s1
    80205608:	2985                	addiw	s3,s3,1
    8020560a:	078a7d63          	bgeu	s4,s8,80205684 <rw_clus+0x15e>
        bp = bread(0, sec);
    8020560e:	85ce                	mv	a1,s3
    80205610:	4501                	li	a0,0
    80205612:	ffffe097          	auipc	ra,0xffffe
    80205616:	e02080e7          	jalr	-510(ra) # 80203414 <bread>
    8020561a:	892a                	mv	s2,a0
        m = BSIZE - off % BSIZE;
    8020561c:	1ffaf713          	andi	a4,s5,511
        if (n - tot < m) {
    80205620:	414c07bb          	subw	a5,s8,s4
        m = BSIZE - off % BSIZE;
    80205624:	40ed863b          	subw	a2,s11,a4
        if (n - tot < m) {
    80205628:	86be                	mv	a3,a5
    8020562a:	2781                	sext.w	a5,a5
    8020562c:	0006059b          	sext.w	a1,a2
    80205630:	00f5f363          	bgeu	a1,a5,80205636 <rw_clus+0x110>
    80205634:	86b2                	mv	a3,a2
    80205636:	0006849b          	sext.w	s1,a3
        if (write) {
    8020563a:	f80c8ce3          	beqz	s9,802055d2 <rw_clus+0xac>
            if ((bad = either_copyin(bp->data + (off % BSIZE), user, data, m)) != -1) {
    8020563e:	05890513          	addi	a0,s2,88
    80205642:	1682                	slli	a3,a3,0x20
    80205644:	9281                	srli	a3,a3,0x20
    80205646:	865a                	mv	a2,s6
    80205648:	f8843583          	ld	a1,-120(s0)
    8020564c:	953a                	add	a0,a0,a4
    8020564e:	ffffd097          	auipc	ra,0xffffd
    80205652:	f80080e7          	jalr	-128(ra) # 802025ce <either_copyin>
    80205656:	f7a513e3          	bne	a0,s10,802055bc <rw_clus+0x96>
        brelse(bp);
    8020565a:	854a                	mv	a0,s2
    8020565c:	ffffe097          	auipc	ra,0xffffe
    80205660:	ee4080e7          	jalr	-284(ra) # 80203540 <brelse>
    80205664:	74a6                	ld	s1,104(sp)
    80205666:	7906                	ld	s2,96(sp)
    80205668:	7be2                	ld	s7,56(sp)
    8020566a:	7d02                	ld	s10,32(sp)
    8020566c:	6de2                	ld	s11,24(sp)
}
    8020566e:	8552                	mv	a0,s4
    80205670:	69e6                	ld	s3,88(sp)
    80205672:	6a46                	ld	s4,80(sp)
    80205674:	6aa6                	ld	s5,72(sp)
    80205676:	7ca2                	ld	s9,40(sp)
    80205678:	70e6                	ld	ra,120(sp)
    8020567a:	7446                	ld	s0,112(sp)
    8020567c:	6b06                	ld	s6,64(sp)
    8020567e:	7c42                	ld	s8,48(sp)
    80205680:	6109                	addi	sp,sp,128
    80205682:	8082                	ret
    80205684:	74a6                	ld	s1,104(sp)
    80205686:	7906                	ld	s2,96(sp)
    80205688:	7be2                	ld	s7,56(sp)
    8020568a:	7d02                	ld	s10,32(sp)
    8020568c:	6de2                	ld	s11,24(sp)
    8020568e:	b7c5                	j	8020566e <rw_clus+0x148>
    for (tot = 0; tot < n; tot += m, off += m, data += m, sec++) {
    80205690:	8a62                	mv	s4,s8
    80205692:	bff1                	j	8020566e <rw_clus+0x148>
    80205694:	74a6                	ld	s1,104(sp)
    80205696:	7906                	ld	s2,96(sp)
    80205698:	7be2                	ld	s7,56(sp)
    8020569a:	7d02                	ld	s10,32(sp)
    8020569c:	6de2                	ld	s11,24(sp)
    8020569e:	bfc1                	j	8020566e <rw_clus+0x148>

00000000802056a0 <eget>:
// by their whole path. But when parsing a path, we open all the directories through it, 
// which forms a linked list from the final file to the root. Thus, we use the "parent" pointer 
// to recognize whether an entry with the "name" as given is really the file we want in the right path.
// Should never get root by eget, it's easy to understand.
static struct dirent *eget(struct dirent *parent, char *name)
{
    802056a0:	7139                	addi	sp,sp,-64
    802056a2:	fc06                	sd	ra,56(sp)
    802056a4:	f822                	sd	s0,48(sp)
    802056a6:	f426                	sd	s1,40(sp)
    802056a8:	e852                	sd	s4,16(sp)
    802056aa:	e456                	sd	s5,8(sp)
    802056ac:	0080                	addi	s0,sp,64
    802056ae:	8a2a                	mv	s4,a0
    802056b0:	8aae                	mv	s5,a1
    struct dirent *ep;
    acquire(&ecache.lock);
    802056b2:	00018517          	auipc	a0,0x18
    802056b6:	f0650513          	addi	a0,a0,-250 # 8021d5b8 <ecache>
    802056ba:	ffffb097          	auipc	ra,0xffffb
    802056be:	036080e7          	jalr	54(ra) # 802006f0 <acquire>
    if (name) {
    802056c2:	060a8d63          	beqz	s5,8020573c <eget+0x9c>
        for (ep = root.next; ep != &root; ep = ep->next) {          // LRU algo
    802056c6:	00018497          	auipc	s1,0x18
    802056ca:	eb24b483          	ld	s1,-334(s1) # 8021d578 <root+0x128>
    802056ce:	00018797          	auipc	a5,0x18
    802056d2:	d8278793          	addi	a5,a5,-638 # 8021d450 <root>
    802056d6:	06f48363          	beq	s1,a5,8020573c <eget+0x9c>
    802056da:	f04a                	sd	s2,32(sp)
    802056dc:	ec4e                	sd	s3,24(sp)
            if (ep->valid == 1 && ep->parent == parent
    802056de:	4905                	li	s2,1
        for (ep = root.next; ep != &root; ep = ep->next) {          // LRU algo
    802056e0:	89be                	mv	s3,a5
    802056e2:	a029                	j	802056ec <eget+0x4c>
    802056e4:	1284b483          	ld	s1,296(s1)
    802056e8:	05348863          	beq	s1,s3,80205738 <eget+0x98>
            if (ep->valid == 1 && ep->parent == parent
    802056ec:	11649783          	lh	a5,278(s1)
    802056f0:	ff279ae3          	bne	a5,s2,802056e4 <eget+0x44>
    802056f4:	1204b783          	ld	a5,288(s1)
    802056f8:	ff4796e3          	bne	a5,s4,802056e4 <eget+0x44>
                && filename_equal(ep->filename, name)) {
    802056fc:	85d6                	mv	a1,s5
    802056fe:	8526                	mv	a0,s1
    80205700:	00000097          	auipc	ra,0x0
    80205704:	a7e080e7          	jalr	-1410(ra) # 8020517e <filename_equal>
    80205708:	dd71                	beqz	a0,802056e4 <eget+0x44>
                if (ep->ref++ == 0) {
    8020570a:	1184a783          	lw	a5,280(s1)
    8020570e:	0017871b          	addiw	a4,a5,1
    80205712:	10e4ac23          	sw	a4,280(s1)
    80205716:	e791                	bnez	a5,80205722 <eget+0x82>
                    ep->parent->ref++;
    80205718:	118a2783          	lw	a5,280(s4)
    8020571c:	2785                	addiw	a5,a5,1
    8020571e:	10fa2c23          	sw	a5,280(s4)
                }
                release(&ecache.lock);
    80205722:	00018517          	auipc	a0,0x18
    80205726:	e9650513          	addi	a0,a0,-362 # 8021d5b8 <ecache>
    8020572a:	ffffb097          	auipc	ra,0xffffb
    8020572e:	01a080e7          	jalr	26(ra) # 80200744 <release>
                // edup(ep->parent);
                return ep;
    80205732:	7902                	ld	s2,32(sp)
    80205734:	69e2                	ld	s3,24(sp)
    80205736:	a0a5                	j	8020579e <eget+0xfe>
    80205738:	7902                	ld	s2,32(sp)
    8020573a:	69e2                	ld	s3,24(sp)
            }
        }
    }
    for (ep = root.prev; ep != &root; ep = ep->prev) {              // LRU algo
    8020573c:	00018497          	auipc	s1,0x18
    80205740:	e444b483          	ld	s1,-444(s1) # 8021d580 <root+0x130>
    80205744:	00018797          	auipc	a5,0x18
    80205748:	d0c78793          	addi	a5,a5,-756 # 8021d450 <root>
    8020574c:	00f48a63          	beq	s1,a5,80205760 <eget+0xc0>
    80205750:	873e                	mv	a4,a5
        if (ep->ref == 0) {
    80205752:	1184a783          	lw	a5,280(s1)
    80205756:	cf99                	beqz	a5,80205774 <eget+0xd4>
    for (ep = root.prev; ep != &root; ep = ep->prev) {              // LRU algo
    80205758:	1304b483          	ld	s1,304(s1)
    8020575c:	fee49be3          	bne	s1,a4,80205752 <eget+0xb2>
    80205760:	f04a                	sd	s2,32(sp)
    80205762:	ec4e                	sd	s3,24(sp)
            ep->dirty = 0;
            release(&ecache.lock);
            return ep;
        }
    }
    panic("eget: insufficient ecache");
    80205764:	00004517          	auipc	a0,0x4
    80205768:	40450513          	addi	a0,a0,1028 # 80209b68 <etext+0xb68>
    8020576c:	ffffb097          	auipc	ra,0xffffb
    80205770:	9da080e7          	jalr	-1574(ra) # 80200146 <panic>
            ep->ref = 1;
    80205774:	4785                	li	a5,1
    80205776:	10f4ac23          	sw	a5,280(s1)
            ep->dev = parent->dev;
    8020577a:	114a4783          	lbu	a5,276(s4)
    8020577e:	10f48a23          	sb	a5,276(s1)
            ep->off = 0;
    80205782:	1004ae23          	sw	zero,284(s1)
            ep->valid = 0;
    80205786:	10049b23          	sh	zero,278(s1)
            ep->dirty = 0;
    8020578a:	10048aa3          	sb	zero,277(s1)
            release(&ecache.lock);
    8020578e:	00018517          	auipc	a0,0x18
    80205792:	e2a50513          	addi	a0,a0,-470 # 8021d5b8 <ecache>
    80205796:	ffffb097          	auipc	ra,0xffffb
    8020579a:	fae080e7          	jalr	-82(ra) # 80200744 <release>
    return 0;
}
    8020579e:	8526                	mv	a0,s1
    802057a0:	70e2                	ld	ra,56(sp)
    802057a2:	7442                	ld	s0,48(sp)
    802057a4:	74a2                	ld	s1,40(sp)
    802057a6:	6a42                	ld	s4,16(sp)
    802057a8:	6aa2                	ld	s5,8(sp)
    802057aa:	6121                	addi	sp,sp,64
    802057ac:	8082                	ret

00000000802057ae <read_entry_name>:
 * @param   buffer      pointer to the array that stores the name
 * @param   raw_entry   pointer to the entry in a sector buffer
 * @param   islong      if non-zero, read as l-n-e, otherwise s-n-e.
 */
static void read_entry_name(char *buffer, union dentry *d)
{
    802057ae:	7139                	addi	sp,sp,-64
    802057b0:	fc06                	sd	ra,56(sp)
    802057b2:	f822                	sd	s0,48(sp)
    802057b4:	f426                	sd	s1,40(sp)
    802057b6:	f04a                	sd	s2,32(sp)
    802057b8:	0080                	addi	s0,sp,64
    802057ba:	84aa                	mv	s1,a0
    802057bc:	892e                	mv	s2,a1
    if (d->lne.attr == ATTR_LONG_NAME) {                       // long entry branch
    802057be:	00b5c703          	lbu	a4,11(a1)
    802057c2:	47bd                	li	a5,15
    802057c4:	02f70c63          	beq	a4,a5,802057fc <read_entry_name+0x4e>
    802057c8:	ec4e                	sd	s3,24(sp)
    802057ca:	e852                	sd	s4,16(sp)
        snstr(buffer, d->lne.name3, NELEM(d->lne.name3));
    } else {
        // short-name entry (no LFN). 短名按 FAT 规范存大写，
        // 是否转小写由 NTRes 决定：bit3(0x08)=主名小写，bit4(0x10)=扩展名小写。
        // NTRes=0 时保持原始大小写（如 README 大写文件名），不强制转小写。
        int lower_base = (d->sne._nt_res & 0x08) != 0;
    802057cc:	00c5c983          	lbu	s3,12(a1)
    802057d0:	0089fa13          	andi	s4,s3,8
        int lower_ext  = (d->sne._nt_res & 0x10) != 0;
    802057d4:	0109f993          	andi	s3,s3,16
        memset(buffer, 0, CHAR_SHORT_NAME + 2);
    802057d8:	4635                	li	a2,13
    802057da:	4581                	li	a1,0
    802057dc:	ffffb097          	auipc	ra,0xffffb
    802057e0:	fb0080e7          	jalr	-80(ra) # 8020078c <memset>
        int i;
        for (i = 0; d->sne.name[i] != ' ' && i < 8; i++) {
    802057e4:	00094703          	lbu	a4,0(s2)
    802057e8:	02000793          	li	a5,32
    802057ec:	08f70763          	beq	a4,a5,8020587a <read_entry_name+0xcc>
    802057f0:	4785                	li	a5,1
            char c = d->sne.name[i];
            buffer[i] = (lower_base && c >= 'A' && c <= 'Z') ? (c + 32) : c;
    802057f2:	4565                	li	a0,25
        for (i = 0; d->sne.name[i] != ' ' && i < 8; i++) {
    802057f4:	02000613          	li	a2,32
    802057f8:	45a5                	li	a1,9
    802057fa:	a09d                	j	80205860 <read_entry_name+0xb2>
        memmove(temp, d->lne.name1, sizeof(temp));
    802057fc:	4629                	li	a2,10
    802057fe:	0585                	addi	a1,a1,1
    80205800:	fc040513          	addi	a0,s0,-64
    80205804:	ffffb097          	auipc	ra,0xffffb
    80205808:	fe4080e7          	jalr	-28(ra) # 802007e8 <memmove>
        snstr(buffer, temp, NELEM(d->lne.name1));
    8020580c:	4615                	li	a2,5
    8020580e:	fc040593          	addi	a1,s0,-64
    80205812:	8526                	mv	a0,s1
    80205814:	ffffb097          	auipc	ra,0xffffb
    80205818:	150080e7          	jalr	336(ra) # 80200964 <snstr>
        snstr(buffer, d->lne.name2, NELEM(d->lne.name2));
    8020581c:	4619                	li	a2,6
    8020581e:	00e90593          	addi	a1,s2,14
    80205822:	00548513          	addi	a0,s1,5
    80205826:	ffffb097          	auipc	ra,0xffffb
    8020582a:	13e080e7          	jalr	318(ra) # 80200964 <snstr>
        snstr(buffer, d->lne.name3, NELEM(d->lne.name3));
    8020582e:	4609                	li	a2,2
    80205830:	01c90593          	addi	a1,s2,28
    80205834:	00b48513          	addi	a0,s1,11
    80205838:	ffffb097          	auipc	ra,0xffffb
    8020583c:	12c080e7          	jalr	300(ra) # 80200964 <snstr>
    80205840:	a861                	j	802058d8 <read_entry_name+0x12a>
            buffer[i] = (lower_base && c >= 'A' && c <= 'Z') ? (c + 32) : c;
    80205842:	00f486b3          	add	a3,s1,a5
    80205846:	fee68fa3          	sb	a4,-1(a3) # 1fff <_entry-0x801fe001>
        for (i = 0; d->sne.name[i] != ' ' && i < 8; i++) {
    8020584a:	0007869b          	sext.w	a3,a5
    8020584e:	00f90733          	add	a4,s2,a5
    80205852:	00074703          	lbu	a4,0(a4)
    80205856:	02c70363          	beq	a4,a2,8020587c <read_entry_name+0xce>
    8020585a:	0785                	addi	a5,a5,1
    8020585c:	02b78063          	beq	a5,a1,8020587c <read_entry_name+0xce>
            buffer[i] = (lower_base && c >= 'A' && c <= 'Z') ? (c + 32) : c;
    80205860:	fe0a01e3          	beqz	s4,80205842 <read_entry_name+0x94>
    80205864:	fbf7069b          	addiw	a3,a4,-65
    80205868:	0ff6f693          	zext.b	a3,a3
    8020586c:	fcd56be3          	bltu	a0,a3,80205842 <read_entry_name+0x94>
    80205870:	0207071b          	addiw	a4,a4,32
    80205874:	0ff77713          	zext.b	a4,a4
    80205878:	b7e9                	j	80205842 <read_entry_name+0x94>
        for (i = 0; d->sne.name[i] != ' ' && i < 8; i++) {
    8020587a:	4681                	li	a3,0
        }
        if (d->sne.name[8] != ' ') {
    8020587c:	00894703          	lbu	a4,8(s2)
    80205880:	02000793          	li	a5,32
    80205884:	00f70963          	beq	a4,a5,80205896 <read_entry_name+0xe8>
            buffer[i++] = '.';
    80205888:	00d487b3          	add	a5,s1,a3
    8020588c:	02e00713          	li	a4,46
    80205890:	00e78023          	sb	a4,0(a5)
    80205894:	2685                	addiw	a3,a3,1
        }
        for (int j = 8; j < CHAR_SHORT_NAME; j++, i++) {
    80205896:	00890793          	addi	a5,s2,8
    8020589a:	94b6                	add	s1,s1,a3
    8020589c:	092d                	addi	s2,s2,11
            if (d->sne.name[j] == ' ') { break; }
    8020589e:	02000613          	li	a2,32
            char c = d->sne.name[j];
            buffer[i] = (lower_ext && c >= 'A' && c <= 'Z') ? (c + 32) : c;
    802058a2:	45e5                	li	a1,25
    802058a4:	a039                	j	802058b2 <read_entry_name+0x104>
    802058a6:	00e48023          	sb	a4,0(s1)
        for (int j = 8; j < CHAR_SHORT_NAME; j++, i++) {
    802058aa:	0785                	addi	a5,a5,1
    802058ac:	0485                	addi	s1,s1,1
    802058ae:	03278363          	beq	a5,s2,802058d4 <read_entry_name+0x126>
            if (d->sne.name[j] == ' ') { break; }
    802058b2:	0007c703          	lbu	a4,0(a5)
    802058b6:	02c70763          	beq	a4,a2,802058e4 <read_entry_name+0x136>
            buffer[i] = (lower_ext && c >= 'A' && c <= 'Z') ? (c + 32) : c;
    802058ba:	fe0986e3          	beqz	s3,802058a6 <read_entry_name+0xf8>
    802058be:	fbf7069b          	addiw	a3,a4,-65
    802058c2:	0ff6f693          	zext.b	a3,a3
    802058c6:	fed5e0e3          	bltu	a1,a3,802058a6 <read_entry_name+0xf8>
    802058ca:	0207071b          	addiw	a4,a4,32
    802058ce:	0ff77713          	zext.b	a4,a4
    802058d2:	bfd1                	j	802058a6 <read_entry_name+0xf8>
    802058d4:	69e2                	ld	s3,24(sp)
    802058d6:	6a42                	ld	s4,16(sp)
        }
    }
}
    802058d8:	70e2                	ld	ra,56(sp)
    802058da:	7442                	ld	s0,48(sp)
    802058dc:	74a2                	ld	s1,40(sp)
    802058de:	7902                	ld	s2,32(sp)
    802058e0:	6121                	addi	sp,sp,64
    802058e2:	8082                	ret
    802058e4:	69e2                	ld	s3,24(sp)
    802058e6:	6a42                	ld	s4,16(sp)
    802058e8:	bfc5                	j	802058d8 <read_entry_name+0x12a>

00000000802058ea <fat32_init>:
{
    802058ea:	7139                	addi	sp,sp,-64
    802058ec:	fc06                	sd	ra,56(sp)
    802058ee:	f822                	sd	s0,48(sp)
    802058f0:	f426                	sd	s1,40(sp)
    802058f2:	f04a                	sd	s2,32(sp)
    802058f4:	ec4e                	sd	s3,24(sp)
    802058f6:	e852                	sd	s4,16(sp)
    802058f8:	e456                	sd	s5,8(sp)
    802058fa:	0080                	addi	s0,sp,64
    struct buf *b = bread(0, 0);
    802058fc:	4581                	li	a1,0
    802058fe:	4501                	li	a0,0
    80205900:	ffffe097          	auipc	ra,0xffffe
    80205904:	b14080e7          	jalr	-1260(ra) # 80203414 <bread>
    80205908:	892a                	mv	s2,a0
    if (strncmp((char const*)(b->data + 82), "FAT32", 5))
    8020590a:	4615                	li	a2,5
    8020590c:	00004597          	auipc	a1,0x4
    80205910:	27c58593          	addi	a1,a1,636 # 80209b88 <etext+0xb88>
    80205914:	0aa50513          	addi	a0,a0,170
    80205918:	ffffb097          	auipc	ra,0xffffb
    8020591c:	f4c080e7          	jalr	-180(ra) # 80200864 <strncmp>
    80205920:	16051863          	bnez	a0,80205a90 <fat32_init+0x1a6>
    memmove(&fat.bpb.byts_per_sec, b->data + 11, 2);            // avoid misaligned load on k210
    80205924:	00018497          	auipc	s1,0x18
    80205928:	b0448493          	addi	s1,s1,-1276 # 8021d428 <fat>
    8020592c:	4609                	li	a2,2
    8020592e:	06390593          	addi	a1,s2,99
    80205932:	00018517          	auipc	a0,0x18
    80205936:	b0650513          	addi	a0,a0,-1274 # 8021d438 <fat+0x10>
    8020593a:	ffffb097          	auipc	ra,0xffffb
    8020593e:	eae080e7          	jalr	-338(ra) # 802007e8 <memmove>
    fat.bpb.sec_per_clus = *(b->data + 13);
    80205942:	06594683          	lbu	a3,101(s2)
    80205946:	00d48923          	sb	a3,18(s1)
    fat.bpb.rsvd_sec_cnt = *(uint16 *)(b->data + 14);
    8020594a:	06695603          	lhu	a2,102(s2)
    8020594e:	00c49a23          	sh	a2,20(s1)
    fat.bpb.fat_cnt = *(b->data + 16);
    80205952:	06894703          	lbu	a4,104(s2)
    80205956:	00e48b23          	sb	a4,22(s1)
    fat.bpb.hidd_sec = *(uint32 *)(b->data + 28);
    8020595a:	07492783          	lw	a5,116(s2)
    8020595e:	cc9c                	sw	a5,24(s1)
    fat.bpb.tot_sec = *(uint32 *)(b->data + 32);
    80205960:	07892783          	lw	a5,120(s2)
    80205964:	ccdc                	sw	a5,28(s1)
    fat.bpb.fat_sz = *(uint32 *)(b->data + 36);
    80205966:	07c92583          	lw	a1,124(s2)
    8020596a:	d08c                	sw	a1,32(s1)
    fat.bpb.root_clus = *(uint32 *)(b->data + 44);
    8020596c:	08492503          	lw	a0,132(s2)
    80205970:	d0c8                	sw	a0,36(s1)
    fat.first_data_sec = fat.bpb.rsvd_sec_cnt + fat.bpb.fat_cnt * fat.bpb.fat_sz;
    80205972:	02b7073b          	mulw	a4,a4,a1
    80205976:	9f31                	addw	a4,a4,a2
    80205978:	c098                	sw	a4,0(s1)
    fat.data_sec_cnt = fat.bpb.tot_sec - fat.first_data_sec;
    8020597a:	9f99                	subw	a5,a5,a4
    8020597c:	c0dc                	sw	a5,4(s1)
    fat.data_clus_cnt = fat.data_sec_cnt / fat.bpb.sec_per_clus;
    8020597e:	02d7d7bb          	divuw	a5,a5,a3
    80205982:	c49c                	sw	a5,8(s1)
    fat.byts_per_clus = fat.bpb.sec_per_clus * fat.bpb.byts_per_sec;
    80205984:	0104d783          	lhu	a5,16(s1)
    80205988:	02d787bb          	mulw	a5,a5,a3
    8020598c:	c4dc                	sw	a5,12(s1)
    brelse(b);
    8020598e:	854a                	mv	a0,s2
    80205990:	ffffe097          	auipc	ra,0xffffe
    80205994:	bb0080e7          	jalr	-1104(ra) # 80203540 <brelse>
    if (BSIZE != fat.bpb.byts_per_sec) 
    80205998:	0104d703          	lhu	a4,16(s1)
    8020599c:	20000793          	li	a5,512
    802059a0:	10f71063          	bne	a4,a5,80205aa0 <fat32_init+0x1b6>
    initlock(&ecache.lock, "ecache");
    802059a4:	00004597          	auipc	a1,0x4
    802059a8:	21c58593          	addi	a1,a1,540 # 80209bc0 <etext+0xbc0>
    802059ac:	00018517          	auipc	a0,0x18
    802059b0:	c0c50513          	addi	a0,a0,-1012 # 8021d5b8 <ecache>
    802059b4:	ffffb097          	auipc	ra,0xffffb
    802059b8:	cf8080e7          	jalr	-776(ra) # 802006ac <initlock>
    memset(&root, 0, sizeof(root));
    802059bc:	00018497          	auipc	s1,0x18
    802059c0:	a6c48493          	addi	s1,s1,-1428 # 8021d428 <fat>
    802059c4:	00018917          	auipc	s2,0x18
    802059c8:	a8c90913          	addi	s2,s2,-1396 # 8021d450 <root>
    802059cc:	16800613          	li	a2,360
    802059d0:	4581                	li	a1,0
    802059d2:	854a                	mv	a0,s2
    802059d4:	ffffb097          	auipc	ra,0xffffb
    802059d8:	db8080e7          	jalr	-584(ra) # 8020078c <memset>
    initsleeplock(&root.lock, "entry");
    802059dc:	00004597          	auipc	a1,0x4
    802059e0:	1ec58593          	addi	a1,a1,492 # 80209bc8 <etext+0xbc8>
    802059e4:	00018517          	auipc	a0,0x18
    802059e8:	ba450513          	addi	a0,a0,-1116 # 8021d588 <root+0x138>
    802059ec:	ffffe097          	auipc	ra,0xffffe
    802059f0:	c68080e7          	jalr	-920(ra) # 80203654 <initsleeplock>
    root.attribute = (ATTR_DIRECTORY | ATTR_SYSTEM);
    802059f4:	47d1                	li	a5,20
    802059f6:	12f48423          	sb	a5,296(s1)
    root.first_clus = root.cur_clus = fat.bpb.root_clus;
    802059fa:	50dc                	lw	a5,36(s1)
    802059fc:	12f4aa23          	sw	a5,308(s1)
    80205a00:	12f4a623          	sw	a5,300(s1)
    root.valid = 1;
    80205a04:	4785                	li	a5,1
    80205a06:	12f49f23          	sh	a5,318(s1)
    root.prev = &root;
    80205a0a:	1524bc23          	sd	s2,344(s1)
    root.next = &root;
    80205a0e:	1524b823          	sd	s2,336(s1)
    for(struct dirent *de = ecache.entries; de < ecache.entries + ENTRY_CACHE_NUM; de++) {
    80205a12:	00018497          	auipc	s1,0x18
    80205a16:	bbe48493          	addi	s1,s1,-1090 # 8021d5d0 <ecache+0x18>
        de->next = root.next;
    80205a1a:	00018917          	auipc	s2,0x18
    80205a1e:	a0e90913          	addi	s2,s2,-1522 # 8021d428 <fat>
        de->prev = &root;
    80205a22:	00018a97          	auipc	s5,0x18
    80205a26:	a2ea8a93          	addi	s5,s5,-1490 # 8021d450 <root>
        initsleeplock(&de->lock, "entry");
    80205a2a:	00004a17          	auipc	s4,0x4
    80205a2e:	19ea0a13          	addi	s4,s4,414 # 80209bc8 <etext+0xbc8>
    for(struct dirent *de = ecache.entries; de < ecache.entries + ENTRY_CACHE_NUM; de++) {
    80205a32:	0001c997          	auipc	s3,0x1c
    80205a36:	1ee98993          	addi	s3,s3,494 # 80221c20 <cons>
        de->dev = 0;
    80205a3a:	10048a23          	sb	zero,276(s1)
        de->valid = 0;
    80205a3e:	10049b23          	sh	zero,278(s1)
        de->ref = 0;
    80205a42:	1004ac23          	sw	zero,280(s1)
        de->dirty = 0;
    80205a46:	10048aa3          	sb	zero,277(s1)
        de->parent = 0;
    80205a4a:	1204b023          	sd	zero,288(s1)
        de->next = root.next;
    80205a4e:	15093783          	ld	a5,336(s2)
    80205a52:	12f4b423          	sd	a5,296(s1)
        de->prev = &root;
    80205a56:	1354b823          	sd	s5,304(s1)
        initsleeplock(&de->lock, "entry");
    80205a5a:	85d2                	mv	a1,s4
    80205a5c:	13848513          	addi	a0,s1,312
    80205a60:	ffffe097          	auipc	ra,0xffffe
    80205a64:	bf4080e7          	jalr	-1036(ra) # 80203654 <initsleeplock>
        root.next->prev = de;
    80205a68:	15093783          	ld	a5,336(s2)
    80205a6c:	1297b823          	sd	s1,304(a5)
        root.next = de;
    80205a70:	14993823          	sd	s1,336(s2)
    for(struct dirent *de = ecache.entries; de < ecache.entries + ENTRY_CACHE_NUM; de++) {
    80205a74:	16848493          	addi	s1,s1,360
    80205a78:	fd3491e3          	bne	s1,s3,80205a3a <fat32_init+0x150>
}
    80205a7c:	4501                	li	a0,0
    80205a7e:	70e2                	ld	ra,56(sp)
    80205a80:	7442                	ld	s0,48(sp)
    80205a82:	74a2                	ld	s1,40(sp)
    80205a84:	7902                	ld	s2,32(sp)
    80205a86:	69e2                	ld	s3,24(sp)
    80205a88:	6a42                	ld	s4,16(sp)
    80205a8a:	6aa2                	ld	s5,8(sp)
    80205a8c:	6121                	addi	sp,sp,64
    80205a8e:	8082                	ret
        panic("not FAT32 volume");
    80205a90:	00004517          	auipc	a0,0x4
    80205a94:	10050513          	addi	a0,a0,256 # 80209b90 <etext+0xb90>
    80205a98:	ffffa097          	auipc	ra,0xffffa
    80205a9c:	6ae080e7          	jalr	1710(ra) # 80200146 <panic>
        panic("byts_per_sec != BSIZE");
    80205aa0:	00004517          	auipc	a0,0x4
    80205aa4:	10850513          	addi	a0,a0,264 # 80209ba8 <etext+0xba8>
    80205aa8:	ffffa097          	auipc	ra,0xffffa
    80205aac:	69e080e7          	jalr	1694(ra) # 80200146 <panic>

0000000080205ab0 <eread>:
    if (off > entry->file_size || off + n < off || (entry->attribute & ATTR_DIRECTORY)) {
    80205ab0:	10852783          	lw	a5,264(a0)
    80205ab4:	10d7e363          	bltu	a5,a3,80205bba <eread+0x10a>
{
    80205ab8:	711d                	addi	sp,sp,-96
    80205aba:	ec86                	sd	ra,88(sp)
    80205abc:	e8a2                	sd	s0,80(sp)
    80205abe:	e0ca                	sd	s2,64(sp)
    80205ac0:	f852                	sd	s4,48(sp)
    80205ac2:	f456                	sd	s5,40(sp)
    80205ac4:	f05a                	sd	s6,32(sp)
    80205ac6:	ec5e                	sd	s7,24(sp)
    80205ac8:	1080                	addi	s0,sp,96
    80205aca:	8a2a                	mv	s4,a0
    80205acc:	8bae                	mv	s7,a1
    80205ace:	8ab2                	mv	s5,a2
    80205ad0:	8936                	mv	s2,a3
    80205ad2:	8b3a                	mv	s6,a4
    if (off > entry->file_size || off + n < off || (entry->attribute & ATTR_DIRECTORY)) {
    80205ad4:	9eb9                	addw	a3,a3,a4
        return 0;
    80205ad6:	4501                	li	a0,0
    if (off > entry->file_size || off + n < off || (entry->attribute & ATTR_DIRECTORY)) {
    80205ad8:	0d26e363          	bltu	a3,s2,80205b9e <eread+0xee>
    80205adc:	100a4703          	lbu	a4,256(s4)
    80205ae0:	8b41                	andi	a4,a4,16
    80205ae2:	ef55                	bnez	a4,80205b9e <eread+0xee>
    80205ae4:	fc4e                	sd	s3,56(sp)
    if (off + n > entry->file_size) {
    80205ae6:	00d7f463          	bgeu	a5,a3,80205aee <eread+0x3e>
        n = entry->file_size - off;
    80205aea:	41278b3b          	subw	s6,a5,s2
    for (tot = 0; entry->cur_clus < FAT32_EOC && tot < n; tot += m, off += m, dst += m) {
    80205aee:	10ca2703          	lw	a4,268(s4)
    80205af2:	100007b7          	lui	a5,0x10000
    80205af6:	17dd                	addi	a5,a5,-9 # ffffff7 <_entry-0x70200009>
    80205af8:	08e7e863          	bltu	a5,a4,80205b88 <eread+0xd8>
    80205afc:	080b0863          	beqz	s6,80205b8c <eread+0xdc>
    80205b00:	e4a6                	sd	s1,72(sp)
    80205b02:	e862                	sd	s8,16(sp)
    80205b04:	e466                	sd	s9,8(sp)
    80205b06:	e06a                	sd	s10,0(sp)
    80205b08:	4981                	li	s3,0
        m = fat.byts_per_clus - off % fat.byts_per_clus;
    80205b0a:	00018c97          	auipc	s9,0x18
    80205b0e:	91ec8c93          	addi	s9,s9,-1762 # 8021d428 <fat>
    for (tot = 0; entry->cur_clus < FAT32_EOC && tot < n; tot += m, off += m, dst += m) {
    80205b12:	8c3e                	mv	s8,a5
    80205b14:	a82d                	j	80205b4e <eread+0x9e>
        if (n - tot < m) {
    80205b16:	00048d1b          	sext.w	s10,s1
        if (rw_clus(entry->cur_clus, 0, user_dst, dst, off % fat.byts_per_clus, m) != m) {
    80205b1a:	87ea                	mv	a5,s10
    80205b1c:	86d6                	mv	a3,s5
    80205b1e:	865e                	mv	a2,s7
    80205b20:	4581                	li	a1,0
    80205b22:	10ca2503          	lw	a0,268(s4)
    80205b26:	00000097          	auipc	ra,0x0
    80205b2a:	a00080e7          	jalr	-1536(ra) # 80205526 <rw_clus>
    80205b2e:	2501                	sext.w	a0,a0
    80205b30:	06ad1063          	bne	s10,a0,80205b90 <eread+0xe0>
    for (tot = 0; entry->cur_clus < FAT32_EOC && tot < n; tot += m, off += m, dst += m) {
    80205b34:	013489bb          	addw	s3,s1,s3
    80205b38:	0124893b          	addw	s2,s1,s2
    80205b3c:	1482                	slli	s1,s1,0x20
    80205b3e:	9081                	srli	s1,s1,0x20
    80205b40:	9aa6                	add	s5,s5,s1
    80205b42:	10ca2783          	lw	a5,268(s4)
    80205b46:	06fc6563          	bltu	s8,a5,80205bb0 <eread+0x100>
    80205b4a:	0369fa63          	bgeu	s3,s6,80205b7e <eread+0xce>
        reloc_clus(entry, off, 0);
    80205b4e:	4601                	li	a2,0
    80205b50:	85ca                	mv	a1,s2
    80205b52:	8552                	mv	a0,s4
    80205b54:	00000097          	auipc	ra,0x0
    80205b58:	8c2080e7          	jalr	-1854(ra) # 80205416 <reloc_clus>
        m = fat.byts_per_clus - off % fat.byts_per_clus;
    80205b5c:	00cca683          	lw	a3,12(s9)
    80205b60:	02d9763b          	remuw	a2,s2,a3
    80205b64:	0006071b          	sext.w	a4,a2
        if (n - tot < m) {
    80205b68:	413b07bb          	subw	a5,s6,s3
        m = fat.byts_per_clus - off % fat.byts_per_clus;
    80205b6c:	9e91                	subw	a3,a3,a2
        if (n - tot < m) {
    80205b6e:	84be                	mv	s1,a5
    80205b70:	2781                	sext.w	a5,a5
    80205b72:	0006861b          	sext.w	a2,a3
    80205b76:	faf670e3          	bgeu	a2,a5,80205b16 <eread+0x66>
    80205b7a:	84b6                	mv	s1,a3
    80205b7c:	bf69                	j	80205b16 <eread+0x66>
    80205b7e:	64a6                	ld	s1,72(sp)
    80205b80:	6c42                	ld	s8,16(sp)
    80205b82:	6ca2                	ld	s9,8(sp)
    80205b84:	6d02                	ld	s10,0(sp)
    80205b86:	a809                	j	80205b98 <eread+0xe8>
    for (tot = 0; entry->cur_clus < FAT32_EOC && tot < n; tot += m, off += m, dst += m) {
    80205b88:	4981                	li	s3,0
    80205b8a:	a039                	j	80205b98 <eread+0xe8>
    80205b8c:	89da                	mv	s3,s6
    80205b8e:	a029                	j	80205b98 <eread+0xe8>
    80205b90:	64a6                	ld	s1,72(sp)
    80205b92:	6c42                	ld	s8,16(sp)
    80205b94:	6ca2                	ld	s9,8(sp)
    80205b96:	6d02                	ld	s10,0(sp)
    return tot;
    80205b98:	0009851b          	sext.w	a0,s3
    80205b9c:	79e2                	ld	s3,56(sp)
}
    80205b9e:	60e6                	ld	ra,88(sp)
    80205ba0:	6446                	ld	s0,80(sp)
    80205ba2:	6906                	ld	s2,64(sp)
    80205ba4:	7a42                	ld	s4,48(sp)
    80205ba6:	7aa2                	ld	s5,40(sp)
    80205ba8:	7b02                	ld	s6,32(sp)
    80205baa:	6be2                	ld	s7,24(sp)
    80205bac:	6125                	addi	sp,sp,96
    80205bae:	8082                	ret
    80205bb0:	64a6                	ld	s1,72(sp)
    80205bb2:	6c42                	ld	s8,16(sp)
    80205bb4:	6ca2                	ld	s9,8(sp)
    80205bb6:	6d02                	ld	s10,0(sp)
    80205bb8:	b7c5                	j	80205b98 <eread+0xe8>
        return 0;
    80205bba:	4501                	li	a0,0
}
    80205bbc:	8082                	ret

0000000080205bbe <ewrite>:
    if (off > entry->file_size || off + n < off || (uint64)off + n > 0xffffffff
    80205bbe:	10852783          	lw	a5,264(a0)
    80205bc2:	12d7e063          	bltu	a5,a3,80205ce2 <ewrite+0x124>
{
    80205bc6:	711d                	addi	sp,sp,-96
    80205bc8:	ec86                	sd	ra,88(sp)
    80205bca:	e8a2                	sd	s0,80(sp)
    80205bcc:	e0ca                	sd	s2,64(sp)
    80205bce:	f852                	sd	s4,48(sp)
    80205bd0:	f456                	sd	s5,40(sp)
    80205bd2:	f05a                	sd	s6,32(sp)
    80205bd4:	ec5e                	sd	s7,24(sp)
    80205bd6:	1080                	addi	s0,sp,96
    80205bd8:	8aaa                	mv	s5,a0
    80205bda:	8bae                	mv	s7,a1
    80205bdc:	8a32                	mv	s4,a2
    80205bde:	8936                	mv	s2,a3
    80205be0:	8b3a                	mv	s6,a4
    if (off > entry->file_size || off + n < off || (uint64)off + n > 0xffffffff
    80205be2:	00e687bb          	addw	a5,a3,a4
    80205be6:	10d7e063          	bltu	a5,a3,80205ce6 <ewrite+0x128>
    80205bea:	02069793          	slli	a5,a3,0x20
    80205bee:	9381                	srli	a5,a5,0x20
    80205bf0:	1702                	slli	a4,a4,0x20
    80205bf2:	9301                	srli	a4,a4,0x20
    80205bf4:	97ba                	add	a5,a5,a4
    80205bf6:	577d                	li	a4,-1
    80205bf8:	9301                	srli	a4,a4,0x20
    80205bfa:	0ef76863          	bltu	a4,a5,80205cea <ewrite+0x12c>
        || (entry->attribute & ATTR_READ_ONLY)) {
    80205bfe:	10054783          	lbu	a5,256(a0)
    80205c02:	8b85                	andi	a5,a5,1
    80205c04:	e7ed                	bnez	a5,80205cee <ewrite+0x130>
    80205c06:	fc4e                	sd	s3,56(sp)
    if (entry->first_clus == 0) {   // so file_size if 0 too, which requests off == 0
    80205c08:	10452783          	lw	a5,260(a0)
    80205c0c:	cf81                	beqz	a5,80205c24 <ewrite+0x66>
    for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80205c0e:	0a0b0963          	beqz	s6,80205cc0 <ewrite+0x102>
    80205c12:	e4a6                	sd	s1,72(sp)
    80205c14:	e862                	sd	s8,16(sp)
    80205c16:	e466                	sd	s9,8(sp)
    80205c18:	4981                	li	s3,0
        m = fat.byts_per_clus - off % fat.byts_per_clus;
    80205c1a:	00018c17          	auipc	s8,0x18
    80205c1e:	80ec0c13          	addi	s8,s8,-2034 # 8021d428 <fat>
    80205c22:	a891                	j	80205c76 <ewrite+0xb8>
        entry->cur_clus = entry->first_clus = alloc_clus(entry->dev);
    80205c24:	11454503          	lbu	a0,276(a0)
    80205c28:	fffff097          	auipc	ra,0xfffff
    80205c2c:	62e080e7          	jalr	1582(ra) # 80205256 <alloc_clus>
    80205c30:	2501                	sext.w	a0,a0
    80205c32:	10aaa223          	sw	a0,260(s5)
    80205c36:	10aaa623          	sw	a0,268(s5)
        entry->clus_cnt = 0;
    80205c3a:	100aa823          	sw	zero,272(s5)
        entry->dirty = 1;
    80205c3e:	4785                	li	a5,1
    80205c40:	10fa8aa3          	sb	a5,277(s5)
    80205c44:	b7e9                	j	80205c0e <ewrite+0x50>
        if (n - tot < m) {
    80205c46:	00048c9b          	sext.w	s9,s1
        if (rw_clus(entry->cur_clus, 1, user_src, src, off % fat.byts_per_clus, m) != m) {
    80205c4a:	87e6                	mv	a5,s9
    80205c4c:	86d2                	mv	a3,s4
    80205c4e:	865e                	mv	a2,s7
    80205c50:	4585                	li	a1,1
    80205c52:	10caa503          	lw	a0,268(s5)
    80205c56:	00000097          	auipc	ra,0x0
    80205c5a:	8d0080e7          	jalr	-1840(ra) # 80205526 <rw_clus>
    80205c5e:	2501                	sext.w	a0,a0
    80205c60:	04ac9363          	bne	s9,a0,80205ca6 <ewrite+0xe8>
    for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80205c64:	013489bb          	addw	s3,s1,s3
    80205c68:	0124893b          	addw	s2,s1,s2
    80205c6c:	1482                	slli	s1,s1,0x20
    80205c6e:	9081                	srli	s1,s1,0x20
    80205c70:	9a26                	add	s4,s4,s1
    80205c72:	0369fa63          	bgeu	s3,s6,80205ca6 <ewrite+0xe8>
        reloc_clus(entry, off, 1);
    80205c76:	4605                	li	a2,1
    80205c78:	85ca                	mv	a1,s2
    80205c7a:	8556                	mv	a0,s5
    80205c7c:	fffff097          	auipc	ra,0xfffff
    80205c80:	79a080e7          	jalr	1946(ra) # 80205416 <reloc_clus>
        m = fat.byts_per_clus - off % fat.byts_per_clus;
    80205c84:	00cc2683          	lw	a3,12(s8)
    80205c88:	02d9763b          	remuw	a2,s2,a3
    80205c8c:	0006071b          	sext.w	a4,a2
        if (n - tot < m) {
    80205c90:	413b07bb          	subw	a5,s6,s3
        m = fat.byts_per_clus - off % fat.byts_per_clus;
    80205c94:	9e91                	subw	a3,a3,a2
        if (n - tot < m) {
    80205c96:	84be                	mv	s1,a5
    80205c98:	2781                	sext.w	a5,a5
    80205c9a:	0006861b          	sext.w	a2,a3
    80205c9e:	faf674e3          	bgeu	a2,a5,80205c46 <ewrite+0x88>
    80205ca2:	84b6                	mv	s1,a3
    80205ca4:	b74d                	j	80205c46 <ewrite+0x88>
        if(off > entry->file_size) {
    80205ca6:	108aa783          	lw	a5,264(s5)
    80205caa:	0127fd63          	bgeu	a5,s2,80205cc4 <ewrite+0x106>
            entry->file_size = off;
    80205cae:	112aa423          	sw	s2,264(s5)
            entry->dirty = 1;
    80205cb2:	4785                	li	a5,1
    80205cb4:	10fa8aa3          	sb	a5,277(s5)
    80205cb8:	64a6                	ld	s1,72(sp)
    80205cba:	6c42                	ld	s8,16(sp)
    80205cbc:	6ca2                	ld	s9,8(sp)
    80205cbe:	a031                	j	80205cca <ewrite+0x10c>
    for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80205cc0:	89da                	mv	s3,s6
    80205cc2:	a021                	j	80205cca <ewrite+0x10c>
    80205cc4:	64a6                	ld	s1,72(sp)
    80205cc6:	6c42                	ld	s8,16(sp)
    80205cc8:	6ca2                	ld	s9,8(sp)
    return tot;
    80205cca:	0009851b          	sext.w	a0,s3
    80205cce:	79e2                	ld	s3,56(sp)
}
    80205cd0:	60e6                	ld	ra,88(sp)
    80205cd2:	6446                	ld	s0,80(sp)
    80205cd4:	6906                	ld	s2,64(sp)
    80205cd6:	7a42                	ld	s4,48(sp)
    80205cd8:	7aa2                	ld	s5,40(sp)
    80205cda:	7b02                	ld	s6,32(sp)
    80205cdc:	6be2                	ld	s7,24(sp)
    80205cde:	6125                	addi	sp,sp,96
    80205ce0:	8082                	ret
        return -1;
    80205ce2:	557d                	li	a0,-1
}
    80205ce4:	8082                	ret
        return -1;
    80205ce6:	557d                	li	a0,-1
    80205ce8:	b7e5                	j	80205cd0 <ewrite+0x112>
    80205cea:	557d                	li	a0,-1
    80205cec:	b7d5                	j	80205cd0 <ewrite+0x112>
    80205cee:	557d                	li	a0,-1
    80205cf0:	b7c5                	j	80205cd0 <ewrite+0x112>

0000000080205cf2 <formatname>:
{
    80205cf2:	7179                	addi	sp,sp,-48
    80205cf4:	f406                	sd	ra,40(sp)
    80205cf6:	f022                	sd	s0,32(sp)
    80205cf8:	ec26                	sd	s1,24(sp)
    80205cfa:	e84a                	sd	s2,16(sp)
    80205cfc:	1800                	addi	s0,sp,48
    80205cfe:	84aa                	mv	s1,a0
    while (*name == ' ' || *name == '.') { name++; }
    80205d00:	02000793          	li	a5,32
    80205d04:	02e00713          	li	a4,46
    80205d08:	a011                	j	80205d0c <formatname+0x1a>
    80205d0a:	0485                	addi	s1,s1,1
    80205d0c:	0004c583          	lbu	a1,0(s1)
    80205d10:	fef58de3          	beq	a1,a5,80205d0a <formatname+0x18>
    80205d14:	fee58be3          	beq	a1,a4,80205d0a <formatname+0x18>
    for (p = name; *p; p++) {
    80205d18:	c5a9                	beqz	a1,80205d62 <formatname+0x70>
    80205d1a:	e44e                	sd	s3,8(sp)
    80205d1c:	e052                	sd	s4,0(sp)
    80205d1e:	8926                	mv	s2,s1
        if (c < 0x20 || strchr(illegal, c)) {
    80205d20:	49fd                	li	s3,31
    80205d22:	00004a17          	auipc	s4,0x4
    80205d26:	316a0a13          	addi	s4,s4,790 # 8020a038 <illegal.1>
    80205d2a:	04b9f063          	bgeu	s3,a1,80205d6a <formatname+0x78>
    80205d2e:	8552                	mv	a0,s4
    80205d30:	ffffb097          	auipc	ra,0xffffb
    80205d34:	cb2080e7          	jalr	-846(ra) # 802009e2 <strchr>
    80205d38:	e131                	bnez	a0,80205d7c <formatname+0x8a>
    for (p = name; *p; p++) {
    80205d3a:	0905                	addi	s2,s2,1
    80205d3c:	00094583          	lbu	a1,0(s2)
    80205d40:	f5ed                	bnez	a1,80205d2a <formatname+0x38>
    80205d42:	69a2                	ld	s3,8(sp)
    80205d44:	6a02                	ld	s4,0(sp)
        if (*p != ' ') {
    80205d46:	02000713          	li	a4,32
    80205d4a:	86ca                	mv	a3,s2
    while (p-- > name) {
    80205d4c:	0124fd63          	bgeu	s1,s2,80205d66 <formatname+0x74>
        if (*p != ' ') {
    80205d50:	197d                	addi	s2,s2,-1
    80205d52:	00094783          	lbu	a5,0(s2)
    80205d56:	fee78ae3          	beq	a5,a4,80205d4a <formatname+0x58>
            p[1] = '\0';
    80205d5a:	00068023          	sb	zero,0(a3)
    return name;
    80205d5e:	8526                	mv	a0,s1
            break;
    80205d60:	a801                	j	80205d70 <formatname+0x7e>
    for (p = name; *p; p++) {
    80205d62:	8926                	mv	s2,s1
    80205d64:	b7cd                	j	80205d46 <formatname+0x54>
    return name;
    80205d66:	8526                	mv	a0,s1
    80205d68:	a021                	j	80205d70 <formatname+0x7e>
            return 0;
    80205d6a:	4501                	li	a0,0
    80205d6c:	69a2                	ld	s3,8(sp)
    80205d6e:	6a02                	ld	s4,0(sp)
}
    80205d70:	70a2                	ld	ra,40(sp)
    80205d72:	7402                	ld	s0,32(sp)
    80205d74:	64e2                	ld	s1,24(sp)
    80205d76:	6942                	ld	s2,16(sp)
    80205d78:	6145                	addi	sp,sp,48
    80205d7a:	8082                	ret
            return 0;
    80205d7c:	4501                	li	a0,0
    80205d7e:	69a2                	ld	s3,8(sp)
    80205d80:	6a02                	ld	s4,0(sp)
    80205d82:	b7fd                	j	80205d70 <formatname+0x7e>

0000000080205d84 <cal_checksum>:
{
    80205d84:	1141                	addi	sp,sp,-16
    80205d86:	e422                	sd	s0,8(sp)
    80205d88:	0800                	addi	s0,sp,16
    80205d8a:	872a                	mv	a4,a0
    for (int i = CHAR_SHORT_NAME; i != 0; i--) {
    80205d8c:	00b50613          	addi	a2,a0,11
    uint8 sum = 0;
    80205d90:	4501                	li	a0,0
        sum = ((sum & 1) ? 0x80 : 0) + (sum >> 1) + *shortname++;
    80205d92:	0015579b          	srliw	a5,a0,0x1
    80205d96:	0075151b          	slliw	a0,a0,0x7
    80205d9a:	8fc9                	or	a5,a5,a0
    80205d9c:	0705                	addi	a4,a4,1
    80205d9e:	fff74683          	lbu	a3,-1(a4)
    80205da2:	97b6                	add	a5,a5,a3
    80205da4:	0ff7f513          	zext.b	a0,a5
    for (int i = CHAR_SHORT_NAME; i != 0; i--) {
    80205da8:	fee615e3          	bne	a2,a4,80205d92 <cal_checksum+0xe>
}
    80205dac:	6422                	ld	s0,8(sp)
    80205dae:	0141                	addi	sp,sp,16
    80205db0:	8082                	ret

0000000080205db2 <emake>:
{
    80205db2:	7171                	addi	sp,sp,-176
    80205db4:	f506                	sd	ra,168(sp)
    80205db6:	f122                	sd	s0,160(sp)
    80205db8:	1900                	addi	s0,sp,176
    if (!(dp->attribute & ATTR_DIRECTORY))
    80205dba:	10054783          	lbu	a5,256(a0)
    80205dbe:	8bc1                	andi	a5,a5,16
    80205dc0:	cfc9                	beqz	a5,80205e5a <emake+0xa8>
    80205dc2:	ed26                	sd	s1,152(sp)
    80205dc4:	e54e                	sd	s3,136(sp)
    80205dc6:	fcd6                	sd	s5,120(sp)
    80205dc8:	84aa                	mv	s1,a0
    80205dca:	8aae                	mv	s5,a1
    80205dcc:	89b2                	mv	s3,a2
    if (off % sizeof(union dentry))
    80205dce:	01f67793          	andi	a5,a2,31
    80205dd2:	e7dd                	bnez	a5,80205e80 <emake+0xce>
    memset(&de, 0, sizeof(de));
    80205dd4:	02000613          	li	a2,32
    80205dd8:	4581                	li	a1,0
    80205dda:	f7040513          	addi	a0,s0,-144
    80205dde:	ffffb097          	auipc	ra,0xffffb
    80205de2:	9ae080e7          	jalr	-1618(ra) # 8020078c <memset>
    if (off <= 32) {
    80205de6:	02000793          	li	a5,32
    80205dea:	0d37e763          	bltu	a5,s3,80205eb8 <emake+0x106>
        if (off == 0) {
    80205dee:	0a099963          	bnez	s3,80205ea0 <emake+0xee>
            strncpy(de.sne.name, ".          ", sizeof(de.sne.name));
    80205df2:	462d                	li	a2,11
    80205df4:	00004597          	auipc	a1,0x4
    80205df8:	e0458593          	addi	a1,a1,-508 # 80209bf8 <etext+0xbf8>
    80205dfc:	f7040513          	addi	a0,s0,-144
    80205e00:	ffffb097          	auipc	ra,0xffffb
    80205e04:	a9a080e7          	jalr	-1382(ra) # 8020089a <strncpy>
        de.sne.attr = ATTR_DIRECTORY;
    80205e08:	47c1                	li	a5,16
    80205e0a:	f6f40da3          	sb	a5,-133(s0)
        de.sne.fst_clus_hi = (uint16)(ep->first_clus >> 16);        // first clus high 16 bits
    80205e0e:	104aa783          	lw	a5,260(s5)
    80205e12:	0107d71b          	srliw	a4,a5,0x10
    80205e16:	f8e41223          	sh	a4,-124(s0)
        de.sne.fst_clus_lo = (uint16)(ep->first_clus & 0xffff);       // low 16 bits
    80205e1a:	f8f41523          	sh	a5,-118(s0)
        de.sne.file_size = 0;                                       // filesize is updated in eupdate()
    80205e1e:	f8042623          	sw	zero,-116(s0)
        off = reloc_clus(dp, off, 1);
    80205e22:	4605                	li	a2,1
    80205e24:	85ce                	mv	a1,s3
    80205e26:	8526                	mv	a0,s1
    80205e28:	fffff097          	auipc	ra,0xfffff
    80205e2c:	5ee080e7          	jalr	1518(ra) # 80205416 <reloc_clus>
        rw_clus(dp->cur_clus, 1, 0, (uint64)&de, off, sizeof(de));
    80205e30:	02000793          	li	a5,32
    80205e34:	0005071b          	sext.w	a4,a0
    80205e38:	f7040693          	addi	a3,s0,-144
    80205e3c:	4601                	li	a2,0
    80205e3e:	4585                	li	a1,1
    80205e40:	10c4a503          	lw	a0,268(s1)
    80205e44:	fffff097          	auipc	ra,0xfffff
    80205e48:	6e2080e7          	jalr	1762(ra) # 80205526 <rw_clus>
    80205e4c:	64ea                	ld	s1,152(sp)
    80205e4e:	69aa                	ld	s3,136(sp)
    80205e50:	7ae6                	ld	s5,120(sp)
}
    80205e52:	70aa                	ld	ra,168(sp)
    80205e54:	740a                	ld	s0,160(sp)
    80205e56:	614d                	addi	sp,sp,176
    80205e58:	8082                	ret
    80205e5a:	ed26                	sd	s1,152(sp)
    80205e5c:	e94a                	sd	s2,144(sp)
    80205e5e:	e54e                	sd	s3,136(sp)
    80205e60:	e152                	sd	s4,128(sp)
    80205e62:	fcd6                	sd	s5,120(sp)
    80205e64:	f8da                	sd	s6,112(sp)
    80205e66:	f4de                	sd	s7,104(sp)
    80205e68:	f0e2                	sd	s8,96(sp)
    80205e6a:	ece6                	sd	s9,88(sp)
    80205e6c:	e8ea                	sd	s10,80(sp)
    80205e6e:	e4ee                	sd	s11,72(sp)
        panic("emake: not dir");
    80205e70:	00004517          	auipc	a0,0x4
    80205e74:	d6050513          	addi	a0,a0,-672 # 80209bd0 <etext+0xbd0>
    80205e78:	ffffa097          	auipc	ra,0xffffa
    80205e7c:	2ce080e7          	jalr	718(ra) # 80200146 <panic>
    80205e80:	e94a                	sd	s2,144(sp)
    80205e82:	e152                	sd	s4,128(sp)
    80205e84:	f8da                	sd	s6,112(sp)
    80205e86:	f4de                	sd	s7,104(sp)
    80205e88:	f0e2                	sd	s8,96(sp)
    80205e8a:	ece6                	sd	s9,88(sp)
    80205e8c:	e8ea                	sd	s10,80(sp)
    80205e8e:	e4ee                	sd	s11,72(sp)
        panic("emake: not aligned");
    80205e90:	00004517          	auipc	a0,0x4
    80205e94:	d5050513          	addi	a0,a0,-688 # 80209be0 <etext+0xbe0>
    80205e98:	ffffa097          	auipc	ra,0xffffa
    80205e9c:	2ae080e7          	jalr	686(ra) # 80200146 <panic>
            strncpy(de.sne.name, "..         ", sizeof(de.sne.name));
    80205ea0:	462d                	li	a2,11
    80205ea2:	00004597          	auipc	a1,0x4
    80205ea6:	d6658593          	addi	a1,a1,-666 # 80209c08 <etext+0xc08>
    80205eaa:	f7040513          	addi	a0,s0,-144
    80205eae:	ffffb097          	auipc	ra,0xffffb
    80205eb2:	9ec080e7          	jalr	-1556(ra) # 8020089a <strncpy>
    80205eb6:	bf89                	j	80205e08 <emake+0x56>
    80205eb8:	e94a                	sd	s2,144(sp)
    80205eba:	e152                	sd	s4,128(sp)
    80205ebc:	f8da                	sd	s6,112(sp)
    80205ebe:	f4de                	sd	s7,104(sp)
    80205ec0:	f0e2                	sd	s8,96(sp)
    80205ec2:	ece6                	sd	s9,88(sp)
    80205ec4:	e8ea                	sd	s10,80(sp)
    80205ec6:	e4ee                	sd	s11,72(sp)
        int entcnt = (strlen(ep->filename) + CHAR_LONG_NAME - 1) / CHAR_LONG_NAME;   // count of l-n-entries, rounds up
    80205ec8:	8956                	mv	s2,s5
    80205eca:	8556                	mv	a0,s5
    80205ecc:	ffffb097          	auipc	ra,0xffffb
    80205ed0:	a3c080e7          	jalr	-1476(ra) # 80200908 <strlen>
    80205ed4:	f4a43c23          	sd	a0,-168(s0)
    80205ed8:	00c5071b          	addiw	a4,a0,12
    80205edc:	47b5                	li	a5,13
    80205ede:	02f747bb          	divw	a5,a4,a5
    80205ee2:	f4f42a23          	sw	a5,-172(s0)
    80205ee6:	00078b9b          	sext.w	s7,a5
        memset(shortname, 0, sizeof(shortname));
    80205eea:	4631                	li	a2,12
    80205eec:	4581                	li	a1,0
    80205eee:	f6040513          	addi	a0,s0,-160
    80205ef2:	ffffb097          	auipc	ra,0xffffb
    80205ef6:	89a080e7          	jalr	-1894(ra) # 8020078c <memset>
    for (int j = strlen(name) - 1; j >= 0; j--) {
    80205efa:	8556                	mv	a0,s5
    80205efc:	ffffb097          	auipc	ra,0xffffb
    80205f00:	a0c080e7          	jalr	-1524(ra) # 80200908 <strlen>
    80205f04:	fff5079b          	addiw	a5,a0,-1
    80205f08:	0207cd63          	bltz	a5,80205f42 <emake+0x190>
    80205f0c:	97d6                	add	a5,a5,s5
    80205f0e:	ffea8693          	addi	a3,s5,-2
    80205f12:	96aa                	add	a3,a3,a0
    80205f14:	fff5071b          	addiw	a4,a0,-1
    80205f18:	1702                	slli	a4,a4,0x20
    80205f1a:	9301                	srli	a4,a4,0x20
    80205f1c:	8e99                	sub	a3,a3,a4
        if (name[j] == '.') {
    80205f1e:	02e00613          	li	a2,46
    80205f22:	8b3e                	mv	s6,a5
    80205f24:	0007c703          	lbu	a4,0(a5)
    80205f28:	00c70663          	beq	a4,a2,80205f34 <emake+0x182>
    for (int j = strlen(name) - 1; j >= 0; j--) {
    80205f2c:	17fd                	addi	a5,a5,-1
    80205f2e:	fed79ae3          	bne	a5,a3,80205f22 <emake+0x170>
    char c, *p = name;
    80205f32:	8b56                	mv	s6,s5
                c = '_';
    80205f34:	4a01                	li	s4,0
        if (i == 8 && p) {
    80205f36:	4ca1                	li	s9,8
        if (c == ' ') { continue; }
    80205f38:	02000d13          	li	s10,32
        if (c == '.') {
    80205f3c:	02e00d93          	li	s11,46
    80205f40:	a8f1                	j	8020601c <emake+0x26a>
    char c, *p = name;
    80205f42:	8b56                	mv	s6,s5
    80205f44:	bfc5                	j	80205f34 <emake+0x182>
        if (i == 8 && p) {
    80205f46:	0e0b0363          	beqz	s6,8020602c <emake+0x27a>
            if (p + 1 < name) { break; }            // no '.'
    80205f4a:	0b05                	addi	s6,s6,1
    80205f4c:	078b7863          	bgeu	s6,s8,80205fbc <emake+0x20a>
    while (i < CHAR_SHORT_NAME) {
    80205f50:	f6040793          	addi	a5,s0,-160
    80205f54:	97d2                	add	a5,a5,s4
    80205f56:	f6140713          	addi	a4,s0,-159
    80205f5a:	9752                	add	a4,a4,s4
    80205f5c:	46a9                	li	a3,10
    80205f5e:	414686bb          	subw	a3,a3,s4
    80205f62:	1682                	slli	a3,a3,0x20
    80205f64:	9281                	srli	a3,a3,0x20
    80205f66:	9736                	add	a4,a4,a3
        shortname[i++] = ' ';
    80205f68:	02000693          	li	a3,32
    80205f6c:	00d78023          	sb	a3,0(a5)
    while (i < CHAR_SHORT_NAME) {
    80205f70:	0785                	addi	a5,a5,1
    80205f72:	fee79de3          	bne	a5,a4,80205f6c <emake+0x1ba>
        de.lne.checksum = cal_checksum((uchar *)shortname);
    80205f76:	f6040513          	addi	a0,s0,-160
    80205f7a:	00000097          	auipc	ra,0x0
    80205f7e:	e0a080e7          	jalr	-502(ra) # 80205d84 <cal_checksum>
    80205f82:	f6a40ea3          	sb	a0,-131(s0)
        de.lne.attr = ATTR_LONG_NAME;
    80205f86:	47bd                	li	a5,15
    80205f88:	f6f40da3          	sb	a5,-133(s0)
        for (int i = entcnt; i > 0; i--) {
    80205f8c:	f5843783          	ld	a5,-168(s0)
    80205f90:	12f05963          	blez	a5,802060c2 <emake+0x310>
    80205f94:	f5442783          	lw	a5,-172(s0)
    80205f98:	fff78d9b          	addiw	s11,a5,-1
    80205f9c:	001d9c1b          	slliw	s8,s11,0x1
    80205fa0:	01bc0c3b          	addw	s8,s8,s11
    80205fa4:	002c1c1b          	slliw	s8,s8,0x2
    80205fa8:	01bc0c3b          	addw	s8,s8,s11
    80205fac:	9c56                	add	s8,s8,s5
    80205fae:	8b5e                	mv	s6,s7
    80205fb0:	8d4e                	mv	s10,s3
            for (int j = 1; j <= CHAR_LONG_NAME; j++) {
    80205fb2:	4c85                	li	s9,1
            int end = 0;
    80205fb4:	4a01                	li	s4,0
    80205fb6:	0ff00913          	li	s2,255
    80205fba:	a8f1                	j	80206096 <emake+0x2e4>
                name = p + 1, p = 0;
    80205fbc:	8c5a                	mv	s8,s6
    80205fbe:	4b01                	li	s6,0
    80205fc0:	a019                	j	80205fc6 <emake+0x214>
            if (name > p) {                    // last '.'
    80205fc2:	018b6463          	bltu	s6,s8,80205fca <emake+0x218>
                c = '_';
    80205fc6:	87d2                	mv	a5,s4
    80205fc8:	a881                	j	80206018 <emake+0x266>
                memset(shortname + i, ' ', 8 - i);
    80205fca:	4621                	li	a2,8
    80205fcc:	4146063b          	subw	a2,a2,s4
    80205fd0:	02000593          	li	a1,32
    80205fd4:	f6040793          	addi	a5,s0,-160
    80205fd8:	01478533          	add	a0,a5,s4
    80205fdc:	ffffa097          	auipc	ra,0xffffa
    80205fe0:	7b0080e7          	jalr	1968(ra) # 8020078c <memset>
                i = 8, p = 0;
    80205fe4:	4b01                	li	s6,0
    80205fe6:	4a21                	li	s4,8
    80205fe8:	bff9                	j	80205fc6 <emake+0x214>
            if (strchr(illegal, c) != NULL) {
    80205fea:	85ca                	mv	a1,s2
    80205fec:	00004517          	auipc	a0,0x4
    80205ff0:	06450513          	addi	a0,a0,100 # 8020a050 <illegal.0>
    80205ff4:	ffffb097          	auipc	ra,0xffffb
    80205ff8:	9ee080e7          	jalr	-1554(ra) # 802009e2 <strchr>
    80205ffc:	c119                	beqz	a0,80206002 <emake+0x250>
                c = '_';
    80205ffe:	05f00913          	li	s2,95
        shortname[i++] = c;
    80206002:	001a079b          	addiw	a5,s4,1
    80206006:	f90a0713          	addi	a4,s4,-112
    8020600a:	00870a33          	add	s4,a4,s0
    8020600e:	fd2a0823          	sb	s2,-48(s4)
    while (i < CHAR_SHORT_NAME && (c = *name++)) {
    80206012:	4729                	li	a4,10
    80206014:	f6f741e3          	blt	a4,a5,80205f76 <emake+0x1c4>
                c = '_';
    80206018:	8962                	mv	s2,s8
    8020601a:	8a3e                	mv	s4,a5
    while (i < CHAR_SHORT_NAME && (c = *name++)) {
    8020601c:	00190c13          	addi	s8,s2,1
    80206020:	00094903          	lbu	s2,0(s2)
    80206024:	f20906e3          	beqz	s2,80205f50 <emake+0x19e>
        if (i == 8 && p) {
    80206028:	f19a0fe3          	beq	s4,s9,80205f46 <emake+0x194>
        if (c == ' ') { continue; }
    8020602c:	f9a90de3          	beq	s2,s10,80205fc6 <emake+0x214>
        if (c == '.') {
    80206030:	f9b909e3          	beq	s2,s11,80205fc2 <emake+0x210>
        if (c >= 'a' && c <= 'z') {
    80206034:	f9f9079b          	addiw	a5,s2,-97
    80206038:	0ff7f793          	zext.b	a5,a5
    8020603c:	4765                	li	a4,25
    8020603e:	faf766e3          	bltu	a4,a5,80205fea <emake+0x238>
            c += 'A' - 'a';
    80206042:	3901                	addiw	s2,s2,-32
    80206044:	0ff97913          	zext.b	s2,s2
    80206048:	bf6d                	j	80206002 <emake+0x250>
                de.lne.order |= LAST_LONG_ENTRY;
    8020604a:	0407e793          	ori	a5,a5,64
    8020604e:	a881                	j	8020609e <emake+0x2ec>
                    if ((*w++ = *p++) == 0) {
    80206050:	00054683          	lbu	a3,0(a0)
    80206054:	0016b593          	seqz	a1,a3
                    *w++ = 0;
    80206058:	00270813          	addi	a6,a4,2
                    if ((*w++ = *p++) == 0) {
    8020605c:	0505                	addi	a0,a0,1
                    *w++ = 0;
    8020605e:	8652                	mv	a2,s4
    80206060:	a8cd                	j	80206152 <emake+0x3a0>
            uint off2 = reloc_clus(dp, off, 1);
    80206062:	8666                	mv	a2,s9
    80206064:	85ea                	mv	a1,s10
    80206066:	8526                	mv	a0,s1
    80206068:	fffff097          	auipc	ra,0xfffff
    8020606c:	3ae080e7          	jalr	942(ra) # 80205416 <reloc_clus>
            rw_clus(dp->cur_clus, 1, 0, (uint64)&de, off2, sizeof(de));
    80206070:	02000793          	li	a5,32
    80206074:	0005071b          	sext.w	a4,a0
    80206078:	f7040693          	addi	a3,s0,-144
    8020607c:	8652                	mv	a2,s4
    8020607e:	85e6                	mv	a1,s9
    80206080:	10c4a503          	lw	a0,268(s1)
    80206084:	fffff097          	auipc	ra,0xfffff
    80206088:	4a2080e7          	jalr	1186(ra) # 80205526 <rw_clus>
            off += sizeof(de);
    8020608c:	020d0d1b          	addiw	s10,s10,32
        for (int i = entcnt; i > 0; i--) {
    80206090:	1c4d                	addi	s8,s8,-13
    80206092:	020b0263          	beqz	s6,802060b6 <emake+0x304>
            if ((de.lne.order = i) == entcnt) {
    80206096:	0ffb7793          	zext.b	a5,s6
    8020609a:	fb7788e3          	beq	a5,s7,8020604a <emake+0x298>
    8020609e:	f6f40823          	sb	a5,-144(s0)
            char *p = ep->filename + (i - 1) * CHAR_LONG_NAME;
    802060a2:	3b7d                	addiw	s6,s6,-1
    802060a4:	8562                	mv	a0,s8
            for (int j = 1; j <= CHAR_LONG_NAME; j++) {
    802060a6:	87e6                	mv	a5,s9
            int end = 0;
    802060a8:	85d2                	mv	a1,s4
            uint8 *w = (uint8 *)de.lne.name1;
    802060aa:	f7140713          	addi	a4,s0,-143
                switch (j) {
    802060ae:	4895                	li	a7,5
    802060b0:	432d                	li	t1,11
            for (int j = 1; j <= CHAR_LONG_NAME; j++) {
    802060b2:	4e39                	li	t3,14
    802060b4:	a851                	j	80206148 <emake+0x396>
    802060b6:	0209899b          	addiw	s3,s3,32
    802060ba:	005d9d9b          	slliw	s11,s11,0x5
    802060be:	013d89bb          	addw	s3,s11,s3
        memset(&de, 0, sizeof(de));
    802060c2:	02000613          	li	a2,32
    802060c6:	4581                	li	a1,0
    802060c8:	f7040513          	addi	a0,s0,-144
    802060cc:	ffffa097          	auipc	ra,0xffffa
    802060d0:	6c0080e7          	jalr	1728(ra) # 8020078c <memset>
        strncpy(de.sne.name, shortname, sizeof(de.sne.name));
    802060d4:	462d                	li	a2,11
    802060d6:	f6040593          	addi	a1,s0,-160
    802060da:	f7040513          	addi	a0,s0,-144
    802060de:	ffffa097          	auipc	ra,0xffffa
    802060e2:	7bc080e7          	jalr	1980(ra) # 8020089a <strncpy>
        de.sne.attr = ep->attribute;
    802060e6:	100ac783          	lbu	a5,256(s5)
    802060ea:	f6f40da3          	sb	a5,-133(s0)
        de.sne.fst_clus_hi = (uint16)(ep->first_clus >> 16);      // first clus high 16 bits
    802060ee:	104aa783          	lw	a5,260(s5)
    802060f2:	0107d71b          	srliw	a4,a5,0x10
    802060f6:	f8e41223          	sh	a4,-124(s0)
        de.sne.fst_clus_lo = (uint16)(ep->first_clus & 0xffff);     // low 16 bits
    802060fa:	f8f41523          	sh	a5,-118(s0)
        de.sne.file_size = ep->file_size;                         // filesize is updated in eupdate()
    802060fe:	108aa783          	lw	a5,264(s5)
    80206102:	f8f42623          	sw	a5,-116(s0)
        off = reloc_clus(dp, off, 1);
    80206106:	4605                	li	a2,1
    80206108:	85ce                	mv	a1,s3
    8020610a:	8526                	mv	a0,s1
    8020610c:	fffff097          	auipc	ra,0xfffff
    80206110:	30a080e7          	jalr	778(ra) # 80205416 <reloc_clus>
        rw_clus(dp->cur_clus, 1, 0, (uint64)&de, off, sizeof(de));
    80206114:	02000793          	li	a5,32
    80206118:	0005071b          	sext.w	a4,a0
    8020611c:	f7040693          	addi	a3,s0,-144
    80206120:	4601                	li	a2,0
    80206122:	4585                	li	a1,1
    80206124:	10c4a503          	lw	a0,268(s1)
    80206128:	fffff097          	auipc	ra,0xfffff
    8020612c:	3fe080e7          	jalr	1022(ra) # 80205526 <rw_clus>
}
    80206130:	694a                	ld	s2,144(sp)
    80206132:	6a0a                	ld	s4,128(sp)
    80206134:	7b46                	ld	s6,112(sp)
    80206136:	7ba6                	ld	s7,104(sp)
    80206138:	7c06                	ld	s8,96(sp)
    8020613a:	6ce6                	ld	s9,88(sp)
    8020613c:	6d46                	ld	s10,80(sp)
    8020613e:	6da6                	ld	s11,72(sp)
    80206140:	b331                	j	80205e4c <emake+0x9a>
                switch (j) {
    80206142:	f7e40713          	addi	a4,s0,-130
            for (int j = 1; j <= CHAR_LONG_NAME; j++) {
    80206146:	2785                	addiw	a5,a5,1
                if (end) {
    80206148:	d581                	beqz	a1,80206050 <emake+0x29e>
                    *w++ = 0xff;
    8020614a:	00270813          	addi	a6,a4,2
    8020614e:	86ca                	mv	a3,s2
    80206150:	864a                	mv	a2,s2
                    *w++ = 0xff;            // on k210, unaligned reading is illegal
    80206152:	00d70023          	sb	a3,0(a4)
                    *w++ = 0xff;
    80206156:	00c700a3          	sb	a2,1(a4)
                switch (j) {
    8020615a:	ff1784e3          	beq	a5,a7,80206142 <emake+0x390>
    8020615e:	00678763          	beq	a5,t1,8020616c <emake+0x3ba>
            for (int j = 1; j <= CHAR_LONG_NAME; j++) {
    80206162:	2785                	addiw	a5,a5,1
    80206164:	efc78fe3          	beq	a5,t3,80206062 <emake+0x2b0>
    80206168:	8742                	mv	a4,a6
    8020616a:	bff9                	j	80206148 <emake+0x396>
                    case 11:    w = (uint8 *)de.lne.name3; break;
    8020616c:	f8c40713          	addi	a4,s0,-116
    80206170:	bfd9                	j	80206146 <emake+0x394>

0000000080206172 <edup>:
{
    80206172:	1101                	addi	sp,sp,-32
    80206174:	ec06                	sd	ra,24(sp)
    80206176:	e822                	sd	s0,16(sp)
    80206178:	e426                	sd	s1,8(sp)
    8020617a:	1000                	addi	s0,sp,32
    8020617c:	84aa                	mv	s1,a0
    if (entry != 0) {
    8020617e:	c515                	beqz	a0,802061aa <edup+0x38>
        acquire(&ecache.lock);
    80206180:	00017517          	auipc	a0,0x17
    80206184:	43850513          	addi	a0,a0,1080 # 8021d5b8 <ecache>
    80206188:	ffffa097          	auipc	ra,0xffffa
    8020618c:	568080e7          	jalr	1384(ra) # 802006f0 <acquire>
        entry->ref++;
    80206190:	1184a783          	lw	a5,280(s1)
    80206194:	2785                	addiw	a5,a5,1
    80206196:	10f4ac23          	sw	a5,280(s1)
        release(&ecache.lock);
    8020619a:	00017517          	auipc	a0,0x17
    8020619e:	41e50513          	addi	a0,a0,1054 # 8021d5b8 <ecache>
    802061a2:	ffffa097          	auipc	ra,0xffffa
    802061a6:	5a2080e7          	jalr	1442(ra) # 80200744 <release>
}
    802061aa:	8526                	mv	a0,s1
    802061ac:	60e2                	ld	ra,24(sp)
    802061ae:	6442                	ld	s0,16(sp)
    802061b0:	64a2                	ld	s1,8(sp)
    802061b2:	6105                	addi	sp,sp,32
    802061b4:	8082                	ret

00000000802061b6 <eupdate>:
    if (!entry->dirty || entry->valid != 1) { return; }
    802061b6:	11554783          	lbu	a5,277(a0)
    802061ba:	cff1                	beqz	a5,80206296 <eupdate+0xe0>
{
    802061bc:	715d                	addi	sp,sp,-80
    802061be:	e486                	sd	ra,72(sp)
    802061c0:	e0a2                	sd	s0,64(sp)
    802061c2:	fc26                	sd	s1,56(sp)
    802061c4:	0880                	addi	s0,sp,80
    802061c6:	84aa                	mv	s1,a0
    if (!entry->dirty || entry->valid != 1) { return; }
    802061c8:	11651703          	lh	a4,278(a0)
    802061cc:	4785                	li	a5,1
    802061ce:	00f70763          	beq	a4,a5,802061dc <eupdate+0x26>
}
    802061d2:	60a6                	ld	ra,72(sp)
    802061d4:	6406                	ld	s0,64(sp)
    802061d6:	74e2                	ld	s1,56(sp)
    802061d8:	6161                	addi	sp,sp,80
    802061da:	8082                	ret
    802061dc:	f84a                	sd	s2,48(sp)
    uint entcnt = 0;
    802061de:	fc042e23          	sw	zero,-36(s0)
    uint32 off = reloc_clus(entry->parent, entry->off, 0);
    802061e2:	4601                	li	a2,0
    802061e4:	11c52583          	lw	a1,284(a0)
    802061e8:	12053503          	ld	a0,288(a0)
    802061ec:	fffff097          	auipc	ra,0xfffff
    802061f0:	22a080e7          	jalr	554(ra) # 80205416 <reloc_clus>
    rw_clus(entry->parent->cur_clus, 0, 0, (uint64) &entcnt, off, 1);
    802061f4:	1204b803          	ld	a6,288(s1)
    802061f8:	4785                	li	a5,1
    802061fa:	0005071b          	sext.w	a4,a0
    802061fe:	fdc40693          	addi	a3,s0,-36
    80206202:	4601                	li	a2,0
    80206204:	4581                	li	a1,0
    80206206:	10c82503          	lw	a0,268(a6)
    8020620a:	fffff097          	auipc	ra,0xfffff
    8020620e:	31c080e7          	jalr	796(ra) # 80205526 <rw_clus>
    entcnt &= ~LAST_LONG_ENTRY;
    80206212:	fdc42583          	lw	a1,-36(s0)
    80206216:	fbf5f593          	andi	a1,a1,-65
    8020621a:	fcb42e23          	sw	a1,-36(s0)
    off = reloc_clus(entry->parent, entry->off + (entcnt << 5), 0);
    8020621e:	0055959b          	slliw	a1,a1,0x5
    80206222:	11c4a783          	lw	a5,284(s1)
    80206226:	4601                	li	a2,0
    80206228:	9dbd                	addw	a1,a1,a5
    8020622a:	1204b503          	ld	a0,288(s1)
    8020622e:	fffff097          	auipc	ra,0xfffff
    80206232:	1e8080e7          	jalr	488(ra) # 80205416 <reloc_clus>
    80206236:	0005091b          	sext.w	s2,a0
    rw_clus(entry->parent->cur_clus, 0, 0, (uint64)&de, off, sizeof(de));
    8020623a:	1204b503          	ld	a0,288(s1)
    8020623e:	02000793          	li	a5,32
    80206242:	874a                	mv	a4,s2
    80206244:	fb840693          	addi	a3,s0,-72
    80206248:	4601                	li	a2,0
    8020624a:	4581                	li	a1,0
    8020624c:	10c52503          	lw	a0,268(a0)
    80206250:	fffff097          	auipc	ra,0xfffff
    80206254:	2d6080e7          	jalr	726(ra) # 80205526 <rw_clus>
    de.sne.fst_clus_hi = (uint16)(entry->first_clus >> 16);
    80206258:	1044a783          	lw	a5,260(s1)
    8020625c:	0107d71b          	srliw	a4,a5,0x10
    80206260:	fce41623          	sh	a4,-52(s0)
    de.sne.fst_clus_lo = (uint16)(entry->first_clus & 0xffff);
    80206264:	fcf41923          	sh	a5,-46(s0)
    de.sne.file_size = entry->file_size;
    80206268:	1084a783          	lw	a5,264(s1)
    8020626c:	fcf42a23          	sw	a5,-44(s0)
    rw_clus(entry->parent->cur_clus, 1, 0, (uint64)&de, off, sizeof(de));
    80206270:	1204b503          	ld	a0,288(s1)
    80206274:	02000793          	li	a5,32
    80206278:	874a                	mv	a4,s2
    8020627a:	fb840693          	addi	a3,s0,-72
    8020627e:	4601                	li	a2,0
    80206280:	4585                	li	a1,1
    80206282:	10c52503          	lw	a0,268(a0)
    80206286:	fffff097          	auipc	ra,0xfffff
    8020628a:	2a0080e7          	jalr	672(ra) # 80205526 <rw_clus>
    entry->dirty = 0;
    8020628e:	10048aa3          	sb	zero,277(s1)
    80206292:	7942                	ld	s2,48(sp)
    80206294:	bf3d                	j	802061d2 <eupdate+0x1c>
    80206296:	8082                	ret

0000000080206298 <eremove>:
    if (entry->valid != 1) { return; }
    80206298:	11651703          	lh	a4,278(a0)
    8020629c:	4785                	li	a5,1
    8020629e:	00f70363          	beq	a4,a5,802062a4 <eremove+0xc>
    802062a2:	8082                	ret
{
    802062a4:	7139                	addi	sp,sp,-64
    802062a6:	fc06                	sd	ra,56(sp)
    802062a8:	f822                	sd	s0,48(sp)
    802062aa:	f426                	sd	s1,40(sp)
    802062ac:	f04a                	sd	s2,32(sp)
    802062ae:	ec4e                	sd	s3,24(sp)
    802062b0:	e852                	sd	s4,16(sp)
    802062b2:	0080                	addi	s0,sp,64
    802062b4:	89aa                	mv	s3,a0
    uint entcnt = 0;
    802062b6:	fc042623          	sw	zero,-52(s0)
    uint32 off = entry->off;
    802062ba:	11c52a03          	lw	s4,284(a0)
    uint32 off2 = reloc_clus(entry->parent, off, 0);
    802062be:	4601                	li	a2,0
    802062c0:	85d2                	mv	a1,s4
    802062c2:	12053503          	ld	a0,288(a0)
    802062c6:	fffff097          	auipc	ra,0xfffff
    802062ca:	150080e7          	jalr	336(ra) # 80205416 <reloc_clus>
    802062ce:	0005049b          	sext.w	s1,a0
    rw_clus(entry->parent->cur_clus, 0, 0, (uint64) &entcnt, off2, 1);
    802062d2:	1209b503          	ld	a0,288(s3)
    802062d6:	4785                	li	a5,1
    802062d8:	8726                	mv	a4,s1
    802062da:	fcc40693          	addi	a3,s0,-52
    802062de:	4601                	li	a2,0
    802062e0:	4581                	li	a1,0
    802062e2:	10c52503          	lw	a0,268(a0)
    802062e6:	fffff097          	auipc	ra,0xfffff
    802062ea:	240080e7          	jalr	576(ra) # 80205526 <rw_clus>
    entcnt &= ~LAST_LONG_ENTRY;
    802062ee:	fcc42783          	lw	a5,-52(s0)
    802062f2:	fbf7f793          	andi	a5,a5,-65
    802062f6:	fcf42623          	sw	a5,-52(s0)
    uint8 flag = EMPTY_ENTRY;
    802062fa:	5795                	li	a5,-27
    802062fc:	fcf405a3          	sb	a5,-53(s0)
    for (int i = 0; i <= entcnt; i++) {
    80206300:	4901                	li	s2,0
        rw_clus(entry->parent->cur_clus, 1, 0, (uint64) &flag, off2, 1);
    80206302:	1209b503          	ld	a0,288(s3)
    80206306:	4785                	li	a5,1
    80206308:	8726                	mv	a4,s1
    8020630a:	fcb40693          	addi	a3,s0,-53
    8020630e:	4601                	li	a2,0
    80206310:	4585                	li	a1,1
    80206312:	10c52503          	lw	a0,268(a0)
    80206316:	fffff097          	auipc	ra,0xfffff
    8020631a:	210080e7          	jalr	528(ra) # 80205526 <rw_clus>
        off += 32;
    8020631e:	020a0a1b          	addiw	s4,s4,32
        off2 = reloc_clus(entry->parent, off, 0);
    80206322:	4601                	li	a2,0
    80206324:	85d2                	mv	a1,s4
    80206326:	1209b503          	ld	a0,288(s3)
    8020632a:	fffff097          	auipc	ra,0xfffff
    8020632e:	0ec080e7          	jalr	236(ra) # 80205416 <reloc_clus>
    80206332:	0005049b          	sext.w	s1,a0
    for (int i = 0; i <= entcnt; i++) {
    80206336:	0019079b          	addiw	a5,s2,1
    8020633a:	0007891b          	sext.w	s2,a5
    8020633e:	fcc42703          	lw	a4,-52(s0)
    80206342:	fd2770e3          	bgeu	a4,s2,80206302 <eremove+0x6a>
    entry->valid = -1;
    80206346:	57fd                	li	a5,-1
    80206348:	10f99b23          	sh	a5,278(s3)
}
    8020634c:	70e2                	ld	ra,56(sp)
    8020634e:	7442                	ld	s0,48(sp)
    80206350:	74a2                	ld	s1,40(sp)
    80206352:	7902                	ld	s2,32(sp)
    80206354:	69e2                	ld	s3,24(sp)
    80206356:	6a42                	ld	s4,16(sp)
    80206358:	6121                	addi	sp,sp,64
    8020635a:	8082                	ret

000000008020635c <etrunc>:
{
    8020635c:	7179                	addi	sp,sp,-48
    8020635e:	f406                	sd	ra,40(sp)
    80206360:	f022                	sd	s0,32(sp)
    80206362:	ec26                	sd	s1,24(sp)
    80206364:	e052                	sd	s4,0(sp)
    80206366:	1800                	addi	s0,sp,48
    80206368:	8a2a                	mv	s4,a0
    for (uint32 clus = entry->first_clus; clus >= 2 && clus < FAT32_EOC; ) {
    8020636a:	10452483          	lw	s1,260(a0)
    8020636e:	ffe4871b          	addiw	a4,s1,-2
    80206372:	100007b7          	lui	a5,0x10000
    80206376:	17d5                	addi	a5,a5,-11 # ffffff5 <_entry-0x7020000b>
    80206378:	02e7ea63          	bltu	a5,a4,802063ac <etrunc+0x50>
    8020637c:	e84a                	sd	s2,16(sp)
    8020637e:	e44e                	sd	s3,8(sp)
    80206380:	89be                	mv	s3,a5
        uint32 next = read_fat(clus);
    80206382:	0004891b          	sext.w	s2,s1
    80206386:	8526                	mv	a0,s1
    80206388:	fffff097          	auipc	ra,0xfffff
    8020638c:	e58080e7          	jalr	-424(ra) # 802051e0 <read_fat>
    80206390:	0005049b          	sext.w	s1,a0
    write_fat(cluster, 0);
    80206394:	4581                	li	a1,0
    80206396:	854a                	mv	a0,s2
    80206398:	fffff097          	auipc	ra,0xfffff
    8020639c:	ffe080e7          	jalr	-2(ra) # 80205396 <write_fat>
    for (uint32 clus = entry->first_clus; clus >= 2 && clus < FAT32_EOC; ) {
    802063a0:	ffe4879b          	addiw	a5,s1,-2
    802063a4:	fcf9ffe3          	bgeu	s3,a5,80206382 <etrunc+0x26>
    802063a8:	6942                	ld	s2,16(sp)
    802063aa:	69a2                	ld	s3,8(sp)
    entry->file_size = 0;
    802063ac:	100a2423          	sw	zero,264(s4)
    entry->first_clus = 0;
    802063b0:	100a2223          	sw	zero,260(s4)
    entry->dirty = 1;
    802063b4:	4785                	li	a5,1
    802063b6:	10fa0aa3          	sb	a5,277(s4)
}
    802063ba:	70a2                	ld	ra,40(sp)
    802063bc:	7402                	ld	s0,32(sp)
    802063be:	64e2                	ld	s1,24(sp)
    802063c0:	6a02                	ld	s4,0(sp)
    802063c2:	6145                	addi	sp,sp,48
    802063c4:	8082                	ret

00000000802063c6 <elock>:
{
    802063c6:	1141                	addi	sp,sp,-16
    802063c8:	e406                	sd	ra,8(sp)
    802063ca:	e022                	sd	s0,0(sp)
    802063cc:	0800                	addi	s0,sp,16
    if (entry == 0 || entry->ref < 1)
    802063ce:	cd19                	beqz	a0,802063ec <elock+0x26>
    802063d0:	11852783          	lw	a5,280(a0)
    802063d4:	00f05c63          	blez	a5,802063ec <elock+0x26>
    acquiresleep(&entry->lock);
    802063d8:	13850513          	addi	a0,a0,312
    802063dc:	ffffd097          	auipc	ra,0xffffd
    802063e0:	2b2080e7          	jalr	690(ra) # 8020368e <acquiresleep>
}
    802063e4:	60a2                	ld	ra,8(sp)
    802063e6:	6402                	ld	s0,0(sp)
    802063e8:	0141                	addi	sp,sp,16
    802063ea:	8082                	ret
        panic("elock");
    802063ec:	00004517          	auipc	a0,0x4
    802063f0:	82c50513          	addi	a0,a0,-2004 # 80209c18 <etext+0xc18>
    802063f4:	ffffa097          	auipc	ra,0xffffa
    802063f8:	d52080e7          	jalr	-686(ra) # 80200146 <panic>

00000000802063fc <eunlock>:
{
    802063fc:	1101                	addi	sp,sp,-32
    802063fe:	ec06                	sd	ra,24(sp)
    80206400:	e822                	sd	s0,16(sp)
    80206402:	e426                	sd	s1,8(sp)
    80206404:	e04a                	sd	s2,0(sp)
    80206406:	1000                	addi	s0,sp,32
    if (entry == 0 || !holdingsleep(&entry->lock) || entry->ref < 1)
    80206408:	c90d                	beqz	a0,8020643a <eunlock+0x3e>
    8020640a:	84aa                	mv	s1,a0
    8020640c:	13850913          	addi	s2,a0,312
    80206410:	854a                	mv	a0,s2
    80206412:	ffffd097          	auipc	ra,0xffffd
    80206416:	316080e7          	jalr	790(ra) # 80203728 <holdingsleep>
    8020641a:	c105                	beqz	a0,8020643a <eunlock+0x3e>
    8020641c:	1184a783          	lw	a5,280(s1)
    80206420:	00f05d63          	blez	a5,8020643a <eunlock+0x3e>
    releasesleep(&entry->lock);
    80206424:	854a                	mv	a0,s2
    80206426:	ffffd097          	auipc	ra,0xffffd
    8020642a:	2be080e7          	jalr	702(ra) # 802036e4 <releasesleep>
}
    8020642e:	60e2                	ld	ra,24(sp)
    80206430:	6442                	ld	s0,16(sp)
    80206432:	64a2                	ld	s1,8(sp)
    80206434:	6902                	ld	s2,0(sp)
    80206436:	6105                	addi	sp,sp,32
    80206438:	8082                	ret
        panic("eunlock");
    8020643a:	00003517          	auipc	a0,0x3
    8020643e:	7e650513          	addi	a0,a0,2022 # 80209c20 <etext+0xc20>
    80206442:	ffffa097          	auipc	ra,0xffffa
    80206446:	d04080e7          	jalr	-764(ra) # 80200146 <panic>

000000008020644a <eput>:
{
    8020644a:	1101                	addi	sp,sp,-32
    8020644c:	ec06                	sd	ra,24(sp)
    8020644e:	e822                	sd	s0,16(sp)
    80206450:	e426                	sd	s1,8(sp)
    80206452:	1000                	addi	s0,sp,32
    80206454:	84aa                	mv	s1,a0
    acquire(&ecache.lock);
    80206456:	00017517          	auipc	a0,0x17
    8020645a:	16250513          	addi	a0,a0,354 # 8021d5b8 <ecache>
    8020645e:	ffffa097          	auipc	ra,0xffffa
    80206462:	292080e7          	jalr	658(ra) # 802006f0 <acquire>
    if (entry != &root && entry->valid != 0 && entry->ref == 1) {
    80206466:	00017797          	auipc	a5,0x17
    8020646a:	fea78793          	addi	a5,a5,-22 # 8021d450 <root>
    8020646e:	00f48a63          	beq	s1,a5,80206482 <eput+0x38>
    80206472:	11649783          	lh	a5,278(s1)
    80206476:	c791                	beqz	a5,80206482 <eput+0x38>
    80206478:	1184a703          	lw	a4,280(s1)
    8020647c:	4785                	li	a5,1
    8020647e:	02f70463          	beq	a4,a5,802064a6 <eput+0x5c>
    entry->ref--;
    80206482:	1184a783          	lw	a5,280(s1)
    80206486:	37fd                	addiw	a5,a5,-1
    80206488:	10f4ac23          	sw	a5,280(s1)
    release(&ecache.lock);
    8020648c:	00017517          	auipc	a0,0x17
    80206490:	12c50513          	addi	a0,a0,300 # 8021d5b8 <ecache>
    80206494:	ffffa097          	auipc	ra,0xffffa
    80206498:	2b0080e7          	jalr	688(ra) # 80200744 <release>
}
    8020649c:	60e2                	ld	ra,24(sp)
    8020649e:	6442                	ld	s0,16(sp)
    802064a0:	64a2                	ld	s1,8(sp)
    802064a2:	6105                	addi	sp,sp,32
    802064a4:	8082                	ret
    802064a6:	e04a                	sd	s2,0(sp)
        acquiresleep(&entry->lock);
    802064a8:	13848913          	addi	s2,s1,312
    802064ac:	854a                	mv	a0,s2
    802064ae:	ffffd097          	auipc	ra,0xffffd
    802064b2:	1e0080e7          	jalr	480(ra) # 8020368e <acquiresleep>
        entry->next->prev = entry->prev;
    802064b6:	1284b703          	ld	a4,296(s1)
    802064ba:	1304b783          	ld	a5,304(s1)
    802064be:	12f73823          	sd	a5,304(a4)
        entry->prev->next = entry->next;
    802064c2:	1284b703          	ld	a4,296(s1)
    802064c6:	12e7b423          	sd	a4,296(a5)
        entry->next = root.next;
    802064ca:	00017797          	auipc	a5,0x17
    802064ce:	f5e78793          	addi	a5,a5,-162 # 8021d428 <fat>
    802064d2:	1507b703          	ld	a4,336(a5)
    802064d6:	12e4b423          	sd	a4,296(s1)
        entry->prev = &root;
    802064da:	00017697          	auipc	a3,0x17
    802064de:	f7668693          	addi	a3,a3,-138 # 8021d450 <root>
    802064e2:	12d4b823          	sd	a3,304(s1)
        root.next->prev = entry;
    802064e6:	12973823          	sd	s1,304(a4)
        root.next = entry;
    802064ea:	1497b823          	sd	s1,336(a5)
        release(&ecache.lock);
    802064ee:	00017517          	auipc	a0,0x17
    802064f2:	0ca50513          	addi	a0,a0,202 # 8021d5b8 <ecache>
    802064f6:	ffffa097          	auipc	ra,0xffffa
    802064fa:	24e080e7          	jalr	590(ra) # 80200744 <release>
        if (entry->valid == -1) {       // this means some one has called eremove()
    802064fe:	11649703          	lh	a4,278(s1)
    80206502:	57fd                	li	a5,-1
    80206504:	06f70463          	beq	a4,a5,8020656c <eput+0x122>
            elock(entry->parent);
    80206508:	1204b503          	ld	a0,288(s1)
    8020650c:	00000097          	auipc	ra,0x0
    80206510:	eba080e7          	jalr	-326(ra) # 802063c6 <elock>
            eupdate(entry);
    80206514:	8526                	mv	a0,s1
    80206516:	00000097          	auipc	ra,0x0
    8020651a:	ca0080e7          	jalr	-864(ra) # 802061b6 <eupdate>
            eunlock(entry->parent);
    8020651e:	1204b503          	ld	a0,288(s1)
    80206522:	00000097          	auipc	ra,0x0
    80206526:	eda080e7          	jalr	-294(ra) # 802063fc <eunlock>
        releasesleep(&entry->lock);
    8020652a:	854a                	mv	a0,s2
    8020652c:	ffffd097          	auipc	ra,0xffffd
    80206530:	1b8080e7          	jalr	440(ra) # 802036e4 <releasesleep>
        struct dirent *eparent = entry->parent;
    80206534:	1204b903          	ld	s2,288(s1)
        acquire(&ecache.lock);
    80206538:	00017517          	auipc	a0,0x17
    8020653c:	08050513          	addi	a0,a0,128 # 8021d5b8 <ecache>
    80206540:	ffffa097          	auipc	ra,0xffffa
    80206544:	1b0080e7          	jalr	432(ra) # 802006f0 <acquire>
        entry->ref--;
    80206548:	1184a783          	lw	a5,280(s1)
    8020654c:	37fd                	addiw	a5,a5,-1
    8020654e:	10f4ac23          	sw	a5,280(s1)
        release(&ecache.lock);
    80206552:	00017517          	auipc	a0,0x17
    80206556:	06650513          	addi	a0,a0,102 # 8021d5b8 <ecache>
    8020655a:	ffffa097          	auipc	ra,0xffffa
    8020655e:	1ea080e7          	jalr	490(ra) # 80200744 <release>
        if (entry->ref == 0) {
    80206562:	1184a783          	lw	a5,280(s1)
    80206566:	cb89                	beqz	a5,80206578 <eput+0x12e>
    80206568:	6902                	ld	s2,0(sp)
    8020656a:	bf0d                	j	8020649c <eput+0x52>
            etrunc(entry);
    8020656c:	8526                	mv	a0,s1
    8020656e:	00000097          	auipc	ra,0x0
    80206572:	dee080e7          	jalr	-530(ra) # 8020635c <etrunc>
    80206576:	bf55                	j	8020652a <eput+0xe0>
            eput(eparent);
    80206578:	854a                	mv	a0,s2
    8020657a:	00000097          	auipc	ra,0x0
    8020657e:	ed0080e7          	jalr	-304(ra) # 8020644a <eput>
    80206582:	6902                	ld	s2,0(sp)
    80206584:	bf21                	j	8020649c <eput+0x52>

0000000080206586 <estat>:
{
    80206586:	1101                	addi	sp,sp,-32
    80206588:	ec06                	sd	ra,24(sp)
    8020658a:	e822                	sd	s0,16(sp)
    8020658c:	e426                	sd	s1,8(sp)
    8020658e:	e04a                	sd	s2,0(sp)
    80206590:	1000                	addi	s0,sp,32
    80206592:	892a                	mv	s2,a0
    80206594:	84ae                	mv	s1,a1
    strncpy(st->name, de->filename, STAT_MAX_NAME);
    80206596:	02000613          	li	a2,32
    8020659a:	85aa                	mv	a1,a0
    8020659c:	8526                	mv	a0,s1
    8020659e:	ffffa097          	auipc	ra,0xffffa
    802065a2:	2fc080e7          	jalr	764(ra) # 8020089a <strncpy>
    st->type = (de->attribute & ATTR_DIRECTORY) ? T_DIR : T_FILE;
    802065a6:	10094783          	lbu	a5,256(s2)
    802065aa:	8bc1                	andi	a5,a5,16
    802065ac:	0017b793          	seqz	a5,a5
    802065b0:	0785                	addi	a5,a5,1
    802065b2:	02f49423          	sh	a5,40(s1)
    st->dev = de->dev;
    802065b6:	11494783          	lbu	a5,276(s2)
    802065ba:	d0dc                	sw	a5,36(s1)
    st->size = de->file_size;
    802065bc:	10896783          	lwu	a5,264(s2)
    802065c0:	f89c                	sd	a5,48(s1)
}
    802065c2:	60e2                	ld	ra,24(sp)
    802065c4:	6442                	ld	s0,16(sp)
    802065c6:	64a2                	ld	s1,8(sp)
    802065c8:	6902                	ld	s2,0(sp)
    802065ca:	6105                	addi	sp,sp,32
    802065cc:	8082                	ret

00000000802065ce <enext>:
 * @return  -1      meet the end of dir
 *          0       find empty slots
 *          1       find a file with all its entries
 */
int enext(struct dirent *dp, struct dirent *ep, uint off, int *count)
{
    802065ce:	7119                	addi	sp,sp,-128
    802065d0:	fc86                	sd	ra,120(sp)
    802065d2:	f8a2                	sd	s0,112(sp)
    802065d4:	0100                	addi	s0,sp,128
    if (!(dp->attribute & ATTR_DIRECTORY))
    802065d6:	10054783          	lbu	a5,256(a0)
    802065da:	8bc1                	andi	a5,a5,16
    802065dc:	cf8d                	beqz	a5,80206616 <enext+0x48>
    802065de:	f4a6                	sd	s1,104(sp)
    802065e0:	f0ca                	sd	s2,96(sp)
    802065e2:	ecce                	sd	s3,88(sp)
    802065e4:	e8d2                	sd	s4,80(sp)
    802065e6:	892a                	mv	s2,a0
    802065e8:	89ae                	mv	s3,a1
    802065ea:	84b2                	mv	s1,a2
    802065ec:	8a36                	mv	s4,a3
        panic("enext not dir");
    if (ep->valid)
    802065ee:	11659783          	lh	a5,278(a1)
    802065f2:	e3b9                	bnez	a5,80206638 <enext+0x6a>
        panic("enext ep valid");
    if (off % 32)
    802065f4:	01f67793          	andi	a5,a2,31
    802065f8:	efa9                	bnez	a5,80206652 <enext+0x84>
        panic("enext not align");
    if (dp->valid != 1) { return -1; }
    802065fa:	11651703          	lh	a4,278(a0)
    802065fe:	4785                	li	a5,1
    80206600:	557d                	li	a0,-1
    80206602:	06f70563          	beq	a4,a5,8020666c <enext+0x9e>
            read_entry_info(ep, &de);
            return 1;
        }
    }
    return -1;
}
    80206606:	74a6                	ld	s1,104(sp)
    80206608:	7906                	ld	s2,96(sp)
    8020660a:	69e6                	ld	s3,88(sp)
    8020660c:	6a46                	ld	s4,80(sp)
    8020660e:	70e6                	ld	ra,120(sp)
    80206610:	7446                	ld	s0,112(sp)
    80206612:	6109                	addi	sp,sp,128
    80206614:	8082                	ret
    80206616:	f4a6                	sd	s1,104(sp)
    80206618:	f0ca                	sd	s2,96(sp)
    8020661a:	ecce                	sd	s3,88(sp)
    8020661c:	e8d2                	sd	s4,80(sp)
    8020661e:	e4d6                	sd	s5,72(sp)
    80206620:	e0da                	sd	s6,64(sp)
    80206622:	fc5e                	sd	s7,56(sp)
    80206624:	f862                	sd	s8,48(sp)
    80206626:	f466                	sd	s9,40(sp)
        panic("enext not dir");
    80206628:	00003517          	auipc	a0,0x3
    8020662c:	60050513          	addi	a0,a0,1536 # 80209c28 <etext+0xc28>
    80206630:	ffffa097          	auipc	ra,0xffffa
    80206634:	b16080e7          	jalr	-1258(ra) # 80200146 <panic>
    80206638:	e4d6                	sd	s5,72(sp)
    8020663a:	e0da                	sd	s6,64(sp)
    8020663c:	fc5e                	sd	s7,56(sp)
    8020663e:	f862                	sd	s8,48(sp)
    80206640:	f466                	sd	s9,40(sp)
        panic("enext ep valid");
    80206642:	00003517          	auipc	a0,0x3
    80206646:	5f650513          	addi	a0,a0,1526 # 80209c38 <etext+0xc38>
    8020664a:	ffffa097          	auipc	ra,0xffffa
    8020664e:	afc080e7          	jalr	-1284(ra) # 80200146 <panic>
    80206652:	e4d6                	sd	s5,72(sp)
    80206654:	e0da                	sd	s6,64(sp)
    80206656:	fc5e                	sd	s7,56(sp)
    80206658:	f862                	sd	s8,48(sp)
    8020665a:	f466                	sd	s9,40(sp)
        panic("enext not align");
    8020665c:	00003517          	auipc	a0,0x3
    80206660:	5ec50513          	addi	a0,a0,1516 # 80209c48 <etext+0xc48>
    80206664:	ffffa097          	auipc	ra,0xffffa
    80206668:	ae2080e7          	jalr	-1310(ra) # 80200146 <panic>
    8020666c:	e4d6                	sd	s5,72(sp)
    8020666e:	e0da                	sd	s6,64(sp)
    80206670:	fc5e                	sd	s7,56(sp)
    80206672:	f862                	sd	s8,48(sp)
    80206674:	f466                	sd	s9,40(sp)
    *count = 0;
    80206676:	0006a023          	sw	zero,0(a3)
    memset(ep->filename, 0, FAT32_MAX_FILENAME + 1);
    8020667a:	10000613          	li	a2,256
    8020667e:	4581                	li	a1,0
    80206680:	854e                	mv	a0,s3
    80206682:	ffffa097          	auipc	ra,0xffffa
    80206686:	10a080e7          	jalr	266(ra) # 8020078c <memset>
    int cnt = 0;
    8020668a:	4a81                	li	s5,0
    for (int off2; (off2 = reloc_clus(dp, off, 0)) != -1; off += 32) {
    8020668c:	5b7d                	li	s6,-1
        if (de.lne.order == EMPTY_ENTRY) {
    8020668e:	0e500b93          	li	s7,229
        if (de.lne.attr == ATTR_LONG_NAME) {
    80206692:	4c3d                	li	s8,15
            if (lcnt < 1 || lcnt > (FAT32_MAX_FILENAME + CHAR_LONG_NAME - 1) / CHAR_LONG_NAME)
    80206694:	4ccd                	li	s9,19
    for (int off2; (off2 = reloc_clus(dp, off, 0)) != -1; off += 32) {
    80206696:	a82d                	j	802066d0 <enext+0x102>
            cnt++;
    80206698:	2a85                	addiw	s5,s5,1
            continue;
    8020669a:	a80d                	j	802066cc <enext+0xfe>
            *count = cnt;
    8020669c:	015a2023          	sw	s5,0(s4)
            return 0;
    802066a0:	4501                	li	a0,0
    802066a2:	6aa6                	ld	s5,72(sp)
    802066a4:	6b06                	ld	s6,64(sp)
    802066a6:	7be2                	ld	s7,56(sp)
    802066a8:	7c42                	ld	s8,48(sp)
    802066aa:	7ca2                	ld	s9,40(sp)
    802066ac:	bfa9                	j	80206606 <enext+0x38>
            read_entry_name(ep->filename + (lcnt - 1) * CHAR_LONG_NAME, &de);
    802066ae:	fff7079b          	addiw	a5,a4,-1
    802066b2:	0017951b          	slliw	a0,a5,0x1
    802066b6:	9d3d                	addw	a0,a0,a5
    802066b8:	0025151b          	slliw	a0,a0,0x2
    802066bc:	9d3d                	addw	a0,a0,a5
    802066be:	f8040593          	addi	a1,s0,-128
    802066c2:	954e                	add	a0,a0,s3
    802066c4:	fffff097          	auipc	ra,0xfffff
    802066c8:	0ea080e7          	jalr	234(ra) # 802057ae <read_entry_name>
    for (int off2; (off2 = reloc_clus(dp, off, 0)) != -1; off += 32) {
    802066cc:	0204849b          	addiw	s1,s1,32
    802066d0:	4601                	li	a2,0
    802066d2:	85a6                	mv	a1,s1
    802066d4:	854a                	mv	a0,s2
    802066d6:	fffff097          	auipc	ra,0xfffff
    802066da:	d40080e7          	jalr	-704(ra) # 80205416 <reloc_clus>
    802066de:	0b650963          	beq	a0,s6,80206790 <enext+0x1c2>
        if (rw_clus(dp->cur_clus, 0, 0, (uint64)&de, off2, 32) != 32 || de.lne.order == END_OF_ENTRY) {
    802066e2:	02000793          	li	a5,32
    802066e6:	0005071b          	sext.w	a4,a0
    802066ea:	f8040693          	addi	a3,s0,-128
    802066ee:	4601                	li	a2,0
    802066f0:	4581                	li	a1,0
    802066f2:	10c92503          	lw	a0,268(s2)
    802066f6:	fffff097          	auipc	ra,0xfffff
    802066fa:	e30080e7          	jalr	-464(ra) # 80205526 <rw_clus>
    802066fe:	2501                	sext.w	a0,a0
    80206700:	02000793          	li	a5,32
    80206704:	08f51c63          	bne	a0,a5,8020679c <enext+0x1ce>
    80206708:	f8044783          	lbu	a5,-128(s0)
    8020670c:	cfd9                	beqz	a5,802067aa <enext+0x1dc>
        if (de.lne.order == EMPTY_ENTRY) {
    8020670e:	f97785e3          	beq	a5,s7,80206698 <enext+0xca>
        } else if (cnt) {
    80206712:	f80a95e3          	bnez	s5,8020669c <enext+0xce>
        if (de.lne.attr == ATTR_LONG_NAME) {
    80206716:	f8b44703          	lbu	a4,-117(s0)
    8020671a:	03871063          	bne	a4,s8,8020673a <enext+0x16c>
            int lcnt = de.lne.order & ~LAST_LONG_ENTRY;
    8020671e:	0bf7f713          	andi	a4,a5,191
            if (lcnt < 1 || lcnt > (FAT32_MAX_FILENAME + CHAR_LONG_NAME - 1) / CHAR_LONG_NAME)
    80206722:	fff7069b          	addiw	a3,a4,-1
    80206726:	08dce963          	bltu	s9,a3,802067b8 <enext+0x1ea>
            if (de.lne.order & LAST_LONG_ENTRY) {
    8020672a:	0407f793          	andi	a5,a5,64
    8020672e:	d3c1                	beqz	a5,802066ae <enext+0xe0>
                *count = lcnt + 1;                              // plus the s-n-e;
    80206730:	0017079b          	addiw	a5,a4,1
    80206734:	00fa2023          	sw	a5,0(s4)
    80206738:	bf9d                	j	802066ae <enext+0xe0>
            if (ep->filename[0] == 0) {
    8020673a:	0009c783          	lbu	a5,0(s3)
    8020673e:	cf95                	beqz	a5,8020677a <enext+0x1ac>
    entry->attribute = d->sne.attr;
    80206740:	f8b44783          	lbu	a5,-117(s0)
    80206744:	10f98023          	sb	a5,256(s3)
    entry->first_clus = ((uint32)d->sne.fst_clus_hi << 16) | d->sne.fst_clus_lo;
    80206748:	f9445783          	lhu	a5,-108(s0)
    8020674c:	0107979b          	slliw	a5,a5,0x10
    80206750:	f9a45703          	lhu	a4,-102(s0)
    80206754:	8fd9                	or	a5,a5,a4
    80206756:	2781                	sext.w	a5,a5
    80206758:	10f9a223          	sw	a5,260(s3)
    entry->file_size = d->sne.file_size;
    8020675c:	f9c42703          	lw	a4,-100(s0)
    80206760:	10e9a423          	sw	a4,264(s3)
    entry->cur_clus = entry->first_clus;
    80206764:	10f9a623          	sw	a5,268(s3)
    entry->clus_cnt = 0;
    80206768:	1009a823          	sw	zero,272(s3)
            return 1;
    8020676c:	4505                	li	a0,1
}
    8020676e:	6aa6                	ld	s5,72(sp)
    80206770:	6b06                	ld	s6,64(sp)
    80206772:	7be2                	ld	s7,56(sp)
    80206774:	7c42                	ld	s8,48(sp)
    80206776:	7ca2                	ld	s9,40(sp)
    80206778:	b579                	j	80206606 <enext+0x38>
                *count = 1;
    8020677a:	4785                	li	a5,1
    8020677c:	00fa2023          	sw	a5,0(s4)
                read_entry_name(ep->filename, &de);
    80206780:	f8040593          	addi	a1,s0,-128
    80206784:	854e                	mv	a0,s3
    80206786:	fffff097          	auipc	ra,0xfffff
    8020678a:	028080e7          	jalr	40(ra) # 802057ae <read_entry_name>
    8020678e:	bf4d                	j	80206740 <enext+0x172>
    80206790:	6aa6                	ld	s5,72(sp)
    80206792:	6b06                	ld	s6,64(sp)
    80206794:	7be2                	ld	s7,56(sp)
    80206796:	7c42                	ld	s8,48(sp)
    80206798:	7ca2                	ld	s9,40(sp)
    8020679a:	b5b5                	j	80206606 <enext+0x38>
            return -1;
    8020679c:	557d                	li	a0,-1
    8020679e:	6aa6                	ld	s5,72(sp)
    802067a0:	6b06                	ld	s6,64(sp)
    802067a2:	7be2                	ld	s7,56(sp)
    802067a4:	7c42                	ld	s8,48(sp)
    802067a6:	7ca2                	ld	s9,40(sp)
    802067a8:	bdb9                	j	80206606 <enext+0x38>
    802067aa:	557d                	li	a0,-1
    802067ac:	6aa6                	ld	s5,72(sp)
    802067ae:	6b06                	ld	s6,64(sp)
    802067b0:	7be2                	ld	s7,56(sp)
    802067b2:	7c42                	ld	s8,48(sp)
    802067b4:	7ca2                	ld	s9,40(sp)
    802067b6:	bd81                	j	80206606 <enext+0x38>
                return -1;
    802067b8:	557d                	li	a0,-1
    802067ba:	6aa6                	ld	s5,72(sp)
    802067bc:	6b06                	ld	s6,64(sp)
    802067be:	7be2                	ld	s7,56(sp)
    802067c0:	7c42                	ld	s8,48(sp)
    802067c2:	7ca2                	ld	s9,40(sp)
    802067c4:	b589                	j	80206606 <enext+0x38>

00000000802067c6 <dirlookup>:
 * @param   dp          entry of a directory file
 * @param   filename    target filename
 * @param   poff        offset of proper empty entry slots from the beginning of the dir
 */
struct dirent *dirlookup(struct dirent *dp, char *filename, uint *poff)
{
    802067c6:	715d                	addi	sp,sp,-80
    802067c8:	e486                	sd	ra,72(sp)
    802067ca:	e0a2                	sd	s0,64(sp)
    802067cc:	fc26                	sd	s1,56(sp)
    802067ce:	f84a                	sd	s2,48(sp)
    802067d0:	f44e                	sd	s3,40(sp)
    802067d2:	ec56                	sd	s5,24(sp)
    802067d4:	0880                	addi	s0,sp,80
    if (!(dp->attribute & ATTR_DIRECTORY))
    802067d6:	10054783          	lbu	a5,256(a0)
    802067da:	8bc1                	andi	a5,a5,16
    802067dc:	cbb1                	beqz	a5,80206830 <dirlookup+0x6a>
    802067de:	84aa                	mv	s1,a0
    802067e0:	89ae                	mv	s3,a1
    802067e2:	8ab2                	mv	s5,a2
        panic("dirlookup not DIR");
    if (strncmp(filename, ".", FAT32_MAX_FILENAME) == 0) {
    802067e4:	0ff00613          	li	a2,255
    802067e8:	00003597          	auipc	a1,0x3
    802067ec:	48858593          	addi	a1,a1,1160 # 80209c70 <etext+0xc70>
    802067f0:	854e                	mv	a0,s3
    802067f2:	ffffa097          	auipc	ra,0xffffa
    802067f6:	072080e7          	jalr	114(ra) # 80200864 <strncmp>
    802067fa:	c529                	beqz	a0,80206844 <dirlookup+0x7e>
        return edup(dp);
    } else if (strncmp(filename, "..", FAT32_MAX_FILENAME) == 0) {
    802067fc:	0ff00613          	li	a2,255
    80206800:	00003597          	auipc	a1,0x3
    80206804:	47858593          	addi	a1,a1,1144 # 80209c78 <etext+0xc78>
    80206808:	854e                	mv	a0,s3
    8020680a:	ffffa097          	auipc	ra,0xffffa
    8020680e:	05a080e7          	jalr	90(ra) # 80200864 <strncmp>
    80206812:	ed39                	bnez	a0,80206870 <dirlookup+0xaa>
        if (dp == &root) {
    80206814:	00017797          	auipc	a5,0x17
    80206818:	c3c78793          	addi	a5,a5,-964 # 8021d450 <root>
    8020681c:	04f48363          	beq	s1,a5,80206862 <dirlookup+0x9c>
            return edup(&root);
        }
        return edup(dp->parent);
    80206820:	1204b503          	ld	a0,288(s1)
    80206824:	00000097          	auipc	ra,0x0
    80206828:	94e080e7          	jalr	-1714(ra) # 80206172 <edup>
    8020682c:	892a                	mv	s2,a0
    8020682e:	a00d                	j	80206850 <dirlookup+0x8a>
    80206830:	f052                	sd	s4,32(sp)
    80206832:	e85a                	sd	s6,16(sp)
        panic("dirlookup not DIR");
    80206834:	00003517          	auipc	a0,0x3
    80206838:	42450513          	addi	a0,a0,1060 # 80209c58 <etext+0xc58>
    8020683c:	ffffa097          	auipc	ra,0xffffa
    80206840:	90a080e7          	jalr	-1782(ra) # 80200146 <panic>
        return edup(dp);
    80206844:	8526                	mv	a0,s1
    80206846:	00000097          	auipc	ra,0x0
    8020684a:	92c080e7          	jalr	-1748(ra) # 80206172 <edup>
    8020684e:	892a                	mv	s2,a0
    if (poff) {
        *poff = off;
    }
    eput(ep);
    return NULL;
}
    80206850:	854a                	mv	a0,s2
    80206852:	60a6                	ld	ra,72(sp)
    80206854:	6406                	ld	s0,64(sp)
    80206856:	74e2                	ld	s1,56(sp)
    80206858:	7942                	ld	s2,48(sp)
    8020685a:	79a2                	ld	s3,40(sp)
    8020685c:	6ae2                	ld	s5,24(sp)
    8020685e:	6161                	addi	sp,sp,80
    80206860:	8082                	ret
            return edup(&root);
    80206862:	853e                	mv	a0,a5
    80206864:	00000097          	auipc	ra,0x0
    80206868:	90e080e7          	jalr	-1778(ra) # 80206172 <edup>
    8020686c:	892a                	mv	s2,a0
    8020686e:	b7cd                	j	80206850 <dirlookup+0x8a>
    if (dp->valid != 1) {
    80206870:	11649703          	lh	a4,278(s1)
    80206874:	4785                	li	a5,1
        return NULL;
    80206876:	4901                	li	s2,0
    if (dp->valid != 1) {
    80206878:	fcf71ce3          	bne	a4,a5,80206850 <dirlookup+0x8a>
    struct dirent *ep = eget(dp, filename);
    8020687c:	85ce                	mv	a1,s3
    8020687e:	8526                	mv	a0,s1
    80206880:	fffff097          	auipc	ra,0xfffff
    80206884:	e20080e7          	jalr	-480(ra) # 802056a0 <eget>
    80206888:	892a                	mv	s2,a0
    if (ep->valid == 1) { return ep; }                               // ecache hits
    8020688a:	11651703          	lh	a4,278(a0)
    8020688e:	4785                	li	a5,1
    80206890:	fcf700e3          	beq	a4,a5,80206850 <dirlookup+0x8a>
    80206894:	f052                	sd	s4,32(sp)
    80206896:	e85a                	sd	s6,16(sp)
    int len = strlen(filename);
    80206898:	854e                	mv	a0,s3
    8020689a:	ffffa097          	auipc	ra,0xffffa
    8020689e:	06e080e7          	jalr	110(ra) # 80200908 <strlen>
    int count = 0;
    802068a2:	fa042e23          	sw	zero,-68(s0)
    reloc_clus(dp, 0, 0);
    802068a6:	4601                	li	a2,0
    802068a8:	4581                	li	a1,0
    802068aa:	8526                	mv	a0,s1
    802068ac:	fffff097          	auipc	ra,0xfffff
    802068b0:	b6a080e7          	jalr	-1174(ra) # 80205416 <reloc_clus>
    uint off = 0;
    802068b4:	4a01                	li	s4,0
    while ((type = enext(dp, ep, off, &count) != -1)) {
    802068b6:	5b7d                	li	s6,-1
    802068b8:	fbc40693          	addi	a3,s0,-68
    802068bc:	8652                	mv	a2,s4
    802068be:	85ca                	mv	a1,s2
    802068c0:	8526                	mv	a0,s1
    802068c2:	00000097          	auipc	ra,0x0
    802068c6:	d0c080e7          	jalr	-756(ra) # 802065ce <enext>
    802068ca:	03650f63          	beq	a0,s6,80206908 <dirlookup+0x142>
        } else if (filename_equal(filename, ep->filename)) {
    802068ce:	85ca                	mv	a1,s2
    802068d0:	854e                	mv	a0,s3
    802068d2:	fffff097          	auipc	ra,0xfffff
    802068d6:	8ac080e7          	jalr	-1876(ra) # 8020517e <filename_equal>
    802068da:	e901                	bnez	a0,802068ea <dirlookup+0x124>
        off += count << 5;
    802068dc:	fbc42783          	lw	a5,-68(s0)
    802068e0:	0057979b          	slliw	a5,a5,0x5
    802068e4:	01478a3b          	addw	s4,a5,s4
    802068e8:	bfc1                	j	802068b8 <dirlookup+0xf2>
            ep->parent = edup(dp);
    802068ea:	8526                	mv	a0,s1
    802068ec:	00000097          	auipc	ra,0x0
    802068f0:	886080e7          	jalr	-1914(ra) # 80206172 <edup>
    802068f4:	12a93023          	sd	a0,288(s2)
            ep->off = off;
    802068f8:	11492e23          	sw	s4,284(s2)
            ep->valid = 1;
    802068fc:	4785                	li	a5,1
    802068fe:	10f91b23          	sh	a5,278(s2)
            return ep;
    80206902:	7a02                	ld	s4,32(sp)
    80206904:	6b42                	ld	s6,16(sp)
    80206906:	b7a9                	j	80206850 <dirlookup+0x8a>
    if (poff) {
    80206908:	000a8463          	beqz	s5,80206910 <dirlookup+0x14a>
        *poff = off;
    8020690c:	014aa023          	sw	s4,0(s5)
    eput(ep);
    80206910:	854a                	mv	a0,s2
    80206912:	00000097          	auipc	ra,0x0
    80206916:	b38080e7          	jalr	-1224(ra) # 8020644a <eput>
    return NULL;
    8020691a:	4901                	li	s2,0
    8020691c:	7a02                	ld	s4,32(sp)
    8020691e:	6b42                	ld	s6,16(sp)
    80206920:	bf05                	j	80206850 <dirlookup+0x8a>

0000000080206922 <ealloc>:
{
    80206922:	715d                	addi	sp,sp,-80
    80206924:	e486                	sd	ra,72(sp)
    80206926:	e0a2                	sd	s0,64(sp)
    80206928:	f84a                	sd	s2,48(sp)
    8020692a:	0880                	addi	s0,sp,80
    8020692c:	892a                	mv	s2,a0
    if (!(dp->attribute & ATTR_DIRECTORY)) {
    8020692e:	10054783          	lbu	a5,256(a0)
    80206932:	8bc1                	andi	a5,a5,16
    80206934:	cba1                	beqz	a5,80206984 <ealloc+0x62>
    80206936:	fc26                	sd	s1,56(sp)
    80206938:	f052                	sd	s4,32(sp)
    8020693a:	852e                	mv	a0,a1
    8020693c:	8a32                	mv	s4,a2
    if (dp->valid != 1 || !(name = formatname(name))) {        // detect illegal character
    8020693e:	11691703          	lh	a4,278(s2)
    80206942:	4785                	li	a5,1
        return NULL;
    80206944:	4481                	li	s1,0
    if (dp->valid != 1 || !(name = formatname(name))) {        // detect illegal character
    80206946:	02f71763          	bne	a4,a5,80206974 <ealloc+0x52>
    8020694a:	f44e                	sd	s3,40(sp)
    8020694c:	fffff097          	auipc	ra,0xfffff
    80206950:	3a6080e7          	jalr	934(ra) # 80205cf2 <formatname>
    80206954:	89aa                	mv	s3,a0
    80206956:	10050c63          	beqz	a0,80206a6e <ealloc+0x14c>
    uint off = 0;
    8020695a:	fa042e23          	sw	zero,-68(s0)
    if ((ep = dirlookup(dp, name, &off)) != 0) {      // entry exists
    8020695e:	fbc40613          	addi	a2,s0,-68
    80206962:	85aa                	mv	a1,a0
    80206964:	854a                	mv	a0,s2
    80206966:	00000097          	auipc	ra,0x0
    8020696a:	e60080e7          	jalr	-416(ra) # 802067c6 <dirlookup>
    8020696e:	84aa                	mv	s1,a0
    80206970:	c515                	beqz	a0,8020699c <ealloc+0x7a>
    80206972:	79a2                	ld	s3,40(sp)
}
    80206974:	8526                	mv	a0,s1
    80206976:	74e2                	ld	s1,56(sp)
    80206978:	7a02                	ld	s4,32(sp)
    8020697a:	60a6                	ld	ra,72(sp)
    8020697c:	6406                	ld	s0,64(sp)
    8020697e:	7942                	ld	s2,48(sp)
    80206980:	6161                	addi	sp,sp,80
    80206982:	8082                	ret
    80206984:	fc26                	sd	s1,56(sp)
    80206986:	f44e                	sd	s3,40(sp)
    80206988:	f052                	sd	s4,32(sp)
    8020698a:	ec56                	sd	s5,24(sp)
        panic("ealloc not dir");
    8020698c:	00003517          	auipc	a0,0x3
    80206990:	2f450513          	addi	a0,a0,756 # 80209c80 <etext+0xc80>
    80206994:	ffff9097          	auipc	ra,0xffff9
    80206998:	7b2080e7          	jalr	1970(ra) # 80200146 <panic>
    8020699c:	ec56                	sd	s5,24(sp)
    ep = eget(dp, name);
    8020699e:	85ce                	mv	a1,s3
    802069a0:	854a                	mv	a0,s2
    802069a2:	fffff097          	auipc	ra,0xfffff
    802069a6:	cfe080e7          	jalr	-770(ra) # 802056a0 <eget>
    802069aa:	84aa                	mv	s1,a0
    elock(ep);
    802069ac:	00000097          	auipc	ra,0x0
    802069b0:	a1a080e7          	jalr	-1510(ra) # 802063c6 <elock>
    ep->attribute = attr;
    802069b4:	11448023          	sb	s4,256(s1)
    ep->file_size = 0;
    802069b8:	1004a423          	sw	zero,264(s1)
    ep->first_clus = 0;
    802069bc:	1004a223          	sw	zero,260(s1)
    ep->parent = edup(dp);
    802069c0:	854a                	mv	a0,s2
    802069c2:	fffff097          	auipc	ra,0xfffff
    802069c6:	7b0080e7          	jalr	1968(ra) # 80206172 <edup>
    802069ca:	12a4b023          	sd	a0,288(s1)
    ep->off = off;
    802069ce:	fbc42a83          	lw	s5,-68(s0)
    802069d2:	1154ae23          	sw	s5,284(s1)
    ep->clus_cnt = 0;
    802069d6:	1004a823          	sw	zero,272(s1)
    ep->cur_clus = 0;
    802069da:	1004a623          	sw	zero,268(s1)
    ep->dirty = 0;
    802069de:	10048aa3          	sb	zero,277(s1)
    strncpy(ep->filename, name, FAT32_MAX_FILENAME);
    802069e2:	0ff00613          	li	a2,255
    802069e6:	85ce                	mv	a1,s3
    802069e8:	8526                	mv	a0,s1
    802069ea:	ffffa097          	auipc	ra,0xffffa
    802069ee:	eb0080e7          	jalr	-336(ra) # 8020089a <strncpy>
    ep->filename[FAT32_MAX_FILENAME] = '\0';
    802069f2:	0e048fa3          	sb	zero,255(s1)
    if (attr == ATTR_DIRECTORY) {    // generate "." and ".." for ep
    802069f6:	47c1                	li	a5,16
    802069f8:	02fa0a63          	beq	s4,a5,80206a2c <ealloc+0x10a>
        ep->attribute |= ATTR_ARCHIVE;
    802069fc:	1004c783          	lbu	a5,256(s1)
    80206a00:	0207e793          	ori	a5,a5,32
    80206a04:	10f48023          	sb	a5,256(s1)
    emake(dp, ep, off);
    80206a08:	8656                	mv	a2,s5
    80206a0a:	85a6                	mv	a1,s1
    80206a0c:	854a                	mv	a0,s2
    80206a0e:	fffff097          	auipc	ra,0xfffff
    80206a12:	3a4080e7          	jalr	932(ra) # 80205db2 <emake>
    ep->valid = 1;
    80206a16:	4785                	li	a5,1
    80206a18:	10f49b23          	sh	a5,278(s1)
    eunlock(ep);
    80206a1c:	8526                	mv	a0,s1
    80206a1e:	00000097          	auipc	ra,0x0
    80206a22:	9de080e7          	jalr	-1570(ra) # 802063fc <eunlock>
    return ep;
    80206a26:	79a2                	ld	s3,40(sp)
    80206a28:	6ae2                	ld	s5,24(sp)
    80206a2a:	b7a9                	j	80206974 <ealloc+0x52>
        ep->attribute |= ATTR_DIRECTORY;
    80206a2c:	1004c783          	lbu	a5,256(s1)
    80206a30:	0107e793          	ori	a5,a5,16
    80206a34:	10f48023          	sb	a5,256(s1)
        ep->cur_clus = ep->first_clus = alloc_clus(dp->dev);
    80206a38:	11494503          	lbu	a0,276(s2)
    80206a3c:	fffff097          	auipc	ra,0xfffff
    80206a40:	81a080e7          	jalr	-2022(ra) # 80205256 <alloc_clus>
    80206a44:	2501                	sext.w	a0,a0
    80206a46:	10a4a223          	sw	a0,260(s1)
    80206a4a:	10a4a623          	sw	a0,268(s1)
        emake(ep, ep, 0);
    80206a4e:	4601                	li	a2,0
    80206a50:	85a6                	mv	a1,s1
    80206a52:	8526                	mv	a0,s1
    80206a54:	fffff097          	auipc	ra,0xfffff
    80206a58:	35e080e7          	jalr	862(ra) # 80205db2 <emake>
        emake(ep, dp, 32);
    80206a5c:	02000613          	li	a2,32
    80206a60:	85ca                	mv	a1,s2
    80206a62:	8526                	mv	a0,s1
    80206a64:	fffff097          	auipc	ra,0xfffff
    80206a68:	34e080e7          	jalr	846(ra) # 80205db2 <emake>
    80206a6c:	bf71                	j	80206a08 <ealloc+0xe6>
        return NULL;
    80206a6e:	84aa                	mv	s1,a0
    80206a70:	79a2                	ld	s3,40(sp)
    80206a72:	b709                	j	80206974 <ealloc+0x52>

0000000080206a74 <lookup_path>:
    return path;
}

// FAT32 version of namex in xv6's original file system.
static struct dirent *lookup_path(char *path, int parent, char *name)
{
    80206a74:	715d                	addi	sp,sp,-80
    80206a76:	e486                	sd	ra,72(sp)
    80206a78:	e0a2                	sd	s0,64(sp)
    80206a7a:	fc26                	sd	s1,56(sp)
    80206a7c:	f44e                	sd	s3,40(sp)
    80206a7e:	ec56                	sd	s5,24(sp)
    80206a80:	e85a                	sd	s6,16(sp)
    80206a82:	0880                	addi	s0,sp,80
    80206a84:	84aa                	mv	s1,a0
    80206a86:	8b2e                	mv	s6,a1
    80206a88:	8ab2                	mv	s5,a2
    struct dirent *entry, *next;
    if (*path == '/') {
    80206a8a:	00054783          	lbu	a5,0(a0)
    80206a8e:	02f00713          	li	a4,47
    80206a92:	02e78a63          	beq	a5,a4,80206ac6 <lookup_path+0x52>
        entry = edup(&root);
    } else if (*path != '\0') {
        entry = edup(myproc()->cwd);
    } else {
        return NULL;
    80206a96:	4981                	li	s3,0
    } else if (*path != '\0') {
    80206a98:	c7a5                	beqz	a5,80206b00 <lookup_path+0x8c>
    80206a9a:	f84a                	sd	s2,48(sp)
    80206a9c:	f052                	sd	s4,32(sp)
    80206a9e:	e45e                	sd	s7,8(sp)
    80206aa0:	e062                	sd	s8,0(sp)
        entry = edup(myproc()->cwd);
    80206aa2:	ffffb097          	auipc	ra,0xffffb
    80206aa6:	02c080e7          	jalr	44(ra) # 80201ace <myproc>
    80206aaa:	15853503          	ld	a0,344(a0)
    80206aae:	fffff097          	auipc	ra,0xfffff
    80206ab2:	6c4080e7          	jalr	1732(ra) # 80206172 <edup>
    80206ab6:	89aa                	mv	s3,a0
    while (*path == '/') {
    80206ab8:	02f00913          	li	s2,47
    if (len > FAT32_MAX_FILENAME) {
    80206abc:	0ff00b93          	li	s7,255
    80206ac0:	0ff00c13          	li	s8,255
    80206ac4:	a8f5                	j	80206bc0 <lookup_path+0x14c>
    80206ac6:	f84a                	sd	s2,48(sp)
    80206ac8:	f052                	sd	s4,32(sp)
    80206aca:	e45e                	sd	s7,8(sp)
    80206acc:	e062                	sd	s8,0(sp)
        entry = edup(&root);
    80206ace:	00017517          	auipc	a0,0x17
    80206ad2:	98250513          	addi	a0,a0,-1662 # 8021d450 <root>
    80206ad6:	fffff097          	auipc	ra,0xfffff
    80206ada:	69c080e7          	jalr	1692(ra) # 80206172 <edup>
    80206ade:	89aa                	mv	s3,a0
    80206ae0:	bfe1                	j	80206ab8 <lookup_path+0x44>
    }
    while ((path = skipelem(path, name)) != 0) {
        elock(entry);
        if (!(entry->attribute & ATTR_DIRECTORY)) {
            eunlock(entry);
    80206ae2:	854e                	mv	a0,s3
    80206ae4:	00000097          	auipc	ra,0x0
    80206ae8:	918080e7          	jalr	-1768(ra) # 802063fc <eunlock>
            eput(entry);
    80206aec:	854e                	mv	a0,s3
    80206aee:	00000097          	auipc	ra,0x0
    80206af2:	95c080e7          	jalr	-1700(ra) # 8020644a <eput>
            return NULL;
    80206af6:	4981                	li	s3,0
    80206af8:	7942                	ld	s2,48(sp)
    80206afa:	7a02                	ld	s4,32(sp)
    80206afc:	6ba2                	ld	s7,8(sp)
    80206afe:	6c02                	ld	s8,0(sp)
    if (parent) {
        eput(entry);
        return NULL;
    }
    return entry;
}
    80206b00:	854e                	mv	a0,s3
    80206b02:	60a6                	ld	ra,72(sp)
    80206b04:	6406                	ld	s0,64(sp)
    80206b06:	74e2                	ld	s1,56(sp)
    80206b08:	79a2                	ld	s3,40(sp)
    80206b0a:	6ae2                	ld	s5,24(sp)
    80206b0c:	6b42                	ld	s6,16(sp)
    80206b0e:	6161                	addi	sp,sp,80
    80206b10:	8082                	ret
            eunlock(entry);
    80206b12:	854e                	mv	a0,s3
    80206b14:	00000097          	auipc	ra,0x0
    80206b18:	8e8080e7          	jalr	-1816(ra) # 802063fc <eunlock>
            return entry;
    80206b1c:	7942                	ld	s2,48(sp)
    80206b1e:	7a02                	ld	s4,32(sp)
    80206b20:	6ba2                	ld	s7,8(sp)
    80206b22:	6c02                	ld	s8,0(sp)
    80206b24:	bff1                	j	80206b00 <lookup_path+0x8c>
            eunlock(entry);
    80206b26:	854e                	mv	a0,s3
    80206b28:	00000097          	auipc	ra,0x0
    80206b2c:	8d4080e7          	jalr	-1836(ra) # 802063fc <eunlock>
            eput(entry);
    80206b30:	854e                	mv	a0,s3
    80206b32:	00000097          	auipc	ra,0x0
    80206b36:	918080e7          	jalr	-1768(ra) # 8020644a <eput>
            return NULL;
    80206b3a:	89d2                	mv	s3,s4
    80206b3c:	7942                	ld	s2,48(sp)
    80206b3e:	7a02                	ld	s4,32(sp)
    80206b40:	6ba2                	ld	s7,8(sp)
    80206b42:	6c02                	ld	s8,0(sp)
    80206b44:	bf75                	j	80206b00 <lookup_path+0x8c>
    int len = path - s;
    80206b46:	40b487b3          	sub	a5,s1,a1
    80206b4a:	863e                	mv	a2,a5
    if (len > FAT32_MAX_FILENAME) {
    80206b4c:	2781                	sext.w	a5,a5
    80206b4e:	00fbd363          	bge	s7,a5,80206b54 <lookup_path+0xe0>
    80206b52:	8662                	mv	a2,s8
    80206b54:	0006079b          	sext.w	a5,a2
    name[len] = 0;
    80206b58:	97d6                	add	a5,a5,s5
    80206b5a:	00078023          	sb	zero,0(a5)
    memmove(name, s, len);
    80206b5e:	2601                	sext.w	a2,a2
    80206b60:	8556                	mv	a0,s5
    80206b62:	ffffa097          	auipc	ra,0xffffa
    80206b66:	c86080e7          	jalr	-890(ra) # 802007e8 <memmove>
    while (*path == '/') {
    80206b6a:	0004c783          	lbu	a5,0(s1)
    80206b6e:	01279763          	bne	a5,s2,80206b7c <lookup_path+0x108>
        path++;
    80206b72:	0485                	addi	s1,s1,1
    while (*path == '/') {
    80206b74:	0004c783          	lbu	a5,0(s1)
    80206b78:	ff278de3          	beq	a5,s2,80206b72 <lookup_path+0xfe>
        elock(entry);
    80206b7c:	854e                	mv	a0,s3
    80206b7e:	00000097          	auipc	ra,0x0
    80206b82:	848080e7          	jalr	-1976(ra) # 802063c6 <elock>
        if (!(entry->attribute & ATTR_DIRECTORY)) {
    80206b86:	1009c783          	lbu	a5,256(s3)
    80206b8a:	8bc1                	andi	a5,a5,16
    80206b8c:	dbb9                	beqz	a5,80206ae2 <lookup_path+0x6e>
        if (parent && *path == '\0') {
    80206b8e:	000b0563          	beqz	s6,80206b98 <lookup_path+0x124>
    80206b92:	0004c783          	lbu	a5,0(s1)
    80206b96:	dfb5                	beqz	a5,80206b12 <lookup_path+0x9e>
        if ((next = dirlookup(entry, name, 0)) == 0) {
    80206b98:	4601                	li	a2,0
    80206b9a:	85d6                	mv	a1,s5
    80206b9c:	854e                	mv	a0,s3
    80206b9e:	00000097          	auipc	ra,0x0
    80206ba2:	c28080e7          	jalr	-984(ra) # 802067c6 <dirlookup>
    80206ba6:	8a2a                	mv	s4,a0
    80206ba8:	dd3d                	beqz	a0,80206b26 <lookup_path+0xb2>
        eunlock(entry);
    80206baa:	854e                	mv	a0,s3
    80206bac:	00000097          	auipc	ra,0x0
    80206bb0:	850080e7          	jalr	-1968(ra) # 802063fc <eunlock>
        eput(entry);
    80206bb4:	854e                	mv	a0,s3
    80206bb6:	00000097          	auipc	ra,0x0
    80206bba:	894080e7          	jalr	-1900(ra) # 8020644a <eput>
        entry = next;
    80206bbe:	89d2                	mv	s3,s4
    while (*path == '/') {
    80206bc0:	0004c783          	lbu	a5,0(s1)
    80206bc4:	05279463          	bne	a5,s2,80206c0c <lookup_path+0x198>
        path++;
    80206bc8:	0485                	addi	s1,s1,1
    while (*path == '/') {
    80206bca:	0004c783          	lbu	a5,0(s1)
    80206bce:	ff278de3          	beq	a5,s2,80206bc8 <lookup_path+0x154>
    if (*path == 0) { return NULL; }
    80206bd2:	cb99                	beqz	a5,80206be8 <lookup_path+0x174>
    while (*path != '/' && *path != 0) {
    80206bd4:	85a6                	mv	a1,s1
    80206bd6:	f72788e3          	beq	a5,s2,80206b46 <lookup_path+0xd2>
    80206bda:	d7b5                	beqz	a5,80206b46 <lookup_path+0xd2>
        path++;
    80206bdc:	0485                	addi	s1,s1,1
    while (*path != '/' && *path != 0) {
    80206bde:	0004c783          	lbu	a5,0(s1)
    80206be2:	ff279ce3          	bne	a5,s2,80206bda <lookup_path+0x166>
    80206be6:	b785                	j	80206b46 <lookup_path+0xd2>
    if (parent) {
    80206be8:	000b1763          	bnez	s6,80206bf6 <lookup_path+0x182>
    80206bec:	7942                	ld	s2,48(sp)
    80206bee:	7a02                	ld	s4,32(sp)
    80206bf0:	6ba2                	ld	s7,8(sp)
    80206bf2:	6c02                	ld	s8,0(sp)
    80206bf4:	b731                	j	80206b00 <lookup_path+0x8c>
        eput(entry);
    80206bf6:	854e                	mv	a0,s3
    80206bf8:	00000097          	auipc	ra,0x0
    80206bfc:	852080e7          	jalr	-1966(ra) # 8020644a <eput>
        return NULL;
    80206c00:	4981                	li	s3,0
    80206c02:	7942                	ld	s2,48(sp)
    80206c04:	7a02                	ld	s4,32(sp)
    80206c06:	6ba2                	ld	s7,8(sp)
    80206c08:	6c02                	ld	s8,0(sp)
    80206c0a:	bddd                	j	80206b00 <lookup_path+0x8c>
    if (*path == 0) { return NULL; }
    80206c0c:	dff1                	beqz	a5,80206be8 <lookup_path+0x174>
    while (*path != '/' && *path != 0) {
    80206c0e:	0004c783          	lbu	a5,0(s1)
    80206c12:	85a6                	mv	a1,s1
    80206c14:	b7d9                	j	80206bda <lookup_path+0x166>

0000000080206c16 <ename>:

struct dirent *ename(char *path)
{
    80206c16:	716d                	addi	sp,sp,-272
    80206c18:	e606                	sd	ra,264(sp)
    80206c1a:	e222                	sd	s0,256(sp)
    80206c1c:	0a00                	addi	s0,sp,272
    char name[FAT32_MAX_FILENAME + 1];
    return lookup_path(path, 0, name);
    80206c1e:	ef040613          	addi	a2,s0,-272
    80206c22:	4581                	li	a1,0
    80206c24:	00000097          	auipc	ra,0x0
    80206c28:	e50080e7          	jalr	-432(ra) # 80206a74 <lookup_path>
}
    80206c2c:	60b2                	ld	ra,264(sp)
    80206c2e:	6412                	ld	s0,256(sp)
    80206c30:	6151                	addi	sp,sp,272
    80206c32:	8082                	ret

0000000080206c34 <enameparent>:

struct dirent *enameparent(char *path, char *name)
{
    80206c34:	1141                	addi	sp,sp,-16
    80206c36:	e406                	sd	ra,8(sp)
    80206c38:	e022                	sd	s0,0(sp)
    80206c3a:	0800                	addi	s0,sp,16
    80206c3c:	862e                	mv	a2,a1
    return lookup_path(path, 1, name);
    80206c3e:	4585                	li	a1,1
    80206c40:	00000097          	auipc	ra,0x0
    80206c44:	e34080e7          	jalr	-460(ra) # 80206a74 <lookup_path>
}
    80206c48:	60a2                	ld	ra,8(sp)
    80206c4a:	6402                	ld	s0,0(sp)
    80206c4c:	0141                	addi	sp,sp,16
    80206c4e:	8082                	ret

0000000080206c50 <plicinit>:

//
// the riscv Platform Level Interrupt Controller (PLIC).
//

void plicinit(void) {
    80206c50:	1141                	addi	sp,sp,-16
    80206c52:	e422                	sd	s0,8(sp)
    80206c54:	0800                	addi	s0,sp,16
	writed(1, PLIC_V + DISK_IRQ * sizeof(uint32));
    80206c56:	00fc37b7          	lui	a5,0xfc3
    80206c5a:	07ba                	slli	a5,a5,0xe
    80206c5c:	4705                	li	a4,1
    80206c5e:	c3d8                	sw	a4,4(a5)
	writed(1, PLIC_V + UART_IRQ * sizeof(uint32));
    80206c60:	00fc37b7          	lui	a5,0xfc3
    80206c64:	07ba                	slli	a5,a5,0xe
    80206c66:	d798                	sw	a4,40(a5)

	#ifdef DEBUG 
	printf("plicinit\n");
	#endif 
}
    80206c68:	6422                	ld	s0,8(sp)
    80206c6a:	0141                	addi	sp,sp,16
    80206c6c:	8082                	ret

0000000080206c6e <plicinithart>:

void
plicinithart(void)
{
    80206c6e:	1141                	addi	sp,sp,-16
    80206c70:	e406                	sd	ra,8(sp)
    80206c72:	e022                	sd	s0,0(sp)
    80206c74:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80206c76:	ffffb097          	auipc	ra,0xffffb
    80206c7a:	e2c080e7          	jalr	-468(ra) # 80201aa2 <cpuid>
  #ifdef QEMU
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART_IRQ) | (1 << DISK_IRQ);
    80206c7e:	0085171b          	slliw	a4,a0,0x8
    80206c82:	01f867b7          	lui	a5,0x1f86
    80206c86:	0785                	addi	a5,a5,1 # 1f86001 <_entry-0x7e279fff>
    80206c88:	07b6                	slli	a5,a5,0xd
    80206c8a:	97ba                	add	a5,a5,a4
    80206c8c:	40200713          	li	a4,1026
    80206c90:	08e7a023          	sw	a4,128(a5)
  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80206c94:	00d5151b          	slliw	a0,a0,0xd
    80206c98:	03f0c7b7          	lui	a5,0x3f0c
    80206c9c:	20178793          	addi	a5,a5,513 # 3f0c201 <_entry-0x7c2f3dff>
    80206ca0:	07b2                	slli	a5,a5,0xc
    80206ca2:	97aa                	add	a5,a5,a0
    80206ca4:	0007a023          	sw	zero,0(a5)
  *(hart0_m_int_enable_hi) = readd(hart0_m_int_enable_hi) | (1 << (UART_IRQ % 32));
  #endif
  #ifdef DEBUG
  printf("plicinithart\n");
  #endif
}
    80206ca8:	60a2                	ld	ra,8(sp)
    80206caa:	6402                	ld	s0,0(sp)
    80206cac:	0141                	addi	sp,sp,16
    80206cae:	8082                	ret

0000000080206cb0 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80206cb0:	1141                	addi	sp,sp,-16
    80206cb2:	e406                	sd	ra,8(sp)
    80206cb4:	e022                	sd	s0,0(sp)
    80206cb6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80206cb8:	ffffb097          	auipc	ra,0xffffb
    80206cbc:	dea080e7          	jalr	-534(ra) # 80201aa2 <cpuid>
  int irq;
  #ifndef QEMU
  irq = *(uint32*)PLIC_MCLAIM(hart);
  #else
  irq = *(uint32*)PLIC_SCLAIM(hart);
    80206cc0:	00d5151b          	slliw	a0,a0,0xd
    80206cc4:	03f0c7b7          	lui	a5,0x3f0c
    80206cc8:	20178793          	addi	a5,a5,513 # 3f0c201 <_entry-0x7c2f3dff>
    80206ccc:	07b2                	slli	a5,a5,0xc
    80206cce:	97aa                	add	a5,a5,a0
  #endif
  return irq;
}
    80206cd0:	43c8                	lw	a0,4(a5)
    80206cd2:	60a2                	ld	ra,8(sp)
    80206cd4:	6402                	ld	s0,0(sp)
    80206cd6:	0141                	addi	sp,sp,16
    80206cd8:	8082                	ret

0000000080206cda <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80206cda:	1101                	addi	sp,sp,-32
    80206cdc:	ec06                	sd	ra,24(sp)
    80206cde:	e822                	sd	s0,16(sp)
    80206ce0:	e426                	sd	s1,8(sp)
    80206ce2:	1000                	addi	s0,sp,32
    80206ce4:	84aa                	mv	s1,a0
  int hart = cpuid();
    80206ce6:	ffffb097          	auipc	ra,0xffffb
    80206cea:	dbc080e7          	jalr	-580(ra) # 80201aa2 <cpuid>
  #ifndef QEMU
  *(uint32*)PLIC_MCLAIM(hart) = irq;
  #else
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80206cee:	00d5151b          	slliw	a0,a0,0xd
    80206cf2:	03f0c7b7          	lui	a5,0x3f0c
    80206cf6:	20178793          	addi	a5,a5,513 # 3f0c201 <_entry-0x7c2f3dff>
    80206cfa:	07b2                	slli	a5,a5,0xc
    80206cfc:	97aa                	add	a5,a5,a0
    80206cfe:	c3c4                	sw	s1,4(a5)
  #endif
}
    80206d00:	60e2                	ld	ra,24(sp)
    80206d02:	6442                	ld	s0,16(sp)
    80206d04:	64a2                	ld	s1,8(sp)
    80206d06:	6105                	addi	sp,sp,32
    80206d08:	8082                	ret

0000000080206d0a <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80206d0a:	715d                	addi	sp,sp,-80
    80206d0c:	e486                	sd	ra,72(sp)
    80206d0e:	e0a2                	sd	s0,64(sp)
    80206d10:	fc26                	sd	s1,56(sp)
    80206d12:	f84a                	sd	s2,48(sp)
    80206d14:	f44e                	sd	s3,40(sp)
    80206d16:	f052                	sd	s4,32(sp)
    80206d18:	0880                	addi	s0,sp,80
    80206d1a:	8a2a                	mv	s4,a0
    80206d1c:	84ae                	mv	s1,a1
    80206d1e:	89b2                	mv	s3,a2
  int i;

  acquire(&cons.lock);
    80206d20:	0001b517          	auipc	a0,0x1b
    80206d24:	f0050513          	addi	a0,a0,-256 # 80221c20 <cons>
    80206d28:	ffffa097          	auipc	ra,0xffffa
    80206d2c:	9c8080e7          	jalr	-1592(ra) # 802006f0 <acquire>
  for(i = 0; i < n; i++){
    80206d30:	03305f63          	blez	s3,80206d6e <consolewrite+0x64>
    80206d34:	ec56                	sd	s5,24(sp)
    80206d36:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80206d38:	5afd                	li	s5,-1
    80206d3a:	4685                	li	a3,1
    80206d3c:	8626                	mv	a2,s1
    80206d3e:	85d2                	mv	a1,s4
    80206d40:	fbf40513          	addi	a0,s0,-65
    80206d44:	ffffc097          	auipc	ra,0xffffc
    80206d48:	88a080e7          	jalr	-1910(ra) # 802025ce <either_copyin>
    80206d4c:	03550363          	beq	a0,s5,80206d72 <consolewrite+0x68>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
    80206d50:	fbf44503          	lbu	a0,-65(s0)
    80206d54:	4581                	li	a1,0
    80206d56:	4601                	li	a2,0
    80206d58:	4681                	li	a3,0
    80206d5a:	4885                	li	a7,1
    80206d5c:	00000073          	ecall
  for(i = 0; i < n; i++){
    80206d60:	2905                	addiw	s2,s2,1
    80206d62:	0485                	addi	s1,s1,1
    80206d64:	fd299be3          	bne	s3,s2,80206d3a <consolewrite+0x30>
    80206d68:	894e                	mv	s2,s3
    80206d6a:	6ae2                	ld	s5,24(sp)
    80206d6c:	a021                	j	80206d74 <consolewrite+0x6a>
    80206d6e:	4901                	li	s2,0
    80206d70:	a011                	j	80206d74 <consolewrite+0x6a>
    80206d72:	6ae2                	ld	s5,24(sp)
      break;
    sbi_console_putchar(c);
  }
  release(&cons.lock);
    80206d74:	0001b517          	auipc	a0,0x1b
    80206d78:	eac50513          	addi	a0,a0,-340 # 80221c20 <cons>
    80206d7c:	ffffa097          	auipc	ra,0xffffa
    80206d80:	9c8080e7          	jalr	-1592(ra) # 80200744 <release>

  return i;
}
    80206d84:	854a                	mv	a0,s2
    80206d86:	60a6                	ld	ra,72(sp)
    80206d88:	6406                	ld	s0,64(sp)
    80206d8a:	74e2                	ld	s1,56(sp)
    80206d8c:	7942                	ld	s2,48(sp)
    80206d8e:	79a2                	ld	s3,40(sp)
    80206d90:	7a02                	ld	s4,32(sp)
    80206d92:	6161                	addi	sp,sp,80
    80206d94:	8082                	ret

0000000080206d96 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80206d96:	711d                	addi	sp,sp,-96
    80206d98:	ec86                	sd	ra,88(sp)
    80206d9a:	e8a2                	sd	s0,80(sp)
    80206d9c:	e4a6                	sd	s1,72(sp)
    80206d9e:	e0ca                	sd	s2,64(sp)
    80206da0:	fc4e                	sd	s3,56(sp)
    80206da2:	f852                	sd	s4,48(sp)
    80206da4:	f456                	sd	s5,40(sp)
    80206da6:	f05a                	sd	s6,32(sp)
    80206da8:	1080                	addi	s0,sp,96
    80206daa:	8aaa                	mv	s5,a0
    80206dac:	8a2e                	mv	s4,a1
    80206dae:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80206db0:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80206db4:	0001b517          	auipc	a0,0x1b
    80206db8:	e6c50513          	addi	a0,a0,-404 # 80221c20 <cons>
    80206dbc:	ffffa097          	auipc	ra,0xffffa
    80206dc0:	934080e7          	jalr	-1740(ra) # 802006f0 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80206dc4:	0001b497          	auipc	s1,0x1b
    80206dc8:	e5c48493          	addi	s1,s1,-420 # 80221c20 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80206dcc:	0001b917          	auipc	s2,0x1b
    80206dd0:	eec90913          	addi	s2,s2,-276 # 80221cb8 <cons+0x98>
  while(n > 0){
    80206dd4:	0d305463          	blez	s3,80206e9c <consoleread+0x106>
    while(cons.r == cons.w){
    80206dd8:	0984a783          	lw	a5,152(s1)
    80206ddc:	09c4a703          	lw	a4,156(s1)
    80206de0:	0af71963          	bne	a4,a5,80206e92 <consoleread+0xfc>
      if(myproc()->killed){
    80206de4:	ffffb097          	auipc	ra,0xffffb
    80206de8:	cea080e7          	jalr	-790(ra) # 80201ace <myproc>
    80206dec:	591c                	lw	a5,48(a0)
    80206dee:	e7ad                	bnez	a5,80206e58 <consoleread+0xc2>
      sleep(&cons.r, &cons.lock);
    80206df0:	85a6                	mv	a1,s1
    80206df2:	854a                	mv	a0,s2
    80206df4:	ffffb097          	auipc	ra,0xffffb
    80206df8:	54e080e7          	jalr	1358(ra) # 80202342 <sleep>
    while(cons.r == cons.w){
    80206dfc:	0984a783          	lw	a5,152(s1)
    80206e00:	09c4a703          	lw	a4,156(s1)
    80206e04:	fef700e3          	beq	a4,a5,80206de4 <consoleread+0x4e>
    80206e08:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF];
    80206e0a:	0001b717          	auipc	a4,0x1b
    80206e0e:	e1670713          	addi	a4,a4,-490 # 80221c20 <cons>
    80206e12:	0017869b          	addiw	a3,a5,1
    80206e16:	08d72c23          	sw	a3,152(a4)
    80206e1a:	07f7f693          	andi	a3,a5,127
    80206e1e:	9736                	add	a4,a4,a3
    80206e20:	01874703          	lbu	a4,24(a4)
    80206e24:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    80206e28:	4691                	li	a3,4
    80206e2a:	04db8a63          	beq	s7,a3,80206e7e <consoleread+0xe8>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80206e2e:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80206e32:	4685                	li	a3,1
    80206e34:	faf40613          	addi	a2,s0,-81
    80206e38:	85d2                	mv	a1,s4
    80206e3a:	8556                	mv	a0,s5
    80206e3c:	ffffb097          	auipc	ra,0xffffb
    80206e40:	75c080e7          	jalr	1884(ra) # 80202598 <either_copyout>
    80206e44:	57fd                	li	a5,-1
    80206e46:	04f50a63          	beq	a0,a5,80206e9a <consoleread+0x104>
      break;

    dst++;
    80206e4a:	0a05                	addi	s4,s4,1
    --n;
    80206e4c:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    80206e4e:	47a9                	li	a5,10
    80206e50:	06fb8163          	beq	s7,a5,80206eb2 <consoleread+0x11c>
    80206e54:	6be2                	ld	s7,24(sp)
    80206e56:	bfbd                	j	80206dd4 <consoleread+0x3e>
        release(&cons.lock);
    80206e58:	0001b517          	auipc	a0,0x1b
    80206e5c:	dc850513          	addi	a0,a0,-568 # 80221c20 <cons>
    80206e60:	ffffa097          	auipc	ra,0xffffa
    80206e64:	8e4080e7          	jalr	-1820(ra) # 80200744 <release>
        return -1;
    80206e68:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80206e6a:	60e6                	ld	ra,88(sp)
    80206e6c:	6446                	ld	s0,80(sp)
    80206e6e:	64a6                	ld	s1,72(sp)
    80206e70:	6906                	ld	s2,64(sp)
    80206e72:	79e2                	ld	s3,56(sp)
    80206e74:	7a42                	ld	s4,48(sp)
    80206e76:	7aa2                	ld	s5,40(sp)
    80206e78:	7b02                	ld	s6,32(sp)
    80206e7a:	6125                	addi	sp,sp,96
    80206e7c:	8082                	ret
      if(n < target){
    80206e7e:	0009871b          	sext.w	a4,s3
    80206e82:	01677a63          	bgeu	a4,s6,80206e96 <consoleread+0x100>
        cons.r--;
    80206e86:	0001b717          	auipc	a4,0x1b
    80206e8a:	e2f72923          	sw	a5,-462(a4) # 80221cb8 <cons+0x98>
    80206e8e:	6be2                	ld	s7,24(sp)
    80206e90:	a031                	j	80206e9c <consoleread+0x106>
    80206e92:	ec5e                	sd	s7,24(sp)
    80206e94:	bf9d                	j	80206e0a <consoleread+0x74>
    80206e96:	6be2                	ld	s7,24(sp)
    80206e98:	a011                	j	80206e9c <consoleread+0x106>
    80206e9a:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80206e9c:	0001b517          	auipc	a0,0x1b
    80206ea0:	d8450513          	addi	a0,a0,-636 # 80221c20 <cons>
    80206ea4:	ffffa097          	auipc	ra,0xffffa
    80206ea8:	8a0080e7          	jalr	-1888(ra) # 80200744 <release>
  return target - n;
    80206eac:	413b053b          	subw	a0,s6,s3
    80206eb0:	bf6d                	j	80206e6a <consoleread+0xd4>
    80206eb2:	6be2                	ld	s7,24(sp)
    80206eb4:	b7e5                	j	80206e9c <consoleread+0x106>

0000000080206eb6 <consputc>:
void consputc(int c) {
    80206eb6:	1141                	addi	sp,sp,-16
    80206eb8:	e422                	sd	s0,8(sp)
    80206eba:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80206ebc:	10000793          	li	a5,256
    80206ec0:	00f50b63          	beq	a0,a5,80206ed6 <consputc+0x20>
    80206ec4:	4581                	li	a1,0
    80206ec6:	4601                	li	a2,0
    80206ec8:	4681                	li	a3,0
    80206eca:	4885                	li	a7,1
    80206ecc:	00000073          	ecall
}
    80206ed0:	6422                	ld	s0,8(sp)
    80206ed2:	0141                	addi	sp,sp,16
    80206ed4:	8082                	ret
    80206ed6:	4521                	li	a0,8
    80206ed8:	4581                	li	a1,0
    80206eda:	4601                	li	a2,0
    80206edc:	4681                	li	a3,0
    80206ede:	4885                	li	a7,1
    80206ee0:	00000073          	ecall
    80206ee4:	02000513          	li	a0,32
    80206ee8:	00000073          	ecall
    80206eec:	4521                	li	a0,8
    80206eee:	00000073          	ecall
}
    80206ef2:	bff9                	j	80206ed0 <consputc+0x1a>

0000000080206ef4 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80206ef4:	1101                	addi	sp,sp,-32
    80206ef6:	ec06                	sd	ra,24(sp)
    80206ef8:	e822                	sd	s0,16(sp)
    80206efa:	e426                	sd	s1,8(sp)
    80206efc:	1000                	addi	s0,sp,32
    80206efe:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    80206f00:	0001b517          	auipc	a0,0x1b
    80206f04:	d2050513          	addi	a0,a0,-736 # 80221c20 <cons>
    80206f08:	ffff9097          	auipc	ra,0xffff9
    80206f0c:	7e8080e7          	jalr	2024(ra) # 802006f0 <acquire>

  switch(c){
    80206f10:	47d5                	li	a5,21
    80206f12:	0af48563          	beq	s1,a5,80206fbc <consoleintr+0xc8>
    80206f16:	0297c963          	blt	a5,s1,80206f48 <consoleintr+0x54>
    80206f1a:	47a1                	li	a5,8
    80206f1c:	0ef48c63          	beq	s1,a5,80207014 <consoleintr+0x120>
    80206f20:	47c1                	li	a5,16
    80206f22:	10f49f63          	bne	s1,a5,80207040 <consoleintr+0x14c>
  case C('P'):  // Print process list.
    procdump();
    80206f26:	ffffb097          	auipc	ra,0xffffb
    80206f2a:	6dc080e7          	jalr	1756(ra) # 80202602 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80206f2e:	0001b517          	auipc	a0,0x1b
    80206f32:	cf250513          	addi	a0,a0,-782 # 80221c20 <cons>
    80206f36:	ffffa097          	auipc	ra,0xffffa
    80206f3a:	80e080e7          	jalr	-2034(ra) # 80200744 <release>
}
    80206f3e:	60e2                	ld	ra,24(sp)
    80206f40:	6442                	ld	s0,16(sp)
    80206f42:	64a2                	ld	s1,8(sp)
    80206f44:	6105                	addi	sp,sp,32
    80206f46:	8082                	ret
  switch(c){
    80206f48:	07f00793          	li	a5,127
    80206f4c:	0cf48463          	beq	s1,a5,80207014 <consoleintr+0x120>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80206f50:	0001b717          	auipc	a4,0x1b
    80206f54:	cd070713          	addi	a4,a4,-816 # 80221c20 <cons>
    80206f58:	0a072783          	lw	a5,160(a4)
    80206f5c:	09872703          	lw	a4,152(a4)
    80206f60:	9f99                	subw	a5,a5,a4
    80206f62:	07f00713          	li	a4,127
    80206f66:	fcf764e3          	bltu	a4,a5,80206f2e <consoleintr+0x3a>
      c = (c == '\r') ? '\n' : c;
    80206f6a:	47b5                	li	a5,13
    80206f6c:	0cf48d63          	beq	s1,a5,80207046 <consoleintr+0x152>
      consputc(c);
    80206f70:	8526                	mv	a0,s1
    80206f72:	00000097          	auipc	ra,0x0
    80206f76:	f44080e7          	jalr	-188(ra) # 80206eb6 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80206f7a:	0001b797          	auipc	a5,0x1b
    80206f7e:	ca678793          	addi	a5,a5,-858 # 80221c20 <cons>
    80206f82:	0a07a703          	lw	a4,160(a5)
    80206f86:	0017069b          	addiw	a3,a4,1
    80206f8a:	0006861b          	sext.w	a2,a3
    80206f8e:	0ad7a023          	sw	a3,160(a5)
    80206f92:	07f77713          	andi	a4,a4,127
    80206f96:	97ba                	add	a5,a5,a4
    80206f98:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80206f9c:	47a9                	li	a5,10
    80206f9e:	0cf48b63          	beq	s1,a5,80207074 <consoleintr+0x180>
    80206fa2:	4791                	li	a5,4
    80206fa4:	0cf48863          	beq	s1,a5,80207074 <consoleintr+0x180>
    80206fa8:	0001b797          	auipc	a5,0x1b
    80206fac:	d107a783          	lw	a5,-752(a5) # 80221cb8 <cons+0x98>
    80206fb0:	0807879b          	addiw	a5,a5,128
    80206fb4:	f6f61de3          	bne	a2,a5,80206f2e <consoleintr+0x3a>
    80206fb8:	863e                	mv	a2,a5
    80206fba:	a86d                	j	80207074 <consoleintr+0x180>
    80206fbc:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80206fbe:	0001b717          	auipc	a4,0x1b
    80206fc2:	c6270713          	addi	a4,a4,-926 # 80221c20 <cons>
    80206fc6:	0a072783          	lw	a5,160(a4)
    80206fca:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80206fce:	0001b497          	auipc	s1,0x1b
    80206fd2:	c5248493          	addi	s1,s1,-942 # 80221c20 <cons>
    while(cons.e != cons.w &&
    80206fd6:	4929                	li	s2,10
    80206fd8:	02f70a63          	beq	a4,a5,8020700c <consoleintr+0x118>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80206fdc:	37fd                	addiw	a5,a5,-1
    80206fde:	07f7f713          	andi	a4,a5,127
    80206fe2:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80206fe4:	01874703          	lbu	a4,24(a4)
    80206fe8:	03270463          	beq	a4,s2,80207010 <consoleintr+0x11c>
      cons.e--;
    80206fec:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80206ff0:	10000513          	li	a0,256
    80206ff4:	00000097          	auipc	ra,0x0
    80206ff8:	ec2080e7          	jalr	-318(ra) # 80206eb6 <consputc>
    while(cons.e != cons.w &&
    80206ffc:	0a04a783          	lw	a5,160(s1)
    80207000:	09c4a703          	lw	a4,156(s1)
    80207004:	fcf71ce3          	bne	a4,a5,80206fdc <consoleintr+0xe8>
    80207008:	6902                	ld	s2,0(sp)
    8020700a:	b715                	j	80206f2e <consoleintr+0x3a>
    8020700c:	6902                	ld	s2,0(sp)
    8020700e:	b705                	j	80206f2e <consoleintr+0x3a>
    80207010:	6902                	ld	s2,0(sp)
    80207012:	bf31                	j	80206f2e <consoleintr+0x3a>
    if(cons.e != cons.w){
    80207014:	0001b717          	auipc	a4,0x1b
    80207018:	c0c70713          	addi	a4,a4,-1012 # 80221c20 <cons>
    8020701c:	0a072783          	lw	a5,160(a4)
    80207020:	09c72703          	lw	a4,156(a4)
    80207024:	f0f705e3          	beq	a4,a5,80206f2e <consoleintr+0x3a>
      cons.e--;
    80207028:	37fd                	addiw	a5,a5,-1
    8020702a:	0001b717          	auipc	a4,0x1b
    8020702e:	c8f72b23          	sw	a5,-874(a4) # 80221cc0 <cons+0xa0>
      consputc(BACKSPACE);
    80207032:	10000513          	li	a0,256
    80207036:	00000097          	auipc	ra,0x0
    8020703a:	e80080e7          	jalr	-384(ra) # 80206eb6 <consputc>
    8020703e:	bdc5                	j	80206f2e <consoleintr+0x3a>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80207040:	ee0487e3          	beqz	s1,80206f2e <consoleintr+0x3a>
    80207044:	b731                	j	80206f50 <consoleintr+0x5c>
      consputc(c);
    80207046:	4529                	li	a0,10
    80207048:	00000097          	auipc	ra,0x0
    8020704c:	e6e080e7          	jalr	-402(ra) # 80206eb6 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80207050:	0001b797          	auipc	a5,0x1b
    80207054:	bd078793          	addi	a5,a5,-1072 # 80221c20 <cons>
    80207058:	0a07a703          	lw	a4,160(a5)
    8020705c:	0017069b          	addiw	a3,a4,1
    80207060:	0006861b          	sext.w	a2,a3
    80207064:	0ad7a023          	sw	a3,160(a5)
    80207068:	07f77713          	andi	a4,a4,127
    8020706c:	97ba                	add	a5,a5,a4
    8020706e:	4729                	li	a4,10
    80207070:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80207074:	0001b797          	auipc	a5,0x1b
    80207078:	c4c7a423          	sw	a2,-952(a5) # 80221cbc <cons+0x9c>
        wakeup(&cons.r);
    8020707c:	0001b517          	auipc	a0,0x1b
    80207080:	c3c50513          	addi	a0,a0,-964 # 80221cb8 <cons+0x98>
    80207084:	ffffb097          	auipc	ra,0xffffb
    80207088:	43a080e7          	jalr	1082(ra) # 802024be <wakeup>
    8020708c:	b54d                	j	80206f2e <consoleintr+0x3a>

000000008020708e <consoleinit>:

void
consoleinit(void)
{
    8020708e:	1101                	addi	sp,sp,-32
    80207090:	ec06                	sd	ra,24(sp)
    80207092:	e822                	sd	s0,16(sp)
    80207094:	e426                	sd	s1,8(sp)
    80207096:	1000                	addi	s0,sp,32
  initlock(&cons.lock, "cons");
    80207098:	0001b497          	auipc	s1,0x1b
    8020709c:	b8848493          	addi	s1,s1,-1144 # 80221c20 <cons>
    802070a0:	00003597          	auipc	a1,0x3
    802070a4:	bf058593          	addi	a1,a1,-1040 # 80209c90 <etext+0xc90>
    802070a8:	8526                	mv	a0,s1
    802070aa:	ffff9097          	auipc	ra,0xffff9
    802070ae:	602080e7          	jalr	1538(ra) # 802006ac <initlock>

  cons.e = cons.w = cons.r = 0;
    802070b2:	0804ac23          	sw	zero,152(s1)
    802070b6:	0804ae23          	sw	zero,156(s1)
    802070ba:	0a04a023          	sw	zero,160(s1)
  
  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    802070be:	00015797          	auipc	a5,0x15
    802070c2:	2f278793          	addi	a5,a5,754 # 8021c3b0 <devsw>
    802070c6:	00000717          	auipc	a4,0x0
    802070ca:	cd070713          	addi	a4,a4,-816 # 80206d96 <consoleread>
    802070ce:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    802070d0:	00000717          	auipc	a4,0x0
    802070d4:	c3a70713          	addi	a4,a4,-966 # 80206d0a <consolewrite>
    802070d8:	ef98                	sd	a4,24(a5)
}
    802070da:	60e2                	ld	ra,24(sp)
    802070dc:	6442                	ld	s0,16(sp)
    802070de:	64a2                	ld	s1,8(sp)
    802070e0:	6105                	addi	sp,sp,32
    802070e2:	8082                	ret

00000000802070e4 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    802070e4:	1141                	addi	sp,sp,-16
    802070e6:	e406                	sd	ra,8(sp)
    802070e8:	e022                	sd	s0,0(sp)
    802070ea:	0800                	addi	s0,sp,16
  if(i >= NUM)
    802070ec:	479d                	li	a5,7
    802070ee:	04a7cb63          	blt	a5,a0,80207144 <free_desc+0x60>
    panic("virtio_disk_intr 1");
  if(disk.free[i])
    802070f2:	0001b717          	auipc	a4,0x1b
    802070f6:	f0e70713          	addi	a4,a4,-242 # 80222000 <disk>
    802070fa:	972a                	add	a4,a4,a0
    802070fc:	6789                	lui	a5,0x2
    802070fe:	97ba                	add	a5,a5,a4
    80207100:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x801fdfe8>
    80207104:	eba1                	bnez	a5,80207154 <free_desc+0x70>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    80207106:	00451713          	slli	a4,a0,0x4
    8020710a:	0001d797          	auipc	a5,0x1d
    8020710e:	ef67b783          	ld	a5,-266(a5) # 80224000 <disk+0x2000>
    80207112:	97ba                	add	a5,a5,a4
    80207114:	0007b023          	sd	zero,0(a5)
  disk.free[i] = 1;
    80207118:	0001b717          	auipc	a4,0x1b
    8020711c:	ee870713          	addi	a4,a4,-280 # 80222000 <disk>
    80207120:	972a                	add	a4,a4,a0
    80207122:	6789                	lui	a5,0x2
    80207124:	97ba                	add	a5,a5,a4
    80207126:	4705                	li	a4,1
    80207128:	00e78c23          	sb	a4,24(a5) # 2018 <_entry-0x801fdfe8>
  wakeup(&disk.free[0]);
    8020712c:	0001d517          	auipc	a0,0x1d
    80207130:	eec50513          	addi	a0,a0,-276 # 80224018 <disk+0x2018>
    80207134:	ffffb097          	auipc	ra,0xffffb
    80207138:	38a080e7          	jalr	906(ra) # 802024be <wakeup>
}
    8020713c:	60a2                	ld	ra,8(sp)
    8020713e:	6402                	ld	s0,0(sp)
    80207140:	0141                	addi	sp,sp,16
    80207142:	8082                	ret
    panic("virtio_disk_intr 1");
    80207144:	00003517          	auipc	a0,0x3
    80207148:	b5450513          	addi	a0,a0,-1196 # 80209c98 <etext+0xc98>
    8020714c:	ffff9097          	auipc	ra,0xffff9
    80207150:	ffa080e7          	jalr	-6(ra) # 80200146 <panic>
    panic("virtio_disk_intr 2");
    80207154:	00003517          	auipc	a0,0x3
    80207158:	b5c50513          	addi	a0,a0,-1188 # 80209cb0 <etext+0xcb0>
    8020715c:	ffff9097          	auipc	ra,0xffff9
    80207160:	fea080e7          	jalr	-22(ra) # 80200146 <panic>

0000000080207164 <virtio_disk_init>:
{
    80207164:	1141                	addi	sp,sp,-16
    80207166:	e406                	sd	ra,8(sp)
    80207168:	e022                	sd	s0,0(sp)
    8020716a:	0800                	addi	s0,sp,16
  initlock(&disk.vdisk_lock, "virtio_disk");
    8020716c:	00003597          	auipc	a1,0x3
    80207170:	b5c58593          	addi	a1,a1,-1188 # 80209cc8 <etext+0xcc8>
    80207174:	0001d517          	auipc	a0,0x1d
    80207178:	f3450513          	addi	a0,a0,-204 # 802240a8 <disk+0x20a8>
    8020717c:	ffff9097          	auipc	ra,0xffff9
    80207180:	530080e7          	jalr	1328(ra) # 802006ac <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80207184:	03f107b7          	lui	a5,0x3f10
    80207188:	0785                	addi	a5,a5,1 # 3f10001 <_entry-0x7c2effff>
    8020718a:	07b2                	slli	a5,a5,0xc
    8020718c:	4398                	lw	a4,0(a5)
    8020718e:	2701                	sext.w	a4,a4
    80207190:	747277b7          	lui	a5,0x74727
    80207194:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xbad968a>
    80207198:	12f71563          	bne	a4,a5,802072c2 <virtio_disk_init+0x15e>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    8020719c:	03f107b7          	lui	a5,0x3f10
    802071a0:	0785                	addi	a5,a5,1 # 3f10001 <_entry-0x7c2effff>
    802071a2:	07b2                	slli	a5,a5,0xc
    802071a4:	0791                	addi	a5,a5,4
    802071a6:	439c                	lw	a5,0(a5)
    802071a8:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    802071aa:	4705                	li	a4,1
    802071ac:	10e79b63          	bne	a5,a4,802072c2 <virtio_disk_init+0x15e>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    802071b0:	03f107b7          	lui	a5,0x3f10
    802071b4:	0785                	addi	a5,a5,1 # 3f10001 <_entry-0x7c2effff>
    802071b6:	07b2                	slli	a5,a5,0xc
    802071b8:	07a1                	addi	a5,a5,8
    802071ba:	439c                	lw	a5,0(a5)
    802071bc:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    802071be:	4709                	li	a4,2
    802071c0:	10e79163          	bne	a5,a4,802072c2 <virtio_disk_init+0x15e>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    802071c4:	03f107b7          	lui	a5,0x3f10
    802071c8:	0785                	addi	a5,a5,1 # 3f10001 <_entry-0x7c2effff>
    802071ca:	07b2                	slli	a5,a5,0xc
    802071cc:	47d8                	lw	a4,12(a5)
    802071ce:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    802071d0:	554d47b7          	lui	a5,0x554d4
    802071d4:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ad2baaf>
    802071d8:	0ef71563          	bne	a4,a5,802072c2 <virtio_disk_init+0x15e>
  *R(VIRTIO_MMIO_STATUS) = status;
    802071dc:	03f107b7          	lui	a5,0x3f10
    802071e0:	0785                	addi	a5,a5,1 # 3f10001 <_entry-0x7c2effff>
    802071e2:	07b2                	slli	a5,a5,0xc
    802071e4:	4705                	li	a4,1
    802071e6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    802071e8:	470d                	li	a4,3
    802071ea:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    802071ec:	03f10737          	lui	a4,0x3f10
    802071f0:	0705                	addi	a4,a4,1 # 3f10001 <_entry-0x7c2effff>
    802071f2:	0732                	slli	a4,a4,0xc
    802071f4:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    802071f6:	c7ffe737          	lui	a4,0xc7ffe
    802071fa:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <ebss_clear+0xffffffff47dd975f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    802071fe:	8ef9                	and	a3,a3,a4
    80207200:	03f10737          	lui	a4,0x3f10
    80207204:	0705                	addi	a4,a4,1 # 3f10001 <_entry-0x7c2effff>
    80207206:	0732                	slli	a4,a4,0xc
    80207208:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    8020720a:	472d                	li	a4,11
    8020720c:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8020720e:	473d                	li	a4,15
    80207210:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80207212:	03f107b7          	lui	a5,0x3f10
    80207216:	0785                	addi	a5,a5,1 # 3f10001 <_entry-0x7c2effff>
    80207218:	07b2                	slli	a5,a5,0xc
    8020721a:	6705                	lui	a4,0x1
    8020721c:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8020721e:	03f107b7          	lui	a5,0x3f10
    80207222:	0785                	addi	a5,a5,1 # 3f10001 <_entry-0x7c2effff>
    80207224:	07b2                	slli	a5,a5,0xc
    80207226:	0207a823          	sw	zero,48(a5)
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8020722a:	03f107b7          	lui	a5,0x3f10
    8020722e:	0785                	addi	a5,a5,1 # 3f10001 <_entry-0x7c2effff>
    80207230:	07b2                	slli	a5,a5,0xc
    80207232:	03478793          	addi	a5,a5,52
    80207236:	439c                	lw	a5,0(a5)
    80207238:	2781                	sext.w	a5,a5
  if(max == 0)
    8020723a:	cfc1                	beqz	a5,802072d2 <virtio_disk_init+0x16e>
  if(max < NUM)
    8020723c:	471d                	li	a4,7
    8020723e:	0af77263          	bgeu	a4,a5,802072e2 <virtio_disk_init+0x17e>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80207242:	03f107b7          	lui	a5,0x3f10
    80207246:	0785                	addi	a5,a5,1 # 3f10001 <_entry-0x7c2effff>
    80207248:	07b2                	slli	a5,a5,0xc
    8020724a:	4721                	li	a4,8
    8020724c:	df98                	sw	a4,56(a5)
  memset(disk.pages, 0, sizeof(disk.pages));
    8020724e:	6609                	lui	a2,0x2
    80207250:	4581                	li	a1,0
    80207252:	0001b517          	auipc	a0,0x1b
    80207256:	dae50513          	addi	a0,a0,-594 # 80222000 <disk>
    8020725a:	ffff9097          	auipc	ra,0xffff9
    8020725e:	532080e7          	jalr	1330(ra) # 8020078c <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80207262:	0001b697          	auipc	a3,0x1b
    80207266:	d9e68693          	addi	a3,a3,-610 # 80222000 <disk>
    8020726a:	00c6d713          	srli	a4,a3,0xc
    8020726e:	2701                	sext.w	a4,a4
    80207270:	03f107b7          	lui	a5,0x3f10
    80207274:	0785                	addi	a5,a5,1 # 3f10001 <_entry-0x7c2effff>
    80207276:	07b2                	slli	a5,a5,0xc
    80207278:	c3b8                	sw	a4,64(a5)
  disk.desc = (struct VRingDesc *) disk.pages;
    8020727a:	0001d797          	auipc	a5,0x1d
    8020727e:	d8678793          	addi	a5,a5,-634 # 80224000 <disk+0x2000>
    80207282:	e394                	sd	a3,0(a5)
  disk.avail = (uint16*)(((char*)disk.desc) + NUM*sizeof(struct VRingDesc));
    80207284:	0001b717          	auipc	a4,0x1b
    80207288:	dfc70713          	addi	a4,a4,-516 # 80222080 <disk+0x80>
    8020728c:	e798                	sd	a4,8(a5)
  disk.used = (struct UsedArea *) (disk.pages + PGSIZE);
    8020728e:	0001c717          	auipc	a4,0x1c
    80207292:	d7270713          	addi	a4,a4,-654 # 80223000 <disk+0x1000>
    80207296:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80207298:	4705                	li	a4,1
    8020729a:	00e78c23          	sb	a4,24(a5)
    8020729e:	00e78ca3          	sb	a4,25(a5)
    802072a2:	00e78d23          	sb	a4,26(a5)
    802072a6:	00e78da3          	sb	a4,27(a5)
    802072aa:	00e78e23          	sb	a4,28(a5)
    802072ae:	00e78ea3          	sb	a4,29(a5)
    802072b2:	00e78f23          	sb	a4,30(a5)
    802072b6:	00e78fa3          	sb	a4,31(a5)
}
    802072ba:	60a2                	ld	ra,8(sp)
    802072bc:	6402                	ld	s0,0(sp)
    802072be:	0141                	addi	sp,sp,16
    802072c0:	8082                	ret
    panic("could not find virtio disk");
    802072c2:	00003517          	auipc	a0,0x3
    802072c6:	a1650513          	addi	a0,a0,-1514 # 80209cd8 <etext+0xcd8>
    802072ca:	ffff9097          	auipc	ra,0xffff9
    802072ce:	e7c080e7          	jalr	-388(ra) # 80200146 <panic>
    panic("virtio disk has no queue 0");
    802072d2:	00003517          	auipc	a0,0x3
    802072d6:	a2650513          	addi	a0,a0,-1498 # 80209cf8 <etext+0xcf8>
    802072da:	ffff9097          	auipc	ra,0xffff9
    802072de:	e6c080e7          	jalr	-404(ra) # 80200146 <panic>
    panic("virtio disk max queue too short");
    802072e2:	00003517          	auipc	a0,0x3
    802072e6:	a3650513          	addi	a0,a0,-1482 # 80209d18 <etext+0xd18>
    802072ea:	ffff9097          	auipc	ra,0xffff9
    802072ee:	e5c080e7          	jalr	-420(ra) # 80200146 <panic>

00000000802072f2 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    802072f2:	7119                	addi	sp,sp,-128
    802072f4:	fc86                	sd	ra,120(sp)
    802072f6:	f8a2                	sd	s0,112(sp)
    802072f8:	f4a6                	sd	s1,104(sp)
    802072fa:	f0ca                	sd	s2,96(sp)
    802072fc:	ecce                	sd	s3,88(sp)
    802072fe:	e8d2                	sd	s4,80(sp)
    80207300:	e4d6                	sd	s5,72(sp)
    80207302:	e0da                	sd	s6,64(sp)
    80207304:	fc5e                	sd	s7,56(sp)
    80207306:	f862                	sd	s8,48(sp)
    80207308:	f466                	sd	s9,40(sp)
    8020730a:	0100                	addi	s0,sp,128
    8020730c:	8a2a                	mv	s4,a0
    8020730e:	8c2e                	mv	s8,a1
  uint64 sector = b->sectorno;
    80207310:	00c56c83          	lwu	s9,12(a0)

  acquire(&disk.vdisk_lock);
    80207314:	0001d517          	auipc	a0,0x1d
    80207318:	d9450513          	addi	a0,a0,-620 # 802240a8 <disk+0x20a8>
    8020731c:	ffff9097          	auipc	ra,0xffff9
    80207320:	3d4080e7          	jalr	980(ra) # 802006f0 <acquire>
  for(int i = 0; i < 3; i++){
    80207324:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80207326:	44a1                	li	s1,8
      disk.free[i] = 0;
    80207328:	0001bb97          	auipc	s7,0x1b
    8020732c:	cd8b8b93          	addi	s7,s7,-808 # 80222000 <disk>
    80207330:	6b09                	lui	s6,0x2
  for(int i = 0; i < 3; i++){
    80207332:	4a8d                	li	s5,3
    80207334:	a88d                	j	802073a6 <virtio_disk_rw+0xb4>
      disk.free[i] = 0;
    80207336:	00fb8733          	add	a4,s7,a5
    8020733a:	975a                	add	a4,a4,s6
    8020733c:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80207340:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80207342:	0207c563          	bltz	a5,8020736c <virtio_disk_rw+0x7a>
  for(int i = 0; i < 3; i++){
    80207346:	2905                	addiw	s2,s2,1
    80207348:	0611                	addi	a2,a2,4 # 2004 <_entry-0x801fdffc>
    8020734a:	1b590163          	beq	s2,s5,802074ec <virtio_disk_rw+0x1fa>
    idx[i] = alloc_desc();
    8020734e:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80207350:	0001d717          	auipc	a4,0x1d
    80207354:	cc870713          	addi	a4,a4,-824 # 80224018 <disk+0x2018>
    80207358:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8020735a:	00074683          	lbu	a3,0(a4)
    8020735e:	fee1                	bnez	a3,80207336 <virtio_disk_rw+0x44>
  for(int i = 0; i < NUM; i++){
    80207360:	2785                	addiw	a5,a5,1
    80207362:	0705                	addi	a4,a4,1
    80207364:	fe979be3          	bne	a5,s1,8020735a <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80207368:	57fd                	li	a5,-1
    8020736a:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8020736c:	03205163          	blez	s2,8020738e <virtio_disk_rw+0x9c>
        free_desc(idx[j]);
    80207370:	f9042503          	lw	a0,-112(s0)
    80207374:	00000097          	auipc	ra,0x0
    80207378:	d70080e7          	jalr	-656(ra) # 802070e4 <free_desc>
      for(int j = 0; j < i; j++)
    8020737c:	4785                	li	a5,1
    8020737e:	0127d863          	bge	a5,s2,8020738e <virtio_disk_rw+0x9c>
        free_desc(idx[j]);
    80207382:	f9442503          	lw	a0,-108(s0)
    80207386:	00000097          	auipc	ra,0x0
    8020738a:	d5e080e7          	jalr	-674(ra) # 802070e4 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    8020738e:	0001d597          	auipc	a1,0x1d
    80207392:	d1a58593          	addi	a1,a1,-742 # 802240a8 <disk+0x20a8>
    80207396:	0001d517          	auipc	a0,0x1d
    8020739a:	c8250513          	addi	a0,a0,-894 # 80224018 <disk+0x2018>
    8020739e:	ffffb097          	auipc	ra,0xffffb
    802073a2:	fa4080e7          	jalr	-92(ra) # 80202342 <sleep>
  for(int i = 0; i < 3; i++){
    802073a6:	f9040613          	addi	a2,s0,-112
    802073aa:	894e                	mv	s2,s3
    802073ac:	b74d                	j	8020734e <virtio_disk_rw+0x5c>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    802073ae:	0001d717          	auipc	a4,0x1d
    802073b2:	c5273703          	ld	a4,-942(a4) # 80224000 <disk+0x2000>
    802073b6:	973e                	add	a4,a4,a5
    802073b8:	00071623          	sh	zero,12(a4)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    802073bc:	0001b517          	auipc	a0,0x1b
    802073c0:	c4450513          	addi	a0,a0,-956 # 80222000 <disk>
    802073c4:	0001d717          	auipc	a4,0x1d
    802073c8:	c3c70713          	addi	a4,a4,-964 # 80224000 <disk+0x2000>
    802073cc:	6314                	ld	a3,0(a4)
    802073ce:	96be                	add	a3,a3,a5
    802073d0:	00c6d603          	lhu	a2,12(a3)
    802073d4:	00166613          	ori	a2,a2,1
    802073d8:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    802073dc:	f9842683          	lw	a3,-104(s0)
    802073e0:	6310                	ld	a2,0(a4)
    802073e2:	97b2                	add	a5,a5,a2
    802073e4:	00d79723          	sh	a3,14(a5)

  disk.info[idx[0]].status = 0;
    802073e8:	20048613          	addi	a2,s1,512
    802073ec:	0612                	slli	a2,a2,0x4
    802073ee:	962a                	add	a2,a2,a0
    802073f0:	02060823          	sb	zero,48(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    802073f4:	00469793          	slli	a5,a3,0x4
    802073f8:	630c                	ld	a1,0(a4)
    802073fa:	95be                	add	a1,a1,a5
    802073fc:	6689                	lui	a3,0x2
    802073fe:	03068693          	addi	a3,a3,48 # 2030 <_entry-0x801fdfd0>
    80207402:	96ce                	add	a3,a3,s3
    80207404:	96aa                	add	a3,a3,a0
    80207406:	e194                	sd	a3,0(a1)
  disk.desc[idx[2]].len = 1;
    80207408:	6314                	ld	a3,0(a4)
    8020740a:	96be                	add	a3,a3,a5
    8020740c:	4585                	li	a1,1
    8020740e:	c68c                	sw	a1,8(a3)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80207410:	6314                	ld	a3,0(a4)
    80207412:	96be                	add	a3,a3,a5
    80207414:	4509                	li	a0,2
    80207416:	00a69623          	sh	a0,12(a3)
  disk.desc[idx[2]].next = 0;
    8020741a:	6314                	ld	a3,0(a4)
    8020741c:	97b6                	add	a5,a5,a3
    8020741e:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80207422:	00ba2223          	sw	a1,4(s4)
  disk.info[idx[0]].b = b;
    80207426:	03463423          	sd	s4,40(a2)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk.avail[2 + (disk.avail[1] % NUM)] = idx[0];
    8020742a:	6714                	ld	a3,8(a4)
    8020742c:	0026d783          	lhu	a5,2(a3)
    80207430:	8b9d                	andi	a5,a5,7
    80207432:	0789                	addi	a5,a5,2
    80207434:	0786                	slli	a5,a5,0x1
    80207436:	96be                	add	a3,a3,a5
    80207438:	00969023          	sh	s1,0(a3)
  __sync_synchronize();
    8020743c:	0ff0000f          	fence
  disk.avail[1] = disk.avail[1] + 1;
    80207440:	6718                	ld	a4,8(a4)
    80207442:	00275783          	lhu	a5,2(a4)
    80207446:	2785                	addiw	a5,a5,1
    80207448:	00f71123          	sh	a5,2(a4)
  __sync_synchronize();
    8020744c:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80207450:	03f107b7          	lui	a5,0x3f10
    80207454:	0785                	addi	a5,a5,1 # 3f10001 <_entry-0x7c2effff>
    80207456:	07b2                	slli	a5,a5,0xc
    80207458:	0407a823          	sw	zero,80(a5)

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8020745c:	004a2783          	lw	a5,4(s4)
    80207460:	02b79163          	bne	a5,a1,80207482 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80207464:	0001d917          	auipc	s2,0x1d
    80207468:	c4490913          	addi	s2,s2,-956 # 802240a8 <disk+0x20a8>
  while(b->disk == 1) {
    8020746c:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    8020746e:	85ca                	mv	a1,s2
    80207470:	8552                	mv	a0,s4
    80207472:	ffffb097          	auipc	ra,0xffffb
    80207476:	ed0080e7          	jalr	-304(ra) # 80202342 <sleep>
  while(b->disk == 1) {
    8020747a:	004a2783          	lw	a5,4(s4)
    8020747e:	fe9788e3          	beq	a5,s1,8020746e <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80207482:	f9042483          	lw	s1,-112(s0)
    80207486:	20048713          	addi	a4,s1,512
    8020748a:	0712                	slli	a4,a4,0x4
    8020748c:	0001b797          	auipc	a5,0x1b
    80207490:	b7478793          	addi	a5,a5,-1164 # 80222000 <disk>
    80207494:	97ba                	add	a5,a5,a4
    80207496:	0207b423          	sd	zero,40(a5)
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    8020749a:	0001d917          	auipc	s2,0x1d
    8020749e:	b6690913          	addi	s2,s2,-1178 # 80224000 <disk+0x2000>
    802074a2:	a019                	j	802074a8 <virtio_disk_rw+0x1b6>
      i = disk.desc[i].next;
    802074a4:	00e7d483          	lhu	s1,14(a5)
    free_desc(i);
    802074a8:	8526                	mv	a0,s1
    802074aa:	00000097          	auipc	ra,0x0
    802074ae:	c3a080e7          	jalr	-966(ra) # 802070e4 <free_desc>
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    802074b2:	0492                	slli	s1,s1,0x4
    802074b4:	00093783          	ld	a5,0(s2)
    802074b8:	97a6                	add	a5,a5,s1
    802074ba:	00c7d703          	lhu	a4,12(a5)
    802074be:	8b05                	andi	a4,a4,1
    802074c0:	f375                	bnez	a4,802074a4 <virtio_disk_rw+0x1b2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    802074c2:	0001d517          	auipc	a0,0x1d
    802074c6:	be650513          	addi	a0,a0,-1050 # 802240a8 <disk+0x20a8>
    802074ca:	ffff9097          	auipc	ra,0xffff9
    802074ce:	27a080e7          	jalr	634(ra) # 80200744 <release>
}
    802074d2:	70e6                	ld	ra,120(sp)
    802074d4:	7446                	ld	s0,112(sp)
    802074d6:	74a6                	ld	s1,104(sp)
    802074d8:	7906                	ld	s2,96(sp)
    802074da:	69e6                	ld	s3,88(sp)
    802074dc:	6a46                	ld	s4,80(sp)
    802074de:	6aa6                	ld	s5,72(sp)
    802074e0:	6b06                	ld	s6,64(sp)
    802074e2:	7be2                	ld	s7,56(sp)
    802074e4:	7c42                	ld	s8,48(sp)
    802074e6:	7ca2                	ld	s9,40(sp)
    802074e8:	6109                	addi	sp,sp,128
    802074ea:	8082                	ret
  if(write)
    802074ec:	018037b3          	snez	a5,s8
    802074f0:	f8f42023          	sw	a5,-128(s0)
  buf0.reserved = 0;
    802074f4:	f8042223          	sw	zero,-124(s0)
  buf0.sector = sector;
    802074f8:	f9943423          	sd	s9,-120(s0)
  disk.desc[idx[0]].addr = (uint64) kwalkaddr(myproc()->kpagetable, (uint64) &buf0);
    802074fc:	ffffa097          	auipc	ra,0xffffa
    80207500:	5d2080e7          	jalr	1490(ra) # 80201ace <myproc>
    80207504:	f9042483          	lw	s1,-112(s0)
    80207508:	00449993          	slli	s3,s1,0x4
    8020750c:	0001d917          	auipc	s2,0x1d
    80207510:	af490913          	addi	s2,s2,-1292 # 80224000 <disk+0x2000>
    80207514:	00093a83          	ld	s5,0(s2)
    80207518:	9ace                	add	s5,s5,s3
    8020751a:	f8040593          	addi	a1,s0,-128
    8020751e:	6d28                	ld	a0,88(a0)
    80207520:	ffff9097          	auipc	ra,0xffff9
    80207524:	730080e7          	jalr	1840(ra) # 80200c50 <kwalkaddr>
    80207528:	00aab023          	sd	a0,0(s5)
  disk.desc[idx[0]].len = sizeof(buf0);
    8020752c:	00093783          	ld	a5,0(s2)
    80207530:	97ce                	add	a5,a5,s3
    80207532:	4741                	li	a4,16
    80207534:	c798                	sw	a4,8(a5)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80207536:	00093783          	ld	a5,0(s2)
    8020753a:	97ce                	add	a5,a5,s3
    8020753c:	4705                	li	a4,1
    8020753e:	00e79623          	sh	a4,12(a5)
  disk.desc[idx[0]].next = idx[1];
    80207542:	f9442783          	lw	a5,-108(s0)
    80207546:	00093703          	ld	a4,0(s2)
    8020754a:	974e                	add	a4,a4,s3
    8020754c:	00f71723          	sh	a5,14(a4)
  disk.desc[idx[1]].addr = (uint64) b->data;
    80207550:	0792                	slli	a5,a5,0x4
    80207552:	00093703          	ld	a4,0(s2)
    80207556:	973e                	add	a4,a4,a5
    80207558:	058a0693          	addi	a3,s4,88
    8020755c:	e314                	sd	a3,0(a4)
  disk.desc[idx[1]].len = BSIZE;
    8020755e:	00093703          	ld	a4,0(s2)
    80207562:	973e                	add	a4,a4,a5
    80207564:	20000693          	li	a3,512
    80207568:	c714                	sw	a3,8(a4)
  if(write)
    8020756a:	e40c12e3          	bnez	s8,802073ae <virtio_disk_rw+0xbc>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8020756e:	0001d717          	auipc	a4,0x1d
    80207572:	a9273703          	ld	a4,-1390(a4) # 80224000 <disk+0x2000>
    80207576:	973e                	add	a4,a4,a5
    80207578:	4689                	li	a3,2
    8020757a:	00d71623          	sh	a3,12(a4)
    8020757e:	bd3d                	j	802073bc <virtio_disk_rw+0xca>

0000000080207580 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80207580:	1101                	addi	sp,sp,-32
    80207582:	ec06                	sd	ra,24(sp)
    80207584:	e822                	sd	s0,16(sp)
    80207586:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80207588:	0001d517          	auipc	a0,0x1d
    8020758c:	b2050513          	addi	a0,a0,-1248 # 802240a8 <disk+0x20a8>
    80207590:	ffff9097          	auipc	ra,0xffff9
    80207594:	160080e7          	jalr	352(ra) # 802006f0 <acquire>

  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80207598:	03f107b7          	lui	a5,0x3f10
    8020759c:	0785                	addi	a5,a5,1 # 3f10001 <_entry-0x7c2effff>
    8020759e:	07b2                	slli	a5,a5,0xc
    802075a0:	53b8                	lw	a4,96(a5)
    802075a2:	8b0d                	andi	a4,a4,3
    802075a4:	03f107b7          	lui	a5,0x3f10
    802075a8:	0785                	addi	a5,a5,1 # 3f10001 <_entry-0x7c2effff>
    802075aa:	07b2                	slli	a5,a5,0xc
    802075ac:	d3f8                	sw	a4,100(a5)
  __sync_synchronize();
    802075ae:	0ff0000f          	fence

  while(disk.used_idx != disk.used->id){
    802075b2:	0001d797          	auipc	a5,0x1d
    802075b6:	a4e78793          	addi	a5,a5,-1458 # 80224000 <disk+0x2000>
    802075ba:	6b94                	ld	a3,16(a5)
    802075bc:	0207d703          	lhu	a4,32(a5)
    802075c0:	0026d783          	lhu	a5,2(a3)
    802075c4:	06f70663          	beq	a4,a5,80207630 <virtio_disk_intr+0xb0>
    802075c8:	e426                	sd	s1,8(sp)
    802075ca:	e04a                	sd	s2,0(sp)
    __sync_synchronize();
    int id = disk.used->elems[disk.used_idx % NUM].id;
    802075cc:	0001b917          	auipc	s2,0x1b
    802075d0:	a3490913          	addi	s2,s2,-1484 # 80222000 <disk>
    802075d4:	0001d497          	auipc	s1,0x1d
    802075d8:	a2c48493          	addi	s1,s1,-1492 # 80224000 <disk+0x2000>
    __sync_synchronize();
    802075dc:	0ff0000f          	fence
    int id = disk.used->elems[disk.used_idx % NUM].id;
    802075e0:	6898                	ld	a4,16(s1)
    802075e2:	0204d783          	lhu	a5,32(s1)
    802075e6:	8b9d                	andi	a5,a5,7
    802075e8:	078e                	slli	a5,a5,0x3
    802075ea:	97ba                	add	a5,a5,a4
    802075ec:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    802075ee:	20078713          	addi	a4,a5,512
    802075f2:	0712                	slli	a4,a4,0x4
    802075f4:	974a                	add	a4,a4,s2
    802075f6:	03074703          	lbu	a4,48(a4)
    802075fa:	e739                	bnez	a4,80207648 <virtio_disk_intr+0xc8>
      panic("virtio_disk_intr status");

    disk.info[id].b->disk = 0;   // disk is done with buf
    802075fc:	20078793          	addi	a5,a5,512
    80207600:	0792                	slli	a5,a5,0x4
    80207602:	97ca                	add	a5,a5,s2
    80207604:	7798                	ld	a4,40(a5)
    80207606:	00072223          	sw	zero,4(a4)
    wakeup(disk.info[id].b);
    8020760a:	7788                	ld	a0,40(a5)
    8020760c:	ffffb097          	auipc	ra,0xffffb
    80207610:	eb2080e7          	jalr	-334(ra) # 802024be <wakeup>

    disk.used_idx++;
    80207614:	0204d783          	lhu	a5,32(s1)
    80207618:	2785                	addiw	a5,a5,1
    8020761a:	17c2                	slli	a5,a5,0x30
    8020761c:	93c1                	srli	a5,a5,0x30
    8020761e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->id){
    80207622:	6898                	ld	a4,16(s1)
    80207624:	00275703          	lhu	a4,2(a4)
    80207628:	faf71ae3          	bne	a4,a5,802075dc <virtio_disk_intr+0x5c>
    8020762c:	64a2                	ld	s1,8(sp)
    8020762e:	6902                	ld	s2,0(sp)
  }

  release(&disk.vdisk_lock);
    80207630:	0001d517          	auipc	a0,0x1d
    80207634:	a7850513          	addi	a0,a0,-1416 # 802240a8 <disk+0x20a8>
    80207638:	ffff9097          	auipc	ra,0xffff9
    8020763c:	10c080e7          	jalr	268(ra) # 80200744 <release>
}
    80207640:	60e2                	ld	ra,24(sp)
    80207642:	6442                	ld	s0,16(sp)
    80207644:	6105                	addi	sp,sp,32
    80207646:	8082                	ret
      panic("virtio_disk_intr status");
    80207648:	00002517          	auipc	a0,0x2
    8020764c:	6f050513          	addi	a0,a0,1776 # 80209d38 <etext+0xd38>
    80207650:	ffff9097          	auipc	ra,0xffff9
    80207654:	af6080e7          	jalr	-1290(ra) # 80200146 <panic>
	...

0000000080208000 <_trampoline>:
    80208000:	14051573          	csrrw	a0,sscratch,a0
    80208004:	02153423          	sd	ra,40(a0)
    80208008:	02253823          	sd	sp,48(a0)
    8020800c:	02353c23          	sd	gp,56(a0)
    80208010:	04453023          	sd	tp,64(a0)
    80208014:	04553423          	sd	t0,72(a0)
    80208018:	04653823          	sd	t1,80(a0)
    8020801c:	04753c23          	sd	t2,88(a0)
    80208020:	f120                	sd	s0,96(a0)
    80208022:	f524                	sd	s1,104(a0)
    80208024:	fd2c                	sd	a1,120(a0)
    80208026:	e150                	sd	a2,128(a0)
    80208028:	e554                	sd	a3,136(a0)
    8020802a:	e958                	sd	a4,144(a0)
    8020802c:	ed5c                	sd	a5,152(a0)
    8020802e:	0b053023          	sd	a6,160(a0)
    80208032:	0b153423          	sd	a7,168(a0)
    80208036:	0b253823          	sd	s2,176(a0)
    8020803a:	0b353c23          	sd	s3,184(a0)
    8020803e:	0d453023          	sd	s4,192(a0)
    80208042:	0d553423          	sd	s5,200(a0)
    80208046:	0d653823          	sd	s6,208(a0)
    8020804a:	0d753c23          	sd	s7,216(a0)
    8020804e:	0f853023          	sd	s8,224(a0)
    80208052:	0f953423          	sd	s9,232(a0)
    80208056:	0fa53823          	sd	s10,240(a0)
    8020805a:	0fb53c23          	sd	s11,248(a0)
    8020805e:	11c53023          	sd	t3,256(a0)
    80208062:	11d53423          	sd	t4,264(a0)
    80208066:	11e53823          	sd	t5,272(a0)
    8020806a:	11f53c23          	sd	t6,280(a0)
    8020806e:	140022f3          	csrr	t0,sscratch
    80208072:	06553823          	sd	t0,112(a0)
    80208076:	00853103          	ld	sp,8(a0)
    8020807a:	02053203          	ld	tp,32(a0)
    8020807e:	01053283          	ld	t0,16(a0)
    80208082:	00053303          	ld	t1,0(a0)
    80208086:	18031073          	csrw	satp,t1
    8020808a:	12000073          	sfence.vma
    8020808e:	8282                	jr	t0

0000000080208090 <userret>:
    80208090:	18059073          	csrw	satp,a1
    80208094:	12000073          	sfence.vma
    80208098:	07053283          	ld	t0,112(a0)
    8020809c:	14029073          	csrw	sscratch,t0
    802080a0:	02853083          	ld	ra,40(a0)
    802080a4:	03053103          	ld	sp,48(a0)
    802080a8:	03853183          	ld	gp,56(a0)
    802080ac:	04053203          	ld	tp,64(a0)
    802080b0:	04853283          	ld	t0,72(a0)
    802080b4:	05053303          	ld	t1,80(a0)
    802080b8:	05853383          	ld	t2,88(a0)
    802080bc:	7120                	ld	s0,96(a0)
    802080be:	7524                	ld	s1,104(a0)
    802080c0:	7d2c                	ld	a1,120(a0)
    802080c2:	6150                	ld	a2,128(a0)
    802080c4:	6554                	ld	a3,136(a0)
    802080c6:	6958                	ld	a4,144(a0)
    802080c8:	6d5c                	ld	a5,152(a0)
    802080ca:	0a053803          	ld	a6,160(a0)
    802080ce:	0a853883          	ld	a7,168(a0)
    802080d2:	0b053903          	ld	s2,176(a0)
    802080d6:	0b853983          	ld	s3,184(a0)
    802080da:	0c053a03          	ld	s4,192(a0)
    802080de:	0c853a83          	ld	s5,200(a0)
    802080e2:	0d053b03          	ld	s6,208(a0)
    802080e6:	0d853b83          	ld	s7,216(a0)
    802080ea:	0e053c03          	ld	s8,224(a0)
    802080ee:	0e853c83          	ld	s9,232(a0)
    802080f2:	0f053d03          	ld	s10,240(a0)
    802080f6:	0f853d83          	ld	s11,248(a0)
    802080fa:	10053e03          	ld	t3,256(a0)
    802080fe:	10853e83          	ld	t4,264(a0)
    80208102:	11053f03          	ld	t5,272(a0)
    80208106:	11853f83          	ld	t6,280(a0)
    8020810a:	14051573          	csrrw	a0,sscratch,a0
    8020810e:	10200073          	sret
	...
