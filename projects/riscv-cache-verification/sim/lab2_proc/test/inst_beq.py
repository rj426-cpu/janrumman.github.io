#=========================================================================
# beq
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
    csrr  x2, mngr2proc < 2

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

    # This branch should be taken
    beq   x1, x2, label_a
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

    # Use x3 to track the control flow pattern
    addi  x3, x0, 0

    csrr  x1, mngr2proc < 1
    csrr  x2, mngr2proc < 2

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

    # This branch should be taken
    beq   x1, x2, label_a
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
    csrw proc2mngr, x3 > 0b11

  """

#-------------------------------------------------------------------------
# gen_src0_dep_taken_test
#-------------------------------------------------------------------------

def gen_src0_dep_taken_test():
  return [
    gen_br2_src0_dep_test( 5, "beq", 1, 1, True ),
    gen_br2_src0_dep_test( 4, "beq", 2, 2, True ),
    gen_br2_src0_dep_test( 3, "beq", 3, 3, True ),
    gen_br2_src0_dep_test( 2, "beq", 4, 4, True ),
    gen_br2_src0_dep_test( 1, "beq", 5, 5, True ),
    gen_br2_src0_dep_test( 0, "beq", 6, 6, True ),
  ]

#-------------------------------------------------------------------------
# gen_src0_dep_nottaken_test
#-------------------------------------------------------------------------

def gen_src0_dep_nottaken_test():
  return [
    gen_br2_src0_dep_test( 5, "beq", 1, 7, False ),
    gen_br2_src0_dep_test( 4, "beq", 2, 7, False ),
    gen_br2_src0_dep_test( 3, "beq", 3, 7, False ),
    gen_br2_src0_dep_test( 2, "beq", 4, 7, False ),
    gen_br2_src0_dep_test( 1, "beq", 5, 7, False ),
    gen_br2_src0_dep_test( 0, "beq", 6, 7, False ),
  ]

#-------------------------------------------------------------------------
# gen_src1_dep_taken_test
#-------------------------------------------------------------------------

def gen_src1_dep_taken_test():
  return [
    gen_br2_src1_dep_test( 5, "beq", 1, 1, True ),
    gen_br2_src1_dep_test( 4, "beq", 2, 2, True ),
    gen_br2_src1_dep_test( 3, "beq", 3, 3, True ),
    gen_br2_src1_dep_test( 2, "beq", 4, 4, True ),
    gen_br2_src1_dep_test( 1, "beq", 5, 5, True ),
    gen_br2_src1_dep_test( 0, "beq", 6, 6, True ),
  ]

#-------------------------------------------------------------------------
# gen_src1_dep_nottaken_test
#-------------------------------------------------------------------------

def gen_src1_dep_nottaken_test():
  return [
    gen_br2_src1_dep_test( 5, "beq", 7, 1, False ),
    gen_br2_src1_dep_test( 4, "beq", 7, 2, False ),
    gen_br2_src1_dep_test( 3, "beq", 7, 3, False ),
    gen_br2_src1_dep_test( 2, "beq", 7, 4, False ),
    gen_br2_src1_dep_test( 1, "beq", 7, 5, False ),
    gen_br2_src1_dep_test( 0, "beq", 7, 6, False ),
  ]

#-------------------------------------------------------------------------
# gen_srcs_dep_taken_test
#-------------------------------------------------------------------------

def gen_srcs_dep_taken_test():
  return [
    gen_br2_srcs_dep_test( 5, "beq", 1, 1, True ),
    gen_br2_srcs_dep_test( 4, "beq", 2, 2, True ),
    gen_br2_srcs_dep_test( 3, "beq", 3, 3, True ),
    gen_br2_srcs_dep_test( 2, "beq", 4, 4, True ),
    gen_br2_srcs_dep_test( 1, "beq", 5, 5, True ),
    gen_br2_srcs_dep_test( 0, "beq", 6, 6, True ),
  ]

#-------------------------------------------------------------------------
# gen_srcs_dep_nottaken_test
#-------------------------------------------------------------------------

def gen_srcs_dep_nottaken_test():
  return [
    gen_br2_srcs_dep_test( 5, "beq", 1, 2, False ),
    gen_br2_srcs_dep_test( 4, "beq", 2, 3, False ),
    gen_br2_srcs_dep_test( 3, "beq", 3, 4, False ),
    gen_br2_srcs_dep_test( 2, "beq", 4, 5, False ),
    gen_br2_srcs_dep_test( 1, "beq", 5, 6, False ),
    gen_br2_srcs_dep_test( 0, "beq", 6, 7, False ),
  ]

#-------------------------------------------------------------------------
# gen_src0_eq_src1_test
#-------------------------------------------------------------------------

def gen_src0_eq_src1_test():
  return [
    gen_br2_src0_eq_src1_test( "beq", 1, True ),
  ]

#-------------------------------------------------------------------------
# gen_value_test
#-------------------------------------------------------------------------

def gen_value_test():
  return [
    gen_br2_value_test( "beq", -1, -1, True  ),
    gen_br2_value_test( "beq", -1,  0, False ),
    gen_br2_value_test( "beq", -1,  1, False ),

    gen_br2_value_test( "beq",  0, -1, False ),
    gen_br2_value_test( "beq",  0,  0, True  ),
    gen_br2_value_test( "beq",  0,  1, False ),

    gen_br2_value_test( "beq",  1, -1, False ),
    gen_br2_value_test( "beq",  1,  0, False ),
    gen_br2_value_test( "beq",  1,  1, True  ),

    gen_br2_value_test( "beq", 0xffffffff, 0xffffffff, True  ),
    gen_br2_value_test( "beq", 0x7fffffff, 0x7fffffff, True  ),
    gen_br2_value_test( "beq", 0xffffffff, 0x7fffffff, False ),
  ]

#-------------------------------------------------------------------------
# gen_backward_test
#-------------------------------------------------------------------------

def gen_backward_test():
  return """

    addi x3, x0, 0

    addi x1, x0, 1
    addi x2, x0, 1

    beq x1, x2, label_b

  label_a:
    addi x3, x3, 0b10
    addi x1, x0, 0

  label_b:
    beq x1, x2, label_a

    addi x3, x3, 0b01

    csrw proc2mngr, x3 > 0b11

  """

#-------------------------------------------------------------------------
# gen_random_test
#-------------------------------------------------------------------------

def gen_random_test():

  asm_code = []

  for i in range(20):

    src0 = random.randint( 0, 100 )
    src1 = random.randint( 0, 100 )

    result = 1 if src0 != src1 else 0

    asm_code.append( """

      addi x3, x0, 0

      csrr x1, mngr2proc < %d
      csrr x2, mngr2proc < %d

      beq  x1, x2, label_%d
      addi x3, x3, 1

    label_%d:
      csrw proc2mngr, x3 > %d

    """ % ( src0, src1, i, i, result ) )

  return asm_code