#include "PacketUnpacker.h"
#include "PacketReceiver.h"
#include <iostream>
std::queue<std::shared_ptr<ByteArray>> PacketUnpacker::packetQueue;
void PacketUnpacker::readPacket()
{
    //massive change: mutex applied only when pushing packet, not when receiving it from the gateway
    std::shared_ptr<ByteArray> packet = std::make_shared<ByteArray>(1600, 'a');
    packetReceiver->receivePackets(packet);
    std::cerr <<"packet in verification queue\n";
    mtx.lock();
    packetQueue.push(packet);
    mtx.unlock();
}

PacketUnpacker::PacketUnpacker(int verID)
{
    std::string path = "/tmp/fifo_pipe_ver" + std::to_string(verID);
    packetReceiver = PacketReceiver::getInstance(verID, path);
    seqChecker = SeqChecker();
}

std::shared_ptr<ByteArray> PacketUnpacker::consumePacket()
{
    //return nullptr if queue is empty
    if(packetQueue.empty()) return nullptr;
    //take a packet from the queue and check if
    mtx.lock();
    std::shared_ptr<ByteArray> packet = packetQueue.front();
    //remove it from queue
    packetQueue.pop();
    mtx.unlock();
    return packet;
}

void PacketUnpacker::verifiyPacket()
{
    //TODO make it adhere to the correct ethernet frame structure
    std::shared_ptr<ByteArray> packet = consumePacket();

    //Signal a packet received
    std::shared_ptr<StatsManager> statsManager = StatsManager::getInstance();

    //nothing to do if no packet
    if(packet == nullptr) return;
    statsManager->increaseNumPackets(1);

    std::cerr << "verifying packet\n";
    //Extract Stream ID
    int streamID_startIndex = MAC_ADD_LEN+MAC_ADD_LEN+FRAME_TYPE_LEN;
    ByteArray tempBA;
    tempBA.append(*packet, streamID_startIndex, STREAMID_LEN);

    //Check stream id
    ConfigurationManager::setCurrStreamID(tempBA);
//    for(int i=0; i<packet->size(); i++)
//        std::cerr << (int) packet->at(i) << " ";
//    std::cerr << "\n";

    std::shared_ptr<Configuration> tempConfig = ConfigurationManager::getConfiguration();

    //Report stream id error
    if(tempConfig == nullptr)
    {
        std::cerr << "temp config null\n";
        std::shared_ptr<ErrorInfo> errorInfo = ErrorHandler::getInstance()->packetErrorInfo;
        if(errorInfo == nullptr)
        {
            errorInfo = std::make_shared<ErrorInfo>(packet);
        }
        errorInfo->addError(STREAM_ID);
        ErrorHandler::getInstance()->logError();
        return;
    }

    //unpack sequence number
    unsigned long long seqNum = 0;
    int seqNumStartIndex = MAC_ADD_LEN+MAC_ADD_LEN+FRAME_TYPE_LEN+STREAMID_LEN;
    for(int i=0; i<8; i++)
        seqNum |= ((unsigned long long )packet->at(seqNumStartIndex+i) << (i*8));
    seqChecker.receive(seqNum);
    std::cerr << seqNum << "\n";


    //check for frame errors
    //by matching receiver and sender mac addresses and checking the CRCs
    int startIndex = 0, endIndex = packet->length();
    std::shared_ptr<FrameVerifier> fv = FrameVerifier::getInstance();
    bool frameStatus = fv->verifiy(packet, startIndex, endIndex);

    //check for payload error
    //by matching payloads
    int payloadLength = ConfigurationManager::getConfiguration()->getPayloadLength();
    startIndex = streamID_startIndex+STREAMID_LEN+SeqNum_LEN;
    endIndex = startIndex+payloadLength-1;

    std::shared_ptr<PayloadVerifier> pv = PayloadVerifier::getInstance();
    bool payloadStatus = pv->verifiy(packet, startIndex, endIndex);
    //must delete pointer holding onto packet to avoid memory leak (no need with smart pointers)
    if(!frameStatus)
        std::cerr << "frame corrupted\n";
    else
        std::cerr << "frame correct\n";
    if(!payloadStatus)
        std::cerr << "payload corrupted\n";
    else
        std::cerr << "payload correct\n";
}


