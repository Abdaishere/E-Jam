/*#ifndef CONFIGURATIONMANAGER_H
#define CONFIGURATIONMANAGER_H

#define CONFIG_FOLDER_LENGTH 11

#include "../commonHeaders/Configuration.h"
#include "../commonHeaders/Byte.h"
#include <map>
#include <string>
#include <sstream>
#include <memory>

#include "../commonHeaders/UsernameGetter.h"

class ConfigurationManager
{
private:
    static std::map<int, std::shared_ptr<Configuration>> configurations;
    static std::string CONFIG_FOLDER;
public:
    static void initConfigurations();
    static void addConfiguration(const char*);
    static std::shared_ptr<Configuration> getConfiguration();
};



#endif // CONFIGURATIONMANAGER_H
*/