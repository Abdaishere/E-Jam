cmake_minimum_required(VERSION 3.23.2)
project(Generator)

set(CMAKE_CXX_STANDARD 14)

add_executable(Generator main.cpp PacketCreator.cpp PacketCreator.h StreamDetails.cpp StreamDetails.h Configuration.cpp Configuration.h PayloadGenerator.cpp PayloadGenerator.h SegmentConstructor.cpp SegmentConstructor.h DatagramConstructor.cpp DatagramConstructor.h FrameConstructor.cpp FrameConstructor.h EthernetConstructor.cpp EthernetConstructor.h IPv4.h rawGenerator.h rawGenerator.cpp)
