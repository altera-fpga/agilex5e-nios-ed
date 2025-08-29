/*
 * Copyright (C) 2023 Intel Corporation
 * SPDX-License-Identifier: BSD-3-Clause
 */

#include <stdio.h>
#include "FreeRTOS.h"
#include "task.h"
#include "timers.h"
#include "semphr.h"

#define TASK_STACKSIZE  2048

/* Task priority setting : Task1 > Task2 > Task3 */
#define TASK1_PRIORITY  (tskIDLE_PRIORITY + 3)
#define TASK2_PRIORITY  (tskIDLE_PRIORITY + 2)
#define TASK3_PRIORITY  (tskIDLE_PRIORITY + 1)

SemaphoreHandle_t g_mutex;

#define NUM_PRINTS_PER_TASK 5

int t1_ms_slept = 750 / portTICK_PERIOD_MS;
int t2_ms_slept = 450 / portTICK_PERIOD_MS;
int t3_ms_slept = 250 / portTICK_PERIOD_MS;

void prvTask1(void* pvParameters)
{
    int i = 0;
	int ms_slept = (*((int *)pvParameters));
	while (1)
	{
        xSemaphoreTake(g_mutex,portMAX_DELAY);
        if (i < NUM_PRINTS_PER_TASK) {
	        printf("Hello from task1: %d\n\n", i++);
        }
        xSemaphoreGive(g_mutex);
		vTaskDelay(ms_slept);
	}
}

void prvTask2(void* pvParameters)
{
    int i = 0;
	int ms_slept = (*((int *)pvParameters));
	while (1)
	{
        xSemaphoreTake(g_mutex,portMAX_DELAY);
        if (i < NUM_PRINTS_PER_TASK) {
	        printf("Hello from task2: %d\n\n", i++);
        }
        xSemaphoreGive(g_mutex);
		vTaskDelay(ms_slept);
	}
}

void prvTask3(void* pvParameters)
{
    int i = 0;
	int ms_slept = (*((int *)pvParameters));
	while (1)
	{
        xSemaphoreTake(g_mutex,portMAX_DELAY);
        if (i < NUM_PRINTS_PER_TASK) {
	        printf("Hello from task3: %d\n\n", i++);
        }
        xSemaphoreGive(g_mutex);
		vTaskDelay(ms_slept);
	}
}

int main(void)
{
	printf("Hello FreeRTOS from main...\n");

    g_mutex = xSemaphoreCreateMutex();

	if (pdFAIL == xTaskCreate( prvTask1, "Task1", TASK_STACKSIZE,
				              &t1_ms_slept, TASK1_PRIORITY, NULL )){
		printf("Task1 creation fail!!!!\n");
	}
	if (pdFAIL == xTaskCreate( prvTask2, "Task2", TASK_STACKSIZE,
				              &t2_ms_slept, TASK2_PRIORITY, NULL )){
		printf("Task2 creation fail!!!!\n");
	}
	if (pdFAIL == xTaskCreate( prvTask3, "Task3", TASK_STACKSIZE,
				              &t3_ms_slept, TASK3_PRIORITY, NULL )){
		printf("Task3 creation fail!!!!\n");
	}

	vTaskStartScheduler();
    
	for( ;; );
}
