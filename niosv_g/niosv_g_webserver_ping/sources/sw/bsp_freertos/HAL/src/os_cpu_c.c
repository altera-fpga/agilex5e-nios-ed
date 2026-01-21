/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2022 Intel Corporation, Santa Clara, California, USA.         *
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
*                                                                             *
* Altera does not recommend, suggest or require that this reference design    *
* file be used in conjunction or combination with any other product.          *
******************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include "alt_types.h"
#include "sys/alt_log_printf.h"
#include "sys/alt_irq.h"
#include "FreeRTOS.h"
#include "task.h"

/* Counter to check ISR or non-ISR context. If the value is non-zero, the
 * context is inside ISR.
 */ 
alt_u32 ulHalNestedInterruptCounter = 0;

/* handle_trap() and alt_tick() are Intel HAL function. */
extern alt_u32 handle_trap( alt_u32 cause, alt_u32 epc, alt_u32 tval );
extern void alt_tick( void );

#define HAL_HANDLE_TRAP();  alt_u32 ulMCAUSE = 0, ulMEPC = 0, ulMTVAL = 0;           \
	                        __asm volatile( "csrr %0, mcause" : "=r"( ulMCAUSE ) );  \
                            __asm volatile( "csrr %0, mepc" : "=r"( ulMEPC ) );      \
                            __asm volatile( "csrr %0, mtval" : "=r"( ulMTVAL ) );    \
                            ulHalNestedInterruptCounter++;                           \
                            handle_trap(ulMCAUSE, ulMEPC, ulMTVAL);                  \
                            ulHalNestedInterruptCounter--;                           \

/* Hook for tick. To use this, configUSE_TICK_HOOK must set to 1 */
#if ( configUSE_TICK_HOOK != 1 )
    #error configUSE_TICK_HOOK must be set to 1 because vApplicationTickHook() is used to call alt_tick().
#endif
void vApplicationTickHook( void )
{
    /* ALT_LOG - see altera_hal/HAL/inc/sys/alt_log_printf.h */
    ALT_LOG_SYS_CLK_HEARTBEAT();

    ulHalNestedInterruptCounter++;
    alt_tick();
    ulHalNestedInterruptCounter--;
}

/* This hook is provided by HAL and will be called at the end of alt_tick(). 
 * This function is declared as weak in this source file for reference.
 * Application writer could implement a concrete one in another source file to
 * overwrite this function.
 */
__WEAK void vTickHookUser( void )
{

}

/* Hook for generating canary value using rand(). Application writer could
 * override this hook to have different canary value generation. 
 */
#if (configENABLE_HEAP_PROTECTOR == 1)
__WEAK void vApplicationGetRandomHeapCanary(portPOINTER_SIZE_TYPE* pxHeapCanary ) {
	if (pxHeapCanary != NULL) {
		*pxHeapCanary = rand();
	}
}
#endif

/* Hook for stack overflow. To use this, configCHECK_FOR_STACK_OVERFLOW must set
 * 1 or 2. 
 */
#if ( configCHECK_FOR_STACK_OVERFLOW == 1 )
__WEAK void vApplicationStackOverflowHook( TaskHandle_t xTask, char *pcTaskName )
{
    /*  To suspress unused argument warning. */
	( void ) xTask;

    printf("Stack overflow task is %s \r\n",pcTaskName);
    taskDISABLE_INTERRUPTS();
    __asm volatile( "ebreak" );
    for( ;; );
}
#endif

/* Override weak function defined in portASM.S */
void freertos_risc_v_application_interrupt_handler( void )
{
   HAL_HANDLE_TRAP();
}

/* Override weak function defined in portASM.S */
void freertos_risc_v_application_exception_handler( void )
{
   HAL_HANDLE_TRAP();
}

#if ( configSUPPORT_STATIC_ALLOCATION == 1 )
void vApplicationGetIdleTaskMemory(StaticTask_t **ppxIdleTaskTCBBuffer,
        StackType_t **ppxIdleTaskStackBuffer, uint32_t *pulIdleTaskStackSize )
{
    static StaticTask_t IdleTaskTCBBuffer;
    static StackType_t IdleTaskStackBuffer[configMINIMAL_STACK_SIZE];
    *ppxIdleTaskTCBBuffer = &IdleTaskTCBBuffer;
    *ppxIdleTaskStackBuffer = IdleTaskStackBuffer;
    *pulIdleTaskStackSize = configMINIMAL_STACK_SIZE;
}

#if ( configUSE_TIMERS ==1 )
void vApplicationGetTimerTaskMemory(StaticTask_t **ppxTimerTaskTCBBuffer,
        StackType_t **ppxTimerTaskStackBuffer, uint32_t *pulTimerTaskStackSize)
{
    static StaticTask_t TimerTaskTCBBuffer;
    static StackType_t TimerTaskStackBuffer[configTIMER_TASK_STACK_DEPTH];
    *ppxTimerTaskTCBBuffer = &TimerTaskTCBBuffer;
    *ppxTimerTaskStackBuffer = TimerTaskStackBuffer;
    *pulTimerTaskStackSize = configTIMER_TASK_STACK_DEPTH;
}
#endif /* configUSE_TIMERS */
#endif /* configSUPPORT_STATIC_ALLOCATION */
