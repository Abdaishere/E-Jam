#ifndef PACKETUNPACKER_H
#define PACKETUNPACKER_H

#include "../commonHeaders/Byte.h"
#include "FramVerifier.h"
#include "PayloadVerifier.h"
#include "PacketReceiver.h"
#include <queue>
#include <mutex>
#include "SeqChecker.h"
#include <memory>
#include "../commonHeaders/StatsManager.h"

class PacketUnpacker
{
private:
    std::mutex mtx;
    std::shared_ptr<ByteArray> consumePacket();
    std::shared_ptr<PacketReceiver> packetReceiver;
    FrameVerifier frameVerifier;
    PayloadVerifier payloadVerifier;
    Configuration configuration;
    SeqChecker seqChecker;
public:
    static std::queue<std::shared_ptr<ByteArray>> packetQueue;
    PacketUnpacker(int verID, Configuration configuration);
    void readPacket();
    void verifiyPacket();
};

#endif // PACKETUNPACKER_H
