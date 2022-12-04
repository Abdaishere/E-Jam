#ifndef PAYLOADVERIFIER_H
#define PAYLOADVERIFIER_H


#include "Byte.h"
#include "ConfigurationManager.h"

class PayloadVerifier
{
    public:
        PayloadVerifier(ByteArray);
        void setPayload(ByteArray);
        void generatePayload();
    private:
        ByteArray payload;
        PayloadType payloadType;
        bool verifiy();
        void setPayloadType();
};

#endif // PAYLOADVERIFIER_H
