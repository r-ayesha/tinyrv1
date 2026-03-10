#-------------------------------------------------------------------------
# door-monitor-step3.asm
#-------------------------------------------------------------------------

start:
  addi x3, x0, 0
  addi x4, x0, 0

loop:
  lw   x1, 0x20c(x0)
  bne  x1, x0, loop

wait_fall:
  lw   x1, 0x20c(x0)
  bne  x1, x0, wait_fall

addi x3, x3, 1
sw   x3, 0x210(x0)

bne  x4, x0, start_alarm
jal  x0, loop

start_alarm:
  addi x5, x0, 1
  sw   x5, 0x21c(x0)
  addi x4, x0, 1
  jal  x0, loop

