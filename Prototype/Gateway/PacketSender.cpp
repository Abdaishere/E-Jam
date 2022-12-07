#include "PacketSender.h"

PacketSender::PacketSender() {}

void PacketSender::openPipes()
{
    for (int i = 0; i < MAX_PROCESSES; i++)
    {
        mkfifo((FIFO_FILE + std::to_string(i)).c_str(), S_IFIFO | 0640);
        fd[i] = open((FIFO_FILE + std::to_string(i)).c_str(), O_RDWR);
    }
}

void PacketSender::closePipes()
{
    for (int i = 0; i < MAX_PROCESSES; i++)
        close(fd[i]);
}

void PacketSender::checkPipes()
{
    for (int i = 0; i < MAX_PROCESSES; i++)
    {
        while (read(fd[i], buffer, sizeof(buffer)) != 0)
        {
            payloads[i].push(buffer);
            memset(&buffer, 0, sizeof buffer); // clear the buffer
        }
    }
}

void PacketSender::roundRubin()
{
    auto endTest = std::chrono::system_clock::now(); + 5min;
    do {
        for (int i = 0; i < MAX_PROCESSES && std::chrono::system_clock::now() < endTest; i++)
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

bool PacketSender::sendToSwitch(Payload& payload)
{
    // open socket
    int sock = socket(AF_PACKET, SOCK_RAW, protocol);
    if (sock == -1)
    {
        std::cout << "unable to open socket\n";
        return false;
    }

    // get interface index
    // using netDevice - low-level access to Linux network devices
    struct ifreq ifr;
    size_t if_name_len = strlen(DEFAULT_IF_NAME);
    if (if_name_len < sizeof(ifr.ifr_name))
    {
        memcpy(ifr.ifr_name, DEFAULT_IF_NAME, if_name_len);
        ifr.ifr_name[if_name_len] = 0;
    }
    else
    {
        std::cout << "interface name too long\n";
        return false;
    }
    if (ioctl(sock,SIOCGIFINDEX,&ifr) == -1)
    {
        std::cout << "could not get open ethernet interface\n";
        return false;
    }
    int ifIndex = ifr.ifr_ifindex;


    //construct destination address
    const unsigned char ether_broadcast_addr[]=
            {0xff,0xff,0xff,0xff,0xff,0xff};

    struct sockaddr_ll addr = {0};
    addr.sll_family = AF_PACKET;
    addr.sll_ifindex = ifIndex;
    addr.sll_halen = ETHER_ADDR_LEN;
    addr.sll_protocol = htons(htons(protocol));
    memcpy(addr.sll_addr,ether_broadcast_addr,ETHER_ADDR_LEN);

    // send the request
    // ssize_t sendto(int sockfd, const void *buf, size_t len, int flags,
    //                const struct sockaddr *dest_addr, socklen_t addrlen);
    if (sendto(sock, &payload, sizeof(payload), 0, (struct sockaddr*)&addr, sizeof(addr)) == -1)
    {
        std::cout << "couldn't send frame\n";
        return false;
    }
    return true;
}
