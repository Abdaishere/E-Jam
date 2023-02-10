#include "PacketCreator.h"
#include "ConfigurationManager.h"
#include <iostream>
#include <thread>
#include <string>
#include <time.h>
#include "StatsManager.h"

//#define FIFO_FILE "/home/mohamedelhagry/Desktop/ahmed"
#define FIFO_FILE "/tmp/fifo_pipe_gen"

//TODO naming style and coding style 
//TODO standarize the units

//thread function to send the packets
void sendingFunction(PacketCreator* pc)
{
    while(true)
            pc->sendHead();
}


//sending for specific time 
void sendingTimeBasedPackets(PacketCreator* pc, int seconds)
{
    if(seconds <= 0) return;
    time_t beginTime = time(NULL);
    time_t endTime = time(NULL);
    while ((endTime - beginTime) <= seconds)
    {
        pc->sendHead();
        endTime = time(NULL);
    }
}

//sending N packets
void sendingNPackets(PacketCreator* pc, int packetsToSend)
{
    if(packetsToSend <= 0) return; 
    while(packetsToSend--)
    {
        pc->sendHead();
    }
}

//thread function to send packets
void creatingFunction(PacketCreator* pc)
{
    unsigned long long numberOfPackets = ConfigurationManager::getConfiguration()->getNumberOfPackets();

    while(numberOfPackets--)
    {
        int lenRcv = ConfigurationManager::getConfiguration()->getReceivers().size();
        for(int rcvInd=0; rcvInd < lenRcv; rcvInd++)
        {
            pc->createPacket(rcvInd);
        }
    }
}

//thread function to send the stats
void sendStatsFunction(StatsManager* sm)
{
    while (true)
        sm->sendStats();
}

int main(int argc, char** argv)
{
    int genID = 0;
    char *configPath;
    if (argc > 2)
    {
        genID = std::stoi(argv[1]);
        configPath = argv[2];
    }
    
    ConfigurationManager::getConfiguration(configPath);
    StatsManager* sm = StatsManager::getInstance(genID, true);
    PacketSender::getInstance(genID, FIFO_FILE, 0777);

    PacketCreator* pc = new PacketCreator();
    std::thread creator(creatingFunction,pc);
    std::thread sender(sendingFunction,pc);
    std::thread statWriter(sendStatsFunction, sm);


    creator.join();
    sender.join();
    statWriter.join();
}

