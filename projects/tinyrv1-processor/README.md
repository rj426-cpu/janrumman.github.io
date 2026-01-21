# TinyRV1 RISC-V Processor

A custom RISC-V-inspired single-cycle processor implementation with specialized hardware acceleration, designed and verified in Verilog for embedded door security systems.

## 🎯 Project Overview

TinyRV1 is a complete processor design project that explores both general-purpose and application-specific computing architectures. The project demonstrates the performance trade-offs between flexible general-purpose processors and optimized specialized accelerators.

### Key Features
- **Custom ISA:** RISC-V-inspired instruction set architecture
- **Dual Implementations:** Both general-purpose and specialized accelerator versions
- **Complete System:** Full memory interfacing and I/O capabilities
- **Verified Design:** Comprehensive testbench coverage and waveform analysis

## 🏗️ Architecture Details

### General-Purpose Processor
The base implementation features:
- **32-bit single-cycle datapath** with complete ISA support
- **Modular design** using hierarchical Verilog components
- **Core components:** 32-bit adders, comparators, registers, and counters
- **Memory interface:** Full address and data bus implementation
- **Control logic:** Instruction decode and execution control

### Specialized Accumulator Accelerator
Optimized for the door security application:
- **FSM-based control:** Finite state machine driven datapath
- **Streamlined operations:** Focused on accumulation and comparison patterns
- **Performance:** 3-5x faster than general-purpose implementation
- **Area efficiency:** Reduced logic compared to full processor

## 📊 Performance Analysis

Performance comparison conducted using Intel Quartus synthesis:

| Metric | General Processor | Accelerator | Improvement |
|--------|------------------|-------------|-------------|
| Execution Speed | Baseline | 3-5x faster | 300-500% |
| Critical Path | Analyzed | Optimized | Reduced |
| Area Utilization | Full datapath | Minimal | Smaller |

## 🔧 Implementation Stack

**Design & Verification:**
- Verilog HDL for all hardware modules
- Structural and behavioral modeling
- Hierarchical design methodology

**Tools:**
- Intel Quartus Prime (synthesis and place-and-route)
- Surfer on VSCode (waveform analysis)
- Custom testbenches for verification

**Target Platform:**
- FPGA deployment ready
- Door security embedded system application

## 🚀 Building and Testing

### Prerequisites
- Linux environment
- Intel Quartus Prime
- Verilog simulator (ModelSim or compatible)
- Make build system

### Build Instructions

```bash
# Configure the build environment
./configure

# Compile the design
make

# Run verification tests
make check

# View synthesis results
make synth
```

### Testing
The project includes extensive verification:
- Unit tests for individual components
- Integration tests for complete processor
- Performance benchmarks comparing implementations
- Waveform analysis for debugging

## 💡 Key Concepts Demonstrated

1. **Computer Architecture:** Single-cycle processor design principles
2. **Hardware Optimization:** Trade-offs between generality and performance
3. **Digital Design:** FSM design, datapath optimization, control logic
4. **Verification:** Testbench development and waveform debugging
5. **FPGA Development:** Synthesis, timing analysis, area optimization

## 📚 Technical Skills Applied

- **HDL Design:** Verilog (structural and behavioral)
- **Computer Organization:** ISA design, datapath architecture
- **FPGA Tools:** Quartus synthesis and analysis
- **Debugging:** Waveform analysis and sequential logic verification
- **Performance Analysis:** Critical path and area utilization optimization

## 🎓 Project Context

Developed for ECE 2300: Digital Logic and Computer Organization at Cornell University (Fall 2025). This project was completed in collaboration with a lab partner and represents the culmination of learning in digital design, progressing from basic logic gates through complete processor implementation.
