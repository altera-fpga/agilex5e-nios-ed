# Nios® V/m DMA OCM Design

 This design demonstrates the transaction between the Nios® V processor with DMA and OCM core for the AgilexTM 5 FPGA E-Series 065B Premium Development Kit (ES1) DK-A5E065BB32AES1. 

## Description

 This example design includes a Nios® V/m processor connected to the On Chip RAM-II, JTAG UART IP, Parallel-IO and System ID peripheral core. The objective of the design is to accomplish data transfer between the processor and soft IP peripherals.

![image](https://github.com/altera-fpga/agilex5e-nios-ed/blob/rel/25.1.1/niosv_m/niosv_m_dma_ocm/img/dma_ocm.png)

## Project Details

- **Title**: Nios® V/m DMA OCM Design
- **Source**: Github
- **Design Support**: SCTH
- **Family**: Agilex 5
- **Quartus Version**: 25.1.1
- **Development Kit**: Agilex 5 FPGA E-Series 065B Premium Development Kit DK-A5E065BB32AES1
- **Device Part**: A5ED065BB32AE6SR0
- **Design Package**: agilex5_niosv_m_dma_ocm.zip
- **Category**: Memory
- **URL**: https://github.com/altera-fpga/agilex5e-nios-ed/tree/rel/25.1.1/niosv_m/niosv_m_dma_ocm
- **download URL**: https://github.com/altera-fpga/agilex5e-nios-ed/releases/download/25.1.1-v1.0/agilex5_niosv_m_dma_ocm.zip

## Documentation

- **Title**: Design Document
- **URL**:https://github.com/altera-fpga/agilex5e-nios-ed/tree/rel/25.1.1/niosv_m/niosv_m_dma_ocm/docs/NiosV_m_Processor_DMA_OCM_Design_on_Agilex_5_FPGA.md

### Prerequisites

 - Agilex™ 5 FPGA E-Series 065B Premium Development Kit, ordering code DK- A5E065BB32AES1. Refer to the board documentation for more information about the development kit.
 - Mini and Micro USB Cable. Included with the development kit.
 - Host PC with 64 GB of RAM. Less will be fine for only exercising the binaries, and not rebuilding the GHRD.
 
### Release Contents  

#### Binaries
 - Prebuilt binaries are located [here](https://github.com/altera-fpga/agilex5e-nios-ed/tree/rel/24.3.1/niosv_m/niosv_m_dma_ocm/ready_to_test).
 - The sof and elf files required to run the design can be found in "ready_to_test" folder 
 - Program the sof and download the elf file on board

#### Nios® V/m Processor
- Microcontroller- Balanced (For interrupt driven baremetal and RTOS code)
- Nios® V/m processor is highly customizable and can be tailored to meet specific application requirements, providing flexibility and scalability in embedded system designs.
 
#### IP Cores
 The following IPs are used in this Platform Designer component of the design:
- Nios® V/m soft processor core

- On Chip RAM-II

- JTAG UART

- MSGDMA

- System ID

- Clock Bridge, Reset Controller


### Hardware Setup

Refer to [Agilex™ 5 FPGA Premium Development Kit User Guide](https://www.intel.com/content/www/us/en/docs/programmable/814550.html) to setup the hardware connection.


### Address Map Details

#### Nios V Address Map
 |Address Offset	|Size (Bytes)	|Peripheral	| Description|
  |-|-|-|-|
  |0x0000_0000|1MB|On-Chip RAM|To store application|
  |0x0011_0068|8|JTAG UART|Communication between a host PC and the Nios V processor system|
  |0x0011_0000|16|On-Chip Memory 1|Memory Read/Write Operations|
  |0x0012_0000|16|On-Chip Memory 2|Memory Read/Write Operations|
  |0x0012_8040|16|MSGDMA|Memory Read/Write Operations|  
  |0x0012_8070|8|System ID|Hardware configuration system ID (0x000000A5)|
  ||||


### User Flow 

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
 ||Run simulation|Yes|Yes|

### Environment Setup

#### Tools Download and Installation
1. Quartus Prime Pro

 - Download the Quartus® Prime Pro Edition software version 25.1 from the FPGA Software Download Center webpage of the Intel website. Follow the on-screen instructions to complete the installation process. Choose an installation directory that is relative to the Quartus® Prime Pro Edition software installation directory.
 - Set up the Quartus tools in the PATH, so they are accessible without full path.
```console
	export QUARTUS_ROOTDIR=~/intelFPGA_pro/25.1.1/quartus/
	export PATH=$QUARTUS_ROOTDIR/bin:$QUARTUS_ROOTDIR/linux64:$QUARTUS_ROOTDIR/../qsys/bin:$PATH
```


### Getting Started

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
elf2hex sw/app/build/app.elf -b 0x0 -w 32 -e 0x9ffff sw/app/build/onchip_mem.hex -r4
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