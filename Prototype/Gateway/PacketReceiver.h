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
#include <pthread.h>
#include "Byte.h"
#include "ConfigurationManager.h"
using namespace std;
//constants
#define BUFF_LEN 1600
#define ETHER_TYPE 0x88b5
#define FIFO_FILE_VER "/tmp/fifo_pipe_ver" 
#define STREAM_ID_OFFSET 14

typedef unsigned char* Payload;
const int BUFFER_SIZE_VER = 2000;
const int MTU = 1600;

//this module receives packets from the switch and sends them to the verifiers
class PacketReceiver {
private:
    //array which holds pipe file descriptors for each pipe
    int* fd;
    int sock;
    int MAX_VERS;
    char IF_NAME[IF_NAMESIZE];
    //double buffer for storing / consuming the actual packets
    unsigned char* recBuffer;
    unsigned char* forwardingBuffer;
    //double buffer to store the sizes read from the pipe, one for reading from the switch, and another for writing to the pipes
    int* recSizes;
    int* forwardingSizes;
    //
    int received;

    int toForward;
public:
    PacketReceiver(int, const char* IF_NAME);
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
