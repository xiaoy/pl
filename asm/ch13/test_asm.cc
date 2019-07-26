#include <iostream>
#include <time.h>
//#include "indexof.h"
using namespace std;

extern "C" long IndexOf(long n, long array[], unsigned count);

int main(){
    const unsigned ARRAY_SIZE = 100000;
    const unsigned LOOP_SIZE = 100000;

    char* boolstr[] = {"flase", "true"};

    long array[ARRAY_SIZE];
    for(unsigned int i = 0; i < ARRAY_SIZE; ++i)
        array[i] = rand();
    
    long searchVal;
    time_t startTime, endTime;
    cout << "Enter en integer value to find: ";
    cin >> searchVal;
    cout << "Please wati..\n";

    time(&startTime);
    int count = 0;
    for(unsigned n = 0; n < LOOP_SIZE; n++)
    {
        count = IndexOf(searchVal, array, ARRAY_SIZE);
    }

    bool found = count != -1;

    time(&endTime);

    cout << "Elapsed ASM time: " << long(endTime - startTime) << " seconds. Found = " << boolstr[found] << endl;
    return 0;
}