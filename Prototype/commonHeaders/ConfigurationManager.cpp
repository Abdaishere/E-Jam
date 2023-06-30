#include "ConfigurationManager.h"
std::string ConfigurationManager::CONFIG_FOLDER = "etc/EJam";
std::vector<ByteArray>ConfigurationManager::streamIDs = std::vector<ByteArray>();
std::vector<Configuration>ConfigurationManager::configurations = std::vector<Configuration>();
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
            configurations.push_back(config);
            return;
        }
    }
}

void ConfigurationManager::initConfigurations()
{
    streamIDs.clear();
    configurations.clear();
    CONFIG_FOLDER = "";
    CONFIG_FOLDER+= CONFIG_DIR;

    //ensure that the config files are listed in order of their creation time (birth time)
    std::string lsStr = "ls -tr --time=birth";
    std::string dirStr(CONFIG_FOLDER);
    lsStr+=dirStr;

    std::string ls= exec(lsStr.c_str());
    std::vector<std::string> directories = splitString(ls,'\n');
    std::vector<std::string> configFiles;
    //Augment the parent directory
    for(std::string& dir: directories){
        if(dir.substr(0,6) == "config")
            configFiles.push_back(std::string(CONFIG_FOLDER)+"/"+dir);
    }
    for(const std::string& dir: configFiles)
    {
        if(dir.substr(dir.size()-3) == "txt")
            addConfiguration(dir.c_str());
    }
}

int ConfigurationManager::getNumberOfStreams() {
    return (int)streamIDs.size();
}
//verifier ID is the stream ID in the non-sorted list of streams
int ConfigurationManager::getStreamIndex(ByteArray& StreamID)
{
    int index = 0;
    for(const auto& streamID: streamIDs){
        if(streamID == StreamID)
            return index;
        ++index;
    }
    return -1;
}