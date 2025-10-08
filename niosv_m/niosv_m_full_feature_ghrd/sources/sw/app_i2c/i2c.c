#include <stdio.h>
#include <unistd.h>
#include "io.h"
#include "alt_types.h"
#include "system.h"
#include "altera_avalon_i2c.h"

// -------------------------------------------------------------------------------
// On-Chip Memory Base Address - from the prespective of I2C Agent to AvMM bridge
// ------------------------------------------------------------------------------
#define ONCHIP_MEM_FOR_BRIDGE_BASE 0x0

// -------------------
// I2C Host IP pointer
// -------------------
ALT_AVALON_I2C_DEV_t *i2c_dev; 

// -------------------------------------------------------------------
// I2C Agent to AvMM bridge's I2C Slave Address & Byte Address Length
// -------------------------------------------------------------------
const alt_u8 I2C_TARGET_ADDRESS = 0x55;
const alt_u8 I2C_BYTE_ADDRESS_COUNT = 4;

int i2c_init(ALT_AVALON_I2C_DEV_t **i2c_dev)
{
    // Get a pointer to the avalon i2c instance
	// Modify the I2C_0_NAME according to system.h
    printf("Initializing I2C host...\n");
	*i2c_dev = alt_avalon_i2c_open(I2C_0_NAME);
    if (NULL == *i2c_dev) {
        printf("Error: Cannot find %s\n", I2C_0_NAME);
        return 1;
    }
	
    // Set the target address as 0x55 (I2C Agent to AvMM Bridge I2C Address in qsys_agent.qsys).
    alt_avalon_i2c_master_target_set(*i2c_dev, I2C_TARGET_ADDRESS);
	printf("Info: Found %s\n\n", I2C_0_NAME);

    return 0;
}

int i2c_agent_to_avmm_read_bytes(ALT_AVALON_I2C_DEV_t *i2c_dev, alt_u32 target_addr,
                   alt_u32 read_byte_count, alt_u8 *buf)
{
    ALT_AVALON_I2C_STATUS_CODE status;
    alt_u8 txbuffer[4] = {0};
    alt_u8 retry_count = 0;

    txbuffer[0] = 0xFF & (target_addr >> 24);
    txbuffer[1] = 0xFF & (target_addr >> 16);
    txbuffer[2] = 0xFF & (target_addr >> 8);
    txbuffer[3] = 0xFF & (target_addr >> 0);

    printf(
        "Preparing to read %lu bytes of data from I2C address 0x%02lX and target address 0x%02X%02X%02X%02X\n",
        read_byte_count, i2c_dev->master_target_address, txbuffer[0], txbuffer[1], txbuffer[2], txbuffer[3]);
    do {
        status = alt_avalon_i2c_master_tx_rx(i2c_dev, txbuffer,
                                             I2C_BYTE_ADDRESS_COUNT, buf,
                                             read_byte_count,
                                             ALT_AVALON_I2C_NO_INTERRUPTS);
        if (status != ALT_AVALON_I2C_SUCCESS) {
            printf("Error: I2C read failed with code %ld\n", status);
        }
    } while ((status != ALT_AVALON_I2C_SUCCESS) && (retry_count++ < 5));

    if (status != ALT_AVALON_I2C_SUCCESS)
        return 1; //FAIL

    return 0;
}

int i2c_agent_to_avmm_write_bytes(ALT_AVALON_I2C_DEV_t *i2c_dev, alt_u32 target_addr,
                    alt_u32 write_byte_count, alt_u8 *buf)
{
    ALT_AVALON_I2C_STATUS_CODE status;
    int i;
    alt_u8 txbuffer[200] = {0};

    txbuffer[0] = 0xFF & (target_addr >> 24);
    txbuffer[1] = 0xFF & (target_addr >> 16);
    txbuffer[2] = 0xFF & (target_addr >> 8);
    txbuffer[3] = 0xFF & (target_addr >> 0);
    for (int i = 0; i < write_byte_count; i++) {
        txbuffer[I2C_BYTE_ADDRESS_COUNT + i] = buf[i];
    }

    // Write the address and data
    printf(
        "Preparing to write data to I2C address 0x%02lX and target address 0x%02X%02X%02X%02X\n",
        i2c_dev->master_target_address, txbuffer[0], txbuffer[1], txbuffer[2], txbuffer[3]);
    for (i = 0; i < write_byte_count; i++) {
        printf("   0x%02X\n", txbuffer[I2C_BYTE_ADDRESS_COUNT + i]);
    }
	printf("\n");
    status = alt_avalon_i2c_master_tx(i2c_dev, txbuffer,
                                      write_byte_count + I2C_BYTE_ADDRESS_COUNT,
                                      ALT_AVALON_I2C_NO_INTERRUPTS);

    if (status != ALT_AVALON_I2C_SUCCESS)
    {
		printf("Error: I2C write failed with code %ld\n", status);
		return 1; //FAIL
	}		


    return 0;
}

alt_u32 i2c_agent_to_avmm_read_word(ALT_AVALON_I2C_DEV_t *dev, alt_u32 target_addr)
{
    int ret;
    alt_u8 buf[4] = {0};
    alt_u32 ret_data = 0;

    printf("Preparing to read word from target 0x%08lX\n", target_addr);

    ret = i2c_agent_to_avmm_read_bytes(dev, target_addr, 4, buf);

    // Assume it will always be successful. Otherwise retry should occur here
    if (ret != 0) {
        printf("Error: i2c_read_bytes failed in i2c_read_word\n");
        return 0;
    } else {
		ret_data = (buf[0] << 0) | (buf[1] << 8) | (buf[2] << 16) | (buf[3] << 24);
		printf("Read Data: 0x%08lX\n\n", ret_data);
        return ret_data;
    }
}

void i2c_agent_to_avmm_write_word(ALT_AVALON_I2C_DEV_t *dev, alt_u32 target_addr,
                    alt_u32 data)
{
    int ret;
    alt_u8 buf[4] = {0};

    printf("Preparing to write word 0x%08lX to target 0x%08lX\n", data, target_addr);

    buf[0] = 0xFF & (data >> 0);
    buf[1] = 0xFF & (data >> 8);
    buf[2] = 0xFF & (data >> 16);
    buf[3] = 0xFF & (data >> 24);

    ret = i2c_agent_to_avmm_write_bytes(dev, target_addr, 4, buf);

    if (ret != 0) {
        printf("Error: i2c_write_bytes failed\n");
    }
    else {
    printf ("All the I2C reads and writes completed successfully \n");
    }
}

int main() {
	
	//Initializing I2C Host & I2C Agent to AvMM bridge
	i2c_init(&i2c_dev);
    
	/* Read a single address from I2C Agent to AvMM bridge (4KBytes On-Chip Memory).
	 * Valid On-Chip Memory address : 0x0 ~ 0xfff.
	 * Selected address 0x0.
	 * Expecting "Read Data: 0x0" from an empty On-Chip Memory
	 */
	i2c_agent_to_avmm_read_word(i2c_dev, ONCHIP_MEM_FOR_BRIDGE_BASE);
	
	/* Write a single address to I2C Agent to AvMM bridge (4KBytes On-Chip Memory).
	 * Valid On-Chip Memory address : 0x0 ~ 0xfff
	 * Selected address 0x0.
	 */
	i2c_agent_to_avmm_write_word(i2c_dev, ONCHIP_MEM_FOR_BRIDGE_BASE, 0xdeadbeef);
	
	/* Read a single address from I2C Agent to AvMM bridge (4KBytes On-Chip Memory).
	 * Valid On-Chip Memory address : 0x0 ~ 0xfff
	 * Selected address 0x0.
	 * Expecting "Read Data: 0xdeadbeef" from a written On-Chip Memory
	 */
	i2c_agent_to_avmm_read_word(i2c_dev, ONCHIP_MEM_FOR_BRIDGE_BASE);
	
	/* Write a single address to I2C Agent to AvMM bridge (4KBytes On-Chip Memory).
	 * Valid On-Chip Memory address : 0x0 ~ 0xfff
	 * Selected address 0x0.
	 */
	i2c_agent_to_avmm_write_word(i2c_dev, ONCHIP_MEM_FOR_BRIDGE_BASE, 0xabcdef89);
	
	/* Read a single address from I2C Agent to AvMM bridge (4KBytes On-Chip Memory).
	 * Valid On-Chip Memory address : 0x0 ~ 0xfff
	 * Selected address 0x0.
	 * Expecting "Read Data: 0xdeadbeef" from a written On-Chip Memory
	 */
	i2c_agent_to_avmm_read_word(i2c_dev, ONCHIP_MEM_FOR_BRIDGE_BASE);
	
	printf("Bye world!\n");
	
    fflush(stdout);
    return 0;
}
