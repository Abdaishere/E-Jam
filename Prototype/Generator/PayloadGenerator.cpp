//
// Created by khaled on 11/27/22.
//

#include "PayloadGenerator.h"

PayloadGenerator* PayloadGenerator::instance = nullptr;

PayloadGenerator::PayloadGenerator()
{
    //TODO add stream id before actual Payload
    int seed = ConfigurationManager::getConfiguration()->getSeed();
    this->rng.setSeed(seed);

    int payloadLength = ConfigurationManager::getConfiguration()->getPayloadLength();
    payload = ByteArray(payloadLength,0);
}

void PayloadGenerator::generateRandomCharacters()
{
    payload.length=0;
    for(int i=0; i<payload.capacity; i++)
    {
        unsigned char c = rng.gen();
        payload.at(i) = c;
        // so copy constructor works correctly
        payload.length++;
    }
}

void PayloadGenerator::regeneratePayload()
{
    PayloadType payloadType = ConfigurationManager::getConfiguration()->getPayloadType();

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
    payload = ByteArray("abcdefghijklmabcdefghijklmabcdefghijklmabcdefghijklm"
                        "abcdefghijklmabcdefghijklmabcdefghijklmabcdefghijklm",104,0);
}

void PayloadGenerator::generateSecondAlphabet()
{
    payload = ByteArray("nopqrstuvwxyz",13);
}


PayloadGenerator *PayloadGenerator::getInstance()
{
    if(instance == nullptr)
    {
        instance = new PayloadGenerator();
    }
    return instance;
}

void PayloadGenerator::addStreamId()
{
    payload = ByteArray("abcdefghijklm",13);
}


