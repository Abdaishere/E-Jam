#include "PayloadVerifier.h"

PayloadVerifier* PayloadVerifier::instance = nullptr;

PayloadVerifier::PayloadVerifier()
{
    //ctor
}

//handle singleton instance
PayloadVerifier* PayloadVerifier::getInstance()
{
    if(instance == nullptr)
    {
        instance = new PayloadVerifier;
    }
    return instance;
}

bool PayloadVerifier::verifiy(ByteArray* packet, int startIndex, int endIndex)
{
    //todo
}


