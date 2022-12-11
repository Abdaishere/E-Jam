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
    return configuration;
}
Configuration* ConfigurationManager::getConfiguration()
{
    return configuration;
}
