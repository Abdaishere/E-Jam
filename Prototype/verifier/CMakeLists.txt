cmake_minimum_required(VERSION 3.22.1)
project(verifier)

set(COMMON_FILES ../../commonHeaders)
include_directories(${COMMON_FILES})
set(CMAKE_CXX_STANDARD 14)

add_executable(verifier src/main.cpp src/streamsManager.cpp ${COMMON_FILES}/Configuration.h src/streamsManager.h src/DatagramVerifier.cpp src/DatagramVerifier.h src/ErrorHandler.cpp src/ErrorHandler.h src/FramVerifier.cpp src/FramVerifier.h src/PacketUnpacker.cpp src/PacketUnpacker.h src/PayloadVerifier.cpp src/SegmentVerifier.cpp src/PacketReceiver.cpp src/SeqChecker.cpp ${COMMON_FILES}/UsernameGetter.cpp ${COMMON_FILES}/StatsManager.cpp ${COMMON_FILES}/ConfigurationManager.cpp ${COMMON_FILES}/Byte.cpp ${COMMON_FILES}/Utils.h ${COMMON_FILES}/Utils.cpp)