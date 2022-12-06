#include <iostream>
#include <queue>
#include <thread>
#include "src/PacketUnpacker.h"
#include "src/ConfigurationManager.h"

using namespace std;

void read(PacketUnpacker* pu)
{
    int times = 400;
    while(times)
    {
        pu->readPacket();
    }
}

void verify(PacketUnpacker* pu)
{
    int times = 200;
    while(times)
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


    return 0;

}
