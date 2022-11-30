//
// Created by khaled on 11/27/22.
//

#include "PayloadGenerator.h"

PayloadGenerator::PayloadGenerator(int type)
{
    switch (type)
    {
        default:
            generateAlphabet();
    }
}

void PayloadGenerator::generateRandomCharacters()
{
    //TODO
}

void PayloadGenerator::generateAlphabet()
{
    payload = (unsigned char *) "abcdefghijklmnopqrstuvwxyz";
    payloadSize = 26;
}

unsigned char*PayloadGenerator::getPayload()
{
    return payload;
}

int PayloadGenerator::getPayloadSize()
{
    return payloadSize;
}
