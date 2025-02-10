# Nios V Example Designs Repository

This repository contains the Nios V Example designs based on Agilex™ 5 FPGA E-Series 065B Premium Development Kit

Development Kit product page- https://www.intel.com/content/www/us/en/products/details/fpga/development-kits/agilex/a5e065b-premium.html 

The following table contains the list of Acronyms that the user may come across in the design details

| Acronym | Expansion |
| --- | ------ |
| DMA | Direct Memory Access |
| OCM | On-Chip Memory |
| PIO | Parallel I/O |
| RTOS | Real Time Operating System |
| GHRD | Golden Hardware Reference Design |

There are three variants of the NiosV core:
    
    a. Nios V/m core - Microcontroller- Balanced (For interrupt driven baremetal and RTOS code)
    
    b. Nios V/g core - General-Purpose Processor- High Performance (For interrupt driven baremetal and RTOS code)

    c. Nios V/c core - Compact Microcontroller- Smallest (For non-interrupt driven baremetal code)


The following table contains the list of the designs on Agilex 5 FPGA E-Series 065B Premium Development Kit

| # | Nios V core | Design name | Description |
| - | --- | ------ | ----------- |
| 1 | Nios V/m | Nios V/m DMA OCM Design | This design demonstrates the transaction between the Nios® V processor with DMA and OCM core<br>[Design details](niosv_m/niosv_m_dma_ocm/docs/Agilex™_5_FPGA_Nios®V_m_Processor_DMA_OCM_design.pdf) |
| 2 | Nios V/m | Nios V/m Helloworld OCM Memory test Design | Nios® V/m Processor-based Helloworld example design<br>[Design details](niosv_m/niosv_m_helloworld_ocm_mem_test/docs/Agilex™_5_FPGA_Helloworld_and_OCM_test_design_on_Nios®V_m_Processor.pdf) |
| 3 | Nios V/m | Nios V/m PIO Design |This design demonstrates the transaction between the Nios® V processor and the Parallel Input/Output (PIO) core<br>[Design details](niosv_m/niosv_m_pio/docs/Agilex™_5_FPGA_Nios®V_m_Processor_PIO_LED_Toggle_Design.pdf) |
| 4 | Nios V/g | Nios V/g Helloworld Design | Nios® V/g Processor-based Helloworld example design<br>[Design details](niosv_g/niosv_g_helloworld/docs/Agilex™_5_FPGA_Nios®V_g_Processor_Helloworld_Design.pdf) |
| 5 | Nios V/g | Nios V/g OCM Memory Tese Design | Nios® V/g Processor-based OCM memory test example design<br>[Design details](niosv_g/niosv_g_ocm_mem_test/docs/Agilex™_5_FPGA_Nios®V_g_Processor_OCM_test_Design.pdf) |
| 6 | Nios V/c | Nios V/c Helloworld OCM Memory test Design | Nios® V/c Processor-based Helloworld and OCM memory test example design<br>[Design details](niosv_c/niosv_c_helloworld_ocm_mem_test/docs/Agilex™_5_FPGA_Helloworld_and_OCM_test_design_on_Nios®V_c_Processor.pdf) |
| 7 | Nios V/m | Nios V/m Baseline Golden Hardware Reference Design (GHRD) | This design demonstrates the baseline Golden Hardware Reference Design (GHRD) for a Nios V/m processor with basic bare minimum peripherals required for any application execution <br>[Design details](niosv_m/niosv_m_baseline_ghrd/docs/Agilex_5_FPGA_NiosV_m_Processor_baseline_ghrd_on_Agilex_5_FPGA.pdf)


Refer to the documents in the following link for More information on the Nios V Processor core - [https://www.intel.com/content/www/us/en/support/programmable/support-resources/support-centers/nios-v-support.html ](https://www.intel.com/content/www/us/en/support/programmable/support-resources/support-centers/nios-v-support.html#introtext_1506028531_1693475107)
