

#include "PacketCreator.h"
#include "ConfigurationManager.h"
#include <iostream>
#include <sys/stat.h>
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>
#include <StatsManager.h>

std::queue<ByteArray> PacketCreator::productQueue;
std::mutex PacketCreator::mtx;

void PacketCreator::createPacket(int rcvInd)
{
    //Signal a packet created
    std::shared_ptr<StatsManager> statsManager = StatsManager::getInstance();
    statsManager->increaseNumPackets();

    //TODO move ByteArray creating inside each constructor class
    ByteArray sourceAddress = ConfigurationManager::getConfiguration()->getMyMacAddress();
    ByteArray destinationAddress = ConfigurationManager::getConfiguration()->getReceivers()[rcvInd];

    std::shared_ptr<PayloadGenerator> payloadGenerator = PayloadGenerator::getInstance();
    payloadGenerator->regeneratePayload();
    ByteArray payload = payloadGenerator->getPayload();

    ByteArray innerProtocol = ByteArray(2, '0');
    innerProtocol[0] = (unsigned char) 0x88;
    innerProtocol[1] = (unsigned char) 0xb5;
    ByteArray streamID = *ConfigurationManager::getConfiguration()->getStreamID();
    std::shared_ptr<FrameConstructor> frameConstructor = std::make_shared<EthernetConstructor>(sourceAddress, destinationAddress,
                                                                 payload,
                                                                 innerProtocol, 
                                                                 streamID);
    frameConstructor->constructFrame();
    //TODO delete the values inside created ByteArray*
    //lock the mutex and push to queue then unlock it
    mtx.lock();
    productQueue.push(frameConstructor->getFrame());
    mtx.unlock();
}

PacketCreator::PacketCreator() {
    sender = PacketSender::getInstance();
}
#include <iostream>
void PacketCreator::sendHead()
{
    if(productQueue.size()<1)
    {
        return;
    }
    mtx.lock();
    ByteArray packet = productQueue.front();
    productQueue.pop();
    mtx.unlock();

    sender->transmitPackets(packet);
    std::cerr << ("Packet transmitted\n");
}
