#ifndef GENERATOR_CONFIGURATIONMANAGER_H
#define GENERATOR_CONFIGURATIONMANAGER_H


#include "Configuration.h"
#include "Byte.h"

class ConfigurationManager
{
private:
    //singleton instance from configuration
    static std::shared_ptr<Configuration> configuration;
public:
    static std::shared_ptr<Configuration> getConfiguration(char*);
    static std::shared_ptr<Configuration>& getConfiguration();
    static void run();
};


#endif //GENERATOR_CONFIGURATIONMANAGER_H
