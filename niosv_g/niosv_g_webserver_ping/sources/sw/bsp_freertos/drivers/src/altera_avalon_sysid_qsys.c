/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2003 Altera Corporation, San Jose, California, USA.           *
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

#include "altera_avalon_sysid_qsys.h"
#include "altera_avalon_sysid_qsys_regs.h"
#include "alt_types.h"
#include <io.h>

/*
*  This component is special: there's only one of it.
*  Therefore we can dispense with a bunch of complexity
*  normally associated with components, such as specialized
*  structs containing parameter info, and instead use that
*  info by name directly out of system.h.  A downside of this
*  approach is that each time the system is regenerated, and
*  system.h changes, this file must be recompiled.  Fortunately
*  this file is, and is likely to remain, quite small.
*/
#include "system.h"

#ifdef SYSID_BASE
/*
*  return values:
*    0 if the hardware and software appear to be in sync
     1 , otherwise
*/

alt_32 alt_avalon_sysid_qsys_test(void)
{
  /* Read the hardware-tag, aka value0, from the hardware. */
  alt_u32 hardware_id = IORD_ALTERA_AVALON_SYSID_QSYS_ID(SYSID_BASE);

  /* Return 0 if the hardware and software appear to be in sync, else 1 would be returned.*/
  /*
	Time stamp check is removed now and will not be used to validate the software and hardware integrity. 
	Though the HDL generation time stamp can still be read via TIMESTAMP_REGISTER (offset 0x04) as an
	information to the USER.
	
	The SYSID (at offset 0x00) will now contains the manually entered System ID or auto-generated HASH CRC32 
	value. From the System ID driver perspective, it is transparent and the same will be validated as desired.
*/

   if (SYSID_ID == hardware_id)
  {
    return 0;
  }
  return 1;
}
#endif
