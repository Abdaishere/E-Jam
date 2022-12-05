#include "PacketUnpacker.h"
#include <iostream>

std::queue<ByteArray*> PacketUnpacker::packetQueue;

void PacketUnpacker::readPacket()
{
    //hard code to receive a packet until finishing the gateway //todo
    int macAddr = 6, destinationAddr = 6, payloadAddr = 13, crc = 6;
    ByteArray packet("AABBCCFFFFFFabcdefghijklm123456", macAddr+destinationAddr+payloadAddr+crc, 0);
    packetQueue.push(&packet);
}

ByteArray* PacketUnpacker::consumePacket()
{
    //return nullptr if queue is empty
    if(packetQueue.size() == 0) return nullptr;
    //take a packet from the queue and check if
    ByteArray* packet = packetQueue.front();
    //remove it from queue
    packetQueue.pop();
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

    //if there is an error on frame verification return error
    if(frameStatus == false)
    {
        //todo call the error handler
    }

    //check for payload error
    int payloadLength = 13;  //todo get payload length from configuration
    startIndex = 12, endIndex = startIndex+payloadLength;

    PayloadVerifier* pv = PayloadVerifier::getInstance();
    bool payloadStatus = pv->verifiy(packet, startIndex, endIndex);

    if(payloadStatus == false)
    {
        //todo call the error handler
    }

    //todo same thing goes to segment and datagram
}


