// ------------------------
// SEMAPHORE IMPLEMENTATION
// ------------------------

// You will implement the semaphore using condition variables and sleeplocks. This implementation is
// available in the lecture slides. Define the semaphore structure in a new file named
// assignment3/xv6-riscv/kernel/semaphore.h. In another new file assignment3/xv6-riscv/kernel/semaphore.c
// implement the following three functions.

// void sem_init (struct semaphore *s, int x)
// void sem_wait (struct semaphore *s)
// void sem_post (struct semaphore *s)

#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "sleeplock.h"
#include "condvar.h"
#include "semaphore.h"

void sem_init (struct semaphore *s, int x){
    initsleeplock(&s->lk,"lock");
    initsleeplock(&s->c.lk,"lock");
    s->val=x;
    return;
}

void sem_wait (struct semaphore *s){
    acquiresleep(&s->lk);
    // printf("s->val:%d\n",s->val);
    s->val=s->val-1;
    // printf("s->val:%d\n",s->val);
    while(s->val<0) cond_wait(&s->c,&s->lk);
    releasesleep(&s->lk);
    return;
}

void sem_post (struct semaphore *s){
    acquiresleep(&s->lk);
    s->val=s->val+1;
    cond_signal(&s->c);
    releasesleep(&s->lk);
}

// A. buffer_sem_init: This system call initializes all semaphores and any other variable involved in the
// bounded buffer implementation.

// B. sem_produce: This system call implements the producer function. It takes the produced value as argument.

// C. sem_consume: This system call implements the consumer function. This system call should be implemented in
// such a way that the consumed item is printed out. Make sure to acquire a sleeplock before printing. The consumed
// item is also returned to the user program although it is not used.