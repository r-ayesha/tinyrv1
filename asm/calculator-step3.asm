#-------------------------------------------------------------------------
# calculator-step3.asm
#-------------------------------------------------------------------------

loop:
  lw   x1, 0x200(x0)
  lw   x2, 0x204(x0)
  lw   x3, 0x208(x0)

  sw   x1, 0x210(x0)
  sw   x2, 0x214(x0)

  addi x5, x0, 0
  bne  x3, x5, check_mul

  add  x4, x1, x2
  jal  x0, done

check_mul:
  addi x5, x0, 1
  bne  x3, x5, do_sub

  mul  x4, x1, x2
  jal  x0, done

do_sub:
  addi x6, x0, -1     
  mul x6, x2, x6     
  add  x4, x1, x6 

done:
  sw   x4, 0x218(x0)
  jal  x0, loop



