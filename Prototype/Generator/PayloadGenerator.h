//
// Created by khaled on 11/27/22.
//

#ifndef GENERATOR_PAYLOADGENERATOR_H
#define GENERATOR_PAYLOADGENERATOR_H


#include <string>
#include "Byte.h"

class PayloadGenerator
{
private:
    ByteArray payload;
    void generateRandomCharacters();
    void generateAlphabet();
public:
    explicit PayloadGenerator(int type);
    ByteArray getPayload();

};


#endif //GENERATOR_PAYLOADGENERATOR_H
