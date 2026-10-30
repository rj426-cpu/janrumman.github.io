#=========================================================================
# ProcDpathImmGen unit tests
#=========================================================================

from pymtl3 import *
from pymtl3.stdlib.test_utils import run_test_vector_sim

from lab2_proc.ProcDpathImmGen import ProcDpathImmGen

#-------------------------------------------------------------------------
# test I-type
#-------------------------------------------------------------------------

def test_immgen_i( cmdline_opts ):
  dut = ProcDpathImmGen()

  run_test_vector_sim( dut, [
    ('imm_type inst                                imm*'),
    [ 0,       0b11111111111100000000000000000000, 0b11111111111111111111111111111111],
    [ 0,       0b00000000000011111111111111111111, 0b00000000000000000000000000000000],
    [ 0,       0b01111111111100000000000000000000, 0b00000000000000000000011111111111],
    [ 0,       0b11111111111000000000000000000000, 0b11111111111111111111111111111110],
  ], cmdline_opts )

#-------------------------------------------------------------------------
# test U-type
#-------------------------------------------------------------------------

def test_immgen_u( cmdline_opts ):
  dut = ProcDpathImmGen()

  run_test_vector_sim( dut, [
    ('imm_type inst       imm*'),
    [ 3,       0x00001000, 0x00001000 ],
    [ 3,       0x12345fff, 0x12345000 ],
    [ 3,       0xabcde123, 0xabcde000 ],
    [ 3,       0xffffffff, 0xfffff000 ],
  ], cmdline_opts )
  
#-------------------------------------------------------------------------
# test S-type
#-------------------------------------------------------------------------

def test_immgen_s( cmdline_opts ):
  dut = ProcDpathImmGen()

  run_test_vector_sim( dut, [
    ('imm_type inst       imm*'),
    [ 1,       0x00000013, 0x00000000 ], # zero
    [ 1,       0x00000093, 0x00000001 ], # low immediate bit
    [ 1,       0x00000f93, 0x0000001f ], # inst[11:7]
    [ 1,       0x02000013, 0x00000020 ], # inst[31:25]
    [ 1,       0x7e000f93, 0x000007ff ], # largest positive
    [ 1,       0xfe000f93, 0xffffffff ], # -1
    [ 1,       0xfe000813, 0xfffffff0 ], # -16
    [ 1,       0x80000013, 0xfffff800 ], # most negative
  ], cmdline_opts )


#-------------------------------------------------------------------------
# extra B-type cases
#-------------------------------------------------------------------------

def test_immgen_b_edges( cmdline_opts ):
  dut = ProcDpathImmGen()

  run_test_vector_sim( dut, [
    ('imm_type inst       imm*'),
    [ 2,       0x00000013, 0x00000000 ], # zero
    [ 2,       0x00000113, 0x00000002 ], # displacement bit 1
    [ 2,       0x00000813, 0x00000010 ], # inst[11:8]
    [ 2,       0x02000013, 0x00000020 ], # inst[30:25]
    [ 2,       0x00000093, 0x00000800 ], # inst[7] becomes bit 11
    [ 2,       0x80000013, 0xfffff000 ], # sign bit
    [ 2,       0x7e000f93, 0x00000ffe ], # largest positive
    [ 2,       0xfe000f93, 0xfffffffe ], # -2
  ], cmdline_opts )


#-------------------------------------------------------------------------
# test J-type
#-------------------------------------------------------------------------

def test_immgen_j( cmdline_opts ):
  dut = ProcDpathImmGen()

  run_test_vector_sim( dut, [
    ('imm_type inst       imm*'),
    [ 4,       0x00000013, 0x00000000 ], # zero
    [ 4,       0x00200013, 0x00000002 ], # displacement bit 1
    [ 4,       0x40000013, 0x00000400 ], # inst[30:21]
    [ 4,       0x00100013, 0x00000800 ], # inst[20] becomes bit 11
    [ 4,       0x00001013, 0x00001000 ], # inst[19:12]
    [ 4,       0x7ffff013, 0x000ffffe ], # largest positive
    [ 4,       0xfffff013, 0xfffffffe ], # -2
    [ 4,       0x80000013, 0xfff00000 ], # most negative
  ], cmdline_opts )
  
  