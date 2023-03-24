cmake_minimum_required(VERSION 3.22.1)
project(Generator)
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pthread")

set(COMMON_FILES ../commonHeaders)
include_directories(${COMMON_FILES})
set(CMAKE_CXX_STANDARD 14)

add_executable(Generator main.cpp  PacketCreator.cpp PayloadGenerator.cpp PayloadGenerator.h FrameConstructor.cpp FrameConstructor.h EthernetConstructor.cpp EthernetConstructor.h PacketSender.cpp PacketSender.h  ${COMMON_FILES}/Byte.cpp ${COMMON_FILES}/RNG.cpp ${COMMON_FILES}/StatsManager.cpp ${COMMON_FILES}/Utils.cpp ${COMMON_FILES}/ConfigurationManager.cpp)