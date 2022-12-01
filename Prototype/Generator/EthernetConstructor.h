//
// Created by khaled on 11/27/22.
//

#ifndef GENERATOR_ETHERNETCONSTRUCTOR_H
#define GENERATOR_ETHERNETCONSTRUCTOR_H


#include <string>
#include "FrameConstructor.h"
class EthernetConstructor : public FrameConstructor
{
private:
    const static int headerSize = 8 + 6 + 6 + 2 + 4;
    constexpr static unsigned char preamble[] = {0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAB};
    //type of network layer protocol or length of data
    std::string type;
    std::string payload;
    std::string CRC;
    //may need to insert 12-byte inter-packet gap, not sure

public:
    EthernetConstructor(std::string sourceAddress, std::string destinationAddress,
                        const std::string payload,
                        std::string innerProtocol) ;

    void constructFrame();

    int calculateCRC(int payloadSize, std::string payload);

};


#endif //GENERATOR_ETHERNETCONSTRUCTOR_H
