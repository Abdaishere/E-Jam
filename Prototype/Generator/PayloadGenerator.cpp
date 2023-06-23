
#include "PayloadGenerator.h"

PayloadGenerator::PayloadGenerator(Configuration configuration) {
    uint64_t seed = configuration.getSeed();
    this->rng.setSeed(seed);

    int payloadLength = configuration.getPayloadLength();
    payload = ByteArray(payloadLength, 'a');
    payloadType = configuration.getPayloadType();
}

PayloadGenerator::PayloadGenerator(Configuration configuration, int global_id):global_id(global_id) {
    //initialize RNG
    uint64_t seed = configuration.getSeed();
    this->rng.setSeed(seed);
    for(int i=0; i<global_id; ++i)
        this->rng.long_jump();
    rng.fillTable(1);

    int payloadLength = configuration.getPayloadLength();
    payload = ByteArray(payloadLength, 'a');
    payloadType = configuration.getPayloadType();
}

void PayloadGenerator::generateRandomCharacters(int packetNumber) {
    rng.goTo(packetNumber);
    for (int i = 0; i < payload.size(); i++)
        payload.at(i) = rng.gen();
}

void PayloadGenerator::regeneratePayload(uint64_t seqNum) {
    switch (payloadType) {
        case FIRST:
            generateFirstAlphabet(); //first half of alphabet a--m
            break;
        case SECOND:
            generateSecondAlphabet(); //second half of alphabet n--z
            break;
        default:
            generateRandomCharacters(seqNum); //random chars
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


