#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include "io.h"
#include "system.h"
#include "altera_avalon_pio_regs.h"
// #include "altera_avalon_sysid_qsys_regs.h"
 
void looper() {
        int i = 0;
        int rst_ack =IORD_ALTERA_AVALON_PIO_DATA(RST_ACK_PIO_BASE);
        // printf("Hello world from Nios V/g cpu \n");
        // while ((rst_ack = IORD_ALTERA_AVALON_PIO_DATA(RST_ACK_PIO_BASE)) != 0x03) {}
        
        do {
                printf("Hello world from Nios V/g cpu before reset: %d\n",i);
                i++;
                rst_ack = IORD_ALTERA_AVALON_PIO_DATA(RST_ACK_PIO_BASE);
        } while (rst_ack != 0x03);
        printf("Hello world from Nios V/g cpu after reset\n");               
}
 
int main() {
        // int i = 0;
        unsigned int ack = IORD_ALTERA_AVALON_PIO_DATA(RST_ACK_PIO_BASE);
        // printf("ACK: %d\n",IORD_ALTERA_AVALON_PIO_DATA(RST_ACK_PIO_BASE));
        
        if (ack == 0x03) {
                printf("Hello world from Nios V/g cpu after reset\n");
                return 0;
        }
        
        while ((ack = IORD_ALTERA_AVALON_PIO_DATA(RST_ACK_PIO_BASE)) != 0x01);
        
        IOWR_ALTERA_AVALON_PIO_DATA(RST_ACK_PIO_BASE, 0x02);
        
        // printf("Ack set to 2");
        // usleep(100000);
        // looper();

        do {
                printf("Hello world from Nios V/g cpu before reset\n");
                ack = IORD_ALTERA_AVALON_PIO_DATA(RST_ACK_PIO_BASE);
        } while (ack != 0x03);

        printf("Hello world from Nios V/g cpu after reset\n");
	
        return 0;
}