//
// Created by khaled on 12/26/22.
//

#ifndef VERIFIER_STATSMANAGER_H
#define VERIFIER_STATSMANAGER_H

//Send interval in seconds
#define SEND_DELAY 1
#define STAT_DIR "/etc/EJam/stats/"


#include <chrono>
#include "Configuration.h"

//Singleton class
class StatsManager
{
private:
    static StatsManager* instance;
    long numberOfPackets;
    long numberOfErrors;
    clock_t timer;
    StatsManager(int, bool);
    void resetStats(bool);
    void writeStatFile();
    bool is_gen;
    int instanceID;

public:
    static StatsManager* getInstance(int instanceID = 0,bool is_gen = false);
    void sendStats();
    void increaseNumPackets(long val = 1);
    void increaseNumErrors(long val = 1);
};


#endif //VERIFIER_STATSMANAGER_H
