#include <iostream>
#include <iomanip>
#include <verilated.h>
#include <verilated_fst_c.h>
#include "Vcpu.h"

// ANSIカラーコード定義
#define ANSI_GREEN "\033[32m"
#define ANSI_RED   "\033[31m"
#define ANSI_RESET "\033[0m"

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Vcpu* top = new Vcpu;

    Verilated::traceEverOn(true);
    VerilatedFstC* tfp = new VerilatedFstC;
    top->trace(tfp, 99);
    tfp->open("waveform.fst");

    uint64_t main_time = 0;
    top->clk = 0;
    top->rst_n = 0;
    top->eval();

    int total_tests = 0, passed_tests = 0;

    // ヘッダー部分の出力
    std::cout << "\n==========================================================================================================================" << std::endl;
    std::cout << "Cycle |  PC  | Instruction  | Mnemonic | rd  | rs1 | rs2/imm |   ALU_A    |   ALU_B    |   Result   |  Expected  | Status" << std::endl;
    std::cout << "------|------|--------------|----------|-----| ----|---------|------------|------------|------------|------------|--------" << std::endl;

    // シミュレーション
    while (main_time < 200) {
        if (main_time > 20) top->rst_n = 1;
        top->clk = !top->clk;
        top->eval();
        tfp->dump(main_time);

        if (top->clk && top->rst_n) {
            uint32_t instr = top->current_instr;
            if (instr != 0) {
                total_tests++;

                // デコード処理（表示用）
                uint32_t pc        = top->pc_out;
                uint32_t alu_in_a  = top->alu_in_a_out;
                uint32_t alu_in_b  = top->alu_in_b_out;
                uint32_t alu_result= top->alu_result_out;
                uint32_t rs1_data  = top->rs1_data_out;
                uint32_t rs2_data  = top->rs2_data_out;

                uint8_t opcode = instr & 0x7F;
                uint8_t rd     = (instr >> 7) & 0x1F;
                uint8_t funct3 = (instr >> 12) & 0x7;
                uint8_t rs1    = (instr >> 15) & 0x1F;
                uint8_t rs2    = (instr >> 20) & 0x1F;
                uint8_t funct7 = (instr >> 25) & 0x7F;
                int32_t imm_i  = (int32_t)(instr & 0xFFF00000) >> 20;

                const char* mnemonic = "UNKNOWN";
                uint32_t expected = 0;
                bool is_r_type = false;

                // 期待値計算ロジック
                if (opcode == 0x33) {
                    is_r_type = true;
                    if      (funct7 == 0x00 && funct3 == 0x0) { mnemonic = "ADD";  expected = rs1_data + rs2_data; }
                    else if (funct7 == 0x20 && funct3 == 0x0) { mnemonic = "SUB";  expected = rs1_data - rs2_data; }
                    else if (funct7 == 0x00 && funct3 == 0x7) { mnemonic = "AND";  expected = rs1_data & rs2_data; }
                    else if (funct7 == 0x00 && funct3 == 0x6) { mnemonic = "OR";   expected = rs1_data | rs2_data; }
                    else if (funct7 == 0x00 && funct3 == 0x4) { mnemonic = "XOR";  expected = rs1_data ^ rs2_data; }
                } else if (opcode == 0x13) {
                    if      (funct3 == 0x0) { mnemonic = "ADDI"; expected = rs1_data + imm_i; }
                    else if (funct3 == 0x7) { mnemonic = "ANDI"; expected = rs1_data & (uint32_t)imm_i; }
                    else if (funct3 == 0x6) { mnemonic = "ORI";  expected = rs1_data | (uint32_t)imm_i; }
                    else if (funct3 == 0x4) { mnemonic = "XORI"; expected = rs1_data ^ (uint32_t)imm_i; }
                }

                bool passed = (alu_result == expected);
                if (passed) passed_tests++;

                // 各行の出力
                std::cout << "   " << std::setw(2) << std::setfill(' ') << std::dec << (main_time / 2)
                         << " | 0x" << std::hex << std::setw(2) << std::setfill('0') << pc
                         << " |  0x" << std::setw(8) << instr << std::dec << " "
                         << " |   " << std::setw(6) << std::setfill(' ') << std::left << mnemonic
                         << " | x" << std::setw(2) << std::right << (int)rd
                         << " | x" << std::setw(2) << (int)rs1 << " | ";

                if (is_r_type) {
                    std::cout << std::setw(6) << std::right << ("x" + std::to_string((int)rs2)) << " ";
                } else {
                    std::cout << std::setw(6) << std::right << imm_i << " ";
                }

                std::cout << " | 0x" << std::hex << std::setw(8) << std::setfill('0') << alu_in_a
                          << " | 0x" << std::setw(8) << alu_in_b
                          << " | 0x" << std::setw(8) << alu_result
                          << " | 0x" << std::setw(8) << expected << std::dec
                          << " |  " << (passed ? ANSI_GREEN "PASS" ANSI_RESET : ANSI_RED "FAIL" ANSI_RESET)
                          << std::endl;
            }
        }
        main_time++;
    }

    std::cout << "==========================================================================================================================" << std::endl;
    std::cout << "Result: "
              << (passed_tests == total_tests ? ANSI_GREEN : ANSI_RED)
              << passed_tests << "/" << total_tests << " tests passed"
              << ANSI_RESET << std::endl;
    std::cout << std::endl;

    tfp->close();
    delete top;
    return (passed_tests == total_tests) ? 0 : 1;
}
