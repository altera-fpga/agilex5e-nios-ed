// Copyright (C) 2022 Intel Corporation
//
// This software and the related documents are Intel copyrighted materials, and
// your use of them is governed by the express license under which they were
// provided to you ("License"). Unless the License provides otherwise, you may
// not use, modify, copy, publish, distribute, disclose or transmit this
// software or the related documents without Intel's prior written permission.
//
// This software and the related documents are provided as is, with no express
// or implied warranties, other than those that are expressly stated in the
// License.
//
// -----------------------------------------------------------------------------
// File: main.c
// -----------------------------------------------------------------------------



#include <stdio.h>
#include <stdint.h>
#include "io.h"
#include <unistd.h>
#include <system.h>
#include "altera_avalon_pio_regs.h"
#include "altera_avalon_sysid_qsys_regs.h"

// Define the base address for On-Chip Memory (OCM)
#define OCM_BASE INTEL_ONCHIP_MEMORY_0_BASE

// Function to perform a memory test by reading, modifying, and verifying memory content
void mem_test()
{
    printf("Starting Memory test \n");
    int i;
    int p, p_updated;

    for (i = 0; i < 32; i = i + 4)
    {
        // Read value from memory at specified base address and offset
        p = IORD_32DIRECT(OCM_BASE, i);
        printf("value at memory location 0x%x with offset %d is 0x%x\n", OCM_BASE, i, p);

        // Write test pattern to memory at specified base address and offset
        IOWR_32DIRECT(OCM_BASE, i, 0xa5a5a5a5);
        
        // Read back written value from memory at specified base address and offset
        p_updated = IORD_32DIRECT(OCM_BASE, i);
        printf("After write: value at memory location 0x%x with offset %d is 0x%x\n", OCM_BASE, i, p_updated);

        // Validate memory write operation
        if (p_updated == 0xa5a5a5a5)
        {
            printf("Memory write test PASSED\n");
        }
        else
        {
            printf("Memory write test FAILED at location 0x%X\n", (OCM_BASE + i));
        }
    }
    printf("Memory Test Complete \n");
}

// Function to perform PIO test by toggling PIOs and verifying read-back values
int pio_test()
{
    int count = 0;
    int i;
    int iter = 0;
    int pio_err = 0;
    printf("Application to toggle the PIOs- [4:0] \n");

    // increase the below value while testing the leds on board
    while (iter < 10000)
    {
        if (count == 64)
        {
            count = 0;
            IOWR_ALTERA_AVALON_PIO_DATA(PIO_0_BASE, 0xf);
        }
        // Generate a test pattern to write to PIO
        i = count & 0xf;
        IOWR_ALTERA_AVALON_PIO_DATA(PIO_0_BASE, count & 0xf);
        // IORD_ALTERA_AVALON_PIO_DATA(PIO_1_BASE);
        usleep(100);
        
        // Read back value from PIO
        printf("DATA READBACK FROM PIO_0_BASE is 0x%x \n", IORD_ALTERA_AVALON_PIO_DATA(PIO_0_BASE));
        printf("DATA READBACK FROM PIO_1_BASE is 0x%x \n", IORD_ALTERA_AVALON_PIO_DATA(PIO_1_BASE));

        // Verify the read-back value matches expected pattern
        if (i != IORD_ALTERA_AVALON_PIO_DATA(PIO_0_BASE))
        {
            printf("Data MISMATCH - TEST FAILED \n");
            pio_err++;
        }
        else
        {
            printf("DATA MATCHED - TEST PASSED \n");
        }
        count++;
        iter++;
    }
    return pio_err;
}

// Main function
int main()
{
    int pio_fail_flag;
    int sys_id;

    // Print startup message
    printf("Hello World from NiosV Baseline GHRD \n");
    
    // Execute memory test
    mem_test();
    
    // Execute PIO test
    pio_fail_flag = pio_test();
    
    // Check PIO test result
    if (pio_fail_flag != 0)
    {
        printf("NIOSV-PIO Test failed with PIO_ERR = %d\n", pio_fail_flag);
    }
    else
    {
        printf("NIOSV-PIO Test PASSED \n");
    }

    // Read and print system ID from peripheral core
    printf("Print the value of System ID \n");
    sys_id = IORD_ALTERA_AVALON_SYSID_QSYS_ID(SYSID_QSYS_0_BASE);
    printf("System ID from Peripheral core is 0x%X \n", sys_id);

    return 0;
}
