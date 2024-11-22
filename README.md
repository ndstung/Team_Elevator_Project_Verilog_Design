# Elevator Control System Using Verilog on FPGA

This repository contains the design, implementation, and simulation of an elevator control system for a four-floor building. The project utilizes Verilog HDL and an FPGA platform to develop a robust and efficient controller capable of handling various elevator functionalities, including floor selection, door operations, and emergency protocols.

## Project Overview

This project aims to design a reliable elevator controller using a Mealy Finite State Machine (FSM) model for behavioral modeling. The system is built to:
- Support safe and efficient transportation between floors.
- Provide clear user feedback via a seven-segment display and auditory alerts.
- Handle emergency scenarios such as door jams and SOS signals.

### Key Features:
- **Finite State Machine Design**: Efficiently manages elevator states, including Idle, Door Open/Close, Slow/Fast Movement, and Emergency Handling.
- **Seven-Segment Display**: Displays floor number, door status, and movement direction.
- **Auditory Alerts**: Real-time voice prompts for state transitions and emergencies.
- **Emergency Features**: SOS button, flashing indicators, and door jam detection.

## Hardware and Software Tools

### Hardware
- **FPGA Board**: Xilinx XC7007S ZYNQ.
  - **Switches**: Input for floor requests.
  - **Buttons**: SOS and reset functions.
  - **Seven-Segment Display**: Displays the current floor, door status, and movement direction.
  - **LED Indicators**: Show active floor requests.
  - **Speaker Output**: Provides audio feedback.

### Software
- **Xilinx Vivado**: For design synthesis, implementation, and simulation.
- **Verilog HDL**: The hardware description language used for system design.

## System Architecture

The elevator control system is built on a Mealy FSM model, enabling dynamic state transitions based on user inputs and system conditions. The system includes the following modules:
1. **Elevator Control Module**: Manages core operations like movement and door handling.
2. **Seven-Segment Display Module**: Provides visual feedback.
3. **Narrator Module**: Generates auditory signals for system states.
4. **Memory Module**: Stores audio samples for announcements.

### Block Diagram
![Block Diagram](path/to/block-diagram.png)
*Figure 1: Block Diagram of the Elevator Control System*

## Simulation Results

The system has been thoroughly simulated to validate its functionality under various scenarios:
1. **Normal Operations**:
   - Responding to floor requests.
   - Handling door open/close operations.
2. **Emergency Handling**:
   - Door jams and SOS alerts.
   - Transitioning back to normal states after emergencies.

### Waveform Examples
#### Test Case 1: Normal Floor Request
![Waveform Test Case 1](path/to/waveform1.png)
*Figure 2: System response to a request for the third floor.*

#### Test Case 2: Emergency - Door Jam
![Waveform Test Case 2](path/to/waveform2.png)
*Figure 3: Elevator handling a door jam scenario.*

## Challenges and Solutions

### Challenges:
- Initial FSM design lacked sufficient states to cover all elevator operations.
- Synchronization issues between modules during integration.
- Resource optimization for FPGA implementation.

### Solutions:
- Expanded the FSM design to include more states.
- Modular approach to simplify integration and testing.
- Efficient signal mapping and pin assignments for resource optimization.

## Contribution

| Team Member      | Contribution                                  |
|-------------------|----------------------------------------------|
| **Hai Long**      | FSM design and control path implementation. |
| **Tung Nguyen**   | Signal definitions and mapping.             |
| **Hung Nguyen**   | Speaker output development.                 |
| **Duy Cu**        | Audio mapping and system integration.       |

## Future Work

- Expand the system to handle more floors.
- Implement energy-efficient algorithms for optimization.
- Add wireless control for remote operations.

## References

1. P. Dutta, B. Mondal, S. Mukherjee, and A. Goswami, "Design and Implementation of an Elevator Controller using FSM on FPGA," *International Journal of Computer Applications*, vol. 97, no. 10, pp. 1-5, Jul. 2014.
2. S. J. Raut and M. S. Bhide, "Design of Elevator Controller Using FPGA," *International Journal of Engineering Research & Technology (IJERT)*, vol. 2, no. 2, pp. 1-4, Feb. 2013.
3. F. Reale and M. Onofri, "Optimization of an elevator control system via reinforcement learning," in *Proc. IEEE 2020 15th International Workshop on Semantic and Social Media Adaptation and Personalization (SMAP)*, Zakynthos, Greece, 2020, pp. 1-6.

---

This README.md file provides an overview of the project, its architecture, simulation results, and contributions, making it suitable for sharing on GitHub.
