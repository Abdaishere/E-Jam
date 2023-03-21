#include "Byte.h"


std::string byteArray_to_string(const ByteArray& byteArray)
{
	std::string result = "";
	for(unsigned char uc: byteArray)
	{
		char c = (char) uc;
		result+=c;
	}
	return result;
}

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