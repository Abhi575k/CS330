#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"


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


int main(){
    uint64 *p=(uint64*)malloc(sizeof(uint64));
    printf("Virtual Addr: %x\n",p);
    printf("Physical Addr: %x\n",getpa(p));
    exit(0);
}