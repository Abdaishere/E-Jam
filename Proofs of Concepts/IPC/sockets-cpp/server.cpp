#include <iostream>
#include <vector>
#include <netinet/in.h>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <sys/socket.h>
#include <unistd.h>
#include <chrono>
using namespace std;

#define PORT 5000

int main()
{
    auto startTest = chrono::high_resolution_clock::now();
    long long counter = 0;

    // create the socket file descriptor
    int sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock == -1)
    {
        perror("socket failed");
        exit(EXIT_FAILURE);
    }

    // forcefully attaching socket to the port
    int opt = 1;
    if (setsockopt(sock, SOL_SOCKET, SO_REUSEADDR | SO_REUSEPORT, &opt, sizeof(opt)))
    {
        perror("setsockopt");
        exit(EXIT_FAILURE);
    }

    // construct the client address
    struct sockaddr_in address {};
    address.sin_family = AF_INET;
    address.sin_port = htons(PORT);
    address.sin_addr.s_addr = INADDR_ANY;   // bind to all interfaces

    // binds the socket to the address and port number
    if (bind(sock, (struct sockaddr*)&address, sizeof(address)) < 0)
    {
        perror("bind failed");
        exit(EXIT_FAILURE);
    }

    // waits for the client to approach the server to make a connection
    if (listen(sock, 3) < 0)
    {
        perror("listen failed");
        exit(EXIT_FAILURE);
    }

    // accepting the client connection
    int server_fd;
    int addrlen = sizeof(address);
    if ((server_fd = accept(sock, (struct sockaddr*)&address, (socklen_t*)&addrlen)) < 0)
    {
        perror("accept");
        exit(EXIT_FAILURE);
    }

    int bufferSize = 1024;
    char buffer[bufferSize];

    string response = string(10, 'b');

    while (true)
    {
        // receive request from the client
        memset(&buffer, 0, sizeof(buffer)); // clear the buffer
        recv(server_fd, (char*)&buffer, bufferSize, 0);
//        cout << "Client requested: " << buffer << endl;

        if (strcmp(buffer, "exit") == 0)
            break;

        // send response to the client
        memset(&buffer, 0, sizeof(buffer)); //clear the buffer
        strcpy(buffer, response.c_str());
        send(server_fd, (char*)&buffer, strlen(buffer), 0);

        counter++;
    }

    // closing the connected socket
    close(server_fd);

    // closing the listening socket
    shutdown(sock, SHUT_RDWR);

    auto endTest = chrono::high_resolution_clock::now();
    double elapsedTime = chrono::duration_cast<chrono::duration<double>>(endTest - startTest).count() * 1000;
    cout << "Total time = " << elapsedTime << endl;
    cout << "Sent responses = " << counter << endl;
    return 0;
}
