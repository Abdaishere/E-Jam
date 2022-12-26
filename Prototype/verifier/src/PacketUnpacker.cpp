#include "PacketUnpacker.h"
#include "PacketReceiver.h"
#include <iostream>
std::queue<ByteArray*> PacketUnpacker::packetQueue;
void PacketUnpacker::readPacket()
{
//    int senderAddr = 6, destinationAddr = 6, payloadAddr = 13, crc = 6;
//    ByteArray* packet = new ByteArray("AABBCCFFFFFF00xyZabcdefghijklm123456", senderAddr+destinationAddr+payloadAddr+crc, 0);
    //massive change: mutex applied only when pushing packet, not when receiving it from the gateway
    ByteArray* packet = new ByteArray(1600);
    packetReceiver->receivePackets(packet);
//    std::cerr << "packet received\n";
    std::cerr <<"packet in verification queue\n";
    mtx.lock();
    packetQueue.push(packet);
    mtx.unlock();
}

PacketUnpacker::PacketUnpacker(int verID)
{
    std::string path = "/tmp/fifo_pipe_ver" + std::to_string(verID);
    packetReceiver = PacketReceiver::getInstance(verID, path);
}

ByteArray* PacketUnpacker::consumePacket()
{
    //return nullptr if queue is empty
    if(packetQueue.empty()) return nullptr;
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
    //TODO make it adhere to the correct ethernet frame structure
    ByteArray* packet = consumePacket();

    //Signal a packet received
    StatsManager* statsManager = StatsManager::getInstance();
    statsManager->increaseNumPackets();

    //nothing to do if no packet
    if(packet == nullptr) return;

    std::cerr << "verifying packet\n";
    //Extract Stream ID
    //    int streamID_startIndex = PREMBLE_LENGTH+MAC_ADD_LEN+MAC_ADD_LEN+FRAME_TYPE_LEN;
    packet->print();
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
        std::cerr << strmID << "temp config null\n";
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
    //by matching receiver and sender mac addresses and checking the CRCs
    int startIndex = 0, endIndex = packet->length;
    FrameVerifier* fv = FrameVerifier::getInstance();
    bool frameStatus = fv->verifiy(packet, startIndex, endIndex);

    //check for payload error
    //by matching payloads
    int payloadLength = ConfigurationManager::getConfiguration()->getPayloadLength();
    startIndex = streamID_startIndex;
    endIndex = startIndex+STREAMID_LEN+payloadLength-1;

    PayloadVerifier* pv = PayloadVerifier::getInstance();
    bool payloadStatus = pv->verifiy(packet, startIndex, endIndex);
    //must delete pointer holding onto packet to avoid memory leak
    delete packet;
    std::cerr << "reached verification point\n";
    if(!frameStatus)
        std::cerr << "frame corrupted\n";
    if(!payloadStatus)
        std::cerr << "payload corrupted\n";
    if(frameStatus && payloadStatus)
        std::cerr << "frame correct\n";
}


