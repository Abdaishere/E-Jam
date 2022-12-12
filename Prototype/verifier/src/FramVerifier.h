#ifndef FRAMVERIFIER_H
#define FRAMVERIFIER_H

#include "ConfigurationManager.h"
#include "ErrorHandler.h"
//singleton
class FrameVerifier
{
    public:
        //parameters pointer to byteArray, start index, end index of payload
        bool verifiy(ByteArray*, int, int);
        static FrameVerifier* getInstance();
    private:
        static FrameVerifier* instance;
        //singleton class
        FrameVerifier();
        //define accepted macAddr and senders
        std::vector<ByteArray>* acceptedSenders;
        #define acceptedRecv ConfigurationManager::getConfiguration()->getMyMacAddress()
        void updateAcceptedSenders();
};

#endif // FRAMVERIFIER_H
