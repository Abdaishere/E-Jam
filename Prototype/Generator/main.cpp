#include "PacketCreator.h"
#include <iostream>
#include <thread>
#include<unistd.h>

void sendingFunction(PacketCreator* pc)
{
    while(true)
        pc->sendHead();
}
void creatingFunction(PacketCreator* pc)
{
    while(true)
        pc->createPacket();
}

int main()
{

    PacketCreator* pc = new PacketCreator();


    std::thread creator(creatingFunction,pc);
    std::thread sender(sendingFunction,pc);
//    std::thread sender();


    creator.join();
    sender.join();

}

