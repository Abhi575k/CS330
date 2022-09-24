
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
  68:	9ac50513          	addi	a0,a0,-1620 # a10 <malloc+0xea>
  6c:	00000097          	auipc	ra,0x0
  70:	7fc080e7          	jalr	2044(ra) # 868 <printf>
        exit(0);
  74:	4501                	li	a0,0
  76:	00000097          	auipc	ra,0x0
  7a:	452080e7          	jalr	1106(ra) # 4c8 <exit>
        printf("Usage: pipeline <number_of_processes(n)> <value(x)>\n");
  7e:	00001517          	auipc	a0,0x1
  82:	99250513          	addi	a0,a0,-1646 # a10 <malloc+0xea>
  86:	00000097          	auipc	ra,0x0
  8a:	7e2080e7          	jalr	2018(ra) # 868 <printf>
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
 106:	97650513          	addi	a0,a0,-1674 # a78 <malloc+0x152>
 10a:	00000097          	auipc	ra,0x0
 10e:	75e080e7          	jalr	1886(ra) # 868 <printf>
        if(read(fd[0],temp,2*sizeof(int))<0){
            printf("Error reading from pipe.\n");
            exit(0);
        }
		temp[1]+=(int)getpid();
		printf("%d: %d\n",(int)getpid(),temp[1]);
 112:	00001497          	auipc	s1,0x1
 116:	96648493          	addi	s1,s1,-1690 # a78 <malloc+0x152>
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
 168:	704080e7          	jalr	1796(ra) # 868 <printf>
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
 1b2:	89a50513          	addi	a0,a0,-1894 # a48 <malloc+0x122>
 1b6:	00000097          	auipc	ra,0x0
 1ba:	6b2080e7          	jalr	1714(ra) # 868 <printf>
		exit(0);
 1be:	4501                	li	a0,0
 1c0:	00000097          	auipc	ra,0x0
 1c4:	308080e7          	jalr	776(ra) # 4c8 <exit>
        printf("Error writing to pipe.\n");
 1c8:	00001517          	auipc	a0,0x1
 1cc:	89850513          	addi	a0,a0,-1896 # a60 <malloc+0x13a>
 1d0:	00000097          	auipc	ra,0x0
 1d4:	698080e7          	jalr	1688(ra) # 868 <printf>
        exit(0);
 1d8:	4501                	li	a0,0
 1da:	00000097          	auipc	ra,0x0
 1de:	2ee080e7          	jalr	750(ra) # 4c8 <exit>
        printf("Error creating fork.\n");
 1e2:	00001517          	auipc	a0,0x1
 1e6:	89e50513          	addi	a0,a0,-1890 # a80 <malloc+0x15a>
 1ea:	00000097          	auipc	ra,0x0
 1ee:	67e080e7          	jalr	1662(ra) # 868 <printf>
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
 222:	87a50513          	addi	a0,a0,-1926 # a98 <malloc+0x172>
 226:	00000097          	auipc	ra,0x0
 22a:	642080e7          	jalr	1602(ra) # 868 <printf>
            exit(0);
 22e:	4501                	li	a0,0
 230:	00000097          	auipc	ra,0x0
 234:	298080e7          	jalr	664(ra) # 4c8 <exit>
            printf("Error writing to pipe.\n");
 238:	00001517          	auipc	a0,0x1
 23c:	82850513          	addi	a0,a0,-2008 # a60 <malloc+0x13a>
 240:	00000097          	auipc	ra,0x0
 244:	628080e7          	jalr	1576(ra) # 868 <printf>
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

0000000000000580 <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 580:	48e5                	li	a7,25
 ecall
 582:	00000073          	ecall
 ret
 586:	8082                	ret

0000000000000588 <cps>:
.global cps
cps:
 li a7, SYS_cps
 588:	48e9                	li	a7,26
 ecall
 58a:	00000073          	ecall
 ret
 58e:	8082                	ret

0000000000000590 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 590:	1101                	addi	sp,sp,-32
 592:	ec06                	sd	ra,24(sp)
 594:	e822                	sd	s0,16(sp)
 596:	1000                	addi	s0,sp,32
 598:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 59c:	4605                	li	a2,1
 59e:	fef40593          	addi	a1,s0,-17
 5a2:	00000097          	auipc	ra,0x0
 5a6:	f46080e7          	jalr	-186(ra) # 4e8 <write>
}
 5aa:	60e2                	ld	ra,24(sp)
 5ac:	6442                	ld	s0,16(sp)
 5ae:	6105                	addi	sp,sp,32
 5b0:	8082                	ret

00000000000005b2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5b2:	7139                	addi	sp,sp,-64
 5b4:	fc06                	sd	ra,56(sp)
 5b6:	f822                	sd	s0,48(sp)
 5b8:	f426                	sd	s1,40(sp)
 5ba:	f04a                	sd	s2,32(sp)
 5bc:	ec4e                	sd	s3,24(sp)
 5be:	0080                	addi	s0,sp,64
 5c0:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 5c2:	c299                	beqz	a3,5c8 <printint+0x16>
 5c4:	0805c863          	bltz	a1,654 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 5c8:	2581                	sext.w	a1,a1
  neg = 0;
 5ca:	4881                	li	a7,0
 5cc:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 5d0:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5d2:	2601                	sext.w	a2,a2
 5d4:	00000517          	auipc	a0,0x0
 5d8:	4ec50513          	addi	a0,a0,1260 # ac0 <digits>
 5dc:	883a                	mv	a6,a4
 5de:	2705                	addiw	a4,a4,1
 5e0:	02c5f7bb          	remuw	a5,a1,a2
 5e4:	1782                	slli	a5,a5,0x20
 5e6:	9381                	srli	a5,a5,0x20
 5e8:	97aa                	add	a5,a5,a0
 5ea:	0007c783          	lbu	a5,0(a5)
 5ee:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5f2:	0005879b          	sext.w	a5,a1
 5f6:	02c5d5bb          	divuw	a1,a1,a2
 5fa:	0685                	addi	a3,a3,1
 5fc:	fec7f0e3          	bgeu	a5,a2,5dc <printint+0x2a>
  if(neg)
 600:	00088b63          	beqz	a7,616 <printint+0x64>
    buf[i++] = '-';
 604:	fd040793          	addi	a5,s0,-48
 608:	973e                	add	a4,a4,a5
 60a:	02d00793          	li	a5,45
 60e:	fef70823          	sb	a5,-16(a4)
 612:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 616:	02e05863          	blez	a4,646 <printint+0x94>
 61a:	fc040793          	addi	a5,s0,-64
 61e:	00e78933          	add	s2,a5,a4
 622:	fff78993          	addi	s3,a5,-1
 626:	99ba                	add	s3,s3,a4
 628:	377d                	addiw	a4,a4,-1
 62a:	1702                	slli	a4,a4,0x20
 62c:	9301                	srli	a4,a4,0x20
 62e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 632:	fff94583          	lbu	a1,-1(s2)
 636:	8526                	mv	a0,s1
 638:	00000097          	auipc	ra,0x0
 63c:	f58080e7          	jalr	-168(ra) # 590 <putc>
  while(--i >= 0)
 640:	197d                	addi	s2,s2,-1
 642:	ff3918e3          	bne	s2,s3,632 <printint+0x80>
}
 646:	70e2                	ld	ra,56(sp)
 648:	7442                	ld	s0,48(sp)
 64a:	74a2                	ld	s1,40(sp)
 64c:	7902                	ld	s2,32(sp)
 64e:	69e2                	ld	s3,24(sp)
 650:	6121                	addi	sp,sp,64
 652:	8082                	ret
    x = -xx;
 654:	40b005bb          	negw	a1,a1
    neg = 1;
 658:	4885                	li	a7,1
    x = -xx;
 65a:	bf8d                	j	5cc <printint+0x1a>

000000000000065c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 65c:	7119                	addi	sp,sp,-128
 65e:	fc86                	sd	ra,120(sp)
 660:	f8a2                	sd	s0,112(sp)
 662:	f4a6                	sd	s1,104(sp)
 664:	f0ca                	sd	s2,96(sp)
 666:	ecce                	sd	s3,88(sp)
 668:	e8d2                	sd	s4,80(sp)
 66a:	e4d6                	sd	s5,72(sp)
 66c:	e0da                	sd	s6,64(sp)
 66e:	fc5e                	sd	s7,56(sp)
 670:	f862                	sd	s8,48(sp)
 672:	f466                	sd	s9,40(sp)
 674:	f06a                	sd	s10,32(sp)
 676:	ec6e                	sd	s11,24(sp)
 678:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 67a:	0005c903          	lbu	s2,0(a1)
 67e:	18090f63          	beqz	s2,81c <vprintf+0x1c0>
 682:	8aaa                	mv	s5,a0
 684:	8b32                	mv	s6,a2
 686:	00158493          	addi	s1,a1,1
  state = 0;
 68a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 68c:	02500a13          	li	s4,37
      if(c == 'd'){
 690:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 694:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 698:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 69c:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6a0:	00000b97          	auipc	s7,0x0
 6a4:	420b8b93          	addi	s7,s7,1056 # ac0 <digits>
 6a8:	a839                	j	6c6 <vprintf+0x6a>
        putc(fd, c);
 6aa:	85ca                	mv	a1,s2
 6ac:	8556                	mv	a0,s5
 6ae:	00000097          	auipc	ra,0x0
 6b2:	ee2080e7          	jalr	-286(ra) # 590 <putc>
 6b6:	a019                	j	6bc <vprintf+0x60>
    } else if(state == '%'){
 6b8:	01498f63          	beq	s3,s4,6d6 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 6bc:	0485                	addi	s1,s1,1
 6be:	fff4c903          	lbu	s2,-1(s1)
 6c2:	14090d63          	beqz	s2,81c <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 6c6:	0009079b          	sext.w	a5,s2
    if(state == 0){
 6ca:	fe0997e3          	bnez	s3,6b8 <vprintf+0x5c>
      if(c == '%'){
 6ce:	fd479ee3          	bne	a5,s4,6aa <vprintf+0x4e>
        state = '%';
 6d2:	89be                	mv	s3,a5
 6d4:	b7e5                	j	6bc <vprintf+0x60>
      if(c == 'd'){
 6d6:	05878063          	beq	a5,s8,716 <vprintf+0xba>
      } else if(c == 'l') {
 6da:	05978c63          	beq	a5,s9,732 <vprintf+0xd6>
      } else if(c == 'x') {
 6de:	07a78863          	beq	a5,s10,74e <vprintf+0xf2>
      } else if(c == 'p') {
 6e2:	09b78463          	beq	a5,s11,76a <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 6e6:	07300713          	li	a4,115
 6ea:	0ce78663          	beq	a5,a4,7b6 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6ee:	06300713          	li	a4,99
 6f2:	0ee78e63          	beq	a5,a4,7ee <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 6f6:	11478863          	beq	a5,s4,806 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6fa:	85d2                	mv	a1,s4
 6fc:	8556                	mv	a0,s5
 6fe:	00000097          	auipc	ra,0x0
 702:	e92080e7          	jalr	-366(ra) # 590 <putc>
        putc(fd, c);
 706:	85ca                	mv	a1,s2
 708:	8556                	mv	a0,s5
 70a:	00000097          	auipc	ra,0x0
 70e:	e86080e7          	jalr	-378(ra) # 590 <putc>
      }
      state = 0;
 712:	4981                	li	s3,0
 714:	b765                	j	6bc <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 716:	008b0913          	addi	s2,s6,8
 71a:	4685                	li	a3,1
 71c:	4629                	li	a2,10
 71e:	000b2583          	lw	a1,0(s6)
 722:	8556                	mv	a0,s5
 724:	00000097          	auipc	ra,0x0
 728:	e8e080e7          	jalr	-370(ra) # 5b2 <printint>
 72c:	8b4a                	mv	s6,s2
      state = 0;
 72e:	4981                	li	s3,0
 730:	b771                	j	6bc <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 732:	008b0913          	addi	s2,s6,8
 736:	4681                	li	a3,0
 738:	4629                	li	a2,10
 73a:	000b2583          	lw	a1,0(s6)
 73e:	8556                	mv	a0,s5
 740:	00000097          	auipc	ra,0x0
 744:	e72080e7          	jalr	-398(ra) # 5b2 <printint>
 748:	8b4a                	mv	s6,s2
      state = 0;
 74a:	4981                	li	s3,0
 74c:	bf85                	j	6bc <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 74e:	008b0913          	addi	s2,s6,8
 752:	4681                	li	a3,0
 754:	4641                	li	a2,16
 756:	000b2583          	lw	a1,0(s6)
 75a:	8556                	mv	a0,s5
 75c:	00000097          	auipc	ra,0x0
 760:	e56080e7          	jalr	-426(ra) # 5b2 <printint>
 764:	8b4a                	mv	s6,s2
      state = 0;
 766:	4981                	li	s3,0
 768:	bf91                	j	6bc <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 76a:	008b0793          	addi	a5,s6,8
 76e:	f8f43423          	sd	a5,-120(s0)
 772:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 776:	03000593          	li	a1,48
 77a:	8556                	mv	a0,s5
 77c:	00000097          	auipc	ra,0x0
 780:	e14080e7          	jalr	-492(ra) # 590 <putc>
  putc(fd, 'x');
 784:	85ea                	mv	a1,s10
 786:	8556                	mv	a0,s5
 788:	00000097          	auipc	ra,0x0
 78c:	e08080e7          	jalr	-504(ra) # 590 <putc>
 790:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 792:	03c9d793          	srli	a5,s3,0x3c
 796:	97de                	add	a5,a5,s7
 798:	0007c583          	lbu	a1,0(a5)
 79c:	8556                	mv	a0,s5
 79e:	00000097          	auipc	ra,0x0
 7a2:	df2080e7          	jalr	-526(ra) # 590 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7a6:	0992                	slli	s3,s3,0x4
 7a8:	397d                	addiw	s2,s2,-1
 7aa:	fe0914e3          	bnez	s2,792 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 7ae:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 7b2:	4981                	li	s3,0
 7b4:	b721                	j	6bc <vprintf+0x60>
        s = va_arg(ap, char*);
 7b6:	008b0993          	addi	s3,s6,8
 7ba:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 7be:	02090163          	beqz	s2,7e0 <vprintf+0x184>
        while(*s != 0){
 7c2:	00094583          	lbu	a1,0(s2)
 7c6:	c9a1                	beqz	a1,816 <vprintf+0x1ba>
          putc(fd, *s);
 7c8:	8556                	mv	a0,s5
 7ca:	00000097          	auipc	ra,0x0
 7ce:	dc6080e7          	jalr	-570(ra) # 590 <putc>
          s++;
 7d2:	0905                	addi	s2,s2,1
        while(*s != 0){
 7d4:	00094583          	lbu	a1,0(s2)
 7d8:	f9e5                	bnez	a1,7c8 <vprintf+0x16c>
        s = va_arg(ap, char*);
 7da:	8b4e                	mv	s6,s3
      state = 0;
 7dc:	4981                	li	s3,0
 7de:	bdf9                	j	6bc <vprintf+0x60>
          s = "(null)";
 7e0:	00000917          	auipc	s2,0x0
 7e4:	2d890913          	addi	s2,s2,728 # ab8 <malloc+0x192>
        while(*s != 0){
 7e8:	02800593          	li	a1,40
 7ec:	bff1                	j	7c8 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 7ee:	008b0913          	addi	s2,s6,8
 7f2:	000b4583          	lbu	a1,0(s6)
 7f6:	8556                	mv	a0,s5
 7f8:	00000097          	auipc	ra,0x0
 7fc:	d98080e7          	jalr	-616(ra) # 590 <putc>
 800:	8b4a                	mv	s6,s2
      state = 0;
 802:	4981                	li	s3,0
 804:	bd65                	j	6bc <vprintf+0x60>
        putc(fd, c);
 806:	85d2                	mv	a1,s4
 808:	8556                	mv	a0,s5
 80a:	00000097          	auipc	ra,0x0
 80e:	d86080e7          	jalr	-634(ra) # 590 <putc>
      state = 0;
 812:	4981                	li	s3,0
 814:	b565                	j	6bc <vprintf+0x60>
        s = va_arg(ap, char*);
 816:	8b4e                	mv	s6,s3
      state = 0;
 818:	4981                	li	s3,0
 81a:	b54d                	j	6bc <vprintf+0x60>
    }
  }
}
 81c:	70e6                	ld	ra,120(sp)
 81e:	7446                	ld	s0,112(sp)
 820:	74a6                	ld	s1,104(sp)
 822:	7906                	ld	s2,96(sp)
 824:	69e6                	ld	s3,88(sp)
 826:	6a46                	ld	s4,80(sp)
 828:	6aa6                	ld	s5,72(sp)
 82a:	6b06                	ld	s6,64(sp)
 82c:	7be2                	ld	s7,56(sp)
 82e:	7c42                	ld	s8,48(sp)
 830:	7ca2                	ld	s9,40(sp)
 832:	7d02                	ld	s10,32(sp)
 834:	6de2                	ld	s11,24(sp)
 836:	6109                	addi	sp,sp,128
 838:	8082                	ret

000000000000083a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 83a:	715d                	addi	sp,sp,-80
 83c:	ec06                	sd	ra,24(sp)
 83e:	e822                	sd	s0,16(sp)
 840:	1000                	addi	s0,sp,32
 842:	e010                	sd	a2,0(s0)
 844:	e414                	sd	a3,8(s0)
 846:	e818                	sd	a4,16(s0)
 848:	ec1c                	sd	a5,24(s0)
 84a:	03043023          	sd	a6,32(s0)
 84e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 852:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 856:	8622                	mv	a2,s0
 858:	00000097          	auipc	ra,0x0
 85c:	e04080e7          	jalr	-508(ra) # 65c <vprintf>
}
 860:	60e2                	ld	ra,24(sp)
 862:	6442                	ld	s0,16(sp)
 864:	6161                	addi	sp,sp,80
 866:	8082                	ret

0000000000000868 <printf>:

void
printf(const char *fmt, ...)
{
 868:	711d                	addi	sp,sp,-96
 86a:	ec06                	sd	ra,24(sp)
 86c:	e822                	sd	s0,16(sp)
 86e:	1000                	addi	s0,sp,32
 870:	e40c                	sd	a1,8(s0)
 872:	e810                	sd	a2,16(s0)
 874:	ec14                	sd	a3,24(s0)
 876:	f018                	sd	a4,32(s0)
 878:	f41c                	sd	a5,40(s0)
 87a:	03043823          	sd	a6,48(s0)
 87e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 882:	00840613          	addi	a2,s0,8
 886:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 88a:	85aa                	mv	a1,a0
 88c:	4505                	li	a0,1
 88e:	00000097          	auipc	ra,0x0
 892:	dce080e7          	jalr	-562(ra) # 65c <vprintf>
}
 896:	60e2                	ld	ra,24(sp)
 898:	6442                	ld	s0,16(sp)
 89a:	6125                	addi	sp,sp,96
 89c:	8082                	ret

000000000000089e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 89e:	1141                	addi	sp,sp,-16
 8a0:	e422                	sd	s0,8(sp)
 8a2:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8a4:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8a8:	00000797          	auipc	a5,0x0
 8ac:	2307b783          	ld	a5,560(a5) # ad8 <freep>
 8b0:	a805                	j	8e0 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 8b2:	4618                	lw	a4,8(a2)
 8b4:	9db9                	addw	a1,a1,a4
 8b6:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8ba:	6398                	ld	a4,0(a5)
 8bc:	6318                	ld	a4,0(a4)
 8be:	fee53823          	sd	a4,-16(a0)
 8c2:	a091                	j	906 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8c4:	ff852703          	lw	a4,-8(a0)
 8c8:	9e39                	addw	a2,a2,a4
 8ca:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 8cc:	ff053703          	ld	a4,-16(a0)
 8d0:	e398                	sd	a4,0(a5)
 8d2:	a099                	j	918 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8d4:	6398                	ld	a4,0(a5)
 8d6:	00e7e463          	bltu	a5,a4,8de <free+0x40>
 8da:	00e6ea63          	bltu	a3,a4,8ee <free+0x50>
{
 8de:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8e0:	fed7fae3          	bgeu	a5,a3,8d4 <free+0x36>
 8e4:	6398                	ld	a4,0(a5)
 8e6:	00e6e463          	bltu	a3,a4,8ee <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8ea:	fee7eae3          	bltu	a5,a4,8de <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 8ee:	ff852583          	lw	a1,-8(a0)
 8f2:	6390                	ld	a2,0(a5)
 8f4:	02059713          	slli	a4,a1,0x20
 8f8:	9301                	srli	a4,a4,0x20
 8fa:	0712                	slli	a4,a4,0x4
 8fc:	9736                	add	a4,a4,a3
 8fe:	fae60ae3          	beq	a2,a4,8b2 <free+0x14>
    bp->s.ptr = p->s.ptr;
 902:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 906:	4790                	lw	a2,8(a5)
 908:	02061713          	slli	a4,a2,0x20
 90c:	9301                	srli	a4,a4,0x20
 90e:	0712                	slli	a4,a4,0x4
 910:	973e                	add	a4,a4,a5
 912:	fae689e3          	beq	a3,a4,8c4 <free+0x26>
  } else
    p->s.ptr = bp;
 916:	e394                	sd	a3,0(a5)
  freep = p;
 918:	00000717          	auipc	a4,0x0
 91c:	1cf73023          	sd	a5,448(a4) # ad8 <freep>
}
 920:	6422                	ld	s0,8(sp)
 922:	0141                	addi	sp,sp,16
 924:	8082                	ret

0000000000000926 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 926:	7139                	addi	sp,sp,-64
 928:	fc06                	sd	ra,56(sp)
 92a:	f822                	sd	s0,48(sp)
 92c:	f426                	sd	s1,40(sp)
 92e:	f04a                	sd	s2,32(sp)
 930:	ec4e                	sd	s3,24(sp)
 932:	e852                	sd	s4,16(sp)
 934:	e456                	sd	s5,8(sp)
 936:	e05a                	sd	s6,0(sp)
 938:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 93a:	02051493          	slli	s1,a0,0x20
 93e:	9081                	srli	s1,s1,0x20
 940:	04bd                	addi	s1,s1,15
 942:	8091                	srli	s1,s1,0x4
 944:	0014899b          	addiw	s3,s1,1
 948:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 94a:	00000517          	auipc	a0,0x0
 94e:	18e53503          	ld	a0,398(a0) # ad8 <freep>
 952:	c515                	beqz	a0,97e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 954:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 956:	4798                	lw	a4,8(a5)
 958:	02977f63          	bgeu	a4,s1,996 <malloc+0x70>
 95c:	8a4e                	mv	s4,s3
 95e:	0009871b          	sext.w	a4,s3
 962:	6685                	lui	a3,0x1
 964:	00d77363          	bgeu	a4,a3,96a <malloc+0x44>
 968:	6a05                	lui	s4,0x1
 96a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 96e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 972:	00000917          	auipc	s2,0x0
 976:	16690913          	addi	s2,s2,358 # ad8 <freep>
  if(p == (char*)-1)
 97a:	5afd                	li	s5,-1
 97c:	a88d                	j	9ee <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 97e:	00000797          	auipc	a5,0x0
 982:	16278793          	addi	a5,a5,354 # ae0 <base>
 986:	00000717          	auipc	a4,0x0
 98a:	14f73923          	sd	a5,338(a4) # ad8 <freep>
 98e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 990:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 994:	b7e1                	j	95c <malloc+0x36>
      if(p->s.size == nunits)
 996:	02e48b63          	beq	s1,a4,9cc <malloc+0xa6>
        p->s.size -= nunits;
 99a:	4137073b          	subw	a4,a4,s3
 99e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9a0:	1702                	slli	a4,a4,0x20
 9a2:	9301                	srli	a4,a4,0x20
 9a4:	0712                	slli	a4,a4,0x4
 9a6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9a8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9ac:	00000717          	auipc	a4,0x0
 9b0:	12a73623          	sd	a0,300(a4) # ad8 <freep>
      return (void*)(p + 1);
 9b4:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 9b8:	70e2                	ld	ra,56(sp)
 9ba:	7442                	ld	s0,48(sp)
 9bc:	74a2                	ld	s1,40(sp)
 9be:	7902                	ld	s2,32(sp)
 9c0:	69e2                	ld	s3,24(sp)
 9c2:	6a42                	ld	s4,16(sp)
 9c4:	6aa2                	ld	s5,8(sp)
 9c6:	6b02                	ld	s6,0(sp)
 9c8:	6121                	addi	sp,sp,64
 9ca:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 9cc:	6398                	ld	a4,0(a5)
 9ce:	e118                	sd	a4,0(a0)
 9d0:	bff1                	j	9ac <malloc+0x86>
  hp->s.size = nu;
 9d2:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9d6:	0541                	addi	a0,a0,16
 9d8:	00000097          	auipc	ra,0x0
 9dc:	ec6080e7          	jalr	-314(ra) # 89e <free>
  return freep;
 9e0:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9e4:	d971                	beqz	a0,9b8 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9e6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9e8:	4798                	lw	a4,8(a5)
 9ea:	fa9776e3          	bgeu	a4,s1,996 <malloc+0x70>
    if(p == freep)
 9ee:	00093703          	ld	a4,0(s2)
 9f2:	853e                	mv	a0,a5
 9f4:	fef719e3          	bne	a4,a5,9e6 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 9f8:	8552                	mv	a0,s4
 9fa:	00000097          	auipc	ra,0x0
 9fe:	b5e080e7          	jalr	-1186(ra) # 558 <sbrk>
  if(p == (char*)-1)
 a02:	fd5518e3          	bne	a0,s5,9d2 <malloc+0xac>
        return 0;
 a06:	4501                	li	a0,0
 a08:	bf45                	j	9b8 <malloc+0x92>
