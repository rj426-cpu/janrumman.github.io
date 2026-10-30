#!/bin/bash

set -e

TEST="lab3_mem/test/CacheAltRandom_test.py::test_random_reads_writes"

echo "========================================"
echo " CACHE RANDOMIZED VERIFICATION SUITE"
echo "========================================"

for workload in baseline conflict; do
  for seed in 4750 1234 2026 9999; do

    echo ""
    echo "========================================"
    echo "Workload: $workload | Seed: $seed"
    echo "========================================"

    CACHE_WORKLOAD="$workload" CACHE_SEED="$seed" \
      python -m pytest -x -q -s "$TEST"

  done
done

echo ""
echo "========================================"
echo " ALL 8 RANDOMIZED TESTS PASSED"
echo " 8000 TOTAL REQUESTS VERIFIED"
echo "========================================"
