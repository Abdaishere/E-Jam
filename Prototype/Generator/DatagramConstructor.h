
#ifndef GENERATOR_DATAGRAMCONSTRUCTOR_H
#define GENERATOR_DATAGRAMCONSTRUCTOR_H

#include <string>

#define valid_protocols {IPv6, IPv4, };

class DatagramConstructor
{
private:
    int protocol;
    std::string datagram;
    std::string payload;
public:
    DatagramConstructor(std::string payload, int protocol){};
    void constructDatagram();
};

#endif //GENERATOR_DATAGRAMCONSTRUCTOR_H
