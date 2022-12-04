#ifndef PACKETUNPACKER_H
#define PACKETUNPACKER_H

#include "Byte.h"
#include <queue>

class PacketUnpacker
{
    public:
        PacketUnpacker();
        virtual ~PacketUnpacker();
        static std::queue<ByteArray> packetQueue;
    private:
        void readPacket();
        ByteArray consumePacket();
};

#endif // PACKETUNPACKER_H
