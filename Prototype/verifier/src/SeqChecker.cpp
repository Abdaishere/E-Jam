//
// Created by mohamed on 2/14/23.
//

#include <cassert>
#include "SeqChecker.h"

void SeqChecker::receive(unsigned long long int seqNum) {
    if(seqNum == expectedNext)
    {
        expectedNext++;
        OOO += std::lower_bound(wait.begin(), wait.end(), seqNum) - wait.begin();
        return;
    }

    if(seqNum > expectedNext)
    {
        for(long long i=expectedNext; i<seqNum; i++)
        {
            wait.push_back(i++);
            missing++;
        }
        expectedNext = seqNum++;
        return;
    }

    if(seqNum < expectedNext)
    {
        assert(std::lower_bound(wait.begin(), wait.end(), seqNum) != wait.end());
        wait.erase(std::lower_bound(wait.begin(), wait.end(),seqNum));
        missing--;
    }
}
