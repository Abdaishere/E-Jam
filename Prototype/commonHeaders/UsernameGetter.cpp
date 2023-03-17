#include "UsernameGetter.h"
//get the username from cmd
std::string UsernameGetter::exec() {
    const char* cmd = "whoami";
    std::array<char, 128> buffer;
    std::string result;
    std::unique_ptr<FILE, decltype(&pclose)> pipe(popen(cmd, "r"), pclose);
    if (!pipe) {
        throw std::runtime_error("popen() failed!");
    }
    while (fgets(buffer.data(), buffer.size(), pipe.get()) != nullptr) {
        result += buffer.data();
        if(result.back() == '\n')
            result.pop_back();
    }
    if(result == "root")
        result = "mohamed"; //hardcoded ###########

    return result;
}