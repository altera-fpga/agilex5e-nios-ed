/*
 * Copyright (c) 2009 Altera Corporation, San Jose, California, USA.  
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
 * intel_niosv_irq.c - Support for Intel Nios V internal interrupt controllers
 *                     CLINT and CLIC.
 *
 * If CSR support is present in the hardware, the HAL uses either a CLIC or CLINT (in 
 * Direct or Vectored mode) interrupt controller, chosen via the hw.tcl configured 
 * Interrupt Mode. HAL software initializes the selected interrupt controller 
 * before transferring control to the user's main program. 
 * There is currently no HAL API support for run-time switching of the interrupt mode. 
 */

#include "sys/alt_irq.h"
#include "intel_niosv_irq.h"
#include "intel_niosv.h"
#include "alt_niosv_int_mode.h"

#if defined(ALT_CPU_INT_MODE) && (ALT_CPU_INT_MODE == ALT_CPU_INT_MODE_VIC)
extern alt_u32 VIC_VECTOR_TABLE[];
#endif 

#if NIOSV_HAS_CLIC
extern alt_u32 clic_vector_table[];
#endif 

/* intel_niosv_clic_csrind_init
 *
 * CLIC-specific initialization of CSRind registers (not for use outside this module). 
 * The registers accessible via CSRind are available in both CLIC and CLINT modes, and follow WARL 
 * conventions so they can safely be initialized by writing zeroes irrespective of the CLIC
 * parameterization.
 * The HW permits writes to CLIC CSRind register bits that do not correspond to implemented interrupt
 * sources. 
 * The CLIC can be configured to latch edge-triggered interrupts in clicintip, so these registers
 * are included in the initialization process. 
 */
static ALT_INLINE void intel_niosv_clic_csrind_init(void)
{
#if NIOSV_HAS_CLIC
    register alt_u32 i;
    // Initialize clicintip (MIREG) and clicintie (MIREG2) for 32 interrupts at a time.
    // this disables interrupts and clears any pending edge-triggered interrupts 
    for (i = 0; i < (ALT_CPU_CLIC_NUM_INTERRUPTS+31)/32; ++i) {
        NIOSV_WRITE_CSR (NIOSV_MISELECT_CSR, NIOSV_CSRIND_CLICINTIP_IE_BASE + i);
        NIOSV_WRITE_CSR (NIOSV_MIREG_CSR,    0);
        NIOSV_WRITE_CSR (NIOSV_MIREG2_CSR,   0);
    }
    // Initialize clicintctl (MIREG) and clicintattr (MIREG2) for 4 interrupts at a time.
    // This sets level and priority to the lowest possible value (in the case of 8 level bits, use 
    // 0x01 rather than 0x00 to avoid local disable behaviour)).
    // In clicintattr, disables edge triggering, polarity inversion, and hardware vectoring if 
    // the CLIC HW has been parameterized with these features. 
    for (i = 0; i < (ALT_CPU_CLIC_NUM_INTERRUPTS+3)/4; ++i) {
        NIOSV_WRITE_CSR (NIOSV_MISELECT_CSR, NIOSV_CSRIND_CLICINTCTL_ATTR_BASE + i);
        NIOSV_WRITE_CSR (NIOSV_MIREG_CSR,    (ALT_CPU_CLIC_NUM_LEVELS <= 128) ? 0 : 0x01010101);
        NIOSV_WRITE_CSR (NIOSV_MIREG2_CSR,   0);
    }
    // Initialize any clicinttrig debug control registers that have been implemented
    for (i = 0; i < ALT_CPU_CLIC_NUM_DEBUG_TRIGGERS; ++i) {
        NIOSV_WRITE_CSR (NIOSV_MISELECT_CSR, NIOSV_CSRIND_CLICINTTRIG_BASE + i);
        NIOSV_WRITE_CSR (NIOSV_MIREG_CSR,    0);
    }
#endif
}

/* intel_niosv_irq_init
 *
 * Assumes that MTVEC is already initialized with the common trap handler address.
 * 
 * Initializes the interrupt controller(s) based on ALT_CPU_INT_MODE
 *   ALT_CPU_INT_MODE_VIC:  Basic interrupt controller, in Vectored mode (32-entry jump table)
 *   ALT_CPU_INT_MODE_CLIC: Core Level Interrupt Controller (CLIC) initialization based on
 *                          parameters passed through from the hw.tcl script.
 *                          Also for ALT_CPU_INT_MODE_RESERVED
 *   ALT_CPU_INT_MODE_DIRECT (default): basic interrupt controller in non-vectored mode. 
 * 
 * To initialize the internal CLINT interrupt controller HW, just clear the mie register so 
 * that all possible IRQs are disabled. In CLINT Vectored mode, MTVEC needs to point to the
 * jump table rather than the default trap handler. CLIC software vectored interrupt processing
 * uses the default trap handler.
 * 
 * According to the CLIC specification (v0.9), MTVT and MINTTHRESH are not neccessarily preserved
 * when round-tripping from CLIC to CLINT and back to CLIC mode. Therefore the HAL does not directly
 * support mode switching; users who wish to switch interrupt controller after initialization
 * are responsible for preserving and restoring interrupt controller state. 
 * 
 * Interrupts are globally disabled during the switch into CLIC mode (since MTVT is temporarily
 * undefined), after this the global enable is restored to its original value. 
 */
void intel_niosv_irq_init(void) 
{
#if NIOSV_HAS_IRQ_SUPPORT
    // Clear CLINT per-interrupt enables
    NIOSV_CLR_CSR (NIOSV_MIE_CSR, NIOSV_MIE_MASK);

    #if defined(ALT_CPU_INT_MODE) && (ALT_CPU_INT_MODE == ALT_CPU_INT_MODE_VIC)
        // Initialize mtvec with vector table for vic mode.
        NIOSV_WRITE_CSR (NIOSV_MTVEC_CSR, (alt_u32) &VIC_VECTOR_TABLE | ALT_CPU_INT_MODE_VIC);
    #else 
        // Set the interrupt handling mode to CLINT Direct (both bits clear)
        NIOSV_CLR_CSR (NIOSV_MTVEC_CSR, NIOSV_MTVEC_INT_MODE_MASK);
    #endif 

    #if NIOSV_HAS_CLIC 
        intel_niosv_clic_csrind_init();
        #if defined(ALT_CPU_INT_MODE) && ((ALT_CPU_INT_MODE == ALT_CPU_INT_MODE_CLIC) || \
                                          (ALT_CPU_INT_MODE == ALT_CPU_INT_MODE_RESERVED))
            alt_u32 mstatus_val;
            NIOSV_READ_AND_CLR_CSR (NIOSV_MSTATUS_CSR, mstatus_val, NIOSV_MSTATUS_MIE_MASK);
            // Enter CLIC mode by writing MTVEC, but use the same trap handler as CLINT Direct mode
            NIOSV_SET_CSR (NIOSV_MTVEC_CSR, ALT_CPU_INT_MODE_CLIC);
            // Initialize MTVT and MINTTHRESH, then re-enable interrupts
            NIOSV_WRITE_CSR (NIOSV_MTVT_CSR,       clic_vector_table);
            NIOSV_WRITE_CSR (NIOSV_MINTTHRESH_CSR, 0);
            NIOSV_WRITE_CSR (NIOSV_MSTATUS_CSR,    mstatus_val);
        #endif
    #endif

#endif
}

