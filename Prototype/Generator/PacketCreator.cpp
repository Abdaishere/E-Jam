//
// Created by khaled on 11/27/22.
//

#include "PacketCreator.h"
#include <iostream>

std::queue<std::string> PacketCreator::productQueue;
std::mutex PacketCreator::mtx;

void PacketCreator::createPacket()
{
    PayloadGenerator* payloadGenerator = new PayloadGenerator(0);
    FrameConstructor* frameConstructor = new EthernetConstructor("BBBBBB", "CCCCCC",
                                                                 payloadGenerator->getPayload(),
                                                                 "00");
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
    std::string packet = productQueue.front();
    productQueue.pop();
    mtx.unlock();

    printf("%s\n",packet.c_str());
//    std::cout<<packet<<std::endl;
    //gateway.send(packet) //TODO
}
