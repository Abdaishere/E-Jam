#include "FramVerifier.h"

//initialize the static instance
FrameVerifier* FrameVerifier::instance = nullptr;

FrameVerifier::FrameVerifier()
{
    //todo
}

//handle singleton instance
FrameVerifier* FrameVerifier::getInstance()
{
    if(instance == nullptr)
    {
        instance = new FrameVerifier();
    }
    return instance;
}

bool FrameVerifier::verifiy(ByteArray* packet, int startIndex, int endIndex)
{
    //todo
}
