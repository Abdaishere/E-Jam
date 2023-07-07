//
// Created by mohamedelhagry on 12/13/22.
//

#include "PacketReceiver.h"
#include <fcntl.h>
#include <sys/stat.h>
#include <csignal>
#include <error.h>
#include <iostream>
std::shared_ptr<PacketReceiver> PacketReceiver::instance = nullptr;
PacketReceiver::PacketReceiver() {}
#include "../../commonHeaders/Utils.h"
std::shared_ptr<PacketReceiver> PacketReceiver::getInstance(int genID, std::string pipeDir, int pipePerm)
{
    if(instance  == nullptr)
    {
        instance.reset(new PacketReceiver());
        instance->pipeDir = pipeDir;
        instance->permissions = pipePerm;
        instance->verID = genID;
        instance->openFifo();
    }

    return instance;
}


int PacketReceiver::openFifo()
{
    //create pipe with read and write permissions

    int status = mkfifo((instance->pipeDir).c_str(), permissions);

    if(status == -1) {
        if (errno != EEXIST) //if the error was more than the file already existing
        {
            writeToFile("Error in creating the FIFO file\n");
        } else {
            writeToFile("File already exists, skipping creation...\n");
        }
    }
    writeToFile("opening file as pipe\n");
    //open pipe as file
    fd = open((instance->pipeDir).c_str(), O_RDONLY);
    writeToFile("returning  from open fifo function\n");
    std::cerr << "File descriptor "<< fd << "\n";
    return fd;
}

void PacketReceiver::closePipe() {
    close(fd);
}

//fix:must make the smart pointer passed by reference as it is lost when only copied
void PacketReceiver::receivePackets(std::shared_ptr<ByteArray>& packet)
{
    int packetSize; read(fd, &packetSize,4);
    unsigned char* cstr = new unsigned char[packetSize]; //why we do not delete it ??
    read(fd, cstr, packetSize);
    packet = std::make_shared<ByteArray>(packetSize, 'a');
    for(int i=0;i<packetSize;i++)
        packet->at(i) = cstr[i];

//    memcpy(packet, cstr, sizeof(cstr));
    delete[] cstr;
}

PacketReceiver::~PacketReceiver() {
    closePipe();
}


