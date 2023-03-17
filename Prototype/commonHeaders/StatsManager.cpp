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
    resetStats();
}

void StatsManager::resetStats()
{
	receivedCorrectPckts = 0;
	receivedWrongPckts = 0;
	receivedOutOfOrderPckts = 0;
	droppedPckts = 0;

	sentPckts = 0;
	sentErrorPckts = 0;

    timer = clock(); //start time of stats 
}

void StatsManager::sendStats()
{
    clock_t now = clock(); //end time of stats
    clock_t delta_t = (now - timer) / CLOCKS_PER_SEC; //delta: total time to do stats
    if((double) delta_t > SEND_DELAY )
    {
        writeStatFile();
        resetStats(); //to reset variables
    }
}


void StatsManager::increaseReceivedCorrectPckts(int val = 1)
{
	receivedCorrectPckts+=val;
}
void StatsManager::increaseReceivedWrongPckts(int val = 1)
{
	receivedWrongPckts+=val;
}
void StatsManager::increaseReceivedOutOfOrderPckts(int val = 1)
{
	//TODO when to call?
	receivedOutOfOrderPckts+=val;
}
void StatsManager::increaseDroppedPckts(int val = 1)
{
	//TODO when to call?
	droppedPckts+=val;
}

void StatsManager::increaseSentPckts(int val = 1)
{
	sentPckts+=val;
}
void StatsManager::increaseSentErrorPckts(int val = 1)
{
	sentErrorPckts+=val;
}

void StatsManager::writeStatFile()
{
	//TODO write in memory

	/*
	 if(isGen)
	 {
	 	write(targetMac (WHAT)?)
	 	write(configManager.getConfig.streamID)
	 	write(sentpackets)
	 	write(sentWrongpackets)
	 }

	 */


	/*
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
    fclose(file); */
}
