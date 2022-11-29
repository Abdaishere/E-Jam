//
// Created by khaled on 11/29/22.
//

#ifndef GENERATOR_PACKETSENDER_H
#define GENERATOR_PACKETSENDER_H

/**
 * This class is responsible for communicating with the gateway
 */
class PacketSender
{
private:
    static PacketSender* instance;
    char* pipeDir;
    char* permissions;

    PacketSender();
    char* getNewPacket();
    int openFifo();
public:
    static PacketSender* getInstance();
    void transmitPackets();
};


#endif //GENERATOR_PACKETSENDER_H
