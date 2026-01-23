import cpu_pkg::*;

module cpu_top (
  input  logic        clk,
  input  logic        rst_n,
  output logic [31:0] current_instr,
  output logic [31:0] pc_out,
  output logic [31:0] rs1_data_out,
  output logic [31:0] rs2_data_out,
  output logic [31:0] alu_in_a_out,
  output logic [31:0] alu_in_b_out,
  output logic [31:0] alu_result_out,
  output alu_op_t     alu_op_out,
  output src_a_sel_t  src_a_sel_out,
  output src_b_sel_t  src_b_sel_out,
  output reg_write_t  reg_write_out
);
  control_signals_t ctrl_signals;
  imm_type_t        imm_type;

  logic [31:0] pc;
  logic [31:0] instr;
  logic [31:0] rs1_data, rs2_data, imm_data;
  logic [31:0] alu_in_a, alu_in_b, alu_result;

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

  // 汎用レジスタのインスタンス化
  register_file u_register_file (
    .clk(clk),
    .rs1_addr(instr[19:15]),
    .rs2_addr(instr[24:20]),
    .rd_addr(instr[11:7]),
    .rd_data(alu_result),
    .reg_write(ctrl_signals.reg_write),
    .rs1_data(rs1_data),
    .rs2_data(rs2_data)
  );

  // 即値生成器のインスタンス化
  imm_gen u_imm_gen (
    .instr(instr),
    .imm_type(ctrl_signals.imm_type),
    .imm_data(imm_data)
  );

  // ALU 入力選択用のマルチプレクサ
  always_comb begin
    case (ctrl_signals.src_a_sel)
      SRC_A_RS1: alu_in_a = rs1_data;
      default:   alu_in_a = 32'h0;
    endcase
    case (ctrl_signals.src_b_sel)
      SRC_B_RS2: alu_in_b = rs2_data;
      SRC_B_IMM: alu_in_b = imm_data;
      default:   alu_in_b = 32'h0;
    endcase
  end

  // ALU のインスタンス化
  alu u_alu (
    .alu_op(ctrl_signals.alu_op),
    .src_a(alu_in_a),
    .src_b(alu_in_b),
    .alu_result(alu_result)
  );

  // 現在の命令（リセット時は NOP: 0x00000000）
  assign current_instr = rst_n ? instr : 32'h00000000;

  // デバッグ用出力（リセット時は全て 0 または NOP）
  assign pc_out         = rst_n ? pc         : 32'hFFFFFFFC;
  assign rs1_data_out   = rst_n ? rs1_data   : 32'h0;
  assign rs2_data_out   = rst_n ? rs2_data   : 32'h0;
  assign alu_in_a_out   = rst_n ? alu_in_a   : 32'h0;
  assign alu_in_b_out   = rst_n ? alu_in_b   : 32'h0;
  assign alu_result_out = rst_n ? alu_result : 32'h0;
  assign alu_op_out     = rst_n ? ctrl_signals.alu_op    : ALU_NOP;
  assign src_a_sel_out = rst_n ? ctrl_signals.src_a_sel  : SRC_A_RS1;
  assign src_b_sel_out = rst_n ? ctrl_signals.src_b_sel  : SRC_B_RS2;
  assign reg_write_out  = rst_n ? ctrl_signals.reg_write : WRITE_DISABLE;

endmodule
