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

    c. Nios V/c core - Compact Microcontroller- Smallest (For non-interrupt driven baremetal code)


# 1. a5e065b-prem-devkit   
Example Designs using Nios V as the core based on Agilex™ 5 FPGA E-Series 065B Premium Development Kit

Development Kit product page- https://www.intel.com/content/www/us/en/products/details/fpga/development-kits/agilex/a5e065b-premium.html 

The following table contains the list of the designs on Agilex 5 FPGA E-Series 065B Premium Development Kit

| No # | Design Name Prefix (Nios V core) | Design Name Suffix (Functions) | Description |
| - | --- | ------ | ----------- |
| 1 | Nios V/m | Nios V/m Webserver Ping Design | This design demonstrates the transaction between the Nios® V processor with DMA and OCM core<br>[Design details](niosv_m/niosv_m_dma_ocm/docs/NiosV_m_Processor_DMA_OCM_Design_on_Agilex_5_FPGA.md) |
| 2 | Nios V/g | Nios V/g TinyML LiteRT | This design demonstrates the TinyML application using LiteRT for microcontrollers software with Nios® V/g processor<br>[Design details](niosv_g/tinyml_liteRT/docs/Nios_Vg_Processor_TinyML_Design_on_Agilex_5_FPGA.md) |
| 3 | Nios V/c | Nios V/c Helloworld OCM Memory test Design | Nios® V/c Processor-based Helloworld and OCM memory test example design<br>[Design details](niosv_c/niosv_c_helloworld_ocm_mem_test/docs/Nios_Vc_Processor_Helloworld_OCM_Memory_Test_Design_on_Agilex_5_FPGA.md) |
| 4 | Nios V/m | Nios V/m Full Feature Golden Hardware Reference Design (GHRD) | This design demonstrates the baseline Golden Hardware Reference Design (GHRD) for a Nios V/m processor with basic bare minimum peripherals required for any application execution <br>[Design details](niosv_m/niosv_m_baseline_ghrd/docs/NiosV_m_Processor_baseline_ghrd_on_Agilex_5_FPGA.md)|