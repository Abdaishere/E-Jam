//
// Created by khaled on 11/27/22.
//

#ifndef GENERATOR_PACKETCREATOR_H
#define GENERATOR_PACKETCREATOR_H

#include <queue>
#include "PayloadGenerator.h"
#include "SegmentConstructor.h"
#include "DatagramConstructor.h"
#include "FrameConstructor.h"
#include "EthernetConstructor.h"

struct segmentConstructorInfo{
    //some relevant values regarding the headers of the protocol
    //payload
    //time to live
    //destination ip address
    //source ip address
    //
};

class PacketCreator
{
private:
    static PacketCreator* instance;
    std::queue<unsigned char*> productQueue;

    PacketCreator();
public:
    void createPacket();
    static PacketCreator* getInstance();
    void sendHead();
};


#endif //GENERATOR_PACKETCREATOR_H
