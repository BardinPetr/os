KERNEL_LMA = 0x0000000000000000 + 1M;
KERNEL_VMA = 0;
/*KERNEL_VMA = 0xffffffff80000000;*/

ENTRY(_bootstrap)

SECTIONS
{
    . = KERNEL_LMA;

    .bootstrap :
    {
        *(.multiboot2);
        *bootstrap64*(.text);
    }

    . += KERNEL_VMA;

    _kernel_start = .;

    .text ALIGN(4K) : AT(ADDR(.text) - KERNEL_VMA)
    {
        _kernel_code = .;
        *(EXCLUDE_FILE(*bootstrap64*) .text)
    }

    .data ALIGN(4K) : AT(ADDR(.data) - KERNEL_VMA)
    {
        *(.data)
    }

    .eh_frame ALIGN(4K) : AT(ADDR(.eh_frame) - KERNEL_VMA)
    {
        *(.eh_frame)
    }

    .bss ALIGN(4K) : AT(ADDR(.bss) - KERNEL_VMA)
    {
        *(.bss)
        *(COMMON)
    }

    .rodata ALIGN(4K) : AT (ADDR (.rodata) - KERNEL_VMA)
    {
        *(.rodata)
    }

    _kernel_end = .;
}