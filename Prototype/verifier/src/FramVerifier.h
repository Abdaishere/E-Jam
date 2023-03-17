#ifndef FRAMVERIFIER_H
#define FRAMVERIFIER_H

#include "ConfigurationManager.h"
#include "ErrorHandler.h"
#include <memory>
//singleton
class FrameVerifier
{
    public:
        //parameters pointer to byteArray, start index, end index of payload
        bool verifiy(std::shared_ptr<ByteArray>, int, int);
        static std::shared_ptr<FrameVerifier> getInstance();
    private:
        static std::shared_ptr<FrameVerifier> instance;
        //singleton class
        FrameVerifier();
        //define accepted macAddr and senders
        std::shared_ptr<std::vector<ByteArray>> acceptedSenders;
        #define acceptedRecv ConfigurationManager::getConfiguration()->getMyMacAddress()
        void updateAcceptedSenders();
        std::shared_ptr<ByteArray> calculateCRC(std::shared_ptr<ByteArray>,int,int);
};

#endif // FRAMVERIFIER_H
