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

#include "alt_types.h"
#include "system.h"
#include "alt_niosv_int_mode.h"

/*
 * Compiles the vectored interrupt codes only if Nios V interrupt mode
 * is set to Vectored Interrupt mode.
 */
#ifdef ALT_CPU_INT_MODE
#if (ALT_CPU_INT_MODE == ALT_CPU_INT_MODE_VIC)

#include "intel_niosv.h"
#include "sys/alt_exceptions.h"
#include "sys/alt_irq.h"
#include "sys/msw_interrupt.h"
#include "priv/alt_exception_handler_registry.h"
#include "priv/alt_irq_table.h"


/* Exception break. */
#ifdef ALT_CPU_HAS_DEBUG_STUB
    #define ALT_VIC_EXCEPTIONS_BREAK()      do { __asm__ volatile("ebreak"); } while (0)
#else
    #define ALT_VIC_EXCEPTIONS_BREAK()      do { ; } while(1)
#endif /* ALT_CPU_HAS_DEBUG_STUB */

/* Spurious interrupt handling. */
#ifdef ALT_CPU_HAS_DEBUG_STUB
    #define ALT_VIC_SPURIOUS_IRQ()          do { __asm__ volatile("ebreak"); } while (0)
#else
    #define ALT_VIC_SPURIOUS_IRQ()          do { ; } while(1)
#endif /* ALT_CPU_HAS_DEBUG_STUB */

/*
 * The first 16 interrupts are reserved for the processor for interrupts such as
 * supervisor/machine software, timer, external, counter-overflow interrupts.
 * The subsequent 16 interrupts are designated for platform uses.
 */
enum alt_vic_platform_irq_number {
    ALT_VIC_PLATFORM_IRQ_00 = 0,
    ALT_VIC_PLATFORM_IRQ_01,
    ALT_VIC_PLATFORM_IRQ_02,
    ALT_VIC_PLATFORM_IRQ_03,
    ALT_VIC_PLATFORM_IRQ_04,
    ALT_VIC_PLATFORM_IRQ_05,
    ALT_VIC_PLATFORM_IRQ_06,
    ALT_VIC_PLATFORM_IRQ_07,
    ALT_VIC_PLATFORM_IRQ_08,
    ALT_VIC_PLATFORM_IRQ_09,
    ALT_VIC_PLATFORM_IRQ_10,
    ALT_VIC_PLATFORM_IRQ_11,
    ALT_VIC_PLATFORM_IRQ_12,
    ALT_VIC_PLATFORM_IRQ_13,
    ALT_VIC_PLATFORM_IRQ_14,
    ALT_VIC_PLATFORM_IRQ_15,
#if !(__riscv_xlen == 32)
/* Default to 64-bit cpu, support up to 48 platform-specific interrupts. */
    ALT_VIC_PLATFORM_IRQ_16,
    ALT_VIC_PLATFORM_IRQ_17,
    ALT_VIC_PLATFORM_IRQ_18,
    ALT_VIC_PLATFORM_IRQ_19,
    ALT_VIC_PLATFORM_IRQ_20,
    ALT_VIC_PLATFORM_IRQ_21,
    ALT_VIC_PLATFORM_IRQ_22,
    ALT_VIC_PLATFORM_IRQ_23,
    ALT_VIC_PLATFORM_IRQ_24,
    ALT_VIC_PLATFORM_IRQ_25,
    ALT_VIC_PLATFORM_IRQ_26,
    ALT_VIC_PLATFORM_IRQ_27,
    ALT_VIC_PLATFORM_IRQ_28,
    ALT_VIC_PLATFORM_IRQ_29,
    ALT_VIC_PLATFORM_IRQ_30,
    ALT_VIC_PLATFORM_IRQ_31,
    ALT_VIC_PLATFORM_IRQ_32,
    ALT_VIC_PLATFORM_IRQ_33,
    ALT_VIC_PLATFORM_IRQ_34,
    ALT_VIC_PLATFORM_IRQ_35,
    ALT_VIC_PLATFORM_IRQ_36,
    ALT_VIC_PLATFORM_IRQ_37,
    ALT_VIC_PLATFORM_IRQ_38,
    ALT_VIC_PLATFORM_IRQ_39,
    ALT_VIC_PLATFORM_IRQ_40,
    ALT_VIC_PLATFORM_IRQ_41,
    ALT_VIC_PLATFORM_IRQ_42,
    ALT_VIC_PLATFORM_IRQ_43,
    ALT_VIC_PLATFORM_IRQ_44,
    ALT_VIC_PLATFORM_IRQ_45,
    ALT_VIC_PLATFORM_IRQ_46,
    ALT_VIC_PLATFORM_IRQ_47,
#endif /* !(__riscv_xlen == 32) */
};

/*
 * The Vectored Interrupt Controller's vector table functions are assigned with
 * the "interrupt" compiler attribute so that compiler generates the assembly
 * codes for context saving and restoring, and uses the correct return
 * e.g. mret, sret or uret.
 */
void alt_vic_exception_handler(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_mtimer_isr(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_msw_isr(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq0(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq1(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq2(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq3(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq4(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq5(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq6(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq7(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq8(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq9(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq10(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq11(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq12(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq13(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq14(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq15(void) __attribute__ ((interrupt ("machine"), weak));

#if !(__riscv_xlen == 32)
/* Default to 64-bit cpu, support up to 48 platform-specific interrupts. */
void alt_vic_platform_irq16(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq17(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq18(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq19(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq20(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq21(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq22(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq23(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq24(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq25(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq26(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq27(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq28(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq29(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq30(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq31(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq32(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq33(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq34(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq35(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq36(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq37(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq38(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq39(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq40(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq41(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq42(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq43(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq44(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq45(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq46(void) __attribute__ ((interrupt ("machine"), weak));
void alt_vic_platform_irq47(void) __attribute__ ((interrupt ("machine"), weak));
#endif /* !(__riscv_xlen == 32) */

/*
 * This is an example of the exception handler function.
 * Please handle the exceptions based on your needs.
 */
void alt_vic_exception_handler(void)
{
    alt_u32 exception, pc;

    NIOSV_READ_CSR(NIOSV_MEPC_CSR, pc);
    NIOSV_READ_CSR(NIOSV_MCAUSE_CSR, exception);

#ifdef ALT_INCLUDE_INSTRUCTION_RELATED_EXCEPTION_API
    /* If user register own exception via 'alt_instruction_exception_register' */
    if (alt_instruction_exception_handler) {
        if (alt_instruction_exception_handler(exception, 0, 0) != NIOSV_EXCEPTION_RETURN_REISSUE_INST)
            /* Skip the instruction that triggered the exception. */
            NIOSV_WRITE_CSR(NIOSV_MEPC_CSR, pc+4);
    }

    /* Default exception handling. */
    else
#endif /* ALT_INCLUDE_INSTRUCTION_RELATED_EXCEPTION_API */
    {
        switch (exception) {
            case NIOSV_INSTRUCTION_ADDRESS_MISALIGNED:
                ALT_VIC_EXCEPTIONS_BREAK();
                break;
            case NIOSV_INSTRUCTION_ACCESS_FAULT:
                ALT_VIC_EXCEPTIONS_BREAK();
                break;
            case NIOSV_ILLEGAL_INSTRUCTION:
                ALT_VIC_EXCEPTIONS_BREAK();
                break;
            case NIOSV_BREAKPOINT:
                ALT_VIC_EXCEPTIONS_BREAK();
                break;
            case NIOSV_LOAD_ADDRESS_MISALIGNED:
                ALT_VIC_EXCEPTIONS_BREAK();
                break;
            case NIOSV_LOAD_ACCESS_FAULT:
                ALT_VIC_EXCEPTIONS_BREAK();
                break;
            case NIOSV_STORE_AMO_ADDRESS_MISALIGNED:
                ALT_VIC_EXCEPTIONS_BREAK();
                break;
            case NIOSV_STORE_AMO_ACCESS_FAULT:
                ALT_VIC_EXCEPTIONS_BREAK();
                break;
            case NIOSV_ENVIRONMENT_CALL_FROM_U_MODE:
                ALT_VIC_EXCEPTIONS_BREAK();
                break;
            case NIOSV_ENVIRONMENT_CALL_FROM_S_MODE:
                ALT_VIC_EXCEPTIONS_BREAK();
                break;
            case NIOSV_ENVIRONMENT_CALL_FROM_M_MODE:
                ALT_VIC_EXCEPTIONS_BREAK();
                break;
            case NIOSV_INSTRUCTION_PAGE_FAULT:
                ALT_VIC_EXCEPTIONS_BREAK();
                break;
            case NIOSV_LOAD_PAGE_FAULT:
                ALT_VIC_EXCEPTIONS_BREAK();
                break;
            case NIOSV_STORE_AMO_PAGE_FAULT:
                ALT_VIC_EXCEPTIONS_BREAK();
                break;

            /* Undefined exceptions. */
            default:
                ALT_VIC_EXCEPTIONS_BREAK();
                break;
        }
    }
}

/*
 * This is an example of the machine timer isr wrapper.
 * This is intended to work-around the issue of passing argument into the isr as
 * arguments can't be passed into the isr via the vector table.
 * With this work-around, the original machine timer isr code is maintained.
 * User can replace this function with their implementation of machine
 * timer isr.
 */
void alt_vic_mtimer_isr(void)
{
    alt_niosv_timer_sc_isr(0,0,0);
}

/*
 * This is an example of the machine software isr wrapper.
 * This is intended to work-around the issue of passing argument into the isr as
 * arguments can't be passed into the isr via the vector table.
 * With this work-around, the original machine software isr code is maintained.
 * User can replace this function with their implementation of machine
 * software isr.
 */
void alt_vic_msw_isr(void)
{
    if (alt_niosv_software_interrupt_handler)
        alt_niosv_software_interrupt_handler(0,0,0);
}

/*
 * This is an example of the interrupt service routine for platform irq.
 * The platform isr is being registered as normal via the function
 * 'alt_ic_isr_register', then being invoked by this wrapper when
 * Vectored Interrupt Mode is enabled in Nios V.
 * If there is an interrupt occured without an isr being assigned to it,
 * it enters the 'spurious irq' state.
 */
void alt_vic_platform_irq0(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_00;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq1(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_01;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq2(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_02;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq3(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_03;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq4(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_04;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq5(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_05;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq6(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_06;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq7(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_07;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq8(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_08;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq9(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_09;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq10(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_10;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq11(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_11;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq12(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_12;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq13(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_13;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq14(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_14;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq15(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_15;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

#if !(__riscv_xlen == 32)
/* Default to 64-bit cpu, support up to 48 platform-specific interrupts. */

void alt_vic_platform_irq16(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_16;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}
void alt_vic_platform_irq17(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_17;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq18(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_18;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq19(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_19;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq20(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_20;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq21(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_21;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq22(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_22;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq23(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_23;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq24(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_24;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq25(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_25;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq26(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_26;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq27(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_27;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq28(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_28;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq29(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_29;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq30(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_30;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq31(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_31;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq32(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_32;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq33(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_33;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq34(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_34;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq35(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_35;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq36(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_36;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq37(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_37;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq38(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_38;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq39(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_39;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq40(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_40;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq41(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_41;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq42(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_42;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq43(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_43;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq44(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_44;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq45(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_45;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq46(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_46;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}

void alt_vic_platform_irq47(void)
{
    const alt_u8 i = ALT_VIC_PLATFORM_IRQ_47;

    if (alt_irq[i].handler)
        alt_irq[i].handler(alt_irq[i].context);
    else
        ALT_VIC_SPURIOUS_IRQ();
}
#endif /* !(__riscv_xlen == 32) */

#endif /* ALT_CPU_INT_MODE == ALT_CPU_INT_MODE_VIC */
#endif /* ALT_CPU_INT_MODE */
