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

//split string in vector based on specific delimeter
std::vector<std::string> splitString(const std::string& s, char delim)
{
    std::stringstream raw(s);
    std::string temp;
    std::vector<std::string> arr;
    while(getline(raw, temp, delim))
        arr.push_back(temp);
    return arr;
}

int convertStreamID(char* strmID)
{
    return strmID[0] + (strmID[1] << 8) + (strmID[2] << 16);
}

//execute command in cmd
std::string exec(const char * command)
{
    char buffer[128];
    std::string result = "";
    FILE* pipe = popen(command, "r");
    if (!pipe) throw std::runtime_error("popen() failed!");
    try {
        while (fgets(buffer, sizeof buffer, pipe) != NULL) {
            result += buffer;
        }
    } catch (...) {
        pclose(pipe);
        throw;
    }
    pclose(pipe);
    return result;
}
