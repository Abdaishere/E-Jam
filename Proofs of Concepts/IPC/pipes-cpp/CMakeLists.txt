cmake_minimum_required(VERSION 3.23)
project(PipesTest)

set(CMAKE_CXX_STANDARD 20)

add_executable(PipesTest main.cpp server.cpp client.cpp)
