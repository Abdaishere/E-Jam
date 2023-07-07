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
    std::shared_ptr<StatsManager> statsManager = StatsManager::getInstance(configuration);

    //TODO move ByteArray creating inside each constructor class
    ByteArray destinationAddress = configuration.getReceivers()[rcvInd];

    payloadGenerator.regeneratePayload(seqNum);
    ByteArray payload = payloadGenerator.getPayload();

    ByteArray innerProtocol = ByteArray(2, '0');
    innerProtocol[0] = (unsigned char) 0x88;
    innerProtocol[1] = (unsigned char) 0xb5;
    ethernetConstructor.setType(innerProtocol);
    ethernetConstructor.setDestinationAddress(destinationAddress);
    ethernetConstructor.setPayload(payload);
    ethernetConstructor.constructFrame(seqNum);
    //lock the mutex and push to queue then unlock it
    mtx.lock();
    productQueue.push(ethernetConstructor.getFrame());
    mtx.unlock();
}

PacketCreator::PacketCreator(Configuration configuration, int id): payloadGenerator(configuration, id), ethernetConstructor(configuration.getMyMacAddress(), *configuration.getStreamID()){
    sender = PacketSender::getInstance();
    global_id = id;
    seqNum = 1;
    this->configuration = configuration;
}

void PacketCreator::sendHead()
{
    //busy waiting to ensure that a packet is sent
    while(productQueue.empty());
    mtx.lock();
    ByteArray packet = productQueue.front();
    productQueue.pop();
    mtx.unlock();
//    writeToFile("transmitting packets \n");
    sender->transmitPackets(packet);
	std::shared_ptr<StatsManager> statsManager = StatsManager::getInstance(configuration);
	statsManager->increaseSentPckts(1);
}