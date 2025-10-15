/******************************************************************************
* Copyright (c) 2010 Altera Corporation, San Jose, California, USA.           *
* All rights reserved. All use of this software and documentation is          *
* subject to the License Agreement located at the end of this file below.     *
******************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include "transaction_to_packet.h"

// ------------------------------------
// Transaction opcodes
// ------------------------------------
#define SEQUENTIAL_WRITE 0x04
#define SEQUENTIAL_READ  0x14
#define NON_SEQUENTIAL_WRITE 0x00
#define NON_SEQUENTIAL_READ  0x10

#define HEADER_LEN 8
#define RESPONSE_LEN 4

// Define to use static memory
// ----------------------------------------
#define STATIC_MEMORY_ALLOC

#ifdef STATIC_MEMORY_ALLOC	/* Buffer size allocated is sufficient for up to 1K data transaction only */
#define TRANSACTION_BUFFER_LENGTH		1032	/* 1K data + Header length 8 */
unsigned char transaction_buffer[TRANSACTION_BUFFER_LENGTH]; 
unsigned char response_buffer[TRANSACTION_BUFFER_LENGTH];
#endif

// ------------------------------------
// Function prototypes
// ------------------------------------
static unsigned char do_transaction(unsigned char trans_type, unsigned int size,  unsigned int address, unsigned char* data);

unsigned char transaction_channel_write (unsigned int address,
									unsigned int burst_length,
									unsigned char* data_buffer,
									unsigned char sequential)
{
    return sequential?do_transaction(SEQUENTIAL_WRITE, burst_length, address, data_buffer):do_transaction(NON_SEQUENTIAL_WRITE, burst_length, address, data_buffer);
}

unsigned char transaction_channel_read  (unsigned int address,
									unsigned int burst_length,
									unsigned char* data_buffer,
									unsigned char sequential)
{
    return sequential?do_transaction(SEQUENTIAL_READ, burst_length, address, data_buffer):do_transaction(NON_SEQUENTIAL_READ, burst_length, address, data_buffer);
}

static unsigned char do_transaction(unsigned char trans_type,
								unsigned int size,
								unsigned int address,
								unsigned char* data)
{
    unsigned int i;
    unsigned char result = 0;
    unsigned char header[8];
    unsigned char* transaction;
    unsigned char* response;
    unsigned char* p;


    //-------------------------
    // Make transaction header
    //-------------------------
    header[0] = trans_type;
    header[1] = 0;
    header[2] = (size >> 8) & 0xff;
    header[3] = (size & 0xff);
    header[4] = (address >> 24) & 0xff;
    header[5] = (address >> 16) & 0xff;
    header[6] = (address >> 8)  & 0xff;
    header[7] = (address & 0xff);

    switch(trans_type)
    {
        case NON_SEQUENTIAL_WRITE:
        case SEQUENTIAL_WRITE:
			//--------------------------------
			// Build up the write transaction
			//--------------------------------
#ifdef DYNAMIC_MEMORY_ALLOC
			transaction = (unsigned char *) malloc ((size + HEADER_LEN) * sizeof(unsigned char));
			if(transaction == NULL)		printf("Allocating heap memory failed\n");

			response = (unsigned char *) malloc (RESPONSE_LEN * sizeof(unsigned char));
			if(response == NULL)	printf("Allocating heap memory failed\n");
#endif
#ifdef STATIC_MEMORY_ALLOC
			transaction = &transaction_buffer[0];

			response = &response_buffer[0];
#endif
			p = transaction;

			for (i = 0; i < HEADER_LEN; i++)
				*p++ = header[i];

			for (i = 0; i < size; i++)
				*p++ = *data++;

			//-----------------------------------------------
			// Send the header and data, get 4 byte response
			//-----------------------------------------------
			packet_to_byte_convert (size + HEADER_LEN, transaction, RESPONSE_LEN, response);

			//------------------------------------------------------------------
			// Check return number of bytes in the 3rd and 4th byte of response
			//------------------------------------------------------------------
			if (size == (((unsigned int)(response[2]& 0xff)<<8)|((unsigned int)(response[3]&0xff))))
				result = 1;
#ifdef DYNAMIC_MEMORY_ALLOC
			free(transaction);
			free(response);
#endif
			break;

        case NON_SEQUENTIAL_READ:
        case SEQUENTIAL_READ:
#ifdef DYNAMIC_MEMORY_ALLOC
        	response = (unsigned char *) malloc (size * sizeof(unsigned char));
        	if(response == NULL)
        		printf("Allocating heap memory failed\n");
#endif
#ifdef STATIC_MEMORY_ALLOC
			response = &response_buffer[0];
#endif
        	//--------------------------------------------
        	// Send the header, get n size byte response
        	//--------------------------------------------
        	packet_to_byte_convert (HEADER_LEN, header, size, response);

			for (i = 0; i < size; i++)
				*data++ = *response++;

			//-------------------------------------------------------------------
			// Read do not return number of bytes , assume result always set to 1
			//-------------------------------------------------------------------
			result = 1;
#ifdef DYNAMIC_MEMORY_ALLOC
			free(response);
#endif
			break;

        default:
			break;
    }

    if(result)return 1;
    else return 0;
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
