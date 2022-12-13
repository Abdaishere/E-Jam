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

//   main in case of sender
/*
int main(int argc, char ** argv)
{
    auto* packetSender = new PacketSender();
    packetSender->openPipes();

    thread checker(checkingThread, packetSender);
    thread sender(sendingThread, packetSender);

    checker.join();
    sender.join();

    packetSender->closePipes();
    return 0;

}
*/


int main(int argc, char ** argv)
{

    PacketReceiver* packetReceiver = new PacketReceiver;

    while(true)
    {
        std::thread t1 (receivingThread, packetReceiver);
        std::thread t2 (checkingThreadV, packetReceiver);

        t1.join();
        t2.join();

        packetReceiver->swapBuffers();
    }

}
