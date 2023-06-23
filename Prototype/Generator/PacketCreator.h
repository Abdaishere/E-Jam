
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
#include "PacketSender.h"
#include "xoshiro512+.cpp"
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
    std::shared_ptr<PacketSender> sender;
    PayloadGenerator payloadGenerator;
    Configuration configuration;
    EthernetConstructor ethernetConstructor;
    int global_id;
    uint64_t seqNum;
public:
    PacketCreator(Configuration, int id = 0);
    static std::mutex mtx;
    static std::queue<ByteArray> productQueue;
    void createPacket(int);
    void sendHead();
};


#endif //GENERATOR_PACKETCREATOR_H
