//
// Created by khaled on 11/27/22.
//

#ifndef GENERATOR_FRAMECONSTRUCTOR_H
#define GENERATOR_FRAMECONSTRUCTOR_H


#include <string>

class FrameConstructor
{
protected:
    std::string frame;
    std::string destination_address; //Destination MAC address
    std::string source_address;      //Source MAC address
public:
    FrameConstructor(std::string source_address, std::string destination_address){
        this->source_address = source_address;
        this->destination_address = destination_address;
    };
    virtual void constructFrame() = 0;
    std::string getFrame();
};


#endif //GENERATOR_FRAMECONSTRUCTOR_H
