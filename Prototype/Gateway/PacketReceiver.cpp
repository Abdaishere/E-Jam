#include "PacketReceiver.h"

PacketReceiver::PacketReceiver() {}

void PacketReceiver::openPipe()
{
    mkfifo(FIFO_FILE, S_IFIFO | 0640);
    fd = open(FIFO_FILE, O_RDWR);
}

void PacketReceiver::closePipe()
{
    close(fd);
}

bool PacketReceiver::receiveFromSwitch()
{
    char ifName[IF_NAMESIZE];
    strcpy(ifName, DEFAULT_IF);
    struct ifreq ifopts;

    //open socket
    int sock = socket(AF_PACKET, SOCK_RAW, htons(ETHER_TYPE));
    if (sock == -1)
    {
        std::cout << "unable to open socket\n";
        return false;
    }

    //setting timeout for the socket
    struct timeval read_timeout;
    read_timeout.tv_sec = 5;
    read_timeout.tv_usec = 10;
    setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, &read_timeout, sizeof read_timeout);


    /* Set interface to promiscuous mode - do we need to do this every time? */
    strncpy(ifopts.ifr_name, ifName, IFNAMSIZ-1);
    ioctl(sock, SIOCGIFFLAGS, &ifopts);
    ifopts.ifr_flags |= IFF_PROMISC;
    ioctl(sock, SIOCSIFFLAGS, &ifopts);

//    // Bind to device
//    if (setsockopt(sock, SOL_SOCKET, SO_BINDTODEVICE, ifName, IFNAMSIZ-1) == -1)	{
//        perror("SO_BINDTODEVICE");
//        close(sock);
//        exit(EXIT_FAILURE);
//    }

    // construct the receiving buffer
    char* buff = new char[BUFF_LEN];
    for (int i = 0; i < BUFF_LEN; i++)
        buff[i] = 'x';

    // receive the request
    // ssize_t recvfrom(int sockfd, void *restrict buf, size_t len, int flags,
    //                  struct sockaddr *restrict src_addr, socklen_t *restrict addrlen)

    int success = -1;
    int cntr = 3;
    while (cntr--)
    {
        success = recvfrom(sock, buff, BUFF_LEN, 0, nullptr, nullptr);
        if (success == -1)
        {
            std::cout << "not received\n";
            continue;
        }
        std::cout << "finally received\n";
        for (int i = 0; i < BUFF_LEN; i++)
            std::cout << buff[i];
        std::cout << "\n";
    }
    return true;
}

void PacketReceiver::sendToVerifier(Payload& payload)
{
    memset(&buffer, 0, sizeof buffer); // clear the buffer
    strcpy(reinterpret_cast<char *>(buffer), reinterpret_cast<const char *>(payload));
    write(fd, buffer, strlen(reinterpret_cast<const char *>(buffer)));
}