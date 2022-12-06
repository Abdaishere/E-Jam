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
    bool status = true;
    switch(ConfigurationManager::getConfiguration()->getPayloadType())
    {
        case FIRST:
            {
                int offset = 0;
                for(int i=startIndex;i<=endIndex;i++)
                {
                    if(packet->at(i) != 'a'+offset)
                    {
                        status = false;
                    }
                    offset++;
                }
                break;
            }
        case SECOND:
            {
                int offset = 0;
                for(int i=startIndex;i<=endIndex;i++)
                {
                    if(packet->at(i) != 'n'+offset)
                    {
                        status = false;
                    }
                    offset++;
                }
                break;
            }
    }
    if(status == false)
    {
        printf("error\n");
        ErrorInfo* errorInfo = ErrorHandler::getInstance()->packetErrorInfo;
        if(errorInfo == nullptr)
        {
            errorInfo = new ErrorInfo(packet);
        }
        errorInfo->addError(PAYLOAD);
        ErrorHandler::getInstance()->logError();
    }else
    {
        printf("ok\n");
    }
    return status;
}


