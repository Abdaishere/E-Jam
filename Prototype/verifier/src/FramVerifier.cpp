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

//    startIndex+=PREMBLE_LENGTH;
    //check for receiver
    bool correctReceiver = true;
    for(int i=0;i<MAC_ADD_LEN;i++)
    {
        if(acceptedRecv[i] != packet->at(i + startIndex))
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
        for(int j=0;j<MAC_ADD_LEN;j++)
        {
            if(acceptedSenders[i][j]!= packet->at(j+startIndex)){ fullMatch = false; break; }
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


    //Extract payload
    int payloadStart = MAC_ADD_LEN+MAC_ADD_LEN+FRAME_TYPE_LEN + STREAMID_LEN ;
    int payloadEnd = payloadStart + ConfigurationManager::getConfiguration()->getPayloadLength();

    //Extract CRC
    //Calculate the correct CRC
    //CRC includes stream len ID
    ByteArray* correctCRC = calculateCRC(packet, payloadStart, payloadEnd);
    startIndex = endIndex-CRC_LENGTH;
    //Try to Match CRCs
    bool crcCorrect = true;
    for(int i=0;i<CRC_LENGTH;i++)
    {
        if(correctCRC->at(i) != packet->at(i+startIndex)){ crcCorrect = false; break; }
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
    return new ByteArray(4, '4');
    ///TODO calculate CRC carefulllllllll ya hagryyyyyy
    return nullptr;
}
