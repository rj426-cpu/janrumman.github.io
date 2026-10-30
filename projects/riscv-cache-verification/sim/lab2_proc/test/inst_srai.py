#=========================================================================
# srai
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
    csrr x1, mngr2proc < 0x00008000
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    srai x3, x1, 0x03
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    csrw proc2mngr, x3 > 0x00001000
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
    gen_rimm_dest_dep_test( 5, "srai", 0x100, 1, 0x080 ),
    gen_rimm_dest_dep_test( 4, "srai", 0x200, 1, 0x100 ),
    gen_rimm_dest_dep_test( 3, "srai", 0x400, 1, 0x200 ),
    gen_rimm_dest_dep_test( 2, "srai", 0x800, 1, 0x400 ),
    gen_rimm_dest_dep_test( 1, "srai", 0x100, 2, 0x040 ),
    gen_rimm_dest_dep_test( 0, "srai", 0x200, 2, 0x080 ),
  ]

#-------------------------------------------------------------------------
# gen_src_dep_test
#-------------------------------------------------------------------------

def gen_src_dep_test():
  return [
    gen_rimm_src_dep_test( 5, "srai", 0x100, 1, 0x080 ),
    gen_rimm_src_dep_test( 4, "srai", 0x200, 1, 0x100 ),
    gen_rimm_src_dep_test( 3, "srai", 0x400, 1, 0x200 ),
    gen_rimm_src_dep_test( 2, "srai", 0x800, 1, 0x400 ),
    gen_rimm_src_dep_test( 1, "srai", 0x100, 2, 0x040 ),
    gen_rimm_src_dep_test( 0, "srai", 0x200, 2, 0x080 ),
  ]

#-------------------------------------------------------------------------
# gen_srcs_dest_test
#-------------------------------------------------------------------------

def gen_srcs_dest_test():
  return [
    gen_rimm_src_eq_dest_test( "srai",  16,         1,  8          ),
    gen_rimm_src_eq_dest_test( "srai",  32,         2,  8          ),
    gen_rimm_src_eq_dest_test( "srai",  8,          3,  1          ),
    gen_rimm_src_eq_dest_test( "srai", -16,         1, -8          ),
    gen_rimm_src_eq_dest_test( "srai", -1,          5, -1          ),
    gen_rimm_src_eq_dest_test( "srai", 0x80000000,  1, 0xc0000000 ),
  ]

#-------------------------------------------------------------------------
# gen_value_test
#-------------------------------------------------------------------------

def gen_value_test():
  return [

    # Zero
    gen_rimm_value_test( "srai", 0, 0, 0 ),
    gen_rimm_value_test( "srai", 0, 10, 0 ),

    # Shift by zero
    gen_rimm_value_test( "srai", 16, 0, 16 ),
    gen_rimm_value_test( "srai", -16, 0, -16 ),

    # Positive values
    gen_rimm_value_test( "srai", 16, 1, 8 ),
    gen_rimm_value_test( "srai", 16, 2, 4 ),
    gen_rimm_value_test( "srai", 16, 4, 1 ),

    # Sign extension
    gen_rimm_value_test( "srai", -16, 1, -8 ),
    gen_rimm_value_test( "srai", -16, 2, -4 ),
    gen_rimm_value_test( "srai", -16, 4, -1 ),

    # All ones 
    gen_rimm_value_test( "srai", 0xffffffff, 1,  0xffffffff ),
    gen_rimm_value_test( "srai", 0xffffffff, 31, 0xffffffff ),

    # Most negative signed 32-bit value
    gen_rimm_value_test( "srai", 0x80000000, 1,  0xc0000000 ),
    gen_rimm_value_test( "srai", 0x80000000, 31, 0xffffffff ),

    # Largest positive signed 32-bit value
    gen_rimm_value_test( "srai", 0x7fffffff, 1,  0x3fffffff ),
    gen_rimm_value_test( "srai", 0x7fffffff, 31, 0 ),
  ]


#-------------------------------------------------------------------------
# gen_random_test
#-------------------------------------------------------------------------

def gen_random_test():
  asm_code = []

  for i in range(100):

    src   = b32( random.randint(0,0xffffffff) )
    shamt = random.randint(0,31)
    dest  = b32( src.int() >> shamt )

    asm_code.append(
      gen_rimm_value_test(
        "srai", src.uint(), shamt, dest.uint()
      )
    )

  return asm_code