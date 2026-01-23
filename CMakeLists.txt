cmake_minimum_required(VERSION 3.12)
project(riscv_fetch_debug)

# Verilatorパッケージを検索
cmake_policy(SET CMP0144 NEW) # 警告回避のため
find_package(Verilator REQUIRED)

# シミュレーション用プログラムから実行ファイルを生成
add_executable(Vcpu
    src/sim_main.cpp
)

# SystemVerilog ソースを Verilator で C++ に変換
verilate(Vcpu
    SOURCES
        src/cpu_pkg.sv      # CPUパッケージ（最初に配置）
        src/decoder.sv      # デコードユニット
        src/instr_mem.sv    # 命令メモリ
        src/pc_reg.sv       # プログラムカウンタレジスタ
        src/cpu_top.sv      # トップモジュール
    TOP_MODULE cpu_top      # トップモジュール名
    TRACE_FST               # FST波形出力を有効化
    PREFIX Vcpu             # 生成されるC++クラスのプレフィックス
    VERILATOR_ARGS -Wno-CASEINCOMPLETE  # case文の不完全性警告を無効化
)

# Verilatorが生成したヘッダファイルのパスを追加
target_include_directories(Vcpu PRIVATE ${CMAKE_CURRENT_BINARY_DIR})

# アセンブラの実行ファイルを生成
add_executable(assembler
    src/assembler.cpp
)
# program.asmからsrc/program.hexを生成するカスタムコマンド
add_custom_command(
    OUTPUT ${CMAKE_SOURCE_DIR}/src/program.hex
    COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_SOURCE_DIR}/src $<TARGET_FILE:assembler>
    DEPENDS assembler ${CMAKE_SOURCE_DIR}/src/program.asm
    COMMENT "Generating program.hex from program.asm"
    VERBATIM
)

# Vcpuをビルドする前にprogram.hexを生成
add_custom_target(generate_hex ALL
    DEPENDS ${CMAKE_SOURCE_DIR}/src/program.hex
)
add_dependencies(Vcpu generate_hex)
