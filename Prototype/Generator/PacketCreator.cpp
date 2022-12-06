//
// Created by khaled on 11/27/22.
//

#include "PacketCreator.h"
#include <iostream>

std::queue<ByteArray> PacketCreator::productQueue;
std::mutex PacketCreator::mtx;

void PacketCreator::createPacket()
{

    int len = 20;
    PayloadGenerator* payloadGenerator = new PayloadGenerator(len, 1);
    ByteArray src = ByteArray("BBBBBB",6);
    ByteArray dest = ByteArray("CCCCCC",6);
    ByteArray payload = payloadGenerator->getPayload();
    ByteArray innerProt =  ByteArray("00",2);
    FrameConstructor* frameConstructor = new EthernetConstructor(src,dest ,
                                                                 payload,
                                                                 innerProt);
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
