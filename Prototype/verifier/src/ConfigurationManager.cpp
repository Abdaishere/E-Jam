#include "ConfigurationManager.h"


std::map<char*, Configuration*> ConfigurationManager::configurations;

Configuration *ConfigurationManager::getConfiguration(char * streamID)
{
    if(configurations.find(streamID)==configurations.end())
    {
        return nullptr;
    }
    return configurations[streamID];
}

void ConfigurationManager::addConfiguration(char * dir)
{
    Configuration* val = new Configuration();
    val->loadFromFile(dir);

    char* key = (char*) val->getStreamID()->bytes;

    configurations[key] = val;
}

void ConfigurationManager::fillMap()
{
    std::vector<char*> directories;

    //char* ls= system("ls CONFIG_FOLDER");

    for(char* dir: directories)
        addConfiguration(dir);
}

std::string ConfigurationManager::exec(const char * command)
{
    char buffer[128];
    std::string result = "";
    FILE* pipe = popen(command, "r");
    if (!pipe) throw std::runtime_error("popen() failed!");
    try {
        while (fgets(buffer, sizeof buffer, pipe) != NULL) {
            result += buffer;
        }
    } catch (...) {
        pclose(pipe);
        throw;
    }
    pclose(pipe);
    return result;
}

