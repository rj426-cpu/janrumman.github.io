
#=========================================================================
# CacheAlt Randomized Verification
#=========================================================================
# Features:
# - 1000 randomized read/write requests
# - Golden reference memory scoreboard
# - Baseline and conflict-heavy workloads
# - Configurable random seed
# - Hardware performance counter verification
# - Formatted performance results table
#=========================================================================

import os
import random
import pytest

from pymtl3 import *
from pymtl3.passes.backends.verilog import (
    VerilogPlaceholderPass,
    VerilogTranslationImportPass,
)

from lab3_mem.CacheAlt import CacheAlt
from lab3_mem.test.harness import TestHarness, req, resp


def test_random_reads_writes():

  #-----------------------------------------------------------------------
  # Configuration
  #-----------------------------------------------------------------------

  SEED = int(os.environ.get("CACHE_SEED", "4750"))
  NUM_REQUESTS = 1000
  MAX_CYCLES = 100000

  WORKLOAD = os.environ.get("CACHE_WORKLOAD", "conflict")

  rng = random.Random(SEED)

  #-----------------------------------------------------------------------
  # Golden Reference Memory
  #-----------------------------------------------------------------------

  reference_memory = {}

  if WORKLOAD == "baseline":

    # 64 words spanning 256 bytes
    addresses = [4 * i for i in range(64)]

  elif WORKLOAD == "conflict":

    # 64 words spanning 32 cache lines (512 bytes)
    # Forces replacements and dirty evictions
    addresses = [
      base + offset
      for base in range(0, 512, 16)
      for offset in (0, 4)
    ]

  else:
    raise ValueError(f"Unknown workload: {WORKLOAD}")

  # Initialize golden memory with random data
  for addr in addresses:
    reference_memory[addr] = rng.getrandbits(32)

  initial_memory = reference_memory.copy()

  #-----------------------------------------------------------------------
  # Generate Randomized Requests
  #-----------------------------------------------------------------------

  msgs = []

  num_reads = 0
  num_writes = 0

  for i in range(NUM_REQUESTS):

    addr = rng.choice(addresses)
    opaque = i % 256

    if rng.random() < 0.5:

      # READ: Get expected value from golden memory
      expected_data = reference_memory[addr]

      msgs.append(
        req('rd', opaque, addr, 0, 0)
      )

      msgs.append(
        resp('rd', opaque, 0, 0, expected_data)
      )

      num_reads += 1

    else:

      # WRITE: Update golden memory
      data = rng.getrandbits(32)

      msgs.append(
        req('wr', opaque, addr, 0, data)
      )

      msgs.append(
        resp('wr', opaque, 0, 0, 0)
      )

      reference_memory[addr] = data
      num_writes += 1

  #-----------------------------------------------------------------------
  # Create Test Harness
  #-----------------------------------------------------------------------

  # Compare functional response data, not hit/miss test field
  def compare_response(msg, ref):
    return (
      msg.type_ == ref.type_
      and msg.opaque == ref.opaque
      and msg.len == ref.len
      and msg.data == ref.data
    )

  th = TestHarness(
    CacheAlt(),
    cmp_fn=compare_response,
  )

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

  # Initialize backing memory
  th.load(
    list(initial_memory.keys()),
    list(initial_memory.values()),
  )

  #-----------------------------------------------------------------------
  # Import SystemVerilog RTL
  #-----------------------------------------------------------------------

  th.apply(VerilogPlaceholderPass())
  th = VerilogTranslationImportPass()(th)

  th.apply(DefaultPassGroup())
  th.sim_reset()

  #-----------------------------------------------------------------------
  # Run Simulation
  #-----------------------------------------------------------------------

  cycles = 0

  for cycle in range(MAX_CYCLES):

    th.sim_tick()

    if th.done():
      break

  else:
    pytest.fail(
      f"Simulation timed out after {MAX_CYCLES} cycles"
    )

  cycles = cycles + 1

  #-----------------------------------------------------------------------
  # Read Hardware Performance Counters
  #-----------------------------------------------------------------------

  accesses = int(th.cache.total_accesses)
  hits = int(th.cache.cache_hits)
  misses = int(th.cache.cache_misses)
  evictions = int(th.cache.dirty_evictions)

  #-----------------------------------------------------------------------
  # Verify Counter Consistency
  #-----------------------------------------------------------------------

  assert accesses == NUM_REQUESTS, (
    f"Expected {NUM_REQUESTS} accesses, got {accesses}"
  )

  assert hits + misses == NUM_REQUESTS, (
    f"Expected {NUM_REQUESTS} hits + misses, "
    f"got {hits + misses}"
  )

  assert evictions <= misses, (
    f"Dirty evictions ({evictions}) exceed misses ({misses})"
  )

  #-----------------------------------------------------------------------
  # Calculate Performance Metrics
  #-----------------------------------------------------------------------

  hit_rate = (
    100.0 * hits / (hits + misses)
    if hits + misses else 0
  )

  miss_rate = (
    100.0 * misses / (hits + misses)
    if hits + misses else 0
  )

  cycles_per_request = cycles / NUM_REQUESTS

  #-----------------------------------------------------------------------
  # Print Formatted Results Table
  #-----------------------------------------------------------------------

  results = [
    ("Workload", WORKLOAD),
    ("Random Seed", SEED),
    ("Total Requests", NUM_REQUESTS),
    ("Read Requests", num_reads),
    ("Write Requests", num_writes),
    ("Simulation Cycles", cycles),
    ("Total Accesses", accesses),
    ("Cache Hits", hits),
    ("Cache Misses", misses),
    ("Dirty Evictions", evictions),
    ("Hit Rate", f"{hit_rate:.2f}%"),
    ("Miss Rate", f"{miss_rate:.2f}%"),
    ("Cycles per Request", f"{cycles_per_request:.2f}"),
  ]

  print("\n")
  print("=" * 54)
  print("       RANDOMIZED CACHE VERIFICATION RESULTS")
  print("=" * 54)

  print(f"| {'Metric':<26} | {'Value':>19} |")
  print("|" + "-" * 28 + "|" + "-" * 21 + "|")

  for metric, value in results:
    print(f"| {metric:<26} | {str(value):>19} |")

  print("=" * 54)

  print(
    f"\nPASS: All {NUM_REQUESTS} cache responses "
    "matched the reference model."
  )
