#========================================================================
# accumulate.asm
#========================================================================

start:

  # wait for button to be pressed

  addi x1, x0, 1
wait_posedge:
  lw   x2, 0x208(x0)            # in2
  bne  x2, x1, wait_posedge     # loop when input is high

  # wait for button to be unpressed

wait_negedge:
  lw   x2, 0x208(x0)            
  bne  x2, x0, wait_negedge 

  # read and display size

  lw   x1, 0x200(x0)            # take in in0 to put into reg x1
  sw   x1, 0x210(x0)            # take reg x1 to put into out0

  # set breadboard pin high for timing

  addi x3, x0, 1
  sw   x3, 0x21c(x0)            # out3 = 1
  addi x4, x0, 0                # initialize x4 = 0 
  addi x5, x0, 0x100            # data address

L1:
  bne  x1, x0, accumulate
  jal  x0, store

accumulate:
  lw   x6, 0(x5)
  add  x4, x4, x6
  addi x1, x1, -1
  addi x5, x5, 4
  jal  x0, L1
  
  # Be sure to understand the code above and below so you know what
  # register stores the size and what register stores the result.

  # set breadboard pin low for timing

store:
  sw   x0, 0x21c(x0)

  # done

  sw   x4, 0x214(x0)
  jal  x0, start

  .data
           #       result result   seven
           #  size  (dec)  (hex) segment
           # ----------------------------
  .word 36 #     1     36  0x024    4
  .word 26 #     2     62  0x03e   30
  .word 69 #     3    131  0x083    3
  .word 57 #     4    188  0x0bc   28
  .word 11 #     5    199  0x0c7    7
  .word 68 #     6    267  0x10b   11
  .word 41 #     7    308  0x134   20
  .word 90 #     8    398  0x18e   14

  .word 32 #     9    430  0x1ae   14
  .word 76 #    10    506  0x1fa   26
  .word 44 #    11    550  0x226    6
  .word 19 #    12    569  0x239   25
  .word 17 #    13    586  0x24a   10
  .word 59 #    14    645  0x285    5
  .word 99 #    15    744  0x2e8    8
  .word 49 #    16    793  0x319   25

  .word 65 #    17    858  0x35a   26
  .word 12 #    18    870  0x366    6
  .word 55 #    19    925  0x39d   29
  .word  0 #    20    925  0x39d   29
  .word 51 #    21    976  0x3d0   16
  .word 42 #    22   1018  0x3fa   26
  .word 82 #    23   1100  0x44c   12
  .word 23 #    24   1123  0x463    3

  .word 21 #    25   1144  0x478   24
  .word 54 #    26   1198  0x4ae   14
  .word 83 #    27   1281  0x501    1
  .word 31 #    28   1312  0x520    0
  .word 16 #    29   1328  0x530   16
  .word 76 #    30   1404  0x57c   28
  .word 21 #    31   1425  0x591   17
  .word  4 #    32   1429  0x595   21

