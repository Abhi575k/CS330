
user/_primefactors:     file format elf64-littleriscv


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
  34:	712d                	addi	sp,sp,-288
  36:	ee06                	sd	ra,280(sp)
  38:	ea22                	sd	s0,272(sp)
  3a:	e626                	sd	s1,264(sp)
  3c:	e24a                	sd	s2,256(sp)
  3e:	fdce                	sd	s3,248(sp)
  40:	1200                	addi	s0,sp,288
	if(argc!=2){
  42:	4789                	li	a5,2
  44:	04f51863          	bne	a0,a5,94 <main+0x60>
  48:	84ae                	mv	s1,a1
        printf("Usage: pipeline <value(x)>\n");
        printf("value ranges from 2 to 100.\n");
        exit(0);
    }
    if(!checkInt(argv[1])||atoi(argv[1])<2||atoi(argv[1])>100){
  4a:	0085b903          	ld	s2,8(a1)
  4e:	854a                	mv	a0,s2
  50:	00000097          	auipc	ra,0x0
  54:	fb0080e7          	jalr	-80(ra) # 0 <checkInt>
  58:	c909                	beqz	a0,6a <main+0x36>
  5a:	854a                	mv	a0,s2
  5c:	00000097          	auipc	ra,0x0
  60:	4d4080e7          	jalr	1236(ra) # 530 <atoi>
  64:	4785                	li	a5,1
  66:	04a7cc63          	blt	a5,a0,be <main+0x8a>
        printf("Usage: pipeline <value(x)>\n");
  6a:	00001517          	auipc	a0,0x1
  6e:	afe50513          	addi	a0,a0,-1282 # b68 <malloc+0xea>
  72:	00001097          	auipc	ra,0x1
  76:	94e080e7          	jalr	-1714(ra) # 9c0 <printf>
        printf("value ranges from 2 to 100.\n");
  7a:	00001517          	auipc	a0,0x1
  7e:	b0e50513          	addi	a0,a0,-1266 # b88 <malloc+0x10a>
  82:	00001097          	auipc	ra,0x1
  86:	93e080e7          	jalr	-1730(ra) # 9c0 <printf>
        exit(0);
  8a:	4501                	li	a0,0
  8c:	00000097          	auipc	ra,0x0
  90:	5a4080e7          	jalr	1444(ra) # 630 <exit>
        printf("Usage: pipeline <value(x)>\n");
  94:	00001517          	auipc	a0,0x1
  98:	ad450513          	addi	a0,a0,-1324 # b68 <malloc+0xea>
  9c:	00001097          	auipc	ra,0x1
  a0:	924080e7          	jalr	-1756(ra) # 9c0 <printf>
        printf("value ranges from 2 to 100.\n");
  a4:	00001517          	auipc	a0,0x1
  a8:	ae450513          	addi	a0,a0,-1308 # b88 <malloc+0x10a>
  ac:	00001097          	auipc	ra,0x1
  b0:	914080e7          	jalr	-1772(ra) # 9c0 <printf>
        exit(0);
  b4:	4501                	li	a0,0
  b6:	00000097          	auipc	ra,0x0
  ba:	57a080e7          	jalr	1402(ra) # 630 <exit>
    if(!checkInt(argv[1])||atoi(argv[1])<2||atoi(argv[1])>100){
  be:	6488                	ld	a0,8(s1)
  c0:	00000097          	auipc	ra,0x0
  c4:	470080e7          	jalr	1136(ra) # 530 <atoi>
  c8:	06400793          	li	a5,100
  cc:	f8a7cfe3          	blt	a5,a0,6a <main+0x36>
    }
    int fd[2];
    //  fd[0]: read
    //  fd[1]: write
	if(pipe(fd)<0){
  d0:	fc840513          	addi	a0,s0,-56
  d4:	00000097          	auipc	ra,0x0
  d8:	56c080e7          	jalr	1388(ra) # 640 <pipe>
  dc:	16054263          	bltz	a0,240 <main+0x20c>
		printf("Error creating pipe.\n");
		exit(0);
	}
    int data[]={2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97,atoi(argv[1]),0};
  e0:	4789                	li	a5,2
  e2:	f4f42c23          	sw	a5,-168(s0)
  e6:	478d                	li	a5,3
  e8:	f4f42e23          	sw	a5,-164(s0)
  ec:	4795                	li	a5,5
  ee:	f6f42023          	sw	a5,-160(s0)
  f2:	479d                	li	a5,7
  f4:	f6f42223          	sw	a5,-156(s0)
  f8:	47ad                	li	a5,11
  fa:	f6f42423          	sw	a5,-152(s0)
  fe:	47b5                	li	a5,13
 100:	f6f42623          	sw	a5,-148(s0)
 104:	47c5                	li	a5,17
 106:	f6f42823          	sw	a5,-144(s0)
 10a:	47cd                	li	a5,19
 10c:	f6f42a23          	sw	a5,-140(s0)
 110:	47dd                	li	a5,23
 112:	f6f42c23          	sw	a5,-136(s0)
 116:	47f5                	li	a5,29
 118:	f6f42e23          	sw	a5,-132(s0)
 11c:	47fd                	li	a5,31
 11e:	f8f42023          	sw	a5,-128(s0)
 122:	02500793          	li	a5,37
 126:	f8f42223          	sw	a5,-124(s0)
 12a:	02900793          	li	a5,41
 12e:	f8f42423          	sw	a5,-120(s0)
 132:	02b00793          	li	a5,43
 136:	f8f42623          	sw	a5,-116(s0)
 13a:	02f00793          	li	a5,47
 13e:	f8f42823          	sw	a5,-112(s0)
 142:	03500793          	li	a5,53
 146:	f8f42a23          	sw	a5,-108(s0)
 14a:	03b00793          	li	a5,59
 14e:	f8f42c23          	sw	a5,-104(s0)
 152:	03d00793          	li	a5,61
 156:	f8f42e23          	sw	a5,-100(s0)
 15a:	04300793          	li	a5,67
 15e:	faf42023          	sw	a5,-96(s0)
 162:	04700793          	li	a5,71
 166:	faf42223          	sw	a5,-92(s0)
 16a:	04900793          	li	a5,73
 16e:	faf42423          	sw	a5,-88(s0)
 172:	04f00793          	li	a5,79
 176:	faf42623          	sw	a5,-84(s0)
 17a:	05300793          	li	a5,83
 17e:	faf42823          	sw	a5,-80(s0)
 182:	05900793          	li	a5,89
 186:	faf42a23          	sw	a5,-76(s0)
 18a:	06100793          	li	a5,97
 18e:	faf42c23          	sw	a5,-72(s0)
 192:	6488                	ld	a0,8(s1)
 194:	00000097          	auipc	ra,0x0
 198:	39c080e7          	jalr	924(ra) # 530 <atoi>
 19c:	faa42e23          	sw	a0,-68(s0)
 1a0:	fc042023          	sw	zero,-64(s0)
	if(data[25]%data[data[26]]==0){
 1a4:	f5842583          	lw	a1,-168(s0)
 1a8:	02b5653b          	remw	a0,a0,a1
 1ac:	e931                	bnez	a0,200 <main+0x1cc>
        while(data[25]%data[data[26]]==0){
            printf("%d, ",data[data[26]]);
 1ae:	00001497          	auipc	s1,0x1
 1b2:	a1248493          	addi	s1,s1,-1518 # bc0 <malloc+0x142>
 1b6:	8526                	mv	a0,s1
 1b8:	00001097          	auipc	ra,0x1
 1bc:	808080e7          	jalr	-2040(ra) # 9c0 <printf>
            data[25]/=data[data[26]];
 1c0:	fc042703          	lw	a4,-64(s0)
 1c4:	070a                	slli	a4,a4,0x2
 1c6:	fd040793          	addi	a5,s0,-48
 1ca:	973e                	add	a4,a4,a5
 1cc:	f8872683          	lw	a3,-120(a4)
 1d0:	fbc42783          	lw	a5,-68(s0)
 1d4:	02d7c7bb          	divw	a5,a5,a3
 1d8:	faf42e23          	sw	a5,-68(s0)
        while(data[25]%data[data[26]]==0){
 1dc:	f8872583          	lw	a1,-120(a4)
 1e0:	02b7e7bb          	remw	a5,a5,a1
 1e4:	dbe9                	beqz	a5,1b6 <main+0x182>
        }
        printf("[%d]\n",(int)getpid());
 1e6:	00000097          	auipc	ra,0x0
 1ea:	4ca080e7          	jalr	1226(ra) # 6b0 <getpid>
 1ee:	85aa                	mv	a1,a0
 1f0:	00001517          	auipc	a0,0x1
 1f4:	9d850513          	addi	a0,a0,-1576 # bc8 <malloc+0x14a>
 1f8:	00000097          	auipc	ra,0x0
 1fc:	7c8080e7          	jalr	1992(ra) # 9c0 <printf>
    }
    if(data[25]<=1) exit(0);
 200:	fbc42703          	lw	a4,-68(s0)
 204:	4785                	li	a5,1
 206:	04e7da63          	bge	a5,a4,25a <main+0x226>
    data[26]++;
 20a:	fc042783          	lw	a5,-64(s0)
 20e:	2785                	addiw	a5,a5,1
 210:	fcf42023          	sw	a5,-64(s0)
    if(write(fd[1],data,27*sizeof(int))<0){
 214:	06c00613          	li	a2,108
 218:	f5840593          	addi	a1,s0,-168
 21c:	fcc42503          	lw	a0,-52(s0)
 220:	00000097          	auipc	ra,0x0
 224:	430080e7          	jalr	1072(ra) # 650 <write>
 228:	02054e63          	bltz	a0,264 <main+0x230>
            printf("Error reading from pipe.\n");
            exit(0);
        }
        if(temp[25]%temp[temp[26]]==0){
            while(temp[25]%temp[temp[26]]==0){
                printf("%d, ",temp[temp[26]]);
 22c:	00001497          	auipc	s1,0x1
 230:	99448493          	addi	s1,s1,-1644 # bc0 <malloc+0x142>
                temp[25]/=temp[temp[26]];
            }
            printf("[%d]\n",(int)getpid());
 234:	00001997          	auipc	s3,0x1
 238:	99498993          	addi	s3,s3,-1644 # bc8 <malloc+0x14a>
		temp[26]++;
        if(write(fd[1],temp,27*sizeof(int))<0){
            printf("Error writing to pipe.\n");
            exit(0);
        }
		if(temp[25]>1){
 23c:	4905                	li	s2,1
 23e:	a0c1                	j	2fe <main+0x2ca>
		printf("Error creating pipe.\n");
 240:	00001517          	auipc	a0,0x1
 244:	96850513          	addi	a0,a0,-1688 # ba8 <malloc+0x12a>
 248:	00000097          	auipc	ra,0x0
 24c:	778080e7          	jalr	1912(ra) # 9c0 <printf>
		exit(0);
 250:	4501                	li	a0,0
 252:	00000097          	auipc	ra,0x0
 256:	3de080e7          	jalr	990(ra) # 630 <exit>
    if(data[25]<=1) exit(0);
 25a:	4501                	li	a0,0
 25c:	00000097          	auipc	ra,0x0
 260:	3d4080e7          	jalr	980(ra) # 630 <exit>
        printf("Error writing to pipe.\n");
 264:	00001517          	auipc	a0,0x1
 268:	96c50513          	addi	a0,a0,-1684 # bd0 <malloc+0x152>
 26c:	00000097          	auipc	ra,0x0
 270:	754080e7          	jalr	1876(ra) # 9c0 <printf>
        exit(0);
 274:	4501                	li	a0,0
 276:	00000097          	auipc	ra,0x0
 27a:	3ba080e7          	jalr	954(ra) # 630 <exit>
        printf("Error creating fork.\n");
 27e:	00001517          	auipc	a0,0x1
 282:	96a50513          	addi	a0,a0,-1686 # be8 <malloc+0x16a>
 286:	00000097          	auipc	ra,0x0
 28a:	73a080e7          	jalr	1850(ra) # 9c0 <printf>
        exit(0);
 28e:	4501                	li	a0,0
 290:	00000097          	auipc	ra,0x0
 294:	3a0080e7          	jalr	928(ra) # 630 <exit>
		close(fd[0]);
 298:	fc842503          	lw	a0,-56(s0)
 29c:	00000097          	auipc	ra,0x0
 2a0:	3bc080e7          	jalr	956(ra) # 658 <close>
        close(fd[1]);
 2a4:	fcc42503          	lw	a0,-52(s0)
 2a8:	00000097          	auipc	ra,0x0
 2ac:	3b0080e7          	jalr	944(ra) # 658 <close>
			goto x;
		}
		close(fd[0]);
        close(fd[1]);
    }
	exit(0);
 2b0:	4501                	li	a0,0
 2b2:	00000097          	auipc	ra,0x0
 2b6:	37e080e7          	jalr	894(ra) # 630 <exit>
            printf("Error reading from pipe.\n");
 2ba:	00001517          	auipc	a0,0x1
 2be:	94650513          	addi	a0,a0,-1722 # c00 <malloc+0x182>
 2c2:	00000097          	auipc	ra,0x0
 2c6:	6fe080e7          	jalr	1790(ra) # 9c0 <printf>
            exit(0);
 2ca:	4501                	li	a0,0
 2cc:	00000097          	auipc	ra,0x0
 2d0:	364080e7          	jalr	868(ra) # 630 <exit>
		temp[26]++;
 2d4:	f4842783          	lw	a5,-184(s0)
 2d8:	2785                	addiw	a5,a5,1
 2da:	f4f42423          	sw	a5,-184(s0)
        if(write(fd[1],temp,27*sizeof(int))<0){
 2de:	06c00613          	li	a2,108
 2e2:	ee040593          	addi	a1,s0,-288
 2e6:	fcc42503          	lw	a0,-52(s0)
 2ea:	00000097          	auipc	ra,0x0
 2ee:	366080e7          	jalr	870(ra) # 650 <write>
 2f2:	08054a63          	bltz	a0,386 <main+0x352>
		if(temp[25]>1){
 2f6:	f4442783          	lw	a5,-188(s0)
 2fa:	0af95363          	bge	s2,a5,3a0 <main+0x36c>
    int id=fork();
 2fe:	00000097          	auipc	ra,0x0
 302:	32a080e7          	jalr	810(ra) # 628 <fork>
    if(id<0){
 306:	f6054ce3          	bltz	a0,27e <main+0x24a>
    else if(id>0){
 30a:	f8a047e3          	bgtz	a0,298 <main+0x264>
        if(read(fd[0],temp,27*sizeof(int))<0){
 30e:	06c00613          	li	a2,108
 312:	ee040593          	addi	a1,s0,-288
 316:	fc842503          	lw	a0,-56(s0)
 31a:	00000097          	auipc	ra,0x0
 31e:	32e080e7          	jalr	814(ra) # 648 <read>
 322:	f8054ce3          	bltz	a0,2ba <main+0x286>
        if(temp[25]%temp[temp[26]]==0){
 326:	f4842783          	lw	a5,-184(s0)
 32a:	078a                	slli	a5,a5,0x2
 32c:	fd040713          	addi	a4,s0,-48
 330:	97ba                	add	a5,a5,a4
 332:	f107a583          	lw	a1,-240(a5)
 336:	f4442783          	lw	a5,-188(s0)
 33a:	02b7e7bb          	remw	a5,a5,a1
 33e:	fbd9                	bnez	a5,2d4 <main+0x2a0>
                printf("%d, ",temp[temp[26]]);
 340:	8526                	mv	a0,s1
 342:	00000097          	auipc	ra,0x0
 346:	67e080e7          	jalr	1662(ra) # 9c0 <printf>
                temp[25]/=temp[temp[26]];
 34a:	f4842703          	lw	a4,-184(s0)
 34e:	070a                	slli	a4,a4,0x2
 350:	fd040793          	addi	a5,s0,-48
 354:	973e                	add	a4,a4,a5
 356:	f1072683          	lw	a3,-240(a4)
 35a:	f4442783          	lw	a5,-188(s0)
 35e:	02d7c7bb          	divw	a5,a5,a3
 362:	f4f42223          	sw	a5,-188(s0)
            while(temp[25]%temp[temp[26]]==0){
 366:	f1072583          	lw	a1,-240(a4)
 36a:	02b7e7bb          	remw	a5,a5,a1
 36e:	dbe9                	beqz	a5,340 <main+0x30c>
            printf("[%d]\n",(int)getpid());
 370:	00000097          	auipc	ra,0x0
 374:	340080e7          	jalr	832(ra) # 6b0 <getpid>
 378:	85aa                	mv	a1,a0
 37a:	854e                	mv	a0,s3
 37c:	00000097          	auipc	ra,0x0
 380:	644080e7          	jalr	1604(ra) # 9c0 <printf>
 384:	bf81                	j	2d4 <main+0x2a0>
            printf("Error writing to pipe.\n");
 386:	00001517          	auipc	a0,0x1
 38a:	84a50513          	addi	a0,a0,-1974 # bd0 <malloc+0x152>
 38e:	00000097          	auipc	ra,0x0
 392:	632080e7          	jalr	1586(ra) # 9c0 <printf>
            exit(0);
 396:	4501                	li	a0,0
 398:	00000097          	auipc	ra,0x0
 39c:	298080e7          	jalr	664(ra) # 630 <exit>
		close(fd[0]);
 3a0:	fc842503          	lw	a0,-56(s0)
 3a4:	00000097          	auipc	ra,0x0
 3a8:	2b4080e7          	jalr	692(ra) # 658 <close>
        close(fd[1]);
 3ac:	fcc42503          	lw	a0,-52(s0)
 3b0:	00000097          	auipc	ra,0x0
 3b4:	2a8080e7          	jalr	680(ra) # 658 <close>
 3b8:	bde5                	j	2b0 <main+0x27c>

00000000000003ba <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 3ba:	1141                	addi	sp,sp,-16
 3bc:	e422                	sd	s0,8(sp)
 3be:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 3c0:	87aa                	mv	a5,a0
 3c2:	0585                	addi	a1,a1,1
 3c4:	0785                	addi	a5,a5,1
 3c6:	fff5c703          	lbu	a4,-1(a1)
 3ca:	fee78fa3          	sb	a4,-1(a5)
 3ce:	fb75                	bnez	a4,3c2 <strcpy+0x8>
    ;
  return os;
}
 3d0:	6422                	ld	s0,8(sp)
 3d2:	0141                	addi	sp,sp,16
 3d4:	8082                	ret

00000000000003d6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3d6:	1141                	addi	sp,sp,-16
 3d8:	e422                	sd	s0,8(sp)
 3da:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 3dc:	00054783          	lbu	a5,0(a0)
 3e0:	cb91                	beqz	a5,3f4 <strcmp+0x1e>
 3e2:	0005c703          	lbu	a4,0(a1)
 3e6:	00f71763          	bne	a4,a5,3f4 <strcmp+0x1e>
    p++, q++;
 3ea:	0505                	addi	a0,a0,1
 3ec:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 3ee:	00054783          	lbu	a5,0(a0)
 3f2:	fbe5                	bnez	a5,3e2 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 3f4:	0005c503          	lbu	a0,0(a1)
}
 3f8:	40a7853b          	subw	a0,a5,a0
 3fc:	6422                	ld	s0,8(sp)
 3fe:	0141                	addi	sp,sp,16
 400:	8082                	ret

0000000000000402 <strlen>:

uint
strlen(const char *s)
{
 402:	1141                	addi	sp,sp,-16
 404:	e422                	sd	s0,8(sp)
 406:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 408:	00054783          	lbu	a5,0(a0)
 40c:	cf91                	beqz	a5,428 <strlen+0x26>
 40e:	0505                	addi	a0,a0,1
 410:	87aa                	mv	a5,a0
 412:	4685                	li	a3,1
 414:	9e89                	subw	a3,a3,a0
 416:	00f6853b          	addw	a0,a3,a5
 41a:	0785                	addi	a5,a5,1
 41c:	fff7c703          	lbu	a4,-1(a5)
 420:	fb7d                	bnez	a4,416 <strlen+0x14>
    ;
  return n;
}
 422:	6422                	ld	s0,8(sp)
 424:	0141                	addi	sp,sp,16
 426:	8082                	ret
  for(n = 0; s[n]; n++)
 428:	4501                	li	a0,0
 42a:	bfe5                	j	422 <strlen+0x20>

000000000000042c <memset>:

void*
memset(void *dst, int c, uint n)
{
 42c:	1141                	addi	sp,sp,-16
 42e:	e422                	sd	s0,8(sp)
 430:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 432:	ce09                	beqz	a2,44c <memset+0x20>
 434:	87aa                	mv	a5,a0
 436:	fff6071b          	addiw	a4,a2,-1
 43a:	1702                	slli	a4,a4,0x20
 43c:	9301                	srli	a4,a4,0x20
 43e:	0705                	addi	a4,a4,1
 440:	972a                	add	a4,a4,a0
    cdst[i] = c;
 442:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 446:	0785                	addi	a5,a5,1
 448:	fee79de3          	bne	a5,a4,442 <memset+0x16>
  }
  return dst;
}
 44c:	6422                	ld	s0,8(sp)
 44e:	0141                	addi	sp,sp,16
 450:	8082                	ret

0000000000000452 <strchr>:

char*
strchr(const char *s, char c)
{
 452:	1141                	addi	sp,sp,-16
 454:	e422                	sd	s0,8(sp)
 456:	0800                	addi	s0,sp,16
  for(; *s; s++)
 458:	00054783          	lbu	a5,0(a0)
 45c:	cb99                	beqz	a5,472 <strchr+0x20>
    if(*s == c)
 45e:	00f58763          	beq	a1,a5,46c <strchr+0x1a>
  for(; *s; s++)
 462:	0505                	addi	a0,a0,1
 464:	00054783          	lbu	a5,0(a0)
 468:	fbfd                	bnez	a5,45e <strchr+0xc>
      return (char*)s;
  return 0;
 46a:	4501                	li	a0,0
}
 46c:	6422                	ld	s0,8(sp)
 46e:	0141                	addi	sp,sp,16
 470:	8082                	ret
  return 0;
 472:	4501                	li	a0,0
 474:	bfe5                	j	46c <strchr+0x1a>

0000000000000476 <gets>:

char*
gets(char *buf, int max)
{
 476:	711d                	addi	sp,sp,-96
 478:	ec86                	sd	ra,88(sp)
 47a:	e8a2                	sd	s0,80(sp)
 47c:	e4a6                	sd	s1,72(sp)
 47e:	e0ca                	sd	s2,64(sp)
 480:	fc4e                	sd	s3,56(sp)
 482:	f852                	sd	s4,48(sp)
 484:	f456                	sd	s5,40(sp)
 486:	f05a                	sd	s6,32(sp)
 488:	ec5e                	sd	s7,24(sp)
 48a:	1080                	addi	s0,sp,96
 48c:	8baa                	mv	s7,a0
 48e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 490:	892a                	mv	s2,a0
 492:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 494:	4aa9                	li	s5,10
 496:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 498:	89a6                	mv	s3,s1
 49a:	2485                	addiw	s1,s1,1
 49c:	0344d863          	bge	s1,s4,4cc <gets+0x56>
    cc = read(0, &c, 1);
 4a0:	4605                	li	a2,1
 4a2:	faf40593          	addi	a1,s0,-81
 4a6:	4501                	li	a0,0
 4a8:	00000097          	auipc	ra,0x0
 4ac:	1a0080e7          	jalr	416(ra) # 648 <read>
    if(cc < 1)
 4b0:	00a05e63          	blez	a0,4cc <gets+0x56>
    buf[i++] = c;
 4b4:	faf44783          	lbu	a5,-81(s0)
 4b8:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 4bc:	01578763          	beq	a5,s5,4ca <gets+0x54>
 4c0:	0905                	addi	s2,s2,1
 4c2:	fd679be3          	bne	a5,s6,498 <gets+0x22>
  for(i=0; i+1 < max; ){
 4c6:	89a6                	mv	s3,s1
 4c8:	a011                	j	4cc <gets+0x56>
 4ca:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 4cc:	99de                	add	s3,s3,s7
 4ce:	00098023          	sb	zero,0(s3)
  return buf;
}
 4d2:	855e                	mv	a0,s7
 4d4:	60e6                	ld	ra,88(sp)
 4d6:	6446                	ld	s0,80(sp)
 4d8:	64a6                	ld	s1,72(sp)
 4da:	6906                	ld	s2,64(sp)
 4dc:	79e2                	ld	s3,56(sp)
 4de:	7a42                	ld	s4,48(sp)
 4e0:	7aa2                	ld	s5,40(sp)
 4e2:	7b02                	ld	s6,32(sp)
 4e4:	6be2                	ld	s7,24(sp)
 4e6:	6125                	addi	sp,sp,96
 4e8:	8082                	ret

00000000000004ea <stat>:

int
stat(const char *n, struct stat *st)
{
 4ea:	1101                	addi	sp,sp,-32
 4ec:	ec06                	sd	ra,24(sp)
 4ee:	e822                	sd	s0,16(sp)
 4f0:	e426                	sd	s1,8(sp)
 4f2:	e04a                	sd	s2,0(sp)
 4f4:	1000                	addi	s0,sp,32
 4f6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4f8:	4581                	li	a1,0
 4fa:	00000097          	auipc	ra,0x0
 4fe:	176080e7          	jalr	374(ra) # 670 <open>
  if(fd < 0)
 502:	02054563          	bltz	a0,52c <stat+0x42>
 506:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 508:	85ca                	mv	a1,s2
 50a:	00000097          	auipc	ra,0x0
 50e:	17e080e7          	jalr	382(ra) # 688 <fstat>
 512:	892a                	mv	s2,a0
  close(fd);
 514:	8526                	mv	a0,s1
 516:	00000097          	auipc	ra,0x0
 51a:	142080e7          	jalr	322(ra) # 658 <close>
  return r;
}
 51e:	854a                	mv	a0,s2
 520:	60e2                	ld	ra,24(sp)
 522:	6442                	ld	s0,16(sp)
 524:	64a2                	ld	s1,8(sp)
 526:	6902                	ld	s2,0(sp)
 528:	6105                	addi	sp,sp,32
 52a:	8082                	ret
    return -1;
 52c:	597d                	li	s2,-1
 52e:	bfc5                	j	51e <stat+0x34>

0000000000000530 <atoi>:

int
atoi(const char *s)
{
 530:	1141                	addi	sp,sp,-16
 532:	e422                	sd	s0,8(sp)
 534:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 536:	00054603          	lbu	a2,0(a0)
 53a:	fd06079b          	addiw	a5,a2,-48
 53e:	0ff7f793          	andi	a5,a5,255
 542:	4725                	li	a4,9
 544:	02f76963          	bltu	a4,a5,576 <atoi+0x46>
 548:	86aa                	mv	a3,a0
  n = 0;
 54a:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 54c:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 54e:	0685                	addi	a3,a3,1
 550:	0025179b          	slliw	a5,a0,0x2
 554:	9fa9                	addw	a5,a5,a0
 556:	0017979b          	slliw	a5,a5,0x1
 55a:	9fb1                	addw	a5,a5,a2
 55c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 560:	0006c603          	lbu	a2,0(a3)
 564:	fd06071b          	addiw	a4,a2,-48
 568:	0ff77713          	andi	a4,a4,255
 56c:	fee5f1e3          	bgeu	a1,a4,54e <atoi+0x1e>
  return n;
}
 570:	6422                	ld	s0,8(sp)
 572:	0141                	addi	sp,sp,16
 574:	8082                	ret
  n = 0;
 576:	4501                	li	a0,0
 578:	bfe5                	j	570 <atoi+0x40>

000000000000057a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 57a:	1141                	addi	sp,sp,-16
 57c:	e422                	sd	s0,8(sp)
 57e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 580:	02b57663          	bgeu	a0,a1,5ac <memmove+0x32>
    while(n-- > 0)
 584:	02c05163          	blez	a2,5a6 <memmove+0x2c>
 588:	fff6079b          	addiw	a5,a2,-1
 58c:	1782                	slli	a5,a5,0x20
 58e:	9381                	srli	a5,a5,0x20
 590:	0785                	addi	a5,a5,1
 592:	97aa                	add	a5,a5,a0
  dst = vdst;
 594:	872a                	mv	a4,a0
      *dst++ = *src++;
 596:	0585                	addi	a1,a1,1
 598:	0705                	addi	a4,a4,1
 59a:	fff5c683          	lbu	a3,-1(a1)
 59e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 5a2:	fee79ae3          	bne	a5,a4,596 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 5a6:	6422                	ld	s0,8(sp)
 5a8:	0141                	addi	sp,sp,16
 5aa:	8082                	ret
    dst += n;
 5ac:	00c50733          	add	a4,a0,a2
    src += n;
 5b0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 5b2:	fec05ae3          	blez	a2,5a6 <memmove+0x2c>
 5b6:	fff6079b          	addiw	a5,a2,-1
 5ba:	1782                	slli	a5,a5,0x20
 5bc:	9381                	srli	a5,a5,0x20
 5be:	fff7c793          	not	a5,a5
 5c2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 5c4:	15fd                	addi	a1,a1,-1
 5c6:	177d                	addi	a4,a4,-1
 5c8:	0005c683          	lbu	a3,0(a1)
 5cc:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 5d0:	fee79ae3          	bne	a5,a4,5c4 <memmove+0x4a>
 5d4:	bfc9                	j	5a6 <memmove+0x2c>

00000000000005d6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 5d6:	1141                	addi	sp,sp,-16
 5d8:	e422                	sd	s0,8(sp)
 5da:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 5dc:	ca05                	beqz	a2,60c <memcmp+0x36>
 5de:	fff6069b          	addiw	a3,a2,-1
 5e2:	1682                	slli	a3,a3,0x20
 5e4:	9281                	srli	a3,a3,0x20
 5e6:	0685                	addi	a3,a3,1
 5e8:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 5ea:	00054783          	lbu	a5,0(a0)
 5ee:	0005c703          	lbu	a4,0(a1)
 5f2:	00e79863          	bne	a5,a4,602 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 5f6:	0505                	addi	a0,a0,1
    p2++;
 5f8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 5fa:	fed518e3          	bne	a0,a3,5ea <memcmp+0x14>
  }
  return 0;
 5fe:	4501                	li	a0,0
 600:	a019                	j	606 <memcmp+0x30>
      return *p1 - *p2;
 602:	40e7853b          	subw	a0,a5,a4
}
 606:	6422                	ld	s0,8(sp)
 608:	0141                	addi	sp,sp,16
 60a:	8082                	ret
  return 0;
 60c:	4501                	li	a0,0
 60e:	bfe5                	j	606 <memcmp+0x30>

0000000000000610 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 610:	1141                	addi	sp,sp,-16
 612:	e406                	sd	ra,8(sp)
 614:	e022                	sd	s0,0(sp)
 616:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 618:	00000097          	auipc	ra,0x0
 61c:	f62080e7          	jalr	-158(ra) # 57a <memmove>
}
 620:	60a2                	ld	ra,8(sp)
 622:	6402                	ld	s0,0(sp)
 624:	0141                	addi	sp,sp,16
 626:	8082                	ret

0000000000000628 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 628:	4885                	li	a7,1
 ecall
 62a:	00000073          	ecall
 ret
 62e:	8082                	ret

0000000000000630 <exit>:
.global exit
exit:
 li a7, SYS_exit
 630:	4889                	li	a7,2
 ecall
 632:	00000073          	ecall
 ret
 636:	8082                	ret

0000000000000638 <wait>:
.global wait
wait:
 li a7, SYS_wait
 638:	488d                	li	a7,3
 ecall
 63a:	00000073          	ecall
 ret
 63e:	8082                	ret

0000000000000640 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 640:	4891                	li	a7,4
 ecall
 642:	00000073          	ecall
 ret
 646:	8082                	ret

0000000000000648 <read>:
.global read
read:
 li a7, SYS_read
 648:	4895                	li	a7,5
 ecall
 64a:	00000073          	ecall
 ret
 64e:	8082                	ret

0000000000000650 <write>:
.global write
write:
 li a7, SYS_write
 650:	48c1                	li	a7,16
 ecall
 652:	00000073          	ecall
 ret
 656:	8082                	ret

0000000000000658 <close>:
.global close
close:
 li a7, SYS_close
 658:	48d5                	li	a7,21
 ecall
 65a:	00000073          	ecall
 ret
 65e:	8082                	ret

0000000000000660 <kill>:
.global kill
kill:
 li a7, SYS_kill
 660:	4899                	li	a7,6
 ecall
 662:	00000073          	ecall
 ret
 666:	8082                	ret

0000000000000668 <exec>:
.global exec
exec:
 li a7, SYS_exec
 668:	489d                	li	a7,7
 ecall
 66a:	00000073          	ecall
 ret
 66e:	8082                	ret

0000000000000670 <open>:
.global open
open:
 li a7, SYS_open
 670:	48bd                	li	a7,15
 ecall
 672:	00000073          	ecall
 ret
 676:	8082                	ret

0000000000000678 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 678:	48c5                	li	a7,17
 ecall
 67a:	00000073          	ecall
 ret
 67e:	8082                	ret

0000000000000680 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 680:	48c9                	li	a7,18
 ecall
 682:	00000073          	ecall
 ret
 686:	8082                	ret

0000000000000688 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 688:	48a1                	li	a7,8
 ecall
 68a:	00000073          	ecall
 ret
 68e:	8082                	ret

0000000000000690 <link>:
.global link
link:
 li a7, SYS_link
 690:	48cd                	li	a7,19
 ecall
 692:	00000073          	ecall
 ret
 696:	8082                	ret

0000000000000698 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 698:	48d1                	li	a7,20
 ecall
 69a:	00000073          	ecall
 ret
 69e:	8082                	ret

00000000000006a0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 6a0:	48a5                	li	a7,9
 ecall
 6a2:	00000073          	ecall
 ret
 6a6:	8082                	ret

00000000000006a8 <dup>:
.global dup
dup:
 li a7, SYS_dup
 6a8:	48a9                	li	a7,10
 ecall
 6aa:	00000073          	ecall
 ret
 6ae:	8082                	ret

00000000000006b0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 6b0:	48ad                	li	a7,11
 ecall
 6b2:	00000073          	ecall
 ret
 6b6:	8082                	ret

00000000000006b8 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 6b8:	48d9                	li	a7,22
 ecall
 6ba:	00000073          	ecall
 ret
 6be:	8082                	ret

00000000000006c0 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 6c0:	48b1                	li	a7,12
 ecall
 6c2:	00000073          	ecall
 ret
 6c6:	8082                	ret

00000000000006c8 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 6c8:	48b5                	li	a7,13
 ecall
 6ca:	00000073          	ecall
 ret
 6ce:	8082                	ret

00000000000006d0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 6d0:	48b9                	li	a7,14
 ecall
 6d2:	00000073          	ecall
 ret
 6d6:	8082                	ret

00000000000006d8 <yield>:
.global yield
yield:
 li a7, SYS_yield
 6d8:	48dd                	li	a7,23
 ecall
 6da:	00000073          	ecall
 ret
 6de:	8082                	ret

00000000000006e0 <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 6e0:	48e1                	li	a7,24
 ecall
 6e2:	00000073          	ecall
 ret
 6e6:	8082                	ret

00000000000006e8 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 6e8:	1101                	addi	sp,sp,-32
 6ea:	ec06                	sd	ra,24(sp)
 6ec:	e822                	sd	s0,16(sp)
 6ee:	1000                	addi	s0,sp,32
 6f0:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 6f4:	4605                	li	a2,1
 6f6:	fef40593          	addi	a1,s0,-17
 6fa:	00000097          	auipc	ra,0x0
 6fe:	f56080e7          	jalr	-170(ra) # 650 <write>
}
 702:	60e2                	ld	ra,24(sp)
 704:	6442                	ld	s0,16(sp)
 706:	6105                	addi	sp,sp,32
 708:	8082                	ret

000000000000070a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 70a:	7139                	addi	sp,sp,-64
 70c:	fc06                	sd	ra,56(sp)
 70e:	f822                	sd	s0,48(sp)
 710:	f426                	sd	s1,40(sp)
 712:	f04a                	sd	s2,32(sp)
 714:	ec4e                	sd	s3,24(sp)
 716:	0080                	addi	s0,sp,64
 718:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 71a:	c299                	beqz	a3,720 <printint+0x16>
 71c:	0805c863          	bltz	a1,7ac <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 720:	2581                	sext.w	a1,a1
  neg = 0;
 722:	4881                	li	a7,0
 724:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 728:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 72a:	2601                	sext.w	a2,a2
 72c:	00000517          	auipc	a0,0x0
 730:	4fc50513          	addi	a0,a0,1276 # c28 <digits>
 734:	883a                	mv	a6,a4
 736:	2705                	addiw	a4,a4,1
 738:	02c5f7bb          	remuw	a5,a1,a2
 73c:	1782                	slli	a5,a5,0x20
 73e:	9381                	srli	a5,a5,0x20
 740:	97aa                	add	a5,a5,a0
 742:	0007c783          	lbu	a5,0(a5)
 746:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 74a:	0005879b          	sext.w	a5,a1
 74e:	02c5d5bb          	divuw	a1,a1,a2
 752:	0685                	addi	a3,a3,1
 754:	fec7f0e3          	bgeu	a5,a2,734 <printint+0x2a>
  if(neg)
 758:	00088b63          	beqz	a7,76e <printint+0x64>
    buf[i++] = '-';
 75c:	fd040793          	addi	a5,s0,-48
 760:	973e                	add	a4,a4,a5
 762:	02d00793          	li	a5,45
 766:	fef70823          	sb	a5,-16(a4)
 76a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 76e:	02e05863          	blez	a4,79e <printint+0x94>
 772:	fc040793          	addi	a5,s0,-64
 776:	00e78933          	add	s2,a5,a4
 77a:	fff78993          	addi	s3,a5,-1
 77e:	99ba                	add	s3,s3,a4
 780:	377d                	addiw	a4,a4,-1
 782:	1702                	slli	a4,a4,0x20
 784:	9301                	srli	a4,a4,0x20
 786:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 78a:	fff94583          	lbu	a1,-1(s2)
 78e:	8526                	mv	a0,s1
 790:	00000097          	auipc	ra,0x0
 794:	f58080e7          	jalr	-168(ra) # 6e8 <putc>
  while(--i >= 0)
 798:	197d                	addi	s2,s2,-1
 79a:	ff3918e3          	bne	s2,s3,78a <printint+0x80>
}
 79e:	70e2                	ld	ra,56(sp)
 7a0:	7442                	ld	s0,48(sp)
 7a2:	74a2                	ld	s1,40(sp)
 7a4:	7902                	ld	s2,32(sp)
 7a6:	69e2                	ld	s3,24(sp)
 7a8:	6121                	addi	sp,sp,64
 7aa:	8082                	ret
    x = -xx;
 7ac:	40b005bb          	negw	a1,a1
    neg = 1;
 7b0:	4885                	li	a7,1
    x = -xx;
 7b2:	bf8d                	j	724 <printint+0x1a>

00000000000007b4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 7b4:	7119                	addi	sp,sp,-128
 7b6:	fc86                	sd	ra,120(sp)
 7b8:	f8a2                	sd	s0,112(sp)
 7ba:	f4a6                	sd	s1,104(sp)
 7bc:	f0ca                	sd	s2,96(sp)
 7be:	ecce                	sd	s3,88(sp)
 7c0:	e8d2                	sd	s4,80(sp)
 7c2:	e4d6                	sd	s5,72(sp)
 7c4:	e0da                	sd	s6,64(sp)
 7c6:	fc5e                	sd	s7,56(sp)
 7c8:	f862                	sd	s8,48(sp)
 7ca:	f466                	sd	s9,40(sp)
 7cc:	f06a                	sd	s10,32(sp)
 7ce:	ec6e                	sd	s11,24(sp)
 7d0:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 7d2:	0005c903          	lbu	s2,0(a1)
 7d6:	18090f63          	beqz	s2,974 <vprintf+0x1c0>
 7da:	8aaa                	mv	s5,a0
 7dc:	8b32                	mv	s6,a2
 7de:	00158493          	addi	s1,a1,1
  state = 0;
 7e2:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 7e4:	02500a13          	li	s4,37
      if(c == 'd'){
 7e8:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 7ec:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 7f0:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 7f4:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7f8:	00000b97          	auipc	s7,0x0
 7fc:	430b8b93          	addi	s7,s7,1072 # c28 <digits>
 800:	a839                	j	81e <vprintf+0x6a>
        putc(fd, c);
 802:	85ca                	mv	a1,s2
 804:	8556                	mv	a0,s5
 806:	00000097          	auipc	ra,0x0
 80a:	ee2080e7          	jalr	-286(ra) # 6e8 <putc>
 80e:	a019                	j	814 <vprintf+0x60>
    } else if(state == '%'){
 810:	01498f63          	beq	s3,s4,82e <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 814:	0485                	addi	s1,s1,1
 816:	fff4c903          	lbu	s2,-1(s1)
 81a:	14090d63          	beqz	s2,974 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 81e:	0009079b          	sext.w	a5,s2
    if(state == 0){
 822:	fe0997e3          	bnez	s3,810 <vprintf+0x5c>
      if(c == '%'){
 826:	fd479ee3          	bne	a5,s4,802 <vprintf+0x4e>
        state = '%';
 82a:	89be                	mv	s3,a5
 82c:	b7e5                	j	814 <vprintf+0x60>
      if(c == 'd'){
 82e:	05878063          	beq	a5,s8,86e <vprintf+0xba>
      } else if(c == 'l') {
 832:	05978c63          	beq	a5,s9,88a <vprintf+0xd6>
      } else if(c == 'x') {
 836:	07a78863          	beq	a5,s10,8a6 <vprintf+0xf2>
      } else if(c == 'p') {
 83a:	09b78463          	beq	a5,s11,8c2 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 83e:	07300713          	li	a4,115
 842:	0ce78663          	beq	a5,a4,90e <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 846:	06300713          	li	a4,99
 84a:	0ee78e63          	beq	a5,a4,946 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 84e:	11478863          	beq	a5,s4,95e <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 852:	85d2                	mv	a1,s4
 854:	8556                	mv	a0,s5
 856:	00000097          	auipc	ra,0x0
 85a:	e92080e7          	jalr	-366(ra) # 6e8 <putc>
        putc(fd, c);
 85e:	85ca                	mv	a1,s2
 860:	8556                	mv	a0,s5
 862:	00000097          	auipc	ra,0x0
 866:	e86080e7          	jalr	-378(ra) # 6e8 <putc>
      }
      state = 0;
 86a:	4981                	li	s3,0
 86c:	b765                	j	814 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 86e:	008b0913          	addi	s2,s6,8
 872:	4685                	li	a3,1
 874:	4629                	li	a2,10
 876:	000b2583          	lw	a1,0(s6)
 87a:	8556                	mv	a0,s5
 87c:	00000097          	auipc	ra,0x0
 880:	e8e080e7          	jalr	-370(ra) # 70a <printint>
 884:	8b4a                	mv	s6,s2
      state = 0;
 886:	4981                	li	s3,0
 888:	b771                	j	814 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 88a:	008b0913          	addi	s2,s6,8
 88e:	4681                	li	a3,0
 890:	4629                	li	a2,10
 892:	000b2583          	lw	a1,0(s6)
 896:	8556                	mv	a0,s5
 898:	00000097          	auipc	ra,0x0
 89c:	e72080e7          	jalr	-398(ra) # 70a <printint>
 8a0:	8b4a                	mv	s6,s2
      state = 0;
 8a2:	4981                	li	s3,0
 8a4:	bf85                	j	814 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 8a6:	008b0913          	addi	s2,s6,8
 8aa:	4681                	li	a3,0
 8ac:	4641                	li	a2,16
 8ae:	000b2583          	lw	a1,0(s6)
 8b2:	8556                	mv	a0,s5
 8b4:	00000097          	auipc	ra,0x0
 8b8:	e56080e7          	jalr	-426(ra) # 70a <printint>
 8bc:	8b4a                	mv	s6,s2
      state = 0;
 8be:	4981                	li	s3,0
 8c0:	bf91                	j	814 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 8c2:	008b0793          	addi	a5,s6,8
 8c6:	f8f43423          	sd	a5,-120(s0)
 8ca:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 8ce:	03000593          	li	a1,48
 8d2:	8556                	mv	a0,s5
 8d4:	00000097          	auipc	ra,0x0
 8d8:	e14080e7          	jalr	-492(ra) # 6e8 <putc>
  putc(fd, 'x');
 8dc:	85ea                	mv	a1,s10
 8de:	8556                	mv	a0,s5
 8e0:	00000097          	auipc	ra,0x0
 8e4:	e08080e7          	jalr	-504(ra) # 6e8 <putc>
 8e8:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 8ea:	03c9d793          	srli	a5,s3,0x3c
 8ee:	97de                	add	a5,a5,s7
 8f0:	0007c583          	lbu	a1,0(a5)
 8f4:	8556                	mv	a0,s5
 8f6:	00000097          	auipc	ra,0x0
 8fa:	df2080e7          	jalr	-526(ra) # 6e8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 8fe:	0992                	slli	s3,s3,0x4
 900:	397d                	addiw	s2,s2,-1
 902:	fe0914e3          	bnez	s2,8ea <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 906:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 90a:	4981                	li	s3,0
 90c:	b721                	j	814 <vprintf+0x60>
        s = va_arg(ap, char*);
 90e:	008b0993          	addi	s3,s6,8
 912:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 916:	02090163          	beqz	s2,938 <vprintf+0x184>
        while(*s != 0){
 91a:	00094583          	lbu	a1,0(s2)
 91e:	c9a1                	beqz	a1,96e <vprintf+0x1ba>
          putc(fd, *s);
 920:	8556                	mv	a0,s5
 922:	00000097          	auipc	ra,0x0
 926:	dc6080e7          	jalr	-570(ra) # 6e8 <putc>
          s++;
 92a:	0905                	addi	s2,s2,1
        while(*s != 0){
 92c:	00094583          	lbu	a1,0(s2)
 930:	f9e5                	bnez	a1,920 <vprintf+0x16c>
        s = va_arg(ap, char*);
 932:	8b4e                	mv	s6,s3
      state = 0;
 934:	4981                	li	s3,0
 936:	bdf9                	j	814 <vprintf+0x60>
          s = "(null)";
 938:	00000917          	auipc	s2,0x0
 93c:	2e890913          	addi	s2,s2,744 # c20 <malloc+0x1a2>
        while(*s != 0){
 940:	02800593          	li	a1,40
 944:	bff1                	j	920 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 946:	008b0913          	addi	s2,s6,8
 94a:	000b4583          	lbu	a1,0(s6)
 94e:	8556                	mv	a0,s5
 950:	00000097          	auipc	ra,0x0
 954:	d98080e7          	jalr	-616(ra) # 6e8 <putc>
 958:	8b4a                	mv	s6,s2
      state = 0;
 95a:	4981                	li	s3,0
 95c:	bd65                	j	814 <vprintf+0x60>
        putc(fd, c);
 95e:	85d2                	mv	a1,s4
 960:	8556                	mv	a0,s5
 962:	00000097          	auipc	ra,0x0
 966:	d86080e7          	jalr	-634(ra) # 6e8 <putc>
      state = 0;
 96a:	4981                	li	s3,0
 96c:	b565                	j	814 <vprintf+0x60>
        s = va_arg(ap, char*);
 96e:	8b4e                	mv	s6,s3
      state = 0;
 970:	4981                	li	s3,0
 972:	b54d                	j	814 <vprintf+0x60>
    }
  }
}
 974:	70e6                	ld	ra,120(sp)
 976:	7446                	ld	s0,112(sp)
 978:	74a6                	ld	s1,104(sp)
 97a:	7906                	ld	s2,96(sp)
 97c:	69e6                	ld	s3,88(sp)
 97e:	6a46                	ld	s4,80(sp)
 980:	6aa6                	ld	s5,72(sp)
 982:	6b06                	ld	s6,64(sp)
 984:	7be2                	ld	s7,56(sp)
 986:	7c42                	ld	s8,48(sp)
 988:	7ca2                	ld	s9,40(sp)
 98a:	7d02                	ld	s10,32(sp)
 98c:	6de2                	ld	s11,24(sp)
 98e:	6109                	addi	sp,sp,128
 990:	8082                	ret

0000000000000992 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 992:	715d                	addi	sp,sp,-80
 994:	ec06                	sd	ra,24(sp)
 996:	e822                	sd	s0,16(sp)
 998:	1000                	addi	s0,sp,32
 99a:	e010                	sd	a2,0(s0)
 99c:	e414                	sd	a3,8(s0)
 99e:	e818                	sd	a4,16(s0)
 9a0:	ec1c                	sd	a5,24(s0)
 9a2:	03043023          	sd	a6,32(s0)
 9a6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 9aa:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 9ae:	8622                	mv	a2,s0
 9b0:	00000097          	auipc	ra,0x0
 9b4:	e04080e7          	jalr	-508(ra) # 7b4 <vprintf>
}
 9b8:	60e2                	ld	ra,24(sp)
 9ba:	6442                	ld	s0,16(sp)
 9bc:	6161                	addi	sp,sp,80
 9be:	8082                	ret

00000000000009c0 <printf>:

void
printf(const char *fmt, ...)
{
 9c0:	711d                	addi	sp,sp,-96
 9c2:	ec06                	sd	ra,24(sp)
 9c4:	e822                	sd	s0,16(sp)
 9c6:	1000                	addi	s0,sp,32
 9c8:	e40c                	sd	a1,8(s0)
 9ca:	e810                	sd	a2,16(s0)
 9cc:	ec14                	sd	a3,24(s0)
 9ce:	f018                	sd	a4,32(s0)
 9d0:	f41c                	sd	a5,40(s0)
 9d2:	03043823          	sd	a6,48(s0)
 9d6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 9da:	00840613          	addi	a2,s0,8
 9de:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 9e2:	85aa                	mv	a1,a0
 9e4:	4505                	li	a0,1
 9e6:	00000097          	auipc	ra,0x0
 9ea:	dce080e7          	jalr	-562(ra) # 7b4 <vprintf>
}
 9ee:	60e2                	ld	ra,24(sp)
 9f0:	6442                	ld	s0,16(sp)
 9f2:	6125                	addi	sp,sp,96
 9f4:	8082                	ret

00000000000009f6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 9f6:	1141                	addi	sp,sp,-16
 9f8:	e422                	sd	s0,8(sp)
 9fa:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 9fc:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a00:	00000797          	auipc	a5,0x0
 a04:	2407b783          	ld	a5,576(a5) # c40 <freep>
 a08:	a805                	j	a38 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 a0a:	4618                	lw	a4,8(a2)
 a0c:	9db9                	addw	a1,a1,a4
 a0e:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 a12:	6398                	ld	a4,0(a5)
 a14:	6318                	ld	a4,0(a4)
 a16:	fee53823          	sd	a4,-16(a0)
 a1a:	a091                	j	a5e <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 a1c:	ff852703          	lw	a4,-8(a0)
 a20:	9e39                	addw	a2,a2,a4
 a22:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 a24:	ff053703          	ld	a4,-16(a0)
 a28:	e398                	sd	a4,0(a5)
 a2a:	a099                	j	a70 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a2c:	6398                	ld	a4,0(a5)
 a2e:	00e7e463          	bltu	a5,a4,a36 <free+0x40>
 a32:	00e6ea63          	bltu	a3,a4,a46 <free+0x50>
{
 a36:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a38:	fed7fae3          	bgeu	a5,a3,a2c <free+0x36>
 a3c:	6398                	ld	a4,0(a5)
 a3e:	00e6e463          	bltu	a3,a4,a46 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a42:	fee7eae3          	bltu	a5,a4,a36 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 a46:	ff852583          	lw	a1,-8(a0)
 a4a:	6390                	ld	a2,0(a5)
 a4c:	02059713          	slli	a4,a1,0x20
 a50:	9301                	srli	a4,a4,0x20
 a52:	0712                	slli	a4,a4,0x4
 a54:	9736                	add	a4,a4,a3
 a56:	fae60ae3          	beq	a2,a4,a0a <free+0x14>
    bp->s.ptr = p->s.ptr;
 a5a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 a5e:	4790                	lw	a2,8(a5)
 a60:	02061713          	slli	a4,a2,0x20
 a64:	9301                	srli	a4,a4,0x20
 a66:	0712                	slli	a4,a4,0x4
 a68:	973e                	add	a4,a4,a5
 a6a:	fae689e3          	beq	a3,a4,a1c <free+0x26>
  } else
    p->s.ptr = bp;
 a6e:	e394                	sd	a3,0(a5)
  freep = p;
 a70:	00000717          	auipc	a4,0x0
 a74:	1cf73823          	sd	a5,464(a4) # c40 <freep>
}
 a78:	6422                	ld	s0,8(sp)
 a7a:	0141                	addi	sp,sp,16
 a7c:	8082                	ret

0000000000000a7e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 a7e:	7139                	addi	sp,sp,-64
 a80:	fc06                	sd	ra,56(sp)
 a82:	f822                	sd	s0,48(sp)
 a84:	f426                	sd	s1,40(sp)
 a86:	f04a                	sd	s2,32(sp)
 a88:	ec4e                	sd	s3,24(sp)
 a8a:	e852                	sd	s4,16(sp)
 a8c:	e456                	sd	s5,8(sp)
 a8e:	e05a                	sd	s6,0(sp)
 a90:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a92:	02051493          	slli	s1,a0,0x20
 a96:	9081                	srli	s1,s1,0x20
 a98:	04bd                	addi	s1,s1,15
 a9a:	8091                	srli	s1,s1,0x4
 a9c:	0014899b          	addiw	s3,s1,1
 aa0:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 aa2:	00000517          	auipc	a0,0x0
 aa6:	19e53503          	ld	a0,414(a0) # c40 <freep>
 aaa:	c515                	beqz	a0,ad6 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 aac:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 aae:	4798                	lw	a4,8(a5)
 ab0:	02977f63          	bgeu	a4,s1,aee <malloc+0x70>
 ab4:	8a4e                	mv	s4,s3
 ab6:	0009871b          	sext.w	a4,s3
 aba:	6685                	lui	a3,0x1
 abc:	00d77363          	bgeu	a4,a3,ac2 <malloc+0x44>
 ac0:	6a05                	lui	s4,0x1
 ac2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 ac6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 aca:	00000917          	auipc	s2,0x0
 ace:	17690913          	addi	s2,s2,374 # c40 <freep>
  if(p == (char*)-1)
 ad2:	5afd                	li	s5,-1
 ad4:	a88d                	j	b46 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 ad6:	00000797          	auipc	a5,0x0
 ada:	17278793          	addi	a5,a5,370 # c48 <base>
 ade:	00000717          	auipc	a4,0x0
 ae2:	16f73123          	sd	a5,354(a4) # c40 <freep>
 ae6:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 ae8:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 aec:	b7e1                	j	ab4 <malloc+0x36>
      if(p->s.size == nunits)
 aee:	02e48b63          	beq	s1,a4,b24 <malloc+0xa6>
        p->s.size -= nunits;
 af2:	4137073b          	subw	a4,a4,s3
 af6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 af8:	1702                	slli	a4,a4,0x20
 afa:	9301                	srli	a4,a4,0x20
 afc:	0712                	slli	a4,a4,0x4
 afe:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 b00:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 b04:	00000717          	auipc	a4,0x0
 b08:	12a73e23          	sd	a0,316(a4) # c40 <freep>
      return (void*)(p + 1);
 b0c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 b10:	70e2                	ld	ra,56(sp)
 b12:	7442                	ld	s0,48(sp)
 b14:	74a2                	ld	s1,40(sp)
 b16:	7902                	ld	s2,32(sp)
 b18:	69e2                	ld	s3,24(sp)
 b1a:	6a42                	ld	s4,16(sp)
 b1c:	6aa2                	ld	s5,8(sp)
 b1e:	6b02                	ld	s6,0(sp)
 b20:	6121                	addi	sp,sp,64
 b22:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 b24:	6398                	ld	a4,0(a5)
 b26:	e118                	sd	a4,0(a0)
 b28:	bff1                	j	b04 <malloc+0x86>
  hp->s.size = nu;
 b2a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 b2e:	0541                	addi	a0,a0,16
 b30:	00000097          	auipc	ra,0x0
 b34:	ec6080e7          	jalr	-314(ra) # 9f6 <free>
  return freep;
 b38:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 b3c:	d971                	beqz	a0,b10 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b3e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 b40:	4798                	lw	a4,8(a5)
 b42:	fa9776e3          	bgeu	a4,s1,aee <malloc+0x70>
    if(p == freep)
 b46:	00093703          	ld	a4,0(s2)
 b4a:	853e                	mv	a0,a5
 b4c:	fef719e3          	bne	a4,a5,b3e <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 b50:	8552                	mv	a0,s4
 b52:	00000097          	auipc	ra,0x0
 b56:	b6e080e7          	jalr	-1170(ra) # 6c0 <sbrk>
  if(p == (char*)-1)
 b5a:	fd5518e3          	bne	a0,s5,b2a <malloc+0xac>
        return 0;
 b5e:	4501                	li	a0,0
 b60:	bf45                	j	b10 <malloc+0x92>
