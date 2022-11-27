//
// Created by khaled on 11/27/22.
//
#include <vector>
#include <string>

typedef char* byte;
typedef unsigned long long ull;
#define MAC_ADD_LEN 6

class Configuration
{
private:
    std::vector<byte> senders;
    std::vector<byte> receivers;
    int payloadType;
    ull numberOfPackets;
    ull lifeTime;
    int flowType;
    ull SendingRate;

public:
    const std::vector<byte> &getSenders() const
    {
        return senders;
    }

    void setSenders(const std::vector<byte> &senders)
    {
        Configuration::senders = senders;
    }

    const std::vector<byte> &getReceivers() const
    {
        return receivers;
    }

    void setReceivers(const std::vector<byte> &receivers)
    {
        Configuration::receivers = receivers;
    }

    int getPayloadType() const
    {
        return payloadType;
    }

    void setPayloadType(int payloadType)
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
};

