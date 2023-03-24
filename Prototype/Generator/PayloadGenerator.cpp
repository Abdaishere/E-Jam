
#include "PayloadGenerator.h"

PayloadGenerator::PayloadGenerator(Configuration configuration)
{
    int seed = configuration.getSeed();
    this->rng.setSeed(seed);

    int payloadLength = configuration.getPayloadLength();
    payload = ByteArray(payloadLength, 'a');
    payloadType = configuration.getPayloadType();
}

void PayloadGenerator::generateRandomCharacters()
{
    for(int i=0; i<payload.size(); i++)
    {
        unsigned char c = rng.gen();
        payload.at(i) = c;
        // so copy constructor works correctly
    }
}

void PayloadGenerator::regeneratePayload()
{
    //heuristic for payload type
    switch (payloadType)
    {
        case FIRST:
            generateFirstAlphabet(); //first half of alphabet a--m
            break;
        case SECOND:
            generateSecondAlphabet(); //second half of alphabet n--z
            break;
        default:
            generateRandomCharacters(); //random chars
    }
}

void PayloadGenerator::generateAlphabet()
{
    std::string tmp = "abcdefghijklmnopqrstuvwxyz";
    payload = ByteArray(tmp.begin(), tmp.end());
}

ByteArray PayloadGenerator::getPayload()
{
    return payload;
}

void PayloadGenerator::generateFirstAlphabet()
{
    std::string tmp = "abcdefghijklmabcdefghijklmabcdefghijklmabcdefghijklmabcdefghijklmabcdefghijklmabcdefghijklmabcdefghijklm";
    payload = ByteArray(tmp.begin(), tmp.end());
}

void PayloadGenerator::generateSecondAlphabet()
{
    std::string tmp = "nopqrstuvwxyz";
    payload = ByteArray(tmp.begin(), tmp.end());
}

void PayloadGenerator::addStreamId()
{
    std::string tmp = "abcdefghijklm";
    payload = ByteArray(tmp.begin(), tmp.end());
}


