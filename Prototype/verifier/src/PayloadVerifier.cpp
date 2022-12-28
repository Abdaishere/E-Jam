#include "PayloadVerifier.h"

PayloadVerifier* PayloadVerifier::instance = nullptr;

PayloadVerifier::PayloadVerifier()
{

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
                    printf("%c %c", packet->at(i) , 'a'+offset);
                    status = false;
                }
                offset++;
                if(offset == 13)offset = 0;
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
        case RANDOM:
            //TODO check random payload type
            status = true;
            break;
    }
    if(!status)
    {
        ErrorInfo* errorInfo = ErrorHandler::getInstance()->packetErrorInfo;
        if(errorInfo == nullptr)
        {
            errorInfo = new ErrorInfo(packet);
        }
        errorInfo->addError(PAYLOAD);
        ErrorHandler::getInstance()->logError();
    }
    return status;
}


