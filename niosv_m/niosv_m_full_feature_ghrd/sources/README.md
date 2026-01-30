# Nios® V/m Full Feature Golden Hardware Reference Design (GHRD) Overview

 This design demonstrates the Full Feature Golden Hardware Reference Design (GHRD) that showcases the connectivity to multiple peripherals with Nios® V/m processor as the core on Agilex™ 5 FPGA E-Series 065B Premium Development Kit.

## Description
This example design includes a Nios® V/m processor connected to various on-board peripherals.
The objective of the design is to accomplish data transfer between the processor and soft IP peripherals. Each peripheral has a dedicated application which demonstrates it's basic use.
 
 ![Block Diagram](https://github.com/altera-fpga/agilex5e-nios-ed/blob/rel/25.3.1/niosv_m/niosv_m_full_feature_ghrd/img/full_feature_ghrd_block_design.png)

## Project Details

- **Title**: Nios® V/m Full Feature Golden Hardware Reference Design (GHRD)
- **Source**: Github
- **Design Support**: CTH
- **Family**: Agilex 5
- **Quartus Version**: 25.3.1
- **Development Kit**: Agilex 5 FPGA E-Series 065B Premium Development Kit DK-A5E065BB32AES1
- **Device Part**: A5ED065BB32AE6SR0
- **Design Package**: agilex5_niosv_m_full_feature_ghrd.zip
- **Category**: GHRD
- **URL**: https://github.com/altera-fpga/agilex5e-nios-ed/blob/rel/25.3.1/niosv_m/niosv_m_full_feature_ghrd
- **download URL**: https://github.com/altera-fpga/agilex5e-nios-ed/releases/download/25.1.1-v1.0/agilex5_niosv_m_full_feature_ghrd.zip

## Documentation

- **Title**: Design Document
**URL**: https://github.com/altera-fpga/agilex5e-nios-ed/blob/rel/25.3.1/niosv_m/niosv_m_full_feature_ghrd/docs/NiosV_m_Processor_full_feature_ghrd_on_Agilex_5_FPGA.md

# Getting Started

Vendor: Altera
 
1. Directory structure
2. Using existing files (sof and elf) to run on hardware
3. Building the design from scratch

    a.	Required directory structure

    b.	Use of build_sof.py to compile the design

    c.	Steps to create the bsp and build software sources

    d.  Hardware Validation 

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
cp custom_logic/emif_axi_adaptor_hw.tcl ./hw
cp custom_logic/emif_axi_handler.sv ./hw 
quartus_py ./scripts/build_sof.py
```
- The quartus tool will compile the design and generate the output files

c. Creating the bsp, build software sources and download elf
- To create software app, run the following commands in the terminal:

- Clean the app build project before regenerating elf

```     
niosv-bsp -c --quartus-project=hw/top.qpf --qsys=hw/qsys_top.qsys --type=hal sw/bsp/settings.bsp

- qspi_app
niosv-app --bsp-dir=sw/bsp --app-dir=sw/app_qspi --srcs=sw/app_qspi/main.c
cmake -S ./sw/app_qspi -B sw/app_qspi/build
make -C sw/app_qspi/build

- spi_app
niosv-app --bsp-dir=sw/bsp --app-dir=sw/app_spi --srcs=sw/app_spi/
cmake -S ./sw/app_spi -B sw/app_spi/build
make -C sw/app_spi/build
 
- i2c_app
niosv-app --bsp-dir=sw/bsp --app-dir=sw/app_i2c --srcs=sw/app_i2c/i2c.c
cmake -S ./sw/app_i2c -B sw/app_i2c/build
make -C sw/app_i2c/build
 
- dma_ocm_app
niosv-app --bsp-dir=sw/bsp --app-dir=sw/app_dma_ocm --srcs=sw/app_dma_ocm/main.c
cmake -S ./sw/app_dma_ocm -B sw/app_dma_ocm/build
make -C sw/app_dma_ocm/build
 
- emif_app
niosv-app --bsp-dir=sw/bsp --app-dir=sw/app_emif --srcs=sw/app_emif/main.c
cmake -S ./sw/app_emif -B sw/app_emif/build
make -C sw/app_emif/build
 
 
- isr_app
niosv-app --bsp-dir=sw/bsp --app-dir=sw/app_timer --srcs=sw/app_timer/main.c
cmake -S ./sw/app_timer -B sw/app_timer/build
make -C sw/app_timer/build
 
- pio_app
niosv-app --bsp-dir=sw/bsp --app-dir=sw/app_pio --srcs=sw/app_pio/main.c
cmake -S ./sw/app_pio -B sw/app_pio/build
make -C sw/app_pio/build
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
niosv-download -g ready_to_test/app_<peripheral>.elf -c 1
``` 
- Verify the output on the terminal by using the following command in the terminal:
``` 
juart-terminal -d 1 -c 1 -i 0 
```