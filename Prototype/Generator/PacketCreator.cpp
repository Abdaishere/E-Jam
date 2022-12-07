//
// Created by khaled on 11/27/22.
//

#include "PacketCreator.h"
#include "ConfigurationManager.h"
#include <iostream>
#include <sys/stat.h>
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>

std::queue<ByteArray> PacketCreator::productQueue;
std::mutex PacketCreator::mtx;

void PacketCreator::createPacket(int rcvInd)
{
    ByteArray sourceAddress = ConfigurationManager::getConfiguration()->getMyMacAddress();
    ByteArray destinationAddress = ConfigurationManager::getConfiguration()->getReceivers()[rcvInd];

    PayloadGenerator* payloadGenerator = PayloadGenerator::getInstance();
    payloadGenerator->regeneratePayload();
    ByteArray payload = payloadGenerator->getPayload();
    ByteArray innerProtocol = ByteArray("00",2);
    FrameConstructor* frameConstructor = new EthernetConstructor(sourceAddress, destinationAddress,
                                                                 payload,
                                                                 innerProtocol);
    frameConstructor->constructFrame();

    mtx.lock();
    productQueue.push(frameConstructor->getFrame());
    mtx.unlock();
}



void PacketCreator::sendHead()
{
    if(productQueue.size()<1)
    {
        return;
    }
    mtx.lock();
    ByteArray packet = productQueue.front();
    productQueue.pop();
    mtx.unlock();

    sendToGateway(packet);
}

void PacketCreator::sendToGateway(const ByteArray& packet)
{
    //making the FIFO with 777 permissions
    if(mkfifo("./gen",0777)==-1)
    {
        if(errno != EEXIST) //if the error was more than the file already existing
        {
            printf("Error in creating the FIFO file\n");
            return;
        }
        else
        {
            printf("File already exists, skipping creation...\n");
        }
    }
    //open the fifo as write only and get the file descriptor (blocking by default)
    int fd = open("myfifo1", O_WRONLY);

    write(fd,packet.bytes,packet.length);
    //close(fd); //No need to close because the stream is always on (NOT TESTED) //TODO
}
