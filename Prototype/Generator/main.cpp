#include "PacketCreator.h"
#include "ConfigurationManager.h"
#include <iostream>
#include <thread>
#include <string>
#include "StatsManager.h"

//#define FIFO_FILE "/home/mohamedelhagry/Desktop/ahmed"
#define FIFO_FILE "/tmp/fifo_pipe_gen"

void sendingFunction(PacketCreator* pc)
{
    //TODO if possible, add timeout
    while(true)
            pc->sendHead();
}
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

