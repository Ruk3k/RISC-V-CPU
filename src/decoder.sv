import cpu_pkg::*;

module decoder (
  input logic [31:0] instr,
  output control_signals_t ctrl
);
  opcode_t opcode;
  logic [6:0] funct7;
  logic [2:0] funct3;

  // 機械語命令から対応するフィールドを抽出
  assign opcode = opcode_t'(instr[6:0]);
  assign funct7 = instr[31:25];
  assign funct3 = instr[14:12];

  // デコード（パース）部分
  always_comb begin
    // デフォルト値の設定
    ctrl.alu_op     = ALU_NOP;
    ctrl.src_a_sel  = SRC_A_RS1;
    ctrl.src_b_sel  = SRC_B_RS2;
    ctrl.reg_write  = WRITE_DISABLE;

    // opcode で制御信号を指定
    case(opcode)
      OPCODE_OP: begin
        ctrl.src_a_sel = SRC_A_RS1;
        ctrl.src_b_sel = SRC_B_RS2;
        ctrl.reg_write = WRITE_ENABLE; // レジスタ書き込み有効化
        case({funct7, funct3}) // funct7 と funct3 で命令を判別
          10'b0000000_000: ctrl.alu_op = ALU_ADD; // ADD
          10'b0100000_000: ctrl.alu_op = ALU_SUB; // SUB
          10'b0000000_111: ctrl.alu_op = ALU_AND; // AND
          10'b0000000_110: ctrl.alu_op = ALU_OR;  // OR
          10'b0000000_100: ctrl.alu_op = ALU_XOR; // XOR
          default:         ctrl.alu_op = ALU_NOP; // デフォルトは NOP
        endcase
      end

      OPCODE_OP_IMM: begin
        ctrl.src_a_sel = SRC_A_RS1;
        ctrl.src_b_sel = SRC_B_IMM;
        ctrl.reg_write = WRITE_ENABLE; // レジスタ書き込み有効化
        case(funct3) // funct3 で命令を判別
          3'b000:  ctrl.alu_op = ALU_ADD; // ADDI
          3'b111:  ctrl.alu_op = ALU_AND; // ANDI
          3'b110:  ctrl.alu_op = ALU_OR;  // ORI
          3'b100:  ctrl.alu_op = ALU_XOR; // XORI
          default: ctrl.alu_op = ALU_NOP; // デフォルトは NOP
        endcase
      end
      default: ctrl.alu_op = ALU_NOP; // デフォルトは NOP
    endcase
  end
endmodule
