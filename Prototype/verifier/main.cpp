#include <iostream>
#include <queue>
#include <thread>
#include "src/PacketUnpacker.h"
#include "src/ConfigurationManager.h"

using namespace std;

void receive(PacketUnpacker* pu)
{
    while(true)
    {
        pu->readPacket();
    }
}

void verify(PacketUnpacker* pu)
{
    while(true)
    {
        pu->verifiyPacket();
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
    ConfigurationManager::initConfigurations();

    PacketUnpacker* pu = new PacketUnpacker(verID);


    std::thread reader(receive, pu);
    std::thread verifier(verify, pu);

    reader.join();
    verifier.join();


    return 0;
}
