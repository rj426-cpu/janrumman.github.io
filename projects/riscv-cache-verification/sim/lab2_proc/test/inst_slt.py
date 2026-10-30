#=========================================================================
# slt
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
    csrr x1, mngr2proc < 4
    csrr x2, mngr2proc < 5
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    slt x3, x1, x2
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
# Vary the distance before consuming the SLT result
#-------------------------------------------------------------------------

def gen_dest_dep_test():
  tests = []

  for n in range(6):
    nops = "\n".join( ["nop"] * n )
    tests.append( f"""
      csrr x1, mngr2proc < 4
      csrr x2, mngr2proc < 5
      nop
      nop
      nop
      nop
      nop
      slt  x3, x1, x2
      {nops}
      csrw proc2mngr, x3 > 1
    """ )

  return tests


#-------------------------------------------------------------------------
# gen_src0_dep_test
# Vary the distance between producing rs1 and using it in SLT
#-------------------------------------------------------------------------

def gen_src0_dep_test():
  tests = []

  for n in range(6):
    nops = "\n".join( ["nop"] * n )
    tests.append( f"""
      csrr x2, mngr2proc < 5
      nop
      nop
      nop
      nop
      nop
      csrr x1, mngr2proc < 4
      {nops}
      slt  x3, x1, x2
      csrw proc2mngr, x3 > 1
    """ )

  return tests


#-------------------------------------------------------------------------
# gen_src1_dep_test
# Vary the distance between producing rs2 and using it in SLT
#-------------------------------------------------------------------------

def gen_src1_dep_test():
  tests = []

  for n in range(6):
    nops = "\n".join( ["nop"] * n )
    tests.append( f"""
      csrr x1, mngr2proc < 4
      nop
      nop
      nop
      nop
      nop
      csrr x2, mngr2proc < 5
      {nops}
      slt  x3, x1, x2
      csrw proc2mngr, x3 > 1
    """ )

  return tests


#-------------------------------------------------------------------------
# gen_srcs_dep_test
# Both sources are produced shortly before SLT
#-------------------------------------------------------------------------

def gen_srcs_dep_test():
  tests = []

  for n in range(6):
    nops = "\n".join( ["nop"] * n )
    tests.append( f"""
      csrr x1, mngr2proc < 4
      csrr x2, mngr2proc < 5
      {nops}
      slt  x3, x1, x2
      csrw proc2mngr, x3 > 1
    """ )

  return tests


#-------------------------------------------------------------------------
# gen_srcs_dest_test
# Destination overlaps a source; equal sources compare false
#-------------------------------------------------------------------------

def gen_srcs_dest_test():
  return [
    """
      csrr x1, mngr2proc < 4
      csrr x2, mngr2proc < 5
      slt  x1, x1, x2
      csrw proc2mngr, x1 > 1
    """,
    """
      csrr x1, mngr2proc < 4
      csrr x2, mngr2proc < 5
      slt  x2, x1, x2
      csrw proc2mngr, x2 > 1
    """,
    """
      csrr x1, mngr2proc < 4
      slt  x1, x1, x1
      csrw proc2mngr, x1 > 0
    """,
  ]


#-------------------------------------------------------------------------
# gen_back_to_back_test
# Consecutive comparisons produce different results
#-------------------------------------------------------------------------

def gen_back_to_back_test():
  return """
    csrr x1, mngr2proc < 4
    csrr x2, mngr2proc < 5
    nop
    nop
    nop
    nop
    nop
    slt  x3, x1, x2
    slt  x4, x2, x1
    csrw proc2mngr, x3 > 1
    csrw proc2mngr, x4 > 0
  """


#-------------------------------------------------------------------------
# gen_value_test
# Signed edge cases and operand order
#-------------------------------------------------------------------------

def gen_value_test():
  pairs = [
    (0x00000000, 0x00000000, 0),
    (0x00000004, 0x00000005, 1),
    (0x00000005, 0x00000004, 0),
    (0xffffffff, 0x00000000, 1), # -1 < 0
    (0x00000000, 0xffffffff, 0), # 0 < -1 is false
    (0x80000000, 0x7fffffff, 1), # smallest signed < largest signed
    (0x7fffffff, 0x80000000, 0),
    (0xffffffff, 0xfffffffe, 0), # -1 < -2 is false
    (0xfffffffe, 0xffffffff, 1), # -2 < -1
  ]

  tests = []

  for a, b, result in pairs:
    tests.append( f"""
      csrr x1, mngr2proc < 0x{a:08x}
      csrr x2, mngr2proc < 0x{b:08x}
      slt  x3, x1, x2
      csrw proc2mngr, x3 > {result}
    """ )

  return tests


#-------------------------------------------------------------------------
# gen_random_test
# Reproducible random signed comparisons and dependency distances
#-------------------------------------------------------------------------

def gen_random_test():
  rng = random.Random(0xdeadbeef)
  tests = []

  for i in range(100):
    a = rng.getrandbits(32)
    b = rng.getrandbits(32)

    signed_a = a if a < 0x80000000 else a - 0x100000000
    signed_b = b if b < 0x80000000 else b - 0x100000000
    result = int( signed_a < signed_b )

    src_nops  = "\n".join( ["nop"] * rng.randrange(6) )
    dest_nops = "\n".join( ["nop"] * rng.randrange(6) )

    tests.append( f"""
      csrr x1, mngr2proc < 0x{a:08x}
      csrr x2, mngr2proc < 0x{b:08x}
      {src_nops}
      slt  x3, x1, x2
      {dest_nops}
      csrw proc2mngr, x3 > {result}
    """ )

  return tests