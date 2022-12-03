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
            generateAlphabet((rand()%22)+5);
    }
}

void PayloadGenerator::generateAlphabet(int n)
{
   payload = ByteArray(n,0);
   for (int i=0; i<n; i++)
   {
       int offset = rand()%26;
       payload[i] = offset+'a';
   }
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


