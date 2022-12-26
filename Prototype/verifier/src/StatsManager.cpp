//
// Created by khaled on 12/26/22.
//

#include <cstdio>
#include "StatsManager.h"


StatsManager* StatsManager::instance;

StatsManager *StatsManager::getInstance(int verID)
{
    if (instance == nullptr)
        instance = new StatsManager(verID);
    return instance;
}


StatsManager::StatsManager(int verID)
{
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
    dir += "/Ver_";
    dir += std::to_string(verID);
    dir += ".txt";

    FILE* file = fopen(dir.c_str(),"w");
    std::string line = std::to_string(numberOfPackets) + '\n' + std::to_string(numberOfErrors);
    fwrite(line.c_str(), sizeof(char), line.length()*sizeof(char), file);
    fclose(file);
}
