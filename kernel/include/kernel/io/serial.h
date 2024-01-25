#ifndef OS_SERIAL_H
#define OS_SERIAL_H

#include "kernel/io/io.h"
#include <stdint.h>
#include <stdbool.h>

enum SERIAL_PORT_IO_NUMBER {
    SERIAL_COM_1 = 0x3F8,
};

enum SERIAL_PORT_REGISTER {
    SERIAL_REG_DATA = 0,
    SERIAL_REG_INTERRUPT_ENABLE,
    SERIAL_REG_INTERRUPT_IDENTIFICATION,
    SERIAL_REG_LINE_CONTROL,
    SERIAL_REG_MODEM_CONTROL,
    SERIAL_REG_LINE_STATUS,
    SERIAL_REG_MODEM_STATUS,
    SERIAL_REG_SCRATCH,
};

enum SERIAL_LINE_STATUS {
    SERIAL_LINE_STATUS_DR = 1 << 0,     // data ready
    SERIAL_LINE_STATUS_TEMT = 1 << 6    // transmitter empty
};

enum SERIAL_MODEM_CONTROL {
    SERIAL_MODEM_CONTROL_DTR = 1 << 0,
    SERIAL_MODEM_CONTROL_RTS = 1 << 1,
    SERIAL_MODEM_CONTROL_OUT1 = 1 << 2,
    SERIAL_MODEM_CONTROL_IRQ = 1 << 3,
    SERIAL_MODEM_CONTROL_LOOP = 1 << 4,
};


bool serial_init(uint16_t port, uint32_t speed);

uint8_t serial_available();

uint8_t serial_read();

void serial_write(uint8_t a);

void serial_writes(const char* string);

#endif //OS_SERIAL_H
