//
// Created by khaled on 11/27/22.
//

#ifndef GENERATOR_ETHERNETCONSTRUCTOR_H
#define GENERATOR_ETHERNETCONSTRUCTOR_H

#include "Configuration.h"

#include "FrameConstructor.h"
#include "Byte.h"
class EthernetConstructor : public FrameConstructor
{
private:
    const static int headerSize = 8 + 6 + 6 + 2 + 4;
    constexpr static unsigned char preamble[] = {0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAB};
    //type of network layer protocol or capacity of data
    ByteArray type;
    ByteArray payload;
    ByteArray CRC;
    //may need to insert 12-byte inter-packet gap, not sure

public:
    EthernetConstructor(ByteArray& sourceAddress, ByteArray& destinationAddress,
                        ByteArray& payload,
                        ByteArray& innerProtocol) ;

    void constructFrame();

    ByteArray calculateCRC(ByteArray*);

};


#endif //GENERATOR_ETHERNETCONSTRUCTOR_H
