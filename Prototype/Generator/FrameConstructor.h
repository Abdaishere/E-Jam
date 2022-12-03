//
// Created by khaled on 11/27/22.
//

#ifndef GENERATOR_FRAMECONSTRUCTOR_H
#define GENERATOR_FRAMECONSTRUCTOR_H


#include <string>
#include "Byte.h"

class FrameConstructor
{
protected:
    ByteArray frame;
    ByteArray destination_address; //Destination MAC address
    ByteArray source_address;      //Source MAC address
public:
    FrameConstructor(ByteArray, ByteArray);
    virtual void constructFrame() = 0;
     ByteArray getFrame();
};


#endif //GENERATOR_FRAMECONSTRUCTOR_H
