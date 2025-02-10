#include <stdio.h>
#include <stdint.h>
#include "io.h"
#include <unistd.h>
#include <system.h>
#include "altera_avalon_sysid_qsys_regs.h"

// Define the base address for On-Chip Memory (OCM)
#define OCM_BASE INTEL_ONCHIP_MEMORY_0_BASE

// Main function
int main()
{
    int p;
    int p_updated;
    int sys_id;
    int i;
    
    // Print startup message
    printf("Hello World from NIOSV/g core ! \n");
    printf("Application will execute Memory Test \n");

    printf("Starting Memory test \n");

    // Memory test: Read, modify, and verify memory content
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

    // Read system ID from peripheral core at specified base address
    printf("Print the value of System ID \n");
    sys_id = IORD_ALTERA_AVALON_SYSID_QSYS_ID(SYSID_QSYS_0_BASE);
    printf("System ID from Peripheral core is 0x%X \n", sys_id);

    return 0;
}
