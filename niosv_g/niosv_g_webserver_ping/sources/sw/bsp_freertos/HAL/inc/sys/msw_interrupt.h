#ifndef __M_SW_INTERRUPT_H__
#define __M_SW_INTERRUPT_H__

#include "alt_types.h"
#include "sys/alt_irq.h"
#include "intel_niosv.h"

extern alt_niosv_sw_isr_t alt_niosv_software_interrupt_handler;

// If the CLIC is present, enable/disable are applied to both MIE and CLICINTIE because this is faster than
// checking which interrupt controller is enabled.
// However if the CLIC is currently active, MIE is unaffected by CSR operations. 
// If the hart is in CLINT mode, clicintie can be written without changing to CLIC mode.  

static ALT_INLINE void ALT_ALWAYS_INLINE alt_niosv_enable_msw_interrupt() {
    NIOSV_SET_CSR(NIOSV_MIE_CSR, 0x1 << NIOSV_SOFTWARE_IRQ);
    #if NIOSV_HAS_CLIC
        NIOSV_WRITE_CSR(NIOSV_MISELECT_CSR, NIOSV_CSRIND_CLICINTIP_IE_BASE);
        NIOSV_SET_CSR  (NIOSV_MIREG2_CSR,   (0x1 << NIOSV_SOFTWARE_IRQ));
    #endif
}

static ALT_INLINE void ALT_ALWAYS_INLINE alt_niosv_disable_msw_interrupt() {
    NIOSV_CLR_CSR(NIOSV_MIE_CSR, 0x1 << NIOSV_SOFTWARE_IRQ);
    #if NIOSV_HAS_CLIC
        NIOSV_WRITE_CSR(NIOSV_MISELECT_CSR, NIOSV_CSRIND_CLICINTIP_IE_BASE);
        NIOSV_CLR_CSR  (NIOSV_MIREG2_CSR,   (0x1 << NIOSV_SOFTWARE_IRQ));
    #endif
}

static ALT_INLINE int ALT_ALWAYS_INLINE alt_niosv_is_msw_interrupt_enabled() {
    alt_u32 ie_val;
    NIOSV_READ_CSR(NIOSV_MIE_CSR, ie_val);
    #if NIOSV_HAS_CLIC
        // In CLIC mode, mie will read as all-zeroes. Just OR mie with clicintie
        register alt_u32 clicintie_val;
        NIOSV_WRITE_CSR(NIOSV_MISELECT_CSR, NIOSV_CSRIND_CLICINTIP_IE_BASE);
        NIOSV_READ_CSR (NIOSV_MIREG2_CSR, clicintie_val);
        ie_val |= clicintie_val;
    #endif   
    return ie_val & (0x1 << NIOSV_SOFTWARE_IRQ);
}

static ALT_INLINE volatile alt_u32 *const ALT_ALWAYS_INLINE alt_niosv_get_msip_addr() {
    return alt_niosv_get_mtimecmp_addr() + 2 + alt_niosv_read_mhartid();  
}

static ALT_INLINE void ALT_ALWAYS_INLINE alt_niosv_trigger_msw_interrupt() {
    volatile alt_u32 *const alt_niosv_msip = alt_niosv_get_msip_addr();
    *alt_niosv_msip = 0x1;
}

static ALT_INLINE void ALT_ALWAYS_INLINE alt_niosv_clear_msw_interrupt() {
    volatile alt_u32 *const alt_niosv_msip = alt_niosv_get_msip_addr();
    *alt_niosv_msip = 0x0;
}

static ALT_INLINE void ALT_ALWAYS_INLINE alt_niosv_register_msw_interrupt_handler(alt_niosv_sw_isr_t handle) {
    alt_niosv_software_interrupt_handler = handle;
}

#endif /* __M_SW_INTERRUPT_H__ */
