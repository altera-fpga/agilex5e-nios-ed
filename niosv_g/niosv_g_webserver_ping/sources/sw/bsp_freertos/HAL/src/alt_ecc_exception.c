/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2024 Altera Corporation, San Jose, California, USA.           *
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
#include "sys/alt_ecc_exception.h"
#include "io.h"
#include "sys/alt_cache.h"
#include "system.h"

#ifdef ALT_CPU_ECC_PRESENT

/*
 * Force linker to include the ECC exception handler section. This creates a 
 * permanent reference to the handler code, preventing it from being optimized out
 * even if alt_ecc_exception_register() is never called.
 */
extern char __alt_ecc_fatal_handler_start[];
/* Create a strong reference that can't be optimized away. */
const void *__force_ecc_fatal_handler __attribute__ ((used)) =
    __alt_ecc_fatal_handler_start;

/* 
 * Global variable containing address to jump to when likely fatal
 * ECC error exception occurs.
 */
alt_u32 alt_ecc_exception_handler = 0x0;

/*
 * This file implements support for calling a user-registered handler
 * when a likely fatal ECC error exception occurs.
 */

/*
 * alt_ecc_fatal_exception_register() is called to register a handler to
 * service likely fatal ECC error exceptions. 
 * 
 * Passing null (0x0) in the handler argument will disable a previously-
 * registered handler.
 *
 * Note that if no handler is registered, just normal exception processing
 * occurs on a likely fatal ECC exception and it is possible that the exception
 * processing code might trigger an infinite exception loop.
 */

void alt_ecc_exception_register(alt_u32 handler)
{
	alt_ecc_exception_handler = handler;

    /* 
     * Flush this from the cache.
     */
    alt_dcache_flush(&alt_ecc_exception_handler, sizeof(alt_ecc_exception_handler));
}

#endif
