#ifndef PACKETUNPACKER_H
#define PACKETUNPACKER_H

#include "Byte.h"
#include "FramVerifier.h"
#include "PayloadVerifier.h"
#include "PacketReceiver.h"
#include <queue>
#include <mutex>
#include "StatsManager.h"

class PacketUnpacker
{
private:
    std::mutex mtx; //to protect packetQueue from data races
    ByteArray* consumePacket();
    PacketReceiver* packetReceiver;
public:
    static std::queue<ByteArray*> packetQueue;
    PacketUnpacker(int verID);
    void readPacket();
    void verifiyPacket();
};

#endif // PACKETUNPACKER_H
