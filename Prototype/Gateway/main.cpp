#include "PacketSender.h"
#include <iostream>
#include <thread>
using namespace std;

void checkingThread(PacketSender* packetSender)
{
    while (true)
        packetSender->checkPipes();
}

void sendingThread(PacketSender* packetSender)
{
    while (true)
        packetSender->roundRubin();
}

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
