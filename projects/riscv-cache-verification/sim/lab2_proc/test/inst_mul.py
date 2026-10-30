#=========================================================================
# mul
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
    csrr x2, mngr2proc < 4
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    mul x3, x1, x2
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    csrw proc2mngr, x3 > 20
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
# gen_dest_dep_test how soon csrw can consume the multiply result
#-------------------------------------------------------------------------

def gen_dest_dep_test():
  tests = []
  for n in range(6):
    nops = "\n".join( ["nop"] * n )
    tests.append( f"""
      csrr x1, mngr2proc < 5
      csrr x2, mngr2proc < 4
      nop
      nop
      nop
      nop
      nop
      mul  x3, x1, x2
      {nops}
      csrw proc2mngr, x3 > 20
    """ )
  return tests

#-------------------------------------------------------------------------
# gen_src0_dep_test recent write to rs1
#-------------------------------------------------------------------------

def gen_src0_dep_test():
  tests = []
  for n in range(6):
    nops = "\n".join( ["nop"] * n )
    tests.append( f"""
      csrr x2, mngr2proc < 4
      nop
      nop
      nop
      nop
      nop
      csrr x1, mngr2proc < 5
      {nops}
      mul  x3, x1, x2
      csrw proc2mngr, x3 > 20
    """ )
  return tests

#-------------------------------------------------------------------------
# gen_src1_dep_test recent write to rs2
#-------------------------------------------------------------------------

def gen_src1_dep_test():
  tests = []
  for n in range(6):
    nops = "\n".join( ["nop"] * n )
    tests.append( f"""
      csrr x1, mngr2proc < 5
      nop
      nop
      nop
      nop
      nop
      csrr x2, mngr2proc < 4
      {nops}
      mul  x3, x1, x2
      csrw proc2mngr, x3 > 20
    """ )
  return tests

#-------------------------------------------------------------------------
# gen_srcs_dep_test both operands written shortly before mul
#-------------------------------------------------------------------------

def gen_srcs_dep_test():
  tests = []
  for n in range(6):
    nops = "\n".join( ["nop"] * n )
    tests.append( f"""
      csrr x1, mngr2proc < 5
      csrr x2, mngr2proc < 4
      {nops}
      mul  x3, x1, x2
      csrw proc2mngr, x3 > 20
    """ )
  return tests

#-------------------------------------------------------------------------
# gen_srcs_dest_test destination is a source reg
#-------------------------------------------------------------------------

def gen_srcs_dest_test():
  return [
    """
      csrr x1, mngr2proc < 5
      csrr x2, mngr2proc < 4
      mul  x1, x1, x2
      csrw proc2mngr, x1 > 20
    """,
    """
      csrr x1, mngr2proc < 5
      csrr x2, mngr2proc < 4
      mul  x2, x1, x2
      csrw proc2mngr, x2 > 20
    """,
    """
      csrr x1, mngr2proc < 5
      mul  x1, x1, x1
      csrw proc2mngr, x1 > 25
    """,
  ]

#-------------------------------------------------------------------------
# gen_back_to_back_test multiplier accepts a second request after first
#-------------------------------------------------------------------------

def gen_back_to_back_test():
  return """
    csrr x1, mngr2proc < 5
    csrr x2, mngr2proc < 4
    nop
    nop
    nop
    nop
    nop
    mul  x3, x1, x2
    mul  x4, x2, x2
    csrw proc2mngr, x3 > 20
    csrw proc2mngr, x4 > 16
  """

#-------------------------------------------------------------------------
# gen_value_test zero, neg bit patterns, 32 bit overflow
#-------------------------------------------------------------------------

def gen_value_test():
  pairs = [
    (0x00000000, 0xdeadbeef),
    (0x00000001, 0x87654321),
    (0xffffffff, 0x00000002),
    (0x80000000, 0x00000002),
    (0xffffffff, 0xffffffff),
    (0x12345678, 0x00000100),
  ]

  tests = []
  for a, b in pairs:
    result = (a * b) & 0xffffffff
    tests.append( f"""
      csrr x1, mngr2proc < 0x{a:08x}
      csrr x2, mngr2proc < 0x{b:08x}
      mul  x3, x1, x2
      csrw proc2mngr, x3 > 0x{result:08x}
    """ )

  return tests

#-------------------------------------------------------------------------
# gen_random_test
#-------------------------------------------------------------------------

def gen_random_test():
  rng = random.Random(0xdeadbeef)
  asm_code = []

  for i in range(100):
    a = rng.getrandbits(32)
    b = rng.getrandbits(32)
    result = (a * b) & 0xffffffff

    # Vary source and destination dependency distances.
    src_nops  = "\n".join( ["nop"] * rng.randrange(6) )
    dest_nops = "\n".join( ["nop"] * rng.randrange(6) )

    asm_code.append( f"""
      csrr x1, mngr2proc < 0x{a:08x}
      csrr x2, mngr2proc < 0x{b:08x}
      {src_nops}
      mul  x3, x1, x2
      {dest_nops}
      csrw proc2mngr, x3 > 0x{result:08x}
    """ )

  return asm_code
