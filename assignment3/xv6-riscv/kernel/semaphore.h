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

struct semaphore{
    int val;             // sem_wait() decrements, sem_post() increments the value
    struct sleeplock lk;    // lock for updating values
    struct cond_t c;
};