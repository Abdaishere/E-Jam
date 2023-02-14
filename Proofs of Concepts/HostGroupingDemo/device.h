#include <string>

#ifndef DEVICE_H
#define DEVICE_H

#endif // DEVICE_H

class Device
{
public:
    std::string ip;
    int hw;
    int flags;
    std::string mac_address;
    std::string mask;
    std::string iface;

    Device(std::string ip, int hw, int flags, std::string mac_address, std::string mask, std::string iface)
        :ip {ip}, hw{hw}, flags{flags}, mac_address{mac_address}, mask{mask}, iface{iface}{}
};
