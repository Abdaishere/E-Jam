#include "ConfigurationManager.h"
std::string ConfigurationManager::CONFIG_FOLDER = "etc/EJam";
std::vector<ByteArray>ConfigurationManager::streamIDs = std::vector<ByteArray>();
Configuration ConfigurationManager::getConfiguration(char* path)
{
    Configuration currentConfiguration;
    currentConfiguration.loadFromFile(path);

    return currentConfiguration;
}

//for testing that we read the configuration correctly
void ConfigurationManager::run(Configuration configuration)
{
    if(!configuration.isSet())
    {
        printf("Configuration not set!\n");
        return;
    }

    std::vector<ByteArray>& currSenders = configuration.getSenders();
    for(int i=0;i<currSenders.size();i++)
    {
        print(&currSenders[i]);
    }
    for(ByteArray& e:configuration.getSenders())
    {
        print(&e);
    }
    std::vector<ByteArray>& currRecvs = configuration.getReceivers();
    for(int i=0;i<currRecvs.size();i++)
    {
        print(&currRecvs[i]);
    }

}

/// adds configuration to the gateway streamIDs if it belongs to the current node
void ConfigurationManager::addConfiguration(const char * dir)
{
    Configuration config;
    config.loadFromFile((char *)dir);
    for(auto receivers:config.getReceivers())
    {
        if(receivers == config.discoverMyMac())
        {
            streamIDs.push_back(config.getStreamIDVal());
            return;
        }
    }
}

void ConfigurationManager::initConfigurations()
{
    streamIDs.clear();
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
    std::sort(streamIDs.begin(), streamIDs.end());
}

int ConfigurationManager::getNumberOfStreams() {
    return (int)streamIDs.size();
}

int ConfigurationManager::getStreamIndex(ByteArray& StreamID)
{
    int index = std::lower_bound(streamIDs.begin(), streamIDs.end(), StreamID) - streamIDs.begin();
    if(index >= (int)streamIDs.size() || streamIDs[index] != StreamID)
        return -1;

    return index;
}