#include "PacketUnpacker.h"
#include <iostream>

std::queue<ByteArray*> PacketUnpacker::packetQueue;
void PacketUnpacker::readPacket()
{
    //hard code to receive a packet until finishing the gateway //todo
    int senderAddr = 6, destinationAddr = 6, payloadAddr = 13, crc = 6;
    ByteArray packet("AABBCCFFFFFFabcdefghijklm123456", senderAddr+destinationAddr+payloadAddr+crc, 0);
    mtx.lock();
    packetQueue.push(&packet);
    mtx.unlock();
}

ByteArray* PacketUnpacker::consumePacket()
{
    //return nullptr if queue is empty
    if(packetQueue.size() == 0) return nullptr;
    //take a packet from the queue and check if
    mtx.lock();
    ByteArray* packet = packetQueue.front();
    //remove it from queue
    packetQueue.pop();
    mtx.unlock();
    return packet;
}

void PacketUnpacker::verifiyPacket()
{
    ByteArray* packet = consumePacket();
    //nothing to do if no packet
    if(packet == nullptr) return;
    //check for frame errors
    int startIndex = 0, endIndex = packet->length;
    FrameVerifier* fv = FrameVerifier::getInstance();
    bool frameStatus = fv->verifiy(packet, startIndex, endIndex);

    //check for payload error
    int payloadLength = 13;  //todo get payload length from configuration
    startIndex = 12, endIndex = startIndex+payloadLength;

    PayloadVerifier* pv = PayloadVerifier::getInstance();
    bool payloadStatus = pv->verifiy(packet, startIndex, endIndex);
}


