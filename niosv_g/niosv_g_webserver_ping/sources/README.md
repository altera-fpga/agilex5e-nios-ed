# Nios® V/g Ping Design 

 This design demonstrates the Ping application on a Nios® V/g processor using the Triple Speed Ethernet IP for the Agilex™ 5 FPGA E-Series 065B Premium Development Kit.

## Description

The example design demonstrates ping application. The Nios V/g acts as the core. The Triple Speed Ethernet (TSE) IP is configured in RGMII mode and connectes to the onboard 88E1512 PHY via RGMII interface. 
The design has 2 MSGDMA IPs configured in Memory Mapped to Stream (MM2S) mode for Transmission and Stream to Memory Mapped (S2MM) mode for Reception.

To test the application, connect the RGMII Interface of the Agilex 5 Development Kit to the Link Partner using RJ-45 cable.
Ensure that the IP addresses are modified accordingly in the application code under the following location - sw/app_freertos/main.c
Once the application binaries are downloaded (See section 3.d below for the steps), the board starts pinging the link partner automatically.
Observe the Ping Request and Response prints on the terminal.


![image](https://github.com/altera-fpga/agilex5e-nios-ed/blob/rel/25.3.1/niosv_g/niosv_g_webserver_ping/img/web_server_block_diagram.png)

## Project Details

- **Title**: Nios® V/g Ping Design
- **Source**: Github
- **Design Support**: CTH
- **Family**: Agilex 5
- **Quartus Version**: 25.3.1
- **Development Kit**: Agilex 5 FPGA E-Series 065B Premium Development Kit DK-A5E065BB32AES1
- **Device Part**: A5ED065BB32AE6SR0
- **Design Package**: agilex5_niosv_g_webserver_ping.zip
- **Category**: Networking
- **URL**: https://github.com/altera-fpga/agilex5e-nios-ed/blob/rel/25.3.1/niosv_g/niosv_g_webserver_ping
- **download URL**: https://github.com/altera-fpga/agilex5e-nios-ed/releases/download/25.3.1-v1.0/agilex5_niosv_g_webserver_ping.zip

## Documentation

- **Title**: Design Document 
**URL**: https://github.com/altera-fpga/agilex5e-nios-ed/blob/rel/25.3.1/niosv_g/niosv_g_webserver_ping/docs/NiosV_g_Processor_ping_on_Agilex_5_FPGA.md


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
quartus_py ./scripts/build_sof.py
```
- The quartus tool will compile the design and generate the output files

c. Creating the bsp, build software sources and download elf
- To create software app, run the following commands in the terminal:

- Clean the app build project before regenerating elf

```     
niosv-bsp -c --quartus-project=hw/top.qpf --qsys=hw/qsys_top.qsys --type=freertos --cmd="enable_sw_package altera_freertos_tcpip" sw/bsp_freertos/settings.bsp
niosv-app --bsp-dir=sw/bsp_freertos --app-dir=sw/app_freertos --srcs=sw/app_freertos/main.c
cmake -S ./sw/app_freertos -B sw/app_freertos/build
make -C sw/app_freertos/build
```
Note:The software can be compiled using the Ashling Visual Studio Code Extension for Altera FPGAs

For information on the build process, please refer to the following document- [Ashling VSCode Extension](https://www.intel.com/content/www/us/en/docs/programmable/730783/current/ashling-visual-studio-code-extension.html)

d. Hardware Validation
- Program the generated sof and then download the elf file on the board
```        
quartus_pgm --cable=1 -m jtag -o 'p;ready_to_test/top.sof'
``` 
- Reduce the JTAG clock frequency to 6MHz before programming the application .elf file on the board.
```
jtagconfig --setparam 1 JtagClock 6M
```
- Toggle the In-System-Sources and Probe (ISSP) IP to initialize PHY and set it to 1G.
```
quartus_stp -t ready_to_test/toggle_issp.tcl
```
- Download the elf file on the board 
```    
niosv-download -g ready_to_test/app.elf -c 1
``` 
- Verify the output on the terminal by using the following command in the terminal:
``` 
juart-terminal -d 1 -c 1 -i 0 
```