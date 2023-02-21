cmake_minimum_required(VERSION 3.23)
project(Gateway)
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pthread")

set(CMAKE_CXX_STANDARD 14)
include_directories(../commonHeaders)
add_executable(Gateway main.cpp PacketSender.cpp PacketSender.h PacketReceiver.cpp PacketReceiver.h)
