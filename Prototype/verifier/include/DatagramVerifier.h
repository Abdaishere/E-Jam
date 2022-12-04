#ifndef DATAGRAMVERIFIER_H
#define DATAGRAMVERIFIER_H

#include "Byte.h"
class DatagramVerifier
{
    public:
        DatagramVerifier(ByteArray);
        void setData(ByteArray);
    private:
        ByteArray datagram;
        bool verifiy();
};

#endif // DATAGRAMVERIFIER_H
