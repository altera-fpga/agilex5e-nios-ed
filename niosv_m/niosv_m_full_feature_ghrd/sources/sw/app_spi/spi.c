#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include "io.h"
#include "alt_types.h"
#include "system.h"
#include "transaction_to_packet.h"

// -------------------------------------------------------------------------------
// On-Chip Memory Base Address - from the prespective of SPI Agent to AvMM bridge
// ------------------------------------------------------------------------------
#define ONCHIP_MEM_FOR_BRIDGE_BASE 0x0

// ------------------------------------
// Transaction size
// ------------------------------------
#define BUFFER_LENGTH		256

// -----------------------------------------------------------------------
// INCREMENT ADDRESS - starting from the given address, data will be
//						read/write to incrementing address
// NON_INCREMEMT_ADDRESS - data will read/write only to the given address
//(If data size is more than 4 bytes, the 1st four data will be overwrite
//	by the next 4 bytes , due to non-increment address
// -----------------------------------------------------------------------
#define INCREMENT_ADDRESS			1
#define NON_INCREMENT_ADDRESS		0

void create_test_data(unsigned char* buffer, int length);

int main()
{
	int i;
	unsigned char data_buffer[BUFFER_LENGTH];
	unsigned char read_buffer[BUFFER_LENGTH];
	printf ("Starting SPI Test \n");

	// ---------------------------------------------------
	//	Create random test data with size BUFFER_LENGTH
	// ---------------------------------------------------
	create_test_data(&data_buffer[0], BUFFER_LENGTH);

	// ---------------------------------------------------
	//	Write to On Chip memory connected to SPI Bridge
	// ---------------------------------------------------
	printf("Writing data to onchip memory ...\n");
	if(transaction_channel_write (ONCHIP_MEM_FOR_BRIDGE_BASE,
									BUFFER_LENGTH,
									&data_buffer[0],
									INCREMENT_ADDRESS)){
    	printf("Write transaction successful\n\n");
	}
	else {
		printf("Write transaction unsuccessful\n\n");
	}

	// ------------------------------------------------------
	//	Read back from On Chip Memory connected to SPI Bridge
	// ------------------------------------------------------
	printf("Reading data from onchip memory ...\n\n");
	(transaction_channel_read (ONCHIP_MEM_FOR_BRIDGE_BASE,
								BUFFER_LENGTH,
								&read_buffer[0],
								INCREMENT_ADDRESS));

	// ------------------------------------------------------
	//	Compare data
	// ------------------------------------------------------
	printf("Comparing data ...\n");
	for(i=0;i<BUFFER_LENGTH;i++){
    	if(data_buffer[i]!=read_buffer[i]){
			break;
		}
    }

    if(i==BUFFER_LENGTH){
    	printf("Compare data completes error free\n\n");
    }
    else {
    	printf("Data doesn't match, error at index: %u\n\n",i);
	}

	return 0;
}

// ----------------------------------
// Function create random test data
// ----------------------------------
void create_test_data(unsigned char* buffer, int length)
{
    int i=0;
    unsigned int seed = 0;

    do
    {
      seed += __TIME__[i] << 8;
      i++;
    } while(__TIME__[i] != '\0' );
    i = 0;

    do
    {
      seed += __DATE__[i] << 8;
      i++;
    } while(__DATE__[i] != '\0' );

    srand(seed);

    printf("Creating random test data ...\n\n");

    for (i = 0; i < BUFFER_LENGTH; i++)
    {
      buffer[i] = (0xFF & rand()) % 256;  // random values between 0 and 255
    }
}