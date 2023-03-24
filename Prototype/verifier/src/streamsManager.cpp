#include "streamsManager.h"

/*
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

void ConfigurationManager::setCurrStreamID(ByteArray& streamID)
{
    currentStreamID = (char*) streamID.c_str();
}

char* ConfigurationManager::getCurrStreamID()
{
    return currentStreamID;
}
*/