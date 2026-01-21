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
| GHRD | Golden Hardware Reference Design |
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
| 1 | Nios V/g | Nios V/g Webserver Ping Design | This design demonstrates the Ping application using the Triple Speed Ethernet IP <br>[Design details](niosv_g/niosv_g_webserver_ping/docs/Nios_Vg_Processor_Webserver_Ping_Design_on_Agilex_5_FPGA.md) |
| 2 | Nios V/g | Nios V/g TinyML LiteRT | This design demonstrates the TinyML application using LiteRT for microcontrollers software with Nios® V/g processor<br>[Design details](niosv_g/tinyml_liteRT/docs/Nios_Vg_Processor_TinyML_Design_on_Agilex_5_FPGA.md) |
| 3 | Nios V/m | Nios V/m Full Feature Golden Hardware Reference Design (GHRD) | This design demonstrates the Full Feature Golden Hardware Reference Design (GHRD) that showcases the connectivity to multiple peripherals required for application execution <br>[Design details](niosv_m/niosv_m_full_feature_ghrd/docs/NiosV_m_Processor_full_feature_ghrd_on_Agilex_5_FPGA.md)|