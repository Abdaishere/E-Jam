cmake_minimum_required(VERSION 3.23.2)
project(Generator)

set(COMMON_FILES ../commonHeaders)
include_directories(${COMMON_FILES})
set(CMAKE_CXX_STANDARD 14)

add_executable(Generator main.cpp ${COMMON_FILES}/Byte.h PacketCreator.cpp PacketCreator.h StreamDetails.cpp StreamDetails.h ConfigurationManager.cpp Configuration.h PayloadGenerator.cpp PayloadGenerator.h SegmentConstructor.cpp SegmentConstructor.h DatagramConstructor.cpp DatagramConstructor.h FrameConstructor.cpp FrameConstructor.h EthernetConstructor.cpp EthernetConstructor.h IPv4.h rawGenerator.h rawGenerator.cpp PacketSender.cpp PacketSender.h  ${COMMON_FILES}/Byte.cpp ${COMMON_FILES}/RNG.cpp )