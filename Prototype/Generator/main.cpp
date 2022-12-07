#include "PacketCreator.h"
#include "ConfigurationManager.h"
#include <iostream>
#include <thread>

void sendingFunction(PacketCreator* pc)
{
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

int main()
{
    //TODO (Obviously, there is a segmentation fault)

    PacketCreator* pc = new PacketCreator();


    std::thread creator(creatingFunction,pc);
    std::thread sender(sendingFunction,pc);


    creator.join();
    sender.join();

}

