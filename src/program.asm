// I 形式命令のテスト（OP-IMM）
addi  x1,  x0, 10
addi  x2,  x0, -5
andi  x3,  x1, 15
ori   x4,  x2, 5
xori  x5,  x1, 3

// R 形式命令のテスト（OP）
add   x6,  x1,  x2
sub   x7,  x2,  x1
and   x8,  x1,  x4
or    x9,  x1,  x2
xor   x10, x1,  x2
