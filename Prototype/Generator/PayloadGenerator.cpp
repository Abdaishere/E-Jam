
#include "PayloadGenerator.h"

PayloadGenerator::PayloadGenerator(Configuration configuration) {
    int seed = configuration.getSeed();
    this->rng.setSeed(seed);

    int payloadLength = configuration.getPayloadLength();
    payload = ByteArray(payloadLength, 'a');
    payloadType = configuration.getPayloadType();
}

void PayloadGenerator::generateRandomCharacters() {
    for (int i = 0; i < payload.size(); i++)
        payload.at(i) = rng.gen();
}

void PayloadGenerator::regeneratePayload() {
    //heuristic for payload type
    switch (payloadType) {
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

ByteArray PayloadGenerator::getPayload() {
    return payload;
}

void PayloadGenerator::generateFirstAlphabet() {
    char nxt = 'a';
    for (int i = 0; i < payload.size(); i++) {
        payload.at(i) = nxt++;
        if (nxt == 'n')
            nxt = 'a';
    }
}

void PayloadGenerator::generateSecondAlphabet() {
    char nxt = 'n';
    for (int i = 0; i < payload.size(); i++) {
        payload.at(i) = nxt++;
        if (nxt - 1 == 'z')
            nxt = 'n';
    }
}


