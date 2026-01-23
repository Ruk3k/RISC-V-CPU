module pc_reg (
  input  logic        clk,
  input  logic        rst_n,
  output logic [31:0] pc
);
// リセット時は PC = 0、以降は 4 ずつインクリメント
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) pc <= 32'hFFFFFFFC;  // リセット解除の次のクロックで PC = 0 になるように -4 に設定
    else pc <= pc + 4;
  end

endmodule
