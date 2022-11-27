//
// Created by khaled on 11/27/22.
//

#ifndef GENERATOR_FRAMECONSTRUCTOR_H
#define GENERATOR_FRAMECONSTRUCTOR_H


class FrameConstructor
{
private:
    int protocol;
    char* frame;
public:
    FrameConstructor(int protocol, const char* resultingString, int innerProtocol){};
    void constructDatagram();
};


#endif //GENERATOR_FRAMECONSTRUCTOR_H
