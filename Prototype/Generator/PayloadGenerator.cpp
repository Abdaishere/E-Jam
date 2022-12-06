//
// Created by khaled on 11/27/22.
//

#include "PayloadGenerator.h"


PayloadGenerator::PayloadGenerator(int cap, int type)
{
    payload = ByteArray(cap, type);
    switch (type)
    {
        case 1:
            generateRandomCharacters();
            break;
        default:
            generateAlphabet();
    }
}

void PayloadGenerator::generateRandomCharacters(int seed)
{
    rng.setSeed(rand());
    for(int i=0; i<payload.capacity; i++)
    {
        unsigned char c = rng.gen();
        payload.at(i) = c;
        // so copy constructor works correctly
        payload.length++;

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

