//
// Created by mohamedelhagry on 12/13/22.
//

#include "PacketReceiver.h"
#include <fcntl.h>
#include <sys/stat.h>
#include <csignal>
#include <error.h>
#include <iostream>
#include <unistd.h>
PacketReceiver* PacketReceiver::instance = nullptr;
PacketReceiver::PacketReceiver() {}

PacketReceiver* PacketReceiver::getInstance(int genID, std::string pipeDir, int pipePerm)
{
    if(instance  == nullptr)
    {
        instance = new PacketReceiver();
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
            printf("Error in creating the FIFO file\n");
        } else {
            printf("File already exists, skipping creation...\n");
        }
    }

    //open pipe as file
    fd = open((instance->pipeDir).c_str(), O_RDONLY);
    std::cerr << "File descriptor "<< fd << "\n";
    return fd;
}

void PacketReceiver::closePipe() {
    close(fd);
}

void PacketReceiver::receivePackets(ByteArray* packet)
{
    int packetSize; read(fd, &packetSize,4);
    unsigned char* cstr = new unsigned char[packetSize];
    int received = read(fd, cstr, packetSize);
    packet = new ByteArray(packetSize, 'a');
    memcpy(packet, cstr, sizeof(cstr));
    std::cerr << "packet reached receiver " << received << " \n";
//    for(int i=0; i<packet->length; i++)
//        std::cerr<<(int)packet->at(i) << " ";
//    std::cerr << "\n";
}

PacketReceiver::~PacketReceiver() {
    closePipe();
}


