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

void PayloadGenerator::generateRandomCharacters(int seed = 0)
{

    for(int i=0; i<payload.length; i++)
    {
        unsigned char c = rng.gen();
        payload.write(c);
    }
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

