import cpu_pkg::*;

module alu (
  input  alu_op_t     alu_op,
  input  logic [31:0] src_a,
  input  logic [31:0] src_b,
  output logic [31:0] alu_result
);
  always_comb begin
    case (alu_op)
      ALU_ADD: alu_result = src_a + src_b;
      ALU_SUB: alu_result = src_a - src_b;
      ALU_AND: alu_result = src_a & src_b;
      ALU_OR:  alu_result = src_a | src_b;
      ALU_XOR: alu_result = src_a ^ src_b;
      default: alu_result = 32'b0; // 未定義または NOP の場合は 0 を出力
    endcase
  end

endmodule
