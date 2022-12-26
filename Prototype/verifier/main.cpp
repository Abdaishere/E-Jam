#include <iostream>
#include <queue>
#include <thread>
#include "src/PacketUnpacker.h"
#include "src/ConfigurationManager.h"
#include "src/StatsManager.h"

using namespace std;

void receive(PacketUnpacker* pu)
{
    int iters = 1000;
    while(iters--)
    {
        pu->readPacket();
    }
}

void verify(PacketUnpacker* pu)
{
    int iters = 1000;
    while(iters--)
    {
        pu->verifiyPacket();
    }
}

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

    return 0;
}