#-------------------------------------------------------------------------
# test4.asm
#-------------------------------------------------------------------------
# Tests the multi-note player and IR sensor

loop:
  lw   x1, 0x20c(x0) # Load value from the IR sensor
  sw   x1, 0x210(x0) # Display IR sensor value on display

  lw   x2, 0x204(x0) # Load value from the input switches
  sw   x2, 0x218(x0) # Display the number from the input switches
  sw   x2, 0x21c(x0) # Send value to multi-note player

  jal  x0, loop
