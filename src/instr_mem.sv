module instr_mem (
  input  logic [31:0] addr,
  output logic [31:0] instr
);
// 4KiB の命令メモリ（1024ワード分）を用意
  logic [31:0] mem [0:1023];

// 初期化時に program.hex から命令を読み込むように設定
  initial $readmemh("../src/program.hex", mem);

// バイトアドレスをワードアドレスに変換（addr[11:2] → アドレスを 4 で割って取得）
  assign instr = mem[addr[11:2]];

endmodule
