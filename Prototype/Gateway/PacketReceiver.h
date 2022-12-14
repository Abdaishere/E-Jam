#ifndef GP_PACKETRECEIVER_H
#define GP_PACKETRECEIVER_H

#include <iostream>
#include <queue>
#include <cstring>
#include <sys/stat.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <linux/if_packet.h>
#include <net/if.h>
#include <net/ethernet.h>
#include <netinet/in.h>
#include <fcntl.h>
#include <unistd.h>
#include <csignal>
using namespace std;

#define BUFF_LEN 1600
#define ETHER_TYPE 0x88b5
#define DEFAULT_IF "enp34s0"
#define FIFO_FILE_VER "./tmp/fifo_pipe_ver"
typedef unsigned char* Payload;
const int BUFFER_SIZE_VER = 100000;
const int MTU = 1600;

//this module receives packets from the switch and sends them to the verifiers
class PacketReceiver {
private:
    //indices of verifiers in
    queue<pair<int,int>> payloads;
    int* fd;
    int sock;
    int MAX_VERS;

    //double buffer to store the next packet size for when
    unsigned char* recBuffer;
    unsigned char* forwardingBuffer;
    //double buffer, one for reading from the switch, and another for writing to the pipes
    int* recSizes;
    int* forwardingSizes;
    //
    int received;
    int toForward;

    char ifName[IF_NAMESIZE];
public:
    PacketReceiver(int);
    void openPipes();
    void closePipes();
    bool initializeSwitchConnection();
    void swapBuffers();
    void checkBuffer();
    void receiveFromSwitch();
    void sendToVerifier(int verID, Payload payload, int len);
    ~PacketReceiver();
};


#endif //GP_PACKETRECEIVER_H
