
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


    printf("Read - Modify - Write to DDR EMIF Base : 0x%X \n",ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE);
    alt_u32 reset_data = 0x0;
    alt_u32 write_data = 0xdeafdead;
    alt_u32 read_data;
    alt_u32 mismatch= 0x0;
    //Read the DDR memory for contents before DMA copies data into it

    for(i=0; i < DATA_LENGTH; i++) {

        printf("Data read at DDR location 0x%lX is : 0x%X \n", (ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE + (i*4)), IORD_32DIRECT(ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE, i * 4) );

    }
    //Clear the DDR memory
    for(i=0; i < DATA_LENGTH; i++) {

        read_data = IORD_32DIRECT(ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE, i * 4);
        printf("read_data BEFORE clearing DDR is 0x%lX \n", read_data);
        IOWR_32DIRECT(ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE, i * 4,(read_data * reset_data));
        read_data = IORD_32DIRECT(ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE, i * 4);
        printf("read_data AFTER clearing DDR is 0x%lX \n", read_data);

        printf("Reading DDR locations after Write data 0x%lX at DDR location 0x%lX : is : 0x%X\n", reset_data , (ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE + (i*4)), IORD_32DIRECT(ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE, i * 4) );

    }

    //Write DATA to DDR memory
    for(i=0; i < DATA_LENGTH; i++) {
        printf("Writing String 0x%lX to DDR location : 0x%lX\n", write_data,(ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE + (i*4)) );
        read_data = IORD_32DIRECT(ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE, i * 4);
        IOWR_32DIRECT(ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE, (i * 4),0xdeafdead);
        read_data = IORD_32DIRECT(ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE, i * 4);
        printf("DATA READ AFTER WRITING STRING TO DDR is 0x%lX \n", read_data);

        printf("Reading DDR locations after Write STRING data 0x%lX at DDR location 0x%lX : is : 0x%X\n", write_data , (ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE + (i*4)), IORD_32DIRECT(ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE, i * 4) );

        // Compare write and read
        if (read_data != write_data) {
            printf("MISMATCH at index %ld: Wrote 0x%lX, Read 0x%lX\n", i, write_data, read_data);
            mismatch = 1;
        }

    }

    if (mismatch == 0) {
        printf("SUCCESS: All data matched!\n");
    } else {
        printf("FAIL: Data mismatch occurred.\n");
    }

}

 
