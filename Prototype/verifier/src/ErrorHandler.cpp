#include "ErrorHandler.h"

ErrorHandler::ErrorHandler()
{
    //ctor
}

//initialize the pointer
ErrorHandler* ErrorHandler::instance = nullptr;

//get instance function
ErrorHandler* ErrorHandler::getInstance()
{
    if(instance == nullptr)
    {
        instance = new ErrorHandler();
    }
    return instance;
}


void ErrorHandler::logError()
{
    if(packetErrorInfo) errors.push(packetErrorInfo);
    packetErrorInfo = nullptr;
}

void ErrorHandler::sendErrors()
{
    //todo
}
