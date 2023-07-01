#ifndef GENERATOR_RNG_H
#define GENERATOR_RNG_H
#include <random>
#include "xoshiro512+.cpp"
//masks used to genetare a random number
const unsigned long long masks[] = {255ull,
                                    65280ull,
                                    16711680ull,
                                    4278190080ull,
                                    1095216660480ull,
                                    280375465082880ull,
                                    71776119061217280ull,
                                    18374686479671623680ull};
const int preComputeSize = 1e4;
const int defaultShift = 5e3;

class RNG {
private:
    int index;
    int startPacketNumber;
    u_int64_t currRandomNumber;
    u_int64_t seed[8];
    //contains the starting seeds of the next preComputeSize packets
    uint64_t seedTable[preComputeSize][8];
    //random device
    XOSHIRO_PRNG rng;
public:
    RNG() //set the initial seed to zero
    {
        index = 8;
        memset(seed, 0, sizeof seed);
        rng.setSeed(seed);
    }

    uint64_t getR(){
        return currRandomNumber;
    }

    //return 0 if the packetNumber is in the range of the table, -1 is before, 1 if after range
    int inTable(int packetNumber){
        if(packetNumber < startPacketNumber) return -1;
        if(startPacketNumber + preComputeSize - 1 < packetNumber) return 1;
        return 0;
    }

    //set the start seed corresponding to this packet Number
    bool goTo(int packetNumber){
        if(inTable(packetNumber) < 0) return false;
        while(inTable(packetNumber) != 0)
            shiftTable();
        setSeed(seedTable[packetNumber - startPacketNumber]);
        return true;
    }

    void setSeed (u_int64_t* otherSeed){
        index = 8;
        memcpy(seed, otherSeed, sizeof seed);
        rng.setSeed(seed);
    }

    void setSeed(uint64_t singleSeed){
        index = 8;
        uint64_t tempSeed[8];
        memset(tempSeed, 0, sizeof tempSeed);
        tempSeed[0] = singleSeed;
        setSeed((uint64_t*)tempSeed);
    }

    void jump(){
        index = 8;
        rng.jump();
    }

    void long_jump(){
        index = 8;
        rng.long_jump();
    }

    void shiftTable(int shiftVal = defaultShift){
        uint64_t* start = new uint64_t[8];
        memcpy(start, seedTable[shiftVal],8 * sizeof(start[0]));
        fillTable( startPacketNumber + shiftVal, start);
        delete[] start;
    }

    void fillTable(int startNumber){
        fillTable(startNumber, seed);
    }

    //fill sparse table starting from the start value
    void fillTable(int startNumber, uint64_t* start){
        index = 8;
        startPacketNumber = startNumber;

        memcpy(seedTable[0], start, 8 * sizeof start[0]);
        for (int i = 1; i < preComputeSize; ++i)
            rng.jump(seedTable[i], seedTable[i-1]);
    }

    unsigned char gen(){
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
