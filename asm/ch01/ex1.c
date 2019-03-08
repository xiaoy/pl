#include <stdio.h>
#include <math.h>

int binary_to_decimal(char* buff,int size)
{
    int count = 1;
    for(int i = 0; i < size; ++i)
    {
        if(buff[i] == '\0')
        {
            break;
        }
        count += 1;
    }

    int sum = 0;    
    for(int i = 0; i < count; ++i)
    {
        if(buff[i] == '1')
        {
            sum += pow(2, count - i - 1); 
        }
    }
    return sum;
}
int main() {
    char buff[32] = {'0'};
    printf("input 16 bit binary binary:");
    scanf("%16s", buff);
    int ret = binary_to_decimal(buff, sizeof(buff));
    printf("binary:%s decimal:%d\n", buff, ret);
}