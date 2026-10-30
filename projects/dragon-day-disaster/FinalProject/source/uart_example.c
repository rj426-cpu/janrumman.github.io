/*
 * FinalProject.c
 * Chrome Dinosaur Game — Board Side
 * ECE 3140 / CS 3420
 *
 * Reads accelerometer data and sends jump events over serial to Python game.
 * Board is strapped to player's body. Y axis spike below -3500 = jump.
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
    for(int i = 1000000; i > 0; i--){}
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
        if (accelData.y < -3500 && jump_cooldown == 0) {
            uart_puts("J\n");
            jump_cooldown = 15;  /* ~150ms cooldown to prevent double triggers */
        }

        short_delay();
    }

    return 0;
}
