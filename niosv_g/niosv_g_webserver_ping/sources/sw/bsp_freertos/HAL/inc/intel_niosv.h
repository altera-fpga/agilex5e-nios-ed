/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2008 Altera Corporation, San Jose, California, USA.           *
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
#ifndef __INTEL_NIOSV_H__
#define __INTEL_NIOSV_H__

#ifndef ALT_ASM_SRC 
#include "alt_types.h"
#include "io.h"
#endif /* !ALT_ASM_SRC */

#include "system.h"

/*
 * This header provides processor macros for accessing Intel Nios V.
 */

#define NIOSV_M_ARCH        1
#define NIOSV_M_ARCH_NOPIPE 2
#define NIOSV_G_ARCH        3
#define NIOSV_C_ARCH        4

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */

#define ALT_VOLATILE_ACCESS(x) (*(__typeof__(*x) volatile *)(x))

// Handy stringification marcos
#define ALT_MKSTR(s) #s
#define ALT_MKSTR_EXPAND(s) ALT_MKSTR(s)

/* Default value is true. For older builds (mid 23.2 and earlier every CPU had CSR support */
#ifndef ALT_CPU_HAS_CSR_SUPPORT
    #define ALT_CPU_HAS_CSR_SUPPORT 1
#endif

#define NIOSV_HAS_IRQ_SUPPORT ALT_CPU_HAS_CSR_SUPPORT

#if !(ALT_CPU_HAS_CSR_SUPPORT)

    // Cores that do not have CSR support do not support platform interrupts or
    // Shadow Register File bank switching
    #define NIOSV_NIRQ          0
    #define NIOSV_HAS_CLIC      0
    #define NIOSV_NUM_SRF_BANKS 1

#else /* !ALT_CPU_HAS_CSR_SUPPORT */

#ifndef ALT_ASM_SRC
typedef void (*alt_niosv_timer_isr_t)(alt_u32 cause, alt_u32 epc, alt_u32 tval);
typedef void (*alt_niosv_sw_isr_t)(alt_u32 cause, alt_u32 epc, alt_u32 tval);
#endif /* !ALT_ASM_SRC */

#define NIOSV_IC_ID         0
#define NIOSV_SOFTWARE_IRQ  3
#define NIOSV_TIMER_IRQ     7
#define NIOSV_EXTERNAL_IRQ  11

#define NIOSV_NUM_SYNCH_EXCEPTIONS  16
#define NIOSV_ECC_EXCEPTION         19

/* 
 * Two shadow register files are always provided by the "C++" core architecture; 
 * In the "g" core the number of banks is configurable via the NUM_SRF_BANKS parameter.
 * "m" core variants do not support shadow registers at all.  
 */

#if defined(ALT_CPU_NUM_SRF_BANKS)
    #define NIOSV_NUM_SRF_BANKS ALT_CPU_NUM_SRF_BANKS
#elif ALT_CPU_NIOSV_CORE_VARIANT == NIOSV_C_ARCH
    #define NIOSV_NUM_SRF_BANKS 2
#else
    #define NIOSV_NUM_SRF_BANKS 1
#endif

#if defined(ALT_CPU_CLIC_EN) && (ALT_CPU_CLIC_EN)
    #define NIOSV_HAS_CLIC 1
#else
    #define NIOSV_HAS_CLIC 0
#endif

/*
 * Memory mapped control registers
 */
#define NIOSV_MTIMECMP_ADDR   (ALT_CPU_MTIME_OFFSET + 0x8)
#define NIOSV_MTIME_ADDR      ALT_CPU_MTIME_OFFSET
#define MTIMECMP_MAX_VALUE    0xFFFFFFFFFFFFFFFF

/*
 * Control registers (CSRs)
 */
#define NIOSV_MSTATUS_CSR     0x300
#define NIOSV_MIE_CSR         0x304
#define NIOSV_MTVEC_CSR       0x305
#define NIOSV_MTVT_CSR        0x307
#define NIOSV_MSCRATCH_CSR    0x340
#define NIOSV_MEPC_CSR        0x341
#define NIOSV_MCAUSE_CSR      0x342
#define NIOSV_MTVAL_CSR       0x343
#define NIOSV_MIP_CSR         0x344
#define NIOSV_MNXTI_CSR       0x345
#define NIOSV_MINTTHRESH_CSR  0x347
#define NIOSV_MSCRATCHCSW_CSR 0x348
#define NIOSV_MSCRATCHSWL_CSR 0x349
#define NIOSV_MTINST_CSR      0x34A
#define NIOSV_MTVAL2_CSR      0x34B
#define NIOSV_MISELECT_CSR    0x350
#define NIOSV_MIREG_CSR       0x351
#define NIOSV_MIREG2_CSR      0x352
#define NIOSV_ECC_INJECT_CSR  0x7C0
#define NIOSV_ECC_STATUS_CSR  0x7C1
#define NIOSV_MSRFSTATUS_CSR  0x7C4
#define NIOSV_MRDPSRF_CSR     0x7C5
#define NIOSV_MWRPSRF_CSR     0x7C6
#define NIOSV_MHARTID_CSR     0xF14
#define NIOSV_MINTSTATUS_CSR  0xFB1

/*
 * Control register (CSR) fields
 */
#define NIOSV_MSTATUS_MIE_MASK      0x8
#define NIOSV_MCAUSE_CAUSE_MASK     0xFFF
#define NIOSV_MCAUSE_INTERRUPT_MASK (1<<(__riscv_xlen-1))
#define NIOSV_MTVEC_INT_MODE_MASK   0x3
#define NIOSV_MSRFSTATUS_ESI_MASK   (1<<(__riscv_xlen-1))
#if (__riscv_xlen == 32)
  #define NIOSV_MIE_MASK            0xFFFFFFFF
#else
  #define NIOSV_MIE_MASK            0xFFFFFFFFFFFFFFFF
#endif

/*
 * Addresses within CSRind space (typically written to MISELECT)
 */
#define NIOSV_CSRIND_CLICINTCTL_ATTR_BASE 0x1000
#define NIOSV_CSRIND_CLICINTIP_IE_BASE    0x1400
#define NIOSV_CSRIND_CLICINTTRIG_BASE     0x1480

/*
 * Number of available platform IRQs in internal interrupt controller (CLINT or CLIC).
 * Note: in NiosV CLINT implementations, the top 16 bits of mie / mip are
 *       available for platform defined interrupts, and the bottom
 *       16 are reserved for RISC-V standard interrupts supported by interrupt
 *       specific HAL API functions. 
 * If more than one interrupt controller is present, NIOSV_NIRQ represents
 * the highest number of platform interrupts offered by any of the
 * interrupt controllers. 
 */

#define NIOSV_CLINT_NIRQ (__riscv_xlen-16)

#if NIOSV_HAS_CLIC && ((ALT_CPU_CLIC_NUM_INTERRUPTS-16) > NIOSV_CLINT_NIRQ)
  #define NIOSV_NIRQ (ALT_CPU_CLIC_NUM_INTERRUPTS-16)
#else
  #define NIOSV_NIRQ NIOSV_CLINT_NIRQ
#endif

/*
 * Macros to access control registers.
 * The macros and the functions that use them are not available when this file
 * is included from an assembly-language file. 
 */

#ifndef ALT_ASM_SRC

/* Read CSR regNum and set dst to its value. */
#define NIOSV_READ_CSR(regNum, dst)                         \
  do { asm volatile ("csrr %[dstReg], %[imm]"               \
    : [dstReg] "=r"(dst)                                    \
    : [imm] "i"(regNum)); } while (0)

/* Writes CSR regNum with src */
#define NIOSV_WRITE_CSR(regNum, src)                        \
  do { asm volatile ("csrw %[imm], %[srcReg]"               \
    :                                                       \
    : [imm] "i"(regNum), [srcReg] "r"(src)); } while (0)

/* Read CSR regNum, set dst to its value, and write CSR regNum with src. */
#define NIOSV_SWAP_CSR(regNum, src, dst)                    \
  do { asm volatile ("csrrw %[dstReg], %[imm], %[srcReg]"   \
    : [dstReg] "=r"(dst)                                    \
    : [imm] "i"(regNum), [srcReg] "r"(src)); } while (0)

/* 
 * Bit-wise OR the CSR with bitmask.
 * Any bit that is 1 in bitmask causes the corresponding bit in CSR to be set to 1.
 */
#define NIOSV_SET_CSR(regNum, bitmask)                      \
  do { asm volatile ("csrs %[imm], %[srcReg]"               \
    :                                                       \
    : [imm] "i"(regNum), [srcReg] "r"(bitmask)); } while (0)

/* 
 * Read CSR regNum, set dst to its value, and bit-wise OR the CSR with bitmask.
 * Any bit that is 1 in bitmask causes the corresponding bit in CSR to be set to 1.
 */
#define NIOSV_READ_AND_SET_CSR(regNum, dst, bitmask)        \
  do { asm volatile ("csrrs %[dstReg], %[imm], %[srcReg]"   \
    : [dstReg] "=r"(dst)                                    \
    : [imm] "i"(regNum), [srcReg] "r"(bitmask)); } while (0)

/* 
 * Bit-wise AND the CSR with ~bitmask.
 * Any bit that is 1 in bitmask causes the corresponding bit in CSR to be cleared to 0.
 */
#define NIOSV_CLR_CSR(regNum, bitmask)                      \
  do { asm volatile ("csrc %[imm], %[srcReg]"              \
    :                                                       \
    : [imm] "i"(regNum), [srcReg] "r"(bitmask)); } while (0)

/* 
 * Read CSR regNum, set dst to its value, and bit-wise AND the CSR with ~bitmask.
 * Any bit that is 1 in bitmask causes the corresponding bit in CSR to be cleared to 0.
 */
#define NIOSV_READ_AND_CLR_CSR(regNum, dst, bitmask)        \
  do { asm volatile ("csrrc %[dstReg], %[imm], %[srcReg]"   \
    : [dstReg] "=r"(dst)                                    \
    : [imm] "i"(regNum), [srcReg] "r"(bitmask)); } while (0)

/* set specific bit to 1 */
#define NIOSV_CSR_SET_BIT(regNum, bit)        \
  do { asm volatile ("csrsi %[imm], %[srcReg]"   \
    :                                                       \
    : [imm] "i"(regNum), [srcReg] "r"(bit)); } while (0)

/* set specific bit to 0 */
#define NIOSV_CSR_CLR_BIT(regNum, bit)        \
  do { asm volatile ("csrci %[imm], %[srcReg]"   \
    :                                                       \
    : [imm] "i"(regNum), [srcReg] "r"(bit)); } while (0)

static ALT_INLINE int ALT_ALWAYS_INLINE alt_niosv_read_mhartid() {
    alt_u32 mhartid_val;
    NIOSV_READ_CSR(NIOSV_MHARTID_CSR, mhartid_val);
    return mhartid_val;
}

// Functions for getting mtime, and get/set mtimecmp
static ALT_INLINE volatile alt_u32 *const ALT_ALWAYS_INLINE alt_niosv_get_mtimecmp_addr() {
    return (alt_u32 *)(NIOSV_MTIMECMP_ADDR + (8 * alt_niosv_read_mhartid()));
}
alt_u64 alt_niosv_mtime_get();
void alt_niosv_mtimecmp_set(alt_u64 time);
alt_u64 alt_niosv_mtimecmp_get();
void alt_niosv_mtimecmp_interrupt_init();
extern alt_niosv_timer_isr_t alt_niosv_timer_interrupt_handler;

static ALT_INLINE void ALT_ALWAYS_INLINE alt_niosv_register_mtimecmp_interrupt_handle(alt_niosv_timer_isr_t handle) {
    alt_niosv_timer_interrupt_handler = handle;
}


// If the CLIC is present, enable/disable are applied to both MIE and CLICINTIE because this is faster than
// checking which interrupt controller is enabled.
// However if the CLIC is currently active, MIE is unaffected by CSR operations. 
// If the hart is in CLINT mode, clicintie can be written without changing to CLIC mode.  

static ALT_INLINE void ALT_ALWAYS_INLINE alt_niosv_enable_timer_interrupt() {
    NIOSV_SET_CSR(NIOSV_MIE_CSR, (0x1 << NIOSV_TIMER_IRQ));
    #if NIOSV_HAS_CLIC
        NIOSV_WRITE_CSR(NIOSV_MISELECT_CSR, NIOSV_CSRIND_CLICINTIP_IE_BASE);
        NIOSV_SET_CSR  (NIOSV_MIREG2_CSR,   (0x1 << NIOSV_TIMER_IRQ));
    #endif
}

static ALT_INLINE void ALT_ALWAYS_INLINE alt_niosv_disable_timer_interrupt() {
    NIOSV_CLR_CSR(NIOSV_MIE_CSR, (0x1 << NIOSV_TIMER_IRQ));
    #if NIOSV_HAS_CLIC
        NIOSV_WRITE_CSR(NIOSV_MISELECT_CSR, NIOSV_CSRIND_CLICINTIP_IE_BASE);
        NIOSV_CLR_CSR  (NIOSV_MIREG2_CSR,   (0x1 << NIOSV_TIMER_IRQ));
    #endif
}

static ALT_INLINE int ALT_ALWAYS_INLINE alt_niosv_is_timer_interrupt_enabled() {
    alt_u32 ie_val;
    NIOSV_READ_CSR(NIOSV_MIE_CSR, ie_val);
    #if NIOSV_HAS_CLIC
        // In CLIC mode, mie will read as all-zeroes. Just OR mie with clicintie
        register alt_u32 clicintie_val;
        NIOSV_WRITE_CSR(NIOSV_MISELECT_CSR, NIOSV_CSRIND_CLICINTIP_IE_BASE);
        NIOSV_READ_CSR (NIOSV_MIREG2_CSR, clicintie_val);
        ie_val |= clicintie_val;
    #endif   
    return ie_val & (0x1 << NIOSV_TIMER_IRQ);
}

/*
 * Functions for use as system clock driver and timestamp driver.
 */
void alt_niosv_timer_sc_isr(alt_u32 cause, alt_u32 epc, alt_u32 tval);

extern alt_u64 alt_niosv_timestamp_offset;

static ALT_INLINE int ALT_ALWAYS_INLINE alt_niosv_timer_timestamp_start() {
    alt_niosv_timestamp_offset = alt_niosv_mtime_get();
    return 0;
}

static ALT_INLINE alt_u64 ALT_ALWAYS_INLINE alt_niosv_timer_timestamp() {
    return alt_niosv_mtime_get() - alt_niosv_timestamp_offset;
}

static ALT_INLINE alt_u32 ALT_ALWAYS_INLINE alt_niosv_timer_timestamp_freq() {
    return ALT_CPU_CPU_FREQ;
}

#endif /* !ALT_ASM_SRC */

// Determine amount to add to mtimecmp to trigger a subsequent interrupt at
#define MTIMECMP_DELTA_AMT (ALT_CPU_CPU_FREQ / ALT_CPU_TICKS_PER_SEC)

#endif /* ALT_CPU_HAS_CSR_SUPPORT */

/*
 * Cache maintenance macros
 * CLEAN - Writeback to memory;
 * FLUSH - Writeback to memory and invalidate. 
 */

#if ALT_CPU_DCACHE_SIZE > 0
#define DCACHE_CLEAN_BY_INDEX_VAL(i) \
__asm__ volatile(".insn i 0x0F, 0x2, zero, %[i_reg], 0x081" :: [i_reg] "r"(i));

#define DCACHE_FLUSH_BY_INDEX_VAL(i) \
__asm__ volatile(".insn i 0x0F, 0x2, zero, %[i_reg], 0x082" :: [i_reg] "r"(i));

#define DCACHE_INVALIDATE_BY_INDEX_VAL(i) \
__asm__ volatile(".insn i 0x0F, 0x2, zero, %[i_reg], 0x080" :: [i_reg] "r"(i));
#endif

/* API to check the validity of the System ID.
 * BSP will generate #define ALT_SYSID_BASE <System ID base address> and
 * #define ALT_SYSID_ID <System ID value> in system.h if there is System ID IP
 * connected to NiosV CPU.
*/
#ifdef ALT_SYSID_BASE
#define IS_SYSTEM_ID_VALID()	((IORD_32DIRECT(ALT_SYSID_BASE, 0) == ALT_SYSID_ID) ? 0 : -1)
#else /* ALT_SYSID_BASE */
#define IS_SYSTEM_ID_VALID()	-1
#endif /* ALT_SYSID_BASE */

/*
 * Macros for accessing select Nios V general-purpose registers.
 */
/* SP (Stack Pointer) register */ 
#define NIOSV_READ_SP(sp) \
    do { __asm ("mv %0, sp" : "=r" (sp) ); } while (0)

/*
 * Macros for useful processor instructions.
 */
#define NIOSV_EBREAK() \
    do { __asm volatile ("ebreak"); } while (0)

/* TODO: Figure this out for Nios V. No optional immediate for RISC-V ebreak supported. */
#define NIOSV_REPORT_STACK_OVERFLOW() \
    do { __asm volatile("ebreak"); } while (0)

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __INTEL_NIOSV_H__ */
