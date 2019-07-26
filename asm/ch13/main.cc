#include <stdio.h>
extern "C" void asm_main();


int main()
{
    printf("init main\n");
    asm_main();
    return 0;
}