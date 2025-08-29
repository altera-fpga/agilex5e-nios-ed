# Agilex 5 FPGA - Hello World on Nios® V/g Processor Design Example

Nios® V/g Processor-based Helloworld example design on the Agilex® 5 FPGA.

## Description

Nios® V/g Processor-based Helloworld example design on the Agilex® 5 FPGA E-Series 065B Premium Development Kit (ES1) DKA5E065BB32AES1

![image](https://github.com/altera-fpga/agilex5e-nios-ed/blob/rel/25.1.1/niosv_g/niosv_g_helloworld/img/hello_world.png)

## Project Details

* **Title**: Agilex 5 FPGA - Hello World on Nios® V/g Processor Design Example
* **Source**: Github
* **Design Support**: CTH
* **Family**: Agilex 5
* **Quartus Version**: 25.1.1
* **Development Kit**: Agilex 5 FPGA E-Series 065B Premium Development Kit DK-A5E065BB32AES1
* **Device Part**: A5ED065BB32AE6SR0
* **Design Package**: agilex5_niosv_g_helloworld.zip
* **Category**: Helloworld
* **URL**: https://github.com/altera-fpga/agilex5e-nios-ed/tree/rel/25.1.1/niosv_g/niosv_g_helloworld
* **downloadURL**: https://github.com/altera-fpga/agilex5e-nios-ed/releases/download/25.1.1-v1.0/agilex5_niosv_g_helloworld.zip


## Documentation

* **Title**: Design Document
* **URL**: https://github.com/altera-fpga/agilex5e-nios-ed/tree/rel/25.1.1/niosv_g/niosv_g_helloworld/img/block_diagram.png

# Getting Started

Vendor: Altera

Devkit Product Page: [https://www.intel.com/content/www/us/en/products/details/fpga/development-kits/agilex/a5e065b-premium.html](https://www.intel.com/content/www/us/en/products/details/fpga/development-kits/agilex/a5e065b-premium.html)

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
- To create software app, run the following commands in the terminal:

- Clean the app build project before regenerating elf

- Building HAL application 

```
niosv-bsp -c --quartus-project=hw/top.qpf --qsys=hw/qsys_top.qsys --type=hal sw/bsp_hal/settings.bsp
niosv-app --bsp-dir=sw/bsp_hal --app-dir=sw/app_hal --srcs=sw/app_hal/main.c
niosv-shell
cmake -S ./sw/app_hal -B sw/app_hal/build -G "Unix Makefiles"
make -C sw/app_hal/build
elf2hex sw/app_hal/build/app.elf -b 0x0 -w 32 -e 0x7ffff sw/app_hal/build/onchip_mem.hex -r4
```

- Building FreeRTOS application 

```        
niosv-bsp -c --quartus-project=hw/top.qpf --qsys=hw/qsys_top.qsys --type=freertos sw/bsp_freertos/settings.bsp
niosv-app --bsp-dir=sw/bsp_freertos --app-dir=sw/app_freertos --srcs=sw/app_freertos/main.c
niosv-shell
cmake -S ./sw/app_freertos -B sw/app_freertos/build -G "Unix Makefiles"
make -C sw/app_freertos/build
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
HAL Application
```
niosv-download -g ready_to_test/app_hal.elf -c 1
```
FreeRTOS application
```
niosv-download -g ready_to_test/app_freertos.elf -c 1
```
- Verify the output on the terminal by using the following command in the terminal:
``` 
juart-terminal -d 1 -c 1 -i 0 
```

### 4. Running simulation

Simulation is enabled for this design where the memory is initialized with the application hex. Use the following commands to run the simulation:

- Generate Testbench from Platform Designer. Generate -> Generate Testbench System 
```	
cp ./sw/app_hal/build/onchip_mem.hex ./qsys_top_tb/qsys_top_tb/sim/mentor 
cd hw/qsys_top_tb/qsys_top_tb/sim/mentor/
vsim &
source msim_setup.tcl
ld_debug
run -all
```
