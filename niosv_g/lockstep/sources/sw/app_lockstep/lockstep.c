#include <stdio.h>
#include <unistd.h>
#include "io.h"
#include "system.h"
#include "altera_avalon_pio_regs.h"
#include "altera_avalon_sysid_qsys_regs.h"
#define LOCKSTEP_CONFIG_BASE_ADDR 0x00060000 // Lockstep Base Address

// usleep definition
int usleep(useconds_t usec);

// Alarm Detection function
void alarm_detection(){
    /*
    * Detection mechanism
    * 1. Read Alarms (Expecting no alarms)
    * 2. Read fRSmartComp state (Expecting OD state)
    * 3. Read mismatch slice (Expecting no mismatch)
    */
    usleep(100000);
    //Reading Alarms (ERRCTRL_FNGIALARMS) 
    unsigned int read_alarm = IORD_32DIRECT(LOCKSTEP_CONFIG_BASE_ADDR, 0xD498);
    //Reading fRSmartComp state (ERRCTRL_FNPERIPHGI4)
    unsigned int read_state = IORD_32DIRECT(LOCKSTEP_CONFIG_BASE_ADDR, 0xD4E4);
    //Reading Mismatch Comparator Slices (ERRCTRL_FNGICMPCTXT0)
    unsigned int read_slice = IORD_32DIRECT(LOCKSTEP_CONFIG_BASE_ADDR, 0xD4B0);

    printf("****Reading Alarms, System & Comp State****\n");
    if(!read_alarm)
    {
        printf("\tINFO: No Alarms Detected\n");
    }
    else
    {
        if(read_alarm&0x1) printf("\tWARNING: Alarm0\n");
        if(read_alarm&0x2) printf("\tWARNING: Alarm1\n");
        if(read_alarm&0x4) printf("\tWARNING: Alarm2\n");
        if(read_alarm&0x8) printf("\tWARNING: Alarm3\n");
        if(read_alarm&0x10) printf("\tWARNING: Alarm4\n");
        if(read_alarm&0x10000) printf("\tWARNING: Alarm16\n");
        if(read_alarm&0x20000) printf("\tWARNING: Alarm17\n");
        if(read_alarm&0x40000) printf("\tWARNING: Alarm18\n");
        if(read_alarm&0x80000) printf("\tWARNING: Alarm19\n");
    }
 
    switch(read_state)
    {
        case 0x1: printf("\tINFO: DISABLED\n"); break;
        case 0x2: printf("\tINFO: OD (Online Detection)\n"); break;
        case 0x4: printf("\tWARNING: FCS (Failure Control by System Supervisor)\n"); break;
        default: printf("\tWARNING: This is not expected.\n");
    }
 
    
    if(!read_slice)
    {
        printf("\tINFO: No Comparator Slice mismatch\n");
    }
    else
    {
        for(int i=0; i<23; i++)
        {
            if(read_slice&0x1) printf("\tWARNING: Mismatch in Slice %d\n", i);
            read_slice=read_slice/2;
        }
    } 
}

// Lockstep Initialization
void lockstep_init() {
    printf("*******Lockstep processor Initialization*******\n");
    /*
    * Provide timeout acknowledgment (ERRCTRL_TIMEOUT_ACK)
    * Verify timeout counter stopped (ERRCTRL_TIMEOUT) by 
    * delaying more than timeout period
    * Max timeout period at 100MHz processor clock is 10.44 milliseconds
    */
    IOWR_32DIRECT(LOCKSTEP_CONFIG_BASE_ADDR, 0xD428, 0x78A5C3E1);
    IOWR_32DIRECT(LOCKSTEP_CONFIG_BASE_ADDR, 0xD428, 0x875A3C1E);
    unsigned char count1 = IORD_8DIRECT(LOCKSTEP_CONFIG_BASE_ADDR, 0xD424);
    usleep(10000);
    unsigned char count2 = IORD_8DIRECT(LOCKSTEP_CONFIG_BASE_ADDR, 0xD424);
    if(count1 == count2) printf("\tINFO: Timeout acknowledged.\n");

    /*
    * Disable timeout (ERRCTRL_TIMEOUT)
    * 1. Unlock ERRCTRL_TIMEOUT
    * 2. Verify unlocked status
    * 3. Write new timeout deadline as 0 (Disable)
    * 4. Lock ERRCTRL_TIMEOUT
    */
    IOWR_8DIRECT(LOCKSTEP_CONFIG_BASE_ADDR, 0xD427, (0x19<<1));						
    unsigned int timeout_csr = IORD_32DIRECT(LOCKSTEP_CONFIG_BASE_ADDR, 0xD424);
    printf("\tINFO: Timeout Period = %d\n", timeout_csr&0xff);
    if(timeout_csr&0x01000000) 
    {
        printf("\tINFO: ERRCTRL_TIMEOUT Unlocked Success.\n");
    } else
    {
        printf("\tWARNING: ERRCTRL_TIMEOUT Still Locked. Failed to unlock.\n");
    }

    IOWR_8DIRECT(LOCKSTEP_CONFIG_BASE_ADDR, 0xD424, 0);
    IOWR_8DIRECT(LOCKSTEP_CONFIG_BASE_ADDR, 0xD427, 0);							//Fix done here
    timeout_csr = IORD_32DIRECT(LOCKSTEP_CONFIG_BASE_ADDR, 0xD424);
    if(timeout_csr&0x01000000) 
    {
        printf("\tWARNING: ERRCTRL_TIMEOUT Still Unlocked. Failed to lock.\n");
    } else
    {
        printf("\tINFO: ERRCTRL_TIMEOUT Locked Success.\n");
    }
    timeout_csr = IORD_32DIRECT(LOCKSTEP_CONFIG_BASE_ADDR, 0xD424);
    printf("\tINFO: Timeout Period = %d\n", timeout_csr&0xff);
    if((timeout_csr&0xff) == 0) printf("\tINFO: Timeout disabled.\n");
 
    // Verify no alarm mask
    unsigned int maskA = IORD_32DIRECT(LOCKSTEP_CONFIG_BASE_ADDR, 0xD44C)&0xffffff;
    unsigned int maskB = IORD_32DIRECT(LOCKSTEP_CONFIG_BASE_ADDR, 0xD450)&0xffffff;
    if((maskA == 0x555555)&&(maskB == 0x555555))
    {
        printf("\tINFO: All alarms are unmasked.\n");
    }
    else {
        printf("\tWARNING: Alarms are Masked!!!");
    }
}

// Lockstep Reset function
void lockstep_reset() {
    /* 
    * Reset the Niosv/g processor using PIO
    */
    printf("*******Lockstep processor Reset*******\n");

    // Assert resetreq via PIO_0
    IOWR_ALTERA_AVALON_PIO_DATA(RST_REQ_PIO_BASE, 1);
    printf("Reset request asserted to Lockstep processor\n");
    
    // Short delay
    usleep(100000);

    // Deassert resetreq via PIO_0
    IOWR_ALTERA_AVALON_PIO_DATA(RST_REQ_PIO_BASE, 0);
    printf("Reset request to Lockstep processor deasserted\n");
    // usleep(100000);
    
}

//Lockstep Clear Log Functions
void lockstep_clear(){
    /*
     * Clears Lockstep module
     * 1. Disable Lockstep module
     * 2. Clear LOG
     * 3. Enable Lockstep module
     */
    printf("*******Lockstep processor Clear LOG*******\n");
    
    // Disable Lockstep module
    IOWR_32DIRECT(LOCKSTEP_CONFIG_BASE_ADDR, 0xD440, 0xABCDABCD); 
    
    /*
     * Clear LOG (ERRCTRL_PGOLOGRST)
     * 1. Unlock ERRCTRL_PGOLOGRST
     * 2. Verify unlocked status
     * 3. Reset LOG
     * 4. Stop Reset LOG
     * 4. Lock ERRCTRL_PGOLOGRST
     */
    IOWR_8DIRECT(LOCKSTEP_CONFIG_BASE_ADDR, 0xD45F, (0x1C<<1));
    unsigned int logrst_csr = IORD_32DIRECT(LOCKSTEP_CONFIG_BASE_ADDR, 0xD45C);
    if(logrst_csr&0x01000000) 
    {
        printf("\tINFO: ERRCTRL_PGOLOGRST Unlocked Success.\n");
    } else
    {
        printf("\tWARNING: ERRCTRL_PGOLOGRST Still Locked. Failed to unlock.\n");
    }

    IOWR_8DIRECT(LOCKSTEP_CONFIG_BASE_ADDR, 0xD45C, 0x33);
    usleep(100000);
    IOWR_8DIRECT(LOCKSTEP_CONFIG_BASE_ADDR, 0xD45C, 0x0);
    IOWR_8DIRECT(LOCKSTEP_CONFIG_BASE_ADDR, 0xD45F, 0);
    logrst_csr = IORD_32DIRECT(LOCKSTEP_CONFIG_BASE_ADDR, 0xD45C);
    if(logrst_csr&0x01000000) 
    {
        printf("\tWARNING: ERRCTRL_PGOLOGRST Still Unlocked. Failed to lock.\n");
    } else
    {
        printf("\tINFO: ERRCTRL_PGOLOGRST Locked Success.\n");
    }
    if((logrst_csr&0xff) == 0x33) printf("\tWARNING: Clear LOG is still active.\n");
    
    //Enable Lockstep Module    
    IOWR_32DIRECT(LOCKSTEP_CONFIG_BASE_ADDR, 0xD440, 0x75601522); 
}

int main(){
    // Initial Hard Reset to bring Lockstep Niosv/g processor out of reset
    lockstep_reset();
    // Lockstep Initilization Procedure
    lockstep_init();   
    // Alarm Detection after Initialization & LOG clear
    alarm_detection();
    
    // Set the Acknowlegment value (ACK) to 0x01
    // 0x01 - This represents that the System Supervisor is ready & waiting for Lockstep processor to be ready too.
    IOWR_ALTERA_AVALON_PIO_DATA(RST_ACK_PIO_BASE, 0x01);
    printf("ACK set to 0x01\n");
    usleep(100000);

    unsigned int ack;

    // Multiple iterations of Failsafe mechanism
    for (int i = 1; i <= 5; i=i+2) {
    	
    	// Poll for ACK from NiosV/g via PIO_1
    	// 0x02 - This represents that the System Supervisor & Lockstep Processor are ready. Test starts.
    	ack = 0;
    	while ((ack = IORD_ALTERA_AVALON_PIO_DATA(RST_ACK_PIO_BASE)) != 0x02);
    	usleep(100000);
    	printf("ACK 0x02 received from Lockstep processor\n\n ~~~~ START TEST %d ~~~~~\n", i);
     
        /*
        * Configure and Start Root Fault Injection
        * 1. Select Slice 7 as target slice (ERRCTRL_PGO0)
        * 2. Test 1 -- Inject Comparator Self-detection with working frSmartComp (ERRCTRL_ROOT_INJ)
        * 3. Test 3 -- Inject Comparator Mismatch with working frSmartComp (ERRCTRL_ROOT_INJ)
        * 4. Test 5 -- Inject Comparator Self-detection with faulty frSmartComp (ERRCTRL_ROOT_INJ)
        * 5. Stop inject
        */
        IOWR_32DIRECT(LOCKSTEP_CONFIG_BASE_ADDR, 0xD460, 0x7);
        IOWR_32DIRECT(LOCKSTEP_CONFIG_BASE_ADDR, 0xD444, i); 
        IOWR_32DIRECT(LOCKSTEP_CONFIG_BASE_ADDR, 0xD444, 0x0);  
        printf("*********Root Fault Injected*********\n");  

        // Detection after Root Fault Injection
        alarm_detection();

        // Hard Reset Lockstep processor
        lockstep_reset();
        // Lockstep Initilization Procedure
    	lockstep_init();
        
        // Detection after Lockstep Processor Reset
        alarm_detection();
        
        // Set ACK value to 0x01
    	// 0x01 - Toggling ACK back to 0x01 to check whether Lockstep processor is still online
    	IOWR_ALTERA_AVALON_PIO_DATA(RST_ACK_PIO_BASE, 0x01);
    	printf("ACK set to 0x01\n");
    }
    
    // Set ACK value to 0x03
    // 0x03 - This represents that the Test is completed.	
    IOWR_ALTERA_AVALON_PIO_DATA(RST_ACK_PIO_BASE, 0x03);
    printf("ACK set to 0x03\n\n ~~~~ END TEST ~~~~~\n\n");
 
    return 0;
 
}

