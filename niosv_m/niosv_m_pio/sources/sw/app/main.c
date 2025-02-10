#include <stdio.h>
#include <system.h>
#include <io.h>
#include "altera_avalon_pio_regs.h"
#include <unistd.h>
#include "system.h"
#include "altera_avalon_sysid_qsys_regs.h"

// Using usleep as the delay function
int usleep(useconds_t usec);
int sys_id;
int pio_test();

// Function to toggle PIOs and verify data consistency
int pio ()
{
    int count = 0;
    int i;
    int pio_err = 0;
    printf("Application to toggle the PIOs- [4:0] \n");

    while(count < 64)
    {
        i = count & 0xf;
        
        // Write data to the PIO register at base address PIO_0_BASE
        IOWR_ALTERA_AVALON_PIO_DATA(PIO_0_BASE, count & 0xf);
        
        // Introduce a short delay
        usleep(100);
        
        // Read back data from the PIO register
        printf("DATA READBACK FROM PIO_0_BASE is 0x%x \n", IORD_ALTERA_AVALON_PIO_DATA(PIO_0_BASE));

        // Verify if the written data matches the read data
        if (i != IORD_ALTERA_AVALON_PIO_DATA(PIO_0_BASE))
        {
            printf("Data MISMATCH - TEST FAILED \n");
            pio_err = pio_err + 1;
        }
        else
        {
            printf ("DATA MATCHED - TEST PASSED \n");
        }
        count++;
    }
    return pio_err;
}

int main () 
{
    int pio_fail_flag;

    // Run the PIO test function
    pio_fail_flag = pio();
    
    // Check the result of the PIO test
    if ((pio_fail_flag != 0))
    {
        printf ("NIOSV-PIO Test failed with PIO_ERR = %d\n", pio_fail_flag);
    }
    else
    {
        printf ("NIOSV-PIO Test PASSED \n");
    }    
    
    // Read and print the System ID from the peripheral core
    printf ("Print the value of System ID \n");
    sys_id = IORD_ALTERA_AVALON_SYSID_QSYS_ID(SYSID_QSYS_0_BASE);
    printf ("System ID from Peripheral core is 0x%X \n", sys_id);
    
    return 0;  
}