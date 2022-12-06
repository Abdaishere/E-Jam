#ifndef PACKETUNPACKER_H
#define PACKETUNPACKER_H

#include "Byte.h"
#include "FramVerifier.h"
#include "PayloadVerifier.h"
#include <queue>
#include <mutex>


class PacketUnpacker
{
    public:
        static std::queue<ByteArray*> packetQueue;
        void readPacket();
        void verifiyPacket();
    private:
        std::mutex mtx;
        ByteArray* consumePacket();
};

#endif // PACKETUNPACKER_H
