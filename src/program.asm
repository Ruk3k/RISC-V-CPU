addi  x1,  x0, 10      // x1 = 10
addi  x2,  x0, 10      // x2 = 10
addi  x3,  x0, 10      // x3 = 10
beq   x1,  x2, 12      // Skip 2 instruction
addi  x4,  x0, 99      // x4 = 99 (should be skipped)
addi  x5,  x0, 88      // x5 = 88 (should be skipped)
addi  x6,  x0, 20      // x6 = 20 (branch target)
addi  x7,  x0, 30      // x7 = 30
beq   x1,  x3, 8       // skip 1 instruction
addi  x8,  x0, 40      // x8 = 40 (should be skipped)
addi  x9,  x0, 50      // x9 = 50 (branch target)
