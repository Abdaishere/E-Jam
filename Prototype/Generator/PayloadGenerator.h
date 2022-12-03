//
// Created by khaled on 11/27/22.
//

#ifndef GENERATOR_PAYLOADGENERATOR_H
#define GENERATOR_PAYLOADGENERATOR_H
#include "Configuration.h"


#include <string>
#include "Byte.h"

class PayloadGenerator
{
private:
    ByteArray payload;
    void generateFirstAlphabet();
    void generateSecondAlphabet();
    void generateAlphabet(int);
public:
    explicit PayloadGenerator(PayloadType);
    ByteArray getPayload();

};


#endif //GENERATOR_PAYLOADGENERATOR_H
