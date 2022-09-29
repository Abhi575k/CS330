We have created a system call forkf which takes the address of a function as an argument to the system call. So, to make the system call we have to make several changes in some files as given in the question statement. And finally, we create a forkf() function in proc.c file which will contain the main code for system call.

The forkf() function is similar to fork() except that it takes a function address as argument and do the following :

1. Creates a new process.(Allocating from the list of UNUSED proc)
2. Copies the user memory from parent to child.
3. Copies saved user registers.
4. Sets a0(return register) to 0 to return 0 to parent.
5. Sets the epc register(user program counter) of child  so as to point to the function address passed in the argument.
6. Copies open file descriptors.
7. Return the pid.

On exiting the systemcall forkf , program counter register epc in child is pointing to the function address passed and hence that function executes first. After returning from that function, epc points to the instruction next to ecall(loosely syscall) as expected and carry on the child program as usual. Hence, our objective is achieved so that right after returning to user mode, first the given function executes and then the child program will continue.
Parent program will behave just like as in normal fork call.

Now coming back to the analsis of given program :

first we call forkf with function(f) as argument, which after returning to user mode in child process executes the function and then carries the remaining procedure of child. In parent there is a [sleep] system call which delays the parent process so as to complete the child first. In child process while executing f, we encounter fprintf, which uses [write] system call. After that child is also having fprintf. Then there is parent again ready and also uses fprintf. After that it calls [wait] system call which waits for the child process(if any) and then finally program is ended with an [exit] syscall. If forkf fails, then also there is an [exit] systemcall for that.
Implementations of these system calls - 
1. Forkf -> we created this system call as fork call with some function address as argument. The change was just that we had to set epc counter to point to function given as argument first in the child process. Remaining process remains the same.
2. Fork -> For forkf we used code of fork. So, Giving implementation details for fork -> First we allocate a new process, then we copy memory and registers from parent to child. After that the process of returning is explained in above lines. After that by aquiring wait lock, we set parent of new child to be the calling process. And then by locking the child process, we make its state runnable.
3.Sleep-> It acquires p->lock and release lk, after that it changes the process state to sleep and then call sched() to happen after some seconds as given in chan. After that it releases p->lock and the acquire lk.
4. Write call -> write() writes up to count bytes from the buffer starting at buf to the file referred to by the file descriptor fd.
5. wait -> After aquiring wait lock, it scans through proctable to look for exited children. When it finds exited children we release wait lock and then return.
6. Exit -> First it reparents (if any) child to init. Then wakes up the parent process if in sleep state. After that by acquiring p->lock it makes the state of process to be zombie.
