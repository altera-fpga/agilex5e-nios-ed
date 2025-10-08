/******************************************************************************
* Copyright (c) 2010 Altera Corporation, San Jose, California, USA.           *
* All rights reserved. All use of this software and documentation is          *
* subject to the License Agreement located at the end of this file below.     *
******************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include "system.h"
#include "byte_to_core.h"

//------------------------------------
// Special packet characters
//------------------------------------
#define BYTESIDLECHAR 0x4a
#define BYTESESCCHAR  0x4d

// ----------------------------------------
// Define to use static or dynamic memory 
// ----------------------------------------
#define DYNAMIC_MEMORY_ALLOC
//#define STATIC_MEMORY_ALLOC

#ifdef STATIC_MEMORY_ALLOC	/* Buffer size allocated is sufficient for up to 1K data transaction only */
#define BYTE_BUFFER_LENGTH		4136 	/* PACKET_BUFFER_LENGTH * 2 (for special characters) */
unsigned char send_byte_buffer[BYTE_BUFFER_LENGTH];
unsigned char response_byte_buffer[BYTE_BUFFER_LENGTH];
#endif

//------------------------------------
// Function prototypes
//------------------------------------
static unsigned char xor_20(unsigned char val);

unsigned char byte_to_core_convert (unsigned int send_length, unsigned char* send_data,
								unsigned int response_length, unsigned char* response_data)
{
    unsigned int i;
    unsigned int packet_length = 0;
    unsigned char *send_packet;
    unsigned char *response_packet;
    unsigned char *p;
    unsigned char current_byte;

    //---------------------------------------------------------------------
    // The maximum length of the packet is going to be so we can allocate
    // a chunk of memory for it. Assuming worst case scenario is that each
    // data byte is escaped, so we double the memory allocation.
    //---------------------------------------------------------------------
    
#ifdef DYNAMIC_MEMORY_ALLOC
    unsigned int send_max_len = 2 * send_length;
    unsigned int response_max_len = 2 * response_length;
	
	send_packet = (unsigned char*) malloc (send_max_len * sizeof(unsigned char));
    if(send_packet == NULL)	printf("Allocating heap memory failed\n");

    response_packet = (unsigned char*) malloc (response_max_len * sizeof(unsigned char));
    if(response_packet == NULL)	printf("Allocating heap memory failed\n");
#endif
#ifdef STATIC_MEMORY_ALLOC
	unsigned int response_max_len = 2 * response_length;
	
	send_packet = &send_byte_buffer[0];

	response_packet = &response_byte_buffer[0];
#endif
    p = send_packet;

    for (i = 0; i < send_length; i++)
    {
        current_byte = send_data[i];
        //-----------------------------------------------
        // Check for Escape and Idle special characters.
        // If exists, insert Escape and XOR the next byte
        //-----------------------------------------------
        switch(current_byte)
        {
            case BYTESIDLECHAR:
                        *p++ = BYTESESCCHAR;
                        *p++ = xor_20(current_byte);
                        break;
            case BYTESESCCHAR:
                        *p++ = BYTESESCCHAR;
                        *p++ = xor_20(current_byte);
                        break;
            default:
                        *p++ = current_byte;
                        break;
        }

    }
    packet_length=p-send_packet;

    //---------------------------------------------------------
    // Use the SPI core access routine to transmit and receive
    //---------------------------------------------------------
    spi_command(SPI_0_BASE,0,packet_length,send_packet,response_max_len,response_packet,0);

    //-----------------------------------------------------------------
    //Analyze response packet , reset pointer to start of response data
    //-----------------------------------------------------------------
	i=0;
	p = response_data;
	while(i < response_max_len)
	{
		current_byte = response_packet[i];
		//-----------------------------------------------
		// Check for Escape and Idle special characters.
		// If exists, ignore and XOR the next byte
		//-----------------------------------------------
		switch(current_byte)
		{
			case BYTESIDLECHAR:
				i++;
				break;

			case BYTESESCCHAR:
				i++;
				current_byte = response_packet[i];
				*p++ = xor_20(current_byte);
				i++;
				break;

			default:
				*p++ = current_byte;
				i++;
				break;
		}
	}
#ifdef DYNAMIC_MEMORY_ALLOC
	free(send_packet);
    free(response_packet);
#endif
    return 0;
}

static unsigned char xor_20(unsigned char val)
{
    return val^0x20;
}

/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2010 Altera Corporation, San Jose, California, USA.           *
* All rights reserved.                                                        *
*                                                                             *
* Permission is hereby granted, free of charge, to any person obtaining a     *
* copy of this software and associated documentation files (the "Software"),  *
* to deal in the Software without restriction, including without limitation   *
* the rights to use, copy, modify, merge, publish, distribute, sublicense,    *
* and/or sell copies of the Software, and to permit persons to whom the       *
* Software is furnished to do so, subject to the following conditions:        *
*                                                                             *
* The above copyright notice and this permission notice shall be included in  *
* all copies or substantial portions of the Software.                         *
*                                                                             *
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  *
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    *
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE *
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      *
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     *
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         *
* DEALINGS IN THE SOFTWARE.                                                   *
*                                                                             *
* This agreement shall be governed in all respects by the laws of the State   *
* of California and by the laws of the United States of America.              *
* Altera does not recommend, suggest or require that this reference design    *
* file be used in conjunction or combination with any other product.          *
******************************************************************************/
