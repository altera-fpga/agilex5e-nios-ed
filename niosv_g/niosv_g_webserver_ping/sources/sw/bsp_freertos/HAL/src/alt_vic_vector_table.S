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
*                                                                             *
******************************************************************************/

#include "system.h"
#include "alt_niosv_int_mode.h"

/*
 * Compiles the vectored interrupt codes only if Nios V interrupt mode
 * is set to Vectored Interrupt mode.
 */

#ifdef ALT_CPU_INT_MODE
#if (ALT_CPU_INT_MODE == ALT_CPU_INT_MODE_VIC)

/*
 * This is an example of the Nios V's Vectored Interrupt Controller jump table.
 * Every single entry/line is a 'jump' to the isr assigned in the entry.
 * User can replace the existing interrupt service routine to tailor its
 * behavior for their specific needs or requirement.
 *
 * The alignment is chosen to suit the HW implementation which is designed to
 * construct the target address by bitmasking rather than addition. 
 *
 * 'No operation' loop is used as stub function for entries that don't have
 * it's designated interrupt service routine.
 */
    .section .text, "xa"
#if !(__riscv_xlen == 32)
    /* Assuming 64-bit system. */
    .align 8
#else
    .align 7
#endif /* !(__riscv_xlen == 32) */
    .globl VIC_VECTOR_TABLE

VIC_VECTOR_TABLE:
    "jal zero, alt_vic_exception_handler"   /* Synchronous exception.         */
    "jal zero, nop"                         /* Supervisor software interrupt. */
    "jal zero, nop"                         /* Reserved.                      */
    "jal zero, alt_vic_msw_isr"             /* Machine software interrupt.    */
    "jal zero, nop"                         /* Reserved.                      */
    "jal zero, nop"                         /* Supervisor timer interrupt.    */
    "jal zero, nop"                         /* Reserved.                      */
    "jal zero, alt_vic_mtimer_isr"          /* Machine timer interrupt.       */
    "jal zero, nop"                         /* Reserved.                      */
    "jal zero, nop"                         /* Supervisor external interrupt. */
    "jal zero, nop"                         /* Reserved.                      */
    "jal zero, nop"                         /* Machine external interrupt.    */
    "jal zero, nop"                         /* Reserved.                      */
    "jal zero, nop"                         /* Counter-overflow interrupt.    */
    "jal zero, nop"                         /* Reserved.                      */
    "jal zero, nop"                         /* Reserved.                      */

    /* Platform-specific interrupts (16-31). */
    "jal zero, alt_vic_platform_irq0"
    "jal zero, alt_vic_platform_irq1"
    "jal zero, alt_vic_platform_irq2"
    "jal zero, alt_vic_platform_irq3"
    "jal zero, alt_vic_platform_irq4"
    "jal zero, alt_vic_platform_irq5"
    "jal zero, alt_vic_platform_irq6"
    "jal zero, alt_vic_platform_irq7"
    "jal zero, alt_vic_platform_irq8"
    "jal zero, alt_vic_platform_irq9"
    "jal zero, alt_vic_platform_irq10"
    "jal zero, alt_vic_platform_irq11"
    "jal zero, alt_vic_platform_irq12"
    "jal zero, alt_vic_platform_irq13"
    "jal zero, alt_vic_platform_irq14"
    "jal zero, alt_vic_platform_irq15"
#if !(__riscv_xlen == 32)
    /* Default to 64-bit cpu, support up to 48 platform-specific interrupts. */
    "jal zero, alt_vic_platform_irq16"
    "jal zero, alt_vic_platform_irq17"
    "jal zero, alt_vic_platform_irq18"
    "jal zero, alt_vic_platform_irq19"
    "jal zero, alt_vic_platform_irq20"
    "jal zero, alt_vic_platform_irq21"
    "jal zero, alt_vic_platform_irq22"
    "jal zero, alt_vic_platform_irq23"
    "jal zero, alt_vic_platform_irq24"
    "jal zero, alt_vic_platform_irq25"
    "jal zero, alt_vic_platform_irq26"
    "jal zero, alt_vic_platform_irq27"
    "jal zero, alt_vic_platform_irq28"
    "jal zero, alt_vic_platform_irq29"
    "jal zero, alt_vic_platform_irq30"
    "jal zero, alt_vic_platform_irq31"
    "jal zero, alt_vic_platform_irq32"
    "jal zero, alt_vic_platform_irq33"
    "jal zero, alt_vic_platform_irq34"
    "jal zero, alt_vic_platform_irq35"
    "jal zero, alt_vic_platform_irq36"
    "jal zero, alt_vic_platform_irq37"
    "jal zero, alt_vic_platform_irq38"
    "jal zero, alt_vic_platform_irq39"
    "jal zero, alt_vic_platform_irq40"
    "jal zero, alt_vic_platform_irq41"
    "jal zero, alt_vic_platform_irq42"
    "jal zero, alt_vic_platform_irq43"
    "jal zero, alt_vic_platform_irq44"
    "jal zero, alt_vic_platform_irq45"
    "jal zero, alt_vic_platform_irq46"
    "jal zero, alt_vic_platform_irq47"
#endif /* (__riscv_xlen != 32) */

.globl nop
nop:
    j nop                    # No operation (self-jump)

#endif /* ALT_CPU_INT_MODE == ALT_CPU_INT_MODE_VIC */
#endif /* ALT_CPU_INT_MODE */
