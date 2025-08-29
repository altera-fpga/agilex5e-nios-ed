/*
 * Copyright (C) 2021 Intel Corporation
 * SPDX-License-Identifier: BSD-3-Clause
 */

#include <stdio.h>
#include <unistd.h>

// Function to print a message multiple times in a loop
void looper() {
    for (int i = 0; i < 10; ++i) {
        printf("Hello world, this is the Nios V/g cpu checking in %d...\n", i);
    }
}

// Main function
int main() {
    // Call the looper function to print messages
    looper();
    
    // Introduce a short delay before program exits
    usleep(1000);
    
    // Print exit message
    printf("Bye world!\n");
    
    return 0;
}

