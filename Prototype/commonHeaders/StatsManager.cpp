#include <cstdio>
#include "StatsManager.h"

//initialize the unique instance
std::shared_ptr<StatsManager> StatsManager::instance;


//handle unique instance
std::shared_ptr<StatsManager> StatsManager::getInstance(int verID, bool is_gen, Configuration* conf)
{
    if (instance == nullptr)
    {
        instance.reset(new StatsManager(verID, is_gen, conf));
    }
    return instance;
}


StatsManager::StatsManager(int id, bool is_gen1, Configuration* conf)
{
    is_gen = is_gen1;
    instanceID = id;
	configuration = conf;
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
	char delimiter = ' ';
	std::string msg = "";

	if (is_gen) //Working as a generator
	{
		//Process type ( 0 for generator , 1 for verifier )
		msg += "0";
		msg += delimiter;

		//Target mac
		//Stream ID
		if (!configuration)
		{
			msg += "00000000";
			msg += delimiter;
			msg += "xxx";
		}
		else
		{
			msg += byteArray_to_string(configuration->getReceivers()[0]);
			msg += delimiter;
			msg += byteArray_to_string(*configuration->getStreamID());
		}
		msg += delimiter;

		//sent Packets
		msg += std::to_string(sentPckts);
		msg += delimiter;

		//sent errored packets
		msg += std::to_string(sentErrorPckts);
	}
	else	//Working as a verifier
	{
		//Process type ( 0 for generator , 1 for verifier )
		msg += "1";
		msg += delimiter;

		//Source mac
		//Stream ID
		if (!configuration)
		{
			msg += "00000000";
			msg += delimiter;
			msg += "xxx";
		}
		else
		{
			msg += byteArray_to_string(configuration->getMyMacAddress());
			msg += delimiter;
			msg += byteArray_to_string(*configuration->getStreamID());
		}
		msg += delimiter;

		//Correctly Received Packets
		msg += std::to_string(receivedCorrectPckts);
		msg += delimiter;

		//Errornos packets
		msg += std::to_string(receivedWrongPckts);
		msg += delimiter;

		//Packets dropped
		msg += std::to_string(droppedPckts);
		msg += delimiter;

		//Packets received out of order
		msg += std::to_string(receivedWrongPckts);
	}

	//TODO prepare a named pipe and write msg
}
