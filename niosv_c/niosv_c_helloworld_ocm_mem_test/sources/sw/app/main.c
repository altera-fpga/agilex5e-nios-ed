#include <stdio.h> // Standard I/O functions
#include <stdint.h> // Standard integer types
#include "io.h" // I/O functions for memory-mapped I/O
#include <unistd.h> // Standard library for usleep function
#include <system.h> // System definitions
#include "altera_avalon_sysid_qsys_regs.h" // Altera Avalon SysID Qsys register definitions

#define OCM_BASE INTEL_ONCHIP_MEMORY_0_BASE // Base address for on-chip memory

int main() {
    int p; // Variable to store memory value
    int p_updated; // Variable to store updated memory value
    int sys_id; // Variable to store system ID (unused)
    int i; // Loop counter

    // Print initial messages
    printf("Hello World from Agilex-5 NIOSV/c core! \n");
    printf("Application will execute Memory Test \n");

    // Print starting message for memory test
    printf("Starting Memory test \n");

    // Loop to test memory locations
    for (i = 0; i < 32; i = i + 4) {
        // Read value from memory
        p = IORD_32DIRECT(OCM_BASE, i);
        printf("Value at memory location 0x%x with offset %d is 0x%x\n", OCM_BASE, i, p);

        // Write a test value to memory
        IOWR_32DIRECT(OCM_BASE, i, 0xa5a5a5a5);
        // Read the updated value from memory
        p_updated = IORD_32DIRECT(OCM_BASE, i);
        printf("After write: value at memory location 0x%x with offset %d is 0x%x\n", OCM_BASE, i, p_updated);

        // Check if the write was successful
        if (p_updated == 0xa5a5a5a5) {
            printf("Memory test passed at offset %d\n", i);
        } else {
            printf("Memory test failed at offset %d\n", i);
        }
    }

    return 0; // Exit the application
}