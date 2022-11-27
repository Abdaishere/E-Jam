//
// Created by khaled on 11/27/22.
//

#ifndef GENERATOR_STREAMDETAILS_H
#define GENERATOR_STREAMDETAILS_H


#include "Configuration.h"

class StreamDetails
{
private:
    Configuration configuration;

public:
    const Configuration &getConfiguration() const;

    void setConfiguration(const Configuration &configuration);

};


#endif //GENERATOR_STREAMDETAILS_H
