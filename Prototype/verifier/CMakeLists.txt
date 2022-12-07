cmake_minimum_required(VERSION 3.24)
project(verifier)

set(CMAKE_CXX_STANDARD 14)

add_executable(verifier main.cpp src/Byte.h src/ConfigurationManager.cpp src/Configuration.h src/ConfigurationManager.h src/DatagramVerifier.cpp src/DatagramVerifier.h src/ErrorHandler.cpp src/ErrorHandler.h src/FramVerifier.cpp src/FramVerifier.h src/PacketUnpacker.cpp src/PacketUnpacker.h src/PayloadVerifier.cpp src/PayloadVerifier.h src/SegmentVerifier.cpp src/SegmentVerifier.h)
