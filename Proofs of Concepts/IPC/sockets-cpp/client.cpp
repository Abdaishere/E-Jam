#include <vector>
#include <iostream>
#include <arpa/inet.h>
#include <cstdio>
#include <cstring>
#include <sys/socket.h>
#include <unistd.h>
#include <chrono>
using namespace std;

#define PORT 5000

int main()
{
    auto begin = chrono::high_resolution_clock::now();
    vector<string> requests;
    int n = 1e7;
    for (int i = 0; i < n; i++)
        requests.emplace_back(string(10, 'b'));

    // create the socket file descriptor
    int sock = socket(AF_INET /* IP v4 */, SOCK_STREAM /* TCP */, 0);
    if (sock == -1)
    {
        perror("Socket creation error");
        exit(EXIT_FAILURE);
    }

    // construct the server address
    struct sockaddr_in server_addr {};
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(PORT);

    // convert ip from text to binary and put it in sin_addr field
    if (inet_pton(AF_INET, "127.0.0.1", &server_addr.sin_addr) <= 0)
    {
        perror("Invalid address");
        exit(EXIT_FAILURE);
    }

    // client connects with the server
    int client_fd = connect(sock, (struct sockaddr*)&server_addr, sizeof(server_addr));
    if (client_fd < 0)
    {
        perror("Connection Failed");
        exit(EXIT_FAILURE);
    }

    int bufferSize = 1024;
    char buffer[bufferSize];

    for (auto& request : requests)
    {
        // send request to the server
        memset(buffer, 0, sizeof(buffer)); // clear the buffer
        strcpy(buffer, request.c_str());
        send(sock, (char*)&buffer, strlen(buffer), 0);

        // receive buffer from the server
        memset(&buffer, 0, sizeof(buffer)); // clear the buffer
        recv(sock, (char*)&buffer, bufferSize, 0);
//        cout << "Server responded: " << buffer << endl;
    }

    // closing the connected socket
    close(client_fd);

    auto end = chrono::high_resolution_clock::now();
    cout << "Total time = " << chrono::duration_cast<chrono::duration<double>>(end - begin).count() * 1000 << endl;
    return 0;
}
