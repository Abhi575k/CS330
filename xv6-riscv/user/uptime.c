#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/date.h"
#include <time.h>

int main(){
    int tm=uptime();
    printf("System up for: %d seconds\n",tm/10);
    exit(0);
}