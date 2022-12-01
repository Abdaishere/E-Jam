//
// Created by khaled on 11/27/22.
//

#ifndef GENERATOR_PAYLOADGENERATOR_H
#define GENERATOR_PAYLOADGENERATOR_H


#include <string>

class PayloadGenerator
{
private:
    std::string payload;
    void generateRandomCharacters();
    void generateAlphabet();
public:
    explicit PayloadGenerator(int type);
    std::string getPayload();

};


#endif //GENERATOR_PAYLOADGENERATOR_H
