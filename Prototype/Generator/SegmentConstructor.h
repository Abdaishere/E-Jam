#ifndef GENERATOR_SEGMENTCONSTRUCTOR_H
#define GENERATOR_SEGMENTCONSTRUCTOR_H

class SegmentConstructor
{
private:
    int protocol;
    char* segment;
    char* payload;
public:
    SegmentConstructor(const char* payload, int protocol){};
    void constructSegment();
};


#endif //GENERATOR_SEGMENTCONSTRUCTOR_H
