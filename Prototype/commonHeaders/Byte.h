#ifndef BYTEARRAY_H
#define BYTEARRAY_H

#include <cstdio>

struct ByteArray
{
    unsigned char * bytes;
    int capacity, length, extraBuffer;


    ByteArray(int len=0, int extraBuffer = 10)
    {
        if(len==0)
        {
            bytes = nullptr;
            capacity = length = 0;
        }
        else
        {
            bytes = new unsigned char[len];
            length = 0;
            capacity = len;
        }
        this->extraBuffer = extraBuffer;
    }

    void reset(int len)
    {
        if(len==length)
            return;
        length = 0;
        capacity = len;
        delete[] bytes; //delete before initializing
        bytes = new unsigned char[capacity];
    }

    ByteArray(ByteArray const &other)
    {
        this->capacity = other.capacity;
        this->length = other.length;
        this->bytes = new unsigned char[this->capacity];
        this->extraBuffer = other.extraBuffer;
        for(int i=0; i < length; i++) {
            this->bytes[i] = other.bytes[i];
        }
    }

    ByteArray(const char* bytes, int length, int extraBuffer = 10)
    {
        this->bytes = new unsigned char[length];
        this->capacity = length;
        this->length = length;
        for(int i=0; i<length; i++){ this->bytes[i] = bytes[i]; }
        this->extraBuffer = extraBuffer;
    }

    //appends entire bytesToWrite to the current byteArray
    bool write(ByteArray& bytesToWrite)
    {
        if(length + bytesToWrite.capacity > capacity)
            return false;
        for(int i=0; i<bytesToWrite.capacity; i++)
            bytes[length++] = bytesToWrite.bytes[i];
        return true;
    }

    //appends a sub-range [start, end] of bytesToWrite to the current byteArray
    bool write(ByteArray& bytesToWrite, int start, int end)
    {
        if(length + (end - start + 1) >= capacity)
            return false;
        for(int i=start; i<=end; i++)
            bytes[length++] = bytesToWrite.bytes[i];
        return true;
    }

    void operator= (const ByteArray& other)
    {
        this->capacity = other.capacity;
        this->length = other.length;
        delete[] bytes;
        this->bytes = new unsigned char[this->capacity];
        this->extraBuffer = other.extraBuffer;
        for(int i=0; i < length; i++)
            this->bytes[i] = other.bytes[i];
    }

    unsigned char& operator[] (int idx)
    {
        return bytes[idx];
    }

    void operator+= (const ByteArray& other)
    {
        if(this->capacity >= this->length + other.length)
        {
            int j=0;
            for (int i=length; i < this->length + other.length; i++)
            {
                bytes[i]= other.bytes[j++];
            }
        }
        else
        {
            int newLen = this->length + other.length + extraBuffer;
            unsigned char* newPtr = new unsigned char[newLen];

            for (int i=0; i<this->length; i++)
            {
                newPtr[i]=this->bytes[i];
            }
            this->capacity = newLen;

            int j=0;
            for (int i=length; j < other.length; i++,j++)
            {
                newPtr[i] = other.bytes[j];
            }
            this->length += other.length;
            delete[] bytes;
            this->bytes = newPtr;
        }
    }

    //a.at(5) = 'b';
    unsigned char& at(int idx)
    {
        return bytes[idx];
    }

    void print() const
    {
        for(int i=0; i < length; i++)
        {
            //to avoid seeing whitespaces
            printf("%d ", this->bytes[i]);
//            printf("%c", this->bytes[i]);
        }
        printf("\n");

    }

    void printChars() const
    {
        for(int i=0; i < length; i++)
        {
            printf("%c", this->bytes[i]);
        }
        printf("\n");
    }


    ~ByteArray()
    {
        delete[] bytes;
    }


};

#endif
// BYTEARRAY_H