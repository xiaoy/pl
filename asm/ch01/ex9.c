#include <stdio.h>

#define MAX_LEN 1024
#define NUM_COUNT 8

int get_str_len(char* arr);
char* sub(char* src, char* dst);
int main()
{
    char src_buff[MAX_LEN] = {0};
    char dst_buff[MAX_LEN] = {0};
    printf("first binary(8):");
    scanf("%s", src_buff);
    printf("second binary(8):");
    scanf("%s", dst_buff);
    if(get_str_len(src_buff) != NUM_COUNT || get_str_len(dst_buff) != NUM_COUNT)
    {
        printf("wrong num bit, must 8 bit binary\n");
        return 0;
    }
    printf("%s - %s = ", src_buff, dst_buff);
    char* ret = sub(src_buff, dst_buff);
    printf("%s\n", ret);
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
char* sub(char* src, char* dst)
{
    for(int i = NUM_COUNT - 1; i >= 0; --i)
    {
        char a = src[i];
        char b = dst[i];
        if(a < b)
        {
            int carray_index = 0;
            for(int j = i - 1; j >= 0 ; --j)
            {
                if(src[j] > '0')
                {
                    carray_index = j;
                    break;
                }
            }
            src[carray_index] = '0';
            src[i] = '2';
            for(int k = carray_index + 1; k < i; ++k)
            {
                src[k] = '1';
            }
        }
        dst[i] = src[i] - dst[i] + '0';
    }
    return dst;
}