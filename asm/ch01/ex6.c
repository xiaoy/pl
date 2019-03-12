#include <stdio.h>

#define MAX_BUFF_LEN 1024
#define NUM_COUNT 4

int char_to_int(char c);
char* add(char* src, char* dst, int len);
void test();

int main()
{
    //test();
    char src_buff[MAX_BUFF_LEN] = {0};
    char dst_buff[MAX_BUFF_LEN] = {0};
    printf("input number one:");
    scanf("%s", src_buff);
    printf("input number two:");
    scanf("%s", dst_buff);
    char* ret_str = add(src_buff, dst_buff, NUM_COUNT);
    printf("ret:%s\n", ret_str);
}

int char_to_int(char c)
{
    if(c >= '0' && c <= '9')
    {
        return (int)(c - '0');
    }
    else if(c >= 'a' && c <= 'f')
    {
        return (int)(c - 'a') + 10;
    }
    else if(c >= 'A' && c <= 'F')
    {
        return (int)(c - 'A') + 10;
    }
    else
    {
        return 0;
    }
}

char int_to_char(int a)
{
    if(a >= 0 && a <= 9)
    {
        return (char)(a + '0');
    }
    else if(a >= 10 && a <= 15)
    {
        a = a - 10;
        return (int)(a + 'A');
    }
    else
    {
        printf("wrong logic hex num\n");
        return '0';
    }
}
char* add(char* src, char* dst, int len)
{
    int base = 16;
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
void test()
{
    printf("%x + %x = %x\n", 0x100A, 0X200b, 0x100A + 0X200b);
    printf("%x + %x = %x\n", 0x21dA, 0X2fab, 0x21dA + 0X2fab);
    printf("%x + %x = %x\n", 0xc1dA, 0X2eab, 0xc1dA + 0X2eab);
    printf("%x + %x = %x\n", 0xcbfA, 0Xafab, 0xcbfA + 0Xafab);
}