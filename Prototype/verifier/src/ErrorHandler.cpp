#include "ErrorHandler.h"

ErrorHandler::ErrorHandler()
{
    //ctor
}

//initialize the pointer
std::shared_ptr<ErrorHandler> ErrorHandler::instance = nullptr;

//get instance function
std::shared_ptr<ErrorHandler> ErrorHandler::getInstance()
{
    if(instance == nullptr)
    {
        //instance = std::make_shared<ErrorHandler>();
        instance.reset(new ErrorHandler());
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
    //TODO send errors to SysAPI via pipe
    //This function must run in a third thread
    //use pipe named verifier_sysApi_verID
    //pop errors from queue
        //use pipe to send queue.front
}
