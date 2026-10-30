/*
 * calibrate.c
 * Chrome Dinosaur Game — Accelerometer Calibration Tool
 * ECE 3140 / CS 3420
 *
 * Streams raw X/Y/Z accelerometer data over serial at 115200 baud.
 * Use this to find jump thresholds before running FinalProject.c.
 *
 * Usage: flash to board, run python_serial.py, move/jump, observe Y axis spikes.
 */

#include <pin_mux.h>
#include <clock_config.h>
#include <stdio.h>
#include <board.h>
#include <MKL46Z4.h>
#include <fsl_debug_console.h>
#include "3140_i2c.h"
#include "3140_accel.h"

/*------------------------------*/
/* UART communication functions */
/*------------------------------*/

void init_uart(void) {
    BOARD_InitBootPins();
    BOARD_InitBootClocks();
    BOARD_InitDebugConsole();
}

void uart_putc(char ch) {
    while(!(UART0->S1 & UART_S1_TDRE_MASK));
    UART0->D = (uint8_t)ch;
}

void uart_puts(char *ptr_str) {
    while(*ptr_str) {
        if(*ptr_str == '\n') { uart_putc('\r'); }
        uart_putc(*ptr_str++);
    }
}

void short_delay(void) {
    for(int i = 50000; i > 0; i--){}
}

/*------------------------------*/
/* Main                         */
/*------------------------------*/

int main(void) {
    SRAWDATA accelData;
    int jump_cooldown = 0;

    init_uart();

    I2C_Init();
    short_delay();

    if (ACCEL_getDefaultConfig() != 1) {
        uart_puts("accel FAILED\n");
        while(1){}
    }

    uart_puts("Ready\n");

    while(1) {
        ACCEL_getAccelDat(&accelData);

        if (jump_cooldown > 0) jump_cooldown--;

        /* Jump detected when Y axis spikes below -3500 */
        /* Tune threshold and cooldown based on testing  */
        if (accelData.y < -2500 && jump_cooldown == 0) {
            uart_puts("J\n");
            jump_cooldown = 20;  /* ~150ms cooldown to prevent double triggers */
        }

        short_delay();
    }

    return 0;
}
