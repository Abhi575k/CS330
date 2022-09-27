# CS330 OPERATING SYSTEM

## Assignment - 1

### Part 1

### Part 2

#### d)

D. forkf: This system call introduces a slight variation in the fork() call. The
usual fork() call returns to the code right after the fork() call in both parent and
child. In forkf() call, the parent behaves just like the usual fork() call, but
the child first executes a function right after returning to user mode and then returns
to the code after the forkf() call. The forkf system call takes the function address as
an argument. There is one requirement regarding the function which is passed as the argument
of forkf: the function must not have any argument. It will be helpful to understand how
the fork() call is implemented and from where the program counter is picked up when a trap
returns to user mode.

Consider the following example program that uses forkf().

#include "kernel/types.h"
#include "user/user.h"

int g (int x)
{
   return x*x;
}

int f (void)
{
   int x = 10;

   fprintf(2, "Hello world! %d\n", g(x));
   return 0;
}

int
main(void)
{
  int x = forkf(f);
  if (x < 0) {
     fprintf(2, "Error: cannot fork\nAborting...\n");
     exit(0);
  }
  else if (x > 0) {
     sleep(1);
     fprintf(1, "%d: Parent.\n", getpid());
     wait(0);
  }
  else {
     fprintf(1, "%d: Child.\n", getpid());
  }

  exit(0);
}

The expected output of this program is shown below.

Hello world! 100
4: Child.
3: Parent.

Explain the outputs of the program when the return value of f is 0, 1, and -1.
How does the program behave if the return value of f is changed to some integer
value other than 0, 1, and -1? How does the program behave if the return type
of f is changed to void and the return statement in f is commented? [18 points]

