//
// Created by khaled on 11/27/22.
//

#include "PacketCreator.h"
#include <iostream>

std::queue<ByteArray> PacketCreator::productQueue;
std::mutex PacketCreator::mtx;

void PacketCreator::createPacket()
{
    PayloadGenerator* payloadGenerator = new PayloadGenerator(0);
    FrameConstructor* frameConstructor = new EthernetConstructor(ByteArray("BBBBBB",6), ByteArray("CCCCCC",6),
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
