//
// Created by khaled on 11/27/22.
//

#ifndef GENERATOR_PAYLOADGENERATOR_H
#define GENERATOR_PAYLOADGENERATOR_H


class PayloadGenerator
{
private:

public:
    explicit PayloadGenerator(int type);

    char* generateRandomCharacters();
    char* generateAlphabet();
};


#endif //GENERATOR_PAYLOADGENERATOR_H
