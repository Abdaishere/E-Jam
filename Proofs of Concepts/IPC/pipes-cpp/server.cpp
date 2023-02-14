#include <iostream>
#include <cstring>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <chrono>

using namespace std;

#define FIFO_FILE1 "/tmp/fifo_pipe1"
#define FIFO_FILE2 "/tmp/fifo_pipe2"

int main(int argc, char* argv[])
{
    int n = stoi(argv[1]);
    cout << "n = " << n << endl;

    auto startTest = std::chrono::system_clock::now();
    long long counter = 0;

    int bufferSize = n + 5;
    char buffer[bufferSize];
    string response = string(n, 'b');

    // create the FIFO if it does not exist with permissions -rw-r-----
    mkfifo(FIFO_FILE1, S_IFIFO | 0640);
    mkfifo(FIFO_FILE2, S_IFIFO | 0640);

    // open the file with read and write modes
    int fd1 = open(FIFO_FILE1, O_RDWR);
    int fd2 = open(FIFO_FILE2, O_RDWR);

    while (true)
    {
        // receive response from the client
        memset(&buffer, 0, sizeof buffer); // clear the buffer
        read(fd1, buffer, sizeof(buffer));
        cout << "Client requested: " << buffer << endl;

        if (strcmp(buffer, "exit") == 0)
            break;

        // send response to the client
        memset(&buffer, 0, sizeof buffer); // clear the buffer
        strcpy(buffer, response.c_str());
        write(fd2, buffer, strlen(buffer));

        counter++;
    }

    // close the file descriptor
    close(fd1);
    close(fd2);

    auto endTest = std::chrono::system_clock::now();
    long long elapsedTime = (long long)(chrono::duration_cast<chrono::milliseconds>(endTest - startTest).count());
    cout << "Total time = " << elapsedTime << endl;
    cout << "Sent responses = " << counter << endl;
    return 0;
}