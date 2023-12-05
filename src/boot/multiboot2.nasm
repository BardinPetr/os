; see https://www.gnu.org/software/grub/manual/multiboot2/multiboot.html
MULTIBOOT_MAGIC         equ 0xe85250d6
MULTIBOOT_ARCH          equ 0           ; i386
MULTIBOOT_HEADER_LENGTH equ header - header.end
MULTIBOOT_CHECKSUM      equ -(MULTIBOOT_MAGIC + MULTIBOOT_ARCH + MULTIBOOT_HEADER_LENGTH)

section .multiboot2
header:
	dd MULTIBOOT_MAGIC
	dd MULTIBOOT_ARCH
	dd MULTIBOOT_HEADER_LENGTH
    dd MULTIBOOT_CHECKSUM

    ; Tags section. Each 8-byte aligned
    ; dw type
    ; dw flags
    ; dd size

    ; terminator tag
    dw 0
    dw 0
    dd 8

    .end:
