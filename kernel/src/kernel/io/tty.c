#include <stdint.h>
#include "kernel/io/tty.h"
#include "kernel/kernel.h"

#include <string.h>

static const size_t VGA_WIDTH = 80;
static const size_t VGA_HEIGHT = 25;

static size_t terminal_row;
static size_t terminal_column;
static uint8_t terminal_color;
static uint16_t *terminal_buffer;


void tty_init(void) {
    terminal_buffer = (uint16_t *) (KERNEL_LMA + 0xB8000);
    tty_clean();
}

void tty_put(char c, uint8_t color, size_t x, size_t y) {
    terminal_buffer[y * VGA_WIDTH + x] = vga_entry(c, color);
}

void tty_clean(void) {
    terminal_color = vga_entry_color(VGA_COLOR_GREEN, VGA_COLOR_BLACK);
    terminal_column = 0;
    terminal_row = 0;

    for (size_t x = 0; x < VGA_WIDTH; x++)
        for (size_t y = 0; y < VGA_HEIGHT; y++)
            tty_put(' ', terminal_color, x, y);
}

void tty_color(uint8_t color) {
    terminal_color = color;
}

void tty_putchar(char c) {
    switch (c) {
        case '\n':
            ++terminal_row;
        case '\r':
            terminal_column = 0;
            break;
        default:
            tty_put(c, terminal_color, terminal_column, terminal_row);
            ++terminal_column;
            break;
    }

    if (terminal_column == VGA_WIDTH) {
        terminal_column = 0;
        ++terminal_row;
    }
    if (terminal_row == VGA_HEIGHT)
        tty_clean();
}

void terminal_write(const char *data, size_t size) {
    for (size_t i = 0; i < size; i++)
        tty_putchar(data[i]);
}

void terminal_puts(const char *data) {
    terminal_write(data, strlen(data));
}
