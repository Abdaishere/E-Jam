#include <iostream>
#include <queue>
#include <thread>
#include "src/PacketUnpacker.h"
#include "src/ConfigurationManager.h"

using namespace std;

void read(PacketUnpacker* pu)
{
    while(true)
    {
//        pu->readPacket();
    }
}

void verify(PacketUnpacker* pu)
{
    while(true)
    {
//        pu->verifiyPacket();
    }
}

std::string exec(const char* cmd)
{
    char buffer[128];
    std::string result = "";
    FILE* pipe = popen(cmd, "r");
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

int main(int argc, char** argv)
{
    int verID = 0;
    if (argc > 1)
    {
        verID = std::stoi(argv[1]);
        printf("%d\n", verID);
    }
    ConfigurationManager::initConfigurations();
    return 0;
    PacketUnpacker* pu = new PacketUnpacker;


    std::thread reader(read, pu);
    std::thread verifier(verify, pu);

    reader.join();
    verifier.join();


    return 0;
}
