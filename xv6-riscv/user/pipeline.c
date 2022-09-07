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

int main(int argc,char *argv[])
{
	if(argc!=3){
        printf("Usage: pipeline <number_of_processes(n)> <value(x)>\n");
        exit(0);
    }
    if(!checkInt(argv[1])||!checkInt(argv[2])||atoi(argv[1])<0){
        printf("Usage: pipeline <number_of_processes(n)> <value(x)>\n");
        exit(0);
    }
    int fd[2];
    //  fd[0]: read
    //  fd[1]: write
    int data[]={atoi(argv[1]),atoi(argv[2])+(int)getpid()};
	if(pipe(fd)<0){
		printf("Error creating pipe.\n");
		exit(0);
	}
    if(write(fd[1],data,2*sizeof(int))<0){
        printf("Error writing to pipe.\n");
        exit(0);
    }
	printf("%d: %d\n",(int)getpid(),data[1]);
	x: ;
    int id=fork();
    if(id<0){
        printf("Error creating fork.\n");
        exit(0);
    }
    else if(id>0){
		close(fd[0]);
        close(fd[1]);
    }else{
		// sleep(1);
        int temp[2];
        if(read(fd[0],temp,2*sizeof(int))<0){
            printf("Error reading from pipe.\n");
            exit(0);
        }
		temp[1]+=(int)getpid();
		printf("%d: %d\n",(int)getpid(),temp[1]);
		temp[0]--;
        if(write(fd[1],temp,2*sizeof(int))<0){
            printf("Error writing to pipe.\n");
            exit(0);
        }
		if(temp[0]>1){
			goto x;
		}
		close(fd[0]);
        close(fd[1]);
    }
	exit(0);
}