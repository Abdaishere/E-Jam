cmake_minimum_required(VERSION 3.23.2)
project(verifier)

set(COMMON_FILES ../commonHeaders)
include_directories(${COMMON_FILES})
set(CMAKE_CXX_STANDARD 14)

add_executable(verifier main.cpp  ${COMMON_FILES}/Byte.h src/ConfigurationManager.cpp ${COMMON_FILES}/Configuration.h src/ConfigurationManager.h src/DatagramVerifier.cpp src/DatagramVerifier.h src/ErrorHandler.cpp src/ErrorHandler.h src/FramVerifier.cpp src/FramVerifier.h src/PacketUnpacker.cpp src/PacketUnpacker.h src/PayloadVerifier.cpp src/PayloadVerifier.h src/SegmentVerifier.cpp src/SegmentVerifier.h src/PacketReceiver.h src/PacketReceiver.cpp ${COMMON_FILES}/UsernameGetter.h ${COMMON_FILES}/UsernameGetter.cpp src/StatsManager.cpp src/StatsManager.h)
