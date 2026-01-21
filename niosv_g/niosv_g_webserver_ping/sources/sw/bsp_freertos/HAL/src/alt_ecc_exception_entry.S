/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2024 Altera Corporation, San Jose, California, USA.      *
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
 * This is for handling ECC exception. The code is pulled in at the beginning
 * of trap_vector when ALT_CPU_ECC_PRESENT is defined (ECC Full is enabled).
 */

#include "system.h"

#ifdef ALT_CPU_ECC_PRESENT
    .equ EXCEPTION_HARDWARE_ERROR, 19
    .equ ALT_ECC_INJECT, 0x7C0
    .equ ALT_ECC_STATUS, 0x7C1

    .section .exceptions.entry.ecc_fatal, "xa"
    .align 2

    /*
     * Linker may optimize out this section if no code explicitly references it.
     * A strong reference is maintained in alt_ecc_exception.c to ensure this
     * critical error handler is preserved when ALT_CPU_ECC_PRESENT is defined.
     */
    .globl __alt_ecc_fatal_handler_start
    __alt_ecc_fatal_handler_start:

    /* Clear the alt_ecc_inject CSR */
    csrwi ALT_ECC_INJECT, 0

    /* Flush the CPU pipeline as there will be other instructions with
     * the ECC-exception bit set in the CPU pipe.
     */
    fence.i

    /* save t0 into mscratch */
    csrw mscratch, t0

    /* mcause == 19 is ECC exception */
    csrr t0, mcause
    addi t0, t0, -EXCEPTION_HARDWARE_ERROR
    bnez t0, alt_not_ecc_exception

    /* mtval2 contains the source and type of the ECC error */
    /* check LSB to differentiate between correctable/non-correctable */
    csrr t0, mtval2
    andi t0, t0, 1
    bnez t0, alt_ecc_uncorrectable_exception

    /*
      Correctable ECC Exception
     */
alt_ecc_correctable_exception:
    /* check mtval2 for source of the ecc error */

    /* GPR correctable ecc exception*/
alt_ecc_gpr_correctable_exception:
    /* mtval contains faulting register number */
    csrr t0, mtval

    /* binary decision tree (using only 1 variable)
       to figure out which register to fix */
    addi t0, t0, -16
    bgez t0, alt_ecc_correct_x16_x31

    /* x0 - x15 */
alt_ecc_correct_x0_x15:
    /* t0 now holds -16..-1 representing x0..x15 */
    addi t0, t0, 8
    bgez t0, alt_ecc_correct_x8_x15

    /* x0 - x7 */
alt_ecc_correct_x0_x7:
    /* t0 now holds -8..-1 representing x0..x7 */
    addi t0, t0, 4
    bgez t0, alt_ecc_correct_x4_x7

alt_ecc_correct_x0_x3:
    /* It takes 5 instructions to determine the exact
       failing register and correcting it
       It only takes 4 instructions to correct a quad */
    ori x1, x1, 0
    ori x2, x2, 0
    ori x3, x3, 0
    j alt_ecc_correctable_exception_done

alt_ecc_correct_x4_x7:
    ori x4, x4, 0
    ori x5, x5, 0
    ori x6, x6, 0
    ori x7, x7, 0
    j alt_ecc_correctable_exception_done

    /* x8 - x15 */
alt_ecc_correct_x8_x15:
    /* t0 now holds 0..7 representing x8..x15 */
    addi t0, t0, -4
    bgez t0, alt_ecc_correct_x12_x15

alt_ecc_correct_x8_x11:
    ori x8, x8, 0
    ori x9, x9, 0
    ori x10, x10, 0
    ori x11, x11, 0
    j alt_ecc_correctable_exception_done

alt_ecc_correct_x12_x15:
    ori x12, x12, 0
    ori x13, x13, 0
    ori x14, x14, 0
    ori x15, x15, 0
    j alt_ecc_correctable_exception_done

    /* x16 - x31 */
alt_ecc_correct_x16_x31:
    /* t0 now holds 0..15 representing x16..x31 */
    addi t0, t0, -8
    bgez t0, alt_ecc_correct_x24_x31

    /* x16 - x23 */
alt_ecc_correct_x16_x23:
    /* t0 now holds -8..-1 representing x16..x23 */
    addi t0, t0, 4
    bgez t0, alt_ecc_correct_x20_x23

alt_ecc_correct_x16_x19:
    ori x16, x16, 0
    ori x17, x17, 0
    ori x18, x18, 0
    ori x19, x19, 0
    j alt_ecc_correctable_exception_done

alt_ecc_correct_x20_x23:
    ori x20, x20, 0
    ori x21, x21, 0
    ori x22, x22, 0
    ori x23, x23, 0
    j alt_ecc_correctable_exception_done

    /* x24 - x31 */
alt_ecc_correct_x24_x31:
    /* t0 now holds 0..7 representing x24..x31 */
    addi t0, t0, -4
    bgez t0, alt_ecc_correct_x28_x31

alt_ecc_correct_x24_x27:
    ori x24, x24, 0
    ori x25, x25, 0
    ori x26, x26, 0
    ori x27, x27, 0
    j alt_ecc_correctable_exception_done

alt_ecc_correct_x28_x31:
    ori x28, x28, 0
    ori x29, x29, 0
    ori x30, x30, 0
    ori x31, x31, 0

alt_ecc_correctable_exception_done:
    /* re-enable ECC exceptions */
    lui  t0, 0x80000
    csrs ALT_ECC_STATUS, t0

    /* restore t0 and return */
    csrr t0, mscratch
    mret

    /*
      End of Correctable ECC Exception
     */


    /* Load alt_ecc_exception_handler value/address */
alt_ecc_uncorrectable_exception:
    lui t0, %hi(alt_ecc_exception_handler)
    lw t0, %lo(alt_ecc_exception_handler)(t0)

    /* Check if alt_ecc_exception_handler is not zero */
    bnez t0, jump_to_ecc_handler

    /* If alt_ecc_fatal_exception_handler is zero (the handler is not
     * registered), the operation must stop here.
     */
    ebreak

jump_to_ecc_handler:
    /* Jump to t0 to invoke alt_ecc_exception_handler.
     * The ra register woudn't be modified as we expect the handler wouldn't
     * return. If it does return, the operation must stop here.
     */
    jalr x0, t0
    ebreak

    /* If the handler able to correct/recover the error, adding jump operation to
     * this label (j alt_not_ecc_exception) to continue normal exception operation.
     */
.globl alt_not_ecc_exception
alt_not_ecc_exception:
    /* Restore t0 */
    csrr t0, mscratch

    /*
     * There is a concrete alt_ecc_exception_register() function implemented in
     * alt_ecc_error_inject.c. By doing this, it tells linker that above code need
     * to be pulled in at the beggining of trap_vector and included in the
     * compilation.
     */
.weak alt_ecc_exception_register
alt_ecc_exception_register:

#endif /*ALT_CPU_ECC_PRESENT*/
