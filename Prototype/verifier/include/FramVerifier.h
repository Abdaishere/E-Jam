#ifndef FRAMVERIFIER_H
#define FRAMVERIFIER_H

#include "ConfigurationManager.h"

class FrameVerifier
{
    public:
        FrameVerifier(ByteArray);
        void setFrame(ByteArray);
    private:
        //define accepted macAddr and senders
        #define acceptedSenders ConfigurationManager::getConfiguration()->getSenders()
        #define acceptedRecv ConfigurationManager::getConfiguration()->getMyMacAddress()
        ByteArray frame;
        bool verifiy();
};

#endif // FRAMVERIFIER_H
