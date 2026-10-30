#=========================================================================
# bltu
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

    # Use x3 to track the control flow pattern
    addi  x3, x0, 0

    csrr  x1, mngr2proc < 2
    csrr  x2, mngr2proc < 1

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

    # This branch should be taken
    bltu   x2, x1, label_a
    addi  x3, x3, 0b01

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

    # Only the second bit should be set if branch was taken
    csrw proc2mngr, x3 > 0b10

  """

#-------------------------------------------------------------------------
# gen_not_taken_test
#-------------------------------------------------------------------------

def gen_not_taken_test():
  return """

    addi x3, x0, 0

    csrr x1, mngr2proc < 2
    csrr x2, mngr2proc < 1

    # 2 < 1 is false
    bltu x1, x2, label_a

    addi x3, x3, 1

  label_a:
    csrw proc2mngr, x3 > 1

  """


#-------------------------------------------------------------------------
# gen_equal_test
#-------------------------------------------------------------------------

def gen_equal_test():
  return """

    addi x3, x0, 0

    csrr x1, mngr2proc < 5
    csrr x2, mngr2proc < 5

    # 5 < 5 is false
    bltu x1, x2, label_a

    addi x3, x3, 1

  label_a:
    csrw proc2mngr, x3 > 1

  """

#-------------------------------------------------------------------------
# gen_src0_dep_taken_test
#-------------------------------------------------------------------------

def gen_src0_dep_taken_test():
  return [
    gen_br2_src0_dep_test( 5, "bltu", 1, 7, True ),
    gen_br2_src0_dep_test( 4, "bltu", 2, 7, True ),
    gen_br2_src0_dep_test( 3, "bltu", 3, 7, True ),
    gen_br2_src0_dep_test( 2, "bltu", 4, 7, True ),
    gen_br2_src0_dep_test( 1, "bltu", 5, 7, True ),
    gen_br2_src0_dep_test( 0, "bltu", 6, 7, True ),
  ]

#-------------------------------------------------------------------------
# gen_src0_dep_nottaken_test
#-------------------------------------------------------------------------

def gen_src0_dep_nottaken_test():
  return [
    gen_br2_src0_dep_test( 5, "bltu", 7, 1, False ),
    gen_br2_src0_dep_test( 4, "bltu", 7, 2, False ),
    gen_br2_src0_dep_test( 3, "bltu", 7, 3, False ),
    gen_br2_src0_dep_test( 2, "bltu", 7, 4, False ),
    gen_br2_src0_dep_test( 1, "bltu", 7, 5, False ),
    gen_br2_src0_dep_test( 0, "bltu", 7, 6, False ),
  ]

#-------------------------------------------------------------------------
# gen_src1_dep_taken_test
#-------------------------------------------------------------------------

def gen_src1_dep_taken_test():
  return [
    gen_br2_src1_dep_test( 5, "bltu", 1, 7, True ),
    gen_br2_src1_dep_test( 4, "bltu", 2, 7, True ),
    gen_br2_src1_dep_test( 3, "bltu", 3, 7, True ),
    gen_br2_src1_dep_test( 2, "bltu", 4, 7, True ),
    gen_br2_src1_dep_test( 1, "bltu", 5, 7, True ),
    gen_br2_src1_dep_test( 0, "bltu", 6, 7, True ),
  ]

#-------------------------------------------------------------------------
# gen_src1_dep_nottaken_test
#-------------------------------------------------------------------------

def gen_src1_dep_nottaken_test():
  return [
    gen_br2_src1_dep_test( 5, "bltu", 7, 1, False ),
    gen_br2_src1_dep_test( 4, "bltu", 7, 2, False ),
    gen_br2_src1_dep_test( 3, "bltu", 7, 3, False ),
    gen_br2_src1_dep_test( 2, "bltu", 7, 4, False ),
    gen_br2_src1_dep_test( 1, "bltu", 7, 5, False ),
    gen_br2_src1_dep_test( 0, "bltu", 7, 6, False ),
  ]

#-------------------------------------------------------------------------
# gen_srcs_dep_taken_test
#-------------------------------------------------------------------------

def gen_srcs_dep_taken_test():
  return [
    gen_br2_srcs_dep_test( 5, "bltu", 1, 2, True ),
    gen_br2_srcs_dep_test( 4, "bltu", 2, 3, True ),
    gen_br2_srcs_dep_test( 3, "bltu", 3, 4, True ),
    gen_br2_srcs_dep_test( 2, "bltu", 4, 5, True ),
    gen_br2_srcs_dep_test( 1, "bltu", 5, 6, True ),
    gen_br2_srcs_dep_test( 0, "bltu", 6, 7, True ),
  ]

#-------------------------------------------------------------------------
# gen_srcs_dep_nottaken_test
#-------------------------------------------------------------------------

def gen_srcs_dep_nottaken_test():
  return [
    gen_br2_srcs_dep_test( 5, "bltu", 2, 1, False ),
    gen_br2_srcs_dep_test( 4, "bltu", 3, 2, False ),
    gen_br2_srcs_dep_test( 3, "bltu", 4, 3, False ),
    gen_br2_srcs_dep_test( 2, "bltu", 5, 4, False ),
    gen_br2_srcs_dep_test( 1, "bltu", 6, 5, False ),
    gen_br2_srcs_dep_test( 0, "bltu", 7, 6, False ),
  ]

#-------------------------------------------------------------------------
# gen_unsigned_test
#-------------------------------------------------------------------------

def gen_unsigned_test():
  return """

    addi x3, x0, 0

    csrr x1, mngr2proc < 0xffffffff
    csrr x2, mngr2proc < 1

    # UNSIGNED:
    # 0xffffffff = 4294967295
    # 4294967295 < 1 is false
    bltu x1, x2, label_a

    addi x3, x3, 1

  label_a:
    csrw proc2mngr, x3 > 1

  """

#-------------------------------------------------------------------------
# gen_backward_test
#-------------------------------------------------------------------------

def gen_backward_test():
  return """

    addi x3, x0, 0

    addi x1, x0, 0
    addi x2, x0, 1

    # 0 < 1 -> taken
    bltu x1, x2, label_b

  label_a:
    addi x3, x3, 0b10

    # Make condition false
    addi x1, x0, 2

  label_b:

    # First time: 0 < 1 -> taken backwards
    # Second time: 2 < 1 -> not taken
    bltu x1, x2, label_a

    addi x3, x3, 0b01

    csrw proc2mngr, x3 > 0b11

  """

#-------------------------------------------------------------------------
# gen_random_test
#-------------------------------------------------------------------------

def gen_random_test():

  asm_code = []

  for i in range(20):

    src0 = random.randint( 0, 0xffffffff )
    src1 = random.randint( 0, 0xffffffff )

    result = 0 if src0 < src1 else 1

    asm_code.append( """

      addi x3, x0, 0

      csrr x1, mngr2proc < %d
      csrr x2, mngr2proc < %d

      bltu x1, x2, label_%d
      addi x3, x3, 1

    label_%d:
      csrw proc2mngr, x3 > %d

    """ % ( src0, src1, i, i, result ) )

  return asm_code
