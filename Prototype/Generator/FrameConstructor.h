//
// Created by khaled on 11/27/22.
//

#ifndef GENERATOR_FRAMECONSTRUCTOR_H
#define GENERATOR_FRAMECONSTRUCTOR_H


class FrameConstructor
{
protected:
    unsigned char* frame;
    unsigned char destination_address[6]; //Destination MAC address
    unsigned char source_address[6];      //Source MAC address
public:
    FrameConstructor(unsigned char* source_address, unsigned char* destination_address){
        for(int i=0; i<6; i++)
            this->source_address[i] = source_address[i];
        for(int i=0; i<6; i++)
            this->destination_address[i] = destination_address[i];
    };
    virtual void constructFrame() = 0;
    unsigned char* getFrame();
};


#endif //GENERATOR_FRAMECONSTRUCTOR_H
