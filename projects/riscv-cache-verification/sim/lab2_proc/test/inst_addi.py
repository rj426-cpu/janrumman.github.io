#=========================================================================
# addi
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
    addi x3, x1, 0x0004
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    csrw proc2mngr, x3 > 9
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
    gen_rimm_dest_dep_test( 5, "addi", 1, 1, 2 ),
    gen_rimm_dest_dep_test( 4, "addi", 2, 1, 3 ),
    gen_rimm_dest_dep_test( 3, "addi", 3, 1, 4 ),
    gen_rimm_dest_dep_test( 2, "addi", 4, 1, 5 ),
    gen_rimm_dest_dep_test( 1, "addi", 5, 1, 6 ),
    gen_rimm_dest_dep_test( 0, "addi", 6, 1, 7 ),
  ]

#-------------------------------------------------------------------------
# gen_src_dep_test
#-------------------------------------------------------------------------

def gen_src_dep_test():
  return [
    gen_rimm_src_dep_test( 5, "addi",  7, 1,  8 ),
    gen_rimm_src_dep_test( 4, "addi",  8, 1,  9 ),
    gen_rimm_src_dep_test( 3, "addi",  9, 1, 10 ),
    gen_rimm_src_dep_test( 2, "addi", 10, 1, 11 ),
    gen_rimm_src_dep_test( 1, "addi", 11, 1, 12 ),
    gen_rimm_src_dep_test( 0, "addi", 12, 1, 13 ),
  ]

#-------------------------------------------------------------------------
# gen_srcs_dest_test
#-------------------------------------------------------------------------

def gen_srcs_dest_test():
  return [
    gen_rimm_src_eq_dest_test( "addi",    25,     1,    26 ),
    gen_rimm_src_eq_dest_test( "addi",    26,     0,    26 ),
    gen_rimm_src_eq_dest_test( "addi",    28, 0xfff,    27 ),
    gen_rimm_src_eq_dest_test( "addi",    28, 0x7ff, 0x81b ),
    gen_rimm_src_eq_dest_test( "addi", 0x800, 0x800,     0 ),
  ]

#-------------------------------------------------------------------------
# gen_value_test
#-------------------------------------------------------------------------

def gen_value_test():
  return [

    # Basic values
    gen_rimm_value_test( "addi", 0x00000000, 0x000, 0x00000000 ),
    gen_rimm_value_test( "addi", 0x00000001, 0x001, 0x00000002 ),
    gen_rimm_value_test( "addi", 0x00000003, 0x007, 0x0000000a ),

    # Positive immediates
    gen_rimm_value_test( "addi", 0x00000000, 0x7ff, 0x000007ff ),
    gen_rimm_value_test( "addi", 0x80000000, 0x7ff, 0x800007ff ),
    gen_rimm_value_test( "addi", 0x7fffffff, 0x001, 0x80000000 ),

    # Sign extension
    gen_rimm_value_test( "addi", 0x00000000, 0xfff, 0xffffffff ),
    gen_rimm_value_test( "addi", 0x00000001, 0xfff, 0x00000000 ),
    gen_rimm_value_test( "addi", 0x80000000, 0xfff, 0x7fffffff ),

    # Most negative 12-bit immediate
    gen_rimm_value_test( "addi", 0x00000000, 0x800, 0xfffff800 ),
    gen_rimm_value_test( "addi", 0x00000800, 0x800, 0x00000000 ),
    gen_rimm_value_test( "addi", 0x80000000, 0x800, 0x7ffff800 ),

    # Overflow 
    gen_rimm_value_test( "addi", 0xffffffff, 0x001, 0x00000000 ),
    gen_rimm_value_test( "addi", 0x7fffffff, 0x001, 0x80000000 ),

    # Negative source + negative immediate 
    gen_rimm_value_test( "addi", 0xffffffff, 0xfff, 0xfffffffe ),
  ]

#-------------------------------------------------------------------------
# gen_random_test
#-------------------------------------------------------------------------

def gen_random_test():
  asm_code = []
  for i in range(100):
    src = b32( random.randint(0,0xffffffff) )
    imm = b12( random.randint(0,0xfff) )
    dest = src + sext(imm, 32)
    asm_code.append( gen_rimm_value_test( "addi", src.uint(), 
                                         imm.uint(), dest.uint() ) )
  return asm_code
