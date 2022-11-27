//
// Created by khaled on 11/27/22.
//

#ifndef GENERATOR_SEGMENTCONSTRUCTOR_H
#define GENERATOR_SEGMENTCONSTRUCTOR_H


#include "PayloadGenerator.h"

class SegmentConstructor
{
private:
    int protocol;
    char* segment;
public:
    SegmentConstructor(int protocol, const char* resultingString, int innerProtocol){};
    void constructSegment();
};


#endif //GENERATOR_SEGMENTCONSTRUCTOR_H
