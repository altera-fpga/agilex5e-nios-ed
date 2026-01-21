/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2009      Altera Corporation, San Jose, California, USA.      *
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

#include "sys/alt_irq.h"
#include "sys/alt_exceptions.h"
#include "sys/alt_log_printf.h"

#include "os/alt_hooks.h"

#include "alt_types.h"
#include "system.h"

#if ALT_CPU_HAS_CSR_SUPPORT

alt_niosv_sw_isr_t alt_niosv_software_interrupt_handler;
alt_niosv_timer_isr_t alt_niosv_timer_interrupt_handler;

#ifdef ALT_INCLUDE_INSTRUCTION_RELATED_EXCEPTION_API
/* Function pointer to exception callback routine */
alt_exception_result (*alt_instruction_exception_handler)
  (alt_exception_cause, alt_u32, alt_u32) = 0x0;

#endif /* ALT_INCLUDE_INSTRUCTION_RELATED_EXCEPTION_API */

#ifdef ALT_CPU_ECC_PRESENT
extern alt_u32 alt_ecc_exception_handler;
#endif

alt_u32 is_ecc_handler_present (alt_u32 e_code) __attribute__ ((section (".exceptions")));
void break_operation (void) __attribute__ ((section (".exceptions")));
void alt_irq_handler (void) __attribute__ ((section (".exceptions")));
alt_u32 handle_trap(alt_u32 cause, alt_u32 epc, alt_u32 tval) __attribute__ ((section (".exceptions")));
#if defined(ALT_CPU_CLIC_EN) && ALT_CPU_CLIC_EN
void clic_handle_standard_interrupt(alt_u32 exception_code, alt_u32 epc) __attribute__ ((section (".exceptions")));
void clic_handle_default_vt_interrupt() __attribute__ ((interrupt, section(".exceptions")));
#endif

alt_u32 handle_trap(alt_u32 cause, alt_u32 epc, alt_u32 tval)
{
    alt_u32 is_irq, exception_code;

    is_irq = (cause & NIOSV_MCAUSE_INTERRUPT_MASK);
    exception_code = (cause & ~NIOSV_MCAUSE_INTERRUPT_MASK);

    if (is_irq) {
        switch (exception_code) {
            case NIOSV_TIMER_IRQ:
            {
                if (alt_niosv_timer_interrupt_handler) {
                    ALT_OS_INT_ENTER();
                    alt_niosv_timer_interrupt_handler(cause, epc, tval);
                    ALT_OS_INT_EXIT();
                }
                break;
            }
            case NIOSV_SOFTWARE_IRQ:
            {
                if (alt_niosv_software_interrupt_handler) {
                    ALT_OS_INT_ENTER();
                    alt_niosv_software_interrupt_handler(cause, epc, tval);
                    ALT_OS_INT_EXIT();
                }
                break;
            }
            default:
            {
                if (exception_code >= 16) {
                    alt_irq_handler();
                } else {
                    ALT_LOG_PRINTF("invalid exception code: %d, epc = %d, tval = %d\n", exception_code, epc, tval);
                }
                break;
            }
        };
    } else {
#ifdef ALT_INCLUDE_INSTRUCTION_RELATED_EXCEPTION_API
        if (alt_instruction_exception_handler) {
            alt_exception_result handler_rc = alt_instruction_exception_handler(exception_code, epc, tval);
            epc = (handler_rc == NIOSV_EXCEPTION_RETURN_REISSUE_INST) ? epc : (epc + 4);
        }  else {
            if (!is_ecc_handler_present(exception_code)) {
                break_operation();
            } 
        }
#else  // ALT_INCLUDE_INSTRUCTION_RELATED_EXCEPTION_API
        if (!is_ecc_handler_present(exception_code)) {
             break_operation();
        } 
#endif // ALT_INCLUDE_INSTRUCTION_RELATED_EXCEPTION_API
    }

    return epc;
}

alt_u32 is_ecc_handler_present (alt_u32 e_code) {
#ifdef ALT_CPU_ECC_PRESENT
    alt_u32 present = (e_code == NIOSV_ECC_EXCEPTION && alt_ecc_exception_handler);
#else
    alt_u32 present = 0;
#endif
    return present;
} 

void break_operation (void)
{
#ifdef ALT_CPU_HAS_DEBUG_STUB
            NIOSV_EBREAK();
#else  // ALT_CPU_HAS_DEBUG_STUB
            while(1)
                ;
#endif // ALT_CPU_HAS_DEBUG_STUB  
}

/*
 * A table describing each interrupt handler. The index into the array is the
 * interrupt id associated with the handler. 
 *
 * When an interrupt occurs, the associated handler is called with
 * the argument stored in the context member.
 * 
 * Other modules access this table via the declaration in priv/alt_irq_table.h
 */

struct ALT_IRQ_HANDLER
{
  void (*handler)(void*);
  void *context;
} alt_irq[ALT_NIRQ];

/*
 * alt_irq_handler() is called by the interrupt exception handler in order to 
 * process any outstanding CLINT platform interrupts. 
 *
 * It is defined here since it is linked in using weak linkage. 
 * This means that if there is never a call to alt_irq_register() then
 * this function will not get linked in to the executable. This is acceptable
 * since if no handler is ever registered, then an interrupt can never occur.
 * 
 * This function is not relevant to CLINT vectored or CLIC interrupt handling modes. 
 */
void alt_irq_handler (void)
{
    alt_u32 active;
    alt_u32 mask;
    alt_u32 i;

    /*
     * Notify the operating system that we are at interrupt level.
     */  
    ALT_OS_INT_ENTER();

    /* 
     * Obtain from the interrupt controller a bit list of pending interrupts,
     * and then process the highest priority interrupt. This process loops, 
     * loading the active interrupt list on each pass until alt_irq_pending() 
     * return zero.
     * 
     * The maximum interrupt latency for the highest priority interrupt is
     * reduced by finding out which interrupts are pending as late as possible.
     * Consider the case where the high priority interupt is asserted during
     * the interrupt entry sequence for a lower priority interrupt to see why
     * this is the case.
     */
    active = alt_irq_pending();

    do
    {
        i = 0;
        mask = 1;

        /*
         * Test each bit in turn looking for an active interrupt. Once one is 
         * found, the interrupt handler asigned by a call to alt_irq_register() is
         * called to clear the interrupt condition.
         */

        do
        {
            if (active & mask)
            {
                alt_irq[i].handler(alt_irq[i].context); 
                break;
            }
            
            mask <<= 1;
            i++;
            
        } while (1);

        active = alt_irq_pending();
    
    } while (active);

    /*
     * Notify the operating system that interrupt processing is complete.
     */ 

    ALT_OS_INT_EXIT();
}


#if defined(ALT_CPU_CLIC_EN) && ALT_CPU_CLIC_EN

/* clic_handle_standard_interrupt is called by the CLIC service loop in machine_trap.S, 
 * whenever a RISC-V standard interrupt (interrupt ID < 16) is identified as the most important
 * available interrupt. mtval is not available as it could have been clobbered by preemption.
 * This function is required because the alt_irq table does not include entries for these
 * standard interrupts.
 * The CLIC service loop is responsible for informing the OS of transitions to and from 
 * interrupt level. 
 */

void clic_handle_standard_interrupt(alt_u32 exception_code, alt_u32 epc)
{
    alt_u32 cause = 0x80000000 | exception_code;
    switch (exception_code) {
        case NIOSV_TIMER_IRQ:
        {
            if (alt_niosv_timer_interrupt_handler) {
                alt_niosv_timer_interrupt_handler(cause, epc, 0);
            }
            break;
        }
        case NIOSV_SOFTWARE_IRQ:
        {
            if (alt_niosv_software_interrupt_handler) {
                alt_niosv_software_interrupt_handler(cause, epc, 0);
            }
            break;
        }
        default:
        {
            ALT_LOG_PRINTF("invalid exception code: %d, epc = %d\n", exception_code, epc);
            break;
        }
    }
}

/* clic_handle_default_vt_interrupt is a placeholder for use in the CLIC vector table. 
 * It is intended to catch hardware vectored interrupts for which no interrupt specific handler
 * has been defined. 
 * The function is expected to be called by the CLIC SHV HW mechanism; therefore interrupts are
 * disabled on entry and an mret instruction is used to exit the routine. 
 * The function prototype declaration includes an "interrupt" atrribute which causes the compiler
 * to generate code that saves and restores all registers that are needed by this function. 
 */
void clic_handle_default_vt_interrupt() 
{
    alt_u32 cause;
    NIOSV_READ_CSR(NIOSV_MCAUSE_CSR,cause);
    ALT_LOG_PRINTF("invalid cause: %d\n", cause);
    __asm__ (
        "mret;"
    );
}

#endif /* #if defined(ALT_CPU_CLIC_EN) && ALT_CPU_CLIC_EN */

#endif /* #if ALT_CPU_HAS_CSR_SUPPORT */
