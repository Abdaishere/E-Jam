#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <unistd.h>
#include <cstring>
using namespace std;

int main()
{
    int fileDescriptors[2];
    int n = 100;
    char buffer[n];

    if (pipe(fileDescriptors) == -1)
    {
        perror("pipe");
        exit(1);
    }

    pid_t pid = fork();

    if (pid == 0)
    {
        cout << "Process 2: writing to the pipe\n";
        cin.getline(buffer, 100);
        write(fileDescriptors[1], buffer, strlen(buffer));
    }
    else
    {
        cout << "Process 1: reading from the pipe\n";
        read(fileDescriptors[0], buffer, n);
        cout << "Process 2 said: \"" << buffer << "\"\n";
    }
    return 0;
}