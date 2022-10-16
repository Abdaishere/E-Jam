#include <iostream>
#include <vector>
#include <cstring>
#include <fcntl.h>
#include <unistd.h>
#include <chrono>

using namespace std;

#define bufferSize 1024
#define FIFO_FILE1 "/tmp/fifo_pipe1"
#define FIFO_FILE2 "/tmp/fifo_pipe2"

int main()
{
    auto begin = chrono::high_resolution_clock::now();
    int n = 1e5;
    vector<string> requests;
    for (int i = 0; i < n; i++)
        requests.emplace_back(string(10, 'a'));

    char buffer[bufferSize];

    // open the file with read and write modes
    int fd1 = open(FIFO_FILE1, O_RDWR);
    int fd2 = open(FIFO_FILE2, O_RDWR);

    for (auto& request : requests)
    {
        // send request to the server
        memset(&buffer, 0, sizeof buffer); // clear the buffer
        strcpy(buffer, request.c_str());
        write(fd1, buffer, strlen(buffer));

        // receive response from the server
        memset(&buffer, 0, sizeof buffer); // clear the buffer
        read(fd2, buffer, sizeof(buffer));
//        cout << "Server responded: " << buffer << endl;
    }
    // close the file descriptor
    close(fd1);
    close(fd2);

    auto end = chrono::high_resolution_clock::now();
    cout << "Total time = " << chrono::duration_cast<chrono::duration<double>>(end - begin).count() * 1000 << endl;
    return 0;
}