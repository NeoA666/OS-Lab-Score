
xv6-user/_sh:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <checkenvname>:

char mycwd[128];

int
checkenvname(char* s)
{
       0:	1141                	addi	sp,sp,-16
       2:	e422                	sd	s0,8(sp)
       4:	0800                	addi	s0,sp,16
  if((*s >= 'A' && *s <= 'Z') ||
       6:	00054703          	lbu	a4,0(a0)
       a:	fbf7071b          	addiw	a4,a4,-65
       e:	0ff77713          	zext.b	a4,a4
      12:	03900793          	li	a5,57
      16:	04e7ed63          	bltu	a5,a4,70 <checkenvname+0x70>
      1a:	fd100793          	li	a5,-47
      1e:	1782                	slli	a5,a5,0x20
      20:	17fd                	addi	a5,a5,-1
      22:	8399                	srli	a5,a5,0x6
      24:	00e7d7b3          	srl	a5,a5,a4
      28:	8b85                	andi	a5,a5,1
      2a:	c7a9                	beqz	a5,74 <checkenvname+0x74>
     (*s >= 'a' && *s <= 'z') ||
      *s == '_')
    ;
  else
    return 0;
  char *tmp = s + 1;
      2c:	00150713          	addi	a4,a0,1
  while((*tmp >= 'A' && *tmp <= 'Z') ||
      30:	03900693          	li	a3,57
      34:	fd100613          	li	a2,-47
      38:	1602                	slli	a2,a2,0x20
      3a:	167d                	addi	a2,a2,-1
      3c:	8219                	srli	a2,a2,0x6
      3e:	02f00593          	li	a1,47
      42:	a021                	j	4a <checkenvname+0x4a>
      44:	02f5f163          	bgeu	a1,a5,66 <checkenvname+0x66>
        (*tmp >= 'a' && *tmp <= 'z') ||
        (*tmp >= '0' && *tmp <= '9') ||
         *tmp == '_')
    tmp++;
      48:	0705                	addi	a4,a4,1
  while((*tmp >= 'A' && *tmp <= 'Z') ||
      4a:	00074783          	lbu	a5,0(a4)
      4e:	fef6fbe3          	bgeu	a3,a5,44 <checkenvname+0x44>
      52:	fbf7879b          	addiw	a5,a5,-65
      56:	0ff7f793          	zext.b	a5,a5
      5a:	00f6e663          	bltu	a3,a5,66 <checkenvname+0x66>
      5e:	00f657b3          	srl	a5,a2,a5
      62:	8b85                	andi	a5,a5,1
      64:	f3f5                	bnez	a5,48 <checkenvname+0x48>
  return (int)(tmp - s);
      66:	40a7053b          	subw	a0,a4,a0
}
      6a:	6422                	ld	s0,8(sp)
      6c:	0141                	addi	sp,sp,16
      6e:	8082                	ret
  if((*s >= 'A' && *s <= 'Z') ||
      70:	4501                	li	a0,0
      72:	bfe5                	j	6a <checkenvname+0x6a>
      74:	4501                	li	a0,0
      76:	bfd5                	j	6a <checkenvname+0x6a>

0000000000000078 <export>:

int
export(char *argv[])
{
      78:	7131                	addi	sp,sp,-192
      7a:	fd06                	sd	ra,184(sp)
      7c:	f922                	sd	s0,176(sp)
      7e:	f526                	sd	s1,168(sp)
      80:	ed4e                	sd	s3,152(sp)
      82:	0180                	addi	s0,sp,192
      84:	84aa                	mv	s1,a0
  if(!strcmp(argv[1], "-p"))
      86:	00001597          	auipc	a1,0x1
      8a:	7e258593          	addi	a1,a1,2018 # 1868 <malloc+0x100>
      8e:	6508                	ld	a0,8(a0)
      90:	00001097          	auipc	ra,0x1
      94:	028080e7          	jalr	40(ra) # 10b8 <strcmp>
      98:	ed3d                	bnez	a0,116 <export+0x9e>
      9a:	e15a                	sd	s6,128(sp)
      9c:	89aa                	mv	s3,a0
  { // print all the env vars
    if(!nenv)
      9e:	00002b17          	auipc	s6,0x2
      a2:	a32b2b03          	lw	s6,-1486(s6) # 1ad0 <nenv>
      a6:	040b0d63          	beqz	s6,100 <export+0x88>
      aa:	f14a                	sd	s2,160(sp)
      ac:	e952                	sd	s4,144(sp)
      ae:	e556                	sd	s5,136(sp)
    {
      printf("NO env var exported\n");
      return 0;
    }
    for(int i=0; i<nenv; i++)
      b0:	00002497          	auipc	s1,0x2
      b4:	b1848493          	addi	s1,s1,-1256 # 1bc8 <envs>
      b8:	892a                	mv	s2,a0
      printf("export %s=%s\n", envs[i].name, envs[i].value);
      ba:	00001a97          	auipc	s5,0x1
      be:	7cea8a93          	addi	s5,s5,1998 # 1888 <malloc+0x120>
    for(int i=0; i<nenv; i++)
      c2:	00002a17          	auipc	s4,0x2
      c6:	a0ea0a13          	addi	s4,s4,-1522 # 1ad0 <nenv>
      ca:	03605663          	blez	s6,f6 <export+0x7e>
      printf("export %s=%s\n", envs[i].name, envs[i].value);
      ce:	02048613          	addi	a2,s1,32
      d2:	85a6                	mv	a1,s1
      d4:	8556                	mv	a0,s5
      d6:	00001097          	auipc	ra,0x1
      da:	5da080e7          	jalr	1498(ra) # 16b0 <printf>
    for(int i=0; i<nenv; i++)
      de:	2905                	addiw	s2,s2,1
      e0:	08048493          	addi	s1,s1,128
      e4:	000a2783          	lw	a5,0(s4)
      e8:	fef943e3          	blt	s2,a5,ce <export+0x56>
      ec:	790a                	ld	s2,160(sp)
      ee:	6a4a                	ld	s4,144(sp)
      f0:	6aaa                	ld	s5,136(sp)
      f2:	6b0a                	ld	s6,128(sp)
      f4:	a0dd                	j	1da <export+0x162>
      f6:	790a                	ld	s2,160(sp)
      f8:	6a4a                	ld	s4,144(sp)
      fa:	6aaa                	ld	s5,136(sp)
      fc:	6b0a                	ld	s6,128(sp)
      fe:	a8f1                	j	1da <export+0x162>
      printf("NO env var exported\n");
     100:	00001517          	auipc	a0,0x1
     104:	77050513          	addi	a0,a0,1904 # 1870 <malloc+0x108>
     108:	00001097          	auipc	ra,0x1
     10c:	5a8080e7          	jalr	1448(ra) # 16b0 <printf>
      return 0;
     110:	89da                	mv	s3,s6
     112:	6b0a                	ld	s6,128(sp)
     114:	a0d9                	j	1da <export+0x162>
    return 0;
  }
  else if(nenv == NENVS)
     116:	00002997          	auipc	s3,0x2
     11a:	9ba9a983          	lw	s3,-1606(s3) # 1ad0 <nenv>
     11e:	47c1                	li	a5,16
     120:	0cf98463          	beq	s3,a5,1e8 <export+0x170>
     124:	f14a                	sd	s2,160(sp)
    return -1;
  }
  char name[32], value[96];
  char *s = argv[1], *t = name;

  for(s=argv[1], t=name; (*t=*s++)!='='; t++)
     126:	0084b903          	ld	s2,8(s1)
     12a:	00190493          	addi	s1,s2,1
     12e:	00094783          	lbu	a5,0(s2)
     132:	faf40023          	sb	a5,-96(s0)
     136:	03d00713          	li	a4,61
     13a:	0ce78263          	beq	a5,a4,1fe <export+0x186>
     13e:	fa040793          	addi	a5,s0,-96
     142:	03d00693          	li	a3,61
     146:	0785                	addi	a5,a5,1
     148:	0485                	addi	s1,s1,1
     14a:	fff4c703          	lbu	a4,-1(s1)
     14e:	00e78023          	sb	a4,0(a5)
     152:	fed71ae3          	bne	a4,a3,146 <export+0xce>
    ;
  *t = 0;
     156:	00078023          	sb	zero,0(a5)

  if(checkenvname(name) != ((s - argv[1]) - 1))
     15a:	fa040513          	addi	a0,s0,-96
     15e:	00000097          	auipc	ra,0x0
     162:	ea2080e7          	jalr	-350(ra) # 0 <checkenvname>
     166:	41248933          	sub	s2,s1,s2
     16a:	197d                	addi	s2,s2,-1
     16c:	09251c63          	bne	a0,s2,204 <export+0x18c>
  {
    fprintf(2, "Invalid NAME!\n");
    return -1;
  }
  for(t=value; (*t=*s); s++, t++)
     170:	0004c703          	lbu	a4,0(s1)
     174:	f4e40023          	sb	a4,-192(s0)
     178:	f4040793          	addi	a5,s0,-192
     17c:	cb01                	beqz	a4,18c <export+0x114>
     17e:	0485                	addi	s1,s1,1
     180:	0785                	addi	a5,a5,1
     182:	0004c703          	lbu	a4,0(s1)
     186:	00e78023          	sb	a4,0(a5)
     18a:	fb75                	bnez	a4,17e <export+0x106>
    ;
  if(*--t == '/')
     18c:	fff7c683          	lbu	a3,-1(a5)
     190:	02f00713          	li	a4,47
     194:	08e68463          	beq	a3,a4,21c <export+0x1a4>
    *t = 0;
  
  strcpy(envs[nenv].name, name);
     198:	00799513          	slli	a0,s3,0x7
     19c:	00002917          	auipc	s2,0x2
     1a0:	a2c90913          	addi	s2,s2,-1492 # 1bc8 <envs>
     1a4:	fa040593          	addi	a1,s0,-96
     1a8:	954a                	add	a0,a0,s2
     1aa:	00001097          	auipc	ra,0x1
     1ae:	ec4080e7          	jalr	-316(ra) # 106e <strcpy>
  strcpy(envs[nenv].value, value);
     1b2:	00002497          	auipc	s1,0x2
     1b6:	91e48493          	addi	s1,s1,-1762 # 1ad0 <nenv>
     1ba:	4088                	lw	a0,0(s1)
     1bc:	051e                	slli	a0,a0,0x7
     1be:	02050513          	addi	a0,a0,32
     1c2:	f4040593          	addi	a1,s0,-192
     1c6:	954a                	add	a0,a0,s2
     1c8:	00001097          	auipc	ra,0x1
     1cc:	ea6080e7          	jalr	-346(ra) # 106e <strcpy>
  nenv++;
     1d0:	409c                	lw	a5,0(s1)
     1d2:	2785                	addiw	a5,a5,1
     1d4:	c09c                	sw	a5,0(s1)
  return 0;
     1d6:	4981                	li	s3,0
     1d8:	790a                	ld	s2,160(sp)
}
     1da:	854e                	mv	a0,s3
     1dc:	70ea                	ld	ra,184(sp)
     1de:	744a                	ld	s0,176(sp)
     1e0:	74aa                	ld	s1,168(sp)
     1e2:	69ea                	ld	s3,152(sp)
     1e4:	6129                	addi	sp,sp,192
     1e6:	8082                	ret
    fprintf(2, "too many env vars\n");
     1e8:	00001597          	auipc	a1,0x1
     1ec:	6b058593          	addi	a1,a1,1712 # 1898 <malloc+0x130>
     1f0:	4509                	li	a0,2
     1f2:	00001097          	auipc	ra,0x1
     1f6:	490080e7          	jalr	1168(ra) # 1682 <fprintf>
    return -1;
     1fa:	59fd                	li	s3,-1
     1fc:	bff9                	j	1da <export+0x162>
  for(s=argv[1], t=name; (*t=*s++)!='='; t++)
     1fe:	fa040793          	addi	a5,s0,-96
     202:	bf91                	j	156 <export+0xde>
    fprintf(2, "Invalid NAME!\n");
     204:	00001597          	auipc	a1,0x1
     208:	6ac58593          	addi	a1,a1,1708 # 18b0 <malloc+0x148>
     20c:	4509                	li	a0,2
     20e:	00001097          	auipc	ra,0x1
     212:	474080e7          	jalr	1140(ra) # 1682 <fprintf>
    return -1;
     216:	59fd                	li	s3,-1
     218:	790a                	ld	s2,160(sp)
     21a:	b7c1                	j	1da <export+0x162>
    *t = 0;
     21c:	fe078fa3          	sb	zero,-1(a5)
     220:	bfa5                	j	198 <export+0x120>

0000000000000222 <replace>:

int
replace(char *buf)
{
     222:	7151                	addi	sp,sp,-240
     224:	f586                	sd	ra,232(sp)
     226:	f1a2                	sd	s0,224(sp)
     228:	eda6                	sd	s1,216(sp)
     22a:	fd56                	sd	s5,184(sp)
     22c:	1980                	addi	s0,sp,240
     22e:	84aa                	mv	s1,a0
  char raw[100], name[32], *s, *t, *tmp;
  int n = 0;
  strcpy(raw, buf);
     230:	85aa                	mv	a1,a0
     232:	f3840513          	addi	a0,s0,-200
     236:	00001097          	auipc	ra,0x1
     23a:	e38080e7          	jalr	-456(ra) # 106e <strcpy>
  for(s=raw, t=buf; (*t=*s); t++)
     23e:	f3844783          	lbu	a5,-200(s0)
     242:	00f48023          	sb	a5,0(s1)
     246:	12078863          	beqz	a5,376 <replace+0x154>
     24a:	e9ca                	sd	s2,208(sp)
     24c:	e5ce                	sd	s3,200(sp)
     24e:	e1d2                	sd	s4,192(sp)
     250:	f95a                	sd	s6,176(sp)
  int n = 0;
     252:	4a81                	li	s5,0
  for(s=raw, t=buf; (*t=*s); t++)
     254:	f3840713          	addi	a4,s0,-200
  {
    if(*s++ == '$'){
     258:	02400993          	li	s3,36
     25c:	03900b13          	li	s6,57
     260:	fd100a13          	li	s4,-47
     264:	1a02                	slli	s4,s4,0x20
     266:	1a7d                	addi	s4,s4,-1
     268:	006a5a13          	srli	s4,s4,0x6
     26c:	a03d                	j	29a <replace+0x78>
      tmp = name;
      if((*s >= 'A' && *s <= 'Z') || (*s >= 'a' && *s <= 'z') || *s == '_')
     26e:	00174683          	lbu	a3,1(a4)
     272:	fbf6879b          	addiw	a5,a3,-65
     276:	0ff7f793          	zext.b	a5,a5
     27a:	00fb6663          	bltu	s6,a5,286 <replace+0x64>
     27e:	00fa57b3          	srl	a5,s4,a5
     282:	8b85                	andi	a5,a5,1
     284:	e395                	bnez	a5,2a8 <replace+0x86>
          if(!strcmp(name, envs[i].name))
            for(tmp=envs[i].value; (*t=*tmp); t++, tmp++)
              ;
        t--;
      }
      n++;
     286:	2a85                	addiw	s5,s5,1
     288:	86a6                	mv	a3,s1
     28a:	874a                	mv	a4,s2
  for(s=raw, t=buf; (*t=*s); t++)
     28c:	00168493          	addi	s1,a3,1
     290:	00074783          	lbu	a5,0(a4)
     294:	00f680a3          	sb	a5,1(a3)
     298:	c7e1                	beqz	a5,360 <replace+0x13e>
    if(*s++ == '$'){
     29a:	00170913          	addi	s2,a4,1
     29e:	fd3788e3          	beq	a5,s3,26e <replace+0x4c>
     2a2:	86a6                	mv	a3,s1
     2a4:	874a                	mv	a4,s2
     2a6:	b7dd                	j	28c <replace+0x6a>
        *tmp++ = *s++;
     2a8:	00270913          	addi	s2,a4,2
     2ac:	f0d40c23          	sb	a3,-232(s0)
     2b0:	f1940693          	addi	a3,s0,-231
     2b4:	03900613          	li	a2,57
     2b8:	fd100593          	li	a1,-47
     2bc:	1582                	slli	a1,a1,0x20
     2be:	15fd                	addi	a1,a1,-1
     2c0:	8199                	srli	a1,a1,0x6
     2c2:	02f00513          	li	a0,47
        while((*s >= 'A' && *s <= 'Z') || (*s >= 'a' && *s <= 'z') || (*s >= '0' && *s <= '9') || *s == '_')
     2c6:	a039                	j	2d4 <replace+0xb2>
     2c8:	02e57463          	bgeu	a0,a4,2f0 <replace+0xce>
          *tmp++ = *s++;
     2cc:	0905                	addi	s2,s2,1
     2ce:	0685                	addi	a3,a3,1
     2d0:	fee68fa3          	sb	a4,-1(a3)
        while((*s >= 'A' && *s <= 'Z') || (*s >= 'a' && *s <= 'z') || (*s >= '0' && *s <= '9') || *s == '_')
     2d4:	00094703          	lbu	a4,0(s2)
     2d8:	fee678e3          	bgeu	a2,a4,2c8 <replace+0xa6>
     2dc:	fbf7079b          	addiw	a5,a4,-65
     2e0:	0ff7f793          	zext.b	a5,a5
     2e4:	00f66663          	bltu	a2,a5,2f0 <replace+0xce>
     2e8:	00f5d7b3          	srl	a5,a1,a5
     2ec:	8b85                	andi	a5,a5,1
     2ee:	fff9                	bnez	a5,2cc <replace+0xaa>
        *tmp = 0;
     2f0:	00068023          	sb	zero,0(a3)
        for(int i=0; i<nenv; i++)
     2f4:	00001797          	auipc	a5,0x1
     2f8:	7dc7a783          	lw	a5,2012(a5) # 1ad0 <nenv>
     2fc:	06f05063          	blez	a5,35c <replace+0x13a>
     300:	f55e                	sd	s7,168(sp)
     302:	f162                	sd	s8,160(sp)
     304:	ed66                	sd	s9,152(sp)
     306:	00002b97          	auipc	s7,0x2
     30a:	8e2b8b93          	addi	s7,s7,-1822 # 1be8 <envs+0x20>
     30e:	4c01                	li	s8,0
     310:	00001c97          	auipc	s9,0x1
     314:	7c0c8c93          	addi	s9,s9,1984 # 1ad0 <nenv>
     318:	a801                	j	328 <replace+0x106>
     31a:	2c05                	addiw	s8,s8,1
     31c:	080b8b93          	addi	s7,s7,128
     320:	000ca783          	lw	a5,0(s9)
     324:	02fc5963          	bge	s8,a5,356 <replace+0x134>
          if(!strcmp(name, envs[i].name))
     328:	fe0b8593          	addi	a1,s7,-32
     32c:	f1840513          	addi	a0,s0,-232
     330:	00001097          	auipc	ra,0x1
     334:	d88080e7          	jalr	-632(ra) # 10b8 <strcmp>
     338:	f16d                	bnez	a0,31a <replace+0xf8>
            for(tmp=envs[i].value; (*t=*tmp); t++, tmp++)
     33a:	87de                	mv	a5,s7
     33c:	000bc703          	lbu	a4,0(s7)
     340:	00e48023          	sb	a4,0(s1)
     344:	db79                	beqz	a4,31a <replace+0xf8>
     346:	0485                	addi	s1,s1,1
     348:	0785                	addi	a5,a5,1
     34a:	0007c703          	lbu	a4,0(a5)
     34e:	00e48023          	sb	a4,0(s1)
     352:	fb75                	bnez	a4,346 <replace+0x124>
     354:	b7d9                	j	31a <replace+0xf8>
     356:	7baa                	ld	s7,168(sp)
     358:	7c0a                	ld	s8,160(sp)
     35a:	6cea                	ld	s9,152(sp)
        t--;
     35c:	14fd                	addi	s1,s1,-1
     35e:	b725                	j	286 <replace+0x64>
     360:	694e                	ld	s2,208(sp)
     362:	69ae                	ld	s3,200(sp)
     364:	6a0e                	ld	s4,192(sp)
     366:	7b4a                	ld	s6,176(sp)
    }
  }
  return n;
}
     368:	8556                	mv	a0,s5
     36a:	70ae                	ld	ra,232(sp)
     36c:	740e                	ld	s0,224(sp)
     36e:	64ee                	ld	s1,216(sp)
     370:	7aea                	ld	s5,184(sp)
     372:	616d                	addi	sp,sp,240
     374:	8082                	ret
  int n = 0;
     376:	4a81                	li	s5,0
     378:	bfc5                	j	368 <replace+0x146>

000000000000037a <getcmd>:
  exit(0);
}

int
getcmd(char *buf, int nbuf)
{
     37a:	1101                	addi	sp,sp,-32
     37c:	ec06                	sd	ra,24(sp)
     37e:	e822                	sd	s0,16(sp)
     380:	e426                	sd	s1,8(sp)
     382:	e04a                	sd	s2,0(sp)
     384:	1000                	addi	s0,sp,32
     386:	84aa                	mv	s1,a0
     388:	892e                	mv	s2,a1
  fprintf(2, "-> %s $ ", mycwd);
     38a:	00001617          	auipc	a2,0x1
     38e:	75660613          	addi	a2,a2,1878 # 1ae0 <mycwd>
     392:	00001597          	auipc	a1,0x1
     396:	52e58593          	addi	a1,a1,1326 # 18c0 <malloc+0x158>
     39a:	4509                	li	a0,2
     39c:	00001097          	auipc	ra,0x1
     3a0:	2e6080e7          	jalr	742(ra) # 1682 <fprintf>
  memset(buf, 0, nbuf);
     3a4:	864a                	mv	a2,s2
     3a6:	4581                	li	a1,0
     3a8:	8526                	mv	a0,s1
     3aa:	00001097          	auipc	ra,0x1
     3ae:	d64080e7          	jalr	-668(ra) # 110e <memset>
  gets(buf, nbuf);
     3b2:	85ca                	mv	a1,s2
     3b4:	8526                	mv	a0,s1
     3b6:	00001097          	auipc	ra,0x1
     3ba:	d9e080e7          	jalr	-610(ra) # 1154 <gets>
  if(buf[0] == 0) // EOF
     3be:	0004c503          	lbu	a0,0(s1)
     3c2:	00153513          	seqz	a0,a0
    return -1;
  return 0;
}
     3c6:	40a00533          	neg	a0,a0
     3ca:	60e2                	ld	ra,24(sp)
     3cc:	6442                	ld	s0,16(sp)
     3ce:	64a2                	ld	s1,8(sp)
     3d0:	6902                	ld	s2,0(sp)
     3d2:	6105                	addi	sp,sp,32
     3d4:	8082                	ret

00000000000003d6 <panic>:
  exit(0);
}

void
panic(char *s)
{
     3d6:	1141                	addi	sp,sp,-16
     3d8:	e406                	sd	ra,8(sp)
     3da:	e022                	sd	s0,0(sp)
     3dc:	0800                	addi	s0,sp,16
     3de:	862a                	mv	a2,a0
  fprintf(2, "%s\n", s);
     3e0:	00001597          	auipc	a1,0x1
     3e4:	4f058593          	addi	a1,a1,1264 # 18d0 <malloc+0x168>
     3e8:	4509                	li	a0,2
     3ea:	00001097          	auipc	ra,0x1
     3ee:	298080e7          	jalr	664(ra) # 1682 <fprintf>
  exit(1);
     3f2:	4505                	li	a0,1
     3f4:	00001097          	auipc	ra,0x1
     3f8:	f2c080e7          	jalr	-212(ra) # 1320 <exit>

00000000000003fc <fork1>:
}

int
fork1(void)
{
     3fc:	1141                	addi	sp,sp,-16
     3fe:	e406                	sd	ra,8(sp)
     400:	e022                	sd	s0,0(sp)
     402:	0800                	addi	s0,sp,16
  int pid;

  pid = fork();
     404:	00001097          	auipc	ra,0x1
     408:	f14080e7          	jalr	-236(ra) # 1318 <fork>
  if(pid == -1)
     40c:	57fd                	li	a5,-1
     40e:	00f50663          	beq	a0,a5,41a <fork1+0x1e>
    panic("fork");
  return pid;
}
     412:	60a2                	ld	ra,8(sp)
     414:	6402                	ld	s0,0(sp)
     416:	0141                	addi	sp,sp,16
     418:	8082                	ret
    panic("fork");
     41a:	00001517          	auipc	a0,0x1
     41e:	4be50513          	addi	a0,a0,1214 # 18d8 <malloc+0x170>
     422:	00000097          	auipc	ra,0x0
     426:	fb4080e7          	jalr	-76(ra) # 3d6 <panic>

000000000000042a <runcmd>:
{
     42a:	7175                	addi	sp,sp,-144
     42c:	e506                	sd	ra,136(sp)
     42e:	e122                	sd	s0,128(sp)
     430:	0900                	addi	s0,sp,144
  if(cmd == 0)
     432:	c51d                	beqz	a0,460 <runcmd+0x36>
     434:	fca6                	sd	s1,120(sp)
     436:	f8ca                	sd	s2,112(sp)
     438:	f4ce                	sd	s3,104(sp)
     43a:	f0d2                	sd	s4,96(sp)
     43c:	ecd6                	sd	s5,88(sp)
     43e:	e8da                	sd	s6,80(sp)
     440:	84aa                	mv	s1,a0
  switch(cmd->type){
     442:	4118                	lw	a4,0(a0)
     444:	4795                	li	a5,5
     446:	02e7e863          	bltu	a5,a4,476 <runcmd+0x4c>
     44a:	00056783          	lwu	a5,0(a0)
     44e:	078a                	slli	a5,a5,0x2
     450:	00001717          	auipc	a4,0x1
     454:	5d070713          	addi	a4,a4,1488 # 1a20 <malloc+0x2b8>
     458:	97ba                	add	a5,a5,a4
     45a:	439c                	lw	a5,0(a5)
     45c:	97ba                	add	a5,a5,a4
     45e:	8782                	jr	a5
     460:	fca6                	sd	s1,120(sp)
     462:	f8ca                	sd	s2,112(sp)
     464:	f4ce                	sd	s3,104(sp)
     466:	f0d2                	sd	s4,96(sp)
     468:	ecd6                	sd	s5,88(sp)
     46a:	e8da                	sd	s6,80(sp)
    exit(1);
     46c:	4505                	li	a0,1
     46e:	00001097          	auipc	ra,0x1
     472:	eb2080e7          	jalr	-334(ra) # 1320 <exit>
    panic("runcmd");
     476:	00001517          	auipc	a0,0x1
     47a:	46a50513          	addi	a0,a0,1130 # 18e0 <malloc+0x178>
     47e:	00000097          	auipc	ra,0x0
     482:	f58080e7          	jalr	-168(ra) # 3d6 <panic>
    if(ecmd->argv[0] == 0)
     486:	6508                	ld	a0,8(a0)
     488:	c14d                	beqz	a0,52a <runcmd+0x100>
    exec(ecmd->argv[0], ecmd->argv);
     48a:	00848a13          	addi	s4,s1,8
     48e:	85d2                	mv	a1,s4
     490:	00001097          	auipc	ra,0x1
     494:	ec8080e7          	jalr	-312(ra) # 1358 <exec>
    for(i=0; i<nenv; i++)
     498:	00001797          	auipc	a5,0x1
     49c:	6387a783          	lw	a5,1592(a5) # 1ad0 <nenv>
     4a0:	06f05663          	blez	a5,50c <runcmd+0xe2>
     4a4:	00001917          	auipc	s2,0x1
     4a8:	74590913          	addi	s2,s2,1861 # 1be9 <envs+0x21>
     4ac:	4981                	li	s3,0
      *s_tmp++ = '/';
     4ae:	02f00b13          	li	s6,47
    for(i=0; i<nenv; i++)
     4b2:	00001a97          	auipc	s5,0x1
     4b6:	61ea8a93          	addi	s5,s5,1566 # 1ad0 <nenv>
      while((*s_tmp = *d_tmp++))
     4ba:	874a                	mv	a4,s2
     4bc:	fff94783          	lbu	a5,-1(s2)
     4c0:	f6f40c23          	sb	a5,-136(s0)
     4c4:	cba5                	beqz	a5,534 <runcmd+0x10a>
      char *s_tmp = env_cmd;
     4c6:	f7840793          	addi	a5,s0,-136
        s_tmp++;
     4ca:	0785                	addi	a5,a5,1
      while((*s_tmp = *d_tmp++))
     4cc:	0705                	addi	a4,a4,1
     4ce:	fff74683          	lbu	a3,-1(a4)
     4d2:	00d78023          	sb	a3,0(a5)
     4d6:	faf5                	bnez	a3,4ca <runcmd+0xa0>
      *s_tmp++ = '/';
     4d8:	00178713          	addi	a4,a5,1
     4dc:	01678023          	sb	s6,0(a5)
      d_tmp = ecmd->argv[0];
     4e0:	649c                	ld	a5,8(s1)
      while((*s_tmp++ = *d_tmp++))
     4e2:	0785                	addi	a5,a5,1
     4e4:	0705                	addi	a4,a4,1
     4e6:	fff7c683          	lbu	a3,-1(a5)
     4ea:	fed70fa3          	sb	a3,-1(a4)
     4ee:	faf5                	bnez	a3,4e2 <runcmd+0xb8>
      exec(env_cmd, ecmd->argv);
     4f0:	85d2                	mv	a1,s4
     4f2:	f7840513          	addi	a0,s0,-136
     4f6:	00001097          	auipc	ra,0x1
     4fa:	e62080e7          	jalr	-414(ra) # 1358 <exec>
    for(i=0; i<nenv; i++)
     4fe:	2985                	addiw	s3,s3,1
     500:	08090913          	addi	s2,s2,128
     504:	000aa783          	lw	a5,0(s5)
     508:	faf9c9e3          	blt	s3,a5,4ba <runcmd+0x90>
    fprintf(2, "exec %s failed\n", ecmd->argv[0]);
     50c:	6490                	ld	a2,8(s1)
     50e:	00001597          	auipc	a1,0x1
     512:	3da58593          	addi	a1,a1,986 # 18e8 <malloc+0x180>
     516:	4509                	li	a0,2
     518:	00001097          	auipc	ra,0x1
     51c:	16a080e7          	jalr	362(ra) # 1682 <fprintf>
  exit(0);
     520:	4501                	li	a0,0
     522:	00001097          	auipc	ra,0x1
     526:	dfe080e7          	jalr	-514(ra) # 1320 <exit>
      exit(1);
     52a:	4505                	li	a0,1
     52c:	00001097          	auipc	ra,0x1
     530:	df4080e7          	jalr	-524(ra) # 1320 <exit>
      char *s_tmp = env_cmd;
     534:	f7840793          	addi	a5,s0,-136
     538:	b745                	j	4d8 <runcmd+0xae>
    close(rcmd->fd);
     53a:	5148                	lw	a0,36(a0)
     53c:	00001097          	auipc	ra,0x1
     540:	e0c080e7          	jalr	-500(ra) # 1348 <close>
    if(open(rcmd->file, rcmd->mode) < 0){
     544:	508c                	lw	a1,32(s1)
     546:	6888                	ld	a0,16(s1)
     548:	00001097          	auipc	ra,0x1
     54c:	e18080e7          	jalr	-488(ra) # 1360 <open>
     550:	00054763          	bltz	a0,55e <runcmd+0x134>
    runcmd(rcmd->cmd);
     554:	6488                	ld	a0,8(s1)
     556:	00000097          	auipc	ra,0x0
     55a:	ed4080e7          	jalr	-300(ra) # 42a <runcmd>
      fprintf(2, "open %s failed\n", rcmd->file);
     55e:	6890                	ld	a2,16(s1)
     560:	00001597          	auipc	a1,0x1
     564:	39858593          	addi	a1,a1,920 # 18f8 <malloc+0x190>
     568:	4509                	li	a0,2
     56a:	00001097          	auipc	ra,0x1
     56e:	118080e7          	jalr	280(ra) # 1682 <fprintf>
      exit(1);
     572:	4505                	li	a0,1
     574:	00001097          	auipc	ra,0x1
     578:	dac080e7          	jalr	-596(ra) # 1320 <exit>
    if(fork1() == 0)
     57c:	00000097          	auipc	ra,0x0
     580:	e80080e7          	jalr	-384(ra) # 3fc <fork1>
     584:	c919                	beqz	a0,59a <runcmd+0x170>
    wait(0);
     586:	4501                	li	a0,0
     588:	00001097          	auipc	ra,0x1
     58c:	da0080e7          	jalr	-608(ra) # 1328 <wait>
    runcmd(lcmd->right);
     590:	6888                	ld	a0,16(s1)
     592:	00000097          	auipc	ra,0x0
     596:	e98080e7          	jalr	-360(ra) # 42a <runcmd>
      runcmd(lcmd->left);
     59a:	6488                	ld	a0,8(s1)
     59c:	00000097          	auipc	ra,0x0
     5a0:	e8e080e7          	jalr	-370(ra) # 42a <runcmd>
    if(pipe(p) < 0)
     5a4:	fb840513          	addi	a0,s0,-72
     5a8:	00001097          	auipc	ra,0x1
     5ac:	d88080e7          	jalr	-632(ra) # 1330 <pipe>
     5b0:	04054363          	bltz	a0,5f6 <runcmd+0x1cc>
    if(fork1() == 0){
     5b4:	00000097          	auipc	ra,0x0
     5b8:	e48080e7          	jalr	-440(ra) # 3fc <fork1>
     5bc:	c529                	beqz	a0,606 <runcmd+0x1dc>
    if(fork1() == 0){
     5be:	00000097          	auipc	ra,0x0
     5c2:	e3e080e7          	jalr	-450(ra) # 3fc <fork1>
     5c6:	cd25                	beqz	a0,63e <runcmd+0x214>
    close(p[0]);
     5c8:	fb842503          	lw	a0,-72(s0)
     5cc:	00001097          	auipc	ra,0x1
     5d0:	d7c080e7          	jalr	-644(ra) # 1348 <close>
    close(p[1]);
     5d4:	fbc42503          	lw	a0,-68(s0)
     5d8:	00001097          	auipc	ra,0x1
     5dc:	d70080e7          	jalr	-656(ra) # 1348 <close>
    wait(0);
     5e0:	4501                	li	a0,0
     5e2:	00001097          	auipc	ra,0x1
     5e6:	d46080e7          	jalr	-698(ra) # 1328 <wait>
    wait(0);
     5ea:	4501                	li	a0,0
     5ec:	00001097          	auipc	ra,0x1
     5f0:	d3c080e7          	jalr	-708(ra) # 1328 <wait>
    break;
     5f4:	b735                	j	520 <runcmd+0xf6>
      panic("pipe");
     5f6:	00001517          	auipc	a0,0x1
     5fa:	31250513          	addi	a0,a0,786 # 1908 <malloc+0x1a0>
     5fe:	00000097          	auipc	ra,0x0
     602:	dd8080e7          	jalr	-552(ra) # 3d6 <panic>
      close(1);
     606:	4505                	li	a0,1
     608:	00001097          	auipc	ra,0x1
     60c:	d40080e7          	jalr	-704(ra) # 1348 <close>
      dup(p[1]);
     610:	fbc42503          	lw	a0,-68(s0)
     614:	00001097          	auipc	ra,0x1
     618:	d6c080e7          	jalr	-660(ra) # 1380 <dup>
      close(p[0]);
     61c:	fb842503          	lw	a0,-72(s0)
     620:	00001097          	auipc	ra,0x1
     624:	d28080e7          	jalr	-728(ra) # 1348 <close>
      close(p[1]);
     628:	fbc42503          	lw	a0,-68(s0)
     62c:	00001097          	auipc	ra,0x1
     630:	d1c080e7          	jalr	-740(ra) # 1348 <close>
      runcmd(pcmd->left);
     634:	6488                	ld	a0,8(s1)
     636:	00000097          	auipc	ra,0x0
     63a:	df4080e7          	jalr	-524(ra) # 42a <runcmd>
      close(0);
     63e:	00001097          	auipc	ra,0x1
     642:	d0a080e7          	jalr	-758(ra) # 1348 <close>
      dup(p[0]);
     646:	fb842503          	lw	a0,-72(s0)
     64a:	00001097          	auipc	ra,0x1
     64e:	d36080e7          	jalr	-714(ra) # 1380 <dup>
      close(p[0]);
     652:	fb842503          	lw	a0,-72(s0)
     656:	00001097          	auipc	ra,0x1
     65a:	cf2080e7          	jalr	-782(ra) # 1348 <close>
      close(p[1]);
     65e:	fbc42503          	lw	a0,-68(s0)
     662:	00001097          	auipc	ra,0x1
     666:	ce6080e7          	jalr	-794(ra) # 1348 <close>
      runcmd(pcmd->right);
     66a:	6888                	ld	a0,16(s1)
     66c:	00000097          	auipc	ra,0x0
     670:	dbe080e7          	jalr	-578(ra) # 42a <runcmd>
    if(fork1() == 0)
     674:	00000097          	auipc	ra,0x0
     678:	d88080e7          	jalr	-632(ra) # 3fc <fork1>
     67c:	ea0512e3          	bnez	a0,520 <runcmd+0xf6>
      runcmd(bcmd->cmd);
     680:	6488                	ld	a0,8(s1)
     682:	00000097          	auipc	ra,0x0
     686:	da8080e7          	jalr	-600(ra) # 42a <runcmd>

000000000000068a <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     68a:	1101                	addi	sp,sp,-32
     68c:	ec06                	sd	ra,24(sp)
     68e:	e822                	sd	s0,16(sp)
     690:	e426                	sd	s1,8(sp)
     692:	1000                	addi	s0,sp,32
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     694:	0a800513          	li	a0,168
     698:	00001097          	auipc	ra,0x1
     69c:	0d0080e7          	jalr	208(ra) # 1768 <malloc>
     6a0:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     6a2:	0a800613          	li	a2,168
     6a6:	4581                	li	a1,0
     6a8:	00001097          	auipc	ra,0x1
     6ac:	a66080e7          	jalr	-1434(ra) # 110e <memset>
  cmd->type = EXEC;
     6b0:	4785                	li	a5,1
     6b2:	c09c                	sw	a5,0(s1)
  return (struct cmd*)cmd;
}
     6b4:	8526                	mv	a0,s1
     6b6:	60e2                	ld	ra,24(sp)
     6b8:	6442                	ld	s0,16(sp)
     6ba:	64a2                	ld	s1,8(sp)
     6bc:	6105                	addi	sp,sp,32
     6be:	8082                	ret

00000000000006c0 <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     6c0:	7139                	addi	sp,sp,-64
     6c2:	fc06                	sd	ra,56(sp)
     6c4:	f822                	sd	s0,48(sp)
     6c6:	f426                	sd	s1,40(sp)
     6c8:	f04a                	sd	s2,32(sp)
     6ca:	ec4e                	sd	s3,24(sp)
     6cc:	e852                	sd	s4,16(sp)
     6ce:	e456                	sd	s5,8(sp)
     6d0:	e05a                	sd	s6,0(sp)
     6d2:	0080                	addi	s0,sp,64
     6d4:	8b2a                	mv	s6,a0
     6d6:	8aae                	mv	s5,a1
     6d8:	8a32                	mv	s4,a2
     6da:	89b6                	mv	s3,a3
     6dc:	893a                	mv	s2,a4
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     6de:	02800513          	li	a0,40
     6e2:	00001097          	auipc	ra,0x1
     6e6:	086080e7          	jalr	134(ra) # 1768 <malloc>
     6ea:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     6ec:	02800613          	li	a2,40
     6f0:	4581                	li	a1,0
     6f2:	00001097          	auipc	ra,0x1
     6f6:	a1c080e7          	jalr	-1508(ra) # 110e <memset>
  cmd->type = REDIR;
     6fa:	4789                	li	a5,2
     6fc:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     6fe:	0164b423          	sd	s6,8(s1)
  cmd->file = file;
     702:	0154b823          	sd	s5,16(s1)
  cmd->efile = efile;
     706:	0144bc23          	sd	s4,24(s1)
  cmd->mode = mode;
     70a:	0334a023          	sw	s3,32(s1)
  cmd->fd = fd;
     70e:	0324a223          	sw	s2,36(s1)
  return (struct cmd*)cmd;
}
     712:	8526                	mv	a0,s1
     714:	70e2                	ld	ra,56(sp)
     716:	7442                	ld	s0,48(sp)
     718:	74a2                	ld	s1,40(sp)
     71a:	7902                	ld	s2,32(sp)
     71c:	69e2                	ld	s3,24(sp)
     71e:	6a42                	ld	s4,16(sp)
     720:	6aa2                	ld	s5,8(sp)
     722:	6b02                	ld	s6,0(sp)
     724:	6121                	addi	sp,sp,64
     726:	8082                	ret

0000000000000728 <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     728:	7179                	addi	sp,sp,-48
     72a:	f406                	sd	ra,40(sp)
     72c:	f022                	sd	s0,32(sp)
     72e:	ec26                	sd	s1,24(sp)
     730:	e84a                	sd	s2,16(sp)
     732:	e44e                	sd	s3,8(sp)
     734:	1800                	addi	s0,sp,48
     736:	89aa                	mv	s3,a0
     738:	892e                	mv	s2,a1
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     73a:	4561                	li	a0,24
     73c:	00001097          	auipc	ra,0x1
     740:	02c080e7          	jalr	44(ra) # 1768 <malloc>
     744:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     746:	4661                	li	a2,24
     748:	4581                	li	a1,0
     74a:	00001097          	auipc	ra,0x1
     74e:	9c4080e7          	jalr	-1596(ra) # 110e <memset>
  cmd->type = PIPE;
     752:	478d                	li	a5,3
     754:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     756:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     75a:	0124b823          	sd	s2,16(s1)
  return (struct cmd*)cmd;
}
     75e:	8526                	mv	a0,s1
     760:	70a2                	ld	ra,40(sp)
     762:	7402                	ld	s0,32(sp)
     764:	64e2                	ld	s1,24(sp)
     766:	6942                	ld	s2,16(sp)
     768:	69a2                	ld	s3,8(sp)
     76a:	6145                	addi	sp,sp,48
     76c:	8082                	ret

000000000000076e <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     76e:	7179                	addi	sp,sp,-48
     770:	f406                	sd	ra,40(sp)
     772:	f022                	sd	s0,32(sp)
     774:	ec26                	sd	s1,24(sp)
     776:	e84a                	sd	s2,16(sp)
     778:	e44e                	sd	s3,8(sp)
     77a:	1800                	addi	s0,sp,48
     77c:	89aa                	mv	s3,a0
     77e:	892e                	mv	s2,a1
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     780:	4561                	li	a0,24
     782:	00001097          	auipc	ra,0x1
     786:	fe6080e7          	jalr	-26(ra) # 1768 <malloc>
     78a:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     78c:	4661                	li	a2,24
     78e:	4581                	li	a1,0
     790:	00001097          	auipc	ra,0x1
     794:	97e080e7          	jalr	-1666(ra) # 110e <memset>
  cmd->type = LIST;
     798:	4791                	li	a5,4
     79a:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     79c:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     7a0:	0124b823          	sd	s2,16(s1)
  return (struct cmd*)cmd;
}
     7a4:	8526                	mv	a0,s1
     7a6:	70a2                	ld	ra,40(sp)
     7a8:	7402                	ld	s0,32(sp)
     7aa:	64e2                	ld	s1,24(sp)
     7ac:	6942                	ld	s2,16(sp)
     7ae:	69a2                	ld	s3,8(sp)
     7b0:	6145                	addi	sp,sp,48
     7b2:	8082                	ret

00000000000007b4 <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     7b4:	1101                	addi	sp,sp,-32
     7b6:	ec06                	sd	ra,24(sp)
     7b8:	e822                	sd	s0,16(sp)
     7ba:	e426                	sd	s1,8(sp)
     7bc:	e04a                	sd	s2,0(sp)
     7be:	1000                	addi	s0,sp,32
     7c0:	892a                	mv	s2,a0
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     7c2:	4541                	li	a0,16
     7c4:	00001097          	auipc	ra,0x1
     7c8:	fa4080e7          	jalr	-92(ra) # 1768 <malloc>
     7cc:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     7ce:	4641                	li	a2,16
     7d0:	4581                	li	a1,0
     7d2:	00001097          	auipc	ra,0x1
     7d6:	93c080e7          	jalr	-1732(ra) # 110e <memset>
  cmd->type = BACK;
     7da:	4795                	li	a5,5
     7dc:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     7de:	0124b423          	sd	s2,8(s1)
  return (struct cmd*)cmd;
}
     7e2:	8526                	mv	a0,s1
     7e4:	60e2                	ld	ra,24(sp)
     7e6:	6442                	ld	s0,16(sp)
     7e8:	64a2                	ld	s1,8(sp)
     7ea:	6902                	ld	s2,0(sp)
     7ec:	6105                	addi	sp,sp,32
     7ee:	8082                	ret

00000000000007f0 <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     7f0:	7139                	addi	sp,sp,-64
     7f2:	fc06                	sd	ra,56(sp)
     7f4:	f822                	sd	s0,48(sp)
     7f6:	f426                	sd	s1,40(sp)
     7f8:	f04a                	sd	s2,32(sp)
     7fa:	ec4e                	sd	s3,24(sp)
     7fc:	e852                	sd	s4,16(sp)
     7fe:	e456                	sd	s5,8(sp)
     800:	e05a                	sd	s6,0(sp)
     802:	0080                	addi	s0,sp,64
     804:	8a2a                	mv	s4,a0
     806:	892e                	mv	s2,a1
     808:	8ab2                	mv	s5,a2
     80a:	8b36                	mv	s6,a3
  char *s;
  int ret;

  s = *ps;
     80c:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     80e:	00001997          	auipc	s3,0x1
     812:	2ba98993          	addi	s3,s3,698 # 1ac8 <whitespace>
     816:	00b4fe63          	bgeu	s1,a1,832 <gettoken+0x42>
     81a:	0004c583          	lbu	a1,0(s1)
     81e:	854e                	mv	a0,s3
     820:	00001097          	auipc	ra,0x1
     824:	910080e7          	jalr	-1776(ra) # 1130 <strchr>
     828:	c509                	beqz	a0,832 <gettoken+0x42>
    s++;
     82a:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     82c:	fe9917e3          	bne	s2,s1,81a <gettoken+0x2a>
     830:	84ca                	mv	s1,s2
  if(q)
     832:	000a8463          	beqz	s5,83a <gettoken+0x4a>
    *q = s;
     836:	009ab023          	sd	s1,0(s5)
  ret = *s;
     83a:	0004c783          	lbu	a5,0(s1)
     83e:	00078a9b          	sext.w	s5,a5
  switch(*s){
     842:	03c00713          	li	a4,60
     846:	06f76663          	bltu	a4,a5,8b2 <gettoken+0xc2>
     84a:	03a00713          	li	a4,58
     84e:	00f76e63          	bltu	a4,a5,86a <gettoken+0x7a>
     852:	cf89                	beqz	a5,86c <gettoken+0x7c>
     854:	02600713          	li	a4,38
     858:	00e78963          	beq	a5,a4,86a <gettoken+0x7a>
     85c:	fd87879b          	addiw	a5,a5,-40
     860:	0ff7f793          	zext.b	a5,a5
     864:	4705                	li	a4,1
     866:	06f76d63          	bltu	a4,a5,8e0 <gettoken+0xf0>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     86a:	0485                	addi	s1,s1,1
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
  }
  if(eq)
     86c:	000b0463          	beqz	s6,874 <gettoken+0x84>
    *eq = s;
     870:	009b3023          	sd	s1,0(s6)

  while(s < es && strchr(whitespace, *s))
     874:	00001997          	auipc	s3,0x1
     878:	25498993          	addi	s3,s3,596 # 1ac8 <whitespace>
     87c:	0124fe63          	bgeu	s1,s2,898 <gettoken+0xa8>
     880:	0004c583          	lbu	a1,0(s1)
     884:	854e                	mv	a0,s3
     886:	00001097          	auipc	ra,0x1
     88a:	8aa080e7          	jalr	-1878(ra) # 1130 <strchr>
     88e:	c509                	beqz	a0,898 <gettoken+0xa8>
    s++;
     890:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     892:	fe9917e3          	bne	s2,s1,880 <gettoken+0x90>
     896:	84ca                	mv	s1,s2
  *ps = s;
     898:	009a3023          	sd	s1,0(s4)
  return ret;
}
     89c:	8556                	mv	a0,s5
     89e:	70e2                	ld	ra,56(sp)
     8a0:	7442                	ld	s0,48(sp)
     8a2:	74a2                	ld	s1,40(sp)
     8a4:	7902                	ld	s2,32(sp)
     8a6:	69e2                	ld	s3,24(sp)
     8a8:	6a42                	ld	s4,16(sp)
     8aa:	6aa2                	ld	s5,8(sp)
     8ac:	6b02                	ld	s6,0(sp)
     8ae:	6121                	addi	sp,sp,64
     8b0:	8082                	ret
  switch(*s){
     8b2:	03e00713          	li	a4,62
     8b6:	02e79163          	bne	a5,a4,8d8 <gettoken+0xe8>
    s++;
     8ba:	00148693          	addi	a3,s1,1
    if(*s == '>'){
     8be:	0014c703          	lbu	a4,1(s1)
     8c2:	03e00793          	li	a5,62
      s++;
     8c6:	0489                	addi	s1,s1,2
      ret = '+';
     8c8:	02b00a93          	li	s5,43
    if(*s == '>'){
     8cc:	faf700e3          	beq	a4,a5,86c <gettoken+0x7c>
    s++;
     8d0:	84b6                	mv	s1,a3
  ret = *s;
     8d2:	03e00a93          	li	s5,62
     8d6:	bf59                	j	86c <gettoken+0x7c>
  switch(*s){
     8d8:	07c00713          	li	a4,124
     8dc:	f8e787e3          	beq	a5,a4,86a <gettoken+0x7a>
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     8e0:	00001997          	auipc	s3,0x1
     8e4:	1e898993          	addi	s3,s3,488 # 1ac8 <whitespace>
     8e8:	00001a97          	auipc	s5,0x1
     8ec:	1d8a8a93          	addi	s5,s5,472 # 1ac0 <symbols>
     8f0:	0524f163          	bgeu	s1,s2,932 <gettoken+0x142>
     8f4:	0004c583          	lbu	a1,0(s1)
     8f8:	854e                	mv	a0,s3
     8fa:	00001097          	auipc	ra,0x1
     8fe:	836080e7          	jalr	-1994(ra) # 1130 <strchr>
     902:	e50d                	bnez	a0,92c <gettoken+0x13c>
     904:	0004c583          	lbu	a1,0(s1)
     908:	8556                	mv	a0,s5
     90a:	00001097          	auipc	ra,0x1
     90e:	826080e7          	jalr	-2010(ra) # 1130 <strchr>
     912:	e911                	bnez	a0,926 <gettoken+0x136>
      s++;
     914:	0485                	addi	s1,s1,1
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     916:	fc991fe3          	bne	s2,s1,8f4 <gettoken+0x104>
  if(eq)
     91a:	84ca                	mv	s1,s2
    ret = 'a';
     91c:	06100a93          	li	s5,97
  if(eq)
     920:	f40b18e3          	bnez	s6,870 <gettoken+0x80>
     924:	bf95                	j	898 <gettoken+0xa8>
    ret = 'a';
     926:	06100a93          	li	s5,97
     92a:	b789                	j	86c <gettoken+0x7c>
     92c:	06100a93          	li	s5,97
     930:	bf35                	j	86c <gettoken+0x7c>
     932:	06100a93          	li	s5,97
  if(eq)
     936:	f20b1de3          	bnez	s6,870 <gettoken+0x80>
     93a:	bfb9                	j	898 <gettoken+0xa8>

000000000000093c <peek>:

int
peek(char **ps, char *es, char *toks)
{
     93c:	7139                	addi	sp,sp,-64
     93e:	fc06                	sd	ra,56(sp)
     940:	f822                	sd	s0,48(sp)
     942:	f426                	sd	s1,40(sp)
     944:	f04a                	sd	s2,32(sp)
     946:	ec4e                	sd	s3,24(sp)
     948:	e852                	sd	s4,16(sp)
     94a:	e456                	sd	s5,8(sp)
     94c:	0080                	addi	s0,sp,64
     94e:	8a2a                	mv	s4,a0
     950:	892e                	mv	s2,a1
     952:	8ab2                	mv	s5,a2
  char *s;

  s = *ps;
     954:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     956:	00001997          	auipc	s3,0x1
     95a:	17298993          	addi	s3,s3,370 # 1ac8 <whitespace>
     95e:	00b4fe63          	bgeu	s1,a1,97a <peek+0x3e>
     962:	0004c583          	lbu	a1,0(s1)
     966:	854e                	mv	a0,s3
     968:	00000097          	auipc	ra,0x0
     96c:	7c8080e7          	jalr	1992(ra) # 1130 <strchr>
     970:	c509                	beqz	a0,97a <peek+0x3e>
    s++;
     972:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     974:	fe9917e3          	bne	s2,s1,962 <peek+0x26>
     978:	84ca                	mv	s1,s2
  *ps = s;
     97a:	009a3023          	sd	s1,0(s4)
  return *s && strchr(toks, *s);
     97e:	0004c583          	lbu	a1,0(s1)
     982:	4501                	li	a0,0
     984:	e991                	bnez	a1,998 <peek+0x5c>
}
     986:	70e2                	ld	ra,56(sp)
     988:	7442                	ld	s0,48(sp)
     98a:	74a2                	ld	s1,40(sp)
     98c:	7902                	ld	s2,32(sp)
     98e:	69e2                	ld	s3,24(sp)
     990:	6a42                	ld	s4,16(sp)
     992:	6aa2                	ld	s5,8(sp)
     994:	6121                	addi	sp,sp,64
     996:	8082                	ret
  return *s && strchr(toks, *s);
     998:	8556                	mv	a0,s5
     99a:	00000097          	auipc	ra,0x0
     99e:	796080e7          	jalr	1942(ra) # 1130 <strchr>
     9a2:	00a03533          	snez	a0,a0
     9a6:	b7c5                	j	986 <peek+0x4a>

00000000000009a8 <parseredirs>:
  return cmd;
}

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     9a8:	711d                	addi	sp,sp,-96
     9aa:	ec86                	sd	ra,88(sp)
     9ac:	e8a2                	sd	s0,80(sp)
     9ae:	e4a6                	sd	s1,72(sp)
     9b0:	e0ca                	sd	s2,64(sp)
     9b2:	fc4e                	sd	s3,56(sp)
     9b4:	f852                	sd	s4,48(sp)
     9b6:	f456                	sd	s5,40(sp)
     9b8:	f05a                	sd	s6,32(sp)
     9ba:	ec5e                	sd	s7,24(sp)
     9bc:	1080                	addi	s0,sp,96
     9be:	8a2a                	mv	s4,a0
     9c0:	89ae                	mv	s3,a1
     9c2:	8932                	mv	s2,a2
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     9c4:	00001a97          	auipc	s5,0x1
     9c8:	f6ca8a93          	addi	s5,s5,-148 # 1930 <malloc+0x1c8>
    tok = gettoken(ps, es, 0, 0);
    if(gettoken(ps, es, &q, &eq) != 'a')
     9cc:	06100b13          	li	s6,97
      panic("missing file for redirection");
    switch(tok){
     9d0:	03c00b93          	li	s7,60
  while(peek(ps, es, "<>")){
     9d4:	a02d                	j	9fe <parseredirs+0x56>
      panic("missing file for redirection");
     9d6:	00001517          	auipc	a0,0x1
     9da:	f3a50513          	addi	a0,a0,-198 # 1910 <malloc+0x1a8>
     9de:	00000097          	auipc	ra,0x0
     9e2:	9f8080e7          	jalr	-1544(ra) # 3d6 <panic>
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     9e6:	4701                	li	a4,0
     9e8:	4681                	li	a3,0
     9ea:	fa043603          	ld	a2,-96(s0)
     9ee:	fa843583          	ld	a1,-88(s0)
     9f2:	8552                	mv	a0,s4
     9f4:	00000097          	auipc	ra,0x0
     9f8:	ccc080e7          	jalr	-820(ra) # 6c0 <redircmd>
     9fc:	8a2a                	mv	s4,a0
  while(peek(ps, es, "<>")){
     9fe:	8656                	mv	a2,s5
     a00:	85ca                	mv	a1,s2
     a02:	854e                	mv	a0,s3
     a04:	00000097          	auipc	ra,0x0
     a08:	f38080e7          	jalr	-200(ra) # 93c <peek>
     a0c:	cd25                	beqz	a0,a84 <parseredirs+0xdc>
    tok = gettoken(ps, es, 0, 0);
     a0e:	4681                	li	a3,0
     a10:	4601                	li	a2,0
     a12:	85ca                	mv	a1,s2
     a14:	854e                	mv	a0,s3
     a16:	00000097          	auipc	ra,0x0
     a1a:	dda080e7          	jalr	-550(ra) # 7f0 <gettoken>
     a1e:	84aa                	mv	s1,a0
    if(gettoken(ps, es, &q, &eq) != 'a')
     a20:	fa040693          	addi	a3,s0,-96
     a24:	fa840613          	addi	a2,s0,-88
     a28:	85ca                	mv	a1,s2
     a2a:	854e                	mv	a0,s3
     a2c:	00000097          	auipc	ra,0x0
     a30:	dc4080e7          	jalr	-572(ra) # 7f0 <gettoken>
     a34:	fb6511e3          	bne	a0,s6,9d6 <parseredirs+0x2e>
    switch(tok){
     a38:	fb7487e3          	beq	s1,s7,9e6 <parseredirs+0x3e>
     a3c:	03e00793          	li	a5,62
     a40:	02f48463          	beq	s1,a5,a68 <parseredirs+0xc0>
     a44:	02b00793          	li	a5,43
     a48:	faf49be3          	bne	s1,a5,9fe <parseredirs+0x56>
      break;
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
      break;
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_APPEND, 1);
     a4c:	4705                	li	a4,1
     a4e:	20500693          	li	a3,517
     a52:	fa043603          	ld	a2,-96(s0)
     a56:	fa843583          	ld	a1,-88(s0)
     a5a:	8552                	mv	a0,s4
     a5c:	00000097          	auipc	ra,0x0
     a60:	c64080e7          	jalr	-924(ra) # 6c0 <redircmd>
     a64:	8a2a                	mv	s4,a0
      break;
     a66:	bf61                	j	9fe <parseredirs+0x56>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
     a68:	4705                	li	a4,1
     a6a:	60100693          	li	a3,1537
     a6e:	fa043603          	ld	a2,-96(s0)
     a72:	fa843583          	ld	a1,-88(s0)
     a76:	8552                	mv	a0,s4
     a78:	00000097          	auipc	ra,0x0
     a7c:	c48080e7          	jalr	-952(ra) # 6c0 <redircmd>
     a80:	8a2a                	mv	s4,a0
      break;
     a82:	bfb5                	j	9fe <parseredirs+0x56>
    }
  }
  return cmd;
}
     a84:	8552                	mv	a0,s4
     a86:	60e6                	ld	ra,88(sp)
     a88:	6446                	ld	s0,80(sp)
     a8a:	64a6                	ld	s1,72(sp)
     a8c:	6906                	ld	s2,64(sp)
     a8e:	79e2                	ld	s3,56(sp)
     a90:	7a42                	ld	s4,48(sp)
     a92:	7aa2                	ld	s5,40(sp)
     a94:	7b02                	ld	s6,32(sp)
     a96:	6be2                	ld	s7,24(sp)
     a98:	6125                	addi	sp,sp,96
     a9a:	8082                	ret

0000000000000a9c <parseexec>:
  return cmd;
}

struct cmd*
parseexec(char **ps, char *es)
{
     a9c:	7159                	addi	sp,sp,-112
     a9e:	f486                	sd	ra,104(sp)
     aa0:	f0a2                	sd	s0,96(sp)
     aa2:	eca6                	sd	s1,88(sp)
     aa4:	e0d2                	sd	s4,64(sp)
     aa6:	fc56                	sd	s5,56(sp)
     aa8:	1880                	addi	s0,sp,112
     aaa:	8a2a                	mv	s4,a0
     aac:	8aae                	mv	s5,a1
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;

  if(peek(ps, es, "("))
     aae:	00001617          	auipc	a2,0x1
     ab2:	e8a60613          	addi	a2,a2,-374 # 1938 <malloc+0x1d0>
     ab6:	00000097          	auipc	ra,0x0
     aba:	e86080e7          	jalr	-378(ra) # 93c <peek>
     abe:	ed15                	bnez	a0,afa <parseexec+0x5e>
     ac0:	e8ca                	sd	s2,80(sp)
     ac2:	e4ce                	sd	s3,72(sp)
     ac4:	f85a                	sd	s6,48(sp)
     ac6:	f45e                	sd	s7,40(sp)
     ac8:	f062                	sd	s8,32(sp)
     aca:	ec66                	sd	s9,24(sp)
     acc:	89aa                	mv	s3,a0
    return parseblock(ps, es);

  ret = execcmd();
     ace:	00000097          	auipc	ra,0x0
     ad2:	bbc080e7          	jalr	-1092(ra) # 68a <execcmd>
     ad6:	8c2a                	mv	s8,a0
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
     ad8:	8656                	mv	a2,s5
     ada:	85d2                	mv	a1,s4
     adc:	00000097          	auipc	ra,0x0
     ae0:	ecc080e7          	jalr	-308(ra) # 9a8 <parseredirs>
     ae4:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     ae6:	008c0913          	addi	s2,s8,8
     aea:	00001b17          	auipc	s6,0x1
     aee:	e6eb0b13          	addi	s6,s6,-402 # 1958 <malloc+0x1f0>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
      break;
    if(tok != 'a')
     af2:	06100c93          	li	s9,97
      panic("syntax");
    cmd->argv[argc] = q;
    cmd->eargv[argc] = eq;
    argc++;
    if(argc >= MAXARGS)
     af6:	4ba9                	li	s7,10
  while(!peek(ps, es, "|)&;")){
     af8:	a081                	j	b38 <parseexec+0x9c>
    return parseblock(ps, es);
     afa:	85d6                	mv	a1,s5
     afc:	8552                	mv	a0,s4
     afe:	00000097          	auipc	ra,0x0
     b02:	1bc080e7          	jalr	444(ra) # cba <parseblock>
     b06:	84aa                	mv	s1,a0
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
  cmd->eargv[argc] = 0;
  return ret;
}
     b08:	8526                	mv	a0,s1
     b0a:	70a6                	ld	ra,104(sp)
     b0c:	7406                	ld	s0,96(sp)
     b0e:	64e6                	ld	s1,88(sp)
     b10:	6a06                	ld	s4,64(sp)
     b12:	7ae2                	ld	s5,56(sp)
     b14:	6165                	addi	sp,sp,112
     b16:	8082                	ret
      panic("syntax");
     b18:	00001517          	auipc	a0,0x1
     b1c:	e2850513          	addi	a0,a0,-472 # 1940 <malloc+0x1d8>
     b20:	00000097          	auipc	ra,0x0
     b24:	8b6080e7          	jalr	-1866(ra) # 3d6 <panic>
    ret = parseredirs(ret, ps, es);
     b28:	8656                	mv	a2,s5
     b2a:	85d2                	mv	a1,s4
     b2c:	8526                	mv	a0,s1
     b2e:	00000097          	auipc	ra,0x0
     b32:	e7a080e7          	jalr	-390(ra) # 9a8 <parseredirs>
     b36:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     b38:	865a                	mv	a2,s6
     b3a:	85d6                	mv	a1,s5
     b3c:	8552                	mv	a0,s4
     b3e:	00000097          	auipc	ra,0x0
     b42:	dfe080e7          	jalr	-514(ra) # 93c <peek>
     b46:	e131                	bnez	a0,b8a <parseexec+0xee>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     b48:	f9040693          	addi	a3,s0,-112
     b4c:	f9840613          	addi	a2,s0,-104
     b50:	85d6                	mv	a1,s5
     b52:	8552                	mv	a0,s4
     b54:	00000097          	auipc	ra,0x0
     b58:	c9c080e7          	jalr	-868(ra) # 7f0 <gettoken>
     b5c:	c51d                	beqz	a0,b8a <parseexec+0xee>
    if(tok != 'a')
     b5e:	fb951de3          	bne	a0,s9,b18 <parseexec+0x7c>
    cmd->argv[argc] = q;
     b62:	f9843783          	ld	a5,-104(s0)
     b66:	00f93023          	sd	a5,0(s2)
    cmd->eargv[argc] = eq;
     b6a:	f9043783          	ld	a5,-112(s0)
     b6e:	04f93823          	sd	a5,80(s2)
    argc++;
     b72:	2985                	addiw	s3,s3,1
    if(argc >= MAXARGS)
     b74:	0921                	addi	s2,s2,8
     b76:	fb7999e3          	bne	s3,s7,b28 <parseexec+0x8c>
      panic("too many args");
     b7a:	00001517          	auipc	a0,0x1
     b7e:	dce50513          	addi	a0,a0,-562 # 1948 <malloc+0x1e0>
     b82:	00000097          	auipc	ra,0x0
     b86:	854080e7          	jalr	-1964(ra) # 3d6 <panic>
  cmd->argv[argc] = 0;
     b8a:	098e                	slli	s3,s3,0x3
     b8c:	9c4e                	add	s8,s8,s3
     b8e:	000c3423          	sd	zero,8(s8)
  cmd->eargv[argc] = 0;
     b92:	040c3c23          	sd	zero,88(s8)
     b96:	6946                	ld	s2,80(sp)
     b98:	69a6                	ld	s3,72(sp)
     b9a:	7b42                	ld	s6,48(sp)
     b9c:	7ba2                	ld	s7,40(sp)
     b9e:	7c02                	ld	s8,32(sp)
     ba0:	6ce2                	ld	s9,24(sp)
  return ret;
     ba2:	b79d                	j	b08 <parseexec+0x6c>

0000000000000ba4 <parsepipe>:
{
     ba4:	7179                	addi	sp,sp,-48
     ba6:	f406                	sd	ra,40(sp)
     ba8:	f022                	sd	s0,32(sp)
     baa:	ec26                	sd	s1,24(sp)
     bac:	e84a                	sd	s2,16(sp)
     bae:	e44e                	sd	s3,8(sp)
     bb0:	1800                	addi	s0,sp,48
     bb2:	892a                	mv	s2,a0
     bb4:	89ae                	mv	s3,a1
  cmd = parseexec(ps, es);
     bb6:	00000097          	auipc	ra,0x0
     bba:	ee6080e7          	jalr	-282(ra) # a9c <parseexec>
     bbe:	84aa                	mv	s1,a0
  if(peek(ps, es, "|")){
     bc0:	00001617          	auipc	a2,0x1
     bc4:	da060613          	addi	a2,a2,-608 # 1960 <malloc+0x1f8>
     bc8:	85ce                	mv	a1,s3
     bca:	854a                	mv	a0,s2
     bcc:	00000097          	auipc	ra,0x0
     bd0:	d70080e7          	jalr	-656(ra) # 93c <peek>
     bd4:	e909                	bnez	a0,be6 <parsepipe+0x42>
}
     bd6:	8526                	mv	a0,s1
     bd8:	70a2                	ld	ra,40(sp)
     bda:	7402                	ld	s0,32(sp)
     bdc:	64e2                	ld	s1,24(sp)
     bde:	6942                	ld	s2,16(sp)
     be0:	69a2                	ld	s3,8(sp)
     be2:	6145                	addi	sp,sp,48
     be4:	8082                	ret
    gettoken(ps, es, 0, 0);
     be6:	4681                	li	a3,0
     be8:	4601                	li	a2,0
     bea:	85ce                	mv	a1,s3
     bec:	854a                	mv	a0,s2
     bee:	00000097          	auipc	ra,0x0
     bf2:	c02080e7          	jalr	-1022(ra) # 7f0 <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     bf6:	85ce                	mv	a1,s3
     bf8:	854a                	mv	a0,s2
     bfa:	00000097          	auipc	ra,0x0
     bfe:	faa080e7          	jalr	-86(ra) # ba4 <parsepipe>
     c02:	85aa                	mv	a1,a0
     c04:	8526                	mv	a0,s1
     c06:	00000097          	auipc	ra,0x0
     c0a:	b22080e7          	jalr	-1246(ra) # 728 <pipecmd>
     c0e:	84aa                	mv	s1,a0
  return cmd;
     c10:	b7d9                	j	bd6 <parsepipe+0x32>

0000000000000c12 <parseline>:
{
     c12:	7179                	addi	sp,sp,-48
     c14:	f406                	sd	ra,40(sp)
     c16:	f022                	sd	s0,32(sp)
     c18:	ec26                	sd	s1,24(sp)
     c1a:	e84a                	sd	s2,16(sp)
     c1c:	e44e                	sd	s3,8(sp)
     c1e:	e052                	sd	s4,0(sp)
     c20:	1800                	addi	s0,sp,48
     c22:	892a                	mv	s2,a0
     c24:	89ae                	mv	s3,a1
  cmd = parsepipe(ps, es);
     c26:	00000097          	auipc	ra,0x0
     c2a:	f7e080e7          	jalr	-130(ra) # ba4 <parsepipe>
     c2e:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     c30:	00001a17          	auipc	s4,0x1
     c34:	d38a0a13          	addi	s4,s4,-712 # 1968 <malloc+0x200>
     c38:	a839                	j	c56 <parseline+0x44>
    gettoken(ps, es, 0, 0);
     c3a:	4681                	li	a3,0
     c3c:	4601                	li	a2,0
     c3e:	85ce                	mv	a1,s3
     c40:	854a                	mv	a0,s2
     c42:	00000097          	auipc	ra,0x0
     c46:	bae080e7          	jalr	-1106(ra) # 7f0 <gettoken>
    cmd = backcmd(cmd);
     c4a:	8526                	mv	a0,s1
     c4c:	00000097          	auipc	ra,0x0
     c50:	b68080e7          	jalr	-1176(ra) # 7b4 <backcmd>
     c54:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     c56:	8652                	mv	a2,s4
     c58:	85ce                	mv	a1,s3
     c5a:	854a                	mv	a0,s2
     c5c:	00000097          	auipc	ra,0x0
     c60:	ce0080e7          	jalr	-800(ra) # 93c <peek>
     c64:	f979                	bnez	a0,c3a <parseline+0x28>
  if(peek(ps, es, ";")){
     c66:	00001617          	auipc	a2,0x1
     c6a:	d0a60613          	addi	a2,a2,-758 # 1970 <malloc+0x208>
     c6e:	85ce                	mv	a1,s3
     c70:	854a                	mv	a0,s2
     c72:	00000097          	auipc	ra,0x0
     c76:	cca080e7          	jalr	-822(ra) # 93c <peek>
     c7a:	e911                	bnez	a0,c8e <parseline+0x7c>
}
     c7c:	8526                	mv	a0,s1
     c7e:	70a2                	ld	ra,40(sp)
     c80:	7402                	ld	s0,32(sp)
     c82:	64e2                	ld	s1,24(sp)
     c84:	6942                	ld	s2,16(sp)
     c86:	69a2                	ld	s3,8(sp)
     c88:	6a02                	ld	s4,0(sp)
     c8a:	6145                	addi	sp,sp,48
     c8c:	8082                	ret
    gettoken(ps, es, 0, 0);
     c8e:	4681                	li	a3,0
     c90:	4601                	li	a2,0
     c92:	85ce                	mv	a1,s3
     c94:	854a                	mv	a0,s2
     c96:	00000097          	auipc	ra,0x0
     c9a:	b5a080e7          	jalr	-1190(ra) # 7f0 <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     c9e:	85ce                	mv	a1,s3
     ca0:	854a                	mv	a0,s2
     ca2:	00000097          	auipc	ra,0x0
     ca6:	f70080e7          	jalr	-144(ra) # c12 <parseline>
     caa:	85aa                	mv	a1,a0
     cac:	8526                	mv	a0,s1
     cae:	00000097          	auipc	ra,0x0
     cb2:	ac0080e7          	jalr	-1344(ra) # 76e <listcmd>
     cb6:	84aa                	mv	s1,a0
  return cmd;
     cb8:	b7d1                	j	c7c <parseline+0x6a>

0000000000000cba <parseblock>:
{
     cba:	7179                	addi	sp,sp,-48
     cbc:	f406                	sd	ra,40(sp)
     cbe:	f022                	sd	s0,32(sp)
     cc0:	ec26                	sd	s1,24(sp)
     cc2:	e84a                	sd	s2,16(sp)
     cc4:	e44e                	sd	s3,8(sp)
     cc6:	1800                	addi	s0,sp,48
     cc8:	84aa                	mv	s1,a0
     cca:	892e                	mv	s2,a1
  if(!peek(ps, es, "("))
     ccc:	00001617          	auipc	a2,0x1
     cd0:	c6c60613          	addi	a2,a2,-916 # 1938 <malloc+0x1d0>
     cd4:	00000097          	auipc	ra,0x0
     cd8:	c68080e7          	jalr	-920(ra) # 93c <peek>
     cdc:	c12d                	beqz	a0,d3e <parseblock+0x84>
  gettoken(ps, es, 0, 0);
     cde:	4681                	li	a3,0
     ce0:	4601                	li	a2,0
     ce2:	85ca                	mv	a1,s2
     ce4:	8526                	mv	a0,s1
     ce6:	00000097          	auipc	ra,0x0
     cea:	b0a080e7          	jalr	-1270(ra) # 7f0 <gettoken>
  cmd = parseline(ps, es);
     cee:	85ca                	mv	a1,s2
     cf0:	8526                	mv	a0,s1
     cf2:	00000097          	auipc	ra,0x0
     cf6:	f20080e7          	jalr	-224(ra) # c12 <parseline>
     cfa:	89aa                	mv	s3,a0
  if(!peek(ps, es, ")"))
     cfc:	00001617          	auipc	a2,0x1
     d00:	c8c60613          	addi	a2,a2,-884 # 1988 <malloc+0x220>
     d04:	85ca                	mv	a1,s2
     d06:	8526                	mv	a0,s1
     d08:	00000097          	auipc	ra,0x0
     d0c:	c34080e7          	jalr	-972(ra) # 93c <peek>
     d10:	cd1d                	beqz	a0,d4e <parseblock+0x94>
  gettoken(ps, es, 0, 0);
     d12:	4681                	li	a3,0
     d14:	4601                	li	a2,0
     d16:	85ca                	mv	a1,s2
     d18:	8526                	mv	a0,s1
     d1a:	00000097          	auipc	ra,0x0
     d1e:	ad6080e7          	jalr	-1322(ra) # 7f0 <gettoken>
  cmd = parseredirs(cmd, ps, es);
     d22:	864a                	mv	a2,s2
     d24:	85a6                	mv	a1,s1
     d26:	854e                	mv	a0,s3
     d28:	00000097          	auipc	ra,0x0
     d2c:	c80080e7          	jalr	-896(ra) # 9a8 <parseredirs>
}
     d30:	70a2                	ld	ra,40(sp)
     d32:	7402                	ld	s0,32(sp)
     d34:	64e2                	ld	s1,24(sp)
     d36:	6942                	ld	s2,16(sp)
     d38:	69a2                	ld	s3,8(sp)
     d3a:	6145                	addi	sp,sp,48
     d3c:	8082                	ret
    panic("parseblock");
     d3e:	00001517          	auipc	a0,0x1
     d42:	c3a50513          	addi	a0,a0,-966 # 1978 <malloc+0x210>
     d46:	fffff097          	auipc	ra,0xfffff
     d4a:	690080e7          	jalr	1680(ra) # 3d6 <panic>
    panic("syntax - missing )");
     d4e:	00001517          	auipc	a0,0x1
     d52:	c4250513          	addi	a0,a0,-958 # 1990 <malloc+0x228>
     d56:	fffff097          	auipc	ra,0xfffff
     d5a:	680080e7          	jalr	1664(ra) # 3d6 <panic>

0000000000000d5e <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     d5e:	1101                	addi	sp,sp,-32
     d60:	ec06                	sd	ra,24(sp)
     d62:	e822                	sd	s0,16(sp)
     d64:	e426                	sd	s1,8(sp)
     d66:	1000                	addi	s0,sp,32
     d68:	84aa                	mv	s1,a0
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     d6a:	c521                	beqz	a0,db2 <nulterminate+0x54>
    return 0;

  switch(cmd->type){
     d6c:	4118                	lw	a4,0(a0)
     d6e:	4795                	li	a5,5
     d70:	04e7e163          	bltu	a5,a4,db2 <nulterminate+0x54>
     d74:	00056783          	lwu	a5,0(a0)
     d78:	078a                	slli	a5,a5,0x2
     d7a:	00001717          	auipc	a4,0x1
     d7e:	cbe70713          	addi	a4,a4,-834 # 1a38 <malloc+0x2d0>
     d82:	97ba                	add	a5,a5,a4
     d84:	439c                	lw	a5,0(a5)
     d86:	97ba                	add	a5,a5,a4
     d88:	8782                	jr	a5
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     d8a:	651c                	ld	a5,8(a0)
     d8c:	c39d                	beqz	a5,db2 <nulterminate+0x54>
     d8e:	01050793          	addi	a5,a0,16
      *ecmd->eargv[i] = 0;
     d92:	67b8                	ld	a4,72(a5)
     d94:	00070023          	sb	zero,0(a4)
    for(i=0; ecmd->argv[i]; i++)
     d98:	07a1                	addi	a5,a5,8
     d9a:	ff87b703          	ld	a4,-8(a5)
     d9e:	fb75                	bnez	a4,d92 <nulterminate+0x34>
     da0:	a809                	j	db2 <nulterminate+0x54>
    break;

  case REDIR:
    rcmd = (struct redircmd*)cmd;
    nulterminate(rcmd->cmd);
     da2:	6508                	ld	a0,8(a0)
     da4:	00000097          	auipc	ra,0x0
     da8:	fba080e7          	jalr	-70(ra) # d5e <nulterminate>
    *rcmd->efile = 0;
     dac:	6c9c                	ld	a5,24(s1)
     dae:	00078023          	sb	zero,0(a5)
    bcmd = (struct backcmd*)cmd;
    nulterminate(bcmd->cmd);
    break;
  }
  return cmd;
     db2:	8526                	mv	a0,s1
     db4:	60e2                	ld	ra,24(sp)
     db6:	6442                	ld	s0,16(sp)
     db8:	64a2                	ld	s1,8(sp)
     dba:	6105                	addi	sp,sp,32
     dbc:	8082                	ret
    nulterminate(pcmd->left);
     dbe:	6508                	ld	a0,8(a0)
     dc0:	00000097          	auipc	ra,0x0
     dc4:	f9e080e7          	jalr	-98(ra) # d5e <nulterminate>
    nulterminate(pcmd->right);
     dc8:	6888                	ld	a0,16(s1)
     dca:	00000097          	auipc	ra,0x0
     dce:	f94080e7          	jalr	-108(ra) # d5e <nulterminate>
    break;
     dd2:	b7c5                	j	db2 <nulterminate+0x54>
    nulterminate(lcmd->left);
     dd4:	6508                	ld	a0,8(a0)
     dd6:	00000097          	auipc	ra,0x0
     dda:	f88080e7          	jalr	-120(ra) # d5e <nulterminate>
    nulterminate(lcmd->right);
     dde:	6888                	ld	a0,16(s1)
     de0:	00000097          	auipc	ra,0x0
     de4:	f7e080e7          	jalr	-130(ra) # d5e <nulterminate>
    break;
     de8:	b7e9                	j	db2 <nulterminate+0x54>
    nulterminate(bcmd->cmd);
     dea:	6508                	ld	a0,8(a0)
     dec:	00000097          	auipc	ra,0x0
     df0:	f72080e7          	jalr	-142(ra) # d5e <nulterminate>
    break;
     df4:	bf7d                	j	db2 <nulterminate+0x54>

0000000000000df6 <parsecmd>:
{
     df6:	7179                	addi	sp,sp,-48
     df8:	f406                	sd	ra,40(sp)
     dfa:	f022                	sd	s0,32(sp)
     dfc:	ec26                	sd	s1,24(sp)
     dfe:	e84a                	sd	s2,16(sp)
     e00:	1800                	addi	s0,sp,48
     e02:	fca43c23          	sd	a0,-40(s0)
  es = s + strlen(s);
     e06:	84aa                	mv	s1,a0
     e08:	00000097          	auipc	ra,0x0
     e0c:	2dc080e7          	jalr	732(ra) # 10e4 <strlen>
     e10:	1502                	slli	a0,a0,0x20
     e12:	9101                	srli	a0,a0,0x20
     e14:	94aa                	add	s1,s1,a0
  cmd = parseline(&s, es);
     e16:	85a6                	mv	a1,s1
     e18:	fd840513          	addi	a0,s0,-40
     e1c:	00000097          	auipc	ra,0x0
     e20:	df6080e7          	jalr	-522(ra) # c12 <parseline>
     e24:	892a                	mv	s2,a0
  peek(&s, es, "");
     e26:	00001617          	auipc	a2,0x1
     e2a:	bda60613          	addi	a2,a2,-1062 # 1a00 <malloc+0x298>
     e2e:	85a6                	mv	a1,s1
     e30:	fd840513          	addi	a0,s0,-40
     e34:	00000097          	auipc	ra,0x0
     e38:	b08080e7          	jalr	-1272(ra) # 93c <peek>
  if(s != es){
     e3c:	fd843603          	ld	a2,-40(s0)
     e40:	00961e63          	bne	a2,s1,e5c <parsecmd+0x66>
  nulterminate(cmd);
     e44:	854a                	mv	a0,s2
     e46:	00000097          	auipc	ra,0x0
     e4a:	f18080e7          	jalr	-232(ra) # d5e <nulterminate>
}
     e4e:	854a                	mv	a0,s2
     e50:	70a2                	ld	ra,40(sp)
     e52:	7402                	ld	s0,32(sp)
     e54:	64e2                	ld	s1,24(sp)
     e56:	6942                	ld	s2,16(sp)
     e58:	6145                	addi	sp,sp,48
     e5a:	8082                	ret
    fprintf(2, "leftovers: %s\n", s);
     e5c:	00001597          	auipc	a1,0x1
     e60:	b4c58593          	addi	a1,a1,-1204 # 19a8 <malloc+0x240>
     e64:	4509                	li	a0,2
     e66:	00001097          	auipc	ra,0x1
     e6a:	81c080e7          	jalr	-2020(ra) # 1682 <fprintf>
    panic("syntax");
     e6e:	00001517          	auipc	a0,0x1
     e72:	ad250513          	addi	a0,a0,-1326 # 1940 <malloc+0x1d8>
     e76:	fffff097          	auipc	ra,0xfffff
     e7a:	560080e7          	jalr	1376(ra) # 3d6 <panic>

0000000000000e7e <main>:
{
     e7e:	715d                	addi	sp,sp,-80
     e80:	e486                	sd	ra,72(sp)
     e82:	e0a2                	sd	s0,64(sp)
     e84:	fc26                	sd	s1,56(sp)
     e86:	f84a                	sd	s2,48(sp)
     e88:	f44e                	sd	s3,40(sp)
     e8a:	f052                	sd	s4,32(sp)
     e8c:	ec56                	sd	s5,24(sp)
     e8e:	e85a                	sd	s6,16(sp)
     e90:	e45e                	sd	s7,8(sp)
     e92:	0880                	addi	s0,sp,80
  while((fd = dev(O_RDWR, 1, 0)) >= 0){
     e94:	4601                	li	a2,0
     e96:	4585                	li	a1,1
     e98:	4509                	li	a0,2
     e9a:	00000097          	auipc	ra,0x0
     e9e:	516080e7          	jalr	1302(ra) # 13b0 <dev>
     ea2:	00054963          	bltz	a0,eb4 <main+0x36>
    if(fd >= 3){
     ea6:	4789                	li	a5,2
     ea8:	fea7d6e3          	bge	a5,a0,e94 <main+0x16>
      close(fd);
     eac:	00000097          	auipc	ra,0x0
     eb0:	49c080e7          	jalr	1180(ra) # 1348 <close>
  strcpy(envs[nenv].name, "SHELL");
     eb4:	00001497          	auipc	s1,0x1
     eb8:	c1c48493          	addi	s1,s1,-996 # 1ad0 <nenv>
     ebc:	4088                	lw	a0,0(s1)
     ebe:	051e                	slli	a0,a0,0x7
     ec0:	00001917          	auipc	s2,0x1
     ec4:	d0890913          	addi	s2,s2,-760 # 1bc8 <envs>
     ec8:	00001597          	auipc	a1,0x1
     ecc:	af058593          	addi	a1,a1,-1296 # 19b8 <malloc+0x250>
     ed0:	954a                	add	a0,a0,s2
     ed2:	00000097          	auipc	ra,0x0
     ed6:	19c080e7          	jalr	412(ra) # 106e <strcpy>
  strcpy(envs[nenv].value, "/bin");
     eda:	4088                	lw	a0,0(s1)
     edc:	051e                	slli	a0,a0,0x7
     ede:	02050513          	addi	a0,a0,32
     ee2:	00001597          	auipc	a1,0x1
     ee6:	ade58593          	addi	a1,a1,-1314 # 19c0 <malloc+0x258>
     eea:	954a                	add	a0,a0,s2
     eec:	00000097          	auipc	ra,0x0
     ef0:	182080e7          	jalr	386(ra) # 106e <strcpy>
  nenv++;
     ef4:	409c                	lw	a5,0(s1)
     ef6:	2785                	addiw	a5,a5,1
     ef8:	c09c                	sw	a5,0(s1)
  getcwd(mycwd);
     efa:	00001517          	auipc	a0,0x1
     efe:	be650513          	addi	a0,a0,-1050 # 1ae0 <mycwd>
     f02:	00000097          	auipc	ra,0x0
     f06:	4be080e7          	jalr	1214(ra) # 13c0 <getcwd>
  while(getcmd(buf, sizeof(buf)) >= 0){
     f0a:	00001917          	auipc	s2,0x1
     f0e:	c5690913          	addi	s2,s2,-938 # 1b60 <buf.0>
    replace(buf);
     f12:	00001997          	auipc	s3,0x1
     f16:	bce98993          	addi	s3,s3,-1074 # 1ae0 <mycwd>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     f1a:	06300a13          	li	s4,99
      else if(!strcmp(ecmd->argv[0], "export"))
     f1e:	00001a97          	auipc	s5,0x1
     f22:	abaa8a93          	addi	s5,s5,-1350 # 19d8 <malloc+0x270>
          fprintf(2, "Usage: export [-p] [NAME=VALUE]\n");
     f26:	00001b97          	auipc	s7,0x1
     f2a:	abab8b93          	addi	s7,s7,-1350 # 19e0 <malloc+0x278>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     f2e:	02000b13          	li	s6,32
  while(getcmd(buf, sizeof(buf)) >= 0){
     f32:	a851                	j	fc6 <main+0x148>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     f34:	0829c783          	lbu	a5,130(s3)
     f38:	0b679f63          	bne	a5,s6,ff6 <main+0x178>
      buf[strlen(buf)-1] = 0;  // chop \n
     f3c:	00001517          	auipc	a0,0x1
     f40:	c2450513          	addi	a0,a0,-988 # 1b60 <buf.0>
     f44:	00000097          	auipc	ra,0x0
     f48:	1a0080e7          	jalr	416(ra) # 10e4 <strlen>
     f4c:	fff5079b          	addiw	a5,a0,-1
     f50:	1782                	slli	a5,a5,0x20
     f52:	9381                	srli	a5,a5,0x20
     f54:	00001717          	auipc	a4,0x1
     f58:	b8c70713          	addi	a4,a4,-1140 # 1ae0 <mycwd>
     f5c:	97ba                	add	a5,a5,a4
     f5e:	08078023          	sb	zero,128(a5)
      if(chdir(buf+3) < 0)
     f62:	00001517          	auipc	a0,0x1
     f66:	c0150513          	addi	a0,a0,-1023 # 1b63 <buf.0+0x3>
     f6a:	00000097          	auipc	ra,0x0
     f6e:	40e080e7          	jalr	1038(ra) # 1378 <chdir>
     f72:	00054b63          	bltz	a0,f88 <main+0x10a>
      getcwd(mycwd);
     f76:	00001517          	auipc	a0,0x1
     f7a:	b6a50513          	addi	a0,a0,-1174 # 1ae0 <mycwd>
     f7e:	00000097          	auipc	ra,0x0
     f82:	442080e7          	jalr	1090(ra) # 13c0 <getcwd>
     f86:	a081                	j	fc6 <main+0x148>
        fprintf(2, "cannot cd %s\n", buf+3);
     f88:	00001617          	auipc	a2,0x1
     f8c:	bdb60613          	addi	a2,a2,-1061 # 1b63 <buf.0+0x3>
     f90:	00001597          	auipc	a1,0x1
     f94:	a3858593          	addi	a1,a1,-1480 # 19c8 <malloc+0x260>
     f98:	4509                	li	a0,2
     f9a:	00000097          	auipc	ra,0x0
     f9e:	6e8080e7          	jalr	1768(ra) # 1682 <fprintf>
     fa2:	bfd1                	j	f76 <main+0xf8>
        free(cmd);
     fa4:	8526                	mv	a0,s1
     fa6:	00000097          	auipc	ra,0x0
     faa:	740080e7          	jalr	1856(ra) # 16e6 <free>
        continue;
     fae:	a821                	j	fc6 <main+0x148>
          fprintf(2, "Usage: export [-p] [NAME=VALUE]\n");
     fb0:	85de                	mv	a1,s7
     fb2:	4509                	li	a0,2
     fb4:	00000097          	auipc	ra,0x0
     fb8:	6ce080e7          	jalr	1742(ra) # 1682 <fprintf>
        free(cmd);
     fbc:	8526                	mv	a0,s1
     fbe:	00000097          	auipc	ra,0x0
     fc2:	728080e7          	jalr	1832(ra) # 16e6 <free>
  while(getcmd(buf, sizeof(buf)) >= 0){
     fc6:	06400593          	li	a1,100
     fca:	854a                	mv	a0,s2
     fcc:	fffff097          	auipc	ra,0xfffff
     fd0:	3ae080e7          	jalr	942(ra) # 37a <getcmd>
     fd4:	08054863          	bltz	a0,1064 <main+0x1e6>
    replace(buf);
     fd8:	854a                	mv	a0,s2
     fda:	fffff097          	auipc	ra,0xfffff
     fde:	248080e7          	jalr	584(ra) # 222 <replace>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     fe2:	0809c783          	lbu	a5,128(s3)
     fe6:	01479863          	bne	a5,s4,ff6 <main+0x178>
     fea:	0819c703          	lbu	a4,129(s3)
     fee:	06400793          	li	a5,100
     ff2:	f4f701e3          	beq	a4,a5,f34 <main+0xb6>
      struct cmd *cmd = parsecmd(buf);
     ff6:	854a                	mv	a0,s2
     ff8:	00000097          	auipc	ra,0x0
     ffc:	dfe080e7          	jalr	-514(ra) # df6 <parsecmd>
    1000:	84aa                	mv	s1,a0
      if(ecmd->argv[0] == 0) {
    1002:	6508                	ld	a0,8(a0)
    1004:	d145                	beqz	a0,fa4 <main+0x126>
      else if(!strcmp(ecmd->argv[0], "export"))
    1006:	85d6                	mv	a1,s5
    1008:	00000097          	auipc	ra,0x0
    100c:	0b0080e7          	jalr	176(ra) # 10b8 <strcmp>
    1010:	e50d                	bnez	a0,103a <main+0x1bc>
        if(ecmd->argv[1] == NULL)
    1012:	689c                	ld	a5,16(s1)
    1014:	dfd1                	beqz	a5,fb0 <main+0x132>
        else if(export(ecmd->argv) < 0)
    1016:	00848513          	addi	a0,s1,8
    101a:	fffff097          	auipc	ra,0xfffff
    101e:	05e080e7          	jalr	94(ra) # 78 <export>
    1022:	f8055de3          	bgez	a0,fbc <main+0x13e>
          fprintf(2, "export failed\n");
    1026:	00001597          	auipc	a1,0x1
    102a:	9e258593          	addi	a1,a1,-1566 # 1a08 <malloc+0x2a0>
    102e:	4509                	li	a0,2
    1030:	00000097          	auipc	ra,0x0
    1034:	652080e7          	jalr	1618(ra) # 1682 <fprintf>
    1038:	b751                	j	fbc <main+0x13e>
      else if(fork1() == 0) 
    103a:	fffff097          	auipc	ra,0xfffff
    103e:	3c2080e7          	jalr	962(ra) # 3fc <fork1>
    1042:	cd01                	beqz	a0,105a <main+0x1dc>
      wait(0);
    1044:	4501                	li	a0,0
    1046:	00000097          	auipc	ra,0x0
    104a:	2e2080e7          	jalr	738(ra) # 1328 <wait>
      free(cmd);
    104e:	8526                	mv	a0,s1
    1050:	00000097          	auipc	ra,0x0
    1054:	696080e7          	jalr	1686(ra) # 16e6 <free>
    1058:	b7bd                	j	fc6 <main+0x148>
        runcmd(cmd);
    105a:	8526                	mv	a0,s1
    105c:	fffff097          	auipc	ra,0xfffff
    1060:	3ce080e7          	jalr	974(ra) # 42a <runcmd>
  exit(0);
    1064:	4501                	li	a0,0
    1066:	00000097          	auipc	ra,0x0
    106a:	2ba080e7          	jalr	698(ra) # 1320 <exit>

000000000000106e <strcpy>:
#include "kernel/include/fcntl.h"
#include "xv6-user/user.h"

char*
strcpy(char *s, const char *t)
{
    106e:	1141                	addi	sp,sp,-16
    1070:	e422                	sd	s0,8(sp)
    1072:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    1074:	87aa                	mv	a5,a0
    1076:	0585                	addi	a1,a1,1
    1078:	0785                	addi	a5,a5,1
    107a:	fff5c703          	lbu	a4,-1(a1)
    107e:	fee78fa3          	sb	a4,-1(a5)
    1082:	fb75                	bnez	a4,1076 <strcpy+0x8>
    ;
  return os;
}
    1084:	6422                	ld	s0,8(sp)
    1086:	0141                	addi	sp,sp,16
    1088:	8082                	ret

000000000000108a <strcat>:

char*
strcat(char *s, const char *t)
{
    108a:	1141                	addi	sp,sp,-16
    108c:	e422                	sd	s0,8(sp)
    108e:	0800                	addi	s0,sp,16
  char *os = s;
  while(*s)
    1090:	00054783          	lbu	a5,0(a0)
    1094:	c385                	beqz	a5,10b4 <strcat+0x2a>
    1096:	87aa                	mv	a5,a0
    s++;
    1098:	0785                	addi	a5,a5,1
  while(*s)
    109a:	0007c703          	lbu	a4,0(a5)
    109e:	ff6d                	bnez	a4,1098 <strcat+0xe>
  while((*s++ = *t++))
    10a0:	0585                	addi	a1,a1,1
    10a2:	0785                	addi	a5,a5,1
    10a4:	fff5c703          	lbu	a4,-1(a1)
    10a8:	fee78fa3          	sb	a4,-1(a5)
    10ac:	fb75                	bnez	a4,10a0 <strcat+0x16>
    ;
  return os;
}
    10ae:	6422                	ld	s0,8(sp)
    10b0:	0141                	addi	sp,sp,16
    10b2:	8082                	ret
  while(*s)
    10b4:	87aa                	mv	a5,a0
    10b6:	b7ed                	j	10a0 <strcat+0x16>

00000000000010b8 <strcmp>:


int
strcmp(const char *p, const char *q)
{
    10b8:	1141                	addi	sp,sp,-16
    10ba:	e422                	sd	s0,8(sp)
    10bc:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    10be:	00054783          	lbu	a5,0(a0)
    10c2:	cb91                	beqz	a5,10d6 <strcmp+0x1e>
    10c4:	0005c703          	lbu	a4,0(a1)
    10c8:	00f71763          	bne	a4,a5,10d6 <strcmp+0x1e>
    p++, q++;
    10cc:	0505                	addi	a0,a0,1
    10ce:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    10d0:	00054783          	lbu	a5,0(a0)
    10d4:	fbe5                	bnez	a5,10c4 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    10d6:	0005c503          	lbu	a0,0(a1)
}
    10da:	40a7853b          	subw	a0,a5,a0
    10de:	6422                	ld	s0,8(sp)
    10e0:	0141                	addi	sp,sp,16
    10e2:	8082                	ret

00000000000010e4 <strlen>:

uint
strlen(const char *s)
{
    10e4:	1141                	addi	sp,sp,-16
    10e6:	e422                	sd	s0,8(sp)
    10e8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    10ea:	00054783          	lbu	a5,0(a0)
    10ee:	cf91                	beqz	a5,110a <strlen+0x26>
    10f0:	0505                	addi	a0,a0,1
    10f2:	87aa                	mv	a5,a0
    10f4:	86be                	mv	a3,a5
    10f6:	0785                	addi	a5,a5,1
    10f8:	fff7c703          	lbu	a4,-1(a5)
    10fc:	ff65                	bnez	a4,10f4 <strlen+0x10>
    10fe:	40a6853b          	subw	a0,a3,a0
    1102:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    1104:	6422                	ld	s0,8(sp)
    1106:	0141                	addi	sp,sp,16
    1108:	8082                	ret
  for(n = 0; s[n]; n++)
    110a:	4501                	li	a0,0
    110c:	bfe5                	j	1104 <strlen+0x20>

000000000000110e <memset>:

void*
memset(void *dst, int c, uint n)
{
    110e:	1141                	addi	sp,sp,-16
    1110:	e422                	sd	s0,8(sp)
    1112:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    1114:	ca19                	beqz	a2,112a <memset+0x1c>
    1116:	87aa                	mv	a5,a0
    1118:	1602                	slli	a2,a2,0x20
    111a:	9201                	srli	a2,a2,0x20
    111c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    1120:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    1124:	0785                	addi	a5,a5,1
    1126:	fee79de3          	bne	a5,a4,1120 <memset+0x12>
  }
  return dst;
}
    112a:	6422                	ld	s0,8(sp)
    112c:	0141                	addi	sp,sp,16
    112e:	8082                	ret

0000000000001130 <strchr>:

char*
strchr(const char *s, char c)
{
    1130:	1141                	addi	sp,sp,-16
    1132:	e422                	sd	s0,8(sp)
    1134:	0800                	addi	s0,sp,16
  for(; *s; s++)
    1136:	00054783          	lbu	a5,0(a0)
    113a:	cb99                	beqz	a5,1150 <strchr+0x20>
    if(*s == c)
    113c:	00f58763          	beq	a1,a5,114a <strchr+0x1a>
  for(; *s; s++)
    1140:	0505                	addi	a0,a0,1
    1142:	00054783          	lbu	a5,0(a0)
    1146:	fbfd                	bnez	a5,113c <strchr+0xc>
      return (char*)s;
  return 0;
    1148:	4501                	li	a0,0
}
    114a:	6422                	ld	s0,8(sp)
    114c:	0141                	addi	sp,sp,16
    114e:	8082                	ret
  return 0;
    1150:	4501                	li	a0,0
    1152:	bfe5                	j	114a <strchr+0x1a>

0000000000001154 <gets>:

char*
gets(char *buf, int max)
{
    1154:	711d                	addi	sp,sp,-96
    1156:	ec86                	sd	ra,88(sp)
    1158:	e8a2                	sd	s0,80(sp)
    115a:	e4a6                	sd	s1,72(sp)
    115c:	e0ca                	sd	s2,64(sp)
    115e:	fc4e                	sd	s3,56(sp)
    1160:	f852                	sd	s4,48(sp)
    1162:	f456                	sd	s5,40(sp)
    1164:	f05a                	sd	s6,32(sp)
    1166:	ec5e                	sd	s7,24(sp)
    1168:	1080                	addi	s0,sp,96
    116a:	8baa                	mv	s7,a0
    116c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    116e:	892a                	mv	s2,a0
    1170:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    1172:	4aa9                	li	s5,10
    1174:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    1176:	89a6                	mv	s3,s1
    1178:	2485                	addiw	s1,s1,1
    117a:	0344d863          	bge	s1,s4,11aa <gets+0x56>
    cc = read(0, &c, 1);
    117e:	4605                	li	a2,1
    1180:	faf40593          	addi	a1,s0,-81
    1184:	4501                	li	a0,0
    1186:	00000097          	auipc	ra,0x0
    118a:	1b2080e7          	jalr	434(ra) # 1338 <read>
    if(cc < 1)
    118e:	00a05e63          	blez	a0,11aa <gets+0x56>
    buf[i++] = c;
    1192:	faf44783          	lbu	a5,-81(s0)
    1196:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    119a:	01578763          	beq	a5,s5,11a8 <gets+0x54>
    119e:	0905                	addi	s2,s2,1
    11a0:	fd679be3          	bne	a5,s6,1176 <gets+0x22>
    buf[i++] = c;
    11a4:	89a6                	mv	s3,s1
    11a6:	a011                	j	11aa <gets+0x56>
    11a8:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    11aa:	99de                	add	s3,s3,s7
    11ac:	00098023          	sb	zero,0(s3)
  return buf;
}
    11b0:	855e                	mv	a0,s7
    11b2:	60e6                	ld	ra,88(sp)
    11b4:	6446                	ld	s0,80(sp)
    11b6:	64a6                	ld	s1,72(sp)
    11b8:	6906                	ld	s2,64(sp)
    11ba:	79e2                	ld	s3,56(sp)
    11bc:	7a42                	ld	s4,48(sp)
    11be:	7aa2                	ld	s5,40(sp)
    11c0:	7b02                	ld	s6,32(sp)
    11c2:	6be2                	ld	s7,24(sp)
    11c4:	6125                	addi	sp,sp,96
    11c6:	8082                	ret

00000000000011c8 <stat>:

int
stat(const char *n, struct stat *st)
{
    11c8:	1101                	addi	sp,sp,-32
    11ca:	ec06                	sd	ra,24(sp)
    11cc:	e822                	sd	s0,16(sp)
    11ce:	e04a                	sd	s2,0(sp)
    11d0:	1000                	addi	s0,sp,32
    11d2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    11d4:	4581                	li	a1,0
    11d6:	00000097          	auipc	ra,0x0
    11da:	18a080e7          	jalr	394(ra) # 1360 <open>
  if(fd < 0)
    11de:	02054663          	bltz	a0,120a <stat+0x42>
    11e2:	e426                	sd	s1,8(sp)
    11e4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    11e6:	85ca                	mv	a1,s2
    11e8:	00000097          	auipc	ra,0x0
    11ec:	180080e7          	jalr	384(ra) # 1368 <fstat>
    11f0:	892a                	mv	s2,a0
  close(fd);
    11f2:	8526                	mv	a0,s1
    11f4:	00000097          	auipc	ra,0x0
    11f8:	154080e7          	jalr	340(ra) # 1348 <close>
  return r;
    11fc:	64a2                	ld	s1,8(sp)
}
    11fe:	854a                	mv	a0,s2
    1200:	60e2                	ld	ra,24(sp)
    1202:	6442                	ld	s0,16(sp)
    1204:	6902                	ld	s2,0(sp)
    1206:	6105                	addi	sp,sp,32
    1208:	8082                	ret
    return -1;
    120a:	597d                	li	s2,-1
    120c:	bfcd                	j	11fe <stat+0x36>

000000000000120e <atoi>:

int
atoi(const char *s)
{
    120e:	1141                	addi	sp,sp,-16
    1210:	e422                	sd	s0,8(sp)
    1212:	0800                	addi	s0,sp,16
  int n;
  int neg = 1;
  if (*s == '-') {
    1214:	00054703          	lbu	a4,0(a0)
    1218:	02d00793          	li	a5,45
  int neg = 1;
    121c:	4585                	li	a1,1
  if (*s == '-') {
    121e:	04f70363          	beq	a4,a5,1264 <atoi+0x56>
    s++;
    neg = -1;
  }
  n = 0;
  while('0' <= *s && *s <= '9')
    1222:	00054703          	lbu	a4,0(a0)
    1226:	fd07079b          	addiw	a5,a4,-48
    122a:	0ff7f793          	zext.b	a5,a5
    122e:	46a5                	li	a3,9
    1230:	02f6ed63          	bltu	a3,a5,126a <atoi+0x5c>
  n = 0;
    1234:	4681                	li	a3,0
  while('0' <= *s && *s <= '9')
    1236:	4625                	li	a2,9
    n = n*10 + *s++ - '0';
    1238:	0505                	addi	a0,a0,1
    123a:	0026979b          	slliw	a5,a3,0x2
    123e:	9fb5                	addw	a5,a5,a3
    1240:	0017979b          	slliw	a5,a5,0x1
    1244:	9fb9                	addw	a5,a5,a4
    1246:	fd07869b          	addiw	a3,a5,-48
  while('0' <= *s && *s <= '9')
    124a:	00054703          	lbu	a4,0(a0)
    124e:	fd07079b          	addiw	a5,a4,-48
    1252:	0ff7f793          	zext.b	a5,a5
    1256:	fef671e3          	bgeu	a2,a5,1238 <atoi+0x2a>
  return n * neg;
}
    125a:	02d5853b          	mulw	a0,a1,a3
    125e:	6422                	ld	s0,8(sp)
    1260:	0141                	addi	sp,sp,16
    1262:	8082                	ret
    s++;
    1264:	0505                	addi	a0,a0,1
    neg = -1;
    1266:	55fd                	li	a1,-1
    1268:	bf6d                	j	1222 <atoi+0x14>
  n = 0;
    126a:	4681                	li	a3,0
    126c:	b7fd                	j	125a <atoi+0x4c>

000000000000126e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    126e:	1141                	addi	sp,sp,-16
    1270:	e422                	sd	s0,8(sp)
    1272:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    1274:	02b57463          	bgeu	a0,a1,129c <memmove+0x2e>
    while(n-- > 0)
    1278:	00c05f63          	blez	a2,1296 <memmove+0x28>
    127c:	1602                	slli	a2,a2,0x20
    127e:	9201                	srli	a2,a2,0x20
    1280:	00c507b3          	add	a5,a0,a2
  dst = vdst;
    1284:	872a                	mv	a4,a0
      *dst++ = *src++;
    1286:	0585                	addi	a1,a1,1
    1288:	0705                	addi	a4,a4,1
    128a:	fff5c683          	lbu	a3,-1(a1)
    128e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    1292:	fef71ae3          	bne	a4,a5,1286 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    1296:	6422                	ld	s0,8(sp)
    1298:	0141                	addi	sp,sp,16
    129a:	8082                	ret
    dst += n;
    129c:	00c50733          	add	a4,a0,a2
    src += n;
    12a0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    12a2:	fec05ae3          	blez	a2,1296 <memmove+0x28>
    12a6:	fff6079b          	addiw	a5,a2,-1
    12aa:	1782                	slli	a5,a5,0x20
    12ac:	9381                	srli	a5,a5,0x20
    12ae:	fff7c793          	not	a5,a5
    12b2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    12b4:	15fd                	addi	a1,a1,-1
    12b6:	177d                	addi	a4,a4,-1
    12b8:	0005c683          	lbu	a3,0(a1)
    12bc:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    12c0:	fee79ae3          	bne	a5,a4,12b4 <memmove+0x46>
    12c4:	bfc9                	j	1296 <memmove+0x28>

00000000000012c6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    12c6:	1141                	addi	sp,sp,-16
    12c8:	e422                	sd	s0,8(sp)
    12ca:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    12cc:	ca05                	beqz	a2,12fc <memcmp+0x36>
    12ce:	fff6069b          	addiw	a3,a2,-1
    12d2:	1682                	slli	a3,a3,0x20
    12d4:	9281                	srli	a3,a3,0x20
    12d6:	0685                	addi	a3,a3,1
    12d8:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    12da:	00054783          	lbu	a5,0(a0)
    12de:	0005c703          	lbu	a4,0(a1)
    12e2:	00e79863          	bne	a5,a4,12f2 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
    12e6:	0505                	addi	a0,a0,1
    p2++;
    12e8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    12ea:	fed518e3          	bne	a0,a3,12da <memcmp+0x14>
  }
  return 0;
    12ee:	4501                	li	a0,0
    12f0:	a019                	j	12f6 <memcmp+0x30>
      return *p1 - *p2;
    12f2:	40e7853b          	subw	a0,a5,a4
}
    12f6:	6422                	ld	s0,8(sp)
    12f8:	0141                	addi	sp,sp,16
    12fa:	8082                	ret
  return 0;
    12fc:	4501                	li	a0,0
    12fe:	bfe5                	j	12f6 <memcmp+0x30>

0000000000001300 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    1300:	1141                	addi	sp,sp,-16
    1302:	e406                	sd	ra,8(sp)
    1304:	e022                	sd	s0,0(sp)
    1306:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    1308:	00000097          	auipc	ra,0x0
    130c:	f66080e7          	jalr	-154(ra) # 126e <memmove>
}
    1310:	60a2                	ld	ra,8(sp)
    1312:	6402                	ld	s0,0(sp)
    1314:	0141                	addi	sp,sp,16
    1316:	8082                	ret

0000000000001318 <fork>:
# generated by usys.pl - do not edit
#include "kernel/include/sysnum.h"
.global fork
fork:
 li a7, SYS_fork
    1318:	4885                	li	a7,1
 ecall
    131a:	00000073          	ecall
 ret
    131e:	8082                	ret

0000000000001320 <exit>:
.global exit
exit:
 li a7, SYS_exit
    1320:	4889                	li	a7,2
 ecall
    1322:	00000073          	ecall
 ret
    1326:	8082                	ret

0000000000001328 <wait>:
.global wait
wait:
 li a7, SYS_wait
    1328:	488d                	li	a7,3
 ecall
    132a:	00000073          	ecall
 ret
    132e:	8082                	ret

0000000000001330 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    1330:	4891                	li	a7,4
 ecall
    1332:	00000073          	ecall
 ret
    1336:	8082                	ret

0000000000001338 <read>:
.global read
read:
 li a7, SYS_read
    1338:	4895                	li	a7,5
 ecall
    133a:	00000073          	ecall
 ret
    133e:	8082                	ret

0000000000001340 <write>:
.global write
write:
 li a7, SYS_write
    1340:	48c1                	li	a7,16
 ecall
    1342:	00000073          	ecall
 ret
    1346:	8082                	ret

0000000000001348 <close>:
.global close
close:
 li a7, SYS_close
    1348:	48d5                	li	a7,21
 ecall
    134a:	00000073          	ecall
 ret
    134e:	8082                	ret

0000000000001350 <kill>:
.global kill
kill:
 li a7, SYS_kill
    1350:	4899                	li	a7,6
 ecall
    1352:	00000073          	ecall
 ret
    1356:	8082                	ret

0000000000001358 <exec>:
.global exec
exec:
 li a7, SYS_exec
    1358:	489d                	li	a7,7
 ecall
    135a:	00000073          	ecall
 ret
    135e:	8082                	ret

0000000000001360 <open>:
.global open
open:
 li a7, SYS_open
    1360:	48bd                	li	a7,15
 ecall
    1362:	00000073          	ecall
 ret
    1366:	8082                	ret

0000000000001368 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    1368:	48a1                	li	a7,8
 ecall
    136a:	00000073          	ecall
 ret
    136e:	8082                	ret

0000000000001370 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    1370:	48d1                	li	a7,20
 ecall
    1372:	00000073          	ecall
 ret
    1376:	8082                	ret

0000000000001378 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    1378:	48a5                	li	a7,9
 ecall
    137a:	00000073          	ecall
 ret
    137e:	8082                	ret

0000000000001380 <dup>:
.global dup
dup:
 li a7, SYS_dup
    1380:	48a9                	li	a7,10
 ecall
    1382:	00000073          	ecall
 ret
    1386:	8082                	ret

0000000000001388 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    1388:	48ad                	li	a7,11
 ecall
    138a:	00000073          	ecall
 ret
    138e:	8082                	ret

0000000000001390 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    1390:	48b1                	li	a7,12
 ecall
    1392:	00000073          	ecall
 ret
    1396:	8082                	ret

0000000000001398 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    1398:	48b5                	li	a7,13
 ecall
    139a:	00000073          	ecall
 ret
    139e:	8082                	ret

00000000000013a0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    13a0:	48b9                	li	a7,14
 ecall
    13a2:	00000073          	ecall
 ret
    13a6:	8082                	ret

00000000000013a8 <test_proc>:
.global test_proc
test_proc:
 li a7, SYS_test_proc
    13a8:	48d9                	li	a7,22
 ecall
    13aa:	00000073          	ecall
 ret
    13ae:	8082                	ret

00000000000013b0 <dev>:
.global dev
dev:
 li a7, SYS_dev
    13b0:	48dd                	li	a7,23
 ecall
    13b2:	00000073          	ecall
 ret
    13b6:	8082                	ret

00000000000013b8 <readdir>:
.global readdir
readdir:
 li a7, SYS_readdir
    13b8:	48e1                	li	a7,24
 ecall
    13ba:	00000073          	ecall
 ret
    13be:	8082                	ret

00000000000013c0 <getcwd>:
.global getcwd
getcwd:
 li a7, SYS_getcwd
    13c0:	48e5                	li	a7,25
 ecall
    13c2:	00000073          	ecall
 ret
    13c6:	8082                	ret

00000000000013c8 <remove>:
.global remove
remove:
 li a7, SYS_remove
    13c8:	48c5                	li	a7,17
 ecall
    13ca:	00000073          	ecall
 ret
    13ce:	8082                	ret

00000000000013d0 <trace>:
.global trace
trace:
 li a7, SYS_trace
    13d0:	48c9                	li	a7,18
 ecall
    13d2:	00000073          	ecall
 ret
    13d6:	8082                	ret

00000000000013d8 <sysinfo>:
.global sysinfo
sysinfo:
 li a7, SYS_sysinfo
    13d8:	48cd                	li	a7,19
 ecall
    13da:	00000073          	ecall
 ret
    13de:	8082                	ret

00000000000013e0 <rename>:
.global rename
rename:
 li a7, SYS_rename
    13e0:	48e9                	li	a7,26
 ecall
    13e2:	00000073          	ecall
 ret
    13e6:	8082                	ret

00000000000013e8 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    13e8:	1101                	addi	sp,sp,-32
    13ea:	ec06                	sd	ra,24(sp)
    13ec:	e822                	sd	s0,16(sp)
    13ee:	1000                	addi	s0,sp,32
    13f0:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    13f4:	4605                	li	a2,1
    13f6:	fef40593          	addi	a1,s0,-17
    13fa:	00000097          	auipc	ra,0x0
    13fe:	f46080e7          	jalr	-186(ra) # 1340 <write>
}
    1402:	60e2                	ld	ra,24(sp)
    1404:	6442                	ld	s0,16(sp)
    1406:	6105                	addi	sp,sp,32
    1408:	8082                	ret

000000000000140a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    140a:	7139                	addi	sp,sp,-64
    140c:	fc06                	sd	ra,56(sp)
    140e:	f822                	sd	s0,48(sp)
    1410:	f426                	sd	s1,40(sp)
    1412:	0080                	addi	s0,sp,64
    1414:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    1416:	c299                	beqz	a3,141c <printint+0x12>
    1418:	0805cb63          	bltz	a1,14ae <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    141c:	2581                	sext.w	a1,a1
  neg = 0;
    141e:	4881                	li	a7,0
    1420:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    1424:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    1426:	2601                	sext.w	a2,a2
    1428:	00000517          	auipc	a0,0x0
    142c:	68050513          	addi	a0,a0,1664 # 1aa8 <digits>
    1430:	883a                	mv	a6,a4
    1432:	2705                	addiw	a4,a4,1
    1434:	02c5f7bb          	remuw	a5,a1,a2
    1438:	1782                	slli	a5,a5,0x20
    143a:	9381                	srli	a5,a5,0x20
    143c:	97aa                	add	a5,a5,a0
    143e:	0007c783          	lbu	a5,0(a5)
    1442:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    1446:	0005879b          	sext.w	a5,a1
    144a:	02c5d5bb          	divuw	a1,a1,a2
    144e:	0685                	addi	a3,a3,1
    1450:	fec7f0e3          	bgeu	a5,a2,1430 <printint+0x26>
  if(neg)
    1454:	00088c63          	beqz	a7,146c <printint+0x62>
    buf[i++] = '-';
    1458:	fd070793          	addi	a5,a4,-48
    145c:	00878733          	add	a4,a5,s0
    1460:	02d00793          	li	a5,45
    1464:	fef70823          	sb	a5,-16(a4)
    1468:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    146c:	02e05c63          	blez	a4,14a4 <printint+0x9a>
    1470:	f04a                	sd	s2,32(sp)
    1472:	ec4e                	sd	s3,24(sp)
    1474:	fc040793          	addi	a5,s0,-64
    1478:	00e78933          	add	s2,a5,a4
    147c:	fff78993          	addi	s3,a5,-1
    1480:	99ba                	add	s3,s3,a4
    1482:	377d                	addiw	a4,a4,-1
    1484:	1702                	slli	a4,a4,0x20
    1486:	9301                	srli	a4,a4,0x20
    1488:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    148c:	fff94583          	lbu	a1,-1(s2)
    1490:	8526                	mv	a0,s1
    1492:	00000097          	auipc	ra,0x0
    1496:	f56080e7          	jalr	-170(ra) # 13e8 <putc>
  while(--i >= 0)
    149a:	197d                	addi	s2,s2,-1
    149c:	ff3918e3          	bne	s2,s3,148c <printint+0x82>
    14a0:	7902                	ld	s2,32(sp)
    14a2:	69e2                	ld	s3,24(sp)
}
    14a4:	70e2                	ld	ra,56(sp)
    14a6:	7442                	ld	s0,48(sp)
    14a8:	74a2                	ld	s1,40(sp)
    14aa:	6121                	addi	sp,sp,64
    14ac:	8082                	ret
    x = -xx;
    14ae:	40b005bb          	negw	a1,a1
    neg = 1;
    14b2:	4885                	li	a7,1
    x = -xx;
    14b4:	b7b5                	j	1420 <printint+0x16>

00000000000014b6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    14b6:	715d                	addi	sp,sp,-80
    14b8:	e486                	sd	ra,72(sp)
    14ba:	e0a2                	sd	s0,64(sp)
    14bc:	f84a                	sd	s2,48(sp)
    14be:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    14c0:	0005c903          	lbu	s2,0(a1)
    14c4:	1a090a63          	beqz	s2,1678 <vprintf+0x1c2>
    14c8:	fc26                	sd	s1,56(sp)
    14ca:	f44e                	sd	s3,40(sp)
    14cc:	f052                	sd	s4,32(sp)
    14ce:	ec56                	sd	s5,24(sp)
    14d0:	e85a                	sd	s6,16(sp)
    14d2:	e45e                	sd	s7,8(sp)
    14d4:	8aaa                	mv	s5,a0
    14d6:	8bb2                	mv	s7,a2
    14d8:	00158493          	addi	s1,a1,1
  state = 0;
    14dc:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    14de:	02500a13          	li	s4,37
    14e2:	4b55                	li	s6,21
    14e4:	a839                	j	1502 <vprintf+0x4c>
        putc(fd, c);
    14e6:	85ca                	mv	a1,s2
    14e8:	8556                	mv	a0,s5
    14ea:	00000097          	auipc	ra,0x0
    14ee:	efe080e7          	jalr	-258(ra) # 13e8 <putc>
    14f2:	a019                	j	14f8 <vprintf+0x42>
    } else if(state == '%'){
    14f4:	01498d63          	beq	s3,s4,150e <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
    14f8:	0485                	addi	s1,s1,1
    14fa:	fff4c903          	lbu	s2,-1(s1)
    14fe:	16090763          	beqz	s2,166c <vprintf+0x1b6>
    if(state == 0){
    1502:	fe0999e3          	bnez	s3,14f4 <vprintf+0x3e>
      if(c == '%'){
    1506:	ff4910e3          	bne	s2,s4,14e6 <vprintf+0x30>
        state = '%';
    150a:	89d2                	mv	s3,s4
    150c:	b7f5                	j	14f8 <vprintf+0x42>
      if(c == 'd'){
    150e:	13490463          	beq	s2,s4,1636 <vprintf+0x180>
    1512:	f9d9079b          	addiw	a5,s2,-99
    1516:	0ff7f793          	zext.b	a5,a5
    151a:	12fb6763          	bltu	s6,a5,1648 <vprintf+0x192>
    151e:	f9d9079b          	addiw	a5,s2,-99
    1522:	0ff7f713          	zext.b	a4,a5
    1526:	12eb6163          	bltu	s6,a4,1648 <vprintf+0x192>
    152a:	00271793          	slli	a5,a4,0x2
    152e:	00000717          	auipc	a4,0x0
    1532:	52270713          	addi	a4,a4,1314 # 1a50 <malloc+0x2e8>
    1536:	97ba                	add	a5,a5,a4
    1538:	439c                	lw	a5,0(a5)
    153a:	97ba                	add	a5,a5,a4
    153c:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
    153e:	008b8913          	addi	s2,s7,8
    1542:	4685                	li	a3,1
    1544:	4629                	li	a2,10
    1546:	000ba583          	lw	a1,0(s7)
    154a:	8556                	mv	a0,s5
    154c:	00000097          	auipc	ra,0x0
    1550:	ebe080e7          	jalr	-322(ra) # 140a <printint>
    1554:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
    1556:	4981                	li	s3,0
    1558:	b745                	j	14f8 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
    155a:	008b8913          	addi	s2,s7,8
    155e:	4681                	li	a3,0
    1560:	4629                	li	a2,10
    1562:	000ba583          	lw	a1,0(s7)
    1566:	8556                	mv	a0,s5
    1568:	00000097          	auipc	ra,0x0
    156c:	ea2080e7          	jalr	-350(ra) # 140a <printint>
    1570:	8bca                	mv	s7,s2
      state = 0;
    1572:	4981                	li	s3,0
    1574:	b751                	j	14f8 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
    1576:	008b8913          	addi	s2,s7,8
    157a:	4681                	li	a3,0
    157c:	4641                	li	a2,16
    157e:	000ba583          	lw	a1,0(s7)
    1582:	8556                	mv	a0,s5
    1584:	00000097          	auipc	ra,0x0
    1588:	e86080e7          	jalr	-378(ra) # 140a <printint>
    158c:	8bca                	mv	s7,s2
      state = 0;
    158e:	4981                	li	s3,0
    1590:	b7a5                	j	14f8 <vprintf+0x42>
    1592:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
    1594:	008b8c13          	addi	s8,s7,8
    1598:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
    159c:	03000593          	li	a1,48
    15a0:	8556                	mv	a0,s5
    15a2:	00000097          	auipc	ra,0x0
    15a6:	e46080e7          	jalr	-442(ra) # 13e8 <putc>
  putc(fd, 'x');
    15aa:	07800593          	li	a1,120
    15ae:	8556                	mv	a0,s5
    15b0:	00000097          	auipc	ra,0x0
    15b4:	e38080e7          	jalr	-456(ra) # 13e8 <putc>
    15b8:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    15ba:	00000b97          	auipc	s7,0x0
    15be:	4eeb8b93          	addi	s7,s7,1262 # 1aa8 <digits>
    15c2:	03c9d793          	srli	a5,s3,0x3c
    15c6:	97de                	add	a5,a5,s7
    15c8:	0007c583          	lbu	a1,0(a5)
    15cc:	8556                	mv	a0,s5
    15ce:	00000097          	auipc	ra,0x0
    15d2:	e1a080e7          	jalr	-486(ra) # 13e8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    15d6:	0992                	slli	s3,s3,0x4
    15d8:	397d                	addiw	s2,s2,-1
    15da:	fe0914e3          	bnez	s2,15c2 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
    15de:	8be2                	mv	s7,s8
      state = 0;
    15e0:	4981                	li	s3,0
    15e2:	6c02                	ld	s8,0(sp)
    15e4:	bf11                	j	14f8 <vprintf+0x42>
        s = va_arg(ap, char*);
    15e6:	008b8993          	addi	s3,s7,8
    15ea:	000bb903          	ld	s2,0(s7)
        if(s == 0)
    15ee:	02090163          	beqz	s2,1610 <vprintf+0x15a>
        while(*s != 0){
    15f2:	00094583          	lbu	a1,0(s2)
    15f6:	c9a5                	beqz	a1,1666 <vprintf+0x1b0>
          putc(fd, *s);
    15f8:	8556                	mv	a0,s5
    15fa:	00000097          	auipc	ra,0x0
    15fe:	dee080e7          	jalr	-530(ra) # 13e8 <putc>
          s++;
    1602:	0905                	addi	s2,s2,1
        while(*s != 0){
    1604:	00094583          	lbu	a1,0(s2)
    1608:	f9e5                	bnez	a1,15f8 <vprintf+0x142>
        s = va_arg(ap, char*);
    160a:	8bce                	mv	s7,s3
      state = 0;
    160c:	4981                	li	s3,0
    160e:	b5ed                	j	14f8 <vprintf+0x42>
          s = "(null)";
    1610:	00000917          	auipc	s2,0x0
    1614:	40890913          	addi	s2,s2,1032 # 1a18 <malloc+0x2b0>
        while(*s != 0){
    1618:	02800593          	li	a1,40
    161c:	bff1                	j	15f8 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
    161e:	008b8913          	addi	s2,s7,8
    1622:	000bc583          	lbu	a1,0(s7)
    1626:	8556                	mv	a0,s5
    1628:	00000097          	auipc	ra,0x0
    162c:	dc0080e7          	jalr	-576(ra) # 13e8 <putc>
    1630:	8bca                	mv	s7,s2
      state = 0;
    1632:	4981                	li	s3,0
    1634:	b5d1                	j	14f8 <vprintf+0x42>
        putc(fd, c);
    1636:	02500593          	li	a1,37
    163a:	8556                	mv	a0,s5
    163c:	00000097          	auipc	ra,0x0
    1640:	dac080e7          	jalr	-596(ra) # 13e8 <putc>
      state = 0;
    1644:	4981                	li	s3,0
    1646:	bd4d                	j	14f8 <vprintf+0x42>
        putc(fd, '%');
    1648:	02500593          	li	a1,37
    164c:	8556                	mv	a0,s5
    164e:	00000097          	auipc	ra,0x0
    1652:	d9a080e7          	jalr	-614(ra) # 13e8 <putc>
        putc(fd, c);
    1656:	85ca                	mv	a1,s2
    1658:	8556                	mv	a0,s5
    165a:	00000097          	auipc	ra,0x0
    165e:	d8e080e7          	jalr	-626(ra) # 13e8 <putc>
      state = 0;
    1662:	4981                	li	s3,0
    1664:	bd51                	j	14f8 <vprintf+0x42>
        s = va_arg(ap, char*);
    1666:	8bce                	mv	s7,s3
      state = 0;
    1668:	4981                	li	s3,0
    166a:	b579                	j	14f8 <vprintf+0x42>
    166c:	74e2                	ld	s1,56(sp)
    166e:	79a2                	ld	s3,40(sp)
    1670:	7a02                	ld	s4,32(sp)
    1672:	6ae2                	ld	s5,24(sp)
    1674:	6b42                	ld	s6,16(sp)
    1676:	6ba2                	ld	s7,8(sp)
    }
  }
}
    1678:	60a6                	ld	ra,72(sp)
    167a:	6406                	ld	s0,64(sp)
    167c:	7942                	ld	s2,48(sp)
    167e:	6161                	addi	sp,sp,80
    1680:	8082                	ret

0000000000001682 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    1682:	715d                	addi	sp,sp,-80
    1684:	ec06                	sd	ra,24(sp)
    1686:	e822                	sd	s0,16(sp)
    1688:	1000                	addi	s0,sp,32
    168a:	e010                	sd	a2,0(s0)
    168c:	e414                	sd	a3,8(s0)
    168e:	e818                	sd	a4,16(s0)
    1690:	ec1c                	sd	a5,24(s0)
    1692:	03043023          	sd	a6,32(s0)
    1696:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    169a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    169e:	8622                	mv	a2,s0
    16a0:	00000097          	auipc	ra,0x0
    16a4:	e16080e7          	jalr	-490(ra) # 14b6 <vprintf>
}
    16a8:	60e2                	ld	ra,24(sp)
    16aa:	6442                	ld	s0,16(sp)
    16ac:	6161                	addi	sp,sp,80
    16ae:	8082                	ret

00000000000016b0 <printf>:

void
printf(const char *fmt, ...)
{
    16b0:	711d                	addi	sp,sp,-96
    16b2:	ec06                	sd	ra,24(sp)
    16b4:	e822                	sd	s0,16(sp)
    16b6:	1000                	addi	s0,sp,32
    16b8:	e40c                	sd	a1,8(s0)
    16ba:	e810                	sd	a2,16(s0)
    16bc:	ec14                	sd	a3,24(s0)
    16be:	f018                	sd	a4,32(s0)
    16c0:	f41c                	sd	a5,40(s0)
    16c2:	03043823          	sd	a6,48(s0)
    16c6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    16ca:	00840613          	addi	a2,s0,8
    16ce:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    16d2:	85aa                	mv	a1,a0
    16d4:	4505                	li	a0,1
    16d6:	00000097          	auipc	ra,0x0
    16da:	de0080e7          	jalr	-544(ra) # 14b6 <vprintf>
}
    16de:	60e2                	ld	ra,24(sp)
    16e0:	6442                	ld	s0,16(sp)
    16e2:	6125                	addi	sp,sp,96
    16e4:	8082                	ret

00000000000016e6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    16e6:	1141                	addi	sp,sp,-16
    16e8:	e422                	sd	s0,8(sp)
    16ea:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    16ec:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    16f0:	00000797          	auipc	a5,0x0
    16f4:	3e87b783          	ld	a5,1000(a5) # 1ad8 <freep>
    16f8:	a02d                	j	1722 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    16fa:	4618                	lw	a4,8(a2)
    16fc:	9f2d                	addw	a4,a4,a1
    16fe:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    1702:	6398                	ld	a4,0(a5)
    1704:	6310                	ld	a2,0(a4)
    1706:	a83d                	j	1744 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    1708:	ff852703          	lw	a4,-8(a0)
    170c:	9f31                	addw	a4,a4,a2
    170e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    1710:	ff053683          	ld	a3,-16(a0)
    1714:	a091                	j	1758 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1716:	6398                	ld	a4,0(a5)
    1718:	00e7e463          	bltu	a5,a4,1720 <free+0x3a>
    171c:	00e6ea63          	bltu	a3,a4,1730 <free+0x4a>
{
    1720:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1722:	fed7fae3          	bgeu	a5,a3,1716 <free+0x30>
    1726:	6398                	ld	a4,0(a5)
    1728:	00e6e463          	bltu	a3,a4,1730 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    172c:	fee7eae3          	bltu	a5,a4,1720 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
    1730:	ff852583          	lw	a1,-8(a0)
    1734:	6390                	ld	a2,0(a5)
    1736:	02059813          	slli	a6,a1,0x20
    173a:	01c85713          	srli	a4,a6,0x1c
    173e:	9736                	add	a4,a4,a3
    1740:	fae60de3          	beq	a2,a4,16fa <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
    1744:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    1748:	4790                	lw	a2,8(a5)
    174a:	02061593          	slli	a1,a2,0x20
    174e:	01c5d713          	srli	a4,a1,0x1c
    1752:	973e                	add	a4,a4,a5
    1754:	fae68ae3          	beq	a3,a4,1708 <free+0x22>
    p->s.ptr = bp->s.ptr;
    1758:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    175a:	00000717          	auipc	a4,0x0
    175e:	36f73f23          	sd	a5,894(a4) # 1ad8 <freep>
}
    1762:	6422                	ld	s0,8(sp)
    1764:	0141                	addi	sp,sp,16
    1766:	8082                	ret

0000000000001768 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    1768:	7139                	addi	sp,sp,-64
    176a:	fc06                	sd	ra,56(sp)
    176c:	f822                	sd	s0,48(sp)
    176e:	f426                	sd	s1,40(sp)
    1770:	ec4e                	sd	s3,24(sp)
    1772:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1774:	02051493          	slli	s1,a0,0x20
    1778:	9081                	srli	s1,s1,0x20
    177a:	04bd                	addi	s1,s1,15
    177c:	8091                	srli	s1,s1,0x4
    177e:	0014899b          	addiw	s3,s1,1
    1782:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    1784:	00000517          	auipc	a0,0x0
    1788:	35453503          	ld	a0,852(a0) # 1ad8 <freep>
    178c:	c915                	beqz	a0,17c0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    178e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1790:	4798                	lw	a4,8(a5)
    1792:	08977e63          	bgeu	a4,s1,182e <malloc+0xc6>
    1796:	f04a                	sd	s2,32(sp)
    1798:	e852                	sd	s4,16(sp)
    179a:	e456                	sd	s5,8(sp)
    179c:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
    179e:	8a4e                	mv	s4,s3
    17a0:	0009871b          	sext.w	a4,s3
    17a4:	6685                	lui	a3,0x1
    17a6:	00d77363          	bgeu	a4,a3,17ac <malloc+0x44>
    17aa:	6a05                	lui	s4,0x1
    17ac:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    17b0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    17b4:	00000917          	auipc	s2,0x0
    17b8:	32490913          	addi	s2,s2,804 # 1ad8 <freep>
  if(p == (char*)-1)
    17bc:	5afd                	li	s5,-1
    17be:	a091                	j	1802 <malloc+0x9a>
    17c0:	f04a                	sd	s2,32(sp)
    17c2:	e852                	sd	s4,16(sp)
    17c4:	e456                	sd	s5,8(sp)
    17c6:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
    17c8:	00001797          	auipc	a5,0x1
    17cc:	c0078793          	addi	a5,a5,-1024 # 23c8 <base>
    17d0:	00000717          	auipc	a4,0x0
    17d4:	30f73423          	sd	a5,776(a4) # 1ad8 <freep>
    17d8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    17da:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    17de:	b7c1                	j	179e <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
    17e0:	6398                	ld	a4,0(a5)
    17e2:	e118                	sd	a4,0(a0)
    17e4:	a08d                	j	1846 <malloc+0xde>
  hp->s.size = nu;
    17e6:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    17ea:	0541                	addi	a0,a0,16
    17ec:	00000097          	auipc	ra,0x0
    17f0:	efa080e7          	jalr	-262(ra) # 16e6 <free>
  return freep;
    17f4:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    17f8:	c13d                	beqz	a0,185e <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    17fa:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    17fc:	4798                	lw	a4,8(a5)
    17fe:	02977463          	bgeu	a4,s1,1826 <malloc+0xbe>
    if(p == freep)
    1802:	00093703          	ld	a4,0(s2)
    1806:	853e                	mv	a0,a5
    1808:	fef719e3          	bne	a4,a5,17fa <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
    180c:	8552                	mv	a0,s4
    180e:	00000097          	auipc	ra,0x0
    1812:	b82080e7          	jalr	-1150(ra) # 1390 <sbrk>
  if(p == (char*)-1)
    1816:	fd5518e3          	bne	a0,s5,17e6 <malloc+0x7e>
        return 0;
    181a:	4501                	li	a0,0
    181c:	7902                	ld	s2,32(sp)
    181e:	6a42                	ld	s4,16(sp)
    1820:	6aa2                	ld	s5,8(sp)
    1822:	6b02                	ld	s6,0(sp)
    1824:	a03d                	j	1852 <malloc+0xea>
    1826:	7902                	ld	s2,32(sp)
    1828:	6a42                	ld	s4,16(sp)
    182a:	6aa2                	ld	s5,8(sp)
    182c:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
    182e:	fae489e3          	beq	s1,a4,17e0 <malloc+0x78>
        p->s.size -= nunits;
    1832:	4137073b          	subw	a4,a4,s3
    1836:	c798                	sw	a4,8(a5)
        p += p->s.size;
    1838:	02071693          	slli	a3,a4,0x20
    183c:	01c6d713          	srli	a4,a3,0x1c
    1840:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    1842:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    1846:	00000717          	auipc	a4,0x0
    184a:	28a73923          	sd	a0,658(a4) # 1ad8 <freep>
      return (void*)(p + 1);
    184e:	01078513          	addi	a0,a5,16
  }
}
    1852:	70e2                	ld	ra,56(sp)
    1854:	7442                	ld	s0,48(sp)
    1856:	74a2                	ld	s1,40(sp)
    1858:	69e2                	ld	s3,24(sp)
    185a:	6121                	addi	sp,sp,64
    185c:	8082                	ret
    185e:	7902                	ld	s2,32(sp)
    1860:	6a42                	ld	s4,16(sp)
    1862:	6aa2                	ld	s5,8(sp)
    1864:	6b02                	ld	s6,0(sp)
    1866:	b7f5                	j	1852 <malloc+0xea>
