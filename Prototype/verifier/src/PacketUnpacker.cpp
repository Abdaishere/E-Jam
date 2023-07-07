#include "PacketUnpacker.h"
#include "PacketReceiver.h"
#include <iostream>
#include <utility>
std::queue<std::shared_ptr<ByteArray>> PacketUnpacker::packetQueue;
void PacketUnpacker::readPacket()
{
    //massive change: mutex applied only when pushing packet, not when receiving it from the gateway
    std::shared_ptr<ByteArray> packet = std::make_shared<ByteArray>(1600, 'a');
    packetReceiver->receivePackets(packet);
    mtx.lock();
    packetQueue.push(packet);
    mtx.unlock();
}

PacketUnpacker::PacketUnpacker(int verID, Configuration configuration)
{
    std::string path = "/tmp/fifo_pipe_ver" + std::to_string(verID);
    packetReceiver = PacketReceiver::getInstance(verID, path);
    this->configuration = configuration;

    std::vector<ByteArray> senders = this->configuration.getSenders();
    for(const ByteArray& sender:senders)
        srcMacAddresses.push_back(sender);
    std::sort(srcMacAddresses.begin(), srcMacAddresses.end());

    int genNum = (int)senders.size();
    frameVerifier = std::vector<FrameVerifier> ();
    payloadVerifier = std::vector<PayloadVerifier> ();
    seqChecker = std::vector<SeqChecker> ();
    for(int i=0; i<genNum; i++){
        frameVerifier.emplace_back(configuration);
        payloadVerifier.emplace_back(configuration, i);
        seqChecker.emplace_back();
    }

	statsManager = StatsManager::getInstance(configuration,verID, false);
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
    bool pcktVerified = true;
    std::shared_ptr<ByteArray> packet = consumePacket();
    //Signal a packet received
    //nothing to do if no packet
    if(packet == nullptr) return;

    //Extract Source Mac address
    int sourceMac_startIndex = MAC_ADD_LEN;
    ByteArray currSrcMac = packet->substr(sourceMac_startIndex, MAC_ADD_LEN);
//    print(&currSrcMac);
    int genID = std::lower_bound(srcMacAddresses.begin(), srcMacAddresses.end(), currSrcMac) - srcMacAddresses.begin();
    if(genID >= srcMacAddresses.size() || srcMacAddresses[genID] != currSrcMac)
    {
        writeToFile("temp config null\n");
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
    seqChecker[genID].receive(seqNum);
//    writeToFile("SeqNum: " +  std::to_string(seqNum));
//    writeToFile("Missing : " + std::to_string(seqChecker[genID].getMissing()));
//    writeToFile("Reordered:" + std::to_string(seqChecker[genID].getReordered()) + "\n");


    //check for frame errors
    //by matching receiver and sender mac addresses and checking the CRCs
    int startIndex = 0, endIndex = packet->length();
    bool frameStatus = frameVerifier[genID].verifiy(packet, startIndex, endIndex);
    pcktVerified &= frameStatus;

    //check for payload error
    //by matching payloads
    int payloadLength = configuration.getPayloadLength();
    startIndex = seqNumStartIndex+SeqNum_LEN;
    endIndex = startIndex+payloadLength-1;

	if(configuration.getCheckContent()){
		bool payloadStatus = payloadVerifier[genID].verifiy(packet, startIndex, endIndex, seqNum);
		pcktVerified &=payloadStatus;
	}
	if(pcktVerified)
		statsManager->increaseReceivedCorrectPckts(1);
	else
		statsManager->increaseReceivedWrongPckts(1);
}


