import cpu_pkg::*;

module imm_gen (
  input  logic [31:0] instr,
  input  imm_type_t   imm_type,
  output logic [31:0] imm_data
);
  always_comb begin
    case(imm_type)
      IMM_I:   imm_data = {{21{instr[31]}}, instr[30:25], instr[24:21], instr[20]};
      IMM_S:   imm_data = {{21{instr[31]}}, instr[30:25], instr[11:8], instr[7]};
      IMM_B:   imm_data = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
      IMM_U:   imm_data = {instr[31], instr[30:20], instr[19:12], 12'b0};
      IMM_J:   imm_data = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:25], instr[24:21], 1'b0};
      default: imm_data = 32'h0;
    endcase
  end

endmodule
