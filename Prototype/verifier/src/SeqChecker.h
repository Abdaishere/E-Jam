//
// Created by mohamed on 2/14/23.
//

#ifndef VERIFIER_SEQCHECKER_H
#define VERIFIER_SEQCHECKER_H
#include <vector>
#include <deque>
#include "Configuration.h"

const int MaxBuffSize = 300;
const int MaxReordering = 1000;
///out of order packets are packets with s < expNext, so
///reordering metrics supported are reordered packet ratio and reordering extent

class SeqChecker {
private:
    ull expectedNext;
    ull missing;
    //out of order frames, type-P-reordered
    ull reordered;
    //frames that have not yet arrived which have a lower sequence number than frames that have arrived
    std::deque<ull>  reorderingExtents, recSeqNums;
public:
    void receive(ull seqNum);
    SeqChecker()
    {
        expectedNext = 1;
        missing = 0;
        reordered = 0;
        reorderingExtents = std::deque<ull>();
        recSeqNums = std::deque<ull>();
    }
    ull getExpectedNext() const;

    ull getMissing() const;

    ull getReordered() const;

    const std::deque<ull> &getRecSeqNums() const;
};


#endif //VERIFIER_SEQCHECKER_H
