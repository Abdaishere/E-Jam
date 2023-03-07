#ifndef CONFIGURATIONMANAGER_H
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
    static std::string exec(const char*);
    static char* currentStreamID;
    static std::string CONFIG_FOLDER;
public:
    static int convertStreamID(char*);
    static void initConfigurations();
    static void addConfiguration(const char*);
    static std::shared_ptr<Configuration> getConfiguration();
    static void setCurrStreamID(ByteArray& streamID);
    static char* getCurrStreamID();

    static std::vector<std::string> splitString(const std::string &s, char delim);
};



#endif // CONFIGURATIONMANAGER_H
