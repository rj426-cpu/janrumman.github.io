#=========================================================================
# sub
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
    sub x3, x1, x2
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
# Vary the distance between sub and the instruction reading its result
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
      sub  x3, x1, x2
      {nops}
      csrw proc2mngr, x3 > 1
    """ )

  return tests


#-------------------------------------------------------------------------
# gen_src0_dep_test
# Vary the distance between producing rs1 and using it in sub
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
      sub  x3, x1, x2
      csrw proc2mngr, x3 > 1
    """ )

  return tests


#-------------------------------------------------------------------------
# gen_src1_dep_test
# Vary the distance between producing rs2 and using it in sub
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
      sub  x3, x1, x2
      csrw proc2mngr, x3 > 1
    """ )

  return tests


#-------------------------------------------------------------------------
# gen_srcs_dep_test
# Both source registers are produced shortly before sub
#-------------------------------------------------------------------------

def gen_srcs_dep_test():
  tests = []

  for n in range(6):
    nops = "\n".join( ["nop"] * n )
    tests.append( f"""
      csrr x1, mngr2proc < 5
      csrr x2, mngr2proc < 4
      {nops}
      sub  x3, x1, x2
      csrw proc2mngr, x3 > 1
    """ )

  return tests


#-------------------------------------------------------------------------
# gen_srcs_dest_test
# Destination overlaps one or both source registers
#-------------------------------------------------------------------------

def gen_srcs_dest_test():
  return [
    """
      csrr x1, mngr2proc < 5
      csrr x2, mngr2proc < 4
      sub  x1, x1, x2
      csrw proc2mngr, x1 > 1
    """,
    """
      csrr x1, mngr2proc < 5
      csrr x2, mngr2proc < 4
      sub  x2, x1, x2
      csrw proc2mngr, x2 > 1
    """,
    """
      csrr x1, mngr2proc < 5
      sub  x1, x1, x1
      csrw proc2mngr, x1 > 0
    """,
  ]


#-------------------------------------------------------------------------
# gen_back_to_back_test
# Two consecutive sub instructions both produce the correct result
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
    sub  x3, x1, x2
    sub  x4, x2, x1
    csrw proc2mngr, x3 > 0x00000001
    csrw proc2mngr, x4 > 0xffffffff
  """


#-------------------------------------------------------------------------
# gen_value_test
# Operand order, zero, negative results, and 32-bit wraparound
#-------------------------------------------------------------------------

def gen_value_test():
  pairs = [
    (0x00000000, 0x00000000),
    (0x00000001, 0x00000000),
    (0x00000000, 0x00000001),
    (0x00000005, 0x00000004),
    (0x00000004, 0x00000005),
    (0x80000000, 0x00000001),
    (0x7fffffff, 0xffffffff),
    (0xffffffff, 0xffffffff),
  ]

  tests = []

  for a, b in pairs:
    result = (a - b) & 0xffffffff
    tests.append( f"""
      csrr x1, mngr2proc < 0x{a:08x}
      csrr x2, mngr2proc < 0x{b:08x}
      sub  x3, x1, x2
      csrw proc2mngr, x3 > 0x{result:08x}
    """ )

  return tests


#-------------------------------------------------------------------------
# gen_random_test
# Reproducible random operands and dependency distances
#-------------------------------------------------------------------------

def gen_random_test():
  rng = random.Random(0xdeadbeef)
  tests = []

  for i in range(100):
    a = rng.getrandbits(32)
    b = rng.getrandbits(32)
    result = (a - b) & 0xffffffff

    src_nops  = "\n".join( ["nop"] * rng.randrange(6) )
    dest_nops = "\n".join( ["nop"] * rng.randrange(6) )

    tests.append( f"""
      csrr x1, mngr2proc < 0x{a:08x}
      csrr x2, mngr2proc < 0x{b:08x}
      {src_nops}
      sub  x3, x1, x2
      {dest_nops}
      csrw proc2mngr, x3 > 0x{result:08x}
    """ )

  return tests