#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vcpu.h"
#include "Vcpu_cpu.h"
#include <iostream>
#include <iomanip>

void tick(Vcpu* cpu, VerilatedVcdC* tfp, vluint64_t &time) {
    cpu->eval();
    if (tfp) tfp->dump(time);
    time += 5;
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Vcpu* top = new Vcpu();

    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC();
    top->trace(tfp, 99);
    tfp->open("waveform.vcd");

    vluint64_t main_time = 0;

    top->rst = 1;
    top->clk = 0;
    top->eval();
    top->clk = 1;
    top->eval();

    top->rst = 0;
    top->clk = 0;
    tick(top, tfp, main_time);

    std::cout << std::endl << "Starting CPU Debug Simulation (B-type Branch Test)..." << std::endl;
    std::cout << "===============================================================================================================================" << std::endl;
    std::cout << " Cycle |     PC     | Instruction | Branch? |                                 Register Updates                                 " << std::endl;
    std::cout << "-------|------------|-------------|---------|----------------------------------------------------------------------------------" << std::endl;

    uint32_t prev_pc = 0;
    uint32_t prev_instruction = 0;
    for (int cycle = 0; cycle < 11; cycle++) {
        top->clk = 1;
        tick(top, tfp, main_time);

        auto& rf = top->cpu->rf;
        uint32_t pc_val = top->cpu->__PVT__pc;
        uint32_t instruction = top->cpu->__PVT__instruction;
        uint8_t opcode = instruction & 0x7F;
        uint8_t prev_opcode = prev_instruction & 0x7F;

        // Check if branch was taken (based on PREVIOUS instruction)
        bool branch_taken = (prev_pc != 0) && (pc_val != prev_pc + 4);
        std::string branch_str = (prev_opcode == 0x63) ? (branch_taken ? " TAKEN " : "NOT_TKN") : "   -   ";

        std::cout << "  " << std::setw(2) << std::setfill(' ') << std::dec << cycle << "   | "
                  << "0x" << std::setw(8) << std::hex << std::setfill('0') << pc_val << " | "
                  << " 0x" << std::setw(8) << std::hex << std::setfill('0') << instruction << " | "
                  << std::setw(7) << std::setfill(' ') << branch_str << " | ";

        // Show registers that changed
        std::cout << "x1=" << std::dec << std::setw(3) << static_cast<int32_t>(rf[1]) << " | "
                  << "x2=" << std::setw(3) << static_cast<int32_t>(rf[2]) << " | "
                  << "x3=" << std::setw(3) << static_cast<int32_t>(rf[3]) << " | "
                  << "x4=" << std::setw(3) << static_cast<int32_t>(rf[4]) << " | "
                  << "x5=" << std::setw(3) << static_cast<int32_t>(rf[5]) << " | "
                  << "x6=" << std::setw(3) << static_cast<int32_t>(rf[6]) << " | "
                  << "x7=" << std::setw(3) << static_cast<int32_t>(rf[7]) << " | "
                  << "x8=" << std::setw(3) << static_cast<int32_t>(rf[8]) << " | "
                  << "x9=" << std::setw(3) << static_cast<int32_t>(rf[9]) << " | "
                  << std::endl;

        prev_pc = pc_val;
        prev_instruction = instruction;
        top->clk = 0;
        tick(top, tfp, main_time);
    }

    std::cout << "===============================================================================================================================" << std::endl;

    tfp->close();
    delete top;

    std::cout << "Debug finished. Waves saved to waveform.vcd" << std::endl << std::endl;

    return 0;
}
