#include <stdio.h>

float f(float x)
{
    return x * x;
}
int main()
{
    double sum = 0.0;
    double det = 1e-9;
    printf("det:%e\n", det);
    for(double i  = 1.0; i <=2.0; i = i + det)
    {
        sum = sum + det * f(i); 
    }
    printf("sum:%f\n", sum);
}