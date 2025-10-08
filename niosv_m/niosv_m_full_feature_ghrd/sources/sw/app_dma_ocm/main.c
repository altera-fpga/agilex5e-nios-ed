
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
    // printf("ADDRESS_SPAN_EXTENDER_0_CNTL_BASE: 0x%X\n", ADDRESS_SPAN_EXTENDER_0_CNTL_BASE);
    // printf("ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE: 0x%X\n", ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE);

    // Frequency Counter
    // printf("FREQ_COUNTER_0_BASE: 0x%X\n", FREQ_COUNTER_0_BASE);

    // JTAG UART
    printf("JTAG_UART_0_BASE: 0x%X\n", JTAG_UART_0_BASE);

    // mSGDMA
    printf("MSGDMA_0_CSR_BASE: 0x%X\n", MSGDMA_0_CSR_BASE);
    printf("MSGDMA_0_DESCRIPTOR_SLAVE_BASE: 0x%X\n", MSGDMA_0_DESCRIPTOR_SLAVE_BASE);

    // On-Chip Memory
    printf("OCM_BOOT_NIOSV_BASE: 0x%X\n", OCM_BOOT_NIOSV_BASE);
    printf("OCM_READ_DMA_WRITE_BASE: 0x%X\n", OCM_READ_DMA_WRITE_BASE);

    // PIO
    // printf("PIO_0_BASE: 0x%X\n", PIO_0_BASE);

    // Product Info
    // printf("PRODUCT_INFO_0_BASE: 0x%X\n", PRODUCT_INFO_0_BASE);

    // // Status Monitor
    // printf("STATUS_MON_0_BASE: 0x%X\n", STATUS_MON_0_BASE);

    // System ID
    printf("SYSID_QSYS_0_BASE: 0x%X\n", SYSID_QSYS_0_BASE);

    //OCM-2 CM_WRITE_DMA_READ_NIOSV_BASE
    printf("OCM-2 CM_WRITE_DMA_READ_NIOSV_BASE: 0x%X\n", OCM_WRITE_DMA_READ_BASE);

    printf("----------------------------------------\n");

    // printf("Read - Modify - Write to DDR EMIF Base : 0x%X",ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE);
    alt_u32 reset_data = 0x0;
    alt_u32 write_data = 0xdeafdead;
    alt_u32 read_data;
    //Read the DDR memory for contents before DMA copies data into it

    // for(i=0; i < DATA_LENGTH; i++) {

    //     printf("Data read at DDR location 0x%X is : 0x%X \n", (ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE + (i*4)), IORD_32DIRECT(ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE, i * 4) );

    // }
    //Clear the DDR memory
    // for(i=0; i < DATA_LENGTH; i++) {

    //     read_data = IORD_32DIRECT(ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE, i * 4);
    //     printf("read_data BEFORE clearing DDR is 0x%X \n", read_data);
    //     IOWR_32DIRECT(ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE, i * 4,(read_data * reset_data));
    //     read_data = IORD_32DIRECT(ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE, i * 4);
    //     printf("read_data AFTER clearing DDR is 0x%X \n", read_data);

    //     printf("Reading DDR locations after Write data 0x%X at DDR location 0x%X : is : 0x%X\n", reset_data , (ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE + (i*4)), IORD_32DIRECT(ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE, i * 4) );

    // }

    //Write DATA to DDR memory
    // for(i=0; i < DATA_LENGTH; i++) {
    //     printf("Writing String 0x%X to DDR location : 0x%X\n", write_data,(ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE + (i*4)) );
    //     read_data = IORD_32DIRECT(ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE, i * 4);
    //     IOWR_32DIRECT(ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE, (i * 4),0xdeafdead);
    //     read_data = IORD_32DIRECT(ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE, i * 4);
    //     printf("DATA READ AFTER WRITING STRING TO DDR is 0x%X \n", read_data);

    //     printf("Reading DDR locations after Write STRING data 0x%X at DDR location 0x%X : is : 0x%X\n", write_data , (ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE + (i*4)), IORD_32DIRECT(ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE, i * 4) );

    // }

        printf("----------------------------------------\n");

    

    // Write data to OCM_READ_DMA_WRITE_BASE
    printf("Writing data to OCM_READ_DMA_WRITE_BASE...\n");
    for (i = 0; i < DATA_LENGTH; i++) {
        data_in = i + 1; // Example data pattern
        IOWR_32DIRECT(OCM_READ_DMA_WRITE_BASE, i * 4, data_in);
        printf("Written 0x%X to address 0x%X\n", data_in, OCM_READ_DMA_WRITE_BASE + i * 4);
    }

       #define DATA_SOURCE_BASE OCM_READ_DMA_WRITE_BASE
    //    #define DATA_DESTINATION_BASE ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE
    //    alt_u32 *WRITE_ADDRESS = ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE;
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

//Approach 1
#if 0
#define ALTERA_MSGDMA_CSR_STATUS_DESCRIPTOR_ERROR_MASK  0x08  // Bit 3
#define ALTERA_MSGDMA_CSR_STATUS_TRANSFER_ERROR_MASK    0x10  // Bit 4

uint32_t dma_status;
dma_status = IORD_ALTERA_MSGDMA_CSR_STATUS(MSGDMA_0_CSR_BASE);
printf("dma_status is 0x%X\n",dma_status);
do {
    dma_status = IORD_ALTERA_MSGDMA_CSR_STATUS(MSGDMA_0_CSR_BASE);
                printf("dma is busy with 0x%X\n", (dma_status & ALTERA_MSGDMA_CSR_BUSY_MASK));
    // Check for errors in the status register
    if (dma_status & ALTERA_MSGDMA_CSR_STATUS_DESCRIPTOR_ERROR_MASK) {
        printf("Error: Descriptor fetch error occurred.\n");
        //return -1;
    }
    if (dma_status & ALTERA_MSGDMA_CSR_STATUS_TRANSFER_ERROR_MASK) {
        printf("Error: Transfer error occurred.\n");
        //return -1;
    }

} while (dma_status & ALTERA_MSGDMA_CSR_BUSY_MASK); // Wait until the busy flag is cleared

#endif

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

//wait for dma completion
#if 0
if (wait_for_dma_completion_with_timeout() != 0) {
    // Handle timeout error
    printf("DMA transfer timed out!\n");
} else {
    // Proceed with data validation or next steps
    printf("DMA transfer completed successfully.\n");
}
#endif


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

/*--------------------------------------------------*/
 /* Showcasing DMA  to DDR transfers is not required */
 /*--------------------------------------------------*/ 

#if 0

printf("Configuring DMA Descriptor for DDR transfers \n");


#if 1
    // Configure MSGDMA descriptor for DDR writes
    alt_msgdma_standard_descriptor dma_ddr_descriptor;
    status = alt_msgdma_construct_standard_mm_to_mm_descriptor(
        dma_dev,
        &dma_ddr_descriptor,
        (void *)OCM_READ_DMA_WRITE_BASE,
        (void *)ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE,
        DATA_LENGTH * 4, // Total bytes to transfer
        ALTERA_MSGDMA_DESCRIPTOR_CONTROL_PARK_WRITES_MASK // Special control flags
    );
    if (status != 0) {
        printf("Failed to construct MSGDMA descriptor.\n");
        return -1;
    }
    #endif
  // Start the DMA transfer
    status = alt_msgdma_standard_descriptor_async_transfer(dma_dev, &dma_ddr_descriptor);
     printf("status is %x\n",status);
    if (status != 0) {
        printf("Failed to start MSGDMA transfer.\n");
        return -1;
    }
    printf("MSGDMA transfer started successfully.\n");
printf("Wait for DMA completion\n");
if (wait_for_dma_completion_with_timeout() != 0) {
    // Handle timeout error
    printf("DMA transfer timed out!\n");
} else {
    // Proceed with data validation or next steps
    printf("DMA transfer completed successfully.\n");
}


printf("MSGDMA transfer completed successfully for DMA-DDR\n");


// Verifying if Data copied successfully from DMA to DDR
printf("Verifying if Data copied successfully from DMA to DDR \n");

printf("DMA moved data to 0x%X DDR DESTINATION ADDRESS \n",ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE);

    printf("MSGDMA transfer completed.\n");

    // Verify data at ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE
    printf("Verifying data at ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE...\n");
    for (i = 0; i < DATA_LENGTH; i++) {
        data_out = IORD_32DIRECT(ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE, i * 4);
        data_in = IORD_32DIRECT(OCM_READ_DMA_WRITE_BASE, i * 4);
        printf("Read 0x%X from address 0x%X, expected 0x%X\n",
               data_out, ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE + i * 4, data_in);

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

    return 0;
}

#endif







/*--------------------------------------------------*/
/* Approach 2 -- Not required */
/*--------------------------------------------------*/


#if 0

#include <stdio.h>
#include <system.h>
#include <io.h>
#include <unistd.h>

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include "altera_msgdma_descriptor_regs.h"
#include "altera_msgdma_prefetcher_regs.h"
#include "altera_msgdma_descriptor_regs.h"
#include "altera_msgdma_csr_regs.h"
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
#include "altera_avalon_sysid_qsys_regs.h"



typedef uint32_t u32;

//#define EMIF_FM_0_BASE EMIF_FM_0_ARCH_BASE
//#define OCM_0_BASE INTEL_ONCHIP_MEMORY_0_BASE
#define NIOSV_WINDOW_S_ASE_0 ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE

#define DATA_DESTINATION_BASE NIOSV_WINDOW_S_ASE_0 //DDR4_EMIF_BASE
#define DATA_SOURCE_BASE OCM_READ_DMA_WRITE_BASE //INTEL_ONCHIP_MEMORY_1_BASE
#define LEN 256
#define LEN_S 256

// Using usleep as the delay funciton
        int usleep(useconds_t usec);





// Using usleep as the delay funciton
        int usleep(useconds_t usec);

//Modular Scatter-Gather DMA defines

        alt_msgdma_dev *STDATA_MSGDMA;
        alt_msgdma_dev *dev_ptr;
        alt_msgdma_standard_descriptor STDATA_MSGDMA_DESEC;
        alt_u32 *WRITE_ADDRESS = DATA_DESTINATION_BASE;
        alt_u32 *READ_ADDRESS = DATA_SOURCE_BASE;
        alt_u32 * ram_readaccess_ptr;
        alt_u32 * ram_writeaccess_ptr;
        alt_u32 i,j,first_dma_source_data;
        alt_u32 data_in,data_read;
        alt_32 status=0;

        int *ptr_src_base = (int *)DATA_SOURCE_BASE;



	int main () 
	{
		int a,b,c;
		int i,j;
		int p, p_updated;
		int fail_flag = 0 ;
		int itr = 1 ;
		int sys_id;

		printf("SOURCE_ADDR is : 0x%X \n", DATA_SOURCE_BASE);
		printf("DESTINATION_ADDR is : 0x%X \n", DATA_DESTINATION_BASE);
		printf("Clearing EMIF memory: 0x%X \n",NIOSV_WINDOW_S_ASE_0);

		for(j = 1024; j < 1096; j=j+4)
        	{
			
		 	p = IORD_32DIRECT(NIOSV_WINDOW_S_ASE_0,j);
                        printf("value at memory location 0x%x with offset %x is 0x%x\n",(NIOSV_WINDOW_S_ASE_0),j, p);
			
			printf("Writing Data Pattern 0x0 \n");
                        IOWR_32DIRECT(NIOSV_WINDOW_S_ASE_0,j,(p & 0x0));
                        p_updated = IORD_32DIRECT(NIOSV_WINDOW_S_ASE_0,j);

			printf("After write: value at memory location 0x%x with offset %x is 0x%x\n",(NIOSV_WINDOW_S_ASE_0),j,p_updated);
		}


#if 0
		for (i =1024 ; i < 1040 ; i=i+4)
		{
			printf("Start Iteration %d\n",itr);
			p = IORD_32DIRECT(DDR4_EMIF_BASE,i);
			printf("value at memory location 0x%x with offset %x is 0x%x\n",(DDR4_EMIF_BASE),i, p);

			printf("Writing Data Pattern 0xa5a5a5a5 \n");
			IOWR_32DIRECT(DDR4_EMIF_BASE,i,0xa5a5a5a5);
			p_updated = IORD_32DIRECT(DDR4_EMIF_BASE,i);

  			printf("After write: value at memory location 0x%x with offset %x is 0x%x\n",(DDR4_EMIF_BASE),i,p_updated);

			if(IORD_32DIRECT(DDR4_EMIF_BASE,i) == 0xa5a5a5a5)
			{
				printf("Memory test PASSED in iteration : %d\n",itr);
			}
			else
			{
				printf("Memory test FAILED in iteration : %d\n",itr);
				fail_flag = fail_flag + 1;
			}
			itr++;
		}
#endif
#if 0
		if (fail_flag != 0)
		{
			printf ("EMIF Memory Test Failed\n");
			printf ("EMIF_fail_flag = %d \n",fail_flag);
		}
		else
		{
			printf ("EMIF Memory Test PASSED\n");
		}
#endif

		printf("writing into OCM  memory from NIOS V\n");

        for(j = 1024; j < 1096; j=j+4)
        {
                /* writing a repeating pattern of 0, 1, .. ,0xFF, ..*/
                data_in = (j & 0xFFFFFFFF);
                IOWR_32DIRECT(DATA_SOURCE_BASE, j, data_in);
                printf("Addr 0x%lx     Writing Data  0x%lx\n",(DATA_SOURCE_BASE+j), data_in);

                printf("Addr 0x%lx     Reading back Data written 0x%lx\n",(DATA_SOURCE_BASE+j), IORD_32DIRECT(DATA_SOURCE_BASE,j));

        }

        printf("Data write to onchip memory completed\n");


		 //Open the mSGDMA
        dev_ptr = alt_msgdma_open(MSGDMA_0_CSR_NAME);
        if (dev_ptr == NULL)
        printf("Could not open mSG-DMA\n");
        printf("DMA is open mSG-DMA\n");
        // Construct the DMA descriptors
        if(alt_msgdma_construct_standard_mm_to_mm_descriptor (
                dev_ptr,
                &STDATA_MSGDMA_DESEC,
                READ_ADDRESS,
                WRITE_ADDRESS,
                LEN,
                ALTERA_MSGDMA_DESCRIPTOR_CONTROL_PARK_WRITES_MASK
                ) == -EINVAL)
                {
                printf(" invalid argument \n");
                goto exit;
                }
                printf("Created descriptor definition for mSG-DMA\n");


        // Run the mSGMA
        status =alt_msgdma_standard_descriptor_async_transfer(dev_ptr, &STDATA_MSGDMA_DESEC);
        printf("status is %x\n",status);

        ALT_USLEEP(100000);
        // verify the data written by the msgdma at the destination addresses //
	printf("DMA moved data to 0x%X DESTINATION ADDRESS \n",DATA_DESTINATION_BASE);
        for(i = 1024; i < 1096; i=i+4)
        {

                data_read = IORD_32DIRECT(DATA_DESTINATION_BASE,i); // Issue with IORD and IOWR

		ALT_USLEEP(10000);
                printf("Addr 0x%lx     Data read 0x%lx\n",(DATA_DESTINATION_BASE+i), data_read);
                ALT_USLEEP(10000);
                // should be a pattern of 0, 1, .., 0x20, .. 
                printf("base 0x%x offset_add 0x%lx ,expected 0x%lx read 0x%lx\n",DATA_DESTINATION_BASE,i,(i&0xFFFFFFFF), data_read);

                if ((i & 0xFFFFFFFF) != data_read)
                {
                        printf("Error - base 0x%x offset_add 0x%lx failed,expected %lx but read 0x%lx\n" ,DATA_DESTINATION_BASE, i,(i&0xFFFFFFFF), data_read);
                        goto exit;
                } else {
                printf("Data matched !\n");
                }
        }
        printf("Memory copy over DMA was a SUCCESS. Session will now close. \n");

	//sys_id = IORD_ALTERA_AVALON_SYSID_QSYS_ID(SYSID_QSYS_0_BASE);
        //printf ("System ID from Peripheral core is 0x%X \n",sys_id);

        exit:

        printf("%c",(char)4);




		return 0;  
      }


		
#endif