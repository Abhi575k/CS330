// --------------------------------
// TESTING SEMAPHORE IMPLEMENTATION
// --------------------------------

// I have included a user program named semprodconstest in assignment3/xv6-riscv/user/ that implements
// the multiple producer multiple consumer bounded buffer using semaphores. To get this program
// to compile, you will need to implement a few new systems calls, which I discuss below. Your implementation
// should not require any change in the user program. You will implement the bounded buffer and its code as
// discussed in lecture slide#63. You will need to use a buffer that is separate from the buffer used
// in the condition variable-based implementation of bounded buffer. Fix the size of the buffer to twenty.
// Declare the buffer at an appropriate place in the assignment3/xv6-riscv/kernel/ directory. You may put
// this declaration in a new file as well.

// Producer:
// Binary semaphore pro.v=1
// do { Generate a new item
// sem_wait (&empty);
// sem_wait (&pro);
// buffer[nextp] = item;
// nextp = (nextp+1)%N;
// sem_post (&pro);
// sem_post (&full);
// } while (more to produce);

// Consumer:
// Binary semaphore con.v=1
// do { sem_wait (&full);
// sem_wait (&con);
// item = buffer[nextc];
// nextc = (nextc+1)%N;
// sem_post (&con);
// sem_post (&empty);
// Use item
// } while (more to consume);

struct bounded_buffer_elem{
   int data;
   int full;
   struct sleeplock lk;
   struct semaphore inserted;
   struct semaphore deleted;
};

struct bounded_buffer_elem bounded_buffer[SIZE];
int bb_tail, bb_head;
struct sleeplock bb_lock_delete;
struct sleeplock bb_lock_insert;
struct sleeplock bb_lock_print;