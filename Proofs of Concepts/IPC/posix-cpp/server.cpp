#include <iostream>
#include <vector>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <cstdio>
#include <cstring>
#include <chrono>
using namespace std;

int main()
{
    auto begin = chrono::high_resolution_clock::now();

    // ftok to generate unique key
    key_t key = ftok("shmfile",65);

    // shmget returns an identifier in shmid
    int shmid = shmget(key,1024, IPC_CREAT | 0666);

    // shmat to attach to shared memory
    char *str = (char*) shmat(shmid, nullptr, 0);
    string prev;

    while (strcmp(str, "exit") != 0)
    {
        if (strcmp(str, prev.c_str()) != 0)
        {
//            printf("Data read from memory: %s\n", str);
            prev = str;
        }
    }

    //detach from shared memory
    shmdt(str);

    // destroy the shared memory
    shmctl(shmid, IPC_RMID, nullptr);

    auto end = chrono::high_resolution_clock::now();
    cout << "Server time = " << chrono::duration_cast<chrono::duration<double>>(end - begin).count() * 1000 << endl;
    return 0;
}