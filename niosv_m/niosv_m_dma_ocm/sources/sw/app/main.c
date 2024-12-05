/*  
 *  Description: Application that demonstrates the 
 *  transfer between the 2 memories via mSGDMA 
 *
 *
 *
 */


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
typedef uint32_t u32;


#define DATA_SOURCE_BASE INTEL_ONCHIP_MEMORY_1_BASE
#define DATA_DESTINATION_BASE INTEL_ONCHIP_MEMORY_2_BASE
#define LEN 256
#define LEN_S 256

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
	int sys_id;


int main()
{

	printf ("Hello World from NIOSV/m core on SM ! \n");

	printf ("****************Run DMA Test - OCM to OCM **************************************** \n");

	// DMA operation:

	printf("writing into onchip memory from NIOS V\n");
		
	for(j = 0; j < 32; j=j+4)
	{
		/* writing a repeating pattern of 0, 1, .. ,0xFF, ..*/
       		data_in = (j & 0xFFFFFFFF);
       		IOWR_32DIRECT(DATA_SOURCE_BASE, j, data_in);
	
		printf("Addr 0x%lx     Data written 0x%lx\n",(DATA_SOURCE_BASE+j), IORD_32DIRECT(DATA_SOURCE_BASE,j));

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

	ALT_USLEEP(1000);
	// verify the data written by the msgdma at the destination addresses //
	for(i = 0; i < 32; i=i+4)
	{
      
		data_read = IORD_32DIRECT(DATA_DESTINATION_BASE,i); // Issue with IORD and IOWR
		ALT_USLEEP(1000);
		printf("Addr 0x%lx     Data read 0x%lx\n",(DATA_DESTINATION_BASE+i), data_read);
		ALT_USLEEP(1000);
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
	
	printf ("Print the value of System ID \n");
        sys_id = IORD_ALTERA_AVALON_SYSID_QSYS_ID(SYSID_QSYS_0_BASE);
        printf ("System ID from Peripheral core is 0x%X \n",sys_id);


	exit:

	printf("%c",(char)4);

	return 0;
}
