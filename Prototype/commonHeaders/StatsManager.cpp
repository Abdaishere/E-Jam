#include <cstdio>
#include "StatsManager.h"
#include <iostream>
#include <fstream>
#include <thread>
#include "Utils.h"

//initialize the unique instance
std::shared_ptr<StatsManager> StatsManager::instance;


//handle unique instance
std::shared_ptr<StatsManager> StatsManager::getInstance(const Configuration& config, int verID, bool is_gen)
{
    if (instance == nullptr)
    {
        instance.reset(new StatsManager(config, verID, is_gen));
    }
    return instance;
}
std::shared_ptr<StatsManager> StatsManager::getInstance()
{
	return instance;
}

StatsManager::StatsManager(const Configuration& config, int id, bool is_gen1)
{
    is_gen = is_gen1;
    instanceID = id;
	configuration = config;
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


    timer = std::chrono::steady_clock::now();
}

void StatsManager::sendStats()
{
    auto now = std::chrono::steady_clock::now();
    if (now - timer > std::chrono::seconds(SEND_DELAY))
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

void StatsManager::buildMsg(std::string& msg)
{
	char delimiter = ' ';
	if (is_gen) //Working as a generator
	{
		//Target mac
		//Stream ID
		if (configuration.isSet())
		{
			msg += "00000000";
			msg += delimiter;
			msg += "xxx";
		}
		else
		{
			msg += byteArray_to_string(configuration.getReceivers()[0]);
			msg += delimiter;
			msg += byteArray_to_string(*configuration.getStreamID());
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
		//Source mac
		//Stream ID
		if (configuration.isSet())
		{
			//fallback to identifity I can't reach the gen_id
			msg += "00000000";
			msg += delimiter;
			msg += "xxx"; 
		}else
		{
			msg += byteArray_to_string(configuration.getMyMacAddress());
			msg += delimiter;
			msg += byteArray_to_string(*configuration.getStreamID());
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
		msg += std::to_string(receivedOutOfOrderPckts);
	}
}

void StatsManager::writeStatFile()
{
	//build the msg
	std::string msg;
	buildMsg(msg);
    //open pipe
	std::string dir = STAT_DIR;
	if(is_gen)
	{
		dir += "/genStats/sgen_";
	}
	else
	{
		dir += "/verStats/sver_";
	}

 	mkfifo((dir + std::to_string(instanceID)).c_str(), S_IFIFO | 0640);
    fd = open((dir+ std::to_string(instanceID)).c_str(), O_RDWR);

    if(fd == -1)
	{
        if (errno != EEXIST) //if the error was more than the file already existing
        {
            writeToFile("Error in creating the FIFO file sgen_id");
            printf("Error in creating the FIFO file sgen_id\n");
            return;
        } else {
            writeToFile("File already exists sgen_id, skipping creation...");
            printf("File already exists sgen_id, skipping creation...\n");
        }
    }

    writeToFile("before writing to pipe.");
	//Write on pipe
    writeToFile("message is: " + msg);
    std::cerr << "message is: " + msg << "\n";
	write(fd, msg.c_str(), sizeof(char)*msg.size());
    close(fd);
    writeToFile("after writing to pipe.");
}

