module cpu_top (
  input  logic        clk,
  input  logic        rst_n,
  output logic [31:0] current_instr
);
  logic [31:0] pc;
  logic [31:0] instr;

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

// 現在の命令を出力（リセット時は NOP: 0x00000000）
  assign current_instr = rst_n ? instr : 32'h00000000;

endmodule
