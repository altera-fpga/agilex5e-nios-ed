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

#define ALARM_RATE 20

volatile alt_u32 simple_cnt = 0;
alt_alarm m_the_alarm;

//void initialize_sw_timer_interrupt (void);
void initialize_interval_timer_interrupt(void);

//static void isr_sw_timer (void * context , alt_u32 id);
static void isr_interval_timer (void * context, alt_u32 id);

int usleep(useconds_t usec);


alt_u32 alarm_cb(void *context) {
    ++simple_cnt;
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
	/* Once serviced, clear the interrupt */
	IOWR_ALTERA_AVALON_TIMER_STATUS(TIMER_0_BASE,0x0);	
	++simple_cnt;
}

int main()
{
		
	printf("Example Design to showcase different approach to implement periodical interrupts: \n\n");
	
	//Start the Alarm
	printf("Approach 1 --- Alarms \n");
	printf("With the Nios V processor internal timer ticks 1000 per seconds,\nthe alarm callback function (a count-up counter) is triggered about 50 times in 1 second when alarm's nticks is 20\n\n");
	
	alt_alarm_start(&m_the_alarm, ALARM_RATE, alarm_cb, NULL);
	// Wait for 1.5 second
	ALT_USLEEP(1500000);
	alt_alarm_stop(&m_the_alarm);
	printf("Turn on Alarm for 1.5 second...\n");
	printf ("Counter is at %ld, which should be close to %d times\n", simple_cnt, NIOSV_INTERNAL_TIMER_TICKS_PER_SECOND/ALARM_RATE*3/2);
	// Alarm Trigger in 1 second = Total ticks in 1 second divide by Alarm tick counts
	// Alarm Trigger in 1 second = Total ticks in 1.5 seconds divide by Alarm tick counts
	printf ("Resetting simple counter\n");
	simple_cnt=0;
	
	
	alt_alarm_start(&m_the_alarm, ALARM_RATE, alarm_cb, NULL);
	// Wait for 0.5 second
	ALT_USLEEP(500000);
	alt_alarm_stop(&m_the_alarm);
	printf("Turn on Alarm for another 0.5 second...\n");
	printf ("Counter is at %ld, which should be close to %d times\n", simple_cnt, NIOSV_INTERNAL_TIMER_TICKS_PER_SECOND/ALARM_RATE/2);
	printf ("Resetting simple counter\n\n");
	simple_cnt=0;
		
		
	//Start the Interval Timer IP as Platform Interrupt
	printf("Approach 2 --- Interval Timer IP as Platform Interrupt \n");
	printf("With the Interval Timer IP sending interrupt every second,\nthe Interval Timer IP ISR (also a count-up counter) is triggered 1 times in 1 second\n\n");
	
	
	initialize_interval_timer_interrupt();
	// Wait for 3 second
	ALT_USLEEP(3000000);
	IOWR_ALTERA_AVALON_TIMER_CONTROL(TIMER_0_BASE, ALTERA_AVALON_TIMER_CONTROL_STOP_MSK); // Explicitly stop the timer
	printf("Turn on Interval Timer IP for 3 second...\n");
	printf ("Counter is at %ld, which should be close to %d times\n", simple_cnt, 3*1000/TIMER_0_PERIOD); 
	// Interrupt Trigger in 1 second = 1000 milliseconds divide by timeout period
	// Interrupt Trigger in 3 seconds = 3*1000 milliseconds divide by timeout period
	printf ("Resetting simple counter\n");
	simple_cnt=0;

	
	initialize_interval_timer_interrupt();
	// Wait for 2 second
	ALT_USLEEP(2000000);
	IOWR_ALTERA_AVALON_TIMER_CONTROL(TIMER_0_BASE, ALTERA_AVALON_TIMER_CONTROL_STOP_MSK); // Explicitly stop the timer
	printf("Turn on Interval Timer IP for 2 second...\n");
	printf ("Counter is at %ld, which should be close to %d times\n\n", simple_cnt, 2*1000/TIMER_0_PERIOD);
	
	return 0;		
}
