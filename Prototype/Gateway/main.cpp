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

void checkingThread(PacketReceiver* packetReceiver)
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
        receivingThread(packetReceiver);
        checkingThread(packetReceiver);
        packetReceiver->swapBuffers();

        printf("gere");
    }

}
