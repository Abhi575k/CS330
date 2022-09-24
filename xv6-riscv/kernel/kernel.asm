
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	8d013103          	ld	sp,-1840(sp) # 800088d0 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	00009717          	auipc	a4,0x9
    80000056:	fee70713          	addi	a4,a4,-18 # 80009040 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00006797          	auipc	a5,0x6
    80000068:	e9c78793          	addi	a5,a5,-356 # 80005f00 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd87ff>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	de078793          	addi	a5,a5,-544 # 80000e8e <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d8:	57fd                	li	a5,-1
    800000da:	83a9                	srli	a5,a5,0xa
    800000dc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000e0:	47bd                	li	a5,15
    800000e2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e6:	00000097          	auipc	ra,0x0
    800000ea:	f36080e7          	jalr	-202(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ee:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f2:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f6:	30200073          	mret
}
    800000fa:	60a2                	ld	ra,8(sp)
    800000fc:	6402                	ld	s0,0(sp)
    800000fe:	0141                	addi	sp,sp,16
    80000100:	8082                	ret

0000000080000102 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000102:	715d                	addi	sp,sp,-80
    80000104:	e486                	sd	ra,72(sp)
    80000106:	e0a2                	sd	s0,64(sp)
    80000108:	fc26                	sd	s1,56(sp)
    8000010a:	f84a                	sd	s2,48(sp)
    8000010c:	f44e                	sd	s3,40(sp)
    8000010e:	f052                	sd	s4,32(sp)
    80000110:	ec56                	sd	s5,24(sp)
    80000112:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000114:	04c05663          	blez	a2,80000160 <consolewrite+0x5e>
    80000118:	8a2a                	mv	s4,a0
    8000011a:	84ae                	mv	s1,a1
    8000011c:	89b2                	mv	s3,a2
    8000011e:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000120:	5afd                	li	s5,-1
    80000122:	4685                	li	a3,1
    80000124:	8626                	mv	a2,s1
    80000126:	85d2                	mv	a1,s4
    80000128:	fbf40513          	addi	a0,s0,-65
    8000012c:	00002097          	auipc	ra,0x2
    80000130:	33a080e7          	jalr	826(ra) # 80002466 <either_copyin>
    80000134:	01550c63          	beq	a0,s5,8000014c <consolewrite+0x4a>
      break;
    uartputc(c);
    80000138:	fbf44503          	lbu	a0,-65(s0)
    8000013c:	00000097          	auipc	ra,0x0
    80000140:	78e080e7          	jalr	1934(ra) # 800008ca <uartputc>
  for(i = 0; i < n; i++){
    80000144:	2905                	addiw	s2,s2,1
    80000146:	0485                	addi	s1,s1,1
    80000148:	fd299de3          	bne	s3,s2,80000122 <consolewrite+0x20>
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4a>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7119                	addi	sp,sp,-128
    80000166:	fc86                	sd	ra,120(sp)
    80000168:	f8a2                	sd	s0,112(sp)
    8000016a:	f4a6                	sd	s1,104(sp)
    8000016c:	f0ca                	sd	s2,96(sp)
    8000016e:	ecce                	sd	s3,88(sp)
    80000170:	e8d2                	sd	s4,80(sp)
    80000172:	e4d6                	sd	s5,72(sp)
    80000174:	e0da                	sd	s6,64(sp)
    80000176:	fc5e                	sd	s7,56(sp)
    80000178:	f862                	sd	s8,48(sp)
    8000017a:	f466                	sd	s9,40(sp)
    8000017c:	f06a                	sd	s10,32(sp)
    8000017e:	ec6e                	sd	s11,24(sp)
    80000180:	0100                	addi	s0,sp,128
    80000182:	8b2a                	mv	s6,a0
    80000184:	8aae                	mv	s5,a1
    80000186:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000188:	00060b9b          	sext.w	s7,a2
  acquire(&cons.lock);
    8000018c:	00011517          	auipc	a0,0x11
    80000190:	ff450513          	addi	a0,a0,-12 # 80011180 <cons>
    80000194:	00001097          	auipc	ra,0x1
    80000198:	a50080e7          	jalr	-1456(ra) # 80000be4 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019c:	00011497          	auipc	s1,0x11
    800001a0:	fe448493          	addi	s1,s1,-28 # 80011180 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a4:	89a6                	mv	s3,s1
    800001a6:	00011917          	auipc	s2,0x11
    800001aa:	07290913          	addi	s2,s2,114 # 80011218 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800001ae:	4c91                	li	s9,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001b0:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001b2:	4da9                	li	s11,10
  while(n > 0){
    800001b4:	07405863          	blez	s4,80000224 <consoleread+0xc0>
    while(cons.r == cons.w){
    800001b8:	0984a783          	lw	a5,152(s1)
    800001bc:	09c4a703          	lw	a4,156(s1)
    800001c0:	02f71463          	bne	a4,a5,800001e8 <consoleread+0x84>
      if(myproc()->killed){
    800001c4:	00001097          	auipc	ra,0x1
    800001c8:	7ec080e7          	jalr	2028(ra) # 800019b0 <myproc>
    800001cc:	551c                	lw	a5,40(a0)
    800001ce:	e7b5                	bnez	a5,8000023a <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    800001d0:	85ce                	mv	a1,s3
    800001d2:	854a                	mv	a0,s2
    800001d4:	00002097          	auipc	ra,0x2
    800001d8:	e98080e7          	jalr	-360(ra) # 8000206c <sleep>
    while(cons.r == cons.w){
    800001dc:	0984a783          	lw	a5,152(s1)
    800001e0:	09c4a703          	lw	a4,156(s1)
    800001e4:	fef700e3          	beq	a4,a5,800001c4 <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001e8:	0017871b          	addiw	a4,a5,1
    800001ec:	08e4ac23          	sw	a4,152(s1)
    800001f0:	07f7f713          	andi	a4,a5,127
    800001f4:	9726                	add	a4,a4,s1
    800001f6:	01874703          	lbu	a4,24(a4)
    800001fa:	00070c1b          	sext.w	s8,a4
    if(c == C('D')){  // end-of-file
    800001fe:	079c0663          	beq	s8,s9,8000026a <consoleread+0x106>
    cbuf = c;
    80000202:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000206:	4685                	li	a3,1
    80000208:	f8f40613          	addi	a2,s0,-113
    8000020c:	85d6                	mv	a1,s5
    8000020e:	855a                	mv	a0,s6
    80000210:	00002097          	auipc	ra,0x2
    80000214:	200080e7          	jalr	512(ra) # 80002410 <either_copyout>
    80000218:	01a50663          	beq	a0,s10,80000224 <consoleread+0xc0>
    dst++;
    8000021c:	0a85                	addi	s5,s5,1
    --n;
    8000021e:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    80000220:	f9bc1ae3          	bne	s8,s11,800001b4 <consoleread+0x50>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000224:	00011517          	auipc	a0,0x11
    80000228:	f5c50513          	addi	a0,a0,-164 # 80011180 <cons>
    8000022c:	00001097          	auipc	ra,0x1
    80000230:	a6c080e7          	jalr	-1428(ra) # 80000c98 <release>

  return target - n;
    80000234:	414b853b          	subw	a0,s7,s4
    80000238:	a811                	j	8000024c <consoleread+0xe8>
        release(&cons.lock);
    8000023a:	00011517          	auipc	a0,0x11
    8000023e:	f4650513          	addi	a0,a0,-186 # 80011180 <cons>
    80000242:	00001097          	auipc	ra,0x1
    80000246:	a56080e7          	jalr	-1450(ra) # 80000c98 <release>
        return -1;
    8000024a:	557d                	li	a0,-1
}
    8000024c:	70e6                	ld	ra,120(sp)
    8000024e:	7446                	ld	s0,112(sp)
    80000250:	74a6                	ld	s1,104(sp)
    80000252:	7906                	ld	s2,96(sp)
    80000254:	69e6                	ld	s3,88(sp)
    80000256:	6a46                	ld	s4,80(sp)
    80000258:	6aa6                	ld	s5,72(sp)
    8000025a:	6b06                	ld	s6,64(sp)
    8000025c:	7be2                	ld	s7,56(sp)
    8000025e:	7c42                	ld	s8,48(sp)
    80000260:	7ca2                	ld	s9,40(sp)
    80000262:	7d02                	ld	s10,32(sp)
    80000264:	6de2                	ld	s11,24(sp)
    80000266:	6109                	addi	sp,sp,128
    80000268:	8082                	ret
      if(n < target){
    8000026a:	000a071b          	sext.w	a4,s4
    8000026e:	fb777be3          	bgeu	a4,s7,80000224 <consoleread+0xc0>
        cons.r--;
    80000272:	00011717          	auipc	a4,0x11
    80000276:	faf72323          	sw	a5,-90(a4) # 80011218 <cons+0x98>
    8000027a:	b76d                	j	80000224 <consoleread+0xc0>

000000008000027c <consputc>:
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000284:	10000793          	li	a5,256
    80000288:	00f50a63          	beq	a0,a5,8000029c <consputc+0x20>
    uartputc_sync(c);
    8000028c:	00000097          	auipc	ra,0x0
    80000290:	564080e7          	jalr	1380(ra) # 800007f0 <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	552080e7          	jalr	1362(ra) # 800007f0 <uartputc_sync>
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	546080e7          	jalr	1350(ra) # 800007f0 <uartputc_sync>
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	53c080e7          	jalr	1340(ra) # 800007f0 <uartputc_sync>
    800002bc:	bfe1                	j	80000294 <consputc+0x18>

00000000800002be <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002be:	1101                	addi	sp,sp,-32
    800002c0:	ec06                	sd	ra,24(sp)
    800002c2:	e822                	sd	s0,16(sp)
    800002c4:	e426                	sd	s1,8(sp)
    800002c6:	e04a                	sd	s2,0(sp)
    800002c8:	1000                	addi	s0,sp,32
    800002ca:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002cc:	00011517          	auipc	a0,0x11
    800002d0:	eb450513          	addi	a0,a0,-332 # 80011180 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	910080e7          	jalr	-1776(ra) # 80000be4 <acquire>

  switch(c){
    800002dc:	47d5                	li	a5,21
    800002de:	0af48663          	beq	s1,a5,8000038a <consoleintr+0xcc>
    800002e2:	0297ca63          	blt	a5,s1,80000316 <consoleintr+0x58>
    800002e6:	47a1                	li	a5,8
    800002e8:	0ef48763          	beq	s1,a5,800003d6 <consoleintr+0x118>
    800002ec:	47c1                	li	a5,16
    800002ee:	10f49a63          	bne	s1,a5,80000402 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f2:	00002097          	auipc	ra,0x2
    800002f6:	1ca080e7          	jalr	458(ra) # 800024bc <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00011517          	auipc	a0,0x11
    800002fe:	e8650513          	addi	a0,a0,-378 # 80011180 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	996080e7          	jalr	-1642(ra) # 80000c98 <release>
}
    8000030a:	60e2                	ld	ra,24(sp)
    8000030c:	6442                	ld	s0,16(sp)
    8000030e:	64a2                	ld	s1,8(sp)
    80000310:	6902                	ld	s2,0(sp)
    80000312:	6105                	addi	sp,sp,32
    80000314:	8082                	ret
  switch(c){
    80000316:	07f00793          	li	a5,127
    8000031a:	0af48e63          	beq	s1,a5,800003d6 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000031e:	00011717          	auipc	a4,0x11
    80000322:	e6270713          	addi	a4,a4,-414 # 80011180 <cons>
    80000326:	0a072783          	lw	a5,160(a4)
    8000032a:	09872703          	lw	a4,152(a4)
    8000032e:	9f99                	subw	a5,a5,a4
    80000330:	07f00713          	li	a4,127
    80000334:	fcf763e3          	bltu	a4,a5,800002fa <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000338:	47b5                	li	a5,13
    8000033a:	0cf48763          	beq	s1,a5,80000408 <consoleintr+0x14a>
      consputc(c);
    8000033e:	8526                	mv	a0,s1
    80000340:	00000097          	auipc	ra,0x0
    80000344:	f3c080e7          	jalr	-196(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000348:	00011797          	auipc	a5,0x11
    8000034c:	e3878793          	addi	a5,a5,-456 # 80011180 <cons>
    80000350:	0a07a703          	lw	a4,160(a5)
    80000354:	0017069b          	addiw	a3,a4,1
    80000358:	0006861b          	sext.w	a2,a3
    8000035c:	0ad7a023          	sw	a3,160(a5)
    80000360:	07f77713          	andi	a4,a4,127
    80000364:	97ba                	add	a5,a5,a4
    80000366:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    8000036a:	47a9                	li	a5,10
    8000036c:	0cf48563          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000370:	4791                	li	a5,4
    80000372:	0cf48263          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000376:	00011797          	auipc	a5,0x11
    8000037a:	ea27a783          	lw	a5,-350(a5) # 80011218 <cons+0x98>
    8000037e:	0807879b          	addiw	a5,a5,128
    80000382:	f6f61ce3          	bne	a2,a5,800002fa <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000386:	863e                	mv	a2,a5
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00011717          	auipc	a4,0x11
    8000038e:	df670713          	addi	a4,a4,-522 # 80011180 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    8000039a:	00011497          	auipc	s1,0x11
    8000039e:	de648493          	addi	s1,s1,-538 # 80011180 <cons>
    while(cons.e != cons.w &&
    800003a2:	4929                	li	s2,10
    800003a4:	f4f70be3          	beq	a4,a5,800002fa <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	07f7f713          	andi	a4,a5,127
    800003ae:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b0:	01874703          	lbu	a4,24(a4)
    800003b4:	f52703e3          	beq	a4,s2,800002fa <consoleintr+0x3c>
      cons.e--;
    800003b8:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003bc:	10000513          	li	a0,256
    800003c0:	00000097          	auipc	ra,0x0
    800003c4:	ebc080e7          	jalr	-324(ra) # 8000027c <consputc>
    while(cons.e != cons.w &&
    800003c8:	0a04a783          	lw	a5,160(s1)
    800003cc:	09c4a703          	lw	a4,156(s1)
    800003d0:	fcf71ce3          	bne	a4,a5,800003a8 <consoleintr+0xea>
    800003d4:	b71d                	j	800002fa <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d6:	00011717          	auipc	a4,0x11
    800003da:	daa70713          	addi	a4,a4,-598 # 80011180 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00011717          	auipc	a4,0x11
    800003f0:	e2f72a23          	sw	a5,-460(a4) # 80011220 <cons+0xa0>
      consputc(BACKSPACE);
    800003f4:	10000513          	li	a0,256
    800003f8:	00000097          	auipc	ra,0x0
    800003fc:	e84080e7          	jalr	-380(ra) # 8000027c <consputc>
    80000400:	bded                	j	800002fa <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000402:	ee048ce3          	beqz	s1,800002fa <consoleintr+0x3c>
    80000406:	bf21                	j	8000031e <consoleintr+0x60>
      consputc(c);
    80000408:	4529                	li	a0,10
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e72080e7          	jalr	-398(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000412:	00011797          	auipc	a5,0x11
    80000416:	d6e78793          	addi	a5,a5,-658 # 80011180 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000436:	00011797          	auipc	a5,0x11
    8000043a:	dec7a323          	sw	a2,-538(a5) # 8001121c <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00011517          	auipc	a0,0x11
    80000442:	dda50513          	addi	a0,a0,-550 # 80011218 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	db2080e7          	jalr	-590(ra) # 800021f8 <wakeup>
    8000044e:	b575                	j	800002fa <consoleintr+0x3c>

0000000080000450 <consoleinit>:

void
consoleinit(void)
{
    80000450:	1141                	addi	sp,sp,-16
    80000452:	e406                	sd	ra,8(sp)
    80000454:	e022                	sd	s0,0(sp)
    80000456:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000458:	00008597          	auipc	a1,0x8
    8000045c:	bb858593          	addi	a1,a1,-1096 # 80008010 <etext+0x10>
    80000460:	00011517          	auipc	a0,0x11
    80000464:	d2050513          	addi	a0,a0,-736 # 80011180 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6ec080e7          	jalr	1772(ra) # 80000b54 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	330080e7          	jalr	816(ra) # 800007a0 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00021797          	auipc	a5,0x21
    8000047c:	ea078793          	addi	a5,a5,-352 # 80021318 <devsw>
    80000480:	00000717          	auipc	a4,0x0
    80000484:	ce470713          	addi	a4,a4,-796 # 80000164 <consoleread>
    80000488:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c7870713          	addi	a4,a4,-904 # 80000102 <consolewrite>
    80000492:	ef98                	sd	a4,24(a5)
}
    80000494:	60a2                	ld	ra,8(sp)
    80000496:	6402                	ld	s0,0(sp)
    80000498:	0141                	addi	sp,sp,16
    8000049a:	8082                	ret

000000008000049c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000049c:	7179                	addi	sp,sp,-48
    8000049e:	f406                	sd	ra,40(sp)
    800004a0:	f022                	sd	s0,32(sp)
    800004a2:	ec26                	sd	s1,24(sp)
    800004a4:	e84a                	sd	s2,16(sp)
    800004a6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a8:	c219                	beqz	a2,800004ae <printint+0x12>
    800004aa:	08054663          	bltz	a0,80000536 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004ae:	2501                	sext.w	a0,a0
    800004b0:	4881                	li	a7,0
    800004b2:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b6:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b8:	2581                	sext.w	a1,a1
    800004ba:	00008617          	auipc	a2,0x8
    800004be:	b8660613          	addi	a2,a2,-1146 # 80008040 <digits>
    800004c2:	883a                	mv	a6,a4
    800004c4:	2705                	addiw	a4,a4,1
    800004c6:	02b577bb          	remuw	a5,a0,a1
    800004ca:	1782                	slli	a5,a5,0x20
    800004cc:	9381                	srli	a5,a5,0x20
    800004ce:	97b2                	add	a5,a5,a2
    800004d0:	0007c783          	lbu	a5,0(a5)
    800004d4:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d8:	0005079b          	sext.w	a5,a0
    800004dc:	02b5553b          	divuw	a0,a0,a1
    800004e0:	0685                	addi	a3,a3,1
    800004e2:	feb7f0e3          	bgeu	a5,a1,800004c2 <printint+0x26>

  if(sign)
    800004e6:	00088b63          	beqz	a7,800004fc <printint+0x60>
    buf[i++] = '-';
    800004ea:	fe040793          	addi	a5,s0,-32
    800004ee:	973e                	add	a4,a4,a5
    800004f0:	02d00793          	li	a5,45
    800004f4:	fef70823          	sb	a5,-16(a4)
    800004f8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fc:	02e05763          	blez	a4,8000052a <printint+0x8e>
    80000500:	fd040793          	addi	a5,s0,-48
    80000504:	00e784b3          	add	s1,a5,a4
    80000508:	fff78913          	addi	s2,a5,-1
    8000050c:	993a                	add	s2,s2,a4
    8000050e:	377d                	addiw	a4,a4,-1
    80000510:	1702                	slli	a4,a4,0x20
    80000512:	9301                	srli	a4,a4,0x20
    80000514:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000518:	fff4c503          	lbu	a0,-1(s1)
    8000051c:	00000097          	auipc	ra,0x0
    80000520:	d60080e7          	jalr	-672(ra) # 8000027c <consputc>
  while(--i >= 0)
    80000524:	14fd                	addi	s1,s1,-1
    80000526:	ff2499e3          	bne	s1,s2,80000518 <printint+0x7c>
}
    8000052a:	70a2                	ld	ra,40(sp)
    8000052c:	7402                	ld	s0,32(sp)
    8000052e:	64e2                	ld	s1,24(sp)
    80000530:	6942                	ld	s2,16(sp)
    80000532:	6145                	addi	sp,sp,48
    80000534:	8082                	ret
    x = -xx;
    80000536:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000053a:	4885                	li	a7,1
    x = -xx;
    8000053c:	bf9d                	j	800004b2 <printint+0x16>

000000008000053e <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000053e:	1101                	addi	sp,sp,-32
    80000540:	ec06                	sd	ra,24(sp)
    80000542:	e822                	sd	s0,16(sp)
    80000544:	e426                	sd	s1,8(sp)
    80000546:	1000                	addi	s0,sp,32
    80000548:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000054a:	00011797          	auipc	a5,0x11
    8000054e:	ce07ab23          	sw	zero,-778(a5) # 80011240 <pr+0x18>
  printf("panic: ");
    80000552:	00008517          	auipc	a0,0x8
    80000556:	ac650513          	addi	a0,a0,-1338 # 80008018 <etext+0x18>
    8000055a:	00000097          	auipc	ra,0x0
    8000055e:	02e080e7          	jalr	46(ra) # 80000588 <printf>
  printf(s);
    80000562:	8526                	mv	a0,s1
    80000564:	00000097          	auipc	ra,0x0
    80000568:	024080e7          	jalr	36(ra) # 80000588 <printf>
  printf("\n");
    8000056c:	00008517          	auipc	a0,0x8
    80000570:	b5c50513          	addi	a0,a0,-1188 # 800080c8 <digits+0x88>
    80000574:	00000097          	auipc	ra,0x0
    80000578:	014080e7          	jalr	20(ra) # 80000588 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057c:	4785                	li	a5,1
    8000057e:	00009717          	auipc	a4,0x9
    80000582:	a8f72123          	sw	a5,-1406(a4) # 80009000 <panicked>
  for(;;)
    80000586:	a001                	j	80000586 <panic+0x48>

0000000080000588 <printf>:
{
    80000588:	7131                	addi	sp,sp,-192
    8000058a:	fc86                	sd	ra,120(sp)
    8000058c:	f8a2                	sd	s0,112(sp)
    8000058e:	f4a6                	sd	s1,104(sp)
    80000590:	f0ca                	sd	s2,96(sp)
    80000592:	ecce                	sd	s3,88(sp)
    80000594:	e8d2                	sd	s4,80(sp)
    80000596:	e4d6                	sd	s5,72(sp)
    80000598:	e0da                	sd	s6,64(sp)
    8000059a:	fc5e                	sd	s7,56(sp)
    8000059c:	f862                	sd	s8,48(sp)
    8000059e:	f466                	sd	s9,40(sp)
    800005a0:	f06a                	sd	s10,32(sp)
    800005a2:	ec6e                	sd	s11,24(sp)
    800005a4:	0100                	addi	s0,sp,128
    800005a6:	8a2a                	mv	s4,a0
    800005a8:	e40c                	sd	a1,8(s0)
    800005aa:	e810                	sd	a2,16(s0)
    800005ac:	ec14                	sd	a3,24(s0)
    800005ae:	f018                	sd	a4,32(s0)
    800005b0:	f41c                	sd	a5,40(s0)
    800005b2:	03043823          	sd	a6,48(s0)
    800005b6:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005ba:	00011d97          	auipc	s11,0x11
    800005be:	c86dad83          	lw	s11,-890(s11) # 80011240 <pr+0x18>
  if(locking)
    800005c2:	020d9b63          	bnez	s11,800005f8 <printf+0x70>
  if (fmt == 0)
    800005c6:	040a0263          	beqz	s4,8000060a <printf+0x82>
  va_start(ap, fmt);
    800005ca:	00840793          	addi	a5,s0,8
    800005ce:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d2:	000a4503          	lbu	a0,0(s4)
    800005d6:	16050263          	beqz	a0,8000073a <printf+0x1b2>
    800005da:	4481                	li	s1,0
    if(c != '%'){
    800005dc:	02500a93          	li	s5,37
    switch(c){
    800005e0:	07000b13          	li	s6,112
  consputc('x');
    800005e4:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e6:	00008b97          	auipc	s7,0x8
    800005ea:	a5ab8b93          	addi	s7,s7,-1446 # 80008040 <digits>
    switch(c){
    800005ee:	07300c93          	li	s9,115
    800005f2:	06400c13          	li	s8,100
    800005f6:	a82d                	j	80000630 <printf+0xa8>
    acquire(&pr.lock);
    800005f8:	00011517          	auipc	a0,0x11
    800005fc:	c3050513          	addi	a0,a0,-976 # 80011228 <pr>
    80000600:	00000097          	auipc	ra,0x0
    80000604:	5e4080e7          	jalr	1508(ra) # 80000be4 <acquire>
    80000608:	bf7d                	j	800005c6 <printf+0x3e>
    panic("null fmt");
    8000060a:	00008517          	auipc	a0,0x8
    8000060e:	a1e50513          	addi	a0,a0,-1506 # 80008028 <etext+0x28>
    80000612:	00000097          	auipc	ra,0x0
    80000616:	f2c080e7          	jalr	-212(ra) # 8000053e <panic>
      consputc(c);
    8000061a:	00000097          	auipc	ra,0x0
    8000061e:	c62080e7          	jalr	-926(ra) # 8000027c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000622:	2485                	addiw	s1,s1,1
    80000624:	009a07b3          	add	a5,s4,s1
    80000628:	0007c503          	lbu	a0,0(a5)
    8000062c:	10050763          	beqz	a0,8000073a <printf+0x1b2>
    if(c != '%'){
    80000630:	ff5515e3          	bne	a0,s5,8000061a <printf+0x92>
    c = fmt[++i] & 0xff;
    80000634:	2485                	addiw	s1,s1,1
    80000636:	009a07b3          	add	a5,s4,s1
    8000063a:	0007c783          	lbu	a5,0(a5)
    8000063e:	0007891b          	sext.w	s2,a5
    if(c == 0)
    80000642:	cfe5                	beqz	a5,8000073a <printf+0x1b2>
    switch(c){
    80000644:	05678a63          	beq	a5,s6,80000698 <printf+0x110>
    80000648:	02fb7663          	bgeu	s6,a5,80000674 <printf+0xec>
    8000064c:	09978963          	beq	a5,s9,800006de <printf+0x156>
    80000650:	07800713          	li	a4,120
    80000654:	0ce79863          	bne	a5,a4,80000724 <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    80000658:	f8843783          	ld	a5,-120(s0)
    8000065c:	00878713          	addi	a4,a5,8
    80000660:	f8e43423          	sd	a4,-120(s0)
    80000664:	4605                	li	a2,1
    80000666:	85ea                	mv	a1,s10
    80000668:	4388                	lw	a0,0(a5)
    8000066a:	00000097          	auipc	ra,0x0
    8000066e:	e32080e7          	jalr	-462(ra) # 8000049c <printint>
      break;
    80000672:	bf45                	j	80000622 <printf+0x9a>
    switch(c){
    80000674:	0b578263          	beq	a5,s5,80000718 <printf+0x190>
    80000678:	0b879663          	bne	a5,s8,80000724 <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    8000067c:	f8843783          	ld	a5,-120(s0)
    80000680:	00878713          	addi	a4,a5,8
    80000684:	f8e43423          	sd	a4,-120(s0)
    80000688:	4605                	li	a2,1
    8000068a:	45a9                	li	a1,10
    8000068c:	4388                	lw	a0,0(a5)
    8000068e:	00000097          	auipc	ra,0x0
    80000692:	e0e080e7          	jalr	-498(ra) # 8000049c <printint>
      break;
    80000696:	b771                	j	80000622 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000698:	f8843783          	ld	a5,-120(s0)
    8000069c:	00878713          	addi	a4,a5,8
    800006a0:	f8e43423          	sd	a4,-120(s0)
    800006a4:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006a8:	03000513          	li	a0,48
    800006ac:	00000097          	auipc	ra,0x0
    800006b0:	bd0080e7          	jalr	-1072(ra) # 8000027c <consputc>
  consputc('x');
    800006b4:	07800513          	li	a0,120
    800006b8:	00000097          	auipc	ra,0x0
    800006bc:	bc4080e7          	jalr	-1084(ra) # 8000027c <consputc>
    800006c0:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c2:	03c9d793          	srli	a5,s3,0x3c
    800006c6:	97de                	add	a5,a5,s7
    800006c8:	0007c503          	lbu	a0,0(a5)
    800006cc:	00000097          	auipc	ra,0x0
    800006d0:	bb0080e7          	jalr	-1104(ra) # 8000027c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d4:	0992                	slli	s3,s3,0x4
    800006d6:	397d                	addiw	s2,s2,-1
    800006d8:	fe0915e3          	bnez	s2,800006c2 <printf+0x13a>
    800006dc:	b799                	j	80000622 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006de:	f8843783          	ld	a5,-120(s0)
    800006e2:	00878713          	addi	a4,a5,8
    800006e6:	f8e43423          	sd	a4,-120(s0)
    800006ea:	0007b903          	ld	s2,0(a5)
    800006ee:	00090e63          	beqz	s2,8000070a <printf+0x182>
      for(; *s; s++)
    800006f2:	00094503          	lbu	a0,0(s2)
    800006f6:	d515                	beqz	a0,80000622 <printf+0x9a>
        consputc(*s);
    800006f8:	00000097          	auipc	ra,0x0
    800006fc:	b84080e7          	jalr	-1148(ra) # 8000027c <consputc>
      for(; *s; s++)
    80000700:	0905                	addi	s2,s2,1
    80000702:	00094503          	lbu	a0,0(s2)
    80000706:	f96d                	bnez	a0,800006f8 <printf+0x170>
    80000708:	bf29                	j	80000622 <printf+0x9a>
        s = "(null)";
    8000070a:	00008917          	auipc	s2,0x8
    8000070e:	91690913          	addi	s2,s2,-1770 # 80008020 <etext+0x20>
      for(; *s; s++)
    80000712:	02800513          	li	a0,40
    80000716:	b7cd                	j	800006f8 <printf+0x170>
      consputc('%');
    80000718:	8556                	mv	a0,s5
    8000071a:	00000097          	auipc	ra,0x0
    8000071e:	b62080e7          	jalr	-1182(ra) # 8000027c <consputc>
      break;
    80000722:	b701                	j	80000622 <printf+0x9a>
      consputc('%');
    80000724:	8556                	mv	a0,s5
    80000726:	00000097          	auipc	ra,0x0
    8000072a:	b56080e7          	jalr	-1194(ra) # 8000027c <consputc>
      consputc(c);
    8000072e:	854a                	mv	a0,s2
    80000730:	00000097          	auipc	ra,0x0
    80000734:	b4c080e7          	jalr	-1204(ra) # 8000027c <consputc>
      break;
    80000738:	b5ed                	j	80000622 <printf+0x9a>
  if(locking)
    8000073a:	020d9163          	bnez	s11,8000075c <printf+0x1d4>
}
    8000073e:	70e6                	ld	ra,120(sp)
    80000740:	7446                	ld	s0,112(sp)
    80000742:	74a6                	ld	s1,104(sp)
    80000744:	7906                	ld	s2,96(sp)
    80000746:	69e6                	ld	s3,88(sp)
    80000748:	6a46                	ld	s4,80(sp)
    8000074a:	6aa6                	ld	s5,72(sp)
    8000074c:	6b06                	ld	s6,64(sp)
    8000074e:	7be2                	ld	s7,56(sp)
    80000750:	7c42                	ld	s8,48(sp)
    80000752:	7ca2                	ld	s9,40(sp)
    80000754:	7d02                	ld	s10,32(sp)
    80000756:	6de2                	ld	s11,24(sp)
    80000758:	6129                	addi	sp,sp,192
    8000075a:	8082                	ret
    release(&pr.lock);
    8000075c:	00011517          	auipc	a0,0x11
    80000760:	acc50513          	addi	a0,a0,-1332 # 80011228 <pr>
    80000764:	00000097          	auipc	ra,0x0
    80000768:	534080e7          	jalr	1332(ra) # 80000c98 <release>
}
    8000076c:	bfc9                	j	8000073e <printf+0x1b6>

000000008000076e <printfinit>:
    ;
}

void
printfinit(void)
{
    8000076e:	1101                	addi	sp,sp,-32
    80000770:	ec06                	sd	ra,24(sp)
    80000772:	e822                	sd	s0,16(sp)
    80000774:	e426                	sd	s1,8(sp)
    80000776:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000778:	00011497          	auipc	s1,0x11
    8000077c:	ab048493          	addi	s1,s1,-1360 # 80011228 <pr>
    80000780:	00008597          	auipc	a1,0x8
    80000784:	8b858593          	addi	a1,a1,-1864 # 80008038 <etext+0x38>
    80000788:	8526                	mv	a0,s1
    8000078a:	00000097          	auipc	ra,0x0
    8000078e:	3ca080e7          	jalr	970(ra) # 80000b54 <initlock>
  pr.locking = 1;
    80000792:	4785                	li	a5,1
    80000794:	cc9c                	sw	a5,24(s1)
}
    80000796:	60e2                	ld	ra,24(sp)
    80000798:	6442                	ld	s0,16(sp)
    8000079a:	64a2                	ld	s1,8(sp)
    8000079c:	6105                	addi	sp,sp,32
    8000079e:	8082                	ret

00000000800007a0 <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007a0:	1141                	addi	sp,sp,-16
    800007a2:	e406                	sd	ra,8(sp)
    800007a4:	e022                	sd	s0,0(sp)
    800007a6:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a8:	100007b7          	lui	a5,0x10000
    800007ac:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007b0:	f8000713          	li	a4,-128
    800007b4:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b8:	470d                	li	a4,3
    800007ba:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007be:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007c2:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c6:	469d                	li	a3,7
    800007c8:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007cc:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007d0:	00008597          	auipc	a1,0x8
    800007d4:	88858593          	addi	a1,a1,-1912 # 80008058 <digits+0x18>
    800007d8:	00011517          	auipc	a0,0x11
    800007dc:	a7050513          	addi	a0,a0,-1424 # 80011248 <uart_tx_lock>
    800007e0:	00000097          	auipc	ra,0x0
    800007e4:	374080e7          	jalr	884(ra) # 80000b54 <initlock>
}
    800007e8:	60a2                	ld	ra,8(sp)
    800007ea:	6402                	ld	s0,0(sp)
    800007ec:	0141                	addi	sp,sp,16
    800007ee:	8082                	ret

00000000800007f0 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007f0:	1101                	addi	sp,sp,-32
    800007f2:	ec06                	sd	ra,24(sp)
    800007f4:	e822                	sd	s0,16(sp)
    800007f6:	e426                	sd	s1,8(sp)
    800007f8:	1000                	addi	s0,sp,32
    800007fa:	84aa                	mv	s1,a0
  push_off();
    800007fc:	00000097          	auipc	ra,0x0
    80000800:	39c080e7          	jalr	924(ra) # 80000b98 <push_off>

  if(panicked){
    80000804:	00008797          	auipc	a5,0x8
    80000808:	7fc7a783          	lw	a5,2044(a5) # 80009000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080c:	10000737          	lui	a4,0x10000
  if(panicked){
    80000810:	c391                	beqz	a5,80000814 <uartputc_sync+0x24>
    for(;;)
    80000812:	a001                	j	80000812 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000814:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000818:	0ff7f793          	andi	a5,a5,255
    8000081c:	0207f793          	andi	a5,a5,32
    80000820:	dbf5                	beqz	a5,80000814 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000822:	0ff4f793          	andi	a5,s1,255
    80000826:	10000737          	lui	a4,0x10000
    8000082a:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    8000082e:	00000097          	auipc	ra,0x0
    80000832:	40a080e7          	jalr	1034(ra) # 80000c38 <pop_off>
}
    80000836:	60e2                	ld	ra,24(sp)
    80000838:	6442                	ld	s0,16(sp)
    8000083a:	64a2                	ld	s1,8(sp)
    8000083c:	6105                	addi	sp,sp,32
    8000083e:	8082                	ret

0000000080000840 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000840:	00008717          	auipc	a4,0x8
    80000844:	7c873703          	ld	a4,1992(a4) # 80009008 <uart_tx_r>
    80000848:	00008797          	auipc	a5,0x8
    8000084c:	7c87b783          	ld	a5,1992(a5) # 80009010 <uart_tx_w>
    80000850:	06e78c63          	beq	a5,a4,800008c8 <uartstart+0x88>
{
    80000854:	7139                	addi	sp,sp,-64
    80000856:	fc06                	sd	ra,56(sp)
    80000858:	f822                	sd	s0,48(sp)
    8000085a:	f426                	sd	s1,40(sp)
    8000085c:	f04a                	sd	s2,32(sp)
    8000085e:	ec4e                	sd	s3,24(sp)
    80000860:	e852                	sd	s4,16(sp)
    80000862:	e456                	sd	s5,8(sp)
    80000864:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000866:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000086a:	00011a17          	auipc	s4,0x11
    8000086e:	9dea0a13          	addi	s4,s4,-1570 # 80011248 <uart_tx_lock>
    uart_tx_r += 1;
    80000872:	00008497          	auipc	s1,0x8
    80000876:	79648493          	addi	s1,s1,1942 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000087a:	00008997          	auipc	s3,0x8
    8000087e:	79698993          	addi	s3,s3,1942 # 80009010 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000882:	00594783          	lbu	a5,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000886:	0ff7f793          	andi	a5,a5,255
    8000088a:	0207f793          	andi	a5,a5,32
    8000088e:	c785                	beqz	a5,800008b6 <uartstart+0x76>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000890:	01f77793          	andi	a5,a4,31
    80000894:	97d2                	add	a5,a5,s4
    80000896:	0187ca83          	lbu	s5,24(a5)
    uart_tx_r += 1;
    8000089a:	0705                	addi	a4,a4,1
    8000089c:	e098                	sd	a4,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000089e:	8526                	mv	a0,s1
    800008a0:	00002097          	auipc	ra,0x2
    800008a4:	958080e7          	jalr	-1704(ra) # 800021f8 <wakeup>
    
    WriteReg(THR, c);
    800008a8:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008ac:	6098                	ld	a4,0(s1)
    800008ae:	0009b783          	ld	a5,0(s3)
    800008b2:	fce798e3          	bne	a5,a4,80000882 <uartstart+0x42>
  }
}
    800008b6:	70e2                	ld	ra,56(sp)
    800008b8:	7442                	ld	s0,48(sp)
    800008ba:	74a2                	ld	s1,40(sp)
    800008bc:	7902                	ld	s2,32(sp)
    800008be:	69e2                	ld	s3,24(sp)
    800008c0:	6a42                	ld	s4,16(sp)
    800008c2:	6aa2                	ld	s5,8(sp)
    800008c4:	6121                	addi	sp,sp,64
    800008c6:	8082                	ret
    800008c8:	8082                	ret

00000000800008ca <uartputc>:
{
    800008ca:	7179                	addi	sp,sp,-48
    800008cc:	f406                	sd	ra,40(sp)
    800008ce:	f022                	sd	s0,32(sp)
    800008d0:	ec26                	sd	s1,24(sp)
    800008d2:	e84a                	sd	s2,16(sp)
    800008d4:	e44e                	sd	s3,8(sp)
    800008d6:	e052                	sd	s4,0(sp)
    800008d8:	1800                	addi	s0,sp,48
    800008da:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    800008dc:	00011517          	auipc	a0,0x11
    800008e0:	96c50513          	addi	a0,a0,-1684 # 80011248 <uart_tx_lock>
    800008e4:	00000097          	auipc	ra,0x0
    800008e8:	300080e7          	jalr	768(ra) # 80000be4 <acquire>
  if(panicked){
    800008ec:	00008797          	auipc	a5,0x8
    800008f0:	7147a783          	lw	a5,1812(a5) # 80009000 <panicked>
    800008f4:	c391                	beqz	a5,800008f8 <uartputc+0x2e>
    for(;;)
    800008f6:	a001                	j	800008f6 <uartputc+0x2c>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008f8:	00008797          	auipc	a5,0x8
    800008fc:	7187b783          	ld	a5,1816(a5) # 80009010 <uart_tx_w>
    80000900:	00008717          	auipc	a4,0x8
    80000904:	70873703          	ld	a4,1800(a4) # 80009008 <uart_tx_r>
    80000908:	02070713          	addi	a4,a4,32
    8000090c:	02f71b63          	bne	a4,a5,80000942 <uartputc+0x78>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000910:	00011a17          	auipc	s4,0x11
    80000914:	938a0a13          	addi	s4,s4,-1736 # 80011248 <uart_tx_lock>
    80000918:	00008497          	auipc	s1,0x8
    8000091c:	6f048493          	addi	s1,s1,1776 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000920:	00008917          	auipc	s2,0x8
    80000924:	6f090913          	addi	s2,s2,1776 # 80009010 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000928:	85d2                	mv	a1,s4
    8000092a:	8526                	mv	a0,s1
    8000092c:	00001097          	auipc	ra,0x1
    80000930:	740080e7          	jalr	1856(ra) # 8000206c <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000934:	00093783          	ld	a5,0(s2)
    80000938:	6098                	ld	a4,0(s1)
    8000093a:	02070713          	addi	a4,a4,32
    8000093e:	fef705e3          	beq	a4,a5,80000928 <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000942:	00011497          	auipc	s1,0x11
    80000946:	90648493          	addi	s1,s1,-1786 # 80011248 <uart_tx_lock>
    8000094a:	01f7f713          	andi	a4,a5,31
    8000094e:	9726                	add	a4,a4,s1
    80000950:	01370c23          	sb	s3,24(a4)
      uart_tx_w += 1;
    80000954:	0785                	addi	a5,a5,1
    80000956:	00008717          	auipc	a4,0x8
    8000095a:	6af73d23          	sd	a5,1722(a4) # 80009010 <uart_tx_w>
      uartstart();
    8000095e:	00000097          	auipc	ra,0x0
    80000962:	ee2080e7          	jalr	-286(ra) # 80000840 <uartstart>
      release(&uart_tx_lock);
    80000966:	8526                	mv	a0,s1
    80000968:	00000097          	auipc	ra,0x0
    8000096c:	330080e7          	jalr	816(ra) # 80000c98 <release>
}
    80000970:	70a2                	ld	ra,40(sp)
    80000972:	7402                	ld	s0,32(sp)
    80000974:	64e2                	ld	s1,24(sp)
    80000976:	6942                	ld	s2,16(sp)
    80000978:	69a2                	ld	s3,8(sp)
    8000097a:	6a02                	ld	s4,0(sp)
    8000097c:	6145                	addi	sp,sp,48
    8000097e:	8082                	ret

0000000080000980 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000980:	1141                	addi	sp,sp,-16
    80000982:	e422                	sd	s0,8(sp)
    80000984:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000986:	100007b7          	lui	a5,0x10000
    8000098a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000098e:	8b85                	andi	a5,a5,1
    80000990:	cb91                	beqz	a5,800009a4 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000992:	100007b7          	lui	a5,0x10000
    80000996:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    8000099a:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    8000099e:	6422                	ld	s0,8(sp)
    800009a0:	0141                	addi	sp,sp,16
    800009a2:	8082                	ret
    return -1;
    800009a4:	557d                	li	a0,-1
    800009a6:	bfe5                	j	8000099e <uartgetc+0x1e>

00000000800009a8 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    800009a8:	1101                	addi	sp,sp,-32
    800009aa:	ec06                	sd	ra,24(sp)
    800009ac:	e822                	sd	s0,16(sp)
    800009ae:	e426                	sd	s1,8(sp)
    800009b0:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009b2:	54fd                	li	s1,-1
    int c = uartgetc();
    800009b4:	00000097          	auipc	ra,0x0
    800009b8:	fcc080e7          	jalr	-52(ra) # 80000980 <uartgetc>
    if(c == -1)
    800009bc:	00950763          	beq	a0,s1,800009ca <uartintr+0x22>
      break;
    consoleintr(c);
    800009c0:	00000097          	auipc	ra,0x0
    800009c4:	8fe080e7          	jalr	-1794(ra) # 800002be <consoleintr>
  while(1){
    800009c8:	b7f5                	j	800009b4 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009ca:	00011497          	auipc	s1,0x11
    800009ce:	87e48493          	addi	s1,s1,-1922 # 80011248 <uart_tx_lock>
    800009d2:	8526                	mv	a0,s1
    800009d4:	00000097          	auipc	ra,0x0
    800009d8:	210080e7          	jalr	528(ra) # 80000be4 <acquire>
  uartstart();
    800009dc:	00000097          	auipc	ra,0x0
    800009e0:	e64080e7          	jalr	-412(ra) # 80000840 <uartstart>
  release(&uart_tx_lock);
    800009e4:	8526                	mv	a0,s1
    800009e6:	00000097          	auipc	ra,0x0
    800009ea:	2b2080e7          	jalr	690(ra) # 80000c98 <release>
}
    800009ee:	60e2                	ld	ra,24(sp)
    800009f0:	6442                	ld	s0,16(sp)
    800009f2:	64a2                	ld	s1,8(sp)
    800009f4:	6105                	addi	sp,sp,32
    800009f6:	8082                	ret

00000000800009f8 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009f8:	1101                	addi	sp,sp,-32
    800009fa:	ec06                	sd	ra,24(sp)
    800009fc:	e822                	sd	s0,16(sp)
    800009fe:	e426                	sd	s1,8(sp)
    80000a00:	e04a                	sd	s2,0(sp)
    80000a02:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a04:	03451793          	slli	a5,a0,0x34
    80000a08:	ebb9                	bnez	a5,80000a5e <kfree+0x66>
    80000a0a:	84aa                	mv	s1,a0
    80000a0c:	00025797          	auipc	a5,0x25
    80000a10:	5f478793          	addi	a5,a5,1524 # 80026000 <end>
    80000a14:	04f56563          	bltu	a0,a5,80000a5e <kfree+0x66>
    80000a18:	47c5                	li	a5,17
    80000a1a:	07ee                	slli	a5,a5,0x1b
    80000a1c:	04f57163          	bgeu	a0,a5,80000a5e <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a20:	6605                	lui	a2,0x1
    80000a22:	4585                	li	a1,1
    80000a24:	00000097          	auipc	ra,0x0
    80000a28:	2bc080e7          	jalr	700(ra) # 80000ce0 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a2c:	00011917          	auipc	s2,0x11
    80000a30:	85490913          	addi	s2,s2,-1964 # 80011280 <kmem>
    80000a34:	854a                	mv	a0,s2
    80000a36:	00000097          	auipc	ra,0x0
    80000a3a:	1ae080e7          	jalr	430(ra) # 80000be4 <acquire>
  r->next = kmem.freelist;
    80000a3e:	01893783          	ld	a5,24(s2)
    80000a42:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a44:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a48:	854a                	mv	a0,s2
    80000a4a:	00000097          	auipc	ra,0x0
    80000a4e:	24e080e7          	jalr	590(ra) # 80000c98 <release>
}
    80000a52:	60e2                	ld	ra,24(sp)
    80000a54:	6442                	ld	s0,16(sp)
    80000a56:	64a2                	ld	s1,8(sp)
    80000a58:	6902                	ld	s2,0(sp)
    80000a5a:	6105                	addi	sp,sp,32
    80000a5c:	8082                	ret
    panic("kfree");
    80000a5e:	00007517          	auipc	a0,0x7
    80000a62:	60250513          	addi	a0,a0,1538 # 80008060 <digits+0x20>
    80000a66:	00000097          	auipc	ra,0x0
    80000a6a:	ad8080e7          	jalr	-1320(ra) # 8000053e <panic>

0000000080000a6e <freerange>:
{
    80000a6e:	7179                	addi	sp,sp,-48
    80000a70:	f406                	sd	ra,40(sp)
    80000a72:	f022                	sd	s0,32(sp)
    80000a74:	ec26                	sd	s1,24(sp)
    80000a76:	e84a                	sd	s2,16(sp)
    80000a78:	e44e                	sd	s3,8(sp)
    80000a7a:	e052                	sd	s4,0(sp)
    80000a7c:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a7e:	6785                	lui	a5,0x1
    80000a80:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a84:	94aa                	add	s1,s1,a0
    80000a86:	757d                	lui	a0,0xfffff
    80000a88:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a8a:	94be                	add	s1,s1,a5
    80000a8c:	0095ee63          	bltu	a1,s1,80000aa8 <freerange+0x3a>
    80000a90:	892e                	mv	s2,a1
    kfree(p);
    80000a92:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a94:	6985                	lui	s3,0x1
    kfree(p);
    80000a96:	01448533          	add	a0,s1,s4
    80000a9a:	00000097          	auipc	ra,0x0
    80000a9e:	f5e080e7          	jalr	-162(ra) # 800009f8 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000aa2:	94ce                	add	s1,s1,s3
    80000aa4:	fe9979e3          	bgeu	s2,s1,80000a96 <freerange+0x28>
}
    80000aa8:	70a2                	ld	ra,40(sp)
    80000aaa:	7402                	ld	s0,32(sp)
    80000aac:	64e2                	ld	s1,24(sp)
    80000aae:	6942                	ld	s2,16(sp)
    80000ab0:	69a2                	ld	s3,8(sp)
    80000ab2:	6a02                	ld	s4,0(sp)
    80000ab4:	6145                	addi	sp,sp,48
    80000ab6:	8082                	ret

0000000080000ab8 <kinit>:
{
    80000ab8:	1141                	addi	sp,sp,-16
    80000aba:	e406                	sd	ra,8(sp)
    80000abc:	e022                	sd	s0,0(sp)
    80000abe:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ac0:	00007597          	auipc	a1,0x7
    80000ac4:	5a858593          	addi	a1,a1,1448 # 80008068 <digits+0x28>
    80000ac8:	00010517          	auipc	a0,0x10
    80000acc:	7b850513          	addi	a0,a0,1976 # 80011280 <kmem>
    80000ad0:	00000097          	auipc	ra,0x0
    80000ad4:	084080e7          	jalr	132(ra) # 80000b54 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ad8:	45c5                	li	a1,17
    80000ada:	05ee                	slli	a1,a1,0x1b
    80000adc:	00025517          	auipc	a0,0x25
    80000ae0:	52450513          	addi	a0,a0,1316 # 80026000 <end>
    80000ae4:	00000097          	auipc	ra,0x0
    80000ae8:	f8a080e7          	jalr	-118(ra) # 80000a6e <freerange>
}
    80000aec:	60a2                	ld	ra,8(sp)
    80000aee:	6402                	ld	s0,0(sp)
    80000af0:	0141                	addi	sp,sp,16
    80000af2:	8082                	ret

0000000080000af4 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000af4:	1101                	addi	sp,sp,-32
    80000af6:	ec06                	sd	ra,24(sp)
    80000af8:	e822                	sd	s0,16(sp)
    80000afa:	e426                	sd	s1,8(sp)
    80000afc:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000afe:	00010497          	auipc	s1,0x10
    80000b02:	78248493          	addi	s1,s1,1922 # 80011280 <kmem>
    80000b06:	8526                	mv	a0,s1
    80000b08:	00000097          	auipc	ra,0x0
    80000b0c:	0dc080e7          	jalr	220(ra) # 80000be4 <acquire>
  r = kmem.freelist;
    80000b10:	6c84                	ld	s1,24(s1)
  if(r)
    80000b12:	c885                	beqz	s1,80000b42 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b14:	609c                	ld	a5,0(s1)
    80000b16:	00010517          	auipc	a0,0x10
    80000b1a:	76a50513          	addi	a0,a0,1898 # 80011280 <kmem>
    80000b1e:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b20:	00000097          	auipc	ra,0x0
    80000b24:	178080e7          	jalr	376(ra) # 80000c98 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b28:	6605                	lui	a2,0x1
    80000b2a:	4595                	li	a1,5
    80000b2c:	8526                	mv	a0,s1
    80000b2e:	00000097          	auipc	ra,0x0
    80000b32:	1b2080e7          	jalr	434(ra) # 80000ce0 <memset>
  return (void*)r;
}
    80000b36:	8526                	mv	a0,s1
    80000b38:	60e2                	ld	ra,24(sp)
    80000b3a:	6442                	ld	s0,16(sp)
    80000b3c:	64a2                	ld	s1,8(sp)
    80000b3e:	6105                	addi	sp,sp,32
    80000b40:	8082                	ret
  release(&kmem.lock);
    80000b42:	00010517          	auipc	a0,0x10
    80000b46:	73e50513          	addi	a0,a0,1854 # 80011280 <kmem>
    80000b4a:	00000097          	auipc	ra,0x0
    80000b4e:	14e080e7          	jalr	334(ra) # 80000c98 <release>
  if(r)
    80000b52:	b7d5                	j	80000b36 <kalloc+0x42>

0000000080000b54 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b54:	1141                	addi	sp,sp,-16
    80000b56:	e422                	sd	s0,8(sp)
    80000b58:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b5a:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b5c:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b60:	00053823          	sd	zero,16(a0)
}
    80000b64:	6422                	ld	s0,8(sp)
    80000b66:	0141                	addi	sp,sp,16
    80000b68:	8082                	ret

0000000080000b6a <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b6a:	411c                	lw	a5,0(a0)
    80000b6c:	e399                	bnez	a5,80000b72 <holding+0x8>
    80000b6e:	4501                	li	a0,0
  return r;
}
    80000b70:	8082                	ret
{
    80000b72:	1101                	addi	sp,sp,-32
    80000b74:	ec06                	sd	ra,24(sp)
    80000b76:	e822                	sd	s0,16(sp)
    80000b78:	e426                	sd	s1,8(sp)
    80000b7a:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b7c:	6904                	ld	s1,16(a0)
    80000b7e:	00001097          	auipc	ra,0x1
    80000b82:	e16080e7          	jalr	-490(ra) # 80001994 <mycpu>
    80000b86:	40a48533          	sub	a0,s1,a0
    80000b8a:	00153513          	seqz	a0,a0
}
    80000b8e:	60e2                	ld	ra,24(sp)
    80000b90:	6442                	ld	s0,16(sp)
    80000b92:	64a2                	ld	s1,8(sp)
    80000b94:	6105                	addi	sp,sp,32
    80000b96:	8082                	ret

0000000080000b98 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b98:	1101                	addi	sp,sp,-32
    80000b9a:	ec06                	sd	ra,24(sp)
    80000b9c:	e822                	sd	s0,16(sp)
    80000b9e:	e426                	sd	s1,8(sp)
    80000ba0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000ba2:	100024f3          	csrr	s1,sstatus
    80000ba6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000baa:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bac:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bb0:	00001097          	auipc	ra,0x1
    80000bb4:	de4080e7          	jalr	-540(ra) # 80001994 <mycpu>
    80000bb8:	5d3c                	lw	a5,120(a0)
    80000bba:	cf89                	beqz	a5,80000bd4 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bbc:	00001097          	auipc	ra,0x1
    80000bc0:	dd8080e7          	jalr	-552(ra) # 80001994 <mycpu>
    80000bc4:	5d3c                	lw	a5,120(a0)
    80000bc6:	2785                	addiw	a5,a5,1
    80000bc8:	dd3c                	sw	a5,120(a0)
}
    80000bca:	60e2                	ld	ra,24(sp)
    80000bcc:	6442                	ld	s0,16(sp)
    80000bce:	64a2                	ld	s1,8(sp)
    80000bd0:	6105                	addi	sp,sp,32
    80000bd2:	8082                	ret
    mycpu()->intena = old;
    80000bd4:	00001097          	auipc	ra,0x1
    80000bd8:	dc0080e7          	jalr	-576(ra) # 80001994 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bdc:	8085                	srli	s1,s1,0x1
    80000bde:	8885                	andi	s1,s1,1
    80000be0:	dd64                	sw	s1,124(a0)
    80000be2:	bfe9                	j	80000bbc <push_off+0x24>

0000000080000be4 <acquire>:
{
    80000be4:	1101                	addi	sp,sp,-32
    80000be6:	ec06                	sd	ra,24(sp)
    80000be8:	e822                	sd	s0,16(sp)
    80000bea:	e426                	sd	s1,8(sp)
    80000bec:	1000                	addi	s0,sp,32
    80000bee:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bf0:	00000097          	auipc	ra,0x0
    80000bf4:	fa8080e7          	jalr	-88(ra) # 80000b98 <push_off>
  if(holding(lk))
    80000bf8:	8526                	mv	a0,s1
    80000bfa:	00000097          	auipc	ra,0x0
    80000bfe:	f70080e7          	jalr	-144(ra) # 80000b6a <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c02:	4705                	li	a4,1
  if(holding(lk))
    80000c04:	e115                	bnez	a0,80000c28 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c06:	87ba                	mv	a5,a4
    80000c08:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c0c:	2781                	sext.w	a5,a5
    80000c0e:	ffe5                	bnez	a5,80000c06 <acquire+0x22>
  __sync_synchronize();
    80000c10:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c14:	00001097          	auipc	ra,0x1
    80000c18:	d80080e7          	jalr	-640(ra) # 80001994 <mycpu>
    80000c1c:	e888                	sd	a0,16(s1)
}
    80000c1e:	60e2                	ld	ra,24(sp)
    80000c20:	6442                	ld	s0,16(sp)
    80000c22:	64a2                	ld	s1,8(sp)
    80000c24:	6105                	addi	sp,sp,32
    80000c26:	8082                	ret
    panic("acquire");
    80000c28:	00007517          	auipc	a0,0x7
    80000c2c:	44850513          	addi	a0,a0,1096 # 80008070 <digits+0x30>
    80000c30:	00000097          	auipc	ra,0x0
    80000c34:	90e080e7          	jalr	-1778(ra) # 8000053e <panic>

0000000080000c38 <pop_off>:

void
pop_off(void)
{
    80000c38:	1141                	addi	sp,sp,-16
    80000c3a:	e406                	sd	ra,8(sp)
    80000c3c:	e022                	sd	s0,0(sp)
    80000c3e:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c40:	00001097          	auipc	ra,0x1
    80000c44:	d54080e7          	jalr	-684(ra) # 80001994 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c48:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c4c:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c4e:	e78d                	bnez	a5,80000c78 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c50:	5d3c                	lw	a5,120(a0)
    80000c52:	02f05b63          	blez	a5,80000c88 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c56:	37fd                	addiw	a5,a5,-1
    80000c58:	0007871b          	sext.w	a4,a5
    80000c5c:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c5e:	eb09                	bnez	a4,80000c70 <pop_off+0x38>
    80000c60:	5d7c                	lw	a5,124(a0)
    80000c62:	c799                	beqz	a5,80000c70 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c64:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c68:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c6c:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c70:	60a2                	ld	ra,8(sp)
    80000c72:	6402                	ld	s0,0(sp)
    80000c74:	0141                	addi	sp,sp,16
    80000c76:	8082                	ret
    panic("pop_off - interruptible");
    80000c78:	00007517          	auipc	a0,0x7
    80000c7c:	40050513          	addi	a0,a0,1024 # 80008078 <digits+0x38>
    80000c80:	00000097          	auipc	ra,0x0
    80000c84:	8be080e7          	jalr	-1858(ra) # 8000053e <panic>
    panic("pop_off");
    80000c88:	00007517          	auipc	a0,0x7
    80000c8c:	40850513          	addi	a0,a0,1032 # 80008090 <digits+0x50>
    80000c90:	00000097          	auipc	ra,0x0
    80000c94:	8ae080e7          	jalr	-1874(ra) # 8000053e <panic>

0000000080000c98 <release>:
{
    80000c98:	1101                	addi	sp,sp,-32
    80000c9a:	ec06                	sd	ra,24(sp)
    80000c9c:	e822                	sd	s0,16(sp)
    80000c9e:	e426                	sd	s1,8(sp)
    80000ca0:	1000                	addi	s0,sp,32
    80000ca2:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000ca4:	00000097          	auipc	ra,0x0
    80000ca8:	ec6080e7          	jalr	-314(ra) # 80000b6a <holding>
    80000cac:	c115                	beqz	a0,80000cd0 <release+0x38>
  lk->cpu = 0;
    80000cae:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000cb2:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000cb6:	0f50000f          	fence	iorw,ow
    80000cba:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cbe:	00000097          	auipc	ra,0x0
    80000cc2:	f7a080e7          	jalr	-134(ra) # 80000c38 <pop_off>
}
    80000cc6:	60e2                	ld	ra,24(sp)
    80000cc8:	6442                	ld	s0,16(sp)
    80000cca:	64a2                	ld	s1,8(sp)
    80000ccc:	6105                	addi	sp,sp,32
    80000cce:	8082                	ret
    panic("release");
    80000cd0:	00007517          	auipc	a0,0x7
    80000cd4:	3c850513          	addi	a0,a0,968 # 80008098 <digits+0x58>
    80000cd8:	00000097          	auipc	ra,0x0
    80000cdc:	866080e7          	jalr	-1946(ra) # 8000053e <panic>

0000000080000ce0 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000ce0:	1141                	addi	sp,sp,-16
    80000ce2:	e422                	sd	s0,8(sp)
    80000ce4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000ce6:	ce09                	beqz	a2,80000d00 <memset+0x20>
    80000ce8:	87aa                	mv	a5,a0
    80000cea:	fff6071b          	addiw	a4,a2,-1
    80000cee:	1702                	slli	a4,a4,0x20
    80000cf0:	9301                	srli	a4,a4,0x20
    80000cf2:	0705                	addi	a4,a4,1
    80000cf4:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000cf6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cfa:	0785                	addi	a5,a5,1
    80000cfc:	fee79de3          	bne	a5,a4,80000cf6 <memset+0x16>
  }
  return dst;
}
    80000d00:	6422                	ld	s0,8(sp)
    80000d02:	0141                	addi	sp,sp,16
    80000d04:	8082                	ret

0000000080000d06 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d06:	1141                	addi	sp,sp,-16
    80000d08:	e422                	sd	s0,8(sp)
    80000d0a:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d0c:	ca05                	beqz	a2,80000d3c <memcmp+0x36>
    80000d0e:	fff6069b          	addiw	a3,a2,-1
    80000d12:	1682                	slli	a3,a3,0x20
    80000d14:	9281                	srli	a3,a3,0x20
    80000d16:	0685                	addi	a3,a3,1
    80000d18:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d1a:	00054783          	lbu	a5,0(a0)
    80000d1e:	0005c703          	lbu	a4,0(a1)
    80000d22:	00e79863          	bne	a5,a4,80000d32 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d26:	0505                	addi	a0,a0,1
    80000d28:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d2a:	fed518e3          	bne	a0,a3,80000d1a <memcmp+0x14>
  }

  return 0;
    80000d2e:	4501                	li	a0,0
    80000d30:	a019                	j	80000d36 <memcmp+0x30>
      return *s1 - *s2;
    80000d32:	40e7853b          	subw	a0,a5,a4
}
    80000d36:	6422                	ld	s0,8(sp)
    80000d38:	0141                	addi	sp,sp,16
    80000d3a:	8082                	ret
  return 0;
    80000d3c:	4501                	li	a0,0
    80000d3e:	bfe5                	j	80000d36 <memcmp+0x30>

0000000080000d40 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d40:	1141                	addi	sp,sp,-16
    80000d42:	e422                	sd	s0,8(sp)
    80000d44:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d46:	ca0d                	beqz	a2,80000d78 <memmove+0x38>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d48:	00a5f963          	bgeu	a1,a0,80000d5a <memmove+0x1a>
    80000d4c:	02061693          	slli	a3,a2,0x20
    80000d50:	9281                	srli	a3,a3,0x20
    80000d52:	00d58733          	add	a4,a1,a3
    80000d56:	02e56463          	bltu	a0,a4,80000d7e <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d5a:	fff6079b          	addiw	a5,a2,-1
    80000d5e:	1782                	slli	a5,a5,0x20
    80000d60:	9381                	srli	a5,a5,0x20
    80000d62:	0785                	addi	a5,a5,1
    80000d64:	97ae                	add	a5,a5,a1
    80000d66:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d68:	0585                	addi	a1,a1,1
    80000d6a:	0705                	addi	a4,a4,1
    80000d6c:	fff5c683          	lbu	a3,-1(a1)
    80000d70:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d74:	fef59ae3          	bne	a1,a5,80000d68 <memmove+0x28>

  return dst;
}
    80000d78:	6422                	ld	s0,8(sp)
    80000d7a:	0141                	addi	sp,sp,16
    80000d7c:	8082                	ret
    d += n;
    80000d7e:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d80:	fff6079b          	addiw	a5,a2,-1
    80000d84:	1782                	slli	a5,a5,0x20
    80000d86:	9381                	srli	a5,a5,0x20
    80000d88:	fff7c793          	not	a5,a5
    80000d8c:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d8e:	177d                	addi	a4,a4,-1
    80000d90:	16fd                	addi	a3,a3,-1
    80000d92:	00074603          	lbu	a2,0(a4)
    80000d96:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d9a:	fef71ae3          	bne	a4,a5,80000d8e <memmove+0x4e>
    80000d9e:	bfe9                	j	80000d78 <memmove+0x38>

0000000080000da0 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000da0:	1141                	addi	sp,sp,-16
    80000da2:	e406                	sd	ra,8(sp)
    80000da4:	e022                	sd	s0,0(sp)
    80000da6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000da8:	00000097          	auipc	ra,0x0
    80000dac:	f98080e7          	jalr	-104(ra) # 80000d40 <memmove>
}
    80000db0:	60a2                	ld	ra,8(sp)
    80000db2:	6402                	ld	s0,0(sp)
    80000db4:	0141                	addi	sp,sp,16
    80000db6:	8082                	ret

0000000080000db8 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000db8:	1141                	addi	sp,sp,-16
    80000dba:	e422                	sd	s0,8(sp)
    80000dbc:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000dbe:	ce11                	beqz	a2,80000dda <strncmp+0x22>
    80000dc0:	00054783          	lbu	a5,0(a0)
    80000dc4:	cf89                	beqz	a5,80000dde <strncmp+0x26>
    80000dc6:	0005c703          	lbu	a4,0(a1)
    80000dca:	00f71a63          	bne	a4,a5,80000dde <strncmp+0x26>
    n--, p++, q++;
    80000dce:	367d                	addiw	a2,a2,-1
    80000dd0:	0505                	addi	a0,a0,1
    80000dd2:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dd4:	f675                	bnez	a2,80000dc0 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dd6:	4501                	li	a0,0
    80000dd8:	a809                	j	80000dea <strncmp+0x32>
    80000dda:	4501                	li	a0,0
    80000ddc:	a039                	j	80000dea <strncmp+0x32>
  if(n == 0)
    80000dde:	ca09                	beqz	a2,80000df0 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000de0:	00054503          	lbu	a0,0(a0)
    80000de4:	0005c783          	lbu	a5,0(a1)
    80000de8:	9d1d                	subw	a0,a0,a5
}
    80000dea:	6422                	ld	s0,8(sp)
    80000dec:	0141                	addi	sp,sp,16
    80000dee:	8082                	ret
    return 0;
    80000df0:	4501                	li	a0,0
    80000df2:	bfe5                	j	80000dea <strncmp+0x32>

0000000080000df4 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000df4:	1141                	addi	sp,sp,-16
    80000df6:	e422                	sd	s0,8(sp)
    80000df8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000dfa:	872a                	mv	a4,a0
    80000dfc:	8832                	mv	a6,a2
    80000dfe:	367d                	addiw	a2,a2,-1
    80000e00:	01005963          	blez	a6,80000e12 <strncpy+0x1e>
    80000e04:	0705                	addi	a4,a4,1
    80000e06:	0005c783          	lbu	a5,0(a1)
    80000e0a:	fef70fa3          	sb	a5,-1(a4)
    80000e0e:	0585                	addi	a1,a1,1
    80000e10:	f7f5                	bnez	a5,80000dfc <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e12:	00c05d63          	blez	a2,80000e2c <strncpy+0x38>
    80000e16:	86ba                	mv	a3,a4
    *s++ = 0;
    80000e18:	0685                	addi	a3,a3,1
    80000e1a:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e1e:	fff6c793          	not	a5,a3
    80000e22:	9fb9                	addw	a5,a5,a4
    80000e24:	010787bb          	addw	a5,a5,a6
    80000e28:	fef048e3          	bgtz	a5,80000e18 <strncpy+0x24>
  return os;
}
    80000e2c:	6422                	ld	s0,8(sp)
    80000e2e:	0141                	addi	sp,sp,16
    80000e30:	8082                	ret

0000000080000e32 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e32:	1141                	addi	sp,sp,-16
    80000e34:	e422                	sd	s0,8(sp)
    80000e36:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e38:	02c05363          	blez	a2,80000e5e <safestrcpy+0x2c>
    80000e3c:	fff6069b          	addiw	a3,a2,-1
    80000e40:	1682                	slli	a3,a3,0x20
    80000e42:	9281                	srli	a3,a3,0x20
    80000e44:	96ae                	add	a3,a3,a1
    80000e46:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e48:	00d58963          	beq	a1,a3,80000e5a <safestrcpy+0x28>
    80000e4c:	0585                	addi	a1,a1,1
    80000e4e:	0785                	addi	a5,a5,1
    80000e50:	fff5c703          	lbu	a4,-1(a1)
    80000e54:	fee78fa3          	sb	a4,-1(a5)
    80000e58:	fb65                	bnez	a4,80000e48 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e5a:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e5e:	6422                	ld	s0,8(sp)
    80000e60:	0141                	addi	sp,sp,16
    80000e62:	8082                	ret

0000000080000e64 <strlen>:

int
strlen(const char *s)
{
    80000e64:	1141                	addi	sp,sp,-16
    80000e66:	e422                	sd	s0,8(sp)
    80000e68:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e6a:	00054783          	lbu	a5,0(a0)
    80000e6e:	cf91                	beqz	a5,80000e8a <strlen+0x26>
    80000e70:	0505                	addi	a0,a0,1
    80000e72:	87aa                	mv	a5,a0
    80000e74:	4685                	li	a3,1
    80000e76:	9e89                	subw	a3,a3,a0
    80000e78:	00f6853b          	addw	a0,a3,a5
    80000e7c:	0785                	addi	a5,a5,1
    80000e7e:	fff7c703          	lbu	a4,-1(a5)
    80000e82:	fb7d                	bnez	a4,80000e78 <strlen+0x14>
    ;
  return n;
}
    80000e84:	6422                	ld	s0,8(sp)
    80000e86:	0141                	addi	sp,sp,16
    80000e88:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e8a:	4501                	li	a0,0
    80000e8c:	bfe5                	j	80000e84 <strlen+0x20>

0000000080000e8e <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e8e:	1141                	addi	sp,sp,-16
    80000e90:	e406                	sd	ra,8(sp)
    80000e92:	e022                	sd	s0,0(sp)
    80000e94:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e96:	00001097          	auipc	ra,0x1
    80000e9a:	aee080e7          	jalr	-1298(ra) # 80001984 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e9e:	00008717          	auipc	a4,0x8
    80000ea2:	17a70713          	addi	a4,a4,378 # 80009018 <started>
  if(cpuid() == 0){
    80000ea6:	c139                	beqz	a0,80000eec <main+0x5e>
    while(started == 0)
    80000ea8:	431c                	lw	a5,0(a4)
    80000eaa:	2781                	sext.w	a5,a5
    80000eac:	dff5                	beqz	a5,80000ea8 <main+0x1a>
      ;
    __sync_synchronize();
    80000eae:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000eb2:	00001097          	auipc	ra,0x1
    80000eb6:	ad2080e7          	jalr	-1326(ra) # 80001984 <cpuid>
    80000eba:	85aa                	mv	a1,a0
    80000ebc:	00007517          	auipc	a0,0x7
    80000ec0:	1fc50513          	addi	a0,a0,508 # 800080b8 <digits+0x78>
    80000ec4:	fffff097          	auipc	ra,0xfffff
    80000ec8:	6c4080e7          	jalr	1732(ra) # 80000588 <printf>
    kvminithart();    // turn on paging
    80000ecc:	00000097          	auipc	ra,0x0
    80000ed0:	0d8080e7          	jalr	216(ra) # 80000fa4 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ed4:	00002097          	auipc	ra,0x2
    80000ed8:	a16080e7          	jalr	-1514(ra) # 800028ea <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000edc:	00005097          	auipc	ra,0x5
    80000ee0:	064080e7          	jalr	100(ra) # 80005f40 <plicinithart>
  }

  scheduler();        
    80000ee4:	00001097          	auipc	ra,0x1
    80000ee8:	fd6080e7          	jalr	-42(ra) # 80001eba <scheduler>
    consoleinit();
    80000eec:	fffff097          	auipc	ra,0xfffff
    80000ef0:	564080e7          	jalr	1380(ra) # 80000450 <consoleinit>
    printfinit();
    80000ef4:	00000097          	auipc	ra,0x0
    80000ef8:	87a080e7          	jalr	-1926(ra) # 8000076e <printfinit>
    printf("\n");
    80000efc:	00007517          	auipc	a0,0x7
    80000f00:	1cc50513          	addi	a0,a0,460 # 800080c8 <digits+0x88>
    80000f04:	fffff097          	auipc	ra,0xfffff
    80000f08:	684080e7          	jalr	1668(ra) # 80000588 <printf>
    printf("xv6 kernel is booting\n");
    80000f0c:	00007517          	auipc	a0,0x7
    80000f10:	19450513          	addi	a0,a0,404 # 800080a0 <digits+0x60>
    80000f14:	fffff097          	auipc	ra,0xfffff
    80000f18:	674080e7          	jalr	1652(ra) # 80000588 <printf>
    printf("\n");
    80000f1c:	00007517          	auipc	a0,0x7
    80000f20:	1ac50513          	addi	a0,a0,428 # 800080c8 <digits+0x88>
    80000f24:	fffff097          	auipc	ra,0xfffff
    80000f28:	664080e7          	jalr	1636(ra) # 80000588 <printf>
    kinit();         // physical page allocator
    80000f2c:	00000097          	auipc	ra,0x0
    80000f30:	b8c080e7          	jalr	-1140(ra) # 80000ab8 <kinit>
    kvminit();       // create kernel page table
    80000f34:	00000097          	auipc	ra,0x0
    80000f38:	322080e7          	jalr	802(ra) # 80001256 <kvminit>
    kvminithart();   // turn on paging
    80000f3c:	00000097          	auipc	ra,0x0
    80000f40:	068080e7          	jalr	104(ra) # 80000fa4 <kvminithart>
    procinit();      // process table
    80000f44:	00001097          	auipc	ra,0x1
    80000f48:	990080e7          	jalr	-1648(ra) # 800018d4 <procinit>
    trapinit();      // trap vectors
    80000f4c:	00002097          	auipc	ra,0x2
    80000f50:	976080e7          	jalr	-1674(ra) # 800028c2 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f54:	00002097          	auipc	ra,0x2
    80000f58:	996080e7          	jalr	-1642(ra) # 800028ea <trapinithart>
    plicinit();      // set up interrupt controller
    80000f5c:	00005097          	auipc	ra,0x5
    80000f60:	fce080e7          	jalr	-50(ra) # 80005f2a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f64:	00005097          	auipc	ra,0x5
    80000f68:	fdc080e7          	jalr	-36(ra) # 80005f40 <plicinithart>
    binit();         // buffer cache
    80000f6c:	00002097          	auipc	ra,0x2
    80000f70:	1c2080e7          	jalr	450(ra) # 8000312e <binit>
    iinit();         // inode table
    80000f74:	00003097          	auipc	ra,0x3
    80000f78:	852080e7          	jalr	-1966(ra) # 800037c6 <iinit>
    fileinit();      // file table
    80000f7c:	00003097          	auipc	ra,0x3
    80000f80:	7fc080e7          	jalr	2044(ra) # 80004778 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f84:	00005097          	auipc	ra,0x5
    80000f88:	0de080e7          	jalr	222(ra) # 80006062 <virtio_disk_init>
    userinit();      // first user process
    80000f8c:	00001097          	auipc	ra,0x1
    80000f90:	cfc080e7          	jalr	-772(ra) # 80001c88 <userinit>
    __sync_synchronize();
    80000f94:	0ff0000f          	fence
    started = 1;
    80000f98:	4785                	li	a5,1
    80000f9a:	00008717          	auipc	a4,0x8
    80000f9e:	06f72f23          	sw	a5,126(a4) # 80009018 <started>
    80000fa2:	b789                	j	80000ee4 <main+0x56>

0000000080000fa4 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000fa4:	1141                	addi	sp,sp,-16
    80000fa6:	e422                	sd	s0,8(sp)
    80000fa8:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000faa:	00008797          	auipc	a5,0x8
    80000fae:	0767b783          	ld	a5,118(a5) # 80009020 <kernel_pagetable>
    80000fb2:	83b1                	srli	a5,a5,0xc
    80000fb4:	577d                	li	a4,-1
    80000fb6:	177e                	slli	a4,a4,0x3f
    80000fb8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fba:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fbe:	12000073          	sfence.vma
  sfence_vma();
}
    80000fc2:	6422                	ld	s0,8(sp)
    80000fc4:	0141                	addi	sp,sp,16
    80000fc6:	8082                	ret

0000000080000fc8 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fc8:	7139                	addi	sp,sp,-64
    80000fca:	fc06                	sd	ra,56(sp)
    80000fcc:	f822                	sd	s0,48(sp)
    80000fce:	f426                	sd	s1,40(sp)
    80000fd0:	f04a                	sd	s2,32(sp)
    80000fd2:	ec4e                	sd	s3,24(sp)
    80000fd4:	e852                	sd	s4,16(sp)
    80000fd6:	e456                	sd	s5,8(sp)
    80000fd8:	e05a                	sd	s6,0(sp)
    80000fda:	0080                	addi	s0,sp,64
    80000fdc:	84aa                	mv	s1,a0
    80000fde:	89ae                	mv	s3,a1
    80000fe0:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fe2:	57fd                	li	a5,-1
    80000fe4:	83e9                	srli	a5,a5,0x1a
    80000fe6:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fe8:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fea:	04b7f263          	bgeu	a5,a1,8000102e <walk+0x66>
    panic("walk");
    80000fee:	00007517          	auipc	a0,0x7
    80000ff2:	0e250513          	addi	a0,a0,226 # 800080d0 <digits+0x90>
    80000ff6:	fffff097          	auipc	ra,0xfffff
    80000ffa:	548080e7          	jalr	1352(ra) # 8000053e <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000ffe:	060a8663          	beqz	s5,8000106a <walk+0xa2>
    80001002:	00000097          	auipc	ra,0x0
    80001006:	af2080e7          	jalr	-1294(ra) # 80000af4 <kalloc>
    8000100a:	84aa                	mv	s1,a0
    8000100c:	c529                	beqz	a0,80001056 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000100e:	6605                	lui	a2,0x1
    80001010:	4581                	li	a1,0
    80001012:	00000097          	auipc	ra,0x0
    80001016:	cce080e7          	jalr	-818(ra) # 80000ce0 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000101a:	00c4d793          	srli	a5,s1,0xc
    8000101e:	07aa                	slli	a5,a5,0xa
    80001020:	0017e793          	ori	a5,a5,1
    80001024:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001028:	3a5d                	addiw	s4,s4,-9
    8000102a:	036a0063          	beq	s4,s6,8000104a <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000102e:	0149d933          	srl	s2,s3,s4
    80001032:	1ff97913          	andi	s2,s2,511
    80001036:	090e                	slli	s2,s2,0x3
    80001038:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000103a:	00093483          	ld	s1,0(s2)
    8000103e:	0014f793          	andi	a5,s1,1
    80001042:	dfd5                	beqz	a5,80000ffe <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001044:	80a9                	srli	s1,s1,0xa
    80001046:	04b2                	slli	s1,s1,0xc
    80001048:	b7c5                	j	80001028 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000104a:	00c9d513          	srli	a0,s3,0xc
    8000104e:	1ff57513          	andi	a0,a0,511
    80001052:	050e                	slli	a0,a0,0x3
    80001054:	9526                	add	a0,a0,s1
}
    80001056:	70e2                	ld	ra,56(sp)
    80001058:	7442                	ld	s0,48(sp)
    8000105a:	74a2                	ld	s1,40(sp)
    8000105c:	7902                	ld	s2,32(sp)
    8000105e:	69e2                	ld	s3,24(sp)
    80001060:	6a42                	ld	s4,16(sp)
    80001062:	6aa2                	ld	s5,8(sp)
    80001064:	6b02                	ld	s6,0(sp)
    80001066:	6121                	addi	sp,sp,64
    80001068:	8082                	ret
        return 0;
    8000106a:	4501                	li	a0,0
    8000106c:	b7ed                	j	80001056 <walk+0x8e>

000000008000106e <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000106e:	57fd                	li	a5,-1
    80001070:	83e9                	srli	a5,a5,0x1a
    80001072:	00b7f463          	bgeu	a5,a1,8000107a <walkaddr+0xc>
    return 0;
    80001076:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001078:	8082                	ret
{
    8000107a:	1141                	addi	sp,sp,-16
    8000107c:	e406                	sd	ra,8(sp)
    8000107e:	e022                	sd	s0,0(sp)
    80001080:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001082:	4601                	li	a2,0
    80001084:	00000097          	auipc	ra,0x0
    80001088:	f44080e7          	jalr	-188(ra) # 80000fc8 <walk>
  if(pte == 0)
    8000108c:	c105                	beqz	a0,800010ac <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000108e:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001090:	0117f693          	andi	a3,a5,17
    80001094:	4745                	li	a4,17
    return 0;
    80001096:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001098:	00e68663          	beq	a3,a4,800010a4 <walkaddr+0x36>
}
    8000109c:	60a2                	ld	ra,8(sp)
    8000109e:	6402                	ld	s0,0(sp)
    800010a0:	0141                	addi	sp,sp,16
    800010a2:	8082                	ret
  pa = PTE2PA(*pte);
    800010a4:	00a7d513          	srli	a0,a5,0xa
    800010a8:	0532                	slli	a0,a0,0xc
  return pa;
    800010aa:	bfcd                	j	8000109c <walkaddr+0x2e>
    return 0;
    800010ac:	4501                	li	a0,0
    800010ae:	b7fd                	j	8000109c <walkaddr+0x2e>

00000000800010b0 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010b0:	715d                	addi	sp,sp,-80
    800010b2:	e486                	sd	ra,72(sp)
    800010b4:	e0a2                	sd	s0,64(sp)
    800010b6:	fc26                	sd	s1,56(sp)
    800010b8:	f84a                	sd	s2,48(sp)
    800010ba:	f44e                	sd	s3,40(sp)
    800010bc:	f052                	sd	s4,32(sp)
    800010be:	ec56                	sd	s5,24(sp)
    800010c0:	e85a                	sd	s6,16(sp)
    800010c2:	e45e                	sd	s7,8(sp)
    800010c4:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010c6:	c205                	beqz	a2,800010e6 <mappages+0x36>
    800010c8:	8aaa                	mv	s5,a0
    800010ca:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010cc:	77fd                	lui	a5,0xfffff
    800010ce:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800010d2:	15fd                	addi	a1,a1,-1
    800010d4:	00c589b3          	add	s3,a1,a2
    800010d8:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    800010dc:	8952                	mv	s2,s4
    800010de:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010e2:	6b85                	lui	s7,0x1
    800010e4:	a015                	j	80001108 <mappages+0x58>
    panic("mappages: size");
    800010e6:	00007517          	auipc	a0,0x7
    800010ea:	ff250513          	addi	a0,a0,-14 # 800080d8 <digits+0x98>
    800010ee:	fffff097          	auipc	ra,0xfffff
    800010f2:	450080e7          	jalr	1104(ra) # 8000053e <panic>
      panic("mappages: remap");
    800010f6:	00007517          	auipc	a0,0x7
    800010fa:	ff250513          	addi	a0,a0,-14 # 800080e8 <digits+0xa8>
    800010fe:	fffff097          	auipc	ra,0xfffff
    80001102:	440080e7          	jalr	1088(ra) # 8000053e <panic>
    a += PGSIZE;
    80001106:	995e                	add	s2,s2,s7
  for(;;){
    80001108:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    8000110c:	4605                	li	a2,1
    8000110e:	85ca                	mv	a1,s2
    80001110:	8556                	mv	a0,s5
    80001112:	00000097          	auipc	ra,0x0
    80001116:	eb6080e7          	jalr	-330(ra) # 80000fc8 <walk>
    8000111a:	cd19                	beqz	a0,80001138 <mappages+0x88>
    if(*pte & PTE_V)
    8000111c:	611c                	ld	a5,0(a0)
    8000111e:	8b85                	andi	a5,a5,1
    80001120:	fbf9                	bnez	a5,800010f6 <mappages+0x46>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001122:	80b1                	srli	s1,s1,0xc
    80001124:	04aa                	slli	s1,s1,0xa
    80001126:	0164e4b3          	or	s1,s1,s6
    8000112a:	0014e493          	ori	s1,s1,1
    8000112e:	e104                	sd	s1,0(a0)
    if(a == last)
    80001130:	fd391be3          	bne	s2,s3,80001106 <mappages+0x56>
    pa += PGSIZE;
  }
  return 0;
    80001134:	4501                	li	a0,0
    80001136:	a011                	j	8000113a <mappages+0x8a>
      return -1;
    80001138:	557d                	li	a0,-1
}
    8000113a:	60a6                	ld	ra,72(sp)
    8000113c:	6406                	ld	s0,64(sp)
    8000113e:	74e2                	ld	s1,56(sp)
    80001140:	7942                	ld	s2,48(sp)
    80001142:	79a2                	ld	s3,40(sp)
    80001144:	7a02                	ld	s4,32(sp)
    80001146:	6ae2                	ld	s5,24(sp)
    80001148:	6b42                	ld	s6,16(sp)
    8000114a:	6ba2                	ld	s7,8(sp)
    8000114c:	6161                	addi	sp,sp,80
    8000114e:	8082                	ret

0000000080001150 <kvmmap>:
{
    80001150:	1141                	addi	sp,sp,-16
    80001152:	e406                	sd	ra,8(sp)
    80001154:	e022                	sd	s0,0(sp)
    80001156:	0800                	addi	s0,sp,16
    80001158:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000115a:	86b2                	mv	a3,a2
    8000115c:	863e                	mv	a2,a5
    8000115e:	00000097          	auipc	ra,0x0
    80001162:	f52080e7          	jalr	-174(ra) # 800010b0 <mappages>
    80001166:	e509                	bnez	a0,80001170 <kvmmap+0x20>
}
    80001168:	60a2                	ld	ra,8(sp)
    8000116a:	6402                	ld	s0,0(sp)
    8000116c:	0141                	addi	sp,sp,16
    8000116e:	8082                	ret
    panic("kvmmap");
    80001170:	00007517          	auipc	a0,0x7
    80001174:	f8850513          	addi	a0,a0,-120 # 800080f8 <digits+0xb8>
    80001178:	fffff097          	auipc	ra,0xfffff
    8000117c:	3c6080e7          	jalr	966(ra) # 8000053e <panic>

0000000080001180 <kvmmake>:
{
    80001180:	1101                	addi	sp,sp,-32
    80001182:	ec06                	sd	ra,24(sp)
    80001184:	e822                	sd	s0,16(sp)
    80001186:	e426                	sd	s1,8(sp)
    80001188:	e04a                	sd	s2,0(sp)
    8000118a:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000118c:	00000097          	auipc	ra,0x0
    80001190:	968080e7          	jalr	-1688(ra) # 80000af4 <kalloc>
    80001194:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001196:	6605                	lui	a2,0x1
    80001198:	4581                	li	a1,0
    8000119a:	00000097          	auipc	ra,0x0
    8000119e:	b46080e7          	jalr	-1210(ra) # 80000ce0 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011a2:	4719                	li	a4,6
    800011a4:	6685                	lui	a3,0x1
    800011a6:	10000637          	lui	a2,0x10000
    800011aa:	100005b7          	lui	a1,0x10000
    800011ae:	8526                	mv	a0,s1
    800011b0:	00000097          	auipc	ra,0x0
    800011b4:	fa0080e7          	jalr	-96(ra) # 80001150 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011b8:	4719                	li	a4,6
    800011ba:	6685                	lui	a3,0x1
    800011bc:	10001637          	lui	a2,0x10001
    800011c0:	100015b7          	lui	a1,0x10001
    800011c4:	8526                	mv	a0,s1
    800011c6:	00000097          	auipc	ra,0x0
    800011ca:	f8a080e7          	jalr	-118(ra) # 80001150 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011ce:	4719                	li	a4,6
    800011d0:	004006b7          	lui	a3,0x400
    800011d4:	0c000637          	lui	a2,0xc000
    800011d8:	0c0005b7          	lui	a1,0xc000
    800011dc:	8526                	mv	a0,s1
    800011de:	00000097          	auipc	ra,0x0
    800011e2:	f72080e7          	jalr	-142(ra) # 80001150 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011e6:	00007917          	auipc	s2,0x7
    800011ea:	e1a90913          	addi	s2,s2,-486 # 80008000 <etext>
    800011ee:	4729                	li	a4,10
    800011f0:	80007697          	auipc	a3,0x80007
    800011f4:	e1068693          	addi	a3,a3,-496 # 8000 <_entry-0x7fff8000>
    800011f8:	4605                	li	a2,1
    800011fa:	067e                	slli	a2,a2,0x1f
    800011fc:	85b2                	mv	a1,a2
    800011fe:	8526                	mv	a0,s1
    80001200:	00000097          	auipc	ra,0x0
    80001204:	f50080e7          	jalr	-176(ra) # 80001150 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001208:	4719                	li	a4,6
    8000120a:	46c5                	li	a3,17
    8000120c:	06ee                	slli	a3,a3,0x1b
    8000120e:	412686b3          	sub	a3,a3,s2
    80001212:	864a                	mv	a2,s2
    80001214:	85ca                	mv	a1,s2
    80001216:	8526                	mv	a0,s1
    80001218:	00000097          	auipc	ra,0x0
    8000121c:	f38080e7          	jalr	-200(ra) # 80001150 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001220:	4729                	li	a4,10
    80001222:	6685                	lui	a3,0x1
    80001224:	00006617          	auipc	a2,0x6
    80001228:	ddc60613          	addi	a2,a2,-548 # 80007000 <_trampoline>
    8000122c:	040005b7          	lui	a1,0x4000
    80001230:	15fd                	addi	a1,a1,-1
    80001232:	05b2                	slli	a1,a1,0xc
    80001234:	8526                	mv	a0,s1
    80001236:	00000097          	auipc	ra,0x0
    8000123a:	f1a080e7          	jalr	-230(ra) # 80001150 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000123e:	8526                	mv	a0,s1
    80001240:	00000097          	auipc	ra,0x0
    80001244:	5fe080e7          	jalr	1534(ra) # 8000183e <proc_mapstacks>
}
    80001248:	8526                	mv	a0,s1
    8000124a:	60e2                	ld	ra,24(sp)
    8000124c:	6442                	ld	s0,16(sp)
    8000124e:	64a2                	ld	s1,8(sp)
    80001250:	6902                	ld	s2,0(sp)
    80001252:	6105                	addi	sp,sp,32
    80001254:	8082                	ret

0000000080001256 <kvminit>:
{
    80001256:	1141                	addi	sp,sp,-16
    80001258:	e406                	sd	ra,8(sp)
    8000125a:	e022                	sd	s0,0(sp)
    8000125c:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000125e:	00000097          	auipc	ra,0x0
    80001262:	f22080e7          	jalr	-222(ra) # 80001180 <kvmmake>
    80001266:	00008797          	auipc	a5,0x8
    8000126a:	daa7bd23          	sd	a0,-582(a5) # 80009020 <kernel_pagetable>
}
    8000126e:	60a2                	ld	ra,8(sp)
    80001270:	6402                	ld	s0,0(sp)
    80001272:	0141                	addi	sp,sp,16
    80001274:	8082                	ret

0000000080001276 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001276:	715d                	addi	sp,sp,-80
    80001278:	e486                	sd	ra,72(sp)
    8000127a:	e0a2                	sd	s0,64(sp)
    8000127c:	fc26                	sd	s1,56(sp)
    8000127e:	f84a                	sd	s2,48(sp)
    80001280:	f44e                	sd	s3,40(sp)
    80001282:	f052                	sd	s4,32(sp)
    80001284:	ec56                	sd	s5,24(sp)
    80001286:	e85a                	sd	s6,16(sp)
    80001288:	e45e                	sd	s7,8(sp)
    8000128a:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000128c:	03459793          	slli	a5,a1,0x34
    80001290:	e795                	bnez	a5,800012bc <uvmunmap+0x46>
    80001292:	8a2a                	mv	s4,a0
    80001294:	892e                	mv	s2,a1
    80001296:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001298:	0632                	slli	a2,a2,0xc
    8000129a:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000129e:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012a0:	6b05                	lui	s6,0x1
    800012a2:	0735e863          	bltu	a1,s3,80001312 <uvmunmap+0x9c>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800012a6:	60a6                	ld	ra,72(sp)
    800012a8:	6406                	ld	s0,64(sp)
    800012aa:	74e2                	ld	s1,56(sp)
    800012ac:	7942                	ld	s2,48(sp)
    800012ae:	79a2                	ld	s3,40(sp)
    800012b0:	7a02                	ld	s4,32(sp)
    800012b2:	6ae2                	ld	s5,24(sp)
    800012b4:	6b42                	ld	s6,16(sp)
    800012b6:	6ba2                	ld	s7,8(sp)
    800012b8:	6161                	addi	sp,sp,80
    800012ba:	8082                	ret
    panic("uvmunmap: not aligned");
    800012bc:	00007517          	auipc	a0,0x7
    800012c0:	e4450513          	addi	a0,a0,-444 # 80008100 <digits+0xc0>
    800012c4:	fffff097          	auipc	ra,0xfffff
    800012c8:	27a080e7          	jalr	634(ra) # 8000053e <panic>
      panic("uvmunmap: walk");
    800012cc:	00007517          	auipc	a0,0x7
    800012d0:	e4c50513          	addi	a0,a0,-436 # 80008118 <digits+0xd8>
    800012d4:	fffff097          	auipc	ra,0xfffff
    800012d8:	26a080e7          	jalr	618(ra) # 8000053e <panic>
      panic("uvmunmap: not mapped");
    800012dc:	00007517          	auipc	a0,0x7
    800012e0:	e4c50513          	addi	a0,a0,-436 # 80008128 <digits+0xe8>
    800012e4:	fffff097          	auipc	ra,0xfffff
    800012e8:	25a080e7          	jalr	602(ra) # 8000053e <panic>
      panic("uvmunmap: not a leaf");
    800012ec:	00007517          	auipc	a0,0x7
    800012f0:	e5450513          	addi	a0,a0,-428 # 80008140 <digits+0x100>
    800012f4:	fffff097          	auipc	ra,0xfffff
    800012f8:	24a080e7          	jalr	586(ra) # 8000053e <panic>
      uint64 pa = PTE2PA(*pte);
    800012fc:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800012fe:	0532                	slli	a0,a0,0xc
    80001300:	fffff097          	auipc	ra,0xfffff
    80001304:	6f8080e7          	jalr	1784(ra) # 800009f8 <kfree>
    *pte = 0;
    80001308:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000130c:	995a                	add	s2,s2,s6
    8000130e:	f9397ce3          	bgeu	s2,s3,800012a6 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001312:	4601                	li	a2,0
    80001314:	85ca                	mv	a1,s2
    80001316:	8552                	mv	a0,s4
    80001318:	00000097          	auipc	ra,0x0
    8000131c:	cb0080e7          	jalr	-848(ra) # 80000fc8 <walk>
    80001320:	84aa                	mv	s1,a0
    80001322:	d54d                	beqz	a0,800012cc <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001324:	6108                	ld	a0,0(a0)
    80001326:	00157793          	andi	a5,a0,1
    8000132a:	dbcd                	beqz	a5,800012dc <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000132c:	3ff57793          	andi	a5,a0,1023
    80001330:	fb778ee3          	beq	a5,s7,800012ec <uvmunmap+0x76>
    if(do_free){
    80001334:	fc0a8ae3          	beqz	s5,80001308 <uvmunmap+0x92>
    80001338:	b7d1                	j	800012fc <uvmunmap+0x86>

000000008000133a <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000133a:	1101                	addi	sp,sp,-32
    8000133c:	ec06                	sd	ra,24(sp)
    8000133e:	e822                	sd	s0,16(sp)
    80001340:	e426                	sd	s1,8(sp)
    80001342:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001344:	fffff097          	auipc	ra,0xfffff
    80001348:	7b0080e7          	jalr	1968(ra) # 80000af4 <kalloc>
    8000134c:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000134e:	c519                	beqz	a0,8000135c <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001350:	6605                	lui	a2,0x1
    80001352:	4581                	li	a1,0
    80001354:	00000097          	auipc	ra,0x0
    80001358:	98c080e7          	jalr	-1652(ra) # 80000ce0 <memset>
  return pagetable;
}
    8000135c:	8526                	mv	a0,s1
    8000135e:	60e2                	ld	ra,24(sp)
    80001360:	6442                	ld	s0,16(sp)
    80001362:	64a2                	ld	s1,8(sp)
    80001364:	6105                	addi	sp,sp,32
    80001366:	8082                	ret

0000000080001368 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80001368:	7179                	addi	sp,sp,-48
    8000136a:	f406                	sd	ra,40(sp)
    8000136c:	f022                	sd	s0,32(sp)
    8000136e:	ec26                	sd	s1,24(sp)
    80001370:	e84a                	sd	s2,16(sp)
    80001372:	e44e                	sd	s3,8(sp)
    80001374:	e052                	sd	s4,0(sp)
    80001376:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001378:	6785                	lui	a5,0x1
    8000137a:	04f67863          	bgeu	a2,a5,800013ca <uvminit+0x62>
    8000137e:	8a2a                	mv	s4,a0
    80001380:	89ae                	mv	s3,a1
    80001382:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001384:	fffff097          	auipc	ra,0xfffff
    80001388:	770080e7          	jalr	1904(ra) # 80000af4 <kalloc>
    8000138c:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000138e:	6605                	lui	a2,0x1
    80001390:	4581                	li	a1,0
    80001392:	00000097          	auipc	ra,0x0
    80001396:	94e080e7          	jalr	-1714(ra) # 80000ce0 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000139a:	4779                	li	a4,30
    8000139c:	86ca                	mv	a3,s2
    8000139e:	6605                	lui	a2,0x1
    800013a0:	4581                	li	a1,0
    800013a2:	8552                	mv	a0,s4
    800013a4:	00000097          	auipc	ra,0x0
    800013a8:	d0c080e7          	jalr	-756(ra) # 800010b0 <mappages>
  memmove(mem, src, sz);
    800013ac:	8626                	mv	a2,s1
    800013ae:	85ce                	mv	a1,s3
    800013b0:	854a                	mv	a0,s2
    800013b2:	00000097          	auipc	ra,0x0
    800013b6:	98e080e7          	jalr	-1650(ra) # 80000d40 <memmove>
}
    800013ba:	70a2                	ld	ra,40(sp)
    800013bc:	7402                	ld	s0,32(sp)
    800013be:	64e2                	ld	s1,24(sp)
    800013c0:	6942                	ld	s2,16(sp)
    800013c2:	69a2                	ld	s3,8(sp)
    800013c4:	6a02                	ld	s4,0(sp)
    800013c6:	6145                	addi	sp,sp,48
    800013c8:	8082                	ret
    panic("inituvm: more than a page");
    800013ca:	00007517          	auipc	a0,0x7
    800013ce:	d8e50513          	addi	a0,a0,-626 # 80008158 <digits+0x118>
    800013d2:	fffff097          	auipc	ra,0xfffff
    800013d6:	16c080e7          	jalr	364(ra) # 8000053e <panic>

00000000800013da <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013da:	1101                	addi	sp,sp,-32
    800013dc:	ec06                	sd	ra,24(sp)
    800013de:	e822                	sd	s0,16(sp)
    800013e0:	e426                	sd	s1,8(sp)
    800013e2:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013e4:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013e6:	00b67d63          	bgeu	a2,a1,80001400 <uvmdealloc+0x26>
    800013ea:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013ec:	6785                	lui	a5,0x1
    800013ee:	17fd                	addi	a5,a5,-1
    800013f0:	00f60733          	add	a4,a2,a5
    800013f4:	767d                	lui	a2,0xfffff
    800013f6:	8f71                	and	a4,a4,a2
    800013f8:	97ae                	add	a5,a5,a1
    800013fa:	8ff1                	and	a5,a5,a2
    800013fc:	00f76863          	bltu	a4,a5,8000140c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001400:	8526                	mv	a0,s1
    80001402:	60e2                	ld	ra,24(sp)
    80001404:	6442                	ld	s0,16(sp)
    80001406:	64a2                	ld	s1,8(sp)
    80001408:	6105                	addi	sp,sp,32
    8000140a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000140c:	8f99                	sub	a5,a5,a4
    8000140e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001410:	4685                	li	a3,1
    80001412:	0007861b          	sext.w	a2,a5
    80001416:	85ba                	mv	a1,a4
    80001418:	00000097          	auipc	ra,0x0
    8000141c:	e5e080e7          	jalr	-418(ra) # 80001276 <uvmunmap>
    80001420:	b7c5                	j	80001400 <uvmdealloc+0x26>

0000000080001422 <uvmalloc>:
  if(newsz < oldsz)
    80001422:	0ab66163          	bltu	a2,a1,800014c4 <uvmalloc+0xa2>
{
    80001426:	7139                	addi	sp,sp,-64
    80001428:	fc06                	sd	ra,56(sp)
    8000142a:	f822                	sd	s0,48(sp)
    8000142c:	f426                	sd	s1,40(sp)
    8000142e:	f04a                	sd	s2,32(sp)
    80001430:	ec4e                	sd	s3,24(sp)
    80001432:	e852                	sd	s4,16(sp)
    80001434:	e456                	sd	s5,8(sp)
    80001436:	0080                	addi	s0,sp,64
    80001438:	8aaa                	mv	s5,a0
    8000143a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000143c:	6985                	lui	s3,0x1
    8000143e:	19fd                	addi	s3,s3,-1
    80001440:	95ce                	add	a1,a1,s3
    80001442:	79fd                	lui	s3,0xfffff
    80001444:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001448:	08c9f063          	bgeu	s3,a2,800014c8 <uvmalloc+0xa6>
    8000144c:	894e                	mv	s2,s3
    mem = kalloc();
    8000144e:	fffff097          	auipc	ra,0xfffff
    80001452:	6a6080e7          	jalr	1702(ra) # 80000af4 <kalloc>
    80001456:	84aa                	mv	s1,a0
    if(mem == 0){
    80001458:	c51d                	beqz	a0,80001486 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    8000145a:	6605                	lui	a2,0x1
    8000145c:	4581                	li	a1,0
    8000145e:	00000097          	auipc	ra,0x0
    80001462:	882080e7          	jalr	-1918(ra) # 80000ce0 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001466:	4779                	li	a4,30
    80001468:	86a6                	mv	a3,s1
    8000146a:	6605                	lui	a2,0x1
    8000146c:	85ca                	mv	a1,s2
    8000146e:	8556                	mv	a0,s5
    80001470:	00000097          	auipc	ra,0x0
    80001474:	c40080e7          	jalr	-960(ra) # 800010b0 <mappages>
    80001478:	e905                	bnez	a0,800014a8 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000147a:	6785                	lui	a5,0x1
    8000147c:	993e                	add	s2,s2,a5
    8000147e:	fd4968e3          	bltu	s2,s4,8000144e <uvmalloc+0x2c>
  return newsz;
    80001482:	8552                	mv	a0,s4
    80001484:	a809                	j	80001496 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001486:	864e                	mv	a2,s3
    80001488:	85ca                	mv	a1,s2
    8000148a:	8556                	mv	a0,s5
    8000148c:	00000097          	auipc	ra,0x0
    80001490:	f4e080e7          	jalr	-178(ra) # 800013da <uvmdealloc>
      return 0;
    80001494:	4501                	li	a0,0
}
    80001496:	70e2                	ld	ra,56(sp)
    80001498:	7442                	ld	s0,48(sp)
    8000149a:	74a2                	ld	s1,40(sp)
    8000149c:	7902                	ld	s2,32(sp)
    8000149e:	69e2                	ld	s3,24(sp)
    800014a0:	6a42                	ld	s4,16(sp)
    800014a2:	6aa2                	ld	s5,8(sp)
    800014a4:	6121                	addi	sp,sp,64
    800014a6:	8082                	ret
      kfree(mem);
    800014a8:	8526                	mv	a0,s1
    800014aa:	fffff097          	auipc	ra,0xfffff
    800014ae:	54e080e7          	jalr	1358(ra) # 800009f8 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014b2:	864e                	mv	a2,s3
    800014b4:	85ca                	mv	a1,s2
    800014b6:	8556                	mv	a0,s5
    800014b8:	00000097          	auipc	ra,0x0
    800014bc:	f22080e7          	jalr	-222(ra) # 800013da <uvmdealloc>
      return 0;
    800014c0:	4501                	li	a0,0
    800014c2:	bfd1                	j	80001496 <uvmalloc+0x74>
    return oldsz;
    800014c4:	852e                	mv	a0,a1
}
    800014c6:	8082                	ret
  return newsz;
    800014c8:	8532                	mv	a0,a2
    800014ca:	b7f1                	j	80001496 <uvmalloc+0x74>

00000000800014cc <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014cc:	7179                	addi	sp,sp,-48
    800014ce:	f406                	sd	ra,40(sp)
    800014d0:	f022                	sd	s0,32(sp)
    800014d2:	ec26                	sd	s1,24(sp)
    800014d4:	e84a                	sd	s2,16(sp)
    800014d6:	e44e                	sd	s3,8(sp)
    800014d8:	e052                	sd	s4,0(sp)
    800014da:	1800                	addi	s0,sp,48
    800014dc:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014de:	84aa                	mv	s1,a0
    800014e0:	6905                	lui	s2,0x1
    800014e2:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014e4:	4985                	li	s3,1
    800014e6:	a821                	j	800014fe <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014e8:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014ea:	0532                	slli	a0,a0,0xc
    800014ec:	00000097          	auipc	ra,0x0
    800014f0:	fe0080e7          	jalr	-32(ra) # 800014cc <freewalk>
      pagetable[i] = 0;
    800014f4:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014f8:	04a1                	addi	s1,s1,8
    800014fa:	03248163          	beq	s1,s2,8000151c <freewalk+0x50>
    pte_t pte = pagetable[i];
    800014fe:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001500:	00f57793          	andi	a5,a0,15
    80001504:	ff3782e3          	beq	a5,s3,800014e8 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001508:	8905                	andi	a0,a0,1
    8000150a:	d57d                	beqz	a0,800014f8 <freewalk+0x2c>
      panic("freewalk: leaf");
    8000150c:	00007517          	auipc	a0,0x7
    80001510:	c6c50513          	addi	a0,a0,-916 # 80008178 <digits+0x138>
    80001514:	fffff097          	auipc	ra,0xfffff
    80001518:	02a080e7          	jalr	42(ra) # 8000053e <panic>
    }
  }
  kfree((void*)pagetable);
    8000151c:	8552                	mv	a0,s4
    8000151e:	fffff097          	auipc	ra,0xfffff
    80001522:	4da080e7          	jalr	1242(ra) # 800009f8 <kfree>
}
    80001526:	70a2                	ld	ra,40(sp)
    80001528:	7402                	ld	s0,32(sp)
    8000152a:	64e2                	ld	s1,24(sp)
    8000152c:	6942                	ld	s2,16(sp)
    8000152e:	69a2                	ld	s3,8(sp)
    80001530:	6a02                	ld	s4,0(sp)
    80001532:	6145                	addi	sp,sp,48
    80001534:	8082                	ret

0000000080001536 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001536:	1101                	addi	sp,sp,-32
    80001538:	ec06                	sd	ra,24(sp)
    8000153a:	e822                	sd	s0,16(sp)
    8000153c:	e426                	sd	s1,8(sp)
    8000153e:	1000                	addi	s0,sp,32
    80001540:	84aa                	mv	s1,a0
  if(sz > 0)
    80001542:	e999                	bnez	a1,80001558 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001544:	8526                	mv	a0,s1
    80001546:	00000097          	auipc	ra,0x0
    8000154a:	f86080e7          	jalr	-122(ra) # 800014cc <freewalk>
}
    8000154e:	60e2                	ld	ra,24(sp)
    80001550:	6442                	ld	s0,16(sp)
    80001552:	64a2                	ld	s1,8(sp)
    80001554:	6105                	addi	sp,sp,32
    80001556:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001558:	6605                	lui	a2,0x1
    8000155a:	167d                	addi	a2,a2,-1
    8000155c:	962e                	add	a2,a2,a1
    8000155e:	4685                	li	a3,1
    80001560:	8231                	srli	a2,a2,0xc
    80001562:	4581                	li	a1,0
    80001564:	00000097          	auipc	ra,0x0
    80001568:	d12080e7          	jalr	-750(ra) # 80001276 <uvmunmap>
    8000156c:	bfe1                	j	80001544 <uvmfree+0xe>

000000008000156e <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000156e:	c679                	beqz	a2,8000163c <uvmcopy+0xce>
{
    80001570:	715d                	addi	sp,sp,-80
    80001572:	e486                	sd	ra,72(sp)
    80001574:	e0a2                	sd	s0,64(sp)
    80001576:	fc26                	sd	s1,56(sp)
    80001578:	f84a                	sd	s2,48(sp)
    8000157a:	f44e                	sd	s3,40(sp)
    8000157c:	f052                	sd	s4,32(sp)
    8000157e:	ec56                	sd	s5,24(sp)
    80001580:	e85a                	sd	s6,16(sp)
    80001582:	e45e                	sd	s7,8(sp)
    80001584:	0880                	addi	s0,sp,80
    80001586:	8b2a                	mv	s6,a0
    80001588:	8aae                	mv	s5,a1
    8000158a:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000158c:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000158e:	4601                	li	a2,0
    80001590:	85ce                	mv	a1,s3
    80001592:	855a                	mv	a0,s6
    80001594:	00000097          	auipc	ra,0x0
    80001598:	a34080e7          	jalr	-1484(ra) # 80000fc8 <walk>
    8000159c:	c531                	beqz	a0,800015e8 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000159e:	6118                	ld	a4,0(a0)
    800015a0:	00177793          	andi	a5,a4,1
    800015a4:	cbb1                	beqz	a5,800015f8 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015a6:	00a75593          	srli	a1,a4,0xa
    800015aa:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015ae:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015b2:	fffff097          	auipc	ra,0xfffff
    800015b6:	542080e7          	jalr	1346(ra) # 80000af4 <kalloc>
    800015ba:	892a                	mv	s2,a0
    800015bc:	c939                	beqz	a0,80001612 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015be:	6605                	lui	a2,0x1
    800015c0:	85de                	mv	a1,s7
    800015c2:	fffff097          	auipc	ra,0xfffff
    800015c6:	77e080e7          	jalr	1918(ra) # 80000d40 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015ca:	8726                	mv	a4,s1
    800015cc:	86ca                	mv	a3,s2
    800015ce:	6605                	lui	a2,0x1
    800015d0:	85ce                	mv	a1,s3
    800015d2:	8556                	mv	a0,s5
    800015d4:	00000097          	auipc	ra,0x0
    800015d8:	adc080e7          	jalr	-1316(ra) # 800010b0 <mappages>
    800015dc:	e515                	bnez	a0,80001608 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015de:	6785                	lui	a5,0x1
    800015e0:	99be                	add	s3,s3,a5
    800015e2:	fb49e6e3          	bltu	s3,s4,8000158e <uvmcopy+0x20>
    800015e6:	a081                	j	80001626 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015e8:	00007517          	auipc	a0,0x7
    800015ec:	ba050513          	addi	a0,a0,-1120 # 80008188 <digits+0x148>
    800015f0:	fffff097          	auipc	ra,0xfffff
    800015f4:	f4e080e7          	jalr	-178(ra) # 8000053e <panic>
      panic("uvmcopy: page not present");
    800015f8:	00007517          	auipc	a0,0x7
    800015fc:	bb050513          	addi	a0,a0,-1104 # 800081a8 <digits+0x168>
    80001600:	fffff097          	auipc	ra,0xfffff
    80001604:	f3e080e7          	jalr	-194(ra) # 8000053e <panic>
      kfree(mem);
    80001608:	854a                	mv	a0,s2
    8000160a:	fffff097          	auipc	ra,0xfffff
    8000160e:	3ee080e7          	jalr	1006(ra) # 800009f8 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001612:	4685                	li	a3,1
    80001614:	00c9d613          	srli	a2,s3,0xc
    80001618:	4581                	li	a1,0
    8000161a:	8556                	mv	a0,s5
    8000161c:	00000097          	auipc	ra,0x0
    80001620:	c5a080e7          	jalr	-934(ra) # 80001276 <uvmunmap>
  return -1;
    80001624:	557d                	li	a0,-1
}
    80001626:	60a6                	ld	ra,72(sp)
    80001628:	6406                	ld	s0,64(sp)
    8000162a:	74e2                	ld	s1,56(sp)
    8000162c:	7942                	ld	s2,48(sp)
    8000162e:	79a2                	ld	s3,40(sp)
    80001630:	7a02                	ld	s4,32(sp)
    80001632:	6ae2                	ld	s5,24(sp)
    80001634:	6b42                	ld	s6,16(sp)
    80001636:	6ba2                	ld	s7,8(sp)
    80001638:	6161                	addi	sp,sp,80
    8000163a:	8082                	ret
  return 0;
    8000163c:	4501                	li	a0,0
}
    8000163e:	8082                	ret

0000000080001640 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001640:	1141                	addi	sp,sp,-16
    80001642:	e406                	sd	ra,8(sp)
    80001644:	e022                	sd	s0,0(sp)
    80001646:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001648:	4601                	li	a2,0
    8000164a:	00000097          	auipc	ra,0x0
    8000164e:	97e080e7          	jalr	-1666(ra) # 80000fc8 <walk>
  if(pte == 0)
    80001652:	c901                	beqz	a0,80001662 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001654:	611c                	ld	a5,0(a0)
    80001656:	9bbd                	andi	a5,a5,-17
    80001658:	e11c                	sd	a5,0(a0)
}
    8000165a:	60a2                	ld	ra,8(sp)
    8000165c:	6402                	ld	s0,0(sp)
    8000165e:	0141                	addi	sp,sp,16
    80001660:	8082                	ret
    panic("uvmclear");
    80001662:	00007517          	auipc	a0,0x7
    80001666:	b6650513          	addi	a0,a0,-1178 # 800081c8 <digits+0x188>
    8000166a:	fffff097          	auipc	ra,0xfffff
    8000166e:	ed4080e7          	jalr	-300(ra) # 8000053e <panic>

0000000080001672 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001672:	c6bd                	beqz	a3,800016e0 <copyout+0x6e>
{
    80001674:	715d                	addi	sp,sp,-80
    80001676:	e486                	sd	ra,72(sp)
    80001678:	e0a2                	sd	s0,64(sp)
    8000167a:	fc26                	sd	s1,56(sp)
    8000167c:	f84a                	sd	s2,48(sp)
    8000167e:	f44e                	sd	s3,40(sp)
    80001680:	f052                	sd	s4,32(sp)
    80001682:	ec56                	sd	s5,24(sp)
    80001684:	e85a                	sd	s6,16(sp)
    80001686:	e45e                	sd	s7,8(sp)
    80001688:	e062                	sd	s8,0(sp)
    8000168a:	0880                	addi	s0,sp,80
    8000168c:	8b2a                	mv	s6,a0
    8000168e:	8c2e                	mv	s8,a1
    80001690:	8a32                	mv	s4,a2
    80001692:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001694:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001696:	6a85                	lui	s5,0x1
    80001698:	a015                	j	800016bc <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000169a:	9562                	add	a0,a0,s8
    8000169c:	0004861b          	sext.w	a2,s1
    800016a0:	85d2                	mv	a1,s4
    800016a2:	41250533          	sub	a0,a0,s2
    800016a6:	fffff097          	auipc	ra,0xfffff
    800016aa:	69a080e7          	jalr	1690(ra) # 80000d40 <memmove>

    len -= n;
    800016ae:	409989b3          	sub	s3,s3,s1
    src += n;
    800016b2:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016b4:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016b8:	02098263          	beqz	s3,800016dc <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016bc:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016c0:	85ca                	mv	a1,s2
    800016c2:	855a                	mv	a0,s6
    800016c4:	00000097          	auipc	ra,0x0
    800016c8:	9aa080e7          	jalr	-1622(ra) # 8000106e <walkaddr>
    if(pa0 == 0)
    800016cc:	cd01                	beqz	a0,800016e4 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016ce:	418904b3          	sub	s1,s2,s8
    800016d2:	94d6                	add	s1,s1,s5
    if(n > len)
    800016d4:	fc99f3e3          	bgeu	s3,s1,8000169a <copyout+0x28>
    800016d8:	84ce                	mv	s1,s3
    800016da:	b7c1                	j	8000169a <copyout+0x28>
  }
  return 0;
    800016dc:	4501                	li	a0,0
    800016de:	a021                	j	800016e6 <copyout+0x74>
    800016e0:	4501                	li	a0,0
}
    800016e2:	8082                	ret
      return -1;
    800016e4:	557d                	li	a0,-1
}
    800016e6:	60a6                	ld	ra,72(sp)
    800016e8:	6406                	ld	s0,64(sp)
    800016ea:	74e2                	ld	s1,56(sp)
    800016ec:	7942                	ld	s2,48(sp)
    800016ee:	79a2                	ld	s3,40(sp)
    800016f0:	7a02                	ld	s4,32(sp)
    800016f2:	6ae2                	ld	s5,24(sp)
    800016f4:	6b42                	ld	s6,16(sp)
    800016f6:	6ba2                	ld	s7,8(sp)
    800016f8:	6c02                	ld	s8,0(sp)
    800016fa:	6161                	addi	sp,sp,80
    800016fc:	8082                	ret

00000000800016fe <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016fe:	c6bd                	beqz	a3,8000176c <copyin+0x6e>
{
    80001700:	715d                	addi	sp,sp,-80
    80001702:	e486                	sd	ra,72(sp)
    80001704:	e0a2                	sd	s0,64(sp)
    80001706:	fc26                	sd	s1,56(sp)
    80001708:	f84a                	sd	s2,48(sp)
    8000170a:	f44e                	sd	s3,40(sp)
    8000170c:	f052                	sd	s4,32(sp)
    8000170e:	ec56                	sd	s5,24(sp)
    80001710:	e85a                	sd	s6,16(sp)
    80001712:	e45e                	sd	s7,8(sp)
    80001714:	e062                	sd	s8,0(sp)
    80001716:	0880                	addi	s0,sp,80
    80001718:	8b2a                	mv	s6,a0
    8000171a:	8a2e                	mv	s4,a1
    8000171c:	8c32                	mv	s8,a2
    8000171e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001720:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001722:	6a85                	lui	s5,0x1
    80001724:	a015                	j	80001748 <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001726:	9562                	add	a0,a0,s8
    80001728:	0004861b          	sext.w	a2,s1
    8000172c:	412505b3          	sub	a1,a0,s2
    80001730:	8552                	mv	a0,s4
    80001732:	fffff097          	auipc	ra,0xfffff
    80001736:	60e080e7          	jalr	1550(ra) # 80000d40 <memmove>

    len -= n;
    8000173a:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000173e:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001740:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001744:	02098263          	beqz	s3,80001768 <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    80001748:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000174c:	85ca                	mv	a1,s2
    8000174e:	855a                	mv	a0,s6
    80001750:	00000097          	auipc	ra,0x0
    80001754:	91e080e7          	jalr	-1762(ra) # 8000106e <walkaddr>
    if(pa0 == 0)
    80001758:	cd01                	beqz	a0,80001770 <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    8000175a:	418904b3          	sub	s1,s2,s8
    8000175e:	94d6                	add	s1,s1,s5
    if(n > len)
    80001760:	fc99f3e3          	bgeu	s3,s1,80001726 <copyin+0x28>
    80001764:	84ce                	mv	s1,s3
    80001766:	b7c1                	j	80001726 <copyin+0x28>
  }
  return 0;
    80001768:	4501                	li	a0,0
    8000176a:	a021                	j	80001772 <copyin+0x74>
    8000176c:	4501                	li	a0,0
}
    8000176e:	8082                	ret
      return -1;
    80001770:	557d                	li	a0,-1
}
    80001772:	60a6                	ld	ra,72(sp)
    80001774:	6406                	ld	s0,64(sp)
    80001776:	74e2                	ld	s1,56(sp)
    80001778:	7942                	ld	s2,48(sp)
    8000177a:	79a2                	ld	s3,40(sp)
    8000177c:	7a02                	ld	s4,32(sp)
    8000177e:	6ae2                	ld	s5,24(sp)
    80001780:	6b42                	ld	s6,16(sp)
    80001782:	6ba2                	ld	s7,8(sp)
    80001784:	6c02                	ld	s8,0(sp)
    80001786:	6161                	addi	sp,sp,80
    80001788:	8082                	ret

000000008000178a <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000178a:	c6c5                	beqz	a3,80001832 <copyinstr+0xa8>
{
    8000178c:	715d                	addi	sp,sp,-80
    8000178e:	e486                	sd	ra,72(sp)
    80001790:	e0a2                	sd	s0,64(sp)
    80001792:	fc26                	sd	s1,56(sp)
    80001794:	f84a                	sd	s2,48(sp)
    80001796:	f44e                	sd	s3,40(sp)
    80001798:	f052                	sd	s4,32(sp)
    8000179a:	ec56                	sd	s5,24(sp)
    8000179c:	e85a                	sd	s6,16(sp)
    8000179e:	e45e                	sd	s7,8(sp)
    800017a0:	0880                	addi	s0,sp,80
    800017a2:	8a2a                	mv	s4,a0
    800017a4:	8b2e                	mv	s6,a1
    800017a6:	8bb2                	mv	s7,a2
    800017a8:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017aa:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017ac:	6985                	lui	s3,0x1
    800017ae:	a035                	j	800017da <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017b0:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017b4:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017b6:	0017b793          	seqz	a5,a5
    800017ba:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017be:	60a6                	ld	ra,72(sp)
    800017c0:	6406                	ld	s0,64(sp)
    800017c2:	74e2                	ld	s1,56(sp)
    800017c4:	7942                	ld	s2,48(sp)
    800017c6:	79a2                	ld	s3,40(sp)
    800017c8:	7a02                	ld	s4,32(sp)
    800017ca:	6ae2                	ld	s5,24(sp)
    800017cc:	6b42                	ld	s6,16(sp)
    800017ce:	6ba2                	ld	s7,8(sp)
    800017d0:	6161                	addi	sp,sp,80
    800017d2:	8082                	ret
    srcva = va0 + PGSIZE;
    800017d4:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017d8:	c8a9                	beqz	s1,8000182a <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017da:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017de:	85ca                	mv	a1,s2
    800017e0:	8552                	mv	a0,s4
    800017e2:	00000097          	auipc	ra,0x0
    800017e6:	88c080e7          	jalr	-1908(ra) # 8000106e <walkaddr>
    if(pa0 == 0)
    800017ea:	c131                	beqz	a0,8000182e <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017ec:	41790833          	sub	a6,s2,s7
    800017f0:	984e                	add	a6,a6,s3
    if(n > max)
    800017f2:	0104f363          	bgeu	s1,a6,800017f8 <copyinstr+0x6e>
    800017f6:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017f8:	955e                	add	a0,a0,s7
    800017fa:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017fe:	fc080be3          	beqz	a6,800017d4 <copyinstr+0x4a>
    80001802:	985a                	add	a6,a6,s6
    80001804:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001806:	41650633          	sub	a2,a0,s6
    8000180a:	14fd                	addi	s1,s1,-1
    8000180c:	9b26                	add	s6,s6,s1
    8000180e:	00f60733          	add	a4,a2,a5
    80001812:	00074703          	lbu	a4,0(a4)
    80001816:	df49                	beqz	a4,800017b0 <copyinstr+0x26>
        *dst = *p;
    80001818:	00e78023          	sb	a4,0(a5)
      --max;
    8000181c:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001820:	0785                	addi	a5,a5,1
    while(n > 0){
    80001822:	ff0796e3          	bne	a5,a6,8000180e <copyinstr+0x84>
      dst++;
    80001826:	8b42                	mv	s6,a6
    80001828:	b775                	j	800017d4 <copyinstr+0x4a>
    8000182a:	4781                	li	a5,0
    8000182c:	b769                	j	800017b6 <copyinstr+0x2c>
      return -1;
    8000182e:	557d                	li	a0,-1
    80001830:	b779                	j	800017be <copyinstr+0x34>
  int got_null = 0;
    80001832:	4781                	li	a5,0
  if(got_null){
    80001834:	0017b793          	seqz	a5,a5
    80001838:	40f00533          	neg	a0,a5
}
    8000183c:	8082                	ret

000000008000183e <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    8000183e:	7139                	addi	sp,sp,-64
    80001840:	fc06                	sd	ra,56(sp)
    80001842:	f822                	sd	s0,48(sp)
    80001844:	f426                	sd	s1,40(sp)
    80001846:	f04a                	sd	s2,32(sp)
    80001848:	ec4e                	sd	s3,24(sp)
    8000184a:	e852                	sd	s4,16(sp)
    8000184c:	e456                	sd	s5,8(sp)
    8000184e:	e05a                	sd	s6,0(sp)
    80001850:	0080                	addi	s0,sp,64
    80001852:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001854:	00010497          	auipc	s1,0x10
    80001858:	e7c48493          	addi	s1,s1,-388 # 800116d0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000185c:	8b26                	mv	s6,s1
    8000185e:	00006a97          	auipc	s5,0x6
    80001862:	7a2a8a93          	addi	s5,s5,1954 # 80008000 <etext>
    80001866:	04000937          	lui	s2,0x4000
    8000186a:	197d                	addi	s2,s2,-1
    8000186c:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000186e:	00016a17          	auipc	s4,0x16
    80001872:	862a0a13          	addi	s4,s4,-1950 # 800170d0 <tickslock>
    char *pa = kalloc();
    80001876:	fffff097          	auipc	ra,0xfffff
    8000187a:	27e080e7          	jalr	638(ra) # 80000af4 <kalloc>
    8000187e:	862a                	mv	a2,a0
    if(pa == 0)
    80001880:	c131                	beqz	a0,800018c4 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001882:	416485b3          	sub	a1,s1,s6
    80001886:	858d                	srai	a1,a1,0x3
    80001888:	000ab783          	ld	a5,0(s5)
    8000188c:	02f585b3          	mul	a1,a1,a5
    80001890:	2585                	addiw	a1,a1,1
    80001892:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001896:	4719                	li	a4,6
    80001898:	6685                	lui	a3,0x1
    8000189a:	40b905b3          	sub	a1,s2,a1
    8000189e:	854e                	mv	a0,s3
    800018a0:	00000097          	auipc	ra,0x0
    800018a4:	8b0080e7          	jalr	-1872(ra) # 80001150 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018a8:	16848493          	addi	s1,s1,360
    800018ac:	fd4495e3          	bne	s1,s4,80001876 <proc_mapstacks+0x38>
  }
}
    800018b0:	70e2                	ld	ra,56(sp)
    800018b2:	7442                	ld	s0,48(sp)
    800018b4:	74a2                	ld	s1,40(sp)
    800018b6:	7902                	ld	s2,32(sp)
    800018b8:	69e2                	ld	s3,24(sp)
    800018ba:	6a42                	ld	s4,16(sp)
    800018bc:	6aa2                	ld	s5,8(sp)
    800018be:	6b02                	ld	s6,0(sp)
    800018c0:	6121                	addi	sp,sp,64
    800018c2:	8082                	ret
      panic("kalloc");
    800018c4:	00007517          	auipc	a0,0x7
    800018c8:	91450513          	addi	a0,a0,-1772 # 800081d8 <digits+0x198>
    800018cc:	fffff097          	auipc	ra,0xfffff
    800018d0:	c72080e7          	jalr	-910(ra) # 8000053e <panic>

00000000800018d4 <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    800018d4:	7139                	addi	sp,sp,-64
    800018d6:	fc06                	sd	ra,56(sp)
    800018d8:	f822                	sd	s0,48(sp)
    800018da:	f426                	sd	s1,40(sp)
    800018dc:	f04a                	sd	s2,32(sp)
    800018de:	ec4e                	sd	s3,24(sp)
    800018e0:	e852                	sd	s4,16(sp)
    800018e2:	e456                	sd	s5,8(sp)
    800018e4:	e05a                	sd	s6,0(sp)
    800018e6:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018e8:	00007597          	auipc	a1,0x7
    800018ec:	8f858593          	addi	a1,a1,-1800 # 800081e0 <digits+0x1a0>
    800018f0:	00010517          	auipc	a0,0x10
    800018f4:	9b050513          	addi	a0,a0,-1616 # 800112a0 <pid_lock>
    800018f8:	fffff097          	auipc	ra,0xfffff
    800018fc:	25c080e7          	jalr	604(ra) # 80000b54 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001900:	00007597          	auipc	a1,0x7
    80001904:	8e858593          	addi	a1,a1,-1816 # 800081e8 <digits+0x1a8>
    80001908:	00010517          	auipc	a0,0x10
    8000190c:	9b050513          	addi	a0,a0,-1616 # 800112b8 <wait_lock>
    80001910:	fffff097          	auipc	ra,0xfffff
    80001914:	244080e7          	jalr	580(ra) # 80000b54 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001918:	00010497          	auipc	s1,0x10
    8000191c:	db848493          	addi	s1,s1,-584 # 800116d0 <proc>
      initlock(&p->lock, "proc");
    80001920:	00007b17          	auipc	s6,0x7
    80001924:	8d8b0b13          	addi	s6,s6,-1832 # 800081f8 <digits+0x1b8>
      p->kstack = KSTACK((int) (p - proc));
    80001928:	8aa6                	mv	s5,s1
    8000192a:	00006a17          	auipc	s4,0x6
    8000192e:	6d6a0a13          	addi	s4,s4,1750 # 80008000 <etext>
    80001932:	04000937          	lui	s2,0x4000
    80001936:	197d                	addi	s2,s2,-1
    80001938:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000193a:	00015997          	auipc	s3,0x15
    8000193e:	79698993          	addi	s3,s3,1942 # 800170d0 <tickslock>
      initlock(&p->lock, "proc");
    80001942:	85da                	mv	a1,s6
    80001944:	8526                	mv	a0,s1
    80001946:	fffff097          	auipc	ra,0xfffff
    8000194a:	20e080e7          	jalr	526(ra) # 80000b54 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    8000194e:	415487b3          	sub	a5,s1,s5
    80001952:	878d                	srai	a5,a5,0x3
    80001954:	000a3703          	ld	a4,0(s4)
    80001958:	02e787b3          	mul	a5,a5,a4
    8000195c:	2785                	addiw	a5,a5,1
    8000195e:	00d7979b          	slliw	a5,a5,0xd
    80001962:	40f907b3          	sub	a5,s2,a5
    80001966:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001968:	16848493          	addi	s1,s1,360
    8000196c:	fd349be3          	bne	s1,s3,80001942 <procinit+0x6e>
  }
}
    80001970:	70e2                	ld	ra,56(sp)
    80001972:	7442                	ld	s0,48(sp)
    80001974:	74a2                	ld	s1,40(sp)
    80001976:	7902                	ld	s2,32(sp)
    80001978:	69e2                	ld	s3,24(sp)
    8000197a:	6a42                	ld	s4,16(sp)
    8000197c:	6aa2                	ld	s5,8(sp)
    8000197e:	6b02                	ld	s6,0(sp)
    80001980:	6121                	addi	sp,sp,64
    80001982:	8082                	ret

0000000080001984 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001984:	1141                	addi	sp,sp,-16
    80001986:	e422                	sd	s0,8(sp)
    80001988:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    8000198a:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    8000198c:	2501                	sext.w	a0,a0
    8000198e:	6422                	ld	s0,8(sp)
    80001990:	0141                	addi	sp,sp,16
    80001992:	8082                	ret

0000000080001994 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    80001994:	1141                	addi	sp,sp,-16
    80001996:	e422                	sd	s0,8(sp)
    80001998:	0800                	addi	s0,sp,16
    8000199a:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    8000199c:	2781                	sext.w	a5,a5
    8000199e:	079e                	slli	a5,a5,0x7
  return c;
}
    800019a0:	00010517          	auipc	a0,0x10
    800019a4:	93050513          	addi	a0,a0,-1744 # 800112d0 <cpus>
    800019a8:	953e                	add	a0,a0,a5
    800019aa:	6422                	ld	s0,8(sp)
    800019ac:	0141                	addi	sp,sp,16
    800019ae:	8082                	ret

00000000800019b0 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    800019b0:	1101                	addi	sp,sp,-32
    800019b2:	ec06                	sd	ra,24(sp)
    800019b4:	e822                	sd	s0,16(sp)
    800019b6:	e426                	sd	s1,8(sp)
    800019b8:	1000                	addi	s0,sp,32
  push_off();
    800019ba:	fffff097          	auipc	ra,0xfffff
    800019be:	1de080e7          	jalr	478(ra) # 80000b98 <push_off>
    800019c2:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019c4:	2781                	sext.w	a5,a5
    800019c6:	079e                	slli	a5,a5,0x7
    800019c8:	00010717          	auipc	a4,0x10
    800019cc:	8d870713          	addi	a4,a4,-1832 # 800112a0 <pid_lock>
    800019d0:	97ba                	add	a5,a5,a4
    800019d2:	7b84                	ld	s1,48(a5)
  pop_off();
    800019d4:	fffff097          	auipc	ra,0xfffff
    800019d8:	264080e7          	jalr	612(ra) # 80000c38 <pop_off>
  return p;
}
    800019dc:	8526                	mv	a0,s1
    800019de:	60e2                	ld	ra,24(sp)
    800019e0:	6442                	ld	s0,16(sp)
    800019e2:	64a2                	ld	s1,8(sp)
    800019e4:	6105                	addi	sp,sp,32
    800019e6:	8082                	ret

00000000800019e8 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019e8:	1141                	addi	sp,sp,-16
    800019ea:	e406                	sd	ra,8(sp)
    800019ec:	e022                	sd	s0,0(sp)
    800019ee:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019f0:	00000097          	auipc	ra,0x0
    800019f4:	fc0080e7          	jalr	-64(ra) # 800019b0 <myproc>
    800019f8:	fffff097          	auipc	ra,0xfffff
    800019fc:	2a0080e7          	jalr	672(ra) # 80000c98 <release>

  if (first) {
    80001a00:	00007797          	auipc	a5,0x7
    80001a04:	e807a783          	lw	a5,-384(a5) # 80008880 <first.1677>
    80001a08:	eb89                	bnez	a5,80001a1a <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a0a:	00001097          	auipc	ra,0x1
    80001a0e:	ef8080e7          	jalr	-264(ra) # 80002902 <usertrapret>
}
    80001a12:	60a2                	ld	ra,8(sp)
    80001a14:	6402                	ld	s0,0(sp)
    80001a16:	0141                	addi	sp,sp,16
    80001a18:	8082                	ret
    first = 0;
    80001a1a:	00007797          	auipc	a5,0x7
    80001a1e:	e607a323          	sw	zero,-410(a5) # 80008880 <first.1677>
    fsinit(ROOTDEV);
    80001a22:	4505                	li	a0,1
    80001a24:	00002097          	auipc	ra,0x2
    80001a28:	d22080e7          	jalr	-734(ra) # 80003746 <fsinit>
    80001a2c:	bff9                	j	80001a0a <forkret+0x22>

0000000080001a2e <allocpid>:
allocpid() {
    80001a2e:	1101                	addi	sp,sp,-32
    80001a30:	ec06                	sd	ra,24(sp)
    80001a32:	e822                	sd	s0,16(sp)
    80001a34:	e426                	sd	s1,8(sp)
    80001a36:	e04a                	sd	s2,0(sp)
    80001a38:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a3a:	00010917          	auipc	s2,0x10
    80001a3e:	86690913          	addi	s2,s2,-1946 # 800112a0 <pid_lock>
    80001a42:	854a                	mv	a0,s2
    80001a44:	fffff097          	auipc	ra,0xfffff
    80001a48:	1a0080e7          	jalr	416(ra) # 80000be4 <acquire>
  pid = nextpid;
    80001a4c:	00007797          	auipc	a5,0x7
    80001a50:	e3878793          	addi	a5,a5,-456 # 80008884 <nextpid>
    80001a54:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a56:	0014871b          	addiw	a4,s1,1
    80001a5a:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a5c:	854a                	mv	a0,s2
    80001a5e:	fffff097          	auipc	ra,0xfffff
    80001a62:	23a080e7          	jalr	570(ra) # 80000c98 <release>
}
    80001a66:	8526                	mv	a0,s1
    80001a68:	60e2                	ld	ra,24(sp)
    80001a6a:	6442                	ld	s0,16(sp)
    80001a6c:	64a2                	ld	s1,8(sp)
    80001a6e:	6902                	ld	s2,0(sp)
    80001a70:	6105                	addi	sp,sp,32
    80001a72:	8082                	ret

0000000080001a74 <proc_pagetable>:
{
    80001a74:	1101                	addi	sp,sp,-32
    80001a76:	ec06                	sd	ra,24(sp)
    80001a78:	e822                	sd	s0,16(sp)
    80001a7a:	e426                	sd	s1,8(sp)
    80001a7c:	e04a                	sd	s2,0(sp)
    80001a7e:	1000                	addi	s0,sp,32
    80001a80:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a82:	00000097          	auipc	ra,0x0
    80001a86:	8b8080e7          	jalr	-1864(ra) # 8000133a <uvmcreate>
    80001a8a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a8c:	c121                	beqz	a0,80001acc <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a8e:	4729                	li	a4,10
    80001a90:	00005697          	auipc	a3,0x5
    80001a94:	57068693          	addi	a3,a3,1392 # 80007000 <_trampoline>
    80001a98:	6605                	lui	a2,0x1
    80001a9a:	040005b7          	lui	a1,0x4000
    80001a9e:	15fd                	addi	a1,a1,-1
    80001aa0:	05b2                	slli	a1,a1,0xc
    80001aa2:	fffff097          	auipc	ra,0xfffff
    80001aa6:	60e080e7          	jalr	1550(ra) # 800010b0 <mappages>
    80001aaa:	02054863          	bltz	a0,80001ada <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001aae:	4719                	li	a4,6
    80001ab0:	05893683          	ld	a3,88(s2)
    80001ab4:	6605                	lui	a2,0x1
    80001ab6:	020005b7          	lui	a1,0x2000
    80001aba:	15fd                	addi	a1,a1,-1
    80001abc:	05b6                	slli	a1,a1,0xd
    80001abe:	8526                	mv	a0,s1
    80001ac0:	fffff097          	auipc	ra,0xfffff
    80001ac4:	5f0080e7          	jalr	1520(ra) # 800010b0 <mappages>
    80001ac8:	02054163          	bltz	a0,80001aea <proc_pagetable+0x76>
}
    80001acc:	8526                	mv	a0,s1
    80001ace:	60e2                	ld	ra,24(sp)
    80001ad0:	6442                	ld	s0,16(sp)
    80001ad2:	64a2                	ld	s1,8(sp)
    80001ad4:	6902                	ld	s2,0(sp)
    80001ad6:	6105                	addi	sp,sp,32
    80001ad8:	8082                	ret
    uvmfree(pagetable, 0);
    80001ada:	4581                	li	a1,0
    80001adc:	8526                	mv	a0,s1
    80001ade:	00000097          	auipc	ra,0x0
    80001ae2:	a58080e7          	jalr	-1448(ra) # 80001536 <uvmfree>
    return 0;
    80001ae6:	4481                	li	s1,0
    80001ae8:	b7d5                	j	80001acc <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001aea:	4681                	li	a3,0
    80001aec:	4605                	li	a2,1
    80001aee:	040005b7          	lui	a1,0x4000
    80001af2:	15fd                	addi	a1,a1,-1
    80001af4:	05b2                	slli	a1,a1,0xc
    80001af6:	8526                	mv	a0,s1
    80001af8:	fffff097          	auipc	ra,0xfffff
    80001afc:	77e080e7          	jalr	1918(ra) # 80001276 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b00:	4581                	li	a1,0
    80001b02:	8526                	mv	a0,s1
    80001b04:	00000097          	auipc	ra,0x0
    80001b08:	a32080e7          	jalr	-1486(ra) # 80001536 <uvmfree>
    return 0;
    80001b0c:	4481                	li	s1,0
    80001b0e:	bf7d                	j	80001acc <proc_pagetable+0x58>

0000000080001b10 <proc_freepagetable>:
{
    80001b10:	1101                	addi	sp,sp,-32
    80001b12:	ec06                	sd	ra,24(sp)
    80001b14:	e822                	sd	s0,16(sp)
    80001b16:	e426                	sd	s1,8(sp)
    80001b18:	e04a                	sd	s2,0(sp)
    80001b1a:	1000                	addi	s0,sp,32
    80001b1c:	84aa                	mv	s1,a0
    80001b1e:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b20:	4681                	li	a3,0
    80001b22:	4605                	li	a2,1
    80001b24:	040005b7          	lui	a1,0x4000
    80001b28:	15fd                	addi	a1,a1,-1
    80001b2a:	05b2                	slli	a1,a1,0xc
    80001b2c:	fffff097          	auipc	ra,0xfffff
    80001b30:	74a080e7          	jalr	1866(ra) # 80001276 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b34:	4681                	li	a3,0
    80001b36:	4605                	li	a2,1
    80001b38:	020005b7          	lui	a1,0x2000
    80001b3c:	15fd                	addi	a1,a1,-1
    80001b3e:	05b6                	slli	a1,a1,0xd
    80001b40:	8526                	mv	a0,s1
    80001b42:	fffff097          	auipc	ra,0xfffff
    80001b46:	734080e7          	jalr	1844(ra) # 80001276 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b4a:	85ca                	mv	a1,s2
    80001b4c:	8526                	mv	a0,s1
    80001b4e:	00000097          	auipc	ra,0x0
    80001b52:	9e8080e7          	jalr	-1560(ra) # 80001536 <uvmfree>
}
    80001b56:	60e2                	ld	ra,24(sp)
    80001b58:	6442                	ld	s0,16(sp)
    80001b5a:	64a2                	ld	s1,8(sp)
    80001b5c:	6902                	ld	s2,0(sp)
    80001b5e:	6105                	addi	sp,sp,32
    80001b60:	8082                	ret

0000000080001b62 <freeproc>:
{
    80001b62:	1101                	addi	sp,sp,-32
    80001b64:	ec06                	sd	ra,24(sp)
    80001b66:	e822                	sd	s0,16(sp)
    80001b68:	e426                	sd	s1,8(sp)
    80001b6a:	1000                	addi	s0,sp,32
    80001b6c:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b6e:	6d28                	ld	a0,88(a0)
    80001b70:	c509                	beqz	a0,80001b7a <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b72:	fffff097          	auipc	ra,0xfffff
    80001b76:	e86080e7          	jalr	-378(ra) # 800009f8 <kfree>
  p->trapframe = 0;
    80001b7a:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b7e:	68a8                	ld	a0,80(s1)
    80001b80:	c511                	beqz	a0,80001b8c <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b82:	64ac                	ld	a1,72(s1)
    80001b84:	00000097          	auipc	ra,0x0
    80001b88:	f8c080e7          	jalr	-116(ra) # 80001b10 <proc_freepagetable>
  p->pagetable = 0;
    80001b8c:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b90:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b94:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b98:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001b9c:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001ba0:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001ba4:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001ba8:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bac:	0004ac23          	sw	zero,24(s1)
}
    80001bb0:	60e2                	ld	ra,24(sp)
    80001bb2:	6442                	ld	s0,16(sp)
    80001bb4:	64a2                	ld	s1,8(sp)
    80001bb6:	6105                	addi	sp,sp,32
    80001bb8:	8082                	ret

0000000080001bba <allocproc>:
{
    80001bba:	1101                	addi	sp,sp,-32
    80001bbc:	ec06                	sd	ra,24(sp)
    80001bbe:	e822                	sd	s0,16(sp)
    80001bc0:	e426                	sd	s1,8(sp)
    80001bc2:	e04a                	sd	s2,0(sp)
    80001bc4:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bc6:	00010497          	auipc	s1,0x10
    80001bca:	b0a48493          	addi	s1,s1,-1270 # 800116d0 <proc>
    80001bce:	00015917          	auipc	s2,0x15
    80001bd2:	50290913          	addi	s2,s2,1282 # 800170d0 <tickslock>
    acquire(&p->lock);
    80001bd6:	8526                	mv	a0,s1
    80001bd8:	fffff097          	auipc	ra,0xfffff
    80001bdc:	00c080e7          	jalr	12(ra) # 80000be4 <acquire>
    if(p->state == UNUSED) {
    80001be0:	4c9c                	lw	a5,24(s1)
    80001be2:	cf81                	beqz	a5,80001bfa <allocproc+0x40>
      release(&p->lock);
    80001be4:	8526                	mv	a0,s1
    80001be6:	fffff097          	auipc	ra,0xfffff
    80001bea:	0b2080e7          	jalr	178(ra) # 80000c98 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bee:	16848493          	addi	s1,s1,360
    80001bf2:	ff2492e3          	bne	s1,s2,80001bd6 <allocproc+0x1c>
  return 0;
    80001bf6:	4481                	li	s1,0
    80001bf8:	a889                	j	80001c4a <allocproc+0x90>
  p->pid = allocpid();
    80001bfa:	00000097          	auipc	ra,0x0
    80001bfe:	e34080e7          	jalr	-460(ra) # 80001a2e <allocpid>
    80001c02:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c04:	4785                	li	a5,1
    80001c06:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c08:	fffff097          	auipc	ra,0xfffff
    80001c0c:	eec080e7          	jalr	-276(ra) # 80000af4 <kalloc>
    80001c10:	892a                	mv	s2,a0
    80001c12:	eca8                	sd	a0,88(s1)
    80001c14:	c131                	beqz	a0,80001c58 <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001c16:	8526                	mv	a0,s1
    80001c18:	00000097          	auipc	ra,0x0
    80001c1c:	e5c080e7          	jalr	-420(ra) # 80001a74 <proc_pagetable>
    80001c20:	892a                	mv	s2,a0
    80001c22:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c24:	c531                	beqz	a0,80001c70 <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001c26:	07000613          	li	a2,112
    80001c2a:	4581                	li	a1,0
    80001c2c:	06048513          	addi	a0,s1,96
    80001c30:	fffff097          	auipc	ra,0xfffff
    80001c34:	0b0080e7          	jalr	176(ra) # 80000ce0 <memset>
  p->context.ra = (uint64)forkret;
    80001c38:	00000797          	auipc	a5,0x0
    80001c3c:	db078793          	addi	a5,a5,-592 # 800019e8 <forkret>
    80001c40:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c42:	60bc                	ld	a5,64(s1)
    80001c44:	6705                	lui	a4,0x1
    80001c46:	97ba                	add	a5,a5,a4
    80001c48:	f4bc                	sd	a5,104(s1)
}
    80001c4a:	8526                	mv	a0,s1
    80001c4c:	60e2                	ld	ra,24(sp)
    80001c4e:	6442                	ld	s0,16(sp)
    80001c50:	64a2                	ld	s1,8(sp)
    80001c52:	6902                	ld	s2,0(sp)
    80001c54:	6105                	addi	sp,sp,32
    80001c56:	8082                	ret
    freeproc(p);
    80001c58:	8526                	mv	a0,s1
    80001c5a:	00000097          	auipc	ra,0x0
    80001c5e:	f08080e7          	jalr	-248(ra) # 80001b62 <freeproc>
    release(&p->lock);
    80001c62:	8526                	mv	a0,s1
    80001c64:	fffff097          	auipc	ra,0xfffff
    80001c68:	034080e7          	jalr	52(ra) # 80000c98 <release>
    return 0;
    80001c6c:	84ca                	mv	s1,s2
    80001c6e:	bff1                	j	80001c4a <allocproc+0x90>
    freeproc(p);
    80001c70:	8526                	mv	a0,s1
    80001c72:	00000097          	auipc	ra,0x0
    80001c76:	ef0080e7          	jalr	-272(ra) # 80001b62 <freeproc>
    release(&p->lock);
    80001c7a:	8526                	mv	a0,s1
    80001c7c:	fffff097          	auipc	ra,0xfffff
    80001c80:	01c080e7          	jalr	28(ra) # 80000c98 <release>
    return 0;
    80001c84:	84ca                	mv	s1,s2
    80001c86:	b7d1                	j	80001c4a <allocproc+0x90>

0000000080001c88 <userinit>:
{
    80001c88:	1101                	addi	sp,sp,-32
    80001c8a:	ec06                	sd	ra,24(sp)
    80001c8c:	e822                	sd	s0,16(sp)
    80001c8e:	e426                	sd	s1,8(sp)
    80001c90:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c92:	00000097          	auipc	ra,0x0
    80001c96:	f28080e7          	jalr	-216(ra) # 80001bba <allocproc>
    80001c9a:	84aa                	mv	s1,a0
  initproc = p;
    80001c9c:	00007797          	auipc	a5,0x7
    80001ca0:	38a7b623          	sd	a0,908(a5) # 80009028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001ca4:	03400613          	li	a2,52
    80001ca8:	00007597          	auipc	a1,0x7
    80001cac:	be858593          	addi	a1,a1,-1048 # 80008890 <initcode>
    80001cb0:	6928                	ld	a0,80(a0)
    80001cb2:	fffff097          	auipc	ra,0xfffff
    80001cb6:	6b6080e7          	jalr	1718(ra) # 80001368 <uvminit>
  p->sz = PGSIZE;
    80001cba:	6785                	lui	a5,0x1
    80001cbc:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cbe:	6cb8                	ld	a4,88(s1)
    80001cc0:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001cc4:	6cb8                	ld	a4,88(s1)
    80001cc6:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001cc8:	4641                	li	a2,16
    80001cca:	00006597          	auipc	a1,0x6
    80001cce:	53658593          	addi	a1,a1,1334 # 80008200 <digits+0x1c0>
    80001cd2:	15848513          	addi	a0,s1,344
    80001cd6:	fffff097          	auipc	ra,0xfffff
    80001cda:	15c080e7          	jalr	348(ra) # 80000e32 <safestrcpy>
  p->cwd = namei("/");
    80001cde:	00006517          	auipc	a0,0x6
    80001ce2:	53250513          	addi	a0,a0,1330 # 80008210 <digits+0x1d0>
    80001ce6:	00002097          	auipc	ra,0x2
    80001cea:	48e080e7          	jalr	1166(ra) # 80004174 <namei>
    80001cee:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001cf2:	478d                	li	a5,3
    80001cf4:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001cf6:	8526                	mv	a0,s1
    80001cf8:	fffff097          	auipc	ra,0xfffff
    80001cfc:	fa0080e7          	jalr	-96(ra) # 80000c98 <release>
}
    80001d00:	60e2                	ld	ra,24(sp)
    80001d02:	6442                	ld	s0,16(sp)
    80001d04:	64a2                	ld	s1,8(sp)
    80001d06:	6105                	addi	sp,sp,32
    80001d08:	8082                	ret

0000000080001d0a <growproc>:
{
    80001d0a:	1101                	addi	sp,sp,-32
    80001d0c:	ec06                	sd	ra,24(sp)
    80001d0e:	e822                	sd	s0,16(sp)
    80001d10:	e426                	sd	s1,8(sp)
    80001d12:	e04a                	sd	s2,0(sp)
    80001d14:	1000                	addi	s0,sp,32
    80001d16:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d18:	00000097          	auipc	ra,0x0
    80001d1c:	c98080e7          	jalr	-872(ra) # 800019b0 <myproc>
    80001d20:	892a                	mv	s2,a0
  sz = p->sz;
    80001d22:	652c                	ld	a1,72(a0)
    80001d24:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001d28:	00904f63          	bgtz	s1,80001d46 <growproc+0x3c>
  } else if(n < 0){
    80001d2c:	0204cc63          	bltz	s1,80001d64 <growproc+0x5a>
  p->sz = sz;
    80001d30:	1602                	slli	a2,a2,0x20
    80001d32:	9201                	srli	a2,a2,0x20
    80001d34:	04c93423          	sd	a2,72(s2)
  return 0;
    80001d38:	4501                	li	a0,0
}
    80001d3a:	60e2                	ld	ra,24(sp)
    80001d3c:	6442                	ld	s0,16(sp)
    80001d3e:	64a2                	ld	s1,8(sp)
    80001d40:	6902                	ld	s2,0(sp)
    80001d42:	6105                	addi	sp,sp,32
    80001d44:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001d46:	9e25                	addw	a2,a2,s1
    80001d48:	1602                	slli	a2,a2,0x20
    80001d4a:	9201                	srli	a2,a2,0x20
    80001d4c:	1582                	slli	a1,a1,0x20
    80001d4e:	9181                	srli	a1,a1,0x20
    80001d50:	6928                	ld	a0,80(a0)
    80001d52:	fffff097          	auipc	ra,0xfffff
    80001d56:	6d0080e7          	jalr	1744(ra) # 80001422 <uvmalloc>
    80001d5a:	0005061b          	sext.w	a2,a0
    80001d5e:	fa69                	bnez	a2,80001d30 <growproc+0x26>
      return -1;
    80001d60:	557d                	li	a0,-1
    80001d62:	bfe1                	j	80001d3a <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d64:	9e25                	addw	a2,a2,s1
    80001d66:	1602                	slli	a2,a2,0x20
    80001d68:	9201                	srli	a2,a2,0x20
    80001d6a:	1582                	slli	a1,a1,0x20
    80001d6c:	9181                	srli	a1,a1,0x20
    80001d6e:	6928                	ld	a0,80(a0)
    80001d70:	fffff097          	auipc	ra,0xfffff
    80001d74:	66a080e7          	jalr	1642(ra) # 800013da <uvmdealloc>
    80001d78:	0005061b          	sext.w	a2,a0
    80001d7c:	bf55                	j	80001d30 <growproc+0x26>

0000000080001d7e <fork>:
{
    80001d7e:	7179                	addi	sp,sp,-48
    80001d80:	f406                	sd	ra,40(sp)
    80001d82:	f022                	sd	s0,32(sp)
    80001d84:	ec26                	sd	s1,24(sp)
    80001d86:	e84a                	sd	s2,16(sp)
    80001d88:	e44e                	sd	s3,8(sp)
    80001d8a:	e052                	sd	s4,0(sp)
    80001d8c:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001d8e:	00000097          	auipc	ra,0x0
    80001d92:	c22080e7          	jalr	-990(ra) # 800019b0 <myproc>
    80001d96:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001d98:	00000097          	auipc	ra,0x0
    80001d9c:	e22080e7          	jalr	-478(ra) # 80001bba <allocproc>
    80001da0:	10050b63          	beqz	a0,80001eb6 <fork+0x138>
    80001da4:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001da6:	04893603          	ld	a2,72(s2)
    80001daa:	692c                	ld	a1,80(a0)
    80001dac:	05093503          	ld	a0,80(s2)
    80001db0:	fffff097          	auipc	ra,0xfffff
    80001db4:	7be080e7          	jalr	1982(ra) # 8000156e <uvmcopy>
    80001db8:	04054663          	bltz	a0,80001e04 <fork+0x86>
  np->sz = p->sz;
    80001dbc:	04893783          	ld	a5,72(s2)
    80001dc0:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001dc4:	05893683          	ld	a3,88(s2)
    80001dc8:	87b6                	mv	a5,a3
    80001dca:	0589b703          	ld	a4,88(s3)
    80001dce:	12068693          	addi	a3,a3,288
    80001dd2:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001dd6:	6788                	ld	a0,8(a5)
    80001dd8:	6b8c                	ld	a1,16(a5)
    80001dda:	6f90                	ld	a2,24(a5)
    80001ddc:	01073023          	sd	a6,0(a4)
    80001de0:	e708                	sd	a0,8(a4)
    80001de2:	eb0c                	sd	a1,16(a4)
    80001de4:	ef10                	sd	a2,24(a4)
    80001de6:	02078793          	addi	a5,a5,32
    80001dea:	02070713          	addi	a4,a4,32
    80001dee:	fed792e3          	bne	a5,a3,80001dd2 <fork+0x54>
  np->trapframe->a0 = 0;
    80001df2:	0589b783          	ld	a5,88(s3)
    80001df6:	0607b823          	sd	zero,112(a5)
    80001dfa:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    80001dfe:	15000a13          	li	s4,336
    80001e02:	a03d                	j	80001e30 <fork+0xb2>
    freeproc(np);
    80001e04:	854e                	mv	a0,s3
    80001e06:	00000097          	auipc	ra,0x0
    80001e0a:	d5c080e7          	jalr	-676(ra) # 80001b62 <freeproc>
    release(&np->lock);
    80001e0e:	854e                	mv	a0,s3
    80001e10:	fffff097          	auipc	ra,0xfffff
    80001e14:	e88080e7          	jalr	-376(ra) # 80000c98 <release>
    return -1;
    80001e18:	5a7d                	li	s4,-1
    80001e1a:	a069                	j	80001ea4 <fork+0x126>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e1c:	00003097          	auipc	ra,0x3
    80001e20:	9ee080e7          	jalr	-1554(ra) # 8000480a <filedup>
    80001e24:	009987b3          	add	a5,s3,s1
    80001e28:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001e2a:	04a1                	addi	s1,s1,8
    80001e2c:	01448763          	beq	s1,s4,80001e3a <fork+0xbc>
    if(p->ofile[i])
    80001e30:	009907b3          	add	a5,s2,s1
    80001e34:	6388                	ld	a0,0(a5)
    80001e36:	f17d                	bnez	a0,80001e1c <fork+0x9e>
    80001e38:	bfcd                	j	80001e2a <fork+0xac>
  np->cwd = idup(p->cwd);
    80001e3a:	15093503          	ld	a0,336(s2)
    80001e3e:	00002097          	auipc	ra,0x2
    80001e42:	b42080e7          	jalr	-1214(ra) # 80003980 <idup>
    80001e46:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e4a:	4641                	li	a2,16
    80001e4c:	15890593          	addi	a1,s2,344
    80001e50:	15898513          	addi	a0,s3,344
    80001e54:	fffff097          	auipc	ra,0xfffff
    80001e58:	fde080e7          	jalr	-34(ra) # 80000e32 <safestrcpy>
  pid = np->pid;
    80001e5c:	0309aa03          	lw	s4,48(s3)
  release(&np->lock);
    80001e60:	854e                	mv	a0,s3
    80001e62:	fffff097          	auipc	ra,0xfffff
    80001e66:	e36080e7          	jalr	-458(ra) # 80000c98 <release>
  acquire(&wait_lock);
    80001e6a:	0000f497          	auipc	s1,0xf
    80001e6e:	44e48493          	addi	s1,s1,1102 # 800112b8 <wait_lock>
    80001e72:	8526                	mv	a0,s1
    80001e74:	fffff097          	auipc	ra,0xfffff
    80001e78:	d70080e7          	jalr	-656(ra) # 80000be4 <acquire>
  np->parent = p;
    80001e7c:	0329bc23          	sd	s2,56(s3)
  release(&wait_lock);
    80001e80:	8526                	mv	a0,s1
    80001e82:	fffff097          	auipc	ra,0xfffff
    80001e86:	e16080e7          	jalr	-490(ra) # 80000c98 <release>
  acquire(&np->lock);
    80001e8a:	854e                	mv	a0,s3
    80001e8c:	fffff097          	auipc	ra,0xfffff
    80001e90:	d58080e7          	jalr	-680(ra) # 80000be4 <acquire>
  np->state = RUNNABLE;
    80001e94:	478d                	li	a5,3
    80001e96:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001e9a:	854e                	mv	a0,s3
    80001e9c:	fffff097          	auipc	ra,0xfffff
    80001ea0:	dfc080e7          	jalr	-516(ra) # 80000c98 <release>
}
    80001ea4:	8552                	mv	a0,s4
    80001ea6:	70a2                	ld	ra,40(sp)
    80001ea8:	7402                	ld	s0,32(sp)
    80001eaa:	64e2                	ld	s1,24(sp)
    80001eac:	6942                	ld	s2,16(sp)
    80001eae:	69a2                	ld	s3,8(sp)
    80001eb0:	6a02                	ld	s4,0(sp)
    80001eb2:	6145                	addi	sp,sp,48
    80001eb4:	8082                	ret
    return -1;
    80001eb6:	5a7d                	li	s4,-1
    80001eb8:	b7f5                	j	80001ea4 <fork+0x126>

0000000080001eba <scheduler>:
{
    80001eba:	7139                	addi	sp,sp,-64
    80001ebc:	fc06                	sd	ra,56(sp)
    80001ebe:	f822                	sd	s0,48(sp)
    80001ec0:	f426                	sd	s1,40(sp)
    80001ec2:	f04a                	sd	s2,32(sp)
    80001ec4:	ec4e                	sd	s3,24(sp)
    80001ec6:	e852                	sd	s4,16(sp)
    80001ec8:	e456                	sd	s5,8(sp)
    80001eca:	e05a                	sd	s6,0(sp)
    80001ecc:	0080                	addi	s0,sp,64
    80001ece:	8792                	mv	a5,tp
  int id = r_tp();
    80001ed0:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001ed2:	00779a93          	slli	s5,a5,0x7
    80001ed6:	0000f717          	auipc	a4,0xf
    80001eda:	3ca70713          	addi	a4,a4,970 # 800112a0 <pid_lock>
    80001ede:	9756                	add	a4,a4,s5
    80001ee0:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001ee4:	0000f717          	auipc	a4,0xf
    80001ee8:	3f470713          	addi	a4,a4,1012 # 800112d8 <cpus+0x8>
    80001eec:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001eee:	498d                	li	s3,3
        p->state = RUNNING;
    80001ef0:	4b11                	li	s6,4
        c->proc = p;
    80001ef2:	079e                	slli	a5,a5,0x7
    80001ef4:	0000fa17          	auipc	s4,0xf
    80001ef8:	3aca0a13          	addi	s4,s4,940 # 800112a0 <pid_lock>
    80001efc:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001efe:	00015917          	auipc	s2,0x15
    80001f02:	1d290913          	addi	s2,s2,466 # 800170d0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f06:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f0a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f0e:	10079073          	csrw	sstatus,a5
    80001f12:	0000f497          	auipc	s1,0xf
    80001f16:	7be48493          	addi	s1,s1,1982 # 800116d0 <proc>
    80001f1a:	a03d                	j	80001f48 <scheduler+0x8e>
        p->state = RUNNING;
    80001f1c:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001f20:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001f24:	06048593          	addi	a1,s1,96
    80001f28:	8556                	mv	a0,s5
    80001f2a:	00001097          	auipc	ra,0x1
    80001f2e:	92e080e7          	jalr	-1746(ra) # 80002858 <swtch>
        c->proc = 0;
    80001f32:	020a3823          	sd	zero,48(s4)
      release(&p->lock);
    80001f36:	8526                	mv	a0,s1
    80001f38:	fffff097          	auipc	ra,0xfffff
    80001f3c:	d60080e7          	jalr	-672(ra) # 80000c98 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f40:	16848493          	addi	s1,s1,360
    80001f44:	fd2481e3          	beq	s1,s2,80001f06 <scheduler+0x4c>
      acquire(&p->lock);
    80001f48:	8526                	mv	a0,s1
    80001f4a:	fffff097          	auipc	ra,0xfffff
    80001f4e:	c9a080e7          	jalr	-870(ra) # 80000be4 <acquire>
      if(p->state == RUNNABLE) {
    80001f52:	4c9c                	lw	a5,24(s1)
    80001f54:	ff3791e3          	bne	a5,s3,80001f36 <scheduler+0x7c>
    80001f58:	b7d1                	j	80001f1c <scheduler+0x62>

0000000080001f5a <sched>:
{
    80001f5a:	7179                	addi	sp,sp,-48
    80001f5c:	f406                	sd	ra,40(sp)
    80001f5e:	f022                	sd	s0,32(sp)
    80001f60:	ec26                	sd	s1,24(sp)
    80001f62:	e84a                	sd	s2,16(sp)
    80001f64:	e44e                	sd	s3,8(sp)
    80001f66:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f68:	00000097          	auipc	ra,0x0
    80001f6c:	a48080e7          	jalr	-1464(ra) # 800019b0 <myproc>
    80001f70:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001f72:	fffff097          	auipc	ra,0xfffff
    80001f76:	bf8080e7          	jalr	-1032(ra) # 80000b6a <holding>
    80001f7a:	c93d                	beqz	a0,80001ff0 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f7c:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001f7e:	2781                	sext.w	a5,a5
    80001f80:	079e                	slli	a5,a5,0x7
    80001f82:	0000f717          	auipc	a4,0xf
    80001f86:	31e70713          	addi	a4,a4,798 # 800112a0 <pid_lock>
    80001f8a:	97ba                	add	a5,a5,a4
    80001f8c:	0a87a703          	lw	a4,168(a5)
    80001f90:	4785                	li	a5,1
    80001f92:	06f71763          	bne	a4,a5,80002000 <sched+0xa6>
  if(p->state == RUNNING)
    80001f96:	4c98                	lw	a4,24(s1)
    80001f98:	4791                	li	a5,4
    80001f9a:	06f70b63          	beq	a4,a5,80002010 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f9e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001fa2:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001fa4:	efb5                	bnez	a5,80002020 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001fa6:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001fa8:	0000f917          	auipc	s2,0xf
    80001fac:	2f890913          	addi	s2,s2,760 # 800112a0 <pid_lock>
    80001fb0:	2781                	sext.w	a5,a5
    80001fb2:	079e                	slli	a5,a5,0x7
    80001fb4:	97ca                	add	a5,a5,s2
    80001fb6:	0ac7a983          	lw	s3,172(a5)
    80001fba:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001fbc:	2781                	sext.w	a5,a5
    80001fbe:	079e                	slli	a5,a5,0x7
    80001fc0:	0000f597          	auipc	a1,0xf
    80001fc4:	31858593          	addi	a1,a1,792 # 800112d8 <cpus+0x8>
    80001fc8:	95be                	add	a1,a1,a5
    80001fca:	06048513          	addi	a0,s1,96
    80001fce:	00001097          	auipc	ra,0x1
    80001fd2:	88a080e7          	jalr	-1910(ra) # 80002858 <swtch>
    80001fd6:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001fd8:	2781                	sext.w	a5,a5
    80001fda:	079e                	slli	a5,a5,0x7
    80001fdc:	97ca                	add	a5,a5,s2
    80001fde:	0b37a623          	sw	s3,172(a5)
}
    80001fe2:	70a2                	ld	ra,40(sp)
    80001fe4:	7402                	ld	s0,32(sp)
    80001fe6:	64e2                	ld	s1,24(sp)
    80001fe8:	6942                	ld	s2,16(sp)
    80001fea:	69a2                	ld	s3,8(sp)
    80001fec:	6145                	addi	sp,sp,48
    80001fee:	8082                	ret
    panic("sched p->lock");
    80001ff0:	00006517          	auipc	a0,0x6
    80001ff4:	22850513          	addi	a0,a0,552 # 80008218 <digits+0x1d8>
    80001ff8:	ffffe097          	auipc	ra,0xffffe
    80001ffc:	546080e7          	jalr	1350(ra) # 8000053e <panic>
    panic("sched locks");
    80002000:	00006517          	auipc	a0,0x6
    80002004:	22850513          	addi	a0,a0,552 # 80008228 <digits+0x1e8>
    80002008:	ffffe097          	auipc	ra,0xffffe
    8000200c:	536080e7          	jalr	1334(ra) # 8000053e <panic>
    panic("sched running");
    80002010:	00006517          	auipc	a0,0x6
    80002014:	22850513          	addi	a0,a0,552 # 80008238 <digits+0x1f8>
    80002018:	ffffe097          	auipc	ra,0xffffe
    8000201c:	526080e7          	jalr	1318(ra) # 8000053e <panic>
    panic("sched interruptible");
    80002020:	00006517          	auipc	a0,0x6
    80002024:	22850513          	addi	a0,a0,552 # 80008248 <digits+0x208>
    80002028:	ffffe097          	auipc	ra,0xffffe
    8000202c:	516080e7          	jalr	1302(ra) # 8000053e <panic>

0000000080002030 <yield>:
{
    80002030:	1101                	addi	sp,sp,-32
    80002032:	ec06                	sd	ra,24(sp)
    80002034:	e822                	sd	s0,16(sp)
    80002036:	e426                	sd	s1,8(sp)
    80002038:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000203a:	00000097          	auipc	ra,0x0
    8000203e:	976080e7          	jalr	-1674(ra) # 800019b0 <myproc>
    80002042:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002044:	fffff097          	auipc	ra,0xfffff
    80002048:	ba0080e7          	jalr	-1120(ra) # 80000be4 <acquire>
  p->state = RUNNABLE;
    8000204c:	478d                	li	a5,3
    8000204e:	cc9c                	sw	a5,24(s1)
  sched();
    80002050:	00000097          	auipc	ra,0x0
    80002054:	f0a080e7          	jalr	-246(ra) # 80001f5a <sched>
  release(&p->lock);
    80002058:	8526                	mv	a0,s1
    8000205a:	fffff097          	auipc	ra,0xfffff
    8000205e:	c3e080e7          	jalr	-962(ra) # 80000c98 <release>
}
    80002062:	60e2                	ld	ra,24(sp)
    80002064:	6442                	ld	s0,16(sp)
    80002066:	64a2                	ld	s1,8(sp)
    80002068:	6105                	addi	sp,sp,32
    8000206a:	8082                	ret

000000008000206c <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000206c:	7179                	addi	sp,sp,-48
    8000206e:	f406                	sd	ra,40(sp)
    80002070:	f022                	sd	s0,32(sp)
    80002072:	ec26                	sd	s1,24(sp)
    80002074:	e84a                	sd	s2,16(sp)
    80002076:	e44e                	sd	s3,8(sp)
    80002078:	1800                	addi	s0,sp,48
    8000207a:	89aa                	mv	s3,a0
    8000207c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000207e:	00000097          	auipc	ra,0x0
    80002082:	932080e7          	jalr	-1742(ra) # 800019b0 <myproc>
    80002086:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002088:	fffff097          	auipc	ra,0xfffff
    8000208c:	b5c080e7          	jalr	-1188(ra) # 80000be4 <acquire>
  release(lk);
    80002090:	854a                	mv	a0,s2
    80002092:	fffff097          	auipc	ra,0xfffff
    80002096:	c06080e7          	jalr	-1018(ra) # 80000c98 <release>

  // Go to sleep.
  p->chan = chan;
    8000209a:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000209e:	4789                	li	a5,2
    800020a0:	cc9c                	sw	a5,24(s1)

  sched();
    800020a2:	00000097          	auipc	ra,0x0
    800020a6:	eb8080e7          	jalr	-328(ra) # 80001f5a <sched>

  // Tidy up.
  p->chan = 0;
    800020aa:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800020ae:	8526                	mv	a0,s1
    800020b0:	fffff097          	auipc	ra,0xfffff
    800020b4:	be8080e7          	jalr	-1048(ra) # 80000c98 <release>
  acquire(lk);
    800020b8:	854a                	mv	a0,s2
    800020ba:	fffff097          	auipc	ra,0xfffff
    800020be:	b2a080e7          	jalr	-1238(ra) # 80000be4 <acquire>
}
    800020c2:	70a2                	ld	ra,40(sp)
    800020c4:	7402                	ld	s0,32(sp)
    800020c6:	64e2                	ld	s1,24(sp)
    800020c8:	6942                	ld	s2,16(sp)
    800020ca:	69a2                	ld	s3,8(sp)
    800020cc:	6145                	addi	sp,sp,48
    800020ce:	8082                	ret

00000000800020d0 <wait>:
{
    800020d0:	715d                	addi	sp,sp,-80
    800020d2:	e486                	sd	ra,72(sp)
    800020d4:	e0a2                	sd	s0,64(sp)
    800020d6:	fc26                	sd	s1,56(sp)
    800020d8:	f84a                	sd	s2,48(sp)
    800020da:	f44e                	sd	s3,40(sp)
    800020dc:	f052                	sd	s4,32(sp)
    800020de:	ec56                	sd	s5,24(sp)
    800020e0:	e85a                	sd	s6,16(sp)
    800020e2:	e45e                	sd	s7,8(sp)
    800020e4:	e062                	sd	s8,0(sp)
    800020e6:	0880                	addi	s0,sp,80
    800020e8:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800020ea:	00000097          	auipc	ra,0x0
    800020ee:	8c6080e7          	jalr	-1850(ra) # 800019b0 <myproc>
    800020f2:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800020f4:	0000f517          	auipc	a0,0xf
    800020f8:	1c450513          	addi	a0,a0,452 # 800112b8 <wait_lock>
    800020fc:	fffff097          	auipc	ra,0xfffff
    80002100:	ae8080e7          	jalr	-1304(ra) # 80000be4 <acquire>
    havekids = 0;
    80002104:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002106:	4a15                	li	s4,5
    for(np = proc; np < &proc[NPROC]; np++){
    80002108:	00015997          	auipc	s3,0x15
    8000210c:	fc898993          	addi	s3,s3,-56 # 800170d0 <tickslock>
        havekids = 1;
    80002110:	4a85                	li	s5,1
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002112:	0000fc17          	auipc	s8,0xf
    80002116:	1a6c0c13          	addi	s8,s8,422 # 800112b8 <wait_lock>
    havekids = 0;
    8000211a:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    8000211c:	0000f497          	auipc	s1,0xf
    80002120:	5b448493          	addi	s1,s1,1460 # 800116d0 <proc>
    80002124:	a0bd                	j	80002192 <wait+0xc2>
          pid = np->pid;
    80002126:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000212a:	000b0e63          	beqz	s6,80002146 <wait+0x76>
    8000212e:	4691                	li	a3,4
    80002130:	02c48613          	addi	a2,s1,44
    80002134:	85da                	mv	a1,s6
    80002136:	05093503          	ld	a0,80(s2)
    8000213a:	fffff097          	auipc	ra,0xfffff
    8000213e:	538080e7          	jalr	1336(ra) # 80001672 <copyout>
    80002142:	02054563          	bltz	a0,8000216c <wait+0x9c>
          freeproc(np);
    80002146:	8526                	mv	a0,s1
    80002148:	00000097          	auipc	ra,0x0
    8000214c:	a1a080e7          	jalr	-1510(ra) # 80001b62 <freeproc>
          release(&np->lock);
    80002150:	8526                	mv	a0,s1
    80002152:	fffff097          	auipc	ra,0xfffff
    80002156:	b46080e7          	jalr	-1210(ra) # 80000c98 <release>
          release(&wait_lock);
    8000215a:	0000f517          	auipc	a0,0xf
    8000215e:	15e50513          	addi	a0,a0,350 # 800112b8 <wait_lock>
    80002162:	fffff097          	auipc	ra,0xfffff
    80002166:	b36080e7          	jalr	-1226(ra) # 80000c98 <release>
          return pid;
    8000216a:	a09d                	j	800021d0 <wait+0x100>
            release(&np->lock);
    8000216c:	8526                	mv	a0,s1
    8000216e:	fffff097          	auipc	ra,0xfffff
    80002172:	b2a080e7          	jalr	-1238(ra) # 80000c98 <release>
            release(&wait_lock);
    80002176:	0000f517          	auipc	a0,0xf
    8000217a:	14250513          	addi	a0,a0,322 # 800112b8 <wait_lock>
    8000217e:	fffff097          	auipc	ra,0xfffff
    80002182:	b1a080e7          	jalr	-1254(ra) # 80000c98 <release>
            return -1;
    80002186:	59fd                	li	s3,-1
    80002188:	a0a1                	j	800021d0 <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    8000218a:	16848493          	addi	s1,s1,360
    8000218e:	03348463          	beq	s1,s3,800021b6 <wait+0xe6>
      if(np->parent == p){
    80002192:	7c9c                	ld	a5,56(s1)
    80002194:	ff279be3          	bne	a5,s2,8000218a <wait+0xba>
        acquire(&np->lock);
    80002198:	8526                	mv	a0,s1
    8000219a:	fffff097          	auipc	ra,0xfffff
    8000219e:	a4a080e7          	jalr	-1462(ra) # 80000be4 <acquire>
        if(np->state == ZOMBIE){
    800021a2:	4c9c                	lw	a5,24(s1)
    800021a4:	f94781e3          	beq	a5,s4,80002126 <wait+0x56>
        release(&np->lock);
    800021a8:	8526                	mv	a0,s1
    800021aa:	fffff097          	auipc	ra,0xfffff
    800021ae:	aee080e7          	jalr	-1298(ra) # 80000c98 <release>
        havekids = 1;
    800021b2:	8756                	mv	a4,s5
    800021b4:	bfd9                	j	8000218a <wait+0xba>
    if(!havekids || p->killed){
    800021b6:	c701                	beqz	a4,800021be <wait+0xee>
    800021b8:	02892783          	lw	a5,40(s2)
    800021bc:	c79d                	beqz	a5,800021ea <wait+0x11a>
      release(&wait_lock);
    800021be:	0000f517          	auipc	a0,0xf
    800021c2:	0fa50513          	addi	a0,a0,250 # 800112b8 <wait_lock>
    800021c6:	fffff097          	auipc	ra,0xfffff
    800021ca:	ad2080e7          	jalr	-1326(ra) # 80000c98 <release>
      return -1;
    800021ce:	59fd                	li	s3,-1
}
    800021d0:	854e                	mv	a0,s3
    800021d2:	60a6                	ld	ra,72(sp)
    800021d4:	6406                	ld	s0,64(sp)
    800021d6:	74e2                	ld	s1,56(sp)
    800021d8:	7942                	ld	s2,48(sp)
    800021da:	79a2                	ld	s3,40(sp)
    800021dc:	7a02                	ld	s4,32(sp)
    800021de:	6ae2                	ld	s5,24(sp)
    800021e0:	6b42                	ld	s6,16(sp)
    800021e2:	6ba2                	ld	s7,8(sp)
    800021e4:	6c02                	ld	s8,0(sp)
    800021e6:	6161                	addi	sp,sp,80
    800021e8:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800021ea:	85e2                	mv	a1,s8
    800021ec:	854a                	mv	a0,s2
    800021ee:	00000097          	auipc	ra,0x0
    800021f2:	e7e080e7          	jalr	-386(ra) # 8000206c <sleep>
    havekids = 0;
    800021f6:	b715                	j	8000211a <wait+0x4a>

00000000800021f8 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800021f8:	7139                	addi	sp,sp,-64
    800021fa:	fc06                	sd	ra,56(sp)
    800021fc:	f822                	sd	s0,48(sp)
    800021fe:	f426                	sd	s1,40(sp)
    80002200:	f04a                	sd	s2,32(sp)
    80002202:	ec4e                	sd	s3,24(sp)
    80002204:	e852                	sd	s4,16(sp)
    80002206:	e456                	sd	s5,8(sp)
    80002208:	0080                	addi	s0,sp,64
    8000220a:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000220c:	0000f497          	auipc	s1,0xf
    80002210:	4c448493          	addi	s1,s1,1220 # 800116d0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002214:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002216:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002218:	00015917          	auipc	s2,0x15
    8000221c:	eb890913          	addi	s2,s2,-328 # 800170d0 <tickslock>
    80002220:	a821                	j	80002238 <wakeup+0x40>
        p->state = RUNNABLE;
    80002222:	0154ac23          	sw	s5,24(s1)
      }
      release(&p->lock);
    80002226:	8526                	mv	a0,s1
    80002228:	fffff097          	auipc	ra,0xfffff
    8000222c:	a70080e7          	jalr	-1424(ra) # 80000c98 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002230:	16848493          	addi	s1,s1,360
    80002234:	03248463          	beq	s1,s2,8000225c <wakeup+0x64>
    if(p != myproc()){
    80002238:	fffff097          	auipc	ra,0xfffff
    8000223c:	778080e7          	jalr	1912(ra) # 800019b0 <myproc>
    80002240:	fea488e3          	beq	s1,a0,80002230 <wakeup+0x38>
      acquire(&p->lock);
    80002244:	8526                	mv	a0,s1
    80002246:	fffff097          	auipc	ra,0xfffff
    8000224a:	99e080e7          	jalr	-1634(ra) # 80000be4 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    8000224e:	4c9c                	lw	a5,24(s1)
    80002250:	fd379be3          	bne	a5,s3,80002226 <wakeup+0x2e>
    80002254:	709c                	ld	a5,32(s1)
    80002256:	fd4798e3          	bne	a5,s4,80002226 <wakeup+0x2e>
    8000225a:	b7e1                	j	80002222 <wakeup+0x2a>
    }
  }
}
    8000225c:	70e2                	ld	ra,56(sp)
    8000225e:	7442                	ld	s0,48(sp)
    80002260:	74a2                	ld	s1,40(sp)
    80002262:	7902                	ld	s2,32(sp)
    80002264:	69e2                	ld	s3,24(sp)
    80002266:	6a42                	ld	s4,16(sp)
    80002268:	6aa2                	ld	s5,8(sp)
    8000226a:	6121                	addi	sp,sp,64
    8000226c:	8082                	ret

000000008000226e <reparent>:
{
    8000226e:	7179                	addi	sp,sp,-48
    80002270:	f406                	sd	ra,40(sp)
    80002272:	f022                	sd	s0,32(sp)
    80002274:	ec26                	sd	s1,24(sp)
    80002276:	e84a                	sd	s2,16(sp)
    80002278:	e44e                	sd	s3,8(sp)
    8000227a:	e052                	sd	s4,0(sp)
    8000227c:	1800                	addi	s0,sp,48
    8000227e:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002280:	0000f497          	auipc	s1,0xf
    80002284:	45048493          	addi	s1,s1,1104 # 800116d0 <proc>
      pp->parent = initproc;
    80002288:	00007a17          	auipc	s4,0x7
    8000228c:	da0a0a13          	addi	s4,s4,-608 # 80009028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002290:	00015997          	auipc	s3,0x15
    80002294:	e4098993          	addi	s3,s3,-448 # 800170d0 <tickslock>
    80002298:	a029                	j	800022a2 <reparent+0x34>
    8000229a:	16848493          	addi	s1,s1,360
    8000229e:	01348d63          	beq	s1,s3,800022b8 <reparent+0x4a>
    if(pp->parent == p){
    800022a2:	7c9c                	ld	a5,56(s1)
    800022a4:	ff279be3          	bne	a5,s2,8000229a <reparent+0x2c>
      pp->parent = initproc;
    800022a8:	000a3503          	ld	a0,0(s4)
    800022ac:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800022ae:	00000097          	auipc	ra,0x0
    800022b2:	f4a080e7          	jalr	-182(ra) # 800021f8 <wakeup>
    800022b6:	b7d5                	j	8000229a <reparent+0x2c>
}
    800022b8:	70a2                	ld	ra,40(sp)
    800022ba:	7402                	ld	s0,32(sp)
    800022bc:	64e2                	ld	s1,24(sp)
    800022be:	6942                	ld	s2,16(sp)
    800022c0:	69a2                	ld	s3,8(sp)
    800022c2:	6a02                	ld	s4,0(sp)
    800022c4:	6145                	addi	sp,sp,48
    800022c6:	8082                	ret

00000000800022c8 <exit>:
{
    800022c8:	7179                	addi	sp,sp,-48
    800022ca:	f406                	sd	ra,40(sp)
    800022cc:	f022                	sd	s0,32(sp)
    800022ce:	ec26                	sd	s1,24(sp)
    800022d0:	e84a                	sd	s2,16(sp)
    800022d2:	e44e                	sd	s3,8(sp)
    800022d4:	e052                	sd	s4,0(sp)
    800022d6:	1800                	addi	s0,sp,48
    800022d8:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800022da:	fffff097          	auipc	ra,0xfffff
    800022de:	6d6080e7          	jalr	1750(ra) # 800019b0 <myproc>
    800022e2:	89aa                	mv	s3,a0
  if(p == initproc)
    800022e4:	00007797          	auipc	a5,0x7
    800022e8:	d447b783          	ld	a5,-700(a5) # 80009028 <initproc>
    800022ec:	0d050493          	addi	s1,a0,208
    800022f0:	15050913          	addi	s2,a0,336
    800022f4:	02a79363          	bne	a5,a0,8000231a <exit+0x52>
    panic("init exiting");
    800022f8:	00006517          	auipc	a0,0x6
    800022fc:	f6850513          	addi	a0,a0,-152 # 80008260 <digits+0x220>
    80002300:	ffffe097          	auipc	ra,0xffffe
    80002304:	23e080e7          	jalr	574(ra) # 8000053e <panic>
      fileclose(f);
    80002308:	00002097          	auipc	ra,0x2
    8000230c:	554080e7          	jalr	1364(ra) # 8000485c <fileclose>
      p->ofile[fd] = 0;
    80002310:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002314:	04a1                	addi	s1,s1,8
    80002316:	01248563          	beq	s1,s2,80002320 <exit+0x58>
    if(p->ofile[fd]){
    8000231a:	6088                	ld	a0,0(s1)
    8000231c:	f575                	bnez	a0,80002308 <exit+0x40>
    8000231e:	bfdd                	j	80002314 <exit+0x4c>
  begin_op();
    80002320:	00002097          	auipc	ra,0x2
    80002324:	070080e7          	jalr	112(ra) # 80004390 <begin_op>
  iput(p->cwd);
    80002328:	1509b503          	ld	a0,336(s3)
    8000232c:	00002097          	auipc	ra,0x2
    80002330:	84c080e7          	jalr	-1972(ra) # 80003b78 <iput>
  end_op();
    80002334:	00002097          	auipc	ra,0x2
    80002338:	0dc080e7          	jalr	220(ra) # 80004410 <end_op>
  p->cwd = 0;
    8000233c:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002340:	0000f497          	auipc	s1,0xf
    80002344:	f7848493          	addi	s1,s1,-136 # 800112b8 <wait_lock>
    80002348:	8526                	mv	a0,s1
    8000234a:	fffff097          	auipc	ra,0xfffff
    8000234e:	89a080e7          	jalr	-1894(ra) # 80000be4 <acquire>
  reparent(p);
    80002352:	854e                	mv	a0,s3
    80002354:	00000097          	auipc	ra,0x0
    80002358:	f1a080e7          	jalr	-230(ra) # 8000226e <reparent>
  wakeup(p->parent);
    8000235c:	0389b503          	ld	a0,56(s3)
    80002360:	00000097          	auipc	ra,0x0
    80002364:	e98080e7          	jalr	-360(ra) # 800021f8 <wakeup>
  acquire(&p->lock);
    80002368:	854e                	mv	a0,s3
    8000236a:	fffff097          	auipc	ra,0xfffff
    8000236e:	87a080e7          	jalr	-1926(ra) # 80000be4 <acquire>
  p->xstate = status;
    80002372:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002376:	4795                	li	a5,5
    80002378:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000237c:	8526                	mv	a0,s1
    8000237e:	fffff097          	auipc	ra,0xfffff
    80002382:	91a080e7          	jalr	-1766(ra) # 80000c98 <release>
  sched();
    80002386:	00000097          	auipc	ra,0x0
    8000238a:	bd4080e7          	jalr	-1068(ra) # 80001f5a <sched>
  panic("zombie exit");
    8000238e:	00006517          	auipc	a0,0x6
    80002392:	ee250513          	addi	a0,a0,-286 # 80008270 <digits+0x230>
    80002396:	ffffe097          	auipc	ra,0xffffe
    8000239a:	1a8080e7          	jalr	424(ra) # 8000053e <panic>

000000008000239e <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000239e:	7179                	addi	sp,sp,-48
    800023a0:	f406                	sd	ra,40(sp)
    800023a2:	f022                	sd	s0,32(sp)
    800023a4:	ec26                	sd	s1,24(sp)
    800023a6:	e84a                	sd	s2,16(sp)
    800023a8:	e44e                	sd	s3,8(sp)
    800023aa:	1800                	addi	s0,sp,48
    800023ac:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800023ae:	0000f497          	auipc	s1,0xf
    800023b2:	32248493          	addi	s1,s1,802 # 800116d0 <proc>
    800023b6:	00015997          	auipc	s3,0x15
    800023ba:	d1a98993          	addi	s3,s3,-742 # 800170d0 <tickslock>
    acquire(&p->lock);
    800023be:	8526                	mv	a0,s1
    800023c0:	fffff097          	auipc	ra,0xfffff
    800023c4:	824080e7          	jalr	-2012(ra) # 80000be4 <acquire>
    if(p->pid == pid){
    800023c8:	589c                	lw	a5,48(s1)
    800023ca:	01278d63          	beq	a5,s2,800023e4 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800023ce:	8526                	mv	a0,s1
    800023d0:	fffff097          	auipc	ra,0xfffff
    800023d4:	8c8080e7          	jalr	-1848(ra) # 80000c98 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800023d8:	16848493          	addi	s1,s1,360
    800023dc:	ff3491e3          	bne	s1,s3,800023be <kill+0x20>
  }
  return -1;
    800023e0:	557d                	li	a0,-1
    800023e2:	a829                	j	800023fc <kill+0x5e>
      p->killed = 1;
    800023e4:	4785                	li	a5,1
    800023e6:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800023e8:	4c98                	lw	a4,24(s1)
    800023ea:	4789                	li	a5,2
    800023ec:	00f70f63          	beq	a4,a5,8000240a <kill+0x6c>
      release(&p->lock);
    800023f0:	8526                	mv	a0,s1
    800023f2:	fffff097          	auipc	ra,0xfffff
    800023f6:	8a6080e7          	jalr	-1882(ra) # 80000c98 <release>
      return 0;
    800023fa:	4501                	li	a0,0
}
    800023fc:	70a2                	ld	ra,40(sp)
    800023fe:	7402                	ld	s0,32(sp)
    80002400:	64e2                	ld	s1,24(sp)
    80002402:	6942                	ld	s2,16(sp)
    80002404:	69a2                	ld	s3,8(sp)
    80002406:	6145                	addi	sp,sp,48
    80002408:	8082                	ret
        p->state = RUNNABLE;
    8000240a:	478d                	li	a5,3
    8000240c:	cc9c                	sw	a5,24(s1)
    8000240e:	b7cd                	j	800023f0 <kill+0x52>

0000000080002410 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002410:	7179                	addi	sp,sp,-48
    80002412:	f406                	sd	ra,40(sp)
    80002414:	f022                	sd	s0,32(sp)
    80002416:	ec26                	sd	s1,24(sp)
    80002418:	e84a                	sd	s2,16(sp)
    8000241a:	e44e                	sd	s3,8(sp)
    8000241c:	e052                	sd	s4,0(sp)
    8000241e:	1800                	addi	s0,sp,48
    80002420:	84aa                	mv	s1,a0
    80002422:	892e                	mv	s2,a1
    80002424:	89b2                	mv	s3,a2
    80002426:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002428:	fffff097          	auipc	ra,0xfffff
    8000242c:	588080e7          	jalr	1416(ra) # 800019b0 <myproc>
  if(user_dst){
    80002430:	c08d                	beqz	s1,80002452 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002432:	86d2                	mv	a3,s4
    80002434:	864e                	mv	a2,s3
    80002436:	85ca                	mv	a1,s2
    80002438:	6928                	ld	a0,80(a0)
    8000243a:	fffff097          	auipc	ra,0xfffff
    8000243e:	238080e7          	jalr	568(ra) # 80001672 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002442:	70a2                	ld	ra,40(sp)
    80002444:	7402                	ld	s0,32(sp)
    80002446:	64e2                	ld	s1,24(sp)
    80002448:	6942                	ld	s2,16(sp)
    8000244a:	69a2                	ld	s3,8(sp)
    8000244c:	6a02                	ld	s4,0(sp)
    8000244e:	6145                	addi	sp,sp,48
    80002450:	8082                	ret
    memmove((char *)dst, src, len);
    80002452:	000a061b          	sext.w	a2,s4
    80002456:	85ce                	mv	a1,s3
    80002458:	854a                	mv	a0,s2
    8000245a:	fffff097          	auipc	ra,0xfffff
    8000245e:	8e6080e7          	jalr	-1818(ra) # 80000d40 <memmove>
    return 0;
    80002462:	8526                	mv	a0,s1
    80002464:	bff9                	j	80002442 <either_copyout+0x32>

0000000080002466 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002466:	7179                	addi	sp,sp,-48
    80002468:	f406                	sd	ra,40(sp)
    8000246a:	f022                	sd	s0,32(sp)
    8000246c:	ec26                	sd	s1,24(sp)
    8000246e:	e84a                	sd	s2,16(sp)
    80002470:	e44e                	sd	s3,8(sp)
    80002472:	e052                	sd	s4,0(sp)
    80002474:	1800                	addi	s0,sp,48
    80002476:	892a                	mv	s2,a0
    80002478:	84ae                	mv	s1,a1
    8000247a:	89b2                	mv	s3,a2
    8000247c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000247e:	fffff097          	auipc	ra,0xfffff
    80002482:	532080e7          	jalr	1330(ra) # 800019b0 <myproc>
  if(user_src){
    80002486:	c08d                	beqz	s1,800024a8 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002488:	86d2                	mv	a3,s4
    8000248a:	864e                	mv	a2,s3
    8000248c:	85ca                	mv	a1,s2
    8000248e:	6928                	ld	a0,80(a0)
    80002490:	fffff097          	auipc	ra,0xfffff
    80002494:	26e080e7          	jalr	622(ra) # 800016fe <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002498:	70a2                	ld	ra,40(sp)
    8000249a:	7402                	ld	s0,32(sp)
    8000249c:	64e2                	ld	s1,24(sp)
    8000249e:	6942                	ld	s2,16(sp)
    800024a0:	69a2                	ld	s3,8(sp)
    800024a2:	6a02                	ld	s4,0(sp)
    800024a4:	6145                	addi	sp,sp,48
    800024a6:	8082                	ret
    memmove(dst, (char*)src, len);
    800024a8:	000a061b          	sext.w	a2,s4
    800024ac:	85ce                	mv	a1,s3
    800024ae:	854a                	mv	a0,s2
    800024b0:	fffff097          	auipc	ra,0xfffff
    800024b4:	890080e7          	jalr	-1904(ra) # 80000d40 <memmove>
    return 0;
    800024b8:	8526                	mv	a0,s1
    800024ba:	bff9                	j	80002498 <either_copyin+0x32>

00000000800024bc <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800024bc:	715d                	addi	sp,sp,-80
    800024be:	e486                	sd	ra,72(sp)
    800024c0:	e0a2                	sd	s0,64(sp)
    800024c2:	fc26                	sd	s1,56(sp)
    800024c4:	f84a                	sd	s2,48(sp)
    800024c6:	f44e                	sd	s3,40(sp)
    800024c8:	f052                	sd	s4,32(sp)
    800024ca:	ec56                	sd	s5,24(sp)
    800024cc:	e85a                	sd	s6,16(sp)
    800024ce:	e45e                	sd	s7,8(sp)
    800024d0:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800024d2:	00006517          	auipc	a0,0x6
    800024d6:	bf650513          	addi	a0,a0,-1034 # 800080c8 <digits+0x88>
    800024da:	ffffe097          	auipc	ra,0xffffe
    800024de:	0ae080e7          	jalr	174(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800024e2:	0000f497          	auipc	s1,0xf
    800024e6:	34648493          	addi	s1,s1,838 # 80011828 <proc+0x158>
    800024ea:	00015917          	auipc	s2,0x15
    800024ee:	d3e90913          	addi	s2,s2,-706 # 80017228 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800024f2:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800024f4:	00006997          	auipc	s3,0x6
    800024f8:	d8c98993          	addi	s3,s3,-628 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    800024fc:	00006a97          	auipc	s5,0x6
    80002500:	d8ca8a93          	addi	s5,s5,-628 # 80008288 <digits+0x248>
    printf("\n");
    80002504:	00006a17          	auipc	s4,0x6
    80002508:	bc4a0a13          	addi	s4,s4,-1084 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000250c:	00006b97          	auipc	s7,0x6
    80002510:	dfcb8b93          	addi	s7,s7,-516 # 80008308 <states.1714>
    80002514:	a00d                	j	80002536 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002516:	ed86a583          	lw	a1,-296(a3)
    8000251a:	8556                	mv	a0,s5
    8000251c:	ffffe097          	auipc	ra,0xffffe
    80002520:	06c080e7          	jalr	108(ra) # 80000588 <printf>
    printf("\n");
    80002524:	8552                	mv	a0,s4
    80002526:	ffffe097          	auipc	ra,0xffffe
    8000252a:	062080e7          	jalr	98(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000252e:	16848493          	addi	s1,s1,360
    80002532:	03248163          	beq	s1,s2,80002554 <procdump+0x98>
    if(p->state == UNUSED)
    80002536:	86a6                	mv	a3,s1
    80002538:	ec04a783          	lw	a5,-320(s1)
    8000253c:	dbed                	beqz	a5,8000252e <procdump+0x72>
      state = "???";
    8000253e:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002540:	fcfb6be3          	bltu	s6,a5,80002516 <procdump+0x5a>
    80002544:	1782                	slli	a5,a5,0x20
    80002546:	9381                	srli	a5,a5,0x20
    80002548:	078e                	slli	a5,a5,0x3
    8000254a:	97de                	add	a5,a5,s7
    8000254c:	6390                	ld	a2,0(a5)
    8000254e:	f661                	bnez	a2,80002516 <procdump+0x5a>
      state = "???";
    80002550:	864e                	mv	a2,s3
    80002552:	b7d1                	j	80002516 <procdump+0x5a>
  }
}
    80002554:	60a6                	ld	ra,72(sp)
    80002556:	6406                	ld	s0,64(sp)
    80002558:	74e2                	ld	s1,56(sp)
    8000255a:	7942                	ld	s2,48(sp)
    8000255c:	79a2                	ld	s3,40(sp)
    8000255e:	7a02                	ld	s4,32(sp)
    80002560:	6ae2                	ld	s5,24(sp)
    80002562:	6b42                	ld	s6,16(sp)
    80002564:	6ba2                	ld	s7,8(sp)
    80002566:	6161                	addi	sp,sp,80
    80002568:	8082                	ret

000000008000256a <waitpid>:

int
waitpid(int pid_inp,uint64 addr)
{
    8000256a:	711d                	addi	sp,sp,-96
    8000256c:	ec86                	sd	ra,88(sp)
    8000256e:	e8a2                	sd	s0,80(sp)
    80002570:	e4a6                	sd	s1,72(sp)
    80002572:	e0ca                	sd	s2,64(sp)
    80002574:	fc4e                	sd	s3,56(sp)
    80002576:	f852                	sd	s4,48(sp)
    80002578:	f456                	sd	s5,40(sp)
    8000257a:	f05a                	sd	s6,32(sp)
    8000257c:	ec5e                	sd	s7,24(sp)
    8000257e:	e862                	sd	s8,16(sp)
    80002580:	e466                	sd	s9,8(sp)
    80002582:	1080                	addi	s0,sp,96
    80002584:	892a                	mv	s2,a0
    80002586:	8aae                	mv	s5,a1
  if(pid_inp==-1){
    80002588:	57fd                	li	a5,-1
    8000258a:	04f50063          	beq	a0,a5,800025ca <waitpid+0x60>
      sleep(p, &wait_lock);  //DOC: wait-sleep
    }
  }else{
    struct proc *np;
    int havekids, pid;
    struct proc *p = myproc();
    8000258e:	fffff097          	auipc	ra,0xfffff
    80002592:	422080e7          	jalr	1058(ra) # 800019b0 <myproc>
    80002596:	8baa                	mv	s7,a0

    acquire(&wait_lock);
    80002598:	0000f517          	auipc	a0,0xf
    8000259c:	d2050513          	addi	a0,a0,-736 # 800112b8 <wait_lock>
    800025a0:	ffffe097          	auipc	ra,0xffffe
    800025a4:	644080e7          	jalr	1604(ra) # 80000be4 <acquire>

    for(;;){
      // Scan through table looking for exited children.
      havekids = 0;
    800025a8:	4c01                	li	s8,0
        if(np->pid == pid_inp){
          // make sure the child isn't still in exit() or swtch().
          acquire(&np->lock);

          havekids = 1;
          if(np->state == ZOMBIE){
    800025aa:	4a15                	li	s4,5
      for(np = proc; np < &proc[NPROC]; np++){
    800025ac:	00015997          	auipc	s3,0x15
    800025b0:	b2498993          	addi	s3,s3,-1244 # 800170d0 <tickslock>
          havekids = 1;
    800025b4:	4b05                	li	s6,1
        release(&wait_lock);
        return -1;
      }
      
      // Wait for a child to exit.
      sleep(p, &wait_lock);  //DOC: wait-sleep
    800025b6:	0000fc97          	auipc	s9,0xf
    800025ba:	d02c8c93          	addi	s9,s9,-766 # 800112b8 <wait_lock>
      havekids = 0;
    800025be:	8762                	mv	a4,s8
      for(np = proc; np < &proc[NPROC]; np++){
    800025c0:	0000f497          	auipc	s1,0xf
    800025c4:	11048493          	addi	s1,s1,272 # 800116d0 <proc>
    800025c8:	aabd                	j	80002746 <waitpid+0x1dc>
    struct proc *p = myproc();
    800025ca:	fffff097          	auipc	ra,0xfffff
    800025ce:	3e6080e7          	jalr	998(ra) # 800019b0 <myproc>
    800025d2:	89aa                	mv	s3,a0
    acquire(&wait_lock);
    800025d4:	0000f517          	auipc	a0,0xf
    800025d8:	ce450513          	addi	a0,a0,-796 # 800112b8 <wait_lock>
    800025dc:	ffffe097          	auipc	ra,0xffffe
    800025e0:	608080e7          	jalr	1544(ra) # 80000be4 <acquire>
      havekids = 0;
    800025e4:	4c01                	li	s8,0
          if(np->state == ZOMBIE){
    800025e6:	4b15                	li	s6,5
      for(np = proc; np < &proc[NPROC]; np++){
    800025e8:	00015a17          	auipc	s4,0x15
    800025ec:	ae8a0a13          	addi	s4,s4,-1304 # 800170d0 <tickslock>
          havekids = 1;
    800025f0:	4b85                	li	s7,1
      sleep(p, &wait_lock);  //DOC: wait-sleep
    800025f2:	0000fc97          	auipc	s9,0xf
    800025f6:	cc6c8c93          	addi	s9,s9,-826 # 800112b8 <wait_lock>
      havekids = 0;
    800025fa:	8762                	mv	a4,s8
      for(np = proc; np < &proc[NPROC]; np++){
    800025fc:	0000f497          	auipc	s1,0xf
    80002600:	0d448493          	addi	s1,s1,212 # 800116d0 <proc>
    80002604:	a0bd                	j	80002672 <waitpid+0x108>
            pid = np->pid;
    80002606:	0304aa03          	lw	s4,48(s1)
            if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000260a:	000a8e63          	beqz	s5,80002626 <waitpid+0xbc>
    8000260e:	4691                	li	a3,4
    80002610:	02c48613          	addi	a2,s1,44
    80002614:	85d6                	mv	a1,s5
    80002616:	0509b503          	ld	a0,80(s3)
    8000261a:	fffff097          	auipc	ra,0xfffff
    8000261e:	058080e7          	jalr	88(ra) # 80001672 <copyout>
    80002622:	02054563          	bltz	a0,8000264c <waitpid+0xe2>
            freeproc(np);
    80002626:	8526                	mv	a0,s1
    80002628:	fffff097          	auipc	ra,0xfffff
    8000262c:	53a080e7          	jalr	1338(ra) # 80001b62 <freeproc>
            release(&np->lock);
    80002630:	8526                	mv	a0,s1
    80002632:	ffffe097          	auipc	ra,0xffffe
    80002636:	666080e7          	jalr	1638(ra) # 80000c98 <release>
            release(&wait_lock);
    8000263a:	0000f517          	auipc	a0,0xf
    8000263e:	c7e50513          	addi	a0,a0,-898 # 800112b8 <wait_lock>
    80002642:	ffffe097          	auipc	ra,0xffffe
    80002646:	656080e7          	jalr	1622(ra) # 80000c98 <release>
            return pid;
    8000264a:	a86d                	j	80002704 <waitpid+0x19a>
              release(&np->lock);
    8000264c:	8526                	mv	a0,s1
    8000264e:	ffffe097          	auipc	ra,0xffffe
    80002652:	64a080e7          	jalr	1610(ra) # 80000c98 <release>
              release(&wait_lock);
    80002656:	0000f517          	auipc	a0,0xf
    8000265a:	c6250513          	addi	a0,a0,-926 # 800112b8 <wait_lock>
    8000265e:	ffffe097          	auipc	ra,0xffffe
    80002662:	63a080e7          	jalr	1594(ra) # 80000c98 <release>
              return -1;
    80002666:	8a4a                	mv	s4,s2
    80002668:	a871                	j	80002704 <waitpid+0x19a>
      for(np = proc; np < &proc[NPROC]; np++){
    8000266a:	16848493          	addi	s1,s1,360
    8000266e:	03448463          	beq	s1,s4,80002696 <waitpid+0x12c>
        if(np->parent == p){
    80002672:	7c9c                	ld	a5,56(s1)
    80002674:	ff379be3          	bne	a5,s3,8000266a <waitpid+0x100>
          acquire(&np->lock);
    80002678:	8526                	mv	a0,s1
    8000267a:	ffffe097          	auipc	ra,0xffffe
    8000267e:	56a080e7          	jalr	1386(ra) # 80000be4 <acquire>
          if(np->state == ZOMBIE){
    80002682:	4c9c                	lw	a5,24(s1)
    80002684:	f96781e3          	beq	a5,s6,80002606 <waitpid+0x9c>
          release(&np->lock);
    80002688:	8526                	mv	a0,s1
    8000268a:	ffffe097          	auipc	ra,0xffffe
    8000268e:	60e080e7          	jalr	1550(ra) # 80000c98 <release>
          havekids = 1;
    80002692:	875e                	mv	a4,s7
    80002694:	bfd9                	j	8000266a <waitpid+0x100>
      if(!havekids || p->killed){
    80002696:	c701                	beqz	a4,8000269e <waitpid+0x134>
    80002698:	0289a783          	lw	a5,40(s3)
    8000269c:	cb99                	beqz	a5,800026b2 <waitpid+0x148>
        release(&wait_lock);
    8000269e:	0000f517          	auipc	a0,0xf
    800026a2:	c1a50513          	addi	a0,a0,-998 # 800112b8 <wait_lock>
    800026a6:	ffffe097          	auipc	ra,0xffffe
    800026aa:	5f2080e7          	jalr	1522(ra) # 80000c98 <release>
        return -1;
    800026ae:	8a4a                	mv	s4,s2
    800026b0:	a891                	j	80002704 <waitpid+0x19a>
      sleep(p, &wait_lock);  //DOC: wait-sleep
    800026b2:	85e6                	mv	a1,s9
    800026b4:	854e                	mv	a0,s3
    800026b6:	00000097          	auipc	ra,0x0
    800026ba:	9b6080e7          	jalr	-1610(ra) # 8000206c <sleep>
      havekids = 0;
    800026be:	bf35                	j	800025fa <waitpid+0x90>
            pid = np->pid;
    800026c0:	0304aa03          	lw	s4,48(s1)
            if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800026c4:	000a8e63          	beqz	s5,800026e0 <waitpid+0x176>
    800026c8:	4691                	li	a3,4
    800026ca:	02c48613          	addi	a2,s1,44
    800026ce:	85d6                	mv	a1,s5
    800026d0:	050bb503          	ld	a0,80(s7)
    800026d4:	fffff097          	auipc	ra,0xfffff
    800026d8:	f9e080e7          	jalr	-98(ra) # 80001672 <copyout>
    800026dc:	04054263          	bltz	a0,80002720 <waitpid+0x1b6>
            freeproc(np);
    800026e0:	8526                	mv	a0,s1
    800026e2:	fffff097          	auipc	ra,0xfffff
    800026e6:	480080e7          	jalr	1152(ra) # 80001b62 <freeproc>
            release(&np->lock);
    800026ea:	8526                	mv	a0,s1
    800026ec:	ffffe097          	auipc	ra,0xffffe
    800026f0:	5ac080e7          	jalr	1452(ra) # 80000c98 <release>
            release(&wait_lock);
    800026f4:	0000f517          	auipc	a0,0xf
    800026f8:	bc450513          	addi	a0,a0,-1084 # 800112b8 <wait_lock>
    800026fc:	ffffe097          	auipc	ra,0xffffe
    80002700:	59c080e7          	jalr	1436(ra) # 80000c98 <release>
    }
  }
}
    80002704:	8552                	mv	a0,s4
    80002706:	60e6                	ld	ra,88(sp)
    80002708:	6446                	ld	s0,80(sp)
    8000270a:	64a6                	ld	s1,72(sp)
    8000270c:	6906                	ld	s2,64(sp)
    8000270e:	79e2                	ld	s3,56(sp)
    80002710:	7a42                	ld	s4,48(sp)
    80002712:	7aa2                	ld	s5,40(sp)
    80002714:	7b02                	ld	s6,32(sp)
    80002716:	6be2                	ld	s7,24(sp)
    80002718:	6c42                	ld	s8,16(sp)
    8000271a:	6ca2                	ld	s9,8(sp)
    8000271c:	6125                	addi	sp,sp,96
    8000271e:	8082                	ret
              release(&np->lock);
    80002720:	8526                	mv	a0,s1
    80002722:	ffffe097          	auipc	ra,0xffffe
    80002726:	576080e7          	jalr	1398(ra) # 80000c98 <release>
              release(&wait_lock);
    8000272a:	0000f517          	auipc	a0,0xf
    8000272e:	b8e50513          	addi	a0,a0,-1138 # 800112b8 <wait_lock>
    80002732:	ffffe097          	auipc	ra,0xffffe
    80002736:	566080e7          	jalr	1382(ra) # 80000c98 <release>
              return -1;
    8000273a:	5a7d                	li	s4,-1
    8000273c:	b7e1                	j	80002704 <waitpid+0x19a>
      for(np = proc; np < &proc[NPROC]; np++){
    8000273e:	16848493          	addi	s1,s1,360
    80002742:	03348463          	beq	s1,s3,8000276a <waitpid+0x200>
        if(np->pid == pid_inp){
    80002746:	589c                	lw	a5,48(s1)
    80002748:	ff279be3          	bne	a5,s2,8000273e <waitpid+0x1d4>
          acquire(&np->lock);
    8000274c:	8526                	mv	a0,s1
    8000274e:	ffffe097          	auipc	ra,0xffffe
    80002752:	496080e7          	jalr	1174(ra) # 80000be4 <acquire>
          if(np->state == ZOMBIE){
    80002756:	4c9c                	lw	a5,24(s1)
    80002758:	f74784e3          	beq	a5,s4,800026c0 <waitpid+0x156>
          release(&np->lock);
    8000275c:	8526                	mv	a0,s1
    8000275e:	ffffe097          	auipc	ra,0xffffe
    80002762:	53a080e7          	jalr	1338(ra) # 80000c98 <release>
          havekids = 1;
    80002766:	875a                	mv	a4,s6
    80002768:	bfd9                	j	8000273e <waitpid+0x1d4>
      if(!havekids || p->killed){
    8000276a:	c701                	beqz	a4,80002772 <waitpid+0x208>
    8000276c:	028ba783          	lw	a5,40(s7)
    80002770:	cb99                	beqz	a5,80002786 <waitpid+0x21c>
        release(&wait_lock);
    80002772:	0000f517          	auipc	a0,0xf
    80002776:	b4650513          	addi	a0,a0,-1210 # 800112b8 <wait_lock>
    8000277a:	ffffe097          	auipc	ra,0xffffe
    8000277e:	51e080e7          	jalr	1310(ra) # 80000c98 <release>
        return -1;
    80002782:	5a7d                	li	s4,-1
    80002784:	b741                	j	80002704 <waitpid+0x19a>
      sleep(p, &wait_lock);  //DOC: wait-sleep
    80002786:	85e6                	mv	a1,s9
    80002788:	855e                	mv	a0,s7
    8000278a:	00000097          	auipc	ra,0x0
    8000278e:	8e2080e7          	jalr	-1822(ra) # 8000206c <sleep>
      havekids = 0;
    80002792:	b535                	j	800025be <waitpid+0x54>

0000000080002794 <cps>:

int 
cps(){
    80002794:	711d                	addi	sp,sp,-96
    80002796:	ec86                	sd	ra,88(sp)
    80002798:	e8a2                	sd	s0,80(sp)
    8000279a:	e4a6                	sd	s1,72(sp)
    8000279c:	e0ca                	sd	s2,64(sp)
    8000279e:	fc4e                	sd	s3,56(sp)
    800027a0:	f852                	sd	s4,48(sp)
    800027a2:	f456                	sd	s5,40(sp)
    800027a4:	f05a                	sd	s6,32(sp)
    800027a6:	ec5e                	sd	s7,24(sp)
    800027a8:	e862                	sd	s8,16(sp)
    800027aa:	e466                	sd	s9,8(sp)
    800027ac:	1080                	addi	s0,sp,96
   // struct proc *p;
    struct proc *np;
    //sti();
    for (np = proc ; np<&proc[NPROC];np++)
    800027ae:	0000f497          	auipc	s1,0xf
    800027b2:	f2248493          	addi	s1,s1,-222 # 800116d0 <proc>
    {

    acquire(&np->lock);
      if(np->state == SLEEPING) {
    800027b6:	4a09                	li	s4,2
        printf("%s \t %d \t SLEEPING  \n", np->name,np->pid);
      }

      else if(np->state == RUNNING) {
    800027b8:	4a91                	li	s5,4
        printf("%s \t %d \t RUNNING  \n", np->name,np->pid);
      }

      else if(np->state == RUNNABLE) {
    800027ba:	4b0d                	li	s6,3
        printf("%s \t %d \t RUNNABLE \n", np->name,np->pid);
    800027bc:	00006c97          	auipc	s9,0x6
    800027c0:	b0cc8c93          	addi	s9,s9,-1268 # 800082c8 <digits+0x288>
        printf("%s \t %d \t RUNNING  \n", np->name,np->pid);
    800027c4:	00006c17          	auipc	s8,0x6
    800027c8:	aecc0c13          	addi	s8,s8,-1300 # 800082b0 <digits+0x270>
        printf("%s \t %d \t SLEEPING  \n", np->name,np->pid);
    800027cc:	00006b97          	auipc	s7,0x6
    800027d0:	accb8b93          	addi	s7,s7,-1332 # 80008298 <digits+0x258>
    for (np = proc ; np<&proc[NPROC];np++)
    800027d4:	00015997          	auipc	s3,0x15
    800027d8:	8fc98993          	addi	s3,s3,-1796 # 800170d0 <tickslock>
    800027dc:	a015                	j	80002800 <cps+0x6c>
        printf("%s \t %d \t SLEEPING  \n", np->name,np->pid);
    800027de:	5890                	lw	a2,48(s1)
    800027e0:	15848593          	addi	a1,s1,344
    800027e4:	855e                	mv	a0,s7
    800027e6:	ffffe097          	auipc	ra,0xffffe
    800027ea:	da2080e7          	jalr	-606(ra) # 80000588 <printf>
      }
     
    release(&np->lock);
    800027ee:	8526                	mv	a0,s1
    800027f0:	ffffe097          	auipc	ra,0xffffe
    800027f4:	4a8080e7          	jalr	1192(ra) # 80000c98 <release>
    for (np = proc ; np<&proc[NPROC];np++)
    800027f8:	16848493          	addi	s1,s1,360
    800027fc:	05348063          	beq	s1,s3,8000283c <cps+0xa8>
    acquire(&np->lock);
    80002800:	8526                	mv	a0,s1
    80002802:	ffffe097          	auipc	ra,0xffffe
    80002806:	3e2080e7          	jalr	994(ra) # 80000be4 <acquire>
      if(np->state == SLEEPING) {
    8000280a:	4c9c                	lw	a5,24(s1)
    8000280c:	fd4789e3          	beq	a5,s4,800027de <cps+0x4a>
      else if(np->state == RUNNING) {
    80002810:	01578d63          	beq	a5,s5,8000282a <cps+0x96>
      else if(np->state == RUNNABLE) {
    80002814:	fd679de3          	bne	a5,s6,800027ee <cps+0x5a>
        printf("%s \t %d \t RUNNABLE \n", np->name,np->pid);
    80002818:	5890                	lw	a2,48(s1)
    8000281a:	15848593          	addi	a1,s1,344
    8000281e:	8566                	mv	a0,s9
    80002820:	ffffe097          	auipc	ra,0xffffe
    80002824:	d68080e7          	jalr	-664(ra) # 80000588 <printf>
    80002828:	b7d9                	j	800027ee <cps+0x5a>
        printf("%s \t %d \t RUNNING  \n", np->name,np->pid);
    8000282a:	5890                	lw	a2,48(s1)
    8000282c:	15848593          	addi	a1,s1,344
    80002830:	8562                	mv	a0,s8
    80002832:	ffffe097          	auipc	ra,0xffffe
    80002836:	d56080e7          	jalr	-682(ra) # 80000588 <printf>
    8000283a:	bf55                	j	800027ee <cps+0x5a>
      
    }
    return 26;
    
    8000283c:	4569                	li	a0,26
    8000283e:	60e6                	ld	ra,88(sp)
    80002840:	6446                	ld	s0,80(sp)
    80002842:	64a6                	ld	s1,72(sp)
    80002844:	6906                	ld	s2,64(sp)
    80002846:	79e2                	ld	s3,56(sp)
    80002848:	7a42                	ld	s4,48(sp)
    8000284a:	7aa2                	ld	s5,40(sp)
    8000284c:	7b02                	ld	s6,32(sp)
    8000284e:	6be2                	ld	s7,24(sp)
    80002850:	6c42                	ld	s8,16(sp)
    80002852:	6ca2                	ld	s9,8(sp)
    80002854:	6125                	addi	sp,sp,96
    80002856:	8082                	ret

0000000080002858 <swtch>:
    80002858:	00153023          	sd	ra,0(a0)
    8000285c:	00253423          	sd	sp,8(a0)
    80002860:	e900                	sd	s0,16(a0)
    80002862:	ed04                	sd	s1,24(a0)
    80002864:	03253023          	sd	s2,32(a0)
    80002868:	03353423          	sd	s3,40(a0)
    8000286c:	03453823          	sd	s4,48(a0)
    80002870:	03553c23          	sd	s5,56(a0)
    80002874:	05653023          	sd	s6,64(a0)
    80002878:	05753423          	sd	s7,72(a0)
    8000287c:	05853823          	sd	s8,80(a0)
    80002880:	05953c23          	sd	s9,88(a0)
    80002884:	07a53023          	sd	s10,96(a0)
    80002888:	07b53423          	sd	s11,104(a0)
    8000288c:	0005b083          	ld	ra,0(a1)
    80002890:	0085b103          	ld	sp,8(a1)
    80002894:	6980                	ld	s0,16(a1)
    80002896:	6d84                	ld	s1,24(a1)
    80002898:	0205b903          	ld	s2,32(a1)
    8000289c:	0285b983          	ld	s3,40(a1)
    800028a0:	0305ba03          	ld	s4,48(a1)
    800028a4:	0385ba83          	ld	s5,56(a1)
    800028a8:	0405bb03          	ld	s6,64(a1)
    800028ac:	0485bb83          	ld	s7,72(a1)
    800028b0:	0505bc03          	ld	s8,80(a1)
    800028b4:	0585bc83          	ld	s9,88(a1)
    800028b8:	0605bd03          	ld	s10,96(a1)
    800028bc:	0685bd83          	ld	s11,104(a1)
    800028c0:	8082                	ret

00000000800028c2 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800028c2:	1141                	addi	sp,sp,-16
    800028c4:	e406                	sd	ra,8(sp)
    800028c6:	e022                	sd	s0,0(sp)
    800028c8:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800028ca:	00006597          	auipc	a1,0x6
    800028ce:	a6e58593          	addi	a1,a1,-1426 # 80008338 <states.1714+0x30>
    800028d2:	00014517          	auipc	a0,0x14
    800028d6:	7fe50513          	addi	a0,a0,2046 # 800170d0 <tickslock>
    800028da:	ffffe097          	auipc	ra,0xffffe
    800028de:	27a080e7          	jalr	634(ra) # 80000b54 <initlock>
}
    800028e2:	60a2                	ld	ra,8(sp)
    800028e4:	6402                	ld	s0,0(sp)
    800028e6:	0141                	addi	sp,sp,16
    800028e8:	8082                	ret

00000000800028ea <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800028ea:	1141                	addi	sp,sp,-16
    800028ec:	e422                	sd	s0,8(sp)
    800028ee:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028f0:	00003797          	auipc	a5,0x3
    800028f4:	58078793          	addi	a5,a5,1408 # 80005e70 <kernelvec>
    800028f8:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800028fc:	6422                	ld	s0,8(sp)
    800028fe:	0141                	addi	sp,sp,16
    80002900:	8082                	ret

0000000080002902 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002902:	1141                	addi	sp,sp,-16
    80002904:	e406                	sd	ra,8(sp)
    80002906:	e022                	sd	s0,0(sp)
    80002908:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000290a:	fffff097          	auipc	ra,0xfffff
    8000290e:	0a6080e7          	jalr	166(ra) # 800019b0 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002912:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002916:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002918:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    8000291c:	00004617          	auipc	a2,0x4
    80002920:	6e460613          	addi	a2,a2,1764 # 80007000 <_trampoline>
    80002924:	00004697          	auipc	a3,0x4
    80002928:	6dc68693          	addi	a3,a3,1756 # 80007000 <_trampoline>
    8000292c:	8e91                	sub	a3,a3,a2
    8000292e:	040007b7          	lui	a5,0x4000
    80002932:	17fd                	addi	a5,a5,-1
    80002934:	07b2                	slli	a5,a5,0xc
    80002936:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002938:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000293c:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000293e:	180026f3          	csrr	a3,satp
    80002942:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002944:	6d38                	ld	a4,88(a0)
    80002946:	6134                	ld	a3,64(a0)
    80002948:	6585                	lui	a1,0x1
    8000294a:	96ae                	add	a3,a3,a1
    8000294c:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000294e:	6d38                	ld	a4,88(a0)
    80002950:	00000697          	auipc	a3,0x0
    80002954:	13868693          	addi	a3,a3,312 # 80002a88 <usertrap>
    80002958:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000295a:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000295c:	8692                	mv	a3,tp
    8000295e:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002960:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002964:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002968:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000296c:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002970:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002972:	6f18                	ld	a4,24(a4)
    80002974:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002978:	692c                	ld	a1,80(a0)
    8000297a:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    8000297c:	00004717          	auipc	a4,0x4
    80002980:	71470713          	addi	a4,a4,1812 # 80007090 <userret>
    80002984:	8f11                	sub	a4,a4,a2
    80002986:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002988:	577d                	li	a4,-1
    8000298a:	177e                	slli	a4,a4,0x3f
    8000298c:	8dd9                	or	a1,a1,a4
    8000298e:	02000537          	lui	a0,0x2000
    80002992:	157d                	addi	a0,a0,-1
    80002994:	0536                	slli	a0,a0,0xd
    80002996:	9782                	jalr	a5
}
    80002998:	60a2                	ld	ra,8(sp)
    8000299a:	6402                	ld	s0,0(sp)
    8000299c:	0141                	addi	sp,sp,16
    8000299e:	8082                	ret

00000000800029a0 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800029a0:	1101                	addi	sp,sp,-32
    800029a2:	ec06                	sd	ra,24(sp)
    800029a4:	e822                	sd	s0,16(sp)
    800029a6:	e426                	sd	s1,8(sp)
    800029a8:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800029aa:	00014497          	auipc	s1,0x14
    800029ae:	72648493          	addi	s1,s1,1830 # 800170d0 <tickslock>
    800029b2:	8526                	mv	a0,s1
    800029b4:	ffffe097          	auipc	ra,0xffffe
    800029b8:	230080e7          	jalr	560(ra) # 80000be4 <acquire>
  ticks++;
    800029bc:	00006517          	auipc	a0,0x6
    800029c0:	67450513          	addi	a0,a0,1652 # 80009030 <ticks>
    800029c4:	411c                	lw	a5,0(a0)
    800029c6:	2785                	addiw	a5,a5,1
    800029c8:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800029ca:	00000097          	auipc	ra,0x0
    800029ce:	82e080e7          	jalr	-2002(ra) # 800021f8 <wakeup>
  release(&tickslock);
    800029d2:	8526                	mv	a0,s1
    800029d4:	ffffe097          	auipc	ra,0xffffe
    800029d8:	2c4080e7          	jalr	708(ra) # 80000c98 <release>
}
    800029dc:	60e2                	ld	ra,24(sp)
    800029de:	6442                	ld	s0,16(sp)
    800029e0:	64a2                	ld	s1,8(sp)
    800029e2:	6105                	addi	sp,sp,32
    800029e4:	8082                	ret

00000000800029e6 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800029e6:	1101                	addi	sp,sp,-32
    800029e8:	ec06                	sd	ra,24(sp)
    800029ea:	e822                	sd	s0,16(sp)
    800029ec:	e426                	sd	s1,8(sp)
    800029ee:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029f0:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800029f4:	00074d63          	bltz	a4,80002a0e <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    800029f8:	57fd                	li	a5,-1
    800029fa:	17fe                	slli	a5,a5,0x3f
    800029fc:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800029fe:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002a00:	06f70363          	beq	a4,a5,80002a66 <devintr+0x80>
  }
}
    80002a04:	60e2                	ld	ra,24(sp)
    80002a06:	6442                	ld	s0,16(sp)
    80002a08:	64a2                	ld	s1,8(sp)
    80002a0a:	6105                	addi	sp,sp,32
    80002a0c:	8082                	ret
     (scause & 0xff) == 9){
    80002a0e:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002a12:	46a5                	li	a3,9
    80002a14:	fed792e3          	bne	a5,a3,800029f8 <devintr+0x12>
    int irq = plic_claim();
    80002a18:	00003097          	auipc	ra,0x3
    80002a1c:	560080e7          	jalr	1376(ra) # 80005f78 <plic_claim>
    80002a20:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002a22:	47a9                	li	a5,10
    80002a24:	02f50763          	beq	a0,a5,80002a52 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002a28:	4785                	li	a5,1
    80002a2a:	02f50963          	beq	a0,a5,80002a5c <devintr+0x76>
    return 1;
    80002a2e:	4505                	li	a0,1
    } else if(irq){
    80002a30:	d8f1                	beqz	s1,80002a04 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002a32:	85a6                	mv	a1,s1
    80002a34:	00006517          	auipc	a0,0x6
    80002a38:	90c50513          	addi	a0,a0,-1780 # 80008340 <states.1714+0x38>
    80002a3c:	ffffe097          	auipc	ra,0xffffe
    80002a40:	b4c080e7          	jalr	-1204(ra) # 80000588 <printf>
      plic_complete(irq);
    80002a44:	8526                	mv	a0,s1
    80002a46:	00003097          	auipc	ra,0x3
    80002a4a:	556080e7          	jalr	1366(ra) # 80005f9c <plic_complete>
    return 1;
    80002a4e:	4505                	li	a0,1
    80002a50:	bf55                	j	80002a04 <devintr+0x1e>
      uartintr();
    80002a52:	ffffe097          	auipc	ra,0xffffe
    80002a56:	f56080e7          	jalr	-170(ra) # 800009a8 <uartintr>
    80002a5a:	b7ed                	j	80002a44 <devintr+0x5e>
      virtio_disk_intr();
    80002a5c:	00004097          	auipc	ra,0x4
    80002a60:	a20080e7          	jalr	-1504(ra) # 8000647c <virtio_disk_intr>
    80002a64:	b7c5                	j	80002a44 <devintr+0x5e>
    if(cpuid() == 0){
    80002a66:	fffff097          	auipc	ra,0xfffff
    80002a6a:	f1e080e7          	jalr	-226(ra) # 80001984 <cpuid>
    80002a6e:	c901                	beqz	a0,80002a7e <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002a70:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002a74:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002a76:	14479073          	csrw	sip,a5
    return 2;
    80002a7a:	4509                	li	a0,2
    80002a7c:	b761                	j	80002a04 <devintr+0x1e>
      clockintr();
    80002a7e:	00000097          	auipc	ra,0x0
    80002a82:	f22080e7          	jalr	-222(ra) # 800029a0 <clockintr>
    80002a86:	b7ed                	j	80002a70 <devintr+0x8a>

0000000080002a88 <usertrap>:
{
    80002a88:	1101                	addi	sp,sp,-32
    80002a8a:	ec06                	sd	ra,24(sp)
    80002a8c:	e822                	sd	s0,16(sp)
    80002a8e:	e426                	sd	s1,8(sp)
    80002a90:	e04a                	sd	s2,0(sp)
    80002a92:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a94:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002a98:	1007f793          	andi	a5,a5,256
    80002a9c:	e3ad                	bnez	a5,80002afe <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a9e:	00003797          	auipc	a5,0x3
    80002aa2:	3d278793          	addi	a5,a5,978 # 80005e70 <kernelvec>
    80002aa6:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002aaa:	fffff097          	auipc	ra,0xfffff
    80002aae:	f06080e7          	jalr	-250(ra) # 800019b0 <myproc>
    80002ab2:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002ab4:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ab6:	14102773          	csrr	a4,sepc
    80002aba:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002abc:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002ac0:	47a1                	li	a5,8
    80002ac2:	04f71c63          	bne	a4,a5,80002b1a <usertrap+0x92>
    if(p->killed)
    80002ac6:	551c                	lw	a5,40(a0)
    80002ac8:	e3b9                	bnez	a5,80002b0e <usertrap+0x86>
    p->trapframe->epc += 4;
    80002aca:	6cb8                	ld	a4,88(s1)
    80002acc:	6f1c                	ld	a5,24(a4)
    80002ace:	0791                	addi	a5,a5,4
    80002ad0:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ad2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002ad6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ada:	10079073          	csrw	sstatus,a5
    syscall();
    80002ade:	00000097          	auipc	ra,0x0
    80002ae2:	2e0080e7          	jalr	736(ra) # 80002dbe <syscall>
  if(p->killed)
    80002ae6:	549c                	lw	a5,40(s1)
    80002ae8:	ebc1                	bnez	a5,80002b78 <usertrap+0xf0>
  usertrapret();
    80002aea:	00000097          	auipc	ra,0x0
    80002aee:	e18080e7          	jalr	-488(ra) # 80002902 <usertrapret>
}
    80002af2:	60e2                	ld	ra,24(sp)
    80002af4:	6442                	ld	s0,16(sp)
    80002af6:	64a2                	ld	s1,8(sp)
    80002af8:	6902                	ld	s2,0(sp)
    80002afa:	6105                	addi	sp,sp,32
    80002afc:	8082                	ret
    panic("usertrap: not from user mode");
    80002afe:	00006517          	auipc	a0,0x6
    80002b02:	86250513          	addi	a0,a0,-1950 # 80008360 <states.1714+0x58>
    80002b06:	ffffe097          	auipc	ra,0xffffe
    80002b0a:	a38080e7          	jalr	-1480(ra) # 8000053e <panic>
      exit(-1);
    80002b0e:	557d                	li	a0,-1
    80002b10:	fffff097          	auipc	ra,0xfffff
    80002b14:	7b8080e7          	jalr	1976(ra) # 800022c8 <exit>
    80002b18:	bf4d                	j	80002aca <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002b1a:	00000097          	auipc	ra,0x0
    80002b1e:	ecc080e7          	jalr	-308(ra) # 800029e6 <devintr>
    80002b22:	892a                	mv	s2,a0
    80002b24:	c501                	beqz	a0,80002b2c <usertrap+0xa4>
  if(p->killed)
    80002b26:	549c                	lw	a5,40(s1)
    80002b28:	c3a1                	beqz	a5,80002b68 <usertrap+0xe0>
    80002b2a:	a815                	j	80002b5e <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b2c:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002b30:	5890                	lw	a2,48(s1)
    80002b32:	00006517          	auipc	a0,0x6
    80002b36:	84e50513          	addi	a0,a0,-1970 # 80008380 <states.1714+0x78>
    80002b3a:	ffffe097          	auipc	ra,0xffffe
    80002b3e:	a4e080e7          	jalr	-1458(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b42:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b46:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002b4a:	00006517          	auipc	a0,0x6
    80002b4e:	86650513          	addi	a0,a0,-1946 # 800083b0 <states.1714+0xa8>
    80002b52:	ffffe097          	auipc	ra,0xffffe
    80002b56:	a36080e7          	jalr	-1482(ra) # 80000588 <printf>
    p->killed = 1;
    80002b5a:	4785                	li	a5,1
    80002b5c:	d49c                	sw	a5,40(s1)
    exit(-1);
    80002b5e:	557d                	li	a0,-1
    80002b60:	fffff097          	auipc	ra,0xfffff
    80002b64:	768080e7          	jalr	1896(ra) # 800022c8 <exit>
  if(which_dev == 2)
    80002b68:	4789                	li	a5,2
    80002b6a:	f8f910e3          	bne	s2,a5,80002aea <usertrap+0x62>
    yield();
    80002b6e:	fffff097          	auipc	ra,0xfffff
    80002b72:	4c2080e7          	jalr	1218(ra) # 80002030 <yield>
    80002b76:	bf95                	j	80002aea <usertrap+0x62>
  int which_dev = 0;
    80002b78:	4901                	li	s2,0
    80002b7a:	b7d5                	j	80002b5e <usertrap+0xd6>

0000000080002b7c <kerneltrap>:
{
    80002b7c:	7179                	addi	sp,sp,-48
    80002b7e:	f406                	sd	ra,40(sp)
    80002b80:	f022                	sd	s0,32(sp)
    80002b82:	ec26                	sd	s1,24(sp)
    80002b84:	e84a                	sd	s2,16(sp)
    80002b86:	e44e                	sd	s3,8(sp)
    80002b88:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b8a:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b8e:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b92:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002b96:	1004f793          	andi	a5,s1,256
    80002b9a:	cb85                	beqz	a5,80002bca <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b9c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002ba0:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002ba2:	ef85                	bnez	a5,80002bda <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002ba4:	00000097          	auipc	ra,0x0
    80002ba8:	e42080e7          	jalr	-446(ra) # 800029e6 <devintr>
    80002bac:	cd1d                	beqz	a0,80002bea <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002bae:	4789                	li	a5,2
    80002bb0:	06f50a63          	beq	a0,a5,80002c24 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002bb4:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002bb8:	10049073          	csrw	sstatus,s1
}
    80002bbc:	70a2                	ld	ra,40(sp)
    80002bbe:	7402                	ld	s0,32(sp)
    80002bc0:	64e2                	ld	s1,24(sp)
    80002bc2:	6942                	ld	s2,16(sp)
    80002bc4:	69a2                	ld	s3,8(sp)
    80002bc6:	6145                	addi	sp,sp,48
    80002bc8:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002bca:	00006517          	auipc	a0,0x6
    80002bce:	80650513          	addi	a0,a0,-2042 # 800083d0 <states.1714+0xc8>
    80002bd2:	ffffe097          	auipc	ra,0xffffe
    80002bd6:	96c080e7          	jalr	-1684(ra) # 8000053e <panic>
    panic("kerneltrap: interrupts enabled");
    80002bda:	00006517          	auipc	a0,0x6
    80002bde:	81e50513          	addi	a0,a0,-2018 # 800083f8 <states.1714+0xf0>
    80002be2:	ffffe097          	auipc	ra,0xffffe
    80002be6:	95c080e7          	jalr	-1700(ra) # 8000053e <panic>
    printf("scause %p\n", scause);
    80002bea:	85ce                	mv	a1,s3
    80002bec:	00006517          	auipc	a0,0x6
    80002bf0:	82c50513          	addi	a0,a0,-2004 # 80008418 <states.1714+0x110>
    80002bf4:	ffffe097          	auipc	ra,0xffffe
    80002bf8:	994080e7          	jalr	-1644(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bfc:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c00:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c04:	00006517          	auipc	a0,0x6
    80002c08:	82450513          	addi	a0,a0,-2012 # 80008428 <states.1714+0x120>
    80002c0c:	ffffe097          	auipc	ra,0xffffe
    80002c10:	97c080e7          	jalr	-1668(ra) # 80000588 <printf>
    panic("kerneltrap");
    80002c14:	00006517          	auipc	a0,0x6
    80002c18:	82c50513          	addi	a0,a0,-2004 # 80008440 <states.1714+0x138>
    80002c1c:	ffffe097          	auipc	ra,0xffffe
    80002c20:	922080e7          	jalr	-1758(ra) # 8000053e <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002c24:	fffff097          	auipc	ra,0xfffff
    80002c28:	d8c080e7          	jalr	-628(ra) # 800019b0 <myproc>
    80002c2c:	d541                	beqz	a0,80002bb4 <kerneltrap+0x38>
    80002c2e:	fffff097          	auipc	ra,0xfffff
    80002c32:	d82080e7          	jalr	-638(ra) # 800019b0 <myproc>
    80002c36:	4d18                	lw	a4,24(a0)
    80002c38:	4791                	li	a5,4
    80002c3a:	f6f71de3          	bne	a4,a5,80002bb4 <kerneltrap+0x38>
    yield();
    80002c3e:	fffff097          	auipc	ra,0xfffff
    80002c42:	3f2080e7          	jalr	1010(ra) # 80002030 <yield>
    80002c46:	b7bd                	j	80002bb4 <kerneltrap+0x38>

0000000080002c48 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002c48:	1101                	addi	sp,sp,-32
    80002c4a:	ec06                	sd	ra,24(sp)
    80002c4c:	e822                	sd	s0,16(sp)
    80002c4e:	e426                	sd	s1,8(sp)
    80002c50:	1000                	addi	s0,sp,32
    80002c52:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002c54:	fffff097          	auipc	ra,0xfffff
    80002c58:	d5c080e7          	jalr	-676(ra) # 800019b0 <myproc>
  switch (n) {
    80002c5c:	4795                	li	a5,5
    80002c5e:	0497e163          	bltu	a5,s1,80002ca0 <argraw+0x58>
    80002c62:	048a                	slli	s1,s1,0x2
    80002c64:	00006717          	auipc	a4,0x6
    80002c68:	81470713          	addi	a4,a4,-2028 # 80008478 <states.1714+0x170>
    80002c6c:	94ba                	add	s1,s1,a4
    80002c6e:	409c                	lw	a5,0(s1)
    80002c70:	97ba                	add	a5,a5,a4
    80002c72:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002c74:	6d3c                	ld	a5,88(a0)
    80002c76:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002c78:	60e2                	ld	ra,24(sp)
    80002c7a:	6442                	ld	s0,16(sp)
    80002c7c:	64a2                	ld	s1,8(sp)
    80002c7e:	6105                	addi	sp,sp,32
    80002c80:	8082                	ret
    return p->trapframe->a1;
    80002c82:	6d3c                	ld	a5,88(a0)
    80002c84:	7fa8                	ld	a0,120(a5)
    80002c86:	bfcd                	j	80002c78 <argraw+0x30>
    return p->trapframe->a2;
    80002c88:	6d3c                	ld	a5,88(a0)
    80002c8a:	63c8                	ld	a0,128(a5)
    80002c8c:	b7f5                	j	80002c78 <argraw+0x30>
    return p->trapframe->a3;
    80002c8e:	6d3c                	ld	a5,88(a0)
    80002c90:	67c8                	ld	a0,136(a5)
    80002c92:	b7dd                	j	80002c78 <argraw+0x30>
    return p->trapframe->a4;
    80002c94:	6d3c                	ld	a5,88(a0)
    80002c96:	6bc8                	ld	a0,144(a5)
    80002c98:	b7c5                	j	80002c78 <argraw+0x30>
    return p->trapframe->a5;
    80002c9a:	6d3c                	ld	a5,88(a0)
    80002c9c:	6fc8                	ld	a0,152(a5)
    80002c9e:	bfe9                	j	80002c78 <argraw+0x30>
  panic("argraw");
    80002ca0:	00005517          	auipc	a0,0x5
    80002ca4:	7b050513          	addi	a0,a0,1968 # 80008450 <states.1714+0x148>
    80002ca8:	ffffe097          	auipc	ra,0xffffe
    80002cac:	896080e7          	jalr	-1898(ra) # 8000053e <panic>

0000000080002cb0 <fetchaddr>:
{
    80002cb0:	1101                	addi	sp,sp,-32
    80002cb2:	ec06                	sd	ra,24(sp)
    80002cb4:	e822                	sd	s0,16(sp)
    80002cb6:	e426                	sd	s1,8(sp)
    80002cb8:	e04a                	sd	s2,0(sp)
    80002cba:	1000                	addi	s0,sp,32
    80002cbc:	84aa                	mv	s1,a0
    80002cbe:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002cc0:	fffff097          	auipc	ra,0xfffff
    80002cc4:	cf0080e7          	jalr	-784(ra) # 800019b0 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002cc8:	653c                	ld	a5,72(a0)
    80002cca:	02f4f863          	bgeu	s1,a5,80002cfa <fetchaddr+0x4a>
    80002cce:	00848713          	addi	a4,s1,8
    80002cd2:	02e7e663          	bltu	a5,a4,80002cfe <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002cd6:	46a1                	li	a3,8
    80002cd8:	8626                	mv	a2,s1
    80002cda:	85ca                	mv	a1,s2
    80002cdc:	6928                	ld	a0,80(a0)
    80002cde:	fffff097          	auipc	ra,0xfffff
    80002ce2:	a20080e7          	jalr	-1504(ra) # 800016fe <copyin>
    80002ce6:	00a03533          	snez	a0,a0
    80002cea:	40a00533          	neg	a0,a0
}
    80002cee:	60e2                	ld	ra,24(sp)
    80002cf0:	6442                	ld	s0,16(sp)
    80002cf2:	64a2                	ld	s1,8(sp)
    80002cf4:	6902                	ld	s2,0(sp)
    80002cf6:	6105                	addi	sp,sp,32
    80002cf8:	8082                	ret
    return -1;
    80002cfa:	557d                	li	a0,-1
    80002cfc:	bfcd                	j	80002cee <fetchaddr+0x3e>
    80002cfe:	557d                	li	a0,-1
    80002d00:	b7fd                	j	80002cee <fetchaddr+0x3e>

0000000080002d02 <fetchstr>:
{
    80002d02:	7179                	addi	sp,sp,-48
    80002d04:	f406                	sd	ra,40(sp)
    80002d06:	f022                	sd	s0,32(sp)
    80002d08:	ec26                	sd	s1,24(sp)
    80002d0a:	e84a                	sd	s2,16(sp)
    80002d0c:	e44e                	sd	s3,8(sp)
    80002d0e:	1800                	addi	s0,sp,48
    80002d10:	892a                	mv	s2,a0
    80002d12:	84ae                	mv	s1,a1
    80002d14:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002d16:	fffff097          	auipc	ra,0xfffff
    80002d1a:	c9a080e7          	jalr	-870(ra) # 800019b0 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002d1e:	86ce                	mv	a3,s3
    80002d20:	864a                	mv	a2,s2
    80002d22:	85a6                	mv	a1,s1
    80002d24:	6928                	ld	a0,80(a0)
    80002d26:	fffff097          	auipc	ra,0xfffff
    80002d2a:	a64080e7          	jalr	-1436(ra) # 8000178a <copyinstr>
  if(err < 0)
    80002d2e:	00054763          	bltz	a0,80002d3c <fetchstr+0x3a>
  return strlen(buf);
    80002d32:	8526                	mv	a0,s1
    80002d34:	ffffe097          	auipc	ra,0xffffe
    80002d38:	130080e7          	jalr	304(ra) # 80000e64 <strlen>
}
    80002d3c:	70a2                	ld	ra,40(sp)
    80002d3e:	7402                	ld	s0,32(sp)
    80002d40:	64e2                	ld	s1,24(sp)
    80002d42:	6942                	ld	s2,16(sp)
    80002d44:	69a2                	ld	s3,8(sp)
    80002d46:	6145                	addi	sp,sp,48
    80002d48:	8082                	ret

0000000080002d4a <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002d4a:	1101                	addi	sp,sp,-32
    80002d4c:	ec06                	sd	ra,24(sp)
    80002d4e:	e822                	sd	s0,16(sp)
    80002d50:	e426                	sd	s1,8(sp)
    80002d52:	1000                	addi	s0,sp,32
    80002d54:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d56:	00000097          	auipc	ra,0x0
    80002d5a:	ef2080e7          	jalr	-270(ra) # 80002c48 <argraw>
    80002d5e:	c088                	sw	a0,0(s1)
  return 0;
}
    80002d60:	4501                	li	a0,0
    80002d62:	60e2                	ld	ra,24(sp)
    80002d64:	6442                	ld	s0,16(sp)
    80002d66:	64a2                	ld	s1,8(sp)
    80002d68:	6105                	addi	sp,sp,32
    80002d6a:	8082                	ret

0000000080002d6c <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002d6c:	1101                	addi	sp,sp,-32
    80002d6e:	ec06                	sd	ra,24(sp)
    80002d70:	e822                	sd	s0,16(sp)
    80002d72:	e426                	sd	s1,8(sp)
    80002d74:	1000                	addi	s0,sp,32
    80002d76:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d78:	00000097          	auipc	ra,0x0
    80002d7c:	ed0080e7          	jalr	-304(ra) # 80002c48 <argraw>
    80002d80:	e088                	sd	a0,0(s1)
  return 0;
}
    80002d82:	4501                	li	a0,0
    80002d84:	60e2                	ld	ra,24(sp)
    80002d86:	6442                	ld	s0,16(sp)
    80002d88:	64a2                	ld	s1,8(sp)
    80002d8a:	6105                	addi	sp,sp,32
    80002d8c:	8082                	ret

0000000080002d8e <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002d8e:	1101                	addi	sp,sp,-32
    80002d90:	ec06                	sd	ra,24(sp)
    80002d92:	e822                	sd	s0,16(sp)
    80002d94:	e426                	sd	s1,8(sp)
    80002d96:	e04a                	sd	s2,0(sp)
    80002d98:	1000                	addi	s0,sp,32
    80002d9a:	84ae                	mv	s1,a1
    80002d9c:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002d9e:	00000097          	auipc	ra,0x0
    80002da2:	eaa080e7          	jalr	-342(ra) # 80002c48 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002da6:	864a                	mv	a2,s2
    80002da8:	85a6                	mv	a1,s1
    80002daa:	00000097          	auipc	ra,0x0
    80002dae:	f58080e7          	jalr	-168(ra) # 80002d02 <fetchstr>
}
    80002db2:	60e2                	ld	ra,24(sp)
    80002db4:	6442                	ld	s0,16(sp)
    80002db6:	64a2                	ld	s1,8(sp)
    80002db8:	6902                	ld	s2,0(sp)
    80002dba:	6105                	addi	sp,sp,32
    80002dbc:	8082                	ret

0000000080002dbe <syscall>:
[SYS_cps]  sys_cps,
};

void
syscall(void)
{
    80002dbe:	1101                	addi	sp,sp,-32
    80002dc0:	ec06                	sd	ra,24(sp)
    80002dc2:	e822                	sd	s0,16(sp)
    80002dc4:	e426                	sd	s1,8(sp)
    80002dc6:	e04a                	sd	s2,0(sp)
    80002dc8:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002dca:	fffff097          	auipc	ra,0xfffff
    80002dce:	be6080e7          	jalr	-1050(ra) # 800019b0 <myproc>
    80002dd2:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002dd4:	05853903          	ld	s2,88(a0)
    80002dd8:	0a893783          	ld	a5,168(s2)
    80002ddc:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002de0:	37fd                	addiw	a5,a5,-1
    80002de2:	4765                	li	a4,25
    80002de4:	00f76f63          	bltu	a4,a5,80002e02 <syscall+0x44>
    80002de8:	00369713          	slli	a4,a3,0x3
    80002dec:	00005797          	auipc	a5,0x5
    80002df0:	6a478793          	addi	a5,a5,1700 # 80008490 <syscalls>
    80002df4:	97ba                	add	a5,a5,a4
    80002df6:	639c                	ld	a5,0(a5)
    80002df8:	c789                	beqz	a5,80002e02 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002dfa:	9782                	jalr	a5
    80002dfc:	06a93823          	sd	a0,112(s2)
    80002e00:	a839                	j	80002e1e <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002e02:	15848613          	addi	a2,s1,344
    80002e06:	588c                	lw	a1,48(s1)
    80002e08:	00005517          	auipc	a0,0x5
    80002e0c:	65050513          	addi	a0,a0,1616 # 80008458 <states.1714+0x150>
    80002e10:	ffffd097          	auipc	ra,0xffffd
    80002e14:	778080e7          	jalr	1912(ra) # 80000588 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002e18:	6cbc                	ld	a5,88(s1)
    80002e1a:	577d                	li	a4,-1
    80002e1c:	fbb8                	sd	a4,112(a5)
  }
}
    80002e1e:	60e2                	ld	ra,24(sp)
    80002e20:	6442                	ld	s0,16(sp)
    80002e22:	64a2                	ld	s1,8(sp)
    80002e24:	6902                	ld	s2,0(sp)
    80002e26:	6105                	addi	sp,sp,32
    80002e28:	8082                	ret

0000000080002e2a <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002e2a:	1101                	addi	sp,sp,-32
    80002e2c:	ec06                	sd	ra,24(sp)
    80002e2e:	e822                	sd	s0,16(sp)
    80002e30:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002e32:	fec40593          	addi	a1,s0,-20
    80002e36:	4501                	li	a0,0
    80002e38:	00000097          	auipc	ra,0x0
    80002e3c:	f12080e7          	jalr	-238(ra) # 80002d4a <argint>
    return -1;
    80002e40:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002e42:	00054963          	bltz	a0,80002e54 <sys_exit+0x2a>
  exit(n);
    80002e46:	fec42503          	lw	a0,-20(s0)
    80002e4a:	fffff097          	auipc	ra,0xfffff
    80002e4e:	47e080e7          	jalr	1150(ra) # 800022c8 <exit>
  return 0;  // not reached
    80002e52:	4781                	li	a5,0
}
    80002e54:	853e                	mv	a0,a5
    80002e56:	60e2                	ld	ra,24(sp)
    80002e58:	6442                	ld	s0,16(sp)
    80002e5a:	6105                	addi	sp,sp,32
    80002e5c:	8082                	ret

0000000080002e5e <sys_getpid>:

uint64
sys_getpid(void)
{
    80002e5e:	1141                	addi	sp,sp,-16
    80002e60:	e406                	sd	ra,8(sp)
    80002e62:	e022                	sd	s0,0(sp)
    80002e64:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002e66:	fffff097          	auipc	ra,0xfffff
    80002e6a:	b4a080e7          	jalr	-1206(ra) # 800019b0 <myproc>
}
    80002e6e:	5908                	lw	a0,48(a0)
    80002e70:	60a2                	ld	ra,8(sp)
    80002e72:	6402                	ld	s0,0(sp)
    80002e74:	0141                	addi	sp,sp,16
    80002e76:	8082                	ret

0000000080002e78 <sys_fork>:

uint64
sys_fork(void)
{
    80002e78:	1141                	addi	sp,sp,-16
    80002e7a:	e406                	sd	ra,8(sp)
    80002e7c:	e022                	sd	s0,0(sp)
    80002e7e:	0800                	addi	s0,sp,16
  return fork();
    80002e80:	fffff097          	auipc	ra,0xfffff
    80002e84:	efe080e7          	jalr	-258(ra) # 80001d7e <fork>
}
    80002e88:	60a2                	ld	ra,8(sp)
    80002e8a:	6402                	ld	s0,0(sp)
    80002e8c:	0141                	addi	sp,sp,16
    80002e8e:	8082                	ret

0000000080002e90 <sys_wait>:

uint64
sys_wait(void)
{
    80002e90:	1101                	addi	sp,sp,-32
    80002e92:	ec06                	sd	ra,24(sp)
    80002e94:	e822                	sd	s0,16(sp)
    80002e96:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002e98:	fe840593          	addi	a1,s0,-24
    80002e9c:	4501                	li	a0,0
    80002e9e:	00000097          	auipc	ra,0x0
    80002ea2:	ece080e7          	jalr	-306(ra) # 80002d6c <argaddr>
    80002ea6:	87aa                	mv	a5,a0
    return -1;
    80002ea8:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002eaa:	0007c863          	bltz	a5,80002eba <sys_wait+0x2a>
  return wait(p);
    80002eae:	fe843503          	ld	a0,-24(s0)
    80002eb2:	fffff097          	auipc	ra,0xfffff
    80002eb6:	21e080e7          	jalr	542(ra) # 800020d0 <wait>
}
    80002eba:	60e2                	ld	ra,24(sp)
    80002ebc:	6442                	ld	s0,16(sp)
    80002ebe:	6105                	addi	sp,sp,32
    80002ec0:	8082                	ret

0000000080002ec2 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002ec2:	7179                	addi	sp,sp,-48
    80002ec4:	f406                	sd	ra,40(sp)
    80002ec6:	f022                	sd	s0,32(sp)
    80002ec8:	ec26                	sd	s1,24(sp)
    80002eca:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002ecc:	fdc40593          	addi	a1,s0,-36
    80002ed0:	4501                	li	a0,0
    80002ed2:	00000097          	auipc	ra,0x0
    80002ed6:	e78080e7          	jalr	-392(ra) # 80002d4a <argint>
    80002eda:	87aa                	mv	a5,a0
    return -1;
    80002edc:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002ede:	0207c063          	bltz	a5,80002efe <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80002ee2:	fffff097          	auipc	ra,0xfffff
    80002ee6:	ace080e7          	jalr	-1330(ra) # 800019b0 <myproc>
    80002eea:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002eec:	fdc42503          	lw	a0,-36(s0)
    80002ef0:	fffff097          	auipc	ra,0xfffff
    80002ef4:	e1a080e7          	jalr	-486(ra) # 80001d0a <growproc>
    80002ef8:	00054863          	bltz	a0,80002f08 <sys_sbrk+0x46>
    return -1;
  return addr;
    80002efc:	8526                	mv	a0,s1
}
    80002efe:	70a2                	ld	ra,40(sp)
    80002f00:	7402                	ld	s0,32(sp)
    80002f02:	64e2                	ld	s1,24(sp)
    80002f04:	6145                	addi	sp,sp,48
    80002f06:	8082                	ret
    return -1;
    80002f08:	557d                	li	a0,-1
    80002f0a:	bfd5                	j	80002efe <sys_sbrk+0x3c>

0000000080002f0c <sys_sleep>:

uint64
sys_sleep(void)
{
    80002f0c:	7139                	addi	sp,sp,-64
    80002f0e:	fc06                	sd	ra,56(sp)
    80002f10:	f822                	sd	s0,48(sp)
    80002f12:	f426                	sd	s1,40(sp)
    80002f14:	f04a                	sd	s2,32(sp)
    80002f16:	ec4e                	sd	s3,24(sp)
    80002f18:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002f1a:	fcc40593          	addi	a1,s0,-52
    80002f1e:	4501                	li	a0,0
    80002f20:	00000097          	auipc	ra,0x0
    80002f24:	e2a080e7          	jalr	-470(ra) # 80002d4a <argint>
    return -1;
    80002f28:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002f2a:	06054563          	bltz	a0,80002f94 <sys_sleep+0x88>
  acquire(&tickslock);
    80002f2e:	00014517          	auipc	a0,0x14
    80002f32:	1a250513          	addi	a0,a0,418 # 800170d0 <tickslock>
    80002f36:	ffffe097          	auipc	ra,0xffffe
    80002f3a:	cae080e7          	jalr	-850(ra) # 80000be4 <acquire>
  ticks0 = ticks;
    80002f3e:	00006917          	auipc	s2,0x6
    80002f42:	0f292903          	lw	s2,242(s2) # 80009030 <ticks>
  while(ticks - ticks0 < n){
    80002f46:	fcc42783          	lw	a5,-52(s0)
    80002f4a:	cf85                	beqz	a5,80002f82 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002f4c:	00014997          	auipc	s3,0x14
    80002f50:	18498993          	addi	s3,s3,388 # 800170d0 <tickslock>
    80002f54:	00006497          	auipc	s1,0x6
    80002f58:	0dc48493          	addi	s1,s1,220 # 80009030 <ticks>
    if(myproc()->killed){
    80002f5c:	fffff097          	auipc	ra,0xfffff
    80002f60:	a54080e7          	jalr	-1452(ra) # 800019b0 <myproc>
    80002f64:	551c                	lw	a5,40(a0)
    80002f66:	ef9d                	bnez	a5,80002fa4 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002f68:	85ce                	mv	a1,s3
    80002f6a:	8526                	mv	a0,s1
    80002f6c:	fffff097          	auipc	ra,0xfffff
    80002f70:	100080e7          	jalr	256(ra) # 8000206c <sleep>
  while(ticks - ticks0 < n){
    80002f74:	409c                	lw	a5,0(s1)
    80002f76:	412787bb          	subw	a5,a5,s2
    80002f7a:	fcc42703          	lw	a4,-52(s0)
    80002f7e:	fce7efe3          	bltu	a5,a4,80002f5c <sys_sleep+0x50>
  }
  release(&tickslock);
    80002f82:	00014517          	auipc	a0,0x14
    80002f86:	14e50513          	addi	a0,a0,334 # 800170d0 <tickslock>
    80002f8a:	ffffe097          	auipc	ra,0xffffe
    80002f8e:	d0e080e7          	jalr	-754(ra) # 80000c98 <release>
  return 0;
    80002f92:	4781                	li	a5,0
}
    80002f94:	853e                	mv	a0,a5
    80002f96:	70e2                	ld	ra,56(sp)
    80002f98:	7442                	ld	s0,48(sp)
    80002f9a:	74a2                	ld	s1,40(sp)
    80002f9c:	7902                	ld	s2,32(sp)
    80002f9e:	69e2                	ld	s3,24(sp)
    80002fa0:	6121                	addi	sp,sp,64
    80002fa2:	8082                	ret
      release(&tickslock);
    80002fa4:	00014517          	auipc	a0,0x14
    80002fa8:	12c50513          	addi	a0,a0,300 # 800170d0 <tickslock>
    80002fac:	ffffe097          	auipc	ra,0xffffe
    80002fb0:	cec080e7          	jalr	-788(ra) # 80000c98 <release>
      return -1;
    80002fb4:	57fd                	li	a5,-1
    80002fb6:	bff9                	j	80002f94 <sys_sleep+0x88>

0000000080002fb8 <sys_kill>:

uint64
sys_kill(void)
{
    80002fb8:	1101                	addi	sp,sp,-32
    80002fba:	ec06                	sd	ra,24(sp)
    80002fbc:	e822                	sd	s0,16(sp)
    80002fbe:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002fc0:	fec40593          	addi	a1,s0,-20
    80002fc4:	4501                	li	a0,0
    80002fc6:	00000097          	auipc	ra,0x0
    80002fca:	d84080e7          	jalr	-636(ra) # 80002d4a <argint>
    80002fce:	87aa                	mv	a5,a0
    return -1;
    80002fd0:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002fd2:	0007c863          	bltz	a5,80002fe2 <sys_kill+0x2a>
  return kill(pid);
    80002fd6:	fec42503          	lw	a0,-20(s0)
    80002fda:	fffff097          	auipc	ra,0xfffff
    80002fde:	3c4080e7          	jalr	964(ra) # 8000239e <kill>
}
    80002fe2:	60e2                	ld	ra,24(sp)
    80002fe4:	6442                	ld	s0,16(sp)
    80002fe6:	6105                	addi	sp,sp,32
    80002fe8:	8082                	ret

0000000080002fea <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002fea:	1101                	addi	sp,sp,-32
    80002fec:	ec06                	sd	ra,24(sp)
    80002fee:	e822                	sd	s0,16(sp)
    80002ff0:	e426                	sd	s1,8(sp)
    80002ff2:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002ff4:	00014517          	auipc	a0,0x14
    80002ff8:	0dc50513          	addi	a0,a0,220 # 800170d0 <tickslock>
    80002ffc:	ffffe097          	auipc	ra,0xffffe
    80003000:	be8080e7          	jalr	-1048(ra) # 80000be4 <acquire>
  xticks = ticks;
    80003004:	00006497          	auipc	s1,0x6
    80003008:	02c4a483          	lw	s1,44(s1) # 80009030 <ticks>
  release(&tickslock);
    8000300c:	00014517          	auipc	a0,0x14
    80003010:	0c450513          	addi	a0,a0,196 # 800170d0 <tickslock>
    80003014:	ffffe097          	auipc	ra,0xffffe
    80003018:	c84080e7          	jalr	-892(ra) # 80000c98 <release>
  return xticks;
}
    8000301c:	02049513          	slli	a0,s1,0x20
    80003020:	9101                	srli	a0,a0,0x20
    80003022:	60e2                	ld	ra,24(sp)
    80003024:	6442                	ld	s0,16(sp)
    80003026:	64a2                	ld	s1,8(sp)
    80003028:	6105                	addi	sp,sp,32
    8000302a:	8082                	ret

000000008000302c <sys_getppid>:

uint64
sys_getppid(void)
{
    8000302c:	1141                	addi	sp,sp,-16
    8000302e:	e406                	sd	ra,8(sp)
    80003030:	e022                	sd	s0,0(sp)
    80003032:	0800                	addi	s0,sp,16
  if(myproc()->parent)
    80003034:	fffff097          	auipc	ra,0xfffff
    80003038:	97c080e7          	jalr	-1668(ra) # 800019b0 <myproc>
    8000303c:	7d1c                	ld	a5,56(a0)
  return myproc()->parent->pid;

  return -1;
    8000303e:	557d                	li	a0,-1
  if(myproc()->parent)
    80003040:	c799                	beqz	a5,8000304e <sys_getppid+0x22>
  return myproc()->parent->pid;
    80003042:	fffff097          	auipc	ra,0xfffff
    80003046:	96e080e7          	jalr	-1682(ra) # 800019b0 <myproc>
    8000304a:	7d1c                	ld	a5,56(a0)
    8000304c:	5b88                	lw	a0,48(a5)
}
    8000304e:	60a2                	ld	ra,8(sp)
    80003050:	6402                	ld	s0,0(sp)
    80003052:	0141                	addi	sp,sp,16
    80003054:	8082                	ret

0000000080003056 <sys_yield>:

uint64
sys_yield(void)
{
    80003056:	1141                	addi	sp,sp,-16
    80003058:	e406                	sd	ra,8(sp)
    8000305a:	e022                	sd	s0,0(sp)
    8000305c:	0800                	addi	s0,sp,16
  yield();
    8000305e:	fffff097          	auipc	ra,0xfffff
    80003062:	fd2080e7          	jalr	-46(ra) # 80002030 <yield>
  return 0;
}
    80003066:	4501                	li	a0,0
    80003068:	60a2                	ld	ra,8(sp)
    8000306a:	6402                	ld	s0,0(sp)
    8000306c:	0141                	addi	sp,sp,16
    8000306e:	8082                	ret

0000000080003070 <sys_getpa>:

uint64
sys_getpa(void)
{
    80003070:	1101                	addi	sp,sp,-32
    80003072:	ec06                	sd	ra,24(sp)
    80003074:	e822                	sd	s0,16(sp)
    80003076:	1000                	addi	s0,sp,32
  uint64 A;
  if(argaddr(0, &A) < 0)
    80003078:	fe840593          	addi	a1,s0,-24
    8000307c:	4501                	li	a0,0
    8000307e:	00000097          	auipc	ra,0x0
    80003082:	cee080e7          	jalr	-786(ra) # 80002d6c <argaddr>
    80003086:	87aa                	mv	a5,a0
    return -1;
    80003088:	557d                	li	a0,-1
  if(argaddr(0, &A) < 0)
    8000308a:	0207cc63          	bltz	a5,800030c2 <sys_getpa+0x52>
  printf("%d\n",A);
    8000308e:	fe843583          	ld	a1,-24(s0)
    80003092:	00005517          	auipc	a0,0x5
    80003096:	3de50513          	addi	a0,a0,990 # 80008470 <states.1714+0x168>
    8000309a:	ffffd097          	auipc	ra,0xffffd
    8000309e:	4ee080e7          	jalr	1262(ra) # 80000588 <printf>
  return walkaddr(myproc()->pagetable, A) + (A & (PGSIZE - 1));
    800030a2:	fffff097          	auipc	ra,0xfffff
    800030a6:	90e080e7          	jalr	-1778(ra) # 800019b0 <myproc>
    800030aa:	fe843583          	ld	a1,-24(s0)
    800030ae:	6928                	ld	a0,80(a0)
    800030b0:	ffffe097          	auipc	ra,0xffffe
    800030b4:	fbe080e7          	jalr	-66(ra) # 8000106e <walkaddr>
    800030b8:	fe843783          	ld	a5,-24(s0)
    800030bc:	17d2                	slli	a5,a5,0x34
    800030be:	93d1                	srli	a5,a5,0x34
    800030c0:	953e                	add	a0,a0,a5
}
    800030c2:	60e2                	ld	ra,24(sp)
    800030c4:	6442                	ld	s0,16(sp)
    800030c6:	6105                	addi	sp,sp,32
    800030c8:	8082                	ret

00000000800030ca <sys_waitpid>:

uint64
sys_waitpid(void)
{
    800030ca:	1101                	addi	sp,sp,-32
    800030cc:	ec06                	sd	ra,24(sp)
    800030ce:	e822                	sd	s0,16(sp)
    800030d0:	1000                	addi	s0,sp,32
  int pid_inp;
  uint64 p;
  if(argaddr(1, &p) < 0)
    800030d2:	fe040593          	addi	a1,s0,-32
    800030d6:	4505                	li	a0,1
    800030d8:	00000097          	auipc	ra,0x0
    800030dc:	c94080e7          	jalr	-876(ra) # 80002d6c <argaddr>
    return -1;
    800030e0:	57fd                	li	a5,-1
  if(argaddr(1, &p) < 0)
    800030e2:	02054563          	bltz	a0,8000310c <sys_waitpid+0x42>
  if(argint(0, &pid_inp) < 0)
    800030e6:	fec40593          	addi	a1,s0,-20
    800030ea:	4501                	li	a0,0
    800030ec:	00000097          	auipc	ra,0x0
    800030f0:	c5e080e7          	jalr	-930(ra) # 80002d4a <argint>
    return -1;
    800030f4:	57fd                	li	a5,-1
  if(argint(0, &pid_inp) < 0)
    800030f6:	00054b63          	bltz	a0,8000310c <sys_waitpid+0x42>
  return waitpid(pid_inp,p);
    800030fa:	fe043583          	ld	a1,-32(s0)
    800030fe:	fec42503          	lw	a0,-20(s0)
    80003102:	fffff097          	auipc	ra,0xfffff
    80003106:	468080e7          	jalr	1128(ra) # 8000256a <waitpid>
    8000310a:	87aa                	mv	a5,a0
}
    8000310c:	853e                	mv	a0,a5
    8000310e:	60e2                	ld	ra,24(sp)
    80003110:	6442                	ld	s0,16(sp)
    80003112:	6105                	addi	sp,sp,32
    80003114:	8082                	ret

0000000080003116 <sys_cps>:

uint64
sys_cps(void)
{
    80003116:	1141                	addi	sp,sp,-16
    80003118:	e406                	sd	ra,8(sp)
    8000311a:	e022                	sd	s0,0(sp)
    8000311c:	0800                	addi	s0,sp,16
  return cps();
    8000311e:	fffff097          	auipc	ra,0xfffff
    80003122:	676080e7          	jalr	1654(ra) # 80002794 <cps>
    80003126:	60a2                	ld	ra,8(sp)
    80003128:	6402                	ld	s0,0(sp)
    8000312a:	0141                	addi	sp,sp,16
    8000312c:	8082                	ret

000000008000312e <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000312e:	7179                	addi	sp,sp,-48
    80003130:	f406                	sd	ra,40(sp)
    80003132:	f022                	sd	s0,32(sp)
    80003134:	ec26                	sd	s1,24(sp)
    80003136:	e84a                	sd	s2,16(sp)
    80003138:	e44e                	sd	s3,8(sp)
    8000313a:	e052                	sd	s4,0(sp)
    8000313c:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000313e:	00005597          	auipc	a1,0x5
    80003142:	42a58593          	addi	a1,a1,1066 # 80008568 <syscalls+0xd8>
    80003146:	00014517          	auipc	a0,0x14
    8000314a:	fa250513          	addi	a0,a0,-94 # 800170e8 <bcache>
    8000314e:	ffffe097          	auipc	ra,0xffffe
    80003152:	a06080e7          	jalr	-1530(ra) # 80000b54 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003156:	0001c797          	auipc	a5,0x1c
    8000315a:	f9278793          	addi	a5,a5,-110 # 8001f0e8 <bcache+0x8000>
    8000315e:	0001c717          	auipc	a4,0x1c
    80003162:	1f270713          	addi	a4,a4,498 # 8001f350 <bcache+0x8268>
    80003166:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000316a:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000316e:	00014497          	auipc	s1,0x14
    80003172:	f9248493          	addi	s1,s1,-110 # 80017100 <bcache+0x18>
    b->next = bcache.head.next;
    80003176:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003178:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000317a:	00005a17          	auipc	s4,0x5
    8000317e:	3f6a0a13          	addi	s4,s4,1014 # 80008570 <syscalls+0xe0>
    b->next = bcache.head.next;
    80003182:	2b893783          	ld	a5,696(s2)
    80003186:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003188:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000318c:	85d2                	mv	a1,s4
    8000318e:	01048513          	addi	a0,s1,16
    80003192:	00001097          	auipc	ra,0x1
    80003196:	4bc080e7          	jalr	1212(ra) # 8000464e <initsleeplock>
    bcache.head.next->prev = b;
    8000319a:	2b893783          	ld	a5,696(s2)
    8000319e:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800031a0:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800031a4:	45848493          	addi	s1,s1,1112
    800031a8:	fd349de3          	bne	s1,s3,80003182 <binit+0x54>
  }
}
    800031ac:	70a2                	ld	ra,40(sp)
    800031ae:	7402                	ld	s0,32(sp)
    800031b0:	64e2                	ld	s1,24(sp)
    800031b2:	6942                	ld	s2,16(sp)
    800031b4:	69a2                	ld	s3,8(sp)
    800031b6:	6a02                	ld	s4,0(sp)
    800031b8:	6145                	addi	sp,sp,48
    800031ba:	8082                	ret

00000000800031bc <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800031bc:	7179                	addi	sp,sp,-48
    800031be:	f406                	sd	ra,40(sp)
    800031c0:	f022                	sd	s0,32(sp)
    800031c2:	ec26                	sd	s1,24(sp)
    800031c4:	e84a                	sd	s2,16(sp)
    800031c6:	e44e                	sd	s3,8(sp)
    800031c8:	1800                	addi	s0,sp,48
    800031ca:	89aa                	mv	s3,a0
    800031cc:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    800031ce:	00014517          	auipc	a0,0x14
    800031d2:	f1a50513          	addi	a0,a0,-230 # 800170e8 <bcache>
    800031d6:	ffffe097          	auipc	ra,0xffffe
    800031da:	a0e080e7          	jalr	-1522(ra) # 80000be4 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800031de:	0001c497          	auipc	s1,0x1c
    800031e2:	1c24b483          	ld	s1,450(s1) # 8001f3a0 <bcache+0x82b8>
    800031e6:	0001c797          	auipc	a5,0x1c
    800031ea:	16a78793          	addi	a5,a5,362 # 8001f350 <bcache+0x8268>
    800031ee:	02f48f63          	beq	s1,a5,8000322c <bread+0x70>
    800031f2:	873e                	mv	a4,a5
    800031f4:	a021                	j	800031fc <bread+0x40>
    800031f6:	68a4                	ld	s1,80(s1)
    800031f8:	02e48a63          	beq	s1,a4,8000322c <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800031fc:	449c                	lw	a5,8(s1)
    800031fe:	ff379ce3          	bne	a5,s3,800031f6 <bread+0x3a>
    80003202:	44dc                	lw	a5,12(s1)
    80003204:	ff2799e3          	bne	a5,s2,800031f6 <bread+0x3a>
      b->refcnt++;
    80003208:	40bc                	lw	a5,64(s1)
    8000320a:	2785                	addiw	a5,a5,1
    8000320c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000320e:	00014517          	auipc	a0,0x14
    80003212:	eda50513          	addi	a0,a0,-294 # 800170e8 <bcache>
    80003216:	ffffe097          	auipc	ra,0xffffe
    8000321a:	a82080e7          	jalr	-1406(ra) # 80000c98 <release>
      acquiresleep(&b->lock);
    8000321e:	01048513          	addi	a0,s1,16
    80003222:	00001097          	auipc	ra,0x1
    80003226:	466080e7          	jalr	1126(ra) # 80004688 <acquiresleep>
      return b;
    8000322a:	a8b9                	j	80003288 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000322c:	0001c497          	auipc	s1,0x1c
    80003230:	16c4b483          	ld	s1,364(s1) # 8001f398 <bcache+0x82b0>
    80003234:	0001c797          	auipc	a5,0x1c
    80003238:	11c78793          	addi	a5,a5,284 # 8001f350 <bcache+0x8268>
    8000323c:	00f48863          	beq	s1,a5,8000324c <bread+0x90>
    80003240:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003242:	40bc                	lw	a5,64(s1)
    80003244:	cf81                	beqz	a5,8000325c <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003246:	64a4                	ld	s1,72(s1)
    80003248:	fee49de3          	bne	s1,a4,80003242 <bread+0x86>
  panic("bget: no buffers");
    8000324c:	00005517          	auipc	a0,0x5
    80003250:	32c50513          	addi	a0,a0,812 # 80008578 <syscalls+0xe8>
    80003254:	ffffd097          	auipc	ra,0xffffd
    80003258:	2ea080e7          	jalr	746(ra) # 8000053e <panic>
      b->dev = dev;
    8000325c:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    80003260:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80003264:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003268:	4785                	li	a5,1
    8000326a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000326c:	00014517          	auipc	a0,0x14
    80003270:	e7c50513          	addi	a0,a0,-388 # 800170e8 <bcache>
    80003274:	ffffe097          	auipc	ra,0xffffe
    80003278:	a24080e7          	jalr	-1500(ra) # 80000c98 <release>
      acquiresleep(&b->lock);
    8000327c:	01048513          	addi	a0,s1,16
    80003280:	00001097          	auipc	ra,0x1
    80003284:	408080e7          	jalr	1032(ra) # 80004688 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003288:	409c                	lw	a5,0(s1)
    8000328a:	cb89                	beqz	a5,8000329c <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000328c:	8526                	mv	a0,s1
    8000328e:	70a2                	ld	ra,40(sp)
    80003290:	7402                	ld	s0,32(sp)
    80003292:	64e2                	ld	s1,24(sp)
    80003294:	6942                	ld	s2,16(sp)
    80003296:	69a2                	ld	s3,8(sp)
    80003298:	6145                	addi	sp,sp,48
    8000329a:	8082                	ret
    virtio_disk_rw(b, 0);
    8000329c:	4581                	li	a1,0
    8000329e:	8526                	mv	a0,s1
    800032a0:	00003097          	auipc	ra,0x3
    800032a4:	f06080e7          	jalr	-250(ra) # 800061a6 <virtio_disk_rw>
    b->valid = 1;
    800032a8:	4785                	li	a5,1
    800032aa:	c09c                	sw	a5,0(s1)
  return b;
    800032ac:	b7c5                	j	8000328c <bread+0xd0>

00000000800032ae <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800032ae:	1101                	addi	sp,sp,-32
    800032b0:	ec06                	sd	ra,24(sp)
    800032b2:	e822                	sd	s0,16(sp)
    800032b4:	e426                	sd	s1,8(sp)
    800032b6:	1000                	addi	s0,sp,32
    800032b8:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800032ba:	0541                	addi	a0,a0,16
    800032bc:	00001097          	auipc	ra,0x1
    800032c0:	466080e7          	jalr	1126(ra) # 80004722 <holdingsleep>
    800032c4:	cd01                	beqz	a0,800032dc <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800032c6:	4585                	li	a1,1
    800032c8:	8526                	mv	a0,s1
    800032ca:	00003097          	auipc	ra,0x3
    800032ce:	edc080e7          	jalr	-292(ra) # 800061a6 <virtio_disk_rw>
}
    800032d2:	60e2                	ld	ra,24(sp)
    800032d4:	6442                	ld	s0,16(sp)
    800032d6:	64a2                	ld	s1,8(sp)
    800032d8:	6105                	addi	sp,sp,32
    800032da:	8082                	ret
    panic("bwrite");
    800032dc:	00005517          	auipc	a0,0x5
    800032e0:	2b450513          	addi	a0,a0,692 # 80008590 <syscalls+0x100>
    800032e4:	ffffd097          	auipc	ra,0xffffd
    800032e8:	25a080e7          	jalr	602(ra) # 8000053e <panic>

00000000800032ec <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800032ec:	1101                	addi	sp,sp,-32
    800032ee:	ec06                	sd	ra,24(sp)
    800032f0:	e822                	sd	s0,16(sp)
    800032f2:	e426                	sd	s1,8(sp)
    800032f4:	e04a                	sd	s2,0(sp)
    800032f6:	1000                	addi	s0,sp,32
    800032f8:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800032fa:	01050913          	addi	s2,a0,16
    800032fe:	854a                	mv	a0,s2
    80003300:	00001097          	auipc	ra,0x1
    80003304:	422080e7          	jalr	1058(ra) # 80004722 <holdingsleep>
    80003308:	c92d                	beqz	a0,8000337a <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000330a:	854a                	mv	a0,s2
    8000330c:	00001097          	auipc	ra,0x1
    80003310:	3d2080e7          	jalr	978(ra) # 800046de <releasesleep>

  acquire(&bcache.lock);
    80003314:	00014517          	auipc	a0,0x14
    80003318:	dd450513          	addi	a0,a0,-556 # 800170e8 <bcache>
    8000331c:	ffffe097          	auipc	ra,0xffffe
    80003320:	8c8080e7          	jalr	-1848(ra) # 80000be4 <acquire>
  b->refcnt--;
    80003324:	40bc                	lw	a5,64(s1)
    80003326:	37fd                	addiw	a5,a5,-1
    80003328:	0007871b          	sext.w	a4,a5
    8000332c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000332e:	eb05                	bnez	a4,8000335e <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003330:	68bc                	ld	a5,80(s1)
    80003332:	64b8                	ld	a4,72(s1)
    80003334:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003336:	64bc                	ld	a5,72(s1)
    80003338:	68b8                	ld	a4,80(s1)
    8000333a:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000333c:	0001c797          	auipc	a5,0x1c
    80003340:	dac78793          	addi	a5,a5,-596 # 8001f0e8 <bcache+0x8000>
    80003344:	2b87b703          	ld	a4,696(a5)
    80003348:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000334a:	0001c717          	auipc	a4,0x1c
    8000334e:	00670713          	addi	a4,a4,6 # 8001f350 <bcache+0x8268>
    80003352:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003354:	2b87b703          	ld	a4,696(a5)
    80003358:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000335a:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000335e:	00014517          	auipc	a0,0x14
    80003362:	d8a50513          	addi	a0,a0,-630 # 800170e8 <bcache>
    80003366:	ffffe097          	auipc	ra,0xffffe
    8000336a:	932080e7          	jalr	-1742(ra) # 80000c98 <release>
}
    8000336e:	60e2                	ld	ra,24(sp)
    80003370:	6442                	ld	s0,16(sp)
    80003372:	64a2                	ld	s1,8(sp)
    80003374:	6902                	ld	s2,0(sp)
    80003376:	6105                	addi	sp,sp,32
    80003378:	8082                	ret
    panic("brelse");
    8000337a:	00005517          	auipc	a0,0x5
    8000337e:	21e50513          	addi	a0,a0,542 # 80008598 <syscalls+0x108>
    80003382:	ffffd097          	auipc	ra,0xffffd
    80003386:	1bc080e7          	jalr	444(ra) # 8000053e <panic>

000000008000338a <bpin>:

void
bpin(struct buf *b) {
    8000338a:	1101                	addi	sp,sp,-32
    8000338c:	ec06                	sd	ra,24(sp)
    8000338e:	e822                	sd	s0,16(sp)
    80003390:	e426                	sd	s1,8(sp)
    80003392:	1000                	addi	s0,sp,32
    80003394:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003396:	00014517          	auipc	a0,0x14
    8000339a:	d5250513          	addi	a0,a0,-686 # 800170e8 <bcache>
    8000339e:	ffffe097          	auipc	ra,0xffffe
    800033a2:	846080e7          	jalr	-1978(ra) # 80000be4 <acquire>
  b->refcnt++;
    800033a6:	40bc                	lw	a5,64(s1)
    800033a8:	2785                	addiw	a5,a5,1
    800033aa:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800033ac:	00014517          	auipc	a0,0x14
    800033b0:	d3c50513          	addi	a0,a0,-708 # 800170e8 <bcache>
    800033b4:	ffffe097          	auipc	ra,0xffffe
    800033b8:	8e4080e7          	jalr	-1820(ra) # 80000c98 <release>
}
    800033bc:	60e2                	ld	ra,24(sp)
    800033be:	6442                	ld	s0,16(sp)
    800033c0:	64a2                	ld	s1,8(sp)
    800033c2:	6105                	addi	sp,sp,32
    800033c4:	8082                	ret

00000000800033c6 <bunpin>:

void
bunpin(struct buf *b) {
    800033c6:	1101                	addi	sp,sp,-32
    800033c8:	ec06                	sd	ra,24(sp)
    800033ca:	e822                	sd	s0,16(sp)
    800033cc:	e426                	sd	s1,8(sp)
    800033ce:	1000                	addi	s0,sp,32
    800033d0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800033d2:	00014517          	auipc	a0,0x14
    800033d6:	d1650513          	addi	a0,a0,-746 # 800170e8 <bcache>
    800033da:	ffffe097          	auipc	ra,0xffffe
    800033de:	80a080e7          	jalr	-2038(ra) # 80000be4 <acquire>
  b->refcnt--;
    800033e2:	40bc                	lw	a5,64(s1)
    800033e4:	37fd                	addiw	a5,a5,-1
    800033e6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800033e8:	00014517          	auipc	a0,0x14
    800033ec:	d0050513          	addi	a0,a0,-768 # 800170e8 <bcache>
    800033f0:	ffffe097          	auipc	ra,0xffffe
    800033f4:	8a8080e7          	jalr	-1880(ra) # 80000c98 <release>
}
    800033f8:	60e2                	ld	ra,24(sp)
    800033fa:	6442                	ld	s0,16(sp)
    800033fc:	64a2                	ld	s1,8(sp)
    800033fe:	6105                	addi	sp,sp,32
    80003400:	8082                	ret

0000000080003402 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003402:	1101                	addi	sp,sp,-32
    80003404:	ec06                	sd	ra,24(sp)
    80003406:	e822                	sd	s0,16(sp)
    80003408:	e426                	sd	s1,8(sp)
    8000340a:	e04a                	sd	s2,0(sp)
    8000340c:	1000                	addi	s0,sp,32
    8000340e:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003410:	00d5d59b          	srliw	a1,a1,0xd
    80003414:	0001c797          	auipc	a5,0x1c
    80003418:	3b07a783          	lw	a5,944(a5) # 8001f7c4 <sb+0x1c>
    8000341c:	9dbd                	addw	a1,a1,a5
    8000341e:	00000097          	auipc	ra,0x0
    80003422:	d9e080e7          	jalr	-610(ra) # 800031bc <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003426:	0074f713          	andi	a4,s1,7
    8000342a:	4785                	li	a5,1
    8000342c:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003430:	14ce                	slli	s1,s1,0x33
    80003432:	90d9                	srli	s1,s1,0x36
    80003434:	00950733          	add	a4,a0,s1
    80003438:	05874703          	lbu	a4,88(a4)
    8000343c:	00e7f6b3          	and	a3,a5,a4
    80003440:	c69d                	beqz	a3,8000346e <bfree+0x6c>
    80003442:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003444:	94aa                	add	s1,s1,a0
    80003446:	fff7c793          	not	a5,a5
    8000344a:	8ff9                	and	a5,a5,a4
    8000344c:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003450:	00001097          	auipc	ra,0x1
    80003454:	118080e7          	jalr	280(ra) # 80004568 <log_write>
  brelse(bp);
    80003458:	854a                	mv	a0,s2
    8000345a:	00000097          	auipc	ra,0x0
    8000345e:	e92080e7          	jalr	-366(ra) # 800032ec <brelse>
}
    80003462:	60e2                	ld	ra,24(sp)
    80003464:	6442                	ld	s0,16(sp)
    80003466:	64a2                	ld	s1,8(sp)
    80003468:	6902                	ld	s2,0(sp)
    8000346a:	6105                	addi	sp,sp,32
    8000346c:	8082                	ret
    panic("freeing free block");
    8000346e:	00005517          	auipc	a0,0x5
    80003472:	13250513          	addi	a0,a0,306 # 800085a0 <syscalls+0x110>
    80003476:	ffffd097          	auipc	ra,0xffffd
    8000347a:	0c8080e7          	jalr	200(ra) # 8000053e <panic>

000000008000347e <balloc>:
{
    8000347e:	711d                	addi	sp,sp,-96
    80003480:	ec86                	sd	ra,88(sp)
    80003482:	e8a2                	sd	s0,80(sp)
    80003484:	e4a6                	sd	s1,72(sp)
    80003486:	e0ca                	sd	s2,64(sp)
    80003488:	fc4e                	sd	s3,56(sp)
    8000348a:	f852                	sd	s4,48(sp)
    8000348c:	f456                	sd	s5,40(sp)
    8000348e:	f05a                	sd	s6,32(sp)
    80003490:	ec5e                	sd	s7,24(sp)
    80003492:	e862                	sd	s8,16(sp)
    80003494:	e466                	sd	s9,8(sp)
    80003496:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003498:	0001c797          	auipc	a5,0x1c
    8000349c:	3147a783          	lw	a5,788(a5) # 8001f7ac <sb+0x4>
    800034a0:	cbd1                	beqz	a5,80003534 <balloc+0xb6>
    800034a2:	8baa                	mv	s7,a0
    800034a4:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800034a6:	0001cb17          	auipc	s6,0x1c
    800034aa:	302b0b13          	addi	s6,s6,770 # 8001f7a8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034ae:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800034b0:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034b2:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800034b4:	6c89                	lui	s9,0x2
    800034b6:	a831                	j	800034d2 <balloc+0x54>
    brelse(bp);
    800034b8:	854a                	mv	a0,s2
    800034ba:	00000097          	auipc	ra,0x0
    800034be:	e32080e7          	jalr	-462(ra) # 800032ec <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800034c2:	015c87bb          	addw	a5,s9,s5
    800034c6:	00078a9b          	sext.w	s5,a5
    800034ca:	004b2703          	lw	a4,4(s6)
    800034ce:	06eaf363          	bgeu	s5,a4,80003534 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    800034d2:	41fad79b          	sraiw	a5,s5,0x1f
    800034d6:	0137d79b          	srliw	a5,a5,0x13
    800034da:	015787bb          	addw	a5,a5,s5
    800034de:	40d7d79b          	sraiw	a5,a5,0xd
    800034e2:	01cb2583          	lw	a1,28(s6)
    800034e6:	9dbd                	addw	a1,a1,a5
    800034e8:	855e                	mv	a0,s7
    800034ea:	00000097          	auipc	ra,0x0
    800034ee:	cd2080e7          	jalr	-814(ra) # 800031bc <bread>
    800034f2:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034f4:	004b2503          	lw	a0,4(s6)
    800034f8:	000a849b          	sext.w	s1,s5
    800034fc:	8662                	mv	a2,s8
    800034fe:	faa4fde3          	bgeu	s1,a0,800034b8 <balloc+0x3a>
      m = 1 << (bi % 8);
    80003502:	41f6579b          	sraiw	a5,a2,0x1f
    80003506:	01d7d69b          	srliw	a3,a5,0x1d
    8000350a:	00c6873b          	addw	a4,a3,a2
    8000350e:	00777793          	andi	a5,a4,7
    80003512:	9f95                	subw	a5,a5,a3
    80003514:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003518:	4037571b          	sraiw	a4,a4,0x3
    8000351c:	00e906b3          	add	a3,s2,a4
    80003520:	0586c683          	lbu	a3,88(a3)
    80003524:	00d7f5b3          	and	a1,a5,a3
    80003528:	cd91                	beqz	a1,80003544 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000352a:	2605                	addiw	a2,a2,1
    8000352c:	2485                	addiw	s1,s1,1
    8000352e:	fd4618e3          	bne	a2,s4,800034fe <balloc+0x80>
    80003532:	b759                	j	800034b8 <balloc+0x3a>
  panic("balloc: out of blocks");
    80003534:	00005517          	auipc	a0,0x5
    80003538:	08450513          	addi	a0,a0,132 # 800085b8 <syscalls+0x128>
    8000353c:	ffffd097          	auipc	ra,0xffffd
    80003540:	002080e7          	jalr	2(ra) # 8000053e <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003544:	974a                	add	a4,a4,s2
    80003546:	8fd5                	or	a5,a5,a3
    80003548:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    8000354c:	854a                	mv	a0,s2
    8000354e:	00001097          	auipc	ra,0x1
    80003552:	01a080e7          	jalr	26(ra) # 80004568 <log_write>
        brelse(bp);
    80003556:	854a                	mv	a0,s2
    80003558:	00000097          	auipc	ra,0x0
    8000355c:	d94080e7          	jalr	-620(ra) # 800032ec <brelse>
  bp = bread(dev, bno);
    80003560:	85a6                	mv	a1,s1
    80003562:	855e                	mv	a0,s7
    80003564:	00000097          	auipc	ra,0x0
    80003568:	c58080e7          	jalr	-936(ra) # 800031bc <bread>
    8000356c:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000356e:	40000613          	li	a2,1024
    80003572:	4581                	li	a1,0
    80003574:	05850513          	addi	a0,a0,88
    80003578:	ffffd097          	auipc	ra,0xffffd
    8000357c:	768080e7          	jalr	1896(ra) # 80000ce0 <memset>
  log_write(bp);
    80003580:	854a                	mv	a0,s2
    80003582:	00001097          	auipc	ra,0x1
    80003586:	fe6080e7          	jalr	-26(ra) # 80004568 <log_write>
  brelse(bp);
    8000358a:	854a                	mv	a0,s2
    8000358c:	00000097          	auipc	ra,0x0
    80003590:	d60080e7          	jalr	-672(ra) # 800032ec <brelse>
}
    80003594:	8526                	mv	a0,s1
    80003596:	60e6                	ld	ra,88(sp)
    80003598:	6446                	ld	s0,80(sp)
    8000359a:	64a6                	ld	s1,72(sp)
    8000359c:	6906                	ld	s2,64(sp)
    8000359e:	79e2                	ld	s3,56(sp)
    800035a0:	7a42                	ld	s4,48(sp)
    800035a2:	7aa2                	ld	s5,40(sp)
    800035a4:	7b02                	ld	s6,32(sp)
    800035a6:	6be2                	ld	s7,24(sp)
    800035a8:	6c42                	ld	s8,16(sp)
    800035aa:	6ca2                	ld	s9,8(sp)
    800035ac:	6125                	addi	sp,sp,96
    800035ae:	8082                	ret

00000000800035b0 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800035b0:	7179                	addi	sp,sp,-48
    800035b2:	f406                	sd	ra,40(sp)
    800035b4:	f022                	sd	s0,32(sp)
    800035b6:	ec26                	sd	s1,24(sp)
    800035b8:	e84a                	sd	s2,16(sp)
    800035ba:	e44e                	sd	s3,8(sp)
    800035bc:	e052                	sd	s4,0(sp)
    800035be:	1800                	addi	s0,sp,48
    800035c0:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800035c2:	47ad                	li	a5,11
    800035c4:	04b7fe63          	bgeu	a5,a1,80003620 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800035c8:	ff45849b          	addiw	s1,a1,-12
    800035cc:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800035d0:	0ff00793          	li	a5,255
    800035d4:	0ae7e363          	bltu	a5,a4,8000367a <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800035d8:	08052583          	lw	a1,128(a0)
    800035dc:	c5ad                	beqz	a1,80003646 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800035de:	00092503          	lw	a0,0(s2)
    800035e2:	00000097          	auipc	ra,0x0
    800035e6:	bda080e7          	jalr	-1062(ra) # 800031bc <bread>
    800035ea:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800035ec:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800035f0:	02049593          	slli	a1,s1,0x20
    800035f4:	9181                	srli	a1,a1,0x20
    800035f6:	058a                	slli	a1,a1,0x2
    800035f8:	00b784b3          	add	s1,a5,a1
    800035fc:	0004a983          	lw	s3,0(s1)
    80003600:	04098d63          	beqz	s3,8000365a <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003604:	8552                	mv	a0,s4
    80003606:	00000097          	auipc	ra,0x0
    8000360a:	ce6080e7          	jalr	-794(ra) # 800032ec <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000360e:	854e                	mv	a0,s3
    80003610:	70a2                	ld	ra,40(sp)
    80003612:	7402                	ld	s0,32(sp)
    80003614:	64e2                	ld	s1,24(sp)
    80003616:	6942                	ld	s2,16(sp)
    80003618:	69a2                	ld	s3,8(sp)
    8000361a:	6a02                	ld	s4,0(sp)
    8000361c:	6145                	addi	sp,sp,48
    8000361e:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003620:	02059493          	slli	s1,a1,0x20
    80003624:	9081                	srli	s1,s1,0x20
    80003626:	048a                	slli	s1,s1,0x2
    80003628:	94aa                	add	s1,s1,a0
    8000362a:	0504a983          	lw	s3,80(s1)
    8000362e:	fe0990e3          	bnez	s3,8000360e <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003632:	4108                	lw	a0,0(a0)
    80003634:	00000097          	auipc	ra,0x0
    80003638:	e4a080e7          	jalr	-438(ra) # 8000347e <balloc>
    8000363c:	0005099b          	sext.w	s3,a0
    80003640:	0534a823          	sw	s3,80(s1)
    80003644:	b7e9                	j	8000360e <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003646:	4108                	lw	a0,0(a0)
    80003648:	00000097          	auipc	ra,0x0
    8000364c:	e36080e7          	jalr	-458(ra) # 8000347e <balloc>
    80003650:	0005059b          	sext.w	a1,a0
    80003654:	08b92023          	sw	a1,128(s2)
    80003658:	b759                	j	800035de <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    8000365a:	00092503          	lw	a0,0(s2)
    8000365e:	00000097          	auipc	ra,0x0
    80003662:	e20080e7          	jalr	-480(ra) # 8000347e <balloc>
    80003666:	0005099b          	sext.w	s3,a0
    8000366a:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    8000366e:	8552                	mv	a0,s4
    80003670:	00001097          	auipc	ra,0x1
    80003674:	ef8080e7          	jalr	-264(ra) # 80004568 <log_write>
    80003678:	b771                	j	80003604 <bmap+0x54>
  panic("bmap: out of range");
    8000367a:	00005517          	auipc	a0,0x5
    8000367e:	f5650513          	addi	a0,a0,-170 # 800085d0 <syscalls+0x140>
    80003682:	ffffd097          	auipc	ra,0xffffd
    80003686:	ebc080e7          	jalr	-324(ra) # 8000053e <panic>

000000008000368a <iget>:
{
    8000368a:	7179                	addi	sp,sp,-48
    8000368c:	f406                	sd	ra,40(sp)
    8000368e:	f022                	sd	s0,32(sp)
    80003690:	ec26                	sd	s1,24(sp)
    80003692:	e84a                	sd	s2,16(sp)
    80003694:	e44e                	sd	s3,8(sp)
    80003696:	e052                	sd	s4,0(sp)
    80003698:	1800                	addi	s0,sp,48
    8000369a:	89aa                	mv	s3,a0
    8000369c:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000369e:	0001c517          	auipc	a0,0x1c
    800036a2:	12a50513          	addi	a0,a0,298 # 8001f7c8 <itable>
    800036a6:	ffffd097          	auipc	ra,0xffffd
    800036aa:	53e080e7          	jalr	1342(ra) # 80000be4 <acquire>
  empty = 0;
    800036ae:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800036b0:	0001c497          	auipc	s1,0x1c
    800036b4:	13048493          	addi	s1,s1,304 # 8001f7e0 <itable+0x18>
    800036b8:	0001e697          	auipc	a3,0x1e
    800036bc:	bb868693          	addi	a3,a3,-1096 # 80021270 <log>
    800036c0:	a039                	j	800036ce <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800036c2:	02090b63          	beqz	s2,800036f8 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800036c6:	08848493          	addi	s1,s1,136
    800036ca:	02d48a63          	beq	s1,a3,800036fe <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800036ce:	449c                	lw	a5,8(s1)
    800036d0:	fef059e3          	blez	a5,800036c2 <iget+0x38>
    800036d4:	4098                	lw	a4,0(s1)
    800036d6:	ff3716e3          	bne	a4,s3,800036c2 <iget+0x38>
    800036da:	40d8                	lw	a4,4(s1)
    800036dc:	ff4713e3          	bne	a4,s4,800036c2 <iget+0x38>
      ip->ref++;
    800036e0:	2785                	addiw	a5,a5,1
    800036e2:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800036e4:	0001c517          	auipc	a0,0x1c
    800036e8:	0e450513          	addi	a0,a0,228 # 8001f7c8 <itable>
    800036ec:	ffffd097          	auipc	ra,0xffffd
    800036f0:	5ac080e7          	jalr	1452(ra) # 80000c98 <release>
      return ip;
    800036f4:	8926                	mv	s2,s1
    800036f6:	a03d                	j	80003724 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800036f8:	f7f9                	bnez	a5,800036c6 <iget+0x3c>
    800036fa:	8926                	mv	s2,s1
    800036fc:	b7e9                	j	800036c6 <iget+0x3c>
  if(empty == 0)
    800036fe:	02090c63          	beqz	s2,80003736 <iget+0xac>
  ip->dev = dev;
    80003702:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003706:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000370a:	4785                	li	a5,1
    8000370c:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003710:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003714:	0001c517          	auipc	a0,0x1c
    80003718:	0b450513          	addi	a0,a0,180 # 8001f7c8 <itable>
    8000371c:	ffffd097          	auipc	ra,0xffffd
    80003720:	57c080e7          	jalr	1404(ra) # 80000c98 <release>
}
    80003724:	854a                	mv	a0,s2
    80003726:	70a2                	ld	ra,40(sp)
    80003728:	7402                	ld	s0,32(sp)
    8000372a:	64e2                	ld	s1,24(sp)
    8000372c:	6942                	ld	s2,16(sp)
    8000372e:	69a2                	ld	s3,8(sp)
    80003730:	6a02                	ld	s4,0(sp)
    80003732:	6145                	addi	sp,sp,48
    80003734:	8082                	ret
    panic("iget: no inodes");
    80003736:	00005517          	auipc	a0,0x5
    8000373a:	eb250513          	addi	a0,a0,-334 # 800085e8 <syscalls+0x158>
    8000373e:	ffffd097          	auipc	ra,0xffffd
    80003742:	e00080e7          	jalr	-512(ra) # 8000053e <panic>

0000000080003746 <fsinit>:
fsinit(int dev) {
    80003746:	7179                	addi	sp,sp,-48
    80003748:	f406                	sd	ra,40(sp)
    8000374a:	f022                	sd	s0,32(sp)
    8000374c:	ec26                	sd	s1,24(sp)
    8000374e:	e84a                	sd	s2,16(sp)
    80003750:	e44e                	sd	s3,8(sp)
    80003752:	1800                	addi	s0,sp,48
    80003754:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003756:	4585                	li	a1,1
    80003758:	00000097          	auipc	ra,0x0
    8000375c:	a64080e7          	jalr	-1436(ra) # 800031bc <bread>
    80003760:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003762:	0001c997          	auipc	s3,0x1c
    80003766:	04698993          	addi	s3,s3,70 # 8001f7a8 <sb>
    8000376a:	02000613          	li	a2,32
    8000376e:	05850593          	addi	a1,a0,88
    80003772:	854e                	mv	a0,s3
    80003774:	ffffd097          	auipc	ra,0xffffd
    80003778:	5cc080e7          	jalr	1484(ra) # 80000d40 <memmove>
  brelse(bp);
    8000377c:	8526                	mv	a0,s1
    8000377e:	00000097          	auipc	ra,0x0
    80003782:	b6e080e7          	jalr	-1170(ra) # 800032ec <brelse>
  if(sb.magic != FSMAGIC)
    80003786:	0009a703          	lw	a4,0(s3)
    8000378a:	102037b7          	lui	a5,0x10203
    8000378e:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003792:	02f71263          	bne	a4,a5,800037b6 <fsinit+0x70>
  initlog(dev, &sb);
    80003796:	0001c597          	auipc	a1,0x1c
    8000379a:	01258593          	addi	a1,a1,18 # 8001f7a8 <sb>
    8000379e:	854a                	mv	a0,s2
    800037a0:	00001097          	auipc	ra,0x1
    800037a4:	b4c080e7          	jalr	-1204(ra) # 800042ec <initlog>
}
    800037a8:	70a2                	ld	ra,40(sp)
    800037aa:	7402                	ld	s0,32(sp)
    800037ac:	64e2                	ld	s1,24(sp)
    800037ae:	6942                	ld	s2,16(sp)
    800037b0:	69a2                	ld	s3,8(sp)
    800037b2:	6145                	addi	sp,sp,48
    800037b4:	8082                	ret
    panic("invalid file system");
    800037b6:	00005517          	auipc	a0,0x5
    800037ba:	e4250513          	addi	a0,a0,-446 # 800085f8 <syscalls+0x168>
    800037be:	ffffd097          	auipc	ra,0xffffd
    800037c2:	d80080e7          	jalr	-640(ra) # 8000053e <panic>

00000000800037c6 <iinit>:
{
    800037c6:	7179                	addi	sp,sp,-48
    800037c8:	f406                	sd	ra,40(sp)
    800037ca:	f022                	sd	s0,32(sp)
    800037cc:	ec26                	sd	s1,24(sp)
    800037ce:	e84a                	sd	s2,16(sp)
    800037d0:	e44e                	sd	s3,8(sp)
    800037d2:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800037d4:	00005597          	auipc	a1,0x5
    800037d8:	e3c58593          	addi	a1,a1,-452 # 80008610 <syscalls+0x180>
    800037dc:	0001c517          	auipc	a0,0x1c
    800037e0:	fec50513          	addi	a0,a0,-20 # 8001f7c8 <itable>
    800037e4:	ffffd097          	auipc	ra,0xffffd
    800037e8:	370080e7          	jalr	880(ra) # 80000b54 <initlock>
  for(i = 0; i < NINODE; i++) {
    800037ec:	0001c497          	auipc	s1,0x1c
    800037f0:	00448493          	addi	s1,s1,4 # 8001f7f0 <itable+0x28>
    800037f4:	0001e997          	auipc	s3,0x1e
    800037f8:	a8c98993          	addi	s3,s3,-1396 # 80021280 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800037fc:	00005917          	auipc	s2,0x5
    80003800:	e1c90913          	addi	s2,s2,-484 # 80008618 <syscalls+0x188>
    80003804:	85ca                	mv	a1,s2
    80003806:	8526                	mv	a0,s1
    80003808:	00001097          	auipc	ra,0x1
    8000380c:	e46080e7          	jalr	-442(ra) # 8000464e <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003810:	08848493          	addi	s1,s1,136
    80003814:	ff3498e3          	bne	s1,s3,80003804 <iinit+0x3e>
}
    80003818:	70a2                	ld	ra,40(sp)
    8000381a:	7402                	ld	s0,32(sp)
    8000381c:	64e2                	ld	s1,24(sp)
    8000381e:	6942                	ld	s2,16(sp)
    80003820:	69a2                	ld	s3,8(sp)
    80003822:	6145                	addi	sp,sp,48
    80003824:	8082                	ret

0000000080003826 <ialloc>:
{
    80003826:	715d                	addi	sp,sp,-80
    80003828:	e486                	sd	ra,72(sp)
    8000382a:	e0a2                	sd	s0,64(sp)
    8000382c:	fc26                	sd	s1,56(sp)
    8000382e:	f84a                	sd	s2,48(sp)
    80003830:	f44e                	sd	s3,40(sp)
    80003832:	f052                	sd	s4,32(sp)
    80003834:	ec56                	sd	s5,24(sp)
    80003836:	e85a                	sd	s6,16(sp)
    80003838:	e45e                	sd	s7,8(sp)
    8000383a:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    8000383c:	0001c717          	auipc	a4,0x1c
    80003840:	f7872703          	lw	a4,-136(a4) # 8001f7b4 <sb+0xc>
    80003844:	4785                	li	a5,1
    80003846:	04e7fa63          	bgeu	a5,a4,8000389a <ialloc+0x74>
    8000384a:	8aaa                	mv	s5,a0
    8000384c:	8bae                	mv	s7,a1
    8000384e:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003850:	0001ca17          	auipc	s4,0x1c
    80003854:	f58a0a13          	addi	s4,s4,-168 # 8001f7a8 <sb>
    80003858:	00048b1b          	sext.w	s6,s1
    8000385c:	0044d593          	srli	a1,s1,0x4
    80003860:	018a2783          	lw	a5,24(s4)
    80003864:	9dbd                	addw	a1,a1,a5
    80003866:	8556                	mv	a0,s5
    80003868:	00000097          	auipc	ra,0x0
    8000386c:	954080e7          	jalr	-1708(ra) # 800031bc <bread>
    80003870:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003872:	05850993          	addi	s3,a0,88
    80003876:	00f4f793          	andi	a5,s1,15
    8000387a:	079a                	slli	a5,a5,0x6
    8000387c:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000387e:	00099783          	lh	a5,0(s3)
    80003882:	c785                	beqz	a5,800038aa <ialloc+0x84>
    brelse(bp);
    80003884:	00000097          	auipc	ra,0x0
    80003888:	a68080e7          	jalr	-1432(ra) # 800032ec <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000388c:	0485                	addi	s1,s1,1
    8000388e:	00ca2703          	lw	a4,12(s4)
    80003892:	0004879b          	sext.w	a5,s1
    80003896:	fce7e1e3          	bltu	a5,a4,80003858 <ialloc+0x32>
  panic("ialloc: no inodes");
    8000389a:	00005517          	auipc	a0,0x5
    8000389e:	d8650513          	addi	a0,a0,-634 # 80008620 <syscalls+0x190>
    800038a2:	ffffd097          	auipc	ra,0xffffd
    800038a6:	c9c080e7          	jalr	-868(ra) # 8000053e <panic>
      memset(dip, 0, sizeof(*dip));
    800038aa:	04000613          	li	a2,64
    800038ae:	4581                	li	a1,0
    800038b0:	854e                	mv	a0,s3
    800038b2:	ffffd097          	auipc	ra,0xffffd
    800038b6:	42e080e7          	jalr	1070(ra) # 80000ce0 <memset>
      dip->type = type;
    800038ba:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800038be:	854a                	mv	a0,s2
    800038c0:	00001097          	auipc	ra,0x1
    800038c4:	ca8080e7          	jalr	-856(ra) # 80004568 <log_write>
      brelse(bp);
    800038c8:	854a                	mv	a0,s2
    800038ca:	00000097          	auipc	ra,0x0
    800038ce:	a22080e7          	jalr	-1502(ra) # 800032ec <brelse>
      return iget(dev, inum);
    800038d2:	85da                	mv	a1,s6
    800038d4:	8556                	mv	a0,s5
    800038d6:	00000097          	auipc	ra,0x0
    800038da:	db4080e7          	jalr	-588(ra) # 8000368a <iget>
}
    800038de:	60a6                	ld	ra,72(sp)
    800038e0:	6406                	ld	s0,64(sp)
    800038e2:	74e2                	ld	s1,56(sp)
    800038e4:	7942                	ld	s2,48(sp)
    800038e6:	79a2                	ld	s3,40(sp)
    800038e8:	7a02                	ld	s4,32(sp)
    800038ea:	6ae2                	ld	s5,24(sp)
    800038ec:	6b42                	ld	s6,16(sp)
    800038ee:	6ba2                	ld	s7,8(sp)
    800038f0:	6161                	addi	sp,sp,80
    800038f2:	8082                	ret

00000000800038f4 <iupdate>:
{
    800038f4:	1101                	addi	sp,sp,-32
    800038f6:	ec06                	sd	ra,24(sp)
    800038f8:	e822                	sd	s0,16(sp)
    800038fa:	e426                	sd	s1,8(sp)
    800038fc:	e04a                	sd	s2,0(sp)
    800038fe:	1000                	addi	s0,sp,32
    80003900:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003902:	415c                	lw	a5,4(a0)
    80003904:	0047d79b          	srliw	a5,a5,0x4
    80003908:	0001c597          	auipc	a1,0x1c
    8000390c:	eb85a583          	lw	a1,-328(a1) # 8001f7c0 <sb+0x18>
    80003910:	9dbd                	addw	a1,a1,a5
    80003912:	4108                	lw	a0,0(a0)
    80003914:	00000097          	auipc	ra,0x0
    80003918:	8a8080e7          	jalr	-1880(ra) # 800031bc <bread>
    8000391c:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000391e:	05850793          	addi	a5,a0,88
    80003922:	40c8                	lw	a0,4(s1)
    80003924:	893d                	andi	a0,a0,15
    80003926:	051a                	slli	a0,a0,0x6
    80003928:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    8000392a:	04449703          	lh	a4,68(s1)
    8000392e:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003932:	04649703          	lh	a4,70(s1)
    80003936:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    8000393a:	04849703          	lh	a4,72(s1)
    8000393e:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003942:	04a49703          	lh	a4,74(s1)
    80003946:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    8000394a:	44f8                	lw	a4,76(s1)
    8000394c:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000394e:	03400613          	li	a2,52
    80003952:	05048593          	addi	a1,s1,80
    80003956:	0531                	addi	a0,a0,12
    80003958:	ffffd097          	auipc	ra,0xffffd
    8000395c:	3e8080e7          	jalr	1000(ra) # 80000d40 <memmove>
  log_write(bp);
    80003960:	854a                	mv	a0,s2
    80003962:	00001097          	auipc	ra,0x1
    80003966:	c06080e7          	jalr	-1018(ra) # 80004568 <log_write>
  brelse(bp);
    8000396a:	854a                	mv	a0,s2
    8000396c:	00000097          	auipc	ra,0x0
    80003970:	980080e7          	jalr	-1664(ra) # 800032ec <brelse>
}
    80003974:	60e2                	ld	ra,24(sp)
    80003976:	6442                	ld	s0,16(sp)
    80003978:	64a2                	ld	s1,8(sp)
    8000397a:	6902                	ld	s2,0(sp)
    8000397c:	6105                	addi	sp,sp,32
    8000397e:	8082                	ret

0000000080003980 <idup>:
{
    80003980:	1101                	addi	sp,sp,-32
    80003982:	ec06                	sd	ra,24(sp)
    80003984:	e822                	sd	s0,16(sp)
    80003986:	e426                	sd	s1,8(sp)
    80003988:	1000                	addi	s0,sp,32
    8000398a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000398c:	0001c517          	auipc	a0,0x1c
    80003990:	e3c50513          	addi	a0,a0,-452 # 8001f7c8 <itable>
    80003994:	ffffd097          	auipc	ra,0xffffd
    80003998:	250080e7          	jalr	592(ra) # 80000be4 <acquire>
  ip->ref++;
    8000399c:	449c                	lw	a5,8(s1)
    8000399e:	2785                	addiw	a5,a5,1
    800039a0:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800039a2:	0001c517          	auipc	a0,0x1c
    800039a6:	e2650513          	addi	a0,a0,-474 # 8001f7c8 <itable>
    800039aa:	ffffd097          	auipc	ra,0xffffd
    800039ae:	2ee080e7          	jalr	750(ra) # 80000c98 <release>
}
    800039b2:	8526                	mv	a0,s1
    800039b4:	60e2                	ld	ra,24(sp)
    800039b6:	6442                	ld	s0,16(sp)
    800039b8:	64a2                	ld	s1,8(sp)
    800039ba:	6105                	addi	sp,sp,32
    800039bc:	8082                	ret

00000000800039be <ilock>:
{
    800039be:	1101                	addi	sp,sp,-32
    800039c0:	ec06                	sd	ra,24(sp)
    800039c2:	e822                	sd	s0,16(sp)
    800039c4:	e426                	sd	s1,8(sp)
    800039c6:	e04a                	sd	s2,0(sp)
    800039c8:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800039ca:	c115                	beqz	a0,800039ee <ilock+0x30>
    800039cc:	84aa                	mv	s1,a0
    800039ce:	451c                	lw	a5,8(a0)
    800039d0:	00f05f63          	blez	a5,800039ee <ilock+0x30>
  acquiresleep(&ip->lock);
    800039d4:	0541                	addi	a0,a0,16
    800039d6:	00001097          	auipc	ra,0x1
    800039da:	cb2080e7          	jalr	-846(ra) # 80004688 <acquiresleep>
  if(ip->valid == 0){
    800039de:	40bc                	lw	a5,64(s1)
    800039e0:	cf99                	beqz	a5,800039fe <ilock+0x40>
}
    800039e2:	60e2                	ld	ra,24(sp)
    800039e4:	6442                	ld	s0,16(sp)
    800039e6:	64a2                	ld	s1,8(sp)
    800039e8:	6902                	ld	s2,0(sp)
    800039ea:	6105                	addi	sp,sp,32
    800039ec:	8082                	ret
    panic("ilock");
    800039ee:	00005517          	auipc	a0,0x5
    800039f2:	c4a50513          	addi	a0,a0,-950 # 80008638 <syscalls+0x1a8>
    800039f6:	ffffd097          	auipc	ra,0xffffd
    800039fa:	b48080e7          	jalr	-1208(ra) # 8000053e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800039fe:	40dc                	lw	a5,4(s1)
    80003a00:	0047d79b          	srliw	a5,a5,0x4
    80003a04:	0001c597          	auipc	a1,0x1c
    80003a08:	dbc5a583          	lw	a1,-580(a1) # 8001f7c0 <sb+0x18>
    80003a0c:	9dbd                	addw	a1,a1,a5
    80003a0e:	4088                	lw	a0,0(s1)
    80003a10:	fffff097          	auipc	ra,0xfffff
    80003a14:	7ac080e7          	jalr	1964(ra) # 800031bc <bread>
    80003a18:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003a1a:	05850593          	addi	a1,a0,88
    80003a1e:	40dc                	lw	a5,4(s1)
    80003a20:	8bbd                	andi	a5,a5,15
    80003a22:	079a                	slli	a5,a5,0x6
    80003a24:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003a26:	00059783          	lh	a5,0(a1)
    80003a2a:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003a2e:	00259783          	lh	a5,2(a1)
    80003a32:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003a36:	00459783          	lh	a5,4(a1)
    80003a3a:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003a3e:	00659783          	lh	a5,6(a1)
    80003a42:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003a46:	459c                	lw	a5,8(a1)
    80003a48:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003a4a:	03400613          	li	a2,52
    80003a4e:	05b1                	addi	a1,a1,12
    80003a50:	05048513          	addi	a0,s1,80
    80003a54:	ffffd097          	auipc	ra,0xffffd
    80003a58:	2ec080e7          	jalr	748(ra) # 80000d40 <memmove>
    brelse(bp);
    80003a5c:	854a                	mv	a0,s2
    80003a5e:	00000097          	auipc	ra,0x0
    80003a62:	88e080e7          	jalr	-1906(ra) # 800032ec <brelse>
    ip->valid = 1;
    80003a66:	4785                	li	a5,1
    80003a68:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003a6a:	04449783          	lh	a5,68(s1)
    80003a6e:	fbb5                	bnez	a5,800039e2 <ilock+0x24>
      panic("ilock: no type");
    80003a70:	00005517          	auipc	a0,0x5
    80003a74:	bd050513          	addi	a0,a0,-1072 # 80008640 <syscalls+0x1b0>
    80003a78:	ffffd097          	auipc	ra,0xffffd
    80003a7c:	ac6080e7          	jalr	-1338(ra) # 8000053e <panic>

0000000080003a80 <iunlock>:
{
    80003a80:	1101                	addi	sp,sp,-32
    80003a82:	ec06                	sd	ra,24(sp)
    80003a84:	e822                	sd	s0,16(sp)
    80003a86:	e426                	sd	s1,8(sp)
    80003a88:	e04a                	sd	s2,0(sp)
    80003a8a:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003a8c:	c905                	beqz	a0,80003abc <iunlock+0x3c>
    80003a8e:	84aa                	mv	s1,a0
    80003a90:	01050913          	addi	s2,a0,16
    80003a94:	854a                	mv	a0,s2
    80003a96:	00001097          	auipc	ra,0x1
    80003a9a:	c8c080e7          	jalr	-884(ra) # 80004722 <holdingsleep>
    80003a9e:	cd19                	beqz	a0,80003abc <iunlock+0x3c>
    80003aa0:	449c                	lw	a5,8(s1)
    80003aa2:	00f05d63          	blez	a5,80003abc <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003aa6:	854a                	mv	a0,s2
    80003aa8:	00001097          	auipc	ra,0x1
    80003aac:	c36080e7          	jalr	-970(ra) # 800046de <releasesleep>
}
    80003ab0:	60e2                	ld	ra,24(sp)
    80003ab2:	6442                	ld	s0,16(sp)
    80003ab4:	64a2                	ld	s1,8(sp)
    80003ab6:	6902                	ld	s2,0(sp)
    80003ab8:	6105                	addi	sp,sp,32
    80003aba:	8082                	ret
    panic("iunlock");
    80003abc:	00005517          	auipc	a0,0x5
    80003ac0:	b9450513          	addi	a0,a0,-1132 # 80008650 <syscalls+0x1c0>
    80003ac4:	ffffd097          	auipc	ra,0xffffd
    80003ac8:	a7a080e7          	jalr	-1414(ra) # 8000053e <panic>

0000000080003acc <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003acc:	7179                	addi	sp,sp,-48
    80003ace:	f406                	sd	ra,40(sp)
    80003ad0:	f022                	sd	s0,32(sp)
    80003ad2:	ec26                	sd	s1,24(sp)
    80003ad4:	e84a                	sd	s2,16(sp)
    80003ad6:	e44e                	sd	s3,8(sp)
    80003ad8:	e052                	sd	s4,0(sp)
    80003ada:	1800                	addi	s0,sp,48
    80003adc:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003ade:	05050493          	addi	s1,a0,80
    80003ae2:	08050913          	addi	s2,a0,128
    80003ae6:	a021                	j	80003aee <itrunc+0x22>
    80003ae8:	0491                	addi	s1,s1,4
    80003aea:	01248d63          	beq	s1,s2,80003b04 <itrunc+0x38>
    if(ip->addrs[i]){
    80003aee:	408c                	lw	a1,0(s1)
    80003af0:	dde5                	beqz	a1,80003ae8 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003af2:	0009a503          	lw	a0,0(s3)
    80003af6:	00000097          	auipc	ra,0x0
    80003afa:	90c080e7          	jalr	-1780(ra) # 80003402 <bfree>
      ip->addrs[i] = 0;
    80003afe:	0004a023          	sw	zero,0(s1)
    80003b02:	b7dd                	j	80003ae8 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003b04:	0809a583          	lw	a1,128(s3)
    80003b08:	e185                	bnez	a1,80003b28 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003b0a:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003b0e:	854e                	mv	a0,s3
    80003b10:	00000097          	auipc	ra,0x0
    80003b14:	de4080e7          	jalr	-540(ra) # 800038f4 <iupdate>
}
    80003b18:	70a2                	ld	ra,40(sp)
    80003b1a:	7402                	ld	s0,32(sp)
    80003b1c:	64e2                	ld	s1,24(sp)
    80003b1e:	6942                	ld	s2,16(sp)
    80003b20:	69a2                	ld	s3,8(sp)
    80003b22:	6a02                	ld	s4,0(sp)
    80003b24:	6145                	addi	sp,sp,48
    80003b26:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003b28:	0009a503          	lw	a0,0(s3)
    80003b2c:	fffff097          	auipc	ra,0xfffff
    80003b30:	690080e7          	jalr	1680(ra) # 800031bc <bread>
    80003b34:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003b36:	05850493          	addi	s1,a0,88
    80003b3a:	45850913          	addi	s2,a0,1112
    80003b3e:	a811                	j	80003b52 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003b40:	0009a503          	lw	a0,0(s3)
    80003b44:	00000097          	auipc	ra,0x0
    80003b48:	8be080e7          	jalr	-1858(ra) # 80003402 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003b4c:	0491                	addi	s1,s1,4
    80003b4e:	01248563          	beq	s1,s2,80003b58 <itrunc+0x8c>
      if(a[j])
    80003b52:	408c                	lw	a1,0(s1)
    80003b54:	dde5                	beqz	a1,80003b4c <itrunc+0x80>
    80003b56:	b7ed                	j	80003b40 <itrunc+0x74>
    brelse(bp);
    80003b58:	8552                	mv	a0,s4
    80003b5a:	fffff097          	auipc	ra,0xfffff
    80003b5e:	792080e7          	jalr	1938(ra) # 800032ec <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003b62:	0809a583          	lw	a1,128(s3)
    80003b66:	0009a503          	lw	a0,0(s3)
    80003b6a:	00000097          	auipc	ra,0x0
    80003b6e:	898080e7          	jalr	-1896(ra) # 80003402 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003b72:	0809a023          	sw	zero,128(s3)
    80003b76:	bf51                	j	80003b0a <itrunc+0x3e>

0000000080003b78 <iput>:
{
    80003b78:	1101                	addi	sp,sp,-32
    80003b7a:	ec06                	sd	ra,24(sp)
    80003b7c:	e822                	sd	s0,16(sp)
    80003b7e:	e426                	sd	s1,8(sp)
    80003b80:	e04a                	sd	s2,0(sp)
    80003b82:	1000                	addi	s0,sp,32
    80003b84:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003b86:	0001c517          	auipc	a0,0x1c
    80003b8a:	c4250513          	addi	a0,a0,-958 # 8001f7c8 <itable>
    80003b8e:	ffffd097          	auipc	ra,0xffffd
    80003b92:	056080e7          	jalr	86(ra) # 80000be4 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b96:	4498                	lw	a4,8(s1)
    80003b98:	4785                	li	a5,1
    80003b9a:	02f70363          	beq	a4,a5,80003bc0 <iput+0x48>
  ip->ref--;
    80003b9e:	449c                	lw	a5,8(s1)
    80003ba0:	37fd                	addiw	a5,a5,-1
    80003ba2:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003ba4:	0001c517          	auipc	a0,0x1c
    80003ba8:	c2450513          	addi	a0,a0,-988 # 8001f7c8 <itable>
    80003bac:	ffffd097          	auipc	ra,0xffffd
    80003bb0:	0ec080e7          	jalr	236(ra) # 80000c98 <release>
}
    80003bb4:	60e2                	ld	ra,24(sp)
    80003bb6:	6442                	ld	s0,16(sp)
    80003bb8:	64a2                	ld	s1,8(sp)
    80003bba:	6902                	ld	s2,0(sp)
    80003bbc:	6105                	addi	sp,sp,32
    80003bbe:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003bc0:	40bc                	lw	a5,64(s1)
    80003bc2:	dff1                	beqz	a5,80003b9e <iput+0x26>
    80003bc4:	04a49783          	lh	a5,74(s1)
    80003bc8:	fbf9                	bnez	a5,80003b9e <iput+0x26>
    acquiresleep(&ip->lock);
    80003bca:	01048913          	addi	s2,s1,16
    80003bce:	854a                	mv	a0,s2
    80003bd0:	00001097          	auipc	ra,0x1
    80003bd4:	ab8080e7          	jalr	-1352(ra) # 80004688 <acquiresleep>
    release(&itable.lock);
    80003bd8:	0001c517          	auipc	a0,0x1c
    80003bdc:	bf050513          	addi	a0,a0,-1040 # 8001f7c8 <itable>
    80003be0:	ffffd097          	auipc	ra,0xffffd
    80003be4:	0b8080e7          	jalr	184(ra) # 80000c98 <release>
    itrunc(ip);
    80003be8:	8526                	mv	a0,s1
    80003bea:	00000097          	auipc	ra,0x0
    80003bee:	ee2080e7          	jalr	-286(ra) # 80003acc <itrunc>
    ip->type = 0;
    80003bf2:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003bf6:	8526                	mv	a0,s1
    80003bf8:	00000097          	auipc	ra,0x0
    80003bfc:	cfc080e7          	jalr	-772(ra) # 800038f4 <iupdate>
    ip->valid = 0;
    80003c00:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003c04:	854a                	mv	a0,s2
    80003c06:	00001097          	auipc	ra,0x1
    80003c0a:	ad8080e7          	jalr	-1320(ra) # 800046de <releasesleep>
    acquire(&itable.lock);
    80003c0e:	0001c517          	auipc	a0,0x1c
    80003c12:	bba50513          	addi	a0,a0,-1094 # 8001f7c8 <itable>
    80003c16:	ffffd097          	auipc	ra,0xffffd
    80003c1a:	fce080e7          	jalr	-50(ra) # 80000be4 <acquire>
    80003c1e:	b741                	j	80003b9e <iput+0x26>

0000000080003c20 <iunlockput>:
{
    80003c20:	1101                	addi	sp,sp,-32
    80003c22:	ec06                	sd	ra,24(sp)
    80003c24:	e822                	sd	s0,16(sp)
    80003c26:	e426                	sd	s1,8(sp)
    80003c28:	1000                	addi	s0,sp,32
    80003c2a:	84aa                	mv	s1,a0
  iunlock(ip);
    80003c2c:	00000097          	auipc	ra,0x0
    80003c30:	e54080e7          	jalr	-428(ra) # 80003a80 <iunlock>
  iput(ip);
    80003c34:	8526                	mv	a0,s1
    80003c36:	00000097          	auipc	ra,0x0
    80003c3a:	f42080e7          	jalr	-190(ra) # 80003b78 <iput>
}
    80003c3e:	60e2                	ld	ra,24(sp)
    80003c40:	6442                	ld	s0,16(sp)
    80003c42:	64a2                	ld	s1,8(sp)
    80003c44:	6105                	addi	sp,sp,32
    80003c46:	8082                	ret

0000000080003c48 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003c48:	1141                	addi	sp,sp,-16
    80003c4a:	e422                	sd	s0,8(sp)
    80003c4c:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003c4e:	411c                	lw	a5,0(a0)
    80003c50:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003c52:	415c                	lw	a5,4(a0)
    80003c54:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003c56:	04451783          	lh	a5,68(a0)
    80003c5a:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003c5e:	04a51783          	lh	a5,74(a0)
    80003c62:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003c66:	04c56783          	lwu	a5,76(a0)
    80003c6a:	e99c                	sd	a5,16(a1)
}
    80003c6c:	6422                	ld	s0,8(sp)
    80003c6e:	0141                	addi	sp,sp,16
    80003c70:	8082                	ret

0000000080003c72 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c72:	457c                	lw	a5,76(a0)
    80003c74:	0ed7e963          	bltu	a5,a3,80003d66 <readi+0xf4>
{
    80003c78:	7159                	addi	sp,sp,-112
    80003c7a:	f486                	sd	ra,104(sp)
    80003c7c:	f0a2                	sd	s0,96(sp)
    80003c7e:	eca6                	sd	s1,88(sp)
    80003c80:	e8ca                	sd	s2,80(sp)
    80003c82:	e4ce                	sd	s3,72(sp)
    80003c84:	e0d2                	sd	s4,64(sp)
    80003c86:	fc56                	sd	s5,56(sp)
    80003c88:	f85a                	sd	s6,48(sp)
    80003c8a:	f45e                	sd	s7,40(sp)
    80003c8c:	f062                	sd	s8,32(sp)
    80003c8e:	ec66                	sd	s9,24(sp)
    80003c90:	e86a                	sd	s10,16(sp)
    80003c92:	e46e                	sd	s11,8(sp)
    80003c94:	1880                	addi	s0,sp,112
    80003c96:	8baa                	mv	s7,a0
    80003c98:	8c2e                	mv	s8,a1
    80003c9a:	8ab2                	mv	s5,a2
    80003c9c:	84b6                	mv	s1,a3
    80003c9e:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003ca0:	9f35                	addw	a4,a4,a3
    return 0;
    80003ca2:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003ca4:	0ad76063          	bltu	a4,a3,80003d44 <readi+0xd2>
  if(off + n > ip->size)
    80003ca8:	00e7f463          	bgeu	a5,a4,80003cb0 <readi+0x3e>
    n = ip->size - off;
    80003cac:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003cb0:	0a0b0963          	beqz	s6,80003d62 <readi+0xf0>
    80003cb4:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cb6:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003cba:	5cfd                	li	s9,-1
    80003cbc:	a82d                	j	80003cf6 <readi+0x84>
    80003cbe:	020a1d93          	slli	s11,s4,0x20
    80003cc2:	020ddd93          	srli	s11,s11,0x20
    80003cc6:	05890613          	addi	a2,s2,88
    80003cca:	86ee                	mv	a3,s11
    80003ccc:	963a                	add	a2,a2,a4
    80003cce:	85d6                	mv	a1,s5
    80003cd0:	8562                	mv	a0,s8
    80003cd2:	ffffe097          	auipc	ra,0xffffe
    80003cd6:	73e080e7          	jalr	1854(ra) # 80002410 <either_copyout>
    80003cda:	05950d63          	beq	a0,s9,80003d34 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003cde:	854a                	mv	a0,s2
    80003ce0:	fffff097          	auipc	ra,0xfffff
    80003ce4:	60c080e7          	jalr	1548(ra) # 800032ec <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ce8:	013a09bb          	addw	s3,s4,s3
    80003cec:	009a04bb          	addw	s1,s4,s1
    80003cf0:	9aee                	add	s5,s5,s11
    80003cf2:	0569f763          	bgeu	s3,s6,80003d40 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003cf6:	000ba903          	lw	s2,0(s7)
    80003cfa:	00a4d59b          	srliw	a1,s1,0xa
    80003cfe:	855e                	mv	a0,s7
    80003d00:	00000097          	auipc	ra,0x0
    80003d04:	8b0080e7          	jalr	-1872(ra) # 800035b0 <bmap>
    80003d08:	0005059b          	sext.w	a1,a0
    80003d0c:	854a                	mv	a0,s2
    80003d0e:	fffff097          	auipc	ra,0xfffff
    80003d12:	4ae080e7          	jalr	1198(ra) # 800031bc <bread>
    80003d16:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d18:	3ff4f713          	andi	a4,s1,1023
    80003d1c:	40ed07bb          	subw	a5,s10,a4
    80003d20:	413b06bb          	subw	a3,s6,s3
    80003d24:	8a3e                	mv	s4,a5
    80003d26:	2781                	sext.w	a5,a5
    80003d28:	0006861b          	sext.w	a2,a3
    80003d2c:	f8f679e3          	bgeu	a2,a5,80003cbe <readi+0x4c>
    80003d30:	8a36                	mv	s4,a3
    80003d32:	b771                	j	80003cbe <readi+0x4c>
      brelse(bp);
    80003d34:	854a                	mv	a0,s2
    80003d36:	fffff097          	auipc	ra,0xfffff
    80003d3a:	5b6080e7          	jalr	1462(ra) # 800032ec <brelse>
      tot = -1;
    80003d3e:	59fd                	li	s3,-1
  }
  return tot;
    80003d40:	0009851b          	sext.w	a0,s3
}
    80003d44:	70a6                	ld	ra,104(sp)
    80003d46:	7406                	ld	s0,96(sp)
    80003d48:	64e6                	ld	s1,88(sp)
    80003d4a:	6946                	ld	s2,80(sp)
    80003d4c:	69a6                	ld	s3,72(sp)
    80003d4e:	6a06                	ld	s4,64(sp)
    80003d50:	7ae2                	ld	s5,56(sp)
    80003d52:	7b42                	ld	s6,48(sp)
    80003d54:	7ba2                	ld	s7,40(sp)
    80003d56:	7c02                	ld	s8,32(sp)
    80003d58:	6ce2                	ld	s9,24(sp)
    80003d5a:	6d42                	ld	s10,16(sp)
    80003d5c:	6da2                	ld	s11,8(sp)
    80003d5e:	6165                	addi	sp,sp,112
    80003d60:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d62:	89da                	mv	s3,s6
    80003d64:	bff1                	j	80003d40 <readi+0xce>
    return 0;
    80003d66:	4501                	li	a0,0
}
    80003d68:	8082                	ret

0000000080003d6a <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003d6a:	457c                	lw	a5,76(a0)
    80003d6c:	10d7e863          	bltu	a5,a3,80003e7c <writei+0x112>
{
    80003d70:	7159                	addi	sp,sp,-112
    80003d72:	f486                	sd	ra,104(sp)
    80003d74:	f0a2                	sd	s0,96(sp)
    80003d76:	eca6                	sd	s1,88(sp)
    80003d78:	e8ca                	sd	s2,80(sp)
    80003d7a:	e4ce                	sd	s3,72(sp)
    80003d7c:	e0d2                	sd	s4,64(sp)
    80003d7e:	fc56                	sd	s5,56(sp)
    80003d80:	f85a                	sd	s6,48(sp)
    80003d82:	f45e                	sd	s7,40(sp)
    80003d84:	f062                	sd	s8,32(sp)
    80003d86:	ec66                	sd	s9,24(sp)
    80003d88:	e86a                	sd	s10,16(sp)
    80003d8a:	e46e                	sd	s11,8(sp)
    80003d8c:	1880                	addi	s0,sp,112
    80003d8e:	8b2a                	mv	s6,a0
    80003d90:	8c2e                	mv	s8,a1
    80003d92:	8ab2                	mv	s5,a2
    80003d94:	8936                	mv	s2,a3
    80003d96:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80003d98:	00e687bb          	addw	a5,a3,a4
    80003d9c:	0ed7e263          	bltu	a5,a3,80003e80 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003da0:	00043737          	lui	a4,0x43
    80003da4:	0ef76063          	bltu	a4,a5,80003e84 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003da8:	0c0b8863          	beqz	s7,80003e78 <writei+0x10e>
    80003dac:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003dae:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003db2:	5cfd                	li	s9,-1
    80003db4:	a091                	j	80003df8 <writei+0x8e>
    80003db6:	02099d93          	slli	s11,s3,0x20
    80003dba:	020ddd93          	srli	s11,s11,0x20
    80003dbe:	05848513          	addi	a0,s1,88
    80003dc2:	86ee                	mv	a3,s11
    80003dc4:	8656                	mv	a2,s5
    80003dc6:	85e2                	mv	a1,s8
    80003dc8:	953a                	add	a0,a0,a4
    80003dca:	ffffe097          	auipc	ra,0xffffe
    80003dce:	69c080e7          	jalr	1692(ra) # 80002466 <either_copyin>
    80003dd2:	07950263          	beq	a0,s9,80003e36 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003dd6:	8526                	mv	a0,s1
    80003dd8:	00000097          	auipc	ra,0x0
    80003ddc:	790080e7          	jalr	1936(ra) # 80004568 <log_write>
    brelse(bp);
    80003de0:	8526                	mv	a0,s1
    80003de2:	fffff097          	auipc	ra,0xfffff
    80003de6:	50a080e7          	jalr	1290(ra) # 800032ec <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003dea:	01498a3b          	addw	s4,s3,s4
    80003dee:	0129893b          	addw	s2,s3,s2
    80003df2:	9aee                	add	s5,s5,s11
    80003df4:	057a7663          	bgeu	s4,s7,80003e40 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003df8:	000b2483          	lw	s1,0(s6)
    80003dfc:	00a9559b          	srliw	a1,s2,0xa
    80003e00:	855a                	mv	a0,s6
    80003e02:	fffff097          	auipc	ra,0xfffff
    80003e06:	7ae080e7          	jalr	1966(ra) # 800035b0 <bmap>
    80003e0a:	0005059b          	sext.w	a1,a0
    80003e0e:	8526                	mv	a0,s1
    80003e10:	fffff097          	auipc	ra,0xfffff
    80003e14:	3ac080e7          	jalr	940(ra) # 800031bc <bread>
    80003e18:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e1a:	3ff97713          	andi	a4,s2,1023
    80003e1e:	40ed07bb          	subw	a5,s10,a4
    80003e22:	414b86bb          	subw	a3,s7,s4
    80003e26:	89be                	mv	s3,a5
    80003e28:	2781                	sext.w	a5,a5
    80003e2a:	0006861b          	sext.w	a2,a3
    80003e2e:	f8f674e3          	bgeu	a2,a5,80003db6 <writei+0x4c>
    80003e32:	89b6                	mv	s3,a3
    80003e34:	b749                	j	80003db6 <writei+0x4c>
      brelse(bp);
    80003e36:	8526                	mv	a0,s1
    80003e38:	fffff097          	auipc	ra,0xfffff
    80003e3c:	4b4080e7          	jalr	1204(ra) # 800032ec <brelse>
  }

  if(off > ip->size)
    80003e40:	04cb2783          	lw	a5,76(s6)
    80003e44:	0127f463          	bgeu	a5,s2,80003e4c <writei+0xe2>
    ip->size = off;
    80003e48:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003e4c:	855a                	mv	a0,s6
    80003e4e:	00000097          	auipc	ra,0x0
    80003e52:	aa6080e7          	jalr	-1370(ra) # 800038f4 <iupdate>

  return tot;
    80003e56:	000a051b          	sext.w	a0,s4
}
    80003e5a:	70a6                	ld	ra,104(sp)
    80003e5c:	7406                	ld	s0,96(sp)
    80003e5e:	64e6                	ld	s1,88(sp)
    80003e60:	6946                	ld	s2,80(sp)
    80003e62:	69a6                	ld	s3,72(sp)
    80003e64:	6a06                	ld	s4,64(sp)
    80003e66:	7ae2                	ld	s5,56(sp)
    80003e68:	7b42                	ld	s6,48(sp)
    80003e6a:	7ba2                	ld	s7,40(sp)
    80003e6c:	7c02                	ld	s8,32(sp)
    80003e6e:	6ce2                	ld	s9,24(sp)
    80003e70:	6d42                	ld	s10,16(sp)
    80003e72:	6da2                	ld	s11,8(sp)
    80003e74:	6165                	addi	sp,sp,112
    80003e76:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e78:	8a5e                	mv	s4,s7
    80003e7a:	bfc9                	j	80003e4c <writei+0xe2>
    return -1;
    80003e7c:	557d                	li	a0,-1
}
    80003e7e:	8082                	ret
    return -1;
    80003e80:	557d                	li	a0,-1
    80003e82:	bfe1                	j	80003e5a <writei+0xf0>
    return -1;
    80003e84:	557d                	li	a0,-1
    80003e86:	bfd1                	j	80003e5a <writei+0xf0>

0000000080003e88 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003e88:	1141                	addi	sp,sp,-16
    80003e8a:	e406                	sd	ra,8(sp)
    80003e8c:	e022                	sd	s0,0(sp)
    80003e8e:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003e90:	4639                	li	a2,14
    80003e92:	ffffd097          	auipc	ra,0xffffd
    80003e96:	f26080e7          	jalr	-218(ra) # 80000db8 <strncmp>
}
    80003e9a:	60a2                	ld	ra,8(sp)
    80003e9c:	6402                	ld	s0,0(sp)
    80003e9e:	0141                	addi	sp,sp,16
    80003ea0:	8082                	ret

0000000080003ea2 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003ea2:	7139                	addi	sp,sp,-64
    80003ea4:	fc06                	sd	ra,56(sp)
    80003ea6:	f822                	sd	s0,48(sp)
    80003ea8:	f426                	sd	s1,40(sp)
    80003eaa:	f04a                	sd	s2,32(sp)
    80003eac:	ec4e                	sd	s3,24(sp)
    80003eae:	e852                	sd	s4,16(sp)
    80003eb0:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003eb2:	04451703          	lh	a4,68(a0)
    80003eb6:	4785                	li	a5,1
    80003eb8:	00f71a63          	bne	a4,a5,80003ecc <dirlookup+0x2a>
    80003ebc:	892a                	mv	s2,a0
    80003ebe:	89ae                	mv	s3,a1
    80003ec0:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ec2:	457c                	lw	a5,76(a0)
    80003ec4:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003ec6:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ec8:	e79d                	bnez	a5,80003ef6 <dirlookup+0x54>
    80003eca:	a8a5                	j	80003f42 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003ecc:	00004517          	auipc	a0,0x4
    80003ed0:	78c50513          	addi	a0,a0,1932 # 80008658 <syscalls+0x1c8>
    80003ed4:	ffffc097          	auipc	ra,0xffffc
    80003ed8:	66a080e7          	jalr	1642(ra) # 8000053e <panic>
      panic("dirlookup read");
    80003edc:	00004517          	auipc	a0,0x4
    80003ee0:	79450513          	addi	a0,a0,1940 # 80008670 <syscalls+0x1e0>
    80003ee4:	ffffc097          	auipc	ra,0xffffc
    80003ee8:	65a080e7          	jalr	1626(ra) # 8000053e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003eec:	24c1                	addiw	s1,s1,16
    80003eee:	04c92783          	lw	a5,76(s2)
    80003ef2:	04f4f763          	bgeu	s1,a5,80003f40 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ef6:	4741                	li	a4,16
    80003ef8:	86a6                	mv	a3,s1
    80003efa:	fc040613          	addi	a2,s0,-64
    80003efe:	4581                	li	a1,0
    80003f00:	854a                	mv	a0,s2
    80003f02:	00000097          	auipc	ra,0x0
    80003f06:	d70080e7          	jalr	-656(ra) # 80003c72 <readi>
    80003f0a:	47c1                	li	a5,16
    80003f0c:	fcf518e3          	bne	a0,a5,80003edc <dirlookup+0x3a>
    if(de.inum == 0)
    80003f10:	fc045783          	lhu	a5,-64(s0)
    80003f14:	dfe1                	beqz	a5,80003eec <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003f16:	fc240593          	addi	a1,s0,-62
    80003f1a:	854e                	mv	a0,s3
    80003f1c:	00000097          	auipc	ra,0x0
    80003f20:	f6c080e7          	jalr	-148(ra) # 80003e88 <namecmp>
    80003f24:	f561                	bnez	a0,80003eec <dirlookup+0x4a>
      if(poff)
    80003f26:	000a0463          	beqz	s4,80003f2e <dirlookup+0x8c>
        *poff = off;
    80003f2a:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003f2e:	fc045583          	lhu	a1,-64(s0)
    80003f32:	00092503          	lw	a0,0(s2)
    80003f36:	fffff097          	auipc	ra,0xfffff
    80003f3a:	754080e7          	jalr	1876(ra) # 8000368a <iget>
    80003f3e:	a011                	j	80003f42 <dirlookup+0xa0>
  return 0;
    80003f40:	4501                	li	a0,0
}
    80003f42:	70e2                	ld	ra,56(sp)
    80003f44:	7442                	ld	s0,48(sp)
    80003f46:	74a2                	ld	s1,40(sp)
    80003f48:	7902                	ld	s2,32(sp)
    80003f4a:	69e2                	ld	s3,24(sp)
    80003f4c:	6a42                	ld	s4,16(sp)
    80003f4e:	6121                	addi	sp,sp,64
    80003f50:	8082                	ret

0000000080003f52 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003f52:	711d                	addi	sp,sp,-96
    80003f54:	ec86                	sd	ra,88(sp)
    80003f56:	e8a2                	sd	s0,80(sp)
    80003f58:	e4a6                	sd	s1,72(sp)
    80003f5a:	e0ca                	sd	s2,64(sp)
    80003f5c:	fc4e                	sd	s3,56(sp)
    80003f5e:	f852                	sd	s4,48(sp)
    80003f60:	f456                	sd	s5,40(sp)
    80003f62:	f05a                	sd	s6,32(sp)
    80003f64:	ec5e                	sd	s7,24(sp)
    80003f66:	e862                	sd	s8,16(sp)
    80003f68:	e466                	sd	s9,8(sp)
    80003f6a:	1080                	addi	s0,sp,96
    80003f6c:	84aa                	mv	s1,a0
    80003f6e:	8b2e                	mv	s6,a1
    80003f70:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003f72:	00054703          	lbu	a4,0(a0)
    80003f76:	02f00793          	li	a5,47
    80003f7a:	02f70363          	beq	a4,a5,80003fa0 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003f7e:	ffffe097          	auipc	ra,0xffffe
    80003f82:	a32080e7          	jalr	-1486(ra) # 800019b0 <myproc>
    80003f86:	15053503          	ld	a0,336(a0)
    80003f8a:	00000097          	auipc	ra,0x0
    80003f8e:	9f6080e7          	jalr	-1546(ra) # 80003980 <idup>
    80003f92:	89aa                	mv	s3,a0
  while(*path == '/')
    80003f94:	02f00913          	li	s2,47
  len = path - s;
    80003f98:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80003f9a:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003f9c:	4c05                	li	s8,1
    80003f9e:	a865                	j	80004056 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003fa0:	4585                	li	a1,1
    80003fa2:	4505                	li	a0,1
    80003fa4:	fffff097          	auipc	ra,0xfffff
    80003fa8:	6e6080e7          	jalr	1766(ra) # 8000368a <iget>
    80003fac:	89aa                	mv	s3,a0
    80003fae:	b7dd                	j	80003f94 <namex+0x42>
      iunlockput(ip);
    80003fb0:	854e                	mv	a0,s3
    80003fb2:	00000097          	auipc	ra,0x0
    80003fb6:	c6e080e7          	jalr	-914(ra) # 80003c20 <iunlockput>
      return 0;
    80003fba:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003fbc:	854e                	mv	a0,s3
    80003fbe:	60e6                	ld	ra,88(sp)
    80003fc0:	6446                	ld	s0,80(sp)
    80003fc2:	64a6                	ld	s1,72(sp)
    80003fc4:	6906                	ld	s2,64(sp)
    80003fc6:	79e2                	ld	s3,56(sp)
    80003fc8:	7a42                	ld	s4,48(sp)
    80003fca:	7aa2                	ld	s5,40(sp)
    80003fcc:	7b02                	ld	s6,32(sp)
    80003fce:	6be2                	ld	s7,24(sp)
    80003fd0:	6c42                	ld	s8,16(sp)
    80003fd2:	6ca2                	ld	s9,8(sp)
    80003fd4:	6125                	addi	sp,sp,96
    80003fd6:	8082                	ret
      iunlock(ip);
    80003fd8:	854e                	mv	a0,s3
    80003fda:	00000097          	auipc	ra,0x0
    80003fde:	aa6080e7          	jalr	-1370(ra) # 80003a80 <iunlock>
      return ip;
    80003fe2:	bfe9                	j	80003fbc <namex+0x6a>
      iunlockput(ip);
    80003fe4:	854e                	mv	a0,s3
    80003fe6:	00000097          	auipc	ra,0x0
    80003fea:	c3a080e7          	jalr	-966(ra) # 80003c20 <iunlockput>
      return 0;
    80003fee:	89d2                	mv	s3,s4
    80003ff0:	b7f1                	j	80003fbc <namex+0x6a>
  len = path - s;
    80003ff2:	40b48633          	sub	a2,s1,a1
    80003ff6:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003ffa:	094cd463          	bge	s9,s4,80004082 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003ffe:	4639                	li	a2,14
    80004000:	8556                	mv	a0,s5
    80004002:	ffffd097          	auipc	ra,0xffffd
    80004006:	d3e080e7          	jalr	-706(ra) # 80000d40 <memmove>
  while(*path == '/')
    8000400a:	0004c783          	lbu	a5,0(s1)
    8000400e:	01279763          	bne	a5,s2,8000401c <namex+0xca>
    path++;
    80004012:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004014:	0004c783          	lbu	a5,0(s1)
    80004018:	ff278de3          	beq	a5,s2,80004012 <namex+0xc0>
    ilock(ip);
    8000401c:	854e                	mv	a0,s3
    8000401e:	00000097          	auipc	ra,0x0
    80004022:	9a0080e7          	jalr	-1632(ra) # 800039be <ilock>
    if(ip->type != T_DIR){
    80004026:	04499783          	lh	a5,68(s3)
    8000402a:	f98793e3          	bne	a5,s8,80003fb0 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    8000402e:	000b0563          	beqz	s6,80004038 <namex+0xe6>
    80004032:	0004c783          	lbu	a5,0(s1)
    80004036:	d3cd                	beqz	a5,80003fd8 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004038:	865e                	mv	a2,s7
    8000403a:	85d6                	mv	a1,s5
    8000403c:	854e                	mv	a0,s3
    8000403e:	00000097          	auipc	ra,0x0
    80004042:	e64080e7          	jalr	-412(ra) # 80003ea2 <dirlookup>
    80004046:	8a2a                	mv	s4,a0
    80004048:	dd51                	beqz	a0,80003fe4 <namex+0x92>
    iunlockput(ip);
    8000404a:	854e                	mv	a0,s3
    8000404c:	00000097          	auipc	ra,0x0
    80004050:	bd4080e7          	jalr	-1068(ra) # 80003c20 <iunlockput>
    ip = next;
    80004054:	89d2                	mv	s3,s4
  while(*path == '/')
    80004056:	0004c783          	lbu	a5,0(s1)
    8000405a:	05279763          	bne	a5,s2,800040a8 <namex+0x156>
    path++;
    8000405e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004060:	0004c783          	lbu	a5,0(s1)
    80004064:	ff278de3          	beq	a5,s2,8000405e <namex+0x10c>
  if(*path == 0)
    80004068:	c79d                	beqz	a5,80004096 <namex+0x144>
    path++;
    8000406a:	85a6                	mv	a1,s1
  len = path - s;
    8000406c:	8a5e                	mv	s4,s7
    8000406e:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80004070:	01278963          	beq	a5,s2,80004082 <namex+0x130>
    80004074:	dfbd                	beqz	a5,80003ff2 <namex+0xa0>
    path++;
    80004076:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004078:	0004c783          	lbu	a5,0(s1)
    8000407c:	ff279ce3          	bne	a5,s2,80004074 <namex+0x122>
    80004080:	bf8d                	j	80003ff2 <namex+0xa0>
    memmove(name, s, len);
    80004082:	2601                	sext.w	a2,a2
    80004084:	8556                	mv	a0,s5
    80004086:	ffffd097          	auipc	ra,0xffffd
    8000408a:	cba080e7          	jalr	-838(ra) # 80000d40 <memmove>
    name[len] = 0;
    8000408e:	9a56                	add	s4,s4,s5
    80004090:	000a0023          	sb	zero,0(s4)
    80004094:	bf9d                	j	8000400a <namex+0xb8>
  if(nameiparent){
    80004096:	f20b03e3          	beqz	s6,80003fbc <namex+0x6a>
    iput(ip);
    8000409a:	854e                	mv	a0,s3
    8000409c:	00000097          	auipc	ra,0x0
    800040a0:	adc080e7          	jalr	-1316(ra) # 80003b78 <iput>
    return 0;
    800040a4:	4981                	li	s3,0
    800040a6:	bf19                	j	80003fbc <namex+0x6a>
  if(*path == 0)
    800040a8:	d7fd                	beqz	a5,80004096 <namex+0x144>
  while(*path != '/' && *path != 0)
    800040aa:	0004c783          	lbu	a5,0(s1)
    800040ae:	85a6                	mv	a1,s1
    800040b0:	b7d1                	j	80004074 <namex+0x122>

00000000800040b2 <dirlink>:
{
    800040b2:	7139                	addi	sp,sp,-64
    800040b4:	fc06                	sd	ra,56(sp)
    800040b6:	f822                	sd	s0,48(sp)
    800040b8:	f426                	sd	s1,40(sp)
    800040ba:	f04a                	sd	s2,32(sp)
    800040bc:	ec4e                	sd	s3,24(sp)
    800040be:	e852                	sd	s4,16(sp)
    800040c0:	0080                	addi	s0,sp,64
    800040c2:	892a                	mv	s2,a0
    800040c4:	8a2e                	mv	s4,a1
    800040c6:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800040c8:	4601                	li	a2,0
    800040ca:	00000097          	auipc	ra,0x0
    800040ce:	dd8080e7          	jalr	-552(ra) # 80003ea2 <dirlookup>
    800040d2:	e93d                	bnez	a0,80004148 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040d4:	04c92483          	lw	s1,76(s2)
    800040d8:	c49d                	beqz	s1,80004106 <dirlink+0x54>
    800040da:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040dc:	4741                	li	a4,16
    800040de:	86a6                	mv	a3,s1
    800040e0:	fc040613          	addi	a2,s0,-64
    800040e4:	4581                	li	a1,0
    800040e6:	854a                	mv	a0,s2
    800040e8:	00000097          	auipc	ra,0x0
    800040ec:	b8a080e7          	jalr	-1142(ra) # 80003c72 <readi>
    800040f0:	47c1                	li	a5,16
    800040f2:	06f51163          	bne	a0,a5,80004154 <dirlink+0xa2>
    if(de.inum == 0)
    800040f6:	fc045783          	lhu	a5,-64(s0)
    800040fa:	c791                	beqz	a5,80004106 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040fc:	24c1                	addiw	s1,s1,16
    800040fe:	04c92783          	lw	a5,76(s2)
    80004102:	fcf4ede3          	bltu	s1,a5,800040dc <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004106:	4639                	li	a2,14
    80004108:	85d2                	mv	a1,s4
    8000410a:	fc240513          	addi	a0,s0,-62
    8000410e:	ffffd097          	auipc	ra,0xffffd
    80004112:	ce6080e7          	jalr	-794(ra) # 80000df4 <strncpy>
  de.inum = inum;
    80004116:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000411a:	4741                	li	a4,16
    8000411c:	86a6                	mv	a3,s1
    8000411e:	fc040613          	addi	a2,s0,-64
    80004122:	4581                	li	a1,0
    80004124:	854a                	mv	a0,s2
    80004126:	00000097          	auipc	ra,0x0
    8000412a:	c44080e7          	jalr	-956(ra) # 80003d6a <writei>
    8000412e:	872a                	mv	a4,a0
    80004130:	47c1                	li	a5,16
  return 0;
    80004132:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004134:	02f71863          	bne	a4,a5,80004164 <dirlink+0xb2>
}
    80004138:	70e2                	ld	ra,56(sp)
    8000413a:	7442                	ld	s0,48(sp)
    8000413c:	74a2                	ld	s1,40(sp)
    8000413e:	7902                	ld	s2,32(sp)
    80004140:	69e2                	ld	s3,24(sp)
    80004142:	6a42                	ld	s4,16(sp)
    80004144:	6121                	addi	sp,sp,64
    80004146:	8082                	ret
    iput(ip);
    80004148:	00000097          	auipc	ra,0x0
    8000414c:	a30080e7          	jalr	-1488(ra) # 80003b78 <iput>
    return -1;
    80004150:	557d                	li	a0,-1
    80004152:	b7dd                	j	80004138 <dirlink+0x86>
      panic("dirlink read");
    80004154:	00004517          	auipc	a0,0x4
    80004158:	52c50513          	addi	a0,a0,1324 # 80008680 <syscalls+0x1f0>
    8000415c:	ffffc097          	auipc	ra,0xffffc
    80004160:	3e2080e7          	jalr	994(ra) # 8000053e <panic>
    panic("dirlink");
    80004164:	00004517          	auipc	a0,0x4
    80004168:	62c50513          	addi	a0,a0,1580 # 80008790 <syscalls+0x300>
    8000416c:	ffffc097          	auipc	ra,0xffffc
    80004170:	3d2080e7          	jalr	978(ra) # 8000053e <panic>

0000000080004174 <namei>:

struct inode*
namei(char *path)
{
    80004174:	1101                	addi	sp,sp,-32
    80004176:	ec06                	sd	ra,24(sp)
    80004178:	e822                	sd	s0,16(sp)
    8000417a:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000417c:	fe040613          	addi	a2,s0,-32
    80004180:	4581                	li	a1,0
    80004182:	00000097          	auipc	ra,0x0
    80004186:	dd0080e7          	jalr	-560(ra) # 80003f52 <namex>
}
    8000418a:	60e2                	ld	ra,24(sp)
    8000418c:	6442                	ld	s0,16(sp)
    8000418e:	6105                	addi	sp,sp,32
    80004190:	8082                	ret

0000000080004192 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004192:	1141                	addi	sp,sp,-16
    80004194:	e406                	sd	ra,8(sp)
    80004196:	e022                	sd	s0,0(sp)
    80004198:	0800                	addi	s0,sp,16
    8000419a:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000419c:	4585                	li	a1,1
    8000419e:	00000097          	auipc	ra,0x0
    800041a2:	db4080e7          	jalr	-588(ra) # 80003f52 <namex>
}
    800041a6:	60a2                	ld	ra,8(sp)
    800041a8:	6402                	ld	s0,0(sp)
    800041aa:	0141                	addi	sp,sp,16
    800041ac:	8082                	ret

00000000800041ae <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800041ae:	1101                	addi	sp,sp,-32
    800041b0:	ec06                	sd	ra,24(sp)
    800041b2:	e822                	sd	s0,16(sp)
    800041b4:	e426                	sd	s1,8(sp)
    800041b6:	e04a                	sd	s2,0(sp)
    800041b8:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800041ba:	0001d917          	auipc	s2,0x1d
    800041be:	0b690913          	addi	s2,s2,182 # 80021270 <log>
    800041c2:	01892583          	lw	a1,24(s2)
    800041c6:	02892503          	lw	a0,40(s2)
    800041ca:	fffff097          	auipc	ra,0xfffff
    800041ce:	ff2080e7          	jalr	-14(ra) # 800031bc <bread>
    800041d2:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800041d4:	02c92683          	lw	a3,44(s2)
    800041d8:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800041da:	02d05763          	blez	a3,80004208 <write_head+0x5a>
    800041de:	0001d797          	auipc	a5,0x1d
    800041e2:	0c278793          	addi	a5,a5,194 # 800212a0 <log+0x30>
    800041e6:	05c50713          	addi	a4,a0,92
    800041ea:	36fd                	addiw	a3,a3,-1
    800041ec:	1682                	slli	a3,a3,0x20
    800041ee:	9281                	srli	a3,a3,0x20
    800041f0:	068a                	slli	a3,a3,0x2
    800041f2:	0001d617          	auipc	a2,0x1d
    800041f6:	0b260613          	addi	a2,a2,178 # 800212a4 <log+0x34>
    800041fa:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800041fc:	4390                	lw	a2,0(a5)
    800041fe:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004200:	0791                	addi	a5,a5,4
    80004202:	0711                	addi	a4,a4,4
    80004204:	fed79ce3          	bne	a5,a3,800041fc <write_head+0x4e>
  }
  bwrite(buf);
    80004208:	8526                	mv	a0,s1
    8000420a:	fffff097          	auipc	ra,0xfffff
    8000420e:	0a4080e7          	jalr	164(ra) # 800032ae <bwrite>
  brelse(buf);
    80004212:	8526                	mv	a0,s1
    80004214:	fffff097          	auipc	ra,0xfffff
    80004218:	0d8080e7          	jalr	216(ra) # 800032ec <brelse>
}
    8000421c:	60e2                	ld	ra,24(sp)
    8000421e:	6442                	ld	s0,16(sp)
    80004220:	64a2                	ld	s1,8(sp)
    80004222:	6902                	ld	s2,0(sp)
    80004224:	6105                	addi	sp,sp,32
    80004226:	8082                	ret

0000000080004228 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004228:	0001d797          	auipc	a5,0x1d
    8000422c:	0747a783          	lw	a5,116(a5) # 8002129c <log+0x2c>
    80004230:	0af05d63          	blez	a5,800042ea <install_trans+0xc2>
{
    80004234:	7139                	addi	sp,sp,-64
    80004236:	fc06                	sd	ra,56(sp)
    80004238:	f822                	sd	s0,48(sp)
    8000423a:	f426                	sd	s1,40(sp)
    8000423c:	f04a                	sd	s2,32(sp)
    8000423e:	ec4e                	sd	s3,24(sp)
    80004240:	e852                	sd	s4,16(sp)
    80004242:	e456                	sd	s5,8(sp)
    80004244:	e05a                	sd	s6,0(sp)
    80004246:	0080                	addi	s0,sp,64
    80004248:	8b2a                	mv	s6,a0
    8000424a:	0001da97          	auipc	s5,0x1d
    8000424e:	056a8a93          	addi	s5,s5,86 # 800212a0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004252:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004254:	0001d997          	auipc	s3,0x1d
    80004258:	01c98993          	addi	s3,s3,28 # 80021270 <log>
    8000425c:	a035                	j	80004288 <install_trans+0x60>
      bunpin(dbuf);
    8000425e:	8526                	mv	a0,s1
    80004260:	fffff097          	auipc	ra,0xfffff
    80004264:	166080e7          	jalr	358(ra) # 800033c6 <bunpin>
    brelse(lbuf);
    80004268:	854a                	mv	a0,s2
    8000426a:	fffff097          	auipc	ra,0xfffff
    8000426e:	082080e7          	jalr	130(ra) # 800032ec <brelse>
    brelse(dbuf);
    80004272:	8526                	mv	a0,s1
    80004274:	fffff097          	auipc	ra,0xfffff
    80004278:	078080e7          	jalr	120(ra) # 800032ec <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000427c:	2a05                	addiw	s4,s4,1
    8000427e:	0a91                	addi	s5,s5,4
    80004280:	02c9a783          	lw	a5,44(s3)
    80004284:	04fa5963          	bge	s4,a5,800042d6 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004288:	0189a583          	lw	a1,24(s3)
    8000428c:	014585bb          	addw	a1,a1,s4
    80004290:	2585                	addiw	a1,a1,1
    80004292:	0289a503          	lw	a0,40(s3)
    80004296:	fffff097          	auipc	ra,0xfffff
    8000429a:	f26080e7          	jalr	-218(ra) # 800031bc <bread>
    8000429e:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800042a0:	000aa583          	lw	a1,0(s5)
    800042a4:	0289a503          	lw	a0,40(s3)
    800042a8:	fffff097          	auipc	ra,0xfffff
    800042ac:	f14080e7          	jalr	-236(ra) # 800031bc <bread>
    800042b0:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800042b2:	40000613          	li	a2,1024
    800042b6:	05890593          	addi	a1,s2,88
    800042ba:	05850513          	addi	a0,a0,88
    800042be:	ffffd097          	auipc	ra,0xffffd
    800042c2:	a82080e7          	jalr	-1406(ra) # 80000d40 <memmove>
    bwrite(dbuf);  // write dst to disk
    800042c6:	8526                	mv	a0,s1
    800042c8:	fffff097          	auipc	ra,0xfffff
    800042cc:	fe6080e7          	jalr	-26(ra) # 800032ae <bwrite>
    if(recovering == 0)
    800042d0:	f80b1ce3          	bnez	s6,80004268 <install_trans+0x40>
    800042d4:	b769                	j	8000425e <install_trans+0x36>
}
    800042d6:	70e2                	ld	ra,56(sp)
    800042d8:	7442                	ld	s0,48(sp)
    800042da:	74a2                	ld	s1,40(sp)
    800042dc:	7902                	ld	s2,32(sp)
    800042de:	69e2                	ld	s3,24(sp)
    800042e0:	6a42                	ld	s4,16(sp)
    800042e2:	6aa2                	ld	s5,8(sp)
    800042e4:	6b02                	ld	s6,0(sp)
    800042e6:	6121                	addi	sp,sp,64
    800042e8:	8082                	ret
    800042ea:	8082                	ret

00000000800042ec <initlog>:
{
    800042ec:	7179                	addi	sp,sp,-48
    800042ee:	f406                	sd	ra,40(sp)
    800042f0:	f022                	sd	s0,32(sp)
    800042f2:	ec26                	sd	s1,24(sp)
    800042f4:	e84a                	sd	s2,16(sp)
    800042f6:	e44e                	sd	s3,8(sp)
    800042f8:	1800                	addi	s0,sp,48
    800042fa:	892a                	mv	s2,a0
    800042fc:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800042fe:	0001d497          	auipc	s1,0x1d
    80004302:	f7248493          	addi	s1,s1,-142 # 80021270 <log>
    80004306:	00004597          	auipc	a1,0x4
    8000430a:	38a58593          	addi	a1,a1,906 # 80008690 <syscalls+0x200>
    8000430e:	8526                	mv	a0,s1
    80004310:	ffffd097          	auipc	ra,0xffffd
    80004314:	844080e7          	jalr	-1980(ra) # 80000b54 <initlock>
  log.start = sb->logstart;
    80004318:	0149a583          	lw	a1,20(s3)
    8000431c:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000431e:	0109a783          	lw	a5,16(s3)
    80004322:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004324:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004328:	854a                	mv	a0,s2
    8000432a:	fffff097          	auipc	ra,0xfffff
    8000432e:	e92080e7          	jalr	-366(ra) # 800031bc <bread>
  log.lh.n = lh->n;
    80004332:	4d3c                	lw	a5,88(a0)
    80004334:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004336:	02f05563          	blez	a5,80004360 <initlog+0x74>
    8000433a:	05c50713          	addi	a4,a0,92
    8000433e:	0001d697          	auipc	a3,0x1d
    80004342:	f6268693          	addi	a3,a3,-158 # 800212a0 <log+0x30>
    80004346:	37fd                	addiw	a5,a5,-1
    80004348:	1782                	slli	a5,a5,0x20
    8000434a:	9381                	srli	a5,a5,0x20
    8000434c:	078a                	slli	a5,a5,0x2
    8000434e:	06050613          	addi	a2,a0,96
    80004352:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80004354:	4310                	lw	a2,0(a4)
    80004356:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    80004358:	0711                	addi	a4,a4,4
    8000435a:	0691                	addi	a3,a3,4
    8000435c:	fef71ce3          	bne	a4,a5,80004354 <initlog+0x68>
  brelse(buf);
    80004360:	fffff097          	auipc	ra,0xfffff
    80004364:	f8c080e7          	jalr	-116(ra) # 800032ec <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004368:	4505                	li	a0,1
    8000436a:	00000097          	auipc	ra,0x0
    8000436e:	ebe080e7          	jalr	-322(ra) # 80004228 <install_trans>
  log.lh.n = 0;
    80004372:	0001d797          	auipc	a5,0x1d
    80004376:	f207a523          	sw	zero,-214(a5) # 8002129c <log+0x2c>
  write_head(); // clear the log
    8000437a:	00000097          	auipc	ra,0x0
    8000437e:	e34080e7          	jalr	-460(ra) # 800041ae <write_head>
}
    80004382:	70a2                	ld	ra,40(sp)
    80004384:	7402                	ld	s0,32(sp)
    80004386:	64e2                	ld	s1,24(sp)
    80004388:	6942                	ld	s2,16(sp)
    8000438a:	69a2                	ld	s3,8(sp)
    8000438c:	6145                	addi	sp,sp,48
    8000438e:	8082                	ret

0000000080004390 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004390:	1101                	addi	sp,sp,-32
    80004392:	ec06                	sd	ra,24(sp)
    80004394:	e822                	sd	s0,16(sp)
    80004396:	e426                	sd	s1,8(sp)
    80004398:	e04a                	sd	s2,0(sp)
    8000439a:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000439c:	0001d517          	auipc	a0,0x1d
    800043a0:	ed450513          	addi	a0,a0,-300 # 80021270 <log>
    800043a4:	ffffd097          	auipc	ra,0xffffd
    800043a8:	840080e7          	jalr	-1984(ra) # 80000be4 <acquire>
  while(1){
    if(log.committing){
    800043ac:	0001d497          	auipc	s1,0x1d
    800043b0:	ec448493          	addi	s1,s1,-316 # 80021270 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800043b4:	4979                	li	s2,30
    800043b6:	a039                	j	800043c4 <begin_op+0x34>
      sleep(&log, &log.lock);
    800043b8:	85a6                	mv	a1,s1
    800043ba:	8526                	mv	a0,s1
    800043bc:	ffffe097          	auipc	ra,0xffffe
    800043c0:	cb0080e7          	jalr	-848(ra) # 8000206c <sleep>
    if(log.committing){
    800043c4:	50dc                	lw	a5,36(s1)
    800043c6:	fbed                	bnez	a5,800043b8 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800043c8:	509c                	lw	a5,32(s1)
    800043ca:	0017871b          	addiw	a4,a5,1
    800043ce:	0007069b          	sext.w	a3,a4
    800043d2:	0027179b          	slliw	a5,a4,0x2
    800043d6:	9fb9                	addw	a5,a5,a4
    800043d8:	0017979b          	slliw	a5,a5,0x1
    800043dc:	54d8                	lw	a4,44(s1)
    800043de:	9fb9                	addw	a5,a5,a4
    800043e0:	00f95963          	bge	s2,a5,800043f2 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800043e4:	85a6                	mv	a1,s1
    800043e6:	8526                	mv	a0,s1
    800043e8:	ffffe097          	auipc	ra,0xffffe
    800043ec:	c84080e7          	jalr	-892(ra) # 8000206c <sleep>
    800043f0:	bfd1                	j	800043c4 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800043f2:	0001d517          	auipc	a0,0x1d
    800043f6:	e7e50513          	addi	a0,a0,-386 # 80021270 <log>
    800043fa:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800043fc:	ffffd097          	auipc	ra,0xffffd
    80004400:	89c080e7          	jalr	-1892(ra) # 80000c98 <release>
      break;
    }
  }
}
    80004404:	60e2                	ld	ra,24(sp)
    80004406:	6442                	ld	s0,16(sp)
    80004408:	64a2                	ld	s1,8(sp)
    8000440a:	6902                	ld	s2,0(sp)
    8000440c:	6105                	addi	sp,sp,32
    8000440e:	8082                	ret

0000000080004410 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004410:	7139                	addi	sp,sp,-64
    80004412:	fc06                	sd	ra,56(sp)
    80004414:	f822                	sd	s0,48(sp)
    80004416:	f426                	sd	s1,40(sp)
    80004418:	f04a                	sd	s2,32(sp)
    8000441a:	ec4e                	sd	s3,24(sp)
    8000441c:	e852                	sd	s4,16(sp)
    8000441e:	e456                	sd	s5,8(sp)
    80004420:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004422:	0001d497          	auipc	s1,0x1d
    80004426:	e4e48493          	addi	s1,s1,-434 # 80021270 <log>
    8000442a:	8526                	mv	a0,s1
    8000442c:	ffffc097          	auipc	ra,0xffffc
    80004430:	7b8080e7          	jalr	1976(ra) # 80000be4 <acquire>
  log.outstanding -= 1;
    80004434:	509c                	lw	a5,32(s1)
    80004436:	37fd                	addiw	a5,a5,-1
    80004438:	0007891b          	sext.w	s2,a5
    8000443c:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000443e:	50dc                	lw	a5,36(s1)
    80004440:	efb9                	bnez	a5,8000449e <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004442:	06091663          	bnez	s2,800044ae <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    80004446:	0001d497          	auipc	s1,0x1d
    8000444a:	e2a48493          	addi	s1,s1,-470 # 80021270 <log>
    8000444e:	4785                	li	a5,1
    80004450:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004452:	8526                	mv	a0,s1
    80004454:	ffffd097          	auipc	ra,0xffffd
    80004458:	844080e7          	jalr	-1980(ra) # 80000c98 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000445c:	54dc                	lw	a5,44(s1)
    8000445e:	06f04763          	bgtz	a5,800044cc <end_op+0xbc>
    acquire(&log.lock);
    80004462:	0001d497          	auipc	s1,0x1d
    80004466:	e0e48493          	addi	s1,s1,-498 # 80021270 <log>
    8000446a:	8526                	mv	a0,s1
    8000446c:	ffffc097          	auipc	ra,0xffffc
    80004470:	778080e7          	jalr	1912(ra) # 80000be4 <acquire>
    log.committing = 0;
    80004474:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004478:	8526                	mv	a0,s1
    8000447a:	ffffe097          	auipc	ra,0xffffe
    8000447e:	d7e080e7          	jalr	-642(ra) # 800021f8 <wakeup>
    release(&log.lock);
    80004482:	8526                	mv	a0,s1
    80004484:	ffffd097          	auipc	ra,0xffffd
    80004488:	814080e7          	jalr	-2028(ra) # 80000c98 <release>
}
    8000448c:	70e2                	ld	ra,56(sp)
    8000448e:	7442                	ld	s0,48(sp)
    80004490:	74a2                	ld	s1,40(sp)
    80004492:	7902                	ld	s2,32(sp)
    80004494:	69e2                	ld	s3,24(sp)
    80004496:	6a42                	ld	s4,16(sp)
    80004498:	6aa2                	ld	s5,8(sp)
    8000449a:	6121                	addi	sp,sp,64
    8000449c:	8082                	ret
    panic("log.committing");
    8000449e:	00004517          	auipc	a0,0x4
    800044a2:	1fa50513          	addi	a0,a0,506 # 80008698 <syscalls+0x208>
    800044a6:	ffffc097          	auipc	ra,0xffffc
    800044aa:	098080e7          	jalr	152(ra) # 8000053e <panic>
    wakeup(&log);
    800044ae:	0001d497          	auipc	s1,0x1d
    800044b2:	dc248493          	addi	s1,s1,-574 # 80021270 <log>
    800044b6:	8526                	mv	a0,s1
    800044b8:	ffffe097          	auipc	ra,0xffffe
    800044bc:	d40080e7          	jalr	-704(ra) # 800021f8 <wakeup>
  release(&log.lock);
    800044c0:	8526                	mv	a0,s1
    800044c2:	ffffc097          	auipc	ra,0xffffc
    800044c6:	7d6080e7          	jalr	2006(ra) # 80000c98 <release>
  if(do_commit){
    800044ca:	b7c9                	j	8000448c <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    800044cc:	0001da97          	auipc	s5,0x1d
    800044d0:	dd4a8a93          	addi	s5,s5,-556 # 800212a0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800044d4:	0001da17          	auipc	s4,0x1d
    800044d8:	d9ca0a13          	addi	s4,s4,-612 # 80021270 <log>
    800044dc:	018a2583          	lw	a1,24(s4)
    800044e0:	012585bb          	addw	a1,a1,s2
    800044e4:	2585                	addiw	a1,a1,1
    800044e6:	028a2503          	lw	a0,40(s4)
    800044ea:	fffff097          	auipc	ra,0xfffff
    800044ee:	cd2080e7          	jalr	-814(ra) # 800031bc <bread>
    800044f2:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800044f4:	000aa583          	lw	a1,0(s5)
    800044f8:	028a2503          	lw	a0,40(s4)
    800044fc:	fffff097          	auipc	ra,0xfffff
    80004500:	cc0080e7          	jalr	-832(ra) # 800031bc <bread>
    80004504:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004506:	40000613          	li	a2,1024
    8000450a:	05850593          	addi	a1,a0,88
    8000450e:	05848513          	addi	a0,s1,88
    80004512:	ffffd097          	auipc	ra,0xffffd
    80004516:	82e080e7          	jalr	-2002(ra) # 80000d40 <memmove>
    bwrite(to);  // write the log
    8000451a:	8526                	mv	a0,s1
    8000451c:	fffff097          	auipc	ra,0xfffff
    80004520:	d92080e7          	jalr	-622(ra) # 800032ae <bwrite>
    brelse(from);
    80004524:	854e                	mv	a0,s3
    80004526:	fffff097          	auipc	ra,0xfffff
    8000452a:	dc6080e7          	jalr	-570(ra) # 800032ec <brelse>
    brelse(to);
    8000452e:	8526                	mv	a0,s1
    80004530:	fffff097          	auipc	ra,0xfffff
    80004534:	dbc080e7          	jalr	-580(ra) # 800032ec <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004538:	2905                	addiw	s2,s2,1
    8000453a:	0a91                	addi	s5,s5,4
    8000453c:	02ca2783          	lw	a5,44(s4)
    80004540:	f8f94ee3          	blt	s2,a5,800044dc <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004544:	00000097          	auipc	ra,0x0
    80004548:	c6a080e7          	jalr	-918(ra) # 800041ae <write_head>
    install_trans(0); // Now install writes to home locations
    8000454c:	4501                	li	a0,0
    8000454e:	00000097          	auipc	ra,0x0
    80004552:	cda080e7          	jalr	-806(ra) # 80004228 <install_trans>
    log.lh.n = 0;
    80004556:	0001d797          	auipc	a5,0x1d
    8000455a:	d407a323          	sw	zero,-698(a5) # 8002129c <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000455e:	00000097          	auipc	ra,0x0
    80004562:	c50080e7          	jalr	-944(ra) # 800041ae <write_head>
    80004566:	bdf5                	j	80004462 <end_op+0x52>

0000000080004568 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004568:	1101                	addi	sp,sp,-32
    8000456a:	ec06                	sd	ra,24(sp)
    8000456c:	e822                	sd	s0,16(sp)
    8000456e:	e426                	sd	s1,8(sp)
    80004570:	e04a                	sd	s2,0(sp)
    80004572:	1000                	addi	s0,sp,32
    80004574:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004576:	0001d917          	auipc	s2,0x1d
    8000457a:	cfa90913          	addi	s2,s2,-774 # 80021270 <log>
    8000457e:	854a                	mv	a0,s2
    80004580:	ffffc097          	auipc	ra,0xffffc
    80004584:	664080e7          	jalr	1636(ra) # 80000be4 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004588:	02c92603          	lw	a2,44(s2)
    8000458c:	47f5                	li	a5,29
    8000458e:	06c7c563          	blt	a5,a2,800045f8 <log_write+0x90>
    80004592:	0001d797          	auipc	a5,0x1d
    80004596:	cfa7a783          	lw	a5,-774(a5) # 8002128c <log+0x1c>
    8000459a:	37fd                	addiw	a5,a5,-1
    8000459c:	04f65e63          	bge	a2,a5,800045f8 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800045a0:	0001d797          	auipc	a5,0x1d
    800045a4:	cf07a783          	lw	a5,-784(a5) # 80021290 <log+0x20>
    800045a8:	06f05063          	blez	a5,80004608 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800045ac:	4781                	li	a5,0
    800045ae:	06c05563          	blez	a2,80004618 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800045b2:	44cc                	lw	a1,12(s1)
    800045b4:	0001d717          	auipc	a4,0x1d
    800045b8:	cec70713          	addi	a4,a4,-788 # 800212a0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800045bc:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800045be:	4314                	lw	a3,0(a4)
    800045c0:	04b68c63          	beq	a3,a1,80004618 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800045c4:	2785                	addiw	a5,a5,1
    800045c6:	0711                	addi	a4,a4,4
    800045c8:	fef61be3          	bne	a2,a5,800045be <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800045cc:	0621                	addi	a2,a2,8
    800045ce:	060a                	slli	a2,a2,0x2
    800045d0:	0001d797          	auipc	a5,0x1d
    800045d4:	ca078793          	addi	a5,a5,-864 # 80021270 <log>
    800045d8:	963e                	add	a2,a2,a5
    800045da:	44dc                	lw	a5,12(s1)
    800045dc:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800045de:	8526                	mv	a0,s1
    800045e0:	fffff097          	auipc	ra,0xfffff
    800045e4:	daa080e7          	jalr	-598(ra) # 8000338a <bpin>
    log.lh.n++;
    800045e8:	0001d717          	auipc	a4,0x1d
    800045ec:	c8870713          	addi	a4,a4,-888 # 80021270 <log>
    800045f0:	575c                	lw	a5,44(a4)
    800045f2:	2785                	addiw	a5,a5,1
    800045f4:	d75c                	sw	a5,44(a4)
    800045f6:	a835                	j	80004632 <log_write+0xca>
    panic("too big a transaction");
    800045f8:	00004517          	auipc	a0,0x4
    800045fc:	0b050513          	addi	a0,a0,176 # 800086a8 <syscalls+0x218>
    80004600:	ffffc097          	auipc	ra,0xffffc
    80004604:	f3e080e7          	jalr	-194(ra) # 8000053e <panic>
    panic("log_write outside of trans");
    80004608:	00004517          	auipc	a0,0x4
    8000460c:	0b850513          	addi	a0,a0,184 # 800086c0 <syscalls+0x230>
    80004610:	ffffc097          	auipc	ra,0xffffc
    80004614:	f2e080e7          	jalr	-210(ra) # 8000053e <panic>
  log.lh.block[i] = b->blockno;
    80004618:	00878713          	addi	a4,a5,8
    8000461c:	00271693          	slli	a3,a4,0x2
    80004620:	0001d717          	auipc	a4,0x1d
    80004624:	c5070713          	addi	a4,a4,-944 # 80021270 <log>
    80004628:	9736                	add	a4,a4,a3
    8000462a:	44d4                	lw	a3,12(s1)
    8000462c:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000462e:	faf608e3          	beq	a2,a5,800045de <log_write+0x76>
  }
  release(&log.lock);
    80004632:	0001d517          	auipc	a0,0x1d
    80004636:	c3e50513          	addi	a0,a0,-962 # 80021270 <log>
    8000463a:	ffffc097          	auipc	ra,0xffffc
    8000463e:	65e080e7          	jalr	1630(ra) # 80000c98 <release>
}
    80004642:	60e2                	ld	ra,24(sp)
    80004644:	6442                	ld	s0,16(sp)
    80004646:	64a2                	ld	s1,8(sp)
    80004648:	6902                	ld	s2,0(sp)
    8000464a:	6105                	addi	sp,sp,32
    8000464c:	8082                	ret

000000008000464e <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000464e:	1101                	addi	sp,sp,-32
    80004650:	ec06                	sd	ra,24(sp)
    80004652:	e822                	sd	s0,16(sp)
    80004654:	e426                	sd	s1,8(sp)
    80004656:	e04a                	sd	s2,0(sp)
    80004658:	1000                	addi	s0,sp,32
    8000465a:	84aa                	mv	s1,a0
    8000465c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000465e:	00004597          	auipc	a1,0x4
    80004662:	08258593          	addi	a1,a1,130 # 800086e0 <syscalls+0x250>
    80004666:	0521                	addi	a0,a0,8
    80004668:	ffffc097          	auipc	ra,0xffffc
    8000466c:	4ec080e7          	jalr	1260(ra) # 80000b54 <initlock>
  lk->name = name;
    80004670:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004674:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004678:	0204a423          	sw	zero,40(s1)
}
    8000467c:	60e2                	ld	ra,24(sp)
    8000467e:	6442                	ld	s0,16(sp)
    80004680:	64a2                	ld	s1,8(sp)
    80004682:	6902                	ld	s2,0(sp)
    80004684:	6105                	addi	sp,sp,32
    80004686:	8082                	ret

0000000080004688 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004688:	1101                	addi	sp,sp,-32
    8000468a:	ec06                	sd	ra,24(sp)
    8000468c:	e822                	sd	s0,16(sp)
    8000468e:	e426                	sd	s1,8(sp)
    80004690:	e04a                	sd	s2,0(sp)
    80004692:	1000                	addi	s0,sp,32
    80004694:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004696:	00850913          	addi	s2,a0,8
    8000469a:	854a                	mv	a0,s2
    8000469c:	ffffc097          	auipc	ra,0xffffc
    800046a0:	548080e7          	jalr	1352(ra) # 80000be4 <acquire>
  while (lk->locked) {
    800046a4:	409c                	lw	a5,0(s1)
    800046a6:	cb89                	beqz	a5,800046b8 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800046a8:	85ca                	mv	a1,s2
    800046aa:	8526                	mv	a0,s1
    800046ac:	ffffe097          	auipc	ra,0xffffe
    800046b0:	9c0080e7          	jalr	-1600(ra) # 8000206c <sleep>
  while (lk->locked) {
    800046b4:	409c                	lw	a5,0(s1)
    800046b6:	fbed                	bnez	a5,800046a8 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800046b8:	4785                	li	a5,1
    800046ba:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800046bc:	ffffd097          	auipc	ra,0xffffd
    800046c0:	2f4080e7          	jalr	756(ra) # 800019b0 <myproc>
    800046c4:	591c                	lw	a5,48(a0)
    800046c6:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800046c8:	854a                	mv	a0,s2
    800046ca:	ffffc097          	auipc	ra,0xffffc
    800046ce:	5ce080e7          	jalr	1486(ra) # 80000c98 <release>
}
    800046d2:	60e2                	ld	ra,24(sp)
    800046d4:	6442                	ld	s0,16(sp)
    800046d6:	64a2                	ld	s1,8(sp)
    800046d8:	6902                	ld	s2,0(sp)
    800046da:	6105                	addi	sp,sp,32
    800046dc:	8082                	ret

00000000800046de <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800046de:	1101                	addi	sp,sp,-32
    800046e0:	ec06                	sd	ra,24(sp)
    800046e2:	e822                	sd	s0,16(sp)
    800046e4:	e426                	sd	s1,8(sp)
    800046e6:	e04a                	sd	s2,0(sp)
    800046e8:	1000                	addi	s0,sp,32
    800046ea:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800046ec:	00850913          	addi	s2,a0,8
    800046f0:	854a                	mv	a0,s2
    800046f2:	ffffc097          	auipc	ra,0xffffc
    800046f6:	4f2080e7          	jalr	1266(ra) # 80000be4 <acquire>
  lk->locked = 0;
    800046fa:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800046fe:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004702:	8526                	mv	a0,s1
    80004704:	ffffe097          	auipc	ra,0xffffe
    80004708:	af4080e7          	jalr	-1292(ra) # 800021f8 <wakeup>
  release(&lk->lk);
    8000470c:	854a                	mv	a0,s2
    8000470e:	ffffc097          	auipc	ra,0xffffc
    80004712:	58a080e7          	jalr	1418(ra) # 80000c98 <release>
}
    80004716:	60e2                	ld	ra,24(sp)
    80004718:	6442                	ld	s0,16(sp)
    8000471a:	64a2                	ld	s1,8(sp)
    8000471c:	6902                	ld	s2,0(sp)
    8000471e:	6105                	addi	sp,sp,32
    80004720:	8082                	ret

0000000080004722 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004722:	7179                	addi	sp,sp,-48
    80004724:	f406                	sd	ra,40(sp)
    80004726:	f022                	sd	s0,32(sp)
    80004728:	ec26                	sd	s1,24(sp)
    8000472a:	e84a                	sd	s2,16(sp)
    8000472c:	e44e                	sd	s3,8(sp)
    8000472e:	1800                	addi	s0,sp,48
    80004730:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004732:	00850913          	addi	s2,a0,8
    80004736:	854a                	mv	a0,s2
    80004738:	ffffc097          	auipc	ra,0xffffc
    8000473c:	4ac080e7          	jalr	1196(ra) # 80000be4 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004740:	409c                	lw	a5,0(s1)
    80004742:	ef99                	bnez	a5,80004760 <holdingsleep+0x3e>
    80004744:	4481                	li	s1,0
  release(&lk->lk);
    80004746:	854a                	mv	a0,s2
    80004748:	ffffc097          	auipc	ra,0xffffc
    8000474c:	550080e7          	jalr	1360(ra) # 80000c98 <release>
  return r;
}
    80004750:	8526                	mv	a0,s1
    80004752:	70a2                	ld	ra,40(sp)
    80004754:	7402                	ld	s0,32(sp)
    80004756:	64e2                	ld	s1,24(sp)
    80004758:	6942                	ld	s2,16(sp)
    8000475a:	69a2                	ld	s3,8(sp)
    8000475c:	6145                	addi	sp,sp,48
    8000475e:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004760:	0284a983          	lw	s3,40(s1)
    80004764:	ffffd097          	auipc	ra,0xffffd
    80004768:	24c080e7          	jalr	588(ra) # 800019b0 <myproc>
    8000476c:	5904                	lw	s1,48(a0)
    8000476e:	413484b3          	sub	s1,s1,s3
    80004772:	0014b493          	seqz	s1,s1
    80004776:	bfc1                	j	80004746 <holdingsleep+0x24>

0000000080004778 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004778:	1141                	addi	sp,sp,-16
    8000477a:	e406                	sd	ra,8(sp)
    8000477c:	e022                	sd	s0,0(sp)
    8000477e:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004780:	00004597          	auipc	a1,0x4
    80004784:	f7058593          	addi	a1,a1,-144 # 800086f0 <syscalls+0x260>
    80004788:	0001d517          	auipc	a0,0x1d
    8000478c:	c3050513          	addi	a0,a0,-976 # 800213b8 <ftable>
    80004790:	ffffc097          	auipc	ra,0xffffc
    80004794:	3c4080e7          	jalr	964(ra) # 80000b54 <initlock>
}
    80004798:	60a2                	ld	ra,8(sp)
    8000479a:	6402                	ld	s0,0(sp)
    8000479c:	0141                	addi	sp,sp,16
    8000479e:	8082                	ret

00000000800047a0 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800047a0:	1101                	addi	sp,sp,-32
    800047a2:	ec06                	sd	ra,24(sp)
    800047a4:	e822                	sd	s0,16(sp)
    800047a6:	e426                	sd	s1,8(sp)
    800047a8:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800047aa:	0001d517          	auipc	a0,0x1d
    800047ae:	c0e50513          	addi	a0,a0,-1010 # 800213b8 <ftable>
    800047b2:	ffffc097          	auipc	ra,0xffffc
    800047b6:	432080e7          	jalr	1074(ra) # 80000be4 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800047ba:	0001d497          	auipc	s1,0x1d
    800047be:	c1648493          	addi	s1,s1,-1002 # 800213d0 <ftable+0x18>
    800047c2:	0001e717          	auipc	a4,0x1e
    800047c6:	bae70713          	addi	a4,a4,-1106 # 80022370 <ftable+0xfb8>
    if(f->ref == 0){
    800047ca:	40dc                	lw	a5,4(s1)
    800047cc:	cf99                	beqz	a5,800047ea <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800047ce:	02848493          	addi	s1,s1,40
    800047d2:	fee49ce3          	bne	s1,a4,800047ca <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800047d6:	0001d517          	auipc	a0,0x1d
    800047da:	be250513          	addi	a0,a0,-1054 # 800213b8 <ftable>
    800047de:	ffffc097          	auipc	ra,0xffffc
    800047e2:	4ba080e7          	jalr	1210(ra) # 80000c98 <release>
  return 0;
    800047e6:	4481                	li	s1,0
    800047e8:	a819                	j	800047fe <filealloc+0x5e>
      f->ref = 1;
    800047ea:	4785                	li	a5,1
    800047ec:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800047ee:	0001d517          	auipc	a0,0x1d
    800047f2:	bca50513          	addi	a0,a0,-1078 # 800213b8 <ftable>
    800047f6:	ffffc097          	auipc	ra,0xffffc
    800047fa:	4a2080e7          	jalr	1186(ra) # 80000c98 <release>
}
    800047fe:	8526                	mv	a0,s1
    80004800:	60e2                	ld	ra,24(sp)
    80004802:	6442                	ld	s0,16(sp)
    80004804:	64a2                	ld	s1,8(sp)
    80004806:	6105                	addi	sp,sp,32
    80004808:	8082                	ret

000000008000480a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000480a:	1101                	addi	sp,sp,-32
    8000480c:	ec06                	sd	ra,24(sp)
    8000480e:	e822                	sd	s0,16(sp)
    80004810:	e426                	sd	s1,8(sp)
    80004812:	1000                	addi	s0,sp,32
    80004814:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004816:	0001d517          	auipc	a0,0x1d
    8000481a:	ba250513          	addi	a0,a0,-1118 # 800213b8 <ftable>
    8000481e:	ffffc097          	auipc	ra,0xffffc
    80004822:	3c6080e7          	jalr	966(ra) # 80000be4 <acquire>
  if(f->ref < 1)
    80004826:	40dc                	lw	a5,4(s1)
    80004828:	02f05263          	blez	a5,8000484c <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000482c:	2785                	addiw	a5,a5,1
    8000482e:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004830:	0001d517          	auipc	a0,0x1d
    80004834:	b8850513          	addi	a0,a0,-1144 # 800213b8 <ftable>
    80004838:	ffffc097          	auipc	ra,0xffffc
    8000483c:	460080e7          	jalr	1120(ra) # 80000c98 <release>
  return f;
}
    80004840:	8526                	mv	a0,s1
    80004842:	60e2                	ld	ra,24(sp)
    80004844:	6442                	ld	s0,16(sp)
    80004846:	64a2                	ld	s1,8(sp)
    80004848:	6105                	addi	sp,sp,32
    8000484a:	8082                	ret
    panic("filedup");
    8000484c:	00004517          	auipc	a0,0x4
    80004850:	eac50513          	addi	a0,a0,-340 # 800086f8 <syscalls+0x268>
    80004854:	ffffc097          	auipc	ra,0xffffc
    80004858:	cea080e7          	jalr	-790(ra) # 8000053e <panic>

000000008000485c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000485c:	7139                	addi	sp,sp,-64
    8000485e:	fc06                	sd	ra,56(sp)
    80004860:	f822                	sd	s0,48(sp)
    80004862:	f426                	sd	s1,40(sp)
    80004864:	f04a                	sd	s2,32(sp)
    80004866:	ec4e                	sd	s3,24(sp)
    80004868:	e852                	sd	s4,16(sp)
    8000486a:	e456                	sd	s5,8(sp)
    8000486c:	0080                	addi	s0,sp,64
    8000486e:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004870:	0001d517          	auipc	a0,0x1d
    80004874:	b4850513          	addi	a0,a0,-1208 # 800213b8 <ftable>
    80004878:	ffffc097          	auipc	ra,0xffffc
    8000487c:	36c080e7          	jalr	876(ra) # 80000be4 <acquire>
  if(f->ref < 1)
    80004880:	40dc                	lw	a5,4(s1)
    80004882:	06f05163          	blez	a5,800048e4 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004886:	37fd                	addiw	a5,a5,-1
    80004888:	0007871b          	sext.w	a4,a5
    8000488c:	c0dc                	sw	a5,4(s1)
    8000488e:	06e04363          	bgtz	a4,800048f4 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004892:	0004a903          	lw	s2,0(s1)
    80004896:	0094ca83          	lbu	s5,9(s1)
    8000489a:	0104ba03          	ld	s4,16(s1)
    8000489e:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800048a2:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800048a6:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800048aa:	0001d517          	auipc	a0,0x1d
    800048ae:	b0e50513          	addi	a0,a0,-1266 # 800213b8 <ftable>
    800048b2:	ffffc097          	auipc	ra,0xffffc
    800048b6:	3e6080e7          	jalr	998(ra) # 80000c98 <release>

  if(ff.type == FD_PIPE){
    800048ba:	4785                	li	a5,1
    800048bc:	04f90d63          	beq	s2,a5,80004916 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800048c0:	3979                	addiw	s2,s2,-2
    800048c2:	4785                	li	a5,1
    800048c4:	0527e063          	bltu	a5,s2,80004904 <fileclose+0xa8>
    begin_op();
    800048c8:	00000097          	auipc	ra,0x0
    800048cc:	ac8080e7          	jalr	-1336(ra) # 80004390 <begin_op>
    iput(ff.ip);
    800048d0:	854e                	mv	a0,s3
    800048d2:	fffff097          	auipc	ra,0xfffff
    800048d6:	2a6080e7          	jalr	678(ra) # 80003b78 <iput>
    end_op();
    800048da:	00000097          	auipc	ra,0x0
    800048de:	b36080e7          	jalr	-1226(ra) # 80004410 <end_op>
    800048e2:	a00d                	j	80004904 <fileclose+0xa8>
    panic("fileclose");
    800048e4:	00004517          	auipc	a0,0x4
    800048e8:	e1c50513          	addi	a0,a0,-484 # 80008700 <syscalls+0x270>
    800048ec:	ffffc097          	auipc	ra,0xffffc
    800048f0:	c52080e7          	jalr	-942(ra) # 8000053e <panic>
    release(&ftable.lock);
    800048f4:	0001d517          	auipc	a0,0x1d
    800048f8:	ac450513          	addi	a0,a0,-1340 # 800213b8 <ftable>
    800048fc:	ffffc097          	auipc	ra,0xffffc
    80004900:	39c080e7          	jalr	924(ra) # 80000c98 <release>
  }
}
    80004904:	70e2                	ld	ra,56(sp)
    80004906:	7442                	ld	s0,48(sp)
    80004908:	74a2                	ld	s1,40(sp)
    8000490a:	7902                	ld	s2,32(sp)
    8000490c:	69e2                	ld	s3,24(sp)
    8000490e:	6a42                	ld	s4,16(sp)
    80004910:	6aa2                	ld	s5,8(sp)
    80004912:	6121                	addi	sp,sp,64
    80004914:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004916:	85d6                	mv	a1,s5
    80004918:	8552                	mv	a0,s4
    8000491a:	00000097          	auipc	ra,0x0
    8000491e:	34c080e7          	jalr	844(ra) # 80004c66 <pipeclose>
    80004922:	b7cd                	j	80004904 <fileclose+0xa8>

0000000080004924 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004924:	715d                	addi	sp,sp,-80
    80004926:	e486                	sd	ra,72(sp)
    80004928:	e0a2                	sd	s0,64(sp)
    8000492a:	fc26                	sd	s1,56(sp)
    8000492c:	f84a                	sd	s2,48(sp)
    8000492e:	f44e                	sd	s3,40(sp)
    80004930:	0880                	addi	s0,sp,80
    80004932:	84aa                	mv	s1,a0
    80004934:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004936:	ffffd097          	auipc	ra,0xffffd
    8000493a:	07a080e7          	jalr	122(ra) # 800019b0 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000493e:	409c                	lw	a5,0(s1)
    80004940:	37f9                	addiw	a5,a5,-2
    80004942:	4705                	li	a4,1
    80004944:	04f76763          	bltu	a4,a5,80004992 <filestat+0x6e>
    80004948:	892a                	mv	s2,a0
    ilock(f->ip);
    8000494a:	6c88                	ld	a0,24(s1)
    8000494c:	fffff097          	auipc	ra,0xfffff
    80004950:	072080e7          	jalr	114(ra) # 800039be <ilock>
    stati(f->ip, &st);
    80004954:	fb840593          	addi	a1,s0,-72
    80004958:	6c88                	ld	a0,24(s1)
    8000495a:	fffff097          	auipc	ra,0xfffff
    8000495e:	2ee080e7          	jalr	750(ra) # 80003c48 <stati>
    iunlock(f->ip);
    80004962:	6c88                	ld	a0,24(s1)
    80004964:	fffff097          	auipc	ra,0xfffff
    80004968:	11c080e7          	jalr	284(ra) # 80003a80 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000496c:	46e1                	li	a3,24
    8000496e:	fb840613          	addi	a2,s0,-72
    80004972:	85ce                	mv	a1,s3
    80004974:	05093503          	ld	a0,80(s2)
    80004978:	ffffd097          	auipc	ra,0xffffd
    8000497c:	cfa080e7          	jalr	-774(ra) # 80001672 <copyout>
    80004980:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004984:	60a6                	ld	ra,72(sp)
    80004986:	6406                	ld	s0,64(sp)
    80004988:	74e2                	ld	s1,56(sp)
    8000498a:	7942                	ld	s2,48(sp)
    8000498c:	79a2                	ld	s3,40(sp)
    8000498e:	6161                	addi	sp,sp,80
    80004990:	8082                	ret
  return -1;
    80004992:	557d                	li	a0,-1
    80004994:	bfc5                	j	80004984 <filestat+0x60>

0000000080004996 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004996:	7179                	addi	sp,sp,-48
    80004998:	f406                	sd	ra,40(sp)
    8000499a:	f022                	sd	s0,32(sp)
    8000499c:	ec26                	sd	s1,24(sp)
    8000499e:	e84a                	sd	s2,16(sp)
    800049a0:	e44e                	sd	s3,8(sp)
    800049a2:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800049a4:	00854783          	lbu	a5,8(a0)
    800049a8:	c3d5                	beqz	a5,80004a4c <fileread+0xb6>
    800049aa:	84aa                	mv	s1,a0
    800049ac:	89ae                	mv	s3,a1
    800049ae:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800049b0:	411c                	lw	a5,0(a0)
    800049b2:	4705                	li	a4,1
    800049b4:	04e78963          	beq	a5,a4,80004a06 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800049b8:	470d                	li	a4,3
    800049ba:	04e78d63          	beq	a5,a4,80004a14 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800049be:	4709                	li	a4,2
    800049c0:	06e79e63          	bne	a5,a4,80004a3c <fileread+0xa6>
    ilock(f->ip);
    800049c4:	6d08                	ld	a0,24(a0)
    800049c6:	fffff097          	auipc	ra,0xfffff
    800049ca:	ff8080e7          	jalr	-8(ra) # 800039be <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800049ce:	874a                	mv	a4,s2
    800049d0:	5094                	lw	a3,32(s1)
    800049d2:	864e                	mv	a2,s3
    800049d4:	4585                	li	a1,1
    800049d6:	6c88                	ld	a0,24(s1)
    800049d8:	fffff097          	auipc	ra,0xfffff
    800049dc:	29a080e7          	jalr	666(ra) # 80003c72 <readi>
    800049e0:	892a                	mv	s2,a0
    800049e2:	00a05563          	blez	a0,800049ec <fileread+0x56>
      f->off += r;
    800049e6:	509c                	lw	a5,32(s1)
    800049e8:	9fa9                	addw	a5,a5,a0
    800049ea:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800049ec:	6c88                	ld	a0,24(s1)
    800049ee:	fffff097          	auipc	ra,0xfffff
    800049f2:	092080e7          	jalr	146(ra) # 80003a80 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800049f6:	854a                	mv	a0,s2
    800049f8:	70a2                	ld	ra,40(sp)
    800049fa:	7402                	ld	s0,32(sp)
    800049fc:	64e2                	ld	s1,24(sp)
    800049fe:	6942                	ld	s2,16(sp)
    80004a00:	69a2                	ld	s3,8(sp)
    80004a02:	6145                	addi	sp,sp,48
    80004a04:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004a06:	6908                	ld	a0,16(a0)
    80004a08:	00000097          	auipc	ra,0x0
    80004a0c:	3c8080e7          	jalr	968(ra) # 80004dd0 <piperead>
    80004a10:	892a                	mv	s2,a0
    80004a12:	b7d5                	j	800049f6 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004a14:	02451783          	lh	a5,36(a0)
    80004a18:	03079693          	slli	a3,a5,0x30
    80004a1c:	92c1                	srli	a3,a3,0x30
    80004a1e:	4725                	li	a4,9
    80004a20:	02d76863          	bltu	a4,a3,80004a50 <fileread+0xba>
    80004a24:	0792                	slli	a5,a5,0x4
    80004a26:	0001d717          	auipc	a4,0x1d
    80004a2a:	8f270713          	addi	a4,a4,-1806 # 80021318 <devsw>
    80004a2e:	97ba                	add	a5,a5,a4
    80004a30:	639c                	ld	a5,0(a5)
    80004a32:	c38d                	beqz	a5,80004a54 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004a34:	4505                	li	a0,1
    80004a36:	9782                	jalr	a5
    80004a38:	892a                	mv	s2,a0
    80004a3a:	bf75                	j	800049f6 <fileread+0x60>
    panic("fileread");
    80004a3c:	00004517          	auipc	a0,0x4
    80004a40:	cd450513          	addi	a0,a0,-812 # 80008710 <syscalls+0x280>
    80004a44:	ffffc097          	auipc	ra,0xffffc
    80004a48:	afa080e7          	jalr	-1286(ra) # 8000053e <panic>
    return -1;
    80004a4c:	597d                	li	s2,-1
    80004a4e:	b765                	j	800049f6 <fileread+0x60>
      return -1;
    80004a50:	597d                	li	s2,-1
    80004a52:	b755                	j	800049f6 <fileread+0x60>
    80004a54:	597d                	li	s2,-1
    80004a56:	b745                	j	800049f6 <fileread+0x60>

0000000080004a58 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004a58:	715d                	addi	sp,sp,-80
    80004a5a:	e486                	sd	ra,72(sp)
    80004a5c:	e0a2                	sd	s0,64(sp)
    80004a5e:	fc26                	sd	s1,56(sp)
    80004a60:	f84a                	sd	s2,48(sp)
    80004a62:	f44e                	sd	s3,40(sp)
    80004a64:	f052                	sd	s4,32(sp)
    80004a66:	ec56                	sd	s5,24(sp)
    80004a68:	e85a                	sd	s6,16(sp)
    80004a6a:	e45e                	sd	s7,8(sp)
    80004a6c:	e062                	sd	s8,0(sp)
    80004a6e:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004a70:	00954783          	lbu	a5,9(a0)
    80004a74:	10078663          	beqz	a5,80004b80 <filewrite+0x128>
    80004a78:	892a                	mv	s2,a0
    80004a7a:	8aae                	mv	s5,a1
    80004a7c:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004a7e:	411c                	lw	a5,0(a0)
    80004a80:	4705                	li	a4,1
    80004a82:	02e78263          	beq	a5,a4,80004aa6 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004a86:	470d                	li	a4,3
    80004a88:	02e78663          	beq	a5,a4,80004ab4 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004a8c:	4709                	li	a4,2
    80004a8e:	0ee79163          	bne	a5,a4,80004b70 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004a92:	0ac05d63          	blez	a2,80004b4c <filewrite+0xf4>
    int i = 0;
    80004a96:	4981                	li	s3,0
    80004a98:	6b05                	lui	s6,0x1
    80004a9a:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004a9e:	6b85                	lui	s7,0x1
    80004aa0:	c00b8b9b          	addiw	s7,s7,-1024
    80004aa4:	a861                	j	80004b3c <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004aa6:	6908                	ld	a0,16(a0)
    80004aa8:	00000097          	auipc	ra,0x0
    80004aac:	22e080e7          	jalr	558(ra) # 80004cd6 <pipewrite>
    80004ab0:	8a2a                	mv	s4,a0
    80004ab2:	a045                	j	80004b52 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004ab4:	02451783          	lh	a5,36(a0)
    80004ab8:	03079693          	slli	a3,a5,0x30
    80004abc:	92c1                	srli	a3,a3,0x30
    80004abe:	4725                	li	a4,9
    80004ac0:	0cd76263          	bltu	a4,a3,80004b84 <filewrite+0x12c>
    80004ac4:	0792                	slli	a5,a5,0x4
    80004ac6:	0001d717          	auipc	a4,0x1d
    80004aca:	85270713          	addi	a4,a4,-1966 # 80021318 <devsw>
    80004ace:	97ba                	add	a5,a5,a4
    80004ad0:	679c                	ld	a5,8(a5)
    80004ad2:	cbdd                	beqz	a5,80004b88 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004ad4:	4505                	li	a0,1
    80004ad6:	9782                	jalr	a5
    80004ad8:	8a2a                	mv	s4,a0
    80004ada:	a8a5                	j	80004b52 <filewrite+0xfa>
    80004adc:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004ae0:	00000097          	auipc	ra,0x0
    80004ae4:	8b0080e7          	jalr	-1872(ra) # 80004390 <begin_op>
      ilock(f->ip);
    80004ae8:	01893503          	ld	a0,24(s2)
    80004aec:	fffff097          	auipc	ra,0xfffff
    80004af0:	ed2080e7          	jalr	-302(ra) # 800039be <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004af4:	8762                	mv	a4,s8
    80004af6:	02092683          	lw	a3,32(s2)
    80004afa:	01598633          	add	a2,s3,s5
    80004afe:	4585                	li	a1,1
    80004b00:	01893503          	ld	a0,24(s2)
    80004b04:	fffff097          	auipc	ra,0xfffff
    80004b08:	266080e7          	jalr	614(ra) # 80003d6a <writei>
    80004b0c:	84aa                	mv	s1,a0
    80004b0e:	00a05763          	blez	a0,80004b1c <filewrite+0xc4>
        f->off += r;
    80004b12:	02092783          	lw	a5,32(s2)
    80004b16:	9fa9                	addw	a5,a5,a0
    80004b18:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004b1c:	01893503          	ld	a0,24(s2)
    80004b20:	fffff097          	auipc	ra,0xfffff
    80004b24:	f60080e7          	jalr	-160(ra) # 80003a80 <iunlock>
      end_op();
    80004b28:	00000097          	auipc	ra,0x0
    80004b2c:	8e8080e7          	jalr	-1816(ra) # 80004410 <end_op>

      if(r != n1){
    80004b30:	009c1f63          	bne	s8,s1,80004b4e <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004b34:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004b38:	0149db63          	bge	s3,s4,80004b4e <filewrite+0xf6>
      int n1 = n - i;
    80004b3c:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004b40:	84be                	mv	s1,a5
    80004b42:	2781                	sext.w	a5,a5
    80004b44:	f8fb5ce3          	bge	s6,a5,80004adc <filewrite+0x84>
    80004b48:	84de                	mv	s1,s7
    80004b4a:	bf49                	j	80004adc <filewrite+0x84>
    int i = 0;
    80004b4c:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004b4e:	013a1f63          	bne	s4,s3,80004b6c <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004b52:	8552                	mv	a0,s4
    80004b54:	60a6                	ld	ra,72(sp)
    80004b56:	6406                	ld	s0,64(sp)
    80004b58:	74e2                	ld	s1,56(sp)
    80004b5a:	7942                	ld	s2,48(sp)
    80004b5c:	79a2                	ld	s3,40(sp)
    80004b5e:	7a02                	ld	s4,32(sp)
    80004b60:	6ae2                	ld	s5,24(sp)
    80004b62:	6b42                	ld	s6,16(sp)
    80004b64:	6ba2                	ld	s7,8(sp)
    80004b66:	6c02                	ld	s8,0(sp)
    80004b68:	6161                	addi	sp,sp,80
    80004b6a:	8082                	ret
    ret = (i == n ? n : -1);
    80004b6c:	5a7d                	li	s4,-1
    80004b6e:	b7d5                	j	80004b52 <filewrite+0xfa>
    panic("filewrite");
    80004b70:	00004517          	auipc	a0,0x4
    80004b74:	bb050513          	addi	a0,a0,-1104 # 80008720 <syscalls+0x290>
    80004b78:	ffffc097          	auipc	ra,0xffffc
    80004b7c:	9c6080e7          	jalr	-1594(ra) # 8000053e <panic>
    return -1;
    80004b80:	5a7d                	li	s4,-1
    80004b82:	bfc1                	j	80004b52 <filewrite+0xfa>
      return -1;
    80004b84:	5a7d                	li	s4,-1
    80004b86:	b7f1                	j	80004b52 <filewrite+0xfa>
    80004b88:	5a7d                	li	s4,-1
    80004b8a:	b7e1                	j	80004b52 <filewrite+0xfa>

0000000080004b8c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004b8c:	7179                	addi	sp,sp,-48
    80004b8e:	f406                	sd	ra,40(sp)
    80004b90:	f022                	sd	s0,32(sp)
    80004b92:	ec26                	sd	s1,24(sp)
    80004b94:	e84a                	sd	s2,16(sp)
    80004b96:	e44e                	sd	s3,8(sp)
    80004b98:	e052                	sd	s4,0(sp)
    80004b9a:	1800                	addi	s0,sp,48
    80004b9c:	84aa                	mv	s1,a0
    80004b9e:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004ba0:	0005b023          	sd	zero,0(a1)
    80004ba4:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004ba8:	00000097          	auipc	ra,0x0
    80004bac:	bf8080e7          	jalr	-1032(ra) # 800047a0 <filealloc>
    80004bb0:	e088                	sd	a0,0(s1)
    80004bb2:	c551                	beqz	a0,80004c3e <pipealloc+0xb2>
    80004bb4:	00000097          	auipc	ra,0x0
    80004bb8:	bec080e7          	jalr	-1044(ra) # 800047a0 <filealloc>
    80004bbc:	00aa3023          	sd	a0,0(s4)
    80004bc0:	c92d                	beqz	a0,80004c32 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004bc2:	ffffc097          	auipc	ra,0xffffc
    80004bc6:	f32080e7          	jalr	-206(ra) # 80000af4 <kalloc>
    80004bca:	892a                	mv	s2,a0
    80004bcc:	c125                	beqz	a0,80004c2c <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004bce:	4985                	li	s3,1
    80004bd0:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004bd4:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004bd8:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004bdc:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004be0:	00004597          	auipc	a1,0x4
    80004be4:	b5058593          	addi	a1,a1,-1200 # 80008730 <syscalls+0x2a0>
    80004be8:	ffffc097          	auipc	ra,0xffffc
    80004bec:	f6c080e7          	jalr	-148(ra) # 80000b54 <initlock>
  (*f0)->type = FD_PIPE;
    80004bf0:	609c                	ld	a5,0(s1)
    80004bf2:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004bf6:	609c                	ld	a5,0(s1)
    80004bf8:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004bfc:	609c                	ld	a5,0(s1)
    80004bfe:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004c02:	609c                	ld	a5,0(s1)
    80004c04:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004c08:	000a3783          	ld	a5,0(s4)
    80004c0c:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004c10:	000a3783          	ld	a5,0(s4)
    80004c14:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004c18:	000a3783          	ld	a5,0(s4)
    80004c1c:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004c20:	000a3783          	ld	a5,0(s4)
    80004c24:	0127b823          	sd	s2,16(a5)
  return 0;
    80004c28:	4501                	li	a0,0
    80004c2a:	a025                	j	80004c52 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004c2c:	6088                	ld	a0,0(s1)
    80004c2e:	e501                	bnez	a0,80004c36 <pipealloc+0xaa>
    80004c30:	a039                	j	80004c3e <pipealloc+0xb2>
    80004c32:	6088                	ld	a0,0(s1)
    80004c34:	c51d                	beqz	a0,80004c62 <pipealloc+0xd6>
    fileclose(*f0);
    80004c36:	00000097          	auipc	ra,0x0
    80004c3a:	c26080e7          	jalr	-986(ra) # 8000485c <fileclose>
  if(*f1)
    80004c3e:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004c42:	557d                	li	a0,-1
  if(*f1)
    80004c44:	c799                	beqz	a5,80004c52 <pipealloc+0xc6>
    fileclose(*f1);
    80004c46:	853e                	mv	a0,a5
    80004c48:	00000097          	auipc	ra,0x0
    80004c4c:	c14080e7          	jalr	-1004(ra) # 8000485c <fileclose>
  return -1;
    80004c50:	557d                	li	a0,-1
}
    80004c52:	70a2                	ld	ra,40(sp)
    80004c54:	7402                	ld	s0,32(sp)
    80004c56:	64e2                	ld	s1,24(sp)
    80004c58:	6942                	ld	s2,16(sp)
    80004c5a:	69a2                	ld	s3,8(sp)
    80004c5c:	6a02                	ld	s4,0(sp)
    80004c5e:	6145                	addi	sp,sp,48
    80004c60:	8082                	ret
  return -1;
    80004c62:	557d                	li	a0,-1
    80004c64:	b7fd                	j	80004c52 <pipealloc+0xc6>

0000000080004c66 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004c66:	1101                	addi	sp,sp,-32
    80004c68:	ec06                	sd	ra,24(sp)
    80004c6a:	e822                	sd	s0,16(sp)
    80004c6c:	e426                	sd	s1,8(sp)
    80004c6e:	e04a                	sd	s2,0(sp)
    80004c70:	1000                	addi	s0,sp,32
    80004c72:	84aa                	mv	s1,a0
    80004c74:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004c76:	ffffc097          	auipc	ra,0xffffc
    80004c7a:	f6e080e7          	jalr	-146(ra) # 80000be4 <acquire>
  if(writable){
    80004c7e:	02090d63          	beqz	s2,80004cb8 <pipeclose+0x52>
    pi->writeopen = 0;
    80004c82:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004c86:	21848513          	addi	a0,s1,536
    80004c8a:	ffffd097          	auipc	ra,0xffffd
    80004c8e:	56e080e7          	jalr	1390(ra) # 800021f8 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004c92:	2204b783          	ld	a5,544(s1)
    80004c96:	eb95                	bnez	a5,80004cca <pipeclose+0x64>
    release(&pi->lock);
    80004c98:	8526                	mv	a0,s1
    80004c9a:	ffffc097          	auipc	ra,0xffffc
    80004c9e:	ffe080e7          	jalr	-2(ra) # 80000c98 <release>
    kfree((char*)pi);
    80004ca2:	8526                	mv	a0,s1
    80004ca4:	ffffc097          	auipc	ra,0xffffc
    80004ca8:	d54080e7          	jalr	-684(ra) # 800009f8 <kfree>
  } else
    release(&pi->lock);
}
    80004cac:	60e2                	ld	ra,24(sp)
    80004cae:	6442                	ld	s0,16(sp)
    80004cb0:	64a2                	ld	s1,8(sp)
    80004cb2:	6902                	ld	s2,0(sp)
    80004cb4:	6105                	addi	sp,sp,32
    80004cb6:	8082                	ret
    pi->readopen = 0;
    80004cb8:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004cbc:	21c48513          	addi	a0,s1,540
    80004cc0:	ffffd097          	auipc	ra,0xffffd
    80004cc4:	538080e7          	jalr	1336(ra) # 800021f8 <wakeup>
    80004cc8:	b7e9                	j	80004c92 <pipeclose+0x2c>
    release(&pi->lock);
    80004cca:	8526                	mv	a0,s1
    80004ccc:	ffffc097          	auipc	ra,0xffffc
    80004cd0:	fcc080e7          	jalr	-52(ra) # 80000c98 <release>
}
    80004cd4:	bfe1                	j	80004cac <pipeclose+0x46>

0000000080004cd6 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004cd6:	7159                	addi	sp,sp,-112
    80004cd8:	f486                	sd	ra,104(sp)
    80004cda:	f0a2                	sd	s0,96(sp)
    80004cdc:	eca6                	sd	s1,88(sp)
    80004cde:	e8ca                	sd	s2,80(sp)
    80004ce0:	e4ce                	sd	s3,72(sp)
    80004ce2:	e0d2                	sd	s4,64(sp)
    80004ce4:	fc56                	sd	s5,56(sp)
    80004ce6:	f85a                	sd	s6,48(sp)
    80004ce8:	f45e                	sd	s7,40(sp)
    80004cea:	f062                	sd	s8,32(sp)
    80004cec:	ec66                	sd	s9,24(sp)
    80004cee:	1880                	addi	s0,sp,112
    80004cf0:	84aa                	mv	s1,a0
    80004cf2:	8aae                	mv	s5,a1
    80004cf4:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004cf6:	ffffd097          	auipc	ra,0xffffd
    80004cfa:	cba080e7          	jalr	-838(ra) # 800019b0 <myproc>
    80004cfe:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004d00:	8526                	mv	a0,s1
    80004d02:	ffffc097          	auipc	ra,0xffffc
    80004d06:	ee2080e7          	jalr	-286(ra) # 80000be4 <acquire>
  while(i < n){
    80004d0a:	0d405163          	blez	s4,80004dcc <pipewrite+0xf6>
    80004d0e:	8ba6                	mv	s7,s1
  int i = 0;
    80004d10:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d12:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004d14:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004d18:	21c48c13          	addi	s8,s1,540
    80004d1c:	a08d                	j	80004d7e <pipewrite+0xa8>
      release(&pi->lock);
    80004d1e:	8526                	mv	a0,s1
    80004d20:	ffffc097          	auipc	ra,0xffffc
    80004d24:	f78080e7          	jalr	-136(ra) # 80000c98 <release>
      return -1;
    80004d28:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004d2a:	854a                	mv	a0,s2
    80004d2c:	70a6                	ld	ra,104(sp)
    80004d2e:	7406                	ld	s0,96(sp)
    80004d30:	64e6                	ld	s1,88(sp)
    80004d32:	6946                	ld	s2,80(sp)
    80004d34:	69a6                	ld	s3,72(sp)
    80004d36:	6a06                	ld	s4,64(sp)
    80004d38:	7ae2                	ld	s5,56(sp)
    80004d3a:	7b42                	ld	s6,48(sp)
    80004d3c:	7ba2                	ld	s7,40(sp)
    80004d3e:	7c02                	ld	s8,32(sp)
    80004d40:	6ce2                	ld	s9,24(sp)
    80004d42:	6165                	addi	sp,sp,112
    80004d44:	8082                	ret
      wakeup(&pi->nread);
    80004d46:	8566                	mv	a0,s9
    80004d48:	ffffd097          	auipc	ra,0xffffd
    80004d4c:	4b0080e7          	jalr	1200(ra) # 800021f8 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004d50:	85de                	mv	a1,s7
    80004d52:	8562                	mv	a0,s8
    80004d54:	ffffd097          	auipc	ra,0xffffd
    80004d58:	318080e7          	jalr	792(ra) # 8000206c <sleep>
    80004d5c:	a839                	j	80004d7a <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004d5e:	21c4a783          	lw	a5,540(s1)
    80004d62:	0017871b          	addiw	a4,a5,1
    80004d66:	20e4ae23          	sw	a4,540(s1)
    80004d6a:	1ff7f793          	andi	a5,a5,511
    80004d6e:	97a6                	add	a5,a5,s1
    80004d70:	f9f44703          	lbu	a4,-97(s0)
    80004d74:	00e78c23          	sb	a4,24(a5)
      i++;
    80004d78:	2905                	addiw	s2,s2,1
  while(i < n){
    80004d7a:	03495d63          	bge	s2,s4,80004db4 <pipewrite+0xde>
    if(pi->readopen == 0 || pr->killed){
    80004d7e:	2204a783          	lw	a5,544(s1)
    80004d82:	dfd1                	beqz	a5,80004d1e <pipewrite+0x48>
    80004d84:	0289a783          	lw	a5,40(s3)
    80004d88:	fbd9                	bnez	a5,80004d1e <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004d8a:	2184a783          	lw	a5,536(s1)
    80004d8e:	21c4a703          	lw	a4,540(s1)
    80004d92:	2007879b          	addiw	a5,a5,512
    80004d96:	faf708e3          	beq	a4,a5,80004d46 <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d9a:	4685                	li	a3,1
    80004d9c:	01590633          	add	a2,s2,s5
    80004da0:	f9f40593          	addi	a1,s0,-97
    80004da4:	0509b503          	ld	a0,80(s3)
    80004da8:	ffffd097          	auipc	ra,0xffffd
    80004dac:	956080e7          	jalr	-1706(ra) # 800016fe <copyin>
    80004db0:	fb6517e3          	bne	a0,s6,80004d5e <pipewrite+0x88>
  wakeup(&pi->nread);
    80004db4:	21848513          	addi	a0,s1,536
    80004db8:	ffffd097          	auipc	ra,0xffffd
    80004dbc:	440080e7          	jalr	1088(ra) # 800021f8 <wakeup>
  release(&pi->lock);
    80004dc0:	8526                	mv	a0,s1
    80004dc2:	ffffc097          	auipc	ra,0xffffc
    80004dc6:	ed6080e7          	jalr	-298(ra) # 80000c98 <release>
  return i;
    80004dca:	b785                	j	80004d2a <pipewrite+0x54>
  int i = 0;
    80004dcc:	4901                	li	s2,0
    80004dce:	b7dd                	j	80004db4 <pipewrite+0xde>

0000000080004dd0 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004dd0:	715d                	addi	sp,sp,-80
    80004dd2:	e486                	sd	ra,72(sp)
    80004dd4:	e0a2                	sd	s0,64(sp)
    80004dd6:	fc26                	sd	s1,56(sp)
    80004dd8:	f84a                	sd	s2,48(sp)
    80004dda:	f44e                	sd	s3,40(sp)
    80004ddc:	f052                	sd	s4,32(sp)
    80004dde:	ec56                	sd	s5,24(sp)
    80004de0:	e85a                	sd	s6,16(sp)
    80004de2:	0880                	addi	s0,sp,80
    80004de4:	84aa                	mv	s1,a0
    80004de6:	892e                	mv	s2,a1
    80004de8:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004dea:	ffffd097          	auipc	ra,0xffffd
    80004dee:	bc6080e7          	jalr	-1082(ra) # 800019b0 <myproc>
    80004df2:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004df4:	8b26                	mv	s6,s1
    80004df6:	8526                	mv	a0,s1
    80004df8:	ffffc097          	auipc	ra,0xffffc
    80004dfc:	dec080e7          	jalr	-532(ra) # 80000be4 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e00:	2184a703          	lw	a4,536(s1)
    80004e04:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004e08:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e0c:	02f71463          	bne	a4,a5,80004e34 <piperead+0x64>
    80004e10:	2244a783          	lw	a5,548(s1)
    80004e14:	c385                	beqz	a5,80004e34 <piperead+0x64>
    if(pr->killed){
    80004e16:	028a2783          	lw	a5,40(s4)
    80004e1a:	ebc1                	bnez	a5,80004eaa <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004e1c:	85da                	mv	a1,s6
    80004e1e:	854e                	mv	a0,s3
    80004e20:	ffffd097          	auipc	ra,0xffffd
    80004e24:	24c080e7          	jalr	588(ra) # 8000206c <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e28:	2184a703          	lw	a4,536(s1)
    80004e2c:	21c4a783          	lw	a5,540(s1)
    80004e30:	fef700e3          	beq	a4,a5,80004e10 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e34:	09505263          	blez	s5,80004eb8 <piperead+0xe8>
    80004e38:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e3a:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80004e3c:	2184a783          	lw	a5,536(s1)
    80004e40:	21c4a703          	lw	a4,540(s1)
    80004e44:	02f70d63          	beq	a4,a5,80004e7e <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004e48:	0017871b          	addiw	a4,a5,1
    80004e4c:	20e4ac23          	sw	a4,536(s1)
    80004e50:	1ff7f793          	andi	a5,a5,511
    80004e54:	97a6                	add	a5,a5,s1
    80004e56:	0187c783          	lbu	a5,24(a5)
    80004e5a:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e5e:	4685                	li	a3,1
    80004e60:	fbf40613          	addi	a2,s0,-65
    80004e64:	85ca                	mv	a1,s2
    80004e66:	050a3503          	ld	a0,80(s4)
    80004e6a:	ffffd097          	auipc	ra,0xffffd
    80004e6e:	808080e7          	jalr	-2040(ra) # 80001672 <copyout>
    80004e72:	01650663          	beq	a0,s6,80004e7e <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e76:	2985                	addiw	s3,s3,1
    80004e78:	0905                	addi	s2,s2,1
    80004e7a:	fd3a91e3          	bne	s5,s3,80004e3c <piperead+0x6c>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004e7e:	21c48513          	addi	a0,s1,540
    80004e82:	ffffd097          	auipc	ra,0xffffd
    80004e86:	376080e7          	jalr	886(ra) # 800021f8 <wakeup>
  release(&pi->lock);
    80004e8a:	8526                	mv	a0,s1
    80004e8c:	ffffc097          	auipc	ra,0xffffc
    80004e90:	e0c080e7          	jalr	-500(ra) # 80000c98 <release>
  return i;
}
    80004e94:	854e                	mv	a0,s3
    80004e96:	60a6                	ld	ra,72(sp)
    80004e98:	6406                	ld	s0,64(sp)
    80004e9a:	74e2                	ld	s1,56(sp)
    80004e9c:	7942                	ld	s2,48(sp)
    80004e9e:	79a2                	ld	s3,40(sp)
    80004ea0:	7a02                	ld	s4,32(sp)
    80004ea2:	6ae2                	ld	s5,24(sp)
    80004ea4:	6b42                	ld	s6,16(sp)
    80004ea6:	6161                	addi	sp,sp,80
    80004ea8:	8082                	ret
      release(&pi->lock);
    80004eaa:	8526                	mv	a0,s1
    80004eac:	ffffc097          	auipc	ra,0xffffc
    80004eb0:	dec080e7          	jalr	-532(ra) # 80000c98 <release>
      return -1;
    80004eb4:	59fd                	li	s3,-1
    80004eb6:	bff9                	j	80004e94 <piperead+0xc4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004eb8:	4981                	li	s3,0
    80004eba:	b7d1                	j	80004e7e <piperead+0xae>

0000000080004ebc <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004ebc:	df010113          	addi	sp,sp,-528
    80004ec0:	20113423          	sd	ra,520(sp)
    80004ec4:	20813023          	sd	s0,512(sp)
    80004ec8:	ffa6                	sd	s1,504(sp)
    80004eca:	fbca                	sd	s2,496(sp)
    80004ecc:	f7ce                	sd	s3,488(sp)
    80004ece:	f3d2                	sd	s4,480(sp)
    80004ed0:	efd6                	sd	s5,472(sp)
    80004ed2:	ebda                	sd	s6,464(sp)
    80004ed4:	e7de                	sd	s7,456(sp)
    80004ed6:	e3e2                	sd	s8,448(sp)
    80004ed8:	ff66                	sd	s9,440(sp)
    80004eda:	fb6a                	sd	s10,432(sp)
    80004edc:	f76e                	sd	s11,424(sp)
    80004ede:	0c00                	addi	s0,sp,528
    80004ee0:	84aa                	mv	s1,a0
    80004ee2:	dea43c23          	sd	a0,-520(s0)
    80004ee6:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004eea:	ffffd097          	auipc	ra,0xffffd
    80004eee:	ac6080e7          	jalr	-1338(ra) # 800019b0 <myproc>
    80004ef2:	892a                	mv	s2,a0

  begin_op();
    80004ef4:	fffff097          	auipc	ra,0xfffff
    80004ef8:	49c080e7          	jalr	1180(ra) # 80004390 <begin_op>

  if((ip = namei(path)) == 0){
    80004efc:	8526                	mv	a0,s1
    80004efe:	fffff097          	auipc	ra,0xfffff
    80004f02:	276080e7          	jalr	630(ra) # 80004174 <namei>
    80004f06:	c92d                	beqz	a0,80004f78 <exec+0xbc>
    80004f08:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004f0a:	fffff097          	auipc	ra,0xfffff
    80004f0e:	ab4080e7          	jalr	-1356(ra) # 800039be <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004f12:	04000713          	li	a4,64
    80004f16:	4681                	li	a3,0
    80004f18:	e5040613          	addi	a2,s0,-432
    80004f1c:	4581                	li	a1,0
    80004f1e:	8526                	mv	a0,s1
    80004f20:	fffff097          	auipc	ra,0xfffff
    80004f24:	d52080e7          	jalr	-686(ra) # 80003c72 <readi>
    80004f28:	04000793          	li	a5,64
    80004f2c:	00f51a63          	bne	a0,a5,80004f40 <exec+0x84>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004f30:	e5042703          	lw	a4,-432(s0)
    80004f34:	464c47b7          	lui	a5,0x464c4
    80004f38:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004f3c:	04f70463          	beq	a4,a5,80004f84 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004f40:	8526                	mv	a0,s1
    80004f42:	fffff097          	auipc	ra,0xfffff
    80004f46:	cde080e7          	jalr	-802(ra) # 80003c20 <iunlockput>
    end_op();
    80004f4a:	fffff097          	auipc	ra,0xfffff
    80004f4e:	4c6080e7          	jalr	1222(ra) # 80004410 <end_op>
  }
  return -1;
    80004f52:	557d                	li	a0,-1
}
    80004f54:	20813083          	ld	ra,520(sp)
    80004f58:	20013403          	ld	s0,512(sp)
    80004f5c:	74fe                	ld	s1,504(sp)
    80004f5e:	795e                	ld	s2,496(sp)
    80004f60:	79be                	ld	s3,488(sp)
    80004f62:	7a1e                	ld	s4,480(sp)
    80004f64:	6afe                	ld	s5,472(sp)
    80004f66:	6b5e                	ld	s6,464(sp)
    80004f68:	6bbe                	ld	s7,456(sp)
    80004f6a:	6c1e                	ld	s8,448(sp)
    80004f6c:	7cfa                	ld	s9,440(sp)
    80004f6e:	7d5a                	ld	s10,432(sp)
    80004f70:	7dba                	ld	s11,424(sp)
    80004f72:	21010113          	addi	sp,sp,528
    80004f76:	8082                	ret
    end_op();
    80004f78:	fffff097          	auipc	ra,0xfffff
    80004f7c:	498080e7          	jalr	1176(ra) # 80004410 <end_op>
    return -1;
    80004f80:	557d                	li	a0,-1
    80004f82:	bfc9                	j	80004f54 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004f84:	854a                	mv	a0,s2
    80004f86:	ffffd097          	auipc	ra,0xffffd
    80004f8a:	aee080e7          	jalr	-1298(ra) # 80001a74 <proc_pagetable>
    80004f8e:	8baa                	mv	s7,a0
    80004f90:	d945                	beqz	a0,80004f40 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f92:	e7042983          	lw	s3,-400(s0)
    80004f96:	e8845783          	lhu	a5,-376(s0)
    80004f9a:	c7ad                	beqz	a5,80005004 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f9c:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f9e:	4b01                	li	s6,0
    if((ph.vaddr % PGSIZE) != 0)
    80004fa0:	6c85                	lui	s9,0x1
    80004fa2:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004fa6:	def43823          	sd	a5,-528(s0)
    80004faa:	a42d                	j	800051d4 <exec+0x318>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004fac:	00003517          	auipc	a0,0x3
    80004fb0:	78c50513          	addi	a0,a0,1932 # 80008738 <syscalls+0x2a8>
    80004fb4:	ffffb097          	auipc	ra,0xffffb
    80004fb8:	58a080e7          	jalr	1418(ra) # 8000053e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004fbc:	8756                	mv	a4,s5
    80004fbe:	012d86bb          	addw	a3,s11,s2
    80004fc2:	4581                	li	a1,0
    80004fc4:	8526                	mv	a0,s1
    80004fc6:	fffff097          	auipc	ra,0xfffff
    80004fca:	cac080e7          	jalr	-852(ra) # 80003c72 <readi>
    80004fce:	2501                	sext.w	a0,a0
    80004fd0:	1aaa9963          	bne	s5,a0,80005182 <exec+0x2c6>
  for(i = 0; i < sz; i += PGSIZE){
    80004fd4:	6785                	lui	a5,0x1
    80004fd6:	0127893b          	addw	s2,a5,s2
    80004fda:	77fd                	lui	a5,0xfffff
    80004fdc:	01478a3b          	addw	s4,a5,s4
    80004fe0:	1f897163          	bgeu	s2,s8,800051c2 <exec+0x306>
    pa = walkaddr(pagetable, va + i);
    80004fe4:	02091593          	slli	a1,s2,0x20
    80004fe8:	9181                	srli	a1,a1,0x20
    80004fea:	95ea                	add	a1,a1,s10
    80004fec:	855e                	mv	a0,s7
    80004fee:	ffffc097          	auipc	ra,0xffffc
    80004ff2:	080080e7          	jalr	128(ra) # 8000106e <walkaddr>
    80004ff6:	862a                	mv	a2,a0
    if(pa == 0)
    80004ff8:	d955                	beqz	a0,80004fac <exec+0xf0>
      n = PGSIZE;
    80004ffa:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80004ffc:	fd9a70e3          	bgeu	s4,s9,80004fbc <exec+0x100>
      n = sz - i;
    80005000:	8ad2                	mv	s5,s4
    80005002:	bf6d                	j	80004fbc <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005004:	4901                	li	s2,0
  iunlockput(ip);
    80005006:	8526                	mv	a0,s1
    80005008:	fffff097          	auipc	ra,0xfffff
    8000500c:	c18080e7          	jalr	-1000(ra) # 80003c20 <iunlockput>
  end_op();
    80005010:	fffff097          	auipc	ra,0xfffff
    80005014:	400080e7          	jalr	1024(ra) # 80004410 <end_op>
  p = myproc();
    80005018:	ffffd097          	auipc	ra,0xffffd
    8000501c:	998080e7          	jalr	-1640(ra) # 800019b0 <myproc>
    80005020:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80005022:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005026:	6785                	lui	a5,0x1
    80005028:	17fd                	addi	a5,a5,-1
    8000502a:	993e                	add	s2,s2,a5
    8000502c:	757d                	lui	a0,0xfffff
    8000502e:	00a977b3          	and	a5,s2,a0
    80005032:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005036:	6609                	lui	a2,0x2
    80005038:	963e                	add	a2,a2,a5
    8000503a:	85be                	mv	a1,a5
    8000503c:	855e                	mv	a0,s7
    8000503e:	ffffc097          	auipc	ra,0xffffc
    80005042:	3e4080e7          	jalr	996(ra) # 80001422 <uvmalloc>
    80005046:	8b2a                	mv	s6,a0
  ip = 0;
    80005048:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    8000504a:	12050c63          	beqz	a0,80005182 <exec+0x2c6>
  uvmclear(pagetable, sz-2*PGSIZE);
    8000504e:	75f9                	lui	a1,0xffffe
    80005050:	95aa                	add	a1,a1,a0
    80005052:	855e                	mv	a0,s7
    80005054:	ffffc097          	auipc	ra,0xffffc
    80005058:	5ec080e7          	jalr	1516(ra) # 80001640 <uvmclear>
  stackbase = sp - PGSIZE;
    8000505c:	7c7d                	lui	s8,0xfffff
    8000505e:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80005060:	e0043783          	ld	a5,-512(s0)
    80005064:	6388                	ld	a0,0(a5)
    80005066:	c535                	beqz	a0,800050d2 <exec+0x216>
    80005068:	e9040993          	addi	s3,s0,-368
    8000506c:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80005070:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80005072:	ffffc097          	auipc	ra,0xffffc
    80005076:	df2080e7          	jalr	-526(ra) # 80000e64 <strlen>
    8000507a:	2505                	addiw	a0,a0,1
    8000507c:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005080:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005084:	13896363          	bltu	s2,s8,800051aa <exec+0x2ee>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005088:	e0043d83          	ld	s11,-512(s0)
    8000508c:	000dba03          	ld	s4,0(s11)
    80005090:	8552                	mv	a0,s4
    80005092:	ffffc097          	auipc	ra,0xffffc
    80005096:	dd2080e7          	jalr	-558(ra) # 80000e64 <strlen>
    8000509a:	0015069b          	addiw	a3,a0,1
    8000509e:	8652                	mv	a2,s4
    800050a0:	85ca                	mv	a1,s2
    800050a2:	855e                	mv	a0,s7
    800050a4:	ffffc097          	auipc	ra,0xffffc
    800050a8:	5ce080e7          	jalr	1486(ra) # 80001672 <copyout>
    800050ac:	10054363          	bltz	a0,800051b2 <exec+0x2f6>
    ustack[argc] = sp;
    800050b0:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800050b4:	0485                	addi	s1,s1,1
    800050b6:	008d8793          	addi	a5,s11,8
    800050ba:	e0f43023          	sd	a5,-512(s0)
    800050be:	008db503          	ld	a0,8(s11)
    800050c2:	c911                	beqz	a0,800050d6 <exec+0x21a>
    if(argc >= MAXARG)
    800050c4:	09a1                	addi	s3,s3,8
    800050c6:	fb3c96e3          	bne	s9,s3,80005072 <exec+0x1b6>
  sz = sz1;
    800050ca:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800050ce:	4481                	li	s1,0
    800050d0:	a84d                	j	80005182 <exec+0x2c6>
  sp = sz;
    800050d2:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    800050d4:	4481                	li	s1,0
  ustack[argc] = 0;
    800050d6:	00349793          	slli	a5,s1,0x3
    800050da:	f9040713          	addi	a4,s0,-112
    800050de:	97ba                	add	a5,a5,a4
    800050e0:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    800050e4:	00148693          	addi	a3,s1,1
    800050e8:	068e                	slli	a3,a3,0x3
    800050ea:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800050ee:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800050f2:	01897663          	bgeu	s2,s8,800050fe <exec+0x242>
  sz = sz1;
    800050f6:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800050fa:	4481                	li	s1,0
    800050fc:	a059                	j	80005182 <exec+0x2c6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800050fe:	e9040613          	addi	a2,s0,-368
    80005102:	85ca                	mv	a1,s2
    80005104:	855e                	mv	a0,s7
    80005106:	ffffc097          	auipc	ra,0xffffc
    8000510a:	56c080e7          	jalr	1388(ra) # 80001672 <copyout>
    8000510e:	0a054663          	bltz	a0,800051ba <exec+0x2fe>
  p->trapframe->a1 = sp;
    80005112:	058ab783          	ld	a5,88(s5)
    80005116:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000511a:	df843783          	ld	a5,-520(s0)
    8000511e:	0007c703          	lbu	a4,0(a5)
    80005122:	cf11                	beqz	a4,8000513e <exec+0x282>
    80005124:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005126:	02f00693          	li	a3,47
    8000512a:	a039                	j	80005138 <exec+0x27c>
      last = s+1;
    8000512c:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80005130:	0785                	addi	a5,a5,1
    80005132:	fff7c703          	lbu	a4,-1(a5)
    80005136:	c701                	beqz	a4,8000513e <exec+0x282>
    if(*s == '/')
    80005138:	fed71ce3          	bne	a4,a3,80005130 <exec+0x274>
    8000513c:	bfc5                	j	8000512c <exec+0x270>
  safestrcpy(p->name, last, sizeof(p->name));
    8000513e:	4641                	li	a2,16
    80005140:	df843583          	ld	a1,-520(s0)
    80005144:	158a8513          	addi	a0,s5,344
    80005148:	ffffc097          	auipc	ra,0xffffc
    8000514c:	cea080e7          	jalr	-790(ra) # 80000e32 <safestrcpy>
  oldpagetable = p->pagetable;
    80005150:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80005154:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    80005158:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000515c:	058ab783          	ld	a5,88(s5)
    80005160:	e6843703          	ld	a4,-408(s0)
    80005164:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005166:	058ab783          	ld	a5,88(s5)
    8000516a:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000516e:	85ea                	mv	a1,s10
    80005170:	ffffd097          	auipc	ra,0xffffd
    80005174:	9a0080e7          	jalr	-1632(ra) # 80001b10 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005178:	0004851b          	sext.w	a0,s1
    8000517c:	bbe1                	j	80004f54 <exec+0x98>
    8000517e:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    80005182:	e0843583          	ld	a1,-504(s0)
    80005186:	855e                	mv	a0,s7
    80005188:	ffffd097          	auipc	ra,0xffffd
    8000518c:	988080e7          	jalr	-1656(ra) # 80001b10 <proc_freepagetable>
  if(ip){
    80005190:	da0498e3          	bnez	s1,80004f40 <exec+0x84>
  return -1;
    80005194:	557d                	li	a0,-1
    80005196:	bb7d                	j	80004f54 <exec+0x98>
    80005198:	e1243423          	sd	s2,-504(s0)
    8000519c:	b7dd                	j	80005182 <exec+0x2c6>
    8000519e:	e1243423          	sd	s2,-504(s0)
    800051a2:	b7c5                	j	80005182 <exec+0x2c6>
    800051a4:	e1243423          	sd	s2,-504(s0)
    800051a8:	bfe9                	j	80005182 <exec+0x2c6>
  sz = sz1;
    800051aa:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800051ae:	4481                	li	s1,0
    800051b0:	bfc9                	j	80005182 <exec+0x2c6>
  sz = sz1;
    800051b2:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800051b6:	4481                	li	s1,0
    800051b8:	b7e9                	j	80005182 <exec+0x2c6>
  sz = sz1;
    800051ba:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800051be:	4481                	li	s1,0
    800051c0:	b7c9                	j	80005182 <exec+0x2c6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800051c2:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800051c6:	2b05                	addiw	s6,s6,1
    800051c8:	0389899b          	addiw	s3,s3,56
    800051cc:	e8845783          	lhu	a5,-376(s0)
    800051d0:	e2fb5be3          	bge	s6,a5,80005006 <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800051d4:	2981                	sext.w	s3,s3
    800051d6:	03800713          	li	a4,56
    800051da:	86ce                	mv	a3,s3
    800051dc:	e1840613          	addi	a2,s0,-488
    800051e0:	4581                	li	a1,0
    800051e2:	8526                	mv	a0,s1
    800051e4:	fffff097          	auipc	ra,0xfffff
    800051e8:	a8e080e7          	jalr	-1394(ra) # 80003c72 <readi>
    800051ec:	03800793          	li	a5,56
    800051f0:	f8f517e3          	bne	a0,a5,8000517e <exec+0x2c2>
    if(ph.type != ELF_PROG_LOAD)
    800051f4:	e1842783          	lw	a5,-488(s0)
    800051f8:	4705                	li	a4,1
    800051fa:	fce796e3          	bne	a5,a4,800051c6 <exec+0x30a>
    if(ph.memsz < ph.filesz)
    800051fe:	e4043603          	ld	a2,-448(s0)
    80005202:	e3843783          	ld	a5,-456(s0)
    80005206:	f8f669e3          	bltu	a2,a5,80005198 <exec+0x2dc>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000520a:	e2843783          	ld	a5,-472(s0)
    8000520e:	963e                	add	a2,a2,a5
    80005210:	f8f667e3          	bltu	a2,a5,8000519e <exec+0x2e2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005214:	85ca                	mv	a1,s2
    80005216:	855e                	mv	a0,s7
    80005218:	ffffc097          	auipc	ra,0xffffc
    8000521c:	20a080e7          	jalr	522(ra) # 80001422 <uvmalloc>
    80005220:	e0a43423          	sd	a0,-504(s0)
    80005224:	d141                	beqz	a0,800051a4 <exec+0x2e8>
    if((ph.vaddr % PGSIZE) != 0)
    80005226:	e2843d03          	ld	s10,-472(s0)
    8000522a:	df043783          	ld	a5,-528(s0)
    8000522e:	00fd77b3          	and	a5,s10,a5
    80005232:	fba1                	bnez	a5,80005182 <exec+0x2c6>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005234:	e2042d83          	lw	s11,-480(s0)
    80005238:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000523c:	f80c03e3          	beqz	s8,800051c2 <exec+0x306>
    80005240:	8a62                	mv	s4,s8
    80005242:	4901                	li	s2,0
    80005244:	b345                	j	80004fe4 <exec+0x128>

0000000080005246 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005246:	7179                	addi	sp,sp,-48
    80005248:	f406                	sd	ra,40(sp)
    8000524a:	f022                	sd	s0,32(sp)
    8000524c:	ec26                	sd	s1,24(sp)
    8000524e:	e84a                	sd	s2,16(sp)
    80005250:	1800                	addi	s0,sp,48
    80005252:	892e                	mv	s2,a1
    80005254:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005256:	fdc40593          	addi	a1,s0,-36
    8000525a:	ffffe097          	auipc	ra,0xffffe
    8000525e:	af0080e7          	jalr	-1296(ra) # 80002d4a <argint>
    80005262:	04054063          	bltz	a0,800052a2 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005266:	fdc42703          	lw	a4,-36(s0)
    8000526a:	47bd                	li	a5,15
    8000526c:	02e7ed63          	bltu	a5,a4,800052a6 <argfd+0x60>
    80005270:	ffffc097          	auipc	ra,0xffffc
    80005274:	740080e7          	jalr	1856(ra) # 800019b0 <myproc>
    80005278:	fdc42703          	lw	a4,-36(s0)
    8000527c:	01a70793          	addi	a5,a4,26
    80005280:	078e                	slli	a5,a5,0x3
    80005282:	953e                	add	a0,a0,a5
    80005284:	611c                	ld	a5,0(a0)
    80005286:	c395                	beqz	a5,800052aa <argfd+0x64>
    return -1;
  if(pfd)
    80005288:	00090463          	beqz	s2,80005290 <argfd+0x4a>
    *pfd = fd;
    8000528c:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005290:	4501                	li	a0,0
  if(pf)
    80005292:	c091                	beqz	s1,80005296 <argfd+0x50>
    *pf = f;
    80005294:	e09c                	sd	a5,0(s1)
}
    80005296:	70a2                	ld	ra,40(sp)
    80005298:	7402                	ld	s0,32(sp)
    8000529a:	64e2                	ld	s1,24(sp)
    8000529c:	6942                	ld	s2,16(sp)
    8000529e:	6145                	addi	sp,sp,48
    800052a0:	8082                	ret
    return -1;
    800052a2:	557d                	li	a0,-1
    800052a4:	bfcd                	j	80005296 <argfd+0x50>
    return -1;
    800052a6:	557d                	li	a0,-1
    800052a8:	b7fd                	j	80005296 <argfd+0x50>
    800052aa:	557d                	li	a0,-1
    800052ac:	b7ed                	j	80005296 <argfd+0x50>

00000000800052ae <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800052ae:	1101                	addi	sp,sp,-32
    800052b0:	ec06                	sd	ra,24(sp)
    800052b2:	e822                	sd	s0,16(sp)
    800052b4:	e426                	sd	s1,8(sp)
    800052b6:	1000                	addi	s0,sp,32
    800052b8:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800052ba:	ffffc097          	auipc	ra,0xffffc
    800052be:	6f6080e7          	jalr	1782(ra) # 800019b0 <myproc>
    800052c2:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800052c4:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7ffd90d0>
    800052c8:	4501                	li	a0,0
    800052ca:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800052cc:	6398                	ld	a4,0(a5)
    800052ce:	cb19                	beqz	a4,800052e4 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800052d0:	2505                	addiw	a0,a0,1
    800052d2:	07a1                	addi	a5,a5,8
    800052d4:	fed51ce3          	bne	a0,a3,800052cc <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800052d8:	557d                	li	a0,-1
}
    800052da:	60e2                	ld	ra,24(sp)
    800052dc:	6442                	ld	s0,16(sp)
    800052de:	64a2                	ld	s1,8(sp)
    800052e0:	6105                	addi	sp,sp,32
    800052e2:	8082                	ret
      p->ofile[fd] = f;
    800052e4:	01a50793          	addi	a5,a0,26
    800052e8:	078e                	slli	a5,a5,0x3
    800052ea:	963e                	add	a2,a2,a5
    800052ec:	e204                	sd	s1,0(a2)
      return fd;
    800052ee:	b7f5                	j	800052da <fdalloc+0x2c>

00000000800052f0 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800052f0:	715d                	addi	sp,sp,-80
    800052f2:	e486                	sd	ra,72(sp)
    800052f4:	e0a2                	sd	s0,64(sp)
    800052f6:	fc26                	sd	s1,56(sp)
    800052f8:	f84a                	sd	s2,48(sp)
    800052fa:	f44e                	sd	s3,40(sp)
    800052fc:	f052                	sd	s4,32(sp)
    800052fe:	ec56                	sd	s5,24(sp)
    80005300:	0880                	addi	s0,sp,80
    80005302:	89ae                	mv	s3,a1
    80005304:	8ab2                	mv	s5,a2
    80005306:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005308:	fb040593          	addi	a1,s0,-80
    8000530c:	fffff097          	auipc	ra,0xfffff
    80005310:	e86080e7          	jalr	-378(ra) # 80004192 <nameiparent>
    80005314:	892a                	mv	s2,a0
    80005316:	12050f63          	beqz	a0,80005454 <create+0x164>
    return 0;

  ilock(dp);
    8000531a:	ffffe097          	auipc	ra,0xffffe
    8000531e:	6a4080e7          	jalr	1700(ra) # 800039be <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005322:	4601                	li	a2,0
    80005324:	fb040593          	addi	a1,s0,-80
    80005328:	854a                	mv	a0,s2
    8000532a:	fffff097          	auipc	ra,0xfffff
    8000532e:	b78080e7          	jalr	-1160(ra) # 80003ea2 <dirlookup>
    80005332:	84aa                	mv	s1,a0
    80005334:	c921                	beqz	a0,80005384 <create+0x94>
    iunlockput(dp);
    80005336:	854a                	mv	a0,s2
    80005338:	fffff097          	auipc	ra,0xfffff
    8000533c:	8e8080e7          	jalr	-1816(ra) # 80003c20 <iunlockput>
    ilock(ip);
    80005340:	8526                	mv	a0,s1
    80005342:	ffffe097          	auipc	ra,0xffffe
    80005346:	67c080e7          	jalr	1660(ra) # 800039be <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000534a:	2981                	sext.w	s3,s3
    8000534c:	4789                	li	a5,2
    8000534e:	02f99463          	bne	s3,a5,80005376 <create+0x86>
    80005352:	0444d783          	lhu	a5,68(s1)
    80005356:	37f9                	addiw	a5,a5,-2
    80005358:	17c2                	slli	a5,a5,0x30
    8000535a:	93c1                	srli	a5,a5,0x30
    8000535c:	4705                	li	a4,1
    8000535e:	00f76c63          	bltu	a4,a5,80005376 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005362:	8526                	mv	a0,s1
    80005364:	60a6                	ld	ra,72(sp)
    80005366:	6406                	ld	s0,64(sp)
    80005368:	74e2                	ld	s1,56(sp)
    8000536a:	7942                	ld	s2,48(sp)
    8000536c:	79a2                	ld	s3,40(sp)
    8000536e:	7a02                	ld	s4,32(sp)
    80005370:	6ae2                	ld	s5,24(sp)
    80005372:	6161                	addi	sp,sp,80
    80005374:	8082                	ret
    iunlockput(ip);
    80005376:	8526                	mv	a0,s1
    80005378:	fffff097          	auipc	ra,0xfffff
    8000537c:	8a8080e7          	jalr	-1880(ra) # 80003c20 <iunlockput>
    return 0;
    80005380:	4481                	li	s1,0
    80005382:	b7c5                	j	80005362 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005384:	85ce                	mv	a1,s3
    80005386:	00092503          	lw	a0,0(s2)
    8000538a:	ffffe097          	auipc	ra,0xffffe
    8000538e:	49c080e7          	jalr	1180(ra) # 80003826 <ialloc>
    80005392:	84aa                	mv	s1,a0
    80005394:	c529                	beqz	a0,800053de <create+0xee>
  ilock(ip);
    80005396:	ffffe097          	auipc	ra,0xffffe
    8000539a:	628080e7          	jalr	1576(ra) # 800039be <ilock>
  ip->major = major;
    8000539e:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800053a2:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800053a6:	4785                	li	a5,1
    800053a8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800053ac:	8526                	mv	a0,s1
    800053ae:	ffffe097          	auipc	ra,0xffffe
    800053b2:	546080e7          	jalr	1350(ra) # 800038f4 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800053b6:	2981                	sext.w	s3,s3
    800053b8:	4785                	li	a5,1
    800053ba:	02f98a63          	beq	s3,a5,800053ee <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    800053be:	40d0                	lw	a2,4(s1)
    800053c0:	fb040593          	addi	a1,s0,-80
    800053c4:	854a                	mv	a0,s2
    800053c6:	fffff097          	auipc	ra,0xfffff
    800053ca:	cec080e7          	jalr	-788(ra) # 800040b2 <dirlink>
    800053ce:	06054b63          	bltz	a0,80005444 <create+0x154>
  iunlockput(dp);
    800053d2:	854a                	mv	a0,s2
    800053d4:	fffff097          	auipc	ra,0xfffff
    800053d8:	84c080e7          	jalr	-1972(ra) # 80003c20 <iunlockput>
  return ip;
    800053dc:	b759                	j	80005362 <create+0x72>
    panic("create: ialloc");
    800053de:	00003517          	auipc	a0,0x3
    800053e2:	37a50513          	addi	a0,a0,890 # 80008758 <syscalls+0x2c8>
    800053e6:	ffffb097          	auipc	ra,0xffffb
    800053ea:	158080e7          	jalr	344(ra) # 8000053e <panic>
    dp->nlink++;  // for ".."
    800053ee:	04a95783          	lhu	a5,74(s2)
    800053f2:	2785                	addiw	a5,a5,1
    800053f4:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    800053f8:	854a                	mv	a0,s2
    800053fa:	ffffe097          	auipc	ra,0xffffe
    800053fe:	4fa080e7          	jalr	1274(ra) # 800038f4 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005402:	40d0                	lw	a2,4(s1)
    80005404:	00003597          	auipc	a1,0x3
    80005408:	36458593          	addi	a1,a1,868 # 80008768 <syscalls+0x2d8>
    8000540c:	8526                	mv	a0,s1
    8000540e:	fffff097          	auipc	ra,0xfffff
    80005412:	ca4080e7          	jalr	-860(ra) # 800040b2 <dirlink>
    80005416:	00054f63          	bltz	a0,80005434 <create+0x144>
    8000541a:	00492603          	lw	a2,4(s2)
    8000541e:	00003597          	auipc	a1,0x3
    80005422:	35258593          	addi	a1,a1,850 # 80008770 <syscalls+0x2e0>
    80005426:	8526                	mv	a0,s1
    80005428:	fffff097          	auipc	ra,0xfffff
    8000542c:	c8a080e7          	jalr	-886(ra) # 800040b2 <dirlink>
    80005430:	f80557e3          	bgez	a0,800053be <create+0xce>
      panic("create dots");
    80005434:	00003517          	auipc	a0,0x3
    80005438:	34450513          	addi	a0,a0,836 # 80008778 <syscalls+0x2e8>
    8000543c:	ffffb097          	auipc	ra,0xffffb
    80005440:	102080e7          	jalr	258(ra) # 8000053e <panic>
    panic("create: dirlink");
    80005444:	00003517          	auipc	a0,0x3
    80005448:	34450513          	addi	a0,a0,836 # 80008788 <syscalls+0x2f8>
    8000544c:	ffffb097          	auipc	ra,0xffffb
    80005450:	0f2080e7          	jalr	242(ra) # 8000053e <panic>
    return 0;
    80005454:	84aa                	mv	s1,a0
    80005456:	b731                	j	80005362 <create+0x72>

0000000080005458 <sys_dup>:
{
    80005458:	7179                	addi	sp,sp,-48
    8000545a:	f406                	sd	ra,40(sp)
    8000545c:	f022                	sd	s0,32(sp)
    8000545e:	ec26                	sd	s1,24(sp)
    80005460:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005462:	fd840613          	addi	a2,s0,-40
    80005466:	4581                	li	a1,0
    80005468:	4501                	li	a0,0
    8000546a:	00000097          	auipc	ra,0x0
    8000546e:	ddc080e7          	jalr	-548(ra) # 80005246 <argfd>
    return -1;
    80005472:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005474:	02054363          	bltz	a0,8000549a <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005478:	fd843503          	ld	a0,-40(s0)
    8000547c:	00000097          	auipc	ra,0x0
    80005480:	e32080e7          	jalr	-462(ra) # 800052ae <fdalloc>
    80005484:	84aa                	mv	s1,a0
    return -1;
    80005486:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005488:	00054963          	bltz	a0,8000549a <sys_dup+0x42>
  filedup(f);
    8000548c:	fd843503          	ld	a0,-40(s0)
    80005490:	fffff097          	auipc	ra,0xfffff
    80005494:	37a080e7          	jalr	890(ra) # 8000480a <filedup>
  return fd;
    80005498:	87a6                	mv	a5,s1
}
    8000549a:	853e                	mv	a0,a5
    8000549c:	70a2                	ld	ra,40(sp)
    8000549e:	7402                	ld	s0,32(sp)
    800054a0:	64e2                	ld	s1,24(sp)
    800054a2:	6145                	addi	sp,sp,48
    800054a4:	8082                	ret

00000000800054a6 <sys_read>:
{
    800054a6:	7179                	addi	sp,sp,-48
    800054a8:	f406                	sd	ra,40(sp)
    800054aa:	f022                	sd	s0,32(sp)
    800054ac:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054ae:	fe840613          	addi	a2,s0,-24
    800054b2:	4581                	li	a1,0
    800054b4:	4501                	li	a0,0
    800054b6:	00000097          	auipc	ra,0x0
    800054ba:	d90080e7          	jalr	-624(ra) # 80005246 <argfd>
    return -1;
    800054be:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054c0:	04054163          	bltz	a0,80005502 <sys_read+0x5c>
    800054c4:	fe440593          	addi	a1,s0,-28
    800054c8:	4509                	li	a0,2
    800054ca:	ffffe097          	auipc	ra,0xffffe
    800054ce:	880080e7          	jalr	-1920(ra) # 80002d4a <argint>
    return -1;
    800054d2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054d4:	02054763          	bltz	a0,80005502 <sys_read+0x5c>
    800054d8:	fd840593          	addi	a1,s0,-40
    800054dc:	4505                	li	a0,1
    800054de:	ffffe097          	auipc	ra,0xffffe
    800054e2:	88e080e7          	jalr	-1906(ra) # 80002d6c <argaddr>
    return -1;
    800054e6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054e8:	00054d63          	bltz	a0,80005502 <sys_read+0x5c>
  return fileread(f, p, n);
    800054ec:	fe442603          	lw	a2,-28(s0)
    800054f0:	fd843583          	ld	a1,-40(s0)
    800054f4:	fe843503          	ld	a0,-24(s0)
    800054f8:	fffff097          	auipc	ra,0xfffff
    800054fc:	49e080e7          	jalr	1182(ra) # 80004996 <fileread>
    80005500:	87aa                	mv	a5,a0
}
    80005502:	853e                	mv	a0,a5
    80005504:	70a2                	ld	ra,40(sp)
    80005506:	7402                	ld	s0,32(sp)
    80005508:	6145                	addi	sp,sp,48
    8000550a:	8082                	ret

000000008000550c <sys_write>:
{
    8000550c:	7179                	addi	sp,sp,-48
    8000550e:	f406                	sd	ra,40(sp)
    80005510:	f022                	sd	s0,32(sp)
    80005512:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005514:	fe840613          	addi	a2,s0,-24
    80005518:	4581                	li	a1,0
    8000551a:	4501                	li	a0,0
    8000551c:	00000097          	auipc	ra,0x0
    80005520:	d2a080e7          	jalr	-726(ra) # 80005246 <argfd>
    return -1;
    80005524:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005526:	04054163          	bltz	a0,80005568 <sys_write+0x5c>
    8000552a:	fe440593          	addi	a1,s0,-28
    8000552e:	4509                	li	a0,2
    80005530:	ffffe097          	auipc	ra,0xffffe
    80005534:	81a080e7          	jalr	-2022(ra) # 80002d4a <argint>
    return -1;
    80005538:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000553a:	02054763          	bltz	a0,80005568 <sys_write+0x5c>
    8000553e:	fd840593          	addi	a1,s0,-40
    80005542:	4505                	li	a0,1
    80005544:	ffffe097          	auipc	ra,0xffffe
    80005548:	828080e7          	jalr	-2008(ra) # 80002d6c <argaddr>
    return -1;
    8000554c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000554e:	00054d63          	bltz	a0,80005568 <sys_write+0x5c>
  return filewrite(f, p, n);
    80005552:	fe442603          	lw	a2,-28(s0)
    80005556:	fd843583          	ld	a1,-40(s0)
    8000555a:	fe843503          	ld	a0,-24(s0)
    8000555e:	fffff097          	auipc	ra,0xfffff
    80005562:	4fa080e7          	jalr	1274(ra) # 80004a58 <filewrite>
    80005566:	87aa                	mv	a5,a0
}
    80005568:	853e                	mv	a0,a5
    8000556a:	70a2                	ld	ra,40(sp)
    8000556c:	7402                	ld	s0,32(sp)
    8000556e:	6145                	addi	sp,sp,48
    80005570:	8082                	ret

0000000080005572 <sys_close>:
{
    80005572:	1101                	addi	sp,sp,-32
    80005574:	ec06                	sd	ra,24(sp)
    80005576:	e822                	sd	s0,16(sp)
    80005578:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000557a:	fe040613          	addi	a2,s0,-32
    8000557e:	fec40593          	addi	a1,s0,-20
    80005582:	4501                	li	a0,0
    80005584:	00000097          	auipc	ra,0x0
    80005588:	cc2080e7          	jalr	-830(ra) # 80005246 <argfd>
    return -1;
    8000558c:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000558e:	02054463          	bltz	a0,800055b6 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005592:	ffffc097          	auipc	ra,0xffffc
    80005596:	41e080e7          	jalr	1054(ra) # 800019b0 <myproc>
    8000559a:	fec42783          	lw	a5,-20(s0)
    8000559e:	07e9                	addi	a5,a5,26
    800055a0:	078e                	slli	a5,a5,0x3
    800055a2:	97aa                	add	a5,a5,a0
    800055a4:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800055a8:	fe043503          	ld	a0,-32(s0)
    800055ac:	fffff097          	auipc	ra,0xfffff
    800055b0:	2b0080e7          	jalr	688(ra) # 8000485c <fileclose>
  return 0;
    800055b4:	4781                	li	a5,0
}
    800055b6:	853e                	mv	a0,a5
    800055b8:	60e2                	ld	ra,24(sp)
    800055ba:	6442                	ld	s0,16(sp)
    800055bc:	6105                	addi	sp,sp,32
    800055be:	8082                	ret

00000000800055c0 <sys_fstat>:
{
    800055c0:	1101                	addi	sp,sp,-32
    800055c2:	ec06                	sd	ra,24(sp)
    800055c4:	e822                	sd	s0,16(sp)
    800055c6:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800055c8:	fe840613          	addi	a2,s0,-24
    800055cc:	4581                	li	a1,0
    800055ce:	4501                	li	a0,0
    800055d0:	00000097          	auipc	ra,0x0
    800055d4:	c76080e7          	jalr	-906(ra) # 80005246 <argfd>
    return -1;
    800055d8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800055da:	02054563          	bltz	a0,80005604 <sys_fstat+0x44>
    800055de:	fe040593          	addi	a1,s0,-32
    800055e2:	4505                	li	a0,1
    800055e4:	ffffd097          	auipc	ra,0xffffd
    800055e8:	788080e7          	jalr	1928(ra) # 80002d6c <argaddr>
    return -1;
    800055ec:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800055ee:	00054b63          	bltz	a0,80005604 <sys_fstat+0x44>
  return filestat(f, st);
    800055f2:	fe043583          	ld	a1,-32(s0)
    800055f6:	fe843503          	ld	a0,-24(s0)
    800055fa:	fffff097          	auipc	ra,0xfffff
    800055fe:	32a080e7          	jalr	810(ra) # 80004924 <filestat>
    80005602:	87aa                	mv	a5,a0
}
    80005604:	853e                	mv	a0,a5
    80005606:	60e2                	ld	ra,24(sp)
    80005608:	6442                	ld	s0,16(sp)
    8000560a:	6105                	addi	sp,sp,32
    8000560c:	8082                	ret

000000008000560e <sys_link>:
{
    8000560e:	7169                	addi	sp,sp,-304
    80005610:	f606                	sd	ra,296(sp)
    80005612:	f222                	sd	s0,288(sp)
    80005614:	ee26                	sd	s1,280(sp)
    80005616:	ea4a                	sd	s2,272(sp)
    80005618:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000561a:	08000613          	li	a2,128
    8000561e:	ed040593          	addi	a1,s0,-304
    80005622:	4501                	li	a0,0
    80005624:	ffffd097          	auipc	ra,0xffffd
    80005628:	76a080e7          	jalr	1898(ra) # 80002d8e <argstr>
    return -1;
    8000562c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000562e:	10054e63          	bltz	a0,8000574a <sys_link+0x13c>
    80005632:	08000613          	li	a2,128
    80005636:	f5040593          	addi	a1,s0,-176
    8000563a:	4505                	li	a0,1
    8000563c:	ffffd097          	auipc	ra,0xffffd
    80005640:	752080e7          	jalr	1874(ra) # 80002d8e <argstr>
    return -1;
    80005644:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005646:	10054263          	bltz	a0,8000574a <sys_link+0x13c>
  begin_op();
    8000564a:	fffff097          	auipc	ra,0xfffff
    8000564e:	d46080e7          	jalr	-698(ra) # 80004390 <begin_op>
  if((ip = namei(old)) == 0){
    80005652:	ed040513          	addi	a0,s0,-304
    80005656:	fffff097          	auipc	ra,0xfffff
    8000565a:	b1e080e7          	jalr	-1250(ra) # 80004174 <namei>
    8000565e:	84aa                	mv	s1,a0
    80005660:	c551                	beqz	a0,800056ec <sys_link+0xde>
  ilock(ip);
    80005662:	ffffe097          	auipc	ra,0xffffe
    80005666:	35c080e7          	jalr	860(ra) # 800039be <ilock>
  if(ip->type == T_DIR){
    8000566a:	04449703          	lh	a4,68(s1)
    8000566e:	4785                	li	a5,1
    80005670:	08f70463          	beq	a4,a5,800056f8 <sys_link+0xea>
  ip->nlink++;
    80005674:	04a4d783          	lhu	a5,74(s1)
    80005678:	2785                	addiw	a5,a5,1
    8000567a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000567e:	8526                	mv	a0,s1
    80005680:	ffffe097          	auipc	ra,0xffffe
    80005684:	274080e7          	jalr	628(ra) # 800038f4 <iupdate>
  iunlock(ip);
    80005688:	8526                	mv	a0,s1
    8000568a:	ffffe097          	auipc	ra,0xffffe
    8000568e:	3f6080e7          	jalr	1014(ra) # 80003a80 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005692:	fd040593          	addi	a1,s0,-48
    80005696:	f5040513          	addi	a0,s0,-176
    8000569a:	fffff097          	auipc	ra,0xfffff
    8000569e:	af8080e7          	jalr	-1288(ra) # 80004192 <nameiparent>
    800056a2:	892a                	mv	s2,a0
    800056a4:	c935                	beqz	a0,80005718 <sys_link+0x10a>
  ilock(dp);
    800056a6:	ffffe097          	auipc	ra,0xffffe
    800056aa:	318080e7          	jalr	792(ra) # 800039be <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800056ae:	00092703          	lw	a4,0(s2)
    800056b2:	409c                	lw	a5,0(s1)
    800056b4:	04f71d63          	bne	a4,a5,8000570e <sys_link+0x100>
    800056b8:	40d0                	lw	a2,4(s1)
    800056ba:	fd040593          	addi	a1,s0,-48
    800056be:	854a                	mv	a0,s2
    800056c0:	fffff097          	auipc	ra,0xfffff
    800056c4:	9f2080e7          	jalr	-1550(ra) # 800040b2 <dirlink>
    800056c8:	04054363          	bltz	a0,8000570e <sys_link+0x100>
  iunlockput(dp);
    800056cc:	854a                	mv	a0,s2
    800056ce:	ffffe097          	auipc	ra,0xffffe
    800056d2:	552080e7          	jalr	1362(ra) # 80003c20 <iunlockput>
  iput(ip);
    800056d6:	8526                	mv	a0,s1
    800056d8:	ffffe097          	auipc	ra,0xffffe
    800056dc:	4a0080e7          	jalr	1184(ra) # 80003b78 <iput>
  end_op();
    800056e0:	fffff097          	auipc	ra,0xfffff
    800056e4:	d30080e7          	jalr	-720(ra) # 80004410 <end_op>
  return 0;
    800056e8:	4781                	li	a5,0
    800056ea:	a085                	j	8000574a <sys_link+0x13c>
    end_op();
    800056ec:	fffff097          	auipc	ra,0xfffff
    800056f0:	d24080e7          	jalr	-732(ra) # 80004410 <end_op>
    return -1;
    800056f4:	57fd                	li	a5,-1
    800056f6:	a891                	j	8000574a <sys_link+0x13c>
    iunlockput(ip);
    800056f8:	8526                	mv	a0,s1
    800056fa:	ffffe097          	auipc	ra,0xffffe
    800056fe:	526080e7          	jalr	1318(ra) # 80003c20 <iunlockput>
    end_op();
    80005702:	fffff097          	auipc	ra,0xfffff
    80005706:	d0e080e7          	jalr	-754(ra) # 80004410 <end_op>
    return -1;
    8000570a:	57fd                	li	a5,-1
    8000570c:	a83d                	j	8000574a <sys_link+0x13c>
    iunlockput(dp);
    8000570e:	854a                	mv	a0,s2
    80005710:	ffffe097          	auipc	ra,0xffffe
    80005714:	510080e7          	jalr	1296(ra) # 80003c20 <iunlockput>
  ilock(ip);
    80005718:	8526                	mv	a0,s1
    8000571a:	ffffe097          	auipc	ra,0xffffe
    8000571e:	2a4080e7          	jalr	676(ra) # 800039be <ilock>
  ip->nlink--;
    80005722:	04a4d783          	lhu	a5,74(s1)
    80005726:	37fd                	addiw	a5,a5,-1
    80005728:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000572c:	8526                	mv	a0,s1
    8000572e:	ffffe097          	auipc	ra,0xffffe
    80005732:	1c6080e7          	jalr	454(ra) # 800038f4 <iupdate>
  iunlockput(ip);
    80005736:	8526                	mv	a0,s1
    80005738:	ffffe097          	auipc	ra,0xffffe
    8000573c:	4e8080e7          	jalr	1256(ra) # 80003c20 <iunlockput>
  end_op();
    80005740:	fffff097          	auipc	ra,0xfffff
    80005744:	cd0080e7          	jalr	-816(ra) # 80004410 <end_op>
  return -1;
    80005748:	57fd                	li	a5,-1
}
    8000574a:	853e                	mv	a0,a5
    8000574c:	70b2                	ld	ra,296(sp)
    8000574e:	7412                	ld	s0,288(sp)
    80005750:	64f2                	ld	s1,280(sp)
    80005752:	6952                	ld	s2,272(sp)
    80005754:	6155                	addi	sp,sp,304
    80005756:	8082                	ret

0000000080005758 <sys_unlink>:
{
    80005758:	7151                	addi	sp,sp,-240
    8000575a:	f586                	sd	ra,232(sp)
    8000575c:	f1a2                	sd	s0,224(sp)
    8000575e:	eda6                	sd	s1,216(sp)
    80005760:	e9ca                	sd	s2,208(sp)
    80005762:	e5ce                	sd	s3,200(sp)
    80005764:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005766:	08000613          	li	a2,128
    8000576a:	f3040593          	addi	a1,s0,-208
    8000576e:	4501                	li	a0,0
    80005770:	ffffd097          	auipc	ra,0xffffd
    80005774:	61e080e7          	jalr	1566(ra) # 80002d8e <argstr>
    80005778:	18054163          	bltz	a0,800058fa <sys_unlink+0x1a2>
  begin_op();
    8000577c:	fffff097          	auipc	ra,0xfffff
    80005780:	c14080e7          	jalr	-1004(ra) # 80004390 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005784:	fb040593          	addi	a1,s0,-80
    80005788:	f3040513          	addi	a0,s0,-208
    8000578c:	fffff097          	auipc	ra,0xfffff
    80005790:	a06080e7          	jalr	-1530(ra) # 80004192 <nameiparent>
    80005794:	84aa                	mv	s1,a0
    80005796:	c979                	beqz	a0,8000586c <sys_unlink+0x114>
  ilock(dp);
    80005798:	ffffe097          	auipc	ra,0xffffe
    8000579c:	226080e7          	jalr	550(ra) # 800039be <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800057a0:	00003597          	auipc	a1,0x3
    800057a4:	fc858593          	addi	a1,a1,-56 # 80008768 <syscalls+0x2d8>
    800057a8:	fb040513          	addi	a0,s0,-80
    800057ac:	ffffe097          	auipc	ra,0xffffe
    800057b0:	6dc080e7          	jalr	1756(ra) # 80003e88 <namecmp>
    800057b4:	14050a63          	beqz	a0,80005908 <sys_unlink+0x1b0>
    800057b8:	00003597          	auipc	a1,0x3
    800057bc:	fb858593          	addi	a1,a1,-72 # 80008770 <syscalls+0x2e0>
    800057c0:	fb040513          	addi	a0,s0,-80
    800057c4:	ffffe097          	auipc	ra,0xffffe
    800057c8:	6c4080e7          	jalr	1732(ra) # 80003e88 <namecmp>
    800057cc:	12050e63          	beqz	a0,80005908 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800057d0:	f2c40613          	addi	a2,s0,-212
    800057d4:	fb040593          	addi	a1,s0,-80
    800057d8:	8526                	mv	a0,s1
    800057da:	ffffe097          	auipc	ra,0xffffe
    800057de:	6c8080e7          	jalr	1736(ra) # 80003ea2 <dirlookup>
    800057e2:	892a                	mv	s2,a0
    800057e4:	12050263          	beqz	a0,80005908 <sys_unlink+0x1b0>
  ilock(ip);
    800057e8:	ffffe097          	auipc	ra,0xffffe
    800057ec:	1d6080e7          	jalr	470(ra) # 800039be <ilock>
  if(ip->nlink < 1)
    800057f0:	04a91783          	lh	a5,74(s2)
    800057f4:	08f05263          	blez	a5,80005878 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800057f8:	04491703          	lh	a4,68(s2)
    800057fc:	4785                	li	a5,1
    800057fe:	08f70563          	beq	a4,a5,80005888 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005802:	4641                	li	a2,16
    80005804:	4581                	li	a1,0
    80005806:	fc040513          	addi	a0,s0,-64
    8000580a:	ffffb097          	auipc	ra,0xffffb
    8000580e:	4d6080e7          	jalr	1238(ra) # 80000ce0 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005812:	4741                	li	a4,16
    80005814:	f2c42683          	lw	a3,-212(s0)
    80005818:	fc040613          	addi	a2,s0,-64
    8000581c:	4581                	li	a1,0
    8000581e:	8526                	mv	a0,s1
    80005820:	ffffe097          	auipc	ra,0xffffe
    80005824:	54a080e7          	jalr	1354(ra) # 80003d6a <writei>
    80005828:	47c1                	li	a5,16
    8000582a:	0af51563          	bne	a0,a5,800058d4 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    8000582e:	04491703          	lh	a4,68(s2)
    80005832:	4785                	li	a5,1
    80005834:	0af70863          	beq	a4,a5,800058e4 <sys_unlink+0x18c>
  iunlockput(dp);
    80005838:	8526                	mv	a0,s1
    8000583a:	ffffe097          	auipc	ra,0xffffe
    8000583e:	3e6080e7          	jalr	998(ra) # 80003c20 <iunlockput>
  ip->nlink--;
    80005842:	04a95783          	lhu	a5,74(s2)
    80005846:	37fd                	addiw	a5,a5,-1
    80005848:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000584c:	854a                	mv	a0,s2
    8000584e:	ffffe097          	auipc	ra,0xffffe
    80005852:	0a6080e7          	jalr	166(ra) # 800038f4 <iupdate>
  iunlockput(ip);
    80005856:	854a                	mv	a0,s2
    80005858:	ffffe097          	auipc	ra,0xffffe
    8000585c:	3c8080e7          	jalr	968(ra) # 80003c20 <iunlockput>
  end_op();
    80005860:	fffff097          	auipc	ra,0xfffff
    80005864:	bb0080e7          	jalr	-1104(ra) # 80004410 <end_op>
  return 0;
    80005868:	4501                	li	a0,0
    8000586a:	a84d                	j	8000591c <sys_unlink+0x1c4>
    end_op();
    8000586c:	fffff097          	auipc	ra,0xfffff
    80005870:	ba4080e7          	jalr	-1116(ra) # 80004410 <end_op>
    return -1;
    80005874:	557d                	li	a0,-1
    80005876:	a05d                	j	8000591c <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005878:	00003517          	auipc	a0,0x3
    8000587c:	f2050513          	addi	a0,a0,-224 # 80008798 <syscalls+0x308>
    80005880:	ffffb097          	auipc	ra,0xffffb
    80005884:	cbe080e7          	jalr	-834(ra) # 8000053e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005888:	04c92703          	lw	a4,76(s2)
    8000588c:	02000793          	li	a5,32
    80005890:	f6e7f9e3          	bgeu	a5,a4,80005802 <sys_unlink+0xaa>
    80005894:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005898:	4741                	li	a4,16
    8000589a:	86ce                	mv	a3,s3
    8000589c:	f1840613          	addi	a2,s0,-232
    800058a0:	4581                	li	a1,0
    800058a2:	854a                	mv	a0,s2
    800058a4:	ffffe097          	auipc	ra,0xffffe
    800058a8:	3ce080e7          	jalr	974(ra) # 80003c72 <readi>
    800058ac:	47c1                	li	a5,16
    800058ae:	00f51b63          	bne	a0,a5,800058c4 <sys_unlink+0x16c>
    if(de.inum != 0)
    800058b2:	f1845783          	lhu	a5,-232(s0)
    800058b6:	e7a1                	bnez	a5,800058fe <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800058b8:	29c1                	addiw	s3,s3,16
    800058ba:	04c92783          	lw	a5,76(s2)
    800058be:	fcf9ede3          	bltu	s3,a5,80005898 <sys_unlink+0x140>
    800058c2:	b781                	j	80005802 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800058c4:	00003517          	auipc	a0,0x3
    800058c8:	eec50513          	addi	a0,a0,-276 # 800087b0 <syscalls+0x320>
    800058cc:	ffffb097          	auipc	ra,0xffffb
    800058d0:	c72080e7          	jalr	-910(ra) # 8000053e <panic>
    panic("unlink: writei");
    800058d4:	00003517          	auipc	a0,0x3
    800058d8:	ef450513          	addi	a0,a0,-268 # 800087c8 <syscalls+0x338>
    800058dc:	ffffb097          	auipc	ra,0xffffb
    800058e0:	c62080e7          	jalr	-926(ra) # 8000053e <panic>
    dp->nlink--;
    800058e4:	04a4d783          	lhu	a5,74(s1)
    800058e8:	37fd                	addiw	a5,a5,-1
    800058ea:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800058ee:	8526                	mv	a0,s1
    800058f0:	ffffe097          	auipc	ra,0xffffe
    800058f4:	004080e7          	jalr	4(ra) # 800038f4 <iupdate>
    800058f8:	b781                	j	80005838 <sys_unlink+0xe0>
    return -1;
    800058fa:	557d                	li	a0,-1
    800058fc:	a005                	j	8000591c <sys_unlink+0x1c4>
    iunlockput(ip);
    800058fe:	854a                	mv	a0,s2
    80005900:	ffffe097          	auipc	ra,0xffffe
    80005904:	320080e7          	jalr	800(ra) # 80003c20 <iunlockput>
  iunlockput(dp);
    80005908:	8526                	mv	a0,s1
    8000590a:	ffffe097          	auipc	ra,0xffffe
    8000590e:	316080e7          	jalr	790(ra) # 80003c20 <iunlockput>
  end_op();
    80005912:	fffff097          	auipc	ra,0xfffff
    80005916:	afe080e7          	jalr	-1282(ra) # 80004410 <end_op>
  return -1;
    8000591a:	557d                	li	a0,-1
}
    8000591c:	70ae                	ld	ra,232(sp)
    8000591e:	740e                	ld	s0,224(sp)
    80005920:	64ee                	ld	s1,216(sp)
    80005922:	694e                	ld	s2,208(sp)
    80005924:	69ae                	ld	s3,200(sp)
    80005926:	616d                	addi	sp,sp,240
    80005928:	8082                	ret

000000008000592a <sys_open>:

uint64
sys_open(void)
{
    8000592a:	7131                	addi	sp,sp,-192
    8000592c:	fd06                	sd	ra,184(sp)
    8000592e:	f922                	sd	s0,176(sp)
    80005930:	f526                	sd	s1,168(sp)
    80005932:	f14a                	sd	s2,160(sp)
    80005934:	ed4e                	sd	s3,152(sp)
    80005936:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005938:	08000613          	li	a2,128
    8000593c:	f5040593          	addi	a1,s0,-176
    80005940:	4501                	li	a0,0
    80005942:	ffffd097          	auipc	ra,0xffffd
    80005946:	44c080e7          	jalr	1100(ra) # 80002d8e <argstr>
    return -1;
    8000594a:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000594c:	0c054163          	bltz	a0,80005a0e <sys_open+0xe4>
    80005950:	f4c40593          	addi	a1,s0,-180
    80005954:	4505                	li	a0,1
    80005956:	ffffd097          	auipc	ra,0xffffd
    8000595a:	3f4080e7          	jalr	1012(ra) # 80002d4a <argint>
    8000595e:	0a054863          	bltz	a0,80005a0e <sys_open+0xe4>

  begin_op();
    80005962:	fffff097          	auipc	ra,0xfffff
    80005966:	a2e080e7          	jalr	-1490(ra) # 80004390 <begin_op>

  if(omode & O_CREATE){
    8000596a:	f4c42783          	lw	a5,-180(s0)
    8000596e:	2007f793          	andi	a5,a5,512
    80005972:	cbdd                	beqz	a5,80005a28 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005974:	4681                	li	a3,0
    80005976:	4601                	li	a2,0
    80005978:	4589                	li	a1,2
    8000597a:	f5040513          	addi	a0,s0,-176
    8000597e:	00000097          	auipc	ra,0x0
    80005982:	972080e7          	jalr	-1678(ra) # 800052f0 <create>
    80005986:	892a                	mv	s2,a0
    if(ip == 0){
    80005988:	c959                	beqz	a0,80005a1e <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000598a:	04491703          	lh	a4,68(s2)
    8000598e:	478d                	li	a5,3
    80005990:	00f71763          	bne	a4,a5,8000599e <sys_open+0x74>
    80005994:	04695703          	lhu	a4,70(s2)
    80005998:	47a5                	li	a5,9
    8000599a:	0ce7ec63          	bltu	a5,a4,80005a72 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000599e:	fffff097          	auipc	ra,0xfffff
    800059a2:	e02080e7          	jalr	-510(ra) # 800047a0 <filealloc>
    800059a6:	89aa                	mv	s3,a0
    800059a8:	10050263          	beqz	a0,80005aac <sys_open+0x182>
    800059ac:	00000097          	auipc	ra,0x0
    800059b0:	902080e7          	jalr	-1790(ra) # 800052ae <fdalloc>
    800059b4:	84aa                	mv	s1,a0
    800059b6:	0e054663          	bltz	a0,80005aa2 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800059ba:	04491703          	lh	a4,68(s2)
    800059be:	478d                	li	a5,3
    800059c0:	0cf70463          	beq	a4,a5,80005a88 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800059c4:	4789                	li	a5,2
    800059c6:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800059ca:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800059ce:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    800059d2:	f4c42783          	lw	a5,-180(s0)
    800059d6:	0017c713          	xori	a4,a5,1
    800059da:	8b05                	andi	a4,a4,1
    800059dc:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800059e0:	0037f713          	andi	a4,a5,3
    800059e4:	00e03733          	snez	a4,a4
    800059e8:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800059ec:	4007f793          	andi	a5,a5,1024
    800059f0:	c791                	beqz	a5,800059fc <sys_open+0xd2>
    800059f2:	04491703          	lh	a4,68(s2)
    800059f6:	4789                	li	a5,2
    800059f8:	08f70f63          	beq	a4,a5,80005a96 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    800059fc:	854a                	mv	a0,s2
    800059fe:	ffffe097          	auipc	ra,0xffffe
    80005a02:	082080e7          	jalr	130(ra) # 80003a80 <iunlock>
  end_op();
    80005a06:	fffff097          	auipc	ra,0xfffff
    80005a0a:	a0a080e7          	jalr	-1526(ra) # 80004410 <end_op>

  return fd;
}
    80005a0e:	8526                	mv	a0,s1
    80005a10:	70ea                	ld	ra,184(sp)
    80005a12:	744a                	ld	s0,176(sp)
    80005a14:	74aa                	ld	s1,168(sp)
    80005a16:	790a                	ld	s2,160(sp)
    80005a18:	69ea                	ld	s3,152(sp)
    80005a1a:	6129                	addi	sp,sp,192
    80005a1c:	8082                	ret
      end_op();
    80005a1e:	fffff097          	auipc	ra,0xfffff
    80005a22:	9f2080e7          	jalr	-1550(ra) # 80004410 <end_op>
      return -1;
    80005a26:	b7e5                	j	80005a0e <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005a28:	f5040513          	addi	a0,s0,-176
    80005a2c:	ffffe097          	auipc	ra,0xffffe
    80005a30:	748080e7          	jalr	1864(ra) # 80004174 <namei>
    80005a34:	892a                	mv	s2,a0
    80005a36:	c905                	beqz	a0,80005a66 <sys_open+0x13c>
    ilock(ip);
    80005a38:	ffffe097          	auipc	ra,0xffffe
    80005a3c:	f86080e7          	jalr	-122(ra) # 800039be <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005a40:	04491703          	lh	a4,68(s2)
    80005a44:	4785                	li	a5,1
    80005a46:	f4f712e3          	bne	a4,a5,8000598a <sys_open+0x60>
    80005a4a:	f4c42783          	lw	a5,-180(s0)
    80005a4e:	dba1                	beqz	a5,8000599e <sys_open+0x74>
      iunlockput(ip);
    80005a50:	854a                	mv	a0,s2
    80005a52:	ffffe097          	auipc	ra,0xffffe
    80005a56:	1ce080e7          	jalr	462(ra) # 80003c20 <iunlockput>
      end_op();
    80005a5a:	fffff097          	auipc	ra,0xfffff
    80005a5e:	9b6080e7          	jalr	-1610(ra) # 80004410 <end_op>
      return -1;
    80005a62:	54fd                	li	s1,-1
    80005a64:	b76d                	j	80005a0e <sys_open+0xe4>
      end_op();
    80005a66:	fffff097          	auipc	ra,0xfffff
    80005a6a:	9aa080e7          	jalr	-1622(ra) # 80004410 <end_op>
      return -1;
    80005a6e:	54fd                	li	s1,-1
    80005a70:	bf79                	j	80005a0e <sys_open+0xe4>
    iunlockput(ip);
    80005a72:	854a                	mv	a0,s2
    80005a74:	ffffe097          	auipc	ra,0xffffe
    80005a78:	1ac080e7          	jalr	428(ra) # 80003c20 <iunlockput>
    end_op();
    80005a7c:	fffff097          	auipc	ra,0xfffff
    80005a80:	994080e7          	jalr	-1644(ra) # 80004410 <end_op>
    return -1;
    80005a84:	54fd                	li	s1,-1
    80005a86:	b761                	j	80005a0e <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005a88:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005a8c:	04691783          	lh	a5,70(s2)
    80005a90:	02f99223          	sh	a5,36(s3)
    80005a94:	bf2d                	j	800059ce <sys_open+0xa4>
    itrunc(ip);
    80005a96:	854a                	mv	a0,s2
    80005a98:	ffffe097          	auipc	ra,0xffffe
    80005a9c:	034080e7          	jalr	52(ra) # 80003acc <itrunc>
    80005aa0:	bfb1                	j	800059fc <sys_open+0xd2>
      fileclose(f);
    80005aa2:	854e                	mv	a0,s3
    80005aa4:	fffff097          	auipc	ra,0xfffff
    80005aa8:	db8080e7          	jalr	-584(ra) # 8000485c <fileclose>
    iunlockput(ip);
    80005aac:	854a                	mv	a0,s2
    80005aae:	ffffe097          	auipc	ra,0xffffe
    80005ab2:	172080e7          	jalr	370(ra) # 80003c20 <iunlockput>
    end_op();
    80005ab6:	fffff097          	auipc	ra,0xfffff
    80005aba:	95a080e7          	jalr	-1702(ra) # 80004410 <end_op>
    return -1;
    80005abe:	54fd                	li	s1,-1
    80005ac0:	b7b9                	j	80005a0e <sys_open+0xe4>

0000000080005ac2 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005ac2:	7175                	addi	sp,sp,-144
    80005ac4:	e506                	sd	ra,136(sp)
    80005ac6:	e122                	sd	s0,128(sp)
    80005ac8:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005aca:	fffff097          	auipc	ra,0xfffff
    80005ace:	8c6080e7          	jalr	-1850(ra) # 80004390 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005ad2:	08000613          	li	a2,128
    80005ad6:	f7040593          	addi	a1,s0,-144
    80005ada:	4501                	li	a0,0
    80005adc:	ffffd097          	auipc	ra,0xffffd
    80005ae0:	2b2080e7          	jalr	690(ra) # 80002d8e <argstr>
    80005ae4:	02054963          	bltz	a0,80005b16 <sys_mkdir+0x54>
    80005ae8:	4681                	li	a3,0
    80005aea:	4601                	li	a2,0
    80005aec:	4585                	li	a1,1
    80005aee:	f7040513          	addi	a0,s0,-144
    80005af2:	fffff097          	auipc	ra,0xfffff
    80005af6:	7fe080e7          	jalr	2046(ra) # 800052f0 <create>
    80005afa:	cd11                	beqz	a0,80005b16 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005afc:	ffffe097          	auipc	ra,0xffffe
    80005b00:	124080e7          	jalr	292(ra) # 80003c20 <iunlockput>
  end_op();
    80005b04:	fffff097          	auipc	ra,0xfffff
    80005b08:	90c080e7          	jalr	-1780(ra) # 80004410 <end_op>
  return 0;
    80005b0c:	4501                	li	a0,0
}
    80005b0e:	60aa                	ld	ra,136(sp)
    80005b10:	640a                	ld	s0,128(sp)
    80005b12:	6149                	addi	sp,sp,144
    80005b14:	8082                	ret
    end_op();
    80005b16:	fffff097          	auipc	ra,0xfffff
    80005b1a:	8fa080e7          	jalr	-1798(ra) # 80004410 <end_op>
    return -1;
    80005b1e:	557d                	li	a0,-1
    80005b20:	b7fd                	j	80005b0e <sys_mkdir+0x4c>

0000000080005b22 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005b22:	7135                	addi	sp,sp,-160
    80005b24:	ed06                	sd	ra,152(sp)
    80005b26:	e922                	sd	s0,144(sp)
    80005b28:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005b2a:	fffff097          	auipc	ra,0xfffff
    80005b2e:	866080e7          	jalr	-1946(ra) # 80004390 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b32:	08000613          	li	a2,128
    80005b36:	f7040593          	addi	a1,s0,-144
    80005b3a:	4501                	li	a0,0
    80005b3c:	ffffd097          	auipc	ra,0xffffd
    80005b40:	252080e7          	jalr	594(ra) # 80002d8e <argstr>
    80005b44:	04054a63          	bltz	a0,80005b98 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005b48:	f6c40593          	addi	a1,s0,-148
    80005b4c:	4505                	li	a0,1
    80005b4e:	ffffd097          	auipc	ra,0xffffd
    80005b52:	1fc080e7          	jalr	508(ra) # 80002d4a <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b56:	04054163          	bltz	a0,80005b98 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005b5a:	f6840593          	addi	a1,s0,-152
    80005b5e:	4509                	li	a0,2
    80005b60:	ffffd097          	auipc	ra,0xffffd
    80005b64:	1ea080e7          	jalr	490(ra) # 80002d4a <argint>
     argint(1, &major) < 0 ||
    80005b68:	02054863          	bltz	a0,80005b98 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005b6c:	f6841683          	lh	a3,-152(s0)
    80005b70:	f6c41603          	lh	a2,-148(s0)
    80005b74:	458d                	li	a1,3
    80005b76:	f7040513          	addi	a0,s0,-144
    80005b7a:	fffff097          	auipc	ra,0xfffff
    80005b7e:	776080e7          	jalr	1910(ra) # 800052f0 <create>
     argint(2, &minor) < 0 ||
    80005b82:	c919                	beqz	a0,80005b98 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b84:	ffffe097          	auipc	ra,0xffffe
    80005b88:	09c080e7          	jalr	156(ra) # 80003c20 <iunlockput>
  end_op();
    80005b8c:	fffff097          	auipc	ra,0xfffff
    80005b90:	884080e7          	jalr	-1916(ra) # 80004410 <end_op>
  return 0;
    80005b94:	4501                	li	a0,0
    80005b96:	a031                	j	80005ba2 <sys_mknod+0x80>
    end_op();
    80005b98:	fffff097          	auipc	ra,0xfffff
    80005b9c:	878080e7          	jalr	-1928(ra) # 80004410 <end_op>
    return -1;
    80005ba0:	557d                	li	a0,-1
}
    80005ba2:	60ea                	ld	ra,152(sp)
    80005ba4:	644a                	ld	s0,144(sp)
    80005ba6:	610d                	addi	sp,sp,160
    80005ba8:	8082                	ret

0000000080005baa <sys_chdir>:

uint64
sys_chdir(void)
{
    80005baa:	7135                	addi	sp,sp,-160
    80005bac:	ed06                	sd	ra,152(sp)
    80005bae:	e922                	sd	s0,144(sp)
    80005bb0:	e526                	sd	s1,136(sp)
    80005bb2:	e14a                	sd	s2,128(sp)
    80005bb4:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005bb6:	ffffc097          	auipc	ra,0xffffc
    80005bba:	dfa080e7          	jalr	-518(ra) # 800019b0 <myproc>
    80005bbe:	892a                	mv	s2,a0
  
  begin_op();
    80005bc0:	ffffe097          	auipc	ra,0xffffe
    80005bc4:	7d0080e7          	jalr	2000(ra) # 80004390 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005bc8:	08000613          	li	a2,128
    80005bcc:	f6040593          	addi	a1,s0,-160
    80005bd0:	4501                	li	a0,0
    80005bd2:	ffffd097          	auipc	ra,0xffffd
    80005bd6:	1bc080e7          	jalr	444(ra) # 80002d8e <argstr>
    80005bda:	04054b63          	bltz	a0,80005c30 <sys_chdir+0x86>
    80005bde:	f6040513          	addi	a0,s0,-160
    80005be2:	ffffe097          	auipc	ra,0xffffe
    80005be6:	592080e7          	jalr	1426(ra) # 80004174 <namei>
    80005bea:	84aa                	mv	s1,a0
    80005bec:	c131                	beqz	a0,80005c30 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005bee:	ffffe097          	auipc	ra,0xffffe
    80005bf2:	dd0080e7          	jalr	-560(ra) # 800039be <ilock>
  if(ip->type != T_DIR){
    80005bf6:	04449703          	lh	a4,68(s1)
    80005bfa:	4785                	li	a5,1
    80005bfc:	04f71063          	bne	a4,a5,80005c3c <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005c00:	8526                	mv	a0,s1
    80005c02:	ffffe097          	auipc	ra,0xffffe
    80005c06:	e7e080e7          	jalr	-386(ra) # 80003a80 <iunlock>
  iput(p->cwd);
    80005c0a:	15093503          	ld	a0,336(s2)
    80005c0e:	ffffe097          	auipc	ra,0xffffe
    80005c12:	f6a080e7          	jalr	-150(ra) # 80003b78 <iput>
  end_op();
    80005c16:	ffffe097          	auipc	ra,0xffffe
    80005c1a:	7fa080e7          	jalr	2042(ra) # 80004410 <end_op>
  p->cwd = ip;
    80005c1e:	14993823          	sd	s1,336(s2)
  return 0;
    80005c22:	4501                	li	a0,0
}
    80005c24:	60ea                	ld	ra,152(sp)
    80005c26:	644a                	ld	s0,144(sp)
    80005c28:	64aa                	ld	s1,136(sp)
    80005c2a:	690a                	ld	s2,128(sp)
    80005c2c:	610d                	addi	sp,sp,160
    80005c2e:	8082                	ret
    end_op();
    80005c30:	ffffe097          	auipc	ra,0xffffe
    80005c34:	7e0080e7          	jalr	2016(ra) # 80004410 <end_op>
    return -1;
    80005c38:	557d                	li	a0,-1
    80005c3a:	b7ed                	j	80005c24 <sys_chdir+0x7a>
    iunlockput(ip);
    80005c3c:	8526                	mv	a0,s1
    80005c3e:	ffffe097          	auipc	ra,0xffffe
    80005c42:	fe2080e7          	jalr	-30(ra) # 80003c20 <iunlockput>
    end_op();
    80005c46:	ffffe097          	auipc	ra,0xffffe
    80005c4a:	7ca080e7          	jalr	1994(ra) # 80004410 <end_op>
    return -1;
    80005c4e:	557d                	li	a0,-1
    80005c50:	bfd1                	j	80005c24 <sys_chdir+0x7a>

0000000080005c52 <sys_exec>:

uint64
sys_exec(void)
{
    80005c52:	7145                	addi	sp,sp,-464
    80005c54:	e786                	sd	ra,456(sp)
    80005c56:	e3a2                	sd	s0,448(sp)
    80005c58:	ff26                	sd	s1,440(sp)
    80005c5a:	fb4a                	sd	s2,432(sp)
    80005c5c:	f74e                	sd	s3,424(sp)
    80005c5e:	f352                	sd	s4,416(sp)
    80005c60:	ef56                	sd	s5,408(sp)
    80005c62:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005c64:	08000613          	li	a2,128
    80005c68:	f4040593          	addi	a1,s0,-192
    80005c6c:	4501                	li	a0,0
    80005c6e:	ffffd097          	auipc	ra,0xffffd
    80005c72:	120080e7          	jalr	288(ra) # 80002d8e <argstr>
    return -1;
    80005c76:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005c78:	0c054a63          	bltz	a0,80005d4c <sys_exec+0xfa>
    80005c7c:	e3840593          	addi	a1,s0,-456
    80005c80:	4505                	li	a0,1
    80005c82:	ffffd097          	auipc	ra,0xffffd
    80005c86:	0ea080e7          	jalr	234(ra) # 80002d6c <argaddr>
    80005c8a:	0c054163          	bltz	a0,80005d4c <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005c8e:	10000613          	li	a2,256
    80005c92:	4581                	li	a1,0
    80005c94:	e4040513          	addi	a0,s0,-448
    80005c98:	ffffb097          	auipc	ra,0xffffb
    80005c9c:	048080e7          	jalr	72(ra) # 80000ce0 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005ca0:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005ca4:	89a6                	mv	s3,s1
    80005ca6:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005ca8:	02000a13          	li	s4,32
    80005cac:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005cb0:	00391513          	slli	a0,s2,0x3
    80005cb4:	e3040593          	addi	a1,s0,-464
    80005cb8:	e3843783          	ld	a5,-456(s0)
    80005cbc:	953e                	add	a0,a0,a5
    80005cbe:	ffffd097          	auipc	ra,0xffffd
    80005cc2:	ff2080e7          	jalr	-14(ra) # 80002cb0 <fetchaddr>
    80005cc6:	02054a63          	bltz	a0,80005cfa <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005cca:	e3043783          	ld	a5,-464(s0)
    80005cce:	c3b9                	beqz	a5,80005d14 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005cd0:	ffffb097          	auipc	ra,0xffffb
    80005cd4:	e24080e7          	jalr	-476(ra) # 80000af4 <kalloc>
    80005cd8:	85aa                	mv	a1,a0
    80005cda:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005cde:	cd11                	beqz	a0,80005cfa <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005ce0:	6605                	lui	a2,0x1
    80005ce2:	e3043503          	ld	a0,-464(s0)
    80005ce6:	ffffd097          	auipc	ra,0xffffd
    80005cea:	01c080e7          	jalr	28(ra) # 80002d02 <fetchstr>
    80005cee:	00054663          	bltz	a0,80005cfa <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005cf2:	0905                	addi	s2,s2,1
    80005cf4:	09a1                	addi	s3,s3,8
    80005cf6:	fb491be3          	bne	s2,s4,80005cac <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cfa:	10048913          	addi	s2,s1,256
    80005cfe:	6088                	ld	a0,0(s1)
    80005d00:	c529                	beqz	a0,80005d4a <sys_exec+0xf8>
    kfree(argv[i]);
    80005d02:	ffffb097          	auipc	ra,0xffffb
    80005d06:	cf6080e7          	jalr	-778(ra) # 800009f8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d0a:	04a1                	addi	s1,s1,8
    80005d0c:	ff2499e3          	bne	s1,s2,80005cfe <sys_exec+0xac>
  return -1;
    80005d10:	597d                	li	s2,-1
    80005d12:	a82d                	j	80005d4c <sys_exec+0xfa>
      argv[i] = 0;
    80005d14:	0a8e                	slli	s5,s5,0x3
    80005d16:	fc040793          	addi	a5,s0,-64
    80005d1a:	9abe                	add	s5,s5,a5
    80005d1c:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005d20:	e4040593          	addi	a1,s0,-448
    80005d24:	f4040513          	addi	a0,s0,-192
    80005d28:	fffff097          	auipc	ra,0xfffff
    80005d2c:	194080e7          	jalr	404(ra) # 80004ebc <exec>
    80005d30:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d32:	10048993          	addi	s3,s1,256
    80005d36:	6088                	ld	a0,0(s1)
    80005d38:	c911                	beqz	a0,80005d4c <sys_exec+0xfa>
    kfree(argv[i]);
    80005d3a:	ffffb097          	auipc	ra,0xffffb
    80005d3e:	cbe080e7          	jalr	-834(ra) # 800009f8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d42:	04a1                	addi	s1,s1,8
    80005d44:	ff3499e3          	bne	s1,s3,80005d36 <sys_exec+0xe4>
    80005d48:	a011                	j	80005d4c <sys_exec+0xfa>
  return -1;
    80005d4a:	597d                	li	s2,-1
}
    80005d4c:	854a                	mv	a0,s2
    80005d4e:	60be                	ld	ra,456(sp)
    80005d50:	641e                	ld	s0,448(sp)
    80005d52:	74fa                	ld	s1,440(sp)
    80005d54:	795a                	ld	s2,432(sp)
    80005d56:	79ba                	ld	s3,424(sp)
    80005d58:	7a1a                	ld	s4,416(sp)
    80005d5a:	6afa                	ld	s5,408(sp)
    80005d5c:	6179                	addi	sp,sp,464
    80005d5e:	8082                	ret

0000000080005d60 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005d60:	7139                	addi	sp,sp,-64
    80005d62:	fc06                	sd	ra,56(sp)
    80005d64:	f822                	sd	s0,48(sp)
    80005d66:	f426                	sd	s1,40(sp)
    80005d68:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005d6a:	ffffc097          	auipc	ra,0xffffc
    80005d6e:	c46080e7          	jalr	-954(ra) # 800019b0 <myproc>
    80005d72:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005d74:	fd840593          	addi	a1,s0,-40
    80005d78:	4501                	li	a0,0
    80005d7a:	ffffd097          	auipc	ra,0xffffd
    80005d7e:	ff2080e7          	jalr	-14(ra) # 80002d6c <argaddr>
    return -1;
    80005d82:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005d84:	0e054063          	bltz	a0,80005e64 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005d88:	fc840593          	addi	a1,s0,-56
    80005d8c:	fd040513          	addi	a0,s0,-48
    80005d90:	fffff097          	auipc	ra,0xfffff
    80005d94:	dfc080e7          	jalr	-516(ra) # 80004b8c <pipealloc>
    return -1;
    80005d98:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005d9a:	0c054563          	bltz	a0,80005e64 <sys_pipe+0x104>
  fd0 = -1;
    80005d9e:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005da2:	fd043503          	ld	a0,-48(s0)
    80005da6:	fffff097          	auipc	ra,0xfffff
    80005daa:	508080e7          	jalr	1288(ra) # 800052ae <fdalloc>
    80005dae:	fca42223          	sw	a0,-60(s0)
    80005db2:	08054c63          	bltz	a0,80005e4a <sys_pipe+0xea>
    80005db6:	fc843503          	ld	a0,-56(s0)
    80005dba:	fffff097          	auipc	ra,0xfffff
    80005dbe:	4f4080e7          	jalr	1268(ra) # 800052ae <fdalloc>
    80005dc2:	fca42023          	sw	a0,-64(s0)
    80005dc6:	06054863          	bltz	a0,80005e36 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005dca:	4691                	li	a3,4
    80005dcc:	fc440613          	addi	a2,s0,-60
    80005dd0:	fd843583          	ld	a1,-40(s0)
    80005dd4:	68a8                	ld	a0,80(s1)
    80005dd6:	ffffc097          	auipc	ra,0xffffc
    80005dda:	89c080e7          	jalr	-1892(ra) # 80001672 <copyout>
    80005dde:	02054063          	bltz	a0,80005dfe <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005de2:	4691                	li	a3,4
    80005de4:	fc040613          	addi	a2,s0,-64
    80005de8:	fd843583          	ld	a1,-40(s0)
    80005dec:	0591                	addi	a1,a1,4
    80005dee:	68a8                	ld	a0,80(s1)
    80005df0:	ffffc097          	auipc	ra,0xffffc
    80005df4:	882080e7          	jalr	-1918(ra) # 80001672 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005df8:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005dfa:	06055563          	bgez	a0,80005e64 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005dfe:	fc442783          	lw	a5,-60(s0)
    80005e02:	07e9                	addi	a5,a5,26
    80005e04:	078e                	slli	a5,a5,0x3
    80005e06:	97a6                	add	a5,a5,s1
    80005e08:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005e0c:	fc042503          	lw	a0,-64(s0)
    80005e10:	0569                	addi	a0,a0,26
    80005e12:	050e                	slli	a0,a0,0x3
    80005e14:	9526                	add	a0,a0,s1
    80005e16:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005e1a:	fd043503          	ld	a0,-48(s0)
    80005e1e:	fffff097          	auipc	ra,0xfffff
    80005e22:	a3e080e7          	jalr	-1474(ra) # 8000485c <fileclose>
    fileclose(wf);
    80005e26:	fc843503          	ld	a0,-56(s0)
    80005e2a:	fffff097          	auipc	ra,0xfffff
    80005e2e:	a32080e7          	jalr	-1486(ra) # 8000485c <fileclose>
    return -1;
    80005e32:	57fd                	li	a5,-1
    80005e34:	a805                	j	80005e64 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005e36:	fc442783          	lw	a5,-60(s0)
    80005e3a:	0007c863          	bltz	a5,80005e4a <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005e3e:	01a78513          	addi	a0,a5,26
    80005e42:	050e                	slli	a0,a0,0x3
    80005e44:	9526                	add	a0,a0,s1
    80005e46:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005e4a:	fd043503          	ld	a0,-48(s0)
    80005e4e:	fffff097          	auipc	ra,0xfffff
    80005e52:	a0e080e7          	jalr	-1522(ra) # 8000485c <fileclose>
    fileclose(wf);
    80005e56:	fc843503          	ld	a0,-56(s0)
    80005e5a:	fffff097          	auipc	ra,0xfffff
    80005e5e:	a02080e7          	jalr	-1534(ra) # 8000485c <fileclose>
    return -1;
    80005e62:	57fd                	li	a5,-1
}
    80005e64:	853e                	mv	a0,a5
    80005e66:	70e2                	ld	ra,56(sp)
    80005e68:	7442                	ld	s0,48(sp)
    80005e6a:	74a2                	ld	s1,40(sp)
    80005e6c:	6121                	addi	sp,sp,64
    80005e6e:	8082                	ret

0000000080005e70 <kernelvec>:
    80005e70:	7111                	addi	sp,sp,-256
    80005e72:	e006                	sd	ra,0(sp)
    80005e74:	e40a                	sd	sp,8(sp)
    80005e76:	e80e                	sd	gp,16(sp)
    80005e78:	ec12                	sd	tp,24(sp)
    80005e7a:	f016                	sd	t0,32(sp)
    80005e7c:	f41a                	sd	t1,40(sp)
    80005e7e:	f81e                	sd	t2,48(sp)
    80005e80:	fc22                	sd	s0,56(sp)
    80005e82:	e0a6                	sd	s1,64(sp)
    80005e84:	e4aa                	sd	a0,72(sp)
    80005e86:	e8ae                	sd	a1,80(sp)
    80005e88:	ecb2                	sd	a2,88(sp)
    80005e8a:	f0b6                	sd	a3,96(sp)
    80005e8c:	f4ba                	sd	a4,104(sp)
    80005e8e:	f8be                	sd	a5,112(sp)
    80005e90:	fcc2                	sd	a6,120(sp)
    80005e92:	e146                	sd	a7,128(sp)
    80005e94:	e54a                	sd	s2,136(sp)
    80005e96:	e94e                	sd	s3,144(sp)
    80005e98:	ed52                	sd	s4,152(sp)
    80005e9a:	f156                	sd	s5,160(sp)
    80005e9c:	f55a                	sd	s6,168(sp)
    80005e9e:	f95e                	sd	s7,176(sp)
    80005ea0:	fd62                	sd	s8,184(sp)
    80005ea2:	e1e6                	sd	s9,192(sp)
    80005ea4:	e5ea                	sd	s10,200(sp)
    80005ea6:	e9ee                	sd	s11,208(sp)
    80005ea8:	edf2                	sd	t3,216(sp)
    80005eaa:	f1f6                	sd	t4,224(sp)
    80005eac:	f5fa                	sd	t5,232(sp)
    80005eae:	f9fe                	sd	t6,240(sp)
    80005eb0:	ccdfc0ef          	jal	ra,80002b7c <kerneltrap>
    80005eb4:	6082                	ld	ra,0(sp)
    80005eb6:	6122                	ld	sp,8(sp)
    80005eb8:	61c2                	ld	gp,16(sp)
    80005eba:	7282                	ld	t0,32(sp)
    80005ebc:	7322                	ld	t1,40(sp)
    80005ebe:	73c2                	ld	t2,48(sp)
    80005ec0:	7462                	ld	s0,56(sp)
    80005ec2:	6486                	ld	s1,64(sp)
    80005ec4:	6526                	ld	a0,72(sp)
    80005ec6:	65c6                	ld	a1,80(sp)
    80005ec8:	6666                	ld	a2,88(sp)
    80005eca:	7686                	ld	a3,96(sp)
    80005ecc:	7726                	ld	a4,104(sp)
    80005ece:	77c6                	ld	a5,112(sp)
    80005ed0:	7866                	ld	a6,120(sp)
    80005ed2:	688a                	ld	a7,128(sp)
    80005ed4:	692a                	ld	s2,136(sp)
    80005ed6:	69ca                	ld	s3,144(sp)
    80005ed8:	6a6a                	ld	s4,152(sp)
    80005eda:	7a8a                	ld	s5,160(sp)
    80005edc:	7b2a                	ld	s6,168(sp)
    80005ede:	7bca                	ld	s7,176(sp)
    80005ee0:	7c6a                	ld	s8,184(sp)
    80005ee2:	6c8e                	ld	s9,192(sp)
    80005ee4:	6d2e                	ld	s10,200(sp)
    80005ee6:	6dce                	ld	s11,208(sp)
    80005ee8:	6e6e                	ld	t3,216(sp)
    80005eea:	7e8e                	ld	t4,224(sp)
    80005eec:	7f2e                	ld	t5,232(sp)
    80005eee:	7fce                	ld	t6,240(sp)
    80005ef0:	6111                	addi	sp,sp,256
    80005ef2:	10200073          	sret
    80005ef6:	00000013          	nop
    80005efa:	00000013          	nop
    80005efe:	0001                	nop

0000000080005f00 <timervec>:
    80005f00:	34051573          	csrrw	a0,mscratch,a0
    80005f04:	e10c                	sd	a1,0(a0)
    80005f06:	e510                	sd	a2,8(a0)
    80005f08:	e914                	sd	a3,16(a0)
    80005f0a:	6d0c                	ld	a1,24(a0)
    80005f0c:	7110                	ld	a2,32(a0)
    80005f0e:	6194                	ld	a3,0(a1)
    80005f10:	96b2                	add	a3,a3,a2
    80005f12:	e194                	sd	a3,0(a1)
    80005f14:	4589                	li	a1,2
    80005f16:	14459073          	csrw	sip,a1
    80005f1a:	6914                	ld	a3,16(a0)
    80005f1c:	6510                	ld	a2,8(a0)
    80005f1e:	610c                	ld	a1,0(a0)
    80005f20:	34051573          	csrrw	a0,mscratch,a0
    80005f24:	30200073          	mret
	...

0000000080005f2a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005f2a:	1141                	addi	sp,sp,-16
    80005f2c:	e422                	sd	s0,8(sp)
    80005f2e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005f30:	0c0007b7          	lui	a5,0xc000
    80005f34:	4705                	li	a4,1
    80005f36:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005f38:	c3d8                	sw	a4,4(a5)
}
    80005f3a:	6422                	ld	s0,8(sp)
    80005f3c:	0141                	addi	sp,sp,16
    80005f3e:	8082                	ret

0000000080005f40 <plicinithart>:

void
plicinithart(void)
{
    80005f40:	1141                	addi	sp,sp,-16
    80005f42:	e406                	sd	ra,8(sp)
    80005f44:	e022                	sd	s0,0(sp)
    80005f46:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f48:	ffffc097          	auipc	ra,0xffffc
    80005f4c:	a3c080e7          	jalr	-1476(ra) # 80001984 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005f50:	0085171b          	slliw	a4,a0,0x8
    80005f54:	0c0027b7          	lui	a5,0xc002
    80005f58:	97ba                	add	a5,a5,a4
    80005f5a:	40200713          	li	a4,1026
    80005f5e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005f62:	00d5151b          	slliw	a0,a0,0xd
    80005f66:	0c2017b7          	lui	a5,0xc201
    80005f6a:	953e                	add	a0,a0,a5
    80005f6c:	00052023          	sw	zero,0(a0)
}
    80005f70:	60a2                	ld	ra,8(sp)
    80005f72:	6402                	ld	s0,0(sp)
    80005f74:	0141                	addi	sp,sp,16
    80005f76:	8082                	ret

0000000080005f78 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005f78:	1141                	addi	sp,sp,-16
    80005f7a:	e406                	sd	ra,8(sp)
    80005f7c:	e022                	sd	s0,0(sp)
    80005f7e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f80:	ffffc097          	auipc	ra,0xffffc
    80005f84:	a04080e7          	jalr	-1532(ra) # 80001984 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005f88:	00d5179b          	slliw	a5,a0,0xd
    80005f8c:	0c201537          	lui	a0,0xc201
    80005f90:	953e                	add	a0,a0,a5
  return irq;
}
    80005f92:	4148                	lw	a0,4(a0)
    80005f94:	60a2                	ld	ra,8(sp)
    80005f96:	6402                	ld	s0,0(sp)
    80005f98:	0141                	addi	sp,sp,16
    80005f9a:	8082                	ret

0000000080005f9c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005f9c:	1101                	addi	sp,sp,-32
    80005f9e:	ec06                	sd	ra,24(sp)
    80005fa0:	e822                	sd	s0,16(sp)
    80005fa2:	e426                	sd	s1,8(sp)
    80005fa4:	1000                	addi	s0,sp,32
    80005fa6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005fa8:	ffffc097          	auipc	ra,0xffffc
    80005fac:	9dc080e7          	jalr	-1572(ra) # 80001984 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005fb0:	00d5151b          	slliw	a0,a0,0xd
    80005fb4:	0c2017b7          	lui	a5,0xc201
    80005fb8:	97aa                	add	a5,a5,a0
    80005fba:	c3c4                	sw	s1,4(a5)
}
    80005fbc:	60e2                	ld	ra,24(sp)
    80005fbe:	6442                	ld	s0,16(sp)
    80005fc0:	64a2                	ld	s1,8(sp)
    80005fc2:	6105                	addi	sp,sp,32
    80005fc4:	8082                	ret

0000000080005fc6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005fc6:	1141                	addi	sp,sp,-16
    80005fc8:	e406                	sd	ra,8(sp)
    80005fca:	e022                	sd	s0,0(sp)
    80005fcc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005fce:	479d                	li	a5,7
    80005fd0:	06a7c963          	blt	a5,a0,80006042 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80005fd4:	0001d797          	auipc	a5,0x1d
    80005fd8:	02c78793          	addi	a5,a5,44 # 80023000 <disk>
    80005fdc:	00a78733          	add	a4,a5,a0
    80005fe0:	6789                	lui	a5,0x2
    80005fe2:	97ba                	add	a5,a5,a4
    80005fe4:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005fe8:	e7ad                	bnez	a5,80006052 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005fea:	00451793          	slli	a5,a0,0x4
    80005fee:	0001f717          	auipc	a4,0x1f
    80005ff2:	01270713          	addi	a4,a4,18 # 80025000 <disk+0x2000>
    80005ff6:	6314                	ld	a3,0(a4)
    80005ff8:	96be                	add	a3,a3,a5
    80005ffa:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005ffe:	6314                	ld	a3,0(a4)
    80006000:	96be                	add	a3,a3,a5
    80006002:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006006:	6314                	ld	a3,0(a4)
    80006008:	96be                	add	a3,a3,a5
    8000600a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    8000600e:	6318                	ld	a4,0(a4)
    80006010:	97ba                	add	a5,a5,a4
    80006012:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006016:	0001d797          	auipc	a5,0x1d
    8000601a:	fea78793          	addi	a5,a5,-22 # 80023000 <disk>
    8000601e:	97aa                	add	a5,a5,a0
    80006020:	6509                	lui	a0,0x2
    80006022:	953e                	add	a0,a0,a5
    80006024:	4785                	li	a5,1
    80006026:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    8000602a:	0001f517          	auipc	a0,0x1f
    8000602e:	fee50513          	addi	a0,a0,-18 # 80025018 <disk+0x2018>
    80006032:	ffffc097          	auipc	ra,0xffffc
    80006036:	1c6080e7          	jalr	454(ra) # 800021f8 <wakeup>
}
    8000603a:	60a2                	ld	ra,8(sp)
    8000603c:	6402                	ld	s0,0(sp)
    8000603e:	0141                	addi	sp,sp,16
    80006040:	8082                	ret
    panic("free_desc 1");
    80006042:	00002517          	auipc	a0,0x2
    80006046:	79650513          	addi	a0,a0,1942 # 800087d8 <syscalls+0x348>
    8000604a:	ffffa097          	auipc	ra,0xffffa
    8000604e:	4f4080e7          	jalr	1268(ra) # 8000053e <panic>
    panic("free_desc 2");
    80006052:	00002517          	auipc	a0,0x2
    80006056:	79650513          	addi	a0,a0,1942 # 800087e8 <syscalls+0x358>
    8000605a:	ffffa097          	auipc	ra,0xffffa
    8000605e:	4e4080e7          	jalr	1252(ra) # 8000053e <panic>

0000000080006062 <virtio_disk_init>:
{
    80006062:	1101                	addi	sp,sp,-32
    80006064:	ec06                	sd	ra,24(sp)
    80006066:	e822                	sd	s0,16(sp)
    80006068:	e426                	sd	s1,8(sp)
    8000606a:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000606c:	00002597          	auipc	a1,0x2
    80006070:	78c58593          	addi	a1,a1,1932 # 800087f8 <syscalls+0x368>
    80006074:	0001f517          	auipc	a0,0x1f
    80006078:	0b450513          	addi	a0,a0,180 # 80025128 <disk+0x2128>
    8000607c:	ffffb097          	auipc	ra,0xffffb
    80006080:	ad8080e7          	jalr	-1320(ra) # 80000b54 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006084:	100017b7          	lui	a5,0x10001
    80006088:	4398                	lw	a4,0(a5)
    8000608a:	2701                	sext.w	a4,a4
    8000608c:	747277b7          	lui	a5,0x74727
    80006090:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006094:	0ef71163          	bne	a4,a5,80006176 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006098:	100017b7          	lui	a5,0x10001
    8000609c:	43dc                	lw	a5,4(a5)
    8000609e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800060a0:	4705                	li	a4,1
    800060a2:	0ce79a63          	bne	a5,a4,80006176 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800060a6:	100017b7          	lui	a5,0x10001
    800060aa:	479c                	lw	a5,8(a5)
    800060ac:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800060ae:	4709                	li	a4,2
    800060b0:	0ce79363          	bne	a5,a4,80006176 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800060b4:	100017b7          	lui	a5,0x10001
    800060b8:	47d8                	lw	a4,12(a5)
    800060ba:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800060bc:	554d47b7          	lui	a5,0x554d4
    800060c0:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800060c4:	0af71963          	bne	a4,a5,80006176 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    800060c8:	100017b7          	lui	a5,0x10001
    800060cc:	4705                	li	a4,1
    800060ce:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800060d0:	470d                	li	a4,3
    800060d2:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800060d4:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800060d6:	c7ffe737          	lui	a4,0xc7ffe
    800060da:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    800060de:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800060e0:	2701                	sext.w	a4,a4
    800060e2:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800060e4:	472d                	li	a4,11
    800060e6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800060e8:	473d                	li	a4,15
    800060ea:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    800060ec:	6705                	lui	a4,0x1
    800060ee:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800060f0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800060f4:	5bdc                	lw	a5,52(a5)
    800060f6:	2781                	sext.w	a5,a5
  if(max == 0)
    800060f8:	c7d9                	beqz	a5,80006186 <virtio_disk_init+0x124>
  if(max < NUM)
    800060fa:	471d                	li	a4,7
    800060fc:	08f77d63          	bgeu	a4,a5,80006196 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006100:	100014b7          	lui	s1,0x10001
    80006104:	47a1                	li	a5,8
    80006106:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006108:	6609                	lui	a2,0x2
    8000610a:	4581                	li	a1,0
    8000610c:	0001d517          	auipc	a0,0x1d
    80006110:	ef450513          	addi	a0,a0,-268 # 80023000 <disk>
    80006114:	ffffb097          	auipc	ra,0xffffb
    80006118:	bcc080e7          	jalr	-1076(ra) # 80000ce0 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    8000611c:	0001d717          	auipc	a4,0x1d
    80006120:	ee470713          	addi	a4,a4,-284 # 80023000 <disk>
    80006124:	00c75793          	srli	a5,a4,0xc
    80006128:	2781                	sext.w	a5,a5
    8000612a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    8000612c:	0001f797          	auipc	a5,0x1f
    80006130:	ed478793          	addi	a5,a5,-300 # 80025000 <disk+0x2000>
    80006134:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006136:	0001d717          	auipc	a4,0x1d
    8000613a:	f4a70713          	addi	a4,a4,-182 # 80023080 <disk+0x80>
    8000613e:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80006140:	0001e717          	auipc	a4,0x1e
    80006144:	ec070713          	addi	a4,a4,-320 # 80024000 <disk+0x1000>
    80006148:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    8000614a:	4705                	li	a4,1
    8000614c:	00e78c23          	sb	a4,24(a5)
    80006150:	00e78ca3          	sb	a4,25(a5)
    80006154:	00e78d23          	sb	a4,26(a5)
    80006158:	00e78da3          	sb	a4,27(a5)
    8000615c:	00e78e23          	sb	a4,28(a5)
    80006160:	00e78ea3          	sb	a4,29(a5)
    80006164:	00e78f23          	sb	a4,30(a5)
    80006168:	00e78fa3          	sb	a4,31(a5)
}
    8000616c:	60e2                	ld	ra,24(sp)
    8000616e:	6442                	ld	s0,16(sp)
    80006170:	64a2                	ld	s1,8(sp)
    80006172:	6105                	addi	sp,sp,32
    80006174:	8082                	ret
    panic("could not find virtio disk");
    80006176:	00002517          	auipc	a0,0x2
    8000617a:	69250513          	addi	a0,a0,1682 # 80008808 <syscalls+0x378>
    8000617e:	ffffa097          	auipc	ra,0xffffa
    80006182:	3c0080e7          	jalr	960(ra) # 8000053e <panic>
    panic("virtio disk has no queue 0");
    80006186:	00002517          	auipc	a0,0x2
    8000618a:	6a250513          	addi	a0,a0,1698 # 80008828 <syscalls+0x398>
    8000618e:	ffffa097          	auipc	ra,0xffffa
    80006192:	3b0080e7          	jalr	944(ra) # 8000053e <panic>
    panic("virtio disk max queue too short");
    80006196:	00002517          	auipc	a0,0x2
    8000619a:	6b250513          	addi	a0,a0,1714 # 80008848 <syscalls+0x3b8>
    8000619e:	ffffa097          	auipc	ra,0xffffa
    800061a2:	3a0080e7          	jalr	928(ra) # 8000053e <panic>

00000000800061a6 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800061a6:	7159                	addi	sp,sp,-112
    800061a8:	f486                	sd	ra,104(sp)
    800061aa:	f0a2                	sd	s0,96(sp)
    800061ac:	eca6                	sd	s1,88(sp)
    800061ae:	e8ca                	sd	s2,80(sp)
    800061b0:	e4ce                	sd	s3,72(sp)
    800061b2:	e0d2                	sd	s4,64(sp)
    800061b4:	fc56                	sd	s5,56(sp)
    800061b6:	f85a                	sd	s6,48(sp)
    800061b8:	f45e                	sd	s7,40(sp)
    800061ba:	f062                	sd	s8,32(sp)
    800061bc:	ec66                	sd	s9,24(sp)
    800061be:	e86a                	sd	s10,16(sp)
    800061c0:	1880                	addi	s0,sp,112
    800061c2:	892a                	mv	s2,a0
    800061c4:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800061c6:	00c52c83          	lw	s9,12(a0)
    800061ca:	001c9c9b          	slliw	s9,s9,0x1
    800061ce:	1c82                	slli	s9,s9,0x20
    800061d0:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800061d4:	0001f517          	auipc	a0,0x1f
    800061d8:	f5450513          	addi	a0,a0,-172 # 80025128 <disk+0x2128>
    800061dc:	ffffb097          	auipc	ra,0xffffb
    800061e0:	a08080e7          	jalr	-1528(ra) # 80000be4 <acquire>
  for(int i = 0; i < 3; i++){
    800061e4:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800061e6:	4c21                	li	s8,8
      disk.free[i] = 0;
    800061e8:	0001db97          	auipc	s7,0x1d
    800061ec:	e18b8b93          	addi	s7,s7,-488 # 80023000 <disk>
    800061f0:	6b09                	lui	s6,0x2
  for(int i = 0; i < 3; i++){
    800061f2:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    800061f4:	8a4e                	mv	s4,s3
    800061f6:	a051                	j	8000627a <virtio_disk_rw+0xd4>
      disk.free[i] = 0;
    800061f8:	00fb86b3          	add	a3,s7,a5
    800061fc:	96da                	add	a3,a3,s6
    800061fe:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80006202:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    80006204:	0207c563          	bltz	a5,8000622e <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006208:	2485                	addiw	s1,s1,1
    8000620a:	0711                	addi	a4,a4,4
    8000620c:	25548063          	beq	s1,s5,8000644c <virtio_disk_rw+0x2a6>
    idx[i] = alloc_desc();
    80006210:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80006212:	0001f697          	auipc	a3,0x1f
    80006216:	e0668693          	addi	a3,a3,-506 # 80025018 <disk+0x2018>
    8000621a:	87d2                	mv	a5,s4
    if(disk.free[i]){
    8000621c:	0006c583          	lbu	a1,0(a3)
    80006220:	fde1                	bnez	a1,800061f8 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006222:	2785                	addiw	a5,a5,1
    80006224:	0685                	addi	a3,a3,1
    80006226:	ff879be3          	bne	a5,s8,8000621c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000622a:	57fd                	li	a5,-1
    8000622c:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    8000622e:	02905a63          	blez	s1,80006262 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80006232:	f9042503          	lw	a0,-112(s0)
    80006236:	00000097          	auipc	ra,0x0
    8000623a:	d90080e7          	jalr	-624(ra) # 80005fc6 <free_desc>
      for(int j = 0; j < i; j++)
    8000623e:	4785                	li	a5,1
    80006240:	0297d163          	bge	a5,s1,80006262 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80006244:	f9442503          	lw	a0,-108(s0)
    80006248:	00000097          	auipc	ra,0x0
    8000624c:	d7e080e7          	jalr	-642(ra) # 80005fc6 <free_desc>
      for(int j = 0; j < i; j++)
    80006250:	4789                	li	a5,2
    80006252:	0097d863          	bge	a5,s1,80006262 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80006256:	f9842503          	lw	a0,-104(s0)
    8000625a:	00000097          	auipc	ra,0x0
    8000625e:	d6c080e7          	jalr	-660(ra) # 80005fc6 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006262:	0001f597          	auipc	a1,0x1f
    80006266:	ec658593          	addi	a1,a1,-314 # 80025128 <disk+0x2128>
    8000626a:	0001f517          	auipc	a0,0x1f
    8000626e:	dae50513          	addi	a0,a0,-594 # 80025018 <disk+0x2018>
    80006272:	ffffc097          	auipc	ra,0xffffc
    80006276:	dfa080e7          	jalr	-518(ra) # 8000206c <sleep>
  for(int i = 0; i < 3; i++){
    8000627a:	f9040713          	addi	a4,s0,-112
    8000627e:	84ce                	mv	s1,s3
    80006280:	bf41                	j	80006210 <virtio_disk_rw+0x6a>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    80006282:	20058713          	addi	a4,a1,512
    80006286:	00471693          	slli	a3,a4,0x4
    8000628a:	0001d717          	auipc	a4,0x1d
    8000628e:	d7670713          	addi	a4,a4,-650 # 80023000 <disk>
    80006292:	9736                	add	a4,a4,a3
    80006294:	4685                	li	a3,1
    80006296:	0ad72423          	sw	a3,168(a4)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000629a:	20058713          	addi	a4,a1,512
    8000629e:	00471693          	slli	a3,a4,0x4
    800062a2:	0001d717          	auipc	a4,0x1d
    800062a6:	d5e70713          	addi	a4,a4,-674 # 80023000 <disk>
    800062aa:	9736                	add	a4,a4,a3
    800062ac:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    800062b0:	0b973823          	sd	s9,176(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800062b4:	7679                	lui	a2,0xffffe
    800062b6:	963e                	add	a2,a2,a5
    800062b8:	0001f697          	auipc	a3,0x1f
    800062bc:	d4868693          	addi	a3,a3,-696 # 80025000 <disk+0x2000>
    800062c0:	6298                	ld	a4,0(a3)
    800062c2:	9732                	add	a4,a4,a2
    800062c4:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800062c6:	6298                	ld	a4,0(a3)
    800062c8:	9732                	add	a4,a4,a2
    800062ca:	4541                	li	a0,16
    800062cc:	c708                	sw	a0,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800062ce:	6298                	ld	a4,0(a3)
    800062d0:	9732                	add	a4,a4,a2
    800062d2:	4505                	li	a0,1
    800062d4:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[0]].next = idx[1];
    800062d8:	f9442703          	lw	a4,-108(s0)
    800062dc:	6288                	ld	a0,0(a3)
    800062de:	962a                	add	a2,a2,a0
    800062e0:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd800e>

  disk.desc[idx[1]].addr = (uint64) b->data;
    800062e4:	0712                	slli	a4,a4,0x4
    800062e6:	6290                	ld	a2,0(a3)
    800062e8:	963a                	add	a2,a2,a4
    800062ea:	05890513          	addi	a0,s2,88
    800062ee:	e208                	sd	a0,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800062f0:	6294                	ld	a3,0(a3)
    800062f2:	96ba                	add	a3,a3,a4
    800062f4:	40000613          	li	a2,1024
    800062f8:	c690                	sw	a2,8(a3)
  if(write)
    800062fa:	140d0063          	beqz	s10,8000643a <virtio_disk_rw+0x294>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800062fe:	0001f697          	auipc	a3,0x1f
    80006302:	d026b683          	ld	a3,-766(a3) # 80025000 <disk+0x2000>
    80006306:	96ba                	add	a3,a3,a4
    80006308:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000630c:	0001d817          	auipc	a6,0x1d
    80006310:	cf480813          	addi	a6,a6,-780 # 80023000 <disk>
    80006314:	0001f517          	auipc	a0,0x1f
    80006318:	cec50513          	addi	a0,a0,-788 # 80025000 <disk+0x2000>
    8000631c:	6114                	ld	a3,0(a0)
    8000631e:	96ba                	add	a3,a3,a4
    80006320:	00c6d603          	lhu	a2,12(a3)
    80006324:	00166613          	ori	a2,a2,1
    80006328:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    8000632c:	f9842683          	lw	a3,-104(s0)
    80006330:	6110                	ld	a2,0(a0)
    80006332:	9732                	add	a4,a4,a2
    80006334:	00d71723          	sh	a3,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006338:	20058613          	addi	a2,a1,512
    8000633c:	0612                	slli	a2,a2,0x4
    8000633e:	9642                	add	a2,a2,a6
    80006340:	577d                	li	a4,-1
    80006342:	02e60823          	sb	a4,48(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006346:	00469713          	slli	a4,a3,0x4
    8000634a:	6114                	ld	a3,0(a0)
    8000634c:	96ba                	add	a3,a3,a4
    8000634e:	03078793          	addi	a5,a5,48
    80006352:	97c2                	add	a5,a5,a6
    80006354:	e29c                	sd	a5,0(a3)
  disk.desc[idx[2]].len = 1;
    80006356:	611c                	ld	a5,0(a0)
    80006358:	97ba                	add	a5,a5,a4
    8000635a:	4685                	li	a3,1
    8000635c:	c794                	sw	a3,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000635e:	611c                	ld	a5,0(a0)
    80006360:	97ba                	add	a5,a5,a4
    80006362:	4809                	li	a6,2
    80006364:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80006368:	611c                	ld	a5,0(a0)
    8000636a:	973e                	add	a4,a4,a5
    8000636c:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006370:	00d92223          	sw	a3,4(s2)
  disk.info[idx[0]].b = b;
    80006374:	03263423          	sd	s2,40(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006378:	6518                	ld	a4,8(a0)
    8000637a:	00275783          	lhu	a5,2(a4)
    8000637e:	8b9d                	andi	a5,a5,7
    80006380:	0786                	slli	a5,a5,0x1
    80006382:	97ba                	add	a5,a5,a4
    80006384:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80006388:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000638c:	6518                	ld	a4,8(a0)
    8000638e:	00275783          	lhu	a5,2(a4)
    80006392:	2785                	addiw	a5,a5,1
    80006394:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006398:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000639c:	100017b7          	lui	a5,0x10001
    800063a0:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800063a4:	00492703          	lw	a4,4(s2)
    800063a8:	4785                	li	a5,1
    800063aa:	02f71163          	bne	a4,a5,800063cc <virtio_disk_rw+0x226>
    sleep(b, &disk.vdisk_lock);
    800063ae:	0001f997          	auipc	s3,0x1f
    800063b2:	d7a98993          	addi	s3,s3,-646 # 80025128 <disk+0x2128>
  while(b->disk == 1) {
    800063b6:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800063b8:	85ce                	mv	a1,s3
    800063ba:	854a                	mv	a0,s2
    800063bc:	ffffc097          	auipc	ra,0xffffc
    800063c0:	cb0080e7          	jalr	-848(ra) # 8000206c <sleep>
  while(b->disk == 1) {
    800063c4:	00492783          	lw	a5,4(s2)
    800063c8:	fe9788e3          	beq	a5,s1,800063b8 <virtio_disk_rw+0x212>
  }

  disk.info[idx[0]].b = 0;
    800063cc:	f9042903          	lw	s2,-112(s0)
    800063d0:	20090793          	addi	a5,s2,512
    800063d4:	00479713          	slli	a4,a5,0x4
    800063d8:	0001d797          	auipc	a5,0x1d
    800063dc:	c2878793          	addi	a5,a5,-984 # 80023000 <disk>
    800063e0:	97ba                	add	a5,a5,a4
    800063e2:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    800063e6:	0001f997          	auipc	s3,0x1f
    800063ea:	c1a98993          	addi	s3,s3,-998 # 80025000 <disk+0x2000>
    800063ee:	00491713          	slli	a4,s2,0x4
    800063f2:	0009b783          	ld	a5,0(s3)
    800063f6:	97ba                	add	a5,a5,a4
    800063f8:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800063fc:	854a                	mv	a0,s2
    800063fe:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006402:	00000097          	auipc	ra,0x0
    80006406:	bc4080e7          	jalr	-1084(ra) # 80005fc6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000640a:	8885                	andi	s1,s1,1
    8000640c:	f0ed                	bnez	s1,800063ee <virtio_disk_rw+0x248>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000640e:	0001f517          	auipc	a0,0x1f
    80006412:	d1a50513          	addi	a0,a0,-742 # 80025128 <disk+0x2128>
    80006416:	ffffb097          	auipc	ra,0xffffb
    8000641a:	882080e7          	jalr	-1918(ra) # 80000c98 <release>
}
    8000641e:	70a6                	ld	ra,104(sp)
    80006420:	7406                	ld	s0,96(sp)
    80006422:	64e6                	ld	s1,88(sp)
    80006424:	6946                	ld	s2,80(sp)
    80006426:	69a6                	ld	s3,72(sp)
    80006428:	6a06                	ld	s4,64(sp)
    8000642a:	7ae2                	ld	s5,56(sp)
    8000642c:	7b42                	ld	s6,48(sp)
    8000642e:	7ba2                	ld	s7,40(sp)
    80006430:	7c02                	ld	s8,32(sp)
    80006432:	6ce2                	ld	s9,24(sp)
    80006434:	6d42                	ld	s10,16(sp)
    80006436:	6165                	addi	sp,sp,112
    80006438:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000643a:	0001f697          	auipc	a3,0x1f
    8000643e:	bc66b683          	ld	a3,-1082(a3) # 80025000 <disk+0x2000>
    80006442:	96ba                	add	a3,a3,a4
    80006444:	4609                	li	a2,2
    80006446:	00c69623          	sh	a2,12(a3)
    8000644a:	b5c9                	j	8000630c <virtio_disk_rw+0x166>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000644c:	f9042583          	lw	a1,-112(s0)
    80006450:	20058793          	addi	a5,a1,512
    80006454:	0792                	slli	a5,a5,0x4
    80006456:	0001d517          	auipc	a0,0x1d
    8000645a:	c5250513          	addi	a0,a0,-942 # 800230a8 <disk+0xa8>
    8000645e:	953e                	add	a0,a0,a5
  if(write)
    80006460:	e20d11e3          	bnez	s10,80006282 <virtio_disk_rw+0xdc>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    80006464:	20058713          	addi	a4,a1,512
    80006468:	00471693          	slli	a3,a4,0x4
    8000646c:	0001d717          	auipc	a4,0x1d
    80006470:	b9470713          	addi	a4,a4,-1132 # 80023000 <disk>
    80006474:	9736                	add	a4,a4,a3
    80006476:	0a072423          	sw	zero,168(a4)
    8000647a:	b505                	j	8000629a <virtio_disk_rw+0xf4>

000000008000647c <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000647c:	1101                	addi	sp,sp,-32
    8000647e:	ec06                	sd	ra,24(sp)
    80006480:	e822                	sd	s0,16(sp)
    80006482:	e426                	sd	s1,8(sp)
    80006484:	e04a                	sd	s2,0(sp)
    80006486:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006488:	0001f517          	auipc	a0,0x1f
    8000648c:	ca050513          	addi	a0,a0,-864 # 80025128 <disk+0x2128>
    80006490:	ffffa097          	auipc	ra,0xffffa
    80006494:	754080e7          	jalr	1876(ra) # 80000be4 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006498:	10001737          	lui	a4,0x10001
    8000649c:	533c                	lw	a5,96(a4)
    8000649e:	8b8d                	andi	a5,a5,3
    800064a0:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800064a2:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800064a6:	0001f797          	auipc	a5,0x1f
    800064aa:	b5a78793          	addi	a5,a5,-1190 # 80025000 <disk+0x2000>
    800064ae:	6b94                	ld	a3,16(a5)
    800064b0:	0207d703          	lhu	a4,32(a5)
    800064b4:	0026d783          	lhu	a5,2(a3)
    800064b8:	06f70163          	beq	a4,a5,8000651a <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800064bc:	0001d917          	auipc	s2,0x1d
    800064c0:	b4490913          	addi	s2,s2,-1212 # 80023000 <disk>
    800064c4:	0001f497          	auipc	s1,0x1f
    800064c8:	b3c48493          	addi	s1,s1,-1220 # 80025000 <disk+0x2000>
    __sync_synchronize();
    800064cc:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800064d0:	6898                	ld	a4,16(s1)
    800064d2:	0204d783          	lhu	a5,32(s1)
    800064d6:	8b9d                	andi	a5,a5,7
    800064d8:	078e                	slli	a5,a5,0x3
    800064da:	97ba                	add	a5,a5,a4
    800064dc:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800064de:	20078713          	addi	a4,a5,512
    800064e2:	0712                	slli	a4,a4,0x4
    800064e4:	974a                	add	a4,a4,s2
    800064e6:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    800064ea:	e731                	bnez	a4,80006536 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800064ec:	20078793          	addi	a5,a5,512
    800064f0:	0792                	slli	a5,a5,0x4
    800064f2:	97ca                	add	a5,a5,s2
    800064f4:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    800064f6:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800064fa:	ffffc097          	auipc	ra,0xffffc
    800064fe:	cfe080e7          	jalr	-770(ra) # 800021f8 <wakeup>

    disk.used_idx += 1;
    80006502:	0204d783          	lhu	a5,32(s1)
    80006506:	2785                	addiw	a5,a5,1
    80006508:	17c2                	slli	a5,a5,0x30
    8000650a:	93c1                	srli	a5,a5,0x30
    8000650c:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006510:	6898                	ld	a4,16(s1)
    80006512:	00275703          	lhu	a4,2(a4)
    80006516:	faf71be3          	bne	a4,a5,800064cc <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    8000651a:	0001f517          	auipc	a0,0x1f
    8000651e:	c0e50513          	addi	a0,a0,-1010 # 80025128 <disk+0x2128>
    80006522:	ffffa097          	auipc	ra,0xffffa
    80006526:	776080e7          	jalr	1910(ra) # 80000c98 <release>
}
    8000652a:	60e2                	ld	ra,24(sp)
    8000652c:	6442                	ld	s0,16(sp)
    8000652e:	64a2                	ld	s1,8(sp)
    80006530:	6902                	ld	s2,0(sp)
    80006532:	6105                	addi	sp,sp,32
    80006534:	8082                	ret
      panic("virtio_disk_intr status");
    80006536:	00002517          	auipc	a0,0x2
    8000653a:	33250513          	addi	a0,a0,818 # 80008868 <syscalls+0x3d8>
    8000653e:	ffffa097          	auipc	ra,0xffffa
    80006542:	000080e7          	jalr	ra # 8000053e <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
	...
