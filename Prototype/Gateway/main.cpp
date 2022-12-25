#include "PacketSender.h"
#include "PacketReceiver.h"
#include <iostream>
#include <thread>
using namespace std;
// functions used in the sender part of the gateway
void checkingThread(PacketSender* packetSender)
{
    while (true)
        packetSender->checkPipes();
}

void sendingThread(PacketSender* packetSender)
{
    while (true)
        packetSender->roundRobin();
}

//functions used in receiving part of the gateway
void receivingThread(PacketReceiver* packetReceiver)
{
    packetReceiver->receiveFromSwitch();
}

void checkingThreadV(PacketReceiver* packetReceiver)
{
    packetReceiver->checkBuffer();
}

int main(int argc, char ** argv)
{
    //sender or receiver
    int mode;
    // num of either generators or verifiers
    int num = 1;
    if(argc > 1)
        mode = stoi(argv[1]);
    if(argc > 2)
        num = stoi(argv[2]);

    //generator
    if(mode == 0)
    {
        auto* packetSender = new PacketSender(num);
        packetSender->openPipes();

        thread checker(checkingThread, packetSender);
        thread sender(sendingThread, packetSender);

        checker.join();
        sender.join();

        packetSender->closePipes();
        return 0;
    }
    //verifier
    else
    {
        PacketReceiver* packetReceiver = new PacketReceiver(num);

        while(true)
        {
            std::thread t1 (receivingThread, packetReceiver);
            std::thread t2 (checkingThreadV, packetReceiver);

            t1.join();
            t2.join();

            packetReceiver->swapBuffers();
        }
    }


}
