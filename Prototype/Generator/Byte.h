//
// Created by mohamedelhagry on 12/2/22.
//

#ifndef GENERATOR_BYTE_H
#define GENERATOR_BYTE_H

#include <cstdio>

struct ByteArray
{
    unsigned char * bytes;
    int length, writePointer;

    ByteArray ()
    {
        bytes = nullptr;
        length = writePointer = 0;
    }

    ByteArray(int len) {
        bytes = new unsigned char[len];
        writePointer = 0;
        length = len;
    }

    void reset(int len)
    {
        writePointer = 0;
        length = len;
        bytes = new unsigned char[length];
    }

    ByteArray(ByteArray const &other)
    {
        this->length = other.length;
        this->writePointer = other.writePointer;
        this->bytes = new unsigned char[this->length];
        for(int i=0; i<writePointer; i++)
            this->bytes[i] = other.bytes[i];
    }

    ByteArray(const char* bytes, int length)
    {
        this->bytes = new unsigned char[length];
        this->length = length;
        for(int i=0; i<length; i++)
            this->bytes[i] = bytes[i];
        writePointer = length;
    }

    //appends entire bytesToWrite to the current byteArray
    bool write(ByteArray& bytesToWrite)
    {
        if(writePointer + bytesToWrite.length >= length)
            return false;
        for(int i=0; i<bytesToWrite.length; i++)
            bytes[writePointer++] = bytesToWrite.bytes[i];
        return true;
    }

    //appends a sub-range [start, end] of bytesToWrite to the current byteArray
    bool write(ByteArray& bytesToWrite, int start, int end)
    {
        if(writePointer + (end - start + 1) >= length)
            return false;
        for(int i=start; i<=end; i++)
            bytes[writePointer++] = bytesToWrite.bytes[i];
        return true;
    }

    void operator= (ByteArray other)
    {
        this->length = other.length;
        this->writePointer = other.writePointer;
        this->bytes = new unsigned char[this->length];
        for(int i=0; i<writePointer; i++)
            this->bytes[i] = other.bytes[i];
    }

    void print()
    {
        for(int i=0;i<writePointer; i++)
            printf("%c", this->bytes[i]);
        printf("\n");

    }
};

#endif //GENERATOR_BYTE_H
