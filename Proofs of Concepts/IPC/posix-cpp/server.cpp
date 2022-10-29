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

int main()
{
    auto startTest = chrono::high_resolution_clock::now();
    long long counter = 0;

    // process id of server
    int pid = getpid();

    // key value of shared memory
    int key = 12345;

    // shared memory create
    int shmid = shmget(key, sizeof(struct memory), IPC_CREAT | 0666);

    // attaching the shared memory
    shmptr = (struct memory*)shmat(shmid, NULL, 0);

    // store the process id of server in shared memory
    shmptr->pid1 = pid;
    shmptr->read = false;
    shmptr->write = true;

    string temp;

    while (strcmp(shmptr->buff, "exit") != 0)
    {
        while (!shmptr->read)
            continue;

        // read from the shared memory
        shmptr->read = false;
        temp = shmptr->buff;
//        cout << "Client sent: " << temp << endl;
        shmptr->write = true;

        counter++;
    }

    shmdt((void*)shmptr);
    shmctl(shmid, IPC_RMID, nullptr);

    auto endTest = chrono::high_resolution_clock::now();
    double elapsedTime = chrono::duration_cast<chrono::duration<double>>(endTest - startTest).count() * 1000;
    cout << "Total time = " << elapsedTime << endl;
    cout << "Received requests = " << counter << endl;
    return 0;
}
