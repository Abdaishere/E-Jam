cmake_minimum_required(VERSION 3.23)
project(posixTest)

set(CMAKE_CXX_STANDARD 20)

add_executable(posixTest main.cpp client.cpp server.cpp)
