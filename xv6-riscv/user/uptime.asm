
user/_uptime:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/date.h"
#include <time.h>

int main(){
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
    int tm=uptime();
   8:	00000097          	auipc	ra,0x0
   c:	33e080e7          	jalr	830(ra) # 346 <uptime>
    printf("System up for: %d seconds\n",tm/10);
  10:	45a9                	li	a1,10
  12:	02b545bb          	divw	a1,a0,a1
  16:	00000517          	auipc	a0,0x0
  1a:	7c250513          	addi	a0,a0,1986 # 7d8 <malloc+0xe4>
  1e:	00000097          	auipc	ra,0x0
  22:	618080e7          	jalr	1560(ra) # 636 <printf>
    // printf("RBW\n");
    exit(0);
  26:	4501                	li	a0,0
  28:	00000097          	auipc	ra,0x0
  2c:	27e080e7          	jalr	638(ra) # 2a6 <exit>

0000000000000030 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  30:	1141                	addi	sp,sp,-16
  32:	e422                	sd	s0,8(sp)
  34:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  36:	87aa                	mv	a5,a0
  38:	0585                	addi	a1,a1,1
  3a:	0785                	addi	a5,a5,1
  3c:	fff5c703          	lbu	a4,-1(a1)
  40:	fee78fa3          	sb	a4,-1(a5)
  44:	fb75                	bnez	a4,38 <strcpy+0x8>
    ;
  return os;
}
  46:	6422                	ld	s0,8(sp)
  48:	0141                	addi	sp,sp,16
  4a:	8082                	ret

000000000000004c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  4c:	1141                	addi	sp,sp,-16
  4e:	e422                	sd	s0,8(sp)
  50:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  52:	00054783          	lbu	a5,0(a0)
  56:	cb91                	beqz	a5,6a <strcmp+0x1e>
  58:	0005c703          	lbu	a4,0(a1)
  5c:	00f71763          	bne	a4,a5,6a <strcmp+0x1e>
    p++, q++;
  60:	0505                	addi	a0,a0,1
  62:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  64:	00054783          	lbu	a5,0(a0)
  68:	fbe5                	bnez	a5,58 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  6a:	0005c503          	lbu	a0,0(a1)
}
  6e:	40a7853b          	subw	a0,a5,a0
  72:	6422                	ld	s0,8(sp)
  74:	0141                	addi	sp,sp,16
  76:	8082                	ret

0000000000000078 <strlen>:

uint
strlen(const char *s)
{
  78:	1141                	addi	sp,sp,-16
  7a:	e422                	sd	s0,8(sp)
  7c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  7e:	00054783          	lbu	a5,0(a0)
  82:	cf91                	beqz	a5,9e <strlen+0x26>
  84:	0505                	addi	a0,a0,1
  86:	87aa                	mv	a5,a0
  88:	4685                	li	a3,1
  8a:	9e89                	subw	a3,a3,a0
  8c:	00f6853b          	addw	a0,a3,a5
  90:	0785                	addi	a5,a5,1
  92:	fff7c703          	lbu	a4,-1(a5)
  96:	fb7d                	bnez	a4,8c <strlen+0x14>
    ;
  return n;
}
  98:	6422                	ld	s0,8(sp)
  9a:	0141                	addi	sp,sp,16
  9c:	8082                	ret
  for(n = 0; s[n]; n++)
  9e:	4501                	li	a0,0
  a0:	bfe5                	j	98 <strlen+0x20>

00000000000000a2 <memset>:

void*
memset(void *dst, int c, uint n)
{
  a2:	1141                	addi	sp,sp,-16
  a4:	e422                	sd	s0,8(sp)
  a6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  a8:	ce09                	beqz	a2,c2 <memset+0x20>
  aa:	87aa                	mv	a5,a0
  ac:	fff6071b          	addiw	a4,a2,-1
  b0:	1702                	slli	a4,a4,0x20
  b2:	9301                	srli	a4,a4,0x20
  b4:	0705                	addi	a4,a4,1
  b6:	972a                	add	a4,a4,a0
    cdst[i] = c;
  b8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  bc:	0785                	addi	a5,a5,1
  be:	fee79de3          	bne	a5,a4,b8 <memset+0x16>
  }
  return dst;
}
  c2:	6422                	ld	s0,8(sp)
  c4:	0141                	addi	sp,sp,16
  c6:	8082                	ret

00000000000000c8 <strchr>:

char*
strchr(const char *s, char c)
{
  c8:	1141                	addi	sp,sp,-16
  ca:	e422                	sd	s0,8(sp)
  cc:	0800                	addi	s0,sp,16
  for(; *s; s++)
  ce:	00054783          	lbu	a5,0(a0)
  d2:	cb99                	beqz	a5,e8 <strchr+0x20>
    if(*s == c)
  d4:	00f58763          	beq	a1,a5,e2 <strchr+0x1a>
  for(; *s; s++)
  d8:	0505                	addi	a0,a0,1
  da:	00054783          	lbu	a5,0(a0)
  de:	fbfd                	bnez	a5,d4 <strchr+0xc>
      return (char*)s;
  return 0;
  e0:	4501                	li	a0,0
}
  e2:	6422                	ld	s0,8(sp)
  e4:	0141                	addi	sp,sp,16
  e6:	8082                	ret
  return 0;
  e8:	4501                	li	a0,0
  ea:	bfe5                	j	e2 <strchr+0x1a>

00000000000000ec <gets>:

char*
gets(char *buf, int max)
{
  ec:	711d                	addi	sp,sp,-96
  ee:	ec86                	sd	ra,88(sp)
  f0:	e8a2                	sd	s0,80(sp)
  f2:	e4a6                	sd	s1,72(sp)
  f4:	e0ca                	sd	s2,64(sp)
  f6:	fc4e                	sd	s3,56(sp)
  f8:	f852                	sd	s4,48(sp)
  fa:	f456                	sd	s5,40(sp)
  fc:	f05a                	sd	s6,32(sp)
  fe:	ec5e                	sd	s7,24(sp)
 100:	1080                	addi	s0,sp,96
 102:	8baa                	mv	s7,a0
 104:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 106:	892a                	mv	s2,a0
 108:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 10a:	4aa9                	li	s5,10
 10c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 10e:	89a6                	mv	s3,s1
 110:	2485                	addiw	s1,s1,1
 112:	0344d863          	bge	s1,s4,142 <gets+0x56>
    cc = read(0, &c, 1);
 116:	4605                	li	a2,1
 118:	faf40593          	addi	a1,s0,-81
 11c:	4501                	li	a0,0
 11e:	00000097          	auipc	ra,0x0
 122:	1a0080e7          	jalr	416(ra) # 2be <read>
    if(cc < 1)
 126:	00a05e63          	blez	a0,142 <gets+0x56>
    buf[i++] = c;
 12a:	faf44783          	lbu	a5,-81(s0)
 12e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 132:	01578763          	beq	a5,s5,140 <gets+0x54>
 136:	0905                	addi	s2,s2,1
 138:	fd679be3          	bne	a5,s6,10e <gets+0x22>
  for(i=0; i+1 < max; ){
 13c:	89a6                	mv	s3,s1
 13e:	a011                	j	142 <gets+0x56>
 140:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 142:	99de                	add	s3,s3,s7
 144:	00098023          	sb	zero,0(s3)
  return buf;
}
 148:	855e                	mv	a0,s7
 14a:	60e6                	ld	ra,88(sp)
 14c:	6446                	ld	s0,80(sp)
 14e:	64a6                	ld	s1,72(sp)
 150:	6906                	ld	s2,64(sp)
 152:	79e2                	ld	s3,56(sp)
 154:	7a42                	ld	s4,48(sp)
 156:	7aa2                	ld	s5,40(sp)
 158:	7b02                	ld	s6,32(sp)
 15a:	6be2                	ld	s7,24(sp)
 15c:	6125                	addi	sp,sp,96
 15e:	8082                	ret

0000000000000160 <stat>:

int
stat(const char *n, struct stat *st)
{
 160:	1101                	addi	sp,sp,-32
 162:	ec06                	sd	ra,24(sp)
 164:	e822                	sd	s0,16(sp)
 166:	e426                	sd	s1,8(sp)
 168:	e04a                	sd	s2,0(sp)
 16a:	1000                	addi	s0,sp,32
 16c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 16e:	4581                	li	a1,0
 170:	00000097          	auipc	ra,0x0
 174:	176080e7          	jalr	374(ra) # 2e6 <open>
  if(fd < 0)
 178:	02054563          	bltz	a0,1a2 <stat+0x42>
 17c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 17e:	85ca                	mv	a1,s2
 180:	00000097          	auipc	ra,0x0
 184:	17e080e7          	jalr	382(ra) # 2fe <fstat>
 188:	892a                	mv	s2,a0
  close(fd);
 18a:	8526                	mv	a0,s1
 18c:	00000097          	auipc	ra,0x0
 190:	142080e7          	jalr	322(ra) # 2ce <close>
  return r;
}
 194:	854a                	mv	a0,s2
 196:	60e2                	ld	ra,24(sp)
 198:	6442                	ld	s0,16(sp)
 19a:	64a2                	ld	s1,8(sp)
 19c:	6902                	ld	s2,0(sp)
 19e:	6105                	addi	sp,sp,32
 1a0:	8082                	ret
    return -1;
 1a2:	597d                	li	s2,-1
 1a4:	bfc5                	j	194 <stat+0x34>

00000000000001a6 <atoi>:

int
atoi(const char *s)
{
 1a6:	1141                	addi	sp,sp,-16
 1a8:	e422                	sd	s0,8(sp)
 1aa:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1ac:	00054603          	lbu	a2,0(a0)
 1b0:	fd06079b          	addiw	a5,a2,-48
 1b4:	0ff7f793          	andi	a5,a5,255
 1b8:	4725                	li	a4,9
 1ba:	02f76963          	bltu	a4,a5,1ec <atoi+0x46>
 1be:	86aa                	mv	a3,a0
  n = 0;
 1c0:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 1c2:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 1c4:	0685                	addi	a3,a3,1
 1c6:	0025179b          	slliw	a5,a0,0x2
 1ca:	9fa9                	addw	a5,a5,a0
 1cc:	0017979b          	slliw	a5,a5,0x1
 1d0:	9fb1                	addw	a5,a5,a2
 1d2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1d6:	0006c603          	lbu	a2,0(a3)
 1da:	fd06071b          	addiw	a4,a2,-48
 1de:	0ff77713          	andi	a4,a4,255
 1e2:	fee5f1e3          	bgeu	a1,a4,1c4 <atoi+0x1e>
  return n;
}
 1e6:	6422                	ld	s0,8(sp)
 1e8:	0141                	addi	sp,sp,16
 1ea:	8082                	ret
  n = 0;
 1ec:	4501                	li	a0,0
 1ee:	bfe5                	j	1e6 <atoi+0x40>

00000000000001f0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1f0:	1141                	addi	sp,sp,-16
 1f2:	e422                	sd	s0,8(sp)
 1f4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 1f6:	02b57663          	bgeu	a0,a1,222 <memmove+0x32>
    while(n-- > 0)
 1fa:	02c05163          	blez	a2,21c <memmove+0x2c>
 1fe:	fff6079b          	addiw	a5,a2,-1
 202:	1782                	slli	a5,a5,0x20
 204:	9381                	srli	a5,a5,0x20
 206:	0785                	addi	a5,a5,1
 208:	97aa                	add	a5,a5,a0
  dst = vdst;
 20a:	872a                	mv	a4,a0
      *dst++ = *src++;
 20c:	0585                	addi	a1,a1,1
 20e:	0705                	addi	a4,a4,1
 210:	fff5c683          	lbu	a3,-1(a1)
 214:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 218:	fee79ae3          	bne	a5,a4,20c <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 21c:	6422                	ld	s0,8(sp)
 21e:	0141                	addi	sp,sp,16
 220:	8082                	ret
    dst += n;
 222:	00c50733          	add	a4,a0,a2
    src += n;
 226:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 228:	fec05ae3          	blez	a2,21c <memmove+0x2c>
 22c:	fff6079b          	addiw	a5,a2,-1
 230:	1782                	slli	a5,a5,0x20
 232:	9381                	srli	a5,a5,0x20
 234:	fff7c793          	not	a5,a5
 238:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 23a:	15fd                	addi	a1,a1,-1
 23c:	177d                	addi	a4,a4,-1
 23e:	0005c683          	lbu	a3,0(a1)
 242:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 246:	fee79ae3          	bne	a5,a4,23a <memmove+0x4a>
 24a:	bfc9                	j	21c <memmove+0x2c>

000000000000024c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 24c:	1141                	addi	sp,sp,-16
 24e:	e422                	sd	s0,8(sp)
 250:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 252:	ca05                	beqz	a2,282 <memcmp+0x36>
 254:	fff6069b          	addiw	a3,a2,-1
 258:	1682                	slli	a3,a3,0x20
 25a:	9281                	srli	a3,a3,0x20
 25c:	0685                	addi	a3,a3,1
 25e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 260:	00054783          	lbu	a5,0(a0)
 264:	0005c703          	lbu	a4,0(a1)
 268:	00e79863          	bne	a5,a4,278 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 26c:	0505                	addi	a0,a0,1
    p2++;
 26e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 270:	fed518e3          	bne	a0,a3,260 <memcmp+0x14>
  }
  return 0;
 274:	4501                	li	a0,0
 276:	a019                	j	27c <memcmp+0x30>
      return *p1 - *p2;
 278:	40e7853b          	subw	a0,a5,a4
}
 27c:	6422                	ld	s0,8(sp)
 27e:	0141                	addi	sp,sp,16
 280:	8082                	ret
  return 0;
 282:	4501                	li	a0,0
 284:	bfe5                	j	27c <memcmp+0x30>

0000000000000286 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 286:	1141                	addi	sp,sp,-16
 288:	e406                	sd	ra,8(sp)
 28a:	e022                	sd	s0,0(sp)
 28c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 28e:	00000097          	auipc	ra,0x0
 292:	f62080e7          	jalr	-158(ra) # 1f0 <memmove>
}
 296:	60a2                	ld	ra,8(sp)
 298:	6402                	ld	s0,0(sp)
 29a:	0141                	addi	sp,sp,16
 29c:	8082                	ret

000000000000029e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 29e:	4885                	li	a7,1
 ecall
 2a0:	00000073          	ecall
 ret
 2a4:	8082                	ret

00000000000002a6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2a6:	4889                	li	a7,2
 ecall
 2a8:	00000073          	ecall
 ret
 2ac:	8082                	ret

00000000000002ae <wait>:
.global wait
wait:
 li a7, SYS_wait
 2ae:	488d                	li	a7,3
 ecall
 2b0:	00000073          	ecall
 ret
 2b4:	8082                	ret

00000000000002b6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2b6:	4891                	li	a7,4
 ecall
 2b8:	00000073          	ecall
 ret
 2bc:	8082                	ret

00000000000002be <read>:
.global read
read:
 li a7, SYS_read
 2be:	4895                	li	a7,5
 ecall
 2c0:	00000073          	ecall
 ret
 2c4:	8082                	ret

00000000000002c6 <write>:
.global write
write:
 li a7, SYS_write
 2c6:	48c1                	li	a7,16
 ecall
 2c8:	00000073          	ecall
 ret
 2cc:	8082                	ret

00000000000002ce <close>:
.global close
close:
 li a7, SYS_close
 2ce:	48d5                	li	a7,21
 ecall
 2d0:	00000073          	ecall
 ret
 2d4:	8082                	ret

00000000000002d6 <kill>:
.global kill
kill:
 li a7, SYS_kill
 2d6:	4899                	li	a7,6
 ecall
 2d8:	00000073          	ecall
 ret
 2dc:	8082                	ret

00000000000002de <exec>:
.global exec
exec:
 li a7, SYS_exec
 2de:	489d                	li	a7,7
 ecall
 2e0:	00000073          	ecall
 ret
 2e4:	8082                	ret

00000000000002e6 <open>:
.global open
open:
 li a7, SYS_open
 2e6:	48bd                	li	a7,15
 ecall
 2e8:	00000073          	ecall
 ret
 2ec:	8082                	ret

00000000000002ee <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 2ee:	48c5                	li	a7,17
 ecall
 2f0:	00000073          	ecall
 ret
 2f4:	8082                	ret

00000000000002f6 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 2f6:	48c9                	li	a7,18
 ecall
 2f8:	00000073          	ecall
 ret
 2fc:	8082                	ret

00000000000002fe <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 2fe:	48a1                	li	a7,8
 ecall
 300:	00000073          	ecall
 ret
 304:	8082                	ret

0000000000000306 <link>:
.global link
link:
 li a7, SYS_link
 306:	48cd                	li	a7,19
 ecall
 308:	00000073          	ecall
 ret
 30c:	8082                	ret

000000000000030e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 30e:	48d1                	li	a7,20
 ecall
 310:	00000073          	ecall
 ret
 314:	8082                	ret

0000000000000316 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 316:	48a5                	li	a7,9
 ecall
 318:	00000073          	ecall
 ret
 31c:	8082                	ret

000000000000031e <dup>:
.global dup
dup:
 li a7, SYS_dup
 31e:	48a9                	li	a7,10
 ecall
 320:	00000073          	ecall
 ret
 324:	8082                	ret

0000000000000326 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 326:	48ad                	li	a7,11
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 32e:	48d9                	li	a7,22
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 336:	48b1                	li	a7,12
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 33e:	48b5                	li	a7,13
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 346:	48b9                	li	a7,14
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <yield>:
.global yield
yield:
 li a7, SYS_yield
 34e:	48dd                	li	a7,23
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 356:	48e1                	li	a7,24
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 35e:	1101                	addi	sp,sp,-32
 360:	ec06                	sd	ra,24(sp)
 362:	e822                	sd	s0,16(sp)
 364:	1000                	addi	s0,sp,32
 366:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 36a:	4605                	li	a2,1
 36c:	fef40593          	addi	a1,s0,-17
 370:	00000097          	auipc	ra,0x0
 374:	f56080e7          	jalr	-170(ra) # 2c6 <write>
}
 378:	60e2                	ld	ra,24(sp)
 37a:	6442                	ld	s0,16(sp)
 37c:	6105                	addi	sp,sp,32
 37e:	8082                	ret

0000000000000380 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 380:	7139                	addi	sp,sp,-64
 382:	fc06                	sd	ra,56(sp)
 384:	f822                	sd	s0,48(sp)
 386:	f426                	sd	s1,40(sp)
 388:	f04a                	sd	s2,32(sp)
 38a:	ec4e                	sd	s3,24(sp)
 38c:	0080                	addi	s0,sp,64
 38e:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 390:	c299                	beqz	a3,396 <printint+0x16>
 392:	0805c863          	bltz	a1,422 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 396:	2581                	sext.w	a1,a1
  neg = 0;
 398:	4881                	li	a7,0
 39a:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 39e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3a0:	2601                	sext.w	a2,a2
 3a2:	00000517          	auipc	a0,0x0
 3a6:	45e50513          	addi	a0,a0,1118 # 800 <digits>
 3aa:	883a                	mv	a6,a4
 3ac:	2705                	addiw	a4,a4,1
 3ae:	02c5f7bb          	remuw	a5,a1,a2
 3b2:	1782                	slli	a5,a5,0x20
 3b4:	9381                	srli	a5,a5,0x20
 3b6:	97aa                	add	a5,a5,a0
 3b8:	0007c783          	lbu	a5,0(a5)
 3bc:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3c0:	0005879b          	sext.w	a5,a1
 3c4:	02c5d5bb          	divuw	a1,a1,a2
 3c8:	0685                	addi	a3,a3,1
 3ca:	fec7f0e3          	bgeu	a5,a2,3aa <printint+0x2a>
  if(neg)
 3ce:	00088b63          	beqz	a7,3e4 <printint+0x64>
    buf[i++] = '-';
 3d2:	fd040793          	addi	a5,s0,-48
 3d6:	973e                	add	a4,a4,a5
 3d8:	02d00793          	li	a5,45
 3dc:	fef70823          	sb	a5,-16(a4)
 3e0:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 3e4:	02e05863          	blez	a4,414 <printint+0x94>
 3e8:	fc040793          	addi	a5,s0,-64
 3ec:	00e78933          	add	s2,a5,a4
 3f0:	fff78993          	addi	s3,a5,-1
 3f4:	99ba                	add	s3,s3,a4
 3f6:	377d                	addiw	a4,a4,-1
 3f8:	1702                	slli	a4,a4,0x20
 3fa:	9301                	srli	a4,a4,0x20
 3fc:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 400:	fff94583          	lbu	a1,-1(s2)
 404:	8526                	mv	a0,s1
 406:	00000097          	auipc	ra,0x0
 40a:	f58080e7          	jalr	-168(ra) # 35e <putc>
  while(--i >= 0)
 40e:	197d                	addi	s2,s2,-1
 410:	ff3918e3          	bne	s2,s3,400 <printint+0x80>
}
 414:	70e2                	ld	ra,56(sp)
 416:	7442                	ld	s0,48(sp)
 418:	74a2                	ld	s1,40(sp)
 41a:	7902                	ld	s2,32(sp)
 41c:	69e2                	ld	s3,24(sp)
 41e:	6121                	addi	sp,sp,64
 420:	8082                	ret
    x = -xx;
 422:	40b005bb          	negw	a1,a1
    neg = 1;
 426:	4885                	li	a7,1
    x = -xx;
 428:	bf8d                	j	39a <printint+0x1a>

000000000000042a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 42a:	7119                	addi	sp,sp,-128
 42c:	fc86                	sd	ra,120(sp)
 42e:	f8a2                	sd	s0,112(sp)
 430:	f4a6                	sd	s1,104(sp)
 432:	f0ca                	sd	s2,96(sp)
 434:	ecce                	sd	s3,88(sp)
 436:	e8d2                	sd	s4,80(sp)
 438:	e4d6                	sd	s5,72(sp)
 43a:	e0da                	sd	s6,64(sp)
 43c:	fc5e                	sd	s7,56(sp)
 43e:	f862                	sd	s8,48(sp)
 440:	f466                	sd	s9,40(sp)
 442:	f06a                	sd	s10,32(sp)
 444:	ec6e                	sd	s11,24(sp)
 446:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 448:	0005c903          	lbu	s2,0(a1)
 44c:	18090f63          	beqz	s2,5ea <vprintf+0x1c0>
 450:	8aaa                	mv	s5,a0
 452:	8b32                	mv	s6,a2
 454:	00158493          	addi	s1,a1,1
  state = 0;
 458:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 45a:	02500a13          	li	s4,37
      if(c == 'd'){
 45e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 462:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 466:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 46a:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 46e:	00000b97          	auipc	s7,0x0
 472:	392b8b93          	addi	s7,s7,914 # 800 <digits>
 476:	a839                	j	494 <vprintf+0x6a>
        putc(fd, c);
 478:	85ca                	mv	a1,s2
 47a:	8556                	mv	a0,s5
 47c:	00000097          	auipc	ra,0x0
 480:	ee2080e7          	jalr	-286(ra) # 35e <putc>
 484:	a019                	j	48a <vprintf+0x60>
    } else if(state == '%'){
 486:	01498f63          	beq	s3,s4,4a4 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 48a:	0485                	addi	s1,s1,1
 48c:	fff4c903          	lbu	s2,-1(s1)
 490:	14090d63          	beqz	s2,5ea <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 494:	0009079b          	sext.w	a5,s2
    if(state == 0){
 498:	fe0997e3          	bnez	s3,486 <vprintf+0x5c>
      if(c == '%'){
 49c:	fd479ee3          	bne	a5,s4,478 <vprintf+0x4e>
        state = '%';
 4a0:	89be                	mv	s3,a5
 4a2:	b7e5                	j	48a <vprintf+0x60>
      if(c == 'd'){
 4a4:	05878063          	beq	a5,s8,4e4 <vprintf+0xba>
      } else if(c == 'l') {
 4a8:	05978c63          	beq	a5,s9,500 <vprintf+0xd6>
      } else if(c == 'x') {
 4ac:	07a78863          	beq	a5,s10,51c <vprintf+0xf2>
      } else if(c == 'p') {
 4b0:	09b78463          	beq	a5,s11,538 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 4b4:	07300713          	li	a4,115
 4b8:	0ce78663          	beq	a5,a4,584 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 4bc:	06300713          	li	a4,99
 4c0:	0ee78e63          	beq	a5,a4,5bc <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 4c4:	11478863          	beq	a5,s4,5d4 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 4c8:	85d2                	mv	a1,s4
 4ca:	8556                	mv	a0,s5
 4cc:	00000097          	auipc	ra,0x0
 4d0:	e92080e7          	jalr	-366(ra) # 35e <putc>
        putc(fd, c);
 4d4:	85ca                	mv	a1,s2
 4d6:	8556                	mv	a0,s5
 4d8:	00000097          	auipc	ra,0x0
 4dc:	e86080e7          	jalr	-378(ra) # 35e <putc>
      }
      state = 0;
 4e0:	4981                	li	s3,0
 4e2:	b765                	j	48a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 4e4:	008b0913          	addi	s2,s6,8
 4e8:	4685                	li	a3,1
 4ea:	4629                	li	a2,10
 4ec:	000b2583          	lw	a1,0(s6)
 4f0:	8556                	mv	a0,s5
 4f2:	00000097          	auipc	ra,0x0
 4f6:	e8e080e7          	jalr	-370(ra) # 380 <printint>
 4fa:	8b4a                	mv	s6,s2
      state = 0;
 4fc:	4981                	li	s3,0
 4fe:	b771                	j	48a <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 500:	008b0913          	addi	s2,s6,8
 504:	4681                	li	a3,0
 506:	4629                	li	a2,10
 508:	000b2583          	lw	a1,0(s6)
 50c:	8556                	mv	a0,s5
 50e:	00000097          	auipc	ra,0x0
 512:	e72080e7          	jalr	-398(ra) # 380 <printint>
 516:	8b4a                	mv	s6,s2
      state = 0;
 518:	4981                	li	s3,0
 51a:	bf85                	j	48a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 51c:	008b0913          	addi	s2,s6,8
 520:	4681                	li	a3,0
 522:	4641                	li	a2,16
 524:	000b2583          	lw	a1,0(s6)
 528:	8556                	mv	a0,s5
 52a:	00000097          	auipc	ra,0x0
 52e:	e56080e7          	jalr	-426(ra) # 380 <printint>
 532:	8b4a                	mv	s6,s2
      state = 0;
 534:	4981                	li	s3,0
 536:	bf91                	j	48a <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 538:	008b0793          	addi	a5,s6,8
 53c:	f8f43423          	sd	a5,-120(s0)
 540:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 544:	03000593          	li	a1,48
 548:	8556                	mv	a0,s5
 54a:	00000097          	auipc	ra,0x0
 54e:	e14080e7          	jalr	-492(ra) # 35e <putc>
  putc(fd, 'x');
 552:	85ea                	mv	a1,s10
 554:	8556                	mv	a0,s5
 556:	00000097          	auipc	ra,0x0
 55a:	e08080e7          	jalr	-504(ra) # 35e <putc>
 55e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 560:	03c9d793          	srli	a5,s3,0x3c
 564:	97de                	add	a5,a5,s7
 566:	0007c583          	lbu	a1,0(a5)
 56a:	8556                	mv	a0,s5
 56c:	00000097          	auipc	ra,0x0
 570:	df2080e7          	jalr	-526(ra) # 35e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 574:	0992                	slli	s3,s3,0x4
 576:	397d                	addiw	s2,s2,-1
 578:	fe0914e3          	bnez	s2,560 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 57c:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 580:	4981                	li	s3,0
 582:	b721                	j	48a <vprintf+0x60>
        s = va_arg(ap, char*);
 584:	008b0993          	addi	s3,s6,8
 588:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 58c:	02090163          	beqz	s2,5ae <vprintf+0x184>
        while(*s != 0){
 590:	00094583          	lbu	a1,0(s2)
 594:	c9a1                	beqz	a1,5e4 <vprintf+0x1ba>
          putc(fd, *s);
 596:	8556                	mv	a0,s5
 598:	00000097          	auipc	ra,0x0
 59c:	dc6080e7          	jalr	-570(ra) # 35e <putc>
          s++;
 5a0:	0905                	addi	s2,s2,1
        while(*s != 0){
 5a2:	00094583          	lbu	a1,0(s2)
 5a6:	f9e5                	bnez	a1,596 <vprintf+0x16c>
        s = va_arg(ap, char*);
 5a8:	8b4e                	mv	s6,s3
      state = 0;
 5aa:	4981                	li	s3,0
 5ac:	bdf9                	j	48a <vprintf+0x60>
          s = "(null)";
 5ae:	00000917          	auipc	s2,0x0
 5b2:	24a90913          	addi	s2,s2,586 # 7f8 <malloc+0x104>
        while(*s != 0){
 5b6:	02800593          	li	a1,40
 5ba:	bff1                	j	596 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 5bc:	008b0913          	addi	s2,s6,8
 5c0:	000b4583          	lbu	a1,0(s6)
 5c4:	8556                	mv	a0,s5
 5c6:	00000097          	auipc	ra,0x0
 5ca:	d98080e7          	jalr	-616(ra) # 35e <putc>
 5ce:	8b4a                	mv	s6,s2
      state = 0;
 5d0:	4981                	li	s3,0
 5d2:	bd65                	j	48a <vprintf+0x60>
        putc(fd, c);
 5d4:	85d2                	mv	a1,s4
 5d6:	8556                	mv	a0,s5
 5d8:	00000097          	auipc	ra,0x0
 5dc:	d86080e7          	jalr	-634(ra) # 35e <putc>
      state = 0;
 5e0:	4981                	li	s3,0
 5e2:	b565                	j	48a <vprintf+0x60>
        s = va_arg(ap, char*);
 5e4:	8b4e                	mv	s6,s3
      state = 0;
 5e6:	4981                	li	s3,0
 5e8:	b54d                	j	48a <vprintf+0x60>
    }
  }
}
 5ea:	70e6                	ld	ra,120(sp)
 5ec:	7446                	ld	s0,112(sp)
 5ee:	74a6                	ld	s1,104(sp)
 5f0:	7906                	ld	s2,96(sp)
 5f2:	69e6                	ld	s3,88(sp)
 5f4:	6a46                	ld	s4,80(sp)
 5f6:	6aa6                	ld	s5,72(sp)
 5f8:	6b06                	ld	s6,64(sp)
 5fa:	7be2                	ld	s7,56(sp)
 5fc:	7c42                	ld	s8,48(sp)
 5fe:	7ca2                	ld	s9,40(sp)
 600:	7d02                	ld	s10,32(sp)
 602:	6de2                	ld	s11,24(sp)
 604:	6109                	addi	sp,sp,128
 606:	8082                	ret

0000000000000608 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 608:	715d                	addi	sp,sp,-80
 60a:	ec06                	sd	ra,24(sp)
 60c:	e822                	sd	s0,16(sp)
 60e:	1000                	addi	s0,sp,32
 610:	e010                	sd	a2,0(s0)
 612:	e414                	sd	a3,8(s0)
 614:	e818                	sd	a4,16(s0)
 616:	ec1c                	sd	a5,24(s0)
 618:	03043023          	sd	a6,32(s0)
 61c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 620:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 624:	8622                	mv	a2,s0
 626:	00000097          	auipc	ra,0x0
 62a:	e04080e7          	jalr	-508(ra) # 42a <vprintf>
}
 62e:	60e2                	ld	ra,24(sp)
 630:	6442                	ld	s0,16(sp)
 632:	6161                	addi	sp,sp,80
 634:	8082                	ret

0000000000000636 <printf>:

void
printf(const char *fmt, ...)
{
 636:	711d                	addi	sp,sp,-96
 638:	ec06                	sd	ra,24(sp)
 63a:	e822                	sd	s0,16(sp)
 63c:	1000                	addi	s0,sp,32
 63e:	e40c                	sd	a1,8(s0)
 640:	e810                	sd	a2,16(s0)
 642:	ec14                	sd	a3,24(s0)
 644:	f018                	sd	a4,32(s0)
 646:	f41c                	sd	a5,40(s0)
 648:	03043823          	sd	a6,48(s0)
 64c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 650:	00840613          	addi	a2,s0,8
 654:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 658:	85aa                	mv	a1,a0
 65a:	4505                	li	a0,1
 65c:	00000097          	auipc	ra,0x0
 660:	dce080e7          	jalr	-562(ra) # 42a <vprintf>
}
 664:	60e2                	ld	ra,24(sp)
 666:	6442                	ld	s0,16(sp)
 668:	6125                	addi	sp,sp,96
 66a:	8082                	ret

000000000000066c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 66c:	1141                	addi	sp,sp,-16
 66e:	e422                	sd	s0,8(sp)
 670:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 672:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 676:	00000797          	auipc	a5,0x0
 67a:	1a27b783          	ld	a5,418(a5) # 818 <freep>
 67e:	a805                	j	6ae <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 680:	4618                	lw	a4,8(a2)
 682:	9db9                	addw	a1,a1,a4
 684:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 688:	6398                	ld	a4,0(a5)
 68a:	6318                	ld	a4,0(a4)
 68c:	fee53823          	sd	a4,-16(a0)
 690:	a091                	j	6d4 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 692:	ff852703          	lw	a4,-8(a0)
 696:	9e39                	addw	a2,a2,a4
 698:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 69a:	ff053703          	ld	a4,-16(a0)
 69e:	e398                	sd	a4,0(a5)
 6a0:	a099                	j	6e6 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6a2:	6398                	ld	a4,0(a5)
 6a4:	00e7e463          	bltu	a5,a4,6ac <free+0x40>
 6a8:	00e6ea63          	bltu	a3,a4,6bc <free+0x50>
{
 6ac:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6ae:	fed7fae3          	bgeu	a5,a3,6a2 <free+0x36>
 6b2:	6398                	ld	a4,0(a5)
 6b4:	00e6e463          	bltu	a3,a4,6bc <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6b8:	fee7eae3          	bltu	a5,a4,6ac <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 6bc:	ff852583          	lw	a1,-8(a0)
 6c0:	6390                	ld	a2,0(a5)
 6c2:	02059713          	slli	a4,a1,0x20
 6c6:	9301                	srli	a4,a4,0x20
 6c8:	0712                	slli	a4,a4,0x4
 6ca:	9736                	add	a4,a4,a3
 6cc:	fae60ae3          	beq	a2,a4,680 <free+0x14>
    bp->s.ptr = p->s.ptr;
 6d0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 6d4:	4790                	lw	a2,8(a5)
 6d6:	02061713          	slli	a4,a2,0x20
 6da:	9301                	srli	a4,a4,0x20
 6dc:	0712                	slli	a4,a4,0x4
 6de:	973e                	add	a4,a4,a5
 6e0:	fae689e3          	beq	a3,a4,692 <free+0x26>
  } else
    p->s.ptr = bp;
 6e4:	e394                	sd	a3,0(a5)
  freep = p;
 6e6:	00000717          	auipc	a4,0x0
 6ea:	12f73923          	sd	a5,306(a4) # 818 <freep>
}
 6ee:	6422                	ld	s0,8(sp)
 6f0:	0141                	addi	sp,sp,16
 6f2:	8082                	ret

00000000000006f4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 6f4:	7139                	addi	sp,sp,-64
 6f6:	fc06                	sd	ra,56(sp)
 6f8:	f822                	sd	s0,48(sp)
 6fa:	f426                	sd	s1,40(sp)
 6fc:	f04a                	sd	s2,32(sp)
 6fe:	ec4e                	sd	s3,24(sp)
 700:	e852                	sd	s4,16(sp)
 702:	e456                	sd	s5,8(sp)
 704:	e05a                	sd	s6,0(sp)
 706:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 708:	02051493          	slli	s1,a0,0x20
 70c:	9081                	srli	s1,s1,0x20
 70e:	04bd                	addi	s1,s1,15
 710:	8091                	srli	s1,s1,0x4
 712:	0014899b          	addiw	s3,s1,1
 716:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 718:	00000517          	auipc	a0,0x0
 71c:	10053503          	ld	a0,256(a0) # 818 <freep>
 720:	c515                	beqz	a0,74c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 722:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 724:	4798                	lw	a4,8(a5)
 726:	02977f63          	bgeu	a4,s1,764 <malloc+0x70>
 72a:	8a4e                	mv	s4,s3
 72c:	0009871b          	sext.w	a4,s3
 730:	6685                	lui	a3,0x1
 732:	00d77363          	bgeu	a4,a3,738 <malloc+0x44>
 736:	6a05                	lui	s4,0x1
 738:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 73c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 740:	00000917          	auipc	s2,0x0
 744:	0d890913          	addi	s2,s2,216 # 818 <freep>
  if(p == (char*)-1)
 748:	5afd                	li	s5,-1
 74a:	a88d                	j	7bc <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 74c:	00000797          	auipc	a5,0x0
 750:	0d478793          	addi	a5,a5,212 # 820 <base>
 754:	00000717          	auipc	a4,0x0
 758:	0cf73223          	sd	a5,196(a4) # 818 <freep>
 75c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 75e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 762:	b7e1                	j	72a <malloc+0x36>
      if(p->s.size == nunits)
 764:	02e48b63          	beq	s1,a4,79a <malloc+0xa6>
        p->s.size -= nunits;
 768:	4137073b          	subw	a4,a4,s3
 76c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 76e:	1702                	slli	a4,a4,0x20
 770:	9301                	srli	a4,a4,0x20
 772:	0712                	slli	a4,a4,0x4
 774:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 776:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 77a:	00000717          	auipc	a4,0x0
 77e:	08a73f23          	sd	a0,158(a4) # 818 <freep>
      return (void*)(p + 1);
 782:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 786:	70e2                	ld	ra,56(sp)
 788:	7442                	ld	s0,48(sp)
 78a:	74a2                	ld	s1,40(sp)
 78c:	7902                	ld	s2,32(sp)
 78e:	69e2                	ld	s3,24(sp)
 790:	6a42                	ld	s4,16(sp)
 792:	6aa2                	ld	s5,8(sp)
 794:	6b02                	ld	s6,0(sp)
 796:	6121                	addi	sp,sp,64
 798:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 79a:	6398                	ld	a4,0(a5)
 79c:	e118                	sd	a4,0(a0)
 79e:	bff1                	j	77a <malloc+0x86>
  hp->s.size = nu;
 7a0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7a4:	0541                	addi	a0,a0,16
 7a6:	00000097          	auipc	ra,0x0
 7aa:	ec6080e7          	jalr	-314(ra) # 66c <free>
  return freep;
 7ae:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7b2:	d971                	beqz	a0,786 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7b4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7b6:	4798                	lw	a4,8(a5)
 7b8:	fa9776e3          	bgeu	a4,s1,764 <malloc+0x70>
    if(p == freep)
 7bc:	00093703          	ld	a4,0(s2)
 7c0:	853e                	mv	a0,a5
 7c2:	fef719e3          	bne	a4,a5,7b4 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 7c6:	8552                	mv	a0,s4
 7c8:	00000097          	auipc	ra,0x0
 7cc:	b6e080e7          	jalr	-1170(ra) # 336 <sbrk>
  if(p == (char*)-1)
 7d0:	fd5518e3          	bne	a0,s5,7a0 <malloc+0xac>
        return 0;
 7d4:	4501                	li	a0,0
 7d6:	bf45                	j	786 <malloc+0x92>
