#ifndef PACKETUNPACKER_H
#define PACKETUNPACKER_H

#include "../../commonHeaders/StatsManager.h"
#include "../../commonHeaders/Byte.h"
#include "../../commonHeaders/Utils.h"
#include "FramVerifier.h"
#include "PayloadVerifier.h"
#include "PacketReceiver.h"
#include <queue>
#include <mutex>
#include "SeqChecker.h"
#include <memory>
#include <algorithm>
// we dedicate frameVerifiers and payloadVerifiers and seqCheckers for each generator in the stream
class PacketUnpacker
{
private:
    std::mutex mtx;
    std::shared_ptr<ByteArray> consumePacket();
    std::shared_ptr<PacketReceiver> packetReceiver;
    Configuration configuration;
    std::vector<ByteArray> srcMacAddresses;
    std::vector<FrameVerifier> frameVerifier;
    std::vector<PayloadVerifier> payloadVerifier;
	std::shared_ptr<StatsManager> statsManager;
    std::vector<SeqChecker> seqChecker;
public:
    static std::queue<std::shared_ptr<ByteArray>> packetQueue;
    PacketUnpacker(int verID, Configuration configuration);
    void readPacket();
    void verifiyPacket();
};

#endif // PACKETUNPACKER_H
