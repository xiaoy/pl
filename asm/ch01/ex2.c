#include <stdio.h>
#include <math.h>
void test();
int hex_to_decimal(char* buff)
{
    int count = 0;
    while(buff[count] != '\0')
    {
        count += 1;
    }

    int sum = 0;    
    for(int i = 0; i < count; ++i)
    {
        char c = buff[i];
        int num = 0;
        if(c >= '1' && c <= '9')
        {
            num = (int)(c - '1') + 1;
        }
        else if(c >= 'a' && c <= 'f')
        {
            num = (int)(c - 'a') + 10;
        }
        else if(c >= 'A' && c <= 'F')
        {
            num = (int)(c - 'A') + 10;
        }
        sum += num * pow(16, count - i - 1); 
    }
    return sum;
}
int main() {
    char buff[64];
    printf("input 32 bit hex:");
    scanf("%32s", buff);
    int ret = hex_to_decimal(buff);
    printf("hex:%s decimal:%d\n", buff, ret);
    test();
}

void test()
{
    printf("0xaaa333:%d, %d\n", 0xaaa333, hex_to_decimal("aaa333"));
    printf("0x0f000e:%d, %d\n", 0x0f000e, hex_to_decimal("0f000e"));
    printf("0xfabcde1:%d, %d\n", 0xfabcde1, hex_to_decimal("fabcde1"));
    printf("0x12345f:%d, %d\n", 0x12345f, hex_to_decimal("12345f"));
}