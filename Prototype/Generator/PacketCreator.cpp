//
// Created by khaled on 11/27/22.
//

#include "PacketCreator.h"

void PacketCreator::createPacket()
{
    PayloadGenerator* payloadGenerator = new PayloadGenerator(0);
    FrameConstructor* frameConstructor = new EthernetConstructor((unsigned char *) "BBBBBB", (unsigned char *) "CCCCCC",
                                                                 payloadGenerator->getPayloadSize(), payloadGenerator->getPayload(),
                                                                 (unsigned char *) "00");

    frameConstructor->constructFrame();
    productQueue.push(frameConstructor->getFrame());
}

PacketCreator *PacketCreator::getInstance()
{
    return nullptr;
}

void PacketCreator::sendHead()
{
    unsigned char* packet = productQueue.front();
    productQueue.pop();

    //gateway.send(packet) //TODO
}
