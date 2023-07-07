cmake_minimum_required(VERSION 3.22.1)
project(Gateway)
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pthread")

set(CMAKE_CXX_STANDARD 14)
set(COMMON_FILES ../commonHeaders)
include_directories(../commonHeaders)
add_executable(Gateway main.cpp PacketSender.cpp PacketReceiver.cpp ${COMMON_FILES}/ConfigurationManager.cpp ${COMMON_FILES}/Utils.cpp ${COMMON_FILES}/Byte.cpp)
