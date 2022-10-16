#include <iostream>
#include <vector>
#include <cstring>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <chrono>

using namespace std;

#define bufferSize 1024
#define FIFO_FILE1 "/tmp/fifo_pipe1"
#define FIFO_FILE2 "/tmp/fifo_pipe2"

int main()
{
    double total = 0;
    auto begin = chrono::high_resolution_clock::now();
    int n = 1e5;
    vector<string> responses;
    for (int i = 0; i < n; i++)
        responses.emplace_back(string(10, 'b'));

    char buffer[bufferSize];

    // create the FIFO if it does not exist with permissions -rw-r-----
    mkfifo(FIFO_FILE1, S_IFIFO | 0640);
    mkfifo(FIFO_FILE2, S_IFIFO | 0640);

    // open the file with read and write modes
    int fd1 = open(FIFO_FILE1, O_RDWR);
    int fd2 = open(FIFO_FILE2, O_RDWR);

    for (auto& response : responses)
    {
        // receive response from the client
        memset(&buffer, 0, sizeof buffer); // clear the buffer
        read(fd1, buffer, sizeof(buffer));
//        cout << "Client requested: " << buffer << endl;

        // send response to the client
        memset(&buffer, 0, sizeof buffer); // clear the buffer
        strcpy(buffer, response.c_str());
        write(fd2, buffer, strlen(buffer));
    }
    // close the file descriptor
    close(fd1);
    close(fd2);

    auto end = chrono::high_resolution_clock::now();
    total += chrono::duration_cast<chrono::duration<double>>(end - begin).count();
    cout << "Total time = " << total * 1000 << endl;
    return 0;
}
