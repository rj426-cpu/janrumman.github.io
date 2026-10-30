#=========================================================================
# sw
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
    csrr x1, mngr2proc < 0x00002000
    csrr x2, mngr2proc < 0xdeadbeef
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    sw   x2, 0(x1)
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    lw   x3, 0(x1)
    csrw proc2mngr, x3 > 0xdeadbeef

    .data
    .word 0x01020304
  """

#-------------------------------------------------------------------------
# Base-address dependencies: 0–5 nops before sw
#-------------------------------------------------------------------------

def gen_single_base_dep_test( num_nops ):
  nops = "\n".join( ["nop"] * num_nops )
  return f"""
    csrr x2, mngr2proc < 0xdeadbeef
    nop
    nop
    nop
    nop
    nop
    csrr x1, mngr2proc < 0x00002000
    {nops}
    sw   x2, 0(x1)
    lw   x3, 0(x1)
    csrw proc2mngr, x3 > 0xdeadbeef

    .data
    .word 0x01020304
  """

def gen_base_dep_test():
  return [ gen_single_base_dep_test(n) for n in range(6) ]


#-------------------------------------------------------------------------
# Store-data dependencies: 0–5 nops before sw
#-------------------------------------------------------------------------

def gen_single_data_dep_test( num_nops ):
  nops = "\n".join( ["nop"] * num_nops )
  return f"""
    csrr x1, mngr2proc < 0x00002000
    nop
    nop
    nop
    nop
    nop
    csrr x2, mngr2proc < 0xdeadbeef
    {nops}
    sw   x2, 0(x1)
    lw   x3, 0(x1)
    csrw proc2mngr, x3 > 0xdeadbeef

    .data
    .word 0x01020304
  """

def gen_data_dep_test():
  return [ gen_single_data_dep_test(n) for n in range(6) ]


#-------------------------------------------------------------------------
# Same register supplies both base address and store data
#-------------------------------------------------------------------------

def gen_same_reg_test():
  return """
    csrr x1, mngr2proc < 0x00002000
    sw   x1, 0(x1)
    lw   x2, 0(x1)
    csrw proc2mngr, x2 > 0x00002000

    .data
    .word 0x01020304
  """


#-------------------------------------------------------------------------
# Consecutive stores must both reach memory
#-------------------------------------------------------------------------

def gen_back_to_back_test():
  return """
    csrr x1, mngr2proc < 0x00002000
    csrr x2, mngr2proc < 0x11223344
    csrr x3, mngr2proc < 0xaabbccdd
    nop
    nop
    nop
    nop
    nop

    sw   x2, 0(x1)
    sw   x3, 4(x1)

    lw   x4, 0(x1)
    csrw proc2mngr, x4 > 0x11223344
    lw   x4, 4(x1)
    csrw proc2mngr, x4 > 0xaabbccdd

    .data
    .word 0x00000000
    .word 0x00000000
  """


#-------------------------------------------------------------------------
# A load produces the data used by the following store
#-------------------------------------------------------------------------

def gen_load_to_store_test():
  return """
    csrr x1, mngr2proc < 0x00002000
    lw   x2, 0(x1)
    sw   x2, 4(x1)
    lw   x3, 4(x1)
    csrw proc2mngr, x3 > 0xcafebabe

    .data
    .word 0xcafebabe
    .word 0x00000000
  """


#-------------------------------------------------------------------------
# Extremes of the signed 12-bit S-type offset, using aligned addresses
#-------------------------------------------------------------------------

def gen_offset_boundary_test():
  return [
    """
      csrr x1, mngr2proc < 0x00002800
      csrr x2, mngr2proc < 0x13579bdf
      sw   x2, -2048(x1)
      lw   x3, -2048(x1)
      csrw proc2mngr, x3 > 0x13579bdf

      .data
      .word 0x00000000
    """,
    """
      csrr x1, mngr2proc < 0x00002000
      csrr x2, mngr2proc < 0x2468ace0
      sw   x2, 2044(x1)
      lw   x3, 2044(x1)
      csrw proc2mngr, x3 > 0x2468ace0

      .data
      .word 0x00000000
    """,
  ]


#-------------------------------------------------------------------------
# Reproducible random bases, offsets, values, and dependency spacing
#-------------------------------------------------------------------------

def gen_random_test():
  rng = random.Random(0xdeadbeef)
  expected = [0] * 16
  lines = []

  for _ in range(20):
    base_index = rng.randrange(16)
    target_index = rng.randrange(16)
    value = rng.getrandbits(32)
    num_nops = rng.randrange(6)

    base_addr = 0x2000 + 4 * base_index
    offset = 4 * (target_index - base_index)

    lines.append( f"csrr x1, mngr2proc < 0x{base_addr:08x}" )
    lines.append( f"csrr x2, mngr2proc < 0x{value:08x}" )
    lines.extend( ["nop"] * num_nops )
    lines.append( f"sw x2, {offset}(x1)" )

    expected[target_index] = value

  lines.append( "csrr x1, mngr2proc < 0x00002000" )

  for index, value in enumerate(expected):
    lines.append( f"lw x3, {4 * index}(x1)" )
    lines.append( f"csrw proc2mngr, x3 > 0x{value:08x}" )

  lines.append( ".data" )
  lines.extend( [".word 0x00000000"] * 16 )

  return "\n".join(lines)

