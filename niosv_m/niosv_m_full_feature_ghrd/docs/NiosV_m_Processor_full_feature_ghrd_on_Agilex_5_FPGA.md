## Introduction

### Nios® V/m Full Feature Golden Hardware Reference Design (GHRD) Overview

 This design demonstrates the Full Feature Golden Hardware Reference Design (GHRD) that showcases the connectivity to multiple peripherals with Nios® V/m processor as the core on Agilex™ 5 FPGA E-Series 065B Premium Development Kit.

### Prerequisites

 - Agilex™ 5 FPGA E-Series 065B Premium Development Kit, ordering code DK- A5E065BB32AES1. Refer to the board documentation for more information about the development kit.
 - Mini and Micro USB Cable. Included with the development kit.
 - Host PC with 64 GB of RAM. Less will be fine for only exercising the binaries, and not rebuilding the GHRD.

### Release Contents  

#### Binaries
 - Prebuilt binaries are located [here](https://github.com/altera-fpga/agilex5e-nios-ed/blob/rel/25.3/niosv_m/niosv_m_full_feature_ghrd/ready_to_test).
 - The sof and elf files required to run the design can be found in "ready_to_test" folder 
 - Program the sof and download the elf file on board

### Nios® V/m Full Feature Golden Hardware Reference Design (GHRD) Architecture
This example design includes a Nios® V/m processor connected to various on-board peripherals.
The objective of the design is to accomplish data transfer between the processor and soft IP peripherals. Each peripheral has a dedicated application which demonstrates it's basic use.
 
 ![Block Diagram](https://github.com/altera-fpga/agilex5e-nios-ed/blob/rel/25.3/niosv_m/niosv_m_full_feature_ghrd/img/full_feature_ghrd_block_design.png)

#### Nios® V/m Processor
- Microcontroller- Balanced (For interrupt driven baremetal and RTOS code)
- Nios® V/m processor is highly customizable and can be tailored to meet specific application requirements, providing flexibility and scalability in embedded system designs.

#### IP Cores
 The following IPs are used in this Platform Designer component of the design:
- Nios® V/m soft processor core

- DDR 

- MSGDMA 
 
- On-Chip RAM-II
 
- QSPI 
 
- I2C 
 
- UART 
 
- SPI 
 
- System ID 
 
- PIO LED 
 
- PIO Pushbutton 

### Hardware Setup

Refer to [Agilex™ 5 FPGA Premium Development Kit User Guide](https://www.intel.com/content/www/us/en/docs/programmable/814550.html) to setup the hardware connection.

### Address Map Details

#### Nios V Address Map

![Address Map](https://github.com/altera-fpga/agilex5e-nios-ed/blob/rel/25.3/niosv_m/niosv_m_full_feature_ghrd/img/address_map.png)


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
 ||Run simulation|No|No|


 ### Environment Setup

#### Tools Download and Installation
1. Quartus Prime Pro

 - Download the Quartus® Prime Pro Edition software version 25.1 from the FPGA Software Download Center webpage of the Intel website. Follow the on-screen instructions to complete the installation process. Choose an installation directory that is relative to the Quartus® Prime Pro Edition software installation directory.
 - Set up the Quartus tools in the PATH, so they are accessible without full path.
```console
	export QUARTUS_ROOTDIR=~/intelFPGA_pro/25.1.1/quartus/
	export PATH=$QUARTUS_ROOTDIR/bin:$QUARTUS_ROOTDIR/linux64:$QUARTUS_ROOTDIR/../qsys/bin:$PATH
```

### Compilation 

#### Hardware Compilation 
- Invoke the `quartus_py` shell in the terminal
- Run the following command in the terminal from top level project directory:
 
```console
quartus_py ./scripts/build_sof.py
```

 - The quartus tool will compile the design and generate the output files

#### Software Compilation 
Note: Clean the app build project before regenerating elf
- To create software app, run the following commands in the terminal:
```console
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

### Programing 
Note: Reduce the JTAG clock frequency to 6MHz using the following command, before programming the sof file
```console
jtagconfig --setparam 1 JtagClock 6M
```

#### Program Hardware Binary SOF
- Program the generated sof and then download the elf file on the board
	
```console
quartus_pgm --cable=1 -m jtag -o 'p;ready_to_test/top.sof'
```

#### Program Software Image ELF
- Download the elf file on the board
	
```console
niosv-download -g ready_to_test/app_<peripheral>.elf -c 1
```

### Testing

#### Open JTAG UART Terminal
- Verify the output on the terminal by using the following command in the terminal:
	
```console
juart-terminal -d 1 -c 1 -i 0 
```