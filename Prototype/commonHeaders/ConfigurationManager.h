#ifndef GENERATOR_CONFIGURATIONMANAGER_H
#define GENERATOR_CONFIGURATIONMANAGER_H


#include "Configuration.h"
#include "Byte.h"

class ConfigurationManager
{
public:
    static Configuration getConfiguration(char*);
    static Configuration getConfiguration();
    static void run(Configuration);
};


#endif //GENERATOR_CONFIGURATIONMANAGER_H
