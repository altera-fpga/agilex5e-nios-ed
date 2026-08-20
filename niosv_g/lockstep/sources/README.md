# Agilex 5 FPGA - Lockstep Example Design Example on Nios® V/g Processor 

Nios® V/g Processor-based Lockstep example design on the Agilex® 5 FPGA.

## Description

This design demonstrates the working of NiosV/g lockstep feature through the standard fail safe control mechanism using by injecting root faults and reading alarms with Nios® V/m as the system supervisor on Agilex™ 5 FPGA E-Series 065B Premium Development Kit (ES1) DK-A5E065BB32AES1.

![image](https://github.com/altera-fpga/agilex5-ed-niosv/blob/rel/26.1.1/niosv_g/lockstep/img/block_diagram.png)

## Project Details

- **Title**: Agilex 5 FPGA - Lockstep Example Design Example on Nios® V/g Processor
- **Source**: Github
- **Design Support**: CTH
- **Family**: Agilex 5
- **Quartus Version**: 26.1.1
- **Development Kit**: Agilex 5 FPGA E-Series 065B Premium Development Kit DK-A5E065BB32AES1
- **Device Part**: A5ED065BB32AE6SR0
- **Design Package**: agilex5_niosv_g_lockstep.zip
- **Category**: Nios V
- **URL**: https://github.com/altera-fpga/agilex5-ed-niosv/blob/rel/26.1.1/niosv_g/lockstep/
- **downloadURL**: https://github.com/altera-fpga/agilex5-ed-niosv/releases/download/26.1.1/agilex5_niosv_g_lockstep.zip

## Documentations

- **Title**: Design Document
**URL**: https://github.com/altera-fpga/agilex5-ed-niosv/blob/rel/26.1.1/niosv_g/lockstep/docs/Nios_Vg_Processor_Lockstep_Design_on_Agilex_5_FPGA.md

### Prerequisites

 -  Agilex® 7 FPGA F-Series Development Kit, ordering code DK-DEV-AGF014EA. Refer to the board documentation for more information about the development kit.
 - Mini and Micro USB Cable. Included with the development kit.
 
### Release Contents  

#### Binaries
 - Prebuilt binaries are located [here](https://github.com/altera-fpga/agilex5-ed-niosv/blob/rel/26.1.1/niosv_g/lockstep/ready_to_test).
 - The sof and elf files required to run the design can be found in "ready_to_test" folder 
 - Program the sof and download the elf file on board

#### Nios® V/g Processor
- General-Purpose Processor- High Performance (For interrupt driven baremetal and RTOS code)
- Nios® V/g processor is highly customizable and can be tailored to meet specific application requirements, providing flexibility and scalability in embedded system designs.
 
#### IP Cores
 The following IPs are used in this Platform Designer component of the design:
- Nios® V/g soft processor core

- Nios® V/m soft processor core

- On Chip RAM-II

- PIO 0

- PIO 1

- JTAG UART

- System ID

- Clock Bridge, Reset Controller

### Hardware Setup

  Refer to [Agilex 5 FPGA E-Series 065B Premium Development Kit User Guide](https://docs.altera.com/r/docs/814550/current/agilex-5-fpga-e-series-065b-premium-development-kit-user-guide/overview) to setup the hardware connection.


### Address Map Details

#### Nios V Address Map
 |Address Offset	|Size (Bytes)	|Peripheral	| Description|
  |-|-|-|-|
  |0x0|12M|On-Chip RAM|To store application|
  |0x0101_0048|8|JTAG UART|Communication between a host PC and the Nios V processor system|
  |0x0101_0040|8|System ID|Hardware configuration system ID (0x00000009)|


## User Flow 

 There are two ways to test the design based on use case. 

   <h5> User Flow 1: Testing with Prebuild Binaries.</h5>
   
   <h5> User Flow 2: Testing Complete Flow.</h5>

 |User Flow|Description|Required for [User flow 1](#user-flow-1-testing-with-prebuild-binaries)|Required for [User flow 2](#user-flow-2-testing-complete-flow)|
 |-|-|-|-|
 |Environment Setup|[Tools Download and Installation](#tools-download)|Yes|Yes|
 |Compilation|Hardware compilation|No|Yes|
 ||Software compilation|No|Yes|    
 |Programing|Program Hardware Binary SOF|Yes|Yes|
 ||Program Software Image ELF|Yes|Yes|
 |Testing|Open JTAG UART Terminal|Yes|Yes|

### Environment Setup

#### Tools Download and Installation
1. Quartus Prime Pro

 - Download the Quartus® Prime Pro Edition software version 26.1.1 from the FPGA Software Download Center webpage of the Intel website. Follow the on-screen instructions to complete the installation process. Choose an installation directory that is relative to the Quartus® Prime Pro Edition software installation directory.
 - Set up the Quartus tools in the PATH, so they are accessible without full path.
```console
export QUARTUS_ROOTDIR=~/intelFPGA_pro/26.1.1/quartus/
export PATH=$QUARTUS_ROOTDIR/bin:$QUARTUS_ROOTDIR/linux64:$QUARTUS_ROOTDIR/../qsys/bin:$PATH
```
# Getting Started

Vendor: Altera

1. Directory structure
2. Using existing files (sof and elf) to run on hardware
3. Building the design from scratch
    
    a. Required directory structure

    b. Use of build_sof.py to compile the design
    
    c. Steps to create the bsp and build software sources

    d.  Hardware Validation 
 
### 1. Directory Structure:
 
The directory structure of this top-level project folder is explained below:

- hw - necessary hardware files (.qpf, .qsf, .sv, .v, .ip) of the design

- sw - This folder contains software application files

- scripts - This folder consists of scripts to build the design

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
- To create software app, run the following commands in the terminal
- Clean the app build project before regenerating elf
- Niosv/m application
```console
niosv-bsp -c --quartus-project=hw/top.qpf --qsys=hw/qsys_top.qsys --type=hal sw/bsp_lockstep/settings.bsp -i=intel_niosv_m_0
niosv-app --bsp-dir=sw/bsp_lockstep --app-dir=sw/app_lockstep --srcs=sw/app_lockstep/lockstep.c
cmake -S ./sw/app_lockstep -B sw/app_lockstep/build
make -C sw/app_lockstep/build
```

- Niosv/g application
```console
niosv-bsp -c --quartus-project=hw/top.qpf --qsys=hw/qsys_top.qsys --type=hal sw/bsp_lockstep_hello/settings.bsp -i=intel_niosv_g_0
niosv-app --bsp-dir=sw/bsp_lockstep_hello --app-dir=sw/app_lockstep_hello --srcs=sw/app_lockstep_hello/hello.c
cmake -S ./sw/app_lockstep_hello -B sw/app_lockstep_hello/build
make -C sw/app_lockstep_hello/build
```

d. Hardware Validation
- Program the generated sof and then download the elf file on the board
```  
quartus_pgm --cable=1 -m jtag -o 'p;ready_to_test/top.sof'
```
- Reduce the JTAG clock frequency to 6MHz before programming the application .elf file on the board.
``` 
jtagconfig --setparam 1 JtagClock 6M
```
- Download the elf file on the board (First download the Niosv/m app and then the Niosv/g app)
```
niosv-download -g sw/app_lockstep/build/app_lockstep.elf
```
```
niosv-download -g sw/app_lockstep_hello/build/app_lockstep_hello.elf -c 1 -i 0
```
- Verify the output on the terminal by using the following command in the terminal:
``` 
juart-terminal -d 1 -c 1 -i 1
```
``` 
juart-terminal -d 1 -c 1 -i 0
```
