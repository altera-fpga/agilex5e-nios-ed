/*
 * Copyright (C) 2021 Intel Corporation
 * SPDX-License-Identifier: BSD-3-Clause
 */

#include <stdio.h>
#include <unistd.h>

void looper() {
    for (int i = 0; i < 10; ++i) {
        printf("Hello world, this is the Nios V/g cpu checking in %d...\n", i);
    }
}

int main() {
    looper();
    usleep(1000);
    printf("Bye world!\n");
    return 0;
}
