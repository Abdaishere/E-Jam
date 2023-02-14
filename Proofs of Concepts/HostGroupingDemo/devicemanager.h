#ifndef DEVICEMANAGER_H
#define DEVICEMANAGER_H

#include "device.h"
#include <vector>

class DeviceManager
{
public:
    std::vector<Device> devices;
    static DeviceManager* getInstance();
    int getNumberOfDevices();
private:
    static DeviceManager* instance;
    DeviceManager();
    void discoverDevices();
};

#endif // DEVICEMANAGER_H
