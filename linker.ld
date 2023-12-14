KERNEL_LMA = 1M;
KERNEL_VMA = 0xFFFFFF8000000000;

ENTRY(_bootstrap)

SECTIONS
{
    . = KERNEL_LMA + KERNEL_VMA;

    _KERNEL_START = .;

    .text ALIGN(4K) : AT(ADDR(.text) - KERNEL_VMA)
    {
        *(.multiboot2);
        _KERNEL_CODE_START = .;
        *(.text);
        _KERNEL_CODE_END = .;
    }

    .data ALIGN(4K) : AT(ADDR(.data) - KERNEL_VMA)
    {
        _KERNEL_DATA_START = .;
        *(.data)
        _KERNEL_DATA_END = .;
    }

    .eh_frame ALIGN(4K) : AT(ADDR(.eh_frame) - KERNEL_VMA)
    {
        *(.eh_frame)
    }

    .bss ALIGN(4K) : AT(ADDR(.bss) - KERNEL_VMA)
    {
        _KERNEL_BSS_START = .;
        *(.bss)
        *(COMMON)
        _KERNEL_BSS_END = .;
    }

    .rodata ALIGN(4K) : AT (ADDR(.rodata) - KERNEL_VMA)
    {
        _KERNEL_RODATA_START = .;
        *(.rodata)
        _KERNEL_RODATA_END = .;
    }

    _KERNEL_END = .;
}