#ifndef DATAGRAMVERIFIER_H
#define DATAGRAMVERIFIER_H

#include "Byte.h"
class DatagramVerifier
{
    public:
        //parameters pointer to byteArray, start index, end index of payload
        bool verifiy(ByteArray*, int, int);
};

#endif // DATAGRAMVERIFIER_H
