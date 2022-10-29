#include <iostream>
#include <cstring>
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
    auto endTest = startTest + 5min;

    long long counter = 0;

    int bufferSize = n + 5;
    char buffer[bufferSize];
    string request = string(n, 'a');

    // open the file with read and write modes
    int fd1 = open(FIFO_FILE1, O_RDWR);
    int fd2 = open(FIFO_FILE2, O_RDWR);

    do {
        // send request to the server
        memset(&buffer, 0, sizeof buffer); // clear the buffer
        strcpy(buffer, request.c_str());
        write(fd1, buffer, strlen(buffer));

        // receive response from the server
        memset(&buffer, 0, sizeof buffer); // clear the buffer
        read(fd2, buffer, sizeof(buffer));
//        cout << "Server responded: " << buffer << endl;

        counter++;

    } while (std::chrono::system_clock::now() < endTest);

    strcpy(buffer, "exit");
    write(fd1, buffer, strlen(buffer));

    // close the file descriptor
    close(fd1);
    close(fd2);

    long long elapsedTime = (long long)(chrono::duration_cast<chrono::milliseconds>(endTest - startTest).count());
    cout << "Total time = " << elapsedTime << endl;
    cout << "Sent requests = " << counter << endl;
    return 0;
}