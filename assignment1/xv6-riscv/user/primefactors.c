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
	if(argc!=2){
        printf("Usage: pipeline <value(x)>\n");
        printf("value ranges from 2 to 100.\n");
        exit(0);
    }
    if(!checkInt(argv[1])||atoi(argv[1])<2||atoi(argv[1])>100){
        printf("Usage: pipeline <value(x)>\n");
        printf("value ranges from 2 to 100.\n");
        exit(0);
    }
    int fd[2];
    //  fd[0]: read
    //  fd[1]: write
	if(pipe(fd)<0){
		printf("Error creating pipe.\n");
		exit(0);
	}
    int data[]={2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97,atoi(argv[1]),0};
	if(data[25]%data[data[26]]==0){
        while(data[25]%data[data[26]]==0){
            printf("%d, ",data[data[26]]);
            data[25]/=data[data[26]];
        }
        printf("[%d]\n",(int)getpid());
    }
    if(data[25]<=1) exit(0);
    data[26]++;
    if(write(fd[1],data,27*sizeof(int))<0){
        printf("Error writing to pipe.\n");
        exit(0);
    }
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
        int temp[30];
        if(read(fd[0],temp,27*sizeof(int))<0){
            printf("Error reading from pipe.\n");
            exit(0);
        }
        if(temp[25]%temp[temp[26]]==0){
            while(temp[25]%temp[temp[26]]==0){
                printf("%d, ",temp[temp[26]]);
                temp[25]/=temp[temp[26]];
            }
            printf("[%d]\n",(int)getpid());
        }
		temp[26]++;
        if(write(fd[1],temp,27*sizeof(int))<0){
            printf("Error writing to pipe.\n");
            exit(0);
        }
		if(temp[25]>1){
			goto x;
		}
		close(fd[0]);
        close(fd[1]);
    }
	exit(0);
}