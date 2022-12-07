//
// Created by khaled on 11/27/22.
//

#include "PayloadGenerator.h"

PayloadGenerator::PayloadGenerator(PayloadType payloadType)
{
    switch (payloadType)
    {
        case FIRST:
            generateFirstAlphabet();
            break;
        case SECOND:
            generateSecondAlphabet();
            break;
        default:
            generateRandomCharacters();
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

void PayloadGenerator::generateFirstAlphabet()
{
    payload = ByteArray("abcdefghijklm",13);
}

void PayloadGenerator::generateSecondAlphabet()
{
    payload = ByteArray("nopqrstuvwxyz",13);
}


