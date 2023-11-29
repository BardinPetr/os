#include "kernel/io/serial.h"


bool serial_init(uint16_t port, uint32_t speed) {
    uint16_t divisor = 115200 / speed;
    outb(port + SERIAL_REG_INTERRUPT_ENABLE, 0x00);         // Disable interrupts
    outb(port + SERIAL_REG_LINE_CONTROL, 0x80);             // Enable DLAB
    outb(port + SERIAL_REG_DATA, divisor);                  // Speed divisor low and high bytes
    outb(port + SERIAL_REG_DATA + 1, divisor >> 8);
    outb(port + SERIAL_REG_LINE_CONTROL, 0x03);             // 8 bits, no parity, one stop bit
    outb(port + SERIAL_REG_INTERRUPT_IDENTIFICATION, 0xC7); // Enable FIFO, clear them, with 14-byte threshold
    outb(port + SERIAL_REG_MODEM_CONTROL, SERIAL_MODEM_CONTROL_IRQ);

    // Loopback test
    uint8_t check = 0x42;
    outb(port + SERIAL_REG_MODEM_CONTROL, SERIAL_MODEM_CONTROL_LOOP);
    outb(port + SERIAL_REG_DATA, check);
    if (inb(port + SERIAL_REG_DATA) != check)
        return 1;
    outb(port + SERIAL_REG_MODEM_CONTROL, SERIAL_MODEM_CONTROL_IRQ);

    return 0;
}


uint8_t serial_available() {
    return inb(SERIAL_COM_1 + SERIAL_REG_LINE_STATUS) & SERIAL_LINE_STATUS_DR;
}

uint8_t serial_read() {
    while (!serial_available());
    return inb(SERIAL_COM_1);
}

static bool serial_transmit_empty() {
    return inb(SERIAL_COM_1 + SERIAL_REG_LINE_STATUS) & SERIAL_LINE_STATUS_TEMT;
}

void serial_write(uint8_t a) {
    while (serial_transmit_empty() == 0);
    outb(SERIAL_COM_1, a);
}

void serial_writes(const char *ptr) {
    while (*ptr) serial_write(*ptr++);
}