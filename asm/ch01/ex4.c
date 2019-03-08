#include <stdio.h>
#define true 1
#define false 0
char* decimal_to_hex(int a, char* buff)
{
    int index = 0;
    int ret;
    int remainder;
    int divide = a;
    while(true)
    {
        remainder = a % 16;
        a = a / 16;
        if(remainder <= 9)
        {
            buff[index++] = remainder + '0';
        }
        else if(remainder >= 10)
        {
            buff[index++] = (remainder - 10) + 'A';
        }
        if(a == 0)
        {
            break;
        }
    }

    for(int i = 0; i < index/2; ++i)
    {
        char c = buff[i];
        buff[i] = buff[index - i - 1];
        buff[index - i - 1] = c;
    }
    return buff;
}
int main()
{
    char buff[64] = {'\0'};
    int a;
    scanf("%d", &a);
    printf("%d:%s\n", a, decimal_to_hex(a, buff));
}