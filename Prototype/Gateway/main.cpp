#include "PacketSender.h"
#include "PacketReceiver.h"
#include <iostream>
#include <thread>
#include <memory>
using namespace std;
// functions used in the sender part of the gateway
void checkingThread(std::shared_ptr<PacketSender> packetSender)
{
    while (true)
        packetSender->checkPipes(); //check the buffe to read payloads 
}

void sendingThread(std::shared_ptr<PacketSender> packetSender)
{
    while (true)
        packetSender->roundRobin(); //round robin technique to send to switch
}

//functions used in receiving part of the gateway
void receivingThread(std::shared_ptr<PacketReceiver> packetReceiver)
{
    packetReceiver->receiveFromSwitch();
}

void checkingThreadV(std::shared_ptr<PacketReceiver> packetReceiver)
{
    packetReceiver->checkBuffer(); //checking the buffer then send to verifiers
}

int main(int argc, char ** argv)
{
    //sender or receiver mode
    int mode;
    // num of either generators or verifiers
    int num = 1;
    if(argc > 1)
        mode = stoi(argv[1]);
    if(argc > 2)
        num = stoi(argv[2]);

    //if mode == 0 then it's a generator otherwise it's a verifier
    //generator
    if(mode == 0)
    {
        std::shared_ptr<PacketSender> packetSender = std::make_shared<PacketSender>(num);
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
        std::shared_ptr<PacketReceiver> packetReceiver = std::make_shared<PacketReceiver>(num);

        while(true)
        {
            //synchronization without locks by swapping the two buffers

            std::thread t1 (receivingThread, packetReceiver); 
            std::thread t2 (checkingThreadV, packetReceiver);

            t1.join();
            t2.join();

            packetReceiver->swapBuffers();
        }
    }


}
