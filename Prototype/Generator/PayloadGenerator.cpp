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
    payload = "abcdefghijklmnopqrstuvwxyz";
}

std::string PayloadGenerator::getPayload()
{
    return payload;
}

