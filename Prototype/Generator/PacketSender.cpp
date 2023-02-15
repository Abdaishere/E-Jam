//
// Created by khaled on 11/29/22.
//

#include "PacketSender.h"
#include <fcntl.h>
#include <sys/stat.h>
#include <csignal>
#include <error.h>
PacketSender* PacketSender::instance = nullptr;
PacketSender::PacketSender() {}

PacketSender* PacketSender::getInstance(int genID, std::string pipeDir, int pipePerm)
{
    if(instance  == nullptr)
    {
        instance = new PacketSender();
        instance->pipeDir = pipeDir;
        instance->permissions = pipePerm;
        instance->genID = genID;
        instance->openFifo();
        return instance;
    }
    else
        return instance;
}
#include <iostream>

void PacketSender::openFifo()
{
    //create pipe with read and write permissions
    int status = mkfifo((instance->pipeDir + std::to_string(instance->genID)).c_str(), permissions);

    if(status == -1) {
        if (errno != EEXIST) //if the error was more than the file already existing
        {
            printf("Error in creating the FIFO file\n");
        } else {
            printf("File already exists, skipping creation...\n");
        }
    }

    //open pipe as file
    fd = open((instance->pipeDir + std::to_string(instance->genID)).c_str(), O_WRONLY);
    std::cerr << "File descriptor " << fd << "\n";
}

void PacketSender::transmitPackets(const ByteArray& packet) const
{
    write(fd, packet.bytes,packet.length);
}
