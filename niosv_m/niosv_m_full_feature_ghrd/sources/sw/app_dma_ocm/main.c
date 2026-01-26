
#include <stdio.h>
#include <stdint.h>
#include <io.h>
#include "system.h"
#include "altera_msgdma.h"

#include "system.h"
#include "os/alt_syscall.h"
#include "sys/alt_log_printf.h"
#include "io.h"
#include "system.h"
#include "altera_avalon_sysid_qsys_regs.h"

#include <stdio.h>
#include <system.h>
#include <io.h>
#include <unistd.h>
#include "altera_msgdma.h"

#define DATA_LENGTH 10 // Number of locations to write and verify


int main() {
    uint32_t i, data_in, data_out;
    int status = 0;
    int fail_flag = 0;

    /*
    Print address of all peripherals
    */

     printf("Peripheral Base Addresses in the Design:\n");
    printf("----------------------------------------\n");

    // Address Span Extender
    printf("ADDRESS_SPAN_EXTENDER_0_CNTL_BASE: 0x%X\n", ADDRESS_SPAN_EXTENDER_0_CNTL_BASE);
    printf("ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE: 0x%X\n", ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE);


    // JTAG UART
    printf("JTAG_UART_0_BASE: 0x%X\n", JTAG_UART_0_BASE);

    // mSGDMA
    printf("MSGDMA_0_CSR_BASE: 0x%X\n", MSGDMA_0_CSR_BASE);
    printf("MSGDMA_0_DESCRIPTOR_SLAVE_BASE: 0x%X\n", MSGDMA_0_DESCRIPTOR_SLAVE_BASE);

    // On-Chip Memory
    printf("OCM_BOOT_NIOSV_BASE: 0x%X\n", OCM_BOOT_NIOSV_BASE);
    printf("OCM_READ_DMA_WRITE_BASE: 0x%X\n", OCM_READ_DMA_WRITE_BASE);

    // PIO
    printf("PIO_0_BASE: 0x%X\n", PIO_0_BASE);



    // System ID
    printf("SYSID_QSYS_0_BASE: 0x%X\n", SYSID_QSYS_0_BASE);

    //OCM-2 CM_WRITE_DMA_READ_NIOSV_BASE
    printf("OCM-2 CM_WRITE_DMA_READ_NIOSV_BASE: 0x%X\n", OCM_WRITE_DMA_READ_BASE);

    printf("----------------------------------------\n");

    // printf("Read - Modify - Write to DDR EMIF Base : 0x%X",ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE);
    alt_u32 reset_data = 0x0;
    alt_u32 write_data = 0xdeafdead;
    alt_u32 read_data;
        printf("----------------------------------------\n");

    

    // Write data to OCM_READ_DMA_WRITE_BASE
    printf("Writing data to OCM_READ_DMA_WRITE_BASE...\n");
    for (i = 0; i < DATA_LENGTH; i++) {
        data_in = i + 1; // Example data pattern
        IOWR_32DIRECT(OCM_READ_DMA_WRITE_BASE, i * 4, data_in);
        printf("Written 0x%X to address 0x%X\n", data_in, OCM_READ_DMA_WRITE_BASE + i * 4);
    }

       #define DATA_SOURCE_BASE OCM_READ_DMA_WRITE_BASE
        alt_u32 *READ_ADDRESS = DATA_SOURCE_BASE;
        alt_u32 *CSR_BASE =  MSGDMA_0_CSR_BASE;
        alt_u32  length = DATA_LENGTH * 4;
        alt_u32  control = ALTERA_MSGDMA_DESCRIPTOR_CONTROL_PARK_WRITES_MASK;


	printf("Initializing and Configuring DMA for OCM transfers \n");
	printf("SOURCE OCM Address: 0x%X\n", OCM_READ_DMA_WRITE_BASE);
	printf("DESTINATION OCM Address: 0x%X\n", OCM_WRITE_DMA_READ_BASE);

// Initialize MSGDMA
    alt_msgdma_dev *dma_dev = alt_msgdma_open(MSGDMA_0_CSR_NAME);
    if (dma_dev == NULL) {
        printf("Failed to open MSGDMA device.\n");
        return -1;
    }
    printf("MSGDMA device opened successfully.\n");

#if 1
    // Configure MSGDMA descriptor for OCM_2: ocm_write_dma_read_niosv writes
    alt_msgdma_standard_descriptor dma_descriptor;
    status = alt_msgdma_construct_standard_mm_to_mm_descriptor(
        dma_dev,
        &dma_descriptor,
        (void *)OCM_READ_DMA_WRITE_BASE,
        (void *)OCM_WRITE_DMA_READ_BASE,
        DATA_LENGTH * 4, // Total bytes to transfer
        ALTERA_MSGDMA_DESCRIPTOR_CONTROL_PARK_WRITES_MASK // Special control flags
    );
    if (status != 0) {
        printf("Failed to construct MSGDMA descriptor.\n");
        return -1;
    }
#endif

   

    printf("MSGDMA descriptor constructed successfully.\n");

    printf("Created descriptor definition for mSGDMA\n");


    // Start the DMA transfer
    status = alt_msgdma_standard_descriptor_async_transfer(dma_dev, &dma_descriptor);
     printf("status is %x\n",status);
    if (status != 0) {
        printf("Failed to start MSGDMA transfer.\n");
        return -1;
    }
    printf("MSGDMA transfer started successfully.\n");


    /* Validate if DMA transfer completed successfully*/

	// Wait for the transfer to complete using the CSR status register
	printf("Waiting for MSGDMA transfer to complete...\n");


//Approach#2 for checking if DMA transfer is complete

#define MSGDMA_DESC_STATUS_COMPLETED_MASK 0x01
#define TIMEOUT_LIMIT 1000000 // 1ms

/**
 * Waits for DMA completion by polling descriptor->status.
 * Returns 0 on success, -1 on timeout.
 */
int wait_for_dma_completion_with_timeout() {
    uint32_t timeout = 0;

    while (!(status & MSGDMA_DESC_STATUS_COMPLETED_MASK)) {
        
        if (++timeout > TIMEOUT_LIMIT) {
            return -1; // Timeout occurred
        }
    }
    printf("timeout completed with status = 0x%X\n",status);

    return 0; // Success
}



	printf("MSGDMA transfer completed successfully for OCM-2.\n");

 

   ALT_USLEEP(1000000);
   ALT_USLEEP(1000000);
  
// Verifying if DMA moved data from OCM-1 to OCM-2
	printf("Verifying if DMA moved data from OCM-1 to OCM-2 correctly \n");
	printf("OCM_READ_DMA_WRITE_BASE: 0x%X\n", OCM_READ_DMA_WRITE_BASE);
	printf("OCM_WRITE_DMA_READ_BASE: 0x%X\n", OCM_WRITE_DMA_READ_BASE);
	for (i = 0; i < DATA_LENGTH; i++) {
        	data_out = IORD_32DIRECT(OCM_WRITE_DMA_READ_BASE, i * 4);
	        data_in = IORD_32DIRECT(OCM_READ_DMA_WRITE_BASE, i * 4);
        	printf("Read 0x%X from address 0x%X, expected 0x%X\n",
               	data_out, OCM_WRITE_DMA_READ_BASE + (i * 4), data_in);

        if (data_out != data_in) {
            	printf("Data mismatch at index %d: expected 0x%X, got 0x%X\n", i, data_in, data_out);
            	fail_flag = 1;
        }
    }

    if (fail_flag) {
        printf("Data verification failed.\n");
    } else {
        printf("Data verification succeeded.\n");
    }

}

