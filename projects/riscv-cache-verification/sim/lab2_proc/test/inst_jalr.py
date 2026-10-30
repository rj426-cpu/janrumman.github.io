#=========================================================================
# jalr
#=========================================================================

import random

# Fix the random seed so results are reproducible
random.seed(0xdeadbeef)

from pymtl3 import *
from lab2_proc.test.inst_utils import *

#-------------------------------------------------------------------------
# gen_basic_test
#-------------------------------------------------------------------------

def gen_basic_test():
  return """

    # Use r3 to track the control flow pattern
    addi  x3, x0, 0           # 0x0200
                              #
    lui x1,      %hi[label_a] # 0x0204
    addi x1, x1, %lo[label_a] # 0x0208
                              #
    nop                       # 0x020c
    nop                       # 0x0210
    nop                       # 0x0214
    nop                       # 0x0218
    nop                       # 0x021c
    nop                       # 0x0220
    nop                       # 0x0224
    nop                       # 0x0228
                              #
    jalr  x31, x1, 0          # 0x022c
    addi  x3, x3, 0b01        # 0x0230

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

  label_a:
    addi  x3, x3, 0b10

    # Check the link address
    csrw  proc2mngr, x31 > 0x0230

    # Only the second bit should be set if jump was taken
    csrw  proc2mngr, x3  > 0b10

  """
#-------------------------------------------------------------------------
# gen_dest_dep_test
#-------------------------------------------------------------------------

def gen_dest_dep_test():
  return """

    # Use r3 to track the control flow pattern
    addi  x3, x0, 0           # 0x0200
                              #
    lui x1,      %hi[label_a] # 0x0204
    addi x1, x1, %lo[label_a] # 0x0208
                              #
    nop                       # 0x020c
    nop                       # 0x0210
    nop                       # 0x0214
    nop                       # 0x0218
    nop                       # 0x021c
    nop                       # 0x0220
    nop                       # 0x0224
    nop                       # 0x0228
                              #
    jalr  x31, x1, 0          # 0x022c
    addi  x3, x3, 0b01        # 0x0230 - skipped

  label_a:
    nop
    nop
    nop

    # use dst by jalr
    addi  x2, x31, 0

    # Check the link address
    csrw  proc2mngr, x2 > 0x0230

    # Check if jump was taken
    csrw  proc2mngr, x3  > 0

  """

#-------------------------------------------------------------------------
# gen_src_dep_test
#-------------------------------------------------------------------------

def gen_src_dep_test():
  return """
    # Use r3 to track the control flow pattern
    addi  x3, x0, 0           # 0x0200
                              #
    lui x1,      %hi[label_a] # 0x0204
    addi x1, x1, %lo[label_a] # 0x0208
                              #
    nop                       # 0x020c
    nop                       # 0x0210
    nop                       # 0x0214
                              #
    jalr  x31, x1, 0          # 0x0218
    addi  x3, x3, 0b01        # 0x021c - skipped

  label_a:

    addi  x3, x3, 0b10        # 0x0220

    # Check the link address
    csrw  proc2mngr, x31 > 0x021c

    # Check if jump was taken
    csrw  proc2mngr, x3  > 0b10

  """

#-------------------------------------------------------------------------
# gen_src0_dep_test
#-------------------------------------------------------------------------

def gen_src0_dep_test():
  return """

    # Use r3 to track the control flow pattern
    addi  x3, x0, 0            # 0x0200

    lui   x1, %hi[label_a]     # 0x0204
    addi  x1, x1, %lo[label_a] # 0x0208

    # No nops 
    jalr  x31, x1, 0           # 0x020c
    addi  x3, x3, 0b01         # 0x0210 - skipped

  label_a:
    addi  x3, x3, 0b10         # 0x0214

    # Check the link address
    csrw  proc2mngr, x31 > 0x0210

    # Check if jump was taken
    csrw  proc2mngr, x3 > 0b10

  """

#-------------------------------------------------------------------------
# gen_jal_x0_test
#-------------------------------------------------------------------------

def gen_jal_x0_test():
  return """
  
    # Use r3 to track the control flow pattern
    addi  x3, x0, 0            # 0x0200

    lui   x1, %hi[label_a]     # 0x0204
    addi  x1, x1, %lo[label_a] # 0x0208

    jalr  x0, x1, 0            # 0x020c
    addi  x3, x3, 0b01         # 0x0210 - skipped

  label_a:
    addi  x3, x3, 0b10         # 0x0214

    # Check the link address
    csrw  proc2mngr, x0 > 0

    # Check if jump was taken
    csrw  proc2mngr, x3 > 0b10

"""

#-------------------------------------------------------------------------
# gen_multijump_test
#-------------------------------------------------------------------------

def gen_multijump_test():
  return """
  
    addi  x3, x0, 1             # 0x0200

    lui   x10, %hi[label_a]     # 0x0204
    addi  x10, x10, %lo[label_a]# 0x0208
    jalr  x0, x10, 0            # 0x020c
    addi  x3, x3, 0             # 0x0210 - skipped

  label_a:
    addi  x3, x3, 2             # 0x0214

    lui   x11, %hi[label_b]     # 0x0218
    addi  x11, x11, %lo[label_b]# 0x021c
    jalr  x1, x11, 0            # 0x0220
    addi  x3, x3, 0             # 0x0224 - skipped

  label_b:
    lui   x12, %hi[label_c]     # 0x0228
    addi  x12, x12, %lo[label_c]# 0x022c
    jalr  x2, x12, 0            # 0x0230
    addi  x3, x3, 4             # 0x0234 - skipped

  label_c:
    addi  x3, x3, 5             # 0x0238

    lui   x13, %hi[label_d]     # 0x023c
    addi  x13, x13, %lo[label_d]# 0x0240
    jalr  x4, x13, 0            # 0x0244
    addi  x3, x3, 0             # 0x0248 - skipped

  label_d:
    lui   x14, %hi[label_e]     # 0x024c
    addi  x14, x14, %lo[label_e]# 0x0250
    jalr  x5, x14, 0            # 0x0254

  label_e:

    # Check the link addresses
    csrw  proc2mngr, x1 > 0x0224
    csrw  proc2mngr, x2 > 0x0234
    csrw  proc2mngr, x4 > 0x0248
    csrw  proc2mngr, x5 > 0x0258

    # Check the control flow
    csrw  proc2mngr, x3 > 8

  """
#-------------------------------------------------------------------------
# gen_random_test
#-------------------------------------------------------------------------

def gen_random_test():

  asm_code = []

  for i in range(20):

    # create random nops
    num_nops = random.randint( 0, 8 )

    asm_code.append( """

      addi  x3, x0, 0

      lui   x1, %%hi[label_%d]
      addi  x1, x1, %%lo[label_%d]

      %s

      jalr  x31, x1, 0
      addi  x3, x3, 0b01

    label_%d:
      addi  x3, x3, 0b10

      csrw  proc2mngr, x3 > 0b10

    """ % ( i, i, gen_nops(num_nops), i ) )

  return asm_code