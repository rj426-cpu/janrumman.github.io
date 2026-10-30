#=========================================================================
# lui
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
    lui x1, 0x0001
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    csrw proc2mngr, x1 > 0x00001000
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
  """

#=========================================================================
# lui
#=========================================================================

import random

# Fix the random seed so results are reproducible
random.seed(0xdeadbeef)

from pymtl3 import *
from lab2_proc.test.inst_utils import *

#-------------------------------------------------------------------------
# gen_dest_dep_test
#-------------------------------------------------------------------------

def gen_dest_dep_test():
  return [

    gen_imm_dest_dep_test( 5, "lui", 0x01, 0x00001000 ),
    gen_imm_dest_dep_test( 4, "lui", 0x02, 0x00002000 ),
    gen_imm_dest_dep_test( 3, "lui", 0x04, 0x00004000 ),
    gen_imm_dest_dep_test( 2, "lui", 0x08, 0x00008000 ),
    gen_imm_dest_dep_test( 1, "lui", 0x10, 0x00010000 ),
    gen_imm_dest_dep_test( 0, "lui", 0x20, 0x00020000 ),

  ]

#-------------------------------------------------------------------------
# gen_value_test¥y
#-------------------------------------------------------------------------

def gen_value_test():
  return [

    # Zero
    gen_imm_value_test( "lui",  0x00000, 0x00000000 ),

    # Bit Patterns
    gen_imm_value_test( "lui",  0x12345, 0x12345000 ),
    gen_imm_value_test( "lui",  0x80000, 0x80000000 ),
    gen_imm_value_test( "lui",  0xfffff, 0xfffff000 ),
  ]

#-------------------------------------------------------------------------
# gen_random_test
#-------------------------------------------------------------------------

def gen_random_test():
  asm_code = []
  for i in range(100):
    imm = b32( random.randint( 0, 0xfffff ) )
    dest = b32( imm << 12 )
    asm_code.append( gen_imm_value_test( "lui",
                                         imm.uint(), dest.uint() ) )
  return asm_code


