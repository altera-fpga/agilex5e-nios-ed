#ifndef _ALT_ECC_ERROR_INJECT_H_
#define _ALT_ECC_ERROR_INJECT_H_

/*
 * Copyright (c) 2024 Altera Corporation, San Jose, California, USA.  
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
 */

#include "alt_types.h"
#include "system.h"

/*
 * The following enumeration describes the value in the mtval2
 * for ECC error. The same value could be used for ECC error injection.
 */
enum alt_ecc_error_type_e {
        NIOSV_GPR_ECC_CORRECTABLE_ERROR                          = 0,
	NIOSV_GPR_ECC_UNCORRECTABLE_ERROR                        = 1,
        NIOSV_FPR_ECC_CORRECTABLE_ERROR                          = 2,
	NIOSV_FPR_ECC_UNCORRECTABLE_ERROR                        = 3,
        NIOSV_VPR_ECC_CORRECTABLE_ERROR                          = 4,
	NIOSV_VPR_ECC_UNCORRECTABLE_ERROR                        = 5,
	NIOSV_CSR_ECC_UNCORRECTABLE_ERROR                        = 7,
        NIOSV_INSTRUCTION_CACHE_TAG_RAM_ECC_CORRECTABLE_ERROR    = 8,
	NIOSV_INSTRUCTION_CACHE_TAG_RAM_ECC_UNCORRECTABLE_ERROR  = 9,
        NIOSV_INSTRUCTION_CACHE_DATA_RAM_ECC_CORRECTABLE_ERROR   = 10,
	NIOSV_INSTRUCTION_CACHE_DATA_RAM_ECC_UNCORRECTABLE_ERROR = 11,
	NIOSV_INSTRUCTION_LOAD_ECC_CORRECTABLE_ERROR             = 12,
	NIOSV_INSTRUCTION_LOAD_ECC_UNCORRECTABLE_ERROR           = 13,
        NIOSV_DATA_CACHE_TAG_RAM_ECC_CORRECTABLE_ERROR           = 16,
	NIOSV_DATA_CACHE_TAG_RAM_ECC_UNCORRECTABLE_ERROR         = 17,
        NIOSV_DATA_CACHE_DATA_RAM_ECC_CORRECTABLE_ERROR          = 18,
	NIOSV_DATA_CACHE_DATA_RAM_ECC_UNCORRECTABLE_ERROR        = 19,
	NIOSV_DATA_LOAD_ECC_CORRECTABLE_ERROR                    = 20,
	NIOSV_DATA_LOAD_ECC_UNCORRECTABLE_ERROR                  = 21,
	NIOSV_DATA_STORE_ECC_CORRECTABLE_ERROR                   = 22,
	NIOSV_DATA_STORE_ECC_UNCORRECTABLE_ERROR                 = 23,
        NIOSV_ENABLE_ECC_ERROR                                   = (1<<31)
};
typedef enum alt_ecc_error_type_e alt_ecc_error_type;

void alt_ecc_error_inject(alt_ecc_error_type error_type);

#endif /* _ALT_ECC_ERROR_INJECT_H_ */
