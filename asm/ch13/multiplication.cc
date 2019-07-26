#include <iostream>
#include <iomanip>
using namespace std;

extern "C" 
{
    // exteral ASM procedures:
    void DisplayTable();
    void SetTextOutColor(unsigned color);

    // local C++ functions:
    int askForInteger();
    void showInt(int value, int width);
    void newLine();
}

int main()
{
    SetTextOutColor(0x1E);          // yellow on blue
    DisplayTable();
    return 0;
}

int askForInteger()
{
    int n;
    cout << "Enter an integer between 1 and 90,000:";
    cin >> n;
    return n;
}

void showInt(int value, int width)
{
    cout << setw(width) << value;
}

 void newLine()
 {
     cout << endl;
 }