/*
 * Copyright (c) 2022 Intel Corporation, San Jose, California, USA.  
 * All rights reserved.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to 
 * deal in the Software without restriction, including without limitation the 
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 * sell copies of the Software, and to permit persons to whom the Software is 
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in 
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
 * DEALINGS IN THE SOFTWARE.
 * 
 * ------------
 *
 * Intel does not recommend, suggest or require that this reference design 
 * file be used in conjunction or combination with any other product.
 */

#include <limits.h>
#include <system.h>
#include <unistd.h>

#include "sys/alt_alarm.h"
#include "priv/alt_busy_sleep.h"
#include "os/alt_syscall.h"

#include "FreeRTOS.h"
#include "task.h"

/*
 * Macro defining the number of micoseconds in a second.
 */

#define ALT_US (1000000)

/*
 * This implementation of usleep overrides the default provided in the HAL/src
 * directory of the abbotts_lake component. When possible, this
 * implementation uses the FreeRTOS vTaskDelay function to block the current
 * thread, rather than using a busy loop. This allows other threads to execute 
 * while the current thread is sleeping.
 *
 * ALT_USLEEP is mapped onto the usleep() system call in alt_syscall.h 
 */

#if defined (__GNUC__) && __GNUC__ >= 4
int ALT_USLEEP (useconds_t us)
#else
unsigned int ALT_USLEEP (unsigned int us)
#endif
{
  alt_u32 ticks;
  alt_u32 tick_rate;
  /* 
   * If the O/S hasn't started yet, then we delay using a busy loop, rather than
   * vTaskDelay (since this would fail). The use of a busy loop is acceptable,
   * since the system is still running in a single-threaded mode.
   */ 

  if (taskSCHEDULER_NOT_STARTED == xTaskGetSchedulerState())
  {
    return alt_busy_sleep (us);
  }

  /* 
   * Calculate the number of whole system clock ticks to delay.
   */

  tick_rate = alt_ticks_per_second ();
  ticks     = (us/ALT_US)* tick_rate + ((us%ALT_US)*tick_rate)/ALT_US;

  /* For RISC-V 32-bit, vTaskDelay can support tick value up to 0xffffffffUL */
 vTaskDelay ((TickType_t) (ticks));

  /*
   * Now delay by the remainder using a busy loop. This is here in order to
   * provide very short delays of less than one clock tick.
   */

  alt_busy_sleep (us%(ALT_US/tick_rate));  

  return 0;  
}
