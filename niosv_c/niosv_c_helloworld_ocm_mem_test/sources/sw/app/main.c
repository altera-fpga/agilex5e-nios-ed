#include <stdio.h>
#include <stdint.h>
#include "io.h"
#include <unistd.h>
#include <system.h>
#include "altera_avalon_sysid_qsys_regs.h"

#define OCM_BASE INTEL_ONCHIP_MEMORY_0_BASE

int main()
{
    int p;
    int p_updated;
    int sys_id;
    int i;
    
    // Print initial messages
    printf("Hello World from Agilex-5  NIOSV/c core! \n");
    printf("Application will execute Memory Test \n");
    
    // Start memory test by reading and writing values to on-chip memory
    printf("Starting Memory test \n");

    for (i = 0; i < 32; i = i + 4)
    {
        // Read value from memory at specified base address and offset
        p = IORD_32DIRECT(OCM_BASE, i);
        printf("value at memory location 0x%x with offset %d is 0x%x\n", OCM_BASE, i, p);
        
        // Write a test pattern to memory
        IOWR_32DIRECT(OCM_BASE, i, 0xa5a5a5a5);
        
        // Read back the value to verify the write operation
        p_updated = IORD_32DIRECT(OCM_BASE, i);
        printf("After write: value at memory location 0x%x with offset %d is 0x%x\n", OCM_BASE, i, p_updated);

        // Verify if the written value matches expected data
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

    // Read and print the System ID from the peripheral core
    printf("Print the value of System ID \n");
    sys_id = IORD_ALTERA_AVALON_SYSID_QSYS_ID(SYSID_QSYS_0_BASE); // Read System ID from the Qsys system ID peripheral
    printf("System ID from Peripheral core is 0x%X \n", sys_id);

    return 0;
}
