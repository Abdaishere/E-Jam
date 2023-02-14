#include <bits/stdc++.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <unistd.h>
using namespace std;

struct memory {
    char buff[300000];
    int status, pid1, pid2;
    bool read, write;
};

struct memory* shmptr;

int main(int argc, char* argv[])
{
    int n = stoi(argv[1]);
    cout << "n = " << n << endl;

    auto startTest = chrono::high_resolution_clock::now();
    auto endTest = startTest + 5min;

    long long counter = 0;

    // process id of client
    int pid = getpid();

    // key value of shared memory
    int key = 12345;

    // shared memory create
    int shmid = shmget(key, sizeof(struct memory), IPC_CREAT | 0666);

    // attaching the shared memory
    shmptr = (struct memory*)shmat(shmid, nullptr, 0);

    // store the process id of client in shared memory
    shmptr->pid2 = pid;
    shmptr->read = false;
    shmptr->write = true;

    string request = string(n, 'a');

    do {
        while (!shmptr->write)
            continue;

        // write to the shared memory
        shmptr->write = false;
        strcpy(shmptr->buff, request.c_str());
        shmptr->read = true;

        counter++;

    } while (std::chrono::system_clock::now() < endTest);

    strcpy(shmptr->buff, "exit");

    shmdt((void*)shmptr);

    double elapsedTime = chrono::duration_cast<chrono::duration<double>>(endTest - startTest).count() * 1000;
    cout << "Total time = " << elapsedTime << endl;
    cout << "Sent requests = " << counter << endl;
    return 0;
}
