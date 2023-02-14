#ifndef PACKETUNPACKER_H
#define PACKETUNPACKER_H

#include "../commonHeaders/Byte.h"
#include "FramVerifier.h"
#include "PayloadVerifier.h"
#include "PacketReceiver.h"
#include <queue>
#include <mutex>
#include "SeqChecker.h"
#include "../commonHeaders/StatsManager.h"

class PacketUnpacker
{
private:
    std::mutex mtx;
    ByteArray* consumePacket();
    PacketReceiver* packetReceiver;
    SeqChecker seqChecker;
public:
    static std::queue<ByteArray*> packetQueue;
    PacketUnpacker(int verID);
    void readPacket();
    void verifiyPacket();
};

#endif // PACKETUNPACKER_H
