/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2009 Altera Corporation, San Jose, California, USA.           *
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
#ifndef __ALT_IRQ_H__
#define __ALT_IRQ_H__

/*
 * alt_irq.h is the Intel Nios V specific implementation of the interrupt controller 
 * interface.
 *
 * This file should be included by application code and device drivers that register 
 * ISRs or manage interrupts.
 */
#include "intel_niosv.h"
#include "alt_types.h"
#include "system.h"

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */

/* 
 * Number of available interrupts in internal interrupt controller.
 */
#define ALT_NIRQ NIOSV_NIRQ

/*
 * Used by alt_ic_irq_disable_all() and alt_ic_irq_enable_all().
 */
typedef int alt_irq_context;

/* ISR Prototype */
typedef void (*alt_isr_func)(void* isr_context);

/* 
 * Lower 16 in Qsys are mapped to the general purpose upper 16 bits of RV
 * 0  --> 16
 * 1  --> 17
 * 2  --> 18
 * 3  --> 19
 * 4  --> 20
 * 5  --> 21
 * 6  --> 22
 * 7  --> 23
 * 8  --> 24
 * 9  --> 25
 * 10 --> 26
 * 11 --> 27
 * 12 --> 28
 * 13 --> 29
 * 14 --> 30
 * 15 --> 31
 */
#define ALT_REMAP_IRQ_NUM(irq) ((irq > (NIOSV_NIRQ - 1)) ? -1 : (int) (irq + 16))

/*
 * alt_irq_enabled can be called to determine if the processor's global
 * interrupt enable is asserted. The return value is zero if interrupts 
 * are disabled, and non-zero otherwise.
 *
 * Whether the internal or external interrupt controller is present, 
 * individual interrupts may still be disabled. Use the other API to query
 * a specific interrupt. 
 */
static ALT_INLINE int ALT_ALWAYS_INLINE 
alt_irq_enabled(void)
{
#if NIOSV_HAS_IRQ_SUPPORT
    alt_u32 mstatus_val;

    NIOSV_READ_CSR(NIOSV_MSTATUS_CSR, mstatus_val);

    return mstatus_val & NIOSV_MSTATUS_MIE_MASK;
#else
    return 0;
#endif
}

/*
 * alt_irq_disable_all() 
 *
 * This routine inhibits all interrupts by clearing the status register MIE 
 * bit. It returns the previous contents of the status register (IRQ 
 * context) which can be used to restore the status register MIE bit to its 
 * state before this routine was called.
 */
static ALT_INLINE alt_irq_context ALT_ALWAYS_INLINE 
alt_irq_disable_all(void)
{
#if NIOSV_HAS_IRQ_SUPPORT
    alt_irq_context context;

    NIOSV_READ_AND_CLR_CSR(NIOSV_MSTATUS_CSR, context, NIOSV_MSTATUS_MIE_MASK);
  
    return context;
#else
    return 0;
#endif
}

/*
 * alt_irq_enable_all() 
 *
 * Enable all interrupts that were previously disabled by alt_irq_disable_all().
 *
 * This routine accepts a context to restore the CPU status register MIE bit
 * to the state prior to a call to alt_irq_disable_all().
 
 * In the case of nested calls to alt_irq_disable_all()/alt_irq_enable_all(), 
 * this means that alt_irq_enable_all() does not necessarily re-enable
 * interrupts.
 */
static ALT_INLINE void ALT_ALWAYS_INLINE 
alt_irq_enable_all(alt_irq_context context)
{
#if NIOSV_HAS_IRQ_SUPPORT
    NIOSV_SET_CSR(NIOSV_MSTATUS_CSR, context & NIOSV_MSTATUS_MIE_MASK);
#endif
}

/*
 * The function alt_irq_init() is defined within the auto-generated file
 * alt_sys_init.c. This function calls the initilization macros for all
 * interrupt controllers in the system at config time, before any other
 * non-interrupt controller driver is initialized.
 *
 * The "base" parameter is ignored and only present for backwards-compatibility.
 * It is recommended that NULL is passed in for the "base" parameter.
 */
extern void alt_irq_init(const void* base);

/*
 * alt_irq_cpu_enable_interrupts() enables the CPU to start taking interrupts.
 */
static ALT_INLINE void ALT_ALWAYS_INLINE 
alt_irq_cpu_enable_interrupts(void)
{
#if NIOSV_HAS_IRQ_SUPPORT
    NIOSV_SET_CSR(NIOSV_MSTATUS_CSR, NIOSV_MSTATUS_MIE_MASK);
#endif
}

/*
 * alt_ic_isr_register() can be used to register an interrupt handler. If the
 * function is succesful, then the requested interrupt will be enabled upon 
 * return.
 */
extern int alt_ic_isr_register(alt_u32 ic_id,
                        alt_u32 irq,
                        alt_isr_func isr,
                        void *isr_context,
                        void *flags);


/*
 * Provide inline functions for IIC.
 */

/** @Function Description:  This function enables a single platform interrupt indicated by "irq".
  * @API Type:              External
  * @param ic_id            Ignored.
  * @param irq              IRQ number
  * @return                 0 if successful, < 0 otherwise
  * If the CLIC is present, both MIE and CLICINTIE are written (MIE does not change if
  * the CLIC is currently active). This is faster than testing MTVEC to discover which
  * interrupt controller is enabled.
  * The CLIC supports up to 2048 interrupt sources and may have multiple CLICINTIE registers
  * in CSRind space. CLICINTIE registers are always 32 bits wide.   
  */
static ALT_INLINE int ALT_ALWAYS_INLINE 
alt_ic_irq_enable(alt_u32 ic_id __attribute__((unused)), alt_u32 irq)
{
#if NIOSV_HAS_IRQ_SUPPORT
    int rc = ALT_REMAP_IRQ_NUM(irq);
    if (rc < 0)
        return rc;
    else
        irq = (alt_u32)rc;
    
    NIOSV_SET_CSR(NIOSV_MIE_CSR, 0x1 << irq);
    #if NIOSV_HAS_CLIC
        NIOSV_WRITE_CSR(NIOSV_MISELECT_CSR, NIOSV_CSRIND_CLICINTIP_IE_BASE + (irq >> 5));
        NIOSV_SET_CSR  (NIOSV_MIREG2_CSR,   (0x1 << (irq & 0x1F)));
    #endif

#endif
    return 0;
}

/** @Function Description:  This function disables a single platform interrupt indicated by "irq".
  * @API Type:              External
  * @param ic_id            Ignored.
  * @param irq              IRQ number
  * @return                 0 if successful, < 0 otherwise
  * If the CLIC is present, both MIE and CLICINTIE are written (MIE does not change if
  * the CLIC is currently active). This is faster than testing MTVEC to discover which
  * interrupt controller is enabled.  
  * The CLIC supports up to 2048 interrupt sources and may have multiple CLICINTIE registers 
  * in CSRind space. CLICINTIE registers are always 32 bits wide.   
  */
static ALT_INLINE int ALT_ALWAYS_INLINE 
alt_ic_irq_disable(alt_u32 ic_id __attribute__((unused)), alt_u32 irq)
{
#if NIOSV_HAS_IRQ_SUPPORT
    int rc = ALT_REMAP_IRQ_NUM(irq);
    if (rc < 0)
        return rc;
    else
        irq = (alt_u32)rc;
    
    NIOSV_CLR_CSR(NIOSV_MIE_CSR, 0x1 << irq);
    #if NIOSV_HAS_CLIC
        NIOSV_WRITE_CSR(NIOSV_MISELECT_CSR, NIOSV_CSRIND_CLICINTIP_IE_BASE + (irq >> 5));
        NIOSV_CLR_CSR  (NIOSV_MIREG2_CSR,   (0x1 << (irq & 0x1F)));
    #endif
#endif
    return 0;
}

/** @Function Description:  This function determines whether the platform interrupt
  *                         interrupt indicated by "irq" is enabled.
  * @API Type:              External
  * @param ic_id            Ignored.
  * @param irq              IRQ number
  * @return                 Zero if corresponding interrupt is disabled and
  *                         non-zero otherwise.
  * If the CLIC is present, both MIE and CLICINTIE are read, and the results OR'ed 
  * (MIE reads as all-zeroes when the CLIC is active). The CLIC supports up to 2048 
  * interrupt sources.  
  */
static ALT_INLINE alt_u32 ALT_ALWAYS_INLINE
alt_ic_irq_enabled(alt_u32 ic_id __attribute__((unused)), alt_u32 irq)
{
#if NIOSV_HAS_IRQ_SUPPORT
    int rc = ALT_REMAP_IRQ_NUM(irq);
    if (rc < 0)
        return 0;
    else
        irq = (alt_u32)rc;
    
    alt_u32 ie_val, ie_result;

    NIOSV_READ_CSR(NIOSV_MIE_CSR, ie_val);
    ie_result = ie_val & (0x1 << irq);
    #if NIOSV_HAS_CLIC
        register alt_u32 clicintie_val;
        NIOSV_WRITE_CSR(NIOSV_MISELECT_CSR, NIOSV_CSRIND_CLICINTIP_IE_BASE + (irq >> 5));
        NIOSV_READ_CSR (NIOSV_MIREG2_CSR, clicintie_val);
        ie_result |= (clicintie_val & (0x1 << (irq & 0x1F)));
    #endif   

    return (ie_result);
#else
    return 0;
#endif
}

/*
 * alt_irq_pending() returns a bit list of the current pending platform interrupts.
 * This is used by alt_irq_handler() to determine which registered interrupt
 * handlers should be called.
 * This code is CLINT specific and will always return 0 when the CLIC is active.
 */
static ALT_INLINE alt_u32 ALT_ALWAYS_INLINE 
alt_irq_pending(void)
{
#if NIOSV_HAS_IRQ_SUPPORT
    alt_u32 active;
    alt_u32 enabled;

    NIOSV_READ_CSR(NIOSV_MIP_CSR, active);
    NIOSV_READ_CSR(NIOSV_MIE_CSR, enabled);

    // Since this is used by alt_irq_handler, we want to only process the upper 16-bits
    // --> the interrupt lines connected via Platform Designer...
    return (active & enabled) >> 16;
#else
    return 0;
#endif
}

/* Core Level Interrupt Controller API
 *
 * The Core Level Interrupt Controller supports up to 2048 interrupt sources (both platform and
 * standard interrupts), configurable interrupt priorities, preemption, and vectoring.
 * 
 * The CLIC feature-set is highly configurable at NiosV core generation time. 
 * 
 * Per-interrupt configuration in the CLIC is performed via indirect CSR accesses, with each
 * interrupt having:
 *    Level and priority configuration in a byte-sized slice of a clicintctl indirect CSR.
 *    Triggering, hardware vectoring, and privilege mode attributes in a byte-sized slice of
 *       a clicintattr indirect CSR.
 *    An interrupt-pending bit in a clicintip indirect CSR 
 *    An interrupt enable bit in a clicintie indirect CSR 
 * 
 * The encoding of level and priority in the 8 ctl bits makes use of the fact that CLIC level 0
 * is always associated with execution outside an interrupt context:
 *    The interrupt's level is encoded in the most significant bits of the byte. 
 *       If there are > 129 CLIC levels, all 8 bits of the byte are used to encode the level, and
 *          the HW interprets a value of 0 as a locally disabled interrupt. In this case all 
 *          interrupts have the same priority of zero. 
 *       If there are two CLIC levels no level bits are needed in ctl, because all interrupts are
 *          implicitly in the "interrupt context" level.
 *       If the configured number of CLIC levels is between 3 and 129 (inclusive) then the number 
 *          of bits used to encode the level is ceil(log2(#levels - 1)). These bits can be all-zero,
 *          this represents the lowest possible interrupt level.  
 *    The interrupt's priority is encoded in the ctl bits after (less significant than) the 
 *    level bits. The number of priority bits is ceil(log2(#priorities)), and will be zero when
 *    there is only one possible interrupt priority.
 *    If the total number of level and priority bits is fewer than 8, the least-significant bits
 *    of ctl will read as all-ones and are ignored when written. 
 * 
 *    The attr byte is composed of several bit-fields, from most to least significant: 
 *       Bit(s)   Contents
 *       7:6      Interrupt's privilege mode, always 0x3 when the hart only supports machine mode.
 *                Does not need to be initialized when written, unless the hart supports multiple
 *                privilege modes. 
 *       5:3      Reserved for future use, write zeroes
 *        2       Inverted interrupt polarity (if enabled in HW)
 *        1       Edge-triggered interrupt    (if enabled in HW)
 *        0       Hardware vectored interrupt (if enabled in HW)
 */ 

#if NIOSV_HAS_CLIC
    #if ALT_CPU_CLIC_NUM_LEVELS > 129
        #define ALT_CLIC_CTL_NUM_LEVEL_BITS 8
    #elif ALT_CPU_CLIC_NUM_LEVELS > 65
        #define ALT_CLIC_CTL_NUM_LEVEL_BITS 7
    #elif ALT_CPU_CLIC_NUM_LEVELS > 33
        #define ALT_CLIC_CTL_NUM_LEVEL_BITS 6
    #elif ALT_CPU_CLIC_NUM_LEVELS > 17
        #define ALT_CLIC_CTL_NUM_LEVEL_BITS 5
    #elif ALT_CPU_CLIC_NUM_LEVELS > 9
        #define ALT_CLIC_CTL_NUM_LEVEL_BITS 4
    #elif ALT_CPU_CLIC_NUM_LEVELS > 5
        #define ALT_CLIC_CTL_NUM_LEVEL_BITS 3
    #elif ALT_CPU_CLIC_NUM_LEVELS > 3
        #define ALT_CLIC_CTL_NUM_LEVEL_BITS 2
    #elif ALT_CPU_CLIC_NUM_LEVELS > 2
        #define ALT_CLIC_CTL_NUM_LEVEL_BITS 1
    #else
        #define ALT_CLIC_CTL_NUM_LEVEL_BITS 0
    #endif

    #if ALT_CPU_CLIC_NUM_PRIORITIES > 128
        #define ALT_CLIC_CTL_NUM_PRIORITY_BITS 8
    #elif ALT_CPU_CLIC_NUM_PRIORITIES > 64
        #define ALT_CLIC_CTL_NUM_PRIORITY_BITS 7
    #elif ALT_CPU_CLIC_NUM_PRIORITIES > 32
        #define ALT_CLIC_CTL_NUM_PRIORITY_BITS 6
    #elif ALT_CPU_CLIC_NUM_PRIORITIES > 16
        #define ALT_CLIC_CTL_NUM_PRIORITY_BITS 5
    #elif ALT_CPU_CLIC_NUM_PRIORITIES > 8
        #define ALT_CLIC_CTL_NUM_PRIORITY_BITS 4
    #elif ALT_CPU_CLIC_NUM_PRIORITIES > 4
        #define ALT_CLIC_CTL_NUM_PRIORITY_BITS 3
    #elif ALT_CPU_CLIC_NUM_PRIORITIES > 2
        #define ALT_CLIC_CTL_NUM_PRIORITY_BITS 2
    #elif ALT_CPU_CLIC_NUM_PRIORITIES > 1
        #define ALT_CLIC_CTL_NUM_PRIORITY_BITS 1
    #else
        #define ALT_CLIC_CTL_NUM_PRIORITY_BITS 0
    #endif

    #define ALT_CLIC_CTL_SLICE_SHIFT(__IRQ__)   ((__IRQ__ & 0x3) << 3)
    #define ALT_CLIC_CTL_LEVEL_SHIFT            (8-ALT_CLIC_CTL_NUM_LEVEL_BITS)
    #define ALT_CLIC_CTL_PRIORITY_SHIFT         (8-(ALT_CLIC_CTL_NUM_LEVEL_BITS+ALT_CLIC_CTL_NUM_PRIORITY_BITS))

    #define ALT_CLIC_ATTR_SLICE_SHIFT(__IRQ__)  ((__IRQ__ & 0x3) << 3)
    #define ALT_CLIC_ATTR_PRIVILEGE_MODE_LOBIT  6
    #define ALT_CLIC_ATTR_INVERT_TRIGGER_BIT    2
    #define ALT_CLIC_ATTR_EDGE_TRIGGER_BIT      1
    #define ALT_CLIC_ATTR_HARDWARE_VECTORED_BIT 0 

    #define ALT_CLIC_MACHINE_PRIVILEGE          3
#endif /* NIOSV_HAS_CLIC */

typedef enum {
    ALT_CLIC_LOGIC_1_LEVEL_TRIGGER_MODE = 0,
    ALT_CLIC_POSITIVE_EDGE_TRIGGER_MODE = 1,
    ALT_CLIC_LOGIC_0_LEVEL_TRIGGER_MODE = 2,
    ALT_CLIC_NEGATIVE_EDGE_TRIGGER_MODE = 3
} alt_clic_trigger_mode_t;

/** @Function Description:  Sets the CLIC's byte-sized clicintctl slice for a single platform
  *                         interrupt indicated by "irq".
  * @API Type:              Internal
  * @param irq              Platform IRQ number
  * @param ctl_byte         The new byte value to be set for the interrupt in the appropriate 
  *                         clicintctl register. Level bits are the most significant in the byte,
  *                         followed by priority bits, and then padding bits which are don't-cares. 
  * @return                 0 if successful, < 0 if "irq" does not represent a valid platform interrupt 
  *                         number. 
  * The CLIC supports up to 2048 interrupt sources and may have multiple clicintctl registers in CSRind 
  * space. These registers are always 32 bits wide and contain CLIC configuration fields for four interrupts.
  * The ctl_byte format is dependent on the CLIC hardware configuration; it is recommended to use 
  * the alt_clic_encode_ctl_byte() function to construct the ctl_byte argument.    
  * Negative return values indicate an invalid irq number.
  * Notes: 1. this function may be obsoleted by future revisions of the CLIC specification. 
  *        2. this function does not provide access to CLIC configuration for standard RISC-V interrupts. 
  */
static ALT_INLINE int ALT_ALWAYS_INLINE 
alt_clic_set_ctl_byte(alt_u32 irq, alt_u8 ctl_byte)
{
#if NIOSV_HAS_IRQ_SUPPORT && NIOSV_HAS_CLIC
    int rc = ALT_REMAP_IRQ_NUM(irq);
    if (rc < 0)
        return rc;
    else {
        irq = (alt_u32)rc;

        alt_u32 slice_mask = 0xFF << ALT_CLIC_CTL_SLICE_SHIFT(irq);
        alt_u32 mireg_val; 
        NIOSV_WRITE_CSR (NIOSV_MISELECT_CSR, NIOSV_CSRIND_CLICINTCTL_ATTR_BASE + (irq >> 2));
        NIOSV_READ_CSR  (NIOSV_MIREG_CSR, mireg_val);   
        mireg_val = (mireg_val & ~slice_mask) | ((alt_u32)ctl_byte << ALT_CLIC_CTL_SLICE_SHIFT(irq));
        NIOSV_WRITE_CSR (NIOSV_MIREG_CSR, mireg_val);
    }
#endif
    return 0;
}

/** @Function Description:  Returns the CLIC's byte-sized clicintctl slice for the 
  *                         platform interrupt indicated by "irq".
  * @API Type:              Internal
  * @param irq              Platform IRQ number
  * @return                 clicintctl slice byte value for the interrupt.
  * Reads a byte-width slice from the clicintctl register containing the level and priority
  * configuration for the specified platform interrupt. This information is packed in a
  * way that is specific to the CLIC hardware parameterization. It is recommended that the
  * alt_clic_ctl_level_bits_of() and alt_clic_ctl_priority_bits_of() functions are used to
  * extract the level and priority bits. 
  * If the CLIC is not present, a zero value is returned. 
  * Notes: 1. this function may be obsoleted by future revisions of the CLIC specification. 
  *        2. this function does not provide access to CLIC configuration for standard RISC-V interrupts. 
  */
static ALT_INLINE alt_u8 ALT_ALWAYS_INLINE 
alt_clic_get_ctl_byte(alt_u32 irq)
{
#if NIOSV_HAS_IRQ_SUPPORT && NIOSV_HAS_CLIC
    int rc = ALT_REMAP_IRQ_NUM(irq);
    if (rc < 0)
        return (alt_u8)0;
    else {
        irq = (alt_u32)rc;
        alt_u32 mireg_val; 
        NIOSV_WRITE_CSR (NIOSV_MISELECT_CSR, NIOSV_CSRIND_CLICINTCTL_ATTR_BASE + (irq >> 2));
        NIOSV_READ_CSR  (NIOSV_MIREG_CSR, mireg_val);   
        return (alt_u8)(mireg_val >> ALT_CLIC_CTL_SLICE_SHIFT(irq));
    }
#else
    return (alt_u8)0;
#endif
}

#if NIOSV_HAS_CLIC

/** @Function Description:    Helper function to pack level and priority bits into a byte-sized clicintctl slice. 
  * @API Type:                Internal
  * @param ctl_level_bits     Level bits that the CLIC combines with trailing 1's to form an 8-bit interrupt level
  *                           used to determine whether interrupt preemption should occur. 
  * @param ctl_priority_bits  Priority bits that the CLIC combines with trailing 1's to form an 8-bit interrupt 
  *                           priority that the CLIC uses to select the most important available interrupt at the
  *                           current level.  
  * @return                   A clicintctl slice containing the level bits, priority bits, and trailing 1's. 
  * The number of supported CLIC levels and priorities is configured at core generation time, and reflected in the
  * macros ALT_CPU_CLIC_NUM_LEVELS and ALT_CPU_CLIC_NUM_PRIORITIES.
  * The value of the level bits CAN be zero; due to the trailing 1's added by the CLIC, the per-interrupt levels
  * are always greater than zero - exception in the special case of 8 level bits, where the CLIC interprets a
  * zero value to mean that the interrupt is locally disabled. 
  * Note: this function may be obsoleted by future revisions of the CLIC specification. 
  */
static ALT_INLINE alt_u8 ALT_ALWAYS_INLINE 
alt_clic_encode_ctl_byte (alt_u32 ctl_level_bits, alt_u32 ctl_priority_bits)
{
    return (ctl_level_bits << ALT_CLIC_CTL_LEVEL_SHIFT) | 
           ((ctl_priority_bits & (0xFF >> (ALT_CLIC_CTL_PRIORITY_SHIFT))) << ALT_CLIC_CTL_PRIORITY_SHIFT) |
           (0xFF >> (ALT_CLIC_CTL_NUM_LEVEL_BITS + ALT_CLIC_CTL_NUM_PRIORITY_BITS)); 
}

/** @Function Description: Helper function to extract the level bits from a byte-sized clicintctl slice. 
  * @API Type:             External
  * @param ctl_byte        clicintctl slice representing level and priority of a single interrupt
  * @return                The level bits contained in ctl_byte.
  * Note: 1. the level bits are the basis of an 8-bit interrupt level generated within the CLIC by appending
  *          trailing 1's.  
  *       2. this function may be obsoleted by future revisions of the CLIC specification. 
  */
static ALT_INLINE alt_u32 ALT_ALWAYS_INLINE 
alt_clic_ctl_level_bits_of(alt_u8 ctl_byte)
{
   return (alt_u32)ctl_byte >> ALT_CLIC_CTL_LEVEL_SHIFT;
}

/** @Function Description: Helper function to extract the priority bits from a byte-sized clicintctl slice. 
  * @API Type:             External
  * @param ctl_byte        clicintctl slice representing level and priority of a single interrupt
  * @return                The priority bits contained in ctl_byte.
  * Note: 1. the priority bits are the basis of an 8-bit interrupt priority generated within the CLIC by  
  *          appending trailing 1's.  
  *       2. this function may be obsoleted by future revisions of the CLIC specification. 
  */
static ALT_INLINE alt_u32 ALT_ALWAYS_INLINE 
alt_clic_ctl_priority_bits_of(alt_u8 ctl_byte)
{
   return ((alt_u32)ctl_byte & (0xFF >> ALT_CLIC_CTL_NUM_LEVEL_BITS)) >> ALT_CLIC_CTL_PRIORITY_SHIFT;
}

#endif /* NIOSV_HAS_CLIC */

/** @Function Description:  Sets the level of the CLIC platform interrupt indicated by "irq".
  * @API Type:              External
  * @param irq              Platform IRQ number
  * @param level_bits       The new value to be set for the level bits of interrupt in the appropriate 
  *                         clicintctl register. Level bits are the most significant in the byte,
  *                         followed by priority bits, and then padding bits which are don't-cares.
  * @return                 0 if successful, < 0 if "irq" does not represent a valid platform interrupt 
  *                         number. 
  * The CLIC supports up to 2048 interrupt sources and may have multiple clicintctl registers in CSRind 
  * space. These registers are always 32 bits wide and contain CLIC configuration fields for four interrupts.
  * The ctl_byte format is dependent on the CLIC hardware configuration; this function uses 
  * alt_clic_priority_bits_of() and alt_clic_encode_ctl_byte() to manipulate the clicintctl slice for
  * the targeted interrupt.     
  * Negative return values indicate an invalid irq number.
  * Note: this function does not provide access to CLIC configuration for standard RISC-V interrupts. 
  */
static ALT_INLINE int ALT_ALWAYS_INLINE 
alt_clic_set_level(alt_u32 irq, alt_u8 level_bits)
{
#if NIOSV_HAS_IRQ_SUPPORT && NIOSV_HAS_CLIC
    int rc = ALT_REMAP_IRQ_NUM(irq);
    if (rc < 0)
        return rc;
    else {
        irq = (alt_u32)rc;

        alt_u32 slice_mask = 0xFF << ALT_CLIC_CTL_SLICE_SHIFT(irq);
        alt_u32 mireg_val;
        alt_u8  ctl_byte; 
        NIOSV_WRITE_CSR (NIOSV_MISELECT_CSR, NIOSV_CSRIND_CLICINTCTL_ATTR_BASE + (irq >> 2));
        NIOSV_READ_CSR  (NIOSV_MIREG_CSR, mireg_val); 
        ctl_byte = (mireg_val & slice_mask) >> ALT_CLIC_CTL_SLICE_SHIFT(irq);
        ctl_byte = alt_clic_encode_ctl_byte (level_bits, alt_clic_ctl_priority_bits_of(ctl_byte));
        mireg_val = (mireg_val & ~slice_mask) | ((alt_u32)ctl_byte << ALT_CLIC_CTL_SLICE_SHIFT(irq));
        NIOSV_WRITE_CSR (NIOSV_MIREG_CSR, mireg_val);
    }
#endif
    return 0;
}

/** @Function Description:  Returns the CLIC level for the platform interrupt indicated by "irq". 
  * @API Type:              External
  * @param irq              Platform IRQ number
  * @return                 CLIC level that is currently assigned to the interrupt. 
  * Reads a byte-width slice from the clicintctl register containing the level and priority
  * configuration for the specified platform interrupt, and extracts the level bits returning them
  * right-justified in the result value. 
  * If the CLIC is not present, a zero value is returned. 
  * Note: this function does not provide access to CLIC configuration for standard RISC-V interrupts. 
  */
static ALT_INLINE alt_u8 ALT_ALWAYS_INLINE 
alt_clic_get_level(alt_u32 irq)
{
#if NIOSV_HAS_IRQ_SUPPORT && NIOSV_HAS_CLIC
    int rc = ALT_REMAP_IRQ_NUM(irq);
    if (rc < 0)
        return (alt_u8)0;
    else {
        irq = (alt_u32)rc;
        alt_u32 mireg_val; 
        NIOSV_WRITE_CSR (NIOSV_MISELECT_CSR, NIOSV_CSRIND_CLICINTCTL_ATTR_BASE + (irq >> 2));
        NIOSV_READ_CSR  (NIOSV_MIREG_CSR, mireg_val);   
        return alt_clic_ctl_level_bits_of((alt_u8)(mireg_val >> ALT_CLIC_CTL_SLICE_SHIFT(irq)));
    }
#else
    return (alt_u8)0;
#endif
}

/** @Function Description:  Sets the priority of the CLIC platform interrupt indicated by "irq".
  * @API Type:              External
  * @param irq              Platform IRQ number
  * @param priority_bits    The new value to be set for the priority bits of interrupt in the appropriate 
  *                         clicintctl register. Level bits are the most significant in the byte,
  *                         followed by priority bits, and then padding bits which are don't-cares.
  * @return                 0 if successful, < 0 if "irq" does not represent a valid platform interrupt 
  *                         number. 
  * The CLIC supports up to 2048 interrupt sources and may have multiple clicintctl registers in CSRind 
  * space. These registers are always 32 bits wide and contain CLIC configuration fields for four interrupts.
  * The ctl_byte format is dependent on the CLIC hardware configuration; this function uses 
  * alt_clic_level_bits_of() and alt_clic_encode_ctl_byte() to manipulate the clicintctl slice for
  * targeted interrupt.     
  * Negative return values indicate an invalid irq number.
  * Note: this function does not provide access to CLIC configuration for standard RISC-V interrupts. 
  */
static ALT_INLINE int ALT_ALWAYS_INLINE 
alt_clic_set_priority(alt_u32 irq, alt_u8 priority_bits)
{
#if NIOSV_HAS_IRQ_SUPPORT && NIOSV_HAS_CLIC
    int rc = ALT_REMAP_IRQ_NUM(irq);
    if (rc < 0)
        return rc;
    else {
        irq = (alt_u32)rc;

        alt_u32 slice_mask = 0xFF << ALT_CLIC_CTL_SLICE_SHIFT(irq);
        alt_u32 mireg_val;
        alt_u8  ctl_byte; 
        NIOSV_WRITE_CSR (NIOSV_MISELECT_CSR, NIOSV_CSRIND_CLICINTCTL_ATTR_BASE + (irq >> 2));
        NIOSV_READ_CSR  (NIOSV_MIREG_CSR, mireg_val);  
        ctl_byte = (mireg_val & slice_mask) >> ALT_CLIC_CTL_SLICE_SHIFT(irq);
        ctl_byte = alt_clic_encode_ctl_byte (alt_clic_ctl_level_bits_of(ctl_byte), priority_bits);
        mireg_val = (mireg_val & ~slice_mask) | ((alt_u32)ctl_byte << ALT_CLIC_CTL_SLICE_SHIFT(irq));
        NIOSV_WRITE_CSR (NIOSV_MIREG_CSR, mireg_val);
    }
#endif
    return 0;
}
  
 /** @Function Description:  Returns the CLIC priority for the platform interrupt indicated by "irq". 
   * @API Type:              External
   * @param irq              Platform IRQ number
   * @return                 CLIC level that is currently assigned to the interrupt. 
   * Reads a byte-width slice from the clicintctl register containing the level and priority
   * configuration for the specified platform interrupt, and extracts the priority bits returning them
   * right-justified in the result value. 
   * If the CLIC is not present, a zero value is returned. 
   * Note: this function does not provide access to CLIC configuration for standard RISC-V interrupts. 
   */
static ALT_INLINE alt_u8 ALT_ALWAYS_INLINE 
alt_clic_get_priority(alt_u32 irq)
{
#if NIOSV_HAS_IRQ_SUPPORT && NIOSV_HAS_CLIC
    int rc = ALT_REMAP_IRQ_NUM(irq);
    if (rc < 0)
        return (alt_u8)0;
    else {
        irq = (alt_u32)rc;
        alt_u32 mireg_val; 
        NIOSV_WRITE_CSR (NIOSV_MISELECT_CSR, NIOSV_CSRIND_CLICINTCTL_ATTR_BASE + (irq >> 2));
        NIOSV_READ_CSR  (NIOSV_MIREG_CSR, mireg_val);   
        return alt_clic_ctl_priority_bits_of((alt_u8)(mireg_val >> ALT_CLIC_CTL_SLICE_SHIFT(irq)));
    }
#else
    return (alt_u8)0;
#endif
}
 
/** @Function Description:  Sets the CLIC's byte-sized clicintattr slice for a single platform
  *                         interrupt indicated by "irq".
  * @API Type:              External
  * @param irq              Platform IRQ number
  * @param ctl_byte         The new byte value to be set for the interrupt in the appropriate 
  *                         clicintattr register. 
  * @return                 0 if successful, < 0 if "irq" does not represent a valid platform interrupt 
  *                         number. 
  * The CLIC supports up to 2048 interrupt sources and may have multiple clicintattr registers in CSRind 
  * space. These registers are always 32 bits wide and contain CLIC configuration fields for four interrupts.
  * The attribute byte has a fixed layout:
  *       Bit(s)   Contents
  *       7:6      Interrupt's privilege mode, always 0x3 when the hart only supports machine mode.
  *                Does not need to be initialized when written, unless the hart supports multiple
  *                privilege modes. 
  *       5:3      Reserved for future use, write zeroes
  *        2       Inverted interrupt polarity (if enabled in HW)
  *        1       Edge-triggered interrupt    (if enabled in HW)
  *        0       Hardware vectored interrupt (if enabled in HW)
  * Use the alt_clic_encode_attr() function to pack attributes into a byte.
  * Negative return values indicate an invalid irq number.
  * Note: this function does not provide access to CLIC configuration for standard RISC-V interrupts. 
  */
static ALT_INLINE int ALT_ALWAYS_INLINE 
alt_clic_set_attr_byte(alt_u32 irq, alt_u8 attr_byte)
{
#if NIOSV_HAS_IRQ_SUPPORT && NIOSV_HAS_CLIC
    int rc = ALT_REMAP_IRQ_NUM(irq);
    if (rc < 0)
        return rc;
    else {
        irq = (alt_u32)rc;

        alt_u32 slice_mask = 0xFF << ALT_CLIC_CTL_SLICE_SHIFT(irq);
        alt_u32 mireg_val; 
        NIOSV_WRITE_CSR (NIOSV_MISELECT_CSR, NIOSV_CSRIND_CLICINTCTL_ATTR_BASE + (irq >> 2));
        NIOSV_READ_CSR  (NIOSV_MIREG2_CSR, mireg_val);   
        NIOSV_WRITE_CSR (NIOSV_MIREG2_CSR, (mireg_val & ~slice_mask) |
                                           ((alt_u32)attr_byte << ALT_CLIC_ATTR_SLICE_SHIFT(irq)));
    }
#endif
    return 0;
}

/** @Function Description:  Returns the CLIC's byte-sized clicintattr slice for a single 
  *                         platform interrupt indicated by "irq".
  * @API Type:              External
  * @param irq              Platform IRQ number
  * @return                 clicintattr slice byte value for the interrupt.
  * Reads a byte-width slice from the clicintattr register containing the attribute configuration
  * for the specified platform interrupt. This information is packed into bit-fields:
  *       Bit(s)   Contents                          Extraction function
  *       7:6      Interrupt's privilege mode        alt_clic_privilege_mode_bits_of()
  *       5:3      Reserved for future use
  *        2       Inverted interrupt polarity       alt_clic_invert_trigger_bit_of()
  *        1       Edge-triggered interrupt          alt_clic_edge_trigger_bit_of()
  *        0       Hardware vectored interrupt       alt_clic_hardware_vectored_bit_of()
  * If the CLIC is not present, a zero value is returned. 
  * Note: this function does not provide access to CLIC configuration for standard RISC-V interrupts. 
  */
  
static ALT_INLINE alt_u8 ALT_ALWAYS_INLINE 
alt_clic_get_attr_byte(alt_u32 irq)
{
#if NIOSV_HAS_IRQ_SUPPORT && NIOSV_HAS_CLIC
    int rc = ALT_REMAP_IRQ_NUM(irq);
    if (rc < 0)
        return (alt_u8)0;
    else {
        irq = (alt_u32)rc;
        alt_u32 mireg_val; 
        NIOSV_WRITE_CSR (NIOSV_MISELECT_CSR, NIOSV_CSRIND_CLICINTCTL_ATTR_BASE + (irq >> 2));
        NIOSV_READ_CSR  (NIOSV_MIREG2_CSR, mireg_val);   
        return (alt_u8)(mireg_val >> ALT_CLIC_ATTR_SLICE_SHIFT(irq));
    }
#else
    return (alt_u8)0;
#endif
}

/** @Function Description:  Sets the CLIC trigger mode of the platform interrupt indicated by "irq".
  * @API Type:              External
  * @param irq              Platform IRQ number
  * @param trigger_mode     The new CLIC trigger mode to be set for the interrupt in the appropriate 
  *                         clicintattr register. 
  * @return                 0 if successful, < 0 if "irq" does not represent a valid platform interrupt 
  *                         number. 
  * The CLIC supports up to 2048 interrupt sources and may have multiple clicintattr registers in CSRind 
  * space. These registers are always 32 bits wide and contain CLIC configuration fields for four interrupts.
  * Only bits 2:1 of the attribute byte are affected by this function. 
  * Negative return values indicate an invalid irq number.
  * Note: this function does not provide access to CLIC configuration for standard RISC-V interrupts. 
  */
 static ALT_INLINE int ALT_ALWAYS_INLINE 
 alt_clic_set_trigger_mode(alt_u32 irq, alt_clic_trigger_mode_t trigger_mode)
 {
 #if NIOSV_HAS_IRQ_SUPPORT && NIOSV_HAS_CLIC
     int rc = ALT_REMAP_IRQ_NUM(irq);
     if (rc < 0)
         return rc;
     else {
         irq = (alt_u32)rc;
 
         alt_u32 slice_trigger_mask = 0x6 << (irq & 0x3);
         alt_u32 mireg_val; 
         NIOSV_WRITE_CSR (NIOSV_MISELECT_CSR, NIOSV_CSRIND_CLICINTCTL_ATTR_BASE + (irq >> 2));
         NIOSV_READ_CSR  (NIOSV_MIREG2_CSR, mireg_val);   
         NIOSV_WRITE_CSR (NIOSV_MIREG2_CSR, (mireg_val & ~slice_trigger_mask) | 
                                            (((alt_u32)trigger_mode & 0x3) << 
                                             (ALT_CLIC_ATTR_SLICE_SHIFT(irq) + ALT_CLIC_ATTR_EDGE_TRIGGER_BIT)));
     }
 #endif
     return 0;
 }
 
 /** @Function Description:  Returns the CLIC trigger mode of the platform interrupt indicated by "irq".
   * @API Type:              External
   * @param irq              Platform IRQ number
   * @return                 CLIC interrupt mode currently active for the interrupt. 
   * If the CLIC is not present, a zero value (ALT_CLIC_LOGIC_1_LEVEL_TRIGGER_MODE) is returned. 
   * Note: this function does not provide access to CLIC configuration for standard RISC-V interrupts. 
   */
   
 static ALT_INLINE alt_clic_trigger_mode_t ALT_ALWAYS_INLINE 
 alt_clic_get_trigger_mode(alt_u32 irq)
 {
 #if NIOSV_HAS_IRQ_SUPPORT && NIOSV_HAS_CLIC
     int rc = ALT_REMAP_IRQ_NUM(irq);
     if (rc < 0)
         return (alt_u8)0;
     else {
         irq = (alt_u32)rc;
         alt_u32 mireg_val; 
         NIOSV_WRITE_CSR (NIOSV_MISELECT_CSR, NIOSV_CSRIND_CLICINTCTL_ATTR_BASE + (irq >> 2));
         NIOSV_READ_CSR  (NIOSV_MIREG2_CSR, mireg_val);   
         return (alt_clic_trigger_mode_t)((mireg_val >> (ALT_CLIC_ATTR_SLICE_SHIFT(irq) + ALT_CLIC_ATTR_EDGE_TRIGGER_BIT)) & 0x3);
     }
 #else
     return (alt_clic_trigger_mode_t)0;
 #endif
 }
 
#if NIOSV_HAS_CLIC

/** @Function Description:    Helper function to pack privilege mode, trigger configuration, and the hardware
  *                           vectored flag into a byte-sized clicintattr slice. 
  * @API Type:                External
  * @param privilege_mode     RISC-V Privilege mode to be associated with this interrupt
  * @param invert_trigger     Invert sense of interrupt triggering, i.e. low-level rather than high-level, or
  *                           negative-edge rather than positive-edge. 
  * @param edge_trigger       Interrupt is latched in the CLIC on a level transition 
  * @param hardware_vectored  Set to 1 if the CLIC must use hardware vectoring to service the interrupt
  * @return                   A clicintattr slice containing the supplied bit field values. 
  */
static ALT_INLINE alt_u8 ALT_ALWAYS_INLINE 
alt_clic_encode_attr_byte (alt_u32 privilege_mode, alt_u32 invert_trigger, alt_u32 edge_trigger, alt_u32 hardware_vectored)
{
   return (alt_u8)(((privilege_mode    & 0x3) << ALT_CLIC_ATTR_PRIVILEGE_MODE_LOBIT ) | 
                   ((invert_trigger    & 0x1) << ALT_CLIC_ATTR_INVERT_TRIGGER_BIT   ) | 
                   ((edge_trigger      & 0x1) << ALT_CLIC_ATTR_EDGE_TRIGGER_BIT     ) | 
                   ((hardware_vectored & 0x1) << ALT_CLIC_ATTR_HARDWARE_VECTORED_BIT));
}

/** @Function Description: Helper function to extract privilege mode from a byte-sized clicintattr slice. 
  * @API Type:             External
  * @param attr_byte       clicintattr slice representing attributes of a single interrupt
  * @return                The RISC-V privilege mode that was encoded in attr_byte 
  */
static ALT_INLINE alt_u32 ALT_ALWAYS_INLINE 
alt_clic_privilege_mode_bits_of(alt_u8 attr_byte)
{
    return ((alt_u32)attr_byte >> ALT_CLIC_ATTR_PRIVILEGE_MODE_LOBIT) & 0x3;
}

/** @Function Description: Helper function to extract the invert-trigger bit from a byte-sized clicintattr slice. 
  * @API Type:             External
  * @param attr_byte       clicintattr slice representing attributes of a single interrupt
  * @return                The invert-trigger flag that was encoded in attr_byte.  
  */
static ALT_INLINE alt_u32 ALT_ALWAYS_INLINE 
alt_clic_invert_trigger_bit_of(alt_u8 attr_byte)
{
    return ((alt_u32)attr_byte >> ALT_CLIC_ATTR_INVERT_TRIGGER_BIT) & 0x1;
}

/** @Function Description: Helper function to extract the edge-trigger bit from a byte-sized clicintattr slice. 
  * @API Type:             External
  * @param attr_byte       clicintattr slice representing attributes of a single interrupt
  * @return                The edge-trigger flag that was encoded in attr_byte. 
  * If the edge-trigger flag is set, the interrupt will be triggered by a rising or falling edge (depending on
  * invert-trigger configuration) and latched in the interrupt's clicintip bit.   
  */
static ALT_INLINE alt_u32 ALT_ALWAYS_INLINE 
alt_clic_edge_trigger_bit_of(alt_u8 attr_byte)
{
    return ((alt_u32)attr_byte >> ALT_CLIC_ATTR_EDGE_TRIGGER_BIT) & 0x1;
}

/** @Function Description: Helper function to extract the hardware-vectored flag from a byte-sized clicintattr slice. 
  * @API Type:             External
  * @param attr_byte       clicintattr slice representing attributes of a single interrupt
  * @return                The hardware-vectored flag that was encoded in attr_byte.  
  */
 static ALT_INLINE alt_u32 ALT_ALWAYS_INLINE 
alt_clic_hardware_vectored_bit_of(alt_u8 attr_byte)
{
    return ((alt_u32)attr_byte >> ALT_CLIC_ATTR_HARDWARE_VECTORED_BIT) & 0x1;
}

#endif /* NIOSV_HAS_CLIC */


#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __ALT_IRQ_H__ */
