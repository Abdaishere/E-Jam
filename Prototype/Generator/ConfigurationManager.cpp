//
// Created by khaled on 12/3/22.
//

#include "ConfigurationManager.h"
Configuration* ConfigurationManager::configuration = nullptr;

Configuration* ConfigurationManager::getConfiguration(char* path)
{
    if(configuration == nullptr)
        configuration =  new Configuration();

    configuration->loadFromFile(path);
    configuration->Mac12toMac6();
    return configuration;
}
Configuration* ConfigurationManager::getConfiguration()
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
    for(auto& e:configuration->getSenders())
    {
        e.print();
    }
    for(auto& e:configuration->getReceivers())
    {
        e.print();
    }
}
