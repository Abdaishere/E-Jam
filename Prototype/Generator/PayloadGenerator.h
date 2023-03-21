
#ifndef GENERATOR_PAYLOADGENERATOR_H
#define GENERATOR_PAYLOADGENERATOR_H
#include "Configuration.h"


#include <string>
#include "Byte.h"
#include "RNG.h"
#include "ConfigurationManager.h"

class PayloadGenerator
{
private:
    ByteArray payload;
    void generateFirstAlphabet(); // a -- m
    void generateSecondAlphabet(); // n -- z
    void generateRandomCharacters();
    void addStreamId();
    RNG rng;
    PayloadType payloadType;
    void generateAlphabet();
public:
    //must specify the length of the payload and its type
    PayloadGenerator(Configuration);
    ByteArray getPayload();
    void regeneratePayload();
};


#endif //GENERATOR_PAYLOADGENERATOR_H
