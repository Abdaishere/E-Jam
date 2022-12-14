//
// Created by mohamedelhagry on 12/13/22.
//

#ifndef VERIFIER_PACKETRECEIVER_H
#define VERIFIER_PACKETRECEIVER_H

#include <string>
#include "Byte.h"

class PacketReceiver {
private:
    static PacketReceiver* instance;
    std::string pipeDir;
    int permissions;
    int fd;
    int verID;
    PacketReceiver();
    ~PacketReceiver();
    int openFifo();
    void closePipe();
public:

    static PacketReceiver* getInstance(int genID = 0, std::string pipeDir="", int pipePerm = 0777);
    void receivePackets(ByteArray* packet);
};


#endif //VERIFIER_PACKETRECEIVER_H
