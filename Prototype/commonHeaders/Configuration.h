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
#include <memory>

//constants of configuration
typedef unsigned long long ull;
#define MAC_ADD_LEN 6
#define STREAMID_LEN 3
#define SeqNum_Len 8
#define FRAME_TYPE_LEN 2
#define CRC_LENGTH 4
#define PREMBLE_LENGTH 8
#define LENGTH_LENGTH 2
#define SeqNum_LEN 8
#define CONFIG_DIR "/etc/EJam"



enum PayloadType {FIRST, SECOND, RANDOM};
enum TransportProtocol {TCP, UDP};
enum FlowType {BACK_TO_BACK, BURSTY};

class Configuration
{
private:
    //stream attributes
    std::shared_ptr<ByteArray> streamID;                //A 3 alphanumeric charaters defining a stream
    std::vector<ByteArray> senders;     //list of senders mac addresses
    std::vector<ByteArray> receivers;   //list of receivers mac addressess
    ByteArray myMacAddress;             //The mac address of this machine (Inferred)
    PayloadType payloadType;            //The type of the payload
    ull numberOfPackets = 100;          //Number of packets flowing in the stream before it ends
    ull bcFramesNum;                    //after x regular frame, send a broadcast frame
    int payloadLength, seed;            //Payload length, and seed to use in RNGs
    ull interFrameGap;                  //Time to wait between each packet generation in the stream in ms
    ull lifeTime = 1000;                //Time to live before ending execution in ms
    TransportProtocol transportProtocol;  //The protocol used in the transport layer
    FlowType flowType;                  //The production pattern that the packets uses
    bool checkContent;                  //Whether to check content or not
    char* filePath;

    //convert int to corresponding hexa character
    unsigned char hexSwitcher(int x)
    {
        if(x<10 && x>=0)
            return x+'0';
        else if(x>9 && x<16)
            return x+'A';
        else
            return 'F';
    }

    //Discover the mac address of this machine
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
        return ByteArray(mac_address, MAC_ADD_LEN);
    }
public:
    Configuration()
    {
        filePath = nullptr;
    }

    bool isSet()
    {
        return filePath != nullptr;
    }

    //Read configuration from a file of the correct format
    void loadFromFile(char* path)
    {
        //copying pointers, not actual contents of the char array
        filePath = path;
        freopen(path,"r",stdin);

        //Set stream ID, must be of leangth 3 (STREAMID_LEN)
        unsigned char* sID =  new unsigned char[STREAMID_LEN];
        for(int i=0;i<STREAMID_LEN;i++) std::cin>>sID[i];

        setStreamID(sID);

        //Set senders and recievers
        int sndSize, rcvSize;
        std::cin>> sndSize;
        while(sndSize--)    //Read n senders
        {
            std::string s;
            std::cin>>s;
            senders.push_back(ByteArray(s.begin(), s.end()));
        }
        std::cin>> rcvSize;
        while(rcvSize--)    //Read n reciever
        {
            std::string s;
            std::cin>>s;
            receivers.push_back(ByteArray(s.begin(), s.end()));
        }
        //Read payload type
        int input;
        std::cin>>input;
        switch (input)
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
        std::cin>>bcFramesNum;
        std::cin>>interFrameGap;
        std::cin>>lifeTime;

        //Read transport protocol
        std::cin>>input;
        switch (input)
        {
            case 0:
                transportProtocol = TCP;
                break;
            default:
                transportProtocol = UDP;
        }

        //Read Flow type
        std::cin>>input;
        switch (input)
        {
            case 0:
                flowType = BACK_TO_BACK;
                break;
            default:
                flowType = BURSTY;
        }

        //Read check content
        char cInput;
        std::cin>>cInput;
        cInput-='0'; //convert to int
        checkContent = cInput;


        //handle macaddres
        myMacAddress = discoverMyMac();
        Mac12toMac6();
    }

    //convert hexa character to corresponding char value in decimal
    char hexToNum(char c)
    {
        if(c >= 'A' && c <='F')
            return c - 'A' + 10;
        return  c - '0';
    }

    //converting mac of length 12 (hexadecimal notation) to mac length 6
    std::string convertToMac6(std::string mac12)
    {
        std::string mac6(6, 'x');
        if(mac12.size() != 12)
        {
            throw std::invalid_argument("SIZE NOT 12");
        }
        for(int i=0,j=0; i<12; i+=2,j++)
        {
            char half1 = 0, half2 = 0;
            half1 = hexToNum(mac12[i]);
            // ABFF000
            half2 = hexToNum(mac12[i+1]);
            mac6[j] = (half1 << 4) + half2;
        }
        return mac6;
    }

    //convert all senders and receivers to mac 6
    void Mac12toMac6()
    {
        for(auto& e:receivers)
        {
            std::string temp(12, 'x');
            for(int i=0; i<12; i++) temp[i] = e.at(i);
            std::string ma6 = convertToMac6(temp);
            ByteArray mac6 = ByteArray(ma6.begin(), ma6.end());
            e = mac6;
        }
        for(auto& e:senders)
        {
            std::string temp(12, 'x');
            for(int i=0; i<12; i++) temp[i] = e.at(i);
            std::string ma6 = convertToMac6(temp);
            ByteArray mac6 = ByteArray(ma6.begin(), ma6.end());
            e = mac6;
        }
    }

    //getters and setters
    
    std::vector<ByteArray>& getSenders()
    {
        return senders;
    }

    void setSenders(const std::vector<ByteArray> &inSenders)
    {
        Configuration::senders = inSenders;
    }

    std::vector<ByteArray>& getReceivers() 
    {
        return receivers;
    }

    void setReceivers(const std::vector<ByteArray> &inReceivers)
    {
        Configuration::receivers = inReceivers;
    }

    PayloadType getPayloadType() const
    {
        return payloadType;
    }

    void setPayloadType(PayloadType pt)
    {
        Configuration::payloadType = pt;
    }

    long long int getNumberOfPackets() const
    {
        return numberOfPackets;
    }

    void setNumberOfPackets(long long int nop)
    {
        Configuration::numberOfPackets = nop;
    }

    long long int getLifeTime() const
    {
        return lifeTime;
    }

    void setLifeTime(long long int lt)
    {
        Configuration::lifeTime = lt;
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

    void setMyMacAddress(const unsigned char* mac)
    {
        myMacAddress = ByteArray(mac,6);
    }

    std::shared_ptr<ByteArray> getStreamID()
    {
        return streamID;
    }

    void setStreamID(const unsigned char* id)
    {
        streamID = std::make_shared<ByteArray>(id, STREAMID_LEN);
    }

    ull getBcFramesNum()
    {
        return bcFramesNum;
    }

    ull getInterFrameGap()
    {
        return interFrameGap;
    }

    ull getLifeTime()
    {
        return lifeTime;
    }
    TransportProtocol getTransportProtocol()
    {
        return transportProtocol;
    }
    FlowType getFlowType()
    {
        return flowType;
    }
    bool getCheckContent()
    {
        return checkContent;
    }


    //Printing for debugging only
    void print()
    {
        printf("Stream ID: %s\n", streamID->c_str());
        printf("Senders(%d):\n", (int)senders.size());
        for(auto sender: senders)
        {
            printf("%c", 9);
            printChars(&sender);
        }

        printf("Receivers(%d):\n", (int)receivers.size());
        for(auto rec: receivers)
        {
            printf("%c",9);
            printChars(&rec);
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
        printf("Seed: %d\n", seed);
        printf("bcFramesNum: %llu\n", bcFramesNum);
        printf("interFrameGap: %llu\n", interFrameGap);
        printf("lifeTime: %llu\n", lifeTime);

        switch (transportProtocol)
        {
            case TCP:
                printf("Transprt Protocol Type: TCP\n");
                break;
            default:
                printf("Transprt Protocol Type: UDP\n");
        }
        switch (flowType)
        {
            case BACK_TO_BACK:
                printf("Flow Type: Back to back\n");
                break;
            default:
                printf("Flow Type: Bursty\n");
        }

        printf("checkContent: %d\n", checkContent);
        printf("###########################\n");
    }
};

#endif
