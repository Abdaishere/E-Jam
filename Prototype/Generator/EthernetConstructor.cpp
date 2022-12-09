//
// Created by khaled on 11/27/22.
//

#include "EthernetConstructor.h"

#define CRC_LEN 4
EthernetConstructor::EthernetConstructor(ByteArray& sourceAddress, ByteArray& destinationAddress,
                                         ByteArray& payload,
                                         ByteArray& innerProtocol) : FrameConstructor(sourceAddress, destinationAddress){
    this->payload = payload;
    type=innerProtocol;
}

void EthernetConstructor::constructFrame() {

    frame.reset(source_address.capacity + destination_address.capacity + type.capacity + payload.capacity + CRC_LEN);
    frame.write(destination_address);
    frame.write(source_address);
    frame.write(type);
    frame.write(payload);

    calculateCRC(payload);
    frame.write(CRC);
}

ByteArray EthernetConstructor::calculateCRC(ByteArray payload) {
    int crc = 0;
    CRC = ByteArray("Work", 4);
    return CRC;
}
