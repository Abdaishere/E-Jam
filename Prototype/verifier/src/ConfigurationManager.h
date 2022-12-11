#ifndef CONFIGURATIONMANAGER_H
#define CONFIGURATIONMANAGER_H

#define CONFIG_FOLDER /tmp/config

#include "Configuration.h"
#include "Byte.h"
#include <map>
#include <string>

class ConfigurationManager
{
private:
    static std::map<char*, Configuration*> configurations;
    static std::string exec(const char*);
public:
    static void fillMap();
    static void addConfiguration(char*);
    static Configuration* getConfiguration(char*);
};



#endif // CONFIGURATIONMANAGER_H
