#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int checkInt(char* s){
    int idx=0;
    while(s[idx]!='\0'){
        if(s[idx]<'0'||s[idx]>'9') return 0;
        idx++;
    }
    return 1;
}

int main(int argc,char* argv[]){
    if(argc!=3){
        printf("Usage: forksleep <time_delay(m)> <mode(n)>\n");
        exit(0);
    }
    if(!checkInt(argv[1])||!checkInt(argv[2])||atoi(argv[2])<0||atoi(argv[2])>1){
        printf("Usage: forksleep <time_delay(m)> <mode(n)>\n");
        exit(0);
    }

    int m=atoi(argv[1]),n=atoi(argv[2]);
    int f=fork();
    if(f>0){
        if(n==1) sleep(m);
        printf("%d: Parent.\n",(int)getpid());
    }else if(f==0){
        if(n==0) sleep(m);
        printf("%d: Child.\n",(int)getpid());
    }else{
        printf("Error creating child.\n");
    }
    exit(0);
}