#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include <stddef.h>


// int main(){
//     int p = getpid();
//     int z=5;
//     printf("parent :%d\n",p);
//     int f = fork();
//     if(f==0) {
//         printf("child :%d\n",getpid());
//         printf("parent :%d\n",getppid());
//     }
//     else{
//         sleep(10);
//        printf(" parent : %d\n",getpid());
//     }
//    z = yield();
//    printf("%d",z);
//     exit(0);
// }

//      getpa()
// int main(){
//     uint64 *p=(uint64*)malloc(sizeof(uint64));
//     printf("Virtual Addr: %x\n",p);
//     printf("Physical Addr: %x\n",getpa(p));
//     exit(0);
// }

// int main(){
//     int f0=fork();
//     if(f0==0){
//         printf("[CHILD1] %d\n",getpid());
//     }else{
//         int f1=fork();
//         if(f1==0){
//             sleep(10);
//             printf("[CHILD2] %d\n",getpid());
//         }else{
//             waitpid((uint64)f1,NULL);
//             // sleep(20);
//             // printf("%d\n",f1);
//             printf("[PARENT] %d\n", getpid());
//         }
//     }
//     exit(0);
// }

int main(){
    cps();
    exit(0);
}