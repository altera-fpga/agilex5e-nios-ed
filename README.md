# Nios V Example Designs Repository

This repository contains the Nios V Example designs based on different Altera FPGA development kits.

The following table contains the list of Acronyms that the user may come across in the design details

| Acronym | Expansion |
| --- | ------ |
| DMA | Direct Memory Access |
| OCM | On-Chip Memory |
| PIO | Parallel I/O |
| RTOS | Real Time Operating System |
| ECC | Error-Correcting Code |
| TCM | Tightly Coupled Memory |
| SSS | Simple Socket Server |
| CI | Custom Instrcution |
| CRC | Cyclic Redundancy Check |


There are three variants of the NiosV core:
    
    a. Nios V/m core - Microcontroller- Balanced (For interrupt driven baremetal and RTOS code)
    
    b. Nios V/g core - General-Purpose Processor- High Performance (For interrupt driven baremetal and RTOS code)


# 1. a5e065b-prem-devkit   
Example Designs using Nios V as the core based on Agilex™ 5 FPGA E-Series 065B Premium Development Kit

Development Kit product page- https://www.intel.com/content/www/us/en/products/details/fpga/development-kits/agilex/a5e065b-premium.html 

The following table contains the list of the designs on Agilex 5 FPGA E-Series 065B Premium Development Kit

| No # | Design Name Prefix (Nios V core) | Design Name Suffix (Functions) | Description |
| - | --- | ------ | ----------- |
| 1 | Nios V/g | Nios® V/g Soft-SoC System Example Design | This design demonstrates the Soft-SoC System Example Design that showcases the connectivity to multiple peripherals with Nios® V/g processor as the core <br>[Design details](niosv_g/niosv_g_soft_soc_system_example_design/docs/Niosv_g_processor_soft_soc_system_example_design_on_Agilex_5_FPGA.md)|