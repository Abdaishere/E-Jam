#ifndef SEGMENTVERIFIER_H
#define SEGMENTVERIFIER_H

#include "../../commonHeaders/Byte.h"

class SegmentVerifier
{
    public:
        //parameters pointer to byteArray, start index, end index of payload
        bool verifiy(ByteArray*, int, int);
};

#endif // SEGMENTVERIFIER_H
