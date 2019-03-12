#include <stdio.h>
#include <math.h>
#include <stdint.h>
#include <inttypes.h>

#define MAX_BUFF_LEN 1024 
#define max(a, b) (((a) > (b)) ? (a) : (b))

int get_str_len(char* arr);
int char_to_int(char c);
char* mul(char* src, char* dst, char* ret);
void test();

int main()
{
    test();
    char src_buff[MAX_BUFF_LEN] = {0};
    char dst_buff[MAX_BUFF_LEN] = {0};
    char ret_buff[MAX_BUFF_LEN * 2] = {0};
    printf("input number one:");
    scanf("%s", src_buff);
    printf("input number two:");
    scanf("%s", dst_buff);
    char* ret_str = mul(src_buff, dst_buff, ret_buff);
    printf("ret:%s\n", ret_str);
}

int get_str_len(char* arr)
{
    int len = 0;
    while(*arr++ != 0)
    {
        ++len;
    }
    return len;
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
        printf("wrong hex ascii %d\n", c);
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
        return (int)(a + 'a');
    }
    else
    {
        printf("wrong logic hex num:%d\n", a);
        return '0';
    }
}

char* mul(char* src, char* dst, char* ret_buff)
{
    int base = 16;
    int carry;
    int index = 0;
    int src_len = get_str_len(src);
    int dst_len = get_str_len(dst);
    int ret_buff_width = max(src_len, dst_len) * 2;
    for(int i = 0; i < ret_buff_width; ++i)
    {
        ret_buff[i] = '0';
    }
    for(int i = src_len - 1; i >= 0; --i)
    {
        carry = 0;
        int a = char_to_int(src[i]); 
        int dst_index = ret_buff_width - index -1;
        int cur_base = pow(base, index);
        for(int j = dst_len - 1; j >= 0; --j)
        {
            int b = char_to_int(dst[j]); 
            int ori = char_to_int(ret_buff[dst_index]);
            int ret = a * b + carry + ori; 
            carry = ret / base;
            ret = ret % base;
            ret_buff[dst_index] = int_to_char(ret); 
            --dst_index;
        }
        ret_buff[dst_index] = int_to_char(carry);
        index = index + 1;
    }
    return ret_buff;
}
void test()
{
    printf("%x * %x = %x\n", 0x100A, 0X200b, 0x100A * 0X200b);
    printf("%x * %x = %x\n", 0x21dA, 0X2fab, 0x21dA * 0X2fab);
    printf("%x * %x = %x\n", 0xc1dA, 0X2eab, 0xc1dA * 0X2eab);
    printf("%x * %x = %x\n", 0xcbfA, 0Xafab, 0xcbfA * 0Xafab);
    int64_t x1 = 0xcbfAddaa;
    int64_t x2 = 0xafab1002;
    int64_t ret = x1 * x2;
    printf("%x * %x = %llx\n", 0xcbfAddaa, 0xafab1002, ret); 
}