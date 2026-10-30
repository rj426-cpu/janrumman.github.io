#=========================================================================
# CacheFL_test.py
#=========================================================================

import pytest

from random import seed, randint
from random import Random 

from pymtl3 import *
from pymtl3.stdlib.mem        import MemMsgType
from pymtl3.stdlib.test_utils import mk_test_case_table

from lab3_mem.test.harness import req, resp, run_test
from lab3_mem.CacheFL      import CacheFL

seed(0xa4e28cc2)

#-------------------------------------------------------------------------
# cmp_wo_test_field
#-------------------------------------------------------------------------
# The test field in the cache response is used to indicate if the
# corresponding memory access resulted in a hit or a miss. However, the
# FL model always sets the test field to zero since it does not track
# hits/misses. So we need to do something special to ignore the test
# field when using the FL model. To do this, we can pass in a specialized
# comparison function to the StreamSinkFL.

def cmp_wo_test_field( msg, ref ):

  if msg.type_ != ref.type_:
    return False

  if msg.len != ref.len:
    return False

  if msg.opaque != ref.opaque:
    return False

  if ref.data != msg.data:
    return False

  # do not check the test field

  return True

#-------------------------------------------------------------------------
# Data
#-------------------------------------------------------------------------
# These functions are used to specify the address/data to preload into
# the main memory before running a test.

# 64B of sequential data

def data_64B():
  return [
    # addr      data
    0x00001000, 0x000c0ffe,
    0x00001004, 0x10101010,
    0x00001008, 0x20202020,
    0x0000100c, 0x30303030,
    0x00001010, 0x40404040,
    0x00001014, 0x50505050,
    0x00001018, 0x60606060,
    0x0000101c, 0x70707070,
    0x00001020, 0x80808080,
    0x00001024, 0x90909090,
    0x00001028, 0xa0a0a0a0,
    0x0000102c, 0xb0b0b0b0,
    0x00001030, 0xc0c0c0c0,
    0x00001034, 0xd0d0d0d0,
    0x00001038, 0xe0e0e0e0,
    0x0000103c, 0xf0f0f0f0,
  ]

# 512B of sequential data

def data_512B():
  data = []
  for i in range(128):
    data.extend([0x00001000+i*4,0xabcd1000+i*4])
  return data

# 1024B of random data

def data_random():
  seed(0xdeadbeef)
  data = []
  for i in range(256):
    data.extend([0x00001000+i*4,randint(0,0xffffffff)])
  return data

#----------------------------------------------------------------------
# Test Cases for Write Init
#----------------------------------------------------------------------

# Just make sure a single write init goes through the memory system.

def write_init_word():
  return [
    #    type  opq  addr   len data                type  opq  test len data
    req( 'in', 0x0, 0x1000, 0, 0xdeadbeef ), resp( 'in', 0x0, 0,   0,  0    ),
  ]

# Write init a word multiple times, also tests opaque bits

def write_init_multi_word():
  return [
    #    type  opq  addr   len data                type  opq  test len data
    req( 'in', 0x0, 0x1000, 0, 0xdeadbeef ), resp( 'in', 0x0, 0,   0,  0    ),
    req( 'in', 0x1, 0x1000, 0, 0xdeadbeef ), resp( 'in', 0x1, 0,   0,  0    ),
    req( 'in', 0x2, 0x1000, 0, 0xdeadbeef ), resp( 'in', 0x2, 0,   0,  0    ),
    req( 'in', 0x3, 0x1000, 0, 0xdeadbeef ), resp( 'in', 0x3, 0,   0,  0    ),
  ]

# Use write inits for each word in a cache line

def write_init_cacheline():
  return [
    #    type  opq  addr   len data                type  opq  test len data
    req( 'in', 0x0, 0x1000, 0, 0x01010101 ), resp( 'in', 0x0, 0,   0,  0    ),
    req( 'in', 0x1, 0x1004, 0, 0x02020202 ), resp( 'in', 0x1, 0,   0,  0    ),
    req( 'in', 0x2, 0x1008, 0, 0x03030303 ), resp( 'in', 0x2, 0,   0,  0    ),
    req( 'in', 0x3, 0x100c, 0, 0x04040404 ), resp( 'in', 0x3, 0,   0,  0    ),
  ]

# Write init one word in each cacheline in half the cache. For the direct
# mapped cache, this will write the first half of all the sets. For the
# set associative cache, this will write all of the sets in the first
# way.

def write_init_multi_cacheline():
  return [
    #    type  opq  addr   len data                type  opq  test len data
    req( 'in', 0x0, 0x0000, 0, 0x00000000 ), resp( 'in', 0x0, 0,   0,  0    ),
    req( 'in', 0x1, 0x1010, 0, 0x01010101 ), resp( 'in', 0x1, 0,   0,  0    ),
    req( 'in', 0x2, 0x2020, 0, 0x02020202 ), resp( 'in', 0x2, 0,   0,  0    ),
    req( 'in', 0x3, 0x3030, 0, 0x03030303 ), resp( 'in', 0x3, 0,   0,  0    ),
    req( 'in', 0x4, 0x4040, 0, 0x04040404 ), resp( 'in', 0x4, 0,   0,  0    ),
    req( 'in', 0x5, 0x5050, 0, 0x05050505 ), resp( 'in', 0x5, 0,   0,  0    ),
    req( 'in', 0x6, 0x6060, 0, 0x06060606 ), resp( 'in', 0x6, 0,   0,  0    ),
    req( 'in', 0x7, 0x7070, 0, 0x07070707 ), resp( 'in', 0x7, 0,   0,  0    ),
  ]

#----------------------------------------------------------------------
# Test Cases for Read Hits
#----------------------------------------------------------------------

# Single read hit

def read_hit_word():
  return [
    #    type  opq  addr   len data                type  opq  test len data
    req( 'in', 0x0, 0x1000, 0, 0xdeadbeef ), resp( 'in', 0x0, 0,   0,  0          ),
    req( 'rd', 0x0, 0x1000, 0, 0          ), resp( 'rd', 0x0, 1,   0,  0xdeadbeef ),
  ]

# Read same word multiple times, also tests opaque bits

def read_hit_multi_word():
  return [
    #    type  opq  addr   len data                type  opq  test len data
    req( 'in', 0x0, 0x1000, 0, 0xdeadbeef ), resp( 'in', 0x0, 0,   0,  0    ),

    req( 'rd', 0x0, 0x1000, 0, 0          ), resp( 'rd', 0x0, 1,   0,  0xdeadbeef ),
    req( 'rd', 0x1, 0x1000, 0, 0          ), resp( 'rd', 0x1, 1,   0,  0xdeadbeef ),
    req( 'rd', 0x2, 0x1000, 0, 0          ), resp( 'rd', 0x2, 1,   0,  0xdeadbeef ),
    req( 'rd', 0x3, 0x1000, 0, 0          ), resp( 'rd', 0x3, 1,   0,  0xdeadbeef ),
  ]

# Read every word in cache line

def read_hit_cacheline():
  return [
    #    type  opq  addr   len data                type  opq  test len data
    req( 'in', 0x0, 0x1000, 0, 0x01010101 ), resp( 'in', 0x0, 0,   0,  0    ),
    req( 'in', 0x1, 0x1004, 0, 0x02020202 ), resp( 'in', 0x1, 0,   0,  0    ),
    req( 'in', 0x2, 0x1008, 0, 0x03030303 ), resp( 'in', 0x2, 0,   0,  0    ),
    req( 'in', 0x3, 0x100c, 0, 0x04040404 ), resp( 'in', 0x3, 0,   0,  0    ),

    req( 'rd', 0x4, 0x1000, 0, 0          ), resp( 'rd', 0x4, 1,   0,  0x01010101 ),
    req( 'rd', 0x5, 0x1004, 0, 0          ), resp( 'rd', 0x5, 1,   0,  0x02020202 ),
    req( 'rd', 0x6, 0x1008, 0, 0          ), resp( 'rd', 0x6, 1,   0,  0x03030303 ),
    req( 'rd', 0x7, 0x100c, 0, 0          ), resp( 'rd', 0x7, 1,   0,  0x04040404 ),
  ]

# Read one word from each cacheline

def read_hit_multi_cacheline():
  return [
    #    type  opq  addr   len data                type  opq  test len data
    req( 'in', 0x0, 0x0000, 0, 0x00000000 ), resp( 'in', 0x0, 0,   0,  0          ),
    req( 'in', 0x1, 0x1010, 0, 0x01010101 ), resp( 'in', 0x1, 0,   0,  0          ),
    req( 'in', 0x2, 0x2020, 0, 0x02020202 ), resp( 'in', 0x2, 0,   0,  0          ),
    req( 'in', 0x3, 0x3030, 0, 0x03030303 ), resp( 'in', 0x3, 0,   0,  0          ),
    req( 'in', 0x4, 0x4040, 0, 0x04040404 ), resp( 'in', 0x4, 0,   0,  0          ),
    req( 'in', 0x5, 0x5050, 0, 0x05050505 ), resp( 'in', 0x5, 0,   0,  0          ),
    req( 'in', 0x6, 0x6060, 0, 0x06060606 ), resp( 'in', 0x6, 0,   0,  0          ),
    req( 'in', 0x7, 0x7070, 0, 0x07070707 ), resp( 'in', 0x7, 0,   0,  0          ),

    req( 'rd', 0x0, 0x0000, 0, 0          ), resp( 'rd', 0x0, 1,   0,  0x00000000 ),
    req( 'rd', 0x1, 0x1010, 0, 0          ), resp( 'rd', 0x1, 1,   0,  0x01010101 ),
    req( 'rd', 0x2, 0x2020, 0, 0          ), resp( 'rd', 0x2, 1,   0,  0x02020202 ),
    req( 'rd', 0x3, 0x3030, 0, 0          ), resp( 'rd', 0x3, 1,   0,  0x03030303 ),
    req( 'rd', 0x4, 0x4040, 0, 0          ), resp( 'rd', 0x4, 1,   0,  0x04040404 ),
    req( 'rd', 0x5, 0x5050, 0, 0          ), resp( 'rd', 0x5, 1,   0,  0x05050505 ),
    req( 'rd', 0x6, 0x6060, 0, 0          ), resp( 'rd', 0x6, 1,   0,  0x06060606 ),
    req( 'rd', 0x7, 0x7070, 0, 0          ), resp( 'rd', 0x7, 1,   0,  0x07070707 ),
  ]

#----------------------------------------------------------------------
# Test Cases for Write Hits
#----------------------------------------------------------------------

# Single write hit to one word

def write_hit_word():
  return [
    #    type  opq  addr   len data                type  opq  test len data
    req( 'in', 0x0, 0x1000, 0, 0xdeadbeef ), resp( 'in', 0x0, 0,   0,  0          ),
    req( 'wr', 0x0, 0x1000, 0, 0xcafecafe ), resp( 'wr', 0x0, 1,   0,  0          ),
    req( 'rd', 0x0, 0x1000, 0, 0          ), resp( 'rd', 0x0, 1,   0,  0xcafecafe ),
  ]

# Write/read word multiple times, also tests opaque bits

def write_hit_multi_word():
  return [
    #    type  opq  addr   len data                type  opq  test len data
    req( 'in', 0x0, 0x1000, 0, 0xdeadbeef ), resp( 'in', 0x0, 0,   0,  0          ),

    req( 'wr', 0x1, 0x1000, 0, 0x01010101 ), resp( 'wr', 0x1, 1,   0,  0          ),
    req( 'rd', 0x2, 0x1000, 0, 0          ), resp( 'rd', 0x2, 1,   0,  0x01010101 ),
    req( 'wr', 0x3, 0x1000, 0, 0x02020202 ), resp( 'wr', 0x3, 1,   0,  0          ),
    req( 'rd', 0x4, 0x1000, 0, 0          ), resp( 'rd', 0x4, 1,   0,  0x02020202 ),
    req( 'wr', 0x5, 0x1000, 0, 0x03030303 ), resp( 'wr', 0x5, 1,   0,  0          ),
    req( 'rd', 0x6, 0x1000, 0, 0          ), resp( 'rd', 0x6, 1,   0,  0x03030303 ),
    req( 'wr', 0x7, 0x1000, 0, 0x04040404 ), resp( 'wr', 0x7, 1,   0,  0          ),
    req( 'rd', 0x8, 0x1000, 0, 0          ), resp( 'rd', 0x8, 1,   0,  0x04040404 ),
  ]

# Write/read every word in cache line

def write_hit_cacheline():
  return [
    #    type  opq  addr   len data                type  opq  test len data
    req( 'in', 0x0, 0x1000, 0, 0x01010101 ), resp( 'in', 0x0, 0,   0,  0          ),
    req( 'in', 0x0, 0x1004, 0, 0x02020202 ), resp( 'in', 0x0, 0,   0,  0          ),
    req( 'in', 0x0, 0x1008, 0, 0x03030303 ), resp( 'in', 0x0, 0,   0,  0          ),
    req( 'in', 0x0, 0x100c, 0, 0x04040404 ), resp( 'in', 0x0, 0,   0,  0          ),

    req( 'wr', 0x1, 0x1000, 0, 0x01010101 ), resp( 'wr', 0x1, 1,   0,  0          ),
    req( 'wr', 0x3, 0x1004, 0, 0x02020202 ), resp( 'wr', 0x3, 1,   0,  0          ),
    req( 'wr', 0x5, 0x1008, 0, 0x03030303 ), resp( 'wr', 0x5, 1,   0,  0          ),
    req( 'wr', 0x7, 0x100c, 0, 0x04040404 ), resp( 'wr', 0x7, 1,   0,  0          ),

    req( 'rd', 0x2, 0x1000, 0, 0          ), resp( 'rd', 0x2, 1,   0,  0x01010101 ),
    req( 'rd', 0x4, 0x1004, 0, 0          ), resp( 'rd', 0x4, 1,   0,  0x02020202 ),
    req( 'rd', 0x6, 0x1008, 0, 0          ), resp( 'rd', 0x6, 1,   0,  0x03030303 ),
    req( 'rd', 0x8, 0x100c, 0, 0          ), resp( 'rd', 0x8, 1,   0,  0x04040404 ),
  ]

# Write/read one word from each cacheline

def write_hit_multi_cacheline():
  return [
    #    type  opq  addr   len data                type  opq  test len data
    req( 'in', 0x0, 0x0000, 0, 0x00000000 ), resp( 'in', 0x0, 0,   0,  0          ),
    req( 'in', 0x1, 0x1010, 0, 0x01010101 ), resp( 'in', 0x1, 0,   0,  0          ),
    req( 'in', 0x2, 0x2020, 0, 0x02020202 ), resp( 'in', 0x2, 0,   0,  0          ),
    req( 'in', 0x3, 0x3030, 0, 0x03030303 ), resp( 'in', 0x3, 0,   0,  0          ),
    req( 'in', 0x4, 0x4040, 0, 0x04040404 ), resp( 'in', 0x4, 0,   0,  0          ),
    req( 'in', 0x5, 0x5050, 0, 0x05050505 ), resp( 'in', 0x5, 0,   0,  0          ),
    req( 'in', 0x6, 0x6060, 0, 0x06060606 ), resp( 'in', 0x6, 0,   0,  0          ),
    req( 'in', 0x7, 0x7070, 0, 0x07070707 ), resp( 'in', 0x7, 0,   0,  0          ),

    req( 'wr', 0x0, 0x0000, 0, 0x10101010 ), resp( 'wr', 0x0, 1,   0,  0          ),
    req( 'wr', 0x1, 0x1010, 0, 0x11111111 ), resp( 'wr', 0x1, 1,   0,  0          ),
    req( 'wr', 0x2, 0x2020, 0, 0x12121212 ), resp( 'wr', 0x2, 1,   0,  0          ),
    req( 'wr', 0x3, 0x3030, 0, 0x13131313 ), resp( 'wr', 0x3, 1,   0,  0          ),
    req( 'wr', 0x4, 0x4040, 0, 0x14141414 ), resp( 'wr', 0x4, 1,   0,  0          ),
    req( 'wr', 0x5, 0x5050, 0, 0x15151515 ), resp( 'wr', 0x5, 1,   0,  0          ),
    req( 'wr', 0x6, 0x6060, 0, 0x16161616 ), resp( 'wr', 0x6, 1,   0,  0          ),
    req( 'wr', 0x7, 0x7070, 0, 0x17171717 ), resp( 'wr', 0x7, 1,   0,  0          ),

    req( 'rd', 0x0, 0x0000, 0, 0          ), resp( 'rd', 0x0, 1,   0,  0x10101010 ),
    req( 'rd', 0x1, 0x1010, 0, 0          ), resp( 'rd', 0x1, 1,   0,  0x11111111 ),
    req( 'rd', 0x2, 0x2020, 0, 0          ), resp( 'rd', 0x2, 1,   0,  0x12121212 ),
    req( 'rd', 0x3, 0x3030, 0, 0          ), resp( 'rd', 0x3, 1,   0,  0x13131313 ),
    req( 'rd', 0x4, 0x4040, 0, 0          ), resp( 'rd', 0x4, 1,   0,  0x14141414 ),
    req( 'rd', 0x5, 0x5050, 0, 0          ), resp( 'rd', 0x5, 1,   0,  0x15151515 ),
    req( 'rd', 0x6, 0x6060, 0, 0          ), resp( 'rd', 0x6, 1,   0,  0x16161616 ),
    req( 'rd', 0x7, 0x7070, 0, 0          ), resp( 'rd', 0x7, 1,   0,  0x17171717 ),
  ]

#----------------------------------------------------------------------
# Test Cases for Refill on Read Miss
#----------------------------------------------------------------------

# Single read miss (uses data_64B)

def read_miss_word():
  return [
    #    type  opq  addr   len data                type  opq  test len data
    req( 'rd', 0x0, 0x1000, 0, 0          ), resp( 'rd', 0x0, 0,   0,  0x000c0ffe ),
  ]

# Read same word multiple times, also tests opaque bits (uses data_64B)

def read_miss_multi_word():
  return [
    #    type  opq  addr   len data                type  opq  test len data
    req( 'rd', 0x0, 0x1000, 0, 0          ), resp( 'rd', 0x0, 0,   0,  0x000c0ffe ),
    req( 'rd', 0x1, 0x1000, 0, 0          ), resp( 'rd', 0x1, 1,   0,  0x000c0ffe ),
    req( 'rd', 0x2, 0x1000, 0, 0          ), resp( 'rd', 0x2, 1,   0,  0x000c0ffe ),
    req( 'rd', 0x3, 0x1000, 0, 0          ), resp( 'rd', 0x3, 1,   0,  0x000c0ffe ),
  ]

# Read every word in cache line (uses data_64B)

def read_miss_cacheline():
  return [
    #    type  opq  addr   len data                type  opq  test len data
    req( 'rd', 0x1, 0x1000, 0, 0          ), resp( 'rd', 0x1, 0,   0,  0x000c0ffe ),
    req( 'rd', 0x2, 0x1004, 0, 0          ), resp( 'rd', 0x2, 1,   0,  0x10101010 ),
    req( 'rd', 0x3, 0x1008, 0, 0          ), resp( 'rd', 0x3, 1,   0,  0x20202020 ),
    req( 'rd', 0x4, 0x100c, 0, 0          ), resp( 'rd', 0x4, 1,   0,  0x30303030 ),
  ]

# Read miss for each cacheline, then read hit for each cacheline (uses data_512B)

def read_miss_multi_cacheline():
  return [
    #    type  opq  addr   len data                type  opq  test len data
    req( 'rd', 0x0, 0x1000, 0, 0          ), resp( 'rd', 0x0, 0,   0,  0xabcd1000 ),
    req( 'rd', 0x1, 0x1010, 0, 0          ), resp( 'rd', 0x1, 0,   0,  0xabcd1010 ),
    req( 'rd', 0x2, 0x1020, 0, 0          ), resp( 'rd', 0x2, 0,   0,  0xabcd1020 ),
    req( 'rd', 0x3, 0x1030, 0, 0          ), resp( 'rd', 0x3, 0,   0,  0xabcd1030 ),
    req( 'rd', 0x4, 0x1040, 0, 0          ), resp( 'rd', 0x4, 0,   0,  0xabcd1040 ),
    req( 'rd', 0x5, 0x1050, 0, 0          ), resp( 'rd', 0x5, 0,   0,  0xabcd1050 ),
    req( 'rd', 0x6, 0x1060, 0, 0          ), resp( 'rd', 0x6, 0,   0,  0xabcd1060 ),
    req( 'rd', 0x7, 0x1070, 0, 0          ), resp( 'rd', 0x7, 0,   0,  0xabcd1070 ),
    req( 'rd', 0x8, 0x1080, 0, 0          ), resp( 'rd', 0x8, 0,   0,  0xabcd1080 ),
    req( 'rd', 0x9, 0x1090, 0, 0          ), resp( 'rd', 0x9, 0,   0,  0xabcd1090 ),
    req( 'rd', 0xa, 0x10a0, 0, 0          ), resp( 'rd', 0xa, 0,   0,  0xabcd10a0 ),
    req( 'rd', 0xb, 0x10b0, 0, 0          ), resp( 'rd', 0xb, 0,   0,  0xabcd10b0 ),
    req( 'rd', 0xc, 0x10c0, 0, 0          ), resp( 'rd', 0xc, 0,   0,  0xabcd10c0 ),
    req( 'rd', 0xd, 0x10d0, 0, 0          ), resp( 'rd', 0xd, 0,   0,  0xabcd10d0 ),
    req( 'rd', 0xe, 0x10e0, 0, 0          ), resp( 'rd', 0xe, 0,   0,  0xabcd10e0 ),
    req( 'rd', 0xf, 0x10f0, 0, 0          ), resp( 'rd', 0xf, 0,   0,  0xabcd10f0 ),

    req( 'rd', 0x0, 0x1000, 0, 0          ), resp( 'rd', 0x0, 1,   0,  0xabcd1000 ),
    req( 'rd', 0x1, 0x1010, 0, 0          ), resp( 'rd', 0x1, 1,   0,  0xabcd1010 ),
    req( 'rd', 0x2, 0x1020, 0, 0          ), resp( 'rd', 0x2, 1,   0,  0xabcd1020 ),
    req( 'rd', 0x3, 0x1030, 0, 0          ), resp( 'rd', 0x3, 1,   0,  0xabcd1030 ),
    req( 'rd', 0x4, 0x1040, 0, 0          ), resp( 'rd', 0x4, 1,   0,  0xabcd1040 ),
    req( 'rd', 0x5, 0x1050, 0, 0          ), resp( 'rd', 0x5, 1,   0,  0xabcd1050 ),
    req( 'rd', 0x6, 0x1060, 0, 0          ), resp( 'rd', 0x6, 1,   0,  0xabcd1060 ),
    req( 'rd', 0x7, 0x1070, 0, 0          ), resp( 'rd', 0x7, 1,   0,  0xabcd1070 ),
    req( 'rd', 0x8, 0x1080, 0, 0          ), resp( 'rd', 0x8, 1,   0,  0xabcd1080 ),
    req( 'rd', 0x9, 0x1090, 0, 0          ), resp( 'rd', 0x9, 1,   0,  0xabcd1090 ),
    req( 'rd', 0xa, 0x10a0, 0, 0          ), resp( 'rd', 0xa, 1,   0,  0xabcd10a0 ),
    req( 'rd', 0xb, 0x10b0, 0, 0          ), resp( 'rd', 0xb, 1,   0,  0xabcd10b0 ),
    req( 'rd', 0xc, 0x10c0, 0, 0          ), resp( 'rd', 0xc, 1,   0,  0xabcd10c0 ),
    req( 'rd', 0xd, 0x10d0, 0, 0          ), resp( 'rd', 0xd, 1,   0,  0xabcd10d0 ),
    req( 'rd', 0xe, 0x10e0, 0, 0          ), resp( 'rd', 0xe, 1,   0,  0xabcd10e0 ),
    req( 'rd', 0xf, 0x10f0, 0, 0          ), resp( 'rd', 0xf, 1,   0,  0xabcd10f0 ),

    req( 'rd', 0x0, 0x1004, 0, 0          ), resp( 'rd', 0x0, 1,   0,  0xabcd1004 ),
    req( 'rd', 0x1, 0x1014, 0, 0          ), resp( 'rd', 0x1, 1,   0,  0xabcd1014 ),
    req( 'rd', 0x2, 0x1024, 0, 0          ), resp( 'rd', 0x2, 1,   0,  0xabcd1024 ),
    req( 'rd', 0x3, 0x1034, 0, 0          ), resp( 'rd', 0x3, 1,   0,  0xabcd1034 ),
    req( 'rd', 0x4, 0x1044, 0, 0          ), resp( 'rd', 0x4, 1,   0,  0xabcd1044 ),
    req( 'rd', 0x5, 0x1054, 0, 0          ), resp( 'rd', 0x5, 1,   0,  0xabcd1054 ),
    req( 'rd', 0x6, 0x1064, 0, 0          ), resp( 'rd', 0x6, 1,   0,  0xabcd1064 ),
    req( 'rd', 0x7, 0x1074, 0, 0          ), resp( 'rd', 0x7, 1,   0,  0xabcd1074 ),
    req( 'rd', 0x8, 0x1084, 0, 0          ), resp( 'rd', 0x8, 1,   0,  0xabcd1084 ),
    req( 'rd', 0x9, 0x1094, 0, 0          ), resp( 'rd', 0x9, 1,   0,  0xabcd1094 ),
    req( 'rd', 0xa, 0x10a4, 0, 0          ), resp( 'rd', 0xa, 1,   0,  0xabcd10a4 ),
    req( 'rd', 0xb, 0x10b4, 0, 0          ), resp( 'rd', 0xb, 1,   0,  0xabcd10b4 ),
    req( 'rd', 0xc, 0x10c4, 0, 0          ), resp( 'rd', 0xc, 1,   0,  0xabcd10c4 ),
    req( 'rd', 0xd, 0x10d4, 0, 0          ), resp( 'rd', 0xd, 1,   0,  0xabcd10d4 ),
    req( 'rd', 0xe, 0x10e4, 0, 0          ), resp( 'rd', 0xe, 1,   0,  0xabcd10e4 ),
    req( 'rd', 0xf, 0x10f4, 0, 0          ), resp( 'rd', 0xf, 1,   0,  0xabcd10f4 ),
  ]

#----------------------------------------------------------------------
# Test Cases for Refill on Write Miss
#----------------------------------------------------------------------

# Single write miss to one word (uses data_64B)

def write_miss_word():
  return [
    #    type  opq  addr   len data                type  opq  test len data
    req( 'wr', 0x0, 0x1000, 0, 0xcafecafe ), resp( 'wr', 0x0, 0,   0,  0          ),
    req( 'rd', 0x0, 0x1000, 0, 0          ), resp( 'rd', 0x0, 1,   0,  0xcafecafe ),
  ]

# Write/read word multiple times, also tests opaque bits (uses data_64B)

def write_miss_multi_word():
  return [
    #    type  opq  addr   len data                type  opq  test len data
    req( 'wr', 0x1, 0x1000, 0, 0x01010101 ), resp( 'wr', 0x1, 0,   0,  0          ),
    req( 'rd', 0x2, 0x1000, 0, 0          ), resp( 'rd', 0x2, 1,   0,  0x01010101 ),
    req( 'wr', 0x3, 0x1000, 0, 0x02020202 ), resp( 'wr', 0x3, 1,   0,  0          ),
    req( 'rd', 0x4, 0x1000, 0, 0          ), resp( 'rd', 0x4, 1,   0,  0x02020202 ),
    req( 'wr', 0x5, 0x1000, 0, 0x03030303 ), resp( 'wr', 0x5, 1,   0,  0          ),
    req( 'rd', 0x6, 0x1000, 0, 0          ), resp( 'rd', 0x6, 1,   0,  0x03030303 ),
    req( 'wr', 0x7, 0x1000, 0, 0x04040404 ), resp( 'wr', 0x7, 1,   0,  0          ),
    req( 'rd', 0x8, 0x1000, 0, 0          ), resp( 'rd', 0x8, 1,   0,  0x04040404 ),
  ]

# Write/read every word in cache line (uses data_64B)

def write_miss_cacheline():
  return [
    #    type  opq  addr   len data                type  opq  test len data
    req( 'wr', 0x1, 0x1000, 0, 0x01010101 ), resp( 'wr', 0x1, 0,   0,  0          ),
    req( 'wr', 0x2, 0x1004, 0, 0x02020202 ), resp( 'wr', 0x2, 1,   0,  0          ),
    req( 'wr', 0x3, 0x1008, 0, 0x03030303 ), resp( 'wr', 0x3, 1,   0,  0          ),
    req( 'wr', 0x4, 0x100c, 0, 0x04040404 ), resp( 'wr', 0x4, 1,   0,  0          ),

    req( 'rd', 0x5, 0x1000, 0, 0          ), resp( 'rd', 0x5, 1,   0,  0x01010101 ),
    req( 'rd', 0x6, 0x1004, 0, 0          ), resp( 'rd', 0x6, 1,   0,  0x02020202 ),
    req( 'rd', 0x7, 0x1008, 0, 0          ), resp( 'rd', 0x7, 1,   0,  0x03030303 ),
    req( 'rd', 0x8, 0x100c, 0, 0          ), resp( 'rd', 0x8, 1,   0,  0x04040404 ),
  ]

# Write/read one word from each cacheline (uses data_512B)

def write_miss_multi_cacheline():
  return [
    #    type  opq  addr   len data                type  opq  test len data
    req( 'wr', 0x0, 0x1000, 0, 0x10101010 ), resp( 'wr', 0x0, 0,   0,  0          ),
    req( 'wr', 0x1, 0x1010, 0, 0x11111111 ), resp( 'wr', 0x1, 0,   0,  0          ),
    req( 'wr', 0x2, 0x1020, 0, 0x12121212 ), resp( 'wr', 0x2, 0,   0,  0          ),
    req( 'wr', 0x3, 0x1030, 0, 0x13131313 ), resp( 'wr', 0x3, 0,   0,  0          ),
    req( 'wr', 0x4, 0x1040, 0, 0x14141414 ), resp( 'wr', 0x4, 0,   0,  0          ),
    req( 'wr', 0x5, 0x1050, 0, 0x15151515 ), resp( 'wr', 0x5, 0,   0,  0          ),
    req( 'wr', 0x6, 0x1060, 0, 0x16161616 ), resp( 'wr', 0x6, 0,   0,  0          ),
    req( 'wr', 0x7, 0x1070, 0, 0x17171717 ), resp( 'wr', 0x7, 0,   0,  0          ),
    req( 'wr', 0x8, 0x1080, 0, 0x18181818 ), resp( 'wr', 0x8, 0,   0,  0          ),
    req( 'wr', 0x9, 0x1090, 0, 0x19191919 ), resp( 'wr', 0x9, 0,   0,  0          ),
    req( 'wr', 0xa, 0x10a0, 0, 0x1a1a1a1a ), resp( 'wr', 0xa, 0,   0,  0          ),
    req( 'wr', 0xb, 0x10b0, 0, 0x1b1b1b1b ), resp( 'wr', 0xb, 0,   0,  0          ),
    req( 'wr', 0xc, 0x10c0, 0, 0x1c1c1c1c ), resp( 'wr', 0xc, 0,   0,  0          ),
    req( 'wr', 0xd, 0x10d0, 0, 0x1d1d1d1d ), resp( 'wr', 0xd, 0,   0,  0          ),
    req( 'wr', 0xe, 0x10e0, 0, 0x1e1e1e1e ), resp( 'wr', 0xe, 0,   0,  0          ),
    req( 'wr', 0xf, 0x10f0, 0, 0x1f1f1f1f ), resp( 'wr', 0xf, 0,   0,  0          ),

    req( 'rd', 0x0, 0x1000, 0, 0          ), resp( 'rd', 0x0, 1,   0,  0x10101010 ),
    req( 'rd', 0x1, 0x1010, 0, 0          ), resp( 'rd', 0x1, 1,   0,  0x11111111 ),
    req( 'rd', 0x2, 0x1020, 0, 0          ), resp( 'rd', 0x2, 1,   0,  0x12121212 ),
    req( 'rd', 0x3, 0x1030, 0, 0          ), resp( 'rd', 0x3, 1,   0,  0x13131313 ),
    req( 'rd', 0x4, 0x1040, 0, 0          ), resp( 'rd', 0x4, 1,   0,  0x14141414 ),
    req( 'rd', 0x5, 0x1050, 0, 0          ), resp( 'rd', 0x5, 1,   0,  0x15151515 ),
    req( 'rd', 0x6, 0x1060, 0, 0          ), resp( 'rd', 0x6, 1,   0,  0x16161616 ),
    req( 'rd', 0x7, 0x1070, 0, 0          ), resp( 'rd', 0x7, 1,   0,  0x17171717 ),
    req( 'rd', 0x8, 0x1080, 0, 0          ), resp( 'rd', 0x8, 1,   0,  0x18181818 ),
    req( 'rd', 0x9, 0x1090, 0, 0          ), resp( 'rd', 0x9, 1,   0,  0x19191919 ),
    req( 'rd', 0xa, 0x10a0, 0, 0          ), resp( 'rd', 0xa, 1,   0,  0x1a1a1a1a ),
    req( 'rd', 0xb, 0x10b0, 0, 0          ), resp( 'rd', 0xb, 1,   0,  0x1b1b1b1b ),
    req( 'rd', 0xc, 0x10c0, 0, 0          ), resp( 'rd', 0xc, 1,   0,  0x1c1c1c1c ),
    req( 'rd', 0xd, 0x10d0, 0, 0          ), resp( 'rd', 0xd, 1,   0,  0x1d1d1d1d ),
    req( 'rd', 0xe, 0x10e0, 0, 0          ), resp( 'rd', 0xe, 1,   0,  0x1e1e1e1e ),
    req( 'rd', 0xf, 0x10f0, 0, 0          ), resp( 'rd', 0xf, 1,   0,  0x1f1f1f1f ),
  ]

#----------------------------------------------------------------------
# Test Cases for Evict
#----------------------------------------------------------------------

# Write miss to two cachelines, and then a read to a third cacheline.
# This read to the third cacheline is guaranteed to cause an eviction on
# both the direct mapped and set associative caches. (uses data_512B)

def evict_word():
  return [
    #    type  opq  addr   len data                type  opq  test len data
    req( 'wr', 0x0, 0x1000, 0, 0xcafecafe ), resp( 'wr', 0x0, 0,   0,  0          ),
    req( 'rd', 0x0, 0x1000, 0, 0          ), resp( 'rd', 0x0, 1,   0,  0xcafecafe ),
    req( 'wr', 0x0, 0x1080, 0, 0x000c0ffe ), resp( 'wr', 0x0, 0,   0,  0          ),
    req( 'rd', 0x0, 0x1080, 0, 0          ), resp( 'rd', 0x0, 1,   0,  0x000c0ffe ),
    req( 'rd', 0x0, 0x1100, 0, 0          ), resp( 'rd', 0x0, 0,   0,  0xabcd1100 ), # conflicts
    req( 'rd', 0x0, 0x1000, 0, 0          ), resp( 'rd', 0x0, 0,   0,  0xcafecafe ),
  ]

# Write word and evict multiple times. Test is carefully crafted to
# ensure it applies to both direct mapped and set associative caches.
# (uses data_512B)

def evict_multi_word():
  return [
    #    type  opq  addr   len data                type  opq  test len data
    req( 'wr', 0x0, 0x1000, 0, 0x01010101 ), resp( 'wr', 0x0, 0,   0,  0          ),
    req( 'rd', 0x1, 0x1000, 0, 0          ), resp( 'rd', 0x1, 1,   0,  0x01010101 ),
    req( 'wr', 0x2, 0x1080, 0, 0x11111111 ), resp( 'wr', 0x2, 0,   0,  0          ),
    req( 'rd', 0x3, 0x1080, 0, 0          ), resp( 'rd', 0x3, 1,   0,  0x11111111 ),
    req( 'rd', 0x4, 0x1100, 0, 0          ), resp( 'rd', 0x4, 0,   0,  0xabcd1100 ), # conflicts
    req( 'rd', 0x5, 0x1080, 0, 0          ), resp( 'rd', 0x5, 1,   0,  0x11111111 ), # make sure way1 is still LRU

    req( 'wr', 0x6, 0x1000, 0, 0x02020202 ), resp( 'wr', 0x6, 0,   0,  0          ),
    req( 'rd', 0x7, 0x1000, 0, 0          ), resp( 'rd', 0x7, 1,   0,  0x02020202 ),
    req( 'wr', 0x8, 0x1080, 0, 0x12121212 ), resp( 'wr', 0x8, 1,   0,  0          ),
    req( 'rd', 0x9, 0x1080, 0, 0          ), resp( 'rd', 0x9, 1,   0,  0x12121212 ),
    req( 'rd', 0xa, 0x1100, 0, 0          ), resp( 'rd', 0xa, 0,   0,  0xabcd1100 ), # conflicts
    req( 'rd', 0xb, 0x1080, 0, 0          ), resp( 'rd', 0xb, 1,   0,  0x12121212 ), # make sure way1 is still LRU

    req( 'wr', 0xc, 0x1000, 0, 0x03030303 ), resp( 'wr', 0xc, 0,   0,  0          ),
    req( 'rd', 0xd, 0x1000, 0, 0          ), resp( 'rd', 0xd, 1,   0,  0x03030303 ),
    req( 'wr', 0xe, 0x1080, 0, 0x13131313 ), resp( 'wr', 0xe, 1,   0,  0          ),
    req( 'rd', 0xf, 0x1080, 0, 0          ), resp( 'rd', 0xf, 1,   0,  0x13131313 ),
    req( 'rd', 0x0, 0x1100, 0, 0          ), resp( 'rd', 0x0, 0,   0,  0xabcd1100 ), # conflicts
    req( 'rd', 0x1, 0x1080, 0, 0          ), resp( 'rd', 0x1, 1,   0,  0x13131313 ), # make sure way1 is still LRU

    req( 'wr', 0x2, 0x1000, 0, 0x04040404 ), resp( 'wr', 0x2, 0,   0,  0          ),
    req( 'rd', 0x3, 0x1000, 0, 0          ), resp( 'rd', 0x3, 1,   0,  0x04040404 ),
    req( 'wr', 0x4, 0x1080, 0, 0x14141414 ), resp( 'wr', 0x4, 1,   0,  0          ),
    req( 'rd', 0x5, 0x1080, 0, 0          ), resp( 'rd', 0x5, 1,   0,  0x14141414 ),
    req( 'rd', 0x6, 0x1100, 0, 0          ), resp( 'rd', 0x6, 0,   0,  0xabcd1100 ), # conflicts
    req( 'rd', 0x7, 0x1080, 0, 0          ), resp( 'rd', 0x7, 1,   0,  0x14141414 ), # make sure way1 is still LRU

    req( 'rd', 0x8, 0x1000, 0, 0          ), resp( 'rd', 0x8, 0,   0,  0x04040404 ),
  ]

# Write every word on two cachelines, and then a read to a third
# cacheline. This read to the third cacheline is guaranteed to cause an
# eviction on both the direct mapped and set associative caches. (uses
# data_512B)

def evict_cacheline():
  return [
    #    type  opq  addr   len data                type  opq  test len data
    req( 'wr', 0x0, 0x1000, 0, 0x01010101 ), resp( 'wr', 0x0, 0,   0,  0          ),
    req( 'wr', 0x1, 0x1004, 0, 0x02020202 ), resp( 'wr', 0x1, 1,   0,  0          ),
    req( 'wr', 0x2, 0x1008, 0, 0x03030303 ), resp( 'wr', 0x2, 1,   0,  0          ),
    req( 'wr', 0x3, 0x100c, 0, 0x04040404 ), resp( 'wr', 0x3, 1,   0,  0          ),

    req( 'wr', 0x4, 0x1080, 0, 0x11111111 ), resp( 'wr', 0x4, 0,   0,  0          ),
    req( 'wr', 0x5, 0x1084, 0, 0x12121212 ), resp( 'wr', 0x5, 1,   0,  0          ),
    req( 'wr', 0x6, 0x1088, 0, 0x13131313 ), resp( 'wr', 0x6, 1,   0,  0          ),
    req( 'wr', 0x7, 0x108c, 0, 0x14141414 ), resp( 'wr', 0x7, 1,   0,  0          ),

    req( 'rd', 0x8, 0x1100, 0, 0          ), resp( 'rd', 0x8, 0,   0,  0xabcd1100 ), # conflicts

    req( 'rd', 0x9, 0x1000, 0, 0          ), resp( 'rd', 0x9, 0,   0,  0x01010101 ),
    req( 'rd', 0xa, 0x1004, 0, 0          ), resp( 'rd', 0xa, 1,   0,  0x02020202 ),
    req( 'rd', 0xb, 0x1008, 0, 0          ), resp( 'rd', 0xb, 1,   0,  0x03030303 ),
    req( 'rd', 0xc, 0x100c, 0, 0          ), resp( 'rd', 0xc, 1,   0,  0x04040404 ),
  ]

# Write one word from each cacheline, then evict (uses data_512B)

def evict_multi_cacheline():
  return [
    #    type  opq  addr   len data                type  opq  test len data
    req( 'wr', 0x0, 0x1000, 0, 0x10101010 ), resp( 'wr', 0x0, 0,   0,  0          ),
    req( 'wr', 0x1, 0x1010, 0, 0x11111111 ), resp( 'wr', 0x1, 0,   0,  0          ),
    req( 'wr', 0x2, 0x1020, 0, 0x12121212 ), resp( 'wr', 0x2, 0,   0,  0          ),
    req( 'wr', 0x3, 0x1030, 0, 0x13131313 ), resp( 'wr', 0x3, 0,   0,  0          ),
    req( 'wr', 0x4, 0x1040, 0, 0x14141414 ), resp( 'wr', 0x4, 0,   0,  0          ),
    req( 'wr', 0x5, 0x1050, 0, 0x15151515 ), resp( 'wr', 0x5, 0,   0,  0          ),
    req( 'wr', 0x6, 0x1060, 0, 0x16161616 ), resp( 'wr', 0x6, 0,   0,  0          ),
    req( 'wr', 0x7, 0x1070, 0, 0x17171717 ), resp( 'wr', 0x7, 0,   0,  0          ),
    req( 'wr', 0x8, 0x1080, 0, 0x18181818 ), resp( 'wr', 0x8, 0,   0,  0          ),
    req( 'wr', 0x9, 0x1090, 0, 0x19191919 ), resp( 'wr', 0x9, 0,   0,  0          ),
    req( 'wr', 0xa, 0x10a0, 0, 0x1a1a1a1a ), resp( 'wr', 0xa, 0,   0,  0          ),
    req( 'wr', 0xb, 0x10b0, 0, 0x1b1b1b1b ), resp( 'wr', 0xb, 0,   0,  0          ),
    req( 'wr', 0xc, 0x10c0, 0, 0x1c1c1c1c ), resp( 'wr', 0xc, 0,   0,  0          ),
    req( 'wr', 0xd, 0x10d0, 0, 0x1d1d1d1d ), resp( 'wr', 0xd, 0,   0,  0          ),
    req( 'wr', 0xe, 0x10e0, 0, 0x1e1e1e1e ), resp( 'wr', 0xe, 0,   0,  0          ),
    req( 'wr', 0xf, 0x10f0, 0, 0x1f1f1f1f ), resp( 'wr', 0xf, 0,   0,  0          ),

    req( 'rd', 0x0, 0x1000, 0, 0          ), resp( 'rd', 0x0, 1,   0,  0x10101010 ),
    req( 'rd', 0x1, 0x1010, 0, 0          ), resp( 'rd', 0x1, 1,   0,  0x11111111 ),
    req( 'rd', 0x2, 0x1020, 0, 0          ), resp( 'rd', 0x2, 1,   0,  0x12121212 ),
    req( 'rd', 0x3, 0x1030, 0, 0          ), resp( 'rd', 0x3, 1,   0,  0x13131313 ),
    req( 'rd', 0x4, 0x1040, 0, 0          ), resp( 'rd', 0x4, 1,   0,  0x14141414 ),
    req( 'rd', 0x5, 0x1050, 0, 0          ), resp( 'rd', 0x5, 1,   0,  0x15151515 ),
    req( 'rd', 0x6, 0x1060, 0, 0          ), resp( 'rd', 0x6, 1,   0,  0x16161616 ),
    req( 'rd', 0x7, 0x1070, 0, 0          ), resp( 'rd', 0x7, 1,   0,  0x17171717 ),
    req( 'rd', 0x8, 0x1080, 0, 0          ), resp( 'rd', 0x8, 1,   0,  0x18181818 ),
    req( 'rd', 0x9, 0x1090, 0, 0          ), resp( 'rd', 0x9, 1,   0,  0x19191919 ),
    req( 'rd', 0xa, 0x10a0, 0, 0          ), resp( 'rd', 0xa, 1,   0,  0x1a1a1a1a ),
    req( 'rd', 0xb, 0x10b0, 0, 0          ), resp( 'rd', 0xb, 1,   0,  0x1b1b1b1b ),
    req( 'rd', 0xc, 0x10c0, 0, 0          ), resp( 'rd', 0xc, 1,   0,  0x1c1c1c1c ),
    req( 'rd', 0xd, 0x10d0, 0, 0          ), resp( 'rd', 0xd, 1,   0,  0x1d1d1d1d ),
    req( 'rd', 0xe, 0x10e0, 0, 0          ), resp( 'rd', 0xe, 1,   0,  0x1e1e1e1e ),
    req( 'rd', 0xf, 0x10f0, 0, 0          ), resp( 'rd', 0xf, 1,   0,  0x1f1f1f1f ),

    req( 'rd', 0x0, 0x1100, 0, 0          ), resp( 'rd', 0x0, 0,   0,  0xabcd1100 ), # conflicts
    req( 'rd', 0x1, 0x1110, 0, 0          ), resp( 'rd', 0x1, 0,   0,  0xabcd1110 ), # conflicts
    req( 'rd', 0x2, 0x1120, 0, 0          ), resp( 'rd', 0x2, 0,   0,  0xabcd1120 ), # conflicts
    req( 'rd', 0x3, 0x1130, 0, 0          ), resp( 'rd', 0x3, 0,   0,  0xabcd1130 ), # conflicts
    req( 'rd', 0x4, 0x1140, 0, 0          ), resp( 'rd', 0x4, 0,   0,  0xabcd1140 ), # conflicts
    req( 'rd', 0x5, 0x1150, 0, 0          ), resp( 'rd', 0x5, 0,   0,  0xabcd1150 ), # conflicts
    req( 'rd', 0x6, 0x1160, 0, 0          ), resp( 'rd', 0x6, 0,   0,  0xabcd1160 ), # conflicts
    req( 'rd', 0x7, 0x1170, 0, 0          ), resp( 'rd', 0x7, 0,   0,  0xabcd1170 ), # conflicts
    req( 'rd', 0x8, 0x1180, 0, 0          ), resp( 'rd', 0x8, 0,   0,  0xabcd1180 ), # conflicts
    req( 'rd', 0x9, 0x1190, 0, 0          ), resp( 'rd', 0x9, 0,   0,  0xabcd1190 ), # conflicts
    req( 'rd', 0xa, 0x11a0, 0, 0          ), resp( 'rd', 0xa, 0,   0,  0xabcd11a0 ), # conflicts
    req( 'rd', 0xb, 0x11b0, 0, 0          ), resp( 'rd', 0xb, 0,   0,  0xabcd11b0 ), # conflicts
    req( 'rd', 0xc, 0x11c0, 0, 0          ), resp( 'rd', 0xc, 0,   0,  0xabcd11c0 ), # conflicts
    req( 'rd', 0xd, 0x11d0, 0, 0          ), resp( 'rd', 0xd, 0,   0,  0xabcd11d0 ), # conflicts
    req( 'rd', 0xe, 0x11e0, 0, 0          ), resp( 'rd', 0xe, 0,   0,  0xabcd11e0 ), # conflicts
    req( 'rd', 0xf, 0x11f0, 0, 0          ), resp( 'rd', 0xf, 0,   0,  0xabcd11f0 ), # conflicts

    req( 'rd', 0x0, 0x1000, 0, 0          ), resp( 'rd', 0x0, 0,   0,  0x10101010 ),
    req( 'rd', 0x1, 0x1010, 0, 0          ), resp( 'rd', 0x1, 0,   0,  0x11111111 ),
    req( 'rd', 0x2, 0x1020, 0, 0          ), resp( 'rd', 0x2, 0,   0,  0x12121212 ),
    req( 'rd', 0x3, 0x1030, 0, 0          ), resp( 'rd', 0x3, 0,   0,  0x13131313 ),
    req( 'rd', 0x4, 0x1040, 0, 0          ), resp( 'rd', 0x4, 0,   0,  0x14141414 ),
    req( 'rd', 0x5, 0x1050, 0, 0          ), resp( 'rd', 0x5, 0,   0,  0x15151515 ),
    req( 'rd', 0x6, 0x1060, 0, 0          ), resp( 'rd', 0x6, 0,   0,  0x16161616 ),
    req( 'rd', 0x7, 0x1070, 0, 0          ), resp( 'rd', 0x7, 0,   0,  0x17171717 ),
    req( 'rd', 0x8, 0x1080, 0, 0          ), resp( 'rd', 0x8, 0,   0,  0x18181818 ),
    req( 'rd', 0x9, 0x1090, 0, 0          ), resp( 'rd', 0x9, 0,   0,  0x19191919 ),
    req( 'rd', 0xa, 0x10a0, 0, 0          ), resp( 'rd', 0xa, 0,   0,  0x1a1a1a1a ),
    req( 'rd', 0xb, 0x10b0, 0, 0          ), resp( 'rd', 0xb, 0,   0,  0x1b1b1b1b ),
    req( 'rd', 0xc, 0x10c0, 0, 0          ), resp( 'rd', 0xc, 0,   0,  0x1c1c1c1c ),
    req( 'rd', 0xd, 0x10d0, 0, 0          ), resp( 'rd', 0xd, 0,   0,  0x1d1d1d1d ),
    req( 'rd', 0xe, 0x10e0, 0, 0          ), resp( 'rd', 0xe, 0,   0,  0x1e1e1e1e ),
    req( 'rd', 0xf, 0x10f0, 0, 0          ), resp( 'rd', 0xf, 0,   0,  0x1f1f1f1f ),
  ]

#-------------------------------------------------------------------------
# Write hits preserve neighboring words
#-------------------------------------------------------------------------

def write_hit_preserves_neighbors():
  msgs = []
  words = [0x01234567, 0x89abcdef, 0x13579bdf, 0x2468ace0]
  opaque = 0x80

  # All init transactions must happen before reads/writes.
  for word in range(4):
    msgs.extend([
      req( 'in', opaque, 0x1000 + 4*word, 0, words[word] ),
      resp('in', opaque, 0, 0, 0 ),
    ])
    opaque += 1

  # Update every word position, in a nonsequential order.
  for target, value in [
    (2, 0xa5c37e19),
    (0, 0x00000000),
    (3, 0xffffffff),
    (1, 0xdeadbeef),
  ]:
    msgs.extend([
      req( 'wr', opaque, 0x1000 + 4*target, 0, value ),
      resp('wr', opaque, 1, 0, 0 ),
    ])
    opaque += 1
    words[target] = value

    # Verify both the changed word and its unchanged neighbors.
    for word in range(4):
      msgs.extend([
        req( 'rd', opaque, 0x1000 + 4*word, 0, 0 ),
        resp('rd', opaque, 1, 0, words[word] ),
      ])
      opaque += 1

  return msgs

#-------------------------------------------------------------------------
# Read miss at a nonzero word offset
#-------------------------------------------------------------------------

def read_miss_last_word_first():
  return [
    #    type  opq   addr    len data          type  opq   test len data
    req( 'rd', 0xff, 0x100c, 0, 0 ), resp( 'rd', 0xff, 0, 0, 0x30303030 ),
    req( 'rd', 0x80, 0x1000, 0, 0 ), resp( 'rd', 0x80, 1, 0, 0x000c0ffe ),
    req( 'rd', 0x55, 0x1008, 0, 0 ), resp( 'rd', 0x55, 1, 0, 0x20202020 ),
    req( 'rd', 0xaa, 0x1004, 0, 0 ), resp( 'rd', 0xaa, 1, 0, 0x10101010 ),
  ]
  
#-------------------------------------------------------------------------
# Write miss updates only the requested word after refill
#-------------------------------------------------------------------------

def write_miss_preserves_refill():
  return [
    #    type  opq   addr    len data                 type  opq   test len data
    req( 'wr', 0x91, 0x1008, 0, 0xa5c37e19 ), resp( 'wr', 0x91, 0, 0, 0          ),
    req( 'rd', 0x92, 0x1000, 0, 0          ), resp( 'rd', 0x92, 1, 0, 0x000c0ffe ),
    req( 'rd', 0x93, 0x1004, 0, 0          ), resp( 'rd', 0x93, 1, 0, 0x10101010 ),
    req( 'rd', 0x94, 0x1008, 0, 0          ), resp( 'rd', 0x94, 1, 0, 0xa5c37e19 ),
    req( 'rd', 0x95, 0x100c, 0, 0          ), resp( 'rd', 0x95, 1, 0, 0x30303030 ),
  ]


#-------------------------------------------------------------------------
# Additional datapath directed tests
#-------------------------------------------------------------------------

def write_hit_preserves_neighbors():
  # Initialize all words before any read/write transaction. After each
  # write, read every word to detect an incorrect byte mask or word mux.
  msgs = []
  words = [0x01234567, 0x89abcdef, 0x13579bdf, 0x2468ace0]
  opaque = 0x80
  for word in range(4):
    msgs.extend([req('in', opaque, 0x1000 + 4*word, 0, words[word]),
                 resp('in', opaque, 0, 0, 0)])
    opaque += 1
  for target, value in [(2, 0xa5c37e19), (0, 0),
                        (3, 0xffffffff), (1, 0xdeadbeef)]:
    msgs.extend([req('wr', opaque, 0x1000 + 4*target, 0, value),
                 resp('wr', opaque, 1, 0, 0)])
    opaque += 1
    words[target] = value
    for word in range(4):
      msgs.extend([req('rd', opaque, 0x1000 + 4*word, 0, 0),
                   resp('rd', opaque, 1, 0, words[word])])
      opaque += 1
  return msgs


def read_miss_last_word_first():
  # Fetching word 3 must refill from the line start, not the word address.
  return [
    req('rd', 0xff, 0x100c, 0, 0), resp('rd', 0xff, 0, 0, 0x30303030),
    req('rd', 0x80, 0x1000, 0, 0), resp('rd', 0x80, 1, 0, 0x000c0ffe),
    req('rd', 0x55, 0x1008, 0, 0), resp('rd', 0x55, 1, 0, 0x20202020),
    req('rd', 0xaa, 0x1004, 0, 0), resp('rd', 0xaa, 1, 0, 0x10101010),
  ]


def write_miss_preserves_refill():
  # A write miss at word 2 must retain the other three refilled words.
  return [
    req('wr', 0x91, 0x1008, 0, 0xa5c37e19), resp('wr', 0x91, 0, 0, 0),
    req('rd', 0x92, 0x1000, 0, 0), resp('rd', 0x92, 1, 0, 0x000c0ffe),
    req('rd', 0x93, 0x1004, 0, 0), resp('rd', 0x93, 1, 0, 0x10101010),
    req('rd', 0x94, 0x1008, 0, 0), resp('rd', 0x94, 1, 0, 0xa5c37e19),
    req('rd', 0x95, 0x100c, 0, 0), resp('rd', 0x95, 1, 0, 0x30303030),
  ]


def dmap_all_indices_words():
  # Populate all 16 baseline entries, then revisit every word in reverse
  # order. This checks the full index width as well as the word mux.
  msgs = []
  for line in range(16):
    for word in range(4):
      n = 4*line + word
      msgs.extend([req('in', n, 0x1000 + 4*n, 0, 0xa5000000 + n),
                   resp('in', n, 0, 0, 0)])
  for n in reversed(range(64)):
    msgs.extend([req('rd', 0x80 + n, 0x1000 + 4*n, 0, 0),
                 resp('rd', 0x80 + n, 1, 0, 0xa5000000 + n)])
  return msgs


def bank_dirty_evict_data():
  # All three lines route to bank 3, index 5 in the baseline. They also
  # conflict in one alternative set, so the third line evicts the first
  # in either design. Nonzero bank/index bits must survive write-back.
  data = []
  for line in range(3):
    for word in range(4):
      data.extend([0x00000170 + line*0x400 + word*4,
                   0x12340000 + line*0x100 + word])
  return data


def bank_dirty_evict_words():
  msgs = []
  base = 0x00000170
  # Dirty the first line at word 2, then force it out with two conflicts.
  msgs.extend([req('wr', 0xe0, base + 8, 0, 0xdeadbeef),
               resp('wr', 0xe0, 0, 0, 0)])
  for line in (1, 2):
    msgs.extend([req('rd', 0xe0 + line, base + line*0x400, 0, 0),
                 resp('rd', 0xe0 + line, 0, 0, 0x12340000 + line*0x100)])
  # Returning to the first line must recover the modified word from
  # memory, together with its three unchanged neighbors.
  for i, word in enumerate((2, 0, 3, 1)):
    value = 0xdeadbeef if word == 2 else 0x12340000 + word
    msgs.extend([req('rd', 0xf0 + i, base + word*4, 0, 0),
                 resp('rd', 0xf0 + i, 0 if i == 0 else 1, 0, value)])
  return msgs

#-------------------------------------------------------------------------
# Generic tests
#-------------------------------------------------------------------------

test_case_table_generic = mk_test_case_table([
  (                                    "msg_func                    mem_data_func stall lat src sink"),

  [ "write_init_word",                  write_init_word,            None,         0.0,  0,  0,  0    ],
  [ "write_init_multi_word",            write_init_multi_word,      None,         0.0,  0,  0,  0    ],
  [ "write_init_cacheline",             write_init_cacheline,       None,         0.0,  0,  0,  0    ],
  [ "write_init_multi_cacheline",       write_init_multi_cacheline, None,         0.0,  0,  0,  0    ],
  [ "write_init_multi_word_sink_delay", write_init_multi_word,      None,         0.0,  0,  0,  10   ],
  [ "write_init_multi_word_src_delay",  write_init_multi_word,      None,         0.0,  0,  10, 0    ],

  [ "read_hit_word",                    read_hit_word,              None,         0.0,  0,  0,  0    ],
  [ "read_hit_multi_word",              read_hit_multi_word,        None,         0.0,  0,  0,  0    ],
  [ "read_hit_cacheline",               read_hit_cacheline,         None,         0.0,  0,  0,  0    ],
  [ "read_hit_multi_cacheline",         read_hit_multi_cacheline,   None,         0.0,  0,  0,  0    ],
  [ "read_hit_multi_word_sink_delay",   read_hit_multi_word,        None,         0.0,  0,  0,  10   ],
  [ "read_hit_multi_word_src_delay",    read_hit_multi_word,        None,         0.0,  0,  10, 0    ],

  [ "write_hit_word",                   write_hit_word,             None,         0.0,  0,  0,  0    ],
  [ "write_hit_multi_word",             write_hit_multi_word,       None,         0.0,  0,  0,  0    ],
  [ "write_hit_cacheline",              write_hit_cacheline,        None,         0.0,  0,  0,  0    ],
  [ "write_hit_multi_cacheline",        write_hit_multi_cacheline,  None,         0.0,  0,  0,  0    ],
  [ "write_hit_multi_word_sink_delay",  write_hit_multi_word,       None,         0.0,  0,  0,  10   ],
  [ "write_hit_multi_word_src_delay",   write_hit_multi_word,       None,         0.0,  0,  10, 0    ],

  [ "read_miss_word",                   read_miss_word,             data_64B,     0.0,  0,  0,  0    ],
  [ "read_miss_multi_word",             read_miss_multi_word,       data_64B,     0.0,  0,  0,  0    ],
  [ "read_miss_cacheline",              read_miss_cacheline,        data_64B,     0.0,  0,  0,  0    ],
  [ "read_miss_multi_cacheline",        read_miss_multi_cacheline,  data_512B,    0.0,  0,  0,  0    ],
  [ "read_miss_multi_word_sink_delay",  read_miss_multi_word,       data_64B,     0.9,  3,  0,  10   ],
  [ "read_miss_multi_word_src_delay",   read_miss_multi_word,       data_64B,     0.9,  3,  10, 0    ],

  [ "write_miss_word",                  write_miss_word,            data_64B,     0.0,  0,  0,  0    ],
  [ "write_miss_multi_word",            write_miss_multi_word,      data_64B,     0.0,  0,  0,  0    ],
  [ "write_miss_cacheline",             write_miss_cacheline,       data_64B,     0.0,  0,  0,  0    ],
  [ "write_miss_multi_cacheline",       write_miss_multi_cacheline, data_512B,    0.0,  0,  0,  0    ],
  [ "write_miss_multi_word_sink_delay", write_miss_multi_word,      data_64B,     0.9,  3,  0,  10   ],
  [ "write_miss_multi_word_src_delay",  write_miss_multi_word,      data_64B,     0.9,  3,  10, 0    ],

  [ "evict_word",                       evict_word,                 data_512B,    0.0,  0,  0,  0    ],
  [ "evict_multi_word",                 evict_multi_word,           data_512B,    0.0,  0,  0,  0    ],
  [ "evict_cacheline",                  evict_cacheline,            data_512B,    0.0,  0,  0,  0    ],
  [ "evict_multi_cacheline",            evict_multi_cacheline,      data_512B,    0.0,  0,  0,  0    ],
  [ "evict_multi_word_sink_delay",      evict_multi_word,           data_512B,    0.9,  3,  0,  10   ],
  [ "evict_multi_word_src_delay",       evict_multi_word,           data_512B,    0.9,  3,  10, 0    ],

  [ "write_hit_preserves_neighbors",    write_hit_preserves_neighbors, None,      0.0,  0,  0,  0    ],
  [ "read_miss_last_word_first",        read_miss_last_word_first,     data_64B,  0.0,  0,  0,  0    ],
  [ "write_miss_preserves_refill",      write_miss_preserves_refill,   data_64B,  0.0,  0,  0,  0    ],
  
  [ "write_hit_preserves_neighbors", write_hit_preserves_neighbors, None, 0.0, 0, 0, 0 ],
  [ "write_hit_preserves_neighbors_delays", write_hit_preserves_neighbors, None, 0.0, 0, 3, 5 ],
  [ "read_miss_last_word_first", read_miss_last_word_first, data_64B, 0.0, 0, 0, 0 ],
  [ "read_miss_last_word_first_delays", read_miss_last_word_first, data_64B, 0.5, 3, 2, 5 ],
  [ "write_miss_preserves_refill", write_miss_preserves_refill, data_64B, 0.0, 0, 0, 0 ],
  [ "write_miss_preserves_refill_delays", write_miss_preserves_refill, data_64B, 0.5, 3, 2, 5 ],
])

@pytest.mark.parametrize( **test_case_table_generic )
def test_generic( test_params, cmdline_opts ):
  run_test( CacheFL(), test_params, cmdline_opts, cmp_wo_test_field )

#-------------------------------------------------------------------------
# Test Case with Random Addresses and Data
#-------------------------------------------------------------------------

def random_read_write_words():
  rng = Random(0x4750)  # Fixed seed: same test every run

  # Must match the initial values supplied by data_512B().
  reference = {
    0x1000 + 4*i: 0xabcd1000 + 4*i
    for i in range(128)
  }

  msgs = []

  for i in range(96):
    addr   = 0x1000 + 4*rng.randrange(128)
    opaque = i & 0xff

    if rng.randrange(3) == 0:
      value = rng.getrandbits(32)

      msgs.extend([
        req( 'wr', opaque, addr, 0, value ),
        resp('wr', opaque, 0,    0, 0     ),
      ])

      reference[addr] = value

    else:
      msgs.extend([
        req( 'rd', opaque, addr, 0, 0               ),
        resp('rd', opaque, 0,    0, reference[addr] ),
      ])

  # Check every address at the end, including ones written earlier.
  for i in range(128):
    addr   = 0x1000 + 4*i
    opaque = (96 + i) & 0xff

    msgs.extend([
      req( 'rd', opaque, addr, 0, 0               ),
      resp('rd', opaque, 0,    0, reference[addr] ),
    ])

  return msgs

def random_read_only_local():
  # Repeated reads within eight cache lines.
  rng = Random(0x4751)
  msgs = []

  for i in range(96):
    addr = 0x1000 + 4*rng.randrange(32)
    msgs.extend([
      req( 'rd', i, addr, 0, 0 ),
      resp('rd', i, 0,    0, 0xabcd1000 + addr - 0x1000 ),
    ])

  return msgs


def random_hot_words():
  # Random reads and writes among the four words in one line.
  rng = Random(0x4752)
  reference = {0x1000 + 4*i: 0xabcd1000 + 4*i for i in range(4)}
  msgs = []

  for i in range(96):
    addr = 0x1000 + 4*rng.randrange(4)

    if rng.randrange(2):
      value = rng.getrandbits(32)
      msgs.extend([
        req( 'wr', i, addr, 0, value ),
        resp('wr', i, 0,    0, 0 ),
      ])
      reference[addr] = value
    else:
      msgs.extend([
        req( 'rd', i, addr, 0, 0 ),
        resp('rd', i, 0,    0, reference[addr] ),
      ])

  for i in range(4):
    addr = 0x1000 + 4*i
    msgs.extend([
      req( 'rd', 96+i, addr, 0, 0 ),
      resp('rd', 96+i, 0,    0, reference[addr] ),
    ])

  return msgs


def random_conflicting_lines():
  # These lines conflict in the baseline cache but fit in two ways.
  rng = Random(0x4753)
  reference = {
    addr: 0xabcd1000 + addr - 0x1000
    for base in (0x1000, 0x1100)
    for addr in (base, base+4, base+8, base+12)
  }
  msgs = []

  for i in range(96):
    addr = rng.choice((0x1000, 0x1100)) + 4*rng.randrange(4)

    if rng.randrange(3) == 0:
      value = rng.getrandbits(32)
      msgs.extend([
        req( 'wr', i, addr, 0, value ),
        resp('wr', i, 0,    0, 0 ),
      ])
      reference[addr] = value
    else:
      msgs.extend([
        req( 'rd', i, addr, 0, 0 ),
        resp('rd', i, 0,    0, reference[addr] ),
      ])

  for i, addr in enumerate(sorted(reference)):
    msgs.extend([
      req( 'rd', 96+i, addr, 0, 0 ),
      resp('rd', 96+i, 0,    0, reference[addr] ),
    ])

  return msgs

test_case_table_random = mk_test_case_table([
  (                             "msg_func                 mem_data_func stall lat src sink" ),

  [ "mixed",                   random_read_write_words,    data_512B,     0.0,  0,  0,  0 ],
  [ "mixed_delays",            random_read_write_words,    data_512B,     0.5,  3,  2,  5 ],
  [ "local_reads",             random_read_only_local,     data_512B,     0.0,  0,  0,  0 ],
  [ "hot_words",               random_hot_words,           data_512B,     0.0,  0,  0,  0 ],
  [ "conflicting_lines",       random_conflicting_lines,   data_512B,     0.0,  0,  0,  0 ],
  [ "conflicting_lines_delays", random_conflicting_lines,  data_512B,     0.5,  3,  2,  5 ],
])


@pytest.mark.parametrize( **test_case_table_random )
def test_random( test_params, cmdline_opts ):
  run_test( CacheFL(), test_params, cmdline_opts, cmp_wo_test_field )

#-------------------------------------------------------------------------
# Test Cases for Direct Mapped
#-------------------------------------------------------------------------

def dmap_clean_conflict():
  # Both lines map to entry 0, so each replaces the other.
  return [
    req( 'rd', 0x21, 0x1000, 0, 0 ), resp( 'rd', 0x21, 0, 0, 0xabcd1000 ),
    req( 'rd', 0x22, 0x1100, 0, 0 ), resp( 'rd', 0x22, 0, 0, 0xabcd1100 ),
    req( 'rd', 0x23, 0x1000, 0, 0 ), resp( 'rd', 0x23, 0, 0, 0xabcd1000 ),
  ]


def dmap_dirty_conflict():
  # Replacing a dirty line must write it back to memory.
  return [
    req( 'wr', 0x31, 0x100c, 0, 0xdeadbeef ), resp( 'wr', 0x31, 0, 0, 0          ),
    req( 'rd', 0x32, 0x1100, 0, 0          ), resp( 'rd', 0x32, 0, 0, 0xabcd1100 ),
    req( 'rd', 0x33, 0x100c, 0, 0          ), resp( 'rd', 0x33, 0, 0, 0xdeadbeef ),
    req( 'rd', 0x34, 0x1008, 0, 0          ), resp( 'rd', 0x34, 1, 0, 0xabcd1008 ),
  ]


def dmap_capacity_boundary():
  msgs = []

  # Fill all 16 entries, then access a 17th line.
  for i in range(17):
    addr = 0x1000 + 16*i
    msgs.extend([
      req( 'rd', i, addr, 0, 0 ),
      resp('rd', i, 0,    0, 0xabcd1000 + 16*i ),
    ])

  # The 17th line replaced entry 0; entries 1–15 should still hit.
  for i in range(1, 16):
    addr = 0x1000 + 16*i
    msgs.extend([
      req( 'rd', 0x40+i, addr, 0, 0 ),
      resp('rd', 0x40+i, 1,    0, 0xabcd1000 + 16*i ),
    ])

  msgs.extend([
    req( 'rd', 0x70, 0x1000, 0, 0 ),
    resp('rd', 0x70, 0,      0, 0xabcd1000 ),
  ])

  return msgs

test_case_table_dmap = mk_test_case_table([
  (                              "msg_func                 mem_data_func stall lat src sink" ),

  [ "dmap_all_indices_words",        dmap_all_indices_words, None,        0.0,  0,  0,  0 ],
  [ "dmap_all_indices_words_delays", dmap_all_indices_words, None,        0.0,  0,  2,  5 ],
  [ "dmap_clean_conflict",           dmap_clean_conflict,    data_512B,   0.0,  0,  0,  0 ],
  [ "dmap_dirty_conflict",           dmap_dirty_conflict,    data_512B,   0.0,  0,  0,  0 ],
  [ "dmap_dirty_conflict_delays",    dmap_dirty_conflict,    data_512B,   0.5,  3,  2,  5 ],
  [ "dmap_capacity_boundary",        dmap_capacity_boundary, data_512B,   0.0,  0,  0,  0 ],
])

@pytest.mark.parametrize( **test_case_table_dmap )
def test_dmap( test_params, cmdline_opts ):
  run_test( CacheFL(), test_params, cmdline_opts, cmp_wo_test_field )

#-------------------------------------------------------------------------
# Test Cases for Set Associative
#-------------------------------------------------------------------------
def sassoc_two_way_hit():
  # These lines share a set but should occupy different ways.
  return [
    req( 'rd', 0x41, 0x1000, 0, 0 ), resp( 'rd', 0x41, 0, 0, 0xabcd1000 ),
    req( 'rd', 0x42, 0x1080, 0, 0 ), resp( 'rd', 0x42, 0, 0, 0xabcd1080 ),
    req( 'rd', 0x43, 0x1000, 0, 0 ), resp( 'rd', 0x43, 1, 0, 0xabcd1000 ),
    req( 'rd', 0x44, 0x1080, 0, 0 ), resp( 'rd', 0x44, 1, 0, 0xabcd1080 ),
  ]


def sassoc_lru_dirty_victim():
  # Touch A after loading B. B becomes LRU and is dirty.
  return [
    req( 'rd', 0x51, 0x1000, 0, 0          ), resp( 'rd', 0x51, 0, 0, 0xabcd1000 ),
    req( 'wr', 0x52, 0x1084, 0, 0xfeedface ), resp( 'wr', 0x52, 0, 0, 0          ),
    req( 'rd', 0x53, 0x1000, 0, 0          ), resp( 'rd', 0x53, 1, 0, 0xabcd1000 ),
    req( 'rd', 0x54, 0x1100, 0, 0          ), resp( 'rd', 0x54, 0, 0, 0xabcd1100 ),
    req( 'rd', 0x55, 0x1000, 0, 0          ), resp( 'rd', 0x55, 1, 0, 0xabcd1000 ),
    req( 'rd', 0x56, 0x1084, 0, 0          ), resp( 'rd', 0x56, 0, 0, 0xfeedface ),
  ]


def sassoc_lru_other_way():
  # Touch B before loading C. This time A must be evicted.
  return [
    req( 'rd', 0x61, 0x1000, 0, 0 ), resp( 'rd', 0x61, 0, 0, 0xabcd1000 ),
    req( 'rd', 0x62, 0x1080, 0, 0 ), resp( 'rd', 0x62, 0, 0, 0xabcd1080 ),
    req( 'rd', 0x63, 0x1080, 0, 0 ), resp( 'rd', 0x63, 1, 0, 0xabcd1080 ),
    req( 'rd', 0x64, 0x1100, 0, 0 ), resp( 'rd', 0x64, 0, 0, 0xabcd1100 ),
    req( 'rd', 0x65, 0x1080, 0, 0 ), resp( 'rd', 0x65, 1, 0, 0xabcd1080 ),
    req( 'rd', 0x66, 0x1000, 0, 0 ), resp( 'rd', 0x66, 0, 0, 0xabcd1000 ),
  ]

def sassoc_lru_evict_way1():
  # Touch A before loading C. This time B must be evicted.
  return [
    req( 'rd', 0x61, 0x1000, 0, 0 ), resp( 'rd', 0x61, 0, 0, 0xabcd1000 ),
    req( 'rd', 0x62, 0x1080, 0, 0 ), resp( 'rd', 0x62, 0, 0, 0xabcd1080 ),
    req( 'rd', 0x63, 0x1000, 0, 0 ), resp( 'rd', 0x63, 1, 0, 0xabcd1000 ),
    req( 'rd', 0x64, 0x1100, 0, 0 ), resp( 'rd', 0x64, 0, 0, 0xabcd1100 ),
    req( 'rd', 0x65, 0x1000, 0, 0 ), resp( 'rd', 0x65, 1, 0, 0xabcd1000 ),
    req( 'rd', 0x66, 0x1080, 0, 0 ), resp( 'rd', 0x66, 0, 0, 0xabcd1080 ),
  ]

def sassoc_dirty_evict_way0():
  # Make A dirty, then access B to make A the LRU.
  # Load C to evict A and verify its modified data is written back.
  return [
    req( 'rd', 0x51, 0x1000, 0, 0          ), resp( 'rd', 0x51, 0, 0, 0xabcd1000 ),
    req( 'rd', 0x52, 0x1080, 0, 0          ), resp( 'rd', 0x52, 0, 0, 0xabcd1080 ),
    req( 'wr', 0x53, 0x1000, 0, 0xfeedface ), resp( 'wr', 0x53, 1, 0, 0          ),
    req( 'rd', 0x54, 0x1080, 0, 0          ), resp( 'rd', 0x54, 1, 0, 0xabcd1080 ),
    req( 'rd', 0x55, 0x1100, 0, 0          ), resp( 'rd', 0x55, 0, 0, 0xabcd1100 ),
    req( 'rd', 0x56, 0x1080, 0, 0          ), resp( 'rd', 0x56, 1, 0, 0xabcd1080 ),
    req( 'rd', 0x57, 0x1000, 0, 0          ), resp( 'rd', 0x57, 0, 0, 0xfeedface ),
  ]

def sassoc_repeated_replacements():
  return [
    req( 'rd', 0x61, 0x1000, 0, 0 ), resp( 'rd', 0x61, 0, 0, 0xabcd1000 ),
    req( 'rd', 0x62, 0x1080, 0, 0 ), resp( 'rd', 0x62, 0, 0, 0xabcd1080 ),
    req( 'rd', 0x63, 0x1000, 0, 0 ), resp( 'rd', 0x63, 1, 0, 0xabcd1000 ),
    req( 'rd', 0x64, 0x1100, 0, 0 ), resp( 'rd', 0x64, 0, 0, 0xabcd1100 ),
    req( 'rd', 0x65, 0x1000, 0, 0 ), resp( 'rd', 0x65, 1, 0, 0xabcd1000 ),
    req( 'rd', 0x66, 0x1180, 0, 0 ), resp( 'rd', 0x66, 0, 0, 0xabcd1180 ),
    req( 'rd', 0x67, 0x1000, 0, 0 ), resp( 'rd', 0x67, 1, 0, 0xabcd1000 ),
    req( 'rd', 0x68, 0x1080, 0, 0 ), resp( 'rd', 0x68, 0, 0, 0xabcd1080 ),
  ]

def sassoc_dirty_both_ways():
  return [
    req( 'rd', 0x51, 0x1000, 0, 0          ), resp( 'rd', 0x51, 0, 0, 0xabcd1000 ),
    req( 'rd', 0x52, 0x1080, 0, 0          ), resp( 'rd', 0x52, 0, 0, 0xabcd1080 ),
    req( 'wr', 0x53, 0x1000, 0, 0xfeedface ), resp( 'wr', 0x53, 1, 0, 0          ),
    req( 'wr', 0x54, 0x1080, 0, 0xfacefeed ), resp( 'wr', 0x54, 1, 0, 0          ),
    req( 'rd', 0x55, 0x1000, 0, 0          ), resp( 'rd', 0x55, 1, 0, 0xfeedface ),
    req( 'rd', 0x56, 0x1100, 0, 0          ), resp( 'rd', 0x56, 0, 0, 0xabcd1100 ),
    req( 'rd', 0x57, 0x1180, 0, 0          ), resp( 'rd', 0x57, 0, 0, 0xabcd1180 ),
    req( 'rd', 0x58, 0x1000, 0, 0          ), resp( 'rd', 0x58, 0, 0, 0xfeedface ),
    req( 'rd', 0x59, 0x1080, 0, 0          ), resp( 'rd', 0x59, 0, 0, 0xfacefeed ),
  ]

def sassoc_independent_sets():
  return [
    req( 'rd', 0x61, 0x1000, 0, 0 ), resp( 'rd', 0x61, 0, 0, 0xabcd1000 ),
    req( 'rd', 0x62, 0x1080, 0, 0 ), resp( 'rd', 0x62, 0, 0, 0xabcd1080 ),
    req( 'rd', 0x63, 0x1010, 0, 0 ), resp( 'rd', 0x63, 0, 0, 0xabcd1010 ),
    req( 'rd', 0x64, 0x1090, 0, 0 ), resp( 'rd', 0x64, 0, 0, 0xabcd1090 ),
    req( 'rd', 0x65, 0x1000, 0, 0 ), resp( 'rd', 0x65, 1, 0, 0xabcd1000 ),
    req( 'rd', 0x66, 0x1010, 0, 0 ), resp( 'rd', 0x66, 1, 0, 0xabcd1010 ),
    req( 'rd', 0x67, 0x1100, 0, 0 ), resp( 'rd', 0x67, 0, 0, 0xabcd1100 ),
    req( 'rd', 0x68, 0x1110, 0, 0 ), resp( 'rd', 0x68, 0, 0, 0xabcd1110 ),
    req( 'rd', 0x69, 0x1000, 0, 0 ), resp( 'rd', 0x69, 1, 0, 0xabcd1000 ),
    req( 'rd', 0x70, 0x1010, 0, 0 ), resp( 'rd', 0x70, 1, 0, 0xabcd1010 ),
    req( 'rd', 0x71, 0x1080, 0, 0 ), resp( 'rd', 0x71, 0, 0, 0xabcd1080 ),
    req( 'rd', 0x72, 0x1090, 0, 0 ), resp( 'rd', 0x72, 0, 0, 0xabcd1090 ),
  ]

def sassoc_capacity_boundary():
  msgs = []

  # Fill eight sets with two lines each, then add a third line to set 0.
  for i in range(17):
    addr = 0x1000 + 16*i
    msgs.extend([
      req( 'rd', i, addr, 0, 0 ),
      resp('rd', i, 0,    0, 0xabcd1000 + 16*i ),
    ])

  # Lines 1–15 should still be present.
  for i in range(1, 16):
    addr = 0x1000 + 16*i
    msgs.extend([
      req( 'rd', 0x40+i, addr, 0, 0 ),
      resp('rd', 0x40+i, 1,    0, 0xabcd1000 + 16*i ),
    ])

  # The oldest line in set 0 was displaced.
  msgs.extend([
    req( 'rd', 0x70, 0x1000, 0, 0 ),
    resp('rd', 0x70, 0,      0, 0xabcd1000 ),
  ])

  return msgs

test_case_table_sassoc = mk_test_case_table([
  (                              "msg_func                    mem_data_func stall lat src sink" ),

  [ "sassoc_two_way_hit",           sassoc_two_way_hit,           data_512B,   0.0,  0,  0,  0 ],
  [ "sassoc_lru_dirty_victim",      sassoc_lru_dirty_victim,      data_512B,   0.0,  0,  0,  0 ],
  [ "sassoc_lru_dirty_delays",      sassoc_lru_dirty_victim,      data_512B,   0.5,  3,  2,  5 ],
  [ "sassoc_dirty_evict_way0",      sassoc_dirty_evict_way0,      data_512B,   0.0,  0,  0,  0 ],
  [ "sassoc_dirty_evict_way0_sink" ,sassoc_dirty_evict_way0,      data_512B,   0.0,  0,  0,  5 ],
  [ "sassoc_dirty_evict_way0_src",  sassoc_dirty_evict_way0,      data_512B,   0.0,  0,  3,  0 ],
  [ "sassoc_lru_other_way",         sassoc_lru_other_way,         data_512B,   0.0,  0,  0,  0 ],
  [ "sassoc_lru_evict_way1",        sassoc_lru_evict_way1,        data_512B,   0.0,  0,  0,  0 ],
  [ "sassoc_capacity_boundary",     sassoc_capacity_boundary,     data_512B,   0.0,  0,  0,  0 ],
  [ "sassoc_repeated_replacements", sassoc_repeated_replacements, data_512B,   0.0,  0,  0, 0 ],
  [ "sassoc_dirty_both_ways",       sassoc_dirty_both_ways,       data_512B,   0.0,  0,  0, 0 ],
  [ "sassoc_independent_sets",      sassoc_independent_sets,      data_512B,   0.0,  0,  0, 0 ],
])

@pytest.mark.parametrize( **test_case_table_sassoc )
def test_sassoc( test_params, cmdline_opts ):
  run_test( CacheFL(), test_params, cmdline_opts, cmp_wo_test_field )

#-------------------------------------------------------------------------
# Banked cache test
#-------------------------------------------------------------------------
# This test case is to test if the bank offset is implemented correctly.
# The idea behind this test case is to differentiate between a cache with
# no bank bits and a design has one/two bank bits by looking at cache
# request hit/miss status.

# We first design a test case for 2-way set-associative cache. The last
# request should hit only if students implement the correct index bit to
# be [6:9]. If they implement the index bit to be [4:7] or [5:8], the
# last request is a miss, which is wrong. See below for explanation. This
# test case also works for the baseline direct-mapped cache.

# Direct-mapped
#
#   no bank(should fail):
#      idx
#   00 0000 0000
#   01 0000 0000
#   10 0000 0000
#   00 0000 0000
#   idx: 0, 0, 0 so the third one with tag 10 will evict the first one
#   with tag 00, and thus the fourth read will miss instead of hit.
#
#   4-bank(correct):
#    idx  bk
#   00 00 00 0000
#   01 00 00 0000
#   10 00 00 0000
#   00 00 00 0000
#   idx: 0, 4, 8 so the third one with tag 10 won't evict anything, and
#   thus the fourth read will hit.

# 2-way set-associative
#
#   no bank(should fail):
#        idx
#   00 0 000 0000
#   01 0 000 0000
#   10 0 000 0000
#   00 0 000 0000
#   idx: 0, 0, 0 so the third one with tag 10 will evict the first one
#   with tag 00, and thus the fourth read will miss instead of hit.
#
#   4-bank(correct):
#     idx  bk
#   0 0 00 00 0000
#   0 1 00 00 0000
#   1 0 00 00 0000
#   idx: 0, 4, 0 so the third one with tag 10 won't evict anything, and
#   thus the fourth read will hit.

def bank_test():
  return [
    #    type  opq  addr       len data                type  opq  test len data
    req( 'rd', 0x0, 0x00000000, 0, 0 ), resp( 'rd', 0x0, 0,   0,  0xdeadbeef ),
    req( 'rd', 0x1, 0x00000100, 0, 0 ), resp( 'rd', 0x1, 0,   0,  0x00c0ffee ),
    req( 'rd', 0x2, 0x00000200, 0, 0 ), resp( 'rd', 0x2, 0,   0,  0xffffffff ),
    req( 'rd', 0x3, 0x00000000, 0, 0 ), resp( 'rd', 0x3, 1,   0,  0xdeadbeef ),
  ]

def bank_test_data():
  return [
    # addr      data (in int)
    0x00000000, 0xdeadbeef,
    0x00000100, 0x00c0ffee,
    0x00000200, 0xffffffff,
  ]

test_case_table_bank = mk_test_case_table([
  (             "msg_func   mem_data_func   stall lat src sink"),
  [ "bank_test", bank_test, bank_test_data, 0.0,  0,  0,  0    ],
  [ "bank_dirty_evict_words", bank_dirty_evict_words, bank_dirty_evict_data, 0.0, 0, 0, 0 ],
  [ "bank_dirty_evict_words_delays", bank_dirty_evict_words, bank_dirty_evict_data, 0.5, 3, 2, 5 ],
])

@pytest.mark.parametrize( **test_case_table_bank )
def test_bank( test_params, cmdline_opts ):
  run_test( CacheFL(), test_params, cmdline_opts, cmp_wo_test_field )
