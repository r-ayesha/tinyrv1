#-------------------------------------------------------------------------
# door-monitor-step2.asm
#-------------------------------------------------------------------------

sw x0, 0x210(x0)
 
start:
  addi x3, x0, 0
  addi x4, x0, 1

loop:
  lw   x1, 0x20c(x0)
  bne  x1, x4, loop       # wait for sensor to become 1

wait_fall:
  lw   x1, 0x20c(x0)
  bne  x1, x0, wait_fall  # wait for sensor to return to 0

addi x3, x3, 1
sw   x3, 0x210(x0)

jal  x0, loop
