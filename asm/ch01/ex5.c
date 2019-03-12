#include <stdio.h>

#define MAX_BUFF_LEN 1024
#define NUM_COUNT 1000 

int char_to_int(char c);
char* add(int base, char* src, char* dst, int len);

int main()
{
    int base;
    printf("input base num:");
    scanf("%d", &base);
    if(base < 2 || base > 10)
    {
        printf("wrong base number, input base num in range[2-10]\n");
        return 0;
    }
    char src_buff[MAX_BUFF_LEN] = {0};
    char dst_buff[MAX_BUFF_LEN] = {0};
    printf("input number one:");
    scanf("%s", src_buff);
    printf("input number two:");
    scanf("%s", dst_buff);
    char* ret_str = add(base, src_buff, dst_buff, NUM_COUNT);
    printf("ret:%s\n", ret_str);
}

int char_to_int(char c)
{
    return (int)(c - '0');
}

char int_to_char(int a)
{
    return (char)(a + '0');
}
char* add(int base, char* src, char* dst, int len)
{
    int carry = 0;
    for(int i = len - 1; i >= 0; --i)
    {
        int a = char_to_int(src[i]); 
        int b = char_to_int(dst[i]); 
        int ret = a + b + carry;
        carry = ret / base;
        ret = ret % base;
        dst[i] = int_to_char(ret); 
    }
    dst[len] = 0;
    return dst;
}