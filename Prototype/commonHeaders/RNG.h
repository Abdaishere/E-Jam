#ifndef GENERATOR_RNG_H
#define GENERATOR_RNG_H
#include <random>
#include <xoshiro512+.cpp>
//masks used to genetare a random number
const unsigned long long masks[] = {255,
                                    65280,
                                    16711680,
                                    4278190080,
                                    1095216660480,
                                    280375465082880,
                                    71776119061217280,
                                    18374686479671623680ull};
class RNG {
private:
    int index;
    unsigned long long currRandomNumber;
    int seed;
    //random device
    XOSHIRO_PRNG rng;
public:
    RNG(int seed = 0) //set the initial seed by defult to zero
    {
        index = 8;
        this->seed = seed;
        setSeed(seed);
    }

    unsigned long long getR()
    {
        return currRandomNumber;
    }

    void setSeed (u_int64_t seed)
    {
        this->seed = seed;
        rng.setSeed(seed);
    }

    void jump(){
    }

    void long_jump(){
    }

    unsigned char gen()
    {
        if(index == 8)
        {
            currRandomNumber = rng.next();
            index = 0;
        }

        //taking the byte i'm currently interested in and shifting it left until its the first byte
        unsigned char val = ((currRandomNumber & masks[index]) >> (index << 3));
        index++;
        return val;
    }
};

#endif //GENERATOR_RNG_H
