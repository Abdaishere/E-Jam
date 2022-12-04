#include "PacketUnpacker.h"
#include <iostream>
std::queue<ByteArray> PacketUnpacker::packetQueue;

void PacketUnpacker::readPacket()
{
    //hard code to receive a packet until finishing the gateway
    int macAddr = 6, destinationAddr = 6, payloadAddr = 13, crc = 6;
    ByteArray packet("AABBCCFFFFFFabcdefghijklm123456", macAddr+destinationAddr+payloadAddr+crc, 0);
    packetQueue.push(packet);
}

ByteArray PacketUnpacker::consumePacket()
{
    //take a packet from the queue and check if
    ByteArray packet = packetQueue.front();
    //remove it from queue
    packetQueue.pop();
    return packet;
}


