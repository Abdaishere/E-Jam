#include "Utils.h"
#include "PacketSender.h"
#include <fcntl.h>
#include <sys/stat.h>
#include <iostream>
#include <queue>
#include <unistd.h>
#include <fstream>


std::shared_ptr<PacketSender> PacketSender::instance = nullptr;
PacketSender::PacketSender() {}

std::shared_ptr<PacketSender> PacketSender::getInstance(int genID, std::string pipeDir, int pipePerm)
{
    if(instance  == nullptr)
    {
        instance.reset(new PacketSender());
        instance->pipeDir = pipeDir;
        instance->permissions = pipePerm;
        instance->genID = genID;
        instance->openFifo();
        return instance;
    }
    return instance;
}

void PacketSender::openFifo()
{
    writeToFile("Entered openFifo.");
    //create pipe with read and write permissions
    int status = mkfifo((instance->pipeDir + std::to_string(instance->genID)).c_str(), permissions);
    writeToFile("Created pipe.");
    if(status == -1) {
        if (errno != EEXIST) //if the error was more than the file already existing
        {
            writeToFile("Error in creating the FIFO file\n");
        } else {
            writeToFile("File already exists, skipping creation...\n");
        }
    }

    //open pipe as file
    fd = open((instance->pipeDir + std::to_string(instance->genID)).c_str(), O_WRONLY);
    writeToFile("File descriptor " + std::to_string(fd) + "\n");
}

void PacketSender::transmitPackets(const ByteArray& packet) const
{
    int len = packet.size();
    write(fd, &len,4);
    write(fd, packet.c_str(), len);
}
