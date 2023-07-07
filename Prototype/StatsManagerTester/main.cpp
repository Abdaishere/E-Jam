#include <iostream>
#include <memory>
#include "StatsManager.h"
#include <thread>
#include <cstdlib>
#include <ctime>

int generate_random_number()
{
	std::srand(std::time(nullptr));
	return std::rand() % 100 + 1;
}

void execute_every_duration(std::shared_ptr<StatsManager> sm,int duration_in_seconds)
{
	int x = 0;
	while (true)
	{
		int r = generate_random_number();
		sm->increaseSentPckts(r);
		std::cout<<x++<<": adding "<<r<<" packets\n";
		sm->sendStats();
		std::this_thread::sleep_for(std::chrono::seconds(duration_in_seconds));
	}
}

int main()
{
	Configuration  configuration;
	configuration.setMacAddress(ByteArray(reinterpret_cast<const unsigned char *>("AA:AA:BB")));
	configuration.setStreamID(reinterpret_cast<const unsigned char *>("id123"));
	configuration.setFilePath("path...");
	std::shared_ptr<StatsManager> sm = StatsManager::getInstance(configuration, 0, true);

	execute_every_duration(sm,1);


	return 0;
}