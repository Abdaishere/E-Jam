#include "ConfigurationManager.h"
std::shared_ptr<Configuration> ConfigurationManager::configuration = nullptr;

std::shared_ptr<Configuration> ConfigurationManager::getConfiguration(char* path)
{
    if(configuration == nullptr)
    {
        configuration.reset(new Configuration());
    }
    configuration->loadFromFile(path);

    return configuration;
}
std::shared_ptr<Configuration> ConfigurationManager::getConfiguration()
{
    return configuration;
}
//for testing that we read the configuration correctly
void ConfigurationManager::run()
{
    if(configuration == nullptr)
    {
        printf("Configuration not set!\n");
        return;
    }
    std::vector<ByteArray>& currSenders = configuration->getSenders();
    for(int i=0;i<currSenders.size();i++)
    {
        print(&currSenders[i]);
    }/*
    for(ByteArray& e:configuration->getSenders())
    {
        print(&e);
    }*/
    std::vector<ByteArray>& currRecvs = configuration->getReceivers();
    for(int i=0;i<currRecvs.size();i++)
    {
        print(&currRecvs[i]);
    }
}
