#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <vector>
#include <string>
#include <map>
#include <sys/time.h>

using namespace std;

struct Device
{
    char ip[20];
    char mac_address[500];
};

typedef map<string,Device*> Snapshot;

void updateArpTable1()
{
    system("sudo arp-scan --localnet > ./arper_data");
}

Snapshot getDevices()
{
    //Snapshot devices;
    Snapshot devices;
    updateArpTable1();
    // Read with fgets()
    char line[500];
    FILE *fp = fopen("./arper_data", "r");
    fgets(line, sizeof(line), fp);    // Skip the first two lines (column headers).
    fgets(line, sizeof(line), fp);    // Skip the first two lines (column headers).


    while(fgets(line, sizeof(line), fp))
    {
        //if the current line does not start with an ip
        if ((line[0]<'0' || line[0]>'9') &&
            (line[1]<'0' || line[1]>'9' || line[1]=='0'))
            break;

        auto *device = new Device;
        // Read the data.
        sscanf(line, "%s    %s\n",
               device->ip,
               device->mac_address
               );

        if(strcmp(device->mac_address, "00:00:00:00:00:00") != 0)
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

    short INTERVAL = 3.0;// in seconds

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

            if(devicesEntered.size()!=0)
            {
                printf("####################\n");
                printf("# There are (%zu) new devices: \n", devicesEntered.size());
                for (auto d: devicesEntered)
                    printf("# %s    %s\n", d->ip, d->mac_address);
                printf("####################\n\n");

            }

            if(devicesLeft.size()!=0)
            {
                printf("####################\n");
                printf("# Devices disconnected (%zu)\n", devicesLeft.size());
                for(auto d: devicesLeft)
                    printf("# %s    %s\n", d->ip, d->mac_address);
                printf("####################\n\n");
            }
        }
        gettimeofday(&now, NULL);
    }
    return 0;
}

