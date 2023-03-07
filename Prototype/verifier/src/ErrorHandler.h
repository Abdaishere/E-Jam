#ifndef ERRORHANDLER_H
#define ERRORHANDLER_H


#include <queue>
#include <vector>
#include "../commonHeaders/Byte.h"
#include "time.h"
#include <memory>
#include "../commonHeaders/StatsManager.h"

//supported errors each type corresponds to unique error
enum ErrorType
{
    DATAGRAM,
    SEGMENT,
    PAYLOAD,
    SOURCE_MAC,
    DESTINATION_MAC,
    CRC,
    STREAM_ID
};

struct ErrorInfo
{
    std::shared_ptr<ByteArray> senderMac, recvMac;
    std::vector<ErrorType> errorTypes;
    time_t firstErrorTime;

    ErrorInfo(std::shared_ptr<ByteArray> packet)
    {
        firstErrorTime = time(NULL); //observe the error time
        senderMac = std::make_shared<ByteArray>(6, 'a');
        //append packet[0:5] into sendermac
        senderMac->append(*packet, 0, 6);
        recvMac = std::make_shared<ByteArray>(6, 'a');
        recvMac->append(*packet, 6, 6);
    }

    //add new error to current errors
    void addError(ErrorType error)
    {
        //Signal error detection
        std::shared_ptr<StatsManager> statsManager = StatsManager::getInstance();
        statsManager->increaseNumErrors();
        //printf("%d", error);
        errorTypes.push_back(error); 
    }

    ~ErrorInfo()
    {
        //delete senderMac, recvMac;
    }

};


//singleton
class ErrorHandler
{
    public:
        //current packet error info
        std::shared_ptr<ErrorInfo> packetErrorInfo;
        static std::shared_ptr<ErrorHandler> getInstance();
        void logError();
        void sendErrors();
    private:
        ErrorHandler();
        static std::shared_ptr<ErrorHandler> instance;
        std::queue<std::shared_ptr<ErrorInfo>> errors;
};

#endif // ERRORHANDLER_H
