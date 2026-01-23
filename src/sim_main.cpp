#include <iostream>
#include <iomanip>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vcpu.h"

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Vcpu* top = new Vcpu;

    // 波形出力設定
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("waveform.vcd");

    // 初期化
    uint64_t main_time = 0;
    top->clk = 0;
    top->rst_n = 0;

    std::cout << std::endl << "Result" << std::endl
              << "-----------------------------" << std::endl;

    // シミュレーション（50タイムステップ = 25クロックサイクル）
    while (main_time < 50) {

        // タイムステップ10まではリセット（5クロックサイクル）
        if (main_time > 10) top->rst_n = 1;

        // クロックの反転
        top->clk = !top->clk;
        top->eval();

        // 波形の記録
        tfp->dump(main_time);

        // フェッチした機械語命令を出力
        if (top->clk) {
            std::cout << "Time: " << std::setw(3) << std::setfill('0') << main_time
                      << " | Instr: 0x" << std::hex << std::setw(8) << std::setfill('0') << top->current_instr
                      << std::dec << std::endl;
        }
        main_time++;
    }

    std::cout << "-----------------------------" << std::endl << std::endl;

    tfp->close();
    delete top;
    return 0;
}
