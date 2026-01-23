import cpu_pkg::*;

module cpu_top (
  input  logic        clk,
  input  logic        rst_n,
  output logic [31:0] current_instr,
  // デコード結果の出力（テスト用）
  output logic [3:0]  decoded_alu_op,
  output logic [1:0]  decoded_src_a_sel,
  output logic [1:0]  decoded_src_b_sel,
  output logic        decoded_reg_write
);
  logic [31:0] pc;
  logic [31:0] instr;
  control_signals_t ctrl_signals;

// PC レジスタのインスタンス化
  pc_reg u_pc_reg (
    .clk(clk),
    .rst_n(rst_n),
    .pc(pc)
  );

// 命令メモリのインスタンス化
  instr_mem u_instr_mem (
    .addr(pc),
    .instr(instr)
  );

// デコーダのインスタンス化
  decoder u_decoder (
    .instr(instr),
    .ctrl(ctrl_signals)
  );

// 現在の命令を出力（リセット時は NOP: 0x00000000）
  assign current_instr = rst_n ? instr : 32'h00000000;

// デコード結果を出力
  assign decoded_alu_op    = ctrl_signals.alu_op;
  assign decoded_src_a_sel = ctrl_signals.src_a_sel;
  assign decoded_src_b_sel = ctrl_signals.src_b_sel;
  assign decoded_reg_write = ctrl_signals.reg_write;

endmodule
