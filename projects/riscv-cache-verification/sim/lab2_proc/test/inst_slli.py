#=========================================================================
# slli
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
    csrr x1, mngr2proc < 0x80008000
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    slli x3, x1, 0x03
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    csrw proc2mngr, x3 > 0x00040000
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
    gen_rimm_dest_dep_test( 5, "slli", 0x100, 1, 0x200  ),
    gen_rimm_dest_dep_test( 4, "slli", 0x200, 1, 0x400  ),
    gen_rimm_dest_dep_test( 3, "slli", 0x400, 1, 0x800  ),
    gen_rimm_dest_dep_test( 2, "slli", 0x800, 1, 0x1000 ),
    gen_rimm_dest_dep_test( 1, "slli", 0x100, 2, 0x400  ),
    gen_rimm_dest_dep_test( 0, "slli", 0x200, 2, 0x800  ),
  ]

#-------------------------------------------------------------------------
# gen_src_dep_test
#-------------------------------------------------------------------------

def gen_src_dep_test():
  return [
    gen_rimm_src_dep_test( 5, "slli", 0x100, 1, 0x200  ),
    gen_rimm_src_dep_test( 4, "slli", 0x200, 1, 0x400  ),
    gen_rimm_src_dep_test( 3, "slli", 0x400, 1, 0x800  ),
    gen_rimm_src_dep_test( 2, "slli", 0x800, 1, 0x1000 ),
    gen_rimm_src_dep_test( 1, "slli", 0x100, 2, 0x400  ),
    gen_rimm_src_dep_test( 0, "slli", 0x200, 2, 0x800  ),
  ]

#-------------------------------------------------------------------------
# gen_srcs_dest_test
#-------------------------------------------------------------------------

def gen_srcs_dest_test():
  return [
    gen_rimm_src_eq_dest_test( "slli",  1, 1, 2   ),
    gen_rimm_src_eq_dest_test( "slli",  2, 2, 8   ),
    gen_rimm_src_eq_dest_test( "slli",  4, 3, 32  ),
    gen_rimm_src_eq_dest_test( "slli", 16, 1, 32  ),
    gen_rimm_src_eq_dest_test( "slli", 16, 2, 64  ),
    gen_rimm_src_eq_dest_test( "slli", 16, 3, 128 ),
  ]

#-------------------------------------------------------------------------
# gen_value_test
#-------------------------------------------------------------------------

def gen_value_test():
  return [

    # Zero
    gen_rimm_value_test( "slli", 0, 0, 0 ),
    gen_rimm_value_test( "slli", 0, 10, 0 ),

    # Shift by zero
    gen_rimm_value_test( "slli", 16, 0, 16 ),
    gen_rimm_value_test( "slli", 0xffffffff, 0, 0xffffffff  ),

    # Left Bits Fall Off
    gen_rimm_value_test( "slli", 0x80000000, 1, 0 ),
    gen_rimm_value_test( "slli", 0x40000000, 1, 0x80000000),

    # All ones 
    gen_rimm_value_test( "slli", 0xffffffff, 1, 0xfffffffe ),
    gen_rimm_value_test( "slli", 0xffffffff, 4, 0xfffffff0 ),

    # Max Shift 
    gen_rimm_value_test( "slli", 1, 31, 0x80000000 ),
    gen_rimm_value_test( "slli", 2, 31, 0),
  ]

#-------------------------------------------------------------------------
# gen_random_test
#-------------------------------------------------------------------------

def gen_random_test():
  asm_code = []

  for i in range(100):

    src   = b32( random.randint(0,0xffffffff) )
    shamt = random.randint(0,31)
    dest  = b32( (src.uint() << shamt) & 0xffffffff )

    asm_code.append(
      gen_rimm_value_test(
        "slli", src.uint(), shamt, dest.uint()
      )
    )

  return asm_code