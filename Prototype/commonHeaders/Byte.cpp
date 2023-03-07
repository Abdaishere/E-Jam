#include "Byte.h"

void print(ByteArray* ptr)
{
    int sz = ptr->size();
    for(int i=0;i<sz;i++)
    {
        std::cout<<(int)ptr->at(i);
    }
    std::cout<<std::endl;
}

void printChars(ByteArray* ptr)
{
    int sz = ptr->size();
    for(int i=0;i<sz;i++)
    {
        std::cout<<ptr->at(i);
    }
    std::cout<<std::endl;
}