#ifndef CONFIGURATIONMANAGER_H
#define CONFIGURATIONMANAGER_H


#include "Configuration.h"
#include "Byte.h"

class ConfigurationManager
{
private:
    static Configuration* configuration;
public:
    static void loadConfiguration(ByteArray);
    static Configuration* getConfiguration();
};



#endif // CONFIGURATIONMANAGER_H
