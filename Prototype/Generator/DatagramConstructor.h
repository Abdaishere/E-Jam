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
public:
    DatagramConstructor(int protocol, const char* resultingString, int innerProtocol){};
    void constructDatagram();
};


#endif //GENERATOR_DATAGRAMCONSTRUCTOR_H
