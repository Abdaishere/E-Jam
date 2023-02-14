#ifndef PAYLOADVERIFIER_H
#define PAYLOADVERIFIER_H


#include "../commonHeaders/Byte.h"
#include "ConfigurationManager.h"
#include "ErrorHandler.h"

//singleton
class PayloadVerifier
{
    public:
        //parameters pointer to byteArray, start index, end index of payload
        bool verifiy(ByteArray*, int, int);
        static PayloadVerifier* getInstance();
    private:
        static PayloadVerifier* instance;
        //singleton class
        PayloadVerifier();
        PayloadType payloadType;
        void generatePayload();
};

#endif // PAYLOADVERIFIER_H
