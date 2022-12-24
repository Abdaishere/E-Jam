#include "ConfigurationManager.h"


std::map<int, Configuration*> ConfigurationManager::configurations;
char* ConfigurationManager::currentStreamID;
std::string ConfigurationManager::CONFIG_FOLDER;

Configuration *ConfigurationManager::getConfiguration()
{
    char* streamID = ConfigurationManager::currentStreamID;
    int key = convertStreamID(streamID);

    if(configurations.find(key)==configurations.end())
    {
        return nullptr;
    }
    return configurations[key];
}

void ConfigurationManager::addConfiguration(const char * dir)
{
    Configuration* val = new Configuration();
    val->loadFromFile((char *)dir);

    int key = convertStreamID((char*) val->getStreamID()->bytes);

    configurations[key] = val;
    val->print();
}

void ConfigurationManager::initConfigurations()
{
    CONFIG_FOLDER = "";
    CONFIG_FOLDER+="/home/" +UsernameGetter::exec() + "/EJam";

    std::string lsStr = "ls ";
    std::string dirStr(CONFIG_FOLDER);
    lsStr+=dirStr;

    std::string ls= exec(lsStr.c_str());
    std::vector<std::string> directories = splitString(ls,'\n');

    //Augment the parent directory
    for(std::string& dir: directories)
        dir = std::string(CONFIG_FOLDER)+"/"+dir;

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

int ConfigurationManager::convertStreamID(char* strmID)
{
    return strmID[0] + (strmID[1] << 8) + (strmID[2] << 16);
}
