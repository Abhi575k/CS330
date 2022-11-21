// Define the condition variable of type cond_t in a new file named assignment3/xv6-riscv/kernel/condvar.h.
// Think about what this type should be.
struct sleeplock;

struct cond_t{
    uint64 i;               // i=1; condition has been been fulfilled
    struct sleeplock lk;
    char* name;
};