#include <iostream>
#include <fstream>

using namespace std;

void TranslateBuffer(char* buf, unsigned count, unsigned char eChar);
int main(int argcount, char * args[])
{
    if(argcount < 3)
    {
        cout << "Usage: encode infile outfile" << endl;
        return -1;
    }

    const int BUFSIZE = 2000;
    char buffer[BUFSIZE];
    unsigned int count;
    unsigned char encryptCode;
    cout << "Encryption code [0-255?";
    cin >> encryptCode;

    ifstream infile(args[1], ios::binary);
    ofstream  outfile(args[2], ios::binary);

    cout << "Reading " << args[1] << " and creating " << args[2] << endl;
    while(!infile.eof())
    {
        infile.read(buffer, BUFSIZE);
        count = infile.gcount();
        TranslateBuffer(buffer, count, encryptCode);
        outfile.write(buffer, count);
    }
    return 0;
}
void TranslateBuffer(char* buf, unsigned count, unsigned char eChar)
{
    __asm
    {
        mov esi, buf
        mov ecx, count
        mov al, eChar
        L1:
            xor [esi], al 
            inc esi
            loop L1
    }
}