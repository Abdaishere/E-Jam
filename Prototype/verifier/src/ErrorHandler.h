#ifndef ERRORHANDLER_H
#define ERRORHANDLER_H


#include <queue>
#include <vector>
#include "Byte.h"
#include "time.h"

//supported errors
enum ErrorType
{
    DATAGRAM, SEGMENT, PAYLOAD,
    SOURCE_MAC, DESTINATION_MAC, CRC
};

struct ErrorInfo
{
    ByteArray* senderMac;
    ByteArray* recvMac;
    std::vector<ErrorType> errorTypes;
    time_t firstErrorTime;

    ErrorInfo(ByteArray* packet)
    {
        firstErrorTime = time(NULL);
        senderMac = new ByteArray(6, 0);
        senderMac->write(*packet, 0, 5);
        recvMac = new ByteArray(6, 0);
        recvMac->write(*packet, 6, 11);
    }

    void addError(ErrorType error)
    {
        errorTypes.push_back(error);
    }

    ~ErrorInfo()
    {
        delete senderMac, recvMac;
    }

};


//singleton
class ErrorHandler
{
    public:
        //current packet error info
        ErrorInfo* packetErrorInfo;
        static ErrorHandler* getInstance();
        void logError();
        void sendErrors(); //todo
    private:
        ErrorHandler();
        static ErrorHandler* instance;
        std::queue<ErrorInfo*> errors;
};

#endif // ERRORHANDLER_H
