/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2020-2021 Intel Corporation, Santa Clara, California, USA.    *
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
 * This is the base machine-mode trap exception handler for Nios V.  This only
 * saves the caller saved registers, any callee saved registers will be saved by
 * handle_trap or other C-ABI handlers if needed.
*/ 

#define ALT_ASM_SRC

#include "linker.h"
#include "system.h"
#include "intel_niosv.h"
#include "os/alt_hooks.h"

    .section .exceptions.entry.label, "xa"

    // TODO: for CLIC support, aligment should be forced to 64 bytes
    .align 2

    .globl trap_vector
    .globl __alt_exception_stack_pointer
    .globl __alt_exception_stack_limit

#if !defined(ALT_CPU_CLIC_NUM_INTERRUPTS) 
    #define NUM_CLIC_VT_ENTRIES (12)  // Representing standard interrupts <= Machine External Interrupt
#elif (ALT_CPU_CLIC_NUM_INTERRUPTS > 32)
    #define NUM_CLIC_VT_ENTRIES (32)  // This limit will be configurable in future
#else
    #define NUM_CLIC_VT_ENTRIES (ALT_CPU_CLIC_NUM_INTERRUPTS)
#endif

    .type trap_vector, @function

trap_vector:
    /*
     * The code for detecting a likely fatal ECC exception is
     * linked here before the normal exception handler code if required.
     * This is handled by the linker script and putting that code
     * in the .exceptions.entry.ecc_fatal section.
     */

    /*
     * Now start the normal exception handler code.
     */

    .section .exceptions.entry, "xa"

    /* Determine architecture byte size */
#if __riscv_xlen == 32
    #define XBYTES       4
    #define CLOG2_XBYTES 2
    #define XST          sw
    #define XLD          lw

    #define FBYTES 4
    #define FPST fsw
    #define FPLD flw
#else //__riscv_xlen == 64
    #define XBYTES       8
    #define CLOG2_XBYTES 3
    #define XST          sd
    #define XLD          ld

#if __riscv_flen == 32
    #define FBYTES 4
    #define FPST   fsw
    #define FPLD   flw
#else //__riscv_flen == 64
    #define FBYTES 8
    #define FPST   fsd
    #define FPLD   fld
#endif
#endif

    /* Does the architecture have shadow registers? */
#define CPU_HAS_SRF (NIOSV_NUM_SRF_BANKS > 1)

    /* Provide stack space for saving FCSR if the hart has an FPU */
#if (__riscv_flen == 32 || __riscv_flen == 64)
    #define FPU_CONTEXT_SAVE_WORDS (1)
#else 
    #define FPU_CONTEXT_SAVE_WORDS (0)
#endif

    /* Determine whether CLIC preemption is possible, and if so then
       provide stack space for saving preempted interrupt handler CSR values. */      
#if NIOSV_HAS_CLIC && (ALT_CPU_CLIC_NUM_LEVELS > 2)
    #define CLIC_CONTEXT_SAVE_WORDS (2)
#else
    #define CLIC_CONTEXT_SAVE_WORDS (0)
#endif

#define CSR_SAVE_BYTES ((FPU_CONTEXT_SAVE_WORDS + CLIC_CONTEXT_SAVE_WORDS) * XBYTES)

/**
 * @brief ABI Calling Convention

 +----------+----------+----------------------------------+--------+----------+
 | Register | ABI Name | Description                      | Saver  | Shadowed |
 +----------+----------+----------------------------------+--------+----------+
 | x0       | zero     | Hardwired to zero                |  ---   | No       |
 | x1       | ra       | Return address                   | Caller | No       |
 | x2       | sp       | Stack pointer                    | Callee | No       |
 | x3       | gp       | Global pointer                   |  ---   | No       |
 | x4       | tp       | Thread pointer                   |  ---   | No       |
 | x5-x7    | t0-t2    | Temporaries                      | Caller | No       |
 | x8       | s0/fp    | Saved register/frame pointer     | Callee | RVE      |
 | x9       | s1       | Saved register                   | Callee | RVE      |
 | x10-x11  | a0-a1    | Function arguments/return values | Caller | RVE      |
 | x12-x15  | a2-a5    | Function arguments               | Caller | RVE      |
 | x16-x17  | a6-a7    | Function arguments               | Caller | Yes      |
 | x18-x27  | s2-s11   | Saved registers                  | Callee | Yes      |
 | x28-x31  | t3-t6    | Temporaries                      | Caller | Yes      |
 +----------+----------+----------------------------------+--------+----------+
 | f0-f7    | ft0-ft7  | FP temporaries                   | Caller | Yes      |
 | f8-f9    | fs0-fs1  | FP saved registers               | Callee | Yes      |
 | f10-f11  | fa0-fa1  | FP arguments/return values       | Caller | Yes      |
 | f12-f17  | fa2-fa7  | FP function arguments            | Caller | Yes      |
 | f18-f27  | fs2-fs11 | FP saved registers               | Callee | Yes      |
 | f28-f31  | ft8-ft11 | FP Temporaries                   | Caller | Yes      |
 +----------+----------+----------------------------------+--------+----------+

 */

    /* Determine the stack frame size for GP and FP registers; this depends
       on architecture and availability of shadow registers. */
#if CPU_HAS_SRF
    #ifdef __riscv_e
        #define GPR_STACK_FRAME_BYTES (4 * XBYTES)
    #else //not RVE
        #define GPR_STACK_FRAME_BYTES (10 * XBYTES)
    #endif
    #define FPR_STACK_FRAME_BYTES (0)
#else //no shadow registers
    #ifdef __riscv_e
        #define GPR_STACK_FRAME_BYTES (10 * XBYTES)
    #else
        #define GPR_STACK_FRAME_BYTES (16 * XBYTES)
    #endif
    #if (__riscv_flen == 32 || __riscv_flen == 64)
        #define FPR_STACK_FRAME_BYTES (20 * FBYTES)
    #else
        #define FPR_STACK_FRAME_BYTES (0)
    #endif
#endif
   /* Determine total stack frame size, and offsets for CSR saves if they are required */
#define STACK_FRAME_BYTES  (GPR_STACK_FRAME_BYTES + CSR_SAVE_BYTES + FPR_STACK_FRAME_BYTES)
#define MCAUSE_SAVE_OFFSET (GPR_STACK_FRAME_BYTES + 0 * XBYTES)
#define MEPC_SAVE_OFFSET   (GPR_STACK_FRAME_BYTES + 1 * XBYTES)
#define FCSR_SAVE_OFFSET   (GPR_STACK_FRAME_BYTES + CSR_SAVE_BYTES - XBYTES)

#ifdef ALT_EXCEPTION_STACK

    /* Save callee saved register s0 */
    /* RVE No need to save the register as it falls into the shadow register range for RVE */
#if (!defined(__riscv_e)) || (!CPU_HAS_SRF)
    addi sp, sp, -XBYTES
    XST  s0, 0(sp)
#endif

    /* Determine whether the exception stack is already in use by comparing against the 
       exception stack bounds */    
    la s0, __alt_exception_stack_pointer
    bgtu sp, s0, not_nested_exc
    la s0, __alt_exception_stack_limit
    bltu sp, s0, not_nested_exc

nested_exc:
    /* This saves the stack pointer onto the stack to keep the loading of
       the stack pointer below the same for both cases (nested vs non-nested) */
    XST  sp, -XBYTES(sp)
    addi sp, sp, -XBYTES    
    j save_registers
    
not_nested_exc:
    /* Load the exception stack pointer into s0 */
    la s0, __alt_exception_stack_pointer - XBYTES
    
    /* Save the current stack pointer into the exception stack, and load the 
       exception stack pointer (s0 holds the memory address of the exception stack) */      
    XST sp, 0(s0)
    mv  sp, s0

#endif /* ALT_EXCEPTION_STACK */

save_registers:

    /* Save caller-saved registers on the stack */
    addi sp, sp, -STACK_FRAME_BYTES

    /* rv32e, rv32i and rv32if */
    XST ra,  0 * XBYTES(sp)
    XST t0,  1 * XBYTES(sp)
    XST t1,  2 * XBYTES(sp)
    XST t2,  3 * XBYTES(sp)

    /* These are shadowd in RVE */
#ifdef __riscv_e
#if !CPU_HAS_SRF
    XST a0,  4 * XBYTES(sp)
    XST a1,  5 * XBYTES(sp)
    XST a2,  6 * XBYTES(sp)
    XST a3,  7 * XBYTES(sp)
    XST a4,  8 * XBYTES(sp)
    XST a5,  9 * XBYTES(sp)
#endif
#endif

    /* rv32i and rv32if */
#ifndef __riscv_e
    XST a0,  4 * XBYTES(sp)
    XST a1,  5 * XBYTES(sp)
    XST a2,  6 * XBYTES(sp)
    XST a3,  7 * XBYTES(sp)
    XST a4,  8 * XBYTES(sp)
    XST a5,  9 * XBYTES(sp)
    /* These are shadowed */
#if !CPU_HAS_SRF
    XST a6, 10 * XBYTES(sp)
    XST a7, 11 * XBYTES(sp)
    XST t3, 12 * XBYTES(sp)
    XST t4, 13 * XBYTES(sp)
    XST t5, 14 * XBYTES(sp)
    XST t6, 15 * XBYTES(sp)
#endif
#endif

    /* All floating point registers are shadowed */
#if (__riscv_flen == 32 || __riscv_flen == 64)
    csrr a0, fcsr
    XST  a0, FCSR_SAVE_OFFSET(sp)
#if !CPU_HAS_SRF
    FPST ft0,  ((GPR_STACK_FRAME_BYTES + CSR_SAVE_BYTES) +  0 * FBYTES)(sp)
    FPST ft1,  ((GPR_STACK_FRAME_BYTES + CSR_SAVE_BYTES) +  1 * FBYTES)(sp)
    FPST ft2,  ((GPR_STACK_FRAME_BYTES + CSR_SAVE_BYTES) +  2 * FBYTES)(sp)
    FPST ft3,  ((GPR_STACK_FRAME_BYTES + CSR_SAVE_BYTES) +  3 * FBYTES)(sp)
    FPST ft4,  ((GPR_STACK_FRAME_BYTES + CSR_SAVE_BYTES) +  4 * FBYTES)(sp)
    FPST ft5,  ((GPR_STACK_FRAME_BYTES + CSR_SAVE_BYTES) +  5 * FBYTES)(sp)
    FPST ft6,  ((GPR_STACK_FRAME_BYTES + CSR_SAVE_BYTES) +  6 * FBYTES)(sp)
    FPST ft7,  ((GPR_STACK_FRAME_BYTES + CSR_SAVE_BYTES) +  7 * FBYTES)(sp)
    FPST ft8,  ((GPR_STACK_FRAME_BYTES + CSR_SAVE_BYTES) +  8 * FBYTES)(sp)
    FPST ft9,  ((GPR_STACK_FRAME_BYTES + CSR_SAVE_BYTES) +  9 * FBYTES)(sp)
    FPST ft10, ((GPR_STACK_FRAME_BYTES + CSR_SAVE_BYTES) + 10 * FBYTES)(sp)
    FPST ft11, ((GPR_STACK_FRAME_BYTES + CSR_SAVE_BYTES) + 11 * FBYTES)(sp)
    FPST fa0,  ((GPR_STACK_FRAME_BYTES + CSR_SAVE_BYTES) + 12 * FBYTES)(sp)
    FPST fa1,  ((GPR_STACK_FRAME_BYTES + CSR_SAVE_BYTES) + 13 * FBYTES)(sp)
    FPST fa2,  ((GPR_STACK_FRAME_BYTES + CSR_SAVE_BYTES) + 14 * FBYTES)(sp)
    FPST fa3,  ((GPR_STACK_FRAME_BYTES + CSR_SAVE_BYTES) + 15 * FBYTES)(sp)
    FPST fa4,  ((GPR_STACK_FRAME_BYTES + CSR_SAVE_BYTES) + 16 * FBYTES)(sp)
    FPST fa5,  ((GPR_STACK_FRAME_BYTES + CSR_SAVE_BYTES) + 17 * FBYTES)(sp)
    FPST fa6,  ((GPR_STACK_FRAME_BYTES + CSR_SAVE_BYTES) + 18 * FBYTES)(sp)
    FPST fa7,  ((GPR_STACK_FRAME_BYTES + CSR_SAVE_BYTES) + 19 * FBYTES)(sp)
#endif
#endif
   
    csrr a0, mcause
    csrr a1, mepc

#if !(NIOSV_HAS_CLIC)
    csrr a2, mtval
    jal handle_trap
    csrw mepc, a0
#else
    /* Handle synchronous exceptions and CLINT-mode interrupts (CLIC sets mcause.mpp to 2'b11) */
    li a2, 0xB0000000
    bltu a0, a2, handle_basic_trap  // Ultimately calls handle_trap

    // Preemptible CLIC software vectoring logic starts here, still with interrupts disabled
#if CLIC_CONTEXT_SAVE_WORDS > 0
    sw a0, MCAUSE_SAVE_OFFSET(sp)   // Save mpp, mpil, mpie in case this handler is preempted. 
    sw a1, MEPC_SAVE_OFFSET(sp)     // Save mepc            "    "    "     "    "     "
#endif
    // Get highest current interrupt and enable interrupts. Result is mtvt + (mcause.exccode * XBYTES)
    // As a side-effect, mcause.exccode is updated. Will return original interrupt if no others appear.
    csrrsi a0, NIOSV_MNXTI_CSR, NIOSV_MSTATUS_MIE_MASK  
                                   
    //--------- In CLIC mode, code beyond this point executes with interrupts enabled --------------

    beqz a0, fast_exit             // Check if original interrupt vanished.

    // To call a HAL platform interrupt specific handler, it is neccessary to look up the context in the alt_irq
    // table, which starts with the first platform interrupt, i.e. interrupt #16.
    // The required alt-irq table entry address is (char*)(&alt_irq) + 2*XBYTES*(mcause.exccode-16).
    // This can also be obtained from the mnxti result using the following expression:
    //   (unsigned long)(&alt_irq) + (mnxti_result*2) - (16*(2*XBYTES)) - 2*(unsigned long)(mtvt_value)
    //
    // Since RISC-V standard interrupts are not provided for in the alt_irq table, they are dispatched via 
    // the clic_handle_standard_interrupt function. 
  
    // TODO: Figure out whether this is supposed to be once-per-interrupt, or to mark execution of an interrupt handler. 
    // ALt_OS_INT_ENTER and EXIT have hardly any documentation and only one example of non-empty definitions has been found, 
    // in an obsolete customer product.  
    ALT_OS_INT_ENTER_ASM

clic_service_loop:
    csrr a1, NIOSV_MTVT_CSR
    addi a2, a1, 16*XBYTES
    blt  a0, a2, call_clic_handle_standard_interrupt  
    sub  a0, a0, a2               // a0 now contains a byte offset from the CLIC VT entry for the first platform interrupt
    slli a0, a0, 1                // Double the offset to convert it into an alt_irq entry byte offset
    la   a1, alt_irq
    add  a0, a0, a1               // alt_irq + 2*(mnxti_result-(mtvt_value+16*XBYTES))
    XLD  a1, 0(a0)                // alt_irq Function pointer in a1     
    XLD  a0, XBYTES(a0)           // alt_irq Context pointer  in a0     
    jalr a1                       // Call C ABI Routine - signature void (unsigned int context)
                                  // Routine must clear down level-triggered interrupt in peripheral HW.
clic_service_after_handler_call:
    // Claim any pending interrupt at level > mcause.mpil
    // Note that mcause.mpil will have changed if this software vectoring dispatcher was preempted, 
    // this is a weakness of the v0.9 CLIC spec. 
    csrrsi a0, NIOSV_MNXTI_CSR, NIOSV_MSTATUS_MIE_MASK 
    bnez a0, clic_service_loop    // Loop to service any interrupt. 

    ALT_OS_INT_EXIT_ASM

#endif /* NIOSV_HAS_CLIC */

    /* Restore caller-saved registers 
       Even if CLIC preemption can happen, while interrupts are enabled it is still possible 
       to restore any information that a preempting interrupt handler is able to save.
       However interrupt-context registers (mepc and mstatus.mpp, .mpie, mpil) that are
       altered by HW when an interrupt is taken must be restored _after_ interrupts are 
       disabled, just before the mret. 
       Thus a0 and a1 are used to convey the saved mcause and mepc to the critical section, and
       if not shadowed are restored there. */
       
restore_registers:

    /* All floating point registers are shadowed */
#if (__riscv_flen == 32 || __riscv_flen == 64)
    XLD  a0,   FCSR_SAVE_OFFSET(sp)
    csrw fcsr, a0
#if !CPU_HAS_SRF
    FPLD ft0,  ((GPR_STACK_FRAME_BYTES + CSR_SAVE_BYTES) +  0 * FBYTES)(sp)
    FPLD ft1,  ((GPR_STACK_FRAME_BYTES + CSR_SAVE_BYTES) +  1 * FBYTES)(sp)
    FPLD ft2,  ((GPR_STACK_FRAME_BYTES + CSR_SAVE_BYTES) +  2 * FBYTES)(sp)
    FPLD ft3,  ((GPR_STACK_FRAME_BYTES + CSR_SAVE_BYTES) +  3 * FBYTES)(sp)
    FPLD ft4,  ((GPR_STACK_FRAME_BYTES + CSR_SAVE_BYTES) +  4 * FBYTES)(sp)
    FPLD ft5,  ((GPR_STACK_FRAME_BYTES + CSR_SAVE_BYTES) +  5 * FBYTES)(sp)
    FPLD ft6,  ((GPR_STACK_FRAME_BYTES + CSR_SAVE_BYTES) +  6 * FBYTES)(sp)
    FPLD ft7,  ((GPR_STACK_FRAME_BYTES + CSR_SAVE_BYTES) +  7 * FBYTES)(sp)
    FPLD ft8,  ((GPR_STACK_FRAME_BYTES + CSR_SAVE_BYTES) +  8 * FBYTES)(sp)
    FPLD ft9,  ((GPR_STACK_FRAME_BYTES + CSR_SAVE_BYTES) +  9 * FBYTES)(sp)
    FPLD ft10, ((GPR_STACK_FRAME_BYTES + CSR_SAVE_BYTES) + 10 * FBYTES)(sp)
    FPLD ft11, ((GPR_STACK_FRAME_BYTES + CSR_SAVE_BYTES) + 11 * FBYTES)(sp)
    FPLD fa0,  ((GPR_STACK_FRAME_BYTES + CSR_SAVE_BYTES) + 12 * FBYTES)(sp)
    FPLD fa1,  ((GPR_STACK_FRAME_BYTES + CSR_SAVE_BYTES) + 13 * FBYTES)(sp)
    FPLD fa2,  ((GPR_STACK_FRAME_BYTES + CSR_SAVE_BYTES) + 14 * FBYTES)(sp)
    FPLD fa3,  ((GPR_STACK_FRAME_BYTES + CSR_SAVE_BYTES) + 15 * FBYTES)(sp)
    FPLD fa4,  ((GPR_STACK_FRAME_BYTES + CSR_SAVE_BYTES) + 16 * FBYTES)(sp)
    FPLD fa5,  ((GPR_STACK_FRAME_BYTES + CSR_SAVE_BYTES) + 17 * FBYTES)(sp)
    FPLD fa6,  ((GPR_STACK_FRAME_BYTES + CSR_SAVE_BYTES) + 18 * FBYTES)(sp)
    FPLD fa7,  ((GPR_STACK_FRAME_BYTES + CSR_SAVE_BYTES) + 19 * FBYTES)(sp)
#endif
#endif

    /* rv32e, rv32i and rv32if */
    XLD ra,  0 * XBYTES(sp)
    XLD t0,  1 * XBYTES(sp)
    XLD t1,  2 * XBYTES(sp)
    XLD t2,  3 * XBYTES(sp)
    /* These registers are shadowed in RVE */
#ifdef __riscv_e
#if !CPU_HAS_SRF
    XLD a2,  6 * XBYTES(sp)
    XLD a3,  7 * XBYTES(sp)
    XLD a4,  8 * XBYTES(sp)
    XLD a5,  9 * XBYTES(sp)
#endif
#endif

    /* rv32i and rv32if */
#ifndef __riscv_e
    XLD a2,  6 * XBYTES(sp)
    XLD a3,  7 * XBYTES(sp)
    XLD a4,  8 * XBYTES(sp)
    XLD a5,  9 * XBYTES(sp)
    /* These registers are shadowed */
#if !CPU_HAS_SRF
    XLD a6, 10 * XBYTES(sp)
    XLD a7, 11 * XBYTES(sp)
    XLD t3, 12 * XBYTES(sp)
    XLD t4, 13 * XBYTES(sp)
    XLD t5, 14 * XBYTES(sp)
    XLD t6, 15 * XBYTES(sp)
#endif
#endif	

fast_exit:  // Fast exit point, which can be used when no registers other than a0 and a1 have been touched.

#if CLIC_CONTEXT_SAVE_WORDS > 0
    XLD  a0, MCAUSE_SAVE_OFFSET(sp)       // Get saved mcause which contains mpp, mpie, mpil corresponding to 
                                          //   privilege mode, mie, and mil of the interrupted context.
    XLD  a1, MEPC_SAVE_OFFSET(sp)         // Get mepc for this interrupt context.
    csrci mstatus, NIOSV_MSTATUS_MIE_MASK // Ensure that interrupts are disabled 
    //--------- Non-interruptible critical section -----------------------
    csrw mcause, a0                       // Restore mcause.mpp, mpie, mpil as they were at entry to this trap handler. 
    csrw mepc,   a1                       // Restore mepc value as at entry, in case preemption occurred.
#endif

#if (!defined(__riscv_e) || !(CPU_HAS_SRF))
    // Only rv32e has shadows for a0 and a1, in all other cases they need to be restored from the stack
    XLD a0,  4 * XBYTES(sp)
    XLD a1,  5 * XBYTES(sp)
#endif

    addi sp, sp, STACK_FRAME_BYTES

#ifdef ALT_EXCEPTION_STACK
    /* Load in the previous stack pointer */
    XLD  sp, 0(sp)

    /* Load callee saved register s0 */
    /* RVE: No need to restore the register, because we didn't need to save it */
#if (!defined(__riscv_e)) || (!(CPU_HAS_SRF))
    XLD  s0, 0(sp)
    addi sp, sp, XBYTES
#endif
#endif

    mret

    /*-----------------------------------------------------------------------*/

handle_basic_trap:
    /* Handle synchronous exceptions or interrupts other than CLIC platform interrupts,
     * with interrupts disabled.
     * Assumes:
     *   1. interrupts have not been enabled since entry to the interrupt/exception dispatcher. 
     *   2. Arguments in a0 and a1 are mcause and mepc
     * The called function handle_trap() should have a signature like this:
     *   alt_u32 handle_trap(alt_u32 cause, alt_u32 epc, alt_u32 tval)
     * The return value overrides mepc 
     */ 
    csrr a2, mtval
    jal handle_trap
#if CLIC_CONTEXT_SAVE_WORDS > 0
    XST a0, MEPC_SAVE_OFFSET(sp)   // Update saved mepc, which will be loaded in the critical section
                                   // of the register-restore code.   
#else
    csrw mepc, a0                  // New mepc value can be set straight away, as this handler 
                                   // will not attempt to restore mepc from the stack.  
#endif
    j restore_registers

    /*-----------------------------------------------------------------------*/
#if NIOSV_HAS_CLIC

call_clic_handle_standard_interrupt:
    /* Used when mnxti returns a CLIC vector table offset corresponding to a standard RISC-V
     * interrupt (one of the first 16 interrupts).
     * On arrival at this label, a0 is expected to contain the mnxti read-and-set result,
     * and a1 the mtvt value which is the base for the mnxti results. 
     * clic_handle_standard_interrupt() is a C-ABI function called with this signature: 
     *   void clic_handle_standard_interrupt(alt_u32 exception_code, alt_u32 epc)
     */
    sub  a0, a0, a1                      // (a0 - a1) is the CLIC VT offset, interrupt# * XBYTES
    srli a0, a0, CLOG2_XBYTES            // Recover the interrupt ID aka exception code
#if CLIC_CONTEXT_SAVE_WORDS > 0
    XLD  a1, MEPC_SAVE_OFFSET(sp)        // Get original mepc value that was saved in case of preemption
#else
    csrr a1, mepc
#endif
    jal clic_handle_standard_interrupt   // Call C-ABI handler
    j   clic_service_after_handler_call  // Return to interrupt service loop
#endif /* NIOSV_HAS_CLIC */

/*------------------------- CLIC vector table -------------------------------*/

/* A CLIC vector table is defined when the CLIC is included in the Nios-V hardware 
 * configuration. 
 * The CLIC vector table is used for dispatching hardware vectored interrupts, and 
 * for software vectoring of standard RISC-V interrupts. 
 * To save memory, a maximum of 32 such interrupts are supported in the CLIC vector table. 
 * All software vectored platform interrupts are handled via the alt_irq table. 
 *
 * The size of the CLIC vector table will in future be configurable. 
 */

#if NIOSV_HAS_CLIC

    .section .exceptions
    .balign 1<<ALT_CPU_CLIC_VT_ALIGN
    .globl clic_vector_table

#if __riscv_xlen == 32
    #define FNPTR .4byte
#else //__riscv_xlen == 64
    #define FNPTR .8byte
#endif

clic_vector_table:
    .rept NUM_CLIC_VT_ENTRIES
    FNPTR clic_handle_default_vt_interrupt
    .endr

#endif 
