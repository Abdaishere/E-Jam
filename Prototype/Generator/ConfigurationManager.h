//
// Created by khaled on 12/3/22.
//

#ifndef GENERATOR_CONFIGURATIONMANAGER_H
#define GENERATOR_CONFIGURATIONMANAGER_H


#include "Configuration.h"
#include "Byte.h"

class ConfigurationManager
{
private:
    static Configuration *configuration;
public:
    static Configuration* getConfiguration(char*);
    static Configuration* getConfiguration();
    static void run();
};


#endif //GENERATOR_CONFIGURATIONMANAGER_H
