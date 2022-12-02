//
// Created by khaled on 11/27/22.
//

#ifndef GENERATOR_PACKETCREATOR_H
#define GENERATOR_PACKETCREATOR_H
#include <mutex>
#include <queue>
#include <string>
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
public:
    static std::mutex mtx;
    static std::queue<ByteArray> productQueue;
    void createPacket();
    void sendHead();
};


#endif //GENERATOR_PACKETCREATOR_H
