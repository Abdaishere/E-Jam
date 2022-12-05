#include <iostream>
#include <queue>
#include "src/Byte.h"
#include "src/FramVerifier.h"

using namespace std;
int main()
{

    auto ret = ConfigurationManager::getConfiguration()->getSenders();
    ret.push_back(ByteArray("abv", 3, 0));
    cout<<ret[0][2];

    return 0;
}
