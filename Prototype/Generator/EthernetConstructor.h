
#ifndef GENERATOR_ETHERNETCONSTRUCTOR_H
#define GENERATOR_ETHERNETCONSTRUCTOR_H

#include "Configuration.h"

#include "FrameConstructor.h"
#include "Utils.h"
#include "Byte.h"
class EthernetConstructor : public FrameConstructor
{
private:
    unsigned char pre[8] = {0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAB};
    const static int headerSize = 8 + 6 + 6 + 2 + 4;
    ByteArray preamble;
    //type of network layer protocol or capacity of data
    ByteArray type;
    ByteArray streamID;
    ByteArray payload;
    ByteArray CRC;
    static long long seqNum;
    //may need to insert 12-byte inter-packet gap, not sure

public:
    EthernetConstructor(ByteArray sourceAddress,
                        ByteArray streamID) ;

    void setType(const ByteArray &type);
    void setPayload(const ByteArray &payload);
    void constructFrame();

    ByteArray calculateCRC(std::shared_ptr<ByteArray>);

}; 


#endif //GENERATOR_ETHERNETCONSTRUCTOR_H
