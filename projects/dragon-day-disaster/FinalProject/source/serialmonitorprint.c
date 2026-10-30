#include "3140_serial.h"
#include "led.h"

int main(void) {
    led_init();
    uart_init();

    green_on_frdm();

    while(1) {
        uart_putString("AAA\r\n");
        delay(100);
    }

    return 0;
}
