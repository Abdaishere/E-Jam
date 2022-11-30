//
// Created by khaled on 11/27/22.
//

#ifndef GENERATOR_PAYLOADGENERATOR_H
#define GENERATOR_PAYLOADGENERATOR_H


class PayloadGenerator
{
private:
    unsigned char* payload;
    int payloadSize;
    void generateRandomCharacters();
    void generateAlphabet();
public:
    explicit PayloadGenerator(int type);
    unsigned char *getPayload();
    int getPayloadSize();

};


#endif //GENERATOR_PAYLOADGENERATOR_H
