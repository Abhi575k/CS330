// 1. You will implement the barrier as a group of three system calls described below. You will implement
// an array of barriers inside xv6. Fix the size of the array to ten. Declare this array at an appropriate
// place inside the assignment3/xv6-riscv/kernel/ directory. You may put this declaration in a new file as well.

// #include "types.h"
// #include "riscv.h"
// #include "defs.h"
// #include "param.h"
// #include "memlayout.h"
// #include "spinlock.h"
// #include "proc.h"
// #include "sleeplock.h"
// #include "condvar.h"

int barriers[10]={0,0,0,0,0,0,0,0,0,0};

// A. barrier_alloc: The barrier_alloc system call will find a free barrier from the barrier array and return
// its id to the user program.

// int barrier_alloc(){
//     for(int i=0;i<10;i++){
//         if(barriers[i]==0){
//             barriers[i]=1;
//             return i;
//         }
//     }
//     return -1;
// }

// // B. barrier: This system call implements the barrier using condition variables. It takes three arguments:
// // barrier instance number, barrier array id, and number of processes. The implementation of this system
// // call should be such that when a process enters the barrier it prints out a line like the following.

// // pid: Entered barrier#k for barrier array id n

// // Replace pid, k, n with actual values. Also, after exiting the barrier, a process prints out a line like
// // the following.

// // pid: Finished barrier#k for barrier array id n

// // You should acquire an appropriate sleeplock for printing these without jumbling up the output.

// void barrier(int barrier_inst_num,int barrier_arr_id,int num_proc){
//     printf("%d: Entered barrier#%d for barrier array id %d\n",barriers[barrier_arr_id],barrier_inst_num,barrier_arr_id);
//     printf("%d: Finished barrier#%d for barrier array id %d\n",barriers[barrier_arr_id],barrier_inst_num,barrier_arr_id);
//     return;
// }

// // C. barrier_free: This system call frees the barrier corresponding to the passed barrier array id.

// void barrier_free(int id){
//     barriers[id]=0;
//     return;
// }
