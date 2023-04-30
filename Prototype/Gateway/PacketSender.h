#ifndef GP_PACKETSENDER_H
#define GP_PACKETSENDER_H

#include <iostream>
#include <queue>
#include <cstring>
#include <fcntl.h>
#include <unistd.h>
#include <chrono>
#include <sys/stat.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <linux/if_packet.h>
#include <net/ethernet.h>
#include <net/if.h>
#include <netinet/in.h>
#include "Byte.h"
using namespace std;


#define FIFO_FILE "/tmp/fifo_pipe_gen"
#define protocol 0x88b5

typedef unsigned char* Payload;
const int BUFFER_SIZE = 1600;

//this module receives packets from generators and sends them the switch
class PacketSender {
private:
    int genNum;
    std::vector<queue<ByteArray>> payloads;
    int* fd;
    char IF_NAME[IF_NAMESIZE];
    unsigned char buffer[BUFFER_SIZE];
    const char* DEFAULT_IF_NAME = "wlp0s20f3";
    int sock;
    struct ifreq ifr;
    int ifIndex;
    struct sockaddr_ll addr;
public:
    PacketSender(int genNum, const char* IF_NAME = nullptr);
    void openPipes();
    void closePipes();
    void checkPipes();
    void roundRobin();
    bool sendToSwitch(ByteArray payload);
    ~PacketSender();
};


#endif //GP_PACKETSENDER_H
