cmake_minimum_required(VERSION 3.22.1)
project(EJam)

set(COMMON_FILES ../commonHeaders)
set(GENERATOR_DIR ../Generator)
set(VERIFIER_DIR ../verifier)
set(GATEWAY_DIR ../Gateway)
include_directories(${COMMON_FILES})
include_directories(${GENERATOR_DIR})
include_directories(${VERIFIER_DIR})
include_directories(${GATEWAY_DIR})
set(CMAKE_CXX_STANDARD 14)

add_executable(Generator ${GENERATOR_DIR}/main.cpp  ${GENERATOR_DIR}/PacketCreator.cpp ${GENERATOR_DIR}/PayloadGenerator.cpp ${GENERATOR_DIR}/PayloadGenerator.h ${GENERATOR_DIR}/FrameConstructor.cpp ${GENERATOR_DIR}/FrameConstructor.h ${GENERATOR_DIR}/EthernetConstructor.cpp ${GENERATOR_DIR}/EthernetConstructor.h ${GENERATOR_DIR}/PacketSender.cpp ${GENERATOR_DIR}/PacketSender.h  ${COMMON_FILES}/Byte.cpp ${COMMON_FILES}/RNG.cpp ${COMMON_FILES}/StatsManager.cpp ${COMMON_FILES}/Utils.cpp ${COMMON_FILES}/ConfigurationManager.cpp)


add_executable(verifier ${VERIFIER_DIR}/main.cpp ${VERIFIER_DIR}/src/streamsManager.cpp ${COMMON_FILES}/Configuration.h ${VERIFIER_DIR}/src/streamsManager.h ${VERIFIER_DIR}/src/DatagramVerifier.cpp ${VERIFIER_DIR}/src/DatagramVerifier.h ${VERIFIER_DIR}/src/ErrorHandler.cpp ${VERIFIER_DIR}/src/ErrorHandler.h ${VERIFIER_DIR}/src/FramVerifier.cpp ${VERIFIER_DIR}/src/FramVerifier.h ${VERIFIER_DIR}/src/PacketUnpacker.cpp ${VERIFIER_DIR}/src/PacketUnpacker.h ${VERIFIER_DIR}/src/PayloadVerifier.cpp ${VERIFIER_DIR}/src/SegmentVerifier.cpp ${VERIFIER_DIR}/src/PacketReceiver.cpp ${VERIFIER_DIR}/src/SeqChecker.cpp ${COMMON_FILES}/UsernameGetter.cpp ${COMMON_FILES}/StatsManager.cpp ${COMMON_FILES}/ConfigurationManager.cpp ${COMMON_FILES}/Byte.cpp)


add_executable(Gateway ${GATEWAY_DIR}/main.cpp ${GATEWAY_DIR}/PacketSender.cpp ${GATEWAY_DIR}/PacketSender.h ${GATEWAY_DIR}/PacketReceiver.cpp ${GATEWAY_DIR}/PacketReceiver.h)
