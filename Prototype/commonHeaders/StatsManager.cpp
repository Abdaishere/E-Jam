#include <cstdio>
#include "StatsManager.h"

//initialize the unique instance
std::shared_ptr<StatsManager> StatsManager::instance;


//handle unique instance
std::shared_ptr<StatsManager> StatsManager::getInstance(int verID, bool is_gen)
{
    if (instance == nullptr)
    {
        instance.reset(new StatsManager(verID, is_gen));
    }
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
    timer = clock(); //start time of stats 
}

void StatsManager::sendStats()
{
    clock_t now = clock(); //end time of stats
    clock_t delta_t = (now - timer) / CLOCKS_PER_SEC; //delta: total time to do stats
    if((double) delta_t > SEND_DELAY )
    {
        writeStatFile();
        resetStats(false); //to reset variables
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
    std::string dir = STAT_DIR;
    if(is_gen)
        dir += "/Gen_";
    else
        dir += "/Ver_";
    dir += std::to_string(instanceID);
    dir += ".txt";

    FILE* file = fopen(dir.c_str(),"w");
    std::string line = std::to_string(numberOfPackets) + '\n' + std::to_string(numberOfErrors) + '\n';
    fwrite(line.c_str(), sizeof(char), line.length()*sizeof(char), file);
    fclose(file);
}
