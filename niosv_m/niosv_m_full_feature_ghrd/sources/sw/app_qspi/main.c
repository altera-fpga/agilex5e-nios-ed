/* 
 * "Small Hello World" example. 
 * 
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example 
 * designs. It requires a STDOUT  device in your system's hardware. 
 *
 * The purpose of this example is to demonstrate the smallest possible Hello 
 * World application, using the Nios II HAL library.  The memory footprint
 * of this hosted application is ~332 bytes by default using the standard 
 * reference design.  For a more fully featured Hello World application
 * example, see the example titled "Hello World".
 *
 * The memory footprint of this example has been reduced by making the
 * following changes to the normal "Hello World" example.
 * Check in the Nios II Software Developers Manual for a more complete 
 * description.
 * 
 * In the SW Application project (small_hello_world):
 *
 *  - In the C/C++ Build page
 * 
 *    - Set the Optimization Level to -Os
 * 
 * In System Library project (small_hello_world_syslib):
 *  - In the C/C++ Build page
 * 
 *    - Set the Optimization Level to -Os
 * 
 *    - Define the preprocessor option ALT_NO_INSTRUCTION_EMULATION 
 *      This removes software exception handling, which means that you cannot 
 *      run code compiled for Nios II cpu with a hardware multiplier on a core 
 *      without a the multiply unit. Check the Nios II Software Developers 
 *      Manual for more details.
 *
 *  - In the System Library page:
 *    - Set Periodic system timer and Timestamp timer to none
 *      This prevents the automatic inclusion of the timer driver.
 *
 *    - Set Max file descriptors to 4
 *      This reduces the size of the file handle pool.
 *
 *    - Check Main function does not exit
 *    - Uncheck Clean exit (flush buffers)
 *      This removes the unneeded call to exit when main returns, since it
 *      won't.
 *
 *    - Check Don't use C++
 *      This builds without the C++ support code.
 *
 *    - Check Small C library
 *      This uses a reduced functionality C library, which lacks  
 *      support for buffering, file IO, floating point and getch(), etc. 
 *      Check the Nios II Software Developers Manual for a complete list.
 *
 *    - Check Reduced device drivers
 *      This uses reduced functionality drivers if they're available. For the
 *      standard design this means you get polled UART and JTAG UART drivers,
 *      no support for the LCD driver and you lose the ability to program 
 *      CFI compliant flash devices.
 *
 *    - Check Access device drivers directly
 *      This bypasses the device file system to access device drivers directly.
 *      This eliminates the space required for the device file system services.
 *      It also provides a HAL version of libc services that access the drivers
 *      directly, further reducing space. Only a limited number of libc
 *      functions are available in this configuration.
 *
 *    - Use ALT versions of stdio routines:
 *
 *           Function                  Description
 *        ===============  =====================================
 *        alt_printf       Only supports %s, %x, and %c ( < 1 Kbyte)
 *        alt_putstr       Smaller overhead than puts with direct drivers
 *                         Note this function doesn't add a newline.
 *        alt_putchar      Smaller overhead than putchar with direct drivers
 *        alt_getchar      Smaller overhead than getchar with direct drivers
 *
 */

#include <stdio.h>
#include <io.h>
#include <system.h>
#include <unistd.h>
#include <string.h>
#include <intel_mailbox_client_flash.h>
#include <intel_mailbox_client.h>

int main (){

	intel_mailbox_client* fd;
	int ret_code;

	int sector_size = 65536;
	int sector_address;
	int number_of_sectors = 10;						//Assume as EPCQ16
	int offset = 0;

	char source [65536];
	char dest [65536];

	memset(source, 0xAA, 65536);
	#define MBOX_NAME "/dev/intel_mailbox_client_0"

	printf("Mailbox Client API\n");
	printf("EPCQ in Agilex FPGA Development Kit\n");

	//Read Device Info
	fd = mailbox_client_open(MBOX_NAME);
	if (fd!=NULL)
	{
	//Open Flash
		ret_code = mailbox_client_flash_open(fd);
		if(ret_code == 0)
		{
			printf("Opening flash device\n");
		}else
		  {
			  printf("\tERROR : Open flash operation failed\n");
			  printf("\tError code : %d\n", ret_code);
			  printf("\tExit program!\n");
			  close_flash(fd);
			  exit(0);
		  }

	//Erase Whole Flash
		for(int i=0; i<number_of_sectors; i++)
		{
			sector_address = (i*sector_size) + offset;
			ret_code = mailbox_client_flash_erase_block(fd, sector_address,sector_size);
			if(ret_code == 0)
			{
				printf("Erasing sector %d at address 0x%08X\n", i, sector_address);
			}else
			  {
				  printf("\tERROR : Erase operation failed for sector %d\n", i);
				  printf("\tError code : %d\n", ret_code);
				  printf("\tExit program!\n");
				  close_flash(fd);
				  exit(0);
			  }
		}

	//Write & Read Whole Flash
		for(int j=0; j<number_of_sectors; j++)
		{
			sector_address = (j*sector_size) + offset;
			ret_code = mailbox_client_flash_write(fd, sector_address, source, sector_size);
			if(ret_code == 0)
			{
				printf("Writing data into sector %d at address 0x%08X\n", j, sector_address);
				ret_code = mailbox_client_flash_read(fd, sector_address, dest, sector_size);
				if(ret_code == 0)
				{
					printf("Reading data...");
					for(int k=0; k<sector_size; k++)
					{
						if(dest[k] != source [k])
						{
							printf("\tERROR : Read back error in sector %d\n", j);
							printf("\tWrite value = 0x%02X\n", source[k]);
							printf("\tRead value = 0x%02X\n", dest[k]);
							printf("\tExit program !\n");
							close_flash(fd);
							exit(0);
						}
					}
					printf("ReadBack operation successful\n");
				}else
				{
					printf("\tERROR : Reading operation failed for sector %d\n", j);
					printf("\tExit program !\n");
					close_flash(fd);
					exit(0);
				}
			}else
			{
				printf("\tERROR : Writing operation failed for sector %d\n", j);
				printf("\tExit program!\n");
				close_flash(fd);
				exit(0);
			}
		}

	//Erase sector 1
		int block1_offset = offset + sector_size;
		ret_code = mailbox_client_flash_erase_block(fd, block1_offset,sector_size);
		if(ret_code == 0)
		{
			printf("Erasing sector 1 at address 0x%08X\n", block1_offset);
		}else
		{
			printf("\tERROR : Erase operation failed\n");
			printf("\tError code : %d\n", ret_code);
			printf("\tExit program!\n");
			close_flash(fd);
			exit(0);
		}

	//Write & ReadBack 1st part of sector 1 as 0xAA (size = AA_size)
		int AA_size = 22768;
		int BC_size = sector_size - AA_size;
		ret_code = mailbox_client_flash_write(fd, block1_offset, source, AA_size);
		if (ret_code == 0)
		{
			printf("Write 0xAA from address 0x%08X to 0x%08X in sector 0\n", block1_offset, (block1_offset + AA_size - 1));
			ret_code = mailbox_client_flash_read(fd, block1_offset, dest, AA_size);
			for(int k=0; k<AA_size; k++)
			{
				if(dest[k] != source [k])
				{
					printf("\tERROR : Read back error at address 0x%08X\n", (block1_offset + k));
					printf("\tWrite value = 0x%2X\n", source[k]);
					printf("\tRead value = 0x%2X\n", dest[k]);
					printf("\tExit program !\n");
					close_flash(fd);
					exit(0);
				}
			}
			printf("ReadBack operation successful\n");
		}else
		{
			printf("\tERROR : Write operation failed\n");
			printf("\tError code : %d\n", ret_code);
			printf("\tExit program!\n");
			close_flash(fd);
			exit(0);
		}

		memset(source, 0xBC, sector_size);

	//Write & ReadBack 2nd part of sector 1 as 0xBC (size = BC_size)
		ret_code = mailbox_client_flash_write_block(fd, block1_offset, (block1_offset + AA_size), source, BC_size);
		if (ret_code == 0)
		{
			printf("Write 0xBC from address 0x%08X to 0x%08X in sector 0\n", (block1_offset + AA_size), (block1_offset + AA_size + BC_size - 1));
			memset(source, 0xAA, AA_size);
			ret_code = mailbox_client_flash_read(fd, block1_offset, dest, sector_size);
			for(int k=0; k<sector_size; k++)
			{
				if(dest[k] != source [k])
				{
					printf("\tERROR : Read back error at address 0x%08X\n", (block1_offset + k));
					printf("\tWrite value = 0x%2X\n", source[k]);
					printf("\tRead value = 0x%2X\n", dest[k]);
					printf("\tExit program !\n");
					close_flash(fd);
					exit(0);
				}
			}
			printf("ReadBack operation successful\n");
		}else
		{
			printf("\tERROR : Change operation failed\n");
			printf("\tError code : %d\n", ret_code);
			printf("\tExit program!\n");
			close_flash(fd);
			exit(0);
		}

	//Write using send_cmd
		ret_code = mailbox_client_flash_erase_block(fd, 0x00010000,sector_size);
		int arg[2];
		int input_data[1];
		int resp_buff[1];

		int id = 2;
		int cmd = 0x3a;
		arg[0] = 0x00010000;
		arg[1] = 1;
		int arg_length = 2;
		int cmd_length = 2;
		int resp_length = 1;

		ret_code = mailbox_client_send_cmd(fd, id, cmd, arg, arg_length, cmd_length, input_data, resp_buff, resp_length);
		if(ret_code == 0)
		{
			printf("Read Results = 0x%08X.\n", resp_buff[0]);
		}


		id = 1;
		cmd = 0x39;
		arg[0] = 0x00010000;
		arg[1] = 1;
		arg_length = 2;
		cmd_length = 3;
		input_data[0] = 0xabcdef12;				//1 word to write
		resp_length = 0;

		ret_code = mailbox_client_send_cmd(fd, id, cmd, arg, arg_length, cmd_length, input_data, resp_buff, resp_length);
		if(ret_code == 0)
		{
			printf("Command 0x%02X with the command id of %d is successful.\n", cmd, id);
		}

		id = 2;
		cmd = 0x3a;
		arg[0] = 0x00010000;
		arg[1] = 1;
		arg_length = 2;
		cmd_length = 2;
		resp_length = 1;

		ret_code = mailbox_client_send_cmd(fd, id, cmd, arg, arg_length, cmd_length, input_data, resp_buff, resp_length);
		if(ret_code == 0)
		{
			printf("Read Results = 0x%08X.\n", resp_buff[0]);
		}

	//Close Flash
		close_flash(fd);
	}

}


void close_flash(intel_mailbox_client* fd)
{
	//Close Flash
		int ret_code = mailbox_client_flash_close(fd);
		if(ret_code == 0)
		{
			printf("Closing flash device\n");
		}else
		{
			printf("\tERROR : Closing flash operation failed\n");
			printf("\tError code : %d\n", ret_code);
			printf("\tExit program!\n");
			exit(0);
		}
}



