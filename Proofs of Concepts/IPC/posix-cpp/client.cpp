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
    int n = 1e7;
    vector<string> requests;
    for (int i = 0; i < n; i++)
        requests.emplace_back(string(10, 'a'));
    requests.emplace_back("exit");

    // ftok to generate unique key
    key_t key = ftok("shmfile",65);

    // shmget returns an identifier in shmid
    int shmid = shmget(key, 1024, IPC_CREAT | 0666);

    // shmat to attach to shared memory
    char *str = (char*) shmat(shmid, nullptr, 0);

    for (auto& request : requests)
    {
        strcpy(str, request.c_str());
//        printf("Data written in memory: %s\n", str);
    }

    //detach from shared memory
    shmdt(str);

    auto end = chrono::high_resolution_clock::now();
    cout << "Client time = " << chrono::duration_cast<chrono::duration<double>>(end - begin).count() * 1000 << endl;
    return 0;
}