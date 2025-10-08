/* *************************************************************************
 * The following application makes use of interrupts
 * 1. It uses the sw timer agent internal timecmp regitser to issue 
 * an interrupt the niosv core
 * 2. There is a timer IP in the hardware which as 10ms issues an interrupt
 * to the core
 ***************************************************************************/
#include <stdio.h>
#include "system.h"
#include <io.h>
#include "altera_avalon_sysid_qsys_regs.h"
#include <altera_avalon_timer_regs.h>
#include <unistd.h>
#include "sys/alt_irq.h"
#include "intel_niosv_m.h"
#include "intel_niosv.h"
#include "sys/alt_alarm.h"
#include "alt_types.h"
#include "sys/alt_sys_wrappers.h"

#define MIN_ALARMS 5
#define ALARM_RATE 20

volatile alt_u32 m_alarm_cnt = 0;
alt_alarm m_the_alarm;

//void initialize_sw_timer_interrupt (void);
void initialize_interval_timer_interrupt(void);

//static void isr_sw_timer (void * context , alt_u32 id);
static void isr_interval_timer (void * context, alt_u32 id);

int usleep(useconds_t usec);


alt_u32 alarm_cb(void *context) {
    ++m_alarm_cnt;
    return ALARM_RATE;
}


void initialize_interval_timer_interrupt (void)
{

	/* Use this function from sys/alt_irq.h to register the interrupt with NIOSV */
	alt_ic_isr_register(TIMER_0_IRQ_INTERRUPT_CONTROLLER_ID,
			TIMER_0_IRQ,
			(void *)isr_interval_timer, NULL, 0x0);

	/* Initiate the Interval Timer : drivers/inc/altera_avalon_timer_regs.h */
	IOWR_ALTERA_AVALON_TIMER_CONTROL(TIMER_0_BASE, 
			ALTERA_AVALON_TIMER_CONTROL_CONT_MSK 
			| ALTERA_AVALON_TIMER_CONTROL_START_MSK 
			| ALTERA_AVALON_TIMER_CONTROL_ITO_MSK);

}

static void isr_interval_timer (void * context, alt_u32 id)
{

	static int num =0 ;
	/* Once serviced, clear the interrupt */

	IOWR_ALTERA_AVALON_TIMER_STATUS(TIMER_0_BASE,0x0);
	
	printf("Interrupt Serviced # %d\n",num++);

	printf("SYS ID is 0x%x\n", IORD_ALTERA_AVALON_SYSID_QSYS_ID(SYSID_QSYS_0_BASE));

	// Disable the timer after it has serviced 10 times
	if (num >= 10)
	{
		//IOWR_ALTERA_AVALON_TIMER_CONTROL(TIMER_0_BASE, 0x0); // Disable the timer
		IOWR_ALTERA_AVALON_TIMER_CONTROL(TIMER_0_BASE, ALTERA_AVALON_TIMER_CONTROL_STOP_MSK); // Explicitly stop the timer

		printf("Timer disabled after 10 interrupts.\n");
	}


}

static void initialize_sw_timer_interrupt (void)
{
	// Utilizing the alarm function for sw timer interrupts
	alt_alarm_start(&m_the_alarm, ALARM_RATE, alarm_cb, NULL);
}



	int main()
	{
	
		int i;
		
		printf("Example Design to showcase the SW Timer and Timer Interval Interrupts being serviced \n");
		printf("SW Timer Interrupt alarm triggerd \n");
		initialize_sw_timer_interrupt();
		// Wait for n cycles
		ALT_USLEEP(1000000);
		/*
		for (i = 0; i < 1000000; i++)
		{
			__asm__("NOP");
		}
		*/
		printf("Out of sleep \n");
		
		// Call the timer function
		initialize_interval_timer_interrupt();
	
		
		if (m_alarm_cnt < MIN_ALARMS) {
			printf("Potential issue with alarm callback, it only occurred %lu times...\n", m_alarm_cnt);
		} else {
			printf ("Alarm triggered by internal sw timer Interrupt %d number of times \n",m_alarm_cnt);
		}


		

	
		while(1)
		{
		}
	
		return 0;
		
	}
