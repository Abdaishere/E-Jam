#include "ConfigurationManager.h"

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
    }/*
    for(ByteArray& e:configuration->getSenders())
    {
        print(&e);
    }*/
    std::vector<ByteArray>& currRecvs = configuration.getReceivers();
    for(int i=0;i<currRecvs.size();i++)
    {
        print(&currRecvs[i]);
    }
}
