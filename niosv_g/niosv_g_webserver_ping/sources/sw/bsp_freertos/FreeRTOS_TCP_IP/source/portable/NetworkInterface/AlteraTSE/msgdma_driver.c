/*
 * License Agreement
 *
 * Copyright (c) 2025
 * Altera Corporation, San Jose, California, USA.
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
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
 * This agreement shall be governed in all respects by the laws of the State
 * of California and by the laws of the United States of America.
 */

#include "FreeRTOS.h"
#include "FreeRTOS_IP.h"
#include "FreeRTOS_IP_Private.h"
#include "NetworkBufferManagement.h"

#include <task.h>
#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include "sys/alt_cache.h"
#include "msgdma_driver.h"

static TaskHandle_t xRxTask = NULL;
static size_t sys_desc_mem_index = 0;

void* sys_desc_malloc(size_t size)
{
    if (sys_desc_mem_index + size > SYS_DESC_MEM_SIZE) {
        return NULL; // Not enough memory
    }
    void* ptr = SYS_DESC_MEM_START + sys_desc_mem_index;
    sys_desc_mem_index += size;
    // Zero out the allocated memory
    memset(ptr, 0, size);
    return ptr;
}

ALTERA_MSGDMA_CSR_PREFETCHER_CSR_INSTANCE (SYS_TSE_MSGDMA_RX, SYS_TSE_MSGDMA_RX_CSR, SYS_TSE_MSGDMA_RX_PREFETCHER_CSR, sys_tse_msgdma_rx);
ALTERA_MSGDMA_CSR_PREFETCHER_CSR_INSTANCE (SYS_TSE_MSGDMA_TX, SYS_TSE_MSGDMA_TX_CSR, SYS_TSE_MSGDMA_TX_PREFETCHER_CSR, sys_tse_msgdma_tx);

// Start an mSGDMA with a descriptor list.
//  - Park mode is disabled.
//  - Poll mode is disabled.
//  - Last descriptor should be owned by SW before started.
//  - Flush descriptor list from dcache.
#define MSGDMA_START_LIST(msgdma, list) alt_msgdma_start_prefetcher_with_std_desc_list(msgdma, list, 0, 0, 1, 1)

typedef struct NET_DEV_data NET_DEV_DATA;
NET_DEV_DATA *pdev_data;

static BaseType_t msgdma_InitRxDescList(NET_DEV_DATA *pdev_data, bool refill)
{
    alt_u8     desc_idx;
    alt_u8    *write_address = NULL;
    alt_u32        control;
    alt_u32        net_buf_size;
    desc_t        *desc;
    desc_t        *llist;
    int            result;
    NetworkBufferDescriptor_t *pxBuffer = NULL;

    net_buf_size = ALTERA_TSE_MAC_MAX_FRAME_LENGTH;
    configASSERT(ALTERA_TSE_MAC_MAX_FRAME_LENGTH <= pdev_data->RxMsgdma->max_byte);

    llist = NULL;

    for (desc_idx = 0; desc_idx < ALTERA_TSE_MSGDMA_RX_DESC_CHAIN_SIZE; desc_idx++) {
        desc = &(pdev_data->RxList[desc_idx]);

        // Trigger interrupt when transfer is complete.
        // control  = ALTERA_MSGDMA_DESCRIPTOR_CONTROL_ERROR_IRQ_MASK;
        control  = 0;
        control |= ALTERA_MSGDMA_DESCRIPTOR_CONTROL_END_ON_EOP_MASK;
        control |= ALTERA_MSGDMA_DESCRIPTOR_CONTROL_TRANSFER_COMPLETE_IRQ_MASK;

        if (desc_idx == (ALTERA_TSE_MSGDMA_RX_DESC_CHAIN_SIZE - 1)) {        /* Last descriptor is terminating and does not need a write buffer. */
            write_address = NULL;
        }
        else {
            pxBuffer = pxGetNetworkBufferWithDescriptor(ALTERA_TSE_MAC_MAX_FRAME_LENGTH, 1000);
            configASSERT(pxBuffer != NULL);

            // Assign buffer to DMA descriptor
            write_address = pxBuffer->pucEthernetBuffer;

            pdev_data->pxRxBufferMap[desc_idx] = pxBuffer;
            //memset(write_address, 0, ALTERA_TSE_MAC_MAX_FRAME_LENGTH);
        }

        if (refill == pdFALSE) {

            // Flush the addresses from the dcache lines so any writeback after
            // this won't overwrite data from the mSGDMA. No writeback here
            // because there is nothing useful in these lists yet.
            alt_dcache_flush_no_writeback(write_address, net_buf_size);

            // Initialize the descriptor values.
            result = alt_msgdma_construct_prefetcher_standard_st_to_mm_descriptor(
                    pdev_data->RxMsgdma,     // mSGDMA
                    desc,                    // descriptor
                    (alt_u32) write_address, // write address low (buffer address)
                    net_buf_size,            // buffer length
                    control                  // register control
            );

            if (result != 0) {
                printf("RX mSGDMA initializing descriptor %d: FAILED.\n",
                    desc_idx);
                if(write_address != NULL)
                    vReleaseNetworkBufferAndDescriptor(pxBuffer);
                return pdFAIL;
            }

            // Add descriptor to list.
            int rc = alt_msgdma_prefetcher_add_standard_desc_to_list(&llist, desc);
            if (rc != 0) {
                printf("RX mSGDMA add standard descriptor %d to list: FAILED.\n", desc_idx);
                if(write_address != NULL)
                    vReleaseNetworkBufferAndDescriptor(pxBuffer);
                return pdFAIL;
            }
        }
    }
    return pdPASS;
}

static  BaseType_t  msgdma_InitTxDescList (NET_DEV_DATA *pdev_data)
{
    desc_t      *desc;
    desc_t      *llist;     /* Used for tracking linked list in descriptor list construction. */
    alt_u32     control;
    int         ret;
    alt_u32     desc_idx;

    llist = NULL;

    for (desc_idx = 0; desc_idx < ALTERA_TSE_MSGDMA_TX_DESC_CHAIN_SIZE; desc_idx++) {

        desc = &(pdev_data->TxList[desc_idx]);

        control  = 0;                                                            /* Set control for Avalon MM-ST transfer.     */
        control |= ALTERA_MSGDMA_DESCRIPTOR_CONTROL_GENERATE_SOP_MASK;           /* Emit start of packet.                      */
        control |= ALTERA_MSGDMA_DESCRIPTOR_CONTROL_GENERATE_EOP_MASK;           /* Emit end of packet.                        */
        control |= ALTERA_MSGDMA_DESCRIPTOR_CONTROL_EARLY_TERMINATION_IRQ_MASK;  /* Interrupt if EOP not seen and above size.  */
        control |= ALTERA_MSGDMA_DESCRIPTOR_CONTROL_TRANSFER_COMPLETE_IRQ_MASK;  /* Interrupt when succesful completion.       */

        ret = alt_msgdma_construct_prefetcher_standard_mm_to_st_descriptor(
                pdev_data->TxMsgdma,
                desc,     // descriptor
                0x0,      // read address low
                0x0,      // length
                control   // control
        );
        if (ret != 0) {
            printf("TX mSGDMA Init data to mSGDMA: FAILED (%d).\n", ret);
            return pdFAIL;
        }

        ret = alt_msgdma_prefetcher_add_standard_desc_to_list(&llist, desc);
        if (ret != 0) {
            printf("TX mSGDMA Add standard descriptor to list: FAILED.\n");
            return pdFAIL;
        }
    }
    return pdPASS;
}

static  BaseType_t  msgdma_InitRxAndTxDescLists (NET_DEV_DATA *dev)
{
    // Initialize RX descriptor List.
    {
        FreeRTOS_debug_printf( ("RX mSGDMA Descriptor Initialization: Starting.\n") );

        if (!msgdma_InitRxDescList(dev, pdFALSE)) {
            printf("RX mSGDMA Descriptor Initialization: FAILED.\n");
            return pdFAIL;
        }

        printf("RX mSGDMA Descriptor Initialization: Success.\n");
    }
    // Initialize Tx descriptor list.
    {
        FreeRTOS_debug_printf( ("Tx descriptor list initialization: Starting.\n") );

        if (!msgdma_InitTxDescList(dev)) {
            printf("Tx descriptor list initialization: FAILED.\n");
            return pdFAIL;
        }

        printf("Tx descriptor list initialization: Success.\n");
    }
    return pdPASS;
}

void msgdma_tx_isr(NET_DEV_DATA *pdev_data)
{
    alt_u32       reg_data;
    desc_t       *desc;

    pdev_data->StatTxIsrHit += 1;

    reg_data = IORD_ALTERA_MSGDMA_CSR_STATUS(pdev_data->TxMsgdma->csr_base);

    if ((reg_data & ALTERA_MSGDMA_CSR_STOPPED_ON_ERROR_MASK) ||
        (reg_data & ALTERA_MSGDMA_CSR_STOPPED_ON_EARLY_TERMINATION_MASK)) {
        pdev_data->StatTxIsrMsgdmaError += 1;
        printf("Tx mSGDMA descriptor is in error.\n");
        return;
    }

    // If no errors, then things should have succeeded.
    pdev_data->StatTxSuccessPackets += 1;

    // Cleanup data buffer now that processing is done.
    desc = &(pdev_data->TxList[0]);

    desc->read_address = 0; // Clear the address from the descriptor.

    return;
}

void refillDescriptor(uint8_t index)
{
    desc_t *list;
    desc_t *desc;
    alt_u32 reg_data_32;
    alt_u32 i, attempt;
    alt_u32 result = 0;

    list = pdev_data->RxList;                               /* Get the list HW is operating on. */

    for (i = 0; i != IDX_RX_LAST_NULL_DESC; i++) {
        desc = &(list[i]);
        
        alt_dcache_flush(desc, sizeof(desc_t));

        reg_data_32 = IORD_32DIRECT(&(desc->control), 0);
    
        if (reg_data_32 & ALT_MSGDMA_PREFETCHER_DESCRIPTOR_CTRL_OWN_BY_HW_SET_MASK) {  /* If descriptor is owned by HW, then all */
            FreeRTOS_debug_printf( ("All descriptors owned by HW\n") );
            break;                                                                     /* descriptors after will be owned by HW. */
        }
        else {

            NetworkBufferDescriptor_t *pxBuffer = pdev_data->pxRxBufferMap[index];

            if (pxBuffer != NULL)
            {
                pxBuffer->xDataLength = desc->bytes_transfered;
                pxBuffer->pucEthernetBuffer = (alt_u8 *)(desc->write_address);
            
                #ifdef MSGDMA_DEBUG
                printf("Rx Desc write address = 0x%x length = %d\n", desc->write_address, desc->bytes_transfered);
                for (j = 0; j < (desc->bytes_transfered); j++) {
                    printf("%02X ", ((uint8_t *)desc->write_address)[j]);
                }
                printf("\n");
                #endif
                IPStackEvent_t xRxEvent = {
                    .eEventType = eNetworkRxEvent,
                    .pvData = pxBuffer
                };
                pxBuffer->pxInterface = pdev_data->pxSavedInterface;
                pxBuffer->pxEndPoint = FreeRTOS_MatchingEndpoint(pdev_data->pxSavedInterface, pxBuffer->pucEthernetBuffer);

                if (xSendEventStructToIPTask( &xRxEvent, 0) == pdFALSE)
                {
                    printf("Failed to queue, release buffer\n");
                    vReleaseNetworkBufferAndDescriptor(pxBuffer);
                }
            }
            else
            {
                vReleaseNetworkBufferAndDescriptor(pxBuffer);
            }
        }
    }

    for (attempt=0; attempt < MAX_ATTEMPT_COUNT; attempt++) {
        // Attempt to initialize the RX descriptor list with retries
        if (!msgdma_InitRxDescList(pdev_data, pdTRUE)) {
            printf("RX mSGDMA Descriptor Refill Attempt %ld: FAILED.\n", attempt);
        }
        else {
            //printf("RX mSGDMA Descriptor Refill Attempt %d: SUCCESS.\n", attempt);
            break;
        }
    }
    if (attempt == MAX_ATTEMPT_COUNT) {
        printf("All attempts to refill RX mSGDMA Descriptor have failed.\n");
        return;
    }

    for (attempt=0; attempt < MAX_ATTEMPT_COUNT; attempt++) {
    // Attempt to initialize the RX descriptor list with retries
        result = MSGDMA_START_LIST(pdev_data->RxMsgdma, pdev_data->RxList);
        if (result != 0) {
            printf("mSGDMA Rx Re-initialization Attempt %ld: Failed to start Rx list.\n", attempt);
        } else {
            FreeRTOS_debug_printf( ("mSGDMA Rx Re-initialization Attempt %d: Success to start Rx list.\n", attempt) );
            break;
        }
    }
    if (attempt == MAX_ATTEMPT_COUNT) {
        printf("All attempts to re-initialize RX mSGDMA have failed.\n");
        return;
    }

    IOWR_ALT_MSGDMA_PREFETCHER_STATUS(pdev_data->RxMsgdma->prefetcher_base, ALT_MSGDMA_PREFETCHER_STATUS_IRQ_CLR_MASK);
    // Re_enable global interrupts so we don't miss one that occurs during the
    // processing of this ISR.
    reg_data_32  = IORD_ALT_MSGDMA_PREFETCHER_CONTROL(pdev_data->RxMsgdma->csr_base);
    reg_data_32 |= ALT_MSGDMA_PREFETCHER_CTRL_GLOBAL_INTR_EN_SET_MASK;
    IOWR_ALT_MSGDMA_PREFETCHER_CONTROL(pdev_data->RxMsgdma->csr_base, reg_data_32);

    pdev_data->RxIsrNextDesc += 1;
}

static void vRefillRxBufferTask(void *pvParameters)
{
    xRxTask = xTaskGetCurrentTaskHandle();

    for (;;)
    {
        ulTaskNotifyTake( pdTRUE, portMAX_DELAY );  
        refillDescriptor(0);
        vTaskDelay(pdMS_TO_TICKS(500));
    }
}

void msgdma_rx_isr(void)
{
    BaseType_t xRefillTaskWoken = pdFALSE;

    pdev_data->StatRxIsrHit += 1;

    vTaskNotifyGiveFromISR( xRxTask, &xRefillTaskWoken );  
    portYIELD_FROM_ISR(xRefillTaskWoken);
}

void msgdma_init(NetworkInterface_t *pxInterface)
{
    pdev_data = (NET_DEV_DATA *)malloc(sizeof(NET_DEV_DATA));

    if (pdev_data == NULL) {
        printf("Memory allocation failed\n");
        return;
    }
    pdev_data->TxMsgdma = NULL;
    pdev_data->RxMsgdma = NULL;

    pdev_data->pxSavedInterface = pxInterface;
    // Set RX state trackers.
    pdev_data->RxListHwOwned = -1;
    pdev_data->RxIsrNextDesc = 0;
    pdev_data->RxPendListNextDesc = 0;

    // Zero statistic counters.
    pdev_data->StatRxSuccessPackets = 0;
    pdev_data->StatTxSuccessPackets = 0;

    pdev_data->StatRxIsrHit = 0;
    pdev_data->StatRxIsrButNoHwOwnedList = 0;
    pdev_data->StatRxIsrQueueFull = 0;

    pdev_data->StatTxIsrHit = 0;
    pdev_data->StatTxIsrMsgdmaError = 0;
    pdev_data->StatTxIsrDeallocError = 0;

    // Initialize mSGDMA memory.
    // Descriptor list sizes - terminating descriptor is already included in the count.
    size_t rx_list_size = ALTERA_TSE_MSGDMA_RX_DESC_CHAIN_SIZE * sizeof(desc_t);
    size_t tx_list_size = ALTERA_TSE_MSGDMA_TX_DESC_CHAIN_SIZE * sizeof(desc_t);

    // Allocate descriptor lists on the heap.
    {
        //printf("mSGDMA desc list allocation: Starting.\n");

        pdev_data->RxList = (desc_t *) sys_desc_malloc(rx_list_size);
        if (pdev_data->RxList == NULL) {
            printf("mSGDMA descriptor list allocation: Rx FAILED.\n");
            return;
        }

        pdev_data->TxList = (desc_t *) sys_desc_malloc(tx_list_size);
        if (pdev_data->TxList == NULL) {
            printf("mSGDMA descriptor list allocation: Tx FAILED.\n");
            return;
        }
        printf("mSGDMA desc list allocation: Success.\n");
    }

    //printf("Acquiring RX and TX alt_msgdma_dev: Starting.\n");
    pdev_data->RxMsgdma = alt_msgdma_open(sys_tse_msgdma_rx.name);
    if (pdev_data->RxMsgdma == NULL) {
        printf("Rx mSGDMA Open '%s': FAILED.\n", sys_tse_msgdma_rx.name);
        return;
    }

    pdev_data->TxMsgdma = alt_msgdma_open(sys_tse_msgdma_tx.name);
    if (pdev_data->TxMsgdma == NULL) {
        printf("Tx mSGDMA Open '%s': FAILED.\n", sys_tse_msgdma_tx.name);
        return;
    }

    printf("Acquiring RX and TX alt_msgdma_dev: Success.\n");

    //Register mSGDMA descriptor ISR.
    {
        FreeRTOS_debug_printf( ("mSGDMA RX ISR Registering: Starting.\n") );
        alt_msgdma_register_callback(
                pdev_data->RxMsgdma,                        // mSGDMA device
                (alt_msgdma_callback) msgdma_rx_isr, // callback function
                0,                                          // control
                NULL);                                       // arguments/context
        printf("mSGDMA RX ISR Registering: Success.\n");

        FreeRTOS_debug_printf( ("mSGDMA TX ISR Registering: Starting.\n") );
        alt_msgdma_register_callback(
                pdev_data->TxMsgdma,                        // mSGDMA device
                (alt_msgdma_callback) msgdma_tx_isr, // callback function
                0,                                          // control
                NULL);                                       // arguments/context
        printf("mSGDMA TX ISR Registering: Success.\n");
    }
    //Initialize mSGDMA descriptors (and descriptor lists).
    {
        FreeRTOS_debug_printf( ("mSGDMA descriptor list initialization: Starting.\n") );
        if (!msgdma_InitRxAndTxDescLists(pdev_data)) {
            printf("mSGDMA descriptor list initialization: FAILED.\n");
            return;
        }
        // Now point Rx mSGDMA prefetcher to the Rx list
        pdev_data->RxListHwOwned = 0;
        alt_u32 result = MSGDMA_START_LIST(pdev_data->RxMsgdma, pdev_data->RxList);
        if (result != 0) {
            printf("mSGDMA Initialization: Failed to start Rx list.\n");
            return;
        }
        printf("mSGDMA descriptor list initialization: Success.\n");
    }
    xTaskCreate(vRefillRxBufferTask, "RxRefill", 2048, NULL, tskIDLE_PRIORITY + 1, &xRxTask);
	return;
}

int msgdma_send_copy(uint8_t *p_data, size_t size)
{
    int            rc;
    desc_t        *data_desc;
    desc_t        *null_desc;

    data_desc = &(pdev_data->TxList[0]);
    null_desc = &(pdev_data->TxList[1]);

    /* Initialize descriptor with given buffer and size. */
    data_desc->read_address   = (alt_u32) p_data;
    data_desc->transfer_length    = size;
    data_desc->control           &= ALT_MSGDMA_PREFETCHER_DESCRIPTOR_CTRL_OWN_BY_HW_CLR_MASK;
    data_desc->next_desc_ptr  = (alt_u32) null_desc;
    null_desc->next_desc_ptr  = (alt_u32) data_desc;

    alt_dcache_flush(p_data, size);               /* Ensure the buffer is flushed before it is passed to the mSGDMA. */
    alt_dcache_flush(data_desc, sizeof(desc_t));  /* Ensure the descriptor is flushed */
    alt_dcache_flush(null_desc, sizeof(desc_t));

    /* Start the asynchronous send. */
    rc = MSGDMA_START_LIST(pdev_data->TxMsgdma, pdev_data->TxList);
    if (rc != 0) {
        printf("Failed start async send to TX mSGDMA: %d\n", rc);
        return -1;
    }

    FreeRTOS_debug_printf( ("Async send to TX mSGDMA: Success.\n") );
    return 0;
}

void msgdma_print_statistics()
{
    uint32_t    rx_success;
    uint32_t    tx_success;

    uint32_t    rx_isr_hit;
    uint32_t    rx_isr_no_hw_owned;
    uint32_t    rx_isr_queue_full;

    uint32_t    tx_isr_hit;
    uint32_t    tx_isr_msgdma_err;
    uint32_t    tx_isr_dealloc_err;


    rx_isr_hit         = IORD_32DIRECT(&(pdev_data->StatRxIsrHit),              0);
    rx_isr_no_hw_owned = IORD_32DIRECT(&(pdev_data->StatRxIsrButNoHwOwnedList), 0);
    rx_isr_queue_full  = IORD_32DIRECT(&(pdev_data->StatRxIsrQueueFull),        0);

    tx_isr_hit         = IORD_32DIRECT(&(pdev_data->StatTxIsrHit),          0);
    tx_isr_msgdma_err  = IORD_32DIRECT(&(pdev_data->StatTxIsrMsgdmaError),  0);
    tx_isr_dealloc_err = IORD_32DIRECT(&(pdev_data->StatTxIsrDeallocError), 0);

    rx_success = IORD_32DIRECT(&(pdev_data->StatRxSuccessPackets), 0);
    tx_success = IORD_32DIRECT(&(pdev_data->StatTxSuccessPackets), 0);

    printf("Rx recvd  : %lu\n", rx_success);
    printf("Tx sent   : %lu\n", tx_success);
    printf("\n");
    printf("Rx ISR hit         : %lu\n", rx_isr_hit);
    printf("Rx ISR no hw list  : %lu\n", rx_isr_no_hw_owned);
    printf("Rx ISR queue full  : %lu\n", rx_isr_queue_full);
    printf("\n");
    printf("Tx ISR hit         : %lu\n", tx_isr_hit);
    printf("Tx ISR msgdma err  : %lu\n", tx_isr_msgdma_err);
    printf("Tx ISR dealloc err : %lu\n", tx_isr_dealloc_err);
}
