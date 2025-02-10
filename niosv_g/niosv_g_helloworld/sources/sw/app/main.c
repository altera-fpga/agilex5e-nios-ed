/*
 * Copyright (C) 2021 Intel Corporation
 * SPDX-License-Identifier: BSD-3-Clause
 */

#include <stdio.h> // Standard I/O functions
#include <unistd.h> // Standard library for usleep function

// Function to print "Hello world" messages in a loop
void looper() {
    for (int i = 0; i < 10; ++i) {
        printf("Hello world, this is the Nios V/g cpu checking in %d...\n", i);
    }
}

// Main function
int main() {
    looper(); // Call the looper function
    usleep(1000); // Sleep for 1000 microseconds
    printf("Bye world!\n"); // Print goodbye message
    return 0; // Exit the application
}
