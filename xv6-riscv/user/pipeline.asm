
user/_pipeline:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <checkInt>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int checkInt(char* s){
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
    int idx=0;
    while(s[idx]!='\0'){
   6:	00054783          	lbu	a5,0(a0)
   a:	cf99                	beqz	a5,28 <checkInt+0x28>
   c:	0505                	addi	a0,a0,1
        if(s[idx]<'0'||s[idx]>'9') return 0;
   e:	4725                	li	a4,9
  10:	fd07879b          	addiw	a5,a5,-48
  14:	0ff7f793          	andi	a5,a5,255
  18:	00f76a63          	bltu	a4,a5,2c <checkInt+0x2c>
    while(s[idx]!='\0'){
  1c:	0505                	addi	a0,a0,1
  1e:	fff54783          	lbu	a5,-1(a0)
  22:	f7fd                	bnez	a5,10 <checkInt+0x10>
        idx++;
    }
    return 1;
  24:	4505                	li	a0,1
  26:	a021                	j	2e <checkInt+0x2e>
  28:	4505                	li	a0,1
  2a:	a011                	j	2e <checkInt+0x2e>
        if(s[idx]<'0'||s[idx]>'9') return 0;
  2c:	4501                	li	a0,0
}
  2e:	6422                	ld	s0,8(sp)
  30:	0141                	addi	sp,sp,16
  32:	8082                	ret

0000000000000034 <main>:

int main(int argc,char *argv[])
{
  34:	7139                	addi	sp,sp,-64
  36:	fc06                	sd	ra,56(sp)
  38:	f822                	sd	s0,48(sp)
  3a:	f426                	sd	s1,40(sp)
  3c:	f04a                	sd	s2,32(sp)
  3e:	0080                	addi	s0,sp,64
	if(argc!=3){
  40:	478d                	li	a5,3
  42:	02f51e63          	bne	a0,a5,7e <main+0x4a>
  46:	84ae                	mv	s1,a1
        printf("Usage: pipeline <number_of_processes(n)> <value(x)>\n");
        exit(0);
    }
    if(!checkInt(argv[1])||!checkInt(argv[2])||atoi(argv[1])<0){
  48:	0085b903          	ld	s2,8(a1)
  4c:	854a                	mv	a0,s2
  4e:	00000097          	auipc	ra,0x0
  52:	fb2080e7          	jalr	-78(ra) # 0 <checkInt>
  56:	c519                	beqz	a0,64 <main+0x30>
  58:	6888                	ld	a0,16(s1)
  5a:	00000097          	auipc	ra,0x0
  5e:	fa6080e7          	jalr	-90(ra) # 0 <checkInt>
  62:	e91d                	bnez	a0,98 <main+0x64>
        printf("Usage: pipeline <number_of_processes(n)> <value(x)>\n");
  64:	00001517          	auipc	a0,0x1
  68:	99c50513          	addi	a0,a0,-1636 # a00 <malloc+0xea>
  6c:	00000097          	auipc	ra,0x0
  70:	7ec080e7          	jalr	2028(ra) # 858 <printf>
        exit(0);
  74:	4501                	li	a0,0
  76:	00000097          	auipc	ra,0x0
  7a:	452080e7          	jalr	1106(ra) # 4c8 <exit>
        printf("Usage: pipeline <number_of_processes(n)> <value(x)>\n");
  7e:	00001517          	auipc	a0,0x1
  82:	98250513          	addi	a0,a0,-1662 # a00 <malloc+0xea>
  86:	00000097          	auipc	ra,0x0
  8a:	7d2080e7          	jalr	2002(ra) # 858 <printf>
        exit(0);
  8e:	4501                	li	a0,0
  90:	00000097          	auipc	ra,0x0
  94:	438080e7          	jalr	1080(ra) # 4c8 <exit>
    if(!checkInt(argv[1])||!checkInt(argv[2])||atoi(argv[1])<0){
  98:	854a                	mv	a0,s2
  9a:	00000097          	auipc	ra,0x0
  9e:	32e080e7          	jalr	814(ra) # 3c8 <atoi>
  a2:	fc0541e3          	bltz	a0,64 <main+0x30>
    }
    int fd[2];
    //  fd[0]: read
    //  fd[1]: write
    int data[]={atoi(argv[1]),atoi(argv[2])+(int)getpid()};
  a6:	6488                	ld	a0,8(s1)
  a8:	00000097          	auipc	ra,0x0
  ac:	320080e7          	jalr	800(ra) # 3c8 <atoi>
  b0:	fca42823          	sw	a0,-48(s0)
  b4:	6888                	ld	a0,16(s1)
  b6:	00000097          	auipc	ra,0x0
  ba:	312080e7          	jalr	786(ra) # 3c8 <atoi>
  be:	84aa                	mv	s1,a0
  c0:	00000097          	auipc	ra,0x0
  c4:	488080e7          	jalr	1160(ra) # 548 <getpid>
  c8:	9ca9                	addw	s1,s1,a0
  ca:	fc942a23          	sw	s1,-44(s0)
	if(pipe(fd)<0){
  ce:	fd840513          	addi	a0,s0,-40
  d2:	00000097          	auipc	ra,0x0
  d6:	406080e7          	jalr	1030(ra) # 4d8 <pipe>
  da:	0c054a63          	bltz	a0,1ae <main+0x17a>
		printf("Error creating pipe.\n");
		exit(0);
	}
    if(write(fd[1],data,2*sizeof(int))<0){
  de:	4621                	li	a2,8
  e0:	fd040593          	addi	a1,s0,-48
  e4:	fdc42503          	lw	a0,-36(s0)
  e8:	00000097          	auipc	ra,0x0
  ec:	400080e7          	jalr	1024(ra) # 4e8 <write>
  f0:	0c054c63          	bltz	a0,1c8 <main+0x194>
        printf("Error writing to pipe.\n");
        exit(0);
    }
	printf("%d: %d\n",(int)getpid(),data[1]);
  f4:	00000097          	auipc	ra,0x0
  f8:	454080e7          	jalr	1108(ra) # 548 <getpid>
  fc:	85aa                	mv	a1,a0
  fe:	fd442603          	lw	a2,-44(s0)
 102:	00001517          	auipc	a0,0x1
 106:	96650513          	addi	a0,a0,-1690 # a68 <malloc+0x152>
 10a:	00000097          	auipc	ra,0x0
 10e:	74e080e7          	jalr	1870(ra) # 858 <printf>
        if(read(fd[0],temp,2*sizeof(int))<0){
            printf("Error reading from pipe.\n");
            exit(0);
        }
		temp[1]+=(int)getpid();
		printf("%d: %d\n",(int)getpid(),temp[1]);
 112:	00001497          	auipc	s1,0x1
 116:	95648493          	addi	s1,s1,-1706 # a68 <malloc+0x152>
		temp[0]--;
        if(write(fd[1],temp,2*sizeof(int))<0){
            printf("Error writing to pipe.\n");
            exit(0);
        }
		if(temp[0]>1){
 11a:	4905                	li	s2,1
    int id=fork();
 11c:	00000097          	auipc	ra,0x0
 120:	3a4080e7          	jalr	932(ra) # 4c0 <fork>
    if(id<0){
 124:	0a054f63          	bltz	a0,1e2 <main+0x1ae>
    else if(id>0){
 128:	0ca04a63          	bgtz	a0,1fc <main+0x1c8>
        if(read(fd[0],temp,2*sizeof(int))<0){
 12c:	4621                	li	a2,8
 12e:	fc840593          	addi	a1,s0,-56
 132:	fd842503          	lw	a0,-40(s0)
 136:	00000097          	auipc	ra,0x0
 13a:	3aa080e7          	jalr	938(ra) # 4e0 <read>
 13e:	0e054063          	bltz	a0,21e <main+0x1ea>
		temp[1]+=(int)getpid();
 142:	00000097          	auipc	ra,0x0
 146:	406080e7          	jalr	1030(ra) # 548 <getpid>
 14a:	fcc42783          	lw	a5,-52(s0)
 14e:	9fa9                	addw	a5,a5,a0
 150:	fcf42623          	sw	a5,-52(s0)
		printf("%d: %d\n",(int)getpid(),temp[1]);
 154:	00000097          	auipc	ra,0x0
 158:	3f4080e7          	jalr	1012(ra) # 548 <getpid>
 15c:	85aa                	mv	a1,a0
 15e:	fcc42603          	lw	a2,-52(s0)
 162:	8526                	mv	a0,s1
 164:	00000097          	auipc	ra,0x0
 168:	6f4080e7          	jalr	1780(ra) # 858 <printf>
		temp[0]--;
 16c:	fc842783          	lw	a5,-56(s0)
 170:	37fd                	addiw	a5,a5,-1
 172:	fcf42423          	sw	a5,-56(s0)
        if(write(fd[1],temp,2*sizeof(int))<0){
 176:	4621                	li	a2,8
 178:	fc840593          	addi	a1,s0,-56
 17c:	fdc42503          	lw	a0,-36(s0)
 180:	00000097          	auipc	ra,0x0
 184:	368080e7          	jalr	872(ra) # 4e8 <write>
 188:	0a054863          	bltz	a0,238 <main+0x204>
		if(temp[0]>1){
 18c:	fc842783          	lw	a5,-56(s0)
 190:	f8f946e3          	blt	s2,a5,11c <main+0xe8>
			goto x;
		}
		close(fd[0]);
 194:	fd842503          	lw	a0,-40(s0)
 198:	00000097          	auipc	ra,0x0
 19c:	358080e7          	jalr	856(ra) # 4f0 <close>
        close(fd[1]);
 1a0:	fdc42503          	lw	a0,-36(s0)
 1a4:	00000097          	auipc	ra,0x0
 1a8:	34c080e7          	jalr	844(ra) # 4f0 <close>
 1ac:	a0a5                	j	214 <main+0x1e0>
		printf("Error creating pipe.\n");
 1ae:	00001517          	auipc	a0,0x1
 1b2:	88a50513          	addi	a0,a0,-1910 # a38 <malloc+0x122>
 1b6:	00000097          	auipc	ra,0x0
 1ba:	6a2080e7          	jalr	1698(ra) # 858 <printf>
		exit(0);
 1be:	4501                	li	a0,0
 1c0:	00000097          	auipc	ra,0x0
 1c4:	308080e7          	jalr	776(ra) # 4c8 <exit>
        printf("Error writing to pipe.\n");
 1c8:	00001517          	auipc	a0,0x1
 1cc:	88850513          	addi	a0,a0,-1912 # a50 <malloc+0x13a>
 1d0:	00000097          	auipc	ra,0x0
 1d4:	688080e7          	jalr	1672(ra) # 858 <printf>
        exit(0);
 1d8:	4501                	li	a0,0
 1da:	00000097          	auipc	ra,0x0
 1de:	2ee080e7          	jalr	750(ra) # 4c8 <exit>
        printf("Error creating fork.\n");
 1e2:	00001517          	auipc	a0,0x1
 1e6:	88e50513          	addi	a0,a0,-1906 # a70 <malloc+0x15a>
 1ea:	00000097          	auipc	ra,0x0
 1ee:	66e080e7          	jalr	1646(ra) # 858 <printf>
        exit(0);
 1f2:	4501                	li	a0,0
 1f4:	00000097          	auipc	ra,0x0
 1f8:	2d4080e7          	jalr	724(ra) # 4c8 <exit>
		close(fd[0]);
 1fc:	fd842503          	lw	a0,-40(s0)
 200:	00000097          	auipc	ra,0x0
 204:	2f0080e7          	jalr	752(ra) # 4f0 <close>
        close(fd[1]);
 208:	fdc42503          	lw	a0,-36(s0)
 20c:	00000097          	auipc	ra,0x0
 210:	2e4080e7          	jalr	740(ra) # 4f0 <close>
    }
	exit(0);
 214:	4501                	li	a0,0
 216:	00000097          	auipc	ra,0x0
 21a:	2b2080e7          	jalr	690(ra) # 4c8 <exit>
            printf("Error reading from pipe.\n");
 21e:	00001517          	auipc	a0,0x1
 222:	86a50513          	addi	a0,a0,-1942 # a88 <malloc+0x172>
 226:	00000097          	auipc	ra,0x0
 22a:	632080e7          	jalr	1586(ra) # 858 <printf>
            exit(0);
 22e:	4501                	li	a0,0
 230:	00000097          	auipc	ra,0x0
 234:	298080e7          	jalr	664(ra) # 4c8 <exit>
            printf("Error writing to pipe.\n");
 238:	00001517          	auipc	a0,0x1
 23c:	81850513          	addi	a0,a0,-2024 # a50 <malloc+0x13a>
 240:	00000097          	auipc	ra,0x0
 244:	618080e7          	jalr	1560(ra) # 858 <printf>
            exit(0);
 248:	4501                	li	a0,0
 24a:	00000097          	auipc	ra,0x0
 24e:	27e080e7          	jalr	638(ra) # 4c8 <exit>

0000000000000252 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 252:	1141                	addi	sp,sp,-16
 254:	e422                	sd	s0,8(sp)
 256:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 258:	87aa                	mv	a5,a0
 25a:	0585                	addi	a1,a1,1
 25c:	0785                	addi	a5,a5,1
 25e:	fff5c703          	lbu	a4,-1(a1)
 262:	fee78fa3          	sb	a4,-1(a5)
 266:	fb75                	bnez	a4,25a <strcpy+0x8>
    ;
  return os;
}
 268:	6422                	ld	s0,8(sp)
 26a:	0141                	addi	sp,sp,16
 26c:	8082                	ret

000000000000026e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 26e:	1141                	addi	sp,sp,-16
 270:	e422                	sd	s0,8(sp)
 272:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 274:	00054783          	lbu	a5,0(a0)
 278:	cb91                	beqz	a5,28c <strcmp+0x1e>
 27a:	0005c703          	lbu	a4,0(a1)
 27e:	00f71763          	bne	a4,a5,28c <strcmp+0x1e>
    p++, q++;
 282:	0505                	addi	a0,a0,1
 284:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 286:	00054783          	lbu	a5,0(a0)
 28a:	fbe5                	bnez	a5,27a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 28c:	0005c503          	lbu	a0,0(a1)
}
 290:	40a7853b          	subw	a0,a5,a0
 294:	6422                	ld	s0,8(sp)
 296:	0141                	addi	sp,sp,16
 298:	8082                	ret

000000000000029a <strlen>:

uint
strlen(const char *s)
{
 29a:	1141                	addi	sp,sp,-16
 29c:	e422                	sd	s0,8(sp)
 29e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2a0:	00054783          	lbu	a5,0(a0)
 2a4:	cf91                	beqz	a5,2c0 <strlen+0x26>
 2a6:	0505                	addi	a0,a0,1
 2a8:	87aa                	mv	a5,a0
 2aa:	4685                	li	a3,1
 2ac:	9e89                	subw	a3,a3,a0
 2ae:	00f6853b          	addw	a0,a3,a5
 2b2:	0785                	addi	a5,a5,1
 2b4:	fff7c703          	lbu	a4,-1(a5)
 2b8:	fb7d                	bnez	a4,2ae <strlen+0x14>
    ;
  return n;
}
 2ba:	6422                	ld	s0,8(sp)
 2bc:	0141                	addi	sp,sp,16
 2be:	8082                	ret
  for(n = 0; s[n]; n++)
 2c0:	4501                	li	a0,0
 2c2:	bfe5                	j	2ba <strlen+0x20>

00000000000002c4 <memset>:

void*
memset(void *dst, int c, uint n)
{
 2c4:	1141                	addi	sp,sp,-16
 2c6:	e422                	sd	s0,8(sp)
 2c8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2ca:	ce09                	beqz	a2,2e4 <memset+0x20>
 2cc:	87aa                	mv	a5,a0
 2ce:	fff6071b          	addiw	a4,a2,-1
 2d2:	1702                	slli	a4,a4,0x20
 2d4:	9301                	srli	a4,a4,0x20
 2d6:	0705                	addi	a4,a4,1
 2d8:	972a                	add	a4,a4,a0
    cdst[i] = c;
 2da:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 2de:	0785                	addi	a5,a5,1
 2e0:	fee79de3          	bne	a5,a4,2da <memset+0x16>
  }
  return dst;
}
 2e4:	6422                	ld	s0,8(sp)
 2e6:	0141                	addi	sp,sp,16
 2e8:	8082                	ret

00000000000002ea <strchr>:

char*
strchr(const char *s, char c)
{
 2ea:	1141                	addi	sp,sp,-16
 2ec:	e422                	sd	s0,8(sp)
 2ee:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2f0:	00054783          	lbu	a5,0(a0)
 2f4:	cb99                	beqz	a5,30a <strchr+0x20>
    if(*s == c)
 2f6:	00f58763          	beq	a1,a5,304 <strchr+0x1a>
  for(; *s; s++)
 2fa:	0505                	addi	a0,a0,1
 2fc:	00054783          	lbu	a5,0(a0)
 300:	fbfd                	bnez	a5,2f6 <strchr+0xc>
      return (char*)s;
  return 0;
 302:	4501                	li	a0,0
}
 304:	6422                	ld	s0,8(sp)
 306:	0141                	addi	sp,sp,16
 308:	8082                	ret
  return 0;
 30a:	4501                	li	a0,0
 30c:	bfe5                	j	304 <strchr+0x1a>

000000000000030e <gets>:

char*
gets(char *buf, int max)
{
 30e:	711d                	addi	sp,sp,-96
 310:	ec86                	sd	ra,88(sp)
 312:	e8a2                	sd	s0,80(sp)
 314:	e4a6                	sd	s1,72(sp)
 316:	e0ca                	sd	s2,64(sp)
 318:	fc4e                	sd	s3,56(sp)
 31a:	f852                	sd	s4,48(sp)
 31c:	f456                	sd	s5,40(sp)
 31e:	f05a                	sd	s6,32(sp)
 320:	ec5e                	sd	s7,24(sp)
 322:	1080                	addi	s0,sp,96
 324:	8baa                	mv	s7,a0
 326:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 328:	892a                	mv	s2,a0
 32a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 32c:	4aa9                	li	s5,10
 32e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 330:	89a6                	mv	s3,s1
 332:	2485                	addiw	s1,s1,1
 334:	0344d863          	bge	s1,s4,364 <gets+0x56>
    cc = read(0, &c, 1);
 338:	4605                	li	a2,1
 33a:	faf40593          	addi	a1,s0,-81
 33e:	4501                	li	a0,0
 340:	00000097          	auipc	ra,0x0
 344:	1a0080e7          	jalr	416(ra) # 4e0 <read>
    if(cc < 1)
 348:	00a05e63          	blez	a0,364 <gets+0x56>
    buf[i++] = c;
 34c:	faf44783          	lbu	a5,-81(s0)
 350:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 354:	01578763          	beq	a5,s5,362 <gets+0x54>
 358:	0905                	addi	s2,s2,1
 35a:	fd679be3          	bne	a5,s6,330 <gets+0x22>
  for(i=0; i+1 < max; ){
 35e:	89a6                	mv	s3,s1
 360:	a011                	j	364 <gets+0x56>
 362:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 364:	99de                	add	s3,s3,s7
 366:	00098023          	sb	zero,0(s3)
  return buf;
}
 36a:	855e                	mv	a0,s7
 36c:	60e6                	ld	ra,88(sp)
 36e:	6446                	ld	s0,80(sp)
 370:	64a6                	ld	s1,72(sp)
 372:	6906                	ld	s2,64(sp)
 374:	79e2                	ld	s3,56(sp)
 376:	7a42                	ld	s4,48(sp)
 378:	7aa2                	ld	s5,40(sp)
 37a:	7b02                	ld	s6,32(sp)
 37c:	6be2                	ld	s7,24(sp)
 37e:	6125                	addi	sp,sp,96
 380:	8082                	ret

0000000000000382 <stat>:

int
stat(const char *n, struct stat *st)
{
 382:	1101                	addi	sp,sp,-32
 384:	ec06                	sd	ra,24(sp)
 386:	e822                	sd	s0,16(sp)
 388:	e426                	sd	s1,8(sp)
 38a:	e04a                	sd	s2,0(sp)
 38c:	1000                	addi	s0,sp,32
 38e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 390:	4581                	li	a1,0
 392:	00000097          	auipc	ra,0x0
 396:	176080e7          	jalr	374(ra) # 508 <open>
  if(fd < 0)
 39a:	02054563          	bltz	a0,3c4 <stat+0x42>
 39e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3a0:	85ca                	mv	a1,s2
 3a2:	00000097          	auipc	ra,0x0
 3a6:	17e080e7          	jalr	382(ra) # 520 <fstat>
 3aa:	892a                	mv	s2,a0
  close(fd);
 3ac:	8526                	mv	a0,s1
 3ae:	00000097          	auipc	ra,0x0
 3b2:	142080e7          	jalr	322(ra) # 4f0 <close>
  return r;
}
 3b6:	854a                	mv	a0,s2
 3b8:	60e2                	ld	ra,24(sp)
 3ba:	6442                	ld	s0,16(sp)
 3bc:	64a2                	ld	s1,8(sp)
 3be:	6902                	ld	s2,0(sp)
 3c0:	6105                	addi	sp,sp,32
 3c2:	8082                	ret
    return -1;
 3c4:	597d                	li	s2,-1
 3c6:	bfc5                	j	3b6 <stat+0x34>

00000000000003c8 <atoi>:

int
atoi(const char *s)
{
 3c8:	1141                	addi	sp,sp,-16
 3ca:	e422                	sd	s0,8(sp)
 3cc:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3ce:	00054603          	lbu	a2,0(a0)
 3d2:	fd06079b          	addiw	a5,a2,-48
 3d6:	0ff7f793          	andi	a5,a5,255
 3da:	4725                	li	a4,9
 3dc:	02f76963          	bltu	a4,a5,40e <atoi+0x46>
 3e0:	86aa                	mv	a3,a0
  n = 0;
 3e2:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 3e4:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 3e6:	0685                	addi	a3,a3,1
 3e8:	0025179b          	slliw	a5,a0,0x2
 3ec:	9fa9                	addw	a5,a5,a0
 3ee:	0017979b          	slliw	a5,a5,0x1
 3f2:	9fb1                	addw	a5,a5,a2
 3f4:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3f8:	0006c603          	lbu	a2,0(a3)
 3fc:	fd06071b          	addiw	a4,a2,-48
 400:	0ff77713          	andi	a4,a4,255
 404:	fee5f1e3          	bgeu	a1,a4,3e6 <atoi+0x1e>
  return n;
}
 408:	6422                	ld	s0,8(sp)
 40a:	0141                	addi	sp,sp,16
 40c:	8082                	ret
  n = 0;
 40e:	4501                	li	a0,0
 410:	bfe5                	j	408 <atoi+0x40>

0000000000000412 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 412:	1141                	addi	sp,sp,-16
 414:	e422                	sd	s0,8(sp)
 416:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 418:	02b57663          	bgeu	a0,a1,444 <memmove+0x32>
    while(n-- > 0)
 41c:	02c05163          	blez	a2,43e <memmove+0x2c>
 420:	fff6079b          	addiw	a5,a2,-1
 424:	1782                	slli	a5,a5,0x20
 426:	9381                	srli	a5,a5,0x20
 428:	0785                	addi	a5,a5,1
 42a:	97aa                	add	a5,a5,a0
  dst = vdst;
 42c:	872a                	mv	a4,a0
      *dst++ = *src++;
 42e:	0585                	addi	a1,a1,1
 430:	0705                	addi	a4,a4,1
 432:	fff5c683          	lbu	a3,-1(a1)
 436:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 43a:	fee79ae3          	bne	a5,a4,42e <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 43e:	6422                	ld	s0,8(sp)
 440:	0141                	addi	sp,sp,16
 442:	8082                	ret
    dst += n;
 444:	00c50733          	add	a4,a0,a2
    src += n;
 448:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 44a:	fec05ae3          	blez	a2,43e <memmove+0x2c>
 44e:	fff6079b          	addiw	a5,a2,-1
 452:	1782                	slli	a5,a5,0x20
 454:	9381                	srli	a5,a5,0x20
 456:	fff7c793          	not	a5,a5
 45a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 45c:	15fd                	addi	a1,a1,-1
 45e:	177d                	addi	a4,a4,-1
 460:	0005c683          	lbu	a3,0(a1)
 464:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 468:	fee79ae3          	bne	a5,a4,45c <memmove+0x4a>
 46c:	bfc9                	j	43e <memmove+0x2c>

000000000000046e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 46e:	1141                	addi	sp,sp,-16
 470:	e422                	sd	s0,8(sp)
 472:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 474:	ca05                	beqz	a2,4a4 <memcmp+0x36>
 476:	fff6069b          	addiw	a3,a2,-1
 47a:	1682                	slli	a3,a3,0x20
 47c:	9281                	srli	a3,a3,0x20
 47e:	0685                	addi	a3,a3,1
 480:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 482:	00054783          	lbu	a5,0(a0)
 486:	0005c703          	lbu	a4,0(a1)
 48a:	00e79863          	bne	a5,a4,49a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 48e:	0505                	addi	a0,a0,1
    p2++;
 490:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 492:	fed518e3          	bne	a0,a3,482 <memcmp+0x14>
  }
  return 0;
 496:	4501                	li	a0,0
 498:	a019                	j	49e <memcmp+0x30>
      return *p1 - *p2;
 49a:	40e7853b          	subw	a0,a5,a4
}
 49e:	6422                	ld	s0,8(sp)
 4a0:	0141                	addi	sp,sp,16
 4a2:	8082                	ret
  return 0;
 4a4:	4501                	li	a0,0
 4a6:	bfe5                	j	49e <memcmp+0x30>

00000000000004a8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4a8:	1141                	addi	sp,sp,-16
 4aa:	e406                	sd	ra,8(sp)
 4ac:	e022                	sd	s0,0(sp)
 4ae:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4b0:	00000097          	auipc	ra,0x0
 4b4:	f62080e7          	jalr	-158(ra) # 412 <memmove>
}
 4b8:	60a2                	ld	ra,8(sp)
 4ba:	6402                	ld	s0,0(sp)
 4bc:	0141                	addi	sp,sp,16
 4be:	8082                	ret

00000000000004c0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4c0:	4885                	li	a7,1
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 4c8:	4889                	li	a7,2
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 4d0:	488d                	li	a7,3
 ecall
 4d2:	00000073          	ecall
 ret
 4d6:	8082                	ret

00000000000004d8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4d8:	4891                	li	a7,4
 ecall
 4da:	00000073          	ecall
 ret
 4de:	8082                	ret

00000000000004e0 <read>:
.global read
read:
 li a7, SYS_read
 4e0:	4895                	li	a7,5
 ecall
 4e2:	00000073          	ecall
 ret
 4e6:	8082                	ret

00000000000004e8 <write>:
.global write
write:
 li a7, SYS_write
 4e8:	48c1                	li	a7,16
 ecall
 4ea:	00000073          	ecall
 ret
 4ee:	8082                	ret

00000000000004f0 <close>:
.global close
close:
 li a7, SYS_close
 4f0:	48d5                	li	a7,21
 ecall
 4f2:	00000073          	ecall
 ret
 4f6:	8082                	ret

00000000000004f8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4f8:	4899                	li	a7,6
 ecall
 4fa:	00000073          	ecall
 ret
 4fe:	8082                	ret

0000000000000500 <exec>:
.global exec
exec:
 li a7, SYS_exec
 500:	489d                	li	a7,7
 ecall
 502:	00000073          	ecall
 ret
 506:	8082                	ret

0000000000000508 <open>:
.global open
open:
 li a7, SYS_open
 508:	48bd                	li	a7,15
 ecall
 50a:	00000073          	ecall
 ret
 50e:	8082                	ret

0000000000000510 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 510:	48c5                	li	a7,17
 ecall
 512:	00000073          	ecall
 ret
 516:	8082                	ret

0000000000000518 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 518:	48c9                	li	a7,18
 ecall
 51a:	00000073          	ecall
 ret
 51e:	8082                	ret

0000000000000520 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 520:	48a1                	li	a7,8
 ecall
 522:	00000073          	ecall
 ret
 526:	8082                	ret

0000000000000528 <link>:
.global link
link:
 li a7, SYS_link
 528:	48cd                	li	a7,19
 ecall
 52a:	00000073          	ecall
 ret
 52e:	8082                	ret

0000000000000530 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 530:	48d1                	li	a7,20
 ecall
 532:	00000073          	ecall
 ret
 536:	8082                	ret

0000000000000538 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 538:	48a5                	li	a7,9
 ecall
 53a:	00000073          	ecall
 ret
 53e:	8082                	ret

0000000000000540 <dup>:
.global dup
dup:
 li a7, SYS_dup
 540:	48a9                	li	a7,10
 ecall
 542:	00000073          	ecall
 ret
 546:	8082                	ret

0000000000000548 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 548:	48ad                	li	a7,11
 ecall
 54a:	00000073          	ecall
 ret
 54e:	8082                	ret

0000000000000550 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 550:	48d9                	li	a7,22
 ecall
 552:	00000073          	ecall
 ret
 556:	8082                	ret

0000000000000558 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 558:	48b1                	li	a7,12
 ecall
 55a:	00000073          	ecall
 ret
 55e:	8082                	ret

0000000000000560 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 560:	48b5                	li	a7,13
 ecall
 562:	00000073          	ecall
 ret
 566:	8082                	ret

0000000000000568 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 568:	48b9                	li	a7,14
 ecall
 56a:	00000073          	ecall
 ret
 56e:	8082                	ret

0000000000000570 <yield>:
.global yield
yield:
 li a7, SYS_yield
 570:	48dd                	li	a7,23
 ecall
 572:	00000073          	ecall
 ret
 576:	8082                	ret

0000000000000578 <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 578:	48e1                	li	a7,24
 ecall
 57a:	00000073          	ecall
 ret
 57e:	8082                	ret

0000000000000580 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 580:	1101                	addi	sp,sp,-32
 582:	ec06                	sd	ra,24(sp)
 584:	e822                	sd	s0,16(sp)
 586:	1000                	addi	s0,sp,32
 588:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 58c:	4605                	li	a2,1
 58e:	fef40593          	addi	a1,s0,-17
 592:	00000097          	auipc	ra,0x0
 596:	f56080e7          	jalr	-170(ra) # 4e8 <write>
}
 59a:	60e2                	ld	ra,24(sp)
 59c:	6442                	ld	s0,16(sp)
 59e:	6105                	addi	sp,sp,32
 5a0:	8082                	ret

00000000000005a2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5a2:	7139                	addi	sp,sp,-64
 5a4:	fc06                	sd	ra,56(sp)
 5a6:	f822                	sd	s0,48(sp)
 5a8:	f426                	sd	s1,40(sp)
 5aa:	f04a                	sd	s2,32(sp)
 5ac:	ec4e                	sd	s3,24(sp)
 5ae:	0080                	addi	s0,sp,64
 5b0:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 5b2:	c299                	beqz	a3,5b8 <printint+0x16>
 5b4:	0805c863          	bltz	a1,644 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 5b8:	2581                	sext.w	a1,a1
  neg = 0;
 5ba:	4881                	li	a7,0
 5bc:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 5c0:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5c2:	2601                	sext.w	a2,a2
 5c4:	00000517          	auipc	a0,0x0
 5c8:	4ec50513          	addi	a0,a0,1260 # ab0 <digits>
 5cc:	883a                	mv	a6,a4
 5ce:	2705                	addiw	a4,a4,1
 5d0:	02c5f7bb          	remuw	a5,a1,a2
 5d4:	1782                	slli	a5,a5,0x20
 5d6:	9381                	srli	a5,a5,0x20
 5d8:	97aa                	add	a5,a5,a0
 5da:	0007c783          	lbu	a5,0(a5)
 5de:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5e2:	0005879b          	sext.w	a5,a1
 5e6:	02c5d5bb          	divuw	a1,a1,a2
 5ea:	0685                	addi	a3,a3,1
 5ec:	fec7f0e3          	bgeu	a5,a2,5cc <printint+0x2a>
  if(neg)
 5f0:	00088b63          	beqz	a7,606 <printint+0x64>
    buf[i++] = '-';
 5f4:	fd040793          	addi	a5,s0,-48
 5f8:	973e                	add	a4,a4,a5
 5fa:	02d00793          	li	a5,45
 5fe:	fef70823          	sb	a5,-16(a4)
 602:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 606:	02e05863          	blez	a4,636 <printint+0x94>
 60a:	fc040793          	addi	a5,s0,-64
 60e:	00e78933          	add	s2,a5,a4
 612:	fff78993          	addi	s3,a5,-1
 616:	99ba                	add	s3,s3,a4
 618:	377d                	addiw	a4,a4,-1
 61a:	1702                	slli	a4,a4,0x20
 61c:	9301                	srli	a4,a4,0x20
 61e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 622:	fff94583          	lbu	a1,-1(s2)
 626:	8526                	mv	a0,s1
 628:	00000097          	auipc	ra,0x0
 62c:	f58080e7          	jalr	-168(ra) # 580 <putc>
  while(--i >= 0)
 630:	197d                	addi	s2,s2,-1
 632:	ff3918e3          	bne	s2,s3,622 <printint+0x80>
}
 636:	70e2                	ld	ra,56(sp)
 638:	7442                	ld	s0,48(sp)
 63a:	74a2                	ld	s1,40(sp)
 63c:	7902                	ld	s2,32(sp)
 63e:	69e2                	ld	s3,24(sp)
 640:	6121                	addi	sp,sp,64
 642:	8082                	ret
    x = -xx;
 644:	40b005bb          	negw	a1,a1
    neg = 1;
 648:	4885                	li	a7,1
    x = -xx;
 64a:	bf8d                	j	5bc <printint+0x1a>

000000000000064c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 64c:	7119                	addi	sp,sp,-128
 64e:	fc86                	sd	ra,120(sp)
 650:	f8a2                	sd	s0,112(sp)
 652:	f4a6                	sd	s1,104(sp)
 654:	f0ca                	sd	s2,96(sp)
 656:	ecce                	sd	s3,88(sp)
 658:	e8d2                	sd	s4,80(sp)
 65a:	e4d6                	sd	s5,72(sp)
 65c:	e0da                	sd	s6,64(sp)
 65e:	fc5e                	sd	s7,56(sp)
 660:	f862                	sd	s8,48(sp)
 662:	f466                	sd	s9,40(sp)
 664:	f06a                	sd	s10,32(sp)
 666:	ec6e                	sd	s11,24(sp)
 668:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 66a:	0005c903          	lbu	s2,0(a1)
 66e:	18090f63          	beqz	s2,80c <vprintf+0x1c0>
 672:	8aaa                	mv	s5,a0
 674:	8b32                	mv	s6,a2
 676:	00158493          	addi	s1,a1,1
  state = 0;
 67a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 67c:	02500a13          	li	s4,37
      if(c == 'd'){
 680:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 684:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 688:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 68c:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 690:	00000b97          	auipc	s7,0x0
 694:	420b8b93          	addi	s7,s7,1056 # ab0 <digits>
 698:	a839                	j	6b6 <vprintf+0x6a>
        putc(fd, c);
 69a:	85ca                	mv	a1,s2
 69c:	8556                	mv	a0,s5
 69e:	00000097          	auipc	ra,0x0
 6a2:	ee2080e7          	jalr	-286(ra) # 580 <putc>
 6a6:	a019                	j	6ac <vprintf+0x60>
    } else if(state == '%'){
 6a8:	01498f63          	beq	s3,s4,6c6 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 6ac:	0485                	addi	s1,s1,1
 6ae:	fff4c903          	lbu	s2,-1(s1)
 6b2:	14090d63          	beqz	s2,80c <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 6b6:	0009079b          	sext.w	a5,s2
    if(state == 0){
 6ba:	fe0997e3          	bnez	s3,6a8 <vprintf+0x5c>
      if(c == '%'){
 6be:	fd479ee3          	bne	a5,s4,69a <vprintf+0x4e>
        state = '%';
 6c2:	89be                	mv	s3,a5
 6c4:	b7e5                	j	6ac <vprintf+0x60>
      if(c == 'd'){
 6c6:	05878063          	beq	a5,s8,706 <vprintf+0xba>
      } else if(c == 'l') {
 6ca:	05978c63          	beq	a5,s9,722 <vprintf+0xd6>
      } else if(c == 'x') {
 6ce:	07a78863          	beq	a5,s10,73e <vprintf+0xf2>
      } else if(c == 'p') {
 6d2:	09b78463          	beq	a5,s11,75a <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 6d6:	07300713          	li	a4,115
 6da:	0ce78663          	beq	a5,a4,7a6 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6de:	06300713          	li	a4,99
 6e2:	0ee78e63          	beq	a5,a4,7de <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 6e6:	11478863          	beq	a5,s4,7f6 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6ea:	85d2                	mv	a1,s4
 6ec:	8556                	mv	a0,s5
 6ee:	00000097          	auipc	ra,0x0
 6f2:	e92080e7          	jalr	-366(ra) # 580 <putc>
        putc(fd, c);
 6f6:	85ca                	mv	a1,s2
 6f8:	8556                	mv	a0,s5
 6fa:	00000097          	auipc	ra,0x0
 6fe:	e86080e7          	jalr	-378(ra) # 580 <putc>
      }
      state = 0;
 702:	4981                	li	s3,0
 704:	b765                	j	6ac <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 706:	008b0913          	addi	s2,s6,8
 70a:	4685                	li	a3,1
 70c:	4629                	li	a2,10
 70e:	000b2583          	lw	a1,0(s6)
 712:	8556                	mv	a0,s5
 714:	00000097          	auipc	ra,0x0
 718:	e8e080e7          	jalr	-370(ra) # 5a2 <printint>
 71c:	8b4a                	mv	s6,s2
      state = 0;
 71e:	4981                	li	s3,0
 720:	b771                	j	6ac <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 722:	008b0913          	addi	s2,s6,8
 726:	4681                	li	a3,0
 728:	4629                	li	a2,10
 72a:	000b2583          	lw	a1,0(s6)
 72e:	8556                	mv	a0,s5
 730:	00000097          	auipc	ra,0x0
 734:	e72080e7          	jalr	-398(ra) # 5a2 <printint>
 738:	8b4a                	mv	s6,s2
      state = 0;
 73a:	4981                	li	s3,0
 73c:	bf85                	j	6ac <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 73e:	008b0913          	addi	s2,s6,8
 742:	4681                	li	a3,0
 744:	4641                	li	a2,16
 746:	000b2583          	lw	a1,0(s6)
 74a:	8556                	mv	a0,s5
 74c:	00000097          	auipc	ra,0x0
 750:	e56080e7          	jalr	-426(ra) # 5a2 <printint>
 754:	8b4a                	mv	s6,s2
      state = 0;
 756:	4981                	li	s3,0
 758:	bf91                	j	6ac <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 75a:	008b0793          	addi	a5,s6,8
 75e:	f8f43423          	sd	a5,-120(s0)
 762:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 766:	03000593          	li	a1,48
 76a:	8556                	mv	a0,s5
 76c:	00000097          	auipc	ra,0x0
 770:	e14080e7          	jalr	-492(ra) # 580 <putc>
  putc(fd, 'x');
 774:	85ea                	mv	a1,s10
 776:	8556                	mv	a0,s5
 778:	00000097          	auipc	ra,0x0
 77c:	e08080e7          	jalr	-504(ra) # 580 <putc>
 780:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 782:	03c9d793          	srli	a5,s3,0x3c
 786:	97de                	add	a5,a5,s7
 788:	0007c583          	lbu	a1,0(a5)
 78c:	8556                	mv	a0,s5
 78e:	00000097          	auipc	ra,0x0
 792:	df2080e7          	jalr	-526(ra) # 580 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 796:	0992                	slli	s3,s3,0x4
 798:	397d                	addiw	s2,s2,-1
 79a:	fe0914e3          	bnez	s2,782 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 79e:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 7a2:	4981                	li	s3,0
 7a4:	b721                	j	6ac <vprintf+0x60>
        s = va_arg(ap, char*);
 7a6:	008b0993          	addi	s3,s6,8
 7aa:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 7ae:	02090163          	beqz	s2,7d0 <vprintf+0x184>
        while(*s != 0){
 7b2:	00094583          	lbu	a1,0(s2)
 7b6:	c9a1                	beqz	a1,806 <vprintf+0x1ba>
          putc(fd, *s);
 7b8:	8556                	mv	a0,s5
 7ba:	00000097          	auipc	ra,0x0
 7be:	dc6080e7          	jalr	-570(ra) # 580 <putc>
          s++;
 7c2:	0905                	addi	s2,s2,1
        while(*s != 0){
 7c4:	00094583          	lbu	a1,0(s2)
 7c8:	f9e5                	bnez	a1,7b8 <vprintf+0x16c>
        s = va_arg(ap, char*);
 7ca:	8b4e                	mv	s6,s3
      state = 0;
 7cc:	4981                	li	s3,0
 7ce:	bdf9                	j	6ac <vprintf+0x60>
          s = "(null)";
 7d0:	00000917          	auipc	s2,0x0
 7d4:	2d890913          	addi	s2,s2,728 # aa8 <malloc+0x192>
        while(*s != 0){
 7d8:	02800593          	li	a1,40
 7dc:	bff1                	j	7b8 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 7de:	008b0913          	addi	s2,s6,8
 7e2:	000b4583          	lbu	a1,0(s6)
 7e6:	8556                	mv	a0,s5
 7e8:	00000097          	auipc	ra,0x0
 7ec:	d98080e7          	jalr	-616(ra) # 580 <putc>
 7f0:	8b4a                	mv	s6,s2
      state = 0;
 7f2:	4981                	li	s3,0
 7f4:	bd65                	j	6ac <vprintf+0x60>
        putc(fd, c);
 7f6:	85d2                	mv	a1,s4
 7f8:	8556                	mv	a0,s5
 7fa:	00000097          	auipc	ra,0x0
 7fe:	d86080e7          	jalr	-634(ra) # 580 <putc>
      state = 0;
 802:	4981                	li	s3,0
 804:	b565                	j	6ac <vprintf+0x60>
        s = va_arg(ap, char*);
 806:	8b4e                	mv	s6,s3
      state = 0;
 808:	4981                	li	s3,0
 80a:	b54d                	j	6ac <vprintf+0x60>
    }
  }
}
 80c:	70e6                	ld	ra,120(sp)
 80e:	7446                	ld	s0,112(sp)
 810:	74a6                	ld	s1,104(sp)
 812:	7906                	ld	s2,96(sp)
 814:	69e6                	ld	s3,88(sp)
 816:	6a46                	ld	s4,80(sp)
 818:	6aa6                	ld	s5,72(sp)
 81a:	6b06                	ld	s6,64(sp)
 81c:	7be2                	ld	s7,56(sp)
 81e:	7c42                	ld	s8,48(sp)
 820:	7ca2                	ld	s9,40(sp)
 822:	7d02                	ld	s10,32(sp)
 824:	6de2                	ld	s11,24(sp)
 826:	6109                	addi	sp,sp,128
 828:	8082                	ret

000000000000082a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 82a:	715d                	addi	sp,sp,-80
 82c:	ec06                	sd	ra,24(sp)
 82e:	e822                	sd	s0,16(sp)
 830:	1000                	addi	s0,sp,32
 832:	e010                	sd	a2,0(s0)
 834:	e414                	sd	a3,8(s0)
 836:	e818                	sd	a4,16(s0)
 838:	ec1c                	sd	a5,24(s0)
 83a:	03043023          	sd	a6,32(s0)
 83e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 842:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 846:	8622                	mv	a2,s0
 848:	00000097          	auipc	ra,0x0
 84c:	e04080e7          	jalr	-508(ra) # 64c <vprintf>
}
 850:	60e2                	ld	ra,24(sp)
 852:	6442                	ld	s0,16(sp)
 854:	6161                	addi	sp,sp,80
 856:	8082                	ret

0000000000000858 <printf>:

void
printf(const char *fmt, ...)
{
 858:	711d                	addi	sp,sp,-96
 85a:	ec06                	sd	ra,24(sp)
 85c:	e822                	sd	s0,16(sp)
 85e:	1000                	addi	s0,sp,32
 860:	e40c                	sd	a1,8(s0)
 862:	e810                	sd	a2,16(s0)
 864:	ec14                	sd	a3,24(s0)
 866:	f018                	sd	a4,32(s0)
 868:	f41c                	sd	a5,40(s0)
 86a:	03043823          	sd	a6,48(s0)
 86e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 872:	00840613          	addi	a2,s0,8
 876:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 87a:	85aa                	mv	a1,a0
 87c:	4505                	li	a0,1
 87e:	00000097          	auipc	ra,0x0
 882:	dce080e7          	jalr	-562(ra) # 64c <vprintf>
}
 886:	60e2                	ld	ra,24(sp)
 888:	6442                	ld	s0,16(sp)
 88a:	6125                	addi	sp,sp,96
 88c:	8082                	ret

000000000000088e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 88e:	1141                	addi	sp,sp,-16
 890:	e422                	sd	s0,8(sp)
 892:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 894:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 898:	00000797          	auipc	a5,0x0
 89c:	2307b783          	ld	a5,560(a5) # ac8 <freep>
 8a0:	a805                	j	8d0 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 8a2:	4618                	lw	a4,8(a2)
 8a4:	9db9                	addw	a1,a1,a4
 8a6:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8aa:	6398                	ld	a4,0(a5)
 8ac:	6318                	ld	a4,0(a4)
 8ae:	fee53823          	sd	a4,-16(a0)
 8b2:	a091                	j	8f6 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8b4:	ff852703          	lw	a4,-8(a0)
 8b8:	9e39                	addw	a2,a2,a4
 8ba:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 8bc:	ff053703          	ld	a4,-16(a0)
 8c0:	e398                	sd	a4,0(a5)
 8c2:	a099                	j	908 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8c4:	6398                	ld	a4,0(a5)
 8c6:	00e7e463          	bltu	a5,a4,8ce <free+0x40>
 8ca:	00e6ea63          	bltu	a3,a4,8de <free+0x50>
{
 8ce:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8d0:	fed7fae3          	bgeu	a5,a3,8c4 <free+0x36>
 8d4:	6398                	ld	a4,0(a5)
 8d6:	00e6e463          	bltu	a3,a4,8de <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8da:	fee7eae3          	bltu	a5,a4,8ce <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 8de:	ff852583          	lw	a1,-8(a0)
 8e2:	6390                	ld	a2,0(a5)
 8e4:	02059713          	slli	a4,a1,0x20
 8e8:	9301                	srli	a4,a4,0x20
 8ea:	0712                	slli	a4,a4,0x4
 8ec:	9736                	add	a4,a4,a3
 8ee:	fae60ae3          	beq	a2,a4,8a2 <free+0x14>
    bp->s.ptr = p->s.ptr;
 8f2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8f6:	4790                	lw	a2,8(a5)
 8f8:	02061713          	slli	a4,a2,0x20
 8fc:	9301                	srli	a4,a4,0x20
 8fe:	0712                	slli	a4,a4,0x4
 900:	973e                	add	a4,a4,a5
 902:	fae689e3          	beq	a3,a4,8b4 <free+0x26>
  } else
    p->s.ptr = bp;
 906:	e394                	sd	a3,0(a5)
  freep = p;
 908:	00000717          	auipc	a4,0x0
 90c:	1cf73023          	sd	a5,448(a4) # ac8 <freep>
}
 910:	6422                	ld	s0,8(sp)
 912:	0141                	addi	sp,sp,16
 914:	8082                	ret

0000000000000916 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 916:	7139                	addi	sp,sp,-64
 918:	fc06                	sd	ra,56(sp)
 91a:	f822                	sd	s0,48(sp)
 91c:	f426                	sd	s1,40(sp)
 91e:	f04a                	sd	s2,32(sp)
 920:	ec4e                	sd	s3,24(sp)
 922:	e852                	sd	s4,16(sp)
 924:	e456                	sd	s5,8(sp)
 926:	e05a                	sd	s6,0(sp)
 928:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 92a:	02051493          	slli	s1,a0,0x20
 92e:	9081                	srli	s1,s1,0x20
 930:	04bd                	addi	s1,s1,15
 932:	8091                	srli	s1,s1,0x4
 934:	0014899b          	addiw	s3,s1,1
 938:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 93a:	00000517          	auipc	a0,0x0
 93e:	18e53503          	ld	a0,398(a0) # ac8 <freep>
 942:	c515                	beqz	a0,96e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 944:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 946:	4798                	lw	a4,8(a5)
 948:	02977f63          	bgeu	a4,s1,986 <malloc+0x70>
 94c:	8a4e                	mv	s4,s3
 94e:	0009871b          	sext.w	a4,s3
 952:	6685                	lui	a3,0x1
 954:	00d77363          	bgeu	a4,a3,95a <malloc+0x44>
 958:	6a05                	lui	s4,0x1
 95a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 95e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 962:	00000917          	auipc	s2,0x0
 966:	16690913          	addi	s2,s2,358 # ac8 <freep>
  if(p == (char*)-1)
 96a:	5afd                	li	s5,-1
 96c:	a88d                	j	9de <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 96e:	00000797          	auipc	a5,0x0
 972:	16278793          	addi	a5,a5,354 # ad0 <base>
 976:	00000717          	auipc	a4,0x0
 97a:	14f73923          	sd	a5,338(a4) # ac8 <freep>
 97e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 980:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 984:	b7e1                	j	94c <malloc+0x36>
      if(p->s.size == nunits)
 986:	02e48b63          	beq	s1,a4,9bc <malloc+0xa6>
        p->s.size -= nunits;
 98a:	4137073b          	subw	a4,a4,s3
 98e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 990:	1702                	slli	a4,a4,0x20
 992:	9301                	srli	a4,a4,0x20
 994:	0712                	slli	a4,a4,0x4
 996:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 998:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 99c:	00000717          	auipc	a4,0x0
 9a0:	12a73623          	sd	a0,300(a4) # ac8 <freep>
      return (void*)(p + 1);
 9a4:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 9a8:	70e2                	ld	ra,56(sp)
 9aa:	7442                	ld	s0,48(sp)
 9ac:	74a2                	ld	s1,40(sp)
 9ae:	7902                	ld	s2,32(sp)
 9b0:	69e2                	ld	s3,24(sp)
 9b2:	6a42                	ld	s4,16(sp)
 9b4:	6aa2                	ld	s5,8(sp)
 9b6:	6b02                	ld	s6,0(sp)
 9b8:	6121                	addi	sp,sp,64
 9ba:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 9bc:	6398                	ld	a4,0(a5)
 9be:	e118                	sd	a4,0(a0)
 9c0:	bff1                	j	99c <malloc+0x86>
  hp->s.size = nu;
 9c2:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9c6:	0541                	addi	a0,a0,16
 9c8:	00000097          	auipc	ra,0x0
 9cc:	ec6080e7          	jalr	-314(ra) # 88e <free>
  return freep;
 9d0:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9d4:	d971                	beqz	a0,9a8 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9d6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9d8:	4798                	lw	a4,8(a5)
 9da:	fa9776e3          	bgeu	a4,s1,986 <malloc+0x70>
    if(p == freep)
 9de:	00093703          	ld	a4,0(s2)
 9e2:	853e                	mv	a0,a5
 9e4:	fef719e3          	bne	a4,a5,9d6 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 9e8:	8552                	mv	a0,s4
 9ea:	00000097          	auipc	ra,0x0
 9ee:	b6e080e7          	jalr	-1170(ra) # 558 <sbrk>
  if(p == (char*)-1)
 9f2:	fd5518e3          	bne	a0,s5,9c2 <malloc+0xac>
        return 0;
 9f6:	4501                	li	a0,0
 9f8:	bf45                	j	9a8 <malloc+0x92>
