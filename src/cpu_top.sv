import cpu_pkg::*;

module cpu_top (
  input  logic        clk,
  input  logic        rst_n,
  output logic [31:0] current_instr,
  output alu_op_t     alu_op,
  output src_a_sel_t  src_a_sel,
  output src_b_sel_t  src_b_sel,
  output reg_write_t  reg_write
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

// デコード結果を出力（リセット時は NOP）
  assign alu_op    = rst_n ? ctrl_signals.alu_op    : ALU_NOP;
  assign src_a_sel = rst_n ? ctrl_signals.src_a_sel : SRC_A_RS1;
  assign src_b_sel = rst_n ? ctrl_signals.src_b_sel : SRC_B_RS2;
  assign reg_write = rst_n ? ctrl_signals.reg_write : WRITE_DISABLE;

endmodule
