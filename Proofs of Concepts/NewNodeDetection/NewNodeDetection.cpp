#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <sys/shm.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <csignal>
#include<sys/wait.h>
#include<unistd.h>
#include <vector>
#include <string>
#include <iostream>
#include <map>
#include <sys/time.h>

using namespace std;

struct Device
{
    char ip[20];
    int hw;
    int flags;
    char mac_address[500];
    char mask[500];
    char iface[500];
};

typedef map<string,Device*> Snapshot;

Snapshot getDevices()
{
    Snapshot devices;
    char line[500]; // Read with fgets().
    FILE *fp = fopen("/proc/net/arp", "r");
    fgets(line, sizeof(line), fp);    // Skip the first line (column headers).
    while(fgets(line, sizeof(line), fp))
    {
        auto *device = new Device;
        // Read the data.
        sscanf(line, "%s 0x%x 0x%x %s %s %s\n",
               device->ip,
               &device->hw,
               &device->flags,
               device->mac_address,
               device->mask,
               device->iface);
        devices.insert(pair<string,Device*>(device->mac_address,device));
    }
    fclose(fp);
    return devices;
}
vector<Device*> snapshotDifference(const Snapshot& list1, const Snapshot& list2)
{
    //list1 - list2
    vector<Device*> difference;
    for(auto & i : list1)
    {
        if(list2.find(i.first) == list2.end())
            difference.push_back(i.second);
    }
    return difference;
}

int main()
{
    Snapshot currentDevices;
    Snapshot oldDevices;

    short INTERVAL = 1.0;// in seconds

    //The timer part can be replaced with sleep when implementing this code as a thread

    timeval now, start;
    gettimeofday(&start, NULL);
    gettimeofday(&now, NULL);


    while(true)
    {
        double secs = (double)(now.tv_usec - start.tv_usec) / 1000000 + (double)(now.tv_sec - start.tv_sec);
        if(secs > INTERVAL)
        {
            gettimeofday(&start, NULL); //reset timer
            currentDevices = getDevices();
            vector<Device*> devicesEntered = snapshotDifference(currentDevices, oldDevices);
            vector<Device*> devicesLeft    = snapshotDifference(oldDevices, currentDevices);
            oldDevices = currentDevices;

            printf("number of new devices = %zu\nnumber of disconnected devices = %zu\n",
                   devicesEntered.size(), devicesLeft.size());
        }
        gettimeofday(&now, NULL);
    }

    return 0;
}

