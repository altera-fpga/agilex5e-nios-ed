# Nios® V/m Baseline Golden Hardware Reference Design (GHRD)

 This design demonstrates the baseline Golden Hardware Reference Design (GHRD) for a Nios® V/m processor with basic bare minimum peripherals required for any application execution for the Agilex™ 5 FPGA E-Series 065B Premium Development Kit.

## Description

 This example design includes a Nios® V/m processor connected to the On Chip RAM-II, JTAG UART IP, Parallel-IO and System ID peripheral core. The objective of the design is to accomplish data transfer between the processor and soft IP peripherals.

![image](https://github.com/altera-fpga/agilex5e-nios-ed/blob/rel/25.1.0/niosv_m/niosv_m_baseline_ghrd/img/baseling_ghrd_block_design.png)

## Project Details

- **Title**: Nios® V/m Baseline Golden Hardware Reference Design (GHRD)
- **Source**: Github
- **Design Support**: SCTH
- **Family**: Agilex 5
- **Quartus Version**: 25.1.0
- **Development Kit**: Agilex 5 FPGA E-Series 065B Premium Development Kit DK-A5E065BB32AES1
- **Device Part**: A5ED065BB32AE6SR0
- **Design Package**: agilex5_niosv_m_baseline_ghrd.zip
- **Category**: GHRD
- **URL**: https://github.com/altera-fpga/agilex5e-nios-ed/tree/rel/25.1.0/niosv_m/niosv_m_baseline_ghrd
- **download URL**: https://github.com/altera-fpga/agilex5e-nios-ed/releases/download/25.1.0-v1.0/agilex5_niosv_m_baseline_ghrd.zip

## Documentation

- **Title**: Design Document
- **URL**: https://github.com/altera-fpga/agilex5e-nios-ed/blob/rel/25.1.0/niosv_m/niosv_m_baseline_ghrd/docs/NiosV_m_Processor_baseline_ghrd_on_Agilex_5_FPGA.md


# Getting Started

Vendor: Altera
 
1. Directory structure
2. Using existing files (sof and elf) to run on hardware
3. Building the design from scratch

    a.	Required directory structure

    b.	Use of build_sof.py to compile the design

    c.	Steps to create the bsp and build software sources

    d.  Hardware Validation 
    
4. Running simulation

### 1. Directory Structure:

The directory structure is explained below:

- hw- necessary hardware files (.qpf, .qsf, .sv, .v, .ip) of the design

- sw- This folder contains software application files

- scripts- This folder consists of scripts to build the design


### 2. Using existing files to run the design on hardware

- The sof and elf files required to run the design can be found in "ready_to_test" folder 

- Refer the Hardware validation section (3.d) for the steps  


### 3. Building the design from scratch

The steps to build the project from scratch are mentioned below:

a. Required directory structure
- The top-level project folder should have directory structure as mentioned in Section 1 (Directory Structure).

b. Using build_sof.py to compile the design
- Invoke the quartus_py shell in the terminal

- Run the following command in the terminal from top level project directory:
```
quartus_py ./scripts/build_sof.py
```
- The quartus tool will compile the design and generate the output files

c. Creating the bsp, build software sources and download elf
- To create software app, run the following commands in the terminal:

- Clean the app build project before regenerating elf

```     
niosv-bsp -c --quartus-project=hw/top.qpf --qsys=hw/qsys_top.qsys --type=hal sw/bsp/settings.bsp
niosv-app --bsp-dir=sw/bsp --app-dir=sw/app --srcs=sw/app/main.c
niosv-shell
cmake -S ./sw/app -B sw/app/build -G "Unix Makefiles"
make -C sw/app/build
elf2hex sw/app/build/app.elf -b 0x0 -w 32 -e 0xfffff sw/app/build/onchip_mem.hex -r4
```
Note:The software can be compiled using the Ashling Visual Studio Code Extension for Altera FPGAs
For information on the build process, please refer to the following document- [https://www.intel.com/content/www/us/en/docs/programmable/730783/25-1/ashling-visual-studio-code-extension.html](https://www.intel.com/content/www/us/en/docs/programmable/730783/25-1/ashling-visual-studio-code-extension.html)

d. Hardware Validation
- Program the generated sof and then download the elf file on the board
```        
quartus_pgm --cable=1 -m jtag -o 'p;ready_to_test/top.sof'
``` 
- Reduce the JTAG clock frequency to 6MHz before programming the application .elf file on the board.
```
jtagconfig --setparam 1 JtagClock 6M
```
- Download the elf file on the board 
```    
niosv-download -g ready_to_test/app.elf -c 1
``` 
- Verify the output on the terminal by using the following command in the terminal:
``` 
juart-terminal -d 1 -c 1 -i 0 
```

### 4. Running simulation

Simulation is enabled for this design where the memory is initialized with the application hex. Use the following commands to run the simulation:

- Generate Testbench from Platform Designer. Generate -> Generate Testbench System 
```	
cp ./sw/app/build/onchip_mem.hex ./qsys_top_tb/qsys_top_tb/sim/mentor 
cd hw/qsys_top_tb/qsys_top_tb/sim/mentor/
vsim &
source msim_setup.tcl
ld_debug
run -all
```
