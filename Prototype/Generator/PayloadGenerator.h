//
// Created by khaled on 11/27/22.
//

#ifndef GENERATOR_PAYLOADGENERATOR_H
#define GENERATOR_PAYLOADGENERATOR_H
#include "Configuration.h"


#include <string>
#include "Byte.h"
#include "RNG.h"

class PayloadGenerator
{
private:
    ByteArray payload;
    void generateFirstAlphabet();
    void generateSecondAlphabet();
    void generateRandomCharacters(int seed = 0);
    RNG rng;
    void generateAlphabet();
public:
    //must specify the length of the payload and its type
    explicit PayloadGenerator(int cap, PayloadType type);
    ByteArray getPayload();

};


#endif //GENERATOR_PAYLOADGENERATOR_H
