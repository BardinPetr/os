#include "kernel/kernel.h"
#include "kernel/io/serial.h"



void kernel_init(void) {
    serial_init(SERIAL_COM_1, 115200);
    serial_writes("test string\n");
}