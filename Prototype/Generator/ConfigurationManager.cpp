//
// Created by khaled on 12/3/22.
//

#include "ConfigurationManager.h"
Configuration* ConfigurationManager::configuration = nullptr;

Configuration* ConfigurationManager::getConfiguration()
{
    if(configuration == nullptr)
        configuration =  new Configuration();

    return configuration;
}

void ConfigurationManager::loadConfiguration(ByteArray dir)
{
    // TODO actually load from file

    //For the prototype, we will return the default
    configuration = new Configuration();
}
