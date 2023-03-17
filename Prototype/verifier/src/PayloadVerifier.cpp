#include "PayloadVerifier.h"

std::shared_ptr<PayloadVerifier> PayloadVerifier::instance = nullptr;

PayloadVerifier::PayloadVerifier()
{

}

//handle singleton instance
std::shared_ptr<PayloadVerifier> PayloadVerifier::getInstance()
{
    if(instance == nullptr)
    {
        instance.reset(new PayloadVerifier());
    }
    return instance;
}

bool PayloadVerifier::verifiy(std::shared_ptr<ByteArray>& packet, int startIndex, int endIndex)
{
    bool status = true;
    switch(ConfigurationManager::getConfiguration()->getPayloadType())
    {
        case FIRST: //verify first half of alphabet a--m
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
        case SECOND: //verify second half of alphabet n--z
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
        std::shared_ptr<ErrorInfo> errorInfo = ErrorHandler::getInstance()->packetErrorInfo;
        if(errorInfo == nullptr)
        {
            errorInfo = std::make_shared<ErrorInfo>(packet);
        }
        errorInfo->addError(PAYLOAD);
        ErrorHandler::getInstance()->logError();
    }
    return status;
}


