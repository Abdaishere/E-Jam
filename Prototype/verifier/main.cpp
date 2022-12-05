#include <iostream>
#include <queue>
#include "src/Byte.h"

using namespace std;
int main()
{
    ByteArray a("abc", 3, 0);
    std::queue<ByteArray*> que;
    que.push(&a);
    que.front()->at(0, 'b');
    que.front()->print();
    a.print();


    return 0;
}
