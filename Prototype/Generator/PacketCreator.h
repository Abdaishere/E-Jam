
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
public:
    PacketCreator(Configuration);
    static std::mutex mtx;
    static std::queue<ByteArray> productQueue;
    void createPacket(int);
    void sendHead();
};


#endif //GENERATOR_PACKETCREATOR_H
