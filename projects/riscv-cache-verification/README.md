# RISC-V Cache Design and Verification

A SystemVerilog cache design and verification project developed as part of Cornell University's **ECE 4750: Computer Architecture**, with additional independent work focused on hardware performance monitoring, randomized verification, and cache benchmarking.

## Overview

This project implements and verifies a two-way set-associative, write-back cache using SystemVerilog and PyMTL3.

The original cache implementation was developed collaboratively by **Rumman Jan and Ariel Lai** for ECE 4750 Lab 3.

After completing the course lab, I independently extended the project to explore cache performance measurement and more comprehensive verification techniques.

## Cache Architecture

The cache features:

- Two-way set-associative organization
- Write-back policy with dirty-bit tracking
- Valid and tag tracking
- Cache controller implemented as a finite-state machine
- Support for read, write, and write-initialize requests
- Integration with a PyMTL3 test harness and backing memory model

## Original Course Implementation

**Contributors: Rumman Jan and Ariel Lai**

The original ECE 4750 Lab 3 work involved implementing and testing the cache architecture, including its controller, datapath, request handling, hit/miss behavior, refill operations, and dirty-line eviction.

This portion of the project was completed collaboratively as part of the course.

## Independent Extensions Beyond Lab Requirements

**Contributor: Rumman Jan**

Following the original lab, I independently added the following features.

### 1. Hardware Performance Counters

Extended the SystemVerilog cache controller with four 32-bit hardware counters:

| Counter | Description |
|---|---|
| `total_accesses` | Counts accepted cache requests |
| `cache_hits` | Counts read/write hits |
| `cache_misses` | Counts read/write misses |
| `dirty_evictions` | Counts dirty cache-line evictions |

The counters are exposed through the cache hierarchy and made accessible to the PyMTL3 verification environment.

### 2. Directed Counter Verification

Developed dedicated tests for:

- Repeated reads and cache hits
- Read/write misses
- Dirty cache-line eviction
- Write-hit and write-miss behavior
- Write-initialize counter behavior

Created a shell script to run each directed test independently.

### 3. Randomized Cache Verification

Developed a deterministic randomized testbench that generates sequences of read and write requests.

The verification environment uses a Python golden reference memory model to track expected data and check cache responses.

Features include:

- 1,000 requests per simulation
- Configurable random seeds
- Randomized read/write operations
- Reference-model checking
- Hardware performance counter validation
- Simulation timeout detection

### 4. Cache Workload Benchmarking

Implemented two workload configurations:

**Baseline workload:** A smaller working set designed to demonstrate cache reuse and high hit rates.

**Conflict-heavy workload:** A larger working set designed to increase cache misses, replacements, and dirty evictions.

Both workloads can be executed across multiple random seeds using an automated shell script.

### 5. Multi-Seed Regression Testing

Created a regression script that executes eight independent randomized simulations:

- Two workloads
- Four random seeds per workload
- 1,000 requests per simulation
- 8,000 total verified requests

Each simulation runs in a separate Python process to avoid Verilator simulation-context conflicts.

## Benchmark Results

The following measurements were obtained using random seed 4750.

| Metric | Baseline | Conflict-heavy |
|---|---:|---:|
| Requests | 1,000 | 1,000 |
| Cache hits | 984 | 500 |
| Cache misses | 16 | 500 |
| Dirty evictions | 0 | 325 |
| Hit rate | 98.40% | 50.00% |
| Miss rate | 1.60% | 50.00% |
| Cycles per request | 4.05 | 6.48 |

All eight randomized regression tests passed, covering 8,000 cache requests.

## Running the Tests

The project uses the Cornell ECE 4750 simulation environment, including PyMTL3, pytest, and Verilator.

From the `sim` directory:

**Directed performance-counter tests**

```bash
bash run_counter_tests.sh
```

**Randomized regression suite**

```bash
bash run_random_tests.sh
```

**Individual randomized test**

```bash
CACHE_WORKLOAD=conflict CACHE_SEED=4750 \
python -m pytest -x -vv -s \
lab3_mem/test/CacheAltRandom_test.py::test_random_reads_writes
```

## Technologies

SystemVerilog, Verilog, Python, PyMTL3, Verilator, pytest, Bash, Git

## Contributors and Attribution

**Rumman Jan and Ariel Lai:** Original ECE 4750 Lab 3 cache implementation and course verification work.

**Rumman Jan:** Independent post-lab extensions, including hardware performance counters, directed counter tests, randomized reference-model verification, multi-seed regression testing, and workload performance benchmarking.

This repository builds upon coursework completed at Cornell University. The independent extensions were developed to deepen my understanding of cache microarchitecture, RTL verification, and performance analysis.
