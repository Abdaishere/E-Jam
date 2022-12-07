#ifndef GP_PACKETSENDER_H
#define GP_PACKETSENDER_H

#include <iostream>
#include <queue>
using namespace std;

#define FIFO_FILE "/tmp/fifo_pipe"
typedef unsigned char* Payload;
const int MAX_PROCESSES = 20;
const int BUFFER_SIZE = 128;

class PacketSender {
private:
    queue<Payload> payloads[MAX_PROCESSES];
    int fd[MAX_PROCESSES];
    unsigned char buffer[BUFFER_SIZE];

public:
    PacketSender();
    void openPipes();
    void closePipes();
    void receivePayload(Payload payload, int process);
    vector<Payload> roundRubin();
    void sendToSwitch();
};


#endif //GP_PACKETSENDER_H
