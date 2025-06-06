#ifndef PAYLOADVERIFIER_H
#define PAYLOADVERIFIER_H


#include "../../commonHeaders/Byte.h"
#include "streamsManager.h"
#include "ErrorHandler.h"
#include <memory>
#include "../../commonHeaders/RNG.h"

//singleton
class PayloadVerifier
{
private:
    Configuration configuration;
    PayloadType payloadType;
    void generatePayload();
    RNG rng;
    int gen_global_ID;
public:
    PayloadVerifier(Configuration, int);
    //parameters pointer to byteArray, start index, end index of payload
    bool verifiy(std::shared_ptr<ByteArray>&, int, int, int);
};

#endif // PAYLOADVERIFIER_H
