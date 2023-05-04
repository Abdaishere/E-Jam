cmake_minimum_required(VERSION 3.26)
project(StatsManagerTester)

set(CMAKE_CXX_STANDARD 17)
set(COMMON_FILES ../commonHeaders)
include_directories(${COMMON_FILES})
add_executable(StatsManagerTester main.cpp ${COMMON_FILES}/StatsManager.h ${COMMON_FILES}/Byte.cpp ${COMMON_FILES}/StatsManager.cpp ${COMMON_FILES}/Utils.cpp ${COMMON_FILES}/ConfigurationManager.h ${COMMON_FILES}/ConfigurationManager.cpp)
