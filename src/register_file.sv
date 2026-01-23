module register_file (
  input  logic        clk,
  input  logic [4:0]  rs1_addr,
  input  logic [4:0]  rs2_addr,
  input  logic [4:0]  rd_addr,
  input  logic [31:0] rd_data,
  input  logic        reg_write,
  output logic [31:0] rs1_data,
  output logic [31:0] rs2_data
);
  logic [31:0] rf [0:31];

  // レジスタの初期化
  initial begin
    for (int i = 0; i < 32; i++) rf[i] = 32'b0;
  end

  // 書き込み（x0 への書き込みは禁止）
  always_ff @(posedge clk) begin
    if (reg_write && (rd_addr != 5'b0)) rf[rd_addr] <= rd_data;
  end

  // 読み出し（x0 からの読み出しは常に 0 とする）
  assign rs1_data = (rs1_addr == 5'b0) ? 32'b0 : rf[rs1_addr];
  assign rs2_data = (rs2_addr == 5'b0) ? 32'b0 : rf[rs2_addr];

endmodule
