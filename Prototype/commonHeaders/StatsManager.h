#ifndef VERIFIER_STATSMANAGER_H
#define VERIFIER_STATSMANAGER_H

//Send interval in seconds
#define SEND_DELAY 1
#define STAT_DIR "/etc/EJam/stats"


#include <chrono>
#include "Configuration.h"
#include <memory>
#include "unistd.h"
#include "sys/stat.h"
#include <fcntl.h>


typedef unsigned long long ull;
//Singleton class
class StatsManager
{
private:
    static std::shared_ptr<StatsManager> instance; //singleton unique instance
	ull receivedCorrectPckts;
	ull receivedWrongPckts;
	ull receivedOutOfOrderPckts;
	ull droppedPckts;

	ull sentPckts;
	ull sentErrorPckts;

    std::chrono::time_point<std::chrono::steady_clock> timer;
    StatsManager(const Configuration& config, int, bool);
    void resetStats();
	void buildMsg(std::string&);
    void writeStatFile();
	bool is_gen;
    int instanceID;
	Configuration configuration;
	int fd; //file descriptor to write sgen_id files

public:
    static std::shared_ptr<StatsManager> getInstance(const Configuration& config, int instanceID = 0, bool is_gen = false);
    static std::shared_ptr<StatsManager> getInstance();
    void sendStats();
	void increaseReceivedCorrectPckts(int);
	void increaseReceivedWrongPckts(int);
	void increaseReceivedOutOfOrderPckts(int);
	void increaseDroppedPckts(int);
	void increaseSentPckts(int);
	void increaseSentErrorPckts(int);
};


#endif //VERIFIER_STATSMANAGER_H
