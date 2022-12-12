//
// Created by khaled on 11/27/22.
//

#include "EthernetConstructor.h"

//TODO Get values from Configuration manager
EthernetConstructor::EthernetConstructor(ByteArray& sourceAddress, ByteArray& destinationAddress,
                                         ByteArray& payload,
                                         ByteArray& innerProtocol) : FrameConstructor(sourceAddress, destinationAddress){
    this->payload = payload;
    type=innerProtocol;
}

void EthernetConstructor::constructFrame() {
    //TODO add rest of the ethernet frame fields ie. (preamble, type, etc...)
    frame.reset(source_address.capacity + destination_address.capacity + type.capacity + payload.capacity + CRC_LENGTH);
    frame.write(destination_address);
    frame.write(source_address);
    frame.write(type);
    frame.write(payload);

    calculateCRC(&payload);
    frame.write(CRC);
}

ByteArray EthernetConstructor::calculateCRC(ByteArray* payload)
{
    //TODO Calculate CRC
    int crc = 0;
    CRC = ByteArray("Work", 4);
    return CRC;
}
