#include "PacketReceiver.h"

PacketReceiver::PacketReceiver(int verNum)
{
    //initialize maximum number of verifiers and initialize the connection to pipes
    MAX_VERS = verNum;
    fd = new int[verNum];
    recBuffer = new unsigned char[BUFFER_SIZE_VER];
    forwardingBuffer = new unsigned char[BUFFER_SIZE_VER];
    recSizes = new int[BUFFER_SIZE_VER];
    forwardingSizes = new int[BUFFER_SIZE_VER];
    received = toForward = 0;
    openPipes();
    initializeSwitchConnection();
}

//open pipe for each verifier
void PacketReceiver::openPipes()
{
//    string ver = FIFO_FILE + "ver";
    for(int i=0; i<MAX_VERS; i++)
    {
        mkfifo((FIFO_FILE_VER + std::to_string(i)).c_str()  , S_IFIFO | 0640);
        fd[i] = open((FIFO_FILE_VER + std::to_string(i)).c_str(), O_RDWR);
    }
}

bool PacketReceiver::initializeSwitchConnection()
{

    strcpy(ifName, DEFAULT_IF);
    struct ifreq ifopts;

    //open socket
    sock = socket(AF_PACKET, SOCK_RAW, htons(ETHER_TYPE));
    if (sock == -1)
    {
        std::cerr << "unable to open socket\n";
        return false;
    }

    /* Set interface to promiscuous mode,
       i.e. read everything even if the destination
       mac address doesn't match your address
       we might not need to do this*/
    strncpy(ifopts.ifr_name, ifName, IFNAMSIZ-1);
    //get interface flags
    ioctl(sock, SIOCGIFFLAGS, &ifopts);
    //turn on promiscuous mode mask
    ifopts.ifr_flags |= IFF_PROMISC;
    //set interface flags
    ioctl(sock, SIOCSIFFLAGS, &ifopts);
//    Bind this socket to a specific switch to read from, other packets are dropped
//    if (setsockopt(sock, SOL_SOCKET, SO_BINDTODEVICE, ifName, IFNAMSIZ-1) == -1)	{
//        perror("SO_BINDTODEVICE");
//        close(sock);
//        exit(EXIT_FAILURE);
//    }
    return true;
}


//closing the pipes
void PacketReceiver::closePipes()
{
    for(int i=0; i<MAX_VERS; i++)
        close(fd[i]);
}


//synchronization without locks by swapping the buffers
void PacketReceiver::swapBuffers()
{
    swap(recBuffer, forwardingBuffer);
    swap(recSizes, forwardingSizes);
    toForward = received;
}

//send forward buffer to its corresponding verifier
void PacketReceiver::checkBuffer()
{
    int verID;
    int totSizeFor = 0;
    for(int ptr=0; ptr < toForward; ptr++)
    {
        //extract the streamID
        ByteArray streamID;
        streamID.assign(forwardingBuffer[totSizeFor + STREAM_ID_OFFSET], STREAMID_LEN);
        verID = ConfigurationManager::getStreamIndex(streamID);
        if(verID == -1)
        {
            std::cerr << "Couldn't find suitable stream\n";
            verID = 0;
        }
        sendToVerifier(verID, forwardingBuffer+totSizeFor, forwardingSizes[ptr]);
        totSizeFor += forwardingSizes[ptr];
    }
}

//receive packets from switch in recBuffer
void PacketReceiver::receiveFromSwitch()
{
    received = 0;
    int totSizeRec = 0;
    int sizeLeft = BUFFER_SIZE_VER;
    int cnt = 0;
    while(sizeLeft >= MTU)
    {
        int bytesRead = recvfrom(sock, recBuffer+totSizeRec, MTU, 0, nullptr, nullptr);
        std::cerr<<bytesRead << " ";
        cnt++;
        if (bytesRead == -1)
        {
            std::cerr << "not received\n";
            return;
        }

        sizeLeft -= bytesRead;
        totSizeRec += bytesRead;
        recSizes[received++] = bytesRead;
    }

    std::cerr << cnt << " packets received\n";
}

//send payload to single verifier used in checkBuffer to send to all verifiers
void PacketReceiver::sendToVerifier(int verID, Payload payload, int len)
{
    //converting int to char
    write(fd[verID], &len, sizeof(int));
    //assuming the pipe speed is faster than the  network speed
    write(fd[verID], payload, len);
}

PacketReceiver::~PacketReceiver()
{
    closePipes();
}