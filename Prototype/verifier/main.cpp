#include <iostream>
#include <queue>
#include <thread>
#include "src/PacketUnpacker.h"
#include "src/ConfigurationManager.h"
#include "../commonHeaders/StatsManager.h"

using namespace std;

//thread function for receiving packets
void receive(std::shared_ptr<PacketUnpacker> pu)
{
//    int iters = 1000;
    while(true)
    {
        pu->readPacket();
    }
}

//thread function to verifiy received packets
void verify(std::shared_ptr<PacketUnpacker> pu)
{
//    int iters = 100000000;
    while(true)
    {
        pu->verifiyPacket();
    }
}

//thread function to send stats
void sendStats(std::shared_ptr<StatsManager> sm)
{
    while (true)
    {
        sm->sendStats();
    }
}

int main(int argc, char** argv)
{
    int verID = 0;
    char *configPath;
    if (argc > 2)
    {
        verID = std::stoi(argv[1]);
        configPath = argv[2];
        printf("%d\n", verID);
    }
    else
    {
        printf("Missing Arguments\n");
        return 0;
    }

//    ConfigurationManager::getConfiguration(configPath);
    std::shared_ptr<Configuration> currConfig = ConfigurationManager::getConfiguration();
    std::shared_ptr<StatsManager> sm = StatsManager::getInstance(verID);
    ConfigurationManager::initConfigurations();

    std::shared_ptr<PacketUnpacker> pu = std::make_shared<PacketUnpacker>(verID);

    std::thread reader(receive, pu);
    std::thread verifier(verify, pu);
    std::thread statWriter(sendStats, sm);

    reader.join();
    verifier.join();
    statWriter.join();

    return 0;
}