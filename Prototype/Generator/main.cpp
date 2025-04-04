#include "PacketCreator.h"
#include "ConfigurationManager.h"
#include <iostream>
#include <thread>
#include <string>
#include <time.h>
#include <chrono>
#include <fstream>
#include "StatsManager.h"
#include "ConfigurationManager.h"

//#define FIFO_FILE "/home/mohamedelhagry/Desktop/ahmed"
#define FIFO_FILE "/tmp/fifo_pipe_gen"
typedef unsigned long long ull;
//TODO naming style and coding style 
//TODO standarize the units

//thread function to send the packets
/// \param deprecated Should be deprecated because of the more specific controlled sending functions below
void sendingFunction(std::shared_ptr<PacketCreator> pc)
{
    while(true)
            pc->sendHead();
}

///Different modes of sending are:
/// time based, burst
/// time based back-to-back
/// content based burst
/// content based back-to-back


/// \param duration time of sending in milliseconds (10^-3) seconds
/// \details send a packets back to back for a certain duration
void sendTimeBasedB2B(std::shared_ptr<PacketCreator> pc, ull duration, ull IFG = 0)
{
    using namespace std::chrono;

    if(duration <= 0) return;
    time_point<steady_clock> beginTime = steady_clock::now();
    time_point<steady_clock> endTime = steady_clock::now();
    while (duration_cast<milliseconds>(endTime- beginTime).count() <= duration)
    {
        pc->sendHead();
        endTime = steady_clock::now();
        std::this_thread::sleep_for(milliseconds(IFG));
    }
}

/// \param duration time of sending in milliseconds (10^-3) seconds
/// \param delay time between bursts in milliseconds (10^-3) seconds
/// \param burstSize number of packets per burst
/// \details bursts of length burstSize with inter-burst gap delay for a certain duration
void sendTimeBasedBurst(std::shared_ptr<PacketCreator> pc, ull duration, ull delay, int burstSize, ull IFG = 0)
{
    using namespace std::chrono;
    if(duration <= 0) return;
    time_point<steady_clock> beginTime = steady_clock::now();
    time_point<steady_clock> endTime = steady_clock::now();

    while (duration_cast<milliseconds>(endTime- beginTime).count() <= duration)
    {
        int remaining = burstSize;
        while(remaining--){
            pc->sendHead();
            std::this_thread::sleep_for(milliseconds(IFG));
        }

        //duration between bursts
        std::this_thread::sleep_for(milliseconds(delay));
        endTime = steady_clock::now();
    }
}

/// \details send a specified number of packets back to back
void sendB2B(std::shared_ptr<PacketCreator> pc, int packetsToSend, ull IFG = 0)
{
    using namespace std::chrono;
    if(packetsToSend <= 0) return; 
    while(packetsToSend--)
    {
        pc->sendHead();
        std::this_thread::sleep_for(milliseconds(IFG));
    }
}


/// \param delay in milliseconds
/// \details send a specified number of packets in bursts of size burstSize
void sendBurst(std::shared_ptr<PacketCreator> pc, int packetsToSend, ull delay, int burstSize, ull IFG = 0)
{
    using namespace std::chrono;
    if(packetsToSend <= 0) return;

    while(packetsToSend > 0)
    {
        int rem = std::min(burstSize, packetsToSend);
        packetsToSend -= rem;
        while(rem--)
        {
            pc->sendHead();
            std::this_thread::sleep_for(milliseconds(IFG));
        }

        std::this_thread::sleep_for(milliseconds(delay));
    }
}


/// \param number of packets to create
/// \param gap in milliseconds is the gap between individual packets
/// \details create packets with delay so that memory doesn't get too full when rate of consumption is low
//thread function to send packets
void createNumBased(std::shared_ptr<PacketCreator> pc, ull number, Configuration currConfig,  ull gap = 0)
{
    using namespace std::chrono;
    while(number--)
    {
        int lenRcv = currConfig.getReceivers().size();
        for(int rcvInd=0; rcvInd < lenRcv; rcvInd++)
            pc->createPacket(rcvInd);

        if(gap > 0)
            std::this_thread::sleep_for(milliseconds(gap));
    }
}

/// \param duration time of sending in milliseconds (10^-3) seconds
void createTimeBased (std::shared_ptr<PacketCreator> pc, ull duration, Configuration currConfig,  ull gap = 0)
{
    using namespace std::chrono;
    time_point<steady_clock> beginTime = steady_clock::now();
    time_point<steady_clock> endTime = steady_clock::now();

    int lengthReceived = currConfig.getReceivers().size();
    while (duration_cast<milliseconds>(endTime- beginTime).count() <= duration)
    {
        for(int receiveIndex=0; receiveIndex < lengthReceived; receiveIndex++)
            pc->createPacket(receiveIndex);

        std::this_thread::sleep_for(milliseconds(gap));
        endTime = steady_clock::now();
    }
}

//thread function to send the stats
void sendStatsFunction(std::shared_ptr<StatsManager> sm)
{
    writeToFile("Start of the thread.");
    while (true)
        sm->sendStats();
}

int main(int argc, char** argv)
{
    int genID = 0;
    char *configPath;
    if (argc > 2)
    {
        genID = std::stoi(argv[1]);
        configPath = argv[2];
    }else
    {
        std::cout<<"Missing Arguments\n";
        return 0;
    }


    Configuration currConfig = ConfigurationManager::getConfiguration(configPath);
    ////setting up the initial state of the RNG
    int global_id = currConfig.getID(currConfig.getMyMacAddress());

    std::shared_ptr<StatsManager> sm = StatsManager::getInstance(currConfig, genID, true);
    PacketSender::getInstance(genID, FIFO_FILE, 0777);
    std::shared_ptr<PacketCreator> pc = std::make_shared<PacketCreator>(currConfig, global_id);
    /// send according to one of the above threads using flowtype and sending mode
    /// sending mode is inferred from the numOfPackets and flowTime parameters in the stream configuration



    std::thread creator, sender;
    writeToFile(std::to_string(sm == nullptr));
    std::thread statWriter(sendStatsFunction, sm);
    ull gap = currConfig.getInterFrameGap();
    FlowType flowType = currConfig.getFlowType();
    ull packetNumber = currConfig.getNumberOfPackets();
    currConfig.print();
    if(packetNumber > 0)
    {
        creator = std::thread(createNumBased, pc, packetNumber, currConfig,gap);
        ull burstDelay = currConfig.getBurstDelay();
        ull burstSize = currConfig.getBurstLength();
        if(flowType == BURSTY)
            sender = std::thread(sendBurst, pc, packetNumber, burstDelay, burstSize,gap);
        else
            sender = std::thread(sendB2B, pc, packetNumber, gap);
    }
    else
    {
        ull sendTime = currConfig.getLifeTime();
        ull burstDelay = currConfig.getBurstDelay();
        ull burstLength = currConfig.getBurstLength();
        creator = std::thread(createTimeBased, pc, sendTime, currConfig, gap);
        if(flowType == BURSTY)
            sender = std::thread(sendTimeBasedBurst, pc, sendTime, burstDelay,burstLength,gap);
        else
            sender = std::thread(sendTimeBasedB2B, pc, sendTime, gap);
    }
    creator.join();
    sender.join();
    statWriter.join();
}

