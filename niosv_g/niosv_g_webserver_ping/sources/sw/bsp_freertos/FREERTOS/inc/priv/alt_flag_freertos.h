#ifndef __ALT_FLAG_FREERTOS_H__
#define __ALT_FLAG_FREERTOS_H__

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
 * macros in alt_flag.h. These functions are simply wrappers for the FreeRTOS
 * flags API.
 *
 * These functions are considered to be part of the internal implementation of
 * the HAL, and should not be called directly by application code or device
 * drivers. They are not guaranteed to be preserved in future versions of the
 * HAL.
 */

#include "FreeRTOSConfig.h"
#include "FreeRTOS.h"
#include "event_groups.h"
#include "os_cpu.h"

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */

typedef struct ALT_FLAG_STRUCT
{
    EventGroupHandle_t handle;
#if (configSUPPORT_STATIC_ALLOCATION == 1)
    StaticEventGroup_t buffer;
#endif
}alt_flag_t;

/*
 * alt_flag_create() is a wrapper for xEventGroupCreate()/xEventGroupCreateStatic(),
 * with the error code converted into the functions return value.
 */

static ALT_INLINE int ALT_ALWAYS_INLINE alt_flag_create (alt_flag_t* pgroup)
{
#if (configSUPPORT_STATIC_ALLOCATION == 1)
  pgroup->handle = xEventGroupCreateStatic(&pgroup->buffer);
#else
  pgroup->handle = xEventGroupCreate();
#endif
  return pgroup->handle != NULL? 0 : -1;
}

/*
 * alt_flag_pend() is a wrapper for xEventGroupWaitBits(), with the error code 
 * converted into the functions return value.
 */

static ALT_INLINE int ALT_ALWAYS_INLINE alt_flag_pend (alt_flag_t group, 
                   EventBits_t flags, 
                   BaseType_t  wait_types,
                   TickType_t  timeout)
{
  int ret = 0;
  EventBits_t uxBits;
  if (taskSCHEDULER_NOT_STARTED != xTaskGetSchedulerState())
  {
    // If timeout == 0, it is assumed that we don't want the timeout.
    timeout  = timeout == 0 ? portMAX_DELAY : timeout;
    uxBits = xEventGroupWaitBits(group.handle, flags, ( wait_types & 0x2 ) >> 1,
                                ( wait_types & 0x1 ), timeout);
    ret = uxBits & flags? 0 : -1;
  }
  return ret;
}

/*
 * alt_flag_post() is a wrapper for xEventGroup[Set|Clear]Bits() or
 * xEventGroup[Set|Clear]BitsFromISR().
 */

static ALT_INLINE int ALT_ALWAYS_INLINE alt_flag_post (alt_flag_t group, 
                   EventBits_t     flags, 
                   uint8_t        opt)
{
  BaseType_t xHigherPriorityTaskWoken = pdFALSE;
  if (taskSCHEDULER_NOT_STARTED != xTaskGetSchedulerState())
  {
    if (IS_IN_ISR_CONTEXT()){
      if (opt == 1){ 
        if ( pdTRUE == xEventGroupSetBitsFromISR(group.handle, flags, &xHigherPriorityTaskWoken)){
          portYIELD_FROM_ISR(xHigherPriorityTaskWoken);
        }
      } else {
        xEventGroupClearBitsFromISR(group.handle, flags);     
      }
    } else {
      if (opt == 1){ 
        xEventGroupSetBits(group.handle, flags);
      } else {
        xEventGroupClearBits(group.handle, flags);     
      }      
    }
  }
  return 0;
}

#ifdef __cplusplus
}
#endif

#endif /* __ALT_FLAG_FREERTOS_H__ */
