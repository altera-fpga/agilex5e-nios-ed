/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2022 Intel Corporation, San Jose, California, USA.            *
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
******************************************************************************/

/*
 * These are the env lock/unlock stubs required by newlib. These are 
 * used to make accesses to environment variables thread safe. Note that 
 * this implementation requires that environment variables are never manipulated 
 * by an interrupt service routine.
 */

#include "FreeRTOS.h"
#include "semphr.h"
#include <reent.h>
#include "system.h"

/* semaphore to protect the environment */
SemaphoreHandle_t alt_envsem;

#if(OS_THREAD_SAFE_C_LIBRARY > 0)
/* id of the task that is currently manipulating the heap */
static int lockid = -1;

/* number of times __malloc_lock has recursed */
static int locks;
#endif /* OS_THREAD_SAFE_C_LIBRARY */

void __env_lock ( struct _reent *_r )
{
#if(OS_THREAD_SAFE_C_LIBRARY > 0)
  TaskStatus_t xTaskDetails;
  int id;
  int semcnt;

  if (taskSCHEDULER_NOT_STARTED == xTaskGetSchedulerState())
      return;

  /* Get the current task's status information. */
  vTaskGetInfo(
            /* Query this task. */
            NULL,
            &xTaskDetails,
            /* Don't include the stack high water mark value. */
            pdFALSE,
            /* Don't include the task state in the TaskStatus_t structure. */
            0 );

  /* Use task number as the task id */
  id = ( int )xTaskDetails.xTaskNumber;
   
  /* See if we own the heap already by checking the semaphore counter.
   * If the counter is 0, that means we own the heap now.
   */
  semcnt = ( int )uxSemaphoreGetCount( alt_envsem );

  if( semcnt == 0 && id == lockid ) 
  {
    /* We do; just count the recursion */
    locks++;
  }
  else 
  {
    /* Wait on the other task to yield the heap, then claim ownership of it */
    xSemaphoreTake( alt_envsem, 0);
    locks  = 1;
    lockid = id;
  }
#endif /* OS_THREAD_SAFE_C_LIBRARY */
}

void __env_unlock ( struct _reent *_r )
{
#if(OS_THREAD_SAFE_C_LIBRARY > 0)

  if (taskSCHEDULER_NOT_STARTED == xTaskGetSchedulerState())
      return;

  if (locks == 0)
    return;

  /* release the heap once the number of locks == the number of unlocks */
  if( (--locks) == 0 ) 
  {
    lockid = -1;
    xSemaphoreGive( alt_envsem );
  }
#endif /* OS_THREAD_SAFE_C_LIBRARY */
}
