#include <stdio.h>
#include <kernel/io/tty.h>

int puts(const char *string) {
    terminal_puts(string);
    return 1;
}
