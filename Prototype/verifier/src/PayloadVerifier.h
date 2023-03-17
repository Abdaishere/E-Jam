#ifndef PAYLOADVERIFIER_H
#define PAYLOADVERIFIER_H


#include "../commonHeaders/Byte.h"
#include "ConfigurationManager.h"
#include "ErrorHandler.h"
#include <memory>


//singleton
class PayloadVerifier
{
    public:
        //parameters pointer to byteArray, start index, end index of payload
        bool verifiy(std::shared_ptr<ByteArray>&, int, int);
        static std::shared_ptr<PayloadVerifier> getInstance();
    private:
        static std::shared_ptr<PayloadVerifier> instance;
        //singleton class
        PayloadVerifier();
        PayloadType payloadType;
        void generatePayload();
};

#endif // PAYLOADVERIFIER_H
