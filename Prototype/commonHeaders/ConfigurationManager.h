#ifndef GENERATOR_CONFIGURATIONMANAGER_H
#define GENERATOR_CONFIGURATIONMANAGER_H


#include "Configuration.h"
#include "Byte.h"
#include "Utils.h"
#include <algorithm>
#include <vector>
/// This class servers a multipurpose job
/// For the generator and verifier, it acts as a fetcher for their current configuration
/// For the gateway, it acts as a directory to guide gateway for which verifier to send its incoming packets
class ConfigurationManager
{
private:
    static std::vector<Configuration> configurations;
public:
    static std::string CONFIG_FOLDER;
    static std::vector<ByteArray> streamIDs;
    static void initConfigurations();
    static Configuration getConfiguration(char*);
    static void addConfiguration(const char*);
    static void run(Configuration);
    static int getNumberOfStreams();
    static int getStreamIndex(ByteArray&);
};


#endif //GENERATOR_CONFIGURATIONMANAGER_H
