#include "ConfigurationManager.h"


std::map<char*, Configuration*> ConfigurationManager::configurations;
char* ConfigurationManager::currentStreamID;

Configuration *ConfigurationManager::getConfiguration()
{
    char* streamID = ConfigurationManager::currentStreamID;
    if(configurations.find(streamID)==configurations.end())
    {
        return nullptr;
    }
    return configurations[streamID];
}

void ConfigurationManager::addConfiguration(const char * dir)
{
    Configuration* val = new Configuration();
    val->loadFromFile((char *)dir);

    char* key = (char*) val->getStreamID()->bytes;

    configurations[key] = val;
}

void ConfigurationManager::initConfigurations()
{
    std::string lsStr = "ls ";
    std::string dirStr(CONFIG_FOLDER);
    lsStr+=dirStr;

    std::string ls= exec(lsStr.c_str());
    std::vector<std::string> directories = splitString(ls,'\n');

    for(const std::string& dir: directories)
        addConfiguration(dir.c_str());
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

std::vector<std::string> ConfigurationManager::splitString(const std::string& s, char delim)
{
    std::stringstream raw(s);
    std::string temp;
    std::vector<std::string> arr;
    while(getline(raw, temp, delim))
        arr.push_back(temp);
    return arr;
}

void ConfigurationManager::setCurrStreamID(char * newStrmID)
{
    //delete old stream id
    delete[] currentStreamID;

    //set new stream id
    currentStreamID = newStrmID;
}

char *ConfigurationManager::getCurrStreamID()
{
    return currentStreamID;
}
