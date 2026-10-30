#=========================================================================
# auipc
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
    auipc x1, 0x00010                       # PC=0x200
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    csrw  proc2mngr, x1 > 0x00010200
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

    gen_imm_dest_dep_test( 5, "auipc", 0x1,  0x00001200 ),
    gen_imm_dest_dep_test( 4, "auipc", 0x2,  0x0000221c ),
    gen_imm_dest_dep_test( 3, "auipc", 0x4,  0x00004234 ),
    gen_imm_dest_dep_test( 2, "auipc", 0x8,  0x00008248 ),
    gen_imm_dest_dep_test( 1, "auipc", 0x10, 0x00010258 ),
    gen_imm_dest_dep_test( 0, "auipc", 0x20, 0x00020264 ),

  ]

#-------------------------------------------------------------------------
# gen_value_test
#-------------------------------------------------------------------------

def gen_value_test():
  return [

    # Zero immediate
    gen_imm_value_test( "auipc", 0x00000, 0x00000200 ),

    # Bit patterns
    gen_imm_value_test( "auipc", 0x12345, 0x12345208 ),
    gen_imm_value_test( "auipc", 0x80000, 0x80000210 ),
    gen_imm_value_test( "auipc", 0xfffff, 0xfffff218 ),

  ]
#-------------------------------------------------------------------------
# gen_pc_test
#-------------------------------------------------------------------------

def gen_pc_test():
  return """

    # PC = 0x200
    nop

    # PC = 0x204
    nop

    # PC = 0x208
    auipc x3, 0x1

    # 0x208 + (0x1 << 12) = 0x1208
    csrw proc2mngr, x3 > 0x00001208

  """

#-------------------------------------------------------------------------
# gen_random_test
#-------------------------------------------------------------------------

def gen_random_test():
  asm_code = []

  pc = 0x200

  for i in range(100):

    imm  = random.randint( 0, 0xfffff )
    dest = b32( pc + (imm << 12) )

    asm_code.append(
      gen_imm_value_test( "auipc", imm, dest.uint() )
    )

    pc += 8

  return asm_code


