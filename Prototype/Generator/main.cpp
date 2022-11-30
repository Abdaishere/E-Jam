#include "PacketCreator.h"
#include<unistd.h>

int main()
{
    PacketCreator* pc = PacketCreator::getInstance();

    int pid = fork();

    if (pid==0)
    {
        pc->createPacket();
    }
    else
    {
        pc->sendHead();
    }

    //TODO (Obviously, there is a segmentation fault)
}
