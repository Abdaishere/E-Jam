#ifndef GENERATOR_RNG_H
#define GENERATOR_RNG_H
#include <random>
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
    std::mt19937_64 rng; //random device
public:
    RNG(int seed = 0) //set the initial seed by defult to zero
    {
        index = 8;
        this->seed = seed;
        rng.seed(seed);
    }

    unsigned long long getR()
    {
        return currRandomNumber;
    }

    void setSeed (int s)
    {
        rng.seed(s);
    }

    unsigned char gen()
    {
        if(index == 8)
        {
            currRandomNumber = rng();
            index = 0;
        }

        //taking the byte i'm currently interested in and shifting it left until its the first byte
        unsigned char val = ((currRandomNumber & masks[index]) >> (index << 3));
        index++;
        return val;
    }
};

#endif //GENERATOR_RNG_H
