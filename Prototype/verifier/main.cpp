#include <iostream>
#include <queue>
#include <thread>
#include "src/PacketUnpacker.h"
#include "src/ConfigurationManager.h"

using namespace std;

void read(PacketUnpacker* pu)
{
    int times = 400;
    while(times--)
    {
        pu->readPacket();
    }
}

void verify(PacketUnpacker* pu)
{
    int times = 200;
    while(times--)
    {
        pu->verifiyPacket();
    }
}

int main(){



    PacketUnpacker* pu = new PacketUnpacker;


    std::thread reader(read, pu);
    std::thread verifier(verify, pu);

    reader.join();
    verifier.join();


/*
    for(int i=0;i<ConfigurationManager::getConfiguration()->getSenders().size();i++)
    {
        std::cout<<"data\n";
    }

    std::cout<<ConfigurationManager::getConfiguration()->getMyMacAddress().bytes<<std::endl;
    std::cout<<ConfigurationManager::getConfiguration()->getMyMacAddress().length;
    //std::cout<<ConfigurationManager::getConfiguration()->getMyMacAddress()*/
    return 0;

}
