
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
    void generateRandomCharacters(int);
    void addStreamId();
    RNG rng;
    PayloadType payloadType;
    int global_id;
    void generateAlphabet();
public:
    //must specify the length of the payload and its type
    PayloadGenerator(Configuration);
    PayloadGenerator(Configuration, int);
    ByteArray getPayload();
    void regeneratePayload(uint64_t);
};


#endif //GENERATOR_PAYLOADGENERATOR_H
