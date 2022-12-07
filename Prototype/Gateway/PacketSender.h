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
using namespace std;


#define FIFO_FILE "./tmp/fifo_pipe_gen"
#define protocol 0x88b5
typedef unsigned char* Payload;
const int MAX_PROCESSES = 20;
const int BUFFER_SIZE = 128;
const char* DEFAULT_IF_NAME = "enp34s0";


class PacketSender {
private:
    queue<Payload> payloads[MAX_PROCESSES];
    int fd[MAX_PROCESSES];
    unsigned char buffer[BUFFER_SIZE];

public:
    PacketSender();
    void openPipes();
    void closePipes();
    void checkPipes();
    void roundRubin();
    bool sendToSwitch(Payload& payload);
};


#endif //GP_PACKETSENDER_H
