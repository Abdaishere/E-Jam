#include <iostream>
#include <queue>
#include <thread>
#include "src/PacketUnpacker.h"
#include "src/ConfigurationManager.h"
#include "StatsManager.h"

using namespace std;

//thread function for receiving packets
void receive(PacketUnpacker* pu)
{
//    int iters = 1000;
    while(true)
    {
        pu->readPacket();
    }
}

//thread function to verifiy received packets
void verify(PacketUnpacker* pu)
{
//    int iters = 100000000;
    while(true)
    {
        pu->verifiyPacket();
    }
}

//thread function to send stats
void sendStats(StatsManager* sm)
{
    while (true)
    {
        sm->sendStats();
    }
}

int main(int argc, char** argv)
{
    int verID = 0;
    if (argc > 1)
    {
        verID = std::stoi(argv[1]);
        printf("%d\n", verID);
    }
    StatsManager* sm = StatsManager::getInstance(verID);
    ConfigurationManager::initConfigurations();

    PacketUnpacker* pu = new PacketUnpacker(verID);

    std::thread reader(receive, pu);
    std::thread verifier(verify, pu);
    std::thread statWriter(sendStats, sm);

    reader.join();
    verifier.join();
    statWriter.join();

    return 0;
}