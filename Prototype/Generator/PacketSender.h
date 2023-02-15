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
    int permissions;
    //file descriptor for pipe
    int fd;
    int genID;
    PacketSender();
//    std::string getNewPacket();
    void openFifo();
public:
    static PacketSender* getInstance(int genID = 0, std::string pipeDir = "", int pipePerm = 0777);
    void transmitPackets(const ByteArray &packet) const;
    //TODO Close fifo after joining threads
};


#endif //GENERATOR_PACKETSENDER_H
