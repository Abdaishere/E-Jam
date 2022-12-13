#include "FramVerifier.h"

//initialize the static instance
FrameVerifier* FrameVerifier::instance = nullptr;

FrameVerifier::FrameVerifier()
{

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
    updateAcceptedSenders();
    std::vector<ByteArray>acceptedSenders = *(this->acceptedSenders);

    ErrorInfo* errorInfo = ErrorHandler::getInstance()->packetErrorInfo;

    bool status = true;

    startIndex+=PREMBLE_LENGTH;

    //check for receiver
    bool correctReceiver = true;
    for(int i=startIndex;i<startIndex+MAC_ADD_LEN-1;i++)
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

    //check first 6 entries with a sender
    startIndex+=MAC_ADD_LEN;
    bool correctSender = false;
    for(int i=0;i<acceptedSenders.size();i++)
    {
        //ith index is current sender compare it with first 6 entries in packet
        bool fullMatch = true;
        for(int j=startIndex;j<startIndex+MAC_ADD_LEN;j++)
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
        if(errorInfo == nullptr)
        {
            errorInfo = new ErrorInfo(packet);
        }
        errorInfo->addError(SOURCE_MAC);
        status = false;
    }
    //Extract CRC
    startIndex = endIndex-CRC_LENGTH;

    //Extract payload
    int payloadStart = MAC_ADD_LEN+MAC_ADD_LEN+FRAME_TYPE_LEN;
    int payloadEnd = payloadStart + STREAMID_LEN + ConfigurationManager::getConfiguration()->getPayloadLength();

    //Calculate the correct CRC
    ByteArray* correctCRC = calculateCRC(packet, payloadStart, payloadEnd);

    //Try to Match CRCs
    bool crcCorrect = true;
    for(int i=startIndex;i<startIndex+CRC_LENGTH;i++)
    {
        if(correctCRC->bytes[i] != packet->at(i)){ crcCorrect = false; break; }
    }
    if(!crcCorrect)
    {
        if(errorInfo == nullptr)
        {
            errorInfo = new ErrorInfo(packet);
        }
        errorInfo->addError(CRC);
        status = false;
    }
    delete correctCRC;


    return status;
}

void FrameVerifier::updateAcceptedSenders()
{
    acceptedSenders = &ConfigurationManager::getConfiguration()->getSenders();
}

ByteArray *FrameVerifier::calculateCRC(ByteArray * packet, int startIdx, int endIdx)
{
    //TODO calculate CRC
    return nullptr;
}
