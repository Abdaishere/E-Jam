//
// Created by khaled on 11/27/22.
//

#ifndef GENERATOR_DATAGRAMCONSTRUCTOR_H
#define GENERATOR_DATAGRAMCONSTRUCTOR_H

#define valid_protocols {IPv6, IPv4, };

class DatagramConstructor
{
private:
    int protocol;
    char* datagram;
    char* payload;
public:
    DatagramConstructor(const char* payload, int protocol){};
    void constructDatagram();
};

#endif //GENERATOR_DATAGRAMCONSTRUCTOR_H
