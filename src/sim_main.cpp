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

    std::cout << "Starting CPU Debug Simulation..." << std::endl;
    std::cout << "-------------------------------------------------------" << std::endl;
    std::cout << " Cycle |     PC     | Reg |  Value (Hex)  | Value (Dec)" << std::endl;
    std::cout << "-------|------------|-----|---------------|------------" << std::endl;

    for (int cycle = 0; cycle < 10; cycle++) {
        top->clk = 1;
        tick(top, tfp, main_time);

        auto& rf = top->cpu->rf;
        uint32_t pc_val = top->cpu->__PVT__pc;

        std::cout << "  " << std::setw(2) << std::setfill(' ') << cycle << "   | "
                  << "0x" << std::setw(8) << std::hex << std::setfill('0') << pc_val << " | ";

        int target_reg = (cycle < 6) ? (cycle + 1) : 0;
        if (cycle == 5) target_reg = 0;

        std::cout << " x" << std::dec << target_reg << " | "
                  << "  0x" << std::setw(8) << std::hex << std::setfill('0') << rf[target_reg] << "  | "
                  << std::setw(6) << std::dec << std::setfill(' ') << static_cast<int32_t>(rf[target_reg]) << std::endl;

        top->clk = 0;
        tick(top, tfp, main_time);
    }

    tfp->close();
    delete top;
    std::cout << "-------------------------------------------------------" << std::endl;
    std::cout << "Debug finished. Waves saved to waveform.vcd" << std::endl;

    return 0;
}
