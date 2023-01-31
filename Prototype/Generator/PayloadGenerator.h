//
// Created by khaled on 11/27/22.
//

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
    static PayloadGenerator* instance;
    ByteArray payload;
    void generateFirstAlphabet(); // a -- m
    void generateSecondAlphabet(); // n -- z
    void generateRandomCharacters();
    void addStreamId();

    RNG rng;
    void generateAlphabet();
    explicit PayloadGenerator();
public:
    //must specify the length of the payload and its type
    ByteArray getPayload();
    static PayloadGenerator* getInstance();
    void regeneratePayload();
};


#endif //GENERATOR_PAYLOADGENERATOR_H
