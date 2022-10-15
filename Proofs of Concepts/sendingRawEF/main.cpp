#include <iostream>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <linux/if_packet.h>
#include <net/if.h>
#include <net/ethernet.h>
#include <cstring>
#include <netinet/in.h>

#define DEFAULT_IF_NAME "enp34s0"
#define BUFF_LEN 81
#define frameLength 118
#define protocol 0x88b5
struct EthernetFrame{
    char destAdd[6];
    char sourceAdd[6];
    char etherType[2];
    char payload[100];
    char CRC[4];
};

int main(int argn, char** argv) {
    //experimental use etherTypes 0x88B5 and 0x88B6
    int etherType = 0x88B5;


    //open socket
    int sock = socket(AF_PACKET, SOCK_RAW, protocol);
    if(sock == -1) {
        std::cout << "unable to open socket\n";
        return -1;
    }

    //get interface index
    //using netDevice - low-level access to Linux network devices
    struct ifreq ifr;
    size_t if_name_len = strlen(DEFAULT_IF_NAME);
    if(if_name_len < sizeof(ifr.ifr_name)){
        memcpy(ifr.ifr_name, DEFAULT_IF_NAME, if_name_len);
        ifr.ifr_name[if_name_len] = 0;
    }
    else
    {
        std::cout << "interface name too long\n";
        return -1;
    }
    if(ioctl(sock,SIOCGIFINDEX,&ifr) == -1)
    {
        std::cout << "could not get open ethernet interface\n";
        return -1;
    }
    int ifIndex = ifr.ifr_ifindex;


    //construct destination address
    const unsigned char ether_broadcast_addr[]=
            {0xff,0xff,0xff,0xff,0xff,0xff};

    struct sockaddr_ll addr={0};
    addr.sll_family=AF_PACKET;
    addr.sll_ifindex=ifIndex;
    addr.sll_halen=ETHER_ADDR_LEN;
    addr.sll_protocol=htons(htons(protocol));
    memcpy(addr.sll_addr,ether_broadcast_addr,ETHER_ADDR_LEN);


    //construct the ethernet frame
    EthernetFrame frame;
    for(int i=0; i<6; i++)frame.sourceAdd[i] = 'x';
    for(int i=0; i<6; i++)frame.destAdd[i] = (char)0xff;
    frame.etherType[0] = (char)0x88;frame.etherType[1] = (char)0xB5;
    for(int i=0; i<100; i++) frame.payload[i] = (char)('a' + (i % 255));
    frame.payload[0]  =frame.payload[1]  = frame.payload[2]  = 'z';
    for(int i=0; i<4; i++)frame.CRC[i] = 'x';

//    char req[] = {'a','a','a','a','a','a','a','a','a','a','a','a','a',
//                  'a','a','a','a','a','a','a','a','a','a','a','a',
//                  'a','a','a','a','a','a','a','a','a','a','a','a',
//                  'a','a','a','a','a','a','a','a','a','a','a','a',
//                  'a','a','a','a','a','a','a','a','a','a','a','a',
//                  'a','a','a','a','a','a','a','a','a','a','a','a',
//                  'a','a','a','a','a','a','a','a','a','a','a','a'};
//    char* req = new char[BUFF_LEN];
//    for(int i=0; i<BUFF_LEN; i++)
//        req[i] = 'a';


    //send the request
    // ssize_t sendto(int sockfd, const void *buf, size_t len, int flags,
    //                      const struct sockaddr *dest_addr, socklen_t addrlen);
    if (sendto(sock,&frame,sizeof(frame),0,(struct sockaddr*)&addr,sizeof(addr))==-1) {
        std::cout << "couldn't send frame\n";
        return -1;
    }
}
