//
// Created by mohamedelhagry on 3/13/23.
//

#include "Utils.h"
ByteArray convertLLToStr(unsigned long long number) {
    ByteArray result(8,'a');
    int byteMask = (1 << 8)-1;
    for(int i=0; i<8; i++)
        result.at(i) = (char) (number>>(i*8) & byteMask);

    return result;
}