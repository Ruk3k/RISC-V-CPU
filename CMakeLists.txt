cmake_minimum_required(VERSION 3.12)
project(my_riskv_cpu)

cmake_policy(SET CMP0144 NEW)
find_package(Verilator REQUIRED)

add_executable(assembler src/assembler.cpp)

add_custom_command(
    OUTPUT ${CMAKE_BINARY_DIR}/src/program.hex
    COMMAND assembler
    DEPENDS assembler ${CMAKE_SOURCE_DIR}/src/program.asm
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/src
    COMMENT "Assembling program.asm into program.hex..."
)

add_custom_target(generate_hex ALL DEPENDS ${CMAKE_BINARY_DIR}/src/program.hex)

add_executable(Vcpu
    src/sim_main.cpp
    ${VERILATOR_ROOT}/include/verilated_vcd_c.cpp
)

verilate(Vcpu
    SOURCES src/cpu.v
    TOP_MODULE cpu
    TRACE
)

# Ensure Vcpu depends on hex file generation
add_dependencies(Vcpu generate_hex)

target_include_directories(Vcpu PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
