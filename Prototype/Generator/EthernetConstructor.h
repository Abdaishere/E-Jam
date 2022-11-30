//
// Created by khaled on 11/27/22.
//

#ifndef GENERATOR_ETHERNETCONSTRUCTOR_H
#define GENERATOR_ETHERNETCONSTRUCTOR_H


#include "FrameConstructor.h"
class EthernetConstructor : public FrameConstructor
{
    const static int headerSize = 8 + 6 + 6 + 2 + 4;
    constexpr static unsigned char preamble[] = {0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAB};
    //type of network layer protocol or length of data
    unsigned char type[2]{};
    unsigned char *payload;
    unsigned char CRC[4]{};
    int payloadSize;
    //may need to insert 12-byte inter-packet gap, not sure

    EthernetConstructor(unsigned char *sourceAddress, unsigned char *destinationAddress,
                        const int payloadSize, const unsigned char *payload,
                        unsigned char *innerProtocol) ;

    void constructFrame();

    int calculateCRC(int payloadSize, unsigned char* payload);

};


#endif //GENERATOR_ETHERNETCONSTRUCTOR_H
