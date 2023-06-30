#include "FramVerifier.h"

FrameVerifier::FrameVerifier(Configuration configuration)
{
    this->configuration = configuration;
}

bool FrameVerifier::verifiy(std::shared_ptr<ByteArray> packet, int startIndex, int endIndex)
{
    updateAcceptedSenders();
    std::vector<ByteArray>acceptedSenders = *(this->acceptedSenders);

    std::shared_ptr<ErrorInfo> errorInfo = ErrorHandler::getInstance()->packetErrorInfo;

    bool status = true;

    //check for receiver
    bool correctReceiver = true;
    for(int i=0;i<MAC_ADD_LEN;i++){
        if(configuration.getMyMacAddress()[i] != packet->at(i + startIndex))
        {
            correctReceiver = false;
            break;
        }
    }

    if(!correctReceiver){
        if(errorInfo == nullptr){
           errorInfo = std::make_shared<ErrorInfo>(packet);
        }
        errorInfo->addError(DESTINATION_MAC);
        status = false;
    }

    //check first 6 entries with a sender
    startIndex+=MAC_ADD_LEN;
    bool correctSender = false;
    for(int i=0;i<acceptedSenders.size();i++){
        //ith index is current sender compare it with first 6 entries in packet
        bool fullMatch = true;
        for(int j=0;j<MAC_ADD_LEN;j++){
            if(acceptedSenders[i][j]!= packet->at(j+startIndex)){ fullMatch = false; break; }
        }
        if(fullMatch){
            correctSender = true;
            break;
        }
    }

    if(!correctSender)
    {
        if(errorInfo == nullptr)
        {
            errorInfo = std::make_shared<ErrorInfo>(packet);
        }
        errorInfo->addError(SOURCE_MAC);
        status = false;
    }


    //Extract payload
    int payloadStart = MAC_ADD_LEN+MAC_ADD_LEN+FRAME_TYPE_LEN + STREAMID_LEN;
    int payloadEnd = payloadStart + configuration.getPayloadLength();

    //Extract CRC
    //Calculate the correct CRC
    //CRC includes stream len ID
    std::shared_ptr<ByteArray> correctCRC = calculateCRC(packet, payloadStart, payloadEnd);
    startIndex = endIndex-CRC_LENGTH;
    //Try to Match CRCs
    bool crcCorrect = true;
    for(int i=0;i<CRC_LENGTH;i++){
        if(correctCRC->at(i) != packet->at(i+startIndex)){ crcCorrect = false; break; }
    }
    if(!crcCorrect){
        if(errorInfo == nullptr){
            errorInfo = std::make_shared<ErrorInfo>(packet);
        }
        errorInfo->addError(CRC);
        status = false;
    }
    return status;
}

void FrameVerifier::updateAcceptedSenders()
{
    std::vector<ByteArray>& senders = configuration.getSenders();
    acceptedSenders = std::make_shared<std::vector<ByteArray>>(senders);
}

std::shared_ptr<ByteArray> FrameVerifier::calculateCRC(std::shared_ptr<ByteArray> packet, int startIdx, int endIdx)
{
    return std::make_shared<ByteArray>(4, '4');
    ///TODO calculate CRC carefulllllllll ya hagryyyyyy
}
