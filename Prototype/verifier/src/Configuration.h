#ifndef CONFIGURATION_H_INCLUDED
#define CONFIGURATION_H_INCLUDED

#include <vector>
#include <cstdlib>
#include "Byte.h"

typedef unsigned long long ull;
#define MAC_ADD_LEN 6

enum PayloadType {FIRST, SECOND, RANDOM};

class Configuration
{
private:
    std::vector<ByteArray> senders;
    std::vector<ByteArray> receivers;
    ByteArray myMacAddress;
    PayloadType payloadType;
    ull numberOfPackets;
    ull lifeTime;
    int flowType;
    ull SendingRate;

    unsigned char hexSwitcher(int x)
    {
        if(x<10 && x>=0)
            return x+'0';
        else if(x>9 && x<16)
            return x+'A';
        else
            return 'F';
    }
public:
    Configuration()
    {
        int macLen = 6;

        this->myMacAddress = ByteArray(macLen,0);
        for (int i=0; i<macLen; i++)
        {
            this->myMacAddress[i] = hexSwitcher(rand()%16);
        }
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
};


#endif // CONFIGURATION_H_INCLUDED
