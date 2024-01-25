#include "kernel/io/io.h"

inline void outb(uint16_t port, uint8_t value) {
    __asm__ volatile ("out %0, %1"
            :
            : "Nd"(port), "a"(value)
            );
}

inline uint8_t inb(uint16_t port) {
    uint8_t res;
    __asm__ volatile ("in %0, %1"
            : "=a"(res)
            : "Nd"(port)
            );
    return res;
}
