#ifndef PACKETUNPACKER_H
#define PACKETUNPACKER_H

#include "Byte.h"
#include "FramVerifier.h"
#include "PayloadVerifier.h"
#include <queue>

class PacketUnpacker
{
    public:
        PacketUnpacker();
        virtual ~PacketUnpacker();
        static std::queue<ByteArray*> packetQueue;
        void readPacket();
        void verifiyPacket();
    private:
        ByteArray* consumePacket();
};

#endif // PACKETUNPACKER_H
