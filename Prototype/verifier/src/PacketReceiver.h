//
// Created by mohamedelhagry on 12/13/22.
//

#ifndef VERIFIER_PACKETRECEIVER_H
#define VERIFIER_PACKETRECEIVER_H

#include <string>
#include <string.h>
#include <memory>
#include "../commonHeaders/Byte.h"

class PacketReceiver {
private:
    static std::shared_ptr<PacketReceiver> instance;
    std::string pipeDir;
    int permissions;
    int fd;
    int verID;
    PacketReceiver();
    int openFifo();
    void closePipe();
public:
    ~PacketReceiver();
    static std::shared_ptr<PacketReceiver> getInstance(int genID = 0, std::string pipeDir="", int pipePerm = 0777);
    void receivePackets(std::shared_ptr<ByteArray> packet);
};


#endif //VERIFIER_PACKETRECEIVER_H
