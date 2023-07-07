
#ifndef GENERATOR_FRAMECONSTRUCTOR_H
#define GENERATOR_FRAMECONSTRUCTOR_H


#include <string>
#include <cstdint>
#include "Byte.h"

class FrameConstructor
{
protected:
    ByteArray frame;
    ByteArray destination_address;
    //Destination MAC address
    ByteArray source_address;      //Source MAC address
public:
    FrameConstructor(ByteArray);
    FrameConstructor(ByteArray, ByteArray);
    void setDestinationAddress(const ByteArray &destinationAddress);
    virtual void constructFrame(uint64_t&) = 0;
     ByteArray getFrame();
};


#endif //GENERATOR_FRAMECONSTRUCTOR_H
