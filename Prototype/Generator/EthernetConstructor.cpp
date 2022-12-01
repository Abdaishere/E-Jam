//
// Created by khaled on 11/27/22.
//

#include "EthernetConstructor.h"

EthernetConstructor::EthernetConstructor(std::string sourceAddress, std::string destinationAddress,
                                         const std::string payload,
                                         std::string innerProtocol) : FrameConstructor(sourceAddress, destinationAddress){
    this->payload = payload;
    type=innerProtocol;
}

void EthernetConstructor::constructFrame() {

    frame = "";
    frame = source_address;
    frame+= destination_address;
    frame+=type;
    frame+=payload;

    calculateCRC(payload.size(), payload);
    frame+=CRC;
}

int EthernetConstructor::calculateCRC(int payloadSize, std::string payload) {
    int crc = 0;
    CRC = "Working";
    return crc;
}
