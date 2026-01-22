# My-RISC-V-CPU Project

自作の **Verilog HDL** による RISC-V プロセッサの開発と、そのシミュレーション環境の構築プロジェクトです。

## 🛠 開発環境 (Development Environment)

Docker でコンテナ化して実装しています。

* **OS**: Ubuntu
* **Logic Synthesis & Sim**: **Verilator** (Verilog HDL を C++ へ変換するツール)
* **Build System**: CMake (CMake Tools によるビルド管理の自動化)
* **Waveform Viewer**: **Surfer** (VS Code 拡張機能。VCD ファイルをエディタ内で直接観測)

---

## 🚀 ワークフロー (Workflow)

自作のアセンブラからシミュレーションまでをシームレスに連携させています。

1.  **アセンブル**: C++ で自作したアセンブラが `.asm` を読み込み、命令パッキングを行って `program.hex` を生成。
2.  **シミュレーション**: Verilator が生成した C++ モデルをテストベンチ（`sim_main.cpp`）と統合。各サイクルのレジスタ状態をリアルタイムでダンプ。
3.  **波形解析**: VS Code 上の **Surfer** を使用。VCD ファイルを読み込み、内部信号のタイミングチャートを視覚的にデバッグ。
