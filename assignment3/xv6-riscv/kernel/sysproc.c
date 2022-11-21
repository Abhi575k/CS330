#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
  int n;
  if(argint(0, &n) < 0)
    return -1;
  exit(n);
  return 0;  // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return fork();
}

uint64
sys_wait(void)
{
  uint64 p;
  if(argaddr(0, &p) < 0)
    return -1;
  return wait(p);
}

uint64
sys_sbrk(void)
{
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = myproc()->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

uint64
sys_sleep(void)
{
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  if(argint(0, &pid) < 0)
    return -1;
  return kill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

uint64
sys_getppid(void)
{
  if (myproc()->parent) return myproc()->parent->pid;
  else {
     printf("No parent found.\n");
     return 0;
  }
}

uint64
sys_yield(void)
{
  yield();
  return 0;
}

uint64
sys_getpa(void)
{
  uint64 x;
  if (argaddr(0, &x) < 0) return -1;
  return walkaddr(myproc()->pagetable, x) + (x & (PGSIZE - 1));
}

uint64
sys_forkf(void)
{
  uint64 x;
  if (argaddr(0, &x) < 0) return -1;
  return forkf(x);
}

uint64
sys_waitpid(void)
{
  uint64 p;
  int x;

  if(argint(0, &x) < 0)
    return -1;
  if(argaddr(1, &p) < 0)
    return -1;

  if (x == -1) return wait(p);
  if ((x == 0) || (x < -1)) return -1;
  return waitpid(x, p);
}

uint64
sys_ps(void)
{
   return ps();
}

uint64
sys_pinfo(void)
{
  uint64 p;
  int x;

  if(argint(0, &x) < 0)
    return -1;
  if(argaddr(1, &p) < 0)
    return -1;

  if ((x == 0) || (x < -1) || (p == 0)) return -1;
  return pinfo(x, p);
}

uint64
sys_forkp(void)
{
  int x;
  if(argint(0, &x) < 0) return -1;
  return forkp(x);
}

uint64
sys_schedpolicy(void)
{
  int x;
  if(argint(0, &x) < 0) return -1;
  return schedpolicy(x);
}

uint64
sys_condsleep(void)
{
  uint64 c,sl;
   if(argaddr(0, &c) < 0)
    return -1;
   if(argaddr(1, &sl) < 0)
    return -1;

  condsleep((struct cond_t*)c,(struct sleeplock*)sl);

  return 0;
}

// uint64
// sys_wakeupone(void)
// {
//   uint64 c;
//    if(argaddr(0, &c) < 0)
//     return -1;
//   wakeupone((void*)c);

//   return 0;
// }

uint64
sys_barrier_alloc(void){
    return barrier_alloc();
}

uint64
sys_barrier(void){
    int x,y,z;
    if(argint(0, &x) < 0) return -1;
    if(argint(1, &y) < 0) return -1;
    if(argint(2, &z) < 0) return -1;
    barrier(x,y,z);
    return 0;
}

uint64
sys_barrier_free(void){
    int x;
    if(argint(0, &x) < 0) return -1;
    barrier_free(x);
    return 0;
}

uint64
sys_buffer_cond_init(void){
    buffer_cond_init();
    return 0;
}

uint64
sys_cond_produce(void){
    int x;
    if(argint(0, &x) < 0) return -1;
    cond_produce(x);
    return 0;
}

uint64
sys_cond_consume(void){
    return cond_consume();
}

// uint64
// sys_semsleep(void)
// {
//   uint64 c,sl;
//    if(argaddr(0, &c) < 0)
//     return -1;
//    if(argaddr(1, &sl) < 0)
//     return -1;

//   semsleep((struct semaphore*)c,(struct sleeplock*)sl);

//   return 0;
// }

uint64
sys_buffer_sem_init(void){
    buffer_sem_init();
    return 0;
}

uint64
sys_sem_produce(void){
    int x;
    if(argint(0, &x) < 0) return -1;
    sem_produce(x);
    return 0;
}

uint64
sys_sem_consume(void){
    return sem_consume();
}
