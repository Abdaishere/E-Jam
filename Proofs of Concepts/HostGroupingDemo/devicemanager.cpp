#include "devicemanager.h"
DeviceManager* DeviceManager::instance = nullptr;

DeviceManager* DeviceManager::getInstance()
{
    if(DeviceManager::instance == nullptr)
        DeviceManager::instance = new DeviceManager;
    return DeviceManager::instance;
}

DeviceManager::DeviceManager()
{
    discoverDevices();
}

void DeviceManager::discoverDevices()
{
    //TODO: hard-coded for now, to be developed later
    devices.push_back(Device("192.168.1.1",1,0,"10:00:00:00","0","0"));
    devices.push_back(Device("192.168.1.2",1,0,"20:00:00:00","0","0"));
    devices.push_back(Device("192.168.1.3",1,0,"30:00:00:00","0","0"));
    devices.push_back(Device("192.168.1.4",1,0,"40:00:00:00","0","0"));
    devices.push_back(Device("192.168.1.5",1,0,"50:00:00:00","0","0"));
    devices.push_back(Device("192.168.1.6",1,0,"60:00:00:00","0","0"));
    devices.push_back(Device("192.168.1.7",1,0,"70:00:00:00","0","0"));
    devices.push_back(Device("192.168.1.8",1,0,"80:00:00:00","0","0"));

}

int DeviceManager::getNumberOfDevices()
{
    return devices.size();
}
