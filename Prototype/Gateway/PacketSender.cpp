#include "PacketSender.h"
// potential improvement : use a double buffer for transmission, similar approach to the verifier
PacketSender::PacketSender(int genNum) {
    this->genNum = genNum;
    fd = new int[genNum];
    payloads = std::vector<queue<ByteArray>>(genNum);
    //opening socket
    sock = socket(AF_PACKET, SOCK_RAW, protocol);
    if (sock == -1)
    {
        std::cerr << "unable to open socket\n";
        return;
    }

    // get interface index
    // using netDevice - low-level access to Linux network devices
    size_t if_name_len = strlen(DEFAULT_IF_NAME);
    if (if_name_len < sizeof(ifr.ifr_name))
    {
        memcpy(ifr.ifr_name, DEFAULT_IF_NAME, if_name_len);
        ifr.ifr_name[if_name_len] = 0;
    }
    else
        std::cerr << "interface name too long\n";

    if (ioctl(sock,SIOCGIFINDEX,&ifr) == -1)
        std::cerr << "could not get open ethernet interface\n";

    ifIndex = ifr.ifr_ifindex;

    //construct destination address
    const unsigned char ether_broadcast_addr[]=
            {0xff,0xff,0xff,0xff,0xff,0xff};

    addr = {0};
    addr.sll_family = AF_PACKET;
    addr.sll_ifindex = ifIndex;
    addr.sll_halen = ETHER_ADDR_LEN;
    addr.sll_protocol = htons(htons(protocol));
    memcpy(addr.sll_addr,ether_broadcast_addr,ETHER_ADDR_LEN);
}

void PacketSender::openPipes()
{
    for (int i = 0; i < genNum; i++)
    {
        mkfifo((FIFO_FILE + std::to_string(i)).c_str(), S_IFIFO | 0640);
        fd[i] = open((FIFO_FILE + std::to_string(i)).c_str(), O_RDWR);
        cout << fd[i] << endl;
    }
}

void PacketSender::closePipes()
{
    for (int i = 0; i < genNum; i++)
        close(fd[i]);
}

void PacketSender::checkPipes()
{
    for (int i = 0; i < genNum; i++)
    {
        int len;
        read(fd[i], &len, 4);
        int bytesRead = read(fd[i], buffer, len);
        while (bytesRead != 0)
        {
            payloads[i].push(ByteArray(buffer, bytesRead));
            read(fd[i], &len, 4);
            bytesRead = read(fd[i], buffer, len);
        }
    }
}

void PacketSender::roundRobin()
{
    auto endTest = std::chrono::system_clock::now() + 5min;
    do {
        for (int i = 0; i < genNum && std::chrono::system_clock::now() < endTest; i++)
        {
            while (payloads[i].empty() && std::chrono::system_clock::now() < endTest);
            if (!payloads[i].empty())
            {
                sendToSwitch(payloads[i].front());
                payloads[i].pop();
            }
        }
    } while (std::chrono::system_clock::now() < endTest);
}

bool PacketSender::sendToSwitch(ByteArray payload)
{
    std::cerr << payload.size() << "\n";
//    for(int i=0; i<payload.size();i++)
//        cerr << (int)payload.at(i)<< " ";
//    cerr <<"\n";
    // send the request
    // ssize_t sendto(int sockfd, const void *buf, size_t len, int flags,
    //                const struct sockaddr *dest_addr, socklen_t addrlen);
    if (sendto(sock, payload.c_str(), payload.size(), 0, (struct sockaddr*)&addr, sizeof(addr)) == -1)
    {
        cerr << "couldn't send frame " << errno << "\n";
        return false;
    }
    cerr << "sent frame\n";
    return true;
}

PacketSender::~PacketSender() {
    closePipes();
}
