#=========================================================================
# slti
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
    csrr x1, mngr2proc < 5
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    slti x3, x1, 6
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    csrw proc2mngr, x3 > 1
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
  """

#-------------------------------------------------------------------------
# gen_dest_dep_test
#-------------------------------------------------------------------------

def gen_dest_dep_test():
  return [
    gen_rimm_dest_dep_test( 5, "slti", 0, 1, 1 ),
    gen_rimm_dest_dep_test( 4, "slti", 1, 1, 0 ),
    gen_rimm_dest_dep_test( 3, "slti", 2, 1, 0 ),
    gen_rimm_dest_dep_test( 2, "slti", 3, 1, 0 ),
    gen_rimm_dest_dep_test( 1, "slti", 4, 1, 0 ),
    gen_rimm_dest_dep_test( 0, "slti", 5, 1, 0 ),
  ]

#-------------------------------------------------------------------------
# gen_src_dep_test
#-------------------------------------------------------------------------

def gen_src_dep_test():
  return [
    gen_rimm_src_dep_test( 5, "slti",  5, 10,  1 ),
    gen_rimm_src_dep_test( 4, "slti", 15, 10,  0 ),
    gen_rimm_src_dep_test( 3, "slti", 20, 10,  0 ),
    gen_rimm_src_dep_test( 2, "slti",  9, 10,  1 ),
    gen_rimm_src_dep_test( 1, "slti",  1, 10,  1 ),
    gen_rimm_src_dep_test( 0, "slti", 17, 10,  0 ),
  ]

#-------------------------------------------------------------------------
# gen_srcs_dest_test
#-------------------------------------------------------------------------

def gen_srcs_dest_test():
  return [
    gen_rimm_src_eq_dest_test( "slti",    25,     1, 0 ),
    gen_rimm_src_eq_dest_test( "slti",    -1,     0, 1 ),
    gen_rimm_src_eq_dest_test( "slti",    -1,    -2, 0 ),
    gen_rimm_src_eq_dest_test( "slti",     5, 0xfff, 0 ),
    gen_rimm_src_eq_dest_test( "slti",    -5, 0x7ff, 1 ),
    gen_rimm_src_eq_dest_test( "slti", 0x800, 0x800, 0 ),
  ]

#-------------------------------------------------------------------------
# gen_value_test
#-------------------------------------------------------------------------

def gen_value_test():
  return [

    # Equal values
    gen_rimm_value_test( "slti", 0, 0, 0 ),
    gen_rimm_value_test( "slti", 1, 1, 0 ),

    # Positive-positive, large gap
    gen_rimm_value_test( "slti", 1, 0x7ff, 1 ),
    gen_rimm_value_test( "slti", 0x7fffffff, 1, 0 ),

    # Negative-negative, small gap
    gen_rimm_value_test( "slti", -1, -2, 0 ),
    gen_rimm_value_test( "slti", -2, -1, 1 ),

    # Negative-negative, large gap
    gen_rimm_value_test( "slti", -2048, -1, 1 ),
    gen_rimm_value_test( "slti", -1, 0x800, 0 ),

    # Negative source, positive immediate
    gen_rimm_value_test( "slti", -1, 1, 1 ),
    gen_rimm_value_test( "slti", 0x80000000, 0x7ff, 1 ),

    # Positive source, negative immediate
    gen_rimm_value_test( "slti", 1, -1, 0 ),
    gen_rimm_value_test( "slti", 0x7fffffff, 0x800, 0 ),

    # Extreme signed source values
    gen_rimm_value_test( "slti", 0x80000000, 0, 1 ),
    gen_rimm_value_test( "slti", 0x7fffffff, 0, 0 ),

  ]

#-------------------------------------------------------------------------
# gen_random_test
#-------------------------------------------------------------------------

def gen_random_test():
  asm_code = []
  for i in range(100):
    src = b32( random.randint(0,0xffffffff) )
    imm = b12( random.randint(0,0xfff) )
    dest = 1 if src.int() < sext(imm,32).int() else 0
    asm_code.append( gen_rimm_value_test( "slti", src.uint(), 
                                         imm.uint(), dest ) )
  return asm_code
