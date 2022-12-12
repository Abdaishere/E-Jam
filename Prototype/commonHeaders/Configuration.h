//
// Created by khaled on 11/27/22.
//
#ifndef CONFIGURATION_H
#define CONFIGURATION_H

#include <vector>
#include <cstdlib>
#include "Byte.h"
#include <iostream>

typedef unsigned long long ull;
#define MAC_ADD_LEN 6
#define STREAMID_LEN 3
#define FRAME_TYPE_LEN 2

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
        //TODO get the real mac address
        ByteArray mac;
        mac = ByteArray("EEEEEE",6,0);
        /*
        int macLen = 6;
        mac = ByteArray(macLen,0);
        for (int i=0; i<macLen; i++)
        {
            this->myMacAddress[i] = hexSwitcher(rand()%16);
            this->myMacAddress.length++;
        }*/
        return mac;
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
        printf("Senders(%d):\n", senders.size());
        for(auto sender: senders)
        {
            printf("%c", 9);
            sender.printChars();
        }

        printf("Receivers(%d):\n", receivers.size());
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
        printf("Number of packets: %d\n", numberOfPackets);
        printf("Payload length: %d\n", payloadLength);
        printf("Seed: %d\n\n\n", seed);
        printf("###########################\n");

    }
};

#endif
