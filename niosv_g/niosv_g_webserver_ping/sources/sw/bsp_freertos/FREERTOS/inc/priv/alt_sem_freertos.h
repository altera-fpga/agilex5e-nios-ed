#ifndef __ALT_SEM_FREERTOS_H__
#define __ALT_SEM_FREERTOS_H__

/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2022 Intel Corporation, San Jose, California, USA.           *
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
 * This file provides the FreeRTOS specific functions used to implement the 
 * macros in alt_sem.h. These functions are simply wrappers for the FreeRTOS
 * flags API.
 *
 * These functions are considered to be part of the internal implementation of
 * the HAL, and should not be called directly by application code or device
 * drivers. They are not guaranteed to be preserved in future versions of the
 * HAL.
 */

#include "FreeRTOSConfig.h"
#include "FreeRTOS.h"
#include "semphr.h"
#include "os_cpu.h"

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */

typedef struct ALT_SEM_STRUCT
{
    SemaphoreHandle_t handle;
#if (configSUPPORT_STATIC_ALLOCATION == 1)
    StaticSemaphore_t buffer;
#endif
}alt_sem_t;

/*
 * alt_sem_create() is a wrapper for xSemaphoreCreateCounting()/xSemaphoreCreateCountingStatic().
 * The return value is 0 if the semaphore has been successfully created,
 * or non-zero otherwise.
 * configSUPPORT_DYNAMIC_ALLOCATION and configUSE_COUNTING_SEMAPHORES must be set
 * to 1 by default. Not doing so, there will be compile errors. 
 * -> configSUPPORT_DYNAMIC_ALLOCATION == 1 is needed for heap_x.c file.
 * -> configUSE_COUNTING_SEMAPHORES == 1 is needed for using xSemaphoreCreateCounting()
 *    or xSemaphoreCreateCountingStatic().
 * With both set to 1, dynamic version of semaphore will be used by default. If
 * configSUPPORT_STATIC_ALLOCATION is set to 1, static version of semepahore
 * will be used instead.
 */

static ALT_INLINE int ALT_ALWAYS_INLINE alt_sem_create (alt_sem_t* sem, 
              UBaseType_t value)
{ 
#if (configSUPPORT_STATIC_ALLOCATION == 1)
  sem->handle = xSemaphoreCreateCountingStatic(value, value, &sem->buffer);
#else
  sem->handle = xSemaphoreCreateCounting(value, value);
#endif
  return sem->handle ? 0 : -1;
} 

/*
 * alt_sem_pend() is a wrapper for xSemaphoreTake() or xSemaphoreTakeFromISR().
 * 
 */

static ALT_INLINE int ALT_ALWAYS_INLINE alt_sem_pend (alt_sem_t sem, 
                  TickType_t timeout)
{
  int ret = -1;
  BaseType_t xHigherPriorityTaskWoken = pdFALSE;

  if (IS_IN_ISR_CONTEXT()){
      if (pdTRUE == xSemaphoreTakeFromISR(sem.handle, &xHigherPriorityTaskWoken)){
        portYIELD_FROM_ISR(xHigherPriorityTaskWoken);
        ret = 0;
      }
  } else {
      // If timeout == 0, it is assumed that we don't want the timeout.
      timeout = timeout == 0 ? portMAX_DELAY : timeout;
      if ( pdTRUE == xSemaphoreTake(sem.handle, timeout)){
        ret = 0;
      }
  }
  return  ret;
}

/*
 * alt_sem_post() is a wrapper for xSemaphoreGive() or xSemaphoreGiveFromISR().
 */

static ALT_INLINE int ALT_ALWAYS_INLINE alt_sem_post (alt_sem_t sem)
{
  int ret = -1;
  BaseType_t xHigherPriorityTaskWoken = pdFALSE;

  if (IS_IN_ISR_CONTEXT()){
      if (pdTRUE == xSemaphoreGiveFromISR(sem.handle, &xHigherPriorityTaskWoken)){
        portYIELD_FROM_ISR(xHigherPriorityTaskWoken);
        ret = 0;
      }
  } else {
      if ( pdTRUE == xSemaphoreGive(sem.handle)){
        ret = 0;
      }
  }
  return  ret;
}

#ifdef __cplusplus
}
#endif

#endif /* __ALT_SEM_FREERTOS_H__ */
