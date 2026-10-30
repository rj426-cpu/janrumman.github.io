#=========================================================================
# ProcDpathAlu unit tests
#=========================================================================

from pymtl3 import *
from pymtl3.stdlib.test_utils import run_test_vector_sim

from lab2_proc.ProcDpathAlu import ProcDpathAlu

#-------------------------------------------------------------------------
# add
#-------------------------------------------------------------------------

def test_alu_add( cmdline_opts ):
  dut = ProcDpathAlu()

  run_test_vector_sim( dut, [
    ('in0           in1           fn  out*          ops_eq*   ops_lt*  ops_ltu*'),
    [ 0x00000000,   0x00000000,   0,  0x00000000,   '?',      '?',       '?'      ],
    [ 0x0ffaa660,   0x00012304,   0,  0x0ffbc964,   '?',      '?',       '?'      ],
    # pos-neg
    [ 0x00132050,   0xd6620040,   0,  0xd6752090,   '?',      '?',       '?'      ],
    [ 0xfff0a440,   0x00004450,   0,  0xfff0e890,   '?',      '?',       '?'      ],
    # neg-neg
    [ 0xfeeeeaa3,   0xf4650000,   0,  0xf353eaa3,   '?',      '?',       '?'      ],
  ], cmdline_opts )

#-------------------------------------------------------------------------
# add edge cases
#-------------------------------------------------------------------------

def test_alu_add_edges( cmdline_opts ):
  dut = ProcDpathAlu()

  run_test_vector_sim( dut, [
    ('in0        in1         fn out*        ops_eq* ops_lt* ops_ltu*'),
    [ 0xffffffff, 0x00000001, 0, 0x00000000, '?',    '?',    '?' ],
    [ 0x7fffffff, 0x00000001, 0, 0x80000000, '?',    '?',    '?' ],
    [ 0x80000000, 0x80000000, 0, 0x00000000, '?',    '?',    '?' ],
    [ 0xffffffff, 0xffffffff, 0, 0xfffffffe, '?',    '?',    '?' ],
    [ 0x80000000, 0x7fffffff, 0, 0xffffffff, '?',    '?',    '?' ],
  ], cmdline_opts )


#-------------------------------------------------------------------------
# sub: operand order, equality, and wraparound
#-------------------------------------------------------------------------

def test_alu_sub( cmdline_opts ):
  dut = ProcDpathAlu()

  run_test_vector_sim( dut, [
    ('in0        in1         fn out*        ops_eq* ops_lt* ops_ltu*'),
    [ 0x00000005, 0x00000004, 1, 0x00000001, '?',    '?',    '?' ],
    [ 0x00000004, 0x00000005, 1, 0xffffffff, '?',    '?',    '?' ],
    [ 0x00000000, 0x00000001, 1, 0xffffffff, '?',    '?',    '?' ],
    [ 0x00000001, 0x00000000, 1, 0x00000001, '?',    '?',    '?' ],
    [ 0x80000000, 0x00000001, 1, 0x7fffffff, '?',    '?',    '?' ],
    [ 0x7fffffff, 0xffffffff, 1, 0x80000000, '?',    '?',    '?' ],
    [ 0xdeadbeef, 0xdeadbeef, 1, 0x00000000, '?',    '?',    '?' ],
  ], cmdline_opts )


#-------------------------------------------------------------------------
# or
#-------------------------------------------------------------------------

def test_alu_or( cmdline_opts ):
  dut = ProcDpathAlu()

  run_test_vector_sim( dut, [
    ('in0        in1         fn out*        ops_eq* ops_lt* ops_ltu*'),
    [ 0x00000000, 0x00000000, 2, 0x00000000, '?',    '?',    '?' ],
    [ 0xaaaaaaaa, 0x55555555, 2, 0xffffffff, '?',    '?',    '?' ],
    [ 0x12345678, 0x00000000, 2, 0x12345678, '?',    '?',    '?' ],
    [ 0x80000000, 0x00000001, 2, 0x80000001, '?',    '?',    '?' ],
    [ 0x0f0f0f0f, 0x33333333, 2, 0x3f3f3f3f, '?',    '?',    '?' ],
    [ 0xffffffff, 0x12345678, 2, 0xffffffff, '?',    '?',    '?' ],
  ], cmdline_opts )


#-------------------------------------------------------------------------
# and
#-------------------------------------------------------------------------

def test_alu_and( cmdline_opts ):
  dut = ProcDpathAlu()

  run_test_vector_sim( dut, [
    ('in0        in1         fn out*        ops_eq* ops_lt* ops_ltu*'),
    [ 0x00000000, 0xffffffff, 3, 0x00000000, '?',    '?',    '?' ],
    [ 0xaaaaaaaa, 0x55555555, 3, 0x00000000, '?',    '?',    '?' ],
    [ 0x12345678, 0xffffffff, 3, 0x12345678, '?',    '?',    '?' ],
    [ 0x0f0f0f0f, 0x33333333, 3, 0x03030303, '?',    '?',    '?' ],
    [ 0x80000000, 0xffffffff, 3, 0x80000000, '?',    '?',    '?' ],
    [ 0xffffffff, 0xffffffff, 3, 0xffffffff, '?',    '?',    '?' ],
  ], cmdline_opts )


#-------------------------------------------------------------------------
# nand
#-------------------------------------------------------------------------

def test_alu_nand( cmdline_opts ):
  dut = ProcDpathAlu()

  run_test_vector_sim( dut, [
    ('in0        in1         fn out*        ops_eq* ops_lt* ops_ltu*'),
    [ 0x00000000, 0x00000000, 4, 0xffffffff, '?',    '?',    '?' ],
    [ 0xffffffff, 0xffffffff, 4, 0x00000000, '?',    '?',    '?' ],
    [ 0xaaaaaaaa, 0x55555555, 4, 0xffffffff, '?',    '?',    '?' ],
    [ 0x0f0f0f0f, 0x33333333, 4, 0xfcfcfcfc, '?',    '?',    '?' ],
    [ 0x80000000, 0xffffffff, 4, 0x7fffffff, '?',    '?',    '?' ],
  ], cmdline_opts )


#-------------------------------------------------------------------------
# nor
#-------------------------------------------------------------------------

def test_alu_nor( cmdline_opts ):
  dut = ProcDpathAlu()

  run_test_vector_sim( dut, [
    ('in0        in1         fn out*        ops_eq* ops_lt* ops_ltu*'),
    [ 0x00000000, 0x00000000, 5, 0xffffffff, '?',    '?',    '?' ],
    [ 0xffffffff, 0x00000000, 5, 0x00000000, '?',    '?',    '?' ],
    [ 0xaaaaaaaa, 0x55555555, 5, 0x00000000, '?',    '?',    '?' ],
    [ 0x0f0f0f0f, 0x33333333, 5, 0xc0c0c0c0, '?',    '?',    '?' ],
    [ 0x80000000, 0x00000001, 5, 0x7ffffffe, '?',    '?',    '?' ],
  ], cmdline_opts )


#-------------------------------------------------------------------------
# xor
#-------------------------------------------------------------------------

def test_alu_xor( cmdline_opts ):
  dut = ProcDpathAlu()

  run_test_vector_sim( dut, [
    ('in0        in1         fn out*        ops_eq* ops_lt* ops_ltu*'),
    [ 0xdeadbeef, 0xdeadbeef, 6, 0x00000000, '?',    '?',    '?' ],
    [ 0xaaaaaaaa, 0x55555555, 6, 0xffffffff, '?',    '?',    '?' ],
    [ 0x12345678, 0x00000000, 6, 0x12345678, '?',    '?',    '?' ],
    [ 0x0f0f0f0f, 0x33333333, 6, 0x3c3c3c3c, '?',    '?',    '?' ],
    [ 0xffffffff, 0x00000001, 6, 0xfffffffe, '?',    '?',    '?' ],
  ], cmdline_opts )


#-------------------------------------------------------------------------
# xnor
#-------------------------------------------------------------------------

def test_alu_xnor( cmdline_opts ):
  dut = ProcDpathAlu()

  run_test_vector_sim( dut, [
    ('in0        in1         fn out*        ops_eq* ops_lt* ops_ltu*'),
    [ 0xdeadbeef, 0xdeadbeef, 7, 0xffffffff, '?',    '?',    '?' ],
    [ 0xaaaaaaaa, 0x55555555, 7, 0x00000000, '?',    '?',    '?' ],
    [ 0x12345678, 0x00000000, 7, 0xedcba987, '?',    '?',    '?' ],
    [ 0x0f0f0f0f, 0x33333333, 7, 0xc3c3c3c3, '?',    '?',    '?' ],
    [ 0xffffffff, 0x00000001, 7, 0x00000001, '?',    '?',    '?' ],
  ], cmdline_opts )


#-------------------------------------------------------------------------
# sll: overflow and shift amounts use only in1[4:0]
#-------------------------------------------------------------------------

def test_alu_sll( cmdline_opts ):
  dut = ProcDpathAlu()

  run_test_vector_sim( dut, [
    ('in0        in1         fn out*        ops_eq* ops_lt* ops_ltu*'),
    [ 0x00000001, 0x00000000, 8, 0x00000001, '?',    '?',    '?' ],
    [ 0x00000001, 0x0000001f, 8, 0x80000000, '?',    '?',    '?' ],
    [ 0x80000000, 0x00000001, 8, 0x00000000, '?',    '?',    '?' ],
    [ 0xffffffff, 0x00000004, 8, 0xfffffff0, '?',    '?',    '?' ],

    # 32 becomes shift 0; 33 becomes shift 1
    [ 0x12345678, 0x00000020, 8, 0x12345678, '?',    '?',    '?' ],
    [ 0x00000001, 0x00000021, 8, 0x00000002, '?',    '?',    '?' ],
    [ 0x00000001, 0xffffffff, 8, 0x80000000, '?',    '?',    '?' ],
  ], cmdline_opts )


#-------------------------------------------------------------------------
# srl: zeros must enter from the left
#-------------------------------------------------------------------------

def test_alu_srl( cmdline_opts ):
  dut = ProcDpathAlu()

  run_test_vector_sim( dut, [
    ('in0        in1         fn out*        ops_eq* ops_lt* ops_ltu*'),
    [ 0x80000000, 0x00000000, 9, 0x80000000, '?',    '?',    '?' ],
    [ 0x80000000, 0x00000001, 9, 0x40000000, '?',    '?',    '?' ],
    [ 0xffffffff, 0x0000001f, 9, 0x00000001, '?',    '?',    '?' ],
    [ 0x00000001, 0x00000001, 9, 0x00000000, '?',    '?',    '?' ],
    [ 0x80000001, 0x00000020, 9, 0x80000001, '?',    '?',    '?' ],
    [ 0x80000000, 0x00000021, 9, 0x40000000, '?',    '?',    '?' ],
    [ 0x80000000, 0xffffffff, 9, 0x00000001, '?',    '?',    '?' ],
  ], cmdline_opts )


#-------------------------------------------------------------------------
# sra: preserve the sign when shifting right
#-------------------------------------------------------------------------

def test_alu_sra( cmdline_opts ):
  dut = ProcDpathAlu()

  run_test_vector_sim( dut, [
    ('in0        in1         fn out*        ops_eq* ops_lt* ops_ltu*'),
    [ 0x80000000, 0x00000000, 10, 0x80000000, '?',   '?',    '?' ],
    [ 0x80000000, 0x00000001, 10, 0xc0000000, '?',   '?',    '?' ],
    [ 0x80000000, 0x0000001f, 10, 0xffffffff, '?',   '?',    '?' ],
    [ 0x7fffffff, 0x0000001f, 10, 0x00000000, '?',   '?',    '?' ],
    [ 0xffffffff, 0x00000011, 10, 0xffffffff, '?',   '?',    '?' ],
    [ 0x80000001, 0x00000020, 10, 0x80000001, '?',   '?',    '?' ],
    [ 0x80000000, 0x00000021, 10, 0xc0000000, '?',   '?',    '?' ],
    [ 0x80000000, 0xffffffff, 10, 0xffffffff, '?',   '?',    '?' ],
  ], cmdline_opts )


#-------------------------------------------------------------------------
# slt: signed comparison and equality
#-------------------------------------------------------------------------

def test_alu_slt( cmdline_opts ):
  dut = ProcDpathAlu()

  run_test_vector_sim( dut, [
    ('in0        in1         fn out*        ops_eq* ops_lt* ops_ltu*'),
    [ 0x00000000, 0x00000000, 13, 0x00000000, '?',   '?',    '?' ],
    [ 0x00000004, 0x00000005, 13, 0x00000001, '?',   '?',    '?' ],
    [ 0x00000005, 0x00000004, 13, 0x00000000, '?',   '?',    '?' ],

    # -1 < 0, but 0 is not less than -1
    [ 0xffffffff, 0x00000000, 13, 0x00000001, '?',   '?',    '?' ],
    [ 0x00000000, 0xffffffff, 13, 0x00000000, '?',   '?',    '?' ],

    # Most negative versus largest positive signed value
    [ 0x80000000, 0x7fffffff, 13, 0x00000001, '?',   '?',    '?' ],
    [ 0x7fffffff, 0x80000000, 13, 0x00000000, '?',   '?',    '?' ],

    # Two negative values and equal negative values
    [ 0xfffffffe, 0xffffffff, 13, 0x00000001, '?',   '?',    '?' ],
    [ 0xffffffff, 0xfffffffe, 13, 0x00000000, '?',   '?',    '?' ],
    [ 0x80000000, 0x80000000, 13, 0x00000000, '?',   '?',    '?' ],
  ], cmdline_opts )


#-------------------------------------------------------------------------
# comparison flags: signed and unsigned interpretations differ
#-------------------------------------------------------------------------

def test_alu_comparison_flags( cmdline_opts ):
  dut = ProcDpathAlu()

  run_test_vector_sim( dut, [
    ('in0        in1         fn out* ops_eq* ops_lt* ops_ltu*'),

    # Equal operands
    [ 0x00000000, 0x00000000, 0, '?', 1,      0,      0 ],
    [ 0xdeadbeef, 0xdeadbeef, 0, '?', 1,      0,      0 ],
    [ 0xffffffff, 0xffffffff, 0, '?', 1,      0,      0 ],

    # Positive operands
    [ 0x00000001, 0x00000002, 0, '?', 0,      1,      1 ],
    [ 0x00000002, 0x00000001, 0, '?', 0,      0,      0 ],

    # Opposite signs: signed and unsigned results disagree
    [ 0xffffffff, 0x00000000, 0, '?', 0,      1,      0 ],
    [ 0x00000000, 0xffffffff, 0, '?', 0,      0,      1 ],
    [ 0x80000000, 0x7fffffff, 0, '?', 0,      1,      0 ],
    [ 0x7fffffff, 0x80000000, 0, '?', 0,      0,      1 ],

    # Both negative: -2 < -1
    [ 0xfffffffe, 0xffffffff, 0, '?', 0,      1,      1 ],
    [ 0xffffffff, 0xfffffffe, 0, '?', 0,      0,      0 ],
  ], cmdline_opts )
  
#-------------------------------------------------------------------------
# cp_op0
#-------------------------------------------------------------------------

def test_alu_cp_op0( cmdline_opts ):
  dut = ProcDpathAlu()

  run_test_vector_sim( dut, [
    ('in0           in1           fn  out*          ops_eq*   ops_lt*  ops_ltu*'),
    [ 0x00000000,   0x00000000,  11,  0x00000000,   '?',      '?',       '?'      ],
    [ 0x0ffaa660,   0x00012304,  11,  0x0ffaa660,   '?',      '?',       '?'      ],
    [ 0x00132050,   0xd6620040,  11,  0x00132050,   '?',      '?',       '?'      ],
    [ 0xfff0a440,   0x00004450,  11,  0xfff0a440,   '?',      '?',       '?'      ],
    [ 0xfeeeeaa3,   0xf4650000,  11,  0xfeeeeaa3,   '?',      '?',       '?'      ],
  ], cmdline_opts )

#-------------------------------------------------------------------------
# cp_op1
#-------------------------------------------------------------------------

def test_alu_cp_op1( cmdline_opts ):
  dut = ProcDpathAlu()

  run_test_vector_sim( dut, [
    ('in0           in1           fn  out*          ops_eq*   ops_lt*  ops_ltu*'),
    [ 0x00000000,   0x00000000,  12,  0x00000000,   '?',      '?',       '?'      ],
    [ 0x0ffaa660,   0x00012304,  12,  0x00012304,   '?',      '?',       '?'      ],
    [ 0x00132050,   0xd6620040,  12,  0xd6620040,   '?',      '?',       '?'      ],
    [ 0xfff0a440,   0x00004450,  12,  0x00004450,   '?',      '?',       '?'      ],
    [ 0xfeeeeaa3,   0xf4650000,  12,  0xf4650000,   '?',      '?',       '?'      ],
  ], cmdline_opts )

#-------------------------------------------------------------------------
# cp_equality
#-------------------------------------------------------------------------

def test_alu_fn_equality( cmdline_opts ):
  dut = ProcDpathAlu()

  run_test_vector_sim( dut, [
    ('in0           in1           fn  out*          ops_eq*   ops_lt*  ops_ltu*'),
    [ 0x00000000,   0x00000000,  14,  0x00000000,   1,        '?',       '?'      ],
    [ 0x0ffaa660,   0x00012304,  14,  0x00000000,   0,        '?',       '?'      ],
    [ 0x00132050,   0xd6620040,  14,  0x00000000,   0,        '?',       '?'      ],
    [ 0xfff0a440,   0x00004450,  14,  0x00000000,   0,        '?',       '?'      ],
    [ 0xfeeeeaa3,   0xf4650000,  14,  0x00000000,   0,        '?',       '?'      ],
  ], cmdline_opts )


#-------------------------------------------------------------------------
# random: arithmetic, logic, shifts, copies, and comparison flags
#-------------------------------------------------------------------------

def test_alu_random( cmdline_opts ):
  import random

  dut = ProcDpathAlu()

  # Local seed keeps this test reproducible regardless of test order.
  rng = random.Random(0xdeadbeef)

  test_vectors = [
    ('in0 in1 fn out* ops_eq* ops_lt* ops_ltu*')
  ]

  for i in range(100):
    a = rng.randint(0, 0xffffffff)
    b = rng.randint(0, 0xffffffff)

    # Convert the bit patterns to signed Python integers.
    a_signed = a
    b_signed = b

    if a & 0x80000000:
      a_signed = a - 0x100000000

    if b & 0x80000000:
      b_signed = b - 0x100000000

    shamt = b & 0x1f

    eq  = int(a == b)
    lt  = int(a_signed < b_signed)
    ltu = int(a < b)

    test_vectors.append(
      [a, b, 0, (a + b) & 0xffffffff, eq, lt, ltu]
    )
    test_vectors.append(
      [a, b, 1, (a - b) & 0xffffffff, eq, lt, ltu]
    )
    test_vectors.append(
      [a, b, 2, a | b, eq, lt, ltu]
    )
    test_vectors.append(
      [a, b, 3, a & b, eq, lt, ltu]
    )
    test_vectors.append(
      [a, b, 4, ~(a & b) & 0xffffffff, eq, lt, ltu]
    )
    test_vectors.append(
      [a, b, 5, ~(a | b) & 0xffffffff, eq, lt, ltu]
    )
    test_vectors.append(
      [a, b, 6, a ^ b, eq, lt, ltu]
    )
    test_vectors.append(
      [a, b, 7, ~(a ^ b) & 0xffffffff, eq, lt, ltu]
    )
    test_vectors.append(
      [a, b, 8, (a << shamt) & 0xffffffff, eq, lt, ltu]
    )
    test_vectors.append(
      [a, b, 9, a >> shamt, eq, lt, ltu]
    )
    test_vectors.append(
      [a, b, 10, (a_signed >> shamt) & 0xffffffff, eq, lt, ltu]
    )
    test_vectors.append(
      [a, b, 11, a, eq, lt, ltu]
    )
    test_vectors.append(
      [a, b, 12, b, eq, lt, ltu]
    )
    test_vectors.append(
      [a, b, 13, lt, eq, lt, ltu]
    )

  run_test_vector_sim( dut, test_vectors, cmdline_opts )
  