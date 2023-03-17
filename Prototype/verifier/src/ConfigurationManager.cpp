#include "ConfigurationManager.h"


std::map<int, std::shared_ptr<Configuration>> ConfigurationManager::configurations; //map stream id to configuration
char* ConfigurationManager::currentStreamID;
std::string ConfigurationManager::CONFIG_FOLDER;

//get configuration related to stream id
std::shared_ptr<Configuration> ConfigurationManager::getConfiguration()
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
    std::shared_ptr<Configuration> val = std::make_shared<Configuration>();
    val->loadFromFile((char *)dir);

    int key = convertStreamID((char*) val->getStreamID()->c_str());
    configurations[key] = val;
}

void ConfigurationManager::initConfigurations()
{
    CONFIG_FOLDER = "";
    CONFIG_FOLDER+= CONFIG_DIR;

    std::string lsStr = "ls ";
    std::string dirStr(CONFIG_FOLDER);
    lsStr+=dirStr;

    std::string ls= exec(lsStr.c_str());
    std::vector<std::string> directories = splitString(ls,'\n');

    //Augment the parent directory
    for(std::string& dir: directories)
        dir = std::string(CONFIG_FOLDER)+"/"+dir;

    for(const std::string& dir: directories)
    {
        if(dir.substr(dir.size()-3) == "txt")
            addConfiguration(dir.c_str());
    }
}

//execute command in cmd
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

//split string in vector based on specific delimeter
std::vector<std::string> ConfigurationManager::splitString(const std::string& s, char delim)
{
    std::stringstream raw(s);
    std::string temp;
    std::vector<std::string> arr;
    while(getline(raw, temp, delim))
        arr.push_back(temp);
    return arr;
}

void ConfigurationManager::setCurrStreamID(ByteArray& streamID)
{
    currentStreamID = (char*) streamID.c_str();
}

char* ConfigurationManager::getCurrStreamID()
{
    return currentStreamID;
}

int ConfigurationManager::convertStreamID(char* strmID)
{
    return strmID[0] + (strmID[1] << 8) + (strmID[2] << 16);
}
