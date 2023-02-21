cmake_minimum_required(VERSION 3.22.1)
project(Gateway)

set(CMAKE_CXX_STANDARD 14)
include_directories(../commonHeaders)
add_executable(Gateway main.cpp PacketSender.cpp PacketSender.h PacketReceiver.cpp PacketReceiver.h)
