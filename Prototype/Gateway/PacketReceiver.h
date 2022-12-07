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

#define BUFF_LEN 118
#define ETHER_TYPE 0x88b5
#define DEFAULT_IF "enp34s0"
#define FIFO_FILE "./tmp/fifo_pipe_ver"
typedef unsigned char* Payload;
const int BUFFER_SIZE = 128;


class PacketReceiver {
private:
    queue<Payload> payloads;
    int fd;
    unsigned char buffer[BUFFER_SIZE];

public:
    PacketReceiver();
    void openPipe();
    void closePipe();
    bool receiveFromSwitch();
    void sendToVerifier(Payload& payload);
};


#endif //GP_PACKETRECEIVER_H
