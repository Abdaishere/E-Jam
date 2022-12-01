//
// Created by khaled on 11/29/22.
//

#ifndef GENERATOR_PACKETSENDER_H
#define GENERATOR_PACKETSENDER_H

#include <string>

/**
 * This class is responsible for communicating with the gateway
 */
class PacketSender
{
private:
    static PacketSender* instance;
    std::string pipeDir;
    std::string permissions;

    PacketSender();
    std::string getNewPacket();
    int openFifo();
public:
    static PacketSender* getInstance();
    void transmitPackets();
};


#endif //GENERATOR_PACKETSENDER_H
