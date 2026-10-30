# Chrome Dinosaur Game
ECE 3140 / CS 3420 Final Project
Team: Ariel, Rumman

---

## Project Overview
The FRDM-KL46Z board is strapped to the player's body and detects physical jumps
via the onboard MMA8451Q accelerometer over I2C. When a jump is detected, the board
sends "J\n" over USB serial at 115200 baud to a Python pygame script running on the
laptop, which controls the game.

---

## Week 1 Progress

### Board Side (Ariel)
- MCUXpresso project set up with all required lab files
- Accelerometer initialized over I2C
- Raw X/Y/Z values streamed over serial to laptop
- Jump detection working — Y axis spike below -2500 triggers "J\n"
- Calibration tool built to find and tune thresholds
- Serial communication verified end to end at 115200 baud

### Laptop Side (Rumman) 
- Python serial reading script set up and receiving board data
- pygame window in progress

---

## File Descriptions

### Code
| File | Description |
|------|-------------|
| `calibrate.c` | Streams raw X/Y/Z accelerometer data over serial. Use this to tune jump thresholds. Flash this, run python_serial.py, jump around, observe Y axis spikes. |
| `python_serial.py` | Python script that reads serial data from the board. Prints raw accelerometer values and prints "JUMP DETECTED" when it receives "J\n". Run this on the laptop while the board is flashed. |

### Lab-Provided Files 
| File | Description |
|------|-------------|
| `3140_accel.c / .h` | Accelerometer driver for MMA8451Q. Provides `ACCEL_getDefaultConfig()` and `ACCEL_getAccelDat()`. |
| `3140_i2c.c / .h` | I2C driver. Provides `I2C_Init()` for communication with the accelerometer. |
| `3140_concur.c / .h` | Concurrency library. Provides process creation, scheduling, and context switching. Will be used in Week 2. |
| `3140_serial.c / .h` | Original serial library from labs. Not currently used — replaced by direct UART0 access via `BOARD_InitDebugConsole()` from the SDK. |
| `led.c / .h` | LED control functions. Currently disabled — `led_init()` conflicts with `BOARD_InitBootPins()`. Will need to be resolved. |
| `led_lowlevel.s` | Low-level assembly for LED control. Required by `led.c`. |
| `process.c / .h` | Process management for concurrency. Will be used in Week 2. |
| `realtime.h` | Real-time scheduling header. Will be used in Week 2 for PIT timer-based sampling. |
| `3140.s` | Low-level assembly startup code. |
| `mtb.c` | Micro Trace Buffer — debug utility, auto-included by MCUXpresso. |
| `semihost_hardfault.c` | Handles hard faults in semihosting mode. Auto-included by MCUXpresso. |
| `Lab5.c` | Reference code from Lab 5 (excluded from build). Contains PIT timer and concurrency examples useful for Week 2. |
| `process_ref.c` | Reference process implementation (excluded from build). |
| `serialmonitorprint.c` | Earlier serial test file (excluded from build). |

---

## Serial Protocol
| Message | Direction | Meaning |
|---------|-----------|---------|
| `J\n` | Board → Laptop | Jump detected |
| `D\n` | Board → Laptop | Duck detected (planned Week 3) |

---

## Jump Detection
- Board worn on body, Y axis is vertical
- At rest: Y ≈ -1900
- On jump: Y spikes below -2500
- Cooldown of 15 polls after each jump to prevent double triggers

---

## How to Run
1. Open project in MCUXpresso (must use **Default Board Files**)
2. Build and flash using GUI Flash Tool (not debugger)
3. Run `python3 python_serial.py` on laptop
4. Strap board to body and jump

---

## Known Issues
- `led_init()` conflicts with `BOARD_InitBootPins()` — LEDs currently disabled
- `3140_serial.c` uart_init uses wrong pins for this project — replaced by SDK init

---

## Week 2 Plan
- Add RT scheduling via PIT timer for precise 100Hz accelerometer sampling
- Add concurrency — three processes: sample, detect, transmit
- Add locks to protect shared accelerometer buffer
- Connect "J\n" serial event to dino jump in pygame
