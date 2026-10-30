#=========================================================================
# jal
#=========================================================================

from pymtl3 import *
from lab2_proc.test.inst_utils import *

#-------------------------------------------------------------------------
# gen_basic_test
#-------------------------------------------------------------------------

def gen_basic_test():
  return """

    # Use r3 to track the control flow pattern
    addi  x3, x0, 0     # 0x0200
                        #
    nop                 # 0x0204
    nop                 # 0x0208
    nop                 # 0x020c
    nop                 # 0x0210
    nop                 # 0x0214
    nop                 # 0x0218
    nop                 # 0x021c
    nop                 # 0x0220
                        #
    jal   x1, label_a   # 0x0224
    addi  x3, x3, 0b01  # 0x0228

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
    csrw  proc2mngr, x1 > 0x0228

    # Only the second bit should be set if jump was taken
    csrw  proc2mngr, x3 > 0b10

  """

#-------------------------------------------------------------------------
# gen_dest_dep_test
#-------------------------------------------------------------------------

def gen_dest_dep_test():
  return """

    addi  x3, x0, 0     # 0x0200
                        #
    jal   x1, label_a   # 0x0204
    addi  x3, x3, 0b01  # 0x0208 - skipped

  label_a:              
    nop                 # 0x020c
    nop                 # 0x0210
    nop                 # 0x0214

    addi x2, x1, 0      # 0x0218

    # Check the link address
    csrw  proc2mngr, x2 > 0x0208

    # Only the second bit should be set if jump was taken
    csrw  proc2mngr, x3 > 0

  """

#-------------------------------------------------------------------------
# gen_backward_test
#-------------------------------------------------------------------------

def gen_backward_test():
  return """

    # Jump forward
    jal x0, label_b     # 0x0200

  label_a:
    addi x3, x3, 1      # 0x0204
    nop                 # 0x0208
    nop                 # 0x020c
    nop                 # 0x0210
    nop                 # 0x0214

    # break the loop by escaping label_a
    jal  x0, label_c    # 0x0218

  label_b:
    addi x3, x0, 0      # 0x021c

    # Backward jump to label_a
    jal x1, label_a     # 0x0220

    addi x3, x3, 0b10   # 0x0224 - skipped

  label_c:
    # Check the link address
    csrw  proc2mngr, x1 > 0x0224

    # Only the second bit should be set if jump was taken
    csrw  proc2mngr, x3 > 1

  """

#-------------------------------------------------------------------------
# gen_multijump_test
#-------------------------------------------------------------------------

def gen_multijump_test():
  return """
    
    addi  x3, x0, 1     # 0x0200
                        
    jal   x0, label_a   # 0x0204
    addi  x3, x3, 0     # 0x0208 - skipped

  label_a:
    nop                 # 0x020c
    nop                 # 0x0210
    nop                 # 0x0214

    addi  x3, x3, 2     # 0x0218
    jal   x1, label_b   # 0x021c
    addi  x3, x3, 0     # 0x0220 - skipped

  label_b:
    jal   x2, label_c   # 0x0224
    addi  x3, x3, 4     # 0x0228 - skipped

  label_c:
    addi  x3, x3, 5     # 0x022c
    nop                 # 0x0230
    nop                 # 0x0234

    jal   x4, label_d   # 0x0238
    addi  x3, x3, 0     # 0x023c - skipped

  label_d:
    addi  x3, x3, 0     # 0x0240
    jal   x5, label_e   # 0x0244

  label_e:

    # Check the link addresses
    csrw  proc2mngr, x1 > 0x0220
    csrw  proc2mngr, x2 > 0x0228
    csrw  proc2mngr, x4 > 0x023c
    csrw  proc2mngr, x5 > 0x0248

    # Check the control flow
    csrw  proc2mngr, x3 > 8

  """

#-------------------------------------------------------------------------
# gen_jal_x0_test
#-------------------------------------------------------------------------

def gen_jal_x0_test():
  return """
  
    addi  x3, x0, 0     # 0x0200
                        #
    jal   x0, label_a   # 0x0204
    addi  x3, x3, 1     # 0x0208 - skipped

  label_a:
    addi  x3, x3, 2     # 0x020c

    # Check that x0 is still zero
    csrw  proc2mngr, x0 > 0

    # Check that jump was taken
    csrw  proc2mngr, x3 > 2

"""
