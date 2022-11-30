//
// Created by khaled on 11/27/22.
//

#ifndef GENERATOR_PACKETCREATOR_H
#define GENERATOR_PACKETCREATOR_H

#include "PayloadGenerator.h"
#include "SegmentConstructor.h"
#include "DatagramConstructor.h"
#include "FrameConstructor.h"

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
    PayloadGenerator* payloadGenerator;
    SegmentConstructor* segmentConstructor;
    DatagramConstructor* datagramConstructor;
    FrameConstructor* frameConstructor;
public:

    void createPacket();
};


#endif //GENERATOR_PACKETCREATOR_H
