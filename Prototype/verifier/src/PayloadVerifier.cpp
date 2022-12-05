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
    switch(ConfigurationManager::getConfiguration()->getPayloadType())
    {
        case FIRST:
            {
                int offset = 0;
                for(int i=startIndex;i<=endIndex;i++)
                {
                    if(packet->at(i) != 'a'+offset)
                    {
                        return false;
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
                        return false;
                    }
                    offset++;
                }
                break;
            }
        default:
            return true; //todo handle random state
    }
}


