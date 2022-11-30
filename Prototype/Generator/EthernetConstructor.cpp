//
// Created by khaled on 11/27/22.
//

#include "EthernetConstructor.h"

EthernetConstructor::EthernetConstructor(unsigned char *sourceAddress, unsigned char *destinationAddress,
                                         const int payloadSize, const unsigned char *payload,
                                         unsigned char *innerProtocol) : FrameConstructor(sourceAddress, destinationAddress){
    this->payloadSize = payloadSize;
    this->payload = new unsigned char [payloadSize];
    for(int i=0; i<payloadSize; i++)
        this->payload[i] = payload[i];

    type[0] = innerProtocol[0];
    type[1] = innerProtocol[1];
}

void EthernetConstructor::constructFrame() {

    frame = new unsigned char[headerSize + payloadSize];
    int framePointer = 0;
    for(int i=0; i<6; i++)
        frame[framePointer++] = source_address[i];
    for(int i=0; i<6; i++)
        frame[framePointer++] = destination_address[i];
    for(int i=0; i<2; i++)
        frame[framePointer++] = type[i];
    for(int i=0; i<payloadSize; i++)
        frame[framePointer++] = payload[i];

    calculateCRC(payloadSize, payload);
    for(int i=0; i<4; i++)
        frame[framePointer++] = CRC[i];
}

int EthernetConstructor::calculateCRC(int payloadSize, unsigned char *payload) {
    int crc = 0;
    return crc;
}
