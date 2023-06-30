#include "PacketSender.h"

// potential improvement : use a double buffer for transmission, similar approach to the verifier
PacketSender::PacketSender(int genNum, const char *IF_NAME_P) {
    this->genNum = genNum;
    ::memcpy(this->IF_NAME, IF_NAME_P, IF_NAMESIZE);
    fd = new int[genNum];
    packets = std::vector<queue<ByteArray>>(genNum);
    //opening socket
    sock = socket(AF_PACKET, SOCK_RAW, protocol);
    if (sock == -1) {
        std::cerr << "unable to open socket\n";
        return;
    }

    // get interface index
    // using netDevice - low-level access to Linux network devices
    size_t if_name_len = strlen(IF_NAME);
    if (if_name_len < sizeof(ifr.ifr_name)) {
        memcpy(ifr.ifr_name, IF_NAME, if_name_len);
        ifr.ifr_name[if_name_len] = 0;
    } else
        writeToFile("interface name too long\n");

    if (ioctl(sock, SIOCGIFINDEX, &ifr) == -1)
        writeToFile("could not get open ethernet interface\n");

    ifIndex = ifr.ifr_ifindex;

    addr = {0};
    addr.sll_family = AF_PACKET;
    addr.sll_ifindex = ifIndex;
    addr.sll_halen = ETHER_ADDR_LEN;
    addr.sll_protocol = htons(htons(protocol));
}

void PacketSender::openPipes() {
    for (int i = 0; i < genNum; i++) {
        mkfifo((FIFO_FILE + std::to_string(i)).c_str(), S_IFIFO | 0640);
        fd[i] = open((FIFO_FILE + std::to_string(i)).c_str(), O_RDWR);
    }
}

void PacketSender::closePipes() {
    for (int i = 0; i < genNum; i++)
        close(fd[i]);
}

void PacketSender::checkPipes() {
    for (int i = 0; i < genNum; i++) {
        int len;
        read(fd[i], &len, 4);
        int bytesRead = read(fd[i], buffer, len);
        while (bytesRead != 0) {
            packets[i].push(ByteArray(buffer, bytesRead));
            read(fd[i], &len, 4);
            bytesRead = read(fd[i], buffer, len);
        }
    }
}

void PacketSender::roundRobin() {
    //TODO: remove hard-coded time and replace it with test duration + some constant
    auto endTest = std::chrono::system_clock::now() + 5min;
    do {
        for (int i = 0; i < genNum && std::chrono::system_clock::now() < endTest; i++) {
            //busy waiting until we receive packet for this generator
            while (packets[i].empty() && std::chrono::system_clock::now() < endTest);
            if (!packets[i].empty()) {
                sendToSwitch(packets[i].front());
                packets[i].pop();
            }
        }
    } while (std::chrono::system_clock::now() < endTest);
}

bool PacketSender::sendToSwitch(const ByteArray& packet) {
    // send the request
    // ssize_t sendto(int sockfd, const void *buf, size_t len, int flags,
    //                const struct sockaddr *dest_addr, socklen_t addrlen);

    //construct the correct ethernet address
    memcpy(addr.sll_addr, &(packet[0]), ETHER_ADDR_LEN);
    writeToFile(byteArray_to_string(addr.sll_addr));
    if (sendto(sock, packet.c_str(), packet.size(), 0, (struct sockaddr *) &addr, sizeof(addr)) == -1) {
        writeToFile("couldn't send frame " + to_string(errno) + "\n");
        return false;
    }
    return true;
}

PacketSender::~PacketSender() {
    closePipes();
    delete[] fd;
}
