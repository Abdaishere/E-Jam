#ifndef PAYLOADVERIFIER_H
#define PAYLOADVERIFIER_H


#include "../commonHeaders/Byte.h"
#include "streamsManager.h"
#include "ErrorHandler.h"
#include <memory>


//singleton
class PayloadVerifier
{
private:
    Configuration configuration;;
    PayloadType payloadType;
    void generatePayload();
public:
    PayloadVerifier(Configuration);
    //parameters pointer to byteArray, start index, end index of payload
    bool verifiy(std::shared_ptr<ByteArray>&, int, int);
};

#endif // PAYLOADVERIFIER_H
