module cpu (
  input wire clk,
  input wire rst
);

  // ====================================================
  //   Instruction Fetch
  // ====================================================

  reg [31:0] pc;

  always @(posedge clk or posedge rst) begin
    if (rst) pc <= 32'b0;
    else     pc <= pc + 4;
  end

  reg  [31:0] instr_mem [0:1023];
  wire [9:0]  instr_addr = pc[11:2];
  wire [31:0] instruction = instr_mem[instr_addr];

  initial begin
    $readmemh("../src/program.hex", instr_mem);
  end

  // ====================================================
  //   Instruction Decode
  // ====================================================

  /*
  * RISC-V Instruction Formats (Base Integer ISA)
  *
  * R-type: [31:25]funct7 | [24:20]rs2 | [19:15]rs1 | [14:12]funct3 | [11:7]rd | [6:0]opcode
  * (     3 registers:     rd = rs1 op rs2)
  *
  * I-type:  <--- [31:20]imm[11:0] --->| [19:15]rs1 | [14:12]funct3 | [11:7]rd | [6:0]opcode
  * ( 1 reg + 12-bit imm:  rd = rs1 op imm)
  */

  wire [6:0] opcode = instruction[6:0];
  wire [2:0] funct3 = instruction[14:12];
  wire [6:0] funct7 = instruction[31:25];
  wire [4:0] rd     = instruction[11:7];
  wire [4:0] rs1    = instruction[19:15];
  wire [4:0] rs2    = instruction[24:20];

  wire [31:0] imm_i = {{20{instruction[31]}}, instruction[31:20]}; // I-type immediate

  reg  [3:0] alu_op;
  always @(*) begin
    alu_op = 4'b1111;
    case (opcode)
      7'b0110011: begin // R-type instructions
        case ({funct7, funct3})
          10'b0000000_000: alu_op = 4'b0000;     // ADD
          10'b0100000_000: alu_op = 4'b0001;     // SUB
          10'b0000000_111: alu_op = 4'b0010;     // AND
          10'b0000000_110: alu_op = 4'b0011;     // OR
          10'b0000000_100: alu_op = 4'b0100;     // XOR
          default:         alu_op = 4'b1111;     // NOP/Unknown
        endcase
      end
      7'b0010011: begin // I-type instructions
        case (funct3)
          3'b000:  alu_op = 4'b0000;     // ADDI
          3'b111:  alu_op = 4'b0010;     // ANDI
          3'b110:  alu_op = 4'b0011;     // ORI
          3'b100:  alu_op = 4'b0100;     // XORI
          default: alu_op = 4'b1111;     // NOP/Unknown
        endcase
      end
      default: alu_op = 4'b1111;         // NOP/Unknown
    endcase
  end

  // ====================================================
  //   Register Read
  // ====================================================

  reg  [31:0] rf [0:31] /* verilator public */;
  wire [31:0] rf_data1 = (rs1 == 5'b0) ? 32'b0 : rf[rs1];
  wire [31:0] rf_data2 = (rs2 == 5'b0) ? 32'b0 : rf[rs2];

  // ====================================================
  //   Execution (ALU)
  // ====================================================

  wire [31:0] alu_in_a = rf_data1;
  wire [31:0] alu_in_b = (opcode == 7'b0010011) ? imm_i : rf_data2; // Multiplex for ALU B input
  reg  [31:0] alu_out;

  always @(*) begin
    case (alu_op)
      4'b0000: alu_out = alu_in_a + alu_in_b;      // ADD
      4'b0001: alu_out = alu_in_a - alu_in_b;      // SUB
      4'b0010: alu_out = alu_in_a & alu_in_b;      // AND
      4'b0011: alu_out = alu_in_a | alu_in_b;      // OR
      4'b0100: alu_out = alu_in_a ^ alu_in_b;      // XOR
      default: alu_out = 32'b0;                    // NOP/Unknown
    endcase
  end

  // ====================================================
  //   Register Write Back
  // ====================================================

  integer i;
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      for (i = 0; i < 32; i = i + 1) rf[i] <= 32'b0;
    end else begin
      if ((opcode == 7'b0110011 || opcode == 7'b0010011) && rd != 5'b0) begin // R-type and I-type write back
        rf[rd] <= alu_out;
      end
    end
  end

endmodule
