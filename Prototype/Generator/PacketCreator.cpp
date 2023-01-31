//
// Created by khaled on 11/27/22.
//

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
std::mutex PacketCreator::mtx; //to avoid data race on product queue

void PacketCreator::createPacket(int rcvInd)
{
    //Signal a packet created
    StatsManager* statsManager = StatsManager::getInstance();
    statsManager->increaseNumPackets();

    //TODO move ByteArray creating inside each constructor class
    ByteArray sourceAddress = ConfigurationManager::getConfiguration()->getMyMacAddress();
    ByteArray destinationAddress = ConfigurationManager::getConfiguration()->getReceivers()[rcvInd];

    PayloadGenerator* payloadGenerator = PayloadGenerator::getInstance();
    payloadGenerator->regeneratePayload();
    ByteArray payload = payloadGenerator->getPayload();
    ByteArray innerProtocol = ByteArray("00",2);
    innerProtocol[0] = (char)0x88;innerProtocol[1] = (char) 0xb5;
    ByteArray streamID = *ConfigurationManager::getConfiguration()->getStreamID();
    FrameConstructor* frameConstructor = new EthernetConstructor(sourceAddress, destinationAddress,
                                                                 payload,
                                                                 innerProtocol,streamID);
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
    //lock the mutex and consume then unloack it
    mtx.lock();
    ByteArray packet = productQueue.front();
    productQueue.pop();
    mtx.unlock();

    packet.print();
    sender->transmitPackets(packet);
    std::cerr << ("Packet transmitted\n");
}
