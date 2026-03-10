#-------------------------------------------------------------------------
# door-monitor-step4.asm
#-------------------------------------------------------------------------

start:
  addi x3, x0, 0
  addi x4, x0, 1

loop:
  lw   x1, 0x20c(x0)
  bne  x1, x4, loop

wait_fall:
  lw   x1, 0x20c(x0)
  bne  x1, x0, wait_fall

  addi x3, x3, 1
  sw   x3, 0x210(x0)

  addi x5, x0, 1
  sw   x5, 0x21c(x0)

  lw   x6, 0x100(x0)

delay_loop:
  addi x6, x6, -1
  bne  x6, x0, delay_loop

  sw   x0, 0x21c(x0)

  jal  x0, loop

.data
  .word 1000000
