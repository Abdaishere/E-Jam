#include "PacketSender.h"
#include <iostream>
#include <cstring>
#include <vector>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <chrono>
using namespace std;

void PacketSender::openPipes()
{
    for (int i = 0; i < MAX_PROCESSES; i++)
    {
        mkfifo(FIFO_FILE + to_string(i), S_IFIFO | 0640);
        fd[i] = open((FIFO_FILE + to_string(i)).c_str(), O_RDWR);
    }
}

void PacketSender::closePipes()
{
    for (int i = 0; i < MAX_PROCESSES; i++)
        close(fd[i]);
}

void PacketSender::receivePayload(Payload payload, int process)
{
    memset(&buffer, 0, sizeof buffer); // clear the buffer
    read(fd[process], buffer, sizeof(buffer));
    payloads[process].push(buffer);
}

vector<Payload> PacketSender::roundRubin()
{
    vector<Payload> order;
    auto endTest = std::chrono::system_clock::now(); + 5min;
    do {
        for (int i = 0; i < MAX_PROCESSES && std::chrono::system_clock::now() < endTest; i++)
        {
            while (payloads[i].empty() && std::chrono::system_clock::now() < endTest);
            if (!payloads[i].empty())
            {
                order.push_back(payloads[i].front());
                payloads[i].pop();
            }
        }
    } while (std::chrono::system_clock::now() < endTest);
    return order;
}

void PacketSender::sendToSwitch()
{
    int n = stoi(argv[1]);
    cout << "n = " << n << endl;

    auto startTest = std::chrono::system_clock::now();
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

    int bufferSize = n + 5;
    char buffer[bufferSize];

    string response = string(n, 'b');

    while (true)
    {
        // receive request from the client
        int receivedSize = 0;
        string request;
        while (receivedSize < n)
        {
            memset(&buffer, 0, sizeof(buffer)); // clear the buffer
            receivedSize += recv(server_fd, (char*)&buffer, bufferSize, 0);
            request += buffer;
            if (request == "exit")
                break;
        }
//        cout << "Client requested: " << request << endl;
//        cout << request.length() << endl;

        if (request == "exit")
            break;

        // send response to the client
        string message = response;
        size_t sentSize = 0;
        while (sentSize < n)
        {
            memset(buffer, 0, sizeof(buffer)); // clear the buffer
            strcpy(buffer, message.c_str());
            int cur = send(server_fd, (char*)&buffer, strlen(buffer), 0);
            sentSize += cur;
            if (sentSize == message.length())
                message = "";
            else
                message = message.substr(sentSize);
        }

        counter++;
    }

    // closing the connected socket
    close(server_fd);

    // closing the listening socket
    shutdown(sock, SHUT_RDWR);

    auto endTest = std::chrono::system_clock::now();
    long long elapsedTime = (long long)(chrono::duration_cast<chrono::milliseconds>(endTest - startTest).count());
    cout << "Total time = " << elapsedTime << endl;
    cout << "Sent responses = " << counter << endl;
    return 0;
}