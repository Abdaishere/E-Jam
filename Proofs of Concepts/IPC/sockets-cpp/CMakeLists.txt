cmake_minimum_required(VERSION 3.23)
project(SocketsTest)

set(CMAKE_CXX_STANDARD 20)

add_executable(SocketsTest server.cpp client.cpp)
