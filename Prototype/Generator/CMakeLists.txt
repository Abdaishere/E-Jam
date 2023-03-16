cmake_minimum_required(VERSION 3.22.1)
project(Generator)

set(COMMON_FILES ../commonHeaders)
include_directories(${COMMON_FILES})
set(CMAKE_CXX_STANDARD 14)

add_executable(Generator main.cpp ${COMMON_FILES}/Configuration.h ${COMMON_FILES}/Byte.h PacketCreator.cpp PacketCreator.h ConfigurationManager.cpp PayloadGenerator.cpp PayloadGenerator.h FrameConstructor.cpp FrameConstructor.h EthernetConstructor.cpp EthernetConstructor.h PacketSender.cpp PacketSender.h  ${COMMON_FILES}/Byte.cpp ${COMMON_FILES}/RNG.cpp ${COMMON_FILES}/StatsManager.cpp ${COMMON_FILES}/Utils.cpp)