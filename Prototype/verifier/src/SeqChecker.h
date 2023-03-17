//
// Created by mohamed on 2/14/23.
//

#ifndef VERIFIER_SEQCHECKER_H
#define VERIFIER_SEQCHECKER_H
#include <vector>

class SeqChecker {
private:
    unsigned long long expectedNext;
    unsigned long long missing;
    unsigned long long OOO; //out of order frames
    //frames that have not yet arrived which have a lower sequence number than frames that have arrived
    std::vector<unsigned long long> wait;

public:
    void receive(unsigned long long int seqNum);
    SeqChecker()
    {
        expectedNext = 0;
        missing = 0;
        OOO = 0;
        wait = std::vector<unsigned long long>();
    }
};


#endif //VERIFIER_SEQCHECKER_H
