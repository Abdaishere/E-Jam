//
// Created by khaled on 11/27/22.
//

#include "PacketCreator.h"
#include "ConfigurationManager.h"
#include <iostream>

std::queue<ByteArray> PacketCreator::productQueue;
std::mutex PacketCreator::mtx;

void PacketCreator::createPacket(int rcvInd)
{
    ByteArray sourceAddress = ConfigurationManager::getConfiguration()->getMyMacAddress();
    ByteArray destinationAddress = ConfigurationManager::getConfiguration()->getReceivers()[rcvInd];

    PayloadGenerator* payloadGenerator = new PayloadGenerator(ConfigurationManager::getConfiguration()->getPayloadType());
    FrameConstructor* frameConstructor = new EthernetConstructor(sourceAddress, destinationAddress,
                                                                 payloadGenerator->getPayload(),
                                                                 ByteArray("00",2));
    frameConstructor->constructFrame();

    mtx.lock();
    productQueue.push(frameConstructor->getFrame());
    mtx.unlock();


}



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

    packet.print();
//    std::cout<<packet<<std::endl;
    //gateway.send(packet) //TODO
}
