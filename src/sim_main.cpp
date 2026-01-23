#include <iostream>
#include <iomanip>
#include <verilated.h>
#include <verilated_fst_c.h>
#include "Vcpu.h"

const char* alu_op_names[] = {"ADD", "SUB", "AND", "OR", "XOR", "NOP"};
const char* src_a_names[]  = {"RS1"};
const char* src_b_names[]  = {"RS2", "IMM"};

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Vcpu* top = new Vcpu;

    // 波形出力設定
    Verilated::traceEverOn(true);
    VerilatedFstC* tfp = new VerilatedFstC;
    top->trace(tfp, 99);
    tfp->open("waveform.fst");

    // 初期化
    uint64_t main_time = 0;
    top->clk = 0;
    top->rst_n = 0;

    std::cout << "=======================================================================" << std::endl;
    std::cout << "Cycle | Instruction  | Mnemonic | ALU_OP | SrcA | SrcB | RegW | Status" << std::endl;
    std::cout << "------|--------------|----------|--------|------|------|------|--------" << std::endl;

    // シミュレーション（100タイムステップ = 50クロックサイクル）
    while (main_time < 100) {
        // 10クロックサイクル後にリセット解除
        if (main_time > 20) top->rst_n = 1;

        // クロックの反転
        top->clk = !top->clk;
        top->eval();

        // 波形の記録
        tfp->dump(main_time);

        // 立ち上がりエッジでデコード結果を表示
        if (top->clk && top->rst_n) {
            uint32_t instr = top->current_instr;

            // 命令が有効な場合のみ表示
            if (instr != 0) {
                // デコード結果を取得
                uint8_t alu_op = top->alu_op;
                uint8_t src_a_sel = top->src_a_sel;
                uint8_t src_b_sel = top->src_b_sel;
                uint8_t reg_write = top->reg_write;

                // 命令を解析して期待値を設定
                uint8_t opcode = instr & 0x7F;
                uint8_t funct3 = (instr >> 12) & 0x7;
                uint8_t funct7 = (instr >> 25) & 0x7F;

                const char* mnemonic = "UNKNOWN";
                uint8_t expected_alu_op = 5;
                uint8_t expected_src_b = 0;
                uint8_t expected_reg_write = 0;

                if (opcode == 0x33) {  // R-type (OP)
                    expected_src_b = 0;  // SRC_B_RS2
                    expected_reg_write = 1;
                    if (funct7 == 0x00 && funct3 == 0x0) { mnemonic = "ADD"; expected_alu_op = 0; }
                    else if (funct7 == 0x20 && funct3 == 0x0) { mnemonic = "SUB"; expected_alu_op = 1; }
                    else if (funct7 == 0x00 && funct3 == 0x7) { mnemonic = "AND"; expected_alu_op = 2; }
                    else if (funct7 == 0x00 && funct3 == 0x6) { mnemonic = "OR"; expected_alu_op = 3; }
                    else if (funct7 == 0x00 && funct3 == 0x4) { mnemonic = "XOR"; expected_alu_op = 4; }
                } else if (opcode == 0x13) {  // I-type (OP_IMM)
                    expected_src_b = 1;  // SRC_B_IMM
                    expected_reg_write = 1;
                    if (funct3 == 0x0) { mnemonic = "ADDI"; expected_alu_op = 0; }
                    else if (funct3 == 0x7) { mnemonic = "ANDI"; expected_alu_op = 2; }
                    else if (funct3 == 0x6) { mnemonic = "ORI"; expected_alu_op = 3; }
                    else if (funct3 == 0x4) { mnemonic = "XORI"; expected_alu_op = 4; }
                }

                // 検証
                bool passed = (alu_op == expected_alu_op) &&
                             (src_a_sel == 0) &&
                             (src_b_sel == expected_src_b) &&
                             (reg_write == expected_reg_write);

                // 結果を出力
                std::cout << std::setw(5) << std::setfill(' ') << (main_time / 2)
                         << " |  0x" << std::hex << std::setw(8) << std::setfill('0') << instr << " "
                         << std::dec << " | " << std::setw(8) << std::setfill(' ') << std::left << mnemonic
                         << " | " << std::setw(6) << std::left << alu_op_names[alu_op]
                         << " | " << std::setw(4) << std::left << src_a_names[src_a_sel]
                         << " | " << std::setw(4) << std::left << src_b_names[src_b_sel]
                         << " | " << std::setw(4) << std::right << (int)reg_write
                         << " | " << (passed ? " PASS" : " FAIL")
                         << std::endl;
            }
        }

        main_time++;
    }
    std::cout << "=======================================================================" << std::endl;

    tfp->close();
    delete top;
    return 0;
}
