#ifndef FRAMVERIFIER_H
#define FRAMVERIFIER_H

#include "streamsManager.h"
#include "ErrorHandler.h"
#include <memory>
//singleton
class FrameVerifier
{
public:

    //singleton class
    FrameVerifier(Configuration configuration);
    //parameters pointer to byteArray, start index, end index of payload
    bool verifiy(std::shared_ptr<ByteArray>, int, int);
private:
    Configuration configuration;
    //define accepted macAddr and senders
        std::shared_ptr<std::vector<ByteArray>> acceptedSenders;
//        #define acceptedRecv ConfigurationManager::getConfiguration()->getMyMacAddress()
        void updateAcceptedSenders();
        std::shared_ptr<ByteArray> calculateCRC(std::shared_ptr<ByteArray>,int,int);
};

#endif // FRAMVERIFIER_H
