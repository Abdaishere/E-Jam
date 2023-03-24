//
// Created by mohamedelhagry on 3/13/23.
//

#ifndef GENERATOR_UTILS_H
#define GENERATOR_UTILS_H

#include "Byte.h"
#include <vector>
#include <sstream>

ByteArray convertLLToStr(unsigned long long number);
//split string in vector based on specific delimeter
std::vector<std::string> splitString(const std::string& s, char delim);
int convertStreamID(char* strmID);
std::string exec(const char * command);


#endif //GENERATOR_UTILS_H
