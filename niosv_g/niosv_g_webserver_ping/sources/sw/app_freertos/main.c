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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <io.h>
#include <stdbool.h>
#include <fcntl.h>
#include <sys/termios.h>
#include "sys/ioctl.h"
#include "sys/alt_log_printf.h"
#include "system.h"
#include "altera_avalon_pio_regs.h"
#include "altera_avalon_sysid_qsys.h"
#include "altera_avalon_sysid_qsys_regs.h"
#include "altera_avalon_jtag_uart_regs.h"
#include "altera_avalon_jtag_uart.h"
 
#include "task.h" 
#include "timers.h" 
#include "FreeRTOS.h"
#include "FreeRTOS_IP.h"
#include "FreeRTOS_Sockets.h"
#include "FreeRTOS_TCP_IP.h"
#include "FreeRTOS_IP.h"
#include "FreeRTOSIPConfig.h"
#include "FreeRTOS_Routing.h"

#include "tse_driver.h"

#define PING_TASK_STACKSIZE 2048
#define PING_TASK_PRIORITY  (configMAX_PRIORITIES - 1)

static TaskHandle_t xPingTaskHandle = NULL;

void generate_random_mac(uint8_t * mac_address)
{
    // Set the locally administered bit (0x02 in the first octet)
    mac_address[0] = 0x02; 

    // Generate random bytes for the remaining 5 octets
    for ( int i = 1; i < 6; i++ )
    {
        mac_address[i] = (uint8_t)rand();
    }
}

void vPingTestTask(void *pvParameters)
{
    const uint8_t ucIPAddressToPing[4] = { 192, 168, 1, 50 };
    uint32_t ucIPAddress;

    if(!FreeRTOS_inet_pton(FREERTOS_AF_INET, "192.168.1.50", &ucIPAddress))
        printf("IP address conversion failure\n");

    const TickType_t xDelayBetweenPings = pdMS_TO_TICKS(1000);

    xPingTaskHandle = xTaskGetCurrentTaskHandle();
    ulTaskNotifyTake(pdTRUE, portMAX_DELAY);

    for (;;)
    {
        BaseType_t xResult = FreeRTOS_SendPingRequest(ucIPAddress,
                                                      1024,          // Ping data size
                                                      1000000);    // Timeout in ms

        if (xResult != pdFAIL)
        {
            printf("[PING] Request Sent: %u.%u.%u.%u Identifier %lu\n",
                   ucIPAddressToPing[0], ucIPAddressToPing[1],
                   ucIPAddressToPing[2], ucIPAddressToPing[3], xResult);
        }
        else
        {
            printf("[PING] Request Failed: %u.%u.%u.%u\n",
                   ucIPAddressToPing[0], ucIPAddressToPing[1],
                   ucIPAddressToPing[2], ucIPAddressToPing[3]);
        }
        vTaskDelay(xDelayBetweenPings);
    }
}

BaseType_t xApplicationGetRandomNumber( uint32_t *pulNumber )
{
    *pulNumber = ( uint32_t ) rand();
    return pdTRUE;
}

uint32_t ulApplicationGetNextSequenceNumber(
    uint32_t ulSourceAddress,
    uint16_t usSourcePort,
    uint32_t ulDestinationAddress,
    uint16_t usDestinationPort)
{
    return ( uint32_t ) rand();
}

const char *pcApplicationHostnameHook(void)
{
    return "MyFreeRTOSDevice";
}

BaseType_t xApplicationDNSQueryHook(const char *pcName)
{
    if (strcasecmp(pcName, pcApplicationHostnameHook()) == 0)
    {
        return pdPASS;
    }

    return pdFAIL;
}

void vApplicationPingReplyHook(ePingReplyStatus_t eStatus, uint16_t usIdentifier) {
    switch (eStatus) {
        case eSuccess:
            printf("[Ping] Reply received: Identifier %u\n", usIdentifier);
            break;
        case eInvalidChecksum:
            printf("[Ping] Reply received with invalid checksum: Identifier %u\n", usIdentifier);
            break;
        case eInvalidData:
            printf("[Ping] reply received with invalid data: Identifier %u\n", usIdentifier);
            break;
        default:
            printf("[Ping] Unknown ping reply status: Identifier %u\n", usIdentifier);
            break;
    }
}

void vApplicationIPNetworkEventHook( eIPCallbackEvent_t eNetworkEvent )
{
    char cBuffer[ 16 ];  

    if (eNetworkEvent == eNetworkUp)
    {
        FreeRTOS_printf(("Network is UP!\n"));

        uint32_t ulIPAddress, ulNetMask, ulGatewayAddress, ulDNSServerAddress;  
        FreeRTOS_GetAddressConfiguration(
            &ulIPAddress,
            &ulNetMask,
            &ulGatewayAddress,
            &ulDNSServerAddress
        );

        FreeRTOS_inet_ntoa( ulIPAddress, cBuffer );  
        printf( "IP Address: %s\n", cBuffer );  
  
        /* Convert the net mask to a string then print it out. */  
        FreeRTOS_inet_ntoa( ulNetMask, cBuffer );  
        printf( "Subnet Mask: %s\n", cBuffer );  
  
        /* Convert the IP address of the gateway to a string then print it out. */  
        FreeRTOS_inet_ntoa( ulGatewayAddress, cBuffer );  
        printf( "Gateway IP Address: %s\n", cBuffer );  
  
        /* Convert the IP address of the DNS server to a string then print it out. */  
        FreeRTOS_inet_ntoa( ulDNSServerAddress, cBuffer );  
        printf( "DNS server IP Address: %s\n", cBuffer ); 
    }
    xTaskNotifyGive(xPingTaskHandle);
}

BaseType_t vInitialiseNetworkInterface()
{
    const uint8_t ucIPAddress[ 4 ]  = { 192, 168, 1, 40 };
    const uint8_t ucNetMask[ 4 ]    = { 255, 255, 255, 0 };
    const uint8_t ucGateway[ 4 ]    = { 192, 168, 1, 1 };
    const uint8_t ucDNSServer[ 4 ]  = { 8, 8, 8, 8 };
    uint8_t ucMACAddress[ 6 ];
    
    generate_random_mac(ucMACAddress);

	BaseType_t ret = FreeRTOS_IPInit(
        ucIPAddress,
        ucNetMask,
        ucGateway,
        ucDNSServer,
        ucMACAddress
    );
    return ret;
}

int main(void)
{
	printf("Hello FreeRTOS from main...\n");

    if(!vInitialiseNetworkInterface()) {
        printf("Network initialization failure. System Halted\n");
        while(1);
    }

    if (pdFAIL == xTaskCreate( vPingTestTask, "vPingTestTask", PING_TASK_STACKSIZE, NULL, PING_TASK_PRIORITY, &xPingTaskHandle)){
		printf("Ping Task creation fail!!!!\n");
	}
	vTaskStartScheduler();

	for( ;; );
}
