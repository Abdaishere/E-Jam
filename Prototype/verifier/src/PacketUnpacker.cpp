#include "PacketUnpacker.h"
#include <iostream>
std::queue<ByteArray*> PacketUnpacker::packetQueue;
void PacketUnpacker::readPacket()
{
    //hard coded to receive a packet until finishing the gateway //todo
    int senderAddr = 6, destinationAddr = 6, payloadAddr = 13, crc = 6;
    ByteArray* packet = new ByteArray("AABBCCFFFFFF00xyZabcdefghijklm123456", senderAddr+destinationAddr+payloadAddr+crc, 0);
    mtx.lock();
    packetQueue.push(packet);
    mtx.unlock();
}

ByteArray* PacketUnpacker::consumePacket()
{
    //return nullptr if queue is empty
    if(packetQueue.size() == 0) return nullptr;
    //take a packet from the queue and check if
    mtx.lock();
    ByteArray* packet = packetQueue.front();
    //remove it from queue
    packetQueue.pop();
    mtx.unlock();
    return packet;
}

void PacketUnpacker::verifiyPacket()
{
    ByteArray* packet = consumePacket();
    //nothing to do if no packet
    if(packet == nullptr) return;

    //Extract Stream ID
    int streamID_startIndex = MAC_ADD_LEN+MAC_ADD_LEN+FRAME_TYPE_LEN;
    ByteArray tempBA (5, 0);
    tempBA.write(*packet, streamID_startIndex, streamID_startIndex + STREAMID_LEN-1);
    char* strmID = (char*)tempBA.bytes;

    //Check stream id
    ConfigurationManager::setCurrStreamID(strmID);
    Configuration* tempConfig = ConfigurationManager::getConfiguration();

    //Report stream id error
    if(tempConfig == nullptr)
    {
        ErrorInfo* errorInfo = ErrorHandler::getInstance()->packetErrorInfo;
        if(errorInfo == nullptr)
        {
            errorInfo = new ErrorInfo(packet);
        }
        errorInfo->addError(STREAM_ID);
        ErrorHandler::getInstance()->logError();
        return;
    }

    //check for frame errors
    int startIndex = 0, endIndex = packet->length;
    FrameVerifier* fv = FrameVerifier::getInstance();
    bool frameStatus = fv->verifiy(packet, startIndex, endIndex);

    //check for payload error
    int payloadLength = ConfigurationManager::getConfiguration()->getPayloadLength();
    startIndex = streamID_startIndex;
    endIndex = startIndex+STREAMID_LEN+payloadLength-1;

    PayloadVerifier* pv = PayloadVerifier::getInstance();
    bool payloadStatus = pv->verifiy(packet, startIndex, endIndex);
}


