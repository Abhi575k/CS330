#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "sleeplock.h"
#include "condvar.h"

void
cond_wait (struct cond_t *cv, struct sleeplock *lock){
    releasesleep(lock);
    acquiresleep(&cv->lk);
    // condsleep(cv, &cv->lk);
    // if(cv->i==0)
    condsleep(cv, &cv->lk);
    releasesleep(&cv->lk);
    acquiresleep(lock);
    return;
}

void
cond_signal (struct cond_t *cv){
    acquiresleep(&cv->lk);
    cv->i = 1;
    releasesleep(&cv->lk);
    // printf("cond wake in\n");
    wakeupone(cv);
    // printf("cond wake out\n");
    acquiresleep(&cv->lk);
    cv->i = 0;
    releasesleep(&cv->lk);
    return;
}

void
cond_broadcast (struct cond_t *cv){
    acquiresleep(&cv->lk);
    cv->i = 1;
    releasesleep(&cv->lk);
    wakeup(cv);
    acquiresleep(&cv->lk);
    cv->i = 0;
    releasesleep(&cv->lk);
}