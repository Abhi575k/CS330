
user/_forksleep:     file format elf64-littleriscv


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

int main(int argc,char* argv[]){
  34:	1101                	addi	sp,sp,-32
  36:	ec06                	sd	ra,24(sp)
  38:	e822                	sd	s0,16(sp)
  3a:	e426                	sd	s1,8(sp)
  3c:	e04a                	sd	s2,0(sp)
  3e:	1000                	addi	s0,sp,32
    if(argc!=3){
  40:	478d                	li	a5,3
  42:	02f51e63          	bne	a0,a5,7e <main+0x4a>
  46:	84ae                	mv	s1,a1
        printf("Usage: forksleep <time_delay(m)> <mode(n)>\n");
        exit(0);
    }
    if(!checkInt(argv[1])||!checkInt(argv[2])||atoi(argv[2])<0||atoi(argv[2])>1){
  48:	6588                	ld	a0,8(a1)
  4a:	00000097          	auipc	ra,0x0
  4e:	fb6080e7          	jalr	-74(ra) # 0 <checkInt>
  52:	c909                	beqz	a0,64 <main+0x30>
  54:	0104b903          	ld	s2,16(s1)
  58:	854a                	mv	a0,s2
  5a:	00000097          	auipc	ra,0x0
  5e:	fa6080e7          	jalr	-90(ra) # 0 <checkInt>
  62:	e91d                	bnez	a0,98 <main+0x64>
        printf("Usage: forksleep <time_delay(m)> <mode(n)>\n");
  64:	00001517          	auipc	a0,0x1
  68:	89450513          	addi	a0,a0,-1900 # 8f8 <malloc+0xe6>
  6c:	00000097          	auipc	ra,0x0
  70:	6e8080e7          	jalr	1768(ra) # 754 <printf>
        exit(0);
  74:	4501                	li	a0,0
  76:	00000097          	auipc	ra,0x0
  7a:	34e080e7          	jalr	846(ra) # 3c4 <exit>
        printf("Usage: forksleep <time_delay(m)> <mode(n)>\n");
  7e:	00001517          	auipc	a0,0x1
  82:	87a50513          	addi	a0,a0,-1926 # 8f8 <malloc+0xe6>
  86:	00000097          	auipc	ra,0x0
  8a:	6ce080e7          	jalr	1742(ra) # 754 <printf>
        exit(0);
  8e:	4501                	li	a0,0
  90:	00000097          	auipc	ra,0x0
  94:	334080e7          	jalr	820(ra) # 3c4 <exit>
    if(!checkInt(argv[1])||!checkInt(argv[2])||atoi(argv[2])<0||atoi(argv[2])>1){
  98:	854a                	mv	a0,s2
  9a:	00000097          	auipc	ra,0x0
  9e:	22a080e7          	jalr	554(ra) # 2c4 <atoi>
  a2:	fc0541e3          	bltz	a0,64 <main+0x30>
  a6:	6888                	ld	a0,16(s1)
  a8:	00000097          	auipc	ra,0x0
  ac:	21c080e7          	jalr	540(ra) # 2c4 <atoi>
  b0:	4785                	li	a5,1
  b2:	faa7c9e3          	blt	a5,a0,64 <main+0x30>
    }

    int m=atoi(argv[1]),n=atoi(argv[2]);
  b6:	6488                	ld	a0,8(s1)
  b8:	00000097          	auipc	ra,0x0
  bc:	20c080e7          	jalr	524(ra) # 2c4 <atoi>
  c0:	892a                	mv	s2,a0
  c2:	6888                	ld	a0,16(s1)
  c4:	00000097          	auipc	ra,0x0
  c8:	200080e7          	jalr	512(ra) # 2c4 <atoi>
  cc:	84aa                	mv	s1,a0
    int f=fork();
  ce:	00000097          	auipc	ra,0x0
  d2:	2ee080e7          	jalr	750(ra) # 3bc <fork>
    if(f>0){
  d6:	02a05d63          	blez	a0,110 <main+0xdc>
        if(n==1) sleep(m);
  da:	4785                	li	a5,1
  dc:	02f48463          	beq	s1,a5,104 <main+0xd0>
        printf("%d: Parent.\n",(int)getpid());
  e0:	00000097          	auipc	ra,0x0
  e4:	364080e7          	jalr	868(ra) # 444 <getpid>
  e8:	85aa                	mv	a1,a0
  ea:	00001517          	auipc	a0,0x1
  ee:	83e50513          	addi	a0,a0,-1986 # 928 <malloc+0x116>
  f2:	00000097          	auipc	ra,0x0
  f6:	662080e7          	jalr	1634(ra) # 754 <printf>
        if(n==0) sleep(m);
        printf("%d: Child.\n",(int)getpid());
    }else{
        printf("Error creating child.\n");
    }
    exit(0);
  fa:	4501                	li	a0,0
  fc:	00000097          	auipc	ra,0x0
 100:	2c8080e7          	jalr	712(ra) # 3c4 <exit>
        if(n==1) sleep(m);
 104:	854a                	mv	a0,s2
 106:	00000097          	auipc	ra,0x0
 10a:	356080e7          	jalr	854(ra) # 45c <sleep>
 10e:	bfc9                	j	e0 <main+0xac>
    }else if(f==0){
 110:	e515                	bnez	a0,13c <main+0x108>
        if(n==0) sleep(m);
 112:	cc99                	beqz	s1,130 <main+0xfc>
        printf("%d: Child.\n",(int)getpid());
 114:	00000097          	auipc	ra,0x0
 118:	330080e7          	jalr	816(ra) # 444 <getpid>
 11c:	85aa                	mv	a1,a0
 11e:	00001517          	auipc	a0,0x1
 122:	81a50513          	addi	a0,a0,-2022 # 938 <malloc+0x126>
 126:	00000097          	auipc	ra,0x0
 12a:	62e080e7          	jalr	1582(ra) # 754 <printf>
 12e:	b7f1                	j	fa <main+0xc6>
        if(n==0) sleep(m);
 130:	854a                	mv	a0,s2
 132:	00000097          	auipc	ra,0x0
 136:	32a080e7          	jalr	810(ra) # 45c <sleep>
 13a:	bfe9                	j	114 <main+0xe0>
        printf("Error creating child.\n");
 13c:	00001517          	auipc	a0,0x1
 140:	80c50513          	addi	a0,a0,-2036 # 948 <malloc+0x136>
 144:	00000097          	auipc	ra,0x0
 148:	610080e7          	jalr	1552(ra) # 754 <printf>
 14c:	b77d                	j	fa <main+0xc6>

000000000000014e <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 14e:	1141                	addi	sp,sp,-16
 150:	e422                	sd	s0,8(sp)
 152:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 154:	87aa                	mv	a5,a0
 156:	0585                	addi	a1,a1,1
 158:	0785                	addi	a5,a5,1
 15a:	fff5c703          	lbu	a4,-1(a1)
 15e:	fee78fa3          	sb	a4,-1(a5)
 162:	fb75                	bnez	a4,156 <strcpy+0x8>
    ;
  return os;
}
 164:	6422                	ld	s0,8(sp)
 166:	0141                	addi	sp,sp,16
 168:	8082                	ret

000000000000016a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 16a:	1141                	addi	sp,sp,-16
 16c:	e422                	sd	s0,8(sp)
 16e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 170:	00054783          	lbu	a5,0(a0)
 174:	cb91                	beqz	a5,188 <strcmp+0x1e>
 176:	0005c703          	lbu	a4,0(a1)
 17a:	00f71763          	bne	a4,a5,188 <strcmp+0x1e>
    p++, q++;
 17e:	0505                	addi	a0,a0,1
 180:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 182:	00054783          	lbu	a5,0(a0)
 186:	fbe5                	bnez	a5,176 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 188:	0005c503          	lbu	a0,0(a1)
}
 18c:	40a7853b          	subw	a0,a5,a0
 190:	6422                	ld	s0,8(sp)
 192:	0141                	addi	sp,sp,16
 194:	8082                	ret

0000000000000196 <strlen>:

uint
strlen(const char *s)
{
 196:	1141                	addi	sp,sp,-16
 198:	e422                	sd	s0,8(sp)
 19a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 19c:	00054783          	lbu	a5,0(a0)
 1a0:	cf91                	beqz	a5,1bc <strlen+0x26>
 1a2:	0505                	addi	a0,a0,1
 1a4:	87aa                	mv	a5,a0
 1a6:	4685                	li	a3,1
 1a8:	9e89                	subw	a3,a3,a0
 1aa:	00f6853b          	addw	a0,a3,a5
 1ae:	0785                	addi	a5,a5,1
 1b0:	fff7c703          	lbu	a4,-1(a5)
 1b4:	fb7d                	bnez	a4,1aa <strlen+0x14>
    ;
  return n;
}
 1b6:	6422                	ld	s0,8(sp)
 1b8:	0141                	addi	sp,sp,16
 1ba:	8082                	ret
  for(n = 0; s[n]; n++)
 1bc:	4501                	li	a0,0
 1be:	bfe5                	j	1b6 <strlen+0x20>

00000000000001c0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1c0:	1141                	addi	sp,sp,-16
 1c2:	e422                	sd	s0,8(sp)
 1c4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1c6:	ce09                	beqz	a2,1e0 <memset+0x20>
 1c8:	87aa                	mv	a5,a0
 1ca:	fff6071b          	addiw	a4,a2,-1
 1ce:	1702                	slli	a4,a4,0x20
 1d0:	9301                	srli	a4,a4,0x20
 1d2:	0705                	addi	a4,a4,1
 1d4:	972a                	add	a4,a4,a0
    cdst[i] = c;
 1d6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1da:	0785                	addi	a5,a5,1
 1dc:	fee79de3          	bne	a5,a4,1d6 <memset+0x16>
  }
  return dst;
}
 1e0:	6422                	ld	s0,8(sp)
 1e2:	0141                	addi	sp,sp,16
 1e4:	8082                	ret

00000000000001e6 <strchr>:

char*
strchr(const char *s, char c)
{
 1e6:	1141                	addi	sp,sp,-16
 1e8:	e422                	sd	s0,8(sp)
 1ea:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1ec:	00054783          	lbu	a5,0(a0)
 1f0:	cb99                	beqz	a5,206 <strchr+0x20>
    if(*s == c)
 1f2:	00f58763          	beq	a1,a5,200 <strchr+0x1a>
  for(; *s; s++)
 1f6:	0505                	addi	a0,a0,1
 1f8:	00054783          	lbu	a5,0(a0)
 1fc:	fbfd                	bnez	a5,1f2 <strchr+0xc>
      return (char*)s;
  return 0;
 1fe:	4501                	li	a0,0
}
 200:	6422                	ld	s0,8(sp)
 202:	0141                	addi	sp,sp,16
 204:	8082                	ret
  return 0;
 206:	4501                	li	a0,0
 208:	bfe5                	j	200 <strchr+0x1a>

000000000000020a <gets>:

char*
gets(char *buf, int max)
{
 20a:	711d                	addi	sp,sp,-96
 20c:	ec86                	sd	ra,88(sp)
 20e:	e8a2                	sd	s0,80(sp)
 210:	e4a6                	sd	s1,72(sp)
 212:	e0ca                	sd	s2,64(sp)
 214:	fc4e                	sd	s3,56(sp)
 216:	f852                	sd	s4,48(sp)
 218:	f456                	sd	s5,40(sp)
 21a:	f05a                	sd	s6,32(sp)
 21c:	ec5e                	sd	s7,24(sp)
 21e:	1080                	addi	s0,sp,96
 220:	8baa                	mv	s7,a0
 222:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 224:	892a                	mv	s2,a0
 226:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 228:	4aa9                	li	s5,10
 22a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 22c:	89a6                	mv	s3,s1
 22e:	2485                	addiw	s1,s1,1
 230:	0344d863          	bge	s1,s4,260 <gets+0x56>
    cc = read(0, &c, 1);
 234:	4605                	li	a2,1
 236:	faf40593          	addi	a1,s0,-81
 23a:	4501                	li	a0,0
 23c:	00000097          	auipc	ra,0x0
 240:	1a0080e7          	jalr	416(ra) # 3dc <read>
    if(cc < 1)
 244:	00a05e63          	blez	a0,260 <gets+0x56>
    buf[i++] = c;
 248:	faf44783          	lbu	a5,-81(s0)
 24c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 250:	01578763          	beq	a5,s5,25e <gets+0x54>
 254:	0905                	addi	s2,s2,1
 256:	fd679be3          	bne	a5,s6,22c <gets+0x22>
  for(i=0; i+1 < max; ){
 25a:	89a6                	mv	s3,s1
 25c:	a011                	j	260 <gets+0x56>
 25e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 260:	99de                	add	s3,s3,s7
 262:	00098023          	sb	zero,0(s3)
  return buf;
}
 266:	855e                	mv	a0,s7
 268:	60e6                	ld	ra,88(sp)
 26a:	6446                	ld	s0,80(sp)
 26c:	64a6                	ld	s1,72(sp)
 26e:	6906                	ld	s2,64(sp)
 270:	79e2                	ld	s3,56(sp)
 272:	7a42                	ld	s4,48(sp)
 274:	7aa2                	ld	s5,40(sp)
 276:	7b02                	ld	s6,32(sp)
 278:	6be2                	ld	s7,24(sp)
 27a:	6125                	addi	sp,sp,96
 27c:	8082                	ret

000000000000027e <stat>:

int
stat(const char *n, struct stat *st)
{
 27e:	1101                	addi	sp,sp,-32
 280:	ec06                	sd	ra,24(sp)
 282:	e822                	sd	s0,16(sp)
 284:	e426                	sd	s1,8(sp)
 286:	e04a                	sd	s2,0(sp)
 288:	1000                	addi	s0,sp,32
 28a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 28c:	4581                	li	a1,0
 28e:	00000097          	auipc	ra,0x0
 292:	176080e7          	jalr	374(ra) # 404 <open>
  if(fd < 0)
 296:	02054563          	bltz	a0,2c0 <stat+0x42>
 29a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 29c:	85ca                	mv	a1,s2
 29e:	00000097          	auipc	ra,0x0
 2a2:	17e080e7          	jalr	382(ra) # 41c <fstat>
 2a6:	892a                	mv	s2,a0
  close(fd);
 2a8:	8526                	mv	a0,s1
 2aa:	00000097          	auipc	ra,0x0
 2ae:	142080e7          	jalr	322(ra) # 3ec <close>
  return r;
}
 2b2:	854a                	mv	a0,s2
 2b4:	60e2                	ld	ra,24(sp)
 2b6:	6442                	ld	s0,16(sp)
 2b8:	64a2                	ld	s1,8(sp)
 2ba:	6902                	ld	s2,0(sp)
 2bc:	6105                	addi	sp,sp,32
 2be:	8082                	ret
    return -1;
 2c0:	597d                	li	s2,-1
 2c2:	bfc5                	j	2b2 <stat+0x34>

00000000000002c4 <atoi>:

int
atoi(const char *s)
{
 2c4:	1141                	addi	sp,sp,-16
 2c6:	e422                	sd	s0,8(sp)
 2c8:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2ca:	00054603          	lbu	a2,0(a0)
 2ce:	fd06079b          	addiw	a5,a2,-48
 2d2:	0ff7f793          	andi	a5,a5,255
 2d6:	4725                	li	a4,9
 2d8:	02f76963          	bltu	a4,a5,30a <atoi+0x46>
 2dc:	86aa                	mv	a3,a0
  n = 0;
 2de:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 2e0:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 2e2:	0685                	addi	a3,a3,1
 2e4:	0025179b          	slliw	a5,a0,0x2
 2e8:	9fa9                	addw	a5,a5,a0
 2ea:	0017979b          	slliw	a5,a5,0x1
 2ee:	9fb1                	addw	a5,a5,a2
 2f0:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2f4:	0006c603          	lbu	a2,0(a3)
 2f8:	fd06071b          	addiw	a4,a2,-48
 2fc:	0ff77713          	andi	a4,a4,255
 300:	fee5f1e3          	bgeu	a1,a4,2e2 <atoi+0x1e>
  return n;
}
 304:	6422                	ld	s0,8(sp)
 306:	0141                	addi	sp,sp,16
 308:	8082                	ret
  n = 0;
 30a:	4501                	li	a0,0
 30c:	bfe5                	j	304 <atoi+0x40>

000000000000030e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 30e:	1141                	addi	sp,sp,-16
 310:	e422                	sd	s0,8(sp)
 312:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 314:	02b57663          	bgeu	a0,a1,340 <memmove+0x32>
    while(n-- > 0)
 318:	02c05163          	blez	a2,33a <memmove+0x2c>
 31c:	fff6079b          	addiw	a5,a2,-1
 320:	1782                	slli	a5,a5,0x20
 322:	9381                	srli	a5,a5,0x20
 324:	0785                	addi	a5,a5,1
 326:	97aa                	add	a5,a5,a0
  dst = vdst;
 328:	872a                	mv	a4,a0
      *dst++ = *src++;
 32a:	0585                	addi	a1,a1,1
 32c:	0705                	addi	a4,a4,1
 32e:	fff5c683          	lbu	a3,-1(a1)
 332:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 336:	fee79ae3          	bne	a5,a4,32a <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 33a:	6422                	ld	s0,8(sp)
 33c:	0141                	addi	sp,sp,16
 33e:	8082                	ret
    dst += n;
 340:	00c50733          	add	a4,a0,a2
    src += n;
 344:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 346:	fec05ae3          	blez	a2,33a <memmove+0x2c>
 34a:	fff6079b          	addiw	a5,a2,-1
 34e:	1782                	slli	a5,a5,0x20
 350:	9381                	srli	a5,a5,0x20
 352:	fff7c793          	not	a5,a5
 356:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 358:	15fd                	addi	a1,a1,-1
 35a:	177d                	addi	a4,a4,-1
 35c:	0005c683          	lbu	a3,0(a1)
 360:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 364:	fee79ae3          	bne	a5,a4,358 <memmove+0x4a>
 368:	bfc9                	j	33a <memmove+0x2c>

000000000000036a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 36a:	1141                	addi	sp,sp,-16
 36c:	e422                	sd	s0,8(sp)
 36e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 370:	ca05                	beqz	a2,3a0 <memcmp+0x36>
 372:	fff6069b          	addiw	a3,a2,-1
 376:	1682                	slli	a3,a3,0x20
 378:	9281                	srli	a3,a3,0x20
 37a:	0685                	addi	a3,a3,1
 37c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 37e:	00054783          	lbu	a5,0(a0)
 382:	0005c703          	lbu	a4,0(a1)
 386:	00e79863          	bne	a5,a4,396 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 38a:	0505                	addi	a0,a0,1
    p2++;
 38c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 38e:	fed518e3          	bne	a0,a3,37e <memcmp+0x14>
  }
  return 0;
 392:	4501                	li	a0,0
 394:	a019                	j	39a <memcmp+0x30>
      return *p1 - *p2;
 396:	40e7853b          	subw	a0,a5,a4
}
 39a:	6422                	ld	s0,8(sp)
 39c:	0141                	addi	sp,sp,16
 39e:	8082                	ret
  return 0;
 3a0:	4501                	li	a0,0
 3a2:	bfe5                	j	39a <memcmp+0x30>

00000000000003a4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3a4:	1141                	addi	sp,sp,-16
 3a6:	e406                	sd	ra,8(sp)
 3a8:	e022                	sd	s0,0(sp)
 3aa:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3ac:	00000097          	auipc	ra,0x0
 3b0:	f62080e7          	jalr	-158(ra) # 30e <memmove>
}
 3b4:	60a2                	ld	ra,8(sp)
 3b6:	6402                	ld	s0,0(sp)
 3b8:	0141                	addi	sp,sp,16
 3ba:	8082                	ret

00000000000003bc <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3bc:	4885                	li	a7,1
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3c4:	4889                	li	a7,2
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <wait>:
.global wait
wait:
 li a7, SYS_wait
 3cc:	488d                	li	a7,3
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3d4:	4891                	li	a7,4
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <read>:
.global read
read:
 li a7, SYS_read
 3dc:	4895                	li	a7,5
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <write>:
.global write
write:
 li a7, SYS_write
 3e4:	48c1                	li	a7,16
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <close>:
.global close
close:
 li a7, SYS_close
 3ec:	48d5                	li	a7,21
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3f4:	4899                	li	a7,6
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <exec>:
.global exec
exec:
 li a7, SYS_exec
 3fc:	489d                	li	a7,7
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <open>:
.global open
open:
 li a7, SYS_open
 404:	48bd                	li	a7,15
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 40c:	48c5                	li	a7,17
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 414:	48c9                	li	a7,18
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 41c:	48a1                	li	a7,8
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <link>:
.global link
link:
 li a7, SYS_link
 424:	48cd                	li	a7,19
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 42c:	48d1                	li	a7,20
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 434:	48a5                	li	a7,9
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <dup>:
.global dup
dup:
 li a7, SYS_dup
 43c:	48a9                	li	a7,10
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 444:	48ad                	li	a7,11
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 44c:	48d9                	li	a7,22
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 454:	48b1                	li	a7,12
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 45c:	48b5                	li	a7,13
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 464:	48b9                	li	a7,14
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <yield>:
.global yield
yield:
 li a7, SYS_yield
 46c:	48dd                	li	a7,23
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 474:	48e1                	li	a7,24
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 47c:	1101                	addi	sp,sp,-32
 47e:	ec06                	sd	ra,24(sp)
 480:	e822                	sd	s0,16(sp)
 482:	1000                	addi	s0,sp,32
 484:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 488:	4605                	li	a2,1
 48a:	fef40593          	addi	a1,s0,-17
 48e:	00000097          	auipc	ra,0x0
 492:	f56080e7          	jalr	-170(ra) # 3e4 <write>
}
 496:	60e2                	ld	ra,24(sp)
 498:	6442                	ld	s0,16(sp)
 49a:	6105                	addi	sp,sp,32
 49c:	8082                	ret

000000000000049e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 49e:	7139                	addi	sp,sp,-64
 4a0:	fc06                	sd	ra,56(sp)
 4a2:	f822                	sd	s0,48(sp)
 4a4:	f426                	sd	s1,40(sp)
 4a6:	f04a                	sd	s2,32(sp)
 4a8:	ec4e                	sd	s3,24(sp)
 4aa:	0080                	addi	s0,sp,64
 4ac:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4ae:	c299                	beqz	a3,4b4 <printint+0x16>
 4b0:	0805c863          	bltz	a1,540 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4b4:	2581                	sext.w	a1,a1
  neg = 0;
 4b6:	4881                	li	a7,0
 4b8:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4bc:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4be:	2601                	sext.w	a2,a2
 4c0:	00000517          	auipc	a0,0x0
 4c4:	4a850513          	addi	a0,a0,1192 # 968 <digits>
 4c8:	883a                	mv	a6,a4
 4ca:	2705                	addiw	a4,a4,1
 4cc:	02c5f7bb          	remuw	a5,a1,a2
 4d0:	1782                	slli	a5,a5,0x20
 4d2:	9381                	srli	a5,a5,0x20
 4d4:	97aa                	add	a5,a5,a0
 4d6:	0007c783          	lbu	a5,0(a5)
 4da:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4de:	0005879b          	sext.w	a5,a1
 4e2:	02c5d5bb          	divuw	a1,a1,a2
 4e6:	0685                	addi	a3,a3,1
 4e8:	fec7f0e3          	bgeu	a5,a2,4c8 <printint+0x2a>
  if(neg)
 4ec:	00088b63          	beqz	a7,502 <printint+0x64>
    buf[i++] = '-';
 4f0:	fd040793          	addi	a5,s0,-48
 4f4:	973e                	add	a4,a4,a5
 4f6:	02d00793          	li	a5,45
 4fa:	fef70823          	sb	a5,-16(a4)
 4fe:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 502:	02e05863          	blez	a4,532 <printint+0x94>
 506:	fc040793          	addi	a5,s0,-64
 50a:	00e78933          	add	s2,a5,a4
 50e:	fff78993          	addi	s3,a5,-1
 512:	99ba                	add	s3,s3,a4
 514:	377d                	addiw	a4,a4,-1
 516:	1702                	slli	a4,a4,0x20
 518:	9301                	srli	a4,a4,0x20
 51a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 51e:	fff94583          	lbu	a1,-1(s2)
 522:	8526                	mv	a0,s1
 524:	00000097          	auipc	ra,0x0
 528:	f58080e7          	jalr	-168(ra) # 47c <putc>
  while(--i >= 0)
 52c:	197d                	addi	s2,s2,-1
 52e:	ff3918e3          	bne	s2,s3,51e <printint+0x80>
}
 532:	70e2                	ld	ra,56(sp)
 534:	7442                	ld	s0,48(sp)
 536:	74a2                	ld	s1,40(sp)
 538:	7902                	ld	s2,32(sp)
 53a:	69e2                	ld	s3,24(sp)
 53c:	6121                	addi	sp,sp,64
 53e:	8082                	ret
    x = -xx;
 540:	40b005bb          	negw	a1,a1
    neg = 1;
 544:	4885                	li	a7,1
    x = -xx;
 546:	bf8d                	j	4b8 <printint+0x1a>

0000000000000548 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 548:	7119                	addi	sp,sp,-128
 54a:	fc86                	sd	ra,120(sp)
 54c:	f8a2                	sd	s0,112(sp)
 54e:	f4a6                	sd	s1,104(sp)
 550:	f0ca                	sd	s2,96(sp)
 552:	ecce                	sd	s3,88(sp)
 554:	e8d2                	sd	s4,80(sp)
 556:	e4d6                	sd	s5,72(sp)
 558:	e0da                	sd	s6,64(sp)
 55a:	fc5e                	sd	s7,56(sp)
 55c:	f862                	sd	s8,48(sp)
 55e:	f466                	sd	s9,40(sp)
 560:	f06a                	sd	s10,32(sp)
 562:	ec6e                	sd	s11,24(sp)
 564:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 566:	0005c903          	lbu	s2,0(a1)
 56a:	18090f63          	beqz	s2,708 <vprintf+0x1c0>
 56e:	8aaa                	mv	s5,a0
 570:	8b32                	mv	s6,a2
 572:	00158493          	addi	s1,a1,1
  state = 0;
 576:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 578:	02500a13          	li	s4,37
      if(c == 'd'){
 57c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 580:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 584:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 588:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 58c:	00000b97          	auipc	s7,0x0
 590:	3dcb8b93          	addi	s7,s7,988 # 968 <digits>
 594:	a839                	j	5b2 <vprintf+0x6a>
        putc(fd, c);
 596:	85ca                	mv	a1,s2
 598:	8556                	mv	a0,s5
 59a:	00000097          	auipc	ra,0x0
 59e:	ee2080e7          	jalr	-286(ra) # 47c <putc>
 5a2:	a019                	j	5a8 <vprintf+0x60>
    } else if(state == '%'){
 5a4:	01498f63          	beq	s3,s4,5c2 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5a8:	0485                	addi	s1,s1,1
 5aa:	fff4c903          	lbu	s2,-1(s1)
 5ae:	14090d63          	beqz	s2,708 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 5b2:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5b6:	fe0997e3          	bnez	s3,5a4 <vprintf+0x5c>
      if(c == '%'){
 5ba:	fd479ee3          	bne	a5,s4,596 <vprintf+0x4e>
        state = '%';
 5be:	89be                	mv	s3,a5
 5c0:	b7e5                	j	5a8 <vprintf+0x60>
      if(c == 'd'){
 5c2:	05878063          	beq	a5,s8,602 <vprintf+0xba>
      } else if(c == 'l') {
 5c6:	05978c63          	beq	a5,s9,61e <vprintf+0xd6>
      } else if(c == 'x') {
 5ca:	07a78863          	beq	a5,s10,63a <vprintf+0xf2>
      } else if(c == 'p') {
 5ce:	09b78463          	beq	a5,s11,656 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 5d2:	07300713          	li	a4,115
 5d6:	0ce78663          	beq	a5,a4,6a2 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5da:	06300713          	li	a4,99
 5de:	0ee78e63          	beq	a5,a4,6da <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 5e2:	11478863          	beq	a5,s4,6f2 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5e6:	85d2                	mv	a1,s4
 5e8:	8556                	mv	a0,s5
 5ea:	00000097          	auipc	ra,0x0
 5ee:	e92080e7          	jalr	-366(ra) # 47c <putc>
        putc(fd, c);
 5f2:	85ca                	mv	a1,s2
 5f4:	8556                	mv	a0,s5
 5f6:	00000097          	auipc	ra,0x0
 5fa:	e86080e7          	jalr	-378(ra) # 47c <putc>
      }
      state = 0;
 5fe:	4981                	li	s3,0
 600:	b765                	j	5a8 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 602:	008b0913          	addi	s2,s6,8
 606:	4685                	li	a3,1
 608:	4629                	li	a2,10
 60a:	000b2583          	lw	a1,0(s6)
 60e:	8556                	mv	a0,s5
 610:	00000097          	auipc	ra,0x0
 614:	e8e080e7          	jalr	-370(ra) # 49e <printint>
 618:	8b4a                	mv	s6,s2
      state = 0;
 61a:	4981                	li	s3,0
 61c:	b771                	j	5a8 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 61e:	008b0913          	addi	s2,s6,8
 622:	4681                	li	a3,0
 624:	4629                	li	a2,10
 626:	000b2583          	lw	a1,0(s6)
 62a:	8556                	mv	a0,s5
 62c:	00000097          	auipc	ra,0x0
 630:	e72080e7          	jalr	-398(ra) # 49e <printint>
 634:	8b4a                	mv	s6,s2
      state = 0;
 636:	4981                	li	s3,0
 638:	bf85                	j	5a8 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 63a:	008b0913          	addi	s2,s6,8
 63e:	4681                	li	a3,0
 640:	4641                	li	a2,16
 642:	000b2583          	lw	a1,0(s6)
 646:	8556                	mv	a0,s5
 648:	00000097          	auipc	ra,0x0
 64c:	e56080e7          	jalr	-426(ra) # 49e <printint>
 650:	8b4a                	mv	s6,s2
      state = 0;
 652:	4981                	li	s3,0
 654:	bf91                	j	5a8 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 656:	008b0793          	addi	a5,s6,8
 65a:	f8f43423          	sd	a5,-120(s0)
 65e:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 662:	03000593          	li	a1,48
 666:	8556                	mv	a0,s5
 668:	00000097          	auipc	ra,0x0
 66c:	e14080e7          	jalr	-492(ra) # 47c <putc>
  putc(fd, 'x');
 670:	85ea                	mv	a1,s10
 672:	8556                	mv	a0,s5
 674:	00000097          	auipc	ra,0x0
 678:	e08080e7          	jalr	-504(ra) # 47c <putc>
 67c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 67e:	03c9d793          	srli	a5,s3,0x3c
 682:	97de                	add	a5,a5,s7
 684:	0007c583          	lbu	a1,0(a5)
 688:	8556                	mv	a0,s5
 68a:	00000097          	auipc	ra,0x0
 68e:	df2080e7          	jalr	-526(ra) # 47c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 692:	0992                	slli	s3,s3,0x4
 694:	397d                	addiw	s2,s2,-1
 696:	fe0914e3          	bnez	s2,67e <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 69a:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 69e:	4981                	li	s3,0
 6a0:	b721                	j	5a8 <vprintf+0x60>
        s = va_arg(ap, char*);
 6a2:	008b0993          	addi	s3,s6,8
 6a6:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 6aa:	02090163          	beqz	s2,6cc <vprintf+0x184>
        while(*s != 0){
 6ae:	00094583          	lbu	a1,0(s2)
 6b2:	c9a1                	beqz	a1,702 <vprintf+0x1ba>
          putc(fd, *s);
 6b4:	8556                	mv	a0,s5
 6b6:	00000097          	auipc	ra,0x0
 6ba:	dc6080e7          	jalr	-570(ra) # 47c <putc>
          s++;
 6be:	0905                	addi	s2,s2,1
        while(*s != 0){
 6c0:	00094583          	lbu	a1,0(s2)
 6c4:	f9e5                	bnez	a1,6b4 <vprintf+0x16c>
        s = va_arg(ap, char*);
 6c6:	8b4e                	mv	s6,s3
      state = 0;
 6c8:	4981                	li	s3,0
 6ca:	bdf9                	j	5a8 <vprintf+0x60>
          s = "(null)";
 6cc:	00000917          	auipc	s2,0x0
 6d0:	29490913          	addi	s2,s2,660 # 960 <malloc+0x14e>
        while(*s != 0){
 6d4:	02800593          	li	a1,40
 6d8:	bff1                	j	6b4 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 6da:	008b0913          	addi	s2,s6,8
 6de:	000b4583          	lbu	a1,0(s6)
 6e2:	8556                	mv	a0,s5
 6e4:	00000097          	auipc	ra,0x0
 6e8:	d98080e7          	jalr	-616(ra) # 47c <putc>
 6ec:	8b4a                	mv	s6,s2
      state = 0;
 6ee:	4981                	li	s3,0
 6f0:	bd65                	j	5a8 <vprintf+0x60>
        putc(fd, c);
 6f2:	85d2                	mv	a1,s4
 6f4:	8556                	mv	a0,s5
 6f6:	00000097          	auipc	ra,0x0
 6fa:	d86080e7          	jalr	-634(ra) # 47c <putc>
      state = 0;
 6fe:	4981                	li	s3,0
 700:	b565                	j	5a8 <vprintf+0x60>
        s = va_arg(ap, char*);
 702:	8b4e                	mv	s6,s3
      state = 0;
 704:	4981                	li	s3,0
 706:	b54d                	j	5a8 <vprintf+0x60>
    }
  }
}
 708:	70e6                	ld	ra,120(sp)
 70a:	7446                	ld	s0,112(sp)
 70c:	74a6                	ld	s1,104(sp)
 70e:	7906                	ld	s2,96(sp)
 710:	69e6                	ld	s3,88(sp)
 712:	6a46                	ld	s4,80(sp)
 714:	6aa6                	ld	s5,72(sp)
 716:	6b06                	ld	s6,64(sp)
 718:	7be2                	ld	s7,56(sp)
 71a:	7c42                	ld	s8,48(sp)
 71c:	7ca2                	ld	s9,40(sp)
 71e:	7d02                	ld	s10,32(sp)
 720:	6de2                	ld	s11,24(sp)
 722:	6109                	addi	sp,sp,128
 724:	8082                	ret

0000000000000726 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 726:	715d                	addi	sp,sp,-80
 728:	ec06                	sd	ra,24(sp)
 72a:	e822                	sd	s0,16(sp)
 72c:	1000                	addi	s0,sp,32
 72e:	e010                	sd	a2,0(s0)
 730:	e414                	sd	a3,8(s0)
 732:	e818                	sd	a4,16(s0)
 734:	ec1c                	sd	a5,24(s0)
 736:	03043023          	sd	a6,32(s0)
 73a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 73e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 742:	8622                	mv	a2,s0
 744:	00000097          	auipc	ra,0x0
 748:	e04080e7          	jalr	-508(ra) # 548 <vprintf>
}
 74c:	60e2                	ld	ra,24(sp)
 74e:	6442                	ld	s0,16(sp)
 750:	6161                	addi	sp,sp,80
 752:	8082                	ret

0000000000000754 <printf>:

void
printf(const char *fmt, ...)
{
 754:	711d                	addi	sp,sp,-96
 756:	ec06                	sd	ra,24(sp)
 758:	e822                	sd	s0,16(sp)
 75a:	1000                	addi	s0,sp,32
 75c:	e40c                	sd	a1,8(s0)
 75e:	e810                	sd	a2,16(s0)
 760:	ec14                	sd	a3,24(s0)
 762:	f018                	sd	a4,32(s0)
 764:	f41c                	sd	a5,40(s0)
 766:	03043823          	sd	a6,48(s0)
 76a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 76e:	00840613          	addi	a2,s0,8
 772:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 776:	85aa                	mv	a1,a0
 778:	4505                	li	a0,1
 77a:	00000097          	auipc	ra,0x0
 77e:	dce080e7          	jalr	-562(ra) # 548 <vprintf>
}
 782:	60e2                	ld	ra,24(sp)
 784:	6442                	ld	s0,16(sp)
 786:	6125                	addi	sp,sp,96
 788:	8082                	ret

000000000000078a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 78a:	1141                	addi	sp,sp,-16
 78c:	e422                	sd	s0,8(sp)
 78e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 790:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 794:	00000797          	auipc	a5,0x0
 798:	1ec7b783          	ld	a5,492(a5) # 980 <freep>
 79c:	a805                	j	7cc <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 79e:	4618                	lw	a4,8(a2)
 7a0:	9db9                	addw	a1,a1,a4
 7a2:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7a6:	6398                	ld	a4,0(a5)
 7a8:	6318                	ld	a4,0(a4)
 7aa:	fee53823          	sd	a4,-16(a0)
 7ae:	a091                	j	7f2 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7b0:	ff852703          	lw	a4,-8(a0)
 7b4:	9e39                	addw	a2,a2,a4
 7b6:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7b8:	ff053703          	ld	a4,-16(a0)
 7bc:	e398                	sd	a4,0(a5)
 7be:	a099                	j	804 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7c0:	6398                	ld	a4,0(a5)
 7c2:	00e7e463          	bltu	a5,a4,7ca <free+0x40>
 7c6:	00e6ea63          	bltu	a3,a4,7da <free+0x50>
{
 7ca:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7cc:	fed7fae3          	bgeu	a5,a3,7c0 <free+0x36>
 7d0:	6398                	ld	a4,0(a5)
 7d2:	00e6e463          	bltu	a3,a4,7da <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7d6:	fee7eae3          	bltu	a5,a4,7ca <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 7da:	ff852583          	lw	a1,-8(a0)
 7de:	6390                	ld	a2,0(a5)
 7e0:	02059713          	slli	a4,a1,0x20
 7e4:	9301                	srli	a4,a4,0x20
 7e6:	0712                	slli	a4,a4,0x4
 7e8:	9736                	add	a4,a4,a3
 7ea:	fae60ae3          	beq	a2,a4,79e <free+0x14>
    bp->s.ptr = p->s.ptr;
 7ee:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7f2:	4790                	lw	a2,8(a5)
 7f4:	02061713          	slli	a4,a2,0x20
 7f8:	9301                	srli	a4,a4,0x20
 7fa:	0712                	slli	a4,a4,0x4
 7fc:	973e                	add	a4,a4,a5
 7fe:	fae689e3          	beq	a3,a4,7b0 <free+0x26>
  } else
    p->s.ptr = bp;
 802:	e394                	sd	a3,0(a5)
  freep = p;
 804:	00000717          	auipc	a4,0x0
 808:	16f73e23          	sd	a5,380(a4) # 980 <freep>
}
 80c:	6422                	ld	s0,8(sp)
 80e:	0141                	addi	sp,sp,16
 810:	8082                	ret

0000000000000812 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 812:	7139                	addi	sp,sp,-64
 814:	fc06                	sd	ra,56(sp)
 816:	f822                	sd	s0,48(sp)
 818:	f426                	sd	s1,40(sp)
 81a:	f04a                	sd	s2,32(sp)
 81c:	ec4e                	sd	s3,24(sp)
 81e:	e852                	sd	s4,16(sp)
 820:	e456                	sd	s5,8(sp)
 822:	e05a                	sd	s6,0(sp)
 824:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 826:	02051493          	slli	s1,a0,0x20
 82a:	9081                	srli	s1,s1,0x20
 82c:	04bd                	addi	s1,s1,15
 82e:	8091                	srli	s1,s1,0x4
 830:	0014899b          	addiw	s3,s1,1
 834:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 836:	00000517          	auipc	a0,0x0
 83a:	14a53503          	ld	a0,330(a0) # 980 <freep>
 83e:	c515                	beqz	a0,86a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 840:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 842:	4798                	lw	a4,8(a5)
 844:	02977f63          	bgeu	a4,s1,882 <malloc+0x70>
 848:	8a4e                	mv	s4,s3
 84a:	0009871b          	sext.w	a4,s3
 84e:	6685                	lui	a3,0x1
 850:	00d77363          	bgeu	a4,a3,856 <malloc+0x44>
 854:	6a05                	lui	s4,0x1
 856:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 85a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 85e:	00000917          	auipc	s2,0x0
 862:	12290913          	addi	s2,s2,290 # 980 <freep>
  if(p == (char*)-1)
 866:	5afd                	li	s5,-1
 868:	a88d                	j	8da <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 86a:	00000797          	auipc	a5,0x0
 86e:	11e78793          	addi	a5,a5,286 # 988 <base>
 872:	00000717          	auipc	a4,0x0
 876:	10f73723          	sd	a5,270(a4) # 980 <freep>
 87a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 87c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 880:	b7e1                	j	848 <malloc+0x36>
      if(p->s.size == nunits)
 882:	02e48b63          	beq	s1,a4,8b8 <malloc+0xa6>
        p->s.size -= nunits;
 886:	4137073b          	subw	a4,a4,s3
 88a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 88c:	1702                	slli	a4,a4,0x20
 88e:	9301                	srli	a4,a4,0x20
 890:	0712                	slli	a4,a4,0x4
 892:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 894:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 898:	00000717          	auipc	a4,0x0
 89c:	0ea73423          	sd	a0,232(a4) # 980 <freep>
      return (void*)(p + 1);
 8a0:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8a4:	70e2                	ld	ra,56(sp)
 8a6:	7442                	ld	s0,48(sp)
 8a8:	74a2                	ld	s1,40(sp)
 8aa:	7902                	ld	s2,32(sp)
 8ac:	69e2                	ld	s3,24(sp)
 8ae:	6a42                	ld	s4,16(sp)
 8b0:	6aa2                	ld	s5,8(sp)
 8b2:	6b02                	ld	s6,0(sp)
 8b4:	6121                	addi	sp,sp,64
 8b6:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8b8:	6398                	ld	a4,0(a5)
 8ba:	e118                	sd	a4,0(a0)
 8bc:	bff1                	j	898 <malloc+0x86>
  hp->s.size = nu;
 8be:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8c2:	0541                	addi	a0,a0,16
 8c4:	00000097          	auipc	ra,0x0
 8c8:	ec6080e7          	jalr	-314(ra) # 78a <free>
  return freep;
 8cc:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8d0:	d971                	beqz	a0,8a4 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8d2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8d4:	4798                	lw	a4,8(a5)
 8d6:	fa9776e3          	bgeu	a4,s1,882 <malloc+0x70>
    if(p == freep)
 8da:	00093703          	ld	a4,0(s2)
 8de:	853e                	mv	a0,a5
 8e0:	fef719e3          	bne	a4,a5,8d2 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 8e4:	8552                	mv	a0,s4
 8e6:	00000097          	auipc	ra,0x0
 8ea:	b6e080e7          	jalr	-1170(ra) # 454 <sbrk>
  if(p == (char*)-1)
 8ee:	fd5518e3          	bne	a0,s5,8be <malloc+0xac>
        return 0;
 8f2:	4501                	li	a0,0
 8f4:	bf45                	j	8a4 <malloc+0x92>
