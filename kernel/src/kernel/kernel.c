#include "kernel/kernel.h"
#include "kernel/io/serial.h"
#include "kernel/boot/multiboot2.h"
#include "kernel/io/tty.h"
#include "stdio.h"


void kernel_init(unsigned long magic, unsigned long mbi) {
    serial_init(SERIAL_COM_1, 115200);
    if (magic != MULTIBOOT2_BOOTLOADER_MAGIC) {
        serial_writes("Multiboot boot was not confirmed.");
        return;
    }

    serial_writes("Kernel init started. 64 bit mode\n");

    tty_init();
    printf("Loading...\n");

    while (1);
}
