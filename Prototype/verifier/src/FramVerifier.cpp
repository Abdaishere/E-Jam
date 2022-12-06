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
    ErrorInfo* errorInfo = ErrorHandler::getInstance()->packetErrorInfo;

    bool status = true;

    //check first 6 entries with a sender
    bool correctSender = false;
    for(int i=0;i<acceptedSenders.size();i++)
    {
        //ith index is current sender compare it with first 6 entries in packet
        bool fullMatch = true;
        for(int j=0;j<6;j++)
        {
            if(acceptedSenders[i][j] != packet->at(j)){ fullMatch = false; break; }
        }
        if(fullMatch)
        {
            correctSender = true;
            break;
        }
    }

    if(!correctSender)
    {
        errorInfo = new ErrorInfo(packet);
        errorInfo->addError(SOURCE_MAC);
        status = false;
    }

    //check for receiver
    bool correctReceiver = true;
    for(int i=7;i<12;i++)
    {
        if(acceptedRecv[i-7] != packet->at(i))
        {
            correctReceiver = false;
            break;
        }
    }

    if(!correctReceiver)
    {
        if(errorInfo == nullptr)
        {
           errorInfo = new ErrorInfo(packet);
        }
        errorInfo->addError(DESTINATION_MAC);
        status = false;
    }

    return status;
}
