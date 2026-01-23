module pc_reg (
  input  logic        clk,
  input  logic        rst_n,
  output logic [31:0] pc
);
// リセット時は PC = 0、以降は 4 ずつインクリメント（1ワード = 4バイト）
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) pc <= 32'b0;
    else pc <= pc + 4;
  end

endmodule
