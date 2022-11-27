//
// Created by khaled on 11/27/22.
//

#include "StreamDetails.h"

const Configuration &StreamDetails::getConfiguration() const
{
    return configuration;
}

void StreamDetails::setConfiguration(const Configuration &configuration)
{
    StreamDetails::configuration = configuration;
}
