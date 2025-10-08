/******************************************************************************
* Copyright (c) 2010 Altera Corporation, San Jose, California, USA.           *
* All rights reserved. All use of this software and documentation is          *
* subject to the License Agreement located at the end of this file below.     *
******************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "packet_to_byte.h"

//------------------------------------
// Special packet characters
//------------------------------------
#define SOP     0x7a
#define EOP     0x7b
#define CHANNEL 0x7c
#define ESC     0x7d

// ----------------------------------------
// Define to use static or dynamic memory 
// ----------------------------------------
#define DYNAMIC_MEMORY_ALLOC
//#define STATIC_MEMORY_ALLOC

#ifdef STATIC_MEMORY_ALLOC	/* Buffer size allocated is sufficient for up to 1K data transaction only */
#define PACKET_BUFFER_LENGTH		2068 	/* TRANSACTION_BUFFER_LENGTH * 2 (for special characters) + 4 (EOP/SOP/CHAN/ESC) */
unsigned char send_packet_buffer[PACKET_BUFFER_LENGTH];
unsigned char response_packet_buffer[PACKET_BUFFER_LENGTH];
#endif

//------------------------------------
// Function prototypes
//------------------------------------
static unsigned char xor_20(unsigned char val);

unsigned char packet_to_byte_convert (unsigned int send_length, unsigned char* send_data,
								unsigned int response_length, unsigned char* response_data)
{
    unsigned int i;
    unsigned int packet_length = 0;
    unsigned char *send_packet;
    unsigned char *response_packet;
    unsigned char *p;
    unsigned char current_byte;

    //--------------------------------------------------------------
    //To figure out what the maximum length of the packet is going
    // to be so we can allocate a chunk of memory for it.
    //
    // All packets start with an SOP byte, followed by a channel
    // id (2 bytes) and end with an EOP. That's 4 bytes.
    //
    // However, we have to escape characters that are the same
    // as any of the SOP/EOP/channel bytes. Worst case scenario
    // is that each data byte is escaped, which leads us to the
    // algorithm below.
    //---------------------------------------------------------------
    
#ifdef DYNAMIC_MEMORY_ALLOC
    unsigned int send_max_len = 2 * send_length + 4;
    unsigned int response_max_len = 2 * response_length + 4;
	
	send_packet = (unsigned char *) malloc (send_max_len * sizeof(unsigned char));
    if(send_packet == NULL)	printf("Allocating heap memory failed\n");

    response_packet = (unsigned char *) malloc (response_max_len * sizeof(unsigned char));
    if(response_packet == NULL)	printf("Allocating heap memory failed\n");
#endif
#ifdef STATIC_MEMORY_ALLOC
	unsigned int response_max_len = 2 * response_length + 4;
	
	send_packet = &send_packet_buffer[0];

	response_packet = &response_packet_buffer[0];
#endif
    p = send_packet;

    //------------------------------------
    // SOP
    //------------------------------------
    *p++ = SOP;

    //------------------------------------
    // Channel information. Only channel 0 is defined.
     //------------------------------------
    *p++ = CHANNEL;
    *p++ = 0x0;

    //------------------------------------
    // Append the data to the packet
    //------------------------------------
    for (i = 0; i < send_length; i++)
    {
        current_byte = send_data[i];
        //------------------------------------
        // EOP must be added before the last byte
        //------------------------------------
        if (i == send_length-1)
        {
            *p++ = EOP;
        }

        //------------------------------------
        // Escape data bytes which collide with our
        // special characters.
        //------------------------------------
        switch(current_byte)
        {
            case SOP:
                        *p++ = ESC;
                        *p++ = xor_20(current_byte);
                        break;
            case EOP:
                        *p++ = ESC;
                        *p++ = xor_20(current_byte);
                        break;
            case CHANNEL:
                        *p++ = ESC;
                        *p++ = xor_20(current_byte);
                        break;
            case ESC:
                        *p++ = ESC;
                        *p++ = xor_20(current_byte);
                        break;

            default:
                        *p++ = current_byte;
                        break;
        }

    }
    packet_length=p-send_packet;

	byte_to_core_convert(packet_length,send_packet,response_max_len,response_packet);
	//-----------------------------------------------------------------
	//Analyze response packet , reset pointer to start of response data
	//-----------------------------------------------------------------
	p = response_data;
	//-------------
	//Look for SOP
	//-------------
	for(i=0;i<response_max_len;i++){
		if(response_packet[i] == SOP) {
			i++;
			break;
		}
	}

	//-------------------------------
	//Continue parsing data after SOP
	//-------------------------------
	while(i < response_max_len)
	{
		current_byte = response_packet[i];

		switch(current_byte)
		{
			case ESC:
			case CHANNEL:
			case SOP:
				i++;
				current_byte = response_packet[i];
				*p++ = xor_20(current_byte);
				i++;
				break;

			//------------------------------------
			// Get a EOP, get the next last byte
			// and exit while loop
			//------------------------------------
			case EOP:
				i++;
				current_byte = response_packet[i];

				if((current_byte == ESC)||(current_byte == CHANNEL)||(current_byte == SOP)){
					i++;
					current_byte = response_packet[i];
					*p++ = xor_20(current_byte);
				}

				else *p++ = current_byte;

				i = response_max_len;
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
