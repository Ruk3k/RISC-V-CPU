cmake_minimum_required(VERSION 3.12)
project(my_riskv_cpu)

cmake_policy(SET CMP0144 NEW)
find_package(Verilator REQUIRED)

add_executable(Vcpu
    src/sim_main.cpp
    ${VERILATOR_ROOT}/include/verilated_vcd_c.cpp
)

verilate(Vcpu
    SOURCES src/cpu.v
    TOP_MODULE cpu
    TRACE
)

target_include_directories(Vcpu PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
