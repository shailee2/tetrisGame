# Tetris Game on FPGA
A hardware-accelerated implementation of the classic Tetris game, developed using SystemVerilog and C. This project demonstrates real-time game logic, VGA display output, and responsive user input handling on FPGA hardware.

## Overview
This Tetris game is designed to run on FPGA boards, utilizing finite state machines (FSMs) for game logic, memory-mapped I/O for hardware interaction, and VGA for video output. The project emphasizes modular design and efficient hardware-software integration.

## Features
- Real-Time Game Logic: Implemented using FSMs to manage game states and transitions.
- VGA Display Output: Generates video signals to render the game on a monitor.
- User Input Handling: Processes inputs with debouncing to ensure accurate and responsive controls.
- Modular Design: Structured codebase for scalability and ease of maintenance.
- Hardware Integration: Direct interaction with hardware components through memory-mapped I/O.

## Technical Details
### Languages Used: SystemVerilog (96.5%), Verilog (3.5%)
#### Key Modules:
- block.sv: Defines the shapes and behaviors of Tetris blocks.
- vga_controller: Manages VGA signal generation for display output.
- mb_block.v: Handles memory blocks for game state storage.
- hex_driver.sv: Controls hexadecimal display outputs.
- mb_usb_hdmi_top.sv: Top-level module integrating USB and HDMI interfaces.

## Getting Started
#### Prerequisites:
- FPGA development board compatible with SystemVerilog. <br>
- Development tools such as Intel Quartus or Xilinx Vivado.

#### Setup:
- Clone the repository: git clone https://github.com/shailee2/tetrisGame.git <br>
- Open the project in your FPGA development environment. <br>
- Compile and synthesize the design. <br>
- Program the FPGA board with the generated bitstream.

#### Controls:
- Use the designated input buttons or switches on your FPGA board to control the Tetris blocks (move left/right, rotate, drop).

## About the Developer
#### Shailee Patel 
Undergraduate Student, B.S. in Computer Engineering, Minor in Statistics <br>
University of Illinois Urbana-Champaign (2023 - 2027) <br>
#### Contact: 
Email: shaileepatel05@gmail.com <br>
LinkedIn: linkedin.com/in/shailee-patel-04481b285 <br>
GitHub: github.com/shailee2
