package cpu_pkg;
  // opcode の定義
  typedef enum logic [6:0] {
    OPCODE_LUI      = 7'b0110111,
    OPCODE_AUIPC    = 7'b0010111,
    OPCODE_JAL      = 7'b1101111,
    OPCODE_JALR     = 7'b1100111,
    OPCODE_BRANCH   = 7'b1100011,
    OPCODE_LOAD     = 7'b0000011,
    OPCODE_STORE    = 7'b0100011,
    OPCODE_OP_IMM   = 7'b0010011,
    OPCODE_OP       = 7'b0110011,
    OPCODE_MISC_MEM = 7'b0001111,
    OPCODE_SYSTEM   = 7'b1110011
  } opcode_t;

  // ALU の演算種類
  typedef enum logic [3:0] {
    ALU_ADD, ALU_SUB,
    ALU_AND, ALU_OR, ALU_XOR,
    ALU_NOP
  } alu_op_t;

  // ALU の入力 A の選択
  typedef enum logic [1:0] {
    SRC_A_RS1  // レジスタ rs1
  } src_a_sel_t;

  // ALU の入力 B の選択
  typedef enum logic [1:0] {
    SRC_B_RS2,  // レジスタ rs2
    SRC_B_IMM   // 即値
  } src_b_sel_t;

  // 制御信号をまとめた構造体
  typedef struct packed {
    alu_op_t    alu_op;    // ALU の演算種類
    src_a_sel_t src_a_sel; // ALU の入力 A
    src_b_sel_t src_b_sel; // ALU の入力 B
    logic       reg_write; // レジスタ書き込み有効信号
  } control_signals_t;
endpackage
