//
// Created by khaled on 11/27/22.
//
#ifndef CONFIGURATION_H
#define CONFIGURATION_H

#include <vector>
#include <cstdlib>
#include "Byte.h"
#include <iostream>
#include <sys/ioctl.h>
#include <net/if.h>
#include <unistd.h>
#include <netinet/in.h>
#include <string.h>

typedef unsigned long long ull;
#define MAC_ADD_LEN 6
#define STREAMID_LEN 3
#define FRAME_TYPE_LEN 2
#define CRC_LENGTH 4
#define PREMBLE_LENGTH 8
#define LENGTH_LENGTH 2

enum PayloadType {FIRST, SECOND, RANDOM};

class Configuration
{
private:
    std::vector<ByteArray> senders;
    std::vector<ByteArray> receivers;
    ByteArray myMacAddress;
    PayloadType payloadType;
    ull numberOfPackets = 100;
    ull lifeTime = 100;
    int payloadLength, seed;
    int flowType;
    ull SendingRate;
    ByteArray* streamID;

    unsigned char hexSwitcher(int x)
    {
        if(x<10 && x>=0)
            return x+'0';
        else if(x>9 && x<16)
            return x+'A';
        else
            return 'F';
    }
    ByteArray discoverMyMac()
    {
        struct ifreq ifr;
        struct ifconf ifc;
        char buf[1024];
        int success = 0;

        int sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_IP);
        if (sock == -1) { /* handle error*/ };

        ifc.ifc_len = sizeof(buf);
        ifc.ifc_buf = buf;
        if (ioctl(sock, SIOCGIFCONF, &ifc) == -1) { /* handle error */ }

        struct ifreq* it = ifc.ifc_req;
        const struct ifreq* const end = it + (ifc.ifc_len / sizeof(struct ifreq));

        for (; it != end; ++it) {
            strcpy(ifr.ifr_name, it->ifr_name);
            if (ioctl(sock, SIOCGIFFLAGS, &ifr) == 0) {
                if (! (ifr.ifr_flags & IFF_LOOPBACK)) { // don't count loopback
                    if (ioctl(sock, SIOCGIFHWADDR, &ifr) == 0) {
                        success = 1;
                        break;
                    }
                }
            }
        }

        unsigned char mac_address[MAC_ADD_LEN];

        if (success) memcpy(mac_address, ifr.ifr_hwaddr.sa_data, 6);
        return ByteArray((char*) mac_address, MAC_ADD_LEN,0);
    }
public:
    void loadFromFile(char* path)
    {
        freopen(path,"r",stdin);

        //Set stream ID, must be of leangth 3 (STREAMID_LEN)
        char* sID = new char[STREAMID_LEN];
        std::cin>>sID;
        setStreamID(sID);

        //Set senders and recievers
        int sndSize, rcvSize;
        std::cin>> sndSize;
        while(sndSize--)    //Read n senders
        {
            std::string s;
            std::cin>>s;
            senders.push_back(ByteArray(s.c_str(),s.size(),0));
        }
        std::cin>> rcvSize;
        while(rcvSize--)    //Read n reciever
        {
            std::string s;
            std::cin>>s;
            receivers.push_back(ByteArray(s.c_str(),s.size(),0));
        }
        //Read payload type
        int pt;
        std::cin>>pt;
        switch (pt)
        {
            case 0:
                payloadType = FIRST;
                break;
            case 1:
                payloadType = SECOND;
                break;
            default:
                payloadType = RANDOM;
        }

        std::cin>>numberOfPackets;
        std::cin>>payloadLength;
        std::cin>>seed;

        //handle macaddres
        myMacAddress = discoverMyMac();
    }

    std::vector<ByteArray> &getSenders()
    {
        return senders;
    }

    void setSenders(const std::vector<ByteArray> &senders)
    {
        Configuration::senders = senders;
    }

    const std::vector<ByteArray> &getReceivers() const
    {
        return receivers;
    }

    void setReceivers(const std::vector<ByteArray> &receivers)
    {
        Configuration::receivers = receivers;
    }

    PayloadType getPayloadType() const
    {
        return payloadType;
    }

    void setPayloadType(PayloadType payloadType)
    {
        Configuration::payloadType = payloadType;
    }

    long long int getNumberOfPackets() const
    {
        return numberOfPackets;
    }

    void setNumberOfPackets(long long int numberOfPackets)
    {
        Configuration::numberOfPackets = numberOfPackets;
    }

    long long int getLifeTime() const
    {
        return lifeTime;
    }

    void setLifeTime(long long int lifeTime)
    {
        Configuration::lifeTime = lifeTime;
    }

    int getFlowType() const
    {
        return flowType;
    }

    void setFlowType(int flowType)
    {
        Configuration::flowType = flowType;
    }

    long long int getSendingRate() const
    {
        return SendingRate;
    }

    void setSendingRate(long long int sendingRate)
    {
        SendingRate = sendingRate;
    }

    ByteArray getMyMacAddress()
    {
        return myMacAddress;
    }

    int getSeed()
    {
        return seed;
    }

    int getPayloadLength()
    {
        return payloadLength;
    }

    void setMyMacAddress(char* mac)
    {
        myMacAddress = ByteArray(mac,6,0);
    }

    ByteArray* getStreamID()
    {
        return streamID;
    }

    void setStreamID(char* id)
    {
        streamID = new ByteArray(id,STREAMID_LEN,0);
    }

    //For debugging only
    void print()
    {
        printf("Stream ID: %s\n", streamID->bytes);
        printf("Senders(%d):\n", (int)senders.size());
        for(auto sender: senders)
        {
            printf("%c", 9);
            sender.printChars();
        }

        printf("Receivers(%d):\n", (int)receivers.size());
        for(auto rec: receivers)
        {
            printf("%c",9);
            rec.printChars();
        }

        switch (payloadType)
        {
            case FIRST:
                printf("Payload Type: FIRST\n");
                break;
            case SECOND:
                printf("Payload Type: SECOND\n");
                break;
            default:
                printf("Payload Type: RANDOM\n");
        }
        printf("Number of packets: %d\n", (int)numberOfPackets);
        printf("Payload length: %d\n", payloadLength);
        printf("Seed: %d\n\n\n", seed);
        printf("###########################\n");

    }
};

#endif
