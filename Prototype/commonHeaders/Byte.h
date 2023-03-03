#ifndef BYTE_H
#define BYTE_H

#include <iostream>
typedef std::basic_string<unsigned char> ByteArray;

extern void print(ByteArray* ptr);

extern void printChars(ByteArray* ptr);

#endif