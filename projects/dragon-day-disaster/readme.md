# 🐉 Dragon Day Disaster — Motion-Controlled Game

**ECE 3140 / CS 3420 Final Project | Cornell University | Spring 2026**

**Team:** Ariel Lai and Rumman Jan

## Project Overview

Dragon Day Disaster is a two-player motion-controlled game developed using two FRDM-KL46Z microcontroller boards and a Python-based game interface.

Instead of using traditional keyboard controls, players interact with the game through physical movements detected by the onboard MMA8451Q accelerometers. The microcontrollers process motion data and transmit events over USB serial communication to a laptop running the game.

The project combines embedded programming, real-time scheduling, concurrent processes, sensor interfacing, and multithreaded Python programming.

## System Architecture

The system consists of three main components:

**1. Embedded Controllers — FRDM-KL46Z**

- Two ARM Cortex-M-based microcontroller boards serve as motion controllers.
- Onboard MMA8451Q accelerometers capture player movement through I2C.
- Firmware processes sensor measurements to identify motion events.
- Detected events are transmitted to the host computer through USB serial communication.

**2. Serial Communication**

- Each microcontroller communicates with the laptop through a serial interface.
- Serial communication operates at 115200 baud.
- Motion events are encoded as short messages, such as `J\n` for jumping.
- The host application interprets incoming messages as player actions.

**3. Python Game Application**

- A Python application handles gameplay and visual rendering.
- Multithreaded serial interfaces process incoming events from the two controllers.
- Physical movement is translated into real-time game actions.

## Embedded Systems Implementation

### Accelerometer Interface

The FRDM-KL46Z communicates with its onboard MMA8451Q accelerometer over I2C.

- Initialized the accelerometer and configured sensor communication.
- Read raw X, Y, and Z acceleration measurements.
- Calibrated movement thresholds using recorded sensor data.
- Implemented threshold-based motion detection with cooldown logic to reduce repeated triggers.

For the initial jump detection implementation, a Y-axis measurement below approximately `-2500` was used to identify a jump.

### Real-Time Scheduling and Concurrency

The embedded software incorporates real-time scheduling and concurrent processes for managing sensor sampling, motion detection, and communication.

This separates time-sensitive sensor processing from other firmware operations and supports responsive interaction between the hardware and game application.

### Serial Communication

The controllers communicate with the Python host through USB serial connections.

| Message | Action |
|---|---|
| `J\n` | Jump event |
| `D\n` | Duck event (included in the development protocol) |

The host receives and interprets controller messages to update game state.

## Python Game Development

The host-side application provides the game interface and handles incoming hardware events.

- Developed Python serial communication interfaces for microcontroller input.
- Integrated motion-based controls into the game.
- Used multithreading to process events from two independent controllers.
- Managed player inputs and gameplay updates through the host application.

## Technologies Used

| Category | Technologies |
|---|---|
| Microcontrollers | FRDM-KL46Z, ARM Cortex-M |
| Sensors | MMA8451Q Accelerometer |
| Embedded Programming | C, ARM Assembly |
| Communication | I2C, UART, USB Serial |
| Real-Time Systems | Scheduling, Concurrent Processes |
| Game Development | Python, pygame |
| Development Tools | MCUXpresso IDE, Git/GitHub |

## Team Contributions

**Ariel Lai — Embedded Controller Development**

- Microcontroller setup and firmware development.
- Accelerometer initialization and I2C interfacing.
- Motion detection and sensor calibration.
- Embedded serial communication and hardware testing.

**Rumman Jan — Python Game and Host Integration**

- Python game application development.
- Serial communication between the laptop and embedded controllers.
- Integration of hardware motion events with game controls.
- Host-side multithreading and event processing.

Both team members contributed to system integration, debugging, and testing.

## Running the Project

### Embedded Controller

1. Open the embedded firmware project in MCUXpresso IDE.
2. Configure and build the project for the FRDM-KL46Z.
3. Flash the firmware to the microcontroller boards.
4. Connect the boards to the laptop through USB.

### Python Application

Install the required Python dependencies:

```bash
python3 -m pip install pygame pyserial
```

Run the game:

```bash
python3 game.py
```

The correct serial ports must be configured for the connected microcontroller boards.

## Repository Structure

```text
dragon-day-disaster/
├── FinalProject/          # MCUXpresso embedded firmware
├── Assets/                # Game assets
├── game.py                # Python game application
├── python_serial.py       # Serial communication utilities
├── read_serial.py         # Serial testing
├── 3140_accel.c           # Accelerometer driver
├── 3140_accel.h
├── 3140_i2c.c             # I2C communication
├── 3140_i2c.h
├── 3140_serial.c          # Serial interface
├── 3140_serial.h
└── readme.md
```

## Key Concepts

- Embedded C programming on ARM Cortex-M microcontrollers
- I2C-based accelerometer interfacing
- Real-time scheduling and concurrency
- Serial communication between embedded hardware and Python
- Multithreaded host-side event processing
- Hardware/software integration for interactive applications

---

**Cornell University — ECE 3140 / CS 3420, Spring 2026**

Developed by Ariel Lai and Rumman Jan.
