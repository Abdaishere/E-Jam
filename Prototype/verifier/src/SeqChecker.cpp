//
// Created by mohamed on 2/14/23.
//

#include <cassert>
#include "SeqChecker.h"


void SeqChecker::receive(ull seqNum) {
    //packet in order
    if(seqNum >= expectedNext)
    {
        if(seqNum > expectedNext)
        {
            ull discontinuity = seqNum - expectedNext;
            missing += discontinuity;
        }
        expectedNext = seqNum+1;
        // add packet to received packets
        {
            recSeqNums.push_back(seqNum);
            if (recSeqNums.size() > MaxBuffSize)
                recSeqNums.pop_front();
        }
        return;
    }
    //packet reordered
    ++reordered;
    --missing;
    //finding first index i such that seqNum[i] > currSeqNum
    int i = 0;
    for(auto e:recSeqNums)
    {
        if(e > seqNum)
            break;
        ++i;
    }

    reorderingExtents.push_back(recSeqNums.size() - i);
    if(reorderingExtents.size() > MaxReordering)
        reorderingExtents.pop_front();

    recSeqNums.push_back(seqNum);
    if (recSeqNums.size() > MaxBuffSize)
        recSeqNums.pop_front();
}
//for debugging purposes
ull SeqChecker::getExpectedNext() const {
    return expectedNext;
}

ull SeqChecker::getMissing() const {
    return missing;
}

ull SeqChecker::getReordered() const {
    return reordered;
}

const std::deque<ull> &SeqChecker::getRecSeqNums() const {
    return recSeqNums;
}
