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
    payload = ByteArray("abcdefghijklmnopqrstuvwxyz",26);
}

ByteArray PayloadGenerator::getPayload()
{
    return payload;
}

