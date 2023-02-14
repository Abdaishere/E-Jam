#include <bits/stdc++.h>
#include <arpa/inet.h>
#include <cstdio>
#include <cstring>
#include <sys/socket.h>
#include <unistd.h>
#include <chrono>
using namespace std;

#define PORT 5000

int main(int argc, char* argv[])
{
    int n = stoi(argv[1]);
    cout << "n = " << n << endl;

    auto startTest = std::chrono::system_clock::now();
    auto endTest = startTest + 5min;

    long long counter = 0;

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

    int bufferSize = n + 5;
    char buffer[bufferSize];

    string request = string(n, 'a');

    do {
        // send request to the server
        string message = request;
        size_t sentSize = 0;
        while (sentSize < n)
        {
            memset(buffer, 0, sizeof(buffer)); // clear the buffer
            strcpy(buffer, message.c_str());
            int cur = send(sock, (char*)&buffer, message.length(), 0);
            sentSize += cur;
            if (sentSize == message.length())
                message = "";
            else
                message = message.substr(sentSize);
        }

        // receive buffer from the server
        int receivedSize = 0;
        string response;
        while (receivedSize < n)
        {
            memset(&buffer, 0, sizeof(buffer)); // clear the buffer
            receivedSize += recv(sock, (char*)&buffer, bufferSize, 0);
            response += buffer;
        }
//        cout << "Server responded: " << response << endl;
//        cout << response.length() << endl;

        counter++;

    } while (std::chrono::system_clock::now() < endTest);

    strcpy(buffer, "exit");
    send(sock, (char*)&buffer, strlen(buffer), 0);

    // closing the connected socket
    close(client_fd);

//    long long elapsedTime = chrono::duration_cast<chrono::duration<chrono::milliseconds>>(std::chrono::system_clock::now() - startTest);
    long long elapsedTime = (long long)(chrono::duration_cast<chrono::milliseconds>(endTest - startTest).count());
    cout << "Total time = " << elapsedTime << endl;
    cout << "Sent requests = " << counter << endl;
    return 0;
}
