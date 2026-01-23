// I 形式命令のテスト（OP-IMM）
addi  x1,  x0, 10      // Test ADDI: x1 = 0 + 10 = 10
addi  x2,  x0, 20      // Test ADDI: x2 = 0 + 20 = 20
addi  x3,  x0, -5      // Test ADDI: x3 = 0 + (-5) = -5
andi  x4,  x1, 15      // Test ANDI: x4 = 10 & 15 = 10
ori   x5,  x2, 5       // Test ORI:  x5 = 20 | 5 = 21
xori  x6,  x1, 3       // Test XORI: x6 = 10 ^ 3 = 9

// R 形式命令のテスト（OP）
add   x7,  x1,  x2     // Test ADD: x7 = 10 + 20 = 30
sub   x8,  x2,  x1     // Test SUB: x8 = 20 - 10 = 10
and   x9,  x1,  x4     // Test AND: x9 = 10 & 10 = 10
or    x10, x1,  x2     // Test OR:  x10 = 10 | 20 = 30
xor   x11, x1,  x2     // Test XOR: x11 = 10 ^ 20 = 30
