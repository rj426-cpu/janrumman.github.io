
#=========================================================================
# CacheAlt Performance Counter Tests
#=========================================================================

import pytest

from pymtl3 import *
from pymtl3.passes.backends.verilog import (
    VerilogPlaceholderPass,
    VerilogTranslationImportPass,
)

from lab3_mem.CacheAlt import CacheAlt
from lab3_mem.test.harness import TestHarness, req, resp


def test_three_reads():

  # First read misses; subsequent reads hit.
  msgs = [
    req ('rd', 0x00, 0x00000000, 0, 0),
    resp('rd', 0x00, 0,          0, 0x12345678),

    req ('rd', 0x01, 0x00000000, 0, 0),
    resp('rd', 0x01, 1,          0, 0x12345678),

    req ('rd', 0x02, 0x00000000, 0, 0),
    resp('rd', 0x02, 1,          0, 0x12345678),
  ]

  # Create test harness
  th = TestHarness(CacheAlt())

  th.set_param(
    "top.src.construct",
    msgs=msgs[::2],
    initial_delay=3,
  )

  th.set_param(
    "top.sink.construct",
    msgs=msgs[1::2],
    initial_delay=3,
  )

  # Elaborate
  th.elaborate()

  # Initialize backing memory
  th.load([0x00000000], [0x12345678])

  # Configure and import SystemVerilog RTL
  th.apply(VerilogPlaceholderPass())
  th = VerilogTranslationImportPass()(th)

  # Set up simulation
  th.apply(DefaultPassGroup())
  th.sim_reset()

  # Debug: check whether testbench is already finished
  print("\nDone immediately after reset:", th.done())

  # Run simulation
  cycles = 0

  for cycle in range(200):

    th.sim_tick()
    cycles += 1

    if th.done():
      break

  else:
    pytest.fail("Cache did not finish within 200 cycles")

  # Debug: check whether all messages were processed
  print("Simulation cycles:", cycles)
  print("Source done:", th.src.done())
  print("Sink done:", th.sink.done())

  # Read performance counters
  total_accesses  = int(th.cache.total_accesses)
  cache_hits      = int(th.cache.cache_hits)
  cache_misses    = int(th.cache.cache_misses)
  dirty_evictions = int(th.cache.dirty_evictions)

  print("\nCache Performance Counters:")
  print(f"Total accesses:  {total_accesses}")
  print(f"Cache hits:      {cache_hits}")
  print(f"Cache misses:    {cache_misses}")
  print(f"Dirty evictions: {dirty_evictions}")

  # Verify expected results
  assert total_accesses == 3, (
    f"Expected 3 accesses, got {total_accesses}"
  )

  assert cache_hits == 2, (
    f"Expected 2 hits, got {cache_hits}"
  )

  assert cache_misses == 1, (
    f"Expected 1 miss, got {cache_misses}"
  )

  assert dirty_evictions == 0, (
    f"Expected 0 dirty evictions, got {dirty_evictions}"
  )

def test_dirty_eviction():

  # Use three addresses mapping to the same cache set.
  # For a two-way set-associative cache with 16-byte lines
  # and 8 sets, these addresses share the same index.
  #
  # A: 0x00000000
  # B: 0x00000080
  # C: 0x00000100
  #
  # Write A -> miss, line becomes dirty
  # Read B  -> miss, fills second way
  # Read C  -> miss, forces replacement of one way
  #
  # Depending on the replacement policy, A may be evicted.

  msgs = [
    req ('wr', 0x00, 0x00000000, 0, 0xDEADBEEF),
    resp('wr', 0x00, 0,          0, 0),

    req ('rd', 0x01, 0x00000080, 0, 0),
    resp('rd', 0x01, 0,          0, 0x22222222),

    req ('rd', 0x02, 0x00000100, 0, 0),
    resp('rd', 0x02, 0,          0, 0x33333333),
  ]

  th = TestHarness(CacheAlt())

  th.set_param(
    "top.src.construct",
    msgs=msgs[::2],
    initial_delay=3,
  )

  th.set_param(
    "top.sink.construct",
    msgs=msgs[1::2],
    initial_delay=3,
  )

  th.elaborate()

  # Initialize backing memory for B and C
  th.load(
    [0x00000080, 0x00000100],
    [0x22222222, 0x33333333],
  )

  th.apply(VerilogPlaceholderPass())
  th = VerilogTranslationImportPass()(th)

  th.apply(DefaultPassGroup())
  th.sim_reset()

  for cycle in range(300):
    th.sim_tick()

    if th.done():
      break
  else:
    pytest.fail("Dirty eviction test timed out")

  total_accesses  = int(th.cache.total_accesses)
  cache_hits      = int(th.cache.cache_hits)
  cache_misses    = int(th.cache.cache_misses)
  dirty_evictions = int(th.cache.dirty_evictions)

  print("\nDirty Eviction Test:")
  print(f"Total accesses:  {total_accesses}")
  print(f"Cache hits:      {cache_hits}")
  print(f"Cache misses:    {cache_misses}")
  print(f"Dirty evictions: {dirty_evictions}")

  assert total_accesses == 3
  assert cache_hits == 0
  assert cache_misses == 3

  # At least one dirty eviction should occur
  assert dirty_evictions >= 1

#=========================================================================
# Test: Write Miss and Write Hit
#=========================================================================

def test_write_hit_miss():

  # First write to A: miss, allocate cache line, mark dirty.
  # Second write to A: hit.
  # Read A: hit, verify the second write was stored.

  msgs = [
    req ('wr', 0x00, 0x00000000, 0, 0x11111111),
    resp('wr', 0x00, 0,          0, 0),

    req ('wr', 0x01, 0x00000000, 0, 0x22222222),
    resp('wr', 0x01, 1,          0, 0),

    req ('rd', 0x02, 0x00000000, 0, 0),
    resp('rd', 0x02, 1,          0, 0x22222222),
  ]

  th = TestHarness(CacheAlt())

  th.set_param(
    "top.src.construct",
    msgs=msgs[::2],
    initial_delay=3,
  )

  th.set_param(
    "top.sink.construct",
    msgs=msgs[1::2],
    initial_delay=3,
  )

  th.elaborate()
  th.load([0x00000000], [0x00000000])

  th.apply(VerilogPlaceholderPass())
  th = VerilogTranslationImportPass()(th)

  th.apply(DefaultPassGroup())
  th.sim_reset()

  for cycle in range(300):
    th.sim_tick()

    if th.done():
      break
  else:
    pytest.fail("Write hit/miss test timed out")

  total_accesses  = int(th.cache.total_accesses)
  cache_hits      = int(th.cache.cache_hits)
  cache_misses    = int(th.cache.cache_misses)
  dirty_evictions = int(th.cache.dirty_evictions)

  print("\nWrite Hit/Miss Test:")
  print(f"Total accesses:  {total_accesses}")
  print(f"Cache hits:      {cache_hits}")
  print(f"Cache misses:    {cache_misses}")
  print(f"Dirty evictions: {dirty_evictions}")

  assert total_accesses == 3
  assert cache_hits == 2
  assert cache_misses == 1
  assert dirty_evictions == 0


#=========================================================================
# Test: WRITE_INIT Counter Behavior
#=========================================================================

def test_write_init_counters():

  # WRITE_INIT initializes a cache line.
  # It should count as an access, but not as a hit or miss.
  # A subsequent read of that address should hit.

  msgs = [
    req ('in', 0x00, 0x00000000, 0, 0xABCDEF12),
    resp('in', 0x00, 0,          0, 0),

    req ('rd', 0x01, 0x00000000, 0, 0),
    resp('rd', 0x01, 1,          0, 0xABCDEF12),
  ]

  th = TestHarness(CacheAlt())

  th.set_param(
    "top.src.construct",
    msgs=msgs[::2],
    initial_delay=3,
  )

  th.set_param(
    "top.sink.construct",
    msgs=msgs[1::2],
    initial_delay=3,
  )

  th.elaborate()

  th.apply(VerilogPlaceholderPass())
  th = VerilogTranslationImportPass()(th)

  th.apply(DefaultPassGroup())
  th.sim_reset()

  for cycle in range(300):
    th.sim_tick()

    if th.done():
      break
  else:
    pytest.fail("WRITE_INIT test timed out")

  total_accesses  = int(th.cache.total_accesses)
  cache_hits      = int(th.cache.cache_hits)
  cache_misses    = int(th.cache.cache_misses)
  dirty_evictions = int(th.cache.dirty_evictions)

  print("\nWRITE_INIT Test:")
  print(f"Total accesses:  {total_accesses}")
  print(f"Cache hits:      {cache_hits}")
  print(f"Cache misses:    {cache_misses}")
  print(f"Dirty evictions: {dirty_evictions}")

  assert total_accesses == 2
  assert cache_hits == 1
  assert cache_misses == 0
  assert dirty_evictions == 0
