//
// Created by khaled on 11/29/22.
//

#include "PacketSender.h"
#include <fcntl.h>
#include <sys/stat.h>
#include <csignal>

PacketSender::PacketSender() {}

PacketSender* PacketSender::getInstance(int genID, std::string pipeDir, std::string pipePerm)
{
    if(instance  == nullptr)
    {
        instance = new PacketSender();
        instance->pipeDir = pipeDir;
        instance->permissions = pipePerm;
        instance->genID = genID;
        instance->openFifo();
    }
    else
        return instance;
}

int PacketSender::openFifo()
{
    //create pipe with read and write permissions
    mkfifo((instance->pipeDir + std::to_string(instance->genID)).c_str(), S_IFIFO | 0640);
    //open pipe as file
    fd = open((instance->pipeDir + std::to_string(instance->genID)).c_str(), O_WRONLY);
}

void PacketSender::transmitPackets(ByteArray& packet) const
{
    write(fd, packet.bytes,packet.length);
}
