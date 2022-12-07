//
// Created by khaled on 11/29/22.
//

#ifndef GENERATOR_PACKETSENDER_H
#define GENERATOR_PACKETSENDER_H

#include <string>
#include "Byte.h"

/**
 * This class is responsible for communicating with the gateway
 */
class PacketSender
{
private:
    static PacketSender* instance;
    std::string pipeDir;
    std::string permissions;
    //file descriptor for pipe
    int fd;
    int genID;
    PacketSender();
//    std::string getNewPacket();
    int openFifo();
public:
    static PacketSender* getInstance(int genID = 0, std::string pipeDir = "", std::string pipePerm = "");
    void transmitPackets(ByteArray &packet) const;
};


#endif //GENERATOR_PACKETSENDER_H
