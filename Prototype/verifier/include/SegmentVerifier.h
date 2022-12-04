#ifndef SEGMENTVERIFIER_H
#define SEGMENTVERIFIER_H

#include "Byte.h"

class SegmentVerifier
{
    public:
        SegmentVerifier(ByteArray);
        void setSegment(ByteArray);
    private:
        ByteArray segment;
        bool verifiy();
};

#endif // SEGMENTVERIFIER_H
