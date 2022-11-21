// 2. You will implement the multiple producers and multiple consumers on a bounded buffer using three
// system calls described below. You will implement the bounded buffer and its code as discussed in the class where
// each element of the buffer has a condition variable and other necessary fields (please refer to
// multi_prod_multi_cons.c in course homepage). Fix the size of the buffer to twenty. Declare the buffer at
// an appropriate place in the assignment3/xv6-riscv/kernel/ directory. You may put this declaration in a
// new file as well.

#define SIZE 20

struct buffer_elem{
   int data;
   int full;
   struct sleeplock lock;
   struct cond_t inserted;
   struct cond_t deleted;
};

struct buffer_elem buffer[SIZE];
int tail, head;
struct sleeplock lock_delete;
struct sleeplock lock_insert;
struct sleeplock lock_print;