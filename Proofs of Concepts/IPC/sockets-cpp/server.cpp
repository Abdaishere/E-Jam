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
    double total = 0;
    auto begin = chrono::high_resolution_clock::now();
    vector<string> responses;
    int n = 1e7;
    for (int i = 0; i < n; i++)
        responses.emplace_back(string(10, 'b'));

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

    auto end = chrono::high_resolution_clock::now();
    total += chrono::duration_cast<chrono::duration<double>>(end - begin).count();

    // accepting the client connection
    int server_fd;
    int addrlen = sizeof(address);
    if ((server_fd = accept(sock, (struct sockaddr*)&address, (socklen_t*)&addrlen)) < 0)
    {
        perror("accept");
        exit(EXIT_FAILURE);
    }

    begin = chrono::high_resolution_clock::now();

    int bufferSize = 1024;
    char buffer[bufferSize];

    for (auto& response : responses)
    {
        // receive request from the client
        memset(&buffer, 0, sizeof(buffer)); // clear the buffer
        recv(server_fd, (char*)&buffer, bufferSize, 0);
//        cout << "Client requested: " << buffer << endl;

        // send response to the client
        memset(&buffer, 0, sizeof(buffer)); //clear the buffer
        strcpy(buffer, response.c_str());
        send(server_fd, (char*)&buffer, strlen(buffer), 0);
    }

    // closing the connected socket
    close(server_fd);

    // closing the listening socket
    shutdown(sock, SHUT_RDWR);

    end = chrono::high_resolution_clock::now();
    total += chrono::duration_cast<chrono::duration<double>>(end - begin).count();
    cout << "Total time = " << total * 1000 << endl;
    return 0;
}
