#=========================================================================
# IntMulFL_test
#=========================================================================

import pytest

from random import randint

from pymtl3 import *
from pymtl3.stdlib.test_utils import mk_test_case_table, run_sim
from pymtl3.stdlib.stream import StreamSourceFL, StreamSinkFL

from lab1_imul.IntMulFL import IntMulFL

#-------------------------------------------------------------------------
# TestHarness
#-------------------------------------------------------------------------

class TestHarness( Component ):

  def construct( s, imul ):

    # Instantiate models

    s.src  = StreamSourceFL( Bits64 )
    s.sink = StreamSinkFL( Bits32 )
    s.imul = imul

    # Connect

    s.src.ostream  //= s.imul.istream
    s.imul.ostream //= s.sink.istream

  def done( s ):
    return s.src.done() and s.sink.done()

  def line_trace( s ):
    return s.src.line_trace() + " > " + s.imul.line_trace() + " > " + s.sink.line_trace()

#-------------------------------------------------------------------------
# mk_imsg/mk_omsg
#-------------------------------------------------------------------------

# Make input message, truncate ints to ensure they fit in 32 bits.

def mk_imsg( a, b ):
  return concat( Bits32( a, trunc_int=True ), Bits32( b, trunc_int=True ) )

# Make output message, truncate ints to ensure they fit in 32 bits.

def mk_omsg( a ):
  return Bits32( a, trunc_int=True )

#----------------------------------------------------------------------
# Test Case: small positive * positive
#----------------------------------------------------------------------

small_pos_pos_msgs = [
  mk_imsg(  2,  3 ), mk_omsg(   6 ),
  mk_imsg(  4,  5 ), mk_omsg(  20 ),
  mk_imsg(  3,  4 ), mk_omsg(  12 ),
  mk_imsg( 10, 13 ), mk_omsg( 130 ),
  mk_imsg(  8,  7 ), mk_omsg(  56 ),
]

#----------------------------------------------------------------------
# Test Case: small negative * positive
#----------------------------------------------------------------------

small_neg_pos_msgs = [
  mk_imsg(  -2,  3 ), mk_omsg( -6   ),
  mk_imsg(  -4,  5 ), mk_omsg( -20  ),
  mk_imsg(  -3,  4 ), mk_omsg( -12  ),
  mk_imsg( -10, 13 ), mk_omsg( -130 ),
  mk_imsg(  -8,  7 ), mk_omsg( -56  ),
]

#----------------------------------------------------------------------
# Test Case: small positive * negative
#----------------------------------------------------------------------

small_pos_neg_msgs = [
  mk_imsg(  2,  -3 ), mk_omsg( -6   ),
  mk_imsg(  4,  -5 ), mk_omsg( -20  ),
  mk_imsg(  3,  -4 ), mk_omsg( -12  ),
  mk_imsg( 10, -13 ), mk_omsg( -130 ),
  mk_imsg(  8, - 7 ), mk_omsg( -56  ),
]

#----------------------------------------------------------------------
# Test Case: small negative * negative
#----------------------------------------------------------------------

small_neg_neg_msgs = [
  mk_imsg(  -2,  -3 ), mk_omsg( 6   ),
  mk_imsg(  -4,  -5 ), mk_omsg( 20  ),
  mk_imsg(  -3,  -4 ), mk_omsg( 12  ),
  mk_imsg( -10, -13 ), mk_omsg( 130 ),
  mk_imsg(  -8, - 7 ), mk_omsg( 56  ),
]

#----------------------------------------------------------------------
# Test Case: large positive * positive
#----------------------------------------------------------------------

large_pos_pos_msgs = [
  mk_imsg(      100,   1000 ), mk_omsg( 100000    ),
  mk_imsg(     1000,   1000 ), mk_omsg( 1000000   ),
  mk_imsg(    10000,   5000 ), mk_omsg( 50000000  ),
  mk_imsg(   100000,   5450 ), mk_omsg( 545000000 ),
  mk_imsg(  1000000,    600 ), mk_omsg( 600000000 ),
]

#----------------------------------------------------------------------
# Test Case: large positive * negative
#----------------------------------------------------------------------

large_pos_neg_msgs = [
  mk_imsg(      100,  -1000 ), mk_omsg( -100000    ),
  mk_imsg(     1000,  -1000 ), mk_omsg( -1000000   ),
  mk_imsg(    10000,  -5000 ), mk_omsg( -50000000  ),
  mk_imsg(   100000,  -5450 ), mk_omsg( -545000000 ),
  mk_imsg(  1000000,   -600 ), mk_omsg( -600000000 ),
]

#----------------------------------------------------------------------
# Test Case: large negative * positive
#----------------------------------------------------------------------

large_neg_pos_msgs = [
  mk_imsg(     -100,  1000 ), mk_omsg( -100000    ),
  mk_imsg(    -1000,  1000 ), mk_omsg( -1000000   ),
  mk_imsg(   -10000,  5000 ), mk_omsg( -50000000  ),
  mk_imsg(  -100000,  5450 ), mk_omsg( -545000000 ),
  mk_imsg( -1000000,   600 ), mk_omsg( -600000000 ),
]

#----------------------------------------------------------------------
# Test Case: large negative * negative
#----------------------------------------------------------------------

large_neg_neg_msgs = [
  mk_imsg(     -100, -1000 ), mk_omsg( 100000    ),
  mk_imsg(    -1000, -1000 ), mk_omsg( 1000000   ),
  mk_imsg(   -10000, -5000 ), mk_omsg( 50000000  ),
  mk_imsg(  -100000, -5450 ), mk_omsg( 545000000 ),
  mk_imsg( -1000000,  -600 ), mk_omsg( 600000000 ),
]

#----------------------------------------------------------------------
# Test Case: zero, one, and negative one
#----------------------------------------------------------------------

zero_one_negone_msgs = [
  mk_imsg(  0,  0 ), mk_omsg(  0 ),
  mk_imsg(  0,  1 ), mk_omsg(  0 ),
  mk_imsg(  1,  0 ), mk_omsg(  0 ),
  mk_imsg(  1,  1 ), mk_omsg(  1 ) ,
  mk_imsg(  1, -1 ), mk_omsg( -1 ),
  mk_imsg( -1,  1 ), mk_omsg( -1 ),
  mk_imsg( -1, -1 ), mk_omsg(  1 ),
  mk_imsg( -1,  0 ), mk_omsg(  0 ),
  mk_imsg(  0, -1 ), mk_omsg(  0 ),
]

#----------------------------------------------------------------------
# Test Case: masked off low order bits
#----------------------------------------------------------------------

masked_off_low_msgs = [
  mk_imsg(          9,    0xfffff0 ), mk_omsg(          9 *   0xfffff0 ),
  mk_imsg(         20,    0xffff00 ), mk_omsg(         20 *   0xffff00 ),
  mk_imsg( 0xdeadbee0,         100 ), mk_omsg( 0xdeadbee0 *        100 ),
  mk_imsg( 0xdeadbe00,           7 ), mk_omsg( 0xdeadbe00 *          7 ),
  mk_imsg(   0xfffff0,    0xfffff0 ), mk_omsg(   0xfffff0 *   0xfffff0 ),
  mk_imsg(   0xffff00,    0xfffff0 ), mk_omsg(   0xffff00 *   0xfffff0 ),
  mk_imsg( 0xdeadbeef,    0xfffff0 ), mk_omsg( 0xdeadbeef *   0xfffff0 ),
]

#----------------------------------------------------------------------
# Test Case: masked off middle bits
#----------------------------------------------------------------------

masked_off_mid_msgs = [
  mk_imsg(          9,    0xff0000ff ), mk_omsg(          9 * 0xff0000ff ),
  mk_imsg(         20,    0xf00000ff ), mk_omsg(         20 * 0xf00000ff ),
  mk_imsg( 0xff0000ff,           100 ), mk_omsg( 0xff0000ff *        100 ),
  mk_imsg( 0xf00000ff,             7 ), mk_omsg( 0xf00000ff *          7 ),
  mk_imsg( 0xff0000ff,             6 ), mk_omsg( 0xff0000ff *          6 ),
  mk_imsg( 0xff0fffff,             6 ), mk_omsg( 0xff0fffff *          6 ),
  mk_imsg( 0xff0000ff,    0xff0000ff ), mk_omsg( 0xff0000ff * 0xff0000ff ),
  mk_imsg( 0xff0000ff,    0xde0000ef ), mk_omsg( 0xff0000ff * 0xde0000ef ),
]

#----------------------------------------------------------------------
# Test Case: sparse multiplication
#----------------------------------------------------------------------

sparse_msgs = [
  mk_imsg(          9,    0x01000000 ), mk_omsg(          9 * 0x01000000 ),
  mk_imsg(         20,    0x10000010 ), mk_omsg(         20 * 0x10000010 ),
  mk_imsg( 0x01000210,           100 ), mk_omsg( 0x01000210 *        100 ),
  mk_imsg( 0x00001040,             7 ), mk_omsg( 0x00001040 *          7 ),
  mk_imsg( 0x00101000,             6 ), mk_omsg( 0x00101000 *          6 ),
  mk_imsg( 0x10001000,             6 ), mk_omsg( 0x10001000 *          6 ),
  mk_imsg( 0x11111111,            10 ), mk_omsg( 0x11111111 *         10 ),
  mk_imsg( 0x00001001,    0x00001001 ), mk_omsg( 0x00001001 * 0x00001001 ),
  mk_imsg( 0x00101000,    0x00001000 ), mk_omsg( 0x00101000 * 0x00001000 ),
]

#----------------------------------------------------------------------
# Test Case: dense multiplication
#----------------------------------------------------------------------

dense_msgs = [
  mk_imsg(          9,    0xf0ffffff ), mk_omsg(          9 * 0xf0ffffff ),
  mk_imsg(         20,    0x0fffff0f ), mk_omsg(         20 * 0x0fffff0f ),
  mk_imsg( 0xfffdffff,           100 ), mk_omsg( 0xfffdffff *        100 ),
  mk_imsg( 0xfffffffa,             7 ), mk_omsg( 0xfffffffa *          7 ),
  mk_imsg( 0xbfffffff,             6 ), mk_omsg( 0xbfffffff *          6 ),
  mk_imsg( 0xfffff0ff,    0xfffff0ff ), mk_omsg( 0xfffff0ff * 0xfffff0ff ),
  mk_imsg( 0xfffff0ff,    0xf0fff0ff ), mk_omsg( 0xfffff0ff * 0xf0fff0ff ),
]

#----------------------------------------------------------------------
# Test Case: random multiplication
#----------------------------------------------------------------------
random_msgs = []
for i in range( 100 ):
  a = randint( -(2**31), 2**31 - 1 )
  b = randint( -(2**31), 2**31 - 1 )
  random_msgs.extend([ mk_imsg( a, b ), mk_omsg( a * b ) ])

#----------------------------------------------------------------------
# Test Case: alt shift amount patterns
#----------------------------------------------------------------------

alt_shift_msgs = [
  mk_imsg( 7, 0x00000001 ), mk_omsg( 7 * 0x00000001 ), # shift 1
  mk_imsg( 7, 0x00000002 ), mk_omsg( 7 * 0x00000002 ), # trailing zeros = 1
  mk_imsg( 7, 0x00000004 ), mk_omsg( 7 * 0x00000004 ), # shift 2
  mk_imsg( 7, 0x00000008 ), mk_omsg( 7 * 0x00000008 ), # shift 3
  mk_imsg( 7, 0x00000010 ), mk_omsg( 7 * 0x00000010 ), # shift 4
  mk_imsg( 7, 0x00000018 ), mk_omsg( 7 * 0x00000018 ), # pattern ...11000
  mk_imsg( 7, 0x00000014 ), mk_omsg( 7 * 0x00000014 ), # pattern ...10100
  mk_imsg( 7, 0xFFFFFFFF ), mk_omsg( 7 * 0xFFFFFFFF ), # pattern all 1s
  mk_imsg( 7, 0x80000000 ), mk_omsg( 7 * 0x80000000 ), # pattern ...1000...0
]

#-------------------------------------------------------------------------
# Test Case Table
#-------------------------------------------------------------------------

test_case_table = mk_test_case_table([
  (                                 "msgs                    src_delay sink_delay"),
  [      "small_pos_pos",           small_pos_pos_msgs,       0,        0         ],
  [      "small_pos_pos_delay",     small_pos_pos_msgs,       3,        5         ],
  [      "small_neg_pos",           small_neg_pos_msgs,       0,        0         ],
  [      "small_neg_pos_delay",     small_neg_pos_msgs,       3,        5         ],
  [      "small_pos_neg",           small_pos_neg_msgs,       0,        0         ],
  [      "small_pos_neg_delay",     small_pos_neg_msgs,       3,        5         ],
  [      "small_neg_neg",           small_neg_neg_msgs,       0,        0         ],
  [      "small_neg_neg_delay",     small_neg_neg_msgs,       3,        5         ],
  [      "large_pos_pos",           large_pos_pos_msgs,       0,        0         ],
  [      "large_pos_pos_delay",     large_pos_pos_msgs,       3,        5         ],
  [      "large_pos_neg",           large_pos_neg_msgs,       0,        0         ],
  [      "large_pos_neg_delay",     large_pos_neg_msgs,       3,        5         ],
  [      "large_neg_pos",           large_neg_pos_msgs,       0,        0         ],
  [      "large_neg_pos_delay",     large_neg_pos_msgs,       3,        5         ],
  [      "large_neg_neg",           large_neg_neg_msgs,       0,        0         ],
  [      "large_neg_neg_delay",     large_neg_neg_msgs,       3,        5         ],
  [      "zero_one_negone",         zero_one_negone_msgs,     0,        0         ],
  [      "zero_one_negone_delay",   zero_one_negone_msgs,     3,        5         ],
  [      "masked_off_low",          masked_off_low_msgs,      0,        0         ],
  [      "masked_off_low_delay",    masked_off_low_msgs,      3,        5         ],
  [      "masked_off_mid",          masked_off_mid_msgs,      0,        0         ],
  [      "masked_off_mid_delay",    masked_off_mid_msgs,      3,        5         ],
  [      "sparse",                  sparse_msgs,              0,        0         ],
  [      "sparse_delay",            sparse_msgs,              3,        5         ],
  [      "dense",                   dense_msgs,               0,        0         ],
  [      "dense_delay",             dense_msgs,               3,        5         ],
  [      "random",                  random_msgs,              0,        0         ],
  [      "random_delay",            random_msgs,              3,        5         ],
  [      "alt_shift",               alt_shift_msgs,           0,        0         ],
  [      "alt_shift_delay",         alt_shift_msgs,           3,        5         ],
])

#-------------------------------------------------------------------------
# TestHarness
#-------------------------------------------------------------------------

@pytest.mark.parametrize( **test_case_table )
def test( test_params, cmdline_opts ):

  th = TestHarness( IntMulFL() )

  th.set_param("top.src.construct",
    msgs=test_params.msgs[::2],
    initial_delay=test_params.src_delay+3,
    interval_delay=test_params.src_delay )

  th.set_param("top.sink.construct",
    msgs=test_params.msgs[1::2],
    initial_delay=test_params.sink_delay+3,
    interval_delay=test_params.sink_delay )

  run_sim( th, cmdline_opts, duts=['imul'] )

