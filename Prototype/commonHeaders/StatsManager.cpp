//
// Created by khaled on 12/26/22.
//

#include <cstdio>
#include "StatsManager.h"


StatsManager* StatsManager::instance;

StatsManager *StatsManager::getInstance(int verID, bool is_gen)
{
    if (instance == nullptr)
        instance = new StatsManager(verID, is_gen);
    return instance;
}


StatsManager::StatsManager(int id, bool is_gen1)
{
    is_gen = is_gen1;
    instanceID = id;
    resetStats(false);
}

void StatsManager::resetStats(bool send)
{
    numberOfPackets = 0;
    numberOfErrors = 0;
    timer = clock();
}

void StatsManager::sendStats()
{
    clock_t now = clock();
    clock_t delta_t = (now - timer) / CLOCKS_PER_SEC;
    if((double) delta_t > SEND_DELAY )
    {
        writeStatFile();
        resetStats(false);
    }
}


void StatsManager::increaseNumPackets(long val)
{
    numberOfPackets += val;
}

void StatsManager::increaseNumErrors(long val)
{
    numberOfErrors += val;
}

void StatsManager::writeStatFile()
{
    std::string dir = CONFIG_DIR;
    if(is_gen)
        dir += "/Ver_";
    else
        dir += "/Gen_";
    dir += std::to_string(instanceID);
    dir += ".txt";

    FILE* file = fopen(dir.c_str(),"w");
    std::string line = std::to_string(numberOfPackets) + '\n' + std::to_string(numberOfErrors);
    fwrite(line.c_str(), sizeof(char), line.length()*sizeof(char), file);
    fclose(file);
}
