#=========================================================================
# srl
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
    csrr x2, mngr2proc < 0x00000003
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    srl x3, x1, x2
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
# Reference result for a 32-bit logical right shift
#-------------------------------------------------------------------------

def srl_result( value, shift_amount ):
  return (value & 0xffffffff) >> (shift_amount & 0x1f)


#-------------------------------------------------------------------------
# gen_dest_dep_test
# Vary the distance before consuming the SRL result
#-------------------------------------------------------------------------

def gen_dest_dep_test():
  tests = []

  for n in range(6):
    nops = "\n".join( ["nop"] * n )
    tests.append( f"""
      csrr x1, mngr2proc < 0x80000000
      csrr x2, mngr2proc < 3
      nop
      nop
      nop
      nop
      nop
      srl  x3, x1, x2
      {nops}
      csrw proc2mngr, x3 > 0x10000000
    """ )

  return tests


#-------------------------------------------------------------------------
# gen_src0_dep_test
# Vary the distance between producing rs1 and using it in SRL
#-------------------------------------------------------------------------

def gen_src0_dep_test():
  tests = []

  for n in range(6):
    nops = "\n".join( ["nop"] * n )
    tests.append( f"""
      csrr x2, mngr2proc < 3
      nop
      nop
      nop
      nop
      nop
      csrr x1, mngr2proc < 0x80000000
      {nops}
      srl  x3, x1, x2
      csrw proc2mngr, x3 > 0x10000000
    """ )

  return tests


#-------------------------------------------------------------------------
# gen_src1_dep_test
# Vary the distance between producing rs2 and using it in SRL
#-------------------------------------------------------------------------

def gen_src1_dep_test():
  tests = []

  for n in range(6):
    nops = "\n".join( ["nop"] * n )
    tests.append( f"""
      csrr x1, mngr2proc < 0x80000000
      nop
      nop
      nop
      nop
      nop
      csrr x2, mngr2proc < 3
      {nops}
      srl  x3, x1, x2
      csrw proc2mngr, x3 > 0x10000000
    """ )

  return tests


#-------------------------------------------------------------------------
# gen_srcs_dep_test
# Both sources are produced shortly before SRL
#-------------------------------------------------------------------------

def gen_srcs_dep_test():
  tests = []

  for n in range(6):
    nops = "\n".join( ["nop"] * n )
    tests.append( f"""
      csrr x1, mngr2proc < 0x80000000
      csrr x2, mngr2proc < 3
      {nops}
      srl  x3, x1, x2
      csrw proc2mngr, x3 > 0x10000000
    """ )

  return tests


#-------------------------------------------------------------------------
# gen_srcs_dest_test
# Destination overlaps a source register
#-------------------------------------------------------------------------

def gen_srcs_dest_test():
  return [
    """
      csrr x1, mngr2proc < 0x80000000
      csrr x2, mngr2proc < 3
      srl  x1, x1, x2
      csrw proc2mngr, x1 > 0x10000000
    """,
    """
      csrr x1, mngr2proc < 0x80000000
      csrr x2, mngr2proc < 3
      srl  x2, x1, x2
      csrw proc2mngr, x2 > 0x10000000
    """,
    """
      csrr x1, mngr2proc < 0x80000000
      srl  x1, x1, x1
      csrw proc2mngr, x1 > 0x80000000
    """,
  ]


#-------------------------------------------------------------------------
# gen_back_to_back_test
# Consecutive logical shifts both produce the correct result
#-------------------------------------------------------------------------

def gen_back_to_back_test():
  return """
    csrr x1, mngr2proc < 0x80000000
    csrr x2, mngr2proc < 3
    csrr x5, mngr2proc < 31
    nop
    nop
    nop
    nop
    nop
    srl  x3, x1, x2
    srl  x4, x1, x5
    csrw proc2mngr, x3 > 0x10000000
    csrw proc2mngr, x4 > 0x00000001
  """


#-------------------------------------------------------------------------
# gen_value_test
# Zero filling, shift extremes, and low-five-bit masking
#-------------------------------------------------------------------------

def gen_value_test():
  pairs = [
    (0x80000000, 0),
    (0x80000000, 1),
    (0x80000000, 31),
    (0xffffffff, 1),
    (0xffffffff, 31),
    (0x7fffffff, 1),
    (0x7fffffff, 31),
    (0x80000001, 4),
    (0x80000000, 32), # 32 & 31 = 0
    (0x80000000, 33), # 33 & 31 = 1
  ]

  tests = []

  for value, shift_amount in pairs:
    result = srl_result( value, shift_amount )
    tests.append( f"""
      csrr x1, mngr2proc < 0x{value:08x}
      csrr x2, mngr2proc < 0x{shift_amount:08x}
      srl  x3, x1, x2
      csrw proc2mngr, x3 > 0x{result:08x}
    """ )

  return tests


#-------------------------------------------------------------------------
# gen_random_test
# Reproducible random values, shift amounts, and dependency distances
#-------------------------------------------------------------------------

def gen_random_test():
  rng = random.Random(0xdeadbeef)
  tests = []

  for i in range(100):
    value = rng.getrandbits(32)
    shift_amount = rng.getrandbits(32)
    result = srl_result( value, shift_amount )

    src_nops  = "\n".join( ["nop"] * rng.randrange(6) )
    dest_nops = "\n".join( ["nop"] * rng.randrange(6) )

    tests.append( f"""
      csrr x1, mngr2proc < 0x{value:08x}
      csrr x2, mngr2proc < 0x{shift_amount:08x}
      {src_nops}
      srl  x3, x1, x2
      {dest_nops}
      csrw proc2mngr, x3 > 0x{result:08x}
    """ )

  return tests