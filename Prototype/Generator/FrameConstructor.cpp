
#include "FrameConstructor.h"

ByteArray FrameConstructor::getFrame()
{
    return frame;
}

FrameConstructor::FrameConstructor(ByteArray source_address)
{
    this->source_address = source_address;
}
FrameConstructor::FrameConstructor(ByteArray source_address, ByteArray destination_address)
{
    this->source_address = source_address;
    this->destination_address = destination_address;
}

void FrameConstructor::setDestinationAddress(const ByteArray &destinationAddress) {
    destination_address = destinationAddress;
}
